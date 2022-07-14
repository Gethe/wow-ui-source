CovenantUtil = {};

function CovenantUtil.GetRenownRewardDisplayData(rewardInfo, onItemUpdateCallback)
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
		local name, _, icon = GetSpellInfo(rewardInfo.spellID);
		return icon, name, RENOWN_REWARD_SPELL_NAME_FORMAT, RENOWN_REWARD_SPELL_DESCRIPTION;
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

function CovenantUtil.GetUnformattedRenownRewardInfo(rewardInfo, onItemUpdateCallback)
	local icon, name, formatString, description = CovenantUtil.GetRenownRewardDisplayData(rewardInfo, onItemUpdateCallback);
	return (rewardInfo.icon or icon), (name or rewardInfo.name), formatString, (rewardInfo.description or description);
end

function CovenantUtil.GetRenownRewardInfo(rewardInfo, onItemUpdateCallback)
	local icon, name, formatString, description = CovenantUtil.GetUnformattedRenownRewardInfo(rewardInfo, onItemUpdateCallback);
	return icon, name and formatString and formatString:format(name) or name, description;
end