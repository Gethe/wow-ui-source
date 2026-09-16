local SHOW_SWING_TIMER_CVAR = "showSwingTimer";
local OUT_OF_RANGE_ALPHA = 0.4;
CVarCallbackRegistry:SetCVarCachable(SHOW_SWING_TIMER_CVAR);

SwingTimerMixin = {};

function SwingTimerMixin:GetBackground()
	return self.Background;
end

function SwingTimerMixin:GetBorder()
	return self.Border;
end

function SwingTimerMixin:GetStatusBar()
	return self.StatusBar;
end

function SwingTimerMixin:GetStatusBarPip()
	local statusBar = self:GetStatusBar();
	return statusBar.Pip;
end

function SwingTimerMixin:GetTypeLabel()
	local statusBar = self:GetStatusBar();
	return statusBar.TypeLabel;
end

function SwingTimerMixin:GetTypeLabelShadow()
	local statusBar = self:GetStatusBar();
	return statusBar.TypeLabelShadow;
end

function SwingTimerMixin:GetTimeLabel()
	local statusBar = self:GetStatusBar();
	return statusBar.TimeLabel;
end

function SwingTimerMixin:OnLoad()
	EditModeSystemMixin.OnSystemLoad(self);

	CVarCallbackRegistry:RegisterCallback(SHOW_SWING_TIMER_CVAR, self.OnVisibilityCVarChanged, self);
	self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("WEAPON_SLOT_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_SWING_RANGE_UPDATE");
	self:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player");

	self:InitializeBarPresentation();
	self:ClearSwingTimer();
	self:UpdateShownStateAndRegistration();
end

function SwingTimerMixin:OnHide()
	EditModeSystemMixin.OnSystemHide(self);

	self:ClearSwingTimer();
end

function SwingTimerMixin:OnEvent(event, ...)
	if event == "PLAYER_SWING" then
		local swingDuration, swingType = ...;
		if self.swingType == swingType then
			self:ResetSwingTimer(swingDuration);
		end
	elseif event == "PLAYER_IN_COMBAT_CHANGED" then
		self:UpdateShownState();
	elseif event == "PLAYER_TARGET_CHANGED" then
		self:UpdateRangeState();
	elseif event == "WEAPON_SLOT_CHANGED" then
		self:UpdateShownStateAndRegistration();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UpdateShownStateAndRegistration();
	elseif event == "UNIT_ATTACK_SPEED" then
		self:UpdateShownStateAndRegistration();
	elseif event == "PLAYER_SWING_RANGE_UPDATE" then
		local swingType, isInRange, checksRange = ...;
		if self.swingType == swingType then
			self:SetOutOfRange(checksRange and not isInRange);
		end
	end
end

function SwingTimerMixin:CanSwingOffHand()
	local _mainHandAttackSpeed, offHandAttackSpeed = UnitAttackSpeed("player");
	return offHandAttackSpeed ~= nil and offHandAttackSpeed > 0;
end

function SwingTimerMixin:CanSwingRanged()
	local _mainHandAttackSpeed, _offHandAttackSpeed, rangedAttackSpeed = UnitAttackSpeed("player");
	return rangedAttackSpeed ~= nil and rangedAttackSpeed > 0;
end

function SwingTimerMixin:CanSwing()
	if self.swingType == Enum.PlayerSwingType.OffHand then
		return self:CanSwingOffHand();
	elseif self.swingType == Enum.PlayerSwingType.Ranged then
		return self:CanSwingRanged();
	end

	return true;
end

function SwingTimerMixin:ShouldBeShown()
	if self.isInEditMode then
		return true;
	end

	local swingTimerEnabled = CVarCallbackRegistry:GetCVarValueBool(SHOW_SWING_TIMER_CVAR);
	if not swingTimerEnabled then
		return false;
	end

	if not self:CanSwing() then
		return false;
	end

	if self.visibility == Enum.EditModeSwingTimerVisibility.Always then
		return true;
	elseif self.visibility == Enum.EditModeSwingTimerVisibility.InCombat then
		return UnitAffectingCombat("player");
	elseif self.visibility == Enum.EditModeSwingTimerVisibility.Hidden then
		return false;
	end

	return true;
end

function SwingTimerMixin:ShouldRegisterSwingEvent()
	local swingTimerEnabled = CVarCallbackRegistry:GetCVarValueBool(SHOW_SWING_TIMER_CVAR);
	if not swingTimerEnabled then
		return false;
	end

	if not self:CanSwing() then
		return false;
	end

	-- Rather than using OnShow/OnHide, the event needs to be registered when visibility is set to InCombat
	-- so the first swing when entering combat is captured.
	return self.visibility == Enum.EditModeSwingTimerVisibility.Always or self.visibility == Enum.EditModeSwingTimerVisibility.InCombat;
end

function SwingTimerMixin:ShouldCheckRange()
	return self:ShouldRegisterSwingEvent();
end

