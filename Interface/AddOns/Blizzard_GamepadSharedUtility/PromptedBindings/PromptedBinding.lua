PromptedBindingMixin = {};

PromptedBindingMixin.VISIBILITY_TYPE =
{
	ALWAYS = 1, -- Prompt frame is always shown but will be greyed out if unusuable
	ONLY_IF_USABLE = 2, -- Prompt frame will not be shown if unusable
	NEVER = 3, -- Prompt frame is never shown
};

function PromptedBindingMixin:Init(keys, debugName, overboundCallbacks)
	self.keys = keys;
	self.debugName = debugName;
	self.overboundCallbacks = overboundCallbacks or {};
	self.displayKeys = keys;

	self.footerBinding = {};
	self.footerBinding.moreActionsMenuEntries = {};

	self.customPromptFrames = {};

	-- For compatibility until callsites are updated
	self.footerBinding.customPromptFrame = {};
end

local function AddOrSetTable(tbl, opts, opt, alwaysSet)
	local field = opts[opt];
	if not field then
		if alwaysSet then
			tbl[opt] = tbl[opt] or {};
		end
		return;
	end

	if type(field) ~= "table" then
		tbl[opt] = {};
		table.insert(tbl[opt], field);
	else
		tbl[opt] = field;
	end
end

local function ApplyOpts(tbl, opts)
	tbl.visibilityType = opts.visibilityType or PromptedBindingMixin.VISIBILITY_TYPE.ALWAYS;

	AddOrSetTable(tbl, opts, "buttonContexts", true);
	AddOrSetTable(tbl, opts, "conditions", true);
end

local function ApplyFooterOpts(tbl, opts)
	tbl.label = opts.label;

	AddOrSetTable(tbl, opts, "displayKeys");
end

local function ApplyCustomPromptOpts(tbl, opts)
	tbl.frame = opts.frame;
	tbl.onShowPassed = opts.onShowPassed;
	tbl.onShowFailed = opts.onShowFailed;
end

local function ApplyBindingFunctionOpts(tbl, opts)
	tbl.buttonUpDown = opts.buttonUpDown or GAMEPAD_BUTTON_ANY_DOWN;

	AddOrSetTable(tbl, opts, "bindingFunctions");
end

local function ApplyHoldFunctionOpts(tbl, opts)
	tbl.buttonUpDown = GAMEPAD_BUTTON_ANY_DOWN_OR_UP;
	tbl.holdTimer = {};

	AddOrSetTable(tbl, opts, "holdTime", true);
	AddOrSetTable(tbl, opts, "onDown");
	AddOrSetTable(tbl, opts, "onTap");
	AddOrSetTable(tbl, opts, "onHeld");
	AddOrSetTable(tbl, opts, "onHeldReleased");
end

local function IsConditionMet(footerOrCustomPrompt, activeButtonContext)
	if footerOrCustomPrompt.visibilityType == nil then
		-- No binding exists in this table
		return false;
	end

	local anyButtonContextValid = true;
	if #footerOrCustomPrompt.buttonContexts > 0 then
		anyButtonContextValid = false;
		if activeButtonContext then
			for _, buttonContext in ipairs(footerOrCustomPrompt.buttonContexts) do
				if activeButtonContext == buttonContext then
					anyButtonContextValid = true;
					break;
				end
			end
		end
	end

	if not anyButtonContextValid then
		return false;
	end

	for _, condition in ipairs(footerOrCustomPrompt.conditions) do
		if not condition() then
			return false;
		end
	end

	return true;
end

local function GetSubActionLabel(subAction)
	if subAction.isEnabledFunc then
		return subAction.isEnabledFunc() and subAction.enabledLabel or subAction.disabledLabel;
	end

	return subAction.label;
end

local function GetMoreActionsMenuOwnerRegion(promptedBinding, currentButton)
	local ownerRegion = promptedBinding.moreActionsMenuOwnerRegion;
	if type(ownerRegion) == "function" then
		ownerRegion = ownerRegion();
	end
	return ownerRegion or currentButton;
end

