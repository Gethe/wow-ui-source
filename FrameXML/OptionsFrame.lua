OPTIONS_FARCLIP_MIN = 177;
OPTIONS_FARCLIP_MAX = 777;

OptionsFrameCheckButtons = { };
OptionsFrameCheckButtons["DESKTOP_GAMMA"] = { index = 1, cvar = "desktopGamma", tooltipText = OPTION_TOOLTIP_USE_DESKTOP_GAMMA};
OptionsFrameCheckButtons["TERRAIN_HIGHLIGHTS"] = { index = 2, cvar = "specular", dependency = "ENABLE_ALL_SHADERS", tooltipText = OPTION_TOOLTIP_TERRAIN_HIGHLIGHTS, tooltipRequirement = OPTION_LOGOUT_REQUIREMENT};
OptionsFrameCheckButtons["FULL_SCREEN_GLOW"] = { index = 3, cvar = "ffxGlow", dependency = "ENABLE_ALL_SHADERS", tooltipText = OPTION_TOOLTIP_FULL_SCREEN_GLOW};
OptionsFrameCheckButtons["TRILINEAR_FILTERING"] = { index = 4, cvar = "trilinear", tooltipText = OPTION_TOOLTIP_TRILINEAR, restartClient = 1, tooltipRequirement = OPTION_RESTART_REQUIREMENT};
OptionsFrameCheckButtons["VERTICAL_SYNC"] = { index = 5, cvar = "gxVSync", tooltipText = OPTION_TOOLTIP_VERTICAL_SYNC, gxRestart = 1};
OptionsFrameCheckButtons["CINEMATIC_SUBTITLES"] = { index = 6, cvar = "movieSubtitle", tooltipText = OPTION_TOOLTIP_CINEMATIC_SUBTITLES};
OptionsFrameCheckButtons["WORLD_LOD"] = { index = 7, cvar = "lod", tooltipText = OPTION_TOOLTIP_WORLD_LOD};
OptionsFrameCheckButtons["VERTEX_ANIMATION_SHADERS"] = { index = 8, cvar = "M2UseShaders", tooltipText = OPTION_TOOLTIP_VERTEX_ANIMATION_SHADERS, tooltipRequirement = OPTION_LOGOUT_REQUIREMENT};
OptionsFrameCheckButtons["USE_UISCALE"] = { index = 9, cvar = "useUiScale", tooltipText = OPTION_TOOLTIP_USE_UISCALE};
OptionsFrameCheckButtons["WINDOWED_MODE"] = { index = 10, cvar = "gxWindow", tooltipText = OPTION_TOOLTIP_WINDOWED_MODE, gxRestart = 1};
OptionsFrameCheckButtons["ENABLE_ALL_SHADERS"] = { index = 11, cvar = "pixelShaders", tooltipText = OPTION_TOOLTIP_ENABLE_ALL_SHADERS};
OptionsFrameCheckButtons["DEATH_EFFECT"] = { index = 12, cvar = "ffxDeath", dependency = "ENABLE_ALL_SHADERS", tooltipText = OPTION_TOOLTIP_DEATH_EFFECT};
OptionsFrameCheckButtons["TRIPLE_BUFFER"] = { index = 13, cvar = "gxTripleBuffer", dependency = "VERTICAL_SYNC", tooltipText = OPTION_TOOLTIP_BUFFERING, gxRestart = 1};
OptionsFrameCheckButtons["HARDWARE_CURSOR"] = { index = 14, cvar = "gxCursor", tooltipText = OPTION_TOOLTIP_HARDWARE_CURSOR, gxRestart = 1};
OptionsFrameCheckButtons["PHONG_SHADING"] = { index = 15, cvar = "M2UsePixelShaders", dependency = "VERTEX_ANIMATION_SHADERS", tooltipText = OPTION_TOOLTIP_PHONG_SHADING, };
OptionsFrameCheckButtons["FIX_LAG"] = { index = 16, cvar = "gxFixLag", dependency = "HARDWARE_CURSOR", tooltipText = OPTION_TOOLTIP_FIX_LAG, gxRestart = 1};
OptionsFrameCheckButtons["WINDOWED_MAXIMIZED"] = { index = 17, cvar = "gxMaximize", dependency = "WINDOWED_MODE", tooltipText = OPTION_TOOLTIP_WINDOWED_MAXIMIZED, gxRestart = 1};
OptionsFrameCheckButtons["USE_WEATHER_SHADER"] = { index = 18, cvar = "useWeatherShaders", tooltipText = OPTION_TOOLTIP_USE_WEATHER_SHADER};

