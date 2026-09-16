local BindingGroupMixin = {};

local bindingSets = {};
local nextBindingGroupId = 0;

local function GetModifiedKeyName(modifier, key)
	return modifier .. "-" .. key;
end

--[[
	A binding group is a set of named entries that map one or more inputs to a command.
	A command can be a button click or a game action.
	Binding groups are pushed onto the input stack using GamepadMode.ActivateBindingGroup() or GamepadMode.DeactivateBindingGroup().
]]
function BindingGroupMixin:Init(bindingGroupName)
	self.name = bindingGroupName;
	self.buttons = {};
	self.actions = {};
	self.functions = {};
	self.axes = {};
	self.treatBindsAsCore = false;
	self.nextButtonId = 1;
	self.nextFunctionId = 1;
end

--[[
	Button bindings attempt to find the named button frame in LUA and call "OnClick" on it.
]]
function BindingGroupMixin:AddButtonBinding(keyNameOrNames, buttonFrameName, optionalMouseButtonName)
	if type(keyNameOrNames) ~= "table" then
		keyNameOrNames = {keyNameOrNames};
	end

	self:RemoveKeys(keyNameOrNames);

	if not optionalMouseButtonName then
		optionalMouseButtonName = "LeftButton";
	end

	local buttonId = self.nextButtonId;
	self.buttons[buttonId] = {};
	self.buttons[buttonId].keys = keyNameOrNames;
	self.buttons[buttonId].button = buttonFrameName;
	self.buttons[buttonId].mouseButton = optionalMouseButtonName;
	self.nextButtonId = buttonId + 1;
end

--[[
	Function bindings call the function argument directly.
	To handle both button up and down events, add GAMEPAD_BUTTON_ANY_DOWN_OR_UP as the register type.
	Bool "IsDown" will be passed as the first (non-self) argument to the handler function.
]]
function BindingGroupMixin:AddFunctionBinding(keyNameOrNames, functionToBind, optionalRegisterTypes, optionalOverboundCallback)
	if type(keyNameOrNames) ~= "table" then
		keyNameOrNames = {keyNameOrNames};
	end

	self:RemoveKeys(keyNameOrNames);

	if not optionalRegisterTypes then
		optionalRegisterTypes = GAMEPAD_BUTTON_ANY_DOWN;
	end

	local funcId = self.nextFunctionId;
	self.functions[funcId] = {};
	self.functions[funcId].keys = keyNameOrNames;
	self.functions[funcId].func = functionToBind;
	self.functions[funcId].mouseButton = "LeftButton";
	self.functions[funcId].registerTypes = optionalRegisterTypes;
	self.functions[funcId].overboundCallback = optionalOverboundCallback;
	self.nextFunctionId = funcId + 1;
end

--[[
	An axis binding binds GAMEPAD_STICK_LEFT or GAMEPAD_STICK_RIGHT to a function that takes (x , y) as arguments.
]]
function BindingGroupMixin:AddAxisBinding(keyName, axisFunctionToBind)
	self.axes[keyName] = axisFunctionToBind;
end

--[[
	By default, unhandled inputs will fall through to lower Binding Groups on the input stack. We can create empty binds to block that.
	Note that modified and un-modified versions of the same key name are treated as separate and you probably want to block all versions.
]]
function BindingGroupMixin:BlockKeysWithoutModifiers(keyNameOrNames)
	self:AddButtonBinding(keyNameOrNames, "");
end

function BindingGroupMixin:BlockKeysWithModifiers(keyNameOrNames)
	if type(keyNameOrNames) ~= "table" then
		keyNameOrNames = {keyNameOrNames};
	end

	for _, key in ipairs(keyNameOrNames) do
		local blockKeyNames = {
			GetModifiedKeyName(GAMEPAD_MOD_LEFT, key);
			GetModifiedKeyName(GAMEPAD_MOD_RIGHT, key);
			GetModifiedKeyName(GAMEPAD_MOD_LEFT_AND_RIGHT, key);
		};
		self:BlockKeysWithoutModifiers(blockKeyNames);
	end
end

function BindingGroupMixin:BlockKeys(keyNameOrNames)
	self:BlockKeysWithoutModifiers(keyNameOrNames);
	self:BlockKeysWithModifiers(keyNameOrNames)
end

function BindingGroupMixin:BlockDpad()
	self:BlockKeys({
		GAMEPAD_DPAD_RIGHT,
		GAMEPAD_DPAD_TOP,
		GAMEPAD_DPAD_LEFT,
		GAMEPAD_DPAD_BOTTOM
	});
end

function BindingGroupMixin:BlockDpadAndFaceButtons()
	self:BlockKeys({
		GAMEPAD_DPAD_RIGHT,
		GAMEPAD_DPAD_TOP,
		GAMEPAD_DPAD_LEFT,
		GAMEPAD_DPAD_BOTTOM,
		GAMEPAD_FACE_RIGHT,
		GAMEPAD_FACE_TOP,
		GAMEPAD_FACE_LEFT,
		GAMEPAD_FACE_BOTTOM
	});
end

