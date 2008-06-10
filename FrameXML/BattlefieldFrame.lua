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


function BattlefieldFrame_OnLoad()
	this:RegisterEvent("BATTLEFIELDS_SHOW");
	this:RegisterEvent("BATTLEFIELDS_CLOSED");
	this:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	this:RegisterEvent("PARTY_LEADER_CHANGED");

	BattlefieldFrame.timerDelay = 0;
end

function BattlefieldFrame_OnEvent()
	if ( event == "BATTLEFIELDS_SHOW" ) then
		ShowUIPanel(BattlefieldFrame);
		
		-- Default to first available
		SetSelectedBattlefield(0);

		if ( not BattlefieldFrame:IsVisible() ) then
			CloseBattlefield();
			return;
		end
		UpdateMicroButtons();
		BattlefieldFrame_Update();
	elseif ( event == "BATTLEFIELDS_CLOSED" ) then
		HideUIPanel(BattlefieldFrame);
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
		BattlefieldFrame_UpdateStatus();
		BattlefieldFrame_Update();
	end
	if ( event == "PARTY_LEADER_CHANGED" ) then
		BattlefieldFrame_Update();
	end
end

function BattlefieldFrame_OnUpdate(elapsed)
	if ( BATTLEFIELD_SHUTDOWN_TIMER == 0 ) then
		return;
	end
	BATTLEFIELD_SHUTDOWN_TIMER = BATTLEFIELD_SHUTDOWN_TIMER - elapsed;
	-- Set the time for the score frame
	WorldStateScoreFrameTimer:SetText(SecondsToTimeAbbrev(BATTLEFIELD_SHUTDOWN_TIMER));
	-- Check if I should send a message only once every 3 seconds (BATTLEFIELD_TIMER_DELAY)
	BattlefieldFrame.timerDelay = BattlefieldFrame.timerDelay + elapsed;
	if ( BattlefieldFrame.timerDelay < BATTLEFIELD_TIMER_DELAY ) then
		return;
	else
		BattlefieldFrame.timerDelay = 0
	end
	
	local threshold = BATTLEFIELD_TIMER_THRESHOLDS[BATTLEFIELD_TIMER_THRESHOLD_INDEX];
	if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 ) then
		if ( BATTLEFIELD_SHUTDOWN_TIMER < threshold and BATTLEFIELD_TIMER_THRESHOLD_INDEX ~= getn(BATTLEFIELD_TIMER_THRESHOLDS) ) then
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
					string = format(INSTANCE_COMPLETE_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
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

function BattlefieldFrame_UpdateStatus(tooltipOnly)
	local status, mapName, instanceID;
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
		for index, value in CURRENT_BATTLEFIELD_QUEUES do
			tinsert(PREVIOUS_BATTLEFIELD_QUEUES, value);
		end
		CURRENT_BATTLEFIELD_QUEUES = {};
	end

	for i=1, MAX_BATTLEFIELD_QUEUES do
		status, mapName, instanceID = GetBattlefieldStatus(i);
		if ( instanceID ~= 0 ) then
			mapName = mapName.." "..instanceID;
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
				tooltip = format(BATTLEFIELD_IN_QUEUE, mapName, waitTime, SecondsToTime(timeInQueue));
				
				if ( not tooltipOnly ) then
					if ( not IsAlreadyInQueue(mapName) ) then
						PlaySound("PVPENTERQUEUE");
						UIFrameFadeIn(MiniMapBattlefieldFrame, CHAT_FRAME_FADE_TIME);
						BattlegroundShineFadeIn();
					end
					tinsert(CURRENT_BATTLEFIELD_QUEUES, mapName);
				end
				showRightClickText = 1;
			elseif ( status == "confirm" ) then
				-- Have been accepted show enter battleground dialog
				tooltip = format(BATTLEFIELD_QUEUE_CONFIRM, mapName, SecondsToTime(GetBattlefieldPortExpiration(i)/1000));
				if ( not tooltipOnly ) then
					local dialog = StaticPopup_Show("CONFIRM_BATTLEFIELD_ENTRY", mapName, nil, i);
					if ( dialog ) then
						dialog.data = i;
					end
					PlaySound("PVPTHROUGHQUEUE");
					MiniMapBattlefieldFrame:Show();
				end
				showRightClickText = 1;
			elseif ( status == "active" ) then
				-- In the battleground
				tooltip = format(BATTLEFIELD_IN_BATTLEFIELD, mapName);
				
				BATTLEFIELD_SHUTDOWN_TIMER = GetBattlefieldInstanceExpiration()/1000;
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
	end
	
	if ( not tooltipOnly ) then
		if ( numberQueues == 0 ) then
			-- Clear everything out
			MiniMapBattlefieldFrame:Hide();
		else
			MiniMapBattlefieldFrame:Show();
		end
		
		-- Set minimap icon here since it bugs out on login
		if ( UnitFactionGroup("player") ) then
			MiniMapBattlefieldIcon:SetTexture("Interface\\BattlefieldFrame\\Battleground-"..UnitFactionGroup("player"));
		end
	end
end

function BattlefieldFrame_Update()
	local zoneIndex;
	local zoneOffset = FauxScrollFrame_GetOffset(BattlefieldListScrollFrame);
	local playerLevel = UnitLevel("player");
	local button, buttonStatus;
	local instanceID;
	local mapName, mapDescription, minLevel, maxLevel, mapID, mapX, mapY, mapFull = GetBattlefieldInfo();
	
	-- Set title text
	BattlefieldFrameFrameLabel:SetText(mapName);

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
			elseif ( button.title == FIRST_AVAILABLE and queueMapName == mapName and GetNumBattlefields() == 0 ) then
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
	
	

	FauxScrollFrame_Update(BattlefieldListScrollFrame, numBattlefields, BATTLEFIELD_ZONES_DISPLAYED, BATTLEFIELD_ZONES_HEIGHT, "BattlefieldZone", 293, 315);
end

function BattlefieldButton_OnClick(id)
	SetSelectedBattlefield(FauxScrollFrame_GetOffset(BattlefieldListScrollFrame) + id - 1);
	BattlefieldFrame_Update();
end

function BattlefieldFrameJoinButton_OnClick(joinAsGroup)
	if ( joinAsGroup ) then
		JoinBattlefield(GetSelectedBattlefield(), 1);
	else
		JoinBattlefield(GetSelectedBattlefield());
	end
	
	HideUIPanel(BattlefieldFrame);
end

function MiniMapBattlefieldDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, MiniMapBattlefieldDropDown_Initialize, "MENU");
end

