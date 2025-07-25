GameDialogAlertTextureName = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew";

local function ShouldHideButton(dialog, buttonText, canShowButtonFunc)
	return not (buttonText and (not canShowButtonFunc or canShowButtonFunc(dialog, dialog.data)));
end

local function ShouldHideButtonFromDialogData(dialog, dialogInfo, index)
	if index == 1 then
		return ShouldHideButton(dialog, dialogInfo.button1, dialogInfo.DisplayButton1);
	elseif index == 2 then
		return ShouldHideButton(dialog, dialogInfo.button2, dialogInfo.DisplayButton2);
	elseif index == 3 then
		return ShouldHideButton(dialog, dialogInfo.button3, dialogInfo.DisplayButton3);
	elseif index == 4 then
		return ShouldHideButton(dialog, dialogInfo.button4, dialogInfo.DisplayButton4);
	end
	return true;
end

GameDialogMixin = {};

do
	local function SetupButton(dialog, button)
		button:SetOwningDialog(self);
		button:SetScript("OnClick", function(self, clickButton, down)
			assertsafe(clickButton == "LeftButton" and down == false);
			StaticPopup_OnClick(dialog, self:GetID());
		end);
	end

	function GameDialogMixin:OnLoad()
		self.BG.Top:SetAtlas(GameDialogBackgroundTop, TextureKitConstants.UseAtlasSize);
		self.BG.Bottom:SetAtlas("UI-DialogBox-Background-Dark", TextureKitConstants.UseAtlasSize);
		self.BG.Bottom:SetPoint("TOPLEFT", 7, -7);
		self.BG.Bottom:SetPoint("BOTTOMRIGHT", -7, 7);

		for buttonIndex, button in ipairs(self:GetButtons()) do
			SetupButton(self, button);
		end

		SetupButton(self, self.ExtraButton);

		self.Text:SetOwningDialog(self);
		self.EditBox:SetOwningDialog(self);

		self:RegisterEvent("DISPLAY_SIZE_CHANGED");

		if not self.reserved then
			StaticPopup_AddDialog(self);
		end
	end
end

