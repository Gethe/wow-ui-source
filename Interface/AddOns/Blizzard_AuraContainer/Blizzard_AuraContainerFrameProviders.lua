-- Frame providers let containers decide how aura frames are supplied for each
-- aura group.

AuraContainerFramePoolProviderMixin = {};

function AuraContainerFramePoolProviderMixin:Init(framePool)
	self.framePool = framePool;
	return self;
end

function AuraContainerFramePoolProviderMixin:AcquireFrame()
	return self.framePool:Acquire();
end

function AuraContainerFramePoolProviderMixin:ReleaseFrame(frame)
	self.framePool:Release(frame);
end

function AuraContainerUtil.CreateFramePoolProvider(framePool)
	local provider = CreateFromMixins(AuraContainerFramePoolProviderMixin);
	provider:Init(framePool);
	return provider;
end
