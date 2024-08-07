QUEST_TAG_DUNGEON_TYPES = {
	[Enum.QuestTag.Raid] = true,
	[Enum.QuestTag.Dungeon] = true,
	[Enum.QuestTag.Raid10] = true,
	[Enum.QuestTag.Raid25] = true,
};

WORLD_QUEST_TYPE_DUNGEON_TYPES = {
	[Enum.QuestTagType.Dungeon] = true,
	[Enum.QuestTagType.Raid] = true,
};

local ECHOS_OF_NYLOTHA_CURRENCY_ID = 1803;

WorldQuestsSecondsFormatter = CreateFromMixins(SecondsFormatterMixin);
WorldQuestsSecondsFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.None, false);

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

local function GetQuestTypeIconMarkupStringFromTagData(tagID, worldQuestType, text, iconWidth, iconHeight)
	local atlasName = QuestUtils_GetQuestTagAtlas(tagID, worldQuestType);

	if atlasName then
		-- Use reasonable defaults if nothing is specified
		iconWidth = iconWidth or 20;
		iconHeight = iconHeight or 20;

		local atlasMarkup = CreateAtlasMarkup(atlasName, iconWidth, iconHeight);
		return string.format("%s %s", atlasMarkup, text); -- Convert to localized string to handle dynamic icon placement?
	end
end

local function AddQuestTagTooltipLine(tooltip, tagID, worldQuestType, lineText, iconWidth, iconHeight, color)
	local tooltipLine = GetQuestTypeIconMarkupStringFromTagData(tagID, worldQuestType, lineText, iconWidth, iconHeight);
	if tooltipLine then
		tooltip:AddLine(tooltipLine, color:GetRGB());
	end
end

-- Quest Utils API

QuestUtil = {};

local function GetWorldQuestAtlasInfo(questID, tagInfo, inProgress)
	-- NOTE: In-progress no longer matters, the center icon remains the same for world quests, even when active
	local worldQuestType = tagInfo.worldQuestType;

	if worldQuestType == Enum.QuestTagType.Capstone then
		return "worldquest-Capstone";
	elseif worldQuestType == Enum.QuestTagType.PvP then
		return "worldquest-icon-pvp-ffa";
	elseif worldQuestType == Enum.QuestTagType.PetBattle then
		return "worldquest-icon-petbattle";
	elseif worldQuestType == Enum.QuestTagType.Profession and WORLD_QUEST_ICONS_BY_PROFESSION[tagInfo.tradeskillLineID] then
		return WORLD_QUEST_ICONS_BY_PROFESSION[tagInfo.tradeskillLineID];
	elseif worldQuestType == Enum.QuestTagType.Dungeon then
		return "worldquest-icon-dungeon";
	elseif worldQuestType == Enum.QuestTagType.Raid then
		return "worldquest-icon-raid";
	elseif worldQuestType == Enum.QuestTagType.Invasion then
		return "worldquest-icon-burninglegion";
	elseif worldQuestType == Enum.QuestTagType.Islands then
		return "poi-islands-table";
	elseif worldQuestType == Enum.QuestTagType.FactionAssault then
		local factionTag = UnitFactionGroup("player");
		if factionTag == "Alliance" then
			return "worldquest-icon-alliance";
		else -- "Horde" or "Neutral"
			return "worldquest-icon-horde";
		end
	elseif worldQuestType == Enum.QuestTagType.Threat then
		return QuestUtil.GetThreatPOIIcon(questID);
	elseif worldQuestType == Enum.QuestTagType.DragonRiderRacing then
		return "worldquest-icon-race";
	elseif (worldQuestType == Enum.QuestTagType.WorldBoss) or (worldQuestType == Enum.QuestTagType.Normal and tagInfo.isElite and tagInfo.quality == Enum.WorldQuestQuality.Epic) then
		-- NOTE: Updated to include the new world boss type, but this continues to support the old way of identifying world bosses for now
		return "worldquest-icon-boss";
	else
		if questID then
			local theme = C_QuestLog.GetQuestDetailsTheme(questID);
			if theme then
				return theme.poiIcon;
			end
		end
	end

	return "Worldquest-icon";
end

function QuestUtil.GetWorldQuestAtlasInfo(questID, tagInfo, inProgress)
	local iconAtlas, width, height = GetWorldQuestAtlasInfo(questID, tagInfo, inProgress);

	if iconAtlas then
		local info = C_Texture.GetAtlasInfo(iconAtlas);
		if info then
			return iconAtlas, width or info.width, height or info.height;
		end
	end

	return "Worldquest-icon", 32, 32;
end

function QuestUtil.GetQuestIconOffer(isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling, isImportant, isMeta)
	if isCampaign then
		return "CampaignAvailableQuestIcon", true;
	elseif isLegendary then
		return "legendaryavailablequesticon", true;
	elseif isCovenantCalling then
		return "CampaignAvailableDailyQuestIcon", true;
	elseif isImportant then
		return "importantavailablequesticon", true;
	elseif isMeta then
		return "Wrapperavailablequesticon", true;
	elseif QuestUtil.IsFrequencyRecurring(frequency) then
		return "Recurringavailablequesticon", true;
	elseif isRepeatable then
		return "Interface/GossipFrame/DailyActiveQuestIcon", false;
	end

	return "Interface/GossipFrame/AvailableQuestIcon", false;
