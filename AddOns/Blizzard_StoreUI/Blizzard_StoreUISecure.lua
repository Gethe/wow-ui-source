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
local JustOrderedBoost = false;
local JustOrderedLegion = false;
local BoostProduct = nil;
local VASReady = false;
local UnrevokeWaitingForProducts = false;

--Imports
Import("C_PurchaseAPI");
Import("C_PetJournal");
Import("C_SharedCharacterServices");
Import("C_AuthChallenge");
Import("C_Timer");
Import("C_WowTokenPublic");
Import("CreateForbiddenFrame");
Import("IsGMClient");
Import("HideGMOnly");
Import("math");
Import("table");
Import("pairs");
Import("select");
Import("tostring");
Import("tonumber");
Import("unpack");
Import("wipe");
Import("type");
Import("LoadURLIndex");
Import("GetContainerNumFreeSlots");
Import("GetCursorPosition");
Import("PlaySound");
Import("SetPortraitToTexture");
Import("BACKPACK_CONTAINER");
Import("NUM_BAG_SLOTS");
Import("RAID_CLASS_COLORS");
Import("CLASS_ICON_TCOORDS");
Import("IsModifiedClick");
Import("GetTime");
Import("UnitAffectingCombat");
Import("GetCVar");
Import("GMError");

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
Import("BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE");
Import("BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE_EUR");
Import("BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE_KR");
Import("BLIZZARD_STORE_CONFIRMATION_OTHER");
Import("BLIZZARD_STORE_CONFIRMATION_OTHER_EUR");
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
Import("BLIZZARD_STORE_ERROR_TITLE_CONSUMABLE_TOKEN_OWNED");
Import("BLIZZARD_STORE_ERROR_MESSAGE_CONSUMABLE_TOKEN_OWNED");
Import("BLIZZARD_STORE_ERROR_ITEM_UNAVAILABLE");
Import("BLIZZARD_STORE_ERROR_YOU_OWN_TOO_MANY_OF_THIS");
Import("BLIZZARD_STORE_VAS_ERROR_REALM_NOT_ELIGIBLE");
Import("BLIZZARD_STORE_VAS_ERROR_CANNOT_MOVE_GUILDMASTER");
Import("BLIZZARD_STORE_VAS_ERROR_DUPLICATE_CHARACTER_NAME");
Import("BLIZZARD_STORE_VAS_ERROR_HAS_MAIL");
Import("BLIZZARD_STORE_VAS_ERROR_UNDER_MIN_LEVEL_REQ");
Import("BLIZZARD_STORE_VAS_ERROR_TOO_MUCH_MONEY_FOR_LEVEL");
Import("BLIZZARD_STORE_VAS_ERROR_HAS_AUCTIONS");
Import("BLIZZARD_STORE_VAS_ERROR_NAME_NOT_AVAILABLE");
Import("BLIZZARD_STORE_VAS_ERROR_LAST_RENAME_TOO_RECENT");
Import("BLIZZARD_STORE_VAS_ERROR_CUSTOMIZE_ALREADY_REQUESTED");
Import("BLIZZARD_STORE_VAS_ERROR_LAST_CUSTOMIZE_TOO_SOON");
Import("BLIZZARD_STORE_VAS_ERROR_FACTION_CHANGE_TOO_SOON");
Import("BLIZZARD_STORE_VAS_ERROR_RACE_CLASS_COMBO_INELIGIBLE");
Import("BLIZZARD_STORE_VAS_ERROR_INELIGIBLE_MAP_ID");
Import("BLIZZARD_STORE_VAS_ERROR_BATTLEPAY_DELIVERY_PENDING");
Import("BLIZZARD_STORE_VAS_ERROR_HAS_WOW_TOKEN");
Import("BLIZZARD_STORE_VAS_ERROR_CHARACTER_LOCKED");
Import("BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_RECENT");
Import("BLIZZARD_STORE_VAS_ERROR_OTHER");
Import("BLIZZARD_STORE_VAS_ERROR_LABEL");
Import("BLIZZARD_STORE_LEGION_PURCHASE_READY");
Import("BLIZZARD_STORE_LEGION_PURCHASE_READY_DESCRIPTION");
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
Import("BLIZZARD_STORE_TOKEN_CURRENT_MARKET_PRICE");
Import("BLIZZARD_STORE_TOKEN_DESC_30_DAYS");
Import("BLIZZARD_STORE_TOKEN_DESC_2700_MINUTES");
Import("BLIZZARD_STORE_LOG_OUT_TO_PURCHASE_THIS_PRODUCT");
Import("BLIZZARD_STORE_PRODUCT_IS_READY");
Import("BLIZZARD_STORE_VAS_SERVICE_READY_DESCRIPTION");
Import("BLIZZARD_STORE_NAME_CHANGE_READY_DESCRIPTION");
Import("BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE");
Import("BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE");
Import("BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE");
Import("BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE");
Import("BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE_CN");
Import("BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE_CN");
Import("BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE_CN");
Import("BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE_CN");
Import("BLIZZARD_STORE_BOOST_UNREVOKED_CONSUMPTION");
Import("TOOLTIP_DEFAULT_COLOR");
Import("TOOLTIP_DEFAULT_BACKGROUND_COLOR");
Import("CHARACTER_UPGRADE_LOG_OUT_NOW");
Import("CHARACTER_UPGRADE_POPUP_LATER");
Import("CHARACTER_UPGRADE_READY");
Import("CHARACTER_UPGRADE_READY_DESCRIPTION");
Import("FREE_CHARACTER_UPGRADE_READY");
Import("FREE_CHARACTER_UPGRADE_READY_DESCRIPTION");
Import("VAS_SELECT_CHARACTER_DISABLED");
Import("VAS_SELECT_CHARACTER");
Import("VAS_CHARACTER_LABEL");
Import("VAS_SELECT_REALM");
Import("VAS_REALM_LABEL");
Import("VAS_CHARACTER_SELECTION_DESCRIPTION");
Import("VAS_SELECTED_CHARACTER_DESCRIPTION");
Import("VAS_NEW_CHARACTER_NAME_LABEL");
Import("VAS_NAME_CHANGE_TOOLTIP");
Import("VAS_NAME_CHANGE_CONFIRMATION");
Import("VAS_APPEARANCE_CHANGE_CONFIRMATION");
Import("VAS_FACTION_CHANGE_CONFIRMATION");
Import("VAS_RACE_CHANGE_CONFIRMATION");
Import("VAS_RACE_CHANGE_VALIDATION_DESCRIPTION");
Import("VAS_FACTION_CHANGE_VALIDATION_DESCRIPTION");
Import("VAS_APPEARANCE_CHANGE_VALIDATION_DESCRIPTION");
Import("TOKEN_CURRENT_AUCTION_VALUE");
Import("TOKEN_MARKET_PRICE_NOT_AVAILABLE");
Import("OKAY");
Import("CONTINUE");
Import("OPTIONS");
Import("LARGE_NUMBER_SEPERATOR");
Import("DECIMAL_SEPERATOR");
Import("GOLD_AMOUNT_SYMBOL");
Import("GOLD_AMOUNT_TEXTURE");
Import("GOLD_AMOUNT_TEXTURE_STRING");
Import("SILVER_AMOUNT_SYMBOL");
Import("SILVER_AMOUNT_TEXTURE");
Import("SILVER_AMOUNT_TEXTURE_STRING");
Import("COPPER_AMOUNT_SYMBOL");
Import("COPPER_AMOUNT_TEXTURE");
Import("COPPER_AMOUNT_TEXTURE_STRING");
Import("FACTION_HORDE");
Import("FACTION_ALLIANCE");
Import("LIST_DELIMITER");


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
Import("LE_STORE_ERROR_CONSUMABLE_TOKEN_OWNED");
Import("LE_STORE_ERROR_TOO_MANY_TOKENS");
Import("LE_STORE_ERROR_ITEM_UNAVAILABLE");
Import("LE_VAS_SERVICE_NAME_CHANGE");
Import("LE_VAS_SERVICE_APPEARANCE_CHANGE");
Import("LE_VAS_SERVICE_FACTION_CHANGE");
Import("LE_VAS_SERVICE_RACE_CHANGE");
Import("LE_VAS_ERROR_REALM_NOT_ELIGIBLE");
Import("LE_VAS_ERROR_CANNOT_MOVE_GUILDMASTER");
Import("LE_VAS_ERROR_DUPLICATE_CHARACTER_NAME");
Import("LE_VAS_ERROR_HAS_MAIL");
Import("LE_VAS_ERROR_UNDER_MIN_LEVEL_REQ");
Import("LE_VAS_ERROR_TOO_MUCH_MONEY_FOR_LEVEL");
Import("LE_VAS_ERROR_HAS_AUCTIONS");
Import("LE_VAS_ERROR_NAME_NOT_AVAILABLE");
Import("LE_VAS_ERROR_LAST_RENAME_TOO_RECENT");
Import("LE_VAS_ERROR_CUSTOMIZE_ALREADY_REQUESTED");
Import("LE_VAS_ERROR_LAST_CUSTOMIZE_TOO_RECENT");
Import("LE_VAS_ERROR_FACTION_CHANGE_TOO_SOON");
Import("LE_VAS_ERROR_RACE_CLASS_COMBO_INELIGIBLE");
Import("LE_VAS_ERROR_INELIGIBLE_MAP_ID");
Import("LE_VAS_ERROR_BATTLEPAY_DELIVERY_PENDING");
Import("LE_VAS_ERROR_HAS_WOW_TOKEN");
Import("LE_VAS_ERROR_CHAR_LOCKED");
Import("LE_VAS_ERROR_LAST_SAVE_TOO_RECENT");
Import("LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS");
Import("LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES");

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
local COPPER_PER_SILVER = 100;
local SILVER_PER_GOLD = 100;
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD;
local WOW_TOKEN_CATEGORY_ID = 30;
local WOW_GAMES_CATEGORY_ID = 33;
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

