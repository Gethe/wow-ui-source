ProfessionsCustomerOrdersOrderListElementMixin = {};

function ProfessionsCustomerOrdersOrderListElementMixin:OnEnter()
	self.MouseoverOverlay:Show();
end

function ProfessionsCustomerOrdersOrderListElementMixin:OnLeave()
	self.MouseoverOverlay:Hide();
end

function ProfessionsCustomerOrdersOrderListElementMixin:Init(order)
	-- TEMP
	self.Label:SetText(Professions.FormatListElementText(order));
end