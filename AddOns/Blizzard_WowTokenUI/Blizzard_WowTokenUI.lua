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
Import("C_PurchaseAPI");

Import("math");
Import("pairs");
Import("select");
Import("unpack");
Import("tostring");
Import("tonumber");
Import("date");
Import("time");
Import("type");
Import("PlaySound");
Import("GetCVar");
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
Import("TOKEN_CONFIRM_CREATE_AUCTION_LINE_2"); 
Import("TOKEN_CONFIRM_GAME_TIME_DESCRIPTION");
Import("TOKEN_CONFIRM_GAME_TIME_DESCRIPTION_MINUTES");
Import("TOKEN_CONFIRM_GAME_TIME_EXPIRATION_CONFIRMATION_DESCRIPTION"); 
Import("TOKEN_CONFIRM_GAME_TIME_RENEWAL_CONFIRMATION_DESCRIPTION"); 
Import("TOKEN_COMPLETE_GAME_TIME_DESCRIPTION"); 
Import("TOKEN_BUYOUT_AUCTION_CONFIRMATION_DESCRIPTION");
Import("TOKEN_PRICE_LOCK_EXPIRE");
Import("TOKEN_REDEEM_GAME_TIME_EXPIRATION_FORMAT_MINUTES");
Import("TOKEN_COMPLETE_GAME_TIME_DESCRIPTION_MINUTES");
Import("TOKEN_REDEEM_GAME_TIME_BUTTON_LABEL_MINUTES");
Import("TOKEN_REDEEM_GAME_TIME_DESCRIPTION_MINUTES");
Import("TOKEN_TRANSACTION_IN_PROGRESS");
Import("TOKEN_YOU_WILL_BE_LOGGED_OUT");
Import("TOKEN_REDEMPTION_UNAVAILABLE");
Import("BLIZZARD_STORE_TRANSACTION_IN_PROGRESS");

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
Import("WEEKS_ABBR");
Import("DAYS_ABBR");
Import("HOURS_ABBR");
Import("MINUTES_ABBR");

Import("LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS");
Import("LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES");
Import("LE_TOKEN_RESULT_SUCCESS");
Import("LE_TOKEN_RESULT_ERROR_OTHER");
Import("LE_TOKEN_RESULT_ERROR_DISABLED");

RedeemIndex = nil;

