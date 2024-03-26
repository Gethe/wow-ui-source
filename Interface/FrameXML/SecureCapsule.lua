local contents = {};
local issecure = issecure;
local type = type;
local pairs = pairs;
local select = select;
local error = error;
local format = string.format;

--Create a local version of this function just so we don't have to worry about changes
local function copyTable(tab, tableCopies)
	if not tableCopies then
		tableCopies = {};
	end

	local copy = {};
	tableCopies[tab] = copy;

	for k, v in pairs(tab) do
		if ( type(v) == "table" ) then
			if ( tableCopies[v] ) then
				copy[k] = tableCopies[v];
			else
				copy[k] = copyTable(v, tableCopies);
			end
		else
			copy[k] = v;
		end
	end
	return copy;
end

local function copyTableWithTypeCheck(tab, name, tableCopies)
	if not tableCopies then
		tableCopies = {};
	end

	local copy = {};
	tableCopies[tab] = copy;

	for k, v in pairs(tab) do
		if ( type(v) == "table" ) then
			if ( tableCopies[v] ) then
				copy[k] = tableCopies[v];
			else
				copy[k] = copyTableWithTypeCheck(v, name, tableCopies);
			end
		elseif ( type(v) == "userdata" ) then
			error(format("Secure Capsule: Cannot import userdata into secure capsule (importing %s)", name));
		else
			copy[k] = v;
		end
	end
	return copy;
end

function SecureCapsuleGet(name, skipTableCopy)
	if ( not issecure() ) then
		return;
	end

	if ( type(contents[name]) == "table" ) then
		--Segment the users, unless otherwise requested (likely segmented in its own sanitization)
		if skipTableCopy then
			return contents[name];
		else
			return copyTable(contents[name]);
		end
	else
		return contents[name];
	end
end

-------------------------------
--Local functions for retaining.
-------------------------------

local function RetainHelper(name, toTable, fromTable)
	if ( toTable[name] ) then
		error(format("Secure Capsule: Duplicate key retention \"%s\"", name));
	end

	local fromVal = fromTable[name];
	local fromType = type(fromVal);

	if ( fromType == "table" ) then
		toTable[name] = copyTableWithTypeCheck(fromVal, name);
	elseif ( fromType == "userdata" ) then
		error(format("Secure Capsule: Cannot import userdata into secure capsule (importing %s)", name));
	else
		toTable[name] = fromVal;
	end
end

--Retains a copy of name
local function retain(name)
	RetainHelper(name, contents, _G);
end

--Takes name and removes it from the global environment (note: make sure that nothing else has saved off a copy)
local function take(name)
	retain(name);
	_G[name] = nil;
end

--Removes something from the global environment entirely (note: make sure that any saved references are local and will not be returned or otherwise exposed under any circumstances)
local function remove(name)
	_G[name] = nil;
end

-- We create the "Enum" table directly in contents because we dont want the reference from _G in the secure environment
local function retainenum(name)
	if (not contents["Enum"]) then
		contents["Enum"] = {};
	end
	contents["Enum"][name] = copyTable(_G.Enum[name]);
end

local function takeenum(name)
	if ( not contents["Enum"] ) then
		contents["Enum"] = {};
	end
	contents["Enum"][name] = _G.Enum[name];
	_G.Enum[name] = nil;
end

-- Used to retain only certain keys from a table
local function retainfromtable(tblName, keyName)
	if ( type(_G[tblName]) ~= "table" ) then
		error(format("Secure Capsule: Cannot retain from table; %s is not a table.", tblName));
	end

	if ( not contents[tblName] ) then
		contents[tblName] = {};
	end

	RetainHelper(keyName, contents[tblName], _G[tblName]);
end

-- Used to take only certain keys from a table
local function takefromtable(tblName, keyName)
	local tbl = _G[tblName];
	if ( type(tbl) ~= "table" ) then
		error(format("Secure Capsule: Cannot take from table; %s is not a table.", tblName));
	end

	if ( not contents[tblName] ) then
		contents[tblName] = {};
	end

	RetainHelper(keyName, contents[tblName], tbl);
	tbl[keyName] = nil;
end

local function removefromtable(tblName, keyName)
	local tbl = _G[tblName];
	if ( type(tbl) ~= "table" ) then
		error(format("Secure Capsule: Cannot remove from table; %s is not a table.", tblName));
	end

	tbl[keyName] = nil;
end

-------------------------------
--Things we actually want to save
-------------------------------

--If storing off Lua functions, be careful that they don't in turn call any other Lua functions that may have been swapped out.

