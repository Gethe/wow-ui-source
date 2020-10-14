---------------------------------------------------------------------------------
--- Garrison Follower Options				                                  ---
---------------------------------------------------------------------------------

-- These are follower options that depend on this AddOn being loaded, and so they can't be set in GarrisonBaseUtils.
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_9_0].missionFollowerSortFunc =  GarrisonFollowerList_DefaultMissionSort;
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_9_0].missionFollowerInitSortFunc = GarrisonFollowerList_InitializeDefaultMissionSort;

StaticPopupDialogs["COVENANT_MISSIONS_CONFIRM_ADVENTURE"] = {
	text = COVENANT_MISSIONS_START_MISSION_QUESTION,
	button1 = COVENANT_MISSIONS_CONFIRM_START_MISSION,
	button2 = CANCEL,
	OnAccept = function(self)
		GarrisonFollowerMission.OnClickStartMissionButton(self.data);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["COVENANT_MISSIONS_HEAL_CONFIRMATION"] = {
	text = COVENANT_MISSION_CONFIRM_HEAL_FOLLOWER,
	button1 = COVENANT_MISSIONS_CONFIRM_START_MISSION,
	button2 = CANCEL,
	OnAccept = function(self)
		C_Garrison.RushHealFollower(self.data.followerID);
		PlaySound(SOUNDKIT.UI_ADVENTURES_HEAL_FOLLOWER, nil, SOUNDKIT_ALLOW_DUPLICATES);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};



local covenantGarrisonStyleData =
{
	--Might do 4x for covenants, setting it up for this to be the possible way to express it, but also just because this'll be an easy way to replace the assets 1 to 1
	closeButtonBorder = "UI-Frame-Oribos-ExitButtonBorder",
	closeButtonBorderX = 0,
	closeButtonBorderY = 1,
	closeButtonX = 4,
	closeButtonY = 5,

	nineSliceLayout = "CovenantMissionFrame",
	materialFrameBG = "adventures_mission_materialframe",
	BackgroundTile = "Adventures-Missions-BG-02",
};

local function SetupMissionList(self, styleData)
	HybridScrollFrame_CreateButtons(self.MissionTab.MissionList.listScroll, "CovenantMissionListButtonTemplate", 13, -8, nil, nil, nil, -4);
	self.MissionTab.MissionList:Update();
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
	materialFrame.BG:SetAtlas(covenantGarrisonStyleData.materialFrameBG);
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

	self:SetupCompleteDialog();
	self:UpdateCurrencyInfo();
	self:UpdateTextures();
	PanelTemplates_SetNumTabs(self, 3);
	self:SelectTab(self:DefaultTab());

	self.FollowerList:SetSortFuncs(GarrisonFollowerList_DefaultSort, GarrisonFollowerList_InitializeDefaultSort);

	self:GetMissionPage().Board:Reset();

	self:GetMissionPage().Stage.EnemyPowerLabel:SetFontObjectsToTry("GameFontHighlight", "GameFontHighlightSmall");
	self:GetMissionPage().Stage.EnemyPowerValue:SetFontObjectsToTry("GameFontHighlight", "GameFontHighlightSmall");
	self:GetMissionPage().Stage.PartyPowerLabel:SetFontObjectsToTry("GameFontHighlight", "GameFontHighlightSmall");
	self:GetMissionPage().Stage.PartyPowerValue:SetFontObjectsToTry("GameFontHighlight", "GameFontHighlightSmall");

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
	"ADVENTURE_MAP_CLOSE",
};

local COVENANT_MISSION_STATIC_POPUPS = {
	"COVENANT_MISSIONS_CONFIRM_ADVENTURE",
	"COVENANT_MISSIONS_HEAL_CONFIRMATION",
};

function CovenantMission:OnEventMainFrame(event, ...)
	if event == "ADVENTURE_MAP_CLOSE" then
		self.CloseButton:Click();
	else
		GarrisonFollowerMission.OnEventMainFrame(self, event, ...);
	end
