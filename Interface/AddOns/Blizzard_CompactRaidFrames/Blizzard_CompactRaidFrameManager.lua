NUM_WORLD_RAID_MARKERS = 8;
NUM_RAID_ICONS = 8;

WORLD_RAID_MARKER_ORDER = {};
WORLD_RAID_MARKER_ORDER[1] = 8;
WORLD_RAID_MARKER_ORDER[2] = 4;
WORLD_RAID_MARKER_ORDER[3] = 1;
WORLD_RAID_MARKER_ORDER[4] = 7;
WORLD_RAID_MARKER_ORDER[5] = 2;
WORLD_RAID_MARKER_ORDER[6] = 3;
WORLD_RAID_MARKER_ORDER[7] = 6;
WORLD_RAID_MARKER_ORDER[8] = 5;

MINIMUM_RAID_CONTAINER_HEIGHT = 72;

RAID_MARKER_RESET_ID = -1;

NUM_RAID_MARKERS = 8;
MAX_NUM_GROUPS = 8;

local function ReverseMarkerID(id)
	return NUM_RAID_MARKERS - id + 1; --+1 because it is a 1-based id. 
end

function CompactRaidFrameManager_OnLoad(self)
	self.container = CompactRaidFrameContainer;

	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UPDATE_ACTIVE_BATTLEFIELD");
	self:RegisterEvent("UNIT_FLAGS");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_DIFFICULTY_CHANGED");
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED");

	self.container:SetFlowFilterFunction(CRFFlowFilterFunc)
	self.container:SetGroupFilterFunction(CRFGroupFilterFunc)
	CompactRaidFrameManager_UpdateContainerBounds();

	CompactRaidFrameManager_Collapse();

	--Set up the options flow container
	FlowContainer_Initialize(self.displayFrame.optionsFlowContainer);

	do --filter group pool
		self.filterGroupPool = CreateFramePool("Button", self, "CRFManagerFilterGroupButtonTemplate");
		local parent = self.displayFrame.filterOptions;

		local buttons = {};
		for i = 1,MAX_NUM_GROUPS do
			local button = self.filterGroupPool:Acquire();
			button:SetParent(parent);
			button:SetParentKey("filterGroup"..i);
			button:SetText(i);
			button:SetID(i);
			tinsert(buttons, button);
			button:Show();
		end

		local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, MAX_NUM_GROUPS / 2, 2, 0);
		local anchor = CreateAnchor("TOPLEFT", parent.filterRoleTank, "BOTTOMLEFT", 0, 0);
		AnchorUtil.GridLayout(buttons, anchor, layout);
	end

	do --raid marker pool
		self.raidMarkerPool = CreateFramePool("Button", self, "CRFManagerRaidIconButtonTemplate");
		local parent = self.displayFrame.raidMarkers;

		local buttons = {};

		local function MakeRow(from, to, finalButton)
			for i = from, to do
				local button = self.raidMarkerPool:Acquire();
				button:SetParent(parent);
				button:SetID(ReverseMarkerID(i));
				button:SetParentKey("raidMarker"..i);
				tinsert(buttons, button);
				button:Show();
			end
		end

		local HalfNumMarkers = NUM_RAID_MARKERS / 2;

		MakeRow(1, HalfNumMarkers);

		local raidMarkerRemove = self.raidMarkerPool:Acquire();
		raidMarkerRemove.markerTexture:SetAtlas("GM-raidMarker-remove", TextureKitConstants.IgnoreAtlasSize);
		raidMarkerRemove:SetID(0);
		raidMarkerRemove:SetParent(parent);
		raidMarkerRemove.backgroundTexture:SetAlpha(0);
		tinsert(buttons, raidMarkerRemove);
		raidMarkerRemove:Show();
		raidMarkerRemove:SetParentKey("raidMarkerRemove");

		MakeRow(HalfNumMarkers + 1, NUM_RAID_MARKERS);

		local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, NUM_RAID_MARKERS / 2 + 1, 3, 0);
		local anchor = CreateAnchor("TOPLEFT", parent.raidMarkerUnitTab, "BOTTOMLEFT", 3, -4);
		AnchorUtil.GridLayout(buttons, anchor, layout);
	end

	--divider pools to be filled out on update
	self.container.dividerVerticalPool = CreateFramePool("Frame", self, "CRFManagerDividerVertical");
	self.container.dividerHorizontalPool = CreateFramePool("Frame", self, "CRFManagerDividerHorizontal");

	do --restrict pings dropdown
		local function IsSelected(restrictEnum)
			return C_PartyInfo.GetRestrictPings() == restrictEnum;
		end

		local function SetSelected(restrictEnum)
			local newValue = IsSelected(restrictEnum) and Enum.RestrictPingsTo.None or restrictEnum;
			C_PartyInfo.SetRestrictPings(newValue);
		end

		local dropdown = CompactRaidFrameManager.displayFrame.RestrictPingsDropdown;
		dropdown:SetWidth(158);
		dropdown:SetupMenu(function(dropdown, rootDescription)
			rootDescription:SetTag("MENU_RAID_FRAME_RESTRICT_PINGS");

			rootDescription:CreateRadio(NONE, IsSelected, SetSelected, Enum.RestrictPingsTo.None);
			rootDescription:CreateRadio(RAID_MANAGER_RESTRICT_PINGS_TO_LEAD, IsSelected, SetSelected, Enum.RestrictPingsTo.Lead);
			rootDescription:CreateRadio(RAID_MANAGER_RESTRICT_PINGS_TO_ASSIST, IsSelected, SetSelected, Enum.RestrictPingsTo.Assist);
			rootDescription:CreateRadio(RAID_MANAGER_RESTRICT_PINGS_TO_TANKS_HEALERS, IsSelected, SetSelected, Enum.RestrictPingsTo.TankHealer);
		end);
    end

	do --mode control dropdown
		local function IsSelected(isRaid)
			return IsInRaid() == isRaid;
		end

		local function SetSelected(isRaid)
			if isRaid then
				C_PartyInfo.ConvertToRaid();
			else
				C_PartyInfo.ConvertToParty();
			end
		end

		local dropdown = CompactRaidFrameManager.displayFrame.ModeControlDropdown;
		dropdown:SetWidth(100);
		dropdown:SetupMenu(function(dropdown, rootDescription)
			rootDescription:SetTag("MENU_RAID_FRAME_CONVERT_PARTY");

			local inRaid = true;
			rootDescription:CreateRadio(RAID, IsSelected, SetSelected, inRaid);
			rootDescription:CreateRadio(PARTY, IsSelected, SetSelected, not inRaid);
		end);
	end

	do --difficulty dropdown
		local dropdown = CompactRaidFrameManager.displayFrame.difficulty;

		dropdown:SetupMenu(function(dropdown, rootDescription)
			rootDescription:SetTag("MENU_RAID_FRAME_DIFFICULTY");

			local function IsSelected(difficultyID)
				return GetDungeonDifficultyID() == difficultyID;
			end

			local function SetSelected(difficultyID)
				SetDungeonDifficultyID(difficultyID);
			end

			rootDescription:CreateRadio(PLAYER_DIFFICULTY1, IsSelected, SetSelected, 1);
			rootDescription:CreateRadio(PLAYER_DIFFICULTY2, IsSelected, SetSelected, 2);
			rootDescription:CreateRadio(PLAYER_DIFFICULTY6, IsSelected, SetSelected, 23);
		end);

		CompactRaidFrameManager_UpdateDifficultyDropdown();
	end

	CompactRaidFrameManager_UpdateLabel();
