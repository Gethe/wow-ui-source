MacKeyboardOptionsFrameCheckButtons = { };
MacKeyboardOptionsFrameCheckButtons["MAC_DISABLE_OS_SHORTCUTS"] = { index = 9, cvar = "MacDisableOsShortcuts", tooltipText = MAC_DISABLE_OS_SHORTCUTS_TOOLTIP};
MacKeyboardOptionsFrameCheckButtons["MAC_USE_COMMAND_LEFT_CLICK_AS_RIGHT_CLICK"] = { index = 10, cvar = "MacUseCommandLeftClickAsRightClick", tooltipText = MAC_USE_COMMAND_LEFT_CLICK_AS_RIGHT_CLICK_TOOLTIP};

local function MacKeyboardOptions_Okay (self)
	MacKeyboardOptionsFrame_Save()
end

local function MacKeyboardOptions_Cancel (self)

end

local function MacKeyboardOptions_Default (self)
	MacKeyboardOptionsFrame_SetDefaults();
end

local function MacKeyboardOptions_Refresh (self)
	MacKeyboardOptionsFrame_Update();
end

function MacKeyboardOptionsFrame_OnLoad(self)
	if(IsMacClient()) then
		self.name = KEYBOARD_HEADER;
		self.hasApply = true;
		BlizzardOptionsPanel_OnLoad(self, MacKeyboardOptions_Okay, MacKeyboardOptions_Cancel, MacKeyboardOptions_Default, MacKeyboardOptions_Refresh);
		OptionsFrame_AddCategory(VideoOptionsFrame, self);
	end
end

function MacOptionsFrame_DisableText(text)
	text:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function MacOptionsFrame_DisableSlider(slider)
	local name = slider:GetName();
	local value = _G[name.."Value"];
	_G[name.."Thumb"]:Hide();
	MacOptionsFrame_DisableText( _G[name.."Text"] );
	MacOptionsFrame_DisableText( _G[name.."Low"] );
	MacOptionsFrame_DisableText( _G[name.."High"] );
	slider:Disable();
	if ( value ) then
		value:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end

function MacKeyboardOptionsFrame_Update()
	for index, value in pairs(MacKeyboardOptionsFrameCheckButtons) do
		local button = _G["MacKeyboardOptionsFrameCheckButton"..value.index];
		local string = _G["MacKeyboardOptionsFrameCheckButton"..value.index.."Text"];
		local checked = GetCVar(value.cvar);
		button:SetChecked(checked and checked ~= "0");
		button.setFunc = function(checked)
			VideoOptionsFrameApply:Enable();		-- we have a change, enable the Apply button
		end;

		string:SetText(_G[index]);
		button:SetHitRectInsets(0, -button:GetWidth() - string:GetWidth(), 0, 0);
		button.tooltipText = value.tooltipText;

		button.GetValue = function(self) return GetCVar(self.cvar); end
		button.SetValue = function(self, value)  end
	end

	local disableOSShortcutsButton = MacKeyboardOptionsFrameCheckButton9;
	disableOSShortcutsButton.setFunc = function(checked)
		VideoOptionsFrameApply:Enable();
		if ( (not MacOptions_IsUniversalAccessEnabled()) and (checked == "1")  ) then
			StaticPopup_Show("MAC_OPEN_UNIVERSAL_ACCESS");
			disableOSShortcutsButton:SetChecked(false);
		end
	end;

	if ( (not MacOptions_IsUniversalAccessEnabled()) and disableOSShortcutsButton:GetChecked() ) then
		disableOSShortcutsButton:SetChecked(false);
		SetCVar("MacDisableOSShortcuts", "0");
	end
end

function MacKeyboardOptionsFrame_Save()
	for index, value in pairs(MacKeyboardOptionsFrameCheckButtons) do
		local button = _G["MacKeyboardOptionsFrameCheckButton"..value.index];
		if ( button:GetChecked() ) then
			value.value = "1";
		else
			value.value = "0";
		end

		SetCVar(value.cvar, value.value, index);
	end
end

function MacKeyboardOptionsFrame_SetDefaults()
	local checkButton, slider;
	for index, value in pairs(MacKeyboardOptionsFrameCheckButtons) do
		checkButton = _G["MacKeyboardOptionsFrameCheckButton"..value.index];
		local checked = GetCVarDefault(value.cvar);
		checkButton:SetChecked(checked and checked ~= "0");
	end    
	MacKeyboardOptionsFrame_Save();
end

function MacOptionsFrame_DisableCheckBox(checkBox)
	--checkBox:SetChecked(false);
	checkBox:Disable();
	_G[checkBox:GetName().."Text"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function MacOptionsFrame_EnableCheckBox(checkBox, setChecked, checked, isWhite)
	if ( setChecked ) then
		checkBox:SetChecked(checked and checked ~= "0");
	end
	checkBox:Enable();
	if ( isWhite ) then
		_G[checkBox:GetName().."Text"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		_G[checkBox:GetName().."Text"]:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end
