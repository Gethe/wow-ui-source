ACCOUNT_SAVE_KICK_ERROR_CODE = 241;

GlueDialogTypes["ACCOUNT_SAVE_IN_PROGRESS"] = {
	text = ACCOUNT_SAVE_IN_PROGRESS,
	ignoreKeys = true,
	spinner = true,
	darken = true,
	cover = true,
	explicitAcknowledge = true,
}

GlueDialogTypes["ACCOUNT_SAVE_SUCCESS"] = {
	text = "",
	button1 = ACCOUNT_SAVE_FILE_BUTTON,
	button2 = ACCOUNT_SAVE_CLOSE_BUTTON,
	html = 1,
	explicitAcknowledge = true,
	OnAccept = function()
		LaunchURL(GlueDialog.data);
	end,
	OnCancel = function()
	end,
}

AccountSaveFrameMixin = {};

AccountSaveFrameMixin.VisualState = {
	Disabled = 1,
	EnabledLocked = 2,
	EnabledUnlocked = 3
};


function AccountSaveFrameMixin:OnLoad()
	self.LockEditBox:SetScript("OnTextChanged", GenerateClosure(self.OnLockEditBoxTextChanged, self));
	self.LockEditBox:SetScript("OnEnterPressed", GenerateClosure(self.OnLockEditBoxEnterPressed, self));
	self.LockEditBox:SetScript("OnEscapePressed", GenerateClosure(self.OnLockEditBoxEscapePressed, self));
	self.SaveButton:SetOnClickHandler(GenerateClosure(self.OnSaveButtonClicked, self));

	self:RegisterEvent("ACCOUNT_SAVE_ENABLED_UPDATE");
	self:RegisterEvent("ACCOUNT_LOCKED_POST_SAVE_UPDATE");
	self:RegisterEvent("ACCOUNT_SAVE_RESULT");
end

function AccountSaveFrameMixin:OnShow()
	self:UpdateAccountState();
end

function AccountSaveFrameMixin:UpdateAccountState()
	if not C_AccountServices.IsAccountSaveEnabled() then
		self.activeState = AccountSaveFrameMixin.VisualState.Disabled;
		self:Hide();
		return;
	end

	local oldState = self.activeState;

	if C_AccountServices.IsAccountLockedPostSave() then
		self.activeState = AccountSaveFrameMixin.VisualState.EnabledLocked;

		self.Text:SetText(HTML_START .. ACCOUNT_SAVE_DESCRIPTION_LOCKED .. HTML_END);
		self.Text:SetWidth(self.ContentInsets:GetWidth());
		self.LockEditBox:SetText("");
		self.LockEditBox:Hide();
		self.SaveButton:SetPoint("TOPLEFT", self.Text, "BOTTOMLEFT", 0, -5);
		self.SaveButton:SetEnabled(true);
	else
		self.activeState = AccountSaveFrameMixin.VisualState.EnabledUnlocked;

		self.Text:SetText(HTML_START .. ACCOUNT_SAVE_DESCRIPTION_UNLOCKED .. HTML_END);
		self.Text:SetWidth(self.ContentInsets:GetWidth());
		self.LockEditBox:Show();
		self.SaveButton:SetPoint("TOPLEFT", self.LockEditBox, "BOTTOMLEFT", -10, 0);
		self.SaveButton:SetEnabled(self:DoesLockStringMatch());
	end

	if C_AccountServices.IsAccountSaveInProgress() then
		self.LockEditBox:SetEnabled(false);
		self.SaveButton:SetEnabled(false);
		GlueDialog_Show("ACCOUNT_SAVE_IN_PROGRESS");
	else
		self.LockEditBox:SetEnabled(true);
		GlueDialog_Hide("ACCOUNT_SAVE_IN_PROGRESS");
	end

	if self.activeState ~= oldState then
		self:UpdateSizing();
	end
end

function AccountSaveFrameMixin:OnLockEditBoxTextChanged()
	self.SaveButton:SetEnabled(self:DoesLockStringMatch());
end

function AccountSaveFrameMixin:OnLockEditBoxEnterPressed()
	if self:DoesLockStringMatch() then
		self:SaveAccountData();
	end
end

function AccountSaveFrameMixin:OnLockEditBoxEscapePressed()
	self.LockEditBox:ClearFocus();
end

