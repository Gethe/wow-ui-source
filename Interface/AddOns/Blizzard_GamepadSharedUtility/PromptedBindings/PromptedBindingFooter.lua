PromptedBindingFooterMixin = {};

PromptedBindingFooterMixin.ALIGNMENT_TYPE =
{
	LEFT = 1,
	RIGHT = 2,
	CENTER = 3
};

PromptedBindingFooterMixin.OVERFLOW_TYPE =
{
	EXPAND = 1,
	WRAP = 2
};

-- Regardless of order registered, the footer will display keys left to right in this order.
local KEYS_IN_SORT_ORDER =
{
	GAMEPAD_FACE_BOTTOM,
	GAMEPAD_FACE_LEFT,
	GAMEPAD_FACE_TOP,
	GAMEPAD_DPAD_HORIZONTAL,
	GAMEPAD_DPAD_VERTICAL,
	GAMEPAD_DPAD,
	GAMEPAD_DPAD_LEFT,
	GAMEPAD_DPAD_TOP,
	GAMEPAD_DPAD_RIGHT,
	GAMEPAD_DPAD_BOTTOM,
	GAMEPAD_MENU_LEFT,
	GAMEPAD_MENU_RIGHT,
	GAMEPAD_SHOULDER_LEFT,
	GAMEPAD_SHOULDER_RIGHT,
	GAMEPAD_STICK_LEFT,
	GAMEPAD_STICK_LEFT_PRESS,
	GAMEPAD_STICK_RIGHT,
	GAMEPAD_STICK_RIGHT_VERTICAL,
	GAMEPAD_STICK_RIGHT_HORIZONTAL,
	GAMEPAD_STICK_RIGHT_PRESS,
	GAMEPAD_TRIGGER_LEFT,
	GAMEPAD_TRIGGER_RIGHT,
	GAMEPAD_FACE_RIGHT
};

local parentFrameToFooterMap = {};

function PromptedBindingFooterMixin:Init(parentFrame, debugName)
	self.parentFrame = parentFrame;
	self.debugName = debugName and debugName or "PromptedBindingFooter";
	self.alignmentType = PromptedBindingFooterMixin.ALIGNMENT_TYPE.LEFT;
	self.overflowType = PromptedBindingFooterMixin.OVERFLOW_TYPE.EXPAND;
	self.xOffset = 0;
	self.yOffset = 0;
	self.disallowButtonContexts = false;

	self.promptedBindings = {};
	self.promptedBindingsByKey = {};
	self.promptedBindingsActive = {};

	self.inputLegend = nil;
	self.isShown = false;

	-- There may be multiple footers associated with the same parent frame, but we should only need an arbitrary entry assuming they are laid out consistently.
	parentFrameToFooterMap[parentFrame] = self;
end

-- This is the standard setup function you want for adding prompted bindings to this footer.
function PromptedBindingFooterMixin:AddPromptedBinding(promptedBinding)
	table.insert(self.promptedBindings, promptedBinding);
end

function PromptedBindingFooterMixin:AddPromptedBindings(promptedBindings)
	for _, promptedBinding in ipairs(promptedBindings) do
		self:AddPromptedBinding(promptedBinding);
	end
end

-- Utility wrapper for cases where we only care about a simple key-function handler with no visuals but want it managed by the footer.
function PromptedBindingFooterMixin:AddFunctionBinding(key, func)
	local promptedBinding = GamepadSharedUtility.CreatePromptedBinding(key, "FunctionPromptedBinding");
	promptedBinding:AddFooterBinding({ visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.NEVER });
	promptedBinding:AddFooterFunction({ bindingFunctions = func });
	self:AddPromptedBinding(promptedBinding);
	return promptedBinding;
end

