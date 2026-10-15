local GameTimeFrameMixin_OnLoad = GameTimeFrameMixin.OnLoad;

function GameTimeFrameMixin:OnLoad()
	GameTimeFrameMixin_OnLoad(self);

	self.StateTexture:SetAtlas("ui-hud-minimap-calendar-button", TextureKitConstants.UseAtlasSize);
	self.AddTexture:SetBlendMode("ADD");
	self.AddTexture:SetAlpha(0);
end

function GameTimeFrameMixin:OnButtonStateChanged()
	self.StateTexture:SetAtlas("ui-hud-minimap-calendar-button", TextureKitConstants.UseAtlasSize);

	local isMouseDown = self:IsDownOver() or self:IsDown();
	local isMouseOver = self:IsOver();
	local addAlpha = 0;
	if isMouseDown then
		addAlpha = self.mousedownAddAlpha;
	elseif isMouseOver then
		addAlpha = self.mouseoverAddAlpha;
	end

	self.AddTexture:SetShown(addAlpha > 0);
	self.AddTexture:SetAlpha(addAlpha);
end