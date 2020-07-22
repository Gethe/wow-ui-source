
RuneforgeCreateFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgeCreateFrameMixin:OnLoad()
	self.Cost:SetTextAnchorPoint("CENTER");
	self:UpdateCost();
end

function RuneforgeCreateFrameMixin:OnShow()
	self:RegisterRefreshMethod(self.Refresh);
	self:GetRuneforgeFrame():RegisterCallback(RuneforgeFrameMixin.Event.UpgradeItemChanged, self.Refresh, self);
	self:Refresh();
end

function RuneforgeCreateFrameMixin:OnHide()
	self:UnregisterRefreshMethod();
	self:GetRuneforgeFrame():UnregisterCallback(RuneforgeFrameMixin.Event.UpgradeItemChanged, self);
end

function RuneforgeCreateFrameMixin:CraftItem()
	local runeforgeFrame = self:GetRuneforgeFrame();
	if self:IsRuneforgeUpgrading() then
		local baseItem = runeforgeFrame:GetItem();
		local upgradeItem = runeforgeFrame:GetUpgradeItem();
		C_LegendaryCrafting.UpgradeRuneforgeLegendary(baseItem, upgradeItem);
	else
		local craftDescription = runeforgeFrame:GetCraftDescription();
		C_LegendaryCrafting.CraftRuneforgeLegendary(craftDescription);
	end
end

function RuneforgeCreateFrameMixin:Close()
	self:GetRuneforgeFrame():Close();
end

function RuneforgeCreateFrameMixin:Refresh()
	local canCraft, errorString = self:GetRuneforgeFrame():CanCraftRuneforgeLegendary();
	self.CraftItemButton:SetCraftState(canCraft, errorString);
	self.CraftError:SetShown(errorString ~= nil);
	self.CraftError:SetText(errorString);

	self:UpdateCost();
end

function RuneforgeCreateFrameMixin:UpdateCost()
	local currenciesCost = self:GetRuneforgeFrame():GetCost();
	local showCost = (currenciesCost ~= nil) and (#currenciesCost > 0);
	self.Cost:SetShown(showCost);

	if showCost then
		self.Cost:SetCurrencies(currenciesCost, RUNEFORGE_LEGENDARY_COST_FORMAT);
	end
end

function RuneforgeCreateFrameMixin:GetRuneforgeFrame()
	return self:GetParent();
end


RuneforgeCraftItemButtonMixin = {};

function RuneforgeCraftItemButtonMixin:OnShow()
	self:SetText(self:GetParent():IsRuneforgeUpgrading() and LEGENDARY_CRAFTING_UPGRADE_ITEM or LEGENDARY_CRAFTING_CRAFT_ITEM);
end

function RuneforgeCraftItemButtonMixin:OnClick()
	self:GetParent():CraftItem();
end

function RuneforgeCraftItemButtonMixin:OnEnter()
	if self.errorString then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(GameTooltip, self.errorString);
		GameTooltip:Show();
	end
end

function RuneforgeCraftItemButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function RuneforgeCraftItemButtonMixin:SetCraftState(canCraft, errorString)
	self:SetEnabled(canCraft);
	self.errorString = errorString;
end


RuneforgeCloseButtonMixin = {};

function RuneforgeCloseButtonMixin:OnClick()
	self:GetParent():Close();
end
