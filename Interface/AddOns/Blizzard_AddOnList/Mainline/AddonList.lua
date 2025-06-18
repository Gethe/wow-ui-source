ADDON_BUTTON_HEIGHT = 16;
MAX_ADDONS_DISPLAYED = 19;

g_addonCategoriesCollapsed = { };

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

AddonDialogMixin = { };

function AddonDialogMixin:OnLoad()
	-- Overridden only for Glue
end

if ( InGlue() ) then
	AddonDialogTypes = { };
	HasShownAddonOutOfDateDialog = false;

	AddonDialogTypes["ADDONS_OUT_OF_DATE"] = {
		text = ADDONS_OUT_OF_DATE,
		button1 = DISABLE_ADDONS,
		button2 = LOAD_ADDONS,
		OnAccept = function(dialog, data)
			AddonDialog_Show("CONFIRM_DISABLE_ADDONS");
		end,
		OnCancel = function(dialog, data)
			AddonDialog_Show("CONFIRM_LOAD_ADDONS");
		end,
	}

	AddonDialogTypes["CONFIRM_LOAD_ADDONS"] = {
		text = CONFIRM_LOAD_ADDONS,
		button1 = OKAY,
		button2 = CANCEL,
		OnAccept = function(dialog, data)
			C_AddOns.SetAddonVersionCheck(false);
			CharacterSelect_CheckDialogStates();
		end,
		OnCancel = function(dialog, data)
			AddonDialog_Show("ADDONS_OUT_OF_DATE");
		end,
	}

	AddonDialogTypes["CONFIRM_DISABLE_ADDONS"] = {
		text = CONFIRM_DISABLE_ADDONS,
		button1 = OKAY,
		button2 = CANCEL,
		OnAccept = function(dialog, data)
			AddonList_DisableOutOfDate();
			CharacterSelect_CheckDialogStates();
		end,
		OnCancel = function(dialog, data)
			AddonDialog_Show("ADDONS_OUT_OF_DATE");
		end,
	}

	function AddonDialogMixin:OnLoad()
		AddonDialogBackground:ClearAllPoints();
		AddonDialogBackground:SetPoint("CENTER");

		self:SetScript("OnShow", self.OnShow);
		self:SetScript("OnKeyDown", self.OnKeyDown);
	end

	function AddonDialogMixin:OnShow()
		self:Raise();
	end

	function AddonDialogMixin:OnKeyDown()
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

AddonListMixin = { };

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
			character = GetAddonCharacter();
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

local function AddonList_InitCategory(entry, treeNode)
	local category = treeNode:GetData().category;
	entry.Title:SetText(category);

	entry.CollapseExpand:SetTreeNode(treeNode);
	entry.CollapseExpand:UpdateState();

	entry.title = category;
	entry.treeNode = treeNode;
end

