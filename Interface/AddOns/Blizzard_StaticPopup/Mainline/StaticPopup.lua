local StaticPopup_DisplayedFrames = { };

STATICPOPUP_NUMDIALOGS = 4;
STATICPOPUP_TIMEOUT = 60;
STATICPOPUP_TEXTURE_ALERT = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew";
STATICPOPUP_TEXTURE_ALERTGEAR = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertOther";
StaticPopupDialogs = { };

local fullscreenFrameOverride;
local function GetFullscreenFrame()
	return fullscreenFrameOverride or GetAppropriateTopLevelParent();
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

function StaticPopup_StandardConfirmationTextHandler(self, expectedText)
	local parent = self:GetParent();
	parent.button1:SetEnabled(ConfirmationEditBoxMatches(parent.editBox, expectedText));
end

function StaticPopup_StandardNonEmptyTextHandler(self)
	local parent = self:GetParent();
	parent.button1:SetEnabled(UserEditBoxNonEmpty(parent.editBox));
end

function StaticPopup_StandardEditBoxOnEscapePressed(self)
	self:GetParent():Hide();
end

function StaticPopup_GetDialog(index)
	return _G["StaticPopup"..index];
end

function StaticPopup_FindVisible(which, data)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = StaticPopup_GetDialog(index);
		if ( frame and frame:IsShown() and (frame.which == which) and (not info.multiple or (frame.data == data)) ) then
			return frame;
		end
	end
	return nil;
end

function StaticPopup_Visible(which)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = StaticPopup_GetDialog(index);
		if( frame and frame:IsShown() and (frame.which == which) ) then
			return frame:GetName(), frame;
		end
	end
	return nil;
end

function StaticPopup_Resize(dialog, which)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	local text = _G[dialog:GetName().."Text"];
	local editBox = _G[dialog:GetName().."EditBox"];
	local button1 = _G[dialog:GetName().."Button1"];
	local extraButton = dialog.extraButton;

	local maxHeightSoFar, maxWidthSoFar = (dialog.maxHeightSoFar or 0), (dialog.maxWidthSoFar or 0);
	local width = 320;

	if ( info.verticalButtonLayout ) then
		width = width + 30;
	else
		if (info.showAlert or info.showAlertGear or info.customAlertIcon or info.closeButton or info.wide) then
			width = 420;
		elseif ( info.editBoxWidth and info.editBoxWidth > 260 ) then
			width = width + (info.editBoxWidth - 260);
		elseif ( which == "GUILD_IMPEACH" ) then
			width = 375;
		end
	end

	-- Ensure that the dialog can contain the buttons, regardless of the configuration.
	local button2 = _G[dialog:GetName().."Button2"];
	local button3 = _G[dialog:GetName().."Button3"];
	local button4 = _G[dialog:GetName().."Button4"];
	local buttons = {button1, button2, button3, button4};
	local outerMargin = 60;
	local buttonMinWidth = outerMargin;
	for index, button in ipairs(buttons) do
		if button:IsShown() then
			buttonMinWidth = buttonMinWidth + button:GetWidth();
		end
	end
	width = max(width, buttonMinWidth);

	if ( dialog.insertedFrame ) then
		width = max(width, dialog.insertedFrame:GetWidth());
	end
	if ( width > maxWidthSoFar ) then
		dialog:SetWidth(width);
		dialog.maxWidthSoFar = width;
	end

	if ( info.wideText ) then
		dialog.text:SetWidth(360);
		dialog.SubText:SetWidth(360);
	else
		dialog.text:SetWidth(290);
		dialog.SubText:SetWidth(290);
	end

	-- Slightly reducing width to prevent the text from feeling cramped
	if ( info.normalSizedSubText and not info.wideText ) then
		local currentWidth = dialog.SubText:GetWidth();
		dialog.SubText:SetWidth(currentWidth - 20);
	end

	local height = 32 + text:GetHeight() + 2;
	if ( info.extraButton ) then
		height = height + 40 + extraButton:GetHeight();
	end
	if ( not info.nobuttons ) then
		height = height + 6 + button1:GetHeight();
	end
	if ( info.hasEditBox ) then
		height = height + 8 + editBox:GetHeight();
	elseif ( info.hasMoneyFrame ) then
		height = height + 16;
	elseif ( info.hasMoneyInputFrame ) then
		height = height + 22;
	end
	if ( info.hasDropDown ) then
		height = height + 8 + dialog.DropDownControl:GetHeight();
	end
	if ( dialog.insertedFrame ) then
		height = height + dialog.insertedFrame:GetHeight();
	end
	if ( info.hasItemFrame ) then
		if ( info.compactItemFrame ) then
			height = height + 44;
		else
			height = height + 64;
		end
	end
	if ( dialog.SubText:IsShown() ) then
		height = height + dialog.SubText:GetHeight() + 8;
		-- Adding a bit more vertical space to prevent the text from feeling cramped
		if ( info.normalSizedSubText and info.compactItemFrame) then
			height = height + 18;
		end
	end

	if ( info.verticalButtonLayout ) then
		height = height + 16 + (26 * (dialog.numButtons - 1));
	end

	if ( height > maxHeightSoFar ) then
		dialog:SetHeight(height);
		dialog.maxHeightSoFar = height;
	end
end

