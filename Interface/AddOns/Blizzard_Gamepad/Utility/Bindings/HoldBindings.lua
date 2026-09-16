--[[
	Interface for handling the propagation and querying of the state of
	gamepad-considered modifier keys.
]]
local inputModifierCallbacksFrame = Mixin(CreateFrame("Frame"), CallbackRegistryMixin);
inputModifierCallbacksFrame:GenerateCallbackEvents(
{
	"InputModifierStateChanged",
	"CrossBarModifierStateChanged",
	"TargetModifierChanged",
	"TargetModifierStateChanged",
	"TargetModifierStateCancelled",
	"TargetModifierVisualStateChanged",
});
inputModifierCallbacksFrame.OnLoad(inputModifierCallbacksFrame);

-- Note: Used as bit flags
GamepadTargetingState = {
	NONE = 0,
	HOSTILE = 1,
	FRIENDLY = 2,
	BOTH = 3,
};

-- Internal state variables
local inputModifierDown = false;
local targetingModifiersDown = GamepadTargetingState.NONE;
local targetingModifierActive = GamepadTargetingState.NONE;
local targetingModifierVisualState = GamepadTargetingState.NONE;
local overrideAllowLeftRightModifiers = false;
local targetModifierVisualDelayTimer = nil;

-- Input Modifier state registry ---------------
function GamepadMode.RegisterInputModifierStateChangeCallback(callback, owner)
	inputModifierCallbacksFrame:RegisterCallback("InputModifierStateChanged", callback, owner);
end
function GamepadMode.UnregisterInputModifierStateChangeCallback(owner)
	inputModifierCallbacksFrame:UnregisterCallback("InputModifierStateChanged", owner);
end

-- Target modifier state registry --------------

-- Triggered when the active targeting mode has changed.
function GamepadMode.RegisterTargetModifierStateChanged(callback, owner)
	inputModifierCallbacksFrame:RegisterCallback("TargetModifierStateChanged", callback, owner);
end
function GamepadMode.UnregisterTargetModifierStateChanged(owner)
	inputModifierCallbacksFrame:UnregisterCallback("TargetModifierStateChanged", owner);
end

-- Triggered when the active target mode has been cancelled, typically due to the HUD modifier having been triggered.
function GamepadMode.RegisterTargetModifierStateCancelled(callback, owner)
	inputModifierCallbacksFrame:RegisterCallback("TargetModifierStateCancelled", callback, owner);
end

function GamepadMode.UnregisterTargetModifierStateCancelled(owner)
	inputModifierCallbacksFrame:UnregisterCallback("TargetModifierStateCancelled", owner);
end

-- Triggered after a short delay after a new targeting state has become active.
function GamepadMode.RegisterTargetModifierVisualStateChanged(callback, owner)
	inputModifierCallbacksFrame:RegisterCallback("TargetModifierVisualStateChanged", callback, owner);
end

function GamepadMode.UnregisterTargetModifierVisualStateChanged(owner)
	inputModifierCallbacksFrame:UnregisterCallback("TargetModifierVisualStateChanged", owner);
end

-- Triggered whenever a targeting modifier is pressed or released, regardless of whether it became active.
function GamepadMode.RegisterTargetModifierChanged(callback, owner)
	inputModifierCallbacksFrame:RegisterCallback("TargetModifierChanged", callback, owner);
end

function GamepadMode.UnregisterTargetModifierChanged(owner)
	inputModifierCallbacksFrame:UnregisterCallback("TargetModifierChanged", owner);
end

-- Crossbar modifier state registry -------------
function GamepadMode.RegisterCrossBarModifierStateChanged(callback, owner)
	inputModifierCallbacksFrame:RegisterCallback("CrossBarModifierStateChanged", callback, owner);
end
function GamepadMode.UnregisterCrossBarModifierStateChanged(owner)
	inputModifierCallbacksFrame:UnregisterCallback("CrossBarModifierStateChanged", owner);
end

-- Binding.xml handlers -------------------------
function GamepadMode.OnHUDBindingModifierChanged(down)
	local treatModifierAsToggle = CVarCallbackRegistry:GetCVarValueBool("GamepadHudModifierUsesToggle");
	if treatModifierAsToggle then
		if down then
			GamepadMode.SetHUDBindingModifier(not GamepadMode.IsHUDBindingModifierDown());
		end
	else
		GamepadMode.SetHUDBindingModifier(down);
	end
end

