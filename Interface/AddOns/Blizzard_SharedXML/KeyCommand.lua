local generalMetaKeys =
{
	SHIFT = IsShiftKeyDown,
	CTRL = IsControlKeyDown,
	ALT = IsAltKeyDown,
	META = IsMetaKeyDown,
};

function GetBindingFullInput(input)
	local fullInput = "";
	-- MUST BE IN THIS ORDER (ALT, CTRL, SHIFT, META)
	if ( IsAltKeyDown() ) then
		fullInput = fullInput.."ALT-";
	end

	if ( IsControlKeyDown() ) then
		fullInput = fullInput.."CTRL-"
	end

	if ( IsShiftKeyDown() ) then
		fullInput = fullInput.."SHIFT-"
	end

	if ( IsMetaKeyDown() ) then
		fullInput = fullInput.."META-"
	end

	if ( input == "LeftButton" ) then
		fullInput = fullInput.."BUTTON1";
	elseif ( input == "RightButton" ) then
		fullInput = fullInput.."BUTTON2";
	elseif ( input == "MiddleButton" ) then
		fullInput = fullInput.."BUTTON3";
	elseif ( input == "Button4" ) then
		fullInput = fullInput.."BUTTON4";
	elseif ( input == "Button5" ) then
		fullInput = fullInput.."BUTTON5";
	elseif ( input == "Button6" ) then
		fullInput = fullInput.."BUTTON6";
	elseif ( input == "Button7" ) then
		fullInput = fullInput.."BUTTON7";
	elseif ( input == "Button8" ) then
		fullInput = fullInput.."BUTTON8";
	elseif ( input == "Button9" ) then
		fullInput = fullInput.."BUTTON9";
	elseif ( input == "Button10" ) then
		fullInput = fullInput.."BUTTON10";
	elseif ( input == "Button11" ) then
		fullInput = fullInput.."BUTTON11";
	elseif ( input == "Button12" ) then
		fullInput = fullInput.."BUTTON12";
	elseif ( input == "Button13" ) then
		fullInput = fullInput.."BUTTON13";
	elseif ( input == "Button14" ) then
		fullInput = fullInput.."BUTTON14";
	elseif ( input == "Button15" ) then
		fullInput = fullInput.."BUTTON15";
	elseif ( input == "Button16" ) then
		fullInput = fullInput.."BUTTON16";
	elseif ( input == "Button17" ) then
		fullInput = fullInput.."BUTTON17";
	elseif ( input == "Button18" ) then
		fullInput = fullInput.."BUTTON18";
	elseif ( input == "Button19" ) then
		fullInput = fullInput.."BUTTON19";
	elseif ( input == "Button20" ) then
		fullInput = fullInput.."BUTTON20";
	elseif ( input == "Button21" ) then
		fullInput = fullInput.."BUTTON21";
	elseif ( input == "Button22" ) then
		fullInput = fullInput.."BUTTON22";
	elseif ( input == "Button23" ) then
		fullInput = fullInput.."BUTTON23";
	elseif ( input == "Button24" ) then
		fullInput = fullInput.."BUTTON24";
	elseif ( input == "Button25" ) then
		fullInput = fullInput.."BUTTON25";
	elseif ( input == "Button26" ) then
		fullInput = fullInput.."BUTTON26";
	elseif ( input == "Button27" ) then
		fullInput = fullInput.."BUTTON27";
	elseif ( input == "Button28" ) then
		fullInput = fullInput.."BUTTON28";
	elseif ( input == "Button29" ) then
		fullInput = fullInput.."BUTTON29";
	elseif ( input == "Button30" ) then
		fullInput = fullInput.."BUTTON30";
	elseif ( input == "Button31" ) then
		fullInput = fullInput.."BUTTON31";
	else
		fullInput = fullInput..input;
	end

	return fullInput;
end

function GetBindingFromInput(input)
	local fullInput = GetBindingFullInput(input);
	return GetBindingByKey(fullInput);
end

-- May deprecate GetBindingFromClick.
GetBindingFromClick = GetBindingFromInput;

local keyStates = {};

local function IsSingleKeyDown(key)
	if generalMetaKeys[key] then
		return generalMetaKeys[key]();
	end

	return IsKeyDown(key);
end

local function IsCommandKeyDown(key)
	for index, keyName in ipairs(key) do
		if not IsSingleKeyDown(keyName) then
			return false;
		end
	end

	return true;
end

KeyCommand =
{
	RUN_ON_UP = true,
	RUN_ON_DOWN = false,
};

function KeyCommand:OnLoad(command, runOnUp, key)
	self:SetCommand(command);
	self:SetKey(runOnUp, key);
end

function KeyCommand:Update()
	local isDown = IsCommandKeyDown(self.key);

	-- Press
	if not self.isDown and isDown then
		self.isDown = true;
		if not self.runOnUp then
			self.command();
			self:MarkCommandFired();
		end
	end

	-- Release
	if self.isDown and not isDown then
		self.isDown = false;
		if self.runOnUp and self:CanFireCommand() then
			self.command();
		end

		self:CheckResetCommand();
	end
end

function KeyCommand:MarkCommandFired()
	for index, keyName in ipairs(self.key) do
		keyStates[keyName] = self;
	end
end

function KeyCommand:CanFireCommand()
	for index, keyName in ipairs(self.key) do
		if keyStates[keyName] ~= nil then
			return false;
		end
	end

	return true;
end

function KeyCommand:CheckResetCommand()
	for index, keyName in ipairs(self.key) do
		if IsSingleKeyDown(keyName) then
			return;
		end

		keyStates[keyName] = nil;
	end
end

function KeyCommand:SetKey(mode, key)
	self.runOnUp = (mode == KeyCommand.RUN_ON_UP);
	self.key = key;
end

function KeyCommand:SetCommand(command)
	assert(type(command) == "function");
	self.command = command;
end

function KeyCommand_Create(command, runOnUp, key)
	local keyCommand = CreateFromMixins(KeyCommand);
	keyCommand:OnLoad(command, runOnUp, key);
	return keyCommand;
end

function KeyCommand_CreateKey(...)
	return { ... };
end

function KeyCommand_Update(commands)
	for index, command in pairs(commands) do
		if command:Update() then
			return true;
		end
	end
end