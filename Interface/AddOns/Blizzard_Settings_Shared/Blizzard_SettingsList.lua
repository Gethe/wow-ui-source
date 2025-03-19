local securecallfunction = securecallfunction;
local pairs = pairs;

-- Matches a similar function reused in multiple places
local function EnumerateTaintedKeysTable(tableToIterate)
	local pairsIterator, enumerateTable, initialIteratorKey = securecallfunction(pairs, tableToIterate);
	local function IteratorFunction(tbl, key)
		return securecallfunction(pairsIterator, tbl, key);
	end

	return IteratorFunction, enumerateTable, initialIteratorKey;
end

SettingsListSearchCategoryMixin = {};

function SettingsListSearchCategoryMixin:Init(initializer)
	local data = initializer:GetData();
	self.Title:SetText(data.category:GetQualifiedName());
end

function SettingsListSearchCategoryMixin:OnClick(button, buttonName, down)
	local initializer = self:GetElementData();
	local data = initializer:GetData();
	local force = true;
	SettingsPanel:SelectCategory(data.category, force);
end

function SettingsListSearchCategoryMixin:OnEnter()
	self.MouseoverOverlay:Show();
end

function SettingsListSearchCategoryMixin:OnLeave()
	self.MouseoverOverlay:Hide();
end

function CreateSettingsListSearchCategoryInitializer(category)
	local data = {category = category};
	return Settings.CreateElementInitializer("SettingsListSearchCategoryTemplate", data);
end

SettingsListMixin = {};

function SettingsListMixin:OnLoad()
	local verticalPad = 10;
	local padLeft, padRight = 25, 0;
	local spacing = 9;
	local view = CreateScrollBoxListLinearView(verticalPad, verticalPad, padLeft, padRight, spacing);

	local function Factory(factory, elementData)
		local function Initializer(frame, elementData)
			securecallfunction(elementData.InitFrame, elementData, frame);
		end
		securecallfunction(elementData.Factory, elementData, factory, Initializer);
	end

	local function Resetter(frame, elementData)
		securecallfunction(elementData.Resetter, elementData, frame);
	end

	local function ExtentCalculator(dataIndex, elementData)
		local extent = securecallfunction(elementData.GetExtent, elementData);
		return extent or view:GetTemplateExtent(securecallfunction(elementData.GetTemplate, elementData));
	end

	view:SetElementFactory(Factory);
	view:SetElementResetter(Resetter);
	view:SetElementExtentCalculator(ExtentCalculator);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local scrollBoxAnchors = 
	{
		CreateAnchor("TOPLEFT", self.Header, "BOTTOMLEFT", -15, -2),
		CreateAnchor("BOTTOMRIGHT", -20, -2);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchors, scrollBoxAnchors);
	
	ScrollUtil.AddResizableChildrenBehavior(self.ScrollBox);
end

function SettingsListMixin:SetInputBlockerShown(shown)
	if shown then
		self.ScrollBox.InputBlocker:SetFrameStrata("DIALOG");
		self.ScrollBox.InputBlocker:Show();
	else
		self.ScrollBox.InputBlocker:Hide();
	end
end

function SettingsListMixin:GetInputBlocker()
	return self.ScrollBox.InputBlocker;
end

-- Used when a setting value change results in other settings needing to have their
-- visibility changed. For example, checking a bool setting may hide one child, but show
-- another.

function SettingsListMixin:RepairDisplay(layout)
	-- The order isn't stored on the initializer itself because initializers can be mirrored in
	-- another settings lists, namely Acessibility.
	local order = {};
	for index, initializer in layout:EnumerateInitializers() do
		order[initializer] = index;
	end

	-- Remove what is no longer intended to be shown.
	local dataProvider = self.ScrollBox:GetDataProvider();
	local shown = {};
	for index, initializer in dataProvider:ReverseEnumerate() do
		if initializer:ShouldShow() then
			shown[initializer] = true;
		else
			dataProvider:RemoveIndex(index);
		end
	end

	-- Add any newly shown, out of position at the end. Will be corrected when sorted.
	for index, initializer in EnumerateTaintedKeysTable(layout:GetInitializers()) do
		if not shown[initializer] and initializer:ShouldShow() then
			dataProvider:Insert(initializer);
		end
	end

	-- Reorder and sort the list.
	local function Comparator(e1, e2)
		return order[e1] < order[e2];
	end
	dataProvider:SetSortComparator(Comparator);
	dataProvider:ClearSortComparator();
end

function SettingsListMixin:Display(initializers)
	local dataProvider = CreateDataProvider();
	for key, initializer in EnumerateTaintedKeysTable(initializers) do
		if initializer:ShouldShow() then
			dataProvider:Insert(initializer);
		end
	end

	securecallfunction(self.ScrollBox.SetDataProvider, self.ScrollBox, dataProvider);
end

function SettingsListMixin:ScrollToElementByName(name)
	self.ScrollBox:ScrollToElementDataByPredicate(function(elementData)
		local data = securecallfunction(rawget, elementData, "data");
		local elementName = securecallfunction(rawget, data, "name");
		return elementName == name;
	end, ScrollBoxConstants.AlignBegin);
end