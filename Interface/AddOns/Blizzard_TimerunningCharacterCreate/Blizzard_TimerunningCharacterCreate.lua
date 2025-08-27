
local function AddCreateButtonDisabledState(button)
	button:SetScript("OnEnter", function()
		if not button:IsEnabled() then
			GlueTooltip:SetOwner(button, "ANCHOR_RIGHT", 0, 0);
			GameTooltip_AddNormalLine(GlueTooltip, TIMERUNNING_DISABLED_TOOLTIP);
			GlueTooltip:Show();
		end
	end);
	button:SetScript("OnLeave", function()
		GlueTooltip:Hide();
	end);
	button:SetMotionScriptsWhileDisabled(true);
end


TimerunningCreateCharacterButtonGlowMixin = {};

function TimerunningCreateCharacterButtonGlowMixin:OnLoad()
	-- Allow mask adjustments for different implementations.
	if self.frameMaskOverrideHeight then
		self.RotatingGlow.FrameMask:SetHeight(self.frameMaskOverrideHeight);
	end

	if self.frameMaskOverrideAnchorLeft then
		self.RotatingGlow.FrameMask:SetPoint("LEFT", self.frameMaskOverrideAnchorLeft);
	end

	if self.frameMaskOverrideAnchorRight then
		self.RotatingGlow.FrameMask:SetPoint("RIGHT", self.frameMaskOverrideAnchorRight);
	end

	self:UpdateHeight();
end

function TimerunningCreateCharacterButtonGlowMixin:OnSizeChanged()
	self:UpdateHeight();
end

function TimerunningCreateCharacterButtonGlowMixin:UpdateHeight()
	self.RotatingGlow.GlowCircle:SetHeight(self.RotatingGlow.GlowCircle:GetWidth());
end


TimerunningFirstTimeDialogMixin = {};

function TimerunningFirstTimeDialogMixin:OnLoad()
	self.InfoPanel.CreateButton:SetText(TimerunningUtil.AddLargeIcon(TIMERUNNING_POPUP_CREATE));

	self.InfoPanel.CreateButton:SetScript("OnClick", function()
		local timerunningSeasonID  = GetActiveTimerunningSeasonID();
		local suppressPopup = true;
		self:Dismiss(suppressPopup);

		local createCharacterCallback = function()
			-- Don't show the popup with the create character choice since the player just selected timerunner.
			CharacterSelectUtil.CreateNewCharacter(Enum.CharacterCreateType.Normal, timerunningSeasonID);
		end;

		if GetCVar("showCreateCharacterRealmConfirmDialog") == "1" then
			local formattedText = string.format(StaticPopupDialogs["CREATE_CHARACTER_REALM_CONFIRMATION"].text, CharacterSelectUtil.GetFormattedCurrentRealmName());
			local text2 = nil;
			StaticPopup_Show("CREATE_CHARACTER_REALM_CONFIRMATION", formattedText, text2, createCharacterCallback);
		else
			createCharacterCallback();
		end

		C_LiveEvent.OnLiveEventPopupClicked(timerunningSeasonID);
	end);
	AddCreateButtonDisabledState(self.InfoPanel.CreateButton);

	self.InfoPanel.CloseButton:SetScript("OnClick", function()
		self:Dismiss();
	end);

	self:RegisterEvent("LOGIN_STATE_CHANGED");
	self:RegisterEvent("TIMERUNNING_SEASON_UPDATE");

	self:UpdateState();
end

function TimerunningFirstTimeDialogMixin:OnKeyDown(key)
	if key == "ESCAPE" then
		self:Dismiss();
	end
end

function TimerunningFirstTimeDialogMixin:OnShow()
	self:UpdateState();
end

function TimerunningFirstTimeDialogMixin:OnEvent(event, ...)
	if (event == "LOGIN_STATE_CHANGED") then
		if not IsConnectedToServer() then
			self:Hide();
		end
	elseif (event == "TIMERUNNING_SEASON_UPDATE") then
		self:UpdateState();
	end
end

local TIMERUNNING_INFO_PANEL_DESC = {
	[Constants.TimerunningConsts.TIMERUNNING_SEASON_NONE] = {
		textureSuffix = "",
		rewardAnchorOffsetX = 193,
		rewardAnchorOffsetY = 44,
	},
	[Constants.TimerunningConsts.TIMERUNNING_SEASON_PANDARIA] = {
		textureSuffix = "",
		rewardAnchorOffsetX = 193,
		rewardAnchorOffsetY = 44,
	},
	[Constants.TimerunningConsts.TIMERUNNING_SEASON_LEGION] = {
		textureSuffix = "-legion",
		rewardAnchorOffsetX = 193,
		rewardAnchorOffsetY = 44,
	},
};

local TIMERUNNING_LOCALE_SUFFIX_OVERRIDES = {
	["zhCN"] = "cn",
	["zhTW"] = "tw",
};

