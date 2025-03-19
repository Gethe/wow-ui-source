
TitledPanelMixin = {};

function TitledPanelMixin:GetTitleText()
	return self.TitleContainer.TitleText;
end

function TitledPanelMixin:SetTitleColor(color)
	self:GetTitleText():SetTextColor(color:GetRGBA());
end

function TitledPanelMixin:SetTitle(title)
	self:GetTitleText():SetText(title);
end

function TitledPanelMixin:SetTitleFormatted(fmt, ...)
	self:GetTitleText():SetFormattedText(fmt, ...);
end

function TitledPanelMixin:SetTitleMaxLinesAndHeight(maxLines, height)
	self:GetTitleText():SetMaxLines(maxLines);
	self:GetTitleText():SetHeight(height);
end

function TitledPanelMixin:SetTitleMaxLinesAndHeight(maxLines, height)
	self:GetTitleText():SetMaxLines(maxLines);
	self:GetTitleText():SetHeight(height);
end

function TitledPanelMixin:SetTitleOffsets(leftOffset, rightOffset)
	self.TitleContainer:SetPoint("TOPLEFT", self, "TOPLEFT", leftOffset or 58, -1);
	self.TitleContainer:SetPoint("TOPRIGHT", self, "TOPRIGHT", rightOffset or -24, -1);
end

DefaultPanelMixin = CreateFromMixins(TitledPanelMixin);

PortraitFrameMixin = CreateFromMixins(TitledPanelMixin);

function PortraitFrameMixin:GetPortrait()
	return self.PortraitContainer.portrait;
end

function PortraitFrameMixin:SetBorder(layoutName)
	local layout = NineSliceUtil.GetLayout(layoutName);
	NineSliceUtil.ApplyLayout(self.NineSlice, layout);
end

function PortraitFrameMixin:SetPortraitToAsset(texture)
	SetPortraitToTexture(self:GetPortrait(), texture);
end

function PortraitFrameMixin:SetPortraitToUnit(unit)
	SetPortraitTexture(self:GetPortrait(), unit);
end

function PortraitFrameMixin:SetPortraitToBag(bagID)
	C_Container.SetBagPortraitTexture(self:GetPortrait(), bagID);
end

function PortraitFrameMixin:SetPortraitTextureRaw(texture)
	self:GetPortrait():SetTexture(texture);
end

function PortraitFrameMixin:SetPortraitAtlasRaw(atlas, ...)
	self:GetPortrait():SetAtlas(atlas, ...);
end

function PortraitFrameMixin:SetPortraitToClassIcon(classFilename)
	self:SetPortraitTextureRaw("Interface/TargetingFrame/UI-Classes-Circles");
	local left, right, bottom, top = unpack(CLASS_ICON_TCOORDS[string.upper(classFilename)]);
	self:SetPortraitTexCoord(left, right, bottom, top);
end

function PortraitFrameMixin:SetPortraitTexCoord(...)
	self:GetPortrait():SetTexCoord(...);
end

function PortraitFrameMixin:SetPortraitShown(shown)
	self:GetPortrait():SetShown(shown);
end

function PortraitFrameMixin:SetPortraitTextureSizeAndOffset(size, offsetX, offsetY)
	local portrait = self:GetPortrait();
	portrait:SetSize(size, size);
	portrait:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX, offsetY);
end

do
	local function SetFrameLevelInternal(frame, level)
		if frame then
			assertsafe(level < 10000, "Base level needs to be low enough to accomodate the existing layering"); -- TODO: Should become a constant
			frame:SetFrameLevel(level);
		end
	end

	function PortraitFrameMixin:SetFrameLevelsFromBaseLevel(baseLevel)
		SetFrameLevelInternal(self.NineSlice, baseLevel + 500);
		SetFrameLevelInternal(self.PortraitContainer, baseLevel + 400);
		SetFrameLevelInternal(self.TitleContainer, baseLevel + 510);
		SetFrameLevelInternal(self.CloseButton, baseLevel + 510);
	end
end

PortraitFrameFlatBaseMixin = {};

function PortraitFrameFlatBaseMixin:SetBackgroundColor(color)
	if self.Bg then
		local bg = self.Bg;
		color = color or PANEL_BACKGROUND_COLOR;
		local r, g, b, a = color:GetRGBA();
		bg.BottomLeft:SetVertexColor(r, g, b, a);
		bg.BottomRight:SetVertexColor(r, g, b, a);
		bg.BottomEdge:SetColorTexture(r, g, b, a);
		bg.TopSection:SetColorTexture(r, g, b, a);
	end
end