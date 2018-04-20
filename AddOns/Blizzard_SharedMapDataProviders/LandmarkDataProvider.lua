
WINTERGRASP_UI_MAP_ID = 123;
WINTERGRASP_POI_AREAID = 4197;

local function IsVindicaarTextureKit(textureKitPrefix)
	return textureKitPrefix == "FlightMaster_VindicaarArgus" or textureKitPrefix == "FlightMaster_VindicaarStygianWake" or textureKitPrefix == "FlightMaster_VindicaarMacAree";
end

local function DoesLandMarkTypeShowHighlights(landmarkType, textureKitPrefix)
	if IsVindicaarTextureKit(textureKitPrefix) then
		return false;
	end

	return landmarkType == LE_MAP_LANDMARK_TYPE_NORMAL
		or landmarkType == LE_MAP_LANDMARK_TYPE_TAMER
		or landmarkType == LE_MAP_LANDMARK_TYPE_TAXINODE
		or landmarkType == LE_MAP_LANDMARK_TYPE_CONTRIBUTION
		or landmarkType == LE_MAP_LANDMARK_TYPE_MAP_LINK;
end

local function ShouldShowAreaLabel(poi)
	if poi.landmarkType == LE_MAP_LANDMARK_TYPE_CONTRIBUTION or poi.useMouseOverTooltip then
		return false;
	end
	if poi.poiID and C_AreaPoiInfo.IsAreaPOITimed(poi.poiID) then
		return false;
	end

	return true;
end

LandmarkDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function LandmarkDataProviderMixin:OnShow()
	self:RegisterEvent("WORLD_MAP_UPDATE");
end

function LandmarkDataProviderMixin:OnHide()
	self:UnregisterEvent("WORLD_MAP_UPDATE");
end

function LandmarkDataProviderMixin:OnEvent(event, ...)
	if event == "WORLD_MAP_UPDATE" then
		self:RefreshAllData();
	end
end

function LandmarkDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("LandmarkPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("MapLinkPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("DungeonEntrancePinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("GraveyardPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("AreaPOIBannerPinTemplate");
	self:GetMap():TriggerEvent("ClearAreaLabel", MAP_AREA_LABEL_TYPE.AREA_POI_BANNER);
end

function LandmarkDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	
	local mapID = self:GetMap():GetMapID();
	for landmarkIndex = 1, GetNumMapLandmarks() do
		local landmarkInfo = C_WorldMap.GetMapLandmarkInfo(landmarkIndex);
		if landmarkInfo then
			self:AddLandmark(landmarkIndex, landmarkInfo);
		end
	end
end

function LandmarkDataProviderMixin:AddLandmark(landmarkIndex, landmarkInfo)
	if landmarkInfo.displayAsBanner then
		local timeLeftMinutes = C_AreaPoiInfo.GetAreaPOITimeLeft(landmarkInfo.poiID);
		local descriptionLabel = nil;
		if timeLeftMinutes then
			local hoursLeft = math.floor(timeLeftMinutes / 60);
			local minutesLeft = timeLeftMinutes % 60;
			descriptionLabel = INVASION_TIME_FORMAT:format(hoursLeft, minutesLeft)
		end

		local atlas, width, height = GetAtlasInfo(landmarkInfo.atlasName);
		local areaPOIBannerLabelTextureInfo = {};
		areaPOIBannerLabelTextureInfo.atlas = landmarkInfo.atlasName;
		areaPOIBannerLabelTextureInfo.width = width;
		areaPOIBannerLabelTextureInfo.height = height;
		self:GetMap():TriggerEvent("SetAreaLabel", MAP_AREA_LABEL_TYPE.AREA_POI_BANNER, landmarkInfo.name, descriptionLabel, INVASION_FONT_COLOR, INVASION_DESCRIPTION_FONT_COLOR, areaPOIBannerLabelTextureInfo);
	elseif WorldMap_ShouldShowLandmark(landmarkInfo.landmarkType) and (landmarkInfo.mapID ~= WINTERGRASP_UI_MAP_ID or landmarkInfo.areaID == WINTERGRASP_POI_AREAID) then
		local poiPin;
		local isGraveyard = landmarkInfo.graveyardID and landmarkInfo.graveyardID > 0;
		if isGraveyard then
			poiPin = self:GetMap():AcquirePin("GraveyardPinTemplate", landmarkIndex);
			poiPin.graveyardID = landmarkInfo.graveyardID;
		elseif landmarkInfo.landmarkType == LE_MAP_LANDMARK_TYPE_MAP_LINK then
			poiPin = self:GetMap():AcquirePin("MapLinkPinTemplate", landmarkIndex);
		elseif landmarkInfo.landmarkType == LE_MAP_LANDMARK_TYPE_DUNGEON_ENTRANCE then
			poiPin = self:GetMap():AcquirePin("DungeonEntrancePinTemplate", landmarkIndex);
		else
			poiPin = self:GetMap():AcquirePin("LandmarkPinTemplate", landmarkIndex);
		end
			
		poiPin:SetPosition(landmarkInfo.x, landmarkInfo.y);
	end
end

--[[ Pin ]]--
LandmarkPinMixin = CreateFromMixins(MapCanvasPinMixin);

function LandmarkPinMixin:OnLoad()
	self:SetScalingLimits(1, 1.0, 1.2);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_LANDMARK");
end

function LandmarkPinMixin:OnAcquired(landmarkIndex)
	self:SetMouseClickEnabled(false);
	self.landmarkIndex = landmarkIndex;
	self:Refresh();
end

function LandmarkPinMixin:Refresh()
	local landmarkInfo = C_WorldMap.GetMapLandmarkInfo(self.landmarkIndex);
	self.name = landmarkInfo.name;
	self.description = landmarkInfo.description;
	self.mapLinkID = landmarkInfo.mapLinkID;
	self.poiID = landmarkInfo.poiID;
	self.landmarkType = landmarkInfo.landmarkType;
	self.textureKitPrefix = landmarkInfo.textureKitPrefix;
	self.useMouseOverTooltip = landmarkInfo.useMouseOverTooltip;
	
	self:SetTexture(landmarkInfo.atlasName, landmarkInfo.textureKitPrefix, landmarkInfo.textureIndex);
end

local ATLAS_WITH_TEXTURE_KIT_PREFIX = "%s-%s";
function LandmarkPinMixin:SetTexture(atlasIcon, textureKitPrefix, textureIndex)
	if atlasIcon then
		if textureKitPrefix then
			atlasIcon = ATLAS_WITH_TEXTURE_KIT_PREFIX:format(textureKitPrefix, atlasIcon);
		end
		
		self.Texture:SetAtlas(atlasIcon, true);
		self.HighlightTexture:SetAtlas(atlasIcon, true);

		local sizeX, sizeY = self.Texture:GetSize();
		if textureKitPrefix == "FlightMaster_Argus" then
			sizeX = 21;
			sizeY = 18;
		end
		self.Texture:SetSize(sizeX, sizeY);
		self.HighlightTexture:SetSize(sizeX, sizeY);
		self:SetSize(sizeX, sizeY);
		
		self.Texture:SetTexCoord(0, 1, 0, 1);
		self.HighlightTexture:SetTexCoord(0, 1, 0, 1);
	else
		self:SetSize(32, 32);
		self.Texture:SetSize(16, 16);
		self.Texture:SetTexture("Interface/Minimap/POIIcons");
		self.HighlightTexture:SetTexture("Interface/Minimap/POIIcons");
		
		local x1, x2, y1, y2 = GetPOITextureCoords(textureIndex);
		self.Texture:SetTexCoord(x1, x2, y1, y2);
		self.HighlightTexture:SetTexCoord(x1, x2, y1, y2);
	end
end

function LandmarkPinMixin:OnMouseEnter()
	self.UpdateTooltip = function() self:OnMouseEnter(); end;
	self.HighlightTexture:SetShown(DoesLandMarkTypeShowHighlights(self.landmarkType, self.textureKitPrefix));

	if ShouldShowAreaLabel(self) then
		self:GetMap():TriggerEvent("SetAreaLabel", MAP_AREA_LABEL_TYPE.POI, self.name, self.description);
	end

	if self.landmarkType == LE_MAP_LANDMARK_TYPE_CONTRIBUTION then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.name, HIGHLIGHT_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(" ");

		-- TODO:: Stop relying on world map poi tooltip helpers.
		WorldMapPOI_AddContributionsToTooltip(GameTooltip, C_ContributionCollector.GetManagedContributionsForCreatureID(self.mapLinkID));

		GameTooltip:Show();
	else
		if WarfrontTooltipController:HandleTooltip(GameTooltip, self, self.poiID, self.name, self.description) then
			return;
		end
		
		local name = self.name;
		local description = self.description;
		if name and #name > 0 and description and #description > 0 and C_AreaPoiInfo.IsAreaPOITimed(self.poiID) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(name));
			GameTooltip:AddLine(NORMAL_FONT_COLOR:WrapTextInColorCode(description));
			local timeLeftMinutes = C_AreaPoiInfo.GetAreaPOITimeLeft(self.poiID);
			if timeLeftMinutes then
				local timeString = SecondsToTime(timeLeftMinutes * 60);
				GameTooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(timeString), NORMAL_FONT_COLOR:GetRGB());
			end
			GameTooltip:Show();
		end
	end
end

function LandmarkPinMixin:OnMouseLeave()
	self.HighlightTexture:Hide();
	self:GetMap():TriggerEvent("ClearAreaLabel", MAP_AREA_LABEL_TYPE.POI);

	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

ClickableLandmarkPinMixin = {};

function ClickableLandmarkPinMixin:OnAcquired(landmarkIndex)
	LandmarkPinMixin.OnAcquired(self, landmarkIndex);
	self:SetMouseClickEnabled(true);
end

MapLinkPinMixin = CreateFromMixins(ClickableLandmarkPinMixin);

function MapLinkPinMixin:OnClick()
	self:GetMap():SetMapID(self.mapLinkID);
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
end

DungeonEntrancePinMixin = CreateFromMixins(ClickableLandmarkPinMixin);

function DungeonEntrancePinMixin:OnClick()
	EncounterJournal_LoadUI();
	EncounterJournal_OpenJournal(nil, self.mapLinkID);
end

GraveyardPinMixin = CreateFromMixins(ClickableLandmarkPinMixin);

function GraveyardPinMixin:OnShow()
	self:RegisterEvent("CEMETERY_PREFERENCE_UPDATED");
end

function GraveyardPinMixin:OnHide()
	self:UnregisterEvent("CEMETERY_PREFERENCE_UPDATED");
end

function GraveyardPinMixin:OnEvent()
	self:Refresh();
end

function GraveyardPinMixin:Refresh()
	LandmarkPinMixin.Refresh(self);
	if GetCemeteryPreference() == self.graveyardID then
		self.Background:SetTexture("Interface\\WorldMap\\GravePicker-Selected");
	else
		self.Background:SetTexture("Interface\\WorldMap\\GravePicker-Unselected");
	end
end

function GraveyardPinMixin:OnMouseEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local r, g, b = HIGHLIGHT_FONT_COLOR:GetRGB();

	if self.graveyardID == GetCemeteryPreference() then
		GameTooltip:SetText(GRAVEYARD_SELECTED);
		GameTooltip:AddLine(GRAVEYARD_SELECTED_TOOLTIP, r, g, b, true);
	else
		GameTooltip:SetText(GRAVEYARD_ELIGIBLE);
		GameTooltip:AddLine(GRAVEYARD_ELIGIBLE_TOOLTIP, r, g, b, true);
	end

	GameTooltip:Show();
	
	self.HighlightTexture:Show();
end

function GraveyardPinMixin:OnMouseLeave()
	self.HighlightTexture:Hide();

	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

function GraveyardPinMixin:OnClick()
	SetCemeteryPreference(self.graveyardID);
end