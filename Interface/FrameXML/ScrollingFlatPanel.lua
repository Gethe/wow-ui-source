local ScrollBarWidth = 16;

ScrollingFlatPanelMixin = {};

function ScrollingFlatPanelMixin:OnLoad()
	self:SetTitle(self.panelTitle);
	
	self.onCloseCallback = function(button)
		self:OnCloseCallback();
		return false;
	end

	self.HideAnim:SetScript("OnFinished", function()
		self:OnHideAnimFinished();
	end);
end

function ScrollingFlatPanelMixin:OnCloseCallback()
	self:PlayCloseAnimation();
end

function ScrollingFlatPanelMixin:Open(skipShow)
	self.isOpen = true;

	-- Managing the visibility of this panel may occur manually
	-- in some special cases, such as EditMode.
	if not skipShow then
		self:Show();
	end

	self:Resize();
	self:PlayOpenAnimation();
end

function ScrollingFlatPanelMixin:Resize()
	local anchors = 26;
	local extra = 20;
	local height = self:CalculateElementsHeight() + anchors + extra;
	self:SetHeight(math.min(height, self.panelMaxHeight));

	local showScrollBar = self.ScrollBox:HasScrollableExtent();
	self:SetWidth(self.panelWidth + (showScrollBar and ScrollBarWidth or 0));

	self.ScrollBar:SetShown(showScrollBar);

	local view = self.ScrollBox:GetView();
	local padding = view:GetPadding();
	self.ScrollBox:SetWidth(self.panelWidth - padding.left);
end

function ScrollingFlatPanelMixin:GetMaxPossibleWidth()
	return self.panelWidth + ScrollBarWidth;
end

function ScrollingFlatPanelMixin:OnHideAnimFinished()
	HideUIPanel(self);
end

function ScrollingFlatPanelMixin:StopAllAnimations()
	self.ShowAnim:Stop();
	self.HideAnim:Stop();
end

function ScrollingFlatPanelMixin:PlayOpenAnimation()
	self.HideAnim:Stop();

	local reverse = true;
	self.ShowAnim:Play(reverse);
end

function ScrollingFlatPanelMixin:PlayCloseAnimation()
	self.ShowAnim:Stop();

	local reverse = false;
	self.HideAnim:Play(reverse);
end

function ScrollingFlatPanelMixin:Close()
	self.isOpen = false;

	self:PlayCloseAnimation();
end

function ScrollingFlatPanelMixin:GetPanelMaxHeight()
	assert(self.panelMaxHeight ~= nil, "panelMaxHeight was not assigned.")
	return self.panelMaxHeight;
end

function ScrollingFlatPanelMixin:CalculateElementsHeight()
	error("Requires implementation of ScrollingFlatPanelMixin:CalculateElementsHeight.");
end