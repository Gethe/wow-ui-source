
MAX_RAID_MEMBERS = 40;
NUM_RAID_GROUPS = 8;
MEMBERS_PER_RAID_GROUP = 5;
MAX_RAID_INFOS = 20;
MAX_RAID_INFOS_DISPLAYED = 4;

function RaidFrame_OnLoad()
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("RAID_ROSTER_UPDATE");
	this:RegisterEvent("UPDATE_INSTANCE_INFO");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("VOICE_STATUS_UPDATE");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("READY_CHECK");
	this:RegisterEvent("READY_CHECK_CONFIRM");
	this:RegisterEvent("READY_CHECK_FINISHED");
	-- Raid option uvars
	SHOW_DISPELLABLE_DEBUFFS = "0";
	RegisterForSave("SHOW_DISPELLABLE_DEBUFFS");
	SHOW_CASTABLE_BUFFS = "0";
	RegisterForSave("SHOW_CASTABLE_BUFFS");

	-- Update party frame visibility
	RaidOptionsFrame_UpdatePartyFrames();
	RaidFrame_Update();

	RaidFrame.hasRaidInfo = nil;
end

function RaidFrame_OnEvent()
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		RequestRaidInfo();
	end
	if ( event == "PLAYER_LOGIN" ) then
		if ( GetNumRaidMembers() > 0 ) then
			RaidFrame_LoadUI();
			RaidFrame_Update();
		end
	end
	if ( event == "RAID_ROSTER_UPDATE" ) then
		RaidFrame_LoadUI();
		RaidFrame_Update();
		RaidPullout_RenewFrames();
	end
	if ( event == "READY_CHECK" or
		 event == "READY_CHECK_CONFIRM" ) then
		if ( RaidFrame:IsShown() and RaidGroupFrame_Update ) then
			RaidGroupFrame_Update();
		end
	elseif ( event == "READY_CHECK_FINISHED" ) then
		if ( RaidFrame:IsShown() and RaidGroupFrame_ReadyCheckFinished ) then
			RaidGroupFrame_ReadyCheckFinished();
		end
	end
	if ( event == "UPDATE_INSTANCE_INFO" ) then
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
		RaidInfoFrame_Update();
	end
	if ( event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or event == "VOICE_STATUS_UPDATE" ) then
		RaidFrame_Update();
	end
end

function RaidFrame_Update()
	-- If not in a raid hide all the UI and just display raid explanation text
	if ( GetNumRaidMembers() == 0 ) then
		RaidFrameConvertToRaidButton:Show();
		if ( GetPartyMember(1) and IsPartyLeader() ) then
			RaidFrameConvertToRaidButton:Enable();
		else
			RaidFrameConvertToRaidButton:Disable();
		end
		RaidFrameRaidDescription:Show();
	else
		RaidFrameConvertToRaidButton:Hide();
		RaidFrameRaidDescription:Hide();
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
function RaidInfoFrame_Update()
	local savedInstances = GetNumSavedInstances();
	local instanceName, instanceID, instanceReset, width;
	local frameName, frameID, frameReset;
	if ( savedInstances > 0 ) then
		if ( savedInstances > MAX_RAID_INFOS_DISPLAYED ) then
			width = 205;
			RaidInfoScrollFrameTop:Show();
			RaidInfoScrollFrameBottom:Show();
			RaidInfoScrollFrameScrollBar:Show();
			RaidInfoFrame.scrolling = 1;
		else
			width = 230;
			RaidInfoScrollFrameTop:Hide();
			RaidInfoScrollFrameBottom:Hide();
			RaidInfoScrollFrameScrollBar:Hide();
			RaidInfoFrame.scrolling = nil;
		end
		for i=1, MAX_RAID_INFOS do
			local frame = getglobal("RaidInfoInstance"..i);
			if ( i <=  savedInstances) then
				instanceName, instanceID, instanceReset = GetSavedInstanceInfo(i);
				 
				if ( not frame ) then
					local name =  "RaidInfoInstance"..i;
					frame = CreateFrame("FRAME", name, RaidInfoScrollChildFrame, "RaidInfoInstanceTemplate");
					frame:SetPoint("TOPLEFT", "RaidInfoInstance"..i-1, "BOTTOMLEFT", 0, 5);
				end

				frameName = getglobal("RaidInfoInstance"..i.."Name");
				frameID = getglobal("RaidInfoInstance"..i.."ID");
				frameReset = getglobal("RaidInfoInstance"..i.."Reset");

				frameName:SetText(instanceName);
				frameID:SetText(instanceID);
				frameReset:SetText(RESETS_IN.." "..SecondsToTime(instanceReset));
				if ( RaidInfoFrame.scrolling ) then
					frameName:SetWidth(180);
				else
					frameName:SetWidth(190);
				end
				frame:SetWidth(width);
				frame:Show();
			else
				if ( frame ) then
					frame:Hide();
				end
			end
			
		end
	end
end
