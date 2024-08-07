local questOfferPinData =
{
	[Enum.QuestClassification.Normal] = 	{ level = 1, atlas = "QuestNormal", },
	[Enum.QuestClassification.Questline] = 	{ level = 1, atlas = "QuestNormal", },
	[Enum.QuestClassification.Recurring] =	{ level = 2, atlas = "UI-QuestPoiRecurring-QuestBang", },
	[Enum.QuestClassification.Meta] = 		{ level = 3, atlas = "quest-wrapper-available", },
	[Enum.QuestClassification.Calling] = 	{ level = 4, atlas = "Quest-DailyCampaign-Available", },
	[Enum.QuestClassification.Campaign] = 	{ level = 5, atlas = "Quest-Campaign-Available", },
	[Enum.QuestClassification.Legendary] =	{ level = 6, atlas = "UI-QuestPoiLegendary-QuestBang", },
	[Enum.QuestClassification.Important] =	{ level = 7, atlas = "importantavailablequesticon", },
};

local function GetMaxPinLevel()
	local maxPinLevel = 0;
	for _, info in pairs(questOfferPinData) do
		maxPinLevel = math.max(maxPinLevel, info.level);
	end

	return maxPinLevel;
end

QuestOfferDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin, { PIN_LEVEL_RANGE = GetMaxPinLevel(), });

function QuestOfferDataProviderMixin:BuildPinSubTypeData(pinSubType, info)
	return { pinSubType = pinSubType, info = info };
end

function QuestOfferDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("QuestOfferPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("QuestHubPinTemplate");
	self:ResetQuestLines();
	self:ResetQuestHubs();
	self:ResetSuppressor();
end

function QuestOfferDataProviderMixin:ResetQuestLines()
	self.questLines = nil;
end

function QuestOfferDataProviderMixin:ResetQuestHubs()
	self.questHubs = nil;
end

function QuestOfferDataProviderMixin:ResetSuppressor()
	self.pinSuppressor = nil;
end

function QuestOfferDataProviderMixin:GetQuestOffers()
	return GetOrCreateTableEntry(self, "questLines");
end

function QuestOfferDataProviderMixin:GetQuestHubs()
	return GetOrCreateTableEntry(self, "questHubs");
end

function QuestOfferDataProviderMixin:IsQuestOfferAccountIgnored(questOffer)
	if not questOffer.isAccountCompleted then
		return false; -- This offer hasn't been account completed yet, not ignored
	end

	if C_Minimap.IsTrackingAccountCompletedQuests() then
		return false; -- The user wants to see account completed quests, not ignored.
	end

	if questOffer.questLineID then
		if C_QuestLine.QuestLineIgnoresAccountCompletedFiltering(self:GetMap():GetMapID(), questOffer.questLineID) then
			return false; -- This quest line overrides any cvar settings, not ignored
		end
	end

	if C_QuestLog.QuestIgnoresAccountCompletedFiltering(questOffer.questID) then
		return false; -- This quest overrides any cvar settings, not ignored.
	end

	return true;
end

function QuestOfferDataProviderMixin:ShouldAddQuestOffer(questOffer)
	if not questOffer then
		return false;
	end

	if questOffer.inProgress then
		return false;
	end

	if questOffer.isHidden and not C_Minimap.IsTrackingHiddenQuests() then
		return false;
	end

	if questOffer.isLocalStory and not self:ShouldShowLocalStories() then
		return false;
	end

	if self:IsQuestOfferAccountIgnored(questOffer) then
		return false;
	end

	return true;
end

function QuestOfferDataProviderMixin:CheckAddQuestOffer(questOffer)
	if self:ShouldAddQuestOffer(questOffer) then
		questOffer.dataProvider = self;
		self:GetQuestOffers()[questOffer.questID] = questOffer;
	end
end

local function InitializeCommonQuestOfferData(info)
	if info then
		local questID = info.questID or info.questId;
		local questClassification = C_QuestInfoSystem.GetQuestClassification(questID);
		local pinData = questOfferPinData[questClassification];
		if pinData then
			info.questID = questID;
			info.questClassification = questClassification;
			info.pinLevel = pinData.level;
			info.questIcon = pinData.atlas;
			info.pinAlpha = info.isHidden and 0.5 or 1; -- TODO: Trivial quests need special icons, but kee the same atlas as normal.
			return info;
		end
	end
end

-- Because of the number of different data sources that exist, convert them all to a common data format for pin setup.
-- This API could move, but the key is being able to get all the information distilled into a homogenous source.
-- Because QuestLineInfo was how this API existed in the first place and tasks are newly integrated, use QuestLineInfo as a starting point
local function CreateQuestOfferFromQuestLineInfo(mapID, info)
	if InitializeCommonQuestOfferData(info) then
		-- These are fields that are not present on questLineInfo that are present on taskInfo
		-- They're just called out to maintain parity for the most part
		info.isQuestStart = true;
		info.numObjectives = 0;
		info.mapID = mapID;
		info.childDepth = nil; -- Called out to maintain
		return info;
	end
end

local function CreateQuestOfferFromTaskInfo(mapID, info)
	if InitializeCommonQuestOfferData(info) then
		-- These are fields that are not present on taskInfo that are present on questLineInfo
		-- Also called out to maintain parity.
		info.questID = info.questId; -- Named differently, don't want to go update all the places that this old name exists yet.
		info.questLineName = nil;

		local title, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(info.questID);
		info.questName = title;
		info.questLineID = nil;
		info.isHidden = C_QuestLog.IsQuestTrivial(info.questID);
		info.isLegendary = C_QuestLog.IsLegendaryQuest(info.questID);
		info.isCampaign = false; -- This cannot be a campaign for a task, it would be in a quest line
		info.isImportant = C_QuestLog.IsImportantQuest(info.questID);
		info.isAccountCompleted = C_QuestLog.IsQuestFlaggedCompletedOnAccount(info.questID);
		info.floorLocation = Enum.QuestLineFloorLocation.Same; -- This data may not be exposed yet
		info.isLocalStory = false;
		return info;
	end
end

local function CheckAddOffer(questOffers, offer)
	if offer and not questOffers[offer.questID] then
		questOffers[offer.questID] = offer;
	end
end

function QuestOfferDataProviderMixin:AddQuestLinesToQuestOffers(questOffers, mapID)
	for index, questLineInfo in ipairs(C_QuestLine.GetAvailableQuestLines(mapID)) do
		CheckAddOffer(questOffers, CreateQuestOfferFromQuestLineInfo(mapID, questLineInfo));
	end

	local forceVisibleQuests = C_QuestLine.GetForceVisibleQuests(mapID);
	for _, questID in ipairs(forceVisibleQuests) do
		CheckAddOffer(questOffers, CreateQuestOfferFromQuestLineInfo(mapID, C_QuestLine.GetQuestLineInfo(questID, mapID)));
	end
end

function QuestOfferDataProviderMixin:AddTaskInfoToQuestOffers(questOffers, mapID)
	local taskInfo = GetQuestsForPlayerByMapIDCached(mapID);
	if taskInfo then
		for i, info in ipairs(taskInfo) do
			CheckAddOffer(questOffers, CreateQuestOfferFromTaskInfo(mapID, info));
		end
	end
end

function QuestOfferDataProviderMixin:GetAllQuestOffersForMap(mapID)
	-- NOTE: This needs to process things in priority order:
	-- 1. QuestLine
	-- 2. Force Show
	-- 3. Task Info
	-- Never add duplicates, because the priority is ranked from most info to least info.
	-- questOffers will be indexed by questID to make it easier to avoid adding duplicates
	local questOffers = {};
	self:AddQuestLinesToQuestOffers(questOffers, mapID);
	self:AddTaskInfoToQuestOffers(questOffers, mapID);

	return questOffers;
end

function QuestOfferDataProviderMixin:AddAllRelevantQuestOffers(mapID)
	for questID, questOffer in pairs(self:GetAllQuestOffersForMap(mapID)) do
		self:CheckAddQuestOffer(questOffer);
	end
end

function QuestOfferDataProviderMixin:AddAllRelevantQuestHubs(mapID)
	local hubs = C_AreaPoiInfo.GetQuestHubsForMap(mapID);
	for _, hubAreaPoiID in ipairs(hubs) do
		local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, hubAreaPoiID);
		if poiInfo then
			poiInfo.dataProvider = self;
			self:GetQuestHubs()[hubAreaPoiID] = poiInfo;
		end
	end
