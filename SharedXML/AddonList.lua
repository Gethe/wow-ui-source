ADDON_BUTTON_HEIGHT = 16;
MAX_ADDONS_DISPLAYED = 19;

if ( not InGlue() ) then
	UIPanelWindows["AddonList"] = { area = "center", pushable = 0, whileDead = 1 };
end

-- We use this in the shared XML file
AddonTooltip = nil;

local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
local UIDropDownMenu_GetSelectedValue = UIDropDownMenu_GetSelectedValue
local UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue

if ( InGlue() ) then
	AddonDialogTypes = { };
	HasShownAddonOutOfDateDialog = false;
	
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
			SetAddonVersionCheck(false);
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

	function AddonDialog_Show(which)
		-- Set the text of the dialog
		AddonDialogText:SetText(AddonDialogTypes[which].text);

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

	AddonTooltip = GlueTooltip
	UIDropDownMenu_Initialize = GlueDropDownMenu_Initialize
	UIDropDownMenu_AddButton = GlueDropDownMenu_AddButton
	UIDropDownMenu_CreateInfo = GlueDropDownMenu_CreateInfo
	UIDropDownMenu_GetSelectedValue = GlueDropDownMenu_GetSelectedValue
	UIDropDownMenu_SetSelectedValue = GlueDropDownMenu_SetSelectedValue

	function UpdateAddonButton(checkVersion)
		if ( GetNumAddOns() > 0 ) then
			-- Check to see if any of them are out of date and not disabled
			if ( checkVersion and IsAddonVersionCheckEnabled() and AddonList_HasOutOfDate() and not HasShownAddonOutOfDateDialog ) then
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
else
	AddonTooltip = GameTooltip
end

function AddonList_HasAnyChanged()
	if (AddonList.outOfDate and not IsAddonVersionCheckEnabled() or (not AddonList.outOfDate and IsAddonVersionCheckEnabled() and AddonList_HasOutOfDate())) then
		return true;
	end
	for i=1,GetNumAddOns() do
		local character = nil;
		if (not InGlue()) then
			character = UnitName("player");
		end
		local enabled = (GetAddOnEnableState(character, i) > 0);
		local reason = select(5,GetAddOnInfo(i))
		if ( enabled ~= AddonList.startStatus[i] and reason ~= "DEP_DISABLED" ) then
			return true
		end
	end
	return false
end

function AddonList_HasNewVersion()
	local hasNewVersion = false;
	for i=1, GetNumAddOns() do
		local name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(i);
		if ( newVersion ) then
			hasNewVersion = true;
			break;
		end
	end
	return hasNewVersion;
end

function AddonList_Show()
	if ( InGlue() ) then
		AddonList:Show();
	else
		ShowUIPanel(AddonList);
	end
end

function AddonList_Hide(save)
	AddonList.save = save

	if ( InGlue() ) then
		AddonList:Hide()
	else
		HideUIPanel(AddonList);
	end
end

