-- This LUA file implements LFGMinimapMixin for Blizzard_GroupFinder
-- Anything in Wrath onwards should use this implementation.

-------------------------------------------------------
----------LFGMinimapMixin
-------------------------------------------------------
LFGMinimapMixin = {};

function LFGMinimapMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	
	if MiniMap_BattleGroundQueueSeparateButton() then
		self:SetFrameLevel(self:GetFrameLevel()+1)
	else
		-- Combined button should be above battlefield frame
		self:SetFrameLevel(MiniMapBattlefieldFrame:GetFrameLevel()+1)
		-- Register for battlefield events to update visibility in combined mode
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
		self:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW");
		self:RegisterEvent("PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE");
	end

	self:SetPoint("TOPLEFT", 16, -123);
end

function LFGMinimapMixin:OnClick(button)
	if ( button == "RightButton" ) then
		QueueStatusDropdown_Show(self);
	else
		-- Handle both battlefield and LFG clicks in combined mode
		local inBattlefield, showScoreboard = QueueStatus_InActiveBattlefield();
		if ( IsInLFDBattlefield() ) then
			inBattlefield = true;
			showScoreboard = true;
		end
		local lfgListActiveEntry = C_LFGList.HasActiveEntryInfo();
		if ( inBattlefield ) then
			if ( showScoreboard ) then
				TogglePVPScoreboardOrResults();
			end
		elseif ( lfgListActiveEntry ) then
			LFGListUtil_OpenBestWindow(true);
		else
			--See if we have any active LFGList applications
			local apps = C_LFGList.GetApplications();
			for i=1, #apps do
				local _, appStatus = C_LFGList.GetApplicationInfo(apps[i]);
				if ( appStatus == "applied" or appStatus == "invited" ) then
					--We want to open to the LFGList screen
					LFGListUtil_OpenBestWindow(true);
					return;
				end
			end

			PVEFrame_ShowFrame();
		end
	end
end

function LFGMinimapMixin:OnEvent(event, ...)
	if (event == "PLAYER_ENTERING_WORLD" or
			event == "GROUP_ROSTER_UPDATE" or
			event == "LFG_UPDATE" or 
			event == "LFG_QUEUE_STATUS_UPDATE" or
			event == "UPDATE_BATTLEFIELD_STATUS" or
			event == "PVPQUEUE_ANYWHERE_SHOW" or
			event == "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE" ) then
		
		local separateButtons = MiniMap_BattleGroundQueueSeparateButton();
		
		--Try each LFG type
		local hasLFGMode = false;
		for i=1, NUM_LE_LFG_CATEGORYS do
			local mode, submode = GetLFGMode(i);
			if ( mode and submode ~= "noteleport" ) then
				hasLFGMode = true;
				break;
			end
		end

		--Try LFGList entries
		local hasApp = false;
		local apps = C_LFGList.GetApplications();
		for i=1, #apps do
			local _, appStatus = C_LFGList.GetApplicationInfo(apps[i]);
			if ( appStatus == "applied" or appStatus == "invited" ) then
				hasApp = true;
				break;
			end
		end
		
		local hasLFG = C_LFGList.HasActiveEntryInfo() or hasLFGMode or hasApp;
		
		if separateButtons then
			-- Separate buttons mode: Show LFG button only when there's LFG activity
			if ( hasLFG ) then
				self:Show();
				self.eye:StartAnimating();
			else
				self:Hide();
				self.eye:StopAnimating();
			end
		else
			-- Combined button mode: Show if there's any queue activity (LFG or BG)
			local hasBattlefieldQueue = false;
			local maxBattlefieldID = GetMaxBattlefieldID and GetMaxBattlefieldID() or MAX_BATTLEFIELD_QUEUES;
			for i=1, maxBattlefieldID do
				local status = GetBattlefieldStatus(i);
				if ( status ~= "none" ) then
					hasBattlefieldQueue = true;
					break;
				end
			end
			
			if ( hasLFG or hasBattlefieldQueue ) then
				self:Show();
				self.eye:StartAnimating();
			else
				self:Hide();
				self.eye:StopAnimating();
			end
		end
	end
end

function LFGMinimapMixin:OnEnter()
	QueueStatusFrame:Show();
end

function LFGMinimapMixin:OnLeave()
	QueueStatusFrame:Hide();
end
