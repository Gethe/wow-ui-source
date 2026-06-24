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

function HousingBlueprintImportFrameMixin:TryHandleEscape()
	if StaticPopup_EscapePressed() then
		return true;
	end
	if self:IsOperationInProgress() then
		-- If loading state is shown, consume the Escape key input
		return true;
	end
	return HousingBlueprintBaseFrameMixin.TryHandleEscape(self);
end

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
	local blueprintCode, blueprintType = self.InputContent:GetInputValues();

	self.ValidationContent:SetShareCode(blueprintCode);
	self:ShowContent(self.ValidationContent);
end

function HousingBlueprintImportFrameMixin:OnValidationNextClicked()
	if not self.ValidationContent:CanImport() then
		return;
	end

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

	self.CountListContainer.ContentsListButton:SetScript("OnClick", function()
		if self.blueprintContentInfo then
			HousingBlueprintContentListFrame:ShowBlueprintContents(self.blueprintContentInfo, self.isReadonly);
		end
	end);
end

function HousingBlueprintImportValidationContentMixin:OnEvent(event, ...)
	if event == "HOUSING_NUM_DECOR_PLACED_CHANGED"
		or event == "HOUSING_STORAGE_UPDATED"
		or event == "HOUSING_LAYOUT_ROOM_RECEIVED" 
		or event == "HOUSING_LAYOUT_ROOM_REMOVED"
		or event == "HOUSE_LEVEL_CHANGED" then
		if not self.isReadonly then
			self:UpdateBlueprintContentsData();
		end
	elseif event == "HOUSING_STORAGE_ENTRY_UPDATED" then
		local entryVariantID = ...;
		if not self.isReadonly and self:DoesBlueprintContainCatalogEntry(entryVariantID) then
			self:UpdateBlueprintContentsData();
		end
	elseif event == "HOUSING_BLUEPRINT_CONTENTS_FAILURE" then
		local sharecode, result = ...;
		self:OnContentRequestFailure(result);
	elseif event == "HOUSING_BLUEPRINT_CONTENTS_RECEIVED" then
		local contentInfo = ...;
		if contentInfo and self.blueprintCode == contentInfo.shareCode then
			self:OnBlueprintContentsReceived(contentInfo);
		end
	end
end

function HousingBlueprintImportValidationContentMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ValidationWhileShownEvents);

	if self.blueprintCode then
		self:UpdateBlueprintContentsData();
	end
end

function HousingBlueprintImportValidationContentMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ValidationWhileShownEvents);
end

function HousingBlueprintImportValidationContentMixin:IsShowingBlueprint(shareCode)
	return self.blueprintContentInfo and self.blueprintContentInfo.shareCode == shareCode;
end

function HousingBlueprintImportValidationContentMixin:IsShowingBlueprintForTarget(shareCode, houseGUID)
	if not self.blueprintContentInfo then
		return false;
	end

	return self.blueprintContentInfo.shareCode == shareCode and self.blueprintContentInfo.targetHouseGUID == houseGUID;
end

function HousingBlueprintImportValidationContentMixin:SetShareCode(shareCode)
	self.blueprintCode = shareCode;
	self.blueprintType = C_HousingBlueprint.GetBlueprintTypeForCode(self.blueprintCode);
	self.isReadonly = not C_HousingBlueprint.CanImportTypeFromCurrentLocation(self.blueprintType);
	self:UpdateImportButton();

	if self:IsShown() then
		self:UpdateBlueprintContentsData();
	end
end

function HousingBlueprintImportValidationContentMixin:UpdateBlueprintContentsData()
	if self.isWaitingForContent then
		return;
	end

	-- Avoid showing loading state if we're requesting an update on blueprint contents we're already displaying
	local showLoadingState = not self.blueprintContentInfo or self.blueprintContentInfo.shareCode ~= self.blueprintCode;
	self:UpdateWaitingState(--[[isWaitingForContent]] true, showLoadingState);
	
	C_HousingBlueprint.RequestBlueprintContents(self.blueprintCode);
end

function HousingBlueprintImportValidationContentMixin:ClearData()
	self.blueprintCode = nil;
	self.blueprintType = nil;
	self.isReadonly = nil;
	self.isWaitingForContent = nil;
	self.showLoadingState = nil;
	self.blueprintContentInfo = nil;
	self.budgetInfo = nil;

	self.CountListContainer.ContentsCountText:SetText("");
end

function HousingBlueprintImportValidationContentMixin:GetBlueprintValues()
	return self.blueprintCode, self.blueprintType;
end