function AddonList_OnLoad(self)
	self.TitleText:SetText(ADDON_LIST)
	ButtonFrameTemplate_HidePortrait(self)

	self.offset = 0;

	local template;
	if ( InGlue() ) then
		self:SetParent(GlueParent)
		AddonDialog:SetParent(GlueParent)
		AddonDialog:SetFrameStrata("DIALOG")
		AddonDialogButton1:SetScript("OnClick", AddonDialog_OnClick);
		AddonDialogButton2:SetScript("OnClick", AddonDialog_OnClick);
		local bg = CreateFrame("Frame", "AddonListBackground", GlueParent)
		bg:SetFrameStrata("HIGH")
		bg:EnableMouse(true)
		bg:SetAllPoints()
		bg:Hide()
		local tex = bg:CreateTexture()
		tex:SetColorTexture(0, 0, 0, 0.6)
		tex:SetDrawLayer("BACKGROUND")
		tex:SetPoint("TOPLEFT")
		tex:SetPoint("BOTTOMRIGHT")
		self:EnableKeyboard(true)
		self:SetScript("OnKeyDown", AddonList_OnKeyDown)
		self:SetFrameStrata("DIALOG")
		template = "GlueDropDownMenuTemplate"
	else
		AddonDialog = nil;
		self:SetParent(UIParent);
		self:SetFrameStrata("HIGH");
		template = "UIDropDownMenuTemplate"
		self.startStatus = {};
		self.shouldReload = false;
		self.outOfDate = IsAddonVersionCheckEnabled() and AddonList_HasOutOfDate();
		self.outOfDateIndexes = {};
		for i=1,GetNumAddOns() do
			self.startStatus[i] = (GetAddOnEnableState(UnitName("player"), i) > 0);
			if (select(5, GetAddOnInfo(i)) == "INTERFACE_VERSION") then
				tinsert(self.outOfDateIndexes, i);
			end
		end
	end
	local drop = CreateFrame("Frame", "AddonCharacterDropDown", self, template)
	drop:SetPoint("TOPLEFT", 0, -30)
	UIDropDownMenu_Initialize(drop, AddonListCharacterDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(drop, true);
	AddonListScrollFrameScrollChildFrame:SetParent(AddonListScrollFrame);
end

function AddonList_SetStatus(self,lod,status,reload)
	local button = self.LoadAddonButton
	local string = self.Status
	local relstr = self.Reload

	if ( lod ) then
		button:Show()
	else
		button:Hide()
	end

	if ( status ) then
		string:Show()
	else
		string:Hide()
	end

	if ( reload ) then
		relstr:Show()
	else
		relstr:Hide()
	end
end 

function AddonList_Update()
	local numEntrys = GetNumAddOns();
	local name, title, notes, enabled, loadable, reason, security;
	local addonIndex;
	local entry, checkbox, string, status, urlButton, securityIcon, versionButton;

	for i=1, MAX_ADDONS_DISPLAYED do
		addonIndex = AddonList.offset + i;
		entry = _G["AddonListEntry"..i];
		if ( addonIndex > numEntrys ) then
			entry:Hide();
		else
			name, title, notes, loadable, reason, security = GetAddOnInfo(addonIndex);

			-- Get the character from the current list (nil is all characters)
			local character = UIDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
			if ( character == true ) then
				character = nil;
			end

			checkbox = _G["AddonListEntry"..i.."Enabled"];
			local checkboxState = GetAddOnEnableState(character, addonIndex);
			if ( not InGlue() ) then
				enabled = (GetAddOnEnableState(UnitName("player"), addonIndex) > 0);
			else
				enabled = (checkboxState > 0);
			end

			TriStateCheckbox_SetState(checkboxState, checkbox);
			if (checkboxState == 1 ) then
				checkbox.AddonTooltip = ENABLED_FOR_SOME;
			else
				checkbox.AddonTooltip = nil;
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
			if ( not loadable and reason ) then
				string:SetText(_G["ADDON_"..reason]);
			else
				string:SetText("");
			end

			if ( not InGlue() ) then
				if ( enabled ~= AddonList.startStatus[addonIndex] and reason ~= "DEP_DISABLED" or 
					(reason ~= "INTERFACE_VERSION" and tContains(AddonList.outOfDateIndexes, addonIndex)) or 
					(reason == "INTERFACE_VERSION" and not tContains(AddonList.outOfDateIndexes, addonIndex))) then
					if ( enabled ) then
						-- special case for loadable on demand addons
						if ( AddonList_IsAddOnLoadOnDemand(addonIndex) ) then
							AddonList_SetStatus(entry, true, false, false)
						else
							AddonList_SetStatus(entry, false, false, true)
						end
					else
						AddonList_SetStatus(entry, false, false, true)
					end
				else
					AddonList_SetStatus(entry, false, true, false)
				end
			else
				AddonList_SetStatus(entry, false, true, false)
			end

			entry:SetID(addonIndex);
			entry:Show();
		end
	end

	-- ScrollFrame stuff
	FauxScrollFrame_Update(AddonListScrollFrame, numEntrys, MAX_ADDONS_DISPLAYED, ADDON_BUTTON_HEIGHT);

	if ( not InGlue() ) then
		if ( AddonList_HasAnyChanged() ) then
			AddonListOkayButton:SetText(RELOADUI)
			AddonList.shouldReload = true
		else
			AddonListOkayButton:SetText(OKAY)
			AddonList.shouldReload = false
		end
	end
end

function AddonList_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		AddonList_OnCancel();
	elseif ( key == "ENTER" ) then
		AddonList_OnOkay();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function AddonList_IsAddOnLoadOnDemand(index)
	local lod = false
	if ( IsAddOnLoadOnDemand(index) ) then
		local deps = GetAddOnDependencies(index)
		local okay = true;
		for i = 1, select('#', deps) do
			local dep = select(i, deps)
			if ( dep and not IsAddOnLoaded(select(i, deps)) ) then
				okay = false;
				break;
			end
		end
		lod = okay;
	end
	return lod;
end

function AddonList_Enable(index, enabled)

	local character = UIDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	if ( enabled ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		EnableAddOn(index,character);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		DisableAddOn(index,character);
	end
	AddonList_Update();
end

function AddonList_EnableAll(self, button, down)
	EnableAllAddOns(UIDropDownMenu_GetSelectedValue(AddonCharacterDropDown));
	AddonList_Update();
end

function AddonList_DisableAll(self, button, down)
	DisableAllAddOns(UIDropDownMenu_GetSelectedValue(AddonCharacterDropDown));
	AddonList_Update();
end

function AddonList_LoadAddOn(index)
	if ( not AddonList_IsAddOnLoadOnDemand(index) ) then return end
	LoadAddOn(index)
	if ( IsAddOnLoaded(index) ) then
		AddonList.startStatus[index] = true
	end
	AddonList_Update()
end

function AddonList_OnOkay()
	PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK);
	AddonList_Hide(true);
	if ( not InGlue() ) then
		if ( AddonList.shouldReload ) then
			ReloadUI();
		end
	end
end

function AddonList_OnCancel()
	PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_CANCEL);
	AddonList_Hide(false);
