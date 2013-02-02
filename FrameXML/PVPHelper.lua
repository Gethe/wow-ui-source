
BATTLEFIELD_TIMER_DELAY = 3;
BATTLEFIELD_TIMER_THRESHOLDS = {600, 300, 60, 15};
BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;

function PVPHelperFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_REQUEST_RESPONSE");
	self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_INVITE");
	self:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE");
	self:RegisterEvent("BATTLEFIELD_MGR_EJECT_PENDING");
	self:RegisterEvent("BATTLEFIELD_MGR_EJECTED");
	self:RegisterEvent("BATTLEFIELD_MGR_ENTERED");
	self:RegisterEvent("WARGAME_REQUESTED");
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	self.timerDelay = 0
end

function PVPHelperFrame_OnEvent(self, event, ...)
	if ( event == "UPDATE_BATTLEFIELD_STATUS" or event == "ZONE_CHANGED_NEW_AREA" 
			or event == "ZONE_CHANGED" or event == "PLAYER_ENTERING_WORLD") then
		local arg1 = ...
		PVP_UpdateStatus(false, arg1);
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
	elseif ( event == "BATTLEFIELD_MGR_QUEUE_INVITE" ) then
		local battleID, warmup, areaName = ...;
		if(warmup) then
			StaticPopup_Show("BFMGR_INVITED_TO_QUEUE_WARMUP", areaName, nil, battleID);
		else
			StaticPopup_Show("BFMGR_INVITED_TO_QUEUE", areaName, nil, battleID);
		end
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus(false);
	elseif ( event == "BATTLEFIELD_MGR_ENTRY_INVITE" ) then
		local battleID, areaName = ...;
		StaticPopup_Show("BFMGR_INVITED_TO_ENTER", areaName, nil, battleID);
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus(false);
	elseif ( event == "BATTLEFIELD_MGR_EJECT_PENDING" ) then
		local battleID, remote, areaName = ...;
		if(remote) then
			StaticPopup_Show("BFMGR_EJECT_PENDING_REMOTE", areaName, nil, arg1);
		else
		StaticPopup_Show("BFMGR_EJECT_PENDING", areaName, nil, arg1);
		end
		PVP_UpdateStatus(false);
	elseif ( event == "BATTLEFIELD_MGR_EJECTED" ) then
		local battleID, playerExited, relocated, battleActive, lowLevel, areaName = ...;
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE");
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE_WARMUP");
		StaticPopup_Hide("BFMGR_INVITED_TO_ENTER");
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		if(lowLevel) then
			StaticPopup_Show("BFMGR_PLAYER_LOW_LEVEL", areaName, nil, arg1);
		elseif (playerExited and battleActive and not relocated) then
			StaticPopup_Show("BFMGR_PLAYER_EXITED_BATTLE", areaName, nil, arg1);
		end
		PVP_UpdateStatus(false);
	elseif ( event == "BATTLEFIELD_MGR_ENTERED" ) then
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE");
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE_WARMUP");
		StaticPopup_Hide("BFMGR_INVITED_TO_ENTER");
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus(false);
	elseif ( event == "WARGAME_REQUESTED" ) then
		local challengerName, bgName, timeout = ...;
		PVPFramePopup_SetupPopUp(event, challengerName, bgName, timeout);
	elseif ( event == "BATTLEFIELDS_SHOW" ) then
		if ( not PVPUIFrame) then
			PVP_LoadUI();
			PVPQueueFrame_OnEvent(PVPQueueFrame, event, ...);
		end
	end
end


-------------------------------------------------------------------
-- Update PVP Queue status
-------------------------------------------------------------------

function PVP_UpdateStatus(tooltipOnly, mapIndex)
	local numberQueues = 0;
	local timeInQueue;
	local tooltip;
	local showRightClickText;
	BATTLEFIELD_SHUTDOWN_TIMER = 0;

	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(i);
		if ( mapName ) then
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
			if ( status == "confirm" ) then
				-- Have been accepted show enter battleground dialog
				if ( (i==mapIndex) and (not tooltipOnly) ) then
					StaticPopup_Show("CONFIRM_BATTLEFIELD_ENTRY", mapName, nil, i);
					PlaySound("PVPTHROUGHQUEUE");
				end
				PVPTimerFrame:SetScript("OnUpdate", PVPTimerFrame_OnUpdate);
				PVPTimerFrame.updating = true;
			elseif ( status == "active" ) then
				-- In the battleground
				BATTLEFIELD_SHUTDOWN_TIMER = GetBattlefieldInstanceExpiration()/1000;
				if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 and not PVPTimerFrame.updating ) then
					PVPTimerFrame:SetScript("OnUpdate", PVPTimerFrame_OnUpdate);
					PVPTimerFrame.updating = true;
					BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;
					PREVIOUS_BATTLEFIELD_MOD = 0;
				end
			elseif ( status == "error" ) then
				-- Should never happen haha
			end
		end
	end
end

-------------------------------------------------------------------------
-- PVP PopUp Functions
-------------------------------------------------------------------------

function PVPFramePopup_OnLoad(self)
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
	else
		for i = 1, GetMaxBattlefieldID() do
			if ( GetBattlefieldPortExpiration(i) > 0 ) then
				keepUpdating = true;
			end
		end
	end
	
	if ( not keepUpdating ) then
		PVPTimerFrame:SetScript("OnUpdate", nil);
		PVPTimerFrame.updating = false;
		return;
	end
	
	local frame = PVPHelperFrame;
	
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
