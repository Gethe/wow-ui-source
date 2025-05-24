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

RAID_MARKER_REMOVE_ID = 0;
RAID_MARKER_RESET_ID = -1;

NUM_RAID_MARKERS = 8;
MAX_NUM_GROUPS = 8;

CRFM_ButtonStateBehaviorMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function CRFM_ButtonStateBehaviorMixin:OnButtonStateChanged()
	local atlas = self.atlasKey;
	if self:IsDownOver() or self:IsOver() then
		atlas = atlas.."-hover";
	elseif self:IsDown() then
		atlas = atlas.."-pressed";
	end
	
	self:GetNormalTexture():SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
end

CRFM_TooltipMixin = {}

function CRFM_TooltipMixin:OnEnter()
	local tooltipText = nil;
	if not self:IsEnabled() and self.disabledTooltipText then
		tooltipText = RED_FONT_COLOR:WrapTextInColorCode(self.disabledTooltipText);
	else
		tooltipText = self.tooltip;
	end

	if tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -10, -10);
		GameTooltip_SetTitle(GameTooltip, tooltipText);
		GameTooltip:Show();
	end
end

function CRFM_TooltipMixin:OnLeave()
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

CRFM_ToolbarButtonMixin = CreateFromMixins(CRFM_TooltipMixin, CRFM_ButtonStateBehaviorMixin);

function CRFM_ToolbarButtonMixin:OnEnter()
	CRFM_ButtonStateBehaviorMixin.OnEnter(self);
	CRFM_TooltipMixin.OnEnter(self);
end

function CRFM_ToolbarButtonMixin:OnLeave()
	CRFM_ButtonStateBehaviorMixin.OnLeave(self);
	CRFM_TooltipMixin.OnLeave(self);
end

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

		local function AcquireRaidMarker()
			local button = self.raidMarkerPool:Acquire();
			button:SetParent(parent);
			button:Show();
			tinsert(buttons, button);
			return button;
		end

		local function MakeRow(from, to, finalButton)
			for i = from, to do
				local button = AcquireRaidMarker();
				button:SetID(ReverseMarkerID(i));
				button:SetParentKey("raidMarker"..i);
			end
		end

		local HalfNumMarkers = NUM_RAID_MARKERS / 2;
		MakeRow(1, HalfNumMarkers);
		
		local raidMarkerRemove = AcquireRaidMarker();
		raidMarkerRemove.markerTexture:SetAtlas("GM-raidMarker-remove", TextureKitConstants.IgnoreAtlasSize);
		raidMarkerRemove:SetID(RAID_MARKER_REMOVE_ID);
		raidMarkerRemove:SetParentKey("raidMarkerRemove");

		MakeRow(HalfNumMarkers + 1, NUM_RAID_MARKERS);
		
		local raidMarkerReset = AcquireRaidMarker();
		raidMarkerReset.markerTexture:SetAtlas("GM-raidMarker-reset", TextureKitConstants.IgnoreAtlasSize);
		raidMarkerReset:SetID(RAID_MARKER_RESET_ID);
		raidMarkerReset:SetParentKey("raidMarkerReset");

		local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, NUM_RAID_MARKERS / 2 + 1, 2, 0);
		local anchor = CreateAnchor("TOPLEFT", parent.raidMarkerUnitTab, "BOTTOMLEFT", 3, -6);
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

			if IsInRaid() then
				local function IsSelected(difficultyID)
					return DifficultyUtil.DoesCurrentRaidDifficultyMatch(difficultyID);
				end

				local function SetSelected(difficultyID)
					SetRaidDifficulties(true, difficultyID);
				end

				local difficultyData = {
					{difficultyID = DifficultyUtil.ID.PrimaryRaidNormal, text = PLAYER_DIFFICULTY1},
					{difficultyID = DifficultyUtil.ID.PrimaryRaidHeroic, text = PLAYER_DIFFICULTY2},
					{difficultyID = DifficultyUtil.ID.PrimaryRaidMythic, text = PLAYER_DIFFICULTY6},
				};

				for index, data in ipairs(difficultyData) do
					local difficultyID = data.difficultyID;
					local radio = rootDescription:CreateRadio(data.text, IsSelected, SetSelected, difficultyID);
					radio:SetEnabled(DifficultyUtil.IsRaidDifficultyEnabled(difficultyID));
				end
			else
				local function IsSelected(difficultyID)
					return GetDungeonDifficultyID() == difficultyID;
				end

				local function SetSelected(difficultyID)
					SetDungeonDifficultyID(difficultyID);
				end

				local difficultyData = {
					{difficultyID = DifficultyUtil.ID.DungeonNormal, text = PLAYER_DIFFICULTY1},
					{difficultyID = DifficultyUtil.ID.DungeonHeroic, text = PLAYER_DIFFICULTY2},
					{difficultyID = DifficultyUtil.ID.DungeonMythic, text = PLAYER_DIFFICULTY6},
				};

				for index, data in ipairs(difficultyData) do
					local difficultyID = data.difficultyID;
					local radio = rootDescription:CreateRadio(data.text, IsSelected, SetSelected, difficultyID);
					radio:SetEnabled(DifficultyUtil.IsDungeonDifficultyEnabled(difficultyID));
				end
			end
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
		CompactRaidFrameManager.displayFrame.difficulty:OnButtonStateChanged();
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
	CompactRaidFrameManager.toggleButtonBack:Show();
	CompactRaidFrameManager.toggleButtonForward:Hide();
	CompactRaidFrameManager.BottomButtons:Show();
