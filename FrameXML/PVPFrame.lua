-- PVP Global Lua Constants

WORLD_PVP_TIME_UPDATE_IINTERVAL = 1;
MAX_BATTLEFIELD_QUEUES = 2;

BATTLEFIELD_TIMER_DELAY = 3;
BATTLEFIELD_TIMER_THRESHOLDS = {600, 300, 60, 15};
BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;


CURRENT_BATTLEFIELD_QUEUES = {};
PREVIOUS_BATTLEFIELD_QUEUES = {};
MAX_BATTLEFIELD_QUEUES = 2;
MAX_WORLD_PVP_QUEUES = 1;


MAX_ARENA_TEAMS = 3;
MAX_ARENA_TEAM_MEMBERS = 10;
MAX_ARENA_TEAM_MEMBERS_SHOWN = 6;
MAX_ARENA_TEAM_NAME_WIDTH = 310;


MAX_ARENA_TEAM_MEMBER_WIDTH = 320;
MAX_ARENA_TEAM_MEMBER_SCROLL_WIDTH = 300;

NUM_DISPLAYED_BATTLEGROUNDS = 5;

NO_ARENA_SEASON = 0;


BG_BUTTON_WIDTH = 320;
BG_BUTTON_SCROLL_WIDTH = 298;

local BATTLEFIELD_FRAME_FADE_TIME = 0.15


local PVPHONOR_TEXTURELIST = {};
PVPHONOR_TEXTURELIST[1] = "Interface\\PVPFrame\\PvpBg-AlteracValley";
PVPHONOR_TEXTURELIST[2] = "Interface\\PVPFrame\\PvpBg-WarsongGulch";
PVPHONOR_TEXTURELIST[3] = "Interface\\PVPFrame\\PvpBg-ArathiBasin";
PVPHONOR_TEXTURELIST[7] = "Interface\\PVPFrame\\PvpBg-EyeOfTheStorm";
PVPHONOR_TEXTURELIST[9] = "Interface\\PVPFrame\\PvpBg-StrandOfTheAncients";
PVPHONOR_TEXTURELIST[30] = "Interface\\PVPFrame\\PvpBg-IsleOfConquest";
PVPHONOR_TEXTURELIST[32] = "Interface\\PVPFrame\\PvpRandomBg";
PVPHONOR_TEXTURELIST[108] = "Interface\\PVPFrame\\PvpBg-TwinPeaks";
PVPHONOR_TEXTURELIST[120] = "Interface\\PVPFrame\\PvpBg-Gilneas";



local PVPWORLD_TEXTURELIST = {};
PVPWORLD_TEXTURELIST[1] = "Interface\\PVPFrame\\PvpBg-Wintergrasp";
PVPWORLD_TEXTURELIST[21] = "Interface\\PVPFrame\\PvpBg-TolBarad";

local PVPWORLD_DESCRIPTIONS = {};
PVPWORLD_DESCRIPTIONS[1] = WINTERGRASP_DESCRIPTION;
PVPWORLD_DESCRIPTIONS[21] = TOL_BARAD_DESCRIPTION;

ARENABANNER_SMALLFONT = "GameFontNormalSmall"


---- NEW PVP FRAME FUNCTIONS
---- NEW PVP FRAME FUNCTIONS


function PVP_GetSelectedArenaTeam()
	if PVPFrame:IsVisible() and PVPTeamManagementFrame.selectedTeam then
		return PVPTeamManagementFrame.selectedTeam:GetID();
	end
	return nil;
end

function PVP_ArenaTeamFrame()
	return PVPTeamManagementFrame;
end


function PVPMicroButton_SetPushed()
	PVPMicroButtonTexture:SetPoint("TOP", PVPMicroButton, "TOP", 5, -31);
	PVPMicroButtonTexture:SetAlpha(0.5);
end

function PVPMicroButton_SetNormal()
	PVPMicroButtonTexture:SetPoint("TOP", PVPMicroButton, "TOP", 6, -30);
	PVPMicroButtonTexture:SetAlpha(1.0);
end


function TogglePVPFrame()
	if ( UnitLevel("player") >= SHOW_PVP_LEVEL ) then
			ToggleFrame(PVPFrame);
	end
end


function PVPFrame_OnShow(self)
	PVPMicroButton_SetPushed();
	UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	if (self.lastSelectedTab) then
		PVPFrame_TabClicked(self.lastSelectedTab);
	else
		PVPFrame_TabClicked(PVPFrameTab1);
	end
	RequestRatedBattlegroundInfo();
	RequestPVPOptionsEnabled();
end

function PVPFrame_OnHide()
	PVPMicroButton_SetNormal();
	UpdateMicroButtons();
	PlaySound("igCharacterInfoClose");
end



function PVPFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 3)
	PVPFrame_TabClicked(PVPFrameTab1);
	SetPortraitToTexture(PVPFramePortrait,"Interface\\BattlefieldFrame\\UI-Battlefield-Icon");
	
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_LEVEL");
	
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");

	self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_REQUEST_RESPONSE");
	self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_INVITE");
	self:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE");
	self:RegisterEvent("BATTLEFIELD_MGR_EJECT_PENDING");
	self:RegisterEvent("BATTLEFIELD_MGR_EJECTED");
	self:RegisterEvent("BATTLEFIELD_MGR_ENTERED");
	self:RegisterEvent("WARGAME_REQUESTED");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("BATTLEFIELDS_CLOSED");
	self:RegisterEvent("PVP_TYPES_ENABLED");
	
	PVPFrame.timerDelay = 0;
	
	PVPFrameTab2.info = ARENA_CONQUEST_INFO;
	PVPFrameTab3.info = ARENA_TEAM_INFO;
end



--function PVPFrame_Update()
	--PVPHonor_UpdateBattlegrounds()
	--PVPConquestFrame_Update(PVPConquestFrame);
--end

