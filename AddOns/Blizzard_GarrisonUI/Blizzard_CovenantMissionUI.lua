---------------------------------------------------------------------------------
--- Garrison Follower Options				                                  ---
---------------------------------------------------------------------------------

-- These are follower options that depend on this AddOn being loaded, and so they can't be set in GarrisonBaseUtils.
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_9_0].missionFollowerSortFunc =  GarrisonFollowerList_PrioritizeSpecializationAbilityMissionSort;
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_9_0].missionFollowerInitSortFunc = GarrisonFollowerList_InitializePrioritizeSpecializationAbilityMissionSort;

local covenantGarrisonStyleData =
{
	--Might do 4x for covenants, setting it up for this to be the possible way to express it, but also just because this'll be an easy way to replace the assets 1 to 1
	TitleScrollOffset = -5,
	TitleColor = CreateColor(0.008, 0.051, 0.192, 1),

	titleScrollLeft = "AllianceFrame_Title-End-2",
	titleScrollRight = "AllianceFrame_Title-End",
	titleScrollMiddle = "_AllianceFrame_Title-Tile",

	closeButtonBorder = "AllianceFrame_ExitBorder",
	closeButtonBorderX = 0,
	closeButtonBorderY = -1,
	closeButtonX = 4,
	closeButtonY = 4,

	nineSliceLayout = "BFAMissionAlliance",

	BackgroundTile = "UI-Frame-Alliance-BackgroundTile",

	TabLeft = "AllianceFrame_ParchmentHeader-End-2",
	TabRight = "AllianceFrame_ParchmentHeader-End-2",
	TabMiddle = "_AllianceFrame_ParchmentHeader-Mid",
	TabSelectLeft = "AllianceFrame_ParchmentHeaderSelect-End-2",
	TabSelectRight = "AllianceFrame_ParchmentHeaderSelect-End-2",
	TabSelectMiddle = "_AllianceFrame_ParchmentHeaderSelect-Mid",

	SearchLeft = "AllianceFrame_ParchmentHeader-End",
	SearchRight = "AllianceFrame_ParchmentHeader-End-2",
	SearchMiddle = "_AllianceFrame_ParchmentHeader-Mid",
};

local function SetupTitleText(self, styleData)
	if styleData.TitleColor then
		self.TitleText:SetTextColor(styleData.TitleColor:GetRGBA())
	end

	self.TitleText:SetShadowOffset(0, 0);
end

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

local function SetupFollowerList(self, styleData)
	self.FollowerList.HeaderLeft:SetAtlas(styleData.SearchLeft, true);
	self.FollowerList.HeaderRight:SetAtlas(styleData.SearchRight, true);
	self.FollowerList.HeaderMid:SetAtlas(styleData.SearchMiddle, true);

	self.FollowerList.HeaderRight:SetTexCoord(0, 1, 0, 1);
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

CovenantMission = { }

function CovenantMission:OnLoadMainFrame()
	GarrisonFollowerMission.OnLoadMainFrame(self);
	self:UpdateTextures();
	PanelTemplates_SetNumTabs(self, 2);
	self:SelectTab(self:DefaultTab());
	self:AssignBoardPositions();
end

function CovenantMission:AssignBoardPositions()
	self.missionSendBoardReverseLookup = {};
	local missionPage = self.MissionTab.MissionPage;
	for i=1, #missionPage.Enemies do
		self.missionSendBoardReverseLookup[missionPage.Enemies[i].boardIndex] = missionPage.Enemies[i];
	end

	for i=1, #missionPage.Followers do 
		self.missionSendBoardReverseLookup[missionPage.Followers[i].boardIndex] = missionPage.Followers[i];
	end
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

