local atGlues = C_Glue.IsOnGlueScreen();
local dialogFrames = {};
local shownDialogFrames = {};
local queuedDialogInfo = {};
local showConditions = {};

StaticPopupDialogs = {}; -- Definitions
StaticPopupTimeoutSec = 60;

function StaticPopup_AddShowCondition(func)
	table.insert(showConditions, func);
end

function StaticPopup_AddDefinition(which, definition)
	StaticPopupDialogs[which] = definition;
end

function StaticPopup_SetButtonText(which, buttonIndex, text)
	StaticPopupDialogs[which]["button"..buttonIndex] = text;
end

function StaticPopup_AddDialog(dialog)
	table.insert(dialogFrames, dialog);
end

function StaticPopup_RemoveDialog(dialog)
	table.remove(dialogFrames, tIndexOf(dialog));
end

local function GetFirstShownDialog(ignoreFixed)
	for i, dialog in ipairs(shownDialogFrames) do
		if not ignoreFixed or not dialog.hasFixedPosition then
			return dialog;
		end
	end
	return nil;
end

local function StaticPopup_IsDialogFixed(dialog)
	return dialog and dialog.hasFixedPosition;
end

local function GetLastShownDialog(ignoreFixed)
	for i = #shownDialogFrames, 1, -1 do
		local dialog = shownDialogFrames[i];
		if not ignoreFixed or not StaticPopup_IsDialogFixed(dialog) then
			return dialog;
		end
	end
	return nil;
end

local function StaticPopup_CollapseTable()
	for index, dialog in ipairs_reverse(shownDialogFrames) do
		if not dialog:IsShown() then
			table.remove(shownDialogFrames, index);
		end
	end
end

local fullscreenFrameOverride;
local function GetFullScreenFrame()
	return fullscreenFrameOverride or GetAppropriateTopLevelParent();
end

function StaticPopup_UpdateSubText(dialog, dialogInfo)
	if dialogInfo.subtextIsTimer and dialogInfo.timeFormatter then
		dialog.SubText:SetText(dialogInfo.subText:format(dialogInfo.timeFormatter:Format(dialog.timeleft)));
	else
		dialog.SubText:SetText(dialogInfo.subText);
	end
end

function StaticPopup_SetFullScreenFrame(frame)
	if frame then
		fullscreenFrameOverride = frame;
		StaticPopup_ReparentDialogs();
	end
end

function StaticPopup_ClearFullScreenFrame()
	fullscreenFrameOverride = nil;
	StaticPopup_ReparentDialogs();
end

function StaticPopup_StandardConfirmationTextHandler(editBox, expectedText)
	local dialog = editBox:GetParent();
	local button1 = dialog:GetButton1();
	button1:SetEnabled(ConfirmationEditBoxMatches(editBox, expectedText));
end

function StaticPopup_StandardNonEmptyTextHandler(editBox)
	local dialog = editBox:GetParent();
	local button1 = dialog:GetButton1();
	button1:SetEnabled(UserEditBoxNonEmpty(editBox));
end

function StaticPopup_StandardEditBoxOnEscapePressed(editBox)
	editBox:GetParent():Hide();
end

function StaticPopup_FindVisible(which, data)
	local dialogInfo = StaticPopupDialogs[which];
	if not dialogInfo then
		return nil;
	end

	for _, dialog in ipairs(shownDialogFrames) do
		if (dialog.which == which) and (not dialogInfo.multiple or (dialog.data == data)) then
			return dialog;
		end
	end
	return nil;
end

function StaticPopup_Visible(which)
	for _, dialog in ipairs(shownDialogFrames) do
		if dialog.which == which then
			return dialog:GetName(), dialog;
		end
	end
	return nil;
end

function StaticPopup_ForEachShownDialog(func)
	for _, dialog in ipairs(shownDialogFrames) do
		func(dialog);
	end
	return nil;
end

local function GetStaticPopupToken(systemPrefix, notificationType)
	return (systemPrefix or "NOTIFICATION_")..(notificationType or "GENERIC");
end

function StaticPopup_ShowNotification(systemPrefix, notificationType, message)
	local staticPopupToken = GetStaticPopupToken(systemPrefix, notificationType);

	if StaticPopupDialogs[staticPopupToken] == nil then
		StaticPopupDialogs[staticPopupToken] = {
			text = "",

			OnShow = function(dialog, popupMessage)
				dialog:GetTextFontString():SetText(popupMessage);
			end,

			button1 = OKAY,
			timeout = 0,
			whileDead = 1,
		};
	end

	local text_arg1 = nil;
	local text_arg2 = nil;
	StaticPopup_Show(staticPopupToken, text_arg1, text_arg2, message);