function PVPFrame_OnEvent(self, event, ...)
	if  event == "PLAYER_ENTERING_WORLD" then
		FauxScrollFrame_SetOffset(PVPHonorFrameTypeScrollFrame, 0);
		FauxScrollFrame_OnVerticalScroll(PVPHonorFrameTypeScrollFrame, 0, 16, PVPHonor_UpdateBattlegrounds); --We may be changing brackets, so we don't want someone to see an outdated version of the data.
		MiniMapBattlefieldDropDown_OnLoad();
		PVP_UpdateStatus(false, nil);
	elseif event == "CURRENCY_DISPLAY_UPDATE" then
		PVPFrame_UpdateCurrency(self);
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED") then
		local arg1 = ...
		PVP_UpdateStatus(false, arg1);
	--PVPFrame_Update();
	elseif ( event == "BATTLEFIELD_MGR_QUEUE_REQUEST_RESPONSE" ) then
		local battleID, accepted, warmup, inArea, loggingIn, areaName = ...;
		if(not loggingIn) then
			if(accepted) then
				if(warmup) then
					StaticPopup_Show("BFMGR_CONFIRM_WORLD_PVP_QUEUED_WARMUP", areaName, nil, arg1);
				elseif (inArea) then
					StaticPopup_Show("BFMGR_EJECT_PENDING", areaName, nil, arg1);
				else
					StaticPopup_Show("BFMGR_CONFIRM_WORLD_PVP_QUEUED", areaName, nil, arg1);
				end
			else
				StaticPopup_Show("BFMGR_DENY_WORLD_PVP_QUEUED", areaName, nil, arg1);
			end
		end
		PVP_UpdateStatus(false);
		--PVPFrame_Update();
	elseif ( event == "BATTLEFIELD_MGR_EJECT_PENDING" ) then
		local battleID, remote, areaName = ...;
		if(remote) then
			local dialog = StaticPopup_Show("BFMGR_EJECT_PENDING_REMOTE", areaName, nil, arg1);
		else
		local dialog = StaticPopup_Show("BFMGR_EJECT_PENDING", areaName, nil, arg1);
		end
		PVP_UpdateStatus(false);
		--PVPFrame_Update();
	elseif ( event == "BATTLEFIELD_MGR_EJECTED" ) then
		local battleID, playerExited, relocated, battleActive, lowLevel, areaName = ...;
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE");
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE_WARMUP");
		StaticPopup_Hide("BFMGR_INVITED_TO_ENTER");
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		if(lowLevel) then
			local dialog = StaticPopup_Show("BFMGR_PLAYER_LOW_LEVEL", areaName, nil, arg1);
		elseif (playerExited and battleActive and not relocated) then
			local dialog = StaticPopup_Show("BFMGR_PLAYER_EXITED_BATTLE", areaName, nil, arg1);
		end
		PVP_UpdateStatus(false);
		--PVPFrame_Update();
	elseif ( event == "BATTLEFIELD_MGR_QUEUE_INVITE" ) then
		local battleID, warmup, areaName = ...;
		if(warmup) then
			local dialog = StaticPopup_Show("BFMGR_INVITED_TO_QUEUE_WARMUP", areaName, nil, battleID);
		else
			local dialog = StaticPopup_Show("BFMGR_INVITED_TO_QUEUE", areaName, nil, battleID);
		end
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus(false);
		--PVPFrame_Update();
	elseif ( event == "BATTLEFIELD_MGR_ENTRY_INVITE" ) then
		local battleID, areaName = ...;
		local dialog = StaticPopup_Show("BFMGR_INVITED_TO_ENTER", areaName, nil, battleID);
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus(false);
		--PVPFrame_Update();
	elseif ( event == "BATTLEFIELD_MGR_ENTERED" ) then
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE");
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE_WARMUP");
		StaticPopup_Hide("BFMGR_INVITED_TO_ENTER");
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus(false);
		--PVPFrame_Update();
	elseif ( event == "WARGAME_REQUESTED" ) then
		local challengerName, bgName, timeout = ...;
		PVPFramePopup_SetupPopUp(event, challengerName, bgName, timeout);
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		--PVPFrame_Update();
	elseif ( event == "PVP_RATED_STATS_UPDATE" ) then
		local _, _, pointsThisWeek, maxPointsThisWeek = GetPersonalRatedBGInfo();
		PVPFrameConquestBar:SetMinMaxValues(0, maxPointsThisWeek);
		PVPFrameConquestBar:SetValue(pointsThisWeek);
		PVPFrameConquestBar.pointText:SetText(pointsThisWeek.."/"..maxPointsThisWeek);
	elseif ( event == "BATTLEFIELDS_SHOW" )  then
		local isArena, bgId = ...;
		if isArena then
			PVPFrameTab2:Click();
		else
			local numWorldPvP = GetNumWorldPVPAreas();
			local numBgs = GetNumBattlegroundTypes();
			local numTypes = numWorldPvP + numBgs ;
			local numList = 0;
			local index;
			for i=1,numTypes do
				if i <=  numWorldPvP then
					local _, localizedName, _, _, _, canEnter = GetWorldPVPAreaInfo(i);
					if ( localizedName and canEnter ) then
						numList = numList + 1;
					end
				else
					local localizedName, canEnter, _, _, BattleGroundID = GetBattlegroundInfo(i-numWorldPvP);
					if ( localizedName and canEnter ) then
						if ( bgId == BattleGroundID ) then
							PVPHonorFrame.selectedIsWorldPvp = false;
							PVPHonorFrame.selectedPvpID = i-numWorldPvP;
							PVPHonorFrame_ResetInfo();
							PVPHonorFrame_UpdateGroupAvailable();
							index = i-numWorldPvP;
						end
						numList = numList + 1;
					end
				end
			end
			PVPFrameTab1:Click();
			if index then
				local scroll = min(index+1, numList - NUM_DISPLAYED_BATTLEGROUNDS);
				PVPHonorFrameTypeScrollFrameScrollBar:SetMinMaxValues(0, numList*16); 
				PVPHonorFrameTypeScrollFrameScrollBar:SetValue(scroll*16);
			end
		end	
		if not self:IsShown() then
			TogglePVPFrame();
		end
	elseif ( event == "BATTLEFIELDS_CLOSED" )  then
		if self:IsShown() then
			TogglePVPFrame();
		end
	elseif ( event == "PVP_TYPES_ENABLED" )  then
		self.wargamesEnable, self.ratedBGsEnabled, self.ratedArenasEnabled = ...;
		if not self.wargamesEnable then
			PVPHonorFrameWarGameButton:Hide();
		else
			PVPHonorFrameWarGameButton:Show();
		end
	elseif ( event == "UNIT_LEVEL" ) then
		local unit = ...;
		if ( unit == "player" and UnitLevel(unit) == SHOW_CONQUEST_LEVEL ) then
			if ( PVPFrameTab2:IsShown() ) then
				PVPFrame_TabClicked(PVPFrameTab2);
			elseif ( PVPFrameTab3:IsShown() ) then
				PVPFrame_TabClicked(PVPFrameTab3);
			end
		end
	end
end



function PVPFrame_UpdateCurrency(self, currency)
	if ( not currency and self.lastSelectedTab ) then
		local index = self.lastSelectedTab:GetID()	
		if index == 1 then -- Honor Page	
			_, currency = GetCurrencyInfo(HONOR_CURRENCY);
		elseif index == 2 then -- Conquest 
			_, currency = GetCurrencyInfo(CONQUEST_CURRENCY);
		elseif index == 3 then -- Arena Management
			_, currency = GetCurrencyInfo(CONQUEST_CURRENCY);
		end
	end
	
	if ( currency ) then
		local _, _, pointsThisWeek, maxPointsThisWeek = GetPersonalRatedBGInfo();
		PVPFrameConquestBar:SetMinMaxValues(0, maxPointsThisWeek);
		PVPFrameConquestBar:SetValue(pointsThisWeek);
		PVPFrameConquestBar.pointText:SetText(pointsThisWeek.."/"..maxPointsThisWeek);
		PVPFrameTypeValue:SetText(currency);
		PVPFrameTypeLabel:Show();
		PVPFrameTypeIcon:Show();
		PVPFrameTypeValue:Show();
	else
		PVPFrameTypeLabel:Hide();
		PVPFrameTypeIcon:Hide();
		PVPFrameTypeValue:Hide();
	end
end



function PVPFrame_JoinClicked(self, isParty, wargame)
	local tabID =  PVPFrame.lastSelectedTab:GetID();
	if tabID == 1 then --Honor BGs
		if wargame then
			StartWarGame();
		else
			if PVPHonorFrame.selectedIsWorldPvp then
				local pvpID = GetWorldPVPAreaInfo(PVPHonorFrame.selectedPvpID);
				BattlefieldMgrQueueRequest(pvpID); 
			else 
				JoinBattlefield(1, isParty);
			end
		end
	elseif tabID == 2 then
		if PVPConquestFrame.mode == "Arena" then
			JoinArena();
		else -- rated bg
			JoinRatedBattlefield();
		end
	elseif tabID == 3 then	
		StaticPopup_Show("ADD_TEAMMEMBER", nil, nil, PVPTeamManagementFrame.selectedTeam:GetID());
	end
end

function PVPFrame_TabClicked(self)
	local index = self:GetID()	
	PanelTemplates_SetTab(self:GetParent(), index);
	self:GetParent().lastSelectedTab = self;
	PVPFrameRightButton:Hide();
	PVPFrame.panel1:Hide();	
	PVPFrame.panel2:Hide();	
	PVPFrame.panel3:Hide();
	
	PVPFrame.lowLevelFrame:Hide();
	PVPFrameLeftButton:Show();
	
	
	PVPFrameTitleText:SetText(self:GetText());	
	PVPFrame.Inset:SetPoint("TOPLEFT", PANEL_INSET_LEFT_OFFSET, PANEL_INSET_ATTIC_OFFSET);
	PVPFrame.topInset:Hide();
	local currency = 0;
	local factionGroup = UnitFactionGroup("player");
	
	if index == 1 then -- Honor Page
		PVPFrame.panel1:Show();
		PVPFrameRightButton:Show();
		PVPFrameLeftButton:SetText(BATTLEFIELD_JOIN);
		PVPFrameLeftButton:Enable();
		PVPFrameTypeLabel:SetText(HONOR);
		PVPFrameTypeLabel:SetPoint("TOPRIGHT", -180, -38);
		PVPFrameConquestBar:Hide();
		PVPFrameTypeIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor-"..factionGroup);
		_, currency = GetCurrencyInfo(HONOR_CURRENCY);
	elseif UnitLevel("player") < SHOW_CONQUEST_LEVEL then
		self:GetParent().lastSelectedTab = nil;
		PVPFrameLeftButton:Hide();
		PVPFrame.lowLevelFrame.title:SetText(self:GetText());
		PVPFrame.lowLevelFrame.error:SetFormattedText(PVP_CONQUEST_LOWLEVEL, self:GetText());
		PVPFrame.lowLevelFrame.description:SetText(self.info);
		PVPFrame.lowLevelFrame:Show();
		currency = nil;
	elseif GetCurrentArenaSeason() == NO_ARENA_SEASON then
		self:GetParent().lastSelectedTab = nil;
		PVPFrameLeftButton:Hide();
		PVPFrame.lowLevelFrame.title:SetText(self:GetText());
		PVPFrame.lowLevelFrame.error:SetText("");
		PVPFrame.lowLevelFrame.description:SetText(ARENA_MASTER_NO_SEASON_TEXT);
		PVPFrame.lowLevelFrame:Show();
		PVPFrameConquestBar:Show();
		PVPFrameTypeIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);		
		_, currency = GetCurrencyInfo(CONQUEST_CURRENCY);
	elseif index == 2 then -- Conquest 
		PVPFrame.panel2:Show();	
		PVPFrameLeftButton:SetText(BATTLEFIELD_JOIN);
		PVPFrameTypeLabel:SetText(PVP_CONQUEST);
		PVPFrameTypeLabel:SetPoint("TOPRIGHT", -195, -38);
		PVPFrameConquestBar:Show();
		PVPFrameTypeIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);
		_, currency = GetCurrencyInfo(CONQUEST_CURRENCY);
	elseif index == 3 then -- Arena Management
		PVPFrameLeftButton:SetText(ADDMEMBER_TEAM);
		PVPFrameLeftButton:Disable();
		PVPFrame.panel3:Show();	
		PVPFrameTypeLabel:SetText(PVP_CONQUEST);
		PVPFrameTypeLabel:SetPoint("TOPRIGHT", -195, -38);
		PVPFrameConquestBar:Show();		
		PVPFrame.topInset:Show();
		PVPFrame.Inset:SetPoint("TOPLEFT", PANEL_INSET_LEFT_OFFSET, -281);
		PVPFrameTypeIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);
		_, currency = GetCurrencyInfo(CONQUEST_CURRENCY);
	end
	
	PVPFrame_UpdateCurrency(self, currency);