end

function CompactRaidFrameManager_OnEvent(self, event, ...)
	if ( event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" ) then
		CompactRaidFrameManager_UpdateContainerBounds();
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "UPDATE_ACTIVE_BATTLEFIELD" ) then
		CompactRaidFrameManager_UpdateShown();
		CompactRaidFrameManager_UpdateDisplayCounts();
		CompactRaidFrameManager_UpdateLabel();
	elseif ( event == "UNIT_FLAGS" or event == "PLAYER_FLAGS_CHANGED" ) then
		CompactRaidFrameManager_UpdateDisplayCounts();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		CompactRaidFrameManager_UpdateShown();
		CompactRaidFrameManager_UpdateDisplayCounts();
		CompactRaidFrameManager_UpdateOptionsFlowContainer();
		CompactRaidFrameManager_UpdateRaidIcons();
	elseif ( event == "PARTY_LEADER_CHANGED" ) then
		CompactRaidFrameManager_UpdateOptionsFlowContainer();
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		CompactRaidFrameManager_UpdateRaidIcons();
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		CompactRaidFrameManager_UpdateRaidIcons();
	elseif ( event == "PLAYER_DIFFICULTY_CHANGED") then
		CompactRaidFrameManager_UpdateDifficulty();
	elseif ( event == "PLAYER_ROLES_ASSIGNED") then
		self.displayFrame.ModeControlDropdown:GenerateMenu();
		self.displayFrame.RestrictPingsDropdown:GenerateMenu();
	end
end

function CompactRaidFrameManager_UpdateShown()
	local compactRaidFrameManagerDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.CompactRaidFrameManagerDisabled);
	if compactRaidFrameManagerDisabled then
		CompactRaidFrameManager:Hide();
		return;
	end

	local showManager = IsInGroup() or EditModeManagerFrame:AreRaidFramesForcedShown() or EditModeManagerFrame:ArePartyFramesForcedShown();
	CompactRaidFrameManager:SetShown(showManager);

	CompactRaidFrameManager_UpdateOptionsFlowContainer();
	CompactRaidFrameManager_UpdateContainerVisibility();
end

function CompactRaidFrameManager_UpdateLabel()
	if ( IsInRaid() ) then
		CompactRaidFrameManager.displayFrame.label:SetText(RAID);
	else
		CompactRaidFrameManager.displayFrame.label:SetText(PARTY);
	end
end

function CompactRaidFrameManager_Toggle()
	if ( CompactRaidFrameManager.collapsed ) then
		CompactRaidFrameManager_Expand();
	else
		CompactRaidFrameManager_Collapse();
	end
end

function CompactRaidFrameManager_Expand()
	CompactRaidFrameManager.collapsed = false;
	CompactRaidFrameManager:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -7, -140);
	CompactRaidFrameManager.displayFrame:Show();
	CompactRaidFrameManager.toggleButton:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1);
end

function CompactRaidFrameManager_Collapse()
	CompactRaidFrameManager.collapsed = true;
	CompactRaidFrameManager:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -200, -140);
	CompactRaidFrameManager.displayFrame:Hide();
	CompactRaidFrameManager.toggleButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 1);
end

function CompactRaidFrameManager_UpdateDifficultyDropdown()
	local dropdown = CompactRaidFrameManager.displayFrame.difficulty;
	local enabled = not DifficultyUtil.InStoryRaid();
	dropdown:SetEnabled(enabled);
	dropdown:SetAlpha(enabled and 1.0 or .3);
	if enabled then
		dropdown.disabledTooltipText = nil;
	else
		dropdown.disabledTooltipText = DIFFICULTY_LOCKED_REASON_STORY_RAID;
	end
