ColorPickerFrameMixin = {}

function ColorPickerFrameMixin:OnLoad()
    self.Content.ColorPicker:SetScript("OnColorSelect", function(colorPicker, r, g, b)
        self.Content.ColorSwatchCurrent:SetColorTexture(r, g, b);
        self.Content.HexBox:OnColorSelect(r, g, b);
        if self.swatchFunc then
            self.swatchFunc();
        end

        if self.opacityFunc then
            self.opacityFunc();
        end
    end);

    self.Footer.OkayButton:SetScript("OnClick", function()
        self.swatchFunc();
        if self.opacityFunc then
            self.opacityFunc();
        end
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        self:Hide();
    end);

    self.Footer.CancelButton:SetScript("OnClick", function()
        if self.cancelFunc then
            self.cancelFunc(self.previousValues);
        end
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        self:Hide();
    end);
end

function ColorPickerFrameMixin:OnShow()
    if self.hasOpacity then
        self.Content.ColorPicker.Alpha:Show();
        self.Content.ColorPicker.AlphaThumb:Show();
        self.Content.AlphaBackground:Show();
        self.Content.ColorPicker:SetColorAlpha(self.opacity);

        self.Content.ColorPicker:SetWidth(255);
        self:SetWidth(388);
    else
        self.Content.ColorPicker.Alpha:Hide();
        self.Content.ColorPicker.AlphaThumb:Hide();
        self.Content.AlphaBackground:Hide();

        self.Content.ColorPicker:SetWidth(200);
        self:SetWidth(331);
    end
end

function ColorPickerFrameMixin:OnKeyDown(key)
    if GetBindingFromClick(key) == "TOGGLEGAMEMENU" then
        if self.cancelFunc then
            self.cancelFunc(self.previousValues);
        end
        self:Hide();
    end
end

function ColorPickerFrameMixin:SetupColorPickerAndShow(info)
    self.swatchFunc = info.swatchFunc;
    self.hasOpacity = info.hasOpacity;
    self.opacityFunc = info.opacityFunc;
    self.opacity = info.opacity;
    self.previousValues = {r = info.r, g = info.g, b = info.b, a = info.opacity};
    self.cancelFunc = info.cancelFunc;
    self.extraInfo = info.extraInfo;

    self.Content.ColorSwatchOriginal:SetColorTexture(info.r, info.g, info.b);
    self.Content.HexBox:OnColorSelect(info.r, info.g, info.b);

    -- This must come last, since it triggers a call to swatchFunc
    self.Content.ColorPicker:SetColorRGB(info.r, info.g, info.b);
    self:Show();
end

function ColorPickerFrameMixin:GetColorRGB()
    return self.Content.ColorPicker:GetColorRGB();
end

function ColorPickerFrameMixin:GetColorAlpha()
    return self.Content.ColorPicker:GetColorAlpha();
end

function ColorPickerFrameMixin:GetExtraInfo()
    return self.extraInfo;
end

function ColorPickerFrameMixin:GetPreviousValues()
    return self.previousValues.r, self.previousValues.g, self.previousValues.b, self.previousValues.a;
end

ColorPickerHexBoxMixin = {}

function ColorPickerHexBoxMixin:OnLoad()
    self:SetTextInsets(16, 0, 0, 0);
    self.Instructions:SetText(COLOR_PICKER_HEX);
    self.Instructions:ClearAllPoints();
    self.Instructions:SetPoint("TOPLEFT", self, "TOPLEFT", 16, 0);
    self.Instructions:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
end

function ColorPickerHexBoxMixin:OnTextChanged()
    local text = self:GetText();
    self:SetText(string.gsub(text, "[^A-Fa-f0-9]", ""));
    self.Instructions:SetShown(self:GetText() == "");
end

function ColorPickerHexBoxMixin:OnEnterPressed()
    -- If a full hex code was not provided, copy from the start of the string until we have all characters.
    local text = self:GetText();
    local length = string.len(text);
    if length == 0 then
        self:SetText("ffffff");
    elseif length < 6 then
        local startingText = text;
        while length < 6 do
            for i = 1, #startingText do
                local char = startingText:sub(i,i);
                text = text..char;

                length = length + 1;
                if length == 6 then
                    break;
                end
            end
        end
        self:SetText(text);
    end

    -- Update color to match string.
    -- Add alpha values to the end to be correct format.
    local color = CreateColorFromRGBAHexString(self:GetText().."ff");
    ColorPickerFrame.Content.ColorPicker:SetColorRGB(color:GetRGB());
end

function ColorPickerHexBoxMixin:OnColorSelect(r, g, b)
    local hexColor = CreateColor(r, g, b):GenerateHexColorNoAlpha();
    self:SetText(hexColor);
end