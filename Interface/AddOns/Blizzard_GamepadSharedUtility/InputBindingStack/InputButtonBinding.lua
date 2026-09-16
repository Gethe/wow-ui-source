GamepadSharedUtility.BindingStack.InputButtonBinding = {};
local InputButtonBinding = GamepadSharedUtility.BindingStack.InputButtonBinding;

--[[
	key: What physical key will need to be pressed to activate binding
	buttonToClick: Frame button that will be clicked with binding
	name: A name for the binding inside of the binding set it belongs to. Default nil
	mouseButton: Either "LeftButton" or "RightButton", default "LeftButton"
]]
function InputButtonBinding:Init(key, buttonToClick, name, mouseButton)
	if (mouseButton == nil) then
		mouseButton = "LeftButton";
	end

	self.key = key;
	self.name = name;
	self.buttonToClick = buttonToClick;
	self.mouseButton = mouseButton;
	self.type = "InputButtonBinding";
	self.isActive = false;	-- Flag for if the binding is currently active
	self.set = nil;
end

--[[
	Creates OverrideBinding using key, button and mouseButton
]]
function InputButtonBinding:Bind()
	SetOverrideBindingClick(UIParent, true, self.key, self.buttonToClick, self.mouseButton);

	self.set.manager:SetNewActiveKey(self);
	self.isActive = true;
end

--[[
	Called when another binding is bound over this one
]]
function InputButtonBinding:OnOverbound()
	self.isActive = false;
end

--[[
	Converts the binding to a readable string

	return: Binding represented by a string
]]
function InputButtonBinding:ToString()
	return self.key .. " = " .. self.buttonToClick .. " | " .. self.mouseButton .. " | " .. tostring(self.isActive);
end