-- This is copied from WowTokenUI.lua 
function GetSecureMoneyString(money, separateThousands, forceColorBlind)
	local goldString, silverString, copperString;
	local floor = math.floor;

	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = money % COPPER_PER_SILVER;

	if ( (not IsOnGlueScreen() and GetCVar("colorblindMode") == "1" ) or forceColorBlind ) then
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
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_USD,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
	},
	[CURRENCY_GBP] = {
		formatShort = currencyFormatGBP,
		formatLong = currencyFormatGBP,
		browseNotice = BLIZZARD_STORE_BROWSE_EUR,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_EUR,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_EUR,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE_EUR,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER_EUR,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_GBP,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		requireLicenseAccept = true,
		browseHasStar = true,
		browseBuyButtonText = BLIZZARD_STORE_BUY_EUR,
		confirmationButtonText = BLIZZARD_STORE_FINAL_BUY_EUR,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
	},
	[CURRENCY_KRW] = {
		formatShort = currencyFormatRawStar,
		formatLong = currencyFormatKRWLong,
		browseNotice = BLIZZARD_STORE_BROWSE_BATTLE_COINS_KR,
		confirmationNotice = BLIZZARD_STORE_SECOND_CHANCE_KR,
		servicesConfirmationNotice = BLIZZARD_STORE_SECOND_CHANCE_KR,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE_KR,
		expansionConfirmationNotice = BLIZZARD_STORE_SECOND_CHANCE_KR,
		browseWarning = BLIZZARD_STORE_SECOND_CHANCE_KR,
		paymentMethodText = "",
		paymentMethodSubtext = "",
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT,
		requireLicenseAccept = true,
		hideConfirmationBrowseNotice = true,
		browseHasStar = false,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
	},
	[CURRENCY_EUR] = {
		formatShort = currencyFormatEuro,
		formatLong = currencyFormatEuro,
		browseNotice = BLIZZARD_STORE_BROWSE_EUR,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_EUR,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_EUR,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE_EUR,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER_EUR,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_EUR,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		requireLicenseAccept = true,
		browseHasStar = true,
		browseBuyButtonText = BLIZZARD_STORE_BUY_EUR,
		confirmationButtonText = BLIZZARD_STORE_FINAL_BUY_EUR,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
	},
	[CURRENCY_RUB] = {
		formatShort = currencyFormatRUB,
		formatLong = currencyFormatRUB,
		browseNotice = BLIZZARD_STORE_BROWSE_EUR,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_EUR,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_EUR,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE_EUR,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER_EUR,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_RUB,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		requireLicenseAccept = true,
		browseHasStar = true,
		browseBuyButtonText = BLIZZARD_STORE_BUY_EUR,
		confirmationButtonText = BLIZZARD_STORE_FINAL_BUY_EUR,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
	},
	[CURRENCY_ARS] = {
		formatShort = currencyFormatARS,
		formatLong = currencyFormatARS,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_ARS,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
	},
	[CURRENCY_CLP] = {
		formatShort = currencyFormatCLP,
		formatLong = currencyFormatCLP,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_CLP,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
	},
	[CURRENCY_MXN] = {
		formatShort = currencyFormatMXN,
		formatLong = currencyFormatMXN,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_MXN,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
	},
	[CURRENCY_BRL] = {
		formatShort = currencyFormatBRL,
		formatLong = currencyFormatBRL,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_BRL,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
	},
	[CURRENCY_AUD] = {
		formatShort = currencyFormatAUD,
		formatLong = currencyFormatAUD,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_AUD,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
		browseHasStar = true,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
	},
	[CURRENCY_CPT] = {
		formatShort = currencyFormatRawStar,
		formatLong = currencyFormatCPTLong,
		browseNotice = BLIZZARD_STORE_BROWSE_BATTLE_COINS_CN,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_CN,
		paymentMethodText = "",
		paymentMethodSubtext = "",
		hideConfirmationBrowseNotice = true,
		browseHasStar = false,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE_CN,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE_CN,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE_CN,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE_CN,
			},
		},
	},
	[CURRENCY_TPT] = {
		formatShort = currencyFormatTPT,
		formatLong = currencyFormatTPT,
		browseNotice = "",
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_TW,
		paymentMethodText = "",
		paymentMethodSubtext = "",
		browseHasStar = false,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
	},
	[CURRENCY_BETA] = {
		formatShort = currencyFormatBeta,
		formatLong = currencyFormatBeta,
		browseNotice = BLIZZARD_STORE_BROWSE_TEST_CURRENCY,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_TEST,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_TEST,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_TEST,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_TEST,
		paymentMethodText = BLIZZARD_STORE_CONFIRMATION_TEST,
		paymentMethodSubtext = "",
		browseHasStar = true,
		vasDisclaimerData = {
			[LE_VAS_SERVICE_FACTION_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[LE_VAS_SERVICE_RACE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[LE_VAS_SERVICE_APPEARANCE_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[LE_VAS_SERVICE_NAME_CHANGE] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
		},
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
	},
	[LE_STORE_ERROR_CONSUMABLE_TOKEN_OWNED] = {
		title = BLIZZARD_STORE_ERROR_TITLE_CONSUMABLE_TOKEN_OWNED,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_CONSUMABLE_TOKEN_OWNED,
	},
	[LE_STORE_ERROR_TOO_MANY_TOKENS] = {
		title = BLIZZARD_STORE_ERROR_TITLE_CONSUMABLE_TOKEN_OWNED,
		msg = BLIZZARD_STORE_ERROR_YOU_OWN_TOO_MANY_OF_THIS,
	},
	[LE_STORE_ERROR_ITEM_UNAVAILABLE] = {
		title = BLIZZARD_STORE_ERROR_TITLE_CONSUMABLE_TOKEN_OWNED,
		msg = BLIZZARD_STORE_ERROR_ITEM_UNAVAILABLE,
	},
};

--VAS Error message data
local vasErrorData = {
	[LE_VAS_ERROR_REALM_NOT_ELIGIBLE] = {
		msg = BLIZZARD_STORE_VAS_ERROR_REALM_NOT_ELIGIBLE,
	},
	[LE_VAS_ERROR_CANNOT_MOVE_GUILDMASTER] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CANNOT_MOVE_GUILDMASTER,
	},
	[LE_VAS_ERROR_DUPLICATE_CHARACTER_NAME] = {
		msg = BLIZZARD_STORE_VAS_ERROR_DUPLICATE_CHARACTER_NAME,
	},
	[LE_VAS_ERROR_HAS_MAIL] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_MAIL,
	},
	[LE_VAS_ERROR_UNDER_MIN_LEVEL_REQ] = {
		msg = BLIZZARD_STORE_VAS_ERROR_UNDER_MIN_LEVEL_REQ,
	},
	[LE_VAS_ERROR_TOO_MUCH_MONEY_FOR_LEVEL] = {
		msg = function(character)
			local str = "";
			if (character.level > 80) then
				str = GetSecureMoneyString(50000 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			elseif (character.level > 70) then
				str = GetSecureMoneyString(20000 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			elseif (character.level > 50) then
				str = GetSecureMoneyString(5000 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			elseif (character.level > 30) then
				str = GetSecureMoneyString(1000 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			elseif (character.level >= 10) then
				str = GetSecureMoneyString(300 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			end
			return BLIZZARD_STORE_VAS_ERROR_TOO_MUCH_MONEY_FOR_LEVEL:format(str);
		end
	},
	[LE_VAS_ERROR_HAS_AUCTIONS] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_AUCTIONS,
	},
	[LE_VAS_ERROR_NAME_NOT_AVAILABLE] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NAME_NOT_AVAILABLE,
	},
	[LE_VAS_ERROR_LAST_RENAME_TOO_RECENT] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_RENAME_TOO_RECENT,
	},
	[LE_VAS_ERROR_CUSTOMIZE_ALREADY_REQUESTED] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CUSTOMIZE_ALREADY_REQUESTED,
	},
	[LE_VAS_ERROR_FACTION_CHANGE_TOO_SOON] = {
		msg = BLIZZARD_STORE_VAS_ERROR_FACTION_CHANGE_TOO_SOON,
	},
	[LE_VAS_ERROR_RACE_CLASS_COMBO_INELIGIBLE] = { --We should still handle this one even though we shortcut it in case something slips through
		msg = BLIZZARD_STORE_VAS_ERROR_RACE_CLASS_COMBO_INELIGIBLE,
	},
	[LE_VAS_ERROR_INELIGIBLE_MAP_ID] = {
		msg = BLIZZARD_STORE_VAS_ERROR_INELIGIBLE_MAP_ID,
	},
	[LE_VAS_ERROR_BATTLEPAY_DELIVERY_PENDING] = {
		msg = BLIZZARD_STORE_VAS_ERROR_BATTLEPAY_DELIVERY_PENDING,
	},
	[LE_VAS_ERROR_HAS_WOW_TOKEN] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_WOW_TOKEN,
	},
	[LE_VAS_ERROR_CHAR_LOCKED] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CHARACTER_LOCKED,
		notUserFixable = true,
	},
	[LE_VAS_ERROR_LAST_SAVE_TOO_RECENT] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_RECENT,
		notUserFixable = true,
	},
};

