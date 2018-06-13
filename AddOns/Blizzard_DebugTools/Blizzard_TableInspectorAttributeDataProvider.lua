
TableInspectorAttributeDataProviderMixin = CreateFromMixins(TableInspectorDataProviderMixin);

function TableInspectorAttributeDataProviderMixin:Initialize(tableInspector, parent)
	TableInspectorDataProviderMixin.Initialize(self, tableInspector, parent);
	self.linePool = CreatePoolCollection();
	self.linePool:CreatePool("FRAME", parent, "TableAttributeLineEditableTemplate");
	self.linePool:CreatePool("FRAME", parent, "TableAttributeLineReferenceTemplate");
	self.linePool:CreatePool("FRAME", parent, "TableAttributeLineFixedValueTemplate");
	self.linePool:CreatePool("FRAME", parent, "TableAttributeLineTitleTemplate");
	self.attributes = {};
	self.lines = {};
end

function TableInspectorAttributeDataProviderMixin:Clear()
	self.linePool:ReleaseAll();
	wipe(self.attributes);
	wipe(self.lines);
end

function TableInspectorAttributeDataProviderMixin:HideAllLines()
	for i, line in ipairs(self.lines) do
		line:Hide();
	end
end

local typeOrder = { childFrame = 10, boolean = 20, number = 30, string = 40, table = 50, region = 60, ["function"] = 70 };
function TableInspectorAttributeDataProviderMixin:SortAttributes()
	table.sort(self.attributes, function (lhs, rhs)
		local lhsOrder = typeOrder[lhs.type] or 500;
		local rhsOrder = typeOrder[rhs.type] or 500;
		if lhsOrder < rhsOrder then
			return true;
		elseif rhsOrder < lhsOrder then
			return false;
		else
			if lhs.key ~= rhs.key then
				return tostring(lhs.key) < tostring(rhs.key);
			else
				return lhs.displayValue < rhs.displayValue;
			end
		end
	end);
end

local function ShouldShowObject(object)
	return not C_Widget.IsWidget(object) or CanAccessObject(object);
end

function TableInspectorAttributeDataProviderMixin:RefreshData(focusedTable)
	TableInspectorDataProviderMixin.RefreshData(self, focusedTable);
	wipe(self.attributes);
	
	local childFrameIsDisplayed = {};
	for key, value in pairs(focusedTable) do
		if ShouldShowObject(key) and ShouldShowObject(value) then
			local displayValue;
			local valueType = type(value);
			if valueType == "number" or valueType == "string" or valueType == "boolean" then
				displayValue = tostring(value);
			elseif valueType == "table" and value.GetDebugName then
				displayValue = value:GetDebugName();
				valueType = "childFrame";
				childFrameIsDisplayed[value] = true;
			elseif valueType == "nil" then
				displayValue = "nil";
			else
				displayValue = "N/A";
			end
			table.insert(self.attributes, { key = key, type = valueType, rawValue = value, displayValue = displayValue });
		end
	end
	
	if focusedTable.GetChildren then
		local children = { focusedTable:GetChildren() };
	    for _, child in ipairs(children) do
			if ShouldShowObject(child) then
				if not childFrameIsDisplayed[child] then
					table.insert(self.attributes, { key = "N/A", type = "childFrame", rawValue = child, displayValue = child:GetDebugName() });
					childFrameIsDisplayed[child] = true;
				end
			end
		end
	end
	
	if focusedTable.GetRegions then
		local regions = { focusedTable:GetRegions() };
	    for _, region in ipairs(regions) do
			if ShouldShowObject(region) then
				table.insert(self.attributes, { key = "N/A", type = "region", rawValue = region, displayValue = region:GetDebugName() });
			end
		end
	end
	
	self:SortAttributes();
	
	self.linePool:ReleaseAll();
	wipe(self.lines);
	
	for attributeIndex, attributeData in ipairs(self.attributes) do
		if attributeIndex == 1 or attributeData.type ~= self.attributes[attributeIndex - 1].type then
			local line = self.linePool:Acquire("TableAttributeLineTitleTemplate");
			line:Initialize(attributeData.type);
			table.insert(self.lines, line);
		end
		
		local templateType = "TableAttributeLineFixedValueTemplate";
		local valueType = attributeData.type;
		if valueType == "number" or valueType == "string" or valueType == "boolean" then
			templateType = "TableAttributeLineEditableTemplate";
		elseif valueType == "table" or valueType == "childFrame" or valueType == "region" then
			templateType = "TableAttributeLineReferenceTemplate";
		end
		
		local line = self.linePool:Acquire(templateType);
		line:Initialize(self, attributeIndex, attributeData);
		table.insert(self.lines, line);
	end
