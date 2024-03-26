

function WorldMap_IsWorldQuestEffectivelyTracked(questID)
	-- A world quest is effectively tracked if it's being manually watched or if it's automatically watched and it matches our super-tracked quest.
	local watchType = C_QuestLog.GetQuestWatchType(questID);
	return (watchType == Enum.QuestWatchType.Manual) or (watchType == Enum.QuestWatchType.Automatic and C_SuperTrack.GetSuperTrackedQuestID() == questID);
end

WORLD_QUEST_REWARD_TYPE_FLAG_GOLD = 0x0001;
WORLD_QUEST_REWARD_TYPE_FLAG_RESOURCES = 0x0002;
WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER = 0x0004;
WORLD_QUEST_REWARD_TYPE_FLAG_MATERIALS = 0x0008;
WORLD_QUEST_REWARD_TYPE_FLAG_EQUIPMENT = 0x0010;
WORLD_QUEST_REWARD_TYPE_FLAG_REPUTATION = 0x0020;
WORLD_QUEST_REWARD_TYPE_FLAG_ANIMA = 0x0040;
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
	local dragonIslesSuppliesCurrencyID = C_CurrencyInfo.GetDragonIslesSuppliesCurrencyID();
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
	for i = 1, numQuestCurrencies do
		local currencyID = select(4, GetQuestLogRewardCurrencyInfo(i, questID));
		if ( currencyID == ORDER_RESOURCES_CURRENCY_ID or currencyID == warResourcesCurrencyID or currencyID == dragonIslesSuppliesCurrencyID ) then
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
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID = C_Item.GetItemInfo(itemID);
			if ( classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor or (classID == Enum.ItemClass.Gem and subclassID == Enum.ItemGemSubclass.Artifactrelic) ) then
				worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_EQUIPMENT);
			end

			if ( C_Item.IsArtifactPowerItem(itemID) ) then
				worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER);
			end

			if ( classID == Enum.ItemClass.Tradegoods ) then
				worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_MATERIALS);
			end

			if ( C_Item.IsAnimaItemByID(itemID) ) then
				worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ANIMA);
			end
		end
	end

	return true, worldQuestRewardType;
end

function WorldMap_DoesWorldQuestInfoPassFilters(info, ignoreTypeFilters)
	local tagInfo = C_QuestLog.GetQuestTagInfo(info.questId);

	if ( not ignoreTypeFilters and tagInfo ) then
		if ( tagInfo.worldQuestType == Enum.QuestTagType.Profession ) then
			local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();
			local tradeskillLineIndex = tagInfo.tradeskillLineID and C_SpellBook.GetSkillLineIndexByID(tagInfo.tradeskillLineID);

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
		elseif ( tagInfo.worldQuestType == Enum.QuestTagType.PetBattle ) then
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
			elseif ( GetCVarBool("worldQuestFilterAnima") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ANIMA) ~= 0 ) then
				typeMatchesFilters = true;
			end

			-- We always want to show quests that do not fit any of the enumerated reward types.
			if ( worldQuestRewardType ~= 0 and not typeMatchesFilters ) then
				return false;
			end
		end
	else
		-- Even if we don't care about type filters, we still want to make sure reward data is up to date
		if not HaveQuestRewardData(info.questId) then
			C_TaskQuest.RequestPreloadRewardData(info.questId);
		end
	end

	return true;
end

function WorldMap_GetQuestTimeForTooltip(questID)
	local secondsRemaining = C_TaskQuest.GetQuestTimeLeftSeconds(questID);
	if secondsRemaining then
		local color = QuestUtils_GetQuestTimeColor(secondsRemaining);
		local formatterOutput = WorldQuestsSecondsFormatter:Format(secondsRemaining);
		local formattedTime = BONUS_OBJECTIVE_TIME_LEFT:format(formatterOutput);
		return formattedTime, color, secondsRemaining;
	end
end

function CallingPOI_OnEnter(self)
	local noWrap = false;
	GameTooltip_SetTitle(GameTooltip, QuestUtils_GetQuestName(self.questID), nil, noWrap);
	GameTooltip_AddQuestTimeToTooltip(GameTooltip, self.questID);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, CALLING_QUEST_TOOLTIP_DESCRIPTION);

	local widgetSetID = C_TaskQuest.GetQuestTooltipUIWidgetSet(self.questID);
	if (widgetSetID) then
		GameTooltip_AddWidgetSet(GameTooltip, widgetSetID);
	end

	GameTooltip_AddQuestRewardsToTooltip(GameTooltip, self.questID, TOOLTIP_QUEST_REWARDS_STYLE_CALLING_REWARD);
	GameTooltip:Show();
end

function TaskPOI_OnEnter(self, skipSetOwner)
	if not skipSetOwner then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end

	if ( not HaveQuestData(self.questID) ) then
		GameTooltip_SetTitle(GameTooltip, RETRIEVING_DATA, RED_FONT_COLOR);
		GameTooltip_SetTooltipWaitingForData(GameTooltip, true);
		GameTooltip:Show();
		return;
	end

	if C_QuestLog.IsQuestCalling(self.questID) then
		CallingPOI_OnEnter(self);
		return;
	end

	GameTooltip_AddQuest(self);
	EventRegistry:TriggerEvent("TaskPOI.TooltipShown", self, self.questID, self);
end

function TaskPOI_OnLeave(self)
	GameTooltip:Hide();
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