do
	-- Moving this in stages. First pass is to get the text initialization out of :Init to improve readability.
	local PopupTextType = EnumUtil.MakeEnum("Default", "DeferredText", "DeferredSubText", "BillingNag", "SpellConfirmation", "ExpensiveAzeriteRespec", "ExpensiveAuctionBuyout");
	local whichToType =
	{
		["DEATH"] = PopupTextType.DeferredText,
		["CAMP"] = PopupTextType.DeferredText,
		["PLUNDERSTORM_LEAVE"] = PopupTextType.DeferredText,
		["QUIT"] = PopupTextType.DeferredText,
		["DUEL_OUTOFBOUNDS"] = PopupTextType.DeferredText,
		["RECOVER_CORPSE"] = PopupTextType.DeferredText,
		["RESURRECT"] = PopupTextType.DeferredText,
		["RESURRECT_NO_SICKNESS"] = PopupTextType.DeferredText,
		["INSTANCE_BOOT"] = PopupTextType.DeferredText,
		["GARRISON_BOOT"] = PopupTextType.DeferredText,
		["INSTANCE_LOCK"] = PopupTextType.DeferredText,
		["CONFIRM_SUMMON"] = PopupTextType.DeferredText,
		["CONFIRM_SUMMON_SCENARIO"] = PopupTextType.DeferredText,
		["CONFIRM_SUMMON_STARTING_AREA"] = PopupTextType.DeferredText,
		["BFMGR_INVITED_TO_ENTER"] = PopupTextType.DeferredText,
		["AREA_SPIRIT_HEAL"] = PopupTextType.DeferredText,
		["CONFIRM_REMOVE_COMMUNITY_MEMBER"] = PopupTextType.DeferredText,
		["CONFIRM_DESTROY_COMMUNITY_STREAM"] = PopupTextType.DeferredText,
		["ON_BATTLEFIELD_AUTO_QUEUE"] = PopupTextType.DeferredText,
		["ON_BATTLEFIELD_AUTO_QUEUE_EJECT"] = PopupTextType.DeferredText,
		["ON_WORLD_PVP_QUEUE"] = PopupTextType.DeferredText,
		["CONFIRM_RUNEFORGE_LEGENDARY_CRAFT"] = PopupTextType.DeferredText,
		["ANIMA_DIVERSION_CONFIRM_CHANNEL"] = PopupTextType.DeferredText,
		["PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING"] = PopupTextType.DeferredSubText,
		["BILLING_NAG"] = PopupTextType.BillingNag,
		["SPELL_CONFIRMATION_PROMPT"] = PopupTextType.SpellConfirmation,
		["SPELL_CONFIRMATION_WARNING"] = PopupTextType.SpellConfirmation,
		["SPELL_CONFIRMATION_PROMPT_ALERT"] = PopupTextType.SpellConfirmation,
		["SPELL_CONFIRMATION_WARNING_ALERT"] = PopupTextType.SpellConfirmation,
		["CONFIRM_AZERITE_EMPOWERED_RESPEC_EXPENSIVE"] = PopupTextType.ExpensiveAzeriteRespec,
		["BUYOUT_AUCTION_EXPENSIVE"] = PopupTextType.ExpensiveAuctionBuyout,
	};

	local textSetup =
	{
		[PopupTextType.Default] = function(dialog, dialogInfo, text_arg1, text_arg2, data)
			if dialogInfo.text == "" then
				dialog.Text:SetText(text_arg1);
			else
				dialog.Text:SetFormattedText(dialogInfo.text, text_arg1, text_arg2);
			end

			dialog.Text.text_arg1 = text_arg1;
			dialog.Text.text_arg2 = text_arg2;
		end,

		[PopupTextType.DeferredText] = function(dialog, dialogInfo, text_arg1, text_arg2, data)
			dialog.Text:SetText(" ");	-- The text will be filled in later.
			dialog.Text.text_arg1 = text_arg1;
			dialog.Text.text_arg2 = text_arg2;
		end,

		[PopupTextType.DeferredSubText] = function(dialog, dialogInfo, text_arg1, text_arg2, data)
			dialog.SubText:SetText(" ");	-- The text will be filled in later.
			dialog.SubText.text_arg1 = text_arg1;
			dialog.SubText.text_arg2 = text_arg2;
		end,

		[PopupTextType.BillingNag] = function(dialog, dialogInfo, text_arg1, text_arg2, data)
			dialog.Text:SetFormattedText(dialogInfo.text, text_arg1, MINUTES);
		end,

		[PopupTextType.SpellConfirmation] = function(dialog, dialogInfo, text_arg1, text_arg2, data)
			dialog.Text:SetText(text_arg1);
			dialogInfo.text = text_arg1;
			dialogInfo.timeout = text_arg2;
		end,

		[PopupTextType.ExpensiveAzeriteRespec] = function(dialog, dialogInfo, text_arg1, text_arg2, data)
			local separateThousands = true;
			local goldDisplay = GetMoneyString(data.respecCost, separateThousands);
			dialog.Text:SetFormattedText(dialogInfo.text, goldDisplay, text_arg1, CONFIRM_AZERITE_EMPOWERED_RESPEC_STRING);
		end,

		[PopupTextType.ExpensiveAuctionBuyout] = function(dialog, dialogInfo, text_arg1, text_arg2, data)
			local separateThousands = true;
			local goldDisplay = GetMoneyString(text_arg1, separateThousands);
			dialog.Text:SetFormattedText(dialogInfo.text, goldDisplay, BUYOUT_AUCTION_CONFIRMATION_STRING);
		end,
	};

	local function GetDialogTextSetup(which)
		return textSetup[whichToType[which] or PopupTextType.Default];
	end

	function GameDialogMixin:SetupText(which, text_arg1, text_arg2, data)
		self.Text:Show();

		local dialogInfo = StaticPopupDialogs[which];
		local setupFn = GetDialogTextSetup(which);
		setupFn(self, dialogInfo, text_arg1, text_arg2, data);

		self.SubText:SetShown(dialogInfo.subText ~= nil);
		if dialogInfo.subText then
			self.SubText:SetFontObject(dialogInfo.normalSizedSubText and "UserScaledFontGameNormal" or "UserScaledFontGameNormalSmall");
			StaticPopup_UpdateSubText(self, dialogInfo);
		end

		self:SetTextScripts(dialogInfo);
	end
