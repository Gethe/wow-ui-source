BaseMapPoiPinMixin = CreateFromMixins(MapCanvasPinMixin);

--[[static]] function BaseMapPoiPinMixin:CreateSubPin(pinFrameLevel)
	local subPin = CreateFromMixins(self);
	subPin.pinFrameLevel = pinFrameLevel;
	return subPin;
end

function BaseMapPoiPinMixin:OnLoad()
	self:SetScalingLimits(1, 1.0, 1.2);
	if self.pinFrameLevel then
		self:UseFrameLevelType(self.pinFrameLevel);
	end
end

local ATLAS_WITH_TEXTURE_KIT_PREFIX = "%s-%s";
function BaseMapPoiPinMixin:SetTexture(poiInfo)
	poiInfo = poiInfo or self:GetPoiInfo();
	local atlasName = poiInfo.atlasName;
	if atlasName then
		if poiInfo.textureKit then
			atlasName = ATLAS_WITH_TEXTURE_KIT_PREFIX:format(poiInfo.textureKit, atlasName);
		end

		self.Texture:SetAtlas(atlasName, true);
		if self.HighlightTexture then
			self.HighlightTexture:SetAtlas(atlasName, true);
		end

		local sizeX, sizeY = self.Texture:GetSize();
		if self.HighlightTexture then
			self.HighlightTexture:SetSize(sizeX, sizeY);
		end
		self:SetSize(sizeX, sizeY);

		self.Texture:SetTexCoord(0, 1, 0, 1);
		if self.HighlightTexture then
			self.HighlightTexture:SetTexCoord(0, 1, 0, 1);
		end
	else
		self:SetSize(32, 32);
		self.Texture:SetWidth(16);
		self.Texture:SetHeight(16);
		self.Texture:SetTexture("Interface/Minimap/POIIcons");
		if self.HighlightTexture then
			self.HighlightTexture:SetTexture("Interface/Minimap/POIIcons");
		end

		local x1, x2, y1, y2 = C_Minimap.GetPOITextureCoords(poiInfo.textureIndex);
		self.Texture:SetTexCoord(x1, x2, y1, y2);
		if self.HighlightTexture then
			self.HighlightTexture:SetTexCoord(x1, x2, y1, y2);
		end
	end
end

function BaseMapPoiPinMixin:OnAcquired(poiInfo)
	self.poiInfo = poiInfo;
	self.name = poiInfo.name;
	self.description = poiInfo.description;
	self.tooltipWidgetSet = poiInfo.tooltipWidgetSet;
	self.iconWidgetSet = poiInfo.iconWidgetSet;
	self.textureKit = poiInfo.uiTextureKit;

	self:SetDataProvider(poiInfo.dataProvider);
	self:SetTexture(poiInfo);
	self:SetPosition(poiInfo.position:GetXY());
end

function BaseMapPoiPinMixin:GetPoiInfo()
	return self.poiInfo;
end

function BaseMapPoiPinMixin:OnMouseEnter()
	if self.name then
		self:GetMap():TriggerEvent("SetAreaLabel", MAP_AREA_LABEL_TYPE.POI, self.name, self.description);
	end
	if self.OnLegendPinMouseEnter then
		self:OnLegendPinMouseEnter();
	end
end

function BaseMapPoiPinMixin:OnMouseLeave()
	self:GetMap():TriggerEvent("ClearAreaLabel", MAP_AREA_LABEL_TYPE.POI);

	if self.OnLegendPinMouseLeave then
		self:OnLegendPinMouseLeave();
	end
end

MapPinAnimatedHighlightMixin = {};

function MapPinAnimatedHighlightMixin:SetPulseCount(pulseCount)
	self.pulseCount = pulseCount;
end

function MapPinAnimatedHighlightMixin:SetMaxPulseCount(maxPulseCount)
	self.maxPulseCount = maxPulseCount;
end

function MapPinAnimatedHighlightMixin:CheckEndPulses(forceEnd)
	if (forceEnd or self.pulseCount >= self.maxPulseCount) then
		local parent = self:GetParent();
		if parent.AcknowledgeGlow then
			parent:AcknowledgeGlow();
		else
			self:EndBackgroundPulses();
		end

		return true;
	end

	return false;
end

function MapPinAnimatedHighlightMixin:EndBackgroundPulses()
	self.pulseCount = self.maxPulseCount;

	self.PulseBackground:Stop();
	self.BackHighlight:Hide();
	self.TopHighlight:Hide();
end

