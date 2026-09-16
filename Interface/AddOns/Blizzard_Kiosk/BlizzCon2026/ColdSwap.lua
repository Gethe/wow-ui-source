local PopUpKeys = {
	GAMEPAD_DIALOG = "COLDSWAP_GAMEPAD_CONFIRM_DIALOG",
	MKB_DIALOG = "COLDSWAP_MKB_CONFIRM_DIALOG",
};

--[[
	ColdSwap is the functional capacity for the game to swap interface styles in
	response to user action. This is primarily achieved by listening to input
	and firing an Autocode event to _attempt_ the hot swap.
	At time of this addon's creation, the gamepad implementation is so tightly
	coupled to the concept of being in "gamepad mode", it becomes necessary to
	reload the UI to achieve proper input handling. This addon's primary purpose 
	is to (in response to input button press) surface the user with the 
	opportunity to swap input modes.

	NOTE: This is BlizzCon-ONLY functionality, and does not solve the core
	problems of hot-swapping or hybrid input. It is named "ColdSwap" intentionally,
	and is only a band-aid solution for the conference.
]]
local GamepadColdSwap = {
	frame = nil,

	-- Carve out modifier keys in case they are involved in actions
	passthroughKeys = {
		["RSHIFT"] = true,
		["LSHIFT"] = true,
		["RCTRL"] = true,
		["LCTRL"] = true,
		["RALT"] = true,
		["LALT"] = true,
	},

	passthroughActions = {
		["OPENCHAT"] = true,
		["OPENCHATSLASH"] = true,
		["TOGGLEGAMEMENU"] = true,
	}
};

-- Constructs a binding string based on held keys (ex. "CTRL-SHIFT-ENTER")
local function BuildBindingString(key)
	local parts = {};

	if IsAltKeyDown() and key ~= "LALT" and key ~= "RALT" then
		table.insert(parts, "ALT");
	end

	if IsControlKeyDown() and key ~= "LCTRL" and key ~= "RCTRL" then
		table.insert(parts, "CTRL");
	end

	if IsShiftKeyDown() and key ~= "LSHIFT" and key ~= "RSHIFT" then
		table.insert(parts, "SHIFT");
	end

	table.insert(parts, key);

	return table.concat(parts, "-");
end

function GamepadColdSwap:Init()
	self:SetupPopupDialogs();

	PopupEventManager:RegisterCallback("PopupOpened", GenerateClosure(self.OnPopupOpened, self));

	self.frame = CreateFrame("Frame", nil, UIParent);
	self.frame:SetFrameStrata("TOOLTIP");
	self.frame:SetScript("OnKeyDown", function(frame, key) return self:OnKeyDown(key); end);
	self.frame:SetScript("OnGamePadButtonDown", function(frame, button) return self:OnGamepadButtonDown(button); end);
	self.frame:SetScript("OnGamePadButtonUp", function(frame, button) return self:OnGamepadButtonUp(button); end);
	self.frame:SetScript("OnGamePadStick", function(frame, stick, x, y) return self:OnGamepadStick(stick, x, y); end);
	self.frame:SetScript("OnEvent", function(frame, ...) self:OnFrameEvent(...); end);
end

function GamepadColdSwap:OnFrameEvent(event, ...)
	if (event == "BC_26_COLD_SWAP_FEATURE_ENABLED_CHANGED" or event == "BC_26_EXPERIENCE_CHANGED") then
		self:OnEnabledConditionsChanged();
	end
end

function GamepadColdSwap:OnEnabledConditionsChanged()
	local isColdSwapEnabled = BlizzCon2026:IsColdSwapEnabled();
	if (not isColdSwapEnabled) then
		if (StaticPopup_Visible(PopUpKeys.MKB_DIALOG)) then
			StaticPopup_Hide(PopUpKeys.MKB_DIALOG);
		end

		if (StaticPopup_Visible(PopUpKeys.GAMEPAD_DIALOG)) then
			StaticPopup_Hide(PopUpKeys.GAMEPAD_DIALOG);
		end
	end
end

function GamepadColdSwap:SetupPopupDialogs()
	StaticPopupDialogs[PopUpKeys.GAMEPAD_DIALOG] = {
		text = COLDSWAP_TEXT_CONFIRM_GAMEPAD,
		button1 = YES,
		button2 = CANCEL,
		OnAccept = GenerateClosure(self.HandleGamepadDialogConfirm, self),
		OnCancel = GenerateClosure(self.HandleGamepadDialogCancel, self),
		timeout = 0,
		exclusive = 1,
		hideOnEscape = true,
	};

	StaticPopupDialogs[PopUpKeys.MKB_DIALOG] = {
		text = COLDSWAP_TEXT_CONFIRM_MKB,
		button1 = YES,
		button2 = CANCEL,
		OnAccept = GenerateClosure(self.HandleMkbDialogConfirm, self),
		OnCancel = GenerateClosure(self.HandleMkbDialogCancel, self),
		timeout = 0,
		exclusive = 1,
		hideOnEscape = true,
	};
