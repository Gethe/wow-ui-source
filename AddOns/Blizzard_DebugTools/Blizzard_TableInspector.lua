
local tableInspectorPool = CreateFramePool("FRAME", UIParent, "TableAttributeDisplayTemplate");

local DEFAULT_DATA_PROVIDERS = {
	TableInspectorAnchorDataProviderMixin,
	TableInspectorAttributeDataProviderMixin,
};

TableInspectorMixin = {};

function TableInspectorMixin:OnLoad()
	self:Reset();
end

function TableInspectorMixin:SetTableFocusedCallback(tableFocusedCallback)
	self.tableFocusedCallback = tableFocusedCallback;
end

function TableInspectorMixin:Reset()
	self:RemoveAllDataProviders();
	for i, dataProvider in ipairs(DEFAULT_DATA_PROVIDERS) do
		local dataProviderInstance = CreateFromMixins(dataProvider);
		dataProviderInstance:Initialize(self, self.LinesScrollFrame.LinesContainer);
		self:AddDataProvider(dataProviderInstance);
	end
	
	if self.lines then
		wipe(self.lines);
	else
		self.lines = {};
	end

	if self.tableNavigation then
		wipe(self.tableNavigation);
	else
		self.tableNavigation = {};
	end
	
	self.tableNavigationIndex = 0;
end

function TableInspectorMixin:OnHide()
	tableInspectorPool:Release(self);
end

function TableInspectorMixin:AddDataProvider(dataProvider)
	if not self.dataProviders then
		self.dataProviders = {};
	end
	
	table.insert(self.dataProviders, dataProvider);
end

function TableInspectorMixin:ClearData()
	if not self.dataProviders then
		return;
	end
	
	for _, dataProvider in ipairs(self.dataProviders) do
		dataProvider:Clear(self.focusedTable);
	end
end

function TableInspectorMixin:RemoveAllDataProviders()
	if self.dataProviders then
		wipe(self.dataProviders);
	end
end

function TableInspectorMixin:RefreshAllData()
	if self.dataProviders then
		for _, dataProvider in ipairs(self.dataProviders) do
			dataProvider:RefreshData(self.focusedTable);
		end
	end
end

function TableInspectorMixin:UpdateLines()
	if not self.dataProviders then
		return;
	end
	
	self.lines = {};
	
	local previousLine = nil;
	for _, dataProvider in ipairs(self.dataProviders) do
		dataProvider:HideAllLines();
		local lines = dataProvider:GetLines(self.FilterBox:GetText());
		for _, line in ipairs(lines) do
			table.insert(self.lines, line);
			if previousLine then
				line:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", 0, 0);
			else
				line:SetPoint("TOPLEFT", self.LinesScrollFrame.LinesContainer, "TOPLEFT", 0, 0);
			end
			
			previousLine = line;
			line:Show();
		end
	end
	
	ScrollFrame_OnScrollRangeChanged(self.LinesScrollFrame);
end

function TableInspectorMixin:OpenParentDisplay()
	local parent = self.focusedTable.GetParent and self.focusedTable:GetParent() or nil;
	if parent then
		self:InspectTable(parent);
	end
end

function TableInspectorMixin:CanNavigateBackward()
	return self.tableNavigationIndex > 1;
end

function TableInspectorMixin:NavigateBackward()
	if self:CanNavigateBackward() then
		self.tableNavigationIndex = self.tableNavigationIndex - 1;
		self:InspectTable(self.tableNavigation[self.tableNavigationIndex]);
	end
end

function TableInspectorMixin:CanNavigateForward()
	return self.tableNavigationIndex < #self.tableNavigation;
end

function TableInspectorMixin:NavigateForward()
	if self:CanNavigateForward() then
		self.tableNavigationIndex = self.tableNavigationIndex + 1;
		self:InspectTable(self.tableNavigation[self.tableNavigationIndex]);
	end
end

function TableInspectorMixin:DuplicateAttributeDisplay()
	local copy = DisplayTableInspectorWindow(self.focusedTable);
	copy:ClearAllPoints();
	local point, parent, relativePoint, xOffset, yOffset = self:GetPoint();
	copy:SetPoint(point, parent, relativePoint, xOffset + 60, yOffset + 60);
	copy:Show();
	return copy;
end

function TableInspectorMixin:SetFocusedFrameShown(shown)
	if self.focusedTable and self.focusedTable.SetShown then
		self.focusedTable:SetShown(shown);
	end
end

