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

	if self:GetCurrentGuildMoney() < self:GetRenameCost() then
		return Enum.GuildErrorType.NotEnoughMoney;
	end

	if self:IsRenameCooldownActive() then
		return Enum.GuildErrorType.InCooldown;
	end

	return Enum.GuildErrorType.Success;
end

function GuildRenameFrameMixin:HasStatus()
	return self.status ~= nil;
end

function GuildRenameFrameMixin:CanRequestNameChange()
	return self:GetNameChangeRequestStatus() == Enum.GuildErrorType.Success;
end

function GuildRenameFrameMixin:CanExecuteNameChange()
	-- All permissions and requirements to request a name change are met, AND the name check status is successful.
	if not self:GetNameCheckPassed()  then
		return false;
	end
	
	return self:CanRequestNameChange();
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
	return math.max(self.status.refundEligibleEndTime - GetServerTime(), 0);
end

function GuildRenameFrameMixin:GetRenameCooldownRemaining()
	return math.max(self.status.nextRenameTime - GetServerTime(), 0);
end

function GuildRenameFrameMixin:IsRenameCooldownActive()
	if self.status and self.status.nextRenameTime then
		if self.status.nextRenameTime == 0 or GetServerTime() < self.status.nextRenameTime then
			return true;
		end
	end

	return false;
end

function GuildRenameFrameMixin:GetPreviousGuildName()
	return self.status and self.status.oldGuildName or UNKNOWN;
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
	self:OnGuildRenameFlowStatusResponse(guildName, status);
end

function GuildRenameFrameMixin:OnGuildRenameRefundResult(guildName, status)
	self:OnGuildRenameFlowStatusResponse(guildName, status);
end

function GuildRenameFrameMixin:OnGuildRenameFlowStatusResponse(_guildName, status)
	if status == Enum.GuildErrorType.Success then
		self:BeginInteraction(); -- restart the entire interaction to see what state the window should show
		-- TODO: Or determine that the entire interaction should end once the refund succeeds.
		-- TODO: The toast system will also register for this event and use it to display the desired toast about the refund
	else
		UIErrorsFrame:AddExternalErrorMessage(GetGuildError(status));
	end
end

function GuildRenameFrameMixin:BeginInteraction()
	-- request status, and await response to show appropriate options
	C_GuildInfo.RequestRenameStatus();

	if not self.status then
		self:BeginInteractionMode(); -- there won't be a mode yet, but the UI needs to show immediately and enter the waiting state
	end
end

function GuildRenameFrameMixin:GetRenameModeFromStatus()
	if self:CanRequestNameChange() then
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
			self.MoneyFrame:Show();
			MoneyFrame_Update(self.MoneyFrame, self:GetCurrentGuildMoney());
			self.ContextButton:SetText(GUILD_RENAME_COMMAND_DO_RENAME);
			self.ContextButton:SetEnabled(self:CanExecuteNameChange());
		end,

		[GuildRenameMode.Title] = function(self)
			self.MoneyFrame:Hide();
			self.ContextButton:SetText(GOODBYE);
			self.ContextButton:SetEnabled(true);
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
			if isUserChange and hasText and editBox:IsVisible() then
				C_GuildInfo.RequestRenameNameCheck(text);
			end
		end)
	end);

	self.NameBox:SetScript("OnEnterPressed", function(editBox)
		self:CheckRequestNameChange();
	end);

	MoneyFrame_SetType(self.CostFrame, "STATIC");
end

function GuildRenameFlowMixin:CheckRequestNameChange()
	if self:GetManager():CanExecuteNameChange() then
		StaticPopup_Show("CONFIRM_PURCHASE_GUILD_RENAME", GetMoneyString(self:GetManager():GetRenameCost(), true, true), self:GetDesiredName(), { desiredName = self:GetDesiredName() });
	end
end

function GuildRenameFlowMixin:UpdateFromStatus()
	MoneyFrame_Update(self.CostFrame, self:GetManager():GetRenameCost());
end

function GuildRenameFlowMixin:GetDesiredName()
	return self.desiredName or "";
end

local statusIcons = {
	[true] = "common-icon-checkmark",
	[false] = "common-icon-redx",
};

local function GetNameStatusDisplay(statusCode, nameCheckError)
	if statusCode ~= Enum.GuildErrorType.Success then
		if statusCode == Enum.GuildErrorType.NameInvalid and nameCheckError then
			return nameCheckError;
		else
			return GetGuildError(statusCode);
		end
	end

	return "";
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
	self.StatusText:SetText("");
