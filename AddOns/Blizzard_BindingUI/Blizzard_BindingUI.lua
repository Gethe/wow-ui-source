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
							BINDING_HEADER_ITUNES_REMOTE,
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
	PlaySound("gsTitleOptionExit");
	UpdateMicroButtons();
end

function KeyBindingFrame_UnbindKey(keyPressed)
	local oldAction = GetBindingAction(keyPressed, KeyBindingFrame.mode);
	if ( oldAction ~= "" and oldAction ~= KeyBindingFrame.selected ) then
		local key1, key2 = GetBindingKey(oldAction, KeyBindingFrame.mode);
		if ( (not key1 or key1 == keyPressed) and (not key2 or key2 == keyPressed) ) then
			--Error message
			KeyBindingFrame.outputText:SetFormattedText(KEY_UNBOUND_ERROR, GetBindingName(oldAction));
		end
	end
	SetBinding(keyPressed, nil, KeyBindingFrame.mode);
end

function KeyBindingFrame_OnKeyDown(self, keyOrButton)
	if ( GetBindingFromClick(keyOrButton) == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
	elseif ( KeyBindingFrame.selected ) then
		local keyPressed = keyOrButton;

		if ( keyPressed == "UNKNOWN" ) then
			return;
		end

		-- Convert the mouse button names
		if ( keyPressed == "LeftButton" ) then
			keyPressed = "BUTTON1";
		elseif ( keyPressed == "RightButton" ) then
			keyPressed = "BUTTON2";
		elseif ( keyPressed == "MiddleButton" ) then
			keyPressed = "BUTTON3";
		elseif ( keyPressed == "Button4" ) then
			keyPressed = "BUTTON4"
		elseif ( keyOrButton == "Button5" ) then
			keyPressed = "BUTTON5"
		elseif ( keyPressed == "Button6" ) then
			keyPressed = "BUTTON6"
		elseif ( keyOrButton == "Button7" ) then
			keyPressed = "BUTTON7"
		elseif ( keyPressed == "Button8" ) then
			keyPressed = "BUTTON8"
		elseif ( keyOrButton == "Button9" ) then
			keyPressed = "BUTTON9"
		elseif ( keyPressed == "Button10" ) then
			keyPressed = "BUTTON10"
		elseif ( keyOrButton == "Button11" ) then
			keyPressed = "BUTTON11"
		elseif ( keyPressed == "Button12" ) then
			keyPressed = "BUTTON12"
		elseif ( keyOrButton == "Button13" ) then
			keyPressed = "BUTTON13"
		elseif ( keyPressed == "Button14" ) then
			keyPressed = "BUTTON14"
		elseif ( keyOrButton == "Button15" ) then
			keyPressed = "BUTTON15"
		elseif ( keyPressed == "Button16" ) then
			keyPressed = "BUTTON16"
		elseif ( keyOrButton == "Button17" ) then
			keyPressed = "BUTTON17"
		elseif ( keyPressed == "Button18" ) then
			keyPressed = "BUTTON18"
		elseif ( keyOrButton == "Button19" ) then
			keyPressed = "BUTTON19"
		elseif ( keyPressed == "Button20" ) then
			keyPressed = "BUTTON20"
		elseif ( keyOrButton == "Button21" ) then
			keyPressed = "BUTTON21"
		elseif ( keyPressed == "Button22" ) then
			keyPressed = "BUTTON22"
		elseif ( keyOrButton == "Button23" ) then
			keyPressed = "BUTTON23"
		elseif ( keyPressed == "Button24" ) then
			keyPressed = "BUTTON24"
		elseif ( keyOrButton == "Button25" ) then
			keyPressed = "BUTTON25"
		elseif ( keyPressed == "Button26" ) then
			keyPressed = "BUTTON26"
		elseif ( keyOrButton == "Button27" ) then
			keyPressed = "BUTTON27"
		elseif ( keyPressed == "Button28" ) then
			keyPressed = "BUTTON28"
		elseif ( keyOrButton == "Button29" ) then
			keyPressed = "BUTTON29"
		elseif ( keyPressed == "Button30" ) then
			keyPressed = "BUTTON30"
		elseif ( keyOrButton == "Button31" ) then
			keyPressed = "BUTTON31"
		end
		if ( keyPressed == "BUTTON1" or keyPressed == "BUTTON2" ) then
			return;
		end

		if ( keyPressed == "LSHIFT" or
		     keyPressed == "RSHIFT" or
		     keyPressed == "LCTRL" or
		     keyPressed == "RCTRL" or
		     keyPressed == "LALT" or
		     keyPressed == "RALT" ) then
			return;
		end
		if ( IsShiftKeyDown() ) then
			keyPressed = "SHIFT-"..keyPressed;
		end
		if ( IsControlKeyDown() ) then
			keyPressed = "CTRL-"..keyPressed;
		end
		if ( IsAltKeyDown() ) then
			keyPressed = "ALT-"..keyPressed;
		end

		-- Unbind the current action
		local key1, key2 = GetBindingKey(KeyBindingFrame.selected, KeyBindingFrame.mode);
		if ( key1 ) then
			SetBinding(key1, nil, KeyBindingFrame.mode);
		end
		if ( key2 ) then
			SetBinding(key2, nil, KeyBindingFrame.mode);
		end
		-- Unbind the current key and rebind current action
		KeyBindingFrame.outputText:SetText(KEY_BOUND);
		KeyBindingFrame_UnbindKey(keyPressed);
		if ( KeyBindingFrame.keyID == 1 ) then
			KeyBindingFrame_SetBinding(keyPressed, KeyBindingFrame.selected, key1);
			if ( key2 ) then
				SetBinding(key2, KeyBindingFrame.selected, KeyBindingFrame.mode);
			end
		else
			if ( key1 ) then
				KeyBindingFrame_SetBinding(key1, KeyBindingFrame.selected);
			end
			KeyBindingFrame_SetBinding(keyPressed, KeyBindingFrame.selected, key2);
		end
		KeyBindingFrame_Update();
		-- Button highlighting stuff
		KeyBindingFrame_SetSelected(nil);
		KeyBindingFrame.buttonPressed:UnlockHighlight();
		KeyBindingFrame.bindingsChanged = 1;
		
		KeyBindingFrame_UpdateUnbindKey();
	elseif ( GetBindingFromClick(keyOrButton) == "TOGGLEGAMEMENU" ) then
		LoadBindings(GetCurrentBindingSet());
		KeyBindingFrame.outputText:SetText("");
		KeyBindingFrame_SetSelected(nil);
		HideUIPanel(self);
	end
end

function KeyBindingFrame_SetBinding(key, selectedBinding, oldKey)
	if ( SetBinding(key, selectedBinding, KeyBindingFrame.mode) ) then
		return;
	else
		if ( oldKey ) then
			SetBinding(oldKey, selectedBinding, KeyBindingFrame.mode);
		end
		--Error message
		KeyBindingFrame.outputText:SetText(KEYBINDINGFRAME_MOUSEWHEEL_ERROR);
	end
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
	KeyBindingFrame.selected = value;
	if ( KeyBindingFrame.selectedButton ) then
		local oldSelectedButton = KeyBindingFrame.selectedButton;
		oldSelectedButton.selectedHighlight:Hide();
		oldSelectedButton:GetHighlightTexture():SetAlpha(1);
	end
	if ( keyBindingButton ) then
		KeyBindingFrame.selectedButton = keyBindingButton;
		keyBindingButton.selectedHighlight:Show();
		keyBindingButton:GetHighlightTexture():SetAlpha(0);
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
	PlaySound("igMainMenuOptionCheckBoxOn");
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
	PlaySound("igMainMenuOptionCheckBoxOn");
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
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
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
	PlaySound("igMainMenuOptionCheckBoxOn");
	local key1, key2 = GetBindingKey(KeyBindingFrame.selected, KeyBindingFrame.mode);
	if ( key1 ) then
		SetBinding(key1, nil, KeyBindingFrame.mode);
	end
	if ( key2 ) then
		SetBinding(key2, nil, KeyBindingFrame.mode);
	end
	if ( key1 and KeyBindingFrame.keyID == 1 ) then
		KeyBindingFrame_SetBinding(key1, nil, key1);
		if ( key2 ) then
			SetBinding(key2, KeyBindingFrame.selected, KeyBindingFrame.mode);
		end
	else
		if ( key1 ) then
			KeyBindingFrame_SetBinding(key1, KeyBindingFrame.selected);
		end
		if ( key2 ) then
			KeyBindingFrame_SetBinding(key2, nil, key2);
		end
	end
	KeyBindingFrame_Update();
	-- Button highlighting stuff
	KeyBindingFrame_SetSelected(nil);
	KeyBindingFrame.buttonPressed:UnlockHighlight();
	KeyBindingFrame_UpdateUnbindKey();
	KeyBindingFrame.outputText:SetText();
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
	LoadBindings(GetCurrentBindingSet());
	KeyBindingFrame.outputText:SetText("");
	KeyBindingFrame_SetSelected(nil);
	HideUIPanel(KeyBindingFrame);
end

function DefaultsButton_OnClick(self)
	StaticPopup_Show("CONFIRM_RESET_TO_DEFAULT_KEYBINDINGS");
end

function KeyBindingFrame_ResetBindingsToDefault()
	PlaySound("igMainMenuOptionCheckBoxOn");
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