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
		SaveBindings(KeyBindingFrame.which);
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

			-- Handle header
			local headerText = keyBindingRow.header;
			if ( strsub(commandName, 1, 6) == "HEADER" ) then
				headerText:SetText(_G["BINDING_"..commandName]);
				headerText:Show();
				keyBindingButton1:Hide();
				keyBindingButton2:Hide();
				keyBindingDescription:Hide();
			else
				headerText:Hide();
				keyBindingButton1:Show();
				keyBindingButton2:Show();
				keyBindingDescription:Show();
				keyBindingButton1.commandName = commandName;
				keyBindingButton2.commandName = commandName;
				if ( binding1 ) then
					keyBindingButton1:SetText(GetBindingText(binding1));
					keyBindingButton1:SetAlpha(1);
				else
					keyBindingButton1:SetText(GRAY_FONT_COLOR_CODE..NOT_BOUND..FONT_COLOR_CODE_CLOSE);
					keyBindingButton1:SetAlpha(0.8);
				end
				if ( binding2 ) then
					keyBindingButton2:SetText(GetBindingText(binding2));
					keyBindingButton2:SetAlpha(1);
				else
					keyBindingButton2:SetText(GRAY_FONT_COLOR_CODE..NOT_BOUND..FONT_COLOR_CODE_CLOSE);
					keyBindingButton2:SetAlpha(0.8);
				end
				-- Set description
				keyBindingDescription:SetText(GetBindingName(commandName));

				keyBindingRow:Show();
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

local mouseButtonNameConversion =
{
	LeftButton = "BUTTON1",
	RightButton = "BUTTON2",
	MiddleButton = "BUTTON3",
	Button4 = "BUTTON4",
	Button5 = "BUTTON5",
	Button6 = "BUTTON6",
	Button7 = "BUTTON7",
	Button8 = "BUTTON8",
	Button9 = "BUTTON9",
	Button10 = "BUTTON10",
	Button11 = "BUTTON11",
	Button12 = "BUTTON12",
	Button13 = "BUTTON13",
	Button14 = "BUTTON14",
	Button15 = "BUTTON15",
	Button16 = "BUTTON16",
	Button17 = "BUTTON17",
	Button18 = "BUTTON18",
	Button19 = "BUTTON19",
	Button20 = "BUTTON20",
	Button21 = "BUTTON21",
	Button22 = "BUTTON22",
	Button23 = "BUTTON23",
	Button24 = "BUTTON24",
	Button25 = "BUTTON25",
	Button26 = "BUTTON26",
	Button27 = "BUTTON27",
	Button28 = "BUTTON28",
	Button29 = "BUTTON29",
	Button30 = "BUTTON30",
	Button31 = "BUTTON31",
};

local ignoredKeys =
{
	UNKNOWN = true,
	BUTTON1 = true,
	BUTTON2 = true,
	LSHIFT = true,
	RSHIFT = true,
	LCTRL = true,
	RCTRL = true,
	LALT = true,
	RALT = true,
};

local function IsKeyPressIgnoredForBinding(key)
	return ignoredKeys[key] == true;
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

local function CreateKeyChordString(key)
	local shift = IsShiftKeyDown() and "SHIFT-" or "";
	local ctrl = IsControlKeyDown() and "CTRL-" or "";
	local alt = IsAltKeyDown() and "ALT-" or "";

	return ("%s%s%s%s"):format(alt, ctrl, shift, key);
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
		local keyPressed = mouseButtonNameConversion[keyOrButton] or keyOrButton;

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

function BindingButtonTemplate_SetSelected(keyBindingButton, isSelected)
	keyBindingButton.selectedHighlight:SetShown(isSelected);
	keyBindingButton.isSelected = isSelected;

	if isSelected then
		keyBindingButton:GetHighlightTexture():SetAlpha(0);
	else
		keyBindingButton:GetHighlightTexture():SetAlpha(1);
	end

	return isSelected;
end

function BindingButtonTemplate_ToggleSelected(keyBindingButton)
	return BindingButtonTemplate_SetSelected(keyBindingButton, not keyBindingButton.isSelected);
end

function BindingButtonTemplate_IsSelected(keyBindingButton)
	return keyBindingButton.isSelected;
end

function KeyBindingFrame_SetSelected(value, keyBindingButton)
	local previousButton = KeyBindingFrame.selectedButton;

	KeyBindingFrame.selectedButton = nil;
	KeyBindingFrame.selected = value;

	if previousButton then
		BindingButtonTemplate_SetSelected(previousButton, false);
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
	SaveBindings(KeyBindingFrame.which);
	KeyBindingFrame.outputText:SetText("");
	KeyBindingFrame_SetSelected(nil);
	HideUIPanel(KeyBindingFrame);
end

function CancelButton_OnClick(self)
	KeyBindingFrame_CancelBinding(self);
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

function GetBindingName(binding)
	local bindingName = _G["BINDING_NAME_"..binding];
	if ( bindingName ) then
		return bindingName;
	end

	return binding;
end