end

function CompactRaidFrameManager_UpdateOptionsFlowContainer()
	local displayFrame = CompactRaidFrameManager.displayFrame;
	local container = displayFrame.optionsFlowContainer;

	local isLeader = UnitIsGroupLeader("player");
	local isAssist = UnitIsGroupAssistant("player");
	local isLeaderOrAssist = isLeader or isAssist;
	local isRaid = IsInRaid();

	--set background
	for _, bg in ipairs(CompactRaidFrameManager.backgrounds) do
		bg:Hide();
	end
	if isRaid then
		if isLeader then
			CompactRaidFrameManager.BGLeads:Show();
		elseif isAssist then
			CompactRaidFrameManager.BGAssists:Show();
		else
			CompactRaidFrameManager.BGRegulars:Show();
		end
	else
		if isLeader then
			CompactRaidFrameManager.BGPartyLeads:Show();
		else
			CompactRaidFrameManager.BGPartyRegulars:Show();
		end
	end

	CompactRaidFrameContainer.dividerVerticalPool:ReleaseAll();
	CompactRaidFrameContainer.dividerHorizontalPool:ReleaseAll();

	FlowContainer_RemoveAllObjects(container);
	FlowContainer_PauseUpdates(container);
	displayFrame.editMode:ClearAllPoints();

	if isLeader then
		displayFrame.ModeControlDropdown:Show();
	else
		displayFrame.ModeControlDropdown:Hide();
	end

	CompactRaidFrameManager_UpdateDifficultyDropdown();

	if isRaid then
		FlowContainer_AddObject(container, displayFrame.filterOptions);
		displayFrame.filterOptions:Show();
	else
		displayFrame.filterOptions:Hide();
	end

	local function AddAndShow(frame)
		FlowContainer_AddObject(container, frame);
		frame:Show();
	end

	local function Space(pix)
		FlowContainer_AddSpacer(container, pix);
	end

	local verticalDividerPadding = 0;
	local function AddVerticalDivider()
		local frame = CompactRaidFrameContainer.dividerVerticalPool:Acquire();
			
		Space(verticalDividerPadding);
		AddAndShow(frame);
		Space(verticalDividerPadding);
	end

	local function AddHorizontalDivider()
		local frame = CompactRaidFrameContainer.dividerHorizontalPool:Acquire();
		FlowContainer_AddLineBreak(container);
		AddAndShow(frame);
	end

	if isRaid then
		FlowContainer_AddLineBreak(container);
		verticalDividerPadding = 4;
		Space(18);
		AddAndShow(displayFrame.difficulty);
		AddVerticalDivider();
		AddAndShow(displayFrame.editMode);
		AddVerticalDivider();
		AddAndShow(displayFrame.settings);
		AddVerticalDivider();
		AddAndShow(displayFrame.hiddenModeToggle);
		AddHorizontalDivider();
	elseif isLeader then
		FlowContainer_AddLineBreak(container);
		verticalDividerPadding = 0;
		Space(12);
		AddAndShow(displayFrame.difficulty);
		AddVerticalDivider();
		AddAndShow(displayFrame.readyCheckButton);
		AddVerticalDivider();
		AddAndShow(displayFrame.rolePollButton);
		AddVerticalDivider();
		AddAndShow(displayFrame.countdownButton);
		AddVerticalDivider();
		AddAndShow(displayFrame.editMode);
		AddHorizontalDivider();

		displayFrame.hiddenModeToggle:Hide();
		displayFrame.settings:Hide();
	else
		--editMode will be added below

		displayFrame.difficulty:Hide();
		displayFrame.readyCheckButton:Hide();
		displayFrame.rolePollButton:Hide();
		displayFrame.countdownButton:Hide();
		displayFrame.hiddenModeToggle:Hide();
		displayFrame.settings:Hide();
	end

	FlowContainer_AddLineBreak(container);
	Space(18);

	if isRaid and isLeaderOrAssist then
		AddAndShow(displayFrame.everyoneIsAssistButton);
		displayFrame.everyoneIsAssistButton:SetEnabled(isLeader);
	else
		displayFrame.everyoneIsAssistButton:Hide();
	end

	if isRaid and isLeaderOrAssist then
		verticalDividerPadding = 4;
		AddVerticalDivider();
		AddAndShow(displayFrame.readyCheckButton);
		AddVerticalDivider();
		AddAndShow(displayFrame.rolePollButton);
		AddVerticalDivider();
		AddAndShow(displayFrame.countdownButton);
		AddHorizontalDivider();
	elseif isRaid then
		displayFrame.readyCheckButton:Hide();
		displayFrame.rolePollButton:Hide();
		displayFrame.countdownButton:Hide()
	end

	if not isRaid or isLeaderOrAssist then
		FlowContainer_AddLineBreak(container);
		Space(20);
		AddAndShow(displayFrame.raidMarkers);

		if not isRaid and not isLeader then
			local edit = displayFrame.editMode;
			edit:SetPoint("LEFT", displayFrame.raidMarkers.raidMarkerGroundTab, "RIGHT", 50, 10);
			edit:Show();
		end
	else
		displayFrame.raidMarkers:Hide();
	end

	if isLeader then
		FlowContainer_AddLineBreak(container);
		Space(30);
		AddAndShow(displayFrame.RestrictPingsLabel);

		FlowContainer_AddLineBreak(container);
		Space(32);
		AddAndShow(displayFrame.RestrictPingsDropdown);
	else
		displayFrame.RestrictPingsLabel:Hide();
		displayFrame.RestrictPingsDropdown:Hide();
	end

	AddAndShow(displayFrame.BottomButtons);

	FlowContainer_ResumeUpdates(container);

	local usedX, usedY = FlowContainer_GetUsedBounds(container);
	CompactRaidFrameManager:SetHeight(usedY + 40);

	--Then, we update which specific buttons are enabled.

	--Raid leaders and assistants and leaders of non-dungeon finder parties may initiate a role poll.
	if ( IsInGroup() and not HasLFGRestrictions() and not UnitInBattleground("player") and isLeaderOrAssist ) then
		displayFrame.rolePollButton:Enable();
		displayFrame.rolePollButton:SetAlpha(1);
	else
		displayFrame.rolePollButton:Disable();
		displayFrame.rolePollButton:SetAlpha(0.5);
	end

	--Any sort of leader may initiate a ready check.
	if ( IsInGroup() and isLeaderOrAssist ) then
		displayFrame.readyCheckButton:Enable();
		displayFrame.readyCheckButton:SetAlpha(1);
		displayFrame.countdownButton:Enable();
		displayFrame.countdownButton:SetAlpha(1);
	else
		displayFrame.readyCheckButton:Disable();
		displayFrame.readyCheckButton:SetAlpha(0.5);
		displayFrame.countdownButton:Disable();
		displayFrame.countdownButton:SetAlpha(0.5);
	end
