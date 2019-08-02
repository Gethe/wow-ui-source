function DestinyFrame_OnEvent(self, event)
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
	MoveForwardStop();	-- in case the player was moving, need to check if it'll work in blizzcon build
	DestinyFrame_UpdateRecruitInfo(self);
	self:Show();
end

function DestinyFrame_UpdateRecruitInfo(self)
	local active, faction = C_RecruitAFriend.GetRecruitInfo();
	if active then
		if PLAYER_FACTION_GROUP[faction] == "Horde" then
			self.RecruitAFriendSuggestionHorde:ShowHelpBox(RECRUIT_A_FRIEND_FACTION_PANDAREN_HORDE);
			self.RecruitAFriendSuggestionAlliance:Hide();
		else
			self.RecruitAFriendSuggestionAlliance:ShowHelpBox(RECRUIT_A_FRIEND_FACTION_PANDAREN_ALLIANCE);
			self.RecruitAFriendSuggestionHorde:Hide();
		end
	else
		self.RecruitAFriendSuggestionHorde:Hide();
		self.RecruitAFriendSuggestionAlliance:Hide();
	end
end
