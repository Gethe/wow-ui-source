ColorPickerFrameMixin = {};

function ColorPickerFrameMixin:OnOkay()
	self.swatchFunc();
	if self.opacityFunc then
		self.opacityFunc();
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:Hide();
end

function ColorPickerFrameMixin:OnCancel()
	if self.cancelFunc then
		self.cancelFunc(self.previousValues);
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:Hide();
end

function ColorPickerFrameMixin:OnLoad()
	self.Content.ColorPicker:SetScript("OnColorSelect", function(colorPicker, r, g, b)
		self.Content.ColorSwatchCurrent:SetColorTexture(r, g, b);
		self.Content.HexBox:OnColorSelect(r, g, b);
		if self.swatchFunc then
			self.swatchFunc();
		end

		if self.swatch then
			self.swatch:SetColorRGB(r, g, b);
		end

		if self.opacityFunc then
			self.opacityFunc();
		end
	end);

	self.Footer.OkayButton:SetScript("OnClick", GenerateFlatClosure(self.OnOkay, self));
	self.Footer.CancelButton:SetScript("OnClick", GenerateFlatClosure(self.OnCancel, self));

	self:RegisterForTransitions();
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

	self:RegisterEvent("GLOBAL_MOUSE_DOWN");
end

function ColorPickerFrameMixin:OnHide()
	self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
	self:GamepadOnHide();
end

function ColorPickerFrameMixin:GamepadOnHide()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	ColorPickerSoftCursor:SetActive(false);

	if SettingsPanel:IsShown() then
		SmartNavigation:ShowCursor(false);
	end

	self.colorPickerDetailsFooter:HideAndDeactivateBindings();
	GamepadMode.DeactivateBindingGroup(self.brightnessBinding);
end

function ColorPickerFrameMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		if self:IsShown() and not DoesAncestryIncludeAny(self, GetMouseFoci()) then
			if self.cancelFunc then
				self.cancelFunc(self.previousValues);
			end
			self:Hide();
		end
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

ColorPickerHexBoxMixin = {};

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
	local text = self:GetText();
	local length = string.len(text);
	if length == 0 then
		self:SetText("ffffff");
	elseif length < 6 then
		local startingText = text;
		while length < 6 do
			for i = 1, #startingText do
				local char = startingText:sub(i, i);
				text = text .. char;

				length = length + 1;
				if length == 6 then
					break;
				end
			end
		end
		self:SetText(text);
	end

	local color = CreateColorFromRGBAHexString(self:GetText() .. "ff");
	ColorPickerFrame.Content.ColorPicker:SetColorRGB(color:GetRGB());
end

function ColorPickerHexBoxMixin:OnColorSelect(r, g, b)
	local hexColor = CreateColor(r, g, b):GenerateHexColorNoAlpha();
	self:SetText(hexColor);
end

function ColorPickerFrameMixin:SetupColorPickerAndShow(info)
	self.swatchFunc = info.swatchFunc;
	self.hasOpacity = info.hasOpacity;
	self.opacityFunc = info.opacityFunc;
	self.opacity = info.opacity;
	self.previousValues = { r = info.r, g = info.g, b = info.b, a = info.opacity };
	self.cancelFunc = info.cancelFunc;
	self.extraInfo = info.extraInfo;
	self.swatch = info.swatch;

	self.Content.ColorSwatchOriginal:SetColorTexture(info.r, info.g, info.b);
	self.Content.HexBox:OnColorSelect(info.r, info.g, info.b);
	self.Content.ColorPicker:SetColorRGB(info.r, info.g, info.b);
	self:Show();

	self:SetUpGamepadCursorAndShow();
end

