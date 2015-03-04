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

Import("C_WowTokenSecure");
Import("C_WowTokenPublic");
Import("C_Timer");

Import("math");
Import("pairs");
Import("select");
Import("unpack");
Import("tostring");
Import("tonumber");
Import("date");
Import("time");

Import("TOKEN_REDEEM_LABEL"); 
Import("TOKEN_REDEEM_GAME_TIME_TITLE"); 
Import("TOKEN_REDEEM_GAME_TIME_DESCRIPTION"); 
Import("TOKEN_REDEEM_GAME_TIME_EXPIRATION_FORMAT"); 
Import("TOKEN_REDEEM_GAME_TIME_RENEWAL_FORMAT"); 
Import("TOKEN_REDEEM_GAME_TIME_BUTTON_LABEL"); 
Import("TOKEN_CONFIRMATION_TITLE"); 
Import("TOKEN_COMPLETE_TITLE"); 
Import("TOKEN_CREATE_AUCTION_TITLE"); 
Import("TOKEN_BUYOUT_AUCTION_TITLE"); 
Import("TOKEN_CONFIRM_CREATE_AUCTION"); 
Import("TOKEN_CONFIRM_GAME_TIME_DESCRIPTION"); 
Import("TOKEN_CONFIRM_GAME_TIME_EXPIRATION_CONFIRMATION_DESCRIPTION"); 
Import("TOKEN_CONFIRM_GAME_TIME_RENEWAL_CONFIRMATION_DESCRIPTION"); 
Import("TOKEN_COMPLETE_GAME_TIME_DESCRIPTION"); 
Import("TOKEN_BUYOUT_AUCTION_CONFIRMATION_DESCRIPTION");

Import("GOLD_AMOUNT_SYMBOL");
Import("GOLD_AMOUNT_TEXTURE");
Import("GOLD_AMOUNT_TEXTURE_STRING");
Import("SILVER_AMOUNT_SYMBOL");
Import("SILVER_AMOUNT_TEXTURE");
Import("SILVER_AMOUNT_TEXTURE_STRING");
Import("COPPER_AMOUNT_SYMBOL");
Import("COPPER_AMOUNT_TEXTURE");
Import("COPPER_AMOUNT_TEXTURE_STRING");
Import("SHORTDATE");
Import("AUCTION_TIME_LEFT1_DETAIL");
Import("AUCTION_TIME_LEFT2_DETAIL");
Import("AUCTION_TIME_LEFT3_DETAIL");
Import("AUCTION_TIME_LEFT4_DETAIL");
Import("ACCEPT");
Import("CANCEL");
Import("OKAY");
Import("LARGE_NUMBER_SEPERATOR");
Import("DECIMAL_SEPERATOR");
Import("CREATE_AUCTION");
Import("ENABLE_COLORBLIND_MODE");

RedeemedTokenGUID = nil;
function WowTokenRedemptionFrame_OnLoad(self)
	self.timeGranted = 30;

	self:SetPoint("CENTER", UIParent, "CENTER");

	self.portrait:Hide();
	self.portraitFrame:Hide();
	self.topLeftCorner:Show();
	self.topBorderBar:SetPoint("TOPLEFT", self.topLeftCorner, "TOPRIGHT",  0, 0);
	self.leftBorderBar:SetPoint("TOPLEFT", self.topLeftCorner, "BOTTOMLEFT",  0, 0);

	self.Display.Description:SetText(TOKEN_REDEEM_GAME_TIME_DESCRIPTION:format(self.timeGranted));
	self.Display.RedeemButton:SetText(TOKEN_REDEEM_GAME_TIME_BUTTON_LABEL:format(self.timeGranted));
	
	self:RegisterEvent("TOKEN_REDEEM_FRAME_SHOW")
end

function WowTokenRedemptionFrame_OnEvent(self, event, ...)
	if (event == "TOKEN_REDEEM_FRAME_SHOW") then
		RedeemedTokenGUID = ...;
		C_WowTokenPublic.UpdateTokenCount();
		self:Show();
	end
end

function WowTokenRedemptionRedeemButton_OnClick(self)
	WowTokenRedemptionFrame:Hide();
	C_WowTokenSecure.RedeemToken(RedeemedTokenGUID);
end