OptionsFrameSliders = {
	{ text = UI_SCALE, func = "uiscale", minValue = 0.64, maxValue = 1.0, valueStep = 0.01 , tooltipText = OPTION_TOOLTIP_UI_SCALE},
	{ text = FARCLIP, func = "farclip", minValue = OPTIONS_FARCLIP_MIN, maxValue = OPTIONS_FARCLIP_MAX, valueStep = (OPTIONS_FARCLIP_MAX - OPTIONS_FARCLIP_MIN)/10 , tooltipText = OPTION_TOOLTIP_FARCLIP},
	{ text = ENVIRONMENT_DETAIL, func = "WorldDetail", minValue = 0, maxValue = 2, valueStep = 1 , tooltipText = OPTION_TOOLTIP_ENVIRONMENT_DETAIL},
	{ text = TERRAIN_MIP, func = "TerrainMip", minValue = 0, maxValue = 1, valueStep = 1 , tooltipText = OPTION_TOOLTIP_TERRAIN_TEXTURE, restartClient = 1, tooltipRequirement = OPTION_RESTART_REQUIREMENT},
	{ text = TEXTURE_DETAIL, func = "BaseMip", minValue = 0, maxValue = 1, valueStep = 1 , tooltipText = OPTION_TOOLTIP_TEXTURE_DETAIL},
	{ text = GAMMA, func = "Gamma", cvar1="gamma", minValue = -0.5, maxValue = 0.5, valueStep = 0.1 , tooltipText = OPTION_TOOLTIP_GAMMA},
	{ text = ANISOTROPIC, func = "anisotropic", minValue = 1, maxValue = 4, valueStep = 1 , tooltipText = OPTION_TOOLTIP_ANISOTROPIC, restartClient = 1, tooltipRequirement = OPTION_RESTART_REQUIREMENT},
	{ text = SPELL_DETAIL, func = "spellEffectLevel", minValue = 0, maxValue = 2, valueStep = 1 , tooltipText = OPTION_TOOLTIP_SPELL_DETAIL},
	{ text = WEATHER_DETAIL, func = "weatherDensity", minValue = 0, maxValue = 3, valueStep = 1 , tooltipText = OPTION_TOOLTIP_WEATHER_DETAIL},
};

ANISOTROPIC_VALUES = {"1", "2", "4", "8", "16"};

OPTIONS_FRAME_WIDTH = 495;

function OptionsFrame_Init()
	--[[for index, value in OptionsFrameCheckButtons do
		local string = GetCVar(value.cvar);
		value.value = string;
	end]]
	this:RegisterEvent("CVAR_UPDATE");
end

function OptionsFrame_OnEvent()
	if ( event == "CVAR_UPDATE" ) then
		local info = OptionsFrameCheckButtons[arg1];
		if ( info ) then
			info.value = arg2;
		end
	end
end

