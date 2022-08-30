INBOXITEMS_TO_DISPLAY = 7;
PACKAGEITEMS_TO_DISPLAY = 4;
ATTACHMENTS_MAX = 16;
ATTACHMENTS_MAX_SEND = 12;
ATTACHMENTS_PER_ROW_SEND = 7;
ATTACHMENTS_MAX_ROWS_SEND = 2;
ATTACHMENTS_MAX_RECEIVE = 16;
ATTACHMENTS_PER_ROW_RECEIVE = 7;
ATTACHMENTS_MAX_ROWS_RECEIVE = 3;
MAX_COD_AMOUNT = 10000;
SEND_MAIL_TAB_LIST = {};
SEND_MAIL_TAB_LIST[1] = "SendMailNameEditBox";
SEND_MAIL_TAB_LIST[2] = "SendMailSubjectEditBox";
SEND_MAIL_TAB_LIST[3] = "MailEditBox";
SEND_MAIL_TAB_LIST[4] = "SendMailMoneyGold";
SEND_MAIL_TAB_LIST[5] = "SendMailMoneyCopper";

function MailFrame_OnLoad(self)
	-- Init pagenum
	InboxFrame.pageNum = 1;
	-- Tab Handling code
	self.maxTabWidth = self:GetWidth() / 3;
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, 1);
	-- Register for events
	self:RegisterEvent("MAIL_SHOW");
	self:RegisterEvent("MAIL_INBOX_UPDATE");
	self:RegisterEvent("MAIL_CLOSED");
	self:RegisterEvent("MAIL_SEND_INFO_UPDATE");
	self:RegisterEvent("MAIL_SEND_SUCCESS");
	self:RegisterEvent("MAIL_FAILED");
	self:RegisterEvent("MAIL_SUCCESS");	
	self:RegisterEvent("CLOSE_INBOX_ITEM");
	self:RegisterEvent("MAIL_LOCK_SEND_ITEMS");
	self:RegisterEvent("MAIL_UNLOCK_SEND_ITEMS");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	-- Set previous and next fields
	MoneyInputFrame_SetPreviousFocus(SendMailMoney, MailEditBox);
	MoneyInputFrame_SetNextFocus(SendMailMoney, SendMailNameEditBox);
	MoneyFrame_SetMaxDisplayWidth(SendMailMoneyFrame, 160);
	MailFrame_UpdateTrialState(self);
end

function MailFrame_UpdateTrialState(self)
	local isTrialOrVeteran = GameLimitedMode_IsActive();
	MailFrameTab2:SetShown(not isTrialOrVeteran);
	self.trialError:SetShown(isTrialOrVeteran);
end

function MailFrame_OnEvent(self, event, ...)
	if ( event == "MAIL_SHOW" ) then
		ShowUIPanel(MailFrame);
		if ( not MailFrame:IsShown() ) then
			CloseMail();
			return;
		end

		-- Update the roster so auto-completion works
		if ( IsInGuild() and GetNumGuildMembers() == 0 ) then
			C_GuildInfo.GuildRoster();
		end

		OpenAllBags(self);
		SendMailFrame_Update();
		MailFrameTab_OnClick(nil, 1);
		CheckInbox();
		DoEmote("READ", nil, true);
	elseif ( event == "MAIL_INBOX_UPDATE" ) then
		InboxFrame_Update();
		OpenMail_Update();
	elseif ( event == "MAIL_SEND_INFO_UPDATE" ) then
		SendMailFrame_Update();
	elseif ( event == "MAIL_SEND_SUCCESS" ) then
		SendMailFrame_Reset();
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
		-- If open mail frame is open then switch the mail frame back to the inbox
		if ( SendMailFrame.sendMode == "reply" ) then
			MailFrameTab_OnClick(nil, 1);
		end
	elseif ( event == "MAIL_FAILED" ) then
		SendMailMailButton:Enable();
	elseif ( event == "MAIL_SUCCESS" ) then
		SendMailMailButton:Enable();
		if ( InboxNextPageButton:IsEnabled() ) then
			InboxGetMoreMail();
		end
	elseif ( event == "MAIL_CLOSED" ) then
		CancelEmote();
		HideUIPanel(MailFrame);
		CloseAllBags(self);
		SendMailFrameLockSendMail:Hide();
		StaticPopup_Hide("CONFIRM_MAIL_ITEM_UNREFUNDABLE");
	elseif ( event == "CLOSE_INBOX_ITEM" ) then
		local mailID = ...;
		if ( mailID == InboxFrame.openMailID ) then
			HideUIPanel(OpenMailFrame);
		end
	elseif ( event == "MAIL_LOCK_SEND_ITEMS" ) then
		local slotNum, itemLink = ...;
		SendMailFrameLockSendMail:Show();
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink);
		local r, g, b = GetItemQualityColor(itemRarity)
		StaticPopup_Show("CONFIRM_MAIL_ITEM_UNREFUNDABLE", nil, nil, {["texture"] = itemTexture, ["name"] = itemName, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["slot"] = slotNum});
	elseif ( event == "MAIL_UNLOCK_SEND_ITEMS") then
		SendMailFrameLockSendMail:Hide();
		StaticPopup_Hide("CONFIRM_MAIL_ITEM_UNREFUNDABLE");
	elseif ( event == "TRIAL_STATUS_UPDATE" ) then
		MailFrame_UpdateTrialState(self);
	end
end

function MailFrame_OnMouseWheel(self, value)
	if ( value > 0 ) then
		if ( InboxPrevPageButton:IsEnabled() ) then
			InboxPrevPage();
		end
	else
		if ( InboxNextPageButton:IsEnabled() ) then
			InboxNextPage();
		end	
	end
end

function MailFrameTab_OnClick(self, tabID)
	if ( not tabID ) then
		tabID = self:GetID();
	end
	PanelTemplates_SetTab(MailFrame, tabID);
	if ( tabID == 1 ) then
		-- Inbox tab clicked
		ButtonFrameTemplate_HideButtonBar(MailFrame)
		MailFrameInset:SetPoint("TOPLEFT", 4, -58);
		InboxFrame:Show();
		SendMailFrame:Hide();
		SetSendMailShowing(false);
	else
		-- Sendmail tab clicked
		ButtonFrameTemplate_ShowButtonBar(MailFrame)
		MailFrameInset:SetPoint("TOPLEFT", 4, -80);
		InboxFrame:Hide();
		SendMailFrame:Show();
		SendMailFrame_Update();
		SetSendMailShowing(true);

		-- Set the send mode to dictate the flow after a mail is sent
		SendMailFrame.sendMode = "send";
	end
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
end