end

function CompactRaidFrameManager_Collapse()
	CompactRaidFrameManager.collapsed = true;
	CompactRaidFrameManager:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -200, -140);
	CompactRaidFrameManager.displayFrame:Hide();
	CompactRaidFrameManager.toggleButtonBack:Hide();
	CompactRaidFrameManager.toggleButtonForward:Show();
	CompactRaidFrameManager.BottomButtons:Hide();
end

RaidFrameToggleButtonMixin = {}

function RaidFrameToggleButtonMixin:OnLoad()
	self:GetNormalTexture():SetDrawLayer("OVERLAY");
	self:GetPushedTexture():SetDrawLayer("OVERLAY");
	self:GetDisabledTexture():SetDrawLayer("OVERLAY");
end

function RaidFrameToggleButtonMixin:OnClick()
	CompactRaidFrameManager_Toggle();
end

function RaidFrameToggleButtonMixin:OnEnter()
	self:GetNormalTexture():SetAtlas(self.hoverTex);
end

function RaidFrameToggleButtonMixin:OnLeave()
	self:GetNormalTexture():SetAtlas(self.normalTex);
end

function CompactRaidFrameManager_UpdateDifficultyDropdown()
	local dropdown = CompactRaidFrameManager.displayFrame.difficulty;
	local enabled = not DifficultyUtil.InStoryRaid();
	dropdown:SetEnabled(enabled);
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
	local currentBG;
	if isRaid then
		if isLeader then
			currentBG = CompactRaidFrameManager.BGLeads;
		elseif isAssist then
			currentBG = CompactRaidFrameManager.BGAssists;
		else
			currentBG = CompactRaidFrameManager.BGRegulars;
		end
	else
		if isLeader then
			currentBG = CompactRaidFrameManager.BGPartyLeads;
		else
			currentBG = CompactRaidFrameManager.BGPartyRegulars;
		end
	end
	currentBG:Show();

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

	CompactRaidFrameManager.toggleButtonBack:ClearAllPoints();
	CompactRaidFrameManager.toggleButtonForward:ClearAllPoints();

	local function SetToggleHeight(y)
		CompactRaidFrameManager.toggleButtonBack:SetPoint("RIGHT", -7, y);
		CompactRaidFrameManager.toggleButtonForward:SetPoint("RIGHT", -7, y)
	end

	if isRaid then
		if isLeader then
			SetToggleHeight(-35);
		elseif isAssist then
			SetToggleHeight(-55);
		else
			SetToggleHeight(-45);
		end
	elseif isLeader then
		SetToggleHeight(15);
	else
		SetToggleHeight(20);
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
			edit:SetPoint("LEFT", displayFrame.raidMarkers.raidMarkerGroundTab, "RIGHT", 40, 10);
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

	CompactRaidFrameManager.BottomButtons:ClearAllPoints();
	CompactRaidFrameManager.BottomButtons:SetPoint("BOTTOM", currentBG, "BOTTOM", 0, 25);

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

local function GetLocalPlayerSubgroup()
	if not ShouldShowRaidFrames() then
		return nil;
	end

	local localPlayerName = UnitName("player");
	for i=1, GetNumGroupMembers() do
		local name, rank, subgroup = GetRaidRosterInfo(i);
		if name == localPlayerName then
			return subgroup;
		end
	end
	return nil;
end

local usedGroups = {};
function CompactRaidFrameManager_UpdateFilterInfo()
	CompactRaidFrameManager_UpdateRoleFilterButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleTank);
	CompactRaidFrameManager_UpdateRoleFilterButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleHealer);
	CompactRaidFrameManager_UpdateRoleFilterButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleDamager);

	RaidUtil_GetUsedGroups(usedGroups);

	local localPlayerSubgroup = GetLocalPlayerSubgroup();

	for i=1, MAX_RAID_GROUPS do
		local showPlayerIndicator = i == localPlayerSubgroup;
		local button = CompactRaidFrameManager.displayFrame.filterOptions["filterGroup"..i];
		CompactRaidFrameManager_UpdateGroupFilterButton(button, usedGroups, showPlayerIndicator);
	end
