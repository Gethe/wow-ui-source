StaticPopupDialogs["REALM_IS_FULL"].OnCancel = function(dialog, data)
	C_RealmList.ClearRealmList();
	CharacterSelect_ChangeRealm();
end;

StaticPopupDialogs["CONFIRM_PAID_SERVICE"].OnAccept = function(dialog, data)
	C_CharacterCreation.CreateCharacter(CharacterCreateNameEdit:GetText());
end;

StaticPopupDialogs["QUEUED_WITH_FCM"].OnAccept = function(dialog, data)
	C_StoreSecure.GetPurchaseList();
	ToggleStoreUI();
end;

StaticPopupDialogs["CHARACTER_BOOST_NO_CHARACTERS_WARNING"].OnAccept = function(dialog, data)
	CharSelectServicesFlowFrame:Hide();
	CharacterSelect_CreateNewCharacter(Enum.CharacterCreateType.Normal, true);
end;

StaticPopupDialogs["ADVANCED_CHARACTER_CREATION_WARNING"] = {
	text = "",
	button1 = ADVANCED_CHARACTER_CREATION_WARNING_DIALOG_ACCEPT_WARNING,
	button2 = ADVANCED_CHARACTER_CREATION_WARNING_DIALOG_IGNORE_WARNING,
	displayVertical = true,
	ignoreKeys = true,
	OnCancel = function(dialog, data)
		CharacterClass_SelectClass(data, true);
	end,
};

StaticPopupDialogs["DOWNLOAD_HIGH_RES_TEXTURES"] = {
    text = IsMacClient() and HD_TEXTURES_DLG_TEXT_MAC or HD_TEXTURES_DLG_TEXT,
    button1 = IsMacClient() and HD_TEXTURES_DLG_ACCEPT_MAC or HD_TEXTURES_DLG_ACCEPT,
    button2 = CANCEL,
    escapeHides = true,
	OnAccept = function(dialog, data)
		C_BattleNet.InstallHighResTextures();
	end,
};

StaticPopupDialogs["REALM_IS_LOCKED"] = {
	text = CHAR_CREATE_ONLY_EXISTING,
	button1 = CONTINUE,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		RealmList_OnConnectToRealm();
	end
};