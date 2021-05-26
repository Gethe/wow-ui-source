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
	Import("C_Login");
	Import("GlueParent_UpdateDialogs");
	Import("LE_AURORA_STATE_NONE");
	Import("LE_WOW_CONNECTION_STATE_IN_QUEUE");
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
local BoostType = nil;
local BoostDeliveredUsageGUID = nil;
local BoostDeliveredUsageReason = nil;
local VASReady = false;
local UnrevokeWaitingForProducts = false;
local WaitingOnVASToComplete = 0;
local WaitingOnVASToCompleteToken = nil;
local WasVeteran = false;
local StoreFrameHasBeenShown = false;
local CharacterWaitingOnGuildFollowInfo = nil;
local RealmWaitingOnGuildMasterInfo = nil;
local RealmWithGuildMasterInfo = nil;
local GuildMasterInfo = {};
local CharacterList = {};
local GuildMemberAutoCompleteList;
local GuildMemberNameToGuid = {};

--Imports
Import("bit");
Import("C_StoreSecure");
Import("C_CharacterServices");
Import("C_SharedCharacterServices");
Import("C_ClassTrial");
Import("C_AuthChallenge");
Import("C_Timer");
Import("C_WowTokenPublic");
Import("C_StorePublic");
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
Import("strtrim");
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
Import("IsTrialAccount");
Import("IsVeteranTrialAccount");
Import("GetURLIndexAndLoadURL");

--GlobalStrings
Import("BLIZZARD_STORE");
Import("BLIZZARD_STORE_ON_SALE");
Import("BLIZZARD_STORE_PURCHASED");
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
Import("BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES");
Import("BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES_EUR");
Import("BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES_KR");
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
Import("BLIZZARD_STORE_CURRENCY_FORMAT_JPY");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_CAD");
Import("BLIZZARD_STORE_CURRENCY_FORMAT_NZD");
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
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_KRW");
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
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_JPY");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_CAD");
Import("BLIZZARD_STORE_LICENSE_ACK_TEXT_NZD");
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
Import("BLIZZARD_STORE_ERROR_TITLE_CLIENT_RESTRICTED");
Import("BLIZZARD_STORE_ERROR_CLIENT_RESTRICTED");
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
Import("BLIZZARD_STORE_VAS_ERROR_CHARACTER_HAS_VAS_PENDING");
Import("BLIZZARD_STORE_VAS_ERROR_INVALID_DESTINATION_ACCOUNT");
Import("BLIZZARD_STORE_VAS_ERROR_INVALID_SOURCE_ACCOUNT");
Import("BLIZZARD_STORE_VAS_ERROR_DISALLOWED_SOURCE_ACCOUNT");
Import("BLIZZARD_STORE_VAS_ERROR_DISALLOWED_DESTINATION_ACCOUNT");
Import("BLIZZARD_STORE_VAS_ERROR_LOWER_BOX_LEVEL");
Import("BLIZZARD_STORE_VAS_ERROR_MAX_CHARACTERS_ON_SERVER");
Import("BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_DISTANT");
Import("BLIZZARD_STORE_VAS_ERROR_BOOSTED_TOO_RECENTLY");
Import("BLIZZARD_STORE_VAS_ERROR_NOT_GUILD_MASTER");
Import("BLIZZARD_STORE_VAS_ERROR_NOT_IN_GUILD");
Import("BLIZZARD_STORE_VAS_ERROR_NEW_LEADER_INVALID");
Import("BLIZZARD_STORE_VAS_ERROR_AUTHENTICATOR_INSUFFICIENT");
Import("BLIZZARD_STORE_VAS_ERROR_ALREADY_RENAME_FLAGGED");
Import("BLIZZARD_STORE_VAS_ERROR_GM_SENORITY_INSUFFICIENT");
Import("BLIZZARD_STORE_VAS_ERROR_OPERATION_ALREADY_IN_PROGRESS");
Import("BLIZZARD_STORE_VAS_ERROR_LOCKED_FOR_VAS");
Import("BLIZZARD_STORE_VAS_ERROR_MOVE_IN_PROGRESS");
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
Import("BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE");
Import("BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE");
Import("BLIZZARD_STORE_BOOST_UNREVOKED_CONSUMPTION");
Import("BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100");
Import("BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100_CN");
Import("STORE_CATEGORY_TRIAL_DISABLED_TOOLTIP");
Import("STORE_CATEGORY_VETERAN_DISABLED_TOOLTIP");
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
Import("VAS_RP_PARENTHESES");
Import("VAS_SELECT_CHARACTER_DISABLED");
Import("VAS_SELECT_CHARACTER");
Import("VAS_CHARACTER_LABEL");
Import("VAS_SELECT_REALM");
Import("VAS_REALM_LABEL");
Import("VAS_CHARACTER_SELECTION_DESCRIPTION");
Import("VAS_SELECTED_CHARACTER_DESCRIPTION");
Import("VAS_NEW_CHARACTER_NAME_LABEL");
Import("VAS_NAME_CHANGE_TOOLTIP");
Import("VAS_TRANSFER_REALM_TOOLTIP");
Import("VAS_NEW_GUILD_NAME_LABEL");
Import("VAS_GUILD_NAME_CHANGE_TOOLTIP");
Import("VAS_GUILD_NAME_CHANGE_TRANSFER_TOOLTIP");
Import("VAS_GUILD_FACTION_NAME_CHANGE_CHECKBOX_TOOLTIP");
Import("VAS_NEW_GUILD_MASTER_FACTION_CHANGE_TOOLTIP");
Import("VAS_NEW_GUILD_MASTER_TRANSFER_TOOLTIP");
Import("VAS_OLD_GUILD_NEW_NAME_CHANGE_TOOLTIP");
Import("VAS_NEW_GUILD_MASTER_LABEL");
Import("VAS_NEW_GUILD_MASTER_EMPTY_TEXT");
Import("VAS_OLD_GUILD_NEW_NAME_LABEL");
Import("VAS_OLD_GUILD_NEW_NAME_EMPTY_TEXT");
Import("VAS_DESTINATION_REALM_LABEL");
Import("VAS_NAME_CHANGE_CONFIRMATION");
Import("VAS_GUILD_FACTION_CHANGE_CONFIRMATION");
Import("VAS_GUILD_FACTION_CHANGE_PLUS_NAME_CHANGE_CONFIRMATION");
Import("VAS_GUILD_TRANSFER_CONFIRMATION");
Import("VAS_GUILD_TRANSFER_PLUS_NAME_CHANGE_CONFIRMATION");
Import("VAS_GUILD_TRANSFER_PLUS_FACTION_CHANGE_CONFIRMATION");
Import("VAS_GUILD_TRANSFER_PLUS_NAME_AND_FACTION_CHANGE_CONFIRMATION");
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
Import("BLIZZARD_STORE_VAS_AUTOCOMPLETE_AND_MORE");
Import("BLIZZARD_STORE_VAS_REALMS_PREVIOUS");
Import("BLIZZARD_STORE_VAS_ERROR_INVALID_BNET_ACCOUNT");
Import("BLIZZARD_STORE_VAS_PREVIOUS_ENTRIES");
Import("BLIZZARD_STORE_VAS_NEXT_ENTRIES");
Import("BLIZZARD_STORE_VAS_RENAME_GUILD");
Import("BLIZZARD_STORE_VAS_FOLLOW_GUILD_TRANSFER");
Import("BLIZZARD_STORE_VAS_FOLLOW_GUILD_FACTION_TRANSFER");
Import("BLIZZARD_STORE_VAS_FOLLOW_GUILD_FACTION_CHANGE");
Import("BLIZZARD_STORE_VAS_FOLLOW_GUILD_TRANSFER_ERROR");
Import("BLIZZARD_STORE_VAS_FOLLOW_GUILD_FACTION_TRANSFER_ERROR");
Import("BLIZZARD_STORE_VAS_ERROR_NO_ELIGIBLE_CHARACTERS");
Import("BLIZZARD_STORE_VAS_ERROR_NO_GUILD_MASTERS");
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
Import("HTML_START");
Import("HTML_START_CENTERED");
Import("HTML_END");
Import("BLIZZARD_STORE_BUNDLE_DISCOUNT_BANNER");
Import("BLIZZARD_STORE_BUNDLE_DISCOUNT_TOOLTIP_ADDENDUM");
Import("BLIZZARD_STORE_BUNDLE_DISCOUNT_TOOLTIP_REPLACEMENT");
Import("BLIZZARD_STORE_BUNDLE_TOOLTIP_OWNED_DELIVERABLE");
Import("BLIZZARD_STORE_BUNDLE_TOOLTIP_UNOWNED_DELIVERABLE");

Import("WOW_GAMES_CATEGORY_ID");
Import("WOW_GAME_TIME_CATEGORY_ID");
Import("WOW_SUBSCRIPTION_CATEGORY_ID");

--Lua enums
Import("SOUNDKIT");
Import("LE_MODEL_BLEND_OPERATION_NONE");

--Lua constants
local WOW_TOKEN_CATEGORY_ID = 30;

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
local CURRENCY_JPY = 28;
local CURRENCY_CAD = 29;
local CURRENCY_NZD = 30;
local NUM_STORE_PRODUCT_CARDS = 8;
local NUM_STORE_PRODUCT_CARD_ROWS = 2;
local NUM_STORE_PRODUCT_CARDS_PER_ROW = 4;
local ROTATIONS_PER_SECOND = .5;
local COPPER_PER_SILVER = 100;
local SILVER_PER_GOLD = 100;
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD;
local WOW_SERVICES_CATEGORY_ID = 22;
local PI = math.pi;

local CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID = 239;
local CHARACTER_TRANSFER_PRODUCT_ID = 189;
local GUILD_TRANSFER_FACTION_BUNDLE_PRODUCT_ID = 477;
local GUILD_TRANSFER_PRODUCT_ID = 476;

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

local function currencyFormatJPY(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_JPY, formatCurrency(dollars, cents, false));
end

local function currencyFormatCAD(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_CAD, formatCurrency(dollars, cents, false));
end

local function currencyFormatNZD(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_FORMAT_NZD, formatCurrency(dollars, cents, false));
end

local function GetFactionIcon(faction, returnOpposite)
	if faction ~= 0 and faction ~= 1 then
		return "";
	end

	if returnOpposite then
		faction = (faction == 0) and 1 or 0;
	end

	if faction == 0 then
		return "Interface\\Icons\\inv_misc_tournaments_banner_orc";
	elseif faction == 1 then
		return "Interface\\Icons\\achievement_pvp_a_16";
	end
end

local function GetFactionName(faction, returnOpposite)
	if faction ~= 0 and faction ~= 1 then
		return "";
	end

	if returnOpposite then
		faction = (faction == 0) and 1 or 0;
	end

	if (faction == 0) then
		return FACTION_HORDE;
	elseif (faction == 1) then
		return FACTION_ALLIANCE;
	end
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

function StoreFrame_HasPriceData(productID)
	return not C_StoreSecure.IsDynamicBundle(productID) or C_StoreSecure.HasDynamicPriceData(productID);
end

function StoreFrame_GetProductPriceText(entryInfo, currencyFormat)
	local productID = entryInfo.productID;
	if not StoreFrame_HasPriceData(productID) then
		return "";
	else
		return currencyFormat(entryInfo.sharedData.currentDollars, entryInfo.sharedData.currentCents);
	end
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES_EUR,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES_KR,
		expansionConfirmationNotice = BLIZZARD_STORE_SECOND_CHANCE_KR,
		browseWarning = BLIZZARD_STORE_SECOND_CHANCE_KR,
		paymentMethodText = "",
		paymentMethodSubtext = "",
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_KRW,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES_EUR,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES_EUR,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
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
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_TEST,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
			},
		},
	},
	[CURRENCY_JPY] = {
		formatShort = currencyFormatJPY,
		formatLong = currencyFormatJPY,
		browseNotice = "",
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_JPY,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
			},
		},
	},
	[CURRENCY_CAD] = {
		formatShort = currencyFormatCAD,
		formatLong = currencyFormatCAD,
		browseNotice = "",
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_CAD,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
			},
		},
	},
	[CURRENCY_NZD] = {
		formatShort = currencyFormatNZD,
		formatLong = currencyFormatNZD,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_NZD,
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
			[Enum.VasServiceType.GuildNameChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE,
			},
			[Enum.VasServiceType.GuildFactionChange] = {
				disclaimer = BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE,
			},
		},
	},
};

function StoreFrame_CurrencyInfo()
	local currency = C_StoreSecure.GetCurrencyID();
	local info = currencySpecific[currency];
	return info;
end

function StoreFrame_CurrencyFormatShort(...)
	local info = StoreFrame_CurrencyInfo();
	return info.formatShort(...);
end

local function currencyFormatLong(...)
	local info = StoreFrame_CurrencyInfo();
	return info.formatLong(...);
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
	[Enum.StoreError.ClientRestricted] = {
		title = BLIZZARD_STORE_ERROR_TITLE_CLIENT_RESTRICTED,
		msg = BLIZZARD_STORE_ERROR_CLIENT_RESTRICTED,
	},
};

--VAS Error message data
local vasErrorData = {
	[Enum.VasError.CharacterHasVasPending] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CHARACTER_HAS_VAS_PENDING,
		notUserFixable = true,
	},
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
	[Enum.VasError.OperationAlreadyInProgress] = {
		msg = BLIZZARD_STORE_VAS_ERROR_OPERATION_ALREADY_IN_PROGRESS,
	},
	[Enum.VasError.LockedForVas] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LOCKED_FOR_VAS,
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
	[Enum.VasError.MoveInProgress] = {
		msg = BLIZZARD_STORE_VAS_ERROR_MOVE_IN_PROGRESS,
	},
	[Enum.VasError.UnderMinLevelReq] = {
		msg = BLIZZARD_STORE_VAS_ERROR_UNDER_MIN_LEVEL_REQ,
	},
	[Enum.VasError.CharacterTransferTooSoon] = {
		msg = BLIZZARD_STORE_VAS_ERROR_FACTION_CHANGE_TOO_SOON,
	},
	[Enum.VasError.CharLocked] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CHARACTER_LOCKED,
		notUserFixable = true,
	},
	[Enum.VasError.TooMuchMoneyForLevel] = {
		msg = function(character)
			local str = "";
			if (character.level >= 50) then
				-- level 50+: one million gold
				str = GetSecureMoneyString(1000000 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			elseif (character.level >= 40) then
				-- level 10-49: two hundred fifty thousand gold
				str = GetSecureMoneyString(250000 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			elseif (character.level >= 10) then
				-- level 10-49: ten thousand gold
				str = GetSecureMoneyString(10000 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			end
			return string.format(BLIZZARD_STORE_VAS_ERROR_TOO_MUCH_MONEY_FOR_LEVEL, str);
		end
	},
	[Enum.VasError.HasAuctions] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_AUCTIONS,
	},
	[Enum.VasError.LastSaveTooRecent] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_RECENT,
		notUserFixable = true,
	},
	[Enum.VasError.NameNotAvailable] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NAME_NOT_AVAILABLE,
	},
	[Enum.VasError.LastRenameTooRecent] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_RENAME_TOO_RECENT,
	},
	[Enum.VasError.AlreadyRenameFlagged] = {
		msg = BLIZZARD_STORE_VAS_ERROR_ALREADY_RENAME_FLAGGED,
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
	[Enum.VasError.GuildRankInsufficient] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NOT_GUILD_MASTER,
	},
	[Enum.VasError.CharacterWithoutGuild] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NOT_IN_GUILD,
	},
	[Enum.VasError.GmSeniorityInsufficient] = {
		msg = BLIZZARD_STORE_VAS_ERROR_GM_SENORITY_INSUFFICIENT,
	},
	[Enum.VasError.AuthenticatorInsufficient] = {
		msg = BLIZZARD_STORE_VAS_ERROR_AUTHENTICATOR_INSUFFICIENT,
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
	[Enum.VasError.LastSaveTooDistant] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_DISTANT,
	},
	[Enum.VasError.HasCagedBattlePet] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_CAGED_BATTLE_PET,
	},
	[Enum.VasError.BoostedTooRecently] = {
		msg = BLIZZARD_STORE_VAS_ERROR_BOOSTED_TOO_RECENTLY,
		notUserFixable = true,
	},
	[Enum.VasError.NewLeaderInvalid] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NEW_LEADER_INVALID,
	},
	[Enum.VasError.NeedsLevelSquish] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_DISTANT,
	},
};

local factionColors = {
	[0] = "ffe50d12",
	[1] = "ff4a54e8",
};

