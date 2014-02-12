---------------
--NOTE - Please do not change this section without talking to Jacob
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

Import("IsOnGlueScreen");

if ( tbl.IsOnGlueScreen() ) then
	tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
end

setfenv(1, tbl);
----------------

--Local variables (here instead of as members on frames for now)
local JustOrderedProduct = false;
local WaitingOnConfirmation = false;
local WaitingOnConfirmationTime = 0;
local ProcessAnimPlayed = false;
local NumUpgradeDistributions = 0;

--Imports
Import("C_PurchaseAPI");
Import("C_PetJournal");
Import("C_SharedCharacterServices");
Import("C_AuthChallenge");
Import("CreateForbiddenFrame");
Import("IsGMClient");
Import("math");
Import("pairs");
Import("select");
Import("tostring");
Import("tonumber");
Import("unpack");
Import("LoadURLIndex");
Import("GetContainerNumFreeSlots");
Import("GetCursorPosition");
Import("PlaySound");
Import("SetPortraitToTexture");
Import("BACKPACK_CONTAINER");
Import("NUM_BAG_SLOTS");
Import("IsModifiedClick");
Import("GetTime");
Import("UnitAffectingCombat");

--GlobalStrings
Import("BLIZZARD_STORE");
Import("BLIZZARD_STORE_ON_SALE");
Import("BLIZZARD_STORE_BUY");
Import("BLIZZARD_STORE_BUY_EUR");
Import("BLIZZARD_STORE_PLUS_TAX");
Import("BLIZZARD_STORE_PRODUCT_INDEX");
Import("BLIZZARD_STORE_CANCEL_PURCHASE");
Import("BLIZZARD_STORE_FINAL_BUY");
Import("BLIZZARD_STORE_FINAL_BUY_EUR");
Import("BLIZZARD_STORE_CONFIRMATION_TITLE");
Import("BLIZZARD_STORE_CONFIRMATION_INSTRUCTION");
Import("BLIZZARD_STORE_FINAL_PRICE_LABEL");
Import("BLIZZARD_STORE_PAYMENT_METHOD");
Import("BLIZZARD_STORE_PAYMENT_METHOD_EXTRA");
Import("BLIZZARD_STORE_LOADING");
Import("BLIZZARD_STORE_PLEASE_WAIT");
Import("BLIZZARD_STORE_NO_ITEMS");
Import("BLIZZARD_STORE_CHECK_BACK_LATER");
Import("BLIZZARD_STORE_TRANSACTION_IN_PROGRESS");
Import("BLIZZARD_STORE_CONNECTING");
Import("BLIZZARD_STORE_VISIT_WEBSITE");
Import("BLIZZARD_STORE_VISIT_WEBSITE_WARNING");
Import("BLIZZARD_STORE_BAG_FULL");
Import("BLIZZARD_STORE_BAG_FULL_DESC");
Import("BLIZZARD_STORE_CONFIRMATION_GENERIC");
Import("BLIZZARD_STORE_CONFIRMATION_TEST");
Import("BLIZZARD_STORE_CONFIRMATION_EUR");
Import("BLIZZARD_STORE_CONFIRMATION_SERVICES");
Import("BLIZZARD_STORE_CONFIRMATION_SERVICES_TEST");
Import("BLIZZARD_STORE_CONFIRMATION_SERVICES_EUR");
Import("BLIZZARD_STORE_BROWSE_TEST_CURRENCY");
Import("BLIZZARD_STORE_BATTLE_NET_BALANCE");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_USD");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_KRW_LONG");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_CPT_LONG");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_TPT");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_GBP");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_EURO");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_RUB");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_MXN");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_BRL");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_ARS");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_CLP");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_AUD");
Import("BLIZZARD_STORE_CURRENCY_RAW_ASTERISK");
Import("BLIZZARD_STORE_CURRENCY_BETA");
Import("BLIZZARD_STORE_BROWSE_BATTLE_COINS_KR");
Import("BLIZZARD_STORE_BROWSE_BATTLE_COINS_CN");
Import("BLIZZARD_STORE_BROWSE_EUR");
Import("BLIZZARD_STORE_ASTERISK");
Import("BLIZZARD_STORE_INTERNAL_ERROR");
Import("BLIZZARD_STORE_INTERNAL_ERROR_SUBTEXT");
Import("BLIZZARD_STORE_ERROR_TITLE_OTHER");
Import("BLIZZARD_STORE_ERROR_MESSAGE_OTHER");
Import("BLIZZARD_STORE_NOT_AVAILABLE");
Import("BLIZZARD_STORE_NOT_AVAILABLE_SUBTEXT");
Import("BLIZZARD_STORE_ERROR_TITLE_PAYMENT");
Import("BLIZZARD_STORE_ERROR_MESSAGE_PAYMENT");
Import("BLIZZARD_STORE_ERROR_TITLE_BATTLEPAY_DISABLED");
Import("BLIZZARD_STORE_ERROR_MESSAGE_BATTLEPAY_DISABLED");
Import("BLIZZARD_STORE_SECOND_CHANCE_KR");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_CN");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_TW");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_USD");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_GBP");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_EUR");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_RUB");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_ARS");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_CLP");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_MXN");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_BRL");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_AUD");
Import("BLIZZARD_STORE_REGION_LOCKED");
Import("BLIZZARD_STORE_REGION_LOCKED_SUBTEXT");
Import("BLIZZARD_STORE_ERROR_TITLE_INSUFFICIENT_BALANCE");
Import("BLIZZARD_STORE_ERROR_MESSAGE_INSUFFICIENT_BALANCE");
Import("BLIZZARD_STORE_ERROR_TITLE_ALREADY_OWNED");
Import("BLIZZARD_STORE_ERROR_MESSAGE_ALREADY_OWNED");
Import("BLIZZARD_STORE_ERROR_TITLE_PARENTAL_CONTROLS");
Import("BLIZZARD_STORE_ERROR_MESSAGE_PARENTAL_CONTROLS");
Import("BLIZZARD_STORE_ERROR_TITLE_PURCHASE_DENIED");
Import("BLIZZARD_STORE_ERROR_MESSAGE_PURCHASE_DENIED");
Import("BLIZZARD_STORE_DISCOUNT_TEXT_FORMAT");
Import("BLIZZARD_STORE_PAGE_NUMBER");
Import("BLIZZARD_STORE_SPLASH_BANNER_DISCOUNT_FORMAT");
Import("BLIZZARD_STORE_SPLASH_BANNER_FEATURED");
Import("BLIZZARD_STORE_SPLASH_BANNER_NEW");
Import("BLIZZARD_STORE_WALLET_INFO");
Import("BLIZZARD_STORE_PROCESSING");
Import("BLIZZARD_STORE_BEING_PROCESSED_CHECK_BACK_LATER");
Import("BLIZZARD_STORE_PURCHASE_SENT");
Import("BLIZZARD_STORE_YOU_ALREADY_OWN_THIS");
Import("TOOLTIP_DEFAULT_COLOR");
Import("TOOLTIP_DEFAULT_BACKGROUND_COLOR");
Import("CHARACTER_UPGRADE_LOG_OUT_NOW");
Import("CHARACTER_UPGRADE_POPUP_LATER");
Import("CHARACTER_UPGRADE_READY");
Import("CHARACTER_UPGRADE_READY_DESCRIPTION");

Import("OKAY");
Import("LARGE_NUMBER_SEPERATOR");
Import("DECIMAL_SEPERATOR");

--Lua enums
Import("LE_STORE_ERROR_INVALID_PAYMENT_METHOD");
Import("LE_STORE_ERROR_PAYMENT_FAILED");
Import("LE_STORE_ERROR_WRONG_CURRENCY");
Import("LE_STORE_ERROR_BATTLEPAY_DISABLED");
Import("LE_STORE_ERROR_INSUFFICIENT_BALANCE");
Import("LE_STORE_ERROR_OTHER");
Import("LE_STORE_ERROR_ALREADY_OWNED");
Import("LE_STORE_ERROR_PARENTAL_CONTROLS_NO_PURCHASE");
Import("LE_STORE_ERROR_PURCHASE_DENIED");

