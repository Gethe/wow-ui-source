GameKioskTimerMixin = {};

function GameKioskTimerMixin:OnLoad()
	self.timeLeftFormatter = CreateFromMixins(SecondsFormatterMixin);
	self.timeLeftFormatter:Init(
		SecondsFormatterConstants.ZeroApproximationThreshold,
		SecondsFormatter.Abbreviation.Truncate,
		SecondsFormatterConstants.RoundUpLastUnit);
	self.timeLeftFormatter:SetDesiredUnitCount(1);
	self.timeLeftFormatter:SetConvertToLower(true);
end

function GameKioskTimerMixin:OnUpdate()
	if Kiosk.IsSessionTimed() then
		local secondsRemaining = math.floor(Kiosk.GetSecondsRemaining());
		local secondsText = self.timeLeftFormatter:Format(secondsRemaining);
		local secondsTextFormatted = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(secondsText);
		self.Text:SetText(KIOSK_TIME_REMAINING_FORMAT:format(secondsTextFormatted));
		self.Text:Show();
	else
		self.Text:Hide();
	end
end

GameKioskFrameMixin = CreateFromMixins(KioskFrameMixin);

function GameKioskFrameMixin:OnEvent(event, ...)
	KioskFrameMixin.OnEvent(self, event, ...);

	if event == "KIOSK_SESSION_EXPIRED" then
		KioskModeTimer:Hide();
	elseif event == "KIOSK_SESSION_EXPIRATION_CHANGED" then
		KioskModeTimer:SetScript("OnUpdate", nil);
		KioskModeTimer:Hide();
	elseif event == "KIOSK_SESSION_RESTART" then
		ForceLogout();
	elseif event == "KIOSK_SESSION_SHUTDOWN" then
		EditModeManagerFrame:DeleteAllLayouts();
	end
end

local function ForceActionBarToggles()
	local multiActionBarPagesByToggleIndex =
	{
		BOTTOMLEFT_ACTIONBAR_PAGE,
		BOTTOMRIGHT_ACTIONBAR_PAGE,
		RIGHT_ACTIONBAR_PAGE,
		LEFT_ACTIONBAR_PAGE,
		MULTIBAR_5_ACTIONBAR_PAGE,
		MULTIBAR_6_ACTIONBAR_PAGE,
		MULTIBAR_7_ACTIONBAR_PAGE,
	};

	local bitmask = 0;

	for toggleIndex, actionBarPage in ipairs(multiActionBarPagesByToggleIndex) do
		local firstSlot = ((actionBarPage - 1) * NUM_ACTIONBAR_BUTTONS) + 1;
		local lastSlot = firstSlot + NUM_ACTIONBAR_BUTTONS - 1;
		local hasAction = false;

		for slot = firstSlot, lastSlot do
			if C_ActionBar.HasAction(slot) then
				hasAction = true;
				break;
			end
		end

		if hasAction then
			bitmask = bitmask + (2 ^ (toggleIndex - 1));
		end
	end

	SetActionBarToggles(
		(bitmask % 2) >= 1,
		(math.floor(bitmask / 2) % 2) >= 1,
		(math.floor(bitmask / 4) % 2) >= 1,
		(math.floor(bitmask / 8) % 2) >= 1,
		(math.floor(bitmask / 16) % 2) >= 1,
		(math.floor(bitmask / 32) % 2) >= 1,
		(math.floor(bitmask / 64) % 2) >= 1);
end

function GameKioskFrameMixin:HandlePlayerEnteringWorld(isInitialLogin, isUIReload)
	if isInitialLogin then
		ForceActionBarToggles();
	end

	if Kiosk.IsExpired() then
		KioskModeSplashEnd:Show();
		KioskModeTimer:Hide();
	end
end
