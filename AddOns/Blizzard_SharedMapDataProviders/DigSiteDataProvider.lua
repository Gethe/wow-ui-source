DigSiteDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function DigSiteDataProviderMixin:OnShow()
	self:RegisterEvent("CVAR_UPDATE");
end

function DigSiteDataProviderMixin:OnHide()
	self:UnregisterEvent("CVAR_UPDATE");
end

function DigSiteDataProviderMixin:OnEvent(event, ...)
	if event == "CVAR_UPDATE" then
		local eventName, value = ...;
		if eventName == "SHOW_DIG_SITES" then
			self:RefreshAllData();
		end
	end
end

function DigSiteDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("DigSitePinTemplate");
end

function DigSiteDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	if not GetCVarBool("digSites") then
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