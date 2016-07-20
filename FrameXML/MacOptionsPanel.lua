MovieRecordingOptionsFrameCheckButtons = { };
MovieRecordingOptionsFrameCheckButtons["MOVIE_RECORDING_ENABLE_GUI"] = { index = 1, cvar = "MovieRecordingGUI", tooltipText = MOVIE_RECORDING_ENABLE_GUI_TOOLTIP};
MovieRecordingOptionsFrameCheckButtons["MOVIE_RECORDING_ENABLE_SOUND"] = { index = 2, cvar = "MovieRecordingSound", tooltipText = MOVIE_RECORDING_ENABLE_SOUND_TOOLTIP};
MovieRecordingOptionsFrameCheckButtons["MOVIE_RECORDING_ENABLE_CURSOR"] = { index = 3, cvar = "MovieRecordingCursor", tooltipText = MOVIE_RECORDING_ENABLE_CURSOR_TOOLTIP};
MovieRecordingOptionsFrameCheckButtons["MOVIE_RECORDING_ENABLE_ICON"] = { index = 4, cvar = "MovieRecordingIcon", tooltipText = MOVIE_RECORDING_ENABLE_ICON_TOOLTIP};
MovieRecordingOptionsFrameCheckButtons["MOVIE_RECORDING_ENABLE_RECOVER"] = { index = 5, cvar = "MovieRecordingRecover", tooltipText = MOVIE_RECORDING_ENABLE_RECOVER_TOOLTIP};
MovieRecordingOptionsFrameCheckButtons["MOVIE_RECORDING_ENABLE_COMPRESSION"] = { index = 6, cvar = "MovieRecordingAutoCompress", tooltipText = MOVIE_RECORDING_ENABLE_COMPRESSION_TOOLTIP};

MacKeyboardOptionsFrameCheckButtons = { };
MacKeyboardOptionsFrameCheckButtons["MAC_DISABLE_OS_SHORTCUTS"] = { index = 9, cvar = "MacDisableOsShortcuts", tooltipText = MAC_DISABLE_OS_SHORTCUTS_TOOLTIP};
MacKeyboardOptionsFrameCheckButtons["MAC_USE_COMMAND_AS_CONTROL"] = { index = 10, cvar = "MacUseCommandAsControl", tooltipText = MAC_USE_COMMAND_AS_CONTROL_TOOLTIP};
MacKeyboardOptionsFrameCheckButtons["MAC_USE_COMMAND_LEFT_CLICK_AS_RIGHT_CLICK"] = { index = 11, cvar = "MacUseCommandLeftClickAsRightClick", tooltipText = MAC_USE_COMMAND_LEFT_CLICK_AS_RIGHT_CLICK_TOOLTIP};

local function MovieRecordingSupported()
	if (not IsMacClient()) then
		return false;
	elseif (not MovieRecording_IsSupported()) then
		return false;
	else
		return true;
	end
end

local function MovieRecordingOptions_Okay (self)
	MovieRecordingOptionsFrame_Save()
end

local function MovieRecordingOptions_Cancel (self)

end

local function MovieRecordingOptions_Default (self)
	MovieRecordingOptionsFrame_SetDefaults();
end

local function MovieRecordingOptions_Refresh (self)
	MovieRecordingOptionsFrame_Update();
end

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


function MovieRecordingOptionsFrame_OnLoad(self)
	if(IsMacClient()) then
		self.name = BINDING_HEADER_MOVIE_RECORDING_SECTION;
		self.hasApply = true;
		BlizzardOptionsPanel_OnLoad(self, MovieRecordingOptions_Okay, MovieRecordingOptions_Cancel, MovieRecordingOptions_Default, MovieRecordingOptions_Refresh);
		OptionsFrame_AddCategory(VideoOptionsFrame, self);
	end
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

