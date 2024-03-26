
EncounterJournalDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

local TRACKING_PIN_OFFSET_Y = -0.02;
local TRACKING_PIN_OFFSET_X = 0.012;

function EncounterJournalDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	mapCanvas:SetPinTemplateType("EncounterJournalPinTemplate", "BUTTON");
	mapCanvas:SetPinTemplateType("EncounterMapTrackingPinTemplate", "BUTTON");
end

function EncounterJournalDataProviderMixin:OnShow()
	self:RegisterEvent("PORTRAITS_UPDATED");

	self:RegisterEvent("CONTENT_TRACKING_UPDATE");
	self:RegisterEvent("TRACKING_TARGET_INFO_UPDATE");
	self:RegisterEvent("SUPER_TRACKING_CHANGED");
end

function EncounterJournalDataProviderMixin:OnHide()
	self:UnregisterEvent("PORTRAITS_UPDATED");

	self:UnregisterEvent("CONTENT_TRACKING_UPDATE");
	self:UnregisterEvent("TRACKING_TARGET_INFO_UPDATE");
	self:UnregisterEvent("SUPER_TRACKING_CHANGED");
end

function EncounterJournalDataProviderMixin:OnEvent(event, ...)
	self:RefreshAllData();
end

function EncounterJournalDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("EncounterJournalPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("EncounterMapTrackingPinTemplate");
end

function EncounterJournalDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	
	if CanShowEncounterJournal() then
		local mapEncounters = C_EncounterJournal.GetEncountersOnMap(self:GetMap():GetMapID());
		for index, mapEncounterInfo in ipairs(mapEncounters) do
			local bossPin = self:GetMap():AcquirePin("EncounterJournalPinTemplate", mapEncounterInfo.encounterID);
			bossPin:SetPosition(mapEncounterInfo.mapX, mapEncounterInfo.mapY);
			local trackingPin = self:CheckForContentTracking(mapEncounterInfo.encounterID);
			if trackingPin then
				trackingPin:SetPosition(mapEncounterInfo.mapX + TRACKING_PIN_OFFSET_X, mapEncounterInfo.mapY + TRACKING_PIN_OFFSET_Y);
			end
		end
	end
end

function EncounterJournalDataProviderMixin:CheckForContentTracking(encounterID)
	if not ContentTrackingUtil.IsContentTrackingEnabled() or not GetCVarBool("contentTrackingFilter") then
		return false;
	end

	local trackedItemMapInfos = ContentTrackingUtil.GetTrackingMapInfoByEncounterID(encounterID);
	if not trackedItemMapInfos then
		return;
	end
	local numTrackedItems = #trackedItemMapInfos;
	if numTrackedItems <= 0 then
		return;
	end

	local pin = self:GetMap():AcquirePin("EncounterMapTrackingPinTemplate");
	pin:SetPinScale(1.5);
	pin:Init(self, trackedItemMapInfos);
	
	pin.isSuperTracked = pin:IsSuperTracked();

	if isSuperTracked then
		pin:UseFrameLevelType("PIN_FRAME_LEVEL_SUPER_TRACKED_CONTENT");
	else
		pin:UseFrameLevelType("PIN_FRAME_LEVEL_TRACKED_CONTENT");
	end

	pin.selected = isSuperTracked;
	
	pin:SetStyle(POIButtonUtil.Style.ContentTracking);

	local trackableMapInfo = trackedItemMapInfos[1];
	pin:SetTrackable(trackableMapInfo.trackableType, trackableMapInfo.trackableID);
	pin:UpdateButtonStyle();
	return pin;
end

--[[ Pin ]]--
EncounterJournalPinMixin = CreateFromMixins(MapCanvasPinMixin);

function EncounterJournalPinMixin:OnLoad()
	self:SetScalingLimits(1, 0.7, 1.3);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_ENCOUNTER");
end

function EncounterJournalPinMixin:OnAcquired(encounterID)
	self.encounterID = encounterID;
	self:Refresh();
end

function EncounterJournalPinMixin:Refresh()
	local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(self.encounterID);
	self.instanceID = instanceID;
	self.tooltipTitle = name;
	self.tooltipText = description;
	local displayInfo = select(4, EJ_GetCreatureInfo(1, self.encounterID));
	self.displayInfo = displayInfo;
	if displayInfo then
		SetPortraitTextureFromCreatureDisplayID(self.Background, displayInfo);
		self.Background:Show();
	else
		self.Background:Hide();
	end
	
	local complete = C_EncounterJournal.IsEncounterComplete(encounterID);
	self.DefeatedOpacity:SetShown(complete);
	self.DefeatedOverlay:SetShown(complete);
	self.Background:SetDesaturation(complete and 0.7 or 0);
end

function EncounterJournalPinMixin:OnMouseEnter()
	if self.tooltipTitle then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip_SetTitle(GameTooltip, self.tooltipTitle);
		
		if C_EncounterJournal.IsEncounterComplete(self.encounterID) then
			GameTooltip_AddColoredLine(GameTooltip, DUNGEON_ENCOUNTER_DEFEATED, RED_FONT_COLOR);
		end
		
		GameTooltip_AddNormalLine(GameTooltip, self.tooltipText, true);
		GameTooltip:Show();
	end
end

function EncounterJournalPinMixin:OnMouseLeave()
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

function EncounterJournalPinMixin:OnMouseClickAction()
	EncounterJournal_LoadUI();
	EncounterJournal_OpenJournal(nil, self.instanceID, self.encounterID);
end

--[[ Content Tracking Pin ]]--
EncounterMapTrackingPinMixin = CreateFromMixins(MapCanvasPinMixin);

function EncounterMapTrackingPinMixin:OnLoad()
	self:SetScalingLimits(1, 0.7, 1.3);
	self.UpdateTooltip = self.OnMouseEnter;
end

function EncounterMapTrackingPinMixin:DisableInheritedMotionScriptsWarning()
	return true;
end

function EncounterMapTrackingPinMixin:Init(dataProvider, trackableEncounterInfo)
	self.dataProvider = dataProvider;
	self.trackableEncounterInfo = trackableEncounterInfo;
end

function EncounterMapTrackingPinMixin:OnMouseEnter()
	POIButtonMixin.OnEnter(self);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local title = CONTENT_TRACKING_MAP_TOGGLE;
	GameTooltip_SetTitle(GameTooltip, title);

	--Get current difficultyID if player is currently in an encounter
	local difficultyID = select(3, GetInstanceInfo());

	local numTrackedItems = #self.trackableEncounterInfo;
	for i = 1, numTrackedItems do
		local trackableMapInfo = self.trackableEncounterInfo[i];
		local sourceInfo = C_TransmogCollection.GetSourceInfo(trackableMapInfo.trackableID);
		local quality = nil;
		if sourceInfo then
			quality = sourceInfo.quality;
		end
		local objectiveText = C_ContentTracking.GetTitle(trackableMapInfo.trackableType, trackableMapInfo.trackableID);
		local difficultyName =""; 
		if trackableMapInfo.difficultyID then
			difficultyName = PARENS_TEMPLATE:format(DifficultyUtil.GetDifficultyName(trackableMapInfo.difficultyID));
		end
		local qualityColor = ITEM_EPIC_COLOR; --default to item epic color if somehow the item is not loaded
		if quality then
			local r, g, b = C_Item.GetItemQualityColor(quality);
			qualityColor = CreateColor(r, g, b, 1);
		end
		local difficultyColor = RED_FONT_COLOR;
		if not difficultyID or difficultyID == 0 or (difficultyID and difficultyID == trackableMapInfo.difficultyID) then
			difficultyColor = NORMAL_FONT_COLOR;
		end
		GameTooltip_AddColoredDoubleLine(GameTooltip, objectiveText, difficultyName, qualityColor, difficultyColor);
	end
	

	GameTooltip:Show();
end

function EncounterMapTrackingPinMixin:IsSuperTracked()
	
	local numTrackedItems = #self.trackableEncounterInfo;
	local isSuperTracked = nil;
	
	for i = 1, numTrackedItems do
		local trackableMapInfo = self.trackableEncounterInfo[i];
		local trackableType, trackableID = C_SuperTrack.GetSuperTrackedContent();
		if trackableType == trackableMapInfo.trackableType and trackableID == trackableMapInfo.trackableID then
			isSuperTracked = true;
		end
	end
	return isSuperTracked;
end

function EncounterMapTrackingPinMixin:OnMouseLeave()
	POIButtonMixin.OnLeave(self);

	GameTooltip_Hide();
end

function EncounterMapTrackingPinMixin:OnMouseClickAction(...)
	POIButtonMixin.OnClick(self, ...);
end