end

function CompactRaidFrameManager_UpdateDisplayCounts()
	CRF_CountStuff();
	CompactRaidFrameManager_UpdateHeaderInfo();
	CompactRaidFrameManager_UpdateFilterInfo()
end

function CompactRaidFrameManager_UpdateHeaderInfo()
	CompactRaidFrameManager.displayFrame.memberCountLabel:SetFormattedText("%d/%d", RaidInfoCounts.totalAlive, RaidInfoCounts.totalCount);
end

local usedGroups = {};
function CompactRaidFrameManager_UpdateFilterInfo()
	CompactRaidFrameManager_UpdateRoleFilterButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleTank);
	CompactRaidFrameManager_UpdateRoleFilterButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleHealer);
	CompactRaidFrameManager_UpdateRoleFilterButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleDamager);

	RaidUtil_GetUsedGroups(usedGroups);
	for i=1, MAX_RAID_GROUPS do
		CompactRaidFrameManager_UpdateGroupFilterButton(CompactRaidFrameManager.displayFrame.filterOptions["filterGroup"..i], usedGroups);
	end
end

function CompactRaidFrameManager_UpdateRoleFilterButton(button)
	local totalAlive, totalCount = RaidInfoCounts["aliveRole"..button.role], RaidInfoCounts["totalRole"..button.role]
	button:SetFormattedText("%s %d/%d", button.roleTexture, totalAlive, totalCount);
	local showSeparateGroups = EditModeManagerFrame:ShouldRaidFrameShowSeparateGroups();

	local function SetChecked(checked)
		button.checked = checked;
		button:GetNormalTexture():SetAtlas(checked and "common-button-tertiary-selected-small" or (button.hovered and "common-button-tertiary-hover-small" or "common-button-tertiary-normal-small"), TextureKitConstants.IgnoreAtlasSize);
	end

	if ( totalCount == 0 or showSeparateGroups ) then
		SetChecked(false);
		button:Disable();
		button:SetAlpha(0.5);
	else
		button:Enable();
		button:SetAlpha(1);
		local isFiltered = CRF_GetFilterRole(button.role)
		SetChecked(isFiltered);
	end
end

function CompactRaidFrameManager_ToggleRoleFilter(role)
	CRF_SetFilterRole(role, not CRF_GetFilterRole(role));
	CompactRaidFrameManager_UpdateFilterInfo();
	CompactRaidFrameContainer:TryUpdate();
end

function CompactRaidFrameManager_UpdateGroupFilterButton(button, usedGroups)
	local group = button:GetID();

	local function SetChecked(checked)
		button.checked = checked;
		button:GetNormalTexture():SetAtlas(checked and "common-button-tertiary-selected" or (button.hovered and "common-button-tertiary-hover" or "common-button-tertiary-normal"), false);
	end

	if ( usedGroups[group] ) then
		button:Enable();
		button:SetAlpha(1);
		local isFiltered = CRF_GetFilterGroup(group);
		SetChecked(isFiltered);
	else
		SetChecked(false);
		button:Disable();
		button:SetAlpha(0.5);
	end
end

function CompactRaidFrameManager_ToggleGroupFilter(group)
	CRF_SetFilterGroup(group, not CRF_GetFilterGroup(group));
	CompactRaidFrameManager_UpdateFilterInfo();
	CompactRaidFrameContainer:TryUpdate();
end

function CompactRaidFrameManager_UpdateRaidIcons()
	
	local raidMarkers = CompactRaidFrameManager.displayFrame.raidMarkers;

	if raidMarkers.activeTab == raidMarkers.raidMarkerUnitTab then 
		for i=1, NUM_RAID_ICONS do
			local button = raidMarkers["raidMarker"..i];
			button:UpdateRaidIcon();
		end

		local removeButton = raidMarkers.raidMarkerRemove;
		removeButton.markerTexture:SetAtlas("GM-raidMarker-remove", TextureKitConstants.IgnoreAtlasSize);
		removeButton:SetID(0);
		if not GetRaidTargetIndex("target") then
			removeButton.markerTexture:SetDesaturated(true);
			removeButton:Disable();
		else
			removeButton.markerTexture:SetDesaturated(false);
			removeButton:Enable();
		end
	else --world markers
		for i=1, NUM_RAID_ICONS do
			local button = raidMarkers["raidMarker"..i];
			button:UpdateRaidIcon();
		end

		local removeButton = raidMarkers.raidMarkerRemove;
		removeButton.markerTexture:SetAtlas("GM-raidMarker-reset", TextureKitConstants.IgnoreAtlasSize);
		removeButton:SetID(RAID_MARKER_RESET_ID);
		removeButton.markerTexture:SetDesaturated(false);
		removeButton:Enable();
	end
