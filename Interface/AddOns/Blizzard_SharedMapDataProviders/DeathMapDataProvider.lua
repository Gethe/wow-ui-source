DeathMapDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

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
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	GameTooltip:SetText(CORPSE_RED);
	GameTooltip:Show();
end

function CorpsePinMixin:OnMouseLeave()
	GameTooltip:Hide();
end

DeathReleasePinMixin = CreateFromMixins(CorpsePinMixin);

function DeathReleasePinMixin:OnMouseEnter()
	local x, y = self:GetCenter();
	local parentX, parentY = self:GetParent():GetCenter();
	if ( x > parentX ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	GameTooltip:SetText(SPIRIT_HEALER_RELEASE_RED);
	GameTooltip:Show();
end

