HardcorePopUpAcceptButtonMixin = {};

function HardcorePopUpAcceptButtonMixin:OnClick()
	CharacterCreateFrame:NavForward();
	self:GetParent():Hide();
end
