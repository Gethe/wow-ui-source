---------------
--NOTE - Please do not change this section without talking to Jacob
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

setfenv(1, tbl);
----------------

Import("C_SecureTransfer");
Import("C_Timer");
Import("select");
Import("string");
Import("math");
Import("type");
Import("GetCVar");
Import("CANCEL");
Import("OKAY");
Import("GOLD_AMOUNT_SYMBOL");
Import("GOLD_AMOUNT_TEXTURE");
Import("GOLD_AMOUNT_TEXTURE_STRING");
Import("SILVER_AMOUNT_SYMBOL");
Import("SILVER_AMOUNT_TEXTURE");
Import("SILVER_AMOUNT_TEXTURE_STRING");
Import("COPPER_AMOUNT_SYMBOL");
Import("COPPER_AMOUNT_TEXTURE");
Import("COPPER_AMOUNT_TEXTURE_STRING");
Import("SEND_ITEMS_TO_STRANGER_WARNING");
Import("SEND_MONEY_TO_STRANGER_WARNING");
Import("TRADE_ACCEPT_CONFIRMATION");
Import("ACCEPT");

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
			self.Button1:SetText(ACCEPT)
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
}

local currentDialog;

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
    SecureTransferDialog:Show();
end

function SecureTransferDialog_OnLoad(self)
    self:RegisterEvent("SECURE_TRANSFER_CONFIRM_TRADE_ACCEPT");
    self:RegisterEvent("SECURE_TRANSFER_CONFIRM_SEND_MAIL");
    self:RegisterEvent("SECURE_TRANSFER_CANCEL");
end

function SecureTransferDialog_OnEvent(self, event)
    if (event == "SECURE_TRANSFER_CONFIRM_TRADE_ACCEPT") then
        SecureTransferDialog_Show("CONFIRM_TRADE");
    elseif (event == "SECURE_TRANSFER_CONFIRM_SEND_MAIL") then
        local mailInfo = C_SecureTransfer.GetMailInfo();
        if (mailInfo.sendMoney > 0) then
            SecureTransferDialog_Show("SEND_MONEY_TO_STRANGER", mailInfo.target);
        else
            SecureTransferDialog_Show("SEND_ITEMS_TO_STRANGER", mailInfo.target);
        end
    elseif (event == "SECURE_TRANSFER_CANCEL") then
        SecureTransferDialog:Hide();
    end
end

function SecureTransferDialog_OnShow(self)
    if currentDialog.onShow then
		currentDialog.onShow(self);
	end
end

function SecureTransferDialog_OnHide(self)
    Outbound.UpdateSendMailButton();
    currentDialog = nil;
end

function SecureTransferDialogButton_OnClick(self, button, down)
    if (self:GetID() == 1) then
        if (currentDialog.onAccept) then
            currentDialog.onAccept();
        end
    else
        if (currentDialog.onCancel) then
            currentDialog.onCancel();
        end
    end
    self:GetParent():Hide();
end

