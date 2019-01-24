QUEST_TAG_DUNGEON_TYPES = {
	[Enum.QuestTag.Raid] = true,
	[Enum.QuestTag.Dungeon] = true,
	[Enum.QuestTag.Raid10] = true,
	[Enum.QuestTag.Raid25] = true,
};

WORLD_QUEST_TYPE_DUNGEON_TYPES = {
	[LE_QUEST_TAG_TYPE_DUNGEON] = true,
	[LE_QUEST_TAG_TYPE_RAID] = true,
}

WorldQuestsSecondsFormatter = CreateFromMixins(SecondsFormatterMixin);
WorldQuestsSecondsFormatter:OnLoad(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.None, false);

function WorldQuestsSecondsFormatter:GetDesiredUnitCount(seconds)
	return seconds > SECONDS_PER_DAY and 2 or 1;
end

function WorldQuestsSecondsFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Minutes;
end

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

QuestUtil = {};

function QuestUtil.GetWorldQuestAtlasInfo(worldQuestType, inProgress, tradeskillLineIndex)
	local iconAtlas;
	local tradeskillLineID = tradeskillLineIndex and select(7, GetProfessionInfo(tradeskillLineIndex));
	if ( inProgress ) then
		return "worldquest-questmarker-questionmark", 10, 15;
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PVP ) then
		iconAtlas =  "worldquest-icon-pvp-ffa";
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE ) then
		iconAtlas =  "worldquest-icon-petbattle";
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION and WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID] ) then
		iconAtlas =  WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID];
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_DUNGEON ) then
		iconAtlas =  "worldquest-icon-dungeon";
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_RAID ) then
		iconAtlas =  "worldquest-icon-raid";
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_INVASION ) then
		iconAtlas =  "worldquest-icon-burninglegion";
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_ISLANDS ) then
		iconAtlas ="poi-islands-table";
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_FACTION_ASSAULT ) then
		local factionTag = UnitFactionGroup("player");
		if factionTag == "Alliance" then
			iconAtlas = "worldquest-icon-alliance";
		else -- "Horde" or "Neutral"
			iconAtlas = "worldquest-icon-horde";
		end
	else
		return "worldquest-questmarker-questbang", 6, 15;
	end

	local info = C_Texture.GetAtlasInfo(iconAtlas);
	return iconAtlas, info and info.width, info and info.height;
end

local function ApplyTextureToPOI(texture, width, height)
	texture:SetTexCoord(0, 1, 0, 1);
	texture:ClearAllPoints();
	texture:SetPoint("CENTER", texture:GetParent());
	texture:SetSize(width or 32, height or 32);
end

local function ApplyAtlasTexturesToPOI(button, normal, pushed, highlight, width, height)
	button:SetSize(20, 20);
	button:SetNormalAtlas(normal);
	ApplyTextureToPOI(button:GetNormalTexture(), width, height);

	button:SetPushedAtlas(pushed);
	ApplyTextureToPOI(button:GetPushedTexture(), width, height);

	button:SetHighlightAtlas(highlight);
	ApplyTextureToPOI(button:GetHighlightTexture(), width, height);

	if button.SelectedGlow then
		button.SelectedGlow:SetAtlas(pushed);
		ApplyTextureToPOI(button.SelectedGlow, width, height);
	end
end

local function ApplyStandardTexturesToPOI(button, selected)
	button:SetSize(20, 20);
	button:SetNormalTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetNormalTexture());
	if selected then
		button:GetNormalTexture():SetTexCoord(0.500, 0.625, 0.375, 0.5);
	else
		button:GetNormalTexture():SetTexCoord(0.875, 1, 0.375, 0.5);
	end


	button:SetPushedTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetPushedTexture());
	if selected then
		button:GetPushedTexture():SetTexCoord(0.375, 0.500, 0.375, 0.5);
	else
		button:GetPushedTexture():SetTexCoord(0.750, 0.875, 0.375, 0.5);
	end

	button:SetHighlightTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetHighlightTexture());
	button:GetHighlightTexture():SetTexCoord(0.625, 0.750, 0.875, 1);