end

function CompactRaidFrameManager_UpdateDifficulty()
	local difficulty = GetDungeonDifficultyID();
	local dropdown = CompactRaidFrameManager.displayFrame.difficulty;
	local isAssist = UnitIsGroupAssistant("player");
	local atlas = nil; 
	local inStoryRaid = DifficultyUtil.InStoryRaid();
	if (difficulty == DifficultyUtil.ID.DungeonNormal) or inStoryRaid then
		atlas = isAssist and "GM-icon-difficulty-normalAssist" or "GM-icon-difficulty-normal";
	elseif difficulty == DifficultyUtil.ID.DungeonHeroic then
		atlas = isAssist and "GM-icon-difficulty-heroicAssist" or "GM-icon-difficulty-heroic";
	else
		atlas = isAssist and "GM-icon-difficulty-mythicAssist" or "GM-icon-difficulty-mythic";
	end

	dropdown:GetNormalTexture():SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
end

function CompactRaidFrameManager_MouseDownDifficulty(self)
	if UnitIsGroupLeader("player") then
		local dropdown = CompactRaidFrameManager.displayFrame.difficulty;
		local shown = dropdown:IsMenuOpen();
		local difficulty = GetDungeonDifficultyID();
		local atlas = nil;
		local inStoryRaid = DifficultyUtil.InStoryRaid();
		if (difficulty == DifficultyUtil.ID.DungeonNormal) or inStoryRaid then
			atlas = shown and "GM-icon-difficulty-normalSelected" or "GM-icon-difficulty-normal";
		elseif difficulty == DifficultyUtil.ID.DungeonHeroic then
			atlas = shown and "GM-icon-difficulty-heroicSelected" or "GM-icon-difficulty-heroic";
		else
			atlas = shown and "GM-icon-difficulty-mythicSelected" or "GM-icon-difficulty-mythic";
		end

		self:GetNormalTexture():SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
	end
end

--Settings stuff
local cachedSettings = {};
local isSettingCached = {};
function CompactRaidFrameManager_GetSetting(settingName)
	if ( not isSettingCached[settingName] ) then
		cachedSettings[settingName] = CompactRaidFrameManager_GetSettingBeforeLoad(settingName);
		isSettingCached[settingName] = true;
	end
	return cachedSettings[settingName];
end

function CompactRaidFrameManager_GetSettingBeforeLoad(settingName)
	if ( settingName == "Managed" ) then
		return true;
	elseif ( settingName == "Locked" ) then
		return true;
	elseif ( settingName == "DisplayPets" ) then
		return false;
	elseif ( settingName == "PvpDisplayPets" ) then
		return false;
	elseif ( settingName == "DisplayMainTankAndAssist" ) then
		return true;
	elseif ( settingName == "IsShown" ) then
		return true;
	else
		GMError("Unknown setting "..tostring(settingName));
	end
end

do	--Enclosure to make sure people go through SetSetting
	local function CompactRaidFrameManager_SetManaged(value)
		local container = CompactRaidFrameManager.container;
	end

	local function CompactRaidFrameManager_SetDisplayPets(value)
		local container = CompactRaidFrameManager.container;
		local displayPets;
		if ( value and value ~= "0" ) then
			displayPets = true;
		end

		container:SetDisplayPets(displayPets);
	end

	local function CompactRaidFrameManager_SetPvpDisplayPets(value)
		local container = CompactRaidFrameManager.container;
		local displayPets;
		if ( value and value ~= "0" ) then
			displayPets = true;
		end

		container:SetPvpDisplayPets(displayPets);
	end

	local function CompactRaidFrameManager_SetDisplayMainTankAndAssist(value)
		local container = CompactRaidFrameManager.container;
		local displayFlaggedMembers;
		if value and value ~= "0" then
			displayFlaggedMembers = true;
		end

		container:SetDisplayMainTankAndAssist(displayFlaggedMembers);
	end

	local function CompactRaidFrameManager_SetIsShown(value)
		if EditModeManagerFrame:AreRaidFramesForcedShown() or (value and value ~= "0") then
			CompactRaidFrameManager.container.enabled = true;
			CompactRaidFrameManagerDisplayFrameHiddenModeToggle.shownMode = false;
		else
			CompactRaidFrameManager.container.enabled = false;
			CompactRaidFrameManagerDisplayFrameHiddenModeToggle.shownMode = true;
		end
		CompactRaidFrameManager_UpdateContainerVisibility();
	end

	function CompactRaidFrameManager_SetSetting(settingName, value)
		cachedSettings[settingName] = value;
		isSettingCached[settingName] = true;

		--Perform the actual functions
		if ( settingName == "Managed" ) then
			CompactRaidFrameManager_SetManaged(value);
		elseif ( settingName == "DisplayPets" ) then
			CompactRaidFrameManager_SetDisplayPets(value);
		elseif ( settingName == "pvpDisplayPets" ) then
			CompactRaidFrameManager_SetPvpDisplayPets(value);
		elseif ( settingName == "DisplayMainTankAndAssist" ) then
			CompactRaidFrameManager_SetDisplayMainTankAndAssist(value);
		elseif ( settingName == "IsShown" ) then
			CompactRaidFrameManager_SetIsShown(value);
		else
			GMError("Unknown setting "..tostring(settingName));
		end
	end
