

function WorldMap_IsWorldQuestEffectivelyTracked(questID)
	return IsWorldQuestHardWatched(questID) or (IsWorldQuestWatched(questID) and GetSuperTrackedQuestID() == questID);
end

WORLD_QUEST_REWARD_TYPE_FLAG_GOLD = 0x0001;
WORLD_QUEST_REWARD_TYPE_FLAG_RESOURCES = 0x0002;
WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER = 0x0004;
WORLD_QUEST_REWARD_TYPE_FLAG_MATERIALS = 0x0008;
WORLD_QUEST_REWARD_TYPE_FLAG_EQUIPMENT = 0x0010;
WORLD_QUEST_REWARD_TYPE_FLAG_REPUTATION = 0x0020;
function WorldMap_GetWorldQuestRewardType(questID)
	if ( not HaveQuestRewardData(questID) ) then
		C_TaskQuest.RequestPreloadRewardData(questID);
		return false;
	end

	local worldQuestRewardType = 0;
	if ( GetQuestLogRewardMoney(questID) > 0 ) then
		worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_GOLD);
	end

	local ORDER_RESOURCES_CURRENCY_ID = 1220;
	local azeriteCurrencyID = C_CurrencyInfo.GetAzeriteCurrencyID(); 
	local warResourcesCurrencyID = C_CurrencyInfo.GetWarResourcesCurrencyID();
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
	for i = 1, numQuestCurrencies do
		local currencyID = select(4, GetQuestLogRewardCurrencyInfo(i, questID));
		if ( currencyID == ORDER_RESOURCES_CURRENCY_ID or currencyID == warResourcesCurrencyID) then
			worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_RESOURCES);
		elseif ( currencyID == azeriteCurrencyID ) then
			worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER);
		elseif ( C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID) ~= nil ) then
			worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_REPUTATION);
		end
	end

	local numQuestRewards = GetNumQuestLogRewards(questID);
	for i = 1, numQuestRewards do
		local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(i, questID);
		if ( itemID ) then
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID = GetItemInfo(itemID);
			if ( classID == LE_ITEM_CLASS_WEAPON or classID == LE_ITEM_CLASS_ARMOR or (classID == LE_ITEM_CLASS_GEM and subclassID == LE_ITEM_GEM_ARTIFACTRELIC) ) then
				worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_EQUIPMENT);
			end

			if ( IsArtifactPowerItem(itemID) ) then
				worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER);
			end

			if ( classID == LE_ITEM_CLASS_TRADEGOODS ) then
				worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_MATERIALS);
			end
		end
	end

	return true, worldQuestRewardType;
end

function WorldMap_DoesWorldQuestInfoPassFilters(info, ignoreTypeFilters)
	local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, displayTimeLeft = GetQuestTagInfo(info.questId);

	if ( not ignoreTypeFilters ) then
		if ( worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION ) then
			local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();

			if ( tradeskillLineIndex == prof1 or tradeskillLineIndex == prof2 ) then
				if ( not GetCVarBool("primaryProfessionsFilter") ) then
					return false;
				end
			end

			if ( tradeskillLineIndex == fish or tradeskillLineIndex == cook or tradeskillLineIndex == firstAid ) then
				if ( not GetCVarBool("secondaryProfessionsFilter") ) then
					return false;
				end
			end
		elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE ) then
			if ( not GetCVarBool("showTamers") ) then
				return false;
			end
		else
			local dataLoaded, worldQuestRewardType = WorldMap_GetWorldQuestRewardType(info.questId);

			if ( not dataLoaded ) then
				return false;
			end

			local typeMatchesFilters = false;
			if ( GetCVarBool("worldQuestFilterGold") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_GOLD) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterResources") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_RESOURCES) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterArtifactPower") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterProfessionMaterials") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_MATERIALS) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterEquipment") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_EQUIPMENT) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterReputation") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_REPUTATION) ~= 0 ) then
				typeMatchesFilters = true;
			end

			-- We always want to show quests that do not fit any of the enumerated reward types.
			if ( worldQuestRewardType ~= 0 and not typeMatchesFilters ) then
				return false;
			end
		end
	end

	return true;
