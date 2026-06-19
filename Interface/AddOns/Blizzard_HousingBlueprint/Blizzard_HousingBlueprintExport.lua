----------------- Top-Level Export Panel -----------------
local ExportWhileShownEvents = {
	"HOUSING_BLUEPRINT_EXPORT_FAILURE",
	"HOUSING_BLUEPRINT_EXPORT_SUCCESS",
};

-- Inherits HousingBlueprintBaseFrameMixin
HousingBlueprintExportFrameMixin = {};

function HousingBlueprintExportFrameMixin:OnEvent(event, ...)
	if event == "HOUSING_BLUEPRINT_EXPORT_SUCCESS" then
		local shareCode = ...;
		self:OnExportSuccess(shareCode);
	elseif event == "HOUSING_BLUEPRINT_EXPORT_FAILURE" then
		local result = ...;
		self:OnExportFailure(result);
	end
end

function HousingBlueprintExportFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ExportWhileShownEvents);
end

function HousingBlueprintExportFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ExportWhileShownEvents);
end

function HousingBlueprintExportFrameMixin:StartExportFlow()
	-- Don't start in the middle of other ongoing operations
	if HousingFramesUtil.IsBlueprintOperationInProgress() then
		return false;
	end

	if HousingBlueprintImportFrame:IsShown() then
		HousingBlueprintImportFrame:HideSelf();
	end

	self:ClearData();
	self:ShowSelf();
	self:ShowContent(self.InputContent);
	return true;
end

function HousingBlueprintExportFrameMixin:StartRoomExportFlow(roomGUID)
	if not roomGUID then
		return;
	end

	local started = self:StartExportFlow();
	if started then
		self.roomGUID = roomGUID;
		self.InputContent:ShowRoomInput();
	end
end

function HousingBlueprintExportFrameMixin:ClearData()
	self:UpdateLoadingState(--[[isWaitingForResult=]]false);
	self.InputContent:ClearData();
	self.SuccessContent:ClearData();
	self.roomGUID = nil;
end

function HousingBlueprintExportFrameMixin:ShowContent(contentFrame)
	self.InputContent:SetShown(self.InputContent == contentFrame);
	self.SuccessContent:SetShown(self.SuccessContent == contentFrame);

	self:MarkDirty();
end

function HousingBlueprintExportFrameMixin:OnSaveClicked()
	if not self.InputContent:IsInputValid() then
		return;
	end

	self:UpdateLoadingState(--[[isWaitingForResult=]]true);
	local selectedType, nameText = self.InputContent:GetInputValues();

	C_HouseEditor.LeaveHouseEditor();

	if selectedType == Enum.HousingBlueprintType.Room then
		local roomGUID = self.roomGUID or C_HousingLayout.GetRoomPlayerIsIn();
		C_HousingBlueprint.ExportRoomBlueprint(nameText, roomGUID);
	else
		C_HousingBlueprint.ExportBlueprint(selectedType, nameText);
	end
end

function HousingBlueprintExportFrameMixin:UpdateLoadingState(isWaitingForResult)
	self.isWaitingForResult = isWaitingForResult;
	self.LoadingOverlay:SetShown(self.isWaitingForResult);
	self.InputContent:UpdateLoadingState(self.isWaitingForResult);
	self.CloseButton:SetEnabled(not self.isWaitingForResult);
end

function HousingBlueprintExportFrameMixin:OnExportSuccess(shareCode)
	self:UpdateLoadingState(--[[isWaitingForResult=]]false);
	local _, nameText = self.InputContent:GetInputValues();
	self.SuccessContent:SetData(HOUSING_BLUEPRINT_EXPORT_NAME_SAVED_FMT:format(nameText), shareCode);
	self:ShowContent(self.SuccessContent);
end

function HousingBlueprintExportFrameMixin:OnExportFailure(result)
	self:UpdateLoadingState(--[[isWaitingForResult=]]false);

	local errorText = HousingResultToErrorText[result];
	if not errorText then
		errorText = ERR_HOUSING_RESULT_BLUEPRINT_GENERIC_EXPORT_ERROR;
	end

	self.InputContent:SetError(HOUSING_BLUEPRINT_EXPORT_ERROR_FMT:format(errorText));
end

function HousingBlueprintExportFrameMixin:IsOperationInProgress()
	return self.isWaitingForResult;
end

----------------- Input Content -----------------
HousingBlueprintExportInputContentMixin = {};

function HousingBlueprintExportInputContentMixin:OnLoad()
	self.NameInputBox.Instructions:SetText(HOUSING_BLUEPRINT_EXPORT_NAME_PLACEHOLDER);
	self.NameInputBox:SetMaxLetters(Constants.HousingConsts.BlueprintNameMaxCharacters);
	-- Replace the inherited indentation
	self.NameInputBox.Instructions:SetAllPoints();

	self.NameInputBox:SetScript("OnTextChanged", function()
		InputBoxInstructions_OnTextChanged(self.NameInputBox);
		self:UpdateSaveButton();
	end);

	self.SaveButton:SetScript("OnClick", function()
		self:GetParent():OnSaveClicked();
	end);
end

