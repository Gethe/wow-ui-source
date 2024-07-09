ColorPickerFrameMixin = {}

function ColorPickerFrameMixin:SetupColorPickerAndShow(info)
    self.swatchFunc = info.swatchFunc;
    self.hasOpacity = info.hasOpacity;
    self.opacityFunc = info.opacityFunc;
    self.opacity = info.opacity;
    self.previousValues = {r = info.r, g = info.g, b = info.b, a = info.opacity};
    self.cancelFunc = info.cancelFunc;
    self.extraInfo = info.extraInfo;

    ColorSwatch:SetColorTexture(info.r, info.g, info.b);

    -- This must come last, since it triggers a call to swatchFunc
    self:SetColorRGB(info.r, info.g, info.b);
    self:Show();
end

function ColorPickerFrameMixin:GetColorAlpha()
    return OpacitySliderFrame:GetValue();
end

function ColorPickerFrameMixin:GetExtraInfo()
    return self.extraInfo;
end

function ColorPickerFrameMixin:GetPreviousValues()
    return self.previousValues.r, self.previousValues.g, self.previousValues.b, self.previousValues.a;
end