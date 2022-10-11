MinimalSliderMixin = {};

function MinimalSliderMixin:OnLoad()
	self:SetObeyStepOnDrag(self.obeyStepOnDrag);
end

function MinimalSliderMixin:Release()
	self:SetScript("OnValueChanged", nil);
end

local function NoModification(value)
	return value;
end

function CreateMinimalSliderFormatter(labelType, value)
	local formatter = nil;
	if value == nil then
		formatter = NoModification;
	elseif type(value) == "function" then
		formatter = value;
	else
		-- Ignores the control value and returns the function argument instead.
		formatter = function(v)
			return value;
		end;
	end
	return formatter;
end

MinimalSliderWithSteppersMixin = CreateFromMixins(CallbackRegistryMixin);

MinimalSliderWithSteppersMixin:GenerateCallbackEvents(
	{
		"OnValueChanged",
		"OnMouseUp",
	}
);

MinimalSliderWithSteppersMixin.Label = EnumUtil.MakeEnum("Left", "Right", "Top", "Min", "Max");

function MinimalSliderWithSteppersMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	
	local forward = false;
	self.Back:SetScript("OnClick", GenerateClosure(self.OnStepperClicked, self, forward));

	local backward = true;
	self.Forward:SetScript("OnClick", GenerateClosure(self.OnStepperClicked, self, backward));
end

function MinimalSliderWithSteppersMixin:OnStepperClicked(forward)
	local value = self.Slider:GetValue();
	local step = self.Slider:GetValueStep();
	if forward then
		self.Slider:SetValue(value + step);
	else
		self.Slider:SetValue(value - step);
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

local function OnMouseDown(slider)
	if slider:IsEnabled() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function MinimalSliderWithSteppersMixin:Init(value, minValue, maxValue, steps, formatters)
	self.Slider:SetMinMaxValues(minValue, maxValue);
	self.Slider:SetValueStep((maxValue - minValue) / steps);
	self.Slider:SetValue(value);

	self.formatters = formatters;
	self:FormatValue(value);

	local function OnValueChanged(slider, value)
		self:FormatValue(value);

		self:TriggerEvent(MinimalSliderWithSteppersMixin.Event.OnValueChanged, value);
	end
	self.Slider:SetScript("OnValueChanged", OnValueChanged);
	self.Slider:SetScript("OnMouseDown", OnMouseDown);
end

function MinimalSliderWithSteppersMixin:FormatValue(value)
	if not self.formatters then
		return;
	end

	for labelID, formatter in pairs(self.formatters) do
		local label = self.Labels[labelID];
		if label then
			label:SetText(formatter(value));
			label:Show();
		end
	end
end

local function ConfigureSlider(self, color, alpha)
	self.Slider.Thumb:SetAlpha(alpha);

	local r, g, b = color:GetRGB();
	self.LeftText:SetVertexColor(r, g, b);
	self.RightText:SetVertexColor(r, g, b);
	self.TopText:SetVertexColor(r, g, b);
	self.MinText:SetVertexColor(r, g, b);
	self.MaxText:SetVertexColor(r, g, b);
end

function MinimalSliderWithSteppersMixin:SetEnabled_(enabled)
	if enabled then
		ConfigureSlider(self, NORMAL_FONT_COLOR, 1.0);
	else
		ConfigureSlider(self, GRAY_FONT_COLOR, .7);
	end
	self.Slider:SetEnabled(enabled);
	self.Back:SetEnabled(enabled);
	self.Forward:SetEnabled(enabled);
end

function MinimalSliderWithSteppersMixin:SetValue(value)
	self.Slider:SetValue(value);
end

function MinimalSliderWithSteppersMixin:Release()
	self.Slider:Release();

	for index, label in ipairs(self.Labels) do
		label:Hide();
	end
end