function AccountSaveFrameMixin:OnSaveButtonClicked()
	if self.SaveButton:IsEnabled() then
		self:SaveAccountData();
	end
end

function AccountSaveFrameMixin:DoesLockStringMatch()
	return ConfirmationEditBoxMatches(self.LockEditBox, ACCOUNT_SAVE_CONFIRM_STRING);
end

function AccountSaveFrameMixin:SaveAccountData()
	local startedSuccessfully, errorCode = C_AccountServices.SaveAccountData();

	if not startedSuccessfully then
		self:ProcessAccountSaveError(errorCode);
	end

	self:UpdateAccountState();
end

function AccountSaveFrameMixin:OnEvent(event, ...)
	if event == "ACCOUNT_SAVE_ENABLED_UPDATE" or event == "ACCOUNT_LOCKED_POST_SAVE_UPDATE" then
		self:UpdateAccountState();
	elseif event == "ACCOUNT_SAVE_RESULT" then
		local result, outputFolderPath, outputFilePath = ...;

		if result == Enum.AccountExportResult.Success then
			local fileLink = "<a href=\"" .. outputFolderPath .. "\">".. outputFilePath .. "</a>";
			local successMessage = HTML_START_CENTERED .. ACCOUNT_SAVE_SUCCESS .. "|n|n" .. ACCOUNT_SAVE_SUCCESS_DETAILS .. "|n|n" .. fileLink .. HTML_END;
			GlueDialog_Show("ACCOUNT_SAVE_SUCCESS", successMessage, outputFolderPath);
		else
			self:ProcessAccountSaveError(result);
		end

		self:UpdateAccountState();
	end
end

function AccountSaveFrameMixin:ProcessAccountSaveError(errorCode)
	local errorText;
	if errorCode == Enum.AccountExportResult.TimedOut then
		errorText = ACCOUNT_SAVE_ERROR_TIMEOUT;
	elseif errorCode == Enum.AccountExportResult.NoAccountFound then
		errorText = ACCOUNT_SAVE_ERROR_INVALID_ACCOUNT;
	elseif errorCode == Enum.AccountExportResult.RequestedInvalidCharacter then
		errorText = ACCOUNT_SAVE_ERROR_INVALID_CHARACTER;
	elseif errorCode == Enum.AccountExportResult.FileInvalid then
		errorText = ACCOUNT_SAVE_ERROR_FILE_INVALID;
	elseif errorCode == Enum.AccountExportResult.FileWriteFailed then
		errorText = ACCOUNT_SAVE_ERROR_FILE_WRITE;
	elseif errorCode == Enum.AccountExportResult.Unavailable then
		errorText = ACCOUNT_SAVE_ERROR_UNAVAILABLE;
	elseif errorCode == Enum.AccountExportResult.AlreadyInProgress then
		errorText = ACCOUNT_SAVE_ERROR_ALREADY_IN_PROGRESS;
	elseif errorCode == Enum.AccountExportResult.Cancelled then
		errorText = ACCOUNT_SAVE_ERROR_CANCELLED;
	else
		errorText = ACCOUNT_SAVE_ERROR_OTHER;
	end

	GlueDialog_Show("OKAY_MUST_ACCEPT", errorText);
end

function AccountSaveFrameMixin:OnSizeChanged()
	self.Text:SetWidth(self.ContentInsets:GetWidth());
end

local function GetYPadding(frame, pointNum)
	local point, _, _, _, offsetY = frame:GetPoint(pointNum);
	if string.find(point, "TOP") then
		return -(offsetY);
	else
		return offsetY;
	end
end

-- Manually adjust frame height to fit content
-- Using a layout frame template would be preferable, but they're too inconsistently available across classic & mainline versions
function AccountSaveFrameMixin:UpdateSizing()
		local verticalPadding =
			GetYPadding(self.ContentInsets, 1) + -- Inset top
			GetYPadding(self.ContentInsets, 2) + -- Inset bottom
			GetYPadding(self.Text, 1) + -- Text top
			GetYPadding(self.SaveButton, 1); -- Button top

		local panelHeight = verticalPadding + self.AlertIcon:GetHeight() + self.Text:GetHeight() + self.SaveButton:GetHeight();
		if self.LockEditBox:IsShown() then
			panelHeight = panelHeight + GetYPadding(self.LockEditBox, 1) + self.LockEditBox:GetHeight();
		end
		self:SetHeight(math.floor(panelHeight + 0.5));
end