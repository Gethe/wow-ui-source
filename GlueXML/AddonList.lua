ADDON_BUTTON_HEIGHT = 16;
MAX_ADDONS_DISPLAYED = 19;

function UpdateAddonButton()
	if ( GetNumAddOns() > 0 ) then
		-- Check to see if any of them are out of date and not disabled
		if ( IsAddonVersionCheckEnabled() and AddonList_HasOutOfDate() and not HasShownAddonOutOfDateDialog ) then
			AddonDialog_Show("ADDONS_OUT_OF_DATE");
			HasShownAddonOutOfDateDialog = true;
		end
		if ( AddonList_HasNewVersion() ) then
			CharacterSelectAddonsButtonGlow:Show();
		else
			CharacterSelectAddonsButtonGlow:Hide();
		end
		CharacterSelectAddonsButton:Show();
	else
		CharacterSelectAddonsButton:Hide();
	end
end

function AddonList_OnLoad(self)
	self.offset = 0;
end

function AddonList_Update()
	local numEntrys = GetNumAddOns();
	local name, title, notes, url, loadable, reason, security, newVersion;
	local addonIndex;
	local entry, checkbox, string, status, urlButton, securityIcon, versionButton;

	-- Get the character from the current list (nil is all characters)
	local character = GlueDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	if ( character == ALL ) then
		character = nil;
	end
	local enabled, checkboxState;

	for i=1, MAX_ADDONS_DISPLAYED do
		addonIndex = AddonList.offset + i;
		entry = _G["AddonListEntry"..i];
		if ( addonIndex > numEntrys ) then
			entry:Hide();
		else
			name, title, notes, url, loadable, reason, security, newVersion = GetAddOnInfo(addonIndex);
			-- GetAddOnEnableState() returns 0, 1, 2 (disabled, enabled for some, enabled for all)
			checkboxState = GetAddOnEnableState(character, addonIndex);
			enabled = (checkboxState > 0);

			checkbox = _G["AddonListEntry"..i.."Enabled"];
			-- If some are enabled then set the checkbox to be gray
			TriStateCheckbox_SetState(checkboxState, checkbox);
			if ( checkboxState == 1 ) then
				checkbox.tooltip = ENABLED_FOR_SOME;
			else
				checkbox.tooltip = nil;
			end

			string = _G["AddonListEntry"..i.."Title"];
			if ( loadable or ( enabled and (reason == "DEP_DEMAND_LOADED" or reason == "DEMAND_LOADED") ) ) then
				string:SetTextColor(1.0, 0.78, 0.0);
			elseif ( enabled and reason ~= "DEP_DISABLED" ) then
				string:SetTextColor(1.0, 0.1, 0.1);
			else
				string:SetTextColor(0.5, 0.5, 0.5);
			end
			if ( title ) then
				string:SetText(title);
			else
				string:SetText(name);
			end
			urlButton = _G["AddonListEntry"..i.."URL"];
			versionButton = _G["AddonListEntry"..i.."Update"];
			if ( url ) then
				if ( newVersion ) then
					versionButton.tooltip = ADDON_UPDATE_AVAILABLE..CLICK_TO_LAUNCH_ADDON_URL..url;
					versionButton.url = url;
					versionButton:Show();
					urlButton:Hide();
				else
					versionButton:Hide();
					urlButton.tooltip = CLICK_TO_LAUNCH_ADDON_URL..url;
					urlButton.url = url;
					urlButton:Show();
				end
				
			else
				versionButton:Hide();
				urlButton:Hide();
			end
			securityIcon = _G["AddonListEntry"..i.."SecurityIcon"];
			if ( security == "SECURE" ) then
				AddonList_SetSecurityIcon(securityIcon, 1);
			elseif ( security == "INSECURE" ) then
				AddonList_SetSecurityIcon(securityIcon, 2);
			elseif ( security == "BANNED" ) then
				AddonList_SetSecurityIcon(securityIcon, 3);
			end
			_G["AddonListEntry"..i.."Security"].tooltip = _G["ADDON_"..security];
			string = _G["AddonListEntry"..i.."Status"];
			if ( reason ) then
				string:SetText(_G["ADDON_"..reason]);
			else
				string:SetText("");
			end

			entry:SetID(addonIndex);
			entry:Show();
		end
	end

	-- ScrollFrame stuff
	GlueScrollFrame_Update(AddonListScrollFrame, numEntrys, MAX_ADDONS_DISPLAYED, ADDON_BUTTON_HEIGHT);
