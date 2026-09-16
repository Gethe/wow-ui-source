local Shared = require(".Shared");
local StaticOverrideActionBarMixin = require(".StaticOverrideActionBar");

GamepadFriendlyTargetingActionBarMixin = CreateFromMixins(StaticOverrideActionBarMixin);

function GamepadFriendlyTargetingActionBarMixin:OnLoad()
	self.swapLeftAndRightCvar = "GamepadSwapFriendlyTargetActions";
	self.usePartyTargeting = C_CVar.GetCVarBool("GamepadUsePartyTargeting");

	StaticOverrideActionBarMixin.OnLoad(self);

	GamepadMode.RegisterTargetModifierStateChanged(self.OnTargetModifierStateChanged, self);
	GamepadMode.RegisterTargetModifierStateCancelled(self.OnTargetModifierStateCancelled, self);

	CVarCallbackRegistry:RegisterCallback("GamepadUsePartyTargeting", function(_, value)
		self.usePartyTargeting = tonumber(value) ~= 0;
	end);
end

function GamepadFriendlyTargetingActionBarMixin:OnShow()
	self:RegisterEvent("GROUP_JOINED");
	self:RegisterEvent("GROUP_LEFT");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterUnitEvent("UNIT_PET", "player");
	self:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "player", "pet", "targettarget");
	self:RegisterUnitEvent("UNIT_TARGET", "target");

	self:RefreshAssistButton();
	self:RefreshGroupTargeting();
	self:RefreshPlayerPortrait();
	self:RefreshPetButton();

	GamepadMainActionBarFrame:SetShoulderIcons("gamepad-targeting-friendly", "gamepad-targeting-shortcuts");
end

function GamepadFriendlyTargetingActionBarMixin:OnHide()
	self:UnregisterEvent("GROUP_JOINED");
	self:UnregisterEvent("GROUP_LEFT");
	self:UnregisterEvent("GROUP_ROSTER_UPDATE");
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterEvent("UNIT_PET");
	self:UnregisterEvent("UNIT_PORTRAIT_UPDATE");
	self:UnregisterEvent("UNIT_TARGET");

	if GroupTargeting:IsActive() then
		RaidTargetingFreeSelection:SetActive(false);
	end

	GamepadMainActionBarFrame:ResetShoulderIcons();
end

function GamepadFriendlyTargetingActionBarMixin:OnEvent(event, ...)
	local handler = self[event];
	if handler then
		handler(self, ...);
	end
end

function GamepadFriendlyTargetingActionBarMixin:GROUP_JOINED()
	self:RefreshGroupTargeting();
end

function GamepadFriendlyTargetingActionBarMixin:GROUP_LEFT()
	self:RefreshGroupTargeting();
end

function GamepadFriendlyTargetingActionBarMixin:GROUP_ROSTER_UPDATE()
	self:RefreshGroupTargeting();
end

function GamepadFriendlyTargetingActionBarMixin:PLAYER_TARGET_CHANGED()
	self:RefreshAssistButton();
end

function GamepadFriendlyTargetingActionBarMixin:UNIT_PORTRAIT_UPDATE(unit)
	if unit == "player" then
		self:RefreshPlayerPortrait();
	elseif unit == "pet" then
		self:RefreshPetButton();
	elseif unit == "targettarget" then
		self:RefreshAssistButton();
	end
end

function GamepadFriendlyTargetingActionBarMixin:UNIT_PET(ownerUnit)
	if ownerUnit == "player" then
		self:RefreshPetButton();
	end
end

function GamepadFriendlyTargetingActionBarMixin:UNIT_TARGET(unitTarget)
	if unitTarget == "target" then
		self:RefreshAssistButton();
	end
end

function GamepadFriendlyTargetingActionBarMixin:OnTargetModifierStateChanged(newState)
	self:ActivateOrDeactivateOverrideBar(newState == GamepadTargetingState.FRIENDLY);
end

function GamepadFriendlyTargetingActionBarMixin:OnTargetModifierStateCancelled(prevState)
	if prevState == GamepadTargetingState.FRIENDLY then
		self:DeactivateOverrideBar();
	end
end

