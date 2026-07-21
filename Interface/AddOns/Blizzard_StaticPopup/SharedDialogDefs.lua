StaticPopupDialogs["GENERIC_CONFIRMATION"] = {
	text = "",		-- supplied dynamically.
	button1 = "",	-- supplied dynamically.
	button2 = "",	-- supplied dynamically.
	OnShow = function(dialog, data)
		dialog:SetFormattedText(data.text, data.text_arg1, data.text_arg2);
		dialog:GetButton1():SetText(data.acceptText or YES);
		dialog:GetButton2():SetText(data.cancelText or NO);

		if data.showAlert then
			dialog.AlertIcon:Show();
		end
	end,
	OnAccept = function(dialog, data)
		data.callback();
	end,
	OnCancel = function(dialog, data)
		local cancelCallback = data and data.cancelCallback or nil;
		if cancelCallback ~= nil then
			cancelCallback();
		end
	end,
	hideOnEscape = 1,
	timeout = 0,
	multiple = 1,
	whileDead = 1,
	wide = 1, -- Always wide to accomodate the alert icon if it is present.
};
