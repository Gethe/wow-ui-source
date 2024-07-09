function LocalizeNumberAbbreviation_Asian()
	AbbreviateLargeNumbers = function(value)
		local strLen = strlen(value);
		local retString = value;
		if ( strLen >= 11 ) then
			retString = string.sub(value, 1, -8)..SECOND_NUMBER_CAP;
		elseif ( strLen >= 9 ) then
			retString = string.sub(value, 1, -9).."."..string.sub(value, -8, -7)..SECOND_NUMBER_CAP;
		elseif ( strLen >= 7 ) then
			retString = string.sub(value, 1, -5)..FIRST_NUMBER_CAP;
		elseif (strLen > 3 ) then
			retString = BreakUpLargeNumbers(value);
		end
		return retString;
	end

	NUMBER_ABBREVIATION_DATA = {
		-- Order these from largest to smallest
		{ breakpoint = 1000000000,	abbreviation = SECOND_NUMBER_CAP_NO_SPACE,	significandDivisor = 10000000,	fractionDivisor = 1 },
		{ breakpoint = 10000000,	abbreviation = SECOND_NUMBER_CAP_NO_SPACE,	significandDivisor = 1000000,	fractionDivisor = 10 },
		{ breakpoint = 10000,		abbreviation = FIRST_NUMBER_CAP_NO_SPACE,	significandDivisor = 1000,		fractionDivisor = 10 },
	}
end

function LocalizePlayerFrame(offsXVehicle, offsYVehicle, offsX, offsY)
	PlayerFrame_UpdatePlayerNameTextAnchor = function()
		if (PlayerFrame.unit == "vehicle") then
			PlayerName:SetPoint("TOPLEFT", offsXVehicle, offsYVehicle);
		else
			PlayerName:SetPoint("TOPLEFT", offsX, offsY);
		end
	end
end

function LocalizekoKR()
	LocalizeNumberAbbreviation_Asian();
end

function LocalizezhCN()
	LocalizeNumberAbbreviation_Asian();
	LocalizePlayerFrame(92, -26, 85, -26);
end

function LocalizezhTW()
	LocalizeNumberAbbreviation_Asian();
	LocalizePlayerFrame(92, -27, 85, -27);
end

local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {
		localize = LocalizekoKR,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localize = LocalizezhCN,
	},
	zhTW = {
		localize = LocalizezhTW,
	},
};

SetupLocalization(l10nTable);