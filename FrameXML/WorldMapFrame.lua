

function WorldMap_IsWorldQuestEffectivelyTracked(questID)
	return IsWorldQuestHardWatched(questID) or (IsWorldQuestWatched(questID) and GetSuperTrackedQuestID() == questID);
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

function WorldMap_SetupWorldQuestButton(button, worldQuestType, rarity, isElite, tradeskillLineIndex, inProgress, selected, isCriteria, isSpellTarget, isEffectivelyTracked)
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
	if ( worldQuestType == LE_QUEST_TAG_TYPE_PVP ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-pvp-ffa", true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-petbattle", true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION and WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID] ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID], true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_DUNGEON ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-dungeon", true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_RAID ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-raid", true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_INVASION ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-burninglegion", true);
		end
	else
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-questmarker-questbang");
			button.Texture:SetSize(6, 15);
		end
	end

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

WORLD_QUEST_REWARD_TYPE_FLAG_GOLD = 0x0001;
WORLD_QUEST_REWARD_TYPE_FLAG_ORDER_RESOURCES = 0x0002;
WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER = 0x0004;
WORLD_QUEST_REWARD_TYPE_FLAG_MATERIALS = 0x0008;
WORLD_QUEST_REWARD_TYPE_FLAG_EQUIPMENT = 0x0010;
function WorldMap_GetWorldQuestRewardType(questID)
	if ( not HaveQuestRewardData(questID) ) then
		C_TaskQuest.RequestPreloadRewardData(questID);
		return false;
	end

	local worldQuestRewardType = 0;
	if ( GetQuestLogRewardMoney(questID) > 0 ) then
		worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_GOLD);
	end

	if ( GetQuestLogRewardArtifactXP(questID) > 0 ) then
		worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER);
	end

	local ORDER_RESOURCES_CURRENCY_ID = 1220;
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
	for i = 1, numQuestCurrencies do
		if ( select(4, GetQuestLogRewardCurrencyInfo(i, questID)) == ORDER_RESOURCES_CURRENCY_ID ) then
			worldQuestRewardType = bit.bor(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ORDER_RESOURCES);
			break;
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
			elseif ( GetCVarBool("worldQuestFilterOrderResources") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ORDER_RESOURCES) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterArtifactPower") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterProfessionMaterials") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_MATERIALS) ~= 0 ) then
				typeMatchesFilters = true;
			elseif ( GetCVarBool("worldQuestFilterEquipment") and bit.band(worldQuestRewardType, WORLD_QUEST_REWARD_TYPE_FLAG_EQUIPMENT) ~= 0 ) then
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

		if ( factionID ) then
			local factionName = GetFactionInfoByID(factionID);
			if ( factionName ) then
				if (capped) then
					WorldMapTooltip:AddLine(factionName, GRAY_FONT_COLOR:GetRGB());
				else
					WorldMapTooltip:AddLine(factionName);
				end
			end
		end

		if displayTimeLeft then
			WorldMap_AddQuestTimeToTooltip(self.questID);
		end
	else
		WorldMapTooltip:SetText(title);
	end

	for objectiveIndex = 1, self.numObjectives do
		local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(self.questID, objectiveIndex, false);
		if ( objectiveText and #objectiveText > 0 ) then
			local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
			WorldMapTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
		end
	end

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

WorldMapPingMixin = {};

function WorldMapPingMixin:PlayOnFrame(frame, contextData)
	if self.targetFrame ~= frame then
		if frame and frame:IsVisible() then
			self:ClearAllPoints();
			self:SetPoint("CENTER", frame);

			self:Stop();
			self:SetTargetFrame(frame);
			self:SetContextData(contextData);
			self:Play();
		else
			self:Stop();
		end
	end
end

function WorldMapPingMixin:SetTargetFrame(frame)
	-- Stop this ping from playing on any previous target
	if self.targetFrame then
		self.targetFrame.worldMapPing = nil;
	end

	-- This ping is now targeting a new frame (or nothing)
	self.targetFrame = frame;

	-- Clear out context data, it's meaningless with a new frame
	self:SetContextData(nil);

	-- If that frame is a valid target, then let it know that a ping is attached
	if frame then
		frame.worldMapPing = self;

		-- Layer this behind the frame that's targeted (could make this dynamic)
		-- Might need to reparent, this currently works because it's only operating
		-- on TaskPOI pins.
		self:SetFrameLevel(frame:GetFrameLevel() + 1);
	end
end

function WorldMapPingMixin:SetContextData(contextData)
	self.contextData = contextData;
end

function WorldMapPingMixin:GetContextData()
	return self.contextData;
end

function WorldMapPingMixin:Play()
	self.DriverAnimation:Play();
end

function WorldMapPingMixin:Stop()
	self.DriverAnimation:Stop();
end

WorldMapPingAnimationMixin = {};

function WorldMapPingAnimationMixin:OnPlay()
	local ping = self:GetParent();
	ping.ScaleAnimation:Play();
end

function WorldMapPingAnimationMixin:OnStop()
	local ping = self:GetParent();
	ping:SetTargetFrame(nil);
	ping.ScaleAnimation:Stop();
end

function WorldMapPing_StartPingQuest(questID)
	-- MAPREFACTORTODO: Reimplement
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
