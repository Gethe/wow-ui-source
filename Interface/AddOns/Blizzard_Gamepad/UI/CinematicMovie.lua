--[[
	Handles showing UI and controls of skipping movies/cinematics
]]

local function SetUpDialog(frameName, parent)
	local function CloseMovieOnComplete()
		if (parent == MovieFrame) then
			MovieFrame_OnKeyUp(MovieFrame, "SPACE");
			MovieFrame.CloseDialog.ConfirmButton:Click();
		else
			if (IsInCinematicScene() and CanCancelScene()) then
				CancelScene();
			elseif (InCinematic()) then
				StopCinematic();
				return;
			end
		end
	end

	local SKIP_BUTTON = GAMEPAD_MENU_RIGHT;
	local button = GamepadMode.CreateHoldButtonWithTextFromTemplate(
		frameName,
		parent,
		CloseMovieOnComplete,
		SKIP,
		nil,
		SKIP_BUTTON
	);

	button:SetPoint("TOPRIGHT", -100, -5);

	button:SetScript("OnGamePadButtonDown", function(self, gamepadButton)
		if (gamepadButton == SKIP_BUTTON) then
			self:Click("LeftButton", true);
		end
	end);
	button:SetScript("OnGamePadButtonUp", function(self, gamepadButton)
		if (gamepadButton == SKIP_BUTTON) then
			self:Click("LeftButton", false);
		end
	end);
	button:EnableGamePadButton(true);
end

local function SetupGamepad()
	-- Declare our custom handler functions so the soft cursor knows not to take control of the default frames
	MovieFrame.Activate = function(self) end
	MovieFrame.Deactivate = function(self) end
	CinematicFrame.Activate = function(self) end
	CinematicFrame.Deactivate = function(self) end

	SetUpDialog("GamepadMovieSkipButton", MovieFrame);
	SetUpDialog("GamepadCinematicSkipButton", CinematicFrame);
end

local function SetUp()
	local gamepadCinematic = { "GamepadCinematic" };
	InputUtil.RegisterForInterfaceTransitions(gamepadCinematic);
	InputUtil.RegisterGamepadSetup(gamepadCinematic, function ()
		SetupGamepad();
	end);
end

EventUtil.ContinueOnVariablesLoaded(SetUp)
