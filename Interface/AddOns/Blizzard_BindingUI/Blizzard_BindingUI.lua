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
	OnAccept = function() KeyBindingFrame:CharacterSpecificPopupAccept() end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

StaticPopupDialogs["CONFIRM_LOSE_BINDING_CHANGES_CHARACTER_SPECIFIC"] = {
	text = CONFIRM_LOSE_BINDING_CHANGES_CHARACTER_SPECIFIC,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function() KeyBindingFrame:LoseBindingsPopupAccept() end,
	OnCancel = KeybindsFrames_LoseBindingsPopupCancel,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

StaticPopupDialogs["CONFIRM_RESET_TO_DEFAULT_KEYBINDINGS"] = {
	text = CONFIRM_RESET_KEYBINDINGS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function() KeyBindingFrame:ResetBindingsPopupAccept() end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

StaticPopupDialogs["CONFIRM_RESET_TO_PREVIOUS_KEYBINDINGS"] = {
	text = CONFIRM_RESET_TO_PREVIOUS_KEYBINDINGS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function() LoadBindings(GetCurrentBindingSet()) end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

local function KeybindFrames_SetOutputText(...)
	KeyBindingFrame.outputText:SetFormattedText(...);
	QuickKeybindFrame.outputText:SetFormattedText(...);
end

local function KeybindFrames_ClearOutputText()
	KeyBindingFrame.outputText:SetText("");
	QuickKeybindFrame.outputText:SetText("");
end

local function KeybindsFrames_LoseBindingsPopupCancel()
	local newChecked = not KeyBindingFrame.characterSpecificButton:GetChecked();
	KeyBindingFrame.characterSpecificButton:SetChecked(newChecked);
	QuickKeybindFrame.characterSpecificButton:SetChecked(newChecked);
end

KeyBindingFrameMixin = {};

function KeyBindingFrameMixin:OnLoad()
	self:RegisterForClicks("AnyUp");
	self.scrollOffset = 0;
	self:SetSelected(nil);
	self:LoadCategories();
	self:LoadKeyBindingButtons();

	self:RegisterEvent("ADDON_LOADED");
end

function KeyBindingFrameMixin:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		self:LoadCategories();
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

function KeyBindingFrameMixin:LoadCategories()
	local keyBindingCategories = {};
	local otherCategory = nil;
	OptionsList_ClearSelection(self.categoryList, self.categoryList.buttons);

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

function KeyBindingFrameMixin:LoadKeyBindingButtons()
	local previousRow = CreateFrame("FRAME", KEY_BINDING_ROW_NAME.."1", self, "KeyBindingFrameBindingTemplate");
	previousRow:InitializeButtons(1);
	previousRow:SetPoint("TOP", 100, -78);
	self.keyBindingRows = { previousRow };

	for i = 2, KEY_BINDINGS_DISPLAYED do
		local newRow = CreateFrame("FRAME", KEY_BINDING_ROW_NAME..i, self, "KeyBindingFrameBindingTemplate");
		newRow:InitializeButtons(i);
		newRow:SetPoint("TOP", previousRow, "BOTTOM", 0, 2);
		self.keyBindingRows[i] = newRow;

		previousRow = newRow;
	end
end

function KeyBindingFrameMixin:OnShow()
	self.mode = 1;
	self:Update();

	-- Update character button
	self.characterSpecificButton:SetChecked(GetCurrentBindingSet() == 2);

	self:UpdateHeaderText();

	-- Reset bindingsChanged
	self.bindingsChanged = nil;
	self.inQuickKeybind = false;

	Disable_BagButtons();
	UpdateMicroButtons();
end

local function CreatePushToTalkBindingButton()
	local button;
	local handler = CustomBindingHandler:CreateHandler(Enum.CustomBindingType.VoicePushToTalk);

	handler:SetOnBindingModeActivatedCallback(function(isActive)
		if isActive then
			KeyBindingFrame.buttonPressed = button;
			KeyBindingFrame:SetSelected("TOGGLE_VOICE_PUSH_TO_TALK", button);
			KeyBindingFrame:UpdateUnbindKey();
			KeybindFrames_SetOutputText(BIND_KEY_TO_COMMAND, GetBindingName("TOGGLE_VOICE_PUSH_TO_TALK"));
		end
	end);

	handler:SetOnBindingCompletedCallback(function(completedSuccessfully, keys)
		KeyBindingFrame:SetSelected(nil);

		if completedSuccessfully then
			KeybindFrames_SetOutputText(KEY_BOUND);
		else
			KeybindFrames_ClearOutputText();
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

function KeyBindingFrameMixin:Update()
	local numBindings = #self.cntCategory;
	local keyOffset = FauxScrollFrame_GetOffset(self.scrollFrame);

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
				self:SetSelected(self.selected, button);
			else
				self:SetSelected(self.selected, nil);
			end
		end
	end

	HideAllCustomButtons();

	self.scrollOffset = keyOffset;

	for i=1, KEY_BINDINGS_DISPLAYED, 1 do
		keyOffset = keyOffset + 1;
		local keyBindingRow = self.keyBindingRows[i];
		if ( keyOffset <= numBindings ) then
			keyBindingRow:Update(keyOffset);
		else
			keyBindingRow:Hide();
		end
	end

	-- Scroll frame stuff
	FauxScrollFrame_Update(self.scrollFrame, numBindings, KEY_BINDINGS_DISPLAYED, KEY_BINDING_HEIGHT);

	-- Update Unbindkey button
	self:UpdateUnbindKey();
end

function KeyBindingFrameMixin:OnHide()
	if ( not self.inQuickKeybind ) then
		ShowUIPanel(GameMenuFrame);
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT);
		UpdateMicroButtons();
	end
	KeybindFrames_ClearOutputText();
	self:SetSelected(nil);
end

function KeyBindingFrameMixin:UnbindKey(keyPressed, selectedAction, bindingMode)
	local keyBindMessage;
	local oldAction = GetBindingAction(keyPressed, bindingMode);
	if oldAction ~= "" and oldAction ~= selectedAction then
		local key1, key2 = GetBindingKey(oldAction, bindingMode);
		if ( key1 == keyPressed and key2 ) then
			keyBindMessage = PRIMARY_KEY_UNBOUND_ERROR:format(GetBindingName(oldAction));
			KeybindFrames_SetOutputText(keyBindMessage);
		elseif (not key1 or key1 == keyPressed) and (not key2 or key2 == keyPressed) then
			keyBindMessage = KEY_UNBOUND_ERROR:format(GetBindingName(oldAction));
			KeybindFrames_SetOutputText(keyBindMessage);
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
			keyBindMessage = KeyBindingFrame:SetBinding(keyToBind, selectedAction, bindingMode, currentKey) or keyBindMessage;
		end
	end

	return keyBindMessage;
end

-- NOTE: preventKeybindingFrameBehavior being true indicates that all the code specific to the keybind frame shouldn't be run.
-- The default behavior is to be called from the keybinding frame.
-- This function returns true if it tried to bind something, and false otherwise.  Its secondary return is a feedback/status message.
function KeyBindingFrameMixin:AttemptKeybind(keyOrButton, selectedAction, bindingMode, keybindButtonID, preventKeybindingFrameBehavior)
	local keyBindFeedbackMessage;
	local wasSomethingBound = false;

	if GetBindingFromClick(keyOrButton) == "SCREENSHOT" then
		RunBinding("SCREENSHOT");
	elseif selectedAction then
		local keyPressed = GetConvertedKeyOrButton(keyOrButton);

		if not IsKeyPressIgnoredForBinding(keyPressed) then
			keyPressed = CreateKeyChordStringUsingMetaKeyState(keyPressed);

			-- Unbind the current action
			local key1, key2 = GetBindingKey(selectedAction, bindingMode);
			ClearBindingsForKeys(bindingMode, key1, key2);

			-- Unbind the current key and rebind current action
			if not preventKeybindingFrameBehavior then
				keyBindFeedbackMessage = KEY_BOUND;
				KeybindFrames_SetOutputText(KEY_BOUND);
			end

			keyBindFeedbackMessage = self:UnbindKey(keyPressed, selectedAction, bindingMode) or keyBindFeedbackMessage;
			local rebindingMessage = RebindKeysInOrder(keyPressed, keybindButtonID, selectedAction, bindingMode, key1, key2);
			if not keyBindFeedbackMessage then
				keyBindFeedbackMessage = rebindingMessage;
			end

			if not preventKeybindingFrameBehavior then
				self:Update();
				-- Button highlighting stuff
				self:SetSelected(nil);
				if ( self.buttonPressed ) then
					self.buttonPressed:UnlockHighlight();
				end
				self.bindingsChanged = 1;

				self:UpdateUnbindKey();
			end

			wasSomethingBound = true;
		end
	elseif (not preventKeybindingFrameBehavior) and GetBindingFromClick(keyOrButton) == "TOGGLEGAMEMENU" then
		self:CancelBinding();
	end

	return wasSomethingBound, keyBindFeedbackMessage;
end

function KeyBindingFrameMixin:OnKeyDown(keyOrButton)
	return self:AttemptKeybind(keyOrButton, self.selected, self.mode, self.keyID);
end

function KeyBindingFrameMixin:SetBinding(key, selectedAction, bindingMode, oldKey)
	local keyBindMessage;
	if not SetBinding(key, selectedAction, bindingMode) then
		if oldKey then
			SetBinding(oldKey, selectedAction, bindingMode);
		end

		keyBindMessage = KEYBINDINGFRAME_MOUSEWHEEL_ERROR;
		KeybindFrames_SetOutputText(keyBindMessage);
	end

	return keyBindMessage;
end

function KeyBindingFrameMixin:UpdateUnbindKey()
	local enabled = self.selected and true or false;
	self.unbindButton:SetEnabled(enabled);
end

function KeyBindingFrameMixin:UpdateHeaderText()
	if ( self.characterSpecificButton:GetChecked() ) then
		self.Header:Setup(CHARACTER_KEY_BINDINGS:format(UnitName("player")));
	else
		self.Header:Setup(KEY_BINDINGS);
	end
end

function KeyBindingFrameMixin:ChangeBindingProfile()
	if ( self.characterSpecificButton:GetChecked() ) then
		LoadBindings(CHARACTER_BINDINGS);
	else
		LoadBindings(ACCOUNT_BINDINGS);
	end
	self:UpdateHeaderText();
	KeybindFrames_ClearOutputText();
	self:SetSelected(nil);
	self:Update();
end

function KeyBindingFrameMixin:SetSelected(value, keyBindingButton)
	local previousButton = self.selectedButton;

	self.selectedButton = nil;
	self.selected = value;

	if previousButton then
		BindingButtonTemplate_SetSelected(previousButton, false);

		if previousButton.GetCustomBindingType and previousButton:GetCustomBindingType() ~= nil then
			previousButton:CancelBinding();
		end
	end

	if keyBindingButton then
		BindingButtonTemplate_SetSelected(keyBindingButton, true);

		self.selectedButton = keyBindingButton;
		self.selectedButtonIndex = keyBindingButton.buttonIndex;
		self.selectedRowIndex = keyBindingButton.rowIndex;
	end
end

function KeyBindingFrameMixin:OnMouseWheel(delta)
	if ( self.selected ) then
		if ( delta > 0 ) then
			self:OnKeyDown("MOUSEWHEELUP");
		else
			self:OnKeyDown("MOUSEWHEELDOWN");
		end
	end
end

function KeyBindingFrameMixin:CancelBinding()
	LoadBindings(GetCurrentBindingSet());
	KeybindFrames_ClearOutputText();
	self:SetSelected(nil);
	HideUIPanel(self);
end

function KeyBindingFrameMixin:ResetBindingsToDefault()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	LoadBindings(DEFAULT_BINDINGS);
	KeybindFrames_ClearOutputText();
	self:SetSelected(nil);
	self:Update();
end

function KeyBindingFrameMixin:CharacterSpecificPopupAccept()
	SaveBindings(ACCOUNT_BINDINGS);
	KeybindFrames_ClearOutputText();
	self:SetSelected(nil);
	HideUIPanel(self);
	CONFIRMED_DELETING_CHARACTER_SPECIFIC_BINDINGS = 1;
end

function KeyBindingFrameMixin:LoseBindingsPopupAccept()
	self:ChangeBindingProfile();
	self.bindingsChanged = nil;
end

function KeyBindingFrameMixin:ResetBindingsPopupAccept()
	self:ResetBindingsToDefault();
end

function KeyBindingFrameMixin:EnterQuickKeybind()
	self.inQuickKeybind = true;
	HideUIPanel(self);
	ShowUIPanel(QuickKeybindFrame);
end

KeyBindingButtonMixin = {};

function KeyBindingButtonMixin:OnClick(button, down)
	local keybindsFrame = self:GetParent():GetParent();

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if ( keybindsFrame.selected ) then
		-- Code to be able to deselect or select another key to bind
		if ( button == "LeftButton" or button == "RightButton" ) then
			-- Deselect button if it was the pressed previously pressed
			if (keybindsFrame.buttonPressed == self) then
				keybindsFrame:SetSelected(nil);
				KeybindFrames_ClearOutputText();
			else
				-- Select a different button
				keybindsFrame.buttonPressed = self;
				keybindsFrame:SetSelected(self.commandName, self);
				keybindsFrame.keyID = self:GetID();
				KeybindFrames_SetOutputText(BIND_KEY_TO_COMMAND, GetBindingName(self.commandName));
			end
			keybindsFrame:Update();
			return;
		end
		keybindsFrame:OnKeyDown(button);
	else
		if (keybindsFrame.buttonPressed) then
			keybindsFrame.buttonPressed:UnlockHighlight();
		end
		keybindsFrame.buttonPressed = self;
		keybindsFrame:SetSelected(self.commandName, self);
		keybindsFrame.keyID = self:GetID();
		KeybindFrames_SetOutputText(BIND_KEY_TO_COMMAND, GetBindingName(self.commandName));
		keybindsFrame:Update();
	end
	keybindsFrame:UpdateUnbindKey();
end

function KeyBindingButtonMixin:OnLoad()
	self:RegisterForClicks("AnyUp");
end

KeybindingsCategoryListButtonMixin = {};

function KeybindingsCategoryListButtonMixin:OnClick(button, down)
	local keybindsFrame = self:GetParent():GetParent();

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	OptionsList_ClearSelection(keybindsFrame.categoryList, keybindsFrame.categoryList.buttons);
	OptionsList_SelectButton(self:GetParent(), self);

	keybindsFrame.cntCategory = self.element.category;
	keybindsFrame:SetSelected(nil);
	KeybindFrames_ClearOutputText();
	keybindsFrame.scrollFrame.ScrollBar:SetValue(0);
	keybindsFrame:Update();
end

KeybindingsCharacterSpecificButtonMixin = {};

function KeybindingsCharacterSpecificButtonMixin:OnLoad()
	self.text:SetText(HIGHLIGHT_FONT_COLOR_CODE..CHARACTER_SPECIFIC_KEYBINDINGS..FONT_COLOR_CODE_CLOSE);
end

function KeybindingsCharacterSpecificButtonMixin:OnClick(button, down)
	if (self.enabled) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	if ( KeyBindingFrame.bindingsChanged ) then
		StaticPopup_Show("CONFIRM_LOSE_BINDING_CHANGES_CHARACTER_SPECIFIC");
	else
		KeyBindingFrame:ChangeBindingProfile();
	end
end

function KeybindingsCharacterSpecificButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP, nil, nil, nil, nil, true);
end

function KeybindingsCharacterSpecificButtonMixin:OnHide()
	GameTooltip_Hide();
end

KeybindingsUnbindButtonMixin = {};

function KeybindingsUnbindButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local keybindsFrame = self:GetParent();
	local button = keybindsFrame.selectedButton;
	local customBindingType = button.GetCustomBindingType and button:GetCustomBindingType();
	if customBindingType ~= nil then
		CustomBindingManager:Unbind(customBindingType);
		BindingButtonTemplate_SetupBindingButton(nil, button);
	else
		local key1, key2 = GetBindingKey(keybindsFrame.selected, keybindsFrame.mode);
		if ( key1 ) then
			SetBinding(key1, nil, keybindsFrame.mode);
		end
		if ( key2 ) then
			SetBinding(key2, nil, keybindsFrame.mode);
		end
		if ( key1 and keybindsFrame.keyID == 1 ) then
			keybindsFrame:SetBinding(key1, nil, keybindsFrame.mode, key1);
			if ( key2 ) then
				keybindsFrame:SetBinding(key2, keybindsFrame.selected, keybindsFrame.mode, key2);
			end
		else
			if ( key1 ) then
				keybindsFrame:SetBinding(key1, keybindsFrame.selected, keybindsFrame.mode);
			end
			if ( key2 ) then
				keybindsFrame:SetBinding(key2, nil, keybindsFrame.mode, key2);
			end
		end
	end

	keybindsFrame:Update();
	-- Button highlighting stuff
	keybindsFrame:SetSelected(nil);
	keybindsFrame.buttonPressed:UnlockHighlight();
	keybindsFrame:UpdateUnbindKey();
	KeybindFrames_ClearOutputText();
end

KeybindingsOkayButtonMixin = {};

function KeybindingsOkayButtonMixin:OnClick()
	local parentFrame = self:GetParent();
	local keyBindingMode;

	if ( parentFrame.characterSpecificButton:GetChecked() ) then
		keyBindingMode = CHARACTER_BINDINGS;
	else
		keyBindingMode = ACCOUNT_BINDINGS;
		if ( GetCurrentBindingSet() == CHARACTER_BINDINGS ) then
			if ( not CONFIRMED_DELETING_CHARACTER_SPECIFIC_BINDINGS ) then
				StaticPopup_Show("CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS");
				return;
			end
		end
	end
	SaveBindings(keyBindingMode);
	KeybindFrames_ClearOutputText();
	parentFrame:SetSelected(nil);
	HideUIPanel(parentFrame);

	local shouldSave = true;
	HandleCustomKeybindingsDismissed(shouldSave);
end

KeybindingsCancelButtonMixin = {};

function KeybindingsCancelButtonMixin:OnClick()
	local parentFrame = self:GetParent();

	parentFrame:CancelBinding();
	local shouldSave = false;
	HandleCustomKeybindingsDismissed(shouldSave);
end

KeybindingsDefaultsButtonMixin = {};

function KeybindingsDefaultsButtonMixin:OnClick()
	StaticPopup_Show("CONFIRM_RESET_TO_DEFAULT_KEYBINDINGS");
end

KeyBindingFrameBindingTemplateMixin = {};

function KeyBindingFrameBindingTemplateMixin:Update(keyOffset)
	local keybindsFrame = self:GetParent();
	local cntCategory = keybindsFrame.cntCategory;
	-- Set binding text
	local commandName, category, binding1, binding2 = GetBinding(cntCategory[keyOffset], self.mode);
	local customBindingType = C_KeyBindings.GetCustomBindingType(cntCategory[keyOffset]);
	local customButton = customBindingType and GetOrCreateCustomKeybindingButton(customBindingType);
	local isHeader = strsub(commandName, 1, 6) == "HEADER";

	self.header:SetShown(isHeader);
	self.key1Button:SetShown(not isHeader and not customButton);
	self.key2Button:SetShown(not isHeader);
	self.key2Button:SetEnabled(not customButton);
	self.description:SetShown(not isHeader);

	self.key1Button.commandName = commandName;
	self.key2Button.commandName = commandName;

	if ( isHeader ) then
		self.header:SetText(_G["BINDING_"..commandName]);
	else
		if customBindingType ~= nil then
			binding1, binding2 = nil, nil;
		end

		BindingButtonTemplate_SetupBindingButton(binding1, self.key1Button);
		BindingButtonTemplate_SetupBindingButton(binding2, self.key2Button);

		self.description:SetText(GetBindingName(commandName));
		self:Show();

		if customButton then
			BindingButtonTemplate_SetupBindingButton(nil, customButton);

			customButton:ClearAllPoints();
			customButton:SetAllPoints(self.key1Button);
			customButton:Show();
		end
	end
end

function KeyBindingFrameBindingTemplateMixin:InitializeButtons(rowIndex)
	self.key1Button.buttonIndex = 1;
	self.key1Button.rowIndex = rowIndex;
	self.key2Button.buttonIndex = 2;
	self.key2Button.rowIndex = rowIndex;
end

KeyBindingFrameScrollFrameMixin = {};

function KeyBindingFrameScrollFrameMixin:OnVerticalScroll(offset)
	local keybindsFrame = self:GetParent();

	FauxScrollFrame_OnVerticalScroll(self, offset, KEY_BINDING_HEIGHT, GenerateClosure(keybindsFrame.Update, keybindsFrame));
end

function KeyBindingFrameScrollFrameMixin:OnMouseWheel(delta)
	local keybindsFrame = self:GetParent();

	if ( not keybindsFrame.selected ) then
		ScrollFrameTemplate_OnMouseWheel(self, delta);
	else
		keybindsFrame:OnMouseWheel(delta);
	end
end

QuickKeybindButtonMixin = {};

function QuickKeybindButtonMixin:OnClick(button, down)
	local keybindFrame = self:GetParent();
	keybindFrame.keyID = 1; 
	keybindFrame:EnterQuickKeybind();
end

QuickKeybindFrameMixin = {};

function QuickKeybindFrameMixin:OnShow()
	EventRegistry:TriggerEvent("QuickKeybindFrame.QuickKeybindModeEnabled");

	self.characterSpecificButton:SetChecked(KeyBindingFrame.characterSpecificButton:GetChecked());
	self.mouseOverButton = nil;
	Enable_BagButtons();
	ActionButtonUtil.ShowAllActionButtonGrids();
	ActionButtonUtil.ShowAllQuickKeybindButtonHighlights();
	local showQuickKeybindEffects = true;
	MainMenuBar:SetQuickKeybindModeEffectsShown(showQuickKeybindEffects);
	MultiActionBar_SetAllQuickKeybindModeEffectsShown(showQuickKeybindEffects);
	ExtraActionBar_ForceShowIfNeeded();
end

function QuickKeybindFrameMixin:OnHide()
	EventRegistry:TriggerEvent("QuickKeybindFrame.QuickKeybindModeDisabled");

	KeybindFrames_ClearOutputText();
	if ( not GameMenuFrame:IsShown() ) then
		ShowUIPanel(KeyBindingFrame);
	end
	Disable_BagButtons();
	ActionButtonUtil.HideAllActionButtonGrids();
	ActionButtonUtil.HideAllQuickKeybindButtonHighlights();
	local showQuickKeybindEffects = false;
	MainMenuBar:SetQuickKeybindModeEffectsShown(showQuickKeybindEffects);
	MultiActionBar_SetAllQuickKeybindModeEffectsShown(showQuickKeybindEffects);
	ExtraActionBar_CancelForceShow();
end

function QuickKeybindFrameMixin:CancelBinding()
	LoadBindings(GetCurrentBindingSet());
	KeybindFrames_ClearOutputText();
	KeyBindingFrame:SetSelected(nil);
	HideUIPanel(self);
end

function QuickKeybindFrameMixin:SetSelected(value, button)
	KeyBindingFrame:SetSelected(value);
	self.mouseOverButton = button;
end

function QuickKeybindFrameMixin:OnKeyDown(keyOrButton)
	local selected = KeyBindingFrame.selected;
	local mode = KeyBindingFrame.mode;
	local gmkey1, gmkey2 = GetBindingKey("TOGGLEGAMEMENU", mode);
	if ( (keyOrButton == gmkey1 or keyOrButton == gmkey1) and not selected ) then
		ShowUIPanel(GameMenuFrame);
		self:CancelBinding();
	elseif ( keyOrButton == "ESCAPE" and selected ) then
		local key1, key2 = GetBindingKey(selected, mode);
		if ( key1 ) then
			KeyBindingFrame:SetBinding(key1, nil, mode, key1);
		end
		if ( key2 ) then
			KeyBindingFrame:SetBinding(key2, selected, mode, key2);
		end
		KeybindFrames_ClearOutputText();
	else
		KeyBindingFrame:OnKeyDown(keyOrButton);
		-- Reselect hovered button
		KeyBindingFrame:SetSelected(selected);
	end
	if ( self.mouseOverButton ) then
		self.mouseOverButton:QuickKeybindButtonSetTooltip();
	end
end

function QuickKeybindFrameMixin:OnMouseWheel(delta)
	local selected = KeyBindingFrame.selected;
	KeyBindingFrame:OnMouseWheel(delta);
	if ( self.mouseOverButton ) then
		self.mouseOverButton:QuickKeybindButtonSetTooltip();
	end
	-- Reselect hovered button
	KeyBindingFrame:SetSelected(selected);
end

QuickKeybindResetAllButtonMixin = {};

function QuickKeybindResetAllButtonMixin:OnClick()
	StaticPopup_Show("CONFIRM_RESET_TO_PREVIOUS_KEYBINDINGS");
end