end

function QuestOfferDataProviderMixin:GetPinSuppressor()
	return GetOrCreateTableEntry(self, "pinSuppressor");
end

function QuestOfferDataProviderMixin:IsCityMap(mapID)
	local cityMaps = GetOrCreateTableEntry(self, "cityMaps");
	local isCityMap = cityMaps[mapID];
	if isCityMap ~= nil then
		return isCityMap;
	end

	isCityMap = C_Map.IsCityMap(mapID);
	cityMaps[mapID] = isCityMap;
	return isCityMap;
end

function QuestOfferDataProviderMixin:IsSuppressionDisabled(mapID, questHubPin)
	if self:IsCityMap(mapID) then
		return true;
	end

	-- Optional
	if questHubPin and self:IsAtMaxZoom() then
		local hubMapID = questHubPin:GetLinkedUIMapID();
		if not hubMapID or not self:IsCityMap(hubMapID) then
			return true;
		end
	end

	return false;
end

function QuestOfferDataProviderMixin:IsQuestOfferSuppressed(mapID, questOffer)
	local hubPinThatSuppressedOffer = self:GetPinSuppressor()[questOffer.questID];
	if self:IsSuppressionDisabled(mapID, hubPinThatSuppressedOffer) then
		return false;
	end

	return hubPinThatSuppressedOffer ~= nil;
end

function QuestOfferDataProviderMixin:CheckQuestIsRelatedToHub(questID, questHubPin)
	local suppressor = self:GetPinSuppressor();
	local isRelated = suppressor[questID] == questHubPin;
	if not isRelated then
		isRelated = C_QuestHub.IsQuestCurrentlyRelatedToHub(questID, questHubPin:GetPoiInfo().areaPoiID);
		if isRelated then
			suppressor[questID] = questHubPin;
		end
	end

	return isRelated;
end

function QuestOfferDataProviderMixin:RefreshRelatedQuests(questHubPin)
	-- Early out if nothing could be related to this hub
	if self:IsSuppressionDisabled(self:GetMap():GetMapID(), questHubPin) then
		return {};
	end

	local relatedQuests = {};
	for questID, questOffer in pairs(self:GetQuestOffers()) do
		if self:CheckQuestIsRelatedToHub(questID, questHubPin) then
			table.insert(relatedQuests, questOffer);
		end
	end

	return relatedQuests;
end

function QuestOfferDataProviderMixin:CheckAddQuestOfferPins(mapID)
	for questID, questOffer in pairs(self:GetQuestOffers()) do
		if not self:IsQuestOfferSuppressed(mapID, questOffer) then
			local pin = self:GetMap():AcquirePin("QuestOfferPinTemplate", questOffer);
		end
	end
end

function QuestOfferDataProviderMixin:CheckAddHubPins(mapID)
	for _, hubPoiInfo in pairs(self:GetQuestHubs()) do
		self:GetMap():AcquirePin("QuestHubPinTemplate", hubPoiInfo);
	end
end

function QuestOfferDataProviderMixin:CacheFilterSettings()
	self.showLocalStories = GetCVarBool("questPOILocalStory");
end

function QuestOfferDataProviderMixin:ShouldShowLocalStories()
	return self.showLocalStories;
end

function QuestOfferDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	local mapID = self:GetMap():GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	if (mapInfo and MapUtil.ShouldMapTypeShowQuests(mapInfo.mapType)) then
		self:CacheFilterSettings();
		self:AddAllRelevantQuestOffers(mapID);
		self:AddAllRelevantQuestHubs(mapID);
		self:CheckAddHubPins(mapID);
		self:CheckAddQuestOfferPins(mapID);
	end
end

function QuestOfferDataProviderMixin:OnShow()
	MapCanvasDataProviderMixin.OnShow(self);
	self:RegisterEvent("QUESTLINE_UPDATE");
	self:RegisterEvent("MINIMAP_UPDATE_TRACKING");
	self:RequestQuestLinesForMap();
end

function QuestOfferDataProviderMixin:OnHide()
	MapCanvasDataProviderMixin.OnHide(self);
	self:UnregisterEvent("QUESTLINE_UPDATE");
	self:UnregisterEvent("MINIMAP_UPDATE_TRACKING");
end

function QuestOfferDataProviderMixin:OnMapChanged()
	self:RequestQuestLinesForMap()
	MapCanvasDataProviderMixin.OnMapChanged(self)
end

function QuestOfferDataProviderMixin:OnEvent(event, ...)
	if (event == "QUESTLINE_UPDATE") then
		local requestRequired = ...;
		if(requestRequired) then
			self:RequestQuestLinesForMap()
		else
			self:RefreshAllData();
		end
	elseif event == "MINIMAP_UPDATE_TRACKING" then
		self:RefreshAllData();
	end
end

function QuestOfferDataProviderMixin:RequestQuestLinesForMap()
	local mapID = self:GetMap():GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	if (mapInfo and MapUtil.ShouldMapTypeShowQuests(mapInfo.mapType)) then
		C_QuestLine.RequestQuestLinesForMap(mapID)
	end
end

function QuestOfferDataProviderMixin:OnCanvasScaleChanged()
	if self:CheckUpdateMaxZoom() then
		self:RefreshAllData();
	end
end

function QuestOfferDataProviderMixin:CheckUpdateMaxZoom()
	local isMaxZoom = self:GetMap():IsAtMaxZoom();
	if self.isMaxZoom ~= isMaxZoom then
		self.isMaxZoom = isMaxZoom;
		return true;
	end

	return false;
end

function QuestOfferDataProviderMixin:IsAtMaxZoom()
	self:CheckUpdateMaxZoom();
	return self.isMaxZoom;
end

-- TODO: Hoping to find a better way to get this implemented, but copy paste is the way for now.
function QuestOfferDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:GetMap():RegisterCallback("SetBounty", self.SetBounty, self);
end

function QuestOfferDataProviderMixin:OnRemoved(mapCanvas)
	self:GetMap():UnregisterCallback("SetBounty", self);

	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end

function QuestOfferDataProviderMixin:SetBounty(bountyQuestID, bountyFactionID, bountyFrameType)
	local changed = self.bountyQuestID ~= bountyQuestID;
	if changed then
		self.bountyQuestID = bountyQuestID;
		self.bountyFactionID = bountyFactionID;
		self.bountyFrameType = bountyFrameType;
		if self:GetMap() then
			self:RefreshAllData();
		end
	end
end

function QuestOfferDataProviderMixin:GetBountyInfo()
	return self.bountyQuestID, self.bountyFactionID, self.bountyFrameType;
end
-- END TODO: copy paste hacks

IconWithHeightIndicatorMapPinMixin = {};

function IconWithHeightIndicatorMapPinMixin:SetHeightIndicator(floorLocation)
	if floorLocation == Enum.QuestLineFloorLocation.Below then
		self.Texture:SetPoint("CENTER", self, "CENTER", 0, -4);
	elseif floorLocation == Enum.QuestLineFloorLocation.Above then
		self.Texture:SetPoint("CENTER", self, "CENTER", 0, 4);
	end

	local isDifferentFloor = floorLocation ~= nil and floorLocation ~= Enum.QuestLineFloorLocation.Same;
	self.HeightIndicator:SetShown(isDifferentFloor);
	self.Texture:SetDesaturated(isDifferentFloor);
