local function LocalizeInspectTabs_zh()
	for i=1, (InspectFrame.numTabs or 0) do
		local tabName = "InspectFrameTab"..i;
		_G[tabName.."Text"]:SetPoint("CENTER", tabName, "CENTER", 0, 5);
	end
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
			SpecializationSpecName:SetFontObject(GameFontNormalHuge);
		end,
	},
	zhCN = {
		localize = LocalizeInspectTabs_zh,
	},
	zhTW = {
        localize = LocalizeInspectTabs_zh,
    },
};

SetupLocalization(l10nTable);