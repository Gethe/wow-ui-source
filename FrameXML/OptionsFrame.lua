OPTIONS_FARCLIP_MIN = 177;
OPTIONS_FARCLIP_MAX = 1277;

OptionsFrameCheckButtons = { };
OptionsFrameCheckButtons["DESKTOP_GAMMA"] = { index = 1, cvar = "desktopGamma", tooltipText = OPTION_TOOLTIP_USE_DESKTOP_GAMMA};
OptionsFrameCheckButtons["TERRAIN_HIGHLIGHTS"] = { index = 2, cvar = "specular", tooltipText = OPTION_TOOLTIP_TERRAIN_HIGHLIGHTS, tooltipRequirement = OPTION_LOGOUT_REQUIREMENT};
OptionsFrameCheckButtons["FULL_SCREEN_GLOW"] = { index = 3, cvar = "ffxGlow", tooltipText = OPTION_TOOLTIP_FULL_SCREEN_GLOW};
--OptionsFrameCheckButtons["TRILINEAR_FILTERING"] = { index = 4, cvar = "trilinear", tooltipText = OPTION_TOOLTIP_TRILINEAR, restartClient = 1, tooltipRequirement = OPTION_RESTART_REQUIREMENT};
OptionsFrameCheckButtons["VERTICAL_SYNC"] = { index = 5, cvar = "gxVSync", tooltipText = OPTION_TOOLTIP_VERTICAL_SYNC, gxRestart = 1};
OptionsFrameCheckButtons["CINEMATIC_SUBTITLES"] = { index = 6, cvar = "movieSubtitle", tooltipText = OPTION_TOOLTIP_CINEMATIC_SUBTITLES};
OptionsFrameCheckButtons["WORLD_LOD"] = { index = 7, cvar = "lod", tooltipText = OPTION_TOOLTIP_WORLD_LOD};
--OptionsFrameCheckButtons["VERTEX_ANIMATION_SHADERS"] = { index = 8, cvar = "M2UseShaders", tooltipText = OPTION_TOOLTIP_VERTEX_ANIMATION_SHADERS, tooltipRequirement = OPTION_LOGOUT_REQUIREMENT};
OptionsFrameCheckButtons["USE_UISCALE"] = { index = 9, cvar = "useUiScale", tooltipText = OPTION_TOOLTIP_USE_UISCALE};
OptionsFrameCheckButtons["WINDOWED_MODE"] = { index = 10, cvar = "gxWindow", tooltipText = OPTION_TOOLTIP_WINDOWED_MODE, gxRestart = 1};
OptionsFrameCheckButtons["WINDOW_LOCK"] = { index = 11, cvar = "windowResizeLock", dependency = "WINDOWED_MODE", tooltipText = OPTION_TOOLTIP_WINDOW_LOCK};
OptionsFrameCheckButtons["DEATH_EFFECT"] = { index = 12, cvar = "ffxDeath", tooltipText = OPTION_TOOLTIP_DEATH_EFFECT};
OptionsFrameCheckButtons["TRIPLE_BUFFER"] = { index = 13, cvar = "gxTripleBuffer", dependency = "VERTICAL_SYNC", tooltipText = OPTION_TOOLTIP_BUFFERING, gxRestart = 1};
OptionsFrameCheckButtons["HARDWARE_CURSOR"] = { index = 14, cvar = "gxCursor", tooltipText = OPTION_TOOLTIP_HARDWARE_CURSOR, gxRestart = 1};
--OptionsFrameCheckButtons["PHONG_SHADING"] = { index = 15, cvar = "M2UsePixelShaders", dependency = "VERTEX_ANIMATION_SHADERS", tooltipText = OPTION_TOOLTIP_PHONG_SHADING, };
OptionsFrameCheckButtons["WINDOWED_MAXIMIZED"] = { index = 17, cvar = "gxMaximize", dependency = "WINDOWED_MODE", tooltipText = OPTION_TOOLTIP_WINDOWED_MAXIMIZED, gxRestart = 1};
--OptionsFrameCheckButtons["USE_WEATHER_SHADER"] = { index = 18, cvar = "useWeatherShaders", tooltipText = OPTION_TOOLTIP_USE_WEATHER_SHADER};
OptionsFrameCheckButtons["CHARACTER_SHADOWS"] = { index = 19, cvar = "shadowLOD", tooltipText = OPTION_TOOLTIP_CHARACTER_SHADOWS};

