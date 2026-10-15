GamepadSharedUtility.BindingStack.InputActionBinding = {};
local InputActionBinding = GamepadSharedUtility.BindingStack.InputActionBinding;

--[[
	key: What physical key will need to be pressed to activate the binding
	action: Binding Action to bind to key (See Bindings_<Flavor>.xml)
	name: A name for the binding inside of the binding set it belongs to. Default nil
]]
function InputActionBinding:Init(key, action, name)
	self.key = key;
	self.action = action;
	self.name = name;
	self.type = "InputActionBinding";
	self.isActive = false;			-- Flag for if the binding is currently active
	self.set = nil;
end

--[[
	Creates OverrideBinding using key and action
]]
function InputActionBinding:Bind()
	SetOverrideBinding(UIParent, true, self.key, self.action);
	self.set.manager:SetNewActiveKey(self);
	self.isActive = true;
end

--[[
	Called when another binding is bound over this one
]]
function InputActionBinding:OnOverbound()
	self.isActive = false;
end

--[[
	Converts the binding to a readable string

	return: Binding represented by a string
]]
function InputActionBinding:ToString()
	return self.key .. " = " .. self.action .. " | " .. tostring(self.isActive);
end
