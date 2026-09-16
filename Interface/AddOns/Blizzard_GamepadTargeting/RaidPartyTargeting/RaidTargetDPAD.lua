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

function RaidTargetingFreeSelectionMixin:OnUpdate()
	self.raidInputLegendInactive:ClearAllPoints();

	local _, _, top, bottom = CompactRaidFrameContainer:GetBounds();
	local height = bottom - top;

	self.raidInputLegendInactive:SetPoint("TOPLEFT", CompactRaidFrameContainer, "TOPLEFT", 0, -height);
	self:SetScript("OnUpdate", nil);
end

function RaidTargetingFreeSelectionMixin:UpdateVisibility()
	if not InputUtil.IsGamepadUIEnabled() then
		self:Hide();
		return;
	end

	local inRaid = IsInRaid();
	if (IsInGroup() and (inRaid or EditModeManagerFrame:UseRaidStylePartyFrames())) then
		local raidFrame = inRaid and CompactRaidFrameContainer or CompactPartyFrame;
		self.raidInputLegendInactive:ClearAllPoints();
		self.raidInputLegendInactive:SetPoint("TOPLEFT", raidFrame, "BOTTOMLEFT");

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
	local openAction = InputPromptLegends.CreateFrameAction("Open", InputPromptLegends.PromptTemplates.StandardOneIcon, { GAMEPAD_SHOULDER_LEFT }, "");

	local raidInputLegendInactive = InputPromptLegends.CreateInputLegend(self, "raidInputLegendInactive");
	raidInputLegendInactive:SetLegendWidth(45);
	raidInputLegendInactive:AddFrameAction(openAction);
	raidInputLegendInactive:InitializePrompts();

	GamepadSharedUtility.BindingStack.InputBindingManager:BindToCoreBindingActive(GenerateClosure(self.UpdateFooter, self));
end

function RaidTargetingFreeSelectionMixin:UpdateFooter()
	self.raidInputLegendInactive:SetFrameActionPromptEnabled("Open", self:CanUseFocusButton());

	if GroupTargeting:IsActive() then
		self.raidInputLegendInactive:Hide();
	else
		self.raidInputLegendInactive:Show();
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
