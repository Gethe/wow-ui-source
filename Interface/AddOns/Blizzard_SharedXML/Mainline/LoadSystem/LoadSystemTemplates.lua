
DropDownLoadSystemMixin = {};

function DropDownLoadSystemMixin:OnLoad()
	self.DropDownControl:SetOptionSelectedCallback(GenerateClosure(DropDownLoadSystemMixin.OnDropDownIDSelected, self));
	self.DropDownControl:SetDropDownTextFontObject(self.dropDownSelectionFont);
	self.DropDownControl:AdjustTextPointsOffset(0, -1);

	self.selectionIDToSentinelKey = {};
	self.sentinelKeyToInfo = {};
end

function DropDownLoadSystemMixin:GetDropDownControl()
	return self.DropDownControl;
end

function DropDownLoadSystemMixin:OnDropDownIDSelected(selectionID, isUserInput)
	if not isUserInput then
		return;
	end

	local sentinelkey, sentinelInfo = self:GetSentinelKeyInfoFromSelectionID(selectionID);
	if sentinelInfo then
		local callback = sentinelInfo.callback;
		if callback then
			local newSelectionID = callback(self:GetSelectionIDForUtility(), self) or self:GetDefaultSelectionID();

			-- Updating the drop down here is not considered user input, or this would be infinite.
			local dropDownIsUserInput = false;
			self.DropDownControl:SetSelectedValue(newSelectionID, dropDownIsUserInput);
			return;
		end
	end

	self:SetSelectionID(selectionID, isUserInput);
end

function DropDownLoadSystemMixin:SetSelectionID(selectionID, isUserInput)
	self:SetSelectionIDInternal(selectionID, isUserInput);
end

function DropDownLoadSystemMixin:ClearSelection()
	-- Clearing the selection should never be a user action.
	local isUserInput = false;
	self.DropDownControl:SetSelectedValue(nil, isUserInput);
end

function DropDownLoadSystemMixin:SetSelectionIDInternal(selectionID, isUserInput)
	local sentinelKey = self.selectionIDToSentinelKey[selectionID];
	if sentinelKey or not self:IsSelectionIDValid(selectionID) then
		return;
	end

	-- Updating the drop down here is not considered user input, or this would be infinite.
	local dropDownIsUserInput = false;
	self.DropDownControl:SetSelectedValue(selectionID, dropDownIsUserInput);

	self.lastValidSelectionID = selectionID;

	if self.loadCallback then
		self.loadCallback(selectionID, isUserInput);
	end
end