function PromptedBindingFooterMixin:AddStandardSelectPrompt(optionalLabel)
	local label = optionalLabel and optionalLabel or ACTION_LABEL_SELECT;

	-- The default "select" behavior is handled by Smart Navigation so this only adds a prompt, not a binding.
	local promptedBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, "StandardSelectPromptedBinding");
	promptedBinding:AddFooterBinding({
		label = label,
		conditions = SmartNavigation_IsCurrentButtonClickable
	});
	self:AddPromptedBinding(promptedBinding);
	return promptedBinding;
end

function PromptedBindingFooterMixin:AddNonFallbackSelectPrompt(optionalLabel)
	local label = optionalLabel and optionalLabel or ACTION_LABEL_SELECT;

	local function NoButtonContext()
		-- This variant will not be used as a fallback if we failed a more specific check on the same key.
		return SmartNavigation:GetCurrentButtonContext() == nil;
	end

	local promptedBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, "NonFallbackSelectPromptedBinding");
	promptedBinding:AddFooterBinding({
		label = label,
		conditions = { SmartNavigation_IsCurrentButtonClickable, NoButtonContext },
	})
	self:AddPromptedBinding(promptedBinding);
	return promptedBinding;
end

function PromptedBindingFooterMixin:AddStandardFrameControlManagerBindings(focusedFrame)
	-- Next handling is managed by FrameControlsManager. Only prompt the user.
	local nextBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_TRIGGER_RIGHT, "FCMRTPromptedBinding");
	GamepadMode.FrameControlsManager:RegisterJumpHintRightBinding(focusedFrame, nextBinding);
	self:AddPromptedBinding(nextBinding);

	-- Previous handling is managed by FrameControlsManager. Only prompt the user.
	local prevBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_TRIGGER_LEFT, "FCMLTPromptBinding");
	GamepadMode.FrameControlsManager:RegisterJumpHintLeftBinding(focusedFrame, prevBinding);
	self:AddPromptedBinding(prevBinding);

	return nextBinding, prevBinding;
end

function PromptedBindingFooterMixin:AddStandardBackPrompt(optionalLabel)
	local label = optionalLabel and optionalLabel or FRAME_ACTION_BACK;

	-- The default "back" behavior is handled by Smart Navigation so this only adds a prompt, not a binding.
	local promptedBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, "StandardBackPromptedBinding");
	promptedBinding:AddFooterBinding({
		label = label,
	})
	self:AddPromptedBinding(promptedBinding);
	return promptedBinding;
end

function PromptedBindingFooterMixin:SetParentFrame(parentFrame)
	if self.parentFrame == parentFrame then
		return;
	end

	self.parentFrame = parentFrame;

	if self.inputLegend then
		self:ApplyInputLegendAttachment();
	end
end

function PromptedBindingFooterMixin:SetAnchorOffsets(xOffset, yOffset)
	self.xOffset = xOffset;
	self.yOffset = yOffset;
	self:ApplyInputLegendAttachment();
end

function PromptedBindingFooterMixin:SetAlignmentType(alignmentType)
	self.alignmentType = alignmentType;
	self:ApplyInputLegendAttachment();
end

function PromptedBindingFooterMixin:SetOverflowType(overflowType)
	self.overflowType = overflowType;
	self:ApplyInputLegendAttachment();
end

-- See CreateAnchor in AnchorUtil.lua
function PromptedBindingFooterMixin:SetCustomAnchor(anchor)
	self.customAnchor = anchor;
end

-- Call this after adding all required prompted bindings to the footer. This generates the visual data and begins listening for refresh events.
function PromptedBindingFooterMixin:Finalize()
	self:GeneratePromptedBindingsByKey();
	self.requiresBindingGroup = self:IsBindingGroupRequired();
	self:Refresh();
end

function PromptedBindingFooterMixin:UseWideBackground()
	self.useWideBackground = true;
	if self.inputLegend then
		self.inputLegend:ApplyWideStyle();
	end
end

function PromptedBindingFooterMixin:RefreshCustomFrameVisibility()
	-- Hide everything first to guarantee our state is reset correctly.
	for _, promptedBinding in ipairs(self.promptedBindings) do
		promptedBinding:SetCustomPromptFrameShown(false);
	end

	if self.isShown then
		for _, promptedBinding in ipairs(self.promptedBindingsActive) do
			promptedBinding:SetCustomPromptFrameShown(true);
		end
	end