end

function StaticPopup_HideNotification(systemPrefix, notificationType)
	local staticPopupToken = GetStaticPopupToken(systemPrefix, notificationType);
	StaticPopup_Hide(staticPopupToken);
end

function StaticPopup_ShowGenericConfirmation(text, callback, insertedFrame)
	local data = { text = text, callback = callback, };
	StaticPopup_ShowCustomGenericConfirmation(data, insertedFrame);
end

-- customData keys:
-- .text: the text for the confirmation.
-- .text_arg1 : formatted into text if provided
-- .text_arg2 : formatted into text if provided
-- .callback: the callback when the player accepts.
-- .cancelCallback: the callback when the player cancels (will not be called on accept).
-- .acceptText: custom text for the accept button.
-- .cancelText: custom text for the cancel button.
-- .showAlert: whether or not the alert texture should show.
-- .referenceKey: used with StaticPopup_IsCustomGenericConfirmationShown.
function StaticPopup_ShowCustomGenericConfirmation(customData, insertedFrame)
	StaticPopup_Show("GENERIC_CONFIRMATION", nil, nil, customData, insertedFrame);
end

function StaticPopup_IsCustomGenericConfirmationShown(referenceKey)
	for _, dialog in ipairs(shownDialogFrames) do
		if (dialog.which == "GENERIC_CONFIRMATION") and (dialog.data.referenceKey == referenceKey) then
			return true;
		end
	end

	return false;
end

-- customData keys:
-- .text: the text for the confirmation.
-- .text_arg1 : formatted into text if provided
-- .text_arg2 : formatted into text if provided
-- .callback: the callback when the player accepts.
-- .cancelCallback: the callback when the player cancels (will not be called on accept).
-- .acceptText: custom text for the accept button.
-- .cancelText: custom text for the cancel button.
-- .maxLetters: the maximum text length that can be entered.
-- .countInvisibleLetters: used in tandem with maxLetters.
function StaticPopup_ShowCustomGenericInputBox(customData, insertedFrame)
	StaticPopup_Show("GENERIC_INPUT_BOX", nil, nil, customData, insertedFrame);
end

function StaticPopup_ShowGenericDropdown(text, callback, options, requiresConfirmation, defaultOption)
	local data = { text = text, callback = callback, options = options, requiresConfirmation = requiresConfirmation, defaultOption = defaultOption };
	StaticPopup_Show("GENERIC_DROP_DOWN", nil, nil, data);
end

function StaticPopup_Queue(which, text_arg1, text_arg2, data, insertedFrame, customOnHideScript)
	table.insert(queuedDialogInfo, {
		which = which,
		text_arg1 = text_arg1,
		text_arg2 = text_arg2,
		data = data,
		insertedFrame = insertedFrame,
		customOnHideScript = customOnHideScript,
	});
end

function StaticPopup_CheckQueuedDialogs()
	if #queuedDialogInfo > 0 and not StaticPopup_IsAnyDialogShown() then
		local info = queuedDialogInfo[1];
		StaticPopup_Show(info.which, info.text_arg1, info.text_arg2, info.data, info.insertedFrame, info.customOnHideScript);
		table.remove(queuedDialogInfo, 1);
	end
end

local function CancelAndHideDialog(dialog, reason)
	dialog:Hide();

	local dialogInfo = StaticPopupDialogs[dialog.which];
	if not dialogInfo then
		return;
	end

	local onCancel = dialogInfo.OnCancel;
	if not onCancel then
		return;
	end

	onCancel(dialog, dialog.data, reason);
end

