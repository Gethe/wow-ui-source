CONTROLTYPE_CHECKBOX = 1;
CONTROLTYPE_DROPDOWN = 2;
CONTROLTYPE_SLIDER = 3;


local ALT_KEY = "altkey";
local CONTROL_KEY = "controlkey";
local SHIFT_KEY = "shiftkey";
local NO_KEY = "none";

local securecall = securecall;
local next = next;
local function SecureNext(elements, key)
	return securecall(next, elements, key);
end

local tinsert = tinsert;
local tonumber = tonumber;
local tostring = tostring;
local gsub = gsub;


-- [[ Slider functions ]] --

function BlizzardOptionsPanel_Slider_Disable (slider)
	getmetatable(slider).__index.Disable(slider);
	slider.Text:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	slider.Low:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	slider.High:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);

	if ( slider.Label ) then
		slider.Label:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end

function BlizzardOptionsPanel_Slider_Enable (slider)
	getmetatable(slider).__index.Enable(slider);
	slider.Text:SetVertexColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b);
	slider.Low:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	slider.High:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	if ( slider.Label ) then
		slider.Label:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end

function BlizzardOptionsPanel_Slider_SetEnabled (slider, enabled)
	if ( enabled ) then
		BlizzardOptionsPanel_Slider_Enable(slider);
	else
		BlizzardOptionsPanel_Slider_Disable(slider);
	end
end

function BlizzardOptionsPanel_Slider_Refresh (slider)
	local value;

	if ( slider.GetCurrentValue ) then
		value = slider:GetCurrentValue();
	elseif ( slider.cvar ) then
		value = BlizzardOptionsPanel_GetCVarSafe(slider.cvar);
	end

	if ( value ) then
		if ( slider.SetDisplayValue ) then
			slider:SetDisplayValue(value);
		else
			slider:SetValue(value);
		end
		slider.value = value;
	end
end

function BlizzardOptionsPanel_Slider_OnValueChanged (self, value)
	if(self.onvaluechanged) then
		self:onvaluechanged(value);
	else
		BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
	end
	self.value = value;
end

-- [[ CheckButton functions ]] --

function BlizzardOptionsPanel_CheckButton_Disable(checkBox)
	checkBox:Disable();
	local text = _G[checkBox:GetName().."Text"];
	if ( text ) then
		text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end

function BlizzardOptionsPanel_CheckButton_Enable(checkBox, isWhite)
	checkBox:Enable();
	local text = _G[checkBox:GetName().."Text"];
	if ( not text ) then
		return;
	end
	if ( isWhite ) then
		text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end

function BlizzardOptionsPanel_CheckButton_SetEnabled (checkBox, enabled)
	if ( enabled ) then
		BlizzardOptionsPanel_CheckButton_Enable(checkBox);
	else
		BlizzardOptionsPanel_CheckButton_Disable(checkBox);
	end
end

function BlizzardOptionsPanel_CheckButton_GetSetting (checkButton)
	if ( checkButton:GetChecked() ) then
		if ( not checkButton.invert ) then
			return "1";
		end
	elseif ( checkButton.invert ) then
		return "1";
	end

	return "0";
end

function BlizzardOptionsPanel_CheckButton_OnClick (checkButton)
	PlaySound(checkButton:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);

	BlizzardOptionsPanel_CheckButton_SetNewValue(checkButton);

	local setting = BlizzardOptionsPanel_CheckButton_GetSetting(checkButton);

	if ( checkButton.setFunc ) then
		checkButton.setFunc(setting);
	end
end

function BlizzardOptionsPanel_CheckButton_SetNewValue (checkButton)
	local isChecked = checkButton:GetChecked();

	local setting = BlizzardOptionsPanel_CheckButton_GetSetting(checkButton);

	if ( setting == checkButton.value ) then
		checkButton.newValue = nil;
	else
		checkButton.newValue = setting;
	end

	checkButton:SetValue(setting);

	BlizzardOptionsPanel_SetDependentControlsEnabled(checkButton, isChecked);
end

