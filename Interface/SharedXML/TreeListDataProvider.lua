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

Import("table");
Import("ipairs");

end
---------------

local explicitParameterMsg = "Parameter 'excludeCollapsed' is required.";

TreeDataProviderConstants =
{
	Collapsed = true,
	Uncollapsed = false,
	SetChildCollapse = true,
	RetainChildCollapse = false,
	SkipInvalidation = true,
	DoInvalidation = false,
	ExcludeCollapsed = true,
	IncludeCollapsed = false,
};

local TreeListNodeMixin = {};

local function CreateTreeListNode(dataProvider, parent, data)
	local node = CreateFromMixins(TreeListNodeMixin);
	node:Init(dataProvider, parent, data);
	return node;
end


function TreeListNodeMixin:Init(dataProvider, parent, data)
	self.nodes = {};
	self.dataProvider = dataProvider;
	self.parent = parent;
	self.data = data;
end

function TreeListNodeMixin:GetNodes()
	return self.nodes;
end

function TreeListNodeMixin:GetDepth()
	return self.parent and self.parent:GetDepth() + 1 or 0;
end

function TreeListNodeMixin:GetData()
	return self.data;
end

function TreeListNodeMixin:GetSize()
	return #self.nodes;
end

function TreeListNodeMixin:GetFirstNode()
	return self.nodes[1];
end

function TreeListNodeMixin:MoveNode(node)
	local skipInvalidation = true;
	self.dataProvider:Remove(node, skipInvalidation);
	local previousParent = node.parent;
	node.parent = self;
	
	self:InsertNode(node);

	self.dataProvider:TriggerEvent(TreeListDataProviderMixin.Event.OnMove, node, previousParent, self);	

	return node;
end

function TreeListNodeMixin:MoveNodeRelativeTo(node, referenceNode, offset)
	if not tContains(self.nodes, referenceNode) then
		error("MoveNodeRelativeToNode requires reference node to exist.");
	end

	if self:HasSortComparator() then
		error("MoveNodeRelativeToNode cannot move a node into a sorted node.");
	end

	local skipInvalidation = true;
	self.dataProvider:Remove(node, skipInvalidation);
	local previousParent = node.parent;
	node.parent = self;
	
	local referenceNodeIndex = tIndexOf(self.nodes, referenceNode);
	local newNodeIndex = referenceNodeIndex + offset;
	table.insert(self.nodes, newNodeIndex, node);
	
	self:Invalidate();

	self.dataProvider:TriggerEvent(TreeListDataProviderMixin.Event.OnMove, node, previousParent, self);	

	return node;
end

function TreeListNodeMixin:GetParent()
	return self.parent;
end

function TreeListNodeMixin:Flush()
	self.nodes = {};
	self:Invalidate();
end

function TreeListNodeMixin:Insert(data)
	local node = CreateTreeListNode(self.dataProvider, self, data);
	return self:InsertNode(node);
end

function TreeListNodeMixin:InsertNode(node)
	table.insert(self.nodes, node);
	self:Invalidate();

	self:Sort();

	return node;
end

function TreeListNodeMixin:Remove(node, skipInvalidation)
	for index, node2 in ipairs(self.nodes) do
		if node2 == node then
			local removed = table.remove(self.nodes, index);
			if not skipInvalidation then
				self:Invalidate();
			end
			return removed;
		end
	end
end

function TreeListNodeMixin:SetSortComparator(sortComparator, affectChildren, skipSort)
	self.sortComparator = sortComparator;
	
	if affectChildren then
		for index, child in ipairs(self.nodes) do
			child:SetSortComparator(sortComparator, affectChildren, skipSort);
		end
	end

	if not skipSort then
		self:Sort();
	end
end

function TreeListNodeMixin:HasSortComparator()
	return self.sortComparator ~= nil;
end

function TreeListNodeMixin:Sort()
	if self.sortComparator then
		table.sort(self.nodes, self.sortComparator);
		self.dataProvider:TriggerEvent(TreeListDataProviderMixin.Event.OnSort);
	end
end

function TreeListNodeMixin:Invalidate()
	self.dataProvider:Invalidate();
end

function TreeListNodeMixin:SetChildrenCollapsed(collapsed, affectChildren, skipInvalidate)
	for index, child in ipairs(self.nodes) do
		child:SetCollapsed(collapsed, affectChildren, skipInvalidate);
	end
end

