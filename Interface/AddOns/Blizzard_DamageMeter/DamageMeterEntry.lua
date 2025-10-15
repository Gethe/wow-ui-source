DamageMeterEntryMixin = {};

function DamageMeterEntryMixin:Init(elementData)
	self.Icon.Icon:SetTexture(elementData.texture);
	self.StatusBar:SetMinMaxValues(0, elementData.maxValue);
	self.StatusBar:SetValue(elementData.value);
end
