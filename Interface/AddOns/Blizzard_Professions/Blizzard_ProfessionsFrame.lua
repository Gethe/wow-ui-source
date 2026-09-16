
local ProfessionsFrameEvents =
{
	"TRADE_SKILL_NAME_UPDATE",
	"TRADE_SKILL_LIST_UPDATE",
	"TRADE_SKILL_CLOSE",
	"GARRISON_TRADESKILL_NPC_CLOSED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
	"SKILL_LINE_SPECS_UNLOCKED",
	"IGNORELIST_UPDATE",
	"TRADE_SKILL_SHOW",
	"SKILL_LINES_CHANGED"
};

StaticPopupDialogs["PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE"] =
{
	text = PROFESSIONS_SPECS_CONFIRM_CLOSE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		if ProfessionsFrame.SpecPage:HasAnyConfigChanges() then
			ProfessionsFrame.SpecPage:CommitConfig();
		end
		HideUIPanel(ProfessionsFrame);
	end,
	OnCancel = function(dialog, data)
		HideUIPanel(ProfessionsFrame);
	end,
	hideOnEscape = 1,
};

local helptipSystemName = "Professions";


ProfessionsMixin = {};

function ProfessionsMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsFrameEvents);

	if self.TabSystem then
		TabSystemOwnerMixin.OnLoad(self);
		self:SetTabSystem(self.TabSystem);

		self.recipesTabID = self:AddNamedTab(PROFESSIONS_RECIPES_TAB_NAME, self.CraftingPage);
		self.specializationsTabID = self:AddNamedTab(PROFESSIONS_SPECIALIZATIONS_TAB_NAME, self.SpecPage);
		self.craftingOrdersTabID = self:AddNamedTab(PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, self.OrdersPage);
	end

	self.CloseButton:SetScript("OnClick", GenerateClosure(self.CheckConfirmClose, self));

	if self.MaximizeMinimize then
		local function OnMaximize(frame)
			self:SetMaximized();
		end

		self.MaximizeMinimize:SetOnMaximizedCallback(OnMaximize);

		local function OnMinimize(frame)
			self:SetMinimized();
		end

		self.MaximizeMinimize:SetOnMinimizedCallback(OnMinimize);
	end

	self:RegisterEvent("OPEN_RECIPE_RESPONSE");

	EventRegistry:RegisterCallback("Professions.SelectSkillLine", function(_, info) 
		local useLastSkillLine = false;
		self:SetProfessionInfo(info, useLastSkillLine);
	 end, self);

	EventRegistry:RegisterCallback("Professions.ShowSelectedCraftingPage", function(_, info)
		if self.BookPage and self.BookPage:IsShown() then
			self.BookPage:Hide();
			self.CraftingPage:Show();
			self:RefreshRightTabs();
		end
	end, self);

	self:OverrideArt();

	self:RegisterForTransitions();
end

function ProfessionsMixin:OverrideArt()
	-- derived
end

function ProfessionsMixin:ApplyDesiredWidth()
	local selectedPage = self:GetElementsForTab(self.recipesTabID)[1];
	local pageWidth = selectedPage:GetDesiredPageWidth();

	self.currentPageWidth = pageWidth;
	self:SetWidth(self.currentPageWidth);
	UpdateUIPanelPositions(self);
end

function ProfessionsMixin:SetMaximized()
	ProfessionsUtil.SetCraftingMinimized(false);

	self.CraftingPage:SetMaximized();

	self:UpdateTabs();

	self:ApplyDesiredWidth();
end

function ProfessionsMixin:SetMinimized()
	ProfessionsUtil.SetCraftingMinimized(true);

	self.CraftingPage:SetMinimized();

	self:UpdateTabs();

	self:ApplyDesiredWidth();
end

function ProfessionsMixin:SetTabsShown(shown)
	for _, tabID in ipairs(self:GetTabSet()) do
		self.TabSystem:SetTabShown(tabID, shown);
	end
end

function ProfessionsMixin:OnEvent(event, ...)
	local function ProcessOpenRecipeResponse(openRecipeResponse)
		C_TradeSkillUI.SetProfessionChildSkillLineID(openRecipeResponse.skillLineID);
		local professionInfo = Professions.GetProfessionInfo();
		professionInfo.openRecipeID = openRecipeResponse.recipeID;
		professionInfo.openSpecTab = openRecipeResponse.openSpecTab;
		local useLastSkillLine = false;
		self:SetProfessionInfo(professionInfo, useLastSkillLine);
		return professionInfo;
	end

	if event == "TRADE_SKILL_NAME_UPDATE" then
		-- Intended to refresh title.
		self:Refresh();
	elseif event == "TRADE_SKILL_LIST_UPDATE" then
		-- Filter changes can cause trade skill list updates while we're in the process
		-- of rebuilding our list. Always yield to a subsequent update if the data source
		-- hasn't been rebuilt yet.'
		if C_TradeSkillUI.IsDataSourceChanging() then
			return;
		end

		local professionInfo;

		local openRecipeResponse = self.openRecipeResponse;
		if openRecipeResponse then
			self.openRecipeResponse = nil;
			professionInfo = ProcessOpenRecipeResponse(openRecipeResponse);

			ShowUIPanel(self);
			local forcedOpen = true;
			self:SetTab(professionInfo.openSpecTab and self.specializationsTabID or self.recipesTabID, forcedOpen);
		else
			professionInfo = Professions.GetProfessionInfo();
		end

		local useLastSkillLine = true;
		self:SetProfessionInfo(professionInfo, useLastSkillLine);
	elseif event == "TRADE_SKILL_CLOSE" or event == "GARRISON_TRADESKILL_NPC_CLOSED" then
		HideUIPanel(self);
	elseif event == "OPEN_RECIPE_RESPONSE" then
		local recipeID, professionSkillLineID, expansionSkillLineID = ...;
		local openRecipeResponse = {skillLineID = expansionSkillLineID, recipeID = recipeID};

		if C_TradeSkillUI.IsDataSourceChanging() then
			-- Defer handling the response until the next TRADE_SKILL_LIST_UPDATE otherwise
			-- it will likely just be overwritten by a default recipe selection.
			self.openRecipeResponse = openRecipeResponse;
			return;
		end

		local professionInfo = Professions.GetProfessionInfo();
		if expansionSkillLineID == professionInfo.professionID then
			-- We're in the same expansion profession so the recipe should exist in the list.
			professionInfo.openRecipeID = openRecipeResponse.recipeID;
			self.CraftingPage:Init(professionInfo);
		elseif professionSkillLineID == professionInfo.parentProfessionID then
			-- We're in a different expansion in the same profession. We need to regenerate
			-- the recipe list, so treat this as if the profession info is changing (consistent
			-- with a change when the dropdown is changed).
			local newProfessionInfo = ProcessOpenRecipeResponse(openRecipeResponse);
			local useLastSkillLine = false;
			self:SetProfessionInfo(newProfessionInfo, useLastSkillLine);
		else
			-- We're in a different profession entirely. Defer handling the response until the
			-- next TRADE_SKILL_LIST_UPDATE.
			self.openRecipeResponse = openRecipeResponse;
		end
	elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		self:UpdateTabs();
	elseif event == "SKILL_LINE_SPECS_UNLOCKED" then
		self:UpdateTabs();
	elseif event == "IGNORELIST_UPDATE" then
		C_CraftingOrders.UpdateIgnoreList();
	elseif event == "TRADE_SKILL_SHOW" then
		if self.BookPage then
			self.BookPage:Hide();
			self.CraftingPage:Show();
		end
		self:RefreshRightTabs();
	elseif event == "SKILL_LINES_CHANGED" then
		self:RefreshRightTabs();
	end