--template list from Blizzard_ProductCardTemplates.xml
local productCardTemplateData = {
	SmallStoreCardTemplate = {
		cellGridSize = {width = 1, height = 1},
		cellPixelSize = {width = 146, height = 209},
		padding = {6 , -6 , 6 , 0}, --left, right, top, bottom
		poolSize = 8,
		buyButton = false,
	},
	MediumStoreCardTemplate = {
		cellGridSize = {width = 2, height = 1},
		cellPixelSize = {width = 146 * 2, height = 209},
		padding = {6 , -6 , 6 , 0}, --left, right, top, bottom
		poolSize = 4,
		buyButton = false,
	},
	HorizontalLargeStoreCardTemplate = {
		cellGridSize = {width = 4, height = 1},
		cellPixelSize = {width = 576, height = 209},
		padding = {6 , 0 , 6 , 0}, --left, right, top, bottom
		poolSize = 2,
		buyButton = false,
	},
	VerticalLargeStoreCardTemplate = {
		cellGridSize = {width = 2, height = 2},
		cellPixelSize = {width = 286, height = 209 * 2},
		padding = {6 , 0 , 6 , 0}, --left, right, top, bottom
		poolSize = 2,
		buyButton = false,
	},
	MediumStoreCardWithBuyButtonTemplate = {
		cellGridSize = {width = 2, height = 1},
		cellPixelSize = {width = 277, height = 224},
		padding = {15 , -3 , 15 , 15}, --left, right, top, bottom
		poolSize = 4,
		buyButton = true,
	},
	HorizontalLargeStoreCardWithBuyButtonTemplate = {
		cellGridSize = {width = 4, height = 1},
		cellPixelSize = {width = 566, height = 225},
		padding = {15 , 6 , 15 , 14}, --left, right, top, bottom
		poolSize = 2,
		buyButton = true,
	},
	VerticalLargeStoreCardWithBuyButtonTemplate = {
		cellGridSize = {width = 2, height = 2},
		cellPixelSize = {width = 286, height = 471},
		padding = {10 , -6 , 10 , 0}, --left, right, top, bottom
		poolSize = 2,
		buyButton = true,
	},
	HorizontalFullStoreCardWithBuyButtonTemplate = {
		cellGridSize = {width = 4, height = 2},
		cellPixelSize = {width = 576, height = 471},
		padding = {12 , 0 , 9 , 0}, --left, right, top, bottom
		poolSize = 1,
		buyButton = true,
	},	
	VerticalFullStoreCardWithBuyButtonTemplate = {
		cellGridSize = {width = 4, height = 2},
		cellPixelSize = {width = 576, height = 471},
		padding = {12 , 0 , 9 , 0}, --left, right, top, bottom
		poolSize = 1,
		buyButton = true,
	},
	HorizontalFullStoreCardWithNydusLinkButtonTemplate = {
		cellGridSize = {width = 4, height = 2},
		cellPixelSize = {width = 576, height = 471},
		padding = {12 , 0 , 9 , 0}, --left, right, top, bottom
		poolSize = 1,
		buyButton = true
	},
};

function StoreFrame_GetCellPixelSize(cardTemplate)
	local pixelSize = productCardTemplateData[cardTemplate].cellPixelSize;
	local width = pixelSize.width;
	local height = pixelSize.height;
	return width, height;
end

--Code
local function getIndex(tbl, value) --testing post-commit-hook
	for k, v in pairs(tbl) do
		if ( v == value ) then
			return k;
		end
	end
end

function StoreFrame_GetDiscountInformation(data)
	if data.currentDollars ~= data.normalDollars or data.currentCents ~= data.normalCents then
		local normalPrice = (data.normalDollars * 100) + data.normalCents;
		local discountPrice = (data.currentDollars * 100) + data.currentCents;
		local discountTotal = normalPrice - discountPrice;
		local discountPercentage = 0;
		if normalPrice > 0 then
			discountPercentage = math.floor((discountTotal / normalPrice) * 100);
		end

		local discountDollars = math.floor(discountTotal / 100);
		local discountCents = discountTotal % 100;
		return true, discountPercentage, discountDollars, discountCents;
	else
		return false;
	end
end

function StoreFrame_CheckAndUpdateEntryID(isSplash)
	local products = C_StoreSecure.GetProducts(StoreFrame_GetSelectedCategoryID());

	if (not isSplash) then
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

function StoreFrame_GetProductCardTemplate(cardType, flags)	
	if cardType == Enum.BattlepayCardType.SmallCard then
		return "SmallStoreCardTemplate"
	elseif cardType == Enum.BattlepayCardType.MediumCard then
		return "MediumStoreCardTemplate"
	elseif cardType == Enum.BattlepayCardType.LargeHorizontalCard then
		return "HorizontalLargeStoreCardTemplate"
	elseif cardType == Enum.BattlepayCardType.LargeVeritcalCard then
		return "VerticalLargeStoreCardTemplate"
	elseif cardType == Enum.BattlepayCardType.MediumCardWithBuyButton then
		return "MediumStoreCardWithBuyButtonTemplate"
	elseif cardType == Enum.BattlepayCardType.LargeHorizontalCardWithBuyButton then
		return "HorizontalLargeStoreCardWithBuyButtonTemplate"
	elseif cardType == Enum.BattlepayCardType.LargeVeritcalCardWithBuyButton then
		return "VerticalLargeStoreCardWithBuyButtonTemplate"
	elseif cardType == Enum.BattlepayCardType.FullCardWithNydusLinkButton then
		return "HorizontalFullStoreCardWithNydusLinkButtonTemplate";
	elseif cardType == Enum.BattlepayCardType.FullCardWithBuyButton then
		if bit.band(flags, Enum.BattlepayDisplayFlag.UseHorizontalLayoutForFullCard) == Enum.BattlepayDisplayFlag.UseHorizontalLayoutForFullCard then
			return "HorizontalFullStoreCardWithBuyButtonTemplate";
		else
			return "VerticalFullStoreCardWithBuyButtonTemplate";
		end
	end
end

function StoreFrame_IsCompletelyOwned(entryInfo)
	return entryInfo.sharedData.eligibility == Enum.PurchaseEligibility.Owned;
end

function StoreFrame_IsPartiallyOwned(entryInfo)
	return entryInfo.sharedData.eligibility == Enum.PurchaseEligibility.PartiallyOwned;
end

function StoreFrame_FilterEntries(entries)
	local filteredEntries = {};
	for entryIndex = 1, #entries do
		local entryID = entries[entryIndex];

		local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
		local sharedData = entryInfo.sharedData;

		local completelyOwned = StoreFrame_IsCompletelyOwned(entryInfo);
		local partiallyOwned = StoreFrame_IsPartiallyOwned(entryInfo);
		local hideWhenOwned = bit.band(sharedData.flags, Enum.BattlepayDisplayFlag.HideWhenOwned) ~= 0;

		local expansionTooHigh = (sharedData.eligibility == Enum.PurchaseEligibility.ExpansionTooHigh);
		local expansionTooLow = (sharedData.eligibility == Enum.PurchaseEligibility.ExpansionTooLow);
		local missingRequirement = (sharedData.eligibility == Enum.PurchaseEligibility.MissingRequiredDeliverable);

		if completelyOwned or partiallyOwned then
			if not hideWhenOwned then
				table.insert(filteredEntries, entryID);
			end
		elseif not expansionTooLow and not expansionTooHigh and not missingRequirement then
			table.insert(filteredEntries, entryID);
		end
	end
	return filteredEntries;
end

function StoreFrame_SetCategory(forceModelUpdate)
	if not StoreFrame_CurrencyInfo() then
		return;
	end

	local self = StoreFrame;
	self.productCardPoolCollection:ReleaseAll();
	self.Notice:Hide();

	local entries = C_StoreSecure.GetProducts(StoreFrame_GetSelectedCategoryID());
	if #entries == 0 then
		return;
	end
	entries = StoreFrame_FilterEntries(entries);
	if entries then
		StoreFrame_SetCategoryProductCards(forceModelUpdate, entries);
	end
end

-- builds a table of pages: 
-- the table contains each page, and a starting entry index
function StoreFrame_GetPageInfo(entries)
	local self = StoreFrame;
	if not entries then
		local id = StoreFrame_GetSelectedCategoryID();
		entries = C_StoreSecure.GetProducts(id);
	end

	self.layoutGrid:Reset();
	local currentPage = 0;
	local pageInfo = {};
	local nextPage = true;

	for entryIndex = 1, #entries do
		local entryID = entries[entryIndex];

		local cardPlaced = false;
		while not cardPlaced do
			if nextPage then
				currentPage = currentPage + 1;
				pageInfo[currentPage] = entryIndex;
				nextPage = false;
			end

			local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
			local template = StoreFrame_GetProductCardTemplate(entryInfo.sharedData.cardType, entryInfo.sharedData.flags);
			local createCard = false;
			cardPlaced = StoreFrame_LayoutCard(template, createCard);

			if not cardPlaced then
				self.layoutGrid:Reset();
				nextPage = true;
			end
		end
	end

	self.layoutGrid:Reset();
	return pageInfo;
end

function StoreFrame_SetCategoryProductCards(forceModelUpdate, entries)
	if not StoreFrame_CurrencyInfo() then
		return;
	end

	if not entries then
		return;
	end

	local self = StoreFrame;
	StoreFrame_CheckAndUpdateEntryID(false);

	local pageInfo = StoreFrame_GetPageInfo(entries);
	local startIndex = pageInfo[selectedPageNum];
	local showGlobalBuyButton = true;

	for index = startIndex, #entries do
		local entryID = entries[index];

		local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
		local template = StoreFrame_GetProductCardTemplate(entryInfo.sharedData.cardType, entryInfo.sharedData.flags);

		-- if any of these product cards have their own buy button, we turn off the global buy button
		if productCardTemplateData[template].buyButton then
			showGlobalBuyButton = false;
		end

		local createCard = true;
		local _, card = StoreFrame_LayoutCard(template, createCard);

		if card then
			card:UpdateCard(entryID, forceModelUpdate);
			card:Show();
		else
			break;
		end
	end

	-- set up the buy buttons and paging buttons
	if #entries > 1 then
		local numPages = #pageInfo;
		self.PageText:SetText(string.format(BLIZZARD_STORE_PAGE_NUMBER, selectedPageNum, numPages));

		if numPages > 1 then
			self.PageText:Show();
			self.NextPageButton:Show();
			self.PrevPageButton:Show();
			self.PrevPageButton:SetEnabled(selectedPageNum ~= 1);
			self.NextPageButton:SetEnabled(selectedPageNum ~= numPages);
		else
			self.PageText:Hide();
			self.NextPageButton:Hide();
			self.PrevPageButton:Hide();
		end
	else
		self.PageText:Hide();
		self.NextPageButton:Hide();
		self.PrevPageButton:Hide();
	end
	self.BuyButton:SetShown(showGlobalBuyButton);
	StoreFrame_UpdateBuyButton();
end

local InitialXOffset = 0;
local InitialYOffset = 0;
StoreLayoutGridMixin = {};
function StoreLayoutGridMixin:Init(numRows, numCols)
	self.numRows = numRows;
	self.numCols = numCols;
	self.xOffset = InitialXOffset;
	self.yOffset = InitialYOffset;

	self:Reset(numRows, numCols);
end

function StoreLayoutGridMixin:Reset()
	self.grid = {};
	for row = 1, self.numRows do
		local gridRow = {};
		self.grid[row] = gridRow;
	end
	self.currentRow = 1;
	self.currentCol = 1;
	self.xOffset = InitialXOffset;
	self.yOffset = InitialYOffset;
end

function StoreLayoutGridMixin:IsGridFull()
	return (not self.currentRow) or (not self.currentCol);
end

function StoreLayoutGridMixin:FindNextEmptyIndex()
	if self:IsGridFull() then
		return nil, nil;
	end

	for row = self.currentRow, self.numRows do
		local gridRow = self.grid[row];
		for col = self.currentCol, self.numCols do
			if not gridRow[col] then
				return row, col;
			end
		end
		self.currentCol = 1;
	end
end

-- is there space at the given index for the dimensions (w x h) given?
function StoreLayoutGridMixin:SpaceAtIndex(cardTemplate, row, col)
	local width = productCardTemplateData[cardTemplate].cellGridSize.width;
	local height = productCardTemplateData[cardTemplate].cellGridSize.height;
	local willFit = true;

	if (row + height - 1) > self.numRows then
		return false;
	end

	if (col + width - 1) > self.numCols then
		return false
	end

	return true;
end

function StoreLayoutGridMixin:GetNextSpaceOnRow(row)
	local gridRow = self.grid[row];
	for col = 1, self.numCols do
		if not gridRow[col] then
			return col;
		end
	end
	return 1;
end

-- fill the space (w x h) at the given index
function StoreLayoutGridMixin:FillSpaceAtIndex(cardTemplate, row, col)
	local width = productCardTemplateData[cardTemplate].cellGridSize.width;
	local height = productCardTemplateData[cardTemplate].cellGridSize.height;

	for i = 1, height do
		local gridRow = self.grid[row + i - 1];
		for j = 1, width do
			gridRow[col + j - 1] = cardTemplate;
		end
	end
	self.currentRow = row;
	self.currentCol = col;
	self.currentRow, self.currentCol = self:FindNextEmptyIndex();
end

function StoreLayoutGridMixin:AdjustYOffsetForNewRow(row, col)
	local templateAbove = self.grid[row][col]; -- grab the template 'above' this cell
	if templateAbove then
		local cellPixelHeight = productCardTemplateData[templateAbove].cellPixelSize.height; -- and get the height of this template
		local _, _, _, bottomPadding = unpack(productCardTemplateData[templateAbove].padding); -- and get the bottom padding
		self.yOffset = self.yOffset + (-cellPixelHeight) + (-bottomPadding); -- now adjust our Y offset with this data
	else
		self.yOffset = InitialYOffset;
	end
end

-- the store lays out cards by cells now:
-- [1] [2] [3] [4]
-- [5] [6] [7] [8]
-- the smallest card, is (1x1), which is 1 cell, and the largest card is (4x2), which is all 8 cells
function StoreFrame_LayoutCard(cardTemplate, createCard)
	local self = StoreFrame;

	local card;
	local spaceAvailable = false;
	local row, col = self.layoutGrid:FindNextEmptyIndex();
	while not spaceAvailable and row and col do
		spaceAvailable = self.layoutGrid:SpaceAtIndex(cardTemplate, row, col);
		if spaceAvailable then
			self.layoutGrid:FillSpaceAtIndex(cardTemplate, row, col);

			local leftPadding, _, topPadding, _ = unpack(productCardTemplateData[cardTemplate].padding);
			if createCard then
				card = self.productCardPoolCollection:Acquire(cardTemplate);
			end
			if card then
				self.layoutGrid.xOffset = self.layoutGrid.xOffset + leftPadding;
				card:SetPoint("TOPLEFT", self.RightInset, "TOPLEFT", self.layoutGrid.xOffset, self.layoutGrid.yOffset + (-topPadding));
			end

			-- we've placed a card, now adjust offsets so they're ready for the next card
			local nextRow, nextCol = self.layoutGrid:FindNextEmptyIndex();
			if nextRow then
				if nextRow > row then
					-- card was placed on a new row
					if nextCol == 1 then
						self.layoutGrid.xOffset = InitialXOffset; -- reset X offset
					else
						self.layoutGrid.xOffset = self.layoutGrid.xOffset - leftPadding; -- adjust our X offset with this data, Y offset is unchanged
					end
					self.layoutGrid:AdjustYOffsetForNewRow(row, nextCol);--calculate new Y offset
				else
					local cellPixelWidth = productCardTemplateData[cardTemplate].cellPixelSize.width; -- grab this template's width
					local _, rightPadding = unpack(productCardTemplateData[cardTemplate].padding); -- and get the right padding
					self.layoutGrid.xOffset = self.layoutGrid.xOffset + cellPixelWidth + rightPadding; -- adjust our X offset with this data, Y offset is unchanged
				end
			end
		else
			row = row + 1; -- card will not fit on this row
			if row > self.layoutGrid.numRows then
				-- card will not fit on this page, we're done.
				return spaceAvailable, card;
			end
			col = self.layoutGrid:GetNextSpaceOnRow(row);

			-- we need to move the offsets and take another pass to fit this card
			self.layoutGrid.xOffset = InitialXOffset;-- reset X offset
			self.layoutGrid:AdjustYOffsetForNewRow(row - 1, col);--calculate new Y offset
		end
	end
	return spaceAvailable, card;
end

function StoreFrame_FindPageForBoost(boostType)
	local products = C_StoreSecure.GetProducts(WOW_SERVICES_CATEGORY_ID);

	for productIndex, entryID in ipairs(products) do
		local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
		if (entryInfo and entryInfo.sharedData.boostType == boostType) then
			return math.floor(productIndex / NUM_STORE_PRODUCT_CARDS) + 1;
		end
	end