function AddonListMixin:OnLoad()
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
			local character = GetAddonCharacter();
			self.startStatus[i] = (C_AddOns.GetAddOnEnableState(i, character) > Enum.AddOnEnableState.None);
			if (select(5, C_AddOns.GetAddOnInfo(i)) == "INTERFACE_VERSION") then
				tinsert(self.outOfDateIndexes, i);
			end
		end

		-- In Glue this defaults to "All", in-game it should default to the current character at design request.
		addonCharacter = UnitGUID("player");
	end

	local indent = 20;
	local pad = 5;
	local spacing = 8;
	local view = CreateScrollBoxListTreeListView(indent, pad, pad, pad, pad, spacing);

	view:SetElementFactory(function(factory, treeNode)
		local elementData = treeNode:GetData();
		if elementData.addonIndex then
			factory("AddonListEntryTemplate", AddonList_InitAddon);
		elseif elementData.category then
			factory("AddonListCategoryTemplate", AddonList_InitCategory);
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.SearchBox:HookScript("OnTextChanged", AddonList_Update);

	self.Dropdown:SetWidth(140);

	self.ForceLoad:SetScript("OnShow", function(btn)
		btn:SetChecked(not C_AddOns.IsAddonVersionCheckEnabled());
	end);
	self.ForceLoad:SetScript("OnClick", function(btn)
		if ( btn:GetChecked() ) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			C_AddOns.SetAddonVersionCheck(false);
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
			C_AddOns.SetAddonVersionCheck(true);
		end
		AddonList_Update();
	end);

	self.CancelButton:SetScript("OnClick", AddonList_OnCancel);
	self.OkayButton:SetScript("OnClick", AddonList_OnOkay);
	self.EnableAllButton:SetScript("OnClick", AddonList_EnableAll);
	self.DisableAllButton:SetScript("OnClick", AddonList_DisableAll);
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
		SetBasicMessageDialogText("Can't find checked texture");
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

function AddonList_InitAddon(entry, treeNode)
	local addonIndex = treeNode:GetData().addonIndex;
	local name, title, notes, _, _, security = C_AddOns.GetAddOnInfo(addonIndex);

	-- Get the character from the current list (nil is all characters)
	local character = GetAddonCharacter();

	-- Get loadable state for the selected character, rather than all characters which GetAddOnInfo checks
	local loadable, reason = C_AddOns.IsAddOnLoadable(addonIndex, character);

	local checkboxState = C_AddOns.GetAddOnEnableState(addonIndex, character);
	local enabled;
	if ( not InGlue() ) then
		enabled = (C_AddOns.GetAddOnEnableState(addonIndex, character) > Enum.AddOnEnableState.None);
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

	if ADDON_ACTIONS_BLOCKED[name] or (AddOnPerformance and AddOnPerformance:AddOnHasPerformanceWarning(name)) then
		titleText = titleText .. CreateSimpleTextureMarkup([[Interface\DialogFrame\DialogIcon-AlertNew-16]], 16, 16);
	end
	entry.Title:SetText(titleText);

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
	entry.title = title;
	entry.treeNode = treeNode;
end

function AddonList_Update()
	local dataProvider = CreateTreeDataProvider();

	local addonCategoryToTreeNode = {};
	local addonGroupToTreeNode = {};
	local addonGroupPendingChildren = {};

	local filterText = AddonList.SearchBox:GetText():lower();

	for i = 1, C_AddOns.GetNumAddOns() do
		-- Group is automatically set by C++ for addons with similar names and dependencies, but addons can override for any unusual cases.
		-- Every addon gets a group set, if there are no similar addons detected the group is simply the name of the addon.
		-- If this value is overriden, the value must EXACTLY match the name of the parent addon that this child addon will be grouped under.
		local group = C_AddOns.GetAddOnMetadata(i, "Group");

		-- Category is an addon defined field that allows for tree view organization of similar addons.
		local category = C_AddOns.GetAddOnMetadata(i, "Category");

		local name, title, _, _, _, security = C_AddOns.GetAddOnInfo(i);

		local titleL = title:lower();
		local groupL = group:lower();
		local categoryL = category and category:lower();

		local match = #filterText == 0 or titleL:find(filterText) or groupL:find(filterText) or (categoryL and categoryL:find(filterText));
		if match then
			local groupNode = addonGroupToTreeNode[group];

			-- If the group was already created, add as a child
			if groupNode then
				groupNode:Insert({ addonIndex = i });

			-- If this addon is the parent of a group, create the group node
			elseif name == group then
				if not category then
					-- Default secure addons to an Uncategorized category to separate them from user addons
					if security == "SECURE" then
						category = "Uncategorized";
					end
				end
				local categoryNode;
				if category then
					categoryNode = addonCategoryToTreeNode[category];
					if not categoryNode then
						categoryNode = dataProvider:Insert({ category = category });
						categoryNode:SetCollapsed(g_addonCategoriesCollapsed[category]);
						addonCategoryToTreeNode[category] = categoryNode;
					end
					groupNode = categoryNode:Insert({ addonIndex = i });
				else
					groupNode = dataProvider:Insert({ addonIndex = i });
				end

				addonGroupToTreeNode[group] = groupNode;

				local pending = addonGroupPendingChildren[group];
				if pending then
					for _, child in ipairs(pending) do
						groupNode:Insert(child);
					end

					addonGroupPendingChildren[group] = nil;
				end

			-- If children are sorted before the parent in a group, store the children temporarily until the parent is reached
			else
				table.insert(GetOrCreateTableEntry(addonGroupPendingChildren, group), { addonIndex = i });

			end
		end
	end

	-- Fallback to add any addons with invalid groups to the list so they don't disappear entirely
	for group, children in pairs(addonGroupPendingChildren) do
		for _, child in ipairs(children) do
			dataProvider:Insert(child);
		end
	end

	local function SortNodes(aNode, bNode)
		local a = aNode:GetData();
		local b = bNode:GetData();
		if a.category and b.category then
			return strcmputf8i(a.category, b.category) < 0;
		elseif a.addonIndex and b.addonIndex then
			return a.addonIndex < b.addonIndex
		else
			return a.category ~= nil;
		end
	end

	dataProvider:SetSortComparator(SortNodes);

	AddonList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	if ( not InGlue() ) then
		if ( AddonList_HasAnyChanged() ) then
			AddonList.OkayButton:SetText(RELOADUI);
			AddonList.shouldReload = true;
		else
			AddonList.OkayButton:SetText(OKAY);
			AddonList.shouldReload = false;
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

function AddonListMixin:OnShow()
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
					rootDescription:CreateRadio(characterInfo.name, IsSelected, SetSelected, characterInfo.guid);
				end
			end
		else
			local text = UnitName("player");
			local guid = UnitGUID("player");
			rootDescription:CreateRadio(text, IsSelected, SetSelected, guid);
		end
	end);

	AddonList_Update();
	self:UpdatePerformance();