function OptionsFrame_Load()
	local shadersEnabled = GetCVar("pixelShaders");
	local hasAnisotropic, hasPixelShaders, hasVertexShaders, hasTrilinear, hasTripleBuffering, maxAnisotropy, hasHardwareCursor = GetVideoCaps();
	for index, value in OptionsFrameCheckButtons do
		local button = getglobal("OptionsFrameCheckButton"..value.index);
		local string = getglobal("OptionsFrameCheckButton"..value.index.."Text");
		local checked;
		checked = GetCVar(value.cvar);

		string:SetText(TEXT(getglobal(index)));
		button.tooltipText = value.tooltipText;
		button.tooltipRequirement = value.tooltipRequirement;
		button.gxRestart = value.gxRestart;
		button.restartClient = value.restartClient;

		-- Enable disable checkboxes
		button.disabled = nil;
		if ( index == "ENABLE_ALL_SHADERS" ) then
			if ( not hasPixelShaders ) then
				button.disabled = 1;
			end
		elseif ( index == "VERTEX_ANIMATION_SHADERS" ) then
			if ( not hasVertexShaders ) then
				button.disabled = 1;
			end
		elseif ( index == "TRILINEAR_FILTERING" ) then
			if ( not hasTrilinear ) then
				button.disabled = 1;
			end
		elseif ( index == "TRIPLE_BUFFER" ) then
			if ( not hasTripleBuffering or GetCVar("gxVSync") ~= "1" ) then
				button.disabled = 1;
			end
		elseif ( index == "HARDWARE_CURSOR" ) then
			if ( not hasHardwareCursor ) then
				button.disabled = 1;
			end
		end

		if ( button.disabled ) then
			OptionsFrame_DisableCheckBox(button);
		else
			OptionsFrame_EnableCheckBox(button, 1, checked);
		end
		
		if ( index == "ENABLE_ALL_SHADERS" and hasPixelShaders ) then
			string:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	end
	for index, value in OptionsFrameSliders do
		local slider = getglobal("OptionsFrameSlider"..index);
		local string = getglobal("OptionsFrameSlider"..index.."Text");
		local thumb = getglobal("OptionsFrameSlider"..index.."Thumb");
		local getvalue = getglobal("Get"..value.func);
		slider.disabled = nil;
		if ( getvalue ) then
			getvalue = getvalue();	
		elseif ( value.func == "anisotropic" ) then
			if ( hasAnisotropic ) then
				-- Map cvar to a slider value from 1 - 4, since sliders can't move up by geometric increments
				local cvarValue = GetCVar("anisotropic");
				for i=1, getn(ANISOTROPIC_VALUES) do
					if ( cvarValue == ANISOTROPIC_VALUES[i] ) then
						getvalue = i;
					end
					if ( maxAnisotropy == tonumber(ANISOTROPIC_VALUES[i]) ) then
						maxAnisotropy = i;
					end
				end
				if ( maxAnisotropy ) then
					value.maxValue = maxAnisotropy;
				end
			else
				-- dummy value since slider is disabled
				getvalue = 1;
				slider.disabled = 1;
			end
		else
			getvalue = GetCVar(value.func);			
		end

		if ( slider.disabled ) then
			OptionsFrame_DisableSlider(slider);
		else
			OptionsFrame_EnableSlider(slider);
		end

		slider:SetMinMaxValues(value.minValue, value.maxValue);
		slider:SetValueStep(value.valueStep);
		slider:SetValue(getvalue);
		string:SetText(TEXT(value.text));
		slider.tooltipText = value.tooltipText;
		slider.tooltipRequirement = value.tooltipRequirement;
		slider.gxRestart = value.gxRestart;
		slider.restartClient = value.restartClient;
	end
	OptionsFrame.gamma = GetGamma();
	OptionsFrame.desktopGamma = GetCVar("desktopGamma");
	OptionsFrame.GXRestart = nil;
	OptionsFrame.ClientRestart = nil;

	-- Enable or disable buffering dropdown
	if ( hasTripleBuffering == 1 ) then
		OptionsFrameCheckButton13:Show();
		OptionsFrameCheckButton6:SetPoint("TOP", "OptionsFrameCheckButton5", "BOTTOM", 0, -20);
	else
		OptionsFrameCheckButton13:Hide();
		-- Reposition subtitles button
		OptionsFrameCheckButton6:SetPoint("TOP", "OptionsFrameCheckButton5", "BOTTOM", 0, 2);
	end
	-- Update option dependencies
	OptionsFrame_UpdateCheckboxes();
	-- Update gamma
	OptionsFrame_UpdateGammaControls();
	-- Update ui scale
	OptionsFrame_UpdateUIScaleControls();

	-- Resize the options frame
	OptionsFrame:SetWidth(OPTIONS_FRAME_WIDTH);
	OptionsFrameDisplay:SetWidth(OPTIONS_FRAME_WIDTH - 25);
	OptionsFrameWorldAppearance:SetWidth(OPTIONS_FRAME_WIDTH - 25);
	OptionsFrameBrightness:SetWidth(OPTIONS_FRAME_WIDTH - 25);
	OptionsFramePixelShaders:SetWidth(OPTIONS_FRAME_WIDTH/2 - 13);
	OptionsFrameMiscellaneous:SetWidth(OPTIONS_FRAME_WIDTH/2 - 13);
