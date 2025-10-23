EncounterWarningsViewMixin = CreateFromMixins(EncounterWarningsViewSettingsMixin, ResizeLayoutMixin);

function EncounterWarningsViewMixin:OnLoad()
	self.currentWarningInfo = nil;
	self.expirationTimer = nil;
end

function EncounterWarningsViewMixin:OnShow()
	ResizeLayoutMixin.OnShow(self);
end

function EncounterWarningsViewMixin:OnHide()
	self:ClearWarning();
end

function EncounterWarningsViewMixin:OnViewSettingChanged(setting, _value)
	if setting == EncounterWarningsViewSetting.IconScale then
		self:UpdateIconScale();
	end
end

function EncounterWarningsViewMixin:GetViewSetting(setting)
	local value = self:GetAttribute(setting);

	if value == nil then
		value = EncounterWarningsUtil.GetDefaultViewSetting(setting);
	end

	return value;
end

function EncounterWarningsViewMixin:SetViewSetting(setting, value)
	if self:GetViewSetting(setting) == value then
		return;
	end

	self:SetAttribute(setting, value);
	self:OnViewSettingChanged(setting, value);
end

function EncounterWarningsViewMixin:GetTextElement()
	return self.Text;
end

function EncounterWarningsViewMixin:GetLeftIconElement()
	return self.LeftIcon;
end

function EncounterWarningsViewMixin:GetRightIconElement()
	return self.RightIcon;
end

function EncounterWarningsViewMixin:GetAnimationElement()
	return self.SwingAnimation;
end

function EncounterWarningsViewMixin:GetWarningElements()
	return { self:GetTextElement(), self:GetLeftIconElement(), self:GetRightIconElement(), self:GetAnimationElement() };
end

function EncounterWarningsViewMixin:GetCurrentWarning()
	return self.currentWarningInfo;
end

function EncounterWarningsViewMixin:HasCurrentWarning()
	return self.currentWarningInfo ~= nil;
end

function EncounterWarningsViewMixin:ShouldShowWarning(_encounterWarningInfo)
	-- Extension point in case we need local filtering of warnings.
	return true;
end

function EncounterWarningsViewMixin:ShowWarning(encounterWarningInfo)
	-- Note that we evaluate whether or not a warning should show before
	-- clearing the existing one (if any).

	if not self:ShouldShowWarning(encounterWarningInfo) then
		return;
	end

	self:ClearWarning();
	self.currentWarningInfo = encounterWarningInfo;

	for _, element in ipairs(self:GetWarningElements()) do
		element:Init(encounterWarningInfo, self);
	end

	self:StartExpirationTimer(encounterWarningInfo.duration);
	self:PlayShowAnimation();  -- Implicitly calls Show().

	-- The following logic _could_ be moved to the OnShow handler, but as
	-- it needs access to the encounter warning info which we know for sure
	-- isn't nil here, we'll do it inline.

	-- Addons can customize whether or not we route alerts to sound or chat
	-- on a per-severity basis via extra view settings.

	if encounterWarningInfo.shouldPlaySound then
		if EncounterWarningsViewSettings.AreSoundAlertsEnabled(self) then
			C_EncounterWarnings.PlaySound(encounterWarningInfo.severity);
		end
	end

	if encounterWarningInfo.shouldShowChatMessage then
		if EncounterWarningsViewSettings.AreChatAlertsEnabled(self) then
			EncounterWarningsUtil.ShowChatMessageForWarning(encounterWarningInfo);
		end
	end
end

function EncounterWarningsViewMixin:HideWarning()
	if not self:HasCurrentWarning() then
		return;
	end

	self:CancelExpirationTimer();
	self:PlayHideAnimation();
end

function EncounterWarningsViewMixin:ClearWarning()
	if not self:HasCurrentWarning() then
		return;
	end

	for _, element in ipairs(self:GetWarningElements()) do
		element:Reset();
	end

	self:CancelExpirationTimer();
	self.currentWarningInfo = nil;

	-- Hiding must be done last as our OnHide script also invokes this
	-- function, which early returns so long as this is sequenced after
	-- having nil'd out the current warning above.

	self:Hide();
end

function EncounterWarningsViewMixin:StartExpirationTimer(duration)
	local function OnWarningExpired()
		self:HideWarning();
	end

	self:CancelExpirationTimer();

	-- We allow a nil duration for "static" alerts, eg. those triggered when
	-- idling in edit mode.

	if duration ~= nil then
		self.expirationTimer = C_Timer.NewTimer(duration, OnWarningExpired);
	end
end

function EncounterWarningsViewMixin:CancelExpirationTimer()
	if self.expirationTimer ~= nil then
		self.expirationTimer:Cancel();
		self.expirationTimer = nil;
	end
end

function EncounterWarningsViewMixin:PlayHideAnimation()
	local animationGroup = self:GetAnimationElement();
	local reverse = true;
	animationGroup:Stop();
	animationGroup:SetScript("OnPlay", nil);
	animationGroup:SetScript("OnFinished", function() self:Hide(); end);
	animationGroup:Play(reverse);
end

function EncounterWarningsViewMixin:PlayShowAnimation()
	local animationGroup = self:GetAnimationElement();
	animationGroup:Stop();
	animationGroup:SetScript("OnPlay", function() self:Show(); end);
	animationGroup:SetScript("OnFinished", nil);
	animationGroup:Play();
end

function EncounterWarningsViewMixin:StopAnimating()
	local animationGroup = self:GetAnimationElement();
	animationGroup:SetScript("OnPlay", nil);
	animationGroup:SetScript("OnFinished", nil);
	animationGroup:Stop();
end

function EncounterWarningsViewMixin:UpdateIconScale()
	-- Icon scale is processed external to the icon elements because it's
	-- easier for us to handle dynamic changes to them in edit mode and
	-- apply them here than confine the setup of the icon scale to the
	-- Init method of the element.

	local iconScale = EncounterWarningsViewSettings.GetIconScale(self);
	self:GetLeftIconElement():SetScale(iconScale);
	self:GetRightIconElement():SetScale(iconScale);
end
