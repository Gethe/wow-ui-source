--[[
	SPELLBOOK NAMING NOTE:
	For consistency with 20+ years of existing code, we're continuing to maintain the SpellBook/spellBook (capital B) captialization in code.
	Technically "spellbook" is one word (ie Spellbook/spellbook) but to avoid subtle confusing bugs from mixing/matching, do NOT use that casing.
]]

local Templates = {
	["HEADER"] = { template = "SpellBookHeaderTemplate", initFunc = SpellBookHeaderMixin.Init },
	["SPELL"] = { template = "SpellBookItemTemplate", initFunc = SpellBookItemMixin.Init, resetFunc = SpellBookItemMixin.Reset },
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

	self.categoryMixins = {
		CreateAndInitFromMixin(SpellBookClassCategoryMixin, self);
		CreateAndInitFromMixin(SpellBookGeneralCategoryMixin, self);
		CreateAndInitFromMixin(SpellBookPetCategoryMixin, self);
	};

	for _, categoryMixin in ipairs(self.categoryMixins) do
		categoryMixin:SetTabID(self:AddNamedTab(categoryMixin:GetName()));
	end

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

function SpellBookFrameMixin:OnPagedSpellsUpdate()
	self:CheckShowHelpTips();
	EventRegistry:TriggerEvent("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged");
end

function SpellBookFrameMixin:OnShow()
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
	elseif event == "SPELLS_CHANGED" then
		self:UpdateAllSpellData();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		local resetCurrentPage = true;
		self:UpdateAllSpellData(resetCurrentPage);
	elseif event == "LEARNED_SPELL_IN_SKILL_LINE" then
		local spellID, skillLineIndex, isGuildSpell = ...;
		self:UpdateAllSpellData();
		for _, categoryMixin in ipairs(self.categoryMixins) do
			if categoryMixin:IsAvailable() and categoryMixin:ContainsSkillLine(skillLineIndex) then
				self.CategoryTabSystem:GetTabButton(categoryMixin:GetTabID()):EnableNewSpellsGlow();
			end
		end
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

function SpellBookFrameMixin:SetupSettingsDropdown()
	local function IsSelected()
		return GetCVarBool("spellBookHidePassives");
	end

	local function SetSelected()
		SetCVar("spellBookHidePassives", not IsSelected());
		local forceUpdateSpellGroups, resetCurrentPage = true, false;
		self:UpdateDisplayedSpells(forceUpdateSpellGroups, resetCurrentPage);
	end

	local function IsEnabled()
		return not self:IsInSearchResultsMode();
	end

	self.SettingsDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_SPELL_BOOK_SETTINGS");
		local checkbox = rootDescription:CreateCheckbox(SPELLBOOK_FILTER_PASSIVES, IsSelected, SetSelected);
		checkbox:SetEnabled(IsEnabled);
		checkbox:SetTooltip(function(tooltip, elementDescription)
			if not IsEnabled() then
				GameTooltip_AddHighlightLine(tooltip, SPELLBOOK_SEARCH_HIDE_PASSIVES_DISABLED);
			end
		end);
	end);
end

function SpellBookFrameMixin:UpdateAttic()
	self.SettingsDropdown:ClearAllPoints();
	if AssistedCombatManager:HasActionSpell() then
		self.AssistedCombatRotationSpellFrame:Show();
		local actionSpelID = AssistedCombatManager:GetActionSpellID();
		self.AssistedCombatRotationSpellFrame:SetSpellID(actionSpelID);
		self.SettingsDropdown:SetPoint("TOP", 0, -17);
		self.SettingsDropdown:SetPoint("RIGHT", self.AssistedCombatRotationSpellFrame, "LEFT", -11, 0);
	else
		self.AssistedCombatRotationSpellFrame:Hide();
		self.SettingsDropdown:SetPoint("TOPRIGHT", -30, -17);
	end
	self:ResizeSearchBox();
end

function SpellBookFrameMixin:SetTab(tabID)
	TabSystemOwnerMixin.SetTab(self, tabID);

	self:OnActiveCategoryChanged();
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
	self.isUpdatingAllSpellData = true;
	local activeTabID = self:GetTab();

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
	return GenerateClosure(self.ShouldDisplaySpellBookItem, self, isKioskEnabled, isHidingPassives);
end

function SpellBookFrameMixin:IsHidingPassives()
	return not self:IsInSearchResultsMode() and GetCVarBool("spellBookHidePassives");
end

function SpellBookFrameMixin:ShouldDisplaySpellBookItem(isKioskEnabled, isHidingPassives, slotIndex, spellBank)
	if isKioskEnabled then
		-- If in Kiosk mode, filter out any future spells
		local spellBookItemType = C_SpellBook.GetSpellBookItemType(slotIndex, self.spellBank);
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
	if button == "RightButton" then
		self.showRotationSpells = not self.showRotationSpells;
		self:ShowTooltip();
	end
end

function AssistedCombatRotationSpellFrameMixin:UpdateTooltip()
	-- nop because this one runs every TOOLTIP_UPDATE_TIME but
	-- our tooltip isn't a spell so constant updates aren't needed
end

function AssistedCombatRotationSpellFrameMixin:ShowTooltip()
	local instructionText = ASSISTED_COMBAT_ROTATION_SPELLS_LIST_SHOW;
	local tooltip = GameTooltip;
	GameTooltip_SetTitle(tooltip, ASSISTED_COMBAT_ROTATION, HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddNormalLine(tooltip, AssistedCombatManager:GetActionSpellDescription());
	GameTooltip_AddBlankLineToTooltip(tooltip);

	if self.showRotationSpells then
		instructionText = ASSISTED_COMBAT_ROTATION_SPELLS_LIST_HIDE;

		local spellInfos = { };
		-- there are spells with different IDs but same name, like the shaman Earthquake talent choice node
		local function TryInsertSpell(spellID)
			local newInfo = C_Spell.GetSpellInfo(spellID);
			newInfo.isKnown = IsPlayerSpell(spellID);
			for i, spellInfo in ipairs(spellInfos) do
				if newInfo.name == spellInfo.name then
					-- on a name match, prefer the known one
					if newInfo.isKnown == spellInfo.isKnown or not newInfo.isKnown then
						return;
					end
					table.remove(spellInfos, i);
					break;
				end
			end
			table.insert(spellInfos, newInfo);
		end

		local rotationSpells = C_AssistedCombat.GetRotationSpells();
		for i, spellID in ipairs(rotationSpells) do
			spellID = C_Spell.GetOverrideSpell(spellID);
			TryInsertSpell(spellID);
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
			if spellInfo.isKnown then
				GameTooltip_AddHighlightLine(tooltip, spellInfo.name);
				textureSettings.desaturation = 0;
			else
				GameTooltip_AddDisabledLine(tooltip, spellInfo.name);
				textureSettings.desaturation = 1;
			end
			if i == #spellInfos then
				textureSettings.margin.bottom = 0;
			end
			tooltip:AddTexture(spellInfo.originalIconID, textureSettings);
		end

		GameTooltip_AddBlankLineToTooltip(tooltip);
	end

	if not C_ActionBar.HasAssistedCombatActionButtons() then
		GameTooltip_AddColoredLine(tooltip, SPELLBOOK_SPELL_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR);
	end

	GameTooltip_AddDisabledLine(tooltip, instructionText);

	tooltip:Show();
end
