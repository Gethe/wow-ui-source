local ACTIVE_EVENTS = {
	"UPDATE_BATTLEFIELD_SCORE",
};

PVPMatchScoreboardMixin = {};

function PVPMatchScoreboardMixin:OnLoad()
	self:RegisterEvent("PVP_MATCH_ACTIVE");
	self:RegisterEvent("PVP_MATCH_INACTIVE");

	self.ScrollFrame = self.Content.ScrollFrame;
	self.ScrollCategories = self.Content.ScrollCategories;
	self.TabGroup = self.Content.TabContainer.TabGroup;
	self.Tab1 = self.TabGroup.Tab1;
	self.Tab2 = self.TabGroup.Tab2;
	self.Tab3 = self.TabGroup.Tab3;
	self.tintFrames = { self.ScrollFrame.Background };

	self.Tab1:SetText(ALL);
	self.Tabs = {self.Tab1, self.Tab2, self.Tab3};
	PanelTemplates_SetNumTabs(self, #self.Tabs);
	for k, tab in pairs(self.Tabs) do
		tab:SetScript("OnClick", function() self:OnTabGroupClicked(tab) end);
	end
	PanelTemplates_SetTab(self, 1);

	HybridScrollFrame_OnLoad(self.ScrollFrame);
	HybridScrollFrame_CreateButtons(self.ScrollFrame, "PVPTableRowTemplate");
	HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true);

	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-GenericMetal-ExitButtonBorder", -1, 1);

	self.tableBuilder = CreateTableBuilder(HybridScrollFrame_GetButtons(self.ScrollFrame));
	self.tableBuilder:SetHeaderContainer(self.ScrollCategories);
end

function PVPMatchScoreboardMixin:Init()
	local isArena = IsActiveBattlefieldArena();
	local isLFD = IsInLFDBattlefield();
	local isFactionalMatch = not (isArena or isArenaSkirmish or isLFD);
	local factionIndex = GetBattlefieldArenaFaction();

	if isFactionalMatch then
		local teamInfos = { 
			C_PvP.GetTeamInfo(0),
			C_PvP.GetTeamInfo(1), 
		};
		self.Tab2:SetText(PVP_TAB_FILTER_COUNTED:format(FACTION_ALLIANCE, teamInfos[2].size));
		self.Tab3:SetText(PVP_TAB_FILTER_COUNTED:format(FACTION_HORDE, teamInfos[1].size));
		PanelTemplates_ResizeTabsToFit(self, 600);
	end
	self.TabGroup:SetShown(isFactionalMatch);

	self:SetupArtwork(factionIndex, isFactionalMatch);

	ConstructPVPMatchTable(self.tableBuilder, C_PvP.IsRatedBattleground(), isArena, isLFD, not isFactionalMatch);
end

function PVPMatchScoreboardMixin:OnEvent(event, ...)
	if event == "PVP_MATCH_ACTIVE" then
		self:Init();
		FrameUtil.RegisterFrameForEvents(self, ACTIVE_EVENTS);
	elseif event == "PVP_MATCH_INACTIVE" then
		FrameUtil.UnregisterFrameForEvents(self, ACTIVE_EVENTS);
		HideUIPanel(self);
	elseif event == "UPDATE_BATTLEFIELD_SCORE" then
		self:UpdateTable();
	end
end

function PVPMatchScoreboardMixin:OnUpdate()
	RequestBattlefieldScoreData();
end

function PVPMatchScoreboardMixin:SetupArtwork(factionIndex, isFactionalMatch)
	local useAlternateColor = not isFactionalMatch;
	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);
	for k, button in pairs(buttons) do
		button:Init(useAlternateColor);
	end

	local r, g, b = PVPMatchStyle.GetPanelColor(factionIndex, useAlternateColor):GetRGB();
	self.ScrollFrame.Background:SetVertexColor(r, g, b);

	local theme;
	if isFactionalMatch then
		theme = PVPMatchStyle.GetFactionPanelThemeByIndex(factionIndex);
	else
		theme = PVPMatchStyle.GetNeutralPanelTheme();
	end

	NineSliceUtil.ApplyLayoutByName(self, theme.nineSliceLayout);
end

function PVPMatchScoreboardMixin:UpdateTable()
	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);
	local buttonCount = #buttons;
	local displayCount = GetNumBattlefieldScores();
	local buttonHeight = buttons[1]:GetHeight();
	local visibleElementHeight = displayCount * buttonHeight;

	local offset = HybridScrollFrame_GetOffset(self.ScrollFrame);
	local populateCount = math.min(buttonCount, displayCount);
	self.tableBuilder:Populate(offset, populateCount);
	
	for i = 1, buttonCount do
		local visible = i <= displayCount;
		buttons[i]:SetShown(visible);
	end

	local regionHeight = self.ScrollFrame:GetHeight();
	HybridScrollFrame_Update(self.ScrollFrame, visibleElementHeight, regionHeight);
end
function PVPMatchScoreboardMixin:OnClose()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

	HideParentPanel(self);
end

function PVPMatchScoreboardMixin:OnTabGroupClicked(tab)
	PanelTemplates_SetTab(self, tab:GetID());
	SetBattlefieldScoreFaction(tab.factionEnum);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function PVPMatchScoreboardMixin:BeginShow()
	ShowUIPanel(PVPMatchScoreboard);
end