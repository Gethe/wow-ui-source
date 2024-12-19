LoginWarningDialogBaseMixin = {};

-- Override in inheriting mixins
function LoginWarningDialogBaseMixin:ShouldShow()
	return false;
end

function LoginWarningDialogBaseMixin:TryShow()
	if self:ShouldShow() then
		self:Show();
		return true;
	else
		self:Hide();
		return false;
	end
end

ChinaAgeAppropriatenessWarningMixin = CreateFromMixins(LoginWarningDialogBaseMixin);

function ChinaAgeAppropriatenessWarningMixin:OnLoad()
	self.OkayButton:SetScript("OnClick", GenerateClosure(self.OnAcknowledged, self));
end

function ChinaAgeAppropriatenessWarningMixin:ShouldShow()
	return self.localeMatches and not self.wasAccepted and not C_Login.WasEverLauncherLogin();
end

function ChinaAgeAppropriatenessWarningMixin:OnAcknowledged()
	self.wasAccepted = true;
	self:Hide();
	EventRegistry:TriggerEvent("LoginWarningDialogs.DialogClosed");
end

KoreanRatingsMixin = CreateFromMixins(LoginWarningDialogBaseMixin);

function KoreanRatingsMixin:OnLoad()
	if WasScreenFirstDisplayed() then
		self:ScreenDisplayed();
	else
		self:RegisterEvent("SCREEN_FIRST_DISPLAYED");
	end
end

function KoreanRatingsMixin:OnEvent(event, ...)
	if event == "SCREEN_FIRST_DISPLAYED" then
		self:ScreenDisplayed();
		self:UnregisterEvent("SCREEN_FIRST_DISPLAYED");
	end
end

function KoreanRatingsMixin:ScreenDisplayed()
	self:SetScript("OnUpdate", self.OnUpdate);
end

function KoreanRatingsMixin:ShouldShow()
	return self.localeMatches and not self.wasShown;
end

function KoreanRatingsMixin:OnShow()
	self.wasShown = true;
	self.closeTimer = 3;
end

function KoreanRatingsMixin:OnUpdate(elapsed)
	self.closeTimer = self.closeTimer - elapsed;
	if self.closeTimer <= 0 then
		self.closeTimer = nil;
		self:SetScript("OnUpdate", nil);
		self:Hide();
		EventRegistry:TriggerEvent("LoginWarningDialogs.DialogClosed");
	end
end

TaiwanFraudWarningMixin = CreateFromMixins(LoginWarningDialogBaseMixin);

function TaiwanFraudWarningMixin:OnLoad()
	self.disableHideOnEscape = true;
	self.OkayButton:SetScript("OnClick", GenerateClosure(self.OnAcknowledged, self));
end

function TaiwanFraudWarningMixin:ShouldShow()
	return self.localeMatches and not self.wasAccepted and not GetCVarBool(self.noShowCvar);
end

function TaiwanFraudWarningMixin:OnShow()
	GlueParent_AddModalFrame(self);
end

function TaiwanFraudWarningMixin:OnHide()
	SetCVar(self.noShowCvar, self.DoNotShowAgainCheckbox:IsControlChecked());
	GlueParent_RemoveModalFrame(self);
end

function TaiwanFraudWarningMixin:OnAcknowledged()
	self.wasAccepted = true;
	self:Hide();
	EventRegistry:TriggerEvent("LoginWarningDialogs.DialogClosed");
end