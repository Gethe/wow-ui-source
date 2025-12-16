
-- Copied here for access in the secure environment.
local HearthsteelAtlasMarkup = CreateAtlasMarkup("hearthsteel-icon-32x32", 16, 16, 0, -1);

local function formatLargeNumber(amount)
	amount = tostring(amount);
	local newDisplay = "";
	local strlen = amount:len();
	--Add each thing behind a comma
	for i=4, strlen, 3 do
		newDisplay = LARGE_NUMBER_SEPERATOR..amount:sub(-(i - 1), -(i - 3))..newDisplay;
	end
	--Add everything before the first comma
	newDisplay = amount:sub(1, (strlen % 3 == 0) and 3 or (strlen % 3))..newDisplay;
	return newDisplay;
end

------------------------------------------------------------------------------------------------------------------------------------------------------
-- This section is based on code from MoneyFrame.lua to keep it in the secure environment, if you change it there you should probably change it here as well.
------------------------------------------------------------------------------------------------------------------------------------------------------
local COPPER_PER_SILVER = 100;
local SILVER_PER_GOLD = 100;
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD;

function GetSecureMoneyString(money, separateThousands)
	local goldString, silverString, copperString;
	local floor = math.floor;

	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = money % COPPER_PER_SILVER;

	if ( GetCVar("colorblindMode") == "1" ) then
		if (separateThousands) then
			goldString = formatLargeNumber(gold)..GOLD_AMOUNT_SYMBOL;
		else
			goldString = gold..GOLD_AMOUNT_SYMBOL;
		end
		silverString = silver..SILVER_AMOUNT_SYMBOL;
		copperString = copper..COPPER_AMOUNT_SYMBOL;
	else
		if (separateThousands) then
			goldString = GOLD_AMOUNT_TEXTURE_STRING:format(formatLargeNumber(gold), 0, 0);
		else
			goldString = GOLD_AMOUNT_TEXTURE:format(gold, 0, 0);
		end
		silverString = SILVER_AMOUNT_TEXTURE:format(silver, 0, 0);
		copperString = COPPER_AMOUNT_TEXTURE:format(copper, 0, 0);
	end
	
	local moneyString = "";
	local separator = "";
	if ( gold > 0 ) then
		moneyString = goldString;
		separator = " ";
	end
	if ( silver > 0 ) then
		moneyString = moneyString..separator..silverString;
		separator = " ";
	end
	if ( copper > 0 or moneyString == "" ) then
		moneyString = moneyString..separator..copperString;
	end
	
	return moneyString;
end

function SecureTransferDialog_DelayedAccept(self)
    self.Button1:Disable();
    C_Timer.After(1, function()
        self.Button1:Enable();
    end);
end

function SecureTransferDialog_TimerOnAccept(self)
	self.Button1:Disable();
	self.acceptTimeLeft = 3;
	self.Button1:SetText(self.acceptTimeLeft);
	self.ticker = C_Timer.NewTicker(1, function()
		self.acceptTimeLeft = self.acceptTimeLeft - 1;
		if (self.acceptTimeLeft == 0) then
			self.Button1:SetText(ACCEPT);
			self.Button1:Enable();
			self.ticker:Cancel();
			return;
		else
			self.Button1:SetText(self.acceptTimeLeft);
		end
	end);
end

local SECURE_TRANSFER_DIALOGS = {
    ["CONFIRM_TRADE"] = {
        text = TRADE_ACCEPT_CONFIRMATION,
		onShow = SecureTransferDialog_DelayedAccept,
        onAccept = function()
            C_SecureTransfer.AcceptTrade();
        end,
    },
    ["SEND_MONEY_TO_STRANGER"] = {
        text = SEND_MONEY_TO_STRANGER_WARNING,
        money = function() local mailInfo = C_SecureTransfer.GetMailInfo(); return GetSecureMoneyString(mailInfo.sendMoney); end,
		onShow = SecureTransferDialog_TimerOnAccept,
        onAccept = function(self)
            C_SecureTransfer.SendMail();
        end,
    },
    ["SEND_ITEMS_TO_STRANGER"] = {
        text = SEND_ITEMS_TO_STRANGER_WARNING,
		onShow = SecureTransferDialog_TimerOnAccept,
        onAccept = function(self)
            C_SecureTransfer.SendMail();
        end,
    },
	["CONFIRM_HOUSING_PURCHASE"] = {
		button1 = ACCEPT,
		text = HOUSING_MARKET_PURCHASE_CONFIRMATION,
		onAccept = function(self)
			C_SecureTransfer.CompleteHousingPurchase();
		end,
		waitForEvent = "BULK_PURCHASE_RESULT_RECEIVED",
		eventCallback = function(self, ...)
			local result, _individualResults = ...;
			if result == Enum.BulkPurchaseResult.ResultOk or result == Enum.BulkPurchaseResult.ResultPartialSuccess then
				PlaySound(SOUNDKIT.HOUSING_MARKET_PURCHASE_CELEBRATION);
				self:Hide();
			else
				-- Show failure dialog before hiding
				SecureTransferDialog_Show("HOUSING_PURCHASE_FAILURE");
			end
		end,
		beforeSpinnerWaitTime = 0,
		timeoutTime = 20,
		onTimeout = function(self)
			self:Hide();
			SecureTransferDialog_Show("SLOW_HOUSING_PURCHASE");
		end,
		fullScreenCover = true,
	},
	["SLOW_HOUSING_PURCHASE"] = {
		text = HOUSING_MARKET_PURCHASE_SLOW_DESC,
		hideButton2 = true,
	},
	["HOUSING_PURCHASE_FAILURE"] = {
		text = HOUSING_MARKET_PURCHASE_FAILURE,
		hideButton2 = true,
	},
	["START_HOUSING_VC_PURCHASE"] = {
		button1 = CONTINUE,
		text = HOUSING_MARKET_VC_PURCHASE_CONFIRMATION,
		onAccept = function(self)
			local productID = C_SecureTransfer.GetHousingVCPurchaseProductID();
			C_SecureTransfer.CompleteHousingVCPurchase();
			C_CatalogShop.PurchaseProduct(productID);
			SecureTransferOutbound.HideCatalogShopTopUpFrame();
		end,
		fullScreenCover = true,
		-- Use TOOLTIP strata to layer above the TopUpFrame which uses FULLSCREEN_DIALOG
		overrideFrameStrata = "TOOLTIP",
		getFocusedFrame = SecureTransferOutbound.GetCatalogShopTopUpFrame,
	},
}