end

function ProfessionsMixin:SetOpenRecipeResponse(skillLineID, recipeID, openSpecTab)
	self.openRecipeResponse = {skillLineID = skillLineID, recipeID = recipeID, openSpecTab = openSpecTab};
end

function ProfessionsMixin:SetProfessionInfo(professionInfo, useLastSkillLine)
	local professionIDChanged = (not self.professionInfo) or (self.professionInfo.professionID ~= professionInfo.professionID);
	if professionIDChanged then
		local sourceChanged = (not self.professionInfo) or self.professionInfo.sourceCounter ~= professionInfo.sourceCounter;
		local professionChanged = (not self.professionInfo) or (self.professionInfo.profession ~= professionInfo.profession);
		local forceSkillLineChange = sourceChanged or professionChanged;
		local useNewSkillLine = forceSkillLineChange or not useLastSkillLine;
		if not useNewSkillLine then
			return;
		end
		if professionChanged then
			SearchBoxTemplate_ClearText(self.CraftingPage.RecipeList.SearchBox);
			if self.OrdersPage then
				SearchBoxTemplate_ClearText(self.OrdersPage.BrowseFrame.RecipeList.SearchBox);
			end
			Professions.SetAllSourcesFiltered(false);
			self.CraftingPage.RecipeList.FilterDropdown:ValidateResetState();
		end
		C_TradeSkillUI.SetProfessionChildSkillLineID(useNewSkillLine and professionInfo.professionID or self.professionInfo.professionID);
	end

	-- Always updating the profession info so we're not displaying any stale information in the refresh.
	self.professionInfo = Professions.GetProfessionInfo();
	self.professionInfo.openRecipeID = professionInfo.openRecipeID;
	self.professionInfo.openSpecTab = professionInfo.openSpecTab;

	if professionIDChanged then
		EventRegistry:TriggerEvent("Professions.ProfessionSelected", self.professionInfo);
	end

	self:Refresh();
end

function ProfessionsMixin:SetTitle(skillLineName)
	if self.BookPage and self.BookPage:IsShown() then
		-- Do not update to the profession specific title when we are on the BookPage.
		return;
	end

	if C_TradeSkillUI.IsTradeSkillGuild() then
		self:SetTitleFormatted(GUILD_TRADE_SKILL_TITLE, skillLineName);
	else
		local linked, linkedName = C_TradeSkillUI.IsTradeSkillLinked();
		if linked and linkedName then
			self:SetTitleFormatted("%s %s[%s]|r", TRADE_SKILL_TITLE:format(skillLineName), HIGHLIGHT_FONT_COLOR_CODE, linkedName);
		else
			self:SetTitleFormatted(TRADE_SKILL_TITLE, skillLineName);
		end
	end
end

function ProfessionsMixin:GetProfessionInfo()
	return Professions.GetProfessionInfo();
end

function ProfessionsMixin:SetProfessionType(professionType)
	self.professionType = professionType;
end

function ProfessionsMixin:Refresh()
	local professionInfo = self:GetProfessionInfo();
	if professionInfo.professionID == 0 then
		return;
	end

	self:SetTitle(self.professionInfo.professionName or self.professionInfo.parentProfessionName);
	self:SetPortraitToAsset(C_TradeSkillUI.GetTradeSkillTexture(self.professionInfo.professionID));
	self:SetProfessionType(Professions.GetProfessionType(self.professionInfo));

	for _, page in ipairs(self.Pages) do
		page:Refresh(self.professionInfo);
	end

	self:UpdateTabs();
end