end

function CompactRaidFrameManager_UpdateContainerVisibility()
	if ShouldShowRaidFrames() and CompactRaidFrameManager.container.enabled then
		CompactRaidFrameManager.container:Show();
	else
		CompactRaidFrameManager.container:Hide();
	end

	CompactPartyFrame:UpdateVisibility();

	-- TODO:: WoWLabs temp compatibility changes
	if CompactArenaFrame then
		CompactArenaFrame:UpdateVisibility();
	end
end

function CompactRaidFrameManager_UpdateContainerBounds()
	CompactRaidFrameManager.container:Layout();
end

-------------Utility functions-------------
--Functions used for filtering
local filterOptions = {
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
function CRF_SetFilterRole(role, show)
	filterOptions["displayRole"..role] = show;
end

function CRF_GetFilterRole(role)
	return filterOptions["displayRole"..role];
end

function CRF_SetFilterGroup(group, show)
	assert(type(group) == "number");
	filterOptions[group] = show;
end

function CRF_GetFilterGroup(group)
	assert(type(group) == "number");
	return filterOptions[group];
end

function CRFFlowFilterFunc(token)
	if ( not UnitExists(token) ) then
		return false;
	end

	if ( not IsInRaid() ) then	--We don't filter unless we're in a raid.
		return true;
	end

	local role = UnitGroupRolesAssigned(token);
	if ( not filterOptions["displayRole"..role] ) then
		return false;
	end

	local raidID = UnitInRaid(token);
	if ( raidID ) then
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, raidRole, isML = GetRaidRosterInfo(raidID);
		if ( not filterOptions[subgroup] ) then
			return false;
		end

		local showingMTandMA = CompactRaidFrameManager_GetSetting("DisplayMainTankAndAssist");
		if ( raidRole and (showingMTandMA and showingMTandMA ~= "0") ) then	--If this character is already displayed as a Main Tank/Main Assist, we don't want to show them a second time
			return false;
		end
	end

	return true;
end

function CRFGroupFilterFunc(groupNum)
	return filterOptions[groupNum];
end

--Counting functions
RaidInfoCounts = {
	aliveRoleTANK 			= 0,
	totalRoleTANK			= 0,
	aliveRoleHEALER		= 0,
	totalRoleHEALER		= 0,
	aliveRoleDAMAGER	= 0,
	totalRoleDAMAGER		= 0,
	aliveRoleNONE			= 0,
	totalRoleNONE			= 0,
	totalCount					= 0,
	totalAlive					= 0,
}

local function CRF_ResetCountedStuff()
	for key, val in pairs(RaidInfoCounts) do
		RaidInfoCounts[key] = 0;
	end
end

function CRF_CountStuff()
	CRF_ResetCountedStuff();
	if ( IsInRaid() ) then
		for i=1, GetNumGroupMembers() do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, assignedRole = GetRaidRosterInfo(i);	--Weird that we have 2 role return values, but... oh well
			if ( rank ) then
				CRF_AddToCount(isDead, assignedRole);
			end
		end
	else
		CRF_AddToCount(UnitIsDeadOrGhost("player") , UnitGroupRolesAssigned("player"));
		for i=1, GetNumSubgroupMembers() do
			local unit = "party"..i;
			CRF_AddToCount(UnitIsDeadOrGhost(unit), UnitGroupRolesAssigned(unit));
		end
	end
end

function CRF_AddToCount(isDead, assignedRole)
	RaidInfoCounts.totalCount = RaidInfoCounts.totalCount + 1;
	RaidInfoCounts["totalRole"..assignedRole] = RaidInfoCounts["totalRole"..assignedRole] + 1;
	if ( not isDead ) then
		RaidInfoCounts.totalAlive = RaidInfoCounts.totalAlive + 1;
		RaidInfoCounts["aliveRole"..assignedRole] = RaidInfoCounts["aliveRole"..assignedRole] + 1;
	end
end

local function FilterButtonOnEnter(self, atlas)
	self.hovered = true;
	if not self.checked then
		self:GetNormalTexture():SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
	end
end

local function FilterButtonOnLeave(self)
	self.hovered = false;
	CompactRaidFrameManager_UpdateFilterInfo();
end

CRFManagerFilterRoleButtonMixin = {};

function CRFManagerFilterRoleButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	CompactRaidFrameManager_ToggleRoleFilter(self.role);
end

function CRFManagerFilterRoleButtonMixin:OnEnter()
	FilterButtonOnEnter(self, "common-button-tertiary-hover-small");
end

function CRFManagerFilterRoleButtonMixin:OnLeave()
	FilterButtonOnLeave(self);
end

CRFManagerFilterGroupButtonMixin = {};
 
function CRFManagerFilterGroupButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	CompactRaidFrameManager_ToggleGroupFilter(self:GetID());
end

function CRFManagerFilterGroupButtonMixin:OnEnter()
	FilterButtonOnEnter(self, "common-button-tertiary-hover");
end

function CRFManagerFilterGroupButtonMixin:OnLeave()
	FilterButtonOnLeave(self);
end

CRFManagerRoleMarkerCheckMixin = {};

function CRFManagerRoleMarkerCheckMixin:OnLoad()
	self.icon.icon:SetAtlas(self.id == 0 and "GM-icon-role-tank" or "GM-icon-role-healer", 16, 16, 0, 0);
end	

CRFManagerRaidIconButtonMixin = {};

function CRFManagerRaidIconButtonMixin:GetMarker()
	return ReverseMarkerID(self:GetID());
end

function CRFManagerRaidIconButtonMixin:OnShow()
	self.markerTexture:SetAtlas("GM-raidMarker"..self:GetMarker(), TextureKitConstants.IgnoreAtlasSize);
end

function CRFManagerRaidIconButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local raidMarkers = CompactRaidFrameManager.displayFrame.raidMarkers;
	if self:GetID() == RAID_MARKER_RESET_ID then
		ClearRaidMarker();
	elseif raidMarkers.activeTab == raidMarkers.raidMarkerUnitTab then
		SetRaidTarget("target", self:GetID());
	else
		local marker = WORLD_RAID_MARKER_ORDER[self:GetMarker()];
		ClearRaidMarker(marker);
		PlaceRaidMarker(marker);
	end
	CompactRaidFrameManager_UpdateRaidIcons();
end

function CRFManagerRaidIconButtonMixin:UpdateRaidIcon()
	local raidMarkers = CompactRaidFrameManager.displayFrame.raidMarkers;

	if self == raidMarkers.raidMarkerRemove then
		return; --handled as a special case in CompactRaidFrameManager_UpdateRaidIcons
	end

	if raidMarkers.activeTab == raidMarkers.raidMarkerUnitTab then 
		local unit = "target";
		local disableAll = not CanBeRaidTarget(unit);
		if disableAll then
			self.markerTexture:SetDesaturated(true);
			self.backgroundTexture:SetAtlas("GM-button-marker-disabled", TextureKitConstants.IgnoreAtlasSize);
			self:Disable();
		else
			local applied = false;--IsRaidMarkerActive is for WORLD MARKERS. Leaving this here in case we decide to write an API for unit markers.
			local selected = (self:GetID() == GetRaidTargetIndex(unit));

			self.markerTexture:SetDesaturated(false);
			self:Enable();
			if applied and selected then
				self.backgroundTexture:SetAtlas("GM-button-marker-appliedSelected", TextureKitConstants.IgnoreAtlasSize);
			elseif applied then
				self.backgroundTexture:SetAtlas("GM-button-marker-applied", TextureKitConstants.IgnoreAtlasSize);
			elseif selected then
				self.backgroundTexture:SetAtlas("GM-button-marker-selected", TextureKitConstants.IgnoreAtlasSize);
			else
				self.backgroundTexture:SetAtlas("GM-button-marker-available", TextureKitConstants.IgnoreAtlasSize);
			end
		end
	else
		self.markerTexture:SetDesaturated(false);
		self:Enable();
		if self:GetID() ~= RAID_MARKER_RESET_ID then
			local applied = IsRaidMarkerActive(WORLD_RAID_MARKER_ORDER[self:GetMarker()]); 
			if applied then
				self.backgroundTexture:SetAtlas("GM-button-marker-applied", TextureKitConstants.IgnoreAtlasSize);
			else
				self.backgroundTexture:SetAtlas("GM-button-marker-available", TextureKitConstants.IgnoreAtlasSize);
			end
		end
	end
end

function CRFManagerRaidIconButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.markerTexture:SetPoint("CENTER", self, "CENTER", -1, -1);
		self.backgroundTexture:SetAtlas("GM-button-marker-pressed", TextureKitConstants.IgnoreAtlasSize);
	end
end

function CRFManagerRaidIconButtonMixin:OnMouseUp()
	self.markerTexture:SetPoint("CENTER", self, "CENTER", 0, 1);
	self.backgroundTexture:SetAtlas("GM-button-marker-available", TextureKitConstants.IgnoreAtlasSize);

	self:UpdateRaidIcon();
end

function CRFManagerRaidIconButtonMixin:OnEnter()
	if self.backgroundTexture:GetAtlas() == "GM-button-marker-available" then
		self.backgroundTexture:SetAtlas("GM-button-marker-hover", TextureKitConstants.IgnoreAtlasSize);
	end
end

function CRFManagerRaidIconButtonMixin:OnLeave()
	if self.backgroundTexture:GetAtlas() == "GM-button-marker-hover" then
		self.backgroundTexture:SetAtlas("GM-button-marker-available", TextureKitConstants.IgnoreAtlasSize);
	end
end

CRFManagerMarkerTabMixin = {};

function CRFManagerMarkerTabMixin:OnClick()
	self:GetParent():SetTab(self);
	CompactRaidFrameManager_UpdateRaidIcons();
end

CRFRaidMarkersMixin = {};

function CRFRaidMarkersMixin:SetTab(frame)
	if self.activeTab ~= frame then
		self.activeTab = frame;
		for _, tab in ipairs(self.Tabs) do
			tab:GetNormalTexture():SetAtlas(tab == frame and "GM-tab-active" or "GM-tab-inActive", TextureKitConstants.IgnoreAtlasSize);
			tab:SetNormalFontObject(tab == frame and GameFontHighlightSmall or GameFontNormalSmall);
		end
	end
end

function CRFRaidMarkersMixin:OnLoad()
	self:SetTab(self.Tabs[1]);
end

RaidFrameFilterRoleTankMixin = CreateFromMixins(CRFManagerFilterRoleButtonMixin);

function RaidFrameFilterRoleTankMixin:OnLoad()
	self.role = "TANK";
	self.roleTexture = CreateAtlasMarkup("GM-icon-role-tank", 16, 16, 0, 0);
end

RaidFrameFilterRoleHealerMixin = CreateFromMixins(CRFManagerFilterRoleButtonMixin);

function RaidFrameFilterRoleHealerMixin:OnLoad()
	self.role = "HEALER";
	self.roleTexture = CreateAtlasMarkup("GM-icon-role-healer", 16, 16, 0, 0);
end

RaidFrameFilterRoleDamagerMixin = CreateFromMixins(CRFManagerFilterRoleButtonMixin);

function RaidFrameFilterRoleDamagerMixin:OnLoad()
	self.role = "DAMAGER";
	self.roleTexture = CreateAtlasMarkup("GM-icon-role-dps", 16, 16, 0, 0);
end

CRFManagerTooltipButtonMixin = {}

function CRFManagerTooltipButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -10, -10);
	
	if self.disabledTooltipText then
		local tooltipText = RED_FONT_COLOR:WrapTextInColorCode(self.disabledTooltipText);
		GameTooltip_SetTitle(GameTooltip, tooltipText);
	else
		GameTooltip_SetTitle(GameTooltip, _G[self.tooltip]);
	end

	GameTooltip:Show();
