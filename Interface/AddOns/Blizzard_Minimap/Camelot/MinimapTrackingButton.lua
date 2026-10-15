function MiniMapTrackingButtonMixin:OnButtonStateChanged()
	self.StateTexture:SetAtlas("ui-hud-minimap-tracking-button", TextureKitConstants.UseAtlasSize);

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

local MiniMapTrackingButtonMixin_OnLoad = MiniMapTrackingButtonMixin.OnLoad;

function MiniMapTrackingButtonMixin:OnLoad()
	MiniMapTrackingButtonMixin_OnLoad(self);

	self.AddTexture:SetBlendMode("ADD");
	self.AddTexture:SetAlpha(0);
end