end

function AddonTooltip_BuildDeps(...)
	local deps = "";
	for i=1, select("#", ...) do
		if ( i == 1 ) then
			deps = ADDON_DEPENDENCIES .. select(i, ...);
		else
			deps = deps..", "..select(i, ...);
		end
	end
	return deps;
end

function AddonTooltip_Update(owner)
	local name, title, notes,_,_,_, security = GetAddOnInfo(owner:GetID());
	if ( security == "BANNED" ) then
		AddonTooltipTitle:SetText(ADDON_BANNED_TOOLTIP);
		AddonTooltipNotes:SetText("");
		AddonTooltipDeps:SetText("");
	else
		if ( title ) then
			AddonTooltipTitle:SetText(title);
		else
			AddonTooltipTitle:SetText(name);
		end
		AddonTooltipNotes:SetText(notes);
		AddonTooltipDeps:SetText(AddonTooltip_BuildDeps(GetAddOnDependencies(owner:GetID())));
	end
	
	local titleHeight = AddonTooltipTitle:GetHeight();
	local notesHeight = AddonTooltipNotes:GetHeight();
	local depsHeight = AddonTooltipDeps:GetHeight();
	AddonTooltip:SetHeight(10+titleHeight+2+notesHeight+2+depsHeight+10);
end

