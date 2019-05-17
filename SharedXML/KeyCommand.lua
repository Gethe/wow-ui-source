local generalMetaKeys =
{
	SHIFT = IsShiftKeyDown,
	CTRL = IsControlKeyDown,
	ALT = IsAltKeyDown,
};

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