end

local function ApplyAssetToTexture(texture, asset, isAtlas)
	if isAtlas then
		texture:SetAtlas(asset, true);
	else
		texture:SetSize(16, 16);
		texture:SetTexture(asset);
	end
end

function QuestUtil.ApplyQuestIconOfferToTexture(texture, ...)
	ApplyAssetToTexture(texture, QuestUtil.GetQuestIconOffer(...));
end

function QuestUtil.GetQuestIconActive(isComplete, isLegendary, frequency, isRepeatable, isCampaign, isCovenantCalling, isImportant, isMeta)
	-- Frequency and isRepeatable aren't used yet, reserved for differentiating daily/weekly quests from other ones...
	if isComplete then
		if isCampaign then
			return "CampaignActiveQuestIcon", true;
		elseif isLegendary then
			return "legendaryactivequesticon", true;
		elseif isCovenantCalling then
			return "CampaignActiveDailyQuestIcon", true;
		elseif isImportant then
			return "importantactivequesticon", true;
		elseif isMeta then
			return "Wrapperactivequesticon", true;
		elseif QuestUtil.IsFrequencyRecurring(frequency) then
			return "Recurringactivequesticon", true;
		else
			return "Interface/GossipFrame/ActiveQuestIcon", false;
		end
	end

	if isCampaign or isCovenantCalling then
		return "CampaignInProgressQuestIcon", true;
	elseif isLegendary then
		return "legendaryInProgressquesticon", true;
	elseif isImportant then
		return "importantInProgressquesticon", true;
	elseif isMeta then
		return "WrapperInProgressquesticon", true;
	elseif QuestUtil.IsFrequencyRecurring(frequency) then
		return "RepeatableInProgressquesticon", true;
	end

	return "SideInProgressquesticon", true;
end

function QuestUtil.ApplyQuestIconActiveToTexture(texture, ...)
	ApplyAssetToTexture(texture, QuestUtil.GetQuestIconActive(...));
end

function QuestUtil.ShouldQuestIconsUseCampaignAppearance(questID)
	local quest = QuestCache:Get(questID);
	if quest:IsCampaign() then
		return not CampaignCache:Get(quest:GetCampaignID()):UsesNormalQuestIcons();
	end

	return false;
end

local function GetQuestIconLookInfo(questID, isComplete, isLegendary, frequency, isRepeatable, isImportant, isMeta)
	local quest = QuestCache:Get(questID);
	-- allow for possible overrides
	if isComplete == nil then
		isComplete = quest:IsComplete();
	end
	if isLegendary == nil then
		isLegendary = quest:IsLegendary();
	end
	if frequency == nil then
		frequency = quest.frequency;
	end
	if isRepeatable == nil then
		isRepeatable = quest:IsRepeatableQuest();
	end
	if isImportant == nil then
		isImportant = quest:IsImportant();
	end
	if isMeta == nil then
		isMeta = quest:IsMeta();
	end
	local isCampaign = QuestUtil.ShouldQuestIconsUseCampaignAppearance(questID);
	local isCalling = C_QuestLog.IsQuestCalling(questID);
	return isComplete, isLegendary, frequency, isRepeatable, isCampaign, isCalling, isImportant, isMeta;
end

function QuestUtil.GetQuestIconOfferForQuestID(questID, isLegendary, frequency, isRepeatable, isImportant, isMeta)
	local unusedIsComplete = false;
	local isCampaign, isCalling;
	unusedIsComplete, isLegendary, frequency, isRepeatable, isCampaign, isCalling, isImportant, isMeta = GetQuestIconLookInfo(questID, unusedIsComplete, isLegendary, frequency, isRepeatable, isImportant, isMeta);
	return QuestUtil.GetQuestIconOffer(isLegendary, frequency, isRepeatable, isCampaign, isCalling, isImportant, isMeta);
end

function QuestUtil.ApplyQuestIconOfferToTextureForQuestID(texture, ...)
	ApplyAssetToTexture(texture, QuestUtil.GetQuestIconOfferForQuestID(...));
end

function QuestUtil.GetQuestIconActiveForQuestID(questID, isComplete, isLegendary, frequency, isRepeatable, isImportant, isMeta)
	local isCampaign, isCalling;
	isComplete, isLegendary, frequency, isRepeatable, isCampaign, isCalling, isImportant, isMeta = GetQuestIconLookInfo(questID, isComplete, isLegendary, frequency, isRepeatable, isImportant, isMeta);
	return QuestUtil.GetQuestIconActive(isComplete, isLegendary, frequency, isRepeatable, isCampaign, isCalling, isImportant, isMeta);
end

function QuestUtil.ApplyQuestIconActiveToTextureForQuestID(texture, ...)
	ApplyAssetToTexture(texture, QuestUtil.GetQuestIconActiveForQuestID(...));
end

function QuestUtil.IsQuestActiveButNotComplete(questID)
	if C_QuestLog.IsQuestFlaggedCompleted(questID) or C_QuestLog.ReadyForTurnIn(questID) then
		return false;
	end
	return C_QuestLog.GetLogIndexForQuestID(questID) ~= nil;
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

