FogOfWarFrameMixin = {};

function FogOfWarFrameMixin:OnLoad()
	self:RegisterEvent("FOG_OF_WAR_UPDATED");
end

function FogOfWarFrameMixin:OnEvent(event, ...)
	if event == "FOG_OF_WAR_UPDATED" then
		local forceUpdate = true;
		self:TryFindingBestFogOfWarID(forceUpdate);
	end
end

function FogOfWarFrameMixin:SetFogOfWarID(fogOfWarID, forceUpdate)
	if self.fogOfWarID ~= fogOfWarID or forceUpdate then
		self.fogOfWarID = fogOfWarID;
		self:UpdateFogOfWar();
	end
end

function FogOfWarFrameMixin:OnUiMapChanged(uiMapID)
	self:TryFindingBestFogOfWarID();
end

function FogOfWarFrameMixin:UpdateFogOfWar()
	if self.fogOfWarID then
		local fogOfWarInfo = C_FogOfWar.GetFogOfWarInfo(self.fogOfWarID);
		self:SetFogOfWarBackgroundAtlas(fogOfWarInfo.backgroundAtlas);
		self:SetFogOfWarMaskAtlas(fogOfWarInfo.maskAtlas);
		self:SetMaskScalar(fogOfWarInfo.maskScalar);

		self:Show();
	else
		self:Hide();
	end
end

function FogOfWarFrameMixin:TryFindingBestFogOfWarID(forceUpdate)
	if self:GetUiMapID() then
		self:SetFogOfWarID(C_FogOfWar.GetFogOfWarForMap(self:GetUiMapID()), forceUpdate);
	end
end

function FogOfWarFrameMixin:OnShow()
	self:TryFindingBestFogOfWarID();
end