function StaticPopup_Show(which, text_arg1, text_arg2, data, insertedFrame, customOnHideScript)
	local dialogInfo = StaticPopupDialogs[which];
	if not dialogInfo then
		error("Dialog "..which.. " does not exist.");
	end

	if dialogInfo.OnAccept and dialogInfo.OnButton1 then
		error("Dialog "..which.. " cannot have both OnAccept and OnButton1");
	end

	if dialogInfo.OnCancel and dialogInfo.OnButton2 then
		error("Dialog "..which.. " cannot have both OnCancel and OnButton2");
	end

	if dialogInfo.editBoxSecureText and not issecure() then
		error("Dialog "..which.. " cannot be shown from a tainted context");
	end

	if atGlues then
		-- We don't actually want to hide, we just want to redisplay?
		StaticPopup_HideAllExcept(which);
	end

	for index, func in ipairs(showConditions) do
		if func(dialogInfo, data) ~= true then
			if dialogInfo.OnCancel then
				dialogInfo.OnCancel(nil, data);
			end
			return nil;
		end
	end

	if dialogInfo.exclusive then
		StaticPopup_HideExclusive();
	end

	if dialogInfo.cancels then
		for index, dialog in ipairs_reverse(shownDialogFrames) do
			if dialog.which == dialogInfo.cancels then
				CancelAndHideDialog(dialog, "override");
			end
		end
	end

	if dialogInfo.cancelIfNotAllowedWhileLoggingOut then
		for index, dialog in ipairs_reverse(shownDialogFrames) do
			if not dialogInfo.notClosableByLogout then
				CancelAndHideDialog(dialog, "override");
			end
		end
	end

	if dialogInfo.cancelIfNotAllowedWhileDead then
		for index, dialog in ipairs_reverse(shownDialogFrames) do
			if not dialogInfo.whileDead then
				CancelAndHideDialog(dialog, "override");
			end
		end
	end


	local dialog;
	-- Check if it should use a reserved dialog frame
	if dialogInfo.GetReservedDialogFrame then
		dialog = dialogInfo.GetReservedDialogFrame();
		if not dialog.reserved then
			error("Dialog "..which.. " is trying to use a non-reserved dialog frame.");
		end
	end

	-- Otherwise find an open dialog of the requested type
	dialog = dialog or StaticPopup_FindVisible(which, data);
	if dialog then
		if not dialogInfo.noCancelOnReuse then
			CancelAndHideDialog(dialog, "override");
		else
			dialog:Hide();
		end
	else
		-- Find a free dialog
		for _, dlg in ipairs(dialogFrames) do
			if dlg and (not dlg:IsShown()) then
				dialog = dlg;
				break;
			end
		end
	end

	if not dialog then
		if dialogInfo.OnCancel then
			dialogInfo.OnCancel(nil, data);
		end
		return nil;
	end

	-- Set the miscellaneous variables for the dialog
	dialog.which = which;
	dialog.dialogInfo = dialogInfo;
	dialog.data = data;
	dialog.timeleft = dialogInfo.timeout or 0;
	dialog.hideOnEscape = dialogInfo.hideOnEscape;
	dialog.exclusive = dialogInfo.exclusive;
	dialog.enterClicksFirstButton = dialogInfo.enterClicksFirstButton;
	dialog.insertedFrame = insertedFrame;
	dialog.customOnHideScript = customOnHideScript;
	dialog.progressBarDuration = nil;

	dialog:SetParent(GetAppropriateTopLevelParent());
	dialog:Init(which, text_arg1, text_arg2, data, insertedFrame);
	dialog:SetWindow(nil);

	-- Finally size and show the dialog
	StaticPopup_SetUpPosition(dialog);
	dialog:Show();
	dialog:Resize();

	if dialogInfo.sound then
		PlaySound(dialogInfo.sound);
	end

	return dialog;
end

function StaticPopup_SetTimeLeft(dialog, timeleft)
	dialog.timeleft = timeleft;
end

function StaticPopup_SetProgressBarTime(dialog, duration, timeleft)
	if dialog.dialogInfo and dialog.dialogInfo.progressBar then
		dialog.progressBarDuration = duration;
		dialog.timeleft = timeleft;
	end
end

function StaticPopup_ResizeShownDialogs()
	for _, dialog in ipairs(shownDialogFrames) do
		dialog:Resize(dialog.which);
	end
end

function StaticPopup_Hide(which, data)
	for _, dialog in ipairs_reverse(shownDialogFrames) do
		if (dialog.which == which) and (not data or (data == dialog.data)) then
			dialog:Hide();
		end
	end
end

function StaticPopup_HideAllExcept(which)
	for _, dialog in ipairs_reverse(shownDialogFrames) do
		if dialog.which ~= which then
			dialog:Hide();
		end
	end
end