end

function StoreFrame_GoToPageForBoost(boostType)
	-- NOTE: Assumes that the store has the correct category selected.
	local page = StoreFrame_FindPageForBoost(boostType);
	if page then
		StoreFrame_SetPage(page);
		return true;
	end

	return false;
end

function StoreFrame_FindCardForBoost(boostType)
	if StoreFrame_GoToPageForBoost(boostType) then
		for card in StoreFrame.productCardPoolCollection:EnumerateActive() do
			if card and card:IsShown() and card.boostType == boostType then
				return card;
			end
		end
	end
end

function StoreFrame_SelectBoostForPurchase(boostType)
	local card = StoreFrame_FindCardForBoost(boostType);
	if card then
		card:GetScript("OnClick")(card);
		StoreFrame.BuyButton:GetScript("OnClick")(StoreFrame.BuyButton);
	end
end

function StoreFrame_DoesProductGroupHavePurchasableItems(groupID)
	local entries = C_StoreSecure.GetProducts(groupID);
	entries = StoreFrame_FilterEntries(entries);

	for _, entryID in ipairs(entries) do
		local entryInfo = C_StoreSecure.GetEntryInfo(entryID);

		local completelyOwned = StoreFrame_IsCompletelyOwned(entryInfo);
		local partiallyOwned = StoreFrame_IsPartiallyOwned(entryInfo);

		local alreadyOwned = completelyOwned or partiallyOwned;
		if not alreadyOwned then
			return true;
		end
	end

	return false;
end

function StoreFrame_DoesProductGroupShowOwnedAsDisabled(groupID)
	local productGroupInfo = C_StoreSecure.GetProductGroupInfo(groupID);
	return bit.band(productGroupInfo.flags, Enum.BattlepayProductGroupFlag.DisableOwnedProducts) == Enum.BattlepayProductGroupFlag.DisableOwnedProducts;
end

function StoreFrame_IsProductGroupDisabled(groupID)
	local productGroupInfo = C_StoreSecure.GetProductGroupInfo(groupID);
	if not productGroupInfo then
		return true;
	end

	local displayAsDisabled = productGroupInfo.disabledTooltip ~= nil and not StoreFrame_DoesProductGroupHavePurchasableItems(groupID);
	local enabledForTrial = bit.band(productGroupInfo.flags, Enum.BattlepayProductGroupFlag.EnabledForTrial) == Enum.BattlepayProductGroupFlag.EnabledForTrial;
	local trialRestricted = IsTrialAccount() and not enabledForTrial;
	local enabledForVeteran = bit.band(productGroupInfo.flags, Enum.BattlepayProductGroupFlag.EnabledForVeteran) == Enum.BattlepayProductGroupFlag.EnabledForVeteran;
	local veteranRestricted = IsVeteranTrialAccount() and not enabledForVeteran;
	return displayAsDisabled or trialRestricted or veteranRestricted;
end

function StoreCategoryFrame_SetGroupID(self, groupID)
	self:SetID(groupID);
	local productGroupInfo = C_StoreSecure.GetProductGroupInfo(groupID);
	self.Icon:SetTexture(productGroupInfo.texture);
	self.Text:SetText(productGroupInfo.groupName);
	self.SelectedTexture:SetShown(StoreFrame_GetSelectedCategoryID() == groupID);

	local disabled = StoreFrame_IsProductGroupDisabled(groupID);
	self:SetEnabled(StoreFrame_GetSelectedCategoryID() ~= groupID and not disabled);
	self.Category:SetDesaturated(disabled);
	self.Icon:SetDesaturated(disabled);
	self.IconFrame:SetDesaturated(disabled);
	self.Text:SetFontObject(disabled and "GameFontDisable" or "GameFontNormal");

	local enabledForTrial = bit.band(productGroupInfo.flags, Enum.BattlepayProductGroupFlag.EnabledForTrial) == Enum.BattlepayProductGroupFlag.EnabledForTrial;
	local enabledForVeteran = bit.band(productGroupInfo.flags, Enum.BattlepayProductGroupFlag.EnabledForVeteran) == Enum.BattlepayProductGroupFlag.EnabledForVeteran;
	if IsTrialAccount() and not enabledForTrial then
		self.disabledTooltip = STORE_CATEGORY_TRIAL_DISABLED_TOOLTIP;
	elseif IsVeteranTrialAccount() and not enabledForVeteran then
		self.disabledTooltip = STORE_CATEGORY_VETERAN_DISABLED_TOOLTIP;
	elseif disabled then
		self.disabledTooltip = productGroupInfo.disabledTooltip;
	else
		self.disabledTooltip = nil;
	end
end

function StoreFrame_UpdateCategories(self)
	local categories = C_StoreSecure.GetProductGroups();

	for i = 1, #categories do
		local frame = self.CategoryFrames[i];
		local groupID = categories[i];
		if ( not frame ) then
			frame = CreateForbiddenFrame("Button", nil, self, "StoreCategoryTemplate");

			--[[
				WARNING: ScopeModifiers don't work for templates!
				These functions will fail to load properly if this template is instantiated outside
				of the initial LoadAddon call because we'll have lost the scoped modifiers and the
				reference to the addon environment if we instantiate them later.

				We have to manually set these scripts (below) for them to work properly.
			--]]

			frame:SetScript("OnEnter", StoreCategory_OnEnter);
			frame:SetScript("OnLeave", StoreCategory_OnLeave);
			frame:SetScript("OnClick", StoreCategory_OnClick);
			frame:SetPoint("TOPLEFT", self.CategoryFrames[i - 1], "BOTTOMLEFT", 0, 0);

			self.CategoryFrames[i] = frame;
		end

		StoreCategoryFrame_SetGroupID(frame, groupID);

		frame:Show();
	end

	self.BrowseNotice:ClearAllPoints();
	self.BrowseNotice:SetPoint("TOP", self.CategoryFrames[#categories], "BOTTOM", 0, -15);

	for i = #categories + 1, #self.CategoryFrames do
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
	self:RegisterEvent("STORE_OPEN_SIMPLE_CHECKOUT");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	self:RegisterEvent("SIMPLE_CHECKOUT_CLOSED");
	self:RegisterEvent("SUBSCRIPTION_CHANGED_KICK_IMMINENT");
	self:RegisterEvent("LOGIN_STATE_CHANGED");
	self:RegisterEvent("DYNAMIC_BUNDLE_PRICE_UPDATED");

	self.layoutGrid = CreateFromMixins(StoreLayoutGridMixin);
	self.layoutGrid:Init(2, 4);

	-- We have to call this from CharacterSelect on the glue screen because the addon engine will load
	-- the store addon more than once if we try to make it ondemand, forcing us to load it before we
	-- have a connection.
	if (not IsOnGlueScreen()) then
		C_StoreSecure.GetPurchaseList();
	end

	self.TitleText:SetText(BLIZZARD_STORE);

	self:SetPortraitToAsset("Interface\\Icons\\WoW_Store");
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
		background:SetPoint("TOPLEFT", _G.GlueParent, "TOPLEFT", -1024, 0);
		background:SetPoint("BOTTOMRIGHT", _G.GlueParent, "BOTTOMRIGHT", 1024, 0);

		background:SetColorTexture(0, 0, 0, 0.75);
	end
	self:SetPoint("CENTER", nil, "CENTER", 0, 20); --Intentionally not anchored to UIParent.
	StoreDialog:SetPoint("CENTER", nil, "CENTER", 0, 150);

	self.productCardPoolCollection = CreateFixedSizeFramePoolCollection();

	-- we preallocate all the card pools because if we create frames outside 
	-- of the LoadAddOn call, then the scripts aren't set properly due to scoped modifier issues
	local forbidden = true;
	local preallocate = true;
	for template, info in pairs(productCardTemplateData) do
		self.productCardPoolCollection:CreatePool("Button", self, template, nil, forbidden, info.poolSize, preallocate);
	end

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

function StoreFrame_GetDefaultCategory()
	local productGroups = C_StoreSecure.GetProductGroups();
	local needsNewCategory = not StoreFrame_GetSelectedCategoryID() or StoreFrame_IsProductGroupDisabled(StoreFrame_GetSelectedCategoryID());
	for i = 1, #productGroups do
		local groupID = productGroups[i];
		if not StoreFrame_IsProductGroupDisabled(groupID) then
			if needsNewCategory or groupID == StoreFrame_GetSelectedCategoryID() then
				return groupID;
			end
		end
	end

	return productGroups[1];
end

function StoreFrame_UpdateSelectedCategory()
	selectedCategoryID = StoreFrame_GetDefaultCategory();
end

function StoreFrame_GetSelectedCategoryID()
	return selectedCategoryID;
end

function StoreFrame_SetSelectedCategoryID(categoryID)
	selectedCategoryID = categoryID;
end

function StoreFrame_OnEvent(self, event, ...)
	if ( event == "STORE_PRODUCTS_UPDATED" ) then
		StoreFrame_UpdateSelectedCategory();
		StoreFrame_UpdateCategories(self);
		
		if self:IsShown() then
			C_StoreSecure.RequestAllDynamicPriceInfo();
		end
		
		if StoreFrame_GetSelectedCategoryID() then
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
		local isNewBoost = ...;
		if isNewBoost then
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
		if (StoreFrame_GetSelectedCategoryID() == WOW_TOKEN_CATEGORY_ID) then
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
	elseif ( event == "STORE_OPEN_SIMPLE_CHECKOUT" ) then
		WaitingOnConfirmation = false;
		StoreFrame_UpdateActivePanel(self);
	elseif ( event == "UPDATE_EXPANSION_LEVEL" or event == "TRIAL_STATUS_UPDATE" ) then
		-- Don't refresh products for Veterans (the shop is going to close automatically anyway)
		if not WasVeteran then
			C_StoreSecure.GetProductList();
		end
	elseif ( event == "SIMPLE_CHECKOUT_CLOSED" ) then
		-- Close the shop after you purchase game time
		if WasVeteran and not IsVeteranTrialAccount() then
			self:Hide();
		end
	elseif (event == "SUBSCRIPTION_CHANGED_KICK_IMMINENT") then
		if not SimpleCheckout:IsShown() then
			self:Hide();
			_G.GlueDialog_Show("SUBSCRIPTION_CHANGED_KICK_WARNING");
		end
	elseif (event == "LOGIN_STATE_CHANGED") then
		if (IsOnGlueScreen()) then
			local auroraState = C_Login.GetState();
			if ( auroraState == LE_AURORA_STATE_NONE ) then
				self:Hide();
			end
		end
	elseif (event == "DYNAMIC_BUNDLE_PRICE_UPDATED") then
		if StoreFrame_GetSelectedCategoryID() then
			StoreFrame_SetCategory();
		end
	end
end

function StoreFrame_OnShow(self)
	C_StoreSecure.GetProductList();
	C_WowTokenPublic.UpdateMarketPrice();
	self:SetAttribute("isshown", true);
	WasVeteran = IsVeteranTrialAccount();
	StoreFrame_UpdateActivePanel(self);
	if ( not IsOnGlueScreen() ) then
		Outbound.UpdateMicroButtons();
	end

	BoostType = nil;
	BoostDeliveredUsageReason = nil;
	BoostDeliveredUsageGUID = nil;
	WaitingOnVASToComplete = 0;
	WaitingOnVASToCompleteToken = nil;
	StoreFrameHasBeenShown = true;

	StoreFrame_UpdateCoverState();
	PlaySound(SOUNDKIT.UI_IG_STORE_WINDOW_OPEN_BUTTON);

	C_StoreSecure.ClearPreGeneratedExternalTransactionID();
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
	else
		GlueParent_UpdateDialogs();
	end

	StoreVASValidationFrame:Hide();
	SimpleCheckout:Hide();
	PlaySound(SOUNDKIT.UI_IG_STORE_WINDOW_CLOSE_BUTTON);
	
	C_StoreSecure.ClearPreGeneratedExternalTransactionID();
end

function StoreFrame_OnMouseWheel(self, value)
	if not StoreVASValidationFrame:IsShown() and not StoreConfirmationFrame:IsShown() then
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
end

function StoreFrame_OnCharacterBoostDelivered(self)
	if (IsOnGlueScreen() and BoostDeliveredUsageReason and not _G.CharacterSelect.undeleting) then
		self:Hide();

		_G.CharacterUpgradePopup_OnCharacterBoostDelivered(BoostType, BoostDeliveredUsageGUID, BoostDeliveredUsageReason);
	elseif (not IsOnGlueScreen() and StoreFrameHasBeenShown and not Outbound.IsExpansionTrialUpgradeDialogShowing()) then
		self:Hide();

		local showReason = "forBoost";

		if C_ClassTrial.IsClassTrialCharacter() and BoostDeliveredUsageReason == "forClassTrialUnlock" then
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
	local info = StoreFrame_CurrencyInfo();

	if not info then
		return;
	end

	local text = BLIZZARD_STORE_BUY;
	if info.browseBuyButtonText then
		text = info.browseBuyButtonText;
	end
	self.BuyButton:SetText(text);

	if not selectedEntryID then
		self.BuyButton:Disable();
		self.BuyButton.PulseAnim:Stop();
		return;
	end

	local entryInfo = C_StoreSecure.GetEntryInfo(selectedEntryID);
	local completelyOwned = StoreFrame_IsCompletelyOwned(entryInfo);
	if completelyOwned then
		self.BuyButton:Disable();
		self.BuyButton.PulseAnim:Stop();
		return;
	end

	if not self.BuyButton:IsEnabled() then
		self.BuyButton:Enable();
		if self.BuyButton:IsVisible() then
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
	StoreFrame_SetSelectedCategoryID(category);
	StoreFrame_SetCategory();
end

local function SelectBoostForPurchase(category, boostType, boostReason, characterToApplyToGUID)
	SetStoreCategoryFromAttribute(category);
	StoreFrame_SelectBoostForPurchase(boostType);
	BoostType = boostType;
	BoostDeliveredUsageReason = boostReason;
	BoostDeliveredUsageGUID = characterToApplyToGUID;
end

local function IsVASTransferProduct(productID)
	return productID == CHARACTER_TRANSFER_PRODUCT_ID or productID == CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID or productID == GUILD_TRANSFER_PRODUCT_ID or productID == GUILD_TRANSFER_FACTION_BUNDLE_PRODUCT_ID;
end

local function GetBaseProductInfo(productID)
	if productID == CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID then
		return C_StoreSecure.GetProductInfo(CHARACTER_TRANSFER_PRODUCT_ID);
	elseif productID == GUILD_TRANSFER_FACTION_BUNDLE_PRODUCT_ID then
		return C_StoreSecure.GetProductInfo(GUILD_TRANSFER_PRODUCT_ID);
	end
end

local function GetBundleProductInfo(productID)
	if productID == CHARACTER_TRANSFER_PRODUCT_ID then
		return C_StoreSecure.GetProductInfo(CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID);
	elseif productID == GUILD_TRANSFER_PRODUCT_ID then
		return C_StoreSecure.GetProductInfo(GUILD_TRANSFER_FACTION_BUNDLE_PRODUCT_ID);
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
		SetStoreCategoryFromAttribute(WOW_TOKEN_CATEGORY_ID);
	elseif ( name == "setgamescategory" ) then
		SetStoreCategoryFromAttribute(WOW_GAMES_CATEGORY_ID);
	elseif ( name == "opengamescategory" ) then
		if C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_GAMES_CATEGORY_ID) then
			self:Show();
			SetStoreCategoryFromAttribute(WOW_GAMES_CATEGORY_ID);
		else
			PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT);
			LoadURLIndex(2);
		end
	elseif ( name == "setservicescategory" ) then
		SetStoreCategoryFromAttribute(WOW_SERVICES_CATEGORY_ID);
	elseif ( name == "selectboost") then
		SelectBoostForPurchase(WOW_SERVICES_CATEGORY_ID, value.boostType, value.reason, value.guid);
	elseif ( name == "selectsubscription" ) then
		SetStoreCategoryFromAttribute(WOW_SUBSCRIPTION_CATEGORY_ID);
	elseif ( name == "selectgametime" ) then
		SetStoreCategoryFromAttribute(WOW_GAME_TIME_CATEGORY_ID);
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

			local desc;
			if (hasOther) then
				desc = BLIZZARD_STORE_VAS_ERROR_OTHER;
			elseif (hasNonUserFixable) then
				desc = "";
				for i = 1, #errors do
					if (vasErrorData[errors[i]].notUserFixable) then
						desc = StoreVASValidationFrame_AppendError(desc, errors[i], character);
					end
				end
			else
				desc = BLIZZARD_STORE_VAS_ERROR_LABEL;
				for i = 1, #errors do
					desc = StoreVASValidationFrame_AppendError(desc, errors[i], character);
				end
			end

			self:SetAttribute("vaserrormessageresult", { other = hasOther or hasNonUserFixable, desc = desc });
		end
	elseif ( name == "isvastransferproduct" ) then
		local productID = value;
		self:SetAttribute('isvastransferproductresult', IsVASTransferProduct(productID));
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