function QuestUtil.SetupWorldQuestButton(button, info, inProgress, selected, isCriteria, isSpellTarget, isEffectivelyTracked)
	button.Glow:SetShown(selected);

	if info.quality == Enum.WorldQuestQuality.Common then
		ApplyStandardTexturesToPOI(button, selected);
	elseif info.quality == Enum.WorldQuestQuality.Rare then
		ApplyAtlasTexturesToPOI(button, "worldquest-questmarker-rare", "worldquest-questmarker-rare-down", "worldquest-questmarker-rare", 18, 18);
	elseif info.quality == Enum.WorldQuestQuality.Epic then
		ApplyAtlasTexturesToPOI(button, "worldquest-questmarker-epic", "worldquest-questmarker-epic-down", "worldquest-questmarker-epic", 18, 18);
	end

	if ( button.SelectedGlow ) then
		button.SelectedGlow:SetShown(info.quality ~= Enum.WorldQuestQuality.Common and selected);
	end

	if ( info.isElite ) then
		button.Underlay:SetAtlas("worldquest-questmarker-dragon");
		button.Underlay:Show();
	else
		button.Underlay:Hide();
	end

	local atlas, width, height = QuestUtil.GetWorldQuestAtlasInfo(info.worldQuestType, inProgress, info.tradeskillLineID);
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

function QuestUtil.QuestTextContrastEnabled()
	return GetCVarNumberOrDefault("QuestTextContrast") > 0;
end

function QuestUtil.QuestTextContrastUseLightText()
	return QuestUtil.ShouldQuestTextContrastSettingUseLightText(GetCVarNumberOrDefault("QuestTextContrast"));
end

function QuestUtil.ShouldQuestTextContrastSettingUseLightText(questTextContrastSetting)
	--Use light text when the background is dark
	return  questTextContrastSetting == 4;
end

function QuestUtil.GetDefaultQuestBackgroundTexture()
	return QuestUtil.GetQuestBackgroundAtlas(GetCVarNumberOrDefault("QuestTextContrast"));
end

function QuestUtil.GetQuestBackgroundAtlas(questTextContrastSetting)
	if questTextContrastSetting == 0 then
		return "QuestBG-Parchment";
	elseif questTextContrastSetting == 1 then
		return "QuestBG-Parchment-Accessibility";
	elseif questTextContrastSetting == 2 then
		return "QuestBG-Parchment-Accessibility2";
	elseif questTextContrastSetting == 3 then
		return "QuestBG-Parchment-Accessibility3";
	elseif questTextContrastSetting == 4 then
		return "QuestBG-Parchment-Accessibility4";
	end
end

function QuestUtil.GetDefaultQuestMapBackgroundTexture()
	local questAccesibilityBackground = GetCVarNumberOrDefault("QuestTextContrast");
	if questAccesibilityBackground == 0 then
		return "QuestDetailsBackgrounds";
	elseif questAccesibilityBackground == 1 then
		return "QuestDetailsBackgrounds-Accessibility";
	elseif questAccesibilityBackground == 2 then
		return "QuestDetailsBackgrounds-Accessibility_Light";
	elseif questAccesibilityBackground == 3 then
		return "QuestDetailsBackgrounds-Accessibility_Medium";
	elseif questAccesibilityBackground == 4 then
		return "QuestDetailsBackgrounds-Accessibility_Dark";
	end
end

function QuestUtil.IsShowingQuestDetails(questID)
	return QuestLogPopupDetailFrame_IsShowingQuest(questID);
end

function QuestUtil.OpenQuestDetails(questID)
	QuestLogPopupDetailFrame_Show(questID);
end

function QuestUtil.ShareQuest(questID)
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
	QuestLogPushQuest(questLogIndex);
end

function QuestUtil.GetThreatPOIIcon(questID)
	local theme = C_QuestLog.GetQuestDetailsTheme(questID);
	return theme and theme.poiIcon or "worldquest-icon-nzoth";
end

function QuestUtil.QuestShowsItemByIndex(questLogIndex, isQuestComplete)
	if not questLogIndex then
		return false;
	end
	local _, item, _, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex);
	return item and (not isQuestComplete or showItemWhenComplete);
end

local g_createQuestGroupCache;
function QuestUtil.CanCreateQuestGroup(questID)
	-- Cache this off to avoid spurious calls to C_LFGList.CanCreateQuestGroup, for a given quest the result will not change until
	-- completed.
	if not g_createQuestGroupCache then
		g_createQuestGroupCache = { };
	end
	local canCreate = g_createQuestGroupCache[questID];
	if canCreate == nil then
		canCreate = C_LFGList.CanCreateQuestGroup(questID);
		g_createQuestGroupCache[questID] = canCreate;
	end
	return canCreate;
end

