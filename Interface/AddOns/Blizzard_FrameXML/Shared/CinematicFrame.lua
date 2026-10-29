
local AspectRatios = {};

AspectRatios[Enum.CameraModeAspectRatio.Default] = {x = 0, y = 0};
AspectRatios[Enum.CameraModeAspectRatio.LegacyLetterbox] = {x = 16, y = 9};
AspectRatios[Enum.CameraModeAspectRatio.HighDefinition_16_X_9] = {x = 16, y = 9};
AspectRatios[Enum.CameraModeAspectRatio.Cinemascope_2_Dot_4_X_1] = {x = 2.4, y = 1};

local DefaultAspectRatio = {x = 16, y = 9};

function CinematicFrame_UpdateLettboxForAspectRatio(self)
	-- called when the display changes and when the cinematic camera wants to 
	-- either adjust the aspect ratio or add the legacy letterbox
	if not (self:IsShown()) then
		return;
	end

	if self.forcedAspectRatio == Enum.CameraModeAspectRatio.LegacyLetterbox then
		local width = CinematicFrame:GetWidth();
		local height = CinematicFrame:GetHeight();

		local viewableHeight = width * DefaultAspectRatio.y / DefaultAspectRatio.x;
		local halfDiff = math.max(math.floor((height - viewableHeight) / 2.0), 0);

		WorldFrame:ClearAllPoints();
		WorldFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 0, -halfDiff);
		WorldFrame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, halfDiff);

		local blackBarHeight = math.max(halfDiff, 40);
		UpperBlackBar:SetHeight( blackBarHeight );
		LowerBlackBar:SetHeight( blackBarHeight );
			
		UpperBlackBar:SetShown(true);
		LowerBlackBar:SetShown(true);
	else
		UpperBlackBar:SetShown(false);
		LowerBlackBar:SetShown(false);

		local height, width, actualRatio;
		local requestedRatio = AspectRatios[self.forcedAspectRatio];
		if requestedRatio then
			height = requestedRatio.y * WorldFrame:GetWidth() / requestedRatio.x;
			width = requestedRatio.x * WorldFrame:GetHeight() / requestedRatio.y;
			actualRatio = requestedRatio.x / requestedRatio.y;
		else
			height = DefaultAspectRatio.y * WorldFrame:GetWidth() / DefaultAspectRatio.x;
			width = DefaultAspectRatio.x * WorldFrame:GetHeight() / DefaultAspectRatio.y;
			actualRatio = DefaultAspectRatio.x / DefaultAspectRatio.y;
		end
		local physicalWidth, physicalHeight = GetPhysicalScreenSize();
		local screenRatio = physicalWidth / physicalHeight;

		WorldFrame:ClearAllPoints();
		if actualRatio > screenRatio then -- letterbox
			WorldFrame:SetHeight(1);
			WorldFrame:SetPoint("LEFT", nil, "LEFT", 0, 0);
			WorldFrame:SetPoint("RIGHT", nil, "RIGHT", 0, 0);
			WorldFrame:SetHeight(height);
		elseif actualRatio < screenRatio then --pillarbox
			WorldFrame:SetWidth(1);
			WorldFrame:SetPoint("TOP", nil, "TOP", 0, 0);
			WorldFrame:SetPoint("BOTTOM", nil, "BOTTOM", 0, 0);
			WorldFrame:SetWidth(width);				
		else -- perfect match
			WorldFrame:SetAllPoints();
		end
	end
end

function CinematicFrame_OnLoad(self)
	self.forcedAspectRatio = Enum.CameraModeAspectRatio.LegacyLetterbox;
	self:RegisterEvent("CINEMATIC_START");
	self:RegisterEvent("CINEMATIC_STOP");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");

	CinematicFrame_RegisterForTransition(self);
end

function CinematicFrame_OnHide(self)
	WorldFrame:SetAllPoints(nil);
end

function CinematicFrame_RegisterForTransition(self)
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(CinematicFrame_SetupGamepad, self));
end

function CinematicFrame_SetupGamepad(self)
	self.binding = GamepadMode.CreateBindingGroup("CinematicFrameBindings");
	self.binding:BlockEverything();
	self.binding:AddFunctionBinding(GAMEPAD_FACE_BOTTOM, function()
		CinematicFrameCloseDialogConfirmButton:Click();
	end);
	self.binding:AddFunctionBinding(GAMEPAD_FACE_RIGHT, function()
		CinematicFrameCloseDialogResumeButton:Click();
	end);

	self.confirmIcon = GamepadMode.AddGamepadIconToButton(CinematicFrameCloseDialogConfirmButton, GAMEPAD_FACE_BOTTOM);
	self.resumeIcon = GamepadMode.AddGamepadIconToButton(CinematicFrameCloseDialogResumeButton, GAMEPAD_FACE_RIGHT);

	GamepadMode.SetGamepadIconShown(self.confirmIcon, false);
	GamepadMode.SetGamepadIconShown(self.resumeIcon, false);

	CinematicFrameCloseDialog.FocusGamepad = function()
		GamepadMode.SetGamepadIconShown(self.confirmIcon, true);
		GamepadMode.SetGamepadIconShown(self.resumeIcon, true);
		GamepadMode.ActivateBindingGroup(self.binding);
	end

	CinematicFrameCloseDialog.UnfocusGamepad = function()
		GamepadMode.DeactivateBindingGroup(self.binding);
		GamepadMode.SetGamepadIconShown(self.confirmIcon, false);
		GamepadMode.SetGamepadIconShown(self.resumeIcon, false);
	end
