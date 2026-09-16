--[[
	SPELLBOOK NAMING NOTE:
	For consistency with 20+ years of existing code, we're continuing to maintain the SpellBook/spellBook (capital B) captialization in code.
	Technically "spellbook" is one word (ie Spellbook/spellbook) but to avoid subtle confusing bugs from mixing/matching, do NOT use that casing.
]]

local Templates = {
	["HEADER"] = { template = "SpellBookHeaderTemplate", initFunc = SpellBookHeaderMixin.Init },
	["SPELL"] = { template = "SpellBookItemTemplate", initFunc = SpellBookItemMixin.Init, resetFunc = SpellBookItemMixin.Reset },
	["OUTFIT"] = { template = "SpellBookOutfitItemTemplate", initFunc = SpellBookOutfitItemMixin.Init, resetFunc = SpellBookItemMixin.Reset },
};

-- Events that should always be listened to
local SpellBookLifetimeEvents = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_LEAVING_WORLD",
};
-- Events that should only be listened to while in the world (avoided while entering/exiting it)
local SpellBookInWorldEvents = {
	"LEARNED_SPELL_IN_SKILL_LINE",
	"USE_GLYPH",
	"ACTIVATE_GLYPH",
	"CANCEL_GLYPH_CAST",
	"TRANSMOG_OUTFITS_CHANGED"
};
-- Events that should only be listened to while already visible
local SpellBookWhileVisibleEvents = {
	"SPELLS_CHANGED",
	"DISPLAY_SIZE_CHANGED",
	"UI_SCALE_CHANGED",
};
local SpellBookWhileVisibleUnitEvents = {
	"PLAYER_SPECIALIZATION_CHANGED",
};

SpellBookFrameMixin = CreateFromMixins(SpellBookFrameTutorialsMixin, SpellBookSearchMixin);

function SpellBookFrameMixin:OnLoad()
	TabSystemOwnerMixin.OnLoad(self);
	self:SetTabSystem(self.CategoryTabSystem);
	self.CategoryTabSystem:SetScript("OnSizeChanged", GenerateClosure(self.ResizeSearchBox, self));

	self:CreateCategoryMixins();

	self.PagedSpellsFrame:SetElementTemplateData(Templates);
	self.PagedSpellsFrame:RegisterCallback(PagedContentFrameBaseMixin.Event.OnUpdate, self.OnPagedSpellsUpdate, self);

	self:SetupSettingsDropdown();

	FrameUtil.RegisterFrameForEvents(self, SpellBookLifetimeEvents);
	EventRegistry:RegisterCallback("ClickBindingFrame.UpdateFrames", self.OnClickBindingUpdate, self);
	EventRegistry:RegisterCallback("AssistedCombatManager.OnSetActionSpell", function(o)
		self:UpdateAttic();
		self:CheckShowHelpTips();
	end);
	EventRegistry:RegisterCallback("AssistedCombatManager.OnSetCanHighlightSpellbookSpells", self.MarkSpellDataDirty, self);
	EventRegistry:RegisterCallback("AssistedCombatManager.OnSetUseAssistedHighlight", self.MarkSpellDataDirty, self);

	-- If already in the world (ie due to load on demand), make sure to register for in-world events
	if IsPlayerInWorld() then
		FrameUtil.RegisterFrameForEvents(self, SpellBookInWorldEvents);
	end

	local onPagingButtonEnter = GenerateClosure(self.OnPagingButtonEnter, self);
	local onPagingButtonLeave = GenerateClosure(self.OnPagingButtonLeave, self);
	self.PagedSpellsFrame.PagingControls:SetButtonHoverCallbacks(onPagingButtonEnter, onPagingButtonLeave);

	-- Start the page corner flipbook to sit on its first frame while not playing
	self.BookCornerFlipbook.Anim:Play();
	self.BookCornerFlipbook.Anim:Pause();

	SpellBookFrameTutorialsMixin.OnLoad(self);
	self:InitializeSearch();
end

function SpellBookFrameMixin:CreateCategoryMixins()
	self:RemoveAllTabs();
	self.categoryMixins = {
		CreateAndInitFromMixin(SpellBookClassCategoryMixin, self);
		CreateAndInitFromMixin(SpellBookGeneralCategoryMixin, self);
		CreateAndInitFromMixin(SpellBookPetCategoryMixin, self);
	};

	for _, categoryMixin in ipairs(self.categoryMixins) do
		categoryMixin:SetTabID(self:AddNamedTab(categoryMixin:GetName()));
	end
end

function SpellBookFrameMixin:OnPagedSpellsUpdate()
	self:CheckShowHelpTips();
	EventRegistry:TriggerEvent("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged");

	if (InputUtil.IsGamepadUIEnabled()) then
		self:ResetGamepadCursorLocation();
	end
