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
end
--------------------------------------------------

PortraitFrameMixin = {};

function PortraitFrameMixin:SetBorder(layoutName)
	local layout = NineSliceUtil.GetLayout(layoutName);
	NineSliceUtil.ApplyLayout(self.NineSlice, layout);
end

function PortraitFrameMixin:SetPortraitToAsset(texture)
	SetPortraitToTexture(self.portrait, texture);
end

function PortraitFrameMixin:SetPortraitToUnit(unit)
	SetPortraitTexture(self.portrait, unit);
end

function PortraitFrameMixin:SetPortraitTextureRaw(texture)
	self.portrait:SetTexture(texture);
end

function PortraitFrameMixin:SetPortraitAtlasRaw(atlas, ...)
	self.portrait:SetAtlas(atlas, ...);
end

function PortraitFrameMixin:SetPortraitTexCoord(...)
	self.portrait:SetTexCoord(...);
end

function PortraitFrameMixin:SetPortraitShown(shown)
	self.portrait:SetShown(shown);
end

function PortraitFrameMixin:SetTitleColor(color)
	self.TitleText:SetTextColor(color:GetRGBA());
end

function PortraitFrameMixin:SetTitle(title)
	self.TitleText:SetText(title);
end

function PortraitFrameMixin:SetTitleFormatted(fmt, ...)
	self.TitleText:SetFormattedText(fmt, ...);
end

function PortraitFrameMixin:SetTitleMaxLinesAndHeight(maxLines, height)
	self.TitleText:SetMaxLines(maxLines);
	self.TitleText:SetHeight(height);
end