end



-- Honor Frame functions (the new BG page)
-- Honor Frame functions (the new BG page)

function PVPHonor_UpdateWorldPVPTimer(self, elapsed)
	self.timeStep = self.timeStep + elapsed;
	if self.timeStep > WORLD_PVP_TIME_UPDATE_IINTERVAL then
		self.timeStep = 0;
		local _, name, isActive, canQueue, startTime = GetWorldPVPAreaInfo(self.worldIndex);
		if canQueue then
			self:Enable();
		else
			self:Disable();
			name = GRAY_FONT_COLOR_CODE..name;
		end
		if ( isActive ) then
			name = name.." ("..WINTERGRASP_IN_PROGRESS..")";
		elseif ( startTime > 0 ) then
			name = name.." ("..SecondsToTime(startTime)..")";
		end
		self.title:SetText(name);
	end
end


function PVPHonor_UpdateBattlegrounds()
	local frame;
	local localizedName, canEnter, isHoliday;
	local pvpID, isActive, canQueue, startTime;
	local tempString, isBig, isWorldPVP;
	
	local offset = FauxScrollFrame_GetOffset(PVPHonorFrameTypeScrollFrame);
	local currentFrameNum = 1;
	local availableBGs = 0;
	
	local numWorldPvP = GetNumWorldPVPAreas();
	local numBgs = GetNumBattlegroundTypes();
	local numTypes = numWorldPvP + numBgs ;
	
	for i=1,numTypes do
		frame = _G["PVPHonorFrameBgButton"..currentFrameNum];
		
		if  i <=  numWorldPvP then
			isHoliday = false;
			_, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i);
			pvpID = i;
			isWorldPVP = true;
		else
			pvpID = i-numWorldPvP;
			isActive = false;
			canQueue = true;
			startTime = -1;
			localizedName, canEnter, isHoliday = GetBattlegroundInfo(i-numWorldPvP);
			isWorldPVP = false
		end
		
		if ( localizedName and canEnter ) then
			if offset > 0 then
				offset = offset -1;
			elseif ( frame ) then
				frame.pvpID = pvpID;
				frame.localizedName = localizedName;
				frame.isWorldPVP = isWorldPVP;
				
				if canQueue then
					frame:Enable();
					if ( not PVPHonorFrame.selectedButtonIndex ) then
						frame:Click();
					end
				else
					frame:Disable();
					localizedName = GRAY_FONT_COLOR_CODE..localizedName;
				end
				tempString = localizedName;
				
				if isWorldPVP then
					frame:SetScript("OnUpdate", PVPHonor_UpdateWorldPVPTimer);
					frame.timeStep = 0;
					frame.worldIndex = i;
				else
					frame:SetScript("OnUpdate", nil);
				end
				
				if ( isHoliday ) then
					tempString = tempString.." ("..BATTLEGROUND_HOLIDAY..")";
				end
				
				if ( isActive ) then
					tempString = tempString.." ("..WINTERGRASP_IN_PROGRESS..")";
				elseif ( startTime > 0 ) then
					tempString = tempString.." ("..SecondsToTime(startTime)..")";
				end
				
				if PVPHonorFrame.selectedPvpID ==  frame.pvpID and PVPHonorFrame.selectedIsWorldPvp == isWorldPVP then
					frame:LockHighlight();
				else
					frame:UnlockHighlight();
				end
					
				frame.title:SetText(tempString);
				frame:Show();
				currentFrameNum = currentFrameNum + 1;
			end
			availableBGs = availableBGs + 1;
		end
	end
	
	if ( currentFrameNum <= NUM_DISPLAYED_BATTLEGROUNDS ) then
		isBig = true;	--Espand the highlight to cover where the scroll bar usually is.
	end
	
	for i=1,NUM_DISPLAYED_BATTLEGROUNDS do
		frame = _G["PVPHonorFrameBgButton"..i];
		if ( isBig ) then
			frame:SetWidth(BG_BUTTON_WIDTH);
		else
			frame:SetWidth(BG_BUTTON_SCROLL_WIDTH);
		end
	end
	
	for i=currentFrameNum,NUM_DISPLAYED_BATTLEGROUNDS do
		frame = _G["PVPHonorFrameBgButton"..i];
		frame:Hide();
	end
	
	PVPHonor_UpdateQueueStatus();
	
	PVPHonorFrame_UpdateGroupAvailable();
	FauxScrollFrame_Update(PVPHonorFrameTypeScrollFrame, availableBGs, NUM_DISPLAYED_BATTLEGROUNDS, 16);
end


function PVPHonor_ButtonClicked(self)
	local id = self:GetID();
	local name = self:GetName();
	name = strsub(name, 1, strlen(name)-1);
	
	for i=1,NUM_DISPLAYED_BATTLEGROUNDS do
		if ( id == i ) then
			_G[name..i]:LockHighlight();
		else
			_G[name..i]:UnlockHighlight();
		end
	end
	
	self:GetParent().selectedButtonIndex = id;
	self:GetParent().selectedIsWorldPvp = self.isWorldPVP;
	self:GetParent().selectedPvpID = self.pvpID;
	PVPHonorFrame_ResetInfo();
	PVPHonorFrame_UpdateGroupAvailable();
end



function PVPHonorFrame_ResetInfo()
	if not PVPHonorFrame.selectedIsWorldPvp then
		RequestBattlegroundInstanceInfo(PVPHonorFrame.selectedPvpID);
	end
	PVPHonor_UpdateInfo();
end


function PVPHonor_UpdateInfo()
	if PVPHonorFrame.selectedIsWorldPvp then
		local pvpID = GetWorldPVPAreaInfo(PVPHonorFrame.selectedPvpID);
		local mapDescription = PVPWORLD_DESCRIPTIONS[pvpID]
		if not mapDescription or mapDescription == "" then
			PVPHonorFrameInfoScrollFrameChildFrameDescription:SetText("Missing Map Description");
		else
			PVPHonorFrameInfoScrollFrameChildFrameDescription:SetText(mapDescription);
		end

		if(PVPWORLD_TEXTURELIST[pvpID]) then
			PVPHonorFrameBGTex:SetTexture(PVPWORLD_TEXTURELIST[pvpID]);
		end
		PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo:Hide();
		PVPHonorFrameInfoScrollFrameChildFrameDescription:Show();
	elseif PVPHonorFrame.selectedPvpID then
		local _, canEnter, isHoliday, isRandom, BattleGroundID, mapDescription = GetBattlegroundInfo(PVPHonorFrame.selectedPvpID);
		
		if(PVPHONOR_TEXTURELIST[BattleGroundID]) then
			PVPHonorFrameBGTex:SetTexture(PVPHONOR_TEXTURELIST[BattleGroundID]);
		end
		
		if ( isRandom or isHoliday ) then
			PVPHonor_UpdateRandomInfo();
			PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo:Show();
			PVPHonorFrameInfoScrollFrameChildFrameDescription:Hide();
		else
			if ( mapDescription ~= PVPHonorFrameInfoScrollFrameChildFrameDescription:GetText() ) then
				PVPHonorFrameInfoScrollFrameChildFrameDescription:SetText(mapDescription);
				PVPHonorFrameInfoScrollFrame:SetVerticalScroll(0);
			end
			
			PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo:Hide();
			PVPHonorFrameInfoScrollFrameChildFrameDescription:Show();
		end
	end
end

function PVPHonor_GetRandomBattlegroundInfo()
	return GetBattlegroundInfo(PVPHonorFrame.selectedPvpID);
end

function PVPHonor_UpdateRandomInfo()
	PVPQueue_UpdateRandomInfo(PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo, PVPHonor_GetRandomBattlegroundInfo);
end