end

function SpellBookFrameMixin:OnShowBase()
	self:UpdateAttic();
	self:UpdateAllSpellData();

	if not self:GetTab() and not self:IsInSearchResultsMode() then
		self:ResetToFirstAvailableTab();
	end

	FrameUtil.RegisterFrameForEvents(self, SpellBookWhileVisibleEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, SpellBookWhileVisibleUnitEvents, "player");

	EventRegistry:TriggerEvent("PlayerSpellsFrame.SpellBookFrame.Show");

	if InClickBindingMode() then
		ClickBindingFrame:SetFocusedFrame(self:GetParent());
	end

	SpellBookFrameTutorialsMixin.OnShow(self);
end

function SpellBookFrameMixin:OnShow()
	-- overriden in other flavors
	self:OnShowBase();
end

function SpellBookFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SpellBookWhileVisibleEvents);
	FrameUtil.UnregisterFrameForEvents(self, SpellBookWhileVisibleUnitEvents);

	EventRegistry:TriggerEvent("PlayerSpellsFrame.SpellBookFrame.Hide");

	if InClickBindingMode() then
		ClickBindingFrame:ClearFocusedFrame();
	end

	SpellBookFrameTutorialsMixin.OnHide(self);
end

function SpellBookFrameMixin:OnEvent(event, ...)
	if event =="PLAYER_ENTERING_WORLD" then
		FrameUtil.RegisterFrameForEvents(self, SpellBookInWorldEvents);
	elseif event =="PLAYER_LEAVING_WORLD" then
		FrameUtil.UnregisterFrameForEvents(self, SpellBookInWorldEvents);
	elseif event == "SPELLS_CHANGED" or event == "TRANSMOG_OUTFITS_CHANGED" then
		self:HandleSpellsChanged();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		local resetCurrentPage = true;
		self:UpdateAllSpellData(resetCurrentPage);
	elseif event == "LEARNED_SPELL_IN_SKILL_LINE" then
		local spellID, skillLineIndex, isGuildSpell = ...;
		self:UpdateAllSpellData();
	elseif event == "USE_GLYPH" then
		-- Player has used a glyph or remover and is choosing what spell to use it on
		-- Time for "pending glyph" visuals
		local spellID = ...;
		local isGlyphActivation = false;
		self:GoToSpellForGlyph(spellID, isGlyphActivation);
	elseif event == "ACTIVATE_GLYPH" then
		-- Player has selected a spell to use a glyph or remover on
		-- Time for "glyph activated" visuals
		local spellID = ...;
		local isGlyphActivation = true;
		self:GoToSpellForGlyph(spellID, isGlyphActivation);
	elseif event == "CANCEL_GLYPH_CAST" then
		-- Player has canceled the use of a glyph or remover
		-- Clear any pending/activated glyph states
		self:ForEachDisplayedSpell(function(spellBookItemFrame)
			spellBookItemFrame:UpdateGlyphState();
		end);
	elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		self:UpdateTutorialsForFrameSize();
	end
end

function SpellBookFrameMixin:HandleSpellsChanged()
	self:UpdateAllSpellData();
end

function SpellBookFrameMixin:SetupHidePassivesCheckbox(rootDescription)
	local function HidePassivesIsSelected()
		return GetCVarBool("spellBookHidePassives");
	end

	local function HidePassivesSetSelected()
		SetCVar("spellBookHidePassives", not HidePassivesIsSelected());
		local forceUpdateSpellGroups, resetCurrentPage = true, false;
		self:UpdateDisplayedSpells(forceUpdateSpellGroups, resetCurrentPage);
	end

	local function HidePassivesIsEnabled()
		return not self:IsInSearchResultsMode();
	end

	rootDescription:SetTag("MENU_SPELL_BOOK_SETTINGS");
	local hidePassivesCheckbox = rootDescription:CreateCheckbox(SPELLBOOK_FILTER_PASSIVES, HidePassivesIsSelected, HidePassivesSetSelected);
	hidePassivesCheckbox:SetEnabled(HidePassivesIsEnabled);
	hidePassivesCheckbox:SetTooltip(function(tooltip, elementDescription)
		if not HidePassivesIsEnabled() then
			GameTooltip_AddHighlightLine(tooltip, SPELLBOOK_SEARCH_HIDE_PASSIVES_DISABLED);
		end
	end);

	if (InputUtil.IsGamepadUIEnabled()) then
		hidePassivesCheckbox:SetResponse(MenuResponse.Close);
	end
end