end

function CRFManagerTooltipButtonMixin:OnLeave()
	GameTooltip:Hide();
end

RaidFrameEditModeMixin = CreateFromMixins(CRFManagerTooltipButtonMixin);

function RaidFrameEditModeMixin:OnShow()
	self:SetEnabled(EditModeManagerFrame:CanEnterEditMode());
end

function RaidFrameEditModeMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	ShowUIPanel(EditModeManagerFrame);
end

RaidFrameSettingsMixin = CreateFromMixins(CRFManagerTooltipButtonMixin);

function RaidFrameSettingsMixin:OnClick()
	Settings.OpenToCategory(Settings.INTERFACE_CATEGORY_ID, RAID_FRAMES_LABEL);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
end

RaidFrameHiddenModeToggleMixin = CreateFromMixins(CRFManagerTooltipButtonMixin);

function RaidFrameHiddenModeToggleMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	SetCVar("raidOptionIsShown", not GetCVarBool("raidOptionIsShown"));
end

RaidFrameEveryoneIsAssistMixin = {};

function RaidFrameEveryoneIsAssistMixin:OnLoad()
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:SetChecked(IsEveryoneAssistant());
end

function RaidFrameEveryoneIsAssistMixin:OnEvent()
	self:SetChecked(IsEveryoneAssistant());
	if ( UnitIsGroupLeader("player") ) then
		self:Enable();
	else
		self:Disable();
	end
