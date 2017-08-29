GroupMembersDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function GroupMembersDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:GetMap():SetPinTemplateType("GroupMembersPinTemplate", "UnitPositionFrame");
	-- a single permanent pin
	local pin = self:GetMap():AcquirePin("GroupMembersPinTemplate");
	pin:SetTransformFlags(self:GetTransformFlags());
	pin:SetPosition(0.5, 0.5);
	pin:SetNeedsPeriodicUpdate(false);
	pin:SetShouldShowUnits("player", false);
	self.pin = pin;
end

function GroupMembersDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
	self:GetMap():RemoveAllPinsByTemplate("GroupMembersPinTemplate");
end

function GroupMembersDataProviderMixin:OnShow()
	assert(self.ticker == nil);
	self.ticker = C_Timer.NewTicker(0, function() self:RefreshAllData() end);
end

function GroupMembersDataProviderMixin:OnHide()
	self.ticker:Cancel();
	self.ticker = nil;
end

function GroupMembersDataProviderMixin:OnMapChanged()
	local mapAreaID = self:GetMap():GetMapID();
	self.pin:SetOverrideMapID(mapAreaID);
end

function GroupMembersDataProviderMixin:RefreshAllData(fromOnShow)
	self.pin:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
	local pinSize = 13 / FlightMapFrame.ScrollContainer:GetCanvasScale();
	if self.pinSize ~= pinSize then
		self.pin:SetPinSize("party", pinSize);
		self.pin:SetPinSize("raid", pinSize);
		self.pinSize = pinSize;
	end

	self.pin:UpdatePlayerPins();
	self.pin:UpdateTooltips(GameTooltip);
end

function GroupMembersDataProviderMixin:SetDynamicFrameStratas(zoomedOut, zoomedIn, threshold)
	self.zoomedOutStrata = zoomedOut;
	self.zoomedInStrata = zoomedIn;
	self.frameStrataThreshold = threshold or 0.5;
end

function GroupMembersDataProviderMixin:OnCanvasScaleChanged()
	-- We change the frame strata so that players will show above other flight map icons while zoomed in
	-- but not while zoomed out
	if self.frameStrataThreshold then
		if self:GetMap():GetCanvasZoomPercent() >= self.frameStrataThreshold then
			self.pin:SetFrameStrata(self.zoomedInStrata);
		else
			self.pin:SetFrameStrata(self.zoomedOutStrata);
		end
	end
	
	self.pin:ApplyCurrentPosition();
end

--[[ Group Members Pin ]]--
GroupMembersPinMixin = CreateFromMixins(MapCanvasPinMixin);

function GroupMembersPinMixin:OnLoad()
	UnitPositionFrameMixin.OnLoad(self);
	self:SetAlphaLimits(1.0, 1.0, 1.0);
end