end

function QuestUtil.SetupWorldQuestButton(button, worldQuestType, rarity, isElite, tradeskillLineIndex, inProgress, selected, isCriteria, isSpellTarget, isEffectivelyTracked)
	button.Glow:SetShown(selected);

	if rarity == LE_WORLD_QUEST_QUALITY_COMMON then
		ApplyStandardTexturesToPOI(button, selected);
	elseif rarity == LE_WORLD_QUEST_QUALITY_RARE then
		ApplyAtlasTexturesToPOI(button, "worldquest-questmarker-rare", "worldquest-questmarker-rare-down", "worldquest-questmarker-rare", 18, 18);
	elseif rarity == LE_WORLD_QUEST_QUALITY_EPIC then
		ApplyAtlasTexturesToPOI(button, "worldquest-questmarker-epic", "worldquest-questmarker-epic-down", "worldquest-questmarker-epic", 18, 18);
	end

	if ( button.SelectedGlow ) then
		button.SelectedGlow:SetShown(rarity ~= LE_WORLD_QUEST_QUALITY_COMMON and selected);
	end

	if ( isElite ) then
		button.Underlay:SetAtlas("worldquest-questmarker-dragon");
		button.Underlay:Show();
	else
		button.Underlay:Hide();
	end

	local tradeskillLineID = tradeskillLineIndex and select(7, GetProfessionInfo(tradeskillLineIndex));
	local atlas, width, height = QuestUtil.GetWorldQuestAtlasInfo(worldQuestType, inProgress, tradeskillLineIndex)
	button.Texture:SetAtlas(atlas);
	button.Texture:SetSize(width, height);

	if ( button.TimeLowFrame ) then
		button.TimeLowFrame:Hide();
	end

	if ( button.CriteriaMatchRing ) then
		button.CriteriaMatchRing:SetShown(isCriteria);
	end

	if ( button.TrackedCheck ) then
		button.TrackedCheck:SetShown(isEffectivelyTracked);
	end

	if ( button.SpellTargetGlow ) then
		button.SpellTargetGlow:SetShown(isSpellTarget);
	end
end

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
	return IsQuestDungeonQuest_Internal(tagID, worldQuestType);
end

function QuestUtils_IsQuestBonusObjective(questID)
	return IsQuestTask(questID) and not QuestUtils_IsQuestWorldQuest(questID);
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
		else
			questName = C_QuestLog.GetQuestInfo(questID);
		end
	end

	return questName or "";
end

local function ShouldShowWarModeBonus(questID, currencyID)
	if not C_PvP.IsWarModeDesired() then
		return false;
	end

	if not C_CurrencyInfo.DoesWarModeBonusApply(currencyID) then
		return false;
	end

	return QuestUtils_IsQuestWorldQuest(questID) and C_QuestLog.QuestHasWarModeBonus(questID) and not C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID);
end

