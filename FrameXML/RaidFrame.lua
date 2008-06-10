
MAX_RAID_MEMBERS = 40;
NUM_RAID_GROUPS = 8;
MEMBERS_PER_RAID_GROUP = 5;

function RaidFrame_OnLoad()
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("RAID_ROSTER_UPDATE");

	-- Raid option uvars
	SHOW_DISPELLABLE_DEBUFFS = "0";
	RegisterForSave("SHOW_DISPELLABLE_DEBUFFS");
	SHOW_CASTABLE_BUFFS = "0";
	RegisterForSave("SHOW_CASTABLE_BUFFS");

	-- Update party frame visibility
	RaidOptionsFrame_UpdatePartyFrames();
end

function RaidFrame_OnEvent()
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
end

function RaidFrame_Update()
	-- If not in a raid hide all the UI and just display raid explanation text
	if ( GetNumRaidMembers() == 0 ) then
		RaidFrameConvertToRaidButton:Show();
		if ( IsRaidLeader() ) then
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
	HidePartyFrame();
	ShowPartyFrame();
end
