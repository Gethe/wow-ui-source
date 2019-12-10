DeathMapDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function DeathMapDataProviderMixin:OnShow() 
	self:RegisterEvent("CORPSE_POSITION_UPDATE");
end

function DeathMapDataProviderMixin:OnHide()
	self:UnregisterEvent("CORPSE_POSITION_UPDATE");
end

function DeathMapDataProviderMixin:OnEvent(event, ...)
	if event == "CORPSE_POSITION_UPDATE" then
		self:RefreshAllData();
	end
end

function DeathMapDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("CorpsePinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("DeathReleasePinTemplate");
end

function DeathMapDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	local corpsePosition = C_DeathInfo.GetCorpseMapPosition(mapID);
	if corpsePosition then
		local corpsePin = self:GetMap():AcquirePin("CorpsePinTemplate");
		corpsePin:SetPosition(corpsePosition:GetXY());
		corpsePin:Show();
	end

	--[[ Disabled for now, need a different icon to reduce confusion
	local deathReleasePosition = C_DeathInfo.GetDeathReleasePosition(mapID);
	if deathReleasePosition then
		local deathReleasePin = self:GetMap():AcquirePin("DeathReleasePinTemplate");
		deathReleasePin:SetPosition(deathReleasePosition:GetXY());
		deathReleasePin:Show();
	end	
	]]
end

CorpsePinMixin = CreateFromMixins(MapCanvasPinMixin);

function CorpsePinMixin:OnLoad()
	WorldQuestPinMixin.OnLoad(self);
	self:SetScalingLimits(1, 0.8, 0.8);
end

function CorpsePinMixin:OnAcquired()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_CORPSE");
end

function CorpsePinMixin:OnMouseEnter()
	local x, y = self:GetCenter();
	local parentX, parentY = self:GetParent():GetCenter();
	if ( x > parentX ) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_LEFT");
	else
		WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	WorldMapTooltip:SetText(CORPSE_RED);
	WorldMapTooltip:Show();
end

function CorpsePinMixin:OnMouseLeave()
	WorldMapTooltip:Hide();
end

DeathReleasePinMixin = CreateFromMixins(CorpsePinMixin);

function DeathReleasePinMixin:OnMouseEnter()
	local x, y = self:GetCenter();
	local parentX, parentY = self:GetParent():GetCenter();
	if ( x > parentX ) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_LEFT");
	else
		WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	WorldMapTooltip:SetText(SPIRIT_HEALER_RELEASE_RED);
	WorldMapTooltip:Show();
end

