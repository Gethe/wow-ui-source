
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
	UpdateRaidAndPartyFrames();
	RaidFrame_Update();

	-- Used in ChatFrame.lua
	RaidFrame.hasRaidInfo = nil;
	-- Set this as the first tab
	RaidParentFrame.selectTab = 1;
	ClaimRaidFrame(RaidParentFrame);

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("RaidInfoInstanceTemplate", function(button, elementData)
		RaidInfoFrame_InitButton(button, elementData);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(RaidInfoFrame.ScrollBox, RaidInfoFrame.ScrollBar, view);
end

function RaidFrame_OnShow(self)
	ButtonFrameTemplate_ShowAttic(self:GetParent());
	self:GetParent():GetTitleText():SetText(RAID);

	RaidFrame_Update();

	RaidFrameRaidInfoButton:SetEnabled(GetNumSavedInstances() + GetNumSavedWorldBosses() > 0);

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
		RaidFrameRaidInfoButton:SetEnabled(GetNumSavedInstances() + GetNumSavedWorldBosses() > 0);
		RaidInfoFrame_Update();
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LEADER_CHANGED" or event == "PARTY_LFG_RESTRICTED" ) then
		RaidFrame_Update();
	end
end

function RaidParentFrame_SetView(tab)
	RaidParentFrame.selectTab = tab;
	if ( tab == 1 ) then
		ClaimRaidFrame(RaidParentFrame);
		RaidFrame:Show();
		PanelTemplates_Tab_OnClick(RaidParentFrameTab1, RaidParentFrame);
	elseif ( tab == 2 ) then
		if ( RaidFrame:GetParent() == RaidParentFrame ) then
			RaidFrame:Hide();
		end
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

function UpdateRaidAndPartyFrames()
	PartyFrame:HidePartyFrames();

	if CompactRaidFrameManager_UpdateShown then
		CompactRaidFrameManager_UpdateShown();
	end

	PartyFrame:UpdatePartyFrames();
end

function RaidInfoFrame_InitButton(button, elementData)
	local function InitButton(extended, locked, reset, name, difficulty)
		if extended or locked then
			button.reset:SetText(SecondsToTime(reset, true, nil, 3));
			button.name:SetText(name);
		else
			button.reset:SetFormattedText("|cff808080%s|r", RAID_INSTANCE_EXPIRES_EXPIRED);
			button.name:SetFormattedText("|cff808080%s|r", name);
		end
		button.difficulty:SetText(difficulty);
		button.extended:SetShown(extended);
	end

	local index = elementData.index;
	if elementData.isInstance then
		local name, instanceID, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName = GetSavedInstanceInfo(index);
		InitButton(extended, locked, reset, name, difficultyName);
		button.instanceID = instanceID;
	else
		local name, _, reset = GetSavedWorldBossInfo(index);
		local locked = true;
		local extended = false;
		InitButton(extended, locked, reset, name, RAID_INFO_WORLD_BOSS);

		button.instanceID = nil;
	end

	local selected = RaidInfoFrame.selectedIndex == index and RaidInfoFrame.selectedIsInstance == elementData.isInstance;
	RaidInfoFrame_SetButtonSelected(button, selected);
end

function RaidInfoFrame_SetButtonSelected(button, selected)
	if selected then
		button:LockHighlight();
	else
		button:UnlockHighlight();
	end
end

function RaidInfoFrame_Update()
	local dataProvider = CreateDataProvider();
	for index = 1, GetNumSavedInstances() do
		dataProvider:Insert({index=index, isInstance=true});
	end

	for index = 1, GetNumSavedWorldBosses() do
		dataProvider:Insert({index=index});
	end

	RaidInfoFrame.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	RaidInfoFrame_UpdateButtons();
end

function RaidInfoInstance_OnMouseDown(self)
	self.name:SetPoint("TOPLEFT", 7, -12);
	self.reset:SetPoint("TOPRIGHT", 2, -13);
end

function RaidInfoInstance_OnMouseUp(self)
	self.name:SetPoint("TOPLEFT", 5, -10);
	self.reset:SetPoint("TOPRIGHT", 0, -11);
end

function RaidInfoInstance_OnClick(self)
	if self.instanceID and IsModifiedClick("CHATLINK") then
		ChatEdit_InsertLink(GetSavedInstanceChatLink(self:GetElementData().index));
	else
		local oldSelectedIndex = RaidInfoFrame.selectedIndex;
		local oldSelectedIsInstance = RaidInfoFrame.selectedIsInstance;
		local elementData = self:GetElementData();
		RaidInfoFrame.selectedIndex = elementData.index;
		RaidInfoFrame.selectedIsInstance = elementData.isInstance;

		local function UpdateButtonSelected(index, isInstance, selected)
			if index then
				local button = RaidInfoFrame.ScrollBox:FindFrameByPredicate(function(button, elementData)
					return elementData.index == index and elementData.isInstance == isInstance;
				end);
				if button then
					RaidInfoFrame_SetButtonSelected(button, selected);
				end
			end
		end;

		UpdateButtonSelected(oldSelectedIndex, oldSelectedIsInstance, false);
		UpdateButtonSelected(RaidInfoFrame.selectedIndex, RaidInfoFrame.selectedIsInstance, true);

		RaidInfoFrame_UpdateButtons();
	end
end

function RaidInfoInstance_OnEnter(self)
	if (self.instanceID) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetInstanceLockEncountersComplete(self:GetElementData().index);
		GameTooltip:Show();
	else
		local instanceName, instanceID, instanceReset = GetSavedWorldBossInfo(self:GetElementData().index);
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(instanceName);
		GameTooltip:Show();
	end
end

function RaidInfoFrame_UpdateButtons()
	if RaidInfoFrame.selectedIndex then
		if RaidInfoFrame.selectedIsInstance then
			local _, _, _, _, locked, extended, _, _, _, _, _, _, extendDisabled, _ = GetSavedInstanceInfo(RaidInfoFrame.selectedIndex);
			RaidInfoExtendButton:SetEnabled(not extendDisabled);
			RaidInfoExtendButton.doExtend = not extended;
			if extended then
				RaidInfoExtendButton:SetText(UNEXTEND_RAID_LOCK);
			else
				RaidInfoExtendButton:SetText(locked and EXTEND_RAID_LOCK or REACTIVATE_RAID_LOCK);
			end
		else
			RaidInfoExtendButton:SetText(EXTEND_RAID_LOCK);
			RaidInfoExtendButton:Disable();
		end
	else
		RaidInfoExtendButton:SetText(EXTEND_RAID_LOCK);
		RaidInfoExtendButton:Disable();
	end
end

function RaidInfoExtendButton_OnClick(self)
	if(RaidInfoFrame.selectedIndex and RaidInfoFrame.selectedIndex <= GetNumSavedInstances()) then
		SetSavedInstanceExtend(RaidInfoFrame.selectedIndex, self.doExtend);
		RequestRaidInfo();
		RaidInfoFrame_Update();
	end
end

function RaidFrameAllAssistCheckButton_UpdateAvailable(self)
	self:SetChecked(IsEveryoneAssistant());
	if ( UnitIsGroupLeader("player") ) then
		self:Enable();
		self.Text:SetFontObject(GameFontNormalSmall);
	else
		self:Disable();
		self.Text:SetFontObject(GameFontDisableSmall);
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





