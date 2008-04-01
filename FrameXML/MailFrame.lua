INBOXITEMS_TO_DISPLAY = 7;
STATIONERY_ICON_ROW_HEIGHT = 36;
STATIONERYITEMS_TO_DISPLAY = 5;
PACKAGEITEMS_TO_DISPLAY = 4;
STATIONERY_PATH = "Interface\\Stationery\\";

function MailFrame_Onload()
	-- Init pagenum
	InboxFrame.pageNum = 1;
	-- Tab Handling code
	PanelTemplates_SetNumTabs(this, 2);
	PanelTemplates_SetTab(this, 1);
	-- Register for events
	this:RegisterEvent("MAIL_SHOW");
	this:RegisterEvent("MAIL_INBOX_UPDATE");
	this:RegisterEvent("MAIL_CLOSED");
	this:RegisterEvent("MAIL_SEND_INFO_UPDATE");
	this:RegisterEvent("MAIL_SEND_SUCCESS");
	this:RegisterEvent("MAIL_FAILED");
	this:RegisterEvent("CLOSE_INBOX_ITEM");
	-- Set previous and next fields
	MoneyInputFrame_SetPreviousFocus(SendMailMoney, SendMailBodyEditBox);
end

function MailFrame_OnEvent()
	if ( event == "MAIL_SHOW" ) then
		ShowUIPanel(MailFrame);
		if ( not MailFrame:IsVisible() ) then
			CloseMail();
			return;
		end

		OpenBackpack();
		SendMailFrame_Update();
		MailFrameTab_OnClick(1);
		CheckInbox();
	elseif ( event == "MAIL_INBOX_UPDATE" ) then
		InboxFrame_Update();
		OpenMail_Update();
	elseif ( event == "MAIL_SEND_INFO_UPDATE" ) then
		SendMailFrame_Update();
	elseif ( event == "MAIL_SEND_SUCCESS" ) then
		SendMailFrame_Reset();
		PlaySound("igAbiliityPageTurn");
		-- If open mail frame is open then switch the mail frame back to the inbox
		if ( SendMailFrame.sendMode == "reply" ) then
			MailFrameTab_OnClick(1);
		end
	elseif ( event == "MAIL_FAILED" ) then
		SendMailMailButton:Enable();
	elseif ( event == "MAIL_CLOSED" ) then
		HideUIPanel(MailFrame);
	elseif ( (event == "CLOSE_INBOX_ITEM") and (InboxFrame.openMailID == arg1) ) then
		HideUIPanel(OpenMailFrame);
	end
end

function MailFrameTab_OnClick(tab)
	if ( not tab ) then
		tab = this:GetID();
	end
	PanelTemplates_SetTab(MailFrame, tab);
	if ( tab == 1 ) then
		-- Inbox tab clicked
		InboxFrame:Show();
		SendMailFrame:Hide();
		MailFrameTopLeft:SetTexture("Interface\\ItemTextFrame\\UI-ItemText-TopLeft");
		MailFrameTopRight:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-TopRight");
		MailFrameBotLeft:SetTexture("Interface\\ItemTextFrame\\UI-ItemText-BotLeft");
		MailFrameBotRight:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotRight");
		MailFrameTopLeft:SetPoint("TOPLEFT", "MailFrame", "TOPLEFT", 0, 0);
	else
		-- Sendmail tab clicked
		InboxFrame:Hide();
		SendMailFrame:Show();
		MailFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
		MailFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
		MailFrameBotLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-BotLeft");
		MailFrameBotRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-BotRight");
		MailFrameTopLeft:SetPoint("TOPLEFT", "MailFrame", "TOPLEFT", 2, -1);
		SendMailFrame_Update();

		-- Set the send mode to dictate the flow after a mail is sent
		SendMailFrame.sendMode = "send";
	end
	PlaySound("igSpellBookOpen");
end

-- Inbox functions