end

function PromptedBindingFooterMixin:GeneratePromptedBindingsByKey()
	-- First, rearrange all the bindings in the key order that they should be displayed.
	local sortedBindings = {};
	for _, key in ipairs(KEYS_IN_SORT_ORDER) do
		for _, promptedBinding in ipairs(self.promptedBindings) do
			if promptedBinding:GetKeyForIndex(1) == key then
				table.insert(sortedBindings, promptedBinding);
			end
		end
	end

	-- Then in priority order, add the bindings to a group of others with the same key.
	self.promptedBindingsByKey = {};
	for _, promptedBinding in ipairs(sortedBindings) do
		local mainKey = promptedBinding:GetKeyForIndex(1);
		if not self.promptedBindingsByKey[mainKey] then
			self.promptedBindingsByKey[mainKey] = {};
		end
		table.insert(self.promptedBindingsByKey[mainKey], promptedBinding);
	end
end

function PromptedBindingFooterMixin:IsBindingGroupRequired()
	for _, promptedBinding in ipairs(self.promptedBindings) do
		for index = 1, 2 do
			local key = promptedBinding:GetKeyForIndex(index);
			if key and promptedBinding:RequireTriggerBinding() then
				return true;
			end
		end
	end
	return false;
end

function PromptedBindingFooterMixin:GetPromptedBindingToDisplayForKey(key)
	local bindingsForKey = self.promptedBindingsByKey[key];
	if bindingsForKey then
		-- Iterate through the list of binds using this key, which is already sorted by highest priority.
		for _, promptedBinding in ipairs(bindingsForKey) do
			-- The first one that is valid will always be what we want to show.
			if promptedBinding:IsAnyConditionMet() then
				return promptedBinding;
			end
		end

		-- If none are available, again going by priority find the first one that should show while unavailable.
		for _, promptedBinding in ipairs(bindingsForKey) do
			if promptedBinding:IsAnyBindingAlwaysVisible() then
				return promptedBinding;
			end
		end
	end

	return nil;
end

-- If the input legend was repositioned manually, this can be called to reset its default anchoring.
function PromptedBindingFooterMixin:ApplyInputLegendAttachment()
	if self.inputLegend then
		self.inputLegend:ClearAllPoints();
		self.inputLegend:SetParent(self.parentFrame);

		if self.customAnchor then
			self.customAnchor:SetPoint(self.inputLegend);
		elseif self.alignmentType == PromptedBindingFooterMixin.ALIGNMENT_TYPE.LEFT then
			self.inputLegend:SetPoint("TOPLEFT", self.parentFrame, "BOTTOMLEFT", self.xOffset, self.yOffset);
		elseif self.alignmentType == PromptedBindingFooterMixin.ALIGNMENT_TYPE.RIGHT then
			self.inputLegend:SetPoint("TOPRIGHT", self.parentFrame, "BOTTOMRIGHT", self.xOffset, self.yOffset);
		else
			self.inputLegend:SetPoint("TOP", self.parentFrame, "BOTTOM", self.xOffset, self.yOffset);
		end

		-- The default "EXPAND" occurs automatically when the input legend is refreshed without a specified width, so only check the alternative.
		if self.overflowType == PromptedBindingFooterMixin.OVERFLOW_TYPE.WRAP then
			self.inputLegend:SetLegendWidth(self.parentFrame:GetWidth());
		end
	end
end

function PromptedBindingFooterMixin:RefreshPromptedBindingsActive()
	self.promptedBindingsActive = {};

	for _, key in ipairs(KEYS_IN_SORT_ORDER) do
		local foundBinding = self:GetPromptedBindingToDisplayForKey(key);
		if foundBinding then
			table.insert(self.promptedBindingsActive, foundBinding);
		end
	end
