ADDON_BUTTON_HEIGHT = 16;
MAX_ADDONS_DISPLAYED = 19;

local ADDON_ACTIONS_BLOCKED = { };

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
			CharacterSelect_CheckDialogStates();
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
			CharacterSelect_CheckDialogStates();
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

	function TryShowAddonDialog()
		-- Check to see if any of them are out of date and not disabled
		if not GlueAnnouncementDialog:IsShown() and C_AddOns.IsAddonVersionCheckEnabled() and AddonList_HasOutOfDate() and not HasShownAddonOutOfDateDialog then
			AddonDialog_Show("ADDONS_OUT_OF_DATE");
			HasShownAddonOutOfDateDialog = true;
			return true;
		end

		return false;
	end

	function UpdateAddonButton()
		if CharacterSelectAddonsButton then
			if ( C_AddOns.GetNumAddOns() > 0 ) then
				CharacterSelectAddonsButton:Show();
			else
				CharacterSelectAddonsButton:Hide();
			end
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
	for i=1,C_AddOns.GetNumAddOns() do
		local character = nil;
		if (not InGlue()) then
			character = UnitName("player");
		end
		local enabled = (C_AddOns.GetAddOnEnableState(i, character) > Enum.AddOnEnableState.None);
		local reason = select(5,C_AddOns.GetAddOnInfo(i))
		if ( enabled ~= AddonList.startStatus[i] and reason ~= "DEP_DISABLED" ) then
			return true
		end
	end
	return false
end

function AddonList_HasNewVersion()
	local hasNewVersion = false;
	for i=1, C_AddOns.GetNumAddOns() do
		local name, title, notes, loadable, reason, security, newVersion = C_AddOns.GetAddOnInfo(i);
		if ( newVersion ) then
			hasNewVersion = true;
			break;
		end
	end
	return hasNewVersion;
end

local function AddonList_Hide(save)
	AddonList.save = save

	if ( InGlue() ) then
		AddonList:Hide()
	else
		HideUIPanel(AddonList);
	end
end

function AddonList_OnLoad(self)
	self:SetTitle(ADDON_LIST);
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
		for i=1,C_AddOns.GetNumAddOns() do
			self.startStatus[i] = (C_AddOns.GetAddOnEnableState(i, UnitName("player")) > Enum.AddOnEnableState.None);
			if (select(5, C_AddOns.GetAddOnInfo(i)) == "INTERFACE_VERSION") then
				tinsert(self.outOfDateIndexes, i);
			end
		end
	end

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("AddonListEntryTemplate", function(button, elementData)
		AddonList_InitButton(button, elementData);
	end);

	view:SetPadding(2,2,2,2,5);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

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
	local checkedTexture = checkButton.CheckedTexture;
	if ( not checkedTexture ) then
		message("Can't find checked texture");
	end
	if ( not checked or checked == Enum.AddOnEnableState.None ) then
		-- nil or Enum.AddOnEnableState.None means not checked
		checkButton:SetChecked(false);
	elseif ( checked == Enum.AddOnEnableState.All ) then
		-- Enum.AddOnEnableState.All is a normal check
		checkButton:SetChecked(true);
		checkedTexture:SetVertexColor(1, 1, 1);
		checkedTexture:SetDesaturated(false);
	else
		-- Enum.AddOnEnableState.Some is a gray check
		checkButton:SetChecked(true);
		checkedTexture:SetDesaturated(true);
	end
	checkButton.state = checked or Enum.AddOnEnableState.None;
end

