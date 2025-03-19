
GridSelectorFrameMixin = {};

function GridSelectorFrameMixin:SetLayout(initialAnchor, layout, count)
	if (self.initialAnchor ~= initialAnchor) or (self.layout ~= layout) or (self.count ~= count) then
		self.initialAnchor = initialAnchor;
		self.layout = layout;
		self.count = count;
		self:MarkGridDirty();
	end
end

function GridSelectorFrameMixin:MarkGridDirty()
	if not self.gridDirty then
		self.gridDirty = true;
		RunNextFrame(GenerateClosure(self.UpdateSelections, self));
	end
end

function GridSelectorFrameMixin:UpdateSelections()
	self:ReleaseAllButtons();

	local selectors = {};
	for selectionIndex = 1, self:GetNumSelections() do
		local selector = self:AcquireButton();
		self:RunSetup(selector, selectionIndex);
		selector:Show();
		table.insert(selectors, selector);
	end

	GridLayoutUtil.ApplyGridLayout(selectors, self.initialAnchor, self.layout);

	self.gridDirty = false;
end

function GridSelectorFrameMixin:AcquireButton()
	if self.selectorButtonPool == nil then
		local templateType, buttonTemplate = self:GetButtonTemplate();
		self.selectorButtonPool = CreateFramePool(templateType, self, buttonTemplate);
	end

	return self.selectorButtonPool:Acquire();
end

function GridSelectorFrameMixin:ReleaseAllButtons()
	if self.selectorButtonPool ~= nil then
		self.selectorButtonPool:ReleaseAll();
	end
end

function GridSelectorFrameMixin:EnumerateButtons()
	return self.selectorButtonPool:EnumerateActive();
end