function StoreFrame_IsLoading(self)
	if ( not C_StoreSecure.HasProductList() ) then
		return true;
	end
	if ( not C_StoreSecure.HasDistributionList() ) then
		return true;
	end
	-- can open the store UI while in queue, but in that state we don't ask for, nor need the purchase list
	if ( not C_StoreSecure.HasPurchaseList() ) then
		local _, _, wowConnectionState = C_Login.GetState();
		if ( wowConnectionState ~= LE_WOW_CONNECTION_STATE_IN_QUEUE ) then
			return true;
		end
	end
	return false;
end

function StoreFrame_UpdateActivePanel(self)
	if (StoreFrame.ErrorFrame:IsShown()) then
		StoreFrame_HideAlert(self);
		StoreFrame_HidePurchaseSent(self);
	elseif ( WaitingOnConfirmation ) then
		if (StoreVASValidationFrame and StoreVASValidationFrame:IsShown()) then
			StoreVASValidationFrame.CharacterSelectionFrame.RealmSelector.Button:Disable();
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
	elseif ( StoreFrame_IsLoading(self) ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_LOADING, BLIZZARD_STORE_PLEASE_WAIT);
	elseif ( #C_StoreSecure.GetProductGroups() == 0 ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_NO_ITEMS, BLIZZARD_STORE_CHECK_BACK_LATER);
	elseif ( not IsOnGlueScreen() and not StoreFrame_HasFreeBagSlots() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_BAG_FULL, BLIZZARD_STORE_BAG_FULL_DESC);
	elseif ( not StoreFrame_CurrencyInfo() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_INTERNAL_ERROR, BLIZZARD_STORE_INTERNAL_ERROR_SUBTEXT);
	else
		StoreFrame_HideAlert(self);
		StoreFrame_HidePurchaseSent(self);
		if (StoreVASValidationFrame and StoreVASValidationFrame:IsShown()) then
			StoreVASValidationFrame.CharacterSelectionFrame.RealmSelector.Button:Enable();
			StoreVASValidationFrame.CharacterSelectionFrame.Spinner:Hide();
		end
		local info = StoreFrame_CurrencyInfo();
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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
	PlaySound(SOUNDKIT.UI_IG_STORE_PAGE_NAV_BUTTON);
end

function StoreFrameErrorWebsiteButton_OnClick(self)
	LoadURLIndex(ActiveURLIndex);
end

function StoreFrameCloseButton_OnClick(self)
	StoreFrame:Hide();
end

function SplashSingleBuyButton_OnEnter(self)
	self:GetParent():OnEnter();
end

function SplashSingleBuyButton_OnLeave(self)
	self:GetParent():OnLeave();
end

function StoreFrame_BeginPurchase(entryID)
	local entryInfo = C_StoreSecure.GetEntryInfo(entryID);
	local completelyOwned = StoreFrame_IsCompletelyOwned(entryInfo);
	if completelyOwned then
		StoreFrame_OnError(StoreFrame, Enum.StoreError.AlreadyOwned, false, "FakeOwned");
	elseif C_StoreSecure.PurchaseProduct(entryInfo.productID) then
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

function StoreFrame_ShowPreviews(displayInfoEntries)
	Outbound.ShowPreviews(displayInfoEntries);
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

	PlaySound(SOUNDKIT.UI_IG_STORE_PAGE_NAV_BUTTON);
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

	PlaySound(SOUNDKIT.UI_IG_STORE_PAGE_NAV_BUTTON);
end

local VASServiceType = nil;
local SelectedRealm = nil;
local SelectedCharacter = nil;
local NameChangeNewName = nil;
local OldGuildNewName = nil;
local NewGuildMaster = nil;
local SelectedDestinationRealm = nil;
local DestinationRealmMapping = {};
local StoreDropdownLists = {};
local SelectedDestinationWowAccount = nil;
local SelectedDestinationBnetAccount = nil;
local SelectedDestinationBnetWowAccount = nil;
local TransferFactionChangeBundle = false;
local IsGuildFollow = false;
local RealmAutoCompleteList;
local IsVasBnetTransferValidated = false;
local RealmList = {};

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

	if (TransferFactionChangeBundle) then
		local newFaction = GetFactionName(character.faction, true);
		confStr = confStr .. sep .. newFaction;
		sep = ", ";
	end

	if (SelectedDestinationRealm) then
		confStr = confStr .. sep .. SelectedDestinationRealm
	end

	return confStr;
end

local function IsGuildVasServiceType(serviceType)
	return	serviceType == Enum.VasServiceType.GuildNameChange or
			serviceType == Enum.VasServiceType.GuildFactionChange or 
			serviceType == Enum.VasServiceType.GuildTransfer or 
			serviceType == Enum.VasServiceType.GuildFactionTransfer;
end

local function IsVasServiceTypeEligibleForGuildFollow(serviceType)
	return	serviceType == Enum.VasServiceType.FactionChange or
			serviceType == Enum.VasServiceType.CharacterTransfer or
			serviceType == Enum.VasServiceType.FactionTransfer;
end

local function GetCharactersForSelectedRealm()
	return C_StoreSecure.GetCharactersForRealm(SelectedRealm.virtualRealmAddress, IsGuildVasServiceType(VASServiceType));
end

local function GetGuildMasterInfoForCharacter(guid)
	if not GuildMasterInfo[guid] then
		GuildMasterInfo[guid] = C_StoreSecure.GetVASGuildMasterInfoForCharacterByGUID(guid);
	end

	return GuildMasterInfo[guid];
end

function StoreConfirmationFrame_SetNotice(self, icon, name, dollars, cents, walletName, productDecorator)
	local currency = C_StoreSecure.GetCurrencyID();

	SetPortraitToTexture(self.Icon, icon);

	name = name:gsub("|n", " ");
	self.ProductName:SetText(name);
	local info = StoreFrame_CurrencyInfo();
	local notice;

	if (productDecorator == Enum.BattlepayProductDecorator.Boost) then
		notice = info.servicesConfirmationNotice;

		if info.boostDisclaimerText then
			notice = info.boostDisclaimerText .. "|n|n" .. notice;
		end
	elseif (productDecorator == Enum.BattlepayProductDecorator.Expansion) then
		notice = info.expansionConfirmationNotice;
	elseif (productDecorator == Enum.BattlepayProductDecorator.VasService) then
		local character = CharacterList[SelectedCharacter];

		local guildMasterInfo;
		if IsGuildVasServiceType(VASServiceType) then
			guildMasterInfo = GetGuildMasterInfoForCharacter(character.guid);
			if not guildMasterInfo then
				-- We should never get to this point without guild master info
				return;
			end
		end

		local confirmationNotice;
		if (VASServiceType == Enum.VasServiceType.NameChange) then
			notice = string.format(VAS_NAME_CHANGE_CONFIRMATION, character.name, NameChangeNewName);
			confirmationNotice = info.vasNameChangeConfirmationNotice;
		elseif (VASServiceType == Enum.VasServiceType.FactionChange) then
			local newFaction = GetFactionName(character.faction, true);
			notice = string.format(VAS_FACTION_CHANGE_CONFIRMATION, character.name, SelectedRealm.realmName, newFaction);
			confirmationNotice = info.servicesConfirmationNotice;
		elseif (VASServiceType == Enum.VasServiceType.RaceChange) then
			notice = string.format(VAS_RACE_CHANGE_CONFIRMATION, character.name, SelectedRealm.realmName);
			confirmationNotice = info.servicesConfirmationNotice;
		elseif (VASServiceType == Enum.VasServiceType.AppearanceChange) then
			notice = string.format(VAS_APPEARANCE_CHANGE_CONFIRMATION, character.name, SelectedRealm.realmName);
			confirmationNotice = info.servicesConfirmationNotice;
		elseif (VASServiceType == Enum.VasServiceType.CharacterTransfer ) then
			notice = string.format(VAS_CHARACTER_TRANSFER_CONFIRMATION, character.name, SelectedRealm.realmName, BuildCharacterTransferConfirmationString(character));
			confirmationNotice = info.servicesConfirmationNotice;
		elseif (VASServiceType == Enum.VasServiceType.GuildNameChange) then
			notice = string.format(VAS_NAME_CHANGE_CONFIRMATION, guildMasterInfo.guildName, NameChangeNewName);
			confirmationNotice = info.vasGuildServicesConfirmationNotice;
		elseif (VASServiceType == Enum.VasServiceType.GuildFactionChange) then
			local newFaction = GetFactionName(character.faction, true);
			if NameChangeNewName then
				notice = string.format(VAS_GUILD_FACTION_CHANGE_PLUS_NAME_CHANGE_CONFIRMATION, guildMasterInfo.guildName, SelectedRealm.realmName, newFaction, NameChangeNewName, NewGuildMaster, guildMasterInfo.guildName);
			else
				notice = string.format(VAS_GUILD_FACTION_CHANGE_CONFIRMATION, guildMasterInfo.guildName, SelectedRealm.realmName, newFaction, OldGuildNewName, NewGuildMaster, OldGuildNewName);
			end
			confirmationNotice = info.vasGuildServicesConfirmationNotice;
		elseif (VASServiceType == Enum.VasServiceType.GuildTransfer) then
			local newFaction = GetFactionName(character.faction, true);
			if TransferFactionChangeBundle and NameChangeNewName then
				notice = string.format(VAS_GUILD_TRANSFER_PLUS_NAME_AND_FACTION_CHANGE_CONFIRMATION, guildMasterInfo.guildName, SelectedRealm.realmName, SelectedDestinationRealm, NameChangeNewName, newFaction, NewGuildMaster);
			elseif TransferFactionChangeBundle then
				notice = string.format(VAS_GUILD_TRANSFER_PLUS_FACTION_CHANGE_CONFIRMATION, guildMasterInfo.guildName, SelectedRealm.realmName, SelectedDestinationRealm, newFaction, NewGuildMaster);
			elseif NameChangeNewName then
				notice = string.format(VAS_GUILD_TRANSFER_PLUS_NAME_CHANGE_CONFIRMATION, guildMasterInfo.guildName, SelectedRealm.realmName, SelectedDestinationRealm, NameChangeNewName, NewGuildMaster);
			else
				notice = string.format(VAS_GUILD_TRANSFER_CONFIRMATION, guildMasterInfo.guildName, SelectedRealm.realmName, SelectedDestinationRealm, NewGuildMaster);
			end
			confirmationNotice = info.vasGuildServicesConfirmationNotice;
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
	self.NoticeFrame.Price:SetText(currencyFormatLong(dollars, cents));

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

	local baseProductInfo = GetBaseProductInfo(productID)
	if baseProductInfo then
		name = baseProductInfo.sharedData.name or name;
		finalIcon = baseProductInfo.sharedData.texture;
	end

	StoreConfirmationFrame_SetNotice(self, finalIcon, name, currentDollars, currentCents, walletName, productInfo.sharedData.productDecorator);
	IsUpgrade = productInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.Boost;
	IsLegion = productInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.Expansion;
	BoostType = productInfo.sharedData.boostType;
	local info = StoreFrame_CurrencyInfo();
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

	PlaySound(SOUNDKIT.UI_IG_STORE_CANCEL_BUTTON);
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
		PlaySound(SOUNDKIT.UI_IG_STORE_CONFIRM_PURCHASE_BUTTON);
	else
		StoreFrame_OnError(StoreFrame, Enum.StoreError.Other, false, "Fake");
		PlaySound(SOUNDKIT.UI_IG_STORE_CANCEL_BUTTON);
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
	self.CharacterSelectionFrame.NewGuildName.Label:SetText(VAS_NEW_GUILD_NAME_LABEL);
	self.CharacterSelectionFrame.NewGuildMaster.Label:SetText(VAS_NEW_GUILD_MASTER_LABEL);
	self.CharacterSelectionFrame.NewGuildMaster.EmptyText:SetText(VAS_NEW_GUILD_MASTER_EMPTY_TEXT);
	self.CharacterSelectionFrame.OldGuildNewName.Label:SetText(VAS_OLD_GUILD_NEW_NAME_LABEL);
	self.CharacterSelectionFrame.OldGuildNewName.EmptyText:SetText(VAS_OLD_GUILD_NEW_NAME_EMPTY_TEXT);
	self.CharacterSelectionFrame.RenameGuildCheckbox.Label:SetText(BLIZZARD_STORE_VAS_RENAME_GUILD);
	self.CharacterSelectionFrame.RenameGuildEditbox.EmptyText:SetText(VAS_NEW_GUILD_NAME_LABEL);
	self.CharacterSelectionFrame.TransferRealmEditbox.Label:SetText(VAS_DESTINATION_REALM_LABEL);
	self.CharacterSelectionFrame.TransferRealmEditbox.EmptyText:SetText(BLIZZARD_STORE_VAS_REALM_NAME);
	self.CharacterSelectionFrame.TransferAccountCheckbox.Label:SetText(BLIZZARD_STORE_VAS_TRANSFER_ACCOUNT);
	self.CharacterSelectionFrame.TransferBattlenetAccountEditbox.EmptyText:SetText(BLIZZARD_STORE_VAS_EMAIL_ADDRESS);

	self.CharacterSelectionFrame.FollowGuildCheckbox.Label:SetMaxLines(2);

	SecureMixin(self.CharacterSelectionFrame.SelectedCharacterDescription, ShrinkUntilTruncateFontStringMixin);
	self.CharacterSelectionFrame.SelectedCharacterDescription:SetFontObjectsToTry("GameFontHighlightSmall2", "GameFontWhiteTiny", "GameFontWhiteTiny2");

	SecureMixin(self.CharacterSelectionFrame.FollowGuildErrorMessage, ShrinkUntilTruncateFontStringMixin);
	self.CharacterSelectionFrame.FollowGuildErrorMessage:SetFontObjectsToTry("GameFontBlack", "GameFontBlackSmall", "GameFontBlackSmall2", "GameFontBlackTiny", "GameFontBlackTiny2");

	local labelsToShrink = {
		"FollowGuildCheckbox",
		"TransferAccountCheckbox",
		"TransferFactionCheckbox",
		"RenameGuildCheckbox",
	};

	for i, checkbox in ipairs(labelsToShrink) do
		SecureMixin(self.CharacterSelectionFrame[checkbox].Label, ShrinkUntilTruncateFontStringMixin);
		self.CharacterSelectionFrame[checkbox].Label:SetFontObjectsToTry("GameFontBlack", "GameFontBlackSmall", "GameFontBlackSmall2", "GameFontBlackTiny", "GameFontBlackTiny2");
	end

	if (IsOnGlueScreen()) then
		self.CharacterSelectionFrame.NewCharacterName:SetFontObject("GlueEditBoxFont");
		self.CharacterSelectionFrame.NewGuildName:SetFontObject("GlueEditBoxFont");
		self.CharacterSelectionFrame.NewGuildMaster:SetFontObject("GlueEditBoxFont");
		self.CharacterSelectionFrame.OldGuildNewName:SetFontObject("GlueEditBoxFont");
		self.CharacterSelectionFrame.TransferRealmEditbox:SetFontObject("GlueEditBoxFont");
		self.CharacterSelectionFrame.TransferBattlenetAccountEditbox:SetFontObject("GlueEditBoxFont");
	end

	self:RegisterEvent("STORE_CHARACTER_LIST_RECEIVED");
	self:RegisterEvent("STORE_VAS_PURCHASE_ERROR");
	self:RegisterEvent("STORE_VAS_PURCHASE_COMPLETE");
	self:RegisterEvent("VAS_TRANSFER_VALIDATION_UPDATE");
	self:RegisterEvent("VAS_QUEUE_STATUS_UPDATE");
	self:RegisterEvent("STORE_OPEN_SIMPLE_CHECKOUT");
	self:RegisterEvent("STORE_GUILD_FOLLOW_INFO_RECEIVED");
	self:RegisterEvent("STORE_GUILD_MASTER_INFO_RECEIVED");
end

local InstructionsShowing = false;

function StoreVASValidationFrame_GetProductInfo(self)
	local entryInfo = C_StoreSecure.GetEntryInfo(selectedEntryID);
	self.productID = entryInfo.productID;
	self.productInfo = C_StoreSecure.GetProductInfo(self.productID);
end

local function UpdateCharacterSelectorState()
	if InstructionsShowing then
		StoreVASValidationFrame.CharacterSelectionFrame.NoEligibleCharactersErrorMessage:Hide();
	else
		if #CharacterList == 0 then
			StoreVASValidationFrame.CharacterSelectionFrame.CharacterSelector.Button:Disable();
			StoreVASValidationFrame.CharacterSelectionFrame.CharacterSelector.Text:SetText(VAS_SELECT_CHARACTER_DISABLED);
			if IsGuildVasServiceType(VASServiceType) then
				StoreVASValidationFrame.CharacterSelectionFrame.NoEligibleCharactersErrorMessage:SetText(BLIZZARD_STORE_VAS_ERROR_NO_GUILD_MASTERS);
			else
				StoreVASValidationFrame.CharacterSelectionFrame.NoEligibleCharactersErrorMessage:SetText(BLIZZARD_STORE_VAS_ERROR_NO_ELIGIBLE_CHARACTERS);
			end
			StoreVASValidationFrame.CharacterSelectionFrame.NoEligibleCharactersErrorMessage:Show();
		else
			StoreVASValidationFrame.CharacterSelectionFrame.CharacterSelector.Button:Enable();
			if SelectedCharacter then
				local character = CharacterList[SelectedCharacter];
				local level = character.level;
				if (level == 0) then
					level = 1;
				end
				StoreVASValidationFrame.CharacterSelectionFrame.CharacterSelector.Text:SetText(string.format(VAS_CHARACTER_SELECTION_DESCRIPTION, RAID_CLASS_COLORS[character.classFileName].colorStr, character.name, level, character.className));
			else
				StoreVASValidationFrame.CharacterSelectionFrame.CharacterSelector.Text:SetText(VAS_SELECT_CHARACTER);
			end
			StoreVASValidationFrame.CharacterSelectionFrame.NoEligibleCharactersErrorMessage:Hide();
		end
	end
end

local function UpdateCharacterList()
	if IsGuildVasServiceType(VASServiceType) and RealmWithGuildMasterInfo ~= SelectedRealm.virtualRealmAddress then
		-- wait for STORE_GUILD_MASTER_INFO_RECEIVED event before populating character list
		RealmWaitingOnGuildMasterInfo = SelectedRealm.virtualRealmAddress;
		C_StoreSecure.RequestRealmGuildMasterInfo(SelectedRealm.virtualRealmAddress);
	else
		CharacterList = GetCharactersForSelectedRealm();
		UpdateCharacterSelectorState();
	end
end

function StoreVASValidationFrame_Init(self)
	RealmList = C_StoreSecure.GetRealmList();
	SelectedRealm = RealmList[1];

	VASServiceType = self.productInfo.sharedData.vasServiceType;

	SelectedDestinationRealm = nil;
	SelectedDestinationWowAccount = nil;
	SelectedDestinationBnetAccount = nil;
	SelectedDestinationBnetWowAccount = nil;
	TransferFactionChangeBundle = false;
	IsGuildFollow = false;
	IsVasBnetTransferValidated = false;
	RealmAutoCompleteList = nil;
	DestinationRealmMapping = {};
	SelectedCharacter = nil;
	NameChangeNewName = nil;
	OldGuildNewName = nil;
	NewGuildMaster = nil;

	if not InstructionsShowing then
		RealmWaitingOnGuildMasterInfo = nil;
		RealmWithGuildMasterInfo = nil;
		UpdateCharacterList();
	end

	self.Disclaimer:Hide();
	self.CharacterSelectionFrame.ContinueButton:Disable();
	self.CharacterSelectionFrame.ContinueButton:Show();
	self.CharacterSelectionFrame.Spinner:Hide();

	self.CharacterSelectionFrame.RealmSelector.Text:SetText(SelectedRealm.realmName);
	self.CharacterSelectionFrame.RealmSelector.Button:Enable();
	self.CharacterSelectionFrame.RealmSelector:Show();
	self.CharacterSelectionFrame.CharacterSelector:Show();
	self.CharacterSelectionFrame.NoEligibleCharactersErrorMessage:Hide();
	self.CharacterSelectionFrame.NewCharacterName:Hide();
	self.CharacterSelectionFrame.FollowGuildCheckbox:Hide();
	self.CharacterSelectionFrame.FollowGuildErrorMessage:Hide();
	self.CharacterSelectionFrame.TransferRealmEditbox:Hide();
	self.CharacterSelectionFrame.TransferRealmEditbox.AutoCompleteBox:Hide();
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
	self.CharacterSelectionFrame.GuildIcon:Hide();
	self.CharacterSelectionFrame.SelectedGuildName:Hide();
	self.CharacterSelectionFrame.NewGuildName:Hide();
	self.CharacterSelectionFrame.RenameGuildCheckbox:Hide();
	self.CharacterSelectionFrame.RenameGuildEditbox:Hide();
	self.CharacterSelectionFrame.NewGuildMaster:Hide();
	self.CharacterSelectionFrame.OldGuildNewName:Hide();
	self.CharacterSelectionFrame:Show();

	for list, _ in pairs(StoreDropdownLists) do
		list:Hide();
	end

	local finalIcon = self.productInfo.sharedData.texture;
	if ( not finalIcon ) then
		finalIcon = "Interface\\Icons\\INV_Misc_Note_02";
	end
	SetPortraitToTexture(self.Icon, finalIcon);
	self.ProductName:SetText(self.productInfo.sharedData.name);

	self.ProductInstructions:Hide();
	self.ProductDescription:Show();

	self:ClearAllPoints();
	if (VASServiceType == Enum.VasServiceType.CharacterTransfer or VASServiceType == Enum.VasServiceType.GuildTransfer or VASServiceType == Enum.VasServiceType.GuildFactionChange) then
		self:SetHeight(740);
		self:SetPoint("CENTER", 0, -20);
	else
		self:SetHeight(626);
		self:SetPoint("CENTER", 0, 0);
	end

	self:Show();
end

function StoreVASValidationFrame_CheckForInstructions(self)
	if self.productInfo.sharedData.instructions ~= "" then
		InstructionsShowing = true;
		StoreVASValidationFrame_Init(self);
		self.ProductInstructions:SetTextColor(0, 0, 0);
		self.ProductInstructions:SetText(HTML_START..self.productInfo.sharedData.instructions..HTML_END);
		self.ProductInstructions:Show();
		self.ProductDescription:Hide();
		self.CharacterSelectionFrame.RealmSelector:Hide();
		self.CharacterSelectionFrame.CharacterSelector:Hide();
		self.CharacterSelectionFrame.ContinueButton:Enable();
		self.CharacterSelectionFrame.ContinueButton:Show();
		return true;
	end

	InstructionsShowing = false;
	return false;
end

local VasQueueStatusToString
if (IsOnGlueScreen()) then
	VasQueueStatusToString = {
		[Enum.VasQueueStatus.UnderAnHour] = "SEVERAL_MINUTES",
		[Enum.VasQueueStatus.OneToThreeHours] = "ONE_THREE_HOURS",
		[Enum.VasQueueStatus.ThreeToSixHours] = "THREE_SIX_HOURS",
		[Enum.VasQueueStatus.SixToTwelveHours] = "SIX_TWELVE_HOURS",
		[Enum.VasQueueStatus.OverTwelveHours] = "TWELVE_HOURS",
		[Enum.VasQueueStatus.Over_1_Days] = "ONE_DAY",
		[Enum.VasQueueStatus.Over_2_Days] = "TWO_DAY",
		[Enum.VasQueueStatus.Over_3_Days] = "THREE_DAY",
		[Enum.VasQueueStatus.Over_4_Days] = "FOUR_DAY",
		[Enum.VasQueueStatus.Over_5_Days] = "FIVE_DAY",
		[Enum.VasQueueStatus.Over_6_Days] = "SIX_DAY",
		[Enum.VasQueueStatus.Over_7_Days] = "SEVEN_DAY",
	}
end

local function UpdateQueueStatusDisclaimer(self, queueTime)
	local currencyInfo = StoreFrame_CurrencyInfo();
	local vasDisclaimerData = currencyInfo.vasDisclaimerData;
	if vasDisclaimerData and vasDisclaimerData[VASServiceType] then
		if (queueTime > Enum.VasQueueStatus.UnderAnHour) then
			self.Disclaimer:SetTextColor(_G.RED_FONT_COLOR:GetRGB());
		else
			self.Disclaimer:SetTextColor(0, 0, 0);
		end

		self.Disclaimer:SetText(HTML_START_CENTERED..string.format(vasDisclaimerData[VASServiceType].disclaimer, _G["VAS_QUEUE_"..VasQueueStatusToString[queueTime]])..HTML_END);
		self.Disclaimer:Show();
	end
end

function StoreVASValidationFrame_SetVASStart(self)
	StoreVASValidationFrame_Init(self);

	self.ProductDescription:SetText(self.productInfo.sharedData.description);

	if ( VASServiceType == Enum.VasServiceType.CharacterTransfer or VASServiceType == Enum.VasServiceType.FactionChange) then
		UpdateQueueStatusDisclaimer(self, Enum.VasQueueStatus.UnderAnHour);
		C_StoreGlue.RequestCurrentVASTransferQueues();
	elseif IsGuildVasServiceType(VASServiceType) then
		UpdateQueueStatusDisclaimer(self, Enum.VasQueueStatus.Over_1_Days);
	else
		UpdateQueueStatusDisclaimer(self, Enum.VasQueueStatus.UnderAnHour);
	end
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

function StoreVASValidationFrame_UpdateGuildFactionChangeValidationPosition()
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	if (frame.OldGuildNewName:IsShown()) then
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", frame.OldGuildNewName.Label, "BOTTOMLEFT", 0, -8);
	else
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", frame.NewGuildMaster.Label, "BOTTOMLEFT", 0, -8);
	end
end

function StoreVASValidationFrame_UpdateCharacterTransferValidationPosition()
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	local bottomWidget;
	local xOffset = 8;
	local yOffset = -8;
	if (frame.ChangeIconFrame:IsShown()) then
		bottomWidget = frame.ChangeIconFrame;
	elseif (frame.TransferBnetWoWAccountDropDown:IsShown()) then
		bottomWidget = frame.TransferBnetWoWAccountDropDown;
		xOffset = 16;
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

local function StoreVASValidationFrame_ValidationDescription_SetText(text, isError)
	local frame = StoreVASValidationFrame.CharacterSelectionFrame.ValidationDescription;

	if isError then
		frame:SetTextColor(1.0, 0.1, 0.1);
	else
		frame:SetTextColor(0, 0, 0);
	end

	frame:SetText(HTML_START..text..HTML_END);
end

function StoreVASValidationFrame_OnEvent(self, event, ...)
	if ( event == "STORE_CHARACTER_LIST_RECEIVED" ) then
		WaitingOnConfirmation = false;
		StoreFrame_UpdateActivePanel(StoreFrame);
		if ( StoreFrame:IsShown() ) then
			StoreVASValidationFrame_GetProductInfo(self);
			if not StoreVASValidationFrame_CheckForInstructions(self) then
				StoreVASValidationFrame_SetVASStart(self);
			end
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
			frame.ValidationDescription:SetPoint("TOPLEFT", frame.TransferBattlenetAccountEditbox, "BOTTOMLEFT", -4, -8);
			StoreVASValidationFrame_ValidationDescription_SetText(BLIZZARD_STORE_VAS_ERROR_INVALID_BNET_ACCOUNT, true);
			frame.ValidationDescription:Show();
		end
	elseif ( event == "VAS_QUEUE_STATUS_UPDATE" ) then
		local transfer, factionTransfer = C_StoreGlue.GetVasTransferQueues();
		local queueTime = Enum.VasQueueStatus.UnderAnHour;
		if VASServiceType == Enum.VasServiceType.CharacterTransfer then
			queueTime = transfer;
		elseif VASServiceType == Enum.VasServiceType.FactionChange then
			queueTime = factionTransfer;
		end

		UpdateQueueStatusDisclaimer(self, queueTime);
	elseif ( event == "STORE_OPEN_SIMPLE_CHECKOUT" ) then
		self:Hide();
	elseif ( event == "STORE_GUILD_FOLLOW_INFO_RECEIVED" ) then
		local characterGuid, guildFollowInfo = ...;
		if CharacterWaitingOnGuildFollowInfo == characterGuid then 
			CharacterWaitingOnGuildFollowInfo = nil;
			VASCharacterSelectionCharacterSelector_Callback(SelectedCharacter, guildFollowInfo);
		end
	elseif ( event == "STORE_GUILD_MASTER_INFO_RECEIVED" ) then
		local realmAddress = ...;
		if RealmWaitingOnGuildMasterInfo == realmAddress then 
			RealmWaitingOnGuildMasterInfo = nil;
			RealmWithGuildMasterInfo = realmAddress;
			VASCharacterSelectionRealmSelector_Callback(SelectedRealm);
		end
	end
end

function StoreVASValidationFrame_SetErrors(errors)
	local character = CharacterList[SelectedCharacter];
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

	local desc;
	if (hasOther) then
		desc = BLIZZARD_STORE_VAS_ERROR_OTHER;
	elseif (hasNonUserFixable) then
		desc = "";
		for i = 1, #errors do
			if (vasErrorData[errors[i]].notUserFixable) then
				desc = StoreVASValidationFrame_AppendError(desc, errors[i], character, i == 1);
			end
		end
	else
		desc = BLIZZARD_STORE_VAS_ERROR_LABEL;
		for i = 1, #errors do
			desc = StoreVASValidationFrame_AppendError(desc, errors[i], character, i == 1);
		end
	end
	frame.ChangeIconFrame:Hide();
	if (VASServiceType == Enum.VasServiceType.GuildFactionChange) then
		StoreVASValidationFrame_UpdateGuildFactionChangeValidationPosition();
	elseif (VASServiceType == Enum.VasServiceType.CharacterTransfer) then
		StoreVASValidationFrame_UpdateCharacterTransferValidationPosition();
	end
	frame.Spinner:Hide();
	frame.RealmSelector.Button:Enable();
	StoreVASValidationFrame_ValidationDescription_SetText(desc, true);
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
	self.productID = nil;
	self.productInfo = nil;
	StoreFrame_UpdateCoverState();
end

function StoreVASValidationState_Lock()
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	frame.RealmSelector.Button:Disable();
	frame.CharacterSelector.Button:Disable();
	frame.FollowGuildCheckbox:Disable();
	frame.TransferRealmEditbox:Disable();
	frame.TransferAccountCheckbox:Disable();
	frame.TransferAccountDropDown.Button:Disable();
	frame.TransferFactionCheckbox:Disable();
	frame.TransferBattlenetAccountEditbox:Disable();
	frame.TransferBnetWoWAccountDropDown.Button:Disable();
	frame.NewCharacterName:Disable();
	frame.NewGuildName:Disable();
	frame.ContinueButton:Disable();
	frame.RenameGuildCheckbox:Disable();
	frame.RenameGuildEditbox:Disable();
	frame.NewGuildMaster:Disable();
	frame.OldGuildNewName:Disable();
end

function StoreVASValidationState_Unlock()
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	frame.RealmSelector.Button:Enable();
	frame.FollowGuildCheckbox:Enable();
	frame.TransferRealmEditbox:Enable();
	frame.TransferAccountCheckbox:Enable();
	frame.TransferAccountDropDown.Button:Enable();
	frame.TransferFactionCheckbox:Enable();
	frame.TransferBattlenetAccountEditbox:Enable();
	frame.TransferBnetWoWAccountDropDown.Button:Enable();
	frame.NewCharacterName:Enable();
	frame.NewGuildName:Enable();
	frame.ContinueButton:Enable();
	frame.RenameGuildCheckbox:Enable();
	frame.RenameGuildEditbox:Enable();
	frame.NewGuildMaster:Enable();
	frame.OldGuildNewName:Enable();
	UpdateCharacterSelectorState()
end

function StoreProductCard_UpdateAllStates()
	for card in StoreFrame.productCardPoolCollection:EnumerateActive() do
		card:UpdateState();
	end
end

function StoreProductCard_CheckShowStorePreviewOnClick(self)
	local showPreview;
	if ( IsOnGlueScreen() ) then
		showPreview = _G.IsControlKeyDown();
	else
		showPreview = IsModifiedClick("DRESSUP");
	end
	if ( showPreview ) then
		local entryInfo = C_StoreSecure.GetEntryInfo(self:GetID());
		if ( entryInfo.displayID ) then
			StoreFrame_ShowPreviews(entryInfo.sharedData.cards);
		end
	end

	return showPreview;
end

function StoreProductCard_OnMouseDown(self, ...)
	self.ModelScene:OnMouseDown(...);
end

function StoreProductCard_OnMouseUp(self, ...)
	self.ModelScene:OnMouseUp(...);
end

function StoreSplashSingleProductCard_OnClick(self)
	StoreProductCard_CheckShowStorePreviewOnClick(self);
end

function StoreProductCard_ShowModel(self, entryInfo, showShadows, forceModelUpdate)
	local cards = entryInfo.sharedData.cards;
	local modelSceneID = entryInfo.sharedData.modelSceneID or cards[1].modelSceneID; -- Shared data can specify a scene to override, otherwise use the scene for the model on the card

	self.ModelScene:Show();
	if self.Shadows then
		self.Shadows:SetShown(showShadows);
	end
	self.ModelScene:ClearScene();
	self.ModelScene:SetFromModelSceneID(modelSceneID, forceModelUpdate);

	local hasMultipleModels = #cards > 1;
	local baseActorTag = "item";

	for index, card in ipairs(cards) do
		local actorTag;
		if hasMultipleModels then
			actorTag = baseActorTag .. index;
		else
			actorTag = baseActorTag;
		end

		if card.creatureDisplayInfoID and card.creatureDisplayInfoID > 0 then
			local actor = self.ModelScene:GetActorByTag(actorTag);
			SetupItemPreviewActor(actor, card.creatureDisplayInfoID);
		else
			SetupPlayerForModelScene(self.ModelScene, card.itemModifiedAppearanceIDs);
		end
	end

	-- HACK: This should be driven by the data returned from GetModelSceneCameraInfo, not the model count.
	-- The restoration of left mouse and x-axis movement changing yaw is an orbit camera default
	local activeCamera = self.ModelScene:GetActiveCamera();
	if activeCamera then
		local cameraEnabled = not hasMultipleModels;
		if cameraEnabled then
			activeCamera:ResetDefaultInputModes();
		else
			activeCamera:SetLeftMouseButtonXMode(ORBIT_CAMERA_MOUSE_MODE_NOTHING, true);
			activeCamera:SetMouseWheelMode(ORBIT_CAMERA_MOUSE_MODE_NOTHING, false);
		end
	end
end

function StoreProductCard_HideModel(self)
	if self.ModelScene then
		self.ModelScene:Hide();
	end

	if self.Shadows then
		self.Shadows:Hide();
	end
end

function StoreCategory_OnEnter(self)
	if self.disabledTooltip then
	 	StoreTooltip:ClearAllPoints();
		StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
		StoreTooltip_Show("", self.disabledTooltip);
	else
		self.HighlightTexture:Show();
	end
end

function StoreCategory_OnLeave(self)
	self.HighlightTexture:Hide();
	StoreTooltip:Hide();
end

function StoreCategory_OnClick(self,button,down)
	if self:GetID() == StoreFrame_GetSelectedCategoryID() then
		-- category hasn't changed
		return;
	end

	selectedEntryID = nil;
	StoreFrame_SetSelectedCategoryID(self:GetID());

	StoreFrame_UpdateCategories(StoreFrame);

	selectedPageNum = 1;
	StoreFrame_SetCategory(self:GetID());

	StoreProductCard_UpdateAllStates();
	PlaySound(SOUNDKIT.UI_IG_STORE_PAGE_NAV_BUTTON);
end

----------------------------------
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
	local modelFrameLevel = 200; -- just a reasonable safe default value
	for card in StoreFrame.productCardPoolCollection:EnumerateActive() do
		modelFrameLevel = card.ModelScene:GetFrameLevel() + 2;
		break;
	end
	self:SetFrameLevel(modelFrameLevel);
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
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
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

	UpdateCharacterList();

	RealmAutoCompleteList = nil;
	DestinationRealmMapping = {};
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	frame.RealmSelector.Text:SetText(SelectedRealm.realmName);
	frame.ClassIcon:Hide();
	frame.SelectedCharacterName:Hide();
	frame.SelectedCharacterDescription:Hide();
	frame.SelectedCharacterFrame:Hide();
	frame.FollowGuildCheckbox:Hide();
	frame.FollowGuildErrorMessage:Hide();
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
	frame.ChangeIconFrame:Hide();
	frame.NewCharacterName:SetText("");
	frame.NewCharacterName:Hide();
	frame.GuildIcon:Hide();
	frame.SelectedGuildName:Hide();
	frame.NewGuildName:SetText("");
	frame.NewGuildName:Hide();
	frame.RenameGuildCheckbox:Hide();
	frame.RenameGuildCheckbox:SetChecked(false);
	frame.RenameGuildEditbox:Hide();
	frame.RenameGuildEditbox:SetText("");
	frame.NewGuildMaster:Hide();
	frame.NewGuildMaster:SetText("");
	frame.OldGuildNewName:Hide();
	frame.OldGuildNewName:SetText("");

	if not InstructionsShowing then
		frame.ContinueButton:Disable();
	end
end

function VASCharacterSelectionChangeIconFrame_OnEnter(self)
	local character = CharacterList[SelectedCharacter];

	local races = C_StoreSecure.GetEligibleRacesForVASService(character.guid, VASServiceType);

	local descStr = "";
	local seenAlliedRace = false;
	if races then
		for i = 1, #races do
			local raceInfo = races[i];
			if (raceInfo.isAlliedRace and not raceInfo.isHeritageArmorUnlocked) then
				descStr = descStr .. string.format(_G.BLIZZARD_STORE_VAS_RACE_CHANGE_TOOLTIP_LINE_ALLIED_RACE, raceInfo.raceName);
				seenAlliedRace = true;
			else
				descStr = descStr .. string.format(_G.BLIZZARD_STORE_VAS_RACE_CHANGE_TOOLTIP_LINE, raceInfo.raceName);
			end
			if (i ~= #races) then
				descStr = descStr .. "|n";
			end
		end
	end
	if (seenAlliedRace) then
		descStr = descStr .. "|n" .. _G.BLIZZARD_STORE_VAS_ALLIED_RACE_CHANGE_HERITAGE_WARNING;
	end

	StoreTooltip:ClearAllPoints();
	StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOP", 0, -4);
	local title = "";
	title = string.format(_G.BLIZZARD_STORE_VAS_RACE_CHANGE_TITLE, character.name);
	StoreTooltip_Show(title, descStr);
end

function VASCharacterSelectionChangeIconFrame_OnLeave()
	StoreTooltip:Hide();
end

function VASCharacterSelectionChangeIconFrame_SetIcons(character, serviceType)
	local frame = StoreVASValidationFrame.CharacterSelectionFrame.ChangeIconFrame;

	local gender;
	if (character.sex == 0) then
		gender = "male";
	else
		gender = "female";
	end

	local fromIcon = frame.FromIcon;
	fromIcon.Icon:SetAtlas(_G.GetRaceAtlas(string.lower(character.raceFileName), gender), false);
	fromIcon.Icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375);
	fromIcon:Show();

	local arrowTex = frame.ArrowTex;
	arrowTex:Show();

	local toIcon = frame.ToIcon;
	if (not toIcon) then
		toIcon = CreateForbiddenFrame("Frame", nil, frame, "StoreVASRaceFactionIconFrameTemplate");
		toIcon:SetPoint("LEFT", arrowTex, "RIGHT", 4, 0);
		toIcon.Icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375);
		frame.ToIcon = toIcon;
	end

	if (serviceType == Enum.VasServiceType.FactionChange) then
		toIcon.Icon:SetTexture(GetFactionIcon(character.faction, true));
	else
		toIcon.Icon:SetTexture("Interface\\Icons\\inv_misc_questionmark");
	end
	toIcon:Show();

	frame.ViewRaces:SetText(_G.BLIZZARD_STORE_VAS_RACE_CHANGE_VIEW_AVAILABLE_RACES);

	frame:Show();
