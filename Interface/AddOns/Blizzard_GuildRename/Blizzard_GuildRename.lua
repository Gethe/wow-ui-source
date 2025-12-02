SimpleTooltipRegionMixin = {};

function SimpleTooltipRegionMixin:OnEnter()
	if self.tooltip then
		local tooltipFrame = GetAppropriateTooltip();
		tooltipFrame:SetOwner(self, self.tooltipAnchor or "ANCHOR_RIGHT");
		local useDefaultColor = nil;
		local useWordWrap = true;
		GameTooltip_SetTitle(tooltipFrame, self.tooltip, useDefaultColor, useWordWrap);
		tooltipFrame:Show();
	end
end

function SimpleTooltipRegionMixin:OnLeave()
	GameTooltip_HideTooltip(GetAppropriateTooltip());
end

function SimpleTooltipRegionMixin:SetTooltip(tooltip)
	self.tooltip = tooltip;
end

local guildErrorLookup = {
	[Enum.GuildErrorType.Success] = "",
	[Enum.GuildErrorType.UnknownError] = GUILD_RENAME_ERROR_UNKNOWN,
	[Enum.GuildErrorType.NameInvalid] = GUILD_RENAME_ERROR_NAME_INVALID,
	[Enum.GuildErrorType.NameAlreadyExists] = GUILD_RENAME_ERROR_NAME_ALREADY_EXISTS,
	[Enum.GuildErrorType.NoPermisson] = GUILD_RENAME_ERROR_NO_PERMISSION,
	[Enum.GuildErrorType.NotEnoughMoney] = GUILD_RENAME_ERROR_NOT_ENOUGH_MONEY,
	[Enum.GuildErrorType.TooMuchMoney] = GUILD_RENAME_ERROR_TOO_MUCH_MONEY,
	[Enum.GuildErrorType.InCooldown] = GUILD_RENAME_ERROR_IN_COOLDOWN,
	[Enum.GuildErrorType.ReservationExpired] = GUILD_RENAME_ERROR_RESERVATION_EXPIRED,
};

local function GetGuildError(statusCode)
	local entry = guildErrorLookup[statusCode];
	return entry or guildErrorLookup[Enum.GuildErrorType.UnknownError];
end

local GuildRenameMode = EnumUtil.MakeEnum("Title", "DoRename");

GuildRenameFrameMixin = {};

function GuildRenameFrameMixin:OnLoad()
	self.modeFrames = {};

	self:RegisterEvent("GUILD_RENAME_STATUS_UPDATE");
	self:RegisterEvent("GUILD_RENAME_NAME_CHECK");
	self:RegisterEvent("GUILD_RENAME_REFUND_RESULT");
	self:RegisterEvent("REQUESTED_GUILD_RENAME_RESULT")
	
	RegisterUIPanel(self, { area = "left", pushable = 0});

	self.ContextButton:SetScript("OnClick", function(_buttonFrame, button)
		if button == "LeftButton" then
			local mode = self:GetMode();
			if mode == GuildRenameMode.DoRename then
				self.RenameFlow:CheckRequestNameChange();
			else
				HideUIPanel(self);
			end
		end
	end);

	self:RegisterFontStrings(self.TitleFlow.Description,
		self.TitleFlow.RefundOption:GetFontString(),
		self.TitleFlow.RenameOption:GetFontString(),
		self.RenameFlow.Description,
		self.RenameFlow.CostLabel
	);

	self:RegisterFrames(self.Spinner, self.RenameFlow.Spinner);
	self:RegisterBackgroundTexture(self.Background);
	
	self:AddModeFrame(GuildRenameMode.Title, self.TitleFlow);
	self:AddModeFrame(GuildRenameMode.DoRename, self.RenameFlow);

	MoneyFrame_SetMaxDisplayWidth(self.MoneyFrame, 160);
	MoneyFrame_SetDisplayForced(self.MoneyFrame, true);