end

function CompactRaidFrameManager_UpdateRoleFilterButton(button)
	local totalAlive, totalCount = RaidInfoCounts["aliveRole"..button.role], RaidInfoCounts["totalRole"..button.role]
	button:SetFormattedText("%s %d/%d", button.roleTexture, totalAlive, totalCount);
	local showSeparateGroups = EditModeManagerFrame:ShouldRaidFrameShowSeparateGroups();

	local function SetChecked(checked)
		button.checked = checked;

		local atlas = nil;
		if checked then
			atlas = "common-button-tertiary-selected-small";
		elseif button.hovered then
			atlas = "common-button-tertiary-hover-small";
		else
			atlas = "common-button-tertiary-normal-small";
		end
		button:GetNormalTexture():SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
	end

	if ( totalCount == 0 or showSeparateGroups ) then
		SetChecked(false);
		button:Disable();
	else
		button:Enable();
		local isFiltered = CRF_GetFilterRole(button.role)
		SetChecked(isFiltered);
	end
end

function CompactRaidFrameManager_ToggleRoleFilter(role)
	CRF_SetFilterRole(role, not CRF_GetFilterRole(role));
	CompactRaidFrameManager_UpdateFilterInfo();
	CompactRaidFrameContainer:TryUpdate();
end

function CompactRaidFrameManager_UpdateGroupFilterButton(button, usedGroups, showPlayerIndicator)
	local group = button:GetID();

	local function SetChecked(checked)
		button.checked = checked;
		local atlas = nil;
		if checked then
			atlas = "common-button-tertiary-selected";
		elseif button.hovered then
			atlas = "common-button-tertiary-hover";
		else
			atlas = "common-button-tertiary-normal";
		end

		button:GetNormalTexture():SetAtlas(atlas, false);
	end

	button.PlayerIndicator:SetShown(showPlayerIndicator);

	if ( usedGroups[group] ) then
		button:Enable();
		local isFiltered = CRF_GetFilterGroup(group);
		SetChecked(isFiltered);
	else
		SetChecked(false);
		button:Disable();
	end
end

function CompactRaidFrameManager_ToggleGroupFilter(group)
	CRF_SetFilterGroup(group, not CRF_GetFilterGroup(group));
	CompactRaidFrameManager_UpdateFilterInfo();
	CompactRaidFrameContainer:TryUpdate();
end


function CompactRaidFrameManager_UpdateRaidIcons()
	local raidMarkers = CompactRaidFrameManager.displayFrame.raidMarkers;
	local raidMarkerReset = raidMarkers.raidMarkerReset;
	local raidMarkerRemove = raidMarkers.raidMarkerRemove;
	if raidMarkers.activeTab == raidMarkers.raidMarkerUnitTab then 
		for i=1, NUM_RAID_ICONS do
			local button = raidMarkers["raidMarker"..i];
			button:UpdateRaidIcon();
		end
		if GetRaidTargetIndex("target") then
			raidMarkerRemove.markerTexture:SetDesaturated(false);
			raidMarkerRemove:Enable();
			raidMarkerRemove:Show();

			raidMarkerReset.markerTexture:SetDesaturated(false);
			raidMarkerReset:Enable();
		else
			raidMarkerRemove.markerTexture:SetDesaturated(true);
			raidMarkerRemove:Disable();
			raidMarkerRemove:Hide();

			raidMarkerReset.markerTexture:SetDesaturated(true);
			raidMarkerReset:Disable();
		end
	else --world markers
		for i=1, NUM_RAID_ICONS do
			local button = raidMarkers["raidMarker"..i];
			button:UpdateRaidIcon();
		end

		raidMarkerRemove:Hide();

		raidMarkerReset.markerTexture:SetDesaturated(false);
		raidMarkerReset:Enable();
	end
end

CRFM_DifficultyDropdownMixin = CreateFromMixins(CRFM_ToolbarButtonMixin);

function CRFM_DifficultyDropdownMixin:OnMenuOpened(menu)
	DropdownButtonMixin.OnMenuOpened(self, menu);

	self:OnButtonStateChanged();
end

function CRFM_DifficultyDropdownMixin:OnMenuClosed(menu)
	DropdownButtonMixin.OnMenuClosed(self, menu);

	self:OnButtonStateChanged();
end