function HousingBlueprintImportValidationContentMixin:CanImport()
	if not self.blueprintContentInfo then
		return false;
	end

	if self.isReadonly then
		return false;
	end

	if not FlagsUtil.IsAnythingSet(self.blueprintContentInfo.blockingRequirementFlags) then
		return true;
	end

	local disabledTooltip = nil;
	-- If insufficient budget, convey that in the most precise way
	if FlagsUtil.IsSet(self.blueprintContentInfo.blockingRequirementFlags, Enum.HousingBlueprintUnmetRequirementFlags.InsufficientBudget) then
		if self.budgetInfo.insufficientRoom and (self.budgetInfo.insufficientInterior or self.budgetInfo.insufficientExterior) then
			disabledTooltip = ERR_HOUSING_BLUEPRINT_REQUIREMENT_BUDGETS;
		elseif self.budgetInfo.insufficientRoom then
			disabledTooltip = ERR_HOUSING_BLUEPRINT_REQUIREMENT_BUDGET_ROOM;
		else
			disabledTooltip = ERR_HOUSING_BLUEPRINT_REQUIREMENT_BUDGET_DECOR;
		end
	else
		-- Otherwise, choose the first other blocking requirement flag we have a tooltip for
		for flagName, flagValue in pairs(Enum.HousingBlueprintUnmetRequirementFlags) do
			if FlagsUtil.IsSet(self.blueprintContentInfo.blockingRequirementFlags, flagValue) and HousingBlueprintUnmetRequirementStrings[flagValue] then
				disabledTooltip = HousingBlueprintUnmetRequirementStrings[flagValue];
				break;
			end
		end
	end

	return false, disabledTooltip;
end

function HousingBlueprintImportValidationContentMixin:OnContentRequestFailure(result)
	self:UpdateWaitingState(--[[isWaitingForContent]] false, --[[showLoadingState]] false);
	local errorText = HousingResultToErrorText[result] or ERR_HOUSING_RESULT_BLUEPRINT_GENERIC_IMPORT_ERROR;
	UIErrorsFrame:AddExternalErrorMessage(HOUSING_BLUEPRINT_IMPORT_ERROR_FMT:format(errorText));
end

function HousingBlueprintImportValidationContentMixin:DoesBlueprintContainCatalogEntry(entryVariantID)
	if not self.blueprintContentInfo then
		return false;
	end

	local targetContentType = nil;
	if entryVariantID.entryType == Enum.HousingCatalogEntryType.Decor then
		targetContentType = Enum.HousingBlueprintContentType.Decor;
	elseif entryVariantID.entryType == Enum.HousingCatalogEntryType.Room then
		targetContentType = Enum.HousingBlueprintContentType.Room;
	else
		return false;
	end

	for _, contentGroup in ipairs(self.blueprintContentInfo.contentGroups) do
		if contentGroup.contentType == targetContentType then
			for _, entry in ipairs(contentGroup.entries) do
				if entry.recordID == entryVariantID.recordID then
					return true;
				end
			end
		end
	end

	return false;
end

function HousingBlueprintImportValidationContentMixin:OnBlueprintContentsReceived(contentInfo)
	self:UpdateWaitingState(--[[isWaitingForContent]] false, --[[showLoadingState]] false);
	self.blueprintContentInfo = contentInfo;

	local availableInteriorBudget, availableExteriorBudget, availableRoomBudget = nil, nil, nil;
	if not self.isReadonly then
		availableInteriorBudget, availableExteriorBudget = C_HousingDecor.GetBothMaxPlacementBudgets();
		availableRoomBudget = C_HousingLayout.GetRoomPlacementBudget();
		-- Rooms are the only blueprint type that add to the existing spent budgets rather than replace them, so need to display "available" rather than "max"
		if availableInteriorBudget and self.blueprintType == Enum.HousingBlueprintType.Room then
			local spentDecorBudget = C_HousingDecor.GetSpentPlacementBudget();
			local spentRoomBudget = C_HousingLayout.GetSpentPlacementBudget();
			availableInteriorBudget = availableInteriorBudget - spentDecorBudget;
			availableRoomBudget = availableRoomBudget - spentRoomBudget;
		end
	end

	self.budgetInfo = {
		insufficientInterior = availableInteriorBudget and self.blueprintContentInfo.interiorDecorBudgetCost > availableInteriorBudget,
		insufficientExterior = availableExteriorBudget and self.blueprintContentInfo.exteriorDecorBudgetCost > availableExteriorBudget,
		insufficientRoom = availableRoomBudget and self.blueprintContentInfo.roomBudgetCost > availableRoomBudget,
	};

	self:UpdateBudget(self.BudgetsContainer.IndoorDecorBudget, self.blueprintContentInfo.interiorDecorBudgetCost, availableInteriorBudget, self.budgetInfo.insufficientInterior);
	self:UpdateBudget(self.BudgetsContainer.OutdoorDecorBudget, self.blueprintContentInfo.exteriorDecorBudgetCost, availableExteriorBudget, self.budgetInfo.insufficientExterior);
	self:UpdateBudget(self.BudgetsContainer.RoomBudget, self.blueprintContentInfo.roomBudgetCost, availableRoomBudget, self.budgetInfo.insufficientRoom);

	local numItems = 0;
	local numMissing = 0;
	for _, contentGroup in ipairs(self.blueprintContentInfo.contentGroups) do
		for _, entry in ipairs(contentGroup.entries) do
			numItems = numItems + entry.total;
			if entry.invalid then
				numMissing = numMissing + entry.total;
			else
				numMissing = numMissing + entry.numMissing;
			end
		end
	end
	if self.isReadonly then
		self.CountListContainer.ContentsCountText:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_CONTENTS_COUNT_FMT:format(numItems));
	else
		local numAvailable = numItems - numMissing;
		self.CountListContainer.ContentsCountText:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_CONTENTS_COUNT_COMPARE_FMT:format(numAvailable, numItems));
	end

	self:UpdateImportButton();
	self:MarkDirty();

	-- If we got new content data for the blueprint the List frame is also showing, make sure it gets updated too
	if HousingBlueprintContentListFrame:IsShown() and HousingBlueprintContentListFrame:IsShowingBlueprintForTarget(self.blueprintContentInfo.shareCode, self.blueprintContentInfo.targetHouseGUID)  then
		HousingBlueprintContentListFrame:ShowBlueprintContents(self.blueprintContentInfo, self.isReadonly);
	end
