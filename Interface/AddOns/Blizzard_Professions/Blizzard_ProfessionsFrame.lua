
local ProfessionsFrameEvents =
{
	"TRADE_SKILL_NAME_UPDATE",
	"TRADE_SKILL_LIST_UPDATE",
	"TRADE_SKILL_CLOSE",
	"GARRISON_TRADESKILL_NPC_CLOSED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
	"SKILL_LINE_SPECS_UNLOCKED",
	"IGNORELIST_UPDATE",
};

StaticPopupDialogs["PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE"] =
{
	text = PROFESSIONS_SPECS_CONFIRM_CLOSE,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		if ProfessionsFrame.SpecPage:HasAnyConfigChanges() then
			ProfessionsFrame.SpecPage:CommitConfig();
		end
		HideUIPanel(ProfessionsFrame);
	end,
	OnCancel = function()
		HideUIPanel(ProfessionsFrame);
	end,
	hideOnEscape = 1,
};

local helptipSystemName = "Professions";


ProfessionsMixin = {};

function ProfessionsMixin:InitializeButtons()
	self.CloseButton:SetScript("OnClick", function() self:CheckConfirmClose(); end);
end

function ProfessionsMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsFrameEvents);

	TabSystemOwnerMixin.OnLoad(self);
	self:SetTabSystem(self.TabSystem);

	self.recipesTabID = self:AddNamedTab(PROFESSIONS_RECIPES_TAB_NAME, self.CraftingPage);
	self.specializationsTabID = self:AddNamedTab(PROFESSIONS_SPECIALIZATIONS_TAB_NAME, self.SpecPage);
	self.craftingOrdersTabID = self:AddNamedTab(PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, self.OrdersPage);

	self:InitializeButtons();

	self:RegisterEvent("OPEN_RECIPE_RESPONSE");

	EventRegistry:RegisterCallback("Professions.SelectSkillLine", function(_, info) 
		local useLastSkillLine = false;
		self:SetProfessionInfo(info, useLastSkillLine);
	 end, self);
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
	end
end

function ProfessionsMixin:SetOpenRecipeResponse(skillLineID, recipeID, openSpecTab)
	self.openRecipeResponse = {skillLineID = skillLineID, recipeID = recipeID, openSpecTab = openSpecTab};
end

function ProfessionsMixin:SetProfessionInfo(professionInfo, useLastSkillLine)
	local professionIDChanged = (not self.professionInfo) or (self.professionInfo.professionID ~= professionInfo.professionID);
	if professionIDChanged then
		local professionChanged = (not self.professionInfo) or (self.professionInfo.profession ~= professionInfo.profession);
		local useNewSkillLine = professionChanged or not useLastSkillLine;
		if not useNewSkillLine then
			return;
		end
		C_TradeSkillUI.SetProfessionChildSkillLineID(useNewSkillLine and professionInfo.professionID or self.professionInfo.professionID);
	end

	-- Always updating the profession info so we're not displaying any stale information in the refresh.
	self.professionInfo = Professions.GetProfessionInfo();

	if professionIDChanged then
		EventRegistry:TriggerEvent("Professions.ProfessionSelected", self.professionInfo);
	end

	self:Refresh();
end

function ProfessionsMixin:SetTitle(skillLineName)
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
	if not self.professionInfo or not self:IsVisible() then
		return;
	end

	local onlyShowRecipes = not Professions.InLocalCraftingMode() or C_TradeSkillUI.IsRuneforging();
	for _, tabID in ipairs(self:GetTabSet()) do
		self.TabSystem:SetTabShown(tabID, not onlyShowRecipes);
	end

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
		local specCurrencyInfo = C_ProfSpecs.GetCurrencyInfoForSkillLine(C_ProfSpecs.GetDefaultSpecSkillLine());
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
		self.TabSystem:SetTabEnabled(self.craftingOrdersTabID, self.isCraftingOrdersTabEnabled, self.isCraftingOrdersTabEnabled and "" or PROFESSIONS_ORDERS_MUST_BE_NEAR_TABLE);
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

function ProfessionsMixin:SetTab(tabID, forcedOpen)
	if self.changingTabs then
		return;
	end
	self.changingTabs = true;

	local isSpecTab = (tabID == self.specializationsTabID);
	local isCraftingOrderTab = (tabID == self.craftingOrdersTabID);
	local isRecipesTab = (tabID == self.recipesTabID);

	local previousTab = self:GetTab();

	local hasPendingSpecChanges = self.SpecPage:HasAnyConfigChanges();
	local hasUnlockableTab = self.SpecPage:HasUnlockableTab();
	local specializationTab = self:GetTabButton(self.specializationsTabID);
	local specTabInfo = C_ProfSpecs.GetSpecTabInfo();
	local specTabEnabled = specTabInfo.enabled;

	StaticPopup_Hide("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE");

	local tabAlreadyShown = (tabID == previousTab);

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
				HelpTip:Show(self, helpTipInfo, specializationTab);
			end
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
		Professions.ApplyfilterSet(self.craftingOrdersFilters);
	elseif isRecipesTab then
		Professions.ApplyfilterSet(self.recipesFilters);
	end

	local overrideSkillLine;
	if isSpecTab and not C_ProfSpecs.SkillLineHasSpecialization(self:GetProfessionInfo().professionID) then
		overrideSkillLine = C_ProfSpecs.GetDefaultSpecSkillLine();
	elseif isCraftingOrderTab and not C_CraftingOrders.SkillLineHasOrders(self:GetProfessionInfo().professionID) then
		overrideSkillLine = C_CraftingOrders.GetDefaultOrdersSkillLine();
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
	EventRegistry:TriggerEvent("ProfessionsFrame.Show");
	EventRegistry:TriggerEvent("ItemButton.UpdateCraftedProfessionQualityShown");
	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN);

	MicroButtonPulseStop(SpellbookMicroButton);
	MainMenuMicroButton_HideAlert(SpellbookMicroButton);
	SpellbookMicroButton.suggestedTabButton = nil;
end

function ProfessionsMixin:OnHide()
	EventRegistry:TriggerEvent("ProfessionsFrame.Hide");
	EventRegistry:TriggerEvent("ItemButton.UpdateCraftedProfessionQualityShown");
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Professions);
	StaticPopup_Hide("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE");

	C_Garrison.CloseGarrisonTradeskillNPC();
	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE);

	C_TradeSkillUI.CloseTradeSkill();
	C_CraftingOrders.CloseCrafterCraftingOrders();
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
	if self:GetTab() == self.specializationsTabID and C_Traits.ConfigHasStagedChanges(self.SpecPage:GetConfigID()) then
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