end

function PromptedBindingFooterMixin:RefreshInputLegend()
	-- First time setup.
	if not self.inputLegend then
		self.inputLegend = InputPromptLegends.CreateInputLegend(self.parentFrame, self.debugName .. "inputLegend", self.useWideBackground);
		self:ApplyInputLegendAttachment();

		-- TODO(mwinkler):
		-- This is only needed so that the `InputLegend` uses the order that we desire since it orders items based on frame creation and
		-- frames get reused if they already exist inside the `InputLegend` map.
		-- Find a better way to provide a sort order to the `InputLegend` when it applies the frame positioning.
		for _, key in ipairs(KEYS_IN_SORT_ORDER) do
			local promptedBindings = self.promptedBindingsByKey[key]; -- Use a lookup because values in this table will not be iterated in sort order.
			if promptedBindings then
				local promptedBinding = promptedBindings[1];
				local template = promptedBinding:GetInputIconTemplate();
				if template then
					self.inputLegend:GetOrCreatePromptFrameUsingTemplateAndInputs(template.name,
																				  promptedBinding:GetDisplayKeys(),
																				  GAMEPAD_PROMPT_DIVIDER_SLASH);
				end
			end
		end
	end

	local promptedBindingsInFooter = {};
	for _, promptedBinding in ipairs(self.promptedBindingsActive) do
		local showInFooter = promptedBinding:ShouldShowFooterBinding();
		if showInFooter then
			table.insert(promptedBindingsInFooter, promptedBinding);
		end
	end
	self.inputLegend:RefreshWithPromptedBindings(promptedBindingsInFooter);

	if self.isShown then
		self.inputLegend:Show();
	else
		self.inputLegend:Hide();
	end
end

function PromptedBindingFooterMixin:RefreshBindingGroup()
	if not self.requiresBindingGroup then
		return;
	end

	if self.bindings then
		if self.isShown then
			GamepadMode.DeactivateBindingGroup(self.bindings);
		end
		GamepadMode.UncacheBindingGroup(self.bindings);
	end

	self.bindings = GamepadMode.CreateBindingGroup(self.debugName);

	for _, promptedBinding in ipairs(self.promptedBindingsActive) do
		-- A single prompt can visualize two different actions at the same time, e.g. LB/RB callouts, but they need to be bound separately.
		for index = 1, 2 do
			local key = promptedBinding:GetKeyForIndex(index);
			if key and promptedBinding:RequireTriggerBinding() then
				--[[
					TODO for future us: Prompted bindings need to wrap TriggerBinding,
					and handle button up _and_ down events regardless of trigger conditions, so that
					the prompts can react to the appropriate up and down.

					TriggerBinding should only be called based on binding configuration (i.e. not
					necessarily all buttonEvents, but the input prompt must be notified of all
					up and down events).
				]]
				self.bindings:AddFunctionBinding(key,
												 GenerateClosure(promptedBinding.TriggerBinding, promptedBinding, index),
												 GAMEPAD_BUTTON_ANY_DOWN_OR_UP,
												 GenerateFlatClosure(promptedBinding.OnOverbound, promptedBinding, index));
			end
		end
	end

	if self.isShown then
		GamepadMode.ActivateBindingGroup(self.bindings);
	end
end

function PromptedBindingFooterMixin:Refresh()
	self:RefreshPromptedBindingsActive();
	self:RefreshInputLegend();
	self:RefreshBindingGroup();
	self:RefreshCustomFrameVisibility();
end

function PromptedBindingFooterMixin:ShowAndActivateBindings()
	if not self.isShown then
		self.isShown = true;
		EventRegistry:RegisterCallback("Gamepad.RefreshFrameFocus", self.Refresh, self);
		SmartNavigation:RegisterCallback("SelectedButtonUpdated", GenerateClosure(self.Refresh, self), self);
		SmartNavigation:RegisterCallback("SelectedButtonEnabledStateChanged", GenerateClosure(self.Refresh, self), self);
		self:Refresh();
	end
