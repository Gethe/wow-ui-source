local ACTIVE_EVENTS = {
	"PLAYER_LEAVING_WORLD",
	"PVP_MATCH_COMPLETE",
	"PVP_MATCH_INACTIVE",
	"UPDATE_BATTLEFIELD_SCORE",
};

PVPMatchScoreboardMixin = {};

function PVPMatchScoreboardMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PVP_MATCH_ACTIVE");

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
	if self.isInitialized then
		return;
	end
	self.isInitialized = true;

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
end

function PVPMatchScoreboardMixin:InitPrivate()
	self:Init();
	FrameUtil.RegisterFrameForEvents(self, ACTIVE_EVENTS);
end

function PVPMatchScoreboardMixin:ShutdownPrivate()
	FrameUtil.UnregisterFrameForEvents(self, ACTIVE_EVENTS);
	self.isInitialized = false;
	HideUIPanel(self);
end

function PVPMatchScoreboardMixin:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		if C_PvP.GetActiveMatchState() == Enum.PvpMatchState.Active then
			self:InitPrivate();
		end
	elseif event == "PVP_MATCH_ACTIVE" then
		self:InitPrivate();
	elseif event == "PVP_MATCH_INACTIVE" or event == "PLAYER_LEAVING_WORLD" or event == "PVP_MATCH_COMPLETE" then
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

	self:UpdateTabs();

	local regionHeight = self.ScrollFrame:GetHeight();
	HybridScrollFrame_Update(self.ScrollFrame, visibleElementHeight, regionHeight);
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
end

function PVPMatchScoreboardMixin:BeginShow()
	self:Init();
	ShowUIPanel(PVPMatchScoreboard);
end