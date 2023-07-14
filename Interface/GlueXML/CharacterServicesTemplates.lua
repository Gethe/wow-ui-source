-- NOTE: Not sure what to do about the realm selection stuff, lifing it from Store code for now.
-- Global state is annoying, sigh...
local VAS_AUTO_COMPLETE_MAX_ENTRIES = 10;
local VAS_AUTO_COMPLETE_OFFSET = 0;
local VAS_AUTO_COMPLETE_SELECTION = nil;
local VAS_AUTO_COMPLETE_ENTRIES = nil;

CharacterServicesAutoCompleteButtonMixin = {};

function CharacterServicesAutoCompleteButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local mode = self:GetMode();
	if mode == "select" then
		self:Select();
	elseif mode == "next" then
		self:Next();
	elseif mode == "previous" then
		self:Previous();
	else
		error("Mode not set");
	end
end

function CharacterServicesAutoCompleteButtonMixin:Select()
	VAS_AUTO_COMPLETE_SELECTION = nil;
	VAS_AUTO_COMPLETE_OFFSET = 0;

	self:GetParent():GetParent():SetText(self.info);
	self:GetParent():Hide();
end

function CharacterServicesAutoCompleteButtonMixin:Next()
	VAS_AUTO_COMPLETE_OFFSET = math.min(VAS_AUTO_COMPLETE_OFFSET + VAS_AUTO_COMPLETE_MAX_ENTRIES, #VAS_AUTO_COMPLETE_ENTRIES - 1);
	VAS_AUTO_COMPLETE_SELECTION = nil;
	self:GetParent():GetParent():UpdateAutoComplete();
end

function CharacterServicesAutoCompleteButtonMixin:Previous()
	VAS_AUTO_COMPLETE_OFFSET = math.max(VAS_AUTO_COMPLETE_OFFSET - VAS_AUTO_COMPLETE_MAX_ENTRIES, 0);
	VAS_AUTO_COMPLETE_SELECTION = nil;
	self:GetParent():GetParent():UpdateAutoComplete();
end

function CharacterServicesAutoCompleteButtonMixin:SetMode(mode)
	self.mode = mode;
end

function CharacterServicesAutoCompleteButtonMixin:GetMode()
	return self.mode;
end

CharacterServicesEditBoxBaseMixin = {};

function CharacterServicesEditBoxBaseMixin:OnEscapePressed()
	self:ClearFocus();
end

function CharacterServicesEditBoxBaseMixin:OnEditFocusLost()
	self:HighlightText(0, 0);
end

function CharacterServicesEditBoxBaseMixin:OnEditFocusGained()
	self:HighlightText();
end

AutoCompleteBoxMixin = {};

function AutoCompleteBoxMixin:OnShow()
	self:SetFrameLevel(self:GetParent():GetFrameLevel()+4);
end

function AutoCompleteBoxMixin:OnHide()
	VAS_AUTO_COMPLETE_OFFSET = 0;
	VAS_AUTO_COMPLETE_SELECTION = nil;
end

CharacterServicesEditBoxWithAutoCompleteMixin = {};

function CharacterServicesEditBoxWithAutoCompleteMixin:OnCursorChanged()
	VAS_AUTO_COMPLETE_OFFSET = 0;
	VAS_AUTO_COMPLETE_SELECTION = nil;

	self:UpdateAutoComplete();
end

function CharacterServicesEditBoxWithAutoCompleteMixin:OnTextChanged(userChanged)
	self:UpdateAutoComplete();
end

local function BuildRealmList(autocomplete)
	local currentRealmAddress = select(5, GetServerName());

	local realms = C_StoreSecure.GetVASRealmList();

	for index, realm in ipairs(realms) do
		if (realm.virtualRealmAddress ~= currentRealmAddress) then
			local name = realm.realmName;
			local listText = name;
			if realm.rp then
				listText = listText .. " " .. VAS_RP_PARENTHESES;
			end

			autocomplete:AddAutoCompleteEntry(name, listText, realm.virtualRealmAddress);
		end
	end
end

function CharacterServicesEditBoxWithAutoCompleteMixin:BuildAutoCompleteList()
	-- TODO: Make this configurable:
	self.listBuilder = BuildRealmList;

	if not self.autoCompleteList then
		self.listBuilder(self);
	end
end

function CharacterServicesEditBoxWithAutoCompleteMixin:AddAutoCompleteEntry(value, text, userData)
	if not self.autoCompleteList then
		self.autoCompleteList = {};
	end

	table.insert(self.autoCompleteList, { value = value, text = text, userData = userData });
end

function CharacterServicesEditBoxWithAutoCompleteMixin:GetAutoCompleteList()
	return self.autoCompleteList;
end

function CharacterServicesEditBoxWithAutoCompleteMixin:ClearAutoCompleteList()
	self.autoCompleteList = nil;
end

function CharacterServicesEditBoxWithAutoCompleteMixin:GetAutoCompleteUserDataForPredicate(predicate)
	local list = self:GetAutoCompleteList();
	if list then
		for index, entry in ipairs(list) do
			if predicate(entry) then
				return entry.userData;
			end
		end
	end

	return nil;
end

function CharacterServicesEditBoxWithAutoCompleteMixin:GetAutoCompleteUserDataForText(text)
	return self:GetAutoCompleteUserDataForPredicate(function(entry)
		return entry.text == text;
	end);
end

function CharacterServicesEditBoxWithAutoCompleteMixin:GetAutoCompleteUserDataForValue(value)
	return self:GetAutoCompleteUserDataForPredicate(function(entry)
		return entry.value == value;
	end);
end

function CharacterServicesEditBoxWithAutoCompleteMixin:GetAutoCompleteEntries(text, cursorPosition)
	local autoCompleteList = self:GetAutoCompleteList();
	if not autoCompleteList or #autoCompleteList == 0 or text == "" then
		-- So this is slightly different in Classic. They still show the full list if text is empty
		-- Mainline has far more realms so we probably want to keep the realm list empty in this case
		-- and continue to require the user start typing at least 1 character
		return {};
	end

	local entries = {};
	local str = string.lower(string.sub(text, 1, cursorPosition));
	local scrubbedString = string.gsub(str, "[%(%)%.%%%+%-%*%?%[%^%$]+", "");
	for _, info in ipairs(autoCompleteList) do
		if (string.find(string.lower(info.value), scrubbedString)) then
			table.insert(entries, info);
		end
	end

	return entries;
end

function CharacterServicesEditBoxWithAutoCompleteMixin:UpdateAutoComplete()
	self:BuildAutoCompleteList();

	local text = self:GetText();
	local cursorPosition = self:GetCursorPosition();

	VAS_AUTO_COMPLETE_ENTRIES = self:GetAutoCompleteEntries(text, cursorPosition);

	if (VAS_AUTO_COMPLETE_ENTRIES[1] and text == VAS_AUTO_COMPLETE_ENTRIES[1].value) then
		return;
	end

	local maxWidth = 0;
	local shownButtons = 0;
	local buttonOffset = 0;
	local box = self.AutoCompleteBox;
	if (VAS_AUTO_COMPLETE_OFFSET > 0) then
		local button = box.Buttons[1];
		button.Text:SetText(BLIZZARD_STORE_VAS_REALMS_PREVIOUS);
		button:SetNormalFontObject("GameFontDisableTiny2");
		button:SetHighlightFontObject("GameFontDisableTiny2");
		button:SetMode("previous");
		buttonOffset = 1;
		shownButtons = 1;
	end

	local hasMore = (#VAS_AUTO_COMPLETE_ENTRIES - VAS_AUTO_COMPLETE_OFFSET) > VAS_AUTO_COMPLETE_MAX_ENTRIES;
	for i = 1 + buttonOffset, math.min(VAS_AUTO_COMPLETE_MAX_ENTRIES, (#VAS_AUTO_COMPLETE_ENTRIES - VAS_AUTO_COMPLETE_OFFSET)) + buttonOffset do
		local button = box.Buttons[i];
		if (not button) then
			button = CreateForbiddenFrame("Button", nil, box, "CharacterServicesAutoCompleteButtonTemplate");
			button:SetPoint("TOP", box.Buttons[i-1], "BOTTOM");
		end
		local entryIndex = i + VAS_AUTO_COMPLETE_OFFSET - buttonOffset;
		button:SetMode("select");
		button.info = VAS_AUTO_COMPLETE_ENTRIES[entryIndex].value;
		button:SetNormalFontObject("GameFontWhiteTiny2");
		button:SetHighlightFontObject("GameFontWhiteTiny2");
		button.Text:SetText(VAS_AUTO_COMPLETE_ENTRIES[entryIndex].text);
		button:Show();
		if (i - buttonOffset == VAS_AUTO_COMPLETE_SELECTION) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
		shownButtons = shownButtons + 1;
	end

	if (hasMore) then
		local index = VAS_AUTO_COMPLETE_MAX_ENTRIES+1+buttonOffset;
		local button = box.Buttons[index];
		if (not button) then
			button = CreateForbiddenFrame("Button", nil, box, "CharacterServicesAutoCompleteButtonTemplate");
			button:SetPoint("TOP", box.Buttons[index-1], "BOTTOM");
		end
		button:SetMode("next");
		button:SetNormalFontObject("GameFontDisableTiny2");
		button:SetHighlightFontObject("GameFontDisableTiny2");
		button.Text:SetText(string.format(BLIZZARD_STORE_VAS_REALMS_AND_MORE, (#VAS_AUTO_COMPLETE_ENTRIES - VAS_AUTO_COMPLETE_OFFSET - VAS_AUTO_COMPLETE_MAX_ENTRIES)));
		button:Show();
		shownButtons = shownButtons + 1;
	end

	for i = shownButtons + 1, #box.Buttons do
		box.Buttons[i]:Hide();
	end

	if (#VAS_AUTO_COMPLETE_ENTRIES > 0) then
		box:SetHeight(22 + (shownButtons * box.Buttons[1]:GetHeight()));
		box:Show();
	else
		box:Hide();
	end
end

function CharacterServicesEditBoxWithAutoCompleteMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

function CharacterServicesEditBoxWithAutoCompleteMixin:OnShow()
	self:SetFrameLevel(self:GetParent():GetFrameLevel()+7);
end

function CharacterServicesEditBoxWithAutoCompleteMixin:IncrementSelection()
	if (VAS_AUTO_COMPLETE_OFFSET > 0 and VAS_AUTO_COMPLETE_SELECTION == #VAS_AUTO_COMPLETE_ENTRIES - VAS_AUTO_COMPLETE_OFFSET) then
		return;
	elseif (VAS_AUTO_COMPLETE_SELECTION == VAS_AUTO_COMPLETE_MAX_ENTRIES) then
		if (VAS_AUTO_COMPLETE_OFFSET + VAS_AUTO_COMPLETE_MAX_ENTRIES < #VAS_AUTO_COMPLETE_ENTRIES) then
			VAS_AUTO_COMPLETE_OFFSET = VAS_AUTO_COMPLETE_OFFSET + 1;
		end
	elseif (VAS_AUTO_COMPLETE_SELECTION and (VAS_AUTO_COMPLETE_SELECTION + VAS_AUTO_COMPLETE_OFFSET) < #VAS_AUTO_COMPLETE_ENTRIES) then
		VAS_AUTO_COMPLETE_SELECTION = VAS_AUTO_COMPLETE_SELECTION + 1;
	elseif (not VAS_AUTO_COMPLETE_SELECTION and #VAS_AUTO_COMPLETE_ENTRIES > 0) then
		VAS_AUTO_COMPLETE_SELECTION = 1;
	end

	self:UpdateAutoComplete();
end

function CharacterServicesEditBoxWithAutoCompleteMixin:DecrementSelection()
	if (VAS_AUTO_COMPLETE_SELECTION and #VAS_AUTO_COMPLETE_ENTRIES > 0) then
		if (VAS_AUTO_COMPLETE_SELECTION == 1 and VAS_AUTO_COMPLETE_OFFSET > 0) then
			VAS_AUTO_COMPLETE_OFFSET = VAS_AUTO_COMPLETE_OFFSET - 1;
		elseif (VAS_AUTO_COMPLETE_SELECTION > 1) then
			VAS_AUTO_COMPLETE_SELECTION = VAS_AUTO_COMPLETE_SELECTION - 1;
		end

		self:UpdateAutoComplete();
	end
end

function CharacterServicesEditBoxWithAutoCompleteMixin:EnterPressed()
	if (VAS_AUTO_COMPLETE_SELECTION) then
		local info = VAS_AUTO_COMPLETE_ENTRIES[VAS_AUTO_COMPLETE_SELECTION + VAS_AUTO_COMPLETE_OFFSET];
		VAS_AUTO_COMPLETE_SELECTION = nil;
		VAS_AUTO_COMPLETE_OFFSET = 0;

		self:SetText(info.value);
		self.AutoCompleteBox:Hide();
	end
end

function CharacterServicesEditBoxWithAutoCompleteMixin:OnKeyDown(key)
	if (key == "DOWN") then
		self:IncrementSelection();
	elseif (key == "UP") then
		self:DecrementSelection();
	elseif (key == "ENTER") then
		self:EnterPressed();
	elseif (key == "ESCAPE") then
		self.AutoCompleteBox:Hide();
	end
end
