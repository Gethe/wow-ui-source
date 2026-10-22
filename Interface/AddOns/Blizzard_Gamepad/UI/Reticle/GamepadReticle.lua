--[[
	A small indicator in the middle of the screen to help aim automatic targeting and interactions on gamepad.
]]

GamepadReticleMixin = {};

function GamepadReticleMixin:OnLoad()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitForGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitForGamepad, self));

	self.SwingTimer:HookScript("OnShow", GenerateClosure(self.OnSwingTimerShow, self));
	self.SwingTimer:HookScript("OnHide", GenerateClosure(self.OnSwingTimerHide, self));
end

function GamepadReticleMixin:OnEvent(event, ...)
	if (event == "DISPLAY_SIZE_CHANGED") then
		self:Recenter();
	end
end

function GamepadReticleMixin:Recenter()
	self:ClearAllPoints();
	local _, y = GetCursorCenterPosition();
	self:SetPoint("CENTER", UIParent, "BOTTOM", 0, y / self:GetEffectiveScale());
end

function GamepadReticleMixin:InitForGamepad()
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:Recenter();
	self:Show();
end

function GamepadReticleMixin:UninitForGamepad()
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:Hide();
end

function GamepadReticleMixin:OnSwingTimerShow()
	UIFrameFadeOut(self.Icons, 0.1);
end

function GamepadReticleMixin:OnSwingTimerHide()
	UIFrameFadeIn(self.Icons, 0.1);
end

function GamepadReticleMixin:OnUpdate()
	local isCursorVis = IsCursorVisible();
	self.Icons:SetShown(not isCursorVis);

	self.SwingTimer.enabledCursorVis = not isCursorVis;
	self.SwingTimer:RefreshEnabled();
end

GamepadReticleSwingTimerMixin = {};

local function HasMeleeOffHandWeapon()
	local _, offHandAttackSpeed = UnitAttackSpeed("player");
	return offHandAttackSpeed ~= nil and offHandAttackSpeed > 0;
end

function GamepadReticleSwingTimerMixin:OnLoad()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.RefreshEnabled, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.RefreshEnabled, self));

	for _, animGroup in ipairs({self.FullCircleAnim, self.LeftSideAnim, self.RightSideAnim }) do
		-- Make sure all the anims start empty
		animGroup:SetScript("OnFinished", GenerateClosure(self.OnAnimEnded, self, animGroup));
		animGroup:SetScript("OnStop", GenerateClosure(self.OnAnimEnded, self, animGroup));
	end

	self.enabledCursorVis = not IsCursorVisible();

	CVarCallbackRegistry:RegisterCallback("GamepadEnableReticleSwingTimer", self.OnEnableCVarChanged, self);
	self:OnEnableCVarChanged(GetCVar("GamepadEnableReticleSwingTimer"));
end

function GamepadReticleSwingTimerMixin:OnEnableCVarChanged(newValue)
	self.enabled = (newValue ~= "0");
	self:RefreshEnabled();
end

function GamepadReticleSwingTimerMixin:RefreshEnabled()
	if InputUtil.IsGamepadUIEnabled() and self.enabled and self.enabledCursorVis then
		if not self.initialized then
			self.initialized = true;
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			self:RegisterEvent("PLAYER_SWING");
			self:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player");
			self:RefreshOffHand();
		end
	elseif self.initialized then
		self.initialized = false;
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		self:UnregisterEvent("PLAYER_SWING");
		self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
		self:RefreshVisibility();
	end
end

function GamepadReticleSwingTimerMixin:OnEvent(event, ...)
	if event == "PLAYER_SWING" then
		local duration, type = ...;
		local anim = self.FullCircleAnim;
		if self.hasOffHand then
			if type == Enum.PlayerSwingType.OffHand then
				anim = self.LeftSideAnim;
			else
				anim = self.RightSideAnim;
			end
		end
		self:PlaySwingAnim(anim, duration);
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:RefreshOffHand();
	elseif event == "UNIT_INVENTORY_CHANGED" then
		local unitToken = ...;
		if unitToken == "player" then
			self:RefreshOffHand();
		end
	end
