ScaleToFitFrameMixin = {};

function ScaleToFitFrameMixin:OnScaleToFitFrameLoad()
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function ScaleToFitFrameMixin:OnScaleToFitFrameEvent(event, ...)
	if (event == "DISPLAY_SIZE_CHANGED") or (event == "UI_SCALE_CHANGED") then
		self:Refresh();
	end
end

-- Important: Set a function to be called when a refresh needs to happen, this callback should call SetMaxWidth or SetMaxHeight
function ScaleToFitFrameMixin:SetRefreshCallback(callback)
	self.refreshCallback = callback;
end

function ScaleToFitFrameMixin:Refresh()
	if self.refreshCallback then
		self.refreshCallback();
	end
end

function ScaleToFitFrameMixin:SetMaxWidth(maxWidth)
	self.maxWidth = maxWidth;
	self:UpdateScaleToFit();
end

function ScaleToFitFrameMixin:SetMaxHeight(maxHeight)
	self.maxHeight = maxHeight;
	self:UpdateScaleToFit();
end

function ScaleToFitFrameMixin:UpdateScaleToFit()
	local useScale = 1;

	if self.maxWidth or self.maxHeight then
		local _frameLeft, _frameBottom, frameWidth, frameHeight = GetUnscaledFrameRect(self, self:GetEffectiveScale())

		if self.maxWidth and frameWidth > self.maxWidth then
			useScale = self.maxWidth / frameWidth;
		end

		if self.maxHeight and frameHeight > self.maxHeight then
			useScale = math.min(useScale, self.maxHeight / frameHeight);
		end
	end

	self:SetScale(useScale);
end

-- Automatically calls Refresh whenever the LayoutFrame is cleaned
ScaleToFitLayoutFrameMixin = {};

function ScaleToFitLayoutFrameMixin:OnCleaned()
	self:Refresh();
end
