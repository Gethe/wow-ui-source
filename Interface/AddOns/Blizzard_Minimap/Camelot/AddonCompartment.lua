local AddonCompartmentMixin_OnLoad = AddonCompartmentMixin.OnLoad;

function AddonCompartmentMixin:OnLoad()
	AddonCompartmentMixin_OnLoad(self);

	self.StateTexture:SetAtlas("ui-hud-minimap-addon-indicator", TextureKitConstants.UseAtlasSize);
	self.AddTexture:SetBlendMode("ADD");
	self.AddTexture:SetAlpha(0);
	self.Text:SetScale(0.9);
end

function AddonCompartmentMixin:OnButtonStateChanged()
	self.StateTexture:SetAtlas("ui-hud-minimap-addon-indicator", TextureKitConstants.UseAtlasSize);

	local isMouseDown = self:IsDownOver() or self:IsDown();
	local isMouseOver = self:IsOver() or self:IsMenuOpen();
	local addAlpha = 0;
	if isMouseDown then
		addAlpha = self.mousedownAddAlpha;
	elseif isMouseOver then
		addAlpha = self.mouseoverAddAlpha;
	end

	self.AddTexture:SetShown(addAlpha > 0);
	self.AddTexture:SetAlpha(addAlpha);
end