function StaticPopup_HideAll()
	for _, dialog in ipairs_reverse(shownDialogFrames) do
		local dialogInfo = StaticPopupDialogs[dialog.which];
		if not dialogInfo or not dialogInfo.explicitAcknowledge then
			dialog:Hide();
		end
	end
end

function StaticPopup_OnUpdate(dialog, elapsed)
	local which = dialog.which;
	local dialogInfo = dialog.dialogInfo;

	if dialog.timeleft > 0 then
		dialog.timeleft = math.max(dialog.timeleft - elapsed, 0);

		if dialog.timeleft <= 0 then
			if not dialogInfo.timeoutInformationalOnly then
				CancelAndHideDialog(dialog, "timeout");
			end
			return;
		end

		if dialogInfo.subtextIsTimer and dialogInfo.timeFormatter then
			StaticPopup_UpdateSubText(dialog, dialogInfo);
		elseif not dialog.startDelay then
			local timeleft = math.ceil(dialog.timeleft);
			if dialogInfo.GetExpirationText then
				local text = dialogInfo.GetExpirationText(dialog, dialog.data, timeleft);
				dialog:GetTextFontString():SetText(text);
				dialog:Resize();
			end

			if dialogInfo.GetExpirationSubText then
				local text = dialogInfo.GetExpirationSubText(dialog, dialog.data, timeleft);
				dialog.SubText:SetText(text);
				dialog:Resize();
			end

			if dialog.progressBarDuration then
				local percent = dialog.timeleft / dialog.progressBarDuration;
				StaticPopup_UpdateProgressBar(dialog, percent);
			end
		end
	end

	if dialog.startDelay then
		local timeleft = dialog.startDelay - elapsed;
		if timeleft <= 0 then
			dialog.startDelay = nil;
			dialog:GetTextFontString():SetFormattedText(dialogInfo.text, dialog:GetTextFontString().text_arg1, dialog:GetTextFontString().text_arg2);
			dialog:GetButton1():Enable();
			dialog:Resize();
			return;
		end
		dialog.startDelay = timeleft;

		if dialogInfo.GetExpirationText then
			local text = dialogInfo.GetExpirationText(dialog, dialog.data, ceil(timeleft));
			dialog:GetTextFontString():SetText(text);
			dialog:Resize();
		end
	end

	if dialog.acceptDelay then
		dialog.acceptDelay = dialog.acceptDelay - elapsed;
		if dialog.acceptDelay <= 0 then
			dialog:GetButton1():Enable();
			dialog:GetButton1():SetText(dialogInfo.button1);
			dialog.acceptDelay = nil;

			if dialogInfo.OnAcceptDelayExpired ~= nil then
				dialogInfo.OnAcceptDelayExpired(dialog, dialog.data);
			end
		else
			dialog:GetButton1():Disable();
			dialog:GetButton1():SetText(math.ceil(dialog.acceptDelay));
		end
	end

	local onUpdate = dialogInfo.OnUpdate;
	if onUpdate then
		onUpdate(dialog, elapsed, dialog.data);
	end
end

function StaticPopup_UpdateProgressBar(dialog, percent)
	-- the fill is a little shorter than the border
	local maxWidth = dialog.ProgressBarBorder:GetWidth() - 8;
	if percent <= 0 then
		dialog.ProgressBarFill:Hide();
	else
		dialog.ProgressBarFill:Show();
		dialog.ProgressBarFill:SetWidth(maxWidth * percent);
		dialog.ProgressBarFill:SetTexCoord(0, percent, 0, 1);
	end
end

-- This is intended to be used to continue ticking dialogs while the entire UI is hidden
function StaticPopup_UpdateAll(elapsed)
	for _, dialog in ipairs(shownDialogFrames) do
		if not dialog:IsVisible() then
			StaticPopup_OnUpdate(dialog, elapsed);
		end
	end
end

function StaticPopup_ReleaseInsertedFrame(dialog)
	if dialog.insertedFrame then
		dialog.insertedFrame:Hide();
		dialog.insertedFrame:SetParent(nil);
		dialog.insertedFrame = nil;
	end
end

function StaticPopup_OnShow(dialog)
	dialog:Raise();

	local dialogInfo = StaticPopupDialogs[dialog.which];
	if dialogInfo.OnShow then
		dialogInfo.OnShow(dialog, dialog.data);
	end

	if dialogInfo.cover then
		assert(atGlues); -- No modal frame implementation it glue
		GlueParent_AddModalFrame(dialog);
	end

	if atGlues or dialogInfo.enterClicksFirstButton then
		dialog:SetScript("OnKeyDown", StaticPopup_OnKeyDown);
	end
