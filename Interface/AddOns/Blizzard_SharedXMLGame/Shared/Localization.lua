-- luacheck: ignore 111 (setting non-standard global variable)

local function UseEuropeanNumbers()
	-- Keeping the behavior the same as it was, but it seems like this would ideally be in localize, not localizeFrames
	SetEuropeanNumbers(true);
end

local function AddSpaceToPlayerListDelimiter()
	-- TODO: Not sure why this can't be fixed in globalString data, but leaving this alone
	-- until the dust from the refactor settles.
	PLAYER_LIST_DELIMITER = PLAYER_LIST_DELIMITER.." ";	--Don't ask (bug 158181)
end

local l10nTable = {
	deDE = {
		localize = AddSpaceToPlayerListDelimiter,
		localizeFrames = UseEuropeanNumbers,
	},
	enGB = {},
	enUS = {},
	esES = {
		localize = AddSpaceToPlayerListDelimiter,
		localizeFrames = UseEuropeanNumbers,
	},
	esMX = {
		localize = AddSpaceToPlayerListDelimiter,
	},
	frFR = {
		localize = AddSpaceToPlayerListDelimiter,
		localizeFrames = UseEuropeanNumbers,
	},
	itIT = {
		localize = AddSpaceToPlayerListDelimiter,
		localizeFrames = UseEuropeanNumbers,
	},
	koKR = {},
	ptBR = {
		localizeFrames = UseEuropeanNumbers,
	},
	ptPT = {
		localizeFrames = UseEuropeanNumbers,
	},
	ruRU = {
		localizeFrames = UseEuropeanNumbers,
	},
	zhCN = {},
	zhTW = {
        localize = function()
        end,

        localizeFrames = function()
        end,
    },
};

SetupLocalization(l10nTable);