local currentDialog;

local function GetHearthsteelQuantityFromProduct(productInfo)
	local hearthsteelCurrencyCode = SecureTransferOutbound.GetHearthsteelVirtualCurrencyCode();
	if productInfo and productInfo.virtualCurrencies then
		for _, virtualCurrency in ipairs(productInfo.virtualCurrencies) do
			if virtualCurrency.currencyCode == hearthsteelCurrencyCode then
				return virtualCurrency.amount;
			end
		end
	end

	-- This should never happen in practice.
	return 0;
end

function SecureTransferDialog_Show(which, ...)
    if (not SECURE_TRANSFER_DIALOGS[which]) then
        return;
    end

    local height = 92;

    currentDialog = SECURE_TRANSFER_DIALOGS[which];
    if (select('#', ...) > 0) then
        SecureTransferDialog.Text:SetText(string.format(currentDialog.text, ...));
    else
        SecureTransferDialog.Text:SetText(currentDialog.text);
    end

    height = height + SecureTransferDialog.Text:GetHeight();

    if (currentDialog.money) then
        if (type(currentDialog.money) == "function") then
            SecureTransferDialog.MoneyLabel:SetText(currentDialog.money());
        else
            SecureTransferDialog.MoneyLabel:SetText(currentDialog.money);
        end
        SecureTransferDialog.MoneyLabel:Show();
        height = height + SecureTransferDialog.MoneyLabel:GetHeight();
    else
        SecureTransferDialog.MoneyLabel:Hide();
    end
    SecureTransferDialog:SetHeight(height);

	local parent = SecureTransferOutbound.GetAppropriateTopLevelParent();
	FrameUtil.SetParentMaintainRenderLayering(SecureTransferDialog, parent);

	SecureTransferDialog:SetFrameStrata(currentDialog.overrideFrameStrata or "DIALOG");

	local focusedFrame = currentDialog.getFocusedFrame and currentDialog.getFocusedFrame() or nil;

	-- Position dialog centered on focused frame, or default positioning
	SecureTransferDialog:ClearAllPoints();
	if focusedFrame then
		SecureTransferDialog:SetPoint("CENTER", focusedFrame, "CENTER");
	else
		SecureTransferDialog:SetPoint("CENTER");
	end

	local coverFrameParent = focusedFrame or SecureTransferOutbound.GetAppropriateTopLevelParent();

	SecureTransferDialog.CoverFrame:ClearAllPoints();
	SecureTransferDialog.CoverFrame:SetPoint("TOPLEFT", coverFrameParent, "TOPLEFT");
	SecureTransferDialog.CoverFrame:SetPoint("BOTTOMRIGHT", coverFrameParent, "BOTTOMRIGHT");
	SecureTransferDialog.CoverFrame:SetShown(currentDialog.fullScreenCover);

	local hideButton2 = currentDialog.hideButton2;
	SecureTransferDialog.Button2:SetShown(not hideButton2);

	local button1Text = currentDialog.button1 or (hideButton2 and OKAY or ACCEPT);
	SecureTransferDialog.Button1:SetText(button1Text);
	SecureTransferDialog.Button1:Enable();

	SecureTransferDialog.Button1:ClearAllPoints();
	if hideButton2 then
		SecureTransferDialog.Button1:SetPoint("BOTTOM", SecureTransferDialog, "BOTTOM", 0, 16);
	else
		SecureTransferDialog.Button2:Enable();
		SecureTransferDialog.Button1:SetPoint("BOTTOMRIGHT", SecureTransferDialog, "BOTTOM", -8, 16);
	end

    SecureTransferDialog:Show();
end