end

function StaticPopup_OnHide(dialog)
	if atGlues then
		GlueParent_RemoveModalFrame(dialog);
	else
		-- No modal frame implementation in-game
	end

	if dialog.customOnHideScript then
		dialog.customOnHideScript(dialog);
		dialog.customOnHideScript = nil;
	end

	local dialogInfo = StaticPopupDialogs[dialog.which];
	if dialogInfo.OnHide then
		dialogInfo.OnHide(dialog, dialog.data);
	end

	if dialog:GetEditBox() then
		if dialog:GetEditBox().ClearText then
			dialog:GetEditBox():ClearText();
		else
			dialog:GetEditBox():SetText("");
		end
	end

	if atGlues or dialogInfo.enterClicksFirstButton then
		dialog:SetScript("OnKeyDown", nil);
	end

	StaticPopup_ReleaseInsertedFrame(dialog);

	StaticPopup_CollapseTable();
end

function StaticPopup_OnCloseButtonClicked(closeButton, button)
	closeButton:GetParent():OnCloseButtonClicked(button);
end

local function StaticPopup_CallInfoHandler(dialog, handlerName, ...)
	if dialog:IsShown() then
		local which = dialog.which;
		local dialogInfo = StaticPopupDialogs[which];
		if dialogInfo then
			local handler = dialogInfo[handlerName];
			if handler then
				handler(dialog, ...);
			end
		end
	end
end

function StaticPopup_OnHyperlinkClick(dialog, ...)
	StaticPopup_CallInfoHandler(dialog, "OnHyperlinkClick", ...);
end

function StaticPopup_OnHyperlinkEnter(dialog, ...)
	StaticPopup_CallInfoHandler(dialog, "OnHyperlinkEnter", ...);
end

function StaticPopup_OnHyperlinkLeave(dialog, ...)
	StaticPopup_CallInfoHandler(dialog, "OnHyperlinkLeave", ...);
end

function StaticPopup_OnClick(dialog, index)
	if not dialog:IsShown() then
		return;
	end
	local which = dialog.which;
	local dialogInfo = StaticPopupDialogs[which];
	if not dialogInfo then
		return nil;
	end

	if dialogInfo.selectCallbackByIndex then
		local func;
		if index == 1 then
			func = dialogInfo.OnAccept or dialogInfo.OnButton1;
		elseif index == 2 then
			func = dialogInfo.OnCancel or dialogInfo.OnButton2;
		elseif index == 3 then
			func = dialogInfo.OnButton3;
		elseif index == 4 then
			func = dialogInfo.OnButton4;
		elseif index == 5 then
			func = dialogInfo.OnExtraButton;
		end

		if func then
			local keepOpen = func(dialog, dialog.data, "clicked");
			if not keepOpen and which == dialog.which then
				dialog:Hide();
			end
		end
	else
		-- Keeping this temporarily for backward compatibility
		local hide = true;
		if index == 1 then
			local OnAccept = dialogInfo.OnAccept or dialogInfo.OnButton1;
			if OnAccept then
				hide = not OnAccept(dialog, dialog.data, dialog.data2);
			end
		elseif index == 3 then
			local OnAlt = dialogInfo.OnAlt;
			if OnAlt then
				OnAlt(dialog, dialog.data, "clicked");
			end
		elseif index == 5 then
			local OnExtraButton = dialogInfo.OnExtraButton;
			if OnExtraButton then
				OnExtraButton(dialog, dialog.data, dialog.data2);
			end
		else
			local OnCancel = dialogInfo.OnCancel;
			if OnCancel then
				hide = not OnCancel(dialog, dialog.data, "clicked");
			end
		end

		if hide and (which == dialog.which) and (index ~= 3 or not dialogInfo.noCloseOnAlt) then
			-- can dialog.which change inside one of the On* functions???
			dialog:Hide();
		end
	end

	if atGlues then
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
	end
end

local function CallOnButton(dialog, dialogInfo, startIndex, forward, func)
	local offset = forward and 1 or -1;
	local index = startIndex;
	local button = nil;
	repeat
		button = dialog:GetButton(index);
		if button and button:IsShown() and button:IsEnabled() then
			func(dialog, dialogInfo, index);
			break;
		end
		index = index + offset;
	until button == nil;