end

local function UpdateFactionTransferCheckBoxForFaction(self, faction)
	local bundleProductInfo = GetBundleProductInfo(self.productID);
	local newFaction = GetFactionName(faction, true);
	-- We don't filter the character list, this prevents a lua error if a neutral pandarian is selected.
	if bundleProductInfo and newFaction ~= "" then
		local bundlePrice = bundleProductInfo.sharedData.currentDollars + (bundleProductInfo.sharedData.currentCents / 100);
		local basePrice = self.productInfo.sharedData.currentDollars + (self.productInfo.sharedData.currentCents / 100);
		local diffPrice = bundlePrice - basePrice;
		local diffDollars = math.floor(diffPrice);
		local diffCents = (diffPrice - diffDollars) * 100;
		self.CharacterSelectionFrame.TransferFactionCheckbox.Label:SetText(string.format(BLIZZARD_STORE_VAS_TRANSFER_FACTION_BUNDLE, newFaction, currencyFormatLong(diffDollars, diffCents)));
		self.CharacterSelectionFrame.TransferFactionCheckbox.Label:ApplyFontObjects();
		self.CharacterSelectionFrame.TransferFactionCheckbox:SetChecked(false);
		self.CharacterSelectionFrame.TransferFactionCheckbox:Show();
	else
		self.CharacterSelectionFrame.TransferFactionCheckbox:Hide();
	end
