function DestinyFrame_OnEvent(self, event)
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
	MoveForwardStop();	-- in case the player was moving, need to check if it'll work in blizzcon build
	DestinyFrame_UpdateRecruitInfo(self);
	self:Show();
end

local destinyHordeHelpTipInfo = {
	text = RECRUIT_A_FRIEND_FACTION_PANDAREN_HORDE,
	buttonStyle = HelpTip.ButtonStyle.None,
	targetPoint = HelpTip.Point.RightEdgeCenter,
	useParentStrata = true,
	offsetX = -15,
};

local destinyAllianceHelpTipInfo = {
	text = RECRUIT_A_FRIEND_FACTION_PANDAREN_ALLIANCE,
	buttonStyle = HelpTip.ButtonStyle.None,
	targetPoint = HelpTip.Point.LeftEdgeCenter,
	useParentStrata = true,
	offsetX = 15,
};

function DestinyFrame_UpdateRecruitInfo(self)
	local active, faction = C_RecruitAFriend.GetRecruitInfo();
	if active then
		if PLAYER_FACTION_GROUP[faction] == "Horde" then
			HelpTip:Show(DestinyHordeButton, destinyHordeHelpTipInfo);
			HelpTip:HideAll(DestinyAllianceButton);
		else
			HelpTip:Show(DestinyAllianceButton, destinyAllianceHelpTipInfo);
			HelpTip:HideAll(DestinyHordeButton);
		end
	else
		HelpTip:HideAll(DestinyAllianceButton);
		HelpTip:HideAll(DestinyHordeButton);
	end
end
