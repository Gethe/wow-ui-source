
DropDownLoadSystemMixin = {};

function DropDownLoadSystemMixin:OnLoad()
	self.DropDownControl:SetOptionSelectedCallback(GenerateClosure(DropDownLoadSystemMixin.OnDropDownIDSelected, self));
	self.DropDownControl:SetDropDownTextFontObject("GameFontHighlight");
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
		dropDownButtonInfo.fontObject = "GameFontNormal";
		dropDownButtonInfo.topPadding = 2;

		local sentinelkey, sentinelInfo = self:GetSentinelKeyInfoFromSelectionID(dropDownButtonInfo.value);
		if sentinelInfo then
			dropDownButtonInfo.customCheckIconAtlas = sentinelInfo.icon;
		else
			dropDownButtonInfo.colorCode = self.dropDownOptionColorCode;
			dropDownButtonInfo.notCheckable = true;
			dropDownButtonInfo.leftPadding = 6;

			if self.editEntryCallback then
				dropDownButtonInfo.iconXOffset = -10;
				dropDownButtonInfo.mouseOverIcon = [[Interface\WorldMap\GEAR_64GREY]];
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

function DropDownLoadSystemMixin:SetSelectionOptions(possibleSelections, nameTranslation, dropDownOptionColor)
	self.possibleSelections = CopyTable(possibleSelections);
	self.nameTranslation = nameTranslation;
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

function DropDownLoadSystemMixin:SetEnabledCallback(enabledCallback)
	self.DropDownControl:SetEnabledCallback(enabledCallback);
end

-- sentinelKeyInfo keys:
-- .callback: The previous selectionID is passed in along with the load system. Optionally returns the next selectionID that should be set.
-- 				(selectionID, loadSystem) -> [optional newSelectionID]
-- .text: The dropdown text for this special selection option.
-- .icon: An optional icon used for this special selection option.
function DropDownLoadSystemMixin:AddSentinelValue(sentinelKeyInfo)
	local sentinelKey = self:GetNextSentinelKey();
	self.sentinelKeyToInfo[sentinelKey] = sentinelKeyInfo;
	self:UpdateSelectionOptions();
end

-- newEntryCallback(newEntryName)
-- Create a fresh entry with a new name.
function DropDownLoadSystemMixin:SetNewEntryCallback(newEntryCallback, optionText, popupText)
	local function NewEntrySentinelCallback(selectionID, loadSystem)
		local function LoadSystemNewEntry(entryName)
			if entryName ~= "" then
				self:CreateAndSelectNewEntry(newEntryCallback, entryName);
			end
		end

		local popupInfo = {
			text = popupText,
			callback = LoadSystemNewEntry,
			acceptText = ACCEPT,
		};

		StaticPopup_ShowCustomGenericInputBox(popupInfo);
		return nil;
	end

	local sentinelInfo = {
		text = GREEN_FONT_COLOR:WrapTextInColorCode(optionText),
		icon = "communities-icon-addchannelplus",
		callback = NewEntrySentinelCallback,
	};

	self:AddSentinelValue(sentinelInfo);
end

-- editEntryCallback(selectionID)
-- If this callback is set, a gear icon is displayed in the dropdown that can be clicked to edit the entry.
function DropDownLoadSystemMixin:SetEditEntryCallback(editEntryCallback)
	self.editEntryCallback = editEntryCallback;
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

function DropDownLoadSystemMixin:GetSelectionIDForUtility()
	return self.lastValidSelectionID;
end

function DropDownLoadSystemMixin:GetSelectionID()
	return self.DropDownControl:GetSelectedValue();
end

function DropDownLoadSystemMixin:GetDefaultSelectionID()
	local lastValidSelectionID = self.lastValidSelectionID;
	if lastValidSelectionID and self:IsSelectionIDValid(lastValidSelectionID) then
		return lastValidSelectionID;
	end

	if self.initialSelectionID then
		return self.initialSelectionID;
	end

	if self.possibleSelections then
		return self.possibleSelections[1];
	end

	return 1;
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
