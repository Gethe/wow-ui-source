local HubPage = 1;
local RecipesPage = 2;

local ProfessionsFrameEvents = {
	"TRADE_SKILL_NAME_UPDATE",
	"TRADE_SKILL_DATA_SOURCE_CHANGED",
	"TRADE_SKILL_LIST_UPDATE",
	"TRADE_SKILL_CLOSE",
};

ProfessionsMixin = {};

function ProfessionsMixin:InitializeButtons()
    local function OnTabClicked(button, buttonName, down)
		self:SelectPage(button.page);
	end
	self.tabsMap = {};
	for index, button in ipairs(self.Tabs) do
		button:SetScript("OnClick", OnTabClicked);
		self.tabsMap[button.page] = button;
	end

	self.LinkButton:SetScript("OnClick", function()
		if MacroFrameText and MacroFrameText:IsShown() and MacroFrameText:HasFocus() then
			local link = C_TradeSkillUI.GetTradeSkillListLink();
			if strlenutf8(MacroFrameText:GetText()) + strlenutf8(link) <= MacroFrameText:GetMaxLetters() then
				MacroFrameText:Insert(link);
			end
		else
			if ChatEdit_GetActiveWindow() then
				local link = C_TradeSkillUI.GetTradeSkillListLink();
				ChatEdit_InsertLink(link);
			else
				ToggleDropDownMenu(1, nil, self.LinkDropDown, self.LinkButton, 25, 25);
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			end
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end);
end

function ProfessionsMixin:InitLinkDropdown()
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.text = TRADESKILL_POST;
	info.isTitle = true;
	UIDropDownMenu_AddButton(info);

	info.isTitle = nil;
	info.notCheckable = true;
	info.func = function(_, channel)
		local link = C_TradeSkillUI.GetTradeSkillListLink();
		if link then
			ChatFrame_OpenChat(channel.." "..link, DEFAULT_CHAT_FRAME);
		end
	end;

	info.text = GUILD;
	info.arg1 = SLASH_GUILD1;
	info.disabled = not IsInGuild();
	UIDropDownMenu_AddButton(info);

	info.text = PARTY;
	info.arg1 = SLASH_PARTY1;
	info.disabled = (GetNumSubgroupMembers() == 0);
	UIDropDownMenu_AddButton(info);

	info.text = RAID;
	info.disabled = not IsInRaid();
	info.arg1 = SLASH_RAID1;
	UIDropDownMenu_AddButton(info);

	info.disabled = false

	local channels = { GetChannelList() };
	for i = 1, #channels, 3 do
		info.text = ChatFrame_ResolveChannelName(channels[i + 1]);
		info.arg1 = "/"..channels[i];
		info.disabled = channels[i + 2];
		UIDropDownMenu_AddButton(info);
	end
end

function ProfessionsMixin:OnLoad()
	self:InitializeButtons();

	UIDropDownMenu_Initialize(self.LinkDropDown, GenerateClosure(self.InitLinkDropdown, self), "MENU");

	self.RecipesTab:SetText(PROFESSIONS_RECIPES_TAB);

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
			self:SelectPage(self.Pages[RecipesPage].page);
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
			self.TitleText:SetFormattedText(TRADE_SKILL_TITLE, skillLineName);
		end
	end
end

function ProfessionsMixin:Refresh()
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();

	-- Child profession info will be unavailable in some NPC crafting contexts. In these cases,
	-- use the base profession info instead.
	if professionInfo.professionID == 0 then
		professionInfo = C_TradeSkillUI.GetBaseProfessionInfo();
	end
	professionInfo.displayName = professionInfo.parentProfessionName and professionInfo.parentProfessionName or professionInfo.professionName;

	self:SetTitle(professionInfo.displayName);
	self.HubTab:SetName(professionInfo.displayName);
	self:SetPortraitToAsset(C_TradeSkillUI.GetTradeSkillTexture(professionInfo.professionID));
	self.LinkButton:SetShown(C_TradeSkillUI.CanTradeSkillListLink());

	for _, page in ipairs(self.Pages) do
		page:Refresh(professionInfo);
	end

	for index, frame in ipairs(self.Pages) do
		if self.tabsMap[frame.page] == self.currentTab then
			self:SetWidth(frame:GetDesiredPageWidth());
			break;
		end
	end

	self:UpdateTabs();
end

function ProfessionsMixin:UpdateTabs()
	local onlyShowRecipes = not Professions.InLocalCraftingMode() or C_TradeSkillUI.IsRuneforging();
	self:SetTabsShown(not onlyShowRecipes);

	if onlyShowRecipes then
		self:SelectPage(self.Pages[RecipesPage].page)
	elseif not self.currentTab then
		self:SelectPage(self.Pages[HubPage].page)
	elseif self.currentPage then
		self:SelectPage(self.currentPage);
	end
end

function ProfessionsMixin:SelectPage(page)
	for index, frame in ipairs(self.Pages) do
		local show = (frame.page == page);
		frame:SetShown(show);

		local tab = self.tabsMap[frame.page];
		if show then
			self.currentTab = tab;
			self.currentPage = page;

			PanelTemplates_SelectTab(self.currentTab);

			self:SetWidth(frame:GetDesiredPageWidth());
			UpdateUIPanelPositions(self);
		else
			PanelTemplates_DeselectTab(tab);
		end
	end
end

function ProfessionsMixin:SetTabsShown(shown)
	for index, tab in pairs(self.Tabs) do
		tab:SetShown(shown);
	end
end

function ProfessionsMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsFrameEvents);

	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN);

	self:UpdateTabs();
end

function ProfessionsMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionsFrameEvents);

	C_TradeSkillUI.CloseTradeSkill();
	
	C_Garrison.CloseGarrisonTradeskillNPC();
	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE);
end

ProfessionsFrameTabMixin = {};

function ProfessionsFrameTabMixin:SetName(tabName)
	self.Text:SetText(tabName);
	-- Default min/max widths
	PanelTemplates_TabResize(self, 0, nil, 36, 88);
end