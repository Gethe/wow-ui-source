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

local TreeNodeMixin = {};

local function CreateTreeNode(dataProvider, parent, data)
	local node = CreateFromMixins(TreeNodeMixin);
	node:Init(dataProvider, parent, data);
	return node;
end


function TreeNodeMixin:Init(dataProvider, parent, data)
	self.nodes = {};
	self.dataProvider = dataProvider;
	self.parent = parent;
	self.data = data;
end

function TreeNodeMixin:GetNodes()
	return self.nodes;
end

function TreeNodeMixin:GetDepth()
	return self.parent and self.parent:GetDepth() + 1 or 0;
end

function TreeNodeMixin:GetData()
	return self.data;
end

function TreeNodeMixin:GetSize()
	return #self.nodes;
end

function TreeNodeMixin:GetFirstNode()
	return self.nodes[1];
end

function TreeNodeMixin:MoveNode(node)
	local skipInvalidation = true;
	self.dataProvider:Remove(node, skipInvalidation);
	local previousParent = node.parent;
	node.parent = self;
	
	self:InsertNode(node);

	self.dataProvider:TriggerEvent(TreeDataProviderMixin.Event.OnMove, node, previousParent, self);	

	return node;
end

function TreeNodeMixin:MoveNodeRelativeTo(node, referenceNode, offset)
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

	self.dataProvider:TriggerEvent(TreeDataProviderMixin.Event.OnMove, node, previousParent, self);	

	return node;
end

function TreeNodeMixin:GetParent()
	return self.parent;
end

function TreeNodeMixin:Flush()
	self.nodes = {};
	self:Invalidate();
end

function TreeNodeMixin:Insert(data)
	local node = CreateTreeNode(self.dataProvider, self, data);
	return self:InsertNode(node);
end

function TreeNodeMixin:InsertNode(node)
	table.insert(self.nodes, node);
	self:Invalidate();

	self:Sort();

	return node;
end

function TreeNodeMixin:Remove(node, skipInvalidation)
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

function TreeNodeMixin:SetSortComparator(sortComparator, affectChildren, skipSort)
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

function TreeNodeMixin:HasSortComparator()
	return self.sortComparator ~= nil;
end

function TreeNodeMixin:Sort()
	if self.sortComparator then
		table.sort(self.nodes, self.sortComparator);
		self.dataProvider:TriggerEvent(TreeDataProviderMixin.Event.OnSort);
	end
end

function TreeNodeMixin:Invalidate()
	self.dataProvider:Invalidate();
end

function TreeNodeMixin:SetChildrenCollapsed(collapsed, affectChildren, skipInvalidate)
	for index, child in ipairs(self.nodes) do
		child:SetCollapsed(collapsed, affectChildren, skipInvalidate);
	end
end

function TreeNodeMixin:SetCollapsed(collapsed, affectChildren, skipInvalidate)
	self.collapsed = collapsed;
	if affectChildren then
		self:SetChildrenCollapsed(collapsed, TreeDataProviderConstants.SetChildCollapse, TreeDataProviderConstants.SkipInvalidation);
	end
	if not skipInvalidate then
		self:Invalidate();
	end
end

function TreeNodeMixin:ToggleCollapsed(affectChildren, skipInvalidate)
	local newCollapsed = not self:IsCollapsed();
	self:SetCollapsed(newCollapsed, affectChildren, skipInvalidate);
	return newCollapsed;
end

function TreeNodeMixin:IsCollapsed()
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

TreeDataProviderMixin = CreateFromMixins(CallbackRegistryMixin);

TreeDataProviderMixin:GenerateCallbackEvents(
	{
		"OnSizeChanged",
		"OnRemove",
		"OnSort",
		"OnMove",
	}
);

function TreeDataProviderMixin:Init()
	CallbackRegistryMixin.OnLoad(self);
	
	self.node = CreateTreeNode(self);
end

function TreeDataProviderMixin:GetChildrenNodes()
	return self.node:GetNodes();
end

function TreeDataProviderMixin:GetFirstChildNode()
	return self:GetChildrenNodes()[1];
end

function TreeDataProviderMixin:GetRootNode()
	return self.node;
end

function TreeDataProviderMixin:Invalidate()
	local sortPending = false;
	self:TriggerEvent(DataProviderMixin.Event.OnSizeChanged, sortPending);
end

function TreeDataProviderMixin:IsEmpty()
	return self:GetSize(TreeDataProviderConstants.IncludeCollapsed) == 0;
end

function TreeDataProviderMixin:Insert(data)
	return self.node:Insert(data);
end

function TreeDataProviderMixin:Remove(node)
	if node then
		node.parent:Remove(node);
	end
end

function TreeDataProviderMixin:SetSortComparator(sortComparator, affectChildren, skipSort)
	self.node:SetSortComparator(sortComparator, affectChildren, skipSort);
end

function TreeDataProviderMixin:HasSortComparator()
	return self.node:HasSortComparator();
end

function TreeDataProviderMixin:Sort()
	self.node:Sort();
end