function DropDownLoadSystemMixin:UpdateSelectionOptions()
	local options = {};
	for i, selectionID in ipairs(self.possibleSelections) do
		local option = {};
		option.value = selectionID;

		local sentinelkey, sentinelInfo = self:GetSentinelKeyInfoFromSelectionID(selectionID);
		if sentinelInfo then
			option.text = sentinelInfo.text;
		else
			option.text = self.nameTranslation(selectionID);

			if self.tooltipTranslation then
				option.tooltipOnButton = true;
				option.tooltipTitle = self.tooltipTranslation(selectionID);
			end
		end

		table.insert(options, option);
	end

	local selectionSentinelID = 0;
	local sentinelKeyToIndex = {};
	for i, selectionID in ipairs(self.possibleSelections) do
		local sentinelKey = self.selectionIDToSentinelKey[selectionID];
		if sentinelKey then
			sentinelKeyToIndex[sentinelKey] = i;
		end

		if selectionID >= selectionSentinelID then
			selectionSentinelID = selectionID * 150;
		end
	end

	for sentinelKey, info in pairs(self.sentinelKeyToInfo) do
		local sentinelIndex = sentinelKeyToIndex[sentinelKey];
		if not sentinelIndex then
			self.selectionIDToSentinelKey[selectionSentinelID] = sentinelKey;

			local option = {};
			option.value = selectionSentinelID;
			option.text = info.text;

			if info.isInSubDropDown then
				option.level = 2;
			end

			table.insert(options, option);

			selectionSentinelID = selectionSentinelID + 1;
		else
			local optionInfo = options[sentinelIndex];
			if optionInfo.value <= selectionSentinelID then
				self.selectionIDToSentinelKey[selectionSentinelID] = sentinelKey;
				optionInfo.value = selectionSentinelID;
				selectionSentinelID = selectionSentinelID + 1;
			end
		end
	end

	local function CustomSetupFunction(dropDownButtonInfo, standardFunc)
		local originalFunc = standardFunc;
		local originalDropDownButtonInfo = nil;

		local sentinelkey, sentinelInfo = self:GetSentinelKeyInfoFromSelectionID(dropDownButtonInfo.value);
		if sentinelInfo and sentinelInfo.isList then
			originalDropDownButtonInfo = CopyTable(dropDownButtonInfo);
		end

		dropDownButtonInfo.fontObject = self.dropDownOptionFont;
		dropDownButtonInfo.tooltipBackdropStyle = self.dropdownTooltipBackdropStyle;
		dropDownButtonInfo.iconTooltipBackdropStyle = self.dropdownTooltipBackdropStyle;
		dropDownButtonInfo.topPadding = 2;

		local hasRightClickCallback = (self.rightClickCallback ~= nil);
		dropDownButtonInfo.registerForRightClick = hasRightClickCallback;
		if hasRightClickCallback then
			standardFunc = function (button, arg1, arg2, checked, mouseButton)
				if mouseButton == "RightButton" then
					local shouldCallDefault = self.rightClickCallback(dropDownButtonInfo.value);
					if shouldCallDefault and originalFunc then
						originalFunc(button, arg1, arg2, checked, mouseButton);
					end
				elseif originalFunc then
					originalFunc(button, arg1, arg2, checked, mouseButton);
				end
			end;

			dropDownButtonInfo.func = standardFunc;
		end

		if sentinelInfo then
			dropDownButtonInfo.colorCode = sentinelInfo.colorCode;
			dropDownButtonInfo.tooltipText = sentinelInfo.tooltipText;
			dropDownButtonInfo.tooltipTitle = sentinelInfo.tooltipTitle;
			dropDownButtonInfo.tooltipWarning = sentinelInfo.tooltipWarning;
			dropDownButtonInfo.tooltipWhileDisabled = sentinelInfo.tooltipWhileDisabled;
			dropDownButtonInfo.tooltipOnButton = sentinelInfo.tooltipOnButton;
			dropDownButtonInfo.noTooltipWhileEnabled = sentinelInfo.noTooltipWhileEnabled;

			if sentinelInfo.disabledCallback then
				local disabled, disabledTooltipTitle, disabledTooltipText, disabledTooltipWarning = sentinelInfo.disabledCallback();
				dropDownButtonInfo.disabled = disabled;

				if dropDownButtonInfo.disabled then
					dropDownButtonInfo.tooltipTitle = disabledTooltipTitle;
					dropDownButtonInfo.tooltipText = disabledTooltipText;
					dropDownButtonInfo.tooltipWarning = disabledTooltipWarning;
					dropDownButtonInfo.tooltipWhileDisabled = true;
					dropDownButtonInfo.tooltipOnButton = true;
					dropDownButtonInfo.noTooltipWhileEnabled = true;
				end
			end

			if sentinelInfo.icon then
				dropDownButtonInfo.customCheckIconAtlas = sentinelInfo.icon;
			else
				dropDownButtonInfo.notCheckable = true;
				dropDownButtonInfo.leftPadding = 6;
			end

			if sentinelInfo.isList then
				dropDownButtonInfo.func = nop;
				dropDownButtonInfo.ignoreAsMenuSelection = true;
				dropDownButtonInfo.hasArrow = true;
				dropDownButtonInfo.arrowXOffset = -10;
				dropDownButtonInfo.menuListDisplayMode = "MENU";
				dropDownButtonInfo.menuList = {};

				for i, sentinelKeyInfo in ipairs(sentinelInfo.sentinelKeyInfos) do
					local subDropDownInfo = CopyTable(originalDropDownButtonInfo);
					subDropDownInfo.value = sentinelKeyInfo.value;
					subDropDownInfo.level = dropDownButtonInfo.level + 1;

					CustomSetupFunction(subDropDownInfo, originalFunc);
					table.insert(dropDownButtonInfo.menuList, subDropDownInfo);
				end
			end
		else
			dropDownButtonInfo.colorCode = self.dropDownOptionColorCode;
			dropDownButtonInfo.notCheckable = true;
			dropDownButtonInfo.leftPadding = 6;

			if self.editEntryCallback and (not self.canEditCallback or self.canEditCallback(dropDownButtonInfo.value)) then
				dropDownButtonInfo.iconXOffset = -10;
				dropDownButtonInfo.mouseOverIcon = [[Interface\WorldMap\GEAR_64GREY]];
				dropDownButtonInfo.iconTooltipTitle = self.editEntryTooltip;
				dropDownButtonInfo.func = function(button, ...)
					local gearIcon = button.Icon;
					if button.mouseOverIcon and gearIcon:IsMouseOver() then
						self.editEntryCallback(dropDownButtonInfo.value);
					elseif standardFunc then
						standardFunc(button, ...);
					end
				end
			end

			if dropDownButtonInfo.value == self:GetSelectionID() then
				dropDownButtonInfo.text = dropDownButtonInfo.text..CreateSimpleTextureMarkup([[Interface\Buttons\UI-CheckBox-Check]], 20, 20);
			end
		end
	end

	self.DropDownControl:SetCustomSetup(CustomSetupFunction);
	self.DropDownControl:SetOptions(options);