function BlizzardOptionsPanel_CheckButton_Refresh (checkButton)
	local value;

	if ( checkButton.cvar ) then
		value = GetCVar(checkButton.cvar);
	elseif ( checkButton.GetValue ) then
		value = tostring(checkButton:GetValue());
	end

	if ( value ) then
		if ( checkButton.invert ) then
			checkButton:SetChecked(value == (checkButton.uncheckedValue or "0"));
		else
			checkButton:SetChecked(value == (checkButton.checkedValue or "1"));
		end

		BlizzardOptionsPanel_SetDependentControlsEnabled(checkButton, checkButton:GetChecked());

		checkButton.value = value;
	end
end

-- [[ DropDown functions ]] --

function BlizzardOptionsPanel_DropDown_Refresh (dropDown)
end

function BlizzardOptionsPanel_DropDown_SetEnabled (dropDown, enabled)
	if ( enabled ) then
		UIDropDownMenu_EnableDropDown(dropDown);
	else
		UIDropDownMenu_DisableDropDown(dropDown);
	end
end

-- [[ BlizzardOptionsPanel functions ]] --

-- HACK: unfortunately, CVars have this funny quirk where they are returned as strings, even if they are numbers,
-- which makes things complicated for sliders...things get even more complicated when you have a mix of regular
-- Get/SetCVar calls with the following (typesafe) BlizzardOptionsPanel_Get/SetCVarSafe calls... so to avoid
-- comparing numbers to strings, we are going to convert anything that needs comparing into a number first!

function BlizzardOptionsPanel_SetCVarSafe (cvar, value, event)
	local oldValue = GetCVar(cvar);
	local oldValueNum = tonumber(oldValue);
	local valueNum = tonumber(value);
	if ( oldValueNum or valueNum ) then
		if ( oldValueNum ~= valueNum ) then
			SetCVar(cvar, value, event);
		end
	else
		if ( oldValue ~= value ) then
			SetCVar(cvar, value, event);
		end
	end
end

function BlizzardOptionsPanel_GetCVarSafe (cvar)
	local value = GetCVar(cvar);
	value = tonumber(value) or value;
	return value;
end

function BlizzardOptionsPanel_GetCVarDefaultSafe (cvar)
	local value = GetCVarDefault(cvar);
	value = tonumber(value) or value;
	return value;
end

function BlizzardOptionsPanel_OkayControl (control, panel, perControlCallback)
	if ( control.newValue ) then
		if ( control.value ~= control.newValue ) then
			control:SetValue(control.newValue);
			control.value = control.newValue;
			control.newValue = nil;
			perControlCallback(panel, control);
		end
	elseif ( control.value ) then
		if ( control:GetValue() ~= control.value ) then
			control:SetValue(control.value);
			perControlCallback(panel, control);
		end
	end
end

function BlizzardOptionsPanel_CancelControl (control, panel, perControlCallback)
	if ( control.newValue ) then
		if ( control.value and control.value ~= control.newValue ) then
			-- we need to force-set the value here just in case the control was doing dynamic updating
			control:SetValue(control.value);
			control.newValue = nil;
			perControlCallback(panel, control);
		end
	elseif ( control.value ) then
		if ( control:GetValue() ~= control.value ) then
			control:SetValue(control.value);
			perControlCallback(panel, control);
		end
	end
end

function BlizzardOptionsPanel_DefaultControl (control, panel, perControlCallback)
	if ( control.defaultValue and control.value ~= control.defaultValue ) then
		control:SetValue(control.defaultValue);
		control.value = control.defaultValue;
		control.newValue = nil;
		perControlCallback(panel, control);
	end
end

function BlizzardOptionsPanel_RefreshControl (control, panel, perControlCallback)
	if ( control.RefreshValue ) then
		control:RefreshValue();
	end

	if ( control.type == CONTROLTYPE_CHECKBOX ) then
		BlizzardOptionsPanel_CheckButton_Refresh(control);
	elseif ( control.type == CONTROLTYPE_DROPDOWN ) then
		BlizzardOptionsPanel_DropDown_Refresh(control);
	elseif ( control.type == CONTROLTYPE_SLIDER ) then
		BlizzardOptionsPanel_Slider_Refresh(control);
	end

	perControlCallback(panel, control);
end

function BlizzardOptionsPanel_RefreshControlSingle(control)
	BlizzardOptionsPanel_RefreshControl(control, nil, nop);
end

