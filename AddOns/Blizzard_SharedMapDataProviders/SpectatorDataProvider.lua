SpectatorDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function SpectatorDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:GetMap():SetPinTemplateType("SpectatorPinTemplate", "UnitPositionFrame");
	-- a single permanent pin
	local pin = self:GetMap():AcquirePin("SpectatorPinTemplate", self);
	pin:SetPosition(0.5, 0.5);
	pin:SetNeedsPeriodicUpdate(true);
	pin:UpdateShownUnits();
	self.pin = pin;
end

function SpectatorDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
	self:GetMap():RemoveAllPinsByTemplate("SpectatorPinTemplate");
end

function SpectatorDataProviderMixin:OnMapChanged()
	self.pin:OnMapChanged();
end

function SpectatorDataProviderMixin:RefreshAllData(fromOnShow)
	self.pin:Refresh(fromOnShow);
end

function SpectatorDataProviderMixin:SetUnitPinSize(unit, size)
	local unitPinSizes = self:GetUnitPinSizesTable();
	if unitPinSizes[unit] then
		unitPinSizes[unit] = size;
		if self.pin then
			self.pin:UpdateShownUnits();
		end
	end
end

function SpectatorDataProviderMixin:EnumerateUnitPinSizes()
	local unitPinSizes = self:GetUnitPinSizesTable();
	return next, unitPinSizes;
end

function SpectatorDataProviderMixin:ShouldShowUnit(unit)
	local unitPinSizes = self:GetUnitPinSizesTable();
	return unitPinSizes[unit] and unitPinSizes[unit] > 0;
end

function SpectatorDataProviderMixin:GetUnitPinSizesTable()
	if not self.unitPinSizes then
		self.unitPinSizes = {
			spectateda = 16,
			spectatedb = 16,
		};
	end
	return self.unitPinSizes;
end

--[[ Spectator Pin ]]--
SpectatorPinMixin = CreateFromMixins(MapCanvasPinMixin);

function SpectatorPinMixin:OnLoad()
	UnitPositionFrameMixin.OnLoad(self);
	self:SetAlphaLimits(1.0, 1.0, 1.0);
	self:SetIgnoreGlobalPinScale(true);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_GROUP_MEMBER");

	self:SetShouldShowUnits("player", false);
end

function SpectatorPinMixin:OnAcquired(dataProvider)
	self.dataProvider = dataProvider;
	self:SynchronizePinSizes();
end

function SpectatorPinMixin:OnShow()
	UnitPositionFrameMixin.OnShow(self);
end

function SpectatorPinMixin:OnHide()
	UnitPositionFrameMixin.OnHide(self);
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

function SpectatorPinMixin:OnUpdate()
	self:Refresh();
end

function SpectatorPinMixin:Refresh(fromOnShow)
	self:UpdatePlayerPins();

	self:UpdateTooltips(GameTooltip);

	if fromOnShow then
		self:OnMapChanged();
	end
end

function SpectatorPinMixin:OnMapChanged()
	local mapID = self:GetMap():GetMapID();
	local hideMapIcons = C_Map.GetMapDisplayInfo(mapID);
	if hideMapIcons then
		self:Hide();
	else
		self:SetUiMapID(mapID);
		self:Show();
	end
end

function SpectatorPinMixin:UpdateShownUnits()
	for unit, size in self.dataProvider:EnumerateUnitPinSizes() do
		self:SetShouldShowUnits(unit, size > 0);
	end
end

function SpectatorPinMixin:SynchronizePinSizes()
	local scale = self:GetMap():GetCanvasScale();
	for unit, size in self.dataProvider:EnumerateUnitPinSizes() do
		if self.dataProvider:ShouldShowUnit(unit) then
			self:SetPinSize(unit, size / scale);
		end
	end
end

function SpectatorPinMixin:OnCanvasSizeChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
	self:SynchronizePinSizes();
end

function SpectatorPinMixin:OnCanvasScaleChanged()
	self:SynchronizePinSizes();
end