end

QuestOfferPinMixin = CreateFromMixins(MapCanvasPinMixin, SuperTrackablePinMixin);

function QuestOfferPinMixin:OnLoad()
	self:SetScalingLimits(1, 1.0, 1.2);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_QUEST_OFFER");
end

function QuestOfferPinMixin:OnAcquired(questOffer)
	SuperTrackablePinMixin.OnAcquired(self, questOffer);

	self.mapID = self:GetMap():GetMapID();
	Mixin(self, questOffer);

	self:UseFrameLevelType("PIN_FRAME_LEVEL_QUEST_OFFER", self.pinLevel);
	self:SetHeightIndicator(self.floorLocation);
	self:SetPosition(self.x, self.y);

	self.Texture:SetAtlas(self.questIcon);
	self.Texture:SetAlpha(self.pinAlpha);

	self:Show();
end

function QuestOfferPinMixin:OnMouseEnter()
	TaskPOI_OnEnter(self);
	self:OnLegendPinMouseEnter();
end

function QuestOfferPinMixin:OnMouseLeave()
	TaskPOI_OnLeave(self);
	self:OnLegendPinMouseLeave();
end

function QuestOfferPinMixin:GetSuperTrackData()
	return Enum.SuperTrackingMapPinType.QuestOffer, self.questID;
end

QuestHubPinMixin = {};

function QuestHubPinMixin:OnAcquired(poiInfo)
	AreaPOIPinMixin.OnAcquired(self, poiInfo);
	self:ConsolidateRelatedQuests();
	self:UpdatePriorityQuestDisplay();
end

local function SortConsolidatedQuestsComparator(questOffer1, questOffer2)
	if questOffer1.pinLevel ~= questOffer2.pinLevel then
		return questOffer1.pinLevel > questOffer2.pinLevel;
	end

	local strCmpResult = strcmputf8i(questOffer1.questName, questOffer2.questName);
	if (strCmpResult ~= 0) then
		return strCmpResult < 0;
	end

	if questOffer1.questLineID ~= questOffer2.questLineID then
		if not questOffer1.questLineID then
			return false;
		end

		if not questOffer2.questLineID then
			return true;
		end

		return questOffer1.questLineID < questOffer2.questLineID;
	end

	-- This has to be filled out on every offer
	return questOffer1.questID < questOffer2.questID;
end

function QuestHubPinMixin:ConsolidateRelatedQuests()
	self.relatedQuests = self:GetDataProvider():RefreshRelatedQuests(self);
	table.sort(self.relatedQuests, SortConsolidatedQuestsComparator);
end

function QuestHubPinMixin:UpdatePriorityQuestDisplay()
	local relatedQuests = self:GetRelatedQuests();
	local priorityQuest = relatedQuests and relatedQuests[1];

	self.PriorityQuest:SetShown(priorityQuest ~= nil);
	if priorityQuest then
		self.PriorityQuest:SetAtlas(priorityQuest.questIcon);
	end
end

function QuestHubPinMixin:GetRelatedQuests()
	return GetOrCreateTableEntry(self, "relatedQuests");
end

function QuestHubPinMixin:ShouldMouseButtonBePassthrough(button)
	return false;
end

function QuestHubPinMixin:GetLinkedUIMapID()
	return self:GetPoiInfo().linkedUiMapID;
end

function QuestHubPinMixin:AddCustomTooltipData(tooltip)
	self:AddRelatedQuestsToTooltip(tooltip);

	-- Since this isn't using the base pin, just have it add the instructions manually.
	if self:GetLinkedUIMapID() then
		GameTooltip_AddInstructionLine(tooltip, MAP_LINK_POI_TOOLTIP_INSTRUCTION_LINE, false);
	end
