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

	self.bindings = GamepadMode.CreateBindingGroup(self.debugName);
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
	local functionAsPromptedBinding = GamepadSharedUtility.CreatePromptedBinding(key, func, nil);
	functionAsPromptedBinding:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.NEVER);
	table.insert(self.promptedBindings, functionAsPromptedBinding);
end

function PromptedBindingFooterMixin:AddStandardSelectPrompt(optionalLabel)
	local label = optionalLabel and optionalLabel or ACTION_LABEL_SELECT;

	-- The default "select" behavior is handled by Smart Navigation so this only adds a prompt, not a binding.
	local binding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, nil, label);
	binding:AddCondition(SmartNavigation_IsCurrentButtonClickable);
	self:AddPromptedBinding(binding);
end

function PromptedBindingFooterMixin:AddNonFallbackSelectPrompt(optionalLabel)
	local label = optionalLabel and optionalLabel or ACTION_LABEL_SELECT;

	local binding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, nil, label);
	binding:DisallowButtonContexts(); -- This variant will not be used as a fallback if we failed a more specific check on the same key.
	binding:AddCondition(SmartNavigation_IsCurrentButtonClickable);
	self:AddPromptedBinding(binding);
end

function PromptedBindingFooterMixin:AddStandardFrameControlManagerBindings(focusedFrame)
	-- Next handling is managed by FrameControlsManager. Only prompt the user.
	local nextBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_TRIGGER_RIGHT);
	GamepadMode.FrameControlsManager:RegisterJumpHintRightBinding(focusedFrame, nextBinding);
	self:AddPromptedBinding(nextBinding);

	-- Previous handling is managed by FrameControlsManager. Only prompt the user.
	local prevBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_TRIGGER_LEFT);
	GamepadMode.FrameControlsManager:RegisterJumpHintLeftBinding(focusedFrame, prevBinding);
	self:AddPromptedBinding(prevBinding);
end

function PromptedBindingFooterMixin:AddStandardBackPrompt(optionalLabel)
	local label = optionalLabel and optionalLabel or FRAME_ACTION_BACK;

	-- The default "back" behavior is handled by Smart Navigation so this only adds a prompt, not a binding.
	local binding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, nil, label);
	self:AddPromptedBinding(binding);
end

function PromptedBindingFooterMixin:SetParentFrame(parentFrame)
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
		if promptedBinding.customPromptFrame then
			promptedBinding.customPromptFrame:Hide();
		end
	end

	if self.isShown then
		for _, promptedBinding in ipairs(self.promptedBindingsActive) do
			if promptedBinding.customPromptFrame then
				promptedBinding.customPromptFrame:Show();

				if (promptedBinding:AreConditionsMet()) then
					if (promptedBinding.customPromptFrameOnShowPassedConditionsCallback) then
						promptedBinding.customPromptFrameOnShowPassedConditionsCallback(promptedBinding.customPromptFrame);
					end
				else
					if (promptedBinding.customPromptFrameOnShowFailedConditionsCallback) then
						promptedBinding.customPromptFrameOnShowFailedConditionsCallback(promptedBinding.customPromptFrame);
					end
				end
			end
		end
	end
end

function PromptedBindingFooterMixin:GeneratePromptedBindingsByKey()
	-- First, rearrange all the bindings in the key order that they should be displayed.
	local sortedBindings = {};
	for _, key in ipairs(KEYS_IN_SORT_ORDER) do
		for _, promptedBinding in ipairs(self.promptedBindings) do
			if promptedBinding.keys[1] == key then
				table.insert(sortedBindings, promptedBinding);
			end
		end
	end

	-- Then in priority order, add the bindings to a group of others with the same key.
	self.promptedBindingsByKey = {};
	for _, promptedBinding in ipairs(sortedBindings) do
		local mainKey = promptedBinding.keys[1];
		if not self.promptedBindingsByKey[mainKey] then
			self.promptedBindingsByKey[mainKey] = {};
		end
		table.insert(self.promptedBindingsByKey[mainKey], promptedBinding);
	end
end

local function GetPromptedBindingVisibility(promptedBinding)
	local vis = promptedBinding.visibilityType;
	if type(vis) == "function" then
		vis = vis();
	end
	return vis;
end