local recipeTabName =
{
	[Professions.ProfessionType.Crafting] = PROFESSIONS_RECIPES_TAB_NAME,
	[Professions.ProfessionType.Gathering] = PROFESSIONS_JOURNAL_TAB_NAME,
};
function ProfessionsMixin:UpdateTabs()
	if not self.professionInfo or not self:IsVisible() or not self.TabSystem then
		return;
	end

	local onlyShowRecipes = not Professions.InLocalCraftingMode() or C_TradeSkillUI.IsRuneforging();
	self:SetTabsShown(not (onlyShowRecipes or ProfessionsUtil.IsCraftingMinimized()));

	local recipesTab = self:GetTabButton(self.recipesTabID);
	recipesTab.Text:SetText(recipeTabName[self.professionType]);

	local shouldShowSpec = Professions.InLocalCraftingMode() and C_ProfSpecs.ShouldShowSpecTab();
	local forceAwayFromSpec = not shouldShowSpec;
	if not shouldShowSpec then
		self.TabSystem:SetTabShown(self.specializationsTabID, false);
	else
		local specTabInfo = C_ProfSpecs.GetSpecTabInfo();
		self.TabSystem:SetTabEnabled(self.specializationsTabID, specTabInfo.enabled, specTabInfo.errorReason);
		local specTab = self:GetTabButton(self.specializationsTabID);
		local specSkillLine = C_ProfSpecs.GetDefaultSpecSkillLine();
		local specCurrencyInfo = specSkillLine and C_ProfSpecs.GetCurrencyInfoForSkillLine(specSkillLine);
		local currencyAvailableText = specCurrencyInfo and PROFESSIONS_CURRENCY_AVAILABLE:format(specCurrencyInfo.numAvailable, specCurrencyInfo.currencyName);
		specTab:SetTooltipText(currencyAvailableText);
		forceAwayFromSpec = not specTabInfo.enabled;
	end

	local shouldShowCraftingOrders = self.professionInfo.profession and C_CraftingOrders.ShouldShowCraftingOrderTab();
	local forceAwayFromOrders = not shouldShowCraftingOrders;
	if not shouldShowCraftingOrders then
		self.TabSystem:SetTabShown(self.craftingOrdersTabID, false);
		FrameUtil.UnregisterUpdateFunction(self);
		self.isCraftingOrdersTabEnabled = false;
	else
		self.isCraftingOrdersTabEnabled = C_TradeSkillUI.IsNearProfessionSpellFocus(self.professionInfo.profession);
		self.TabSystem:SetTabEnabled(self.craftingOrdersTabID, self.isCraftingOrdersTabEnabled, PROFESSIONS_ORDERS_MUST_BE_NEAR_TABLE);
		forceAwayFromOrders = not self.isCraftingOrdersTabEnabled;
		FrameUtil.RegisterUpdateFunction(self, .75, GenerateClosure(self.Update, self));
	end

	self.TabSystem:Layout();

	local selectedTab = self:GetTab();
	if not selectedTab or onlyShowRecipes or (selectedTab == self.specializationsTabID and forceAwayFromSpec) or (selectedTab == self.craftingOrdersTabID and forceAwayFromOrders) then
		selectedTab = self.recipesTabID;
	end
	self:SetTab(selectedTab);
end

local unlockableSpecHelpTipInfo =
{
	text = PROFESSIONS_SPECS_CAN_UNLOCK_SPEC,
	buttonStyle = HelpTip.ButtonStyle.Close,
	targetPoint = HelpTip.Point.BottomEdgeCenter,
	system = helptipSystemName,
	autoHorizontalSlide = true,
	onAcknowledgeCallback = function() ProfessionsFrame.unlockSpecHelptipAcknowledged = true; end,
};

local pendingPointsHelpTipInfo =
{
	text = PROFESSIONS_SPECS_PENDING_POINTS,
	buttonStyle = HelpTip.ButtonStyle.Close,
	targetPoint = HelpTip.Point.BottomEdgeCenter,
	system = helptipSystemName,
	autoHorizontalSlide = true,
	onAcknowledgeCallback = function() ProfessionsFrame.pendingPointsHelptipAcknowledged = true; end,
};

local unspentPointsHelpTipInfo =
{
	text = PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER,
	buttonStyle = HelpTip.ButtonStyle.Close,
	targetPoint = HelpTip.Point.BottomEdgeCenter,
	system = helptipSystemName,
	autoHorizontalSlide = true,
	onAcknowledgeCallback = function() ProfessionsFrame.unspentPointsHelptipAcknowledged = true; end,
};

local npcCraftingOrdersHelpTipInfo =
{
	text = PROFESSIONS_CRAFTING_ORDERS_NPC_HELPTIP,
	buttonStyle = HelpTip.ButtonStyle.Close,
	targetPoint = HelpTip.Point.TopEdgeCenter,
	alignment = HelpTip.Alignment.Center,
	offsetX = 0,
	cvarBitfield = "closedInfoFramesAccountWide",
	bitfieldFlag = Enum.FrameTutorialAccount.NpcCraftingOrders,
	checkCVars = true,
	system = helptipSystemName,
};

