local Mode =
{
	Fixed = 1,
	Rotated = 2,
};

local ModeData =
{
	[Mode.Fixed] = {
		frame = "UI-HUD-Minimap-Frame",
		mask = "ui-hud-minimap-frame-generic-mask",
	};

	[Mode.Rotated] = {
		frame = "UI-HUD-Minimap-Frame-Pointer",
		mask = "ui-hud-minimap-frame-generic-mask",
		underlay = "UI-HUD-Minimap-Frame-Circle",
	};
};

CVarCallbackRegistry:SetCVarCachable("rotateMinimap");

ExternalEventURLMinimapButtonStyle = {
	borderAtlas = "UI-HUD-Minimap-Frame-Cycle",
	borderWidth = 42,
	borderHeight = 42,
	spellEffectWidth = 151,
	spellEffectHeight = 151,
};

function MinimapClusterMixin:UpdateMinimapConfig()
	local rotateMinimap = CVarCallbackRegistry:GetCVarValueBool("rotateMinimap");
	local mode = rotateMinimap and Mode.Rotated or Mode.Fixed;
	local data = ModeData[mode];

	local atlasInfo = C_Texture.GetAtlasInfo(data.frame);
	local w, h = atlasInfo.width, atlasInfo.height;
	local minimapContainer = MinimapCluster.MinimapContainer;
	minimapContainer:SetSize(w, h);

	local minimap = minimapContainer.Minimap;
	minimap:SetMaskTexture(data.mask);

	MinimapBackdrop:SetSize(w, h);

	MinimapCompassTexture:SetAtlas(data.frame);
	MinimapCompassTexture:SetSize(w, h);

	-- The rotated implementation utilizes an underlay to achieve the effect of having
	-- the directional indicator rotated around a fixed circular frame.
	if data.underlay then
		MinimapCompassTextureUnderlay:SetAtlas(data.underlay);
		MinimapCompassTextureUnderlay:SetSize(w, h);
		MinimapCompassTextureUnderlay:Show();
	else
		MinimapCompassTextureUnderlay:Hide();
	end

	self.ZoneTextButton:SetFrameLevel(10);
end

function MinimapClusterMixin:ApplyExternalEventURLButtonAnchor()
	local externalEventURLButton = MinimapBackdrop.ExternalEventURLButton;
	externalEventURLButton:ClearAllPoints();
	externalEventURLButton:SetPoint("TOPLEFT", 9, -110);
end

function MinimapClusterMixin:SetHeaderUnderneath(headerUnderneath)
	if headerUnderneath then
		-- Since minimap container can be scaled, account for its scale when setting offsets.
		local scale = self.MinimapContainer:GetScale();
		self.MinimapContainer:ClearAllPoints();
		self.MinimapContainer:SetPoint("BOTTOM", self, "BOTTOM", 10 / scale, 30 / scale);

		self.ZoneTextButton:ClearAllPoints();
		self.ZoneTextButton:SetPoint("BOTTOM", self, "BOTTOM", -1, 8);

		self.IndicatorFrame:ClearAllPoints();
		self.IndicatorFrame:SetPoint("BOTTOMLEFT", self.ZoneTextButton, "TOPLEFT", 0, 0);

		AddonCompartmentFrame:ClearAllPoints();
		AddonCompartmentFrame:SetPoint("BOTTOM", GameTimeFrame, "TOP", 0, -1);
	else
		local accountForFrameScaleYes = true;
		self:ResetFramePoints(self.MinimapContainer, accountForFrameScaleYes);
		self:ResetFramePoints(self.ZoneTextButton);
		self:ResetFramePoints(self.IndicatorFrame);

		AddonCompartmentFrame:ClearAllPoints();
		AddonCompartmentFrame:SetPoint("TOP", GameTimeFrame, "BOTTOM", 0, 1);
	end

end

do
	CVarCallbackRegistry:RegisterCallback("rotateMinimap", function()
		MinimapCluster:UpdateMinimapConfig();
	end);
end
