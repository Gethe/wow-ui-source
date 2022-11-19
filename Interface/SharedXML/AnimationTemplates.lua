VisibleWhilePlayingAnimGroupMixin = {}

function VisibleWhilePlayingAnimGroupMixin:Show()
	self:GetParent():Show();
end

function VisibleWhilePlayingAnimGroupMixin:Hide()
	self:GetParent():Hide();
end

TargetsVisibleWhilePlayingAnimGroupMixin = {}

function TargetsVisibleWhilePlayingAnimGroupMixin:Show()
	self:SetTargetsShown(true, self:GetAnimations());
end

function TargetsVisibleWhilePlayingAnimGroupMixin:Hide()
	self:SetTargetsShown(false, self:GetAnimations());
end

function TargetsVisibleWhilePlayingAnimGroupMixin:SetTargetsShown(shown, ...)
	for i = 1, select("#", ...) do
		local anim = select(i, ...);
		if anim then
			local target = anim:GetTarget();
			if target and target.SetShown then
				target:SetShown(shown);
			end
		end
	end
end