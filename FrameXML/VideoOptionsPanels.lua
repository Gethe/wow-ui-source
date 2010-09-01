-- this code is shared between the frame and glue
----------------------------
VideoData={};				--master array
-------------------------------------------------------------------------------------------------------
TEXT_LOW 	= VIDEO_QUALITY_LABEL1;
TEXT_FAIR 	= VIDEO_QUALITY_LABEL2;
TEXT_MEDIUM = VIDEO_QUALITY_LABEL3;
TEXT_HIGH 	= VIDEO_QUALITY_LABEL4;
TEXT_ULTRA 	= VIDEO_QUALITY_LABEL5;
TEXT_DISABLED = "Disabled"
TEXT_ENABLED = "Enabled"
NEED_GXRESTART = "Changing this option requires a video restart";
local VIDEO_OPTIONS_COMPARISON_EPSILON = 0.000001;

RESOLUTION_LABEL = "Graphics";
RESOLUTION_SUBTEXT = "These options allow you to change the size and detail in which your video hardware renders the game.";
EFFECTS_LABEL = "Advanced";
EFFECTS_SUBTEXT = "These controls allow you to modify specific detail levels for many game elements and effects.";
RESOLUTION = "Resolution";
DISPLAY_HEADER = "Display";
GRAPHICS_HEADER = "Graphics";
TEXTURES_SUBHEADER = "Textures";
ENVIRONMENT_SUBHEADER = "Environment";
EFFECTS_SUBHEADER = "Effects";
DISPLAY_MODE = "Display Mode";
REFRESH_RATE = "Refresh Rate";
RESIZE_WINDOW = "Resize Window";
PRIMARY_MONITOR = "Primary Monitor";
OVERALL_QUALITY = "Overall Quality";
SUNSHAFTS = "Sunshafts";
MAXFPS = "MaxFPS";
MAXFPSBK = "MaxFPSbk"
RECOMMENDED = "Recommended: "
GREYCOLORCODE = "|cff7f7f7f"
GREENCOLORCODE= "|cff00ff00"

VideoOptionsFrame:SetSize(858,660);
VideoOptionsFrameCategoryFrame:SetSize(175,569);
local DefaultVideoOptions = {};



VRN_NOMULTISAMPLE="VRN_NOMULTISAMPLE";
VRN_ILLEGAL="VRN_ILLEGAL";
VRN_UNSUPPORTED="VRN_UNSUPPORTED";
VRN_GRAPHICS="VRN_GRAPHICS";
VRN_NEEDS_2_0="VRN_NEEDS_2_0";
VRN_NEEDS_3_0="VRN_NEEDS_3_0";
VRN_NEEDS_4_0="VRN_NEEDS_4_0";
VRN_NEEDS_5_0="VRN_NEEDS_5_0";
VRN_NEEDS_MACOS_10_5_5="VRN_NEEDS_MACOS_10_5_5";
VRN_NEEDS_MACOS_10_5_7="VRN_NEEDS_MACOS_10_5_7";
VRN_CPUMEM_2GB="VRN_CPUMEM_2GB";
VRN_DUALCORE="VRN_DUALCORE";
VRN_WINDOWS_UNSUPPORTED="VRN_WINDOWS_UNSUPPORTED";
VRN_MACOS_UNSUPPORTED="VRN_MACOS_UNSUPPORTED";

local ErrorCodes =
{
	VRN_NOMULTISAMPLE,
	VRN_ILLEGAL,
	VRN_UNSUPPORTED,
	VRN_GRAPHICS,
	VRN_DUALCORE,
	VRN_CPUMEM_2GB,
	VRN_NEEDS_2_0,
	VRN_NEEDS_3_0,
	VRN_NEEDS_4_0,
	VRN_NEEDS_5_0,
	VRN_MACOS_UNSUPPORTED,
	VRN_WINDOWS_UNSUPPORTED,
	VRN_NEEDS_MACOS_10_5_5,
	VRN_NEEDS_MACOS_10_5_7,
};