function QuestUtils_AddQuestRewardsToTooltip(tooltip, questID, style)
	local hasAnySingleLineRewards = false;
	local isWarModeDesired = C_PvP.IsWarModeDesired();
	local questHasWarModeBonus = C_QuestLog.QuestHasWarModeBonus(questID);

	-- xp
	local totalXp, baseXp = GetQuestLogRewardXP(questID);
	if ( baseXp > 0 ) then
		GameTooltip_AddColoredLine(tooltip, BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(baseXp), HIGHLIGHT_FONT_COLOR);
		if (isWarModeDesired and questHasWarModeBonus) then
			tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_XP_FORMAT:format(C_PvP.GetWarModeRewardBonus()));
		end
		hasAnySingleLineRewards = true;
	end
	local artifactXP = GetQuestLogRewardArtifactXP(questID);
	if ( artifactXP > 0 ) then
		GameTooltip_AddColoredLine(tooltip, BONUS_OBJECTIVE_ARTIFACT_XP_FORMAT:format(artifactXP), HIGHLIGHT_FONT_COLOR);
		hasAnySingleLineRewards = true;
	end

	-- currency
	if not style.atLeastShowAzerite then
		local numAddedQuestCurrencies, usingCurrencyContainer = QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip, tooltip.ItemTooltip);
		if ( numAddedQuestCurrencies > 0 ) then
			hasAnySingleLineRewards = not usingCurrencyContainer or numAddedQuestCurrencies > 1;
		end
	end

	-- honor
	local honorAmount = GetQuestLogRewardHonor(questID);
	if ( honorAmount > 0 ) then
		GameTooltip_AddColoredLine(tooltip, BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format("Interface\\ICONS\\Achievement_LegionPVPTier4", honorAmount, HONOR), HIGHLIGHT_FONT_COLOR);
		hasAnySingleLineRewards = true;
	end

	-- money
	local money = GetQuestLogRewardMoney(questID);
	if ( money > 0 ) then
		SetTooltipMoney(tooltip, money, nil);
		if (isWarModeDesired and QuestUtils_IsQuestWorldQuest(questID) and questHasWarModeBonus) then
			tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_FORMAT:format(C_PvP.GetWarModeRewardBonus()));
		end
		hasAnySingleLineRewards = true;
	end
	
	-- items
	local showRetrievingData = false;
	local numQuestRewards = GetNumQuestLogRewards(questID);	
	local numCurrencyRewards = GetNumQuestLogRewardCurrencies(questID);
	if numQuestRewards > 0 and (not style.prioritizeCurrencyOverItem or numCurrencyRewards == 0) then
		if style.fullItemDescription then 
			-- we want to do a full item description
			local itemIndex = QuestUtils_GetBestQualityItemRewardIndex(questID);  -- Only support one item reward currently
			if not EmbeddedItemTooltip_SetItemByQuestReward(tooltip.ItemTooltip, itemIndex, questID) then
				showRetrievingData = true;
			end
			-- check for item compare input of flag
			if not showRetrievingData then
				if IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") then
					GameTooltip_ShowCompareItem(tooltip.ItemTooltip.Tooltip, tooltip.BackdropFrame);
				else
					for i, tooltip in ipairs(tooltip.ItemTooltip.Tooltip.shoppingTooltips) do
						tooltip:Hide();
					end
				end
			end
		else
			-- we want to do an abbreviated item description
			local name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo(1, questID);
			if numItems > 1 then
				text = string.format(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, texture, HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(numItems), name);
			elseif texture and name then
				text = string.format(BONUS_OBJECTIVE_REWARD_FORMAT, texture, name);
			end
			if text then
				local color = ITEM_QUALITY_COLORS[quality];
				GameTooltip:AddLine(text, color.r, color.g, color.b);
			end
		end
	end

	-- atLeastShowAzerite: show azerite if nothing else is awarded
	-- and in the case of double azerite, only show the currency container one
	if style.atLeastShowAzerite and not hasAnySingleLineRewards and not tooltip.ItemTooltip:IsShown() then
		local numAddedQuestCurrencies, usingCurrencyContainer = QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip, tooltip.ItemTooltip);
		if ( numAddedQuestCurrencies > 0 ) then
			hasAnySingleLineRewards = not usingCurrencyContainer or numAddedQuestCurrencies > 1;
			if usingCurrencyContainer and numAddedQuestCurrencies > 1 then
				EmbeddedItemTooltip_Clear(tooltip.ItemTooltip);
				tooltip.ItemTooltip:Hide();
				tooltip:Show();
			end
		end
	end
	return hasAnySingleLineRewards, showRetrievingData;
end