-- Inbox functions

function InboxFrame_Update()
	local numItems, totalItems = GetInboxNumItems();
	local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1;
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity;
	local icon, button, expireTime, senderText, subjectText, buttonIcon;
	
	if ( totalItems > numItems ) then
		if ( not InboxFrame.maxShownMails ) then
			InboxFrame.maxShownMails = numItems;
		end
		InboxFrame.overflowMails = totalItems - numItems;
		InboxFrame.shownMails = numItems;
	else
		InboxFrame.overflowMails = nil;
	end
	
	for i=1, INBOXITEMS_TO_DISPLAY do
		if ( index <= numItems ) then
			-- Setup mail item
			packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity, firstItemID = GetInboxHeaderInfo(index);
			
			-- Set icon
			if ( packageIcon ) and ( not isGM ) then
				icon = packageIcon;
			else
				icon = stationeryIcon;
			end

			
			-- If no sender set it to "Unknown"
			if ( not sender ) then
				sender = UNKNOWN;
			end
			button = _G["MailItem"..i.."Button"];
			button:Show();
			button.index = index;
			button.hasItem = itemCount;
			button.itemCount = itemCount;
			SetItemButtonCount(button, firstItemQuantity);
			if ( firstItemQuantity ) then
				SetItemButtonQuality(button, select(3, GetItemInfo(firstItemID)), firstItemID);
			else
				button.IconBorder:Hide();
				button.IconOverlay:Hide();
			end
			
			buttonIcon = _G["MailItem"..i.."ButtonIcon"];
			buttonIcon:SetTexture(icon);
			subjectText = _G["MailItem"..i.."Subject"];
			subjectText:SetText(subject);
			senderText = _G["MailItem"..i.."Sender"];
			senderText:SetText(sender);
			
			-- If hasn't been read color the button yellow
			if ( wasRead ) then
				senderText:SetTextColor(0.75, 0.75, 0.75);
				subjectText:SetTextColor(0.75, 0.75, 0.75);
				_G["MailItem"..i.."ButtonSlot"]:SetVertexColor(0.5, 0.5, 0.5);
				SetDesaturation(buttonIcon, true);
				button.IconBorder:SetVertexColor(0.5, 0.5, 0.5);
			else
				senderText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				subjectText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				_G["MailItem"..i.."ButtonSlot"]:SetVertexColor(1.0, 0.82, 0);
				SetDesaturation(buttonIcon, false);
			end
			-- Format expiration time
			if ( daysLeft >= 1 ) then
				daysLeft = GREEN_FONT_COLOR_CODE..format(DAYS_ABBR, floor(daysLeft)).." "..FONT_COLOR_CODE_CLOSE;
			else
				daysLeft = RED_FONT_COLOR_CODE..SecondsToTime(floor(daysLeft * 24 * 60 * 60))..FONT_COLOR_CODE_CLOSE;
			end
			expireTime = _G["MailItem"..i.."ExpireTime"];
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
				_G["MailItem"..i.."ButtonCOD"]:Show();
				_G["MailItem"..i.."ButtonCODBackground"]:Show();
				button.cod = CODAmount;
			else
				_G["MailItem"..i.."ButtonCOD"]:Hide();
				_G["MailItem"..i.."ButtonCODBackground"]:Hide();
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
				button:SetChecked(true);
				SetPortraitToTexture("OpenMailFrameIcon", stationeryIcon);
			else
				button:SetChecked(false);
			end
		else
			-- Clear everything
			_G["MailItem"..i.."Button"]:Hide();
			_G["MailItem"..i.."Sender"]:SetText("");
			_G["MailItem"..i.."Subject"]:SetText("");
			_G["MailItem"..i.."ExpireTime"]:Hide();
			MoneyInputFrame_ResetMoney(SendMailMoney);
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
	if ( totalItems > numItems) then
		InboxTooMuchMail:Show();
	else
		InboxTooMuchMail:Hide();
	end
end

function InboxFrame_OnClick(self, index)
	if ( self:GetChecked() ) then
		InboxFrame.openMailID = index;
		OpenMailFrame.updateButtonPositions = true;
		OpenMail_Update();
		--OpenMailFrame:Show();
		ShowUIPanel(OpenMailFrame);
		OpenMailFrameInset:SetPoint("TOPLEFT", 4, -80);
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
	else
		InboxFrame.openMailID = 0;
		HideUIPanel(OpenMailFrame);		
	end
	InboxFrame_Update();
end

function InboxFrame_OnModifiedClick(self, index)
	local _, _, _, _, _, cod = GetInboxHeaderInfo(index);
	if ( cod <= 0 ) then
		AutoLootMailItem(index);
	end
	InboxFrame_OnClick(self, index);
end

function InboxFrameItem_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( self.hasItem ) then
		if ( self.itemCount == 1) then
			local hasCooldown, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetInboxItem(self.index);
			if(speciesID and speciesID > 0) then
				BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
			end
		else
			GameTooltip:AddLine(MAIL_MULTIPLE_ITEMS.." ("..self.itemCount..")");
		end
	end
	if (self.money) then
		if ( self.hasItem ) then
			GameTooltip:AddLine(" ");
		end
		GameTooltip:AddLine(ENCLOSED_MONEY, nil, nil, nil, true);
		SetTooltipMoney(GameTooltip, self.money);
		SetMoneyFrameColor("GameTooltipMoneyFrame1", "white");
	elseif (self.cod) then
		if ( self.hasItem ) then
			GameTooltip:AddLine(" ");
		end
		GameTooltip:AddLine(COD_AMOUNT, nil, nil, nil, true);
		SetTooltipMoney(GameTooltip, self.cod);
		if ( self.cod > GetMoney() ) then
			SetMoneyFrameColor("GameTooltipMoneyFrame1", "red");
		else
			SetMoneyFrameColor("GameTooltipMoneyFrame1", "white");
		end
	end
	GameTooltip:Show();
end

function InboxNextPage()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	InboxFrame.pageNum = InboxFrame.pageNum + 1;
	InboxGetMoreMail();	
	InboxFrame_Update();
end

