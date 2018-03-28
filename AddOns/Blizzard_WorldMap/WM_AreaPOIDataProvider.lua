
WorldMap_AreaPOIDataProviderMixin = CreateFromMixins(AreaPOIDataProviderMixin);

function WorldMap_AreaPOIDataProviderMixin:GetPinTemplate()
	return "WorldMap_AreaPOIPinTemplate";
end

WorldMap_AreaPOIPinMixin = CreateFromMixins(AreaPOIPinMixin);

function WorldMap_AreaPOIPinMixin:OnLoad()
	AreaPOIPinMixin.OnLoad(self);
end