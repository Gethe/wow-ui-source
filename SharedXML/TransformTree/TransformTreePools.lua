TransformTreeFrameNodePoolMixin = CreateFromMixins(ObjectPoolMixin);

local function TransformTreeFrameNodePoolFactory(transformTreeFramePool)
	local frame = CreateFrame(transformTreeFramePool.frameType, nil, transformTreeFramePool.parent, transformTreeFramePool.frameTemplate);
	return CreateTransformTreeNodeFromWidget(frame, TransformTreeFrameNodeMixin);
end

function TransformTreeFrameNodePoolMixin:OnLoad(frameType, parent, frameTemplate, resetterFunc) -- override
	ObjectPoolMixin.OnLoad(self, TransformTreeFrameNodePoolFactory, resetterFunc);
	self.frameType = frameType;
	self.parent = parent;
	self.frameTemplate = frameTemplate;
end

function TransformTreeFrameNodePoolMixin:Acquire(parentTransform, localPosition, localRotationRadians, localScale) -- override
	local transformTreeFrameNode, justCreated = ObjectPoolMixin.Acquire(self);

	transformTreeFrameNode:SetParentTransform(parentTransform);
	transformTreeFrameNode:SetLocalPosition(localPosition or CreateVector2D(0.0, 0.0));
	transformTreeFrameNode:SetLocalRotation(localRotationRadians or 0);
	transformTreeFrameNode:SetLocalScale(localScale or 1.0);

	return transformTreeFrameNode, justCreated;
end

function TransformTreeFrameNodePoolMixin:GetTemplate()
	return self.frameTemplate;
end

function TransformTreeFrameNode_Reset(transformTreeFramePool, frame)
	frame:Unlink();
	frame:ClearAllPoints();
	frame:Hide();
end

function CreateTransformFrameNodePool(frameType, parent, frameTemplate, resetterFunc)
	local transformTreeFramePool = CreateFromMixins(TransformTreeFrameNodePoolMixin);
	transformTreeFramePool:OnLoad(frameType, parent, frameTemplate, resetterFunc or TransformTreeFrameNode_Reset);
	return transformTreeFramePool;
end