function MapPinAnimatedHighlightMixin:SetHighlightShown(shown, texture, params)
	self:SetShown(shown);
	self.BackHighlight:SetShown(shown);
	self.TopHighlight:SetShown(shown);

	if shown then
		local w, h = texture:GetSize();

		local backgroundPadding = (params and params.backgroundPadding) or 10;

		self.BackHighlight:SetSize(w + backgroundPadding, h + backgroundPadding);
		self.TopHighlight:SetSize(w + 10, h + 10);

		local animType = self:GetParent():GetHighlightAnimType();
		if animType == MapPinHighlightAnimType.ExpandAndFade then
			self.Expand:SetSize(w, h);
			self.Expand = self.BackHighlight;
			local atlas = texture:GetAtlas();
			if atlas then
				self.Expand:SetTexCoord(0, 1, 0, 1);
				self.Expand:SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
			else
				self.Expand:SetTexture(texture:GetTexture());
				self.Expand:SetTexCoord(texture:GetTexCoord());
			end
			self.ExpandAndFade:Play();
		elseif animType == MapPinHighlightAnimType.BackgroundPulse then
			-- Defaulting to 5 pulses, but we can change this dynamically if we want
			self.pulseCount = 1;
			self.maxPulseCount = 5;

			if not self:CheckEndPulses() then
				self.PulseBackground:Play();
			end

			local function OnPulseLoop()
				if self:CheckEndPulses() then
					return;
				end

				self:SetPulseCount(self.pulseCount + 1);
			end
			self.PulseBackground:SetScript("OnLoop", OnPulseLoop);
		end
	end
end

MapPinHighlightType = EnumUtil.MakeEnum(
	"None",
	"BountyRing",				-- Golden ring around the pin, used by the Emissary/Bounty Board, not really used any more after a consistency pass on quest pins
	"SupertrackedHighlight",		-- Blue glow + animated icon pulse, used by Covenant Callings and the World Map Activity Tracker
	"DreamsurgeHighlight",			-- Green glow + animated icon pulse, used by the Dreamsurge event
	"ImportantHubQuestHighlight"	-- Animated background glow, used by Quest Hub with important (manually specified) quests
);

local function isAnimatedHighlightType(highlightType)
	return highlightType == MapPinHighlightType.SupertrackedHighlight or highlightType == MapPinHighlightType.DreamsurgeHighlight or highlightType == MapPinHighlightType.ImportantHubQuestHighlight;
end

MapPinHighlightAnimType = EnumUtil.MakeEnum(
	"ExpandAndFade",	-- Expands and fades the MapPoi icon, and shows a glow texture
	"BackgroundPulse"	-- Pulses a background glow a specified number of times
);

function MapPinHighlight_CreateAnimatedHighlightIfNeeded(parentPin, highlightType)
	if not isAnimatedHighlightType(highlightType) or parentPin.AnimatedHighlight then
		return;
	end

	local frame = CreateFrame("Frame", nil, parentPin, "MapPinAnimatedHighlightTemplate");
	parentPin.AnimatedHighlight = frame;
	frame:SetPoint("CENTER");

	frame.BackHighlight:SetParent(parentPin)
	frame.BackHighlight:SetDrawLayer("BACKGROUND", -8);

	frame.TopHighlight:SetParent(parentPin)
	frame.TopHighlight:SetDrawLayer("OVERLAY", 7);
end

local animatedHighlightTypeTextureKits =
{
	[MapPinHighlightType.SupertrackedHighlight] = "callings",
	[MapPinHighlightType.DreamsurgeHighlight] = "dreamsurge",
	[MapPinHighlightType.ImportantHubQuestHighlight] = "dreamsurge",
};

local animatedHighlightTextureKitRegionInfo = {
	["BackHighlight"] = "%s-backhighlight-full",
	["TopHighlight"] = "%s-tophighlight",
}