function AddonList_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		AddonList_OnCancel();
	elseif ( key == "ENTER" ) then
		AddonList_OnOk();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function AddonList_Enable(index, enabled)
	local character = GlueDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	if ( character == ALL ) then
		character = nil;
	end
	if ( enabled ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		EnableAddOn(character, index);
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
		DisableAddOn(character, index);
	end
	AddonList_Update();
end

function AddonList_OnOk()
	PlaySound("gsLoginChangeRealmOK");
	SaveAddOns();
	AddonList:Hide();
end

function AddonList_OnCancel()
	PlaySound("gsLoginChangeRealmCancel");
	ResetAddOns();
	AddonList:Hide();
end

function AddonListScrollFrame_OnVerticalScroll(self, offset)
	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(offset);
	AddonList.offset = floor((offset / ADDON_BUTTON_HEIGHT) + 0.5);
	AddonList_Update();
	if ( AddonTooltip:IsShown() ) then
		AddonTooltip_Update(AddonTooltip.owner);
	end
end

function AddonList_OnShow()
	AddonList_Update();
end

function AddonList_HasOutOfDate()
	local hasOutOfDate = false;
	for i=1, GetNumAddOns() do
		local name, title, notes, url, loadable, reason = GetAddOnInfo(i);
		if ( enabled and not loadable and reason == "INTERFACE_VERSION" ) then
			hasOutOfDate = true;
			break;
		end
	end
	return hasOutOfDate;
end

function AddonList_SetSecurityIcon(texture, index)
	local width = 64;
	local height = 16;
	local iconWidth = 16;
	local increment = iconWidth/width;
	local left = (index - 1) * increment;
	local right = index * increment;
	texture:SetTexCoord( left, right, 0, 1.0);
end

function AddonList_DisableOutOfDate()
	for i=1, GetNumAddOns() do
		local name, title, notes, url, loadable, reason = GetAddOnInfo(i);
		if ( enabled and not loadable and reason == "INTERFACE_VERSION" ) then
			DisableAddOn(i);
		end
	end
end

function AddonList_HasNewVersion()
	local hasNewVersion = false;
	for i=1, GetNumAddOns() do
		local name, title, notes, url, loadable, reason, security, newVersion = GetAddOnInfo(i);
		if ( newVersion ) then
			hasNewVersion = true;
			break;
		end
	end
	return hasNewVersion;
end

AddonDialogTypes = { };

AddonDialogTypes["ADDONS_OUT_OF_DATE"] = {
	text = ADDONS_OUT_OF_DATE,
	button1 = DISABLE_ADDONS,
	button2 = LOAD_ADDONS,
	OnAccept = function()
		AddonDialog_Show("CONFIRM_DISABLE_ADDONS");
	end,
	OnCancel = function()
		AddonDialog_Show("CONFIRM_LOAD_ADDONS");
	end,
}

AddonDialogTypes["CONFIRM_LOAD_ADDONS"] = {
	text = CONFIRM_LOAD_ADDONS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		SetAddonVersionCheck(0);
	end,
	OnCancel = function()
		AddonDialog_Show("ADDONS_OUT_OF_DATE");
	end,
}

AddonDialogTypes["CONFIRM_DISABLE_ADDONS"] = {
	text = CONFIRM_DISABLE_ADDONS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		AddonList_DisableOutOfDate();
	end,
	OnCancel = function()
		AddonDialog_Show("ADDONS_OUT_OF_DATE");
	end,
}

AddonDialogTypes["CONFIRM_LAUNCH_ADDON_URL"] = {
	text = CONFIRM_LAUNCH_ADDON_URL,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		LaunchAddOnURL(AddonList.selectedID);
	end
}

function AddonDialog_Show(which, arg1)
	-- Set the text of the dialog
	if ( arg1 ) then
		AddonDialogText:SetFormattedText(AddonDialogTypes[which].text, arg1);
	else
		AddonDialogText:SetText(AddonDialogTypes[which].text);
	end

	-- Set the buttons of the dialog
	if ( AddonDialogTypes[which].button2 ) then
		AddonDialogButton1:ClearAllPoints();
		AddonDialogButton1:SetPoint("BOTTOMRIGHT", "AddonDialogBackground", "BOTTOM", -6, 16);
		AddonDialogButton2:ClearAllPoints();
		AddonDialogButton2:SetPoint("LEFT", "AddonDialogButton1", "RIGHT", 13, 0);
		AddonDialogButton2:SetText(AddonDialogTypes[which].button2);
		AddonDialogButton2:Show();
	else
		AddonDialogButton1:ClearAllPoints();
		AddonDialogButton1:SetPoint("BOTTOM", "AddonDialogBackground", "BOTTOM", 0, 16);
		AddonDialogButton2:Hide();
	end

	AddonDialogButton1:SetText(AddonDialogTypes[which].button1);

	-- Set the miscellaneous variables for the dialog
	AddonDialog.which = which;

	-- Finally size and show the dialog
	AddonDialogBackground:SetHeight(16 + AddonDialogText:GetHeight() + 8 + AddonDialogButton1:GetHeight() + 16);
	AddonDialog:Show();
end

function AddonDialog_OnClick(self, button, down)
	local index = self:GetID();
	AddonDialog:Hide();
	if ( index == 1 ) then
		local OnAccept = AddonDialogTypes[AddonDialog.which].OnAccept;
		if ( OnAccept ) then
			OnAccept();
		end
	else
		local OnCancel = AddonDialogTypes[AddonDialog.which].OnCancel;
		if ( OnCancel ) then
			OnCancel();
		end
	end
end

function AddonDialog_OnKeyDown(key)
	if ( key == "PRINTSCREEN" ) then
		Screenshot();
		return;
	end

	if ( key == "ESCAPE" ) then
		if ( AddonDialogButton2:IsShown() ) then
			AddonDialogButton2:Click();
		else
			AddonDialogButton1:Click();
		end
	elseif (key == "ENTER" ) then
		AddonDialogButton1:Click();
	end
end

function AddonListCharacterDropDown_OnClick(self)
	GlueDropDownMenu_SetSelectedValue(AddonCharacterDropDown, self.value);
	AddonList_Update();
end

function AddonListCharacterDropDown_Initialize()
	local selectedValue = GlueDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	local info = GlueDropDownMenu_CreateInfo();
	info.text = ALL;
	info.value = ALL;
	info.func = AddonListCharacterDropDown_OnClick;
	if ( not selectedValue ) then
		info.checked = 1;
	end
	GlueDropDownMenu_AddButton(info);

	for i=1, GetNumCharacters() do
		info.text = GetCharacterInfo(i);
		info.value = GetCharacterInfo(i);
		info.func = AddonListCharacterDropDown_OnClick;
		if ( selectedValue == info.value ) then
			info.checked = 1;
		else
			info.checked = nil;
		end
		GlueDropDownMenu_AddButton(info);
	end
end
