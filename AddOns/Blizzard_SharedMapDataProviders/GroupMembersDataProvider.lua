GroupMembersDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function GroupMembersDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:GetMap():SetPinTemplateType("GroupMembersPinTemplate", "UnitPositionFrame");
	-- a single permanent pin
	local pin = self:GetMap():AcquirePin("GroupMembersPinTemplate");
	pin.dataProvider = self;
	pin:SetPosition(0.5, 0.5);
	pin:SetNeedsPeriodicUpdate(true);
	pin:UpdateShownUnits();
	self.pin = pin;
end

function GroupMembersDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
	self:GetMap():RemoveAllPinsByTemplate("GroupMembersPinTemplate");
end

function GroupMembersDataProviderMixin:OnMapChanged()
	self.pin:OnMapChanged();
end

function GroupMembersDataProviderMixin:RefreshAllData(fromOnShow)
	self.pin:Refresh(fromOnShow);
end

function GroupMembersDataProviderMixin:SetUnitPinSize(unit, size)
	local unitPinSizes = self:GetUnitPinSizesTable();
	if unitPinSizes[unit] then
		unitPinSizes[unit] = size;
		if self.pin then
			self.pin:UpdateShownUnits();
		end
	end
end

function GroupMembersDataProviderMixin:EnumerateUnitPinSizes()
	local unitPinSizes = self:GetUnitPinSizesTable();
	return next, unitPinSizes;
end

function GroupMembersDataProviderMixin:ShouldShowUnit(unit)
	local unitPinSizes = self:GetUnitPinSizesTable();
	return unitPinSizes[unit] > 0;
end

function GroupMembersDataProviderMixin:GetUnitPinSizesTable()
	if not self.unitPinSizes then
		self.unitPinSizes = {
			player = 27,
			party = 11,
			raid = 11 * 0.75;
		};
	end
	return self.unitPinSizes;
end

--[[ Group Members Pin ]]--
GroupMembersPinMixin = CreateFromMixins(MapCanvasPinMixin);

function GroupMembersPinMixin:OnLoad()
	UnitPositionFrameMixin.OnLoad(self);
	self:SetAlphaLimits(1.0, 1.0, 1.0);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_GROUP_MEMBER");

	self:SetPlayerPingTexture(1, "Interface\\minimap\\UI-Minimap-Ping-Center", 32, 32);
	self:SetPlayerPingTexture(2, "Interface\\minimap\\UI-Minimap-Ping-Expand", 32, 32);
	self:SetPlayerPingTexture(3, "Interface\\minimap\\UI-Minimap-Ping-Rotate", 70, 70);

	self:SetMouseOverUnitExcluded("player", true);
	self:SetPinTexture("player", "Interface\\WorldMap\\WorldMapArrow");
end

function GroupMembersPinMixin:OnShow()
	UnitPositionFrameMixin.OnShow(self);
end

function GroupMembersPinMixin:OnHide()
	UnitPositionFrameMixin.OnHide(self);
	if self.dataProvider:ShouldShowUnit("player") then
		self:StopPlayerPing();
	end
end

function GroupMembersPinMixin:OnUpdate()
	self:Refresh();
end

function GroupMembersPinMixin:Refresh(fromOnShow)
	self:UpdatePlayerPins();
	-- TODO: Fix this for fullscreen map
	self:UpdateTooltips(GameTooltip);
end

function GroupMembersPinMixin:OnMapChanged()
	local mapID = self:GetMap():GetMapID();
	local hideMapIcons = C_Map.GetMapDisplayInfo(mapID);
	if hideMapIcons then
		self:Hide();
	else
		self:SetOverrideMapID(mapID);
		self:Show();
		if self.dataProvider:ShouldShowUnit("player") then
			self:StartPlayerPing(2, .25);
		end
	end	
end

function GroupMembersPinMixin:UpdateShownUnits()
	for unit, size in self.dataProvider:EnumerateUnitPinSizes() do
		self:SetShouldShowUnits(unit, size > 0);
	end
end

function GroupMembersPinMixin:OnCanvasScaleChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
	local scale = self:GetMap():GetCanvasScale();
	for unit, size in self.dataProvider:EnumerateUnitPinSizes() do
		if self.dataProvider:ShouldShowUnit(unit) then
			self:SetPinSize(unit, size / scale);
		end
	end
end