local specialMagnifiers = {
	[170] = { -- Legion Deluxe Edition
		[1] = {
			["normal"] = {
				x = 22,
				y = -64,
			},
			["splashsingle"] = {
				x = 72,
				y = -130,
			},
			modelID = 64585,
		},
		[2] = {
			["normal"] = {
				x = 70,
				y = -64,
			},
			["splashsingle"] = {
				x = 120,
				y = -130,
			},
			modelID = 64582,
		},
	},
	[171] = { -- Legion Deluxe Edition Upgrade
		[1] = {
			["normal"] = {
				x = 22,
				y = -64,
			},
			["splashsingle"] = {
				x = 72,
				y = -130,
			},
			modelID = 64585,
		},
		[2] = {
			["normal"] = {
				x = 70,
				y = -64,
			},
			["splashsingle"] = {
				x = 120,
				y = -130,
			},
			modelID = 64582,
		},
	},
}

local factionColors = { 
	[0] = "ffe50d12", 
	[1] = "ff4a54e8",
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
	local entryInfo = C_PurchaseAPI.GetEntryInfo(entryID);
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

	if (entryInfo.currentDollars ~= entryInfo.normalDollars or entryInfo.currentCents ~= entryInfo.normalCents) then
		local normalPrice = entryInfo.normalDollars + (entryInfo.normalCents/100);
		local discountPrice = entryInfo.currentDollars + (entryInfo.currentCents/100);
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

	if ( entryInfo.alreadyOwned ) then
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

	if (entryInfo.isBoost) then
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
	
	card.CurrentPrice:SetText(currencyFormat(entryInfo.currentDollars, entryInfo.currentCents));

	if ( card.SplashBannerText ) then
		if ( entryInfo.bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_NEW ) then
			card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_NEW);
		elseif ( entryInfo.bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_DISCOUNT ) then
			if ( discount ) then
				card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_DISCOUNT_FORMAT:format(discountAmount));
			else
				card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FEATURED);
			end
		elseif ( entryInfo.bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_FEATURED ) then
			card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FEATURED);
		end
	end 

	card.NormalPrice:SetText(currencyFormat(entryInfo.normalDollars, entryInfo.normalCents));
	card.ProductName:SetText(entryInfo.name);
	if (entryInfo.overrideTextColor) then
		card.ProductName:SetTextColor(entryInfo.overrideTextColor.r, entryInfo.overrideTextColor.g, entryInfo.overrideTextColor.b);
	else
		card.ProductName:SetTextColor(1.0, 0.82, 0.0);
	end
	
	if (not card.isSplash) then
		if (entryInfo.overrideBackground) then
			card.Card:SetTexCoord(0, 1, 0, 1);
			card.Card:SetAtlas(entryInfo.overrideBackground, true);
		else
			card.Card:SetSize(146, 209);
			card.Card:SetTexture("Interface\\Store\\Store-Main");
			card.Card:SetTexCoord(0.18457031, 0.32714844, 0.64550781, 0.84960938);	
		end
	end

	if (card == StoreFrame.SplashSingle) then
		card.ProductName:SetFontObject("GameFontNormalWTF2");

		-- nop, but makes :IsTruncated() work below
		card.ProductName:GetWidth();

		if (card.ProductName:IsTruncated()) then
			card.ProductName:SetFontObject("GameFontNormalHuge3");
		end

		if (entryInfo.isWowToken) then
			local price = C_WowTokenPublic.GetCurrentMarketPrice();
			if (price) then
				card.CurrentMarketPrice:SetText(TOKEN_CURRENT_AUCTION_VALUE:format(GetSecureMoneyString(price, true)));
			else
				card.CurrentMarketPrice:SetText(TOKEN_CURRENT_AUCTION_VALUE:format(TOKEN_MARKET_PRICE_NOT_AVAILABLE));
			end
			card.CurrentPrice:ClearAllPoints();
			card.CurrentPrice:SetPoint("TOPLEFT", card.CurrentMarketPrice, "BOTTOMLEFT", 0, -28);
			card.NormalPrice:ClearAllPoints();
			card.NormalPrice:SetPoint("TOPLEFT", card.CurrentMarketPrice, "BOTTOMLEFT", 0, -28);
			card.CurrentMarketPrice:Show();
		else
			card.CurrentMarketPrice:Hide();
			card.CurrentPrice:ClearAllPoints();
			card.CurrentPrice:SetPoint("TOPLEFT", card.Description, "BOTTOMLEFT", 0, -28);
			card.NormalPrice:ClearAllPoints();
			card.NormalPrice:SetPoint("TOPLEFT", card.Description, "BOTTOMLEFT", 0, -28);
		end

		if (discount) then
			card.BuyButton:ClearAllPoints();
			card.BuyButton:SetPoint("TOPLEFT", card.NormalPrice, "BOTTOMLEFT", 0, -20);
		else
			card.BuyButton:ClearAllPoints();
			card.BuyButton:SetPoint("TOPLEFT", card.CurrentPrice, "BOTTOMLEFT", 0, -20);
		end
	end
	
	if (card.Description) then
		local description = entryInfo.description;
		if (entryInfo.isWowToken) then
			local redeemIndex = select(3, C_WowTokenPublic.GetCommerceSystemStatus());
			if (redeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS) then
				description = BLIZZARD_STORE_TOKEN_DESC_30_DAYS;
			elseif (redeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES) then
				description = BLIZZARD_STORE_TOKEN_DESC_2700_MINUTES;
			end
		end
		card.Description:SetText(description);
	end

	if ( entryInfo.displayID ) then
		StoreProductCard_SetModel(card, entryInfo.displayID, entryInfo.alreadyOwned);
	else
		local icon = entryInfo.texture;
		if (not icon) then
			icon = "Interface\\Icons\\INV_Misc_Note_02";
		end
		StoreProductCard_ShowIcon(card, icon, entryInfo.itemID, entryInfo.overrideTexture);
	end

	if (discount) then
		StoreProductCard_ShowDiscount(card, currencyFormat(entryInfo.currentDollars, entryInfo.currentCents), discountReset);
	else
		card.NormalPrice:Hide();
		card.SalePrice:Hide();
		card.Strikethrough:Hide();
		card.CurrentPrice:Show();
	end

	if (card.BuyButton) then
		card.BuyButton:SetEnabled(entryInfo.buyableHere);
	end

	card:SetID(entryID);
	StoreProductCard_UpdateState(card);

	if (card.SpecialMagnifiers) then
		for i = 1, #card.SpecialMagnifiers do
			card.SpecialMagnifiers[i]:Hide();
		end
	end

	if (specialMagnifiers[entryInfo.productID]) then
		for i = 1, #specialMagnifiers[entryInfo.productID] do
			local frame = card.SpecialMagnifiers and card.SpecialMagnifiers[i];
			if (not frame) then
				frame = CreateForbiddenFrame("Button", nil, card, "StoreProductCardSpecialMagnifierTemplate");
				frame:SetScript("OnClick", StoreProductCardSpecialMagnifyingGlass_OnClick);
				frame:SetScript("OnEnter", StoreProductCardSpecialMagnifyingGlass_OnEnter);
				frame:SetScript("OnLeave", StoreProductCardSpecialMagnifyingGlass_OnLeave);	
			end
			local offsetType;
			if (card == StoreFrame.SplashSingle) then
				offsetType = "splashsingle";
			elseif (not card.isSplash) then
				offsetType = "normal";
			end

			if (offsetType) then
				frame:SetPoint("TOPLEFT", specialMagnifiers[entryInfo.productID][i][offsetType].x, specialMagnifiers[entryInfo.productID][i][offsetType].y);
				frame:SetID(specialMagnifiers[entryInfo.productID][i].modelID);
				frame:Show();
			end
		end
	end
	
	if (card.BannerFadeIn and not card:IsShown()) then
		card.BannerFadeIn.FadeAnim:Play();
		card.BannerFadeIn:Show();
	end
	
	if (card.DisabledOverlay) then
		card.DisabledOverlay:SetShown(entryInfo.isVasService and not IsOnGlueScreen());
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
	StoreFrame_CheckMarketPriceUpdates();
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
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("STORE_BOOST_AUTO_CONSUMED");

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
	StoreDialog:SetPoint("CENTER", nil, "CENTER", 0, 40);
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

	self.variablesLoaded = false;
	self.distributionsUpdated = false;
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
		if (UnrevokeWaitingForProducts) then
			local productName = C_PurchaseAPI.GetUnrevokedBoostInfo();
			if (productName and productName ~= "") then
				StoreFrame:Hide();
				StoreFrame_ShowUnrevokeConsumptionDialog();
				UnrevokeWaitingForProducts = false;
			else
				StoreFrame_UpdateActivePanel(self);
			end
		else
			StoreFrame_UpdateActivePanel(self);
		end
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
		if (JustOrderedBoost) then
			StoreFrame_OnCharacterBoostDelivered(self);
		end
	elseif ( event == "AUTH_CHALLENGE_FINISHED" ) then
		if (not C_AuthChallenge.DidChallengeSucceed()) then
			JustOrderedProduct = false;
			JustOrderedBoost = false;
		else
			StoreStateDriverFrame.NoticeTextTimer:Play();
		end
	elseif ( event == "TOKEN_MARKET_PRICE_UPDATED" ) then
		local result = ...;
		if (selectedCategoryID == WOW_TOKEN_CATEGORY_ID) then
			StoreFrame_SetCategory();
		end
	elseif ( event == "TOKEN_STATUS_CHANGED" ) then
		StoreFrame_CheckMarketPriceUpdates();
	elseif ( event == "STORE_BOOST_AUTO_CONSUMED" ) then
		local productName = C_PurchaseAPI.GetUnrevokedBoostInfo();

		if (not productName or productName == "") then
			-- This could happen if we hadn't shown the shop yet in this session.
			C_PurchaseAPI.GetProductList();
			UnrevokeWaitingForProducts = true;
		else
			StoreFrame_ShowUnrevokeConsumptionDialog();
		end
	end
