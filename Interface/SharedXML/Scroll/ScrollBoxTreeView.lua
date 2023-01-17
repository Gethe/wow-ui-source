ScrollBoxListTreeListViewMixin = CreateFromMixins(ScrollBoxListLinearViewMixin);

function ScrollBoxListTreeListViewMixin:Init(indent, top, bottom, left, right, spacing)
	ScrollBoxListLinearViewMixin.Init(self, top, bottom, left, right, spacing);
	self:SetElementIndent(indent);
end

function ScrollBoxListTreeListViewMixin:EnumerateDataProvider(indexBegin, indexEnd)
	return self:GetDataProvider():EnumerateUncollapsed(indexBegin, indexEnd);
end

function ScrollBoxListTreeListViewMixin:SetElementIndent(indent)
	self.indent = indent;
end

function ScrollBoxListTreeListViewMixin:GetElementIndent()
	return self.indent;
end

function ScrollBoxListTreeListViewMixin:GetLayoutFunction()
	local setPoint = self:IsHorizontal() and ScrollBoxViewUtil.SetHorizontalPoint or ScrollBoxViewUtil.SetVerticalPoint;
	local scrollTarget = self:GetScrollTarget();
	local function Layout(index, frame, offset)
		local elementData = frame:GetElementData();
		local indent = (elementData:GetDepth() - 1) * self:GetElementIndent();
		return setPoint(frame, offset, indent, scrollTarget);
	end
	return Layout;
end

function ScrollBoxListTreeListViewMixin:Layout()
	return self:LayoutInternal(self:GetLayoutFunction());
end

function CreateScrollBoxListTreeListView(indent, top, bottom, left, right, spacing)
	return CreateAndInitFromMixin(ScrollBoxListTreeListViewMixin, indent or 10, top or 0, bottom or 0, left or 0, right or 0, spacing or 0);
end