end

function GuildRenameFrameMixin:OnShow()
	self:SetPortraitToUnit("npc");
	self:SetTitle(UnitName("npc"));
end

function GuildRenameFrameMixin:OnHide()
	-- TODO: Make sure this clears out all the status message data that's still hanging around
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.GuildRename);
end

function GuildRenameFrameMixin:OnEvent(event, ...)
	if event == "GUILD_RENAME_STATUS_UPDATE" then
		local status = ...;
		self:OnGuildRenameStatusUpdate(status);
	elseif event == "GUILD_RENAME_NAME_CHECK" then
		local desiredName, statusCode, nameErrorToken = ...;
		self:OnGuildRenameNameCheck(desiredName, statusCode, nameErrorToken);
	elseif event == "REQUESTED_GUILD_RENAME_RESULT" then
		local guildName, status = ...;
		self:OnRequestedGuildRenameResult(guildName, status);
	elseif event == "GUILD_RENAME_REFUND_RESULT" then
		local guildName, status = ...;
		self:OnGuildRenameRefundResult(guildName, status);
	end
end

function GuildRenameFrameMixin:AddModeFrame(mode, frame)
	self.modeFrames[mode] = frame;
	frame:SetManager(self);
end

function GuildRenameFrameMixin:SetSpinnerShown(shown)
	self.Spinner:SetShown(shown);
end

function GuildRenameFrameMixin:OnGuildRenameStatusUpdate(status)
	self.status = status;

	if C_PlayerInteractionManager.IsInteractingWithNpcOfType(Enum.PlayerInteractionType.GuildRename) then
		if self:IsShown() then
			self:UpdateInteractionMode();
		else
			self:BeginInteractionMode();
		end
	end
end

function GuildRenameFrameMixin:GetRenamePermissionStatus()
	if not self:IsPlayerGuildMaster() then
		return Enum.GuildErrorType.NoPermisson;
	end

	return Enum.GuildErrorType.Success;
end

function GuildRenameFrameMixin:GetNameChangeRequestStatus()
	if not self:IsRenameEnabled() then
		return Enum.GuildErrorType.UnknownError; -- Get a status for this?
	end
	
	local permissionStatus = self:GetRenamePermissionStatus()
	if permissionStatus ~= Enum.GuildErrorType.Success then
		return permissionStatus;
	end

	if self:IsRenameCooldownActive() then
		return Enum.GuildErrorType.InCooldown;
	end

	return Enum.GuildErrorType.Success;
end

function GuildRenameFrameMixin:HasStatus()
	return self.status ~= nil;
end

function GuildRenameFrameMixin:GetExecuteNameChangeStatus()
	if self:GetCurrentGuildMoney() < self:GetRenameCost() then
		return Enum.GuildErrorType.NotEnoughMoney;
	end

	if not self:GetNameCheckPassed()  then
		return Enum.GuildErrorType.NameInvalid;
	end
	
	return self:GetNameChangeRequestStatus();
end

function GuildRenameFrameMixin:HasRenamePermission()
	return self:GetRenamePermissionStatus() == Enum.GuildErrorType.Success;
end

function GuildRenameFrameMixin:SetNameCheckPassed(passed)
	self.nameCheckPassed = passed;
end

function GuildRenameFrameMixin:GetNameCheckPassed()
	return self.nameCheckPassed;
end

function GuildRenameFrameMixin:IsPlayerGuildMaster()
	return self.status and self.status.isPlayerGuildMaster;
end

function GuildRenameFrameMixin:GetRenameCost()
	return self.status and self.status.renamePrice or math.huge;
end

function GuildRenameFrameMixin:GetCurrentGuildMoney()
	return self.status and self.status.currentGuildMoney or 0;
end

function GuildRenameFrameMixin:IsRenameEnabled()
	return self.status and self.status.isNameChangeEnabled;
end