function InboxPrevPage()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	InboxFrame.pageNum = InboxFrame.pageNum - 1;
	InboxGetMoreMail();	
	InboxFrame_Update();
end

function InboxGetMoreMail()
	-- get more mails if there is an overflow and less than max are being shown
	if ( InboxFrame.overflowMails and InboxFrame.shownMails < InboxFrame.maxShownMails ) then
		CheckInbox();
	end
end

-- Open Mail functions

function OpenMailFrame_OnHide()
	StaticPopup_Hide("DELETE_MAIL");
	if ( not InboxFrame.openMailID ) then
		InboxFrame_Update();
		PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE);
		return;
	end

	-- Determine if this is an auction temp invoice
	local isInvoice = select(5, GetInboxText(InboxFrame.openMailID));
	local isAuctionTempInvoice = false;
	if ( isInvoice ) then
		local invoiceType, itemName, playerName, bid, buyout, deposit, consignment, moneyDelay, etaHour, etaMin = GetInboxInvoiceInfo(InboxFrame.openMailID);
		if (invoiceType == "seller_temp_invoice") then
			isAuctionTempInvoice = true;
		end
	end
	
	-- If mail contains no items, then delete it on close
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, wasReturned, textCreated  = GetInboxHeaderInfo(InboxFrame.openMailID);
	if ( money == 0 and not itemCount and textCreated and not isAuctionTempInvoice ) then
		DeleteInboxItem(InboxFrame.openMailID);
	end
	InboxFrame.openMailID = 0;
	InboxFrame_Update();
	PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE);
end

