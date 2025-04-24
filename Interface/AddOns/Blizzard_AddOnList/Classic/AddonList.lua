ADDON_BUTTON_HEIGHT = 16;
MAX_ADDONS_DISPLAYED = 19;

local ALL_CHARACTERS = "All";
local addonCharacter = ALL_CHARACTERS;

local function GetAddonCharacter()
	if addonCharacter == ALL_CHARACTERS then
		return nil;
	end
	return addonCharacter;
end


if ( not InGlue() ) then
	UIPanelWindows["AddonList"] = { area = "center", pushable = 0, whileDead = 1 };
end

-- We use this in the shared XML file
AddonTooltip = nil;
AddonDialog = nil;

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
			C_AddOns.SetAddonVersionCheck(false);
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

	function UpdateAddonButton(checkVersion)
		if ( C_AddOns.GetNumAddOns() > 0 ) then
			-- Check to see if any of them are out of date and not disabled
			if ( checkVersion and C_AddOns.IsAddonVersionCheckEnabled() and AddonList_HasOutOfDate() and not HasShownAddonOutOfDateDialog ) then
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

function AddonList_ClearCharacterDropdown()
	addonCharacter = ALL_CHARACTERS;
end

function AddonList_HasAnyChanged()
	if (AddonList.outOfDate and not C_AddOns.IsAddonVersionCheckEnabled() or (not AddonList.outOfDate and C_AddOns.IsAddonVersionCheckEnabled() and AddonList_HasOutOfDate())) then
		return true;
	end
	for i = 1, C_AddOns.GetNumAddOns() do
		local character = nil;
		if (not InGlue()) then
			character = UnitName("player");
		end
		local enabled = (C_AddOns.GetAddOnEnableState(i, character) > 0);
		local reason = select(5, C_AddOns.GetAddOnInfo(i))
		if ( enabled ~= AddonList.startStatus[i] and reason ~= "DEP_DISABLED" ) then
			return true
		end
	end
	return false
end

function AddonList_HasNewVersion()
	local hasNewVersion = false;
	for i = 1, C_AddOns.GetNumAddOns() do
		local name, title, notes, loadable, reason, security, newVersion = C_AddOns.GetAddOnInfo(i);
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

	if ( InGlue() ) then
		self:SetParent(GlueParent)
		AddonDialog:SetParent(GlueParent)
		AddonDialog:SetFrameStrata("DIALOG")
		AddonDialogButton1:SetScript("OnClick", AddonDialog_OnClick);
		AddonDialogButton2:SetScript("OnClick", AddonDialog_OnClick);
		self:EnableKeyboard(true)
		self:SetScript("OnKeyDown", AddonList_OnKeyDown)
		self:SetFrameStrata("DIALOG")
	else
		AddonDialog = nil;
		self:SetParent(UIParent);
		self:SetFrameStrata("HIGH");
		self.startStatus = {};
		self.shouldReload = false;
		self.outOfDate = C_AddOns.IsAddonVersionCheckEnabled() and AddonList_HasOutOfDate();
		self.outOfDateIndexes = {};
		local playerName = UnitName("player");
		for i = 1, C_AddOns.GetNumAddOns() do
			self.startStatus[i] = (C_AddOns.GetAddOnEnableState(i, playerName) > 0);
			if (select(5, C_AddOns.GetAddOnInfo(i)) == "INTERFACE_VERSION") then
				tinsert(self.outOfDateIndexes, i);
			end
		end
	end
	
	AddonListScrollFrameScrollChildFrame:SetParent(AddonListScrollFrame);

	self.Dropdown:SetWidth(140);
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

local function TriStateCheckbox_SetState(checked, checkButton)
	local checkedTexture = _G[checkButton:GetName().."CheckedTexture"];
	if ( not checkedTexture ) then
		message("Can't find checked texture");
	end
	if ( not checked or checked == 0 ) then
		-- nil or 0 means not checked
		checkButton:SetChecked(false);
		checkButton.state = 0;
	elseif ( checked == 2 ) then
		-- 2 is a normal
		checkButton:SetChecked(true);
		checkedTexture:SetVertexColor(1, 1, 1);
		checkedTexture:SetDesaturated(false);
		checkButton.state = 2;
	else
		-- 1 is a gray check
		checkButton:SetChecked(true);
		checkedTexture:SetDesaturated(true);
		checkButton.state = 1;
	end
end