function SpellBookFrameMixin:SetupAllRanksCheckbox(rootDescription)
	local function AllRanksIsSelected()
		return GetCVarBool("ShowAllSpellRanks");
	end

	local function AllRanksSetSelected()
		SetCVar("ShowAllSpellRanks", not AllRanksIsSelected());
		local forceUpdateSpellGroups, resetCurrentPage = true, false;
		self:UpdateDisplayedSpells(forceUpdateSpellGroups, resetCurrentPage);
	end

	local function AllRanksIsEnabled()
		return not self:IsInSearchResultsMode();
	end

	local allRanksCheckbox = rootDescription:CreateCheckbox(SHOW_ALL_SPELL_RANKS, AllRanksIsSelected, AllRanksSetSelected);
	allRanksCheckbox:SetEnabled(AllRanksIsEnabled);

	if (InputUtil.IsGamepadUIEnabled()) then
		allRanksCheckbox:SetResponse(MenuResponse.Close);
	end
end

function SpellBookFrameMixin:SetupUseFlyoutsCheckbox(rootDescription)
	local function UseFlyoutsIsSelected()
		return not self:IsHidingFlyouts();
	end

	local function UseFlyoutsSetSelected()
		SetCVar("spellBookHideFlyouts", UseFlyoutsIsSelected());
		local forceUpdateSpellGroups, resetCurrentPage = true, false;
		self:UpdateDisplayedSpells(forceUpdateSpellGroups, resetCurrentPage);
	end

	local function UseFlyoutsIsEnabled()
		return not self:IsInSearchResultsMode() and not InputUtil.IsGamepadUIEnabled();
	end

	local useFlyoutsCheckbox = rootDescription:CreateCheckbox(SPELLBOOK_USE_FLYOUTS, UseFlyoutsIsSelected, UseFlyoutsSetSelected);
	useFlyoutsCheckbox:SetEnabled(UseFlyoutsIsEnabled);

	if (InputUtil.IsGamepadUIEnabled()) then
		useFlyoutsCheckbox:SetResponse(MenuResponse.Close);
	end
end

function SpellBookFrameMixin:SetupSettingsDropdown()
	-- default is no dropdown, overrides add game-specific options
	self.SettingsDropdown:Hide();
end

function SpellBookFrameMixin:UpdateAttic()
	self.SettingsDropdown:ClearAllPoints();
	if AssistedCombatManager:HasActionSpell() then
		self.AssistedCombatRotationSpellFrame:Show();
		local actionSpelID = AssistedCombatManager:GetActionSpellID();
		self.AssistedCombatRotationSpellFrame:SetSpellID(actionSpelID);
		self.SettingsDropdown:SetPoint("TOP", 0, self.SettingsDropdown.yOffset);
		self.SettingsDropdown:SetPoint("RIGHT", self.AssistedCombatRotationSpellFrame, "LEFT", -11, 0);
	else
		self.AssistedCombatRotationSpellFrame:Hide();
		self.SettingsDropdown:SetPoint("TOPRIGHT", -30, self.SettingsDropdown.yOffset);
	end
	self:ResizeSearchBox();
end

function SpellBookFrameMixin:SetTab(tabID)
	TabSystemOwnerMixin.SetTab(self, tabID);

	self:OnActiveCategoryChanged();
end

function SpellBookFrameMixin:SelectNextTab(forward)
	local nextTab = self:GetNextCategoryMixin(forward);
	if (nextTab) then
		TabSystemOwnerMixin.SetTab(self, nextTab:GetTabID());
		self:OnActiveCategoryChanged();
	end
end

function SpellBookFrameMixin:SetMinimized(shouldBeMinimized)
	local minimizedChanged = self.isMinimized ~= shouldBeMinimized;
	if not self.isMinimized and shouldBeMinimized then
		self.isMinimized = true;
		self:SetWidth(self.minimizedWidth);

		-- Collapse down to one paged view (ie left half of book)
		self.PagedSpellsFrame:SetViewsPerPage(1, true);
		self.PagedSpellsFrame.ViewFrames[2]:Hide();

		-- Minimizing requires shortening TopBar and adjusting the right UV to prevent it from looking squished.
		self.TopBar:SetTexCoord(0, self.minimizedWidth / self.topBarFullWidth, 0, 1);
		self.TopBar:SetWidth(self.minimizedWidth);
	elseif self.isMinimized and not shouldBeMinimized then
		self.isMinimized = false;
		self:SetWidth(self.maximizedWidth);

		-- Expand back up to two paged views (ie whole book)
		self.PagedSpellsFrame.ViewFrames[2]:Show();
		self.PagedSpellsFrame:SetViewsPerPage(2, true);

		-- Maximizing requires lenghtening TopBar and adjusting the right UV to prevent it from looking stretched.
		self.TopBar:SetTexCoord(0, self.maximizedWidth / self.topBarFullWidth, 0, 1);
		self.TopBar:SetWidth(self.maximizedWidth);
	end

	if minimizedChanged then
		self:ResizeSearchBox();
		for _, minimizedPiece in ipairs(self.minimizedArt) do
			minimizedPiece:SetShown(self.isMinimized);
		end
		for _, maximizedPiece in ipairs(self.maximizedArt) do
			maximizedPiece:SetShown(not self.isMinimized);
		end

		self:UpdateTutorialsForFrameSize();
	end
