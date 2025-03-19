local function AdjustOrderHallMissionFrameFont()
	OrderHallMissionFrame.MissionTab.MissionPage.CostFrame.CostLabel:SetFontObject("GameFontNormal");
	OrderHallMissionFrame.MissionTab.ZoneSupportMissionPage.CostFrame.CostLabel:SetFontObject("GameFontNormal");
end

local l10nTable = {
	deDE = {
		localize = AdjustOrderHallMissionFrameFont,
	},
	enGB = {},
	enUS = {},
	esES = {
		localize = AdjustOrderHallMissionFrameFont,
	},
	esMX = {
			localize = AdjustOrderHallMissionFrameFont,
	},
	frFR = {},
	itIT = {
		localize = AdjustOrderHallMissionFrameFont,
	},
	koKR = {
		localize = function()
			FIRST_NUMBER_CAP_VALUE = 10000;
        end,
	},
	ptBR = {
		localize = AdjustOrderHallMissionFrameFont,
	},
	ptPT = {
		localize = AdjustOrderHallMissionFrameFont,
	},
	ruRU = {
		localize = function()
			AdjustOrderHallMissionFrameFont();

			GarrisonMissionFrame.MissionTab.MissionPage.CostFrame.CostLabel:SetFontObject("GameFontNormal");
			GarrisonShipyardFrame.MissionTab.MissionPage.CostFrame.CostLabel:SetFontObject("GameFontNormal");
			BFAMissionFrame.MissionTab.MissionPage.CostFrame.CostLabel:SetFontObject("GameFontNormal");
		end,
	},
	zhCN = {
        localize = function()
			FIRST_NUMBER_CAP_VALUE = 10000;
        end,
	},
	zhTW = {
        localize = function()
			FIRST_NUMBER_CAP_VALUE = 10000;
        end,

        localizeFrames = function()
        end,
    },
};

SetupLocalization(l10nTable);
