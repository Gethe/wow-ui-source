local ACTIVE_EVENTS = {
	"PLAYER_LEAVING_WORLD",
	"PVP_MATCH_COMPLETE",
	"UPDATE_BATTLEFIELD_SCORE",
};

PVPMatchScoreboardMixin = {};

function PVPMatchScoreboardMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_JOINED_PVP_MATCH");

	self.ScrollBox = self.Content.ScrollBox;
	self.ScrollBar = self.Content.ScrollBar;
	self.ScrollCategories = self.Content.ScrollCategories;
	self.TabContainer = self.Content.TabContainer;
	self.TabGroup = self.TabContainer.TabGroup;
	self.MatchmakingText = self.TabContainer.MatchmakingText;
	self.Tab1 = self.TabGroup.Tab1;
	self.Tab2 = self.TabGroup.Tab2;
	self.Tab3 = self.TabGroup.Tab3;
	self.tintFrames = { self.Content.ScrollBox.Background };

	self.Tab1:SetText(ALL);
	self.Tabs = {self.Tab1, self.Tab2, self.Tab3};
	PanelTemplates_SetNumTabs(self, #self.Tabs);
	for k, tab in pairs(self.Tabs) do
		tab:SetScript("OnClick", function() self:OnTabGroupClicked(tab) end);
	end
	PanelTemplates_SetTab(self, 1);

	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-GenericMetal-ExitButtonBorder", -1, 1);

	self.tableBuilder = CreateTableBuilder();
	self.tableBuilder:SetHeaderContainer(self.ScrollCategories);

	PVPMatchUtil.InitScrollBox(self.ScrollBox, self.ScrollBar, self.tableBuilder);
end

function PVPMatchScoreboardMixin:Init()
	if self.isInitialized then
		return;
	end
	self.isInitialized = true;

	FrameUtil.RegisterFrameForEvents(self, ACTIVE_EVENTS);

	local isFactionalMatch = C_PvP.IsMatchFactional();
	self.TabGroup:SetShown(isFactionalMatch);
	self:UpdateTabs();
	
	local factionIndex = GetBattlefieldArenaFaction();
	self:SetupArtwork(factionIndex, isFactionalMatch);
	
	ConstructPVPMatchTable(self.tableBuilder, not isFactionalMatch);
end

function PVPMatchScoreboardMixin:UpdateTabs()
	if self.TabGroup:IsShown() then
		local teamInfos = { 
			C_PvP.GetTeamInfo(0),
			C_PvP.GetTeamInfo(1),
		};
		self.Tab2:SetText(PVP_TAB_FILTER_COUNTED:format(FACTION_ALLIANCE, teamInfos[2].size));
		self.Tab3:SetText(PVP_TAB_FILTER_COUNTED:format(FACTION_HORDE, teamInfos[1].size));
	end

	PVPMatchUtil.UpdateMatchmakingText(self.MatchmakingText);
end

function PVPMatchScoreboardMixin:ShutdownPrivate()
	FrameUtil.UnregisterFrameForEvents(self, ACTIVE_EVENTS);
	self.isInitialized = false;
	HideUIPanel(self);
end

function PVPMatchScoreboardMixin:OnEvent(event, ...)
	if event == "PLAYER_JOINED_PVP_MATCH" or (event == "PLAYER_ENTERING_WORLD" and (C_PvP.GetActiveMatchState() >= Enum.PvPMatchState.Engaged)) then
		self:Init();
	elseif event == "PLAYER_LEAVING_WORLD" or event == "PVP_MATCH_COMPLETE" then
		self:ShutdownPrivate();
	elseif event == "UPDATE_BATTLEFIELD_SCORE" then
		self:UpdateTable();
	end
end

function PVPMatchScoreboardMixin:OnUpdate()
	RequestBattlefieldScoreData();
end

function PVPMatchScoreboardMixin:SetupArtwork(factionIndex, isFactionalMatch)
	local useAlternateColor = not isFactionalMatch;
	local r, g, b = PVPMatchStyle.GetTeamColor(factionIndex, useAlternateColor):GetRGB();
	self.ScrollBox.Background:SetVertexColor(r, g, b);

	local theme;
	if isFactionalMatch then
		theme = PVPMatchStyle.GetFactionPanelThemeByIndex(factionIndex);
	else
		theme = PVPMatchStyle.GetNeutralPanelTheme();
	end

	NineSliceUtil.ApplyLayoutByName(self, theme.nineSliceLayout);
end


function PVPMatchScoreboardMixin:UpdateTable()
	local forceNewDataProvider = true;
	PVPMatchUtil.UpdateDataProvider(self.ScrollBox, forceNewDataProvider);

	self:UpdateTabs();
end

function PVPMatchScoreboardMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function PVPMatchScoreboardMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function PVPMatchScoreboardMixin:OnTabGroupClicked(tab)
	PanelTemplates_SetTab(self, tab:GetID());
	SetBattlefieldScoreFaction(tab.factionEnum);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);

	local forceNewDataProvider = true;
	PVPMatchUtil.UpdateDataProvider(self.ScrollBox, forceNewDataProvider);
end

function PVPMatchScoreboardMixin:BeginShow()
	self:Init();
	ShowUIPanel(PVPMatchScoreboard);
end