-- Generic utils
retain("math");
retain("max");
retain("ceil");
retain("floor");
retain("table");
retain("string");
retain("bit");
retain("pairs");
retain("ipairs");
retain("next");
retain("select");
retain("unpack");
retain("tostring");
retain("tonumber");
retain("date");
retain("time");
retain("type");
retain("wipe");
retain("error");
retain("assert");
retain("strtrim");
retain("getfenv");
retain("setfenv");
retain("setmetatable");
retain("getmetatable");
retain("issecure");
retain("forceinsecure");
retain("pcall");
retain("pack");
retain("securecallfunction");
retain("secureexecuterange");
retain("rawset");
retain("format");
retain("Round");
retain("tinsert");
retain("IsGMClient");
retain("IsOnGlueScreen");
retain("IsModifiedClick");
retain("GetTime");
retain("SafePack");
retain("GetCVar");
retain("GetCVarBool");
retain("UnitAffectingCombat");
retain("LOCALE_enGB");
retain("GetMouseFocus");
retain("CreateFrame");
retain("CreateCounter");
retain("Lerp");
retain("Clamp");
retain("ClampMod");
retain("NegateIf");
retain("PercentageBetween");
retain("Saturate");
retain("GetCursorDelta");
retain("GetScaledCursorDelta");
retain("CalculateAngleBetween");
retain("CalculateDistanceSq");
retain("ClampedPercentageBetween");
retain("AnchorUtil");
retain("EasingUtil");
retain("GetTickTime");
retain("Vector3D_Add");
retain("Vector3D_Normalize");
retain("Vector3D_ScaleBy");
retain("Vector3D_CalculateNormalFromYawPitch");
retain("Vector3D_CalculateYawPitchFromNormal");
retain("DeltaLerp");
retain("GetScreenWidth");
retain("GetScreenHeight");
retain("GetPhysicalScreenSize");
retain("GetScreenDPIScale");
retain("UnitFactionGroup");
retain("strlenutf8");
retain("UnitRace");
retain("UnitSex");
retain("CreateInterpolator");
retain("ApproximatelyEqual");
retain("GenerateClosure");
retain("WithinRangeExclusive");
retain("TextureKitConstants");
retain("CopyValuesAsKeys");
retain("UNKNOWN");
retain("PlaySound");
retain("PlaySoundFile");
retain("SOUNDKIT");
retain("TableUtil");
retain("CreateFromMixins");
retain("UnitIsUnit");
retain("SECONDS_PER_DAY");
retain("DAY_ONELETTER_ABBR");
retain("SECONDS_PER_HOUR");
retain("HOUR_ONELETTER_ABBR");
retain("SECONDS_PER_MIN");
retain("MINUTE_ONELETTER_ABBR");
retain("SECOND_ONELETTER_ABBR");
retain("SecondsToTimeAbbrev");
retain("HIGHLIGHT_FONT_COLOR");
retain("NORMAL_FONT_COLOR");
retain("GREEN_FONT_COLOR");
retain("RED_FONT_COLOR");
retain("DISABLED_FONT_COLOR");
retain("NineSliceLayouts");
retain("NineSliceUtil");
retain("NineSlicePanelMixin");
retain("ColorMixin");
retain("CreateColor");
retain("GetThreatStatusColor");
retain("GetItemInfo");
retain("GetSpellInfo");
retain("UnitTokenFromGUID");
retain("UnitName");
retain("UnitPlayerControlled");
retain("UnitCanAttack");
retain("UnitIsPVP");
retain("UnitReaction");
retain("C_Timer");
retain("C_CVar");
retain("C_UI");
retain("C_XMLUtil");
retain("GetFontStringMetatable");
retain("pcallwithenv");
retain("UnitGUID");
retain("C_GameEnvironmentManager");

-- For tooltips
retain("TOOLTIP_DEFAULT_BACKGROUND_COLOR");
retain("BattlePetToolTip_Show");
retain("SharedTooltip_SetBackdropStyle");
retain("C_TooltipInfo");
retain("C_Item");

--For store
if ( IsGMClient() ) then
	retain("HideGMOnly");
