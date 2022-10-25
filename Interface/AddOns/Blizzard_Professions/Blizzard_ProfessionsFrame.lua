
local ProfessionsFrameEvents =
{
	"TRADE_SKILL_NAME_UPDATE",
	"TRADE_SKILL_LIST_UPDATE",
	"TRADE_SKILL_CLOSE",
	"GARRISON_TRADESKILL_NPC_CLOSED",
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

	self:InitializeButtons();

	self:RegisterEvent("OPEN_RECIPE_RESPONSE");

	EventRegistry:RegisterCallback("Professions.SelectSkillLine", function(_, info) self:SetProfessionInfo(info); end, self);
end

function ProfessionsMixin:OnEvent(event, ...)
	local function ProcessOpenRecipeResponse(openRecipeResponse)
		C_TradeSkillUI.SetProfessionChildSkillLineID(openRecipeResponse.skillLineID);
		local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
		professionInfo.openRecipeID = openRecipeResponse.recipeID;
		professionInfo.openSpecTab = openRecipeResponse.openSpecTab;
		self:Refresh();
		return professionInfo;
	end

	if event == "TRADE_SKILL_NAME_UPDATE" then
		-- Intended to refresh title.
		self:Refresh();
	elseif event == "TRADE_SKILL_LIST_UPDATE" then
		local professionInfo;

		local openRecipeResponse = self.openRecipeResponse;
		if openRecipeResponse then
			self.openRecipeResponse = nil;
			professionInfo = ProcessOpenRecipeResponse(openRecipeResponse);

			ShowUIPanel(self);
			local forcedOpen = true;
			self:SetTab(professionInfo.openSpecTab and self.specializationsTabID or self.recipesTabID, forcedOpen);
		else
			professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
		end

		self:SetProfessionInfo(professionInfo);
	elseif event == "TRADE_SKILL_CLOSE" or event == "GARRISON_TRADESKILL_NPC_CLOSED" then
		HideUIPanel(self);
	elseif event == "OPEN_RECIPE_RESPONSE" then
		local recipeID, professionSkillLineID, expansionSkillLineID = ...;
		local openRecipeResponse = {skillLineID = expansionSkillLineID, recipeID = recipeID};
		local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
		if expansionSkillLineID == professionInfo.professionID then
			-- We're in the same expansion profession so the recipe should exist in the list.
			professionInfo.openRecipeID = openRecipeResponse.recipeID;
			self.CraftingPage:Init(professionInfo);
		elseif professionSkillLineID == professionInfo.parentProfessionID then
			-- We're in a different expansion in the same profession. We need to regenerate
			-- the recipe list, so treat this as if the profession info is changing (consistent
			-- with a change when the dropdown is changed).
			local newProfessionInfo = ProcessOpenRecipeResponse(openRecipeResponse);
			self:SetProfessionInfo(newProfessionInfo);
		else
			-- We're in a different profession entirely. Defer handling the response until the
			-- next TRADE_SKILL_LIST_UPDATE.
			self.openRecipeResponse = openRecipeResponse;
		end
	end
end

function ProfessionsMixin:SetOpenRecipeResponse(skillLineID, recipeID, openSpecTab)
	self.openRecipeResponse = {skillLineID = skillLineID, recipeID = recipeID, openSpecTab = openSpecTab};
end

function ProfessionsMixin:SetProfessionInfo(professionInfo)
	C_TradeSkillUI.SetProfessionChildSkillLineID(professionInfo.professionID);

	EventRegistry:TriggerEvent("Professions.ProfessionSelected", professionInfo);

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
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();

	-- Child profession info will be unavailable in some NPC crafting contexts. In these cases,
	-- use the base profession info instead.
	if professionInfo.professionID == 0 then
		professionInfo = C_TradeSkillUI.GetBaseProfessionInfo();
	end
	professionInfo.displayName = professionInfo.parentProfessionName and professionInfo.parentProfessionName or professionInfo.professionName;

	return professionInfo;
end

function ProfessionsMixin:SetProfessionType(professionType)
	self.professionType = professionType;
end

function ProfessionsMixin:Refresh()
	local professionInfo = self:GetProfessionInfo();

	self:SetTitle(professionInfo.professionName or professionInfo.parentProfessionName);
	self:SetPortraitToAsset(C_TradeSkillUI.GetTradeSkillTexture(professionInfo.professionID));
	self:SetProfessionType(Professions.GetProfessionType(professionInfo));

	for _, page in ipairs(self.Pages) do
		page:Refresh(professionInfo);
	end

	self:UpdateTabs();
end


local recipeTabName =
{
	[Professions.ProfessionType.Crafting] = PROFESSIONS_RECIPES_TAB_NAME,
	[Professions.ProfessionType.Gathering] = PROFESSIONS_JOURNAL_TAB_NAME,
};
function ProfessionsMixin:UpdateTabs()
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
		forceAwayFromSpec = not specTabInfo.enabled;
	end
	self.TabSystem:Layout();

	local selectedTab = self:GetTab();
	if not selectedTab or onlyShowRecipes or (selectedTab == self.specializationsTabID and forceAwayFromSpec) then
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

local unspentPointsHelpTipInfo =
{
	text = PROFESSIONS_SPECS_PENDING_POINTS,
	buttonStyle = HelpTip.ButtonStyle.Close,
	targetPoint = HelpTip.Point.BottomEdgeCenter,
	system = helptipSystemName,
	autoHorizontalSlide = true,
	onAcknowledgeCallback = function() ProfessionsFrame.pendingPointsHelptipAcknowledged = true; end,
};

function ProfessionsMixin:SetTab(tabID, forcedOpen)
	local isSpecTab = (tabID == self.specializationsTabID);

	local hasPendingSpecChanges = self.SpecPage:HasAnyConfigChanges();
	local hasUnlockableTab = self.SpecPage:HasUnlockableTab();
	local specializationTab = self:GetTabButton(self.specializationsTabID);
	local specTabInfo = C_ProfSpecs.GetSpecTabInfo();
	local specTabEnabled = specTabInfo.enabled;
	specializationTab.Glow:SetShown(specTabEnabled and not isSpecTab);
	local shouldPlaySpecGlow = specTabEnabled and (not isSpecTab) and (hasPendingSpecChanges or hasUnlockableTab);
	specializationTab.GlowAnim:SetPlaying(shouldPlaySpecGlow);

	StaticPopup_Hide("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE");

	local tabAlreadyShown = tabID == self:GetTab();

	HelpTip:HideAllSystem(helptipSystemName);
	if (hasUnlockableTab or hasPendingSpecChanges) and specTabEnabled then
		local shouldShowUnlockHelptip = hasUnlockableTab and not self.unlockSpecHelptipAcknowledged;
		local shouldShowPendingHelptip = hasPendingSpecChanges and not self.pendingPointsHelptipAcknowledged and not shouldShowUnlockHelptip;
		if isSpecTab then
			if shouldShowUnlockHelptip and not forcedOpen and not tabAlreadyShown then
				self.unlockSpecHelptipAcknowledged = true;
			elseif shouldShowPendingHelptip and not forcedOpen and not tabAlreadyShown then
				self.pendingPointsHelptipAcknowledged = true;
			end
		else
			local helpTipInfo;
			if shouldShowUnlockHelptip then
				helpTipInfo = unlockableSpecHelpTipInfo;
			elseif shouldShowPendingHelptip then
				helpTipInfo = unspentPointsHelpTipInfo;
			end
			if helpTipInfo then
				HelpTip:Show(self, helpTipInfo, specializationTab);
			end
		end
	end

	local selectedPage = self:GetElementsForTab(tabID)[1];
	local pageWidth = selectedPage:GetDesiredPageWidth();
	if tabAlreadyShown and pageWidth == self:GetWidth() then
		return;
	end

	if isSpecTab and not C_ProfSpecs.SkillLineHasSpecialization(self:GetProfessionInfo().professionID) then
		C_TradeSkillUI.SetProfessionChildSkillLineID(C_ProfSpecs.GetDefaultSpecSkillLine());
		local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
		self:SetProfessionInfo(professionInfo);
		self:Refresh();
	end
	TabSystemOwnerMixin.SetTab(self, tabID);
	self:SetWidth(pageWidth);
	UpdateUIPanelPositions(self);
    EventRegistry:TriggerEvent("ProfessionsFrame.TabSet", ProfessionsFrame, tabID);
end

function ProfessionsMixin:OnShow()
	EventRegistry:TriggerEvent("ItemButton.UpdateCraftedProfessionQualityShown");
	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN);
end

function ProfessionsMixin:OnHide()
	EventRegistry:TriggerEvent("ItemButton.UpdateCraftedProfessionQualityShown");
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Professions);
	StaticPopup_Hide("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE");

	C_Garrison.CloseGarrisonTradeskillNPC();
	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE);
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