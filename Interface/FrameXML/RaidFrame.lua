
MAX_RAID_MEMBERS = 40;
NUM_RAID_GROUPS = 8;
MEMBERS_PER_RAID_GROUP = 5;
MAX_RAID_INFOS = 20;

function RaidParentFrame_OnLoad(self)
	self:SetPortraitToAsset("Interface\\LFGFrame\\UI-LFR-PORTRAIT");
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, 1);
end

function RaidFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UPDATE_INSTANCE_INFO");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("PARTY_LFG_RESTRICTED");

	-- Update party frame visibility
	RaidOptionsFrame_UpdatePartyFrames();
	RaidFrame_Update();

	RaidFrame.hasRaidInfo = nil;
	-- Set this as the first tab
	RaidParentFrame.selectectTab = 1;
	ClaimRaidFrame(RaidParentFrame);
end

function RaidFrame_OnShow(self)
	ButtonFrameTemplate_ShowAttic(self:GetParent());
	self:GetParent().TitleText:SetText(RAID);

	RaidFrame_Update();

	if ( GetNumSavedInstances() + GetNumSavedWorldBosses() > 0 ) then
		RaidFrameRaidInfoButton:Enable();
	else
		RaidFrameRaidInfoButton:Disable();
	end

	RequestRaidInfo();

	UpdateMicroButtons();
end

function RaidFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		RequestRaidInfo();
	elseif ( event == "PLAYER_LOGIN" ) then
		if ( IsInRaid() ) then
			RaidFrame_LoadUI();
			RaidFrame_Update();
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
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
		if ( GetNumSavedInstances() + GetNumSavedWorldBosses() > 0 ) then
			RaidFrameRaidInfoButton:Enable();
		else
			RaidFrameRaidInfoButton:Disable();
		end
		RaidInfoFrame_Update(true);
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LEADER_CHANGED" or event == "PARTY_LFG_RESTRICTED" ) then
		RaidFrame_Update();
	end
end

function RaidParentFrame_SetView(tab)
	if ( tab == 1 ) then
		RaidParentFrame.selectectTab = 1;
		LFRParentFrame:Hide();
		ClaimRaidFrame(RaidParentFrame);
		RaidFrame:Show();
		PanelTemplates_Tab_OnClick(RaidParentFrameTab1, RaidParentFrame);
	elseif ( tab == 2 ) then
		RaidParentFrame.selectectTab = 2;
		if ( RaidFrame:GetParent() == RaidParentFrame ) then
			RaidFrame:Hide();
		end
		LFRParentFrame:Show();
		LFRFrame_SetActiveTab(LFRParentFrame.activeTab);
		PanelTemplates_Tab_OnClick(RaidParentFrameTab2, RaidParentFrame);
	end
end

function RaidFrame_Update()
	-- If not in a raid hide all the UI and just display raid explanation text
	if ( not IsInRaid() ) then
		RaidFrameConvertToRaidButton:Show();
		local convertToRaid = true;
		local canConvertToRaid = C_PartyInfo.AllowedToDoPartyConversion(convertToRaid);
		RaidFrameConvertToRaidButton:SetEnabled(canConvertToRaid);

		RaidFrameNotInRaid:Show();
		ButtonFrameTemplate_ShowButtonBar(FriendsFrame);
	else
		RaidFrameConvertToRaidButton:Hide();
		RaidFrameNotInRaid:Hide();
		ButtonFrameTemplate_HideButtonBar(FriendsFrame);
	end

	if ( RaidGroupFrame_Update ) then
		RaidGroupFrame_Update();
	end
end

function RaidFrame_ConvertToRaid()
	C_PartyInfo.ConvertToRaid();
end