end

function StoreFrame_OnShow(self)
	C_PurchaseAPI.GetProductList();
	C_WowTokenPublic.UpdateMarketPrice();
	self:SetAttribute("isshown", true);
	StoreFrame_UpdateActivePanel(self);
	if ( not IsOnGlueScreen() ) then
		Outbound.UpdateMicroButtons();
	end

	StoreFrame_UpdateCoverState();
	PlaySound("UI_igStore_WindowOpen_Button");
end

function StoreFrame_OnMouseWheel(self, value)
	if ( value > 0 ) then
		if ( self.PrevPageButton:IsShown() and self.PrevPageButton:IsEnabled() ) then
			StoreFramePrevPageButton_OnClick(self.PrevPageButton);
		end
	else
		if ( self.NextPageButton:IsShown() and self.NextPageButton:IsEnabled() ) then
			StoreFrameNextPageButton_OnClick(self.NextPageButton);
		end	
	end
end

function StoreFrame_OnCharacterBoostDelivered(self)
	if (IsOnGlueScreen() and not _G.CharacterSelect.undeleting) then
		self:Hide();
		_G.CharacterUpgradeFlow:SetTarget(false);
		_G.CharSelectServicesFlowFrame:Show();
		_G.CharacterUpgradeFlow.data = _G.CharacterUpgrade_Items[BoostProduct].paid;
		_G.CharacterServicesMaster_SetFlow(_G.CharacterServicesMaster, _G.CharacterUpgradeFlow);
	elseif (not IsOnGlueScreen()) then
		self:Hide();
		ServicesLogoutPopup.Background.Title:SetText(CHARACTER_UPGRADE_READY);
		ServicesLogoutPopup.Background.Description:SetText(CHARACTER_UPGRADE_READY_DESCRIPTION);
		ServicesLogoutPopup.forBoost = true;
		ServicesLogoutPopup.forVasService = false;
		ServicesLogoutPopup.forLegion = false;
		ServicesLogoutPopup:Show();
	end
	JustFinishedOrdering = false;
	JustOrderedBoost = false;
end

function StoreFrame_OnLegionDelivered(self)
	self:Hide();
	if (IsOnGlueScreen()) then
		_G.GlueDialog_Show("LEGION_PURCHASE_READY");
	else
		ServicesLogoutPopup.Background.Title:SetText(BLIZZARD_STORE_LEGION_PURCHASE_READY);
		ServicesLogoutPopup.Background.Description:SetText(BLIZZARD_STORE_LEGION_PURCHASE_READY_DESCRIPTION);
		ServicesLogoutPopup.forBoost = false;
		ServicesLogoutPopup.forVasService = false;
		ServicesLogoutPopup.forLegion = true;
		ServicesLogoutPopup:Show();
	end
	JustFinishedOrdering = false;
	JustOrderedLegion = false;
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
	if (StoreConfirmationFrame and StoreConfirmationFrame:IsShown()) then
		self.Cover:Show();
	elseif (StoreVASValidationFrame and StoreVASValidationFrame:IsShown()) then
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
	elseif ( name == "checkforfree" ) then
		StoreFrame_CheckForFree(self, value);
	elseif ( name == "settokencategory" ) then
		StoreFrame_UpdateCategories(StoreFrame);
		selectedPageNum = 1;
		selectedCategoryID = WOW_TOKEN_CATEGORY_ID;
		StoreFrame_SetCategory();
	elseif ( name == "setgamescategory" ) then
		StoreFrame_UpdateCategories(StoreFrame);
		selectedPageNum = 1;
		selectedCategoryID = WOW_GAMES_CATEGORY_ID;
		StoreFrame_SetCategory();
	elseif ( name == "getvaserrormessage" ) then
		if (IsOnGlueScreen()) then
			self:SetAttribute("vaserrormessageresult", nil);
			local data = value;
			local character = C_PurchaseAPI.GetCharacterInfoByGUID(data.guid);
			if (not character) then
				-- Either this character is not on this realm or we have bogus data somewhere.  were not going to parse this error either way
				return;
			end
			local errors = data.errors;
			local hasOther = false;
			local hasNonUserFixable = false;
			for i = 1, #errors do
				if (not vasErrorData[errors[i]]) then
					hasOther = true;
				elseif (vasErrorData[errors[i]].notUserFixable) then
					hasNonUserFixable = true;
				end
			end

			desc = "";
			if (hasOther) then
				desc = BLIZZARD_STORE_VAS_ERROR_OTHER;
			elseif (hasNonUserFixable) then
				for i = 1, #errors do
					if (vasErrorData[errors[i]].notUserFixable) then
						desc = StoreVASValidationFrame_AppendError(desc, errors[i], character);
					end
				end
			else
				for i = 1, #errors do
					desc = StoreVASValidationFrame_AppendError(desc, errors[i], character);
				end
			end

			self:SetAttribute("vaserrormessageresult", { other = hasOther or hasNonUserFixable, desc = desc });
		end
	end
end

function StoreFrame_OnError(self, errorID, needsAck, internalErr)
	local info = errorData[errorID];
	if ( not info ) then
		info = errorData[LE_STORE_ERROR_OTHER];
	end
	if ( IsGMClient() and not HideGMOnly() ) then
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
		if (StoreVASValidationFrame and StoreVASValidationFrame:IsShown()) then
			StoreVASValidationFrame.CharacterSelectionFrame.ContinueButton:Hide();
			StoreVASValidationFrame.CharacterSelectionFrame.Spinner:Show();
		else
			StoreFrame_SetAlert(self, BLIZZARD_STORE_CONNECTING, BLIZZARD_STORE_PLEASE_WAIT);
		end
	elseif ( JustOrderedProduct or C_PurchaseAPI.HasPurchaseInProgress() ) then
		local progressText;
		if (StoreStateDriverFrame.NoticeTextTimer:IsPlaying()) then --Even if we don't have every list, if we know we have something in progress, we can display that.
			progressText = BLIZZARD_STORE_PROCESSING
		else
			progressText = BLIZZARD_STORE_BEING_PROCESSED_CHECK_BACK_LATER
		end
		StoreFrame_SetAlert(self, BLIZZARD_STORE_TRANSACTION_IN_PROGRESS, progressText);
	elseif ( JustFinishedOrdering ) then
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
		if (StoreVASValidationFrame and StoreVASValidationFrame:IsShown()) then
			StoreVASValidationFrame.CharacterSelectionFrame.Spinner:Hide();
		end
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
	JustFinishedOrdering = false;
	self.PurchaseSentFrame:Hide();
end

function StoreFrame_ShowUnrevokeConsumptionDialog()
	local productName, characterName, realmName = C_PurchaseAPI.GetUnrevokedBoostInfo();

	StoreDialog.Description:SetText(BLIZZARD_STORE_BOOST_UNREVOKED_CONSUMPTION:format(productName, characterName, realmName));
	StoreDialog:Show();
end

function StoreFramePurchaseSentOkayButton_OnClick(self)
	StoreFrame_HidePurchaseSent(StoreFrame);
	if (VASReady) then
		StoreVASValidationFrame_OnVasProductComplete(StoreVASValidationFrame);
	elseif (JustOrderedBoost) then
		StoreFrame_OnCharacterBoostDelivered(StoreFrame);
	elseif (JustOrderedLegion) then
		StoreFrame_OnLegionDelivered(StoreFrame);
	end
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
	if ( StoreVASValidationFrame and StoreVASValidationFrame:IsShown() ) then
		StoreVASValidationFrame:Hide();
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
	local entryInfo = C_PurchaseAPI.GetEntryInfo(entryID);
	if ( entryInfo.alreadyOwned ) then
		StoreFrame_OnError(StoreFrame, LE_STORE_ERROR_ALREADY_OWNED, false, "FakeOwned");
	elseif ( C_PurchaseAPI.PurchaseProduct(entryInfo.productID) ) then
		WaitingOnConfirmation = true;
		WaitingOnConfirmationTime = GetTime();
		StoreFrame_UpdateActivePanel(StoreFrame);
	else
		local productInfo = C_PurchaseAPI.GetProductInfo(entryInfo.productID);
		if (productInfo and productInfo.isExpansion) then
			StoreFrame_OnError(StoreFrame, LE_STORE_ERROR_ALREADY_OWNED, false, "Expansion");
		end
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

