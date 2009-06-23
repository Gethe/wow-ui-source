MAX_ARENA_BATTLES = 6;
NO_ARENA_SEASON = 0;
function ArenaFrame_OnLoad (self)
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("BATTLEFIELDS_CLOSED");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
end

function ArenaFrame_OnEvent (self, event, ...)
	if ( IsBattlefieldArena() ) then
		if ( event == "BATTLEFIELDS_SHOW" ) then
			ShowUIPanel(ArenaFrame);
			if ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and IsPartyLeader() and GetCurrentArenaSeason()~=NO_ARENA_SEASON) then
				if ( not ArenaFrame.selection ) then
					ArenaFrame.selection = 1;
				end
			else
				if ( (not ArenaFrame.selection) or (ArenaFrame.selection < 4) ) then
					ArenaFrame.selection = 4;
				end
			end
            
            if ( GetCurrentArenaSeason()==NO_ARENA_SEASON ) then
                ArenaFrameZoneDescription:SetText(ARENA_MASTER_NO_SEASON_TEXT);
            else
                ArenaFrameZoneDescription:SetText(ARENA_MASTER_TEXT)
            end
            
			if ( not ArenaFrame:IsShown() ) then
				CloseBattlefield();
				return;
			end
			ArenaFrame_Update(self);
		elseif ( event == "BATTLEFIELDS_CLOSED" ) then
			HideUIPanel(ArenaFrame);
		elseif ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
			ArenaFrame_Update(self);
		end
		if ( event == "PARTY_LEADER_CHANGED" ) then
			ArenaFrame_Update(self);
		end
	end
end

function ArenaButton_OnClick(self)
	local id = self:GetID();
	_G["ArenaZone"..id]:LockHighlight();
	ArenaFrame.selection = id;
	ArenaFrame_Update();
end

function ArenaFrame_Update (self)
	local ARENA_TEAMS = {};
	ARENA_TEAMS[1] = {size = 2};
	ARENA_TEAMS[2] = {size = 3};
	ARENA_TEAMS[3] = {size = 5};
	
	local button, battleType, teamSize;
	
	for i=1, MAX_ARENA_BATTLES, 1 do
		button = _G["ArenaZone"..i];
		battleType = ARENA_RATED;
		teamSize = i;
		-- if buttons begin a second set of buttons for casual games, change text elements.
		button:Enable();
		if ( i > MAX_ARENA_TEAMS ) then
			teamSize = teamSize - MAX_ARENA_TEAMS;
			battleType = ARENA_CASUAL;
		elseif ( GetCurrentArenaSeason()==NO_ARENA_SEASON ) then
			button:Disable();
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

	if ( ArenaFrame.selection > MAX_ARENA_TEAMS ) then
		ArenaFrameJoinButton:Enable();
	else
		ArenaFrameJoinButton:Disable();
	end

	if ( CanJoinBattlefieldAsGroup() ) then
		if ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and IsPartyLeader() and GetCurrentArenaSeason()~=NO_ARENA_SEASON) then
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

function ArenaFrameJoinButton_OnClick(self)
	local GROUPJOIN_BUTTONID = 2;
	if ( ArenaFrame.selection < 4 ) then
		JoinBattlefield(ArenaFrame.selection, 1, 1);
	elseif ( ArenaFrame.selection > 3 and self:GetID() == GROUPJOIN_BUTTONID ) then
		JoinBattlefield(ArenaFrame.selection - 3, 1);
	else
		JoinBattlefield(ArenaFrame.selection - 3);
	end
	HideUIPanel(ArenaFrame);
end
