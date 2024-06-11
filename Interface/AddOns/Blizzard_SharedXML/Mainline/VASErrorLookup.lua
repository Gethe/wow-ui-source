
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
			-- If you update these gold thresholds, be sure to also update:
			--   - UserAuth.cpp - TRANSFER_GOLD_LIMIT_BASE and related
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
	[Enum.VasError.AccountRestricted] = {
		msg = function(character)
			if character and character.guid and IsCharacterNPERestricted(character.guid) then
				return BLIZZARD_STORE_VAS_ERROR_NEW_PLAYER_EXPERIENCE;
			end

			return BLIZZARD_STORE_VAS_ERROR_OTHER;
		end,
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
	[Enum.VasError.IsNpeRestricted] = {
		msg = BLIZZARD_STORE_VAS_ERROR_NEW_PLAYER_EXPERIENCE,
	},
	[Enum.VasError.HasCraftingOrders] = {
		msg = BLIZZARD_STORE_VAS_ERROR_HAS_CRAFTING_ORDERS,
	},
	[Enum.VasError.InvalidName] = {
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

function VASErrorData_HasError(errorCode)
	return vasErrorData[errorCode] ~= nil;
end

function VASErrorData_IsUserFixableError(errorCode)
	local error = vasErrorData[errorCode];
	if error then
		return not error.notUserFixable;
	end

	return false; -- Not sure if an error we don't know about can be fixed, so it can't be.
end

function VASErrorData_GetMessage(errorCode, character)
	local errorData = vasErrorData[errorCode];
	if errorData then
		if type(errorData.msg) == "function" then
			return errorData.msg(character);
		end

		return errorData.msg;
	end

	return "";
end

function VASErrorData_GetCombinedMessage(characterGUID)
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

function StoreErrorData_GetMessage(errorCode)
	local info = storeErrorData[errorCode];
	if not info then
		info = storeErrorData[Enum.StoreError.Other];
	end

	return info.title, info.msg, info.link;
end