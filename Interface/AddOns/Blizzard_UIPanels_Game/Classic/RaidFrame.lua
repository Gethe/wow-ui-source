RaidParentFrameMixin = {}
RaidFrameMixin = {}
RaidInfoFrameMixin = {}
RaidInstanceFrameMixin = {}

function RaidParentFrameMixin:OnLoad()
	SetPortraitToTexture(self.portrait, "Interface\\LFGFrame\\UI-LFR-PORTRAIT");
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, 1);
end

function RaidFrameMixin:OnLoad()
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UPDATE_INSTANCE_INFO");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("READY_CHECK_FINISHED");

	-- Update party frame visibility
	RaidOptionsFrame_UpdatePartyFrames();
	self:Update();

	RaidFrame.hasRaidInfo = nil;
	-- Set this as the first tab
	RaidParentFrame.selectectTab = 1;
	ClaimRaidFrame(RaidParentFrame);
end

function RaidInfoFrameMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();
    view:SetElementInitializer("RaidInfoInstanceTemplate", function(button, elementData)
		local function InitButton(extended, locked, reset, name, difficulty, instanceID)
			if button.Name then
				if extended or locked then
					button.Name:SetText(name);
				else
					button.Name:SetFormattedText("|cff808080%s|r", name);
				end
			end

			if button.Reset then
				if extended or locked then
					button.Reset:SetText(SecondsToTime(reset, true, nil, 3));
				else
					button.Reset:SetFormattedText("|cff808080%s|r", RAID_INSTANCE_EXPIRES_EXPIRED);
				end
			end

			if button.Difficulty then
				button.Difficulty:SetText(difficulty);
			end

			if button.ID then
				button.ID:SetText(instanceID);
				button.ID:SetShown(not extended);
			end

			if button.Extended then
				button.Extended:SetShown(extended);
			end
		end

		local index = elementData.index;
		if not index then
			return;
		end

		if elementData.isInstance then
			local savedInstances = GetNumSavedInstances();
			if index > savedInstances then -- Should never happen
				return;
			end

			local name, instanceID, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName = GetSavedInstanceInfo(index);
			InitButton(extended, locked, reset, name, difficultyName, instanceID);
			button.raidIndex = index;
			button.instanceID = instanceID;
		else
			local name, _, reset = GetSavedWorldBossInfo(index);
			local locked = true;
			local extended = false;
			InitButton(extended, locked, reset, name, RAID_INFO_WORLD_BOSS, instanceID);
			button.raidIndex = nil;
			button.instanceID = nil;
		end
    end);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self:RegisterEvent("UPDATE_INSTANCE_INFO");
end

