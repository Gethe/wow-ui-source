
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
	local pad = 0;
	local spacing = 9;
	local view = CreateScrollBoxListLinearView(verticalPad, verticalPad, pad, pad, spacing);

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
		return extent or view:CreateTemplateExtent(securecallfunction(elementData.GetTemplate, elementData));
	end

	view:SetElementFactory(Factory);
	view:SetElementResetter(Resetter);
	view:SetElementExtentCalculator(ExtentCalculator);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local scrollBoxAnchors = 
	{
		CreateAnchor("TOPLEFT", self.Header, "BOTTOMLEFT", 10, -2),
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