end

function GameDialogMixin:SetupCloseButton(dialogInfo)
	self.CloseButton:SetShown(dialogInfo.closeButton);

	if dialogInfo.closeButton then
		if dialogInfo.closeButtonIsHide then
			self.CloseButton:SetNormalTexture(GameDialogCloseButtonStateNormal);
			self.CloseButton:SetPushedTexture(GameDialogCloseButtonStatePressed);
		else
			self.CloseButton:SetNormalTexture(GameDialogCloseButtonStateCondensedNormal);
			self.CloseButton:SetPushedTexture(GameDialogCloseButtonStateCondensedPressed);
		end
	end
end

function GameDialogMixin:OnCloseButtonClicked(button)
	if self.dialogInfo.OnCloseClicked then
		self.dialogInfo.OnCloseClicked(self, self.data);
	end

	self:Hide();
end

function GameDialogMixin:SetupInsertedFrame(insertedFrame)
	if insertedFrame then
		insertedFrame:SetParent(self);
	end
end

function GameDialogMixin:SetupEditBox(dialogInfo)
	-- Set the editbox of the dialog
	local editBox = self:GetEditBox();
	editBox:SetShown(dialogInfo.hasEditBox);
	if dialogInfo.hasEditBox then
		editBox.Instructions:SetText(dialogInfo.editBoxInstructions or "");

		if dialogInfo.maxLetters then
			editBox:SetMaxLetters(dialogInfo.maxLetters);
			editBox:SetCountInvisibleLetters(dialogInfo.countInvisibleLetters);
		end

		editBox:SetDesiredWidth(dialogInfo.editBoxWidth or editBox.baseWidth);

		editBox:SetSecureText(dialogInfo.editBoxSecureText);
		editBox.hasAutoComplete = dialogInfo.autoCompleteSource ~= nil;
		if editBox.hasAutoComplete then
			AutoCompleteEditBox_SetAutoCompleteSource(editBox, dialogInfo.autoCompleteSource, unpack(dialogInfo.autoCompleteArgs));
		else
			AutoCompleteEditBox_SetAutoCompleteSource(editBox, nil);
		end
	end
end

function GameDialogMixin:SetupDropdown(dialogInfo)
	self.Dropdown:SetShown(dialogInfo.hasDropdown);
end

function GameDialogMixin:SetupMoneyFrame(dialogInfo)
	-- The visibility of these was always mutually exclusive.
	self.MoneyFrame:SetShown(dialogInfo.hasMoneyFrame);
	self.MoneyInputFrame:SetShown(not dialogInfo.hasMoneyFrame and dialogInfo.hasMoneyInputFrame);

	local canSetUserScaled = dialogInfo.hasMoneyFrame and self.MoneyFrame.SetIsUseScaled ~= nil;
	if canSetUserScaled then
		self.MoneyFrame:SetIsUserScaled();
	end

	if dialogInfo.hasMoneyInputFrame then
		self.MoneyInputFrame:SetIsUserScaled();

		-- Set OnEnterPress for money input frames
		if dialogInfo.EditBoxOnEnterPressed then
			self.MoneyInputFrame.gold:SetScript("OnEnterPressed", StaticPopupEditBoxMixin.OnEnterPressed);
			self.MoneyInputFrame.silver:SetScript("OnEnterPressed", StaticPopupEditBoxMixin.OnEnterPressed);
			self.MoneyInputFrame.copper:SetScript("OnEnterPressed", StaticPopupEditBoxMixin.OnEnterPressed);
		else
			self.MoneyInputFrame.gold:SetScript("OnEnterPressed", nil);
			self.MoneyInputFrame.silver:SetScript("OnEnterPressed", nil);
			self.MoneyInputFrame.copper:SetScript("OnEnterPressed", nil);
		end
	end
end