function TimerunningFirstTimeDialogMixin:UpdateState()
	local activeTimerunningSeasonID = GetActiveTimerunningSeasonID() or Constants.TimerunningConsts.TIMERUNNING_SEASON_NONE;
	local seenTimerunningFirstLoginPopup = GetCVarNumberOrDefault("seenTimerunningFirstLoginPopup");
	local neverShow = seenTimerunningFirstLoginPopup == -1;
	-- There is no current legion dialog art, so the frame is being hidden until then
	local shouldShow = not neverShow and activeTimerunningSeasonID ~= TIMERUNNING_SEASON_NONE and seenTimerunningFirstLoginPopup ~= activeTimerunningSeasonID;
	local canShow = (IsConnectedToServer() and (CharacterSelect:IsShown()) or (CharacterCreateFrame:IsShown() and (not TimerunningChoicePopup or not TimerunningChoicePopup:IsShown())) and (not IsBetaBuild()));
	self:SetShown(canShow and shouldShow);
	self.InfoPanel.CreateButton:SetEnabled(IsTimerunningEnabled());

	local infoPanelDesc = TIMERUNNING_INFO_PANEL_DESC[activeTimerunningSeasonID];
	local textureSuffix = infoPanelDesc.textureSuffix;
	self.InfoPanel.Background:SetAtlas("timerunning-infographic-background"..textureSuffix);
	self.InfoPanel.LogoFX:SetAtlas("timerunning-infographic-logo-fx"..textureSuffix);
	self.InfoPanel.RewardsImage:SetAtlas("timerunning-infographic-rewards"..textureSuffix);

	local isMoPTimerunning = activeTimerunningSeasonID == Constants.TimerunningConsts.TIMERUNNING_SEASON_PANDARIA;
	self.InfoPanel.RewardsImage:SetPoint("CENTER", self.InfoPanel, "CENTER", infoPanelDesc.rewardAnchorOffsetX, infoPanelDesc.rewardAnchorOffsetY);
	self.InfoPanel.TopDescription:SetShown(isMoPTimerunning);

	local localeString = GetLocale();
	local localeSuffix = TIMERUNNING_LOCALE_SUFFIX_OVERRIDES[localeString] or "en";
	self.InfoPanel.Logo:SetAtlas("timerunning-infographic-logo"..textureSuffix.."-"..localeSuffix);
end

function TimerunningFirstTimeDialogMixin:ShowFromClick(shownFromPopup)
	-- Reset CVar when manually showing the dialog to ensure it stays visible even if an event triggers UpdateState.
	-- The CVar be set back to the the current season when the dialog is closed with escape or the close button.
	SetCVar("seenTimerunningFirstLoginPopup", GetCVarDefault("seenTimerunningFirstLoginPopup"));
	self.shownFromPopup = shownFromPopup;
	self:UpdateState();
end

function TimerunningFirstTimeDialogMixin:Dismiss(suppressPopup)
	SetCVar("seenTimerunningFirstLoginPopup", GetActiveTimerunningSeasonID());
	self:Hide();

	-- In character create this is opened only by the popup, so show the popup again when dismissed.
	if not suppressPopup and ((GlueParent_GetCurrentScreen() == "charcreate") or self.shownFromPopup) then
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
	OnAccept = function(dialog, data)
		TimerunningChoicePopup:Hide();
		CharacterSelectUtil.CreateNewCharacter(Enum.CharacterCreateType.Normal, GetActiveTimerunningSeasonID());
	end,
};

TimerunningChoiceDialogMixin = {};

function TimerunningChoiceDialogMixin:OnLoad()
	if self.isTimerunning then
		self.Header:SetText(TimerunningUtil.AddLargeIcon(self.headerText));
		self.Header:SetPoint("TOP", -6, -20);
		AddCreateButtonDisabledState(self.SelectButton);

		self.descriptionText = TimerunningUtil.GetTimerunningChoiceDesc();
	else
		self.Header:SetText(self.headerText);
		self.Header:SetPoint("TOP", 0, -20);
	end

	self.Description:SetText(self.descriptionText);

	self.SelectButton:SetScript("OnClick", function()
		if self.isTimerunning then
			C_LiveEvent.OnLiveEventPopupClicked(GetActiveTimerunningSeasonID());
		end

		if self.isTimerunning and GlueParent_GetCurrentScreen() == "charcreate" then
			StaticPopup_Show("TIMERUNNING_CHOICE_WARNING");
		else
			TimerunningChoicePopup:Hide();
			CharacterSelectUtil.CreateNewCharacter(Enum.CharacterCreateType.Normal, self.isTimerunning and GetActiveTimerunningSeasonID() or nil);
		end
	end);
end