end

function AddonListMixin:OnHide()
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

function AddonListMixin:OnUpdate()
	self:UpdatePerformance();
end

local function FormatProfilerPercent(pct)
	if pct >= 1 then
		return string.format("%.0f%%", pct);
	elseif pct >= 0.1 then
		return string.format("%.1f%%", pct);
	elseif pct >= 0.01 then
		return string.format("%.2f%%", pct);
	else
		return "0%";
	end
end

function AddonListMixin:GetAddonMetricPercent(addonName, formatString, metric)
	local appVal = C_AddOnProfiler.GetApplicationMetric(metric);
	local overallVal = C_AddOnProfiler.GetOverallMetric(metric);
	local addonVal = C_AddOnProfiler.GetAddOnMetric(addonName, metric);
	local relativeTotal = appVal - overallVal + addonVal;
	if relativeTotal <= 0 then
		return "";
	end
	local pct = addonVal / relativeTotal;
	local warningPct = GetCVarNumberOrDefault("addonPerformanceMsgWarning");
	local warningPctValid = warningPct > 0.0 and warningPct < 1.0;
	local text = formatString:format(FormatProfilerPercent(pct * 100.0), addonName);
	
	local showWarning = warningPctValid and pct > warningPct;
	if showWarning then
		text = RED_FONT_COLOR:WrapTextInColorCode(text) .. CreateSimpleTextureMarkup([[Interface\DialogFrame\DialogIcon-AlertNew-16]], 16, 16);
	end

	return text, showWarning;
end

function AddonListMixin:GetOverallMetric(formatString, metric)
	local appVal = C_AddOnProfiler.GetApplicationMetric(metric);
	if appVal <= 0 then
		return "";
	end

	local overallVal = C_AddOnProfiler.GetOverallMetric(metric);
	local pct = overallVal / appVal;
	local warningPct = GetCVarNumberOrDefault("addonPerformanceMsgWarning");
	local warningPctValid = warningPct > 0.0 and warningPct < 1.0;
	local text = formatString:format(FormatProfilerPercent(pct * 100.0));
	local showWarning = warningPctValid and pct > warningPct;
	return text, showWarning;
end

function AddonListMixin:UpdateOverallMetric(fontString, formatString, metric)
	local text, showWarning = self:GetOverallMetric(formatString, metric);

	if showWarning then
		text = RED_FONT_COLOR:WrapTextInColorCode(text) .. CreateSimpleTextureMarkup([[Interface\DialogFrame\DialogIcon-AlertNew-16]], 16, 16);
		fontString:SetScript("OnEnter", function(btn)
			AddonTooltip:SetOwner(btn, "ANCHOR_BOTTOM", 0, 0)
			AddonTooltip:SetText(ADDON_LIST_PERFORMANCE_WARNING_TOOLTIP);
		end);
		fontString:SetScript("OnLeave", function(btn)
			AddonTooltip:Hide();
		end);
	else
		fontString:SetScript("OnEnter", nil);
		fontString:SetScript("OnLeave", nil);
	end

	fontString:SetText(text);
end

function AddonListMixin:UpdatePerformance()
	local enabled = C_AddOnProfiler.IsEnabled();
	local perfUI = self.Performance;
	local showPerfUI = enabled and not InGlue();
	perfUI:SetShown(showPerfUI);

	if not showPerfUI then
		return;
	end

	self:UpdateOverallMetric(perfUI.Current, ADDON_LIST_PERFORMANCE_CURRENT_CPU, Enum.AddOnProfilerMetric.RecentAverageTime);
	self:UpdateOverallMetric(perfUI.Average, ADDON_LIST_PERFORMANCE_AVERAGE_CPU, Enum.AddOnProfilerMetric.SessionAverageTime);
	self:UpdateOverallMetric(perfUI.Peak, ADDON_LIST_PERFORMANCE_PEAK_CPU, Enum.AddOnProfilerMetric.PeakTime);
end

