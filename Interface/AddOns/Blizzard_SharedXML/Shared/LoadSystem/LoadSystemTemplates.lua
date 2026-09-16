DropdownLoadSystemMixin = {};

function DropdownLoadSystemMixin:OnLoad()
	self.sentinelInfos = {};
end

function DropdownLoadSystemMixin:SetDropdownDefaultText(defaultText)
	self.dropdownDefaultText = defaultText;
end

function DropdownLoadSystemMixin:GetDropdown()
	return self.Dropdown;
end

function DropdownLoadSystemMixin:SetSelectionID(selectionID, isUserInput)
	self.lastValidSelectionID = selectionID;
	self:SetSelectionIDInternal(selectionID);

	if self.loadCallback then
		self.loadCallback(selectionID, isUserInput);
	end
end

function DropdownLoadSystemMixin:GetSelectionID()
	return self.selectionID;
end

function DropdownLoadSystemMixin:SetSelectionIDInternal(selectionID)
	self.selectionID = selectionID;
	self.Dropdown:Update();
end

function DropdownLoadSystemMixin:ClearSelection()
	self:SetSelectionIDInternal(nil);
end

function DropdownLoadSystemMixin:SetMenuTag(menuTag)
	self.menuTag = menuTag;
end

function DropdownLoadSystemMixin:UpdateSelectionOptions()
	self.Dropdown:SetDefaultText(self.dropdownDefaultText);
	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		if self.menuTag then
			rootDescription:SetTag(self.menuTag);
		end

		do
			local function IsSelected(selectionID)
				return self:GetSelectionID() == selectionID;
			end

			local function SetSelected(selectionID)
				local isUserInput = true;
				self:SetSelectionID(selectionID, isUserInput);
			end

			for index, selectionID in ipairs(self.possibleSelections) do
				local text = self.nameTranslation(selectionID);
				local desc = rootDescription:CreateRadio(text, IsSelected, SetSelected, selectionID);

				desc:AddInitializer(function(button, description, menu)
					-- Radio textures are hidden and the text is positioned in their place.
					button.leftTexture1:Hide();
					if button.leftTexture2 then
						button.leftTexture2:Hide();
					end
					
					button.fontString:SetHeight(16);
					button.fontString:SetPoint("LEFT", button.leftTexture1, "LEFT");
					button.fontString:SetTextColor(self.selectionColor:GetRGBA());

					--[[
					The check is separated from the text so that it doesn't appear in the dropdown's
					current selection.
					]]--
					if self:GetSelectionID() == selectionID then
						local fontString2 = button:AttachFontString();
						fontString2:SetPoint("LEFT", button.fontString, "RIGHT");
						fontString2:SetHeight(16);

						local size = 20;
						fontString2:SetTextToFit(CreateSimpleTextureMarkup([[Interface\Buttons\UI-CheckBox-Check]], size, size));
					end

					if self.editEntryCallback and (not self.canEditCallback or self.canEditCallback(selectionID)) then
						local gearButton = MenuTemplates.AttachAutoHideGearButton(button);
						gearButton:SetPoint("RIGHT");
						gearButton:SetScript("OnClick", function()
							self.editEntryCallback(selectionID);
							menu:Close();
						end);

						if self.editEntryTooltip then
							MenuUtil.HookTooltipScripts(gearButton, function(tooltip)
								GameTooltip_SetTitle(tooltip, self.editEntryTooltip);
							end);
						end
					end
				end);
				
				if self.selectionEnabledCallback then
					desc:SetEnabled(function(description)
						local isUserInput = true;
						return self.selectionEnabledCallback(selectionID, isUserInput);
					end);
				end

				if self.tooltipTranslation then
					desc:SetTooltip(function(tooltip, description)
						GameTooltip_SetTitle(tooltip, self.tooltipTranslation(selectionID));
					end);
				end
			end
		end

		for _, sentinelInfo in pairs(self.sentinelInfos) do
			if sentinelInfo.sentinelInfos then
				local submenu = rootDescription:CreateButton(sentinelInfo.text);
				for i, sentinelSubInfo in ipairs(sentinelInfo.sentinelInfos) do
					submenu:CreateButton(sentinelSubInfo.text, sentinelSubInfo.callback);
				end
			else
				local disabledCallback = sentinelInfo.disabledCallback;
				local text = sentinelInfo.text;
				local color = sentinelInfo.color or HIGHLIGHT_FONT_COLOR;
				local icon = sentinelInfo.icon;

				local function Responder()
					local callback = sentinelInfo.callback;
					local callbackSelectionID = callback(self:GetLastValidSelectionID(), self);
					local newSelectionID = callbackSelectionID or self:GetDefaultSelectionID();
					if newSelectionID ~= nil then
						self:SetSelectionIDInternal(newSelectionID);
					end
				end

				local desc;
				if icon then
					desc = rootDescription:CreateButton(text, Responder);
					desc:AddInitializer(function(button, description, menu)
						local texture = button:AttachTexture();
						texture:SetSize(16,16);
						texture:SetPoint("LEFT");
						texture:SetAtlas(icon);

						local fontString = button.fontString;
						fontString:SetPoint("LEFT", texture, "RIGHT", 3, 0);
						fontString:SetTextColor(color:GetRGBA());
					end);
				else
					desc = rootDescription:CreateButton(text, Responder);
					desc:AddInitializer(function(button, description, menu)
						button.fontString:SetTextColor(color:GetRGBA());
					end);
				end

				desc:SetEnabled(function(description)
					return not (disabledCallback and disabledCallback());
				end);

				if disabledCallback then
					desc:SetTooltip(function(tooltip, description)
						local disabled, disabledTooltipTitle, disabledTooltipText, disabledTooltipWarning = disabledCallback();
						if disabled and (disabledTooltipTitle or disabledTooltipText or disabledTooltipWarning) then
							if disabledTooltipTitle then
								GameTooltip_SetTitle(tooltip, disabledTooltipTitle);
							end
							if disabledTooltipText then
								GameTooltip_AddNormalLine(tooltip, disabledTooltipText);
							end
							if disabledTooltipWarning then
								GameTooltip_AddColoredLine(tooltip, disabledTooltipWarning, RED_FONT_COLOR);
							end
						end
					end);
				end
			end
		end
	end);
