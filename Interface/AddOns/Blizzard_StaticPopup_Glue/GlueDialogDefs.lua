StaticPopupDialogs["OKAY"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
};

StaticPopupDialogs["PAID_SERVICE_IN_PROGRESS"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
};

StaticPopupDialogs["OKAY_HTML_MUST_ACCEPT"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	explicitAcknowledge = true,
	html = 1,
};

StaticPopupDialogs["OKAY_MUST_ACCEPT"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	explicitAcknowledge = true,
};

StaticPopupDialogs["CANCEL"] = {
	text = "",
	button1 = CANCEL,
	button2 = nil,
	OnAccept = function(dialog, data)
		C_Login.DisconnectFromServer();
	end,
};

StaticPopupDialogs["OKAY_HTML"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	html = 1,
};

StaticPopupDialogs["OKAY_WITH_URL"] = {
	text = "",
	button1 = DIALOG_HELP_MORE_INFO,
	button2 = OKAY,
	OnAccept = function(dialog, data)
		LaunchURL(_G[data]);
	end,
	OnCancel = function(dialog, data)
	end,
};

StaticPopupDialogs["OKAY_WITH_URL_INDEX"] = {
	text = "",
	button1 = DIALOG_HELP_MORE_INFO,
	button2 = OKAY,
	OnAccept = function(dialog, data)
		local urlIndex = data;
		LoadURLIndex(urlIndex);
	end,
};

StaticPopupDialogs["OKAY_WITH_GENERIC_URL"] = {
	text = "",
	button1 = HELP,
	button2 = OKAY,
	OnAccept = function(dialog, data)
		LaunchURL(BNET_ERROR_GENERIC_URL);
	end,
	OnCancel = function(dialog, data)
	end,
};

StaticPopupDialogs["ERROR_CINEMATIC"] = {
	text = ERROR_CINEMATIC,
	button1 = OKAY,
	button2 = nil,
};

StaticPopupDialogs["CLIENT_RESTART_ALERT"] = {
	text = CLIENT_RESTART_ALERT,
	button1 = OKAY,
	showAlert = 1,
};

StaticPopupDialogs["DECLINE_FAILED"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	OnAccept = function(dialog, data)
		DeclensionFrame:Show();
	end,
};

StaticPopupDialogs["RETRIEVING_CHARACTER_LIST"] = {
	text = CHAR_LIST_RETRIEVING,
	ignoreKeys = true,
	spinner = true,
};

StaticPopupDialogs["CHAR_DELETE_IN_PROGRESS"] = {
	text = CHAR_DELETE_IN_PROGRESS,
	ignoreKeys = true,
	spinner = true,
};

StaticPopupDialogs["REALM_LIST_IN_PROGRESS"] = {
	text = REALM_LIST_IN_PROGRESS,
	ignoreKeys = true,
	button1 = CANCEL,
	button2 = nil,
	OnAccept = function(dialog, data)
		RealmList_OnCancel();
	end,
};

StaticPopupDialogs["OKAY_LEGAL_REDIRECT"] = {
	text = LEGAL_REDIRECT_WARNING,
	button1 = OKAY,
	button2 = nil,
	OnAccept = function(dialog, data)
		C_Login.DisconnectFromServer();
		LaunchURL(C_Login.GetAgreementLink());
	end,
};

StaticPopupDialogs["REALM_IS_FULL"] = {
	text = REALM_IS_FULL_WARNING,
	button1 = YES,
	button2 = NO,
	showAlert = 1,
	OnAccept = function(dialog, data)
		C_RealmList.ConnectToRealm(RealmList.selectedRealm);
	end,
	--OnCancel OVERRIDEN
};

StaticPopupDialogs["CONFIRM_PAID_SERVICE"] = {
	text = CONFIRM_PAID_SERVICE,
	button1 = DONE,
	button2 = CANCEL,
	--OnAccept OVERRIDEN
};

StaticPopupDialogs["CONFIRM_VAS_FACTION_CHANGE"] = {
	text = CONFIRM_PAID_SERVICE,
	button1 = DONE,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		CharacterCreateFrame:BeginVASTransaction();
	end,
	--OnCancel OVERRIDEN
};

StaticPopupDialogs["CHARACTER_CREATE_VAS_ERROR"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	OnAccept = function(dialog, data)
		if data then
			CharacterCreateFrame:Exit();
		end
	end,
};

