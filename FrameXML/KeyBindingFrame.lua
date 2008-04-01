KEY_BINDINGS_DISPLAYED = 17;
KEY_BINDING_HEIGHT = 22;

function KeyBindingFrame_OnShow()
	KeyBindingFrame_Update();
end

function KeyBindingFrame_OnLoad()
	this:RegisterForClicks("MiddleButtonUp", "Button4Up", "Button5Up");
	KeyBindingFrame.selected = nil;
	KeyBindingFrame_Update();
end

function KeyBindingFrame_GetLocalizedName(name, prefix)
	if ( not name ) then
		return "";
	end
	local tempName = name;
	local i = strfind(name, "-");
	local dashIndex = nil;
	while ( i ) do
		if ( not dashIndex ) then
			dashIndex = i;
		else
			dashIndex = dashIndex + i;
		end
		tempName = strsub(tempName, i + 1);
		i = strfind(tempName, "-");
	end

	local modKeys = '';
	if ( not dashIndex ) then
		dashIndex = 0;
	else
		modKeys = strsub(name, 1, dashIndex);
	end

	local variablePrefix = prefix;
	if ( not variablePrefix ) then
		variablePrefix = "";
	end
	local localizedName = nil;
	if ( IsMacClient() ) then
		localizedName = getglobal(variablePrefix..tempName.."_MAC");
	end
	if ( not localizedName ) then
		localizedName = getglobal(variablePrefix..tempName);
	end
	if ( localizedName ) then
		return modKeys..localizedName;
	else 
		return name;
	end
end

function KeyBindingFrame_Update()
	local numBindings = GetNumBindings();
	local keyOffset;
	local keyBindingButton1, keyBindingButton2, commandName, binding1, binding2;
	local keyBindingName, keyBindingDescription;
	local keyBindingButton1NormalTexture, keyBindingButton1PushedTexture;
	for i=1, KEY_BINDINGS_DISPLAYED, 1 do
		keyOffset = FauxScrollFrame_GetOffset(KeyBindingFrameScrollFrame) + i;
		if ( keyOffset <= numBindings) then
			keyBindingButton1 = getglobal("KeyBindingFrameBinding"..i.."Key1Button");
			keyBindingButton1NormalTexture = getglobal("KeyBindingFrameBinding"..i.."Key1ButtonNormalTexture");
			keyBindingButton1PushedTexture = getglobal("KeyBindingFrameBinding"..i.."Key1ButtonPushedTexture");
			keyBindingButton2NormalTexture = getglobal("KeyBindingFrameBinding"..i.."Key2ButtonNormalTexture");
			keyBindingButton2PushedTexture = getglobal("KeyBindingFrameBinding"..i.."Key2ButtonPushedTexture");
			keyBindingButton2 = getglobal("KeyBindingFrameBinding"..i.."Key2Button");
			keyBindingDescription = getglobal("KeyBindingFrameBinding"..i.."Description");
			-- Set binding text
			commandName, binding1, binding2 = GetBinding(keyOffset);
			-- Handle header
			local headerText = getglobal("KeyBindingFrameBinding"..i.."Header");
			if ( strsub(commandName, 1, 6) == "HEADER" ) then
				headerText:SetText(getglobal("BINDING_"..commandName));
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
					keyBindingButton1:SetText(KeyBindingFrame_GetLocalizedName(binding1, "KEY_"));
					--keyBindingButton1:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up");
					--keyBindingButton1:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down");
					keyBindingButton1NormalTexture:SetAlpha(1);
					keyBindingButton1PushedTexture:SetAlpha(1);
				else
					keyBindingButton1:SetText(NORMAL_FONT_COLOR_CODE..NOT_BOUND..FONT_COLOR_CODE_CLOSE);
					--keyBindingButton1:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up");
					--keyBindingButton1:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down");
					keyBindingButton1NormalTexture:SetAlpha(0.8);
					keyBindingButton1PushedTexture:SetAlpha(0.8);
				end
				if ( binding2 ) then
					keyBindingButton2:SetText(KeyBindingFrame_GetLocalizedName(binding2, "KEY_"));
					keyBindingButton2NormalTexture:SetAlpha(1);
					keyBindingButton2PushedTexture:SetAlpha(1);
				else
					keyBindingButton2:SetText(NORMAL_FONT_COLOR_CODE..NOT_BOUND..FONT_COLOR_CODE_CLOSE);
					keyBindingButton2NormalTexture:SetAlpha(0.8);
					keyBindingButton2PushedTexture:SetAlpha(0.8);
				end
				-- Set description
				keyBindingDescription:SetText(KeyBindingFrame_GetLocalizedName(commandName, "BINDING_NAME_"));
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
				getglobal("KeyBindingFrameBinding"..i):Show();
			end
		else
			getglobal("KeyBindingFrameBinding"..i):Hide();
		end
	end
	
	-- Scroll frame stuff
	FauxScrollFrame_Update(KeyBindingFrameScrollFrame, numBindings, KEY_BINDINGS_DISPLAYED, KEY_BINDING_HEIGHT );
