function CompactRaidFrameManager_OnLoad(self)
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	self.container = CompactRaidFrameContainer;
	
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	
	self.container:SetWidth(1000);
	self.dynamicContainerPosition = true;
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
	local manager = CompactRaidFrameManager;
	if ( value == "lock" ) then
		CompactRaidFrameManager_LockContainer(manager);
		CompactRaidFrameManagerOptionsFrameLockedModeLock:LockHighlight();
		CompactRaidFrameManagerOptionsFrameLockedModeUnlock:UnlockHighlight();
	elseif ( value == "unlock" ) then
		CompactRaidFrameManager_UnlockContainer(manager);
		CompactRaidFrameManagerOptionsFrameLockedModeLock:UnlockHighlight();
		CompactRaidFrameManagerOptionsFrameLockedModeUnlock:LockHighlight();
	else
		CompactRaidFrameManager_SetSetting("Locked", CompactRaidFrameManager_GetSettingDefault("Locked"));
		GMError("Unknown lock value: "..tostring(value));
	end
end

function CompactRaidFrameManager_SetSortMode(value)
	local manager = CompactRaidFrameManager;
	if ( value == "group" ) then
		CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_Group);
		CompactRaidFrameManagerOptionsFrameSortModeByGroup:LockHighlight();
		CompactRaidFrameManagerOptionsFrameSortModeByRole:UnlockHighlight();
	elseif ( value == "role" ) then
		CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_Role);
		CompactRaidFrameManagerOptionsFrameSortModeByGroup:UnlockHighlight();
		CompactRaidFrameManagerOptionsFrameSortModeByRole:LockHighlight();
	else
		CompactRaidFrameManager_SetSetting("SortMode", CompactRaidFrameManager_GetSettingDefault("SortMode"));
		GMError("Unknown sort mode: "..tostring(value));
	end
end

function CompactRaidFrameManager_SetGroupMode(value)
	local container = CompactRaidFrameManager.container;
	CompactRaidFrameContainer_SetGroupMode(container, value);
	if ( value == "discrete" ) then
		CompactRaidFrameManagerOptionsFrameGroupModeDiscrete:LockHighlight();
		CompactRaidFrameManagerOptionsFrameGroupModeFlush:UnlockHighlight();
		
		CompactRaidFrameManagerOptionsFrameSortModeByGroup:Hide();
		CompactRaidFrameManagerOptionsFrameSortModeByRole:Hide();
		CompactRaidFrameManagerOptionsFrameManagedModeManaged:Show();
		CompactRaidFrameManagerOptionsFrameManagedModeFree:Show();
	elseif ( value == "flush" ) then
		CompactRaidFrameManagerOptionsFrameGroupModeDiscrete:UnlockHighlight();
		CompactRaidFrameManagerOptionsFrameGroupModeFlush:LockHighlight();
		
		CompactRaidFrameManagerOptionsFrameSortModeByGroup:Show();
		CompactRaidFrameManagerOptionsFrameSortModeByRole:Show();
		CompactRaidFrameManagerOptionsFrameManagedModeManaged:Hide();
		CompactRaidFrameManagerOptionsFrameManagedModeFree:Hide();
	else
		CompactRaidFrameManager_SetSetting("GroupMode", CompactRaidFrameManager_GetSettingDefault("GroupMode"));
		GMError("Unknown group mode: "..tostring(value));
	end
end


function CompactRaidFrameManager_UpdateContainerBounds(self) --Hah, "Bounds" instead of "SizeAndPosition". WHO NEEDS A THESAURUS NOW?!
	if ( self.dynamicContainerPosition ) then
		--Should be below the TargetFrameSpellBar at its lowest height..
		local top = GetScreenHeight() - 135;
		--Should be just above the FriendsFrameMicroButton.
		local bottom = 300;
		
		local containerCenter = (top + bottom) / 2;
		local managerCenter = (self:GetTop() + self:GetBottom()) / 2;
		
		self.container:ClearAllPoints();
		self.container:SetPoint("LEFT", self, "RIGHT", 0, containerCenter - managerCenter);
		self.container:SetHeight(top - bottom);
	end
end

function CompactRaidFrameManager_LockContainer(self)
	self.containerResizeFrame:Hide();
end

function CompactRaidFrameManager_UnlockContainer(self)
	--Anchor the resizer to the current position.
	CompactRaidFrameManager_ResizeFrame_Reanchor(self);
	
	self.containerResizeFrame:Show();
end

