--[[
Factory for animated frames.

The template frame must implement Play(animEnum) and forward the Play() call 
to the appropriate animation object.

The derived factory must call Init() with the frame type, template name, 
and implement Attach() for any custom position handling.

See GlowEmitter.lua as an example.
]]--

EffectFactoryMixin = {};

-- Derive
function EffectFactoryMixin:Init(frameType, template)
	self.pool = CreateFramePool(frameType, nil, template);
end

-- Derive
function EffectFactoryMixin:Attach(frame, target, offsetX, offsetY, width, height)
	frame:SetParent(target);

	local strata = frame:GetFrameStrata();
	frame:SetFrameStrata(strata);
	frame:ClearAllPoints();
	
	if not frame.originalWidth then
		frame.originalWidth = frame:GetWidth();
	end

	if not frame.originalHeight then
		frame.originalHeight = frame:GetHeight();
	end

	frame:SetWidth(width or frame.originalWidth);
	frame:SetHeight(height or frame.originalHeight);
end

function EffectFactoryMixin:Show(target, animEnum, offsetX, offsetY, width, height)
	assert(animEnum ~= nil, "EffectFactory missing animEnum");

	if self:HasExisting(target) then
		return;
	end

	local frame = self.pool:Acquire();
	frame.target = target;

	self:Attach(frame, target, offsetX, offsetY, width, height);

	frame:Show();
	frame:Play(animEnum);
end

function EffectFactoryMixin:Hide(target)
	local frame = self:GetExisting(target);
	if not frame then
		return;
	end

	frame:StopAnimating();
	
	self.pool:Release(frame);
end

function EffectFactoryMixin:SetShown(shown, target, animEnum, offsetX, offsetY, width, height)
	if shown then
		self:Show(target, animEnum, offsetX, offsetY, width, height);
	else
		self:Hide(target);
	end
end

function EffectFactoryMixin:GetExisting(target)
	for frame in self.pool:EnumerateActive() do
		if frame.target == target then
			return frame;
		end
	end
end

function EffectFactoryMixin:HasExisting(target)
	return self:GetExisting(target) ~= nil;
end