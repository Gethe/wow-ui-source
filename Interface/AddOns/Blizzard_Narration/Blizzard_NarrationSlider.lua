
---------------------------------------------------------------------------
-- NarrationSliderMixin
--
-- Narrates as: <label>, Slider, <current value>
--
-- Configurable key-values:
--		narrationLabel (string) - Explicit label override.
--		narrationLabelRegion (region) - Usually a FontString. GetText() is called to supply label text.
--		narrationValueFormatter (function) - function(value, min, max) -> string. For supplying custom text.
---------------------------------------------------------------------------

NarrationSliderMixin = {};

function NarrationSliderMixin:SetNarrationLabelRegion(region)
	self.narrationLabelRegion = region;
end

function NarrationSliderMixin:SetNarrationValueFormatter(formatter)
	self.narrationValueFormatter = formatter;
end

function NarrationSliderMixin:NarrationGetName()
	if self.narrationLabel then
		return self.narrationLabel;
	end

	if self.narrationLabelRegion then
		local text = self.narrationLabelRegion:GetText();
		if text and text ~= "" then
			return text;
		end
	end

	return nil;
end

function NarrationSliderMixin:NarrationGetContext()
	if not self:IsEnabled() then
		return NARRATION_STATUS_DISABLED_FORMAT:format(NARRATION_OBJECT_SLIDER);
	end

	return NARRATION_OBJECT_SLIDER;
end

function NarrationSliderMixin:NarrationGetDescription()
	local value = self:GetValue();

	if self.narrationValueFormatter then
		local minValue, maxValue = self:GetMinMaxValues();
		local formattedValue = self.narrationValueFormatter(value, minValue, maxValue);
		if formattedValue then
			return formattedValue;
		end
	end

	return tostring(value);
end