function SecureTransferDialog_OnLoad(self)
	self:RegisterEvent("SECURE_TRANSFER_CONFIRM_TRADE_ACCEPT");
	self:RegisterEvent("SECURE_TRANSFER_CONFIRM_SEND_MAIL");
	self:RegisterEvent("SECURE_TRANSFER_CONFIRM_HOUSING_PURCHASE");
	self:RegisterEvent("SECURE_TRANSFER_HOUSING_CURRENCY_PURCHASE_CONFIRMATION");
	self:RegisterEvent("SECURE_TRANSFER_CANCEL");
	self:RegisterEvent("BULK_PURCHASE_RESULT_RECEIVED");
end

function SecureTransferDialog_OnEvent(self, event, ...)
    if (event == "SECURE_TRANSFER_CONFIRM_TRADE_ACCEPT") then
        SecureTransferDialog_Show("CONFIRM_TRADE");
    elseif (event == "SECURE_TRANSFER_CONFIRM_SEND_MAIL") then
        local mailInfo = C_SecureTransfer.GetMailInfo();
        if (mailInfo.sendMoney > 0) then
            SecureTransferDialog_Show("SEND_MONEY_TO_STRANGER", mailInfo.target);
        else
            SecureTransferDialog_Show("SEND_ITEMS_TO_STRANGER", mailInfo.target);
        end
	elseif (event == "SECURE_TRANSFER_CONFIRM_HOUSING_PURCHASE") then
		local costText = C_SecureTransfer.GetHousingPurchaseCost() .. HearthsteelAtlasMarkup;
		SecureTransferDialog_Show("CONFIRM_HOUSING_PURCHASE", costText);
	elseif (event == "SECURE_TRANSFER_HOUSING_CURRENCY_PURCHASE_CONFIRMATION") then
		local productID = C_SecureTransfer.GetHousingVCPurchaseProductID();
		local productInfo = C_CatalogShop.GetProductInfo(productID);

		-- We're not formatting in the currency icon because the currency name is spelled out in the dialog text.
		local quantity = GetHearthsteelQuantityFromProduct(productInfo);
		SecureTransferDialog_Show("START_HOUSING_VC_PURCHASE", quantity);
    elseif (event == "SECURE_TRANSFER_CANCEL") then
        SecureTransferDialog:Hide();
	elseif (self.waitingForEvents and currentDialog and currentDialog.waitForEvent) then
		if (event == currentDialog.waitForEvent) then
			if (self.timeoutTimer) then
				self.timeoutTimer:Cancel();
				self.timeoutTimer = nil;
			end
			
			if (self.timedOut) then
				self.timedOut = false;
				return;
			end
			
			if (self.spinnerTimer) then
				self.spinnerTimer:Cancel();
				self.spinnerTimer = nil;
			end
			self.Spinner:Hide();
			self.DarkOverlay:Hide();
			self.waitingForEvents = false;
			
			currentDialog.eventCallback(self, ...);
		end
    end
end

function SecureTransferDialog_OnShow(self)
    if currentDialog.onShow then
		currentDialog.onShow(self);
	end
end

function SecureTransferDialog_OnHide(self)
    SecureTransferOutbound.UpdateSendMailButton();

	-- Cleanup spinner if hiding early
	if (self.waitingForEvents) then
		if (self.spinnerTimer) then
			self.spinnerTimer:Cancel();
			self.spinnerTimer = nil;
		end
		if (self.timeoutTimer) then
			self.timeoutTimer:Cancel();
			self.timeoutTimer = nil;
		end
		self.Spinner:Hide();
		self.DarkOverlay:Hide();
		self.waitingForEvents = false;
		self.timedOut = false;
	end

    currentDialog = nil;

	-- If our parent hides, make sure we're hidden.
	self:Hide();
end

function SecureTransferDialogButton_OnClick(self, button, down)
    if (self:GetID() == 1) then
        if (currentDialog.onAccept) then
            currentDialog.onAccept();
        end
		
		if (currentDialog.waitForEvent) then
			self:Disable();
			self:GetParent().Button2:Disable();
			
			local beforeSpinnerWaitTime = currentDialog.beforeSpinnerWaitTime or 0;
			local spinnerTimer = C_Timer.NewTimer(beforeSpinnerWaitTime, function()
				SecureTransferDialog.DarkOverlay:Show();
				SecureTransferDialog.Spinner:Show();
			end);
			
			SecureTransferDialog.spinnerTimer = spinnerTimer;
			SecureTransferDialog.waitingForEvents = true;
			SecureTransferDialog.timedOut = false;
			
			-- Start timeout timer if specified
			if (currentDialog.timeoutTime) then
				SecureTransferDialog.timeoutTimer = C_Timer.NewTimer(currentDialog.timeoutTime, function()
					if (SecureTransferDialog.waitingForEvents) then
						SecureTransferDialog.timedOut = true;
						if (currentDialog.onTimeout) then
							currentDialog.onTimeout(SecureTransferDialog);
						end
					end
				end);
			end
			
			return;
		end
    else
        if (currentDialog.onCancel) then
            currentDialog.onCancel();
        end
    end
    self:GetParent():Hide();
end