--Data
local CURRENCY_UNKNOWN = 0;
local CURRENCY_USD = 1;
local CURRENCY_GBP = 2;
local CURRENCY_KRW = 3;
local CURRENCY_EUR = 4;
local CURRENCY_RUB = 5;
local CURRENCY_ARS = 8;
local CURRENCY_CLP = 9;
local CURRENCY_MXN = 10;
local CURRENCY_BRL = 11;
local CURRENCY_AUD = 12;
local CURRENCY_CPT = 14;
local CURRENCY_TPT = 15;
local CURRENCY_BETA = 16;
local NUM_STORE_PRODUCT_CARDS = 8;
local NUM_STORE_PRODUCT_CARDS_PER_ROW = 4;
local ROTATIONS_PER_SECOND = .5;
local MODELFRAME_DRAG_ROTATION_CONSTANT = 0.010;
local BATTLEPAY_GROUP_DISPLAY_DEFAULT = 0;
local BATTLEPAY_GROUP_DISPLAY_SPLASH = 1;
local BATTLEPAY_SPLASH_BANNER_TEXT_FEATURED = 0;
local BATTLEPAY_SPLASH_BANNER_TEXT_DISCOUNT = 1;
local BATTLEPAY_SPLASH_BANNER_TEXT_NEW = 2;
local STORETOOLTIP_MAX_WIDTH = 250;

local PI = math.pi;

local currencyMult = 100;

local selectedCategoryID;
local selectedEntryID;
local selectedPageNum = 1;

--DECIMAL_SEPERATOR = ",";
--LARGE_NUMBER_SEPERATOR = ".";

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

local function largeAmount(num)
	return formatLargeNumber(math.floor(num / currencyMult));
end

local function formatCurrency(dollars, cents, alwaysShowCents)
	if ( alwaysShowCents or cents ~= 0 ) then
		return ("%s%s%02d"):format(formatLargeNumber(dollars), DECIMAL_SEPERATOR, cents);
	else
		return formatLargeNumber(dollars);
	end
end

