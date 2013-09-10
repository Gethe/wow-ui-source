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
retain("math");
retain("pairs");
retain("tostring");
retain("tonumber");
retain("LoadURLIndex");
retain("GetContainerNumFreeSlots");
retain("PlaySound");
retain("BACKPACK_CONTAINER");
retain("NUM_BAG_SLOTS");

--GlobalStrings
retain("BLIZZARD_STORE");
take("BLIZZARD_STORE_ON_SALE");
take("BLIZZARD_STORE_BUY");
take("BLIZZARD_STORE_PLUS_TAX");
take("BLIZZARD_STORE_PRODUCT_INDEX");
take("BLIZZARD_STORE_CANCEL_PURCHASE");
take("BLIZZARD_STORE_FINAL_BUY");
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
take("BLIZZARD_STORE_BROWSE_TEST_CURRENCY");
take("BLIZZARD_STORE_CURRENCY_FORMAT_USD");
take("BLIZZARD_STORE_CURRENCY_FORMAT_KRW_LONG");
take("BLIZZARD_STORE_CURRENCY_FORMAT_CPT_LONG");
take("BLIZZARD_STORE_CURRENCY_FORMAT_TPT");
take("BLIZZARD_STORE_CURRENCY_RAW_ASTERISK");
take("BLIZZARD_STORE_CURRENCY_BETA");
take("BLIZZARD_STORE_BROWSE_BATTLE_COINS_KR");
take("BLIZZARD_STORE_BROWSE_BATTLE_COINS_CN");
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
take("BLIZZARD_STORE_REGION_LOCKED");
take("BLIZZARD_STORE_REGION_LOCKED_SUBTEXT");
take("BLIZZARD_STORE_ERROR_TITLE_INSUFFICIENT_BALANCE");
take("BLIZZARD_STORE_ERROR_MESSAGE_INSUFFICIENT_BALANCE");

retain("OKAY");
retain("LARGE_NUMBER_SEPERATOR");
retain("DECIMAL_SEPERATOR");

--Lua enums
take("LE_STORE_ERROR_INVALID_PAYMENT_METHOD");
take("LE_STORE_ERROR_PAYMENT_FAILED");
take("LE_STORE_ERROR_WRONG_CURRENCY");
take("LE_STORE_ERROR_BATTLEPAY_DISABLED");
take("LE_STORE_ERROR_INSUFFICIENT_BALANCE");
take("LE_STORE_ERROR_OTHER");

