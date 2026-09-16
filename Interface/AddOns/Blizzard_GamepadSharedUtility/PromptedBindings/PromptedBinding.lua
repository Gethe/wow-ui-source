PromptedBindingMixin = {};

PromptedBindingMixin.VISIBILITY_TYPE =
{
	ALWAYS = 1,
	ONLY_IF_USABLE = 2,
	NEVER = 3
};

function PromptedBindingMixin:Init(keys, functions, label, debugName)
	self.keys = keys;
	self.functions = functions;
	self.label = label;
	self.labelFunction = nil;
	self.debugName = debugName and debugName or "PromptedBinding";

	-- Optional fields with defaults if applicable.
	self.buttonEventsHandled = GAMEPAD_BUTTON_ANY_DOWN;
	self.visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.ALWAYS;
	self.customDisplayKey = nil;
	self.customPromptFrame = nil;
	self.customPromptFrameOnShowPassedConditionsCallback = nil;
	self.customPromptFrameOnShowFailedConditionsCallback = nil;
	self.functionConditions = {};
	self.validButtonContexts = {};
	self.moreActionsMenuEntries = {};
	self.disallowButtonContexts = false;
	self.overboundCallbacks = {};
	self.onOpenedCallback = nil;
	self.onClosedCallback = nil;
end

-- All condition functions must return true for the binding to be usable.
function PromptedBindingMixin:AddCondition(conditionFunction)
	table.insert(self.functionConditions, conditionFunction);
end

-- A button with the matching key="buttonContext" value must be focused for this binding to be usable; if none are added, this condition is ignored.
function PromptedBindingMixin:AddButtonContext(buttonContextName)
	table.insert(self.validButtonContexts, buttonContextName);
end

-- Adds an entry that will be shown in the popup menu if this binding was created with CreateMoreActionsPromptedBinding, otherwise does nothing.
function PromptedBindingMixin:AddMoreActionsEntry(entryLabel, entryFunction, entryCondition, checkboxCheckedFunc)
	local subAction = { label = entryLabel, func = entryFunction, condition = entryCondition, isCheckedFunc = checkboxCheckedFunc };
	table.insert(self.moreActionsMenuEntries, subAction);
end

-- Adds a search-specific entry that will be shown in the popup menu if this binding was created with CreateMoreActionsPromptedBinding, otherwise does nothing.
function PromptedBindingMixin:AddMoreActionsSearchEntry(entryLabel, entryFunction, entryCondition)
	local subAction = { label = entryLabel, func = entryFunction, condition = entryCondition, isSearchEntry = true };
	table.insert(self.moreActionsMenuEntries, subAction);
end

-- Adds an entry that can switch between two labels based on a condition if this binding was created with CreateMoreActionsPromptedBinding, otherwise does nothing.
function PromptedBindingMixin:AddTwoStateMoreActionsEntry(enabledLabel, disabledLabel, toggleFunction, isEnabledFunction, entryCondition)
	local subAction = { enabledLabel = enabledLabel, disabledLabel = disabledLabel, func = toggleFunction, isEnabledFunc = isEnabledFunction, condition = entryCondition };
	table.insert(self.moreActionsMenuEntries, subAction);
end

-- Alternative means of adding a handler function, for cases where we can't declare it immediately in CreateMoreActionsPromptedBinding.
function PromptedBindingMixin:SetFunction(bindingFunction)
	self.functions = {bindingFunction};
end

function PromptedBindingMixin:SetMenuOpeningCallback(openingCallback)
	self.onOpeningCallback = openingCallback;
end

function PromptedBindingMixin:SetMenuOpenedCallback(openedCallback)
	self.onOpenedCallback = openedCallback;
end

function PromptedBindingMixin:SetMenuClosedCallback(closedCallback)
	self.onClosedCallback = closedCallback;
end

--[[
	Set this if input needs to handle press events in a non-standard way, such as triggering on release or checking both up and down events.
	Options: GAMEPAD_BUTTON_ANY_DOWN, GAMEPAD_BUTTON_ANY_UP, GAMEPAD_BUTTON_ANY_DOWN_OR_UP.
]]
function PromptedBindingMixin:SetButtonEventsHandled(events)
	self.buttonEventsHandled = events;
end

--[[
	Set the label of this prompted binding dynamically. On refresh, labelFunction will be called.
]]
function PromptedBindingMixin:SetLabelFunction(labelFunction)
	self.labelFunction = labelFunction;
end

-- Specifies a callback for when the internal function binding is overbound for one of the prompted keys.
function PromptedBindingMixin:SetOverboundCallback(key, overboundCallback)
	local keyIndex = self:GetKeyIndex(key);
	if (keyIndex) then
		self.overboundCallbacks[keyIndex] = overboundCallback;
	end