end
take("C_StoreSecure");
take("CreateForbiddenFrame");
retain("LoadURLIndex");
retain("C_Container");
retain("GetCursorPosition");
retain("GetRealmName");
retain("SetPortraitToTexture");
retain("SetPortraitTexture");
retain("BACKPACK_CONTAINER");
retain("NUM_BAG_SLOTS");
retain("NUM_TOTAL_EQUIPPED_BAG_SLOTS");
retain("RAID_CLASS_COLORS");
retain("CLASS_ICON_TCOORDS");
retain("C_ModelInfo");
retain("C_PlayerInfo");
retain("GMError");
retain("IsTrialAccount");
retain("IsVeteranTrialAccount");
retain("C_StorePublic");
retain("C_Club");
retain("GetUnscaledFrameRect");
retain("BLIZZARD_STORE_EXTERNAL_LINK_BUTTON_TEXT");
retain("IsCharacterNPERestricted");
retain("GetScaledCursorPosition");
retain("GetScaledCursorPositionForFrame");
retain("SCROLL_FRAME_SCROLL_BAR_TEMPLATE");
retain("SCROLL_FRAME_SCROLL_BAR_OFFSET_LEFT");
retain("SCROLL_FRAME_SCROLL_BAR_OFFSET_TOP");
retain("SCROLL_FRAME_SCROLL_BAR_OFFSET_BOTTOM");
retain("Vector2DMixin");
retain("Vector3DMixin");
retain("SetCursor");
retain("ResetCursor");
retain("Vector2D_CalculateAngleBetween");
retain("Vector2D_Cross");
retain("Vector2D_Dot");

-- Require move
retain("tInvert");
retain("tContains");

-- Investigate loading these from the .tocs and adding preambles
retain("FrameUtil");
retain("EnumUtil");
retain("FlagsUtil");

--For auth challenge
take("C_AuthChallenge");
retain("IsShiftKeyDown");
retain("GetBindingFromClick");

--For character services
retain("C_SharedCharacterServices");
retain("C_CharacterServices");
retain("C_ClassTrial");

--For secure transfer
take("C_SecureTransfer");