end

function CovenantMission:OnShowMainFrame()
	GarrisonMission.OnShowMainFrame(self);
	AdventureMapMixin.OnShow(self.MapTab);
	FrameUtil.RegisterFrameForEvents(self, COVENANT_MISSION_EVENTS); 

	self:RegisterCallback(CovenantMission.Event.OnFollowerFrameMouseUp, self.OnMouseUpMissionFollower, self);
	self:RegisterCallback(CovenantMission.Event.OnFollowerFrameDragStart, self.OnFollowerFrameDragStart, self);
	self:RegisterCallback(CovenantMission.Event.OnFollowerFrameDragStop, self.OnFollowerFrameDragStop, self);
	self:RegisterCallback(CovenantMission.Event.OnFollowerFrameReceiveDrag, self.OnFollowerFrameReceiveDrag, self);

	if (self.FollowerList.followerType ~= self.followerTypeID) then
		self.FollowerList:Initialize(self.followerTypeID);
	end

	self:SetupTabs();

	self:UpdateCurrency();

	PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_OPEN);
end

function CovenantMission:OnHideMainFrame()
	GarrisonFollowerMission.OnHideMainFrame(self);
	AdventureMapMixin.OnHide(self.MapTab);
	FrameUtil.UnregisterFrameForEvents(self, COVENANT_MISSION_EVENTS);

	self:UnregisterCallback(CovenantMission.Event.OnFollowerFrameMouseUp, self);
	self:UnregisterCallback(CovenantMission.Event.OnFollowerFrameDragStart, self);
	self:UnregisterCallback(CovenantMission.Event.OnFollowerFrameDragStop, self);
	self:UnregisterCallback(CovenantMission.Event.OnFollowerFrameReceiveDrag, self);

	self:HideStaticPopups();
	C_AdventureMap.Close(); --Opening the table implicitly opens an Adventure Map, this clears the npc on it.
end

function CovenantMission:ShouldShowMissionsAndFollowersTabs()
	return C_Garrison.IsAtGarrisonMissionNPC();
end

function CovenantMission:HideStaticPopups() 
	for _, popup in ipairs(COVENANT_MISSION_STATIC_POPUPS) do
		StaticPopup_Hide(popup);
	end
end

function CovenantMission:SelectTab(id)
	GarrisonFollowerMission.SelectTab(self, id);
	self.BackgroundTile:SetShown(id ~= 3);
	self:HideStaticPopups();
end

function CovenantMission:CloseMission()
	GarrisonMission.CloseMission(self);
	self:HideStaticPopups();
end