end

function OptionsFrame_Save()
	for index, value in OptionsFrameCheckButtons do
		local button = getglobal("OptionsFrameCheckButton"..value.index);
		if ( button:GetChecked() ) then
			value.value = "1";
		else
			value.value = "0";
		end

		SetCVar(value.cvar, value.value, index);
		
		if ( value.value ~= GetCVar(value.cvar) ) then
			if ( button.gxRestart ) then
				OptionsFrame.GXRestart = 1;
			elseif ( button.restartClient ) then
				OptionsFrame.ClientRestart = 1;
			end
		end
		
		if ( index == "ENABLE_ALL_SHADERS" ) then
			SetCVar("ffx", value.value);
		end
	end
	for index, value in OptionsFrameSliders do
		local slider = getglobal("OptionsFrameSlider"..index);
		local setvalue = getglobal("Set"..value.func);
		local getvalue = getglobal("Get"..value.func);
		if ( value.func == "anisotropic" ) then
			-- Convert back from slider value to actual anisotropic setting
			local anisotropicValue = ANISOTROPIC_VALUES[slider:GetValue()];
			if ( GetCVar("anisotropic") ~= anisotropicValue ) then
				OptionsFrame.ClientRestart = 1;
				SetCVar("anisotropic", anisotropicValue);
			end
		elseif ( not setvalue ) then
			if ( slider:GetValue() ~= GetCVar(value.func) ) then
				if ( slider.gxRestart ) then
					OptionsFrame.GXRestart = 1;
				elseif ( slider.restartClient ) then
					OptionsFrame.ClientRestart = 1;
				end
			end
			SetCVar(value.func, slider:GetValue());
		else
			if ( slider:GetValue() ~= getvalue() ) then
				if ( slider.gxRestart ) then
					OptionsFrame.GXRestart = 1;
				elseif ( slider.restartClient ) then
					OptionsFrame.ClientRestart = 1;
				end
			end
			setvalue(slider:GetValue());
		end
	end
	OptionsFrame.gamma = GetGamma();
	OptionsFrame.desktopGamma = GetCVar("desktopGamma");
	SetScreenResolution(UIDropDownMenu_GetSelectedID(OptionsFrameResolutionDropDown));
	SetMultisampleFormat(UIDropDownMenu_GetSelectedID(OptionsFrameMultiSampleDropDown));
	-- If this value has changed then do a RestartGx
	if ( GetCVar("gxRefresh") ~= UIDropDownMenu_GetSelectedValue(OptionsFrameRefreshDropDown) ) then
		OptionsFrame.GXRestart = 1;
		SetCVar("gxRefresh", UIDropDownMenu_GetSelectedValue(OptionsFrameRefreshDropDown));
	end
	if ( OptionsFrame.GXRestart ) then
		RestartGx();
	end
	if ( OptionsFrame.ClientRestart ) then
		StaticPopup_Show("CLIENT_RESTART_ALERT");
	end

	-- Update scrolling combat text if it's loaded
	if ( CombatText_UpdateDisplayedMessages ) then
		CombatText_UpdateDisplayedMessages();
	end
end

function OptionsFrame_Cancel()
	SetGamma(OptionsFrame.gamma);
	SetCVar("desktopGamma", OptionsFrame.desktopGamma);
end

function OptionsFrameResolutionDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, OptionsFrameResolutionDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(this, GetCurrentResolution(), 1);
	UIDropDownMenu_SetWidth(90, OptionsFrameResolutionDropDown);
end

function OptionsFrameResolutionDropDown_Initialize()
	OptionsFrameResolutionDropDown_LoadResolutions(GetScreenResolutions());	
end

function OptionsFrameResolutionDropDown_LoadResolutions(...)
	local info;
	local resolution, xIndex, width, height;
	for i=1, arg.n, 1 do
		checked = nil;
		info = {};
		resolution = arg[i];
		xIndex = strfind(resolution, "x");
		width = strsub(resolution, 1, xIndex-1);
		height = strsub(resolution, xIndex+1, strlen(resolution));
		if ( width/height > 4/3 ) then
			resolution = resolution.." "..WIDESCREEN_TAG;
		end
		info.text = resolution;
		info.value = arg[i];
		info.func = OptionsFrameResolutionButton_OnClick;
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

