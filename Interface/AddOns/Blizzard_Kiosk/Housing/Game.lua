GameKioskModeSplashMixin = {};

function GameKioskModeSplashMixin:ShowSpinnerTooltip(tooltip)
	GameTooltip:SetOwner(self.Spinner, "ANCHOR_RIGHT");
	GameTooltip:SetText(tooltip);
	GameTooltip:Show();
end

function GameKioskModeSplashMixin:OnResetFailed()
	self.Spinner:Show();
	self.Spinner:SetScript("OnEnter", nil);
	self.Spinner:SetScript("OnLeave", nil);
	self:ShowSpinnerTooltip(KIOSK_HOUSING_RESET_FAILED);
end

function GameKioskModeSplashMixin:OnLoad()
	self:SetParent(GetAppropriateTopLevelParent());
	self:SetFrameStrata("FULLSCREEN");

	self.Background:SetAtlas("welcome-background-keyart");

	self.BodyText1:SetText(KIOSK_HOUSING_START_BODY1);

	self.Button.Text:SetText(KIOSK_HOUSING_START_BUTTON);
	self.Button.Texture:SetAtlas("kiosk-button");
	self.Button.Highlight:SetAtlas("kiosk-button");
	self.Button:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

		self:Hide();

		Kiosk.StartSession();
	end);

	self.Spinner:SetScript("OnEnter", function()
		self:ShowSpinnerTooltip(KIOSK_HOUSING_RESET_IN_PROGRESS);
	end);

	self.Spinner:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);
end

function GameKioskModeSplashMixin:OnShow()
	local resetPending = Kiosk.IsHousingResetPending();
	self:SetButtonEnabled(not resetPending);
end

function GameKioskModeSplashMixin:SetButtonEnabled(enabled)
	self.Button:SetEnabled(enabled);

	self.Spinner:SetShown(not enabled);
end

GameKioskSessionStartedDialogMixin = {};

function GameKioskSessionStartedDialogMixin:OnLoad()
	self:SetParent(GetAppropriateTopLevelParent());
	self:SetFrameStrata("FULLSCREEN_DIALOG");

	self.Background:SetAtlas("housing-basic-panel--stone-background");

	self.Trim:SetAtlas("housing-wood-frame");

	self.Line:SetAtlas("housing-basic-panel-gradient-header-bg", true);

	self.Header:SetText(KIOSK_HOUSING_START_DLG_HEADER);

	self.Body:SetText(KIOSK_HOUSING_START_DLG_BODY1);

	self.ContinueButton:SetText(CONTINUE);
	self.ContinueButton:SetScript("OnClick", function(button)
		self:Hide();
	end);
end

GameKioskModeSplashEndMixin = {};

function GameKioskModeSplashEndMixin:OnLoad()
	self:SetParent(GetAppropriateTopLevelParent());
	self:SetFrameStrata("FULLSCREEN");

	self.Background:SetAtlas("end-screen-background-keyart");

	self.BodyText1:SetText(KIOSK_HOUSING_END_BODY1);

	self.BodyText2:SetText(KIOSK_HOUSING_END_BODY2);

	self.FooterText:SetText(KIOSK_HOUSING_END_FOOTER);
end

GameKioskFrameMixin = CreateFromMixins(KioskFrameMixin);

function GameKioskFrameMixin:OnLoad()
	KioskFrameMixin.OnLoad(self);

	self:RegisterEvent("KIOSK_HOUSING_RESET");
end

function GameKioskFrameMixin:OnEvent(event, ...)
	KioskFrameMixin.OnEvent(self, event, ...);

	if event == "KIOSK_SESSION_STARTED" then
		GameKioskSessionStartedDialog:Show();
	elseif event == "KIOSK_SESSION_EXPIRED" then
		C_HouseEditor.LeaveHouseEditor();

		KioskModeSplashEnd:Show();
	elseif event == "KIOSK_SESSION_SHUTDOWN" then
		C_HouseEditor.LeaveHouseEditor();

		EditModeManagerFrame:DeleteAllLayouts();
	elseif event == "KIOSK_SESSION_RESTART" then
		-- Here but commented out for reference only. This does not
		-- occur here because the Housing demo does not return to glues
		-- before restarting the session.
		-- ForceLogout();

		-- Reset the house to the initial state. Avoid sending the
		-- request if we already have one known to be in transit.
		if not Kiosk.IsHousingResetPending() then
			Kiosk.RequestHousingReset();
		end

		-- Since we aren't returning to glues, reload the UI to mitigate the
		-- impact of any errors that may have occured during the session.
		ConsoleExec("reloadui")
	elseif event == "KIOSK_HOUSING_RESET" then
		-- Always reenable so that the demo can be continued even in the unexpected
		-- event the server failed to reset the house.
		KioskModeSplash:SetButtonEnabled(true);

		local success = ...;
		if not success then
			-- Unexpected failure.
			KioskModeSplash:OnResetFailed();
		end
	end
end

function GameKioskFrameMixin:DisplayExpireState()
	KioskModeSplashEnd:Show();
end

function GameKioskFrameMixin:DisplayLobbyState()
	local ignoreCenter = false;
	CloseAllWindows(ignoreCenter, "Kiosk");

	KioskModeSplashEnd:Hide();
	KioskModeSplash:Show();
end

function GameKioskFrameMixin:HandlePlayerEnteringWorld(_isInitialLogin, isUIReload)
	if not C_Housing.IsInsideHouse() then
		return;
	end

	if not isUIReload then
		--[[
		Reset when entering the house so that it is correctly reset prior to pressing
		Decorate for the first time.
		]]--
		Kiosk.RequestHousingReset();
	end

	if Kiosk.IsInLobby() then
		self:DisplayLobbyState();
	elseif Kiosk.IsExpired() then
		self:DisplayExpireState();
	end

	-- Remove any existing modules and then prevent new ones from being added, in case this
	-- is called prior to ObjectiveTrackerManager startup.
	ObjectiveTrackerManager:RemoveAllModules();
	ObjectiveTrackerManager:SetCanAddModules(false);

	DurabilityFrame:Hide();

	MinimapCluster:Hide();

	-- Use classic preset to move the unit frame elements to the outskirts of the screen.
	EditModeManagerFrame:SelectLayout(2);

	SetCVar("softTargettingInteractKeySound", 0);

	Kiosk.EnableGodMode();
end