function GameDialogMixin:SetupItemFrame(dialogInfo, data)
	local itemFrame = self:GetItemFrame();

	itemFrame.itemID = nil;
	itemFrame:SetShown(dialogInfo.hasItemFrame);

	if dialogInfo.hasItemFrame then
		if data and type(data) == "table" then
			itemFrame:SetCustomOnEnter(data.itemFrameOnEnter);

			local itemFrameCallback = data.itemFrameCallback;
			if itemFrameCallback then
				itemFrameCallback(itemFrame);
			else
				if data.useLinkForItemInfo then
					itemFrame:RetrieveInfo(data);
				end

				itemFrame:DisplayInfo(data.link, data.name, data.color, data.texture, data.count, data.tooltip);
			end
		end
	end
end

function GameDialogMixin:SetupButtons(dialogInfo, data)
	local buttons = {};
	for index, button in ipairs(self:GetButtons()) do
		local shouldShowButton = not ShouldHideButtonFromDialogData(self, dialogInfo, index);
		button:SetShown(shouldShowButton);
		button:ClearAllPoints();

		if shouldShowButton then
			table.insert(buttons, button);
			button:SetText(dialogInfo["button"..index]);
			button:Enable();

			if dialogInfo[("button%dPulse"):format(index)] then
				button.PulseAnim:Play();
			else
				button.PulseAnim:Stop();
			end
		end
	end

	self.visibleButtons = buttons;
	self.numButtons = #buttons;

	self.ButtonContainer:SetShown(self.numButtons > 0);
end

function GameDialogMixin:SetupAlertIcon(dialogInfo, data)
	local dataShowsAlert = (self.which == "GENERIC_CONFIRMATION") and data.showAlert;
	local dialogShowsAlert = dataShowsAlert or dialogInfo.showAlert;
	local showsAnyAlert = dialogShowsAlert or dialogInfo.showAlertGear or dialogInfo.customAlertIcon;
	self.AlertIcon:SetShown(showsAnyAlert);

	if dialogShowsAlert then
		self.AlertIcon:SetTexture(GameDialogAlertTextureName);
	elseif ( dialogInfo.showAlertGear ) then
		self.AlertIcon:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertOther");
	elseif ( dialogInfo.customAlertIcon ) then
		self.AlertIcon:SetTexture(dialogInfo.customAlertIcon);
	end
end

function GameDialogMixin:SetupStartDelay(dialogInfo)
	if dialogInfo.StartDelay then
		self.startDelay = dialogInfo.StartDelay(self);
		self:GetButton(1):SetEnabled(not self.startDelay or self.startDelay <= 0);
	elseif dialogInfo.acceptDelay then
		self.acceptDelay = dialogInfo.acceptDelay;
		self:GetButton(1):Disable();
	else
		self.startDelay = nil;
		self.acceptDelay = nil;
		self:GetButton(1):Enable();
	end
end

function GameDialogMixin:SetupExtraButton(dialogInfo)
	local hasExtraButton = dialogInfo.extraButton ~= nil;
	self.ExtraButton:SetShown(hasExtraButton);
	self.Separator:SetShown(hasExtraButton);

	if dialogInfo.extraButton then
		self.ExtraButton:SetText(dialogInfo.extraButton);

		--widen if too small, but reset to 128 otherwise, this seems wrong, what if the text width is 127, then there will be no padding.
		self.ExtraButton:SetDesiredWidth(math.max(128, self.ExtraButton:GetTextWidth() + 40));

		self:SetHeightPadding(self:GetHeightPadding() + 5);
	end
end

function GameDialogMixin:SetupProgressBar(dialogInfo)
	local hasProgressBar = dialogInfo.progressBar;
	self.ProgressBarBorder:SetShown(hasProgressBar);
	self.ProgressBarFill:SetShown(hasProgressBar);
	self.ProgressBarSpacer:SetShown(hasProgressBar);
end