--GlobalStrings
retain("BLIZZARD_STORE");
retain("ACCEPT");
retain("HTML_START");
retain("HTML_START_CENTERED");
retain("HTML_END");
take("BLIZZARD_STORE_ON_SALE");
take("BLIZZARD_STORE_PURCHASED");
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
take("BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE");
take("BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE_EUR");
take("BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE_KR");
take("BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES");
take("BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES_EUR");
take("BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES_KR");
take("BLIZZARD_STORE_CONFIRMATION_OTHER");
take("BLIZZARD_STORE_CONFIRMATION_OTHER_EUR");
take("BLIZZARD_STORE_BROWSE_TEST_CURRENCY");
take("BLIZZARD_STORE_BATTLE_NET_BALANCE");
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
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_KRW");
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
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_JPY");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_CAD");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_NZD");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_GEL");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_TRY");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_KZT");
take("BLIZZARD_STORE_LICENSE_ACK_TEXT_UAH");
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
take("BLIZZARD_STORE_ERROR_TITLE_CONSUMABLE_TOKEN_OWNED");
take("BLIZZARD_STORE_ERROR_TITLE_CLIENT_RESTRICTED");
take("BLIZZARD_STORE_ERROR_CLIENT_RESTRICTED");
take("BLIZZARD_STORE_ERROR_MESSAGE_CONSUMABLE_TOKEN_OWNED");
take("BLIZZARD_STORE_ERROR_ITEM_UNAVAILABLE");
take("BLIZZARD_STORE_ERROR_YOU_OWN_TOO_MANY_OF_THIS")
take("BLIZZARD_STORE_DISCOUNT_TEXT_FORMAT");
take("BLIZZARD_STORE_PAGE_NUMBER");
take("BLIZZARD_STORE_SPLASH_BANNER_DISCOUNT_FORMAT");
take("BLIZZARD_STORE_SPLASH_BANNER_FEATURED");
take("BLIZZARD_STORE_SPLASH_BANNER_NEW");
take("BLIZZARD_STORE_WALLET_INFO");
take("BLIZZARD_STORE_PURCHASE_SENT");
take("BLIZZARD_STORE_BEING_PROCESSED_CHECK_BACK_LATER");
take("BLIZZARD_STORE_YOU_ALREADY_OWN_THIS");
take("BLIZZARD_STORE_TOKEN_CURRENT_MARKET_PRICE");
take("BLIZZARD_STORE_TOKEN_DESC_30_DAYS");
take("BLIZZARD_STORE_LOG_OUT_TO_PURCHASE_THIS_PRODUCT");
take("BLIZZARD_STORE_PRODUCT_IS_READY");
take("BLIZZARD_STORE_CLICK_TO_OPEN_FAQ");
take("BLIZZARD_STORE_VAS_SERVICE_READY_DESCRIPTION");
take("BLIZZARD_STORE_NAME_CHANGE_READY_DESCRIPTION");
take("BLIZZARD_STORE_LEGION_PURCHASE_READY_DESCRIPTION");
take("BLIZZARD_STORE_LEGION_PURCHASE_READY");
take("CHARACTER_UPGRADE_LOG_OUT_NOW");
take("CHARACTER_UPGRADE_POPUP_LATER");
take("CHARACTER_UPGRADE_READY");
take("CHARACTER_UPGRADE_READY_DESCRIPTION");
take("FREE_CHARACTER_UPGRADE_READY");
take("FREE_CHARACTER_UPGRADE_READY_DESCRIPTION");
take("CHARACTER_UPGRADE_CLASS_TRIAL_UNLOCK_READY_DESCRIPTION");
take("VAS_SELECT_CHARACTER_DISABLED");
take("VAS_SELECT_CHARACTER");
take("VAS_CHARACTER_LABEL");
take("VAS_SELECT_REALM");
take("VAS_REALM_LABEL");
take("VAS_CHARACTER_SELECTION_DESCRIPTION");
take("VAS_SELECTED_CHARACTER_DESCRIPTION");
take("VAS_NEW_CHARACTER_NAME_LABEL");
take("VAS_NAME_CHANGE_TOOLTIP");
take("VAS_TRANSFER_REALM_TOOLTIP");
take("VAS_NEW_GUILD_NAME_LABEL");
take("VAS_GUILD_NAME_CHANGE_TOOLTIP");
take("VAS_GUILD_NAME_CHANGE_TRANSFER_TOOLTIP");
take("VAS_GUILD_FACTION_NAME_CHANGE_CHECKBOX_TOOLTIP");
take("VAS_NEW_GUILD_MASTER_FACTION_CHANGE_TOOLTIP");
take("VAS_NEW_GUILD_MASTER_TRANSFER_TOOLTIP");
take("VAS_OLD_GUILD_NEW_NAME_CHANGE_TOOLTIP");
take("VAS_NEW_GUILD_MASTER_LABEL");
take("VAS_NEW_GUILD_MASTER_EMPTY_TEXT");
take("VAS_OLD_GUILD_NEW_NAME_LABEL");
take("VAS_OLD_GUILD_NEW_NAME_EMPTY_TEXT");
take("VAS_DESTINATION_REALM_LABEL");
take("VAS_NAME_CHANGE_CONFIRMATION");
take("VAS_GUILD_FACTION_CHANGE_CONFIRMATION");
take("VAS_GUILD_FACTION_CHANGE_PLUS_NAME_CHANGE_CONFIRMATION");
take("VAS_GUILD_TRANSFER_CONFIRMATION");
take("VAS_GUILD_TRANSFER_PLUS_NAME_CHANGE_CONFIRMATION");
take("VAS_GUILD_TRANSFER_PLUS_FACTION_CHANGE_CONFIRMATION");
take("VAS_GUILD_TRANSFER_PLUS_NAME_AND_FACTION_CHANGE_CONFIRMATION");
take("VAS_APPEARANCE_CHANGE_CONFIRMATION");
take("VAS_FACTION_CHANGE_CONFIRMATION");
take("VAS_RACE_CHANGE_CONFIRMATION");
take("VAS_CHARACTER_TRANSFER_CONFIRMATION");
take("VAS_RACE_CHANGE_VALIDATION_DESCRIPTION");
take("VAS_FACTION_CHANGE_VALIDATION_DESCRIPTION");
take("VAS_APPEARANCE_CHANGE_VALIDATION_DESCRIPTION");
take("BLIZZARD_STORE_VAS_ERROR_REALM_NOT_ELIGIBLE");
take("BLIZZARD_STORE_VAS_ERROR_CANNOT_MOVE_GUILDMASTER");
take("BLIZZARD_STORE_VAS_ERROR_DUPLICATE_CHARACTER_NAME");
take("BLIZZARD_STORE_VAS_ERROR_HAS_MAIL");
take("BLIZZARD_STORE_VAS_ERROR_UNDER_MIN_LEVEL_REQ");
take("BLIZZARD_STORE_VAS_ERROR_TOO_MUCH_MONEY_FOR_LEVEL");
take("BLIZZARD_STORE_VAS_ERROR_HAS_AUCTIONS");
take("BLIZZARD_STORE_VAS_ERROR_NAME_NOT_AVAILABLE");
take("BLIZZARD_STORE_VAS_ERROR_LAST_RENAME_TOO_RECENT");
take("BLIZZARD_STORE_VAS_ERROR_CUSTOMIZE_ALREADY_REQUESTED");
take("BLIZZARD_STORE_VAS_ERROR_LAST_CUSTOMIZE_TOO_SOON");
take("BLIZZARD_STORE_VAS_ERROR_FACTION_CHANGE_TOO_SOON");
take("BLIZZARD_STORE_VAS_ERROR_RACE_CLASS_COMBO_INELIGIBLE");
take("BLIZZARD_STORE_VAS_ERROR_INELIGIBLE_MAP_ID");
take("BLIZZARD_STORE_VAS_ERROR_BATTLEPAY_DELIVERY_PENDING");
take("BLIZZARD_STORE_VAS_ERROR_HAS_WOW_TOKEN");
take("BLIZZARD_STORE_VAS_ERROR_HAS_HEIRLOOM");
take("BLIZZARD_STORE_VAS_ERROR_CHARACTER_LOCKED");
take("BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_RECENT");
take("BLIZZARD_STORE_VAS_ERROR_CHARACTER_HAS_VAS_PENDING");
take("BLIZZARD_STORE_VAS_ERROR_INVALID_DESTINATION_ACCOUNT");
take("BLIZZARD_STORE_VAS_ERROR_INVALID_SOURCE_ACCOUNT");
take("BLIZZARD_STORE_VAS_ERROR_DISALLOWED_SOURCE_ACCOUNT");
take("BLIZZARD_STORE_VAS_ERROR_DISALLOWED_DESTINATION_ACCOUNT");
take("BLIZZARD_STORE_VAS_ERROR_LOWER_BOX_LEVEL");
take("BLIZZARD_STORE_VAS_ERROR_MAX_CHARACTERS_ON_SERVER");
take("BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_DISTANT");
take("BLIZZARD_STORE_VAS_ERROR_BOOSTED_TOO_RECENTLY");
take("BLIZZARD_STORE_VAS_ERROR_NOT_GUILD_MASTER");
take("BLIZZARD_STORE_VAS_ERROR_NOT_IN_GUILD");
take("BLIZZARD_STORE_VAS_ERROR_NEW_LEADER_INVALID");
take("BLIZZARD_STORE_VAS_ERROR_AUTHENTICATOR_INSUFFICIENT");
take("BLIZZARD_STORE_VAS_ERROR_ALREADY_RENAME_FLAGGED");
take("BLIZZARD_STORE_VAS_ERROR_GM_SENORITY_INSUFFICIENT");
take("BLIZZARD_STORE_VAS_ERROR_OPERATION_ALREADY_IN_PROGRESS");
take("BLIZZARD_STORE_VAS_ERROR_LOCKED_FOR_VAS");
take("BLIZZARD_STORE_VAS_ERROR_MOVE_IN_PROGRESS");
take("BLIZZARD_STORE_VAS_ERROR_HAS_CRAFTING_ORDERS");
take("BLIZZARD_STORE_VAS_ERROR_OTHER");
take("BLIZZARD_STORE_VAS_ERROR_LABEL");
take("BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE");
take("BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE");
take("BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE");
take("BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE");
take("BLIZZARD_STORE_DISCLAIMER_FACTION_CHANGE_CN");
take("BLIZZARD_STORE_DISCLAIMER_RACE_CHANGE_CN");
take("BLIZZARD_STORE_DISCLAIMER_APPEARANCE_CHANGE_CN");
take("BLIZZARD_STORE_DISCLAIMER_NAME_CHANGE_CN");
take("BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER");
take("BLIZZARD_STORE_DISCLAIMER_CHARACTER_TRANSFER_CN");
take("BLIZZARD_STORE_DISCLAIMER_GUILD_NAME_CHANGE");
take("BLIZZARD_STORE_DISCLAIMER_GUILD_FACTION_CHANGE");
take("BLIZZARD_STORE_BOOST_UNREVOKED_CONSUMPTION");
take("BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100");
take("BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100_CN");
take("BLIZZARD_STORE_DISCLAIMER_GUILD_TRANSFER");
take("STORE_CATEGORY_TRIAL_DISABLED_TOOLTIP");
take("STORE_CATEGORY_VETERAN_DISABLED_TOOLTIP");
take("BLIZZARD_STORE_BUNDLE_DISCOUNT_BANNER");
take("BLIZZARD_STORE_BUNDLE_DISCOUNT_TOOLTIP_ADDENDUM");
take("BLIZZARD_STORE_BUNDLE_DISCOUNT_TOOLTIP_REPLACEMENT");
take("BLIZZARD_STORE_BUNDLE_TOOLTIP_HEADER");
take("BLIZZARD_STORE_BUNDLE_TOOLTIP_OWNED_DELIVERABLE");
take("BLIZZARD_STORE_BUNDLE_TOOLTIP_UNOWNED_DELIVERABLE");
retain("TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT");
retain("TOOLTIP_UPDATE_TIME");
retain("PVP_BOUNTY_REWARD_TITLE");
retain("QUEST_REWARDS");
retain("ISLAND_QUEUE_REWARD_FOR_WINNING");
retain("CONTRIBUTION_REWARD_TOOLTIP_TEXT");


