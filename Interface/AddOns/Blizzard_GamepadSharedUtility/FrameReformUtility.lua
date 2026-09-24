--[[
	Contains functions that are commonly needed for reforming
	frames
]]

local X_OFFSET = -3;
local Y_OFFSET = 0;
local BUTTON_HEIGHT_RATIO = 0.8;

--[[
	Creates an icon texture for labeling buttons

	button: Button frame to have frame childed to
	gamepadButtonName: Name of the button that will be use to label the button

	opts: table of options
	{
	  buttonHeightScale: scale factor applied to `button` height to compute the final icon size
	  hookEnableDisableScript: Whether to hook `OnEnable` and `OnDisable`

	  See `UpdateGamepadIconAnchor` for more options.
	}
]]
function GamepadMode.AddGamepadIconToButton(button, gamepadButtonName, opts)
	assert(type(button) == "table", "Param button is invalid type");
	assert(type(gamepadButtonName) == "string", "Param gamepadButtonName is invalid type");
	assert((opts == nil) or (type(opts) == "table"), "Param opts is invalid type");

	opts = opts or {};

	local buttonHeightScale = opts.buttonHeightScale or BUTTON_HEIGHT_RATIO;
	local hookEnableDisableScript = opts.hookEnableDisableScript or true;

	local icon = CreateFrame("FRAME", nil, button, "InputIconTextureFrameTemplate");
	icon:SetInputKey(gamepadButtonName);
	local iconSize = math.floor(button:GetHeight() * buttonHeightScale);
	icon:SetSize(iconSize, iconSize);
	icon.gamepadShown = true;

	GamepadMode.UpdateGamepadIconAnchor(icon, opts);

	if hookEnableDisableScript then
		local buttonEnableScript = button:GetScript("OnEnable");
		local buttonDisableScript = button:GetScript("OnDisable");

		local function OnEnable(self)
			if buttonEnableScript then
				buttonEnableScript(self);
			end
			GamepadMode.UpdateGamepadIconAnchor(icon, opts);
		end

		local function OnDisable(self)
			if buttonDisableScript then
				buttonDisableScript(self);
			end
			GamepadMode.UpdateGamepadIconAnchor(icon, opts);
		end

		button:SetScript("OnEnable", OnEnable);
		button:SetScript("OnDisable", OnDisable);
	end

	return icon;
end

--[[
	Updates the anchors for the icon and text accommodating for if the icon is shown or hidden and
	if the button is enabled or not.

	icon: the icon to have its anchors updated

	opts: table of options
	{
	  showFontOffset: font string offset from button center when the icon is shown
	  hideFontOffset: font string offset from button center when the icon is hidden
	}
]]
function GamepadMode.UpdateGamepadIconAnchor(icon, opts)
	assert((opts == nil) or (type(opts) == "table"), "Param opts is invalid type");

	local button = icon:GetParent();
	local buttonEnabled = button:IsEnabled();
	local extraOffset;

	opts = opts or {};

	if buttonEnabled and icon.gamepadShown then
		icon:Show();
		extraOffset = opts.showFontOffset or ((icon:GetWidth() + -X_OFFSET) * 0.5);
	else
		extraOffset = opts.hideFontOffset or 0;
		icon:Hide();
	end

	local fontString = button:GetFontString();
	local _, anchorFrame = icon:GetPoint();
	if fontString then
		-- Update the fontstring's anchor to account for the icon's visibility possibly changing.
		fontString:ClearAllPoints();
		fontString:SetPoint("CENTER", button, "CENTER", extraOffset, 0);

		-- There is a chance the fontstring was not set yet or has changed so re-anchor it if is different from the current anchor.
		if fontString ~= anchorFrame then
			icon:SetPoint("RIGHT", fontString, "LEFT", X_OFFSET, Y_OFFSET);
		end
	else
		icon:SetPoint("CENTER", button, "CENTER", X_OFFSET, Y_OFFSET);
	end
end

--[[
	Sets if an icon should be shown. Icons are still hidden if the button is disabled.

	icon: icon to show/hide
	shouldShow: if the icon should be shown

	opts: See `UpdateGamepadIconAnchor`
]]
function GamepadMode.SetGamepadIconShown(icon, shouldShow, opts)
	assert((opts == nil) or (type(opts) == "table"), "Param opts is invalid type");

	icon.gamepadShown = shouldShow;
	GamepadMode.UpdateGamepadIconAnchor(icon, opts);
end

--[[
	Creates an icon button with text with press-and-hold functionality

	name: Name for the button
	onFinishFunction: Function to run when press-and-hold is completed
	text: Text to display for the label
	timer: Amount of time button will need to be held, in seconds
	iconNames: Icon to show next to the label

	returns: Button frame with the given name registered for click and hold
]]
function GamepadMode.CreateHoldButtonWithTextFromTemplate(name, parent, onFinishFunction, text, timer, iconNames)
	assert(type(name) == "string", "Param name is wrong type");
	assert(type(parent) == "table", "Param parent is wrong type");
	assert(type(text) == "string", "Param text is wrong type");
	assert(not iconNames or type(iconNames) == "string" or type(iconNames) == "table", "Param iconNames is wrong type");
	assert(not onFinishFunction or type(onFinishFunction) == "function", "Param onFinishFunction is wrong type");
	assert(type(timer) == "number" or timer == nil, "Param timer is wrong type");

	if (not onFinishFunction) then
		onFinishFunction = function() end
	end
	local button = CreateFrame("BUTTON", name, parent, "GamepadPressAndHoldButtonTemplate");
	button.textValue = text;
	button.iconNames = {};
	if (iconNames) then
		if (type(iconNames) == "string") then
			iconNames = {iconNames};
		end
		for i=1, #iconNames, 1 do
			button.iconNames[i] = iconNames[i];
		end
	end

	-- Timer defaults to 1.5 seconds if the parameter is nil
	if (timer ~= nil) then
		button.holdTime = timer;
	end

	hooksecurefunc(button, "TimerFinished", onFinishFunction);

	button:OnLoad();

	return button;
end
