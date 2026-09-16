local Shared = require(".Shared");
local StaticOverrideActionBarMixin = require(".StaticOverrideActionBar");

GamepadShortcutsActionBarMixin = CreateFromMixins(StaticOverrideActionBarMixin);

function GamepadShortcutsActionBarMixin:OnLoad()
	GamepadMode.RegisterInputModifierStateChangeCallback(self.OnInputModifierStateChanged, self);
	StaticOverrideActionBarMixin.OnLoad(self);
end

function GamepadShortcutsActionBarMixin:OnInputModifierStateChanged(isActive)
	self:ActivateOrDeactivateOverrideBar(isActive);
end

function GamepadShortcutsActionBarMixin:OnShow()
	self:RegisterUnitEvent("UNIT_AURA", "player");

	self:RefreshBuffsButton();

	GamepadMainActionBarFrame:SetShoulderIcons("gamepad-targeting-shortcuts", "gamepad-targeting-shortcuts");
end

function GamepadShortcutsActionBarMixin:OnHide()
	self:UnregisterEvent("UNIT_AURA");

	GamepadMainActionBarFrame:ResetShoulderIcons();
end

function GamepadShortcutsActionBarMixin:OnEvent(event, ...)
	if event == "UNIT_AURA" then
		local unitTarget = ...;
		if unitTarget == "player" then
			self:RefreshBuffsButton();
		end
	end
end

function GamepadShortcutsActionBarMixin:RefreshBuffsButton()
	-- Defer refreshes until the end of the frame to ensure the buff frame refreshes first
	RunNextFrame(function()
		local canUse = BuffFrame and BuffFrame:IsShown() and BuffFrame:HasActiveAura();
		self:SetButtonEnabled(self.faceTopButton, canUse);
	end);
end

function GamepadShortcutsActionBarMixin:SetUpDpadLeft()
	self.dpadLeftButton.SpecialActionIcon:SetTexture("Interface\\Icons\\Misc_arrowleft");
	self.dpadLeftButton.SpecialActionIcon:Show();

	Shared.SetButtonHandler(self.dpadLeftButton, function()
		GamepadMainActionBarFrame:PreviousActionBarPage();
	end);
end

function GamepadShortcutsActionBarMixin:SetUpDpadTop()
	self.dpadTopButton.SpecialActionIcon:SetAtlas("gamepad-radial-icon-quests");
	self.dpadTopButton.SpecialActionIcon:Show();

	Shared.SetButtonHandler(self.dpadTopButton, function()
		if ObjectiveTrackerFrame and ObjectiveTrackerFrame:IsShown() then
			GamepadMode.FrameControlsManager:FrameShown(ObjectiveTrackerFrame);
		end
	end);
end

function GamepadShortcutsActionBarMixin:SetUpDpadRight()
	self.dpadRightButton.SpecialActionIcon:SetTexture("Interface\\Icons\\Misc_arrowright");
	self.dpadRightButton.SpecialActionIcon:Show();

	Shared.SetButtonHandler(self.dpadRightButton, function()
		GamepadMainActionBarFrame:NextActionBarPage();
	end);
end

function GamepadShortcutsActionBarMixin:SetUpDpadBottom()
	self.dpadBottomButton.SpecialActionIcon:SetTexture("Interface\\Icons\\UI_Chat");
	self.dpadBottomButton.SpecialActionIcon:Show();

	Shared.SetButtonHandler(self.dpadBottomButton, function()
		local activeChatFrame = FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK);
		if activeChatFrame and activeChatFrame:IsShown() then
			activeChatFrame:SetGamepadFocus();
		end
	end);
end

function GamepadShortcutsActionBarMixin:SetUpFaceLeft()
	self.faceLeftButton.SpecialActionIcon:SetTexture("Interface\\Icons\\UI_WarMode");
	self.faceLeftButton.SpecialActionIcon:Show();

	Shared.SetButtonHandler(self.faceLeftButton, ToggleSheath);
end

function GamepadShortcutsActionBarMixin:SetUpFaceTop()
	self.faceTopButton.SpecialActionIcon:SetAtlas("gamepad-radial-icon-viewbuffs");
	self.faceTopButton.SpecialActionIcon:Show();

	Shared.SetButtonHandler(self.faceTopButton, function()
		if BuffFrame and BuffFrame:IsShown() and BuffFrame:HasActiveAura() then
			GamepadMode.FrameControlsManager:FrameShown(BuffFrame);
		end
	end);
end

function GamepadShortcutsActionBarMixin:SetUpFaceRight()
	self.faceRightButton.SpecialActionIcon:SetAtlas("gamepad-radial-icon-bags");
	self.faceRightButton.SpecialActionIcon:Show();

	Shared.SetButtonHandler(self.faceRightButton, function()
		ToggleAllBags();
	end);
end
