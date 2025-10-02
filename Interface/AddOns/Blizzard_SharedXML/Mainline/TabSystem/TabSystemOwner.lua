
TabSystemTrackerMixin = {};

function TabSystemTrackerMixin:OnLoad()
	self:Init();
end

function TabSystemTrackerMixin:Init()
	self.tabbedElements = {};
	self.tabIDToElementSet = {};
	self.tabIDToTabCallback = {};
end

function TabSystemTrackerMixin:AddTab(tabID, ...)
	self.tabIDToElementSet[tabID] = {};

	for i = 1, select("#", ...) do
		self:AddElementToTab(tabID, select(i, ...));
	end
end

function TabSystemTrackerMixin:AddElementToTab(tabID, element)
	table.insert(self.tabbedElements, element);

	local elementSet = GetOrCreateTableEntry(self.tabIDToElementSet, tabID);
	elementSet[element] = true;
end

function TabSystemTrackerMixin:SetTabCallback(tabID, callback)
	self.tabIDToTabCallback[tabID] = callback;
end

function TabSystemTrackerMixin:SetTab(tabID)
	self.tabID = tabID;

	local elementSet = self.tabIDToElementSet[tabID];
	for i, tabbedElement in ipairs(self.tabbedElements) do
		tabbedElement:SetShown(elementSet and elementSet[tabbedElement]);
	end

	local tabCallback = self.tabIDToTabCallback[tabID];
	if tabCallback then
		tabCallback();
	end
end

function TabSystemTrackerMixin:GetTab()
	return self.tabID;
end

function TabSystemTrackerMixin:GetTabSet()
	return GetKeysArray(self.tabIDToElementSet);
end

function TabSystemTrackerMixin:GetElementsForTab(tabID)
	return GetKeysArray(self.tabIDToElementSet[tabID]);
end


TabSystemOwnerMixin = {};

function TabSystemOwnerMixin:OnLoad()
	self.internalTabTracker = CreateAndInitFromMixin(TabSystemTrackerMixin);
end

function TabSystemOwnerMixin:SetTabSystem(tabSystem)
	self.tabSystem = tabSystem;
	tabSystem:SetTabSelectedCallback(GenerateClosure(self.SetTab, self));
end

function TabSystemOwnerMixin:AddNamedTab(tabName, ...)
	local tabID = self.tabSystem:AddTab(tabName);
	self.internalTabTracker:AddTab(tabID, ...);

	return tabID;
end

function TabSystemOwnerMixin:SetTabCallback(tabID, callback)
	self.internalTabTracker:SetTabCallback(tabID, callback);
end

function TabSystemOwnerMixin:SetTab(tabID)
	self.internalTabTracker:SetTab(tabID);
	self.tabSystem:SetTabVisuallySelected(tabID);
end

function TabSystemOwnerMixin:GetTab()
	return self.internalTabTracker:GetTab();
end

function TabSystemOwnerMixin:GetTabSet()
	return self.internalTabTracker:GetTabSet();
end

function TabSystemOwnerMixin:GetElementsForTab(tabID)
	return self.internalTabTracker:GetElementsForTab(tabID);
end

function TabSystemOwnerMixin:GetTabButton(tabID)
	return self.tabSystem:GetTabButton(tabID);
end