-- For Battle.net Token
take("C_WowTokenSecure");
retain("C_WowTokenPublic");
take("TOKEN_REDEEM_LABEL");
take("TOKEN_REDEEM_GAME_TIME_TITLE");
take("TOKEN_REDEEM_GAME_TIME_DESCRIPTION");
take("TOKEN_REDEEM_GAME_TIME_EXPIRATION_FORMAT");
take("TOKEN_REDEEM_GAME_TIME_RENEWAL_FORMAT");
take("TOKEN_REDEEM_GAME_TIME_BUTTON_LABEL");
take("TOKEN_CONFIRMATION_TITLE");
take("TOKEN_COMPLETE_TITLE");
take("TOKEN_CREATE_AUCTION_TITLE");
take("TOKEN_BUYOUT_AUCTION_TITLE");
take("TOKEN_CONFIRM_CREATE_AUCTION");
take("TOKEN_CONFIRM_CREATE_AUCTION_LINE_2");
take("TOKEN_CONFIRM_GAME_TIME_DESCRIPTION");
take("TOKEN_CONFIRM_GAME_TIME_DESCRIPTION_MINUTES");
take("TOKEN_CONFIRM_GAME_TIME_EXPIRATION_CONFIRMATION_DESCRIPTION");
take("TOKEN_CONFIRM_GAME_TIME_RENEWAL_CONFIRMATION_DESCRIPTION");
take("TOKEN_COMPLETE_GAME_TIME_DESCRIPTION");
take("TOKEN_BUYOUT_AUCTION_CONFIRMATION_DESCRIPTION");
take("TOKEN_PRICE_LOCK_EXPIRE");
take("TOKEN_CURRENT_AUCTION_VALUE");
take("TOKEN_REDEEM_GAME_TIME_EXPIRATION_FORMAT_MINUTES");
take("TOKEN_COMPLETE_GAME_TIME_DESCRIPTION_MINUTES");
take("TOKEN_REDEEM_GAME_TIME_BUTTON_LABEL_MINUTES");
take("TOKEN_REDEEM_GAME_TIME_DESCRIPTION_MINUTES");
take("TOKEN_TRANSACTION_IN_PROGRESS");
take("TOKEN_YOU_WILL_BE_LOGGED_OUT");
take("TOKEN_REDEMPTION_UNAVAILABLE");
take("TOKEN_COMPLETE_BALANCE_DESCRIPTION")
take("TOKEN_CONFIRM_BALANCE_DESCRIPTION")
take("TOKEN_REDEEM_BALANCE_BUTTON_LABEL")
take("TOKEN_REDEEM_BALANCE_DESCRIPTION")
take("TOKEN_REDEEM_BALANCE_CONFIRMATION_DESCRIPTION")
take("TOKEN_REDEEM_BALANCE_ERROR_CAP_FORMAT")
take("TOKEN_REDEEM_BALANCE_FORMAT")
take("TOKEN_REDEEM_BALANCE_TITLE")
retain("TOKEN_MARKET_PRICE_NOT_AVAILABLE");