end

function RaidFrameEveryoneIsAssistMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	SetEveryoneIsAssistant(self:GetChecked());
end

function RaidFrameEveryoneIsAssistMixin:OnEnter() --OnLeave in XML
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -10, -10);
	if ( not self:IsEnabled() ) then
		GameTooltip:AddLine(ALL_ASSIST_NOT_LEADER_ERROR, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	else
		GameTooltip_SetTitle(GameTooltip, CRF_ALL_ASSIST);
	end
	GameTooltip:Show();
end

RaidFrameReadyCheckMixin = CreateFromMixins(CRFManagerTooltipButtonMixin);

function RaidFrameReadyCheckMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	DoReadyCheck();
end

RaidFrameRolePollMixin = CreateFromMixins(CRFManagerTooltipButtonMixin);

function RaidFrameRolePollMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	InitiateRolePoll();
end

RaidFrameCountdownMixin = CreateFromMixins(CRFManagerTooltipButtonMixin);

function RaidFrameCountdownMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	C_PartyInfo.DoCountdown(10);
end

RaidFrameManagerRestrictPingsButtonMixin = {};

local RestrictPingsButtonShownEvents =
{
	"GROUP_ROSTER_UPDATE",
	"PARTY_LEADER_CHANGED",
};

function RaidFrameManagerRestrictPingsButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RestrictPingsButtonShownEvents);

	self:UpdateCheckedState();
end

function RaidFrameManagerRestrictPingsButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RestrictPingsButtonShownEvents);
end

function RaidFrameManagerRestrictPingsButtonMixin:OnEvent()
	self:UpdateCheckedState();
end

function RaidFrameManagerRestrictPingsButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	C_PartyInfo.SetRestrictPings(self:GetChecked());
end

function RaidFrameManagerRestrictPingsButtonMixin:UpdateLabel()
	if IsInRaid() then
		self.Text:SetText(RAID_MANAGER_RESTRICT_PINGS);
	else
		self.Text:SetText(RAID_MANAGER_RESTRICT_PINGS_PARTY);
	end
end

function RaidFrameManagerRestrictPingsButtonMixin:UpdateCheckedState()
	self:SetChecked(C_PartyInfo.GetRestrictPings());
end

function RaidFrameManagerRestrictPingsButtonMixin:ShouldShow()
	return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player");
end

LeavePartyButtonMixin = {};

function LeavePartyButtonMixin:OnClick()
	if C_PartyInfo.IsPartyWalkIn() then
		LeaveWalkInParty();
	else
		C_PartyInfo.LeaveParty();
	end
end

LeaveInstanceGroupButtonMixin = {};

function LeaveInstanceGroupButtonMixin:OnShow()
	if C_PartyInfo.IsPartyWalkIn() then
		self:SetText(INSTANCE_WALK_IN_LEAVE);
	else
		self:SetText(INSTANCE_PARTY_LEAVE);
	end
end

function LeaveInstanceGroupButtonMixin:OnClick()
	ConfirmOrLeaveParty();
end