function InboxFrame_Update()
	local numItems = GetInboxNumItems();
	local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1;
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead;
	local icon, button, expireTime, senderText, subjectText, buttonIcon;
	for i=1, INBOXITEMS_TO_DISPLAY do
		if ( index <= numItems ) then
			-- Setup mail item
			packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead = GetInboxHeaderInfo(index);
			
			-- Set icon
			if ( packageIcon ) then
				icon = packageIcon;
			else
				icon = stationeryIcon;
			end
			-- If no sender set it to "Unknown"
			if ( not sender ) then
				sender = UNKNOWN;
			end
			button = getglobal("MailItem"..i.."Button");
			button:Show();
			button.index = index;
			buttonIcon = getglobal("MailItem"..i.."ButtonIcon");
			buttonIcon:SetTexture(icon);
			subjectText = getglobal("MailItem"..i.."Subject");
			subjectText:SetText(subject);
			senderText = getglobal("MailItem"..i.."Sender");
			senderText:SetText(sender);
			
			-- If hasn't been read color the button yellow
			if ( wasRead ) then
				senderText:SetTextColor(0.75, 0.75, 0.75);
				subjectText:SetTextColor(0.75, 0.75, 0.75);
				getglobal("MailItem"..i.."ButtonSlot"):SetVertexColor(0.5, 0.5, 0.5);
				SetDesaturation(buttonIcon, 1);
			else
				senderText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				subjectText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				getglobal("MailItem"..i.."ButtonSlot"):SetVertexColor(1.0, 0.82, 0);
				SetDesaturation(buttonIcon, nil);
			end
			-- Format expiration time
			if ( daysLeft >= 1 ) then
				daysLeft = GREEN_FONT_COLOR_CODE..floor(daysLeft).." "..GetText("DAYS_ABBR", nil, floor(daysLeft)).." "..FONT_COLOR_CODE_CLOSE;
			else
				daysLeft = RED_FONT_COLOR_CODE..SecondsToTime(floor(daysLeft * 24 * 60 * 60))..FONT_COLOR_CODE_CLOSE;
			end
			expireTime = getglobal("MailItem"..i.."ExpireTime");
			expireTime:SetText(daysLeft);
			-- Set expiration time tooltip
			if ( InboxItemCanDelete(index) ) then
				expireTime.tooltip = TIME_UNTIL_DELETED;
			else
				expireTime.tooltip = TIME_UNTIL_RETURNED;
			end
			expireTime:Show();
			-- Is a C.O.D. package
			if ( CODAmount > 0 ) then
				getglobal("MailItem"..i.."ButtonCOD"):Show();
				button.cod = CODAmount;
			else
				getglobal("MailItem"..i.."ButtonCOD"):Hide();
				button.cod = nil;
			end
			-- Contains money
			if ( money > 0 ) then
				button.money = money;
			else
				button.money = nil;
			end
			-- Set highlight
			if ( InboxFrame.openMailID == index ) then
				button:SetChecked(1);
				SetPortraitToTexture("OpenMailFrameIcon", stationeryIcon);
			else
				button:SetChecked(nil);
			end
		else
			-- Clear everything
			getglobal("MailItem"..i.."Button"):Hide();
			getglobal("MailItem"..i.."Sender"):SetText("");
			getglobal("MailItem"..i.."Subject"):SetText("");
			getglobal("MailItem"..i.."ExpireTime"):Hide();
		end
		index = index + 1;
	end

	-- Handle page arrows
	if ( InboxFrame.pageNum == 1 ) then
		InboxPrevPageButton:Disable();
	else
		InboxPrevPageButton:Enable();
	end
	if ( (InboxFrame.pageNum * INBOXITEMS_TO_DISPLAY) < numItems ) then
		InboxNextPageButton:Enable();
	else
		InboxNextPageButton:Disable();
	end
end

function InboxFrame_OnClick(index)
	if ( this:GetChecked() ) then
		InboxFrame.openMailID = index;
		OpenMail_Update();
		--OpenMailFrame:Show();
		ShowUIPanel(OpenMailFrame);
		PlaySound("igSpellBookOpen");
	else
		InboxFrame.openMailID = 0;
		HideUIPanel(OpenMailFrame);		
	end
	InboxFrame_Update();
end

