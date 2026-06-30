local HousingBlueprintTypeConfirmationStrings = {
	[Enum.HousingBlueprintType.Room] = nil, -- Rooms don't replace anything, so don't need extra confirmation
	[Enum.HousingBlueprintType.House] = HOUSING_BLUEPRINT_IMPORT_CONFIRMATION_TITLE_FULL_LAYOUT,
	[Enum.HousingBlueprintType.Interior] = HOUSING_BLUEPRINT_IMPORT_CONFIRMATION_TITLE_INTERIOR,
	[Enum.HousingBlueprintType.Exterior] = HOUSING_BLUEPRINT_IMPORT_CONFIRMATION_TITLE_EXTERIOR,
};

StaticPopupDialogs["CONFIRM_BLUEPRINT_IMPORT"] = {
	text = "%s",
	subText = HOUSING_BLUEPRINT_IMPORT_CONFIRMATION_TEXT,
	button1 = HOUSING_BLUEPRINT_IMPORT_CONFIRMATION_CONFIRM,
	button2 = HOUSING_BLUEPRINT_IMPORT_CONFIRMATION_CANCEL,
	hideOnEscape = 1,
	selectCallbackByIndex = true,
	OnButton1 = function(self, data)
		-- Confirm
		data.owner:OnImportConfirmed(data.blueprintCode, data.blueprintType);
		self:Hide();
	end,
	OnButton2 = function(self, data)
		-- Cancel
		self:Hide();
	end,
};

----------------- Top-Level Import Panel -----------------
-- Inherits HousingBlueprintBaseFrameMixin
HousingBlueprintImportFrameMixin = {};

function HousingBlueprintImportFrameMixin:OnHide()
	self:ClearData();
end

function HousingBlueprintImportFrameMixin:StartImportFlow(prepopulatedShareCode)
	-- Don't start in the middle of other ongoing operations
	if HousingFramesUtil.IsBlueprintOperationInProgress() then
		return;
	end

	self:ClearData();

	local startingContent = self.InputContent;
	if prepopulatedShareCode then
		self.InputContent:SetShareCode(prepopulatedShareCode);
		if self.InputContent:IsInputValid() then
			startingContent = self.ValidationContent;
			 self.ValidationContent:SetShareCode(prepopulatedShareCode);
		end
	end

	self:ShowSelf();
	self:ShowContent(startingContent);
end

function HousingBlueprintImportFrameMixin:ClearData()
	self.isReadOnly = nil;
	self.InputContent:ClearData();
	self.ValidationContent:ClearData();
end

function HousingBlueprintImportFrameMixin:IsShowingBlueprint(shareCode)
	local inputCode = self.InputContent:GetInputValues();
	if inputCode and inputCode == shareCode then
		return true;
	end

	return self.ValidationContent:IsShowingBlueprint(shareCode);
end

function HousingBlueprintImportFrameMixin:ShowContent(contentFrame)
	self.InputContent:SetShown(self.InputContent == contentFrame);
	self.ValidationContent:SetShown(self.ValidationContent == contentFrame);

	self:MarkDirty();
end

function HousingBlueprintImportFrameMixin:OnInputNextClicked()
	if not self.InputContent:IsInputValid() then
		return;
	end

	PlaySound(SOUNDKIT.HOUSING_BLUEPRINTS_BUTTONS);

	local blueprintCode, blueprintType = self.InputContent:GetInputValues();

	self.ValidationContent:SetShareCode(blueprintCode);
	self:ShowContent(self.ValidationContent);
end

function HousingBlueprintImportFrameMixin:OnValidationNextClicked()
	if not self.ValidationContent:CanImport() then
		return;
	end

	PlaySound(SOUNDKIT.HOUSING_BLUEPRINTS_BUTTONS);

	local blueprintCode, blueprintType = self.ValidationContent:GetBlueprintValues();
	local confirmationString = HousingBlueprintTypeConfirmationStrings[blueprintType];
	if confirmationString then
		local data = { blueprintCode = blueprintCode, blueprintType = blueprintType, owner = self };
		StaticPopup_Show("CONFIRM_BLUEPRINT_IMPORT", confirmationString, nil, data);
		self:HideSelf();
	else
		self:OnImportConfirmed(blueprintCode, blueprintType);
	end
