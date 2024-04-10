
TimerunningFirstTimeDialogMixin = {};

function TimerunningFirstTimeDialogMixin:OnLoad()
	self.InfoPanel.CreateButton:SetText(TimerunningUtil.AddLargeIcon(TIMERUNNING_POPUP_CREATE));

	self.InfoPanel.CreateButton:SetScript("OnClick", function()
		self:Dismiss();
		CharacterSelect_CreateNewCharacter(Enum.CharacterCreateType.Normal, GetActiveTimerunningSeasonID());
	end);
	self.InfoPanel.CloseButton:SetScript("OnClick", function()
		self:Dismiss();
	end);

	self:RegisterEvent("LOGIN_STATE_CHANGED");
	self:RegisterEvent("TIMERUNNING_SEASON_UPDATE");

	self:DetermineVisibility();
end

function TimerunningFirstTimeDialogMixin:OnKeyDown(key)
	if key == "ESCAPE" then
		self:Dismiss();
	end
end

function TimerunningFirstTimeDialogMixin:OnEvent(event, ...)
	if (event == "LOGIN_STATE_CHANGED") then
		if not IsConnectedToServer() then
			self:Hide();
		end
	elseif (event == "TIMERUNNING_SEASON_UPDATE") then
		self:DetermineVisibility();
	end
end

function TimerunningFirstTimeDialogMixin:DetermineVisibility()
	local activeTimerunningSeasonID = GetActiveTimerunningSeasonID();
	local shouldShow = activeTimerunningSeasonID ~= nil and GetCVarNumberOrDefault("seenTimerunningFirstLoginPopup") ~= activeTimerunningSeasonID;
	local canShow = IsConnectedToServer() and (CharacterSelect:IsShown() or CharacterCreateFrame:IsShown()) and (not TimerunningChoicePopup or not TimerunningChoicePopup:IsShown());
	self:SetShown(canShow and shouldShow);
end

function TimerunningFirstTimeDialogMixin:ShowFromClick(shownFromPopup)
	-- Reset CVar when manually showing the dialog to ensure it stays visible even if an event triggers DetermineVisibility.
	-- The CVar be set back to the the current season when the dialog is closed with escape or the close button.
	SetCVar("seenTimerunningFirstLoginPopup", GetCVarDefault("seenTimerunningFirstLoginPopup"));
	self.shownFromPopup = shownFromPopup;
	self:DetermineVisibility();
end

function TimerunningFirstTimeDialogMixin:Dismiss()
	SetCVar("seenTimerunningFirstLoginPopup", GetActiveTimerunningSeasonID());
	self:Hide();

	-- In character create this is opened only by the popup, so show the popup again when dismissed.
	if GlueParent_GetCurrentScreen() == "charcreate" or self.shownFromPopup then
		TimerunningChoicePopup:Show();
	end
end

TimerunningChoiceInfoButtonMixin = {};

function TimerunningChoiceInfoButtonMixin:OnClick()
	TimerunningChoicePopup:Hide();
	local shownFromPopup = true;
	TimerunningFirstTimeDialog:ShowFromClick(shownFromPopup);
end

StaticPopupDialogs["TIMERUNNING_CHOICE_WARNING"] = {
	button1 = CONTINUE,
	button2 = CANCEL,
	text = TIMERUNNING_CHOICE_WARNING,
	OnAccept = function()
		TimerunningChoicePopup:Hide();
		CharacterSelect_CreateNewCharacter(Enum.CharacterCreateType.Normal, GetActiveTimerunningSeasonID());
	end,
};

TimerunningChoiceDialogMixin = {};

function TimerunningChoiceDialogMixin:OnLoad()
	if self.isTimerunning then
		self.Header:SetText(TimerunningUtil.AddLargeIcon(self.headerText));
		self.Header:SetPoint("TOP", -6, -20);
	else
		self.Header:SetText(self.headerText);
		self.Header:SetPoint("TOP", 0, -20);
	end

	self.Description:SetText(self.descriptionText);

	self.SelectButton:SetScript("OnClick", function()
		if self.isTimerunning and GlueParent_GetCurrentScreen() == "charcreate" then
			GlueDialog_Show("TIMERUNNING_CHOICE_WARNING");
		else
			TimerunningChoicePopup:Hide();
			CharacterSelect_CreateNewCharacter(Enum.CharacterCreateType.Normal, self.isTimerunning and GetActiveTimerunningSeasonID() or nil);
		end
	end);
end

TimerunningChoicePopupMixin = {};

function TimerunningChoicePopupMixin:OnLoad()
	self:RegisterEvent("LOGIN_STATE_CHANGED");
end

function TimerunningChoicePopupMixin:OnShow()
	-- Avoid having this and first time dialog visible at the same time, choice dialog overrides first time dialog.
	TimerunningFirstTimeDialog:Hide();
end

function TimerunningChoicePopupMixin:OnEvent(event, ...)
	if (event == "LOGIN_STATE_CHANGED") then
		if not IsConnectedToServer() then
			self:Hide();
		end
	end
end

function TimerunningChoicePopupMixin:OnKeyDown(key)
	if key == "ESCAPE" then
		self:Hide();
	end
end

TimerunningEventBannerMixin = {};

local TimerunningTimeRemainingFormatter = CreateFromMixins(SecondsFormatterMixin);
TimerunningTimeRemainingFormatter:Init(0, SecondsFormatter.Abbreviation.None, false, false);
function TimerunningTimeRemainingFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Days;
end

function TimerunningEventBannerMixin:OnLoad()
	self:RegisterEvent("TIMERUNNING_SEASON_UPDATE");
	self:UpdateShown();
	self:UpdateTimeLeft();
end

function TimerunningEventBannerMixin:OnEvent(event, ...)
	if event == "TIMERUNNING_SEASON_UPDATE" then
		self:UpdateShown();
		self:UpdateTimeLeft();
	end
end

function TimerunningEventBannerMixin:UpdateShown()
	local showTimerunning = GetActiveTimerunningSeasonID() ~= nil;
	self:SetShown(showTimerunning);
	TimerunningCreateCharacterButtonGlow:SetShown(showTimerunning);
end

function TimerunningEventBannerMixin:UpdateTimeLeft()
	local text = TIMERUNNING_BANNER_TIME_LEFT:format(TimerunningTimeRemainingFormatter:Format(GetRemainingTimerunningSeasonSeconds()));
	self.TimeLeft:SetText(text);
end

function TimerunningEventBannerMixin:OnEnter()
	self.Border:SetAtlas("timerunning-glues-active-event-hover");
end

function TimerunningEventBannerMixin:OnLeave()
	self.Border:SetAtlas("timerunning-glues-active-event");
end

function TimerunningEventBannerMixin:OnClick()
	TimerunningFirstTimeDialog:ShowFromClick();
end