function BlizzardOptionsPanel_SetControlEnabled (control, enabled)
	if control.type == CONTROLTYPE_CHECKBOX then
		BlizzardOptionsPanel_CheckButton_SetEnabled(control, enabled);
	elseif control.type == CONTROLTYPE_DROPDOWN then
		BlizzardOptionsPanel_DropDown_SetEnabled(control, enabled);
	elseif control.type == CONTROLTYPE_SLIDER then
		BlizzardOptionsPanel_Slider_SetEnabled(control, enabled);
	end
end

local function SetControlsEnabledInternal (controls, enabled)
	if controls then
		for _, control in SecureNext, controls do
			securecall(BlizzardOptionsPanel_SetControlEnabled, control, enabled);
		end
	end
end

function BlizzardOptionsPanel_SetDependentControlsEnabled (self, enabled)
	SetControlsEnabledInternal(self.dependentControls, enabled);
end

function BlizzardOptionsPanel_SetControlsEnabled (self, enabled)
	SetControlsEnabledInternal(self.controls, enabled);
end

local function RunControlsCallbacks(self, internalCallback, perControlCallback)
	perControlCallback = perControlCallback or nop;

	for _, control in SecureNext, self.controls do
		securecall(internalCallback, control, self, perControlCallback);
	end
end

function BlizzardOptionsPanel_Okay (self, perControlCallback)
	RunControlsCallbacks(self, BlizzardOptionsPanel_OkayControl, perControlCallback);
end

function BlizzardOptionsPanel_Cancel (self, perControlCallback)
	RunControlsCallbacks(self, BlizzardOptionsPanel_CancelControl, perControlCallback);
end

function BlizzardOptionsPanel_Default (self, perControlCallback)
	RunControlsCallbacks(self, BlizzardOptionsPanel_DefaultControl, perControlCallback);
end

function BlizzardOptionsPanel_Refresh (self, perControlCallback)
	RunControlsCallbacks(self, BlizzardOptionsPanel_RefreshControl, perControlCallback);
end

function BlizzardOptionsPanel_OnLoad (frame, okay, cancel, default, refresh)
	frame.okay = okay or BlizzardOptionsPanel_Okay;
	frame.cancel = cancel or BlizzardOptionsPanel_Cancel;
	frame.default = default or BlizzardOptionsPanel_Default;
	frame.refresh = refresh or BlizzardOptionsPanel_Refresh;

	if ( frame:IsEventRegistered("PLAYER_ENTERING_WORLD") ) then
		frame.keepPEWRegistered = true;
	else
		frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	end

	if IsOnGlueScreen() then
		frame:RegisterEvent("FRAMES_LOADED");
	end

	if ( not frame:GetScript("OnEvent") ) then
		frame:SetScript("OnEvent", BlizzardOptionsPanel_OnEvent);
	end
end

function BlizzardOptionsPanel_OnEvent (frame, event, ...)
	local shouldSetupControls = (IsOnGlueScreen() and event == "FRAMES_LOADED") or (event == "PLAYER_ENTERING_WORLD");

	if shouldSetupControls then
		if ( frame.options and frame.controls ) then
			local entry;
			local minValue, maxValue;
			for i, control in SecureNext, frame.controls do
				entry = frame.options[(control.cvar or control.label)];
				if ( entry ) then
					if ( entry.text ) then
						control.tooltipText = (_G["OPTION_TOOLTIP_" .. gsub(entry.text, "_TEXT$", "")] or entry.tooltip);
						local text = _G[control:GetName() .. "Text"];
						if ( text ) then
							text:SetText(_G[entry.text] or entry.text);
						end
					end
					control.tooltipRequirement = entry.tooltipRequirement;

					control.gameRestart = entry.gameRestart;
					control.logout = entry.logout;

					control.event = entry.event or entry.text;

					if ( control.cvar ) then
						if ( control.type == CONTROLTYPE_CHECKBOX ) then
							control.defaultValue = control.defaultValue or GetCVarDefault(control.cvar);
						else
							control.defaultValue = BlizzardOptionsPanel_GetCVarDefaultSafe(control.cvar);
							minValue = entry.minValue;
							maxValue = entry.maxValue;
						end
					else
						control.defaultValue = control.defaultValue or entry.default;
						minValue = entry.minValue;
						maxValue = entry.maxValue;
					end

					if ( control.type == CONTROLTYPE_SLIDER ) then
						BackdropTemplateMixin.OnBackdropLoaded(control);
						BlizzardOptionsPanel_Slider_Enable(control);
						control:SetMinMaxValues(minValue, maxValue);
						control:SetValueStep(entry.valueStep);
					end

					securecall(BlizzardOptionsPanel_SetupControl, control);
				end
			end
		end
		if ( not frame.keepPEWRegistered ) then
			frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
		end

		if IsOnGlueScreen() then
			frame:UnregisterEvent("FRAMES_LOADED");
		end
	end