function TreeDataProviderMixin:GetSize(excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local count = 0;
	local indexBegin, indexEnd = nil, nil;
	local enumerator = self:Enumerate(indexBegin, indexEnd, excludeCollapsed);
	while enumerator() do
		count = count + 1;
	end
	return count;
end

function TreeDataProviderMixin:SetCollapsedByPredicate(collapsed, predicate)
	local foundNode = self:FindElementDataByPredicate(predicate, TreeDataProviderConstants.IncludeCollapsed);	
	if foundNode then 
		foundNode:SetCollapsed(collapsed);
	end
end

function TreeDataProviderMixin:InsertInParentByPredicate(node, predicate)
	local foundNode = self:FindElementDataByPredicate(predicate, TreeDataProviderConstants.IncludeCollapsed);	
	if foundNode then 
		foundNode:Insert(node);
	end
end

function TreeDataProviderMixin:EnumerateEntireRange()
	local indexBegin, indexEnd = nil, nil;
	return self:Enumerate(indexBegin, indexEnd, TreeDataProviderConstants.IncludeCollapsed);
end

function TreeDataProviderMixin:Enumerate(indexBegin, indexEnd, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);

	indexBegin = indexBegin and (indexBegin - 1) or 0;
	indexEnd = indexEnd or math.huge;

	local enumerator = EnumerateTreeListNode(self.node, excludeCollapsed);
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

function TreeDataProviderMixin:ForEach(func, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local indexBegin, indexEnd = nil, nil;
	for index, node in self:Enumerate(indexBegin, indexEnd, excludeCollapsed) do
		func(node);
	end
end

function TreeDataProviderMixin:Find(index, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local indexBegin, indexEnd = nil, nil;
	for nodeIndex, node in self:Enumerate(indexBegin, indexEnd, excludeCollapsed) do
		if nodeIndex == index then
			return node;
		end
	end
end

function TreeDataProviderMixin:FindIndex(node, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local indexBegin, indexEnd = nil, nil;
	for index, node2 in self:Enumerate(indexBegin, indexEnd, excludeCollapsed) do
		if node2 == node then
			return index, node;
		end
	end
end

function TreeDataProviderMixin:FindElementDataByPredicate(predicate, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local index, node = self:FindByPredicate(predicate, excludeCollapsed);
	return node;
end

function TreeDataProviderMixin:FindByPredicate(predicate, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local indexBegin, indexEnd = nil, nil;
	for index, node in self:Enumerate(indexBegin, indexEnd, excludeCollapsed) do
		if predicate(node) then
			return index, node;
		end
	end
end

function TreeDataProviderMixin:FindIndexByPredicate(predicate, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local index, node = self:FindByPredicate(predicate, excludeCollapsed);
	return index;
end

function TreeDataProviderMixin:ContainsByPredicate(predicate, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	local index, node = self:FindByPredicate(predicate, excludeCollapsed);
	return index ~= nil;
end

function TreeDataProviderMixin:Flush()
	local oldNode = self.node;
	self.node = CreateTreeNode(self);

	for index, node in EnumerateTreeListNode(oldNode) do
		self:TriggerEvent(TreeDataProviderMixin.Event.OnRemove, node, index);
	end

	local sortPending = false;
	self:TriggerEvent(TreeDataProviderMixin.Event.OnSizeChanged, sortPending);
end

function TreeDataProviderMixin:SetAllCollapsed(collapsed)
	self.node:SetChildrenCollapsed(collapsed, TreeDataProviderConstants.SetChildCollapse, TreeDataProviderConstants.SkipInvalidation);
	self:Invalidate();
end

function TreeDataProviderMixin:CollapseAll()
	self:SetAllCollapsed(TreeDataProviderConstants.Collapsed);
end

function TreeDataProviderMixin:UncollapseAll()
	self:SetAllCollapsed(TreeDataProviderConstants.Uncollapsed);
end

--[[
Linearizes the uncollapsed elements of the tree so that lookups when ignoring the collapsed
sections of the list are performant in scroll box. Consistent with TreeDataProviderMixin,
query and enumeration APIs' default behavior is to include collapsed nodes in any query or 
enumeration API. To assert understanding what this returns, the 'excludeCollapsed' argument
must be provided.

This was originally written as an optimization for larger tree data providers, but since the
performance cost of linearizing the uncollapsed elements of small trees is neglibile by comparison,
this has become the only variant expected to be used.
--]]
LinearizedTreeDataProviderMixin = CreateFromMixins(TreeDataProviderMixin);

function LinearizedTreeDataProviderMixin:GetSize(excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	if excludeCollapsed then
		return #self:GetLinearized();
	end
	return TreeDataProviderMixin.GetSize(self, excludeCollapsed);
end

function LinearizedTreeDataProviderMixin:Enumerate(indexBegin, indexEnd, excludeCollapsed)
	assert(excludeCollapsed ~= nil, explicitParameterMsg);
	if excludeCollapsed then
		return CreateTableEnumerator(self:GetLinearized(), indexBegin, indexEnd);
	end
	return TreeDataProviderMixin.Enumerate(self, indexBegin, indexEnd, excludeCollapsed);
end

function LinearizedTreeDataProviderMixin:Flush()
	self.linearized = nil;
	TreeDataProviderMixin.Flush(self);
end

function LinearizedTreeDataProviderMixin:Invalidate()
	self.linearized = nil;
	TreeDataProviderMixin.Invalidate(self);
end

function LinearizedTreeDataProviderMixin:GetLinearized()
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
	local dataProvider = CreateFromMixins(LinearizedTreeDataProviderMixin);
	dataProvider:Init();
	return dataProvider;
end
