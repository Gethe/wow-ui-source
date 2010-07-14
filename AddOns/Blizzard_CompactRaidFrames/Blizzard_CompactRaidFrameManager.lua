function CompactRaidFrameManager_OnLoad(self)
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	self.container = CompactRaidFrameContainer;
	
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	
	self.container:SetWidth(1000);
	CompactRaidFrameManager_UpdateContainerBounds(self);
	
	CompactRaidFrameManager_Collapse(self);
end

function CompactRaidFrameManager_OnEvent(self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		CompactRaidFrameManager_SetManaged(CompactRaidFrameManager_GetSetting("Managed"));
		CompactRaidFrameManager_SetLocked(CompactRaidFrameManager_GetSetting("Locked"));
		CompactRaidFrameManager_SetSortMode(CompactRaidFrameManager_GetSetting("SortMode"));
		CompactRaidFrameManager_SetGroupMode(CompactRaidFrameManager_GetSetting("GroupMode"));
	elseif ( event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" ) then
		CompactRaidFrameManager_UpdateContainerBounds(self);
	elseif ( event == "RAID_ROSTER_UPDATE" ) then
		if ( GetNumRaidMembers() > 0 ) then
			self:Show();
		else
			self:Hide();
		end
	end
end

function CompactRaidFrameManager_Toggle(self)
	if ( self.collapsed ) then
		CompactRaidFrameManager_Expand(self);
	else
		CompactRaidFrameManager_Collapse(self);
	end
end

function CompactRaidFrameManager_Expand(self)
	self.collapsed = false;
	self:SetWidth(200);
	self.optionsFrame:Show();
	self.toggleButton:SetText("<");
end

function CompactRaidFrameManager_Collapse(self)
	self.collapsed = true;
	self:SetWidth(25);
	self.optionsFrame:Hide();
	self.toggleButton:SetText(">");
end

--Settings stuff
function CompactRaidFrameManager_GetSetting(settingName)
	return GetCVar("raidOption"..settingName);
end

function CompactRaidFrameManager_GetSettingDefault(settingName)
	return GetCVarDefault("raidOption"..settingName);
end

function CompactRaidFrameManager_SetSetting(settingName, value)
	SetCVar("raidOption"..settingName, value);
	
	--Perform the actual functions
	if ( settingName == "Managed" ) then
		CompactRaidFrameManager_SetManaged(value);
	elseif ( settingName == "Locked" ) then
		CompactRaidFrameManager_SetLocked(value);
	elseif ( settingName == "SortMode" ) then
		CompactRaidFrameManager_SetSortMode(value);
	elseif ( settingName == "GroupMode" ) then
		CompactRaidFrameManager_SetGroupMode(value);
	end
end

function CompactRaidFrameManager_SetManaged(value)
	local container = CompactRaidFrameManager.container;
end

function CompactRaidFrameManager_SetLocked(value)
	local container = CompactRaidFrameManager.container;

end

function CompactRaidFrameManager_SetSortMode(value)
	local manager = CompactRaidFrameManager;
	if ( value == "group" ) then
		CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_Group);
		CompactRaidFrameManagerOptionsFrameSortModeByGroup:LockHighlight();
		CompactRaidFrameManagerOptionsFrameSortModeByRole:UnlockHighlight();
	--elseif ( value == "role" ) then
		--Do some awesome sorting?
	elseif ( value == "alphabetical" ) then
		CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_Alphabetical);
		CompactRaidFrameManagerOptionsFrameSortModeByGroup:UnlockHighlight();
		CompactRaidFrameManagerOptionsFrameSortModeByRole:LockHighlight();
	else
		GMError("Unknown sort mode: "..tostring(value));
		CompactRaidFrameManager_SetSetting("SortMode", CompactRaidFrameManager_GetSettingDefault("SortMode"));
	end
end

function CompactRaidFrameManager_SetGroupMode(value)
	local container = CompactRaidFrameManager.container;
	CompactRaidFrameContainer_SetGroupMode(container, value);
	if ( value == "discrete" ) then
		CompactRaidFrameManagerOptionsFrameGroupModeDiscrete:LockHighlight();
		CompactRaidFrameManagerOptionsFrameGroupModeFlush:UnlockHighlight();
		CompactRaidFrameManager_SetSetting("SortMode", "group");
		CompactRaidFrameManagerOptionsFrameSortModeByRole:Disable();
	elseif ( value == "flush" ) then
		CompactRaidFrameManagerOptionsFrameGroupModeDiscrete:UnlockHighlight();
		CompactRaidFrameManagerOptionsFrameGroupModeFlush:LockHighlight();
		CompactRaidFrameManagerOptionsFrameSortModeByRole:Enable();
	else
		GMError("Unknown group mode: "..tostring(value));
		CompactRaidFrameManager_SetSetting("GroupMode", CompactRaidFrameManager_GetSettingDefault("GroupMode"));
	end
end


function CompactRaidFrameManager_UpdateContainerBounds(self) --Hah, "Bounds" instead of "SizeAndPosition". WHO NEEDS A THESAURUS NOW?!
	--Should be below the TargetFrameSpellBar at its lowest height..
	local top = GetScreenHeight() - 135;
	--Should be just above the FriendsFrameMicroButton.
	local bottom = 300;
	
	self.container:ClearAllPoints();
	self.container:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, top - self:GetTop());
	self.container:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 0, bottom - self:GetBottom());
end

--Functions used for sorting and such
function CRFSort_Group(token1, token2)
	local id1 = tonumber(string.sub(token1, 5));
	local id2 = tonumber(string.sub(token2, 5));
	
	local _, _, subgroup1 = GetRaidRosterInfo(id1);
	local _, _, subgroup2 = GetRaidRosterInfo(id2);
	
	if ( subgroup1 and subgroup2 and subgroup1 ~= subgroup2 ) then
		return subgroup1 < subgroup2;
	end
	
	return id1 < id2;
end

function CRFSort_Alphabetical(token1, token2)
	local name1, name2 = UnitName(token1), UnitName(token2);
	if ( name1 and name2 ) then
		return name1 < name2;
	elseif ( name1 or name2 ) then
		return name1;
	else
		return token1 < token2;
	end
end