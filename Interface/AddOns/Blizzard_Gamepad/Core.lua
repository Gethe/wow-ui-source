local function SetupCVarsForInputMode( useGamepad )
	local function SetupTempCVar(cvar, val)
		if useGamepad then
			C_CVar.SetTempCVar(cvar, val);
		else
			C_CVar.RemoveTempCVar(cvar);
		end
	end

	if InGlue() then
		return;
	end

	-- SoftTarget[*]
	SetupTempCVar("SoftTargetEnemy", 1);
	SetupTempCVar("SoftTargetFriend", 0);
	SetupTempCVar("SoftTargetIconEnemy", 0);
	SetupTempCVar("SoftTargetIconFriend", 0);
	SetupTempCVar("SoftTargetWithLocked", 1);
	SetupTempCVar("SoftTargetMatchLocked", 1);
	SetupTempCVar("SoftTargetIconInteract", 1);
	SetupTempCVar("SoftTargetNameplateEnemy", 0);
	SetupTempCVar("SoftTargetNameplateInteract", 0);
	SetupTempCVar("SoftTargetTooltipEnemy", 0);
	SetupTempCVar("SoftTargetTooltipFriend", 0);
	SetupTempCVar("SoftTargetInteract", 1);
	SetupTempCVar("SoftTargetInteractRange", 20);
	SetupTempCVar("SoftTargetIconGameObject", 1);
	SetupTempCVar("SoftTargetEnemyArc", 1);
	SetupTempCVar("SoftTargetFriendArc", 2);
	SetupTempCVar("SoftTargetInteractArc", 1);
	SetupTempCVar("SoftTargetForce", 0);
	SetupTempCVar("SoftTargetNameplateSize", 20);

	-- CameraFollow[*]
	SetupTempCVar("CameraFollowYawSpeed", 1.0);
	SetupTempCVar("CameraFollowPitchSpeed", 0.5);
	SetupTempCVar("CameraFollowPitchStrength", 1.0);
	SetupTempCVar("CameraFollowPitchDeadZone", 0.0);
	SetupTempCVar("CameraReduceUnexpectedMovement", "0");
	SetupTempCVar("CameraKeepCharacterCentered", "1");
end

local function SetGamepadModeCoreBindingContextActive(useGamepad)
	if (useGamepad) then
		C_KeyBindings.ActivateBindingContext(Enum.BindingContext.GamepadModeInGameCore);
	else
		C_KeyBindings.DeactivateBindingContext(Enum.BindingContext.GamepadModeInGameCore);
	end
end

local function RegisterEvents()
	CVarCallbackRegistry:SetCVarCachable("GamepadShowEmptyActionbars");
	CVarCallbackRegistry:SetCVarCachable("GamepadActionBarLeftRightDelay");
	CVarCallbackRegistry:SetCVarCachable("GamepadActionBarTopBottomDelay");
	CVarCallbackRegistry:SetCVarCachable("GamepadTargetingModifierVisualDelay");
	CVarCallbackRegistry:SetCVarCachable("GamepadCompassCustomFilterFriendly");
	CVarCallbackRegistry:SetCVarCachable("GamepadCompassCustomFilterEnemy");
	CVarCallbackRegistry:SetCVarCachable("GamepadCompassCustomFilterBoss");
	CVarCallbackRegistry:SetCVarCachable("GamepadCompassCustomFilterParty");
	CVarCallbackRegistry:SetCVarCachable("GamepadCompassCustomFilterCritter");

	local Gamepad = {"Gamepad"};
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