function HousingBlueprintExportInputContentMixin:OnShow()
	local isInsideHouse = C_Housing.IsInsideHouse();
	self.TypeDropdown:SetupMenu(function(dropdown, rootDescription)
		local function IsSelected(blueprintType)
			return self.selectedType and self.selectedType == blueprintType;
		end

		local function SetSelected(blueprintType)
			self.selectedType = blueprintType;
			self:UpdateSaveButton();
		end

		local function AddBlueprintTypeOption(blueprintType)
			local optionName = HousingBlueprintTypeOptionStrings[blueprintType];
			rootDescription:CreateHighlightRadio(optionName, IsSelected, SetSelected, blueprintType);
		end

		AddBlueprintTypeOption(Enum.HousingBlueprintType.House);
		AddBlueprintTypeOption(Enum.HousingBlueprintType.Interior);
		AddBlueprintTypeOption(Enum.HousingBlueprintType.Exterior);

		if isInsideHouse then
			AddBlueprintTypeOption(Enum.HousingBlueprintType.Room);
		end
	end);
	self.TypeDropdown:Show();
	self:MarkDirty();
end

function HousingBlueprintExportInputContentMixin:ShowRoomInput()
	self.selectedType = Enum.HousingBlueprintType.Room;
	self.NameInputLabel:Show();
	self.TypeDropdown:Hide();
	self:MarkDirty();
end

function HousingBlueprintExportInputContentMixin:ClearData()
	self.selectedType = nil;
	self.isWaitingForResult = nil;
	self.TypeDropdown:CloseMenu();
	self.NameInputBox:SetText("");
	self.SaveButton:Disable();
	self.SaveButton:SetDisabledTooltip(nil);
	self.ErrorText:Hide();
	self.NameInputLabel:Hide();
end

function HousingBlueprintExportInputContentMixin:UpdateLoadingState(isWaitingForResult)
	self.isWaitingForResult = isWaitingForResult;
	self.NameInputBox:SetEnabled(not isWaitingForResult);
	self.TypeDropdown:SetEnabled(not isWaitingForResult);
	self:UpdateSaveButton();
end

function HousingBlueprintExportInputContentMixin:SetError(errorText)
	self.ErrorText:SetText(errorText);
	self.ErrorText:SetShown(errorText and erroText ~= "");
	self:MarkDirty();
end

function HousingBlueprintExportInputContentMixin:IsInputValid()
	return self:IsTypeSelectionValid() and self:IsNameInputValid();
end

function HousingBlueprintExportInputContentMixin:GetInputValues()
	return self.selectedType, self.NameInputBox:GetText();
end

function HousingBlueprintExportInputContentMixin:IsTypeSelectionValid()
	return self.selectedType ~= nil;
end

function HousingBlueprintExportInputContentMixin:IsNameInputValid()
	local nameText = self.NameInputBox:GetText();
	local numChars = strlenutf8(nameText);
	return numChars >= Constants.HousingConsts.BlueprintNameMinCharacters and numChars <= Constants.HousingConsts.BlueprintNameMaxCharacters;
end

function HousingBlueprintExportInputContentMixin:UpdateSaveButton()
	if self.isWaitingForResult then
		self.SaveButton:Disable();
		self.SaveButton:SetDisabledTooltip(nil);
	else
		local isTypeValid = self:IsTypeSelectionValid();
		local isNameValid = self:IsNameInputValid();
		if isTypeValid and isNameValid then
			self.SaveButton:Enable();
			self.SaveButton:SetDisabledTooltip(nil);
		else
			local disabledTooltip = nil;
			if not isTypeValid and not isNameValid then
				disabledTooltip = HOUSING_BLUEPRINT_EXPORT_SAVE_TOOLTIP_TYPE_AND_NAME;
			elseif not isNameValid then
				disabledTooltip = HOUSING_BLUEPRINT_EXPORT_SAVE_TOOLTIP_NAME;
			else
				disabledTooltip = HOUSING_BLUEPRINT_EXPORT_SAVE_TOOLTIP_TYPE;
			end
			self.SaveButton:Disable();
			self.SaveButton:SetDisabledTooltip(disabledTooltip, "ANCHOR_BOTTOM");
		end
	end
end

----------------- Success Content -----------------
HousingBlueprintExportSuccessContentMixin = {};

function HousingBlueprintExportSuccessContentMixin:OnLoad()
	self.ShareCodeBox.EditBox:SetAutoFocus(false);

	-- Ensure the success content's min size is wide enough for the localized text in both final share buttons, while also keeping them equal sizes
	local chatLinkWidth = self.ChatLinkButton:GetTextWidth() + 40;
	local clipboardWidth =  self.ClipboardButton:GetTextWidth() + 40;
	local largestShareButtonWidth = math.max(chatLinkWidth, clipboardWidth);
	self.minimumWidth = largestShareButtonWidth + largestShareButtonWidth + 10;

	self.ClipboardButton:SetScript("OnClick", function()
		CopyToClipboard(self.ShareCodeBox.EditBox:GetText());
		ChatFrameUtil.DisplaySystemMessageInPrimary(HOUSING_BLUEPRINT_EXPORT_CLIPBOARD_CONFIRMATION);
	end);

	-- TODO: Implement blueprint collection UI
	self.BlueprintsCollectionButton:Disable();
	self.BlueprintsCollectionButton:SetDisabledTooltip("Not yet implemented", "ANCHOR_BOTTOM");

	self.ChatLinkButton:SetScript("OnClick", function()
		local blueprintLink = C_HousingBlueprint.GetBlueprintHyperlink(self.ShareCodeBox.EditBox:GetText());
		if not ChatFrameUtil.InsertLink(blueprintLink) then
			ChatFrameUtil.OpenChat(blueprintLink);
		end
	end);
end

function HousingBlueprintExportSuccessContentMixin:SetData(savedName, shareCode)
	self.SavedName:SetText(savedName);
	self.ShareCodeBox.EditBox:SetText(shareCode);
end

function HousingBlueprintExportSuccessContentMixin:ClearData()
	self.SavedName:SetText("");
	self.ShareCodeBox.EditBox:SetText("");
end