function GameDialogMixin:SetupDecorationFrames(dialogInfo)
	-- TODO: Build a system so that we only need a single coverframe that always fills the screen and is only shown if at least one dialog that uses it is visible.
	-- CoverFrame doesn't need to be a child of each dialog
	local coverFrameParent = GetAppropriateTopLevelParent();
	self.CoverFrame:ClearAllPoints();
	self.CoverFrame:SetPoint("TOPLEFT", coverFrameParent, "TOPLEFT");
	self.CoverFrame:SetPoint("BOTTOMRIGHT", coverFrameParent, "BOTTOMRIGHT");
	self.CoverFrame:SetShown(dialogInfo.fullScreenCover);

	self.Spinner:Hide();
	self.DarkOverlay:Hide();
end

function GameDialogMixin:Init(which, text_arg1, text_arg2, data, insertedFrame)
	local dialogInfo = StaticPopupDialogs[which];
	assertsafe(dialogInfo == self.dialogInfo);

	self:SetHeightPadding(16); -- This is the base height padding, it's fixed, but other frames may modify it during setup.

	self:SetupDecorationFrames(dialogInfo);
	self:SetupText(which, text_arg1, text_arg2, data);
	self:SetupCloseButton(dialogInfo);
	self:SetupInsertedFrame(insertedFrame);
	self:SetupEditBox(dialogInfo);
	self:SetupDropdown(dialogInfo);
	self:SetupMoneyFrame(dialogInfo);
	self:SetupItemFrame(dialogInfo, data);
	self:SetupButtons(dialogInfo);
	self:SetupAlertIcon(dialogInfo, data);
	self:SetupStartDelay(dialogInfo);
	self:SetupExtraButton(dialogInfo);
	self:SetupProgressBar(dialogInfo);
	self:SetupElementAnchoring();
end

local function GetSubTextVerticalOffset(_previous, _current, dialog, dialogInfo)
	return dialogInfo.normalSizedSubText and -18 or -6;
end

local function GetSpacing_SubTextAfterItemFrame(previous, current, dialog, dialogInfo)
	return GetSubTextVerticalOffset(previous, current, dialog, dialogInfo);
end

local function GetSpacing_SubTextAfterText(previous, current, dialog, dialogInfo)
	return GetSubTextVerticalOffset(previous, current, dialog, dialogInfo);
end

local function GetSpacing_ButtonContainerAfterItemFrame(_previous, _current, dialog, dialogInfo)
	return dialogInfo.compactItemFrame and -9 or -18;
end

local function GetSpacing_ButtonsAfterText(_previous, _current, dialog, dialogInfo)
	-- Experimenting with this...not quite done yet
	-- If there are 3 or more buttons, then the buttons need to move further from the text, with additional experimentally derived checks against how many lines of text there are.
	if dialogInfo.button3 and dialog:GetButton(3):IsShown() then
		if dialogInfo.text and #dialogInfo.text < 45 then
			return -35;
		end

		return -20;
	end

	return -9;
end

local DialogElementLayout = CreateAndInitFromMixin(RegionLayoutManager, "None", "Any", 0);
DialogElementLayout:AddSpacingPair("Text", "SubText", GetSpacing_SubTextAfterText);
DialogElementLayout:AddSpacingPair("ItemFrame", "SubText", GetSpacing_SubTextAfterItemFrame);
DialogElementLayout:AddSpacingPair("Any", "ItemFrame", -16);
DialogElementLayout:AddSpacingPair("Text", "ItemFrame", -5);
DialogElementLayout:AddSpacingPair("Any", "insertedFrame", 0);
DialogElementLayout:AddSpacingPair("insertedFrame", "MoneyFrame", 0);
DialogElementLayout:AddSpacingPair("insertedFrame", "MoneyInputFrame", 0);
DialogElementLayout:AddSpacingPair("SubText", "MoneyFrame", -5);
DialogElementLayout:AddSpacingPair("SubText", "MoneyInputFrame", -5);
DialogElementLayout:AddSpacingPair("Text", "MoneyFrame", -5);
DialogElementLayout:AddSpacingPair("Text", "MoneyInputFrame", -5);
DialogElementLayout:AddSpacingPair("Any", "EditBox", -8);
DialogElementLayout:AddSpacingPair("SubText", "EditBox", -10);
DialogElementLayout:AddSpacingPair("Any", "Dropdown", -5);
DialogElementLayout:AddSpacingPair("Any", "ButtonContainer", -9);
DialogElementLayout:AddSpacingPair("Text", "ButtonContainer", GetSpacing_ButtonsAfterText);
DialogElementLayout:AddSpacingPair("ItemFrame", "ButtonContainer", GetSpacing_ButtonContainerAfterItemFrame);
DialogElementLayout:AddSpacingPair("EditBox", "ButtonContainer", -12);
DialogElementLayout:AddSpacingPair("ButtonContainer", "ProgressBarSpacer", 8);

