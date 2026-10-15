-- luacheck: ignore 111 (setting non-standard global variable)

local l10nTable = {
	deDE = {},
	enGB = {},
	enUS = {
        localizeFrames = function()
			--[[
				Random name button is for English only.

				If the random name button is expanded to other locales in the future, make sure to update
				the CharacterCreateMixin UninitializeGamepad function in Blizzard_CharacterCreate.lua.
			]]
			local canShowRandomNameButton = not InputUtil.IsGamepadUIEnabled();
			CharacterCreateFrame.NameChoiceFrame.RandomNameButton:SetShown(canShowRandomNameButton);
        end,
	},
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
			-- Defined variable to show gameroom billing messages
			SHOW_GAMEROOM_BILLING_FRAME = 1;

			-- Hide save username button
			HIDE_SAVE_ACCOUNT_NAME_CHECKBUTTON = true;

			ServerAlertFrame:SetWidth(350);
			ServerAlertFrame:SetHeight(400);
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