end

local SEARCH_BOX_MAX_WIDTH = 300;
local SEARCH_BOX_LEFT_SPACING = 10;
function SpellBookFrameMixin:ResizeSearchBox()
	local width = SEARCH_BOX_MAX_WIDTH;
	local leftEdge = self.CategoryTabSystem:GetRight();
	local rightEdge = self.SearchBox:GetRight();
	if leftEdge and rightEdge then
		local space = rightEdge - leftEdge - SEARCH_BOX_LEFT_SPACING;
		width = math.min(space, SEARCH_BOX_MAX_WIDTH);
	end
	self.SearchBox:SetWidth(width);
end

-- Expects a PlayerSpellsUtil.SpellBookCategories value
function SpellBookFrameMixin:TrySetCategory(categoryEnum)
	for _, categoryMixin in ipairs(self.categoryMixins) do
		if categoryMixin:GetCategoryEnum() == categoryEnum and categoryMixin:IsAvailable() then
			self:SetTab(categoryMixin:GetTabID());
			return true;
		end
	end
	return false;
end

-- Expects a PlayerSpellsUtil.SpellBookCategories value
function SpellBookFrameMixin:IsCategoryActive(categoryEnum)
	local activeCategoryMixin = self:GetActiveCategoryMixin();

	return activeCategoryMixin and activeCategoryMixin:GetCategoryEnum() == categoryEnum;
end

function SpellBookFrameMixin:GoToSpellForGlyph(spellID, isGlyphActivation)
	if not self:IsVisible() then
		PlayerSpellsUtil.OpenToSpellBookTab();
	end

	local knownSpellsOnly, toggleFlyout = true, true;
	local flyoutReason = isGlyphActivation and SpellFlyoutOpenReason.GlyphActivated or SpellFlyoutOpenReason.GlyphPending;
	local spellButton, flyoutButton = self:GoToSpell(spellID, knownSpellsOnly, toggleFlyout, flyoutReason);

	-- SpellFlyout takes care of its own glyph visuals, so update spells not in a flyout
	if spellButton and not flyoutButton then
		if isGlyphActivation then
			spellButton:ShowGlyphActivation();
		else
			spellButton:UpdateGlyphState();
		end
	end
end

-- If found, navigates to the category and page containing the spell and returns its frame
-- If spell is inside a flyout, returns Flyout button and SpellBookItem frame; Otherwise, returns only SpellBookItem frame
function SpellBookFrameMixin:GoToSpell(spellID, knownSpellsOnly, toggleFlyout, flyoutReason)
	local includeHidden = false;
	local includeFlyouts = true;
	local includeFutureSpells = not knownSpellsOnly;
	local includeOffSpec = not knownSpellsOnly;

	local slotIndex, spellBank = C_SpellBook.FindSpellBookSlotForSpell(spellID, includeHidden, includeFlyouts, includeFutureSpells, includeOffSpec);

	if not slotIndex or not spellBank then
		return;
	end

	local activeTabID = self:GetTab();
	local categoryMixinForSpell = nil;
	-- Each category contains specific ranges of slot indices within a spell bank, find which one contains this index
	for _, categoryMixin in ipairs(self.categoryMixins) do
		if categoryMixin:ContainsSlot(slotIndex, spellBank) then
			categoryMixinForSpell = categoryMixin;
			break;
		end
	end

	if not categoryMixinForSpell or not categoryMixinForSpell:IsAvailable() then
		return;
	end

	-- Switch categories to the matching one
	if categoryMixinForSpell:GetTabID() ~= activeTabID then
		self:SetTab(categoryMixinForSpell:GetTabID());
	end

	-- Try to page to the matching SpellBookItem
	local spellBookItemFrame = self.PagedSpellsFrame:GoToElementByPredicate(function(elementData) return elementData.slotIndex == slotIndex; end);

	if not spellBookItemFrame then
		return;
	end

	if spellBookItemFrame:IsFlyout() then
		if toggleFlyout then
			spellBookItemFrame:ToggleFlyout(flyoutReason);
		end
		local spellButton = SpellFlyout:GetFlyoutButtonForSpell(spellID);
		return spellButton, spellBookItemFrame;
	end

	return spellBookItemFrame;
end

