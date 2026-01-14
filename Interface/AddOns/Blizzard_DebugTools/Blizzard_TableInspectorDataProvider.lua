
TableInspectorDataProviderMixin = {};

function TableInspectorDataProviderMixin:Initialize(tableInspector, parent)
	self.tableInspector = tableInspector;
end

function TableInspectorDataProviderMixin:RefreshData(focusedTable)
	self.focusedTable = focusedTable;
end

function TableInspectorDataProviderMixin:GetFocusedTable()
	return self.focusedTable;
end

function TableInspectorDataProviderMixin:GetTableInspector()
	return self.tableInspector;
end

function TableInspectorDataProviderMixin:HideAllLines()
end

function TableInspectorDataProviderMixin:Clear()
end

function TableInspectorDataProviderMixin:GetLines(filter)
	return {};
end