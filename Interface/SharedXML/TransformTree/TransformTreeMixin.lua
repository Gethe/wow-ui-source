TransformTreeMixin = {};

function TransformTreeMixin:OnLoad()
	self.root = CreateTransformTreeNode(TransformTreeBaseNodeMixin);
	self.root:SetParentTree(self);

	-- Not all transform nodes need resolves "pushed" to them, as they will be resolved as soon as transform data is requested
	-- Some nodes, like those that link to a Texture or Frame need to be told to resolve so that they can sync their values
	-- This keeps a set of all dirty nodes that ask to be "pushed" resolutions
	self.dirtyPushTransformNodes = {};
end

function TransformTreeMixin:GetRoot()
	return self.root;
end

-- This should be called to let nodes resolve their transforms, it should likely be called it every frame if your nodes render
function TransformTreeMixin:ResolveTransforms()
	if next(self.dirtyPushTransformNodes) then
		local transformsToResolve = self.dirtyPushTransformNodes;
		self.dirtyPushTransformNodes = {};
		for transformNode in pairs(transformsToResolve) do
			transformNode:ResolveTransform();
		end
	end
end

function TransformTreeMixin:AddDirtyTransform(transformNode)
	self.dirtyPushTransformNodes[transformNode] = true;
end

function TransformTreeMixin:RemoveDirtyTransform(transformNode)
	self.dirtyPushTransformNodes[transformNode] = nil;
end