function StoreFrame_CheckForFree(self, event)
	if (event == "VARIABLES_LOADED") then
		self.variablesLoaded = true;
	end
	if (event == "PRODUCT_DISTRIBUTIONS_UPDATED") then
		self.distributionsUpdated = true;
	end
	if (self.variablesLoaded and self.distributionsUpdated and C_SharedCharacterServices.HasFreePromotionalUpgrade() and not C_SharedCharacterServices.HasSeenFreePromotionalUpgradePopup() and not IsOnGlueScreen()) then
		C_SharedCharacterServices.SetPromotionalPopupSeen(true);
		self:Hide();
		ServicesLogoutPopup.Background.Title:SetText(FREE_CHARACTER_UPGRADE_READY);
		ServicesLogoutPopup.Background.Description:SetText(FREE_CHARACTER_UPGRADE_READY_DESCRIPTION);
		ServicesLogoutPopup:Show();
	end
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

local VASServiceType = nil;
local SelectedRealm = nil;
local SelectedCharacter = nil;
local NewCharacterName = nil;
local StoreDropdownLists = {};

------------------------------------------
function StoreConfirmationFrame_OnLoad(self)
	self.ProductName:SetTextColor(0, 0, 0);
	self.ProductName:SetShadowColor(0, 0, 0, 0);

	self.Title:SetText(BLIZZARD_STORE_CONFIRMATION_TITLE);
	self.NoticeFrame.TotalLabel:SetText(BLIZZARD_STORE_FINAL_PRICE_LABEL);
	
	self.LicenseAcceptText:SetTextColor(0.8, 0.8, 0.8);

	self.NoticeFrame.Notice:SetSpacing(6);

	self:RegisterEvent("STORE_CONFIRM_PURCHASE");
end

function StoreConfirmationFrame_SetNotice(self, icon, name, dollars, cents, walletName, upgrade, vasService, expansion)
	local currency = C_PurchaseAPI.GetCurrencyID();

	SetPortraitToTexture(self.Icon, icon);
	
	name = name:gsub("|n", " ");
	self.ProductName:SetText(name);	
	local info = currencyInfo();
	local format = info.formatLong;
	local notice;
	
	if (upgrade) then
		notice = info.servicesConfirmationNotice;
	elseif (expansion) then
		notice = info.expansionConfirmationNotice;
	elseif (vasService) then
		local characters = C_PurchaseAPI.GetCharactersForRealm(SelectedRealm);
		local character = characters[SelectedCharacter];
		local confirmationNotice;
		if (VASServiceType == LE_VAS_SERVICE_NAME_CHANGE) then
			notice = VAS_NAME_CHANGE_CONFIRMATION:format(character.name, NewCharacterName);
			confirmationNotice = info.vasNameChangeConfirmationNotice;
		elseif (VASServiceType == LE_VAS_SERVICE_FACTION_CHANGE) then
			local newFaction;
			if (character.faction == 0) then
				newFaction = FACTION_ALLIANCE;
			elseif (character.faction == 1) then
				newFaction = FACTION_HORDE;
			end
			notice = VAS_FACTION_CHANGE_CONFIRMATION:format(character.name, SelectedRealm, newFaction);
			confirmationNotice = info.servicesConfirmationNotice;
		elseif (VASServiceType == LE_VAS_SERVICE_RACE_CHANGE) then
			notice = VAS_RACE_CHANGE_CONFIRMATION:format(character.name, SelectedRealm);
			confirmationNotice = info.servicesConfirmationNotice;
		elseif (VASServiceType == LE_VAS_SERVICE_APPEARANCE_CHANGE) then
			notice = VAS_APPEARANCE_CHANGE_CONFIRMATION:format(character.name, SelectedRealm);
			confirmationNotice = info.servicesConfirmationNotice;
		end
		notice = notice .. "|n|n" .. confirmationNotice;
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
	self.NoticeFrame.Price:SetText(format(dollars, cents));

	self:ClearAllPoints();
	self:SetPoint("CENTER", 0, 18);
end

function StoreConfirmationFrame_OnEvent(self, event, ...)
	if ( event == "STORE_CONFIRM_PURCHASE" ) then
		WaitingOnConfirmation = false;
		StoreFrame_UpdateActivePanel(StoreFrame);
		StoreVASValidationFrame:Hide();
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
local IsUpgrade;
local IsLegion;

function StoreConfirmationFrame_Update(self)
	local productID, walletName = C_PurchaseAPI.GetConfirmationInfo();
	if ( not productID ) then
		self:Hide(); --May want to show an error message
		return;
	end
	local productInfo = C_PurchaseAPI.GetProductInfo(productID);

	local finalIcon = productInfo.texture;
	if ( not finalIcon ) then
		finalIcon = "Interface\\Icons\\INV_Misc_Note_02";
	end
	StoreConfirmationFrame_SetNotice(self, finalIcon, productInfo.name, productInfo.currentDollars, productInfo.currentCents, walletName, productInfo.isBoost, productInfo.isVasService, productInfo.isExpansion);
	IsUpgrade = productInfo.isBoost;
	IsLegion = productInfo.isExpansion;
	if (productInfo.isBoost) then
		BoostProduct = productInfo.boostProduct;
	end
	local info = currencyInfo();
	self.NoticeFrame.BrowseNotice:SetText(info.browseNotice);
	self.NoticeFrame.BrowseNotice:SetShown(not info.hideConfirmationBrowseNotice);

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

	FinalPriceDollars = productInfo.currentDollars;
	FinalPriceCents = productInfo.currentCents;

	local height = 370 + self.NoticeFrame.Notice:GetContentHeight() + 35;
	self:SetHeight(height);
	self.NoticeFrame:SetHeight(120 + self.NoticeFrame.Notice:GetContentHeight());

	if (self.NoticeFrame.Price:GetLeft() < self.NoticeFrame.TotalLabel:GetRight()) then
		self.NoticeFrame.Price:SetFontObject("GameFontNormalLargeOutline");
	else
		self.NoticeFrame.Price:SetFontObject("GameFontNormalShadowHuge2");
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
		JustOrderedBoost = IsUpgrade;
		JustOrderedLegion = IsLegion;
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
function StoreVASValidationFrame_OnLoad(self)
	self.ProductName:SetTextColor(0, 0, 0);
	self.ProductName:SetShadowColor(0, 0, 0, 0);

	self.Title:SetText(OPTIONS);
	self.CharacterSelectionFrame.ContinueButton:SetText(CONTINUE);
	self.CharacterSelectionFrame.RealmSelector.Label:SetText(VAS_REALM_LABEL);
	self.CharacterSelectionFrame.CharacterSelector.Label:SetText(VAS_CHARACTER_LABEL);
	self.CharacterSelectionFrame.NewCharacterName.Label:SetText(VAS_NEW_CHARACTER_NAME_LABEL);
	if (IsOnGlueScreen()) then
		self.CharacterSelectionFrame.NewCharacterName:SetFontObject("GlueEditBoxFont");
	end

	self:RegisterEvent("STORE_CHARACTER_LIST_RECEIVED");
	self:RegisterEvent("STORE_VAS_PURCHASE_ERROR");
	self:RegisterEvent("STORE_VAS_PURCHASE_COMPLETE");
end

function StoreVASValidationFrame_SetVASStart(self)
	local entryInfo = C_PurchaseAPI.GetEntryInfo(selectedEntryID);
	local productID = entryInfo.productID;
	local productInfo = C_PurchaseAPI.GetProductInfo(productID);

	local finalIcon = productInfo.texture;
	if ( not finalIcon ) then
		finalIcon = "Interface\\Icons\\INV_Misc_Note_02";
	end
	SetPortraitToTexture(self.Icon, finalIcon);
	self.ProductName:SetText(productInfo.name);
	self.ProductDescription:SetText(productInfo.description);

	local currencyInfo = currencyInfo();

	local vasDisclaimerData = currencyInfo.vasDisclaimerData;

	if (vasDisclaimerData and vasDisclaimerData[productInfo.vasServiceType]) then
		self.Disclaimer:SetText("<html><body><p align=\"center\">"..vasDisclaimerData[productInfo.vasServiceType].disclaimer.."</p></body></html>");
		self.Disclaimer:Show();
	end
	
	VASServiceType = productInfo.vasServiceType;

	SelectedCharacter = nil;
	for list, _ in pairs(StoreDropdownLists) do
		list:Hide();
	end

	self.CharacterSelectionFrame.ContinueButton:Disable();
	self.CharacterSelectionFrame.ContinueButton:Show();
	self.CharacterSelectionFrame.Spinner:Hide();
	if (IsOnGlueScreen()) then
		SelectedRealm = _G.GetServerName();
	else
		SelectedRealm = GetRealmName();
	end

	self.CharacterSelectionFrame.RealmSelector.Text:SetText(SelectedRealm);
	self.CharacterSelectionFrame.CharacterSelector.Text:SetText(VAS_SELECT_CHARACTER);
	self.CharacterSelectionFrame.CharacterSelector.Button:Enable();
	self.CharacterSelectionFrame.NewCharacterName:Hide();
	self.CharacterSelectionFrame.ClassIcon:Hide();
	self.CharacterSelectionFrame.SelectedCharacterFrame:Hide();
	self.CharacterSelectionFrame.SelectedCharacterName:Hide();
	self.CharacterSelectionFrame.SelectedCharacterDescription:Hide();
	self.CharacterSelectionFrame.ValidationDescription:Hide();
	self.CharacterSelectionFrame.ChangeIconFrame:Hide();
	self.CharacterSelectionFrame:Show();
	
	self:ClearAllPoints();
	self:SetPoint("CENTER", 0, 0);

	self:Show();