end

function WorldMap_AddQuestTimeToTooltip(questID)
	local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(questID);
	if ( timeLeftMinutes and timeLeftMinutes > 0 ) then
		local color = NORMAL_FONT_COLOR;
		if ( timeLeftMinutes <= WORLD_QUESTS_TIME_CRITICAL_MINUTES ) then
			color = RED_FONT_COLOR;
		end

		local timeString;
		if timeLeftMinutes <= 60 then
			timeString = SecondsToTime(timeLeftMinutes * 60);
		elseif timeLeftMinutes < 24 * 60  then
			timeString = D_HOURS:format(math.floor(timeLeftMinutes) / 60);
		else
			timeString = D_DAYS:format(math.floor(timeLeftMinutes) / 1440);
		end

		WorldMapTooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(timeString), color.r, color.g, color.b);
	end
end

function TaskPOI_OnEnter(self)
	WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if ( not HaveQuestData(self.questID) ) then
		WorldMapTooltip:SetText(RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		WorldMapTooltip:Show();
		return;
	end

	local title, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(self.questID);
	if ( self.worldQuest ) then
		local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, displayTimeLeft = GetQuestTagInfo(self.questID);
		local color = WORLD_QUEST_QUALITY_COLORS[rarity];
		WorldMapTooltip:SetText(title, color.r, color.g, color.b);
		QuestUtils_AddQuestTypeToTooltip(WorldMapTooltip, self.questID, NORMAL_FONT_COLOR);
			
		local factionName = factionID and GetFactionInfoByID(factionID);
		if (factionName) then
			local reputationYieldsRewards = (not capped) or C_Reputation.IsFactionParagon(factionID);
			if (reputationYieldsRewards) then
				WorldMapTooltip:AddLine(factionName);
			else 
				WorldMapTooltip:AddLine(factionName, GRAY_FONT_COLOR:GetRGB());
			end
		end

		if displayTimeLeft then
			WorldMap_AddQuestTimeToTooltip(self.questID);
		end
	else
		WorldMapTooltip:SetText(title);
	end

	for objectiveIndex = 1, self.numObjectives do
		local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(self.questID, objectiveIndex, false);

		if(self.shouldShowObjectivesAsStatusBar) then 
			local questLogIndex = GetQuestLogIndexByID(self.questID);
			local _, questDescription = GetQuestLogQuestText(questLogIndex);
			GameTooltip_AddColoredLine(WorldMapTooltip, QUEST_DASH .. questDescription, HIGHLIGHT_FONT_COLOR);

			local percent = math.floor((numFulfilled/numRequired) * 100);
			GameTooltip_ShowProgressBar(WorldMapTooltip, 0, numRequired, numFulfilled, PERCENTAGE_STRING:format(percent));
		elseif ( objectiveText and #objectiveText > 0 ) then
			local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
			WorldMapTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
		end
	end
	local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(self.questID, 1, false);
	local percent = C_TaskQuest.GetQuestProgressBarInfo(self.questID);
	if ( percent ) then
		GameTooltip_ShowProgressBar(WorldMapTooltip, 0, 100, percent, PERCENTAGE_STRING:format(percent));
	end

	GameTooltip_AddQuestRewardsToTooltip(WorldMapTooltip, self.questID);

	if ( self.worldQuest and WorldMapTooltip.AddDebugWorldQuestInfo ) then
		WorldMapTooltip:AddDebugWorldQuestInfo(self.questID);
	end

	WorldMapTooltip:Show();
	WorldMapTooltip.recalculatePadding = true;
end

function TaskPOI_OnLeave(self)
	WorldMapTooltip:Hide();
end

function WorldMapPing_StartPingQuest(questID)
	QuestMapFrame_PingQuestID(questID);
end

function WorldMapPing_StartPingPOI(poiFrame)
	-- MAPREFACTORTODO: Reimplement
end

function WorldMapPing_StopPing(frame)
	-- MAPREFACTORTODO: Reimplement
end

function WorldMapPing_UpdatePing(frame, contextData)
	-- MAPREFACTORTODO: Reimplement
end
