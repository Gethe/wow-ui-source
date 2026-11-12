local Gamepad = {"Gamepad"};

local function SetupTempCVar(set, cvar, val)
	if set then
		C_CVar.SetTempCVar(cvar, val);
	else
		C_CVar.RemoveTempCVar(cvar);
	end
end


local function SetupCameraFollowCVars(set)
	SetupTempCVar(set, "CameraFollowYawSpeed", 1.0);
	SetupTempCVar(set, "CameraFollowPitchSpeed", 0.5);
	SetupTempCVar(set, "CameraFollowPitchStrength", 1.0);
	SetupTempCVar(set, "CameraFollowPitchDeadZone", 0.0);
	SetupTempCVar(set, "CameraReduceUnexpectedMovement", "0");
	SetupTempCVar(set, "CameraKeepCharacterCentered", "1");
end

local function SetupCVarsForInputMode( useGamepad )
	if InGlue() then
		return;
	end

	-- SoftTarget[*]
	SetupTempCVar(useGamepad, "SoftTargetEnemy", 1);
	SetupTempCVar(useGamepad, "SoftTargetFriend", 0);
	SetupTempCVar(useGamepad, "SoftTargetIconEnemy", 0);
	SetupTempCVar(useGamepad, "SoftTargetIconFriend", 0);
	SetupTempCVar(useGamepad, "SoftTargetWithLocked", 1);
	SetupTempCVar(useGamepad, "SoftTargetMatchLocked", 1);
	SetupTempCVar(useGamepad, "SoftTargetIconInteract", 1);
	SetupTempCVar(useGamepad, "SoftTargetNameplateEnemy", 0);
	SetupTempCVar(useGamepad, "SoftTargetNameplateInteract", 0);
	SetupTempCVar(useGamepad, "SoftTargetTooltipEnemy", 0);
	SetupTempCVar(useGamepad, "SoftTargetTooltipFriend", 0);
	SetupTempCVar(useGamepad, "SoftTargetInteract", 1);
	SetupTempCVar(useGamepad, "SoftTargetInteractRange", 20);
	SetupTempCVar(useGamepad, "SoftTargetIconGameObject", 1);
	SetupTempCVar(useGamepad, "SoftTargetEnemyArc", 1);
	SetupTempCVar(useGamepad, "SoftTargetFriendArc", 2);
	SetupTempCVar(useGamepad, "SoftTargetInteractArc", 1);
	SetupTempCVar(useGamepad, "SoftTargetForce", 0);
	SetupTempCVar(useGamepad, "SoftTargetNameplateSize", 20);
	SetupTempCVar(useGamepad, "TargetAutoEnemy", 1);
	SetupTempCVar(useGamepad, "TargetAutoFriend", 1);
	SetupTempCVar(useGamepad, "TargetEnemyAttacker", 1);
	SetupTempCVar(useGamepad, "TargetAutoLock", 1);

	-- CameraFollow[*]
	if useGamepad then
		SetupCameraFollowCVars(CVarCallbackRegistry:GetCVarValueBool("GamepadCameraFollowOnStick"));
		CVarCallbackRegistry:RegisterCallback("GamepadCameraFollowOnStick", function()
			SetupCameraFollowCVars(CVarCallbackRegistry:GetCVarValueBool("GamepadCameraFollowOnStick"));
		end, Gamepad);
	else
		SetupCameraFollowCVars(false);
	end
end

local function SetGamepadModeCoreBindingContextActive(useGamepad)
	if InGlue() then
		return;
	end

	if (useGamepad) then
		C_KeyBindings.ActivateBindingContext(Enum.BindingContext.GamepadModeInGameCore);
	else
		C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.GamepadModeInGameCore);
	end
end

local function RegisterEvents()
	CVarCallbackRegistry:SetCVarCachable("GamepadActionBarLeftRightDelay");
	CVarCallbackRegistry:SetCVarCachable("GamepadActionBarTopBottomDelay");
	CVarCallbackRegistry:SetCVarCachable("GamepadTargetingModifierVisualDelay");
	CVarCallbackRegistry:SetCVarCachable("GamepadCompassCustomFilterFriendly");
	CVarCallbackRegistry:SetCVarCachable("GamepadCompassCustomFilterEnemy");
	CVarCallbackRegistry:SetCVarCachable("GamepadCompassCustomFilterBoss");
	CVarCallbackRegistry:SetCVarCachable("GamepadCompassCustomFilterParty");
	CVarCallbackRegistry:SetCVarCachable("GamepadCompassCustomFilterCritter");

	InputUtil.RegisterForInterfaceTransitions(Gamepad);
	InputUtil.RegisterGamepadInit(Gamepad, function ()
		SetupCVarsForInputMode(true);
		SetGamepadModeCoreBindingContextActive(true);

		if Kiosk and Kiosk.IsEnabled() then
			EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD",
				function(_, isInitialLogin, isReloadingUi)
					if isInitialLogin then
						SetupCVarsForInputMode(true);
					end
				end, Gamepad)
		end
	end);
	InputUtil.RegisterMKBInit(Gamepad, function ()
		if Kiosk and Kiosk.IsEnabled() then
			EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD",
				function(_, isInitialLogin, isReloadingUi)
					if (not isInitialLogin) and isReloadingUi then
						C_CVar.SetCVar("SoftTargetNameplateEnemy", 1);
						C_CVar.SetCVar("SoftTargetInteractRange", 10);
						C_CVar.SetCVar("SoftTargetIconGameObject", 0);
						C_CVar.SetCVar("SoftTargetEnemyArc", 2);
						C_CVar.SetCVar("SoftTargetInteractArc", 0);
						C_CVar.SetCVar("SoftTargetNameplateSize", 19);
					end
				end, Gamepad);
		end

		SetupCVarsForInputMode(false);
	end);
	InputUtil.RegisterGamepadUninit(Gamepad, function ()
		SetupCVarsForInputMode(false);
		SetGamepadModeCoreBindingContextActive(false);
		local EDITMODE_MODERN_PRESET_LAYOUT_INDEX = Enum.EditModePresetLayouts.Modern + 1;
		C_EditMode.SetActiveLayout(EDITMODE_MODERN_PRESET_LAYOUT_INDEX);

		if Kiosk and Kiosk.IsEnabled() then
			EventRegistry:UnregisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", Gamepad);
		end
	end);
end

EventUtil.ContinueOnVariablesLoaded(RegisterEvents);