function MiniMapBattlefieldDropDown_Initialize()
	local info;
	local status, mapName, instanceID;
	local numQueued = 0;
	for i=1, MAX_BATTLEFIELD_QUEUES do
		status, mapName, instanceID = GetBattlefieldStatus(i);
		if ( status == "queued" or status == "confirm" ) then
			numQueued = numQueued+1;
			-- Add a spacer if there were dropdown items before this
			if ( numQueued > 1 ) then
				info = {};
				info.text = "";
				info.isTitle = 1;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			end
			
			info = {};
			info.text = mapName;
			info.isTitle = 1;
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);
			if ( status == "queued" ) then
				info = {};
				info.text = CHANGE_INSTANCE;
				info.func = ShowBattlefieldList;
				info.arg1 = i;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
				info = {};
				info.text = LEAVE_QUEUE;
				info.func = AcceptBattlefieldPort;
				info.arg1 = i;
				info.arg2 = nil;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			elseif ( status == "confirm" ) then
				info = {};
				info.text = ENTER_BATTLE;
				info.func = AcceptBattlefieldPort;
				info.arg1 = i;
				info.arg2 = 1;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
				info = {};
				info.text = LEAVE_QUEUE;
				info.func = AcceptBattlefieldPort;
				info.arg1 = i;
				info.arg2 = nil;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			end			
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
	for index,value in PREVIOUS_BATTLEFIELD_QUEUES do
		if ( value == mapName ) then
			inQueue = 1;
		end
	end
	return inQueue;
end