function GameDialogMixin:SetupAnchor(regionKey)
	local previousRegion = self[self.previousRegionKey];
	local region = self[regionKey];

	if region and region:IsShown() then
		local offsetY = DialogElementLayout:GetSpacing(self.previousRegionKey, regionKey, self, self.dialogInfo);

		region:ClearAllPoints();

		if previousRegion then
			region:SetPoint("TOP", previousRegion, "BOTTOM", 0, offsetY);
		else
			region:SetPoint("TOP", self, "TOP", 0, offsetY);
		end

		self.previousRegionKey = regionKey;
	end
end

function GameDialogMixin:SetupElementAnchoring()
	local dialogInfo = self.dialogInfo;

	self.previousRegionKey = "Text";

	local itemFrameAboveSubText = dialogInfo.itemFrameAboveSubtext and dialogInfo.hasItemFrame and dialogInfo.subText;

	if itemFrameAboveSubText then
		self:SetupAnchor("ItemFrame");
		self:SetupAnchor("SubText");
	else
		self:SetupAnchor("SubText");
		self:SetupAnchor("ItemFrame");
	end

	-- NOTE: This assumes that we will never have item frames with inserted frames.
	self:SetupAnchor("insertedFrame");

	self:SetupAnchor("MoneyFrame");
	self:SetupAnchor("MoneyInputFrame");
	self:SetupAnchor("Dropdown");
	self:SetupAnchor("EditBox");

	local buttons = self.visibleButtons;
	if #buttons > 0 then
		self:SetupAnchor("ButtonContainer");

		buttons[1]:ClearAllPoints();
		buttons[1]:SetPoint("TOPLEFT", self.ButtonContainer);

		for index = 2, #buttons do
			buttons[index]:ClearAllPoints();
			buttons[index]:SetPoint("BOTTOMLEFT", buttons[index-1], "BOTTOMRIGHT", 10, 0);
		end
	end

	self:SetupAnchor("ProgressBarSpacer");

	-- There's no need to set up the extra button or separator because they're always anchored to the bottom of the button container.
end

function GameDialogMixin:GetItemFrame()
	return self.ItemFrame;
end

function GameDialogMixin:GetEditBox()
	return self.EditBox;
end

function GameDialogMixin:GetButton1()
	return self:GetButton(1);
end

function GameDialogMixin:GetButton2()
	return self:GetButton(2);
end

function GameDialogMixin:GetButton3()
	return self:GetButton(3);
end

function GameDialogMixin:GetButton4()
	return self:GetButton(4);
end

function GameDialogMixin:GetButton(index)
	return self.ButtonContainer.Buttons[index];
end

function GameDialogMixin:GetButtons()
	return self.ButtonContainer.Buttons;
end

function GameDialogMixin:GetExtraFrame()
	return self.ExtraFrame;
end

function GameDialogMixin:GetTextFontString()
	return self.Text;
end

local function GetDesiredTextWidth(dialogInfo)
	return dialogInfo.wideText and 360 or 290;
end

local STATIC_POPUP_BUTTON_TEXT_MARGIN_SIZE = 20;

