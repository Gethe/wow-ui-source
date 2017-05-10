QUEST_TAG_DUNGEON_TYPES = {
	[QUEST_TAG_RAID] = true,
	[QUEST_TAG_DUNGEON] = true,
	[QUEST_TAG_RAID10] = true,
	[QUEST_TAG_RAID25] = true,
};

WORLD_QUEST_TYPE_DUNGEON_TYPES = {
	[LE_QUEST_TAG_TYPE_DUNGEON] = true,
	[LE_QUEST_TAG_TYPE_RAID] = true,
}

local QUEST_ICONS_FILE = "Interface\\QuestFrame\\QuestTypeIcons";
local QUEST_ICONS_FILE_WIDTH = 128;
local QUEST_ICONS_FILE_HEIGHT = 64;

local function IsQuestWorldQuest_Internal(worldQuestType)
	return worldQuestType ~= nil;
end

local function IsQuestDungeonQuest_Internal(tagID, worldQuestType)
	if IsQuestWorldQuest_Internal(worldQuestType) then
		return WORLD_QUEST_TYPE_DUNGEON_TYPES[worldQuestType];
	end

	return QUEST_TAG_DUNGEON_TYPES[tagID];
end

local function CreateQuestIconTextureMarkup(width, height, left, right, top, bottom)
	return CreateTextureMarkup(QUEST_ICONS_FILE, QUEST_ICONS_FILE_WIDTH, QUEST_ICONS_FILE_HEIGHT, width, height, left, right, top, bottom);
end

local function GetTextureMarkupStringFromTagData(tagID, worldQuestType, text, iconWidth, iconHeight)
	local texCoords = QuestUtils_GetQuestTagTextureCoords(tagID, worldQuestType);

	if texCoords then
		-- Use reasonable defaults if nothing is specified
		iconWidth = iconWidth or 20;
		iconHeight = iconHeight or 20;

		local textureMarkup = CreateQuestIconTextureMarkup(iconWidth, iconHeight, unpack(texCoords));
		return string.format("%s %s", textureMarkup, text); -- Convert to localized string to handle dynamic icon placement?
	end
end

local function AddQuestTagTooltipLine(tooltip, tagID, worldQuestType, lineText, iconWidth, iconHeight, color)
	local tooltipLine = GetTextureMarkupStringFromTagData(tagID, worldQuestType, lineText, iconWidth, iconHeight);
	if tooltipLine then
		tooltip:AddLine(tooltipLine, color:GetRGB());
	end
end

-- Quest Utils API

function QuestUtils_GetQuestTagTextureCoords(tagID, worldQuestType)
	if IsQuestWorldQuest_Internal(worldQuestType) then
		return WORLD_QUEST_TYPE_TCOORDS[worldQuestType];
	end

	return QUEST_TAG_TCOORDS[tagID];
end

function QuestUtils_IsQuestWorldQuest(questID)
	local _, _, worldQuestType = GetQuestTagInfo(questID);
	return IsQuestWorldQuest_Internal(worldQuestType);
end

function QuestUtils_IsQuestDungeonQuest(questID)
	local tagID, _, worldQuestType = GetQuestTagInfo(questID);
	IsQuestDungeonQuest_Internal(tagID, worldQuestType);
end

function QuestUtils_GetQuestTypeTextureMarkupString(questID, iconWidth, iconHeight)
	local tagID, tagName, worldQuestType = GetQuestTagInfo(questID);

	-- NOTE: For now, only allow dungeon quests to get markup
	if IsQuestDungeonQuest_Internal(tagID, worldQuestType) then
		return GetTextureMarkupStringFromTagData(tagID, worldQuestType, tagName, iconWidth, iconHeight);
	end
end

function QuestUtils_AddQuestTypeToTooltip(tooltip, questID, color, iconWidth, iconHeight)
	local tagID, tagName, worldQuestType = GetQuestTagInfo(questID);

	-- NOTE: See above, for now only add dungeons quests to quest tooltips.  Can add a set of filters or a predicate to evaluate
	-- whether or not we want to add this in the future.
	if IsQuestDungeonQuest_Internal(tagID, worldQuestType) then
		AddQuestTagTooltipLine(tooltip, tagID, worldQuestType, tagName, iconWidth, iconHeight, color);
	end
end

function QuestUtils_AddQuestTagLineToTooltip(tooltip, tagName, tagID, worldQuestType, color, iconWidth, iconHeight)
	-- NOTE: This doesn't filter anything, we already arrived at all the data at the callsite and evaluated whether
	-- or not this should have been added.
	AddQuestTagTooltipLine(tooltip, tagID, worldQuestType, tagName, iconWidth, iconHeight, color);
end

function QuestUtils_GetQuestName(questID)
	-- TODO: Make unified API for this?
	local questName = C_TaskQuest.GetQuestInfoByQuestID(questID);
	if not questName then
		local questIndex = GetQuestLogIndexByID(questID);
		if questIndex and questIndex > 0 then
			questName = GetQuestLogTitle(questIndex);
		end
	end

	return questName or "";
end

function QuestUtils_CanUseAutoGroupFinder(questID, isDropdownRequest)
	-- Auto-Finder dropdown is enabled for incomplete "group" non-dungeon quests that have a valid activity.
	-- Auto-Finder button is enabled for all non-dungeon quests that have a valid activity.
	if not IsQuestComplete(questID) then
		local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, displayTimeLeft = GetQuestTagInfo(questID);
	 	if not IsQuestDungeonQuest_Internal(tagID, worldQuestType) and C_LFGList.GetActivityIDForQuestID(questID) then
	 		local isCurrentExpansion = GetQuestExpansion(questID) == LE_EXPANSION_LEVEL_CURRENT;

			if IsQuestWorldQuest_Internal(worldQuestType) then
				return isDropdownRequest or (isElite and isCurrentExpansion);
			else
				local questIndex = GetQuestLogIndexByID(questID);
				if questIndex and questIndex > 0 then
					return isDropdownRequest or (isCurrentExpansion and (GetQuestLogGroupNum(questIndex) > 1));
				end
			end
		end
	end

	return false;
end

function QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip)
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
	local currencies = { };
	for i = 1, numQuestCurrencies do
		local name, texture, numItems, currencyID = GetQuestLogRewardCurrencyInfo(i, questID);
		local rarity = select(8, GetCurrencyInfo(currencyID));
		local currencyInfo = { name = name, texture = texture, numItems = numItems, currencyID = currencyID, rarity = rarity };
		tinsert(currencies, currencyInfo);
	end

	table.sort(currencies,
		function(currency1, currency2)
			if currency1.rarity ~= currency2.rarity then
				return currency1.rarity > currency2.rarity;
			end
			return currency1.currencyID > currency2.currencyID;
		end
	);

	for i, currencyInfo in ipairs(currencies) do
		local text = BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format(currencyInfo.texture, currencyInfo.numItems, currencyInfo.name);
		local currencyColor = GetColorForCurrencyReward(currencyInfo.currencyID, currencyInfo.numItems);
		tooltip:AddLine(text, currencyColor:GetRGB());
	end
	return numQuestCurrencies;
end