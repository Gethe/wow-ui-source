
MAX_RAID_MEMBERS = 40;
NUM_RAID_GROUPS = 8;
MEMBERS_PER_RAID_GROUP = 5;
MAX_RAID_INFOS = 10;

function RaidFrame_OnLoad()
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("RAID_ROSTER_UPDATE");
	this:RegisterEvent("UPDATE_INSTANCE_INFO");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");

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
	if ( event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" ) then
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