function AddonListMixin:UpdateAddOnMemoryUsage()
	-- Expensive call - update once when shown, not in OnUpdate, only once per 15 sec
	-- For addon performance display, which is not shown in glues
	if not InGlue() then
		local now = GetTime();
		local SECONDS_BETWEEN_MEMORY_UPDATE = 15;
		if not self.lastMemoryUpdate or now > self.lastMemoryUpdate + SECONDS_BETWEEN_MEMORY_UPDATE then
			self.lastMemoryUpdate = now;
			UpdateAddOnMemoryUsage();
		end
	end
end

function AddonList_HasOutOfDate()
	local hasOutOfDate = false;
	for i=1, C_AddOns.GetNumAddOns() do
		local name, title, notes, loadable, reason = C_AddOns.GetAddOnInfo(i);
		local character = nil;
		if (not InGlue()) then
			character = GetAddonCharacter();
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
			character = GetAddonCharacter();
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

local function AddonTooltip_AddAddonMetric(tooltip, addon, label, metric, warningOnly)
	local text, warning = AddonList:GetAddonMetricPercent(addon, label, metric);
	if warning or not warningOnly then
		GameTooltip_AddColoredLine(tooltip, text, WHITE_FONT_COLOR);
	end
end

function AddonTooltip_Update(owner)
	local name, title, notes, _, _, security = C_AddOns.GetAddOnInfo(owner:GetID());
	AddonTooltip:ClearLines();
	if ( security == "BANNED" ) then
		AddonTooltip:SetText(ADDON_BANNED_TOOLTIP);
	else
		local tooltipTitle = title or name;
		local version = C_AddOns.GetAddOnMetadata(owner:GetID(), "Version");
		AddonTooltip:AddDoubleLine(tooltipTitle, version);
		AddonTooltip:AddLine(notes, 1.0, 1.0, 1.0, true);
		AddonTooltip:AddLine(AddonTooltip_BuildDeps(C_AddOns.GetAddOnDependencies(owner:GetID())));
	end
	if ADDON_ACTIONS_BLOCKED[name] then
		AddonTooltip:AddLine(INTERFACE_ACTION_BLOCKED_TOOLTIP:format(ADDON_ACTIONS_BLOCKED[name]));
	end

	local loaded = C_AddOns.IsAddOnLoaded(name);
	if loaded and C_AddOnProfiler.IsEnabled() and not InGlue() then
		GameTooltip_AddBlankLineToTooltip(AddonTooltip);

		AddonTooltip_AddAddonMetric(AddonTooltip, name, ADDON_LIST_PERFORMANCE_AVERAGE_CPU, Enum.AddOnProfilerMetric.SessionAverageTime);

		local showWarningOnly = true;
		AddonTooltip_AddAddonMetric(AddonTooltip, name, ADDON_LIST_PERFORMANCE_CURRENT_CPU, Enum.AddOnProfilerMetric.RecentAverageTime, showWarningOnly);
		AddonTooltip_AddAddonMetric(AddonTooltip, name, ADDON_LIST_PERFORMANCE_PEAK_CPU, Enum.AddOnProfilerMetric.PeakTime, showWarningOnly);
		AddonTooltip_AddAddonMetric(AddonTooltip, name, ADDON_LIST_PERFORMANCE_ENCOUNTER_CPU, Enum.AddOnProfilerMetric.EncounterAverageTime, showWarningOnly);

		local mem = GetAddOnMemoryUsage(name);
		if mem > 0 then
			if mem > 1024 then
				GameTooltip_AddColoredLine(AddonTooltip, ADDON_LIST_PERFORMANCE_MEMORY_MB:format(mem / 1024), WHITE_FONT_COLOR);
			else
				GameTooltip_AddColoredLine(AddonTooltip, ADDON_LIST_PERFORMANCE_MEMORY_KB:format(mem), WHITE_FONT_COLOR);
			end
		end
	end

	AddonTooltip:Show()
end

function AddonTooltip_ActionBlocked(addon)
	ADDON_ACTIONS_BLOCKED[addon] = (ADDON_ACTIONS_BLOCKED[addon] or 0) + 1;
end

AddonCategoryCollapseExpandMixin = {};

function AddonCategoryCollapseExpandMixin:SetTreeNode(treeNode)
	self.treeNode = treeNode;
end

function AddonCategoryCollapseExpandMixin:OnClick(button)
	if button == "LeftButton" then
		self:ToggleState();
	end
end

function AddonCategoryCollapseExpandMixin:ToggleState()
	local newCollapsed = self.treeNode:ToggleCollapsed(TreeDataProviderConstants.RetainChildCollapse, TreeDataProviderConstants.DoInvalidation);
	g_addonCategoriesCollapsed[self.treeNode:GetData().category] = newCollapsed and true or nil;
	self:UpdateState();