end

function KeyBindingFrame_OnKeyDown(button)
	if ( arg1 == "PRINTSCREEN" ) then
		Screenshot();
		return;
	end

	-- Convert the mouse button names
	if ( button == "LeftButton" ) then
		button = "BUTTON1";
	elseif ( button == "RightButton" ) then
		button = "BUTTON2";
	elseif ( button == "MiddleButton" ) then
		button = "BUTTON3";
	elseif ( button == "Button4" ) then
		button = "BUTTON4"
	elseif ( button == "Button5" ) then
		button = "BUTTON5"
	end
	if ( KeyBindingFrame.selected ) then
		local keyPressed = arg1;
		if ( button ) then
			if ( button == "BUTTON1" or button == "BUTTON2" ) then
				return;
			end
			keyPressed = button;
		else
			keyPressed = arg1;
		end
		if ( keyPressed == "UNKNOWN" ) then
			return;
		end
		if ( keyPressed == "SHIFT" or keyPressed == "CTRL" or keyPressed == "ALT") then
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
		local oldAction = GetBindingAction(keyPressed);
		if ( oldAction ~= "" and oldAction ~= KeyBindingFrame.selected ) then
			local key1, key2 = GetBindingKey(oldAction);
			if ( (not key1 or key1 == keyPressed) and (not key2 or key2 == keyPressed) ) then
				--Error message
				KeyBindingFrameOutputText:SetText(format(KEY_UNBOUND_ERROR, KeyBindingFrame_GetLocalizedName(oldAction, "BINDING_NAME_")));
			end
		else
			KeyBindingFrameOutputText:SetText(KEY_BOUND);
		end
		local key1, key2 = GetBindingKey(KeyBindingFrame.selected);
		if ( key1 ) then
			SetBinding(key1);
		end
		if ( key2 ) then
			SetBinding(key2);
		end
		if ( KeyBindingFrame.keyID == 1 ) then
			KeyBindingFrame_SetBinding(keyPressed, KeyBindingFrame.selected, key1);
			if ( key2 ) then
				SetBinding(key2, KeyBindingFrame.selected);
			end
		else
			if ( key1 ) then
				KeyBindingFrame_SetBinding(key1, KeyBindingFrame.selected);
			end
			KeyBindingFrame_SetBinding(keyPressed, KeyBindingFrame.selected, key2);
		end
		KeyBindingFrame_Update();
		-- Button highlighting stuff
		KeyBindingFrame.selected = nil;
		KeyBindingFrame.buttonPressed:UnlockHighlight();
	else
		if ( arg1 == "ESCAPE" ) then
			ResetBindings();
			KeyBindingFrameOutputText:SetText("");
			KeyBindingFrame.selected = nil;
			HideUIPanel(this);
		end
	end
end

function KeyBindingButton_OnClick(button)
	if ( KeyBindingFrame.selected ) then
		-- Code to be able to deselect or select another key to bind
		if ( button == "LeftButton" or button == "RightButton" ) then
			-- Deselect button if it was the pressed previously pressed
			if (KeyBindingFrame.buttonPressed == this) then
				KeyBindingFrame.selected = nil;
				KeyBindingFrameOutputText:SetText("");
			else
				-- Select a different button
				KeyBindingFrame.buttonPressed = this;
				KeyBindingFrame.selected = this.commandName;
				KeyBindingFrame.keyID = this:GetID();
				KeyBindingFrameOutputText:SetText(format(BIND_KEY_TO_COMMAND, KeyBindingFrame_GetLocalizedName(this.commandName, "BINDING_NAME_")));
			end
			KeyBindingFrame_Update();
			return;
		end
		KeyBindingFrame_OnKeyDown(button);
	else
		if (KeyBindingFrame.buttonPressed) then
			KeyBindingFrame.buttonPressed:UnlockHighlight();
		end
		KeyBindingFrame.buttonPressed = this;
		KeyBindingFrame.selected = this.commandName;
		KeyBindingFrame.keyID = this:GetID();
		KeyBindingFrameOutputText:SetText(format(BIND_KEY_TO_COMMAND, KeyBindingFrame_GetLocalizedName(this.commandName, "BINDING_NAME_")));
		KeyBindingFrame_Update();
	end
end

function KeyBindingFrame_SetBinding(key, selectedBinding, oldKey)
	if ( SetBinding(key, selectedBinding) ) then
		return;
	else
		if ( oldKey ) then
			SetBinding(oldKey, selectedBinding);
		end
		--Error message
		KeyBindingFrameOutputText:SetText("Can't bind mousewheel to actions with up and down states");
	end
end
