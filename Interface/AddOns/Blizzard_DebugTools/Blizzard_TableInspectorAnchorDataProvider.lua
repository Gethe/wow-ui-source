
TableInspectorAnchorDataProviderMixin = CreateFromMixins(TableInspectorDataProviderMixin);

function TableInspectorAnchorDataProviderMixin:Initialize(tableInspector, parent)
	TableInspectorDataProviderMixin.Initialize(tableInspector, parent);
	self.title = CreateFrame("FRAME", nil, parent, "TableInspectAnchorDataProviderTitleTemplate");
	self.lines = {};
	self.linePool = CreateFramePool("Button", parent, "TableInspectAnchorLineTemplate");
end

function TableInspectorAnchorDataProviderMixin:RefreshData(focusedTable)
	TableInspectorDataProviderMixin.RefreshData(self, focusedTable);
	self:Clear();
	if focusedTable.IsObjectType and focusedTable:IsObjectType("Region") then
		self.lines[1] = self.title;
		for i = 1, focusedTable:GetNumPoints() do
			local line = self.linePool:Acquire();
			self.lines[#self.lines + 1] = line;
			line:Initialize(focusedTable:GetPoint(i));
		end
	end
end

function TableInspectorAnchorDataProviderMixin:HideAllLines()
	for _, line in ipairs(self.lines) do
		line:Hide();
	end
end

function TableInspectorAnchorDataProviderMixin:Clear()
	wipe(self.lines);
	self.linePool:ReleaseAll();
end

function TableInspectorAnchorDataProviderMixin:GetLines(filter)
	if filter == "" then
		return self.lines;
	else
		local results = {};
		for i, line in ipairs(self.lines) do
			if i == 1 or line:MatchesFilter(filter) then
				results[#results + 1] = line;
			end
		end

		return results;
	end
end

TableInspectAnchorLineMixin = {};

function TableInspectAnchorLineMixin:Initialize(point, relativeTo, relativePoint, xOffset, yOffset)
	self.Point:SetText(point);
	self.RelativeTo:SetText(relativeTo and relativeTo:GetDebugName() or "nil");
	self.RelativePoint:SetText(relativePoint);
	self.XOffset:SetText(xOffset);
	self.YOffset:SetText(yOffset);
end

function TableInspectAnchorLineMixin:MatchesFilter(filter)
	return string.lower(self.RelativeTo:GetText()):match(string.lower(filter));
end
