GamepadSharedUtility.BindingStack.InputFunctionBinding = {};
local InputFunctionBinding = GamepadSharedUtility.BindingStack.InputFunctionBinding;

--[[ 
	In order to override an input binding, we have to route the input to a custom button,
	but when we only care about the key->function portion, we can re-use a local set of buttons instead of making new ones.
]]
local InputFunctionBindingButtons = {};

local function GetOrCreateInputFunctionBindingButton(key)
	-- If we have an existing button for this key, use that.
	for _, button in ipairs(InputFunctionBindingButtons) do
		if button.key == key then
			return button;
		end
	end

	-- Else, create a new one that starts with nil input handlers.
	local newButtonName = "InputFunctionBindingButton_" .. key;
	local newButton = GamepadSharedUtility.CreateDownClickButton(newButtonName, UIParent);
	newButton.name = newButtonName;
	newButton.key = key;
	table.insert(InputFunctionBindingButtons, newButton);
	return newButton;
end

local function ReplaceButtonClickFunc(button, onLeftClickFunc, onRightClickFunc)
	button:SetScript("OnClick", function(self, mouseButton, down)
		if (mouseButton == "LeftButton") then
			if onLeftClickFunc then 
				onLeftClickFunc(down); 
			end
		else
			if onRightClickFunc then 
				onRightClickFunc(down); 
			end
		end
	end);
end

local function ReplaceButtonRegisterTypes(button, registerTypes)
	button:RegisterForClicks(unpack(registerTypes)); -- This overwrites the existing event mask.
end

local function SetActiveInputFunctionBinding(key, boundFunction, mouseButton, registerTypes)
	local buttonForKey = GetOrCreateInputFunctionBindingButton(key);
	ReplaceButtonClickFunc(buttonForKey, boundFunction);
	ReplaceButtonRegisterTypes(buttonForKey, registerTypes);
	SetOverrideBindingClick(UIParent, true, key, buttonForKey.name, mouseButton);
end

function InputFunctionBinding:Init(key, boundFunction, mouseButton, registerTypes, overboundCallback)
	self.key = key;
	self.name = key; -- A name is required for the binding set table, but re-using the key works here because they are unique per binding set.
	self.boundFunction = boundFunction;
	self.mouseButton = mouseButton;
	self.registerTypes = registerTypes;
	self.overboundCallback = overboundCallback;
	self.type = "InputFunctionBinding";
	self.isActive = false;
	self.set = nil;
end

function InputFunctionBinding:Bind()
	SetActiveInputFunctionBinding(self.key, self.boundFunction, self.mouseButton, self.registerTypes);

	self.set.manager:SetNewActiveKey(self);
	self.isActive = true;
end

function InputFunctionBinding:OnOverbound()
	self.isActive = false;
	if (self.overboundCallback) then
		self.overboundCallback();
	end
end

function InputFunctionBinding:ToString()
	return self.key .. " = (function) " .. " | " .. tostring(self.isActive);
end