-- Function for raid options
function RaidOptionsFrame_UpdatePartyFrames()
	if ( GetDisplayedAllyFrames() ~= "party" ) then
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
	local savedWorldBosses = GetNumSavedWorldBosses();
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

		if ( index <= savedInstances + savedWorldBosses) then
			if (index <= savedInstances) then
				instanceName, instanceID, instanceReset, instanceDifficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName = GetSavedInstanceInfo(index);
				frame.worldBossID = nil;
				frame.instanceID = instanceID;
				frame.longInstanceID = string.format("%s_%s", instanceIDMostSig, instanceID);
			else
				instanceName, instanceID, instanceReset = GetSavedWorldBossInfo(index - savedInstances);
				locked = true;
				extended = false;
				difficultyName = RAID_INFO_WORLD_BOSS;
				frame.worldBossID = instanceID;
				frame.instanceID = nil;
				frame.longInstanceID = nil;
			end

			frame:SetID(index);

			if ( RaidInfoFrame.selectedIndex == index ) then
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
	HybridScrollFrame_Update(scrollFrame, (savedInstances + savedWorldBosses) * buttonHeight, scrollFrame:GetHeight());
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
	if ( IsModifiedClick("CHATLINK") ) then
		if (self.instanceID) then
			ChatEdit_InsertLink(GetSavedInstanceChatLink(self:GetID()));
		else
			-- No chat links for World Boss locks yet
		end
	else
		RaidInfoFrame.selectedRaidID = self.longInstanceID;
		RaidInfoFrame.selectedWorldBossID = self.worldBossID;
		RaidInfoFrame_Update();
	end
end

function RaidInfoInstance_OnEnter(self)
	if (self.instanceID) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetInstanceLockEncountersComplete(self:GetID());
		GameTooltip:Show();
	else
		local index = self:GetID() - GetNumSavedInstances();
		local instanceName, instanceID, instanceReset = GetSavedWorldBossInfo(index);
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(instanceName);
		GameTooltip:Show();
	end
end

function RaidInfoFrame_UpdateSelectedIndex()
	if (RaidInfoFrame.selectedRaidID) then
		local savedInstances = GetNumSavedInstances();
		for index=1, savedInstances do
			local instanceName, instanceID, instanceReset, instanceDifficulty, locked, extended, instanceIDMostSig, _, _, _, _, _, extendDisabled = GetSavedInstanceInfo(index);
			if ( string.format("%s_%s", instanceIDMostSig, instanceID) == RaidInfoFrame.selectedRaidID ) then
				RaidInfoFrame.selectedIndex = index;
				if ( extendDisabled ) then
					RaidInfoExtendButton:Disable();
				else
					RaidInfoExtendButton:Enable();
				end
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
	elseif (RaidInfoFrame.selectedWorldBossID) then
		local savedInstances = GetNumSavedWorldBosses();
		for index=1, savedInstances do
			local _, worldBossID, _ = GetSavedWorldBossInfo(index);
			if (worldBossID == RaidInfoFrame.selectedWorldBossID) then
				RaidInfoExtendButton:SetText(EXTEND_RAID_LOCK);
				RaidInfoExtendButton:Disable();
				RaidInfoFrame.selectedIndex = index + GetNumSavedInstances();
				return;
			end
		end
	end
	RaidInfoFrame.selectedIndex = nil;
	RaidInfoExtendButton:Disable();
end

function RaidInfoExtendButton_OnClick(self)
	if(RaidInfoFrame.selectedIndex <= GetNumSavedInstances()) then
		SetSavedInstanceExtend(RaidInfoFrame.selectedIndex, self.doExtend);
		RequestRaidInfo();
		RaidInfoFrame_Update();
	end
end

function RaidFrameAllAssistCheckButton_UpdateAvailable(self)
	self:SetChecked(IsEveryoneAssistant());
	if ( UnitIsGroupLeader("player") ) then
		self:Enable();
		self.text:SetFontObject(GameFontNormalSmall);
	else
		self:Disable();
		self.text:SetFontObject(GameFontDisableSmall);
	end
end





--4.3 Temp - Chaz
function ClaimRaidFrame(parent)
	local currentParent = RaidFrame:GetParent();
	if currentParent == parent then
		return;
	end

	RaidFrame:SetParent(parent);
	RaidFrame:ClearAllPoints();
	RaidFrame:SetPoint("TOPLEFT", 0, 0);
	RaidFrame:SetPoint("BOTTOMRIGHT", 0, 0);

	if RaidFrame:IsShown() and currentParent then
		-- more hackiness - Serban
		if ( currentParent == RaidParentFrame ) then
			RaidParentFrame_SetView(2);
		else
			_G[currentParent:GetName().."Tab1"]:Click();
		end
	end
end