function PVPHonor_UpdateQueueStatus()
	local queueStatus, queueMapName, queueInstanceID, frame;
	for i=1, NUM_DISPLAYED_BATTLEGROUNDS do
		frame = _G["PVPHonorFrameBgButton"..i];
		frame.status:Hide();
	end
	local factionTexture = "Interface\\PVPFrame\\PVP-Currency-"..UnitFactionGroup("player");
	for i=1, MAX_BATTLEFIELD_QUEUES do
		queueStatus, queueMapName, queueInstanceID = GetBattlefieldStatus(i);
		if ( queueStatus ~= "none" ) then
			for j=1, NUM_DISPLAYED_BATTLEGROUNDS do
				local frame = _G["PVPHonorFrameBgButton"..j];
				if ( frame.localizedName == queueMapName ) then
					if ( queueStatus == "queued" ) then
						frame.status.texture:SetTexture(factionTexture);
						frame.status.texture:SetTexCoord(0.0, 1.0, 0.0, 1.0);
						frame.status.tooltip = BATTLEFIELD_QUEUE_STATUS;
						frame.status:Show();
					elseif ( queueStatus == "confirm" ) then
						frame.status.texture:SetTexture("Interface\\CharacterFrame\\UI-StateIcon");
						frame.status.texture:SetTexCoord(0.45, 0.95, 0.0, 0.5);
						frame.status.tooltip = BATTLEFIELD_CONFIRM_STATUS;
						frame.status:Show();
					end
				end
			end
		end
	end
end

function PVPHonorFrame_OnLoad(self)
	self:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
end

function PVPHonorFrame_OnEvent(self, event, ...)
	if ( event == "PVPQUEUE_ANYWHERE_SHOW" ) then
		self.currentData = true;
		PVPHonor_UpdateBattlegrounds();
		if ( self.selectedButtonIndex ) then
			PVPHonor_UpdateInfo();
		end
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
		PVPHonor_UpdateQueueStatus();
	elseif ( event == "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE") then
		FauxScrollFrame_SetOffset(PVPHonorFrameTypeScrollFrame, 0);
		FauxScrollFrame_OnVerticalScroll(PVPHonorFrameTypeScrollFrame, 0, 16, PVPHonor_UpdateBattlegrounds); --We may be changing brackets, so we don't want someone to see an outdated version of the data.
		if ( self.selectedButtonIndex ) then
			PVPHonorFrame_ResetInfo();
		end
	elseif ( event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" ) then
		PVPHonorFrame_UpdateGroupAvailable();
	end
end

function PVPHonorFrame_OnShow(self)	
	SortBGList();
	PVPHonor_UpdateBattlegrounds();
	PVPHonorFrame_ResetInfo();
end

function PVPHonorFrame_UpdateGroupAvailable()
	if ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and IsPartyLeader() ) then
		-- If this is true then can join as a group
		PVPFrameRightButton:Enable();
		if not PVPHonorFrame.selectedIsWorldPvp then
			PVPHonorFrameWarGameButton:Enable();
		else
			PVPHonorFrameWarGameButton:Disable();
		end
	else
		PVPFrameRightButton:Disable();
		PVPHonorFrameWarGameButton:Disable();
	end
end



-----------------------------------
---- PVPConquestFrame fUNCTIONS ---
-----------------------------------

function PVPConquestFrame_OnLoad(self)
	
	self.arenaButton.title:SetText(ARENA);
	self.ratedbgButton.title:SetText(PVP_RATED_BATTLEGROUND);		
	self.arenaButton:SetWidth(321);
	self.ratedbgButton:SetWidth(321);
	
	
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("ARENA_TEAM_UPDATE");
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	
	
	
	local factionGroup = UnitFactionGroup("player");
	self.infoButton.factionIcon = _G["PVPConquestFrameInfoButtonInfoIcon"..factionGroup];
	self.infoButton.factionIcon:Show();
	self.winReward.arenaSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);
end


function PVPConquestFrame_OnEvent(self, event, ...)
	if not self:IsShown() then
		return;
	end
	
	PVPConquestFrame_Update(PVPConquestFrame);
end


function PVPConquestFrame_Update(self)
	local groupSize = max(GetNumPartyMembers()+1, GetNumRaidMembers());
	local validGroup = false;
		
	if self.mode == "Arena" then
		self.winReward.winAmount:SetText(0);
	
		local teamName, teamSize, teamRating, teamPlayed, teamWins;
		for i=1,MAX_ARENA_TEAMS do
			teamName, teamSize, teamRating, teamPlayed, teamWins = GetArenaTeam(i);
			if not teamName then
				break;
			elseif teamSize == groupSize then
				validGroup = true;
				self.teamIndex = i;
				ArenaTeamRoster(i);
				
				for j=1,groupSize-1 do
					local name = UnitName("party"..j)
					local found = false;
					for k=1,groupSize*2 do
						if name == GetArenaTeamRosterInfo(i, k) then
							found = true;
							break;
						end
					end
					
					if not found or not UnitIsConnected("party"..j) then
						validGroup = false;
						break;
					end
				end
				break;
			end
		end

		if not validGroup then
			self.infoButton.title:SetText("|cff808080"..ARENA_BATTLES);
			self.infoButton.arenaError:Show();
			self.infoButton.wins:Hide();
			self.infoButton.winsValue:Hide();
			self.infoButton.losses:Hide();
			self.infoButton.lossesValue:Hide();
			self.infoButton.topLeftText:Hide();
			self.infoButton.bottomLeftText:Hide();
			self.teamIndex = nil;
		else
			local ArenaSizesToIndex = {}
			ArenaSizesToIndex[2] = 1;
			ArenaSizesToIndex[3] = 2;
			ArenaSizesToIndex[5] = 3;
			_, ratedArenaReward = GetPersonalRatedArenaInfo(ArenaSizesToIndex[teamSize]);
			self.winReward.winAmount:SetText(ratedArenaReward)
			if ratedArenaReward == 0 then
				RequestRatedArenaInfo(ArenaSizesToIndex[teamSize]);
			end
		
			self.infoButton.title:SetText(teamName);
			self.infoButton.winsValue:SetText(teamWins);
			self.infoButton.lossesValue:SetText(teamPlayed-teamWins);
			self.infoButton.topLeftText:SetText(PVP_RATING.." "..teamRating);
			self.infoButton.bottomLeftText:SetText(_G["ARENA_"..groupSize.."V"..groupSize]);
			
			self.infoButton.arenaError:Hide();
			self.infoButton.wins:Show();
			self.infoButton.winsValue:Show();
			self.infoButton.losses:Show();
			self.infoButton.lossesValue:Show();
			self.infoButton.topLeftText:Show();
			self.infoButton.bottomLeftText:Show();
		end
	else -- Rated BG
		local personalBGRating, ratedBGreward, _, _, weeklyWins, weeklyPlayed = GetPersonalRatedBGInfo();
		self.topRatingText:SetText(RATING..": "..personalBGRating);
		self.winReward.winAmount:SetText(ratedBGreward);
		
		
		local name, size = GetRatedBattleGroundInfo();
		
		validGroup = groupSize==size;
		local prefixColorCode = "|cff808080";
		if validGroup then
			prefixColorCode = "";
		end
		
		
		if name then
			self.infoButton.title:SetText(prefixColorCode..name);
			self.infoButton.bottomLeftText:SetFormattedText(PVP_TEAMTYPE, size, size);
		end
		
		
		self.infoButton.winsValue:SetText(prefixColorCode..weeklyWins);
		self.infoButton.lossesValue:SetText(prefixColorCode..(weeklyPlayed-weeklyWins));
		self.infoButton.topLeftText:SetText(prefixColorCode..ARENA_THIS_WEEK);
		
		self.infoButton.arenaError:Hide();
		self.infoButton.wins:Show();
		self.infoButton.winsValue:Show();
		self.infoButton.losses:Show();
		self.infoButton.lossesValue:Show();
		self.infoButton.topLeftText:Show();
		self.infoButton.bottomLeftText:Show();
		self.infoButton.bgNorm:Show();
		self.infoButton.bgOff:Hide();
	end
	
	
	if validGroup then
		self.partyStatusBG:SetVertexColor(0,1,0);
		self.partyNum:SetFormattedText(GREEN_FONT_COLOR_CODE..PVP_PARTY_SIZE, groupSize);
		self.infoButton.bgNorm:Show();
		self.infoButton.bgOff:Hide();
		SetDesaturation(self.infoButton.factionIcon, false);
		
		self.infoButton.wins:SetText(WINS);
		self.infoButton.losses:SetText(LOSSES);
		if IsPartyLeader() then
			PVPFrameLeftButton:Enable();
		end
	else
		self.partyStatusBG:SetVertexColor(1,0,0);
		self.partyNum:SetFormattedText(RED_FONT_COLOR_CODE..PVP_PARTY_SIZE, groupSize);
		self.infoButton.bgNorm:Hide();
		self.infoButton.bgOff:Show();
		SetDesaturation(self.infoButton.factionIcon, true);
		
		self.infoButton.wins:SetText("|cff808080"..WINS);
		self.infoButton.losses:SetText("|cff808080"..LOSSES);
		PVPFrameLeftButton:Disable();
	end

	self.validGroup = validGroup;
end


function PVPConquestFrame_OnShow(self)
	if not self.clickedButton then
		self.clickedButton = self.arenaButton;
	end
	self.clickedButton:Click();
	PVPConquestFrame_Update(self);
end