local lastTrackedQuestID = nil;
function QuestUtil.TrackWorldQuest(questID, watchType)
	if C_QuestLog.AddWorldQuestWatch(questID, watchType) then
		if lastTrackedQuestID and lastTrackedQuestID ~= questID then
			if C_QuestLog.GetQuestWatchType(lastTrackedQuestID) ~= Enum.QuestWatchType.Manual and watchType == Enum.QuestWatchType.Manual then
				C_QuestLog.AddWorldQuestWatch(lastTrackedQuestID, Enum.QuestWatchType.Manual); -- Promote to manual watch
			end
		end
		lastTrackedQuestID = questID;
	end

	if watchType == Enum.QuestWatchType.Automatic then
		local forceAllowTasks = true;
		QuestUtil.CheckAutoSuperTrackQuest(questID, forceAllowTasks);
	end
end

function QuestUtil.UntrackWorldQuest(questID)
	if C_QuestLog.RemoveWorldQuestWatch(questID) then
		if lastTrackedQuestID == questID then
			lastTrackedQuestID = nil;
		end
	end
	ObjectiveTrackerManager:UpdateAll();
end

function QuestUtil.IsQuestTrackableTask(questID)
	return C_QuestLog.IsQuestTask(questID) and not C_QuestLog.IsQuestBounty(questID);
end

function QuestUtil.AllowAutoSuperTrackQuest(questID, forceAllowTasks)
	if not C_SuperTrack.IsSuperTrackingAnything() then
		if not forceAllowTasks then
		 	return not QuestUtils_IsQuestWorldQuest(questID) and not QuestUtils_IsQuestBonusObjective(questID);
		end

		return true;
	end

	return false;
end

function QuestUtil.CheckAutoSuperTrackQuest(questID, forceAllowTasks)
	if QuestUtil.AllowAutoSuperTrackQuest(questID, forceAllowTasks) then
		C_SuperTrack.SetSuperTrackedQuestID(questID);
	end
end

QuestTimeRemainingFormatter = CreateFromMixins(SecondsFormatterMixin);
QuestTimeRemainingFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.OneLetter, false);

function QuestTimeRemainingFormatter:GetDesiredUnitCount(seconds)
	return seconds > SECONDS_PER_DAY and 2 or 1;
end

function QuestTimeRemainingFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Minutes;
end

QuestTimeRemainingFormatter:SetStripIntervalWhitespace(true);

local g_classificationInfoTable = {
	[Enum.QuestClassification.Campaign] =	{ text = QUEST_CLASSIFICATION_CAMPAIGN, atlas = "CampaignAvailableQuestIcon", size = 16 },
	[Enum.QuestClassification.Calling] =	{ text = QUEST_CLASSIFICATION_CALLING, atlas = "CampaignAvailableDailyQuestIcon", size = 16 },
	[Enum.QuestClassification.Important] =	{ text = QUEST_CLASSIFICATION_IMPORTANT, atlas = "importantavailablequesticon", size = 16 },
	[Enum.QuestClassification.Legendary] =	{ text = QUEST_CLASSIFICATION_LEGENDARY, atlas = "legendaryavailablequesticon", size = 16 },
	[Enum.QuestClassification.Meta] =		{ text = QUEST_CLASSIFICATION_META, atlas = "Wrapperavailablequesticon", size = 16 },
	[Enum.QuestClassification.Recurring] =	{ text = QUEST_CLASSIFICATION_RECURRING, atlas = "Recurringavailablequesticon", size = 16 },
	[Enum.QuestClassification.Questline] =	{ text = QUEST_CLASSIFICATION_QUESTLINE, atlas = "questlog-storylineicon", size = 20 },
};

function QuestUtil.GetQuestClassificationInfo(classification)
	return g_classificationInfoTable[classification];
end

-- return classification, text, atlas, size
function QuestUtil.GetQuestClassificationDetails(questID, skipFormatting)
	local classification = C_QuestInfoSystem.GetQuestClassification(questID);
	local info = QuestUtil.GetQuestClassificationInfo(classification);
	if not info then
		return nil, nil, nil, nil;
	end

	local text = info.text;
	if not skipFormatting then
		if classification == Enum.QuestClassification.Questline then
			local mapID = nil;
			local displayableOnly = true;
			local questLineInfo = C_QuestLine.GetQuestLineInfo(questID, mapID, displayableOnly);
			if questLineInfo then
				text = QUEST_CLASSIFICATION_QUESTLINE_WITH_NAME:format(questLineInfo.questLineName);
			end
		elseif classification == Enum.QuestClassification.Recurring then
			local timeLeft = C_TaskQuest.GetQuestTimeLeftSeconds(questID);
			if timeLeft then
				local timeString = QuestTimeRemainingFormatter:Format(timeLeft);
				text = QUEST_CLASSIFICATION_RECURRING_WITH_TIME:format(timeString);
			end
		end
	end

	return classification, text, info.atlas, info.size;
end

function QuestUtil.GetQuestClassificationString(questID)
	local classification, text, atlas, size = QuestUtil.GetQuestClassificationDetails(questID);
	if classification then
		return CreateAtlasMarkup(atlas, size, size).." "..text;
	end

	return nil;	
end

-- return tagID, text, atlas
function QuestUtil.GetQuestTypeDetails(questID)
	local info = C_QuestLog.GetQuestTagInfo(questID);
	if info then
		return info.tagID, info.tagName, QUEST_TAG_ATLAS[info.tagID];
	end

	return nil, nil, nil;