end

function DropdownLoadSystemMixin:SetSelectionOptions(possibleSelections, nameTranslation, selectionColor, tooltipTranslation)
	self.possibleSelections = CopyTable(possibleSelections);
	self.nameTranslation = nameTranslation;
	self.tooltipTranslation = tooltipTranslation;
	self.selectionColor = selectionColor or HIGHLIGHT_FONT_COLOR;

	self:UpdateSelectionOptions();
end

function DropdownLoadSystemMixin:CreateAndSelectNewEntry(newEntryCallback, entryName)
	local newEntryID = newEntryCallback(entryName);
	if newEntryID then
		table.insert(self.possibleSelections, newEntryID);

		local isUserInput = true;
		self:SetSelectionID(newEntryID, isUserInput);

		self:UpdateSelectionOptions();
	end

	return newEntryID;
end

-- loadCallback: loads an entry by selectionID. (selectionID) -> nil
function DropdownLoadSystemMixin:SetSelectionEnabled(selectionEnabledCallback)
	self.selectionEnabledCallback = selectionEnabledCallback;
end

-- loadCallback: loads an entry by selectionID. (selectionID) -> nil
function DropdownLoadSystemMixin:SetLoadCallback(loadCallback)
	self.loadCallback = loadCallback;
end

-- sentinelInfo keys:
-- .callback: The previous selectionID is passed in along with the load system. Optionally returns the next selectionID that should be set.
-- 				(selectionID, loadSystem) -> [optional newSelectionID]
-- .text: The dropdown text for this special selection option.
-- .icon: An optional icon used for this special selection option.
-- .disabledCallback: Should return whether selection is disabled and tooltip content to show if it is.
--						() => [isDisabled, tooltipTitle, tooltipText, tooltipWarning]
function DropdownLoadSystemMixin:AddSentinelValue(sentinelInfo)
	table.insert(self.sentinelInfos, sentinelInfo);
	self:UpdateSelectionOptions();