retain("GOLD_AMOUNT_SYMBOL");
retain("GOLD_AMOUNT_TEXTURE");
retain("GOLD_AMOUNT_TEXTURE_STRING");
retain("SILVER_AMOUNT_SYMBOL");
retain("SILVER_AMOUNT_TEXTURE");
retain("SILVER_AMOUNT_TEXTURE_STRING");
retain("COPPER_AMOUNT_SYMBOL");
retain("COPPER_AMOUNT_TEXTURE");
retain("COPPER_AMOUNT_TEXTURE_STRING");
retain("SHORTDATE");
retain("SHORTDATE_EU");
retain("AUCTION_TIME_LEFT1_DETAIL");
retain("AUCTION_TIME_LEFT2_DETAIL");
retain("AUCTION_TIME_LEFT3_DETAIL");
retain("AUCTION_TIME_LEFT4_DETAIL");
retain("WEEKS_ABBR");
retain("DAYS_ABBR");
retain("HOURS_ABBR");
retain("MINUTES_ABBR");
retain("OKAY");
retain("LARGE_NUMBER_SEPERATOR");
retain("DECIMAL_SEPERATOR");
retain("TOOLTIP_DEFAULT_COLOR");
retain("CANCEL");
retain("CREATE_AUCTION");
retain("CONTINUE");
retain("OPTIONS");
retain("FACTION_HORDE");
retain("FACTION_ALLIANCE");
retain("LIST_DELIMITER");
retain("FEATURE_NOT_AVAILBLE_PANDAREN");
retain("BLIZZARD_STORE_PROCESSING");

