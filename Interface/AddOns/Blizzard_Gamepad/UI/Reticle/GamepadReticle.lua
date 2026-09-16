--[[
	A small indicator in the middle of the screen to help aim automatic targeting and interactions on gamepad.
]]

GamepadReticleMixin = {};

function GamepadReticleMixin:OnLoad()
	self.showingHoverState = false;

	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitForGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitForGamepad, self));
end

function GamepadReticleMixin:OnEvent(event, ...)
	if (event == "DISPLAY_SIZE_CHANGED") then
		self:Recenter();
	elseif (event == "PLAYER_TARGET_CHANGED") then
		self:PlayTargetUpdate();
	elseif (event == "GAME_PAD_ALLOW_HOVER_EVENTS_WITH_FREE_LOOK_CHANGED") then
		local enabled = ...;
		self:RefreshGamepadReticle(enabled);
	end
end

function GamepadReticleMixin:SetNonTargetingStyle()
	self.TargetingIcon:Hide();
end

function GamepadReticleMixin:SetTargetingNeutralStyle()
	self.TargetingIcon:Show();
	self.TargetingIcon:SetAlpha(0.4);
	self.TargetingIcon:SetScale(1);
end

function GamepadReticleMixin:SetTargetingHoverStyle()
	self.TargetingIcon:Show();
	self.TargetingIcon:SetAlpha(1);
	self.TargetingIcon:SetScale(0.8);
end

function GamepadReticleMixin:SetTargetingHoverState(enable)
	if not enable and self.showingHoverState then
		self.showingHoverState = false;
		self:SetTargetingNeutralStyle();
		if self.UpdateAnim:IsPlaying() then
			self.UpdateAnim:Stop();
		end
	elseif enable and not self.showingHoverState then
		self.showingHoverState = true;
		self:SetTargetingHoverStyle();
		self:PlayTargetUpdate();
	end
end

function GamepadReticleMixin:PlayTargetUpdate()
	if not self.UpdateAnim:IsPlaying() then
		self.UpdateAnim:Play();
	end
end

function GamepadReticleMixin:EnableReticleUpdate(enable)
	local function TickHoverState()
		self:SetTargetingHoverState(C_GamepadTargeting.HasReticleHoverTarget());
	end

	if enable and not self.updateTicker then
		self.updateTicker = C_Timer.NewTicker(0.05, TickHoverState);
		TickHoverState();
	elseif not enable and self.updateTicker then
		self.updateTicker:Cancel();
		self.updateTicker = nil;
	end
end

function GamepadReticleMixin:RefreshGamepadReticle(enabled)
	if enabled then
		self:Show();
		self:SetNonTargetingStyle();
		self:EnableReticleUpdate(false);
		if self.IntroAnim:IsPlaying() then
			self.IntroAnim:Stop();
		end
		if self.UpdateAnim:IsPlaying() then
			self.UpdateAnim:Stop();
		end
	else
		self:Hide();
	end
end

function GamepadReticleMixin:Recenter()
	self:ClearAllPoints();
	self:SetPoint("CENTER", UIParent, "BOTTOM", 0, GetScreenHeight() * C_CVar.GetCVar("CursorCenteredYPos"));
end

function GamepadReticleMixin:InitForGamepad()
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("GAME_PAD_ALLOW_HOVER_EVENTS_WITH_FREE_LOOK_CHANGED");

	local function RefreshGamepadReticle_TargetChanged(reticle)
		reticle:RefreshGamepadReticle(C_GamePad.GetAllowHoverEventsWithFreeLook());
	end
	GamepadMode.RegisterTargetModifierVisualStateChanged(GenerateFlatClosure(RefreshGamepadReticle_TargetChanged, self), self);

	self:Recenter();
	self:Show();

	if C_GamePad.GetAllowHoverEventsWithFreeLook() then
		self:RefreshGamepadReticle(true);
	else
		C_GamePad.SetAllowHoverEventsWithFreeLook(true);
	end
end

function GamepadReticleMixin:UninitForGamepad()
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("PLAYER_TARGET_CHANGED");
	self:UnregisterEvent("GAME_PAD_ALLOW_HOVER_EVENTS_WITH_FREE_LOOK_CHANGED");
	GamepadMode.UnregisterTargetModifierVisualStateChanged(self);

	self:Hide();

	C_GamePad.SetAllowHoverEventsWithFreeLook(false);
end