function GuildRenameFrameMixin:GetRefundAmount()
	return self.status and self.status.refundAmount or 0;
end

function GuildRenameFrameMixin:GetRefundTimeRemaining()
	return math.max(self.status.refundEligibleEndTime - GetTime(), 0);
end

function GuildRenameFrameMixin:GetRenameCooldownRemaining()
	return math.max(self.status.nextRenameTime - GetTime(), 0);
end

function GuildRenameFrameMixin:IsRenameCooldownActive()
	if self.status and self.status.nextRenameTime then
		if self.status.nextRenameTime ~= 0 and GetTime() < self.status.nextRenameTime then
			return true;
		end
	end

	return false;
end

function GuildRenameFrameMixin:GetPreviousGuildName()
	return self.status and self.status.oldGuildName or UNKNOWN;
end

function GuildRenameFrameMixin:IsReservedNameValid()
	if self.status and self.status.reservedName and self.status.reservedName ~= "" then
		return GetTime() < self.status.reservedNameExpirationTime;
	end

	return false;
end

function GuildRenameFrameMixin:GetReservedName()
	if self:IsReservedNameValid() then
		return self.status.reservedName;
	end

	return nil;
end

function GuildRenameFrameMixin:NameMatchesExistingReservation(text)
	return self:GetReservedName() == text;
end

function GuildRenameFrameMixin:OnGuildRenameNameCheck(desiredName, statusCode, nameErrorToken)
	self.renameCheckStatusCode = statusCode;
	self.renameCheckNameError = nameErrorToken and _G[nameErrorToken] or "";
	self.renameCheckDesiredName = desiredName;
	self:SetNameCheckPassed(statusCode == Enum.GuildErrorType.Success);
	self.RenameFlow:UpdateFlowNameStatus();
	self:UpdateFromMode();
end

function GuildRenameFrameMixin:GetNameCheckStatus()
	return self.renameCheckDesiredName or "", self.renameCheckStatusCode, self.renameCheckNameError;
end

function GuildRenameFrameMixin:OnRequestedGuildRenameResult(guildName, status)
	if status == Enum.GuildErrorType.Success then
		HideUIPanel(self);
	else
		self:OnGuildRenameFlowStatusResponse(guildName, status);
		self:BeginInteraction();
	end
end

function GuildRenameFrameMixin:OnGuildRenameRefundResult(guildName, status)
	self:OnGuildRenameFlowStatusResponse(guildName, status);
end

function GuildRenameFrameMixin:OnGuildRenameFlowStatusResponse(_guildName, status)
	if status == Enum.GuildErrorType.Success then
		self:BeginInteraction(); -- restart the entire interaction to see what state the window should show
	else
		UIErrorsFrame:AddExternalErrorMessage(GetGuildError(status));
	end
end

function GuildRenameFrameMixin:BeginInteraction()
	-- clear current and request new status, and await response to show appropriate options
	self.status = nil;

	if C_GuildInfo.RequestRenameStatus() then
		self:BeginInteractionMode(); -- there won't be a mode yet, but the UI needs to show immediately and enter the waiting state
	else
		ChatFrameUtil.DisplaySystemMessageInPrimary(GUILD_RENAME_ERROR_MUST_BE_IN_A_GUILD);
		HideUIPanel(self);
	end
end

function GuildRenameFrameMixin:GetRenameModeFromStatus()
	local status = self:GetNameChangeRequestStatus();
	if status == Enum.GuildErrorType.Success then
		return GuildRenameMode.DoRename;
	end

	return GuildRenameMode.Title;
end

function GuildRenameFrameMixin:BeginInteractionMode(forceMode)
	if not self:IsShown() then
		ShowUIPanel(self);
	end

	self:UpdateInteractionMode(forceMode);
	self:UpdateTheme();
end