function ProfessionsMixin:SetTab(tabID, forcedOpen)
	if not self.TabSystem then
		return;
	end

	if self.changingTabs then
		return;
	end
	self.changingTabs = true;

	local isSpecTab = (tabID == self.specializationsTabID);
	local isCraftingOrderTab = (tabID == self.craftingOrdersTabID);
	local isRecipesTab = (tabID == self.recipesTabID);

	if self.MaximizeMinimize then
		self.MaximizeMinimize:SetShown(isRecipesTab);
	end

	local previousTab = self:GetTab();

	local hasPendingSpecChanges = self.SpecPage:HasAnyConfigChanges();
	local hasUnlockableTab = self.SpecPage:HasUnlockableTab();
	local specializationTab = self:GetTabButton(self.specializationsTabID);
	local specTabInfo = C_ProfSpecs.GetSpecTabInfo();
	local specTabEnabled = specTabInfo.enabled;

	StaticPopup_Hide("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE");

	local tabAlreadyShown = (tabID == previousTab);
	local specHelpTipShown = false;

	HelpTip:HideAllSystem(helptipSystemName);
	if (hasUnlockableTab or hasPendingSpecChanges) and specTabEnabled then
		local shouldShowUnlockHelptip = hasUnlockableTab and not self.unlockSpecHelptipAcknowledged;
		local shouldShowPendingHelptip = hasPendingSpecChanges and not self.pendingPointsHelptipAcknowledged and not shouldShowUnlockHelptip;
		local shouldShowUnspentPointsHelptip = (not self.unspentPointsHelpTipInfo) and (not shouldShowPendingHelptip) and (not shouldShowUnlockHelptip) and C_ProfSpecs.ShouldShowPointsReminderForSkillLine(C_ProfSpecs.GetDefaultSpecSkillLine());
		if isSpecTab then
			if shouldShowUnlockHelptip and not forcedOpen and not tabAlreadyShown then
				self.unlockSpecHelptipAcknowledged = true;
			elseif shouldShowPendingHelptip and not forcedOpen and not tabAlreadyShown then
				self.pendingPointsHelptipAcknowledged = true;
			elseif shouldShowUnspentPointsHelptip and not forcedOpen and not tabAlreadyShown then
				self.unspentPointsHelpTipInfo = true;
			end
		else
			local helpTipInfo;
			if shouldShowUnlockHelptip then
				helpTipInfo = unlockableSpecHelpTipInfo;
			elseif shouldShowPendingHelptip then
				helpTipInfo = pendingPointsHelpTipInfo;
			elseif shouldShowUnspentPointsHelptip then
				helpTipInfo = unspentPointsHelpTipInfo;
			end
			if helpTipInfo then
				HelpTip:Show(specializationTab, helpTipInfo, specializationTab);
				specHelpTipShown = true;
			end
		end
	end

	if isCraftingOrderTab then
		SetCVarBitfield("closedInfoFramesAccountWide", Enum.FrameTutorialAccount.NpcCraftingOrders, true);
	elseif not specHelpTipShown then
		local craftingOrderTab = self:GetTabButton(self.craftingOrdersTabID);
		local latestProfession = Professions.GetNewestKnownProfessionInfo();

		-- Show NPC orders helptip when player reaches skill level 15 in the newest expansion profession
		-- Only show helptip when orders tab is enabled (player is in range of crafting table)
		if latestProfession and latestProfession.skillLevel >= 15 and craftingOrderTab:IsShown() and craftingOrderTab:IsEnabled() then
			HelpTip:Show(craftingOrderTab, npcCraftingOrdersHelpTipInfo, craftingOrderTab);
		end
	end

	local selectedPage = self:GetElementsForTab(tabID)[1];
	local pageWidth = selectedPage:GetDesiredPageWidth();
	-- We can't check against self:GetWidth() because it could have rounding problems
	if tabAlreadyShown and pageWidth == self.currentPageWidth then
		self.changingTabs = false;
		return;
	end

	if previousTab == self.craftingOrdersTabID then
		self.craftingOrdersFilters = Professions.GetCurrentFilterSet();
	elseif previousTab == self.recipesTabID then
		self.recipesFilters = Professions.GetCurrentFilterSet();
	end

	if isCraftingOrderTab then
		-- When transitioning to the crafting orders page, the currently selected expansion
		-- is now copied from the recipes page instead of defaulted to the most recent expansion.
		if not self.craftingOrdersFilters then
			self.craftingOrdersFilters = Professions.GetCurrentFilterSet();
		end
		self.craftingOrdersFilters.professionInfo = self.recipesFilters.professionInfo;

		Professions.ApplyfilterSet(self.craftingOrdersFilters);
	elseif isRecipesTab then
		Professions.ApplyfilterSet(self.recipesFilters);
	end

	-- The currently selected expansion in the recipes page now governs the skill line
	-- used to generate the crafting order recipe list and patron orders.
	local overrideSkillLine;
	if isSpecTab and not C_ProfSpecs.SkillLineHasSpecialization(self:GetProfessionInfo().professionID) then
		overrideSkillLine = C_ProfSpecs.GetDefaultSpecSkillLine();
	end

	if overrideSkillLine then
		C_TradeSkillUI.SetProfessionChildSkillLineID(overrideSkillLine);
		local professionInfo = Professions.GetProfessionInfo();
		local useLastSkillLine = false;
		self:SetProfessionInfo(professionInfo, useLastSkillLine);
	end

	TabSystemOwnerMixin.SetTab(self, tabID);
	self.currentPageWidth = pageWidth;
	self:SetWidth(pageWidth);
	UpdateUIPanelPositions(self);
    EventRegistry:TriggerEvent("ProfessionsFrame.TabSet", ProfessionsFrame, tabID);
	self.changingTabs = false;
end

function ProfessionsMixin:OnShow()
	self.CraftingPage.CraftingOutputLog:Cleanup();
	EventRegistry:TriggerEvent("ProfessionsFrame.Show");
	EventRegistry:TriggerEvent("ItemButton.UpdateCraftedProfessionQualityShown");
	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN);

	MicroButtonPulseStop(ProfessionMicroButton);
	MainMenuMicroButton_HideAlert(ProfessionMicroButton);
	ProfessionMicroButton.showProfessionSpellHighlights = nil;

	self:RefreshRightTabs();

	if InputUtil.IsGamepadUIEnabled() then
		SmartNavigation:RegisterCallback("SelectedButtonUpdated", function()
			self:UpdateGamepadUnlearnIcons();
		end, self);
	end
end

function ProfessionsMixin:OnHide()
	EventRegistry:TriggerEvent("ProfessionsFrame.Hide");
	EventRegistry:TriggerEvent("ItemButton.UpdateCraftedProfessionQualityShown");
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Professions);
	StaticPopup_Hide("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE");

	C_Garrison.CloseGarrisonTradeskillNPC();
	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE);

	self.CraftingPage:Reset();

	C_TradeSkillUI.CloseTradeSkill();
	C_CraftingOrders.CloseCrafterCraftingOrders();
	C_WowSurvey.TriggerSurveyServe(Enum.SurveyDeliveryMoment.ProfessionTable);

	if InputUtil.IsGamepadUIEnabled() then
		SmartNavigation:UnregisterCallback("SelectedButtonUpdated", self);
	end
end

-- Set dynamically
function ProfessionsMixin:Update()
	if self.professionInfo and self.professionInfo.profession then
		local shouldOrdersTabBeEnabled = C_TradeSkillUI.IsNearProfessionSpellFocus(self.professionInfo.profession);
		if shouldOrdersTabBeEnabled ~= self.isCraftingOrdersTabEnabled then
			self:UpdateTabs();
		end
	end
end

