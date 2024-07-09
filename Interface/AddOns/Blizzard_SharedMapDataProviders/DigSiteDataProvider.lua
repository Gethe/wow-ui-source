DigSiteDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin);
DigSiteDataProviderMixin:Init("digSites");

function DigSiteDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:GetMap():SetPinTemplateType("DigSiteBlobPinTemplate", "ArchaeologyDigSiteFrame");
end

function DigSiteDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("DigSitePinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("DigSiteBlobPinTemplate");
end

function DigSiteDataProviderMixin:OnShow()
	CVarMapCanvasDataProviderMixin.OnShow(self);
	self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
end

function DigSiteDataProviderMixin:OnHide()
	CVarMapCanvasDataProviderMixin.OnHide(self);
	self:UnregisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
end

function DigSiteDataProviderMixin:OnEvent(event, ...)
	CVarMapCanvasDataProviderMixin.OnEvent(self, event, ...);
	if event == "RESEARCH_ARTIFACT_DIG_SITE_UPDATED" then
			self:RefreshAllData();
	end
end

function DigSiteDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	
	if not self:IsCVarSet() then
		return;
	end

	local mapID = self:GetMap():GetMapID();
	local digSites = C_ResearchInfo.GetDigSitesForMap(mapID);
	self.pins = {};
	for i, digSiteInfo in ipairs(digSites) do
		

		if(self:IsZoneMapType()) then
			-- Only use blob pins if we are zoomed into a zone on the world map
			local pin = self:GetMap():AcquirePin("DigSiteBlobPinTemplate", digSiteInfo);
			pin.digSiteInfo = digSiteInfo;
			pin:SetMapID(mapID);
		else
			-- Create shovel icon pin
			self:GetMap():AcquirePin("DigSitePinTemplate", digSiteInfo);
		end
	end
end



function DigSiteDataProviderMixin:IsZoneMapType()
	local mapID = self:GetMap():GetMapID();
	if (mapID) then
		local mapInfo = C_Map.GetMapInfo(mapID);
		return mapInfo and mapInfo.mapType == Enum.UIMapType.Zone;
	end

	return false;
end

--[[ Blob Pin ]]--
DigSiteBlobPinMixin = CreateFromMixins(MapCanvasPinMixin);

function DigSiteBlobPinMixin:OnLoad()
	self:SetFillTexture("Interface\\WorldMap\\UI-ArchaeologyBlob-Inside");
	self:SetBorderTexture("Interface\\WorldMap\\UI-ArchaeologyBlob-Outside");
	self:SetFillAlpha(128);
	self:SetBorderAlpha(192);
	self:SetBorderScalar(0.5);
	self:SetIgnoreGlobalPinScale(true);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_DIG_SITE");
end

function DigSiteBlobPinMixin:OnCanvasSizeChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
	self:MarkDirty();
end

function DigSiteBlobPinMixin:OnAcquired(poiInfo)
	self.name = poiInfo.name;
	self.description = poiInfo.description;
	self.tooltipWidgetSet = poiInfo.tooltipWidgetSet;

	self:SetPosition(0.5, 0.5); 
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
end

function DigSiteBlobPinMixin:OnCanvasScaleChanged()
	-- need to wait until end of the frame to update
	self:MarkDirty();
end

function DigSiteBlobPinMixin:MarkDirty()
	self.dirty = true;
end

function DigSiteBlobPinMixin:OnUpdate()
	if self.dirty then
		self.dirty = nil;
		self:TryDrawDigSite();
	end
end

function DigSiteBlobPinMixin:TryDrawDigSite()
	self:DrawNone();
	if(self.digSiteInfo) then
		self:DrawBlob(self.digSiteInfo.poiBlobID, true);
	end
end

--[[ Pin ]]--
DigSitePinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DIG_SITE");