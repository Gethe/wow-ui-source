--[[
	Creates a button that takes down click with
	the given name

	name: Name for the button
	onLClick: Function to run on left mouse click (optional)
	onRClick: Function to run on right mouse click (optional)
	registerType: Table that can contain "AnyUp" and/or "AnyDown" to specify
				  register click type
	inheritFrame: String of frame to inherit from

	returns: Button frame with the given name registered for clicks
]]
function GamepadSharedUtility.CreateDownClickButton(name, parent, onLClick, onRClick, registerType, inheritFrame)
	-- Type check
	assert(type(name) == "string" or not name, "Param name is the wrong type")
	assert(type(parent) == "string" or type(parent) == "table", "Param parent is the wrong type")
	assert(type(onLClick) == "function" or not onLClick, "Param onLClick is the wrong type")
	assert(type(onRClick) == "function" or not onRClick, "Param onRClick is the wrong type")
	assert(type(registerType) == "table" or not registerType, "Param registerType is the wrong type")
	assert(type(inheritFrame) == "string" or not inheritFrame, "Param inheritFrame is the wrong type")

	-- Defaults
	if (not registerType) then registerType = GAMEPAD_BUTTON_ANY_DOWN end

	-- Create frame
	local button = nil
	if (inheritFrame) then
		button = CreateFrame("Button", name, parent, inheritFrame)
	else
		button = CreateFrame("Button", name, parent)
	end
	button:RegisterForClicks(unpack(registerType))
	button:SetScript("OnClick", function(self, mouseButton, down)
		if (mouseButton == "LeftButton") then
			if (onLClick) then onLClick(self, mouseButton, down) end
		else
			if (onRClick) then onRClick(self, mouseButton, down) end
		end
	end)

	return button
end

function GamepadSharedUtility.CreateHoldClickHandler(timeUntilConsideredHold, onDownCallback, onHeldCallback, onTapCallback, onHeldReleasedCallback)
	local handlerData = {};

	local function holdClickHandler(handlerData, clickedButton, mouseButton, down)
		local function OnHeld()
			if (onHeldCallback) then
				onHeldCallback(clickedButton, mouseButton, down);
			end
			-- Clear the timer so that we don't run a tap.
			handlerData.holdTimer = nil;
		end

		if (down) then
			if (onDownCallback) then
				onDownCallback(clickedButton, mouseButton, down);
			end

			handlerData.holdTimer = C_Timer.NewTimer(timeUntilConsideredHold, OnHeld);
		elseif (handlerData.holdTimer) then
			handlerData.holdTimer:Cancel();

			if (onTapCallback) then
				onTapCallback(clickedButton, mouseButton, down);
			end
		else
			if (onHeldReleasedCallback) then
				onHeldReleasedCallback(clickedButton, mouseButton, down);
			end
		end
	end

	return GenerateClosure(holdClickHandler, handlerData);
end