--currencyContainerTooltip should be an InternalEmbeddedItemTooltipTemplate
function QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip, currencyContainerTooltip)
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

	local addedQuestCurrencies = 0;
	local alreadyUsedCurrencyContainerId = 0; --In the case of multiple currency containers needing to displayed, we only display the first.
	local warModeBonus = C_PvP.GetWarModeRewardBonus();

	for i, currencyInfo in ipairs(currencies) do
		local isCurrencyContainer = C_CurrencyInfo.IsCurrencyContainer(currencyInfo.currencyID, currencyInfo.numItems);
		if ( currencyContainerTooltip and isCurrencyContainer and (alreadyUsedCurrencyContainerId == 0) ) then
			if ( EmbeddedItemTooltip_SetCurrencyByID(currencyContainerTooltip, currencyInfo.currencyID, currencyInfo.numItems) ) then
				if ShouldShowWarModeBonus(questID, currencyInfo.currencyID) then
					currencyContainerTooltip.Tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_FORMAT:format(warModeBonus));
					currencyContainerTooltip.Tooltip:Show();
				end

				if ( not tooltip ) then
					break;
				end

				addedQuestCurrencies = addedQuestCurrencies + 1;
				alreadyUsedCurrencyContainerId = currencyInfo.currencyID;
			end
		elseif ( tooltip ) then
			if( alreadyUsedCurrencyContainerId ~= currencyInfo.currencyID ) then --if there's already a currency container of this same type skip it entirely
				if isCurrencyContainer then
					local name, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyInfo.currencyID, currencyInfo.numItems);
					local text = BONUS_OBJECTIVE_REWARD_FORMAT:format(texture, name);
					local color = ITEM_QUALITY_COLORS[quality];
					tooltip:AddLine(text, color.r, color.g, color.b);
				else
					local text = BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format(currencyInfo.texture, currencyInfo.numItems, currencyInfo.name);
					local currencyColor = GetColorForCurrencyReward(currencyInfo.currencyID, currencyInfo.numItems);
					tooltip:AddLine(text, currencyColor:GetRGB());
				end

				if ShouldShowWarModeBonus(questID, currencyInfo.currencyID) then
					tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_FORMAT:format(warModeBonus));
				end

				addedQuestCurrencies = addedQuestCurrencies + 1;
			end
		end
	end
	return addedQuestCurrencies, alreadyUsedCurrencyContainerId > 0;
end

function QuestUtils_GetCurrentQuestLineQuest(questLineID)
	local quests = C_QuestLine.GetQuestLineQuests(questLineID);
	local currentQuestID = 0;
	for i, questID in ipairs(quests) do
		if C_QuestLog.IsOnQuest(questID) then
			currentQuestID = questID;
			break;
		end
	end
	return currentQuestID;
end

function QuestUtils_GetBestQualityItemRewardIndex(questID)
	local index;
	local bestQuality = -1;
	local numQuestRewards = GetNumQuestLogRewards(questID);
	for i = 1, numQuestRewards do
		local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(i, questID);
		if quality > bestQuality then
			index = i;
			bestQuality = quality;
		end
	end
	return index;
end

function QuestUtils_IsQuestWithinTimeThreshold(questID, threshold)
	local secondsRemaining = C_TaskQuest.GetQuestTimeLeftSeconds(questID);
	return secondsRemaining and secondsRemaining <= threshold or false;
end

function QuestUtils_IsQuestWithinLowTimeThreshold(questID)
	return QuestUtils_IsQuestWithinTimeThreshold(questID, MinutesToSeconds(WORLD_QUESTS_TIME_LOW_MINUTES));
end

function QuestUtils_IsQuestWithinCriticalTimeThreshold(questID)
	return QuestUtils_IsQuestWithinTimeThreshold(questID, MinutesToSeconds(WORLD_QUESTS_TIME_CRITICAL_MINUTES));
end

function QuestUtils_GetQuestTimeColor(secondsRemaining)
	local isWithinCriticalTime = secondsRemaining <= MinutesToSeconds(WORLD_QUESTS_TIME_CRITICAL_MINUTES);
	return isWithinCriticalTime and RED_FONT_COLOR or NORMAL_FONT_COLOR;
end

function QuestUtils_ShouldDisplayExpirationWarning(questID)
	local displayExpiration = select(7, GetQuestTagInfo(questID));
	return displayExpiration;
end