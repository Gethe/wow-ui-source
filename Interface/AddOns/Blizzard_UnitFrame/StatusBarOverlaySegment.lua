-- A segment of fill that displays on top of a status bar
-- Ex: Heal prediction bar, which displays on top of a unit's health bar

StatusBarOverlaySegmentMixin = {};

function StatusBarOverlaySegmentMixin:OnLoad()
	if self.fillAtlas then
		self.Fill:SetAtlas(self.fillAtlas, TextureKitConstants.IgnoreAtlasSize);
	elseif self.fillTexture then
		self.Fill:SetTexture(self.fillTexture);
	end

	if self.fillColor then
		self.Fill:SetVertexColor(self.fillColor:GetRGBA());
	end
end

function StatusBarOverlaySegmentMixin:Initialize()
	if self.initialized then
		return;
	end

	self.statusBar = self.statusBar or self:GetParent();
	if not self.statusBar or not self.statusBar.GetStatusBarTexture then
		return;
	end

	local statusBarTexture = self.statusBar:GetStatusBarTexture();
	if not statusBarTexture then
		return;
	end

	local barLayer, barSubLevel = statusBarTexture:GetDrawLayer();
	self.Fill:SetDrawLayer(barLayer, barSubLevel + 1);

	if self.fillOverlays then
		for _, overlay in ipairs(self.fillOverlays) do
			overlay:SetDrawLayer(barLayer, barSubLevel + 2);
		end
	end

	self.initialized = true;
end

function StatusBarOverlaySegmentMixin:SetStatusBar(statusBar)
	self.statusBar = statusBar;
	self:Initialize();
end

function StatusBarOverlaySegmentMixin:SetFillColor(color)
	self.fillColor = color;
	self.Fill:SetVertexColor(self.fillColor:GetRGBA());
end

-- previousTexture: Segment's left edge will be anchored to the right edge of this texture (offset by xOffsetPercent)
-- fillValue: The fill value, out of the underlying status bar's max value, that this segment is portraying; will be used to set the segment's width
-- xOffsetPercent: A percent of total status bar width to offset the segment's left anchor by; Typically used to move the segment to the left so that it overlaps previousTexture
function StatusBarOverlaySegmentMixin:UpdateFillPosition(previousTexture, fillValue, xOffsetPercent)
	-- Lazy initializing as the main StatusBar may not be ready at our OnLoad
	self:Initialize();
	if not self.initialized or fillValue == 0 then
		self:Hide();
		return previousTexture;
	end

	local barWidth, barHeight = self.statusBar:GetSize();

	local segmentOffsetX = 0;
	if xOffsetPercent then
		segmentOffsetX = barWidth * xOffsetPercent;
	end

	self.FillMask:ClearAllPoints();

	self.FillMask:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", segmentOffsetX, 0);
	self.FillMask:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", segmentOffsetX, 0);

	local maxValue = select(2, self.statusBar:GetMinMaxValues());

	local segmentSize = (fillValue / maxValue) * barWidth;
	self.FillMask:SetWidth(segmentSize);
	self:Show();

	-- If this segment has its own tiled overlay texture, update its texcoords to fit the new segment size
	if self.TiledOverlay then
		self.TiledOverlay:SetTexCoord(0, segmentSize / self.tiledOverlaySize, 0, barHeight / self.tiledOverlaySize);
		self.TiledOverlay:Show();
	end

	return self.FillMask;
end