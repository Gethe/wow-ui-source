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

		local x1, x2, y1, y2 = GetPOITextureCoords(poiInfo.textureIndex);
		self.Texture:SetTexCoord(x1, x2, y1, y2);
		if self.HighlightTexture then
			self.HighlightTexture:SetTexCoord(x1, x2, y1, y2);
		end
	end
end

function BaseMapPoiPinMixin:OnAcquired(poiInfo)
	self:SetTexture(poiInfo);

	self.name = poiInfo.name;
	self.description = poiInfo.description;
	self.widgetSetID = poiInfo.widgetSetID;
	self.textureKit = poiInfo.uiTextureKit;

	self:SetPosition(poiInfo.position:GetXY());
end

function BaseMapPoiPinMixin:OnMouseEnter()
	if self.name then
		self:GetMap():TriggerEvent("SetAreaLabel", MAP_AREA_LABEL_TYPE.POI, self.name, self.description);
	end
end

function BaseMapPoiPinMixin:OnMouseLeave()
	self:GetMap():TriggerEvent("ClearAreaLabel", MAP_AREA_LABEL_TYPE.POI);
end

MapPinSupertrackHighlightMixin = {};

function MapPinSupertrackHighlightMixin:SetHighlightShown(shown, texture, params)
	self:SetShown(shown);
	self.BackHighlight:SetShown(shown);
	self.TopHighlight:SetShown(shown);

	if shown then
		local w, h = texture:GetSize();
		self.Expand:SetSize(w, h);

		local backgroundPadding = (params and params.backgroundPadding) or 10;

		self.BackHighlight:SetSize(w + backgroundPadding, h + backgroundPadding);
		self.TopHighlight:SetSize(w + 10, h + 10);

		local atlas = texture:GetAtlas();
		if atlas then
			self.Expand:SetTexCoord(0, 1, 0, 1);
			self.Expand:SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
		else
			self.Expand:SetTexture(texture:GetTexture());
			self.Expand:SetTexCoord(texture:GetTexCoord());
		end

		self.ExpandAndFade:Play();
	end
end

function MapPinHighlight_CheckHighlightPin(highlight, parentPin, regionToHighlight, params)
	if highlight and not parentPin.SupertrackedHighlight then
		local frame = CreateFrame("Frame", nil, parentPin, "MapPinSupertrackHighlightTemplate");
		parentPin.SupertrackedHighlight = frame;
		frame:SetPoint("CENTER");

		frame.BackHighlight:SetParent(parentPin)
		frame.BackHighlight:SetDrawLayer("BACKGROUND", -8);

		frame.TopHighlight:SetParent(parentPin)
		frame.TopHighlight:SetDrawLayer("OVERLAY", 7);
	end

	if parentPin.SupertrackedHighlight then
		parentPin.SupertrackedHighlight:SetHighlightShown(highlight, regionToHighlight, params);
	end
end