StaticPopupDialogs["REALM_LOCALE_WARNING"] = {
	text = REALM_TYPE_LOCALE_WARNING,
	button1 = OKAY,
	button2 = nil,
};

StaticPopupDialogs["REALM_TOURNAMENT_WARNING"] = {
	text = REALM_TYPE_TOURNAMENT_WARNING,
	button1 = OKAY,
	button2 = nil,
};

StaticPopupDialogs["QUEUED_NORMAL"] = {
	text = "",
	button1 = CHANGE_REALM,
	OnAccept = function(dialog, data)
		C_RealmList.RequestChangeRealmList();
	end,
};

StaticPopupDialogs["QUEUED_WITH_FCM"] = {
	text = "",
	button1 = QUEUE_FCM_BUTTON,
	button2 = CHANGE_REALM,
	darken = true,
	--OnAccept OVERRIDEN
	OnCancel = function(dialog, data)
		C_RealmList.RequestChangeRealmList();
	end,
};

StaticPopupDialogs["CHARACTER_BOOST_NO_CHARACTERS_WARNING"] = {
	text = CHARACTER_BOOST_NO_CHARACTERS_WARNING_DIALOG_TEXT,
	button1 = CHARACTER_BOOST_NO_CHARACTERS_WARNING_DIALOG_ACCEPT_WARNING,
	button2 = CHARACTER_BOOST_NO_CHARACTERS_WARNING_DIALOG_IGNORE_WARNING,
	displayVertical = true,
	escapeHides = true,
	--OnAccept OVERRIDEN
	OnCancel = function(dialog, data)
		CharacterUpgradePopup_BeginCharacterUpgradeFlow(data);
	end,
};

StaticPopupDialogs["CHARACTER_BOOST_FEATURE_RESTRICTED"] = {
	text = "",
	button1 = OKAY,
	escapeHides = true,
};

StaticPopupDialogs["BOOST_NOT_RECOMMEND_SPEC_WARNING"] = {
	text = BOOST_NOT_RECOMMEND_SPEC_WARNING,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		CharacterServicesMaster_Advance();
	end,
	OnCancel = function(dialog, data)
		local master = CharacterServicesMaster;
		master.flow:Rewind(master);
	end,
};

StaticPopupDialogs["BOOST_ALLIED_RACE_HERITAGE_ARMOR_WARNING"] = {
	button1 = CONTINUE,
	button2 = CANCEL,
	html = 1,
	OnAccept = function(dialog, data)
		-- Character select auto advances to spec select.
		CharacterServicesMaster_Update();
	end,
	OnCancel = function(dialog, data)
		local master = CharacterServicesMaster;
		master.flow:Restart(master);
	end,
};

StaticPopupDialogs["LEGION_PURCHASE_READY"] = {
	text = BLIZZARD_STORE_LEGION_PURCHASE_READY_DESCRIPTION,
	button1 = BLIZZARD_STORE_LOG_OUT_NOW,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_Login.DisconnectFromServer();
	end,
};

StaticPopupDialogs["CONFIGURATION_WARNING"] = {
	button1 = OKAY,
	OnAccept = function(dialog, data)
		C_ConfigurationWarnings.SetConfigurationWarningSeen(data.configurationWarning);
	end,
	showAlert = 1,
	html = 1,
};

StaticPopupDialogs["SUBSCRIPTION_CHANGED_KICK_WARNING"] = {
	text = TRIAL_UPGRADE_LOGOUT_WARNING,
	button1 = CAMP_NOW,
	OnShow = function()
		AccountReactivate_CloseDialogs();
	end,
	OnAccept = function(dialog, data)
		C_Login.DisconnectFromServer();
	end,
	OnCancel = function(dialog, data)
		C_Login.DisconnectFromServer();
	end,
	OnHide = function(dialog, data)
		C_Login.DisconnectFromServer();
	end,
	OnUpdate = function(dialog, elapsed)
		dialog:SetText(StaticPopupDialogs["SUBSCRIPTION_CHANGED_KICK_WARNING"].text:format(math.ceil(dialog.timeleft)));
	end,
	timeout = 15,
	cover = true,
	anchorPoint = "CENTER",
	anchorOffsetY = 150,
};
