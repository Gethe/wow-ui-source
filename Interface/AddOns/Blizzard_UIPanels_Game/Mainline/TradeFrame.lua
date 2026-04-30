MAX_TRADE_ITEMS = 7;
MAX_TRADABLE_ITEMS = 6;
TRADE_ENCHANT_SLOT = MAX_TRADE_ITEMS;

function TradeFrame_OnLoad(self)
	self:RegisterEvent("TRADE_CLOSED");
	self:RegisterEvent("TRADE_SHOW");
	self:RegisterEvent("TRADE_UPDATE");
	self:RegisterEvent("TRADE_TARGET_ITEM_CHANGED");
	self:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED");
	self:RegisterEvent("TRADE_ACCEPT_UPDATE");
	self:RegisterEvent("TRADE_POTENTIAL_BIND_ENCHANT");
	self:RegisterEvent("TRADE_POTENTIAL_REMOVE_TRANSMOG");
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	self:RegisterEvent("TRADE_UPDATE_WARNINGS");
	FrameTemplate_SetAtticHeight(self, 440);
	TradeRecipientItemsInset.Bg:SetAlpha(0.1);
	TradeRecipientMoneyInset.Bg:SetAlpha(0);
	TradeRecipientEnchantInset.Bg:SetAlpha(0.1);
	TradeRecipientMoneyBg:SetAlpha(0.6);
	TradePlayerInputMoneyFrame:SetForbidden();
end

function TradeFrame_OnShow(self)
	self.acceptState = 0;
	TradeFrameTradeButton.enabled = TradeFrameTradeButton:IsEnabled();
	TradeFrame_UpdateMoney();
end

function TradeFrame_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "TRADE_SHOW" or event == "TRADE_UPDATE" ) then
		ShowUIPanel(self, 1);
		if ( not self:IsShown() ) then
			CloseTrade();
			return;
		end

		TradeFrameTradeButton_Enable();
		TradeFrame_Update(self);
	elseif ( event == "GET_ITEM_INFO_RECEIVED" ) then
		TradeFrame_Update(self);
	elseif ( event == "TRADE_CLOSED" ) then
		HideUIPanel(self);
		StaticPopup_Hide("TRADE_POTENTIAL_BIND_ENCHANT");
		StaticPopup_Hide("TRADE_POTENTIAL_REMOVE_TRANSMOG");
	elseif ( event == "TRADE_TARGET_ITEM_CHANGED" ) then
		TradeFrame_UpdateTargetItem(arg1);
	elseif ( event == "TRADE_PLAYER_ITEM_CHANGED" ) then
		TradeFrame_UpdatePlayerItem(arg1);
	elseif ( event == "TRADE_ACCEPT_UPDATE" ) then
		TradeFrame_SetAcceptState(arg1, arg2);
	elseif ( event == "TRADE_POTENTIAL_BIND_ENCHANT" ) then
		-- leaving this commented here so people know how to interpret arg1
		--local canBecomeBound = arg1;
		if ( arg1 ) then
			StaticPopup_Show("TRADE_POTENTIAL_BIND_ENCHANT");
		else
			StaticPopup_Hide("TRADE_POTENTIAL_BIND_ENCHANT");
		end
	elseif ( event == "TRADE_POTENTIAL_REMOVE_TRANSMOG" ) then
		StaticPopup_Show("TRADE_POTENTIAL_REMOVE_TRANSMOG", arg1, nil, arg2);
	elseif ( event == "TRADE_UPDATE_WARNINGS" ) then
		TradeFrame_UpdateWarnings();
	end
end

function TradeFrame_Update(self)
	self:SetPortraitToUnit("player");
	SetPortraitTexture(self.RecipientOverlay.portrait, "NPC");
	TradeFramePlayerNameText:SetText(GetUnitName("player"));
	TradeFrameRecipientNameText:SetText(GetUnitName("NPC"));
	for i=1, MAX_TRADE_ITEMS, 1 do
		TradeFrame_UpdateTargetItem(i);
		TradeFrame_UpdatePlayerItem(i);
	end
	TradeHighlightRecipient:Hide();
	TradeHighlightPlayer:Hide();
	TradeHighlightPlayerEnchant:Hide();
	TradeHighlightRecipientEnchant:Hide();

	TradeFrame_UpdateWarnings();
end

function TradeFrame_UpdateWarnings()
	if (C_TradeInfo.ShouldShowTradeOfferWarning()) then
		local otherPlayer = GetUnitName("NPC") or PLAYER; -- Probably should never hit this fallback case, but adding it just to be safe. Would rather show PLAYER than not show the warning at all.
		TradeFrameTradeButton.warningTooltip = string.format(TRADE_WARNING_CHANGED_OFFER, otherPlayer);
		TradeFrameTradeButton.WarningIcon:Show();
	else
		TradeFrameTradeButton.warningTooltip = nil;
		TradeFrameTradeButton.WarningIcon:Hide();
	end