function BindingGroupMixin:BlockEverything()
	self:BlockKeys({
		GAMEPAD_DPAD_RIGHT,
		GAMEPAD_DPAD_TOP,
		GAMEPAD_DPAD_LEFT,
		GAMEPAD_DPAD_BOTTOM,
		GAMEPAD_FACE_RIGHT,
		GAMEPAD_FACE_TOP,
		GAMEPAD_FACE_LEFT,
		GAMEPAD_FACE_BOTTOM
	});
	self:BlockKeysWithoutModifiers({
		GAMEPAD_STICK_LEFT,
		GAMEPAD_SHOULDER_LEFT,
		GAMEPAD_SHOULDER_RIGHT
	});
end

function BindingGroupMixin:RemoveKeys(keyNameOrNames)
	if type(keyNameOrNames) ~= "table" then
		keyNameOrNames = {keyNameOrNames};
	end

	for _, button in ipairs (self.buttons) do
		for _, key in ipairs(keyNameOrNames) do
			for i = #button.keys, 1, -1 do
				if button.keys[i] == key then
					table.remove(button.keys, i);
				end
			end
		end
	end

	for _, func in ipairs (self.functions) do
		for _, key in ipairs(keyNameOrNames) do
			for i = #func.keys, 1, -1 do
				if func.keys[i] == key then
					table.remove(func.keys, i);
				end
			end
		end
	end
end

--[[
	The "Core" binding group is the bottom of the stack and handles gameplay input actions.
	If all active binding groups should be "treated as core", the gamepad UI will assume we are still in a gameplay input state.
]]
function BindingGroupMixin:TreatAsCore()
	self.treatBindsAsCore = true;
end

--[[
	Gets controller icon key(s) for given key name table
	keyNames: table of key names from bindings
	return: Table containing the filepaths for each key in the binding
]]
function GamepadMode.GetBindingKeyIconsFromNames(keyNames)
	local keyIcons = nil;

	if (keyNames) then
		keyIcons = {};
		for i=1, #keyNames, 1 do
			keyIcons[i] = InputIconTextureSetUtility.GetNormalActiveInputIconButtonTexture(keyNames[i]);
		end
	end

	return keyIcons;
end

local function CreateCoreBindingSet()
	local inputBindingSet = GamepadSharedUtility.BindingStack.InputBindingSet;
	local coreBindingSet = CreateAndInitFromMixin(inputBindingSet, "Core", GamepadSharedUtility.InputBindingManager);
	local coreBindingTable = {
		actions = {
			gameMenu = {keys = {GAMEPAD_MENU_RIGHT}, action = "OPENRADIAL"},
			openHUD = {keys = {GAMEPAD_MENU_LEFT}, action = "TOGGLEUIFOCUS"},
			autoRun = {keys = {GAMEPAD_STICK_LEFT_PRESS}, action = "TOGGLEAUTORUN"},
			togglePingSystem = {keys = {GAMEPAD_STICK_RIGHT_PRESS}, action = "TOGGLEPINGSYSTEM"},
		}
	};

	coreBindingSet:AddActionBindings(coreBindingTable.actions);
	bindingSets["Core"] = coreBindingSet;
	GamepadSharedUtility.InputBindingManager:SetCoreBindingSet(coreBindingSet);
end

local function GenerateBindingSet(name, bindingTable)
	local inputBindingSet = GamepadSharedUtility.BindingStack.InputBindingSet;
	local set = CreateAndInitFromMixin(inputBindingSet, name, GamepadSharedUtility.InputBindingManager);
	if (bindingTable.actions) then
		set:AddActionBindings(bindingTable.actions);
	end
	if (bindingTable.buttons) then
		set:AddButtonBindings(bindingTable.buttons);
	end
	if (bindingTable.functions) then
		set:AddFunctionBindings(bindingTable.functions);
	end
	if (bindingTable.axes) then
		set:AddAxisBindings(bindingTable.axes);
	end
	set.treatBindsAsCore = bindingTable.treatBindsAsCore;
	bindingSets[name] = set;
end

function GamepadMode.CreateBindingGroup(optionalDebugName)
	local newBindingGroupName = optionalDebugName and (optionalDebugName .. "_" .. nextBindingGroupId) or nextBindingGroupId;
	local newBindingGroup = CreateAndInitFromMixin(BindingGroupMixin, newBindingGroupName, GamepadSharedUtility.InputBindingManager);
	nextBindingGroupId = nextBindingGroupId + 1;
	return newBindingGroup;
end

-- This step is performed on first activation, but can optionally be performed when declaring binding groups if they need to be shared.
function GamepadMode.CacheBindingGroup(bindingGroup)
	GenerateBindingSet(bindingGroup.name, bindingGroup);
end

function GamepadMode.UncacheBindingGroup(bindingGroup)
	bindingSets[bindingGroup.name] = nil;
end

function GamepadMode.ActivateBindingGroup(bindingGroup, alwaysOnTop)
	if bindingSets[bindingGroup.name] == nil then
		GamepadMode.CacheBindingGroup(bindingGroup);
	end
	GamepadSharedUtility.InputBindingManager:AddBindingSet(bindingSets[bindingGroup.name], alwaysOnTop);
end

function GamepadMode.DeactivateBindingGroup(bindingGroup)
	if bindingSets[bindingGroup.name] == nil then
		return;
	end
	GamepadSharedUtility.InputBindingManager:RemoveSet(bindingSets[bindingGroup.name]);
end

if (not InGlue()) then
	CreateCoreBindingSet();
end
