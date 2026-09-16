--[[
	Handles logic and controls for targeting
]]

local GamepadTargetLogicMixin = {};

function GamepadTargetLogicMixin:ConsumeModifier()
	self.wasModifierUsed = true;
end

function GamepadTargetLogicMixin:TargetNextFriendly()
	TargetNearestFriend(false);
	self:ConsumeModifier();
end

function GamepadTargetLogicMixin:TargetNextHostile()
	TargetNearestEnemy(false);
	self:ConsumeModifier();
end

local function GetNextRaidTargetMarkerIndex(direction)
	local currentMarker = GetRaidTargetIndex("target");
	local firstMarker = (direction > 0) and 1 or Constants.RaidMarkerConsts.MAX_RAID_TARGETS_USER;
	local lastMarker = firstMarker + direction * (Constants.RaidMarkerConsts.MAX_RAID_TARGETS_USER - 1);
	local firstMarkerToCheck = currentMarker and (currentMarker + direction) or firstMarker;

	-- If we've wrapped around, the next action should be to remove the marker rather than wrap
	if firstMarkerToCheck == lastMarker + direction then
		return nil;
	end

	local reverseSearch = direction < 0;
	local nextMarker = GetNextAvailableRaidTargetMarkerIndex(
		firstMarkerToCheck,
		reverseSearch,
		false,	-- wrapSearch
		true);	-- treatDeadNonFriendlyMarkersAsAvailable

	if nextMarker == 0 then
		-- If all markers are used already, make the binding move the first one
		if not currentMarker then
			return firstMarker;
		end
		return nil;
	end

	return nextMarker;
end

function GetNextFriendlyRaidTargetMarkerIndex()
	return GetNextRaidTargetMarkerIndex(1);
end

function GetNextHostileRaidTargetMarkerIndex()
	return GetNextRaidTargetMarkerIndex(-1);
end

function GamepadTargetLogicMixin:UnflipCamera()
	if self.isCameraYawFlipped then
		FlipCameraYaw(180);
		self.isCameraYawFlipped = false;
	end
end

function GamepadTargetLogicMixin:FlipCamera(down)
	if down then
		FlipCameraYaw(180);
		self.isCameraYawFlipped = true;
	else
		self:UnflipCamera();
	end
end

function GamepadTargetLogicMixin:ZoomCamera(x, y)
	self.zoomMagnitude = y;
end

function GamepadTargetLogicMixin:UpdateCameraZoom(elapsed)
	if self.zoomMagnitude < 0 then
		CameraZoomOut(self.zoomSpeed * -self.zoomMagnitude * elapsed);
	elseif self.zoomMagnitude > 0 then
		CameraZoomIn(self.zoomSpeed * self.zoomMagnitude * elapsed);
	end
end

function GamepadTargetLogicMixin:OnAbilityUsed(unit, _, _, spellId)
	if unit ~= "player" then
		return;
	end

	-- Attempt to hard target our soft target if we have no hard target and are casting a harmful spell.
	if not UnitExists("target") and C_Spell.IsSpellHarmful(spellId) and UnitExists("softenemy") then
		TargetUnit("softenemy");
	end
end

function GamepadTargetLogicMixin:UpdateSoftTargetInteract()
	local disableSoftInteract = UnitAffectingCombat("player")
		and UnitExists("target")
		and UnitCanAttack("player", "target");

	C_CVar.SetTempCVar("SoftTargetInteract", disableSoftInteract and 0 or 1);
end

function GamepadTargetLogicMixin:OnTargetChanged(...)
	self:ConsumeModifier();
	self:UpdateSoftTargetInteract();
end

function GamepadTargetLogicMixin:OnCombatEnter(...)
	self:UpdateSoftTargetInteract();
end

function GamepadTargetLogicMixin:OnCombatExit(...)
	self:UpdateSoftTargetInteract();
end

function GamepadTargetLogicMixin:RegisterEventsForGamepad()
	EventRegistry:RegisterFrameEventAndCallback("UNIT_SPELLCAST_SENT", self.OnAbilityUsed, self);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_TARGET_CHANGED", self.OnTargetChanged, self);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", self.OnCombatEnter, self);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", self.OnCombatExit, self);
end

function GamepadTargetLogicMixin:UnregisterEventsForGamepad()
	EventRegistry:UnregisterFrameEventAndCallback("UNIT_SPELLCAST_SENT", self);
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_TARGET_CHANGED", self);
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", self);
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", self);
end