function StaticPopup_ShowNotification(systemPrefix, notificationType, message)
	local staticPopupToken = (systemPrefix or "NOTIFICATION_")..(notificationType or "GENERIC");

	if StaticPopupDialogs[staticPopupToken] == nil then
		StaticPopupDialogs[staticPopupToken] = {
			text = "",

			OnShow = function(self, popupMessage)
				self.text:SetText(popupMessage);
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
	for index = 1, STATICPOPUP_NUMDIALOGS do
		local frame = StaticPopup_GetDialog(index);
		if ( frame and frame:IsShown() and (frame.which == "GENERIC_CONFIRMATION") and (frame.data.referenceKey == referenceKey) ) then
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

function StaticPopup_ShowGenericDropDown(text, callback, options, hasButtons, defaultOption, insertedFrame)
	local data = { text = text, callback = callback, options = options, hasButtons = hasButtons, defaultOption = defaultOption };
	StaticPopup_Show("GENERIC_DROP_DOWN", nil, nil, data, insertedFrame);
end

local tempButtonLocs = {};	--So we don't make a new table each time.
function StaticPopup_Show(which, text_arg1, text_arg2, data, insertedFrame)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	if ( info.OnAccept and info.OnButton1 ) then
		error("Dialog "..which.. " cannot have both OnAccept and OnButton1");
	end
	if ( info.OnCancel and info.OnButton2 ) then
		error("Dialog "..which.. " cannot have both OnCancel and OnButton2");
	end

	if ( UnitIsDeadOrGhost("player") and not info.whileDead ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	if ( InCinematic() and not info.interruptCinematic ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	if ( info.exclusive ) then
		StaticPopup_HideExclusive();
	end

	if ( info.cancels ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = StaticPopup_GetDialog(index);
			if ( frame and frame:IsShown() and (frame.which == info.cancels) ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			end
		end
	end

	if ( (which == "CAMP") or (which == "QUIT") ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = StaticPopup_GetDialog(index);
			if ( frame and frame:IsShown() and not StaticPopupDialogs[frame.which].notClosableByLogout ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			end
		end
	end

	if ( which == "DEATH" ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = StaticPopup_GetDialog(index);
			if ( frame and frame:IsShown() and not StaticPopupDialogs[frame.which].whileDead ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			end
		end
	end

	-- Pick a free dialog to use
	local dialog = nil;
	-- Find an open dialog of the requested type
	dialog = StaticPopup_FindVisible(which, data);
	if ( dialog ) then
		if ( not info.noCancelOnReuse ) then
			local OnCancel = info.OnCancel;
			if ( OnCancel ) then
				OnCancel(dialog, dialog.data, "override");
			end
		end
		dialog:Hide();
	end
	if ( not dialog ) then
		-- Find a free dialog
		local index = 1;
		if ( info.preferredIndex ) then
			index = info.preferredIndex;
		end
		for i = index, STATICPOPUP_NUMDIALOGS do
			local frame = StaticPopup_GetDialog(i);
			if ( frame and not frame:IsShown() ) then
				dialog = frame;
				break;
			end
		end

		--If dialog not found and there's a preferredIndex then try to find an available frame before the preferredIndex
		if ( not dialog and info.preferredIndex ) then
			for i = 1, info.preferredIndex do
				local frame = _G["StaticPopup"..i];
				if ( not frame:IsShown() ) then
					dialog = frame;
					break;
				end
			end
		end
	end
	if ( not dialog ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	dialog.CoverFrame:SetShown(info.fullScreenCover);

	dialog.maxHeightSoFar, dialog.maxWidthSoFar = 0, 0;
	local bottomSpace = info.extraButton ~= nil and (dialog.extraButton:GetHeight() + 60) or 16;

	-- Set the text of the dialog
	local text = _G[dialog:GetName().."Text"];
	text:Show();
	if ( (which == "DEATH") or
	     (which == "CAMP") or
		 (which == "QUIT") or
		 (which == "DUEL_OUTOFBOUNDS") or
		 (which == "RECOVER_CORPSE") or
		 (which == "RESURRECT") or
		 (which == "RESURRECT_NO_SICKNESS") or
		 (which == "INSTANCE_BOOT") or
		 (which == "GARRISON_BOOT") or
		 (which == "INSTANCE_LOCK") or
		 (which == "CONFIRM_SUMMON") or
		 (which == "CONFIRM_SUMMON_SCENARIO") or
		 (which == "CONFIRM_SUMMON_STARTING_AREA") or
		 (which == "BFMGR_INVITED_TO_ENTER") or
		 (which == "AREA_SPIRIT_HEAL") or
		 (which == "CONFIRM_REMOVE_COMMUNITY_MEMBER") or
		 (which == "CONFIRM_DESTROY_COMMUNITY_STREAM") or
		 (which == "CONFIRM_RUNEFORGE_LEGENDARY_CRAFT") or
		 (which == "ANIMA_DIVERSION_CONFIRM_CHANNEL")) then
		text:SetText(" ");	-- The text will be filled in later.
		text.text_arg1 = text_arg1;
		text.text_arg2 = text_arg2;
	elseif (which == "PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING") then
		dialog.SubText:SetText(" ");	-- The text will be filled in later.
		dialog.SubText.text_arg1 = text_arg1;
		dialog.SubText.text_arg2 = text_arg2;
	elseif ( which == "BILLING_NAG" ) then
		text:SetFormattedText(info.text, text_arg1, MINUTES);
	elseif ( which == "SPELL_CONFIRMATION_PROMPT" or which == "SPELL_CONFIRMATION_WARNING" ) then
		text:SetText(text_arg1);
		info.text = text_arg1;
		info.timeout = text_arg2;
	elseif ( which == "CONFIRM_AZERITE_EMPOWERED_RESPEC_EXPENSIVE" ) then
		local separateThousands = true;
		local goldDisplay = GetMoneyString(data.respecCost, separateThousands);
		text:SetFormattedText(info.text, goldDisplay, text_arg1, CONFIRM_AZERITE_EMPOWERED_RESPEC_STRING);
	elseif  ( which == "BUYOUT_AUCTION_EXPENSIVE" ) then
		local separateThousands = true;
		local goldDisplay = GetMoneyString(text_arg1, separateThousands);
		text:SetFormattedText(info.text, goldDisplay, BUYOUT_AUCTION_CONFIRMATION_STRING);
	else
		text:SetFormattedText(info.text, text_arg1, text_arg2);
		text.text_arg1 = text_arg1;
		text.text_arg2 = text_arg2;
	end

	-- Show or hide the close button
	if ( info.closeButton ) then
		local closeButton = dialog.CloseButton;
		if ( info.closeButtonIsHide ) then
			closeButton:SetNormalAtlas("RedButton-Exit");
			closeButton:SetPushedAtlas("RedButton-exit-pressed");
		else
			closeButton:SetNormalAtlas("RedButton-MiniCondense");
			closeButton:SetPushedAtlas("RedButton-MiniCondense-pressed");
		end
		closeButton:Show();
	else
		dialog.CloseButton:Hide();
	end

	-- Set the editbox of the dialog
	local editBox = _G[dialog:GetName().."EditBox"];
	if ( info.hasEditBox ) then
		editBox:Show();

		editBox.Instructions:SetText(info.editBoxInstructions or "");

		if ( info.maxLetters ) then
			editBox:SetMaxLetters(info.maxLetters);
			editBox:SetCountInvisibleLetters(info.countInvisibleLetters);
		end
		if ( info.maxBytes ) then
			editBox:SetMaxBytes(info.maxBytes);
		end
		editBox:SetText("");
		if ( info.editBoxWidth ) then
			editBox:SetWidth(info.editBoxWidth);
		else
			editBox:SetWidth(130);
		end

		editBox:ClearAllPoints();
		editBox:SetPoint("BOTTOM", 0, 29 + bottomSpace);
	else
		editBox:Hide();
	end

	if ( info.hasDropDown ) then
		dialog.DropDownControl:Show();
		dialog.DropDownControl:SetOptions(info.dropDownOptions, info.dropDownDefaultOption);

		local function StaticPopup_OnDropDownOptionSelected(value, isUserInput)
			info.OnDropDownOptionSelected(dialog, data, value, isUserInput);
		end

		dialog.DropDownControl:SetOptionSelectedCallback(nil);
		dialog.DropDownControl:SetSelectedValue(nil);

		if info.OnDropDownOptionSelected then
			dialog.DropDownControl:SetOptionSelectedCallback(StaticPopup_OnDropDownOptionSelected);
		end
	else
		dialog.DropDownControl:Hide();
	end

	-- Show or hide money frame
	if ( info.hasMoneyFrame ) then
		_G[dialog:GetName().."MoneyFrame"]:Show();
		_G[dialog:GetName().."MoneyInputFrame"]:Hide();
	elseif ( info.hasMoneyInputFrame ) then
		local moneyInputFrame = _G[dialog:GetName().."MoneyInputFrame"];
		moneyInputFrame:Show();
		_G[dialog:GetName().."MoneyFrame"]:Hide();
		-- Set OnEnterPress for money input frames
		if ( info.EditBoxOnEnterPressed ) then
			moneyInputFrame.gold:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			moneyInputFrame.silver:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			moneyInputFrame.copper:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
		else
			moneyInputFrame.gold:SetScript("OnEnterPressed", nil);
			moneyInputFrame.silver:SetScript("OnEnterPressed", nil);
			moneyInputFrame.copper:SetScript("OnEnterPressed", nil);
		end
	else
		_G[dialog:GetName().."MoneyFrame"]:Hide();
		_G[dialog:GetName().."MoneyInputFrame"]:Hide();
	end

	dialog.ItemFrame:ClearAllPoints();
	dialog.SubText:ClearAllPoints();
	local itemFrameXOffset = -60;
	local itemFrameYOffset = -6;
	local subTextSpacingYOffset = info.normalSizedSubText and -18 or -6;
	if ( info.itemFrameAboveSubtext and info.hasItemFrame and info.subText ) then
		dialog.ItemFrame:SetPoint("TOP", dialog.text, "BOTTOM", itemFrameXOffset, itemFrameYOffset);
		-- Other components (like the moneyFrame) can be anchored under subtext so we anchor to the item frame instead of the bottom of the window.
		dialog.SubText:SetPoint("TOP", dialog.ItemFrame, "BOTTOM", -itemFrameXOffset, subTextSpacingYOffset);
	else
		dialog.ItemFrame:SetPoint("BOTTOM", itemFrameXOffset, bottomSpace + (info.compactItemFrame and 29 or 39));
		dialog.SubText:SetPoint("TOP", dialog.text, "BOTTOM", 0, subTextSpacingYOffset);
	end

	dialog.ItemFrame.itemID = nil;
	-- Show or hide item button
	if ( info.hasItemFrame ) then
		dialog.ItemFrame:Show();
		if ( data and type(data) == "table" ) then
			dialog.ItemFrame:SetCustomOnEnter(data.itemFrameOnEnter);

			local itemFrameCallback = data.itemFrameCallback;
			if ( itemFrameCallback ) then
				itemFrameCallback(dialog.ItemFrame);
			else
				if ( data.useLinkForItemInfo ) then
					dialog.ItemFrame:RetrieveInfo(data);
				end
				dialog.ItemFrame:DisplayInfo(data.link, data.name, data.color, data.texture, data.count, data.tooltip);
			end
		end
	else
		dialog.ItemFrame:Hide();
	end

	-- Set the miscellaneous variables for the dialog
	dialog.which = which;
	dialog.timeleft = info.timeout or 0;
	dialog.hideOnEscape = info.hideOnEscape;
	dialog.exclusive = info.exclusive;
	dialog.enterClicksFirstButton = info.enterClicksFirstButton;
	dialog.insertedFrame = insertedFrame;
	if ( info.subText ) then
		dialog.SubText:SetFontObject(info.normalSizedSubText and "GameFontNormal" or "GameFontNormalSmall");
		dialog.SubText:SetText(info.subText);
		dialog.SubText:Show();
	else
		dialog.SubText:Hide();
	end

	if ( insertedFrame ) then
		insertedFrame:SetParent(dialog);
		insertedFrame:ClearAllPoints();
		if ( dialog.SubText:IsShown() ) then
			insertedFrame:SetPoint("TOP", dialog.SubText, "BOTTOM");
		else
			insertedFrame:SetPoint("TOP", text, "BOTTOM");
		end
		insertedFrame:Show();
		_G[dialog:GetName().."MoneyFrame"]:SetPoint("TOP", insertedFrame, "BOTTOM");
		_G[dialog:GetName().."MoneyInputFrame"]:SetPoint("TOP", insertedFrame, "BOTTOM");
	elseif ( dialog.SubText:IsShown() ) then
		_G[dialog:GetName().."MoneyFrame"]:SetPoint("TOP", dialog.SubText, "BOTTOM", 0, -5);
		_G[dialog:GetName().."MoneyInputFrame"]:SetPoint("TOP", dialog.SubText, "BOTTOM", 0, -5);
	else
		_G[dialog:GetName().."MoneyFrame"]:SetPoint("TOP", dialog.text, "BOTTOM", 0, -5);
		_G[dialog:GetName().."MoneyInputFrame"]:SetPoint("TOP", dialog.text, "BOTTOM", 0, -5);
	end
	-- Clear out data
	dialog.data = data;

	-- Set the buttons of the dialog
	local button1 = _G[dialog:GetName().."Button1"];
	local button2 = _G[dialog:GetName().."Button2"];
	local button3 = _G[dialog:GetName().."Button3"];
	local button4 = _G[dialog:GetName().."Button4"];

	local buttons = {button1, button2, button3, button4};
	for index, button in ipairs_reverse(buttons) do
		button:SetText(info["button"..index]);
		button:Hide();
		button:SetWidth(1);
		button:ClearAllPoints();
		button.PulseAnim:Stop();

		if not (info["button"..index] and ( not info["DisplayButton"..index] or info["DisplayButton"..index](dialog))) then
			table.remove(buttons, index);
		end
	end

	dialog.numButtons = #buttons;

	local buttonTextMargin = 20;
	local minButtonWidth = 120;
	local maxButtonWidth = minButtonWidth;
	for index, button in ipairs(buttons) do
		local buttonWidth = button:GetTextWidth() + buttonTextMargin;
		maxButtonWidth = math.max(maxButtonWidth, buttonWidth);
	end

	local function InitButton(button, index)
		if info[string.format("button%dPulse", index)] then
			button.PulseAnim:Play();
		end
		button:Enable();
		button:Show();
	end

	-- Button layout logic depends on the width of the dialog, so this needs to be resized to account
	-- for any configuration options first. It will be resized again after the buttons have been arranged.
	StaticPopup_Resize(dialog, which);

	local buttonPadding = 10;
	local minButtonWidth = 120;
	local totalButtonPadding = (#buttons - 1) * buttonPadding;
	local totalButtonWidth = #buttons * maxButtonWidth;
	local totalWidth;
	local uncondensedTotalWidth = totalButtonWidth + totalButtonPadding;
	if uncondensedTotalWidth < dialog:GetWidth() then
		for index, button in ipairs(buttons) do
			button:SetWidth(maxButtonWidth);
			InitButton(button, index);
		end
		totalWidth = uncondensedTotalWidth;
	else
		totalWidth = totalButtonPadding;
		for index, button in ipairs(buttons) do
			local buttonWidth = math.max(minButtonWidth, button:GetTextWidth()) + buttonTextMargin;
			button:SetWidth(buttonWidth);
			totalWidth = totalWidth + buttonWidth;
			InitButton(button, index);
		end
	end

	if #buttons > 0 then
		if info.verticalButtonLayout then
			buttons[1]:SetPoint("TOP", dialog.text, "BOTTOM", 0, -16);
			for index = 2, #buttons do
				buttons[index]:SetPoint("TOP", buttons[index-1], "BOTTOM", 0, -6);
			end
		else
			local offset = totalWidth / 2;
			buttons[1]:SetPoint("BOTTOMLEFT", dialog, "BOTTOM", -offset, bottomSpace);
			for index = 2, #buttons do
				buttons[index]:SetPoint("BOTTOMLEFT", buttons[index-1], "BOTTOMRIGHT", buttonPadding, 0);
			end
		end
	end

	if info.extraButton then
		local extraButton = dialog.extraButton;
		extraButton:Show();
		extraButton:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 22);
		extraButton:SetText(info.extraButton);
		--widen if too small, but reset to 128 otherwise
		local width = 128
		local padding = 40;
		local textWidth = extraButton:GetTextWidth() + padding;
		width = math.max(width, textWidth);
		extraButton:SetWidth(width);

		dialog.Separator:Show();
	else
		dialog.extraButton:Hide();
		dialog.Separator:Hide();
	end

	-- Show or hide the alert icon
	local alertIcon = _G[dialog:GetName().."AlertIcon"];
	local dataShowsAlert = (which == "GENERIC_CONFIRMATION") and data.showAlert;
	if ( dataShowsAlert or info.showAlert ) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERT);
		if ( button3:IsShown() )then
			alertIcon:SetPoint("LEFT", 24, 10);
		else
			alertIcon:SetPoint("LEFT", 24, 0);
		end
		alertIcon:Show();
	elseif ( info.showAlertGear ) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERTGEAR);
		if ( button3:IsShown() )then
			alertIcon:SetPoint("LEFT", 24, 0);
		else
			alertIcon:SetPoint("LEFT", 24, 0);
		end
		alertIcon:Show();
	elseif ( info.customAlertIcon ) then
		alertIcon:SetTexture(info.customAlertIcon);
		if ( button3:IsShown() ) then
			alertIcon:SetPoint("LEFT", 24, 0);
		else
			alertIcon:SetPoint("LEFT", 24, 0);
		end
		alertIcon:Show();
	else
		alertIcon:SetTexture();
		alertIcon:Hide();
	end

	dialog.Spinner:Hide();

	if ( info.StartDelay ) then
		dialog.startDelay = info.StartDelay(dialog);
		if (not dialog.startDelay or dialog.startDelay <= 0) then
			button1:Enable();
		else
			button1:Disable();
		end
	elseif info.acceptDelay then
		dialog.acceptDelay = info.acceptDelay;
		button1:Disable();
	else
		dialog.startDelay = nil;
		dialog.acceptDelay = nil;
		button1:Enable();
	end

	editBox:SetSecureText(info.editBoxSecureText);
	editBox.hasAutoComplete = info.autoCompleteSource ~= nil;
	if ( editBox.hasAutoComplete ) then
		AutoCompleteEditBox_SetAutoCompleteSource(editBox, info.autoCompleteSource, unpack(info.autoCompleteArgs));
	else
		AutoCompleteEditBox_SetAutoCompleteSource(editBox, nil);
	end

	dialog.DarkOverlay:Hide();

	dialog:SetWindow(nil);

	-- Finally size and show the dialog
	StaticPopup_SetUpPosition(dialog);
	dialog:Show();

	StaticPopup_Resize(dialog, which);

	if ( info.sound ) then
		PlaySound(info.sound);
	end

	return dialog;
end

function StaticPopup_Hide(which, data)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local dialog = StaticPopup_GetDialog(index);
		if ( dialog and dialog:IsShown() and (dialog.which == which) and (not data or (data == dialog.data)) ) then
			dialog:Hide();
		end
	end
end

local SpellConfirmationFormatter = CreateFromMixins(SecondsFormatterMixin);
SpellConfirmationFormatter:Init(0, SecondsFormatter.Abbreviation.None, true, true);

function StaticPopup_OnUpdate(dialog, elapsed)
	if ( dialog.timeleft > 0 ) then
		local which = dialog.which;
		local timeleft = dialog.timeleft - elapsed;
		if ( timeleft <= 0 ) then
			if ( not StaticPopupDialogs[which].timeoutInformationalOnly ) then
				dialog.timeleft = 0;
				local OnCancel = StaticPopupDialogs[which].OnCancel;
				if ( OnCancel ) then
					OnCancel(dialog, dialog.data, "timeout");
				end
				dialog:Hide();
			end
			return;
		end
		dialog.timeleft = timeleft;

		if ( (which == "DEATH") or
		     (which == "CAMP")  or
			 (which == "QUIT") or
			 (which == "DUEL_OUTOFBOUNDS") or
			 (which == "INSTANCE_BOOT") or
			 (which == "GARRISON_BOOT") or
			 (which == "CONFIRM_SUMMON") or
			 (which == "CONFIRM_SUMMON_SCENARIO") or
			 (which == "CONFIRM_SUMMON_STARTING_AREA") or
			 (which == "BFMGR_INVITED_TO_ENTER") or
			 (which == "AREA_SPIRIT_HEAL") or
			 (which == "SPELL_CONFIRMATION_PROMPT") or
			 (which == "PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING") or
			 (which == "ANIMA_DIVERSION_CONFIRM_CHANNEL")) then
			local text = _G[dialog:GetName().."Text"];
			timeleft = ceil(timeleft);
			if ( (which == "INSTANCE_BOOT") or (which == "GARRISON_BOOT") ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, ceil(timeleft / 60), MINUTES);
				end
			elseif ( which == "CONFIRM_SUMMON" or which == "CONFIRM_SUMMON_SCENARIO" or which == "CONFIRM_SUMMON_STARTING_AREA" ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, C_SummonInfo.GetSummonConfirmSummoner() or "", C_SummonInfo.GetSummonConfirmAreaName(), timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, C_SummonInfo.GetSummonConfirmSummoner() or "", C_SummonInfo.GetSummonConfirmAreaName(), ceil(timeleft / 60), MINUTES);
				end
			elseif ( which == "BFMGR_INVITED_TO_ENTER") then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, text.text_arg1, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, text.text_arg1, ceil(timeleft / 60), MINUTES);
				end
			elseif ( which == "SPELL_CONFIRMATION_PROMPT") then
				local time = SpellConfirmationFormatter:Format(timeleft);
				text:SetText(StaticPopupDialogs[which].text .. " " ..TIME_REMAINING .. " " .. time);
			elseif (which == "PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING") then
				dialog.SubText:SetText(StaticPopupDialogs[which].subText:format(SecondsToTime(timeleft)));
			elseif (which == "ANIMA_DIVERSION_CONFIRM_CHANNEL") then
				local formatterOutput = WorldQuestsSecondsFormatter:Format(timeleft);
				local formattedTime = BONUS_OBJECTIVE_TIME_LEFT:format(formatterOutput);
				text:SetFormattedText(StaticPopupDialogs[which].text, text.text_arg1, formattedTime);
			else
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, ceil(timeleft / 60), MINUTES);
				end
			end
			StaticPopup_Resize(dialog, which);
		end
	end
	if ( dialog.startDelay ) then
		local which = dialog.which;
		local timeleft = dialog.startDelay - elapsed;
		if ( timeleft <= 0 ) then
			dialog.startDelay = nil;
			local text = _G[dialog:GetName().."Text"];
			text:SetFormattedText(StaticPopupDialogs[which].text, text.text_arg1, text.text_arg2);
			local button1 = _G[dialog:GetName().."Button1"];
			button1:Enable();
			StaticPopup_Resize(dialog, which);
			return;
		end
		dialog.startDelay = timeleft;

		if ( which == "RECOVER_CORPSE" or (which == "RESURRECT") or (which == "RESURRECT_NO_SICKNESS") ) then
			local text = _G[dialog:GetName().."Text"];
			timeleft = ceil(timeleft);
			if ( (which == "RESURRECT") or (which == "RESURRECT_NO_SICKNESS") ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].delayText, text.text_arg1, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].delayText, text.text_arg1, ceil(timeleft / 60), MINUTES);
				end
			else
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].delayText, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].delayText, ceil(timeleft / 60), MINUTES);
				end
			end
			StaticPopup_Resize(dialog, which);
		end
	end

	if dialog.acceptDelay then
		dialog.acceptDelay = dialog.acceptDelay - elapsed;
		if dialog.acceptDelay <= 0 then
			dialog.button1:Enable();
			local info = StaticPopupDialogs[dialog.which];
			dialog.button1:SetText(info.button1);
			dialog.acceptDelay = nil;

			if info.OnAcceptDelayExpired ~= nil then
				info.OnAcceptDelayExpired(dialog, dialog.data);
			end
		else
			dialog.button1:Disable();
			dialog.button1:SetText(math.ceil(dialog.acceptDelay));
		end
	end

	local onUpdate = StaticPopupDialogs[dialog.which].OnUpdate;
	if ( onUpdate ) then
		onUpdate(dialog, elapsed);
	end
end

function StaticPopup_EditBoxOnEnterPressed(self)
	local EditBoxOnEnterPressed, which, dialog;
	local parent = self:GetParent();
	if ( parent.which ) then
		which = parent.which;
		dialog = parent;
	elseif ( parent:GetParent().which ) then
		-- This is needed if this is a money input frame since it's nested deeper than a normal edit box
		which = parent:GetParent().which;
		dialog = parent:GetParent();
	end
	if ( not self.hasAutoComplete or not AutoCompleteEditBox_OnEnterPressed(self) ) then
		EditBoxOnEnterPressed = StaticPopupDialogs[which].EditBoxOnEnterPressed;
		if ( EditBoxOnEnterPressed ) then
			EditBoxOnEnterPressed(self, dialog.data);
		end
	end
end

function StaticPopup_EditBoxOnEscapePressed(self)
	local EditBoxOnEscapePressed = StaticPopupDialogs[self:GetParent().which].EditBoxOnEscapePressed;
	if ( EditBoxOnEscapePressed ) then
		EditBoxOnEscapePressed(self, self:GetParent().data);
	end
end

function StaticPopup_EditBoxOnTextChanged(self, userInput)
	if ( not self.hasAutoComplete or not AutoCompleteEditBox_OnTextChanged(self, userInput) ) then
		local EditBoxOnTextChanged = StaticPopupDialogs[self:GetParent().which].EditBoxOnTextChanged;
		if ( EditBoxOnTextChanged ) then
			EditBoxOnTextChanged(self, self:GetParent().data);
		end
	end
	self.Instructions:SetShown(self:GetText() == "");
end

function StaticPopup_OnLoad(self)
	local name = self:GetName();
	self.button1 = _G[name .. "Button1"];
	self.button2 = _G[name .. "Button2"];
	self.button3 = _G[name .. "Button3"];
	self.text = _G[name .. "Text"];
	self.icon = _G[name .. "AlertIcon"];
	self.moneyInputFrame = _G[name .. "MoneyInputFrame"];
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function StaticPopup_OnShow(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);

	local dialog = StaticPopupDialogs[self.which];
	local OnShow = dialog.OnShow;

	if ( OnShow ) then
		OnShow(self, self.data);
	end
	if ( dialog.hasMoneyInputFrame ) then
		_G[self:GetName().."MoneyInputFrameGold"]:SetFocus();
	end
	if ( dialog.enterClicksFirstButton ) then
		self:SetScript("OnKeyDown", StaticPopup_OnKeyDown);
	end
end

function StaticPopup_OnHide(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);

	StaticPopup_CollapseTable();

	local dialog = StaticPopupDialogs[self.which];
	local OnHide = dialog.OnHide;
	if ( OnHide ) then
		OnHide(self, self.data);
	end
	self.extraFrame:Hide();
	if ( dialog.enterClicksFirstButton ) then
		self:SetScript("OnKeyDown", nil);
	end
	if ( self.insertedFrame ) then
		self.insertedFrame:Hide();
		self.insertedFrame:SetParent(nil);
		local text = _G[self:GetName().."Text"];
		_G[self:GetName().."MoneyFrame"]:SetPoint("TOP", text, "BOTTOM", 0, -5);
		_G[self:GetName().."MoneyInputFrame"]:SetPoint("TOP", text, "BOTTOM", 0, -5);
	end
end

function StaticPopup_OnCloseButtonClicked(closeButton, button)
	closeButton:GetParent():Hide();
end

local function StaticPopup_CallInfoHandler(dialog, handlerName, ...)
	if ( dialog:IsShown() ) then
		local which = dialog.which;
		local info = StaticPopupDialogs[which];
		if ( info ) then
			local handler = info[handlerName];
			if ( handler ) then
				handler(dialog, ...);
			end
		end
	end
end

function StaticPopup_OnHyperlinkClick(self, ...)
	StaticPopup_CallInfoHandler(self, "OnHyperlinkClick", ...);
end

function StaticPopup_OnHyperlinkEnter(self, ...)
	StaticPopup_CallInfoHandler(self, "OnHyperlinkEnter", ...);
end

function StaticPopup_OnHyperlinkLeave(self, ...)
	StaticPopup_CallInfoHandler(self, "OnHyperlinkLeave", ...);
end

function StaticPopup_OnClick(dialog, index)
	if ( not dialog:IsShown() ) then
		return;
	end
	local which = dialog.which;
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	if info.selectCallbackByIndex then
		local func;
		if ( index == 1 ) then
			func = info.OnAccept or info.OnButton1;
		elseif ( index == 2 ) then
			func = info.OnCancel or info.OnButton2;
		elseif ( index == 3 ) then
			func = info.OnButton3;
		elseif ( index == 4 ) then
			func = info.OnButton4;
		elseif ( index == 5 ) then
			func = info.OnExtraButton;
		end

		if ( func ) then
			local keepOpen = func(dialog, dialog.data, "clicked");
			if ( not keepOpen and which == dialog.which ) then
				dialog:Hide();
			end
		end
	else
		-- Keeping this temporarily for backward compatibility
		local hide = true;
		if ( index == 1 ) then
			local OnAccept = info.OnAccept or info.OnButton1;
			if ( OnAccept ) then
				hide = not OnAccept(dialog, dialog.data, dialog.data2);
			end
		elseif ( index == 3 ) then
			local OnAlt = info.OnAlt;
			if ( OnAlt ) then
				OnAlt(dialog, dialog.data, "clicked");
			end
		elseif ( index == 5 ) then
			local OnExtraButton = info.OnExtraButton;
			if ( OnExtraButton ) then
				OnExtraButton(dialog, dialog.data, dialog.data2);
			end
		else
			local OnCancel = info.OnCancel;
			if ( OnCancel ) then
				hide = not OnCancel(dialog, dialog.data, "clicked");
			end
		end

		if ( hide and (which == dialog.which) and ( index ~= 3 or not info.noCloseOnAlt) ) then
			-- can dialog.which change inside one of the On* functions???
			dialog:Hide();
		end
	end
end

function StaticPopup_OnKeyDown(self, key)
	-- previously, StaticPopup_EscapePressed() captured the escape key for dialogs, but now we need
	-- to catch it here
	if ( GetBindingFromClick(key) == "TOGGLEGAMEMENU" ) then
		return StaticPopup_EscapePressed();
	elseif ( GetBindingFromClick(key) == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
		return;
	end

	local dialog = StaticPopupDialogs[self.which];
	if ( dialog ) then
		if ( key == "ENTER" and dialog.enterClicksFirstButton ) then
			local frameName = self:GetName();
			local button;
			local i = 1;
			while ( true ) do
				button = _G[frameName.."Button"..i];
				if ( button ) then
					if ( button:IsShown() ) then
						if ( button:IsEnabled() ) then
							StaticPopup_OnClick(self, i);
						end
						return;
					end
					i = i + 1;
				else
					break;
				end
			end
		end
	end
end

function StaticPopup_EscapePressed()
	local closed = nil;
	for _, frame in pairs(StaticPopup_DisplayedFrames) do
		if( frame:IsShown() and frame.hideOnEscape ) then
			local standardDialog = StaticPopupDialogs[frame.which];
			if ( standardDialog ) then
				local OnCancel = standardDialog.OnCancel;
				local noCancelOnEscape = standardDialog.noCancelOnEscape;
				if ( OnCancel and not noCancelOnEscape) then
					OnCancel(frame, frame.data, "clicked");
				end
				frame:Hide();
			else
				StaticPopupSpecial_Hide(frame);
			end
			closed = 1;
		end
	end
	return closed;
end

function StaticPopup_SetUpPosition(dialog)
	if ( not tContains(StaticPopup_DisplayedFrames, dialog) ) then
		StaticPopup_SetUpAnchor(dialog, #StaticPopup_DisplayedFrames + 1);
		tinsert(StaticPopup_DisplayedFrames, dialog);
	end
end

function StaticPopup_SetUpAnchor(dialog, idx)
	dialog:SetParent(GetFullscreenFrame());
	dialog:SetFrameStrata("DIALOG");
	local lastFrame = StaticPopup_DisplayedFrames[idx - 1];
	if ( lastFrame ) then
		dialog:SetPoint("TOP", lastFrame, "BOTTOM", 0, 0);
	else
		dialog:SetPoint("TOP", GetFullscreenFrame(), "TOP", 0, dialog.topOffset or -135);
	end
end

function StaticPopup_CollapseTable()
	local displayedFrames = StaticPopup_DisplayedFrames;
	local index = #displayedFrames;
	while ( ( index >= 1 ) and ( not displayedFrames[index]:IsShown() ) ) do
		tremove(displayedFrames, index);
		index = index - 1;
	end
end

function StaticPopupSpecial_Show(frame)
	if ( frame.exclusive ) then
		StaticPopup_HideExclusive();
	end
	StaticPopup_SetUpPosition(frame);
	frame:Show();
end

function StaticPopupSpecial_Hide(frame)
	frame:Hide();
	StaticPopup_CollapseTable();
end

function StaticPopupSpecial_Toggle(frame)
	if frame:IsShown() then
		StaticPopupSpecial_Hide(frame);
	else
		StaticPopupSpecial_Show(frame);
	end
end

function StaticPopup_ReparentDialogs()
	for _, frame in pairs(StaticPopup_DisplayedFrames) do
		frame:SetParent(GetFullscreenFrame());
		frame:SetFrameStrata("DIALOG");
	end
end

--Note that things will look sub-fantastic if toActivate is bigger than toReplace
function StaticPopupSpecial_Replace(toActivate, toReplace)
	local idx = nil;
	for i=1, #StaticPopup_DisplayedFrames do
		if ( StaticPopup_DisplayedFrames[i] == toReplace ) then
			idx = i;
			break;
		end
	end

	if ( idx ) then
		StaticPopup_DisplayedFrames[idx] = toActivate;
		StaticPopup_SetUpAnchor(toActivate, idx);

		toReplace:Hide();
		toActivate:Show();
		return true;
	end

	return false;
end

--Used to figure out if we can resize a frame
function StaticPopup_IsLastDisplayedFrame(frame)
	for i=#StaticPopup_DisplayedFrames, 1, -1 do
		local popup = StaticPopup_DisplayedFrames[i];
		if ( popup:IsShown() ) then
			return frame == popup
		end
	end
	return false;
end

function StaticPopup_OnEvent(self)
	self.maxHeightSoFar = 0;
	StaticPopup_Resize(self, self.which);
end

function StaticPopup_HideExclusive()
	for _, frame in pairs(StaticPopup_DisplayedFrames) do
		if ( frame:IsShown() and frame.exclusive ) then
			local standardDialog = StaticPopupDialogs[frame.which];
			if ( standardDialog ) then
				frame:Hide();
				local OnCancel = standardDialog.OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			else
				StaticPopupSpecial_Hide(frame);
			end
			break;
		end
	end
end

-- beforeSpinnerWaitTime is the time we wait before showing the spinner after hitting accept
function StaticPopup_OnAcceptWithSpinner(onAcceptCallback, onEventCallback, events, beforeSpinnerWaitTime, self)
	onAcceptCallback(self);

	self.button1:Disable();
	self.button2:Disable();

	local spinnerTimer = C_Timer.NewTimer(beforeSpinnerWaitTime, function()
		self.DarkOverlay:Show();
		self.Spinner:Show();
	end);

	FrameUtil.RegisterFrameForEvents(self, events);

	local oldOnEvent = self:GetScript("OnEvent");
	local oldOnHide = self:GetScript("OnHide");

	local function OnComplete()
		spinnerTimer:Cancel();
		self.Spinner:Hide();
		self:SetScript("OnEvent", oldOnEvent);
		self:SetScript("OnHide", oldOnHide);
		FrameUtil.UnregisterFrameForEvents(self, events);
		self:Hide();
	end

	self:SetScript("OnEvent", function(self, event, ...)
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
	self:SetScript("OnHide", function()
		if oldOnHide then
			oldOnHide(self);
		end
		OnComplete();
	end);

	return true;
end

function StaticPopup_HasDisplayedFrames()
	return #StaticPopup_DisplayedFrames > 0;
end

StaticPopupItemFrameMixin = {};

function StaticPopupItemFrameMixin:OnLoad()
	self:GetParent().itemFrame = self;
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
end

function StaticPopupItemFrameMixin:OnEvent(event, ...)
	if ( event == "GET_ITEM_INFO_RECEIVED" ) then
		local itemID = ...;
		if ( itemID == self.itemID ) then
			local data = self:GetParent().data;
			self:RetrieveInfo(data);
			self:DisplayInfo(data.link, data.name, data.color, data.texture, data.count);
		end
	end
end

function StaticPopupItemFrameMixin:OnEnter()
	if ( self.customOnEnter ) then
		self.customOnEnter(self);
	elseif ( self.link ) then
		local tooltip = self.tooltip or GameTooltip;
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		tooltip:SetHyperlink(self.link);
	end
end

function StaticPopupItemFrameMixin:OnLeave()
	local tooltip = self.tooltip or GameTooltip;
	tooltip:Hide();
end

function StaticPopupItemFrameMixin:SetCustomOnEnter(customOnEnter)
	self.customOnEnter = customOnEnter;
end

function StaticPopupItemFrameMixin:RetrieveInfo(data)
	local itemName, _, itemQuality, _, _, _, _, _, _, texture = C_Item.GetItemInfo(data.link);
	if ( itemName ) then
		data.name = itemName;
		local r, g, b = C_Item.GetItemQualityColor(itemQuality);
		data.color = {r, g, b, 1};
		data.texture = texture;
		self.itemID = nil;
	else
		local itemID, _, _, _, texture = C_Item.GetItemInfoInstant(data.link);
		data.name = RETRIEVING_ITEM_INFO;
		data.color = {RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1};
		data.texture = texture;
		self.itemID = itemID;
	end
end

function StaticPopupItemFrameMixin:DisplayInfo(link, name, color, texture, count, tooltip)
	self.link = link;
	self.tooltip = tooltip;
	_G[self:GetName().."IconTexture"]:SetTexture(texture);
	local nameText = _G[self:GetName().."Text"];
	nameText:SetTextColor(unpack(color or {1, 1, 1, 1}));
	nameText:SetText(name);

	if link then
		local quality = select(3, C_Item.GetItemInfo(link));
		SetItemButtonQuality(self, quality, link);
	end

	if ( count and count > 1 ) then
		_G[self:GetName().."Count"]:SetText(count);
		_G[self:GetName().."Count"]:Show();
	else
		_G[self:GetName().."Count"]:Hide();
	end
end