function GamepadFriendlyTargetingActionBarMixin:RefreshGroupTargeting()
	local function SetClassColorTexture(texture, unit)
		local loc = PlayerLocation:CreateFromUnit(unit);
		local class = C_PlayerInfo.GetClass(loc);
		local color = C_ClassColor.GetClassColor(class);
		texture:SetColorTexture(color.r, color.g, color.b, 1);
	end

	for _, actionButton in ipairs(self.dpadButtons) do
		actionButton.SpecialActionIcon:Hide();
		actionButton.IconOverlay:Hide();
	end

	local isInGroup = IsInGroup();
	local usePartyTargeting = isInGroup and self.usePartyTargeting and not IsInRaid();
	local useRaidTargeting = isInGroup and not usePartyTargeting;

	if useRaidTargeting then
		self.dpadLeftButton.SpecialActionIcon:SetAtlas("gamepad-targeting-left");
		self.dpadTopButton.SpecialActionIcon:SetAtlas("gamepad-targeting-up");
		self.dpadRightButton.SpecialActionIcon:SetAtlas("gamepad-targeting-right");
		self.dpadBottomButton.SpecialActionIcon:SetAtlas("gamepad-targeting-down");

		Shared.SetButtonHandler(self.dpadLeftButton, GenerateClosure(SmartNavigation.NavigateLeft, SmartNavigation), true);
		Shared.SetButtonHandler(self.dpadTopButton, GenerateClosure(SmartNavigation.NavigateUp, SmartNavigation), true);
		Shared.SetButtonHandler(self.dpadRightButton, GenerateClosure(SmartNavigation.NavigateRight, SmartNavigation), true);
		Shared.SetButtonHandler(self.dpadBottomButton, GenerateClosure(SmartNavigation.NavigateDown, SmartNavigation), true);

		for _, actionButton in ipairs(self.dpadButtons) do
			self:SetButtonEnabled(actionButton, true);
			actionButton.SpecialActionIcon:Show();
		end

		RaidTargetingFreeSelection:SetActive(true);
	elseif usePartyTargeting then
		local mapping = {
			party1 = self.dpadTopButton,
			party2 = self.dpadRightButton,
			party3 = self.dpadBottomButton,
			party4 = self.dpadLeftButton,
		};

		self.dpadTopButton.IconOverlay:SetAtlas("gamepad-targeting-first");
		self.dpadRightButton.IconOverlay:SetAtlas("gamepad-targeting-second");
		self.dpadBottomButton.IconOverlay:SetAtlas("gamepad-targeting-third");
		self.dpadLeftButton.IconOverlay:SetAtlas("gamepad-targeting-fourth");

		for unit, actionButton in pairs(mapping) do
			Shared.SetUpTargetingButton(actionButton, unit);

			actionButton.IconOverlay:Show();

			if UnitExists(unit) then
				SetClassColorTexture(actionButton.SpecialActionIcon, unit);
				actionButton.SpecialActionIcon:Show();
				self:SetButtonEnabled(actionButton, true);
			else
				self:SetButtonEnabled(actionButton, false);
			end
		end
	else
		self.dpadLeftButton:SetScript("OnClick", nil);
		self.dpadTopButton:SetScript("OnClick", nil);
		self.dpadRightButton:SetScript("OnClick", nil);
		self.dpadBottomButton:SetScript("OnClick", nil);

		for _, actionButton in ipairs(self.dpadButtons) do
			self:SetButtonEnabled(actionButton, false);
		end
	end

	if not useRaidTargeting and GroupTargeting:IsActive() then
		RaidTargetingFreeSelection:SetActive(false);
	end
end

function GamepadFriendlyTargetingActionBarMixin:RefreshPlayerPortrait()
	SetPortraitTexture(self.faceBottomButton.SpecialActionIcon, "player");
end

function GamepadFriendlyTargetingActionBarMixin:RefreshPetButton()
	if UnitExists("pet") then
		SetPortraitTexture(self.faceLeftButton.SpecialActionIcon, "pet");
		self.faceLeftButton.SpecialActionIcon:Show();
		self:SetButtonEnabled(self.faceLeftButton, true);
	else
		self.faceLeftButton.SpecialActionIcon:Hide();
		self:SetButtonEnabled(self.faceLeftButton, false);
	end
end

function GamepadFriendlyTargetingActionBarMixin:RefreshAssistButton()
	Shared.RefreshAssistButton(self, self.faceRightButton);
end

function GamepadFriendlyTargetingActionBarMixin:ResetDpadLeft()
	Shared.ResetTargetingButton(self.dpadLeftButton);
end

function GamepadFriendlyTargetingActionBarMixin:ResetDpadTop()
	Shared.ResetTargetingButton(self.dpadTopButton);
end

function GamepadFriendlyTargetingActionBarMixin:ResetDpadRight()
	Shared.ResetTargetingButton(self.dpadRightButton);
end

function GamepadFriendlyTargetingActionBarMixin:ResetDpadBottom()
	Shared.ResetTargetingButton(self.dpadBottomButton);
end

function GamepadFriendlyTargetingActionBarMixin:ResetFaceLeft()
	Shared.ResetTargetingButton(self.faceLeftButton);
end

function GamepadFriendlyTargetingActionBarMixin:SetUpFaceLeft()
	self:RefreshPetButton();

	self.faceLeftButton.IconOverlay:SetAtlas("gamepad-targeting-overlay");
	self.faceLeftButton.IconOverlay:Show();

	Shared.SetUpTargetingButton(self.faceLeftButton, "pet");
end

function GamepadFriendlyTargetingActionBarMixin:ResetFaceTop()
	Shared.ResetTargetMarkerButton(self, self.faceTopButton);
end

function GamepadFriendlyTargetingActionBarMixin:SetUpFaceTop()
	Shared.SetUpTargetMarkerButton(self, self.faceTopButton, 1);
end

function GamepadFriendlyTargetingActionBarMixin:ResetFaceRight()
	Shared.ResetTargetingButton(self.faceRightButton);
end

function GamepadFriendlyTargetingActionBarMixin:SetUpFaceRight()
	self:RefreshAssistButton();

	self.faceRightButton.IconOverlay:SetAtlas("gamepad-targeting-overlay");
	self.faceRightButton.IconOverlay:Show();

	Shared.SetUpTargetingButton(self.faceRightButton, "targettarget");
end

function GamepadFriendlyTargetingActionBarMixin:ResetFaceBottom()
	Shared.ResetTargetingButton(self.faceBottomButton);
end

function GamepadFriendlyTargetingActionBarMixin:SetUpFaceBottom()
	self:RefreshPlayerPortrait();

	self.faceBottomButton.IconOverlay:SetAtlas("gamepad-targeting-overlay");
	self.faceBottomButton.IconOverlay:Show();
	self.faceBottomButton.SpecialActionIcon:Show();

	Shared.SetUpTargetingButton(self.faceBottomButton, "player");
end