take("BLIZZARD_CHALLENGE_SUBMIT");
take("BLIZZARD_CHALLENGE_CANCEL");
take("BLIZZARD_CHALLENGE_CONNECTING");
take("BLIZZARD_CHALLENGE_OKAY");
take("BLIZZARD_CHALLENGE_DENIED_TITLE");
take("BLIZZARD_CHALLENGE_DENIED_DESCRIPTION");
take("BLIZZARD_CHALLENGE_ERROR_TITLE");
take("BLIZZARD_CHALLENGE_ERROR_DESCRIPTION");
take("BLIZZARD_CHALLENGE_SCREEN_EXPLANATION");

take("SEND_ITEMS_TO_STRANGER_WARNING");
take("SEND_MONEY_TO_STRANGER_WARNING");
take("TRADE_ACCEPT_CONFIRMATION");

retain("COMMUNITIES_CREATE_COMMUNITY");
retain("COMMUNITIES_CREATE_GROUP");
retain("COMMUNITIES_ADD_DIALOG_CREATE_WOW_LABEL");
retain("COMMUNITIES_ADD_DIALOG_CREATE_WOW_LABEL_NO_FACTION");
retain("COMMUNITIES_ADD_DIALOG_CREATE_WOW_DESCRIPTION");
retain("COMMUNITIES_ADD_DIALOG_CREATE_WOW_DESCRIPTION_NO_FACTION");
retain("COMMUNITIES_ADD_DIALOG_CREATE_BNET_LABEL");
retain("COMMUNITIES_ADD_DIALOG_CREATE_BNET_DESCRIPTION");
retain("COMMUNITIES_ADD_DIALOG_INVITE_LINK_LABEL");
retain("COMMUNITIES_ADD_DIALOG_INVITE_LINK_DESCRIPTION");
retain("COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN");
retain("COMMUNITIES_ADD_DIALOG_BATTLE_NET_LABEL");
retain("COMMUNITIES_ADD_DIALOG_WOW_LABEL");
retain("COMMUNITIES_ADD_DIALOG_LABEL");
retain("COMMUNITIES_CREATE_DIALOG_WOW_LABEL");
retain("COMMUNITIES_CREATE_DIALOG_BATTLE_NET_LABEL");
retain("COMMUNITIES_CREATE_DIALOG_ICON_SELECTION_BUTTON");
retain("COMMUNITIES_CREATE_DIALOG_AVATAR_PICKER_INSTRUCTIONS");
retain("COMMUNITIES_CREATE_DIALOG_NAME_INSTRUCTIONS");
retain("COMMUNITIES_CREATE_DIALOG_NAME_INSTRUCTIONS_BATTLE_NET");
retain("COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS");
retain("COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS_BATTLE_NET");
retain("COMMUNITIES_CREATE_DIALOG_TYPE_LABEL");
retain("COMMUNITIES_SETTINGS_NAME_LABEL");
retain("COMMUNITIES_CREATE_DIALOG_NAME_LABEL");
retain("COMMUNITIES_CREATE_DIALOG_NAME_LABEL_BATTLE_NET");
retain("COMMUNITIES_CREATE_DIALOG_DESCRIPTION_LABEL");
retain("COMMUNITIES_CREATE_DIALOG_DESCRIPTION_LABEL_BATTLE_NET");
retain("COMMUNITIES_CREATE_DIALOG_ICON_LABEL");
retain("COMMUNITIES_CREATE_DIALOG_SHORT_NAME_LABEL");
retain("COMMUNITIES_CREATE_DIALOG_SHORT_NAME_INSTRUCTIONS");
retain("COMMUNITIES_CREATE_DIALOG_SHORT_NAME_INSTRUCTIONS_TOOLTIP");
retain("COMMUNITIES_CREATE_DIALOG_SHORT_NAME_INSTRUCTIONS_CHARACTER");
retain("COMMUNITIES_CREATE_DIALOG_NAME_AND_SHORT_NAME_ERROR");
retain("COMMUNITIES_CREATE_DIALOG_NAME_ERROR");
retain("COMMUNITIES_CREATE_DIALOG_SHORT_NAME_ERROR");
retain("COMMUNITY_TYPE_UNAVAILABLE");
retain("CLUB_FINDER_DISABLE_REASON_VETERAN_TRIAL");

