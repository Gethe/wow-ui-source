local ROW_HEIGHT = 24;
local HORIZONTAL_INDENT = 20;
local VERTICAL_INDENT = 20;
local HEADER_TRIM_EXTRA_VERTICAL_OFFSET = 10;
local PROMPT_ICON_SIZE = 18; -- Scaled down slightly from the default 24x24.

local GAMEPLAY_GROUP = "GAMEPLAY";
local MODIFIER_GROUP = "MODIFIER";
local FRIENDLY_TARGETING_GROUP = "FRIENDLY_TARGETING";
local HOSTILE_TARGETING_GROUP = "HOSTILE_TARGETING";
local PARTY_GROUP = "PARTY";
local MENU_GROUP = "MENU";
local HUD_GROUP = "HUD";

local RAID_ICON_TEXTURE_FILE = "Interface\\TargetingFrame\\UI-RaidTargetingIcons";
local RAID_TARGET_MARKER_DISPLAY_WIDTH = 15;
local RAID_TARGET_MARKER_DISPLAY_HEIGHT = 15;
local RAID_TARGET_MARKER_DISPLAY_PROMPT_OFFSET = 10;

local DPAD_BUTTONS = {
	top = GAMEPAD_DPAD_TOP,
	bottom = GAMEPAD_DPAD_BOTTOM,
	left = GAMEPAD_DPAD_LEFT,
	right = GAMEPAD_DPAD_RIGHT,
};

local FACE_BUTTONS = {
	top = GAMEPAD_FACE_TOP,
	bottom = GAMEPAD_FACE_BOTTOM,
	left = GAMEPAD_FACE_LEFT,
	right = GAMEPAD_FACE_RIGHT,
};

GamepadPersistentInputLegendEntryMixin = {};

function GamepadPersistentInputLegendEntryMixin:OnLoad()
	self:SetPromptFont("GameFontNormal");
	self:SetInputIconSize(1, PROMPT_ICON_SIZE, PROMPT_ICON_SIZE);
end

function GamepadPersistentInputLegendEntryMixin:OnShow()
	if self.RefreshOnShow then
		self:RefreshOnShow(self);
	end
end

function GamepadPersistentInputLegendEntryMixin:SetCustomRefreshOnShow(RefreshFunction)
	self.RefreshOnShow = RefreshFunction;
end

function GamepadPersistentInputLegendEntryMixin:SetCustomRefreshWithCVar(CVar, RefreshFunction)
	CVarCallbackRegistry:RegisterCallback(CVar, RefreshFunction, self);
	RefreshFunction(self);
end

function GamepadPersistentInputLegendEntryMixin:SetCustomRefreshWithEvent(Event, RefreshFunction)
	self:RegisterEvent(Event);
	self[Event] = RefreshFunction;
	RefreshFunction(self);
end

function GamepadPersistentInputLegendEntryMixin:SetCustomRefreshWithEvents(Events, RefreshFunction)
	for _, Event in ipairs(Events) do
		self:SetCustomRefreshWithEvent(Event, RefreshFunction);
	end
end

function GamepadPersistentInputLegendEntryMixin:OnEvent(Event)
	if self[Event] then
		self[Event](self);
	end
end

GamepadPersistentInputLegendMixin = {};

function GamepadPersistentInputLegendMixin:SetGroupColumns(groupName, countAndWidth)
	if not self.columns then
		self.columns = {};
	end

	self.columns[groupName] = countAndWidth;
end

function GamepadPersistentInputLegendMixin:SetGroupUsesHeader(GroupName)
	if not self.headers then
		self.headers = {};
	end

	self.headers[GroupName] = true;
end

function GamepadPersistentInputLegendMixin:DoesGroupUseHeader(GroupName)
	return self.headers and self.headers[GroupName] or false;
end

function GamepadPersistentInputLegendMixin:GetColumnWidth(GroupName)
	return self.columns and self.columns[GroupName].width or 0;
end