function WowTokenRedemptionFrameCloseButton_OnClick(self)
	C_WowTokenSecure.CancelRedeem(RedeemedTokenGUID);
	RedeemedTokenGUID = nil;
	WowTokenRedemptionFrame:Hide();
end

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

	if ( ENABLE_COLORBLIND_MODE == "1" ) then
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

------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------
-- This code is replicated from C_TimerAugment.lua to ensure that the timers are secure.
------------------------------------------------------------------------------------------------------------------------------------------------------
--Cancels a ticker or timer. May be safely called within the ticker's callback in which
--case the ticker simply won't be started again.
--Cancel is guaranteed to be idempotent.
function SecureCancelTicker(ticker)
	ticker._cancelled = true;
end

function NewSecureTicker(duration, callback, iterations)
	local ticker = {};
	ticker._remainingIterations = iterations;
	ticker._callback = function()
		if ( not ticker._cancelled ) then
			callback(ticker);

			--Make sure we weren't cancelled during the callback
			if ( not ticker._cancelled ) then
				if ( ticker._remainingIterations ) then
					ticker._remainingIterations = ticker._remainingIterations - 1;
				end
				if ( not ticker._remainingIterations or ticker._remainingIterations > 0 ) then
					C_Timer.After(duration, ticker._callback);
				end
			end
		end
	end;

	C_Timer.After(duration, ticker._callback);
	return ticker;
end
-----------------------------------------------------------------------------------------------------------------------------------------------------

function GetRedeemConfirmationDescription()
	local isSub, remaining = C_WowTokenSecure.GetRedemptionInfo();

	local now = time();
	local oldTime = now + (remaining * 60); -- remaining is in minutes
	local newTime = oldTime + (30 * 24 * 60 * 60); -- 30 days * 24 hours * 60 minutes * 60 seconds

	local oldDate = date("*t", oldTime);
	local newDate = date("*t", newTime);

	local str = isSub and TOKEN_REDEEM_GAME_TIME_RENEWAL_FORMAT or TOKEN_REDEEM_GAME_TIME_EXPIRATION_FORMAT;

	return str:format(SHORTDATE:format(oldDate.day, oldDate.month, oldDate.year), SHORTDATE:format(newDate.day, newDate.month, newDate.year));
end

-- These are file locals because we don't want to keep variables on the frame itself
local currentDialog, currentTicker, remainingDialogTime;
local dialogs = {
	["WOW_TOKEN_REDEEM_CONFIRMATION"] = {
		completionIcon = false,
		cautionIcon = true,
		title = TOKEN_CONFIRMATION_TITLE,
		description = TOKEN_CONFIRM_GAME_TIME_DESCRIPTION,
		formatDesc = true,
		descFormatArgs = function() return {WowTokenRedemptionFrame.timeGranted} end ,
		confirmationDesc = GetRedeemConfirmationDescription,
		confDescIsFunction = true,
		button1 = ACCEPT,
		button1OnClick = function(self) self:Hide(); C_WowTokenSecure.RedeemTokenConfirm(RedeemedTokenGUID); end,
		button2 = CANCEL,
		button2OnClick = function(self) self:Hide(); C_WowTokenSecure.CancelRedeem(RedeemedTokenGUID); end,
		point = { "CENTER", UIParent, "CENTER", 0, 240 },
	};
	["WOW_TOKEN_REDEEM_COMPLETION"] = {
		completionIcon = true,
		cautionIcon = false,
		title = TOKEN_COMPLETE_TITLE,
		description = TOKEN_COMPLETE_GAME_TIME_DESCRIPTION,
		descFormatArgs = function() return { WowTokenRedemptionFrame.timeGranted } end,
		button1 = OKAY,
		point = { "CENTER", UIParent, "CENTER", 0, 240 },
	};
	["WOW_TOKEN_CREATE_AUCTION"] = {
		completionIcon = false,
		cautionIcon = true,
		title = TOKEN_CREATE_AUCTION_TITLE,
		confirmationDesc = TOKEN_CONFIRM_CREATE_AUCTION,
		formatConfirmationDesc = true,
		confDescFormatArgs = function() return { GetSecureMoneyString(C_WowTokenSecure.GetGuaranteedPrice(), true), AUCTION_TIME_LEFT2_DETAIL } end,
		button1 = CREATE_AUCTION,
		button1OnClick = function(self) C_WowTokenSecure.ConfirmSellToken(); self:Hide(); end,
		button2 = CANCEL,
		onCancelled = function(self)
			C_WowTokenSecure.CancelSale();
		end,
		timer = 60,
		showCautionText = 20,
		point = { "TOPLEFT", UIParent, "TOPLEFT", 286, -157 },
	};

	["WOW_TOKEN_BUYOUT_AUCTION"] = {
		completionIcon = false,
		cautionIcon = true,
		title = TOKEN_BUYOUT_AUCTION_TITLE,
		confirmationDesc = TOKEN_BUYOUT_AUCTION_CONFIRMATION_DESCRIPTION;
		formatConfirmationDesc = true,
		confDescFormatArgs = function() return { GetSecureMoneyString(C_WowTokenSecure.GetGuaranteedPrice(), true); } end,
		onShow = function(self)
			self.Title:SetFontObject("GameFontHighlight");
			self.ConfirmationDesc:SetFontObject("GameFontHighlight");
		end,
		onHide = function(self)
			self.Title:SetFontObject("GameFontNormalLarge");
			self.ConfirmationDesc:SetFontObject("GameFontNormal");
		end,
		button1 = ACCEPT,
		button1OnClick = function(self) C_WowTokenSecure.ConfirmBuyToken(); self:Hide(); end,
		button2 = CANCEL,
		timer = 60,
		showCautionText = 20,
		spacing = 6,
		width = 420,
		baseHeight = 34,
		point = { "TOPLEFT", UIParent, "TOPLEFT", 286, -157 },
	};
};

