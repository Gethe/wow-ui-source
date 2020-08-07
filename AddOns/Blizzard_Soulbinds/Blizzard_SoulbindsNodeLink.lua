SoulbindTreeLinkDirections = 
{
	Vertical = 1,
	Converge = 2,
	Diverge = 3,
};

SoulbindTreeNodeLinkMixin = {}

function SoulbindTreeNodeLinkMixin:Init(direction, angle)
	if direction == SoulbindTreeLinkDirections.Vertical then
		self.Background:SetAtlas("Soulbinds_Tree_Connector_Vertical", true);
		self.FillMask:SetAtlas("Soulbinds_Tree_Connector_Vertical_Mask", true);
	elseif direction == SoulbindTreeLinkDirections.Converge then
		self.Background:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Close", true);
		self.FillMask:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Close_Mask", true);
	elseif direction == SoulbindTreeLinkDirections.Diverge then
		self.Background:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Far", true);
		self.FillMask:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Far_Mask", true);
	end

	self:RotateTextures(angle);
end

function SoulbindTreeNodeLinkMixin:OnHide()
	self.FlowAnim1:Stop();
	self.FlowAnim2:Stop();
	self.FlowAnim3:Stop();
	self.FlowAnim4:Stop();
	self.FlowAnim5:Stop();
	self.FlowAnim6:Stop();
end

function SoulbindTreeNodeLinkMixin:Reset()
	self:SetState(Enum.SoulbindNodeState.Unselected);
end

function SoulbindTreeNodeLinkMixin:SetState(state)
	self.state = state;

	if state == Enum.SoulbindNodeState.Unselected or state == Enum.SoulbindNodeState.Unavailable then
		self:DesaturateHierarchy(1);
		for _, foreground in ipairs(self.foregrounds) do
			foreground:SetShown(false);
		end
		self.FlowAnim1:Stop();
		self.FlowAnim2:Stop();
		self.FlowAnim3:Stop();
		self.FlowAnim4:Stop();
		self.FlowAnim5:Stop();
		self.FlowAnim6:Stop();
	elseif state == Enum.SoulbindNodeState.Selectable then
		self:DesaturateHierarchy(0);
		for _, foreground in ipairs(self.foregrounds) do
			foreground:SetShown(true);
			foreground:SetVertexColor(.3, .3, .3);
		end
		self.FlowAnim1:Play();
		self.FlowAnim2:Play();
		self.FlowAnim3:Play();
		self.FlowAnim4:Play();
		self.FlowAnim5:Play();
		self.FlowAnim6:Play();
	elseif state == Enum.SoulbindNodeState.Selected then
		self:DesaturateHierarchy(0);
		for _, foreground in ipairs(self.foregrounds) do
			foreground:SetShown(true);
			foreground:SetVertexColor(.192, .686, .941);
		end
		self.FlowAnim1:Play();
		self.FlowAnim2:Play();
		self.FlowAnim3:Play();
		self.FlowAnim4:Play();
		self.FlowAnim5:Play();
		self.FlowAnim6:Play();
	end
end

function SoulbindTreeNodeLinkMixin:GetState()
	return self.state;
end