-- Returns frame for spell only if it's currently being displayed; See GoToSpell to page to and get the specified spell
-- If spell is inside a flyout, returns Flyout button and SpellBookItem frame; Otherwise, returns only SpellBookItem frame
function SpellBookFrameMixin:GetSpellFrame(spellID, knownSpellsOnly, toggleFlyout, flyoutReason)
	local includeHidden = false;
	local includeFlyouts = true;
	local includeFutureSpells = not knownSpellsOnly;
	local includeOffSpec = not knownSpellsOnly;

	local slotIndex, spellBank = C_SpellBook.FindSpellBookSlotForSpell(spellID, includeHidden, includeFlyouts, includeFutureSpells, includeOffSpec);

	if not slotIndex or not spellBank then
		return;
	end

	-- Try to page to the matching SpellBookItem
	local spellBookItemFrame = self.PagedSpellsFrame:GetElementFrameByPredicate(function(elementData)
		return elementData.slotIndex == slotIndex and elementData.spellBank == spellBank;
	end);

	if not spellBookItemFrame then
		return;
	end

	if spellBookItemFrame:IsFlyout() then
		if toggleFlyout then
			spellBookItemFrame:ToggleFlyout(flyoutReason);
		end
		local spellButton = SpellFlyout:GetFlyoutButtonForSpell(spellID);
		return spellButton, spellBookItemFrame;
	end

	return spellBookItemFrame;
end

function SpellBookFrameMixin:OnActiveCategoryChanged()
	local newActiveTabID = self:GetTab();
	if newActiveTabID == nil then
		self.PagedSpellsFrame:RemoveDataProvider();
		self.lastActiveTabID = nil;
		return;
	end

	if self:IsInSearchResultsMode() then
		local skipTabReset = true;
		self:ClearActiveSearchState(skipTabReset);
	end

	local wasCategoryActive = self.lastActiveTabID == newActiveTabID;
	self.lastActiveTabID = newActiveTabID;

	local forceUpdateSpellGroups = not wasCategoryActive;
	local resetCurrentPage = not wasCategoryActive;
	self:UpdateDisplayedSpells(forceUpdateSpellGroups, resetCurrentPage);
end

function SpellBookFrameMixin:MarkSpellDataDirty()
	self.spellDataDirty = true;
	if self:IsVisible() then
		self:UpdateAllSpellData();
	end
end

function SpellBookFrameMixin:UpdateAllSpellData(resetCurrentPage)
	-- Refresh spell Category data.
	self:CreateCategoryMixins();

	local activeTabID = self:GetTab();
	self:SetTab(activeTabID);

	self.isUpdatingAllSpellData = true;

	local isActiveCategoryUnavailable = false;
	local didActiveCategorySpellGroupsChange = false;

	-- Update all category spell groups
	for _, categoryMixin in ipairs(self.categoryMixins) do
		local tabID = categoryMixin:GetTabID();

		local isAvailable = categoryMixin:IsAvailable();
		local didSpellGroupsChange = categoryMixin:UpdateSpellGroups();

		self.CategoryTabSystem:SetTabShown(tabID, isAvailable);

		if activeTabID == tabID then
			isActiveCategoryUnavailable = not isAvailable;
			didActiveCategorySpellGroupsChange = didSpellGroupsChange;
		end
	end

	if isActiveCategoryUnavailable then
		self:ResetToFirstAvailableTab();
	else
		local forceUpdateSpellGroups = self.spellDataDirty or didActiveCategorySpellGroupsChange;
		self:UpdateDisplayedSpells(forceUpdateSpellGroups, resetCurrentPage);
	end

	self.isUpdatingAllSpellData = false;
	self.spellDataDirty = false;
end

function SpellBookFrameMixin:UpdateDisplayedSpells(forceUpdateSpellGroups, resetCurrentPage)
	local activeCategoryMixin = self:GetActiveCategoryMixin();
	if not activeCategoryMixin then
		if self:IsInSearchResultsMode() then
			self:UpdateFullSearchResults();
		end
		return;
	end

	local didSpellGroupsChange = false;
	-- Only update category's spell groups if that hasn't already been covered as part of updating all data
	if not self.isUpdatingAllSpellData then
		didSpellGroupsChange = activeCategoryMixin:UpdateSpellGroups();
	end

	if didSpellGroupsChange or forceUpdateSpellGroups then
		-- Spell groups updated, so recreate data provider for spell book items using them
		local byDataGroup = true;
		local categoryData = activeCategoryMixin:GetSpellBookItemData(byDataGroup, self:GetSpellBookItemFilterInstance());
		local categoryDataProvider = CreateDataProvider(categoryData);
		self.PagedSpellsFrame:SetDataProvider(categoryDataProvider, not resetCurrentPage);
	else
		-- No spell groups update, so just update the already-populated spell book item frames
		self:ForEachDisplayedSpell(function(spellBookItemFrame)
			spellBookItemFrame:UpdateSpellData();
		end);
	end
end

