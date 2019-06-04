-- this code is shared between the frame and glue
----------------------------
VideoData={};				--master array
-------------------------------------------------------------------------------------------------------

GREYCOLORCODE = "|cff7f7f7f"
GREENCOLORCODE= "|cff00ff00"

-- We change the size here so that we are able to swap in the old video options screens
-- move to XML when other screens are permanently retired
VideoOptionsFrame:SetSize(858,660);
VideoOptionsFrameCategoryFrame:SetSize(175,569);

local DefaultVideoOptions = {};
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
	VRN_WINDOWS_32BIT,
	VRN_GPU_DRIVER,
};

VR_WINDOWS_32BIT = 4096;


function VideoOptionsValueChanged(self, value, flag)
	self.newValue = value;

	if(self.type == CONTROLTYPE_DROPDOWN) then
		VideoOptionsDropDownMenu_SetSelectedID(self, value, flag);
	else
		if(self.SetDisplayValue) then
			self.SetDisplayValue(self, value);
		end
	end
end

function GetLowBit(value)
	local index = 0;
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
	if(self.description ~= nil) then
		tooltip = tooltip .. self.description .. "|n";
	end

	if(self.data ~= nil) then
		if (self.graphicsCVar ~= nil) then
			self.validity = {GetCVarSettingValidity(self.graphicsCVar, #self.data, self.raid)};
		else
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
					self.validity[cvar_name][cvar_value] = validity[index] or 0;
					index = index + 1;
				end
			end
		end
		-- we now have a table of bit fields which will tell us yes/no/maybe, etc, with each option.

		local recommendedIndex = nil;
		if(self.graphicsCVar ~= nil) then
			recommendedIndex = GetDefaultVideoOption(self.graphicsCVar, false);
		end

		local recommendedValue = nil;
		for i, value in ipairs(self.data) do
			local invalid = false;
			local recommended = false;
			local errorValue = nil;
			if(recommendedIndex ~= nil) then
				if (recommendedIndex == i) then
					recommended = true;
				end
			elseif(value.cvars ~= nil) then
				recommended = true;
				local validity = 0;
				for cvar_name, cvar_value in pairs(value.cvars) do
					validity = bit.bor(validity, self.validity[cvar_name][cvar_value]);
					if(DefaultVideoOptions[cvar_name] ~= cvar_value) then
						recommended = false;
					end
				end
				while(validity > 0) do
					invalid = true;
					local err = GetLowBit(validity);
					validity = validity - bit.lshift(1,err);
					errorValue = (errorValue or "") .. ErrorCodes[err] .. "|n";
				end
			end
			if(not invalid and recommended) then
				recommendedValue = value.text;
			end
			if (value.tooltip ~= nil) then
				tooltip = tooltip .. "|n" .. "|cffffd200" .. value.text .. HEADER_COLON .."|r ";
				if(invalid) then
					tooltip = tooltip .. GREYCOLORCODE;
				elseif(recommended) then
					tooltip = tooltip .. GREENCOLORCODE;
				end
				tooltip =  tooltip .. value.tooltip;
				if(invalid or recommended) then
					tooltip = tooltip .. "|r";
				end
				tooltip = tooltip .. "|n";
			else
				if(invalid) then
					tooltip = tooltip .. "|n" .. "|cffffd200" .. value.text .. HEADER_COLON .. "|r ";
				end
			end
			if(errorValue ~= nil) then
				tooltip = tooltip .. "|cffff0000" .. errorValue .. "|r";
			end
		end
		if(recommendedValue ~= nil) then
			tooltip = tooltip .. "|n" .. VIDEO_OPTIONS_RECOMMENDED .. HEADER_COLON .. " " .. GREENCOLORCODE .. recommendedValue .. "|r|n";
		end
	end
	if(self.cappedTooltip) then
		tooltip = tooltip.."|n"..self.cappedTooltip;
	end
	if(self.clientRestart == true) then
		tooltip = tooltip .. "|n|cffff0000" .. VIDEO_OPTIONS_NEED_CLIENTRESTART .. "|r";
	end
	self.tooltip = tooltip;
end

local inrefresh = nil;

function Graphics_EnableApply(self)
	if(not inrefresh) then
		VideoOptionsFrameApply:Enable();
	end
end

function Graphics_Refresh(self)
	-- first level
	for key, value in pairs(VideoData) do
		_G[key].selectedID = nil;
	end
	VideoOptionsPanel_Refresh( Display_);
	VideoOptionsPanel_Refresh( Graphics_);
	VideoOptionsPanel_Refresh( RaidGraphics_);
	VideoOptionsPanel_Refresh( Advanced_);
end

function VideoOptionsPanel_Refresh (self)
	inrefresh = true;
	BlizzardOptionsPanel_Refresh(self);
	-- second level.
	-- do three levels of dependency
	for i=1,3 do
		for key, value in pairs(VideoData) do
			local control = _G[key];
			if(control.needrefresh) then
				BlizzardOptionsPanel_RefreshControlSingle(control);
				control.needrefresh = false;
			end
		end
	end
	inrefresh = false;
end

function Graphics_OnEvent (self, event, ...)
	BlizzardOptionsPanel_OnEvent( Display_, event, ...);
	BlizzardOptionsPanel_OnEvent( Graphics_, event, ...);
	BlizzardOptionsPanel_OnEvent( RaidGraphics_, event, ...);
end

function ControlSetValue(self, value)
	if (value ~= nil) then
		self:SetValue(value);
		self.value = nil;
		self.newValue = nil;
	end
end

function ControlCheckCapTargets(self)
	for _, name in pairs(self.capTargets) do
		local frame = _G[name];
		if ( frame and frame.onCapCheck ) then
			frame.onCapCheck(frame);
		end
	end
end

function ControlGetCurrentCvarValue(self, checkCvar)
	local value = self.newValue or self:GetValue();
	if ( self.data and self.data[value] ) then
		for cvar, cvarValue in pairs(self.data[value].cvars) do
			if ( cvar == checkCvar ) then
				return cvarValue, value;
			end
		end
	else
		-- this means a custom cvar from config.wtf
		return GetCVar(checkCvar);
	end
end

function ControlGetActiveCvarValue(self, checkCvar)
	local activeCVarValue = tonumber(GetCVar(checkCvar));
	if ( self.data ) then
		for i = 1, #self.data do
			for cvar, cvarValue in pairs(self.data[i].cvars) do
				if ( cvar == checkCvar and cvarValue == activeCVarValue ) then
					return cvarValue, i;
				end
			end
		end
	end
	-- this means a custom cvar from config.wtf
	return GetCVar(checkCvar);
end

local function FinishChanges(self)
	if ( VideoOptionsFrame.gxRestart ) then
		VideoOptionsFrame.gxRestart = nil;
		RestartGx();
		-- reload some tables and redisplay
		Display_DisplayModeDropDown.selectedID = nil; 							 	-- invalidates cached value
		BlizzardOptionsPanel_RefreshControlSingle(Display_DisplayModeDropDown);		-- hardware may not have set this, so we need to refresh

		Display_ResolutionDropDown.tablerefresh = true;
		Display_PrimaryMonitorDropDown.tablerefresh = true;
		Graphics_Refresh(self)
	end

	RaidGraphics_Quality:commitslider();
	Graphics_Quality:commitslider();
end

local function CommitChange(self)
	local name = self:GetName();
	if(name == "Graphics_Quality" or name == "RaidGraphics_Quality") then
		return;
	end
	local value = self.newValue or self.value;
	if ( self.newValue ) then
		if ( self.value ~= self.newValue ) then
			if ( self.gameRestart ) then
				VideoOptionsFrame.gameRestart = true;
			end
			if ( self.restart ) then
				VideoOptionsFrame.gxRestart = true;
			end
		end
	end
	ControlSetValue(self, value);
end

function Graphics_Okay(self)
	CommitChange(Display_PrimaryMonitorDropDown);
	VideoOptionsPanel_Okay( Display_);
	VideoOptionsPanel_Okay( Graphics_);
	VideoOptionsPanel_Okay( RaidGraphics_);
end

function VideoOptionsPanel_Okay (self)
	for _, control in next, self.controls do
		CommitChange(control);
	end
	FinishChanges(self);
end

function Graphics_Cancel(self)
	VideoOptionsPanel_Cancel( Display_);
	VideoOptionsPanel_Cancel( Graphics_);
	VideoOptionsPanel_Cancel( RaidGraphics_);
end

function VideoOptionsPanel_Cancel (self)
	for _, control in next, self.controls do
		if ( control.value ~= control.newValue ) then
			if ( control.restart ) then
				VideoOptionsFrame.gxRestart = true;
			end
		end
		-- we need to force-set the value here just in case the control was doing dynamic updating
		ControlSetValue(control, control.value);
	end
	VideoOptionsFrame.gxRestart = nil;
	VideoOptionsFrame.gameRestart = nil;
end

function VideoOptionsPanel_Default (self)
	for _, control in next, self.controls do
		control.newValue = nil;
		control.value = nil;
	end
end

function Graphics_Default (self, perControlCallback)
	SetDefaultVideoOptions(0);
	VideoOptionsPanel_Default( Display_);
	VideoOptionsPanel_Default( Graphics_);
	VideoOptionsPanel_Default( RaidGraphics_);
	FinishChanges(self);
end

function Graphics_Classic (self)
	for key, value in pairs(VideoData) do
		local control = _G[key];
		if(control.classic and control:GetValue() ~= control.classic) then
			VideoOptions_OnClick(control, control.classic);
			if(control.type == CONTROLTYPE_DROPDOWN) then
				local text = control.data[control.classic].text;
				VideoOptionsDropDownMenu_SetText(control, text);
			elseif(control.type == CONTROLTYPE_SLIDER) then
				control:SetDisplayValue(control.classic);
			end
		elseif(key == "Graphics_Quality" or key == "RaidGraphics_Quality") then
			control.noclick = true;
			Graphics_Quality:SetValue(""..ClassicGraphicsQuality);	-- set the slider only
			control.noclick = false;
		end
	end
end

function Advanced_Default (self, perControlCallback)
	SetDefaultVideoOptions(1);
	if(not InGlue()) then
		SetDefaultVideoOptions(2);
	end
	for _, control in next, self.controls do
		if(string.find(control:GetName(), "Advanced_")) then
			control.newValue = nil;
			control.value = nil;
		end
	end
	FinishChanges(self);
end

function Graphics_TableSetValue(self, value)
	if(self.graphicsCVar) then
		--New method: Call into helper functions and let the C-side handle values.
		SetCVar(self.graphicsCVar, value);
	elseif(self.data[value] and self.data[value].cvars ~= nil) then
		for cvar, cvar_value in pairs(self.data[value].cvars) do
			--Old method: Set CVars directly.
			BlizzardOptionsPanel_SetCVarSafe(cvar, cvar_value);
		end
	end
end
-------------------------------------------------------------------------------------------------------
local function IsValid(self,index)
	if(index == nil) then
		return false;
	end
	local valid = true;
	local is32BitFail = false;
	if(self.graphicsCVar ~= nil) then
		if(self.validity[index] ~= 0) then
			valid = false;
		end
		if(self.validity[index] == VR_WINDOWS_32BIT) then
			is32BitFail = true;
		end
	elseif(self.data ~= nil) then
		if(self.data[index] and self.data[index].cvars ~= nil) then
			for cvar_name, cvar_value in pairs(self.data[index].cvars) do
				if(self.validity[cvar_name][cvar_value] ~= 0) then
					valid = false;
				end
				if(self.validity[cvar_name][cvar_value] == VR_WINDOWS_32BIT) then
					is32BitFail = true;
				end
			end
		end
	end
	return valid, is32BitFail;
end

function Graphics_NotifyTarget(self, masterIndex, isRaid)
	local dropdownIndex = GetGraphicsDropdownIndexByMasterIndex(self.graphicsCVar, masterIndex, isRaid);
	local value = nil;
	if(self.type == CONTROLTYPE_DROPDOWN) then
		value = self.data[dropdownIndex].text;
	elseif(self.type == CONTROLTYPE_SLIDER) then
		value = dropdownIndex;
	end

	local isValid, is32BitFail = IsValid(self, dropdownIndex);
	if(isValid) then
		self.selectedName = nil;
		self.selectedValue = nil;
		self.newValue = dropdownIndex;
		self.selectedID = dropdownIndex;
		if(self.type == CONTROLTYPE_DROPDOWN) then
			VideoOptionsDropDownMenu_SetText(self, value);
		elseif(self.type == CONTROLTYPE_SLIDER) then
			self:SetDisplayValue(dropdownIndex);
		end
		self.warning:Hide();
		if ( self.capTargets ) then
			ControlCheckCapTargets(self);
		end
	else
		if(self.type == CONTROLTYPE_DROPDOWN) then
			-- get best previous entry
			for fallbackIndex = dropdownIndex - 1, 1, -1 do
				local isValid = IsValid(self, fallbackIndex);
				if (isValid) then
					self.newValue = fallbackIndex;
					self.selectedID = fallbackIndex;
					VideoOptionsDropDownMenu_SetText(self, self.data[fallbackIndex].text);
					break;
				end
			end
		end
		if ( is32BitFail ) then
			self.warning.tooltip = string.format(SETTING_BELOW_GRAPHICSQUALITY_32BIT, self.name, value);
		else
			self.warning.tooltip = string.format(SETTING_BELOW_GRAPHICSQUALITY, self.name, value);
		end
		self.warning:Show();
	end
	return;
end

---------------------------------------------------
function Graphics_TableLookup(self, val)
	if(self.table ~= nil) then
		for i, value in ipairs(self.table) do
			if(value == val) then
				return i;
			end
		end
		return 1+#self.table;	-- custom
	end
	return nil;
end
---------------------------------------------------
function Graphics_TableLookupSafe(self, val)
	local id = Graphics_TableLookup(self, val);
	if(id > #self.table) then
		return #self.table;									-- return a legal value. We should use query for recommended setting
	else
		return id;
	end
end
-------------------------------------------------------------------------------------------------------
function Graphics_TableGetValue(self)
	if(self.graphicsCVar) then
		return tonumber(GetCVar(self.graphicsCVar));
	end

	if(self.childOptions) then
		for i = 1, self.numQualityLevels do
			local allMatch = true;
			for _, child in pairs(self.childOptions) do
				if(_G[child].graphicsCVar) then
					local childValue = _G[child].newValue or tonumber(GetCVar(_G[child].graphicsCVar));
					if(GetGraphicsDropdownIndexByMasterIndex(_G[child].graphicsCVar, i, self.raid) ~= childValue) then
						allMatch = false;
						break;
					end
				end
			end
			if(allMatch) then
				return i;
			end
		end
		return nil;
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
				if(_G[key] == nil) then
					return nil;
				end
				if(_G[key].GetNewValueString) then
					local v = _G[key]:GetNewValueString();
					if(v == nil) then
						return 1+#self.data;	-- not yet valid, catch on dependency
					end
					if(v ~= notify_value) then
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

-------------------------------------------------------------------------------------------------------
-- OnClick handlers
--
function VideoOptions_OnClick(self, value)
	-- other values to change?
	if(self.childOptions ~= nil) then
		for _, child in pairs(self.childOptions) do
			_G[child]:notifytarget(value, self.raid);
		end
	end
	-- check whether it is valid
	VideoOptionsValueChanged(self, value, 1);
	VideoOptionsValueChanged(self, self:GetValue(), 1);
	VideoOptionsFrameApply:Enable();		-- we have a change, enable the Apply button
	self.newValue = value;
	if(self.dependent ~= nil) then
		for i, key in ipairs(self.dependent) do
			_G[key].isdependtarget = true;
			if(_G[key].onrefresh) then
				_G[key]:onrefresh();
			end
			local func = _G[key].dependtarget;
			if(func ~= nil) then
				func(_G[key]);
			end
			_G[key].isdependtarget = false;
		end
	end
	if ( self.capTargets ) then
		ControlCheckCapTargets(self);
	end
end

function VideoOptionsDropDown_OnClick(self)
	local value = self:GetID();
	local dropdown = self:GetParent().dropdown;
	VideoOptions_OnClick(dropdown, value);
end

function Display_RaidSettingsEnabled_CheckButton_OnLoad(self)
	self.cvar = "RAIDsettingsEnabled";
	self.SetValue = function (self, value)
			--Don't do anything if it was already this value
			if ( GetCVar(self.cvar) == value ) then
				return;
			end

			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
			-- currently only two settings normal[0] and raid/BG[1]
			if (not InGlue()) then
				AutoChooseCurrentGraphicsSetting();
			end
		end
	VideoOptionsCheckbox_OnLoad(self);
end

function Display_RaidSettingsEnabled_CheckButton_OnClick(self)
	if ( self.cvar ) then
		BlizzardOptionsPanel_CheckButton_OnClick(self);
		VideoOptionsFrameApply:Enable();		-- we have a change, enable the Apply button
		GraphicsOptions_SelectBase();
	end
end

function Dispaly_RaidSettingsEnabled_CheckButton_OnShow(self)
	self:SetChecked( GetCVarBool("RAIDsettingsEnabled") );
	if (not InGlue()) then
		local _, instanceType = IsInInstance()
		if ( instanceType == "raid" or instanceType == "pvp" ) then
			GraphicsOptions_SelectRaid();
			return;
		end
	end
	GraphicsOptions_SelectBase();
end

function GraphicsOptions_SelectBase()
	PanelTemplates_SelectTab(GraphicsButton);
	Graphics_:Show();
	GraphicsButton:SetFrameLevel( Graphics_:GetFrameLevel() + 1 );

	if ( Display_RaidSettingsEnabledCheckBox:GetChecked() ) then
		PanelTemplates_DeselectTab(RaidButton);
	else
		PanelTemplates_SetDisabledTabState(RaidButton);
	end
	RaidGraphics_:Hide();
	RaidButton:SetFrameLevel( Graphics_:GetFrameLevel() - 1 );
end

function GraphicsOptions_SelectRaid()
	if ( not Display_RaidSettingsEnabledCheckBox:GetChecked() ) then
		GraphicsOptions_SelectBase(RaidButton);
		return;
	end

	PanelTemplates_SelectTab(RaidButton);
	Graphics_:Hide();
	GraphicsButton:SetFrameLevel( RaidGraphics_:GetFrameLevel() - 1 );

	PanelTemplates_DeselectTab(GraphicsButton);
	RaidGraphics_:Show();
	RaidButton:SetFrameLevel( RaidGraphics_:GetFrameLevel() + 1 );
end
-------------------------------------------------------------------------------------------------------
-- Refresh handlers
function Graphics_ControlRefreshValue(self)
	if(self.onrefresh) then
		self:onrefresh();
	end
	if(self.type == CONTROLTYPE_DROPDOWN) then
		Graphics_DropDownRefreshValue(self);
	elseif(self.type == CONTROLTYPE_SLIDER) then
		Graphics_SliderRefreshValue(self);
	elseif(self.type == CONTROLTYPE_CHECKBOX) then
		BlizzardOptionsPanel_CheckButton_Refresh(self)
	end
end

function Graphics_SliderRefreshValue(self)
	if(self.initialize) then
		self:initialize();
	end
end

function Graphics_DropDownRefreshValue(self)
	VideoOptionsDropDownMenu_Initialize(self, self.initialize);
	VideoOptionsDropDownMenu_SetSelectedID(self, self:GetValue(), 1);
	local graphicsQuality = "Graphics_Quality";
	if (self.raid) then
		graphicsQuality = "RaidGraphics_Quality";
	end
	if(self.dependent ~= nil) then
		local checkWarning;
		for i, key in ipairs(self.dependent) do
			 _G[key].needrefresh = true;
			 if ( key == graphicsQuality ) then
				checkWarning = true;
			 end
		end
		-- check warning if this control depended on the graphics quality slider
		if ( checkWarning ) then
			local isValid = true;
			local is32BitFail = false;
			local masterIndex;
			if (self.raid) then
				masterIndex = BlizzardOptionsPanel_GetCVarSafe("RAIDgraphicsQuality");
			else
				masterIndex = BlizzardOptionsPanel_GetCVarSafe("graphicsQuality");
			end
			if(self.cvar) then
				local index = GetGraphicsDropdownIndexByMasterIndex(self.cvar, masterIndex, self.raid);
				isValid, is32BitFail = IsValid(self, index);
				if ( not isValid ) then
					if ( is32BitFail ) then
						self.warning.tooltip = string.format(SETTING_BELOW_GRAPHICSQUALITY_32BIT, self.name, value);
					else
						self.warning.tooltip = string.format(SETTING_BELOW_GRAPHICSQUALITY, self.name, value);
					end
					self.warning:Show();
				else
					self.warning:Hide();
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------
-- Enable / Disable
function Slider_Disable(self)
	local label = _G[self:GetName().."Label"];
	if ( label ) then
		label:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	BlizzardOptionsPanel_Slider_Disable(self);
end

function Slider_Enable(self)
	local label = _G[self:GetName().."Label"];
	if ( label ) then
		label:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	BlizzardOptionsPanel_Slider_Enable(self);
end

function VideoOptions_Enable(self)
	if(self.type == CONTROLTYPE_DROPDOWN) then
		VideoOptionsDropDownMenu_EnableDropDown(self);
	elseif(self.type == CONTROLTYPE_SLIDER) then
		Slider_Enable(self);
	elseif(self.type == CONTROLTYPE_CHECKBOX) then
		BlizzardOptionsPanel_CheckButton_Enable(self);
	end
end

function VideoOptions_Disable(self)
	if(self.type == CONTROLTYPE_DROPDOWN) then
		VideoOptionsDropDownMenu_DisableDropDown(self);
	elseif(self.type == CONTROLTYPE_SLIDER) then
		Slider_Disable(self);
	elseif(self.type == CONTROLTYPE_CHECKBOX) then
		BlizzardOptionsPanel_CheckButton_Disable(self);
	end
end
-------------------------------------------------------------------------------------------------------
-- control OnLoad
--
local function LoadVideoData(self)
	local name = self:GetName()
	if not VideoData[name] then
		message(("Missing VideoData for %q"):format(name));
		return;
	end

	-- preload the base data
	if ( name == "RaidGraphics_Quality" ) then
		for key, value in pairs(VideoData["Graphics_Quality"]) do
			self[key] = value;
		end
	end

	for key, value in pairs(VideoData[name]) do
		self[key] = value;
	end
	self["key"] = self;
end

function VideoOptionsDropDown_OnLoad(self)
	LoadVideoData(self);
	self.tablerefresh = true;
	if(self.onload ~= nil) then
		self.onload(self);
	end
	self.needrefresh = false;
	self.initialize = self.initialize or
		function (self, level)
			if(self.tablerefresh) then
				self.tooltiprefresh = true;
				self.table = {};
				self.tablerefresh = false;
				if(self.tablefunction ~= nil) then
					if(self.TABLENEXT == nil) then
						self.TABLENEXT = 1;
					end
					local mytable = {self.tablefunction(self)};      -- initialize the table
					local index = 1;
					for i=1, #mytable, self.TABLENEXT do
						if(self.readfilter ~= nil) then                	-- data needs special treatment before display
							local newtable={};
							for j=1, self.TABLENEXT do
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

			for mode, text in ipairs(self.table) do
				local info = VideoOptionsDropDownMenu_CreateInfo();
				info.text = text;
				info.value = text;
				info.func = self.onclickfunction or VideoOptionsDropDown_OnClick;
				-- disable settings
				if(self.data ~= nil) then
					if(self.data[mode].cvars ~= nil) then
						for cvar_name, cvar_value in pairs(self.data[mode].cvars) do
							if(self.validity[cvar_name][cvar_value] ~= 0 and self.validity[cvar_name][cvar_value] ~= VR_WINDOWS_32BIT) then
								info.notClickable = true;
								info.disablecolor = GREYCOLORCODE;
							end
						end
					else
						if (self.validity[mode] ~= 0) then
							info.notClickable = true;
							info.disablecolor = GREYCOLORCODE;
						end
					end
				end
				if ( self.capMaxValue and mode > self.capMaxValue ) then
					info.notClickable = true;
					info.disablecolor = GREYCOLORCODE;
				end
				VideoOptionsDropDownMenu_AddButton(info);
			end
		end
	self.SetValue = self.SetValue or Graphics_TableSetValue;
	self.GetValue =
		function(self)
			if(self.preGetValue) then
				self:preGetValue();
			end
			if(self.selectedID == nil) then
				self.selectedID = (self.doGetValue or Graphics_TableGetValue)(self);
			end
			return self.selectedID;
		end
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
	VideoOptionsDropDownMenu_SetWidth(self, self.width);
	-- force another control to change to a value
	if(self.graphicsCVar) then
		self.notifytarget = self.notifytarget or Graphics_NotifyTarget;
	else
		-- Only settings that use the new graphicsCVars can be notified.
		self.notifytarget = nil;
	end

	self.lookup = self.lookup or Graphics_TableLookup;
	self.RefreshValue = self.RefreshValue or Graphics_ControlRefreshValue;
	BlizzardOptionsPanel_RegisterControl(self, self:GetParent());
	if ( self.capTargets ) then
		ControlCheckCapTargets(self);
	end
end

function VideoOptionsCheckbox_OnLoad(self)
	LoadVideoData(self);
	self.type = self.type or CONTROLTYPE_CHECKBOX;
	if(self.onload ~= nil) then
		self.onload(self);
	end
	self.SetValue = self.SetValue or
		function(self, value)
		end
	BlizzardOptionsPanel_RegisterControl(self, self:GetParent())
end

function VideoOptionsSlider_OnLoad(self)
	LoadVideoData(self);
	self.type = self.type or CONTROLTYPE_SLIDER;
	if(self.onload ~= nil) then
		self.onload(self);
	end
	self.RefreshValue = self.RefreshValue or Graphics_ControlRefreshValue;
	BlizzardOptionsPanel_RegisterControl(self, self:GetParent());
end

-------------------------------------------------------------------------------------------------------

function VideoOptionsPanel_OnLoad (self, okay, cancel, default, refresh)
	local defaults
	self.hasApply = true;
	if (self.raid) then
		defaults =  {GetDefaultVideoOptions(true)};
	else
		defaults =  {GetDefaultVideoOptions(false)};
	end

	for i=1, #defaults, 2 do
		DefaultVideoOptions[defaults[i]]=defaults[i+1];
	end
end

function VideoOptionsPanel_OnShow(self)
	if ( self.hasApply ) then
		VideoOptionsFrameApply:Show();
	else
		VideoOptionsFrameApply:Hide();
	end
end

function Graphics_OnLoad (self)
	self.name = GRAPHICS_LABEL;
	self.hasApply = true;
	self.classic = Graphics_Classic;
	VideoOptionsPanel_OnLoad( Display_);
	VideoOptionsPanel_OnLoad( Graphics_);
	VideoOptionsPanel_OnLoad( RaidGraphics_);
	BlizzardOptionsPanel_OnLoad(self, Graphics_Okay, Graphics_Cancel, Graphics_Default, Graphics_Refresh);
	OptionsFrame_AddCategory(VideoOptionsFrame, self);
	self:SetScript("OnEvent", Graphics_OnEvent);
end

AdvancedPanelOptions = {
	ClipCursor		= { text = "LOCK_CURSOR_TEXT" },
}

function Advanced_OnLoad (self)
	self.name = ADVANCED_LABEL;
	self.options = AdvancedPanelOptions;
	self.hasApply = true;

	VideoOptionsPanel_OnLoad(self);
	BlizzardOptionsPanel_OnLoad(self, VideoOptionsPanel_Okay, VideoOptionsPanel_Cancel, Advanced_Default, VideoOptionsPanel_Refresh);
	OptionsFrame_AddCategory(VideoOptionsFrame, self);

	if(true) then
		local name = self:GetName();
		_G[name .. "StereoEnabled"]:Hide();
		_G[name .. "Convergence"]:Hide();
		_G[name .. "EyeSeparation"]:Hide();
		_G[name .. "StereoHeader"]:Hide();
		_G[name .. "StereoHeaderUnderline"]:Hide();
	end
end

--
-- Network
--
NetworkPanelOptions = {
	disableServerNagle = { text = "OPTIMIZE_NETWORK_SPEED" },
	useIPv6 = { text = "USEIPV6" },
	advancedCombatLogging = { text = "ADVANCED_COMBAT_LOGGING" },
}

function NetworkOptionsPanel_OnLoad(self)
	self.name = NETWORK_LABEL;
	self.options = NetworkPanelOptions;
	self.hasApply = true;
	BlizzardOptionsPanel_OnLoad(self);
	OptionsFrame_AddCategory(VideoOptionsFrame, self);
end

function NetworkOptionsPanel_CheckButton_OnClick(self)
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	BlizzardOptionsPanel_CheckButton_OnClick(self);
	if ( self.cvar ) then
		BlizzardOptionsPanel_SetCVarSafe(self.cvar, self:GetChecked(), self.event);
	end
	Graphics_EnableApply(self);
end


-- [[ Languages Options Panel ]] --

LanguagesPanelOptions = {
	useEnglishAudio = { text = "USE_ENGLISH_AUDIO" },
}

function LanguagePanel_Cancel (self)
	local dropDowns = { InterfaceOptionsLanguagesPanelLocaleDropDown, InterfaceOptionsLanguagesPanelAudioLocaleDropDown };
	for i = 1, #dropDowns do
		if (dropDowns[i].value ~= dropDowns[i].oldValue) then
			dropDowns[i].SetValue(dropDowns[i], dropDowns[i].oldValue);
		end
	end
end

function LanguagePanel_Okay (self)
	local dropDowns = { InterfaceOptionsLanguagesPanelLocaleDropDown, InterfaceOptionsLanguagesPanelAudioLocaleDropDown };
	for i = 1, #dropDowns do
		if (dropDowns[i].value ~= dropDowns[i].oldValue) then
			dropDowns[i].oldValue = dropDowns[i].value;
		end
	end
	BlizzardOptionsPanel_Okay(self);
end

function InterfaceOptionsLanguagesPanel_OnLoad (self)
	self.name = LANGUAGES_LABEL;
	self.options = LanguagesPanelOptions;
	self.hasApply = true;
	BlizzardOptionsPanel_OnLoad(self, LanguagePanel_Okay, LanguagePanel_Cancel, BlizzardOptionsPanel_Default, BlizzardOptionsPanel_Refresh);
	OptionsFrame_AddCategory(VideoOptionsFrame, self);
end

function InterfaceOptionsLanguagesPanel_UpdateRestartTexture()
	if (InterfaceOptionsLanguagesPanelAudioLocaleDropDown.originalValue ~= InterfaceOptionsLanguagesPanelAudioLocaleDropDown.value
		or InterfaceOptionsLanguagesPanelLocaleDropDown.originalValue ~= InterfaceOptionsLanguagesPanelLocaleDropDown.value) then
		Language_ShowRestartTexture(InterfaceOptionsLanguagesPanel, InterfaceOptionsLanguagesPanelLocaleDropDown.value);
	else
		InterfaceOptionsLanguagesPanel.RestartNeeded:Hide();
	end
end



function InterfaceOptionsLanguagesPanelLocaleDropDown_OnLoad (self)
	self.type = CONTROLTYPE_DROPDOWN;
	BlizzardOptionsPanel_RegisterControl(self, self:GetParent());

	self.cvar = "textLocale";

	local value = GetCVar(self.cvar);
	self.defaultValue = GetCVarDefault(self.cvar);
	self.oldValue = value;
	self.originalValue = value;
	self.value = value;
	self.tooltip = OPTION_TOOLTIP_LOCALE;

	VideoOptionsDropDownMenu_SetWidth(self, 200);
	VideoOptionsDropDownMenu_Initialize(self, InterfaceOptionsLanguagesPanelLocaleDropDown_Initialize);
	VideoOptionsDropDownMenu_SetSelectedValue(self, value);

	self.SetValue =
		function (self, value)
			local currentValue = VideoOptionsDropDownMenu_GetSelectedValue(self);
			local audioCurrentValue = VideoOptionsDropDownMenu_GetSelectedValue(InterfaceOptionsLanguagesPanelAudioLocaleDropDown);
			-- Audio dropdown value should follow changes to text dropdown, except if user has explicitly chosen English instead of
			-- the text level.
			if (audioCurrentValue ~= "enUS" or currentValue == "enUS") then
				InterfaceOptionsLanguagesPanelAudioLocaleDropDown.SetValue(InterfaceOptionsLanguagesPanelAudioLocaleDropDown, value);
			end
			if (value == "enUS") then
				VideoOptionsDropDownMenu_DisableDropDown(InterfaceOptionsLanguagesPanelAudioLocaleDropDown);
			else
				VideoOptionsDropDownMenu_EnableDropDown(InterfaceOptionsLanguagesPanelAudioLocaleDropDown);
			end

			SetCVar("textLocale", value, self.event);
			self.value = value;
			InterfaceOptionsLanguagesPanel_UpdateRestartTexture();
			VideoOptionsDropDownMenu_SetSelectedValue(self, value);
		end
	self.GetValue =
		function (self)
			return VideoOptionsDropDownMenu_GetSelectedValue(self);
		end
	self.RefreshValue =
		function (self)
			VideoOptionsDropDownMenu_Initialize(self, InterfaceOptionsLanguagesPanelLocaleDropDown_Initialize);
			VideoOptionsDropDownMenu_SetSelectedValue(self, self.value);
		end
end

function InterfaceOptionsLanguagesPanelAudioLocaleDropDown_OnLoad(self)
	self.type = CONTROLTYPE_DROPDOWN;
	BlizzardOptionsPanel_RegisterControl(self, self:GetParent());

	self.cvar = "audioLocale";

	local value = GetCVar(self.cvar);
	self.defaultValue = GetCVarDefault(self.cvar);
	self.oldValue = value;
	self.originalValue = value;
	self.value = value;
	self.tooltip = OPTION_TOOLTIP_AUDIO_LOCALE;

	VideoOptionsDropDownMenu_SetWidth(self, 200);
	VideoOptionsDropDownMenu_Initialize(self, InterfaceOptionsLanguagesPanelLocaleDropDown_Initialize);
	VideoOptionsDropDownMenu_SetSelectedValue(self, value);

	self.SetValue =
		function (self, value)
			SetCVar("audioLocale", value, self.event);
			self.value = value;
			InterfaceOptionsLanguagesPanel_UpdateRestartTexture();
			VideoOptionsDropDownMenu_SetSelectedValue(self, value);
		end
	self.GetValue =
		function (self)
			return VideoOptionsDropDownMenu_GetSelectedValue(self);
		end
	self.RefreshValue =
		function (self)
			VideoOptionsDropDownMenu_Initialize(self, InterfaceOptionsLanguagesPanelAudioLocaleDropDown_Initialize);
			VideoOptionsDropDownMenu_SetSelectedValue(self, self.value);

			local audioLocales = {GetAvailableAudioLocales()};
			if (#audioLocales <= 1) then
				VideoOptionsDropDownMenu_DisableDropDown(InterfaceOptionsLanguagesPanelAudioLocaleDropDown);
			else
				VideoOptionsDropDownMenu_EnableDropDown(InterfaceOptionsLanguagesPanelAudioLocaleDropDown);
			end
		end

end

function InterfaceOptionsLanguagesPanelLocaleDropDown_OnClick (self)
	local dropdown = self:GetParent().dropdown;
	dropdown.SetValue(dropdown, self.value);
	Graphics_EnableApply(self);
end

function InterfaceOptionsLanguagesPanelLocaleDropDown_Initialize (self)
	local selectedValue = VideoOptionsDropDownMenu_GetSelectedValue(self);
	local info = VideoOptionsDropDownMenu_CreateInfo();

	InterfaceOptionsLanguagesPanelLocaleDropDown_InitializeHelper(info, selectedValue, GetAvailableLocales());
end

function GetAvailableAudioLocales()
	if (GetCVar("textLocale") == "enUS") then
		return "enUS";
	end
	return "enUS", GetCVar("textLocale");
end

function InterfaceOptionsLanguagesPanelAudioLocaleDropDown_Initialize (self)
	local selectedValue = VideoOptionsDropDownMenu_GetSelectedValue(self);
	local info = VideoOptionsDropDownMenu_CreateInfo();

	InterfaceOptionsLanguagesPanelLocaleDropDown_InitializeHelper(info, selectedValue, GetAvailableAudioLocales());
	if (GetCVar("textLocale") == "enUS") then
		VideoOptionsDropDownMenu_DisableDropDown(InterfaceOptionsLanguagesPanelAudioLocaleDropDown);
	end
end

LanguageRegions = {}
LanguageRegions["deDE"] = 0;
LanguageRegions["enGB"] = 1;
LanguageRegions["enUS"] = 2;
LanguageRegions["esES"] = 3;
LanguageRegions["frFR"] = 4;
LanguageRegions["koKR"] = 5;
LanguageRegions["zhCN"] = 6;
LanguageRegions["zhTW"] = 7;
LanguageRegions["enCN"] = 8;
LanguageRegions["enTW"] = 9;
LanguageRegions["esMX"] = 10;
LanguageRegions["ruRU"] = 11;
LanguageRegions["ptBR"] = 12;
LanguageRegions["ptPT"] = 13;
LanguageRegions["itIT"] = 14; -- For 1.12: These indices map to UV coordiantes in textures that we don't need to update, so don't remove itIT

LANGUAGE_TEXT_HEIGHT = 22/512;

function Language_SetOSLanguageTexture(self)
	local OSlocale = GetOSLocale();
	local locale = GetCVar("textLocale");
	local value = LanguageRegions[OSlocale];
	if ((OSlocale ~= locale) and value) then
		self.Texture:SetTexCoord(0.0, 1.0, LANGUAGE_TEXT_HEIGHT * value, (LANGUAGE_TEXT_HEIGHT * value) + LANGUAGE_TEXT_HEIGHT);
		self:Show();
	else
		self:Hide();
	end
end

function Language_ShowRestartTexture(self, region)
	if (region) then
		local value = LanguageRegions[region];
		if ( value ) then
			self.RestartNeeded:SetTexCoord(0.0, 1.0, LANGUAGE_TEXT_HEIGHT * value, (LANGUAGE_TEXT_HEIGHT * value) + LANGUAGE_TEXT_HEIGHT);
			self.RestartNeeded:Show();
		end
	end
end


function InterfaceOptionsLanguagesPanelLocaleDropDown_InitializeHelper (createInfo, selectedValue, ...)
	local currentChoiceAdded = false;
	for i = 1, select("#", ...) do
		local value = select(i, ...);
		if (value and LanguageRegions[value]) then
			InterfaceOptionsLanguagesPanelLocaleDropDown_InitializeChoice(createInfo, value);
			if ( value == selectedValue ) then
				createInfo.checked = 1;
				currentChoiceAdded = true;
			else
				createInfo.checked = nil;
			end
			VideoOptionsDropDownMenu_AddButton(createInfo);
		end
	end

	if ( not currentChoiceAdded and LanguageRegions[selectedValue]) then
		InterfaceOptionsLanguagesPanelLocaleDropDown_InitializeChoice(createInfo, selectedValue);
		createInfo.checked = 1;
		VideoOptionsDropDownMenu_AddButton(createInfo);
	end
end

function InterfaceOptionsLanguagesPanelLocaleDropDown_InitializeChoice(createInfo, value)
	createInfo.text = nil;
	createInfo.iconOnly = true;
	createInfo.icon = "Interface\\Common\\Lang-Regions";
	createInfo.iconInfo = {};
	createInfo.iconInfo.tCoordLeft = 0.0;
	createInfo.iconInfo.tCoordRight = 1.0;
	createInfo.iconInfo.tCoordTop = LANGUAGE_TEXT_HEIGHT * LanguageRegions[value];
	createInfo.iconInfo.tCoordBottom = (LANGUAGE_TEXT_HEIGHT * LanguageRegions[value]) + LANGUAGE_TEXT_HEIGHT;
	createInfo.iconInfo.tSizeX = 256;
	createInfo.iconInfo.tSizeY = 22;
	createInfo.func = InterfaceOptionsLanguagesPanelLocaleDropDown_OnClick;
	createInfo.value = value;
end

function Graphics_SliderOnLoad(self)
	VideoOptionsSlider_OnLoad(self);

	local name = self:GetName();
	local _, maxValue = self:GetMinMaxValues();
	self.type = CONTROLTYPE_SLIDER;

	self.validity = {GetCVarSettingValidity(self.graphicsCVar, maxValue, self.raid)};

	self.SetDisplayValue = self.SetValue;

	self.SetValue = Graphics_TableSetValue;

	self.GetCurrentValue = function(self)
		return self.newValue or tonumber(GetCVar(self.graphicsCVar));
	end;

	if(self.graphicsCVar) then
		self.notifytarget = self.notifytarget or Graphics_NotifyTarget;
	else
		-- Only settings that use the new graphicsCVars can be notified.
		self.notifytarget = nil;
	end

	_G[name.."Text"]:SetFontObject("OptionsFontSmall");
	_G[name.."Text"]:SetText("");
	_G[name.."High"]:Hide();

	self.Label = _G[name.."Low"];
	self.Label:ClearAllPoints();
	self.Label:SetPoint("LEFT", self, "RIGHT", 3, 2);
end

function Graphics_SliderOnValueChanged(self, value, userInput)
	if(userInput) then
		Graphics_EnableApply(self);
		self.newValue = value;
		VideoOptions_OnClick(self, value);
	end
	self.Label:SetText(value);
end

function Graphics_SliderOnShow(self)
	self:SetDisplayValue(self:GetCurrentValue());
end
