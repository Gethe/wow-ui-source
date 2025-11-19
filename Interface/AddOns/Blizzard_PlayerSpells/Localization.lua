local function SetRemainingTalentPointsYOffSet(newYOffset)
	local classCurrencyDisplay = PlayerSpellsFrame.TalentsFrame.ClassCurrencyDisplay;
	classCurrencyDisplay.CurrentAmountContainer:SetPoint("LEFT", classCurrencyDisplay.CurrencyLabel, "RIGHT", 3, newYOffset);

	local specCurrencyDisplay = PlayerSpellsFrame.TalentsFrame.SpecCurrencyDisplay;
	specCurrencyDisplay.CurrentAmountContainer:SetPoint("LEFT", specCurrencyDisplay.CurrencyLabel, "RIGHT", 3, newYOffset);
end

local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {},
	ptPT = {},
	ruRU = {
		localize = function()
			SetRemainingTalentPointsYOffSet(3);
		end,
	},
	zhCN = {
		localize = function()
			SetRemainingTalentPointsYOffSet(3);
		end,
	},
	zhTW = {
		localize = function()
			SetRemainingTalentPointsYOffSet(3);
		end,
	},
};

SetupLocalization(l10nTable);
