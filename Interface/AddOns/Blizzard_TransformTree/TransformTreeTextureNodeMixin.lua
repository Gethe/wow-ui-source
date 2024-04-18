 TransformTreeTextureNodeMixin = CreateFromMixins(TransformTreeBaseNodeMixin);

 function TransformTreeTextureNodeMixin:OnTransformResolved() -- override
	local globalPosition = self:GetGlobalPosition();
	local globalScale = self:GetGlobalScale();

	self:ClearAllPoints();
	self:SetPoint("CENTER", self:GetParent(), "BOTTOMLEFT", globalPosition.x / globalScale, globalPosition.y / globalScale);

	self:SetRotation(self:GetGlobalRotation());

	self:SetScale(globalScale);
 end

 function TransformTreeTextureNodeMixin:RequiresPushedResolutions() -- override
	return true;
end