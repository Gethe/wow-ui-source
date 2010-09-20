
-- if you change something here you probably want to change the glue version too

CONTROLTYPE_CHECKBOX = 1;
CONTROLTYPE_DROPDOWN = 2;
CONTROLTYPE_SLIDER = 3;


local ALT_KEY = "altkey";
local CONTROL_KEY = "controlkey";
local SHIFT_KEY = "shiftkey";
local NO_KEY = "none";

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
	local name = slider:GetName();
	getmetatable(slider).__index.Disable(slider);
	_G[name.."Text"]:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	_G[name.."Low"]:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	_G[name.."High"]:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function BlizzardOptionsPanel_Slider_Enable (slider)
	local name = slider:GetName();
	getmetatable(slider).__index.Enable(slider);
	_G[name.."Text"]:SetVertexColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b);
	_G[name.."Low"]:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	_G[name.."High"]:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
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
	self.value = value;
	BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
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

function BlizzardOptionsPanel_CheckButton_OnClick (checkButton)
	BlizzardOptionsPanel_CheckButton_SetNewValue(checkButton);

	local setting = "0";
	if ( checkButton:GetChecked() ) then
		if ( not checkButton.invert ) then
			setting = "1";
		end
	elseif ( checkButton.invert ) then
		setting = "1";
	end

	if ( checkButton.setFunc ) then
		checkButton.setFunc(setting);
	end
end

function BlizzardOptionsPanel_CheckButton_SetNewValue (checkButton)
	local setting = "0";
	if ( checkButton:GetChecked() ) then
		if ( not checkButton.invert ) then
			setting = "1";
		end
	elseif ( checkButton.invert ) then
		setting = "1";
	end

	if ( setting == checkButton.value ) then
		checkButton.newValue = nil;
	else
		checkButton.newValue = setting;
	end

	if ( checkButton.dependentControls ) then
		if ( checkButton:GetChecked() ) then
			for _, control in SecureNext, checkButton.dependentControls do
				control:Enable();
			end
		else
			for _, control in SecureNext, checkButton.dependentControls do
				control:Disable();
			end
		end
	end
end

function BlizzardOptionsPanel_CheckButton_Refresh (checkButton)
	local value;

	if ( checkButton.cvar ) then
		value = GetCVar(checkButton.cvar);
	elseif ( checkButton.GetValue ) then
		value = tostring(checkButton:GetValue());
	end

	if ( value ) then
		if ( not checkButton.invert ) then
			if ( value == "1" ) then
				checkButton:SetChecked(true);
			else
				checkButton:SetChecked(false);
			end
		else
			if ( value == "0" ) then
				checkButton:SetChecked(true);
			else
				checkButton:SetChecked(false);
			end
		end

		if ( checkButton.dependentControls ) then
			if ( checkButton:GetChecked() ) then
				for _, depControl in SecureNext, checkButton.dependentControls do
					depControl:Enable();
				end
			else
				for _, depControl in SecureNext, checkButton.dependentControls do
					depControl:Disable();
				end
			end
		end

		checkButton.value = value;
	end
end

-- [[ DropDown functions ]] --

function BlizzardOptionsPanel_DropDown_Refresh (dropDown)
	if ( dropDown.RefreshValue ) then
		dropDown:RefreshValue();
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

function BlizzardOptionsPanel_GetCVarMinSafe (cvar)
	local value = GetCVarMin(cvar);
	value = tonumber(value) or value;
	return value;
end

function BlizzardOptionsPanel_GetCVarMaxSafe (cvar)
	local value = GetCVarMax(cvar);
	value = tonumber(value) or value;
	return value;
end

function BlizzardOptionsPanel_OkayControl (control)
	if ( control.newValue ) then
		if ( control.value ~= control.newValue ) then
			control:SetValue(control.newValue);
			control.value = control.newValue;
			control.newValue = nil;
		end
	elseif ( control.value ) then
		if ( control:GetValue() ~= control.value ) then
			control:SetValue(control.value);
		end
	end
end

function BlizzardOptionsPanel_CancelControl (control)
	if ( control.newValue ) then
		if ( control.value and control.value ~= control.newValue ) then
			-- we need to force-set the value here just in case the control was doing dynamic updating
			control:SetValue(control.value);
			control.newValue = nil;
		end
	elseif ( control.value ) then
		if ( control:GetValue() ~= control.value ) then
			control:SetValue(control.value);
		end
	end
end

function BlizzardOptionsPanel_DefaultControl (control)
	if ( control.defaultValue and control.value ~= control.defaultValue ) then
		control:SetValue(control.defaultValue);
		control.value = control.defaultValue;
		control.newValue = nil;
	end
end

function BlizzardOptionsPanel_RefreshControl (control)
	if ( control.type == CONTROLTYPE_CHECKBOX ) then
		BlizzardOptionsPanel_CheckButton_Refresh(control);
	elseif ( control.type == CONTROLTYPE_DROPDOWN ) then
		BlizzardOptionsPanel_DropDown_Refresh(control);
	elseif ( control.type == CONTROLTYPE_SLIDER ) then
		BlizzardOptionsPanel_Slider_Refresh(control);
	end
end

function BlizzardOptionsPanel_Okay (self)
	for _, control in SecureNext, self.controls do
		securecall(BlizzardOptionsPanel_OkayControl, control);
	end
end

function BlizzardOptionsPanel_Cancel (self)
	for _, control in SecureNext, self.controls do
		securecall(BlizzardOptionsPanel_CancelControl, control);
	end
end

function BlizzardOptionsPanel_Default (self)
	for _, control in SecureNext, self.controls do
		securecall(BlizzardOptionsPanel_DefaultControl, control);
	end
end

function BlizzardOptionsPanel_Refresh (self)
	for _, control in SecureNext, self.controls do
		securecall(BlizzardOptionsPanel_RefreshControl, control);
	end
end

function BlizzardOptionsPanel_OnLoad (frame, okay, cancel, default, refresh)
	frame.okay = okay or BlizzardOptionsPanel_Okay;
	frame.cancel = cancel or BlizzardOptionsPanel_Cancel;
	frame.default = default or BlizzardOptionsPanel_Default;
	frame.refresh = refresh or BlizzardOptionsPanel_Refresh;

	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:SetScript("OnEvent", BlizzardOptionsPanel_OnEvent);
end

function BlizzardOptionsPanel_OnEvent (frame, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
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
							control.defaultValue = GetCVarDefault(control.cvar);
						else
							control.defaultValue = BlizzardOptionsPanel_GetCVarDefaultSafe(control.cvar);
							minValue = BlizzardOptionsPanel_GetCVarMinSafe(control.cvar) or entry.minValue;
							maxValue = BlizzardOptionsPanel_GetCVarMaxSafe(control.cvar) or entry.maxValue;
						end
					else
						control.defaultValue = control.defaultValue or entry.default;
						minValue = entry.minValue;
						maxValue = entry.maxValue;
					end

					if ( control.type == CONTROLTYPE_SLIDER ) then
						BlizzardOptionsPanel_Slider_Enable(control);
						control:SetMinMaxValues(minValue, maxValue);
						control:SetValueStep(entry.valueStep);
					end

					securecall(BlizzardOptionsPanel_SetupControl, control);
				end
			end
		end
		frame:UnregisterEvent(event);	
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
			control.SetValue = function(self, value) self.value = value; BlizzardOptionsPanel_SetCVarSafe(self.cvar, value, self.event); if ( self.uvar ) then _G[self.uvar] = value end end
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

				control.SetValue = function(self, value) self.value = value; if ( self.uvar ) then _G[self.uvar] = value; end end;
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

