
------------------------------------------------------------------------------------------------------------------------------------------------------
-- This section is based on code from MoneyFrame.lua to keep it in the secure environment, if you change it there you should probably change it here as well.
-- NOTE: Avoiding refactor for 9.1.5, will fix in a future patch.
------------------------------------------------------------------------------------------------------------------------------------------------------
local COPPER_PER_SILVER = 100;
local SILVER_PER_GOLD = 100;
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD;

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

local function GetSecureMoneyString(money, separateThousands)
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

local vasErrorData = {
	[Enum.VasTransactionPurchaseResult.OnlyOneVasAtATime] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CHARACTER_HAS_VAS_PENDING,
		notUserFixable = true,
	},
	[Enum.VasTransactionPurchaseResult.InvalidDestinationAccount] = {
		msg = BLIZZARD_STORE_VAS_ERROR_INVALID_DESTINATION_ACCOUNT,
	},
	[Enum.VasTransactionPurchaseResult.InvalidSourceAccount] = {
		msg = BLIZZARD_STORE_VAS_ERROR_INVALID_SOURCE_ACCOUNT,
	},
	[Enum.VasTransactionPurchaseResult.DisallowedSourceAccount] = {
		msg = BLIZZARD_STORE_VAS_ERROR_DISALLOWED_SOURCE_ACCOUNT,
	},
	[Enum.VasTransactionPurchaseResult.DisallowedDestinationAccount] = {
		msg = BLIZZARD_STORE_VAS_ERROR_DISALLOWED_DESTINATION_ACCOUNT,
	},
	[Enum.VasTransactionPurchaseResult.LowerBoxLevel] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LOWER_BOX_LEVEL,
	},
	[Enum.VasTransactionPurchaseResult.ProxyBadRequestContained] = {
		msg = BLIZZARD_STORE_VAS_ERROR_OPERATION_ALREADY_IN_PROGRESS,
	},
	[Enum.VasTransactionPurchaseResult.ProxyCharacterTransferredNoBoostInProgress] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LOCKED_FOR_VAS,
	},
	[Enum.VasTransactionPurchaseResult.DbRealmNotEligible] = {
		msg = BLIZZARD_STORE_VAS_ERROR_REALM_NOT_ELIGIBLE,
	},
	[Enum.VasTransactionPurchaseResult.DbCannotMoveGuildmaster] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CANNOT_MOVE_GUILDMASTER,
	},
	[Enum.VasTransactionPurchaseResult.DbMaxCharactersOnServer] = {
		msg = BLIZZARD_STORE_VAS_ERROR_MAX_CHARACTERS_ON_SERVER,
	},
	[Enum.VasTransactionPurchaseResult.DbDuplicateCharacterName] = {
		msg = BLIZZARD_STORE_VAS_ERROR_DUPLICATE_CHARACTER_NAME,
	},
	[Enum.VasTransactionPurchaseResult.DbHasMail] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_MAIL,
	},
	[Enum.VasTransactionPurchaseResult.DbMoveInProgress] = {
		msg = BLIZZARD_STORE_VAS_ERROR_MOVE_IN_PROGRESS,
	},
	[Enum.VasTransactionPurchaseResult.DbUnderMinLevelReq] = {
		msg = BLIZZARD_STORE_VAS_ERROR_UNDER_MIN_LEVEL_REQ,
	},
	[Enum.VasTransactionPurchaseResult.DbTransferDateTooSoon] = {
		msg = BLIZZARD_STORE_VAS_ERROR_FACTION_CHANGE_TOO_SOON,
	},
	[Enum.VasTransactionPurchaseResult.DbCharLocked] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CHARACTER_LOCKED,
		notUserFixable = true,
	},
	[Enum.VasTransactionPurchaseResult.DbTooMuchMoneyForLevel] = {
		msg = function(character)
			-- If you update these gold thresholds, be sure to also update:
			--   - TRANSFER_GOLD_LIMIT_BASE and related
			--   - The DB script / configs - Ask a DBE to help you
			local level = character and character.level or 1;
			local str = "";
			if level >= 50 then
				-- level 50+: one million gold
				str = GetSecureMoneyString(1000000 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			elseif level >= 40 then
				-- level 10-49: two hundred fifty thousand gold
				str = GetSecureMoneyString(250000 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			elseif level >= 10 then
				-- level 10-49: ten thousand gold
				str = GetSecureMoneyString(10000 * COPPER_PER_SILVER * SILVER_PER_GOLD, true, true);
			end
			return string.format(BLIZZARD_STORE_VAS_ERROR_TOO_MUCH_MONEY_FOR_LEVEL, str);
		end
	},
	[Enum.VasTransactionPurchaseResult.DbHasAuctions] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_AUCTIONS,
	},
	[Enum.VasTransactionPurchaseResult.DbLastSaveTooRecent] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_RECENT,
		notUserFixable = true,
	},
	[Enum.VasTransactionPurchaseResult.DbNameNotAvailable] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NAME_NOT_AVAILABLE,
	},
	[Enum.VasTransactionPurchaseResult.DbLastRenameTooRecent] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_RENAME_TOO_RECENT,
	},
	[Enum.VasTransactionPurchaseResult.DbAlreadyRenameFlagged] = {
		msg = BLIZZARD_STORE_VAS_ERROR_ALREADY_RENAME_FLAGGED,
	},
	[Enum.VasTransactionPurchaseResult.DbCustomizeAlreadyRequested] = {
		msg = BLIZZARD_STORE_VAS_ERROR_CUSTOMIZE_ALREADY_REQUESTED,
	},
	[Enum.VasTransactionPurchaseResult.DbLastCustomizeTooSoon] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_CUSTOMIZE_TOO_SOON,
	},
	[Enum.VasTransactionPurchaseResult.DbFactionChangeTooSoon] = {
		msg = BLIZZARD_STORE_VAS_ERROR_FACTION_CHANGE_TOO_SOON,
	},
	[Enum.VasTransactionPurchaseResult.DbRaceClassComboIneligible] = { --We should still handle this one even though we shortcut it in case something slips through
		msg = BLIZZARD_STORE_VAS_ERROR_RACE_CLASS_COMBO_INELIGIBLE,
	},
	[Enum.VasTransactionPurchaseResult.DbGuildRankInsufficient] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NOT_GUILD_MASTER,
	},
	[Enum.VasTransactionPurchaseResult.DbCharacterWithoutGuild] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NOT_IN_GUILD,
	},
	[Enum.VasTransactionPurchaseResult.DbGmSenorityInsufficient] = {
		msg = BLIZZARD_STORE_VAS_ERROR_GM_SENORITY_INSUFFICIENT,
	},
	[Enum.VasTransactionPurchaseResult.DbAuthenticatorInsufficient] = {
		msg = BLIZZARD_STORE_VAS_ERROR_AUTHENTICATOR_INSUFFICIENT,
	},
	[Enum.VasTransactionPurchaseResult.DbIneligibleMapID] = {
		msg = BLIZZARD_STORE_VAS_ERROR_INELIGIBLE_MAP_ID,
	},
	[Enum.VasTransactionPurchaseResult.DbBpayDeliveryPending] = {
		msg = BLIZZARD_STORE_VAS_ERROR_BATTLEPAY_DELIVERY_PENDING,
	},
	[Enum.VasTransactionPurchaseResult.DbHasBpayToken] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_WOW_TOKEN,
	},
	[Enum.VasTransactionPurchaseResult.DbHasHeirloomItem] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_HEIRLOOM,
	},
	[Enum.VasTransactionPurchaseResult.DbResultAccountRestricted] = {
		msg = function(character)
			if character and character.guid and IsCharacterNPERestricted(character.guid) then
				return BLIZZARD_STORE_VAS_ERROR_NEW_PLAYER_EXPERIENCE;
			end

			return BLIZZARD_STORE_VAS_ERROR_OTHER;
		end,
	},
	[Enum.VasTransactionPurchaseResult.DbLastSaveTooDistant] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_DISTANT,
	},
	[Enum.VasTransactionPurchaseResult.DbCagedPetInInventory] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_CAGED_BATTLE_PET,
	},
	[Enum.VasTransactionPurchaseResult.DbOnBoostCooldown] = {
		msg = BLIZZARD_STORE_VAS_ERROR_BOOSTED_TOO_RECENTLY,
		notUserFixable = true,
	},
	[Enum.VasTransactionPurchaseResult.DbNewLeaderInvalid] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NEW_LEADER_INVALID,
	},
	[Enum.VasTransactionPurchaseResult.DbNeedsLevelSquish] = {
		msg = BLIZZARD_STORE_VAS_ERROR_LAST_SAVE_TOO_DISTANT,
	},
	[Enum.VasTransactionPurchaseResult.DbHasNewPlayerExperienceRestriction] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NEW_PLAYER_EXPERIENCE,
	},
	[Enum.VasTransactionPurchaseResult.DbHasCraftingOrders] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_CRAFTING_ORDERS,
	},
	[Enum.VasTransactionPurchaseResult.DbInvalidName] = {
		msg = BLIZZARD_STORE_VAS_INVALID_NAME,
	},
};