function GuildRenameFrameMixin:UpdateInteractionMode(forceMode)
	self.mode = forceMode or self:GetRenameModeFromStatus();

	for mode, frame in pairs(self.modeFrames) do
		frame:SetShown(mode == self.mode);
	end

	self:SetSpinnerShown(false);
	self.modeFrames[self.mode]:UpdateFromStatus();
	self:UpdateFromMode();
end

function GuildRenameFrameMixin:GetMode()
	return self.mode;
end

do
	local modeSetupFunctions =
	{
		[GuildRenameMode.DoRename] = function(self)
			MoneyFrame_Update(self.MoneyFrame, self:GetCurrentGuildMoney());
			self.MoneyFrame:Show();
			self.ContextButton:SetToGuildRename(self:GetExecuteNameChangeStatus());
			self.GuildIcon:UpdateTabard();
		end,

		[GuildRenameMode.Title] = function(self)
			self.MoneyFrame:Hide();
			self.ContextButton:SetToGoodbye();
			self.GuildIcon:Hide();
		end,
	};

	function GuildRenameFrameMixin:UpdateFromMode()
		modeSetupFunctions[self:GetMode()](self);
	end
end

GuildRenameManagedFlowMixin = {};

function GuildRenameManagedFlowMixin:SetManager(manager)
	self.manager = manager;
end

function GuildRenameManagedFlowMixin:GetManager()
	return self.manager;
end

GuildRenameFlowMixin = CreateFromMixins(TimedCallbackMixin, GuildRenameManagedFlowMixin);

function GuildRenameFlowMixin:OnLoad()
	self:SetCheckDelaySeconds(1);

	self.NameBox:SetScript("OnTextChanged", function(editBox, isUserChange)
		local text = editBox:GetText();
		local hasText = text and text ~= "";
		editBox.Instructions:SetShown(not hasText);
		self:ClearRenameStatus();
		self.desiredName = text;

		-- always force shown if this is a user change, otherwise wait until the check starts.
		self.Spinner:SetShown(isUserChange and hasText);

		self:RunCallbackAsync(function()
			if hasText and editBox:IsVisible() then
				C_GuildInfo.RequestRenameNameCheck(text);
			end
		end)
	end);

	self.NameBox:SetScript("OnEnterPressed", function(editBox)
		self:CheckRequestNameChange();
		editBox:ClearFocus();
	end);

	MoneyFrame_SetType(self.CostFrame, "STATIC");
end

function GuildRenameFlowMixin:CheckRequestNameChange()
	if self:GetManager():GetExecuteNameChangeStatus() == Enum.GuildErrorType.Success then
		StaticPopup_Show("CONFIRM_PURCHASE_GUILD_RENAME", GetMoneyString(self:GetManager():GetRenameCost(), MoneyStringConstants.SeparateThousands, MoneyStringConstants.CheckGoldThreshold), self:GetDesiredName(), { desiredName = self:GetDesiredName() });
	end
end

function GuildRenameFlowMixin:UpdateFromStatus()
	MoneyFrame_Update(self.CostFrame, self:GetManager():GetRenameCost());

	local reservedName = self:GetManager():GetReservedName();
	if reservedName then
		self.NameBox:SetText(reservedName);
	end
end

function GuildRenameFlowMixin:GetDesiredName()
	return self.desiredName or "";
end

local statusIcons = {
	[true] = "common-icon-checkmark",
	[false] = "common-icon-redx",
};

local DEFAULT_STATUS_TEXT = " ";

local function GetNameStatusDisplay(statusCode, nameCheckError)
	if statusCode ~= Enum.GuildErrorType.Success then
		if statusCode == Enum.GuildErrorType.NameInvalid and nameCheckError then
			return nameCheckError;
		else
			return GetGuildError(statusCode);
		end
	end

	return DEFAULT_STATUS_TEXT;
end

