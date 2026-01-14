MapHighlightDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function MapHighlightDataProviderMixin:RefreshAllData(fromOnShow)
	self.pin:Refresh();
end

function MapHighlightDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	-- a single permanent pin
	local pin = self:GetMap():AcquirePin("MapHighlightPinTemplate");
	pin:SetPosition(0.5, 0.5);
	self.pin = pin;
end

function MapHighlightDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
	self:GetMap():RemoveAllPinsByTemplate("MapHighlightPinTemplate");
end

--[[ THE Pin ]]--
MapHighlightPinMixin = CreateFromMixins(MapCanvasPinMixin);

function MapHighlightPinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_MAP_HIGHLIGHT");	
end

function MapHighlightPinMixin:OnUpdate(elapsed)
	if self:IsMouseOver() then
		self:Refresh();
	end
end

function MapHighlightPinMixin:Refresh()
	local mapID = self:GetMap():GetMapID();
	local normalizedCursorX, normalizedCursorY = self:GetMap():GetNormalizedCursorPosition();
	local fileDataID, atlasID, texPercentageX, texPercentageY, textureX, textureY, scrollChildX, scrollChildY = C_Map.GetMapHighlightInfoAtPosition(mapID, normalizedCursorX, normalizedCursorY);
	if (fileDataID and fileDataID > 0) or (atlasID) then
		self.HighlightTexture:SetTexCoord(0, texPercentageX, 0, texPercentageY);
		local width = self:GetWidth();
		local height = self:GetHeight();
		self.HighlightTexture:ClearAllPoints();
		if (atlasID) then
			self.HighlightTexture:SetAtlas(atlasID, true, "TRILINEAR");
			scrollChildX = ((scrollChildX + 0.5*textureX) - 0.5) * width;
			scrollChildY = -((scrollChildY + 0.5*textureY) - 0.5) * height;
			self.HighlightTexture:SetPoint("CENTER", scrollChildX, scrollChildY);
			self.HighlightTexture:Show();
		else
			self.HighlightTexture:SetTexture(fileDataID, nil, nil, "TRILINEAR");
			textureX = textureX * width;
			textureY = textureY * height;
			scrollChildX = scrollChildX * width;
			scrollChildY = -scrollChildY * height;
			if textureX > 0 and textureY > 0 then
				self.HighlightTexture:SetWidth(textureX);
				self.HighlightTexture:SetHeight(textureY);
				self.HighlightTexture:SetPoint("TOPLEFT", scrollChildX, scrollChildY);
				self.HighlightTexture:Show();
			end
		end
	else
		self.HighlightTexture:Hide();
	end
end

function MapHighlightPinMixin:OnCanvasSizeChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
end