function RaidInstanceFrameMixin:OnHover()
	
	-- If we ever want these tooltips in Vanilla, TBC or Wrath, remove this check!
	if GetClassicExpansionLevel() < LE_EXPANSION_CATACLYSM then
		return
	end

	local name = self:GetName();
	local raidID = self.ID:GetText();
	local raidName = self.Name:GetText();
	local raidIndex = self.raidIndex;

	if not raidID or not raidName or not raidIndex then
		return
	end
	
	local _, _, _, _, _, _, _, _, _, _, numBosses = GetSavedInstanceInfo(raidIndex);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	
	GameTooltip:AddLine(string.format(INSTANCE_LOCK_SS, UnitName("player"), raidName));
	
	for i = 1, numBosses do
		local bossName, _, isKilled = GetSavedInstanceEncounterInfo(raidIndex, i);
		if isKilled then
			GameTooltip:AddDoubleLine(bossName, BOSS_DEAD, 1, 1, 1, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			GameTooltip:AddDoubleLine(bossName, BOSS_ALIVE, 1, 1, 1, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		end
	end
	
	GameTooltip:Show();
end

function RaidInstanceFrameMixin:OnLeave()
	GameTooltip_Hide();
end

function RaidInstanceFrameMixin:OnClick()
	if self.instanceID and IsModifiedClick("CHATLINK") then
		--Currently this isn't supported in Classic
		--ChatEdit_InsertLink(GetSavedInstanceChatLink(self:GetElementData().index));
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
					RaidInfoFrame:SetButtonSelected(button, selected);
				end
			end
		end;

		UpdateButtonSelected(oldSelectedIndex, oldSelectedIsInstance, false);
		UpdateButtonSelected(RaidInfoFrame.selectedIndex, RaidInfoFrame.selectedIsInstance, true);

		RaidInfoFrame:UpdateButtons();
	end
end

function RaidFrameMixin:OnShow()
	ButtonFrameTemplate_ShowAttic(self:GetParent());
	
	self:Update();
	
	if ( GetNumSavedInstances() > 0 ) then
		RaidFrameRaidInfoButton:Enable();
	else
		RaidFrameRaidInfoButton:Disable();
	end
	
	RequestRaidInfo();
	
	UpdateMicroButtons();
end

function RaidFrameMixin:OnEvent(event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		RequestRaidInfo();
	elseif ( event == "PLAYER_LOGIN" ) then
		if ( IsInRaid() ) then
			RaidFrame_LoadUI();
			self:Update();
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		RaidFrame_LoadUI();
			self:Update();
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
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LEADER_CHANGED" or event == "PARTY_LFG_RESTRICTED" ) then
		self:Update();
	end
end

function RaidParentFrame_SetView(tab)
	if ( tab == 1 ) then
		RaidParentFrame.selectectTab = 1;
		ClaimRaidFrame(RaidParentFrame);
		RaidFrame:Show();
		PanelTemplates_Tab_OnClick(RaidParentFrameTab1, RaidParentFrame);
	elseif ( tab == 2 ) then
		RaidParentFrame.selectectTab = 2;
		if ( RaidFrame:GetParent() == RaidParentFrame ) then
			RaidFrame:Hide();
		end
		PanelTemplates_Tab_OnClick(RaidParentFrameTab2, RaidParentFrame);
	end
end

function RaidFrameMixin:Update()
	-- If not in a raid hide all the UI and just display raid explanation text
	if ( not IsInRaid() ) then
		RaidFrameConvertToRaidButton:Show();
		if ( UnitExists("party1") and UnitIsGroupLeader("player") ) then
			RaidFrameConvertToRaidButton:Enable();
		else
			RaidFrameConvertToRaidButton:Disable();
		end
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
function RaidInfoFrameMixin:UpdateRaids()
	local dataProvider = CreateDataProvider();
	for index = 1, GetNumSavedInstances() do
		dataProvider:Insert({index=index, isInstance=true});
	end

	for index = 1, GetNumSavedWorldBosses() do
		dataProvider:Insert({index=index});
	end

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	self:UpdateButtons();
end

function RaidInfoFrameMixin:OnEvent(event, ...)
	if ( event == "UPDATE_INSTANCE_INFO" ) then
		self:UpdateRaids();
	end
end

function RaidInfoFrameMixin:UpdateButtons()
	if not RaidInfoExtendButton then
		-- Not all flavors of Classic have the UI / support for the raid extend feature
	elseif self.selectedIndex then
		if self.selectedIsInstance then
			local _, _, _, _, locked, extended, _, _, _, _, _, _, extendDisabled, _ = GetSavedInstanceInfo(self.selectedIndex);
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

function RaidInfoFrameMixin:ExtendButton_OnClick()
	if(self.selectedIndex and self.selectedIndex <= GetNumSavedInstances()) then
		SetSavedInstanceExtend(self.selectedIndex, RaidInfoExtendButton.doExtend);
		RequestRaidInfo();
		self:UpdateRaids();
	end
end

function RaidInfoFrameMixin:SetButtonSelected(button, selected)
	if selected then
		button:LockHighlight();
	else
		button:UnlockHighlight();
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





