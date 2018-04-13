VignetteDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function VignetteDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:InitializeAllTrackingTables();
end

function VignetteDataProviderMixin:OnShow()
	self:RegisterEvent("VIGNETTES_UPDATED");
	self.ticker = C_Timer.NewTicker(0, function() self:UpdatePinPositions() end);
end

function VignetteDataProviderMixin:OnHide()
	self:UnregisterEvent("VIGNETTES_UPDATED");
	if self.ticker then
		self.ticker:Cancel();
		self.ticker = nil;
	end
end

function VignetteDataProviderMixin:OnEvent(event, ...)
	if event == "VIGNETTES_UPDATED" then
		self:RefreshAllData();
	end
end

function VignetteDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("VignettePinTemplate");
	self:InitializeAllTrackingTables();
end

function VignetteDataProviderMixin:InitializeAllTrackingTables()
	self.vignetteGuidsToPins = {};
	self.uniqueVignettesGUIDs = {};
	self.uniqueVignettesPins = {};
end

function VignetteDataProviderMixin:RefreshAllData(fromOnShow)
	local pinsToRemove = {};
	for vignetteGUID, pin in pairs(self.vignetteGuidsToPins) do
		pinsToRemove[vignetteGUID] = pin;
	end

	local vignetteGUIDs = C_VignetteInfo.GetVignettes();
	local mapID = self:GetMap():GetMapID();
	for i, vignetteGUID in ipairs(vignetteGUIDs) do
		local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID);
		if vignetteInfo.onWorldMap then
			local existingPin = pinsToRemove[vignetteGUID];
			if existingPin then
				pinsToRemove[vignetteGUID] = nil;
				existingPin:UpdateFogOfWar(vignetteInfo);
			else
				local pin = self:GetMap():AcquirePin("VignettePinTemplate", vignetteGUID, vignetteInfo);
				self.vignetteGuidsToPins[vignetteGUID] = pin;
				if pin:IsUnique() then
					self:AddUniquePin(pin);
				end
			end
		end
	end

	for vignetteGUID, pin in pairs(pinsToRemove) do
		if pin:IsUnique() then
			self:RemoveUniquePin(pin);
		end
		self:GetMap():RemovePin(pin);
		self.vignetteGuidsToPins[vignetteGUID] = nil;
	end
end

function VignetteDataProviderMixin:OnMapChanged()
	self:RefreshAllData();
end

function VignetteDataProviderMixin:UpdatePinPositions()
	for vignetteGUID, pin in pairs(self.vignetteGuidsToPins) do
		if not pin:IsUnique() then
			pin:UpdatePosition();
		end
	end

	for vignetteID, vignettesGUIDs in pairs(self.uniqueVignettesGUIDs) do
		local bestVignetteIndex = C_VignetteInfo.FindBestUniqueVignette(vignettesGUIDs);
		for vignetteIndex, pin in ipairs(self.uniqueVignettesPins[vignetteID]) do
			pin:UpdatePosition(vignetteIndex == bestVignetteIndex);
		end
	end
end

function VignetteDataProviderMixin:AddUniquePin(pin)
	local vignetteID = pin:GetVignetteID();
	if not self.uniqueVignettesGUIDs[vignetteID] then
		self.uniqueVignettesGUIDs[vignetteID] = {};
		self.uniqueVignettesPins[vignetteID] = {};
	end

	table.insert(self.uniqueVignettesGUIDs[vignetteID], pin:GetVignetteGUID());
	table.insert(self.uniqueVignettesPins[vignetteID], pin);
end

function VignetteDataProviderMixin:RemoveUniquePin(pin)
	local vignetteID = pin:GetVignetteID();
	local uniquePins = self.uniqueVignettesPins[vignetteID];
	if uniquePins then	
		for i, uniquePin in ipairs(uniquePins) do
			if uniquePin == pin then
				table.remove(uniquePins, i);
				if #uniquePins == 0 then
					self.uniqueVignettesPins[vignetteID] = nil;
					self.uniqueVignettesGUIDs[vignetteID] = nil
				else
					table.remove(self.uniqueVignettesGUIDs[vignetteID], i);
				end

				return;
			end
		end
	end
end

--[[ Pin ]]--
VignettePinMixin = CreateFromMixins(MapCanvasPinMixin);

function VignettePinMixin:OnLoad()
	self:SetScalingLimits(1, 1.0, 1.2);
end

function VignettePinMixin:OnAcquired(vignetteGUID, vignetteInfo)
	self.vignetteGUID = vignetteGUID;
	self.name = vignetteInfo.name;
	self.hasTooltip = vignetteInfo.hasTooltip;
	self.isUnique = vignetteInfo.isUnique;
	self.vignetteID = vignetteInfo.vignetteID;

	self.Texture:SetAtlas(vignetteInfo.atlasName, true);
	self.HighlightTexture:SetAtlas(vignetteInfo.atlasName, true);

	local sizeX, sizeY = self.Texture:GetSize();
	self.HighlightTexture:SetSize(sizeX, sizeY);

	self:UpdateFogOfWar(vignetteInfo);

	self:SetSize(sizeX, sizeY);

	self.ShowAnim:Play();

	self:UpdatePosition();

	self:UseFrameLevelType("PIN_FRAME_LEVEL_VIGNETTE", self:GetMap():GetNumActivePinsByTemplate("VignettePinTemplate"));
end

function VignettePinMixin:OnReleased()
	self.ShowAnim:Stop();
end

function VignettePinMixin:IsUnique()
	return self.isUnique;
end

function VignettePinMixin:GetVignetteID()
	return self.vignetteID;
end

function VignettePinMixin:GetVignetteGUID()
	return self.vignetteGUID;
end

function VignettePinMixin:UpdateFogOfWar(vignetteInfo)
	self.Texture:SetDesaturation(vignetteInfo.inFogOfWar and 1 or 0);
	self.Texture:SetAlpha(vignetteInfo.inFogOfWar and .55 or 1);

	self.HighlightTexture:SetDesaturation(vignetteInfo.inFogOfWar and 1 or .75);
end

function VignettePinMixin:UpdatePosition(bestUniqueVignette)
	if self:IsUnique() and not bestUniqueVignette then
		self:Hide();
		return;
	end

	local position = C_VignetteInfo.GetVignettePosition(self.vignetteGUID, self:GetMap():GetMapID());
	if position then
		self:SetPosition(position:GetXY());
		self:Show();
	else
		self:Hide();
	end
end

function VignettePinMixin:OnMouseEnter()
	if self.hasTooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(self.name));
		GameTooltip:Show();
	end
end

function VignettePinMixin:OnMouseLeave()
	GameTooltip:Hide();
end