end

function StoreVASValidationFrame_AppendError(desc, errorID, character, firstAppend)
	local errorData = vasErrorData[errorID];
	local str;
	if (type(errorData.msg) == "function") then
		str = errorData.msg(character);
	else
		str = errorData.msg;
	end

	local sep = desc ~= "" and (firstAppend and "|n|n" or "|n") or "";
	return desc .. sep .. str;
end

function StoreVASValidationFrame_OnEvent(self, event, ...)
	if ( event == "STORE_CHARACTER_LIST_RECEIVED" ) then
		WaitingOnConfirmation = false;
		StoreFrame_UpdateActivePanel(StoreFrame);
		if ( StoreFrame:IsShown() ) then
			StoreVASValidationFrame_SetVASStart(self);
			self:Raise();
		end
	elseif ( event == "STORE_VAS_PURCHASE_ERROR" ) then
		WaitingOnConfirmation = false;
		StoreFrame_UpdateActivePanel(StoreFrame);
		if ( StoreFrame:IsShown() and StoreVASValidationFrame:IsShown() ) then
			local errors = C_PurchaseAPI.GetVASErrors();
			local characters = C_PurchaseAPI.GetCharactersForRealm(SelectedRealm);
			local character = characters[SelectedCharacter];
			local frame = self.CharacterSelectionFrame;
			local hasOther = false;
			local hasNonUserFixable = false;
			for i = 1, #errors do
				if (not vasErrorData[errors[i]]) then
					hasOther = true;
				elseif (vasErrorData[errors[i]].notUserFixable) then
					hasNonUserFixable = true;
				end
			end

			local desc = BLIZZARD_STORE_VAS_ERROR_LABEL;
			if (hasOther) then
				desc = BLIZZARD_STORE_VAS_ERROR_OTHER;
			elseif (hasNonUserFixable) then
				for i = 1, #errors do
					if (vasErrorData[errors[i]].notUserFixable) then
						desc = StoreVASValidationFrame_AppendError(desc, errors[i], character, i == 1);
					end
				end
			else
				for i = 1, #errors do
					desc = StoreVASValidationFrame_AppendError(desc, errors[i], character, i == 1);
				end
			end
			frame.ChangeIconFrame:Hide();
			if (VASServiceType ~= LE_VAS_SERVICE_NAME_CHANGE) then
				frame.ValidationDescription:ClearAllPoints();
				frame.ValidationDescription:SetPoint("TOPLEFT", frame.SelectedCharacterFrame, "BOTTOMLEFT", 8, -8);
			else
				frame.ValidationDescription:ClearAllPoints();
				frame.ValidationDescription:SetPoint("TOPLEFT", frame.NewCharacterName, "BOTTOMLEFT", -5, -6);
			end
			frame.ValidationDescription:SetFontObject("GameFontBlackSmall2");
			frame.ValidationDescription:SetTextColor(1.0, 0.1, 0.1);
			frame.ValidationDescription:SetText(desc);
			frame.ValidationDescription:Show();
			StoreVASValidationFrame.CharacterSelectionFrame.ContinueButton:Show();
			StoreVASValidationFrame.CharacterSelectionFrame.ContinueButton:Disable();
		end
	elseif ( event == "STORE_VAS_PURCHASE_COMPLETE" ) then
		if (StoreFrame:IsShown()) then
			VASReady = true;
			JustFinishedOrdering = true;
			StoreFrame_UpdateActivePanel(StoreFrame);
		elseif (IsOnGlueScreen() and _G.CharacterSelect:IsVisible()) then
			StoreVASValidationFrame_OnVasProductComplete(StoreVASValidationFrame);
		end
	end
end

function StoreVASValidationFrame_OnVasProductComplete(self)
	local productID, guid, realmName = C_PurchaseAPI.GetVASCompletionInfo();
	local productInfo = C_PurchaseAPI.GetProductInfo(productID);
	if (IsOnGlueScreen()) then
		self:GetParent():Hide();	
		_G.StoreFrame_ShowGlueDialog((_G.BLIZZARD_STORE_VAS_PRODUCT_READY):format(productInfo.name), guid, realmName);
	else
		self:GetParent():Hide();
		ServicesLogoutPopup.Background.Title:SetText(BLIZZARD_STORE_PRODUCT_IS_READY:format(productInfo.name));
		local desc;
		if (productInfo.vasServiceType == LE_VAS_SERVICE_NAME_CHANGE) then
			desc = BLIZZARD_STORE_NAME_CHANGE_READY_DESCRIPTION;
		else
			desc = BLIZZARD_STORE_VAS_SERVICE_READY_DESCRIPTION;
		end
		ServicesLogoutPopup.Background.Description:SetText(desc);
		ServicesLogoutPopup.forVasService = true;
		ServicesLogoutPopup.forBoost = false;
		ServicesLogoutPopup.forLegion = false;
		ServicesLogoutPopup:Show();
	end
	VASReady = false;
end

function StoreVASValidationFrame_OnShow(self)
	StoreFrame_UpdateCoverState();
	self:Raise();
end

function StoreVASValidationFrame_OnHide(self)
	StoreFrame_UpdateCoverState();
end

-------------------------------
local isRotating = false;

function StoreProductCard_UpdateState(card)
	-- No product associated with this card
	if (card:GetID() == 0 or not card:IsShown()) then return end;

	if (card.HighlightTexture) then
		local entryID = card:GetID();
		local entryInfo = C_PurchaseAPI.GetEntryInfo(entryID);
		local enableHighlight = card:GetID() ~= selectedEntryID and not isRotating and (not entryInfo.isVasService or IsOnGlueScreen());
		card.HighlightTexture:SetAlpha(enableHighlight and 1 or 0);
		if (not card.Description and card:IsMouseOver()) then
			if (isRotating) then
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
				local name = entryInfo.name:gsub("|n", " ");
				local description = entryInfo.description;
				StoreTooltip:ClearAllPoints();
				StoreTooltip:SetPoint(point, card, rpoint, xoffset, 0);
				if (entryInfo.isVasService and not IsOnGlueScreen()) then
					name = "";
					description = BLIZZARD_STORE_LOG_OUT_TO_PURCHASE_THIS_PRODUCT;
				end
				StoreTooltip_Show(name, description, isToken);
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
	local entryInfo = C_PurchaseAPI.GetEntryInfo(self:GetID());
	if (not entryInfo.isVasService or IsOnGlueScreen()) then
		if (self.HighlightTexture) then
			self.HighlightTexture:SetShown(selectedEntryID ~= self:GetID());
		end
		if (self.Magnifier and self.Model:IsShown() and self ~= StoreFrame.SplashSingle) then
			self.Magnifier:Show();
		end
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

function StoreProductCard_OnClick(self,button,down)
	local entryInfo = C_PurchaseAPI.GetEntryInfo(self:GetID());
	if (entryInfo.isVasService and not IsOnGlueScreen()) then
		return;
	end

	local showPreview;
	if ( IsOnGlueScreen() ) then
		showPreview = _G.IsControlKeyDown();
	else
		showPreview = IsModifiedClick("DRESSUP");
	end
	if ( showPreview ) then
		if ( entryInfo.modelID ) then
			StoreFrame_ShowPreview(entryInfo.name, entryInfo.modelID);
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
	self.InvisibleMouseOverFrame:Hide();

	if (self.GlowSpin) then
		self.GlowSpin:Hide();
		self.GlowSpin.SpinAnim:Stop();
	end

	if (self.GlowPulse) then
		self.GlowPulse:Hide();
		self.GlowPulse.PulseAnim:Stop();
	end

	self.Model:Show();
	self.Shadows:SetShown(self ~= StoreFrame.SplashSingle);
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

function StoreProductCard_ShowIcon(self, icon, itemID, overrideTexture)
	self.Model:Hide();
	self.Shadows:Hide();
	
	if (self.Magnifier) then
		self.Magnifier:Hide();
	end

	self.IconBorder:Show();
	self.Icon:Show();
	if (itemID) then
		self.InvisibleMouseOverFrame:Show();
	else
		self.InvisibleMouseOverFrame:Hide();
	end

	if (not overrideTexture) then
		if (self == StoreFrame.SplashSingle) then
			self.Icon:SetPoint("TOPLEFT", 86, -96);
		end
		self.Icon:SetSize(63, 63);
		SetPortraitToTexture(self.Icon, icon);
		self.IconBorder:Show();
	else
		self.Icon:SetAtlas(overrideTexture, true);
		if (self == StoreFrame.SplashSingle) then
			local adjustX, adjustY;
			local width, height = self.Icon:GetSize();
			if (width > 63) then
				adjustX = -(width - 63);
			else
				adjustX = 63 - width;
			end

			if (height > 63) then
				adjustY = height - 63;
			else
				adjustY = -(63 - height);
			end

			self.Icon:SetPoint("TOPLEFT", 86 + math.floor(adjustX / 2), -96 + math.floor(adjustY / 2));
		end
		self.IconBorder:Hide();
	end

	if (self == StoreFrame.SplashSingle) then
		self.Magnifier:Hide();
	end

	if (self.GlowSpin and not overrideTexture) then
		self.GlowSpin.SpinAnim:Play();
		self.GlowSpin:Show();
	elseif (self.GlowSpin) then
		self.GlowSpin.SpinAnim:Stop();
		self.GlowSpin:Hide();
	end	

	if (self.GlowPulse and not overrideTexture) then
		self.GlowPulse.PulseAnim:Play();
		self.GlowPulse:Show();
	elseif (self.GlowPulse) then
		self.GlowPulse.SpinAnim:Stop();
		self.GlowPulse:Hide();
	end	
