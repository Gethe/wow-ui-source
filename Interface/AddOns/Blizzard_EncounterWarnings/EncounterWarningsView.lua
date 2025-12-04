EncounterWarningsViewMixin = CreateFromMixins(EncounterWarningsSettingsMixin, ResizeLayoutMixin);

function EncounterWarningsViewMixin:OnLoad()
	EncounterWarningsSettingsMixin.OnLoad(self);

	self:SetMouseClickEnabled(false);

	self.currentWarningInfo = nil;
	self.expirationTimer = nil;
	self.hideOnMouseLeave = false;
end

function EncounterWarningsViewMixin:OnShow()
	ResizeLayoutMixin.OnShow(self);
end

function EncounterWarningsViewMixin:OnHide()
	self:ResetWarning();
end

function EncounterWarningsViewMixin:OnEnter()
	local shouldShowTooltip = self:GetTooltipsEnabled(self);
	self:SetTooltipShown(shouldShowTooltip);
end

function EncounterWarningsViewMixin:OnLeave()
	self:SetTooltipShown(false);

	if self.hideOnMouseLeave then
		self.hideOnMouseLeave = false;
		self:HideWarning();
	end
end

function EncounterWarningsViewMixin:OnIconScaleChanged(_iconScale)
	self:UpdateIconScale();
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

function EncounterWarningsViewMixin:GetTooltipFrame()
	return GameTooltip;
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

	self:ResetWarning();
	self.currentWarningInfo = encounterWarningInfo;

	for _, element in ipairs(self:GetWarningElements()) do
		element:Init(encounterWarningInfo, self);
	end

	self:StartExpirationTimer(encounterWarningInfo.duration);
	self:PlayShowAnimation();  -- Implicitly calls Show().

	-- The following logic _could_ be moved to the OnShow handler, but as
	-- it needs access to the encounter warning info which we know for sure
	-- isn't nil here, we'll do it inline.

	if encounterWarningInfo.shouldPlaySound then
		C_EncounterWarnings.PlaySound(encounterWarningInfo.severity);
	end

	if encounterWarningInfo.shouldShowChatMessage then
		EncounterWarningsUtil.ShowChatMessageForWarning(encounterWarningInfo);
	end
end

function EncounterWarningsViewMixin:HideWarning()
	if not self:HasCurrentWarning() then
		return;
	end

	self:CancelExpirationTimer();
	self:PlayHideAnimation();
end

function EncounterWarningsViewMixin:ResetWarning()
	if not self:HasCurrentWarning() then
		return;
	end

	for _, element in ipairs(self:GetWarningElements()) do
		element:Reset();
	end

	self:CancelExpirationTimer();
	self.currentWarningInfo = nil;
end

function EncounterWarningsViewMixin:ClearWarning()
	if not self:HasCurrentWarning() then
		return;
	end

	-- Reset needs to be explicit here as there exist call sequences where
	-- the OnHide script may be deferred and not executed immediately.

	self:ResetWarning();
	self:Hide();
end

function EncounterWarningsViewMixin:StartExpirationTimer(duration)
	local timer;

	local function OnWarningExpired()
		if self.expirationTimer == timer then
			self:CancelExpirationTimer();
		end

		if self:IsMouseOver() then
			self.hideOnMouseLeave = true;
		else
			self:HideWarning();
		end
	end

	self:CancelExpirationTimer();

	-- We allow a zero duration for "static" alerts, eg. those triggered when
	-- idling in edit mode.

	if duration ~= 0 then
		timer = C_Timer.NewTimer(duration, OnWarningExpired);
		self.expirationTimer = timer;
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

function EncounterWarningsViewMixin:SetTooltipShown(shown)
	local tooltip = self:GetTooltipFrame();
	local encounterWarningInfo = self:GetCurrentWarning();

	if shown and encounterWarningInfo ~= nil then
		GameTooltip_SetDefaultAnchor(tooltip, self);
		tooltip:SetSpellByID(encounterWarningInfo.tooltipSpellID);
	elseif tooltip:IsOwned(self) then
		tooltip:Hide();
	end
end

function EncounterWarningsViewMixin:UpdateIconScale()
	-- Icon scale is processed external to the icon elements because it's
	-- easier for us to handle dynamic changes to them in edit mode and
	-- apply them here than confine the setup of the icon scale to the
	-- Init method of the element.

	local iconScale = self:GetIconScale(self);
	self:GetLeftIconElement():SetScale(iconScale);
	self:GetRightIconElement():SetScale(iconScale);
end
