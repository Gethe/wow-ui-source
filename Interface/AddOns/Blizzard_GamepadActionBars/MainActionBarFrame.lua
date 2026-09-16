local AUTO_ATTACK_SPELL_ID = 6603;

GamepadMainActionBarFrameMixin = {};

function GamepadMainActionBarFrameMixin:GetActionBars()
	return self.PageUnit.actionBars;
end

local function AreActionBarsUsable()
	return GamepadSharedUtility.InputBindingManager:IsOnlyCoreBindingSetActive();
end

local function InTargetingModifierVisualDelay()
	return GamepadMode.IsTargetingModifierDown() and not GamepadMode.HasTargetingModifierVisualState();
end

function GamepadMainActionBarFrameMixin:AssignActionBarUsableConditionalFunc()
	local actionBars = self:GetActionBars();
	for _, value in pairs(actionBars) do
		value:SetIsActionBarUsableFunc(AreActionBarsUsable);
	end
end

function GamepadMainActionBarFrameMixin:RefreshSecondaryActionbarVisibility()
	local actionBars = self:GetActionBars();

	actionBars.bottomBar:RefreshActionBarVisibility();
	actionBars.leftBar:RefreshActionBarVisibility();
	actionBars.rightBar:RefreshActionBarVisibility();
end

function GamepadMainActionBarFrameMixin:LinkGamepadMainActionBarsWithShowSettings()
	local actionBars = self:GetActionBars();

	--[[
		Gamepad main top action bar should always be shown as long as gamepad UI is
		enabled, so it is not linked with a show setting
	]]
	actionBars.leftBar:SetActionBarShowSetting("GamepadShowEmptyActionbars");
	actionBars.rightBar:SetActionBarShowSetting("GamepadShowEmptyActionbars");
	actionBars.bottomBar:SetActionBarShowSetting("GamepadShowEmptyActionbars");

	SettingsCallbackRegistry:RegisterCallback("GamepadShowEmptyActionbars", GenerateClosure(self.RefreshSecondaryActionbarVisibility, self));
end

--[[
	Checks if the action bars should be collapsed or not.
]]
function GamepadMainActionBarFrameMixin:UpdateActionBarFocusedState()
	local actionBarUsability = AreActionBarsUsable();
	local inTargetingModifierVisualDelay = InTargetingModifierVisualDelay();

	if actionBarUsability then
		-- Refresh to active state using Mod key event handler
		self.PageUnit:ActionBarModKeyDownStateCheck();
	else
		local actionBars = self:GetActionBars();
		for i, actionBar in pairs(actionBars) do
			if not inTargetingModifierVisualDelay then
				actionBar:HideHighlight();
				actionBar:HideButtonIcons();
			end
		end
	end
	self.PageUnit:ShowModifierIcons(actionBarUsability or inTargetingModifierVisualDelay);
	self:UpdateInteractIcons();
end

function GamepadMainActionBarFrameMixin:NextActionBarPage()
	self.PageUnit:ClickChangePageButton("LeftButton", true);
end

function GamepadMainActionBarFrameMixin:PreviousActionBarPage()
	self.PageUnit:ClickChangePageButton("RightButton", true);
end

function GamepadMainActionBarFrameMixin:CycleActionBarPages()
	self.PageUnit:ClickChangePageButton("LeftButton", true);
end

function GamepadMainActionBarFrameMixin:InitializeGamepad()
	self:Show();
	self:RegisterEvent("PLAYER_ENTER_COMBAT");
	self:RegisterEvent("PLAYER_LEAVE_COMBAT");
end

function GamepadMainActionBarFrameMixin:UninitializeGamepad()
	self:Hide();
	self:UnregisterEvent("PLAYER_ENTER_COMBAT");
	self:UnregisterEvent("PLAYER_LEAVE_COMBAT");
end

function GamepadMainActionBarFrameMixin:OnAutoLootCVarChanged()
	self.autoLootOnTap = CVarCallbackRegistry:GetCVarValueBool("autoLootDefault");
end