function PromptedBindingFooterMixin:GetPromptedBindingToDisplayForKey(key)
	local bindingsForKey = self.promptedBindingsByKey[key];
	if bindingsForKey then
		-- Iterate through the list of binds using this key, which is already sorted by highest priority.
		for _, promptedBinding in ipairs(bindingsForKey) do
			-- The first one that is valid will always be what we want to show.
			if promptedBinding:AreConditionsMet() then
				return promptedBinding;
			end
		end

		-- If none are available, again going by priority find the first one that should show while unavailable.
		for _, promptedBinding in ipairs(bindingsForKey) do
			if GetPromptedBindingVisibility(promptedBinding) == PromptedBindingMixin.VISIBILITY_TYPE.ALWAYS then
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

		-- When initializing, add a frame action for each possible key; it doesn't matter which one, the slot will be updated dynamically afterward.
		for _, key in ipairs(KEYS_IN_SORT_ORDER) do
			local promptedBindings = self.promptedBindingsByKey[key]; -- Use a lookup because values in this table will not be iterated in sort order.
			if promptedBindings then
				local promptedBinding = promptedBindings[1];
				local template = promptedBinding:GetInputIconTemplate();
				if template then
					local id = self.debugName .. key;
					local keys = promptedBinding.customDisplayKey and {promptedBinding.customDisplayKey} or promptedBinding.keys;
					local label = promptedBinding.labelFunction and promptedBinding.labelFunction() or promptedBinding.label;
					local frameAction = InputPromptLegends.CreateFrameAction(id, template, keys, label);
					frameAction:SetDividerType(GAMEPAD_PROMPT_DIVIDER_SLASH);
					self.inputLegend:AddFrameAction(frameAction);
				end
			end
		end
		self.inputLegend:InitializePrompts();
	end

	-- Generate the data we need to 1) find each frame action we need to update and 2) replace content on that frame action.
	local promptedBindingsInFooter = {};
	for _, promptedBinding in ipairs(self.promptedBindingsActive) do
		local inFooter = not promptedBinding.customPromptFrame;
		local vis = GetPromptedBindingVisibility(promptedBinding);
		local shown = (promptedBinding:AreConditionsMet() and vis ~= PromptedBindingMixin.VISIBILITY_TYPE.NEVER) or
					  (vis == PromptedBindingMixin.VISIBILITY_TYPE.ALWAYS);
		if inFooter and shown then
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
	local needsToReactivateBindings = self.isShown;
	if needsToReactivateBindings then
		GamepadMode.DeactivateBindingGroup(self.bindings);
	end

	GamepadMode.UncacheBindingGroup(self.bindings);
	self.bindings = GamepadMode.CreateBindingGroup(self.debugName);

	for _, promptedBinding in ipairs(self.promptedBindingsActive) do
		-- A single prompt can visualize two different actions at the same time, e.g. LB/RB callouts, but they need to be bound separately.
		for index = 1, 2 do
			local key = promptedBinding.keys[index];
			if key and promptedBinding.functions[index] then
				local buttonEvents = promptedBinding.buttonEventsHandled;
				local overboundCallback = promptedBinding.overboundCallbacks[index];

				--[[
					TODO for future us: Prompted bindings need to wrap TriggerBinding, 
					and handle button up _and_ down events regardless of trigger conditions, so that
					the prompts can react to the appropriate up and down.

					TriggerBinding should only be called based on binding configuration (i.e. not 
					necessarily all buttonEvents, but the input prompt must be notified of all
					up and down events).
				]]
				self.bindings:AddFunctionBinding(key, GenerateClosure(PromptedBindingMixin.TriggerBinding, promptedBinding, index), buttonEvents, overboundCallback);
			end
		end
	end

	if needsToReactivateBindings then
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
		GamepadMode.ActivateBindingGroup(self.bindings);
		EventRegistry:RegisterCallback("Gamepad.RefreshFrameFocus", self.Refresh, self);
		SmartNavigation:RegisterCallback("SelectedButtonUpdated", GenerateClosure(self.Refresh, self), self);
		SmartNavigation:RegisterCallback("SelectedButtonEnabledStateChanged", GenerateClosure(self.Refresh, self), self);
		self:Refresh();
	end
end

function PromptedBindingFooterMixin:HideAndDeactivateBindings()
	if self.isShown then
		self.isShown = false;
		GamepadMode.DeactivateBindingGroup(self.bindings);
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
