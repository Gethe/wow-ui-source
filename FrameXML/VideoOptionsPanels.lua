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
	VRN_NEEDS_MACOS_10_5_5,
	VRN_NEEDS_MACOS_10_5_7,
	VRN_NEEDS_MACOS_10_5_8,
	VRN_NEEDS_MACOS_10_6_4,
	VRN_NEEDS_MACOS_10_6_5,
	VRN_GPU_DRIVER,
};

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
			local invalid = false;
			local recommended = false;
			local errorValue = nil;
			if(value.cvars ~= nil) then
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
				tooltip = tooltip .. "|n" .. "|cffffd200" .. value.text .. ":|r ";
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
					tooltip = tooltip .. "|n" .. "|cffffd200" .. value.text .. ":|r " .. "|cff7f7f7f";
				end
			end
			if(errorValue ~= nil) then
				tooltip = tooltip .. "|cffff0000" .. errorValue .. "|r";
			end
			-- if(i ~= #self.data) then
			--	tooltip = tooltip .. "|n";	-- no space after the last item (unless recommended is coming)
			-- end
		end
		if(recommendedValue ~= nil) then
			tooltip = tooltip .. "|n" .. VIDEO_OPTIONS_RECOMMENDED .. ": " .. GREENCOLORCODE .. recommendedValue .. "|r|n";
		end
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

function VideoOptionsPanel_Refresh(self)
	Graphics_Refresh(self);
end

function Graphics_Refresh (self)
	inrefresh = true;
	-- first level
	for key, value in pairs(VideoData) do
		_G[key].selectedID = nil;
	end
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
	inrefresh = false;
end

function Graphics_OnEvent (self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);
end

function ControlSetValue(self, value)
	if(value ~= nil) then
		self:SetValue(value);
		self.value = nil;
		self.newValue = nil;
	end
end

local function FinishChanges(self)
	if ( VideoOptionsFrame.gxRestart ) then
		VideoOptionsFrame.gxRestart = nil;
		RestartGx();
		-- reload some tables and redisplay
		Graphics_DisplayModeDropDown.selectedID = nil; 							 	-- invalidates cached value
		BlizzardOptionsPanel_RefreshControl(Graphics_DisplayModeDropDown);			-- hardware may not have set this, so we need to refresh

		Graphics_ResolutionDropDown.tablerefresh = true;
		Graphics_PrimaryMonitorDropDown.tablerefresh = true;
		Graphics_MultiSampleDropDown.tablerefresh = true;
		Graphics_RefreshDropDown.tablerefresh = true;
		Graphics_Refresh(Graphics_);
	end
	Graphics_Quality:commitslider();
end

local function CommitChange(self)
	if(self:GetName() == "Graphics_Quality") then
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

function VideoOptionsPanel_Okay (self)
	CommitChange(Graphics_PrimaryMonitorDropDown);
	for _, control in next, self.controls do
		CommitChange(control);
	end
	FinishChanges(self);
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
	Graphics_Default(self);
end

function Graphics_Default (self)
	SetDefaultVideoOptions(0);
	for _, control in next, self.controls do
		if(string.find(control:GetName(), "Graphics_")) then
			control.newValue = nil;
			control.value = nil;
		end
	end
	FinishChanges(self);
end

function Advanced_Default (self)
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
	if(self.data[value].cvars ~= nil) then
		for cvar, cvar_value in pairs(self.data[value].cvars) do
			BlizzardOptionsPanel_SetCVarSafe(cvar, cvar_value);
		end
	end
end
-------------------------------------------------------------------------------------------------------
function IsValid(self,index)
	if(index == nil) then
		return false;
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
	return valid;
end
-------------------------------------------------------------------------------------------------------
-- try to keep the same selection when a table has been changed
function VideoOptionsDropDownMenu_dependtarget_refreshtable(self)
	local saveValue = self.table[self:GetValue()];				-- get previous string correponding to current value
	self.tablerefresh = true;									-- say our table is dirty
	VideoOptionsDropDownMenu_Initialize(self, self.initialize);	-- regenerate our table
	VideoOptionsValueChanged(self,self:lookup(saveValue),1);
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
	if((self.data ~= nil) and 
	   (self.data[value]~= nil) and 
	   (self.data[value].notify ~= nil)) then
		for key, notify_value in pairs(self.data[value].notify) do
			_G[key].notifytarget(_G[key], notify_value);
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
end

function VideoOptionsDropDown_OnClick(self)
	local value = self:GetID();
	local dropdown = self:GetParent().dropdown;
	VideoOptions_OnClick(dropdown, value);
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
		-- no check refresh yet
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
	if(self.dependent ~= nil) then
		for i, key in ipairs(self.dependent) do
			 _G[key].needrefresh = true;
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
	for key, value in pairs(VideoData[self:GetName()]) do
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
			self.newValue = nil;
			if(self.tablerefresh) then
				self.tooltiprefresh = true;
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
			local p = self:GetValue();
			for mode, text in ipairs(self.table) do
				local info = VideoOptionsDropDownMenu_CreateInfo();
				info.text = text;
				info.value = text;
				info.func = self.onclickfunction or VideoOptionsDropDown_OnClick;
--				info.checked = nil;
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
						-- This plus the check mark feels very distracting to look at.
						-- if(recommended) then
						-- 	info.colorCode = GREENCOLORCODE;
						-- end
					end
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
	VideoOptionsDropDownMenu_SetWidth(self.width, self);
	-- force another control to change to a value
	self.notifytarget = self.notifytarget or
		function (self, value)
			local index;
			if(self.table == nil) then
				return nil;
			end
			for i, val in ipairs(self.table) do
				if(val == value) then
					index = i;
					break;
				end
			end
			if(IsValid(self, index)) then
				self.selectedName = nil;
				self.selectedValue = nil;
				self.newValue = index;
				self.selectedID = index;
				VideoOptionsDropDownMenu_SetText(value, self);
			end
		end

	self.lookup = self.lookup or Graphics_TableLookup;
	self.RefreshValue = self.RefreshValue or Graphics_ControlRefreshValue;
	BlizzardOptionsPanel_RegisterControl(self, self:GetParent());
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
-- OnLoad for each page
function VideoOptionsPanel_OnLoad (self, okay, cancel, default, refresh)
	local defaults =  {GetDefaultVideoOptions()};
	for i=1, #defaults, 2 do
		DefaultVideoOptions[defaults[i]]=defaults[i+1];
	end
	okay = okay or VideoOptionsPanel_Okay;
	cancel = cancel or VideoOptionsPanel_Cancel;
	default = default or VideoOptionsPanel_Default;
	refresh = refresh or VideoOptionsPanel_Refresh;
	BlizzardOptionsPanel_OnLoad(self, okay, cancel, default, refresh);
	OptionsFrame_AddCategory(VideoOptionsFrame, self);
end

function Graphics_OnLoad (self)
	if(IsGMClient() and InGlue()) then
		local qualityNames =
		{
			VIDEO_QUALITY_LABEL1,
			VIDEO_QUALITY_LABEL2,
			VIDEO_QUALITY_LABEL3,
			VIDEO_QUALITY_LABEL4,
			VIDEO_QUALITY_LABEL5,
		}
		local count = #VideoData["Graphics_Quality"].data;
		for i=1, count do
			local defaults =  {GetVideoOptions(i)};
			ThisVideoOptions = {};
			for m=1, #defaults, 2 do
				ThisVideoOptions[defaults[m]]=defaults[m+1];
			end
			local notify = VideoData["Graphics_Quality"].data[i].notify;
			for key, value in pairs(notify) do
				for j=1, #VideoData[key].data do
					if(VideoData[key].data[j].text == value) then
						for cvar, cvar_value in pairs(VideoData[key].data[j].cvars) do
							if(ThisVideoOptions[cvar] ~= cvar_value) then
								print("mismatch " .. key .. "[" .. qualityNames[i] .. "]:" .. cvar .. ", c++:" .. ThisVideoOptions[cvar] .. " ~= lua:" .. cvar_value);
								VideoData[key].data[j].cvars[cvar] = ThisVideoOptions[cvar];
							end
						end
					end
				end
			end
		end
	end
	self.name = GRAPHICS_LABEL;
	VideoOptionsPanel_OnLoad(self, nil, nil, Graphics_Default, nil)
	self:SetScript("OnEvent", Graphics_OnEvent);
end

function Advanced_OnLoad (self)
	self.name = ADVANCED_LABEL;
	VideoOptionsPanel_OnLoad(self, nil, nil, Advanced_Default, nil)
	-- this must come AFTER the parent OnLoad because the functions will be set to defaults there
	self:SetScript("OnEvent", Graphics_OnEvent);

	if(not IsStereoVideoAvailable()) then
		local name = self:GetName();
		_G[name .. "StereoEnabled"]:Hide();
		_G[name .. "Convergence"]:Hide();
		_G[name .. "EyeSeparation"]:Hide();
		_G[name .. "StereoHeader"]:Hide();
		_G[name .. "StereoHeaderUnderline"]:Hide();
	end
end