function OptionsFrameResolutionButton_OnClick()
	UIDropDownMenu_SetSelectedID(OptionsFrameResolutionDropDown, this:GetID(), 1);
end

function OptionsFrameRefreshDropDown_OnLoad()
	UIDropDownMenu_SetSelectedValue(this, GetCVar("gxRefresh"));
	UIDropDownMenu_Initialize(this, OptionsFrameRefreshDropDown_Initialize);
	UIDropDownMenu_SetWidth(90, OptionsFrameRefreshDropDown);
end

function OptionsFrameRefreshDropDown_Initialize()
	OptionsFrame_GetRefreshRates(GetRefreshRates());
end

function OptionsFrame_GetRefreshRates(...)
	local info = {};
	local checked;
	if ( arg.n == 1 and arg[1] == 0 ) then
		OptionsFrameRefreshDropDownButton:Disable();
		OptionsFrameRefreshDropDownLabel:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		OptionsFrameRefreshDropDownText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		return;
	end
	for i=1, arg.n do
		info = {};
		info.text = arg[i]..HERTZ;
		info.func = OptionsFrameRefreshDropDown_OnClick;
		
		if ( UIDropDownMenu_GetSelectedValue(OptionsFrameRefreshDropDown) and tonumber(UIDropDownMenu_GetSelectedValue(OptionsFrameRefreshDropDown)) == arg[i] ) then
			checked = 1;
			UIDropDownMenu_SetText(info.text, OptionsFrameRefreshDropDown);
		else
			checked = nil;
		end
		info.value = arg[i]
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

function OptionsFrameRefreshDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(OptionsFrameRefreshDropDown, this.value);
end

function OptionsFrameMultiSampleDropDown_OnLoad()
	UIDropDownMenu_SetSelectedID(this, GetCurrentMultisampleFormat());
	UIDropDownMenu_Initialize(this, OptionsFrameMultiSampleDropDown_Initialize);
	UIDropDownMenu_SetWidth(140, OptionsFrameMultiSampleDropDown);
	UIDropDownMenu_SetAnchor(-5, 23, nil, "TOPRIGHT", "OptionsFrameMultiSampleDropDownRight", "BOTTOMRIGHT");
end

function OptionsFrameMultiSampleDropDown_Initialize()
	OptionsFrame_GetMultisampleFormats(GetMultisampleFormats());
end

function OptionsFrame_GetMultisampleFormats(...)
	local colorBits, depthBits, multiSample;
	local info, checked;
	local index = 1;
	for i=1, arg.n, 3 do
		colorBits = arg[i];
		depthBits = arg[i+1];
		multiSample = arg[i+2];
		info = {};
		info.text = format(MULTISAMPLING_FORMAT_STRING, colorBits, depthBits, multiSample);
		info.func = OptionsFrameMultiSampleDropDown_OnClick;
		
		if ( index == UIDropDownMenu_GetSelectedID(OptionsFrameMultiSampleDropDown) ) then
			checked = 1;
			UIDropDownMenu_SetText(info.text, OptionsFrameMultiSampleDropDown);
		else
			checked = nil;
		end
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
		index = index + 1;
	end
end

function OptionsFrameMultiSampleDropDown_OnClick()
	UIDropDownMenu_SetSelectedID(OptionsFrameMultiSampleDropDown, this:GetID());
end

function OptionsFrame_UpdateCheckboxes()
	for index, value in OptionsFrameCheckButtons do
		if ( value.dependency ) then
			local button = getglobal("OptionsFrameCheckButton"..value.index);	
			local dependency = getglobal("OptionsFrameCheckButton"..OptionsFrameCheckButtons[value.dependency].index);
			local enable = dependency:GetChecked();
			if ( enable and index == "TRIPLE_BUFFER" ) then
				local hasAnisotropic, hasPixelShaders, hasVertexShaders, hasTrilinear, hasTripleBuffering, maxAnisotropy, hasHardwareCursor = GetVideoCaps();
				if ( not hasTripleBuffering ) then
					enable = false;
				end
			end
			if ( enable ) then
				OptionsFrame_EnableCheckBox(button);
			else
				OptionsFrame_DisableCheckBox(button);
			end
		end
	end
