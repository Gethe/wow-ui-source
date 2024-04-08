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

			CharacterCreateConfigurationFrame.AllianceText:SetFontObject("FactionName_Shadow_MediumLarge");
			CharacterCreateConfigurationFrame.HordeText:SetFontObject("FactionName_Shadow_MediumLarge");
		end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localize = function()
			SetCharacterGenderAppend = function(sex)
				if ( sex == Enum.UnitSex.Male ) then
					CharacterCreateGenderButtonMaleHighlightText:SetText(MALE);
					CharacterCreateGenderButtonMale:LockHighlight();
					CharacterCreateGenderButtonFemaleHighlightText:SetText("");
					CharacterCreateGenderButtonFemale:UnlockHighlight();
				else
					CharacterCreateGenderButtonMaleHighlightText:SetText("");
					CharacterCreateGenderButtonMale:UnlockHighlight();
					CharacterCreateGenderButtonFemaleHighlightText:SetText(FEMALE);
					CharacterCreateGenderButtonFemale:LockHighlight();
				end
			end

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

			_G["CharacterSelectLogo"]:SetPoint("TOPLEFT", 5, -5);
			_G["AccountLogin"].UI.GameLogo:SetPoint("TOPLEFT", 5, -5);
			_G["CharacterCreateGender"]:Hide();

			SHOW_CHINA_AGE_APPROPRIATENESS_WARNING = true;
		end,
	},
	zhTW = {},
};

SetupLocalization(l10nTable);