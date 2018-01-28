function DestinyFrame_OnEvent(self, event)
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
	MoveForwardStop();	-- in case the player was moving, need to check if it'll work in blizzcon build
	DestinyFrame_UpdateRecruitInfo(self);
	self:Show();
end

function DestinyFrame_UpdateRecruitInfo(self)
	local active, faction = C_RecruitAFriend.GetRecruitInfo();
	if ( active ) then
		if ( PLAYER_FACTION_GROUP[faction] == "Horde" ) then
			self.RecruitAFriendSuggestion:ClearAllPoints();
			self.RecruitAFriendSuggestion:SetPoint("LEFT", DestinyHordeButton, "RIGHT", 10, 0);
			RecruitAFriend_ShowInfoDialog(self.RecruitAFriendSuggestion, RECRUIT_A_FRIEND_FACTION_PANDAREN_HORDE);
			RecruitAFriend_SetInfoDialogDirection(self.RecruitAFriendSuggestion, "left");
		else
			self.RecruitAFriendSuggestion:ClearAllPoints();
			self.RecruitAFriendSuggestion:SetPoint("RIGHT", DestinyAllianceButton, "LEFT", -10, 0);
			RecruitAFriend_ShowInfoDialog(self.RecruitAFriendSuggestion, RECRUIT_A_FRIEND_FACTION_PANDAREN_ALLIANCE);
			RecruitAFriend_SetInfoDialogDirection(self.RecruitAFriendSuggestion, "right");
		end
	else
		self.RecruitAFriendSuggestion:Hide();
	end
end