end

function OptionsFrame_UpdateGammaControls()
	local value = "0";
	if ( OptionsFrameCheckButton1:GetChecked() or OptionsFrameCheckButton10:GetChecked() ) then
		OptionsFrame_DisableSlider(OptionsFrameSlider6);
		value = "1";
	else
		OptionsFrame_EnableSlider(OptionsFrameSlider6);
	end
	SetCVar("desktopGamma", value);
end

function OptionsFrame_UpdateUIScaleControls()
	if ( OptionsFrameCheckButton9:GetChecked() ) then
		OptionsFrame_EnableSlider(OptionsFrameSlider1);
	else
		OptionsFrame_DisableSlider(OptionsFrameSlider1);
	end
end

function OptionsFrame_SetDefaults()
	local checkButton, slider;
	for index, value in OptionsFrameCheckButtons do
		checkButton = getglobal("OptionsFrameCheckButton"..value.index);
		checkButton:SetChecked(GetCVarDefault(value.cvar));
	end
	OptionsFrame_UpdateCheckboxes();
	OptionsFrame_UpdateGammaControls();
	OptionsFrame_UpdateUIScaleControls();
	local sliderValue;
	for index, value in OptionsFrameSliders do
		slider = getglobal("OptionsFrameSlider"..index);
		if ( value.func == "WorldDetail" ) then
			sliderValue = GetCVarDefault("smallCull");
			sliderValue = sliderValue + 0;
			if ( sliderValue <= 0.07 ) then
				sliderValue = 0;
			elseif ( sliderValue <= 0.04 ) then
				sliderValue = 1;
			elseif ( sliderValue <= 0.01 ) then
				sliderValue = 2;
			end
		elseif ( value.func == "TerrainMip" ) then
			sliderValue = 1 - GetCVarDefault("shadowLevel");
		elseif ( value.func == "BaseMip" ) then
			sliderValue = 1 - GetCVarDefault("baseMip");
		elseif ( value.func == "Gamma" ) then
			sliderValue = 1 - GetCVarDefault("gamma");
		else
			sliderValue = GetCVarDefault(value.func);
		end
		slider:SetValue(sliderValue);
	end
	--OptionsFrameRefreshDropDown_Initialize();
	UIDropDownMenu_Initialize(OptionsFrameRefreshDropDown, OptionsFrameRefreshDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(OptionsFrameRefreshDropDown, "60");
	--OptionsFrameResolutionDropDown_Initialize();
	UIDropDownMenu_Initialize(OptionsFrameResolutionDropDown, OptionsFrameResolutionDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(OptionsFrameResolutionDropDown, "1024x768");

	-- Update video settings
	RestoreVideoDefaults();
end

function OptionsFrame_DisableCheckBox(checkBox)
	--checkBox:SetChecked(0);
	checkBox:Disable();
	getglobal(checkBox:GetName().."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function OptionsFrame_EnableCheckBox(checkBox, setChecked, checked, isWhite)
	if ( setChecked ) then
		checkBox:SetChecked(checked);
	end
	checkBox:Enable();
	if ( isWhite ) then
		getglobal(checkBox:GetName().."Text"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		getglobal(checkBox:GetName().."Text"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	
end

function OptionsFrame_DisableSlider(slider)
	local name = slider:GetName();
	getglobal(name.."Thumb"):Hide();
	getglobal(name.."Text"):SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	getglobal(name.."Low"):SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	getglobal(name.."High"):SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function OptionsFrame_EnableSlider(slider)
	local name = slider:GetName();
	getglobal(name.."Thumb"):Show();
	getglobal(name.."Text"):SetVertexColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b);
	getglobal(name.."Low"):SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	getglobal(name.."High"):SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end

function OptionsFrame_DisableDropDown(dropDown)
	getglobal(dropDown:GetName().."Label"):SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	getglobal(dropDown:GetName().."Text"):SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	getglobal(dropDown:GetName().."Button"):Disable();
end

function OptionsFrame_EnableDropDown(dropDown)
	getglobal(dropDown:GetName().."Label"):SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	getglobal(dropDown:GetName().."Text"):SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	getglobal(dropDown:GetName().."Button"):Enable();
end

function PlayClickSound()
	if ( this:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
end