function SwingTimerMixin:UpdateSwingEventRegistration()
	local shouldRegister = self:ShouldRegisterSwingEvent();
	if shouldRegister then
		if not self:IsEventRegistered("PLAYER_SWING") then
			self:RegisterEvent("PLAYER_SWING");
		end
	elseif self:IsEventRegistered("PLAYER_SWING") then
		self:UnregisterEvent("PLAYER_SWING");
		self:ClearSwingTimer();
	end
end

function SwingTimerMixin:InitializeBarPresentation()
	local typeLabel = self:GetTypeLabel();
	typeLabel:SetText(self.typeText);

	local statusBar = self:GetStatusBar();
	statusBar:SetStatusBarTexture(self.barTexture);

	local statusBarTexture = statusBar:GetStatusBarTexture();
	local statusBarPip = self:GetStatusBarPip();
	statusBarPip:ClearAllPoints();
	statusBarPip:SetPoint("RIGHT", statusBarTexture, "RIGHT", 0, 0);
end

function SwingTimerMixin:UpdateShownState()
	local shouldShow = self:ShouldBeShown();
	self:SetShown(shouldShow);
	self:UpdateRangeState();
end

function SwingTimerMixin:SetIsInEditMode(isInEditMode)
	self.isInEditMode = isInEditMode;
	self:UpdateShownState();

	-- Edit mode suppresses the out of range visuals without changing the underlying range state.
	self:ApplyRangePresentation();
end

function SwingTimerMixin:UpdateShownStateAndRegistration()
	self:UpdateRangeCheckRegistration();
	self:UpdateShownState();
	self:UpdateSwingEventRegistration();
end

function SwingTimerMixin:OnVisibilityCVarChanged()
	self:UpdateShownStateAndRegistration();
end

function SwingTimerMixin:ClearSwingTimer()
	self.swingDuration = nil;
	self.swingEndTime = nil;
	self:SetScript("OnUpdate", nil);

	local statusBar = self:GetStatusBar();
	statusBar:SetValue(0);

	local statusBarPip = self:GetStatusBarPip();
	statusBarPip:Hide();

	local timeLabel = self:GetTimeLabel();
	timeLabel:SetText("0.0");
end

function SwingTimerMixin:ResetSwingTimer(duration)
	if not duration or duration <= 0 then
		return;
	end

	self.swingDuration = duration;
	self.swingEndTime = GetTime() + duration;
	self:SetScript("OnUpdate", self.OnUpdate);

	local statusBar = self:GetStatusBar();
	statusBar:SetValue(0);

	local statusBarPip = self:GetStatusBarPip();
	statusBarPip:Show();

	local timeLabel = self:GetTimeLabel();
	timeLabel:SetFormattedText("%.1f", duration);
end

function SwingTimerMixin:OnUpdate(_elapsed)
	if not self.swingEndTime or not self.swingDuration then
		return;
	end

	local remaining = self.swingEndTime - GetTime();
	if remaining <= 0 then
		self:ClearSwingTimer();
		return;
	end

	local statusBar = self:GetStatusBar();
	statusBar:SetValue((self.swingDuration - remaining) / self.swingDuration);

	local timeLabel = self:GetTimeLabel();
	timeLabel:SetFormattedText("%.1f", remaining);
end

function SwingTimerMixin:IsOutOfRange()
	if self.isInEditMode then
		return false;
	end

	return self.isOutOfRange == true;
end

function SwingTimerMixin:IsRangeCheckEnabled()
	return self.isRangeCheckEnabled == true;
end

function SwingTimerMixin:UpdateRangeCheckRegistration()
	local shouldCheckRange = self:ShouldCheckRange();
	if shouldCheckRange == self:IsRangeCheckEnabled() then
		return;
	end

	self.isRangeCheckEnabled = shouldCheckRange;
	C_SwingTimer.EnableRangeCheck(self.swingType, shouldCheckRange);
end

function SwingTimerMixin:SetOutOfRange(isOutOfRange)
	if self.isOutOfRange == isOutOfRange then
		return;
	end

	self.isOutOfRange = isOutOfRange;
	self:ApplyRangePresentation();
end

function SwingTimerMixin:UpdateRangeState()
	if not self:IsRangeCheckEnabled() then
		self:SetOutOfRange(false);
		return;
	end

	local isInRange = C_SwingTimer.IsTargetWithinSwingRange(self.swingType);
	self:SetOutOfRange(isInRange == false);
end

function SwingTimerMixin:ApplyRangePresentation()
	local isOutOfRange = self:IsOutOfRange();

	local alpha = isOutOfRange and OUT_OF_RANGE_ALPHA or 1;

	local background = self:GetBackground();
	background:SetAlpha(alpha);

	local border = self:GetBorder();
	border:SetAlpha(alpha);

	-- Dims the pip, labels and title shadow along with it, as they are all regions of the status bar.
	local statusBar = self:GetStatusBar();
	statusBar:SetAlpha(alpha);

	local textColor = isOutOfRange and RED_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
	local r, g, b = textColor:GetRGB();

	local typeLabel = self:GetTypeLabel();
	typeLabel:SetTextColor(r, g, b);

	local timeLabel = self:GetTimeLabel();
	timeLabel:SetTextColor(r, g, b);
end
