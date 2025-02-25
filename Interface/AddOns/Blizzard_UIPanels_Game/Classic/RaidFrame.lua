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
        local savedInstances = GetNumSavedInstances();
		local index = elementData.index;

		if not index then
			return;
		end

		if index > savedInstances then -- Should never happen
			return;
		end

		button.raidIndex = index;

		local instanceName, instanceID, instanceReset, _, _, _, _, _, _, instanceDifficulty, encountersTotal = GetSavedInstanceInfo(index);

		if button.Name then
			button.Name:SetText(instanceName);
		end

		if button.Difficult then
			button.Difficulty:SetText(instanceDifficulty);
		end

		if button.ID then
			button.ID:SetText(instanceID);
		end

		if button.Reset then
			button.Reset:SetText(SecondsToTime(instanceReset, true, nil, 3));
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

	local savedInstances = GetNumSavedInstances();

	for i = 1, savedInstances do
		dataProvider:Insert({index=i});
	end

    self.ScrollBox:SetDataProvider(dataProvider);
end

function RaidInfoFrameMixin:OnEvent(event, ...)
	if ( event == "UPDATE_INSTANCE_INFO" ) then
		self:UpdateRaids();
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





