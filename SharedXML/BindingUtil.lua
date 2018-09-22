local metaKeys =
{
	LALT = 1,
	RALT = 2,
	LCTRL = 3,
	RCTRL = 4,
	LSHIFT = 5,
	RSHIFT = 6,
};

local ignoredKeys =
{
	UNKNOWN = true,
	BUTTON1 = true,
	BUTTON2 = true,
	-- And metakeys
};

local mouseButtonNameConversion =
{
	LeftButton = "BUTTON1",
	RightButton = "BUTTON2",
	MiddleButton = "BUTTON3",
	Button1 = "BUTTON1",
	Button2 = "BUTTON2",
	Button3 = "BUTTON3",
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

function GetConvertedKeyOrButton(keyOrButton)
	return mouseButtonNameConversion[keyOrButton] or keyOrButton;
end

function IsMouseButton(button)
	return mouseButtonNameConversion[button] ~= nil;
end

function IsLeftMouseButton(button)
	return mouseButtonNameConversion[button] == "BUTTON1";
end

function IsRightMouseButton(button)
	return mouseButtonNameConversion[button] == "BUTTON2";
end

function IsMiddleMouseButton(button)
	return mouseButtonNameConversion[button] == "BUTTON3";
end

function IsMetaKey(key)
	return metaKeys[key] ~= nil;
end

function IsKeyPressIgnoredForBinding(key)
	return IsMetaKey(key) or ignoredKeys[key] == true;
end

local function KeyComparator(key1, key2)
	local key1Priority = metaKeys[key1];
	local key2Priority = metaKeys[key2];
	if key1Priority and key2Priority then
		return key1Priority < key2Priority;
	end

	return key1Priority ~= nil;
end

function CreateKeyChordStringFromTable(keys, preventSort)
	if not preventSort then
		table.sort(keys, KeyComparator);
	end

	return table.concat(keys, "-");
end

function CreateKeyChordString(key)
	local chord = {};
	if IsAltKeyDown() then
		table.insert(chord, "ALT");
	end

	if IsControlKeyDown() then
		table.insert(chord, "CTRL");
	end

	if IsShiftKeyDown() then
		table.insert(chord, "SHIFT");
	end

	if not IsMetaKey(key) then
		table.insert(chord, key);
	end

	local preventSort = true;
	return CreateKeyChordStringFromTable(chord, preventSort);
end

function GetBindingName(binding)
	local bindingName = _G["BINDING_NAME_"..binding];
	if ( bindingName ) then
		return bindingName;
	end

	return binding;
end

function GetBindingKeyForAction(action, useNotBound, useParentheses)
	local key = GetBindingKey(action);
	if key then
		key = GetBindingText(key);
	elseif useNotBound then
		key = NOT_BOUND;
	end

	if key and useParentheses then
		return ("(%s)"):format(key);
	end

	return key;
end

-- Gets the key string for the action and formats it into keyStringFormat, then formats
-- that and the original text into bindingAvailableFormat and returns the resulting string.
-- NOTE: The argument ordering for bindingAvailableFormat should be original text and then binding string text.
-- NOTE: If there is no binding and useNotBound is set, then the NOT_BOUND string is formatted into the location
-- where the key string would normally appear, otherwise only the original text is returned.
function FormatBindingKeyIntoText(text, action, bindingAvailableFormat, keyStringFormat, useNotBound, useParentheses)
	local bindingKey = GetBindingKeyForAction(action, useNotBound, useParentheses);

	if bindingKey then
		bindingAvailableFormat = bindingAvailableFormat or "%s %s";
		keyStringFormat = keyStringFormat or "%s";
		local keyString = keyStringFormat:format(bindingKey);
		return bindingAvailableFormat:format(text, keyString);
	end

	return text;
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

function BindingButtonTemplate_SetupBindingButton(binding, button)
	local bindingText;

	if button.GetCustomBindingType and button:GetCustomBindingType() ~= nil then
		bindingText = CustomBindingManager:GetBindingText(button:GetCustomBindingType());
	elseif binding then
		bindingText = GetBindingText(binding);
	end

	if bindingText then
		button:SetText(bindingText);
		button:SetAlpha(1);
	else
		button:SetText(GRAY_FONT_COLOR:WrapTextInColorCode(NOT_BOUND));
		button:SetAlpha(0.8);
	end
end