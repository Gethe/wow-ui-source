BATTLEFIELD_ZONES_DISPLAYED = 12;
BATTLEFIELD_ZONES_HEIGHT = 20;
BATTLEFIELD_SHUTDOWN_TIMER = 0;
BATTLEFIELD_TIMER_THRESHOLDS = {600, 300, 60, 15};
BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;
PREVIOUS_BATTLEFIELD_MOD = 0;
BATTLEFIELD_TIMER_DELAY = 3;
BATTLEFIELD_MAP_WIDTH = 320;
BATTLEFIELD_MAP_HEIGHT = 213;
CURRENT_BATTLEFIELD_QUEUES = {};
PREVIOUS_BATTLEFIELD_QUEUES = {};

function BattlefieldFrame_OnLoad(self)
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("BATTLEFIELDS_CLOSED");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PARTY_LEADER_CHANGED");

	BattlefieldFrame.timerDelay = 0;
end

function BattlefieldFrame_OnEvent(self, event, ...)
	if ( event == "BATTLEFIELDS_SHOW" ) then
		-- BATTLEFIELDS_SHOW is used for both ArenaFrame and BattlefieldFrame.  If this event is for arena, don't open BattlefieldFrame.
		if ( IsBattlefieldArena() ) then
			return;
		end

		ShowUIPanel(BattlefieldFrame);
		
		-- Default to first available
		SetSelectedBattlefield(0);

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
	WorldStateScoreFrameTimer:SetFormattedText(SecondsToTimeAbbrev(BATTLEFIELD_SHUTDOWN_TIMER));
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
					string = format(BATTLEGROUND_COMPLETE_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
				else
					string = format(BATTLEGROUND_COMPLETE_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
				end
				DEFAULT_CHAT_FRAME:AddMessage(string, info.r, info.g, info.b, info.id);
				PREVIOUS_BATTLEFIELD_MOD = currentMod;
				
			end
		end
	else
		BATTLEFIELD_SHUTDOWN_TIMER = 0;
	end
end

function BattlefieldFrame_Update()
	local zoneIndex;
	local zoneOffset = FauxScrollFrame_GetOffset(BattlefieldListScrollFrame);
	local playerLevel = UnitLevel("player");
	local button, buttonStatus;
	local instanceID;
	local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers, gameType, iconTexture, shortDescription, longDescription = GetBattlegroundInfo();
	
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
			button:SetText(localizedName.." "..instanceID);
			-- Set tooltip
			button.title = localizedName.." "..instanceID;
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
	
	BattlefieldFrameZoneDescription:SetText(longDescription);

	-- Enable or disable the group join button
	if ( CanJoinBattlefieldAsGroup() ) then
		if ( GetNumGroupMembers() > 0 and UnitIsGroupLeader("player") ) then
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
	for index,value in ipairs(PREVIOUS_BATTLEFIELD_QUEUES) do
		if ( value == mapName ) then
			inQueue = 1;
		end
	end
	return inQueue;
end