function GamepadMainActionBarFrameMixin:OnLoad()
	self:AssignActionBarUsableConditionalFunc();
	self.PageUnit:ActionBarModKeyDownStateCheck();
	self:LinkGamepadMainActionBarsWithShowSettings();

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.PageUnit:StartListeningForModifierUpdates();

	self.autoLootOnTap = CVarCallbackRegistry:GetCVarValueBool("autoLootDefault");
	CVarCallbackRegistry:RegisterCallback("autoLootDefault", self.OnAutoLootCVarChanged, self);

	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));

	EventUtil.ContinueOnVariablesLoaded(GenerateClosure(self.PostVariableSetUp, self));

	CVarCallbackRegistry:SetCVarCachable("GamepadSwapTargetModifiers");
	CVarCallbackRegistry:RegisterCallback("GamepadSwapTargetModifiers", self.ResetShoulderIcons, self);
	GamepadMode.RegisterTargetModifierChanged(self.UpdateShoulderHighlight, self);

	GamepadSharedUtility.CreateDownClickButton("CycleActionBarPageButton", self,
		function() self:CycleActionBarPages() end, nil, GAMEPAD_BUTTON_ANY_DOWN);

	-- The prompt for this page unit's paging exists in the persistent input legend, so the default prompt is not needed.
	self.PageUnit:SetPageTrackerPagingPromptVisibility(false);
end

function GamepadMainActionBarFrameMixin:OnShow()
	self:ResetShoulderIcons();
end

local function MakeInteractAction(unit)
	return function(isHoldAction, gamepadActionBarFrame)
		-- This isn't strictly necessary to be unconditional, but cover our bases in case of any
		-- bugs where `SetUseAutoLootToggle` hasn't been reset after a prior autoloot.
		C_AutoLoot.SetUseAutoLootToggle(gamepadActionBarFrame.autoLootOnTap ~= isHoldAction);
		C_PlayerInteractionManager.InteractUnit(unit);

		if isHoldAction then
			C_AutoLoot.SetUseAutoLootToggle(gamepadActionBarFrame.autoLootOnTap);
		end
	end;
end

local function MakeInteractIconHandler(unit, name)
	return function()
		if UnitIsInInteractRange(unit) then
			return "Interface\\Cursor\\" .. name;
		else
			return "Interface\\Cursor\\Unable" .. name;
		end
	end;
end

local function GetAttackIcon()
	return C_Spell.GetSpellTexture(AUTO_ATTACK_SPELL_ID);
end

local interactActions = {
	-- Lootable soft interact (in interact range)
	{
		condition = function(vars) return vars.softInteractExists and vars.softInteractIsInInteractRange and vars.softInteractHasLoot; end,
		action = MakeInteractAction("softinteract"),
		icon = MakeInteractIconHandler("softinteract", "LootAll"),
		overheadTarget = "softinteract",
	},

	-- Soft interact (in interact range)
	{
		condition = function(vars) return vars.softInteractExists and vars.softInteractIsInInteractRange; end,
		cursorUnit = "softinteract",
		action = MakeInteractAction("softinteract"),
		icon = MakeInteractIconHandler("softinteract", "Interact"),
		overheadTarget = "softinteract",
	},

	-- Loot target
	{
		condition = function(vars) return vars.targetExists and UnitHasLootInteraction("target"); end,
		action = MakeInteractAction("target"),
		icon = MakeInteractIconHandler("target", "LootAll"),
		overheadTarget = "target",
	},

	-- Interact with target
	{
		condition = function(vars) return vars.targetExists and UnitIsInteractable("target"); end,
		cursorUnit = "target",
		action = MakeInteractAction("target"),
		icon = MakeInteractIconHandler("target", "Interact"),
		overheadTarget = "target",
	},

	-- Attackable target
	{
		condition = function(vars) return vars.targetExists and UnitCanAttack("player", "target"); end,
		action = function() AttackTarget(); end,
		icon = GetAttackIcon,
	},

	-- Attackable soft enemy
	{
		condition = function() return UnitExists("softenemy") and UnitCanAttack("player", "softenemy"); end,
		action = function() TargetUnit("softenemy"); AttackTarget(); end,
		icon = GetAttackIcon,
	},

	-- Unattackable target
	{
		condition = function(vars) return vars.targetExists; end,
		action = function() UIErrorsFrame:AddExternalErrorMessage(ERR_NO_ATTACK_TARGET); end,
		icon = GetAttackIcon,
	},

	-- No target
	{
		action = function() UIErrorsFrame:AddExternalErrorMessage(ERR_GENERIC_NO_TARGET); end,
		icon = GetAttackIcon,
	},
};

local function ResolveNonBindableInteract()
	-- Vars that are commonly used in conditions, so we don't need to re-evaluate them multiple times
	local vars = {
		softInteractExists = UnitExists("softinteract") or UnitIsGameObject("softinteract"),
		softInteractHasLoot = UnitHasLootInteraction("softinteract"),
		softInteractIsInInteractRange = UnitIsInInteractRange("softinteract"),
		targetExists = UnitExists("target"),
	};

	for _, action in ipairs(interactActions) do
		if not action.condition or action.condition(vars) then
			return action;
		end
	end

	error("At least one action should resolve");
