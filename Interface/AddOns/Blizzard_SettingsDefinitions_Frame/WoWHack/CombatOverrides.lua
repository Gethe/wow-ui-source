local function GetReticleColor()
	return CreateColorFromHexString(GetCVar("SoftTargetReticleColor") or "ffffffff") or CreateColor(1, 1, 1, 1);
end

function CombatOverrides.CreateCenterReticleSetting(category, layout)
	local reticleSetting = Settings.RegisterCVarSetting(category, "SoftTargetReticle", Settings.VarType.Boolean, SETTINGS_CENTER_RETICLE);
	local reticleColorSetting = Settings.RegisterCVarSetting(category, "SoftTargetReticleColor", Settings.VarType.String, SETTINGS_CENTER_RETICLE_COLOR);
	local function OpenReticleColorPicker(swatch, button, isDown)
		local info = {};
		info.swatch = swatch;

		local reticleColor = GetReticleColor();
		info.r, info.g, info.b = reticleColor:GetRGB();

		local currentColor = CreateColor(0, 0, 0, 0);
		info.swatchFunc = function()
			local r, g, b = ColorPickerFrame:GetColorRGB();
			currentColor:SetRGB(r, g, b);
			reticleColorSetting:SetValue(currentColor:GenerateHexColor());
		end;

		info.cancelFunc = function()
			local r, g, b = ColorPickerFrame:GetPreviousValues();
			currentColor:SetRGB(r, g, b);
			reticleColorSetting:SetValue(currentColor:GenerateHexColor());
		end;

		ColorPickerFrame:SetupColorPickerAndShow(info);
	end

	local reticleInitializer = CreateSettingsCheckboxWithColorSwatchInitializer(
		reticleSetting,
		SETTINGS_CENTER_RETICLE_TOOLTIP,
		OpenReticleColorPicker,
		true,
		false,
		GetReticleColor,
		SETTINGS_CENTER_RETICLE_COLOR,
		SETTINGS_CENTER_RETICLE_COLOR_TOOLTIP);
	layout:AddInitializer(reticleInitializer);

	local options = Settings.CreateSliderOptions(50, 140, 1);
	local _, reticleOffsetInitializer = Settings.SetupCVarSlider(category, "SoftTargetReticleOffset", options, SETTINGS_CENTER_RETICLE_OFFSET, SETTINGS_CENTER_RETICLE_OFFSET_TOOLTIP);
	reticleOffsetInitializer:SetParentInitializer(reticleInitializer, function()
		return reticleSetting:GetValue();
	end);
end