function GetLowBit(value)
	if(value == 0) then
		return 0;
	end
	local index = 1;
	while (value > 0) do
		value = floor(value/2);
		index = index + 1;
		if(index > 32) then
			return;	-- ??
		end
	end
	return index;
end

function Graphics_PrepareTooltip(self)
	-- this code should be elsewhere
	if (self.data ~= nil) then
		for i, value in ipairs(self.data) do
			self.table[i]=value.text;
		end
	end

	local tooltip = "";
	if(self.description == nil) then
		self.description = "Description tbd";
	end
	if(self.description ~= nil) then
		tooltip = tooltip .. self.description .. "|n|n";
	end


	-- get validation data
	if (self.data ~= nil) then
		self.validity = {}
		for i, value in ipairs(self.data) do
			if(value.cvars ~= nil) then
				for cvar_name, cvar_value in pairs(value.cvars) do
					if(self.validity[cvar_name] == nil) then
						self.validity[cvar_name] = {};
					end
					self.validity[cvar_name][cvar_value] = 0;
				end
			end
		end
		for cvar_name, table in pairs(self.validity) do
			local cvar_data = {}
			tinsert(cvar_data, cvar_name);
			for cvar_value, valid in pairs(table) do
				tinsert(cvar_data, cvar_value);
			end
			local validity = {GetToolTipInfo(1, #cvar_data - 1, unpack(cvar_data) )};
			local index = 1;
			for cvar_value, valid in pairs(table) do
				self.validity[cvar_name][cvar_value] = validity[index];
				index = index + 1;
			end
		end
		-- we now have a table of bit fields which will tell us yes/no/maybe, etc, with each option.

		local recommendedValue = nil;
		for i, value in ipairs(self.data) do
			if(value.tooltip == nil) then
				value.tooltip = "Tooltip tbd";
			end
			local invalid = false;
			local recommended = false;
			local errorValue = nil;
			if(value.cvars ~= nil) then
				recommended = true;
				for cvar_name, cvar_value in pairs(value.cvars) do
					local validity = self.validity[cvar_name][cvar_value];
					local index = 0;
					while(validity > 0) do
						invalid = true;
						index = index + 1;
						if(index > 32) then	-- ??
							break;
						end
						local err = GetLowBit(validity);
						validity = floor( validity - (2^err) );
						errorValue = (errorValue or "") .. ErrorCodes[err] .. "|n";
					end
					if(DefaultVideoOptions[cvar_name] ~= cvar_value) then
						recommended = false;
					end
				end
			end
			if(not invalid and recommended) then
				recommendedValue = value.text;
			end
			tooltip = tooltip .. "|cffffd200" .. value.text .. ":|r ";
			if (value.tooltip ~= nil) then
				if(invalid) then
					tooltip = tooltip .. GREYCOLORCODE;
				elseif(recommended) then
					tooltip = tooltip .. GREENCOLORCODE;
				end
				tooltip =  tooltip .. value.tooltip;
				if(invalid or recommended) then
					tooltip = tooltip .. "|r";
				end
			else
				if(invalid) then
					tooltip = tooltip .. "|cff7f7f7f";
				end
				if(invalid) then
					tooltip = tooltip .. " (0x" .. string.format("%x", validity[i]) .. ")" .. "|r";
				end
			end
			tooltip = tooltip .. "|n";
			if(errorValue ~= nil) then
				tooltip = tooltip .. "|cffff0000" .. errorValue .. "|r";
			end
			if(i ~= #self.data) then
				tooltip = tooltip .. "|n";	-- no space after the last item (unless recommended is coming)
			end
		end
		if(recommendedValue ~= nil) then
			tooltip = tooltip .. "|n" .. RECOMMENDED .. GREENCOLORCODE .. recommendedValue .. "|r|n";
		end
	end
--	if(self.restart == true) then
--		tooltip = tooltip .. "|n|cffff0000" .. NEED_GXRESTART .. "|r";
--	end
	self.tooltip = tooltip;
end

function Graphics_Default (self)
	SetDefaultVideoOptions(0);
	for _, control in next, self.controls do
		control.newValue = nil;
	end
end

function Graphics_Refresh (self)
	-- first level
	BlizzardOptionsPanel_Refresh(self);
	-- second level.

	-- do three levels of dependency
	for i=1,3 do
		for key, value in pairs(VideoData) do
			if(_G[key].needrefresh) then
				BlizzardOptionsPanel_RefreshControl(_G[key]);
				_G[key].needrefresh = false;
			end
		end
	end
end

function Graphics_OnEvent (self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);
	if ( event == "SET_GLUE_SCREEN" or event == "PLAYER_ENTERING_WORLD" ) then
		-- don't allow systems that don't support features to enable them
		local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
		if ( not hardwareCursor ) then
			Graphics_HardwareCursor:SetChecked(false);
			Graphics_HardwareCursor:Disable();
		end
	end
end

function VideoOptionsPanel_Okay (self)
	for _, control in next, self.controls do
		if ( control.newValue ) then
			if ( control.value ~= control.newValue ) then
				if ( control.gameRestart ) then
					VideoOptionsFrame.gameRestart = true;
				end
				if ( control.restart ) then
					VideoOptionsFrame.gxRestart = true;
				end
				control:SetValue(control.newValue);
				control.value = control.newValue;
				control.newValue = nil;
			end
		elseif ( control.value ) then
			control:SetValue(control.value);
		end
	end
end

function VideoOptionsPanel_Cancel (self)
	for _, control in next, self.controls do
		if ( control.newValue ) then
			if ( control.value and control.value ~= control.newValue ) then
				if ( control.restart ) then
					VideoOptionsFrame.gxRestart = true;
				end
				-- we need to force-set the value here just in case the control was doing dynamic updating
				control:SetValue(control.value);
				control.newValue = nil;
			end
		elseif ( control.value ) then
			control:SetValue(control.value);
		end
	end
end

function VideoOptionsPanel_Default (self)
	for _, control in next, self.controls do
		if ( control.defaultValue and control.value ~= control.defaultValue ) then
			if ( control.restart ) then
				VideoOptionsFrame.gxRestart = true;
			end
			control:SetValue(control.defaultValue);
			control.newValue = nil;
		end
	end
end

function VideoOptionsPanel_OnLoad (self, okay, cancel, default, refresh)
	local defaults =  {GetDefaultVideoOptions()};
	for i=1, #defaults, 2 do
		DefaultVideoOptions[defaults[i]]=defaults[i+1];
	end
	okay = okay or VideoOptionsPanel_Okay;
	cancel = cancel or VideoOptionsPanel_Cancel;
	default = default or VideoOptionsPanel_Default;
	refresh = refresh or BlizzardOptionsPanel_Refresh;
	BlizzardOptionsPanel_OnLoad(self, okay, cancel, default, refresh);
	OptionsFrame_AddCategory(VideoOptionsFrame, self);
end

function Graphics_TableSetValue(self, value)
	if(self.data[value].cvars ~= nil) then
		for cvar, cvar_value in pairs(self.data[value].cvars) do
			BlizzardOptionsPanel_SetCVarSafe(cvar, cvar_value);
		end
	end
end

function Graphics_TableDependTarget(self)
	if(self.onrefresh) then
		self:onrefresh();
	end
end
---------------------------------------------------
function Graphics_TableRefreshValue(self)
	if(self.onrefresh) then
		self:onrefresh();
	end
	VideoOptionsDropDownMenu_Initialize(self, self.initialize);
	VideoOptionsDropDownMenu_SetSelectedID(self, self:GetValue(), 1);
	if(self.dependent ~= nil) then
		for i, key in ipairs(self.dependent) do
			 _G[key].needrefresh = true;
		end
	end
end
---------------------------------------------------
function Graphics_TableLookup(self, val)
	for i, value in ipairs(self.table) do
		if(value == val) then
			return i;
		end 
	end
	return 1+#self.table;	-- custom
end
---------------------------------------------------
function Graphics_TableLookupValidate(self, val)
	local id = Graphics_TableLookup(self, val);
	if(id > #self.table) then
		return #self.table;									-- return a legal value. We should use query for recommended setting
	else
		return id;
	end
end
---------------------------------------------------
function VideoOptionsCopyData(self)
	local dropdownkey = self:GetName();
	if(VideoData[dropdownkey] ~= nil) then
		for key, value in pairs(VideoData[dropdownkey]) do
			self[key] = value;
		end
		self.key = dropdownkey;
	end
end
-- generic functions used for all drop-downs
-------------------------------------------------------------------------------------------------------
function VideoOptionsDropDown_OnLoad(self)
	VideoOptionsCopyData(self);
	self.tablerefresh = true;
	self.tooltiprefresh = true;
	if(self.onload ~= nil) then
		self.onload(self);
	end
	self.needrefresh = false;
	self.initialize = self.initialize or 
		function (self, level)
			self.newValue = nil;
			self.selectedID = nil;
			if(self.tablerefresh) then
				self.table = {};
				self.tablerefresh = false;
				if(self.tablefunction ~= nil) then
					if(self.tablenext == nil) then
						self.tablenext = 1;
					end
					local mytable = {self.tablefunction(self)};      -- initialize the table
					local index = 1;
					for i=1, #mytable, self.tablenext do
						if(self.readfilter ~= nil) then                	-- data needs special treatment before display
							local newtable={};
							for j=1, self.tablenext do
								newtable[j] = mytable[i+j-1];
							end
							self.table[index] = self.readfilter(self, unpack( newtable ));
						else
							self.table[index] = mytable[i];
						end
						index = index + 1;
					end
				end
			end
			if(self.tooltiprefresh) then
				self.tooltiprefresh = false;
				Graphics_PrepareTooltip(self);
			end
--			local v = self:GetValue();
			for mode, text in ipairs(self.table) do
				local info = VideoOptionsDropDownMenu_CreateInfo();
				info.text = text;
				info.value = text;
				info.func = self.onclickfunction or VideoOptionsDropDown_OnClick;
				info.checked = nil;

--				if(mode == v) then
--					info.checked = 1;
--				else
--					info.checked = nil;
--				end

				-- disable and recommended settings!
				if(self.data ~= nil) then
					if(self.data[mode].cvars ~= nil) then
						local recommended = true;
						for cvar_name, cvar_value in pairs(self.data[mode].cvars) do
							if(self.validity[cvar_name][cvar_value] ~= 0) then
								info.notClickable = true;
								info.disablecolor = GREYCOLORCODE;
							end
							if(DefaultVideoOptions[cvar_name] ~= cvar_value) then
								recommended = false;
							end
						end
						if(recommended) then
							info.colorCode = GREENCOLORCODE;
						end
					end
				end
				VideoOptionsDropDownMenu_AddButton(info);
			end
		end
	self.SetValue = self.SetValue or Graphics_TableSetValue;
	self.GetValue = self.GetValue or Graphics_TableGetValue;
	self.GetNewValueString = self.GetNewValueString or 
		function(self)
			if(self.table ~= nil) then
				return self.table[self:GetValue()];
			end
			return nil;
		end
	self.type = self.type or CONTROLTYPE_DROPDOWN;
	-- register the control
	if(self.width == nil) then
		self.width = 110;
	end
	VideoOptionsDropDownMenu_SetWidth(self.width, self);
	-- force another control to change to a value
	self.notifytarget = self.notifytarget or
		function (self, value)
			local index;
			for i, val in ipairs(self.table) do
				if(val == value) then
					index = i;
					break;
				end
			end
			local valid = true;			
			if(self.data ~= nil) then
				if(self.data[index].cvars ~= nil) then
					for cvar_name, cvar_value in pairs(self.data[index].cvars) do
						if(self.validity[cvar_name][cvar_value] ~= 0) then
							valid = false;
						end
					end
				end
			end
			if(valid) then
				self.selectedName = nil;
				self.selectedValue = nil;
				self.newValue = index;
				self.selectedID = index;
				VideoOptionsDropDownMenu_SetText(value, self);
			end
		end

	self.lookup = self.lookup or Graphics_TableLookup;
	self.RefreshValue = self.RefreshValue or Graphics_TableRefreshValue;
	self.dependtarget = self.dependtarget or Graphics_TableDependTarget;
	BlizzardOptionsPanel_RegisterControl(self, self:GetParent());
end
-------------------------------------------------------------------------------------------------------
function VideoOptionsSlider_OnLoad(self)
	VideoOptionsCopyData(self);
	self.type = self.type or CONTROLTYPE_SLIDER;
	self.dependtarget = self.dependtarget or Graphics_TableDependTarget;
	self.RefreshValue = self.RefreshValue or 
		function(self)
			if(self.onrefresh) then
				self:onrefresh();
			end
		end
	BlizzardOptionsPanel_RegisterControl(self, self:GetParent());
end
-------------------------------------------------------------------------------------------------------
function VideoOptionsDropDown_OnClick(self)
	local value = self:GetID();
	local dropdown = self:GetParent().dropdown;
	-- other values to change?
	if((dropdown.data ~= nil) and 
	   (dropdown.data[value]~= nil) and 
	   (dropdown.data[value].notify ~= nil)) then
		for key, notify_value in pairs(dropdown.data[value].notify) do
			_G[key].notifytarget(_G[key], notify_value);
		end
	end
	-- check whether it is valid	
	VideoOptionsDropDownMenu_SetSelectedID(dropdown, value, 1);
	VideoOptionsDropDownMenu_SetSelectedID(dropdown, dropdown:GetValue(), 1);

--	if ( dropdown.value == value ) then
--		dropdown.newValue = nil;
--	else
--		VideoOptionsFrameApply:Enable();		-- we have a change, enable the Apply button
--		dropdown.newValue = value;
--	end

	VideoOptionsFrameApply:Enable();		-- we have a change, enable the Apply button
	dropdown.newValue = value;

	if(dropdown.dependent ~= nil) then
		for i, key in ipairs(dropdown.dependent) do
			local func = _G[key].dependtarget;
			if(func ~= nil) then
				func(_G[key]);
			end
		end
	end
end

function Graphics_TableGetValue(self)
	if(self.selectedID ~= nil) then
		return self.selectedID;
	end
	local readCvars = {};
	for key, value in ipairs(self.data) do
		local match = true;
		if(value.cvars ~= nil) then
			for cvar, cvar_value in pairs(value.cvars) do
				if(readCvars[cvar] == nil) then
					readCvars[cvar] = BlizzardOptionsPanel_GetCVarSafe(cvar);
				end
				if(readCvars[cvar] ~= cvar_value) then
					match = false;
					break;
				end
			end
		end
		if(match==true and value.notify ~= nil) then
			for key, notify_value in pairs(value.notify) do
				if(_G[key].GetNewValueString) then
					if(_G[key]:GetNewValueString() ~= notify_value) then
						match = false;
						break;
					end
				end
			end
		end
		if(match == true) then
			return key;
		end
	end
	return 1+#self.data;
end

VideoOptionsEffectsPanel_Default = Graphics_Default;
VideoOptionsEffectsPanel_Refresh = Graphics_Refresh;
VideoOptionsEffectsPanel_OnEvent = Graphics_OnEvent;
-------------------------------------------------------------------------------------------------------
function Graphics_OnLoad (self)
	self.name = RESOLUTION_LABEL;
	VideoOptionsPanel_OnLoad(self, nil, nil, Graphics_Default, Graphics_Refresh);
	self:SetScript("OnEvent", Graphics_OnEvent);
end
-------------------------------------------------------------------------------------------------------
function VideoOptionsEffectsPanel_OnLoad (self)
	self.name = EFFECTS_LABEL;
--	VideoOptionsEffectsPanelSubText:SetText(EFFECTS_SUBTEXT);
	VideoOptionsPanel_OnLoad(self);
	-- this must come AFTER the parent OnLoad because the functions will be set to defaults there
	self:SetScript("OnEvent", VideoOptionsEffectsPanel_OnEvent);
end
-------------------------------------------------------------------------------------------------------
--[[Stereo Options]]


function VideoOptionsStereoPanel_OnLoad (self)
	self.name = STEREO_VIDEO_LABEL;
	self.options = VideoStereoPanelOptions;
	if ( IsStereoVideoAvailable() ) then
		VideoOptionsPanel_OnLoad(self);
	end
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:SetScript("OnEvent", VideoOptionsStereoPanel_OnEvent);
end

function VideoOptionsStereoPanel_Default(self)
	SetDefaultVideoOptions(2);
	for _, control in next, self.controls do
		if ( control.defaultValue and control.value ~= control.defaultValue ) then
			control:SetValue(control.defaultValue);
		end
		control.newValue = nil;
	end
end

function VideoOptionsStereoPanel_OnEvent(self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);
	
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		-- don't allow systems that don't support features to enable them
		local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
		if ( not hardwareCursor ) then
			VideoOptionsStereoPanelHardwareCursor:SetChecked(false);
			VideoOptionsStereoPanelHardwareCursor:Disable();
		end
		VideoOptionsStereoPanelHardwareCursor.SetChecked =
			function (self, checked)
				local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
				if ( not hardwareCursor ) then
					checked = false;
				end
				getmetatable(self).__index.SetChecked(self, checked);
			end
		VideoOptionsStereoPanelHardwareCursor.Enable =
			function (self)
				local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
				if ( not hardwareCursor ) then
					return;
				end
				getmetatable(self).__index.Enable(self);
				local text = _G[self:GetName().."Text"];
				local fontObject = text:GetFontObject();
				_G[self:GetName().."Text"]:SetTextColor(fontObject:GetTextColor());
			end
	end
end


-------------------------------------------------------------------------------------------------------
function Slider_Disable(self)
	local label = _G[self:GetName().."Label"];
	if ( label ) then
		label:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	BlizzardOptionsPanel_Slider_Disable(self);
end

-------------------------------------------------------------------------------------------------------
function Slider_Enable(self)
	local label = _G[self:GetName().."Label"];
	if ( label ) then
		label:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	BlizzardOptionsPanel_Slider_Enable(self);
end
-------------------------------------------------------------------------------------------------------
function VideoOptions_Enable(self)
	if(self.type == CONTROLTYPE_DROPDOWN) then
		VideoOptionsDropDownMenu_EnableDropDown(self);
	elseif(self.type == CONTROLTYPE_SLIDER) then
		Slider_Enable(self);
	end
end
-------------------------------------------------------------------------------------------------------
function VideoOptions_Disable(self)
	if(self.type == CONTROLTYPE_DROPDOWN) then
		VideoOptionsDropDownMenu_DisableDropDown(self);
	elseif(self.type == CONTROLTYPE_SLIDER) then
		Slider_Disable(self);
	end
end
-------------------------------------------------------------------------------------------------------
function VideoOptionsDropDownMenu_dependtarget_refreshtable(self)
	if(self.onrefresh) then
		self:onrefresh();											-- update our enable-state
	end
	local saveValue = self.table[self:GetValue()];				-- get previous string correponding to current value
	self.tablerefresh = true;									-- say our table is dirty
	VideoOptionsDropDownMenu_Initialize(self, self.initialize);	-- regenerate our table
	self.value = nil;											-- don't worry about the old value
	self.newValue = self:lookup(saveValue);						-- what will the index be in the new table?
	VideoOptionsDropDownMenu_SetSelectedID(self,self.newValue,1);
end

