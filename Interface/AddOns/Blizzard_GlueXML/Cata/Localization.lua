-- luacheck: ignore 111 (setting non-standard global variable)

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
			if(CharCreateAllianceLabel) then
				CharCreateAllianceLabel:SetFontObject("FactionName_Shadow_MediumLarge");
			elseif CharacterCreateConfigurationFrame then
				CharacterCreateConfigurationFrame.AllianceText:SetFontObject("FactionName_Shadow_MediumLarge");
			end

			if(CharCreateHordeLabel) then
				CharCreateHordeLabel:SetFontObject("FactionName_Shadow_MediumLarge");
			elseif CharacterCreateConfigurationFrame then
				CharacterCreateConfigurationFrame.HordeText:SetFontObject("FactionName_Shadow_MediumLarge");
			end
		end,
	},
	ptBR = {},
	ptPT = {},
	ruRU = {},
	zhCN = {
		localize = function()
			SetCharacterGenderAppend = function(sex)
				if ( sex == Enum.UnitSex.Male ) then
					if(CharacterCreateGenderButtonMaleHighlightText ~= nil) then
						CharacterCreateGenderButtonMaleHighlightText:SetText(MALE);
					end
					CharacterCreateGenderButtonMale:LockHighlight();
					if(CharacterCreateGenderButtonFemaleHighlightText ~= nil) then
						CharacterCreateGenderButtonFemaleHighlightText:SetText("");
					end
					CharacterCreateGenderButtonFemale:UnlockHighlight();
				else
					if(CharacterCreateGenderButtonMaleHighlightText ~= nil) then
						CharacterCreateGenderButtonMaleHighlightText:SetText("");
					end
					CharacterCreateGenderButtonMale:UnlockHighlight();
					if(CharacterCreateGenderButtonFemaleHighlightText ~= nil) then
						CharacterCreateGenderButtonFemaleHighlightText:SetText(FEMALE);
					end
					CharacterCreateGenderButtonFemale:LockHighlight();
				end
			end

			GetCNLogoReleaseType = function()
				return LE_RELEASE_TYPE_CLASSIC;
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
			local characterCreateGender = _G["CharacterCreateGender"];
			if (characterCreateGender ~= nil) then
				characterCreateGender:Hide();
			end
		end,
	},
	zhTW = {},
};

SetupLocalization(l10nTable);