function GamepadPersistentInputLegendMixin:GetGroupWidth(GroupName)
	if self.columns and self.columns[GroupName] then
		return HORIZONTAL_INDENT + self.columns[GroupName].count * self.columns[GroupName].width;
	end
	return 0;
end

function GamepadPersistentInputLegendMixin:AddToGroup(GroupName, Frame)
	if not self.groups then
		self.groups = {};
	end

	if not self.groups[GroupName] then
		self.groups[GroupName] = {};
	end

	table.insert(self.groups[GroupName], Frame);
end

function GamepadPersistentInputLegendMixin:CreateBackground(GroupName, height)
	local backgroundFrame = CreateFrame("Frame", nil, self, "GamepadPersistentInputLegendBackgroundTemplate");
	local width = self:GetGroupWidth(GroupName);
	backgroundFrame:SetSize(width, height);
	backgroundFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);

	if self:DoesGroupUseHeader(GroupName) then
		backgroundFrame.HeaderTrim:Show();
		backgroundFrame.HeaderTrim:SetDesaturation(1.0);
	end

	self:AddToGroup(GroupName, backgroundFrame);
end

function GamepadPersistentInputLegendMixin:CreateEntry(GroupName, ColumnIndex, RowIndex, IconString, LabelString)
	local template = type(IconString) == "table"
		and "GamepadPersistentInputLegendEntryWithTwoIconsTemplate"
		or "GamepadPersistentInputLegendEntryTemplate";

	local promptFrame = CreateFrame("Frame", nil, self, template);
	if type(IconString) == "table" then
		for i, s in ipairs(IconString) do
			promptFrame:SetPromptInputIconKey(i, s);
		end
	elseif IconString ~= nil then
		promptFrame:SetPromptInputIconKey(1, IconString);
	end
	promptFrame:SetPromptText(LabelString);
	promptFrame:EnablePrompt();

	local columnWidth = self:GetColumnWidth(GroupName);
	local horizontalOffset = HORIZONTAL_INDENT + (ColumnIndex * columnWidth);
	local verticalOffset =  -VERTICAL_INDENT + (-ROW_HEIGHT * RowIndex);

	-- If this group visualizes a header, scale up the top row text and offset items below it.
	if self:DoesGroupUseHeader(GroupName) then
		if RowIndex == 0 then
			promptFrame:SetPromptFont("GameFontNormal");
		else
			verticalOffset = verticalOffset - HEADER_TRIM_EXTRA_VERTICAL_OFFSET;
		end
	end

	promptFrame:ClearAllPoints();
	promptFrame:SetPoint("TOPLEFT", self, "TOPLEFT", horizontalOffset, verticalOffset);

	self:AddToGroup(GroupName, promptFrame);

	return promptFrame;
end

-- This uses the icon as identifier rather than col/row, just to reduce the risk of index mismatches
function GamepadPersistentInputLegendMixin:SetEntryPromptText(groupName, iconString, labelString)
	for _, frame in ipairs(self.groups[groupName]) do
		if frame.InputIcon1 and frame.InputIcon1.mappedButtonKey == iconString then
			frame:SetPromptText(labelString);
			break;
		end
	end
end

function GamepadPersistentInputLegendMixin:HideAllGroups()
	if self.groups then
		for _, group in pairs(self.groups) do
			for _, frame in pairs(group) do
				frame:Hide();
			end
		end
	end
end

function GamepadPersistentInputLegendMixin:ShowGroup(GroupName)
	self:HideAllGroups();

	local group = self.groups and self.groups[GroupName] or nil;
	if group then
		for _, frame in pairs(group) do
			frame:Show();
		end
	end
end

function GamepadPersistentInputLegendMixin:OnGamepadShowPersistentInputLegendChanged()
	self:RefreshVisibility();
end