local function CreateMoreActionsMenu(promptedBinding)
	local entries = promptedBinding.footerBinding.moreActionsMenuEntries;
	if #entries == 0 then
		return;
	end

	local currentButton = SmartNavigation:GetCurrentButton();
	local ownerRegion = GetMoreActionsMenuOwnerRegion(promptedBinding, currentButton);

	if promptedBinding.onOpeningCallback then
		promptedBinding:onOpeningCallback()
	end

	local menu = MenuUtil.CreateContextMenu(ownerRegion, function(_, rootDescription)
		rootDescription:SetTag("MORE_CONTEXT_ACTIONS");

		for _, subAction in ipairs(entries) do
			local noCondition = not subAction.condition;
			local passesCondition = subAction.condition and subAction.condition(currentButton);

			if noCondition or passesCondition then
				local label = GetSubActionLabel(subAction);
				local func = subAction.func;
				local isCheckedFunc = subAction.isCheckedFunc;
				local isSearchEntry = subAction.isSearchEntry;
				local isRedEntry = subAction.isRedEntry;

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
				elseif isRedEntry then
					rootDescription:CreateRedHighlightButton(label, func, currentButton);
				else
					rootDescription:CreateButton(label, func, currentButton);
				end
			end
		end
	end);

	if promptedBinding.onOpenedCallback then
		promptedBinding:onOpenedCallback(menu)
	end

	if promptedBinding.onClosedCallback then
		menu:SetClosedCallback(function()
			promptedBinding:onClosedCallback(menu);
		end);
	end
end

local function ShouldHandleUpDown(buttonUpDown, down)
	if down then
		if (buttonUpDown == GAMEPAD_BUTTON_ANY_DOWN) or (buttonUpDown == GAMEPAD_BUTTON_ANY_DOWN_OR_UP) then
			return true;
		end
		return false;
	end

	if (buttonUpDown == GAMEPAD_BUTTON_ANY_UP) or (buttonUpDown == GAMEPAD_BUTTON_ANY_DOWN_OR_UP) then
		return true;
	end
	return false;
end

local function HandleHoldBinding(binding, keyIndex, down, onTapCond)
	local function OnHeld()
		local onHeld = binding.onHeld and binding.onHeld[keyIndex];
		if onHeld then
			onHeld();
		end

		binding.holdTimer[keyIndex] = nil;
	end

	if (down) then
		local onDown = binding.onDown and binding.onDown[keyIndex];
		if onDown then
			onDown();
		end

		binding.holdTimer[keyIndex] = C_Timer.NewTimer(binding.holdTime[keyIndex], OnHeld);
	elseif (binding.holdTimer[keyIndex]) then
		binding.holdTimer[keyIndex]:Cancel();

		local onTap = binding.onTap and binding.onTap[keyIndex];
		if onTap and onTapCond() then
			onTap();
		end
	else
		local onHeldReleased = binding.onHeldReleased and binding.onHeldReleased[keyIndex];
		if onHeldReleased then
			onHeldReleased();
		end
	end
end

local function HandleBinding(binding, keyIndex, down)
	local triggeredFunction = binding.bindingFunctions and binding.bindingFunctions[keyIndex];
	if not triggeredFunction then
		return;
	end

	if not ShouldHandleUpDown(binding.buttonUpDown, down) then
		return;
	end

	triggeredFunction(down);
end

local function GetVisibility(binding)
	local vis = binding.visibilityType;
	if vis and type(vis) == "function" then
		vis = vis();
	end
	return vis;
end

--[[
	opts:
		label: string or function for the footer label

		visibilityType: One of `PromptedBindingMixin.VISIBILITY_TYPE`

		buttonContexts: A button with a matching `key="buttonContext"` value must be focused for the binding to be usable

		conditions: Table of condition functions where all must return `true` for the binding to be usable

		displayKeys: Table of InputIconTexture `GAMEPAD_*` constants to use for the prompt visual for each key otherwise uses the key mapping
					 itself for the visual
]]
function PromptedBindingMixin:AddFooterBinding(opts)
	opts = opts or {};
	ApplyOpts(self.footerBinding, opts);
	ApplyFooterOpts(self.footerBinding, opts);
end