--Lua enums
retain("LE_TOKEN_RESULT_SUCCESS");
retain("LE_TOKEN_RESULT_ERROR_OTHER");
retain("LE_TOKEN_RESULT_ERROR_DISABLED");
take("LE_TOKEN_RESULT_ERROR_BALANCE_NEAR_CAP");
take("LE_TOKEN_REDEEM_TYPE_GAME_TIME");
take("LE_TOKEN_REDEEM_TYPE_BALANCE");

--Tag enums
takeenum("StoreError");
takeenum("VasError");
takeenum("BattlepayBoostProduct");
takeenum("BattlepayDisplayFlag");
takeenum("PurchaseEligibility");
takeenum("BattlepayProductDecorator");
takeenum("VasServiceType");
takeenum("VasPurchaseState");
takeenum("BattlepayProductGroupFlag");
takeenum("BattlepayGroupDisplayType");
takeenum("BattlepayCardType");
takeenum("BattlepayBannerType");
retainenum("ModelSceneSetting");
retainenum("ClubType");
retainenum("ClubFieldType");
retainenum("ValidateNameResult");
retainenum("TooltipDataLineType");
retainenum("TooltipDataType");
retainenum("ModelBlendOperation");
retainenum("GameEnvironment");

-- For Private Auras
retainfromtable("AuraUtil", "DefaultAuraCompare");
retainfromtable("C_ChatInfo", "GetColorForChatType");
retain("SMALLER_AURA_DURATION_FONT_MIN_THRESHOLD");
retain("SMALLER_AURA_DURATION_FONT_MAX_THRESHOLD");
retain("SMALLER_AURA_DURATION_FONT");
retain("SMALLER_AURA_DURATION_OFFSET_Y");
retain("DEFAULT_AURA_DURATION_FONT");
retain("DebuffTypeColor");
retain("DebuffTypeSymbol");
retain("BUFF_DURATION_WARNING_TIME");
retain("C_FunctionContainers");
retain("C_UnitAuras");
take("C_UnitAurasPrivate");
removefromtable("C_TooltipInfo", "GetUnitPrivateAura");

-- For Ping System
retain("C_Ping");
take("C_PingSecure");
retain("PING_TYPE_ASSIST");
retain("PING_TYPE_ATTACK");
retain("PING_TYPE_ON_MY_WAY");
retain("PING_TYPE_WARNING");
retain("PING_FAILED_SPAMMING");
retain("PING_FAILED_GENERIC");
retain("PING_FAILED_DISABLED_BY_LEADER");
retain("PING_FAILED_DISABLED_BY_SETTINGS");
retain("PING_FAILED_OUT_OF_PING_AREA");
retain("PING_FAILED_SQUELCHED");
retain("PING_FAILED_UNSPECIFIED");
retainenum("PingSubjectType");
retainenum("PingResult");
retainenum("PingMode");
retain("PingUtil");

-- Secure Mixins
-- where ... are the mixins to mixin
function SecureMixin(object, ...)
	if ( not issecure() ) then
		return;
	end

	for i = 1, select("#", ...) do
		local mixin = select(i, ...);
		for k, v in pairs(mixin) do
			object[k] = v;
		end
	end

	return object;
end

-- This is Private because we need a pristine copy to reference in CreateFromSecureMixins.
local SecureMixinPrivate = SecureMixin;

-- where ... are the mixins to mixin
function CreateFromSecureMixins(...)
	if ( not issecure() ) then
		return;
	end

	return SecureMixinPrivate({}, ...)
end

take("SecureMixin");
take("CreateFromSecureMixins");
take("CreateSecureMixinCopy");

retain("GetFinalNameFromTextureKit")
retain("C_Texture");

retain("C_RecruitAFriend");

-- retain shared constants
retain("WOW_GAMES_CATEGORY_ID");
retain("WOW_GAME_TIME_CATEGORY_ID");
retain("WOW_SUBSCRIPTION_CATEGORY_ID");

remove("loadstring_untainted");
