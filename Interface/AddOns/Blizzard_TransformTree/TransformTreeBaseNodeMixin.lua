TransformTreeBaseNodeMixin = {};

function CreateTransformTreeNode(nodeMixin, parentTransform, localPosition, localRotationRadians, localScale, ...)
	local treeTransformNode = CreateFromMixins(nodeMixin);
	treeTransformNode:OnLoad(parentTransform, localPosition, localRotationRadians, localScale, ...);
	return treeTransformNode;
end

function CreateTransformTreeNodeFromWidget(widget, nodeMixin, parentTransform, localPosition, localRotationRadians, localScale, ...)
	local treeTransformNode = Mixin(widget, nodeMixin);
	treeTransformNode:OnLoad(parentTransform, localPosition, localRotationRadians, localScale, ...);
	return treeTransformNode;
end

function TransformTreeBaseNodeMixin:OnLoad(parentTransform, localPosition, localRotationRadians, localScale)
	self.children = {};

	self:SetParentTransform(parentTransform);
	self:SetLocalPosition(localPosition or CreateVector2D(0.0, 0.0));
	self:SetLocalRotation(localRotationRadians or 0);
	self:SetLocalScale(localScale or 1.0);

	self:MarkDirty();
end

function TransformTreeBaseNodeMixin:SetParentTransform(parentTransform)
	if self.parentTransform ~= parentTransform then
		if self.parentTransform then
			local childIndex = self.parentTransform:FindChildIndex(self);
			assert(childIndex ~= nil);
			table.remove(self.parentTransform.children, childIndex);
		end
		self.parentTransform = parentTransform;
		if parentTransform then
			assert(parentTransform:FindChildIndex(self) == nil);
			table.insert(parentTransform.children, self);
			self:SetParentTree(parentTransform:GetParentTree());
		else
			self:SetParentTree(nil);
		end
		self:MarkDirty();
	end
end

function TransformTreeBaseNodeMixin:GetParentTransform()
	return self.parentTransform;
end

function TransformTreeBaseNodeMixin:Unlink()
	self:SetParentTransform(nil);
end

function TransformTreeBaseNodeMixin:CreateAndAddChild(nodeMixin, localPosition, localRotationRadians, localScale, ...)
	return CreateTransformTreeNode(nodeMixin, self, localPosition, localRotationRadians, localScale, ...);
end

function TransformTreeBaseNodeMixin:CreateNodeFromTexture(textureWidget, localPosition, localRotationRadians, localScale, ...)
	return CreateTransformTreeNodeFromWidget(textureWidget, TransformTreeTextureNodeMixin, self, localPosition, localRotationRadians, localScale, ...);
end

function TransformTreeBaseNodeMixin:CreateNodeFromFrame(frameWidget, localPosition, localRotationRadians, localScale, ...)
	return CreateTransformTreeNodeFromWidget(frameWidget, TransformTreeFrameNodeMixin, self, localPosition, localRotationRadians, localScale, ...);
end

function TransformTreeBaseNodeMixin:FindChildIndex(childTransformTreeNode)
	for i, child in self:EnumerateChildren() do
		if child == childTransformTreeNode then
			return i;
		end
	end
	return nil;
end

function TransformTreeBaseNodeMixin:EnumerateChildren()
	return ipairs(self.children);
end

function TransformTreeBaseNodeMixin:SetLocalScale(localScale)
	if localScale and self.localScale ~= localScale then
		self.localScale = localScale;
		self:MarkDirty();
	end
end

function TransformTreeBaseNodeMixin:GetLocalScale()
	return self.localScale;
end

function TransformTreeBaseNodeMixin:GetGlobalScale()
	self:ResolveTransform();
	return self.globalScale;
end

function TransformTreeBaseNodeMixin:SetLocalRotation(localRotationRadians)
	if localRotationRadians and self.localRotationRadians ~= localRotationRadians then
		self.localRotationRadians = localRotationRadians;
		self:MarkDirty();
	end
end

function TransformTreeBaseNodeMixin:GetLocalRotation()
	return self.localRotationRadians;
end

function TransformTreeBaseNodeMixin:GetGlobalRotation()
	self:ResolveTransform();
	return self.globalRotationRadians;
end

function TransformTreeBaseNodeMixin:SetLocalPosition(localPosition)
	if localPosition and not AreVector2DEqual(self.localPosition, localPosition) then
		self.localPosition = localPosition:Clone();
		self:MarkDirty();
	end
end

function TransformTreeBaseNodeMixin:GetLocalPosition()
	return self.localPosition:Clone();
end

function TransformTreeBaseNodeMixin:GetGlobalPosition()
	self:ResolveTransform();
	return self.globalPosition:Clone();
end

--[[ "protected" methods ]]
function TransformTreeBaseNodeMixin:OnTransformResolved()
	-- override this method to be informed when a nodes transform is resolved, NOTE: you cannot change transforms from this callback
end

function TransformTreeBaseNodeMixin:RequiresPushedResolutions()
	-- override this to return true if your transform node needs to be actively told to resolve
	-- this is useful if your node is linked to an external system like a Frame or Texture
	return false;
end

--[[ "private/internal" methods ]]
function TransformTreeBaseNodeMixin:MarkDirty()
	if not self.dirty then
		self.dirty = true;
		if self:GetParentTree() and self:RequiresPushedResolutions() then
			self:GetParentTree():AddDirtyTransform(self);
		end
		for i, child in self:EnumerateChildren() do
			child:MarkDirty();
		end
	end
end

function TransformTreeBaseNodeMixin:SetParentTree(parentTree)
	if self.parentTree ~= parentTree then
		if self:GetParentTree() and self:RequiresPushedResolutions() then
			self:GetParentTree():RemoveDirtyTransform(self);
		end
		self.parentTree = parentTree;
		if self.dirty then
			if self:GetParentTree() and self:RequiresPushedResolutions() then
				self:GetParentTree():AddDirtyTransform(self);
			end
		end
		for i, child in self:EnumerateChildren() do
			child:SetParentTree(parentTree);
		end
	end
end

function TransformTreeBaseNodeMixin:GetParentTree()
	return self.parentTree;
end

function TransformTreeBaseNodeMixin:ResolveTransform()
	if not self.dirty then
		return;
	end

	self:CheckResolvingError();
	self.dirty = false;
	self.isResolving = true;

	self.globalScale = self:GetLocalScale();
	self.globalRotationRadians = self:GetLocalRotation();
	self.globalPosition = self:GetLocalPosition();

	local parentTransform = self:GetParentTransform();
	if parentTransform then
		self.globalScale = self.globalScale * parentTransform:GetGlobalScale();

		local parentRotation = parentTransform:GetGlobalRotation();
		self.globalRotationRadians = self.globalRotationRadians + parentRotation;

		self.globalPosition:RotateDirection(parentRotation);
		self.globalPosition:Add(parentTransform:GetGlobalPosition());
	end

	xpcall(self.OnTransformResolved, CallErrorHandler, self);

	self.isResolving = false;
end

function TransformTreeBaseNodeMixin:CheckResolvingError()
	if self.isResolving then
		error("Cannot change a transform tree node from a resolution callback, defer the change until after resolution completes.");
	end
end