end

-- Set this if the prompt should not always be shown; by default the binding will appear grayed-out if unusable.
function PromptedBindingMixin:SetVisibilityType(visibilityType)
	self.visibilityType = visibilityType;
end

-- Assign this if we want to visualize the prompt differently than the key mapping; e.g. using the left+right icon instead of left and right separately.
function PromptedBindingMixin:SetCustomDisplayKey(key)
	self.customDisplayKey = key;
end

--[[
	Assign this if we want to use a frame/icon elsewhere in the UI to visualize this action, but still want to manage the state with this footer.

	The following optional parameters are useful for changing the visible state of the prompt frame when its condition state changes and the prompt
	has a visibilityType of always shown.

	optOnShowPassedConditionsCallback - An optional parameter that specifies a callback function to be run when the custom prompt frame is shown by
										the footer and all of the prompt's conditions have passed. The customPromptFrame will be passed in as an
										argument to this callback.

	optOnShowFailedConditionsCallback - An optional parameter that specifies a callback function to be run when the custom prompt frame is shown by
										the footer and at least one of the prompt's conditions failed. The customPromptFrame will be passed in as an
										argument to this callback.
]]
function PromptedBindingMixin:SetCustomPromptFrame(frame, optOnShowPassedConditionsCallback, optOnShowFailedConditionsCallback)
	self.customPromptFrame = frame;
	self.customPromptFrameOnShowPassedConditionsCallback = optOnShowPassedConditionsCallback;
	self.customPromptFrameOnShowFailedConditionsCallback = optOnShowFailedConditionsCallback;
end

function PromptedBindingMixin:DisallowButtonContexts()
	self.disallowButtonContexts = true;
end

function PromptedBindingMixin:GetInputIconTemplate()
	local template = nil;
	if #self.keys == 1 or self.customDisplayKey then
		template = InputPromptLegends.PromptTemplates.StandardOneIcon;
	elseif #self.keys == 2 then
		template = InputPromptLegends.PromptTemplates.StandardTwoIcon;
	end
	return template;
end

-- Returns the index of the specified key in the prompted binding's key table. If the key isn't inside of the keys table, nil is returned.
function PromptedBindingMixin:GetKeyIndex(key)
	for index, storedKey in ipairs(self.keys) do
		if (storedKey == key) then
			return index;
		end
	end
end

function PromptedBindingMixin:AreConditionsMet()
	local activeButtonContext = SmartNavigation:GetCurrentButtonContext();
	local anyButtonContextValid = false;

	if #self.validButtonContexts > 0 then
		if activeButtonContext then
			for _, buttonContext in ipairs(self.validButtonContexts) do
				if activeButtonContext == buttonContext then
					anyButtonContextValid = true;
				end
			end
		end
	else
		anyButtonContextValid = true;
	end

	if not anyButtonContextValid then
		return false;
	end

	for _, condition in ipairs(self.functionConditions) do
		if not condition() then
			return false;
		end
	end

	if self.disallowButtonContexts and SmartNavigation:GetCurrentButtonContext() then
		return false;
	end

	return true;
end

function PromptedBindingMixin:TriggerBinding(functionIndex, down)
	if self:AreConditionsMet() then
		local triggeredFunction = self.functions[functionIndex];
		if triggeredFunction then
			triggeredFunction(down);
		end
	end
end

local function GetSubActionLabel(subAction)
	if subAction.isEnabledFunc then
		return subAction.isEnabledFunc() and subAction.enabledLabel or subAction.disabledLabel;
	end

	return subAction.label;
end

local function CreateMoreActionsMenu(promptedBinding)
	local currentButton = SmartNavigation:GetCurrentButton();

	if (promptedBinding.onOpeningCallback) then
		promptedBinding:onOpeningCallback()
	end

	local menu = MenuUtil.CreateContextMenu(currentButton, function(_, rootDescription)
		rootDescription:SetTag("MORE_CONTEXT_ACTIONS");

		for _, subAction in ipairs(promptedBinding.moreActionsMenuEntries) do
			local noCondition = not subAction.condition;
			local passesCondition = subAction.condition and subAction.condition(currentButton);

			if noCondition or passesCondition then
				local label = GetSubActionLabel(subAction);
				local func = subAction.func;
				local isCheckedFunc = subAction.isCheckedFunc;
				local isSearchEntry = subAction.isSearchEntry;

				if isCheckedFunc then
					local checkbox = rootDescription:CreateCheckbox(
						label,
						isCheckedFunc,
						func,
						currentButton
					);
					checkbox:SetResponse(MenuResponse.Close);
				elseif isSearchEntry then
					rootDescription:CreateSearchEntry(label, func, currentButton);
				else
					rootDescription:CreateButton(label, func, currentButton);
				end
			end
		end
	end);

	if (promptedBinding.onOpenedCallback) then
		promptedBinding:onOpenedCallback(menu)
	end
	if promptedBinding.onClosedCallback then
		menu:SetClosedCallback(function() promptedBinding:onClosedCallback(menu); end);
	end