end

function BlizzardOptionsPanel_RegisterControl (control, parentFrame)
	if ( ( not parentFrame ) or ( not control ) ) then
		return;
	end

	parentFrame.controls = parentFrame.controls or {};

	tinsert(parentFrame.controls, control);

	-- Use the panel's OnEvent handler to wait and setup the control after game data is loaded
end

function BlizzardOptionsPanel_SetupControl (control)
	if ( control.type == CONTROLTYPE_CHECKBOX ) then
		if ( control.cvar ) then
			local value = GetCVar(control.cvar);
			control.value = value;

			if ( control.uvar ) then
				_G[control.uvar] = value;
			end

			control.GetValue = function(self) return GetCVar(self.cvar); end
			control.SetValue = function(self, value) self.newValue = value; BlizzardOptionsPanel_SetCVarSafe(self.cvar, value, self.event); if ( self.uvar ) then _G[self.uvar] = value end end
			control.Disable = function (self) getmetatable(self).__index.Disable(self) _G[self:GetName().."Text"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end;
			control.Enable = function (self)
				getmetatable(self).__index.Enable(self);
				local text = _G[self:GetName().."Text"];
				local fontObject = text:GetFontObject();
				_G[self:GetName().."Text"]:SetTextColor(fontObject:GetTextColor());
			end
		elseif ( control.GetValue ) then
			if ( control.type == CONTROLTYPE_CHECKBOX ) then
				local value = control:GetValue();
				if ( value ) then
					control.value = tostring(value);
				else
					control.value = "0";
				end
				if ( control.uvar ) then
					_G[control.uvar] = value;
				end

				control.SetValue = function(self, value) self.newValue = value; if ( self.uvar ) then _G[self.uvar] = value; end end;
				control.Disable = function (self) getmetatable(self).__index.Disable(self) _G[self:GetName().."Text"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end;
				control.Enable = function (self)
					getmetatable(self).__index.Enable(self);
					local text = _G[self:GetName().."Text"];
					local fontObject = text:GetFontObject();
					_G[self:GetName().."Text"]:SetTextColor(fontObject:GetTextColor());
				end
			end
		end
	elseif ( control.type == CONTROLTYPE_SLIDER ) then
		local value;
		if ( control.GetCurrentValue ) then
			value = control:GetCurrentValue();
		elseif ( control.cvar ) then
			value = BlizzardOptionsPanel_GetCVarSafe(control.cvar);
		else
			value = control:GetValue();
		end

		if ( control.SetDisplayValue ) then
			control:SetDisplayValue(value);
		else
			control:SetValue(value);
		end
		-- set the value AFTER the set value function call so the current value matches the new value
		-- just in case an OnValueChange script changed the new value
		control.value = value;

		control.Disable = BlizzardOptionsPanel_Slider_Disable;
		control.Enable = BlizzardOptionsPanel_Slider_Enable;
	end
end

function BlizzardOptionsPanel_SetupDependentControl (dependency, control)
	if ( not dependency ) then
		return;
	end

	assert(control);

	dependency.dependentControls = dependency.dependentControls or {};
	tinsert(dependency.dependentControls, control);

	if ( control.type ~= CONTROLTYPE_DROPDOWN ) then
		control.Disable = function (self) getmetatable(self).__index.Disable(self) _G[self:GetName().."Text"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end;
		control.Enable = function (self) getmetatable(self).__index.Enable(self) _G[self:GetName().."Text"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b) end;
	else
		control.Disable = function (self) UIDropDownMenu_DisableDropDown(self) end;
		control.Enable = function (self) UIDropDownMenu_EnableDropDown(self) end;
	end
end

