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

function SettingsListMixin:OnLoad(elementData)
	local verticalPad = 10;
	local pad = 0;
	local spacing = 15;
	local view = CreateScrollBoxListLinearView(verticalPad, verticalPad, pad, pad, spacing);

	local function Factory(factory, elementData)
		local function Initializer(frame, elementData)
			elementData:InitFrame(frame);
		end
		elementData:Factory(factory, Initializer);
	end

	local function Resetter(frame, elementData)
		elementData:Resetter(frame);
	end

	local function ExtentCalculator(dataIndex, elementData)
		local extent = elementData:GetExtent();
		return extent or view:CreateTemplateExtent(elementData:GetTemplate());
	end

	view:SetElementFactory(Factory);
	view:SetElementResetter(Resetter);
	view:SetElementExtentCalculator(ExtentCalculator);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local scrollBoxAnchors = 
	{
		CreateAnchor("TOPLEFT", self.Header, "BOTTOMLEFT", 10, -2),
		CreateAnchor("BOTTOMRIGHT", -20, 10);
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
	local dataProvider = CreateDataProvider(initializers);
	self.ScrollBox:SetDataProvider(dataProvider);
end

function SettingsListMixin:ScrollToElementByName(name)
	self.ScrollBox:ScrollToElementDataByPredicate(function(elementData) return elementData.data.name == name; end, ScrollBoxConstants.AlignBegin);
end