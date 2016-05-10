local classFilenameToAtlas = {
	["WARRIOR"] = "ClassTrial-Warrior-Ring",
	["PALADIN"] = "ClassTrial-Paladin-Ring",
	["HUNTER"] = "ClassTrial-Hunter-Ring",
	["ROGUE"] = "ClassTrial-Rogue-Ring",
	["PRIEST"] = "ClassTrial-Priest-Ring",
	["DEATHKNIGHT"] = "ClassTrial-DeathKnight-Ring",
	["SHAMAN"] = "ClassTrial-Shaman-Ring",
	["MAGE"] = "ClassTrial-Mage-Ring",
	["WARLOCK"] = "ClassTrial-Warlock-Ring",
	["MONK"] = "ClassTrial-Monk-Ring",
	["DRUID"] = "ClassTrial-Druid-Ring",
};

function ClassTrial_SetHasAvailableBoost(hasBoost)
	ClassTrialThanksForPlayingDialog:UpdateDialogButtons(hasBoost);
end

ClassTrialDialogMixin = {}

function ClassTrialDialogMixin:ShowThanks()
	local className, classFilename = UnitClass("player");
	self.ClassNameText:SetText(className);
	self.ClassIcon:SetAtlas(classFilenameToAtlas[classFilename])

	local dialogText = CLASS_TRIAL_THANKS_DIALOG_TEXT:format(UnitName("player"));
	self.DialogText:SetText(dialogText);

	self:Show();
end

function ClassTrialDialogMixin:HandleButtonClickCommon()
	PlaySound("igMainMenuOptionCheckBoxOn");
	ClassTrialTimerDisplay:ShowTimer();
end

function ClassTrialDialogMixin:BuyCharacterBoost()
	self:HandleButtonClickCommon();
	ClassTrialSecureFrame:SetAttribute("upgradecharacter", UnitGUID("player"));
end

function ClassTrialDialogMixin:ConfirmCharacterBoost()
	ClassTrialSecureFrame:SetAttribute("upgradecharacter-confirm", UnitGUID("player"));
end

function ClassTrialDialogMixin:DecideLater()
	self:HandleButtonClickCommon();
end

function ClassTrialDialogMixin:OnUpgradeComplete()
	self:Hide();

	self:UnregisterEvent("EVENT_CLASS_TRIAL_TIMER_START");
	self:UnregisterEvent("EVENT_CLASS_TRIAL_UPGRADE_COMPLETE");
end

function ClassTrialDialogMixin:UpdateDialogButtons(hasBoost)
	if hasBoost then
		self.BuyCharacterBoostButton:SetText(CLASS_TRIAL_THANKS_DIALOG_APPLY_BOOST_BUTTON);
	else
		self.BuyCharacterBoostButton:SetText(CLASS_TRIAL_THANKS_DIALOG_BUY_BOOST_BUTTON);
	end

	self.BuyCharacterBoostButton:SetWidth(self.BuyCharacterBoostButton:GetTextWidth() + 80);
	self.DecideLaterButton:SetWidth(self.DecideLaterButton:GetTextWidth() + 80);

	local buttonsWidth = self.DecideLaterButton:GetRight() - self.BuyCharacterBoostButton:GetLeft();
	local offset = (self.DialogFrame:GetWidth() - buttonsWidth) / 2;

	self.BuyCharacterBoostButton:SetPoint("BOTTOMLEFT", self.DialogFrame, "BOTTOMLEFT", offset, 50);
end

function ClassTrialDialogMixin:OnEvent(event, ...)
	if event == "EVENT_CLASS_TRIAL_TIMER_START" then
		self:ShowThanks();
	elseif event == "EVENT_CLASS_TRIAL_UPGRADE_COMPLETE" then
		self:OnUpgradeComplete();
	end
end

function ClassTrialDialogMixin:OnShow()
	ClassTrialTimerDisplay:Hide();
	PlaySound("igClassTrialThanksDialogShow");
end

function ClassTrialDialogMixin:OnLoad()
	ClassTrialSecureFrame:SetAttribute("updateboostpurchasebutton");

	self:RegisterEvent("EVENT_CLASS_TRIAL_TIMER_START");
	self:RegisterEvent("EVENT_CLASS_TRIAL_UPGRADE_COMPLETE");
end

ClassTrialTimerDisplayMixin = {}

function ClassTrialTimerDisplayMixin:SetupCountdown()
	self.kickTime = C_ClassTrial.GetClassTrialLogoutTimeSeconds();
end

function ClassTrialTimerDisplayMixin:UpdateTimerText()
	self.remaining = max(self.kickTime - GetTime(), 0);

	local formattedTime = SecondsToTime(self.remaining, false, true, 1, true);
	local timerText = CLASS_TRIAL_TIMER_DIALOG_TEXT_NO_REMAINING_TIME;

	if formattedTime ~= "" then
		timerText = CLASS_TRIAL_TIMER_DIALOG_TEXT_HAS_REMAINING_TIME:format(formattedTime);
	end

	self.TimerText:SetText(timerText);
end

function ClassTrialTimerDisplayMixin:ShowTimer()
	self:SetupCountdown();
	self:UpdateTimerText();
	self:Show();
end

function ClassTrialTimerDisplayMixin:CheckShowTimer()
	self:SetupCountdown();
	if self.kickTime > 0 then
		self:ShowTimer();
	end
end

function ClassTrialTimerDisplayMixin:OnUpdate()
	self:UpdateTimerText();
end

function ClassTrialTimerDisplayMixin:OnUpgradeComplete()
	self:Hide();

	self:UnregisterEvent("EVENT_CLASS_TRIAL_TIMER_START");
	self:UnregisterEvent("EVENT_CLASS_TRIAL_UPGRADE_COMPLETE");
end

function ClassTrialTimerDisplayMixin:OnEvent(event, ...)
	if event == "EVENT_CLASS_TRIAL_TIMER_START" then
		self:Hide();
	elseif event == "EVENT_CLASS_TRIAL_UPGRADE_COMPLETE" then
		self:OnUpgradeComplete();
	end
end

function ClassTrialTimerDisplayMixin:OnMouseUp()
	PlaySound("igMainMenuOptionCheckBoxOn");
	ClassTrialThanksForPlayingDialog:ShowThanks();
end

function ClassTrialTimerDisplayMixin:OnShow()
	ClassTrialThanksForPlayingDialog:Hide();
end

function ClassTrialTimerDisplayMixin:OnLoad()
	self:RegisterEvent("EVENT_CLASS_TRIAL_TIMER_START");
	self:RegisterEvent("EVENT_CLASS_TRIAL_UPGRADE_COMPLETE");
	self:CheckShowTimer();
end
