
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
		PVP_UpdateStatus();
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
		PVP_UpdateStatus();
	elseif ( event == "BATTLEFIELD_MGR_QUEUE_INVITE" ) then
		local battleID, warmup, areaName = ...;
		if(warmup) then
			StaticPopup_Show("BFMGR_INVITED_TO_QUEUE_WARMUP", areaName, nil, battleID);
		else
			StaticPopup_Show("BFMGR_INVITED_TO_QUEUE", areaName, nil, battleID);
		end
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus();
	elseif ( event == "BATTLEFIELD_MGR_ENTRY_INVITE" ) then
		local battleID, areaName = ...;
		StaticPopup_Show("BFMGR_INVITED_TO_ENTER", areaName, nil, battleID);
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus();
	elseif ( event == "BATTLEFIELD_MGR_EJECT_PENDING" ) then
		local battleID, remote, areaName = ...;
		if(remote) then
			StaticPopup_Show("BFMGR_EJECT_PENDING_REMOTE", areaName, nil, arg1);
		else
		StaticPopup_Show("BFMGR_EJECT_PENDING", areaName, nil, arg1);
		end
		PVP_UpdateStatus();
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
		PVP_UpdateStatus();
	elseif ( event == "BATTLEFIELD_MGR_ENTERED" ) then
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE");
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE_WARMUP");
		StaticPopup_Hide("BFMGR_INVITED_TO_ENTER");
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus();
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

function PVP_UpdateStatus()
	BATTLEFIELD_SHUTDOWN_TIMER = 0;

	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(i);
		if ( status == "active" ) then
			-- In the battleground
			BATTLEFIELD_SHUTDOWN_TIMER = GetBattlefieldInstanceExpiration()/1000;
			if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 and not PVPTimerFrame.updating ) then
				PVPTimerFrame:SetScript("OnUpdate", PVPTimerFrame_OnUpdate);
				PVPTimerFrame.updating = true;
				BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;
				PREVIOUS_BATTLEFIELD_MOD = 0;
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

-------------------------------------------------------------------------
---- PVP Role Check Functions
---------------------------------------------------------------------------
function PVPRoleCheckPopup_OnLoad(self)
--	self:RegisterEvent("PVP_ROLE_CHECK_INITIATED");
	self:RegisterEvent("PVP_ROLE_UPDATE");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PVP_ROLE_CHECK_ROLE_CHOSEN");
end

function PVPRoleCheckPopup_OnEvent(self, event, ...)
--[[	if ( event == "PVP_ROLE_CHECK_INITIATED" ) then
		local active, queueName = GetPVPRoleCheckInfo();
		if ( active ) then
			PVPRoleCheckPopup_Display(self, queueName);
		end
	else]]
	if ( event == "PVP_ROLE_UPDATE" ) then
		PVPRoleCheckPopup_UpdateSelectedRoles(self);
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
		PVPRoleCheckPopup_UpdateRolesChangeable(self);
	elseif ( event == "PVP_ROLE_CHECK_ROLE_CHOSEN" ) then
		local player, isTank, isHealer, isDamage = ...;

		--Yes, consecutive string concatenation == bad for garbage collection. But the alternative is either extremely unslightly or localization unfriendly. (Also, this happens fairly rarely)
		local roleList;
		
		if ( isTank ) then
			roleList = INLINE_TANK_ICON.." "..TANK;
		end
		if ( isHealer ) then
			if ( roleList ) then
				roleList = roleList..PLAYER_LIST_DELIMITER.." "..INLINE_HEALER_ICON.." "..HEALER;
			else
				roleList = INLINE_HEALER_ICON.." "..HEALER;
			end
		end
		if ( isDamage ) then
			if ( roleList ) then
				roleList = roleList..PLAYER_LIST_DELIMITER.." "..INLINE_DAMAGER_ICON.." "..DAMAGER;
			else
				roleList = INLINE_DAMAGER_ICON.." "..DAMAGER;
			end
		end
		assert(roleList);
		ChatFrame_DisplaySystemMessageInPrimary(string.format(LFG_ROLE_CHECK_ROLE_CHOSEN, player, roleList));
	end
end

function PVPRoleCheckPopup_OnShow(self)
	PlaySound("ReadyCheck");
	PVPRoleCheckPopup_UpdateSelectedRoles(self);
	PVPRoleCheckPopup_UpdateRolesChangeable(self);
end

function PVPRoleCheckPopup_UpdateAvailableRoles(tankButton, healButton, dpsButton)
	return LFG_UpdateAvailableRoles(tankButton, healButton, dpsButton);
end

function PVPRoleCheckPopup_UpdateRolesChangeable(self)
	if ( PVPHelper_CanChangeRoles() ) then
		PVPRoleCheckPopup_UpdateAvailableRoles(self.TankIcon, self.HealerIcon, self.DPSIcon);
	else
		LFG_DisableRoleButton(self.TankIcon);
		LFG_DisableRoleButton(self.HealerIcon);
		LFG_DisableRoleButton(self.DPSIcon);
	end
end

function PVPRoleCheckPopup_UpdateSelectedRoles(self)
	local tank, healer, dps = GetPVPRoles();
	self.TankIcon.checkButton:SetChecked(tank);
	self.HealerIcon.checkButton:SetChecked(healer);
	self.DPSIcon.checkButton:SetChecked(dps);
end