function GamepadPersistentInputLegendMixin:RefreshTargetingModifiers()
	if CVarCallbackRegistry:GetCVarValueBool("GamepadSwapTargetModifiers") then
		self.leftTargetingModEntry:SetPromptText(PROMPT_HOSTILE_TARGETING);
		self.rightTargetingModEntry:SetPromptText(PROMPT_FRIENDLY_TARGETING);
		self.friendlyTargetingHeader:SetPromptInputIconKey(1, GAMEPAD_SHOULDER_RIGHT);
		self.hostileTargetingHeader:SetPromptInputIconKey(1, GAMEPAD_SHOULDER_LEFT);
	else
		self.leftTargetingModEntry:SetPromptText(PROMPT_FRIENDLY_TARGETING);
		self.rightTargetingModEntry:SetPromptText(PROMPT_HOSTILE_TARGETING);
		self.friendlyTargetingHeader:SetPromptInputIconKey(1, GAMEPAD_SHOULDER_LEFT);
		self.hostileTargetingHeader:SetPromptInputIconKey(1, GAMEPAD_SHOULDER_RIGHT);
	end

	self:RefreshVisibility();
end

local function SetPromptIcons(prompts, map)
	for k, prompt in pairs(prompts) do
		if prompt then
			prompt:SetPromptInputIconKey(1, map[k]);
		end
	end
end

function GamepadPersistentInputLegendMixin:RefreshFriendlyTargetingModifierIcons()
	if CVarCallbackRegistry:GetCVarValueBool("GamepadSwapFriendlyTargetActions") then
		SetPromptIcons(self.friendlyDpadEntries, FACE_BUTTONS);
		SetPromptIcons(self.friendlyFaceEntries, DPAD_BUTTONS);
	else
		SetPromptIcons(self.friendlyDpadEntries, DPAD_BUTTONS);
		SetPromptIcons(self.friendlyFaceEntries, FACE_BUTTONS);
	end

	self:RefreshVisibility();
end

function GamepadPersistentInputLegendMixin:RefreshHostileTargetingModifierIcons()
	if CVarCallbackRegistry:GetCVarValueBool("GamepadSwapHostileTargetActions") then
		SetPromptIcons(self.hostileDpadEntries, FACE_BUTTONS);
		SetPromptIcons(self.hostileFaceEntries, DPAD_BUTTONS);
	else
		SetPromptIcons(self.hostileDpadEntries, DPAD_BUTTONS);
		SetPromptIcons(self.hostileFaceEntries, FACE_BUTTONS);
	end

	self:RefreshVisibility();
end

function GamepadPersistentInputLegendMixin:RefreshVisibility()
	if (not InputUtil.IsGamepadUIEnabled()) then
		self:HideAllGroups();
		return;
	end

	if self.hostileFaceEntries then
		self.hostileFaceEntries.left:EnableOrDisablePrompt(GamepadMainActionBarFramePageUnitHostileTargetingActionBarActionButton5:IsEnabled());
	end

	local isHudModifierActive = GamepadMode.IsHUDBindingModifierDown();
	local isFriendlyTargetingModActive = GamepadMode.IsTargetingModifierDown(GamepadTargetingState.FRIENDLY);
	local isHostileTargetingModActive = GamepadMode.IsTargetingModifierDown(GamepadTargetingState.HOSTILE);
	local isTargetingModActive = isFriendlyTargetingModActive or isHostileTargetingModActive;
	local isBindingActive = GamepadActionBarEditFrame and GamepadActionBarEditFrame:IsVisible();
	local isAOETargeting = AOEPrompt and AOEPrompt:IsShown();
	local isHudModeActive = GamepadHudMode:IsShown();
	local validInputMode = GamepadSharedUtility.BindingStack.InputBindingManager:IsOnlyCoreBindingSetActive()
		or isHudModifierActive or isTargetingModActive or isAOETargeting or isHudModeActive;

	if not GetCVarBool("GamepadShowPersistentInputLegend") or GamepadRadial:IsShown() or GameMenuFrame:IsShown() or isBindingActive then
		self:HideAllGroups();
	elseif validInputMode then
		if isHudModeActive then
			self:ShowGroup(HUD_GROUP);
		elseif isHudModifierActive then
			self:ShowGroup(MODIFIER_GROUP);
		elseif isFriendlyTargetingModActive then
			self:ShowGroup(FRIENDLY_TARGETING_GROUP);
		elseif isHostileTargetingModActive then
			self:ShowGroup(HOSTILE_TARGETING_GROUP);
		else
			self:ShowGroup(GAMEPLAY_GROUP);
		end
	else
		self:ShowGroup(MENU_GROUP);
	end