function CRFM_DifficultyDropdownMixin:OnButtonStateChanged()
	local difficulty = GetDungeonDifficultyID();
	local atlas = nil; 
	if (difficulty == DifficultyUtil.ID.DungeonNormal) or DifficultyUtil.InStoryRaid() then
		atlas = "GM-icon-difficulty-normal";
	elseif difficulty == DifficultyUtil.ID.DungeonHeroic then
		atlas = "GM-icon-difficulty-heroic";
	else
		atlas = "GM-icon-difficulty-mythic";
	end

	if self:IsMenuOpen() then
		atlas = atlas.."selected";
	end

	if UnitIsGroupAssistant("player") then
		atlas = atlas.."assist";
	else
		if self:IsDownOver() or self:IsOver() then
			atlas = atlas.."-hover";
		elseif self:IsDown() then
			atlas = atlas.."-pressed";
		elseif not self:IsEnabled() then
			atlas = atlas.."-disabled";
		end
	end

	self:GetNormalTexture():SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
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

function CRFManagerRaidIconButtonMixin:OnClick(buttonName, down)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local raidMarkers = CompactRaidFrameManager.displayFrame.raidMarkers;
	if raidMarkers.activeTab == raidMarkers.raidMarkerUnitTab then
		if self:GetID() == RAID_MARKER_REMOVE_ID then
			SetRaidTarget("target", 0);
		elseif self:GetID() == RAID_MARKER_RESET_ID then
			RemoveRaidTargets();
		else
			if buttonName == "RightButton" then
				SetRaidTarget("target", 0);
			else
				SetRaidTarget("target", self:GetID());
			end
		end
	else
		if self:GetID() == RAID_MARKER_RESET_ID then
			ClearRaidMarker();
		else
			local marker = WORLD_RAID_MARKER_ORDER[self:GetMarker()];
			if buttonName == "RightButton" then
				local active = IsRaidMarkerActive(WORLD_RAID_MARKER_ORDER[self:GetMarker()]);
				if active then
					ClearRaidMarker(marker);
				end
			else
				ClearRaidMarker(marker);
				PlaceRaidMarker(marker);
			end
		end
	end
	CompactRaidFrameManager_UpdateRaidIcons();
end

function CRFManagerRaidIconButtonMixin:UpdateRaidIcon()
	local raidMarkers = CompactRaidFrameManager.displayFrame.raidMarkers;

	if (self == raidMarkers.raidMarkerRemove) or (self == raidMarkers.raidMarkerReset) then
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
			tab:GetNormalTexture():SetAtlas(tab == frame and "GM-tab-selected" or "GM-tab-inActive", TextureKitConstants.IgnoreAtlasSize);
			tab:SetNormalFontObject(tab == frame and GameFontHighlightSmall or GameFontDisableSmall);
			tab:SetWidth(tab:GetFontString():GetStringWidth() + 20);
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

RaidFrameEditModeMixin = CreateFromMixins(CRFM_ToolbarButtonMixin);

function RaidFrameEditModeMixin:OnShow()
	self:SetEnabled(EditModeManagerFrame:CanEnterEditMode());
end

function RaidFrameEditModeMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	ShowUIPanel(EditModeManagerFrame);
end

RaidFrameSettingsMixin = CreateFromMixins(CRFM_ToolbarButtonMixin);

function RaidFrameSettingsMixin:OnClick()
	Settings.OpenToCategory(Settings.INTERFACE_CATEGORY_ID, RAID_FRAMES_LABEL);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
end

RaidFrameHiddenModeToggleMixin = CreateFromMixins(CRFM_ToolbarButtonMixin);

function RaidFrameHiddenModeToggleMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	SetCVar("raidOptionIsShown", not GetCVarBool("raidOptionIsShown"));
end

RaidFrameEveryoneIsAssistMixin = CreateFromMixins(CRFM_ToolbarButtonMixin);

function RaidFrameEveryoneIsAssistMixin:OnLoad()
	CRFM_ButtonStateBehaviorMixin.OnLoad(self);

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

function RaidFrameEveryoneIsAssistMixin:OnButtonStateChanged()
	if self:GetChecked() then
		return;
	end

	CRFM_ButtonStateBehaviorMixin.OnButtonStateChanged(self);
end

RaidFrameReadyCheckMixin = CreateFromMixins(CRFM_ToolbarButtonMixin);

function RaidFrameReadyCheckMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	DoReadyCheck();
end

RaidFrameRolePollMixin = CreateFromMixins(CRFM_ToolbarButtonMixin);

function RaidFrameRolePollMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	InitiateRolePoll();
end

RaidFrameCountdownMixin = CreateFromMixins(CRFM_ToolbarButtonMixin);

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

function LeaveInstanceGroupButtonMixin:OnLoad()
	self.Text:SetMaxLines(1);
end

function LeaveInstanceGroupButtonMixin:OnUpdate()
	if C_PartyInfo.IsPartyWalkIn() then
		self:SetText(INSTANCE_WALK_IN_LEAVE);
	else
		self:SetText(INSTANCE_PARTY_LEAVE);
	end
	
	local enabled = PartyUtil.CanLeaveInstance();
	self:SetEnabled(enabled);
end

function LeaveInstanceGroupButtonMixin:OnClick()
	ConfirmOrLeaveParty();
end