end

function GuildRenameFlowMixin:OnShow()
	self.NameBox:SetText("");
	self.NameBox.Instructions:Show();
	self.NameBox:SetFocus();

	self:ClearRenameStatus();
end

local renameCooldownFormatter = CreateFromMixins(SecondsFormatterMixin);
renameCooldownFormatter:Init(SECONDS_PER_DAY, SecondsFormatter.Abbreviation.None, SecondsFormatterConstants.DontRoundUpLastUnit, SecondsFormatterConstants.ConvertToLower);

local refundTimeFormatter = CreateFromMixins(SecondsFormatterMixin);
refundTimeFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.OneLetter, SecondsFormatterConstants.DontRoundUpLastUnit, SecondsFormatterConstants.ConvertToLower);

GuildRenameTitleFlowMixin = CreateFromMixins(GuildRenameManagedFlowMixin, {
	renameCooldownFormatter = renameCooldownFormatter,
	refundTimeFormatter = refundTimeFormatter,
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
			StaticPopup_Show("CONFIRM_GUILD_RENAME_REFUND", manager:GetPreviousGuildName(), GetMoneyString(manager:GetRefundAmount(), true, true), { timeLeft = manager:GetRefundTimeRemaining() });
		end
	end);
end

function GuildRenameTitleFlowMixin:UpdateFromStatus()
	local manager = self:GetManager();
	
	if manager:IsRenameEnabled() then
		self.Description:SetText(GUILD_RENAME_OPTIONS_DESCRIPTION);

		local hasPermission = manager:HasRenamePermission();
		local renameCooldownRemaining = manager:GetRenameCooldownRemaining();
	
		self.RenameOption:SetShown(hasPermission or renameCooldownRemaining > 0);
		self.RenameOption:SetEnabled(hasPermission);

		if hasPermission and renameCooldownRemaining <= 0 then
			self.RenameOption:SetTextAndResize(GUILD_RENAME_OPTIONS_RENAME_AVAILABLE);
		elseif renameCooldownRemaining > 0 then
			local timeUntilRename = self.renameCooldownFormatter:Format(renameCooldownRemaining);
			self.RenameOption:SetTextAndResize(GUILD_RENAME_OPTIONS_RENAME_COOLDOWN:format(timeUntilRename));
		end

		local refundTimeRemaining = manager:GetRefundTimeRemaining();
		local canRefund = hasPermission and refundTimeRemaining > 0;
		self.RefundOption:SetShown(canRefund);
		self.RefundOption:SetEnabled(canRefund);

		if canRefund then
			local timeUntilRefundExpires = self.refundTimeFormatter:Format(refundTimeRemaining);
			self.RefundOption:SetTextAndResize(GUILD_RENAME_OPTIONS_REFUND:format(timeUntilRefundExpires));
		end
	else
		local hasStatus = manager:HasStatus();
		self.Description:SetShown(hasStatus);
		manager:SetSpinnerShown(not hasStatus);

		if hasStatus then
			self.Description:SetText(GUILD_RENAME_OPTIONS_DESCRIPTION_DISABLED);
		end

		self.RenameOption:Hide();
		self.RefundOption:Hide();
	end
end

StaticPopupDialogs["CONFIRM_PURCHASE_GUILD_RENAME"] = {
	text = GUILD_RENAME_DIALOG_TEXT,
	button1 = GUILD_RENAME_DIALOG_CONFIRM_BUTTON,
	button2 = GUILD_RENAME_DIALOG_CANCEL_BUTTON,
	OnAccept = function(self)
		C_GuildInfo.RequestGuildRename(self.data.desiredName);
	end,
	OnCancel = nop,
	timeout = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_GUILD_RENAME_REFUND"] = {
	text = GUILD_RENAME_REFUND_DIALOG_TEXT,
	subText = GUILD_RENAME_REFUND_DIALOG_SUBTEXT,
	subtextIsTimer = true,
	autoSetTimeRemainingDataKey = "timeLeft",
	normalSizedSubText = true,
	timeFormatter = refundTimeFormatter,
	button1 = GUILD_RENAME_DIALOG_CONFIRM_BUTTON,
	button2 = GUILD_RENAME_DIALOG_CANCEL_BUTTON,
	OnAccept = function(self)
		C_GuildInfo.RequestGuildRenameRefund();
	end,
	OnCancel = nop,
	timeout = 0,
	hideOnEscape = 1,
}