function ProfessionsMixin:CheckConfirmClose()
	if self.TabSystem and self:GetTab() == self.specializationsTabID and C_Traits.ConfigHasStagedChanges(self.SpecPage:GetConfigID()) then
		if not StaticPopup_Visible("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE") then
			self.SpecPage:HideAllPopups();
			StaticPopup_Show("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE");
		end
	else
		HideUIPanel(self);
	end
end

function ProfessionsMixin:GetCurrentRecraftingRecipeID()
	return self.CraftingPage:GetCurrentRecraftingRecipeID();
end

function ProfessionsMixin:RefreshRightTabs()
	-- Stub for Mainline, overridden by specific flavors.
end

local function GetFirstInitializedSecondaryProfession(frame)
	local focusTargets =
	{
		frame.SecondaryProfession1,
		frame.SecondaryProfession2,
		frame.SecondaryProfession3,
	};

	for _, profession in ipairs(focusTargets) do
		if profession.professionInitialized then
			return profession;
		end
	end
end

local function GetJumpNavigationButton(frame)
	for i = #frame.spellButtons, 1, -1 do
		local spellButton = frame.spellButtons[i];
		if spellButton:IsShown() then
			return spellButton;
		end
	end
end

local function GetBottommostSpellButton(frame)
	for i = 1, #frame.spellButtons do
		local spellButton = frame.spellButtons[i];
		if spellButton:IsShown() then
			return spellButton;
		end
	end
end

local function GetInitialProfession(firstPrimaryProfession, firstSecondaryProfession)
	if firstPrimaryProfession.professionInitialized then
		return firstPrimaryProfession;
	end

	if firstSecondaryProfession and firstSecondaryProfession.professionInitialized then
		return firstSecondaryProfession;
	end

	return nil;
end

local function UpdateSmartNavFocus_BookPage(frame)
	local firstPrimaryProfession = frame.PrimaryProfession1;
	local firstSecondaryProfession = GetFirstInitializedSecondaryProfession(frame);

	local initialProfession = GetInitialProfession(
		firstPrimaryProfession,
		firstSecondaryProfession);

	if not initialProfession then
		return;
	end

	SmartNavigation:SelectButton(initialProfession.SpellButton1);
end

local function UpdateSmartNavJumps_BookPage(frame)
	local firstPrimaryProfession = frame.PrimaryProfession1;
	local secondPrimaryProfession = frame.PrimaryProfession2;
	local firstSecondaryProfession = frame.SecondaryProfession1;
	local secondSecondaryProfession = frame.SecondaryProfession2;
	local thirdSecondaryProfession = frame.SecondaryProfession3;

	if not thirdSecondaryProfession.professionInitialized then
		return;
	end

	local lastPrimaryProfession;
	if secondPrimaryProfession.professionInitialized then
		lastPrimaryProfession = secondPrimaryProfession;
	elseif firstPrimaryProfession.professionInitialized then
		lastPrimaryProfession = firstPrimaryProfession;
	end

	if not lastPrimaryProfession then
		return;
	end

	local sourceButton = GetJumpNavigationButton(lastPrimaryProfession);

	-- SmartNav's default navigation does not correctly resolve the rightmost secondary profession.
	--Add an explicit UP jump back to the last primary profession.
	SmartNavigation_AddJumpNavigationOverride(
		GetJumpNavigationButton(thirdSecondaryProfession),
		SMART_NAV_INPUT_DIRECTION.UP,
		sourceButton);

	-- If the rightmost secondary profession is the only one initialized, also add a DOWN jump
	if not firstSecondaryProfession.professionInitialized and not secondSecondaryProfession.professionInitialized then
		local dest = GetJumpNavigationButton(thirdSecondaryProfession);
		SmartNavigation_AddJumpNavigationOverride(
			sourceButton,
			SMART_NAV_INPUT_DIRECTION.DOWN,
			dest);
	end
end

local function ClearProfessionJumpOverrides(frame)
	-- Only these profession frames receive custom jump overrides.
	local professionFrames =
	{
		frame.PrimaryProfession1,
		frame.PrimaryProfession2,
		frame.SecondaryProfession3,
	};
	for _, professionFrame in ipairs(professionFrames) do
		for _, spellButton in ipairs(professionFrame.spellButtons) do
			SmartNavigation_ClearJumpNavigationOverrides(spellButton);
		end
	end
end

local function UpdateSmartNavFocus_RecipePage(page, elementData)
	SmartNavigation:SetScrollFrameForFrame(ProfessionsFrame, page.RecipeList.ScrollBox);

	GamepadScrollBarHint:SetOwner(page.RecipeList.ScrollBar.Track.Thumb, "CENTER");
	GamepadScrollBarHint:Show();

	if not elementData then
		return;
	end

	for _, frame in pairs(page.RecipeList.ScrollBox:GetFrames()) do
		local recipeElementData = frame.GetElementData and frame:GetElementData();
		if elementData == recipeElementData then
			SmartNavigation:SelectButton(frame);
			return;
		end
	end
end

function ProfessionsMixin:RefreshBookPageSmartNavJumps()
	local professionsFrame = self.BookPage.ProfessionsContentFrame;

	ClearProfessionJumpOverrides(professionsFrame);
	UpdateSmartNavJumps_BookPage(professionsFrame);
end

function ProfessionsMixin:UpdateGamepadUnlearnIcons()
	local focusedButton = SmartNavigation:GetCurrentButton();

	local function UpdateProfessionFrame(primaryProfessionFrame)
		local show =
			focusedButton and
			focusedButton:GetParent() == primaryProfessionFrame and
			primaryProfessionFrame.isPrimary;

		primaryProfessionFrame.GamepadUnlearnButton:SetShown(show);
	end

	UpdateProfessionFrame(self.BookPage.ProfessionsContentFrame.PrimaryProfession1);
	UpdateProfessionFrame(self.BookPage.ProfessionsContentFrame.PrimaryProfession2);
end

local function FocusChatAndInsertLink(link)
	if not link then
		return;
	end

	local activeChatFrame = FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK);
	if activeChatFrame and activeChatFrame:IsShown() then
		activeChatFrame:SetGamepadFocus();
	end

	ChatFrameUtil.InsertLink(link);