end

local function TapOrHoldPromptedBindingClickHandler(tapOrHoldBinding, down)
	local function OnHeld()
		if (tapOrHoldBinding.onHeld) then
			tapOrHoldBinding.onHeld();
		end

		-- Clear the timer so that we don't run a tap.
		tapOrHoldBinding.holdTimer = nil;
	end

	if (down) then
		if (tapOrHoldBinding.onDown) then
			tapOrHoldBinding.onDown();
		end

		tapOrHoldBinding.holdTimer = C_Timer.NewTimer(tapOrHoldBinding.holdTime, OnHeld);
	elseif (tapOrHoldBinding.holdTimer) then
		tapOrHoldBinding.holdTimer:Cancel();

		if (tapOrHoldBinding.onTap) then
			tapOrHoldBinding.onTap();
		end
	else
		if (tapOrHoldBinding.onHeldReleased) then
			tapOrHoldBinding.onHeldReleased();
		end
	end
end

local function TapOrHoldPromptedBindingOverbound(tapOrHoldBinding)
	if (tapOrHoldBinding.holdTimer) then
		tapOrHoldBinding.holdTimer:Cancel();
	end

	if (tapOrHoldBinding.onBindingOverbound) then
		tapOrHoldBinding.onBindingOverbound();
	end
end

function GamepadSharedUtility.CreatePromptedBinding(key, bindingFunction, label, debugName)
	return CreateAndInitFromMixin(PromptedBindingMixin, {key, nil}, {bindingFunction, nil}, label, debugName);
end

-- Use this variant if two buttons, each with their own function, should share a label, e.g. "LB/RB Zoom".
function GamepadSharedUtility.CreateDoublePromptedBinding(leftKey, rightKey, leftFunction, rightFunction, label, debugName)
	return CreateAndInitFromMixin(PromptedBindingMixin, {leftKey, rightKey}, {leftFunction, rightFunction}, label, debugName);
end

-- This is a utility variant that can be used with AddMoreActionsEntry to generate custom dropdown context menus.
function GamepadSharedUtility.CreateMoreActionsPromptedBinding(key)
	local promptedBinding = GamepadSharedUtility.CreatePromptedBinding(key, nil, CONTEXT_ACTION_LABEL_MORE_ACTIONS);
	promptedBinding:SetFunction(GenerateClosure(CreateMoreActionsMenu, promptedBinding));
	return promptedBinding;
end

--[[
	Use this variant if a button should have different logic for when it is tapped vs held.

	Params:
		- key
			The string representation of the input key that this prompted binding applies to.

		- holdTime
			The amount of time in seconds that the input key must be pressed to be considered held.

		- onTapFunction
			A function which gets called when the input key has been pressed and released before the
			holdTime has elapsed.

		- onHeldFunction
			A function which gets called when the input key is pressed and the specified holdTime has
			elapsed.

		- label
			A display string indicating what action the prompted binding is doing.

		- onDownFunction
			A function that is called when the input key is initially pressed.

		- onHeldReleasedFunction
			A function that is called after the input key is released from a held state.

		- onBindingOverboundFunction
			A function that is called when this prompted binding is replaced by another binding using the same key
			on the binding stack. This is typically used to cancel any logic / reset any flags that you may no longer
			want active since this binding will no longer recieve the released event if it was in a down state.

		- debugName
			A name used to idenitfy the binding in debug output.
]]
function GamepadSharedUtility.CreateTapOrHoldPromptedBinding(key, holdTime, onTapFunction, onHeldFunction, label, onDownFunction, onHeldReleasedFunction, onBindingOverboundFunction, debugName)
	local promptedBinding = GamepadSharedUtility.CreatePromptedBinding(key, nil, label, debugName);
	promptedBinding:SetButtonEventsHandled(GAMEPAD_BUTTON_ANY_DOWN_OR_UP);
	promptedBinding:SetFunction(GenerateClosure(TapOrHoldPromptedBindingClickHandler, promptedBinding));
	promptedBinding:SetOverboundCallback(key, GenerateFlatClosure(TapOrHoldPromptedBindingOverbound, promptedBinding));
	promptedBinding.holdTime = holdTime;
	promptedBinding.onDown = onDownFunction;
	promptedBinding.onTap = onTapFunction;
	promptedBinding.onHeld = onHeldFunction;
	promptedBinding.onHeldReleased = onHeldReleasedFunction;
	promptedBinding.onBindingOverbound = onBindingOverboundFunction;
	return promptedBinding;
end