end

function HousingBlueprintImportFrameMixin:OnImportConfirmed(blueprintCode, blueprintType)
	if blueprintType == Enum.HousingBlueprintType.Room then
		-- Rooms have their own flow as they require the extra step of selecting an available door
		C_HousingBlueprint.StartImportRoomBlueprint(blueprintCode);
		self:HideSelf();
	else
		self:OnImportStarting();
		C_HousingBlueprint.ImportBlueprint(blueprintCode);
	end
end

function HousingBlueprintImportFrameMixin:OnImportStarting()
	-- Replace this as needed when final import "loading visual" handling is implemented
	HousingBlueprintImportLoadingFrame:OnImportStarting();
	self:HideSelf();
	if HousingBlueprintContentListFrame:IsShown() then
		HousingBlueprintContentListFrame:HideSelf();
	end

	C_HouseEditor.LeaveHouseEditor();
end

function HousingBlueprintImportFrameMixin:IsOperationInProgress()
	-- Replace this as needed when final import "loading visual" handling is implemented
	return HousingBlueprintImportLoadingFrame:IsShown();
end

----------------- Input Content -----------------
HousingBlueprintImportInputContentMixin = {};

function HousingBlueprintImportInputContentMixin:OnLoad()
	self.ShareCodeBox.EditBox:SetAutoFocus(false);
	self.ShareCodeBox.EditBox:SetScript("OnTextChanged", function(editBox, isUserChange)
		InputScrollFrame_OnTextChanged(editBox, isUserChange);
		self:OnInputUpdated();
	end);

	self.NextButton:SetScript("OnClick", function()
		self:GetParent():OnInputNextClicked();
	end);

	self.GearDropdown:SetupMenu(function(_dropdown, rootDescription)
		rootDescription:CreateButton(HOUSING_BLUEPRINT_REPORT, GenerateClosure(self.OnReportClicked, self));
	end);
end

function HousingBlueprintImportInputContentMixin:OnReportClicked()
	if not self:IsInputValid() then
		return;
	end
	local blueprintCode, blueprintType = self:GetInputValues();
	local reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.HousingBlueprint);
	reportInfo:SetBlueprintShareCode(blueprintCode);
	ReportFrame:InitiateReport(reportInfo, nil --[[player name]], nil, --[[isBnetReport]] false, --[[sendReportWithoutDialog]] false);
end

function HousingBlueprintImportInputContentMixin:SetShareCode(shareCode)
	self.ShareCodeBox.EditBox:SetText(shareCode);
	self:OnInputUpdated();
end

function HousingBlueprintImportInputContentMixin:ClearData()
	self.NoticeText:SetText("");
	self.ShareCodeBox.EditBox:SetText("");
	self.NextButton:Disable();
end

-- Returns isValid, isNonEmpty
function HousingBlueprintImportInputContentMixin:IsInputValid()
	local isValid = false;
	local isNonEmpty = UserEditBoxNonEmpty(self.ShareCodeBox.EditBox);

	if isNonEmpty then
		local codeText = self.ShareCodeBox.EditBox:GetText();
		isValid = C_HousingBlueprint.IsShareCodeValid(codeText);
	end

	return isValid, isNonEmpty;
end

function HousingBlueprintImportInputContentMixin:GetInputValues()
	local codeText = self.ShareCodeBox.EditBox:GetText();
	return codeText, C_HousingBlueprint.GetBlueprintTypeForCode(codeText);
end

function HousingBlueprintImportInputContentMixin:OnInputUpdated()
	-- Default to no text if nothing entered
	local newNoticeText = "";
	local isInputValid, hasAnyInput = self:IsInputValid();

	if hasAnyInput then
		newNoticeText = isInputValid and HOUSING_BLUEPRINT_IMPORT_NOTICE or HOUSING_BLUEPRINT_IMPORT_SHARECODE_INVALID;
	end
	
	local isError = hasAnyInput and not isInputValid;
	self:SetNoticeText(newNoticeText, isError);
	self.NextButton:SetEnabled(isInputValid);
