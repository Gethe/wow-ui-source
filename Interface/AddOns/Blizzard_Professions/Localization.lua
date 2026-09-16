local function Localize_zh()
	-- Replace instances of GameFontHighlightSmall2 with the larger GameFontHighlightSmall.
	ProfessionsFrame.CraftingPage.SchematicForm.RequiredTools:SetFontObject("GameFontHighlightSmall");
	ProfessionsFrame.CraftingPage.SchematicForm.RecraftingRequiredTools:SetFontObject("GameFontHighlightSmall");
	ProfessionsFrame.CraftingPage.SchematicForm.Description:SetFontObject("GameFontHighlightSmall");

	PROFESSIONS_SCHEMATIC_REAGENTS_Y_OFFSET = -12;
end

local l10nTable = {
	deDE = {
		localize = function()
			ProfessionsFrame.SpecPage.UnlockTabButton:SetWidth(190);
			ProfessionsFrame.SpecPage.ViewTreeButton:SetWidth(200);
		end,
	},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localize = Localize_zh,
	},
	zhTW = {
        localize = Localize_zh,
    },
};

SetupLocalization(l10nTable);