function MovieRecordingOptionsFrame_Update()
	if (not IsMacClient()) then
		return;
	end


	for index, value in pairs(MovieRecordingOptionsFrameCheckButtons) do
		local button = _G["MovieRecordingOptionsFrameCheckButton"..value.index];
		local string = _G["MovieRecordingOptionsFrameCheckButton"..value.index.."Text"];
		local checked = GetCVar(value.cvar);
		button:SetChecked(checked and checked ~= "0");
		button.setFunc = function(checked)
			VideoOptionsFrameApply:Enable();		-- we have a change, enable the Apply button
		end;

		string:SetText(_G[index]);
		button.tooltipText = value.tooltipText;
		
		if(not MovieRecording_IsSupported()) then
			MacOptionsFrame_DisableCheckBox(button);
		else
			MacOptionsFrame_EnableCheckBox(button);
		end
	end


	

	if(not MovieRecording_IsSupported()) then
		UIDropDownMenu_DisableDropDown(MovieRecordingOptionsFrameResolutionDropDown);
		UIDropDownMenu_DisableDropDown(MovieRecordingOptionsFrameFramerateDropDown);
		UIDropDownMenu_DisableDropDown(MovieRecordingOptionsFrameCodecDropDown);
		MacOptionsFrame_DisableSlider(MovieRecordingOptionsFrameQualitySlider);
		MovieRecordingOptionsButtonCompress:Disable();

		-- disable frame text
		MovieRecordingOptionsFrame_DisableText(MovieRecordingOptionsFrameText1);
		MovieRecordingOptionsFrame_DisableText(MovieRecordingOptionsFrameText2);
		MovieRecordingOptionsFrame_DisableText(MovieRecordingOptionsFrameText3);
		MovieRecordingOptionsFrame_DisableText(MovieRecordingOptionsFrameText4);
 
	else
		MovieRecordingOptionsFrameQualitySlider:SetValue(GetCVar("MovieRecordingQuality"));
		if GetCVar("MovieRecordingGUI") then
			MacOptionsFrame_EnableCheckBox(_G["MovieRecordingOptionsFrameCheckButton3"]);
		else
			MacOptionsFrame_DisableCheckBox(_G["MovieRecordingOptionsFrameCheckButton3"]);
		end
	end
	if(not MovieRecordingSupported() or not MovieRecording_IsCursorRecordingSupported()) then
		local button = _G["MovieRecordingOptionsFrameCheckButton3"];
		button:SetChecked(false);
		MacOptionsFrame_DisableCheckBox(button);
	end

	-- make sure that if UI recording is not enabled, that we disable cursor recording (it's part of the UI)
	if ( not MovieRecordingOptionsFrameCheckButton1:GetChecked() ) then
		MovieRecordingOptionsFrameCheckButton3:SetChecked(false);
		MacOptionsFrame_DisableCheckBox(MovieRecordingOptionsFrameCheckButton3);
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
		button.tooltipText = value.tooltipText;
	end

	local disableOSShortcutsButton = _G["MacKeyboardOptionsFrameCheckButton9"];
	disableOSShortcutsButton.setFunc = function(checked)
		VideoOptionsFrameApply:Enable();
		if ( (not MacOptions_IsUniversalAccessEnabled()) and (checked == "1")  ) then
			StaticPopup_Show("MAC_OPEN_UNIVERSAL_ACCESS");
			_G["MacKeyboardOptionsFrameCheckButton9"]:SetChecked(false);
		end
	end;

	if ( (not MacOptions_IsUniversalAccessEnabled()) and disableOSShortcutsButton:GetChecked() ) then
		disableOSShortcutsButton:SetChecked(false);
		SetCVar("MacDisableOSShortcuts", "0");
	end
end

function MovieRecordingOptionsFrame_Save()
	for index, value in pairs(MovieRecordingOptionsFrameCheckButtons) do
		local button = _G["MovieRecordingOptionsFrameCheckButton"..value.index];
		if ( button:GetChecked() ) then
			value.value = "1";
		else
			value.value = "0";
		end

		SetCVar(value.cvar, value.value, index);
	end
	
	if (not MovieRecordingSupported()) then
		return;
	end

	MovieRecording_SaveSelectedWidth();
	SetCVar("MovieRecordingFramerate", UIDropDownMenu_GetSelectedValue(MovieRecordingOptionsFrameFramerateDropDown));
	SetCVar("MovieRecordingCompression", UIDropDownMenu_GetSelectedValue(MovieRecordingOptionsFrameCodecDropDown));

	SetCVar("MovieRecordingQuality", MovieRecordingOptionsFrameQualitySlider:GetValue());
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

function MovieRecordingOptionsFrameResolutionDropDown_UpdateSelection(self)
	local ratio = MovieRecording_GetAspectRatio();
	local width = MovieRecording_GetSelectedWidth();
	UIDropDownMenu_SetSelectedValue(self, width.."x"..floor(width*ratio), 1);
	UIDropDownMenu_SetWidth(MovieRecordingOptionsFrameResolutionDropDown, 110);
end

function MovieRecordingOptionsFrameResolutionDropDown_OnLoad(self)
	if (not MovieRecordingSupported()) then
		return;
	end
	
	-- make sure we get display size change events, so that we
	-- can update the available resolution drop down if we resize our
	-- window or whatnot 
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");	
end

function MovieRecordingOptionsFrameResolutionDropDown_OnShow(self)
	if (not MovieRecordingSupported()) then
		return;
	end

	-- sync the selected width with the internal cvar
	MovieRecording_LoadSelectedWidth();
	
	-- update the drop down list
	UIDropDownMenu_Initialize(self, MovieRecordingOptionsFrameResolutionDropDown_Initialize);
	MovieRecordingOptionsFrameResolutionDropDown_UpdateSelection(self);
end

function MovieRecordingOptionsFrameResolutionDropDown_OnEvent(self, event, ...)
	if ( event == "DISPLAY_SIZE_CHANGED" ) then
		-- user resized the window.  update our supported resolutions, etc.
		UIDropDownMenu_Initialize(self, MovieRecordingOptionsFrameResolutionDropDown_Initialize);
		MovieRecordingOptionsFrameResolutionDropDown_UpdateSelection(self);
	end
end

local function greaterThanTableSort(a, b) return a > b end 

function MovieRecordingOptionsFrameResolutionDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	local ratio = MovieRecording_GetAspectRatio();
	
	local fullWidth = MovieRecording_GetFullWidth();
	local halfWidth = MovieRecording_GetHalfWidth();
	local quarterWidth = MovieRecording_GetQuarterWidth();

	local widthCount = MovieRecording_GetWidthCount();

	for widthIndex = 0, (widthCount - 1), 1 do
		local value = MovieRecording_GetWidthAt(widthIndex);
		local height = floor(value * ratio);
		
		info.text = value.."x"..height;
		info.value = info.text;
		info.func = MovieRecordingOptionsFrameResolutionButton_OnClick;
		info.checked = nil;
		if value == tonumber(fullWidth) then
			info.tooltipTitle = MOVIE_RECORDING_FULL_RESOLUTION;
		elseif value == tonumber(halfWidth) then
			info.tooltipTitle = "Half Resolution";
		elseif value == tonumber(quarterWidth) then
			info.tooltipTitle = "Quarter Resolution";
		else
			info.tooltipTitle = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
end

function MovieRecordingOptionsFrameResolutionButton_OnClick(self)
	UIDropDownMenu_SetSelectedValue(MovieRecordingOptionsFrameResolutionDropDown, self.value);
	
	-- update selected value in code
	local xIndex = strfind(self.value, "x");
	local width = strsub(self.value, 1, xIndex-1);
	MovieRecording_SetSelectedWidth(width);
	VideoOptionsFrameApply:Enable();		-- we have a change, enable the Apply button

--	MovieRecordingOptionsFrame_UpdateTime();
end

function MovieRecordingOptionsFrameFramerateDropDown_OnLoad(self)
	if ( not IsMacClient() ) then
		return;
	end
	
	UIDropDownMenu_Initialize(self, MovieRecordingOptionsFrameFramerateDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, GetCVar("MovieRecordingFramerate"));
	UIDropDownMenu_SetWidth(self, 110);
end

function MovieRecordingOptionsFrameFramerateDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.func = MovieRecordingOptionsFrameFramerateDropDown_OnClick;
	info.checked = nil;

	info.text = MOVIE_RECORDING_FPS_HALF;
	info.value = "2";
	info.checked = nil;
	UIDropDownMenu_AddButton(info);

	info.text = MOVIE_RECORDING_FPS_THIRD;
	info.value = "3";
	info.checked = nil;
	UIDropDownMenu_AddButton(info);

	info.text = MOVIE_RECORDING_FPS_FOURTH;
	info.value = "4";
	info.checked = nil;
	UIDropDownMenu_AddButton(info);
	
	local fps = { "100", "90", "80", "70", "60", "50", "40", "30", "29.97", "25", "23.98", "20", "15", "10" };
	
	for index, value in pairs(fps) do
		info.text = value;
		info.value = info.text;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function MovieRecordingOptionsFrameCodecDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(MovieRecordingOptionsFrameCodecDropDown, self.value);
	VideoOptionsFrameApply:Enable();		-- we have a change, enable the Apply button
	MovieRecordingOptionsFrame_UpdateTime();
end

function MovieRecordingOptionsFrameCodecDropDown_OnLoad(self)
	if ( not IsMacClient() ) then
		return;
	end
	
	UIDropDownMenu_Initialize(self, MovieRecordingOptionsFrameCodecDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, tonumber(GetCVar("MovieRecordingCompression")));
	UIDropDownMenu_SetWidth(self, 110);
end

function MovieRecordingOptionsFrameCodecDropDown_Initialize()
	if (not MovieRecordingSupported()) then
		return;
	end
	
	local info = UIDropDownMenu_CreateInfo();
	info.func = MovieRecordingOptionsFrameCodecDropDown_OnClick;
	info.checked = nil;
	
	local codecType = { 1835692129, 
						1635148593, 
						1768124260,
						1836070006 };
	local codecName = { MOVIE_RECORDING_MJPEG,
						MOVIE_RECORDING_H264,
						MOVIE_RECORDING_AIC,
						MOVIE_RECORDING_MPEG4 };
	local codecTooltip = { 	MOVIE_RECORDING_MJPEG_TOOLTIP,
							MOVIE_RECORDING_H264_TOOLTIP,
							MOVIE_RECORDING_AIC_TOOLTIP,
							MOVIE_RECORDING_MPEG4_TOOLTIP };
						
	for index, value in pairs(codecType) do
		if ( MovieRecording_IsCodecSupported(value)) then
			info.text = codecName[index];
			info.value = value;
			info.checked = nil;
			info.tooltipTitle = codecName[index];
			info.tooltipText = codecTooltip[index];
			UIDropDownMenu_AddButton(info);
		end
	end
end

function MovieRecordingOptionsFrameFramerateDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(MovieRecordingOptionsFrameFramerateDropDown, self.value);
	VideoOptionsFrameApply:Enable();		-- we have a change, enable the Apply button
	MovieRecordingOptionsFrame_UpdateTime();
end

function MovieRecordingOptionsFrame_SetDefaults()
	local checkButton, slider;
	for index, value in pairs(MovieRecordingOptionsFrameCheckButtons) do
		checkButton = _G["MovieRecordingOptionsFrameCheckButton"..value.index];
		local checked = GetCVarDefault(value.cvar);
		checkButton:SetChecked(checked and checked ~= "0");
	end    
	if((not MovieRecordingSupported()) or (not MovieRecording_IsCursorRecordingSupported())) then
		local button = _G["MovieRecordingOptionsFrameCheckButton3"];
		button:SetChecked(false);
		MacOptionsFrame_DisableCheckBox(button);
	else
		local button = _G["MovieRecordingOptionsFrameCheckButton3"];
		MacOptionsFrame_EnableCheckBox(button);
	end

	if (MovieRecordingSupported()) then
		UIDropDownMenu_Initialize(MovieRecordingOptionsFrameFramerateDropDown, MovieRecordingOptionsFrameFramerateDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(MovieRecordingOptionsFrameFramerateDropDown, "29.97");
		UIDropDownMenu_Initialize(MovieRecordingOptionsFrameCodecDropDown, MovieRecordingOptionsFrameCodecDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(MovieRecordingOptionsFrameCodecDropDown, 1635148593);
		UIDropDownMenu_Initialize(MovieRecordingOptionsFrameResolutionDropDown, MovieRecordingOptionsFrameResolutionDropDown_Initialize);
		local ratio = MovieRecording_GetAspectRatio();
		UIDropDownMenu_SetSelectedValue(MovieRecordingOptionsFrameResolutionDropDown, "640x"..floor(640*ratio));
		
		MovieRecordingOptionsFrameQualitySlider:SetValue(2);
		--MovieRecordingOptionsFrame_UpdateTime();
	end
	MovieRecordingOptionsFrame_Save();
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

function MovieRecordingOptionsFrame_UpdateTime()
	if(not MovieRecording_IsSupported()) then
		return;
	end
	local resolution, framerate, xIndex, width, sound;
	framerate = UIDropDownMenu_GetSelectedValue(MovieRecordingOptionsFrameFramerateDropDown);
	if tonumber(framerate) >= 10 then
		resolution = UIDropDownMenu_GetSelectedValue(MovieRecordingOptionsFrameResolutionDropDown);
		xIndex = strfind(resolution, "x");
		width = tonumber(strsub(resolution, 1, xIndex-1));
		if(MovieRecordingOptionsFrameCheckButton2:GetChecked()) then
			sound = true;
		else
			sound = false;
		end
		
		MovieRecordingOptionsFrameText2:SetText(MovieRecording_MaxLength(	tonumber(width),
																tonumber(framerate),
																sound));

		local dataRate = MovieRecording_DataRate(	tonumber(width), 
													tonumber(UIDropDownMenu_GetSelectedValue(MovieRecordingOptionsFrameFramerateDropDown)),
													sound)
		MovieRecordingOptionsFrameText4:SetText(dataRate);
		MovieRecordingFrameTextTooltip1:SetWidth(MovieRecordingOptionsFrameText1:GetWidth() + MovieRecordingOptionsFrameText2:GetWidth() + 2);
		MovieRecordingFrameTextTooltip2:SetWidth(MovieRecordingOptionsFrameText3:GetWidth() + MovieRecordingOptionsFrameText4:GetWidth() + 2);
	else
		MovieRecordingOptionsFrameText2:SetText("");
		MovieRecordingOptionsFrameText4:SetText("");
	end
end

function MovieRecordingOptionsCancelFrame_OnShow()
	MovieRecordingOptionsCancelFrameFileName:SetText(MovieRecording_GetMovieFullPath());

	local fileNameWidth = MovieRecordingOptionsCancelFrameFileName:GetWidth();
	local questionWidth = MovieRecordingOptionsCancelFrameQuestion:GetWidth();
	local frameWidth = math.min(600, math.max(fileNameWidth, questionWidth));

	MovieRecordingOptionsCancelFrame:SetWidth(frameWidth + 40);
	MovieRecordingOptionsCancelFrameFileName:SetWidth(frameWidth);
	MovieRecordingOptionsCancelFrameQuestion:SetWidth(frameWidth);
end

function MovieRecordingOptionsCompressFrame_OnShow()
	local fileNameWidth = MovieRecordingOptionsCompressFrameFileName:GetWidth();
	local frameWidth = math.max(350, fileNameWidth);

	MovieRecordingOptionsCompressFrame:SetWidth(frameWidth + 40);
	MovieRecordingOptionsCompressFrameFileName:SetWidth(frameWidth);
end