end

local function SetAnimDuration(animGroup, duration)
	for _, anim in ipairs({animGroup:GetAnimations()}) do
		anim:SetDuration(duration);
	end
end

function GamepadReticleSwingTimerMixin:RefreshOffHand()
	local hasOffHandWeapon = HasMeleeOffHandWeapon();
	if self.hasOffHand == hasOffHandWeapon then
		return;
	end

	self.hasOffHand = hasOffHandWeapon;

	-- Make sure the animations become visible from the start
	if hasOffHandWeapon then
		self.LeftSideAnim:Restart();
		self.LeftSideAnim:Pause();
		self.RightSideAnim:Restart();
		self.RightSideAnim:Pause();
	else
		self.FullCircleAnim:Restart();
		self.FullCircleAnim:Pause();
	end

	self.LoadBarGlow:SetShown(not hasOffHandWeapon);
	self.LoadBar:SetShown(not hasOffHandWeapon);
	self.SpinnerTip:SetShown(not hasOffHandWeapon);

	self.LeftSideLoadBarGlow:SetShown(hasOffHandWeapon);
	self.LeftSideLoadBar:SetShown(hasOffHandWeapon);
	self.LeftSideSpinnerTip:SetShown(hasOffHandWeapon);

	self.RightSideLoadBarGlow:SetShown(hasOffHandWeapon);
	self.RightSideLoadBar:SetShown(hasOffHandWeapon);
	self.RightSideSpinnerTip:SetShown(hasOffHandWeapon);

	-- Hide first to make sure we don't fade out the new animation that hasn't played yet
	self:Hide();
	self:RefreshVisibility();
end

function GamepadReticleSwingTimerMixin:PlaySwingAnim(animGroup, duration)
	SetAnimDuration(animGroup, duration);

	animGroup:Restart();
	animGroup.isPlaying = true;

	self:SetVisibility(true);
end

function GamepadReticleSwingTimerMixin:IsAnyVisibleAnimationPlaying()
	if self.hasOffHand then
		return self.LeftSideAnim.isPlaying or self.RightSideAnim.isPlaying;
	end

	return self.FullCircleAnim.isPlaying;
end

function GamepadReticleSwingTimerMixin:OnAnimEnded(animGroup)
	animGroup.isPlaying = false;
	self:RefreshVisibility();
end

function GamepadReticleSwingTimerMixin:RefreshVisibility()
	if self.enabled then
		local shouldKeepVisible = self:IsAnyVisibleAnimationPlaying();
		self:SetVisibility(shouldKeepVisible);
	else
		self:SetVisibility(false);
	end
end

function GamepadReticleSwingTimerMixin:SetVisibility(visible)
	local isFading = UIFrameIsFading(self);

	-- Abort any conflicting pre-existing fade and snap back to what it should be. It typically
	-- just means we're right in between two attacks.
	if visible then
		if isFading then
			if self.fadeInfo.mode ~= "IN" then
				UIFrameFadeRemoveFrame(self);
				self:SetAlpha(1);
			end
		elseif not self:IsShown() then
			local fadeInfo = {};
			fadeInfo.mode = "IN";
			fadeInfo.timeToFade = 0.2;
			UIFrameFade(self, fadeInfo);
		end
	else
		if isFading then
			if self.fadeInfo.mode ~= "OUT" then
				UIFrameFadeRemoveFrame(self);
				self:Hide();
			end
		elseif self:IsShown() then
			local fadeInfo = {};
			fadeInfo.mode = "OUT";
			fadeInfo.timeToFade = 0.2;
			fadeInfo.finishedFunc = self.Hide;
			fadeInfo.finishedArg1 = self;
			UIFrameFade(self, fadeInfo);
		end
	end
end
