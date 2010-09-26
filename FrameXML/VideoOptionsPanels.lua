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

VideoOptionsFrame:SetSize(858,660);
VideoOptionsFrameCategoryFrame:SetSize(175,569);

function Graphics_PrepareTooltip(self)
	local tooltip = "";
	if(self.description ~= nil) then
		tooltip = tooltip .. self.description .. "|n|n";
	end
	if (self.data ~= nil) then
		local cvar_data = {}
		local cvar_count = 0;
		for i, value in ipairs(self.data) do
			self.table[i]=value.text;
			if(value.cvars ~= nil) then
				if(cvar_count == 0) then
					for cvar_name, cvar_value in pairs(value.cvars) do
						tinsert(cvar_data, cvar_name);
						cvar_count = cvar_count + 1;
					end
				end
				-- there should be the same number of cvars on each. test for this!
				for cvar_name, cvar_value in pairs(value.cvars) do
					tinsert(cvar_data, cvar_value);
				end
			end
		end
		local validity = {GetToolTipInfo(cvar_count, (#cvar_data)/cvar_count - 1, unpack(cvar_data) )};
		-- we now have a table of bit fields which will tell us yes/no/maybe, etc, with each option.

		for i, value in ipairs(self.data) do
			local invalid = (validity[i] ~= nil) and (validity[i] ~= 0);
			tooltip = tooltip .. "|cffffd200" .. value.text .. ":|r ";
			if (value.tooltip ~= nil) then
				if(invalid) then
					tooltip = tooltip .. "|cff7f7f7f";
				end
				tooltip =  tooltip .. value.tooltip;
				if(invalid) then
					tooltip = tooltip .. " (0x" .. string.format("%x", validity[i]) .. ")" .. "|r";
				end
			end
			tooltip = tooltip .. "|n";
		end
	end
	if(self.restart == true) then
		tooltip = tooltip .. "|n|cffff0000" .. NEED_GXRESTART .. "|r";
	end
	self.tooltip = tooltip;
end

function Graphics_Default (self)
	RestoreVideoResolutionDefaults();
	for _, control in next, self.controls do
		control.newValue = nil;
	end
end

function Graphics_Refresh (self)
	-- first level
	BlizzardOptionsPanel_Refresh(self);
	-- second level.

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
-- generic functions used for all drop-downs
-------------------------------------------------------------------------------------------------------
function VideoOptionsDropDown_OnLoad(self)
	local dropdownkey = self:GetName();
	if(VideoData[dropdownkey] ~= nil) then
		for key, value in pairs(VideoData[dropdownkey]) do
			self[key] = value;
		end
	end
	self.tablerefresh = true;
	self.tooltiprefresh = true;
	if(self.onload ~= nil) then
		self.onload(self);
	end
	self.needrefresh = false;
	self.initialize = self.initialize or 
		function (self, level)
			self.newValue = nil;
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
			local info = VideoOptionsDropDownMenu_CreateInfo();
			for mode, text in ipairs(self.table) do
				info.text = text;
				info.value = text;
				info.func = self.onclickfunction or VideoOptionsDropDown_OnClick;
				info.checked = nil;
				VideoOptionsDropDownMenu_AddButton(info);
			end
		end
	self.SetValue = self.SetValue or Graphics_TableSetValue;
	self.GetValue = self.GetValue or Graphics_TableGetValue;
	self.GetNewValueString = self.GetNewValueString or 
		function(self)
			if(self.table ~= nil) then
				-- there is a bit of a design flaw in the options widgets.
				-- the code relies on either self.newValue==nil or self.newValue~=self.value
				-- instead of just the second. this patch is the result. todo : fix.
				return self.table[self.newValue or self.selectedID or self.value];
			end
			return nil;
		end
	self.type = self.type or CONTROLTYPE_DROPDOWN;
	-- register the control
	BlizzardOptionsPanel_RegisterControl(self, self:GetParent());
	if(self.width == nil) then
		self.width = 110;
	end
	VideoOptionsDropDownMenu_SetWidth(self.width, self);


	-- force another control to change to a value
	self.notifytarget = self.notifytarget or
		function (self, value)
			for i, val in ipairs(self.table) do
				if(val == value) then
					self.newValue = i;
					break;
				end
			end
			self.selectedName = value;
			self.selectedID = nil;
			self.selectedValue = nil;
			VideoOptionsDropDownMenu_SetText(value, self);	-- we only notify with legal values??
		end

	self.lookup = self.lookup or Graphics_TableLookup;
	self.RefreshValue = self.RefreshValue or Graphics_TableRefreshValue;
	self.dependtarget = self.dependtarget or Graphics_TableDependTarget;
end


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
	VideoOptionsDropDownMenu_SetSelectedID(dropdown, value, 1);
	if ( dropdown.value == value ) then
		dropdown.newValue = nil;
	else
		VideoOptionsFrameApply:Enable();		-- we have a change, enable the Apply button
		dropdown.newValue = value;
	end
	if(dropdown.dependent ~= nil) then
		for i, key in ipairs(dropdown.dependent) do
			local func = _G[key].dependtarget;
			if(func ~= nil) then
				func(_G[key]);
			end
		end
	end
end

--
-- if skipcvar is true, we are doing a validation based on the user selected options,
-- not the state of the cvars
--
function Graphics_TableGetValue(self)
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
	RestoreVideoStereoDefaults();
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
function VideoOptions_Enable(self)
	if(self.type == CONTROLTYPE_DROPDOWN) then
		VideoOptionsDropDownMenu_EnableDropDown(self);
	end
end
-------------------------------------------------------------------------------------------------------
function VideoOptions_Disable(self)
	if(self.type == CONTROLTYPE_DROPDOWN) then
		VideoOptionsDropDownMenu_DisableDropDown(self);
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

