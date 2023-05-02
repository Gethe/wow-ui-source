MapHighlightDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function MapHighlightDataProviderMixin:RefreshAllData(fromOnShow)
	self.pin:SetupHighlightPulse();
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
	self:GetMap():RemoveAllPinsByTemplate("MapHighlightPinTemplate");

	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end

--[[ THE Pin ]]--
MapHighlightPinMixin = CreateFromMixins(MapCanvasPinMixin);

function MapHighlightPinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_MAP_HIGHLIGHT");
end

function MapHighlightPinMixin:OnUpdate(elapsed)
	if self:IsMouseOver() then
		self:Refresh();

		if self.handledMouseLeave then
			self.handledMouseLeave = false;
		end
	elseif not self.handledMouseLeave then
		-- To prevent cases where highlight is stuck on when mouse leaves the frame.
		self.HighlightTexture:Hide();

		if self.hasPulseTexture and not self.MapPulse:IsPlaying() then
			self.PulseTexture:Show();
			self.MapPulse:Restart();
		end

		self.handledMouseLeave = true;
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

			if self.MapPulse:IsPlaying() then
				self.MapPulse:Stop();
				self.PulseTexture:Hide();
			end
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

				if self.MapPulse:IsPlaying() then
					self.MapPulse:Stop();
					self.PulseTexture:Hide();
				end
			end
		end
	else
		self.HighlightTexture:Hide();

		if self.hasPulseTexture and not self.MapPulse:IsPlaying() then
			self.PulseTexture:Show();
			self.MapPulse:Restart();
		end
	end
end

function MapHighlightPinMixin:SetupHighlightPulse()
	local mapID = self:GetMap():GetMapID();
	local fileDataID, atlasID, texPercentageX, texPercentageY, textureX, textureY, scrollChildX, scrollChildY = C_Map.GetMapHighlightPulseInfo(mapID);

	self.hasPulseTexture = false;
	if (fileDataID and fileDataID > 0) or (atlasID) then
		self.PulseTexture:SetTexCoord(0, texPercentageX, 0, texPercentageY);
		local width = self:GetWidth();
		local height = self:GetHeight();
		self.PulseTexture:ClearAllPoints();
		if (atlasID) then
			self.PulseTexture:SetAtlas(atlasID, true, "TRILINEAR");
			scrollChildX = ((scrollChildX + 0.5*textureX) - 0.5) * width;
			scrollChildY = -((scrollChildY + 0.5*textureY) - 0.5) * height;
			self.PulseTexture:SetPoint("CENTER", scrollChildX, scrollChildY);
			self.PulseTexture:Show();

			self.MapPulse:Restart();
			self.hasPulseTexture = true;
		else
			self.PulseTexture:SetTexture(fileDataID, nil, nil, "TRILINEAR");
			textureX = textureX * width;
			textureY = textureY * height;
			scrollChildX = scrollChildX * width;
			scrollChildY = -scrollChildY * height;
			if textureX > 0 and textureY > 0 then
				self.PulseTexture:SetWidth(textureX);
				self.PulseTexture:SetHeight(textureY);
				self.PulseTexture:SetPoint("TOPLEFT", scrollChildX, scrollChildY);
				self.PulseTexture:Show();

				self.MapPulse:Restart();
				self.hasPulseTexture = true;
			end
		end
	else
		if self.MapPulse:IsPlaying() then
			self.MapPulse:Stop();
		end
		self.PulseTexture:Hide();
	end
end

function MapHighlightPinMixin:OnCanvasSizeChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
end