MAX_TRADE_ITEMS = 7;
MAX_TRADABLE_ITEMS = 6;

function TradeFrame_OnLoad()
	this:RegisterEvent("TRADE_CLOSED");
	this:RegisterEvent("TRADE_SHOW");
	this:RegisterEvent("TRADE_UPDATE");
	this:RegisterEvent("TRADE_TARGET_ITEM_CHANGED");
	this:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED");
	this:RegisterEvent("TRADE_ACCEPT_UPDATE");
	this:RegisterEvent("TRADE_MONEY_CHANGED");
end

function TradeFrame_OnShow()
	TradeFrame.acceptState = 0;
	TradeFrame_UpdateMoney();
end

function TradeFrame_OnEvent()
	if ( event == "TRADE_SHOW" or event == "TRADE_UPDATE" ) then
		ShowUIPanel(this, 1);
		if ( not this:IsVisible() ) then
			CloseTrade();
			return;
		end

		TradeFrameTradeButton:Enable();
		TradeFrame_Update();
	elseif ( event == "TRADE_CLOSED" ) then
		HideUIPanel(this);
	elseif ( event == "TRADE_TARGET_ITEM_CHANGED" ) then
		TradeFrame_UpdateTargetItem(arg1);
	elseif ( event == "TRADE_PLAYER_ITEM_CHANGED" ) then
		TradeFrame_UpdatePlayerItem(arg1);
	elseif ( event == "TRADE_ACCEPT_UPDATE" ) then
		TradeFrame_SetAcceptState(arg1, arg2);
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
	local buttonText = getglobal("TradePlayerItem"..id.."Name");
	
	-- See if its the enchant slot
	if ( id == 7 ) then
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
	local tradeItemButton = getglobal("TradePlayerItem"..id.."ItemButton");
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
	local buttonText = getglobal("TradeRecipientItem"..id.."Name");
	-- See if its the enchant slot
	if ( id == 7 ) then
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
	local tradeItemButton = getglobal("TradeRecipientItem"..id.."ItemButton");
	local tradeItem = getglobal("TradeRecipientItem"..id);
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
		TradeFrameTradeButton:Disable();
	else
		TradeHighlightPlayer:Hide();
		TradeHighlightPlayerEnchant:Hide();
		TradeFrameTradeButton:Enable();
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
	if ( copper > GetMoney() ) then
		copper = GetPlayerTradeMoney();
		MoneyInputFrame_SetCopper(TradePlayerInputMoneyFrame, copper);
		--MoneyInputFrame_SetTextColor(TradePlayerInputMoneyFrame, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		TradeFrameTradeButton:Disable();
	else
		--MoneyInputFrame_SetTextColor(TradePlayerInputMoneyFrame, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		TradeFrameTradeButton:Enable();
	end
	SetTradeMoney(copper);
end

function TradeFrame_GetAvailableSlot()
	local tradeItemButton;
	for i=1, MAX_TRADABLE_ITEMS do
		tradeItemButton = getglobal("TradePlayerItem"..i.."ItemButton");
		if ( not tradeItemButton.hasItem ) then
			return i;
		end
	end
	return nil;
end
