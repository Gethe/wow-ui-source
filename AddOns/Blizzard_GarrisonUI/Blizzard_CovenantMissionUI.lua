---------------------------------------------------------------------------------
--- Garrison Follower Options				                                  ---
---------------------------------------------------------------------------------

-- These are follower options that depend on this AddOn being loaded, and so they can't be set in GarrisonBaseUtils.
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_9_0].missionFollowerSortFunc =  nil;
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_9_0].missionFollowerInitSortFunc = nil;

local covenantGarrisonStyleData =
{
	--Might do 4x for covenants, setting it up for this to be the possible way to express it, but also just because this'll be an easy way to replace the assets 1 to 1
	closeButtonBorder = "AllianceFrame_ExitBorder",
	closeButtonBorderX = 0,
	closeButtonBorderY = -1,
	closeButtonX = 4,
	closeButtonY = 4,

	nineSliceLayout = "CovenantMissionFrame",

	BackgroundTile = "Adventures-Missions-BG-02",
};

local CovenantPlacer = GarrisonFollowerPlacer;

local function SetupMissionTab(tab, styleData)
	tab.Left:SetAtlas(styleData.TabLeft, true);
	tab.Right:SetAtlas(styleData.TabRight, true);
	tab.Middle:SetAtlas(styleData.TabMiddle, true);
	tab.Middle:SetHorizTile(false);

	tab.SelectedLeft:SetAtlas(styleData.TabSelectLeft, true);
	tab.SelectedRight:SetAtlas(styleData.TabSelectRight, true);
	tab.SelectedMid:SetAtlas(styleData.TabSelectMiddle, true);
	tab.SelectedMid:SetHorizTile(false);
end

local function SetupMissionList(self, styleData)
	SetupMissionTab(self.MissionTab.MissionList.Tab1, styleData);
	SetupMissionTab(self.MissionTab.MissionList.Tab2, styleData);
end

local function SetupBorder(self, styleData)
	self.GarrCorners:Hide();
	self.Bottom:SetTexCoord(0, 1, 1, 0);

	local nineSliceLayout = NineSliceUtil.GetLayout(styleData.nineSliceLayout);
	NineSliceUtil.ApplyLayout(self, nineSliceLayout);
	self.BackgroundTile:SetAtlas(styleData.BackgroundTile);

	self.CloseButton:ClearAllPoints();
	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", styleData.closeButtonX, styleData.closeButtonY);
	self.CloseButton:SetFrameLevel(self.GarrCorners:GetFrameLevel() + 2);

	self.OverlayElements.CloseButtonBorder:SetAtlas(styleData.closeButtonBorder, true);
	self.OverlayElements.CloseButtonBorder:SetParent(self.CloseButton);
	self.OverlayElements.CloseButtonBorder:SetPoint("CENTER", self.CloseButton, "CENTER", styleData.closeButtonBorderX, styleData.closeButtonBorderY);
end

local function SetupTabOffset(self)
	self.Tab1.xOffset = 7;
	self.Tab1.yOffset = -33;
end

local function SetupMaterialFrame(materialFrame, currency, currencyTexture)
	materialFrame.currencyType = currency;
	materialFrame.Icon:SetTexture(currencyTexture);
	materialFrame.Icon:SetSize(18, 18);
	materialFrame.Icon:SetPoint("RIGHT", materialFrame, "RIGHT", -14, 0);
end

---------------------------------------------------------------------------------
-- Shadowlands/Covenant Mission Frame
---------------------------------------------------------------------------------

CovenantMission = CreateFromMixins(CallbackRegistryMixin);

CovenantMission:GenerateCallbackEvents(
{
	"OnFollowerFrameMouseUp",
	"OnFollowerFrameDragStart",
	"OnFollowerFrameDragStop",
	"OnFollowerFrameReceiveDrag",
});

function CovenantMission:OnLoadMainFrame()
	CallbackRegistryMixin.OnLoad(self);
	GarrisonMission.OnLoadMainFrame(self);

	self.TitleText:Hide();

	self:UpdateCurrency();
	self:SetupMissionList();
	self:SetupCompleteDialog();
	self:UpdateTextures();
	PanelTemplates_SetNumTabs(self, 2);
	self:SelectTab(self:DefaultTab());

	self.FollowerList:SetSortFuncs(nil);

	self:GetMissionPage().Board:Reset();

	for followerFrame in self:GetMissionPage().Board:EnumerateFollowers() do
		followerFrame:SetMainFrame(self);
	end
