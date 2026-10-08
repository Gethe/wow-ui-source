StaticPopupDialogs["QUEUED_NORMAL"] = {
	text = "",
	button1 = CANCEL,
	OnAccept = function(dialog, data)
		CharacterSelect_Exit();
	end,
};

StaticPopupDialogs["QUEUED_WITH_FCM"] = {
	text = "",
	button1 = QUEUE_FCM_BUTTON,
	button2 = CANCEL,
	darken = true,
	OnCancel = function(dialog, data)
		CharacterSelect_Exit();
	end,
};