function TableInspectorMixin:SetDynamicUpdates(enabled)
	if enabled then
		self:SetScript("OnUpdate", function()
			self:RefreshAllData();
			self:UpdateLines();
		end);
		self.DynamicUpdateButton:SetChecked(true);
	else
		self:SetScript("OnUpdate", nil);
		self.DynamicUpdateButton:SetChecked(false);
	end
end

function TableInspectorMixin:UpdateFocusedHighlight()
	if self.focusedTable and self.focusedTable.GetDebugName and self.HighlightButton:GetChecked() then
		self.FrameHighlight:Show();
		self.FrameHighlight:HighlightFrame(self.focusedTable);
	else
		self.FrameHighlight:Hide();
	end
end

function TableInspectorMixin:SelectTable(selectedTable, selectedTableTitle)
	self:InspectTable(selectedTable, self.TitleButton.Text:GetText().." - "..selectedTableTitle);
end

function TableInspectorMixin:UpdateTableNavigation(newFocusedTable)
	-- We've branched to a new direction
	if newFocusedTable ~= self.tableNavigation[self.tableNavigationIndex] then		
		for i = self.tableNavigationIndex + 1, #self.tableNavigation do
			self.tableNavigation[i] = nil;
		end
		
		table.insert(self.tableNavigation, newFocusedTable);
		self.tableNavigationIndex = #self.tableNavigation;
	end
	
	self.NavigateBackwardButton:SetEnabled(self:CanNavigateBackward());
	self.NavigateForwardButton:SetEnabled(self:CanNavigateForward());
end

function TableInspectorMixin:InspectTable(focusedTable, title)
	self.LinesScrollFrame:SetVerticalScroll(0);
	self.FilterBox:SetText("");
	self.FilterBox:ClearFocus();
	self:UpdateTableNavigation(focusedTable);
	self.OpenParentButton:SetEnabled(focusedTable and focusedTable.GetParent and focusedTable:GetParent());
	self.focusedTable = focusedTable;
	if not focusedTable then
		self:ClearData();
		self.TitleButton.Text:SetText("No Table Selected");
		return;
	end
	
	if focusedTable.SetShown then
		self.VisibilityButton:SetChecked(focusedTable:IsShown());
		self.VisibilityButton:Enable();
		self:UpdateFocusedHighlight();
		self.HighlightButton:Enable();
	else
		self.VisibilityButton:Disable();
		self.HighlightButton:Disable();
		self.FrameHighlight:Hide();
	end	
	
	if title then
		self.TitleButton.Text:SetText(title);
	elseif focusedTable.GetDebugName then
		self.TitleButton.Text:SetText("Frame Attributes - "..focusedTable:GetDebugName());
	else
		self.TitleButton.Text:SetText("Table Attributes");
	end
	
	self:RefreshAllData();
	self:UpdateLines();
	
	if self.tableFocusedCallback then
		self.tableFocusedCallback(selectedTable);
	end
end

function TableAttributeDisplayDuplicateButton_OnClick(self)
	self:GetParent():DuplicateAttributeDisplay();
end

function TableAttributeDisplayParentButton_OnClick(self)
	self:GetParent():OpenParentDisplay();
end

function TableAttributeDisplayNavigateBackwardButton_OnClick(self)
	self:GetParent():NavigateBackward();
end

function TableAttributeDisplayNavigateForwardButton_OnClick(self)
	self:GetParent():NavigateForward();
end

function TableAttributeDisplayVisibilityButton_OnClick(self)
	self:GetParent():SetFocusedFrameShown(self:GetChecked());
end

function TableAttributeDisplayDynamicUpdateButton_OnClick(self)
	self:GetParent():SetDynamicUpdates(self:GetChecked());
end

function TableAttributeDisplayHighlightButton_OnClick(self)
	self:GetParent():UpdateFocusedHighlight();
end

function TableInspectorFilterBox_OnEnterPressed(self)
	self:ClearFocus();
end

function TableInspectorFilterBox_OnTextChanged(self)
	self:GetParent():UpdateLines();
end

function DisplayTableInspectorWindow(focusedTable, customTitle, tableFocusedCallback)
	local attributeDisplay = tableInspectorPool:Acquire();
	attributeDisplay:OnLoad();
	attributeDisplay:SetTableFocusedCallback(tableFocusedCallback);
	attributeDisplay:InspectTable(focusedTable, customTitle);
	attributeDisplay:SetPoint("LEFT", 64 + math.random(0, 64), math.random(0, 64));
	attributeDisplay:Show();
	return attributeDisplay;
end