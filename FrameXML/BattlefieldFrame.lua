BATTLEFIELD_ZONES_DISPLAYED = 12;
BATTLEFIELD_ZONES_HEIGHT = 20;
BATTLEFIELD_SHUTDOWN_TIMER = 0;
BATTLEFIELD_TIMER_THRESHOLDS = {600, 300, 60, 15};
BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;
PREVIOUS_BATTLEFIELD_MOD = 0;
BATTLEFIELD_TIMER_DELAY = 3;
BATTLEFIELD_MAP_WIDTH = 320;
BATTLEFIELD_MAP_HEIGHT = 213;
MAX_BATTLEFIELD_QUEUES = 3;
CURRENT_BATTLEFIELD_QUEUES = {};
PREVIOUS_BATTLEFIELD_QUEUES = {};

local BATTLEFIELD_FRAME_FADE_TIME = 0.15

function BattlefieldFrame_OnLoad (self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("BATTLEFIELDS_CLOSED");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	
	BattlefieldFrame.timerDelay = 0;
end

function BattlefieldFrame_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		MiniMapBattlefieldDropDown_OnLoad();
		BattlefieldFrame_UpdateStatus(false, nil);
	elseif ( event == "BATTLEFIELDS_SHOW" ) then
		if ( not IsBattlefieldArena() ) then
			ShowUIPanel(BattlefieldFrame);
			
			-- Default to first available
			SetSelectedBattlefield(0);

			if ( not BattlefieldFrame:IsShown() ) then
				CloseBattlefield();
				return;
			end
			UpdateMicroButtons();
			BattlefieldFrame_Update();
		end
	elseif ( event == "BATTLEFIELDS_CLOSED" ) then
		HideUIPanel(BattlefieldFrame);
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED") then
		local arg1 = ...
		BattlefieldFrame_UpdateStatus(false, arg1);
		BattlefieldFrame_Update();
	end
	if ( event == "PARTY_LEADER_CHANGED" ) then
		BattlefieldFrame_Update();
	end
end

local QUEUE_LAST_UPDATED = {}

function BattlefieldTimerFrame_OnUpdate(self, elapsed)
	local keepUpdating = false;
	if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 ) then
		keepUpdating = true;
	else
		for i = 1, MAX_BATTLEFIELD_QUEUES do
			local expiration = GetBattlefieldPortExpiration(i)/1000;
			if 	(	( expiration > 0 and expiration <= 10 ) and 
					( not QUEUE_LAST_UPDATED[i] or QUEUE_LAST_UPDATED[i] and QUEUE_LAST_UPDATED[i] + 10 < GetTime() ) ) then 
				QUEUE_LAST_UPDATED[i] = GetTime();
				local _, mapName, instanceID, _, _, teamSize, registeredMatch = GetBattlefieldStatus(i);
				if ( mapName ) then
					if ( instanceID ~= 0 ) then
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
				local dialog = StaticPopup_Show("CONFIRM_BATTLEFIELD_ENTRY", mapName, nil, i);
				if ( dialog ) then
					dialog.data = i;
				end
				PlaySound("PVPTHROUGHQUEUE");
				keepUpdating = true;
			elseif ( expiration > 10 ) then
				keepUpdating = true;
			end
		end
	end
	
	if ( not keepUpdating ) then
		BattlefieldTimerFrame:SetScript("OnUpdate", nil);
		return;
	end
	
	local frame = BattlefieldFrame
	
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

