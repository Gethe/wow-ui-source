---------------
--NOTE - Please do not change this section without talking to Dan
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

Import("IsOnGlueScreen");

if ( tbl.IsOnGlueScreen() ) then
	tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	Import("C_StoreGlue");
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
local WaitingOnVASToComplete = 0;
local WaitingOnVASToCompleteToken = nil;

--Imports
Import("C_StoreSecure");
Import("C_PetJournal");
Import("C_SharedCharacterServices");
Import("C_ClassTrial");
Import("C_AuthChallenge");
Import("C_Timer");
Import("C_WowTokenPublic");
Import("C_WowTokenSecure");
Import("CreateForbiddenFrame");
Import("IsGMClient");
Import("HideGMOnly");
Import("math");
Import("table");
Import("ipairs");
Import("pairs");
Import("select");
Import("tostring");
Import("tonumber");
Import("unpack");
Import("wipe");
Import("type");
Import("string");
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
Import("GetMouseFocus");
Import("Enum");
Import("SecureMixin");
Import("CreateFromSecureMixins");
Import("ShrinkUntilTruncateFontStringMixin");

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
Import("BLIZZARD_STORE_VAS_ERROR_HAS_HEIRLOOM");
Import("BLIZZARD_STORE_VAS_ERROR_HAS_CAGED_BATTLE_PET");
Import("BLIZZARD_STORE_VAS_ERROR_CHARACTER_LOCKED");
Import("BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_RECENT");
Import("BLIZZARD_STORE_VAS_ERROR_INVALID_DESTINATION_ACCOUNT");
Import("BLIZZARD_STORE_VAS_ERROR_INVALID_SOURCE_ACCOUNT");
Import("BLIZZARD_STORE_VAS_ERROR_DISALLOWED_SOURCE_ACCOUNT");
Import("BLIZZARD_STORE_VAS_ERROR_DISALLOWED_DESTINATION_ACCOUNT");
Import("BLIZZARD_STORE_VAS_ERROR_LOWER_BOX_LEVEL");
Import("BLIZZARD_STORE_VAS_ERROR_MAX_CHARACTERS_ON_SERVER");
Import("BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_DISTANT");
Import("BLIZZARD_STORE_VAS_ERROR_BOOSTED_TOO_RECENTLY");
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
Import("BLIZZARD_STORE_LOG_OUT_TO_PURCHASE_THIS_PRODUCT");
Import("BLIZZARD_STORE_PRODUCT_IS_READY");
Import("BLIZZARD_STORE_VAS_SERVICE_READY_DESCRIPTION");
Import("BLIZZARD_STORE_NAME_CHANGE_READY_DESCRIPTION");
Import("BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE");
Import("BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE");
Import("BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE");
Import("BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE");
Import("BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER");
Import("BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE_CN");
Import("BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE_CN");
Import("BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE_CN");
Import("BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE_CN");
Import("BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER_CN");
Import("BLIZZARD_STORE_BOOST_UNREVOKED_CONSUMPTION");
Import("BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100");
Import("BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100_CN");
Import("TOOLTIP_DEFAULT_COLOR");
Import("TOOLTIP_DEFAULT_BACKGROUND_COLOR");
Import("CHARACTER_UPGRADE_LOG_OUT_NOW");
Import("CHARACTER_UPGRADE_POPUP_LATER");
Import("CHARACTER_UPGRADE_READY");
Import("CHARACTER_UPGRADE_READY_DESCRIPTION");
Import("FREE_CHARACTER_UPGRADE_READY");
Import("FREE_CHARACTER_UPGRADE_READY_DESCRIPTION");
Import("CHARACTER_UPGRADE_CLASS_TRIAL_UNLOCK_READY_DESCRIPTION");
Import("ACCEPT");
Import("VAS_SELECT_CHARACTER_DISABLED");
Import("VAS_SELECT_CHARACTER");
Import("VAS_CHARACTER_LABEL");
Import("VAS_SELECT_REALM");
Import("VAS_REALM_LABEL");
Import("VAS_CHARACTER_SELECTION_DESCRIPTION");
Import("VAS_SELECTED_CHARACTER_DESCRIPTION");
Import("VAS_NEW_CHARACTER_NAME_LABEL");
Import("VAS_NAME_CHANGE_TOOLTIP");
Import("VAS_DESTINATION_REALM_LABEL");
Import("VAS_NAME_CHANGE_CONFIRMATION");
Import("VAS_APPEARANCE_CHANGE_CONFIRMATION");
Import("VAS_FACTION_CHANGE_CONFIRMATION");
Import("VAS_RACE_CHANGE_CONFIRMATION");
Import("VAS_CHARACTER_TRANSFER_CONFIRMATION");
Import("VAS_RACE_CHANGE_VALIDATION_DESCRIPTION");
Import("VAS_FACTION_CHANGE_VALIDATION_DESCRIPTION");
Import("VAS_APPEARANCE_CHANGE_VALIDATION_DESCRIPTION");
Import("VAS_QUEUE_SEVERAL_MINUTES");
Import("VAS_QUEUE_ONE_THREE_HOURS");
Import("VAS_QUEUE_THREE_SIX_HOURS");
Import("VAS_QUEUE_SIX_TWELVE_HOURS");
Import("VAS_QUEUE_TWELVE_HOURS");
Import("VAS_QUEUE_ONE_DAY");
Import("VAS_QUEUE_TWO_DAY");
Import("VAS_QUEUE_THREE_DAY");
Import("VAS_QUEUE_FOUR_DAY");
Import("VAS_QUEUE_FIVE_DAY");
Import("VAS_QUEUE_SIX_DAY");
Import("VAS_QUEUE_SEVEN_DAY");
Import("BLIZZARD_STORE_VAS_SELECT_ACCOUNT");
Import("BLIZZARD_STORE_VAS_DIFFERENT_BNET");
Import("BLIZZARD_STORE_VAS_TRANSFER_REALM");
Import("BLIZZARD_STORE_VAS_REALM_NAME");
Import("BLIZZARD_STORE_VAS_TRANSFER_ACCOUNT");
Import("BLIZZARD_STORE_VAS_TRANSFER_FACTION_BUNDLE");
Import("BLIZZARD_STORE_VAS_EMAIL_ADDRESS");
Import("BLIZZARD_STORE_VAS_DESTINATION_BNET_ACCOUNT");
Import("BLIZZARD_STORE_VAS_REALMS_AND_MORE");
Import("BLIZZARD_STORE_VAS_REALMS_PREVIOUS");
Import("BLIZZARD_STORE_VAS_ERROR_INVALID_BNET_ACCOUNT");
Import("BLIZZARD_STORE_VAS_PREVIOUS_ENTRIES");
Import("BLIZZARD_STORE_VAS_NEXT_ENTRIES");
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
Import("HTML_START_CENTERED");
Import("HTML_END");


--Lua enums
Import("LE_MODEL_BLEND_OPERATION_NONE");

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
local WOW_SERVICES_CATEGORY_ID = 22;
local PI = math.pi;

local CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID = 239;
local CHARACTER_TRANSFER_PRODUCT_ID = 189;

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
		return string.format("%s%s%02d", formatLargeNumber(dollars), DECIMAL_SEPERATOR, cents);
	else
		return formatLargeNumber(dollars);
	end
end

local function currencyFormatUSD(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_USD, formatCurrency(dollars, cents, false));
end

local function currencyFormatGBP(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_GBP, formatCurrency(dollars, cents, false));
end

local function currencyFormatKRWLong(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_KRW_LONG, formatCurrency(dollars, cents, false));
end

local function currencyFormatEuro(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_EURO, formatCurrency(dollars, cents, false));
end

local function currencyFormatRUB(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_RUB, formatCurrency(dollars, cents, false));
end

local function currencyFormatARS(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_ARS, formatCurrency(dollars, cents, false));
end

local function currencyFormatCLP(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_CLP, formatCurrency(dollars, cents, false));
end

local function currencyFormatMXN(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_MXN, formatCurrency(dollars, cents, false));
end

local function currencyFormatBRL(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_BRL, formatCurrency(dollars, cents, false));
end

local function currencyFormatAUD(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_AUD, formatCurrency(dollars, cents, false));
end

local function currencyFormatCPTLong(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_CPT_LONG, formatCurrency(dollars, cents, false));
end

local function currencyFormatTPT(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_TPT, formatCurrency(dollars, cents, false));
end

local function currencyFormatRawStar(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_RAW_ASTERISK, formatCurrency(dollars, cents, false));
end

local function currencyFormatBeta(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_BETA, formatCurrency(dollars, cents, true));
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
			goldString = string.format(GOLD_AMOUNT_TEXTURE_STRING, formatLargeNumber(gold), 0, 0);
		else
			goldString = string.format(GOLD_AMOUNT_TEXTURE, gold, 0, 0);
		end
		silverString = string.format(SILVER_AMOUNT_TEXTURE, silver, 0, 0);
		copperString = string.format(COPPER_AMOUNT_TEXTURE, copper, 0, 0);
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100_CN,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE_CN,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE_CN,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE_CN,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE_CN,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER_CN,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
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
		boostDisclaimerText = BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100,
		vasDisclaimerData = {
			[Enum.VasServiceType.FactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE,
			},
			[Enum.VasServiceType.RaceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE,
			},
			[Enum.VasServiceType.AppearanceChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE,
			},
			[Enum.VasServiceType.NameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE,
			},
			[Enum.VasServiceType.CharacterTransfer] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER,
			},
		},
	},
};

local function currencyInfo()
	local currency = C_StoreSecure.GetCurrencyID();
	local info = currencySpecific[currency];
	return info;
end

--Error message data
local errorData = {
	[Enum.StoreError.InvalidPaymentMethod] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PAYMENT,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PAYMENT,
		link = 11,
	},
	[Enum.StoreError.PaymentFailed] = {
		title = BLIZZARD_STORE_ERROR_TITLE_OTHER,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_OTHER,
	},
	[Enum.StoreError.WrongCurrency] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PAYMENT,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PAYMENT,
		link = 11,
	},
	[Enum.StoreError.BattlepayDisabled] = {
		title = BLIZZARD_STORE_ERROR_TITLE_BATTLEPAY_DISABLED,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_BATTLEPAY_DISABLED,
	},
	[Enum.StoreError.InsufficientBalance] = {
		title = BLIZZARD_STORE_ERROR_TITLE_INSUFFICIENT_BALANCE,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_INSUFFICIENT_BALANCE,
		link = 11,
	},
	[Enum.StoreError.Other] = {
		title = BLIZZARD_STORE_ERROR_TITLE_OTHER,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_OTHER,
	},
	[Enum.StoreError.AlreadyOwned] = {
		title = BLIZZARD_STORE_ERROR_TITLE_ALREADY_OWNED,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_ALREADY_OWNED,
	},
	[Enum.StoreError.ParentalControlsNoPurchase] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PARENTAL_CONTROLS,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PARENTAL_CONTROLS,
	},
	[Enum.StoreError.PurchaseDenied] = {
		title = BLIZZARD_STORE_ERROR_TITLE_PURCHASE_DENIED,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_PURCHASE_DENIED,
	},
	[Enum.StoreError.ConsumableTokenOwned] = {
		title = BLIZZARD_STORE_ERROR_TITLE_CONSUMABLE_TOKEN_OWNED,
		msg = BLIZZARD_STORE_ERROR_MESSAGE_CONSUMABLE_TOKEN_OWNED,
	},
	[Enum.StoreError.TooManyTokens] = {
		title = BLIZZARD_STORE_ERROR_TITLE_CONSUMABLE_TOKEN_OWNED,
		msg = BLIZZARD_STORE_ERROR_YOU_OWN_TOO_MANY_OF_THIS,
	},
	[Enum.StoreError.ItemUnavailable] = {
		title = BLIZZARD_STORE_ERROR_TITLE_CONSUMABLE_TOKEN_OWNED,
		msg = BLIZZARD_STORE_ERROR_ITEM_UNAVAILABLE,
	},
};

