CDMVIS_ALERT_COLOR_GOLD = CreateColorFromRGBHexString("FFD700");
CDMVIS_ALERT_COLOR_CYAN = CreateColorFromRGBHexString("3FBFD4");
CDMVIS_ALERT_COLOR_RED = CreateColorFromRGBHexString("CA1A1A");
CDMVIS_ALERT_COLOR_GREEN = CreateColorFromRGBHexString("4DAF63");
CDMVIS_ALERT_COLOR_BLUE = CreateColorFromRGBHexString("3F6EC7");

CDMVISBaseMixin = CreateFromMixins(CooldownViewerVisualAlertMixin);

function CDMVISBaseMixin:CDMVISBase_OnLoad()
	self:ApplyVertexColor();
end

function CDMVISBaseMixin:GetVertexColor()
	return self.vertexColor;
end

function CDMVISBaseMixin:ApplyVertexColor()
	local color = self:GetVertexColor();
	if color then
		self:ApplyVertexColorToRegions(color, self:GetVertexColoredRegions());
	end
end

function CDMVISBaseMixin:ApplyVertexColorToRegions(color, ...)
	for i = 1, select("#", ...) do
		local region = select(i, ...);
		region:SetVertexColor(color:GetRGBA());
	end
end

function CDMVISBaseMixin:CDMVISBase_OnShow()
	self.playTime = 0;
	self.durationSeconds = self.durationSeconds or 2;
end

function CDMVISBaseMixin:CDMVISBase_OnUpdate(elapsed)
	self.playTime = self.playTime + elapsed; -- For typical play duration times, accumulation error shouldn't matter.
	if self.playTime >= self.durationSeconds then
		CooldownViewerVisualAlertsManager:ReleaseAlert(self);
	end
end

CDMVISMarchingAntsBaseMixin = {};

function CDMVISMarchingAntsBaseMixin:GetVertexColoredRegions()
	return self.Flipbook;
end

function CDMVISMarchingAntsBaseMixin:GetAnchors(target)
	local topLeft = CreateAnchor("TOPLEFT", target, "TOPLEFT", -8, 8);
	local bottomRight = CreateAnchor("BOTTOMRIGHT", target, "BOTTOMRIGHT", 9, -9);
	return topLeft, bottomRight;
end

CDMVISFlashBaseMixin = {};

function CDMVISFlashBaseMixin:GetVertexColoredRegions()
	return self.Glow;
end

function CDMVISFlashBaseMixin:GetAnchors(target)
	local topLeft = CreateAnchor("TOPLEFT", target, "TOPLEFT", -8, 8);
	local bottomRight = CreateAnchor("BOTTOMRIGHT", target, "BOTTOMRIGHT", 9, -9);
	return topLeft, bottomRight;
end