function CovenantMission:SetEnemies(missionPage, enemies, numFollowers)
   	local numVisibleEnemies = 0;

   	local enemiesByBoardIndex = {};

   	for i=1, #enemies do
   		enemiesByBoardIndex[enemies[i].boardIndex] = enemies[i];
   	end

   	for i=1, #missionPage.Enemies do
   		local frame = missionPage.Enemies[i];
   		if ( not frame ) then
   			break;
   		end

   		local enemy = enemiesByBoardIndex[frame.boardIndex];
   		local numMechs = 0;
   		local portrait = frame;
   		if (frame.PortraitFrame) then
   			portrait = frame.PortraitFrame;
   		end
   		local enemyName = "";

   		if( enemy ) then 
   			numVisibleEnemies = numVisibleEnemies + 1;		
   			enemyName = enemy.name;
			frame.autoCombatSpells = enemy.autoCombatSpells;
   		else
   			enemy = {};
			frame.autoCombatSpells = {};
   		end

   		self:SetEnemyPortrait(portrait, enemy, portrait.Elite, numMechs);
		self:OnSetEnemy(frame, enemy);
   		frame.Name:SetText(enemyName);
   		frame:Show();
   	end

   	missionPage.Enemy1:SetPoint("TOPLEFT", 78, -164);
   	return numVisibleEnemies;
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
	--TODO: Crazy placeholder on art for now. 
	local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(GarrisonFollowerOptions[self.followerTypeID].garrisonType);
	local currencyTexture = C_CurrencyInfo.GetCurrencyInfo(primaryCurrency).iconFileID;

	self.MissionTab.MissionPage.CostFrame.CostIcon:SetTexture(currencyTexture);
	self.MissionTab.MissionPage.CostFrame.CostIcon:SetSize(18, 18);
	self.MissionTab.MissionPage.CostFrame.Cost:SetPoint("RIGHT", self.MissionTab.MissionPage.CostFrame.CostIcon, "LEFT", -8, -1);

	SetupMaterialFrame(self.FollowerList.MaterialFrame, primaryCurrency, currencyTexture);
	SetupMaterialFrame(self.MissionTab.MissionList.MaterialFrame, primaryCurrency, currencyTexture);
	self:GetCompleteDialog().BorderFrame.ViewButton:SetPoint("BOTTOM", 0, 88);

	self.MissionTab.MissionPage.Stage.MissionEnvIcon:SetSize(48,48);
	self.MissionTab.MissionPage.Stage.MissionEnvIcon:SetPoint("LEFT", self.MissionTab.MissionPage.Stage.MissionInfo.MissionEnv, "RIGHT", -11, 0);

	self.Top:SetAtlas("_StoneFrameTile-Top", true);
	self.Bottom:SetAtlas("_StoneFrameTile-Bottom", true);
	self.Left:SetAtlas("!StoneFrameTile-Left", true);
	self.Right:SetAtlas("!StoneFrameTile-Left", true);
	self.GarrCorners.TopLeftGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);
	self.GarrCorners.TopRightGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);
	self.GarrCorners.BottomLeftGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);
	self.GarrCorners.BottomRightGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);

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
		frame.BaseFrameBackground:SetAtlas("ClassHall_StoneFrame-BackgroundTile");
		frame.BaseFrameLeft:SetAtlas("!ClassHall_InfoBoxMission-Left");
		frame.BaseFrameRight:SetAtlas("!ClassHall_InfoBoxMission-Left");
		frame.BaseFrameTop:SetAtlas("_ClassHall_InfoBoxMission-Top");
		frame.BaseFrameBottom:SetAtlas("_ClassHall_InfoBoxMission-Top");
		frame.BaseFrameTopLeft:SetAtlas("ClassHall_InfoBoxMission-Corner");
		frame.BaseFrameTopRight:SetAtlas("ClassHall_InfoBoxMission-Corner");
		frame.BaseFrameBottomLeft:SetAtlas("ClassHall_InfoBoxMission-Corner");
		frame.BaseFrameBottomRight:SetAtlas("ClassHall_InfoBoxMission-Corner");
	end

	self.FollowerList.HeaderLeft:SetAtlas("ClassHall_ParchmentHeaderSelect-End-2", true);
	self.FollowerList.HeaderLeft:SetPoint("BOTTOMLEFT", self.FollowerList, "TOPLEFT", 30, -8);

	self.FollowerList.HeaderRight:SetAtlas("ClassHall_ParchmentHeaderSelect-End-2", true);
	self.FollowerList.HeaderMid:SetAtlas("_ClassHall_ParchmentHeaderSelect-Mid", true);
	self.FollowerList.HeaderMid:SetPoint("LEFT", self.FollowerList.HeaderLeft, "RIGHT");
	self.FollowerList.HeaderMid:SetPoint("RIGHT", self.FollowerList.HeaderRight, "LEFT");
	self.FollowerList.HeaderMid:SetHorizTile(false);
	self.FollowerList.HeaderMid:SetWidth(110);

	self.BackgroundTile:SetAtlas("ClassHall_InfoBoxMission-BackgroundTile");

	local styleData = covenantGarrisonStyleData;

	SetupTabOffset(self);
	SetupTitleText(self, styleData);
	SetupMissionList(self, styleData);
	SetupFollowerList(self, styleData);
	SetupBorder(self, styleData);
