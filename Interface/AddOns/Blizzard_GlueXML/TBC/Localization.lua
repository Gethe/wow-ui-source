local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {},
	esES = {},
	esMX = {},
	frFR = {
		localizeFrames = function()
			RealmCharactersSort:SetWidth(RealmCharactersSort:GetWidth() + 8);
			RealmLoadSort:SetWidth(RealmLoadSort:GetWidth() - 8);
		end,
	},
	itIT = {},
	koKR = {
		localizeFrames = function()
			AccountLogin.UI.CommunityButton:SetPoint("BOTTOMLEFT", AccountLogin.UI, "BOTTOMLEFT", 10, 80);

			-- Defined variable to show gameroom billing messages
			SHOW_GAMEROOM_BILLING_FRAME = 1;

			-- Hide save username button
			HIDE_SAVE_ACCOUNT_NAME_CHECKBUTTON = true;

			ServerAlertFrame:SetWidth(350);
			ServerAlertFrame:SetHeight(400);

			SHOW_KOREAN_RATINGS = true;
		end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localize = function()
			GetCNLogoReleaseType = function()
				-- Due to licensing restrictions in China, we want to use the original expansion's logo rather than the Classic logo. See CLASS-22057 for more info.
				return LE_RELEASE_TYPE_ORIGINAL;
			end
		end,

		localizeFrames = function()
			CharacterCreateNameEdit:SetMaxLetters(12);

			-- Defined variable to show gameroom billing messages
			SHOW_GAMEROOM_BILLING_FRAME = 1;

			ONLY_SHOW_GAMEROOM_BILLING_FRAME_ON_PERSONAL_TIME = true;

			-- Hide save username button
			HIDE_SAVE_ACCOUNT_NAME_CHECKBUTTON = true;

			-- zhCN Logo
			CLASSIC_MODERN_LOGO_OVERRIDE = {filename = 'Interface\\Glues\\Common\\GLUES-WOW-CLASSICLOGO', uv = { 0, 1, 0, 1 }};
			BURNING_CRUSADE_ORIGINAL_LOGO_OVERRIDE = {filename = 'Interface\\Glues\\Common\\GLUES-WOW-CHINESEBCLOGO', uv = { 0, 1, 0, 1 }};

			_G["CharacterCreateWoWLogo"]:SetPoint("TOPLEFT", _G["CharacterCreateFrame"], 3, 14) -- -3, +11
			_G["CharacterSelectLogo"]:SetPoint("TOPLEFT", 5, -5);
			_G["AccountLogin"].UI.GameLogo:SetPoint("TOPLEFT", 5, -5);

			tbcInfoIconAtlas = "classic-burningcrusade-infoicon-zhcn";
			tbcInfoPaneInfographicAtlas = "classic-announcementpopup-bcinfographic-zhcn";
			choicePaneCurrentLogoAtlas = "classic-burningcrusadetransition-choice-logo-current-zhcn";
			choicePaneOtherLogoAtlas = "classic-burningcrusadetransition-choice-logo-other-zhcn";

			SHOW_CHINA_AGE_APPROPRIATENESS_WARNING = true;
		end,
	},

	zhTW = {},
};

SetupLocalization(l10nTable);