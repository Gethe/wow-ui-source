-- luacheck: ignore 111 (setting non-standard global variable)

local l10nTable = {
	deDE = {
        localizeFrames = function()
			RPEUpgradeMinimizedFrame.Title:SetFontObject(GameFontNormalLargeOutline);
        end,
	},
	enGB = {},
	enUS = {
        localizeFrames = function()
			-- Random name button is for English only
			CharacterCreateFrame.NameChoiceFrame.RandomNameButton:SetShown(true);
        end,
	},
	esES = {},
	esMX = {},
	frFR = {
        localizeFrames = function()
			RealmCharactersSort:SetWidth(RealmCharactersSort:GetWidth() + 8);
			RealmLoadSort:SetWidth(RealmLoadSort:GetWidth() - 8);

			RPEUPgradeInfoFrame.ControlsFrame.Header:SetFontObject(GameFontNormal);
        end,
	},
	itIT = {},
	koKR = {
        localizeFrames = function()
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
        localizeFrames = function()
			CharacterCreateFrame.NameChoiceFrame.EditBox:SetMaxLetters(12);

			-- Defined variable to show gameroom billing messages
			SHOW_GAMEROOM_BILLING_FRAME = 1;

			ONLY_SHOW_GAMEROOM_BILLING_FRAME_ON_PERSONAL_TIME = true;

			-- Hide save username button
			HIDE_SAVE_ACCOUNT_NAME_CHECKBUTTON = true;

			SHOW_CHINA_AGE_APPROPRIATENESS_WARNING = true;
        end,
	},
	zhTW = {
		localizeFrames = function()
			CharacterCreateFrame.NameChoiceFrame.EditBox:SetMaxLetters(12);

			-- Defined variable to show gameroom billing messages
			SHOW_GAMEROOM_BILLING_FRAME = 1;

			-- Hide save username button
			HIDE_SAVE_ACCOUNT_NAME_CHECKBUTTON = true;
		end,
	},
};

SetupLocalization(l10nTable);