function GuildRenameFlowMixin:UpdateFlowNameStatus()
	local desiredName, statusCode, nameCheckError = self:GetManager():GetNameCheckStatus();
	local nameCheckPassed = statusCode == Enum.GuildErrorType.Success;

	self.Spinner:Hide();
	self.Status:SetShown(#desiredName > 0);
	self.Status:SetAtlas(statusIcons[nameCheckPassed], TextureKitConstants.UseAtlasSize);
	self.StatusText:SetText(GetNameStatusDisplay(statusCode, nameCheckError));
end

function GuildRenameFlowMixin:ClearRenameStatus()
	self:GetManager():SetNameCheckPassed(false);
	self.Status:Hide();
	self.StatusText:SetText(DEFAULT_STATUS_TEXT);
end

function GuildRenameFlowMixin:OnShow()
	self.NameBox:SetText("");
	self.NameBox.Instructions:Show();
	self.NameBox:SetFocus();

	self:ClearRenameStatus();
end

local timeFormatter = CreateFromMixins(SecondsFormatterMixin);
timeFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.OneLetter, SecondsFormatterConstants.DontRoundUpLastUnit, SecondsFormatterConstants.ConvertToLower);

GuildRenameTitleFlowMixin = CreateFromMixins(GuildRenameManagedFlowMixin, {
	timeFormatter = timeFormatter,
});

function GuildRenameTitleFlowMixin:OnLoad()
	self.RenameOption:SetScript("OnClick", function(optionFrame, button)
		if button == "LeftButton" then
			self:GetManager():BeginInteractionMode(GuildRenameMode.DoRename);
		end
	end);
	
	self.RefundOption:SetScript("OnClick", function(optionFrame, button)
		if button == "LeftButton" then
			local manager = self:GetManager();

			local currentGuildName = GetGuildInfo("player");
			local oldGuildName = manager:GetPreviousGuildName();
			local refundAmount = GetMoneyString(manager:GetRefundAmount(), MoneyStringConstants.SeparateThousands, MoneyStringConstants.CheckGoldThreshold);
			local guildRefundDialogText = GUILD_RENAME_REFUND_DIALOG_TEXT:format(currentGuildName, oldGuildName, refundAmount);

			local dialog = StaticPopup_Show("CONFIRM_GUILD_RENAME_REFUND", guildRefundDialogText);
			StaticPopup_SetTimeLeft(dialog, manager:GetRefundTimeRemaining());
		end
	end);
end

function GuildRenameTitleFlowMixin:OnUpdate()
	self:UpdateOptions();
end

function GuildRenameTitleFlowMixin:UpdateOptions()
	local manager = self:GetManager();

	if manager:HasStatus() then
		local hasPermission = self.hasRenamePermission;
		local renameCooldownRemaining = manager:GetRenameCooldownRemaining();
		local refundTimeRemaining = manager:GetRefundTimeRemaining();
		local showRenameOption = hasPermission or renameCooldownRemaining > 0;
		local showRefundOption = hasPermission and refundTimeRemaining > 0;

		self.RenameOption:SetShown(showRenameOption);

		if showRenameOption then
			self.RenameOption:SetEnabled(hasPermission and renameCooldownRemaining == 0);

			if hasPermission and renameCooldownRemaining <= 0 then
				self.RenameOption:SetTextAndResize(GUILD_RENAME_OPTIONS_RENAME_AVAILABLE);
			elseif renameCooldownRemaining > 0 then
				local timeUntilRename = self:FormatTime(renameCooldownRemaining);
				self.RenameOption:SetTextAndResize(GUILD_RENAME_OPTIONS_RENAME_COOLDOWN:format(timeUntilRename));
			end
		end

		local canRefund = hasPermission and refundTimeRemaining > 0;
		self.RefundOption:SetShown(canRefund);

		if canRefund then
			self.RefundOption:SetEnabled(true);

			local timeUntilRefundExpires = self:FormatTime(refundTimeRemaining);
			self.RefundOption:SetTextAndResize(GUILD_RENAME_OPTIONS_REFUND:format(timeUntilRefundExpires));
		end
	end