local function currencyFormatUSD(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_USD:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatGBP(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_GBP:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatKRWLong(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_KRW_LONG:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatEuro(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_EURO:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatRUB(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_RUB:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatARS(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_ARS:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatCLP(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_CLP:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatMXN(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_MXN:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatBRL(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_BRL:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatAUD(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_AUD:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatCPTLong(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_CPT_LONG:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatTPT(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_FORMAT_TPT:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatRawStar(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_RAW_ASTERISK:format(formatCurrency(dollars, cents, false));
end

local function currencyFormatBeta(dollars, cents)
	return BLIZZARD_STORE_CURRENCY_BETA:format(formatCurrency(dollars, cents, true));
end

----------
--Values
---
--formatShort - The format function for currency on the browse window next to quantity display
--formatLong - The format function for currency in areas where we want the full display (e.g. bottom of the browse window and the confirmation frame)
--browseNotice - The notice in the bottom left corner of the browse frame
--confirmationNotice - The notice in the middle of the confirmation frame (between the icon/name and the price
--paymentMethodText - The header displayed on the confirmation frame below the parchment
--paymentMethodSubtext - The smaller text displayed on the confirmation frame below the parchment (and below the paymentMethodText)
--licenseAcceptText - The text (HTML) displayed right above the purchase button on the confirmation window. Can include links.
--requireLicenseAccept - Boolean indicating whether people are required to click a checkbox next to the licenseAcceptText before purchasing the item.
----------
local currencySpecific = {
	[CURRENCY_USD] = {
		formatShort = currencyFormatUSD,
		formatLong = currencyFormatUSD,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_USD,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_GBP] = {
		formatShort = currencyFormatGBP,
		formatLong = currencyFormatGBP,
		browseNotice = BLIZZARD_STORE_BROWSE_EUR,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_EUR,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_EUR,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_GBP,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		requireLicenseAccept = true,
		browseHasStar = true,
		browseBuyButtonText = BLIZZARD_STORE_BUY_EUR,
		confirmationButtonText = BLIZZARD_STORE_FINAL_BUY_EUR,
	},
	[CURRENCY_KRW] = {
		formatShort = currencyFormatRawStar,
		formatLong = currencyFormatKRWLong,
		browseNotice = BLIZZARD_STORE_BROWSE_BATTLE_COINS_KR,
		confirmationNotice = BLIZZARD_STORE_SECOND_CHANCE_KR,
		servicesConfirmationNotice = BLIZZARD_STORE_SECOND_CHANCE_KR,
		browseWarning = BLIZZARD_STORE_SECOND_CHANCE_KR,
		paymentMethodText = "",
		paymentMethodSubtext = "",
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT,
		requireLicenseAccept = true,
		hideConfirmationBrowseNotice = true,
		browseHasStar = false,
	},
	[CURRENCY_EUR] = {
		formatShort = currencyFormatEuro,
		formatLong = currencyFormatEuro,
		browseNotice = BLIZZARD_STORE_BROWSE_EUR,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_EUR,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_EUR,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_EUR,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		requireLicenseAccept = true,
		browseHasStar = true,
		browseBuyButtonText = BLIZZARD_STORE_BUY_EUR,
		confirmationButtonText = BLIZZARD_STORE_FINAL_BUY_EUR,
	},
	[CURRENCY_RUB] = {
		formatShort = currencyFormatRUB,
		formatLong = currencyFormatRUB,
		browseNotice = BLIZZARD_STORE_BROWSE_EUR,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_EUR,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_EUR,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_RUB,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		requireLicenseAccept = true,
		browseHasStar = true,
		browseBuyButtonText = BLIZZARD_STORE_BUY_EUR,
		confirmationButtonText = BLIZZARD_STORE_FINAL_BUY_EUR,
	},
	[CURRENCY_ARS] = {
		formatShort = currencyFormatARS,
		formatLong = currencyFormatARS,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_ARS,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_CLP] = {
		formatShort = currencyFormatCLP,
		formatLong = currencyFormatCLP,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_CLP,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_MXN] = {
		formatShort = currencyFormatMXN,
		formatLong = currencyFormatMXN,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_MXN,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_BRL] = {
		formatShort = currencyFormatBRL,
		formatLong = currencyFormatBRL,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_BRL,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_AUD] = {
		formatShort = currencyFormatAUD,
		formatLong = currencyFormatAUD,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_AUD,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
	},
	[CURRENCY_CPT] = {
		formatShort = currencyFormatRawStar,
		formatLong = currencyFormatCPTLong,
		browseNotice = BLIZZARD_STORE_BROWSE_BATTLE_COINS_CN,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_CN,
		paymentMethodText = "",
		paymentMethodSubtext = "",
		hideConfirmationBrowseNotice = true,
		browseHasStar = false,
	},
	[CURRENCY_TPT] = {
		formatShort = currencyFormatTPT,
		formatLong = currencyFormatTPT,
		browseNotice = "",
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_TW,
		paymentMethodText = "",
		paymentMethodSubtext = "",
		browseHasStar = false,
	},
	[CURRENCY_BETA] = {
		formatShort = currencyFormatBeta,
		formatLong = currencyFormatBeta,
		browseNotice = BLIZZARD_STORE_BROWSE_TEST_CURRENCY,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_TEST,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_TEST,
		paymentMethodText = BLIZZARD_STORE_CONFIRMATION_TEST,
		paymentMethodSubtext = "",
		browseHasStar = true,
	},
};

local function currencyInfo()
	local currency = C_PurchaseAPI.GetCurrencyID();
	local info = currencySpecific[currency];
	return info;
end

--Error message data
local errorData = {
	[LE_STORE_ERROR_INVALID_PAYMENT_METHOD] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PAYMENT,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PAYMENT,
		link = 11,
	},
	[LE_STORE_ERROR_PAYMENT_FAILED] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PAYMENT,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PAYMENT,
		link = 11,
	},
	[LE_STORE_ERROR_WRONG_CURRENCY] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PAYMENT,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PAYMENT,
		link = 11,
	},
	[LE_STORE_ERROR_BATTLEPAY_DISABLED] = {
		title = BLIZZARD_STORE_ERROR_TITLE_BATTLEPAY_DISABLED,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_BATTLEPAY_DISABLED,
	},
	[LE_STORE_ERROR_INSUFFICIENT_BALANCE] = {
		title = BLIZZARD_STORE_ERROR_TITLE_INSUFFICIENT_BALANCE,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_INSUFFICIENT_BALANCE,
		link = 11,
	},
	[LE_STORE_ERROR_OTHER] = {
		title = BLIZZARD_STORE_ERROR_TITLE_OTHER,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_OTHER,
	},
	[LE_STORE_ERROR_ALREADY_OWNED] = {
		title = BLIZZARD_STORE_ERROR_TITLE_ALREADY_OWNED,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_ALREADY_OWNED,
	},
	[LE_STORE_ERROR_PARENTAL_CONTROLS_NO_PURCHASE] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PARENTAL_CONTROLS,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PARENTAL_CONTROLS,
	},
	[LE_STORE_ERROR_PURCHASE_DENIED] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PURCHASE_DENIED,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PURCHASE_DENIED,
	}	
};

local tooltipSides = {};

--Code
local function getIndex(tbl, value)
	for k, v in pairs(tbl) do
		if ( v == value ) then
			return k;
		end
	end
end

function StoreFrame_UpdateCard(card,entryID,discountReset)
	local productID, _, bannerType, alreadyOwned, normalDollars, normalCents, currentDollars, currentCents, buyableHere, name, description, displayID, texture, upgrade = C_PurchaseAPI.GetEntryInfo(entryID);
	StoreProductCard_ResetCornerPieces(card);

	local info = currencyInfo();

	if (not info) then 
		card:Hide(); 
		return;
	end

	local currencyFormat;
	if (StoreProductCard_IsSplashPage(card)) then
		currencyFormat = info.formatLong;
	else
		currencyFormat = info.formatShort;
	end

	local discountAmount, new, hot;
	local discount = false;

	if (currentDollars ~= normalDollars or currentCents ~= normalCents) then
		local normalPrice = normalDollars + (normalCents/100);
		local discountPrice = currentDollars + (currentCents/100);
		local diff = normalPrice - discountPrice;
		discountAmount = math.floor((diff/normalPrice) * 100);
		discount = true;
	end

	card.Checkmark:Hide();
	if (card.NewTexture) then
		card.NewTexture:Hide();
	end

	if (card.HotTexture) then
		card.HotTexture:Hide();
	end

	if (card.DiscountMiddle) then
		card.DiscountLeft:Hide();
		card.DiscountMiddle:Hide();
		card.DiscountRight:Hide();
		card.DiscountText:Hide();
	end

	if ( alreadyOwned ) then
		card.Checkmark:Show();
	elseif ( card.NewTexture and new ) then
		card.NewTexture:Show();
	elseif ( card.HotTexture and hot ) then
		card.HotTexture:Show();
	elseif ( card.DiscountMiddle and discountAmount ) then
		card.DiscountText:SetText(BLIZZARD_STORE_DISCOUNT_TEXT_FORMAT:format(discountAmount));

		local stringWidth = card.DiscountText:GetStringWidth();
		card.DiscountLeft:SetPoint("RIGHT", card.DiscountRight, "LEFT", -stringWidth, 0);
		card.DiscountMiddle:Show();
		card.DiscountLeft:Show();
		card.DiscountRight:Show();
		card.DiscountText:Show();
	end

	if (upgrade) then
		card.UpgradeArrow:Show();
	else
		card.UpgradeArrow:Hide();
	end

	if (card.BuyButton) then
		local text = BLIZZARD_STORE_BUY;
		if (info.browseBuyButtonText) then
			text = info.browseBuyButtonText;
		end
		card.BuyButton:SetText(text);
	end
	
	card.CurrentPrice:SetText(currencyFormat(currentDollars, currentCents));

	if ( card.SplashBannerText ) then
		if ( bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_NEW ) then
			card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_NEW);
		elseif ( bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_DISCOUNT ) then
			if ( discount ) then
				card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_DISCOUNT_FORMAT:format(discountAmount));
			else
				card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FEATURED);
			end
		elseif ( bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_FEATURED ) then
			card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FEATURED);
		end
	end 

	card.NormalPrice:SetText(currencyFormat(normalDollars, normalCents));
	card.ProductName:SetText(name);
	
	if (card.Description) then
		card.Description:SetText(description);
	end

	if ( displayID ) then
		StoreProductCard_SetModel(card, displayID, alreadyOwned);
	else
		local icon = texture;
		if (not icon) then
			icon = "Interface\\Icons\\INV_Misc_Note_02";
		end
		StoreProductCard_ShowIcon(card, icon);
	end

	if (discount) then
		StoreProductCard_ShowDiscount(card, currencyFormat(currentDollars, currentCents), discountReset);
	else
		card.NormalPrice:Hide();
		card.SalePrice:Hide();
		card.Strikethrough:Hide();
		card.CurrentPrice:Show();
	end

	if (card.BuyButton) then
		card.BuyButton:SetEnabled(buyableHere);
	else
		card.Card:SetDesaturated(not buyableHere);
	end

	card:SetID(entryID);
	StoreProductCard_UpdateState(card);

	if (card.BannerFadeIn and not card:IsShown()) then
		card.BannerFadeIn.FadeAnim:Play();
		card.BannerFadeIn:Show();
	end
	
	card:Show();
end

function StoreFrame_CheckAndUpdateEntryID(isSplash, isThreeSplash)
	local products = C_PurchaseAPI.GetProducts(selectedCategoryID);

	if (isSplash and isThreeSplash) then
		if (selectedEntryID ~= products[1] and selectedEntryID ~= products[2] and selectedEntryID ~= products[3]) then
			selectedEntryID = nil;
		end
	elseif (not isSplash) then
		local found = false;
		for i=1, NUM_STORE_PRODUCT_CARDS do
			local entryID = products[i + NUM_STORE_PRODUCT_CARDS * (selectedPageNum - 1)];
			if ( entryID and selectedEntryID == entryID) then
				found = true;
				break;
			elseif ( not entryID ) then
				break;
			end
		end
		if (not found) then
			selectedEntryID = nil;
		end
	end
end

function StoreFrame_SetSplashCategory()
	local id = selectedCategoryID;
	local self = StoreFrame;

	local info = currencyInfo();

	if ( not info ) then
		return;
	end
	
	for i = 1, NUM_STORE_PRODUCT_CARDS do
		local card = self.ProductCards[i];
		card:Hide();
	end

	local currencyFormat = info.formatShort;
	self.Notice:Hide();

	local products = C_PurchaseAPI.GetProducts(id);

	local isThreeSplash = #products >= 3;

	StoreFrame_CheckAndUpdateEntryID(true, isThreeSplash);

	if (isThreeSplash) then
		self.SplashSingle:Hide();
		StoreFrame_UpdateCard(self.SplashPrimary, products[1]);
		StoreFrame_UpdateCard(self.SplashSecondary1, products[2]);
		StoreFrame_UpdateCard(self.SplashSecondary2, products[3]);
	else
		self.SplashPrimary:Hide();
		self.SplashSecondary1:Hide();
		self.SplashSecondary2:Hide();
		selectedEntryID = products[1]; -- This is the only card here so just auto select it so the buy button works
		StoreFrame_UpdateCard(self.SplashSingle, products[1]);
	end

	StoreFrame_UpdateBuyButton();
	
	self.PageText:Hide();
	self.NextPageButton:Hide();
	self.PrevPageButton:Hide();
end

function StoreFrame_SetNormalCategory()
	local id = selectedCategoryID;
	local self = StoreFrame;
	local pageNum = selectedPageNum;
	
	local info = currencyInfo();

	if ( not info ) then
		return;
	end

	StoreFrame_CheckAndUpdateEntryID(false);

	self.SplashSingle:Hide();
	self.SplashPrimary:Hide();
	self.SplashSecondary1:Hide();
	self.SplashSecondary2:Hide();

	local currencyFormat = info.formatShort;

	local products = C_PurchaseAPI.GetProducts(id);
	local numTotal = #products;

	for i=1, NUM_STORE_PRODUCT_CARDS do
		local card = self.ProductCards[i];
		local entryID = products[i + NUM_STORE_PRODUCT_CARDS * (pageNum - 1)];
		if ( not entryID ) then
			card:Hide();
		else
			StoreFrame_UpdateCard(card, entryID);
		end
	end

	if ( #products > NUM_STORE_PRODUCT_CARDS ) then
		-- 10, 10/8 = 1, 2 remain 
		local numPages = math.ceil(#products / NUM_STORE_PRODUCT_CARDS);
		self.PageText:SetText(BLIZZARD_STORE_PAGE_NUMBER:format(pageNum,numPages));
		self.PageText:Show();
		self.NextPageButton:Show();
		self.PrevPageButton:Show();
		self.PrevPageButton:SetEnabled(pageNum ~= 1);
		self.NextPageButton:SetEnabled(pageNum ~= numPages);
	else
		self.PageText:Hide();
		self.NextPageButton:Hide();
		self.PrevPageButton:Hide();
	end

	StoreFrame_UpdateBuyButton();
end

function StoreFrame_SetCategory()
	if (select(5, C_PurchaseAPI.GetProductGroupInfo(selectedCategoryID)) == BATTLEPAY_GROUP_DISPLAY_SPLASH) then
		StoreFrame_SetSplashCategory();
	else
		StoreFrame_SetNormalCategory();
	end
end

function StoreFrame_CreateCards(self, num, numPerRow)
	for i=1, num do
		local card = self.ProductCards[i];
		if ( not card ) then
			card = CreateForbiddenFrame("Button", nil, self, "StoreProductCardTemplate");
			
			StoreProductCard_OnLoad(card);
			self.ProductCards[i] = card;

			if ( i % numPerRow == 1 ) then
				card:SetPoint("TOP", self.ProductCards[i - numPerRow], "BOTTOM", 0, 0);
			else
				card:SetPoint("TOPLEFT", self.ProductCards[i - 1], "TOPRIGHT", 0, 0);
			end

			if ((i % numPerRow) == 0) then
				tooltipSides[card] = "LEFT";
			else
				tooltipSides[card] = "RIGHT";
			end

			card:SetScript("OnEnter", StoreProductCard_OnEnter);
			card:SetScript("OnLeave", StoreProductCard_OnLeave);
			card:SetScript("OnClick", StoreProductCard_OnClick);
			card:SetScript("OnDragStart", StoreProductCard_OnDragStart);
			card:SetScript("OnDragStop", StoreProductCard_OnDragStop);
		end
	end
end

function StoreFrame_UpdateCategories(self)
	local categories = C_PurchaseAPI.GetProductGroups();

	for i=1, #categories do
		local frame = self.CategoryFrames[i];
		local groupID = categories[i];
		if ( not frame ) then
			frame = CreateForbiddenFrame("Button", nil, self, "StoreCategoryTemplate");

			frame:SetScript("OnEnter", StoreCategory_OnEnter);
			frame:SetScript("OnLeave", StoreCategory_OnLeave);
			frame:SetScript("OnClick", StoreCategory_OnClick);
			frame:SetPoint("TOPLEFT", self.CategoryFrames[i - 1], "BOTTOMLEFT", 0, 0);

			self.CategoryFrames[i] = frame;
		end

		frame:SetID(groupID);
		local _, name, _, texture = C_PurchaseAPI.GetProductGroupInfo(groupID);
		frame.Icon:SetTexture(texture);
		frame.Text:SetText(name);
		frame.SelectedTexture:SetShown(selectedCategoryID == groupID);
		frame:SetEnabled(selectedCategoryID ~= groupID);
		frame:Show();
	end

	self.BrowseNotice:ClearAllPoints();
	self.BrowseNotice:SetPoint("TOP", self.CategoryFrames[#categories], "BOTTOM", 0, -15);

	for i=#categories + 1, #self.CategoryFrames do
		self.CategoryFrames[i]:Hide();
	end
end

function StoreFrame_OnLoad(self)
	self:RegisterEvent("STORE_PRODUCTS_UPDATED");
	self:RegisterEvent("STORE_PURCHASE_LIST_UPDATED");
	self:RegisterEvent("PRODUCT_DISTRIBUTIONS_UPDATED");
	self:RegisterEvent("BAG_UPDATE_DELAYED"); --Used for showing the panel when all bags are full
	self:RegisterEvent("STORE_PURCHASE_ERROR");
	self:RegisterEvent("STORE_ORDER_INITIATION_FAILED");
	self:RegisterEvent("AUTH_CHALLENGE_FINISHED");

	-- We have to call this from CharacterSelect on the glue screen because the addon engine will load
	-- the store addon more than once if we try to make it ondemand, forcing us to load it before we
	-- have a connection.
	if (not IsOnGlueScreen()) then
		C_PurchaseAPI.GetPurchaseList();
	end
	
	self.TitleText:SetText(BLIZZARD_STORE);
	
	SetPortraitToTexture(self.portrait, "Interface\\Icons\\WoW_Store");
	StoreFrame_UpdateBuyButton();

	if ( IsOnGlueScreen() ) then
		self:SetFrameStrata("FULLSCREEN_DIALOG");
		-- block keys
		self:EnableKeyboard(true);
		self:SetScript("OnKeyDown",
			function(self, key)
				if ( key == "ESCAPE" ) then
					if ( _G.ModelPreviewFrame:IsShown() ) then
						_G.ModelPreviewFrame:Hide();
					else
						StoreFrame:SetAttribute("action", "EscapePressed");
					end
				end
			end
		);
		-- block other clicks
		local bgFrame = CreateForbiddenFrame("FRAME", nil);
		bgFrame:SetParent(self);
		bgFrame:SetAllPoints(_G.GlueParent);
		bgFrame:SetFrameStrata("DIALOG");
		bgFrame:EnableMouse(true);
		-- background texture
		local background = bgFrame:CreateTexture(nil, "BACKGROUND");
		background:SetAllPoints(_G.GlueParent);
		background:SetTexture(0, 0, 0, 0.75);
	end
	self:SetPoint("CENTER", nil, "CENTER", 0, 20); --Intentionally not anchored to UIParent.

	StoreFrame_CreateCards(self, NUM_STORE_PRODUCT_CARDS, NUM_STORE_PRODUCT_CARDS_PER_ROW);

	StoreFrame.SplashSingle:Hide();
	StoreFrame.SplashPrimary:Hide();
	StoreFrame.SplashSecondary1:Hide();
	StoreFrame.SplashSecondary2:Hide();
	
	-- Single and primary are only used for the checkmark tooltip
	tooltipSides[StoreFrame.SplashSingle] = "RIGHT";
	tooltipSides[StoreFrame.SplashPrimary] = "RIGHT";
	tooltipSides[StoreFrame.SplashSecondary1] = "RIGHT";
	tooltipSides[StoreFrame.SplashSecondary2] = "LEFT";

	StoreFrame.SplashSingle.SplashBannerText:SetShadowColor(0, 0, 0, 0);
	StoreFrame.SplashPrimary.SplashBannerText:SetShadowColor(0, 0, 0, 0);
	StoreFrame.SplashPrimary.Description:SetSpacing(5);
	StoreFrame.Notice.Description:SetSpacing(5);
	StoreFrame_UpdateActivePanel(self);

	--Check whether we already have an error waiting for us.
	local errorID, internalErr = C_PurchaseAPI.GetFailureInfo();
	if ( errorID ) then
		StoreFrame_OnError(self, errorID, true, internalErr);
	end
end

local JustFinishedOrdering = false;

function StoreFrame_OnEvent(self, event, ...)
	if ( event == "STORE_PRODUCTS_UPDATED" ) then
		local productGroups = C_PurchaseAPI.GetProductGroups();
		local found = false;
		for i=1,#productGroups do
			if (productGroups[i] == selectedCategoryID) then
				found = true;
				break;
			end
		end
		if ( not found or not selectedCategoryID ) then
			selectedCategoryID = productGroups[1];
		end
		StoreFrame_UpdateCategories(self);
		if (selectedCategoryID) then
			--FIXME - Not the right place to put this check, but I want to stop the error
			StoreFrame_SetCategory();
		end
		StoreFrame_UpdateActivePanel(self);
	elseif ( event == "STORE_PURCHASE_LIST_UPDATED" ) then
		if (JustOrderedProduct) then
			JustFinishedOrdering = true;
		end
		JustOrderedProduct = false;
		StoreFrame_UpdateActivePanel(self);
	elseif ( self:IsShown() and event == "BAG_UPDATE_DELAYED" ) then
		StoreFrame_UpdateActivePanel(self);
	elseif ( event == "STORE_PURCHASE_ERROR" ) then
		local err, internalErr = C_PurchaseAPI.GetFailureInfo();
		StoreFrame_OnError(self, err, true, internalErr);
	elseif ( event == "STORE_ORDER_INITIATION_FAILED" ) then
		local err, internalErr = ...;
		WaitingOnConfirmation = false;
		StoreFrame_OnError(self, err, false, internalErr);
		StoreFrame_UpdateActivePanel(self);
	elseif ( event == "PRODUCT_DISTRIBUTIONS_UPDATED" ) then
		if (C_SharedCharacterServices.IsPurchaseIDPendingUpgrade() and self:IsShown() and StoreStateDriverFrame.NoticeTextTimer:IsPlaying()) then
			if (IsOnGlueScreen()) then
				self:Hide();
				_G.CharacterUpgradeFlow:SetTarget(false);
				_G.CharSelectServicesFlowFrame:Show();
				_G.CharacterServicesMaster_SetFlow(_G.CharacterServicesMaster, _G.CharacterUpgradeFlow);
			else
				self:Hide();
				ServicesLogoutPopup.Background.Title:SetText(CHARACTER_UPGRADE_READY);
				ServicesLogoutPopup.Background.Description:SetText(CHARACTER_UPGRADE_READY_DESCRIPTION);
				ServicesLogoutPopup:Show();
			end
		end
	elseif ( event == "AUTH_CHALLENGE_FINISHED" ) then
		if (not C_AuthChallenge.DidChallengeSucceed()) then
			JustOrderedProduct = false;
		else
			StoreStateDriverFrame.NoticeTextTimer:Play();
		end
	end
end

function StoreFrame_OnShow(self)
	JustFinishedOrdering = false;
	C_PurchaseAPI.GetProductList();
	self:SetAttribute("isshown", true);
	StoreFrame_UpdateActivePanel(self);
	if ( not IsOnGlueScreen() ) then
		Outbound.UpdateMicroButtons();
	end

	StoreFrame_UpdateCoverState();
	PlaySound("UI_igStore_WindowOpen_Button");
end

function StoreFrame_UpdateBuyButton()
	local self = StoreFrame;
	local info = currencyInfo();

	if (not info) then
		return;
	end

	if (StoreFrame.SplashSingle:IsShown()) then
		self.BuyButton:Hide();
	else
		self.BuyButton:Show();
	end

	local text = BLIZZARD_STORE_BUY;
	if (info.browseBuyButtonText) then
		text = info.browseBuyButtonText;
	end
	self.BuyButton:SetText(text);
		
	if (not selectedEntryID) then
		self.BuyButton:SetEnabled(false);
		return;
	end

	if ( not self.BuyButton:IsEnabled() ) then
		self.BuyButton:SetEnabled(true);
		if ( self.BuyButton:IsVisible() ) then
			self.BuyButton.PulseAnim:Play();
		end
	end
end

function StoreFrame_UpdateCoverState()
	local self = StoreFrame;
	if (StoreConfirmationFrame and StoreConfirmationFrame:IsShown() ) then
		self.Cover:Show();
	elseif (self.Notice:IsShown()) then
		self.Cover:Show();
	elseif (self.PurchaseSentFrame:IsShown()) then
		self.Cover:Show();
	elseif (self.ErrorFrame:IsShown()) then
		self.Cover:Show();
	elseif (self:GetAttribute("previewframeshown")) then
		self.Cover:Show();
	else
		self.Cover:Hide();
	end
end

function StoreFrame_OnAttributeChanged(self, name, value)
	--Note - Setting attributes is how the external UI should communicate with this frame. That way, their taint won't be spread to this code.
	if ( name == "action" ) then
		if ( value == "Show" ) then
			self:Show();
		elseif ( value == "Hide" ) then
			self:Hide();
		elseif ( value == "EscapePressed" ) then
			local handled = false;
			if ( self:IsShown() ) then
				if ( self.ErrorFrame:IsShown() or StoreConfirmationFrame:IsShown() ) then
					--We eat the click, but don't close anything. Make them explicitly press "Cancel".
					handled = true;
				else
					self:Hide();
					handled = true;
				end
			elseif (ServicesLogoutPopup:IsShown()) then
				ServicesLogoutPopup:Hide();
				handled = true;
			end
			self:SetAttribute("escaperesult", handled);
		end
	elseif ( name == "previewframeshown" ) then
		StoreFrame_UpdateCoverState();
	end
end

function StoreFrame_OnError(self, errorID, needsAck, internalErr)
	local info = errorData[errorID];
	if ( not info ) then
		info = errorData[LE_STORE_ERROR_OTHER];
	end
	if ( IsGMClient() ) then
		StoreFrame_ShowError(self, info.title.." ("..internalErr..")", info.msg, info.link, needsAck);
	else
		StoreFrame_ShowError(self, info.title, info.msg, info.link, needsAck);
	end
end

function StoreFrame_UpdateActivePanel(self)
	if (StoreFrame.ErrorFrame:IsShown()) then
		StoreFrame_HideAlert(self);
		StoreFrame_HidePurchaseSent(self);
	elseif ( WaitingOnConfirmation ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_CONNECTING, BLIZZARD_STORE_PLEASE_WAIT);
	elseif ( JustOrderedProduct or C_PurchaseAPI.HasPurchaseInProgress() ) then
		local progressText;
		if (StoreStateDriverFrame.NoticeTextTimer:IsPlaying()) then --Even if we don't have every list, if we know we have something in progress, we can display that.
			progressText = BLIZZARD_STORE_PROCESSING
		else
			progressText = BLIZZARD_STORE_CHECK_BACK_LATER
		end
		StoreFrame_SetAlert(self, BLIZZARD_STORE_TRANSACTION_IN_PROGRESS, progressText);
	elseif ( JustFinishedOrdering ) then
		JustFinishedOrdering = false;
		StoreFrame_HideAlert(self);
		StoreFrame_ShowPurchaseSent(self);
	elseif ( not C_PurchaseAPI.IsAvailable() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_NOT_AVAILABLE, BLIZZARD_STORE_NOT_AVAILABLE_SUBTEXT);
	elseif ( C_PurchaseAPI.IsRegionLocked() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_REGION_LOCKED, BLIZZARD_STORE_REGION_LOCKED_SUBTEXT);
	elseif ( not C_PurchaseAPI.HasPurchaseList() or not C_PurchaseAPI.HasProductList() or not C_PurchaseAPI.HasDistributionList() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_LOADING, BLIZZARD_STORE_PLEASE_WAIT);
	elseif ( #C_PurchaseAPI.GetProductGroups() == 0 ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_NO_ITEMS, BLIZZARD_STORE_CHECK_BACK_LATER);
	elseif ( not IsOnGlueScreen() and not StoreFrame_HasFreeBagSlots() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_BAG_FULL, BLIZZARD_STORE_BAG_FULL_DESC);
	elseif ( not currencyInfo() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_INTERNAL_ERROR, BLIZZARD_STORE_INTERNAL_ERROR_SUBTEXT);
	else
		StoreFrame_HideAlert(self);
		StoreFrame_HidePurchaseSent(self);
		local info = currencyInfo();
		self.BrowseNotice:SetText(info.browseNotice);
	end
end

function StoreFrame_SetAlert(self, title, desc)
	self.Notice.Title:SetText(title);
	self.Notice.Description:SetText(desc);
	self.Notice:Show();

	if ( StoreConfirmationFrame ) then
		StoreConfirmationFrame:Raise(); --Make sure the confirmation is above this alert frame.
	end
end

function StoreFrame_HideAlert(self)
	self.Notice:Hide();
end

function StoreFrame_ShowPurchaseSent(self)
	self.PurchaseSentFrame.Title:SetText(BLIZZARD_STORE_PURCHASE_SENT);
	self.PurchaseSentFrame.OkayButton:SetText(OKAY);

	self.PurchaseSentFrame:Show();

	if ( StoreConfirmationFrame ) then
		StoreConfirmationFrame:Raise();
	end
end

function StoreFrame_HidePurchaseSent(self)
	self.PurchaseSentFrame:Hide();
end

function StoreFramePurchaseSentOkayButton_OnClick(self)
	StoreFrame_HidePurchaseSent(StoreFrame);
end

local ActiveURLIndex = nil;
local ErrorNeedsAck = nil;
function StoreFrame_ShowError(self, title, desc, urlIndex, needsAck)
	local height = 180;
	self.ErrorFrame.Title:SetText(title);
	self.ErrorFrame.Description:SetText(desc);
	self.ErrorFrame.AcceptButton:SetText(OKAY);
	height = height + self.ErrorFrame.Description:GetHeight() + self.ErrorFrame.Title:GetHeight();

	if ( urlIndex ) then
		self.ErrorFrame.AcceptButton:ClearAllPoints();
		self.ErrorFrame.AcceptButton:SetPoint("BOTTOMRIGHT", self.ErrorFrame, "BOTTOM", -10, 20);
		self.ErrorFrame.WebsiteButton:ClearAllPoints();
		self.ErrorFrame.WebsiteButton:SetPoint("BOTTOMLEFT", self.ErrorFrame, "BOTTOM", 10, 20);
		self.ErrorFrame.WebsiteButton:Show();
		self.ErrorFrame.WebsiteButton:SetText(BLIZZARD_STORE_VISIT_WEBSITE);
		self.ErrorFrame.WebsiteWarning:Show();
		self.ErrorFrame.WebsiteWarning:SetText(BLIZZARD_STORE_VISIT_WEBSITE_WARNING);
		height = height + self.ErrorFrame.WebsiteWarning:GetHeight() + 8;
		ActiveURLIndex = urlIndex;
	else
		self.ErrorFrame.AcceptButton:ClearAllPoints();
		self.ErrorFrame.AcceptButton:SetPoint("BOTTOM", self.ErrorFrame, "BOTTOM", 0, 20);
		self.ErrorFrame.WebsiteButton:Hide();
		self.ErrorFrame.WebsiteWarning:Hide();
		ActiveURLIndex = nil;
	end
	ErrorNeedsAck = needsAck;

	self.ErrorFrame:Show();
	self.ErrorFrame:SetHeight(height);

	if ( StoreConfirmationFrame ) then
		StoreConfirmationFrame:Raise(); --Make sure the confirmation is above this error frame.
	end
end

function StoreFrameErrorFrame_OnShow(self)
	StoreFrame_UpdateActivePanel(StoreFrame);
	StoreFrame_UpdateCoverState();
	self:SetFrameLevel(self:GetParent():GetFrameLevel()+4);
end

function StoreFrameErrorFrame_OnHide(self)
	StoreFrame_UpdateCoverState();
	StoreFrame_UpdateActivePanel(StoreFrame);
end

function StoreFrameErrorAcceptButton_OnClick(self)
	if ( ErrorNeedsAck ) then
		C_PurchaseAPI.AckFailure();
	end
	StoreFrame.ErrorFrame:Hide();
	PlaySound("UI_igStore_PageNav_Button");
end

function StoreFrameErrorWebsiteButton_OnClick(self)
	LoadURLIndex(ActiveURLIndex);
end

function StoreFrameCloseButton_OnClick(self)
	StoreFrame:Hide();
end

function StoreFrameBuyButton_OnClick(self)
	local entryID = selectedEntryID
	StoreFrame_BeginPurchase(entryID);
	PlaySound("UI_igStore_Buy_Button");
end

function StoreFrame_BeginPurchase(entryID)
	local productID, _, _, alreadyOwned = C_PurchaseAPI.GetEntryInfo(entryID);
	if ( alreadyOwned ) then
		StoreFrame_OnError(StoreFrame, LE_STORE_ERROR_ALREADY_OWNED, false, "FakeOwned");
	elseif ( C_PurchaseAPI.PurchaseProduct(productID) ) then
		WaitingOnConfirmation = true;
		WaitingOnConfirmationTime = GetTime();
		StoreFrame_UpdateActivePanel(StoreFrame);
	end
end

function StoreFrame_HasFreeBagSlots()
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local freeSlots, bagFamily = GetContainerNumFreeSlots(i);
		if ( freeSlots > 0 and bagFamily == 0 ) then
			return true;
		end
	end
	return false;
end

function StoreFrame_ShowPreview(name, modelID)
	Outbound.ShowPreview(name, modelID);
	StoreProductCard_UpdateAllStates();
end

function StoreFramePrevPageButton_OnClick(self)
	selectedPageNum = selectedPageNum - 1;
	selectedEntryID = nil;
	StoreFrame_SetCategory();

	PlaySound("UI_igStore_PageNav_Button");
end

function StoreFrameNextPageButton_OnClick(self)
	selectedPageNum = selectedPageNum + 1;
	selectedEntryID = nil;
	StoreFrame_SetCategory();

	PlaySound("UI_igStore_PageNav_Button");
end

local ConfirmationFrameHeight = 556;
local ConfirmationFrameMiddleHeight = 200;
local ConfirmationFrameHeightEur = 596;
local ConfirmationFrameMiddleHeightEur = 240;

------------------------------------------
function StoreConfirmationFrame_OnLoad(self)
	self.ProductName:SetTextColor(0, 0, 0);
	self.ProductName:SetShadowColor(0, 0, 0, 0);

	self.Title:SetText(BLIZZARD_STORE_CONFIRMATION_TITLE);
	self.TotalLabel:SetText(BLIZZARD_STORE_FINAL_PRICE_LABEL);

	self.LicenseAcceptText:SetTextColor(0.8, 0.8, 0.8);

	self.NoticeFrame.Notice:SetSpacing(6);

	self:RegisterEvent("STORE_CONFIRM_PURCHASE");
end

function StoreConfirmationFrame_SetNotice(self, icon, name, dollars, cents, walletName, upgrade)
	local currency = C_PurchaseAPI.GetCurrencyID();
	local middleHeight = ConfirmationFrameMiddleHeight;
	local frameHeight = ConfirmationFrameHeight;

	if (currency == CURRENCY_EUR or currency == CURRENCY_RUB or currency == CURRENCY_GBP or currency == CURRENCY_BRL) then
		middleHeight = ConfirmationFrameMiddleHeightEur;
		frameHeight = ConfirmationFrameHeightEur;
	else
		middleHeight = ConfirmationFrameMiddleHeight;
		frameHeight = ConfirmationFrameHeight;
	end

	self:SetHeight(frameHeight);

	self.ParchmentMiddle:SetHeight(middleHeight);
	SetPortraitToTexture(self.Icon, icon);

	self.ProductName:SetText(name);
	self.NoticeFrame.Notice:ClearAllPoints();
	self.NoticeFrame.Notice:SetPoint("TOP", 0, 100);
	local info = currencyInfo();
	local format = info.formatLong;
	local notice;
	
	if (upgrade) then
		notice = info.servicesConfirmationNotice;
	else
		notice = info.confirmationNotice;
	end

	if (not walletName or walletName == "") then
		walletName = BLIZZARD_STORE_BATTLE_NET_BALANCE;
	end
	if (walletName) then
		notice = notice .. "\n\n" .. BLIZZARD_STORE_WALLET_INFO:format(walletName);
	end
	if (upgrade) then
		self.UpgradeArrow:Show();
	else
		self.UpgradeArrow:Hide();
	end
	self.NoticeFrame.Notice:SetText(notice);
	self.NoticeFrame:Show();
	self.Price:SetText(format(dollars, cents));

	self:ClearAllPoints();
	self:SetPoint("CENTER", 0, 18);
end

function StoreConfirmationFrame_OnEvent(self, event, ...)
	if ( event == "STORE_CONFIRM_PURCHASE" ) then
		WaitingOnConfirmation = false;
		StoreFrame_UpdateActivePanel(StoreFrame);
		if ( StoreFrame:IsShown() ) then
			StoreConfirmationFrame_Update(self);
			self:Raise();
		else
			C_PurchaseAPI.PurchaseProductConfirm(false);
		end
	end
end

function StoreConfirmationFrame_OnShow(self)
	StoreFrame_UpdateCoverState();
	self:Raise();
end

function StoreConfirmationFrame_OnHide(self)
	if (not JustOrderedProduct) then
		StoreConfirmationFrame_Cancel();
	end
	StoreFrame_UpdateCoverState();
end

local FinalPriceDollars;
local FinalPriceCents;
function StoreConfirmationFrame_Update(self)
	local productID, walletName = C_PurchaseAPI.GetConfirmationInfo();
	if ( not productID ) then
		self:Hide(); --May want to show an error message
		return;
	end
	local _, _, _, currentDollars, currentCents, _, name, _, displayID, texture, upgrade = C_PurchaseAPI.GetProductInfo(productID);

	local finalIcon = texture;
	if ( not finalIcon ) then
		finalIcon = "Interface\\Icons\\INV_Misc_Note_02";
	end
	StoreConfirmationFrame_SetNotice(self, finalIcon, name, currentDollars, currentCents, walletName, upgrade);

	local info = currencyInfo();
	self.BrowseNotice:SetText(info.browseNotice);
	self.BrowseNotice:SetShown(not info.hideConfirmationBrowseNotice);

	if ( info.licenseAcceptText and info.licenseAcceptText ~= "" ) then
		self.LicenseAcceptText:SetText(info.licenseAcceptText, true);
		self.LicenseAcceptText:Show();
		if ( info.requireLicenseAccept ) then
			self.LicenseAcceptText:SetPoint("BOTTOM", 20, 60);
			self.LicenseAcceptButton:Show();
			self.LicenseAcceptButton:SetChecked(false);
			self.BuyButton:Disable();
		else
			self.LicenseAcceptText:SetPoint("BOTTOM", 0, 60);
			self.LicenseAcceptButton:Hide();
			self.BuyButton:Enable();
		end
	else
		self.LicenseAcceptText:Hide();
		self.LicenseAcceptButton:Hide();
		self.BuyButton:Enable();
	end

	local text = BLIZZARD_STORE_FINAL_BUY;
	if (info.confirmationButtonText) then
		text = info.confirmationButtonText;
	end	
	self.BuyButton:SetText(text);

	FinalPriceDollars = currentDollars;
	FinalPriceCents = currentCents;

	if (self.Price:GetLeft() < self.TotalLabel:GetRight()) then
		self.Price:SetFontObject("GameFontNormalLargeOutline");
	else
		self.Price:SetFontObject("GameFontNormalShadowHuge2");
	end

	self:Show();
end

function StoreConfirmationFrame_Cancel(self)
	C_PurchaseAPI.PurchaseProductConfirm(false);
	StoreConfirmationFrame:Hide();

	PlaySound("UI_igStore_Cancel_Button");
end

function StoreConfirmationFinalBuy_OnClick(self)
	-- wait a bit after window is shown so no one accidentally buys something with a lazy double-click
	if ( GetTime() - WaitingOnConfirmationTime < 0.5 ) then
		return;
	end
	
	if ( C_PurchaseAPI.PurchaseProductConfirm(true, FinalPriceDollars, FinalPriceCents) ) then
		JustOrderedProduct = true;
		StoreStateDriverFrame.NoticeTextTimer:Play();
		PlaySound("UI_igStore_ConfirmPurchase_Button");
	else
		StoreFrame_OnError(StoreFrame, LE_STORE_ERROR_OTHER, false, "Fake");
		PlaySound("UI_igStore_Cancel_Button");
	end
	StoreFrame_UpdateActivePanel(StoreFrame);
	StoreConfirmationFrame:Hide();
end

-------------------------------
local isRotating = false;

function StoreProductCard_UpdateState(card)
	-- No product associated with this card
	if (card:GetID() == 0 or not card:IsShown()) then return end;

	if (card.HighlightTexture) then
		local enableHighlight = card:GetID() ~= selectedEntryID and not isRotating;
		card.HighlightTexture:SetAlpha(enableHighlight and 1 or 0);
		if (not card.Description and card:IsMouseOver()) then
			if (isRotating or forceHide) then
				StoreTooltip:Hide()
			else
				local point, rpoint, xoffset;
				if (tooltipSides[card] == "LEFT") then
					point = "BOTTOMRIGHT";
					rpoint = "TOPLEFT";
					xoffset = 4;
				else
					point = "BOTTOMLEFT";
					rpoint ="TOPRIGHT";
					xoffset = -4;
				end
				local entryID = card:GetID();
				local name, description = select(10,C_PurchaseAPI.GetEntryInfo(entryID));
				
				StoreTooltip:ClearAllPoints();
				StoreTooltip:SetPoint(point, card, rpoint, xoffset, 0);
				StoreTooltip_Show(name, description);
			end
		end
	end
	if (card.Magnifier and card ~= StoreFrame.SplashSingle) then
		local enableMagnifier = not isRotating;
		card.Magnifier:SetAlpha(enableMagnifier and 1 or 0);
	end
	if ( card.SelectedTexture ) then
		card.SelectedTexture:SetShown(card:GetID() == selectedEntryID);
	end
end

function StoreProductCard_UpdateAllStates()
	for i = 1, NUM_STORE_PRODUCT_CARDS do
		local card = StoreFrame.ProductCards[i];
		StoreProductCard_UpdateState(card);
	end

	StoreProductCard_UpdateState(StoreFrame.SplashSingle);
	StoreProductCard_UpdateState(StoreFrame.SplashPrimary);
	StoreProductCard_UpdateState(StoreFrame.SplashSecondary1);
	StoreProductCard_UpdateState(StoreFrame.SplashSecondary2);
end

function StoreProductCard_OnEnter(self)
	if (self.HighlightTexture) then
		self.HighlightTexture:SetShown(selectedEntryID ~= self:GetID());
	end
	if (self.Magnifier and self.Model:IsShown() and self ~= StoreFrame.SplashSingle) then
		self.Magnifier:Show();
	end
	StoreProductCard_UpdateState(self);
end

function StoreProductCard_OnLeave(self)	
	if (self.HighlightTexture) then
		self.HighlightTexture:Hide();
	end
	if (self.Magnifier and self ~= StoreFrame.SplashSingle) then
		self.Magnifier:Hide();
	end
	StoreTooltip:Hide();
end

local function updateSelected(self, card)
	card.SelectedTexture:SetShown(card:GetID() == self:GetID());
end

function StoreProductCard_OnClick(self,button,down)
	local showPreview;
	if ( IsOnGlueScreen() ) then
		showPreview = _G.IsControlKeyDown();
	else
		showPreview = IsModifiedClick("DRESSUP");
	end
	if ( showPreview ) then
		local name, _, modelID = select(10,C_PurchaseAPI.GetEntryInfo(self:GetID()));
		if ( modelID ) then
			StoreFrame_ShowPreview(name, modelID);
		end
	else
		selectedEntryID = self:GetID();
		StoreProductCard_UpdateAllStates();

		StoreFrame_UpdateBuyButton();
		PlaySound("UI_igStore_PageNav_Button");
	end
end

local basePoints = {};

function StoreProductCard_OnLoad(self)
	-- set up data
	self.Model.maxZoom = 0.7;
	self.Model.minZoom = 0.0;
	self.Model.defaultRotation = 0.61;
	
	self.Model.rotation = self.Model.defaultRotation;
	self.Model:SetRotation(self.Model.rotation);
	self.Model:RegisterEvent("UI_SCALE_CHANGED");
	self.Model:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self.Model:SetScript("OnEvent", StoreProductCard_ModelOnEvent);

	if (not StoreProductCard_IsSplashPage(self)) then
		self.ProductName:SetSpacing(3);
	else
		self.ProductName:SetSpacing(0);
	end

	if (self.Description and self == StoreFrame.SplashSingle) then
		self.Description:SetSpacing(2);
	end

	self.CurrentPrice:SetTextColor(1.0, 0.82, 0);
	basePoints[self] = { self.NormalPrice:GetPoint() };

	self:RegisterForDrag("LeftButton");
end

function StoreProductCardModel_RotateLeft(model, rotationIncrement)
	if ( not rotationIncrement ) then
		rotationIncrement = 0.03;
	end
	model.rotation = model.rotation - rotationIncrement;
	model:SetRotation(model.rotation);
	PlaySound("igInventoryRotateCharacter");
end

function StoreProductCardModel_RotateRight(model, rotationIncrement)
	if ( not rotationIncrement ) then
		rotationIncrement = 0.03;
	end
	model.rotation = model.rotation + rotationIncrement;
	model:SetRotation(model.rotation);
	PlaySound("igInventoryRotateCharacter");
end

function StoreProductCardModel_OnUpdate(self, elapsedTime, rotationsPerSecond)
	if ( not rotationsPerSecond ) then
		rotationsPerSecond = ROTATIONS_PER_SECOND;
	end
	
	-- Mouse drag rotation
	if (self.mouseDown) then
		if ( self.rotationCursorStart ) then
			local x = GetCursorPosition();
			local diff = (x - self.rotationCursorStart) * MODELFRAME_DRAG_ROTATION_CONSTANT;
			self.rotationCursorStart = GetCursorPosition();
			self.rotation = self.rotation + diff;
			if ( self.rotation < 0 ) then
				self.rotation = self.rotation + (2 * PI);
			end
			if ( self.rotation > (2 * PI) ) then
				self.rotation = self.rotation - (2 * PI);
			end
			self:SetRotation(self.rotation, false);
		end	
	end
end

function StoreProductCard_OnDragStart(self)
	local model = self.Model;
	model.mouseDown = true;
	model.rotationCursorStart = GetCursorPosition();
	local card = model:GetParent();
	isRotating = true;
	StoreProductCard_UpdateAllStates();
end

function StoreProductCard_OnDragStop(self)
	local model = self.Model;
	model.mouseDown = false;
	local card = model:GetParent();
	isRotating = false;
	StoreProductCard_UpdateAllStates();
end

function StoreProductCard_ModelOnEvent(self, event, ...)
	self:RefreshCamera();
end

local cardModels = {}

function StoreProductCard_SetModel(self, modelID, owned)
	self.IconBorder:Hide();
	self.Icon:Hide();

	if (self.GlowSpin) then
		self.GlowSpin:Hide();
		self.GlowSpin.SpinAnim:Stop();
	end

	if (self.GlowPulse) then
		self.GlowPulse:Hide();
		self.GlowPulse.PulseAnim:Stop();
	end

	self.Model:Show();
	self.Shadows:Show();
	if (cardModels[self] ~= modelID) then
		self.Model:SetDisplayInfo(modelID);
		self.Model:SetDoBlend(false);
		self.Model:SetAnimation(0,-1);
		self.Model.rotation = self.Model.defaultRotation;
		self.Model:SetRotation(self.Model.rotation);
		self.Model:SetPosition(0, 0, 0);
		self.Model.zoomLevel = self.Model.minZoom;
		self.Model:SetPortraitZoom(self.Model.zoomLevel);
		cardModels[self] = modelID;
	end
	if ( owned ) then
		self.Checkmark:Show();
	end
	if (self == StoreFrame.SplashSingle) then
		self.Magnifier:Show();
	end
end

function StoreProductCard_ShowIcon(self, icon)
	self.Model:Hide();
	self.Shadows:Hide();
	
	if (self.Magnifier) then
		self.Magnifier:Hide();
	end

	self.IconBorder:Show();
	self.Icon:Show();

	SetPortraitToTexture(self.Icon, icon);
	if (self == StoreFrame.SplashSingle) then
		self.Magnifier:Hide();
	end

	if (self.GlowSpin) then
		self.GlowSpin.SpinAnim:Play();
		self.GlowSpin:Show();
	end

	if (self.GlowPulse) then
		self.GlowPulse.PulseAnim:Play();
		self.GlowPulse:Show();
	end
end

function StoreProductCard_IsSplashPage(card)
	return card == StoreFrame.SplashSingle or card == StoreFrame.SplashPrimary or card == StoreFrame.SplashSecondary1 or card == StoreFrame.SplashSecondary2;
end

function StoreProductCard_ShowDiscount(card, discountText)
	card.SalePrice:SetText(discountText);

	card.NormalPrice:SetTextColor(0.8, 0.66, 0);

	if (not StoreProductCard_IsSplashPage(card)) then
		local width = card.NormalPrice:GetStringWidth() + card.SalePrice:GetStringWidth();
		
		if ((width + 20 + (card:GetWidth()/8)) > card:GetWidth()) then
			card.NormalPrice:ClearAllPoints();
			card.NormalPrice:SetPoint(unpack(basePoints[card]));
			card.SalePrice:ClearAllPoints();
			card.SalePrice:SetPoint("TOP", card.NormalPrice, "BOTTOM", 0, -4);
		else
			local diff = card.NormalPrice:GetStringWidth() - card.SalePrice:GetStringWidth();
			local _, _, _, _, yOffset = unpack(basePoints[card]);
			card.NormalPrice:ClearAllPoints();
			card.NormalPrice:SetJustifyH("RIGHT");
			card.NormalPrice:SetPoint("BOTTOMRIGHT", card, "BOTTOM", diff/2, yOffset);
			card.SalePrice:ClearAllPoints();
			card.SalePrice:SetJustifyH("LEFT");
			card.SalePrice:SetPoint("BOTTOMLEFT", card.NormalPrice, "BOTTOMRIGHT", 4, 0);
		end
	elseif (card ~= StoreFrame.SplashSingle and card ~= StoreFrame.SplashPrimary) then
		local width = card.NormalPrice:GetStringWidth() + card.SalePrice:GetStringWidth();
		
		if ((width + 120 + (card:GetWidth()/8)) > card:GetWidth()) then
			card.SalePrice:ClearAllPoints();
			card.SalePrice:SetPoint("TOPLEFT", card.NormalPrice, "BOTTOMLEFT", 0, -4);
		else
			card.SalePrice:ClearAllPoints();
			card.SalePrice:SetPoint("BOTTOMLEFT", card.NormalPrice, "BOTTOMRIGHT", 4, 0);
		end
	end
		
	card.CurrentPrice:Hide();
	card.NormalPrice:Show();
	card.SalePrice:Show();

	card.Strikethrough:Show();
end

function StoreProductCardMagnifyingGlass_OnEnter(self)
	StoreProductCard_OnEnter(self:GetParent());
end

function StoreProductCardMagnifyingGlass_OnLeave(self)
	StoreProductCard_OnLeave(self:GetParent());
end

function StoreProductCardMagnifyingGlass_OnClick(self, button, down)
	local card = self:GetParent();
	local entryID = card:GetID();
	local name, _, modelID = select(10,C_PurchaseAPI.GetEntryInfo(entryID));
	StoreFrame_ShowPreview(name, modelID);
end

function StoreProductCardCheckmark_OnEnter(self)
	StoreProductCard_OnEnter(self:GetParent());
	if ( not isRotating ) then
		local point, rpoint, xoffset;
		if (tooltipSides[self:GetParent()] == "LEFT") then
			point = "BOTTOMRIGHT";
			rpoint = "TOPLEFT";
			xoffset = 4;
		else
			point = "BOTTOMLEFT";
			rpoint ="TOPRIGHT";
			xoffset = -4;
		end
		StoreTooltip:ClearAllPoints();
		StoreTooltip:SetPoint(point, self, rpoint, xoffset, 0);
		StoreTooltip_Show(BLIZZARD_STORE_YOU_ALREADY_OWN_THIS);
	end
end

function StoreProductCardCheckmark_OnLeave(self)
	if ( not self:GetParent():IsMouseOver() ) then
		StoreProductCard_OnLeave(self:GetParent());
	end
	StoreTooltip:Hide();
end

function StoreProductCard_ResetCornerPieces(card)
	if (card.NewTexture) then
		card.NewTexture:Hide();
	end

	if (card.HotTexture) then
		card.HotTexture:Hide();
	end

	if (card.DiscountMiddle) then
		card.DiscountMiddle:Hide();
		card.DiscountLeft:Hide();
		card.DiscountRight:Hide();
		card.DiscountText:Hide();
	end

	if (card.Checkmark) then
		card.Checkmark:Hide();
	end
end

------------------------------
function StoreCategory_OnEnter(self)
	self.HighlightTexture:Show();
end

function StoreCategory_OnLeave(self)
	self.HighlightTexture:Hide();
end

function StoreCategory_OnClick(self,button,down)
	local oldId = selectedCategoryID;
	selectedCategoryID = self:GetID();
	if ( oldId ~= selectedCategoryID ) then
		selectedEntryID = nil;
	end
	StoreFrame_UpdateCategories(StoreFrame);

	selectedPageNum = 1;
	StoreFrame_SetCategory(self:GetID());

	StoreProductCard_UpdateAllStates();
	PlaySound("UI_igStore_PageNav_Button");
end

----------------------------------
function StoreTooltip_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b, 0.9);
end

function StoreTooltip_Show(name, description)
	local self = StoreTooltip;
	self:Show();
	StoreTooltip.ProductName:SetText(name);
	StoreTooltip.Description:SetText(description);
	
	-- 10 pixel buffer between top, 10 between name and description, 10 between description and bottom
	local nheight, dheight = self.ProductName:GetHeight(), self.Description:GetHeight();
	local buffer = 10;

	local bufferCount = 3;
	if (not description or description == "") then
		bufferCount = 2;
		dheight = 0;
	end

	local width = math.max(self.ProductName:GetStringWidth(), self.Description:GetStringWidth());
	if ((width + 20) < STORETOOLTIP_MAX_WIDTH) then
		self:SetWidth(width + 20);
	else
		self:SetWidth(STORETOOLTIP_MAX_WIDTH);
	end
	self:SetHeight(buffer*bufferCount + nheight + dheight);
	local parent = self:GetParent();
	local card = parent.ProductCards[1];
	local modelFrameLevel = card.Model:GetFrameLevel();
	self:SetFrameLevel(modelFrameLevel+2);
end

----------------------------------
function StoreButton_OnShow(self)
	if ( self:IsEnabled() ) then
		-- we need to reset our textures just in case we were hidden before a mouse up fired
		self.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
		self.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
		self.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
	end
	local textWidth = self.Text:GetWidth();
	local width = self:GetWidth();
	if ( (width - 40) < textWidth ) then
		self:SetWidth(textWidth + 40);
	end
end

function StoreGoldButton_OnShow(self)
	if ( self:IsEnabled() ) then
		-- we need to reset our textures just in case we were hidden before a mouse up fired
		self.Left:SetTexCoord(0.30859375, 0.35937500, 0.85156250, 0.88281250);
		self.Middle:SetTexCoord(0.73925781, 0.81152344, 0.41992188, 0.45117188);
		self.Right:SetTexCoord(0.98242188, 0.99902344, 0.15917969, 0.19042969);
	end
	local textWidth = self.Text:GetWidth();
	local width = self:GetWidth();
	if ( (width - 40) < textWidth ) then
		self:SetWidth(textWidth + 40);
	end
	self.Text:ClearAllPoints();
	self.Text:SetPoint("CENTER", 0, 3);
end

------------------------------------
function ServicesLogoutPopup_OnLoad(self)
	self.ConfirmButton:SetText(CHARACTER_UPGRADE_LOG_OUT_NOW);
	self.CancelButton:SetText(CHARACTER_UPGRADE_POPUP_LATER);
end

function ServicesLogoutPopupConfirmButton_OnClick(self)
	C_SharedCharacterServices.SetStartAutomatically(true);
	PlaySound("igMainMenuLogout");
	Outbound.Logout();
	ServicesLogoutPopup:Hide();
end

function ServicesLogoutPopupCancelButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	ServicesLogoutPopup:Hide();
end