local RESIZE_OUTSETS = 5;
--ResizeFrame related functions
function CompactRaidFrameManager_ResizeFrame_Reanchor(manager)
	manager.containerResizeFrame:ClearAllPoints();
	manager.containerResizeFrame:SetPoint("TOPLEFT", manager.container, "TOPLEFT", -RESIZE_OUTSETS, RESIZE_OUTSETS);
	manager.containerResizeFrame:SetPoint("BOTTOMLEFT", manager.container, "BOTTOMLEFT", -RESIZE_OUTSETS, -RESIZE_OUTSETS);
end

function CompactRaidFrameManager_ResizeFrame_OnDragStart(manager)
	manager.dynamicContainerPosition = false;
	
	manager.container:StartMoving();
end

function CompactRaidFrameManager_ResizeFrame_OnDragStop(manager)
	manager.container:StopMovingOrSizing();
	CompactRaidFrameManager_ResizeFrame_CheckMagnetism(manager);
end

function CompactRaidFrameManager_ResizeFrame_OnResizeStart(manager)
	manager.dynamicContainerPosition = false;
	
	manager.containerResizeFrame:StartSizing("BOTTOMRIGHT")
	manager.containerResizeFrame:SetScript("OnUpdate", CompactRaidFrameManager_ResizeFrame_OnUpdate);
end

function CompactRaidFrameManager_ResizeFrame_OnResizeStop(manager)
	manager.containerResizeFrame:StopMovingOrSizing();
	manager.containerResizeFrame:SetScript("OnUpdate", nil);
	CompactRaidFrameManager_ResizeFrame_UpdateContainerSize(manager);
end

local RESIZE_UPDATE_INTERVAL = 0.5;
function CompactRaidFrameManager_ResizeFrame_OnUpdate(self, elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed;
	if ( self.timeSinceUpdate >= RESIZE_UPDATE_INTERVAL ) then
		CompactRaidFrameManager_ResizeFrame_UpdateContainerSize(self:GetParent());
	end
end

function CompactRaidFrameManager_ResizeFrame_UpdateContainerSize(manager)
	--Re-anchor the frame by the topleft
	local top, left = manager.container:GetTop(), manager.container:GetLeft();
	manager.container:ClearAllPoints();
	manager.container:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top);
	
	manager.container:SetHeight(manager.containerResizeFrame:GetHeight() - RESIZE_OUTSETS * 2);
	CompactRaidFrameManager_ResizeFrame_Reanchor(manager);
	CompactRaidFrameManager_ResizeFrame_CheckMagnetism(manager);
end

local MAGNETIC_FIELD_RANGE = 10;
function CompactRaidFrameManager_ResizeFrame_CheckMagnetism(manager)
	if ( abs(manager.container:GetLeft() - manager:GetRight()) < MAGNETIC_FIELD_RANGE and
		manager.container:GetTop() > manager:GetBottom() and manager.container:GetBottom() < manager:GetTop() ) then
		--Figure out the anchor point;
		--We anchor by the LEFT.
		local managerCenter = (manager:GetTop() + manager:GetBottom()) / 2;
		local containerCenter = (manager.container:GetTop() + manager.container:GetBottom()) / 2;
		manager.container:ClearAllPoints();
		manager.container:SetPoint("LEFT", manager, "RIGHT", 0, containerCenter - managerCenter);
	end
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
	
	--Fallthrough: Sort by order in Raid window.
	return id1 < id2;
end

local roleValues = { MAINTANK = 1, MAINASSIST = 2, TANK = 3, HEALER = 4, DAMAGER = 5, NONE = 6 };
function CRFSort_Role(token1, token2)
	local id1, id2 = UnitInRaid(token1), UnitInRaid(token2);
	local role1, role2;
	if ( id1 ) then
		role1 = select(10, GetRaidRosterInfo(id1));
	end
	if ( id2 ) then
		role2 = select(10, GetRaidRosterInfo(id2));
	end
	
	role1 = role1 or UnitGroupRolesAssigned(token1);
	role2 = role2 or UnitGroupRolesAssigned(token2);
	
	local value1, value2 = roleValues[role1], roleValues[role2];
	if ( value1 ~= value2 ) then
		return value1 < value2;
	end
	
	--Fallthrough: Sort alphabetically.
	return CRFSort_Alphabetical(token1, token2);
end

function CRFSort_Alphabetical(token1, token2)
	local name1, name2 = UnitName(token1), UnitName(token2);
	if ( name1 and name2 ) then
		return name1 < name2;
	elseif ( name1 or name2 ) then
		return name1;
	end
	
	--Fallthrough: Alphabetic order of tokens (just here to make comparisons well-ordered)
	return token1 < token2;
end