end

function GuildRenameTitleFlowMixin:UpdateFromStatus()
	local manager = self:GetManager();

	self.Description:Hide();
	self.RenameOption:Hide();
	self.RefundOption:Hide();

	self.hasRenamePermission = false;

	if manager:IsRenameEnabled() and manager:HasRenamePermission() then
		self.Description:SetText(GUILD_RENAME_OPTIONS_DESCRIPTION);
		self.Description:Show();

		self.hasRenamePermission = manager:HasRenamePermission();
		self:UpdateOptions();
	else
		local hasStatus = manager:HasStatus();
		self.Description:SetShown(hasStatus);
		manager:SetSpinnerShown(not hasStatus);

		if hasStatus then
			if not manager:HasRenamePermission() then
				self.Description:SetText(GUILD_RENAME_ERROR_NO_PERMISSION);
			else
				self.Description:SetText(GUILD_RENAME_OPTIONS_DESCRIPTION_DISABLED);
			end
		end
	end
end

function GuildRenameTitleFlowMixin:FormatTime(seconds)
	return self.timeFormatter:Format(seconds);
end

GuildRenameContextButtonMixin = CreateFromMixins(SimpleTooltipRegionMixin);

function GuildRenameContextButtonMixin:SetToGuildRename(renameStatus)
	self.renameStatus = renameStatus;
	self:SetText(GUILD_RENAME_COMMAND_DO_RENAME);
	self:SetEnabled(renameStatus == Enum.GuildErrorType.Success);
end

function GuildRenameContextButtonMixin:SetToGoodbye()
	self.renameStatus = nil;
	self:SetText(GOODBYE);
	self:SetEnabled(true);
end

function GuildRenameContextButtonMixin:OnEnter()
	if self.renameStatus and self.renameStatus ~= Enum.GuildErrorType.Success then
		self:SetTooltip(GetGuildError(self.renameStatus));
		SimpleTooltipRegionMixin.OnEnter(self);
	end
end

StaticPopupDialogs["CONFIRM_PURCHASE_GUILD_RENAME"] = {
	text = GUILD_RENAME_DIALOG_TEXT,
	button1 = GUILD_RENAME_DIALOG_CONFIRM_BUTTON,
	button2 = GUILD_RENAME_DIALOG_CANCEL_BUTTON,
	OnAccept = function(dialog, data)
		C_GuildInfo.RequestGuildRename(data.desiredName);
	end,
	OnCancel = nop,
	timeout = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_GUILD_RENAME_REFUND"] = {
	text = "%s", -- Custom text
	subText = GUILD_RENAME_REFUND_DIALOG_SUBTEXT,
	subtextIsTimer = true,
	normalSizedSubText = true,
	timeFormatter = timeFormatter,
	button1 = GUILD_RENAME_DIALOG_CONFIRM_BUTTON,
	button2 = GUILD_RENAME_DIALOG_CANCEL_BUTTON,
	OnAccept = function(dialog, data)
		C_GuildInfo.RequestGuildRenameRefund();
	end,
	OnCancel = nop,
	timeout = 0,
	hideOnEscape = 1,
}

GuildIconDisplayMixin = CreateFromMixins(SimpleTooltipRegionMixin);

function GuildIconDisplayMixin:UpdateTabard()
	local emblemFilename = select(10, GetGuildLogoInfo());
	local tabardInfo = C_GuildInfo.GetGuildTabardInfo("player");
	local hasTabard = emblemFilename and tabardInfo;

	self:SetShown(hasTabard);

	if hasTabard then
		local color = tabardInfo.backgroundColor;
		self.TabardBG:SetVertexColor(color.r, color.g, color.b);
		SetSmallGuildTabardTextures("player", self.Emblem);
		SetSmallGuildTabardTextures("player", self.HighlightEmblem);
	end
end