end

function CinematicFrame_OnEvent(self, event, ...)	
	if ( event == "CINEMATIC_START" ) then
		local canBeCancelled, forcedAspectRatio = ...;
		EventRegistry:TriggerEvent("CinematicFrame.CinematicStarting");

		self.isRealCinematic = canBeCancelled;	--If it isn't real, it's a vehicle cinematic
		self.forcedAspectRatio = forcedAspectRatio;	
		self.closeDialog:Hide();
		ShowUIPanel(self, 1);
		self.BossEmoteFrame:ClearMessages(RaidWarningUtil.MessageType.BossEmote);
		CinematicFrame_UpdateLettboxForAspectRatio(self);

		EventRegistry:TriggerEvent("Subtitles.OnMovieCinematicPlay", self);

		LowHealthFrame:EvaluateVisibleState();
	elseif ( event == "CINEMATIC_STOP" ) then
		HideUIPanel(self);

		-- Clear the normal boss emote messages. If there are any messages left over from the cinematic, we don't want to show them.
		RaidWarningUtil.ClearBossEmotes();

		LowHealthFrame:EvaluateVisibleState();

		EventRegistry:TriggerEvent("Subtitles.OnMovieCinematicStop");

		MovieFrame:OnCinematicStopped();
		EventRegistry:TriggerEvent("CinematicFrame.CinematicStopped");
	elseif ( event == "DISPLAY_SIZE_CHANGED") then
		if (self:IsShown()) then
			WorldFrame:SetAllPoints();
		end
		CinematicFrame_UpdateLettboxForAspectRatio(self);
	end
end

local function ExitCinematic(self)
	if ( self.isRealCinematic and IsGMClient() ) then
		StopCinematic();
	elseif ( self.isRealCinematic ) then
		self.closeDialog:Show();
	elseif ( IsInCinematicScene() ) then
		if ( CanCancelScene() ) then
			self.closeDialog:Show();
		end
	elseif ( CanExitVehicle() ) then	--If it's not a real cinematic, we can cancel it by leaving the vehicle.
		self.closeDialog:Show();
	end
end

function CinematicFrame_OnKeyDown(self, key)
	local keybind = GetBindingFromClick(key);
	if ( keybind == "TOGGLEGAMEMENU" ) then
		ExitCinematic(self);
	elseif ( keybind == "SCREENSHOT" or keybind == "TOGGLEMUSIC" or keybind == "TOGGLESOUND" ) then
		RunBinding(keybind);
	end
end

function CinematicFrame_OnGamePadButtonDown(self, button)
	if InputUtil.IsGamepadUIEnabled() then
		if GamepadMode.IsBindingGroupActive(self.binding) then
			-- Return early and propagate input so the bindings can handle the input instead when the dialog is shown.
			-- Frames with `OnGamePadButtonDown` handlers take input precedance over override bindings and core bindings.
			return true;
		end
		if (button == GAMEPAD_MENU_RIGHT) or (button == GAMEPAD_FACE_RIGHT) then
			ExitCinematic(self);
		end
	else
		local keybind = GetBindingFromClick(button);
		if (keybind == "TOGGLEGAMEMENU") then
			ExitCinematic(self);
		end
	end
end

function CinematicFrame_CancelCinematic()
	if ( CinematicFrame.isRealCinematic ) then
		StopCinematic();
	elseif ( CanCancelScene() ) then
		CancelScene();
	else
		VehicleExit();
	end
end

CinematicFrameCloseDialogMixin = {};

function CinematicFrameCloseDialogMixin:OnShow()
	MouseOverrideCinematicDisable(true);

	if InputUtil.IsGamepadUIEnabled() then
		GamepadMode.FrameControlsManager:HandlePopupShown(self);
	end
end

function CinematicFrameCloseDialogMixin:OnHide()
	MouseOverrideCinematicDisable(false);

	if InputUtil.IsGamepadUIEnabled() then
		GamepadMode.FrameControlsManager:HandlePopupHide(self);
	end
end