end

function CovenantMission:UpdateMissionParty(followers)
	for followerIndex = 1, #followers do
		local followerFrame = followers[followerIndex];
		if ( followerFrame.info ) then
			local followerInfo = C_Garrison.GetFollowerInfo(followerFrame.info.followerID);
			if ( followerInfo and followerInfo.status == GARRISON_FOLLOWER_IN_PARTY ) then
				self:SetFollowerPortrait(followerFrame, followerInfo, true);
			else
				self:RemoveFollowerFromMission(followerFrame, true);
				for i = 1 , #followerFrame.Abilities do
					followerFrame.Abilities[i]:Hide();
				end
			end

			local autoSpellAbilities = C_Garrison.GetFollowerAutoCombatSpells(followerFrame.info.followerID);
			local numAbilities = #autoSpellAbilities;

			for i = 1, numAbilities do
				if (not followerFrame.Abilities[i]) then
						followerFrame.Abilities[i] = CreateFrame("Frame", nil, followerFrame, "CovenantMissionAutoSpellAbilityTemplate");
						followerFrame.Abilities[i]:SetPoint("LEFT", followerFrame.Abilities[i - 1], "RIGHT", 16, 0);
				end

				local autoSpellAbilityFrame = followerFrame.Abilities[i];
				autoSpellAbilityFrame.info = autoSpellAbilities[i];
				autoSpellAbilityFrame.Icon:SetTexture(autoSpellAbilities[i].icon)
				autoSpellAbilityFrame:Show();
			end

			for i = numAbilities + 1, #followerFrame.Abilities do
				followerFrame.Abilities[i]:Hide();
			end

			self:GetMissionPage():UpdateFollowerDurability(followerFrame);
		end
	end
end

function CovenantMission:RemoveFollowerFromMission(frame, updateValues)
	GarrisonFollowerMission.RemoveFollowerFromMission(self, frame, updateValues);

	frame.info = nil;
	if frame.Abilities then
		for i = 1, #frame.Abilities do
			frame.Abilities[i]:Hide();
		end
	end
end

---------------------------------------------------------------------------------
--- Mission Page Follower Mixin                                               ---
---------------------------------------------------------------------------------

CovenantFollowerMissionPageMixin = { }

function CovenantFollowerMissionPageMixin:AddFollower(followerID)
	local missionFrame = self:GetParent():GetParent();
	for i = 1, #self.Followers do
		local followerFrame = self.Followers[i];
		if ( not followerFrame.info ) then
			local followerInfo = C_Garrison.GetFollowerInfo(followerID);
			followerInfo.autoSpellAbilities = C_Garrison.GetFollowerAutoCombatSpells(followerID);
			missionFrame:AssignFollowerToMission(followerFrame, followerInfo);
			break;
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
	mainFrame.FollowerList:SetSortFuncs(GarrisonGarrisonFollowerList_DefaultSort, GarrisonFollowerList_InitializeDefaultSort);

	self.lastUpdate = nil;
end