--VAS Error message data
local vasErrorData = {
	[Enum.VasError.InvalidDestinationAccount] = {
		msg = BLIZZARD_STORE_VAS_ERROR_INVALID_DESTINATION_ACCOUNT,
	},
	[Enum.VasError.InvalidSourceAccount] = {
		msg = BLIZZARD_STORE_VAS_ERROR_INVALID_SOURCE_ACCOUNT,
	},
	[Enum.VasError.DisallowedSourceAccount] = {
		msg = BLIZZARD_STORE_VAS_ERROR_DISALLOWED_SOURCE_ACCOUNT,
	},
	[Enum.VasError.DisallowedDestinationAccount] = {
		msg = BLIZZARD_STORE_VAS_ERROR_DISALLOWED_DESTINATION_ACCOUNT,
	},
	[Enum.VasError.LowerBoxLevel] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LOWER_BOX_LEVEL,
	},
	[Enum.VasError.RealmNotEligible] = {
		msg = BLIZZARD_STORE_VAS_ERROR_REALM_NOT_ELIGIBLE,
	},
	[Enum.VasError.CannotMoveGuildMaster] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CANNOT_MOVE_GUILDMASTER,
	},
	[Enum.VasError.MaxCharactersOnServer] = {
		msg = BLIZZARD_STORE_VAS_ERROR_MAX_CHARACTERS_ON_SERVER,
	},
	[Enum.VasError.DuplicateCharacterName] = {
		msg = BLIZZARD_STORE_VAS_ERROR_DUPLICATE_CHARACTER_NAME,
	},
	[Enum.VasError.HasMail] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_MAIL,
	},
	[Enum.VasError.UnderMinLevelReq] = {
		msg = BLIZZARD_STORE_VAS_ERROR_UNDER_MIN_LEVEL_REQ,
	},
	[Enum.VasError.CharacterTransferTooSoon] = {
		msg = BLIZZARD_STORE_VAS_ERROR_FACTION_CHANGE_TOO_SOON,
	},
	[Enum.VasError.TooMuchMoneyForLevel] = {
		msg = function(character)
			local str = "";
			if (character.level >= 100) then
				str = GetSecureMoneyString(250000 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			elseif (character.level > 80) then
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
			return string.format(BLIZZARD_STORE_VAS_ERROR_TOO_MUCH_MONEY_FOR_LEVEL, str);
		end
	},
	[Enum.VasError.HasAuctions] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_AUCTIONS,
	},
	[Enum.VasError.NameNotAvailable] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NAME_NOT_AVAILABLE,
	},
	[Enum.VasError.LastRenameTooRecent] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_RENAME_TOO_RECENT,
	},
	[Enum.VasError.CustomizeAlreadyRequested] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CUSTOMIZE_ALREADY_REQUESTED,
	},
	[Enum.VasError.LastCustomizeTooRecent] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_CUSTOMIZE_TOO_SOON,
	},
	[Enum.VasError.FactionChangeTooSoon] = {
		msg = BLIZZARD_STORE_VAS_ERROR_FACTION_CHANGE_TOO_SOON,
	},
	[Enum.VasError.RaceClassComboIneligible] = { --We should still handle this one even though we shortcut it in case something slips through
		msg = BLIZZARD_STORE_VAS_ERROR_RACE_CLASS_COMBO_INELIGIBLE,
	},
	[Enum.VasError.IneligibleMapID] = {
		msg = BLIZZARD_STORE_VAS_ERROR_INELIGIBLE_MAP_ID,
	},
	[Enum.VasError.BattlepayDeliveryPending] = {
		msg = BLIZZARD_STORE_VAS_ERROR_BATTLEPAY_DELIVERY_PENDING,
	},
	[Enum.VasError.HasWoWToken] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_WOW_TOKEN,
	},
	[Enum.VasError.HasHeirloom] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_HEIRLOOM,
	},
	[Enum.VasError.CharLocked] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CHARACTER_LOCKED,
		notUserFixable = true,
	},
	[Enum.VasError.LastSaveTooRecent] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_RECENT,
		notUserFixable = true,
	},
	[Enum.VasError.HasCagedBattlePet] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_CAGED_BATTLE_PET,
	},
	[Enum.VasError.LastSaveTooDistant] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_DISTANT,
	},
	[Enum.VasError.BoostedTooRecently] = {
		msg = BLIZZARD_STORE_VAS_ERROR_BOOSTED_TOO_RECENTLY,
		notUserFixable = true,
	}
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

function StoreFrame_UpdateCard(card,entryID,discountReset,forceModelUpdate)
	local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
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

	if (entryInfo.sharedData.currentDollars ~= entryInfo.sharedData.normalDollars or entryInfo.sharedData.currentCents ~= entryInfo.sharedData.normalCents) then
		local normalPrice = entryInfo.sharedData.normalDollars + (entryInfo.sharedData.normalCents/100);
		local discountPrice = entryInfo.sharedData.currentDollars + (entryInfo.sharedData.currentCents/100);
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
		card.DiscountText:SetText(string.format(BLIZZARD_STORE_DISCOUNT_TEXT_FORMAT, discountAmount));

		local stringWidth = card.DiscountText:GetStringWidth();
		card.DiscountLeft:SetPoint("RIGHT", card.DiscountRight, "LEFT", -stringWidth, 0);
		card.DiscountMiddle:Show();
		card.DiscountLeft:Show();
		card.DiscountRight:Show();
		card.DiscountText:Show();
	end

	if (entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.Boost) then
		card.UpgradeArrow:Show();
		card.boostProduct = entryInfo.sharedData.boostProduct;
	else
		card.UpgradeArrow:Hide();
		card.boostProduct = nil;
	end

	if (card.BuyButton) then
		local text = BLIZZARD_STORE_BUY;
		if (info.browseBuyButtonText) then
			text = info.browseBuyButtonText;
		end
		card.BuyButton:SetText(text);
	end

	card.CurrentPrice:SetText(currencyFormat(entryInfo.sharedData.currentDollars, entryInfo.sharedData.currentCents));

	if ( card.SplashBannerText ) then
		if ( entryInfo.bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_NEW ) then
			card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_NEW);
		elseif ( entryInfo.bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_DISCOUNT ) then
			if ( discount ) then
				card.SplashBannerText:SetText(string.format(BLIZZARD_STORE_SPLASH_BANNER_DISCOUNT_FORMAT, discountAmount));
			else
				card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FEATURED);
			end
		elseif ( entryInfo.bannerType == BATTLEPAY_SPLASH_BANNER_TEXT_FEATURED ) then
			card.SplashBannerText:SetText(BLIZZARD_STORE_SPLASH_BANNER_FEATURED);
		end
	end

	card.NormalPrice:SetText(currencyFormat(entryInfo.sharedData.normalDollars, entryInfo.sharedData.normalCents));
	card.ProductName:SetText(entryInfo.sharedData.name);
	if (entryInfo.sharedData.overrideTextColor) then
		card.ProductName:SetTextColor(entryInfo.sharedData.overrideTextColor.r, entryInfo.sharedData.overrideTextColor.g, entryInfo.sharedData.overrideTextColor.b);
	else
		card.ProductName:SetTextColor(1, 1, 1);
	end

	if (not card.isSplash) then
		if (entryInfo.sharedData.overrideBackground) then
			card.Card:SetTexCoord(0, 1, 0, 1);
			card.Card:SetAtlas(entryInfo.sharedData.overrideBackground, true);
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
		if (entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.WoWToken) then
			local price = C_WowTokenPublic.GetCurrentMarketPrice();
			if (price) then
				card.CurrentMarketPrice:SetText(string.format(TOKEN_CURRENT_AUCTION_VALUE, GetSecureMoneyString(price, true)));
			else
				card.CurrentMarketPrice:SetText(string.format(TOKEN_CURRENT_AUCTION_VALUE, TOKEN_MARKET_PRICE_NOT_AVAILABLE));
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
		local description = entryInfo.sharedData.description;
		if (entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.WoWToken) then
			local balanceEnabled = select(3, C_WowTokenPublic.GetCommerceSystemStatus());
			local balanceAmount = C_WowTokenSecure.GetBalanceRedeemAmount();
			description = BLIZZARD_STORE_TOKEN_DESC_30_DAYS;
		end
		card.Description:SetText(description);
	end

	if ( entryInfo.sharedData.displayID ) then
		StoreProductCard_SetModel(card, entryInfo.sharedData.displayID, entryInfo.alreadyOwned, entryInfo.sharedData.modelSceneID, forceModelUpdate);
	else
		local icon = entryInfo.sharedData.texture;
		if (not icon) then
			icon = "Interface\\Icons\\INV_Misc_Note_02";
		end
		StoreProductCard_ShowIcon(card, icon, entryInfo.sharedData.itemID, entryInfo.sharedData.overrideTexture);
	end

	if (discount) then
		StoreProductCard_ShowDiscount(card, currencyFormat(entryInfo.sharedData.currentDollars, entryInfo.sharedData.currentCents), discountReset);
	else
		card.NormalPrice:Hide();
		card.SalePrice:Hide();
		card.Strikethrough:Hide();
		card.CurrentPrice:Show();
	end

	if (card.BuyButton) then
		card.BuyButton:SetEnabled(entryInfo.sharedData.buyableHere);
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
		card.DisabledOverlay:SetShown(entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.VasService and not IsOnGlueScreen());
	end

	card:Show();
end

function StoreFrame_CheckAndUpdateEntryID(isSplash, isThreeSplash)
	local products = C_StoreSecure.GetProducts(selectedCategoryID);

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