function TimerunningChoiceDialogMixin:OnShow()
	if self.isTimerunning then
		self.SelectButton:SetEnabled(IsTimerunningEnabled());
	end
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
	local createCharacterButton = CharacterSelectUI.VisibilityFramesContainer.CharacterList.CreateCharacterButton;

	local onEnableScript = createCharacterButton:GetScript("OnEnable");
	createCharacterButton:SetScript("OnEnable", function()
		if onEnableScript then
			onEnableScript(createCharacterButton);
		end

		self:UpdateShown();
	end);

	local onDisableScript = createCharacterButton:GetScript("OnDisable");
	createCharacterButton:SetScript("OnDisable", function()
		if onDisableScript then
			onDisableScript(createCharacterButton);
		end

		self:UpdateShown();
	end);

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
	local activeTimerunningSeasonID = GetActiveTimerunningSeasonID()
	local showTimerunning = activeTimerunningSeasonID ~= nil;
	if showTimerunning then
		self:SetParent(CharacterSelectCharacterFrame);
		self:SetPoint("BOTTOM", CharacterSelectCharacterFrame, "BOTTOM", 0, 70);

		CharacterSelectCharacterFrame.ScrollBox:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 6);
	else
		self:SetParent(GlueParent);
		self:ClearAllPoints();

		CharacterSelectCharacterFrame.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterSelectCharacterFrame, "BOTTOMRIGHT", -32, 83);
	end

	self:SetShown(showTimerunning);

	self.Header:SetText(TimerunningUtil.GetTimerunningBannerHeaderText());

	local createCharacterEnabled = CharacterSelectUI.VisibilityFramesContainer.CharacterList.CreateCharacterButton:IsEnabled();
	TimerunningCreateCharacterButtonGlow:SetShown(createCharacterEnabled and showTimerunning);
end

function TimerunningEventBannerMixin:UpdateTimeLeft()
	self.updatedTimeLeftText = TIMERUNNING_BANNER_TIME_LEFT:format(TimerunningTimeRemainingFormatter:Format(GetRemainingTimerunningSeasonSeconds()));
	self.TimeLeft:SetText(self.updatedTimeLeftText);
end

function TimerunningEventBannerMixin:OnEnter()
	self.Border:SetAtlas("timerunning-glues-active-event-hover");

	if self.Header:IsTruncated() and self.updatedTimeLeftText then
		GlueTooltip:SetOwner(self, "ANCHOR_RIGHT", -5, -10);
		GameTooltip_SetTitle(GlueTooltip, self.tooltipTitle, nil, false);
		GlueTooltip:AddLine(TIMERUNNING_BANNER_PANDARIA_HEADER, WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b, 1, true);
		GlueTooltip:AddLine(self.updatedTimeLeftText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, true);
		GlueTooltip:Show();
	end
end

function TimerunningEventBannerMixin:OnLeave()
	self.Border:SetAtlas("timerunning-glues-active-event");
	GlueTooltip:Hide();
end

function TimerunningEventBannerMixin:OnClick()
	local shownFromPopup = false;
	TimerunningFirstTimeDialog:ShowFromClick(shownFromPopup);

	C_LiveEvent.OnLiveEventBannerClicked(GetActiveTimerunningSeasonID());
end

StaticPopupDialogs["CONVERT_TIMERUNNER_EARLY"] = {
	text = CONVERT_TIMERUNNER_EARLY_DIALOG_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		TryConvertTimerunningCharacterToStandard(data.characterGuid);
	end,
	OnCancel = function(dialog, data)
		-- Nothing atm
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	acceptDelay = 5,
	fullscreen = 1,
};

TimerunningConversionButtonMixin = {};

function TimerunningConversionButtonMixin:OnClick()
	if CharacterSelectUtil.IsAccountLocked() then
		return;
	end

	local characterID = self:GetParent():GetCharacterID();
	local includeEmptySlots = true;
	local numCharacters = GetNumCharacters(includeEmptySlots);
	if characterID <= 0 or (characterID > numCharacters) then
		-- Somehow our character order got borked, scroll to top and get an updated character list.
		CharacterSelectCharacterFrame.ScrollBox:ScrollToBegin();
	
		CharacterSelectListUtil.GetCharacterListUpdate();
		return;
	end

	local data = {};
	data.characterGuid = self:GetParent():GetCharacterGUID();
	StaticPopup_Show("CONVERT_TIMERUNNER_EARLY", nil, nil, data);
end

function TimerunningConversionButtonMixin:OnMouseDown()
	self.pushed = true;

	self:UpdateTextureStates();
end

function TimerunningConversionButtonMixin:OnMouseUp()
	self.pushed = false;

	self:UpdateTextureStates();
end

function TimerunningConversionButtonMixin:OnEnter()
	GlueTooltip:SetOwner(self, "ANCHOR_LEFT", 4, -8);
	GlueTooltip:SetText(TIMERUNNING_CONVERSION_ENABLED_TOOLTIP, 1.0, 1.0, 1.0);

	self.hovered = true;
	self:UpdateTextureStates();
end

function TimerunningConversionButtonMixin:OnLeave()
	GlueTooltip:Hide();

	self.hovered = false;
	self:UpdateTextureStates();
end

function TimerunningConversionButtonMixin:UpdateTextureStates()
	self.HighlightIcon:SetShown(self.hovered and not self.pushed);
	self.HighlightBorder:SetShown(self.hovered);

	self.Icon:SetPoint("CENTER", self, "CENTER", self.pushed and 2 or 0, self.pushed and -2 or 0);
end