end

local MAX_DISPLAYED_QUESTS_IN_TOOLTIP = 3;

function QuestHubPinMixin:AddRelatedQuestsToTooltip(tooltip)
	local relatedQuests = self:GetRelatedQuests();
	local relatedQuestCount = #relatedQuests;
	if relatedQuestCount > 0 then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddHighlightLine(tooltip, QUEST_HUB_TOOLTIP_AVAILABLE_QUESTS_HEADER);

		local overflowQuestCount = #relatedQuests - MAX_DISPLAYED_QUESTS_IN_TOOLTIP;
		local needsOverflowLine = overflowQuestCount > 1;

		for displayIndex, questOffer in ipairs(relatedQuests) do
			if not needsOverflowLine or displayIndex <= MAX_DISPLAYED_QUESTS_IN_TOOLTIP then
				GameTooltip_AddNormalLine(tooltip, CreateAtlasMarkup(questOffer.questIcon) .. " " .. questOffer.questName);
			else
				GameTooltip_AddNormalLine(tooltip, QUEST_HUB_TOOLTIP_MORE_QUESTS_REMAINING:format(relatedQuestCount - MAX_DISPLAYED_QUESTS_IN_TOOLTIP));
				break;
			end
		end
	end
end

function QuestHubPinMixin:OnMouseClickAction(button)
	-- Trust that this will work and that QuestHubPinMixin implements all necessary APIs
	MapLinkPinMixin.OnMouseClickAction(self, button);
end

-- Hardcoding the QID for now since this is a rare case. If you find yourself
-- adding more QIDs here, please consider making this data driven.
local GLOW_HUB_QUESTS = {
	[80592] = true, -- Severed Threads Pact
};

GLOW_HUB_QUESTS_ACKNOWLEDGED = {};

QuestHubPinGlowMixin = {};

function QuestHubPinGlowMixin:OnMouseEnter()
	AreaPOIPinMixin.OnMouseEnter(self);
	self:AcknowledgeGlow();
end

function QuestHubPinGlowMixin:OnReleased()
	AreaPOIPinMixin.OnReleased(self);
	if (self.AnimatedHighlight) then
		self.AnimatedHighlight:EndBackgroundPulses();
	end
end

function QuestHubPinGlowMixin:GetHighlightType() -- override
	local highlightType = MapPinHighlightType.None;
	local relatedQuests = self:GetRelatedQuests();
	for _, quest in ipairs(relatedQuests) do
		local shouldTryGlowQuest = GLOW_HUB_QUESTS[quest.questID];
		if (shouldTryGlowQuest) then
			local lastResetStartTimeAcknowledgement = GLOW_HUB_QUESTS_ACKNOWLEDGED[quest.questID];
			local questAcknowledgedThisWeek = lastResetStartTimeAcknowledgement and lastResetStartTimeAcknowledgement == C_DateAndTime.GetWeeklyResetStartTime();
			if (not questAcknowledgedThisWeek) then
				highlightType = MapPinHighlightType.ImportantHubQuestHighlight;
			end
		end
	end

	if (highlightType == MapPinHighlightType.None) then
		highlightType = AreaPOIPinMixin.GetHighlightType(self);
	end

	return highlightType;
end

function QuestHubPinGlowMixin:GetHighlightAnimType() -- override
	return MapPinHighlightAnimType.BackgroundPulse;
end

function QuestHubPinGlowMixin:AcknowledgeGlow()
	if (not self.AnimatedHighlight) then
		return;
	end

	self.AnimatedHighlight:EndBackgroundPulses();
	local relatedQuests = self:GetRelatedQuests();
	for _, quest in ipairs(relatedQuests) do
		if (GLOW_HUB_QUESTS[quest.questID]) then
			GLOW_HUB_QUESTS_ACKNOWLEDGED[quest.questID] = C_DateAndTime.GetWeeklyResetStartTime();
		end
	end
end