--[[
	Helper class that binds behavior to static popup open and close events for gamepad focus visuals and input routing.
]]

local DEFOCUSED_ALPHA = 0.5;

GamepadPopupHandler = {};

function GamepadPopupHandler:Init()
	self.visiblePopups = {};
	self.activePopup = nil;

	self:TrackPopupFrames();
	GamepadMode.PopupHandler = self;

	self:InitializeBindings();
end

function GamepadPopupHandler:InitializeBindings()
	self.gamepadBindings = GamepadMode.CreateBindingGroup("GamepadPopupHandlerBindings");
	self.gamepadBindings:BlockEverything();

	self.gamepadBindings:AddFunctionBinding(GAMEPAD_FACE_BOTTOM,
											GenerateClosure(self.TryClickOrHoldButton, self, GAMEPAD_FACE_BOTTOM),
											GAMEPAD_BUTTON_ANY_DOWN_OR_UP);

	self.gamepadBindings:AddFunctionBinding(GAMEPAD_FACE_RIGHT,
											GenerateClosure(self.TryClickOrHoldButton, self, GAMEPAD_FACE_RIGHT),
											GAMEPAD_BUTTON_ANY_DOWN_OR_UP);

	self.gamepadBindings:AddFunctionBinding(GAMEPAD_FACE_LEFT,
											GenerateClosure(self.TryClickOrHoldButton, self, GAMEPAD_FACE_LEFT),
											GAMEPAD_BUTTON_ANY_DOWN_OR_UP);

	if (not InGlue()) then
		self.gamepadBindings:AddFunctionBinding(GAMEPAD_FACE_TOP,
												GenerateClosure(self.TryClickOrHoldButton, self, GAMEPAD_FACE_TOP),
												GAMEPAD_BUTTON_ANY_DOWN_OR_UP);

		self.gamepadBindings:AddFunctionBinding(GAMEPAD_STICK_RIGHT_PRESS,
												GenerateClosure(self.TryClickOrHoldButton, self, GAMEPAD_STICK_RIGHT_PRESS),
												GAMEPAD_BUTTON_ANY_DOWN_OR_UP);
	end
end

local function AddGamepadIcons(dialog)
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

	if not InGlue() then

		if not dialog.gamepadIcons[GAMEPAD_FACE_TOP] then
			local button4 = dialog:GetButton4();
			local icon4 = GamepadMode.AddGamepadIconToButton(button4, GAMEPAD_FACE_TOP);
			dialog.gamepadIcons[GAMEPAD_FACE_TOP] = icon4;
		end

		if not dialog.gamepadIcons[GAMEPAD_STICK_RIGHT_PRESS] then
			local button5 = dialog.ExtraButton;
			local icon5 = GamepadMode.AddGamepadIconToButton(button5, GAMEPAD_STICK_RIGHT_PRESS);
			dialog.gamepadIcons[GAMEPAD_STICK_RIGHT_PRESS] = icon5;
		end
	end
end

local function UpdateGamepadUI(dialog)
	if InputUtil.IsGamepadUIEnabled() and dialog:IsShown() then
		if dialog.gamepadFocused then
			dialog:SetAlpha(1.0);
			for _, frame in pairs(dialog.gamepadIcons) do
				GamepadMode.SetGamepadIconShown(frame, true);
			end
		else
			dialog:SetAlpha(DEFOCUSED_ALPHA);
			for _, frame in pairs(dialog.gamepadIcons) do
				GamepadMode.SetGamepadIconShown(frame, false);
			end
		end
	else
		--[[
			This case is called when the dialog is closed rather than just
			unfocused. In this case we need to hide the gamepad icons and reset
			the alpha value back to full so that the dialog is prepared for MKB
			mode in case the dialog isn't opened again before a interface switch
			occurs.
		]]
		for _, frame in pairs(dialog.gamepadIcons) do
			GamepadMode.SetGamepadIconShown(frame, false);
		end
		dialog:SetAlpha(1.0);
	end
end

function GamepadPopupHandler:UpdateVisiblePopups()
	for _, popup in ipairs(self.visiblePopups) do
		UpdateGamepadUI(popup);
	end
end

local function IsDeletePopup(dialog)
	local popupType = dialog.which;
	return popupType == "DELETE_ITEM" or
		popupType == "DELETE_QUEST_ITEM" or
		popupType == "DELETE_GOOD_ITEM" or
		popupType == "DELETE_GOOD_QUEST_ITEM";
end

local function GamepadButtonToGetter(button)
	local map = {
		[GAMEPAD_FACE_BOTTOM] = "GetButton1",
		[GAMEPAD_FACE_RIGHT] = "GetButton2",
		[GAMEPAD_FACE_LEFT] = "GetButton3",
		[GAMEPAD_FACE_TOP] = "GetButton4",
		[GAMEPAD_STICK_RIGHT_PRESS] = "GetExtraButton",
	};
	return map[button];
end

local function ClickPopupButton(dialog, padButton)
	if not dialog then
		return;
	end

	local buttonGetterFuncKey = GamepadButtonToGetter(padButton);
	local buttonGetter = dialog[buttonGetterFuncKey];
	if not buttonGetter then
		return;
	end

	local button = buttonGetter(dialog);
	if (button:IsShown() and button:IsEnabled()) then
		button:Click();
	end
end

local function GetHoldButton(dialog)
	local map = {
		-- TODO(mwinkler):
		--  These have been commented out to revert back to button press instead of hold
		--  for RC since we do not have final art yet.
		--["RECOVER_CORPSE"] = GAMEPAD_FACE_BOTTOM,
		--["DEATH"] = GAMEPAD_FACE_BOTTOM,
	};
	return map[dialog.which];