end

function GamepadMainActionBarFrameMixin:UpdateInteractIcons()
	local actionBars = self:GetActionBars();
	local iconTexture = actionBars.topBar.Right.ActionButton1.SpecialActionIcon;
	local action = ResolveNonBindableInteract();

	if not action.cursorUnit or not SetUnitCursorTexture(iconTexture, action.cursorUnit, nil, nil, false) then
		local texture = action.icon;
		if type(texture) == "function" then
			texture = texture();
		end
		iconTexture:SetTexture(texture);
	end

	local overheadTarget = nil;
	if GamepadSharedUtility.InputBindingManager:IsOnlyCoreBindingSetActive() then
		overheadTarget = action.overheadTarget;
	end

	SetPreferredGamepadInteractTarget(overheadTarget);
	EventRegistry:TriggerEvent("Gamepad.PreferredGamepadInteractTargetChanged");
end

function GamepadMainActionBarFrameMixin:OnEvent(event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		self.PageUnit:RefreshActionBarVisibilities();
		self:UpdateInteractIcons();
	else
		local actionBars = self:GetActionBars();
		local interactButton = actionBars.topBar.Right.ActionButton1;
		if (event == "PLAYER_ENTER_COMBAT") then
			interactButton:StartFlash();
			interactButton.CheckedTexture:Show();
		elseif (event == "PLAYER_LEAVE_COMBAT") then
			interactButton:StopFlash();
			interactButton.CheckedTexture:Hide();
		end
	end
end

local function SetupNonBindableSlotBackdrop(actionButton)
	local backdrop = actionButton:CreateTexture();
	backdrop:AddMaskTexture(actionButton.CircleMask);
	backdrop:SetAllPoints(actionButton.SlotArt);
	backdrop:SetColorTexture(0, 0, 0, 1);
	backdrop:SetDrawLayer("BACKGROUND", 0);
	backdrop:Show();

	actionButton.SpecialActionIcon:SetDrawLayer("BACKGROUND", 1);
end

local function SetupNonBindableJump(gamepadActionBarFrame)
	local function JumpFunction(self, mouseButton, down)
		self:ApplyPressedStyle(down);
		if (down) then
			if (GamepadMode.IsHUDBindingModifierDown()) then
				SitStandOrDescendStart();
			else
				RunBinding("JUMP", "down");
			end
		else
			DescendStop();
			RunBinding("JUMP", "up");
		end
	end

	local topBarJumpButton = gamepadActionBarFrame.PageUnit.actionBars.topBar.Right.ActionButton4;
	topBarJumpButton:RegisterForClicks("AnyUp", "AnyDown");
	topBarJumpButton:SetScript("OnClick", JumpFunction);
	topBarJumpButton.SpecialActionIcon:SetAtlas("gamepad-ability-icon-jump");
	topBarJumpButton.SpecialActionIcon:Show();
end

local function SetupNonBindableBack(gamepadActionBarFrame)
	local function BackFunction()
		if ( SpellStopCasting() ) then
		elseif ( SpellStopTargeting() ) then
		elseif ( ClearTarget() ) then
		end
	end

	local topBarBackButton = gamepadActionBarFrame.PageUnit.actionBars.topBar.Right.ActionButton3;
	topBarBackButton:RegisterForClicks("AnyDown", "AnyUp");
	topBarBackButton:SetScript("OnClick", function(self, mouseButton, down)
		self:ApplyPressedStyle(down);
		if down then
			BackFunction();
		end
	end);
	topBarBackButton.SpecialActionIcon:SetAtlas("128-redbutton-exit");
	topBarBackButton.SpecialActionIcon:ClearAllPoints();
	topBarBackButton.SpecialActionIcon:SetPoint("TOPLEFT", topBarBackButton, "TOPLEFT", -6, 6);
	topBarBackButton.SpecialActionIcon:SetPoint("BOTTOMRIGHT", topBarBackButton, "BOTTOMRIGHT", 6, -6);
	topBarBackButton.SpecialActionIcon:Show();
end

local function SetupNonBindableInteractFunction(gamepadActionBarFrame, interactButton)
	local function OnDown()
		interactButton:ApplyPressedStyle(true);
	end

	local function OnHeld()
		local action = ResolveNonBindableInteract();
		action.action(true, gamepadActionBarFrame);
	end

	local function OnTap()
		local action = ResolveNonBindableInteract();
		action.action(false, gamepadActionBarFrame);
		interactButton:ApplyPressedStyle(false);
	end

	local function OnReleaseAfterHold()
		interactButton:ApplyPressedStyle(false);
	end

	local INTERACT_AUTO_LOOT_HOLD_TIME = 0.5;
	interactButton:SetScript(
		"OnClick",
		GamepadSharedUtility.CreateHoldClickHandler(INTERACT_AUTO_LOOT_HOLD_TIME, OnDown, OnHeld, OnTap, OnReleaseAfterHold));
end

local function SetupNonBindableInteract(gamepadActionBarFrame)
	local actionBars = gamepadActionBarFrame:GetActionBars();
	local interactButton = actionBars.topBar.Right.ActionButton1;
	local buttonIcon = interactButton.icon;
	local interactIcon = interactButton.SpecialActionIcon;

	--[[
		@TODO: This special use of the action button code for a non-ability can get the "mouse down" and "active" states reset undesirably,
		resulting in "mouse down" disappearing and "active" sticking. We should investigate if ControllerActionButton can be replaced or simplified,
		since it was largely a prototype copy-paste from ActionButton. As a workaround, always hide the "active" state for our dedicated Interact.
	]]
	interactButton:GetCheckedTexture():SetAlpha(0.0);

	-- Re-use the square auto-attack red flash by allowing it to over-scale and be masked, hiding the frame shape.
	interactButton.Flash:ClearAllPoints();
	interactButton.Flash:SetPoint("CENTER");
	interactButton.Flash:SetScale(1.5);

	interactButton:RegisterForClicks("AnyUp", "AnyDown");
	SetupNonBindableInteractFunction(gamepadActionBarFrame, interactButton);

	interactIcon:Show();
	buttonIcon:SetAlpha(0);

	-- Delay handling target change events for a frame to allow the target's nameplate to populate, which we need to pull an icon from.
	local function UpdateInteractIconsNextFrame()
		RunNextFrame(GenerateClosure(gamepadActionBarFrame.UpdateInteractIcons, gamepadActionBarFrame));
	end

	EventRegistry:RegisterFrameEventAndCallback("PLAYER_SOFT_INTERACT_CHANGED", UpdateInteractIconsNextFrame);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_SOFT_ENEMY_CHANGED", UpdateInteractIconsNextFrame);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_TARGET_CHANGED", UpdateInteractIconsNextFrame);
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_EQUIPMENT_CHANGED", UpdateInteractIconsNextFrame);

	gamepadActionBarFrame:UpdateInteractIcons();