function CovenantMission:SetupTabs()
   local tabList = { };
   local validTabs = { };
   local defaultTab;

   local lastShowMissionsAndFollowersTabs = self.lastShowMissionsAndFollowersTabs;
   	if self:ShouldShowMissionsAndFollowersTabs() then
		table.insert(tabList, 1);
		table.insert(tabList, 2);
		validTabs[1] = true;
		validTabs[2] = true;
		self.lastShowMissionsAndFollowersTabs = true;
		defaultTab = 1;
	else
		self.lastShowMissionsAndFollowersTabs = false;
	end

	-- If we have completed all sandbox choice quests, hide the adventure map
	if ((#tabList == 0) or C_Garrison.ShouldShowMapTab(GarrisonFollowerOptions[self.followerTypeID].garrisonType)) then
		table.insert(tabList, 3);
		validTabs[3] = true;
		if (not defaultTab) then
			defaultTab = 3;
		end
	end

   self.Tab1:Hide();
   self.Tab2:Hide();
   self.Tab3:Hide();

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
	
	local missionDeploymentInfo =  C_Garrison.GetMissionDeploymentInfo(missionInfo.missionID);
	missionPage.environment = missionDeploymentInfo.environment;
	self:SetEnvironmentTexture(missionDeploymentInfo.environmentTexture);
	missionPage.EncounterIcon:SetEncounterInfo(missionInfo.encounterIconInfo);
	local enemies = missionDeploymentInfo.enemies;
	self:SetEnemies(missionPage, enemies);
	self:UpdateEnemyPower(missionPage, enemies);
	self:UpdateAllyPower(missionPage);
	self:UpdateMissionData(missionPage);
end

function CovenantMission:UpdateEnemyPower(missionPage, enemies)
	local totalPower = 0;
	for _, enemy in ipairs(enemies) do
		totalPower = totalPower + enemy.attack;
		totalPower = totalPower + enemy.maxHealth;
	end

	self.enemyPowerLevel = totalPower;

	missionPage.Stage.EnemyPowerValue:SetText(BreakUpLargeNumbers(self.enemyPowerLevel));
	missionPage.Stage.EnemyPowerValue:Show();
end

function CovenantMission:UpdateAllyPower(missionPage)
	local partyPower = 0;

	for followerFrame in missionPage.Board:EnumerateFollowers() do
		if followerFrame.info then
			partyPower = partyPower + followerFrame.info.autoCombatantStats.attack;
			partyPower = partyPower + followerFrame.info.autoCombatantStats.currentHealth;
		end
	end

	local textColorCode = partyPower < self.enemyPowerLevel and RED_FONT_COLOR_CODE or YELLOW_FONT_COLOR_CODE;
	missionPage.Stage.PartyPowerValue:SetText(textColorCode .. BreakUpLargeNumbers(partyPower) .. FONT_COLOR_CODE_CLOSE);
	missionPage.Stage.PartyPowerValue:Show();
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
	EventRegistry:TriggerEvent("CovenantMission.CancelLoopingTargetingAnimation");
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

function CovenantMission:InitiateMissionCompletion(missionInfo)
	self:GetCompleteDialog():Hide();
	self.FollowerTab:Hide();
	self.FollowerList:Hide();
	self.MissionTab:Hide();
	HelpPlate_Hide();
	self.MissionComplete:Show();

	self.MissionComplete:SetCurrentMission(missionInfo);
	PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_VIEW_MISSION_REPORT);
end

function CovenantMission:GetPlacerFrame()
	return CovenantFollowerPlacer;
end

function CovenantMission:OnClickFollowerPlacerFrame(button, info)
	local soundKitToPlay = SOUNDKIT.UI_ADVENTURES_ADVENTURER_UNSLOTTED;
	if button == "LeftButton" then
		for followerFrame in self:GetMissionPage().Board:EnumerateFollowers() do
			if followerFrame:IsShown() and followerFrame:IsMouseOver() then
				self:AssignFollowerToMission(followerFrame, info);
				soundKitToPlay = nil;
			end
		end
	end
	
	if soundKitToPlay then
		PlaySound(soundKitToPlay, nil, SOUNDKIT_ALLOW_DUPLICATES);
	end
	self:ClearMouse();
end

function CovenantMission:SetPlacerFrame(placer, info, yOffset, soundKit)
	placer:SetFollowerGUID(info.followerID, info);
	self:LockPlacerToMouse(placer);

	if soundKit then
		PlaySound(soundKit, nil, SOUNDKIT_ALLOW_DUPLICATES);
	else
		PlaySound(SOUNDKIT.UI_ADVENTURES_ADVENTURER_SELECTED, nil, SOUNDKIT_ALLOW_DUPLICATES);
	end
end

function CovenantMission:OnFollowerFrameDragStart(followerFrame)
	local info = followerFrame:GetInfo();
	if not info then
		return;
	end

	local covenantPlacer = self:GetPlacerFrame();
	self:SetPlacerFrame(covenantPlacer, info, yOffset, SOUNDKIT.UI_ADVENTURES_ADVENTURER_SELECTED);
	covenantPlacer.dragStartFrame = followerFrame;

	local function CovenantPlacerFrame_OnHide()
		covenantPlacer.dragStartFrame = nil;
		covenantPlacer:SetScript("OnHide", nil);
	end
	
	covenantPlacer:SetScript("OnHide", CovenantPlacerFrame_OnHide);
	self:RemoveFollowerFromMission(followerFrame);
end

function CovenantMission:OnFollowerFrameDragStop(followerFrame)
	local covenantPlacer = self:GetPlacerFrame();
	if covenantPlacer.info then
		GarrisonShowFollowerPlacerFrame(self, covenantPlacer.info);
	else	
		self:ClearMouse();
	end
	
end

function CovenantMission:OnFollowerFrameReceiveDrag(followerFrame)
	local covenantPlacer = self:GetPlacerFrame();
	if covenantPlacer.info then
		self:AssignFollowerToMission(followerFrame, covenantPlacer.info);
	end
	self:ClearMouse();
end

function CovenantMission:GetPlacerUpdate()
	local covenantPlacer = self:GetPlacerFrame();

	local function PlacerFrameUpdate(placerFrame)
		GarrisonFollowerPlacer_OnUpdate(placerFrame);

		local missionPage = self:GetMissionPage();
		local hoverBoardIndex = missionPage.Board:GetHoverTargetingBoardIndex(placerFrame);
		if hoverBoardIndex ~= self.casterBoardIndex then
			if hoverBoardIndex == nil then
				self.casterBoardIndex = hoverBoardIndex;
				placerFrame:HideSupportColorationRings();
				EventRegistry:TriggerEvent("CovenantMission.CancelLoopingTargetingAnimation");
				return;
			end

			local missionID = missionPage.missionInfo.missionID;
			if covenantPlacer.info.autoCombatSpells[1] == nil then
				return;
			end

			self.casterBoardIndex = hoverBoardIndex;
			local useLoop = true;
			missionPage.Board:TriggerTargetingReticles(C_Garrison.GetAutoMissionTargetingInfo(missionID, covenantPlacer.info.garrFollowerID, hoverBoardIndex), useLoop);
			placerFrame:ShowSupportColorationRings();
		end
	end

	return PlacerFrameUpdate;
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

function CovenantMission:UpdateCurrencyInfo()
	local _, secondaryCurrency = C_Garrison.GetCurrencyTypes(GarrisonFollowerOptions[self.followerTypeID].garrisonType);
	local currencyTexture = C_CurrencyInfo.GetCurrencyInfo(secondaryCurrency).iconFileID;

	self.MissionTab.MissionPage.CostFrame.CostIcon:SetTexture(currencyTexture);
	self.MissionTab.MissionPage.CostFrame.CostIcon:SetSize(18, 18);
	self.MissionTab.MissionPage.CostFrame.Cost:SetPoint("RIGHT", self.MissionTab.MissionPage.CostFrame.CostIcon, "LEFT", -8, -1);

	self.FollowerTab.HealFollowerFrame.CostFrame.CostIcon:SetTexture(currencyTexture);
	self.FollowerTab.HealFollowerFrame.CostFrame.CostIcon:SetSize(18, 18);
	self.FollowerTab.HealFollowerFrame.CostFrame.Cost:SetPoint("RIGHT", self.FollowerTab.HealFollowerFrame.CostFrame.CostIcon, "LEFT", -8, -1);

	SetupMaterialFrame(self.FollowerList.MaterialFrame, secondaryCurrency, currencyTexture);
	SetupMaterialFrame(self.MissionTab.MissionList.MaterialFrame, secondaryCurrency, currencyTexture);
	self:GetCompleteDialog().BorderFrame.ViewButton:SetPoint("BOTTOM", 0, 88);

	self:UpdateCurrency();
end

function CovenantMission:UpdateTextures()
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
	local missionID = missionPage.missionInfo.missionID;

	if previousFollowerID then
		C_Garrison.RemoveFollowerFromMission(missionID, previousFollowerID);
		frame:SetEmpty();
	end
	
	if info.isAutoTroop or C_Garrison.GetFollowerStatus(info.followerID) ~= GARRISON_FOLLOWER_IN_PARTY then
		if not C_Garrison.AddFollowerToMission(missionID, info.followerID, frame.boardIndex) then
			return false;
		end
	end

	if info.autoCombatSpells[1] ~= nil then
		self.casterSpellIndex = frame.boardIndex;
		self.lastAssignedSpell = info.autoCombatSpells[1].autoCombatSpellID;
		local abilityTargetInfos = C_Garrison.GetAutoMissionTargetingInfo(missionID, info.garrFollowerID, self.casterSpellIndex);
		missionPage.Board:TriggerTargetingReticles(abilityTargetInfos);
	end

	frame:SetFollowerGUID(info.followerID, info);

	-- We're dragging this follower from another slot.
	local covenantPlacer = self:GetPlacerFrame();
	if covenantPlacer.dragStartFrame and previousFollowerInfo then
		self:AssignFollowerToMission(covenantPlacer.dragStartFrame, previousFollowerInfo);
	end

	self:UpdateAllyPower(missionPage);
	self:UpdateMissionData(missionPage);

	PlaySound(SOUNDKIT.UI_ADVENTURES_ADVENTURER_SLOTTED, nil, SOUNDKIT_ALLOW_DUPLICATES);

	return true;
end

function CovenantMission:UpdateMissionParty()
	local missionPage = self:GetMissionPage();
	local boardState = {};
	
	if missionPage.missionInfo then
		boardState = C_Garrison.GetAutoMissionBoardState(missionPage.missionInfo.missionID);
	end

	missionPage.Board:UpdateBoardState(boardState);
end
function CovenantMission:RemoveFollowerFromMission(frame, updateValues)
	local missionPage = self:GetMissionPage();

	local followerID = frame:GetFollowerGUID();
	if followerID then
		C_Garrison.RemoveFollowerFromMission(missionPage.missionInfo.missionID, followerID);
	end

	if frame.autoCombatSpells and frame.autoCombatSpells[1].autoCombatSpellID == self.lastAssignedSpell then
		EventRegistry:TriggerEvent("CovenantMission.CancelTargetingAnimation");
	end

	frame:SetEmpty();

	self:UpdateAllyPower(missionPage);
	self:UpdateMissionData(missionPage);

	if updateValues then
		PlaySound(SOUNDKIT.UI_ADVENTURES_ADVENTURER_UNSLOTTED, nil, SOUNDKIT_ALLOW_DUPLICATES);
	end
end

function CovenantMission:GetNumMissionFollowers()
	local numFollowers = 0;
	for followerFrame in self:GetMissionPage().Board:EnumerateFollowers() do
		if followerFrame:GetFollowerGUID()  and not (followerFrame.info.isTroop or followerFrame.info.isAutoTroop) then
			numFollowers = numFollowers + 1;
		end
	end

	return numFollowers;
end

function CovenantMission:GetStartMissionButtonFrame(missionPage)
	return missionPage.StartMissionFrame.ButtonFrame;
end

function CovenantMission:GenerateHelpTipInfo()
	return {
		text = COVENANT_MISSIONS_MISSION_PROGRESS,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_GARRISON_LANDING,
		targetPoint = HelpTip.Point.LeftEdgeCenter,
		offsetX = -5,
		checkCVars = true,
	};
end

function CovenantMission:OnClickStartMissionButton()
	StaticPopup_Show("COVENANT_MISSIONS_CONFIRM_ADVENTURE", nil, nil, self);
end

---------------------------------------------------------------------------------
--- Mission Page Follower Mixin                                               ---
---------------------------------------------------------------------------------

CovenantFollowerMissionPageMixin = { }

function CovenantFollowerMissionPageMixin:AddFollower(followerID)
	local missionFrame = self:GetParent():GetParent();

	local followerInfo = C_Garrison.GetFollowerInfo(followerID);
	followerInfo.autoCombatSpells = C_Garrison.GetFollowerAutoCombatSpells(followerID, followerInfo.level);

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
			puck:SetHighlight(false);
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
