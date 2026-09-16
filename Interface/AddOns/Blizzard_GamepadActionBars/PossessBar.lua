function GamepadActionBarPageUnitMixin:InitializePossessBar()
	local possessBar = self.actionBars.possessBar;
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.SpecialPageTopBar, GamepadActionBarPageUnitMixin.GetTopAnchorFrame, 4);
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.Page1LeftBar, GamepadActionBarPageUnitMixin.GetLeftAnchorFrame, 1);
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.Page1RightBar, GamepadActionBarPageUnitMixin.GetRightAnchorFrame, 1);
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.Page1BottomBar, GamepadActionBarPageUnitMixin.GetBottomAnchorFrame, 1);
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.Page2TopBar, GamepadActionBarPageUnitMixin.GetTopAnchorFrame, 2);
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.Page2LeftBar, GamepadActionBarPageUnitMixin.GetLeftAnchorFrame, 2);
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.Page2RightBar, GamepadActionBarPageUnitMixin.GetRightAnchorFrame, 2);
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.Page2BottomBar, GamepadActionBarPageUnitMixin.GetBottomAnchorFrame, 2);
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.Page3TopBar, GamepadActionBarPageUnitMixin.GetTopAnchorFrame, 3);
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.Page3LeftBar, GamepadActionBarPageUnitMixin.GetLeftAnchorFrame, 3);
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.Page3RightBar, GamepadActionBarPageUnitMixin.GetRightAnchorFrame, 3);
	possessBar:SetOverrideMapping(Enum.GamepadPossessBarOverride.Page3BottomBar, GamepadActionBarPageUnitMixin.GetBottomAnchorFrame, 3);

	-- Simulate the inital assignment as a change event so we initialize the possess bar in the right state.
	possessBar:ApplyInitialOverridePositioning();

	-- Register to event that allows us to display/hide the gamepad possess bar at the appropriate time.
	EventRegistry:RegisterCallback("PetActionBar.GamepadVisibilityHandler", possessBar.ActivateOrDeactivateOverrideBar, possessBar);
end

function GamepadActionBarPageUnitMixin:IsPossessBarActiveBarForPageUnit()
	return self.actionBars.possessBar == self:GetActiveBar();
end

function GamepadActionBarPageUnitMixin:IsPossessBarActiveAndOnSpecialPage()
	local possessBarOverrideIndex = self.actionBars.possessBar:GetOverrideCVarValue();
	local possessBarOverrideAsNumber = tonumber(possessBarOverrideIndex);
	return self.actionBars.possessBar:IsOverrideBarActive() and possessBarOverrideAsNumber == Enum.GamepadPossessBarOverride.SpecialPageTopBar;
end

-- Handles managing the gamepad possess bar buttons similar to how the MKB pet bar manages its pet buttons (PetActionBar.lua).
GamepadPossessBarMixin = CreateFromMixins(GamepadOverrideBarMixin);

function GamepadPossessBarMixin:OnLoad()
	GamepadOverrideBarMixin.OnLoad(self);
	self:RegisterEvent("PLAYER_CONTROL_LOST");
	self:RegisterEvent("PLAYER_CONTROL_GAINED");
	self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED");
	self:RegisterUnitEvent("UNIT_PET", "player");
	self:RegisterUnitEvent("UNIT_FLAGS", "pet");
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN");
	self:RegisterEvent("PET_BAR_UPDATE_USABLE");
	self:RegisterEvent("PET_UI_UPDATE");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
	self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
	self:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED");
	self:RegisterUnitEvent("UNIT_AURA", "pet");

	self:SetScript("OnEvent", self.OnEvent);

	-- Set the indices of the gamepad pet buttons to link them with the stored actions.
	local startingGamepadPetActionIndex = C_GamepadUI.GetFirstGamepadPetActionStorageSlotIndex();
	for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR do
		self.actionButtons[i]:SetID(startingGamepadPetActionIndex + i - 1);
	end

	self:Update();
end

function GamepadPossessBarMixin:OnEvent(event, ...)
	GamepadOverrideBarMixin.OnEvent(self, event, ...);

	local arg1 = ...;
	if (event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and arg1 == "player") or event == "PET_UI_UPDATE" or event == "PLAYER_CONTROL_LOST" or
		event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" or event == "PET_BAR_UPDATE_USABLE" or
		event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_MOUNT_DISPLAY_CHANGED" or event == "PLAYER_SOFT_ENEMY_CHANGED" or
		((event == "UNIT_FLAGS" or event == "UNIT_AURA") and arg1 == "pet")) then
		self:Update();
	elseif ( event =="PET_BAR_UPDATE_COOLDOWN" ) then
		self:UpdateCooldowns();
	end
end

function GamepadPossessBarMixin:OnUpdate(elapsed)
	local rangeTimer = self.rangeTimer;
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed;
		if ( rangeTimer <= 0) then
			for i=1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR do
				local actionButton = self.actionButtons[i];
				local checksRange, inRange = select(8, GetPetActionInfo(actionButton:GetID()));
				actionButton:RefreshRange(checksRange, inRange);
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end
		self.rangeTimer = rangeTimer;
	end
end

function GamepadPossessBarMixin:Update()
	local petActionButton
	for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR do
		petActionButton = self.actionButtons[i];
		petActionButton:UpdateButtonState();
	end
	self:UpdateCooldowns();

	self.rangeTimer = -1;
end

function GamepadPossessBarMixin:UpdateCooldowns()
	for i = 1, Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR do
		local cooldown = self.actionButtons[i].cooldown;
		local petActionButtonID = self.actionButtons[i]:GetID();
		local start, duration, enable = GetPetActionCooldown(petActionButtonID);
		CooldownFrame_Set(cooldown, start, duration, enable);

		-- Update tooltip
		local actionButton = self.actionButtons[i];
		if GameTooltip:GetOwner() == actionButton then
			actionButton:OnEnter();
		end
	end
end

function GamepadPossessBarMixin:UpdateActionButtonsStateAndFlash()
	--[[
		The possess bar's update function handles updating state and flash.
		This method is defined as an override from the GamepadActionBarMixin version.
	]]
	self:Update();
end

function GamepadPossessBarMixin:GetActionBarLinkedWithOverrideBar()
	-- The possess bar itself is the action bar linked with the special page.
	if (self.isOnSpecialPage) then
		return self;
	end

	return GamepadOverrideBarMixin.GetActionBarLinkedWithOverrideBar(self);
end

function GamepadPossessBarMixin:OnOverrideCVarChanged(oldOverride, newOverride)
	GamepadOverrideBarMixin.OnOverrideCVarChanged(self, oldOverride, newOverride);

	-- Show or hide the page tracker's special slot.
	self.pagingUnitOwner:RefreshPageTrackerSpecialPageSlotVisibility();
	self.pagingUnitOwner:HandleSpecialPageActiveStateChange();
end

function GamepadPossessBarMixin:IsPossessBarOverrideOnSpecialPage()
	local possessBarOverride = self:GetOverrideCVarValue();
	local possessBarOverrideAsNumber = tonumber(possessBarOverride);
	return Enum.GamepadPossessBarOverride.SpecialPageTopBar == possessBarOverrideAsNumber;
end

function GamepadPossessBarMixin:UpdateOverrideBarPositioning()
	GamepadOverrideBarMixin.UpdateOverrideBarPositioning(self);
	self.isOnSpecialPage = self:IsPossessBarOverrideOnSpecialPage();
end
