KEY_BINDINGS_DISPLAYED = 21;
KEY_BINDING_HEIGHT = 25;
KEY_BINDING_ROW_NAME = "KeyBindingFrameKeyBinding";

DEFAULT_BINDINGS = 0;
ACCOUNT_BINDINGS = 1;
CHARACTER_BINDINGS = 2;

UIPanelWindows["KeyBindingFrame"] = { area = "center", pushable = 0, whileDead = 1 };

StaticPopupDialogs["CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS"] = {
	text = CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		AttemptToSaveBindings(KeyBindingFrame.which);
		KeyBindingFrame.outputText:SetText("");
		KeyBindingFrame_SetSelected(nil);
		HideUIPanel(KeyBindingFrame);
		CONFIRMED_DELETING_CHARACTER_SPECIFIC_BINDINGS = 1;
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

StaticPopupDialogs["CONFIRM_LOSE_BINDING_CHANGES"] = {
	text = CONFIRM_LOSE_BINDING_CHANGES,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		KeyBindingFrame_ChangeBindingProfile();
		KeyBindingFrame.bindingsChanged = nil;
	end,
	OnCancel = function(self)
		if ( KeyBindingFrame.characterSpecificButton:GetChecked() ) then
			KeyBindingFrame.characterSpecificButton:SetChecked();
		else
			KeyBindingFrame.characterSpecificButton:SetChecked(true);
		end
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

StaticPopupDialogs["CONFIRM_RESET_TO_DEFAULT_KEYBINDINGS"] = {
	text = CONFIRM_RESET_KEYBINDINGS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		KeyBindingFrame_ResetBindingsToDefault();
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1
};

function KeyBindingFrame_OnLoad(self)
	self:RegisterForClicks("AnyUp");
	KeyBindingFrame.scrollOffset = 0;
	KeyBindingFrame_SetSelected(nil);
	KeyBindingFrame_LoadCategories(self);
	KeyBindingFrame_LoadKeyBindingButtons(self);

	self:RegisterEvent("ADDON_LOADED");
end

function KeyBindingFrame_OnEvent(self, event, ...)
	if (event == "ADDON_LOADED") then
		KeyBindingFrame_LoadCategories(self);
	end
end

local defaultCategories = { BINDING_HEADER_MOVEMENT,
							BINDING_HEADER_CHAT,
							BINDING_HEADER_ACTIONBAR,
							BINDING_HEADER_MULTIACTIONBAR,
							BINDING_HEADER_TARGETING,
							BINDING_HEADER_INTERFACE,
							BINDING_HEADER_MISC,
							BINDING_HEADER_CAMERA,
							BINDING_HEADER_RAID_TARGET,
							BINDING_HEADER_VEHICLE,
							BINDING_HEADER_DEBUG,
							BINDING_HEADER_MOVIE_RECORDING_SECTION };

function KeyBindingFrame_LoadCategories(self)
	local keyBindingCategories = {};
	local otherCategory = nil;
	OptionsList_ClearSelection(KeyBindingFrame.categoryList, KeyBindingFrame.categoryList.buttons);

	for i = 1, GetNumBindings() do
		local commandName, category, binding1, binding2 = GetBinding(i, self.mode);

		if ( not category ) then
			--If there is no category name for the category of this keyBinding, put this
			--keyBinding into the default "Other" category.
			category = BINDING_HEADER_OTHER;

			otherCategory = otherCategory or {};

			tinsert(otherCategory, i);
		else
			--Check for global string values for category names.
			category = _G[category] or category;

			keyBindingCategories[category] = keyBindingCategories[category] or {};

			tinsert(keyBindingCategories[category], i);
		end
	end

	local categoryButtons = self.categoryList.buttons;
	local nextCategory = 1;

	for i = 1, #defaultCategories do
		local categoryName = defaultCategories[i];
		if ( keyBindingCategories[categoryName] ~= nil ) then
			local element = { ["name"] = categoryName, ["category"] = keyBindingCategories[categoryName] };
			OptionsList_DisplayButton(categoryButtons[nextCategory], element);
			keyBindingCategories[categoryName] = nil;
			nextCategory = nextCategory + 1;
		end
	end

	for key, value in pairs(keyBindingCategories) do
		if ( nextCategory < #categoryButtons ) then
			local element = { ["name"] = key, ["category"] = keyBindingCategories[key] };
			OptionsList_DisplayButton(categoryButtons[nextCategory], element);
			nextCategory = nextCategory + 1;
		end
	end

	if ( otherCategory ) then
		local element = { ["name"] = BINDING_HEADER_OTHER, ["category"] = otherCategory };
		OptionsList_DisplayButton(categoryButtons[nextCategory], element);
		nextCategory = nextCategory + 1;
	end

	for i = nextCategory, #categoryButtons do
		OptionsList_HideButton(categoryButtons[i]);
	end

	local defaultButton = categoryButtons[1];
	self.cntCategory = defaultButton.element.category;
	OptionsList_SelectButton(defaultButton:GetParent(), defaultButton);
end

function KeyBindingFrame_LoadKeyBindingButtons(self)
	local previousRow = CreateFrame("FRAME", KEY_BINDING_ROW_NAME.."1", KeyBindingFrame, "KeyBindingFrameBindingTemplate");
	previousRow:SetPoint("TOP", 100, -78);
	previousRow.key1Button.buttonIndex = 1;
	previousRow.key1Button.rowIndex = 1;
	previousRow.key2Button.buttonIndex = 2;
	previousRow.key2Button.rowIndex = 1;
	self.keyBindingRows = { previousRow };

	for i = 2, KEY_BINDINGS_DISPLAYED do
		local newRow = CreateFrame("FRAME", KEY_BINDING_ROW_NAME..i, KeyBindingFrame, "KeyBindingFrameBindingTemplate");
		newRow:SetPoint("TOP", previousRow, "BOTTOM", 0, 2);
		newRow.key1Button.buttonIndex = 1;
		newRow.key1Button.rowIndex = i;
		newRow.key2Button.buttonIndex = 2;
		newRow.key2Button.rowIndex = i;
		self.keyBindingRows[i] = newRow;

		previousRow = newRow;
	end
end

function KeyBindingFrame_OnShow(self)
	KeyBindingFrame.mode = 1;
	KeyBindingFrame_Update();

	-- Update character button
	KeyBindingFrame.characterSpecificButton:SetChecked(GetCurrentBindingSet() == 2);

	KeyBindingFrame_UpdateHeaderText();

	-- Reset bindingsChanged
	KeyBindingFrame.bindingsChanged = nil;

	Disable_BagButtons();
	UpdateMicroButtons();
end

local function CreatePushToTalkBindingButton()
	local button;
	local handler = CustomBindingHandler:CreateHandler(Enum.CustomBindingType.VoicePushToTalk);

	handler:SetOnBindingModeActivatedCallback(function(isActive)
		if isActive then
			KeyBindingFrame.buttonPressed = button;
			KeyBindingFrame_SetSelected("TOGGLE_VOICE_PUSH_TO_TALK", button);
			KeyBindingFrame_UpdateUnbindKey();
			KeyBindingFrame.outputText:SetFormattedText(BIND_KEY_TO_COMMAND, GetBindingName("TOGGLE_VOICE_PUSH_TO_TALK"));
		end
	end);

	handler:SetOnBindingCompletedCallback(function(completedSuccessfully, keys)
		KeyBindingFrame_SetSelected(nil);

		if completedSuccessfully then
			KeyBindingFrame.outputText:SetText(KEY_BOUND);
		else
			KeyBindingFrame.outputText:SetText("");
		end

		if completedSuccessfully and keys then
			DisplayUniversalAccessDialogIfRequiredForVoiceChatKeybind(keys);
		end
	end);

	button = CustomBindingManager:RegisterHandlerAndCreateButton(handler, "CustomBindingButtonTemplate", KeyBindingFrame);
	return button;
end

local customKeybindings = {};

local function GetOrCreateCustomKeybindingButton(customBindingType)
	local button = customKeybindings[customBindingType]
	if not button then
		if customBindingType == Enum.CustomBindingType.VoicePushToTalk then
			button = CreatePushToTalkBindingButton();
		end

		customKeybindings[customBindingType] = button;
	end

	return button;
end

local function HideAllCustomButtons()
	for customBindingType, button in pairs(customKeybindings) do
		button:Hide();
	end
end

local function HandleCustomKeybindingsDismissed(shouldSave)
	for customBindingType in pairs(customKeybindings) do
		CustomBindingManager:OnDismissed(customBindingType, shouldSave);
	end
end

function KeyBindingFrame_Update()
	local self = KeyBindingFrame;
	local cntCategory = self.cntCategory;
	local numBindings = #cntCategory;
	local keyOffset = FauxScrollFrame_GetOffset(KeyBindingFrameScrollFrame);

	if ( self.selected ) then
		local offsetDifference = self.scrollOffset - keyOffset;
		if ( offsetDifference ~= 0 ) then
			self.selectedRowIndex = self.selectedRowIndex + offsetDifference;
			if ( self.selectedRowIndex > 0 and self.selectedRowIndex <= #self.keyBindingRows ) then
				local button;
				if ( self.selectedButtonIndex == 1 ) then
					button = self.keyBindingRows[self.selectedRowIndex].key1Button;
				else
					button = self.keyBindingRows[self.selectedRowIndex].key2Button;
				end
				KeyBindingFrame_SetSelected(self.selected, button);
			else
				KeyBindingFrame_SetSelected(self.selected, nil);
			end
		end
	end

	HideAllCustomButtons();

	self.scrollOffset = keyOffset;

	for i=1, KEY_BINDINGS_DISPLAYED, 1 do
		keyOffset = keyOffset + 1;
		local keyBindingRow = self.keyBindingRows[i];
		if ( keyOffset <= numBindings ) then
			local keyBindingButton1 = keyBindingRow.key1Button;
			local keyBindingButton2 = keyBindingRow.key2Button;
			local keyBindingDescription = keyBindingRow.description;
			-- Set binding text
			local commandName, category, binding1, binding2 = GetBinding(cntCategory[keyOffset], self.mode);
			local customBindingType = C_KeyBindings.GetCustomBindingType(cntCategory[keyOffset]);
			local customButton = customBindingType and GetOrCreateCustomKeybindingButton(customBindingType);
			local headerText = keyBindingRow.header;
			local isHeader = strsub(commandName, 1, 6) == "HEADER";

			headerText:SetShown(isHeader);
			keyBindingButton1:SetShown(not isHeader and not customButton);
			keyBindingButton2:SetShown(not isHeader);
			keyBindingButton2:SetEnabled(not customButton);
			keyBindingDescription:SetShown(not isHeader);

			keyBindingButton1.commandName = commandName;
			keyBindingButton2.commandName = commandName;

			if ( isHeader ) then
				headerText:SetText(_G["BINDING_"..commandName]);
			else
				if customBindingType ~= nil then
					binding1, binding2 = nil, nil;
				end

				BindingButtonTemplate_SetupBindingButton(binding1, keyBindingButton1);
				BindingButtonTemplate_SetupBindingButton(binding2, keyBindingButton2);

				keyBindingDescription:SetText(GetBindingName(commandName));
				keyBindingRow:Show();

				if customButton then
					BindingButtonTemplate_SetupBindingButton(nil, customButton);

					customButton:ClearAllPoints();
					customButton:SetAllPoints(keyBindingButton1);
					customButton:Show();
				end
			end
		else
			keyBindingRow:Hide();
		end
	end

	-- Scroll frame stuff
	FauxScrollFrame_Update(KeyBindingFrameScrollFrame, numBindings, KEY_BINDINGS_DISPLAYED, KEY_BINDING_HEIGHT );

	-- Update Unbindkey button
	KeyBindingFrame_UpdateUnbindKey();
end

function KeyBindingFrame_OnHide(self)
	ShowUIPanel(GameMenuFrame);
	KeyBindingFrame.outputText:SetText("");
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT);
	UpdateMicroButtons();
end

function KeyBindingFrame_UnbindKey(keyPressed, selectedAction, bindingMode)
	local keyBindMessage;
	local oldAction = GetBindingAction(keyPressed, bindingMode);
	if oldAction ~= "" and oldAction ~= selectedAction then
		local key1, key2 = GetBindingKey(oldAction, bindingMode);
		if (not key1 or key1 == keyPressed) and (not key2 or key2 == keyPressed) then
			--Notification message
			keyBindMessage = KEY_UNBOUND_ERROR:format(GetBindingName(oldAction))
			KeyBindingFrame.outputText:SetText(keyBindMessage);
		end
	end
	SetBinding(keyPressed, nil, bindingMode);

	return keyBindMessage;
end

local function ClearBindingsForKeys(bindingMode, ...)
	for i = 1, select("#", ...) do
		local key = select(i, ...);
		if key then
			SetBinding(key, nil, bindingMode);
		end
	end
end

local function RebindKeysInOrder(keyPressed, keybindButtonID, selectedAction, bindingMode, ...)
	local keyBindMessage;

	for i = 1, select("#", ...) do
		local currentKey = select(i, ...);
		local keyToBind = (i == keybindButtonID) and keyPressed or currentKey;

		if keyToBind then
			keyBindMessage = KeyBindingFrame_SetBinding(keyToBind, selectedAction, bindingMode, currentKey) or keyBindMessage;
		end
	end

	return keyBindMessage;
end

-- NOTE: preventKeybindingFrameBehavior being true indicates that all the code specific to the keybind frame shouldn't be run.
-- The default behavior is to be called from the keybinding frame.
-- This function returns true if it tried to bind something, and false otherwise.  Its secondary return is a feedback/status message.
function KeyBindingFrame_AttemptKeybind(self, keyOrButton, selectedAction, bindingMode, keybindButtonID, preventKeybindingFrameBehavior)
	local keyBindFeedbackMessage;
	local wasSomethingBound = false;

	if GetBindingFromClick(keyOrButton) == "SCREENSHOT" then
		RunBinding("SCREENSHOT");
	elseif selectedAction then
		local keyPressed = GetConvertedKeyOrButton(keyOrButton);

		if not IsKeyPressIgnoredForBinding(keyPressed) then
			keyPressed = CreateKeyChordString(keyPressed);

			-- Unbind the current action
			local key1, key2 = GetBindingKey(selectedAction, bindingMode)
			ClearBindingsForKeys(bindingMode, key1, key2);

			-- Unbind the current key and rebind current action
			if not preventKeybindingFrameBehavior then
				keyBindFeedbackMessage = KEY_BOUND;
				KeyBindingFrame.outputText:SetText(KEY_BOUND);
			end

			keyBindFeedbackMessage = KeyBindingFrame_UnbindKey(keyPressed, selectedAction, bindingMode) or keyBindFeedbackMessage;
			local rebindingMessage = RebindKeysInOrder(keyPressed, keybindButtonID, selectedAction, bindingMode, key1, key2);
			if not keyBindFeedbackMessage then
				keyBindFeedbackMessage = rebindingMessage;
			end

			if not preventKeybindingFrameBehavior then
				KeyBindingFrame_Update();
				-- Button highlighting stuff
				KeyBindingFrame_SetSelected(nil);
				KeyBindingFrame.buttonPressed:UnlockHighlight();
				KeyBindingFrame.bindingsChanged = 1;

				KeyBindingFrame_UpdateUnbindKey();
			end

			wasSomethingBound = true;
		end
	elseif (not preventKeybindingFrameBehavior) and GetBindingFromClick(keyOrButton) == "TOGGLEGAMEMENU" then
		KeyBindingFrame_CancelBinding(self);
	end

	return wasSomethingBound, keyBindFeedbackMessage;
end

function KeyBindingFrame_OnKeyDown(self, keyOrButton)
	return KeyBindingFrame_AttemptKeybind(self, keyOrButton, KeyBindingFrame.selected, KeyBindingFrame.mode, KeyBindingFrame.keyID);
end

function KeyBindingFrame_SetBinding(key, selectedAction, bindingMode, oldKey)
	local keyBindMessage;

	if not SetBinding(key, selectedAction, bindingMode) then
		if oldKey then
			SetBinding(oldKey, selectedAction, bindingMode);
		end

		--Error message
		keyBindMessage = KEYBINDINGFRAME_MOUSEWHEEL_ERROR;
		KeyBindingFrame.outputText:SetText(keyBindMessage);
	end

	return keyBindMessage;
end

function KeyBindingFrame_UpdateUnbindKey()
	if ( KeyBindingFrame.selected ) then
		KeyBindingFrame.unbindButton:Enable();
	else
		KeyBindingFrame.unbindButton:Disable();
	end
end

function KeyBindingFrame_UpdateHeaderText()
	if ( KeyBindingFrame.characterSpecificButton:GetChecked() ) then
		KeyBindingFrame.header.text:SetFormattedText(CHARACTER_KEY_BINDINGS, UnitName("player"));
	else
		KeyBindingFrame.header.text:SetText(KEY_BINDINGS);
	end
	KeyBindingFrame.header:SetWidth(KeyBindingFrame.header.text:GetWidth() + 80);
end

function KeyBindingFrame_ChangeBindingProfile()
	if ( KeyBindingFrame.characterSpecificButton:GetChecked() ) then
		LoadBindings(CHARACTER_BINDINGS);
	else
		LoadBindings(ACCOUNT_BINDINGS);
	end
	KeyBindingFrame_UpdateHeaderText();
	KeyBindingFrame.outputText:SetText("");
	KeyBindingFrame_SetSelected(nil);
	KeyBindingFrame_Update();
end

function KeyBindingFrame_SetSelected(value, keyBindingButton)
	local previousButton = KeyBindingFrame.selectedButton;

	KeyBindingFrame.selectedButton = nil;
	KeyBindingFrame.selected = value;

	if previousButton then
		BindingButtonTemplate_SetSelected(previousButton, false);

		if previousButton.GetCustomBindingType and previousButton:GetCustomBindingType() ~= nil then
			previousButton:CancelBinding();
		end
	end

	if keyBindingButton then
		BindingButtonTemplate_SetSelected(keyBindingButton, true);

		KeyBindingFrame.selectedButton = keyBindingButton;
		KeyBindingFrame.selectedButtonIndex = keyBindingButton.buttonIndex;
		KeyBindingFrame.selectedRowIndex = keyBindingButton.rowIndex;
	end
end

function KeyBindingFrame_OnMouseWheel(self, delta)
	if ( self.selected ) then
		if ( delta > 0 ) then
			KeyBindingFrame_OnKeyDown(self, "MOUSEWHEELUP");
		else
			KeyBindingFrame_OnKeyDown(self, "MOUSEWHEELDOWN");
		end
	end
end

function KeyBindingButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if ( KeyBindingFrame.selected ) then
		-- Code to be able to deselect or select another key to bind
		if ( button == "LeftButton" or button == "RightButton" ) then
			-- Deselect button if it was the pressed previously pressed
			if (KeyBindingFrame.buttonPressed == self) then
				KeyBindingFrame_SetSelected(nil);
				KeyBindingFrame.outputText:SetText("");
			else
				-- Select a different button
				KeyBindingFrame.buttonPressed = self;
				KeyBindingFrame_SetSelected(self.commandName, self);
				KeyBindingFrame.keyID = self:GetID();
				KeyBindingFrame.outputText:SetFormattedText(BIND_KEY_TO_COMMAND, GetBindingName(self.commandName));
			end
			KeyBindingFrame_Update();
			return;
		end
		KeyBindingFrame_OnKeyDown(self, button);
	else
		if (KeyBindingFrame.buttonPressed) then
			KeyBindingFrame.buttonPressed:UnlockHighlight();
		end
		KeyBindingFrame.buttonPressed = self;
		KeyBindingFrame_SetSelected(self.commandName, self);
		KeyBindingFrame.keyID = self:GetID();
		KeyBindingFrame.outputText:SetFormattedText(BIND_KEY_TO_COMMAND, GetBindingName(self.commandName));
		KeyBindingFrame_Update();
	end
	KeyBindingFrame_UpdateUnbindKey();
end

function KeybindingsCategoryListButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	OptionsList_ClearSelection(KeyBindingFrame.categoryList, KeyBindingFrame.categoryList.buttons);
	OptionsList_SelectButton(self:GetParent(), self);

	KeyBindingFrame.cntCategory = self.element.category;
	KeyBindingFrame_SetSelected(nil);
	KeyBindingFrame.outputText:SetText("");
	KeyBindingFrameScrollFrame.ScrollBar:SetValue(0);
	KeyBindingFrame_Update();
end

function CharacterSpecificButton_OnLoad(self)
	self.text:SetText(HIGHLIGHT_FONT_COLOR_CODE..CHARACTER_SPECIFIC_KEYBINDINGS..FONT_COLOR_CODE_CLOSE);
end

function CharacterSpecificButton_OnClick(self)
	if (self.enabled) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	if ( KeyBindingFrame.bindingsChanged ) then
		StaticPopup_Show("CONFIRM_LOSE_BINDING_CHANGES");
	else
		KeyBindingFrame_ChangeBindingProfile();
	end
end

function CharacterSpecificButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP, nil, nil, nil, nil, true);
end

function CharacterSpecificButton_OnHide(self)
	GameTooltip_Hide();
end

function UnbindButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local button = KeyBindingFrame.selectedButton;
	local customBindingType = button.GetCustomBindingType and button:GetCustomBindingType();
	if customBindingType ~= nil then
		CustomBindingManager:Unbind(customBindingType);
		BindingButtonTemplate_SetupBindingButton(nil, button);
	else
		local key1, key2 = GetBindingKey(KeyBindingFrame.selected, KeyBindingFrame.mode);
		if ( key1 ) then
			SetBinding(key1, nil, KeyBindingFrame.mode);
		end
		if ( key2 ) then
			SetBinding(key2, nil, KeyBindingFrame.mode);
		end
		if ( key1 and KeyBindingFrame.keyID == 1 ) then
			KeyBindingFrame_SetBinding(key1, nil, KeyBindingFrame.mode, key1);
			if ( key2 ) then
				KeyBindingFrame_SetBinding(key2, KeyBindingFrame.selected, KeyBindingFrame.mode, key2);
			end
		else
			if ( key1 ) then
				KeyBindingFrame_SetBinding(key1, KeyBindingFrame.selected, KeyBindingFrame.mode);
			end
			if ( key2 ) then
				KeyBindingFrame_SetBinding(key2, nil, KeyBindingFrame.mode, key2);
			end
		end
	end

	KeyBindingFrame_Update();
	-- Button highlighting stuff
	KeyBindingFrame_SetSelected(nil);
	KeyBindingFrame.buttonPressed:UnlockHighlight();
	KeyBindingFrame_UpdateUnbindKey();
	KeyBindingFrame.outputText:SetText("");
end

function OkayButton_OnClick(self)
	if ( KeyBindingFrame.characterSpecificButton:GetChecked() ) then
		KeyBindingFrame.which = CHARACTER_BINDINGS;
	else
		KeyBindingFrame.which = ACCOUNT_BINDINGS;
		if ( GetCurrentBindingSet() == CHARACTER_BINDINGS ) then
			if ( not CONFIRMED_DELETING_CHARACTER_SPECIFIC_BINDINGS ) then
				StaticPopup_Show("CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS");
				return;
			end
		end
	end
	AttemptToSaveBindings(KeyBindingFrame.which);
	KeyBindingFrame.outputText:SetText("");
	KeyBindingFrame_SetSelected(nil);
	HideUIPanel(KeyBindingFrame);

	local shouldSave = true;
	HandleCustomKeybindingsDismissed(shouldSave);
end

function CancelButton_OnClick(self)
	KeyBindingFrame_CancelBinding(self);

	local shouldSave = false;
	HandleCustomKeybindingsDismissed(shouldSave);
end

function DefaultsButton_OnClick(self)
	StaticPopup_Show("CONFIRM_RESET_TO_DEFAULT_KEYBINDINGS");
end

function KeyBindingFrame_CancelBinding(self)
	LoadBindings(GetCurrentBindingSet());
	KeyBindingFrame.outputText:SetText("");
	KeyBindingFrame_SetSelected(nil);
	HideUIPanel(KeyBindingFrame);
end

function KeyBindingFrame_ResetBindingsToDefault()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LoadBindings(DEFAULT_BINDINGS);
	KeyBindingFrame.outputText:SetText("");
	KeyBindingFrame_SetSelected(nil);
	KeyBindingFrame_Update();
end