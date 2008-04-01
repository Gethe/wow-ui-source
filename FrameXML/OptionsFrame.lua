OPTIONS_FARCLIP_MIN = 177;
OPTIONS_FARCLIP_MAX = 777;

OptionsFrameCheckButtons = { };
OptionsFrameCheckButtons["WORLD_LOD"] = { index = 7, cvar = "lod" , tooltipText = OPTION_TOOLTIP_WORLD_LOD};
OptionsFrameCheckButtons["DESKTOP_GAMMA"] = { index = 1, cvar = "desktopGamma" , tooltipText = OPTION_TOOLTIP_USE_DESKTOP_GAMMA};
OptionsFrameCheckButtons["ENABLE_ALL_SHADERS"] = { index = 11, cvar = "pixelShaders" , tooltipText = OPTION_TOOLTIP_ENABLE_ALL_SHADERS};
OptionsFrameCheckButtons["TERRAIN_HIGHLIGHTS"] = { index = 2, cvar = "specular" , tooltipText = OPTION_TOOLTIP_TERRAIN_HIGHLIGHTS, tooltipRequirement = OPTION_LOGOUT_REQUIREMENT};
OptionsFrameCheckButtons["FULL_SCREEN_GLOW"] = { index = 3, cvar = "ffxGlow" , tooltipText = OPTION_TOOLTIP_FULL_SCREEN_GLOW};
OptionsFrameCheckButtons["DEATH_EFFECT"] = { index = 12, cvar = "ffxDeath" , tooltipText = OPTION_TOOLTIP_DEATH_EFFECT};
OptionsFrameCheckButtons["VERTEX_ANIMATION_SHADERS"] = { index = 8, cvar = "M2UseShaders" , tooltipText = OPTION_TOOLTIP_VERTEX_ANIMATION_SHADERS, tooltipRequirement = OPTION_LOGOUT_REQUIREMENT};
OptionsFrameCheckButtons["TRILINEAR_FILTERING"] = { index = 4, cvar = "trilinear" , tooltipText = OPTION_TOOLTIP_TRILINEAR, restartClient = 1, tooltipRequirement = OPTION_RESTART_REQUIREMENT};
OptionsFrameCheckButtons["VERTICAL_SYNC"] = { index = 5, cvar = "gxVSync" , tooltipText = OPTION_TOOLTIP_VERTICAL_SYNC, gxRestart = 1};
OptionsFrameCheckButtons["CINEMATIC_SUBTITLES"] = { index = 6, cvar = "movieSubtitle" , tooltipText = OPTION_TOOLTIP_CINEMATIC_SUBTITLES};
OptionsFrameCheckButtons["USE_UISCALE"] = { index = 9, cvar = "useUiScale" , tooltipText = OPTION_TOOLTIP_USE_UISCALE};
OptionsFrameCheckButtons["WINDOWED_MODE"] = { index = 10, cvar = "gxWindow" , tooltipText = OPTION_TOOLTIP_WINDOWED_MODE, gxRestart = 1};
OptionsFrameCheckButtons["TRIPLE_BUFFER"] = { index = 13, cvar = "gxTripleBuffer" , tooltipText = OPTION_TOOLTIP_BUFFERING, gxRestart = 1};
OptionsFrameCheckButtons["HARDWARE_CURSOR"] = { index = 14, cvar = "gxCursor" , tooltipText = OPTION_TOOLTIP_HARDWARE_CURSOR, gxRestart = 1};
OptionsFrameCheckButtons["PHONG_SHADING"] = { index = 15, cvar = "M2UsePixelShaders" , tooltipText = OPTION_TOOLTIP_PHONG_SHADING};

OptionsFrameSliders = {
	{ text = UI_SCALE, func = "uiscale", minValue = 0.64, maxValue = 1.0, valueStep = 0.05 , tooltipText = OPTION_TOOLTIP_UI_SCALE},
	{ text = FARCLIP, func = "farclip", minValue = OPTIONS_FARCLIP_MIN, maxValue = OPTIONS_FARCLIP_MAX, valueStep = (OPTIONS_FARCLIP_MAX - OPTIONS_FARCLIP_MIN)/10 , tooltipText = OPTION_TOOLTIP_FARCLIP},
	{ text = ENVIRONMENT_DETAIL, func = "WorldDetail", minValue = 0, maxValue = 2, valueStep = 1 , tooltipText = OPTION_TOOLTIP_ENVIRONMENT_DETAIL},
	{ text = TERRAIN_MIP, func = "TerrainMip", minValue = 0, maxValue = 1, valueStep = 1 , tooltipText = OPTION_TOOLTIP_TERRAIN_TEXTURE, restartClient = 1, tooltipRequirement = OPTION_RESTART_REQUIREMENT},
	{ text = TEXTURE_DETAIL, func = "BaseMip", minValue = 0, maxValue = 1, valueStep = 1 , tooltipText = OPTION_TOOLTIP_TEXTURE_DETAIL},
	{ text = GAMMA, func = "Gamma", cvar1="gamma", minValue = -0.5, maxValue = 0.5, valueStep = 0.1 , tooltipText = OPTION_TOOLTIP_GAMMA},
	{ text = ANISOTROPIC, func = "anisotropic", minValue = 1, maxValue = 4, valueStep = 1 , tooltipText = OPTION_TOOLTIP_ANISOTROPIC, restartClient = 1, tooltipRequirement = OPTION_RESTART_REQUIREMENT},
};