end

function GamepadColdSwap:HandleGamepadDialogConfirm()
	SetCVar("InputDeviceInterfaceStyle", Enum.InputDeviceInterfaceType.Gamepad);
end

function GamepadColdSwap:HandleGamepadDialogCancel()

end

function GamepadColdSwap:HandleMkbDialogConfirm()
	SetCVar("InputDeviceInterfaceStyle", Enum.InputDeviceInterfaceType.Mkb);
end

function GamepadColdSwap:HandleMkbDialogCancel()

end

function GamepadColdSwap:OnKeyDown(key)
	if KioskModeSplashEnd:IsShown() then
		return false;
	end

	local isColdSwapEnabled = BlizzCon2026:IsColdSwapEnabled();
	if (not isColdSwapEnabled) then
		return true;
	end

	if InputUtil.IsMKBUIEnabled() then
		return true;
	end

	if (self.passthroughKeys[key]) then
		return true;
	end

	local keyString = BuildBindingString(key);
	local keyAction = GetBindingAction(keyString, true);
	if (self.passthroughActions[keyAction]) then
		return true;
	end

	local keyboardFocusFrame = GetCurrentKeyBoardFocus();
	if keyboardFocusFrame and keyboardFocusFrame:IsObjectType("EditBox") and keyboardFocusFrame:HasFocus() then
		return true;
	end

	if BlizzCon2026:IsSkyborneExperience() and (not StaticPopup_Visible(PopUpKeys.MKB_DIALOG)) then
		StaticPopup_Show(PopUpKeys.MKB_DIALOG);
	end

	return false;
end

local function PropagatePadInput()
	if BlizzCon2026:IsDungeonExperience() and InputUtil.IsMKBUIEnabled() then
		return false;
	end

	local isColdSwapEnabled = BlizzCon2026:IsColdSwapEnabled();
	if (not isColdSwapEnabled) then
		return true;
	end

	if InputUtil.IsGamepadUIEnabled() then
		return true;
	end

	return false;
end

function GamepadColdSwap:OnGamepadButtonDown(button)
	if KioskModeSplashEnd:IsShown() then
		return false;
	end

	if PropagatePadInput() then
		return true;
	end

	local visible, dialog = StaticPopup_Visible(PopUpKeys.GAMEPAD_DIALOG);
	if BlizzCon2026:IsSkyborneExperience() and (not visible) then
		StaticPopup_Show(PopUpKeys.GAMEPAD_DIALOG);
		return;
	end

	if visible then
		if button == GAMEPAD_FACE_BOTTOM then
			local dialogButton = dialog:GetButton1();
			if dialogButton:IsShown() and dialogButton:IsEnabled() then
				dialogButton:Click();
			end
		elseif button == GAMEPAD_FACE_RIGHT then
			local dialogButton = dialog:GetButton2();
			if dialogButton:IsShown() and dialogButton:IsEnabled() then
				dialogButton:Click();
			end
		end
	end

	return false;
end

function GamepadColdSwap:OnGamepadButtonUp(button)
	if KioskModeSplashEnd:IsShown() then
		return false;
	end

	if PropagatePadInput() then
		return true;
	end

	return false;
end

function GamepadColdSwap:OnGamepadStick(stick, x, y)
	if KioskModeSplashEnd:IsShown() then
		return false;
	end

	if PropagatePadInput() then
		return true;
	end

	return false;
end

function GamepadColdSwap:OnPopupOpened(_, dialog)
	if dialog.which ~= PopUpKeys.GAMEPAD_DIALOG then
		return;
	end

	dialog.gamepadIcons = dialog.gamepadIcons or {};

	if not dialog.gamepadIcons[GAMEPAD_FACE_BOTTOM] then
		local button1 = dialog:GetButton1();
		local icon1 = GamepadMode.AddGamepadIconToButton(button1, GAMEPAD_FACE_BOTTOM);
		dialog.gamepadIcons[GAMEPAD_FACE_BOTTOM] = icon1;
	end

	if not dialog.gamepadIcons[GAMEPAD_FACE_RIGHT] then
		local button2 = dialog:GetButton2();
		local icon2 = GamepadMode.AddGamepadIconToButton(button2, GAMEPAD_FACE_RIGHT);
		dialog.gamepadIcons[GAMEPAD_FACE_RIGHT] = icon2;
	end

	if not dialog.gamepadIcons[GAMEPAD_FACE_LEFT] then
		local button3 = dialog:GetButton3();
		local icon3 = GamepadMode.AddGamepadIconToButton(button3, GAMEPAD_FACE_LEFT);
		dialog.gamepadIcons[GAMEPAD_FACE_LEFT] = icon3;
	end

	dialog:SetAlpha(1.0);
	for k,v in pairs(dialog.gamepadIcons) do
		v:SetAlpha(1.0);
		GamepadMode.SetGamepadIconShown(v, true);
	end
end

GamepadColdSwap:Init();
