
RuneforgeCreateFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

local RefreshEventNames = {
	"BaseItemChanged",
	"PowerSelected",
	"ModifiersChanged",
};

function RuneforgeCreateFrameMixin:OnLoad()
	self.Cost:SetTextAnchorPoint("CENTER");
	self:UpdateCost();
end

function RuneforgeCreateFrameMixin:OnShow()
	local runeforgeFrame = self:GetRuneforgeFrame();
	for i, eventName in ipairs(RefreshEventNames) do
		runeforgeFrame:RegisterCallback(RuneforgeFrameMixin.Event[eventName], self.Refresh, self);
	end

	self:Refresh();
end

function RuneforgeCreateFrameMixin:OnHide()
	local runeforgeFrame = self:GetRuneforgeFrame();
	for i, eventName in ipairs(RefreshEventNames) do
		runeforgeFrame:UnregisterCallback(RuneforgeFrameMixin.Event[eventName], self);
	end
end

function RuneforgeCreateFrameMixin:CraftItem()
	local craftDescription = self:GetRuneforgeFrame():GetCraftDescription();
	C_LegendaryCrafting.CraftRuneforgeLegendary(craftDescription);
end

function RuneforgeCreateFrameMixin:Close()
	self:GetRuneforgeFrame():Close();
end

function RuneforgeCreateFrameMixin:Refresh()
	local craftDescription = self:GetRuneforgeFrame():GetCraftDescription();
	self.CraftItemButton:SetEnabled(craftDescription and C_LegendaryCrafting.CanCraftRuneforgeLegendary(craftDescription));
	self:UpdateCost();
end

function RuneforgeCreateFrameMixin:UpdateCost()
	local baseItem = self:GetRuneforgeFrame():GetItem();
	local currenciesCost = baseItem and C_LegendaryCrafting.GetRuneforgeLegendaryCost(baseItem) or nil;
	local showCost = (currenciesCost ~= nil) and (#currenciesCost > 0);
	self.Cost:SetShown(showCost);

	if showCost then
		self.Cost:SetCurrencies(currenciesCost, RUNEFORGE_LEGENDARY_COST_FORMAT);
	end
end


RuneforgeCraftItemButtonMixin = {};

function RuneforgeCraftItemButtonMixin:OnClick()
	self:GetParent():CraftItem();
end


RuneforgeCloseButtonMixin = {};

function RuneforgeCloseButtonMixin:OnClick()
	self:GetParent():Close();
end
