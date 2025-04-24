local usedGroups = {};
function CompactRaidFrameManager_UpdateFilterInfo(self)
	CompactRaidFrameManager_UpdateRoleFilterButton(self.displayFrame.filterOptions.filterRoleTank);
	CompactRaidFrameManager_UpdateRoleFilterButton(self.displayFrame.filterOptions.filterRoleHealer);
	CompactRaidFrameManager_UpdateRoleFilterButton(self.displayFrame.filterOptions.filterRoleDamager);

	RaidUtil_GetUsedGroups(usedGroups);
	for i=1, MAX_RAID_GROUPS do
		CompactRaidFrameManager_UpdateGroupFilterButton(self.displayFrame.filterOptions["filterGroup"..i], usedGroups);
	end
end

function CompactRaidFrameManager_UpdateRoleFilterButton(button)
	local totalAlive, totalCount = RaidInfoCounts["aliveRole"..button.role], RaidInfoCounts["totalRole"..button.role]
	button:SetFormattedText("%s %d/%d", button.roleTexture, totalAlive, totalCount);
	local keepGroupsTogether = CompactRaidFrameManager_GetSetting("KeepGroupsTogether");
	keepGroupsTogether = keepGroupsTogether and keepGroupsTogether ~= "0";
	if ( totalCount == 0 or keepGroupsTogether ) then
		button.selectedHighlight:Hide();
		button:Disable();
		button:SetAlpha(0.5);
	else
		button:Enable();
		button:SetAlpha(1);
		local isFiltered = CRF_GetFilterRole(button.role)
		if ( isFiltered ) then
			button.selectedHighlight:Show();
		else
			button.selectedHighlight:Hide();
		end
	end
end

function CompactRaidFrameManager_UpdateContainerBounds(self)
	if ( self.dynamicContainerPosition ) then
		--Should be below the TargetFrameSpellBar at its lowest height..
		local top = GetScreenHeight() - 135;
		--Should be just above the FriendsFrameMicroButton.
		local bottom = 330;

		local managerTop = self:GetTop();

		self.containerResizeFrame:ClearAllPoints();
		self.containerResizeFrame:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, top - managerTop);
		self.containerResizeFrame:SetHeight(top - bottom);

		CompactRaidFrameManager_ResizeFrame_UpdateContainerSize(self);
	end
end

local MAGNETIC_FIELD_RANGE = 10;
function CompactRaidFrameManager_ResizeFrame_CheckMagnetism(manager)
	if ( abs(manager.containerResizeFrame:GetLeft() - manager:GetRight()) < MAGNETIC_FIELD_RANGE and
		manager.containerResizeFrame:GetTop() > manager:GetBottom() and manager.containerResizeFrame:GetBottom() < manager:GetTop() ) then
		local resizeFrameTop = manager.containerResizeFrame:GetTop();
		local managerTop = manager:GetTop();
		manager.containerResizeFrame:ClearAllPoints();
		manager.containerResizeFrame:SetPoint("TOPLEFT", manager, "TOPRIGHT", 0, resizeFrameTop - managerTop);
	end
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

local defaultFilterOptions = {
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[7] = true,
	[8] = true,
	displayRoleNONE = true;
	displayRoleTANK = true;
	displayRoleHEALER = true;
	displayRoleDAMAGER = true;
}

Blizzard_CompactRaidFrameManager_FilterOptions = nil

function CompactRaidFrameManager_GetFilterOptions(index)

	if not Blizzard_CompactRaidFrameManager_FilterOptions then
		Blizzard_CompactRaidFrameManager_FilterOptions = defaultFilterOptions
	end

	return Blizzard_CompactRaidFrameManager_FilterOptions[index];
end

function CompactRaidFrameManager_SetFilterOptions(index, newValue)

	if not Blizzard_CompactRaidFrameManager_FilterOptions then
		Blizzard_CompactRaidFrameManager_FilterOptions = defaultFilterOptions
	end

	Blizzard_CompactRaidFrameManager_FilterOptions[index] = newValue;
end