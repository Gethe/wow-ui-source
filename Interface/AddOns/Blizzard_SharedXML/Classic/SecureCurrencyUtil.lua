
--Data
local REGION_US = 1;
local REGION_KR = 2;
local REGION_EU = 3;
local REGION_TW = 4;
local REGION_CN = 5;
local REGION_BETA = 98;
local FormatCurrencyStringShort = nil;
local FormatCurrencyStringLong = nil;

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

local function currencyFormatShort(dollars, cents)
	return string.format(FormatCurrencyStringShort, formatCurrency(dollars, cents, false));
end

local function currencyFormatLong(dollars, cents)
	return string.format(FormatCurrencyStringLong, formatCurrency(dollars, cents, false));
end

local function currencyFormatRawStar(dollars, cents)
	return string.format(BLIZZARD_STORE_CURRENCY_RAW_ASTERISK, formatCurrency(dollars, cents, false));
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
	[REGION_US] = {
		formatShort = currencyFormatShort,
		formatLong = currencyFormatLong,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_USD,
		browseHasStar = true,
		browseNotice = BLIZZARD_STORE_PLUS_TAX,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
		paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
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
	[REGION_EU] = {
		formatShort = currencyFormatShort,
		formatLong = currencyFormatLong,
		browseNotice = BLIZZARD_STORE_BROWSE_EUR,
        confirmationNotice = BLIZZARD_STORE_CONFIRMATION_EUR,
        servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_EUR,
        vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE_EUR,
        vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES_EUR,
        expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER_EUR,
        licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_GBP,
        paymentMethodText = BLIZZARD_STORE_PAYMENT_METHOD,
        paymentMethodSubtext = BLIZZARD_STORE_PAYMENT_METHOD_EXTRA,
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
	[REGION_KR] = {
		formatShort = currencyFormatShort,
		formatLong = currencyFormatLong,
		browseNotice = BLIZZARD_STORE_BROWSE_BATTLE_COINS_KR,
        confirmationNotice = BLIZZARD_STORE_SECOND_CHANCE_KR,
        servicesConfirmationNotice = BLIZZARD_STORE_SECOND_CHANCE_KR,
        vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE_KR,
        vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES_KR,
        expansionConfirmationNotice = BLIZZARD_STORE_SECOND_CHANCE_KR,
        browseWarning = BLIZZARD_STORE_SECOND_CHANCE_KR,
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
	[REGION_TW] = {
		formatShort = currencyFormatShort,
		formatLong = currencyFormatLong,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
        servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
        vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
        vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
        expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
        licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_TW,
        paymentMethodText = "",
        paymentMethodSubtext = "",
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
	[REGION_CN] = {
		formatShort = currencyFormatRawStar,
		formatLong = currencyFormatLong,
		browseNotice = BLIZZARD_STORE_BROWSE_BATTLE_COINS_CN,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_GENERIC,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_NAME_CHANGE,
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_VAS_GUILD_SERVICES,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_OTHER,
		licenseAcceptText = BLIZZARD_STORE_LICENSE_ACK_TEXT_CN,
		paymentMethodText = "",
		paymentMethodSubtext = "",
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
	[REGION_BETA] = {
		formatShort = currencyFormatShort,
		formatLong = currencyFormatLong,
		browseNotice = BLIZZARD_STORE_BROWSE_TEST_CURRENCY,
		confirmationNotice = BLIZZARD_STORE_CONFIRMATION_TEST,
		servicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_TEST,
		vasNameChangeConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_TEST,
		vasGuildServicesConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_SERVICES_TEST,
		expansionConfirmationNotice = BLIZZARD_STORE_CONFIRMATION_TEST,
		paymentMethodText = BLIZZARD_STORE_CONFIRMATION_TEST,
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
	}
};


SecureCurrencyUtil = {};

function SecureCurrencyUtil.GetActiveCurrencyInfo()
	local currencyInfo = C_StoreSecure.GetCurrencyInfo();
	local info = {};
	if currencyInfo then
		local currencyRegion = currencyInfo.sharedData.regionID;
		FormatCurrencyStringShort = currencyInfo.sharedData.formatShort;
		FormatCurrencyStringLong = currencyInfo.sharedData.formatLong;
		info = currencySpecific[currencyRegion];
		if currencyInfo.sharedData.licenseAcceptText ~= "" then
			info.licenseAcceptText = currencyInfo.sharedData.licenseAcceptText;
		end;
		info.requireLicenseAccept = currencyInfo.sharedData.requireLicenseAccept;
		info.browseHasStar = currencyInfo.sharedData.browseHasStar;
		info.hideBrowseNotice = currencyInfo.sharedData.hideBrowseNotice;
		if info.hideBrowseNotice then
			info.browseNotice = ""
		end
		info.hideConfirmationBrowseNotice = currencyInfo.sharedData.hideConfirmationBrowseNotice;
	end
	
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