function PVPRoleCheckPopup_Display(self, queueName)
	PVPRoleCheckPopup_UpdateRolesChangeable(self);
	PVPRoleCheckPopup_UpdateSelectedRoles(self);

	self.Description.Text:SetFormattedText(QUEUED_FOR, NORMAL_FONT_COLOR_CODE..queueName..FONT_COLOR_CODE_CLOSE);
	self.Description:SetWidth(self.Description.Text:GetWidth() + 10);
	self.Description:SetHeight(self.Description.Text:GetHeight());
	StaticPopupSpecial_Show(self);
end

function PVPRoleCheckPopup_RoleButtonClicked(self)
	PVPRoleCheckPopup_SetRoles();
end

function PVPRoleCheckPopup_SetRoles()
	SetPVPRoles(PVPRoleCheckPopup.TankIcon.checkButton:GetChecked(),
		PVPRoleCheckPopup.HealerIcon.checkButton:GetChecked(),
		PVPRoleCheckPopup.DPSIcon.checkButton:GetChecked());
end

function PVPRoleCheckPopupAccept_OnClick()
	PlaySound("igCharacterInfoTab");
	SetPVPRoles(PVPRoleCheckPopupRoleButtonTank.checkButton:GetChecked(),
		PVPRoleCheckPopupRoleButtonHealer.checkButton:GetChecked(),
		PVPRoleCheckPopupRoleButtonDPS.checkButton:GetChecked());
--	if ( CompletePVPRoleCheck(true) ) then
--		StaticPopupSpecial_Hide(PVPRoleCheckPopup);
--	end
end

function PVPRoleCheckPopupDecline_OnClick()
	PlaySound("igCharacterInfoTab");
	StaticPopupSpecial_Hide(PVPRoleCheckPopup);
--	CompletePVPRoleCheck(false);
end

-------------------------------------------------------------------------
---- PVP Ready Dialog
---------------------------------------------------------------------------
function PVPReadyDialog_OnLoad(self)
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
end

function PVPReadyDialog_OnEvent(self, event, ...)
	if ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
		local i = ...;
		local status, mapName, teamSize, registeredMatch, suspendedQueue, queueType, gameType, role = GetBattlefieldStatus(i);
		if ( status == "confirm" ) then
			if ( not PVPReadyDialog_Showing(i) ) then
				PVPReadyDialog_Display(self, i, mapName, registeredMatch, queueType, gameType, role);
			end
		else
			if ( PVPReadyDialog_Showing(i) ) then
				StaticPopupSpecial_Hide(self);
			end
		end
	end
end


function PVPReadyDialog_Showing(index)
	return PVPReadyDialog:IsShown() and PVPReadyDialog.activeIndex == index;
end

function PVPReadyDialog_Display(self, index, displayName, isRated, queueType, gameType, role)
	PVPReadyDialog.activeIndex = index;

	local factionGroup = UnitFactionGroup("player");

	local height = 150;
	if ( PVPHelper_QueueNeedsRoles(queueType, isRated) ) then
		height = height + 20;
		self.bottomArt:SetTexCoord(0.0, 0.5605, 0.0, 0.5625);

		self.roleDescription:Show();
		self.roleLabel:Show();
		self.roleIcon:Show();
		self.roleIcon.texture:SetTexCoord(GetTexCoordsForRole(role));
		self.roleLabel:SetText(_G[role]);
	else
		self.bottomArt:SetTexCoord(0.0, 0.18, 0.0, 0.5625);

		self.roleDescription:Hide();
		self.roleLabel:Hide();
		self.roleIcon:Hide();
	end

	local showTitle = true;
	if ( queueType == "BATTLEGROUND" ) then
		if ( isRated ) then
			self.background:SetTexCoord(0, 1, 0, 102/128);
			self.background:SetTexture("Interface\\PVPFrame\\PvpBg-AlteracValley-ToastBG");
			self.label:SetText(RATED_BATTLEGROUND_IS_READY);
		else
			self.background:SetTexCoord(0, 1, 0, 1);
			self.background:SetTexture("Interface\\LFGFrame\\UI-PVP-BACKGROUND-"..(factionGroup or "Alliance"));
			self.label:SetText(BATTLEGROUND_IS_READY);
		end
	elseif ( queueType == "ARENA" ) then
		self.background:SetTexCoord(0, 1, 25/128, 91/128);
		self.background:SetTexture("Interface\\PVPFrame\\PvpBg-NagrandArena-ToastBG");
		showTitle = false;
		self.label:SetText(ARENA_IS_READY);
	elseif ( queueType == "WARGAME" ) then
		self.background:SetTexCoord(0, 1, 0, 102/128);
		self.background:SetTexture("Interface\\PVPFrame\\PvpBg-AlteracValley-ToastBG");
		self.label:SetText(WARGAME_IS_READY);
	else
		self.label:SetText(BATTLEGROUND_IS_READY);
	end

	if ( showTitle ) then
		self.instanceInfo:Show();
		height = height + 40;
	else
		self.instanceInfo:Hide();
	end

	self.instanceInfo.name:SetText(displayName);
	self.instanceInfo.statusText:SetText(gameType);

	self:SetHeight(height);

	PlaySound("PVPTHROUGHQUEUE");
	StaticPopupSpecial_Show(self);
end

-------------------------------------------------------------------------
---- PVP Helper Functions
---------------------------------------------------------------------------
function PVPHelper_CanChangeRoles()
	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspendedQueue, queueType, gameType, role = GetBattlefieldStatus(i);
		if ( status ~= "none" and status ~= "active" and PVPHelper_QueueNeedsRoles(queueType, registeredMatch) ) then
			return false;
		end
	end
	return true;
end

function PVPHelper_QueueNeedsRoles(queueType, isRated)
	return queueType == "BATTLEGROUND" and not isRated;
end