end

function HousingBlueprintImportInputContentMixin:SetNoticeText(text, isError)
	self.NoticeText:SetText(text);
	local textColor = isError and RED_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
	self.NoticeText:SetTextColor(textColor:GetRGB());
	-- Reset width so that it properly expands as part of the containing Layout frame, without bloating the resulting parent width
	self.NoticeText:SetWidth(1);
	self:MarkDirty();
end

----------------- Import Validation Content -----------------
HousingBlueprintImportValidationContentMixin = {};

local ValidationWhileShownEvents = {
	"HOUSING_NUM_DECOR_PLACED_CHANGED",
	"HOUSING_STORAGE_UPDATED",
	"HOUSING_STORAGE_ENTRY_UPDATED",
	"HOUSING_LAYOUT_ROOM_RECEIVED",
	"HOUSING_LAYOUT_ROOM_REMOVED",
	"HOUSE_LEVEL_CHANGED",
	"HOUSING_BLUEPRINT_CONTENTS_RECEIVED",
	"HOUSING_BLUEPRINT_CONTENTS_FAILURE"
};

function HousingBlueprintImportValidationContentMixin:OnLoad()
	self.ImportButton:SetScript("OnClick", function()
		self:GetParent():OnValidationNextClicked();
	end);
	self.ContentSummary:SetContentUpdatedCallback(GenerateClosure(self.OnContentUpdated, self));
			PlaySound(SOUNDKIT.HOUSING_BLUEPRINTS_BUTTONS);
end

function HousingBlueprintImportValidationContentMixin:IsShowingBlueprint(shareCode)
	return self.ContentSummary:IsShowingBlueprint(shareCode);
end

function HousingBlueprintImportValidationContentMixin:IsShowingBlueprintForTarget(shareCode, houseGUID)
	return self.ContentSummary:IsShowingBlueprintForTarget(shareCode, houseGUID);
end

function HousingBlueprintImportValidationContentMixin:SetShareCode(shareCode)
	self.ContentSummary:SetShareCode(shareCode);
	self:UpdateImportButton();
end

function HousingBlueprintImportValidationContentMixin:ClearData()
	self.ContentSummary:ClearData();
end

function HousingBlueprintImportValidationContentMixin:GetBlueprintValues()
	return self.ContentSummary:GetBlueprintValues();
end

function HousingBlueprintImportValidationContentMixin:CanImport()
	return self.ContentSummary:IsContentImportable();
end

function HousingBlueprintImportValidationContentMixin:OnContentUpdated()
	self:UpdateImportButton();

	if showLoadingState and (not self.loopSoundHandle) then
		local _, soundHandle = PlaySound(SOUNDKIT.HOUSING_BLUEPRINTS_IMPORT_LOOP);
		self.loopSoundHandle = soundHandle;
	elseif (not showLoadingState) and self.loopSoundHandle then
		StopSound(self.loopSoundHandle);
		self.loopSoundHandle = nil;
	end
end

function HousingBlueprintImportValidationContentMixin:UpdateImportButton()
	local canImport, disabledText = self:CanImport();
	self.ImportButton:SetEnabled(canImport);

	if not canImport and self.ContentSummary:IsReadonly() then
		-- Only show location error text as a disabled tooltip, all other messaging is shown through Notice Text
		self.ImportButton:SetDisabledTooltip(ERR_HOUSING_BLUEPRINT_REQUIREMENT_LOCATION, "ANCHOR_BOTTOM");
	else
		self.ImportButton:SetDisabledTooltip(nil);
	end

	local noticeText, noticeTextColor = nil, nil;
	if not canImport and disabledText then
		-- If we have an error message for importing being disabled, show that
		noticeText = disabledText;
		noticeTextColor = RED_FONT_COLOR;
	elseif canImport and self.ContentSummary:HasUnmetRequirements() then
		-- Otherwise if importing is allowed but there are non-blocking unmet requirements, show a warning
		noticeText = HOUSING_BLUEPRINT_IMPORT_VALIDATION_IMPORT_WITH_MISSING;
		noticeTextColor = HIGHLIGHT_FONT_COLOR;
	end

	if noticeText and noticeTextColor then
		self.NoticeText:SetText(noticeText);
		self.NoticeText:SetTextColor(noticeTextColor:GetRGB());
		-- Reset width so that it properly expands as part of the containing Layout frame, without bloating the resulting parent width
		self.NoticeText:SetWidth(1);
		self.NoticeText:Show();
	else
		self.NoticeText:Hide();
	end

	self:MarkDirty();