function TreeListNodeMixin:SetCollapsed(collapsed, affectChildren, skipInvalidate)
	self.collapsed = collapsed;
	if affectChildren then
		self:SetChildrenCollapsed(collapsed, TreeDataProviderConstants.SetChildCollapse, TreeDataProviderConstants.SkipInvalidation);
	end
	if not skipInvalidate then
		self:Invalidate();
	end
end

function TreeListNodeMixin:ToggleCollapsed(affectChildren, skipInvalidate)
	local newCollapsed = not self:IsCollapsed();
	self:SetCollapsed(newCollapsed, affectChildren, skipInvalidate);
	return newCollapsed;
end

function TreeListNodeMixin:IsCollapsed()
	return self.collapsed;
end

local function EnumerateTreeListNode(root, excludeCollapsed)
	local stack = {};
	for _, node in ipairs_reverse(root.nodes) do
		table.insert(stack, node);
	end

	local index = 0;
	local function Enumerator()
		index = index + 1;
		local top = table.remove(stack);
		if top then
			if not excludeCollapsed or not top.collapsed then
				for _, node in ipairs_reverse(top.nodes) do
					table.insert(stack, node);
				end
			end

			return index, top;
		end
	end
	
	return Enumerator;
end

TreeListDataProviderMixin = CreateFromMixins(CallbackRegistryMixin);

TreeListDataProviderMixin:GenerateCallbackEvents(
	{
		"OnSizeChanged",
		"OnRemove",
		"OnSort",
		"OnMove",
	}
);

function TreeListDataProviderMixin:Init()
	CallbackRegistryMixin.OnLoad(self);
	
	self.node = CreateTreeListNode(self);
end

local function EnumerateInternal(indexBegin, indexEnd, root, excludeCollapsed)
	indexBegin = indexBegin and (indexBegin - 1) or 0;
	indexEnd = indexEnd or math.huge;

	local enumerator = EnumerateTreeListNode(root, excludeCollapsed);
	local index = indexBegin;
	while index > 0 do
		index = index - 1;
		enumerator();
	end

	local function Enumerator()
		if indexBegin <= indexEnd then
			indexBegin = indexBegin + 1;
			return enumerator();
		end
	end
	
	return Enumerator;
end

function TreeListDataProviderMixin:GetChildrenNodes()
	return self.node:GetNodes();
end

function TreeListDataProviderMixin:GetFirstChildNode()
	return self:GetChildrenNodes()[1];
end

function TreeListDataProviderMixin:GetRootNode()
	return self.node;
end

function TreeListDataProviderMixin:Invalidate()
	local sortPending = false;
	self:TriggerEvent(DataProviderMixin.Event.OnSizeChanged, sortPending);
end

function TreeListDataProviderMixin:IsEmpty()
	return self:GetSize(TreeDataProviderConstants.IncludeCollapsed) == 0;
end

function TreeListDataProviderMixin:Insert(data)
	return self.node:Insert(data);
end

function TreeListDataProviderMixin:Remove(node)
	if node then
		node.parent:Remove(node);
	end
end

function TreeListDataProviderMixin:SetSortComparator(sortComparator, affectChildren, skipSort)
	self.node:SetSortComparator(sortComparator, affectChildren, skipSort);
end

function TreeListDataProviderMixin:HasSortComparator()
	return self.node:HasSortComparator();
end

function TreeListDataProviderMixin:Sort()
	self.node:Sort();
end

