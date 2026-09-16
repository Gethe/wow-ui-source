GamepadSharedUtility.BindingStack.InputAxisBinding = {};
local InputAxisBinding = GamepadSharedUtility.BindingStack.InputAxisBinding;

local function IsStickCentered(stick)
	local state = C_GamePad.GetDeviceMappedState();
	if not state then
		return true;
	end
	for i = 1, state.stickCount do
		local configName = C_GamePad.StickIndexToConfigName(i - 1); -- This function is 0 based...
		if configName == stick then
			return state.sticks[i].len == 0;
		end
	end
	return true; -- Assume it is
end

local inputAxisListener = CreateFrame("FRAME", "inputBindingAxisListener");
inputAxisListener.left = { isCentered = IsStickCentered("Movement") };
inputAxisListener.right = { isCentered = IsStickCentered("Camera") };

local function UpdateEventRegistration()
	local needsEvent = inputAxisListener.left.func
		or inputAxisListener.right.func
		or inputAxisListener.left.waitForCentering
		or inputAxisListener.right.waitForCentering;

	inputAxisListener:EnableGamePadStick(needsEvent);
end

inputAxisListener:SetScript("OnGamepadStick", function(self, stick, x, y)
	local function handleStick(side)
		side.isCentered = x == 0 and y == 0;

		if side.waitForCentering then
			if not side.isCentered then
				return false;
			end

			side.waitForCentering = nil;
			UpdateEventRegistration();
		end

		if side.func then
			return side.func(x, y);
		end

		return true;
	end

	local unhandled = true;
	if stick == "Movement" then
		unhandled = handleStick(self.left);
	elseif stick == "Camera" then
		unhandled = handleStick(self.right);
	end
	return unhandled;
end);

function InputAxisBinding:Init(key, boundFunction)
	assert(key == GAMEPAD_STICK_LEFT or key == GAMEPAD_STICK_RIGHT, "InputAxisBinding requires GAMEPAD_STICK_LEFT or GAMEPAD_STICK_RIGHT, got " .. tostring(key));

	self.key = key;
	self.name = key; -- A name is required for the binding set table, but re-using the key works here because they are unique per binding set.
	self.boundFunction = boundFunction;
	self.type = "InputAxisBinding";
	self.isActive = false;
	self.set = nil;
end

local function ReplaceAxisFunction(key, boundFunction)
	if key == GAMEPAD_STICK_LEFT then
		inputAxisListener.left.func = boundFunction;
		inputAxisListener.left.waitForCentering = not inputAxisListener.left.isCentered;
	elseif key == GAMEPAD_STICK_RIGHT then
		inputAxisListener.right.func = boundFunction;
		inputAxisListener.right.waitForCentering = not inputAxisListener.right.isCentered;
	end

	UpdateEventRegistration();
end

function InputAxisBinding:Bind()
	ReplaceAxisFunction(self.key, self.boundFunction);

	self.set.manager:SetNewActiveKey(self);
	self.isActive = true;
end

function InputAxisBinding:Unbind()
	ReplaceAxisFunction(self.key, nil);
end

function InputAxisBinding:OnOverbound()
	self.isActive = false;
end

function InputAxisBinding:ToString()
	return self.key .. " = (function) " .. " | " .. tostring(self.isActive);
end
