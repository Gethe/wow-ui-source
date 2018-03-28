DeathMapDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function DeathMapDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("CorpsePinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("DeathReleasePinTemplate");
end

function DeathMapDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	if (WorldMap_DoesCurrentMapHideMapIcons()) then
		return;
	end
	local corpseX, corpseY = GetCorpseMapPosition();
	if (corpseX ~= 0 and corpseY ~= 0) then
		local corpsePin = self:GetMap():AcquirePin("CorpsePinTemplate");
		corpsePin:SetPosition(corpseX, corpseY);
		corpsePin:Show();
	end
	local deathReleaseX, deathReleaseY = GetDeathReleasePosition();
	if (deathReleaseX ~= 0 and deathReleaseY ~= 0) then
		local deathReleasePin = self:GetMap():AcquirePin("DeathReleasePinTemplate");
		deathReleasePin:SetPosition(deathReleaseX, deathReleaseY);
		deathReleasePin:Show();
	end	
end

CorpsePinMixin = CreateFromMixins(MapCanvasPinMixin);

function CorpsePinMixin:OnAcquired()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_CORPSE");
end

function CorpsePinMixin:OnMouseEnter()
	WorldMap_HijackTooltip(self:GetMap());

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

	WorldMap_RestoreTooltip();
end

DeathReleasePinMixin = CreateFromMixins(CorpsePinMixin);

function DeathReleasePinMixin:OnMouseEnter()
	WorldMap_HijackTooltip(self:GetMap());

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