end

local function UpdateFollowGuildCheckbox(self, faction, guildFollowInfo)
	local guildFollowMatches = false;
	if IsVasServiceTypeEligibleForGuildFollow(VASServiceType) and guildFollowInfo then
		if VASServiceType == Enum.VasServiceType.CharacterTransfer then
			guildFollowMatches = guildFollowInfo.transferredRealm;
		elseif VASServiceType == Enum.VasServiceType.FactionChange then
			guildFollowMatches = guildFollowInfo.factionChanged;
		end
	end

	if guildFollowMatches then
		local followGuildNotAllowed = VASServiceType == Enum.VasServiceType.FactionChange and guildFollowInfo.transferredRealm and guildFollowInfo.factionChanged;
		if followGuildNotAllowed then
			local errorString;
			if guildFollowInfo.transferredRealm and guildFollowInfo.factionChanged then
				errorString = BLIZZARD_STORE_VAS_FOLLOW_GUILD_FACTION_TRANSFER_ERROR:format(guildFollowInfo.transferredRealm, GetFactionName(faction, true));
			else
				errorString = BLIZZARD_STORE_VAS_FOLLOW_GUILD_TRANSFER_ERROR:format(guildFollowInfo.transferredRealm);
			end
			self.CharacterSelectionFrame.FollowGuildCheckbox:Hide();
			self.CharacterSelectionFrame.FollowGuildErrorMessage:SetText(errorString);
			self.CharacterSelectionFrame.FollowGuildErrorMessage:Show();
		else
			local checkboxString;
			if guildFollowInfo.transferredRealm and guildFollowInfo.factionChanged then
				local bundleProductInfo = GetBundleProductInfo(self.productID);
				local bundlePrice = bundleProductInfo.sharedData.currentDollars + (bundleProductInfo.sharedData.currentCents / 100);
				local basePrice = self.productInfo.sharedData.currentDollars + (self.productInfo.sharedData.currentCents / 100);
				local diffPrice = bundlePrice - basePrice;
				local diffDollars = math.floor(diffPrice);
				local diffCents = (diffPrice - diffDollars) * 100;
				checkboxString = BLIZZARD_STORE_VAS_FOLLOW_GUILD_FACTION_TRANSFER:format(guildFollowInfo.transferredRealm, GetFactionName(faction, true), currencyFormatLong(diffDollars, diffCents));
			elseif guildFollowInfo.transferredRealm then
				checkboxString = BLIZZARD_STORE_VAS_FOLLOW_GUILD_TRANSFER:format(guildFollowInfo.transferredRealm);
			else
				checkboxString = BLIZZARD_STORE_VAS_FOLLOW_GUILD_FACTION_CHANGE;
			end
			if VASServiceType == Enum.VasServiceType.FactionChange then
				self.CharacterSelectionFrame.FollowGuildCheckbox:SetPoint("TOPLEFT", self.CharacterSelectionFrame.SelectedCharacterFrame, "BOTTOMLEFT", 2, -3)
			else
				self.CharacterSelectionFrame.FollowGuildCheckbox:SetPoint("TOPLEFT", self.CharacterSelectionFrame.SelectedCharacterFrame, "BOTTOMLEFT", 2, -8)
			end
			self.CharacterSelectionFrame.FollowGuildCheckbox.Label:SetText(checkboxString);
			self.CharacterSelectionFrame.FollowGuildCheckbox:SetChecked(true);
			self.CharacterSelectionFrame.FollowGuildCheckbox:Show();
			self.CharacterSelectionFrame.FollowGuildErrorMessage:Hide();
		end

		self.CharacterSelectionFrame.ChangeIconFrame:SetPoint("TOPLEFT", self.CharacterSelectionFrame.SelectedCharacterFrame, "BOTTOMLEFT", 0, -42);
		self.CharacterSelectionFrame.TransferRealmEditbox:SetPoint("TOPRIGHT", self.CharacterSelectionFrame.SelectedCharacterFrame, "BOTTOMRIGHT", 8, -47);

		FollowGuildCheckbox_OnClick(self.CharacterSelectionFrame.FollowGuildCheckbox);
	else
		self.CharacterSelectionFrame.FollowGuildCheckbox:Hide();
		self.CharacterSelectionFrame.FollowGuildErrorMessage:Hide();
		self.CharacterSelectionFrame.ChangeIconFrame:SetPoint("TOPLEFT", self.CharacterSelectionFrame.SelectedCharacterFrame, "BOTTOMLEFT", 0, -4);
		self.CharacterSelectionFrame.TransferRealmEditbox:SetPoint("TOPRIGHT", self.CharacterSelectionFrame.SelectedCharacterFrame, "BOTTOMRIGHT", 8, -10);
	end
end