function MapPinHighlight_UpdateAnimatedHighlight(highlightType, parentPin, regionToHighlight, params)
	MapPinHighlight_CreateAnimatedHighlightIfNeeded(parentPin, highlightType);

	if parentPin.AnimatedHighlight then
		local showHighlight = isAnimatedHighlightType(highlightType);
		if showHighlight then
			local textureKit = animatedHighlightTypeTextureKits[highlightType];
			if textureKit ~= parentPin.AnimatedHighlight.textureKit then
				SetupTextureKitOnRegions(textureKit, parentPin.AnimatedHighlight, animatedHighlightTextureKitRegionInfo, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
				parentPin.AnimatedHighlight.textureKit = textureKit;
			end
		end

		parentPin.AnimatedHighlight:SetHighlightShown(showHighlight, regionToHighlight, params);
	end
end

function MapPinHighlight_CheckHighlightPin(highlightType, parentPin, regionToHighlight, params)
	if not parentPin then
		return;
	end

	if parentPin.BountyRing then
		parentPin.BountyRing:SetShown(highlightType == MapPinHighlightType.BountyRing);
	end

	MapPinHighlight_UpdateAnimatedHighlight(highlightType, parentPin, regionToHighlight, params);
end

function ClearCachedActivitiesForPlayer()
	ClearCachedQuestsForPlayer();
	ClearCachedAreaPOIsForPlayer();
end

-- Cache for C_TaskQuest.GetQuestsForPlayerByMapID
local questCache = {};
function GetQuestsForPlayerByMapIDCached(mapID)
	local entry = questCache[mapID];
	if entry then
		return entry;
	end

	local quests = C_TaskQuest.GetQuestsForPlayerByMapID(mapID);
	questCache[mapID] = quests;
	return quests;
end

function ClearCachedQuestsForPlayer()
	questCache = {};
end

-- Cache for C_AreaPoiInfo.GetAreaPOIForMap
local areaPOICache = {};
function GetAreaPOIsForPlayerByMapIDCached(mapID)
	local entry = areaPOICache[mapID];
	if entry then
		return entry;
	end

	local areaPOIs = C_AreaPoiInfo.GetAreaPOIForMap(mapID);
	areaPOICache[mapID] = areaPOIs;
	return areaPOIs;
end

function ClearCachedAreaPOIsForPlayer()
	areaPOICache = {};
end

--[[ Pin Ping ]]--
MapPinPingMixin = CreateFromMixins(MapCanvasPinMixin);

function MapPinPingMixin:OnLoad()
	self:SetScalingLimits(1, 0.65, 0.65);
	self.numLoops = 1;
end

function MapPinPingMixin:SetNumLoops(numLoops)
	self.numLoops = numLoops;
end

function MapPinPingMixin:SetID(id)
	self.id = id;
end

function MapPinPingMixin:GetID(id)
	return self.id;
end

function MapPinPingMixin:PlayAt(x, y)
	if x and y then
		self:Show();
		self:SetPosition(x, y);
		self.currentLoop = self.numLoops;
		self:PlayLoop();
	else
		self:Stop();
	end
end

function MapPinPingMixin:PlayLoop()
	self.currentLoop = self.currentLoop - 1;
	self.DriverAnimation:Play();
	self.ScaleAnimation:Play();
end

function MapPinPingMixin:HasLoopsLeft()
	return self.currentLoop > 0;
end

function MapPinPingMixin:Stop()
	self.currentLoop = 0;
	self.DriverAnimation:Stop();
	self.ScaleAnimation:Stop();
	self:Clear();
end

function MapPinPingMixin:Clear()
	self:Hide();
	self.id = nil;
end

MapPinPingDriverAnimationMixin = {};

function MapPinPingDriverAnimationMixin:OnFinished()
	local ping = self:GetParent();
	ping.ScaleAnimation:Stop();
	if ping:HasLoopsLeft() then
		ping:PlayLoop();
	else
		ping:Clear();
	end
end

-- NOTE: Mouse scripts are managed entirely through MapCanvasMixin:AcquirePin.
SuperTrackablePinMixin = {};

function SuperTrackablePinMixin:IsSuperTrackingExternallyHandled()
	-- Exists because Events need to implement both AreaPOIPin and POIButton
	-- and POIButton handles the supertracking with custom textures.
	-- By default, anything that actually uses SuperTrackablePinMixin
	-- should handle its own supertracking, but event pins do no
	return false;
end

function SuperTrackablePinMixin:IsSuperTrackAction(button, action)
	return button == "LeftButton" and action == MapCanvasMixin.MouseAction.Click;
end

function SuperTrackablePinMixin:DoesMapTypeAllowSuperTrack()
	local mapInfo = C_Map.GetMapInfo(self:GetMap():GetMapID());
	if mapInfo then
		-- Pins on maps above zone level shouldn't be super-trackable, because it makes it too hard to zoom in to the zone map.
		return mapInfo.mapType >= Enum.UIMapType.Zone;
	end

	return false;
end

function SuperTrackablePinMixin:UpdateMousePropagation()
	self:SetPropagateMouseClicks(not self:DoesMapTypeAllowSuperTrack());
end

function SuperTrackablePinMixin:OnAcquired(...)
	if not self:IsSuperTrackingExternallyHandled() then
		self:UpdateMousePropagation();
		self:UpdateSuperTrackedState(C_SuperTrack[self:GetSuperTrackAccessorAPIName()]());
	end
end

function SuperTrackablePinMixin:OnMouseDownAction(button)

end

function SuperTrackablePinMixin:OnMouseUpAction(button, upInside)

end

function SuperTrackablePinMixin:OnMouseClickAction(button)
	if self:IsSuperTrackAction(button, MapCanvasMixin.MouseAction.Click) and self:DoesMapTypeAllowSuperTrack() then
		C_SuperTrack[self:GetSuperTrackMutatorAPIName()](self:GetSuperTrackData());
	end
end

function SuperTrackablePinMixin:SuperTrack_OnShow()
	EventRegistry:RegisterCallback("Supertracking.OnChanged", self.OnSuperTrackingChanged, self);
end

function SuperTrackablePinMixin:SuperTrack_OnHide()
	EventRegistry:UnregisterCallback("Supertracking.OnChanged", self);
end

function SuperTrackablePinMixin:OnSuperTrackingChanged(manager)
	self:UpdateSuperTrackedState(manager[self:GetSuperTrackAccessorAPIName()](manager));
end

function SuperTrackablePinMixin:UpdateSuperTrackedState(...)
	self:SetSuperTracked(self:DoesSuperTrackDataMatch(...));
end

function SuperTrackablePinMixin:SetSuperTracked(superTracked)
	if self.superTracked ~= superTracked then
		self.superTracked = superTracked;

		-- Defer anchoring to side-step inheritance issues (i.e. needing to define self.Texture before the supertrack textures).
		self:UpdateSuperTrackTextureAnchors();

		self.SuperTrackGlow:SetShown(superTracked);
		self.SuperTrackMarker:SetShown(superTracked);
	end
end

function SuperTrackablePinMixin:IsSuperTracked()
	return self.superTracked;
end

function SuperTrackablePinMixin:UpdateSuperTrackTextureAnchors()
	-- override
	if self:IsSuperTracked() and not self.isAnchored then
		self.isAnchored = true;
		self.SuperTrackGlow:ClearAllPoints();
		self.SuperTrackGlow:SetPoint("TOPLEFT", self.Texture, "TOPLEFT", -18, 18);
		self.SuperTrackGlow:SetPoint("BOTTOMRIGHT", self.Texture, "BOTTOMRIGHT", 18, -18);

		self.SuperTrackMarker:ClearAllPoints();
		self.SuperTrackMarker:SetPoint("CENTER", self.Texture, "BOTTOMRIGHT", -5, 5);
	end
end

function SuperTrackablePinMixin:GetSuperTrackData()
	return nil; -- override
end

function SuperTrackablePinMixin:GetSuperTrackAccessorAPIName()
	return "GetSuperTrackedMapPin"; -- override
end

function SuperTrackablePinMixin:GetSuperTrackMutatorAPIName()
	return "SetSuperTrackedMapPin"; -- override
end

function SuperTrackablePinMixin:DoesSuperTrackDataMatch(...)
	-- override
	local pinType, pinTypeID = select(1, ...);
	local myPinType, myPinTypeID = self:GetSuperTrackData();
	if myPinType and myPinTypeID then
		return pinType == myPinType and pinTypeID == myPinTypeID;
	end

	return false;
end

SuperTrackablePoiPinMixin = CreateFromMixins(SuperTrackablePinMixin);

function SuperTrackablePoiPinMixin:OnAcquired(...)
	BaseMapPoiPinMixin.OnAcquired(self, ...);
	SuperTrackablePinMixin.OnAcquired(self, ...);
end

function SuperTrackablePoiPinMixin:GetSuperTrackData()
	return Enum.SuperTrackingMapPinType.AreaPOI, self.poiInfo.areaPoiID;
end

LegendHighlightablePoiPinMixin = {};

function LegendHighlightablePoiPinMixin:ShowMapLegendGlow()
	if not self.LegendGlow then
        local glow = self:CreateTexture(nil, "BACKGROUND");
        if self.Glow then
            glow:SetPoint("TOPLEFT", self.Glow, "TOPLEFT");
            glow:SetPoint("BOTTOMRIGHT", self.Glow, "BOTTOMRIGHT");
        else
            glow:SetPoint("TOPLEFT", self, "TOPLEFT", -18, 18);
            glow:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 18, -18);
        end
        glow:SetAtlas("UI-QuestPoi-OuterGlow");
        self.LegendGlow = glow;
    end
    self.LegendGlow:Show();
end

function LegendHighlightablePoiPinMixin:HideMapLegendGlow()
	self.LegendGlow:Hide();
end

function LegendHighlightablePoiPinMixin:OnLegendPinMouseEnter()
	EventRegistry:TriggerEvent("MapLegendPinOnEnter", self);
end

function LegendHighlightablePoiPinMixin:OnLegendPinMouseLeave()
	EventRegistry:TriggerEvent("MapLegendPinOnLeave", nil);
end