function GameDialogMixin:GetButtonSizeInfo()
	-- We want all buttons to be the same size if that's possible
	-- Use the largest text length to drive the size of all buttons.
	-- If the total button width is smaller than the "base" width of the dialog, then use that size.
	-- Otherwise, each button will be different sizes, preferring the larger of minSize and the button's text width.
	-- NOTE: There are also some padding checks included in these calculations.
	-- This function returns a possible width to use, and a bool to indicate whether or not to use math.max(width, textWidth)

	local buttons = self.visibleButtons;
	local minButtonWidth = 120;
	local maxButtonWidth = minButtonWidth;
	for index, button in ipairs(buttons) do
		local buttonWidth = button:GetTextWidth() + STATIC_POPUP_BUTTON_TEXT_MARGIN_SIZE;
		maxButtonWidth = math.max(maxButtonWidth, buttonWidth);
	end

	local buttonPadding = 10;
	local totalButtonPadding = (#buttons - 1) * buttonPadding;
	local totalButtonWidth = #buttons * maxButtonWidth;
	local uncondensedTotalWidth = totalButtonWidth + totalButtonPadding;
	if uncondensedTotalWidth < self:GetMinimumWidth() then
		return maxButtonWidth, false;
	end

	return minButtonWidth, true;
end

local function GetDesiredSubTextWidth(dialogInfo)
	if dialogInfo.wideText then
		return 360;
	end

	return dialogInfo.normalSizedSubText and 270 or 290;
end

function GameDialogMixin:Resize()
	local dialogInfo = self.dialogInfo;
	assertsafe(dialogInfo ~= nil);

	if not dialogInfo then
		return;
	end

	local initialWidth = self:GetInitialWidth(dialogInfo);
	self:SetWidthPadding(0);
	self:SetMinimumWidth(initialWidth);

	local buttons = self.visibleButtons;
	local desiredButtonWidth, useMaxOfWidthOrButtonTextWidth = self:GetButtonSizeInfo();

	for index, button in ipairs(buttons) do
		local buttonWidth = desiredButtonWidth;
		if useMaxOfWidthOrButtonTextWidth then
			buttonWidth = math.max(buttonWidth, button:GetTextWidth()) + STATIC_POPUP_BUTTON_TEXT_MARGIN_SIZE;
		end

		button:SetDesiredWidth(buttonWidth);
	end

	local desiredTextWidth = GetDesiredTextWidth(dialogInfo);
	self.Text:SetDesiredWidth(desiredTextWidth);
	self.SubText:SetDesiredWidth(GetDesiredSubTextWidth(dialogInfo));

	-- Through a lot of hardcoded calculations because the source of truth is in several different places
	-- The size ratio of dialog:text is 320 / 290 ~= 1.103448
	-- This is for mainline...at a user scaled text size of 1, this all works out by default so that the dialog has enough
	-- padding. In an effort to keep dialogs appearing as close to the old versions as possible, we're going to maintain that
	-- appearance by default, but keep in mind that the dialog size in the original verison was never driven by the text size
	-- In the user-scaled versions, we'll attempt to keep that padding ratio such that if the desired text size ends up larger
	-- than the initial dialog size, then the dialog will change its minimum width to account for that.
	-- Also, keep in mind that the padding ratio is SPECIFICALLY for default dialogs, not for vertical button layout, alert dialogs,
	-- or dialogs with close buttons, so there will likely need to be some custom scales if we don't just convert the whole system
	-- to use custom width padding.
	local desiredTextWidthScaled = self.Text:GetScaledDesiredWidth(); -- this is post-scaling
	local paddingRatio = initialWidth / desiredTextWidth; -- Default is about 1.103448
	local dialogMinimumWidth = desiredTextWidthScaled * paddingRatio;
	self:SetMinimumWidth(dialogMinimumWidth);

	if dialogInfo.height then
		self:SetFixedHeight(dialogInfo.height);
	end

	-- Yes, this double layout is a sin, no I don't know why it's required yet.
	-- It only seems to be required when doing a TextSizeManager scale update when the dialog is shown.
	self:Layout();
	self:Layout();

	-- There's a dependency issue where the buttons need to resize inside their own container to determine its width
	-- The dialog needs padding if any contained element is the same width as the current dialog.

	if self.ButtonContainer:IsShown() then
		local DIALOG_HORIZONTAL_MARGIN = 16;
		local delta = self.ButtonContainer:GetLeft() - (self:GetLeft() + DIALOG_HORIZONTAL_MARGIN);

		if delta < 0 then
			self:SetWidthPadding(-delta * 2);
		else
			self:SetWidthPadding(0);
		end
	else
		self:SetWidthPadding(0);
	end

	self:Layout();
end

function GameDialogMixin:SetText(text)
	self.Text:SetText(text);
end

function GameDialogMixin:GetText(text)
	return self.Text:GetText();
end

function GameDialogMixin:SetFormattedText(...)
	self.Text:SetFormattedText(...);
end

function GameDialogMixin:OnUpdate(elapsed)
	StaticPopup_OnUpdate(self, elapsed);
	BaseLayoutMixin.OnUpdate(self);
end

function GameDialogMixin:OnEvent(...)
	if self:IsVisible() then
		self:Resize();
	end
end

function GameDialogMixin:OnShow()
	StaticPopup_OnShow(self);

	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);

	local dialogInfo = StaticPopupDialogs[self.which];
	if dialogInfo.hasMoneyInputFrame then
		self.MoneyInputFrame.gold:SetFocus();
	end