function InboxFrameItem_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	if (this.money) then
		GameTooltip:AddLine(ENCLOSED_MONEY, "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, this.money);
		SetMoneyFrameColor("GameTooltipMoneyFrame", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	elseif (this.cod) then
		GameTooltip:AddLine(COD_AMOUNT, "", 1, 1, 1);
		SetTooltipMoney(GameTooltip, this.cod);
		if ( this.cod > GetMoney() ) then
			SetMoneyFrameColor("GameTooltipMoneyFrame", RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			SetMoneyFrameColor("GameTooltipMoneyFrame", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	end
	GameTooltip:Show();
end

function InboxNextPage()
	PlaySound("igMainMenuOptionCheckBoxOn");
	InboxFrame.pageNum = InboxFrame.pageNum + 1;
	InboxFrame_Update();
end

function InboxPrevPage()
	PlaySound("igMainMenuOptionCheckBoxOn");
	InboxFrame.pageNum = InboxFrame.pageNum - 1;
	InboxFrame_Update();
end

-- Open Mail functions

function OpenMailFrame_OnHide()
	StaticPopup_Hide("DELETE_MAIL");
	if ( not InboxFrame.openMailID ) then
		InboxFrame_Update();
		PlaySound("igSpellBookClose");
		return;
	end
	
	-- If mail contains no items, then delete it on close
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemID, wasRead, wasReturned, textCreated  = GetInboxHeaderInfo(InboxFrame.openMailID);
	if ( money == 0 and not itemID and textCreated ) then
		DeleteInboxItem(InboxFrame.openMailID);
	end
	InboxFrame.openMailID = 0;
	InboxFrame_Update();
	PlaySound("igSpellBookClose");
end

function OpenMail_Update()	
	if ( not InboxFrame.openMailID ) then
		return;
	end
	-- Setup mail item
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(InboxFrame.openMailID);
	-- Set sender and subject
	if ( not sender or not canReply ) then
		OpenMailReplyButton:Disable();
	else
		OpenMailReplyButton:Enable();
	end
	if ( not sender ) then
		sender = UNKNOWN;
	end
	OpenMailSender:SetText(sender);
	OpenMailSubject:SetText(subject);
	-- Set Text
	local bodyText, texture, isTakeable = GetInboxText(InboxFrame.openMailID);
	OpenMailBodyText:SetText(bodyText);
	OpenMailScrollFrame:UpdateScrollChildRect();
	if ( texture ) then
		OpenStationeryBackgroundLeft:SetTexture(STATIONERY_PATH..texture.."1");
		OpenStationeryBackgroundRight:SetTexture(STATIONERY_PATH..texture.."2");
	end
	
	-- Set letter
	if ( isTakeable and not textCreated ) then
		SetItemButtonTexture(OpenMailLetterButton, stationeryIcon);
		OpenMailLetterButton:Enable();
	else
		SetItemButtonTexture(OpenMailLetterButton, "");
		OpenMailLetterButton:Disable();
	end
	
	-- Set Item
	local name, itemTexture, count, quality, canUse = GetInboxItem(InboxFrame.openMailID);
	if ( name ) then
		OpenMailFrame.itemName = name;
		OpenMailPackageButton:Enable();
	else
		OpenMailFrame.itemName = nil;
		OpenMailPackageButton:Disable();
	end
	SetItemButtonTexture(OpenMailPackageButton, itemTexture);
	SetItemButtonCount(OpenMailPackageButton, count);
	if ( canUse ) then
		SetItemButtonTextureVertexColor(OpenMailPackageButton, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		SetItemButtonTextureVertexColor(OpenMailPackageButton, 1.0, 0.1, 0.1);
	end
	-- Set COD
	if ( CODAmount > 0 ) then
		OpenMailFrame.cod = CODAmount;
	else
		OpenMailFrame.cod = nil;
	end
	-- Set Money
	if ( money == 0 ) then
		SetItemButtonTexture(OpenMailMoneyButton, "");
		OpenMailMoneyButton:Disable();
		OpenMailFrame.money = nil;
	else
		SetItemButtonTexture(OpenMailMoneyButton, GetCoinIcon(money));
		OpenMailMoneyButton:Enable();
		OpenMailFrame.money = money;
	end
	-- Set button to delete or return to sender
	if ( InboxItemCanDelete(InboxFrame.openMailID) ) then
		OpenMailDeleteButton:SetText(DELETE);
	else
		OpenMailDeleteButton:SetText(MAIL_RETURN);
	end
end

function OpenMail_Reply()
	MailFrameTab_OnClick(2);
	SendMailNameEditBox:SetText(OpenMailSender:GetText())
	SendMailSubjectEditBox:SetText(MAIL_REPLY_PREFIX.." "..OpenMailSubject:GetText())
	SendMailBodyEditBox:SetFocus();

	-- Set the send mode so the work flow can change accordingly
	SendMailFrame.sendMode = "reply";
end

function OpenMail_Delete()
	if ( InboxItemCanDelete(InboxFrame.openMailID) ) then
		if ( OpenMailFrame.itemName ) then
			StaticPopup_Show("DELETE_MAIL", OpenMailFrame.itemName);
			return;
		elseif ( OpenMailFrame.money ) then
			StaticPopup_Show("DELETE_MONEY");
			return;
		else
			DeleteInboxItem(InboxFrame.openMailID);
		end
	else
		ReturnInboxItem(InboxFrame.openMailID);
	end
	InboxFrame.openMailID = nil;
	HideUIPanel(OpenMailFrame);
end

function OpenMailPackage_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	GameTooltip:SetInboxItem(InboxFrame.openMailID);
	if ( OpenMailFrame.cod ) then
		SetTooltipMoney(GameTooltip, OpenMailFrame.cod);
		if ( OpenMailFrame.cod > GetMoney() ) then
			SetMoneyFrameColor("GameTooltipMoneyFrame", RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			SetMoneyFrameColor("GameTooltipMoneyFrame", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	end
	GameTooltip:Show();
end

-- SendMail functions

function SendMailMailButton_OnClick()
	-- Get the copper value, will break all this out into generic functions in the future
	local copper = MoneyInputFrame_GetCopper(SendMailMoney);
	if ( SendMailSendMoneyButton:GetChecked() ) then
		if ( copper > 0 ) then
			-- Open confirmation dialog
			StaticPopup_Show("SEND_MONEY", SendMailNameEditBox:GetText());
		else
			SendMailFrame_SendMail();
		end
	else
		if ( copper > 0 ) then
			-- Send C.O.D.
			SetSendMailCOD(copper);
			
		end
		SendMailFrame_SendMail();
	end
	this:Disable();
end

function SendMailFrame_SendMail()
	SendMail(SendMailNameEditBox:GetText(), SendMailSubjectEditBox:GetText(), SendMailBodyEditBox:GetText());
end

function SendMailFrame_Update()
	-- Update the item being sent
	local itemName, itemTexture, stackCount, quality = GetSendMailItem();
	SendMailPackageButton:SetNormalTexture(itemTexture);
	if ( stackCount <= 1 ) then
		stackCount = "";
	end
	-- Enable or disable C.O.D. depending on whether or not there's an item to send
	if ( itemName ) then
		SendMailCODButton:Enable();
		SendMailCODButtonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	else
		SendMailRadioButton_OnClick(1);
		SendMailCODButton:Disable();
		SendMailCODButtonText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	SendMailPackageButtonCount:SetText(stackCount);
	-- Color the postage text
	if ( GetSendMailPrice() > GetMoney() ) then
		SetMoneyFrameColor("SendMailCostMoneyFrame", RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	else
		SetMoneyFrameColor("SendMailCostMoneyFrame", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	SendMailFrame_CanSend();
end

function SendMailFrame_Reset()
	SendMailNameEditBox:SetText("");
	SendMailNameEditBox:SetFocus();
	SendMailSubjectEditBox:SetText("");
	SendMailBodyEditBox:SetText("");
	StationeryPopupFrame.selectedIndex = nil;
	SendMailFrame_Update();
	StationeryPopupButton_OnClick(1);
	MoneyInputFrame_ResetMoney(SendMailMoney);
	SendMailRadioButton_OnClick(1);
end

function SendMailFrame_CanSend()
	local checks = 0;
	-- If has stationery
	if ( StationeryPopupFrame.selectedIndex ~= nil ) then
		checks = checks + 1;
	end
	-- and has a sendee
	if ( strlen(SendMailNameEditBox:GetText()) > 0 ) then
		checks = checks + 1;
	end
	-- and has a subject
	if ( strlen(SendMailSubjectEditBox:GetText()) > 0 ) then
		checks = checks + 1;
	end
	if ( checks == 3 ) then
		SendMailMailButton:Enable();
	else
		SendMailMailButton:Disable();
	end
end

function SendMailRadioButton_OnClick(index)
	if ( index == 1 ) then
		SendMailSendMoneyButton:SetChecked(1);
		SendMailCODButton:SetChecked(nil);
		SendMailMoneyText:SetText(AMOUNT_TO_SEND);
	else
		SendMailSendMoneyButton:SetChecked(nil);
		SendMailCODButton:SetChecked(1);
		SendMailMoneyText:SetText(COD_AMOUNT);
	end
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function SendMailFrame_SendeeAutocomplete()
	local text = this:GetText();
	local textlen = strlen(text);
        local numFriends = GetNumFriends();
	local name;
	if ( numFriends > 0 ) then
		for i=1, numFriends do
			name = 	GetFriendInfo(i);
			if ( strfind(strupper(name), "^"..strupper(text)) ) then
				this:SetText(name);
				this:HighlightText(textlen, -1);
				return;
			end
		end
	end
end

-- Stationery functions

function StationeryPopupFrame_Update()
	local numStationeries = GetNumStationeries();
	local index = FauxScrollFrame_GetOffset(StationeryPopupScrollFrame) + 1;
	local name, texture, cost;
	local button;
	for i=1, STATIONERYITEMS_TO_DISPLAY do
		button = getglobal("StationeryPopupButton"..i);
		if ( index <= numStationeries ) then
			name, texture, cost = GetStationeryInfo(index);
			getglobal("StationeryPopupButton"..i.."Name"):SetText(name);
			if ( cost ) then
				MoneyFrame_Update("StationeryPopupButton"..i.."MoneyFrame", cost);
				-- If player can't afford
				if ( cost > GetMoney() ) then
					button:Disable();
					SetMoneyFrameColor("StationeryPopupButton"..i.."MoneyFrame", RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				else
					button:Enable();
					SetMoneyFrameColor("StationeryPopupButton"..i.."MoneyFrame", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				end
			else
				-- Is a stationery in player's inventory or is free
				MoneyFrame_Update("StationeryPopupButton"..i.."MoneyFrame", 0);
			end
			getglobal("StationeryPopupButton"..i.."Icon"):SetTexture(texture);
			button:Show();
		else
			getglobal("StationeryPopupButton"..i.."Name"):SetText("");
			MoneyFrame_Update("StationeryPopupButton"..i.."MoneyFrame", 0);
			getglobal("StationeryPopupButton"..i.."Icon"):SetTexture("");
			button:Hide();
		end
		
		if ( index == StationeryPopupFrame.selectedIndex ) then
			button:SetChecked(1);
		else
			button:SetChecked(nil);
		end
		button.index = index;
		index = index + 1;
	end

	-- Scrollbar stuff
	FauxScrollFrame_Update(StationeryPopupScrollFrame, numStationeries , STATIONERYITEMS_TO_DISPLAY, STATIONERY_ICON_ROW_HEIGHT );
end

function StationeryPopupButton_OnClick(index)
	if ( not index ) then
		index = this.index;
	end
	SelectStationery(index);
	StationeryPopupFrame.selectedIndex = index;
	SendMailFrame_CanSend()
	-- Set the stationery texture
	local texture = GetSelectedStationeryTexture();
	if ( texture ) then
		StationeryBackgroundLeft:SetTexture(STATIONERY_PATH..texture.."1");
		StationeryBackgroundRight:SetTexture(STATIONERY_PATH..texture.."2");
	end
	StationeryPopupFrame_Update();
end

function SendMailPackageButton_OnClick()
	local cursorMoney = GetCursorMoney();
	if ( cursorMoney > 0 ) then
		local money = MoneyInputFrame_GetCopper(SendMailMoney);
		if ( money > 0 ) then
			cursorMoney = cursorMoney + money;
		end
		MoneyInputFrame_SetCopper(SendMailMoney, cursorMoney);
		DropCursorMoney();
	else
		ClickSendMailItemButton();
	end
	
	
end
