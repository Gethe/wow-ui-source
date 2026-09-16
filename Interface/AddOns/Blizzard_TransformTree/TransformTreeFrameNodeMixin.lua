 TransformTreeFrameNodeMixin = CreateFromMixins(TransformTreeBaseNodeMixin);

 function TransformTreeFrameNodeMixin:OnTransformResolved() -- override
	local globalPosition = self:GetGlobalPosition();
	local globalScale = self:GetGlobalScale();

	self:ClearAllPoints();
	self:SetPoint("CENTER", self:GetParent(), "BOTTOMLEFT", globalPosition.x / globalScale, globalPosition.y / globalScale);

	self:SetScale(globalScale);

	-- Frames cannot be rotated directly, ignore rotation
 end

 function TransformTreeFrameNodeMixin:RequiresPushedResolutions() -- override
	return true;
end