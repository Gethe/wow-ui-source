
---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
local _, tbl = ...;

if tbl then
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

	Import("C_StoreSecure");
	Import("Enum");
	Import("math");
	Import("string");
	Import("tostring");

	Import("BLIZZARD_STORE_BROWSE_BATTLE_COINS_KR");
	Import("BLIZZARD_STORE_BROWSE_BATTLE_COINS_CN");

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
	Import("BLIZZARD_STORE_CONFIRMATION_GENERIC");

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
	Import("BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100");
	Import("BLIZZARD_STORE_DISCLAIMER_BOOST_TOKEN_100_CN");

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

	Import("BLIZZARD_STORE_PLUS_TAX");
	Import("BLIZZARD_STORE_PAYMENT_METHOD");
	Import("BLIZZARD_STORE_PAYMENT_METHOD_EXTRA");

	Import("BLIZZARD_STORE_SECOND_CHANCE_KR");

	Import("DECIMAL_SEPERATOR");
	Import("LARGE_NUMBER_SEPERATOR");
end
----------------

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

local currencyMult = 100;

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
	[CURRENCY_JPY] = {
		formatShort = currencyFormatJPY,
		formatLong = currencyFormatJPY,
		browseNotice = "",
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
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
		},
	},
	[CURRENCY_CAD] = {
		formatShort = currencyFormatCAD,
		formatLong = currencyFormatCAD,
		browseNotice = "",
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
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
		},
	},
	[CURRENCY_NZD] = {
		formatShort = currencyFormatNZD,
		formatLong = currencyFormatNZD,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
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
		},
	},
};


SecureCurrencyUtil = {};

function SecureCurrencyUtil.GetActiveCurrencyInfo()
	local currency = C_StoreSecure.GetCurrencyID();
	local info = currencySpecific[currency];
	return info;
end

function SecureCurrencyUtil.GetFormattedPrice(storeProductID)
	local entryInfo = C_StoreSecure.GetProductInfo(storeProductID);
	if entryInfo == nil then
		return nil;
	end

	local currencyInfo = SecureCurrencyUtil.GetActiveCurrencyInfo();
	if currencyInfo == nil then
		return nil;
	end
	
	return currencyInfo.formatLong(entryInfo.sharedData.currentDollars, entryInfo.sharedData.currentCents);
end

SecureCurrencyUtil.FormatLargeNumber = formatLargeNumber;
