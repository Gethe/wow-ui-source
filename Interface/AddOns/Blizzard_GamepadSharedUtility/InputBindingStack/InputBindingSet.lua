GamepadSharedUtility.BindingStack.InputBindingSet = {};
local InputBindingSet = GamepadSharedUtility.BindingStack.InputBindingSet;

--[[
	name: Name of binding set, mainly used for debugging
	manager: Which manager the set belongs to.
]]
function InputBindingSet:Init(name, manager)
	self.name = name;
	self.bindings = {};
	self.bindingNameMap = {}; -- Multiple bindings may exist for a single name (multiple keys ==> one button/action)
	self.type = "InputBindingSet";
	self.manager = manager;

	-- Event called when this binding set is buried in the stack
	self.onBuried = {};

	-- Event called when binding set is on the top of the stack after it's been buried
	self.onSurfaced = {};
end

--[[
	Goes through all of the bindings in this set
	and has them bound
]]
function InputBindingSet:BindAll()
	for _, binding in pairs(self.bindings) do
		binding:Bind();
	end
end

--[[
	Adds an InputBinding to the binding set

	binding: InputBinding to add to binding set
]]
function InputBindingSet:AddBinding(binding)
	if (binding.type ~= "InputActionBinding" and binding.type ~= "InputButtonBinding" and
		binding.type ~= "InputFunctionBinding" and binding.type ~= "InputAxisBinding") then
		error("Tried to add a non-InputBinding to the InputBindingSet");
	end

	if (not binding.name) then
		error("Tried to add an input binding to binding set without specifying a name for the binding.");
	end

	-- Clean up any existing bindings for this key
	local existingBinding = self.bindings[binding.key];
	if (existingBinding and self.bindingNameMap[existingBinding.name]) then
		for i, v in ipairs(self.bindingNameMap[existingBinding.name]) do
			if v == existingBinding then
				table.remove(self.bindingNameMap[existingBinding.name], i);
				break;
			end
		end
	end

	self.bindings[binding.key] = binding;
	if (self.bindingNameMap[binding.name]) then
		table.insert(self.bindingNameMap[binding.name], binding);
	else
		self.bindingNameMap[binding.name] = { binding };
	end
	binding.set = self;
end

--[[
	Adds a function GenerateClosure to the onBuried event call.
	Typically this function should be created using GenerateClosure
	so that any parameters that need to be passed along when called
	are.

	funcClosure: Function to be called on the onBuried event
]]
function InputBindingSet:AddFunctionOnBuried(funcClosure)
	if (type(funcClosure) ~= "function") then
		error("Tried to add a non-function to onBuried");
	end

	table.insert(self.onBuried, funcClosure);
end

--[[
	Adds a function GenerateClosure to the onSurfaced event call.
	Typically this function should be created using GenerateClosure
	so that any parameters that need to be passed along when called
	are.

	funcClosure: Function to be called on the onSurfaced event
]]
function InputBindingSet:AddFunctionOnSurfaced(funcClosure)
	if (type(funcClosure) ~= "function") then
		error("Tried to add a non-function to onSurfaced");
	end

	table.insert(self.onSurfaced, funcClosure);
end

--[[
	Runs all functions in the onBuried event
]]
function InputBindingSet:RunOnBuried()
	for _, funcClosure in pairs(self.onBuried) do
		funcClosure();
	end
end

--[[
	Runs all functions in the onSurfaced event
]]
function InputBindingSet:RunOnSurfaced()
	for _, funcClosure in pairs(self.onSurfaced) do
		funcClosure();
	end
end

--[[
	Gets an iterator for all of the bindings

	return: Iterator for all of the bindinds in the set
]]
function InputBindingSet:Iterator()
	return pairs(self.bindings);
end

--[[
	Gets the InputBinding in the set for the given key

	return: InputBinding related to key, nil if none
]]
function InputBindingSet:GetBinding(key)
	return self.bindings[key];
end

--[[
	Puts the set into a readable string

	return: string representing the binding set
]]
function InputBindingSet:ToString()
	local function PrintStayOnTop()
		if (self.stayOnTop) then
			return "Yes";
		else
			return "No";
		end
	end

	local setString = self.name .. "\nAlways on Top: " .. PrintStayOnTop() .. "\n-----------------\n";
	for _, binding in self:Iterator() do
		setString = setString .. binding:ToString() .. "\n";
	end

	return setString;
end

--[[
	Adds a table of action bindings to the bindingSet.
	actionTable: Table of action bindings to create and add to
				 the binding set formatted as follows:

				actionTable =
				{
					bindingName = { keys = {boundKey1, boundKey2, ...}, action = "ACTION_TO_PERFORM"},
	(EXAMPLE)   	jump = { keys = {GAMEPAD_FACE_BOTTOM}, action = "JUMP" },
					...
				}
]]
function InputBindingSet:AddActionBindings(actionTable)
	for bindingName, info in pairs(actionTable) do
		for _, key in pairs(info.keys) do
			local actionBinding = CreateAndInitFromMixin(GamepadSharedUtility.BindingStack.InputActionBinding, key, info.action, bindingName);
			self:AddBinding(actionBinding);
		end
	end
end

--[[
	Adds a table of button bindings to the bindingSet
	buttonTable: Table of button bindings to create and add to
				 the binding set formatted as follows:
					actions =
					{
						bindingName = { keys = {boundKey1, boundKey2, ...}, button = "VIRTUAL_BUTTON_TO_CLICK"},
(EXAMPLE)				OpenRadial = { keys = {GAMEPAD_FACE_BOTTOM}, button = "OpenRadialButton", (OPTIONAL) mouseButton = "<LeftButton/RightButton>" },
						...
					}
]]
function InputBindingSet:AddButtonBindings(buttonTable)
	for bindingName, info in pairs(buttonTable) do
		for _, key in pairs(info.keys) do
			self:AddBinding(CreateAndInitFromMixin(GamepadSharedUtility.BindingStack.InputButtonBinding, key, info.button, bindingName, info.mouseButton));
		end
	end
end

function InputBindingSet:AddFunctionBindings(functionTable)
	for bindingName, info in pairs(functionTable) do
		for _, key in pairs(info.keys) do
			self:AddBinding(CreateAndInitFromMixin(GamepadSharedUtility.BindingStack.InputFunctionBinding, key, info.func, info.mouseButton, info.registerTypes, info.overboundCallback));
		end
	end
end

function InputBindingSet:AddAxisBindings(axisTable)
	for axisKey, axisFunction in pairs(axisTable) do
		self:AddBinding(CreateAndInitFromMixin(GamepadSharedUtility.BindingStack.InputAxisBinding, axisKey, axisFunction));
	end
end

function InputBindingSet:GetAllBindingsUsingName(bindingName)
	return self.bindingNameMap[bindingName];
end