end

function ProfessionsMixin:SetUpGamepadBookPageFooter(toggleTooltips)
	local function UnlearnProfession()
		local button = SmartNavigation:GetCurrentButton();
		local primaryProfessionFrame = button:GetParent();
		primaryProfessionFrame.UnlearnButton:Click();
	end

	local function CanUnlearn()
		local button = SmartNavigation:GetCurrentButton();
		local primaryProfessionFrame = button:GetParent();

		return primaryProfessionFrame.isPrimary;
	end

	local unlearnProfession = GamepadSharedUtility.CreateTapOrHoldPromptedBinding(GAMEPAD_FACE_LEFT, 0.5, nil, UnlearnProfession, FRAME_ACTION_HOLD_TO_UNLEARN);
	unlearnProfession:AddButtonContext("ButtonContext_ProfessionsButton");
	unlearnProfession:AddCondition(CanUnlearn);
	unlearnProfession:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local function BindToActionBar()
		GamepadMode.FrameControlsManager:UnsuspendAllFrames();

		local button = SmartNavigation:GetCurrentButton();
		local slotIndex = ProfessionsBook_GetSpellBookItemSlot(button);
		GamepadActionBarEditFrame:BindSpellBookItem(slotIndex, Enum.SpellBookSpellBank.Player);
	end

	local function LinkInChat()
		GamepadMode.FrameControlsManager:UnsuspendAllFrames();
		local button = SmartNavigation:GetCurrentButton();

		local slotIndex = ProfessionsBook_GetSpellBookItemSlot(button);
		local activeSpellBank = Enum.SpellBookSpellBank.Player;

		local tradeSkillLink = C_SpellBook.GetSpellBookItemTradeSkillLink(slotIndex, activeSpellBank);
		if ( tradeSkillLink ) then
			FocusChatAndInsertLink(tradeSkillLink);
			return;
		end

		local spellLink = C_SpellBook.GetSpellBookItemLink(slotIndex, activeSpellBank);
		if ( spellLink ) then
			FocusChatAndInsertLink(spellLink);
			return;
		end
	end

	local function CanLinkInChat()
		local button = SmartNavigation:GetCurrentButton();
		return button and button:IsShown();
	end

	local moreOptions = GamepadSharedUtility.CreateMoreActionsPromptedBinding(GAMEPAD_FACE_TOP);
	moreOptions:AddButtonContext("ButtonContext_ProfessionsButton");
	moreOptions:AddMoreActionsEntry(CONTEXT_ACTION_LABEL_BIND_TO_GAMEPAD_ACTION_BAR, BindToActionBar);
	moreOptions:AddMoreActionsEntry(SOCIAL_SHARE_TEXT, LinkInChat, CanLinkInChat);

	self.bookPageFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "ProfessionsBookPageFooter");
	self.bookPageFooter:AddPromptedBinding(toggleTooltips);
	self.bookPageFooter:AddPromptedBinding(unlearnProfession);
	self.bookPageFooter:AddPromptedBinding(moreOptions);
	self.bookPageFooter:AddStandardBackPrompt();
	self.bookPageFooter:AddStandardSelectPrompt();
	self.bookPageFooter:SetAnchorOffsets(0, -5);
	self.bookPageFooter:Finalize();
end

function ProfessionsMixin:GetRecipeMoreOptions()
	local function ToggleRecipeFavoriteStatus()
		local favoriteButton = self.CraftingPage.SchematicForm.FavoriteButton;
		favoriteButton:Click();
	end

	local function CanFavoriteRecipe()
		local favoriteButton = self.CraftingPage.SchematicForm.FavoriteButton;
		return not favoriteButton:GetChecked();
	end

	local function ToggleRecipeTracking()
		local trackRecipe = self.CraftingPage.SchematicForm.TrackRecipeCheckbox;
		trackRecipe:Click();
	end

	local function CanTrackRecipe()
		local trackRecipe = self.CraftingPage.SchematicForm.TrackRecipeCheckbox;
		return not trackRecipe:GetChecked();
	end

	local function LinkRecipeInChat()
		Menu.GetManager():CloseMenus();

		local previousRecipeID = self.CraftingPage.RecipeList:GetPreviousRecipeID();
		local link = C_TradeSkillUI.GetRecipeLink(previousRecipeID);

		FocusChatAndInsertLink(link);
	end

	local function CanLinkRecipeInChat()
		return self.CraftingPage.RecipeList:GetPreviousRecipeID();
	end

	local function SelectHighlightedElement()
		local button = SmartNavigation:GetCurrentButton();

		if button then
			button:Click();
		end
	end

	local recipeMoreOptions = GamepadSharedUtility.CreateMoreActionsPromptedBinding(GAMEPAD_FACE_TOP);
	recipeMoreOptions:SetMenuOpeningCallback(SelectHighlightedElement);
	recipeMoreOptions:AddButtonContext("ButtonContext_ProfessionsRecipeButton");
	recipeMoreOptions:AddTwoStateMoreActionsEntry(ADD_FAVORITE_STATUS, REMOVE_FAVORITE_STATUS, ToggleRecipeFavoriteStatus, CanFavoriteRecipe);
	recipeMoreOptions:AddTwoStateMoreActionsEntry(PROFESSIONS_TRACK_RECIPE, PROFESSIONS_UNTRACK_RECIPE, ToggleRecipeTracking, CanTrackRecipe);
	recipeMoreOptions:AddMoreActionsEntry(SOCIAL_SHARE_TEXT, LinkRecipeInChat, CanLinkRecipeInChat);

	return recipeMoreOptions;
end

