
MAX_RAID_MEMBERS = 40;
NUM_RAID_GROUPS = 8;
MEMBERS_PER_RAID_GROUP = 5;
MAX_RAID_INFOS = 10;

function RaidParentFrame_OnLoad(self)
	SetPortraitToTexture(self.portrait, "Interface\\LFGFrame\\UI-LFR-PORTRAIT");
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
	
	if ( GetNumSavedInstances() > 0 ) then
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
		if ( GetNumSavedInstances() > 0 ) then
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

function RaidFrame_Update()
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
function RaidInfoFrame_Update()
	local savedInstances = GetNumSavedInstances();
	local instanceName, instanceID, instanceReset;
	if ( savedInstances > 0 ) then
		--RaidInfoScrollFrameScrollUpButton:SetPoint("BOTTOM", RaidInfoScrollFrame, "TOP", 0, 16);
		for i=1, MAX_RAID_INFOS do
			if ( i <=  savedInstances) then
				instanceName, instanceID, instanceReset = GetSavedInstanceInfo(i);
				getglobal("RaidInfoInstance"..i.."Name"):SetText(instanceName);
				getglobal("RaidInfoInstance"..i.."ID"):SetText(instanceID);
				getglobal("RaidInfoInstance"..i.."Reset"):SetText(RESETS_IN.." "..SecondsToTime(instanceReset));
				getglobal("RaidInfoInstance"..i):Show();
			else
				getglobal("RaidInfoInstance"..i):Hide();
			end
			
		end
		if ( savedInstances > 4 ) then
			RaidInfoScrollFrameScrollBar:Show();
			RaidInfoScrollFrameScrollBar:SetPoint("TOPLEFT", RaidInfoScrollFrame, "TOPRIGHT", 8, -3);
		else
			RaidInfoScrollFrameScrollBar:Hide();
		end
		RaidInfoScrollFrame:UpdateScrollChildRect();
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





