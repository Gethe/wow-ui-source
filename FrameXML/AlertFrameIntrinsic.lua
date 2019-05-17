-- [[ ContainedAlertFrameMixin ]] --
ContainedAlertFrameMixin = {};

function ContainedAlertFrameMixin:OnPostShow()
	self:OnManagedAlertFrameVisibilityChanged();
end

function ContainedAlertFrameMixin:OnPostHide()
	self:OnManagedAlertFrameVisibilityChanged();
end

function ContainedAlertFrameMixin:SetAlertContainer(container)
	self.alertContainer = container;
end

function ContainedAlertFrameMixin:GetAlertContainer()
	return self.alertContainer;
end

function ContainedAlertFrameMixin:OnManagedAlertFrameVisibilityChanged()
	self:GetAlertContainer():UpdateAnchors();
end

function ContainedAlertFrameMixin:ManagesOwnOutroAnimation()
	return not self.externallyManagedOutroAnimation;
end

function ContainedAlertFrameMixin:SetExternallyManagedOutroAnimation(externallyManagedAnimation)
	self.externallyManagedOutroAnimation = externallyManagedAnimation;
end