end

function GameDialogMixin:OnHide()
	StaticPopup_OnHide(self);

	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);

	self.MoneyFrame:ClearAllPoints();
	self.MoneyInputFrame:ClearAllPoints();
	self:ClearTextScripts();
end

function GameDialogMixin:ClearTextScripts()
	self.Text:SetScript("OnEnter", nil);
	self.Text:SetScript("OnLeave", nil);
end

function GameDialogMixin:SetTextScripts(dialogInfo)
	self.Text:SetScript("OnEnter", dialogInfo.textOnEnterScript);
	self.Text:SetScript("OnLeave", dialogInfo.textOnLeaveScript);
end

function GameDialogMixin:OnHyperlinkClick(...)
	StaticPopup_OnHyperlinkClick(self, ...);
end

function GameDialogMixin:OnHyperlinkEnter(...)
	StaticPopup_OnHyperlinkEnter(self, ...);
end

function GameDialogMixin:OnHyperlinkLeave(...)
	StaticPopup_OnHyperlinkLeave(self, ...);
end

StaticPopupItemFrameMixin = {};

function StaticPopupItemFrameMixin:OnLoad()
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
		local itemID, _;
		itemID, _, _, _, texture = C_Item.GetItemInfoInstant(data.link);
		data.name = RETRIEVING_ITEM_INFO;
		data.color = {RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1};
		data.texture = texture;
		self.itemID = itemID;
	end
end

function StaticPopupItemFrameMixin:DisplayInfo(link, name, color, texture, count, tooltip)
	self.link = link;
	self.tooltip = tooltip;

	SetItemButtonTexture(self.Item, texture);

	self.Text:SetTextColor(unpack(color or {1, 1, 1, 1}));
	self.Text:SetText(name);

	if link then
		local quality = select(3, C_Item.GetItemInfo(link));
		SetItemButtonQuality(self.Item, quality, link);
	end

	local hasCount = count and count > 1;
	self.Item.Count:SetShown(hasCount);

	if hasCount then
		self.Item.Count:SetText(count);
	end
end

function StaticPopupItemFrameMixin:DisplayInfoFromStandardCallback(location, name, quality, count)
	name = name or C_Item.GetItemName(location);
	quality = quality or C_Item.GetItemQuality(location);
	count = count or 0;

	self.Item:SetItemLocation(location);
	SetItemButtonQuality(self.Item, quality);

	local colorData = ColorManager.GetColorDataForItemQuality(quality);
	if colorData then
		self.Text:SetTextColor(colorData.color:GetRGB());
	end

	self.Text:SetText(name);

	self.Item.Count:SetShown(count > 1);
	if count > 1 then
		self.Item.Count:SetText(tostring(count));
	end
end

StaticPopup_AddShowCondition(function(dialogInfo, data)
	if not dialogInfo.whileDead and UnitIsDeadOrGhost("player") then
		return false;
	end
	return true;
end);


function GameDialog_MoneyFrameOnLoad(self)
	SmallMoneyFrame_OnLoad(self);
	MoneyFrame_SetType(self, "STATIC");
end
