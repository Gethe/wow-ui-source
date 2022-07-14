ProfessionsCrafterOrdersOrderListElementMixin = {};

function ProfessionsCrafterOrdersOrderListElementMixin:OnEnter()
	self.MouseoverOverlay:Show();
end

function ProfessionsCrafterOrdersOrderListElementMixin:OnLeave()
	self.MouseoverOverlay:Hide();
end

function ProfessionsCrafterOrdersOrderListElementMixin:Init(order)
	-- TEMP
	self.Label:SetText(Professions.FormatListElementText(order));
end