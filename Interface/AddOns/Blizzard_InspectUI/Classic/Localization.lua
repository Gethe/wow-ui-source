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
			--Adjust spec font so it doesn't overflow the window
			SpecializationSpecName:SetFontObject(GameFontNormalHuge);
		end,
	},
	zhCN = {
		localize = function()
			LocalizeInspectTabs_zh();
			InspectTalentFrameSpentPoints:SetPoint("BOTTOMLEFT", 30, 85); -- +0, -1
		end,
	},
	zhTW = {
		localize = function()
			LocalizeInspectTabs_zh();
			InspectTalentFrameSpentPoints:SetPoint("BOTTOMLEFT", 30, 83); -- +0, -3
		end,
	},
};

SetupLocalization(l10nTable);