function GamepadTargetLogicMixin:BeginTargeting(filter)
	if self.activeTargetFilter == filter then
		return;
	elseif self.activeTargetFilter ~= nil then
		self:EndTargeting();
	end

	self.activeTargetFilter = filter;
	self.wasModifierUsed = false;

	C_GamepadTargeting.SetFilter(filter);
	C_GamepadTargeting.Enable();
end

function GamepadTargetLogicMixin:EndTargeting()
	if self.activeTargetFilter == nil then
		return;
	end

	local targetNextHostile = (self.activeTargetFilter ~= Enum.GamepadTargetingFilters.Friendly);
	local targetAlreadySelected = C_GamepadTargeting.Disable();
	if (not self.wasModifierUsed) and (not targetAlreadySelected) then
		if targetNextHostile then
			if CVarCallbackRegistry:GetCVarValueBool("GamepadTabHostileTargetAction") then
				self:TargetNextHostile();
			end
		else
			if CVarCallbackRegistry:GetCVarValueBool("GamepadTabFriendlyTargetAction") then
				self:TargetNextFriendly();
			end
		end
	end

	self.activeTargetFilter = nil;
end

function GamepadTargetLogicMixin:OnTargetModifierChanged(_, active)
	if active ~= GamepadTargetingState.NONE and GamepadSharedUtility.InputBindingManager:IsOnlyCoreBindingSetActive() then
		local filter = (active == GamepadTargetingState.FRIENDLY)
			and Enum.GamepadTargetingFilters.Friendly
			or Enum.GamepadTargetingFilters.Hostile;

		self:BeginTargeting(filter);
	else
		self:EndTargeting();
	end
end

function GamepadTargetLogicMixin:OnTargetModifierCancelled(_, previous)
	self:ConsumeModifier();
	self:EndTargeting();
end

function GamepadTargetLogicMixin:OnInputModifierStateChanged(_, modifierDown)
	local modifierActive = GamepadMode.IsHUDBindingModifierDown();
	if not modifierActive then
		self:UnflipCamera();
	end

	if modifierDown and GamepadMainActionBarFrame:IsShown() then
		GamepadMode.ActivateBindingGroup(self.hudModifierBindings);
		EventRegistry:RegisterForOnUpdate(self, self.UpdateCameraZoom);
	else
		GamepadMode.DeactivateBindingGroup(self.hudModifierBindings);
		EventRegistry:UnregisterForOnUpdate(self);
	end
end

function GamepadTargetLogicMixin:Init()
	self.zoomMagnitude = 0;
	self.zoomSpeed = CVarCallbackRegistry:GetCVarNumberOrDefault("cameraZoomSpeed");
	self.isCameraYawFlipped = false; -- Track locally because the camera interface only applies deltas, not values.
	self.wasModifierUsed = true;

	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.RegisterEventsForGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UnregisterEventsForGamepad, self));
	GamepadMode.RegisterTargetModifierStateChanged(GenerateClosure(self.OnTargetModifierChanged, self), self);
	GamepadMode.RegisterTargetModifierStateCancelled(GenerateClosure(self.OnTargetModifierCancelled, self), self);
	GamepadMode.RegisterInputModifierStateChangeCallback(GenerateClosure(self.OnInputModifierStateChanged, self), self);

	self.hudModifierBindings = GamepadMode.CreateBindingGroup("GamepadHUDModifierBindings");
	self.hudModifierBindings:AddFunctionBinding(GAMEPAD_STICK_LEFT_PRESS, CenterCamera);
	self.hudModifierBindings:AddFunctionBinding(GAMEPAD_STICK_RIGHT_PRESS, GenerateClosure(self.FlipCamera, self), GAMEPAD_BUTTON_ANY_DOWN_OR_UP);
	self.hudModifierBindings:AddAxisBinding(GAMEPAD_STICK_RIGHT, GenerateClosure(self.ZoomCamera, self));
	self.hudModifierBindings:TreatAsCore();

	CVarCallbackRegistry:SetCVarCachable("GamepadTabHostileTargetAction");
	CVarCallbackRegistry:SetCVarCachable("GamepadTabFriendlyTargetAction");
	CVarCallbackRegistry:RegisterCallback("cameraZoomSpeed", function(_, value) self.zoomSpeed = value; end);
end

GamepadTargetLogic = CreateAndInitFromMixin(GamepadTargetLogicMixin);