end

local COVENANT_MISSION_EVENTS = {
	"GARRISON_MISSION_LIST_UPDATE",
	"CURRENCY_DISPLAY_UPDATE",
	"GARRISON_MISSION_STARTED",
	"GARRISON_MISSION_FINISHED",
	"GET_ITEM_INFO_RECEIVED",
	"GARRISON_RANDOM_MISSION_ADDED",
	"CURRENT_SPELL_CAST_CHANGED",
	"GARRISON_FOLLOWER_XP_CHANGED",
};

function CovenantMission:OnShowMainFrame()
	GarrisonFollowerMission.OnShowMainFrame(self);
	FrameUtil.RegisterFrameForEvents(self, COVENANT_MISSION_EVENTS); 

	self:RegisterCallback(CovenantMission.Event.OnFollowerFrameMouseUp, self.OnMouseUpMissionFollower, self);
	self:RegisterCallback(CovenantMission.Event.OnFollowerFrameDragStart, self.OnFollowerFrameDragStart, self);
	self:RegisterCallback(CovenantMission.Event.OnFollowerFrameDragStop, self.OnFollowerFrameDragStop, self);
	self:RegisterCallback(CovenantMission.Event.OnFollowerFrameReceiveDrag, self.OnFollowerFrameReceiveDrag, self);

	self:SetupTabs();
end

function CovenantMission:OnHideMainFrame()
	GarrisonFollowerMission.OnHideMainFrame(self);
	FrameUtil.UnregisterFrameForEvents(self, COVENANT_MISSION_EVENTS);

	self:UnregisterCallback(CovenantMission.Event.OnFollowerFrameMouseUp, self);
	self:UnregisterCallback(CovenantMission.Event.OnFollowerFrameDragStart, self);
	self:UnregisterCallback(CovenantMission.Event.OnFollowerFrameDragStop, self);
	self:UnregisterCallback(CovenantMission.Event.OnFollowerFrameReceiveDrag, self);

	C_AdventureMap.Close(); --Opening the table implicitly opens an Adventure Map, this clears the npc on it.
end