end

local function SetupNonBindableInspect(gamepadActionBarFrame)
	local function InspectFunction()
		local targetExists = UnitExists("target");
		if targetExists then
			TargetFrame_OpenMenu(TargetFrame);
		end
	end

	local inspectButton = gamepadActionBarFrame.PageUnit.actionBars.topBar.Right.ActionButton2;
	inspectButton:RegisterForClicks("AnyDown", "AnyUp");
	inspectButton:SetScript("OnClick", function(self, mouseButton, down)
		self:ApplyPressedStyle(down);
		if not down then
			InspectFunction();
		end
	end);

	local clearOverlay = inspectButton:CreateTexture();
	clearOverlay:SetAllPoints(inspectButton.SpecialActionIcon);
	clearOverlay:SetAtlas("gamepad-actionbar-circleslot-permabound");

	local function UpdateInspectIcon()
		local offset = 3;

		clearOverlay:Hide();

		if GamepadMode.IsTargetingModifierDown() then
			local nextMarker;

			if GamepadMode.IsTargetingModifierDown(GamepadTargetingState.FRIENDLY) then
				nextMarker = GetNextFriendlyRaidTargetMarkerIndex();
			else
				nextMarker = GetNextHostileRaidTargetMarkerIndex();
			end

			local marker = nextMarker or GetRaidTargetIndex("target");

			clearOverlay:SetShown(not nextMarker);

			if marker and marker > 0 then
				inspectButton.SpecialActionIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
				SetRaidTargetIconTexture(inspectButton.SpecialActionIcon, marker);
			else
				inspectButton.SpecialActionIcon:SetColorTexture(0, 0, 0, 0);
				inspectButton.SpecialActionIcon:SetSpriteSheetCell(1, 1, 1);
			end

			offset = -6;
		else
			local atlas = UnitExists("target") and "crosshair_inspect_32" or "crosshair_unableinspect_32";
			inspectButton.SpecialActionIcon:SetAtlas(atlas);
			inspectButton.SpecialActionIcon:SetSpriteSheetCell(1, 1, 1);
		end

		inspectButton.SpecialActionIcon:ClearAllPoints();
		inspectButton.SpecialActionIcon:SetPoint("TOPLEFT", -offset, offset);
		inspectButton.SpecialActionIcon:SetPoint("BOTTOMRIGHT", offset, -offset);
	end

	EventRegistry:RegisterFrameEventAndCallback("PLAYER_TARGET_CHANGED", UpdateInspectIcon);
	EventRegistry:RegisterFrameEventAndCallback("RAID_TARGET_UPDATE", UpdateInspectIcon);
	GamepadMode.RegisterTargetModifierStateChanged(UpdateInspectIcon);
	GamepadMode.RegisterTargetModifierStateCancelled(UpdateInspectIcon);

	UpdateInspectIcon();

	inspectButton.SpecialActionIcon:Show();