OptionsFrameSliders = {
	{ text = UI_SCALE, func = "uiscale", minValue = 0.64, maxValue = 1.0, valueStep = 0.01 , tooltipText = OPTION_TOOLTIP_UI_SCALE},
	{ text = GAMMA, func = "Gamma", cvar1="gamma", minValue = -0.5, maxValue = 0.5, valueStep = 0.1 , tooltipText = OPTION_TOOLTIP_GAMMA},
	{ text = FARCLIP, func = "farclip", minValue = OPTIONS_FARCLIP_MIN, maxValue = OPTIONS_FARCLIP_MAX, valueStep = (OPTIONS_FARCLIP_MAX - OPTIONS_FARCLIP_MIN)/10 , tooltipText = OPTION_TOOLTIP_FARCLIP},
	{ text = TERRAIN_MIP, func = "TerrainMip", minValue = 0, maxValue = 1, valueStep = 1 , tooltipText = OPTION_TOOLTIP_TERRAIN_TEXTURE, restartClient = 1, tooltipRequirement = OPTION_RESTART_REQUIREMENT},
	{ text = SPELL_DETAIL, func = "spellEffectLevel", minValue = 0, maxValue = 9, valueStep = 1 , tooltipText = OPTION_TOOLTIP_SPELL_DETAIL},
	{ text = ENVIRONMENT_DETAIL, func = "environmentDetail", minValue = 0.5, maxValue = 1.5, valueStep = .25 , tooltipText = OPTION_TOOLTIP_ENVIRONMENT_DETAIL},
	{ text = GROUND_DENSITY, func = "groundEffectDensity", minValue = 16, maxValue = 64, valueStep = 8 , tooltipText = OPTION_TOOLTIP_GROUND_DENSITY},
	{ text = GROUND_RADIUS, func = "groundEffectDist", minValue = 70, maxValue = 140, valueStep = 10 , tooltipText = OPTION_TOOLTIP_GROUND_RADIUS},
	{ text = TEXTURE_DETAIL, func = "BaseMip", minValue = 0, maxValue = 1, valueStep = 1 , tooltipText = OPTION_TOOLTIP_TEXTURE_DETAIL},
	{ text = ANISOTROPIC, func = "textureFilteringMode", minValue = 0, maxValue = 5, valueStep = 1 , tooltipText = OPTION_TOOLTIP_ANISOTROPIC, restartClient = 1, tooltipRequirement = OPTION_RESTART_REQUIREMENT},
	{ text = WEATHER_DETAIL, func = "weatherDensity", minValue = 0, maxValue = 3, valueStep = 1 , tooltipText = OPTION_TOOLTIP_WEATHER_DETAIL},
};

ANISOTROPIC_VALUES = { };
ANISOTROPIC_VALUES[2] = "2";
ANISOTROPIC_VALUES[4] = "3";
ANISOTROPIC_VALUES[8] = "4";
ANISOTROPIC_VALUES[16] = "5";

OPTIONS_FRAME_WIDTH = 495;

function OptionsFrame_OnLoad(self)
	--[[for index, value in pairs(OptionsFrameCheckButtons) do
		local string = GetCVar(value.cvar);
		value.value = string;
	end]]
	self:RegisterEvent("CVAR_UPDATE");
end

function OptionsFrame_OnEvent(self, event, ...)
	if ( event == "CVAR_UPDATE" ) then
		local arg1, arg2 = ...;
		local info = OptionsFrameCheckButtons[arg1];
		if ( info ) then
			info.value = arg2;
		end
	end
end