end

function AddonCategoryCollapseExpandMixin:UpdateState()
	local isCollapsed = self.treeNode:IsCollapsed();

	local arrowRotation = isCollapsed and PI or PI / 2.0;
	self.Normal:SetRotation(arrowRotation);
	self.Highlight:SetRotation(arrowRotation);
	self.Pushed:SetRotation(arrowRotation);
end

AddonListNodeMixin = { };

function AddonListNodeMixin:OnClick(button)
	if button == "LeftButton" then
		local data = self.treeNode:GetData();
		if data.category then
			self.CollapseExpand:ToggleState();
		elseif data.addonIndex then
			self.Enabled:Click();
		end
	elseif button == "RightButton" then
		MenuUtil.CreateContextMenu(nil, function(owner, rootDescription)
			rootDescription:SetTag("MENU_ADDON_LIST_ENTRY");

			rootDescription:CreateTitle(self.title);

			local isAddon = self.treeNode:GetData().addonIndex;
			local hasChildren = #self.treeNode.nodes > 0;

			if isAddon then
				rootDescription:CreateButton(ADDON_LIST_ENABLE_DEPENDENCIES, function()
					self:SetEnabledDependencies(true);
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
				end);
			end
			if hasChildren then
				rootDescription:CreateButton(isAddon and ADDON_LIST_ENABLE_GROUP or ADDON_LIST_ENABLE_CATEGORY, function()
					self:SetEnabledAll(true);
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
				end);
				rootDescription:CreateButton(isAddon and ADDON_LIST_DISABLE_GROUP or ADDON_LIST_DISABLE_CATEGORY, function()
					self:SetEnabledAll(false);
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
				end);
			end
			rootDescription:CreateButton(hasChildren and ADDON_LIST_RESET_ALL_TO_DEFAULT or ADDON_LIST_RESET_TO_DEFAULT, function()
				self:SetEnabledAll(nil);
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
			end);
		end);
	end
end

local function AddonListEntry_SetEnabled(index, character, enabled)
	if enabled == nil then
		enabled = C_AddOns.IsAddOnDefaultEnabled(index);
	end

	if enabled then
		C_AddOns.EnableAddOn(index, character);
	else
		C_AddOns.DisableAddOn(index, character);
	end
end

function AddonListNodeMixin:SetEnabledAll(enabled)
	local character = GetAddonCharacter();

	local addonIndex = self.treeNode:GetData().addonIndex;
	if addonIndex then
		AddonListEntry_SetEnabled(addonIndex, character, enabled);
	end

	for _, child in ipairs(self.treeNode.nodes) do
		local index = child:GetData().addonIndex;
		AddonListEntry_SetEnabled(index, character, enabled);
	end

	AddonList_Update();
end

AddonListCategoryMixin = CreateFromMixins(AddonListNodeMixin);
AddonListEntryMixin = CreateFromMixins(AddonListNodeMixin);

function AddonListEntryMixin:OnLoad()
	self:SetScript("OnEnter", function()
		AddonTooltip:SetOwner(self, "ANCHOR_RIGHT", -270, 0);

		AddonList:UpdateAddOnMemoryUsage()

		AddonTooltip_Update(self);
		AddonTooltip:Show();

		self:SetScript("OnUpdate", function()
			AddonTooltip_Update(self);
		end);
	end);
	self:SetScript("OnLeave", function()
		AddonTooltip:Hide();
		self:SetScript("OnUpdate", nil);
	end);

	self.LoadAddonButton:SetScript("OnClick", function()
		AddonList_LoadAddOn(self:GetID());
	end);

	self.Enabled:SetScript("OnClick", function(btn)
		AddonList_Enable(self:GetID(), btn:GetChecked());
	end);
	self.Enabled:SetScript("OnEnter", function(btn)
		if btn.tooltip then
			AddonTooltip:SetOwner(btn, "ANCHOR_RIGHT", -270, 0)
			AddonTooltip:SetText(btn.tooltip);
			AddonTooltip:Show();
		end
	end);
	self.Enabled:SetScript("OnLeave", function()
		AddonTooltip:Hide();
	end);
end

function AddonListEntryMixin:SetEnabledDependencies(enabled)
	local character = GetAddonCharacter();

	local addonIndex = self.treeNode:GetData().addonIndex;
	if addonIndex then
		AddOnUtil.SetEnableStateForAddOnAndDependencies(addonIndex, character, enabled);
	end

	AddonList_Update();
end

