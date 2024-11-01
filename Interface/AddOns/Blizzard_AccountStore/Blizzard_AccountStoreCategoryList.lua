
AccountStoreCategoryMixin = {};

function AccountStoreCategoryMixin:OnClick()
	EventRegistry:TriggerEvent("AccountStore.CategorySelected", self.categoryID);
end

function AccountStoreCategoryMixin:SetCategory(categoryID)
	self.categoryID = categoryID;

	local categoryInfo = C_AccountStore.GetCategoryInfo(categoryID);
	self.Text:SetText(categoryInfo.name);
	self.Icon:SetTexture(categoryInfo.icon);
end


AccountStoreCategoryListMixin = {};

function AccountStoreCategoryListMixin:OnLoad()
	self.SelectionHighlight = self.ScrollBox.SelectionHighlight;

	self:InitScrollBox();

	self:AddDynamicEventMethod(EventRegistry, "AccountStore.StoreFrontSet", self.OnStoreFrontSet);
	self:AddDynamicEventMethod(EventRegistry, "AccountStore.CategorySelected", self.OnCategorySelected);
end

function AccountStoreCategoryListMixin:InitScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("AccountStoreCategoryTemplate", function(button, elementData)
		button:SetCategory(elementData.categoryID);
	end);
	view:SetPadding(16, 0, 0, 0, 0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox, SelectionBehaviorFlags.Intrusive);
	local function SelectionBehaviorCallback(selectionBehaviorSelf, elementData, selected)
		if not selected then
			self.SelectionHighlight:Hide();
		else
			local button = self.ScrollBox:FindFrame(elementData);
			if button then
				self:SetRowSelectedState(button);
			end
		end
	end

	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, SelectionBehaviorCallback, self);
end

function AccountStoreCategoryListMixin:OnStoreFrontSet(storeFrontID)
	self:SetCategories(C_AccountStore.GetCategories(storeFrontID));
end

function AccountStoreCategoryListMixin:OnCategorySelected(categoryID)
	local button = self.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return elementData.categoryID == categoryID;
	end);

	if button then
		self:SetRowSelectedState(button);
	end
end

function AccountStoreCategoryListMixin:SetCategories(categories)
	local dataProvider = CreateDataProviderWithAssignedKey(categories, "categoryID");
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	-- Start with the first category selected.
	EventRegistry:TriggerEvent("AccountStore.CategorySelected", categories[1]);
end

function AccountStoreCategoryListMixin:SetRowSelectedState(rowButton)
	self.SelectionHighlight:SetPoint("CENTER", rowButton, "CENTER", 0, 2);
	self.SelectionHighlight:Show();
end
