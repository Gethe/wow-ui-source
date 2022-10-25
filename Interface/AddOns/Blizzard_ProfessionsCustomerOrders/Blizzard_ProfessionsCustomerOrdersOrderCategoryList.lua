ProfessionsCustomerOrdersOrderCategoryListElementMixin = {};

function ProfessionsCustomerOrdersOrderCategoryListElementMixin:OnEnter()
	self.MouseoverOverlay:Show();
end

function ProfessionsCustomerOrdersOrderCategoryListElementMixin:OnLeave()
	self.MouseoverOverlay:Hide();
end

function ProfessionsCustomerOrdersOrderCategoryListElementMixin:Init(elementData)
	self.Label:SetText(elementData.name);
end