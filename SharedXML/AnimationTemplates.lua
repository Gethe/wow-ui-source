VisibleWhilePlayingAnimGroupMixin = {}

function VisibleWhilePlayingAnimGroupMixin:Show()
	self:GetParent():Show();
end

function VisibleWhilePlayingAnimGroupMixin:Hide()
	self:GetParent():Hide();
end