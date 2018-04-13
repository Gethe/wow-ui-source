local metaKeys =
{
	LSHIFT = 1,
	RSHIFT = 2,
	LCTRL = 3,
	RCTRL = 4,
	LALT = 5,
	RALT = 6,
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
	if IsShiftKeyDown() then
		table.insert(chord, "SHIFT");
	end

	if IsControlKeyDown() then
		table.insert(chord, "CTRL");
	end

	if IsAltKeyDown() then
		table.insert(chord, "ALT");
	end

	if not IsMetaKey(key) then
		table.insert(chord, key);
	end

	local preventSort = true;
	return CreateKeyChordStringFromTable(chord, preventSort);
end
