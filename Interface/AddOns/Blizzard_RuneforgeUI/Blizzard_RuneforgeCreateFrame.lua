
StaticPopupDialogs["CONFIRM_RUNEFORGE_LEGENDARY_CRAFT"] = {
	text = "",
	button1 = YES,
	button2 = NO,

	OnShow = function(self, data)
		self.text:SetText(data.title);
	end,

	OnAccept = function()
		RuneforgeFrame:CraftItem();
	end,

	hideOnEscape = 1,
	hasItemFrame = 1,
	acceptDelay = 5;
};


RuneforgeCreateFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

local RuneforgeCreateFrameEvents = {
	"UNIT_INVENTORY_CHANGED",
	"CURRENCY_DISPLAY_UPDATE",
};

function RuneforgeCreateFrameMixin:OnLoad()
	self:UpdateCost();
end

function RuneforgeCreateFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RuneforgeCreateFrameEvents);

	self:RegisterRefreshMethod(self.Refresh);
	self:GetRuneforgeFrame():RegisterCallback(RuneforgeFrameMixin.Event.UpgradeItemChanged, self.Refresh, self);
	self:Refresh();
end

function RuneforgeCreateFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RuneforgeCreateFrameEvents);

	self:UnregisterRefreshMethod();
	self:GetRuneforgeFrame():UnregisterCallback(RuneforgeFrameMixin.Event.UpgradeItemChanged, self);
end

function RuneforgeCreateFrameMixin:OnEvent(event)
	if event == "UNIT_INVENTORY_CHANGED" or event == "CURRENCY_DISPLAY_UPDATE" then
		self:Refresh();
	end
end

function RuneforgeCreateFrameMixin:GetStaticPopupInfo()
	local runeforgeFrame = self:GetRuneforgeFrame();
	local quality = Enum.ItemQuality.Legendary;
	local baseItem, powerID, modifiers = runeforgeFrame:GetLegendaryCraftInfo();
	local itemPreviewInfo = runeforgeFrame:GetItemPreviewInfo(baseItem, powerID, modifiers);
	if self:IsRuneforgeUpgrading() then
		local upgradeItem = runeforgeFrame:GetUpgradeItem();
		local itemLevel = C_Item.GetCurrentItemLevel(upgradeItem);
		return RUNEFORGE_LEGENDARY_UPGRADING_CONFIRMATION, itemPreviewInfo.itemGUID, upgradeItem, quality, itemLevel, itemPreviewInfo.itemName, powerID, modifiers;
	else
		return RUNEFORGE_LEGENDARY_CRAFTING_CONFIRMATION, itemPreviewInfo.itemGUID, baseItem, quality, itemPreviewInfo.itemLevel, itemPreviewInfo.itemName, powerID, modifiers;
	end
end

function RuneforgeCreateFrameMixin:ShowCraftConfirmation()
	local popupTitleFormat, itemGUID, itemLocation, quality, itemLevel, itemName, powerID, modifiers = self:GetStaticPopupInfo();

	local function StaticPopupItemFrameCallback(itemFrame)
		itemFrame:SetItemLocation(itemLocation);
		SetItemButtonQuality(itemFrame, quality);
		itemFrame.Text:SetTextColor(ITEM_QUALITY_COLORS[quality].color:GetRGB());
		itemFrame.Text:SetText(itemName);
		itemFrame.Count:Hide();
	end

	local function StaticPopupItemFrameOnEnterCallback(itemFrame)
		GameTooltip:SetOwner(itemFrame, "ANCHOR_RIGHT");

		if self:IsRuneforgeUpgrading() then
			GameTooltip:SetRuneforgeResultItem(itemGUID, itemLevel);
		else
			GameTooltip:SetRuneforgeResultItem(itemGUID, itemLevel, powerID, modifiers);
		end

		SharedTooltip_SetBackdropStyle(GameTooltip, GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY);
		GameTooltip:Show();
	end

	local currenciesCost = self:GetRuneforgeFrame():GetCost();
	local popupTitle = popupTitleFormat:format(GetCurrenciesString(currenciesCost));

	local data = {
		title = popupTitle,
		itemFrameCallback = StaticPopupItemFrameCallback,
		itemFrameOnEnter = StaticPopupItemFrameOnEnterCallback,
	};

	StaticPopup_Show("CONFIRM_RUNEFORGE_LEGENDARY_CRAFT", nil, nil, data);
end

function RuneforgeCreateFrameMixin:CraftItem()
	local runeforgeFrame = self:GetRuneforgeFrame();
	if self:IsRuneforgeUpgrading() then
		local baseItem = runeforgeFrame:GetItem();
		local upgradeItem = runeforgeFrame:GetUpgradeItem();
		C_LegendaryCrafting.UpgradeRuneforgeLegendary(baseItem, upgradeItem);
		PlaySound(SOUNDKIT.UI_RUNECARVING_UPGRADE_START);
	else
		local craftDescription = runeforgeFrame:GetCraftDescription();
		C_LegendaryCrafting.CraftRuneforgeLegendary(craftDescription);
		PlaySound(SOUNDKIT.UI_RUNECARVING_CREATE_START);
	end
end

function RuneforgeCreateFrameMixin:Refresh()
	local canCraft, errorString = self:GetRuneforgeFrame():CanCraftRuneforgeLegendary();
	self.CraftItemButton:SetCraftState(canCraft, errorString);

	self:UpdateCost();
end


function RuneforgeCreateFrameMixin:UpdateCost()
	local runeforgeFrame = self:GetRuneforgeFrame();
	local currenciesCost = runeforgeFrame:GetCost();
	local showCost = (currenciesCost ~= nil) and (#currenciesCost > 0);
	self.Cost:SetShown(showCost);

	if showCost then
		for i, cost in ipairs(currenciesCost) do
			local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(cost.currencyID);
			if cost.amount > currencyInfo.quantity then
				cost.colorCode = RED_FONT_COLOR_CODE;
			end
		end

		RuneforgeUtil.SetCurrencyCosts(self.Cost.Currencies, currenciesCost);
		self.Cost:MarkDirty();
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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetParent():ShowCraftConfirmation();
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
	GlowEmitterFactory:SetShown(self, canCraft, GlowEmitterMixin.Anims.FaintFadeAnim);
end
