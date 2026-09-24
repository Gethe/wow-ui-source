--[[
	Allows the player to go into a DPAD selection
	mode over the raid groups
]]

RaidTargetingFreeSelectionMixin = {}

function RaidTargetingFreeSelectionMixin:OnLoad()
	self:SetupFooter();
	self:RegisterForTransitions();
end

function RaidTargetingFreeSelectionMixin:OnGamepadMainMenuShown()
	GroupTargeting:StopTargeting();
end

function RaidTargetingFreeSelectionMixin:OnShow()
	EventRegistry:RegisterCallback("Gamepad.ShowMainMenu", self.OnGamepadMainMenuShown, self);
	self:UpdateFooter();
end

function RaidTargetingFreeSelectionMixin:OnHide()
	EventRegistry:UnregisterCallback("Gamepad.ShowMainMenu", self.OnGamepadMainMenuShown);
	GroupTargeting:StopTargeting();
end

function RaidTargetingFreeSelectionMixin:UpdateVisibility()
	if not InputUtil.IsGamepadUIEnabled() then
		self:Hide();
		return;
	end

	local inRaid = IsInRaid();
	if (IsInGroup() and (inRaid or EditModeManagerFrame:UseRaidStylePartyFrames())) then
		local raidFrame = inRaid and CompactRaidFrameContainer or CompactPartyFrame;
		self.raidTargetingFooter:SetParentFrame(raidFrame);

		self:Show();
	else
		self:Hide();
	end

	self:UpdateFooter();
end

function RaidTargetingFreeSelectionMixin:CanUseFocusButton()
	return GamepadMode.FrameControlsManager:GetShownFrameCount() == 0 and GamepadSharedUtility.InputBindingManager:IsOnlyCoreBindingSetActive();
end

function RaidTargetingFreeSelectionMixin:SetupFooter()
	local open = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_SHOULDER_LEFT, nil, "");
	open:AddCondition(function()
		return self:CanUseFocusButton();
	end);
	open:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ALWAYS);

	self.raidTargetingFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "RaidTargetingFooter");
	self.raidTargetingFooter:AddPromptedBinding(open);
	self.raidTargetingFooter:Finalize();

	GamepadSharedUtility.BindingStack.InputBindingManager:BindToCoreBindingActive(GenerateClosure(self.UpdateFooter, self));
end

function RaidTargetingFreeSelectionMixin:UpdateFooter()
	if GroupTargeting:IsActive() then
		self.raidTargetingFooter:HideAndDeactivateBindings();
	else
		self.raidTargetingFooter:ShowAndActivateBindings();
		self.raidTargetingFooter:Refresh();
	end
end

function RaidTargetingFreeSelectionMixin:SetActive(inActive)
	local raidFrame = IsInRaid() and CompactRaidFrameContainer or CompactPartyFrame;
	if inActive then
		GroupTargeting:StartTargeting(raidFrame);
	else
		GroupTargeting:StopTargeting();
	end

	self:UpdateFooter();
end

function RaidTargetingFreeSelectionMixin:Toggle()
	local raidFrame = IsInRaid() and CompactRaidFrameContainer or CompactPartyFrame;
	if GroupTargeting:IsActive() then
		GroupTargeting:StopTargeting();
	else
		GroupTargeting:StartTargeting(raidFrame);
	end

	self:UpdateFooter();
end

function RaidTargetingFreeSelectionMixin:OnExitEditMode()
	self:UpdateVisibility();
end

function RaidTargetingFreeSelectionMixin:InitializeGamepad()
	self:UpdateVisibility();
end

function RaidTargetingFreeSelectionMixin:UninitializeGamepad()
	self:Hide();
end

function RaidTargetingFreeSelectionMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end
