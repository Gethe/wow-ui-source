AdventureMapInsetMixin = {};

local TILE_WIDTH = 256;
local TILE_HEIGHT = 256;
local TILE_SCALE = .75;
local EFFECTIVE_TILE_WIDTH = TILE_WIDTH * TILE_SCALE;
local EFFECTIVE_TILE_HEIGHT = TILE_HEIGHT * TILE_SCALE;
local WIDTH_INSET = 22 * TILE_SCALE;
local HEIGHT_INSET = 100 * TILE_SCALE;
local TILES_PER_ROW = 4;

function AdventureMapInsetMixin:Initialize(mapCanvas, collapsed, insetIndex, mapID, title, description, collapsedIcon, numDetailTiles, normalizedX, normalizedY)
	self.mapCanvas = mapCanvas;
	self.insetIndex = insetIndex;
	self.mapID = mapID;

	local width = TILES_PER_ROW * EFFECTIVE_TILE_WIDTH - WIDTH_INSET;
	local height = math.floor(numDetailTiles / TILES_PER_ROW) * EFFECTIVE_TILE_HEIGHT - HEIGHT_INSET;

	self:SetSize(width, height);
	self.ExpandedFrame:SetSize(width, height);

	self.collapsed = collapsed;
	self.ExpandedFrame:SetAlpha(self.collapsed and 0.0 or 1.0);
	self.CollapsedFrame:SetAlpha(self.collapsed and 1.0 or 0.0);
	self.ExpandedFrame:SetShown(not self.collapsed);
	self.CollapsedFrame:SetShown(self.collapsed);
	self.CollapsedFrame.Text:SetText(string.upper(title));
	self.CollapsedFrame.TextBackground:SetWidth(self.CollapsedFrame.Text:GetWidth() + 15);
	self.CollapsedFrame.Icon:SetAtlas(collapsedIcon, true);

	local collapsedInfo = C_Texture.GetAtlasInfo(collapsedIcon);
	local collapsedIconWidth = collapsedInfo and collapsedInfo.width or 0;
	local collapsedIconHeight = collapsedInfo and collapsedInfo.height or 0;
	self.CollapsedFrame:SetSize(collapsedIconWidth, collapsedIconHeight);

	self.normalizedX = normalizedX;
	self.normalizedY = normalizedY;

	self:BuildDetailTiles(insetIndex, tileIndex, numDetailTiles)

	self.ExpandedFrame.CloseButton:SetScale(1.0 / self:GetMap():GetScaleForMaxZoom());

	if self.normalizedX and self.normalizedY then
		local canvas = self:GetMap():GetCanvas();
		local scale = self:GetScale();
		self:SetPoint("CENTER", canvas, "TOPLEFT", (canvas:GetWidth() * self.normalizedX) / scale, -(canvas:GetHeight() * self.normalizedY) / scale);
	end

	self:Show();

	self:GetMap():OnMapInsetSizeChanged(self.mapID, self.insetIndex, not self.collapsed);
end

function AdventureMapInsetMixin:OnReleased()
	self.CollapseExpandAnim:Stop();
	if self.detailTilePool then
		self.detailTilePool:ReleaseAll();
	end

	if self.areaTrigger then
		self:GetMap():ReleaseAreaTrigger("AdventureMap_MapInset", self.areaTrigger)
		self.areaTrigger = nil;
	end
	self:Hide();
end

function AdventureMapInsetMixin:BuildDetailTiles(insetIndex, tileIndex, numDetailTiles)
	if not self.detailTilePool then
		self.detailTilePool = CreateTexturePool(self.ExpandedFrame, "BACKGROUND", -6, "AdventureMapDetailTileTemplate");
	end

	for tileIndex = 1, numDetailTiles do
		local textureFileDataID = C_AdventureMap.GetMapInsetDetailTileInfo(insetIndex, tileIndex);

		local detailTile = self.detailTilePool:Acquire();
		detailTile:SetSize(EFFECTIVE_TILE_WIDTH, EFFECTIVE_TILE_HEIGHT);
		detailTile:SetTexture(textureFileDataID);

		local tileRow = math.floor((tileIndex - 1) / TILES_PER_ROW) + 1;
		local tileCol = (tileIndex - 1) % TILES_PER_ROW + 1;

		local offsetX = math.floor(EFFECTIVE_TILE_WIDTH * (tileCol - 1));
		local offsetY = math.floor(EFFECTIVE_TILE_HEIGHT * (tileRow - 1));

		detailTile:ClearAllPoints();
		detailTile:SetPoint("TOPLEFT", self.ExpandedFrame, "TOPLEFT", offsetX, -offsetY);
		detailTile:Show();
	end
end

