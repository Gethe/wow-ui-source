
local ProfessionsFrameEvents = 
{
	"TRADE_SKILL_NAME_UPDATE",
	"TRADE_SKILL_DATA_SOURCE_CHANGED",
	"TRADE_SKILL_LIST_UPDATE",
	"TRADE_SKILL_CLOSE",
};

StaticPopupDialogs["PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE"] = 
{
	text = PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE,
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function()
		if ProfessionsFrame.SpecPage:HasAnyConfigChanges() then
			ProfessionsFrame.SpecPage:RollbackConfig();
		end
		HideUIPanel(ProfessionsFrame);
	end,
	hideOnEscape = 1,
};

ProfessionsMixin = {};

function ProfessionsMixin:InitializeButtons()
	self.CloseButton:SetScript("OnClick", function() self:CheckConfirmClose(); end);
end

function ProfessionsMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsFrameEvents);

	TabSystemOwnerMixin.OnLoad(self);
	self:SetTabSystem(self.TabSystem);

	self.recipesTabID = self:AddNamedTab("Recipes", self.CraftingPage);
	self.specializationsTabID = self:AddNamedTab("Specializations", self.SpecPage);

	self:InitializeButtons();

	self:RegisterEvent("OPEN_RECIPE_RESPONSE");

	EventRegistry:RegisterCallback("Professions.SelectSkillLine", function(_, info) self:SetProfessionInfo(info); end, self);
end

function ProfessionsMixin:OnEvent(event, ...)
	local function ProcessOpenRecipeResponse(openRecipeResponse)
		C_TradeSkillUI.SetProfessionChildSkillLineID(openRecipeResponse.skillLineID);
		local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
		professionInfo.openRecipeID = openRecipeResponse.recipeID;
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
			self:SetTab(self.recipesTabID);
		else
			professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
		end
		
		self:SetProfessionInfo(professionInfo);
	elseif event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
	elseif event == "TRADE_SKILL_CLOSE" or event == "GARRISON_TRADESKILL_NPC_CLOSED" then
		HideUIPanel(self);
	elseif event == "OPEN_RECIPE_RESPONSE" then
		local recipeID, professionSkillLineID, expansionSkillLineID = ...;
		local openRecipeResponse = {skillLineID = expansionSkillLineID, recipeID = recipeID};
		local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
		if expansionSkillLineID == professionInfo.professionID then
			-- We're in the same expansion profession so the recipe should exist in the list.
			professionInfo.openRecipeID = openRecipeResponse.recipeID;
			EventRegistry:TriggerEvent("Professions.ProfessionUpdated", professionInfo);
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

function ProfessionsMixin:SetOpenRecipeResponse(skillLineID, recipeID)
	self.openRecipeResponse = {skillLineID = skillLineID, recipeID = recipeID};
end

function ProfessionsMixin:SetProfessionInfo(professionInfo)
	C_TradeSkillUI.SetProfessionChildSkillLineID(professionInfo.professionID);

	EventRegistry:TriggerEvent("Professions.ProfessionSelected", professionInfo);

	local forceTabChange = true;
	self:Refresh(forceTabChange);
end

function ProfessionsMixin:SetTitle(skillLineName)
	if C_TradeSkillUI.IsTradeSkillGuild() then
		self:SetTitleFormatted(GUILD_TRADE_SKILL_TITLE, skillLineName);
	else
		local linked, linkedName = C_TradeSkillUI.IsTradeSkillLinked();
		if linked and linkedName then
			self:SetTitleFormatted("%s %s[%s]|r", TRADE_SKILL_TITLE:format(skillLineName), HIGHLIGHT_FONT_COLOR_CODE, linkedName);
		else
			self.TitleText:SetFormattedText(TRADE_SKILL_TITLE, skillLineName);
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

function ProfessionsMixin:Refresh(forceTabChange)
	local professionInfo = self:GetProfessionInfo();

	self:SetTitle(professionInfo.displayName);
	self:SetPortraitToAsset(C_TradeSkillUI.GetTradeSkillTexture(professionInfo.professionID));

	self:UpdateTabs(forceTabChange);

	for _, page in ipairs(self.Pages) do
		page:Refresh(professionInfo);
	end
end

function ProfessionsMixin:UpdateTabs(forceTabChange)
	local onlyShowRecipes = not Professions.InLocalCraftingMode() or C_TradeSkillUI.IsRuneforging();
	for _, tabID in ipairs(self:GetTabSet()) do
		self.TabSystem:SetTabShown(tabID, not onlyShowRecipes);
	end

	local shouldShowSpec = Professions.InLocalCraftingMode() and C_ProfSpecs.ShouldShowSpecTab();

	local forceAwayFromSpec = not shouldShowSpec;
	if not shouldShowSpec then
		self.TabSystem:SetTabShown(self.specializationsTabID, false);
	else
		local specTabInfo = C_ProfSpecs.GetSpecTabInfo();
		self.TabSystem:SetTabEnabled(self.specializationsTabID, specTabInfo.enabled, specTabInfo.errorReason);
		forceAwayFromSpec = not specTabInfo.enabled;
	end

	local selectedTab = self:GetTab();
	if not selectedTab or onlyShowRecipes or (selectedTab == self.specializationsTabID and forceAwayFromSpec) then
		selectedTab = self.recipesTabID;
	end
	self:SetTab(selectedTab, forceTabChange);
end

function ProfessionsMixin:SetTab(tabID, forceChange)
	if tabID == self:GetTab() then
		return;
	end

	local isSpecTab = (tabID == self.specializationsTabID);

	if isSpecTab and not C_ProfSpecs.SkillLineHasSpecialization(self:GetProfessionInfo().professionID) then
		C_TradeSkillUI.SetProfessionChildSkillLineID(C_ProfSpecs.GetDefaultSpecSkillLine());
		local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
		self:SetProfessionInfo(professionInfo);
		self:Refresh();
	end
	TabSystemOwnerMixin.SetTab(self, tabID);
	local selectedPage = self:GetElementsForTab(tabID)[1];
	self:SetWidth(selectedPage:GetDesiredPageWidth());
end

function ProfessionsMixin:OnShow()
	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN);
end

function ProfessionsMixin:OnHide()
	C_TradeSkillUI.CloseTradeSkill();
	StaticPopup_Hide("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE");
	
	C_Garrison.CloseGarrisonTradeskillNPC();
	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE);
end

function ProfessionsMixin:CheckConfirmClose()
	if self:GetTab() == self.specializationsTabID and C_Traits.ConfigHasStagedChanges(self.SpecPage:GetConfigID()) then
		self.SpecPage:HideAllPopups();
		StaticPopup_Show("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE");
	else
		HideUIPanel(self);
	end
end