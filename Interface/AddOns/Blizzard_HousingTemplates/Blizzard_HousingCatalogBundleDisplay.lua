
HousingCatalogBundleDisplayMixin = {};

function HousingCatalogBundleDisplayMixin:Init(elementData)
	self.elementData = elementData;
end

function HousingCatalogBundleDisplayMixin.Reset(framePool, self)
	Pool_HideAndClearAnchors(framePool, self);
	self.elementData = nil;
end