end

function DropDownLoadSystemMixin:SetSelectionOptions(possibleSelections, nameTranslation, dropDownOptionColor, tooltipTranslation)
	self.possibleSelections = CopyTable(possibleSelections);
	self.nameTranslation = nameTranslation;
	self.tooltipTranslation = tooltipTranslation;
	self.dropDownOptionColorCode = dropDownOptionColor and dropDownOptionColor:GenerateHexColorMarkup() or nil;

	self:UpdateSelectionOptions();
end

function DropDownLoadSystemMixin:CreateAndSelectNewEntry(newEntryCallback, entryName)
	local newEntryID = newEntryCallback(entryName);

	if newEntryID then
		table.insert(self.possibleSelections, newEntryID);

		self:UpdateSelectionOptions();

		local isUserInput = true;
		self:SetSelectionID(newEntryID, isUserInput);
	end

	return newEntryID;
end

-- loadCallback: loads an entry by selectionID. (selectionID) -> nil
function DropDownLoadSystemMixin:SetLoadCallback(loadCallback)
	self.loadCallback = loadCallback;
end

-- rightClickCallback: handle a right-click in the dropdown. Returns whether or not to call the standard loadCallback. (selectionID) -> shouldCallLoad
-- Note: commonly used for deletion.
function DropDownLoadSystemMixin:SetRightClickCallback(rightClickCallback)
	self.rightClickCallback = rightClickCallback;
end

-- enabledCallback: called before a selection is allowed (in case enabled state changed while the dropdown list is open). ([selectionID]) -> shouldBeEnabled
function DropDownLoadSystemMixin:SetEnabledCallback(enabledCallback)
	self.DropDownControl:SetEnabledCallback(enabledCallback);
end

-- sentinelKeyInfo keys:
-- .callback: The previous selectionID is passed in along with the load system. Optionally returns the next selectionID that should be set.
-- 				(selectionID, loadSystem) -> [optional newSelectionID]
-- .text: The dropdown text for this special selection option.
-- .icon: An optional icon used for this special selection option.
-- .disabledCallback: Should return whether selection is disabled and tooltip content to show if it is.
--						() => [isDisabled, tooltipTitle, tooltipText, tooltipWarning]
function DropDownLoadSystemMixin:AddSentinelValue(sentinelKeyInfo)
	local sentinelKey = self:GetNextSentinelKey();
	self.sentinelKeyToInfo[sentinelKey] = sentinelKeyInfo;

	self:UpdateSelectionOptions();
end

-- sentinelKeyInfo keys:
-- .sentinelKeyInfos: A list of sentinelKeyInfo structs as defined above.
-- .text: The dropdown text for this special selection option.
-- .icon: An optional icon used for this special selection option.
-- .disabledCallback: Should return whether selection is disabled and tooltip content to show if it is.
--						() => [isDisabled, tooltipTitle, tooltipText, tooltipWarning]
function DropDownLoadSystemMixin:AddSentinelSubDropDown(sentinelListInfo)
	sentinelListInfo.isList = true;

	local sentinelKey = self:GetNextSentinelKey();
	self.sentinelKeyToInfo[sentinelKey] = sentinelListInfo;

	for i, sentinelKeyInfo in ipairs(sentinelListInfo.sentinelKeyInfos) do
		sentinelKeyInfo.isInSubDropDown = true;

		local subSentinelKey = self:GetNextSentinelKey();
		self.sentinelKeyToInfo[subSentinelKey] = sentinelKeyInfo;
	end

	self:UpdateSelectionOptions();
end

-- newEntryCallback(newEntryName)
-- popupText: Text to display on a generic name input box popup
-- disabledCallback: Should return whether new entry creation is disabled and tooltip content to show if it is.
--						() => [isDisabled, tooltipTitle, tooltipText, tooltipWarning]
-- Create a fresh entry with a new name.
function DropDownLoadSystemMixin:SetNewEntryCallback(newEntryCallback, optionText, popupText, disabledCallback)
	local function ShowGenericPopup(acceptCallback)
		local popupInfo = {
			text = popupText,
			callback = acceptCallback,
			acceptText = ACCEPT,
		};

		StaticPopup_ShowCustomGenericInputBox(popupInfo);
	end

	self:SetNewEntryCallbackInternal(newEntryCallback, optionText, disabledCallback, ShowGenericPopup);