ANISOTROPIC_VALUES = {"1", "2", "4", "8", "16"};

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
	local hasAnisotropic, hasPixelShaders, hasVertexShaders, hasTrilinear, hasTripleBuffering, maxAnisotropy = GetVideoCaps();
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
		if ( index == "TERRAIN_HIGHLIGHTS" or index == "FULL_SCREEN_GLOW" or index == "DEATH_EFFECT" ) then
			if ( shadersEnabled ~= "1" or not hasPixelShaders ) then
				button.disabled = 1;
			end
		elseif ( index == "ENABLE_ALL_SHADERS" ) then
			if ( not hasPixelShaders ) then
				button.disabled = 1;
			end
		elseif ( index == "VERTEX_ANIMATION_SHADERS" or index == "PHONG_SHADING" ) then
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
		end

		if ( button.disabled ) then
			OptionsFrame_DisableCheckBox(button);
		else
			OptionsFrame_EnableCheckBox(button, checked);
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
					if ( maxAnisotropy == ANISOTROPIC_VALUES[i]+0 ) then
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
	-- Update gamma
	OptionsFrame_UpdateGammaControls();
	-- Update ui scale
	OptionsFrame_UpdateUIScaleControls();
	-- Update phong shading
	OptionsFrame_UpdatePhongShading();
end

function OptionsFrame_Save()
	for index, value in OptionsFrameCheckButtons do
		local button = getglobal("OptionsFrameCheckButton"..value.index);
		if ( button:GetChecked() ) then
			value.value = "1";
		else
			value.value = "0";
		end
		if ( value.value ~= GetCVar(value.cvar) ) then
			if ( button.gxRestart ) then
				OptionsFrame.GXRestart = 1;
			elseif ( button.restartClient ) then
				OptionsFrame.ClientRestart = 1;
			end
		end
		SetCVar(value.cvar, value.value, index);
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
	OptionsFrame_GetRefreshRates(GetRefreshRates(UIDropDownMenu_GetSelectedID(OptionsFrameRefreshDropDown)));
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
		
		if ( UIDropDownMenu_GetSelectedValue(OptionsFrameRefreshDropDown) and UIDropDownMenu_GetSelectedValue(OptionsFrameRefreshDropDown)+0 == arg[i] ) then
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

function OptionsFrame_UpdateGammaControls()
	local value = "0";
	if ( OptionsFrameCheckButton1:GetChecked() ) then
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

function OptionsFrame_UpdateShaderOptions(shadersEnabled)
	for index, value in OptionsFrameCheckButtons do
		local button = getglobal("OptionsFrameCheckButton"..value.index);
		local string = getglobal("OptionsFrameCheckButton"..value.index.."Text");	
		-- Enable disable shader checkboxes
		if ( index == "TERRAIN_HIGHLIGHTS" or index == "FULL_SCREEN_GLOW" or index == "DEATH_EFFECT" ) then
			if ( shadersEnabled ) then
				OptionsFrame_EnableCheckBox(button);
				button:SetChecked(GetCVar(value.cvar));
			else
				OptionsFrame_DisableCheckBox(button);
			end
		end
	end
end

function OptionsFrame_UpdateBuffering(tripleBufferingEnabled)
	if ( tripleBufferingEnabled ) then
		OptionsFrame_EnableCheckBox(OptionsFrameCheckButton13);
		OptionsFrameCheckButton13:SetChecked(GetCVar(OptionsFrameCheckButtons["TRIPLE_BUFFER"].cvar));
	else
		OptionsFrame_DisableCheckBox(OptionsFrameCheckButton13);
	end
end

function OptionsFrame_UpdatePhongShading()
	if ( OptionsFrameCheckButton8:GetChecked() ) then
		OptionsFrame_EnableCheckBox(OptionsFrameCheckButton15);
		OptionsFrameCheckButton15:SetChecked(GetCVar(OptionsFrameCheckButtons["PHONG_SHADING"].cvar));
	else
		OptionsFrame_DisableCheckBox(OptionsFrameCheckButton15);
	end
end

function OptionsFrame_SetDefaults()
	local checkButton, slider;
	local enableShaders;
	for index, value in OptionsFrameCheckButtons do
		checkButton = getglobal("OptionsFrameCheckButton"..value.index);
		checkButton:SetChecked(GetCVarDefault(value.cvar));
		if ( index == "ENABLE_ALL_SHADERS" ) then
			enableShaders = checkButton:GetChecked();
		elseif ( index == "VERTICAL_SYNC" ) then
			OptionsFrame_UpdateBuffering(checkButton:GetChecked());
		end
	end
	OptionsFrame_UpdateShaderOptions(enableShaders);
	OptionsFrame_UpdateUIScaleControls();
	OptionsFrame_UpdateGammaControls();
	OptionsFrame_UpdatePhongShading();
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
			sliderValue = 1 - GetCVarDefault("alphaLevel");
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
end

function OptionsFrame_DisableCheckBox(checkBox)
	checkBox:SetChecked(0);
	checkBox:Disable();
	getglobal(checkBox:GetName().."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function OptionsFrame_EnableCheckBox(checkBox, checked)
	checkBox:SetChecked(checked);
	checkBox:Enable();
	getglobal(checkBox:GetName().."Text"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
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