-- Creates an instance of ShouldDisplaySpellBookItem with injected state checks to prevent needlessly repeating expensive checks over every single SpellBookItem
function SpellBookFrameMixin:GetSpellBookItemFilterInstance()
	local isKioskEnabled = Kiosk.IsEnabled();
	local isHidingPassives = self:IsHidingPassives();
	local isHidingLowRank = self:IsHidingLowRank();
	local isHidingFlyouts = self:IsHidingFlyouts();
	return GenerateClosure(self.ShouldDisplaySpellBookItem, self, isKioskEnabled, isHidingPassives, isHidingLowRank, isHidingFlyouts);
end

function SpellBookFrameMixin:IsHidingPassives()
	return not self:IsInSearchResultsMode() and GetCVarBool("spellBookHidePassives");
end

function SpellBookFrameMixin:IsHidingLowRank()
	return not self:IsInSearchResultsMode() and not GetCVarBool("ShowAllSpellRanks");
end

function SpellBookFrameMixin:IsHidingFlyouts()
	return not InputUtil.IsGamepadUIEnabled() and GetCVarBool("spellBookHideFlyouts");
end

function SpellBookFrameMixin:ShouldDisplaySpellBookItem(isKioskEnabled, isHidingPassives, isHidingLowRank, isHidingFlyouts, slotIndex, spellBank)
	local spellBookItemType = C_SpellBook.GetSpellBookItemType(slotIndex, spellBank);
	if isKioskEnabled then
		-- If in Kiosk mode, filter out any future spells
		if not spellBookItemType or spellBookItemType == Enum.SpellBookItemType.FutureSpell then
			return false;
		end
	end
	if isHidingPassives then
		local isPassive = C_SpellBook.IsSpellBookItemPassive(slotIndex, spellBank);
		if isPassive then
			return false;
		end
	end
	if isHidingLowRank then
		if C_SpellBook.IsSpellBookItemLowRank(slotIndex, spellBank) then
			return false;
		end
	end
	-- If we're using flyouts, show the flyout icons and hide loose spells contained in a flyout.
	-- If we aren't, hide the flyout icons and show the loose spells.
	local isFlyout = spellBookItemType == Enum.SpellBookItemType.Flyout;
	local isFlyoutMember = C_SpellBook.IsSpellBookItemLooseFlyoutMember(slotIndex, spellBank);
	if isHidingFlyouts and isFlyout then
		return false;
	end
	if not isHidingFlyouts and isFlyoutMember then
		return false;
	end
	
	return true;
end

function SpellBookFrameMixin:ForEachDisplayedSpell(func)
	for _, frame in self.PagedSpellsFrame:EnumerateFrames() do
		if frame.HasValidData and frame:HasValidData() then -- Avoid header or spacer frames
			func(frame);
		end
	end
end

function SpellBookFrameMixin:ResetToFirstAvailableTab()
	for _, categoryMixin in ipairs(self.categoryMixins) do
		local isAvailable = categoryMixin:IsAvailable();
		if isAvailable then
			self:SetTab(categoryMixin:GetTabID());
			return;
		end
	end
	self:SetTab(nil);
end

function SpellBookFrameMixin:GetActiveCategoryMixin()
	local currentTabID = self:GetTab();
	if not currentTabID then
		return nil;
	end

	for _, categoryMixin in ipairs(self.categoryMixins) do
		if categoryMixin:GetTabID() == currentTabID then
			return categoryMixin;
		end
	end

	return nil;
end

function SpellBookFrameMixin:GetNextCategoryMixin(forward)
	local currentTabID = self:GetTab();
	if not currentTabID then
		return nil;
	end

	local step = forward and 1 or -1;
	local lastIndex = forward and #self.categoryMixins or 1;

	for index = currentTabID + step, lastIndex, step do
		local categoryMixin = self.categoryMixins[index];
		if categoryMixin:IsAvailable() then
			return categoryMixin;
		end
	end

	return nil;
end

function SpellBookFrameMixin:OnClickBindingUpdate()
	self:ForEachDisplayedSpell(function(spellBookItemFrame)
		spellBookItemFrame:UpdateClickBindState();
	end);
end

function SpellBookFrameMixin:OnPagingButtonEnter()
	self.BookCornerFlipbook.Anim:Play();
end

function SpellBookFrameMixin:OnPagingButtonLeave()
	local reverse = true;
	self.BookCornerFlipbook.Anim:Play(reverse);
end

-- Resets the gamepad cursor to the first valid spell entry currently visible.
-- Used when there is no previous cursor position to restore.
function SpellBookFrameMixin:ResetGamepadCursorLocation()
	SmartNavigation:RefreshButtonGroups(self:GetParent());

	for _, frame in self.PagedSpellsFrame:EnumerateFrames() do
		if frame.HasValidData and frame:HasValidData()  then
			if (SmartNavigation:GetActiveFrame() == self:GetParent()) then
				SmartNavigation:SelectButton(nil);
				SmartNavigation:SelectButton(frame.Button);
			end
			break;
		end
	end