function WowTokenDialog_SetDialog(self, dialogName)
	local dialog = dialogs[dialogName];
	if (not dialog) then
		return;
	end

	if (dialog.validate) then
		if (not dialog.validate()) then
			return;
		end
	end

	if (self:IsShown() and currentDialog == dialog) then
		return;
	else
		self:Hide(); -- To trigger a dialog's onHide.
		currentDialog = dialog;
	end

	local min = math.min;
	local max = math.max;
	self:ClearAllPoints();
	self:SetPoint(unpack(dialog.point));

	local descArgs = nil;
	local confDescArgs = nil;

	if (dialog.descFormatArgs) then
		descArgs = dialog.descFormatArgs();
	end

	if (dialog.confDescFormatArgs) then
		confDescArgs = dialog.confDescFormatArgs();
	end

	-- To trigger a dialog's onShow.
	self:Show();

	local width = 256;
	local height = dialog.baseHeight or 54;
	local extraWidth = 80;
	local maxStringWidth = 354;
	local spacing = dialog.spacing or 16;

	if (dialog.completionIcon) then
		self.CompletionIcon:Show();
		self.Title:ClearAllPoints();
		self.Title:SetPoint("TOP", self.CompletionIcon, "BOTTOM", 0, -12);
		height = height + 83;
	else
		self.CompletionIcon:Hide();
		self.Title:ClearAllPoints();
		self.Title:SetPoint("TOP", 0, -16);
		height = height + 12;
	end

	self.Title:SetWidth(0);
	self.Title:SetText(dialog.title);
	self.Title:SetWidth(min(maxStringWidth, self.Title:GetWidth()));
	height = height + 12 + self.Title:GetHeight();
	width = max(width, self.Title:GetWidth());

	if (dialog.cautionIcon) then
		self.CautionIcon:Show();
		extraWidth = extraWidth + 36;
	else
		self.CautionIcon:Hide();
	end

	if (dialog.description) then
		self.Description:Show();
		self.ConfirmationDesc:ClearAllPoints();
		self.ConfirmationDesc:SetPoint("TOP", self.Description, "BOTTOM", 0, -spacing);
		self.Description:SetWidth(0);
		local description;
		if (not dialog.formatConfirmationDesc or dialog.formatDesc) then
			description = dialog.description:format(unpack(descArgs));
		else
			description = dialog.description;
		end
		self.Description:SetText(description);
		self.Description:SetWidth(min(maxStringWidth, self.Description:GetWidth()));
		height = height + spacing + self.Description:GetHeight();
		width = max(width, self.Description:GetWidth());
	elseif (dialog.confirmationDesc) then
		self.Description:Hide();
		self.ConfirmationDesc:ClearAllPoints();
		self.ConfirmationDesc:SetPoint("TOP", self.Title, "BOTTOM", 0, -spacing);
	end

	if (dialog.confirmationDesc) then
		self.ConfirmationDesc:SetWidth(0);
		local confirmationDesc;
		if (dialog.confDescIsFunction) then
			confirmationDesc = dialog.confirmationDesc();
		elseif (dialog.formatConfirmationDesc) then
			confirmationDesc = dialog.confirmationDesc:format(unpack(confDescArgs));
		else
			confirmationDesc = dialog.confirmationDesc;
		end
		self.ConfirmationDesc:SetText(confirmationDesc);
		self.ConfirmationDesc:SetWidth(min(maxStringWidth, self.ConfirmationDesc:GetWidth()));
		self.ConfirmationDesc:Show();
		height = height + spacing + self.ConfirmationDesc:GetHeight();
		width = max(width, self.ConfirmationDesc:GetWidth());
	else
		self.ConfirmationDesc:Hide();
	end

	if (dialog.button2) then
		self.Button1:ClearAllPoints();
		self.Button1:SetPoint("BOTTOMRIGHT", self, "BOTTOM", -8, 16);
		self.Button2:Show();
		self.Button2:SetText(dialog.button2);
	else
		self.Button2:Hide();
		self.Button1:ClearAllPoints();
		self.Button1:SetPoint("BOTTOM", 0, 16);
	end

	self.CautionText:Hide();
	if (dialog.timer) then
		remainingDialogTime = dialog.timer;
		if (not currentTicker) then
			currentTicker = NewSecureTicker(1, function()
				if (remainingDialogTime == 0) then
					SecureCancelTicker(currentTicker);
					if (dialog.onCancelled) then
						dialog.onCancelled(WowTokenDialog);
					end
					currentTicker = nil;
					self:Hide();
				elseif (remainingDialogTime <= (dialog.showCautionText and dialog.showCautionText or 20)) then
					self.CautionText:SetText(remainingDialogTime);
					self.CautionText:Show();
				else
					self.CautionText:Hide();
				end
				remainingDialogTime = remainingDialogTime - 1;
			end);
		end
	else
		if (currentTicker) then
			SecureCancelTicker(currentTicker);
			currentTicker = nil;
		end
	end
	self.Button1:SetText(dialog.button1);

	local finalWidth;
	if (dialog.width) then
		finalWidth = dialog.width;
	else
		finalWidth = width + extraWidth;
	end
	self:SetSize(finalWidth, height);
