KEY_BINDINGS_DISPLAYED = 17;
KEY_BINDING_HEIGHT = 25;

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
		KeyBindingFrameOutputText:SetText("");
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
		if ( KeyBindingFrameCharacterButton:GetChecked() ) then
			KeyBindingFrameCharacterButton:SetChecked();
		else
			KeyBindingFrameCharacterButton:SetChecked(1);
		end
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

function KeyBindingFrame_OnLoad(self)
	self:RegisterForClicks("AnyUp");
	KeyBindingFrame_SetSelected(nil);
end

function KeyBindingFrame_OnShow()
	KeyBindingFrame_Update();

	-- Update character button
	KeyBindingFrameCharacterButton:SetChecked(GetCurrentBindingSet() == 2);
	-- Update header text
	if ( KeyBindingFrameCharacterButton:GetChecked() ) then
		KeyBindingFrameHeaderText:SetFormattedText(CHARACTER_KEY_BINDINGS, UnitName("player"));
	else
		KeyBindingFrameHeaderText:SetText(KEY_BINDINGS);
	end

	-- Reset bindingsChanged
	KeyBindingFrame.bindingsChanged = nil;
end

function KeyBindingFrame_Update()
	local numBindings = GetNumBindings();
	local keyOffset;
	local keyBindingButton1, keyBindingButton2, commandName, binding1, binding2;
	local keyBindingName, keyBindingDescription;
	local keyBindingButton1NormalTexture, keyBindingButton1PushedTexture, keyBindingButton2NormalTexture, keyBindingButton2PushedTexture;
	for i=1, KEY_BINDINGS_DISPLAYED, 1 do
		keyOffset = FauxScrollFrame_GetOffset(KeyBindingFrameScrollFrame) + i;
		if ( keyOffset <= numBindings) then
			keyBindingButton1 = _G["KeyBindingFrameBinding"..i.."Key1Button"];
			keyBindingButton1NormalTexture = _G["KeyBindingFrameBinding"..i.."Key1ButtonNormalTexture"];
			keyBindingButton1PushedTexture = _G["KeyBindingFrameBinding"..i.."Key1ButtonPushedTexture"];
			keyBindingButton2NormalTexture = _G["KeyBindingFrameBinding"..i.."Key2ButtonNormalTexture"];
			keyBindingButton2PushedTexture = _G["KeyBindingFrameBinding"..i.."Key2ButtonPushedTexture"];
			keyBindingButton2 = _G["KeyBindingFrameBinding"..i.."Key2Button"];
			keyBindingDescription = _G["KeyBindingFrameBinding"..i.."Description"];
			-- Set binding text
			commandName, binding1, binding2 = GetBinding(keyOffset, KeyBindingFrame.mode);
			-- Handle header
			local headerText = _G["KeyBindingFrameBinding"..i.."Header"];
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
					keyBindingButton1:SetText(GetBindingText(binding1, "KEY_"));
					keyBindingButton1:SetAlpha(1);
				else
					keyBindingButton1:SetText(NORMAL_FONT_COLOR_CODE..NOT_BOUND..FONT_COLOR_CODE_CLOSE);
					keyBindingButton1:SetAlpha(0.8);
				end
				if ( binding2 ) then
					keyBindingButton2:SetText(GetBindingText(binding2, "KEY_"));
					keyBindingButton2:SetAlpha(1);
				else
					keyBindingButton2:SetText(NORMAL_FONT_COLOR_CODE..NOT_BOUND..FONT_COLOR_CODE_CLOSE);
					keyBindingButton2:SetAlpha(0.8);
				end
				-- Set description
				keyBindingDescription:SetText(GetBindingText(commandName, "BINDING_NAME_"));
				-- Handle highlight
				keyBindingButton1:UnlockHighlight();
				keyBindingButton2:UnlockHighlight();
				if ( KeyBindingFrame.selected == commandName ) then
					if ( KeyBindingFrame.keyID == 1 ) then
						keyBindingButton1:LockHighlight();
					else
						keyBindingButton2:LockHighlight();
					end
				end
				_G["KeyBindingFrameBinding"..i]:Show();
			end
		else
			_G["KeyBindingFrameBinding"..i]:Hide();
		end
	end
	
	-- Scroll frame stuff
	FauxScrollFrame_Update(KeyBindingFrameScrollFrame, numBindings, KEY_BINDINGS_DISPLAYED, KEY_BINDING_HEIGHT );

	-- Update Unbindkey button
	KeyBindingFrame_UpdateUnbindKey();