function AdventureMapInsetMixin:OnCollapseExpandAnimFinished()
	self.ExpandedFrame:SetShown(not self.collapsed);
	self.CollapsedFrame:SetShown(self.collapsed);
end

function AdventureMapInsetMixin:SyncAnimation()
	self.CollapseExpandAnim:Stop();
	self.ExpandedFrame:Show();
	self.CollapsedFrame:Show();

	self.CollapseExpandAnim.ExpandedFrameAnim:SetFromAlpha(self.ExpandedFrame:GetAlpha());
	self.CollapseExpandAnim.CollapsedFrameAnim:SetFromAlpha(self.CollapsedFrame:GetAlpha());

	if self.collapsed then
		self.CollapseExpandAnim.ExpandedFrameAnim:SetToAlpha(0.0);
		self.CollapseExpandAnim.CollapsedFrameAnim:SetToAlpha(1.0);
	else
		self.CollapseExpandAnim.ExpandedFrameAnim:SetToAlpha(1.0);
		self.CollapseExpandAnim.CollapsedFrameAnim:SetToAlpha(0.0);
	end

	self.CollapseExpandAnim:Play();
end

function AdventureMapInsetMixin:Collapse()
	if not self.collapsed then
		self.collapsed = true;
		self:SyncAnimation();

		if self.areaTrigger then
			self:GetMap():ReleaseAreaTrigger("AdventureMap_MapInset", self.areaTrigger)
			self.areaTrigger = nil;
		end

		self:GetMap():OnMapInsetSizeChanged(self.mapID, self.insetIndex, not self.collapsed);
	end
end

local function OnAreaEnclosedChanged(areaTrigger, areaEnclosed)
	areaTrigger.owner:OnAreaEnclosedChanged(areaEnclosed);
end

function AdventureMapInsetMixin:OnAreaEnclosedChanged(areaEnclosed)
	if not areaEnclosed then
		self:Collapse();
	end
end

function AdventureMapInsetMixin:Expand()
	if self.collapsed then
		self:GetMap():PanAndZoomTo(self.normalizedX, self.normalizedY);
		self.collapsed = false;
		self:SyncAnimation();

		if not self.areaTrigger then
			self.areaTrigger = self:GetMap():AcquireAreaTrigger("AdventureMap_MapInset");
			self.areaTrigger.owner = self;
			self:GetMap():SetAreaTriggerEnclosedCallback(self.areaTrigger, OnAreaEnclosedChanged);
		end

		self.areaTrigger:Reset();
		self.areaTrigger:SetCenter(self.normalizedX, self.normalizedY);
		self.areaTrigger:Stretch(self:GetMap():NormalizeHorizontalSize(self.ExpandedFrame:GetWidth()) * .5, self:GetMap():NormalizeVerticalSize(self.ExpandedFrame:GetHeight()) * .5);

		self:GetMap():OnMapInsetSizeChanged(self.mapID, self.insetIndex, not self.collapsed);
	end
end

function AdventureMapInsetMixin:OnCanvasScaleChanged()
	if not self.collapsed and self:GetMap():IsZoomingOut() then
		self:Collapse();
	end

	self.CollapsedFrame:SetScale(1.0 / self:GetMap():GetCanvasScale());
end

function AdventureMapInsetMixin:GetMap()
	return self.mapCanvas;
end

function AdventureMapInsetMixin:SetLocalPinPosition(pin, normalizedX, normalizedY)
	pin:ClearAllPoints();
	if normalizedX and normalizedY then
		local canvas = self.ExpandedFrame;
		local scale = pin:GetScale() / self:GetScale();
		pin:SetParent(canvas);
		pin:SetPoint("CENTER", canvas, "TOPLEFT", (canvas:GetWidth() * normalizedX) / scale, -(canvas:GetHeight() * normalizedY) / scale);
	end
end

function AdventureMapInsetMixin:GetGlobalPosition(normalizedX, normalizedY)
	local mapCanvas = self:GetMap();
	local canvas = mapCanvas:GetCanvas();

	local globalNormalizedX = mapCanvas:NormalizeHorizontalSize(canvas:GetWidth() * self.normalizedX + self.ExpandedFrame:GetWidth() * (normalizedX - .5));
	local globalNormalizedY = mapCanvas:NormalizeVerticalSize(canvas:GetHeight() * self.normalizedY + self.ExpandedFrame:GetHeight() * (normalizedY - .5));

	return globalNormalizedX, globalNormalizedY;
end

function AdventureMapInsetMixin:OnMouseEnter()
	self:GetMap():OnMapInsetMouseEnter(self.insetIndex);
end

function AdventureMapInsetMixin:OnMouseLeave()
	self:GetMap():OnMapInsetMouseLeave(self.insetIndex);
end