end

function PromptedBindingFooterMixin:HideAndDeactivateBindings()
	if self.isShown then
		self.isShown = false;
		if self.bindings then
			GamepadMode.DeactivateBindingGroup(self.bindings);
		end
		EventRegistry:UnregisterCallback("Gamepad.RefreshFrameFocus", self);
		SmartNavigation:UnregisterCallback("SelectedButtonUpdated", self);
		SmartNavigation:UnregisterCallback("SelectedButtonEnabledStateChanged", self);
		self.inputLegend:Hide();
		self:RefreshCustomFrameVisibility();
	end
end

function GamepadSharedUtility.CreatePromptedBindingFooter(parentFrame, debugName)
	return CreateAndInitFromMixin(PromptedBindingFooterMixin, parentFrame, debugName);
end

local suspendFooter = nil;
local ignoreSuspendFooter = false;

local function GetOrCreateSuspendFooter()
	if not suspendFooter then
		suspendFooter = GamepadSharedUtility.CreatePromptedBindingFooter(UIParent, "SuspendFooter");
		suspendFooter:AddStandardSelectPrompt();
		suspendFooter:AddStandardBackPrompt();
		suspendFooter:Finalize();
	end

	return suspendFooter;
end

function GamepadSharedUtility.ShowSuspendFooterOnFrame(frame)
	if ignoreSuspendFooter then
		return;
	end

	local footer = GetOrCreateSuspendFooter();
	local copyFooter = parentFrameToFooterMap[frame];

	local parentFrame = frame;
	local alignmentType = PromptedBindingFooterMixin.ALIGNMENT_TYPE.LEFT;
	local overflowType = PromptedBindingFooterMixin.OVERFLOW_TYPE.EXPAND;
	local xOffset = 0;
	local yOffset = 0;
	local customAnchor;

	if copyFooter then
		parentFrame = copyFooter.parentFrame;
		alignmentType = copyFooter.alignmentType;
		overflowType = copyFooter.overflowType;
		xOffset = copyFooter.xOffset;
		yOffset = copyFooter.yOffset;
		customAnchor = copyFooter.customAnchor;
	end

	footer:SetParentFrame(parentFrame);
	footer:SetAlignmentType(alignmentType);
	footer:SetOverflowType(overflowType);
	footer:SetAnchorOffsets(xOffset, yOffset);
	footer:SetCustomAnchor(customAnchor);
	footer:ApplyInputLegendAttachment();
	footer:ShowAndActivateBindings();
end

function GamepadSharedUtility.HideSuspendFooter()
	if suspendFooter then
		suspendFooter:HideAndDeactivateBindings();
	end
end

-- Lock the footer active for cases where frame focus is not used by the frame that owns the footer; this should be rare.
function GamepadSharedUtility.ShowAndLockSuspendFooterOnFrame(frame)
	if ignoreSuspendFooter then
		return;
	end

	local footer = GetOrCreateSuspendFooter();
	footer.lockedToFrame = frame;
	GamepadSharedUtility.ShowSuspendFooterOnFrame(frame);
end

function GamepadSharedUtility.SetIgnoreSuspendFooter()
	ignoreSuspendFooter = true;
	if GamepadSharedUtility.IsSuspendFooterShown() then
		suspendFooter:HideAndDeactivateBindings();
	end
end

function GamepadSharedUtility.ClearIgnoreSuspendFooter()
	ignoreSuspendFooter = false;
end

function GamepadSharedUtility.HideAndUnlockSuspendFooter()
	if suspendFooter then
		suspendFooter.lockedToFrame = nil;
		GamepadSharedUtility.HideSuspendFooter();
	end
end

function GamepadSharedUtility.IsSuspendFooterShown()
	return suspendFooter and suspendFooter.isShown;
end

function GamepadSharedUtility.IsSuspendFooterLocked()
	return suspendFooter and suspendFooter.lockedToFrame;
end
