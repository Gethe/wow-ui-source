local contents = {};
local issecure = issecure;
local type = type;
local pairs = pairs;

--Create a local version of this function just so we don't have to worry about changes
local function copyTable(tab)
	local copy = {};
	for k, v in pairs(tab) do
		if ( type(v) == "table" ) then
			copy[k] = copyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end

function SecureCapsuleGet(name)
	if ( not issecure() ) then
		return;
	end

	if ( type(contents[name]) == "table" ) then
		--Segment the users
		return copyTable(contents[name]);
	else
		return contents[name];
	end
end

-------------------------------
--Local functions for retaining.
-------------------------------

--Retains a copy of name
local function retain(name)
	if ( type(_G[name]) == "table" ) then
		contents[name] = copyTable(_G[name]);
	else
		contents[name] = _G[name];
	end
end

--Takes name and removes it from the global environment (note: make sure that nothing else has saved off a copy)
local function take(name)
	contents[name] = _G[name];
	_G[name] = nil;
end


-------------------------------
--Things we actually want to save
-------------------------------

--If storing off Lua functions, be careful that they don't in turn call any other Lua functions that may have been swapped out.

--For store
if ( IsGMClient() ) then
	retain("C_PurchaseAPI");
else
	take("C_PurchaseAPI");
end
take("CreateForbiddenFrame");
retain("IsGMClient");
retain("IsOnGlueScreen");
retain("math");
retain("pairs");
retain("select");
retain("unpack");
retain("tostring");
retain("tonumber");
retain("LoadURLIndex");
retain("GetContainerNumFreeSlots");
retain("GetCursorPosition");
retain("GetRealmName");
retain("PlaySound");
retain("SetPortraitToTexture");
retain("BACKPACK_CONTAINER");
retain("NUM_BAG_SLOTS");
retain("RAID_CLASS_COLORS");
retain("C_PetJournal");
retain("IsModifiedClick");
retain("GetTime");
retain("UnitAffectingCombat");

--For auth challenge
take("C_AuthChallenge");
retain("IsShiftKeyDown");
retain("GetBindingFromClick");

--For character services
take("C_SharedCharacterServices");

