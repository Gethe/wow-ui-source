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

QuestOfferDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin, { PIN_LEVEL_RANGE = GetMaxPinLevel(), });
QuestOfferDataProviderMixin:Init("questPOILocalStory");

function QuestOfferDataProviderMixin:BuildPinSubTypeData(pinSubType, info)
	return { pinSubType = pinSubType, info = info };
end

function QuestOfferDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("QuestOfferPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("QuestHubPinTemplate");
	self:ResetQuestOffers();
	self:ResetQuestHubs();
	self:ResetSuppressor();
end

function QuestOfferDataProviderMixin:ResetQuestOffers()
	self.questOffers = nil;
end

function QuestOfferDataProviderMixin:ResetQuestHubs()
	self.questHubs = nil;
end

function QuestOfferDataProviderMixin:ResetSuppressor()
	self.pinSuppressor = nil;
end

function QuestOfferDataProviderMixin:GetQuestOffers()
	return GetOrCreateTableEntry(self, "questOffers");
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

function QuestOfferDataProviderMixin:ShouldAddQuestOffer(questOffer, mapID)
	if not questOffer then
		return false;
	end

	if questOffer.inProgress then
		return false;
	end

	-- offers from tasks won't have startMapID but will already be filtered out
	if questOffer.startMapID then
		if questOffer.startMapID ~= mapID and not MapUtil.IsChildMapCached(questOffer.startMapID, mapID) then
			return false;
		end
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

function QuestOfferDataProviderMixin:CheckAddQuestOffer(questOffer, mapID)
	if self:ShouldAddQuestOffer(questOffer, mapID) then
		questOffer.dataProvider = self;
		self:GetQuestOffers()[questOffer.questID] = questOffer;
	end
end

local function InitializeCommonQuestOfferData(info)
	if info then
		local questClassification = C_QuestInfoSystem.GetQuestClassification(info.questID);
		local pinData = questOfferPinData[questClassification];
		if pinData then
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
		info.questLineName = nil;

		local title, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(info.questID);
		local questClassification = C_QuestInfoSystem.GetQuestClassification(info.questID);
		info.questName = title;
		info.questLineID = nil;
		info.isHidden = C_QuestLog.IsQuestTrivial(info.questID);
		info.isLegendary = questClassification == Enum.QuestClassification.Legendary;
		info.isCampaign = false; -- This cannot be a campaign for a task, it would be in a quest line
		info.isImportant = questClassification == Enum.QuestClassification.Important;
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
	local taskInfo = GetTasksOnMapCached(mapID);
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
		self:CheckAddQuestOffer(questOffer, mapID);
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
	mapID = mapID or self:GetMap():GetMapID();
	local cityMaps = GetOrCreateTableEntry(self, "cityMaps");
	local isCityMap = cityMaps[mapID];
	if isCityMap ~= nil then
		return isCityMap;
	end

	isCityMap = C_Map.IsCityMap(mapID);
	cityMaps[mapID] = isCityMap;
	return isCityMap;
end

function QuestOfferDataProviderMixin:IsQuestHubForCityMap(questHubPin)
	local hubMapID = questHubPin:GetLinkedUIMapID();
	return hubMapID and self:IsCityMap(hubMapID);
end

function QuestOfferDataProviderMixin:IsSuppressionDisabled(mapID, questHubPin)
	if self:IsCityMap(mapID) then
		return true;
	end

	local isAtMaxZoom = self:GetMap():IsAtMaxZoom();

	-- Optional
	if questHubPin then
		if isAtMaxZoom then
			if not self:IsQuestHubForCityMap(questHubPin) then
				return true;
			end
		end

		return false;
	end

	return isAtMaxZoom;
end

function QuestOfferDataProviderMixin:GetLinkedQuestHub(questOffer)
	return self:GetPinSuppressor()[questOffer.questID];
end

function QuestOfferDataProviderMixin:CheckQuestIsLinkedToHub(questID, questHubPin)
	local suppressor = self:GetPinSuppressor();
	local isLinked = suppressor[questID] == questHubPin;
	if not isLinked then
		isLinked = C_QuestHub.IsQuestCurrentlyRelatedToHub(questID, questHubPin:GetPoiInfo().areaPoiID);
		if isLinked then
			suppressor[questID] = questHubPin;
		end
	end

	return isRelated;
end

function QuestOfferDataProviderMixin:CheckAddQuestOfferPins(mapID)
	for questID, questOffer in pairs(self:GetQuestOffers()) do
		self:GetMap():AcquirePin("QuestOfferPinTemplate", questOffer);
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
	CVarMapCanvasDataProviderMixin.OnShow(self);
	self:RegisterEvent("QUESTLINE_UPDATE");
	self:RegisterEvent("MINIMAP_UPDATE_TRACKING");
	self:RequestQuestLinesForMap();
end

function QuestOfferDataProviderMixin:OnHide()
	CVarMapCanvasDataProviderMixin.OnHide(self);
	self:UnregisterEvent("QUESTLINE_UPDATE");
	self:UnregisterEvent("MINIMAP_UPDATE_TRACKING");
end

function QuestOfferDataProviderMixin:OnMapChanged()
	self:RequestQuestLinesForMap();

	-- NOTE: This comes later because we used to need to do some animation data updates here before refresh all data was called.
	-- Nuking all the animation stuff for the time being while I rebuild it.
	MapCanvasDataProviderMixin.OnMapChanged(self);
end

function QuestOfferDataProviderMixin:OnEvent(event, ...)
	CVarMapCanvasDataProviderMixin.OnEvent(self, event, ...);

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
	self:AddTag(MapPinTags.QuestOffer);

	self.mapID = self:GetMap():GetMapID();
	Mixin(self, questOffer);

	self:UseFrameLevelType("PIN_FRAME_LEVEL_QUEST_OFFER", self.pinLevel);
	self:SetHeightIndicator(self.floorLocation);
	self:SetPosition(self.x, self.y);

	self.Texture:SetAtlas(self.questIcon);
	self.Texture:SetAlpha(self.pinAlpha);
end

function QuestOfferPinMixin:OnMouseEnter()
	TaskPOI_OnEnter(self);
end

function QuestOfferPinMixin:OnMouseLeave()
	TaskPOI_OnLeave(self);
end

function QuestOfferPinMixin:GetSuperTrackData()
	return Enum.SuperTrackingMapPinType.QuestOffer, self.questID;
end

function QuestOfferPinMixin:GetQuestClassification()
	return self.questClassification;
end

function QuestOfferPinMixin:GetDisplayName()
	return self.questName;
end

QuestHubPinMixin = {};

function QuestHubPinMixin:OnAcquired(poiInfo)
	self.poiInfo = poiInfo;
	self:SetDataProvider(poiInfo.dataProvider); -- catch-22 issue.

	self:BuildRelatedQuests(self);
	self:SetIsQuestHubForCityMap(self.dataProvider:IsQuestHubForCityMap(self));
	AreaPOIPinMixin.OnAcquired(self, poiInfo);	
end

function QuestHubPinMixin:BuildRelatedQuests()
	self.relatedQuests = {};

	local dataProvider = self:GetDataProvider();

	-- Early out if nothing could be related to this hub
	if dataProvider:IsSuppressionDisabled(dataProvider:GetMap():GetMapID(), self) then
		return;
	end

	for questID, questOffer in pairs(dataProvider:GetQuestOffers()) do
		if dataProvider:CheckQuestIsLinkedToHub(questID, self) then
			self.relatedQuests[questOffer.questID] = questOffer;
		end
	end
end

function QuestHubPinMixin:GetRelatedQuests()
	return self.relatedQuests;
end

function QuestHubPinMixin:SetIsQuestHubForCityMap(isForCity)
	self.isForCity = isForCity;
end

function QuestHubPinMixin:IsQuestHubForCityMap()
	return self.isForCity;
end

local function DetermineHigherPriorityPin(pin1, pin2)
	if not pin1 then
		return pin2;
	end

	if not pin2 then
		return pin1;
	end

	-- This is programmer design, needs feedback and iteration
	-- Prefer showing active content over quest offers unless the quest offer is campaign or important.
	local pin1IsQuestOffer = pin1:MatchesTag(MapPinTags.QuestOffer);
	local pin2IsQuestOffer = pin2:MatchesTag(MapPinTags.QuestOffer);
	local pin1HighPriorityQuestOffer = pin1IsQuestOffer and pin1.questClassification <= Enum.QuestClassification.Campaign;
	local pin2HighPriorityQuestOffer = pin2IsQuestOffer and pin2.questClassification <= Enum.QuestClassification.Campaign;
	if pin1HighPriorityQuestOffer or pin2HighPriorityQuestOffer then
		return pin1HighPriorityQuestOffer and pin1 or pin2;
	end

	local pin1IsEvent = pin1:MatchesTag(MapPinTags.Event);
	local pin2IsEvent = pin2:MatchesTag(MapPinTags.Event);
	if pin1IsEvent or pin2IsEvent then
		return pin1IsEvent and pin1 or pin2;
	end
	
	local pin1IsWorldQuest = pin1:MatchesTag(MapPinTags.WorldQuest);
	local pin2IsWorldQuest = pin2:MatchesTag(MapPinTags.WorldQuest);
	if pin1IsWorldQuest or pin2IsWorldQuest then
		return pin1IsWorldQuest and pin1 or pin2;
	end

	local pin1IsBonusObjective = pin1:MatchesTag(MapPinTags.BonusObjective);
	local pin2IsBonusObjective = pin2:MatchesTag(MapPinTags.BonusObjective);
	if pin1IsBonusObjective or pin2IsBonusObjective then
		return pin1IsBonusObjective and pin1 or pin2;
	end

	if pin1IsQuestOffer or pin2IsQuestOffer then
		return pin1IsQuestOffer and pin1 or pin2;
	end
	
	return pin1; -- fallback, last pin that was considered better remains better.
end

function QuestHubPinMixin:UpdatePriorityQuestDisplay()
	local currentDisplay = self.priorityDisplayFrame;
	if currentDisplay then
		self.priorityDisplayFrame = nil;
		FrameCloneManager:Release(currentDisplay);
	end

	local pins = self:GetSuppressedPins();
	if not pins then
		return;
	end
	
	local bestPin;
	for pin, active in pairs(pins) do
		if active then
			bestPin = DetermineHigherPriorityPin(bestPin, pin);
		end
	end

	if bestPin then
		local clone = FrameCloneManager:Clone(bestPin, self);
		self.priorityDisplayFrame = clone;
		clone:ClearAllPoints();
		clone:SetPoint("CENTER", self, "BOTTOM", 0, 6);
		clone:Show();
		clone:SetAlpha(1);
		clone:SetScale(0.85);
	end
end

function QuestHubPinMixin:ShouldMouseButtonBePassthrough(button)
	return false;
end

function QuestHubPinMixin:GetLinkedUIMapID()
	return self:GetPoiInfo().linkedUiMapID;
end

local MAX_DISPLAYED_CONTENT_ITEMS_IN_TOOLTIP = 3;

local suppressedTooltipSections =
{
	-- Other Suppressed Pins (not quest offers)
	{
		suppressedPinIndex = 1,
		header = QUEST_HUB_TOOLTIP_AVAILABLE_CONTENT_HEADER,
		maxItems = MAX_DISPLAYED_CONTENT_ITEMS_IN_TOOLTIP,
		moreItemsRemainingString = QUEST_HUB_TOOLTIP_MORE_QUESTS_REMAINING,
	},

	-- Suppressed Quest Offers
	{
		suppressedPinIndex = 2,
		header = QUEST_HUB_TOOLTIP_AVAILABLE_QUESTS_HEADER,
		maxItems = MAX_DISPLAYED_CONTENT_ITEMS_IN_TOOLTIP,
		moreItemsRemainingString = QUEST_HUB_TOOLTIP_MORE_QUESTS_REMAINING,
	},
};

function QuestHubPinMixin:AddCustomTooltipData(tooltip)
	self:ResetSuppressedPinTooltipPool();

	local suppressedPins = { self:GetSuppressedPinsSorted() };
	for index, formatData in ipairs(suppressedTooltipSections) do
		self:AddSuppressedPinsToTooltip(tooltip, suppressedPins, formatData);
	end

	-- Since this isn't using the base pin, just have it add the instructions manually.
	if self:GetLinkedUIMapID() then
		GameTooltip_AddInstructionLine(tooltip, MAP_LINK_POI_TOOLTIP_INSTRUCTION_LINE, false);
	end
end

function QuestHubPinMixin:AddSuppressedPinsToTooltip(tooltip, allSuppressedPins, formatData)
	local suppressedPins = allSuppressedPins[formatData.suppressedPinIndex];
	local count = #suppressedPins;
	if count > 0 then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddHighlightLine(tooltip, formatData.header);

		local overflowCount = count - formatData.maxItems;
		local needsOverflowLine = overflowCount > 1;
		local container = self:GetSuppressedPinTooltipContainer(formatData);

		for displayIndex, pin in ipairs(suppressedPins) do
			if not needsOverflowLine or displayIndex <= formatData.maxItems then
				self:AddSuppressedPinToTooltipContainer(container, pin);
			else
				break;
			end
		end

		if needsOverflowLine then
			container:SetAdditionalItemsText(formatData.moreItemsRemainingString:format(count - formatData.maxItems));
		end		

		container:Layout();
		GameTooltip_InsertFrame(tooltip, container, 0);
	end
end

function QuestHubPinMixin:ShouldAddSuppressedPinToTooltip(pin)
	-- Making the assumption that if this is being called the pin is already known to be suppressed.
	return not pin:MatchesAnyTag(MapPinTags.FlightPoint);
end

function QuestHubPinMixin:AddSuppressedPinToTooltipContainer(container, pin)
	container:AddLine(self:CreatePinTooltipFrame(pin));
end

function QuestHubPinMixin:CreatePinTooltipFrame(pin)
	local pool = self:GetOrCreateSuppressedPinTooltipPool();
	local frame = pool:Acquire();
	frame:SetupFromPin(pin);
	return frame;
end

function QuestHubPinMixin:GetOrCreateSuppressedPinTooltipPool()
	if not self.suppressedPinPool then 
		self.suppressedPinPool = CreateFramePool("Frame", GetAppropriateTopLevelParent(), "SuppressedPinTooltipTemplate");
	end

	return self.suppressedPinPool;
end

function QuestHubPinMixin:ResetSuppressedPinTooltipPool()
	if self.suppressedPinPool then
		self.suppressedPinPool:ReleaseAll();
	end
end

function QuestHubPinMixin:GetSuppressedPinTooltipContainer(formatData)
	if not self.suppressedPinTooltipContainers then
		self.suppressedPinTooltipContainers = {};
	end

	if not self.suppressedPinTooltipContainers[formatData.suppressedPinIndex] then
		self.suppressedPinTooltipContainers[formatData.suppressedPinIndex] = CreateFrame("Frame", nil, nil, "SuppressedPinTooltipContainerTemplate");
	end

	local container = self.suppressedPinTooltipContainers[formatData.suppressedPinIndex];
	container:Reset();
	return container;
end

function QuestHubPinMixin:OnMouseClickAction(button)
	-- Trust that this will work and that QuestHubPinMixin implements all necessary APIs
	MapLinkPinMixin.OnMouseClickAction(self, button);
end

function QuestHubPinMixin:IsPinSuppressor()
	return true;
end

function QuestHubPinMixin:GetSuppressedPins()
	return self.suppressedPins;
end

local function SortQuestOffer(questOffer1, questOffer2)
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

local function SortSuppressedPins(pin1, pin2)
	local pin1Type = pin1:MatchesTag(MapPinTags.Event);
	local pin2Type = pin2:MatchesTag(MapPinTags.Event);

	-- Events first
	if (pin1Type or pin2Type) and pin1Type ~= pin2Type then
		return pin1Type;
	end

	pin1Type = pin1:MatchesTag(MapPinTags.WorldQuest);
	pin2Type = pin2:MatchesTag(MapPinTags.WorldQuest);

	-- World quests second
	if (pin1Type or pin2Type) and pin1Type ~= pin2Type then
		return pin1Type;
	end

	pin1Type = pin1:MatchesTag(MapPinTags.BonusObjective);
	pin2Type = pin2:MatchesTag(MapPinTags.BonusObjective);

	-- Bonus Objectives third
	if (pin1Type or pin2Type) and pin1Type ~= pin2Type then
		return pin1Type;
	end
	
	-- If the types are the same, alphabetical ordering
	local strCmpResult = strcmputf8i(pin1:GetDisplayName(), pin2:GetDisplayName());
	if (strCmpResult ~= 0) then
		return strCmpResult < 0;
	end

	-- Arbitrary ordering if all else fails
	return tostring(pin1) < tostring(pin2);
end

function QuestHubPinMixin:GetSuppressedPinsSorted()
	local pins = self:GetSuppressedPins();
	local orderedPins = {};
	local orderedQuestOffers = {};
	if pins then
		for pin, active in pairs(pins) do
			if active then
				if pin:MatchesTag(MapPinTags.QuestOffer) then
					table.insert(orderedQuestOffers, pin);
				elseif self:ShouldAddSuppressedPinToTooltip(pin) then
					table.insert(orderedPins, pin);
				end
			end
		end
	end

	table.sort(orderedPins, SortSuppressedPins);
	table.sort(orderedQuestOffers, SortQuestOffer);

	return orderedPins, orderedQuestOffers;
end

function QuestHubPinMixin:ShouldSuppressPin(pin)
	if self.isSuppressionDisabled then
		return false;
	end

	-- Pins that can't be supertracked or are supertracked are never suppressed.
	if not pin.IsSuperTracked or pin:IsSuperTracked() then
		return false;
	end

	local isSuppressionCandidate = pin:MatchesAnyTag(MapPinTags.Event, MapPinTags.WorldQuest, MapPinTags.BonusObjective, MapPinTags.FlightPoint);
	
	if isSuppressionCandidate and self:Intersects(pin) then
		return true;
	end

	if self:IsRelatedQuestOfferPin(pin) then
		return true;
	end

	return false;
end

function QuestHubPinMixin:IsRelatedQuestOfferPin(pin)
	if pin:MatchesTag(MapPinTags.QuestOffer) then
		return self:GetDataProvider():GetLinkedQuestHub(pin) == self;
	end

	return false;
end

function QuestHubPinMixin:ResetSuppression()
	local suppressedPins = self:GetSuppressedPins();
	if suppressedPins then
		for pin in pairs(suppressedPins) do
			pin:ClearSuppression();
		end
	end

	self.suppressedPins = nil;
	self.isSuppressionDisabled = self:GetDataProvider():IsSuppressionDisabled(self:GetMap():GetMapID(), self);
end

function QuestHubPinMixin:TrackSuppressedPin(pin)
	if not self.suppressedPins then
		self.suppressedPins = {};
	end

	self.suppressedPins[pin] = true;
end

function QuestHubPinMixin:FinalizeSuppression()
	self:UpdatePriorityQuestDisplay();
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
	for _, quest in pairs(self:GetRelatedQuests()) do
		if GLOW_HUB_QUESTS[quest.questID] then
			local lastResetStartTimeAcknowledgement = GLOW_HUB_QUESTS_ACKNOWLEDGED[quest.questID];
			local questAcknowledgedThisWeek = lastResetStartTimeAcknowledgement and lastResetStartTimeAcknowledgement == C_DateAndTime.GetWeeklyResetStartTime();
			if (not questAcknowledgedThisWeek) then
				return MapPinHighlightType.ImportantHubQuestHighlight;
			end
		end
	end

	return AreaPOIPinMixin.GetHighlightType(self);
end

function QuestHubPinGlowMixin:GetHighlightAnimType() -- override
	local highlightType = self:GetHighlightType();
	if highlightType == MapPinHighlightType.ImportantHubQuestHighlight then
		return MapPinHighlightAnimType.BackgroundPulse;
	end

	return MapPinHighlightAnimType.ExpandAndFade;
end

function QuestHubPinGlowMixin:AcknowledgeGlow()
	if (not self.AnimatedHighlight) then
		return;
	end

	self.AnimatedHighlight:EndBackgroundPulses();
	for _, quest in pairs(self:GetRelatedQuests()) do
		if (GLOW_HUB_QUESTS[quest.questID]) then
			GLOW_HUB_QUESTS_ACKNOWLEDGED[quest.questID] = C_DateAndTime.GetWeeklyResetStartTime();
		end
	end
end

SuppressedPinTooltipMixin = {};

function SuppressedPinTooltipMixin:SetupFromPin(pin)
	-- TODO: Finish actual set up using data from the pin
	self.Title:SetText(pin:GetDisplayName());

	if self.clonedPin then
		FrameCloneManager:Release(self.clonedPin);
	end

	self.clonedPin = FrameCloneManager:Clone(pin, self);
	local clonedPin = self.clonedPin;
	clonedPin:ClearAllPoints();
	clonedPin:SetPoint("CENTER", self.Container);

	-- hacks?
	clonedPin:Show();
	clonedPin:SetAlpha(1);
	clonedPin:SetScale(0.9);
end

SuppressedPinTooltipContainerMixin = {};

function SuppressedPinTooltipContainerMixin:Reset()
	self:SetParent(GetAppropriateTopLevelParent());
	self:ClearAllPoints();
	self:SetPoint("TOPLEFT");
	self:Show();
	self.AdditionalItems:Hide();

	self.lines = {};
end

function SuppressedPinTooltipContainerMixin:AddLine(line)
	local previousLine = self.lines[#self.lines];
	table.insert(self.lines, line);
	
	line:ClearAllPoints();
	line:SetParent(self);
	line:Show();

	if previousLine then
		line:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT");
	else
		line:SetPoint("TOPLEFT");
	end
end

function SuppressedPinTooltipContainerMixin:SetAdditionalItemsText(text)
	self.AdditionalItems:SetText(text);
	self:AddLine(self.AdditionalItems);
end