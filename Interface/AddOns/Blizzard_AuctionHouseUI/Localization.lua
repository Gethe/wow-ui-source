local function AdjustWoWTokenDisplayFont()
	-- These existed but never seemed to be used because Blizzard_AuctionHouseUI.toc
	-- never loaded a Localization file, nor did it have a stub in its directory.
	-- These may need to be removed if the behavior is incorrect, but it was likely
	-- already incorrect and this fixes it.
	AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.LeftDisplay.Label:SetFontObject("GameFontNormalHugeBlack");
	AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.RightDisplay.Label:SetFontObject("GameFontNormalHugeBlack");
end

local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {
		localize = AdjustWoWTokenDisplayFont,
	},
	esMX = {
		localize = AdjustWoWTokenDisplayFont,
	},
	frFR = {
		localize = AdjustWoWTokenDisplayFont,
	},
	itIT = {
		localize = function()
			AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.LeftDisplay.Label:SetFontObject("Game18Font");
			AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.RightDisplay.Label:SetFontObject("Game18Font");
		end,
	},
	koKR = {},
	ptBR = {
		localize = AdjustWoWTokenDisplayFont,
	},
	ptPT = {
		localize = AdjustWoWTokenDisplayFont,
	},
	ruRU = {
		localize = AdjustWoWTokenDisplayFont,
	},
	zhCN = {},
	zhTW = {},
};

SetupLocalization(l10nTable);