end

-- newEntryCallback(newEntryName)
-- customPopup: Custom popup for inputting the new entry name
-- disabledCallback: Should return whether new entry creation is disabled and tooltip content to show if it is.
--						() => [isDisabled, tooltipTitle, tooltipText, tooltipWarning]
-- Create a fresh entry with a new name.
function DropDownLoadSystemMixin:SetNewEntryCallbackCustomPopup(newEntryCallback, optionText, customPopup, disabledCallback)
	local function ShowCustomPopup(acceptCallback)
		customPopup:ShowDialog(acceptCallback);
	end

	self:SetNewEntryCallbackInternal(newEntryCallback, optionText, disabledCallback, ShowCustomPopup);
end

function DropDownLoadSystemMixin:SetNewEntryCallbackInternal(newEntryCallback, optionText, disabledCallback, showPopupFunc)
	local function NewEntrySentinelCallback(selectionID, loadSystem)
		local function LoadSystemNewEntry(entryName)
			if entryName ~= "" then
				self:CreateAndSelectNewEntry(newEntryCallback, entryName);
			end
		end

		showPopupFunc(LoadSystemNewEntry);
		return nil;
	end

	local sentinelInfo = {
		text = optionText,
		colorCode = GREEN_FONT_COLOR_CODE,
		icon = "communities-icon-addchannelplus",
		callback = NewEntrySentinelCallback,
		disabledCallback = disabledCallback,
	};

	self:AddSentinelValue(sentinelInfo);
end

-- editEntryCallback(selectionID): If this callback is set, a gear icon is displayed in the dropdown that can be clicked to edit the entry.
-- editEntryTooltip: If set, displays tooltip text when hoving over the gear icon.
-- canEditCallback(selectionID): If set, is used to determine whether a specific selection can be edited
function DropDownLoadSystemMixin:SetEditEntryCallback(editEntryCallback, editEntryTooltip, canEditCallback)
	self.editEntryCallback = editEntryCallback;
	self.editEntryTooltip = editEntryTooltip;
	self.canEditCallback = canEditCallback;
	self:UpdateSelectionOptions();
end

function DropDownLoadSystemMixin:SetEnabledState(enabledState, disabledTooltip)
	self.DropDownControl:SetEnabled(enabledState, disabledTooltip);
end

function DropDownLoadSystemMixin:IsSelectionIDValid(selectionID)
	if self.possibleSelections == nil then
		return true;
	end

	return tContains(self.possibleSelections, selectionID);
end

function DropDownLoadSystemMixin:IsSelectionIDValidAndEnabled(selectionID, isUserInput)
	if self.possibleSelections == nil then
		return true;
	end

	if not tContains(self.possibleSelections, selectionID) then
		return false;
	end

	local dropdownEnabledCallback = self.DropDownControl:GetEnabledCallback();
	if dropdownEnabledCallback then
		return dropdownEnabledCallback(selectionID, isUserInput);
	end

	return true;
end

function DropDownLoadSystemMixin:GetSelectionIDForUtility()
	return self.lastValidSelectionID;
end

function DropDownLoadSystemMixin:GetSelectionID()
	return self.DropDownControl:GetSelectedValue();
end

function DropDownLoadSystemMixin:GetSelectedValueIndex()
	return self.DropDownControl:GetSelectedValueIndex();
end

function DropDownLoadSystemMixin:GetDefaultSelectionID()
	local isUserInput = false; -- Switching to a default selectionID should not be a user input

	if self.lastValidSelectionID and self:IsSelectionIDValidAndEnabled(self.lastValidSelectionID, isUserInput) then
		return self.lastValidSelectionID;
	end

	if self.initialSelectionID and self:IsSelectionIDValidAndEnabled(self.initialSelectionID, isUserInput) then
		return self.initialSelectionID;
	end

	if self.possibleSelections and self:IsSelectionIDValidAndEnabled(self.possibleSelections[1], isUserInput) then
		return self.possibleSelections[1];
	end

	return nil;
end

function DropDownLoadSystemMixin:GetNextSentinelKey()
	local maxSentinelKey = 0;
	for sentinelKey, sentinelInfo in pairs(self.sentinelKeyToInfo) do
		maxSentinelKey = math.max(maxSentinelKey, sentinelKey);
	end

	return maxSentinelKey + 1;
end

function DropDownLoadSystemMixin:GetSentinelKeyInfoFromSelectionID(selectionID)
	local sentinelkey = self.selectionIDToSentinelKey[selectionID];
	local sentinelInfo = sentinelkey and self.sentinelKeyToInfo[sentinelkey] or nil;
	return sentinelkey, sentinelInfo;
end
