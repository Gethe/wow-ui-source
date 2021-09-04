WorldMap_WorldQuestDataProviderMixin = CreateFromMixins(WorldQuestDataProviderMixin);

function WorldMap_WorldQuestDataProviderMixin:GetPinTemplate()
	return "WorldMap_WorldQuestPinTemplate";
end

function WorldMap_WorldQuestDataProviderMixin:ShouldShowQuest(info)
	if not WorldQuestDataProviderMixin.ShouldShowQuest(self, info) then
		return false;
	end
	local mapID = self:GetMap():GetMapID();
	return mapID == info.mapID;
end

function WorldMap_WorldQuestDataProviderMixin:OnAdded(canvas)
	WorldQuestDataProviderMixin.OnAdded(self, canvas);

	if not self.poiQuantizer then
		self.poiQuantizer = CreateFromMixins(WorldMapPOIQuantizerMixin);
		self.poiQuantizer.size = 75;
		self.poiQuantizer:OnLoad(self.poiQuantizer.size, self.poiQuantizer.size);
	end
end

function WorldMap_WorldQuestDataProviderMixin:RefreshAllData(fromOnShow)
	WorldQuestDataProviderMixin.RefreshAllData(self, fromOnShow);

	self.poiQuantizer:ClearAndQuantize(self.activePins);

	for i, pin in pairs(self.activePins) do
		pin:SetPosition(pin.quantizedX or pin.normalizedX, pin.quantizedY or pin.normalizedY);
	end
end

function WorldMap_WorldQuestDataProviderMixin:OnCanvasSizeChanged()
	local ratio = self:GetMap():DenormalizeHorizontalSize(1.0) / self:GetMap():DenormalizeVerticalSize(1.0);
	self.poiQuantizer:Resize(math.ceil(self.poiQuantizer.size * ratio), self.poiQuantizer.size);
end

WorldMap_WorldQuestPinMixin = CreateFromMixins(WorldQuestPinMixin);

function WorldMap_WorldQuestPinMixin:OnLoad()
	WorldQuestPinMixin.OnLoad(self);

	self:SetScalingLimits(1, 0.425, 0.425);
end

function WorldMap_WorldQuestPinMixin:RefreshVisuals()
	WorldQuestPinMixin.RefreshVisuals(self);
	self.TrackedCheck:SetShown(WorldMap_IsWorldQuestEffectivelyTracked(self.questID));
end