function ProfessionsMixin:GetReagentMoreOptions()
	local function LinkInChat()
		Menu.GetManager():CloseMenus();

		local button = SmartNavigation:GetCurrentButton();
		if not button then
			return;
		end

		local reagent = button.GetReagent and button:GetReagent();
		if not reagent then
			return;
		end

		local link;
		if reagent.itemID then
			link = ItemUtil.GetItemHyperlink(reagent.itemID);
		elseif reagent.currencyID then
			link = C_CurrencyInfo.GetCurrencyLink(reagent.currencyID, 1);
		end

		FocusChatAndInsertLink(link);
	end

	local function CanLinkInChat()
		local button = SmartNavigation:GetCurrentButton();
		return button and button:IsShown();
	end

	local function OpenBagTo()
		GamepadMode.FrameControlsManager:UnsuspendAllFrames();
		local button = SmartNavigation:GetCurrentButton();
		if not button then
			return;
		end

		local reagent = button.GetReagent and button:GetReagent();
		local itemID = reagent and reagent.itemID;
		if not itemID then
			return;
		end

		OpenBackpack();
		GamepadMode.FrameControlsManager:FocusFrame(ContainerFrameCombinedBags);
		ContainerFrameCombinedBags:SetFocusByItemID(itemID);
	end

	local function CanOpenBagTo()
		local button = SmartNavigation:GetCurrentButton();
		if not button then
			return;
		end

		local reagent = button.GetReagent and button:GetReagent();
		if not reagent then
			return;
		end

		return SearchBagsForFirstItem(reagent.itemID) >= 0;
	end

	local function CanSearchAuctionHouse()
		return AuctionHouseFrame and AuctionHouseFrame:IsVisible();
	end

	local function SearchAuctionHouse()
		GamepadMode.FrameControlsManager:UnsuspendAllFrames();
		local button = SmartNavigation:GetCurrentButton();
		if not button then
			return;
		end

		local reagent = button.GetReagent and button:GetReagent();
		local itemID = reagent and reagent.itemID or 0;
		local itemName = C_Item.GetItemInfo(itemID);

		if not itemName then
			return;
		end

		AuctionHouseFrame:SetSearchText(itemName);
		AuctionHouseFrame.SearchBar.SearchButton:Click();
		GamepadMode.FrameControlsManager:FocusFrame(AuctionHouseFrame);
	end
	
	local reagentMoreOptions = GamepadSharedUtility.CreateMoreActionsPromptedBinding(GAMEPAD_FACE_TOP);
	reagentMoreOptions:AddButtonContext("ButtonContext_ProfessionsReagentButton");
	reagentMoreOptions:AddMoreActionsEntry(CONTEXT_ACTION_LABEL_SEE_IN_BAG, OpenBagTo, CanOpenBagTo);
	reagentMoreOptions:AddMoreActionsSearchEntry(BUTTON_LAG_AUCTIONHOUSE, SearchAuctionHouse, CanSearchAuctionHouse);
	reagentMoreOptions:AddMoreActionsEntry(SOCIAL_SHARE_TEXT, LinkInChat, CanLinkInChat);

	return reagentMoreOptions;
end

function ProfessionsMixin:SetUpGamepadCraftingPageFooter(toggleTooltips)
	local function OpenFilter()
		local filter = self.CraftingPage.RecipeList.FilterDropdown;
		filter:MouseDown();
		filter:MouseUp();
	end

	local function FocusSearchBox()
		local searchBox = self.CraftingPage.RecipeList.SearchBox;
		if searchBox.GamepadFocusIcon:IsShown() then
			SmartNavigation:SelectButton(searchBox);
			searchBox:SetFocus();
		end
	end
	local function ShouldShowFocusSearchBox()
		local button = SmartNavigation:GetCurrentButton();
		return button ~= self.CraftingPage.RecipeList.SearchBox;
	end
	
	local function CreateAll()
		self.CraftingPage.CreateAllButton:Click();
	end

	local function Create()
		self.CraftingPage.CreateButton:Click();
	end

	local function CanCreate()
		return self.CraftingPage.CreateButton:IsEnabled();
	end

	local function SetAmount()
		local targetFrame = self.CraftingPage.GamepadCreateMultiple;
		targetFrame.SplitStack = function(button, amount)
			self.CraftingPage.CreateMultipleInputBox:SetValue(amount);
			GamepadMode.FrameControlsManager:UnsuspendFrame();
		end

		GamepadMode.FrameControlsManager:SuspendFrame();
		local maxValue = self.CraftingPage.CreateMultipleInputBox:GetMaxValue();
		StackSplitFrame:OpenStackSplitFrame(maxValue, targetFrame, "BOTTOMRIGHT", "TOPRIGHT");

		GamepadMode.FrameControlsManager:DismissOnUnfocus(StackSplitFrame);
		GamepadMode.FrameControlsManager:FrameShown(StackSplitFrame);

		self.CraftingPage:Update();
	end

	local function CanSetAmount()
		return self.CraftingPage.CreateMultipleInputBox:IsEnabled();
	end

	-- Filter
	local filterDropdown = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_RIGHT, OpenFilter, nil);
	filterDropdown:SetCustomPromptFrame(self.CraftingPage.RecipeList.FilterDropdown.GamepadFocusIcon);

	-- Search
	local focusSearchBox = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, FocusSearchBox, nil);
	focusSearchBox:SetCustomPromptFrame(self.CraftingPage.RecipeList.SearchBox.GamepadFocusIcon);
	focusSearchBox:AddCondition(ShouldShowFocusSearchBox);
	focusSearchBox:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	-- Create / Create All
	local create = GamepadSharedUtility.CreateTapOrHoldPromptedBinding(GAMEPAD_FACE_LEFT, 0.5, Create, CreateAll, CONTEXT_ACTION_LABEL_CREATE_ALL);
	create:AddCondition(CanCreate);
	self.gamepadCreateAllIcon = GamepadMode.AddGamepadIconToButton(self.CraftingPage.CreateAllButton, GAMEPAD_FACE_LEFT, { buttonHeightScale = (1.0), });
	GamepadMode.SetGamepadIconShown(self.gamepadCreateAllIcon, true);
	self.gamepadCreateIcon = GamepadMode.AddGamepadIconToButton(self.CraftingPage.CreateButton, GAMEPAD_FACE_LEFT, { buttonHeightScale = (1.0),  });
	GamepadMode.SetGamepadIconShown(self.gamepadCreateIcon, true);

	-- Adjust Create Amount
	self.adjustAmount = GamepadMode.CreateBindingGroup("ProfessionsCreateMultiple");
	self.adjustAmount:AddFunctionBinding(GAMEPAD_STICK_RIGHT_PRESS, SetAmount);

	-- 'More' Menus
	local recipeMoreOptions = self:GetRecipeMoreOptions();
	local reagentMoreOptions = self:GetReagentMoreOptions();

	self.craftingPageFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "ProfessionsCraftingPageFooter");
	self.craftingPageFooter:AddPromptedBinding(toggleTooltips);
	self.craftingPageFooter:AddPromptedBinding(filterDropdown);
	self.craftingPageFooter:AddPromptedBinding(focusSearchBox);
	self.craftingPageFooter:AddPromptedBinding(create);
	self.craftingPageFooter:AddPromptedBinding(recipeMoreOptions);
	self.craftingPageFooter:AddPromptedBinding(reagentMoreOptions);
	self.craftingPageFooter:AddStandardFrameControlManagerBindings(self);
	self.craftingPageFooter:AddStandardBackPrompt();
	self.craftingPageFooter:AddStandardSelectPrompt();
	self.craftingPageFooter:SetAnchorOffsets(0, -5);
	self.craftingPageFooter:Finalize();