end

local QUEST_LEGEND_SEPARATOR = "    ";

local function GetCombinedQuestLegendText(legendStrings, isMultiLine)
	if not legendStrings or #legendStrings <= 0 then
		return;
	end

	if #legendStrings == 1 then
		return legendStrings[1];
	end

	local combinedText;
	for index, string in ipairs(legendStrings) do
		if isMultiLine then
			combinedText = combinedText and (combinedText.."|n"..string) or string;
		else
			combinedText = combinedText and (combinedText..QUEST_LEGEND_SEPARATOR..string) or string;
		end
	end

	return combinedText;
end

function QuestUtil.GetAccountQuestText(questID)
	if not C_QuestLog.IsAccountQuest(questID) then
		return nil;
	end

	local accountWideIcon = CreateAtlasMarkup("questlog-questtypeicon-account", 18, 18);
	local accountQuestString = accountWideIcon .. " " .. ACCOUNT_QUEST_LABEL;

	local factionGroup = GetQuestFactionGroup(questID);
	-- Faction-specific account quests also include the faction icon
	if factionGroup then
		local isHorde = factionGroup == LE_QUEST_FACTION_HORDE;
		local factionString = isHorde and FACTION_HORDE or FACTION_ALLIANCE;
		local factionIcon = CreateAtlasMarkup(isHorde and "questlog-questtypeicon-horde" or "questlog-questtypeicon-alliance", 18, 18);
		accountQuestString = accountQuestString .. QUEST_LEGEND_SEPARATOR .. factionIcon .. " " .. factionString;
	end

	return accountQuestString;
end

function QuestUtil.GetQuestLegendStrings(questID)
	local legendStrings = {};
	-- Is it a campaign quest, or part of a questline, etc.
	local classificationText = QuestUtil.GetQuestClassificationString(questID);
	if classificationText then
		table.insert(legendStrings, classificationText);
	end

	-- Is it a dungeon quest, or a raid quest, etc.
	local questTypeText = QuestUtils_GetQuestTypeIconMarkupString(questID);
	if questTypeText then
		table.insert(legendStrings, questTypeText);
	end

	-- Is it an account wide quest, and does it require a specific faction?
	local accountQuestText = QuestUtil.GetAccountQuestText(questID);
	if accountQuestText then
		table.insert(legendStrings, accountQuestText);
	end

	if #legendStrings > 0 then
		return legendStrings;
	end
end

function QuestUtil.SetQuestLegendToFontString(questID, fontString)
	local legendStrings = QuestUtil.GetQuestLegendStrings(questID);
	local legendText = GetCombinedQuestLegendText(legendStrings);
	if not legendText then
		return false;
	end

	fontString:SetText(legendText);
	if legendText and fontString:GetNumLines() > 1 then
		local isMultiLine = true;
		fontString:SetText(GetCombinedQuestLegendText(legendStrings, isMultiLine));
	end
	return true;
end

function QuestUtil.SetQuestLegendToTooltip(questID, tooltip)
	local classificationText = QuestUtil.GetQuestClassificationString(questID);
	local questTypeText = QuestUtils_GetQuestTypeIconMarkupString(questID);
	local accountQuestText = QuestUtil.GetAccountQuestText(questID);
	if not classificationText and not questTypeText and not accountQuestText then
		return false;
	end

	-- storyline gets a line by itself
	if classificationText then
		local classification = C_QuestInfoSystem.GetQuestClassification(questID);
		if classification == Enum.QuestClassification.Questline then
			GameTooltip_AddNormalLine(tooltip, classificationText);
			-- clear this out, already used
			classificationText = nil;
		end
	end

	local stringsToCombine = {};
	if classificationText then
		table.insert(stringsToCombine, classificationText);
	end

	if questTypeText then
		table.insert(stringsToCombine, questTypeText);
	end

	local legendText = GetCombinedQuestLegendText(stringsToCombine);
	GameTooltip_AddNormalLine(tooltip, legendText);

	-- The account quest text also gets a line by itself becaues it can contain both an "Account" tag and a "Faction" tag
	if accountQuestText then
		GameTooltip_AddNormalLine(tooltip, accountQuestText);
	end

	return true;
end

function QuestUtils_GetQuestTagAtlas(tagID, worldQuestType)
	if IsQuestWorldQuest_Internal(worldQuestType) then
		return WORLD_QUEST_TYPE_ATLAS[worldQuestType];
	end

	return tagID and QUEST_TAG_ATLAS[tagID];
end

function QuestUtils_IsQuestWorldQuest(questID)
	return C_QuestLog.IsWorldQuest(questID);
end

function QuestUtils_IsQuestDungeonQuest(questID)
	local info = C_QuestLog.GetQuestTagInfo(questID);
	return info and IsQuestDungeonQuest_Internal(info.tagID, info.worldQuestType);
end

function QuestUtils_IsQuestBonusObjective(questID)
	return C_QuestLog.IsQuestTask(questID) and not QuestUtils_IsQuestWorldQuest(questID);
end

