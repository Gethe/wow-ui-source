
TabbedFrameMixin = {};

function TabbedFrameMixin:OnLoad()
	self:Init();
end

function TabbedFrameMixin:Init()
	self.tabbedElements = {};
	self.tabKeyToElementSet = {};
end

function TabbedFrameMixin:AddTab(tabKey, ...)
	self.tabKeyToElementSet[tabKey] = {};

	for i = 1, select("#", ...) do
		self:AddElementToTab(tabKey, select(i, ...));
	end
end

function TabbedFrameMixin:AddElementToTab(tabKey, element)
	table.insert(self.tabbedElements, element);

	local elementSet = GetOrCreateTableEntry(self.tabKeyToElementSet, tabKey);
	elementSet[element] = true;
end

function TabbedFrameMixin:SetTab(tabKey)
	self.tabKey = tabKey;

	local elementSet = self.tabKeyToElementSet[tabKey];
	for i, tabbedElement in ipairs(self.tabbedElements) do
		tabbedElement:SetShown(elementSet and elementSet[tabbedElement]);
	end
end

function TabbedFrameMixin:GetTab()
	return self.tabKey;
end


TabSystemOwnerMixin = CreateFromMixins(TabbedFrameMixin);

function TabSystemOwnerMixin:OnLoad()
	self.internalTabTracker = CreateAndInitFromMixin(TabbedFrameMixin);
end

function TabSystemOwnerMixin:SetTabSystem(tabSystem)
	self.tabSystem = tabSystem;
	tabSystem:SetTabSelectedCallback(GenerateClosure(self.SetTab, self));
end

function TabSystemOwnerMixin:AddNamedTab(tabName, ...)
	local tabID = self.tabSystem:AddTab(tabName);
	self.internalTabTracker:AddTab(tabID, ...);

	for i = 1, select("#", ...) do
		self.internalTabTracker:AddElementToTab(tabID, select(i, ...));
	end

	return tabID;
end

function TabSystemOwnerMixin:SetTab(tabID)
	self.internalTabTracker:SetTab(tabID);
	self.tabSystem:SetTabVisuallySelected(tabID);
end

function TabSystemOwnerMixin:GetTab()
	return self.internalTabTracker:GetTab();
end