function OptionsFrame_Load()
	local shadersEnabled = GetCVar("pixelShaders");
	local hasAnisotropic, hasPixelShaders, hasVertexShaders, hasTrilinear, hasTripleBuffering, maxAnisotropy, hasHardwareCursor = GetVideoCaps();
	for index, value in pairs(OptionsFrameCheckButtons) do
		local button = getglobal("OptionsFrameCheckButton"..value.index);
		local string = getglobal("OptionsFrameCheckButton"..value.index.."Text");
		local checked;
		checked = GetCVar(value.cvar);
		string:SetText(getglobal(index));
		button.tooltipText = value.tooltipText;
		button.tooltipRequirement = value.tooltipRequirement;
		button.gxRestart = value.gxRestart;
		button.restartClient = value.restartClient;

		-- Enable disable checkboxes
		button.disabled = nil;
		if ( index == "TRIPLE_BUFFER" ) then
			if ( not hasTripleBuffering or GetCVar("gxVSync") ~= "1" ) then
				button.disabled = 1;
			end
		elseif ( index == "HARDWARE_CURSOR" ) then
			if ( not hasHardwareCursor ) then
				button.disabled = 1;
			end
		elseif ( index == "WINDOW_LOCK" ) then
			-- we never disable window resizing on the Mac, so hide the checkbox
			if ( IsMacClient() ) then
				button:Hide();
			end
		end

		if ( button.disabled ) then
			OptionsFrame_DisableCheckBox(button);
		else
			OptionsFrame_EnableCheckBox(button, 1, checked);
		end
		
	end
	for index, value in pairs(OptionsFrameSliders) do
		local slider = getglobal("OptionsFrameSlider"..index);
		local string = getglobal("OptionsFrameSlider"..index.."Text");
		local thumb = getglobal("OptionsFrameSlider"..index.."Thumb");
		local getvalue = getglobal("Get"..value.func);
		slider.disabled = nil;
		if ( getvalue ) then
			getvalue = getvalue();	
		elseif ( value.func == "textureFilteringMode" ) then
			if ( hasAnisotropic ) then
				ANISOTROPIC_VALUES[maxAnisotropy] = value.maxValue;
			elseif ( not hasTrilinear ) then
				slider.disabled = 1;
			else
				-- Make this a 2 option switch for bilinear & trilinear
				value.maxValue = 1;
			end
			getvalue = GetCVar(value.func);
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
		string:SetText(value.text);
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
	OptionsFrameMiscellaneous:SetWidth(OPTIONS_FRAME_WIDTH/2 - 13);
	OptionsFramePixelShaders:SetWidth(OPTIONS_FRAME_WIDTH/2 - 13);
end

function OptionsFrame_Save()
	for index, value in pairs(OptionsFrameCheckButtons) do
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
		
	end
	for index, value in pairs(OptionsFrameSliders) do
		local slider = getglobal("OptionsFrameSlider"..index);
		local setvalue = getglobal("Set"..value.func);
		local getvalue = getglobal("Get"..value.func);
		if ( value.func == "textureFilteringMode" ) then
			-- Convert back from slider value to actual anisotropic setting
			local filteringValue = tostring(slider:GetValue());
			if ( GetCVar("textureFilteringMode") ~= filteringValue ) then
				OptionsFrame.ClientRestart = 1;
			end
			SetCVar("textureFilteringMode", filteringValue);
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
	end
	SetCVar("gxRefresh", UIDropDownMenu_GetSelectedValue(OptionsFrameRefreshDropDown));
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
	if ( GetCVar("gxWindow") ~= "1" ) then
		OptionsFrameCheckButton10:SetChecked(false);
	end
	if ( OptionsFrame.desktopGamma == "0" ) then
		OptionsFrameCheckButton1:SetChecked(false);
	end
	SetCVar("desktopGamma", OptionsFrame.desktopGamma);
end

function OptionsFrameResolutionDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, OptionsFrameResolutionDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(self, GetCurrentResolution(), 1);
	UIDropDownMenu_SetWidth(self, 90);
end

function OptionsFrameResolutionDropDown_Initialize()
	OptionsFrameResolutionDropDown_LoadResolutions(GetScreenResolutions());	
end

function OptionsFrameResolutionDropDown_LoadResolutions(...)
	local info = UIDropDownMenu_CreateInfo();
	local resolution, xIndex, width, height;
	for i=1, select("#", ...) do
		resolution = (select(i, ...));
		xIndex = strfind(resolution, "x");
		width = strsub(resolution, 1, xIndex-1);
		height = strsub(resolution, xIndex+1, strlen(resolution));
		if ( width/height > 4/3 ) then
			resolution = resolution.." "..WIDESCREEN_TAG;
		end
		info.text = resolution;
		info.value = resolution;
		info.func = OptionsFrameResolutionButton_OnClick;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function OptionsFrameResolutionButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(OptionsFrameResolutionDropDown, self:GetID(), 1);
end

function OptionsFrameRefreshDropDown_OnLoad(self)
	UIDropDownMenu_SetSelectedValue(self, GetCVar("gxRefresh"));
	UIDropDownMenu_Initialize(self, OptionsFrameRefreshDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 90);
end

function OptionsFrameRefreshDropDown_Initialize()
	OptionsFrame_GetRefreshRates(GetRefreshRates());
end