function QuestUtils_GetQuestTypeIconMarkupString(questID, iconWidth, iconHeight)
	local info = C_QuestLog.GetQuestTagInfo(questID);
	if info then
		return GetQuestTypeIconMarkupStringFromTagData(info.tagID, info.worldQuestType, info.tagName, iconWidth, iconHeight);
	end
end

function QuestUtils_AddQuestTypeToTooltip(tooltip, questID, color, iconWidth, iconHeight)
	local info = C_QuestLog.GetQuestTagInfo(questID);

	-- NOTE: See above, for now only add dungeons quests to quest tooltips.  Can add a set of filters or a predicate to evaluate
	-- whether or not we want to add this in the future.
	if info and IsQuestDungeonQuest_Internal(info.tagID, info.worldQuestType) then
		AddQuestTagTooltipLine(tooltip, info.tagID, info.worldQuestType, info.tagName, iconWidth, iconHeight, color);
	end
end

function QuestUtils_AddQuestTagLineToTooltip(tooltip, tagName, tagID, worldQuestType, color, iconWidth, iconHeight)
	-- NOTE: This doesn't filter anything, we already arrived at all the data at the callsite and evaluated whether
	-- or not this should have been added.
	AddQuestTagTooltipLine(tooltip, tagID, worldQuestType, tagName, iconWidth, iconHeight, color);
end

function QuestUtils_GetQuestName(questID)
	-- TODO: Make unified API for this?
	return C_TaskQuest.GetQuestInfoByQuestID(questID) or C_QuestLog.GetTitleForQuestID(questID) or "";
end

local function ShouldShowWarModeBonus(questID, currencyID, firstInstance)
	if not C_PvP.IsWarModeDesired() then
		return false;
	end

	local warModeBonusApplies, limitOncePerTooltip = C_CurrencyInfo.DoesWarModeBonusApply(currencyID);
	if not warModeBonusApplies or (limitOncePerTooltip and not firstInstance) then
		return false;
	end

	return QuestUtils_IsQuestWorldQuest(questID) and C_QuestLog.QuestCanHaveWarModeBonus(questID) and not C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID);
end

function QuestUtils_GetQuestDecorationLink(linkType, questID, icon, width, height)
	return ("|H%s:%d|h%s|h"):format(linkType, questID, CreateAtlasMarkup(icon, width, height));
end

function QuestUtils_GetReplayQuestDecoration(questID, useLargeIcon)
	local linkType = "questReplay";

	if useLargeIcon then
		return QuestUtils_GetQuestDecorationLink(linkType, questID, "QuestSharing-ReplayIcon", 18, 16);
	else
		return QuestUtils_GetQuestDecorationLink(linkType, questID, "QuestSharing-QuestLog-Replay", 19, 16);
	end
end

function QuestUtils_GetDisabledQuestDecoration(questID, useLargeIcon)
	local linkType = "questDisabled";
	if useLargeIcon then
		return QuestUtils_GetQuestDecorationLink(linkType, questID, "QuestSharing-QuestDetails-Padlock", 10, 10);
	else
		return QuestUtils_GetQuestDecorationLink(linkType, questID, "QuestSharing-QuestDetails-Padlock", 20, 20);
	end
end

-- TODO: Replace booleans with flags?
function QuestUtils_DecorateQuestText(questID, text, useLargeIcon, ignoreReplayable, ignoreDisabled, ignoreTypes)
	if not text then
		return "";
	end

	local output = "";
	if not ignoreReplayable and C_QuestLog.IsQuestReplayable(questID) then
		output = QuestUtils_GetReplayQuestDecoration(questID, useLargeIcon);
	elseif not ignoreDisabled and C_QuestLog.IsQuestDisabledForSession(questID) then
		output = QuestUtils_GetDisabledQuestDecoration(questID, useLargeIcon);
	end

	if not ignoreTypes then
		local textureSize = 14;
		local tagID, tagText, tagAtlas = QuestUtil.GetQuestTypeDetails(questID);
		if tagID == Enum.QuestTag.Dungeon or tagID == Enum.QuestTag.Raid or tagID == Enum.QuestTag.Raid10 or tagID == Enum.QuestTag.Raid25 then
			local link = QuestUtils_GetQuestDecorationLink(tagText, questID, tagAtlas, textureSize, textureSize);
			output = output .. link.. " ";
		else
			local skipFormatting = true;
			local classification, classificationText, classificationAtlas, _size = QuestUtil.GetQuestClassificationDetails(questID, skipFormatting);
			if classification and classification ~= Enum.QuestClassification.Normal then
				if classification == Enum.QuestClassification.Campaign then
					-- deembiggen campaign atlas
					textureSize = 11;
				end
				local link = QuestUtils_GetQuestDecorationLink(classificationText, questID, classificationAtlas, textureSize, textureSize);
				output = output .. link.. " ";
			end
		end
	end

	return output .. text;
end

