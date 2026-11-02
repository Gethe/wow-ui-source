local ACTIVE_EVENTS = {
	"PVP_MATCH_COMPLETE",
};

local LeaveMatchFormatter = CreateFromMixins(SecondsFormatterMixin);
LeaveMatchFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, true);
LeaveMatchFormatter:SetStripIntervalWhitespace(true);

function LeaveMatchFormatter:GetDesiredUnitCount(seconds)
	return 1;
end

PVPMatchResultsMixin = {};

function PVPMatchResultsMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LEAVING_WORLD");
	self:RegisterEvent("PVP_MATCH_ACTIVE");

	local tabContainer = self.content.tabContainer;
	self.scrollBox = self.content.scrollBox;
	self.scrollBar = self.content.scrollBar;
	self.scrollCategories = self.content.scrollCategories;
	self.tabGroup = tabContainer.tabGroup;
	self.tab1 = self.tabGroup.tab1;
	self.tab2 = self.tabGroup.tab2;
	self.tab3 = self.tabGroup.tab3;
	self.header = self.HeaderContainer.Text;
	self.leaveButton = self.buttonContainer.leaveButton;
	self.header:SetShadowOffset(1, -1);
	self.scrollBox:SetEdgeFadeLength(45);

	self.leaveButton:SetScript("OnClick", function() self:OnLeaveButtonClicked(self.leaveButton) end);

	self.tab1:SetText(ALL);
	self.Tabs = { self.tab1, self.tab2, self.tab3 };
	PanelTemplates_SetNumTabs(self, #self.Tabs);
	for _, tab in pairs(self.Tabs) do
		tab:SetScript("OnClick", function() self:OnTabGroupClicked(tab) end);
	end
	PanelTemplates_SetTab(self, 1);

	self.tableBuilder = CreateTableBuilder();
	self.tableBuilder:SetHeaderContainer(self.scrollCategories);
	PVPMatchUtil.InitScrollBox(self.scrollBox, self.scrollBar, self.tableBuilder);
end

function PVPMatchResultsMixin:Init()
	if self.isInitialized then
		return;
	end
	self.isInitialized = true;

	local function GetOutcomeText(winner, currentFactionIndex)
		local enemyFactionIndex = (currentFactionIndex + 1) % 2;
		if winner == currentFactionIndex or winner == enemyFactionIndex then
			local playerIsAlliance = UnitFactionGroup("player") == "Alliance";
			local allianceWon = (winner == currentFactionIndex and playerIsAlliance) or (winner == enemyFactionIndex and not playerIsAlliance);
			local useAlternateColor = false;
			local allianceText = PVPMatchUtil.GetCellColor(1, useAlternateColor):WrapTextInColorCode(VICTORY_TEXT1);
			local hordeText = PVPMatchUtil.GetCellColor(0, useAlternateColor):WrapTextInColorCode(VICTORY_TEXT0);
			return allianceWon and allianceText or hordeText;
		end
		return PVP_MATCH_DRAW;
	end

	local factionIndex = GetBattlefieldArenaFaction();
	self.header:SetText(GetOutcomeText(C_PvP.GetActiveMatchWinner(), factionIndex));

	self.leaveButton:SetText(PVP_MATCH_LEAVE_BUTTON);
	local baseWidth = self.leaveButton:GetFontString():GetStringWidth();
	local timeWidthMargin = 100;
	self.leaveButton:SetWidth(baseWidth + timeWidthMargin);

	self.UpdateLeaveButton = function()
		local shutdownTime = GetBattlefieldInstanceExpiration() / 1000;
		if shutdownTime > 0 then
			local formattedTime = LeaveMatchFormatter:Format(shutdownTime);
			self.leaveButton:SetText(PVP_LEAVE_BUTTON_TIME:format(PVP_MATCH_LEAVE_BUTTON, formattedTime));
		else
			self.leaveButton:SetText(PVP_MATCH_LEAVE_BUTTON);
		end
	end;

	local teamInfos = {
		C_PvP.GetTeamInfo(0),
		C_PvP.GetTeamInfo(1),
	};
	self.tab2:SetText(PVP_TAB_FILTER_COUNTED:format(FACTION_ALLIANCE, teamInfos[2].size));
	self.tab3:SetText(PVP_TAB_FILTER_COUNTED:format(FACTION_HORDE, teamInfos[1].size));
	PanelTemplates_ResizeTabsToFit(self, 600);

	if C_PvP.GetCustomVictoryStatID() > 0 then
		SortBattlefieldScoreData("stat1");
	end

	local isFactionalMatch = true;
	ConstructPVPMatchTable(self.tableBuilder, not isFactionalMatch);
end

function PVPMatchResultsMixin:Shutdown()
	FrameUtil.UnregisterFrameForEvents(self, ACTIVE_EVENTS);
	self.isInitialized = false;
	HideUIPanel(self);
end

function PVPMatchResultsMixin:OnEvent(event, ...)
	if event == "PVP_MATCH_ACTIVE" or (event == "PLAYER_ENTERING_WORLD" and (C_PvP.IsMatchActive() or C_PvP.IsMatchComplete())) then
		FrameUtil.RegisterFrameForEvents(self, ACTIVE_EVENTS);
	elseif event == "PLAYER_LEAVING_WORLD" then
		self:Shutdown();
	elseif event == "PVP_MATCH_COMPLETE" then
		if not C_Commentator.IsSpectating() then
			self:BeginShow();
		end
	end
end

function PVPMatchResultsMixin:BeginShow()
	self:Init();
	ShowUIPanel(self);
end

function PVPMatchResultsMixin:DisplayRewards()
	return;
end

function PVPMatchResultsMixin:HaveConquestData()
	return true;
end

function PVPMatchResultsMixin:OnUpdate()
	if self.UpdateLeaveButton then
		self:UpdateLeaveButton();
	end

	if C_PvP.IsActiveBattlefield() then
		local forceNewDataProvider = true;
		PVPMatchUtil.UpdateDataProvider(self.scrollBox, forceNewDataProvider);
	end
end

function PVPMatchResultsMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function PVPMatchResultsMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function PVPMatchResultsMixin:AddItemReward(item)
	return;
end

function PVPMatchResultsMixin:InitHonorFrame(currency)
	return;
end

function PVPMatchResultsMixin:InitConquestFrame(currency)
	return;
end

function PVPMatchResultsMixin:InitRatingFrame()
	return;
end

function PVPMatchResultsMixin:OnLeaveButtonClicked(button)
	if IsInLFDBattlefield() then
		ConfirmOrLeaveLFGParty();
	else
		ConfirmOrLeaveBattlefield();
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
end

function PVPMatchResultsMixin:OnTabGroupClicked(tab)
	PanelTemplates_SetTab(self, tab:GetID());
	SetBattlefieldScoreFaction(tab.factionEnum);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);

	PVPMatchUtil.UpdateDataProvider(self.scrollBox);
	self.scrollBox:ScrollToBegin();
end
