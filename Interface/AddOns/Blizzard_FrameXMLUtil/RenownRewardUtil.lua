RenownRewardUtil = {};

function RenownRewardUtil.GetRenownRewardDisplayData(rewardInfo, onItemUpdateCallback)
	if rewardInfo.itemID then
		local item = Item:CreateFromItemID(rewardInfo.itemID);
		local icon, name;
		if item:IsItemDataCached() then
			icon = item:GetItemIcon();
			name = item:GetItemName();
		else
			item:ContinueOnItemLoad(onItemUpdateCallback);
		end
		return icon, name, RENOWN_REWARD_ITEM_NAME_FORMAT, RENOWN_REWARD_ITEM_DESCRIPTION;
	elseif rewardInfo.mountID then
		local name, spellID, icon = C_MountJournal.GetMountInfoByID(rewardInfo.mountID);
		return icon, name, RENOWN_REWARD_MOUNT_NAME_FORMAT, RENOWN_REWARD_MOUNT_DESCRIPTION;
	elseif rewardInfo.spellID then
		local spellInfo = C_Spell.GetSpellInfo(rewardInfo.spellID);
		return spellInfo.iconID, spellInfo.name, RENOWN_REWARD_SPELL_NAME_FORMAT, RENOWN_REWARD_SPELL_DESCRIPTION;
	elseif rewardInfo.titleMaskID then
		local name = TitleUtil.GetNameFromTitleMaskID(rewardInfo.titleMaskID);
		return nil, name, RENOWN_REWARD_TITLE_NAME_FORMAT, RENOWN_REWARD_TITLE_DESCRIPTION;
	elseif rewardInfo.transmogID then
		local itemID = C_Transmog.GetItemIDForSource(rewardInfo.transmogID);
		local item = Item:CreateFromItemID(itemID);
		local icon, name;
		if item:IsItemDataCached() then
			icon = item:GetItemIcon();
			name = item:GetItemName();
		else
			item:ContinueOnItemLoad(onItemUpdateCallback);
		end
		return icon, name, RENOWN_REWARD_TRANSMOG_NAME_FORMAT, RENOWN_REWARD_TRANSMOG_DESCRIPTION;
	elseif rewardInfo.transmogSetID then
		local icon = TransmogUtil.GetSetIcon(rewardInfo.transmogSetID);
		local setInfo = C_TransmogSets.GetSetInfo(rewardInfo.transmogSetID);
		if setInfo then
			return icon, setInfo.name, RENOWN_REWARD_TRANSMOGSET_NAME_FORMAT, RENOWN_REWARD_TRANSMOGSET_DESCRIPTION;
		end
	elseif rewardInfo.garrFollowerID then
		local followerInfo = C_Garrison.GetFollowerInfo(rewardInfo.garrFollowerID);
		return followerInfo.portraitIconID, followerInfo.name, RENOWN_REWARD_FOLLOWER_NAME_FORMAT, RENOWN_REWARD_FOLLOWER_DESCRIPTION;
	elseif rewardInfo.transmogIllusionSourceID then
		local illusionInfo = C_TransmogCollection.GetIllusionInfo(rewardInfo.transmogIllusionSourceID);
		if illusionInfo then
			local name = C_TransmogCollection.GetIllusionStrings(rewardInfo.transmogIllusionSourceID);
			return illusionInfo.icon, name, RENOWN_REWARD_ILLUSION_NAME_FORMAT, RENOWN_REWARD_ILLUSION_DESCRIPTION;
		end
	end
end

function RenownRewardUtil.GetUnformattedRenownRewardInfo(rewardInfo, onItemUpdateCallback)
	local icon, name, formatString, description = RenownRewardUtil.GetRenownRewardDisplayData(rewardInfo, onItemUpdateCallback);
	return (rewardInfo.icon or icon), (rewardInfo.name or name), formatString, (rewardInfo.description or description);
end

function RenownRewardUtil.GetRenownRewardInfo(rewardInfo, onItemUpdateCallback)
	local icon, name, formatString, description = RenownRewardUtil.GetUnformattedRenownRewardInfo(rewardInfo, onItemUpdateCallback);
	return icon, name and formatString and formatString:format(name) or name, description;
end

function RenownRewardUtil.AddRenownRewardsToTooltip(tooltip, renownRewards, callback)
	GameTooltip_AddHighlightLine(GameTooltip, MAJOR_FACTION_BUTTON_TOOLTIP_NEXT_REWARDS);

	for i, rewardInfo in ipairs(renownRewards) do
		local renownRewardString;
		local icon, name = RenownRewardUtil.GetRenownRewardInfo(rewardInfo, callback);
		if icon then
			local file, width, height = icon, 16, 16;
			local rewardTexture = CreateSimpleTextureMarkup(file, width, height);
			renownRewardString = rewardTexture .. " " .. name;
		end
		local wrapText = false;
		GameTooltip_AddNormalLine(tooltip, renownRewardString, wrapText);
	end
end

-- Adds a quick summary of your current progress with the faction
-- Used in the Expansion Landing Page
function RenownRewardUtil.AddMajorFactionLandingPageSummaryToTooltip(tooltip, factionID, callback)
	callback = callback or nop;

	local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
	if not majorFactionData then
		return;
	end

	GameTooltip_SetTitle(tooltip, majorFactionData.name, HIGHLIGHT_FONT_COLOR);
	ReputationUtil.TryAppendAccountReputationLineToTooltip(GameTooltip, factionID);
	if not C_MajorFactions.HasMaximumRenown(factionID) then
		GameTooltip_AddNormalLine(tooltip, MAJOR_FACTION_RENOWN_CURRENT_PROGRESS:format(majorFactionData.renownReputationEarned, majorFactionData.renownLevelThreshold));
		GameTooltip_AddBlankLineToTooltip(tooltip);
		local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(factionID, C_MajorFactions.GetCurrentRenownLevel(factionID) + 1);
		if #nextRenownRewards > 0 then
			RenownRewardUtil.AddRenownRewardsToTooltip(tooltip, nextRenownRewards, callback);
			GameTooltip_AddBlankLineToTooltip(tooltip);
		end
	end
end

-- Adds an overview of your progress with the faction, with details on how the renown system works
-- Used in the Reputation Panel and Encounter Journal 
function RenownRewardUtil.AddMajorFactionToTooltip(tooltip, factionID, callback)
	callback = callback or nop;

	local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
	if not majorFactionData then
		return;
	end

	GameTooltip_SetTitle(tooltip, majorFactionData.name, HIGHLIGHT_FONT_COLOR);
	ReputationUtil.TryAppendAccountReputationLineToTooltip(tooltip, majorFactionData.factionID);
	GameTooltip_AddHighlightLine(tooltip, RENOWN_LEVEL_LABEL:format(majorFactionData.renownLevel));

	GameTooltip_AddBlankLineToTooltip(tooltip);
	GameTooltip_AddNormalLine(tooltip, MAJOR_FACTION_RENOWN_TOOLTIP_PROGRESS:format(majorFactionData.name));
	GameTooltip_AddBlankLineToTooltip(tooltip);

	local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(majorFactionData.factionID, C_MajorFactions.GetCurrentRenownLevel(majorFactionData.factionID) + 1);
	if #nextRenownRewards > 0 then
		RenownRewardUtil.AddRenownRewardsToTooltip(tooltip, nextRenownRewards, callback);
	end
end