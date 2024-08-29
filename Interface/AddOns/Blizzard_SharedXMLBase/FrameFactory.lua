local FrameFactoryMixin = {};

function FrameFactoryMixin:Init()
	self.templateInfoCache = CreateTemplateInfoCache();
	self.poolCollection = self:CreateFramePoolCollection();
end

function FrameFactoryMixin:CreateFramePoolCollection()
	return CreateFramePoolCollection();
end

function FrameFactoryMixin:Create(parent, frameTemplateOrFrameType, resetterFunc)
	local frameTemplate = nil;
	local frameType = nil;
	local specialization = nil;

	local info = self.templateInfoCache:GetTemplateInfo(frameTemplateOrFrameType);
	if info then
		frameTemplate = frameTemplateOrFrameType;
		frameType = info.type;
	else
		-- Couldn't obtain template info, so the presumption is that this is a native frame type.
		frameTemplate = "";
		frameType = frameTemplateOrFrameType;
		specialization = frameType;
	end

	-- The frame type is passed as a specialization argument if this is deduced to be a native frame type (i.e. button, frame) to
	-- enable the pool collection to support multiple buckets of intrinsic frame types. We're not leveraging it to provide any
	-- custom initialization of the frame, but only to define a distinct key for each frame bucket.
	local forbidden = nil;
	local pool = self.poolCollection:GetOrCreatePool(frameType, parent, frameTemplate, resetterFunc, forbidden, specialization);
	local frame, new = pool:Acquire();

	if not frame then
		error(string.format("ScrollBoxListViewMixin: Failed to create a frame from pool for frame template or frame type '%s'", frameTemplateOrFrameType));
	end

	return frame, new, info;
end

function FrameFactoryMixin:GetTemplateInfoCache()
	return self.templateInfoCache;
end

function FrameFactoryMixin:GetNumActive()
	return self.poolCollection:GetNumActive();
end

function FrameFactoryMixin:ReleaseAll()
	self.poolCollection:ReleaseAll();
end

function FrameFactoryMixin:Release(frame)
	self.poolCollection:Release(frame);
end

function CreateFrameFactory()
	local frameFactory = CreateFromMixins(FrameFactoryMixin);
	frameFactory:Init();
	return frameFactory;
end