function OpenMailFrame_UpdateButtonPositions(letterIsTakeable, textCreated, stationeryIcon, money)
	if ( OpenMailFrame.activeAttachmentButtons ) then
		while (#OpenMailFrame.activeAttachmentButtons > 0) do
			tremove(OpenMailFrame.activeAttachmentButtons);
		end
	else
		OpenMailFrame.activeAttachmentButtons = {};
	end
	if ( OpenMailFrame.activeAttachmentRowPositions ) then
		while (#OpenMailFrame.activeAttachmentRowPositions  > 0) do
			tremove(OpenMailFrame.activeAttachmentRowPositions );
		end
	else
		OpenMailFrame.activeAttachmentRowPositions = {};
	end

	local rowAttachmentCount = 0;

	-- letter
	if ( letterIsTakeable and not textCreated ) then
		SetItemButtonTexture(OpenMailLetterButton, stationeryIcon);
		tinsert(OpenMailFrame.activeAttachmentButtons, OpenMailLetterButton);
		rowAttachmentCount = rowAttachmentCount + 1;
	else
		SetItemButtonTexture(OpenMailLetterButton, "");
	end
	-- money
	if ( money == 0 ) then
		SetItemButtonTexture(OpenMailMoneyButton, "");
	else
		SetItemButtonTexture(OpenMailMoneyButton, GetCoinIcon(money));
		tinsert(OpenMailFrame.activeAttachmentButtons, OpenMailMoneyButton);
		rowAttachmentCount = rowAttachmentCount + 1;
	end
	-- items
	for i=1, ATTACHMENTS_MAX_RECEIVE do
		local attachmentButton = OpenMailFrame.OpenMailAttachments[i];
		if HasInboxItem(InboxFrame.openMailID, i) then
			tinsert(OpenMailFrame.activeAttachmentButtons, attachmentButton);
			rowAttachmentCount = rowAttachmentCount + 1;

			local name, itemID, itemTexture, count, quality, canUse = GetInboxItem(InboxFrame.openMailID, i);
			if name then
				attachmentButton.name = name;
				SetItemButtonTexture(attachmentButton, itemTexture);
				SetItemButtonCount(attachmentButton, count);
				SetItemButtonQuality(attachmentButton, quality, itemID);
			else
				attachmentButton.name = nil;
				SetItemButtonTexture(attachmentButton, "Interface/Icons/INV_Misc_QuestionMark");
				SetItemButtonCount(attachmentButton, 0);
				SetItemButtonQuality(attachmentButton, nil);
			end

			if canUse then
				SetItemButtonTextureVertexColor(attachmentButton, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			else
				SetItemButtonTextureVertexColor(attachmentButton, 1.0, 0.1, 0.1);
			end
		else
			attachmentButton:Hide();
		end

		if ( rowAttachmentCount >= ATTACHMENTS_PER_ROW_RECEIVE ) then
			tinsert(OpenMailFrame.activeAttachmentRowPositions, {cursorxstart=0,cursorxend=ATTACHMENTS_PER_ROW_RECEIVE - 1});
			rowAttachmentCount = 0;
		end
	end
	-- insert last row's position data
	if ( rowAttachmentCount > 0 ) then
		local xstart = (ATTACHMENTS_PER_ROW_RECEIVE - rowAttachmentCount) / 2;
		local xend = xstart + rowAttachmentCount - 1;
		tinsert(OpenMailFrame.activeAttachmentRowPositions, {cursorxstart=xstart,cursorxend=xend});
	end

	-- hide unusable attachment buttons
	for i=ATTACHMENTS_MAX_RECEIVE + 1, ATTACHMENTS_MAX do
		_G["OpenMailAttachmentButton"..i]:Hide();
	end
end

function OpenMail_Update()
	if ( not InboxFrame.openMailID ) then
		return;
	end
	if ( CanComplainInboxItem(InboxFrame.openMailID) ) then
		OpenMailReportSpamButton:Enable();
		OpenMailReportSpamButton:Show();
		OpenMailSender:SetPoint("BOTTOMRIGHT", OpenMailReportSpamButton, "BOTTOMLEFT" , -5, 0);
	else
		OpenMailReportSpamButton:Hide();
		OpenMailSender:SetPoint("BOTTOMRIGHT", OpenMailFrame, "TOPRIGHT" , -12, -54);
	end

	-- Setup mail item
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(InboxFrame.openMailID);
	-- Set sender and subject
	if ( not sender or not canReply or sender == UnitName("player") ) then
		OpenMailReplyButton:Disable();
	else
		OpenMailReplyButton:Enable();
	end
	if ( not sender ) then
		sender = UNKNOWN;
	end
	-- Save sender name to pass to a potential spam report
	InboxFrame.openMailSender = sender;
	OpenMailSender.Name:SetText(sender);
	OpenMailSubject:SetText(subject);
	-- Set Text
	local bodyText, stationeryID1, stationeryID2, isTakeable, isInvoice = GetInboxText(InboxFrame.openMailID);
	OpenMailBodyText:SetText(bodyText, true);
	if ( stationeryID1 and stationeryID2 ) then
		OpenStationeryBackgroundLeft:SetTexture(stationeryID1);
		OpenStationeryBackgroundRight:SetTexture(stationeryID2);
	end

	-- Is an invoice
	if ( isInvoice ) then
		local invoiceType, itemName, playerName, bid, buyout, deposit, consignment, moneyDelay, etaHour, etaMin, count, commerceAuction = GetInboxInvoiceInfo(InboxFrame.openMailID);
		if ( playerName ) then
			-- Setup based on whether player is the buyer or the seller
			local buyMode;
			if ( count and count > 1 ) then
				itemName = format(AUCTION_MAIL_ITEM_STACK, itemName, count);
			end
			OpenMailInvoicePurchaser:SetShown(not commerceAuction);
			OpenMailInvoiceBuyMode:SetShown(not commerceAuction);
			if ( invoiceType == "buyer" ) then
				if ( bid == buyout ) then
					buyMode = "("..BUYOUT..")";
				else
					buyMode = "("..HIGH_BIDDER..")";
				end
				OpenMailInvoiceItemLabel:SetText(ITEM_PURCHASED_COLON.." "..itemName.."  "..buyMode);
				OpenMailInvoicePurchaser:SetText(SOLD_BY_COLON.." "..playerName);
				OpenMailInvoiceAmountReceived:SetText(AMOUNT_PAID_COLON);
				-- Clear buymode
				OpenMailInvoiceBuyMode:SetText("");
				-- Position amount paid
				OpenMailInvoiceAmountReceived:SetPoint("TOPRIGHT", "OpenMailInvoiceSalePrice", "TOPRIGHT", 0, 0);
				-- Update purchase price
				MoneyFrame_Update("OpenMailTransactionAmountMoneyFrame", bid);	
				-- Position buy line
				OpenMailArithmeticLine:SetPoint("TOP", "OpenMailInvoicePurchaser", "BOTTOMLEFT", 125, 0);
				-- Not used for a purchase invoice
				OpenMailInvoiceSalePrice:Hide();
				OpenMailInvoiceDeposit:Hide();
				OpenMailInvoiceHouseCut:Hide();
				OpenMailDepositMoneyFrame:Hide();
				OpenMailHouseCutMoneyFrame:Hide();
				OpenMailSalePriceMoneyFrame:Hide();
				OpenMailInvoiceNotYetSent:Hide();
				OpenMailInvoiceMoneyDelay:Hide();
			elseif (invoiceType == "seller") then
				OpenMailInvoiceItemLabel:SetText(ITEM_SOLD_COLON.." "..itemName);
				OpenMailInvoicePurchaser:SetText(PURCHASED_BY_COLON.." "..playerName);
				OpenMailInvoiceAmountReceived:SetText(AMOUNT_RECEIVED_COLON);
				-- Determine if auction was bought out or bid on
				if ( bid == buyout ) then
					OpenMailInvoiceBuyMode:SetText("("..BUYOUT..")");
				else
					OpenMailInvoiceBuyMode:SetText("("..HIGH_BIDDER..")");
				end
				-- Position amount received
				OpenMailInvoiceAmountReceived:SetPoint("TOPRIGHT", "OpenMailInvoiceHouseCut", "BOTTOMRIGHT", 0, -18);
				-- Position buy line
				OpenMailArithmeticLine:SetPoint("TOP", "OpenMailInvoiceHouseCut", "BOTTOMRIGHT", 0, 9);
				MoneyFrame_Update("OpenMailSalePriceMoneyFrame", bid);
				MoneyFrame_Update("OpenMailDepositMoneyFrame", deposit);
				MoneyFrame_Update("OpenMailHouseCutMoneyFrame", consignment);
				SetMoneyFrameColor("OpenMailHouseCutMoneyFrame", "red");
				MoneyFrame_Update("OpenMailTransactionAmountMoneyFrame", bid+deposit-consignment);

				-- Show these guys if the player was the seller
				OpenMailInvoiceSalePrice:Show();
				OpenMailInvoiceDeposit:Show();
				OpenMailInvoiceHouseCut:Show();
				OpenMailDepositMoneyFrame:Show();
				OpenMailHouseCutMoneyFrame:Show();
				OpenMailSalePriceMoneyFrame:Show();
				OpenMailInvoiceNotYetSent:Hide();
				OpenMailInvoiceMoneyDelay:Hide();
			elseif (invoiceType == "seller_temp_invoice") then
				if ( bid == buyout ) then
					buyMode = "("..BUYOUT..")";
				else
					buyMode = "("..HIGH_BIDDER..")";
				end
				OpenMailInvoiceItemLabel:SetText(ITEM_SOLD_COLON.." "..itemName.."  "..buyMode);
				OpenMailInvoicePurchaser:SetText(PURCHASED_BY_COLON.." "..playerName);
				OpenMailInvoiceAmountReceived:SetText(AUCTION_INVOICE_PENDING_FUNDS_COLON);
				-- Clear buymode
				OpenMailInvoiceBuyMode:SetText("");
				-- Position amount paid
				OpenMailInvoiceAmountReceived:SetPoint("TOPRIGHT", "OpenMailInvoiceSalePrice", "TOPRIGHT", 0, 0);
				-- Update purchase price
				MoneyFrame_Update("OpenMailTransactionAmountMoneyFrame", bid+deposit-consignment);	
				-- Position buy line
				OpenMailArithmeticLine:SetPoint("TOP", "OpenMailInvoicePurchaser", "BOTTOMLEFT", 125, 0);
				-- How long they have to wait to get the money
				OpenMailInvoiceMoneyDelay:SetFormattedText(AUCTION_INVOICE_FUNDS_DELAY, "12:22");
				-- Not used for a temp sale invoice
				OpenMailInvoiceSalePrice:Hide();
				OpenMailInvoiceDeposit:Hide();
				OpenMailInvoiceHouseCut:Hide();
				OpenMailDepositMoneyFrame:Hide();
				OpenMailHouseCutMoneyFrame:Hide();
				OpenMailSalePriceMoneyFrame:Hide();
				OpenMailInvoiceNotYetSent:Show();
				OpenMailInvoiceMoneyDelay:Show();
			end
			OpenMailInvoiceFrame:Show();
		end
	else
		OpenMailInvoiceFrame:Hide();
	end

	local itemButtonCount, itemRowCount = OpenMail_GetItemCounts(isTakeable, textCreated, money);
	if ( OpenMailFrame.updateButtonPositions ) then
		OpenMailFrame_UpdateButtonPositions(isTakeable, textCreated, stationeryIcon, money);
	end
	if ( OpenMailFrame.activeAttachmentRowPositions ) then
		itemRowCount = #OpenMailFrame.activeAttachmentRowPositions;
	end

	-- record the original number of buttons that the mail needs
	OpenMailFrame.itemButtonCount = itemButtonCount;

	-- Determine starting position for buttons
	local marginxl = 10 + 4;
	local marginxr = 43 + 4;
	local areax = OpenMailFrame:GetWidth() - marginxl - marginxr;
	local iconx = OpenMailAttachmentButton1:GetWidth() + 2;
	local icony = OpenMailAttachmentButton1:GetHeight() + 2;
	local gapx1 = floor((areax - (iconx * ATTACHMENTS_PER_ROW_RECEIVE)) / (ATTACHMENTS_PER_ROW_RECEIVE - 1));
	local gapx2 = floor((areax - (iconx * ATTACHMENTS_PER_ROW_RECEIVE) - (gapx1 * (ATTACHMENTS_PER_ROW_RECEIVE - 1))) / 2);
	local gapy1 = 3;
	local gapy2 = 3;
	local areay = gapy2 + OpenMailAttachmentText:GetHeight() + gapy2 + (icony * itemRowCount) + (gapy1 * (itemRowCount - 1)) + gapy2;
	local indentx = marginxl + gapx2;
	local indenty = 28 + gapy2;
	local tabx = (iconx + gapx1) + 6; --this magic number changes the button spacing
	local taby = (icony + gapy1);
	local scrollHeight = 305 - areay;
	if (scrollHeight > 256) then
		scrollHeight = 256;
		areay = 305 - scrollHeight;
	end

	-- Resize the scroll frame
	OpenMailScrollFrame:SetHeight(scrollHeight);
	OpenMailScrollChildFrame:SetHeight(scrollHeight);
	OpenMailHorizontalBarLeft:SetPoint("TOPLEFT", "OpenMailFrame", "BOTTOMLEFT", 2, 39 + areay);
	OpenScrollBarBackgroundTop:SetHeight(min(scrollHeight, 256));
	OpenScrollBarBackgroundTop:SetTexCoord(0, 0.484375, 0, min(scrollHeight, 256) / 256);
	OpenStationeryBackgroundLeft:SetHeight(scrollHeight);
	OpenStationeryBackgroundLeft:SetTexCoord(0, 1.0, 0, min(scrollHeight, 256) / 256);
	OpenStationeryBackgroundRight:SetHeight(scrollHeight);
	OpenStationeryBackgroundRight:SetTexCoord(0, 1.0, 0, min(scrollHeight, 256) / 256);

	-- Set attachment text
	if ( itemButtonCount > 0 ) then
		OpenMailAttachmentText:SetText(TAKE_ATTACHMENTS);
		OpenMailAttachmentText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		OpenMailAttachmentText:SetPoint("TOPLEFT", "OpenMailFrame", "BOTTOMLEFT", indentx, indenty + (icony * itemRowCount) + (gapy1 * (itemRowCount - 1)) + gapy2 + OpenMailAttachmentText:GetHeight());
	else
		OpenMailAttachmentText:SetText(NO_ATTACHMENTS);
		OpenMailAttachmentText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		OpenMailAttachmentText:SetPoint("TOPLEFT", "OpenMailFrame", "BOTTOMLEFT", marginxl + (areax - OpenMailAttachmentText:GetWidth()) / 2, indenty + (areay - OpenMailAttachmentText:GetHeight()) / 2 + OpenMailAttachmentText:GetHeight());
	end
	-- Set letter
	if ( isTakeable and not textCreated ) then
		OpenMailLetterButton:Show();
	else
		OpenMailLetterButton:Hide();
	end
	-- Set Money
	if ( money == 0 ) then
		OpenMailMoneyButton:Hide();
		OpenMailFrame.money = nil;
	else
		OpenMailMoneyButton:Show();
		OpenMailFrame.money = money;
	end
	-- Set Items
	if ( itemRowCount > 0 and OpenMailFrame.activeAttachmentButtons ) then
		local firstAttachName;
		local rowIndex = 1;
		local cursorx = OpenMailFrame.activeAttachmentRowPositions[1].cursorxstart;
		local cursorxend = OpenMailFrame.activeAttachmentRowPositions[1].cursorxend;
		local cursory = itemRowCount - 1;
		for i, attachmentButton in ipairs(OpenMailFrame.activeAttachmentButtons) do
			attachmentButton:SetPoint("TOPLEFT", OpenMailFrame, "BOTTOMLEFT", indentx + (tabx * cursorx), indenty + icony + (taby * cursory));
			if attachmentButton ~= OpenMailLetterButton and attachmentButton ~= OpenMailMoneyButton then
				if cursory >= 0 and HasInboxItem(InboxFrame.openMailID, attachmentButton:GetID()) then
					if attachmentButton.name then
						if not firstAttachName then
							firstAttachName = attachmentButton.name;
						end
					end

					attachmentButton:Enable();
					attachmentButton:Show();
				else
					attachmentButton:Hide();
				end
			end

			cursorx = cursorx + 1;
			if (cursorx > cursorxend) then
				rowIndex = rowIndex + 1;

				cursory = cursory - 1;
				if ( rowIndex <= itemRowCount ) then
					cursorx = OpenMailFrame.activeAttachmentRowPositions[rowIndex].cursorxstart;
					cursorxend = OpenMailFrame.activeAttachmentRowPositions[rowIndex].cursorxend;
				end
			end
		end

		OpenMailFrame.itemName = firstAttachName;
	else
		OpenMailFrame.itemName = nil;
	end

	-- Set COD
	if ( CODAmount > 0 ) then
		OpenMailFrame.cod = CODAmount;
	else
		OpenMailFrame.cod = nil;
	end
	-- Set button to delete or return to sender
	if ( InboxItemCanDelete(InboxFrame.openMailID) ) then
		OpenMailDeleteButton:SetText(DELETE);
	else
		OpenMailDeleteButton:SetText(MAIL_RETURN);
	end
end

function OpenMail_GetItemCounts(letterIsTakeable, textCreated, money)
	local itemButtonCount = 0;
	local itemRowCount = 0;
	local numRows = 0;
	if ( letterIsTakeable and not textCreated ) then
		itemButtonCount = itemButtonCount + 1;
		itemRowCount = itemRowCount + 1;
	end
	if ( money ~= 0 ) then
		itemButtonCount = itemButtonCount + 1;
		itemRowCount = itemRowCount + 1;
	end
	for i=1, ATTACHMENTS_MAX_RECEIVE do
		if HasInboxItem(InboxFrame.openMailID, i) then
			itemButtonCount = itemButtonCount + 1;
			itemRowCount = itemRowCount + 1;
		end

		if ( itemRowCount >= ATTACHMENTS_PER_ROW_RECEIVE ) then
			numRows = numRows + 1;
			itemRowCount = 0;
		end
	end
	if ( itemRowCount > 0 ) then
		numRows = numRows + 1;
	end
	return itemButtonCount, numRows;
end

function OpenMail_Reply()
	MailFrameTab_OnClick(nil, 2);
	SendMailNameEditBox:SetText(OpenMailSender.Name:GetText())
	local subject = OpenMailSubject:GetText();
	local prefix = MAIL_REPLY_PREFIX.." ";
	if ( strsub(subject, 1, strlen(prefix)) ~= prefix ) then
		subject = prefix..subject;
	end
	SendMailSubjectEditBox:SetText(subject)
	MailEditBox:GetEditBox():SetFocus();

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
		StaticPopup_Hide("COD_CONFIRMATION");
	end
	InboxFrame.openMailID = nil;
	HideUIPanel(OpenMailFrame);
end

function OpenMail_ReportSpam()
	local reportInfo = ReportInfo:CreateMailReportInfo(Enum.ReportType.Mail, InboxFrame.openMailID);
	if(reportInfo) then 
		ReportFrame:InitiateReport(reportInfo, InboxFrame.openMailSender); 
	end		
	OpenMailReportSpamButton:Disable();
end


function OpenMailAttachment_OnEnter(self, index)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local hasCooldown, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetInboxItem(InboxFrame.openMailID, index);
	if(speciesID and speciesID > 0) then
		BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
	end

	if ( OpenMailFrame.cod ) then
		SetTooltipMoney(GameTooltip, OpenMailFrame.cod);
		if ( OpenMailFrame.cod > GetMoney() ) then
			SetMoneyFrameColor("GameTooltipMoneyFrame1", "red");
		else
			SetMoneyFrameColor("GameTooltipMoneyFrame1", "white");
		end
	end
	GameTooltip:Show();
end

function OpenMailAttachment_OnClick(self, index)
	if ( OpenMailFrame.cod and (OpenMailFrame.cod > GetMoney()) ) then
		StaticPopup_Show("COD_ALERT");
	elseif ( OpenMailFrame.cod ) then
		OpenMailFrame.lastTakeAttachment = index;
		StaticPopup_Show("COD_CONFIRMATION");
		OpenMailFrame.updateButtonPositions = false;
	else
		TakeInboxItem(InboxFrame.openMailID, index);
		OpenMailFrame.updateButtonPositions = false;
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

-- SendMail functions

function SendMailMailButton_OnClick(self)
	self:Disable();
	local copper = MoneyInputFrame_GetCopper(SendMailMoney);
	SetSendMailCOD(0);
	SetSendMailMoney(0);
	if ( SendMailSendMoneyButton:GetChecked() ) then
		-- Send Money
		if ( copper > 0 ) then
			-- Confirmation is now done through the secure transfer system
			SetSendMailMoney(copper)
		end
	else
		-- Send C.O.D.
		if ( copper > 0 ) then
			SetSendMailCOD(copper);
		end
	end
	SendMailFrame_SendMail();
end

function SendMailFrame_SendMail()
	SendMail(SendMailNameEditBox:GetText(), SendMailSubjectEditBox:GetText(), MailEditBox:GetInputText());
end

function SendMailFrame_EnableSendMailButton()
	SendMailMailButton:Enable();
end

function SendMailFrame_Update()
	-- Update the item(s) being sent
	local itemCount = 0;
	local itemTitle;
	local gap = false;
	local last = 0;
	for i=1, ATTACHMENTS_MAX_SEND do
		local sendMailAttachmentButton = SendMailFrame.SendMailAttachments[i];

		if HasSendMailItem(i) then
			itemCount = itemCount + 1;

			local itemName, itemID, itemTexture, stackCount, quality = GetSendMailItem(i);
			sendMailAttachmentButton:SetNormalTexture(itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark");
			SetItemButtonCount(sendMailAttachmentButton, stackCount or 0);
			SetItemButtonQuality(sendMailAttachmentButton, quality, itemID);
		
			-- determine what a name for the message in case it doesn't already have one
			if not itemTitle and itemName then
				if stackCount <= 1 then
					itemTitle = itemName;
				else
					itemTitle = itemName.." ("..stackCount..")";
				end
			end

			if last + 1 ~= i then
				gap = true;
			end
			last = i;
		else
			sendMailAttachmentButton:SetNormalTexture(nil);
			SetItemButtonCount(sendMailAttachmentButton, 0);
			SetItemButtonQuality(sendMailAttachmentButton, nil);
		end
	end

	-- Enable or disable C.O.D. depending on whether or not there's an item to send
	if ( itemCount > 0 ) then
		SendMailCODButton:Enable();
		SendMailCODButtonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);

		if SendMailSubjectEditBox:GetText() == "" or SendMailSubjectEditBox:GetText() == SendMailFrame.previousItem then
			itemTitle = itemTitle or "";
			SendMailSubjectEditBox:SetText(itemTitle);
			SendMailFrame.previousItem = itemTitle;
		end
	else
		-- If no itemname see if the subject is the name of the previously held item, if so clear the subject
		if ( SendMailSubjectEditBox:GetText() == SendMailFrame.previousItem ) then
			SendMailSubjectEditBox:SetText("");	
		end
		SendMailFrame.previousItem = "";

		SendMailRadioButton_OnClick(1);
		SendMailCODButton:Disable();
		SendMailCODButtonText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	-- Update the cost
	MoneyFrame_Update("SendMailCostMoneyFrame", GetSendMailPrice());	
	
	-- Color the postage text
	if ( GetSendMailPrice() > GetMoney() ) then
		SetMoneyFrameColor("SendMailCostMoneyFrame", "red");
	else
		SetMoneyFrameColor("SendMailCostMoneyFrame", "white");
	end

	-- Determine how many rows of attachments to show
	local itemRowCount = 1;
	local temp = last;
	while ((temp > ATTACHMENTS_PER_ROW_SEND) and (itemRowCount < ATTACHMENTS_MAX_ROWS_SEND)) do
		itemRowCount = itemRowCount + 1;
		temp = temp - ATTACHMENTS_PER_ROW_SEND;
	end
	if (not gap and (temp == ATTACHMENTS_PER_ROW_SEND) and (itemRowCount < ATTACHMENTS_MAX_ROWS_SEND)) then
		itemRowCount = itemRowCount + 1;
	end
	if (SendMailFrame.maxRowsShown and (last > 0) and (itemRowCount < SendMailFrame.maxRowsShown)) then
		itemRowCount = SendMailFrame.maxRowsShown;
	else
		SendMailFrame.maxRowsShown = itemRowCount;
	end

	-- Compute sizes
	local cursorx = 0;
	local cursory = itemRowCount - 1;
	local marginxl = 8 + 6;
	local marginxr = 40 + 6;
	local areax = SendMailFrame:GetWidth() - marginxl - marginxr;
	local iconx = SendMailAttachment1:GetWidth() + 2;
	local icony = SendMailAttachment1:GetHeight() + 2;
	local gapx1 = floor((areax - (iconx * ATTACHMENTS_PER_ROW_SEND)) / (ATTACHMENTS_PER_ROW_SEND - 1));
	local gapx2 = floor((areax - (iconx * ATTACHMENTS_PER_ROW_SEND) - (gapx1 * (ATTACHMENTS_PER_ROW_SEND - 1))) / 2);
	local gapy1 = 5;
	local gapy2 = 6;
	local areay = (gapy2 * 2) + (gapy1 * (itemRowCount - 1)) + (icony * itemRowCount);
	local indentx = marginxl + gapx2;
	local indenty = 170 + gapy2 + icony;
	local tabx = (iconx + gapx1) - 2; --this magic number changes the attachment spacing
	local taby = (icony + gapy1);
	local scrollHeight = 249 - areay;

	SendMailHorizontalBarLeft2:SetPoint("TOPLEFT", "SendMailFrame", "BOTTOMLEFT", 2, 184 + areay);
	SendStationeryBackgroundLeft:SetHeight(min(scrollHeight, 256));
	SendStationeryBackgroundLeft:SetTexCoord(0, 1.0, 0, min(scrollHeight, 256) / 256);
	SendStationeryBackgroundRight:SetHeight(min(scrollHeight, 256));
	SendStationeryBackgroundRight:SetTexCoord(0, 1.0, 0, min(scrollHeight, 256) / 256);
	SendStationeryBackgroundLeft:SetTexture("Interface/Stationery/stationerytest1");
	SendStationeryBackgroundRight:SetTexture("Interface/Stationery/stationerytest2");
	
	-- Set Items
	for i=1, ATTACHMENTS_MAX_SEND do
		if (cursory >= 0) then
			SendMailFrame.SendMailAttachments[i]:Enable();
			SendMailFrame.SendMailAttachments[i]:Show();
			SendMailFrame.SendMailAttachments[i]:SetPoint("TOPLEFT", "SendMailFrame", "BOTTOMLEFT", indentx + (tabx * cursorx), indenty + (taby * cursory));
			
			cursorx = cursorx + 1;
			if (cursorx >= ATTACHMENTS_PER_ROW_SEND) then
				cursory = cursory - 1;
				cursorx = 0;
			end
		else
			SendMailFrame.SendMailAttachments[i]:Hide();
		end
	end
	for i=ATTACHMENTS_MAX_SEND+1, ATTACHMENTS_MAX do
		SendMailFrame.SendMailAttachments[i]:Hide();
	end

	SendMailFrame_CanSend();
end

function SendMailFrame_Reset()
	SendMailNameEditBox:SetText("");
	SendMailNameEditBox:SetFocus();
	SendMailSubjectEditBox:SetText("");
	MailEditBox:SetText("");
	SendMailFrame_Update();
	MoneyInputFrame_ResetMoney(SendMailMoney);
	SendMailRadioButton_OnClick(1);
	SendMailFrame.maxRowsShown = 0;
end

function SendMailFrame_CanSend()
	local checks = 0;
	local checksRequired = 2;
	-- Has a sendee
	if ( #SendMailNameEditBox:GetText() > 0 ) then
		checks = checks + 1;
	end
	-- and has a subject
	if ( #SendMailSubjectEditBox:GetText() > 0 ) then
		checks = checks + 1;
	end
	-- check c.o.d. amount
	if ( SendMailCODButton:GetChecked() ) then
		checksRequired = checksRequired + 1;
		-- COD must be less than 10000 gold
		if ( MoneyInputFrame_GetCopper(SendMailMoney) > MAX_COD_AMOUNT * COPPER_PER_GOLD ) then
			if ( ENABLE_COLORBLIND_MODE ~= "1" ) then
				SendMailErrorCoin:Show();
			end
			SendMailErrorText:Show();			
		else
			SendMailErrorText:Hide();
			SendMailErrorCoin:Hide();
			checks = checks + 1;
		end
	end
	
	if ( checks == checksRequired ) then
		SendMailMailButton:Enable();
	else
		SendMailMailButton:Disable();
	end
end

function SendMailRadioButton_OnClick(index)
	if ( index == 1 ) then
		SendMailSendMoneyButton:SetChecked(true);
		SendMailCODButton:SetChecked(false);
		SendMailMoneyText:SetText(AMOUNT_TO_SEND);
	else
		SendMailSendMoneyButton:SetChecked(false);
		SendMailCODButton:SetChecked(true);
		SendMailMoneyText:SetText(COD_AMOUNT);
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function SendMailMoneyButton_OnClick()
	local cursorMoney = GetCursorMoney();
	if ( cursorMoney > 0 ) then
		local money = MoneyInputFrame_GetCopper(SendMailMoney);
		if ( money > 0 ) then
			cursorMoney = cursorMoney + money;
		end
		MoneyInputFrame_SetCopper(SendMailMoney, cursorMoney);
		DropCursorMoney();
	end
end

function SendMailAttachmentButton_OnClick(self, button)
	ClickSendMailItemButton(self:GetID(), button == "RightButton");
end

function SendMailAttachmentButton_OnDropAny()
	ClickSendMailItemButton();
end

function SendMailAttachment_OnEnter(self)
	local index = self:GetID();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( HasSendMailItem(index) ) then
		local hasCooldown, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetSendMailItem(index);
		if(speciesID and speciesID > 0) then
			BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
		end
	else
		GameTooltip:SetText(ATTACHMENT_TEXT, 1.0, 1.0, 1.0);
	end
	self.UpdateTooltip = SendMailAttachment_OnEnter;
end

-----------------------------------------------------------------------------------------------
---------------------------------------- Open All Mail ----------------------------------------
-----------------------------------------------------------------------------------------------

local OPEN_ALL_MAIL_MIN_DELAY = 0.15;

OpenAllMailMixin = {};

function OpenAllMailMixin:Reset()
	self.mailIndex = 1;
	self.attachmentIndex = ATTACHMENTS_MAX;
	self.timeUntilNextRetrieval = nil;
	self.blacklistedItemIDs = nil;
end

function OpenAllMailMixin:StartOpening()
	self:Reset();
	self:Disable();
	self:SetText(OPEN_ALL_MAIL_BUTTON_OPENING);
	self:RegisterEvent("MAIL_INBOX_UPDATE");
	self:RegisterEvent("MAIL_FAILED");
	self.numToOpen = GetInboxNumItems();
	self:AdvanceAndProcessNextItem();
end

function OpenAllMailMixin:StopOpening()
	self:Reset();
	self:Enable();
	self:SetText(OPEN_ALL_MAIL_BUTTON);
	self:UnregisterEvent("MAIL_INBOX_UPDATE");
	self:UnregisterEvent("MAIL_FAILED");
end

function OpenAllMailMixin:AdvanceToNextItem()
	local foundAttachment = false;
	while ( not foundAttachment ) do
		local _, _, _, _, money, CODAmount, daysLeft, itemCount, _, _, _, _, isGM = GetInboxHeaderInfo(self.mailIndex);
		local itemID = select(2, GetInboxItem(self.mailIndex, self.attachmentIndex));
		local hasBlacklistedItem = self:IsItemBlacklisted(itemID);
		local hasCOD = CODAmount and CODAmount > 0;
		local hasMoneyOrItem = C_Mail.HasInboxMoney(self.mailIndex) or HasInboxItem(self.mailIndex, self.attachmentIndex);
		if ( not hasBlacklistedItem and not hasCOD and hasMoneyOrItem ) then
			foundAttachment = true;
		else
			self.attachmentIndex = self.attachmentIndex - 1;
			if ( self.attachmentIndex == 0 ) then
				break;
			end
		end
	end
	
	if ( not foundAttachment ) then
		self.mailIndex = self.mailIndex + 1;
		self.attachmentIndex = ATTACHMENTS_MAX;
		if ( self.mailIndex > GetInboxNumItems() ) then
			return false;
		end
		
		return self:AdvanceToNextItem();
	end
	
	return true;
end

function OpenAllMailMixin:AdvanceAndProcessNextItem()
	if ( CalculateTotalNumberOfFreeBagSlots() == 0 ) then
		self:StopOpening();
		return;
	end
	
	if ( self:AdvanceToNextItem() ) then
		self:ProcessNextItem();
	else
		self:StopOpening();
	end
end

function OpenAllMailMixin:ProcessNextItem()
	local _, _, _, _, money, CODAmount, daysLeft, itemCount, _, _, _, _, isGM = GetInboxHeaderInfo(self.mailIndex);
	if ( isGM or (CODAmount and CODAmount > 0) ) then
		self:AdvanceAndProcessNextItem();
		return;
	end
	
	if ( money > 0 ) then
		TakeInboxMoney(self.mailIndex);
		self.timeUntilNextRetrieval = OPEN_ALL_MAIL_MIN_DELAY;
	elseif ( itemCount and itemCount > 0 ) then
		TakeInboxItem(self.mailIndex, self.attachmentIndex);
		self.timeUntilNextRetrieval = OPEN_ALL_MAIL_MIN_DELAY;
	else
		self:AdvanceAndProcessNextItem();
	end
end

function OpenAllMailMixin:OnLoad()
	self:Reset();
end

function OpenAllMailMixin:OnEvent(event, ...)
	if event == "MAIL_INBOX_UPDATE" then
		if ( self.numToOpen ~= GetInboxNumItems() ) then
			self.mailIndex = 1;
			self.attachmentIndex = ATTACHMENTS_MAX;
		end
	elseif ( event == "MAIL_FAILED" ) then
		local itemID = ...;
		if ( itemID ) then
			self:AddBlacklistedItem(itemID);
		end
	end
end

function OpenAllMailMixin:OnUpdate(dt)
	if ( self.timeUntilNextRetrieval ) then
		self.timeUntilNextRetrieval = self.timeUntilNextRetrieval - dt;
		
		if ( self.timeUntilNextRetrieval <= 0 ) then
			if ( not C_Mail.IsCommandPending() ) then
				self.timeUntilNextRetrieval = nil;
				self:AdvanceAndProcessNextItem();
			else
				-- Delay until the current mail command is done processing.
				self.timeUntilNextRetrieval = OPEN_ALL_MAIL_MIN_DELAY;
			end
		end
	end
end

function OpenAllMailMixin:OnClick()
	self:StartOpening();
end

function OpenAllMailMixin:OnHide()
	self:StopOpening();
end

function OpenAllMailMixin:AddBlacklistedItem(itemID)
	if ( not self.blacklistedItemIDs ) then
		self.blacklistedItemIDs = {};
	end
	
	self.blacklistedItemIDs[itemID] = true;
end

function OpenAllMailMixin:IsItemBlacklisted(itemID)
	return self.blacklistedItemIDs and self.blacklistedItemIDs[itemID];
end

function SendMailEditBox_OnLoad()
	ScrollUtil.RegisterScrollBoxWithScrollBar(MailEditBox.ScrollBox, MailEditBoxScrollBar);
	MailEditBox:RegisterCallback("OnTabPressed", SendMailEditBox_OnTabPressed, MailEditBox);
end

function SendMailEditBox_OnTabPressed(self)
	EditBox_HandleTabbing(self, SEND_MAIL_TAB_LIST);
end