MAX_ARENA_BATTLES = 6;

function ArenaFrame_OnLoad()
	this:RegisterEvent("BATTLEFIELDS_SHOW");
	this:RegisterEvent("BATTLEFIELDS_CLOSED");
	this:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	this:RegisterEvent("PARTY_LEADER_CHANGED");

end

function ArenaFrame_OnEvent()
	if ( IsBattlefieldArena() ) then
		if ( event == "BATTLEFIELDS_SHOW" ) then
			ShowUIPanel(ArenaFrame);
			if ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and IsPartyLeader() ) then
				ArenaFrame.selection = 1;
			else
				ArenaFrame.selection = 4;
			end
			if ( not ArenaFrame:IsVisible() ) then
				CloseBattlefield();
				return;
			end
			ArenaFrame_Update();
		elseif ( event == "BATTLEFIELDS_CLOSED" ) then
			HideUIPanel(ArenaFrame);
		elseif ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
			ArenaFrame_Update();
		end
		if ( event == "PARTY_LEADER_CHANGED" ) then
			ArenaFrame_Update();
		end
	end
end

function ArenaButton_OnClick(id)
	getglobal("ArenaZone"..id):LockHighlight();
	ArenaFrame.selection = id;
	ArenaFrame_Update();
end

function ArenaFrame_Update()
	local ARENA_TEAMS = {};
	ARENA_TEAMS[1] = {size = 2};
	ARENA_TEAMS[2] = {size = 3};
	ARENA_TEAMS[3] = {size = 5};

	for i=1, MAX_ARENA_BATTLES, 1 do
		local button = getglobal("ArenaZone"..i);
		local battleType;
		local teamSize = i;
		-- if buttons begin a second set of buttons for casual games, change text elements.
		if ( i > getn(ARENA_TEAMS) ) then
			teamSize = teamSize - getn(ARENA_TEAMS);
			battleType = ARENA_CASUAL;
		else
			battleType = ARENA_RATED;
		end
		-- build text string to populate each element.
		button:SetText(ARENA_TEAMS[teamSize].size.."v"..ARENA_TEAMS[teamSize].size.." "..battleType);
		-- Set selected instance
		if ( i == ArenaFrame.selection ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
	end

	if ( ArenaFrame.selection > getn(ARENA_TEAMS) ) then
		ArenaFrameJoinButton:Enable();
	else
		ArenaFrameJoinButton:Disable();
	end

	if ( CanJoinBattlefieldAsGroup() ) then
		if ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and IsPartyLeader() ) then
			-- If this is true then can join as a group
			ArenaFrameGroupJoinButton:Enable();
		else
			ArenaFrameGroupJoinButton:Disable();
		end
		ArenaFrameGroupJoinButton:Show();
	else
		ArenaFrameGroupJoinButton:Hide();
	end

	-- Enable or disable the group join button
	if ( CanJoinBattlefieldAsGroup() ) then
		if ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and IsPartyLeader() ) then
			-- If this is true then can join as a group
			BattlefieldFrameGroupJoinButton:Enable();
		else
			BattlefieldFrameGroupJoinButton:Disable();
		end
		BattlefieldFrameGroupJoinButton:Show();
	else
		BattlefieldFrameGroupJoinButton:Hide();
	end
end

function ArenaFrameJoinButton_OnClick(joinAs)
	if ( ArenaFrame.selection < 4 ) then
		JoinBattlefield(ArenaFrame.selection, 1, 1);
	elseif ( ArenaFrame.selection > 3  and joinAs ) then
		JoinBattlefield(ArenaFrame.selection - 3, 1);
	else
		JoinBattlefield(ArenaFrame.selection - 3);
	end
	HideUIPanel(ArenaFrame);
end
