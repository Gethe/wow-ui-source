SpellBookHeaderMixin = {};

function SpellBookHeaderMixin:Init(elementData)
	if elementData.text then
		self.Text:SetText(elementData.text);
	end
end
