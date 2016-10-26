UIPanelWindows["FlightMapFrame"] = { area = "center", pushable = 1, showFailedFunc = CloseTaxiMap, allowOtherPanels = 1 };

FlightMapMixin = {};

function FlightMapMixin:SetupTitle()
	self.BorderFrame.TitleText:SetText(FLIGHT_MAP);
	self.BorderFrame.Bg:SetColorTexture(0, 0, 0, 1);
	self.BorderFrame.Bg:SetParent(self);
	self.BorderFrame.TopTileStreaks:Hide();
	
	SetPortraitToTexture(self.BorderFrame.portrait, [[Interface/Icons/icon_petfamily_flying]]);
end

function FlightMapMixin:OnLoad()
	self:RegisterEvent("TAXIMAP_CLOSED");

	self:SetMaxZoom(.85);
	self:SetMinZoom(.275);

	self:SetupTitle();

	self:SetShouldZoomInOnClick(true);
	self:SetShouldPanOnClick(false);

	self:AddStandardDataProviders();
end

function FlightMapMixin:AddStandardDataProviders()
	self:AddDataProvider(CreateFromMixins(FlightMap_FlightPathDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(FlightMap_ZoneSummaryDataProvider));
	self:AddDataProvider(CreateFromMixins(ZoneLabelDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(ActiveQuestDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(GroupMembersDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(ClickToZoomDataProviderMixin));

	local worldQuestDataProvider = CreateFromMixins(WorldQuestDataProviderMixin);
	worldQuestDataProvider:SetMatchWorldMapFilters(true);
	self:AddDataProvider(worldQuestDataProvider);
end

function FlightMapMixin:OnShow()
	local continentID = GetTaxiMapID();
	self:SetMapID(continentID);

	self:ZoomOut();
end

function FlightMapMixin:OnHide()
	CloseTaxiMap();
end

function FlightMapMixin:OnEvent(event, ...)
	if event == "TAXIMAP_CLOSED" then
		HideUIPanel(self);
	end
end