end

-- Restores cursor position after moving to a previous page.
-- Prefers the rightmost item on the matching row so navigation feels continuous when paging backwards.
-- Depending on our traversal type, we optionally preserve relative cursor position.
function SpellBookFrameMixin:RestoreCursorPositionOnPreviousPage(prevX, prevY, preserveRelativePosition)
	local preferRightmost = preserveRelativePosition and true;
	self:RestoreCursorPositionOnPage(prevX, prevY, preferRightmost);
end

-- Restores cursor position after moving to the next page.
-- Prefers the leftmost item on the matching row so navigation feels continuous when paging forwards.
function SpellBookFrameMixin:RestoreCursorPositionOnNextPage(prevX, prevY)
	local preferRightmost = false;
	self:RestoreCursorPositionOnPage(prevX, prevY, preferRightmost);
end

-- Restores the gamepad cursor to the row closest to its previous position.
-- If multiple candidates exist on that row, selects either the leftmost or rightmost item depending on paging direction.
function SpellBookFrameMixin:RestoreCursorPositionOnPage(prevX, prevY, preferRightmost)
	SmartNavigation:RefreshButtonGroups(self:GetParent());

	local bestFrame;
	local bestYDistance = math.huge;
	local bestX = preferRightmost and -math.huge or math.huge;

	for _, frame in self.PagedSpellsFrame:EnumerateFrames() do
		if frame.HasValidData and frame:HasValidData() then
			local frameX, frameY = frame:GetCenter();

			local yDistance = math.abs(frameY - prevY);
			local isBetterX = preferRightmost and frameX > bestX or frameX < bestX

			if yDistance < bestYDistance or (yDistance == bestYDistance and isBetterX) then
				bestFrame = frame;
				bestYDistance = yDistance;
				bestX = frameX;
			end
		end
	end

	if bestFrame and SmartNavigation:GetActiveFrame() == self:GetParent() then
		SmartNavigation:SelectButton(nil);
		SmartNavigation:SelectButton(bestFrame.Button);
	end
end

function SpellBookFrameMixin:GamepadSpellBookPreviousPage(preserveRelativePosition)
	-- Store position of current button before updating page
	local prevX, prevY = SmartNavigation:GetCurrentButton():GetCenter();

	local pageControls = self.PagedSpellsFrame.PagingControls;
	local nextCategoryTab = self:GetNextCategoryMixin(false);

	if (pageControls:GetCurrentPage() > 1) then
		pageControls:PreviousPage();
		self:RestoreCursorPositionOnPreviousPage(prevX, prevY, preserveRelativePosition);
	elseif (nextCategoryTab) then
		self:SelectNextTab(false);
	end
end

function SpellBookFrameMixin:GamepadSpellBookNextPage()
	-- Store position of current button before updating page
	local prevX, prevY = SmartNavigation:GetCurrentButton():GetCenter();

	local pageControls = self.PagedSpellsFrame.PagingControls;
	local nextCategoryTab = self:GetNextCategoryMixin(true);

	if (pageControls:GetCurrentPage() < pageControls:GetMaxPages()) then
		pageControls:NextPage();
		self:RestoreCursorPositionOnNextPage(prevX, prevY);
	elseif (nextCategoryTab) then
		self:SelectNextTab(true);
	end
end

local function FindTopLeftFrameForView(viewFrame)
	local bestFrame;
	local bestRow = math.huge;
	local bestColumn = math.huge;

	for _, frame in ipairs(viewFrame:GetLayoutChildren()) do
		if frame.HasValidData and frame:HasValidData() then
			local row = frame.gridRow or math.huge;
			local column = frame.gridColumn or math.huge;

			if row < bestRow or row == bestRow and column < bestColumn then
				bestFrame = frame;
				bestRow = row;
				bestColumn = column;
			end
		end
	end

	return bestFrame;
end

function SpellBookFrameMixin:GetViewIndexOfButton(button)
	local elementFrame = button:GetParent();
	for viewIndex, viewFrame in ipairs(self.PagedSpellsFrame.ViewFrames) do
		if elementFrame:GetParent() == viewFrame then
			return viewIndex;
		end
	end
end

function SpellBookFrameMixin:GamepadNavigateViewRight()
	local currentButton = SmartNavigation:GetCurrentButton();
	if not currentButton then
		return;
	end

	local viewsPerPage = self.PagedSpellsFrame.viewsPerPage or 1;
	local currentViewIndex = self:GetViewIndexOfButton(currentButton);

	if viewsPerPage > 1 and currentViewIndex < viewsPerPage then
		local nextViewFrame = self.PagedSpellsFrame.ViewFrames[currentViewIndex + 1];

		if nextViewFrame then
			local firstFrame = FindTopLeftFrameForView(nextViewFrame);

			if firstFrame and SmartNavigation:GetActiveFrame() == self:GetParent() then
				SmartNavigation:SelectButton(nil);
				SmartNavigation:SelectButton(firstFrame.Button);
				return;
			end
		end
	end

	self:GamepadSpellBookNextPage();