--[[
	Utility variant that can be used with `AddMoreActionsEntry` to generate custom dropdown context menus.

	opts:
		label: string or function for the footer label otherwise `CONTEXT_ACTION_LABEL_MORE_ACTIONS`

		visibilityType: One of `PromptedBindingMixin.VISIBILITY_TYPE`

		buttonContexts: A button with a matching `key="buttonContext"` value must be focused for the binding to be usable

		conditions: Table of condition functions where all must return `true` for the binding to be usable

		displayKeys: Table of InputIconTexture `GAMEPAD_*` constants to use for the prompt visual for each key otherwise uses the key mapping
		itself for the visual
]]
function PromptedBindingMixin:AddMoreActionsFooterBinding(opts)
	opts = opts or {};
	opts.label = opts.label or CONTEXT_ACTION_LABEL_MORE_ACTIONS;
	self:AddFooterBinding(opts);
end

--[[
	opts:
		buttonUpDown: One of `GAMEPAD_BUTTON_ANY_DOWN`, `GAMEPAD_BUTTON_ANY_UP` or `GAMEPAD_BUTTON_ANY_DOWN_OR_UP`

		bindingFunctions: Table of function(isDown) for each key
						  Example: { function(isDown) end, function(isDown) end, } for multiple keys
]]
function PromptedBindingMixin:AddFooterFunction(opts)
	opts = opts or {};
	ApplyBindingFunctionOpts(self.footerBinding, opts);
end

--[[
	opts:
		holdTime: Table of seconds for each key's hold time

		onDown: Table of functions for each key which gets called when the key is first pressed

		onTap: Table of functions for each key which gets called when the key is pressed and released before the holdTime has elapsed

		onHeld: Table of functions for each key which gets called when the key is pressed and the holdTime has elapsed

		onHeldReleased: Table of functions for each key which gets called when the key is released from an elapsed held state
]]
function PromptedBindingMixin:AddFooterHoldFunction(opts)
	opts = opts or {};
	ApplyHoldFunctionOpts(self.footerBinding, opts);
end