end

function StoreProductCard_IsSplashPage(card)
	return card.isSplash;
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
	local entryInfo = C_PurchaseAPI.GetEntryInfo(entryID);
	StoreFrame_ShowPreview(entryInfo.name, entryInfo.displayID);
end

function StoreProductCardSpecialMagnifyingGlass_OnEnter(self)
	self:SetAlpha(1);
	StoreProductCard_OnEnter(self:GetParent());
end

function StoreProductCardSpecialMagnifyingGlass_OnLeave(self)
	self:SetAlpha(0);
	StoreProductCard_OnLeave(self:GetParent());
end

function StoreProductCardSpecialMagnifyingGlass_OnClick(self, button, down)
	local card = self:GetParent();
	local entryID = card:GetID();
	local entryInfo = C_PurchaseAPI.GetEntryInfo(entryID);
	local modelID = self:GetID();
	StoreFrame_ShowPreview(entryInfo.name, modelID);
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

function StoreProductCardItem_OnEnter(self)
	local card = self:GetParent();
	StoreProductCard_OnEnter(card);
	local entryID = card:GetID();
	local entryInfo = C_PurchaseAPI.GetEntryInfo(entryID);

	local x, y, point;

	if (card == StoreFrame.SplashSingle or card == StoreFrame.SplashPrimary) then
		x = card.Icon:GetLeft();
		y = card.Icon:GetTop();
		point = "BOTTOMRIGHT";
	elseif (tooltipSides[card] == "LEFT") then
		x = card:GetLeft() + 4;
		y = card:GetTop();
		point = "BOTTOMRIGHT";
	else
		x = card:GetRight() - 4;
		y = card:GetTop();
		point = "BOTTOMLEFT";
	end
	StoreTooltip:Hide();
	Outbound.SetItemTooltip(entryInfo.itemID, x, y, point);
end

function StoreProductCardItem_OnLeave(self)
	StoreProductCard_OnLeave(self:GetParent());
	StoreProductCard_UpdateState(self:GetParent());
	Outbound.ClearItemTooltip();
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

function StoreTooltip_Show(name, description, isToken)
	local self = StoreTooltip;
	local STORETOOLTIP_MAX_WIDTH = isToken and 300 or 250;
	local stringMaxWidth = STORETOOLTIP_MAX_WIDTH - 20;
	self.ProductName:SetWidth(stringMaxWidth);
	self.Description:SetWidth(stringMaxWidth);

	self:Show();
	StoreTooltip.ProductName:SetText(name);

	if (isToken) then
		local price = C_WowTokenPublic.GetCurrentMarketPrice();
		if (price) then
			description = description .. BLIZZARD_STORE_TOKEN_CURRENT_MARKET_PRICE:format(GetSecureMoneyString(price));
		else
			description = description .. BLIZZARD_STORE_TOKEN_CURRENT_MARKET_PRICE:format(TOKEN_MARKET_PRICE_NOT_AVAILABLE);
		end
	end
	StoreTooltip.Description:SetText(description);
	
	-- 10 pixel buffer between top, 10 between name and description, 10 between description and bottom
	local nheight, dheight = self.ProductName:GetHeight(), self.Description:GetHeight();
	local buffer = 11;

	local bufferCount = 2;
	if (not name or name == "") then
		self.Description:ClearAllPoints();
		self.Description:SetPoint("TOPLEFT", 10, -11);
	else
		self.Description:ClearAllPoints();
		self.Description:SetPoint("TOPLEFT", self.ProductName, "BOTTOMLEFT", 0, -2);
	end
	
	if (not description or description == "") then
		dheight = 0;
	else
		dheight = dheight + 2;
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
local InfoCache = {};
local InfoCallback = nil;

-- Very simple dropdown.  infoTable contains infoEntries containing text and value, the callback is what is called when a button is clicked.  
function StoreDropDown_SetDropdown(frame, infoTable, callback)
	local buttonHeight = 16;
	local spacing = 0;
	local verticalPadding = 32;
	local horizontalPadding = 24;
	local n = #infoTable;

	wipe(InfoCache);
	
	for list, _ in pairs(StoreDropdownLists) do
		list:Hide();
	end

	if (not StoreDropdownLists[frame.List]) then
		StoreDropdownLists[frame.List] = true;
	end

	frame.List:SetHeight(verticalPadding + spacing*(n-1) + buttonHeight*n);
	for i = 1, n do
		local info = infoTable[i];

		local button;
		if (not frame.List.Buttons[i]) then
			button = CreateForbiddenFrame("Button", nil, frame.List, "StoreDropDownMenuButtonTemplate", i);
			StoreDropDownMenuMenuButton_OnLoad(button);
			button:SetPoint("TOPLEFT", frame.List.Buttons[i-1], "BOTTOMLEFT", 0, -spacing);
		else
			button = frame.List.Buttons[i];
		end

		button:SetText(info.text);
		button:SetWidth(frame.List:GetWidth() - horizontalPadding);
		button:SetHeight(buttonHeight);

		if (info.checked) then
			button.Check:Show();
			button.UnCheck:Hide();
		else
			button.UnCheck:Show();
			button.Check:Hide();
		end
		button:Show();
		InfoCache[i] = info.value;
	end

	InfoCallback = callback;
	for i = n + 1, #frame.List.Buttons do
		if (frame.List.Buttons[i]) then
			frame.List.Buttons[i]:Hide();
		end
	end

	frame.List:Show();
end

function StoreDropDownMenu_OnHide(self)
	wipe(InfoCache);
	InfoCallback = nil;
end

function StoreDropDownMenuMenuButton_OnLoad(self)	
	self:SetFrameLevel(self:GetParent():GetFrameLevel()+2);
	self:SetScript("OnClick", StoreDropDownMenuMenuButton_OnClick);
end

function StoreDropDownMenuMenuButton_OnClick(self, button)
	PlaySound("UChatScrollButton");
	if (not InfoCache or not InfoCallback) then
		-- This should not happen, it means our cache was cleared while the frame was opened.
		-- We probably want a GMError here.
		GMError("StoreDropDown cache was cleared while the frame was shown.");
		self:GetParent():Hide();
		return;
	end

	local value = InfoCache[self:GetID()];
	InfoCallback(value);
	self:GetParent():Hide();
end

------------------------------------
function VASCharacterSelectionRealmSelector_Callback(value)
	SelectedRealm = value;
	SelectedCharacter = nil;
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	frame.RealmSelector.Text:SetText(value);
	frame.CharacterSelector.Text:SetText(VAS_SELECT_CHARACTER);
	frame.CharacterSelector.Button:Enable();
	frame.ClassIcon:Hide();
	frame.SelectedCharacterName:Hide();
	frame.SelectedCharacterDescription:Hide();
	frame.SelectedCharacterFrame:Hide();
	frame.NewCharacterName:SetText("");
	frame.ContinueButton:Disable();
	frame.NewCharacterName:Hide();
end

function VASCharacterSelectionChangeIconFrame_SetIcons(from, to)
	local frame = StoreVASValidationFrame.CharacterSelectionFrame.ChangeIconFrame;
	local spacing = 4;

	local fromTex = frame.Textures[1];
	fromTex:SetAtlas("vas-receipt-icon-"..from, true);
	fromTex:Show();

	local arrowTex = frame.Textures[2];
	arrowTex:Show();

	local width = fromTex:GetWidth() + arrowTex:GetWidth() + spacing; -- This is the width of the fromTex and the arrow before adding the "to" textures.

	local toCount = #to;
	for i = 1, toCount do
		local toTex = frame.Textures[i+2];
		if (not toTex) then
			toTex = frame:CreateTexture(nil, "ARTWORK");
			toTex:SetPoint("LEFT", frame.Textures[i+1], "RIGHT", spacing, 0);
			frame.Textures[i+2] = toTex;
		end
		toTex:SetAtlas("vas-receipt-icon-"..to[i], true);
		toTex:Show();
		width = width + toTex:GetWidth() + spacing;
	end

	for i = toCount + 3, #frame.Textures do
		frame.Textures[i]:Hide();
	end

	fromTex:SetPoint("LEFT", frame, "CENTER", -(width/2), 0);
	frame:Show();
end