function GamepadMode.SetHUDBindingModifier(down)
	if inputModifierDown == down then
		return;
	end

	if down and not GamepadSharedUtility.InputBindingManager:IsOnlyCoreBindingSetActive() then
		return;
	end

	inputModifierDown = down;
	inputModifierCallbacksFrame:TriggerEvent("InputModifierStateChanged", down);
end

function GamepadMode.GetLeftTargetModifierFlag()
	return CVarCallbackRegistry:GetCVarValueBool("GamepadSwapTargetModifiers") and GamepadTargetingState.HOSTILE or GamepadTargetingState.FRIENDLY;
end

function GamepadMode.GetRightTargetModifierFlag()
	return CVarCallbackRegistry:GetCVarValueBool("GamepadSwapTargetModifiers") and GamepadTargetingState.FRIENDLY or GamepadTargetingState.HOSTILE;
end

function GamepadMode.OnLeftTargetModifierChanged(down)
	GamepadMode.OnTargetModifierChanged(GamepadMode.GetLeftTargetModifierFlag(), down);
end

function GamepadMode.OnRightTargetModifierChanged(down)
	GamepadMode.OnTargetModifierChanged(GamepadMode.GetRightTargetModifierFlag(), down);
end

function GamepadMode.OnTargetModifierChanged(flag, down)
	local treatModifierAsToggle = CVarCallbackRegistry:GetCVarValueBool("GamepadHudModifierUsesToggle");
	if treatModifierAsToggle then
		if down then
			GamepadMode.SetTargetModifier(flag, not GamepadMode.IsTargetingModifierDown(flag));
		end
	else
		GamepadMode.SetTargetModifier(flag, down);
	end

	inputModifierCallbacksFrame:TriggerEvent("TargetModifierChanged", flag, down);
end

function GamepadMode.SetTargetModifier(flag, down)
	if bit.band(targetingModifiersDown, flag) == (down and flag or 0) then
		return;
	end

	if down and not GamepadSharedUtility.InputBindingManager:IsOnlyCoreBindingSetActive() then
		return;
	end

	if down then
		targetingModifiersDown = bit.bor(targetingModifiersDown, flag);
	else
		targetingModifiersDown = bit.band(targetingModifiersDown, bit.bnot(flag));
	end

	-- Track a delayed "visual" state to allow rapid tab targeting without updating UI.
	local isOnlyFriendly = targetingModifiersDown == GamepadTargetingState.FRIENDLY;
	local isOnlyHostile = targetingModifiersDown == GamepadTargetingState.HOSTILE;

	if down and (isOnlyFriendly or isOnlyHostile) then
		targetingModifierActive = flag;
		inputModifierCallbacksFrame:TriggerEvent("TargetModifierStateChanged", targetingModifierActive);

		local function ApplyVisualState()
			targetingModifierVisualState = targetingModifierActive;
			inputModifierCallbacksFrame:TriggerEvent("TargetModifierVisualStateChanged", targetingModifierActive);
		end

		local updateImmediately = CVarCallbackRegistry:GetCVarValueBool("GamepadHudModifierUsesToggle");
		if updateImmediately then
			ApplyVisualState();
		else
			targetModifierVisualDelayTimer = C_Timer.NewTimer(CVarCallbackRegistry:GetCVarNumberOrDefault("GamepadTargetingModifierVisualDelay"), function()
				ApplyVisualState();
			end);
		end
	elseif targetingModifierActive ~= GamepadTargetingState.NONE then
		if targetModifierVisualDelayTimer then
			targetModifierVisualDelayTimer:Cancel();
			targetModifierVisualDelayTimer = nil;
		end

		local previousState = targetingModifierActive;
		targetingModifierActive = GamepadTargetingState.NONE;
		targetingModifierVisualState = GamepadTargetingState.NONE;

		if down then
			inputModifierCallbacksFrame:TriggerEvent("TargetModifierStateCancelled", previousState);
		else
			inputModifierCallbacksFrame:TriggerEvent("TargetModifierStateChanged", GamepadTargetingState.NONE);
		end

		inputModifierCallbacksFrame:TriggerEvent("TargetModifierVisualStateChanged", GamepadTargetingState.NONE);
	end

	if down and targetingModifiersDown == GamepadTargetingState.BOTH then
		GamepadMode.SetHUDBindingModifier(true);
	elseif targetingModifiersDown == GamepadTargetingState.NONE then
		GamepadMode.SetHUDBindingModifier(false);
	end
end

