HousingBlueprintUtils = {};

-- expected params options: shouldShowImport, onDeleteConfirm, onStateChange, onMenuOpenChanged
function HousingBlueprintUtils.CreateBlueprintInfoContextMenu(rootDescription, blueprintInfo, params)
	if not blueprintInfo then
		return;
	end
	rootDescription:SetTag("MENU_HOUSING_BLUEPRINT_ENTRY");
	
	rootDescription:AddMenuAcquiredCallback(function(menuFrame)
		if params.onMenuOpenChanged then
			params.onMenuOpenChanged(true);
		end
	end);
	rootDescription:AddMenuReleasedCallback(function(menuFrame, closeReason)
		if params.onMenuOpenChanged then
			params.onMenuOpenChanged(true);
		end
	end);

	if params.shouldShowImport then
		rootDescription:CreateButton(HOUSING_BLUEPRINT_COLLECTION_IMPORT, function()
			HousingFramesUtil.ShowBlueprintImport(blueprintInfo.shareCode);
		end);
	end

	if blueprintInfo.isAutoSave then
		rootDescription:CreateTitle(HOUSING_BLUEPRINT_COLLECTION_READONLY_BACKUP);
		return;			
	end

	rootDescription:CreateButton(HOUSING_BLUEPRINT_COLLECTION_COPY, function()
		CopyToClipboard(blueprintInfo.shareCode);
		ChatFrameUtil.DisplaySystemMessageInPrimary(HOUSING_BLUEPRINT_EXPORT_CLIPBOARD_CONFIRMATION);
	end);
	rootDescription:CreateButton(HOUSING_BLUEPRINT_COLLECTION_RENAME, function()
		HousingBlueprintRenameFrame:ShowForBlueprint(blueprintInfo);
	end);
	rootDescription:CreateButton(HOUSING_BLUEPRINT_COLLECTION_DELETE, function()
		local popupData = {
			shareCode = blueprintInfo.shareCode,
			onDeleteConfirmed = params.onDeleteConfirm,
			onClosed = params.onStateChange,
			confirmationString = HOUSING_BLUEPRINT_DELETE_CONFIRMATION_STRING,
		};
		StaticPopup_Show("CONFIRM_BLUEPRINT_DELETE", HOUSING_BLUEPRINT_DELETE_CONFIRMATION_STRING, nil, popupData);
		if params.onStateChange then
			params.onStateChange();
		end
	end);
end

----------------- Static Popups -----------------
StaticPopupDialogs["CONFIRM_BLUEPRINT_DELETE"] = {
	text = HOUSING_BLUEPRINT_DELETE_CONFIRMATION_TEXT,
	button1 = HOUSING_BLUEPRINT_DELETE_CONFIRM,
	button2 = CANCEL,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hasEditBox = 1,
	maxLetters = 32,
	selectCallbackByIndex = true,

	OnButton1 = function(self, data)
		-- Confirm
		data.onDeleteConfirmed();
		self:Hide();
	end,
	OnButton2 = function(self, data)
		-- Cancel
		if data.onClosed then
			data.onClosed();
		end
		self:Hide();
	end,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		dialog:GetEditBox():SetText("");
		if data.onClosed then
			data.onClosed();
		end
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		if dialog:GetButton1():IsEnabled() then
			data.onDeleteConfirmed();
			dialog:Hide();
		end
	end,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, data.confirmationString);
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
		if data.onClosed then
			data.onClosed();
		end
		ClearCursor();
	end
};