function PVPConquestFrame_ButtonClicked(button)
	if button:GetID() == 1 then --Arena
		PVPConquestFrame.mode = "Arena";
		PVPConquestFrame.BG:SetTexCoord(0.00097656, 0.31445313, 0.33789063, 0.88476563);
		PVPConquestFrame.description:SetText(PVP_ARENA_EXPLANATION);
		PVPConquestFrame.title:SetText(ARENA_BATTLES);
		button:LockHighlight();
		PVPConquestFrame.ratedbgButton:UnlockHighlight();
		PVPConquestFrame.topRatingText:Hide();
	else -- Rated BG	
		PVPConquestFrame.mode = "RatedBg";
		PVPConquestFrame.BG:SetTexCoord(0.32324219, 0.63671875, 0.00195313, 0.54882813);
		PVPConquestFrame.description:SetText(PVP_RATED_BATTLEGROUND_EXPLANATION);
		PVPConquestFrame.title:SetText(PVP_RATED_BATTLEGROUNDS);
		button:LockHighlight();
		PVPConquestFrame.arenaButton:UnlockHighlight();
		PVPConquestFrameInfoButton.title:SetText(PVP_RATED_BATTLEGROUND);
		PVPConquestFrameInfoButton.topLeftText:SetText(ARENA_THIS_WEEK);
		PVPConquestFrame.topRatingText:Show();
	end
	PVPConquestFrame_Update(PVPConquestFrame);
end


--  PVPTeamManagementFrame
--  PVPTeamManagementFrame

function PVPTeamManagementFrame_OnLoad(self)
	self:RegisterEvent("ARENA_TEAM_UPDATE");
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");
	local button;
	for i=1, MAX_ARENA_TEAM_MEMBERS_SHOWN do
		button = _G["PVPTeamManagementFrameTeamMemberButton"..i];
		if mod(i, 2) == 0 then 
			button.BG:Show();
		else		
			button.BG:Hide();
		end
	end
	
	PvP_WeeklyText:SetText(ARENA_WEEKLY_STATS);
end



function PVPTeamManagementFrame_OnEvent(self, event, ...)
	if not self:IsShown() then
		return;
	end
	
	local arg1 = ...;
	if ( event == "ARENA_TEAM_UPDATE") then
		PVPTeamManagementFrame_UpdateTeams(self)
	elseif ( event == "ARENA_TEAM_ROSTER_UPDATE" ) then
		PVPTeamManagementFrame_UpdateTeamInfo(self, self.selectedTeam);
	end
end



function PVPTeamManagementFrame_ToggleSeasonal(self)
	local parent  = self:GetParent();
	parent.seasonStats = not parent.seasonStats;	
	PVPTeamManagementFrame_UpdateTeamInfo(parent, parent.selectedTeam);
end

function PVPTeamManagementFrame_UpdateTeamInfo(self, flagbutton)
	if not  flagbutton  then 
		if self.selectedTeam then
			flagbutton = self.selectedTeam;
		else 
			self.noTeams:Show();
			return;
		end
	end
	flagbutton.Glow:Show();	
	flagbutton.GlowHeader:Show();
	flagbutton.NormalHeader:Hide();
	flagbutton.title:SetFontObject(ARENABANNER_SMALLFONT);
	flagbutton.title:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	self.selectedTeam = flagbutton;
	local teamIndex = flagbutton:GetID();
	ArenaTeamRoster(teamIndex);
	
	if  IsArenaTeamCaptain(teamIndex) then	
		PVPFrameLeftButton:Enable();
	else	
		PVPFrameLeftButton:Disable();
	end
	
	-- Pull Values
	local teamName, teamSize, teamRating, teamPlayed, teamWins,  seasonTeamPlayed, 
	seasonTeamWins, playerPlayed, seasonPlayerPlayed, teamRank, playerRating = GetArenaTeam(teamIndex);

	self.TeamData:Show()
	local TeamDataName = self.TeamData:GetName();

	if ( self.seasonStats ) then
		_G[TeamDataName.."TypeLabel"]:SetText(ARENA_THIS_SEASON);
		played = seasonTeamPlayed;
		wins = seasonTeamWins;
		playerPlayed = seasonPlayerPlayed;
		PvP_WeeklyText:SetText(ARENA_SEASON_STATS);
	else
		_G[TeamDataName.."TypeLabel"]:SetText(ARENA_THIS_WEEK);
		played = teamPlayed;
		wins = teamWins;
		playerPlayed = playerPlayed;
		PvP_WeeklyText:SetText(ARENA_WEEKLY_STATS);
	end

	loss = played - wins;
	-- Populate Data
	_G[TeamDataName.."Name"]:SetText(_G["ARENA_"..teamSize.."V"..teamSize].."  "..teamName);
	_G[TeamDataName.."Rating"]:SetText(teamRating);
	_G[TeamDataName.."Games"]:SetText(played);
	_G[TeamDataName.."Wins"]:SetText(wins);
	_G[TeamDataName.."Loss"]:SetText(loss);	
	 _G[TeamDataName.."Played"]:SetText(playerPlayed);
	 
	 
	--Show teammates at teamIndex
	local numMembers = GetNumArenaTeamMembers(teamIndex, 1);
	local scrollTeammates =  numMembers > MAX_ARENA_TEAM_MEMBERS_SHOWN;
	local TeammateButtonName = self:GetName().."TeamMemberButton";
	local scrollOffset =  FauxScrollFrame_GetOffset(self.teamMemberScrollFrame);
	
	
	
	if ( teamSize > numMembers ) then
		self.invalidTeam:Show();
		self.invalidTeam:SetFrameLevel(self:GetFrameLevel() + 2);
		if IsArenaTeamCaptain(teamIndex) then
			self.invalidTeam.text:SetText(ARENA_CAPTAIN_INVALID_TEAM);
		else
			self.invalidTeam.text:SetText(ARENA_NOT_CAPTAIN_INVALID_TEAM);
		end		
	else
		self.invalidTeam:Hide();
	end
	
	local nameText, classText, playedText, winLossWin, winLossLoss, ratingText;
	-- Display Team Member Specific Info
	local playedValue, winValue, lossValue;
	for i=1, MAX_ARENA_TEAM_MEMBERS_SHOWN, 1 do
		button = _G[TeammateButtonName..i];		
		if  scrollTeammates then
			button:SetWidth(MAX_ARENA_TEAM_MEMBER_SCROLL_WIDTH);
		else
			button:SetWidth(MAX_ARENA_TEAM_MEMBER_WIDTH);		
		end	
		
		
		if ( i > numMembers ) then
			button:Disable();
			_G[TeammateButtonName..i.."NameText"]:SetText("");
			--classText = _G[TeammateButtonName..i.."ClassText"];  ADD class color and Icon
			_G[TeammateButtonName..i.."PlayedText"]:SetText("");
			_G[TeammateButtonName..i.."WinLossText"]:SetText("");
			_G[TeammateButtonName..i.."RatingText"]:SetText("");
			_G[TeammateButtonName..i.."ClassIcon"]:Hide();
			_G[TeammateButtonName..i.."CaptainIcon"]:Hide();
		else
			button:Enable();
			button.playerIndex = i+scrollOffset;
			-- Get Data
			local name, rank, level, class, online, played, win, seasonPlayed, seasonWin, rating = GetArenaTeamRosterInfo(teamIndex, i+scrollOffset);
			loss = played - win;
			seasonLoss = seasonPlayed - seasonWin;

			-- Populate Data into the display, season or this week
			if ( self.seasonStats ) then
				playedValue = seasonPlayed;
				winValue = seasonWin;
				lossValue = seasonLoss;
				teamPlayed = seasonTeamPlayed;
			else
				playedValue = played;
				winValue = win;
				lossValue = loss;
				teamPlayed = teamPlayed;
			end			
			
			nameText = _G[TeammateButtonName..i.."NameText"];
			--classText = _G[TeammateButtonName..i.."ClassText"];  ADD class color and Icon
			playedText = _G[TeammateButtonName..i.."PlayedText"]
			winLossText = _G[TeammateButtonName..i.."WinLossText"];
			ratingText = _G[TeammateButtonName..i.."RatingText"];			
			if class then
				_G[TeammateButtonName..i.."ClassIcon"]:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(class)]));
				_G[TeammateButtonName..i.."ClassIcon"]:Show();
			else
				_G[TeammateButtonName..i.."ClassIcon"]:Hide();
			end
			if  rank > 0 then
				_G[TeammateButtonName..i.."CaptainIcon"]:Hide();
			else
				_G[TeammateButtonName..i.."CaptainIcon"]:Show();
			end
			
			nameText:SetText(name);
			--classText:SetText(class);
			playedText:SetText(playedValue);
			winLossText:SetText(winValue.."-"..lossValue);
			ratingText:SetText(rating);
		
			-- Color Entries based on Online status
			local r, g, b;
			if ( online ) then
				if ( rank > 0 ) then
					r = 1.0;	g = 1.0;	b = 1.0;
				else
					r = 1.0;	g = 0.82;	b = 0.0;
				end
			else
				r = 0.5;	g = 0.5;	b = 0.5;
			end

			nameText:SetTextColor(r, g, b);
			playedText:SetTextColor(r, g, b);
			winLossText:SetTextColor(r, g, b);
			ratingText:SetTextColor(r, g, b);

			button:Show();

			-- Highlight the correct who
			if ( GetArenaTeamRosterSelection(teamIndex) == i ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
		end		
	end	 
	
	FauxScrollFrame_Update(self.teamMemberScrollFrame, numMembers, MAX_ARENA_TEAM_MEMBERS_SHOWN, 18);
end


function PVPTeamManagementFrame_TeamInfo_OnScroll()
	PVPTeamManagementFrame_UpdateTeamInfo(PVPTeamManagementFrame, PVPTeamManagementFrame.selectedTeam);
end


function PVPTeamManagementFrame_FlagClicked(self)
	local index = self:GetID();
	if index < 0 then   -- Player clicked a flag that is not associated with a current team
		-- Try to make a new Arena Team.
			local teamSize = abs(index);
			PVPBannerFrame.teamSize = teamSize;
			ShowUIPanel(PVPBannerFrame);
			PVPBannerFrameTitleText:SetText(_G["ARENA_"..teamSize.."V"..teamSize]);
	else
		if  self:GetParent().selectedTeam then
			self:GetParent().selectedTeam.Glow:Hide();		
			self:GetParent().selectedTeam.GlowHeader:Hide();
			self:GetParent().selectedTeam.NormalHeader:Show();			
			self:GetParent().selectedTeam.title:SetFontObject(ARENABANNER_SMALLFONT);
			self:GetParent().selectedTeam.title:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			HideUIPanel(PVPBannerFrame);
		end
		PVPTeamManagementFrame_UpdateTeamInfo(self:GetParent(), self);	
		FauxScrollFrame_SetOffset(self:GetParent().teamMemberScrollFrame, 0);
	end
end


function PVPTeamManagementFrame_UpdateTeams(self)
		
		self.defaultTeam = nil;
		local bannerName = "";
		local flagsList = {};
		flagsList[2] = false;
		flagsList[3] = false;
		flagsList[5] = false;	
		
		local teamName, teamSize, teamRating, emblem, border;
		local background = {}; 
		local emblemColor = {} ;
		local borderColor = {}; 		

		for i=1, MAX_ARENA_TEAMS do
			--the ammount of parameter this returns is absurd
			teamName, teamSize, teamRating, _,  _,  _, _, _, _, _, _, 
			background.r, background.g, background.b, 
			emblem, emblemColor.r, emblemColor.g, emblemColor.b, 
			border, borderColor.r, borderColor.g, borderColor.b 												= GetArenaTeam(i);			

			if teamName then
				flagsList[teamSize] = true;			
				bannerName = self["flag"..teamSize]:GetName();
				_G[bannerName]:Enable();
				_G[bannerName]:SetID(i);
				_G[bannerName.."Banner"]:SetVertexColor(background.r, background.g, background.b);
				_G[bannerName.."Emblem"]:Show();
				_G[bannerName.."Emblem"]:SetVertexColor( emblemColor.r, emblemColor.g, emblemColor.b);
				_G[bannerName.."Emblem"]:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..emblem);
				_G[bannerName.."Border"]:Show();
				_G[bannerName.."Border"]:SetVertexColor( borderColor.r, borderColor.g, borderColor.b );				
				_G[bannerName.."Border"]:SetTexture("Interface\\PVPFrame\\PVP-Banner-2-Border-"..border);
				_G[bannerName.."Title"]:SetText(_G["ARENA_"..teamSize.."V"..teamSize].."\n"..RATING..":  "..teamRating);
				_G[bannerName.."Title"]:SetFontObject(ARENABANNER_SMALLFONT);
				_G[bannerName.."Title"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				
				if not self.defaultTeam then
					self.defaultTeam =  _G[bannerName];	
				end
			end
		end	
	
		for size, value in pairs(flagsList) do 
			if  not value then 
				local bannerName = self["flag"..size]:GetName();
				_G[bannerName]:SetID(-size);
				_G[bannerName.."Banner"]:SetVertexColor(1, 1, 1);
				_G[bannerName.."Emblem"]:Hide();
				_G[bannerName.."Border"]:Hide();
				_G[bannerName.."Title"]:SetText(_G["ARENA_"..size.."V"..size]);
				_G[bannerName.."Title"]:SetFontObject("GameFontHighlight");
				_G[bannerName.."HeaderSelected"]:Hide();
				_G[bannerName.."Header"]:Show();
				_G[bannerName.."GlowBG"]:Hide();
				if  self.selectedTeam == self["flag"..size] then
					self.selectedTeam = nil;
				end
			end
		end

		self.noTeams:Hide();
		self.weeklyToggleLeft:Enable();
		self.weeklyToggleRight:Enable();
		PVPFrameLeftButton:Enable();
		if  self.selectedTeam then 
			PVPTeamManagementFrame_UpdateTeamInfo(self, self.selectedTeam)
		elseif  self.defaultTeam then 
			PVPTeamManagementFrame_UpdateTeamInfo(self, self.defaultTeam)
		else
			--We have not arena teams
			self.noTeams:Show();
			PVPFrameLeftButton:Disable();
			self.weeklyToggleLeft:Disable();
			self.weeklyToggleRight:Disable();
			self.invalidTeam:Hide();
			self.noTeams:SetFrameLevel(self:GetFrameLevel() + 2);
			FauxScrollFrame_Update(self.teamMemberScrollFrame, 0, MAX_ARENA_TEAM_MEMBERS_SHOWN, 18);
		end	
end


function PVPTeamManagementFrame_OnShow(self)
	PVPTeamManagementFrame_UpdateTeams(self)
end


function PVPTeamManagementFrame_DropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "TEAM", nil, PVPTeamManagementFrameTeamDropDown.name);
end

