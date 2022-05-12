-- Factory for animated frames.
-- The factory template requires Play(...), where ... are optional arguments forwarded
-- at the factory callsite. The derived factory requires Attach(frame, target), and must
-- invoke EffectFactoryMixin.OnLoad() with the desired template name.
-- See GlowEmitter.lua as example.

EffectFactoryMixin = {};

function EffectFactoryMixin:OnLoad(template)
	self.template = template;
end

function EffectFactoryMixin:Show(target, ...)
	if not self.pool then
		self.pool = CreateFramePool("FRAME", nil, self.template);
	end

	if not self:GetExisting(target) then
		local frame = self.pool:Acquire();
		frame.target = target;

		self:Attach(frame, target);

		frame:Show();
		frame:Play(...);
	end
end

function EffectFactoryMixin:Hide(target)
	local frame = self:GetExisting(target);
	if frame then
		frame:StopAnimating();

		self.pool:Release(frame);
	end
end

function EffectFactoryMixin:SetShown(target, shown, ...)
	if shown then
		self:Show(target, ...);
	else
		self:Hide(target);
	end
end

function EffectFactoryMixin:GetExisting(target)
	if self.pool then
		for frame in self.pool:EnumerateActive() do
			if frame.target == target then
				return frame;
			end
		end
	end
end