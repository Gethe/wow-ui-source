MAX_ARENA_BATTLES = 6;

local function CanJoinAsGroup()
	return UnitIsGroupLeader("player") and (IsInGroup() or IsInRaid());
end

function ArenaFrame_OnLoad(self)
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("BATTLEFIELDS_CLOSED");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PARTY_LEADER_CHANGED");

end

function ArenaFrame_OnEvent(self, event)
	if ( IsBattlefieldArena() ) then
		if ( event == "BATTLEFIELDS_SHOW" ) then
			ShowUIPanel(ArenaFrame);
			
			if ( CanJoinAsGroup() and IsArenaSeasonActive()) then
				ArenaFrame.selection = 1;
			else
				ArenaFrame.selection = 4;
			end
			if ( not ArenaFrame:IsShown() ) then
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
			if (IsArenaSeasonActive()) then
				button:Enable();
			else
				button:Disable();
			end
		end
		-- build text string to populate each element.
		button:SetText(format(PVP_TEAMTYPE, ARENA_TEAMS[teamSize].size, ARENA_TEAMS[teamSize].size).." "..battleType);

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
		if CanJoinAsGroup() then
			-- If this is true then can join as a group
			ArenaFrameGroupJoinButton:Enable();
		else
			ArenaFrameGroupJoinButton:Disable();
		end
		ArenaFrameGroupJoinButton:Show();
	else
		ArenaFrameGroupJoinButton:Hide();
	end
end

function ArenaFrameJoinButton_OnClick(joinAs)
	if ( ArenaFrame.selection < 4 ) then
		JoinArena(ArenaFrame.selection, 1, 1);
	elseif ( ArenaFrame.selection > 3  and joinAs ) then
		JoinSkirmish(ArenaFrame.selection - 3, 1);
	else
		JoinSkirmish(ArenaFrame.selection - 3);
	end
	HideUIPanel(ArenaFrame);
end