function PVPTeamManagementFrame_ShowDropdown(name, online)
	HideDropDownMenu(1);
	
	if ( not IsArenaTeamCaptain(PVPTeamManagementFrame.selectedTeam:GetID()) ) then
		if ( online ) then
			PVPTeamManagementFrameTeamDropDown.initialize = PVPTeamManagementFrame_DropDown_Initialize;
			PVPTeamManagementFrameTeamDropDown.displayMode = "MENU";
			PVPTeamManagementFrameTeamDropDown.name = name;
			PVPTeamManagementFrameTeamDropDown.online = online;
			ToggleDropDownMenu(1, nil, PVPTeamManagementFrameTeamDropDown, "cursor");
		end
	else
		PVPTeamManagementFrameTeamDropDown.initialize = PVPTeamManagementFrame_DropDown_Initialize;
		PVPTeamManagementFrameTeamDropDown.displayMode = "MENU";
		PVPTeamManagementFrameTeamDropDown.name = name;
		PVPTeamManagementFrameTeamDropDown.online = online;
		ToggleDropDownMenu(1, nil, PVPTeamManagementFrameTeamDropDown, "cursor");
	end
end


---- PVP PopUp Functions


function PVPFramePopup_OnLoad(self)
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("BATTLEFIELD_QUEUE_TIMEOUT");
end


function PVPFramePopup_OnEvent(self, event, ...)
	if event == "BATTLEFIELD_QUEUE_TIMEOUT" then
		if self.type == "WARGAME_REQUESTED" then
			self:Hide();
		end
	end
end


function PVPFramePopup_OnUpdate(self, elasped)
	if self.timeout then
		self.timeout = self.timeout - elasped;
		if self.timeout > 0 then
			self.timer:SetText(SecondsToTime(self.timeout))
		end
	end
end


function PVPFramePopup_SetupPopUp(event, challengerName, bgName, timeout)
	PVPFramePopup.title:SetFormattedText(WARGAME_CHALLENGED, challengerName, bgName);
	PVPFramePopup.type = event;
	PVPFramePopup.timeout = timeout  - 3;  -- add a 3 second buffer
	PVPFramePopup.minimizeButton:Disable();
	SetPortraitToTexture(PVPFramePopup.ringIcon,"Interface\\BattlefieldFrame\\UI-Battlefield-Icon");
	StaticPopupSpecial_Show(PVPFramePopup);
	PlaySound("ReadyCheck");
end



function PVPFramePopup_OnResponse(accepted)
	if PVPFramePopup.type == "WARGAME_REQUESTED" then
		WarGameRespond(accepted)
	end
	
	StaticPopupSpecial_Hide(PVPFramePopup);
end



---- PVPTimer