function VASCharacterSelectionCharacterSelector_Callback(value)
	SelectedCharacter = value;

	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	local characters = C_PurchaseAPI.GetCharactersForRealm(SelectedRealm);
	local character = characters[SelectedCharacter];
	local level = character.level;
	if (level == 0) then
		level = 1;
	end
	frame.CharacterSelector.Text:SetText(VAS_CHARACTER_SELECTION_DESCRIPTION:format(RAID_CLASS_COLORS[character.classFileName].colorStr, character.name, level, character.className));
	frame.SelectedCharacterFrame:Show();
	frame.ClassIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[character.classFileName]));
	frame.ClassIcon:Show();
	frame.SelectedCharacterName:SetText(character.name);
	frame.SelectedCharacterName:Show();
	frame.SelectedCharacterDescription:SetText(VAS_SELECTED_CHARACTER_DESCRIPTION:format(level, character.raceName, character.className));
	frame.SelectedCharacterDescription:Show();
	frame.ValidationDescription:SetFontObject("GameFontBlack");
	frame.ValidationDescription:SetTextColor(0, 0, 0);

	local bottomWidget = frame.SelectedCharacterFrame;
	if (VASServiceType == LE_VAS_SERVICE_NAME_CHANGE) then
		frame.NewCharacterName:SetText("");
		frame.NewCharacterName:Show();
		frame.NewCharacterName:SetFocus();
		bottomWidget = frame.NewCharacterName;
		frame.ContinueButton:Disable();
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", bottomWidget, "BOTTOMLEFT", -5, -6);
	else
		if (VASServiceType == LE_VAS_SERVICE_RACE_CHANGE) then
			local races = C_PurchaseAPI.GetEligibleRacesForRaceChange(character.guid);

			if (not races or #races == 0) then
				frame.ChangeIconFrame:Hide();
				frame.ValidationDescription:ClearAllPoints();
				frame.ValidationDescription:SetPoint("TOPLEFT", frame.SelectedCharacterFrame, "BOTTOMLEFT", 8, -8);
				frame.ValidationDescription:SetFontObject("GameFontBlackSmall2");
				frame.ValidationDescription:SetTextColor(1.0, 0.1, 0.1);
				frame.ValidationDescription:SetText(StoreVASValidationFrame_AppendError(BLIZZARD_STORE_VAS_ERROR_LABEL, LE_VAS_ERROR_RACE_CLASS_COMBO_INELIGIBLE, character, true));
				frame.ValidationDescription:Show();
				frame.ContinueButton:Disable();
				return;
			end

			local genderPrefix;
			if (character.sex == 0) then
				genderPrefix = "male-";
			else
				genderPrefix = "female-";
			end
			bottomWidget = frame.ChangeIconFrame;
			local to = {};
			for i=1,#races do
				to[i] = genderPrefix..races[i];
			end
			VASCharacterSelectionChangeIconFrame_SetIcons(genderPrefix..character.raceFileName, to);
			
			frame.ValidationDescription:SetText(VAS_RACE_CHANGE_VALIDATION_DESCRIPTION);
			frame.ValidationDescription:Show();
		elseif (VASServiceType == LE_VAS_SERVICE_FACTION_CHANGE) then
			local str, newfaction;

			local from, to;
			if (character.faction == 0) then
				from = "horde";
				to = "alliance";
			elseif (character.faction == 1) then
				from = "alliance";
				to = "horde";
			else
				frame.ChangeIconFrame:Hide();
				frame.ValidationDescription:ClearAllPoints();
				frame.ValidationDescription:SetPoint("TOPLEFT", frame.SelectedCharacterFrame, "BOTTOMLEFT", 8, -8);
				frame.ValidationDescription:SetFontObject("GameFontBlackSmall2");
				frame.ValidationDescription:SetTextColor(1.0, 0.1, 0.1);
				frame.ValidationDescription:SetText(StoreVASValidationFrame_AppendError(BLIZZARD_STORE_VAS_ERROR_LABEL, LE_VAS_ERROR_RACE_CLASS_COMBO_INELIGIBLE, character, true));
				frame.ValidationDescription:Show();
				frame.ContinueButton:Disable();
				return;
			end
			bottomWidget = frame.ChangeIconFrame;
			VASCharacterSelectionChangeIconFrame_SetIcons(from, {to});

			frame.ValidationDescription:SetText(VAS_FACTION_CHANGE_VALIDATION_DESCRIPTION);
			frame.ValidationDescription:Show();
		elseif (VASServiceType == LE_VAS_SERVICE_APPEARANCE_CHANGE) then
			frame.ValidationDescription:SetText(VAS_APPEARANCE_CHANGE_VALIDATION_DESCRIPTION);
			frame.ValidationDescription:Show();
		end
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", bottomWidget, "BOTTOMLEFT", 8, -16);
		frame.ContinueButton:Enable();
	end
end

function VASCharacterSelectionRealmSelector_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	
	if (self:GetParent().List:IsShown()) then
		self:GetParent().List:Hide();
		return;
	end

	local realms = C_PurchaseAPI.GetRealmList();

	local infoTable = {};
	for i = 1, #realms do
		infoTable[#infoTable+1] = {text=realms[i], value=realms[i], checked=(SelectedRealm == realms[i])};
	end

	StoreDropDown_SetDropdown(self:GetParent(), infoTable, VASCharacterSelectionRealmSelector_Callback);
end

function VASCharacterSelectionCharacterSelector_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	
	if (self:GetParent().List:IsShown()) then
		self:GetParent().List:Hide();
		return;
	end

	if (not SelectedRealm) then
		-- This should not happen, it means you have no realm selected.
		return;
	end

	local infoTable = {};
	local characters = C_PurchaseAPI.GetCharactersForRealm(SelectedRealm);
	for i = 1, #characters do
		local character = characters[i];
		local level = character.level;
		if (level == 0) then
			level = 1;
		end
		local str = VAS_CHARACTER_SELECTION_DESCRIPTION:format(RAID_CLASS_COLORS[character.classFileName].colorStr, character.name, level, character.className);
		infoTable[#infoTable+1] = {text=str, value=i, checked=(SelectedCharacter == i)};
	end

	StoreDropDown_SetDropdown(self:GetParent(), infoTable, VASCharacterSelectionCharacterSelector_Callback);
end

function VASCharacterSelectionContinueButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");

	if (not SelectedRealm or not SelectedCharacter) then
		-- This should not happen, as this button should be disabled unless you have both selected.
		return;
	end

	local characters = C_PurchaseAPI.GetCharactersForRealm(SelectedRealm);

	if (not characters[SelectedCharacter]) then
		-- This should not happen
		return;
	end

	local entryInfo = C_PurchaseAPI.GetEntryInfo(selectedEntryID);

	if (not entryInfo.isVasService) then
		-- Um, how did we get to thie frame if this wasnt a vas service?
		return;
	end

	-- Glue screen only

	if ( VASServiceType == LE_VAS_SERVICE_NAME_CHANGE ) then
		NewCharacterName = self:GetParent().NewCharacterName:GetText();

		local valid, reason = _G.IsCharacterNameValid(NewCharacterName);
		if ( not valid) then
			self:GetParent().ValidationDescription:SetFontObject("GameFontBlackSmall2");
			self:GetParent().ValidationDescription:SetTextColor(1.0, 0.1, 0.1);
			self:GetParent().ValidationDescription:SetText(_G[reason]);
			self:GetParent().ValidationDescription:Show();
			self:GetParent().ContinueButton:Disable();
			return;
		end
	end

	if ( C_PurchaseAPI.PurchaseVASProduct(entryInfo.productID, characters[SelectedCharacter].guid, NewCharacterName) ) then
		WaitingOnConfirmation = true;
		WaitingOnConfirmationTime = GetTime();
		StoreFrame_UpdateActivePanel(StoreFrame);
	end
end

function VASCharacterSelectionNewCharacterName_OnEnter(self)
 	StoreTooltip:ClearAllPoints();
	StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
	StoreTooltip_Show("", VAS_NAME_CHANGE_TOOLTIP);
end
------------------------------------
function ServicesLogoutPopup_OnLoad(self)
	self.ConfirmButton:SetText(CHARACTER_UPGRADE_LOG_OUT_NOW);
	self.CancelButton:SetText(CHARACTER_UPGRADE_POPUP_LATER);
end

function ServicesLogoutPopupConfirmButton_OnClick(self)
	if (ServicesLogoutPopup.forBoost) then
		C_SharedCharacterServices.SetStartAutomatically(true, BoostProduct);
	elseif (ServicesLogoutPopup.forVasService) then
		C_PurchaseAPI.SetVASProductReady(true);
	elseif (ServicesLogoutPopup.forLegion) then
		C_PurchaseAPI.SetDisconnectOnLogout(true);
	end
	ServicesLogoutPopup.forBoost = false;
	ServicesLogoutPopup.forVasService = false;
	ServicesLogoutPopup.forLegion = false;
	PlaySound("igMainMenuLogout");
	Outbound.Logout();
	ServicesLogoutPopup:Hide();
end

function ServicesLogoutPopupCancelButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	ServicesLogoutPopup:Hide();
end

--------------------------------------
local priceUpdateTimer, currentPollTimeSeconds;

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

function StoreFrame_UpdateMarketPrice()
	C_WowTokenPublic.UpdateMarketPrice();
end

function StoreFrame_CheckMarketPriceUpdates()
	if (StoreFrame:IsShown() and selectedCategoryID == WOW_TOKEN_CATEGORY_ID) then
		C_WowTokenPublic.UpdateMarketPrice();
		local _, pollTimeSeconds = C_WowTokenPublic.GetCommerceSystemStatus();
		if (not priceUpdateTimer or pollTimeSeconds ~= currentPollTimeSeconds) then
			if (priceUpdateTimer) then
				SecureCancelTicker(priceUpdateTimer);
			end
			priceUpdateTimer = NewSecureTicker(pollTimeSeconds, StoreFrame_UpdateMarketPrice);
			currentPollTimeSeconds = pollTimeSeconds;
		end
	else
		if (priceUpdateTimer) then
			SecureCancelTicker(priceUpdateTimer);
		end
	end
end