end

function HousingBlueprintImportValidationContentMixin:UpdateBudget(budgetFrame, budgetCost, budgetAvailable, isInsufficient)
	if budgetCost > 0 then
		if not budgetAvailable then
			budgetFrame.Text:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_BUDGET_FMT:format(budgetCost));
		else
			budgetFrame.Text:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_BUDGET_COMPARE_FMT:format(budgetCost, budgetAvailable));
		end
		local textColor = isInsufficient and RED_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
		budgetFrame.Text:SetTextColor(textColor:GetRGB());
		budgetFrame:Show();
	else
		budgetFrame:Hide();
	end
end

function HousingBlueprintImportValidationContentMixin:UpdateWaitingState(isWaitingForContent, showLoadingState)
	self.isWaitingForContent = isWaitingForContent;
	self.showLoadingState = showLoadingState;
	self.LoadingSpinner:SetShown(self.showLoadingState);
	self.BudgetsContainer:SetShown(not self.showLoadingState);
	self.CountListContainer:SetShown(not self.showLoadingState);
	self.BudgetBackground:SetShown(not self.showLoadingState);
	self:UpdateImportButton();
end

function HousingBlueprintImportValidationContentMixin:UpdateImportButton()
	local canImport, disabledText = self:CanImport();
	self.ImportButton:SetEnabled(canImport);

	if not canImport and self.isReadonly then
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
	elseif canImport and self.blueprintContentInfo and FlagsUtil.IsAnythingSet(self.blueprintContentInfo.unmetRequirementFlags) then
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


HousingBlueprintBudgetMixin = {};

function HousingBlueprintBudgetMixin:OnLoad()
	self.Icon:SetAtlas(self.icon);
end

function HousingBlueprintBudgetMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
	GameTooltip_AddHighlightLine(GameTooltip, self.tooltipText);
	GameTooltip:Show();
end

function HousingBlueprintBudgetMixin:OnLeave()
	GameTooltip:Hide();
end


----------------- Import-in-Progress Loading Visuals -----------------
-- TODO: Replace and/or modify all of this based on final loading visuals once we have an idea how visually-intensive or time-consuming imports end up being
local ImportLoadingWhileShownEvents = {
	"HOUSING_BLUEPRINT_IMPORT_FAILURE",
	"HOUSING_BLUEPRINT_IMPORT_SUCCESS",
};

HousingBlueprintImportLoadingFrameMixin = {};

function HousingBlueprintImportLoadingFrameMixin:OnLoad()
	FrameUtil.RegisterForTopLevelParentChanged(self);
end

function HousingBlueprintImportLoadingFrameMixin:OnEvent(event, ...)
	if event == "HOUSING_BLUEPRINT_IMPORT_SUCCESS" then
		self:OnImportSuccess();
	elseif event == "HOUSING_BLUEPRINT_IMPORT_FAILURE" then
		local result = ...;
		self:OnImportFailure(result);
	end
end

function HousingBlueprintImportLoadingFrameMixin:OnImportStarting()
	self:Show();
end

function HousingBlueprintImportLoadingFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ImportLoadingWhileShownEvents);
end

function HousingBlueprintImportLoadingFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ImportLoadingWhileShownEvents);
end

function HousingBlueprintImportLoadingFrameMixin:OnImportSuccess(shareCode)
	self:Hide();
end

function HousingBlueprintImportLoadingFrameMixin:OnImportFailure(result)
	local errorText = HousingResultToErrorText[result] or ERR_HOUSING_RESULT_BLUEPRINT_GENERIC_IMPORT_ERROR;
	UIErrorsFrame:AddExternalErrorMessage(HOUSING_BLUEPRINT_IMPORT_ERROR_FMT:format(errorText));
	self:Hide();
end