end

function AddonListScrollFrame_OnVerticalScroll(self, offset)
	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(offset);
	AddonList.offset = floor((offset / ADDON_BUTTON_HEIGHT) + 0.5);
	AddonList_Update();
	if ( AddonTooltip:IsShown() ) then
		AddonTooltip_Update(AddonTooltip:GetOwner());
		AddonTooltip:Show()
	end
end

function AddonList_OnShow()
	if ( InGlue() ) then
		AddonListBackground:Show()
	end
	UIDropDownMenu_Initialize(AddonCharacterDropDown, AddonListCharacterDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue( AddonCharacterDropDown, UIDropDownMenu_GetSelectedValue(AddonCharacterDropDown) );
	AddonList_Update();
end

function AddonList_OnHide(self)
	if ( InGlue() ) then
		AddonListBackground:Hide()
	end
	if ( self.save ) then
		SaveAddOns();
	else
		ResetAddOns();
	end
	self.save = false;
end

function AddonList_HasOutOfDate()
	local hasOutOfDate = false;
	for i=1, GetNumAddOns() do
		local name, title, notes, loadable, reason = GetAddOnInfo(i);
		local character = nil;
		if (not InGlue()) then
			character = UnitName("player");
		end
		local enabled = (GetAddOnEnableState(character, i) > 0);
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
		local name, title, notes, loadable, reason = GetAddOnInfo(i);
		local character = nil;
		if (not InGlue()) then
			character = UnitName("player");
		end
		local enabled = (GetAddOnEnableState(character , i) > 0);
		if ( enabled and not loadable and reason == "INTERFACE_VERSION" ) then
			DisableAddOn(i, true);			
		end
	end
	SaveAddOns();
end

function AddonListCharacterDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(AddonCharacterDropDown, self.value);
	AddonList_Update();
end

function AddonListCharacterDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	local info = UIDropDownMenu_CreateInfo();
	info.text = ALL;
	info.value = true;
	info.func = AddonListCharacterDropDown_OnClick;
	if ( not selectedValue ) then
		info.checked = 1;
	end
	UIDropDownMenu_AddButton(info);

	if ( InGlue() ) then
		for i=1, GetNumCharacters() do
			info.text = GetCharacterInfo(i);
			info.value = GetCharacterInfo(i);
			info.func = AddonListCharacterDropDown_OnClick;
			if ( selectedValue == info.value ) then
				info.checked = 1;
			else
				info.checked = nil;
			end
			UIDropDownMenu_AddButton(info);
		end
	else
		info.text = UnitName("player")
		info.value = UnitName("player");
		if ( selectedValue == info.value ) then
			info.checked = 1;
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
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
	local name, title, notes, _, _, security = GetAddOnInfo(owner:GetID());
	if ( InGlue() ) then
		AddonTooltip:Clear()
	else
		AddonTooltip:ClearLines();
	end
	if ( security == "BANNED" ) then
		AddonTooltip:SetText(ADDON_BANNED_TOOLTIP);
	else
		if ( title ) then
			AddonTooltip:AddLine(title);
		else
			AddonTooltip:AddLine(name);
		end
		AddonTooltip:AddLine(notes, 1.0, 1.0, 1.0);
		AddonTooltip:AddLine(AddonTooltip_BuildDeps(GetAddOnDependencies(owner:GetID())));
	end
	AddonTooltip:Show()
end