end

function KeyBindingFrame_UnbindKey(keyPressed)
	local oldAction = GetBindingAction(keyPressed, KeyBindingFrame.mode);
	if ( oldAction ~= "" and oldAction ~= KeyBindingFrame.selected ) then
		local key1, key2 = GetBindingKey(oldAction, KeyBindingFrame.mode);
		if ( (not key1 or key1 == keyPressed) and (not key2 or key2 == keyPressed) ) then
			--Error message
			KeyBindingFrameOutputText:SetFormattedText(KEY_UNBOUND_ERROR, GetBindingText(oldAction, "BINDING_NAME_"));
		end
	end
	SetBinding(keyPressed, nil, KeyBindingFrame.mode);
end

function KeyBindingFrame_OnKeyDown(self, keyOrButton)
	if ( GetBindingFromClick(keyOrButton) == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
		return;
	end

	if ( KeyBindingFrame.selected ) then
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
		KeyBindingFrameOutputText:SetText(KEY_BOUND);
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
	elseif ( GetBindingFromClick(keyOrButton) == "TOGGLEGAMEMENU" ) then
		LoadBindings(GetCurrentBindingSet());
		KeyBindingFrameOutputText:SetText("");
		KeyBindingFrame_SetSelected(nil);
		HideUIPanel(self);
	end
	KeyBindingFrame_UpdateUnbindKey();
end

function KeyBindingButton_OnClick(self, button)
	if ( KeyBindingFrame.selected ) then
		-- Code to be able to deselect or select another key to bind
		if ( button == "LeftButton" or button == "RightButton" ) then
			-- Deselect button if it was the pressed previously pressed
			if (KeyBindingFrame.buttonPressed == self) then
				KeyBindingFrame_SetSelected(nil);
				KeyBindingFrameOutputText:SetText("");
			else
				-- Select a different button
				KeyBindingFrame.buttonPressed = self;
				KeyBindingFrame_SetSelected(self.commandName);
				KeyBindingFrame.keyID = self:GetID();
				KeyBindingFrameOutputText:SetFormattedText(BIND_KEY_TO_COMMAND, GetBindingText(self.commandName, "BINDING_NAME_"));
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
		KeyBindingFrame_SetSelected(self.commandName);
		KeyBindingFrame.keyID = self:GetID();
		KeyBindingFrameOutputText:SetFormattedText(BIND_KEY_TO_COMMAND, GetBindingText(self.commandName, "BINDING_NAME_"));
		KeyBindingFrame_Update();
	end
	KeyBindingFrame_UpdateUnbindKey();
end

function KeyBindingFrame_SetBinding(key, selectedBinding, oldKey)
	if ( SetBinding(key, selectedBinding, KeyBindingFrame.mode) ) then
		return;
	else
		if ( oldKey ) then
			SetBinding(oldKey, selectedBinding, KeyBindingFrame.mode);
		end
		--Error message
		KeyBindingFrameOutputText:SetText(KEYBINDINGFRAME_MOUSEWHEEL_ERROR);
	end
end

function KeyBindingFrame_UpdateUnbindKey()
	if ( KeyBindingFrame.selected ) then
		KeyBindingFrameUnbindButton:Enable();
	else
		KeyBindingFrameUnbindButton:Disable();
	end
end

function KeyBindingFrame_ChangeBindingProfile()
	if ( KeyBindingFrameCharacterButton:GetChecked() ) then
		LoadBindings(CHARACTER_BINDINGS);
		KeyBindingFrameHeaderText:SetFormattedText(CHARACTER_KEY_BINDINGS, UnitName("player"));
	else
		LoadBindings(ACCOUNT_BINDINGS);
		KeyBindingFrameHeaderText:SetText(KEY_BINDINGS);
	end
	KeyBindingFrameOutputText:SetText("");
	KeyBindingFrame_SetSelected(nil);
	KeyBindingFrame_Update();
end

function KeyBindingFrame_SetSelected(value)
	KeyBindingFrame.selected = value;
end