local storeErrorData = {
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

ErrorLookupInterface = {};

function ErrorLookupInterface.HasError(errorCode)
	return vasErrorData[errorCode] ~= nil;
end

function ErrorLookupInterface.IsUserFixableError(errorCode)
	local error = vasErrorData[errorCode];
	if error then
		return not error.notUserFixable;
	end

	return false; -- Not sure if an error we don't know about can be fixed, so it can't be.
end

function ErrorLookupInterface.GetMessage(errorCode, character)
	local errorData = vasErrorData[errorCode];
	if errorData then
		if type(errorData.msg) == "function" then
			return errorData.msg(character);
		end

		return errorData.msg;
	end

	return "";
end

function ErrorLookupInterface.GetCombinedMessage(characterGUID)
	local errors = C_StoreSecure.GetVASErrors();

	local msgTable = {};

	local character = C_StoreSecure.GetCharacterInfoByGUID(characterGUID);
	for index, errorID in ipairs(errors) do
		local error = VASErrorData_GetMessage(errorID, character);
		table.insert(msgTable, error);
	end

	local displayMsg = table.concat(msgTable, "\n");
	displayMsg = (displayMsg ~= "") and displayMsg or BLIZZARD_STORE_VAS_ERROR_OTHER;

	return displayMsg;
end

function ErrorLookupInterface.GetErrorMessage(errorCode)
	local info = storeErrorData[errorCode];
	if not info then
		info = storeErrorData[Enum.StoreError.Other];
	end

	return info.title, info.msg, info.link;
end
