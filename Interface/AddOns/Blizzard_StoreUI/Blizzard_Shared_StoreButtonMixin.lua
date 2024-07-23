
--------------------------------------------------
-- STORE BUTTON MIXIN
StoreButtonMixin = {};

function StoreButtonMixin:OnLoad()
	if ( not self:IsEnabled() ) then
		self.Left:SetAtlas("shop-button-large-disabled-left");
		self.Middle:SetAtlas("shop-button-large-disabled-middle");
		self.Right:SetAtlas("shop-button-large-disabled-right");
	end
end

function StoreButtonMixin:OnShow()
	if ( self:IsEnabled() ) then
		-- we need to reset our textures just in case we were hidden before a mouse up fired
		self.Left:SetAtlas("shop-button-large-up-left");
		self.Middle:SetAtlas("shop-button-large-up-middle");
		self.Right:SetAtlas("shop-button-large-up-right");
	end

	local textWidth = self.Text:GetWidth();
	local width = self:GetWidth();
	if ( (width - 40) < textWidth ) then
		self:SetWidth(textWidth + 40);
	end
end

function StoreButtonMixin:OnDisable()
	self.Left:SetAtlas("shop-button-large-disabled-left");
	self.Middle:SetAtlas("shop-button-large-disabled-middle");
	self.Right:SetAtlas("shop-button-large-disabled-right");
end

function StoreButtonMixin:OnEnable()
	self.Left:SetAtlas("shop-button-large-up-left");
	self.Middle:SetAtlas("shop-button-large-up-middle");
	self.Right:SetAtlas("shop-button-large-up-right");
end

function StoreButtonMixin:OnMouseDown()
	if ( self:IsEnabled() ) then
		self.Left:SetAtlas("shop-button-large-down-left");
		self.Middle:SetAtlas("shop-button-large-down-middle");
		self.Right:SetAtlas("shop-button-large-down-right");
	end
end

function StoreButtonMixin:OnMouseUp()
	if ( self:IsEnabled() ) then
		self.Left:SetAtlas("shop-button-large-up-left");
		self.Middle:SetAtlas("shop-button-large-up-middle");
		self.Right:SetAtlas("shop-button-large-up-right");
	end
end