function CovenantMission:SetupTabs()
   local tabList = { };
   local validTabs = { };
   local defaultTab;

   local lastShowMissionsAndFollowersTabs = self.lastShowMissionsAndFollowersTabs;

   table.insert(tabList, 1);
   table.insert(tabList, 2);
   validTabs[1] = true;
   validTabs[2] = true;
   self.lastShowMissionsAndFollowersTabs = true;
   defaultTab = 1;

   self.Tab1:Hide();
   self.Tab2:Hide();

   -- don't show any tabs if there's only 1
   if (#tabList > 1) then
		local tab = self["Tab"..tabList[1]];
		local prevTab = tab;
		tab:ClearAllPoints();
		
		tab:SetPoint("BOTTOMLEFT", self, tab.xOffset or 7, tab.yOffset or -31);
		tab:Show();
		
		for i = 2, #tabList do
			tab = self["Tab"..tabList[i]];
			tab:ClearAllPoints();
			tab:SetPoint("LEFT", prevTab, "RIGHT", -16, 0);
			tab:Show();
			prevTab = tab;
		end
   end

   -- If the selected tab is not a valid one, switch to the default. Additionally, if the missions tab is newly available, then select it.
   local selectedTab = PanelTemplates_GetSelectedTab(self);
   if (not validTabs[selectedTab] or lastShowMissionsAndFollowersTabs ~= self.lastShowMissionsAndFollowersTabs) then
   	self:SelectTab(defaultTab);
   end
end

function CovenantMission:ShowMission(missionInfo)
	local missionPage = self:GetMissionPage();

	for followerFrame in missionPage.Board:EnumerateFollowers() do
		followerFrame:SetEmpty();
		followerFrame:Show();
	end

	missionPage.missionInfo = missionInfo;

	self:SetTitle(missionInfo.name);

	self:SetMissionIcon(missionInfo.typeAtlas, missionInfo.isRare);
	
	local missionDeploymentInfo =  C_Garrison.GetMissionDeploymentInfo(missionInfo.missionID);
	missionPage.environment = missionDeploymentInfo.environment;

	self:SetEnvironmentTexture(missionDeploymentInfo.environmentTexture);

	local enemies = missionDeploymentInfo.enemies;
	self:SetEnemies(missionPage, enemies);

	self:UpdateMissionData(missionPage);
end

function CovenantMission:ClearParty()
	local missionPage = self:GetMissionPage();
	for followerFrame in missionPage.Board:EnumerateFollowers() do
		local followerGUID = followerFrame:GetFollowerGUID();
		if followerGUID then
			C_Garrison.RemoveFollowerFromMission(missionPage.missionInfo.missionID, followerGUID);
		end
	end

	missionPage.Board:Reset();
end

-- numFollowers is unused, but kept to maintain the same function signature.
function CovenantMission:SetEnemies(missionPage, enemies, numFollowers)
   	for i, enemyInfo in ipairs(enemies) do
   		local frame = missionPage.Board:GetFrameByBoardIndex(enemyInfo.boardIndex);
   		frame:SetEncounter(enemyInfo);
   		frame:Show();
   	end

   	return #enemies;
end

function CovenantMission:MissionCompleteInitialize(missionList, index)
   	if (not missionList or #missionList == 0 or index == 0) then
   		self:CloseMissionComplete();
   		return false;
   	end
   	if (index > #missionList) then
   		self.MissionComplete.completeMissions = nil;
   		self:CloseMissionComplete();
   		return false;
   	end
   	local mission = missionList[index];
   	self.MissionComplete:SetCurrentMission(mission);
   	return true;
end

function CovenantMission:OnClickFollowerPlacerFrame(button, info)
	if button == "LeftButton" then
		for followerFrame in self:GetMissionPage().Board:EnumerateFollowers() do
			if followerFrame:IsShown() and followerFrame:IsMouseOver() then
				self:AssignFollowerToMission(followerFrame, info);
			end
		end
	end

	self:ClearMouse();
end

function CovenantMission:OnFollowerFrameDragStart(followerFrame)
	local info = followerFrame:GetInfo();
	if not info then
		return;
	end

	self:SetPlacerFrame(CovenantPlacer, info);
	CovenantPlacer.dragStartFrame = followerFrame;

	local function CovenantPlacerFrame_OnHide()
		CovenantPlacer.dragStartFrame = nil;
		CovenantPlacer:SetScript("OnHide", nil);
	end
	
	CovenantPlacer:SetScript("OnHide", CovenantPlacerFrame_OnHide);

	self:RemoveFollowerFromMission(followerFrame);
end

function CovenantMission:OnFollowerFrameDragStop(followerFrame)
	GarrisonShowFollowerPlacerFrame(self, CovenantPlacer.info);
end

function CovenantMission:OnFollowerFrameReceiveDrag(followerFrame)
	self:AssignFollowerToMission(followerFrame, CovenantPlacer.info);
	self:ClearMouse();
end

local AutoAssignmentFollowerOrder = {
	Enum.GarrAutoBoardIndex.AllyLeftFront,
	Enum.GarrAutoBoardIndex.AllyCenterFront,
	Enum.GarrAutoBoardIndex.AllyRightFront,
	Enum.GarrAutoBoardIndex.AllyLeftBack,
	Enum.GarrAutoBoardIndex.AllyRightBack,
};

function CovenantMission:DefaultTab()
    return 1;   -- Missions
end

function CovenantMission:GetNineSlicePiece(pieceName)
    if pieceName == "TopLeftCorner" then
        return self.TopLeftCorner;
    elseif pieceName == "TopRightCorner" then
        return self.TopRightCorner;
    elseif pieceName == "BottomLeftCorner" then
        return self.BotLeftCorner;
    elseif pieceName == "BottomRightCorner" then
        return self.BotRightCorner;
    elseif pieceName == "TopEdge" then
        return self.TopBorder;
    elseif pieceName == "BottomEdge" then
        return self.BottomBorder;
    elseif pieceName == "LeftEdge" then
        return self.LeftBorder;
    elseif pieceName == "RightEdge" then
        return self.RightBorder;
    end
end

function CovenantMission:UpdateTextures()
	local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(GarrisonFollowerOptions[self.followerTypeID].garrisonType);
	local currencyTexture = C_CurrencyInfo.GetCurrencyInfo(primaryCurrency).iconFileID;

	self.MissionTab.MissionPage.CostFrame.CostIcon:SetTexture(currencyTexture);
	self.MissionTab.MissionPage.CostFrame.CostIcon:SetSize(18, 18);
	self.MissionTab.MissionPage.CostFrame.Cost:SetPoint("RIGHT", self.MissionTab.MissionPage.CostFrame.CostIcon, "LEFT", -8, -1);

	self.FollowerTab.CostFrame.CostIcon:SetTexture(currencyTexture);
	self.FollowerTab.CostFrame.CostIcon:SetSize(18, 18);
	self.FollowerTab.CostFrame.Cost:SetPoint("RIGHT", self.FollowerTab.CostFrame.CostIcon, "LEFT", -8, -1);

	SetupMaterialFrame(self.FollowerList.MaterialFrame, primaryCurrency, currencyTexture);
	SetupMaterialFrame(self.MissionTab.MissionList.MaterialFrame, primaryCurrency, currencyTexture);
	self:GetCompleteDialog().BorderFrame.ViewButton:SetPoint("BOTTOM", 0, 88);

	self.MissionTab.MissionPage.Stage.MissionEnvIcon:SetSize(48,48);
	self.MissionTab.MissionPage.Stage.MissionEnvIcon:SetPoint("LEFT", self.MissionTab.MissionPage.Stage.MissionInfo.MissionEnv, "RIGHT", -11, 0);

	self.Top:SetAtlas("_AdventuresFrame-Small-Top", true);
	self.Bottom:SetAtlas("_AdventuresFrame-Small-Top", true);
	self.Left:SetAtlas("!AdventuresFrame-Left", true);
	self.Right:SetAtlas("!AdventuresFrame-Left", true);

	local tabs = { self.MissionTab.MissionList.Tab1, self.MissionTab.MissionList.Tab2 };
	for _, tab in ipairs(tabs) do
		tab.Left:SetAtlas("ClassHall_ParchmentHeader-End-2", true);
		tab.Right:SetAtlas("ClassHall_ParchmentHeader-End-2", true);
		tab.Middle:SetAtlas("_ClassHall_ParchmentHeader-Mid", true);
		tab.Middle:SetPoint("LEFT", tab.Left, "RIGHT");
		tab.Middle:SetPoint("RIGHT", tab.Right, "LEFT");
		tab.Middle:SetHorizTile(false);
		tab.SelectedLeft:SetAtlas("ClassHall_ParchmentHeaderSelect-End-2", true);
		tab.SelectedRight:SetAtlas("ClassHall_ParchmentHeaderSelect-End-2", true);
		tab.SelectedMid:SetAtlas("_ClassHall_ParchmentHeaderSelect-Mid", true);
		tab.SelectedMid:SetPoint("LEFT", tab.SelectedLeft, "RIGHT");
		tab.SelectedMid:SetPoint("RIGHT", tab.SelectedRight, "LEFT");
		tab.SelectedMid:SetHorizTile(false);
	end

	local frames = { self.FollowerTab, self.MissionTab.MissionList };
	for _, frame in ipairs(frames) do
		frame.BaseFrameBackground:SetAtlas("Adventures-Missions-BG-01");
		frame.BaseFrameLeft:SetAtlas("!ClassHall_InfoBoxMission-Left");
		frame.BaseFrameRight:SetAtlas("!ClassHall_InfoBoxMission-Left");
		frame.BaseFrameTop:SetAtlas("_ClassHall_InfoBoxMission-Top");
		frame.BaseFrameBottom:SetAtlas("_ClassHall_InfoBoxMission-Top");
		frame.BaseFrameTopLeft:SetAtlas("ClassHall_InfoBoxMission-Corner");
		frame.BaseFrameTopRight:SetAtlas("ClassHall_InfoBoxMission-Corner");
		frame.BaseFrameBottomLeft:SetAtlas("ClassHall_InfoBoxMission-Corner");
		frame.BaseFrameBottomRight:SetAtlas("ClassHall_InfoBoxMission-Corner");
	end

	self.BackgroundTile:SetAtlas("Adventures-Missions-BG-02");

	local styleData = covenantGarrisonStyleData;

	SetupTabOffset(self);
	SetupMissionList(self, styleData);
	SetupBorder(self, styleData);
end

function CovenantMission:AssignFollowerToMission(frame, info)
	local missionPage = self:GetMissionPage();

	local previousFollowerID = frame:GetFollowerGUID();
	local previousFollowerInfo = frame:GetInfo();
	if previousFollowerID then
		C_Garrison.RemoveFollowerFromMission(missionPage.missionInfo.missionID, previousFollowerID);
		frame:SetEmpty();
	end
	
	if C_Garrison.GetFollowerStatus(info.followerID) ~= GARRISON_FOLLOWER_IN_PARTY then
		if not C_Garrison.AddFollowerToMission(missionPage.missionInfo.missionID, info.followerID, frame.boardIndex) then
			return false;
		end
	end

	frame:SetFollowerGUID(info.followerID, info);

	-- We're dragging this follower from another slot.
	if CovenantPlacer.dragStartFrame and previousFollowerInfo then
		self:AssignFollowerToMission(CovenantPlacer.dragStartFrame, previousFollowerInfo);
	end

	self:UpdateMissionData(missionPage);

	return true;
end

function CovenantMission:UpdateMissionParty()
	-- We don't need to do any further updates for covenant missions, as the pucks handle the display work.
end

function CovenantMission:RemoveFollowerFromMission(frame, updateValues)
	local missionPage = self:GetMissionPage();

	local followerID = frame:GetFollowerGUID();
	if followerID then
		C_Garrison.RemoveFollowerFromMission(missionPage.missionInfo.missionID, followerID);
	end

	frame:SetEmpty();

	self:UpdateMissionData(missionPage);
end

function CovenantMission:GetNumMissionFollowers()
	local numFollowers = 0;
	for followerFrame in self:GetMissionPage().Board:EnumerateFollowers() do
		if followerFrame:GetFollowerGUID() then
			numFollowers = numFollowers + 1;
		end
	end

	return numFollowers;
end

---------------------------------------------------------------------------------
--- Mission Page Follower Mixin                                               ---
---------------------------------------------------------------------------------

CovenantFollowerMissionPageMixin = { }

function CovenantFollowerMissionPageMixin:AddFollower(followerID)
	local missionFrame = self:GetParent():GetParent();

	local followerInfo = C_Garrison.GetFollowerInfo(followerID);
	
	for i, boardIndex in ipairs(AutoAssignmentFollowerOrder) do
		local puck = self.Board:GetFrameByBoardIndex(boardIndex);
		if not puck:GetFollowerGUID() then
			missionFrame:AssignFollowerToMission(puck, followerInfo);
			puck:SetHighlight(false);
			break;
		end
	end
end

function CovenantFollowerMissionPageMixin:UpdatePortraitPulse()
	local highlightFound = false;
	for i, boardIndex in ipairs(AutoAssignmentFollowerOrder) do
		local puck = self.Board:GetFrameByBoardIndex(boardIndex);
		if highlightFound or puck:GetFollowerGUID() then
			puck:SetHighlight(false);
		else
			highlightFound = true;
			puck:SetHighlight(true);
		end
	end
end

---------------------------------------------------------------------------------
--- Covenant Mission Page													  ---
---------------------------------------------------------------------------------

--These functions defaulted some behavior on the Garrison side that we didn't want for the redesign.
function CovenantMissionPage_OnShow(self)
	local mainFrame = self:GetParent():GetParent();
	self:SetFollowerListSortFuncsForMission();
	mainFrame.FollowerList.showCounters = false;
	mainFrame.FollowerList.canExpand = false;
	mainFrame.FollowerList.showUncollected = false;
	mainFrame.FollowerList:Show();
	mainFrame:UpdateStartButton(self);
end

function CovenantMissionPage_OnHide(self)
	local mainFrame = self:GetParent():GetParent();
	mainFrame.FollowerList.showCounters = false;
	mainFrame.FollowerList.canExpand = false;
	mainFrame.FollowerList.showUncollected = true;

	self.lastUpdate = nil;
end