end

function WowTokenDialog_OnLoad(self)
	self:RegisterEvent("TOKEN_SELL_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_BUY_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_REDEEM_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_REDEEM_RESULT");
end

function WowTokenDialog_OnEvent(self, event, ...)
	if (event == "TOKEN_SELL_CONFIRM_REQUIRED") then
		WowTokenDialog_SetDialog(self, "WOW_TOKEN_CREATE_AUCTION");
	elseif (event == "TOKEN_BUY_CONFIRM_REQUIRED") then
		WowTokenDialog_SetDialog(self, "WOW_TOKEN_BUYOUT_AUCTION");
	elseif (event == "TOKEN_REDEEM_CONFIRM_REQUIRED") then
		WowTokenDialog_SetDialog(self, "WOW_TOKEN_REDEEM_CONFIRMATION");
	elseif (event == "TOKEN_REDEEM_RESULT") then
		local result = ...;
		-- TEMP: We should add these as lua enums for error handling when the error cases are known.
		if (result == 1) then -- 1 is success
			WowTokenDialog_SetDialog(self, "WOW_TOKEN_REDEEM_COMPLETION");
		else
			C_WowTokenSecure.CancelRedeem(RedeemedTokenGUID);
		end
		RedeemedTokenGUID = nil;
	end
end

function WowTokenDialogButton_OnClick(self)
	local id = self:GetID();
	local onClick;
	if (id == 1) then
		onClick = "button1OnClick";
	else
		onClick = "button2OnClick";
	end

	if (currentDialog and currentDialog[onClick]) then
		currentDialog[onClick](WowTokenDialog);
	else
		if (id == 2 and currentDialog.onCancelled) then
			currentDialog.onCancelled(WowTokenDialog);
		end
		WowTokenDialog:Hide();
	end
end
