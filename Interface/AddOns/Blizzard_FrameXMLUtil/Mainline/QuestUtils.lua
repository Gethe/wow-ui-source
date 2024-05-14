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

function QuestUtil.GetWorldQuestAtlasInfo(worldQuestType, inProgress, tradeskillLineID, questID)
	local iconAtlas, width, height;

	if inProgress then
		iconAtlas, width, height = "worldquest-questmarker-questionmark", 10, 15;
	elseif worldQuestType == Enum.QuestTagType.PvP then
		iconAtlas =  "worldquest-icon-pvp-ffa";
	elseif worldQuestType == Enum.QuestTagType.PetBattle then
		iconAtlas =  "worldquest-icon-petbattle";
	elseif worldQuestType == Enum.QuestTagType.Profession and WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID] then
		iconAtlas =  WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID];
	elseif worldQuestType == Enum.QuestTagType.Dungeon then
		iconAtlas =  "worldquest-icon-dungeon";
	elseif worldQuestType == Enum.QuestTagType.Raid then
		iconAtlas =  "worldquest-icon-raid";
	elseif worldQuestType == Enum.QuestTagType.Invasion then
		iconAtlas =  "worldquest-icon-burninglegion";
	elseif worldQuestType == Enum.QuestTagType.Islands then
		iconAtlas ="poi-islands-table";
	elseif worldQuestType == Enum.QuestTagType.FactionAssault then
		local factionTag = UnitFactionGroup("player");
		if factionTag == "Alliance" then
			iconAtlas = "worldquest-icon-alliance";
		else -- "Horde" or "Neutral"
			iconAtlas = "worldquest-icon-horde";
		end
	elseif worldQuestType == Enum.QuestTagType.Threat then
		iconAtlas = QuestUtil.GetThreatPOIIcon(questID);
	elseif worldQuestType == Enum.QuestTagType.DragonRiderRacing then
		iconAtlas = "worldquest-icon-race";
	else
		if questID then
			local theme = C_QuestLog.GetQuestDetailsTheme(questID);
			if theme then
				iconAtlas = theme.poiIcon;
			end
		end
	end

	if iconAtlas then
		local info = C_Texture.GetAtlasInfo(iconAtlas);
		if info then
			return iconAtlas, width or info.width, height or info.height;
		end
	end

	return "worldquest-questmarker-questbang", 6, 15;
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

function QuestUtil.OpenQuestDetails(questID)
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
	QuestLogPopupDetailFrame_Show(questLogIndex);
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

	-- NOTE: For now, only allow dungeon quests to get markup
	if info and IsQuestDungeonQuest_Internal(info.tagID, info.worldQuestType) then
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
function QuestUtils_DecorateQuestText(questID, text, useLargeIcon, ignoreReplayable, ignoreDisabled)
	if not ignoreReplayable and C_QuestLog.IsQuestReplayable(questID) then
		return QuestUtils_GetReplayQuestDecoration(questID, useLargeIcon) .. text;
	elseif not ignoreDisabled and C_QuestLog.IsQuestDisabledForSession(questID) then
		return QuestUtils_GetDisabledQuestDecoration(questID, useLargeIcon) .. text;
	end

	return text;
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
	return hasAnySingleLineRewards, showRetrievingData;
end

--currencyContainerTooltip should be an InternalEmbeddedItemTooltipTemplate
function QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip, currencyContainerTooltip)
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
	local currencies = { };
	local uniqueCurrencyIDs = { };
	for i = 1, numQuestCurrencies do
		local name, texture, numItems, currencyID = GetQuestLogRewardCurrencyInfo(i, questID);
		local rarity = C_CurrencyInfo.GetCurrencyInfo(currencyID).quality;
		local firstInstance = not uniqueCurrencyIDs[currencyID];
		if firstInstance then
			uniqueCurrencyIDs[currencyID] = true;
		end
		local currencyInfo = { name = name, texture = texture, numItems = numItems, currencyID = currencyID, rarity = rarity, firstInstance = firstInstance };
		if(currencyID ~= ECHOS_OF_NYLOTHA_CURRENCY_ID or numQuestCurrencies == 1) then
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

QuestSortType = EnumUtil.MakeEnum( "Normal", "Campaign", "Calling", "Legendary", "Threat", "BonusObjective", "WorldQuest", "Important", "Daily", "Meta" );

function QuestUtils_GetQuestSortType(questInfo)
	if questInfo.isCalling then
		return QuestSortType.Calling;
	elseif questInfo.isLegendarySort then
		return QuestSortType.Legendary;
	elseif questInfo.campaignID and questInfo.campaignID > 0 then
		if not C_CampaignInfo.SortAsNormalQuest(questInfo.campaignID) then
			return QuestSortType.Campaign;
		end
	end

	return QuestSortType.Normal;
end

-- This should be unified with QuestUtils_GetQuestSortType, or completely implemented in the C++ API 
function QuestUtils_GetTaskSortType(taskInfo)
	local questID = taskInfo.questID or taskInfo.questId;

	if C_QuestLog.IsWorldQuest(questID) then
		return QuestSortType.WorldQuest;
	elseif C_QuestLog.IsThreatQuest(questID) then
		return QuestSortType.Threat;
	elseif C_QuestLog.IsQuestCalling(questID) then
		return QuestSortType.Calling;
	elseif C_QuestLog.IsImportantQuest(questID) then
		return QuestSortType.Important;
	elseif QuestUtil.ShouldQuestIconsUseCampaignAppearance(questID) then
		return QuestSortType.Campaign; -- NOTE: This is different than the logic above which is only used to display quests in the log, should be unified somehow.
	elseif taskInfo.isDaily then
		return QuestSortType.Daily;
	elseif taskInfo.isMeta then
		return QuestSortType.Meta;
	elseif taskInfo.isQuestStart then
		return QuestSortType.Normal;
	end

	return QuestSortType.BonusObjective;
end

function QuestUtil.IsFrequencyRecurring(frequency)
	return frequency == Enum.QuestFrequency.Daily or frequency == Enum.QuestFrequency.Weekly;
end