function BattlefieldFrame_UpdateStatus(tooltipOnly, mapIndex)
	local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch;
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
		MiniMapBattlefieldFrame_isArena();
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
				tooltip = format(BATTLEFIELD_IN_QUEUE, mapName, waitTime, SecondsToTime(timeInQueue));
				
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
				local seconds = SecondsToTime(GetBattlefieldPortExpiration(i)/1000);
				if ( seconds ~= "" ) then
					tooltip = format(BATTLEFIELD_QUEUE_CONFIRM, mapName, seconds);
				else
					tooltip = format(BATTLEFIELD_QUEUE_PENDING_REMOVAL, mapName);
				end
				if ( (i==mapIndex) and (not tooltipOnly) ) then
					local dialog = StaticPopup_Show("CONFIRM_BATTLEFIELD_ENTRY", mapName, nil, i);
					if ( dialog ) then
						dialog.data = i;
					end
					PlaySound("PVPTHROUGHQUEUE");
					MiniMapBattlefieldFrame:Show();
				end
				showRightClickText = 1;
				BattlefieldTimerFrame:SetScript("OnUpdate", BattlefieldTimerFrame_OnUpdate);
			elseif ( status == "active" ) then
				-- In the battleground
				if ( teamSize ~= 0 ) then
					tooltip = mapName;			
				else
					tooltip = format(BATTLEFIELD_IN_BATTLEFIELD, mapName);
				end
				BATTLEFIELD_SHUTDOWN_TIMER = GetBattlefieldInstanceExpiration()/1000;
				if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 ) then
					BattlefieldTimerFrame:SetScript("OnUpdate", BattlefieldTimerFrame_OnUpdate);
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
	-- See if should add right click message
	if ( MiniMapBattlefieldFrame.tooltip and showRightClickText ) then
		MiniMapBattlefieldFrame.tooltip = MiniMapBattlefieldFrame.tooltip.."\n"..RIGHT_CLICK_MESSAGE;
	elseif ( MiniMapBattlefieldFrame_isArena() ) then
		MiniMapBattlefieldFrame.tooltip = MiniMapBattlefieldFrame.tooltip;
	end
	
	if ( not tooltipOnly ) then
		MiniMapBattlefieldFrame_isArena();
		if ( numberQueues == 0 and (not CanHearthAndResurrectFromArea()) ) then
			-- Clear everything out
			MiniMapBattlefieldFrame:Hide();
		else
			MiniMapBattlefieldFrame:Show();
		end
	end
	BattlefieldFrame.numQueues = numberQueues;
end

function MiniMapBattlefieldFrame_isArena()
	-- Set minimap icon here since it bugs out on login
	local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch = GetBattlefieldStatus(1);
	local isArena, isRegistered = IsActiveBattlefieldArena();
	if ( registeredMatch or isRegistered ) then
		MiniMapBattlefieldIcon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon");
		MiniMapBattlefieldIcon:SetWidth(19);
		MiniMapBattlefieldIcon:SetHeight(19);
		MiniMapBattlefieldIcon:SetPoint("CENTER", "MiniMapBattlefieldFrame", "CENTER", -1, 2);
	elseif ( UnitFactionGroup("player") ) then
		MiniMapBattlefieldIcon:SetTexture("Interface\\BattlefieldFrame\\Battleground-"..UnitFactionGroup("player"));
		MiniMapBattlefieldIcon:SetTexCoord(0, 1, 0, 1);
		MiniMapBattlefieldIcon:SetWidth(32);
		MiniMapBattlefieldIcon:SetHeight(32);
		MiniMapBattlefieldIcon:SetPoint("CENTER", "MiniMapBattlefieldFrame", "CENTER", -1, 0);
	end
end