function WowTokenRedemptionFrame_OnLoad(self)
	RedeemIndex = select(3, C_WowTokenPublic.GetCommerceSystemStatus());
	C_WowTokenSecure.CancelRedeem();
	self:SetPoint("CENTER", UIParent, "CENTER", 0, 60);

	self.portrait:Hide();
	self.portraitFrame:Hide();
	self.topLeftCorner:Show();
	self.topBorderBar:SetPoint("TOPLEFT", self.topLeftCorner, "TOPRIGHT",  0, 0);
	self.leftBorderBar:SetPoint("TOPLEFT", self.topLeftCorner, "BOTTOMLEFT",  0, 0);

	self:RegisterEvent("TOKEN_REDEEM_FRAME_SHOW");
	self:RegisterEvent("TOKEN_REDEEM_GAME_TIME_UPDATED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
end

function GetTimeLeftMinuteString(minutes)
	local weeks = 7 * 24 * 60; -- 7 days, 24 hours, 60 minutes
	local days = 24 * 60; -- 24 hours, 60 minutes
	local hours = 60; -- 60 minutes

	local str = "";
	if (math.floor(minutes / weeks) > 0) then
		local wks = math.floor(minutes / weeks);

		minutes = minutes - (wks * weeks);
		str = str .. WEEKS_ABBR:format(wks);
	end

	if (math.floor(minutes / days) > 0) then
		local dys = math.floor(minutes / days);

		minutes = minutes - (dys * days);
		str = str .. " " .. DAYS_ABBR:format(dys);
	end

	if (math.floor(minutes / hours) > 0) then
		local hrs = math.floor(minutes / hours);

		minutes = minutes - (hrs * hours);
		str = str .. " " .. HOURS_ABBR:format(hrs);
	end

	if (minutes > 0) then
		str = str .. " " .. MINUTES_ABBR:format(minutes);
	end

	return str;
end

function GetRedemptionString()
	local isSub, remaining = C_WowTokenSecure.GetRedemptionInfo();

	if (RedeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS) then
		local now = time();
		local oldTime = now + (remaining * 60); -- remaining is in minutes
		local newTime = oldTime + (30 * 24 * 60 * 60); -- 30 days * 24 hours * 60 minutes * 60 seconds

		local oldDate = date("*t", oldTime);
		local newDate = date("*t", newTime);

		local str = isSub and TOKEN_REDEEM_GAME_TIME_RENEWAL_FORMAT or TOKEN_REDEEM_GAME_TIME_EXPIRATION_FORMAT;

		return str:format(SHORTDATE:format(oldDate.day, oldDate.month, oldDate.year), SHORTDATE:format(newDate.day, newDate.month, newDate.year))
	elseif (RedeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES) then
		return TOKEN_REDEEM_GAME_TIME_EXPIRATION_FORMAT_MINUTES:format(GetTimeLeftMinuteString(remaining), GetTimeLeftMinuteString(remaining + 2700));
	end
end

function WowTokenRedemptionFrame_OnEvent(self, event, ...)
	if (event == "TOKEN_REDEEM_FRAME_SHOW") then
		self.Display.RedeemButton:Disable();
		if (not C_WowTokenPublic.GetCommerceSystemStatus()) then
			self.Display.Format:SetText(TOKEN_REDEMPTION_UNAVAILABLE);
			self.Display.Spinner:Hide();
		else
			C_WowTokenPublic.UpdateTokenCount();
			C_WowTokenSecure.GetRemainingGameTime();
			self.Display.Format:Hide();
			self.Display.Spinner:Show();
		end
		self:Show();
	elseif (event == "TOKEN_REDEEM_GAME_TIME_UPDATED") then
		if (RedeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS) then
			self.Display.Description:SetText(TOKEN_REDEEM_GAME_TIME_DESCRIPTION);
			self.Display.RedeemButton:SetText(TOKEN_REDEEM_GAME_TIME_BUTTON_LABEL);
		elseif (RedeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES) then
			self.Display.Description:SetText(TOKEN_REDEEM_GAME_TIME_DESCRIPTION_MINUTES);
			self.Display.RedeemButton:SetText(TOKEN_REDEEM_GAME_TIME_BUTTON_LABEL_MINUTES);
		end
		self.Display.Format:SetText(GetRedemptionString());
		self.Display.Spinner:Hide();
		self.Display.Format:Show();
		self.Display.RedeemButton:Enable();
	elseif (event == "TOKEN_STATUS_CHANGED") then
		RedeemIndex = select(3, C_WowTokenPublic.GetCommerceSystemStatus());
	end
end

function WowTokenRedemptionFrame_OnAttributeChanged(self, name, value)
	--Note - Setting attributes is how the external UI should communicate with this frame. That way, their taint won't be spread to this code.
	if ( name == "action" ) then
		if ( value == "EscapePressed" ) then
			local handled = false;
			if ( self:IsShown() ) then
				C_WowTokenSecure.CancelRedeem();
				self:Hide();
				handled = true;
			end
			self:SetAttribute("escaperesult", handled);
		end
	end
end

function WowTokenRedemptionRedeemButton_OnClick(self)
	WowTokenRedemptionFrame:Hide();
	C_WowTokenSecure.RedeemToken();
	WowTokenDialog_SetDialog(WowTokenDialog, "WOW_TOKEN_REDEEM_CONFIRMATION");
	PlaySound("igMainMenuOpen");
end

function WowTokenRedemptionFrameCloseButton_OnClick(self)
	C_WowTokenSecure.CancelRedeem();
	WowTokenRedemptionFrame:Hide();
	PlaySound("igMainMenuClose");
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

function GetTimeLeftString()
	local _, duration = C_WowTokenPublic.GetCurrentMarketPrice();
	local timeToSellString;
	if (duration == 1) then
		timeToSellString = AUCTION_TIME_LEFT1_DETAIL;
	elseif (duration == 2) then
		timeToSellString = AUCTION_TIME_LEFT2_DETAIL;
	elseif (duration == 3) then
		timeToSellString = AUCTION_TIME_LEFT3_DETAIL;
	else
		timeToSellString = AUCTION_TIME_LEFT4_DETAIL;
	end
	return timeToSellString;
end

-- These are file locals because we don't want to keep variables on the frame itself
local currentDialog, currentDialogName, currentTicker, remainingDialogTime;
local dialogs;
dialogs = {
	["WOW_TOKEN_REDEEM_CONFIRMATION"] = {
		completionIcon = false,
		cautionIcon = true,
		title = TOKEN_CONFIRMATION_TITLE,
		description = { [LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS] = TOKEN_CONFIRM_GAME_TIME_DESCRIPTION, [LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES] = TOKEN_CONFIRM_GAME_TIME_DESCRIPTION_MINUTES },
		confirmationDesc = nil, -- Now set in reaction to an event
		additionalConfirmationDescription = function()
			if (C_WowTokenSecure.WillKickFromWorld()) then
				return "|n|n"..TOKEN_YOU_WILL_BE_LOGGED_OUT;
			else
				return "";
			end
		end,
		confDescIsFunction = true,
		button1 = ACCEPT,
		button1OnClick = function(self) 
			self:Hide(); 
			if (C_WowTokenSecure.GetTokenCount() > 0) then 
				C_WowTokenSecure.RedeemTokenConfirm(); 
				WowTokenDialog_SetDialog(WowTokenDialog, "WOW_TOKEN_REDEEM_IN_PROGRESS"); 
			else
				Outbound.RedeemFailed(LE_TOKEN_RESULT_ERROR_OTHER);
			end
			PlaySound("igMainMenuClose"); 
		end,
		button2 = CANCEL,
		button2OnClick = function(self) self:Hide(); C_WowTokenSecure.CancelRedeem(); PlaySound("igMainMenuClose"); end,
		onHide = function(self)
			dialogs["WOW_TOKEN_REDEEM_CONFIRMATION"].spinner = true;
			dialogs["WOW_TOKEN_REDEEM_CONFIRMATION"].confirmationDesc = nil;
		end,
		spinner = true,
		point = { "CENTER", UIParent, "CENTER", 0, 240 },
	};
	["WOW_TOKEN_REDEEM_COMPLETION"] = {
		completionIcon = true,
		cautionIcon = false,
		title = TOKEN_COMPLETE_TITLE,
		description = { [LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS] = TOKEN_COMPLETE_GAME_TIME_DESCRIPTION, [LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES] = TOKEN_COMPLETE_GAME_TIME_DESCRIPTION_MINUTES },
		button1 = OKAY,
		button1OnClick = function(self) self:Hide(); PlaySound("igMainMenuClose"); end,
		point = { "CENTER", UIParent, "CENTER", 0, 240 },
	};
	["WOW_TOKEN_REDEEM_COMPLETION_KICK"] = {
		title = BLIZZARD_STORE_TRANSACTION_IN_PROGRESS,
		description = { [LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS] = TOKEN_COMPLETE_GAME_TIME_DESCRIPTION, [LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES] = TOKEN_COMPLETE_GAME_TIME_DESCRIPTION_MINUTES },
		confirmationDesc = TOKEN_YOU_WILL_BE_LOGGED_OUT,
		button1 = OKAY,
		button1OnClick = function(self) self:Hide(); PlaySound("igMainMenuClose"); end,
		point = { "CENTER", UIParent, "CENTER", 0, 240 },
	};
	["WOW_TOKEN_CREATE_AUCTION"] = {
		completionIcon = false,
		cautionIcon = true,
		title = TOKEN_CREATE_AUCTION_TITLE,
		confirmationDesc = TOKEN_CONFIRM_CREATE_AUCTION,
		confirmationDescLine2 = function() return TOKEN_CONFIRM_CREATE_AUCTION_LINE_2:format(GetTimeLeftString()) end,
		price = function() return GetSecureMoneyString(C_WowTokenPublic.GetGuaranteedPrice()); end,
		button1 = CREATE_AUCTION,
		button1OnClick = function(self) C_WowTokenSecure.ConfirmSellToken(true); self:Hide(); PlaySound("LOOTWINDOWCOINSOUND"); end,
		button2 = CANCEL,
		button2OnClick = function(self) C_WowTokenSecure.ConfirmSellToken(false); self:Hide(); PlaySound("igMainMenuClose"); end,
		onShow = function(self)
			self:SetAttribute("isauctiondialogshown", true);
		end,
		onHide = function(self)
			self:SetAttribute("isauctiondialogshown", false);
			Outbound.AuctionWowTokenUpdate();
		end,
		onCancelled = function(self)
			C_WowTokenSecure.ConfirmSellToken(false);
			PlaySound("igMainMenuClose");
		end,
		timed = true,
		showCautionText = 20,
		point = { "TOPLEFT", UIParent, "TOPLEFT", 286, -157 },
	};
	["WOW_TOKEN_BUYOUT_AUCTION"] = {
		completionIcon = false,
		cautionIcon = true,
		title = TOKEN_BUYOUT_AUCTION_TITLE,
		confirmationDesc = TOKEN_BUYOUT_AUCTION_CONFIRMATION_DESCRIPTION;
		formatConfirmationDesc = true,
		confDescFormatArgs = function() return { GetSecureMoneyString(C_WowTokenPublic.GetGuaranteedPrice(), true); } end,
		onShow = function(self)
			self:SetAttribute("isauctiondialogshown", true);
			self.Title:SetFontObject("GameFontHighlight");
			self.ConfirmationDesc:SetFontObject("NumberFontNormal");
		end,
		onHide = function(self)
			self:SetAttribute("isauctiondialogshown", false);
			Outbound.AuctionWowTokenUpdate();
			self.Title:SetFontObject("GameFontNormalLarge");
			self.ConfirmationDesc:SetFontObject("GameFontNormal");
		end,
		button1 = ACCEPT,
		button1OnClick = function(self) C_WowTokenSecure.ConfirmBuyToken(true); self:Hide(); PlaySound("igMainMenuClose"); end,
		button2 = CANCEL,
		button2OnClick = function(self) C_WowTokenSecure.ConfirmBuyToken(false); self:Hide(); PlaySound("igMainMenuClose"); end,
		timed = true,
		showCautionText = 20,
		spacing = 6,
		width = 420,
		baseHeight = 34,
		point = { "TOPLEFT", UIParent, "TOPLEFT", 286, -157 },
	};
	["WOW_TOKEN_REDEEM_IN_PROGRESS"] = {
		title = TOKEN_TRANSACTION_IN_PROGRESS,
		spinner = true,
		noButtons = true,
		point = { "CENTER", UIParent, "CENTER", 0, 240 },
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
		self:Hide();
		currentDialog = dialog;
		currentDialogName = dialogName;
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
		if (dialog.formatDesc) then
			description = dialog.description:format(unpack(descArgs));
		elseif (type(dialog.description) == "table") then
			description = dialog.description[RedeemIndex];
		else
			description = dialog.description;
		end
		if (dialog.additionalDescription) then
			description = description .. dialog.additionalDescription();
		end	
		self.Description:SetText(description);
		self.Description:SetWidth(min(maxStringWidth, self.Description:GetWidth()));
		height = height + spacing + self.Description:GetHeight();
		width = max(width, self.Description:GetWidth());
	elseif (dialog.confirmationDesc) then
		self.Description:Hide();
		self.ConfirmationDesc:ClearAllPoints();
		self.ConfirmationDesc:SetPoint("TOP", self.Title, "BOTTOM", 0, -spacing);
	else
		self.Description:Hide();
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
		if (dialog.additionalConfirmationDescription) then
			confirmationDesc = confirmationDesc .. dialog.additionalConfirmationDescription();
		end	
		self.ConfirmationDesc:SetText(confirmationDesc);
		self.ConfirmationDesc:SetWidth(min(maxStringWidth, self.ConfirmationDesc:GetWidth()));
		self.ConfirmationDesc:Show();
		height = height + spacing + self.ConfirmationDesc:GetHeight();
		width = max(width, self.ConfirmationDesc:GetWidth());
		local target = dialog.description and self.Description or self.Title;
		if (dialog.price) then
			self.PriceLabel:SetWidth(0);
			self.ConfirmationDescLine2:ClearAllPoints();
			self.ConfirmationDescLine2:SetPoint("TOP", target, "BOTTOM", 0, -40 + self.ConfirmationDesc:GetHeight());
			if (type(dialog.price) == "function") then
				self.PriceLabel:SetText(dialog.price());
			else
				self.PriceLabel:SetText(dialog.price);
			end
			self.PriceLabel:Show();
			local totalWidth = self.ConfirmationDesc:GetWidth() + self.PriceLabel:GetWidth() + 2;
			local confFinalWidth = self.ConfirmationDesc:GetWidth() + 1;
			local confDescOffset = confFinalWidth - (totalWidth / 2);
			self.ConfirmationDesc:ClearAllPoints();
			self.ConfirmationDesc:SetPoint("TOPRIGHT", target, "BOTTOM", confDescOffset, -spacing);
			self.ConfirmationDesc:SetJustifyH("RIGHT");
		else
			self.ConfirmationDesc:SetJustifyH("CENTER");
			self.ConfirmationDesc:ClearAllPoints();
			self.ConfirmationDesc:SetPoint("TOP", target, "BOTTOM", 0, -spacing);
			self.ConfirmationDescLine2:ClearAllPoints();
			self.ConfirmationDescLine2:SetPoint("TOP", self.ConfirmationDesc, "BOTTOM", 0, -12);
			self.PriceLabel:Hide();
		end
		if (dialog.confirmationDescLine2) then
			self.ConfirmationDescLine2:SetWidth(0);
			if (type(dialog.confirmationDescLine2) == "function") then
				self.ConfirmationDescLine2:SetText(dialog.confirmationDescLine2());
			else
				self.ConfirmationDescLine2:SetText(dialog.confirmationDescLine2);
			end
			self.ConfirmationDescLine2:SetWidth(min(maxStringWidth, self.ConfirmationDescLine2:GetWidth()));
			self.ConfirmationDescLine2:Show();
			height = height + self.ConfirmationDescLine2:GetHeight();
			width = max(width, self.ConfirmationDescLine2:GetWidth());
		else
			self.ConfirmationDescLine2:Hide();
		end
	else
		self.ConfirmationDesc:Hide();
		self.PriceLabel:Hide();
		self.ConfirmationDescLine2:Hide();
	end

	if (dialog.spinner) then
		self.Spinner:Show();
		self.Spinner:ClearAllPoints();
		if (dialog.noButtons) then
			self.Spinner:SetPoint("BOTTOM", 0, 16);
		else
			self.Spinner:SetPoint("BOTTOM", 0, 32);
			height = height + 16;
		end
	else
		self.Spinner:Hide();
	end

	if (dialog.noButtons) then
		self.Button1:Hide();
		self.Button2:Hide();
	else
		self.Button1:Show();
	end

	if (dialog.button2) then
		self.Button1:ClearAllPoints();
		self.Button2:ClearAllPoints();
		self.Button1:SetPoint("BOTTOMRIGHT", self, "BOTTOM", -8, 16);
		self.Button2:SetPoint("BOTTOMLEFT", self, "BOTTOM", 8, 16);
		self.Button2:Show();
		self.Button2:SetText(dialog.button2);
	else
		self.Button2:Hide();
		self.Button1:ClearAllPoints();
		self.Button1:SetPoint("BOTTOM", 0, 16);
	end

	self.Button1:SetText(dialog.button1);

	local finalWidth;
	if (dialog.width) then
		finalWidth = dialog.width;
	else
		finalWidth = width + extraWidth;
	end
	self:SetSize(finalWidth, height);

	self.CautionText:Hide();
	if (dialog.timed) then
		remainingDialogTime = C_WowTokenSecure.GetPriceLockDuration();
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
					self.CautionText:SetText(TOKEN_PRICE_LOCK_EXPIRE:format(remainingDialogTime));
					self.CautionText:Show();
					local newHeight = height + self.CautionText:GetHeight() + 20;
					if (dialog.button2) then
						self.Button1:ClearAllPoints();
						self.Button2:ClearAllPoints();
						self.Button1:SetPoint("BOTTOMRIGHT", self, "BOTTOM", -8, 46);
						self.Button2:SetPoint("BOTTOMLEFT", self, "BOTTOM", 8, 46);
					else
						self.Button1:ClearAllPoints();
						self.Button1:SetPoint("BOTTOM", 0, 46);
					end
					self:SetSize(finalWidth, newHeight);
				else
					self.CautionText:Hide();
					if (dialog.button2) then
						self.Button1:ClearAllPoints();
						self.Button2:ClearAllPoints();
						self.Button1:SetPoint("BOTTOMRIGHT", self, "BOTTOM", -8, 16);
						self.Button2:SetPoint("BOTTOMLEFT", self, "BOTTOM", 8, 16);
					else
						self.Button1:ClearAllPoints();
						self.Button1:SetPoint("BOTTOM", 0, 16);
					end
					self:SetSize(finalWidth, height);
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

	self:Show();
end

function WowTokenDialog_HideDialog(dialogName)
	if (currentDialog and currentDialogName == dialogName) then
		if (dialogName == "WOW_TOKEN_CREATE_AUCTION") then
			C_WowTokenSecure.ConfirmSellToken(false);
		elseif (dialogName == "WOW_TOKEN_BUYOUT_AUCTION") then
			C_WowTokenSecure.ConfirmBuyToken(false);
		end
		WowTokenDialog:Hide();
	end
end

function WowTokenDialog_OnLoad(self)
	self:RegisterEvent("TOKEN_SELL_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_BUY_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_REDEEM_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_REDEEM_RESULT");
	self:RegisterEvent("AUCTION_HOUSE_CLOSED");
end

function WowTokenDialog_OnShow(self)
	if (currentDialog and currentDialog.onShow) then
		currentDialog.onShow(self);
	end
end

function WowTokenDialog_OnHide(self)
	if (currentDialog and currentDialog.onHide) then
		currentDialog.onHide(self);
	end

	if (self:IsShown()) then
		if (currentDialog.onCancelled) then
			currentDialog.onCancelled(self);
		end
		self:Hide();
	end

	currentDialog = nil;
end

function WowTokenDialog_OnEvent(self, event, ...)
	if (event == "TOKEN_SELL_CONFIRM_REQUIRED") then
		WowTokenDialog_SetDialog(self, "WOW_TOKEN_CREATE_AUCTION");
		Outbound.AuctionWowTokenUpdate();
	elseif (event == "TOKEN_BUY_CONFIRM_REQUIRED") then
		WowTokenDialog_SetDialog(self, "WOW_TOKEN_BUYOUT_AUCTION");
		Outbound.AuctionWowTokenUpdate();
	elseif (event == "TOKEN_REDEEM_CONFIRM_REQUIRED") then
		if (currentDialogName ~= "WOW_TOKEN_REDEEM_CONFIRMATION") then
			return;
		end
		self:Hide();
		dialogs["WOW_TOKEN_REDEEM_CONFIRMATION"].spinner = false;
		dialogs["WOW_TOKEN_REDEEM_CONFIRMATION"].confirmationDesc = GetRedemptionString;
		WowTokenDialog_SetDialog(self, "WOW_TOKEN_REDEEM_CONFIRMATION");
	elseif (event == "TOKEN_REDEEM_RESULT") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_SUCCESS) then
			if (C_WowTokenSecure.WillKickFromWorld()) then
				WowTokenDialog_SetDialog(self, "WOW_TOKEN_REDEEM_COMPLETION_KICK");
			else
				WowTokenDialog_SetDialog(self, "WOW_TOKEN_REDEEM_COMPLETION");
			end
		else
			Outbound.RedeemFailed(result);
			C_WowTokenSecure.CancelRedeem();
		end
	elseif (event == "AUCTION_HOUSE_CLOSED") then
		WowTokenDialog_HideDialog("WOW_TOKEN_CREATE_AUCTION");
		WowTokenDialog_HideDialog("WOW_TOKEN_BUYOUT_AUCTION");
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

	if (currentTicker) then
		SecureCancelTicker(currentTicker);
		currentTicker = nil;
	end
end