function OptionsFrame_GetRefreshRates(...)
	local info = UIDropDownMenu_CreateInfo();
	local checked;
	if ( select("#", ...) == 1 and select(1, ...) == 0 ) then
		OptionsFrameRefreshDropDownButton:Disable();
		OptionsFrameRefreshDropDownLabel:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		OptionsFrameRefreshDropDownText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		return;
	end
	for i=1, select("#", ...) do
		info.text = select(i, ...)..HERTZ;
		info.func = OptionsFrameRefreshDropDown_OnClick;
		
		if ( UIDropDownMenu_GetSelectedValue(OptionsFrameRefreshDropDown) and tonumber(UIDropDownMenu_GetSelectedValue(OptionsFrameRefreshDropDown)) == select(i, ...) ) then
			checked = 1;
			UIDropDownMenu_SetText(OptionsFrameRefreshDropDown, info.text);
		else
			checked = nil;
		end
		info.value = select(i, ...)
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

function OptionsFrameRefreshDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(OptionsFrameRefreshDropDown, self.value);
end

function OptionsFrameMultiSampleDropDown_OnLoad(self)
	UIDropDownMenu_SetSelectedID(self, GetCurrentMultisampleFormat());
	UIDropDownMenu_Initialize(self, OptionsFrameMultiSampleDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 140);
	UIDropDownMenu_SetAnchor(self, -5, 23, "TOPRIGHT", "OptionsFrameMultiSampleDropDownRight", "BOTTOMRIGHT");
end

function OptionsFrameMultiSampleDropDown_Initialize()
	OptionsFrame_GetMultisampleFormats(GetMultisampleFormats());
end

function OptionsFrame_GetMultisampleFormats(...)
	local colorBits, depthBits, multiSample;
	local info = UIDropDownMenu_CreateInfo();
	local checked;
	local index = 1;
	for i=1, select("#", ...), 3 do
		colorBits, depthBits, multiSample = select(i, ...);
		info.text = format(MULTISAMPLING_FORMAT_STRING, colorBits, depthBits, multiSample);
		info.func = OptionsFrameMultiSampleDropDown_OnClick;
		
		if ( index == UIDropDownMenu_GetSelectedID(OptionsFrameMultiSampleDropDown) ) then
			checked = 1;
			UIDropDownMenu_SetText(OptionsFrameMultiSampleDropDown, info.text);
		else
			checked = nil;
		end
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
		index = index + 1;
	end
end

function OptionsFrameMultiSampleDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedID(OptionsFrameMultiSampleDropDown, self:GetID());
end

function OptionsFrame_UpdateCheckboxes()
	for index, value in pairs(OptionsFrameCheckButtons) do
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
	if ( OptionsFrameCheckButton10:GetChecked() ) then
		OptionsFrameCheckButton1:SetChecked(true);
		OptionsFrame_DisableCheckBox(OptionsFrameCheckButton1);
		OptionsFrame_DisableSlider(OptionsFrameSlider2);
		value = "1";
	elseif ( OptionsFrameCheckButton1:GetChecked() ) then
		OptionsFrame_EnableCheckBox(OptionsFrameCheckButton1);
		OptionsFrame_DisableSlider(OptionsFrameSlider2);
		value = "1";
	else
		OptionsFrame_EnableSlider(OptionsFrameSlider2);
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
	for index, value in pairs(OptionsFrameCheckButtons) do
		checkButton = getglobal("OptionsFrameCheckButton"..value.index);
		checkButton:SetChecked(GetCVarDefault(value.cvar));
	end
	OptionsFrame_UpdateCheckboxes();
	OptionsFrame_UpdateGammaControls();
	OptionsFrame_UpdateUIScaleControls();
	local sliderValue;
	for index, value in pairs(OptionsFrameSliders) do
		slider = getglobal("OptionsFrameSlider"..index);
		
--		if ( value.func == "WorldDetail" ) then
--			sliderValue = GetCVarDefault("environmentDetail");
--			sliderValue = sliderValue + 0;
--			if ( sliderValue <= 0.07 ) then
--				sliderValue = 0;
--			elseif ( sliderValue <= 0.04 ) then
--				sliderValue = 1;
--			elseif ( sliderValue <= 0.01 ) then
--				sliderValue = 2;
--			end
--		elseif ( value.func == "TerrainMip" ) then

		if ( value.func == "TerrainMip" ) then
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
	local text = getglobal(checkBox:GetName().."Text");
	if ( text ) then
		text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end

function OptionsFrame_EnableCheckBox(checkBox, setChecked, checked, isWhite)
	if ( setChecked ) then
		checkBox:SetChecked(checked);
	end
	checkBox:Enable();
	local text = getglobal(checkBox:GetName().."Text");
	if ( not text ) then
		return;
	end
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
