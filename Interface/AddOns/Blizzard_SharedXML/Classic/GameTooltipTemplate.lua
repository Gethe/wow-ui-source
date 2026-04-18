GameTooltipMixin = {};

function GameTooltipMixin:OnLoadGameTooltip()
	GameTooltip_OnLoad(self);
	self.shoppingTooltips = { ShoppingTooltip1, ShoppingTooltip2 };
end

function GameTooltipMixin:OnHide()
	GameTooltip_OnHide(self);
end

function GameTooltipMixin:OnTooltipSetDefaultAnchor()
	GameTooltip_SetDefaultAnchor(self, UIParent);
end

function GameTooltipMixin:OnTooltipAddMoney(cost, maxCost)
	GameTooltip_OnTooltipAddMoney(self, cost, maxCost);
end

function GameTooltipMixin:OnTooltipCleared()
	GameTooltip_ClearMoney(self);
	GameTooltip_ClearInsertedFrames(self);
end

GameTooltipStatusBarMixin = {};

function GameTooltipStatusBarMixin:OnValueChanged(value)
	HealthBar_OnValueChanged(self, value);
end

TooltipStatusBarMixin = {};

function TooltipStatusBarMixin:OnLoad()
	self:SetStatusBarColor(0, 1.0, 0);
end

ShoppingTooltipMixin = {};

function ShoppingTooltipMixin:OnTooltipCleared()
	GameTooltip_ClearMoney(self);
	GameTooltip_ClearInsertedFrames(self);
	GameTooltip_UpdateStyle(self);
end