--GlobalStrings
retain("BLIZZARD_STORE");
take("BLIZZARD_STORE_ON_SALE");
take("BLIZZARD_STORE_BUY");
take("BLIZZARD_STORE_BUY_EUR");
take("BLIZZARD_STORE_PLUS_TAX");
take("BLIZZARD_STORE_PRODUCT_INDEX");
take("BLIZZARD_STORE_CANCEL_PURCHASE");
take("BLIZZARD_STORE_FINAL_BUY");
take("BLIZZARD_STORE_FINAL_BUY_EUR");
take("BLIZZARD_STORE_CONFIRMATION_TITLE");
take("BLIZZARD_STORE_CONFIRMATION_INSTRUCTION");
take("BLIZZARD_STORE_FINAL_PRICE_LABEL");
take("BLIZZARD_STORE_PAYMENT_METHOD");
take("BLIZZARD_STORE_PAYMENT_METHOD_EXTRA");
take("BLIZZARD_STORE_LOADING");
take("BLIZZARD_STORE_PLEASE_WAIT");
take("BLIZZARD_STORE_NO_ITEMS");
take("BLIZZARD_STORE_CHECK_BACK_LATER");
take("BLIZZARD_STORE_TRANSACTION_IN_PROGRESS");
take("BLIZZARD_STORE_CONNECTING");
take("BLIZZARD_STORE_VISIT_WEBSITE");
take("BLIZZARD_STORE_VISIT_WEBSITE_WARNING");
take("BLIZZARD_STORE_BAG_FULL");
take("BLIZZARD_STORE_BAG_FULL_DESC");
take("BLIZZARD_STORE_CONFIRMATION_GENERIC");
take("BLIZZARD_STORE_CONFIRMATION_TEST");
take("BLIZZARD_STORE_CONFIRMATION_EUR");
take("BLIZZARD_STORE_CONFIRMATION_SERVICES");
take("BLIZZARD_STORE_CONFIRMATION_SERVICES_TEST");
take("BLIZZARD_STORE_CONFIRMATION_SERVICES_EUR");
take("BLIZZARD_STORE_BROWSE_TEST_CURRENCY");
take("BLIZZARD_STORE_BATTLE_NET_BALANCE");
take("BLIZZARD_STORE_CURRENCY_FORMAT_USD");
take("BLIZZARD_STORE_CURRENCY_FORMAT_KRW_LONG");
take("BLIZZARD_STORE_CURRENCY_FORMAT_CPT_LONG");
take("BLIZZARD_STORE_CURRENCY_FORMAT_TPT");
take("BLIZZARD_STORE_CURRENCY_FORMAT_GBP");
take("BLIZZARD_STORE_CURRENCY_FORMAT_EURO");
take("BLIZZARD_STORE_CURRENCY_FORMAT_RUB");
take("BLIZZARD_STORE_CURRENCY_FORMAT_MXN");
take("BLIZZARD_STORE_CURRENCY_FORMAT_BRL");
take("BLIZZARD_STORE_CURRENCY_FORMAT_ARS");
take("BLIZZARD_STORE_CURRENCY_FORMAT_CLP");
take("BLIZZARD_STORE_CURRENCY_FORMAT_AUD");
take("BLIZZARD_STORE_CURRENCY_RAW_ASTERISK");
take("BLIZZARD_STORE_CURRENCY_BETA");
take("BLIZZARD_STORE_BROWSE_BATTLE_COINS_KR");
take("BLIZZARD_STORE_BROWSE_BATTLE_COINS_CN");
take("BLIZZARD_STORE_BROWSE_EUR");
take("BLIZZARD_STORE_ASTERISK");
take("BLIZZARD_STORE_INTERNAL_ERROR");
take("BLIZZARD_STORE_INTERNAL_ERROR_SUBTEXT");
take("BLIZZARD_STORE_ERROR_TITLE_OTHER");
take("BLIZZARD_STORE_ERROR_MESSAGE_OTHER");
take("BLIZZARD_STORE_NOT_AVAILABLE");
take("BLIZZARD_STORE_NOT_AVAILABLE_SUBTEXT");
take("BLIZZARD_STORE_ERROR_TITLE_PAYMENT");
take("BLIZZARD_STORE_ERROR_MESSAGE_PAYMENT");
take("BLIZZARD_STORE_ERROR_TITLE_BATTLEPAY_DISABLED");
take("BLIZZARD_STORE_ERROR_MESSAGE_BATTLEPAY_DISABLED");
take("BLIZZARD_STORE_SECOND_CHANCE_KR");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_CN");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_TW");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_USD");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_GBP");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_EUR");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_RUB");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_ARS");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_CLP");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_MXN");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_BRL");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_AUD");
take("BLIZZARD_STORE_REGION_LOCKED");
take("BLIZZARD_STORE_REGION_LOCKED_SUBTEXT");
take("BLIZZARD_STORE_ERROR_TITLE_INSUFFICIENT_BALANCE");
take("BLIZZARD_STORE_ERROR_MESSAGE_INSUFFICIENT_BALANCE");
take("BLIZZARD_STORE_ERROR_TITLE_ALREADY_OWNED");
take("BLIZZARD_STORE_ERROR_MESSAGE_ALREADY_OWNED");
take("BLIZZARD_STORE_ERROR_TITLE_PARENTAL_CONTROLS");
take("BLIZZARD_STORE_ERROR_MESSAGE_PARENTAL_CONTROLS");
take("BLIZZARD_STORE_ERROR_TITLE_PURCHASE_DENIED");
take("BLIZZARD_STORE_ERROR_MESSAGE_PURCHASE_DENIED");
take("BLIZZARD_STORE_DISCOUNT_TEXT_FORMAT");
take("BLIZZARD_STORE_PAGE_NUMBER");
take("BLIZZARD_STORE_SPLASH_BANNER_DISCOUNT_FORMAT");
take("BLIZZARD_STORE_SPLASH_BANNER_FEATURED");
take("BLIZZARD_STORE_SPLASH_BANNER_NEW");
take("BLIZZARD_STORE_WALLET_INFO");
take("BLIZZARD_STORE_PROCESSING");
take("BLIZZARD_STORE_PURCHASE_SENT");
take("BLIZZARD_STORE_BEING_PROCESSED_CHECK_BACK_LATER");
take("BLIZZARD_STORE_YOU_ALREADY_OWN_THIS");
take("CHARACTER_UPGRADE_LOG_OUT_NOW");
take("CHARACTER_UPGRADE_POPUP_LATER");
take("CHARACTER_UPGRADE_READY");
take("CHARACTER_UPGRADE_READY_DESCRIPTION");

retain("OKAY");
retain("LARGE_NUMBER_SEPERATOR");
retain("DECIMAL_SEPERATOR");
retain("TOOLTIP_DEFAULT_COLOR");
retain("TOOLTIP_DEFAULT_BACKGROUND_COLOR");

take("BLIZZARD_CHALLENGE_SUBMIT");
take("BLIZZARD_CHALLENGE_CANCEL");
take("BLIZZARD_CHALLENGE_CONNECTING");
take("BLIZZARD_CHALLENGE_OKAY");
take("BLIZZARD_CHALLENGE_DENIED_TITLE");
take("BLIZZARD_CHALLENGE_DENIED_DESCRIPTION");
take("BLIZZARD_CHALLENGE_ERROR_TITLE");
take("BLIZZARD_CHALLENGE_ERROR_DESCRIPTION");
take("BLIZZARD_CHALLENGE_SCREEN_EXPLANATION");

--Lua enums
take("LE_STORE_ERROR_INVALID_PAYMENT_METHOD");
take("LE_STORE_ERROR_PAYMENT_FAILED");
take("LE_STORE_ERROR_WRONG_CURRENCY");
take("LE_STORE_ERROR_BATTLEPAY_DISABLED");
take("LE_STORE_ERROR_INSUFFICIENT_BALANCE");
take("LE_STORE_ERROR_OTHER");
take("LE_STORE_ERROR_ALREADY_OWNED");
take("LE_STORE_ERROR_PARENTAL_CONTROLS_NO_PURCHASE");
take("LE_STORE_ERROR_PURCHASE_DENIED");