end

function GamepadMainActionBarFrameMixin:UpdateShoulderHighlight(flag, down)
	local highlight = (flag == GamepadMode.GetLeftTargetModifierFlag())
		and self.PageUnit.LeftShoulderHighlight
		or self.PageUnit.RightShoulderHighlight;
	highlight:SetShown(down);
end

function GamepadMainActionBarFrameMixin:ResetShoulderIcons()
	self:SetShoulderIcons("gamepad-targeting-friendly", "gamepad-targeting-hostile");
end

function GamepadMainActionBarFrameMixin:SetShoulderIcons(leftIcon, rightIcon)
	if CVarCallbackRegistry:GetCVarValueBool("GamepadSwapTargetModifiers") then
		leftIcon, rightIcon = rightIcon, leftIcon;
	end

	local useAtlasSize = true;
	self.PageUnit.LeftShoulderIcon:SetAtlas(leftIcon, useAtlasSize);
	self.PageUnit.RightShoulderIcon:SetAtlas(rightIcon, useAtlasSize);
end

function GamepadMainActionBarFrameMixin:SetupNonbindableActions()
	SetupNonBindableSlotBackdrop(self.PageUnit.actionBars.topBar.Right.ActionButton1);
	SetupNonBindableSlotBackdrop(self.PageUnit.actionBars.topBar.Right.ActionButton2);
	SetupNonBindableSlotBackdrop(self.PageUnit.actionBars.topBar.Right.ActionButton3);
	SetupNonBindableSlotBackdrop(self.PageUnit.actionBars.topBar.Right.ActionButton4);

	C_ActionBar.UnregisterActionUIButton(self.PageUnit.actionBars.topBar.Right.ActionButton1);
	C_ActionBar.UnregisterActionUIButton(self.PageUnit.actionBars.topBar.Right.ActionButton2);
	C_ActionBar.UnregisterActionUIButton(self.PageUnit.actionBars.topBar.Right.ActionButton3);
	C_ActionBar.UnregisterActionUIButton(self.PageUnit.actionBars.topBar.Right.ActionButton4);

	SetupNonBindableJump(self);
	SetupNonBindableInteract(self);
	SetupNonBindableInspect(self);
	SetupNonBindableBack(self);
end

function GamepadMainActionBarFrameMixin:PostVariableSetUp()
	self:SetupNonbindableActions();

	local abilityBindsActive = GenerateClosure(self.UpdateActionBarFocusedState, self);
	GamepadSharedUtility.InputBindingManager:BindToCoreBindingActive(abilityBindsActive);
	GamepadMode.RegisterInputModifierStateChangeCallback(self.OnInputModifierStateChange, self);
	GamepadMode.RegisterTargetModifierVisualStateChanged(self.OnInputModifierStateChange, self);
end

function GamepadMainActionBarFrameMixin:RefreshActionBars()
	self.PageUnit:ActionBarModKeyDownStateCheck();
end

function GamepadMainActionBarFrameMixin:OnInputModifierStateChange(modifierDown)
	self:UpdateActionBarFocusedState();

	if modifierDown then
		self:RefreshActionBars();
	end
end

function GamepadMainActionBarFrameMixin:PressActionButton(inIndex, button, down)
	local actionBar = self.PageUnit:GetActiveBar();
	local actionButton = actionBar:GetActionButtonByIndex(inIndex);

	if actionButton:IsEnabled() then
		actionButton:Click(button, down);
		if down then
			actionButton:SetButtonState("PUSHED");
		else
			actionButton:SetButtonState("NORMAL");
		end
	end
end