function VASCharacterSelectionCharacterSelector_Callback(value, guildFollowInfo)
	SelectedCharacter = value;
	GuildMemberAutoCompleteList = nil;
	GuildMemberNameToGuid = {};
	IsGuildFollow = false;

	local frame = StoreVASValidationFrame.CharacterSelectionFrame;
	local character = CharacterList[SelectedCharacter];
	local level = character.level;
	if (level == 0) then
		level = 1;
	end

	if IsVasServiceTypeEligibleForGuildFollow(VASServiceType) then
		if not guildFollowInfo then
			if CharacterWaitingOnGuildFollowInfo ~= character.guid then
				-- wait for STORE_GUILD_FOLLOW_INFO_RECEIVED event
				CharacterWaitingOnGuildFollowInfo = character.guid;
				C_StoreSecure.RequestCharacterGuildFollowInfo(character.guid, SelectedRealm.virtualRealmAddress);
			end
			return;
		end
	end

	frame.SelectedCharacterFrame:Show();

	if IsGuildVasServiceType(VASServiceType) then
		local guildMasterInfo = GetGuildMasterInfoForCharacter(character.guid);

		frame.GuildIcon:SetTexture(GetFactionIcon(character.faction));
		frame.GuildIcon:Show();
		frame.SelectedGuildName:SetText(guildMasterInfo.guildName);
		frame.SelectedGuildName:Show();

		frame.ClassIcon:Hide();
		frame.SelectedCharacterName:Hide();
		frame.SelectedCharacterDescription:Hide();
	else
		frame.GuildIcon:Hide();
		frame.SelectedGuildName:Hide();

		frame.ClassIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[character.classFileName]));
		frame.ClassIcon:Show();
		frame.SelectedCharacterName:SetText(character.name);
		frame.SelectedCharacterName:Show();
		frame.SelectedCharacterDescription:SetText(string.format(VAS_SELECTED_CHARACTER_DESCRIPTION, level, character.raceName, character.className));
		frame.SelectedCharacterDescription:Show();
	end

	frame.ValidationDescription:SetTextColor(0, 0, 0);
	frame.ValidationDescription:Hide();

	StoreVASValidationState_Unlock();

	if (VASServiceType == Enum.VasServiceType.NameChange) then
		frame.NewCharacterName:SetText("");
		frame.NewCharacterName:Show();
		frame.NewCharacterName:SetFocus();
		frame.ContinueButton:Disable();
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", frame.NewCharacterName, "BOTTOMLEFT", -5, -8);
	elseif (VASServiceType == Enum.VasServiceType.GuildNameChange) then
		frame.NewGuildName:SetText("");
		frame.NewGuildName:Show();
		frame.NewGuildName:SetFocus();
		frame.ContinueButton:Disable();
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", frame.NewGuildName, "BOTTOMLEFT", -5, -8);
	elseif (VASServiceType == Enum.VasServiceType.GuildFactionChange) then
		frame.RenameGuildCheckbox:ClearAllPoints();
		frame.RenameGuildCheckbox:SetPoint("TOPLEFT", frame.SelectedCharacterFrame, "BOTTOMLEFT", 5, -8);
		frame.RenameGuildCheckbox:Show();
		frame.RenameGuildCheckbox.Label:ApplyFontObjects();
		frame.RenameGuildCheckbox:SetChecked(false);
		frame.RenameGuildEditbox:ClearAllPoints();
		frame.RenameGuildEditbox:SetPoint("TOPRIGHT", frame.SelectedCharacterFrame, "BOTTOMRIGHT", 8, -12);
		frame.RenameGuildEditbox:SetText("");
		frame.RenameGuildEditbox:Hide();
		frame.NewGuildMaster:SetText("");
		frame.NewGuildMaster:Show();
		frame.OldGuildNewName:SetText("");
		frame.OldGuildNewName:Show();
		frame.ContinueButton:Disable();
	elseif (VASServiceType == Enum.VasServiceType.GuildTransfer) then
		frame.TransferRealmEditbox.Label:Show();
		frame.TransferRealmEditbox:SetText("");
		frame.TransferRealmEditbox:Show();
		frame.NewGuildMaster:SetText("");
		frame.NewGuildMaster:Show();
		frame.RenameGuildCheckbox:ClearAllPoints();
		frame.RenameGuildCheckbox:SetPoint("TOPLEFT", frame.SelectedCharacterFrame, "BOTTOMLEFT", 5, -88);
		frame.RenameGuildCheckbox:Show();
		frame.RenameGuildCheckbox.Label:ApplyFontObjects();
		frame.RenameGuildCheckbox:SetChecked(false);
		frame.RenameGuildEditbox:ClearAllPoints();
		frame.RenameGuildEditbox:SetPoint("TOPRIGHT", frame.SelectedCharacterFrame, "BOTTOMRIGHT", 8, -92);
		frame.RenameGuildEditbox:SetText("");
		frame.RenameGuildEditbox:Hide();
		frame.TransferFactionCheckbox:ClearAllPoints();
		frame.TransferFactionCheckbox:SetPoint("TOPLEFT", frame.RenameGuildCheckbox, "BOTTOMLEFT", 0, -4);

		UpdateFactionTransferCheckBoxForFaction(StoreVASValidationFrame, character.faction);

		frame.ContinueButton:Disable();
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", frame.TransferFactionCheckbox, "BOTTOMLEFT", 8, -8);
	elseif (VASServiceType == Enum.VasServiceType.CharacterTransfer) then
		if (StoreVASValidationFrame.productInfo.sharedData.canChangeAccount and (StoreVASValidationFrame.productInfo.sharedData.canChangeBNetAccount or (#_G.C_Login.GetGameAccounts() > 1))) then
			frame.TransferAccountCheckbox:Show();
			frame.TransferAccountCheckbox.Label:ApplyFontObjects();
			frame.TransferFactionCheckbox:ClearAllPoints();
			frame.TransferFactionCheckbox:SetPoint("TOPLEFT", frame.TransferAccountCheckbox, "BOTTOMLEFT", 0, -4);
		else
			frame.TransferFactionCheckbox:ClearAllPoints();
			frame.TransferFactionCheckbox:SetPoint("TOPLEFT", frame.TransferRealmEditbox, "BOTTOMLEFT", -168, -12);
		end
		frame.TransferRealmEditbox:Show();
		frame.TransferRealmEditbox:SetText("");
		frame.TransferBattlenetAccountEditbox:Hide();
		frame.TransferBattlenetAccountEditbox:SetText("");
		frame.TransferBnetWoWAccountDropDown:Hide();
		frame.TransferAccountCheckbox:SetChecked(false);
		frame.TransferAccountDropDown.Text:SetText(BLIZZARD_STORE_VAS_SELECT_ACCOUNT);
		frame.TransferAccountDropDown:Hide();
		SelectedDestinationWowAccount = nil;
		SelectedDestinationBnetWowAccount = nil;

		UpdateFactionTransferCheckBoxForFaction(StoreVASValidationFrame, character.faction);

		StoreVASValidationFrame_SyncFontHeights(frame.TransferAccountCheckbox.Label, frame.TransferFactionCheckbox.Label);
		frame.ContinueButton:Disable();
	else
		local bottomWidget = frame.SelectedCharacterFrame;
		if (VASServiceType == Enum.VasServiceType.RaceChange or VASServiceType == Enum.VasServiceType.FactionChange) then
			local races = C_StoreSecure.GetEligibleRacesForVASService(character.guid, VASServiceType);

			if (not races or #races == 0) then
				frame.ChangeIconFrame:Hide();
				frame.ValidationDescription:ClearAllPoints();
				frame.ValidationDescription:SetPoint("TOPLEFT", frame.SelectedCharacterFrame, "BOTTOMLEFT", 8, -8);
				StoreVASValidationFrame_ValidationDescription_SetText(StoreVASValidationFrame_AppendError(BLIZZARD_STORE_VAS_ERROR_LABEL, Enum.VasError.RaceClassComboIneligible, character, true), true);
				frame.ValidationDescription:Show();
				frame.ContinueButton:Disable();
				return;
			end

			bottomWidget = frame.ChangeIconFrame;
			VASCharacterSelectionChangeIconFrame_SetIcons(character, VASServiceType);

			if (VASServiceType == Enum.VasServiceType.RaceChange) then
				StoreVASValidationFrame_ValidationDescription_SetText(VAS_RACE_CHANGE_VALIDATION_DESCRIPTION);
			elseif (VASServiceType == Enum.VasServiceType.FactionChange) then
				StoreVASValidationFrame_ValidationDescription_SetText(VAS_FACTION_CHANGE_VALIDATION_DESCRIPTION);
			end
			frame.ValidationDescription:Show();
		elseif (VASServiceType == Enum.VasServiceType.AppearanceChange) then
			StoreVASValidationFrame_ValidationDescription_SetText(VAS_APPEARANCE_CHANGE_VALIDATION_DESCRIPTION);
			frame.ValidationDescription:Show();
		end
		frame.ValidationDescription:ClearAllPoints();
		frame.ValidationDescription:SetPoint("TOPLEFT", bottomWidget, "BOTTOMLEFT", 8, -8);
		frame.ContinueButton:Enable();
	end

	UpdateFollowGuildCheckbox(StoreVASValidationFrame, character.faction, guildFollowInfo);
end

function VASRealmList_BuildAutoCompleteLists()
	local character = CharacterList[SelectedCharacter];

	if not RealmAutoCompleteList and (VASServiceType == Enum.VasServiceType.CharacterTransfer or VASServiceType == Enum.VasServiceType.GuildTransfer) then
		local realms = C_StoreSecure.GetVASRealmList();
		
		local infoTable = {};
		for _, realm in ipairs(realms) do
			if (realm.virtualRealmAddress ~= character.currentServer) then
				local name = realm.realmName;
				local listText = name;
				if realm.rp then
					listText = listText .. " " .. VAS_RP_PARENTHESES;
				end
				table.insert(infoTable, {value = name, text = listText});
				DestinationRealmMapping[name] = realm.virtualRealmAddress;
			end
		end

		RealmAutoCompleteList = infoTable;
	end

	if not GuildMemberAutoCompleteList and (VASServiceType == Enum.VasServiceType.GuildFactionChange or VASServiceType == Enum.VasServiceType.GuildTransfer) then
		local guildMasterInfo = GetGuildMasterInfoForCharacter(character.guid);

		local infoTable = {};
		for _, memberInfo in ipairs(guildMasterInfo.guildMemberInfos) do
			if (memberInfo.guid ~= character.guid) then
				table.insert(infoTable, {value = memberInfo.memberName, text = memberInfo.memberName});
				GuildMemberNameToGuid[memberInfo.memberName] = memberInfo.guid;
			end
		end

		GuildMemberAutoCompleteList = infoTable;
	end
end

local function GetStoreAutoCompleteList(self)
	if self.autoCompleteType == "realms" then
		return RealmAutoCompleteList;
	elseif self.autoCompleteType == "guildMembers" then
		return GuildMemberAutoCompleteList;
	end
end

function StoreGetAutoCompleteEntries(self, text, cursorPosition)
	local autoCompleteList = GetStoreAutoCompleteList(self);
	if not autoCompleteList or text == "" then
		-- So this is slightly different in Classic. They still show the full list if text is empty
		-- Mainline has far more realms so we probably want to keep the realm list empty in this case
		-- and continue to require the user start typing at least 1 character
		return {};
	end
	local entries = {};
	local str = string.lower(string.sub(text, 1, cursorPosition));
	local scrubbedString = string.gsub(str, "[%(%)%.%%%+%-%*%?%[%^%$]+", "");
	for _, info in ipairs(autoCompleteList) do
		if (string.find(string.lower(info.value), scrubbedString)) then
			table.insert(entries, info);
		end
	end
	return entries;
end

local VAS_AUTO_COMPLETE_MAX_ENTRIES = 10;
local VAS_AUTO_COMPLETE_OFFSET = 0;
local VAS_AUTO_COMPLETE_SELECTION = nil;
local VAS_AUTO_COMPLETE_ENTRIES = nil;

function StoreAutoCompleteButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	VAS_AUTO_COMPLETE_SELECTION = nil;
	VAS_AUTO_COMPLETE_OFFSET = 0;

	self:GetParent():GetParent():SetText(self.info);
	self:GetParent():Hide();
end

function StoreUpdateAutoComplete(self, text, cursorPosition)
	VASRealmList_BuildAutoCompleteLists();

	VAS_AUTO_COMPLETE_ENTRIES = StoreGetAutoCompleteEntries(self, text, cursorPosition);

	if (VAS_AUTO_COMPLETE_ENTRIES[1] and text == VAS_AUTO_COMPLETE_ENTRIES[1].value) then
		return;
	end

	local maxWidth = 0;
	local shownButtons = 0;
	local buttonOffset = 0;
	local box = self.AutoCompleteBox;
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
		button:SetScript("OnClick", StoreAutoCompleteButton_OnClick);
		button.info = VAS_AUTO_COMPLETE_ENTRIES[entryIndex].value;
		button:SetNormalFontObject("GameFontWhiteTiny2");
		button:SetHighlightFontObject("GameFontWhiteTiny2");
		button.Text:SetText(VAS_AUTO_COMPLETE_ENTRIES[entryIndex].text);
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
		button.Text:SetText(string.format(BLIZZARD_STORE_VAS_AUTOCOMPLETE_AND_MORE, (#VAS_AUTO_COMPLETE_ENTRIES - VAS_AUTO_COMPLETE_OFFSET - VAS_AUTO_COMPLETE_MAX_ENTRIES)));
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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	VAS_AUTO_COMPLETE_OFFSET = math.max(VAS_AUTO_COMPLETE_OFFSET - VAS_AUTO_COMPLETE_MAX_ENTRIES, 0);
	VAS_AUTO_COMPLETE_SELECTION = nil;

	local frame = self:GetParent():GetParent();

	StoreUpdateAutoComplete(frame, frame:GetText(), frame:GetCursorPosition());
end

function StoreAutoCompleteHasMore_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	VAS_AUTO_COMPLETE_OFFSET = math.min(VAS_AUTO_COMPLETE_OFFSET + VAS_AUTO_COMPLETE_MAX_ENTRIES, #VAS_AUTO_COMPLETE_ENTRIES - 1);
	VAS_AUTO_COMPLETE_SELECTION = nil;

	local frame = self:GetParent():GetParent();

	StoreUpdateAutoComplete(frame, frame:GetText(), frame:GetCursorPosition());
end

function StoreAutoCompleteIncrementSelection(self)
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

	StoreUpdateAutoComplete(self, self:GetText(), self:GetCursorPosition());
end

function StoreAutoCompleteDecrementSelection(self)
	if (VAS_AUTO_COMPLETE_SELECTION and #VAS_AUTO_COMPLETE_ENTRIES > 0) then
		if (VAS_AUTO_COMPLETE_SELECTION == 1 and VAS_AUTO_COMPLETE_OFFSET > 0) then
			VAS_AUTO_COMPLETE_OFFSET = VAS_AUTO_COMPLETE_OFFSET - 1;
		elseif (VAS_AUTO_COMPLETE_SELECTION > 1) then
			VAS_AUTO_COMPLETE_SELECTION = VAS_AUTO_COMPLETE_SELECTION - 1;
		end

		StoreUpdateAutoComplete(self, self:GetText(), self:GetCursorPosition());
	end
end

function StoreAutoCompleteSelectionEnterPressed(self)
	if (VAS_AUTO_COMPLETE_SELECTION) then
		local info = VAS_AUTO_COMPLETE_ENTRIES[VAS_AUTO_COMPLETE_SELECTION + VAS_AUTO_COMPLETE_OFFSET];
		VAS_AUTO_COMPLETE_SELECTION = nil;
		VAS_AUTO_COMPLETE_OFFSET = 0;

		self:SetText(info.value);
		self.AutoCompleteBox:Hide();
	end
end

local function PlayCheckboxSound(self)
	local sound = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON;
	if (not self:GetChecked()) then
		sound = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF;
	end
	PlaySound(sound);
end

function VASCharacterSelection_NewCharacterName_OnTextChanged(self)
	self:GetParent().ValidationDescription:Hide();

	local character = CharacterList[SelectedCharacter];

	local newNameText = self:GetText();
	local enabled = newNameText ~= "" and newNameText ~= character.name;

	self:GetParent().ContinueButton:SetEnabled(enabled);
end

function VASCharacterSelection_NewGuildName_OnTextChanged(self)
	self:GetParent().ValidationDescription:Hide();

	local character = CharacterList[SelectedCharacter];
	local guildMasterInfo = GetGuildMasterInfoForCharacter(character.guid);

	local newNameText = self:GetText();
	local enabled = newNameText ~= "" and newNameText ~= guildMasterInfo.guildName;

	self:GetParent().ContinueButton:SetEnabled(enabled);
end

function RenameGuildCheckbox_OnClick(self)
	PlayCheckboxSound(self);

	if VASServiceType == Enum.VasServiceType.GuildTransfer then
		self:GetParent().RenameGuildEditbox:SetText("");

		if (self:GetChecked()) then
			self:GetParent().RenameGuildEditbox:Show();
		else
			self:GetParent().RenameGuildEditbox:Hide();
		end

		VASCharacterSelection_GuildTransfer_GatherAndValidateData();
	elseif VASServiceType == Enum.VasServiceType.GuildFactionChange then
		self:GetParent().RenameGuildEditbox:SetText("");
		self:GetParent().OldGuildNewName:SetText("");

		if (self:GetChecked()) then
			self:GetParent().RenameGuildEditbox:Show();
			self:GetParent().OldGuildNewName:Hide();
		else
			self:GetParent().RenameGuildEditbox:Hide();
			self:GetParent().OldGuildNewName:Show();
		end

		VASCharacterSelection_GuildFactionChange_GatherAndValidateData();
	end
end

function VASCharacterSelection_GuildVASEditbox_OnTextChanged(self)
	self.EmptyText:SetShown(not self:GetText() or self:GetText() == "");

	if VASServiceType == Enum.VasServiceType.GuildTransfer then
		VASCharacterSelection_GuildTransfer_GatherAndValidateData();
	elseif VASServiceType == Enum.VasServiceType.GuildFactionChange then
		VASCharacterSelection_GuildFactionChange_GatherAndValidateData();
	end
end

function VASCharacterSelection_GuildFactionChange_GatherAndValidateData()
	local renameGuildCheckbox = StoreVASValidationFrame.CharacterSelectionFrame.RenameGuildCheckbox;
	local renameGuildEditbox = StoreVASValidationFrame.CharacterSelectionFrame.RenameGuildEditbox;
	local newGuildMasterEditBox = StoreVASValidationFrame.CharacterSelectionFrame.NewGuildMaster;
	local oldGuildNewNameEditBox = StoreVASValidationFrame.CharacterSelectionFrame.OldGuildNewName;
	local continueButton = StoreVASValidationFrame.CharacterSelectionFrame.ContinueButton;

	StoreVASValidationFrame_UpdateGuildFactionChangeValidationPosition();

	local passed = false;

	NewGuildMaster = newGuildMasterEditBox:GetText();

	if GuildMemberNameToGuid[NewGuildMaster] then
		if (renameGuildCheckbox:GetChecked()) then
			passed = renameGuildEditbox:GetText() and renameGuildEditbox:GetText() ~= "";
		else
			passed = oldGuildNewNameEditBox:GetText() and oldGuildNewNameEditBox:GetText() ~= "";
		end
	end

	if passed then
		continueButton:Enable();
	else
		continueButton:Disable();
	end
end

function VASCharacterSelection_GuildTransfer_GatherAndValidateData()
	local character = CharacterList[SelectedCharacter];

	local transferRealmEditbox = StoreVASValidationFrame.CharacterSelectionFrame.TransferRealmEditbox;
	local newGuildMasterEditBox = StoreVASValidationFrame.CharacterSelectionFrame.NewGuildMaster;
	local renameGuildCheckbox = StoreVASValidationFrame.CharacterSelectionFrame.RenameGuildCheckbox;
	local renameGuildEditbox = StoreVASValidationFrame.CharacterSelectionFrame.RenameGuildEditbox;
	local continueButton = StoreVASValidationFrame.CharacterSelectionFrame.ContinueButton;

	local passed = false;

	if transferRealmEditbox:GetText() and transferRealmEditbox:GetText() ~= "" then
		SelectedDestinationRealm = transferRealmEditbox:GetText();
		NewGuildMaster = newGuildMasterEditBox:GetText();

		if DestinationRealmMapping[SelectedDestinationRealm] and GuildMemberNameToGuid[NewGuildMaster] then
			if (renameGuildCheckbox:GetChecked()) then
				passed = renameGuildEditbox:GetText() and renameGuildEditbox:GetText() ~= "";
			else
				passed = true;
			end
		end
	end

	if passed then
		continueButton:Enable();
	else
		continueButton:Disable();
	end
end

function FollowGuildCheckbox_OnClick(self)
	PlayCheckboxSound(self);

	IsGuildFollow = self:GetChecked();

	local showOthers = not self:GetChecked() and VASServiceType ~= Enum.VasServiceType.FactionChange;
	self:GetParent().TransferRealmEditbox:SetShown(showOthers);
	self:GetParent().TransferAccountCheckbox:SetShown(showOthers);

	self:GetParent().TransferAccountDropDown:SetShown(showOthers and self:GetParent().TransferAccountCheckbox:GetChecked());
	self:GetParent().TransferBattlenetAccountEditbox:SetShown(showOthers and SelectedDestinationWowAccount == BLIZZARD_STORE_VAS_DIFFERENT_BNET);
	self:GetParent().TransferFactionCheckbox:SetShown(showOthers and not self:GetParent().TransferAccountCheckbox:GetChecked());

	if not showOthers then
		SelectedDestinationRealm = nil;
		SelectedDestinationWowAccount = nil;
		SelectedDestinationBnetAccount = nil;
		SelectedDestinationBnetWowAccount = nil;

		self:GetParent().TransferRealmEditbox:SetText("");
		self:GetParent().TransferAccountCheckbox:SetChecked(false);
		self:GetParent().TransferAccountDropDown.Text:SetText(BLIZZARD_STORE_VAS_SELECT_ACCOUNT);
	end

	VASCharacterSelectionTransferGatherAndValidateData();
end

function StoreEditBoxWithAutoCompleteTemplate_OnCursorChanged(self)
	VAS_AUTO_COMPLETE_OFFSET = 0;
	VAS_AUTO_COMPLETE_SELECTION = nil;

	StoreUpdateAutoComplete(self, self:GetText(), self:GetCursorPosition());
end

function StoreEditBoxWithAutoCompleteTemplate_OnTextChanged(self)
	VAS_AUTO_COMPLETE_OFFSET = 0;
	VAS_AUTO_COMPLETE_SELECTION = nil;

	self.EmptyText:SetShown(not self:GetText() or self:GetText() == "");
	StoreUpdateAutoComplete(self, self:GetText(), self:GetCursorPosition());

	if VASServiceType == Enum.VasServiceType.GuildTransfer then
		VASCharacterSelection_GuildTransfer_GatherAndValidateData();
	elseif VASServiceType == Enum.VasServiceType.GuildFactionChange then
		VASCharacterSelection_GuildFactionChange_GatherAndValidateData();
	elseif VASServiceType == Enum.VasServiceType.CharacterTransfer then
		VASCharacterSelectionTransferGatherAndValidateData();
	end
end

function StoreAutoCompleteBox_OnHide(self)
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
		TransferFactionChangeBundle = false;
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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	if (self:GetParent().List:IsShown()) then
		self:GetParent().List:Hide();
		return;
	end

	RealmList = C_StoreSecure.GetRealmList();

	local infoTable = {};
	for i = 1, #RealmList do
		infoTable[#infoTable+1] = {text=RealmList[i].realmName, value=RealmList[i], checked=(SelectedRealm == RealmList[i])};
	end

	StoreDropDown_SetDropdown(self:GetParent(), infoTable, VASCharacterSelectionRealmSelector_Callback);
end

function VASCharacterSelectionCharacterSelector_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	if (self:GetParent().List:IsShown()) then
		self:GetParent().List:Hide();
		return;
	end

	if (not SelectedRealm) then
		-- This should not happen, it means you have no realm selected.
		return;
	end

	if RealmWaitingOnGuildMasterInfo == SelectedRealm.virtualRealmAddress then
		-- We are waiting for guild master info, just return until we get it
		return;
	end

	local infoTable = {};
	for i = 1, #CharacterList do
		local character = CharacterList[i];
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

function VASCharacterSelection_CheckForValidName(self, nameToCheck, validNameCheckFunction)
	local valid, reason = validNameCheckFunction(nameToCheck);
	if not valid then
		StoreVASValidationFrame_ValidationDescription_SetText(_G[reason], true);
		self:GetParent().ValidationDescription:Show();
		StoreVASValidationState_Unlock();
		self:GetParent().ContinueButton:Disable();
		return false;
	end

	return true;
end

function VASCharacterSelectionContinueButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	if InstructionsShowing then
		InstructionsShowing = false;
		StoreVASValidationFrame_SetVASStart(self:GetParent():GetParent());
		return;
	end

	if (not SelectedRealm or not SelectedCharacter) then
		-- This should not happen, as this button should be disabled unless you have both selected.
		return;
	end

	StoreVASValidationState_Lock();
	VASCharacterSelectionStartTimeout();

	if (not CharacterList[SelectedCharacter]) then
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
		NameChangeNewName = self:GetParent().NewCharacterName:GetText();

		if not VASCharacterSelection_CheckForValidName(self, NameChangeNewName, _G.C_CharacterCreation.IsCharacterNameValid) then
			return;
		end
	elseif ( VASServiceType == Enum.VasServiceType.GuildNameChange ) then
		NameChangeNewName = self:GetParent().NewGuildName:GetText();

		if not VASCharacterSelection_CheckForValidName(self, NameChangeNewName, _G.C_CharacterCreation.IsGuildNameValid) then
			return;
		end
	elseif ( VASServiceType == Enum.VasServiceType.GuildFactionChange ) then
		if self:GetParent().RenameGuildCheckbox:GetChecked() then
			NameChangeNewName = self:GetParent().RenameGuildEditbox:GetText();
			OldGuildNewName = nil;
			if not VASCharacterSelection_CheckForValidName(self, NameChangeNewName, _G.C_CharacterCreation.IsGuildNameValid) then
				return;
			end
		else
			NameChangeNewName = nil;
			OldGuildNewName = self:GetParent().OldGuildNewName:GetText();
			if not VASCharacterSelection_CheckForValidName(self, OldGuildNewName, _G.C_CharacterCreation.IsGuildNameValid) then
				return;
			end
		end

		if not VASCharacterSelection_CheckForValidName(self, NewGuildMaster, _G.C_CharacterCreation.IsCharacterNameValid) then
			return;
		end
	elseif ( VASServiceType == Enum.VasServiceType.GuildTransfer ) then
		if self:GetParent().RenameGuildCheckbox:GetChecked() then
			NameChangeNewName = self:GetParent().RenameGuildEditbox:GetText();
			if not VASCharacterSelection_CheckForValidName(self, NameChangeNewName, _G.C_CharacterCreation.IsGuildNameValid) then
				return;
			end
		end

		if not VASCharacterSelection_CheckForValidName(self, NewGuildMaster, _G.C_CharacterCreation.IsCharacterNameValid) then
			return;
		end
	end

	local isCharacterTransfer = VASServiceType == Enum.VasServiceType.CharacterTransfer;
	local isBnet = isCharacterTransfer and SelectedDestinationWowAccount == BLIZZARD_STORE_VAS_DIFFERENT_BNET;
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
	if ( C_StoreSecure.PurchaseVASProduct(entryInfo.productID, CharacterList[SelectedCharacter].guid, NameChangeNewName, OldGuildNewName, GuildMemberNameToGuid[NewGuildMaster], DestinationRealmMapping[SelectedDestinationRealm], wowAccountGUID, bnetAccountGUID, TransferFactionChangeBundle, IsGuildFollow) ) then
		WaitingOnConfirmation = true;
		WaitingOnConfirmationTime = GetTime();
		WaitingOnVASToCompleteToken = WaitingOnVASToComplete;
		StoreFrame_UpdateActivePanel(StoreFrame);
	end
end

function VASCharacterSelection_NewCharacterName_OnEnter(self)
 	StoreTooltip:ClearAllPoints();
	StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
	StoreTooltip_Show("", VAS_NAME_CHANGE_TOOLTIP);
end

function VASCharacterSelection_TransferRealmEditbox_OnEnter(self)
 	StoreTooltip:ClearAllPoints();
	StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
	StoreTooltip_Show("", VAS_TRANSFER_REALM_TOOLTIP);
end

function VASCharacterSelection_NewGuildName_OnEnter(self)
 	StoreTooltip:ClearAllPoints();
	StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
	if VASServiceType == Enum.VasServiceType.GuildTransfer then
		StoreTooltip_Show("", VAS_GUILD_NAME_CHANGE_TRANSFER_TOOLTIP);
	else
		StoreTooltip_Show("", VAS_GUILD_NAME_CHANGE_TOOLTIP);
	end
end

function VASCharacterSelection_RenameGuildCheckbox_OnEnter(self)
 	StoreTooltip:ClearAllPoints();
	StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
	StoreTooltip_Show("", VAS_GUILD_FACTION_NAME_CHANGE_CHECKBOX_TOOLTIP);
end

function VASCharacterSelection_NewGuildMaster_OnEnter(self)
 	StoreTooltip:ClearAllPoints();
	StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
	if VASServiceType == Enum.VasServiceType.GuildTransfer then
		StoreTooltip_Show("", VAS_NEW_GUILD_MASTER_TRANSFER_TOOLTIP);
	else
		StoreTooltip_Show("", VAS_NEW_GUILD_MASTER_FACTION_CHANGE_TOOLTIP);
	end
end

function VASCharacterSelection_OldGuildNewName_OnEnter(self)
 	StoreTooltip:ClearAllPoints();
	StoreTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
	StoreTooltip_Show("", VAS_OLD_GUILD_NEW_NAME_CHANGE_TOOLTIP);
end

function VASCharacterSelection_ClearStoreTooltip(self)
 	StoreTooltip:Hide();
end

function VASCharacterSelectionTransferAccountDropDown_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	if (self:GetParent().List:IsShown()) then
		self:GetParent().List:Hide();
		return;
	end
	local character = CharacterList[SelectedCharacter];
	local gameAccounts = _G.C_Login.GetGameAccounts();
	local infoTable = {};
	for i, gameAccount in ipairs(gameAccounts) do
		if (C_StoreSecure.GetWoWAccountGUIDFromName(gameAccount, true) ~= character.wowAccount) then
			infoTable[#infoTable+1] = {text=gameAccount, value=gameAccount, checked=(SelectedDestinationWowAccount == gameAccount)};
		end
	end

	if StoreVASValidationFrame.productInfo.sharedData.canChangeBNetAccount then
		infoTable[#infoTable+1] = {text=BLIZZARD_STORE_VAS_DIFFERENT_BNET, value=BLIZZARD_STORE_VAS_DIFFERENT_BNET, checked=(SelectedDestinationWowAccount == BLIZZARD_STORE_VAS_DIFFERENT_BNET)};
	end

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
	TransferFactionChangeBundle = self:GetChecked();
	if VASServiceType == Enum.VasServiceType.GuildTransfer then
		VASCharacterSelection_GuildTransfer_GatherAndValidateData();
	else
		VASCharacterSelectionTransferGatherAndValidateData();
	end
end

function StripWoWAccountLicenseInfo(gameAccount)
	if (string.find(gameAccount, '#')) then
		return string.gsub(gameAccount,'%d+\#(%d)','WoW%1');
	end
	return gameAccount;
end

function VASCharacterSelectionTransferBnetWoWAccountDropDown_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

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
	
	if not frame.TransferAccountCheckbox:GetChecked() and not(frame.TransferRealmEditbox:GetText() and frame.TransferRealmEditbox:GetText() ~= "") then
		return false
	end

	if frame.TransferAccountCheckbox:GetChecked() and SelectedDestinationWowAccount == BLIZZARD_STORE_VAS_DIFFERENT_BNET then
		local text = frame.TransferBattlenetAccountEditbox:GetText();
		if not(text and text ~= "" and string.find(text, ".+@.+\...+")) then
			return false;
		end
	end

	return true;
end

local function ShouldContinueButtonBeEnabled()
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;

	if VASServiceType == Enum.VasServiceType.FactionChange then
		return true;
	end

	if frame.FollowGuildCheckbox:IsShown() and frame.FollowGuildCheckbox:GetChecked() then
		return true;
	end

	if not VASCharacterSelectionTransferCheckEditBoxes() then
		return false;
	end

	if SelectedDestinationRealm and SelectedDestinationRealm ~= "" and not DestinationRealmMapping[SelectedDestinationRealm] then
		return false;
	end

	if frame.TransferAccountCheckbox:GetChecked() then
		if not SelectedDestinationWowAccount then
			return false;
		elseif SelectedDestinationWowAccount == BLIZZARD_STORE_VAS_DIFFERENT_BNET then
			if IsVasBnetTransferValidated and not SelectedDestinationBnetWowAccount then
				return false;
			end
		end
	end

	return true;
end

function VASCharacterSelectionTransferGatherAndValidateData()
	local frame = StoreVASValidationFrame.CharacterSelectionFrame;

	StoreVASValidationFrame_UpdateCharacterTransferValidationPosition();
	SelectedDestinationRealm = frame.TransferRealmEditbox:GetText();

	if frame.TransferAccountCheckbox:GetChecked() then
		if SelectedDestinationWowAccount == BLIZZARD_STORE_VAS_DIFFERENT_BNET then
			if not IsVasBnetTransferValidated then
				SelectedDestinationBnetAccount = frame.TransferBattlenetAccountEditbox:GetText();
			end
		end
	end

	frame.ContinueButton:SetEnabled(ShouldContinueButtonBeEnabled());
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
		Outbound.ConfirmClassTrialApplyToken(BoostDeliveredUsageGUID, BoostType);
	elseif (showReason == "forBoost") then
		C_CharacterServices.SetAutomaticBoost(BoostType);
	elseif (showReason == "forVasService") then
		C_StoreSecure.SetVASProductReady(true);
	elseif (showReason == "forLegion") then
		C_StoreSecure.SetDisconnectOnLogout(true);
	end

	ServicesLogoutPopup.showReason = nil;

	if doLogoutOnConfirm then
		PlaySound(SOUNDKIT.IG_MAINMENU_LOGOUT);
		Outbound.Logout();
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	ServicesLogoutPopup:Hide();
end

function ServicesLogoutPopupCancelButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
	if (StoreFrame:IsShown() and StoreFrame_GetSelectedCategoryID() == WOW_TOKEN_CATEGORY_ID) then
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

function StoreFrame_SetSelectedEntryID(entryID)
	selectedEntryID = entryID;
end

function StoreFrame_GetSelectedEntryID()
	return selectedEntryID;
end

function StoreFrameBuyButton_OnClick(self)
	StoreFrame_BeginPurchase(selectedEntryID);
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON);
end

StoreBulletPointMixin = {};

function StoreBulletPointMixin:OnLoad()
	BulletPointWithTextureMixin.OnLoad(self);
	self.Text:SetFontObject("GameFontNormalMed1");
	self.Text:SetTextColor(1, 0.84, 0.55);
end

function StoreBulletPointMixin:OnHyperlinkEnter()
	local grandparent = self:GetParent():GetParent();
	local onEnterScript = grandparent:GetScript("OnEnter");
	if onEnterScript then
		onEnterScript(grandparent);
	end
end

function StoreBulletPointMixin:OnHyperlinkLeave()
	local grandparent = self:GetParent():GetParent();
	local onLeaveScript = grandparent:GetScript("OnLeave");
	if onLeaveScript then
		onLeaveScript(grandparent);
	end
end

function StoreBulletPointMixin:OnHyperlinkClick(link)
	local grandparent = self:GetParent():GetParent();
	if not grandparent:IsEnabled() then
		return;
	end

	GetURLIndexAndLoadURL(self, link);
end