end

function TradeFrame_UpdatePlayerItem(id)
	local name, texture, numItems, quality, enchantment, canLoseTransmog, isBound, itemID = GetTradePlayerItemInfo(id);
	local buttonText = _G["TradePlayerItem"..id.."Name"];

	-- See if its the enchant slot
	if ( id == TRADE_ENCHANT_SLOT ) then
		if ( name ) then
			if ( enchantment ) then
				buttonText:SetText(GREEN_FONT_COLOR_CODE..enchantment..FONT_COLOR_CODE_CLOSE);
			else
				buttonText:SetText(HIGHLIGHT_FONT_COLOR_CODE..TRADEFRAME_NOT_MODIFIED_TEXT..FONT_COLOR_CODE_CLOSE);
			end
		else
			buttonText:SetText("");
		end
	else
		buttonText:SetText(name);
		if ( quality ) then
			local r, g, b = C_Item.GetItemQualityColor(quality);
			buttonText:SetTextColor(r, g, b);
		else
			buttonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
	end
	local tradeItemButton = _G["TradePlayerItem"..id.."ItemButton"];
	SetItemButtonTexture(tradeItemButton, texture);
	SetItemButtonCount(tradeItemButton, numItems);

	-- If slot is empty, ignore color overrides for it.
	local suppressOverlays = false;
	local ignoreColorOverrides = not texture;
	SetItemButtonQuality(tradeItemButton, quality, GetTradePlayerItemLink(id), suppressOverlays, isBound, ignoreColorOverrides);

	if ( texture ) then
		tradeItemButton.hasItem = 1;
	else
		tradeItemButton.hasItem = nil;
		if ( GameTooltip:IsOwned(tradeItemButton) ) then
			GameTooltip:Hide();
		end
	end
	local _, dialog = StaticPopup_Visible("TRADE_POTENTIAL_REMOVE_TRANSMOG");
	if ( dialog and dialog.data == id and not canLoseTransmog ) then
		StaticPopup_Hide("TRADE_POTENTIAL_REMOVE_TRANSMOG");
	end

	TradeFrame_AlertItemIfChanged(tradeItemButton, itemID, name, numItems, enchantment);
end

function TradeFrame_UpdateTargetItem(id)
	local name, texture, numItems, quality, isUsable, enchantment, itemID = GetTradeTargetItemInfo(id);
	local buttonText = _G["TradeRecipientItem"..id.."Name"];
	-- See if its the enchant slot
	if ( id == TRADE_ENCHANT_SLOT ) then
		if ( name ) then
			if ( enchantment ) then
				buttonText:SetText(GREEN_FONT_COLOR_CODE..enchantment..FONT_COLOR_CODE_CLOSE);
			else
				buttonText:SetText(HIGHLIGHT_FONT_COLOR_CODE..TRADEFRAME_NOT_MODIFIED_TEXT..FONT_COLOR_CODE_CLOSE);
			end
		else
			buttonText:SetText("");
		end
	else
		buttonText:SetText(name);
		local colorData = ColorManager.GetColorDataForItemQuality(quality);
		if colorData then
			buttonText:SetTextColor(colorData.r, colorData.g, colorData.b);
		end
	end
	local tradeItemButton = _G["TradeRecipientItem"..id.."ItemButton"];
	local tradeItem = _G["TradeRecipientItem"..id];
	SetItemButtonTexture(tradeItemButton, texture);
	SetItemButtonCount(tradeItemButton, numItems);
	if ( isUsable or not name ) then
		SetItemButtonTextureVertexColor(tradeItemButton, 1.0, 1.0, 1.0);
		SetItemButtonNameFrameVertexColor(tradeItem, 1.0, 1.0, 1.0);
		SetItemButtonSlotVertexColor(tradeItem, 1.0, 1.0, 1.0);
	else
		SetItemButtonTextureVertexColor(tradeItemButton, 0.9, 0, 0);
		SetItemButtonNameFrameVertexColor(tradeItem, 0.9, 0, 0);
		SetItemButtonSlotVertexColor(tradeItem, 1.0, 0, 0);
	end
	if ( not texture and GameTooltip:IsOwned(tradeItemButton) ) then
		GameTooltip:Hide();
	end

	-- If slot is empty, ignore color overrides for it.
	local suppressOverlays = false;
	local isBound = false;
	local ignoreColorOverrides = not texture;
	SetItemButtonQuality(tradeItemButton, quality, GetTradeTargetItemLink(id), suppressOverlays, isBound, ignoreColorOverrides);

	TradeFrame_AlertItemIfChanged(tradeItemButton, itemID, name, numItems, enchantment);
end