end

function SpellBookFrameMixin:GamepadNavigateViewLeft()
	local currentButton = SmartNavigation:GetCurrentButton();
	if not currentButton then
		return;
	end

	local viewsPerPage = self.PagedSpellsFrame.viewsPerPage or 1;
	local currentViewIndex = self:GetViewIndexOfButton(currentButton);

	if viewsPerPage > 1 and currentViewIndex > 1 then
		local previousViewFrame = self.PagedSpellsFrame.ViewFrames[currentViewIndex - 1];

		if previousViewFrame then
			local firstFrame = FindTopLeftFrameForView(previousViewFrame);

			if firstFrame and SmartNavigation:GetActiveFrame() == self:GetParent() then
				SmartNavigation:SelectButton(nil);
				SmartNavigation:SelectButton(firstFrame.Button);
				return;
			end
		end
	end

	local preserveRelativePosition = false;
	self:GamepadSpellBookPreviousPage(preserveRelativePosition);
end

AssistedCombatRotationSpellFrameMixin = { };

function AssistedCombatRotationSpellFrameMixin:OnIconEnter()
	UIPanelSpellButtonFrameMixin.OnIconEnter(self);
	AssistedCombatManager:SetCanHighlightSpellbookSpells(true);
	self:ShowTooltip();
end

function AssistedCombatRotationSpellFrameMixin:OnIconLeave()
	UIPanelSpellButtonFrameMixin.OnIconLeave(self);
	AssistedCombatManager:SetCanHighlightSpellbookSpells(false);
end

function AssistedCombatRotationSpellFrameMixin:OnIconDragStart()
	HelpTip:Acknowledge(UIParent, ASSISTED_COMBAT_ROTATION_DRAG_HELPTIP);
	UIPanelSpellButtonFrameMixin.OnIconDragStart(self);
end

function AssistedCombatRotationSpellFrameMixin:OnIconClick(frame, button)
	-- do nothing
end

function AssistedCombatRotationSpellFrameMixin:UpdateTooltip()
	-- nop because this one runs every TOOLTIP_UPDATE_TIME but
	-- our tooltip isn't a spell so constant updates aren't needed
end

function AssistedCombatRotationSpellFrameMixin:ShowTooltip()
	local tooltip = GameTooltip;
	GameTooltip_SetTitle(tooltip, ASSISTED_COMBAT_ROTATION, HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddNormalLine(tooltip, AssistedCombatManager:GetActionSpellDescription());
	GameTooltip_AddBlankLineToTooltip(tooltip);

	local spellInfos = { };
	-- there are spells with different IDs but same name, like the shaman Earthquake talent choice node
	local function TryInsertSpell(spellID)
		local newInfo = C_Spell.GetSpellInfo(spellID);
		for i, spellInfo in ipairs(spellInfos) do
			if newInfo.name == spellInfo.name then
				table.remove(spellInfos, i);
				break;
			end
		end
		table.insert(spellInfos, newInfo);
	end

	local rotationSpells = C_AssistedCombat.GetRotationSpells();
	for i, spellID in ipairs(rotationSpells) do
		spellID = C_Spell.GetOverrideSpell(spellID);
		local spellBank = Enum.SpellBookSpellBank.Player;
		local includeOverrides = true;
		if C_SpellBook.IsSpellInSpellBook(spellID, spellBank, includeOverrides) then
			TryInsertSpell(spellID);
		end
	end

	table.sort(spellInfos, function(lhs, rhs)
		if lhs.isKnown ~= rhs.isKnown then
			return lhs.isKnown;
		end
		return strcmputf8i(lhs.name, rhs.name) < 0;
	end);

	local textureSettings = {
		width = 32,
		height = 32,
		anchor = Enum.TooltipTextureAnchor.LeftCenter,
		margin = { left = 0, right = 8, top = 0, bottom = 4 },
	};

	for i, spellInfo in ipairs(spellInfos) do
		GameTooltip_AddHighlightLine(tooltip, spellInfo.name);
		if i == #spellInfos then
			textureSettings.margin.bottom = 0;
		end
		tooltip:AddTexture(spellInfo.originalIconID, textureSettings);
	end

	if not C_ActionBar.HasAssistedCombatActionButtons() then
		GameTooltip_AddColoredLine(tooltip, SPELLBOOK_SPELL_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR);
	end

	tooltip:Show();
end
