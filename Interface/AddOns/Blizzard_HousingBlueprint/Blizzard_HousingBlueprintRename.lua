local RenameWhileShownEvents = {
	"HOUSING_BLUEPRINT_RENAME_SUCCESS",
	"HOUSING_BLUEPRINT_RENAME_FAILURE",
};

HousingBlueprintRenameFrameMixin = {};

function HousingBlueprintRenameFrameMixin:OnLoad()
	self.NameInputBox.Instructions:SetText(HOUSING_BLUEPRINT_RENAME_NAME_PLACEHOLDER);
	self.NameInputBox:SetMaxLetters(Constants.HousingConsts.BlueprintNameMaxCharacters);
	-- Replace the inherited indentation
	self.NameInputBox.Instructions:SetAllPoints();

	self.NameInputBox:SetScript("OnTextChanged", function()
		InputBoxInstructions_OnTextChanged(self.NameInputBox);
		self:UpdateSaveButton();
	end);
	self.SaveButton:SetScript("OnClick", function()
		self:OnSaveClicked();
	end);
end

function HousingBlueprintRenameFrameMixin:OnEvent(event, ...)
	if event == "HOUSING_BLUEPRINT_RENAME_SUCCESS" then
		self:OnRenameSuccess();
	elseif event == "HOUSING_BLUEPRINT_RENAME_FAILURE" then
		local result = ...;
		self:OnRenameFailure(result);
	end
end

function HousingBlueprintRenameFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RenameWhileShownEvents);
end

function HousingBlueprintRenameFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RenameWhileShownEvents);
	self:ClearData();
end

function HousingBlueprintRenameFrameMixin:IsOperationInProgress()
	return self.isWaitingForResult;
end

function HousingBlueprintRenameFrameMixin:ShowForBlueprint(blueprintInfo)
	-- Don't start in the middle of other ongoing operations
	if HousingFramesUtil.IsBlueprintOperationInProgress() then
		return;
	end

	self:ClearData();
	self.blueprintInfo = blueprintInfo;
	self:ShowSelf();
	self:MarkDirty();
end

function HousingBlueprintRenameFrameMixin:IsShowingBlueprint(shareCode)
	return self.blueprintInfo and self.blueprintInfo.shareCode == shareCode;
end

function HousingBlueprintRenameFrameMixin:ClearData()
	self.blueprintInfo = nil;
	self.isWaitingForResult = nil;
	self.NameInputBox:SetText("");
	self.NameInputBox:Enable();
	self.CloseButton:Enable();
	self.SaveButton:Disable();
	self.SaveButton:SetDisabledTooltip(nil);
	self.ErrorText:Hide();
	self.LoadingOverlay:Hide();
end

function HousingBlueprintRenameFrameMixin:UpdateLoadingState(isWaitingForResult)
	self.isWaitingForResult = isWaitingForResult;
	self.LoadingOverlay:SetShown(self.isWaitingForResult);
	self.NameInputBox:SetEnabled(not isWaitingForResult);
	self.CloseButton:SetEnabled(not self.isWaitingForResult);
	self:UpdateSaveButton();
end

function HousingBlueprintRenameFrameMixin:UpdateErrorText(errorText)
	self.ErrorText:SetText(errorText);
	self.ErrorText:SetShown(errorText and erroText ~= "");
	self:MarkDirty();
end

function HousingBlueprintRenameFrameMixin:UpdateSaveButton()
	if self.isWaitingForResult then
		self.SaveButton:Disable();
		self.SaveButton:SetDisabledTooltip(nil);
	else
		local isNameValid = self:IsInputValid();
		if isNameValid then
			self.SaveButton:Enable();
			self.SaveButton:SetDisabledTooltip(nil);
		else
			self.SaveButton:Disable();
			self.SaveButton:SetDisabledTooltip(HOUSING_BLUEPRINT_EXPORT_SAVE_TOOLTIP_NAME, "ANCHOR_BOTTOM");
		end
	end
end

function HousingBlueprintRenameFrameMixin:IsInputValid()
	local nameText = self.NameInputBox:GetText();
	local numChars = strlenutf8(nameText);
	return numChars >= Constants.HousingConsts.BlueprintNameMinCharacters and numChars <= Constants.HousingConsts.BlueprintNameMaxCharacters;
end

function HousingBlueprintRenameFrameMixin:OnSaveClicked()
	if not self.blueprintInfo or not self:IsInputValid() or self:IsOperationInProgress() then
		return;
	end	

	self:UpdateLoadingState(--[[isWaitingForResult=]]true);
	self:UpdateErrorText(nil);
	local newName = self.NameInputBox:GetText();
	C_HousingBlueprint.RenameBlueprint(self.blueprintInfo.blueprintID, newName);
end

function HousingBlueprintRenameFrameMixin:OnRenameSuccess()
	self:UpdateLoadingState(--[[isWaitingForResult=]]false);
	self:HideSelf();
end

function HousingBlueprintRenameFrameMixin:OnRenameFailure(result)
	self:UpdateLoadingState(--[[isWaitingForResult=]]false);
	local errorText = HousingResultToErrorText[result];
	if not errorText then
		errorText = ERR_HOUSING_BLUEPRINT_RENAME_FAILED;
	end
	self:UpdateErrorText(ERR_HOUSING_BLUEPRINT_RENAME_FAILED_FMT:format(errorText));
end