end

local function OnPopupUpdate(dialog, elapsed)
	local holdButtons = dialog.gamepadHoldButtons;
	if not holdButtons then
		return;
	end

	for k,v in pairs(holdButtons) do
		v.holdTimeLeft = v.holdTimeLeft - elapsed;
		if v.holdTimeLeft <= 0.0 then
			holdButtons[k] = nil;
			ClickPopupButton(dialog, k);
		else
			local alpha = v.holdTimeLeft / v.holdTime;
			local icon = dialog.gamepadIcons[k];
			icon:SetAlpha(alpha);
		end
	end
end

function GamepadPopupHandler:InitializePopup(dialog)
	if not dialog.gamepadPopupInitialized then
		AddGamepadIcons(dialog);

		dialog.useCustomNavigation = true;
		dialog.FocusGamepad = function() self:FocusPopup(dialog) end;
		dialog.UnfocusGamepad = function() self:ClearFocus() end;

		dialog.gamepadHoldButtons = {};

		dialog.gamepadPopupInitialized = true;
	end

	local dialogInfo = dialog.dialogInfo;
	if not dialogInfo.gamepadPopupInitialized then

		if dialogInfo.OnUpdate then
			hooksecurefunc(dialogInfo, "OnUpdate", OnPopupUpdate);
		else
			dialogInfo.OnUpdate = OnPopupUpdate;
		end

		dialogInfo.gamepadPopupInitialized = true;
	end
end

function GamepadPopupHandler:TrackPopupFrames()
	local function OnPopupOpened(_, dialog)
		self:InitializePopup(dialog);
		table.insert(self.visiblePopups, dialog);

		for k,v in pairs(dialog.gamepadIcons) do
			v:SetAlpha(1.0);
		end

		if IsDeletePopup(dialog) then
			SmartNavigation:SetItemToBeDeleted(GetCursorInfo());
		end

		GamepadMode.FrameControlsManager:HandlePopupShown(dialog);
		self:UpdateVisiblePopups();
	end

	local function OnPopupClosed(_, dialog)
		local index = -1;

		for i, popup in ipairs(self.visiblePopups) do
			if popup == dialog then
				index = i;
				break;
			end
		end

		if index > 0 then
			UpdateGamepadUI(self.visiblePopups[index]); -- Update early because we remove it from the bulk update.
			table.remove(self.visiblePopups, index);
		end

		local needHold = GetHoldButton(dialog);

		if IsDeletePopup(dialog) then
			SmartNavigation:ClearItemToBeDeleted();
		elseif needHold then
			dialog.gamepadHoldButtons[needHold] = nil;
		end

		if self.activePopup == dialog then
			self:ClearFocus();
		end

		self:UpdateVisiblePopups();

		-- If available, resume frame focus on the suspended frame that started the StaticPopup.
		if (GamepadMode.FrameControlsManager:IsFrameSuspended()) then
			GamepadMode.FrameControlsManager:UnsuspendFrame();
		end

		GamepadMode.FrameControlsManager:HandlePopupHide(dialog)
	end

	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, function()
		PopupEventManager:RegisterCallback("PopupOpened", OnPopupOpened, self);
		PopupEventManager:RegisterCallback("PopupClosed", OnPopupClosed, self);
	end);
	InputUtil.RegisterGamepadUninit(self, function()
		PopupEventManager:UnregisterCallback("PopupOpened", self);
		PopupEventManager:UnregisterCallback("PopupClosed", self);
	end);
end

function GamepadPopupHandler:TryClickOrHoldButton(button, down)
	local dialog = self.activePopup;
	if not dialog then
		return;
	end

	local needHold = GetHoldButton(dialog);

	if needHold ~= button then
		if down then
			ClickPopupButton(dialog, button);
		end
		return;
	end

	if down then
		dialog.gamepadHoldButtons[needHold] = { holdTime = 2.0, holdTimeLeft = 2.0 };
	else
		dialog.gamepadIcons[needHold]:SetAlpha(1.0);
		dialog.gamepadHoldButtons[needHold] = nil;
	end
end

function GamepadPopupHandler:IsStaticPopupShowing()
	return #self.visiblePopups > 0;
end

function GamepadPopupHandler:FocusPopup(dialog)
	if self:IsStaticPopupShowing() and dialog then
		self.activePopup = dialog;
		self.activePopup.gamepadFocused = true;

		self:UpdateVisiblePopups();
		self:EnableBindings();

		if (not InGlue()) then
			dialog:OnGainGamepadFocus();
		end
	end
end

function GamepadPopupHandler:ClearFocus()
	if self.activePopup then
		self.activePopup.gamepadFocused = false;

		-- "hideOnEscape" implies the popup must be actioned on immediately or dismissed; if we try to unfocus it, treat that as an escape.
		if self.activePopup.hideOnEscape then
			StaticPopup_EscapePressed();
		end

		-- Closing successfully will clear our active popup, if still present we can unfocus it.
		if self.activePopup and not InGlue() then
			self.activePopup:OnLoseGamepadFocus();
		end
		self.activePopup = nil;
	end
	
	self:UpdateVisiblePopups();
	self:DisablePopupBindings();
end

function GamepadPopupHandler:EnableBindings()
	GamepadMode.ActivateBindingGroup(self.gamepadBindings);
end

function GamepadPopupHandler:DisablePopupBindings()
	GamepadMode.DeactivateBindingGroup(self.gamepadBindings);
end
