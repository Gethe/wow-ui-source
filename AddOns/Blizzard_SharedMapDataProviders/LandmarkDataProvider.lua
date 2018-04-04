
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
		or landmarkType == LE_MAP_LANDMARK_TYPE_GOSSIP
		or landmarkType == LE_MAP_LANDMARK_TYPE_TAXINODE
		or landmarkType == LE_MAP_LANDMARK_TYPE_VIGNETTE
		or landmarkType == LE_MAP_LANDMARK_TYPE_INVASION
		or landmarkType == LE_MAP_LANDMARK_TYPE_CONTRIBUTION
		or landmarkType == LE_MAP_LANDMARK_TYPE_MAP_LINK;
end

local function ShouldShowAreaLabel(poi)
	if poi.landmarkType == LE_MAP_LANDMARK_TYPE_CONTRIBUTION or poi.landmarkType == LE_MAP_LANDMARK_TYPE_INVASION or poi.useMouseOverTooltip then
		return false;
	end
	if poi.poiID and C_WorldMap.IsAreaPOITimed(poi.poiID) then
		return false;
	end

	return true;
end

LandmarkDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

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
	for i = 1, GetNumMapLandmarks() do
		local landmarkType, name, description, textureIndex, x, y, mapLinkID, inBattleMap, graveyardID, areaID, poiID, isObjectIcon, atlasIcon, displayAsBanner, textureKitPrefix, useMouseOverTooltip = C_WorldMap.GetMapLandmarkInfo(i);
		if displayAsBanner then
			local timeLeftMinutes = C_WorldMap.GetAreaPOITimeLeft(poiID);
			local descriptionLabel = nil;
			if timeLeftMinutes then
				local hoursLeft = math.floor(timeLeftMinutes / 60);
				local minutesLeft = timeLeftMinutes % 60;
				descriptionLabel = INVASION_TIME_FORMAT:format(hoursLeft, minutesLeft)
			end

			local atlas, width, height = GetAtlasInfo(atlasIcon);
			local areaPOIBannerLabelTextureInfo = {};
			areaPOIBannerLabelTextureInfo.atlas = atlasIcon;
			areaPOIBannerLabelTextureInfo.width = width;
			areaPOIBannerLabelTextureInfo.height = height;
			self:GetMap():TriggerEvent("SetAreaLabel", MAP_AREA_LABEL_TYPE.AREA_POI_BANNER, name, descriptionLabel, INVASION_FONT_COLOR, INVASION_DESCRIPTION_FONT_COLOR, areaPOIBannerLabelTextureInfo);
		elseif WorldMap_ShouldShowLandmark(landmarkType) and (mapID ~= WINTERGRASP_UI_MAP_ID or areaID == WINTERGRASP_POI_AREAID) then
			local poiPin;
			local isGraveyard = graveyardID and graveyardID > 0;
			if isGraveyard then
				poiPin = self:GetMap():AcquirePin("GraveyardPinTemplate", i);
				poiPin.graveyardID = graveyardID;
			elseif landmarkType == LE_MAP_LANDMARK_TYPE_MAP_LINK then
				poiPin = self:GetMap():AcquirePin("MapLinkPinTemplate", i);
			elseif landmarkType == LE_MAP_LANDMARK_TYPE_DUNGEON_ENTRANCE then
				poiPin = self:GetMap():AcquirePin("DungeonEntrancePinTemplate", i);
			else
				poiPin = self:GetMap():AcquirePin("LandmarkPinTemplate", i);
			end
			
			poiPin:SetPosition(x, y);
		end
	end
end

function LandmarkDataProviderMixin:OnMapChanged()
	self:RefreshAllData();
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
	local landmarkType, name, description, textureIndex, x, y, mapLinkID, inBattleMap, graveyardID, areaID, poiID, isObjectIcon, atlasIcon, displayAsBanner, textureKitPrefix, useMouseOverTooltip = C_WorldMap.GetMapLandmarkInfo(self.landmarkIndex);
	self.name = name;
	self.description = description;
	self.mapLinkID = mapLinkID;
	self.poiID = poiID;
	self.landmarkType = landmarkType;
	self.textureKitPrefix = textureKitPrefix;
	self.useMouseOverTooltip = useMouseOverTooltip;
	
	self:SetTexture(atlasIcon, textureKitPrefix, isObjectIcon, textureIndex);
end

local ATLAS_WITH_TEXTURE_KIT_PREFIX = "%s-%s";
function LandmarkPinMixin:SetTexture(atlasIcon, textureKitPrefix, isObjectIcon, textureIndex)
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
	elseif isObjectIcon then
		self:SetSize(32, 32);
		self:SetWidth(32);
		self:SetHeight(32);
		self.Texture:SetWidth(28);
		self.Texture:SetHeight(28);
		self.Texture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
		self.HighlightTexture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
		
		local x1, x2, y1, y2 = GetObjectIconTextureCoords(textureIndex);
		self.Texture:SetTexCoord(x1, x2, y1, y2);
		self.HighlightTexture:SetTexCoord(x1, x2, y1, y2);
	else
		self:SetSize(32, 32);
		self:SetWidth(32);
		self:SetHeight(32);
		self.Texture:SetWidth(16);
		self.Texture:SetHeight(16);
		self.Texture:SetTexture("Interface\\Minimap\\POIIcons");
		self.HighlightTexture:SetTexture("Interface\\Minimap\\POIIcons");
		
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

	if self.landmarkType == LE_MAP_LANDMARK_TYPE_INVASION then
		local name, timeLeftMinutes, rewardQuestID = GetInvasionInfo(self.poiID);

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(name, HIGHLIGHT_FONT_COLOR:GetRGB());

		if timeLeftMinutes and timeLeftMinutes > 0 then
			local timeString = SecondsToTime(timeLeftMinutes * 60);
			GameTooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(timeString), NORMAL_FONT_COLOR:GetRGB());
		end

		if rewardQuestID then
			if not HaveQuestData(rewardQuestID) then
				GameTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
			else
				GameTooltip_AddQuestRewardsToTooltip(GameTooltip, rewardQuestID);
			end
		end

		GameTooltip:Show();
	elseif self.landmarkType == LE_MAP_LANDMARK_TYPE_CONTRIBUTION then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.name, HIGHLIGHT_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(" ");

		-- TODO:: Stop relying on world map poi tooltip helpers.
		WorldMapPOI_AddContributionsToTooltip(GameTooltip, C_ContributionCollector.GetManagedContributionsForCreatureID(self.mapLinkID));

		GameTooltip:Show();
	elseif self.landmarkType == LE_MAP_LANDMARK_TYPE_VIGNETTE and self.useMouseOverTooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(self.name));
		if self.description then
			GameTooltip:AddLine(NORMAL_FONT_COLOR:WrapTextInColorCode(self.description));
		end
		GameTooltip:Show();
	else
		if WarfrontTooltipController:HandleTooltip(GameTooltip, self, self.poiID, self.name, self.description) then
			return;
		end
		
		local name = self.name;
		local description = self.description;
		if name and #name > 0 and description and #description > 0 and C_WorldMap.IsAreaPOITimed(self.poiID) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(name));
			GameTooltip:AddLine(NORMAL_FONT_COLOR:WrapTextInColorCode(description));
			local timeLeftMinutes = C_WorldMap.GetAreaPOITimeLeft(self.poiID);
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