end

local function CallOnFirstmostButton(dialog, dialogInfo, startIndex, func)
	local forward = true;
	CallOnButton(dialog, dialogInfo, startIndex, forward, func);
end

local function CallOnLastmostButton(dialog, dialogInfo, startIndex, func)
	local forward = false;
	CallOnButton(dialog, dialogInfo, startIndex, forward, func);
end

local function OnKeyDownClickHandler(dialog, dialogInfo, index)
	StaticPopup_OnClick(dialog, index);

	if dialogInfo.hideSound then
		PlaySound(dialogInfo.hideSound);
	end
end

local function StaticPopup_OnEscapeKeyDown(dialog)
	local dialogInfo = StaticPopupDialogs[dialog.which];
	if not dialogInfo or dialogInfo.ignoreKeys then
		return;
	end

	if dialogInfo.escapeHides then
		dialog:Hide();
	end

	if atGlues then
		local startIndex = 2;
		CallOnLastmostButton(dialog, dialogInfo, startIndex, OnKeyDownClickHandler);
	end
end

function StaticPopup_OnKeyDown(dialog, key)
	local bindingKey = GetBindingFromClick(key);
	if bindingKey == "TOGGLEGAMEMENU" then
		return StaticPopup_OnEscapeKeyDown(dialog);
	elseif bindingKey == "SCREENSHOT" then
		RunBinding("SCREENSHOT");
		return;
	end

	if key == "ENTER" then
		if atGlues or dialog.enterClicksFirstButton then
			local dialogInfo = StaticPopupDialogs[dialog.which];
			if not dialogInfo or dialogInfo.ignoreKeys then
				return;
			end

			local startIndex = 1;
			CallOnFirstmostButton(dialog, dialogInfo, startIndex, OnKeyDownClickHandler);
		end
	end
end

-- Called by a cascading escape handler in UIParent
function StaticPopup_EscapePressed()
	local closed = nil;
	for _, dialog in ipairs_reverse(shownDialogFrames) do
		if dialog.hideOnEscape then
			local dialogInfo = StaticPopupDialogs[dialog.which];
			if dialogInfo then
				if dialogInfo.OnCancel and (not dialogInfo.noCancelOnEscape) then
					dialogInfo.OnCancel(dialog, dialog.data, "clicked");
				end
				dialog:Hide();
			else
				StaticPopupSpecial_Hide(dialog);
			end
			closed = 1;
		end
	end
	return closed;
end

local nextDialogFallbackID = CreateCounter(42); -- Start the ids large enough that no other popup with an id would overlap this space.
local dialogFallbackIDs = SecureTypes.CreateSecureMap();

local function AssignDialogFallbackID(dialog)
	dialogFallbackIDs[dialog] = nextDialogFallbackID();
end

local function CheckDialogFallbackID(dialog)
	local fallbackID = dialogFallbackIDs[dialog];
	if not fallbackID then
		fallbackID = nextDialogFallbackID();
		dialogFallbackIDs[dialog] = fallbackID;
	end

	return fallbackID;
end

local function DialogOrderComparator(d1, d2)
	local d1IsSpecial = d1.special;
	local d2IsSpecial = d2.special;
	if d1IsSpecial ~= d2IsSpecial then
		return not d1IsSpecial;
	end

	local id1 = d1:GetID();
	local id2 = d2:GetID();
	if id1 and id2 and id1 ~= id2 then
		return id1 < id2;
	end

	return CheckDialogFallbackID(d1) < CheckDialogFallbackID(d2);
end