end

-- newEntryCallback(newEntryName)
-- popupText: Text to display on a generic name input box popup
-- disabledCallback: Should return whether new entry creation is disabled and tooltip content to show if it is.
--						() => [isDisabled, tooltipTitle, tooltipText, tooltipWarning]
-- Create a fresh entry with a new name.
function DropdownLoadSystemMixin:SetNewEntryCallback(newEntryCallback, optionText, popupText, disabledCallback)
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
function DropdownLoadSystemMixin:SetNewEntryCallbackCustomPopup(newEntryCallback, optionText, customPopup, disabledCallback)
	local function ShowCustomPopup(acceptCallback)
		customPopup:ShowDialog(acceptCallback);
	end

	self:SetNewEntryCallbackInternal(newEntryCallback, optionText, disabledCallback, ShowCustomPopup);
end

function DropdownLoadSystemMixin:SetNewEntryCallbackInternal(newEntryCallback, optionText, disabledCallback, showPopupFunc)
	local function CreateNewEntry(selectionID, loadSystem)
		local function OnAccept(entryName)
			if entryName ~= "" then
				self:CreateAndSelectNewEntry(newEntryCallback, entryName);
			end
		end

		showPopupFunc(OnAccept);
		return nil;
	end

	local sentinelInfo = {
		text = optionText,
		color = GREEN_FONT_COLOR,
		icon = "communities-icon-addchannelplus",
		callback = CreateNewEntry,
		disabledCallback = disabledCallback,
	};

	self:AddSentinelValue(sentinelInfo);
end

-- editEntryCallback(selectionID): If this callback is set, a gear icon is displayed in the dropdown that can be clicked to edit the entry.
-- editEntryTooltip: If set, displays tooltip text when hoving over the gear icon.
-- canEditCallback(selectionID): If set, is used to determine whether a specific selection can be edited
function DropdownLoadSystemMixin:SetEditEntryCallback(editEntryCallback, editEntryTooltip, canEditCallback)
	self.editEntryCallback = editEntryCallback;
	self.editEntryTooltip = editEntryTooltip;
	self.canEditCallback = canEditCallback;
	self:UpdateSelectionOptions();
end

function DropdownLoadSystemMixin:SetEnabledState(enabledState)
	self.Dropdown:SetEnabled(enabledState);
end

function DropdownLoadSystemMixin:IsSelectionIDValid(selectionID)
	if self.possibleSelections == nil then
		return true;
	end

	return tContains(self.possibleSelections, selectionID);
end

function DropdownLoadSystemMixin:IsSelectionIDValidAndEnabled(selectionID)
	if self.possibleSelections == nil then
		return true;
	end

	if not tContains(self.possibleSelections, selectionID) then
		return false;
	end

	if self.selectionEnabledCallback then
		local isUserInput = false;
		if not self.selectionEnabledCallback(selectionID, isUserInput) then
			return false;
		end
	end

	return true;
end

function DropdownLoadSystemMixin:GetLastValidSelectionID()
	return self.lastValidSelectionID;
end

function DropdownLoadSystemMixin:GetDefaultSelectionID()
	if self.lastValidSelectionID and self:IsSelectionIDValidAndEnabled(self.lastValidSelectionID) then
		return self.lastValidSelectionID;
	end

	if self.possibleSelections and self:IsSelectionIDValidAndEnabled(self.possibleSelections[1]) then
		return self.possibleSelections[1];
	end

	return nil;
end