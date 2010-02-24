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
		TradeFrame_Update();
	elseif ( event == "TRADE_CLOSED" ) then
		HideUIPanel(self);
		StaticPopup_Hide("TRADE_POTENTIAL_BIND_ENCHANT");
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
	end
end

function TradeFrame_Update()
	SetPortraitTexture(TradeFramePlayerPortrait, "player");
	SetPortraitTexture(TradeFrameRecipientPortrait, "NPC");
	TradeFramePlayerNameText:SetText(UnitName("player"));
	TradeFrameRecipientNameText:SetText(UnitName("NPC"));
	for i=1, MAX_TRADE_ITEMS, 1 do
		TradeFrame_UpdateTargetItem(i);
		TradeFrame_UpdatePlayerItem(i);
	end
	TradeHighlightRecipient:Hide();
	TradeHighlightPlayer:Hide();
	TradeHighlightPlayerEnchant:Hide();
	TradeHighlightRecipientEnchant:Hide();
end

function TradeFrame_UpdatePlayerItem(id)
	local name, texture, numItems, isUsable, enchantment = GetTradePlayerItemInfo(id);
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
	end
	local tradeItemButton = _G["TradePlayerItem"..id.."ItemButton"];
	SetItemButtonTexture(tradeItemButton, texture);
	SetItemButtonCount(tradeItemButton, numItems);
	if ( texture ) then
		tradeItemButton.hasItem = 1;
	else
		tradeItemButton.hasItem = nil;
	end
end

function TradeFrame_UpdateTargetItem(id)
	local name, texture, numItems, quality, isUsable, enchantment = GetTradeTargetItemInfo(id);
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
		AddTradeMoney();
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
	SetTradeMoney(copper);
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