function StoreFrame_SetSplashCategory(forceModelUpdate)
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

	local products = C_StoreSecure.GetProducts(selectedCategoryID);

	if (#products == 0) then
		return;
	end

	local isThreeSplash = #products >= 3;

	StoreFrame_CheckAndUpdateEntryID(true, isThreeSplash);

	if (isThreeSplash) then
		self.SplashSingle:Hide();
		StoreFrame_UpdateCard(self.SplashPrimary, products[1], nil, forceModelUpdate);
		StoreFrame_UpdateCard(self.SplashSecondary1, products[2], nil, forceModelUpdate);
		StoreFrame_UpdateCard(self.SplashSecondary2, products[3], nil, forceModelUpdate);
	else
		self.SplashPrimary:Hide();
		self.SplashSecondary1:Hide();
		self.SplashSecondary2:Hide();
		selectedEntryID = products[1]; -- This is the only card here so just auto select it so the buy button works
		StoreFrame_UpdateCard(self.SplashSingle, products[1], nil, forceModelUpdate);
	end

	StoreFrame_UpdateBuyButton();

	self.PageText:Hide();
	self.NextPageButton:Hide();
	self.PrevPageButton:Hide();
end

function StoreFrame_SetNormalCategory(forceModelUpdate)
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

	local products = C_StoreSecure.GetProducts(id);
	local numTotal = #products;

	for i=1, NUM_STORE_PRODUCT_CARDS do
		local card = self.ProductCards[i];
		local entryID = products[i + NUM_STORE_PRODUCT_CARDS * (pageNum - 1)];
		if ( not entryID ) then
			card:Hide();
		else
			StoreFrame_UpdateCard(card, entryID, nil, forceModelUpdate);
		end
	end

	if ( #products > NUM_STORE_PRODUCT_CARDS ) then
		-- 10, 10/8 = 1, 2 remain
		local numPages = math.ceil(#products / NUM_STORE_PRODUCT_CARDS);
		self.PageText:SetText(string.format(BLIZZARD_STORE_PAGE_NUMBER, pageNum,numPages));
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

function StoreFrame_SetCategory(forceModelUpdate)
	if (select(3, C_StoreSecure.GetProductGroupInfo(selectedCategoryID)) == BATTLEPAY_GROUP_DISPLAY_SPLASH) then
		StoreFrame_SetSplashCategory(forceModelUpdate);
	else
		StoreFrame_SetNormalCategory(forceModelUpdate);
	end
	StoreFrame_CheckMarketPriceUpdates();
end

function StoreFrame_FindPageForBoostProduct(boostProduct)
	local products = C_StoreSecure.GetProducts(WOW_SERVICES_CATEGORY_ID);

	for productIndex, entryID in ipairs(products) do
		local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
		if (entryInfo and entryInfo.sharedData.boostProduct == boostProduct) then
			return math.floor(productIndex / NUM_STORE_PRODUCT_CARDS) + 1;
		end
	end
end

function StoreFrame_GoToPageForBoostProduct(boostProduct)
	-- NOTE: Assumes that the store has the correct category selected.
	local page = StoreFrame_FindPageForBoostProduct(boostProduct);
	if page then
		StoreFrame_SetPage(page);
		return true;
	end

	return false;
end

function StoreFrame_FindCardForBoostProduct(boostProduct)
	if StoreFrame_GoToPageForBoostProduct(boostProduct) then
		for i=1, NUM_STORE_PRODUCT_CARDS do
			local card = StoreFrame.ProductCards[i];

			if card and card:IsShown() and card.boostProduct == boostProduct then
				return card;
			end
		end
	end
end

function StoreFrame_SelectBoostProductForPurchase(boostProduct)
	local card = StoreFrame_FindCardForBoostProduct(boostProduct);
	if (card) then
		-- TODO: Support Click API.
		card:GetScript("OnClick")(card)
		StoreFrame.BuyButton:GetScript("OnClick")(StoreFrame.BuyButton);
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
			card:SetScript("OnMouseDown", StoreProductCard_OnMouseDown);
			card:SetScript("OnMouseUp", StoreProductCard_OnMouseUp);
		end
	end
end

function StoreFrame_UpdateCategories(self)
	local categories = C_StoreSecure.GetProductGroups();

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
		local name, texture = C_StoreSecure.GetProductGroupInfo(groupID);
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
	self:RegisterEvent("STORE_REFRESH");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");

	-- We have to call this from CharacterSelect on the glue screen because the addon engine will load
	-- the store addon more than once if we try to make it ondemand, forcing us to load it before we
	-- have a connection.
	if (not IsOnGlueScreen()) then
		C_StoreSecure.GetPurchaseList();
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
		background:SetColorTexture(0, 0, 0, 0.75);
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
	local errorID, internalErr = C_StoreSecure.GetFailureInfo();
	if ( errorID ) then
		StoreFrame_OnError(self, errorID, true, internalErr);
	end

	self.variablesLoaded = false;
	self.distributionsUpdated = false;
end

local JustFinishedOrdering = false;

function StoreFrame_OnEvent(self, event, ...)
	if ( event == "STORE_PRODUCTS_UPDATED" ) then
		local productGroups = C_StoreSecure.GetProductGroups();
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
			local productName = C_StoreSecure.GetUnrevokedBoostInfo();
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
		local err, internalErr = C_StoreSecure.GetFailureInfo();
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
		local productName = C_StoreSecure.GetUnrevokedBoostInfo();

		if (not productName or productName == "") then
			-- This could happen if we hadn't shown the shop yet in this session.
			C_StoreSecure.GetProductList();
			UnrevokeWaitingForProducts = true;
		else
			StoreFrame_ShowUnrevokeConsumptionDialog();
		end
	elseif ( event == "STORE_REFRESH" ) then
		C_StoreSecure.GetProductList();
	elseif ( event == "UI_MODEL_SCENE_INFO_UPDATED" ) then
		if (self:IsVisible()) then
			StoreFrame_SetCategory(true);
		end
	end
end

function StoreFrame_OnShow(self)
	C_StoreSecure.GetProductList();
	C_WowTokenPublic.UpdateMarketPrice();
	self:SetAttribute("isshown", true);
	StoreFrame_UpdateActivePanel(self);
	if ( not IsOnGlueScreen() ) then
		Outbound.UpdateMicroButtons();
	end

	BoostDeliveredUsageReason = nil;
	BoostDeliveredUsageGUID = nil;
	WaitingOnVASToComplete = 0;
	WaitingOnVASToCompleteToken = nil;

	StoreFrame_UpdateCoverState();
	PlaySound("UI_igStore_WindowOpen_Button");
end

function StoreFrame_OnHide(self)
	if (VASReady) then
		StoreVASValidationFrame_OnVasProductComplete(StoreVASValidationFrame);
	end
	self:SetAttribute("isshown", false);
	-- TODO: Fix so will only hide if Store showed the preview frame
	Outbound.HidePreviewFrame();
	if ( not IsOnGlueScreen() ) then
		Outbound.UpdateMicroButtons();
	end

	StoreVASValidationFrame:Hide();
	PlaySound("UI_igStore_WindowClose_Button");
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

		_G.CharacterUpgradePopup_OnCharacterBoostDelivered(BoostProduct, BoostDeliveredUsageGUID, BoostDeliveredUsageReason);
	elseif (not IsOnGlueScreen()) then
		self:Hide();

		local showReason = "forBoost";

		if C_ClassTrial.IsClassTrialCharacter() and (ProductType == Enum.BattlepayBoostProduct.Level100Boost) and BoostDeliveredUsageReason == "forClassTrialUnlock" then
			showReason = "forClassTrialUnlock";
		end

		ServicesLogoutPopup_SetShowReason(ServicesLogoutPopup, showReason);
	end
	JustFinishedOrdering = false;
	JustOrderedBoost = false;
end

function StoreFrame_OnLegionDelivered(self)
	self:Hide();
	if (IsOnGlueScreen()) then
		_G.GlueDialog_Show("LEGION_PURCHASE_READY");
	else
		ServicesLogoutPopup_SetShowReason(ServicesLogoutPopup, "forLegion");
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

local function SetStoreCategoryFromAttribute(category)
	StoreFrame_UpdateCategories(StoreFrame);
	selectedPageNum = 1;
	selectedCategoryID = category;
	StoreFrame_SetCategory();
end

local function SelectBoostProductForPurchase(category, boostProductID, boostReason, characterToApplyToGUID)
	SetStoreCategoryFromAttribute(category);
	StoreFrame_SelectBoostProductForPurchase(boostProductID);
	BoostDeliveredUsageReason = boostReason;
	BoostDeliveredUsageGUID = characterToApplyToGUID;
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
		SetStoreCategoryFromAttribute(WOW_TOKEN_CATEGORY_ID);
	elseif ( name == "setgamescategory" ) then
		SetStoreCategoryFromAttribute(WOW_GAMES_CATEGORY_ID);
	elseif ( name == "setservicescategory" ) then
		SetStoreCategoryFromAttribute(WOW_SERVICES_CATEGORY_ID);
	elseif ( name == "selectlevel100boostproduct") then
		SelectBoostProductForPurchase(WOW_SERVICES_CATEGORY_ID, Enum.BattlepayBoostProduct.Level100Boost, "forClassTrialUnlock", value);
	elseif ( name == "selectunrevokeboostproduct" ) then
		SelectBoostProductForPurchase(WOW_SERVICES_CATEGORY_ID, Enum.BattlepayBoostProduct.Level90Boost, "forUnrevokeBoost", value);
	elseif ( name == "getvaserrormessage" ) then
		if (IsOnGlueScreen()) then
			self:SetAttribute("vaserrormessageresult", nil);
			local data = value;
			local character = C_StoreSecure.GetCharacterInfoByGUID(data.guid);
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
	elseif ( name == "isvastransferproduct" ) then
		local productID = value;
		self:SetAttribute('isvastransferproductresult', productID == CHARACTER_TRANSFER_PRODUCT_ID or productID == CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID);
	end
end

function StoreFrame_OnError(self, errorID, needsAck, internalErr)
	local info = errorData[errorID];
	if ( not info ) then
		info = errorData[Enum.StoreError.Other];
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
			StoreVASValidationFrame.CharacterSelectionFrame.RealmSelector.Button:Disable();
			StoreVASValidationFrame.CharacterSelectionFrame.CharacterSelector.Button:Disable();
			StoreVASValidationFrame.CharacterSelectionFrame.ContinueButton:Hide();
			StoreVASValidationFrame.CharacterSelectionFrame.Spinner:Show();
		else
			StoreFrame_SetAlert(self, BLIZZARD_STORE_CONNECTING, BLIZZARD_STORE_PLEASE_WAIT);
		end
	elseif ( JustOrderedProduct or C_StoreSecure.HasPurchaseInProgress() ) then
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
	elseif ( not C_StoreSecure.IsAvailable() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_NOT_AVAILABLE, BLIZZARD_STORE_NOT_AVAILABLE_SUBTEXT);
	elseif ( C_StoreSecure.IsRegionLocked() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_REGION_LOCKED, BLIZZARD_STORE_REGION_LOCKED_SUBTEXT);
	elseif ( not C_StoreSecure.HasPurchaseList() or not C_StoreSecure.HasProductList() or not C_StoreSecure.HasDistributionList() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_LOADING, BLIZZARD_STORE_PLEASE_WAIT);
	elseif ( #C_StoreSecure.GetProductGroups() == 0 ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_NO_ITEMS, BLIZZARD_STORE_CHECK_BACK_LATER);
	elseif ( not IsOnGlueScreen() and not StoreFrame_HasFreeBagSlots() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_BAG_FULL, BLIZZARD_STORE_BAG_FULL_DESC);
	elseif ( not currencyInfo() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_INTERNAL_ERROR, BLIZZARD_STORE_INTERNAL_ERROR_SUBTEXT);
	else
		StoreFrame_HideAlert(self);
		StoreFrame_HidePurchaseSent(self);
		if (StoreVASValidationFrame and StoreVASValidationFrame:IsShown()) then
			StoreVASValidationFrame.CharacterSelectionFrame.RealmSelector.Button:Enable();
			StoreVASValidationFrame.CharacterSelectionFrame.CharacterSelector.Button:Enable();
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
	WaitingOnVASToComplete = 0;
	WaitingOnVASToCompleteToken = nil;
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
	local productName, characterName, realmName = C_StoreSecure.GetUnrevokedBoostInfo();

	StoreDialog.Description:SetText(string.format(BLIZZARD_STORE_BOOST_UNREVOKED_CONSUMPTION, productName, characterName, realmName));
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
		C_StoreSecure.AckFailure();
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
	local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
	if ( entryInfo.alreadyOwned ) then
		StoreFrame_OnError(StoreFrame, Enum.StoreError.AlreadyOwned, false, "FakeOwned");
	elseif ( C_StoreSecure.PurchaseProduct(entryInfo.productID) ) then
		if (entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.VasService) then
			WaitingOnVASToComplete = WaitingOnVASToComplete + 1;
		else
			WaitingOnVASToComplete = 0;
			WaitingOnVASToCompleteToken = nil;
		end
		WaitingOnConfirmation = true;
		WaitingOnConfirmationTime = GetTime();
		StoreFrame_UpdateActivePanel(StoreFrame);
	else
		local productInfo = C_StoreSecure.GetProductInfo(entryInfo.productID);
		if (productInfo and productInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.Expansion) then
			StoreFrame_OnError(StoreFrame, Enum.StoreError.AlreadyOwned, false, "Expansion");
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

function StoreFrame_ShowPreview(name, modelID, modelSceneID)
	Outbound.ShowPreview(name, modelID, modelSceneID);
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

function StoreFrame_SetPage(page)
	selectedPageNum = page;
	selectedEntryID = nil;
	StoreFrame_SetCategory();
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
local SelectedDestinationRealm = nil;
local DestinationRealmMapping = {};
local StoreDropdownLists = {};
local SelectedDestinationWowAccount = nil;
local SelectedDestinationBnetAccount = nil;
local SelectedDestinationBnetWowAccount = nil;
local CharacterTransferFactionChangeBundle = nil;
local RealmAutoCompleteList;
local IsVasBnetTransferValidated = false;
local RealmAutoCompleteIndexByKey = {};
local RealmList = {};
local RealmRpPvpMap = {};

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

function BuildCharacterTransferConfirmationString(character)
	local confStr = "";
	local sep = "";

	if (SelectedDestinationWowAccount and SelectedDestinationWowAccount ~= BLIZZARD_STORE_VAS_DIFFERENT_BNET) then
		confStr = StripWoWAccountLicenseInfo(SelectedDestinationWowAccount);
		sep = ", ";
	elseif (SelectedDestinationBnetAccount) then
		confStr = SelectedDestinationBnetAccount .. " (" .. StripWoWAccountLicenseInfo(SelectedDestinationBnetWowAccount) .. ")";
		sep = ", ";
	end

	if (CharacterTransferFactionChangeBundle) then
		local newFaction;
		if (character.faction == 0) then
			newFaction = FACTION_ALLIANCE;
		elseif (character.faction == 1) then
			newFaction = FACTION_HORDE;
		end
		confStr = confStr .. sep .. newFaction;
		sep = ", ";
	end

	if (SelectedDestinationRealm) then
		confStr = confStr .. sep .. SelectedDestinationRealm
	end

	return confStr;
end

function StoreConfirmationFrame_SetNotice(self, icon, name, dollars, cents, walletName, productDecorator)
	local currency = C_StoreSecure.GetCurrencyID();

	SetPortraitToTexture(self.Icon, icon);

	name = name:gsub("|n", " ");
	self.ProductName:SetText(name);
	local info = currencyInfo();
	local format = info.formatLong;
	local notice;

	if (productDecorator == Enum.BattlepayProductDecorator.Boost) then
		notice = info.servicesConfirmationNotice;

		if info.boostDisclaimerText then
			notice = info.boostDisclaimerText .. "|n|n" .. notice;
		end
	elseif (productDecorator == Enum.BattlepayProductDecorator.Expansion) then
		notice = info.expansionConfirmationNotice;
	elseif (productDecorator == Enum.BattlepayProductDecorator.VasService) then
		local characters = C_StoreSecure.GetCharactersForRealm(SelectedRealm);
		local character = characters[SelectedCharacter];
		local confirmationNotice;
		if (VASServiceType == Enum.VasServiceType.NameChange) then
			notice = string.format(VAS_NAME_CHANGE_CONFIRMATION, character.name, NewCharacterName);
			confirmationNotice = info.vasNameChangeConfirmationNotice;
		elseif (VASServiceType == Enum.VasServiceType.FactionChange) then
			local newFaction;
			if (character.faction == 0) then
				newFaction = FACTION_ALLIANCE;
			elseif (character.faction == 1) then
				newFaction = FACTION_HORDE;
			end
			notice = string.format(VAS_FACTION_CHANGE_CONFIRMATION, character.name, SelectedRealm, newFaction);
			confirmationNotice = info.servicesConfirmationNotice;
		elseif (VASServiceType == Enum.VasServiceType.RaceChange) then
			notice = string.format(VAS_RACE_CHANGE_CONFIRMATION, character.name, SelectedRealm);
			confirmationNotice = info.servicesConfirmationNotice;
		elseif (VASServiceType == Enum.VasServiceType.AppearanceChange) then
			notice = string.format(VAS_APPEARANCE_CHANGE_CONFIRMATION, character.name, SelectedRealm);
			confirmationNotice = info.servicesConfirmationNotice;
		elseif (VASServiceType == Enum.VasServiceType.CharacterTransfer ) then
			notice = string.format(VAS_CHARACTER_TRANSFER_CONFIRMATION, character.name, SelectedRealm, BuildCharacterTransferConfirmationString(character));
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
		notice = notice .. "\n\n" .. string.format(BLIZZARD_STORE_WALLET_INFO, walletName);
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
		VASCharacterSelectionCancelTimeout();
		if ( StoreFrame:IsShown() ) then
			StoreConfirmationFrame_Update(self);
			self:Raise();
		else
			C_StoreSecure.PurchaseProductConfirm(false);
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
	local productID, walletName, _, _, currentDollars, currentCents = C_StoreSecure.GetConfirmationInfo();
	if ( not productID ) then
		self:Hide(); --May want to show an error message
		return;
	end
	local productInfo = C_StoreSecure.GetProductInfo(productID);
	local name = productInfo.sharedData.name;
	local finalIcon = productInfo.sharedData.texture;
	if ( not finalIcon ) then
		finalIcon = "Interface\\Icons\\INV_Misc_Note_02";
	end
	-- Character Transfer is a special snowflake here
	if (productID == CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID) then
		local baseProductInfo = C_StoreSecure.GetProductInfo(CHARACTER_TRANSFER_PRODUCT_ID);
		name = baseProductInfo.sharedData.name;
		finalIcon = baseProductInfo.sharedData.texture;
	end
	StoreConfirmationFrame_SetNotice(self, finalIcon, name, currentDollars, currentCents, walletName, productInfo.sharedData.productDecorator);
	IsUpgrade = productInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.Boost;
	IsLegion = productInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.Expansion;
	BoostProduct = productInfo.sharedData.boostProduct;
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

	FinalPriceDollars = currentDollars;
	FinalPriceCents = currentCents;

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
	C_StoreSecure.PurchaseProductConfirm(false);
	StoreConfirmationFrame:Hide();

	PlaySound("UI_igStore_Cancel_Button");
end

function StoreConfirmationFinalBuy_OnClick(self)
	-- wait a bit after window is shown so no one accidentally buys something with a lazy double-click
	if ( GetTime() - WaitingOnConfirmationTime < 0.5 ) then
		return;
	end

	if ( C_StoreSecure.PurchaseProductConfirm(true, FinalPriceDollars, FinalPriceCents) ) then
		JustOrderedProduct = true;
		JustOrderedBoost = IsUpgrade;
		JustOrderedLegion = IsLegion;
		StoreStateDriverFrame.NoticeTextTimer:Play();
		PlaySound("UI_igStore_ConfirmPurchase_Button");
	else
		StoreFrame_OnError(StoreFrame, Enum.StoreError.Other, false, "Fake");
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

	SecureMixin(self.CharacterSelectionFrame.SelectedCharacterDescription, ShrinkUntilTruncateFontStringMixin);
	self.CharacterSelectionFrame.SelectedCharacterDescription:SetFontObjectsToTry("GameFontHighlightSmall2", "GameFontWhiteTiny", "GameFontWhiteTiny2");

	local labelsToShrink = {
		"TransferRealmCheckbox",
		"TransferAccountCheckbox",
		"TransferFactionCheckbox",
	};

	for i, checkbox in ipairs(labelsToShrink) do
		SecureMixin(self.CharacterSelectionFrame[checkbox].Label, ShrinkUntilTruncateFontStringMixin);
		self.CharacterSelectionFrame[checkbox].Label:SetFontObjectsToTry("GameFontBlack", "GameFontBlackSmall", "GameFontBlackSmall2", "GameFontBlackTiny", "GameFontBlackTiny2");
	end

	if (IsOnGlueScreen()) then
		self.CharacterSelectionFrame.NewCharacterName:SetFontObject("GlueEditBoxFont");
		self.CharacterSelectionFrame.TransferRealmEditbox:SetFontObject("GlueEditBoxFont");
		self.CharacterSelectionFrame.TransferBattlenetAccountEditbox:SetFontObject("GlueEditBoxFont");
	end

	self:RegisterEvent("STORE_CHARACTER_LIST_RECEIVED");
	self:RegisterEvent("STORE_VAS_PURCHASE_ERROR");
	self:RegisterEvent("STORE_VAS_PURCHASE_COMPLETE");
	self:RegisterEvent("VAS_TRANSFER_VALIDATION_UPDATE");
	self:RegisterEvent("VAS_QUEUE_STATUS_UPDATE");
end

function StoreVASValidationFrame_SetVASStart(self)
	local entryInfo = C_StoreSecure.GetEntryInfo(selectedEntryID);
	local productID = entryInfo.productID;
	local productInfo = C_StoreSecure.GetProductInfo(productID);

	local finalIcon = productInfo.sharedData.texture;
	if ( not finalIcon ) then
		finalIcon = "Interface\\Icons\\INV_Misc_Note_02";
	end
	SetPortraitToTexture(self.Icon, finalIcon);
	self.ProductName:SetText(productInfo.sharedData.name);
	self.ProductDescription:SetText(productInfo.sharedData.description);

	local currencyInfo = currencyInfo();

	local vasDisclaimerData = currencyInfo.vasDisclaimerData;

	if (vasDisclaimerData and vasDisclaimerData[productInfo.sharedData.vasServiceType]) then
		local disclaimer = vasDisclaimerData[productInfo.sharedData.vasServiceType].disclaimer;
		if (productInfo.sharedData.vasServiceType == Enum.VasServiceType.CharacterTransfer or productInfo.sharedData.vasServiceType == Enum.VasServiceType.FactionChange ) then
			disclaimer = string.format(disclaimer, VAS_QUEUE_SEVERAL_MINUTES);
		end
		self.Disclaimer:SetTextColor(0, 0, 0);
		self.Disclaimer:SetText(HTML_START_CENTERED..disclaimer..HTML_END);
		self.Disclaimer:Show();
	end

	VASServiceType = productInfo.sharedData.vasServiceType;

	SelectedCharacter = nil;
	for list, _ in pairs(StoreDropdownLists) do
		list:Hide();
	end

	self.CharacterSelectionFrame.ContinueButton:Disable();
	self.CharacterSelectionFrame.ContinueButton:Show();
	self.CharacterSelectionFrame.Spinner:Hide();
	SelectedRealm = _G.GetServerName();

	SelectedDestinationRealm = nil;
	SelectedDestinationWowAccount = nil;
	SelectedDestinationBnetAccount = nil;
	SelectedDestinationBnetWowAccount = nil;
	CharacterTransferFactionChangeBundle = nil;
	IsVasBnetTransferValidated = false;
	RealmAutoCompleteList = nil;
	self.CharacterSelectionFrame.RealmSelector.Text:SetText(SelectedRealm);
	self.CharacterSelectionFrame.RealmSelector.Button:Enable();
	self.CharacterSelectionFrame.CharacterSelector.Text:SetText(VAS_SELECT_CHARACTER);
	self.CharacterSelectionFrame.CharacterSelector.Button:Enable();
	self.CharacterSelectionFrame.NewCharacterName:Hide();
	self.CharacterSelectionFrame.TransferRealmCheckbox:Hide();
	self.CharacterSelectionFrame.TransferRealmEditbox:Hide();
	self.CharacterSelectionFrame.TransferRealmAutoCompleteBox:Hide();
	self.CharacterSelectionFrame.TransferAccountCheckbox:Hide();
	self.CharacterSelectionFrame.TransferAccountDropDown:Hide();
	self.CharacterSelectionFrame.TransferFactionCheckbox:Hide();
	self.CharacterSelectionFrame.TransferBattlenetAccountEditbox:Hide();
	self.CharacterSelectionFrame.TransferBnetWoWAccountDropDown:Hide();
	self.CharacterSelectionFrame.ClassIcon:Hide();
	self.CharacterSelectionFrame.SelectedCharacterFrame:Hide();
	self.CharacterSelectionFrame.SelectedCharacterName:Hide();
	self.CharacterSelectionFrame.SelectedCharacterDescription:Hide();
	self.CharacterSelectionFrame.ValidationDescription:Hide();
	self.CharacterSelectionFrame.ChangeIconFrame:Hide();
	self.CharacterSelectionFrame:Show();

	if ( VASServiceType == Enum.VasServiceType.CharacterTransfer or VASServiceType == Enum.VasServiceType.FactionChange ) then
			C_StoreGlue.RequestCurrentVASTransferQueues();
	end

	self:ClearAllPoints();
	if ( VASServiceType == Enum.VasServiceType.CharacterTransfer ) then
		self:SetHeight(740);
		self:SetPoint("CENTER", 0, -20);
	else
		self:SetHeight(626);
		self:SetPoint("CENTER", 0, 0);
	end

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

function StoreVASValidationFrame_UpdateCharacterTransferValidationPosition()
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	local bottomWidget;
	local xOffset = 8;
	local yOffset = -24;
	if (frame.TransferBnetWoWAccountDropDown:IsShown()) then
		bottomWidget = frame.TransferBnetWoWAccountDropDown;
		xOffset = 16;
		yOffset = -16;
	elseif (frame.TransferFactionCheckbox:IsShown()) then
		bottomWidget = frame.TransferFactionCheckbox;
	elseif (frame.TransferBattlenetAccountEditbox:IsShown()) then
		bottomWidget = frame.TransferBattlenetAccountEditbox;
	else
		bottomWidget = frame.TransferAccountCheckbox;
	end
	frame.ValidationDescription:ClearAllPoints();
	frame.ValidationDescription:SetPoint("TOPLEFT", bottomWidget, "BOTTOMLEFT", xOffset, yOffset);
end

local VasQueueStatusToString
if (IsOnGlueScreen()) then
	VasQueueStatusToString = {
		[Enum.VasQueueStatus.UnderAnHour] = "SEVERAL_MINUTES",
		[Enum.VasQueueStatus.OneToThreeHours] = "ONE_THREE_HOURS",
		[Enum.VasQueueStatus.ThreeToSixHours] = "THREE_SIX_HOURS",
		[Enum.VasQueueStatus.SixToTwelveHours] = "SIX_TWELVE_HOURS",
		[Enum.VasQueueStatus.OverTwelveHours] = "TWELVE_HOURS",
		[Enum.VasQueueStatus.Over1Days] = "ONE_DAY",
		[Enum.VasQueueStatus.Over2Days] = "TWO_DAY",
		[Enum.VasQueueStatus.Over3Days] = "THREE_DAY",
		[Enum.VasQueueStatus.Over4Days] = "FOUR_DAY",
		[Enum.VasQueueStatus.Over5Days] = "FIVE_DAY",
		[Enum.VasQueueStatus.Over6Days] = "SIX_DAY",
		[Enum.VasQueueStatus.Over7Days] = "SEVEN_DAY",
	}
end

function StoreVASValidationFrame_SyncFontHeights(...)
	local smallestObject, smallestObjectFontHeight;
	for i = 1, select('#', ...) do
		local obj = select(i, ...);
		local myFH = select(2, obj:GetFont());
		if (not smallestObject or myFH < smallestObjectFontHeight) then
			smallestObject = obj;
			smallestObjectFontHeight = myFH;
		end
	end

	for i = 1, select('#', ...) do
		local obj = select(i, ...);
		obj:SetFontObject(smallestObject:GetFontObject());
	end
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
		VASCharacterSelectionCancelTimeout();
		StoreVASValidationState_Unlock();
		WaitingOnConfirmation = false;
		StoreFrame_UpdateActivePanel(StoreFrame);
		if ( StoreFrame:IsShown() and StoreVASValidationFrame:IsShown() ) then
			StoreVASValidationFrame_SetErrors(C_StoreSecure.GetVASErrors());
		end
	elseif ( event == "STORE_VAS_PURCHASE_COMPLETE" ) then
		if (StoreFrame:IsShown()) then
			WaitingOnConfirmation = false;
			VASReady = true;
			JustFinishedOrdering = WaitingOnVASToComplete == WaitingOnVASToCompleteToken;
			StoreFrame_UpdateActivePanel(StoreFrame);
		elseif (IsOnGlueScreen() and _G.CharacterSelect:IsVisible()) then
			StoreVASValidationFrame_OnVasProductComplete(StoreVASValidationFrame);
		end
	elseif ( event == "VAS_TRANSFER_VALIDATION_UPDATE" ) then
		local error = ...;
		local frame = self.CharacterSelectionFrame
		frame.Spinner:Hide();
		frame.ContinueButton:Show();
		frame.ContinueButton:Disable();
		StoreVASValidationState_Unlock();

		if (not error) then
			IsVasBnetTransferValidated = true;
			frame.TransferBnetWoWAccountDropDown:Show();
			frame.TransferBnetWoWAccountDropDown.Text:SetText(BLIZZARD_STORE_VAS_SELECT_ACCOUNT);
			frame.ValidationDescription:Hide();
		else
			frame.ValidationDescription:ClearAllPoints();
			frame.ValidationDescription:SetPoint("TOPLEFT", frame.TransferBattlenetAccountEditbox, "BOTTOMLEFT", -4, -16);
			frame.ValidationDescription:SetFontObject("GameFontBlackSmall2");
			frame.ValidationDescription:SetTextColor(1.0, 0.1, 0.1);
			frame.ValidationDescription:SetText(BLIZZARD_STORE_VAS_ERROR_INVALID_BNET_ACCOUNT);
			frame.ValidationDescription:Show();
		end
	elseif ( event == "VAS_QUEUE_STATUS_UPDATE" ) then
		local transfer, factionTransfer = C_StoreGlue.GetVasTransferQueues();
		local queueTime = Enum.VasQueueStatus.UnderAnHour;
		if (VASServiceType == Enum.VasServiceType.CharacterTransfer) then
			queueTime = transfer;
		elseif (VASServiceType == Enum.VasServiceType.FactionChange) then
			queueTime = factionTransfer;
		end
		if (queueTime > Enum.VasQueueStatus.UnderAnHour) then
				self.Disclaimer:SetTextColor(_G.RED_FONT_COLOR:GetRGB());
		else
				self.Disclaimer:SetTextColor(0, 0, 0);
		end
		local currencyInfo = currencyInfo();
		local vasDisclaimerData = currencyInfo.vasDisclaimerData;
		self.Disclaimer:SetText(HTML_START_CENTERED..string.format(vasDisclaimerData[VASServiceType].disclaimer, _G["VAS_QUEUE_"..VasQueueStatusToString[queueTime]])..HTML_END);
	end
end

function StoreVASValidationFrame_SetErrors(errors)
	local characters = C_StoreSecure.GetCharactersForRealm(SelectedRealm);
	local character = characters[SelectedCharacter];
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
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
	if (VASServiceType == Enum.VasServiceType.NameChange) then
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", frame.NewCharacterName, "BOTTOMLEFT", -5, -6);
	elseif (VASServiceType == Enum.VasServiceType.CharacterTransfer) then
		StoreVASValidationFrame_UpdateCharacterTransferValidationPosition();
	else
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", frame.SelectedCharacterFrame, "BOTTOMLEFT", 8, -24);
	end
	frame.Spinner:Hide();
	frame.RealmSelector.Button:Enable();
	frame.CharacterSelector.Button:Enable();
	frame.ValidationDescription:SetFontObject("GameFontBlackSmall2");
	frame.ValidationDescription:SetTextColor(1.0, 0.1, 0.1);
	frame.ValidationDescription:SetText(desc);
	frame.ValidationDescription:Show();
	StoreVASValidationState_Unlock();
	frame.ContinueButton:Show();
	frame.ContinueButton:Disable();
end

function StoreVASValidationFrame_OnVasProductComplete(self)
	local productID, guid, realmName, shouldHandle = C_StoreSecure.GetVASCompletionInfo();
	if (not productID) then
		return;
	end
	local productInfo = C_StoreSecure.GetProductInfo(productID);
	if (IsOnGlueScreen()) then
		self:GetParent():Hide();
		_G.StoreFrame_ShowGlueDialog(string.format(_G.BLIZZARD_STORE_VAS_PRODUCT_READY, productInfo.sharedData.name), guid, realmName, shouldHandle);
	else
		self:GetParent():Hide();

		local titleOverride = string.format(BLIZZARD_STORE_PRODUCT_IS_READY, productInfo.sharedData.name);
		local descriptionOverride = (productInfo.sharedData.vasServiceType == Enum.VasServiceType.NameChange) and BLIZZARD_STORE_NAME_CHANGE_READY_DESCRIPTION or BLIZZARD_STORE_VAS_SERVICE_READY_DESCRIPTION;
		ServicesLogoutPopup_SetShowReason(ServicesLogoutPopup, "forVasService", titleOverride, descriptionOverride);
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

function StoreVASValidationState_Lock()
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	frame.RealmSelector.Button:Disable();
	frame.CharacterSelector.Button:Disable();
	frame.TransferRealmCheckbox:Disable();
	frame.TransferRealmEditbox:Disable();
	frame.TransferAccountCheckbox:Disable();
	frame.TransferAccountDropDown.Button:Disable();
	frame.TransferFactionCheckbox:Disable();
	frame.TransferBattlenetAccountEditbox:Disable();
	frame.TransferBnetWoWAccountDropDown.Button:Disable();
	frame.NewCharacterName:Disable();
	frame.ContinueButton:Disable();
end

function StoreVASValidationState_Unlock()
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	frame.RealmSelector.Button:Enable();
	frame.CharacterSelector.Button:Enable();
	frame.TransferRealmCheckbox:Enable();
	frame.TransferRealmEditbox:Enable();
	frame.TransferAccountCheckbox:Enable();
	frame.TransferAccountDropDown.Button:Enable();
	frame.TransferFactionCheckbox:Enable();
	frame.TransferBattlenetAccountEditbox:Enable();
	frame.TransferBnetWoWAccountDropDown.Button:Enable();
	frame.NewCharacterName:Enable();
	frame.ContinueButton:Enable();
end

-------------------------------
local isRotating = false;

function StoreProductCard_UpdateState(card)
	-- No product associated with this card
	if (card:GetID() == 0 or not card:IsShown()) then return end;

	if (card.HighlightTexture) then
		local entryID = card:GetID();
		local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
		local enableHighlight = card:GetID() ~= selectedEntryID and not isRotating and (entryInfo.sharedData.productDecorator ~= Enum.BattlepayProductDecorator.VasService or IsOnGlueScreen());
		card.HighlightTexture:SetAlpha(enableHighlight and 1 or 0);
		if (not card.Description and GetMouseFocus() == card) then
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
				local name = entryInfo.sharedData.name:gsub("|n", " ");
				local description = entryInfo.sharedData.description;
				StoreTooltip:ClearAllPoints();
				StoreTooltip:SetPoint(point, card, rpoint, xoffset, 0);
				if (entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.VasService and not IsOnGlueScreen()) then
					name = "";
					description = BLIZZARD_STORE_LOG_OUT_TO_PURCHASE_THIS_PRODUCT;
				end
				StoreTooltip_Show(name, description, entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.WoWToken);
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
	local entryInfo = C_StoreSecure.GetEntryInfo(self:GetID());
	if (entryInfo.sharedData.productDecorator ~= Enum.BattlepayProductDecorator.VasService or IsOnGlueScreen()) then
		if (self.HighlightTexture) then
			self.HighlightTexture:SetShown(selectedEntryID ~= self:GetID());
		end
		if (self.Magnifier and self.ModelScene:IsShown() and self ~= StoreFrame.SplashSingle) then
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

function StoreProductCard_CheckShowStorePreviewOnClick(self)
	local showPreview;
	if ( IsOnGlueScreen() ) then
		showPreview = _G.IsControlKeyDown();
	else
		showPreview = IsModifiedClick("DRESSUP");
	end
	if ( showPreview ) then
		if ( entryInfo.displayID ) then
			StoreFrame_ShowPreview(entryInfo.name, entryInfo.displayID, entryInfo.modelSceneID);
		end
	end

	return showPreview;
end

function StoreProductCard_OnClick(self,button,down)
	local entryInfo = C_StoreSecure.GetEntryInfo(self:GetID());
	if (entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.VasService and not IsOnGlueScreen()) then
		return;
	end

	if ( not StoreProductCard_CheckShowStorePreviewOnClick(self) ) then
		selectedEntryID = self:GetID();
		StoreProductCard_UpdateAllStates();

		StoreFrame_UpdateBuyButton();
		PlaySound("UI_igStore_PageNav_Button");
	end
end

function StoreProductCard_OnMouseDown(self, ...)
	self.ModelScene:OnMouseDown(...);
end

function StoreProductCard_OnMouseUp(self, ...)
	self.ModelScene:OnMouseUp(...);
end

local basePoints = {};

function StoreProductCard_OnLoad(self)
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
end

function StoreSplashSingleProductCard_OnClick(self)
	StoreProductCard_CheckShowStorePreviewOnClick(self);
end

function StoreProductCard_SetModel(self, modelID, owned, modelSceneID, forceModelUpdate)
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

	self.ModelScene:Show();
	self.Shadows:SetShown(self ~= StoreFrame.SplashSingle);
	self.ModelScene:Show();
	self.ModelScene:SetFromModelSceneID(modelSceneID, forceModelUpdate);

	local item = self.ModelScene:GetActorByTag("item");
	if ( item ) then
		item:SetModelByCreatureDisplayID(modelID);
		item:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_NONE);
	end

	if ( owned ) then
		self.Checkmark:Show();
	end
	if (self == StoreFrame.SplashSingle) then
		self.Magnifier:Show();
	end
end

function StoreProductCard_ShowIcon(self, icon, itemID, overrideTexture)
	self.ModelScene:Hide();
	self.Shadows:Hide();

	if (self.Magnifier) then
		self.Magnifier:Hide();
	end

	self.IconBorder:Show();
	self.Icon:Show();
	self.InvisibleMouseOverFrame:SetShown(itemID);

	if (not overrideTexture) then
		if (self == StoreFrame.SplashSingle) then
			self.Icon:SetPoint("TOPLEFT", 88, -99);
		end
		self.Icon:SetSize(64, 64);
		SetPortraitToTexture(self.Icon, icon);
		self.IconBorder:Show();
	else
		self.Icon:SetAtlas(overrideTexture, true);
		if (self == StoreFrame.SplashSingle) then
			local adjustX, adjustY;
			local width, height = self.Icon:GetSize();
			if (width > 64) then
				adjustX = -(width - 64);
			else
				adjustX = 64 - width;
			end

			if (height > 64) then
				adjustY = height - 64;
			else
				adjustY = -(64 - height);
			end

			self.Icon:SetPoint("TOPLEFT", 88 + math.floor(adjustX / 2), -99 + math.floor(adjustY / 2));
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
	local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
	StoreFrame_ShowPreview(entryInfo.sharedData.name, entryInfo.sharedData.displayID, entryInfo.sharedData.modelSceneID);
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
	local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
	local modelID = self:GetID();
	StoreFrame_ShowPreview(entryInfo.sharedData.name, modelID, entryInfo.sharedData.modelSceneID);
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
	local entryInfo = C_StoreSecure.GetEntryInfo(entryID);

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

	if entryInfo.sharedData.itemID then
		self.hasItemTooltip = true;
		StoreTooltip:Hide();
		Outbound.SetItemTooltip(entryInfo.sharedData.itemID, x, y, point);
	end
end

function StoreProductCardItem_OnLeave(self)
	StoreProductCard_OnLeave(self:GetParent());
	StoreProductCard_UpdateState(self:GetParent());

	if self.hasItemTooltip then
		Outbound.ClearItemTooltip();
		self.hasItemTooltip = false;
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
			description = description .. string.format(BLIZZARD_STORE_TOKEN_CURRENT_MARKET_PRICE, GetSecureMoneyString(price));
		else
			description = description .. string.format(BLIZZARD_STORE_TOKEN_CURRENT_MARKET_PRICE, TOKEN_MARKET_PRICE_NOT_AVAILABLE);
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
	local modelFrameLevel = card.ModelScene:GetFrameLevel();
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
local InfoTable = nil;
local InfoCallback = nil;
local InfoFrame = nil;
local DropDownOffset = 0;
local DropDownMaxButtons = 20;

-- Very simple dropdown.  infoTable contains infoEntries containing text and value, the callback is what is called when a button is clicked.
function StoreDropDown_SetDropdown(frame, infoTable, callback)
	for list, _ in pairs(StoreDropdownLists) do
		list:Hide();
	end

	if (not StoreDropdownLists[frame.List]) then
		StoreDropdownLists[frame.List] = true;
	end

	InfoFrame = frame;
	InfoCallback = callback;
	InfoTable = infoTable;
	DropDownOffset = 0;

	StoreDropDownMenu_SetUpButtons();

	frame.List:Show();
end

function StoreDropDownMenu_PreviousOnClick(self)
	DropDownOffset = math.max(0, DropDownOffset - DropDownMaxButtons);
	StoreDropDownMenu_SetUpButtons();
end

function StoreDropDownMenu_NextOnClick(self)
	DropDownOffset = math.min(DropDownOffset + DropDownMaxButtons, #InfoTable);
	StoreDropDownMenu_SetUpButtons();
end

function StoreDropDownMenu_SetUpButtons()
	local buttonHeight = 16;
	local spacing = 0;
	local verticalPadding = 32;
	local horizontalPadding = 24;
	local numButtons = 0;
	local buttonOffset = 0;
	local frame = InfoFrame;
	local hasMore = DropDownOffset + DropDownMaxButtons < #InfoTable;

	if (DropDownOffset > 0) then
		local button = frame.List.Buttons[1];
		button:SetText(BLIZZARD_STORE_VAS_PREVIOUS_ENTRIES);
		button:SetScript("OnClick", StoreDropDownMenu_PreviousOnClick);
		button:SetWidth(frame.List:GetWidth() - horizontalPadding);
		button:SetHeight(buttonHeight);
		button:Show();
		button.Check:Hide();
		button.UnCheck:Hide();
		buttonOffset = 1;
		numButtons = numButtons + 1;
	end

	for i = 1, DropDownMaxButtons do
		local buttonIndex = i + buttonOffset;
		local infoIndex = i + DropDownOffset;
		local info = InfoTable[infoIndex];

		if (not info) then
			break;
		end

		local button;
		if (not frame.List.Buttons[buttonIndex]) then
			button = CreateForbiddenFrame("Button", nil, frame.List, "StoreDropDownMenuButtonTemplate");
			StoreDropDownMenuMenuButton_OnLoad(button);
			button:SetPoint("TOPLEFT", frame.List.Buttons[buttonIndex-1], "BOTTOMLEFT", 0, -spacing);
		else
			button = frame.List.Buttons[buttonIndex];
		end

		button:SetText(info.text);
		button:SetWidth(frame.List:GetWidth() - horizontalPadding);
		button:SetHeight(buttonHeight);
		button:SetScript("OnClick", StoreDropDownMenuMenuButton_OnClick);
		button.index = infoIndex;

		if (info.checked) then
			button.Check:Show();
			button.UnCheck:Hide();
		else
			button.UnCheck:Show();
			button.Check:Hide();
		end
		button:Show();

		numButtons = numButtons + 1;
	end

	if (hasMore) then
		local buttonIndex = numButtons + 1;
		local button;
		if (not frame.List.Buttons[buttonIndex]) then
			button = CreateForbiddenFrame("Button", nil, frame.List, "StoreDropDownMenuButtonTemplate", buttonIndex);
			StoreDropDownMenuMenuButton_OnLoad(button);
			button:SetPoint("TOPLEFT", frame.List.Buttons[buttonIndex-1], "BOTTOMLEFT", 0, -spacing);
		else
			button = frame.List.Buttons[buttonIndex];
		end
		button:SetText(BLIZZARD_STORE_VAS_NEXT_ENTRIES);
		button:SetScript("OnClick", StoreDropDownMenu_NextOnClick);
		button:SetWidth(frame.List:GetWidth() - horizontalPadding);
		button:SetHeight(buttonHeight);
		button:Show();
		button.Check:Hide();
		button.UnCheck:Hide();
		numButtons = numButtons + 1;
	end

	frame.List:SetHeight(verticalPadding + spacing*(numButtons-1) + buttonHeight*numButtons);

	for i = numButtons + 1, #frame.List.Buttons do
		if (frame.List.Buttons[i]) then
			frame.List.Buttons[i]:Hide();
		end
	end
end

function StoreDropDownMenu_OnHide(self)
	InfoTable = nil;
	InfoFrame = nil;
	InfoCallback = nil;
	DropDownOffset = 0;
end

function StoreDropDownMenuMenuButton_OnLoad(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel()+2);
	self:SetScript("OnClick", StoreDropDownMenuMenuButton_OnClick);
end

function StoreDropDownMenuMenuButton_OnClick(self, button)
	PlaySound("UChatScrollButton");
	if (not InfoTable or not InfoCallback) then
		-- This should not happen, it means our cache was cleared while the frame was opened.
		-- We probably want a GMError here.
		GMError("StoreDropDown cache was cleared while the frame was shown.");
		self:GetParent():Hide();
		return;
	end

	local value = InfoTable[self.index].value;
	InfoCallback(value);
	self:GetParent():Hide();
end

------------------------------------
function VASCharacterSelectionRealmSelector_Callback(value)
	SelectedRealm = value;
	SelectedCharacter = nil;
	RealmAutoCompleteList = nil;
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	frame.RealmSelector.Text:SetText(value);
	frame.CharacterSelector.Text:SetText(VAS_SELECT_CHARACTER);
	frame.CharacterSelector.Button:Enable();
	frame.ClassIcon:Hide();
	frame.SelectedCharacterName:Hide();
	frame.SelectedCharacterDescription:Hide();
	frame.SelectedCharacterFrame:Hide();
	frame.TransferRealmCheckbox:Hide();
	frame.TransferRealmCheckbox:SetChecked(false);
	frame.TransferRealmEditbox:Hide();
	frame.TransferRealmEditbox:SetText("");
	frame.TransferAccountCheckbox:Hide();
	frame.TransferAccountCheckbox:SetChecked(false);
	frame.TransferAccountDropDown:Hide();
	frame.TransferFactionCheckbox:Hide();
	frame.TransferFactionCheckbox:SetChecked(false);
	frame.TransferBattlenetAccountEditbox:Hide();
	frame.TransferBattlenetAccountEditbox:SetText("");
	frame.TransferBnetWoWAccountDropDown:Hide();
	frame.ValidationDescription:Hide();
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
	local characters = C_StoreSecure.GetCharactersForRealm(SelectedRealm);
	local character = characters[SelectedCharacter];
	local level = character.level;
	if (level == 0) then
		level = 1;
	end
	frame.CharacterSelector.Text:SetText(string.format(VAS_CHARACTER_SELECTION_DESCRIPTION, RAID_CLASS_COLORS[character.classFileName].colorStr, character.name, level, character.className));
	frame.SelectedCharacterFrame:Show();
	frame.ClassIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[character.classFileName]));
	frame.ClassIcon:Show();
	frame.SelectedCharacterName:SetText(character.name);
	frame.SelectedCharacterName:Show();
	frame.SelectedCharacterDescription:SetText(string.format(VAS_SELECTED_CHARACTER_DESCRIPTION, level, character.raceName, character.className));
	frame.SelectedCharacterDescription:Show();
	frame.ValidationDescription:SetFontObject("GameFontBlack");
	frame.ValidationDescription:SetTextColor(0, 0, 0);
	frame.ValidationDescription:Hide();

	StoreVASValidationState_Unlock();

	local bottomWidget = frame.SelectedCharacterFrame;
	if (VASServiceType == Enum.VasServiceType.NameChange) then
		frame.NewCharacterName:SetText("");
		frame.NewCharacterName:Show();
		frame.NewCharacterName:SetFocus();
		bottomWidget = frame.NewCharacterName;
		frame.ContinueButton:Disable();
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", bottomWidget, "BOTTOMLEFT", -5, -6);
	elseif (VASServiceType == Enum.VasServiceType.CharacterTransfer) then
		frame.TransferRealmCheckbox:Show();
		frame.TransferRealmCheckbox.Label:ApplyFontObjects();
		if (C_StoreSecure.GetCurrencyID() ~= CURRENCY_KRW) then
			frame.TransferAccountCheckbox:Show();
			frame.TransferAccountCheckbox.Label:ApplyFontObjects();
			frame.TransferFactionCheckbox:ClearAllPoints();
			frame.TransferFactionCheckbox:SetPoint("TOPLEFT", frame.TransferAccountCheckbox, "BOTTOMLEFT", 0, -4);
		else
			frame.TransferFactionCheckbox:ClearAllPoints();
			frame.TransferFactionCheckbox:SetPoint("TOPLEFT", frame.TransferRealmCheckbox, "BOTTOMLEFT", 0, -4);
		end
		frame.TransferRealmCheckbox:SetChecked(false);
		frame.TransferRealmEditbox:SetText("");
		frame.TransferRealmEditbox:Hide();
		frame.TransferBattlenetAccountEditbox:Hide();
		frame.TransferBattlenetAccountEditbox:SetText("");
		frame.TransferBnetWoWAccountDropDown:Hide();
		frame.TransferAccountCheckbox:SetChecked(false);
		frame.TransferAccountDropDown.Text:SetText(BLIZZARD_STORE_VAS_SELECT_ACCOUNT);
		frame.TransferAccountDropDown:Hide();
		frame.TransferFactionCheckbox:SetChecked(false);
		SelectedDestinationWowAccount = nil;
		SelectedDestinationBnetWowAccount = nil;
		local newFaction;
		if (character.faction == 0) then
			newFaction = FACTION_ALLIANCE;
		elseif (character.faction == 1) then
			newFaction = FACTION_HORDE;
		end
		-- We don't filter the character list, this prevents a lua error if a neutral pandarian is selected.
		if (newFaction) then
			local bundleProductInfo = C_StoreSecure.GetProductInfo(CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID);
			local baseProductInfo = C_StoreSecure.GetProductInfo(CHARACTER_TRANSFER_PRODUCT_ID);
			local bundlePrice = bundleProductInfo.sharedData.currentDollars + (bundleProductInfo.sharedData.currentCents / 100);
			local basePrice = baseProductInfo.sharedData.currentDollars + (baseProductInfo.sharedData.currentCents / 100);
			local diffPrice = bundlePrice - basePrice;
			local diffDollars = math.floor(diffPrice);
			local diffCents = (diffPrice - diffDollars) * 100;
			local info = currencyInfo();
			local format = info.formatLong;
			frame.TransferFactionCheckbox.Label:SetText(string.format(BLIZZARD_STORE_VAS_TRANSFER_FACTION_BUNDLE, newFaction, format(diffDollars, diffCents)));
		end
		frame.TransferFactionCheckbox:SetShown(newFaction ~= nil);
		if (frame.TransferFactionCheckbox:IsShown()) then
			frame.TransferFactionCheckbox.Label:ApplyFontObjects();
		end

		StoreVASValidationFrame_SyncFontHeights(frame.TransferRealmCheckbox.Label, frame.TransferAccountCheckbox.Label, frame.TransferFactionCheckbox.Label);
		frame.ContinueButton:Disable();
	else
		if (VASServiceType == Enum.VasServiceType.RaceChange) then
			local races = C_StoreSecure.GetEligibleRacesForRaceChange(character.guid);

			if (not races or #races == 0) then
				frame.ChangeIconFrame:Hide();
				frame.ValidationDescription:ClearAllPoints();
				frame.ValidationDescription:SetPoint("TOPLEFT", frame.SelectedCharacterFrame, "BOTTOMLEFT", 8, -8);
				frame.ValidationDescription:SetFontObject("GameFontBlackSmall2");
				frame.ValidationDescription:SetTextColor(1.0, 0.1, 0.1);
				frame.ValidationDescription:SetText(StoreVASValidationFrame_AppendError(BLIZZARD_STORE_VAS_ERROR_LABEL, Enum.VasError.RaceClassComboIneligible, character, true));
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
		elseif (VASServiceType == Enum.VasServiceType.FactionChange) then
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
				frame.ValidationDescription:SetText(StoreVASValidationFrame_AppendError(BLIZZARD_STORE_VAS_ERROR_LABEL, Enum.VasError.RaceClassComboIneligible, character, true));
				frame.ValidationDescription:Show();
				frame.ContinueButton:Disable();
				return;
			end
			bottomWidget = frame.ChangeIconFrame;
			VASCharacterSelectionChangeIconFrame_SetIcons(from, {to});

			frame.ValidationDescription:SetText(VAS_FACTION_CHANGE_VALIDATION_DESCRIPTION);
			frame.ValidationDescription:Show();
		elseif (VASServiceType == Enum.VasServiceType.AppearanceChange) then
			frame.ValidationDescription:SetText(VAS_APPEARANCE_CHANGE_VALIDATION_DESCRIPTION);
			frame.ValidationDescription:Show();
		end
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", bottomWidget, "BOTTOMLEFT", 8, -16);
		frame.ContinueButton:Enable();
	end
end

function VASRealmList_BuildAutoCompleteList()
	local realms = C_StoreSecure.GetVASRealmList();

	local characters = C_StoreSecure.GetCharactersForRealm(SelectedRealm);
	local character = characters[SelectedCharacter];

	local infoTable = {};
	for i = 1, #realms do
		if (realms[i].virtualRealmAddress ~= character.currentServer) then
			local pvp = realms[i].pvp;
			local rp = realms[i].rp;
			local name = realms[i].realmName;
			RealmRpPvpMap[name] = { rp=rp, pvp=pvp };
			infoTable[#infoTable + 1] = name;
			DestinationRealmMapping[name] = realms[i].virtualRealmAddress;
		end
	end

	RealmAutoCompleteList = infoTable;
end

function VASRealmList_GetAutoCompleteEntries(text, cursorPosition)
	if (text == "") then
		return {};
	end
	local entries = {};
	local str = string.lower(string.sub(text, 1, cursorPosition));
	for i, v in ipairs(RealmAutoCompleteList) do
		if (string.find(string.lower(v), str)) then
			table.insert(entries, v);
		end
	end
	return entries;
end

local VAS_AUTO_COMPLETE_MAX_ENTRIES = 10;
local VAS_AUTO_COMPLETE_OFFSET = 0;
local VAS_AUTO_COMPLETE_SELECTION = nil;
local VAS_AUTO_COMPLETE_ENTRIES = nil;

function VASCharacterSelectionTransferRealmEditBoxAutoCompleteButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");

	VAS_AUTO_COMPLETE_SELECTION = nil;
	VAS_AUTO_COMPLETE_OFFSET = 0;
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;

	frame.TransferRealmEditbox:SetText(self.info);
	frame.TransferRealmAutoCompleteBox:Hide();
end

function VASCharacterSelectionTransferRealmEditBox_UpdateAutoComplete(self, text, cursorPosition)
	if (not RealmAutoCompleteList) then
		VASRealmList_BuildAutoCompleteList();
	end
	VAS_AUTO_COMPLETE_ENTRIES = VASRealmList_GetAutoCompleteEntries(text, cursorPosition);

	if (text == VAS_AUTO_COMPLETE_ENTRIES[1]) then
		return;
	end

	local maxWidth = 0;
	local shownButtons = 0;
	local buttonOffset = 0;
	local box = self:GetParent().TransferRealmAutoCompleteBox;
	if (VAS_AUTO_COMPLETE_OFFSET > 0) then
		local button = box.Buttons[1];
		button.Text:SetText(BLIZZARD_STORE_VAS_REALMS_PREVIOUS);
		button:SetNormalFontObject("GameFontDisableTiny2");
		button:SetHighlightFontObject("GameFontDisableTiny2");
		button:SetScript("OnClick", StoreAutoCompleteGoBack_OnClick);
		buttonOffset = 1;
		shownButtons = 1;
	end

	local hasMore = (#VAS_AUTO_COMPLETE_ENTRIES - VAS_AUTO_COMPLETE_OFFSET) > VAS_AUTO_COMPLETE_MAX_ENTRIES;
	for i = 1 + buttonOffset, math.min(VAS_AUTO_COMPLETE_MAX_ENTRIES, (#VAS_AUTO_COMPLETE_ENTRIES - VAS_AUTO_COMPLETE_OFFSET)) + buttonOffset do
		local button = box.Buttons[i];
		if (not button) then
			button = CreateForbiddenFrame("Button", nil, box, "StoreAutoCompleteButtonTemplate");
			button:SetPoint("TOP", box.Buttons[i-1], "BOTTOM");
		end
		local entryIndex = i + VAS_AUTO_COMPLETE_OFFSET - buttonOffset;
		button:SetScript("OnClick", VASCharacterSelectionTransferRealmEditBoxAutoCompleteButton_OnClick);
		button.info = VAS_AUTO_COMPLETE_ENTRIES[entryIndex];
		local rpPvpInfo = RealmRpPvpMap[VAS_AUTO_COMPLETE_ENTRIES[entryIndex]];
		local tag = _G.VAS_PVE_PARENTHESES;
		if (rpPvpInfo.pvp and rpPvpInfo.rp) then
			tag = _G.VAS_RPPVP_PARENTHESES;
		elseif (rpPvpInfo.pvp) then
			tag = _G.VAS_PVP_PARENTHESES;
		elseif (rpPvpInfo.rp) then
			tag = _G.VAS_RP_PARENTHESES;
		end
		button:SetNormalFontObject("GameFontWhiteTiny2");
		button:SetHighlightFontObject("GameFontWhiteTiny2");
		button.Text:SetText(VAS_AUTO_COMPLETE_ENTRIES[entryIndex] .. " " .. tag);
		button:Show();
		if (i - buttonOffset == VAS_AUTO_COMPLETE_SELECTION) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
		shownButtons = shownButtons + 1;
	end

	if (hasMore) then
		local index = VAS_AUTO_COMPLETE_MAX_ENTRIES+1+buttonOffset;
		local button = box.Buttons[index];
		if (not button) then
			button = CreateForbiddenFrame("Button", nil, box, "StoreAutoCompleteButtonTemplate");
			button:SetPoint("TOP", box.Buttons[index-1], "BOTTOM");
		end
		button:SetScript("OnClick", StoreAutoCompleteHasMore_OnClick);
		button:SetNormalFontObject("GameFontDisableTiny2");
		button:SetHighlightFontObject("GameFontDisableTiny2");
		button.Text:SetText(string.format(BLIZZARD_STORE_VAS_REALMS_AND_MORE, (#VAS_AUTO_COMPLETE_ENTRIES - VAS_AUTO_COMPLETE_OFFSET - VAS_AUTO_COMPLETE_MAX_ENTRIES)));
		button:Show();
		shownButtons = shownButtons + 1;
	end

	for i = shownButtons + 1, #box.Buttons do
		box.Buttons[i]:Hide();
	end

	if (#VAS_AUTO_COMPLETE_ENTRIES > 0) then
		box:SetHeight(22 + (shownButtons * box.Buttons[1]:GetHeight()));
		box:Show();
	else
		box:Hide();
	end
end

function StoreAutoCompleteGoBack_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");

	VAS_AUTO_COMPLETE_OFFSET = math.max(VAS_AUTO_COMPLETE_OFFSET - VAS_AUTO_COMPLETE_MAX_ENTRIES, 0);
	VAS_AUTO_COMPLETE_SELECTION = nil;

	local frame = StoreVASValidationFrame.CharacterSelectionFrame.TransferRealmEditbox;

	VASCharacterSelectionTransferRealmEditBox_UpdateAutoComplete(frame, frame:GetText(), frame:GetCursorPosition());
end

function StoreAutoCompleteHasMore_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");

	VAS_AUTO_COMPLETE_OFFSET = math.min(VAS_AUTO_COMPLETE_OFFSET + VAS_AUTO_COMPLETE_MAX_ENTRIES, #VAS_AUTO_COMPLETE_ENTRIES - 1);
	VAS_AUTO_COMPLETE_SELECTION = nil;

	local frame = StoreVASValidationFrame.CharacterSelectionFrame.TransferRealmEditbox;

	VASCharacterSelectionTransferRealmEditBox_UpdateAutoComplete(frame, frame:GetText(), frame:GetCursorPosition());
end

function StoreAutoCompleteIncrementSelection()
	if (VAS_AUTO_COMPLETE_OFFSET > 0 and VAS_AUTO_COMPLETE_SELECTION == #VAS_AUTO_COMPLETE_ENTRIES - VAS_AUTO_COMPLETE_OFFSET) then
		return;
	elseif (VAS_AUTO_COMPLETE_SELECTION == VAS_AUTO_COMPLETE_MAX_ENTRIES) then
		if (VAS_AUTO_COMPLETE_OFFSET + VAS_AUTO_COMPLETE_MAX_ENTRIES < #VAS_AUTO_COMPLETE_ENTRIES) then
			VAS_AUTO_COMPLETE_OFFSET = VAS_AUTO_COMPLETE_OFFSET + 1;
		end
	elseif (VAS_AUTO_COMPLETE_SELECTION and (VAS_AUTO_COMPLETE_SELECTION + VAS_AUTO_COMPLETE_OFFSET) < #VAS_AUTO_COMPLETE_ENTRIES) then
		VAS_AUTO_COMPLETE_SELECTION = VAS_AUTO_COMPLETE_SELECTION + 1;
	elseif (not VAS_AUTO_COMPLETE_SELECTION and #VAS_AUTO_COMPLETE_ENTRIES > 0) then
		VAS_AUTO_COMPLETE_SELECTION = 1;
	end

	local frame = StoreVASValidationFrame.CharacterSelectionFrame.TransferRealmEditbox;

	VASCharacterSelectionTransferRealmEditBox_UpdateAutoComplete(frame, frame:GetText(), frame:GetCursorPosition());
end

function StoreAutoCompleteDecrementSelection()
	if (VAS_AUTO_COMPLETE_SELECTION and #VAS_AUTO_COMPLETE_ENTRIES > 0) then
		if (VAS_AUTO_COMPLETE_SELECTION == 1 and VAS_AUTO_COMPLETE_OFFSET > 0) then
			VAS_AUTO_COMPLETE_OFFSET = VAS_AUTO_COMPLETE_OFFSET - 1;
		elseif (VAS_AUTO_COMPLETE_SELECTION > 1) then
			VAS_AUTO_COMPLETE_SELECTION = VAS_AUTO_COMPLETE_SELECTION - 1;
		end
		local frame = StoreVASValidationFrame.CharacterSelectionFrame.TransferRealmEditbox;

		VASCharacterSelectionTransferRealmEditBox_UpdateAutoComplete(frame, frame:GetText(), frame:GetCursorPosition());
	end
end

function StoreAutoCompleteSelectionEnterPressed()
	if (VAS_AUTO_COMPLETE_SELECTION) then
		local info = VAS_AUTO_COMPLETE_ENTRIES[VAS_AUTO_COMPLETE_SELECTION + VAS_AUTO_COMPLETE_OFFSET];
		VAS_AUTO_COMPLETE_SELECTION = nil;
		VAS_AUTO_COMPLETE_OFFSET = 0;
		local frame = StoreVASValidationFrame.CharacterSelectionFrame;

		frame.TransferRealmEditbox:SetText(info);
		frame.TransferRealmAutoCompleteBox:Hide();
	end
end

local function PlayCheckboxSound(self)
	local sound = "igMainMenuOptionCheckBoxOn";
	if (not self:GetChecked()) then
		sound = "igMainMenuOptionCheckBoxOff";
	end
	PlaySound(sound);
end

function TransferRealmCheckbox_OnClick(self)
	PlayCheckboxSound(self);
	if (not self:GetChecked()) then
		SelectedDestinationRealm = nil;
		self:GetParent().TransferRealmEditbox:SetText("");
		self:GetParent().TransferRealmAutoCompleteBox:Hide();
	end
	self:GetParent().TransferRealmEditbox:SetShown(self:GetChecked());
	VASCharacterSelectionTransferGatherAndValidateData();
end

function VASCharacterSelectionTransferRealmEditBox_OnCursorChanged(self)
	VAS_AUTO_COMPLETE_OFFSET = 0;
	VAS_AUTO_COMPLETE_SELECTION = nil;

	VASCharacterSelectionTransferRealmEditBox_UpdateAutoComplete(self, self:GetText(), self:GetCursorPosition());
end

function VASCharacterSelectionTransferRealmEditBox_OnTextChanged(self)
	VAS_AUTO_COMPLETE_OFFSET = 0;
	VAS_AUTO_COMPLETE_SELECTION = nil;

	self.EmptyText:SetShown(not self:GetText() or self:GetText() == "");
	VASCharacterSelectionTransferRealmEditBox_UpdateAutoComplete(self, self:GetText(), self:GetCursorPosition());

	VASCharacterSelectionTransferGatherAndValidateData();
end

function TransferRealmAutoCompleteBox_OnHide(self)
	VAS_AUTO_COMPLETE_OFFSET = 0;
	VAS_AUTO_COMPLETE_SELECTION = nil;
end

function TransferAccountCheckbox_OnClick(self)
	PlayCheckboxSound(self);
	if (not self:GetChecked()) then
		SelectedDestinationWowAccount = nil;
		SelectedDestinationBnetAccount = nil;
		SelectedDestinationBnetWowAccount = nil;
		self:GetParent().TransferBattlenetAccountEditbox:Hide();
		self:GetParent().TransferBattlenetAccountEditbox:SetText("");
		self:GetParent().TransferBnetWoWAccountDropDown:Hide();
		self:GetParent().TransferAccountDropDown.Text:SetText(BLIZZARD_STORE_VAS_SELECT_ACCOUNT);
		self:GetParent().TransferBnetWoWAccountDropDown.Text:SetText(BLIZZARD_STORE_VAS_SELECT_ACCOUNT);
	end
	self:GetParent().TransferAccountDropDown:SetShown(self:GetChecked());
	self:GetParent().TransferFactionCheckbox:SetShown(not self:GetChecked());
	if (self:GetChecked()) then
		self:GetParent().TransferFactionCheckbox:SetChecked(false);
		CharacterTransferFactionChangeBundle = false;
	end
	VASCharacterSelectionTransferGatherAndValidateData();
end

function VASCharacterSelectionTransferBattlenetAccountEditbox_OnTextChanged(self)
	self.EmptyText:SetShown(not self:GetText() or self:GetText() == "");

	IsVasBnetTransferValidated = false;
	self:GetParent().TransferBnetWoWAccountDropDown:Hide();

	VASCharacterSelectionTransferGatherAndValidateData();
end

function VASCharacterSelectionRealmSelector_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");

	if (self:GetParent().List:IsShown()) then
		self:GetParent().List:Hide();
		return;
	end

	local realms = C_StoreSecure.GetRealmList();

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
	local characters = C_StoreSecure.GetCharactersForRealm(SelectedRealm);
	for i = 1, #characters do
		local character = characters[i];
		local level = character.level;
		if (level == 0) then
			level = 1;
		end
		local str = string.format(VAS_CHARACTER_SELECTION_DESCRIPTION, RAID_CLASS_COLORS[character.classFileName].colorStr, character.name, level, character.className);
		infoTable[#infoTable+1] = {text=str, value=i, checked=(SelectedCharacter == i)};
	end

	StoreDropDown_SetDropdown(self:GetParent(), infoTable, VASCharacterSelectionCharacterSelector_Callback);
end

local TIMEOUT_SECS = 60; -- How long to wait for a response from the account server
local timeoutTicker;

function VASCharacterSelectionStartTimeout()
	VASCharacterSelectionCancelTimeout();
	timeoutTicker = NewSecureTicker(TIMEOUT_SECS, VASCharacterSelectionTimeout, 1);
end

function VASCharacterSelectionCancelTimeout()
	if (timeoutTicker) then
		SecureCancelTicker(timeoutTicker);
		timeoutTicker = nil;
	end
end

function VASCharacterSelectionTimeout()
	StoreVASValidationFrame_SetErrors({ "Other" });
end

function VASCharacterSelectionContinueButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");

	if (not SelectedRealm or not SelectedCharacter) then
		-- This should not happen, as this button should be disabled unless you have both selected.
		return;
	end

	StoreVASValidationState_Lock();
	VASCharacterSelectionStartTimeout();

	local characters = C_StoreSecure.GetCharactersForRealm(SelectedRealm);

	if (not characters[SelectedCharacter]) then
		-- This should not happen
		return;
	end

	local entryInfo = C_StoreSecure.GetEntryInfo(selectedEntryID);

	if (entryInfo.sharedData.productDecorator ~= Enum.BattlepayProductDecorator.VasService) then
		-- How did we get to this frame if this wasnt a vas service?
		return;
	end

	-- Glue screen only

	if ( VASServiceType == Enum.VasServiceType.NameChange ) then
		NewCharacterName = self:GetParent().NewCharacterName:GetText();

		local valid, reason = _G.IsCharacterNameValid(NewCharacterName);
		if ( not valid) then
			self:GetParent().ValidationDescription:SetFontObject("GameFontBlackSmall2");
			self:GetParent().ValidationDescription:SetTextColor(1.0, 0.1, 0.1);
			self:GetParent().ValidationDescription:SetText(_G[reason]);
			self:GetParent().ValidationDescription:Show();
			StoreVASValidationState_Unlock();
			self:GetParent().ContinueButton:Disable();
			return;
		end
	end
	if ( VASServiceType == Enum.VasServiceType.CharacterTransfer ) then
		if (SelectedDestinationWowAccount == BLIZZARD_STORE_VAS_DIFFERENT_BNET) then
			isBnet = true;
		else
			isBnet = false;
		end
	end

	if (isBnet and not IsVasBnetTransferValidated) then
		C_StoreSecure.ValidateBnetTransfer(SelectedDestinationBnetAccount);
		self:GetParent().ContinueButton:Hide();
		self:GetParent().Spinner:Show();
		return;
	end

	local wowAccountGUID, bnetAccountGUID;
	if (VASServiceType == Enum.VasServiceType.CharacterTransfer) then
		if (isBnet and SelectedDestinationBnetWowAccount) then
			bnetAccountGUID = C_StoreSecure.GetBnetTransferInfo();
			wowAccountGUID = C_StoreSecure.GetWoWAccountGUIDFromName(SelectedDestinationBnetWowAccount, false);
		elseif (SelectedDestinationWowAccount) then
			wowAccountGUID = C_StoreSecure.GetWoWAccountGUIDFromName(SelectedDestinationWowAccount, true);
		end
	end
	if ( C_StoreSecure.PurchaseVASProduct(entryInfo.productID, characters[SelectedCharacter].guid, NewCharacterName, DestinationRealmMapping[SelectedDestinationRealm], CharacterTransferFactionChangeBundle, wowAccountGUID, bnetAccountGUID) ) then
		WaitingOnConfirmation = true;
		WaitingOnConfirmationTime = GetTime();
		WaitingOnVASToCompleteToken = WaitingOnVASToComplete;
		StoreFrame_UpdateActivePanel(StoreFrame);
	end
end

function VASCharacterSelectionNewCharacterName_OnEnter(self)
 	StoreTooltip:ClearAllPoints();
	StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
	StoreTooltip_Show("", VAS_NAME_CHANGE_TOOLTIP);
end

function VASCharacterSelectionTransferAccountDropDown_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");

	if (self:GetParent().List:IsShown()) then
		self:GetParent().List:Hide();
		return;
	end
	local characters = C_StoreSecure.GetCharactersForRealm(SelectedRealm);
	local character = characters[SelectedCharacter];
	local gameAccounts = _G.C_Login.GetGameAccounts();
	local infoTable = {};
	for i, gameAccount in ipairs(gameAccounts) do
		if (C_StoreSecure.GetWoWAccountGUIDFromName(gameAccount, true) ~= character.wowAccount) then
			infoTable[#infoTable+1] = {text=gameAccount, value=gameAccount, checked=(SelectedDestinationWowAccount == gameAccount)};
		end
	end

	infoTable[#infoTable+1] = {text=BLIZZARD_STORE_VAS_DIFFERENT_BNET, value=BLIZZARD_STORE_VAS_DIFFERENT_BNET, checked=(SelectedDestinationWowAccount == BLIZZARD_STORE_VAS_DIFFERENT_BNET)};
	StoreDropDown_SetDropdown(self:GetParent(), infoTable, VASCharacterSelectionTransferAccountDropDown_Callback);
end

function VASCharacterSelectionTransferAccountDropDown_Callback(value)
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	SelectedDestinationWowAccount = value;
	frame.TransferAccountDropDown.Text:SetText(value);
	frame.TransferBattlenetAccountEditbox:SetText("");
	frame.TransferBattlenetAccountEditbox:SetShown(value == BLIZZARD_STORE_VAS_DIFFERENT_BNET);
	frame.TransferBnetWoWAccountDropDown:Hide();
	VASCharacterSelectionTransferGatherAndValidateData();
end

function TransferFactionCheckbox_OnClick(self)
	PlayCheckboxSound(self);
	CharacterTransferFactionChangeBundle = self:GetChecked();
	VASCharacterSelectionTransferGatherAndValidateData();
end

function StripWoWAccountLicenseInfo(gameAccount)
	if (string.find(gameAccount, '#')) then
		return string.gsub(gameAccount,'%d+\#(%d)','WoW%1');
	end
	return gameAccount;
end

function VASCharacterSelectionTransferBnetWoWAccountDropDown_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");

	if (self:GetParent().List:IsShown()) then
		self:GetParent().List:Hide();
		return;
	end

	local _, gameAccounts = C_StoreSecure.GetBnetTransferInfo();
	local infoTable = {};
	for i, gameAccount in ipairs(gameAccounts) do
		infoTable[#infoTable+1] = {text=StripWoWAccountLicenseInfo(gameAccount), value=gameAccount, checked=(SelectedDestinationBnetWowAccount == gameAccount)};
	end

	StoreDropDown_SetDropdown(self:GetParent(), infoTable, VASCharacterSelectionTransferBnetWoWAccountDropDown_Callback);
end

function VASCharacterSelectionTransferBnetWoWAccountDropDown_Callback(value)
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	SelectedDestinationBnetWowAccount = value;
	frame.TransferBnetWoWAccountDropDown.Text:SetText(StripWoWAccountLicenseInfo(value));
	VASCharacterSelectionTransferGatherAndValidateData();
end

function VASCharacterSelectionTransferCheckEditBoxes()
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	local valid = false;
	if (frame.TransferRealmCheckbox:GetChecked()) then
		valid = frame.TransferRealmEditbox:GetText() and frame.TransferRealmEditbox:GetText() ~= "";
	end
	local checkAccount = frame.TransferAccountCheckbox:GetChecked() and SelectedDestinationWowAccount == BLIZZARD_STORE_VAS_DIFFERENT_BNET;
	if (checkAccount) then
		local text = frame.TransferBattlenetAccountEditbox:GetText();
		valid = text and text ~= "" and string.find(text, ".+@.+\...+");
	end
	if (not frame.TransferRealmCheckbox:GetChecked() and not checkAccount) then
		valid = true;
	end
	return valid;
end

function VASCharacterSelectionTransferGatherAndValidateData()
	local noCheck = true;
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	local button = frame.ContinueButton;
	local characters = C_StoreSecure.GetCharactersForRealm(SelectedRealm);
	local character = characters[SelectedCharacter];

	StoreVASValidationFrame_UpdateCharacterTransferValidationPosition();

	if (not VASCharacterSelectionTransferCheckEditBoxes()) then
		button:Disable();
		return;
	end

	button:Disable();
	if (frame.TransferRealmCheckbox:GetChecked()) then
		noCheck = false;
		SelectedDestinationRealm = frame.TransferRealmEditbox:GetText();
		if (not DestinationRealmMapping[SelectedDestinationRealm] or DestinationRealmMapping[SelectedDestinationRealm] == character.currentServer) then
			return;
		end
	end
	if (frame.TransferAccountCheckbox:GetChecked()) then
		noCheck = false;
		if (SelectedDestinationWowAccount == nil) then
			return;
		elseif (SelectedDestinationWowAccount == BLIZZARD_STORE_VAS_DIFFERENT_BNET) then
			if (not IsVasBnetTransferValidated) then
				SelectedDestinationBnetAccount = frame.TransferBattlenetAccountEditbox:GetText();
			elseif (SelectedDestinationBnetWowAccount == nil) then
				return;
			end
		end
	end

	if (noCheck) then
		return;
	end

	button:Enable();
end

------------------------------------
function ServicesLogoutPopup_OnLoad(self)
	self.ConfirmButton:SetText(CHARACTER_UPGRADE_LOG_OUT_NOW);
	self.CancelButton:SetText(CHARACTER_UPGRADE_POPUP_LATER);
end

local servicesLogoutPopupTextMapping = {
	["forBoost"] = {
		title = CHARACTER_UPGRADE_READY,
		description = CHARACTER_UPGRADE_READY_DESCRIPTION,
		logoutButton = CHARACTER_UPGRADE_LOG_OUT_NOW,
	},

	["forClassTrialUnlock"] = {
		title = CHARACTER_UPGRADE_READY,
		description = CHARACTER_UPGRADE_CLASS_TRIAL_UNLOCK_READY_DESCRIPTION,
		logoutButton = ACCEPT,
	},

	["forVasService"] = {
		title = CHARACTER_UPGRADE_READY,
		description = CHARACTER_UPGRADE_READY_DESCRIPTION,
		logoutButton = CHARACTER_UPGRADE_LOG_OUT_NOW,
	},

	["forLegion"] = {
		title = BLIZZARD_STORE_LEGION_PURCHASE_READY,
		description = BLIZZARD_STORE_LEGION_PURCHASE_READY_DESCRIPTION,
		logoutButton = CHARACTER_UPGRADE_LOG_OUT_NOW,
	},
};

local function GetServicesLogoutPopupText(showReason, textKey, override)
	if override then
		return override;
	end

	local textTable = servicesLogoutPopupTextMapping[showReason];
	return textTable[textKey];
end

function ServicesLogoutPopup_SetShowReason(self, showReason, titleOverride, descriptionOverride)
	local titleText = GetServicesLogoutPopupText(showReason, "title", titleOverride);
	local description = GetServicesLogoutPopupText(showReason, "description", descriptionOverride);
	local buttonText = GetServicesLogoutPopupText(showReason, "logoutButton");

	ServicesLogoutPopup.Background.Title:SetText(titleText);
	ServicesLogoutPopup.Background.Description:SetText(description);
	ServicesLogoutPopup.Background.ConfirmButton:SetText(buttonText);

	self.showReason = showReason;

	ServicesLogoutPopup:Show();
end

function ServicesLogoutPopupConfirmButton_OnClick(self)
	local showReason = ServicesLogoutPopup.showReason;
	local doLogoutOnConfirm = true;

	if (showReason == "forClassTrialUnlock") then
		doLogoutOnConfirm = false;
		Outbound.ConfirmClassTrialApplyToken();
	elseif (showReason == "forBoost") then
		C_SharedCharacterServices.SetStartAutomatically(true, BoostProduct);
	elseif (showReason == "forVasService") then
		C_StoreSecure.SetVASProductReady(true);
	elseif (showReason == "forLegion") then
		C_StoreSecure.SetDisconnectOnLogout(true);
	end

	ServicesLogoutPopup.showReason = nil;

	if doLogoutOnConfirm then
		PlaySound("igMainMenuLogout");
		Outbound.Logout();
	else
		PlaySound("igMainMenuOptionCheckBoxOn");
	end

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