function BattlefieldFrame_Update()
	local zoneIndex;
	local zoneOffset = FauxScrollFrame_GetOffset(BattlefieldListScrollFrame);
	local playerLevel = UnitLevel("player");
	local button, buttonStatus;
	local instanceID;
	local mapName, mapDescription, minLevel, maxLevel, mapFull, levelMax, maxGroup = GetBattlefieldInfo();
	
	if ( not mapName ) then
		return;
	end

	-- Set title text
	BattlefieldFrameFrameLabel:SetText(mapName);
	-- Set the Join as Group text based on the limits of which instances can join as group.
	if ( maxGroup and maxGroup == 5 ) then
		BattlefieldFrameGroupJoinButton:SetText(JOIN_AS_PARTY);
	else
		BattlefieldFrameGroupJoinButton:SetText(JOIN_AS_GROUP);		
	end
	-- Setup instance buttons
	-- add one to battlefields because of the fake "first available" button
	local numBattlefields = GetNumBattlefields() + 1;
	for i=1, BATTLEFIELD_ZONES_DISPLAYED, 1 do
		zoneIndex = zoneOffset + i;
		button = getglobal("BattlefieldZone"..i);
		buttonStatus = getglobal("BattlefieldZone"..i.."Status");

		if ( zoneIndex == 1 ) then
			-- The first entry in the list is always "first available"
			button:SetText(FIRST_AVAILABLE);
			-- Set tooltip
			button.title = FIRST_AVAILABLE;
			button.tooltip = NEWBIE_TOOLTIP_FIRST_AVAILABLE;
			button:Show();
		elseif ( zoneIndex > numBattlefields ) then
			button:Hide();
		else
			instanceID = GetBattlefieldInstanceInfo(zoneIndex - 1);
			button:SetText(mapName.." "..instanceID);
			-- Set tooltip
			button.title = mapName.." "..instanceID;
			button.tooltip = NEWBIE_TOOLTIP_ENTER_BATTLEGROUND;
			button:Show();
		end
		
		-- Set queued status
		buttonStatus:SetText("");
		local queueStatus, queueMapName, queueInstanceID;
		for i=1, MAX_BATTLEFIELD_QUEUES do
			queueStatus, queueMapName, queueInstanceID = GetBattlefieldStatus(i);
			if ( queueStatus ~= "none" and queueMapName.." "..queueInstanceID == button.title ) then
				if ( queueStatus == "queued" ) then
					buttonStatus:SetText(BATTLEFIELD_QUEUE_STATUS);
				elseif ( queueStatus == "confirm" ) then
					buttonStatus:SetText(BATTLEFIELD_CONFIRM_STATUS);
				end
			elseif ( button.title == FIRST_AVAILABLE and queueMapName == mapName and queueInstanceID == 0 ) then
				if ( queueStatus == "queued" ) then
					buttonStatus:SetText(BATTLEFIELD_QUEUE_STATUS);
				end
			end
		end
		
		-- Set selected instance
		if ( zoneIndex == 1 and GetSelectedBattlefield() == 0 ) then
			button:LockHighlight();
		elseif ( zoneIndex - 1 == GetSelectedBattlefield() ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
	end
	
	BattlefieldFrameZoneDescription:SetText(mapDescription);

	-- Enable or disable the group join button
	if ( CanJoinBattlefieldAsGroup() ) then
		if ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and IsPartyLeader() ) then
			-- If this is true then can join as a group
			BattlefieldFrameGroupJoinButton:Enable();
		else
			BattlefieldFrameGroupJoinButton:Disable();
		end
		BattlefieldFrameGroupJoinButton:Show();
	else
		BattlefieldFrameGroupJoinButton:Hide();
	end

	if (  BattlefieldFrame.numQueues ) then
		if ( BattlefieldFrame.numQueues <= 3 ) then
			BattlefieldFrameJoinButton:Enable();
		else
			BattlefieldFrameJoinButton:Disable();
		end
	end

	FauxScrollFrame_Update(BattlefieldListScrollFrame, numBattlefields, BATTLEFIELD_ZONES_DISPLAYED, BATTLEFIELD_ZONES_HEIGHT, "BattlefieldZone", 293, 315);
end

function BattlefieldButton_OnClick(self)
	local id = self:GetID();
	SetSelectedBattlefield(FauxScrollFrame_GetOffset(BattlefieldListScrollFrame) + id - 1);
	BattlefieldFrame_Update();
end

function BattlefieldFrameJoinButton_OnClick(self)
	local GROUPJOIN_BUTTONID = 2;
	local id = self:GetID();
	if ( id == GROUPJOIN_BUTTONID ) then
		JoinBattlefield(GetSelectedBattlefield(), 1);
	else
		JoinBattlefield(GetSelectedBattlefield());
	end
	
	HideUIPanel(BattlefieldFrame);
end

function MiniMapBattlefieldDropDown_OnLoad()
	UIDropDownMenu_Initialize(MiniMapBattlefieldDropDown, MiniMapBattlefieldDropDown_Initialize, "MENU");
end

function MiniMapBattlefieldDropDown_Initialize()
	local info;
	local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch;
	local numQueued = 0;
	local numShown = 0;
	
	if ( CanHearthAndResurrectFromArea() ) then
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

			if ( status == "queued" ) then

				if ( teamSize == 0 ) then
					info = UIDropDownMenu_CreateInfo();
					info.text = CHANGE_INSTANCE;
					info.func = function(self, ...) ShowBattlefieldList(...) end;
					info.arg1 = i;
					info.notCheckable = 1;
					UIDropDownMenu_AddButton(info);
				end

				info = UIDropDownMenu_CreateInfo();
				info.text = LEAVE_QUEUE;
				info.func = function (self, ...) AcceptBattlefieldPort(...) end;
				info.arg1 = i;
				info.notCheckable = 1;
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

function IsAlreadyInQueue(mapName)
	local inQueue = nil;
	for index,value in pairs(PREVIOUS_BATTLEFIELD_QUEUES) do
		if ( value == mapName ) then
			inQueue = 1;
		end
	end
	return inQueue;
end
