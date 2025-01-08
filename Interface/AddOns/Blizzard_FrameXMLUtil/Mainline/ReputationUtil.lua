ReputationUtil = {};

function ReputationUtil.TryAppendAccountReputationLineToTooltip(tooltip, factionID)
	if not tooltip or not factionID or not C_Reputation.IsAccountWideReputation(factionID) then
		return;
	end

	local wrapText = false;
	GameTooltip_AddColoredLine(tooltip, REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, ACCOUNT_WIDE_FONT_COLOR, wrapText);
end

function ReputationUtil.AddParagonRewardsToTooltip(tooltip, factionID)
	if not C_Reputation.IsFactionParagon(factionID) then
		return;
	end

	local factionStandingtext;
	local factionData = C_Reputation.GetFactionDataByID(factionID);
	local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID);
	if reputationInfo and reputationInfo.friendshipFactionID > 0 then
		factionStandingtext = reputationInfo.reaction;
	elseif C_Reputation.IsMajorFaction(factionID) then
		factionStandingtext = MAJOR_FACTION_MAX_RENOWN_REACHED;
	else
		local gender = UnitSex("player");
		factionStandingtext = GetText("FACTION_STANDING_LABEL"..factionData.reaction, gender);
	end

	local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
	if tooLowLevelForParagon then
		GameTooltip_SetTitle(tooltip, PARAGON_REPUTATION_TOOLTIP_TEXT_LOW_LEVEL, NORMAL_FONT_COLOR);
	else
		GameTooltip_SetTitle(tooltip, factionStandingtext, HIGHLIGHT_FONT_COLOR);

		ReputationUtil.TryAppendAccountReputationLineToTooltip(tooltip, factionID);
		GameTooltip_AddBlankLineToTooltip(tooltip);

		local description = PARAGON_REPUTATION_TOOLTIP_TEXT:format(factionData.name);
		if hasRewardPending then
			local questIndex = C_QuestLog.GetLogIndexForQuestID(rewardQuestID);
			local text = GetQuestLogCompletionText(questIndex);
			if text and text ~= "" then
				description = text;
			end
		end
		GameTooltip_AddNormalLine(tooltip, description);
		if not hasRewardPending and currentValue and threshold then
			local value = mod(currentValue, threshold);
			-- show overflow if reward is pending
			if hasRewardPending then
				value = value + threshold;
			end
			GameTooltip_ShowProgressBar(tooltip, 0, threshold, value, REPUTATION_PROGRESS_FORMAT:format(value, threshold));
		end
		GameTooltip_AddQuestRewardsToTooltip(tooltip, rewardQuestID);
	end
end