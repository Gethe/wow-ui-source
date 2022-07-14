DigSiteDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin);
DigSiteDataProviderMixin:Init("digSites", "SHOW_DIG_SITES");

function DigSiteDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("DigSitePinTemplate");
end

function DigSiteDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	
	if not self:IsCVarSet() then
		return;
	end

	local mapID = self:GetMap():GetMapID();
	local digSites = C_ResearchInfo.GetDigSitesForMap(mapID);
	for i, digSiteInfo in ipairs(digSites) do
		self:GetMap():AcquirePin("DigSitePinTemplate", digSiteInfo);
	end
end

--[[ Pin ]]--
DigSitePinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DIG_SITE");