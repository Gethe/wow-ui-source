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

EasyFrameAnimationsMixin = { };

local function IterateAllAnimationGroups(frame, func)
	local animGroups = { frame:GetAnimationGroups() };
	for _, animGroup in ipairs(animGroups) do
		func(animGroup);
	end

	local children = { frame:GetChildren() };
	for _, child in ipairs(children) do
		IterateAllAnimationGroups(child, func);
	end
end

function EasyFrameAnimationsMixin:PlayAnims()
	IterateAllAnimationGroups(self, function(animGroup)
		animGroup:Play();
	end);
end

function EasyFrameAnimationsMixin:StopAnims()
	IterateAllAnimationGroups(self, function(animGroup)
		animGroup:Stop();
	end);
end