end

function ProfessionsMixin:SetUpGamepad()
	local toggleTooltips = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_LEFT_PRESS, nil, PROMPT_TOGGLE_TOOLTIPS);

	self:SetUpGamepadBookPageFooter(toggleTooltips);
	self:SetUpGamepadCraftingPageFooter(toggleTooltips);

	EventRegistry:RegisterCallback(
		"SKILL_LINES_CHANGED",
		self.RefreshBookPageSmartNavJumps,
	self);

	EventRegistry:RegisterCallback(
		"Professions.RecipeSelected",
		function(_, page, recipeInfo)
			UpdateSmartNavFocus_RecipePage(page, recipeInfo);
		end,
	self);

	EventRegistry:RegisterCallback(
		"Professions.CraftingDisplayRefresh",
		function()
			GamepadMode.UpdateGamepadIconAnchor(self.gamepadCreateIcon);
			GamepadMode.UpdateGamepadIconAnchor(self.gamepadCreateAllIcon);
		end,
	self);
end

function ProfessionsMixin:InitializeGamepad()
	self.CloseButton:Hide();

	local professionFrame1 = self.BookPage.ProfessionsContentFrame.PrimaryProfession1;
	professionFrame1.StatusBar.overrideWidth = 400;
	professionFrame1.StatusBar:OnLoad();
	professionFrame1.StatusBar:SetPoint("RIGHT", professionFrame1, "RIGHT", -80, 0);
	professionFrame1.UnlearnButton:ClearAllPoints();
	professionFrame1.UnlearnButton:SetPoint("LEFT", professionFrame1.StatusBar, "RIGHT", 15, -4);

	local professionFrame2 = self.BookPage.ProfessionsContentFrame.PrimaryProfession2;
	professionFrame2.StatusBar.overrideWidth = 400;
	professionFrame2.StatusBar:OnLoad();
	professionFrame2.StatusBar:SetPoint("RIGHT", professionFrame2, "RIGHT", -80, 0);
	professionFrame2.UnlearnButton:ClearAllPoints();
	professionFrame2.UnlearnButton:SetPoint("LEFT", professionFrame2.StatusBar, "RIGHT", 15, -4);

	self.CraftingPage.RecipeList.SearchBox:ClearAllPoints();
	self.CraftingPage.RecipeList.SearchBox:SetPoint("TOPLEFT", self.CraftingPage.RecipeList, "TOPLEFT", 42, -8);
	self.CraftingPage.RecipeList.SearchBox:SetPoint("RIGHT", self.CraftingPage.RecipeList.FilterDropdown.GamepadFocusIcon, "LEFT", -2, 0);
	self.CraftingPage.CreateAllButton:SetWidth(130);
	self.CraftingPage.CreateButton:SetWidth(130);
	self.CraftingPage.CreateAllButton.smartNavigationIgnored = true;
	self.CraftingPage.CreateButton.smartNavigationIgnored = true;
	self.CraftingPage.GamepadCreateMultiple.ControlDescText.FontString:SetWidth(60);
	self.CraftingPage.GamepadCreateMultiple.ControlDescText.FontString:SetMaxLines(2);
	self.CraftingPage.LinkButton:Hide();

	local tabs = { self.ProfessionsOverviewTab };
	for _, tab in ipairs(self.rightProfessionTabs) do
		table.insert(tabs, tab);
	end

	self.TabIndicators:SetUpTabs(tabs);
end

function ProfessionsMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetUpGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
end

function ProfessionsMixin:FocusGamepad()
	self.TabIndicators:Show();

	if self.selectedGamepadTabID then
		self.TabIndicators:SetCurrentIndex(self.selectedGamepadTabID);
		self.TabIndicators:UpdateTabIndicators();
	end

	self:UpdateSmartNavFocus();
end

function ProfessionsMixin:UnfocusGamepad()
	self.bookPageFooter:HideAndDeactivateBindings();
	self.craftingPageFooter:HideAndDeactivateBindings();
	GamepadMode.DeactivateBindingGroup(self.adjustAmount);

	self.TabIndicators:Hide();
end

function ProfessionsMixin:UpdateSmartNavFocus()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	if self.BookPage:IsShown() then
		self.craftingPageFooter:HideAndDeactivateBindings();
		self.bookPageFooter:ShowAndActivateBindings();
		UpdateSmartNavFocus_BookPage(self.BookPage.ProfessionsContentFrame);
	elseif self.CraftingPage:IsShown() then
		self.bookPageFooter:HideAndDeactivateBindings();
		self.craftingPageFooter:ShowAndActivateBindings();
		GamepadMode.ActivateBindingGroup(self.adjustAmount, true);
		UpdateSmartNavFocus_RecipePage(self.CraftingPage);
	end
end
