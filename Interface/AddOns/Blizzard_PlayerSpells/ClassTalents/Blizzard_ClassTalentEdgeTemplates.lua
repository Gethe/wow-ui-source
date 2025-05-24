ClassTalentEdgeArrowMixin = {};

function ClassTalentEdgeArrowMixin:UpdateState()
	-- Overrides TalentEdgeArrowMixin
	local shouldShow = true;

	local startButton = self:GetStartButton();
	local endButton = self:GetEndButton();

	-- If either button's position/sizing hasn't been settled yet, just don't show until they are
	if not startButton:IsRectValid() or not endButton:IsRectValid() then
		shouldShow = false;
		self:MarkPositionDirty();
	else
		local startButtonParent = startButton:GetParent();
		local endButtonParent = endButton:GetParent();
		shouldShow = startButtonParent == endButtonParent;
	
		-- If this edge is attached to Nodes on different parents, hide ourself because they're currently visually disconnected
		if startButtonParent ~= endButtonParent then
			shouldShow = false;
		-- If this edge is attached to Nodes in a sequential (ex: vertical/horizontal) layout frame, hide ourself because nodes are being displayed in a non-tree way
		elseif startButtonParent.IsLayoutFrame and startButtonParent:IsLayoutFrame() and not startButtonParent:IgnoreLayoutIndex() then
			shouldShow = false;
		end
	
		-- If edge is visible, ensure that it's also on the button's parent
		if shouldShow and self:GetParent() ~= startButtonParent then
			self:SetParent(startButtonParent);
			self:MarkPositionDirty();
		end
	end

	-- Using Alpha for visible/invisible state for consistency with TalentButtons remaining "Shown" when invisible
	local previousAlpha = self:GetAlpha();
	local newAlpha = shouldShow and 1.0 or 0.0;
	if not ApproximatelyEqual(previousAlpha, newAlpha) then
		self:SetAlpha(newAlpha);
		-- If alpha has changed, that means button parenting has changed, which also likely means positioning changes
		self:MarkPositionDirty();
	end

	TalentEdgeArrowMixin.UpdateState(self);

	-- If we're connecting SubTree nodes, hide the ArrowHead
	local isSubTreeNode = self:IsSubTreeNodeEdge();
	self.ArrowHead:SetShown(not isSubTreeNode);

	-- GhostArrowHead will have been conditionally shown in the base UpdateState so also make sure that's hidden
	if self:IsSubTreeNodeEdge() then
		self.GhostArrowHead:Hide();
	end
end

function ClassTalentEdgeArrowMixin:GetDiameterOffsetForAngle(angle)
	-- Overrides TalentEdgeArrowMixin
	local diameterOffset = TalentEdgeArrowMixin.GetDiameterOffsetForAngle(self, angle);

	-- Conditionally remove the offset amount that's used to accomodate the arrowHead if we're not gonna display the arrowHead
	-- This is easy to assume for now, but if the base edge template is made more complex to accomodate other edge styles this may also need to change
	if self:IsSubTreeNodeEdge() then
		diameterOffset = diameterOffset - 0.2;
	end

	return diameterOffset;
end

function ClassTalentEdgeArrowMixin:IsSubTreeNodeEdge()
	local startButton = self:GetStartButton();
	local endButton = self:GetEndButton();
	return (startButton and startButton:IsSubTreeNode()) or (endButton and endButton:IsSubTreeNode());
end