function QuestUtils_AddQuestRewardsToTooltip(tooltip, questID, style)
	local hasAnySingleLineRewards = false;
	local isWarModeDesired = C_PvP.IsWarModeDesired();
	local questHasWarModeBonus = C_QuestLog.QuestCanHaveWarModeBonus(questID);

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
	local mainRewardIsFirstTimeReputationBonus = false;
	local secondaryRewardsContainFirstTimeRepBonus = false;
	if not style.atLeastShowAzerite then
		local numAddedQuestCurrencies, usingCurrencyContainer, primaryCurrencyRewardInfo = QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip, tooltip.ItemTooltip);
		if ( numAddedQuestCurrencies > 0 ) then
			hasAnySingleLineRewards = not usingCurrencyContainer or numAddedQuestCurrencies > 1;
		end

		if primaryCurrencyRewardInfo then
			local isFirstTimeReward = primaryCurrencyRewardInfo.questRewardContextFlags and FlagsUtil.IsSet(primaryCurrencyRewardInfo.questRewardContextFlags, Enum.QuestRewardContextFlags.FirstCompletionBonus);
			mainRewardIsFirstTimeReputationBonus = isFirstTimeReward and (C_CurrencyInfo.GetFactionGrantedByCurrency(primaryCurrencyRewardInfo.currencyID) ~= nil) or false;
		elseif C_QuestLog.QuestContainsFirstTimeRepBonusForPlayer(questID) then
			secondaryRewardsContainFirstTimeRepBonus = true;
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
	if numQuestRewards > 0 and (not style.prioritizeCurrencyOverItem or C_QuestInfoSystem.HasQuestRewardCurrencies(questID)) then
		if style.fullItemDescription then
			-- we want to do a full item description
			local itemIndex, rewardType = QuestUtils_GetBestQualityItemRewardIndex(questID);  -- Only support one item reward currently
			if not EmbeddedItemTooltip_SetItemByQuestReward(tooltip.ItemTooltip, itemIndex, questID, rewardType, style.showCollectionText) then
				showRetrievingData = true;
			end
			-- check for item compare input of flag
			if not showRetrievingData then
				if TooltipUtil.ShouldDoItemComparison() then
					GameTooltip_ShowCompareItem(tooltip.ItemTooltip.Tooltip, tooltip.BackdropFrame);
				else
					for i, shoppingTooltip in ipairs(tooltip.ItemTooltip.Tooltip.shoppingTooltips) do
						shoppingTooltip:Hide();
					end
				end
			end
		else
			-- we want to do an abbreviated item description
			local name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo(1, questID);
			local text;
			if numItems > 1 then
				text = string.format(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, texture, HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(numItems), name);
			elseif texture and name then
				text = string.format(BONUS_OBJECTIVE_REWARD_FORMAT, texture, name);
			end
			if text then
				local color = ITEM_QUALITY_COLORS[quality];
				tooltip:AddLine(text, color.r, color.g, color.b);
			end
		end
	end

	-- spells
	if not tooltip.ItemTooltip:IsShown() and EmbeddedItemTooltip_SetSpellByFirstQuestReward(tooltip.ItemTooltip, questID) then
		showRetrievingData = true;
	end

	-- atLeastShowAzerite: show azerite if nothing else is awarded
	-- and in the case of double azerite, only show the currency container one
	if style.atLeastShowAzerite and not hasAnySingleLineRewards and not tooltip.ItemTooltip:IsShown() then
		local numAddedQuestCurrencies, usingCurrencyContainer = QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip, tooltip.ItemTooltip);
		if ( numAddedQuestCurrencies > 0 ) then
			hasAnySingleLineRewards = not usingCurrencyContainer or numAddedQuestCurrencies > 1;
			if usingCurrencyContainer and numAddedQuestCurrencies > 1 then
				EmbeddedItemTooltip_Clear(tooltip.ItemTooltip);
				EmbeddedItemTooltip_Hide(tooltip.ItemTooltip);
				tooltip:Show();
			end
		end
	end

	if style.showFirstTimeRepRewardNotice and (mainRewardIsFirstTimeReputationBonus or secondaryRewardsContainFirstTimeRepBonus) then
		local bestTooltipForLine = tooltip.ItemTooltip:IsShown() and tooltip.ItemTooltip.Tooltip or tooltip;
		GameTooltip_AddBlankLineToTooltip(bestTooltipForLine);

		local wrapText = false;
		local noticeText = mainRewardIsFirstTimeReputationBonus and QUEST_REWARDS_IS_ONE_TIME_REP_BONUS or QUEST_REWARDS_CONTAINS_ONE_TIME_REP_BONUS;
		GameTooltip_AddColoredLine(bestTooltipForLine, noticeText, QUEST_REWARD_CONTEXT_FONT_COLOR, wrapText);

		if bestTooltipForLine == tooltip.ItemTooltip.Tooltip then
			tooltip.ItemTooltip.Tooltip:Show();
		end
	end

	return hasAnySingleLineRewards, showRetrievingData;
end

