
RaidWarningUtil = {};

RaidWarningUtil.MessageType = {
	RaidWarning = 1,
	BossEmote = 2,
	BGSystem = 3,
};

RaidWarningUtil.MessageTypePriority = {
	[RaidWarningUtil.MessageType.RaidWarning] = 1,
	[RaidWarningUtil.MessageType.BossEmote] = 2,
	[RaidWarningUtil.MessageType.BGSystem] = 3,
};

RaidWarningUtil.MessageTypeEvents = {
	[RaidWarningUtil.MessageType.RaidWarning] = { "CHAT_MSG_RAID_WARNING", "HARDCORE_DEATHS" },
	[RaidWarningUtil.MessageType.BossEmote] = { "RAID_BOSS_EMOTE", "RAID_BOSS_WHISPER", "CLEAR_BOSS_EMOTES" },
	[RaidWarningUtil.MessageType.BGSystem] = { "CHAT_MSG_BG_SYSTEM_ALLIANCE", "CHAT_MSG_BG_SYSTEM_HORDE" },
};

RaidWarningUtil.MessageTypes = {
	Standard = { RaidWarningUtil.MessageType.RaidWarning, RaidWarningUtil.MessageType.BossEmote },
	BossEmote = { RaidWarningUtil.MessageType.BossEmote },
	BGSystem = { RaidWarningUtil.MessageType.BGSystem },
};

function RaidWarningUtil.AddMessage(textString, colorInfo, displayTime, messageType)
	RaidWarningFrame:AddMessage(textString, colorInfo, displayTime, messageType);
end

function RaidWarningUtil.ClearBossEmotes()
	RaidWarningFrame:ClearMessages(RaidWarningUtil.MessageType.BossEmote);
end

-- This isn't a comprehensive update for all center-anchored elements because
-- we haven't properly resolved all the overlaps yet. This only covers these elements
-- which would otherwise commonly overlap.
function RaidWarningUtil.UpdateCenterScreenAnchors()
	local lowestMessage = RaidWarningFrame:GetLowestMessage();

	-- Anchor DeadlyDebuffFrame below the lowest warning message, or to the
	-- top of RaidWarningFrame when there are no messages.
	DeadlyDebuffFrame:ClearAllPoints();
	if lowestMessage then
		DeadlyDebuffFrame:SetPoint("TOP", lowestMessage, "BOTTOM", 0, 0);
	else
		DeadlyDebuffFrame:SetPoint("TOP", RaidWarningFrame, "TOP", 0, 0);
	end

	PrivateRaidBossEmoteFrameAnchor:ClearAllPoints();

	-- Anchor below DeadlyDebuffFrame if it's visible, otherwise below
	-- the lowest warning message, otherwise to the top of RaidWarningFrame.
	if DeadlyDebuffFrame:IsShown() then
		PrivateRaidBossEmoteFrameAnchor:SetPoint("TOP", DeadlyDebuffFrame, "BOTTOM", 0, 0);
	else
		if lowestMessage then
			PrivateRaidBossEmoteFrameAnchor:SetPoint("TOP", lowestMessage, "BOTTOM", 0, 0);
		else
			PrivateRaidBossEmoteFrameAnchor:SetPoint("TOP", RaidWarningFrame, "TOP", 0, 0);
		end
	end
end
