-- NOTE: This is current only shared between classic projects, mainline needs its own
local shared_l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {
		localize = function()
			-- Random name button is for English only
			ALLOW_RANDOM_NAME_BUTTON = true;
		end,
	},
	esES = {},
	esMX = {},
	frFR = {},
	itIT = {},
	koKR = {},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {},
	zhTW = {
		localizeFrames = function()
			CharacterCreateNameEdit:SetMaxLetters(12);

			-- Defined variable to show gameroom billing messages
			SHOW_GAMEROOM_BILLING_FRAME = 1;

			-- Hide save username button
			HIDE_SAVE_ACCOUNT_NAME_CHECKBUTTON = true;

			-- zhTW Logo
			BURNING_CRUSADE_ORIGINAL_LOGO_OVERRIDE = {filename = 'Interface\\Glues\\Common\\GLUES-WOW-TAIWANBCLOGO', uv = { 0, 1, 0, 1 }};

			tbcInfoIconAtlas = "classic-burningcrusade-infoicon-zhtw";
			tbcInfoPaneInfographicAtlas = "classic-announcementpopup-bcinfographic-zhtw";
			choicePaneCurrentLogoAtlas = "classic-burningcrusadetransition-choice-logo-current-zhtw";
			choicePaneOtherLogoAtlas = "classic-burningcrusadetransition-choice-logo-other-zhtw";
		end
	},
};

SetupLocalization(shared_l10nTable);