function PVPTimerFrame_OnUpdate(self, elapsed)
	local keepUpdating = false;
	if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 ) then
		keepUpdating = true;
		BattlefieldIconText:Hide();
	else
		local lowestExpiration = 0;
		for i = 1, MAX_BATTLEFIELD_QUEUES do
			local expiration = GetBattlefieldPortExpiration(i);
			if ( expiration > 0 ) then
				if( expiration < lowestExpiration or lowestExpiration == 0 ) then
					lowestExpiration = expiration;
				end
	
				keepUpdating = true;
			end
		end

		if( lowestExpiration > 0 and lowestExpiration <= 10 ) then
			BattlefieldIconText:SetText(lowestExpiration);
			BattlefieldIconText:Show();
		else
			BattlefieldIconText:Hide();
		end
	end
	
	if ( not keepUpdating ) then
		PVPTimerFrame:SetScript("OnUpdate", nil);
		return;
	end
	
	local frame = PVPFrame
	
	BATTLEFIELD_SHUTDOWN_TIMER = BATTLEFIELD_SHUTDOWN_TIMER - elapsed;
	-- Set the time for the score frame
	WorldStateScoreFrameTimer:SetFormattedText(SecondsToTimeAbbrev(BATTLEFIELD_SHUTDOWN_TIMER));
	-- Check if I should send a message only once every 3 seconds (BATTLEFIELD_TIMER_DELAY)
	frame.timerDelay = frame.timerDelay + elapsed;
	if ( frame.timerDelay < BATTLEFIELD_TIMER_DELAY ) then
		return;
	else
		frame.timerDelay = 0
	end

	local threshold = BATTLEFIELD_TIMER_THRESHOLDS[BATTLEFIELD_TIMER_THRESHOLD_INDEX];
	if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 ) then
		if ( BATTLEFIELD_SHUTDOWN_TIMER < threshold and BATTLEFIELD_TIMER_THRESHOLD_INDEX ~= #BATTLEFIELD_TIMER_THRESHOLDS ) then
			-- If timer past current threshold advance to the next one
			BATTLEFIELD_TIMER_THRESHOLD_INDEX = BATTLEFIELD_TIMER_THRESHOLD_INDEX + 1;
		else
			-- See if time should be posted
			local currentMod = floor(BATTLEFIELD_SHUTDOWN_TIMER/threshold);
			if ( PREVIOUS_BATTLEFIELD_MOD ~= currentMod ) then
				-- Print message
				local info = ChatTypeInfo["SYSTEM"];
				local string;
				if ( GetBattlefieldWinner() ) then
					local isArena = IsActiveBattlefieldArena();
					if ( isArena ) then
						string = format(ARENA_COMPLETE_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
					else
						string = format(BATTLEGROUND_COMPLETE_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
					end
				else
					string = format(INSTANCE_SHUTDOWN_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
				end
				DEFAULT_CHAT_FRAME:AddMessage(string, info.r, info.g, info.b, info.id);
				PREVIOUS_BATTLEFIELD_MOD = currentMod;
			end
		end
	else
		BATTLEFIELD_SHUTDOWN_TIMER = 0;
	end
end



------		Misc PVP Functions
------		Misc PVP Functions


function PVPQueue_UpdateRandomInfo(base, infoFunc)
	local BGname, canEnter, isHoliday, isRandom = infoFunc();
	
	local hasWin, lossHonor, winHonor, winArena, lossArena;
	
	if ( isRandom ) then
		hasWin, winHonor, winArena, lossHonor, lossArena = GetRandomBGHonorCurrencyBonuses();
		base.title:SetText(RANDOM_BATTLEGROUND);
		base.description:SetText(RANDOM_BATTLEGROUND_EXPLANATION);
	else
		base.title:SetText(BATTLEGROUND_HOLIDAY);
		base.description:SetText(BATTLEGROUND_HOLIDAY_EXPLANATION);
		hasWin, winHonor, winArena, lossHonor, lossArena = GetHolidayBGHonorCurrencyBonuses();
	end
	
	if (winHonor ~= 0) then
		base.winReward.honorSymbol:Show();
		base.winReward.honorAmount:Show();
		base.winReward.honorAmount:SetText(winHonor);
	else
		base.winReward.honorSymbol:Hide();
		base.winReward.honorAmount:Hide();
	end
	
	if (winArena ~= 0) then
		base.winReward.arenaSymbol:Show();
		base.winReward.arenaAmount:Show();
		base.winReward.arenaAmount:SetText(winArena);
	else
		base.winReward.arenaSymbol:Hide();
		base.winReward.arenaAmount:Hide();
	end
	
	if (lossHonor ~= 0) then
		base.lossReward.honorSymbol:Show();
		base.lossReward.honorAmount:Show();
		base.lossReward.honorAmount:SetText(lossHonor);
	else
		base.lossReward.honorSymbol:Hide();
		base.lossReward.honorAmount:Hide();
	end
	
	if (lossArena ~= 0) then
		base.lossReward.arenaSymbol:Show();
		base.lossReward.arenaAmount:Show();
		base.lossReward.arenaAmount:SetText(lossArena);
	else
		base.lossReward.arenaSymbol:Hide();
		base.lossReward.arenaAmount:Hide();
	end
		
	local englishFaction = UnitFactionGroup("player");
	base.winReward.honorSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor-"..englishFaction);
	base.lossReward.honorSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor-"..englishFaction);
	base.winReward.arenaSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..englishFaction);
	base.lossReward.arenaSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..englishFaction);
end



function MiniMapBattlefieldDropDown_OnLoad()
	UIDropDownMenu_Initialize(MiniMapBattlefieldDropDown, MiniMapBattlefieldDropDown_Initialize, "MENU");
end

function MiniMapBattlefieldDropDown_Initialize()
	local info;
	local status, mapName, instanceID, queueID, levelRangeMin, levelRangeMax, teamSize, registeredMatch;
	local numQueued = 0;
	local numShown = 0;
	
	local shownHearthAndRes;
	
	for i=1, MAX_BATTLEFIELD_QUEUES do
		status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch = GetBattlefieldStatus(i);

		-- Inserts a spacer if it's not the first option... to make it look nice.
		if ( status ~= "none" ) then
			numShown = numShown + 1;
			if ( numShown > 1 ) then
				info = UIDropDownMenu_CreateInfo();
				info.isTitle = 1;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			end
		end

		if ( status == "queued" or status == "confirm" ) then
			numQueued = numQueued + 1;
			-- Add a spacer if there were dropdown items before this

			info = UIDropDownMenu_CreateInfo();
			if ( teamSize ~= 0 ) then
				if ( registeredMatch ) then
					info.text = ARENA_RATED_MATCH.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
				else
					info.text = ARENA_CASUAL.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
				end
			else
				info.text = mapName;
			end
			info.isTitle = 1;
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);			

			if ( CanHearthAndResurrectFromArea() and not shownHearthAndRes and GetRealZoneText() == mapName ) then
				info = UIDropDownMenu_CreateInfo();
				info.text = format(LEAVE_ZONE, GetRealZoneText());			
				
				info.func = HearthAndResurrectFromArea;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
				shownHearthAndRes = true;
			end
			
			if ( status == "queued" ) then

				info = UIDropDownMenu_CreateInfo();
				info.text = LEAVE_QUEUE;
				info.func = function (self, ...) AcceptBattlefieldPort(...) end;
				info.arg1 = i;
				info.notCheckable = 1;
				info.disabled = registeredMatch and not (IsPartyLeader() or IsRaidLeader());
				UIDropDownMenu_AddButton(info);

			elseif ( status == "confirm" ) then

				info = UIDropDownMenu_CreateInfo();
				info.text = ENTER_BATTLE;
				info.func = function (self, ...) AcceptBattlefieldPort(...) end;
				info.arg1 = i;
				info.arg2 = 1;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);

				if ( teamSize == 0 ) then
					info = UIDropDownMenu_CreateInfo();
					info.text = LEAVE_QUEUE;
					info.func = function (self, ...) AcceptBattlefieldPort(...) end;
					info.arg1 = i;
					info.notCheckable = 1;
					UIDropDownMenu_AddButton(info);
				end

			end			

		elseif ( status == "active" ) then

			info = UIDropDownMenu_CreateInfo();
			if ( teamSize ~= 0 ) then
				info.text = mapName.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
			else
				info.text = mapName;
			end
			info.isTitle = 1;
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);

			info = UIDropDownMenu_CreateInfo();
			if ( IsActiveBattlefieldArena() ) then
				info.text = LEAVE_ARENA;
			else
				info.text = LEAVE_BATTLEGROUND;				
			end
			info.func = function (self, ...) LeaveBattlefield(...) end;
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);

		end
	end
	
	for i=1, MAX_WORLD_PVP_QUEUES do
		status, mapName, queueID = GetWorldPVPQueueStatus(i);

		-- Inserts a spacer if it's not the first option... to make it look nice.
		if ( status ~= "none" ) then
			numShown = numShown + 1;
			if ( numShown > 1 ) then
				info = UIDropDownMenu_CreateInfo();
				info.isTitle = 1;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			end
		end
		
		if ( status == "queued" or status == "confirm" ) then
			numQueued = numQueued + 1;
			-- Add a spacer if there were dropdown items before this
			
			info = UIDropDownMenu_CreateInfo();
			info.text = mapName;
			info.isTitle = 1;
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);			
			
			if ( CanHearthAndResurrectFromArea() and not shownHearthAndRes and GetRealZoneText() == mapName ) then
				info = UIDropDownMenu_CreateInfo();
				info.text = format(LEAVE_ZONE, GetRealZoneText());			
				
				info.func = HearthAndResurrectFromArea;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
				shownHearthAndRes = true;
			end
			
			if ( status == "queued" ) then
			
				info = UIDropDownMenu_CreateInfo();
				info.text = LEAVE_QUEUE;
				info.func = function (self, ...) BattlefieldMgrExitRequest(...) end;
				info.arg1 = queueID;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
				
			elseif ( status == "confirm" ) then
			
				info = UIDropDownMenu_CreateInfo();
				info.text = ENTER_BATTLE;
				info.func = function (self, ...) BattlefieldMgrEntryInviteResponse(...) end;
				info.arg1 = queueID;
				info.arg2 = 1;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
				
				info = UIDropDownMenu_CreateInfo();
				info.text = LEAVE_QUEUE;
				info.func = function (self, ...) BattlefieldMgrEntryInviteResponse(...) end;
				info.arg1 = i;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			end
		end
	end
	
	if ( CanHearthAndResurrectFromArea() and not shownHearthAndRes ) then
		numShown = numShown + 1;
		info = UIDropDownMenu_CreateInfo();
		info.text = GetRealZoneText();
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);

		info = UIDropDownMenu_CreateInfo();
		info.text = format(LEAVE_ZONE, GetRealZoneText());			
		
		info.func = HearthAndResurrectFromArea;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end