end

function TableInspectorAttributeDataProviderMixin:GetAttribute(index)
	return self.attributes and self.attributes[index] or nil;
end

function TableInspectorAttributeDataProviderMixin:GetLines(filter)
	if filter == "" then
		return self.lines;
	end
	
	local results = {};
	for i, line in ipairs(self.lines) do
		if line:MatchesFilter(filter) then
			table.insert(results, line);
		end
	end
	
	return results;
end

TableAttributeLineMixin = {};

function TableAttributeLineMixin:Initialize(attributeSource, index, attributeData)
	self.attributeSource = attributeSource;
	self.attributeIndex = index;
	self.Key.Text:SetText(attributeData.key);
end

function TableAttributeLineMixin:MatchesFilter(filter)
	local attributeData = self:GetAttributeData(); 
	return string.find(string.lower(attributeData.displayValue), string.lower(filter)) or string.find(string.lower(attributeData.key), string.lower(filter));
end

function TableAttributeLineMixin:GetAttributeSource()
	return self.attributeSource;
end

function TableAttributeLineMixin:GetTableInspector()
	return self.attributeSource:GetTableInspector();
end

function TableAttributeLineMixin:GetAttributeData()
	return self.attributeSource:GetAttribute(self.attributeIndex);
end

TableAttributeLineEditableMixin = CreateFromMixins(TableAttributeLineMixin);

function TableAttributeLineEditableMixin:Initialize(attributeSource, index, attributeData)
	TableAttributeLineMixin.Initialize(self, attributeSource, index, attributeData);
	self.Value:SetText(attributeData.displayValue);
end 

TableAttributeLineReferenceMixin = CreateFromMixins(TableAttributeLineMixin);

function TableAttributeLineReferenceMixin:Initialize(attributeSource, index, attributeData)
	TableAttributeLineMixin.Initialize(self, attributeSource, index, attributeData);
	self.ValueButton.Text:SetText(attributeData.displayValue);
end

TableAttributeLineFixedValueMixin = CreateFromMixins(TableAttributeLineMixin);

function TableAttributeLineFixedValueMixin:Initialize(attributeSource, index, attributeData)
	TableAttributeLineMixin.Initialize(self, attributeSource, index, attributeData);
	self.Value:SetText(attributeData.displayValue);
end

TableAttributeLineTitleMixin = {};

function TableAttributeLineTitleMixin:Initialize(attributeType)
	self.Text:SetText(attributeType.."(s)");
end

function TableAttributeLineTitleMixin:MatchesFilter(filter)
	return true;
end

function TableAttributeDisplayEditBox_OnEditFocusGained(self)
	local line = self:GetParent();
	local tableInspector = line:GetTableInspector();
	tableInspector:SetDynamicUpdates(false);
end

function TableAttributeDisplayEditBox_OnEnterPressed(self)
	local line = self:GetParent();
	local focusedTable = line:GetAttributeSource():GetFocusedTable();
	local valueType = line:GetAttributeData().type;
	if valueType == "string" then
		focusedTable[line.Key.Text:GetText()] = self:GetText();
	elseif valueType == "number" then
		focusedTable[line.Key.Text:GetText()] = tonumber(self:GetText());
	elseif valueType == "boolean" then
		if self:GetText() == "1" or strupper(self:GetText()) == "TRUE" then
			focusedTable[line.Key.Text:GetText()] = true;
		else
			focusedTable[line.Key.Text:GetText()] = false;
		end
	end
	
	self:ClearFocus();
end

function TableAttributeDisplayValueButton_OnMouseDown(self)
	local line = self:GetParent();
	local attributeData = line:GetAttributeData();
	local tableInspector = line:GetTableInspector();
	local tableTitle = attributeData.key;
	if tableTitle == "N/A" and attributeData.rawValue.GetDebugName then
		tableTitle = attributeData.rawValue:GetDebugName();
	end
	
	if IsShiftKeyDown() then
		DisplayTableInspectorWindow(attributeData.rawValue, newTitle);
	else
		tableInspector:SelectTable(attributeData.rawValue, tableTitle);
	end
end