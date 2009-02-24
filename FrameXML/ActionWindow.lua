
local ACTION_WINDOW_OFFSET = 0;
local ACTION_WINDOW_SIZE = 0;
local ACTION_WINDOW_BUTTONS = 4;

function ActionWindowMove(angle)
	if ( angle >= math.pi*0.25 and angle <= math.pi*0.75 ) then
		ActionWindowIncrement();
	elseif ( angle >= math.pi*1.25 and angle <= math.pi*1.75 ) then
		ActionWindowDecrement();
	elseif ( angle > math.pi*0.5 ) then
		ActionBar_PageDown();
	else
		ActionBar_PageUp();
	end
end
		
function ActionWindowIncrement()
	if ( (ACTION_WINDOW_OFFSET + ACTION_WINDOW_SIZE) < NUM_ACTIONBAR_BUTTONS ) then
		ACTION_WINDOW_OFFSET = (ACTION_WINDOW_OFFSET + ACTION_WINDOW_SIZE);
	else
		ACTION_WINDOW_OFFSET = 0;
	end
	ActionWindowUpdate();
end

function ActionWindowDecrement()
	if ( ACTION_WINDOW_OFFSET > 0 ) then
		if ( ACTION_WINDOW_OFFSET > ACTION_WINDOW_SIZE ) then
			ACTION_WINDOW_OFFSET = (ACTION_WINDOW_OFFSET - ACTION_WINDOW_SIZE);
		else
			ACTION_WINDOW_OFFSET = 0;
		end
	else
		ACTION_WINDOW_OFFSET = (NUM_ACTIONBAR_BUTTONS - ACTION_WINDOW_SIZE);
	end
	ActionWindowUpdate();
end

function ActionWindowOffset()
	return ACTION_WINDOW_OFFSET;
end

JOYSTICK_BUTTONS = { };
JOYSTICK_BUTTONS["XBOX"] = { };
JOYSTICK_BUTTONS["XBOX"]["JOYBUTTON1"] = { texture = "Interface\\Joystick\\Xbox-Button-A" };
JOYSTICK_BUTTONS["XBOX"]["JOYBUTTON2"] = { texture = "Interface\\Joystick\\Xbox-Button-B" };
JOYSTICK_BUTTONS["XBOX"]["JOYBUTTON3"] = { texture = "Interface\\Joystick\\Xbox-Button-X" };
JOYSTICK_BUTTONS["XBOX"]["JOYBUTTON4"] = { texture = "Interface\\Joystick\\Xbox-Button-Y" };
JOYSTICK_BUTTONS["PLAYSTATION"] = { };
JOYSTICK_BUTTONS["PLAYSTATION"]["JOYBUTTON1"] = { texture = "Interface\\Joystick\\Playstation-Button-T" };
JOYSTICK_BUTTONS["PLAYSTATION"]["JOYBUTTON2"] = { texture = "Interface\\Joystick\\Playstation-Button-C" };
JOYSTICK_BUTTONS["PLAYSTATION"]["JOYBUTTON3"] = { texture = "Interface\\Joystick\\Playstation-Button-X" };
JOYSTICK_BUTTONS["PLAYSTATION"]["JOYBUTTON4"] = { texture = "Interface\\Joystick\\Playstation-Button-S" };
JOYSTICK_BUTTONS["GAMECUBE"] = { };
JOYSTICK_BUTTONS["GAMECUBE"]["JOYBUTTON1"] = { texture = "Interface\\Joystick\\Gamecube-Button-A" };
JOYSTICK_BUTTONS["GAMECUBE"]["JOYBUTTON2"] = { texture = "Interface\\Joystick\\Gamecube-Button-B" };
JOYSTICK_BUTTONS["GAMECUBE"]["JOYBUTTON3"] = { texture = "Interface\\Joystick\\Gamecube-Button-X" };
JOYSTICK_BUTTONS["GAMECUBE"]["JOYBUTTON4"] = { texture = "Interface\\Joystick\\Gamecube-Button-Y" };

JOYSTICK_BUTTON_GENERIC = { texture = "Interface\\Joystick\\Generic-Button-Black" };

function ActionWindowUpdate()
	local joystick = JoystickName() or "";
	if ( strmatch(joystick, "XBOX") or strmatch(joystick, "Xbox2") ) then
		joystick = "XBOX";
	elseif ( strmatch(joystick, "4 axis 16 button joystick") ) then
		joystick = "PLAYSTATION";
	elseif ( strmatch(joystick, "GameCube") ) then
		joystick = "GAMECUBE";
	else
		joystick = "GENERIC";
	end

	ACTION_WINDOW_SIZE = 0;
	for i = 1, ACTION_WINDOW_BUTTONS do
		local frame = _G["ActionWindowButton"..i];
		if ( frame ) then
			local key = GetBindingKey("ACTIONWINDOW"..i);
			if ( key ) then
				ACTION_WINDOW_SIZE = i;

				local info = (JOYSTICK_BUTTONS[joystick] and JOYSTICK_BUTTONS[joystick][key]);
				if ( not info ) then
					info = JOYSTICK_BUTTON_GENERIC;

					if ( strmatch(key, "JOYBUTTON") ) then
						info.label = gsub(key, "JOYBUTTON([0-9]+)", "%1");
					else
						info.label = key;
					end
				end

				local texture = _G["ActionWindowButton"..i.."Texture"];
				if ( texture ) then
					texture:SetTexture(info.texture);
				end

				local label = _G["ActionWindowButton"..i.."Label"];
				if ( label ) then
					label:SetText(info.label);
				end

				frame:SetPoint("BOTTOM", "ActionButton"..(ActionWindowOffset() + i), "TOP");
				frame:Show();
			else
				frame:Hide();
			end
		end
	end
end