end

function IsAlreadyInQueue(mapName)
	local inQueue = nil;
	for index,value in pairs(PREVIOUS_BATTLEFIELD_QUEUES) do
		if ( value == mapName ) then
			inQueue = 1;
		end
	end
	return inQueue;
end



function BattlegroundShineFadeIn()
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = 0.5;
	fadeInfo.finishedFunc = BattlegroundShineFadeOut;
	UIFrameFade(BattlegroundShine, fadeInfo);
end

--hack since a frame can't have a reference to itself in it
function BattlegroundShineFadeOut()
	UIFrameFadeOut(BattlegroundShine, 0.5);
end



function PVP_UpdateStatus(tooltipOnly, mapIndex)
	local status, mapName, instanceID, queueID, levelRangeMin, levelRangeMax, teamSize, registeredMatch;
	local numberQueues = 0;
	local waitTime, timeInQueue;
	local tooltip;
	local showRightClickText;
	BATTLEFIELD_SHUTDOWN_TIMER = 0;

	-- Reset tooltip
	MiniMapBattlefieldFrame.tooltip = nil;
	MiniMapBattlefieldFrame.waitTime = {};
	MiniMapBattlefieldFrame.status = nil;
	
	-- Copy current queues into previous queues
	if ( not tooltipOnly ) then
		PREVIOUS_BATTLEFIELD_QUEUES = {};
		for index, value in pairs(CURRENT_BATTLEFIELD_QUEUES) do
			tinsert(PREVIOUS_BATTLEFIELD_QUEUES, value);
		end
		CURRENT_BATTLEFIELD_QUEUES = {};
	end

	if ( CanHearthAndResurrectFromArea() ) then
		if ( not MiniMapBattlefieldFrame.inWorldPVPArea ) then
			MiniMapBattlefieldFrame.inWorldPVPArea = true;
			UIFrameFadeIn(MiniMapBattlefieldFrame, BATTLEFIELD_FRAME_FADE_TIME);
			BattlegroundShineFadeIn();
		end
	else
		MiniMapBattlefieldFrame.inWorldPVPArea = false;
	end
	
	for i=1, MAX_BATTLEFIELD_QUEUES do
		status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch = GetBattlefieldStatus(i);
		if ( mapName ) then
			if (  instanceID ~= 0 ) then
				mapName = mapName.." "..instanceID;
			end
			if ( teamSize ~= 0 ) then
				if ( registeredMatch ) then
					mapName = ARENA_RATED_MATCH.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
				else
					mapName = ARENA_CASUAL.." "..format(PVP_TEAMSIZE, teamSize, teamSize);
				end
			end
		end
		tooltip = nil;
		if ( not tooltipOnly and (status ~= "confirm") ) then
			StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY", i);
		end

		if ( status ~= "none" ) then
			numberQueues = numberQueues+1;
			if ( status == "queued" ) then
				-- Update queue info show button on minimap
				waitTime = GetBattlefieldEstimatedWaitTime(i);
				timeInQueue = GetBattlefieldTimeWaited(i)/1000;
				if ( waitTime == 0 ) then
					waitTime = QUEUE_TIME_UNAVAILABLE;
				elseif ( waitTime < 60000 ) then 
					waitTime = LESS_THAN_ONE_MINUTE;
				else
					waitTime = SecondsToTime(waitTime/1000, 1);
				end
				MiniMapBattlefieldFrame.waitTime[i] = waitTime;
				if( registeredMatch and teamSize == 0 ) then
					tooltip = format(BATTLEFIELD_IN_QUEUE_RATED, mapName, waitTime, SecondsToTime(timeInQueue));
				else
					tooltip = format(BATTLEFIELD_IN_QUEUE, mapName, waitTime, SecondsToTime(timeInQueue));
				end
				
				if ( not tooltipOnly ) then
					if ( not IsAlreadyInQueue(mapName) ) then
						UIFrameFadeIn(MiniMapBattlefieldFrame, BATTLEFIELD_FRAME_FADE_TIME);
						BattlegroundShineFadeIn();
						PlaySound("PVPENTERQUEUE");
					end
					tinsert(CURRENT_BATTLEFIELD_QUEUES, mapName);
				end
				showRightClickText = 1;
			elseif ( status == "confirm" ) then
				-- Have been accepted show enter battleground dialog
				local seconds = SecondsToTime(GetBattlefieldPortExpiration(i));
				if ( seconds ~= "" ) then
					tooltip = format(BATTLEFIELD_QUEUE_CONFIRM, mapName, seconds);
				else
					tooltip = format(BATTLEFIELD_QUEUE_PENDING_REMOVAL, mapName);
				end
				if ( (i==mapIndex) and (not tooltipOnly) ) then
					local dialog = StaticPopup_Show("CONFIRM_BATTLEFIELD_ENTRY", mapName, nil, i);
					PlaySound("PVPTHROUGHQUEUE");
					MiniMapBattlefieldFrame:Show();
				end
				showRightClickText = 1;
				PVPTimerFrame:SetScript("OnUpdate", PVPTimerFrame_OnUpdate);
			elseif ( status == "active" ) then
				-- In the battleground
				if ( teamSize ~= 0 ) then
					tooltip = mapName;			
				else
					tooltip = format(BATTLEFIELD_IN_BATTLEFIELD, mapName);
				end
				BATTLEFIELD_SHUTDOWN_TIMER = GetBattlefieldInstanceExpiration()/1000;
				if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 ) then
					PVPTimerFrame:SetScript("OnUpdate", PVPTimerFrame_OnUpdate);
				end
				BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;
				PREVIOUS_BATTLEFIELD_MOD = 0;
				MiniMapBattlefieldFrame.status = status;
			elseif ( status == "error" ) then
				-- Should never happen haha
			end
			if ( tooltip ) then
				if ( MiniMapBattlefieldFrame.tooltip ) then
					MiniMapBattlefieldFrame.tooltip = MiniMapBattlefieldFrame.tooltip.."\n\n"..tooltip;
				else
					MiniMapBattlefieldFrame.tooltip = tooltip;
				end
			end
		end
	end
	
	for i=1, MAX_WORLD_PVP_QUEUES do
		status, mapName, queueID = GetWorldPVPQueueStatus(i);
		if ( status ~= "none" ) then
			numberQueues = numberQueues + 1;
		end
		if ( status == "queued" or status == "confirm" ) then
			if ( status == "queued" ) then
				tooltip = format(BATTLEFIELD_IN_QUEUE_SIMPLE, mapName);
			elseif ( status == "confirm" ) then
				tooltip = format(BATTLEFIELD_QUEUE_CONFIRM_SIMPLE, mapName);
			end
			
			if ( MiniMapBattlefieldFrame.tooltip ) then
				MiniMapBattlefieldFrame.tooltip = MiniMapBattlefieldFrame.tooltip.."\n\n"..tooltip;
			else
				MiniMapBattlefieldFrame.tooltip = tooltip;
			end
		end
	end
	
	-- See if should add right click message
	if ( MiniMapBattlefieldFrame.tooltip and showRightClickText ) then
		MiniMapBattlefieldFrame.tooltip = MiniMapBattlefieldFrame.tooltip.."\n"..RIGHT_CLICK_MESSAGE;
	end
	
	if ( not tooltipOnly ) then
		if ( numberQueues == 0 and (not CanHearthAndResurrectFromArea()) ) then
			-- Clear everything out
			MiniMapBattlefieldFrame:Hide();
		else
			MiniMapBattlefieldFrame:Show();
		end
	end
	PVPFrame.numQueues = numberQueues;
end