function ColorPickerFrameMixin:SetUpGamepadCursorAndShow()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	local cx, cy = self.Content.ColorPicker.Wheel:GetCenter();
	local width = self.Content.ColorPicker.Wheel:GetSize();

	local boundsFunc = function()
		return SoftCursor_CreateCircleBounds(cx, cy, width / 2);
	end

	ColorPickerSoftCursor:SetActive(true);
	ColorPickerSoftCursor:SetBounds(boundsFunc);
	ColorPickerSoftCursor:SetPoint("CENTER", self.Content.ColorPicker.WheelThumb, "CENTER", 0, 0);

	SmartNavigation:HideCursor(true);
	self.colorPickerDetailsFooter:ShowAndActivateBindings();
	GamepadMode.ActivateBindingGroup(self.brightnessBinding);
end

function ColorPickerSoftCursor_OnUpdate(self, delta)
	local currentX, currentY = self:GetCenter();
	local nextX = currentX + (self.speedX * delta);
	local nextY = currentY + (self.speedY * delta);
	local cx, cy = ColorPickerFrame.Content.ColorPicker.Wheel:GetCenter();
	local width = ColorPickerFrame.Content.ColorPicker.Wheel:GetSize();

	nextX, nextY = self.bounds:ClampPointInBounds(nextX, nextY);

	if nextX ~= currentX or nextY ~= currentY then
		self:ClearAllPoints();
		self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", nextX, nextY);

		local x = nextX - cx;
		local y = nextY - cy;
		x = x / (width / 2);
		y = y / (width / 2);

		local hue = math.deg(math.atan2(y, x)) + 180;
		local saturation = math.sqrt(Square(x) + Square(y));

		local _, _, _, _, yOffset = ColorPickerFrame.Content.ColorPicker.ValueThumb:GetPoint();
		local _, height = ColorPickerFrame.Content.ColorPicker.Value:GetSize();
		local value = yOffset / height;

		ColorPickerFrame.Content.ColorPicker:SetColorHSV(hue, saturation, value);
	end
end

function ColorPickerFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateFlatClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateFlatClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateFlatClosure(self.UninitializeGamepad, self));
end

function ColorPickerFrameMixin:SetupGamepad()
	local colorPickerSelect = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, GenerateFlatClosure(self.OnOkay, self), ACTION_LABEL_SELECT);
	local colorPickerColor = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT, nil, ACTION_LABEL_ADJUST_COLOR);
	local colorPickerBrightness = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_LEFT, nil, ACTION_LABEL_ADJUST_BRIGHTNESS);
	local colorPickerCancel = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, GenerateFlatClosure(self.OnCancel, self), FRAME_ACTION_CANCEL);

	self.colorPickerDetailsFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "ColorPickerDetailsFooter");
	self.colorPickerDetailsFooter:AddPromptedBinding(colorPickerSelect);
	self.colorPickerDetailsFooter:AddPromptedBinding(colorPickerColor);
	self.colorPickerDetailsFooter:AddPromptedBinding(colorPickerBrightness);
	self.colorPickerDetailsFooter:AddPromptedBinding(colorPickerCancel);
	self.colorPickerDetailsFooter:Finalize();

	local brightnessFunc = function(x, y)
		local h, s, v = ColorPickerFrame.Content.ColorPicker:GetColorHSV();
		if y > 0 then
			ColorPickerFrame.Content.ColorPicker:SetColorHSV(h, s, v + 0.01);
		else
			ColorPickerFrame.Content.ColorPicker:SetColorHSV(h, s, v - 0.01);
		end
	end;

	self.brightnessBinding = GamepadMode.CreateBindingGroup("ColorPickerBrightnessBinding");
	self.brightnessBinding:AddAxisBinding(GAMEPAD_STICK_LEFT, brightnessFunc);
end

function ColorPickerFrameMixin:InitializeGamepad()
	self.Footer.CancelButton:Hide();
	self.Footer.OkayButton:Hide();
end

function ColorPickerFrameMixin:UninitializeGamepad()
	self.Footer.CancelButton:Show();
	self.Footer.OkayButton:Show();
end