function GamepadMode.OnCrossBarModifierChanged(inMod, down)
	inputModifierCallbacksFrame:TriggerEvent("CrossBarModifierStateChanged", inMod, down);
end

function GamepadMode.OpenRadial()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	if (IsInCinematicScene() and CanCancelScene()) then
		CancelScene();
		return;
	end

	if (InCinematic()) then
		StopCinematic();
		return;
	end

	GamepadRadial:SetShown(not GamepadRadial:IsShown());
end

function GamepadMode.ToggleUIFocus()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	GamepadMode.FrameControlsManager:ToggleUIFocus();
end

-- Query Key State ------------------------------
function GamepadMode.IsHUDBindingModifierDown()
	return inputModifierDown;
end

function GamepadMode.IsTargetingModifierDown(flag)
	if flag == nil then
		return targetingModifierActive ~= GamepadTargetingState.NONE;
	end
	return targetingModifierActive == flag;
end

function GamepadMode.HasTargetingModifierVisualState()
	return targetingModifierVisualState ~= GamepadTargetingState.NONE;
end

function GamepadMode.GetTargetingModifierVisualState()
	return targetingModifierVisualState;
end

function GamepadMode.IsBindingDown(inBinding)
	local keys = { GetBindingKey(inBinding, 1) };
	for _, key in ipairs(keys) do
		if IsKeyDown(key) then
			return true;
		end
	end
	return false;
end

function GamepadMode.IsLeftModifierDown()
	local leftModDown = GamepadMode.IsBindingDown("GAMEPADLEFTMOD");
	return leftModDown and (GamepadSharedUtility.InputBindingManager:IsOnlyCoreBindingSetActive() or GamepadMode.GetOverrideAllowLeftRightModifiers());
end

function GamepadMode.IsRightModifierDown()
	local rightModDown = GamepadMode.IsBindingDown("GAMEPADRIGHTMOD");
	return rightModDown and (GamepadSharedUtility.InputBindingManager:IsOnlyCoreBindingSetActive() or GamepadMode.GetOverrideAllowLeftRightModifiers());
end

-- Override Left/Right Modifiers ----------------
function GamepadMode.SetOverrideAllowLeftRightModifiers(allowUsage)
	overrideAllowLeftRightModifiers = allowUsage;
	GamepadSharedUtility.InputBindingManager:AssumeCoreBindingsAreUsable(allowUsage);
end

function GamepadMode.GetOverrideAllowLeftRightModifiers()
	return overrideAllowLeftRightModifiers;
end

-- Misc Utilities -------------------------------
function GamepadMode.GetHudModifierUsesToggle()
	return not CVarCallbackRegistry:GetCVarValueBool("GamepadHudModifierUsesToggle");
end

function GamepadMode.ResetModifiers()
	GamepadMode.SetHUDBindingModifier(false);
	GamepadMode.SetTargetModifier(GamepadTargetingState.FRIENDLY, false);
	GamepadMode.SetTargetModifier(GamepadTargetingState.HOSTILE, false);
end

--[[
	Calls to the PingListener frame to fire an instant ping on press, or start a pending ping on hold
	isButtonDown: current press state of the bound button
]]
function GamepadMode.TogglePingSystem(down)
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	-- Cancel pending ping on down press.
	if (PingListenerFrame.pendingPingInfo) then
		if (down) then
			PingListenerFrame:TogglePingListener(false);
		end
	else
		PingListenerFrame:TogglePingListener(down);
	end
end

-- System Initialization ------------------------
local function SetUp()
	CVarCallbackRegistry:SetCVarCachable("GamepadHudModifierUsesToggle");
	CVarCallbackRegistry:SetCVarCachable("GamepadSwapTargetModifiers");
	CVarCallbackRegistry:SetCVarCachable("GamepadTargetingModifierVisualDelay");
	CVarCallbackRegistry:SetCVarCachable("GamepadTargetingMode");

	-- Reset modifiers whenever they get swapped, so they don't get stuck if one was currently held
	CVarCallbackRegistry:RegisterCallback("GamepadSwapTargetModifiers", GamepadMode.ResetModifiers);
	CVarCallbackRegistry:RegisterCallback("GamepadSwapFriendlyTargetActions", GamepadMode.ResetModifiers);
	CVarCallbackRegistry:RegisterCallback("GamepadSwapHostileTargetActions", GamepadMode.ResetModifiers);
end

EventUtil.ContinueOnVariablesLoaded(SetUp);