function AddonList_InitButton(entry, addonIndex)
	local name, title, notes, _, _, security = C_AddOns.GetAddOnInfo(addonIndex);

	-- Get the character from the current list (nil is all characters)
	local character = GetAddonCharacter();

	-- Get loadable state for the selected character, rather than all characters which GetAddOnInfo checks
	local loadable, reason = C_AddOns.IsAddOnLoadable(addonIndex, character);

	local checkboxState = C_AddOns.GetAddOnEnableState(addonIndex, character);
	local enabled;
	if ( not InGlue() ) then
		enabled = (C_AddOns.GetAddOnEnableState(addonIndex, UnitName("player")) > Enum.AddOnEnableState.None);
	else
		enabled = (checkboxState > Enum.AddOnEnableState.None);
	end

	TriStateCheckbox_SetState(checkboxState, entry.Enabled);
	if (checkboxState == Enum.AddOnEnableState.Some ) then
		entry.Enabled.tooltip = ENABLED_FOR_SOME;
	else
		entry.Enabled.tooltip = nil;
	end

	if ( loadable or ( enabled and (reason == "DEP_DEMAND_LOADED" or reason == "DEMAND_LOADED") ) ) then
		entry.Title:SetTextColor(1.0, 0.78, 0.0);
	elseif ( enabled and reason ~= "DEP_DISABLED" ) then
		entry.Title:SetTextColor(1.0, 0.1, 0.1);
	else
		entry.Title:SetTextColor(0.5, 0.5, 0.5);
	end

	local titleText = title or name;

	local iconTexture = C_AddOns.GetAddOnMetadata(addonIndex, "IconTexture");
	local iconAtlas = C_AddOns.GetAddOnMetadata(addonIndex, "IconAtlas");

	if not iconTexture and not iconAtlas then
		iconTexture = [[Interface\ICONS\INV_Misc_QuestionMark]];
	end

	if iconTexture then
		titleText = CreateSimpleTextureMarkup(iconTexture, 20, 20) .. " " .. titleText;
	elseif iconAtlas then
		titleText = CreateAtlasMarkup(iconAtlas, 20, 20) .. " " .. titleText;
	end

	if ADDON_ACTIONS_BLOCKED[name] then
		titleText = titleText .. CreateSimpleTextureMarkup([[Interface\DialogFrame\DialogIcon-AlertNew-16]], 16, 16);
	end
	entry.Title:SetText(titleText);

	if ( security == "SECURE" ) then
		AddonList_SetSecurityIcon(entry.Security.Icon, 1);
	elseif ( security == "INSECURE" ) then
		AddonList_SetSecurityIcon(entry.Security.Icon, 2);
	elseif ( security == "BANNED" ) then
		AddonList_SetSecurityIcon(entry.Security.Icon, 3);
	end

	entry.Security.tooltip = _G["ADDON_"..security];

	if ( not loadable and reason ) then
		entry.Status:SetText(_G["ADDON_"..reason]);
	else
		entry.Status:SetText("");
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
end

function AddonList_Update()
	local dataProvider = CreateIndexRangeDataProvider(C_AddOns.GetNumAddOns());
	AddonList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

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

function AddonList_OnKeyDown(self, key)
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
			local extent = 20;
			local maxCharacters = 18;
			local maxScrollExtent = extent * maxCharacters;
			rootDescription:SetScrollMode(maxScrollExtent);

			local includeEmptySlots = true;
			local numCharacters = GetNumCharacters(includeEmptySlots);
			for i=1, numCharacters do
				local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(i);

				-- Check each entry if it's an empty character.
				if characterInfo then
					rootDescription:CreateRadio(characterInfo.name, IsSelected, SetSelected, characterInfo.name);
				end
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

	EventRegistry:TriggerEvent("AddonList.FrameHidden");
end

function AddonList_HasOutOfDate()
	local hasOutOfDate = false;
	for i=1, C_AddOns.GetNumAddOns() do
		local name, title, notes, loadable, reason = C_AddOns.GetAddOnInfo(i);
		local character = nil;
		if (not InGlue()) then
			character = UnitName("player");
		end
		local enabled = (C_AddOns.GetAddOnEnableState(i, character) > Enum.AddOnEnableState.None);
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
		local enabled = (C_AddOns.GetAddOnEnableState(i, character) > Enum.AddOnEnableState.None);
		if ( enabled and not loadable and reason == "INTERFACE_VERSION" ) then
			C_AddOns.DisableAddOn(i);
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
	AddonTooltip:ClearLines();
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
	if ADDON_ACTIONS_BLOCKED[name] then
		AddonTooltip:AddLine(INTERFACE_ACTION_BLOCKED_TOOLTIP:format(ADDON_ACTIONS_BLOCKED[name]));
	end
	AddonTooltip:Show()
end

function AddonTooltip_ActionBlocked(addon)
	ADDON_ACTIONS_BLOCKED[addon] = (ADDON_ACTIONS_BLOCKED[addon] or 0) + 1;
end