--[[
	opts:
		visibilityType: One of `PromptedBindingMixin.VISIBILITY_TYPE`

		buttonContexts: A button with a matching `key="buttonContext"` value must be focused for the binding to be usable

		conditions: Table of condition functions where all must return `true` for the binding to be usable

		frame: The frame to show and hide for this binding

		onShowPassed: function (customPromptFrame) callback when the prompt frame passes the show condition while the legend is shown

		onShowFailed: function (customPromptFrame) callback when the prompt frame fails the show condition while the legend is shown
]]
function PromptedBindingMixin:AddCustomPromptBinding(opts)
	table.insert(self.customPromptFrames, {});
	local promptFrame = self.customPromptFrames[#self.customPromptFrames];
	opts = opts or {};
	ApplyOpts(promptFrame, opts);
	ApplyCustomPromptOpts(promptFrame, opts);
	return promptFrame;
end

--[[
	customPrompt: Return value from `AddCustomPromptBinding`

	opts:
		buttonUpDown: One of `GAMEPAD_BUTTON_ANY_DOWN`, `GAMEPAD_BUTTON_ANY_UP` or `GAMEPAD_BUTTON_ANY_DOWN_OR_UP`

		bindingFunctions: Table of function(isDown) for each key
		Example: { function(isDown) end, function(isDown) end, } for multiple keys
]]
function PromptedBindingMixin:AddCustomPromptFunction(customPrompt, opts)
	opts = opts or {};
	ApplyBindingFunctionOpts(customPrompt, opts);
end

--[[
	customPrompt: Return value from `AddCustomPromptBinding`

	opts:
		holdTime: Table of seconds for each key's hold time

		onDown: Table of functions for each key which gets called when the key is first pressed

		onTap: Table of functions for each key which gets called when the key is pressed and released before the holdTime has elapsed

		onHeld: Table of functions for each key which gets called when the key is pressed and the holdTime has elapsed

		onHeldReleased: Table of functions for each key which gets called when the key is released from an elapsed held state
]]
function PromptedBindingMixin:AddCustomPromptHoldFunction(customPrompt, opts)
	opts = opts or {};
	ApplyHoldFunctionOpts(customPrompt, opts);
end

-- Adds an entry that will be shown in the popup menu
function PromptedBindingMixin:AddMoreActionsEntry(entryLabel, entryFunction, entryCondition, checkboxCheckedFunc)
	local subAction = {
		label = entryLabel,
		func = entryFunction,
		condition = entryCondition,
		isCheckedFunc = checkboxCheckedFunc
	};
	table.insert(self.footerBinding.moreActionsMenuEntries, subAction);
end

-- Adds a search-specific entry that will be shown in the popup menu
function PromptedBindingMixin:AddMoreActionsSearchEntry(entryLabel, entryFunction, entryCondition)
	local subAction = {
		label = entryLabel,
		func = entryFunction,
		condition = entryCondition,
		isSearchEntry = true
	};
	table.insert(self.footerBinding.moreActionsMenuEntries, subAction);
end

-- Adds an red text + red highlight entry that will be shown in the popup menu if this binding was created with CreateMoreActionsPromptedBinding, otherwise does nothing.
function PromptedBindingMixin:AddMoreActionsRedEntry(entryLabel, entryFunction, entryCondition)
	local subAction = { label = entryLabel, func = entryFunction, condition = entryCondition, isRedEntry = true };
	table.insert(self.footerBinding.moreActionsMenuEntries, subAction);
end

-- Adds an entry that can switch between two labels based on a condition
function PromptedBindingMixin:AddTwoStateMoreActionsEntry(enabledLabel, disabledLabel, toggleFunction, isEnabledFunction, entryCondition)
	local subAction = {
		enabledLabel = enabledLabel,
		disabledLabel = disabledLabel,
		func = toggleFunction,
		isEnabledFunc = isEnabledFunction,
		condition = entryCondition
	};
	table.insert(self.footerBinding.moreActionsMenuEntries, subAction);
end

-- ownerRegionOrGetter: A frame, or a function returning a frame, to use as the context menu's owner region instead of the focused button.
function PromptedBindingMixin:SetMoreActionsMenuOwnerRegion(ownerRegionOrGetter)
	self.moreActionsMenuOwnerRegion = ownerRegionOrGetter;
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

function PromptedBindingMixin:GetInputIconTemplate()
	local template = nil;
	if #self.keys == 1 then
		template = InputPromptLegends.PromptTemplates.StandardOneIcon;
	elseif #self.keys == 2 then
		template = InputPromptLegends.PromptTemplates.StandardTwoIcon;
	end
	return template;
end

function PromptedBindingMixin:GetKeyForIndex(index)
	return self.keys[index];
end

function PromptedBindingMixin:GetDisplayKeys()
	return self.displayKeys;
end

function PromptedBindingMixin:HasFooterBinding()
	return (self.footerBinding.visibilityType ~= nil) and not (self.footerBinding.customPromptFrame.frame);
end

function PromptedBindingMixin:GetFooterBindingVisibility()
	return GetVisibility(self.footerBinding);
end

function PromptedBindingMixin:IsAnyBindingAlwaysVisible()
	local footerVis = GetVisibility(self.footerBinding);
	if footerVis and (footerVis == PromptedBindingMixin.VISIBILITY_TYPE.ALWAYS) then
		return true;
	end

	for _, customPromptFrame in ipairs(self.customPromptFrames) do
		local customPromptVis = GetVisibility(customPromptFrame);
		if customPromptVis and (customPromptVis == PromptedBindingMixin.VISIBILITY_TYPE.ALWAYS) then
			return true;
		end
	end

	return false;
end

function PromptedBindingMixin:GetFooterBindingLabel()
	local label = self.footerBinding.label;
	if label and type(label) == "function" then
		label = label();
	end
	return label;
end

function PromptedBindingMixin:ShouldShowFooterBinding()
	if not self:HasFooterBinding() then
		return false;
	end

	local vis = self:GetFooterBindingVisibility();
	if vis == PromptedBindingMixin.VISIBILITY_TYPE.ALWAYS then
		return true;
	end

	if self:IsFooterConditionMet() and (vis ~= PromptedBindingMixin.VISIBILITY_TYPE.NEVER) then
		return true;
	end

	return false;
end

function PromptedBindingMixin:SetCustomPromptFrameShown(shouldShow)
	if not shouldShow then
		-- Compat custom prompt frame support until callsites are updated
		local frame = self.footerBinding.customPromptFrame.frame;
		if frame then
			frame:Hide();
		end

		for _, customPromptFrame in ipairs(self.customPromptFrames) do
			customPromptFrame.frame:Hide();
		end

		return;
	end

	-- Compat custom prompt frame support until callsites are updated
	do
		local frame = self.footerBinding.customPromptFrame.frame;
		if frame then
			frame:Show();
		end

		if self:IsFooterConditionMet() then
			if self.footerBinding.customPromptFrame.OnShowPassedConditionsCallback then
				self.footerBinding.customPromptFrame.OnShowPassedConditionsCallback(self.footerBinding.customPromptFrame.frame);
			end
		else
			if self.footerBinding.customPromptFrame.OnShowFailedConditionsCallback then
				self.footerBinding.customPromptFrame.OnShowFailedConditionsCallback(self.footerBinding.customPromptFrame.frame);
			end
		end
	end

	local activeButtonContext = SmartNavigation:GetCurrentButtonContext();
	for _, customPromptFrame in ipairs(self.customPromptFrames) do
		local vis = GetVisibility(customPromptFrame);
		local canShow = (vis == PromptedBindingMixin.VISIBILITY_TYPE.ALWAYS) or
			(IsConditionMet(customPromptFrame, activeButtonContext) and (vis ~= PromptedBindingMixin.VISIBILITY_TYPE.NEVER));

		if canShow then
			customPromptFrame.frame:Show();
			if customPromptFrame.onShowPassed then
				customPromptFrame.onShowPassed(customPromptFrame.frame);
			end
		else
			customPromptFrame.frame:Hide();
			if customPromptFrame.onShowFailed then
				customPromptFrame.onShowFailed(customPromptFrame.frame);
			end
		end
	end
end

function PromptedBindingMixin:IsFooterConditionMet()
	local activeButtonContext = SmartNavigation:GetCurrentButtonContext();
	return IsConditionMet(self.footerBinding, activeButtonContext);
end

function PromptedBindingMixin:IsAnyConditionMet()
	local activeButtonContext = SmartNavigation:GetCurrentButtonContext();

	if IsConditionMet(self.footerBinding, activeButtonContext) then
		return true;
	end

	for _, customPromptFrame in ipairs(self.customPromptFrames) do
		if IsConditionMet(customPromptFrame, activeButtonContext) then
			return true;
		end
	end

	return false;
end

function PromptedBindingMixin:RequireTriggerBinding()
	if self.footerBinding.bindingFunctions or (#self.footerBinding.moreActionsMenuEntries > 0) or self.footerBinding.holdTime then
		return true;
	end

	for _, customPromptFrame in ipairs(self.customPromptFrames) do
		if customPromptFrame.bindingFunctions or customPromptFrame.holdTime then
			return true;
		end
	end

	return false;
end

function PromptedBindingMixin:TriggerBinding(keyIndex, down)
	local activeButtonContext = SmartNavigation:GetCurrentButtonContext();
	local footerCondMet = IsConditionMet(self.footerBinding, activeButtonContext);

	if footerCondMet then
		if down then
			CreateMoreActionsMenu(self);
		end
		if self.footerBinding.holdTime ~= nil then
			HandleHoldBinding(self.footerBinding, keyIndex, down, function() return true; end);
		else
			HandleBinding(self.footerBinding, keyIndex, down);
		end
	end

	local function CustomPromptTapCond()
		-- Link the onTap handler to the footer condition if we have a footer with no handlers.
		-- If we only have a custom prompt then the onTap handler is implicitly implied to be attached to that prompt frame,
		-- otherwise it is applied to the footer prompt.
		if self:HasFooterBinding() then
			local haveFooterBindingFunc = (self.footerBinding.bindingFunctions and self.footerBinding.bindingFunctions[keyIndex]) or
				self.footerBinding.holdTime ~= nil;
			return haveFooterBindingFunc or footerCondMet;
		end

		return true;
	end

	for _, customPromptFrame in ipairs(self.customPromptFrames) do
		if IsConditionMet(customPromptFrame, activeButtonContext) then
			if customPromptFrame.holdTime ~= nil then
				HandleHoldBinding(customPromptFrame, keyIndex, down, CustomPromptTapCond);
			else
				HandleBinding(customPromptFrame, keyIndex, down);
			end
		end
	end
end

function PromptedBindingMixin:OnOverbound(keyIndex)
	if self.footerBinding.holdTimer then
		local timer = self.footerBinding.holdTimer[keyIndex];
		if timer then
			timer:Cancel();
			self.footerBinding.holdTimer[keyIndex] = nil;
		end
	end

	for _, customPromptFrame in ipairs(self.customPromptFrames) do
		if customPromptFrame.holdTimer then
			local timer = customPromptFrame.holdTimer[keyIndex];
			if timer then
				timer:Cancel();
				customPromptFrame.holdTimer[keyIndex] = nil;
			end
		end
	end

	local overboundCallback = self.overboundCallbacks[keyIndex];
	if overboundCallback then
		overboundCallback();
	end
end


--[[
	overboundCallbacks: Table of functions for each key that is called when the prompted binding is replaced by another
						binding using the same key on the binding stack.
]]
function GamepadSharedUtility.CreateExtensiblePromptedBinding(keys, debugName, overboundCallbacks)
	assert((debugName ~= nil) and (type(debugName) == "string"));

	if type(keys) ~= "table" then
		keys = { keys };
	end

	if (overboundCallbacks ~= nil) and (type(overboundCallbacks) ~= "table") then
		overboundCallbacks = { overboundCallbacks };
	end

	return CreateAndInitFromMixin(PromptedBindingMixin, keys, debugName, overboundCallbacks);
end

function GamepadSharedUtility.CreatePromptedBinding(key, bindingFunction, label, debugName)
	if type(bindingFunction) == "string" then
		return GamepadSharedUtility.CreateExtensiblePromptedBinding(key, bindingFunction, label);
	end
	local promptedBinding = GamepadSharedUtility.CreateExtensiblePromptedBinding(key, debugName or "PromptedBinding");
	promptedBinding:AddFooterBinding({ label = label });
	promptedBinding:AddFooterFunction({ bindingFunctions = bindingFunction });
	return promptedBinding;
end

-- COMPAT API --

function PromptedBindingMixin:SetLabelFunction(labelFunction)
	self.footerBinding.label = labelFunction;
end

function PromptedBindingMixin:SetVisibilityType(visibilityType)
	self.footerBinding.visibilityType = visibilityType;
end

function PromptedBindingMixin:AddButtonContext(buttonContextName)
	table.insert(self.footerBinding.buttonContexts, buttonContextName);
end

function PromptedBindingMixin:AddCondition(conditionFunction)
	table.insert(self.footerBinding.conditions, conditionFunction);
end

function PromptedBindingMixin:SetCustomDisplayKey(key)
	self.footerBinding.displayKeys = {};
	table.insert(self.footerBinding.displayKeys, key);
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
	self.footerBinding.customPromptFrame.frame = frame;
	self.footerBinding.customPromptFrame.OnShowPassedConditionsCallback = optOnShowPassedConditionsCallback;
	self.footerBinding.customPromptFrame.OnShowFailedConditionsCallback = optOnShowFailedConditionsCallback;
end

function PromptedBindingMixin:SetButtonEventsHandled(events)
	self.footerBinding.buttonUpDown = events;
end

function GamepadSharedUtility.CreateDoublePromptedBinding(leftKey, rightKey, leftFunction, rightFunction, label, debugName)
	local promptedBinding = GamepadSharedUtility.CreateExtensiblePromptedBinding({ leftKey, rightKey }, debugName or "DoublePromptedBinding");
	promptedBinding:AddFooterBinding({ label = label });
	promptedBinding:AddFooterFunction({ bindingFunctions = { leftFunction, rightFunction } });
	return promptedBinding;
end

function GamepadSharedUtility.CreateTapOrHoldPromptedBinding(key, holdTime, onTapFunction, onHeldFunction, label, onDownFunction, onHeldReleasedFunction, onBindingOverboundFunction, debugName)
	local promptedBinding = GamepadSharedUtility.CreateExtensiblePromptedBinding(key,
																				 debugName or "TapOrHoldPromptedBinding",
																				 onBindingOverboundFunction);
	promptedBinding:AddFooterBinding({ label = label });
	promptedBinding:AddFooterHoldFunction({
		holdTime = holdTime,
		onDown = onDownFunction,
		onTap = onTapFunction,
		onHeld = onHeldFunction,
		onHeldReleased = onHeldReleasedFunction,
	});
	return promptedBinding;
end

function GamepadSharedUtility.CreateMoreActionsPromptedBinding(key)
	local promptedBinding = GamepadSharedUtility.CreateExtensiblePromptedBinding(key, "MoreActionsPromptedBinding");
	promptedBinding:AddMoreActionsFooterBinding();
	return promptedBinding;
end