function TreeListDataProviderMixin:GetSize(excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local count = 0;
	local indexBegin, indexEnd = nil, nil;
	local enumerator = self:Enumerate(indexBegin, indexEnd, excludeCollapsed);
	while enumerator() do
		count = count + 1;
	end
	return count;
end

function TreeListDataProviderMixin:SetCollapsedByPredicate(collapsed, predicate)
	local foundNode = self:FindElementDataByPredicate(predicate, TreeDataProviderConstants.IncludeCollapsed);	
	if foundNode then 
		foundNode:SetCollapsed(collapsed);
	end
end

function TreeListDataProviderMixin:InsertInParentByPredicate(node, predicate)
	local foundNode = self:FindElementDataByPredicate(predicate, TreeDataProviderConstants.IncludeCollapsed);	
	if foundNode then 
		foundNode:Insert(node);
	end
end

function TreeListDataProviderMixin:EnumerateEntireRange()
	local indexBegin, indexEnd = nil, nil;
	return EnumerateInternal(indexBegin, indexEnd, self.node, TreeDataProviderConstants.IncludeCollapsed);
end

function TreeListDataProviderMixin:Enumerate(indexBegin, indexEnd, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	return EnumerateInternal(indexBegin, indexEnd, self.node, excludeCollapsed);
end

function TreeListDataProviderMixin:ForEach(func, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local indexBegin, indexEnd = nil, nil;
	for index, node in self:Enumerate(indexBegin, indexEnd, excludeCollapsed) do
		func(node);
	end
end

function TreeListDataProviderMixin:Find(index, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local indexBegin, indexEnd = nil, nil;
	for nodeIndex, node in self:Enumerate(indexBegin, indexEnd, excludeCollapsed) do
		if nodeIndex == index then
			return node;
		end
	end
end

function TreeListDataProviderMixin:FindIndex(node, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local indexBegin, indexEnd = nil, nil;
	for index, node2 in self:Enumerate(indexBegin, indexEnd, excludeCollapsed) do
		if node2 == node then
			return index, node;
		end
	end
end

function TreeListDataProviderMixin:FindElementDataByPredicate(predicate, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local index, node = self:FindByPredicate(predicate, excludeCollapsed);
	return node;
end

function TreeListDataProviderMixin:FindByPredicate(predicate, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local indexBegin, indexEnd = nil, nil;
	for index, node in self:Enumerate(indexBegin, indexEnd, excludeCollapsed) do
		if predicate(node) then
			return index, node;
		end
	end
end

function TreeListDataProviderMixin:FindIndexByPredicate(predicate, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local index, node = self:FindByPredicate(predicate, excludeCollapsed);
	return index;
end

function TreeListDataProviderMixin:ContainsByPredicate(predicate, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local index, node = self:FindByPredicate(predicate, excludeCollapsed);
	return index ~= nil;
end

function TreeListDataProviderMixin:Flush()
	local oldNode = self.node;
	self.node = CreateTreeListNode(self);

	for index, node in EnumerateTreeListNode(oldNode) do
		self:TriggerEvent(TreeListDataProviderMixin.Event.OnRemove, node, index);
	end

	local sortPending = false;
	self:TriggerEvent(TreeListDataProviderMixin.Event.OnSizeChanged, sortPending);
end

function TreeListDataProviderMixin:SetAllCollapsed(collapsed)
	self.node:SetChildrenCollapsed(collapsed, TreeDataProviderConstants.SetChildCollapse, TreeDataProviderConstants.SkipInvalidation);
	self:Invalidate();
end

function TreeListDataProviderMixin:CollapseAll()
	self:SetAllCollapsed(TreeDataProviderConstants.Collapsed);
end

function TreeListDataProviderMixin:UncollapseAll()
	self:SetAllCollapsed(TreeDataProviderConstants.Uncollapsed);
end

--[[
Linearizes the uncollapsed elements of the tree so that lookups when ignoring the collapsed
sections of the list are performant in scroll box. Consistent with TreeListDataProviderMixin,
query and enumeration APIs' default behavior is to include collapsed nodes in any query or 
enumeration API. To assert understanding what this returns, the 'excludeCollapsed' argument
must be provided.

This was originally written as an optimization for larger tree data providers, but since the
performance cost of linearizing the uncollapsed elements of small trees is neglibile by comparison,
this has become the only variant expected to be used.
--]]
LinearizedTreeListDataProviderMixin = CreateFromMixins(TreeListDataProviderMixin);

function LinearizedTreeListDataProviderMixin:GetSize(excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	if excludeCollapsed then
		return #self:GetLinearized();
	end
	return TreeListDataProviderMixin.GetSize(self, excludeCollapsed);
end

function LinearizedTreeListDataProviderMixin:Enumerate(indexBegin, indexEnd, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	if excludeCollapsed then
		return CreateTableEnumerator(self:GetLinearized(), indexBegin, indexEnd);
	end
	return TreeListDataProviderMixin.Enumerate(self, indexBegin, indexEnd, excludeCollapsed);
end

function LinearizedTreeListDataProviderMixin:Flush()
	self.linearized = nil;
	TreeListDataProviderMixin.Flush(self);
end

function LinearizedTreeListDataProviderMixin:Invalidate()
	self.linearized = nil;
	TreeListDataProviderMixin.Invalidate(self);
end

function LinearizedTreeListDataProviderMixin:GetLinearized()
	if not self.linearized then
		local linearized = {};
		for index, node in EnumerateTreeListNode(self.node, TreeDataProviderConstants.ExcludeCollapsed) do
			table.insert(linearized, node);
		end
		self.linearized = linearized;
	end
	return self.linearized;
end

function CreateTreeDataProvider()
	local dataProvider = CreateFromMixins(LinearizedTreeListDataProviderMixin);
	dataProvider:Init();
	return dataProvider;
end