function TradeFrame_AlertItemIfChanged(tradeItemButton, itemID, name, numItems, enchantment)
	-- Play alert if anything about this item slot changed. (We don't alert the first time an item is placed in the slot, though.)
	local alertFrame = tradeItemButton.Alert;
	local oldItemKey = alertFrame.itemKey;
	local newItemKey = { id = itemID, name = name, quantity = numItems, enchantmentID = enchantment };
	if (oldItemKey and not tCompare(oldItemKey, newItemKey)) then
		alertFrame.ItemIconAlertAnim:Restart();
	end
	if (oldItemKey or itemID > 0) then
		-- Update our key to the new item, except in the case where we didn't start with a key (fresh trade) and this isn't actually an item yet.
		alertFrame.itemKey = newItemKey;
	end
end

function TradeFrame_SetAcceptState(playerState, targetState)
	TradeFrame.acceptState = playerState;
	if ( playerState == 1 ) then
		TradeHighlightPlayer:Show();
		TradeHighlightPlayerEnchant:Show();
		TradeFrameTradeButton_Disable();
	else
		TradeHighlightPlayer:Hide();
		TradeHighlightPlayerEnchant:Hide();
		TradeFrameTradeButton_Enable();
	end
	if ( targetState == 1 ) then
		TradeHighlightRecipient:Show();
		TradeHighlightRecipientEnchant:Show();
	else
		TradeHighlightRecipient:Hide();
		TradeHighlightRecipientEnchant:Hide();
	end
end

function TradeFrameCancelButton_OnClick()
	if ( TradeFrame.acceptState == 1 ) then
		CancelTradeAccept();
	else
		HideUIPanel(TradeFrame);
	end
end

function TradeFrame_OnHide()
	CloseTrade();
	MoneyInputFrame_SetCopper(TradePlayerInputMoneyFrame, 0);
end

function TradeFrame_OnMouseUp()
	if ( GetCursorMoney() > 0 ) then
		C_TradeInfo.AddTradeMoney();
	elseif ( CursorHasItem() ) then
		local slot = TradeFrame_GetAvailableSlot();
		if ( slot ) then
			ClickTradeButton(slot);
		end
	else
		MoneyInputFrame_ClearFocus(TradePlayerInputMoneyFrame);
	end
end

function TradeFrame_UpdateMoney()
	local copper = MoneyInputFrame_GetCopper(TradePlayerInputMoneyFrame);
	if ( copper > GetMoney() - GetCursorMoney() ) then
		copper = GetPlayerTradeMoney();
		MoneyInputFrame_SetCopper(TradePlayerInputMoneyFrame, copper);
		--MoneyInputFrame_SetTextColor(TradePlayerInputMoneyFrame, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		TradeFrameTradeButton_Disable();
	else
		--MoneyInputFrame_SetTextColor(TradePlayerInputMoneyFrame, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		TradeFrameTradeButton_Enable();
	end
	C_TradeInfo.SetTradeMoney(copper);
end

function TradeFrame_GetAvailableSlot()
	local tradeItemButton;
	for i=1, MAX_TRADABLE_ITEMS do
		tradeItemButton = _G["TradePlayerItem"..i.."ItemButton"];
		if ( not tradeItemButton.hasItem ) then
			return i;
		end
	end
	return nil;
end

function TradeFrameTradeButton_Enable()
	local self = TradeFrameTradeButton;
	if ( StaticPopup_Visible("TRADE_POTENTIAL_BIND_ENCHANT") ) then
		self.enabled = true;
	else
		self:Enable();
	end
end

function TradeFrameTradeButton_Disable()
	local self = TradeFrameTradeButton;
	if ( StaticPopup_Visible("TRADE_POTENTIAL_BIND_ENCHANT") ) then
		self.enabled = false;
	else
		self:Disable();
	end
end

function TradeFrameTradeButton_SetToEnabledState()
	local self = TradeFrameTradeButton;
	if ( self.enabled ) then
		self:Enable();
	else
		self:Disable();
	end
end

TradeFrameTradeButtonMixin = {};

function TradeFrameTradeButtonMixin:OnLoad()
	self.Text:SetText(TRADE); -- Note: Doing this here so that we can anchor the WarningIcon to self.Text and have it be positioned appropriately.
	self.warningTooltip = nil;
end

function TradeFrameTradeButtonMixin:OnEnter()
	if (self.warningTooltip) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(GameTooltip, self.warningTooltip);
		GameTooltip:Show();
	end
end

TradeItemAlertTemplateMixin = {};

function TradeItemAlertTemplateMixin:OnShow()
	self.itemKey = nil; -- Used to track when this itemSlot changes in a way that should trigger an alert.
end

function TradeItemAlertTemplateMixin:OnHide()
	self.ItemIconAlertAnim:Stop();
end