--currencyContainerTooltip should be an InternalEmbeddedItemTooltipTemplate
function QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip, currencyContainerTooltip)
	local currencies = { };
	local uniqueCurrencyIDs = { };
	local currencyRewards = C_QuestLog.GetQuestRewardCurrencies(questID);
	for index, currencyReward in ipairs(currencyRewards) do
		local rarity = C_CurrencyInfo.GetCurrencyInfo(currencyReward.currencyID).quality;
		local firstInstance = not uniqueCurrencyIDs[currencyReward.currencyID];
		if firstInstance then
			uniqueCurrencyIDs[currencyReward.currencyID] = true;
		end
		local currencyInfo = { name = currencyReward.name,
							   texture = currencyReward.texture,
							   numItems = currencyReward.totalRewardAmount,
							   currencyID = currencyReward.currencyID,
							   questRewardContextFlags = currencyReward.questRewardContextFlags,
							   rarity = rarity,
							   firstInstance = firstInstance,
							};
		if(currencyInfo.currencyID ~= ECHOS_OF_NYLOTHA_CURRENCY_ID or #currencyRewards == 1) then
			tinsert(currencies, currencyInfo);
		end
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
	local alreadyUsedCurrencyContainerInfo = nil;  --In the case of multiple currency containers needing to displayed, we only display the first.
	local warModeBonus = C_PvP.GetWarModeRewardBonus();

	for i, currencyInfo in ipairs(currencies) do
		local isCurrencyContainer = C_CurrencyInfo.IsCurrencyContainer(currencyInfo.currencyID, currencyInfo.numItems);
		if ( currencyContainerTooltip and isCurrencyContainer and (alreadyUsedCurrencyContainerId == 0) ) then
			if ( EmbeddedItemTooltip_SetCurrencyByID(currencyContainerTooltip, currencyInfo.currencyID, currencyInfo.numItems) ) then
				if ShouldShowWarModeBonus(questID, currencyInfo.currencyID, currencyInfo.firstInstance) then
					currencyContainerTooltip.Tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_FORMAT:format(warModeBonus));
					currencyContainerTooltip.Tooltip:Show();
				end

				if ( not tooltip ) then
					break;
				end

				addedQuestCurrencies = addedQuestCurrencies + 1;
				alreadyUsedCurrencyContainerId = currencyInfo.currencyID;
				alreadyUsedCurrencyContainerInfo = currencyInfo;
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

				if ShouldShowWarModeBonus(questID, currencyInfo.currencyID, currencyInfo.firstInstance) then
					tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_FORMAT:format(warModeBonus));
				end

				addedQuestCurrencies = addedQuestCurrencies + 1;
			end
		end
	end
	return addedQuestCurrencies, alreadyUsedCurrencyContainerId > 0, alreadyUsedCurrencyContainerInfo;
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

function QuestUtils_GetQuestLogRewardInfo(itemIndex, questID, rewardType)
	if rewardType == "choice" then
		return GetQuestLogChoiceInfo(itemIndex, questID);
	else
		return GetQuestLogRewardInfo(itemIndex, questID);
	end
end

function QuestUtils_GetBestQualityItemRewardIndex(questID)
	local index, rewardType;
	local bestQuality = -1;
	local numQuestRewards = GetNumQuestLogRewards(questID);
	for i = 1, numQuestRewards do
		local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(i, questID);
		if quality > bestQuality then
			index = i;
			bestQuality = quality;
			rewardType = "reward";
		end
	end
	local numQuestChoices = GetNumQuestLogChoices(questID);
	for i = 1, numQuestChoices do
		local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogChoiceInfo(i, questID);
		if quality > bestQuality then
			index = i;
			bestQuality = quality;
			rewardType = "choice";
		end
	end
	return index, rewardType;
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
	local info = C_QuestLog.GetQuestTagInfo(questID);
	return not info or info.displayExpiration;
end

function QuestUtils_GetNumPartyMembersOnQuest(questID)
	local count = 0;
	for i = 1, GetNumSubgroupMembers() do
		if C_QuestLog.IsUnitOnQuest("party"..i, questID) then
			count = count + 1;
		end
	end

	return count;
end

function QuestUtils_IsQuestWatched(questID)
	return questID and C_QuestLog.GetQuestWatchType(questID) ~= nil;
end

function QuestUtil.IsFrequencyRecurring(frequency)
	return frequency == Enum.QuestFrequency.Daily or frequency == Enum.QuestFrequency.Weekly or frequency == Enum.QuestFrequency.ResetByScheduler;
end

-- This determines the alpha of quest icons when a quest giver has a list of available quests
function QuestUtil.GetAvailableQuestIconAlpha(questID)
	local questIgnoresAccountCompletedFilter = C_QuestLog.QuestIgnoresAccountCompletedFiltering(questID);
	-- We're making an assumption here:
	-- If you're talking to an NPC with an available quest, then the map you're currently on is the correct map for the quest line (if the quest has one)
	local uiMapID = C_Map.GetBestMapForUnit("player");
	local questLineInfo = C_QuestLine.GetQuestLineInfo(questID, uiMapID);
	local questLineIgnoresAccountCompletedFilter = (questLineInfo and uiMapID) and C_QuestLine.QuestLineIgnoresAccountCompletedFiltering(uiMapID, questLineInfo.questLineID) or false;
	local isQuestAccountFiltered = not C_Minimap.IsTrackingAccountCompletedQuests() and not questIgnoresAccountCompletedFilter and not questLineIgnoresAccountCompletedFilter;
	if C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID) and isQuestAccountFiltered then
		return 0.5;
	end

	return 1.0;
end