function StaticPopup_SetUpPosition(dialog)
	-- Need to do this before inserting below
	local ignoreFixed = true;

	-- Glues has a single dialog so repositioning is always allowed.
	local insertIndex = tInsertUnique(shownDialogFrames, dialog);
	if not atGlues and (insertIndex == nil) then
		return;
	end

	table.sort(shownDialogFrames, DialogOrderComparator);

	local parent = GetFullScreenFrame();
	dialog:SetParent(parent);
	dialog:SetFrameStrata("DIALOG");

	local dialogInfo = dialog.dialogInfo;
	local anchorDialogFrame = dialogInfo and dialogInfo.AnchorDialogFrame;
	local hasFixedPosition = dialogInfo and (dialogInfo.GetReservedDialogFrame or anchorDialogFrame);
	dialog.hasFixedPosition = hasFixedPosition;

	if StaticPopup_IsDialogFixed(dialog) then
		if anchorDialogFrame then
			dialog:ClearAllPoints();
			anchorDialogFrame(dialog);
		end
	else
		if atGlues then
			dialog:ClearAllPoints();
			dialog:SetAllPoints(parent);
		else
			local previousDialog = nil;
			for index, shownDialog in ipairs(shownDialogFrames) do
				if not StaticPopup_IsDialogFixed(shownDialog) then
					shownDialog:ClearAllPoints();

					if previousDialog then
						shownDialog:SetPoint("TOP", previousDialog, "BOTTOM", 0, 0);
					else
						shownDialog:SetPoint("TOP", GetFullScreenFrame(), "TOP", 0, shownDialog.topOffset or -135);
					end

					previousDialog = shownDialog;
				end
			end
		end
	end
end

function StaticPopupSpecial_Show(dialog)
	dialog.special = true;
	AssignDialogFallbackID(dialog);

	if dialog.exclusive then
		StaticPopup_HideExclusive();
	end

	StaticPopup_SetUpPosition(dialog);
	dialog:Show();
end

function StaticPopupSpecial_Hide(dialog)
	if not dialog.special then
		return;
	end

	dialog:Hide();
	StaticPopup_CollapseTable();
end

function StaticPopupSpecial_Toggle(dialog)
	if dialog:IsShown() then
		StaticPopupSpecial_Hide(dialog);
	else
		StaticPopupSpecial_Show(dialog);
	end
end

function StaticPopup_ReparentDialogs()
	for _, dialog in ipairs(shownDialogFrames) do
		dialog:SetParent(GetFullScreenFrame());
		dialog:SetFrameStrata("DIALOG");
	end
end

--Used to figure out if we can resize a frame
function StaticPopup_IsLastDisplayedFrame(frame)
	local ignoreFixed = true;
	local lastShownDialog = GetLastShownDialog(ignoreFixed);
	return lastShownDialog == frame;
end

function StaticPopup_HideExclusive()
	for _, dialog in ipairs(shownDialogFrames) do
		if dialog.exclusive then
			local dialogInfo = StaticPopupDialogs[dialog.which];
			if dialogInfo then
				CancelAndHideDialog(dialog, "override");
			else
				StaticPopupSpecial_Hide(dialog);
			end
			break;
		end
	end
end

-- beforeSpinnerWaitTime is the time we wait before showing the spinner after hitting accept
function StaticPopup_OnAcceptWithSpinner(onAcceptCallback, onEventCallback, events, beforeSpinnerWaitTime, dialog)
	onAcceptCallback(dialog);

	dialog:GetButton1():Disable();
	dialog:GetButton2():Disable();

	local spinnerTimer = C_Timer.NewTimer(beforeSpinnerWaitTime, function()
		dialog.DarkOverlay:Show();
		dialog.Spinner:Show();
	end);

	FrameUtil.RegisterFrameForEvents(dialog, events);

	local oldOnEvent = dialog:GetScript("OnEvent");
	local oldOnHide = dialog:GetScript("OnHide");

	local function OnComplete()
		spinnerTimer:Cancel();
		dialog.Spinner:Hide();
		dialog:SetScript("OnEvent", oldOnEvent);
		dialog:SetScript("OnHide", oldOnHide);
		FrameUtil.UnregisterFrameForEvents(dialog, events);
		dialog:Hide();
	end

	dialog:SetScript("OnEvent", function(self, event, ...)
		if oldOnEvent then
			oldOnEvent(self, event, ...);
		end

		for i, registeredEvent in ipairs(events) do
			if event == registeredEvent then
				if onEventCallback(self, event, ...) then
					OnComplete();
				end
			end
		end
	end);
	dialog:SetScript("OnHide", function(self)
		if oldOnHide then
			oldOnHide(self);
		end
		OnComplete();
	end);

	return true;
end

function StaticPopup_IsAnyDialogShown()
	return GetFirstShownDialog() ~= nil;
end

StaticPopup_AddShowCondition(function(dialogInfo, data)
	if not dialogInfo.interruptCinematic and InCinematic() then
		return false;
	end
	return true;
end);

EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", function()
	StaticPopup_ResizeShownDialogs();
end);