end


----------------- Import-in-Progress Loading Visuals -----------------
-- TODO: Replace and/or modify all of this based on final loading visuals once we have an idea how visually-intensive or time-consuming imports end up being
local ImportLifetimeEvents = {
	"HOUSING_BLUEPRINT_IMPORT_STARTED",
};

local ImportLoadingWhileShownEvents = {
	"HOUSING_BLUEPRINT_IMPORT_FAILURE",
	"HOUSING_BLUEPRINT_IMPORT_SUCCESS",
};

HousingBlueprintImportLoadingFrameMixin = {};

function HousingBlueprintImportLoadingFrameMixin:OnLoad()
	FrameUtil.RegisterForTopLevelParentChanged(self);
	FrameUtil.RegisterFrameForEvents(self, ImportLifetimeEvents);
end

function HousingBlueprintImportLoadingFrameMixin:OnEvent(event, ...)
	if event == "HOUSING_BLUEPRINT_IMPORT_STARTED" then
		-- For catching contexts, like room import, where the Import UI won't still be open to trigger showing these loading visuals
		self:OnImportStarting();
	elseif event == "HOUSING_BLUEPRINT_IMPORT_SUCCESS" then
		self:OnImportSuccess();
	elseif event == "HOUSING_BLUEPRINT_IMPORT_FAILURE" then
		local result = ...;
		self:OnImportFailure(result);
	end
end

function HousingBlueprintImportLoadingFrameMixin:OnImportStarting()
	if not self:IsShown() then
		self:Show();
	end
end

function HousingBlueprintImportLoadingFrameMixin:OnShow()
	self:SetLoadingActive(true);
	FrameUtil.RegisterFrameForEvents(self, ImportLoadingWhileShownEvents);
end

function HousingBlueprintImportLoadingFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ImportLoadingWhileShownEvents);
	self:SetLoadingActive(false);
end

function HousingBlueprintImportLoadingFrameMixin:OnImportSuccess(shareCode)
	self:SetLoadingActive(false);
	self:ShowLoadingComplete();
	self:Hide();
end

function HousingBlueprintImportLoadingFrameMixin:OnImportFailure(result)
	local errorText = HousingResultToErrorText[result] or ERR_HOUSING_RESULT_BLUEPRINT_GENERIC_IMPORT_ERROR;
	UIErrorsFrame:AddExternalErrorMessage(HOUSING_BLUEPRINT_IMPORT_ERROR_FMT:format(errorText));
	self:SetLoadingActive(false);
	self:Hide();
end

function HousingBlueprintImportLoadingFrameMixin:SetLoadingActive(active)
	if active and (not self.loopSoundHandle) then
		local _, soundHandle = PlaySound(SOUNDKIT.HOUSING_BLUEPRINTS_IMPORT_LOOP);
		self.loopSoundHandle = soundHandle;
	elseif (not active) and self.loopSoundHandle then
		StopSound(self.loopSoundHandle);
		self.loopSoundHandle = nil;
	end
end

function HousingBlueprintImportLoadingFrameMixin:ShowLoadingComplete()
	if HouseEditorFrame and HouseEditorFrame.LayoutModeFrame and HouseEditorFrame.LayoutModeFrame:IsShown() then
		-- If it's active, have the Layout mode frame temporarily refrain from playing any "on room add sounds"
		-- As they can otherwise end up overlapping awkwardly with the blueprint import complete sounds
		HouseEditorFrame.LayoutModeFrame:StartRoomAddSoundPause();
	end

	PlaySound(SOUNDKIT.HOUSING_BLUEPRINTS_IMPORT_SUCCESS);
end
