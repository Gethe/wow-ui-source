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

	local _, width, height = GetAtlasInfo(iconAtlas);
	return iconAtlas, width, height;
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

local function ShouldShowWarModeBonus(questID, warModeBonus, currencyID, currencyAmount)
	local warModeBonusPercentage = warModeBonus / 100;
	if Round(currencyAmount * warModeBonusPercentage) < 1 then
		return false;
	end

	return C_PvP.IsWarModeDesired() and QuestUtils_IsQuestWorldQuest(questID) and C_QuestLog.QuestHasWarModeBonus(questID) and not C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID);
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
				if ShouldShowWarModeBonus(questID, warModeBonus, currencyInfo.currencyID, currencyInfo.numItems) then
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

				if ShouldShowWarModeBonus(questID, warModeBonus, currencyInfo.currencyID, currencyInfo.numItems) then
					tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_FORMAT:format(warModeBonus));
				end

				addedQuestCurrencies = addedQuestCurrencies + 1;
			end
		end
	end
	return addedQuestCurrencies, alreadyUsedCurrencyContainerId > 0;
end
