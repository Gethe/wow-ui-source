---------------
--NOTE - Please do not change this section without talking to the UI team
local _, tbl = ...;
if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	setfenv(1, tbl);

end
---------------

ScrollBoxListTreeListViewMixin = CreateFromMixins(ScrollBoxListLinearViewMixin);

function ScrollBoxListTreeListViewMixin:Init(indent, top, bottom, left, right, spacing)
	ScrollBoxListLinearViewMixin.Init(self, top, bottom, left, right, spacing);
	self:SetElementIndent(indent);
end

function ScrollBoxListTreeListViewMixin:InitDefaultDrag(scrollBox)
	return ScrollUtil.InitDefaultTreeDragBehavior(scrollBox);
end

-- Start of accessor overrides required by ScrollBox
function ScrollBoxListTreeListViewMixin:ForEachElementData(func)
	self:GetDataProvider():ForEach(func, TreeDataProviderConstants.ExcludeCollapsed);
end

function ScrollBoxListTreeListViewMixin:ReverseForEachElementData(func)
	error("ReverseForEachElementData unsupported in ScrollBoxListTreeListViewMixin.");
end

-- Deprecated, use FindElementData
function ScrollBoxListTreeListViewMixin:Find(index)
	return self:FindElementData(index);
end

-- Deprecated, use FindElementDataIndex
function ScrollBoxListTreeListViewMixin:FindIndex(elementData)
	return self:FindElementDataIndex(elementData);
end

function ScrollBoxListTreeListViewMixin:FindElementData(index)
	return self:GetDataProvider():Find(index, TreeDataProviderConstants.ExcludeCollapsed);
end

function ScrollBoxListTreeListViewMixin:FindElementDataIndex(elementData)
	return self:GetDataProvider():FindIndex(elementData, TreeDataProviderConstants.ExcludeCollapsed);
end

function ScrollBoxListTreeListViewMixin:FindElementDataByPredicate(predicate)
	return self:GetDataProvider():FindElementDataByPredicate(predicate, TreeDataProviderConstants.ExcludeCollapsed);
end

function ScrollBoxListTreeListViewMixin:FindElementDataIndexByPredicate(predicate)
	return self:GetDataProvider():FindIndexByPredicate(predicate, TreeDataProviderConstants.ExcludeCollapsed);
end

function ScrollBoxListTreeListViewMixin:FindByPredicate(predicate)
	return self:GetDataProvider():FindByPredicate(predicate, TreeDataProviderConstants.ExcludeCollapsed);
end

function ScrollBoxListTreeListViewMixin:ContainsElementDataByPredicate(predicate)
	return self:GetDataProvider():ContainsByPredicate(predicate, TreeDataProviderConstants.ExcludeCollapsed);
end

function ScrollBoxListTreeListViewMixin:EnumerateDataProviderEntireRange()
	local indexBegin, indexEnd = nil, nil;
	self:GetDataProvider():Enumerate(indexBegin, indexEnd, TreeDataProviderConstants.IncludeCollapsed);
end

function ScrollBoxListTreeListViewMixin:EnumerateDataProvider(indexBegin, indexEnd)
	return self:GetDataProvider():Enumerate(indexBegin, indexEnd, TreeDataProviderConstants.ExcludeCollapsed);
end

function ScrollBoxListTreeListViewMixin:GetDataProviderSize()
	local dataProvider = self:GetDataProvider();
	if dataProvider then
		return dataProvider:GetSize(TreeDataProviderConstants.ExcludeCollapsed);
	end
	return 0;
end

function ScrollBoxListTreeListViewMixin:TranslateElementDataToUnderlyingData(elementData)
	return elementData:GetData();
end

function ScrollBoxListTreeListViewMixin:IsScrollToDataIndexSafe()
	return false;
end

function ScrollBoxListTreeListViewMixin:PrepareScrollToElementDataByPredicate(predicate)
	local dataProvider = self:GetDataProvider();
	if dataProvider then
		-- Traverse the data provider including collapsed elements as we're going to expand the ancestry to
		-- force the desired element to become visible.
		local elementData = dataProvider:FindElementDataByPredicate(predicate, TreeDataProviderConstants.IncludeCollapsed);
		self:PrepareScrollToElementData(elementData);
	end
end

function ScrollBoxListTreeListViewMixin:PrepareScrollToElementData(elementData)
	if elementData then
		local parents = {};

		local parent = elementData.parent;
		while parent do
			table.insert(parents, parent);

			local next = parent.parent;
			if next then
				parent = next;
			else
				break;
			end
		end

		for index, parent in ipairs_reverse(parents) do
			parent:SetCollapsed(false, TreeDataProviderConstants.RetainChildCollapse, TreeDataProviderConstants.SkipInvalidation);
		end

		-- Skip invalidation so that each individual collapse change doesn't unnecessarily signal updates. We're invalidating
		-- after this finishes below.
		local dataProvider = self:GetDataProvider();
		dataProvider:Invalidate();
	end
end
-- End of accessor overrides

function ScrollBoxListTreeListViewMixin:SetElementIndent(indent)
	self.indent = indent;
end

function ScrollBoxListTreeListViewMixin:GetElementIndent()
	return self.indent;
end

function ScrollBoxListTreeListViewMixin:AssignAccessors(frame, elementData)
	ScrollBoxListViewMixin.AssignAccessors(self, frame, elementData);

	frame.IsCollapsed = function(self)
		return elementData:IsCollapsed();
	end;
end

function ScrollBoxListTreeListViewMixin:UnassignAccessors(frame)
	ScrollBoxListViewMixin.UnassignAccessors(self, frame, elementData);

	frame.IsCollapsed = nil;
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