function AddonList_Update()
	local numEntrys = C_AddOns.GetNumAddOns();
	local name, title, notes, enabled, loadable, reason, security;
	local addonIndex;
	local entry, checkbox, string, status, urlButton, securityIcon, versionButton;

	for i=1, MAX_ADDONS_DISPLAYED do
		addonIndex = AddonList.offset + i;
		entry = _G["AddonListEntry"..i];
		if ( addonIndex > numEntrys ) then
			entry:Hide();
		else
			name, title, notes, loadable, reason, security = C_AddOns.GetAddOnInfo(addonIndex);

			-- Get the character from the current list (nil is all characters)
			local character = GetAddonCharacter();

			checkbox = _G["AddonListEntry"..i.."Enabled"];
			local checkboxState = C_AddOns.GetAddOnEnableState(addonIndex, character);
			if ( not InGlue() ) then
				enabled = (C_AddOns.GetAddOnEnableState(addonIndex, UnitName("player")) > 0);
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
	if ( C_AddOns.IsAddOnLoadOnDemand(index) ) then
		local deps = C_AddOns.GetAddOnDependencies(index)
		local okay = true;
		for i = 1, select('#', deps) do
			local dep = select(i, deps)
			if ( dep and not C_AddOns.IsAddOnLoaded(select(i, deps)) ) then
				okay = false;
				break;
			end
		end
		lod = okay;
	end
	return lod;
end

function AddonList_Enable(index, enabled)
	local character = GetAddonCharacter();

	if ( enabled ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		C_AddOns.EnableAddOn(index,character);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		C_AddOns.DisableAddOn(index,character);
	end
	AddonList_Update();
end

function AddonList_EnableAll(self, button, down)
	local character = GetAddonCharacter();

	C_AddOns.EnableAllAddOns(character);
	AddonList_Update();
end

function AddonList_DisableAll(self, button, down)
	local character = GetAddonCharacter();

	C_AddOns.DisableAllAddOns(character);
	AddonList_Update();
end

function AddonList_LoadAddOn(index)
	if ( not AddonList_IsAddOnLoadOnDemand(index) ) then return end
	C_AddOns.LoadAddOn(index)
	if ( C_AddOns.IsAddOnLoaded(index) ) then
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

local function IsSelected(character)
	return addonCharacter == character;
end

local function SetSelected(character)
	addonCharacter = character;
	AddonList_Update();
end

function AddonList_OnShow(self)
	if ( InGlue() ) then
		GlueParent_AddModalFrame(self);
	end

	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_ADDON_LIST");

		rootDescription:CreateRadio(ALL, IsSelected, SetSelected, ALL_CHARACTERS);

		if InGlue() then
			for i=1, GetNumCharacters() do
				local text = GetCharacterInfo(i);
				rootDescription:CreateRadio(text, IsSelected, SetSelected, text);
			end
		else
			local text = UnitName("player");
			rootDescription:CreateRadio(text, IsSelected, SetSelected, text);
		end
	end);

	AddonList_Update();
end

function AddonList_OnHide(self)
	if ( InGlue() ) then
		GlueParent_RemoveModalFrame(self);
	end
	if ( self.save ) then
		C_AddOns.SaveAddOns();
	else
		C_AddOns.ResetAddOns();
	end
	self.save = false;
end

function AddonList_HasOutOfDate()
	local hasOutOfDate = false;
	for i=1, C_AddOns.GetNumAddOns() do
		local name, title, notes, loadable, reason = C_AddOns.GetAddOnInfo(i);
		local character = nil;
		if (not InGlue()) then
			character = UnitName("player");
		end
		local enabled = (C_AddOns.GetAddOnEnableState(i, character) > 0);
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
	for i=1, C_AddOns.GetNumAddOns() do
		local name, title, notes, loadable, reason = C_AddOns.GetAddOnInfo(i);
		local character = nil;
		if (not InGlue()) then
			character = UnitName("player");
		end
		local enabled = (C_AddOns.GetAddOnEnableState(i, character) > 0);
		if ( enabled and not loadable and reason == "INTERFACE_VERSION" ) then
			C_AddOns.DisableAddOn(i); -- passing nil as second argument means disable for all.
		end
	end
	C_AddOns.SaveAddOns();
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
	local name, title, notes, _, _, security = C_AddOns.GetAddOnInfo(owner:GetID());
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
		AddonTooltip:AddLine(AddonTooltip_BuildDeps(C_AddOns.GetAddOnDependencies(owner:GetID())));
	end
	AddonTooltip:Show()
end