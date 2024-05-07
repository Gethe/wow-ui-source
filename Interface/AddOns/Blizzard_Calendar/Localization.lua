local function SetFirstWeekday(day)
	CALENDAR_FIRST_WEEKDAY = day or 2; -- 1=SUN 2=MON 3=TUE 4=WED 5=THU 6=FRI 7=SAT
end

local l10nTable = {
	deDE = {
		localize = SetFirstWeekday,
	},
	enGB = {
		localize = SetFirstWeekday,
	},

	enUS = {

	},

	esES = {
		localize = SetFirstWeekday,
	},
	esMX = {
		localize = function() SetFirstWeekday(1); end,
	},

	frFR = {
		localize = SetFirstWeekday,
	},

	itIT = {
		localize = SetFirstWeekday,
	},

	koKR = {
		localize = LocalizekoKR,
	},

	ptBR = {

	},

	ptPT = {
		localize = function()

		end,
	},

	ruRU = {
		localize = SetFirstWeekday,
	},

	zhCN = {
		localize = LocalizezhCN,
	},

	zhTW = {
		localize = LocalizezhTW,
	},
};

SetupLocalization(l10nTable);