function GamepadActionBarPageUnitMixin:InitializeStanceBar()
	local stanceBar = self.actionBars.stanceBar;
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.None, function() end, 0);
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.Page1LeftBar, GamepadActionBarPageUnitMixin.GetLeftAnchorFrame, 1);
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.Page1RightBar, GamepadActionBarPageUnitMixin.GetRightAnchorFrame, 1);
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.Page1BottomBar, GamepadActionBarPageUnitMixin.GetBottomAnchorFrame, 1);
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.Page2TopBar, GamepadActionBarPageUnitMixin.GetTopAnchorFrame, 2);
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.Page2LeftBar, GamepadActionBarPageUnitMixin.GetLeftAnchorFrame, 2);
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.Page2RightBar, GamepadActionBarPageUnitMixin.GetRightAnchorFrame, 2);
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.Page2BottomBar, GamepadActionBarPageUnitMixin.GetBottomAnchorFrame, 2);
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.Page3TopBar, GamepadActionBarPageUnitMixin.GetTopAnchorFrame, 3);
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.Page3LeftBar, GamepadActionBarPageUnitMixin.GetLeftAnchorFrame, 3);
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.Page3RightBar, GamepadActionBarPageUnitMixin.GetRightAnchorFrame, 3);
	stanceBar:SetOverrideMapping(Enum.GamepadStanceBarOverride.Page3BottomBar, GamepadActionBarPageUnitMixin.GetBottomAnchorFrame, 3);

	-- Simulate the inital assignment as a change event so we initialize the stance bar in the correct state.
	stanceBar:ApplyInitialOverridePositioning();
end

GamepadStanceBarMixin = CreateFromMixins(GamepadOverrideBarMixin);

function GamepadStanceBarMixin:OnLoad()
	GamepadOverrideBarMixin.OnLoad(self);
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	self.BackgroundWatermark:Show();
end

function GamepadStanceBarMixin:OnEvent(event, ...)
	GamepadOverrideBarMixin.OnEvent(self, event, ...);

	if (event == "UPDATE_BONUS_ACTIONBAR" or event == "PLAYER_ENTERING_WORLD") then
		self:UpdateStanceBarState();
	end
end

function GamepadStanceBarMixin:GetActionBarLinkedWithOverrideBar()
	local overrideIndex = self:GetOverrideCVarValue();
	local overrideIndexAsNumber = tonumber(overrideIndex);
	if (overrideIndexAsNumber == Enum.GamepadStanceBarOverride.None and (not self:GetParent())) then
		return self; -- The stance bar is the linked bar when it is not being used.
	end

	return GamepadOverrideBarMixin.GetActionBarLinkedWithOverrideBar(self);
end

function GamepadStanceBarMixin:UpdateStanceBarState()
	if (not C_ActionBar.HasBonusActionBar()) then
		self:DeactivateOverrideBar();
		return;
	end

	local firstStanceBarIndex = C_GamepadUI.GetFirstGamepadActionBarStorageSlotIndexForActiveStance();
	assert(firstStanceBarIndex, "A MKB bonus action bar is active which doesn't have a gamepad equivalent. Extend the gamepad action bar storage (ActionBarConstants.tag) to add additional slots for this bar.");
	local buttonID = firstStanceBarIndex;
	for _, button in ipairs(self.actionButtons) do
		button:UpdateWithStorageId(buttonID);
		buttonID = buttonID + 1;
	end

	self:ActivateOverrideBar();
end