end

function GamepadPersistentInputLegendMixin:OnLoad()
	EventUtil.ContinueOnVariablesLoaded(GenerateClosure(self.PostVariableSetUp, self));
end

function GamepadPersistentInputLegendMixin:PostVariableSetUp()
	CVarCallbackRegistry:RegisterCallback("GamepadShowPersistentInputLegend", self.OnGamepadShowPersistentInputLegendChanged, self);

	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.RefreshVisibility, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.RefreshVisibility, self));

	GamepadSharedUtility.BindingStack.InputBindingManager:BindToCoreBindingActive(GenerateClosure(self.RefreshVisibility, self));
	GamepadMode.RegisterInputModifierStateChangeCallback(GenerateClosure(self.RefreshVisibility, self), self);
	GamepadMode.RegisterTargetModifierStateChanged(GenerateClosure(self.RefreshVisibility, self), self);
	if GroupTargeting then
		GroupTargeting:RegisterGroupTargetingStateChanged(GenerateClosure(self.RefreshVisibility, self), self);
	end
	EventRegistry:RegisterCallback("Gamepad.ShowMainMenu", self.RefreshVisibility, self);
	EventRegistry:RegisterCallback("Gamepad.HideMainMenu", self.RefreshVisibility, self);

	local function GetBackgroundHeightForRows(RowCount, IncludeHeader)
		-- Rows are slightly taller than their contents, so find that difference and remove it to get a consistent indent distance to bottom edge.
		local finalRowExtraSpace = ROW_HEIGHT - PROMPT_ICON_SIZE;
		local calculatedHeight = (ROW_HEIGHT * RowCount) + (VERTICAL_INDENT * 2) - finalRowExtraSpace;
		if IncludeHeader then
			calculatedHeight = calculatedHeight + ROW_HEIGHT + HEADER_TRIM_EXTRA_VERTICAL_OFFSET;
		end
		return calculatedHeight;
	end

	local ONE_WIDE_COLUMN = { count = 1, width = 300 };
	local TWO_MEDIUM_COLUMNS = { count = 2, width = 250 };
	local THREE_NARROW_COLUMNS = { count = 3, width = 200 };

	-- Create Gameplay entries that should be shown in the default state.
	self:SetGroupColumns(GAMEPLAY_GROUP, ONE_WIDE_COLUMN);
	self:CreateBackground(GAMEPLAY_GROUP, GetBackgroundHeightForRows(4));
	self.leftTargetingModEntry = self:CreateEntry(GAMEPLAY_GROUP, 0, 0, GAMEPAD_SHOULDER_LEFT, PROMPT_FRIENDLY_TARGETING);
	self.rightTargetingModEntry = self:CreateEntry(GAMEPLAY_GROUP, 0, 1, GAMEPAD_SHOULDER_RIGHT, PROMPT_HOSTILE_TARGETING);
	self:CreateEntry(GAMEPLAY_GROUP, 0, 2, GAMEPAD_STICK_RIGHT_PRESS, PROMPT_PING);
	self:CreateEntry(GAMEPLAY_GROUP, 0, 3, GAMEPAD_STICK_LEFT_PRESS, PROMPT_AUTO_RUN);

	-- Create modifier entries that should be shown while the friendly target modifier is held.
	self:SetGroupColumns(FRIENDLY_TARGETING_GROUP, TWO_MEDIUM_COLUMNS);
	self:SetGroupUsesHeader(FRIENDLY_TARGETING_GROUP);
	self:CreateBackground(FRIENDLY_TARGETING_GROUP, GetBackgroundHeightForRows(5, true));

	self.friendlyTargetingHeader = self:CreateEntry(
		FRIENDLY_TARGETING_GROUP, 0, 0, GAMEPAD_SHOULDER_LEFT,
		WHITE_FONT_COLOR:WrapTextInColorCode(PROMPT_FRIENDLY_TARGETING_ACTIONS));

	self.friendlyDpadEntries = {
		top = self:CreateEntry(FRIENDLY_TARGETING_GROUP, 0, 1, GAMEPAD_DPAD_TOP, PROMPT_TARGET_GROUP_UP),
		bottom = self:CreateEntry(FRIENDLY_TARGETING_GROUP, 0, 2, GAMEPAD_DPAD_BOTTOM, PROMPT_TARGET_GROUP_DOWN),
		left = self:CreateEntry(FRIENDLY_TARGETING_GROUP, 0, 3, GAMEPAD_DPAD_LEFT, PROMPT_TARGET_GROUP_LEFT),
		right = self:CreateEntry(FRIENDLY_TARGETING_GROUP, 0, 4, GAMEPAD_DPAD_RIGHT, PROMPT_TARGET_GROUP_RIGHT),
	};

	self.friendlyFaceEntries = {
		top = self:CreateEntry(FRIENDLY_TARGETING_GROUP, 1, 1, GAMEPAD_FACE_TOP, PROMPT_APPLY_TARGET_MARKER),
		bottom = self:CreateEntry(FRIENDLY_TARGETING_GROUP, 1, 2, GAMEPAD_FACE_BOTTOM, PROMPT_TARGET_SELF),
		left = self:CreateEntry(FRIENDLY_TARGETING_GROUP, 1, 3, GAMEPAD_FACE_LEFT, PROMPT_TARGET_PET),
		right = self:CreateEntry(FRIENDLY_TARGETING_GROUP, 1, 4, GAMEPAD_FACE_RIGHT, BINDING_NAME_ASSISTTARGET),
	};

	self.friendlyShortcutsEntry = self:CreateEntry(FRIENDLY_TARGETING_GROUP, 0, 5, GAMEPAD_SHOULDER_RIGHT, PROMPT_SHORTCUTS);

	local FriendlyTargetMarkerEntry = self.friendlyFaceEntries.top;
	local TargetPetEntry = self.friendlyFaceEntries.left;

	-- Create modifier entries that should be shown while the hostile target modifier is held.
	self:SetGroupColumns(HOSTILE_TARGETING_GROUP, ONE_WIDE_COLUMN);
	self:SetGroupUsesHeader(HOSTILE_TARGETING_GROUP);
	self:CreateBackground(HOSTILE_TARGETING_GROUP, GetBackgroundHeightForRows(5, true));

	self.hostileTargetingHeader = self:CreateEntry(
		HOSTILE_TARGETING_GROUP, 0, 0, GAMEPAD_SHOULDER_RIGHT,
		WHITE_FONT_COLOR:WrapTextInColorCode(PROMPT_HOSTILE_TARGETING_ACTIONS));

	self.hostileDpadEntries = {
	};

	self.hostileFaceEntries = {
		top = self:CreateEntry(HOSTILE_TARGETING_GROUP, 0, 1, GAMEPAD_FACE_TOP, PROMPT_APPLY_TARGET_MARKER),
		bottom = self:CreateEntry(HOSTILE_TARGETING_GROUP, 0, 2, GAMEPAD_FACE_BOTTOM, BINDING_NAME_TARGETLASTHOSTILE),
		left = self:CreateEntry(HOSTILE_TARGETING_GROUP, 0, 3, GAMEPAD_FACE_LEFT, RANGED_ATTACK),
		right = self:CreateEntry(HOSTILE_TARGETING_GROUP, 0, 4, GAMEPAD_FACE_RIGHT, BINDING_NAME_ASSISTTARGET),
	};

	self.hostileShortcutsEntry = self:CreateEntry(HOSTILE_TARGETING_GROUP, 0, 5, GAMEPAD_SHOULDER_LEFT, PROMPT_SHORTCUTS);

	local HostileTargetMarkerEntry = self.hostileFaceEntries.top;

	-- Create Modifier entries that should be shown while both targeting modifiers are held.
	self:SetGroupColumns(MODIFIER_GROUP, THREE_NARROW_COLUMNS);
	self:SetGroupUsesHeader(MODIFIER_GROUP);
	self:CreateBackground(MODIFIER_GROUP, GetBackgroundHeightForRows(4, true));
	self:CreateEntry(MODIFIER_GROUP, 0, 0, {GAMEPAD_SHOULDER_LEFT, GAMEPAD_SHOULDER_RIGHT}, WHITE_FONT_COLOR:WrapTextInColorCode(PROMPT_SHORTCUT_ACTIONS));

	self:CreateEntry(MODIFIER_GROUP, 0, 1, GAMEPAD_DPAD_RIGHT, PROMPT_NEXT_ACTION_PAGE);
	self:CreateEntry(MODIFIER_GROUP, 0, 2, GAMEPAD_DPAD_LEFT, PROMPT_PREVIOUS_ACTION_PAGE);
	self:CreateEntry(MODIFIER_GROUP, 0, 3, GAMEPAD_DPAD_TOP, PROMPT_VIEW_QUEST_TRACKER);
	self:CreateEntry(MODIFIER_GROUP, 0, 4, GAMEPAD_DPAD_BOTTOM, PROMPT_VIEW_CHAT);

	self:CreateEntry(MODIFIER_GROUP, 1, 1, GAMEPAD_FACE_TOP, PROMPT_VIEW_BUFFS);
	self:CreateEntry(MODIFIER_GROUP, 1, 2, GAMEPAD_FACE_LEFT, BINDING_NAME_TOGGLESHEATH);
	self:CreateEntry(MODIFIER_GROUP, 1, 3, GAMEPAD_FACE_RIGHT, PROMPT_OPEN_BAGS);

	self:CreateEntry(MODIFIER_GROUP, 2, 1, GAMEPAD_STICK_RIGHT_PRESS, PROMPT_FLIP_CAMERA);
	self:CreateEntry(MODIFIER_GROUP, 2, 2, GAMEPAD_STICK_LEFT_PRESS, PROMPT_CENTER_CAMERA);
	self:CreateEntry(MODIFIER_GROUP, 2, 3, GAMEPAD_STICK_RIGHT, PROMPT_ZOOM_IN_CAMERA);
	self:CreateEntry(MODIFIER_GROUP, 2, 4, GAMEPAD_STICK_RIGHT, PROMPT_ZOOM_OUT_CAMERA);

	-- Add the marker texture display to the right of the apply target marker prompt.
	local function CreateTargetMarkerDisplay(entry)
		local tex = entry:CreateTexture();
		tex:SetPoint("LEFT", entry, "RIGHT", RAID_TARGET_MARKER_DISPLAY_PROMPT_OFFSET, 0);
		tex:SetSize(RAID_TARGET_MARKER_DISPLAY_WIDTH, RAID_TARGET_MARKER_DISPLAY_HEIGHT);
		tex:SetTexture(RAID_ICON_TEXTURE_FILE);
		entry.MarkerDisplayTexture = tex;
	end

	CreateTargetMarkerDisplay(FriendlyTargetMarkerEntry);
	CreateTargetMarkerDisplay(HostileTargetMarkerEntry);

	-- Create Menu entries that show while UI Frames are active.
	self:SetGroupColumns(MENU_GROUP, ONE_WIDE_COLUMN);
	self:CreateBackground(MENU_GROUP, GetBackgroundHeightForRows(4));
	self:CreateEntry(MENU_GROUP, 0, 0, GAMEPAD_MENU_LEFT, PROMPT_FOCUS_UI);
	self:CreateEntry(MENU_GROUP, 0, 1, GAMEPAD_TRIGGER_LEFT, PROMPT_PREVIOUS_FRAME);
	self:CreateEntry(MENU_GROUP, 0, 2, GAMEPAD_TRIGGER_RIGHT, PROMPT_NEXT_FRAME);
	self:CreateEntry(MENU_GROUP, 0, 3, GAMEPAD_STICK_RIGHT_PRESS, PROMPT_TOGGLE_TOOLTIPS);

	-- Create HUD Mode entries to show while inspecting the HUD.
	self:SetGroupColumns(HUD_GROUP, ONE_WIDE_COLUMN);
	self:SetGroupUsesHeader(HUD_GROUP);
	self:CreateBackground(HUD_GROUP, GetBackgroundHeightForRows(4, true));
	self:CreateEntry(HUD_GROUP, 0, 0, GAMEPAD_MENU_LEFT, WHITE_FONT_COLOR:WrapTextInColorCode(PROMPT_INSPECT_HUD));
	self:CreateEntry(HUD_GROUP, 0, 1, GAMEPAD_FACE_BOTTOM, SELECT);
	self:CreateEntry(HUD_GROUP, 0, 2, GAMEPAD_FACE_RIGHT, PROMPT_EXIT);
	self:CreateEntry(HUD_GROUP, 0, 3, GAMEPAD_DPAD_LEFT, PROMPT_PREVIOUS_FRAME);
	self:CreateEntry(HUD_GROUP, 0, 4, GAMEPAD_DPAD_RIGHT, PROMPT_NEXT_FRAME);

	-- Update labels/icons to account for swapped modifiers
	self:RefreshTargetingModifiers();
	self:RefreshFriendlyTargetingModifierIcons();
	self:RefreshHostileTargetingModifierIcons();

	CVarCallbackRegistry:RegisterCallback("GamepadSwapTargetModifiers", self.RefreshTargetingModifiers, self);
	CVarCallbackRegistry:RegisterCallback("GamepadSwapFriendlyTargetActions", self.RefreshFriendlyTargetingModifierIcons, self);
	CVarCallbackRegistry:RegisterCallback("GamepadSwapHostileTargetActions", self.RefreshHostileTargetingModifierIcons, self);

	-- Set up any custom refresh events that may occur while the frame is active, or as a result of frame inputs.
	local isInGroup = IsInGroup();
	for k, prompt in pairs(self.friendlyDpadEntries) do
		prompt:EnableOrDisablePrompt(isInGroup);
		prompt:SetCustomRefreshWithEvents({"GROUP_JOINED", "GROUP_LEFT"}, function(self)
			self:EnableOrDisablePrompt(IsInGroup());
		end);
	end

	TargetPetEntry:EnableOrDisablePrompt(UnitExists("pet"));
	TargetPetEntry:SetCustomRefreshWithEvent("UNIT_PET", function(self)
		self:EnableOrDisablePrompt(UnitExists("pet"));
	end);

	local function RefreshTargetMarker(entry, getterName)
		if not UnitExists("target") then
			entry:DisablePrompt();
			entry.MarkerDisplayTexture:Hide();
			return;
		end

		local indexGetter = _G[getterName];
		local nextMarker = indexGetter();

		entry:EnablePrompt();

		if nextMarker then
			SetRaidTargetIconTexture(entry.MarkerDisplayTexture, nextMarker);
			entry.MarkerDisplayTexture:Show();
			entry:SetPromptText(PROMPT_APPLY_TARGET_MARKER);
		else
			entry.MarkerDisplayTexture:Hide();
			entry:SetPromptText(PROMPT_CLEAR_TARGET_MARKER);
		end
	end

	-- The getters may not have been loaded yet...
	local markerEntries = {
		[FriendlyTargetMarkerEntry] = "GetNextFriendlyRaidTargetMarkerIndex",
		[HostileTargetMarkerEntry] = "GetNextHostileRaidTargetMarkerIndex",
	};

	for entry, indexGetter in pairs(markerEntries) do
		if Kiosk.IsEnabled() then
			entry:DisablePrompt();
		else
			local handler = GenerateClosure(RefreshTargetMarker, entry, indexGetter);
			entry:SetCustomRefreshOnShow(handler);
			entry:SetCustomRefreshWithEvents({"PLAYER_TARGET_CHANGED", "RAID_TARGET_UPDATE"}, handler);
		end
	end

	self:RefreshVisibility();
end
