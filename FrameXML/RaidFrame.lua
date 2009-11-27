
MAX_RAID_MEMBERS = 40;
NUM_RAID_GROUPS = 8;
MEMBERS_PER_RAID_GROUP = 5;
MAX_RAID_INFOS = 20;

function RaidFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("UPDATE_INSTANCE_INFO");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("VOICE_STATUS_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("PARTY_LFG_RESTRICTED");

	-- Update party frame visibility
	RaidOptionsFrame_UpdatePartyFrames();
	RaidFrame_Update();

	RaidFrame.hasRaidInfo = nil;
end

function RaidFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		RequestRaidInfo();
	elseif ( event == "PLAYER_LOGIN" ) then
		if ( GetNumRaidMembers() > 0 ) then
			RaidFrame_LoadUI();
			RaidFrame_Update();
		end
	elseif ( event == "RAID_ROSTER_UPDATE" ) then
		RaidFrame_LoadUI();
		RaidFrame_Update();
		RaidPullout_RenewFrames();
	elseif ( event == "READY_CHECK" or
		 event == "READY_CHECK_CONFIRM" ) then
		if ( RaidFrame:IsShown() and RaidGroupFrame_Update ) then
			RaidGroupFrame_Update();
		end
	elseif ( event == "READY_CHECK_FINISHED" ) then
		if ( RaidFrame:IsShown() and RaidGroupFrame_ReadyCheckFinished ) then
			RaidGroupFrame_ReadyCheckFinished();
		end
	elseif ( event == "UPDATE_INSTANCE_INFO" ) then
		if ( not RaidFrame.hasRaidInfo ) then
			-- Set flag
			RaidFrame.hasRaidInfo = 1;
			return;
		end
		if ( GetNumSavedInstances() > 0 ) then
			RaidFrameRaidInfoButton:Enable();
		else
			RaidFrameRaidInfoButton:Disable();
		end
		RaidInfoFrame_Update(true);
	elseif ( event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or
		event == "VOICE_STATUS_UPDATE" or event == "PARTY_LFG_RESTRICTED" ) then
		RaidFrame_Update();
	end
end

function RaidFrame_Update()
	-- If not in a raid hide all the UI and just display raid explanation text
	if ( GetNumRaidMembers() == 0 ) then
		RaidFrameConvertToRaidButton:Show();
		if ( GetPartyMember(1) and IsPartyLeader() and UnitLevel("player") >= 10 and not HasLFGRestrictions() ) then
			RaidFrameConvertToRaidButton:Enable();
		else
			RaidFrameConvertToRaidButton:Disable();
		end
		RaidFrameNotInRaid:Show();
	else
		RaidFrameConvertToRaidButton:Hide();
		RaidFrameNotInRaid:Hide();
	end

	if ( RaidGroupFrame_Update ) then
		RaidGroupFrame_Update();
	end
end

-- Function for raid options
function RaidOptionsFrame_UpdatePartyFrames()
	if ( HIDE_PARTY_INTERFACE == "1" and GetNumRaidMembers() > 0) then
		HidePartyFrame();
	else
		HidePartyFrame();
		ShowPartyFrame();
	end
	UpdatePartyMemberBackground();
end

-- Populates Raid Info Data
function RaidInfoFrame_Update(scrollToSelected)
	RaidInfoFrame_UpdateSelectedIndex();
	
	local scrollFrame = RaidInfoScrollFrame;
	local savedInstances = GetNumSavedInstances();
	local instanceName, instanceID, instanceReset, instanceDifficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName;
	local frameName, frameNameText, frameID, frameReset, width;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local buttonHeight = buttons[1]:GetHeight();
	
	if ( scrollToSelected == true and RaidInfoFrame.selectedIndex ) then --Using == true in case the HybridScrollFrame .update is changed to pass in the parent.
		local button = buttons[RaidInfoFrame.selectedIndex - offset]
		if ( not button or (button:GetTop() > scrollFrame:GetTop()) or (button:GetBottom() < scrollFrame:GetBottom()) ) then
			local scrollFrame = RaidInfoScrollFrame;
			local buttonHeight = scrollFrame.buttons[1]:GetHeight();
			local scrollValue = min(((RaidInfoFrame.selectedIndex - 1) * buttonHeight), scrollFrame.range)
			if ( scrollValue ~= scrollFrame.scrollBar:GetValue() ) then
				scrollFrame.scrollBar:SetValue(scrollValue);
			end
		end
	end

	offset = HybridScrollFrame_GetOffset(scrollFrame);	--May have changed in the previous section to move selected parts into view.

	local mouseIsOverScrollFrame = scrollFrame:IsVisible() and scrollFrame:IsMouseOver();

	for i=1, numButtons do
		local frame = buttons[i];
		local index = i + offset;

		if ( index <=  savedInstances) then
			instanceName, instanceID, instanceReset, instanceDifficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName = GetSavedInstanceInfo(index);

			frame.instanceID = instanceID;
			frame.longInstanceID = string.format("%x%x", instanceIDMostSig, instanceID);
			frame:SetID(index);

			if ( RaidInfoFrame.selectedRaidID == frame.longInstanceID ) then
				frame:LockHighlight();
			else
				frame:UnlockHighlight();
			end

			frame.difficulty:SetText(difficultyName);

			if ( extended or locked ) then
				frame.reset:SetText(SecondsToTime(instanceReset, true, nil, 3));
				frame.name:SetText(instanceName);
			else
				frame.reset:SetFormattedText("|cff808080%s|r", RAID_INSTANCE_EXPIRES_EXPIRED);
				frame.name:SetFormattedText("|cff808080%s|r", instanceName);
			end
			
			if ( extended ) then
				frame.extended:Show();
			else
				frame.extended:Hide();
			end
			
			frame:Show();
			
			if ( mouseIsOverScrollFrame and frame:IsMouseOver() ) then
				RaidInfoInstance_OnEnter(frame);
			end
		else
			frame:Hide();
		end	
	end
	HybridScrollFrame_Update(scrollFrame, savedInstances * buttonHeight, scrollFrame:GetHeight());
end

function RaidInfoScrollFrame_OnLoad(self)
	HybridScrollFrame_OnLoad(self);
	self.update = RaidInfoFrame_Update;
	HybridScrollFrame_CreateButtons(self, "RaidInfoInstanceTemplate");
end

--Makes the button look likes it's being pressed
function RaidInfoInstance_OnMouseDown(self)
	self.name:SetPoint("TOPLEFT", 7, -12);
	self.reset:SetPoint("TOPRIGHT", 2, -13);
end

function RaidInfoInstance_OnMouseUp(self)
	self.name:SetPoint("TOPLEFT", 5, -10);
	self.reset:SetPoint("TOPRIGHT", 0, -11);
end

function RaidInfoInstance_OnClick(self)
	RaidInfoFrame.selectedRaidID = self.longInstanceID;
	RaidInfoFrame_Update();
end

function RaidInfoInstance_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.name:GetText());
	GameTooltip:AddLine(self.difficulty:GetText(), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine(format(INSTANCE_ID, self.instanceID), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:Show();
end

function RaidInfoFrame_UpdateSelectedIndex()
	local savedInstances = GetNumSavedInstances();
	for index=1, savedInstances do
		local instanceName, instanceID, instanceReset, instanceDifficulty, locked, extended, instanceIDMostSig = GetSavedInstanceInfo(index);
		if ( format("%x%x", instanceIDMostSig, instanceID) == RaidInfoFrame.selectedRaidID ) then
			RaidInfoFrame.selectedIndex = index;
			RaidInfoExtendButton:Enable();
			if ( extended ) then
				RaidInfoExtendButton.doExtend = false;
				RaidInfoExtendButton:SetText(UNEXTEND_RAID_LOCK);
			else
				RaidInfoExtendButton.doExtend = true;
				if ( locked ) then
					RaidInfoExtendButton:SetText(EXTEND_RAID_LOCK);
				else
					RaidInfoExtendButton:SetText(REACTIVATE_RAID_LOCK);
				end
			end
			return;
		end
	end
	RaidInfoFrame.selectedIndex = nil;
	RaidInfoExtendButton:Disable();
end

function RaidInfoExtendButton_OnClick(self)
	SetSavedInstanceExtend(RaidInfoFrame.selectedIndex, self.doExtend);
	RequestRaidInfo();
	RaidInfoFrame_Update();
end
