--------------------------------------------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
local _, tbl = ...;
if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
		Import("C_StoreGlue");
	end

	setfenv(1, tbl);

	Import("SetPortraitToTexture");
	Import("SetPortraitTexture");
	Import("SetBagPortraitTexture");
end
--------------------------------------------------

PortraitFrameMixin = {};

function PortraitFrameMixin:GetPortrait()
	return self.PortraitContainer.portrait;
end

function PortraitFrameMixin:GetTitleText()
	return self.TitleContainer.TitleText;
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
	SetBagPortraitTexture(self:GetPortrait(), bagID);
end

function PortraitFrameMixin:SetPortraitTextureRaw(texture)
	self:GetPortrait():SetTexture(texture);
end

function PortraitFrameMixin:SetPortraitAtlasRaw(atlas, ...)
	self:GetPortrait():SetAtlas(atlas, ...);
end

function PortraitFrameMixin:SetPortraitTexCoord(...)
	self:GetPortrait():SetTexCoord(...);
end

function PortraitFrameMixin:SetPortraitShown(shown)
	self:GetPortrait():SetShown(shown);
end

function PortraitFrameMixin:SetTitleColor(color)
	self:GetTitleText():SetTextColor(color:GetRGBA());
end

function PortraitFrameMixin:SetTitle(title)
	self:GetTitleText():SetText(title);
end

function PortraitFrameMixin:SetTitleFormatted(fmt, ...)
	self:GetTitleText():SetFormattedText(fmt, ...);
end

function PortraitFrameMixin:SetTitleMaxLinesAndHeight(maxLines, height)
	self:GetTitleText():SetMaxLines(maxLines);
	self:GetTitleText():SetHeight(height);
end

function PortraitFrameMixin:SetTitleMaxLinesAndHeight(maxLines, height)
	self:GetTitleText():SetMaxLines(maxLines);
	self:GetTitleText():SetHeight(height);
end

function PortraitFrameMixin:SetPortraitTextureSizeAndOffset(size, offsetX, offsetY)
	local portrait = self:GetPortrait();
	portrait:SetSize(size, size);
	portrait:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX, offsetY);
end

function PortraitFrameMixin:DefaultPortraitTextureSizeAndOffset()
	self:SetPortraitTextureSizeAndOffset(60, -54, 7); -- [NB] TODO: Template lookup?
end

PortraitFrameTitleContainerMixin = {};

function PortraitFrameTitleContainerMixin:OnLoad()
	self:GetParent().TitleText = self.TitleText;
end
