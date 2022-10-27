local function CallDefaultOnFrame(frame)
	if frame.OnDefault then
		frame:OnDefault();
	end
end

local function CallRefreshOnFrame(frame)
	if frame.OnRefresh then
		frame:OnRefresh();
	end
end

local securecallfunction = securecallfunction;
local pairs = pairs;

-- Matches a similar function reused in multiple places
local function EnumerateTaintedKeysTable(tableToIterate)
	local pairsIterator, enumerateTable, initialIteratorKey = securecallfunction(pairs, tableToIterate);
	local function IteratorFunction(tbl, key)
		return securecallfunction(pairsIterator, tbl, key);
	end

	return IteratorFunction, enumerateTable, initialIteratorKey;
end

SettingsPanelMixin = {};

function SettingsPanelMixin:OnLoad()
	self.settings = {};
	self.categoryLayouts = {};
	self.modified = {};

	self.NineSlice.Text:SetText(SETTINGS_TITLE);

	self.tabsGroup = CreateRadioButtonGroup();

	self.tabsGroup:AddButtons({self.GameTab, self.AddOnsTab});
	self.tabsGroup:SelectAtIndex(1);
	self.tabsGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.OnTabSelected, self);

	self:SetParent(GetAppropriateTopLevelParent());

	local function closePanel()
		self:Close();
	end

	self.CloseButton.Text:SetText(SETTINGS_CLOSE);
	self.CloseButton:SetScript("OnClick", closePanel);
	self.onCloseCallback = closePanel;

	self.ApplyButton.Text:SetText(SETTINGS_APPLY);
	self.ApplyButton:SetScript("OnClick", function(button, buttonName, down)
		self:Commit();
	end);

	local settingsList = self:GetSettingsList();
	settingsList.Header.DefaultsButton.Text:SetText(SETTINGS_DEFAULTS);
	settingsList.Header.DefaultsButton:SetScript("OnClick", function(button, buttonName, down)
		ShowAppropriateDialog("GAME_SETTINGS_APPLY_DEFAULTS");
	end);

	self.SearchBox:HookScript("OnTextChanged", GenerateClosure(self.OnSearchTextChanged, self));

	self:GetCategoryList():RegisterCallback(SettingsCategoryListMixin.Event.OnCategorySelected, self.SelectCategory, self);

	settingsList.ScrollBox:SetScript("OnMouseWheel", function(scrollBox, delta)
		if not KeybindListener:OnForwardMouseWheel(delta) then
			ScrollControllerMixin.OnMouseWheel(scrollBox, delta);
		end
	end);

	self.Container.SettingsCanvas:SetScript("OnMouseWheel", nop);

	EventRegistry:RegisterCallback("KeybindListener.StoppedListening", self.OnKeybindStoppedListening, self);
	EventRegistry:RegisterCallback("KeybindListener.StartedListening", self.OnKeybindStartedListening, self);
	EventRegistry:RegisterCallback("KeybindListener.UnbindFailed", self.OnKeybindUnbindFailed, self);
	EventRegistry:RegisterCallback("KeybindListener.RebindFailed", self.OnKeybindRebindFailed, self);
	EventRegistry:RegisterCallback("KeybindListener.RebindSuccess", self.OnKeybindRebindSuccess, self);

	CVarCallbackRegistry:RegisterCVarChangedCallback(self.OnCVarChanged, self);

	self:RegisterEvent("UPDATE_BINDINGS");
end

function SettingsPanelMixin:OnAttributeChanged(name, value)
	if name == SettingsInbound.OpenToCategoryAttribute then
		local categoryID, scrollToElementName = securecallfunction(unpack, value);
		local successful = self:OpenToCategory(categoryID, scrollToElementName);
		self:SetSecureAttributeResults(successful);
	elseif name == SettingsInbound.RegisterCategoryAttribute then
		local category, group, addon = securecallfunction(unpack, value, 1, 3);
		self:RegisterCategory(category, group, addon);
	elseif name == SettingsInbound.RegisterVerticalLayoutCategoryAttribute then
		local category = CreateAndInitFromMixin(SettingsCategoryMixin, value);
		local layout = CreateVerticalLayout();
		self:AssignLayoutToCategory(category, layout);
		self:SetSecureAttributeResults(category, layout);
	elseif name == SettingsInbound.RegisterVerticalLayoutSubcategoryAttribute then
		local parentCategory, categoryName = securecallfunction(unpack, value);

		-- Use SettingsCategoryMixin.CreateSubcategory to avoid taint.
		local subcategory = securecallfunction(SettingsCategoryMixin.CreateSubcategory, parentCategory, categoryName);
		local layout = CreateVerticalLayout();
		self:AssignLayoutToCategory(subcategory, layout);
		self:SetSecureAttributeResults(subcategory, layout);
	elseif name == SettingsInbound.RegisterCanvasLayoutCategoryAttribute then
		local frame, categoryName = securecallfunction(unpack, value);
		local category = CreateAndInitFromMixin(SettingsCategoryMixin, categoryName);
		local layout = CreateCanvasLayout(frame);
		self:AssignLayoutToCategory(category, layout);
		self:SetSecureAttributeResults(category, layout);
	elseif name == SettingsInbound.RegisterCanvasLayoutSubcategoryAttribute then
		local parentCategory, frame, categoryName = securecallfunction(unpack, value);

		-- Use SettingsCategoryMixin.CreateSubcategory to avoid taint.
		local subcategory = securecallfunction(SettingsCategoryMixin.CreateSubcategory, parentCategory, categoryName);
		local layout = CreateCanvasLayout(frame);
		self:AssignLayoutToCategory(subcategory, layout);
		self:SetSecureAttributeResults(subcategory, layout);
	elseif name == SettingsInbound.AssignLayoutToCategoryAttribute then
		local category, layout = securecallfunction(unpack, value);
		self:AssignLayoutToCategory(category, layout);
	elseif name == SettingsInbound.SetKeybindingsCategoryAttribute then
		self:SetKeybindingsCategory(value);
	elseif name == SettingsInbound.CreateAddOnSettingAttribute then
		local categoryTbl, settingName, variable, variableType, defaultValue = securecallfunction(unpack, value);
		local setting = CreateAndInitFromMixin(AddOnSettingMixin, settingName, variable, variableType, defaultValue);
		self:RegisterSetting(categoryTbl, setting);
		self:SetSecureAttributeResults(setting);
	elseif name == SettingsInbound.RegisterSettingAttribute then
		local categoryTbl, setting = securecallfunction(unpack, value);
		self:RegisterSetting(categoryTbl, setting);
	elseif name == SettingsInbound.RegisterInitializerAttribute then
		local category, initializer = securecallfunction(unpack, value);
		self:RegisterInitializer(category, initializer);
	elseif name == SettingsInbound.CreateSettingInitializerAttribute then
		local frameTemplate, data = securecallfunction(unpack, value);
		local initializer = CreateFromMixins(SettingsListElementInitializer);
		initializer:Init(frameTemplate, data);
		local setting = securecallfunction(SettingsListElementInitializer.GetSetting, initializer);
		if setting then
			local settingName = securecallfunction(setting.GetName, setting);
			initializer:AddSearchTags(settingName);
		end

		self:SetSecureAttributeResults(initializer);
	elseif name == SettingsInbound.OnSettingValueChangedAttribute then
		local setting, newValue, oldValue, originalValue = securecallfunction(unpack, value);
		self:OnSettingValueChanged(setting, newValue, oldValue, originalValue);
	end
end

function SettingsPanelMixin:SetSecureAttributeResults(...)
	self.secureAttributeResults = { ... };
end

function SettingsPanelMixin:GetSecureAttributeResults()
	return unpack(self.secureAttributeResults);
end

function SettingsPanelMixin:OnTabSelected(tab, tabIndex)
	self:GetCategoryList():SetCategorySet(tab.categorySet);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function SettingsPanelMixin:OnCVarChanged(cvar, cvarValue)
	-- This handler is intended only for cvar updates originating from the console or through the cvar script api.
	-- If the cvar was changed through the settings api, as recommended, this value will already be updated.
	local setting = self:GetSetting(cvar);
	if setting then
		-- The value is forced because the setting will always evaluate the current state of this
		-- cvar as unchanged due to the source of the value being the cvar that was just modified.
		-- This won't produce a recursive overflow because when setting the value legimately through
		-- the settings api, or through the controls, the setting will temporarily reject any changes
		-- to it's value.
		local force = true;
		-- Value is converted from the cvar string representation into a format the setting expects. Note
		-- this is done manually because we normally are strict about the value being the correct type.
		local value = securecallfunction(setting.ConvertValueInternal, setting, cvarValue);
		securecallfunction(setting.SetValue, setting, value, force);
	end
end

function SettingsPanelMixin:OnEvent(event, ...)
	if event == "UPDATE_BINDINGS" then
		self:RenewKeybinds();
	end
end

function SettingsPanelMixin:OnShow()
	if not self:GetCurrentCategory() then
		self:SelectFirstCategory();
	end

	-- Checks for if there are any categories to show on the AddOnsTab 
	local categories = self:GetCategoryList();
	local showTabs = false;
	for _, category in ipairs(categories.allCategories) do
		if category.categorySet == Settings.CategorySet.AddOns then
			showTabs = true;
			break;
		end
	end

	if not showTabs then
		self.GameTab:Hide();
		self.AddOnsTab:Hide();
	end

	-- WOW10-16900
	if IsOnGlueScreen() then
		self:SetFrameStrata("DIALOG");
		GlueParent_AddModalFrame(self);

		self.NineSlice.Text:SetText(SYSTEMOPTIONS_MENU);
	else
		self.NineSlice.Text:SetText(SETTINGS_TITLE);
	end

	self:CheckApplyButton();

	self:CallRefreshOnCanvases();
	self:CheckTutorials(); 
end

function SettingsPanelMixin:CheckTutorials()
	if self.SearchBox:IsShown() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SETTINGS_SEARCH) then
		local searchBoxTutorial = 
		{
			text = SETTINGS_SEARCH_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_SETTINGS_SEARCH,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			useParentStrata = true,
			offsetX = 4,
		}
		HelpTip:Show(self.SearchBox, searchBoxTutorial);
	end
end

function SettingsPanelMixin:Flush()
	KeybindListener:StopListening();

	self:ClearOutputText();
	self:ClearSearchBox();
	self:WipeModifiedTable();
end

function SettingsPanelMixin:OnHide()
	self:Flush();

	if IsOnGlueScreen() then
		GlueParent_RemoveModalFrame(self);
		return;
	end

	local checked = Settings.GetValue("PROXY_CHARACTER_SPECIFIC_BINDINGS");
	local bindingSet = checked and Enum.BindingSet.Character or Enum.BindingSet.Account;
	SaveBindings(bindingSet);
end

function SettingsPanelMixin:Commit(unrevertable)
	self:CommitCanvases();
	self:CommitSettings(unrevertable);
	self:CommitBindings();
	self:WipeModifiedTable();
end

function SettingsPanelMixin:Close(skipTransitionBackToOpeningPanel)
	if self:HasUnappliedSettings() then
		ShowAppropriateDialog("GAME_SETTINGS_CONFIRM_DISCARD");
	else
		self:ExitWithCommit(skipTransitionBackToOpeningPanel);
	end
end

function SettingsPanelMixin:ExitWithoutCommit()
	for setting, record in pairs(self.modified) do
		-- The settings under affect of IgnoreApply flag shouldn't be in the self.modified table after having been applied
		-- Needs bug investigation
		if (securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.Revertable) or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.Apply)) and not securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.IgnoreApply) then
			securecallfunction(setting.Revert, setting);
		end
	end

	self:Flush();
	self:TransitionBackOpeningPanel();
end

function SettingsPanelMixin:ExitWithCommit(skipTransitionBackToOpeningPanel)
	local unrevertable = true;
	self:Commit(unrevertable);

	if skipTransitionBackToOpeningPanel then
		HideUIPanel(self);
	else
		self:TransitionBackOpeningPanel();
	end
end

function SettingsPanelMixin:TransitionBackOpeningPanel()
	HideUIPanel(self);

	if not IsOnGlueScreen() then
		if EditModeManagerFrame:IsEditModeActive() then
			ShowUIPanel(EditModeManagerFrame);
		else
			ToggleGameMenu();
		end
	end
end

function SettingsPanelMixin:Open()
	self:WipeModifiedTable();
	ShowUIPanel(SettingsPanel);
end

function SettingsPanelMixin:OpenToCategory(categoryID, scrollToElementName)
	self:Open();

	local categoryTbl = self:GetCategoryList():GetCategory(categoryID);
	if categoryTbl then
		self:SelectCategory(categoryTbl);

		if scrollToElementName then
			self:GetSettingsList():ScrollToElementByName(scrollToElementName);
		end
	end
	return categoryTbl ~= nil;
end

function SettingsPanelMixin:SetKeybindingsCategory(category)
	self.keybindingsCategory = category;
end

function SettingsPanelMixin:CommitBindings()
	if not IsOnGlueScreen() then
		SaveBindings(GetCurrentBindingSet());

		local shouldSave = true;
		SaveAllCustomBindings(shouldSave);
	end
end

function SettingsPanelMixin:CommitSettings(unrevertable)
	self.revertableSettings = {};

	local saveBindings = false;
	local gxRestart = false;
	local windowUpdate = false;

	local commits = {};
	for setting, record in pairs(self.modified) do
		table.insert(commits, setting);
	end

	-- Commit order is necessary under rare circumstances where we need to guarantee that
	-- a particular option is changed before another, such as the case with display mode
	-- and resolution lists. Since the display mode dictates the resolution options, the
	-- display mode always needs to be applied first, especially in the scenario where display
	-- mode is being reverted.
	table.sort(commits, function(lhs, rhs)
		return lhs:GetCommitOrder() < rhs:GetCommitOrder();
	end);

	for index, setting in ipairs(commits) do
		saveBindings = saveBindings or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.SaveBindings);
		gxRestart = gxRestart or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.GxRestart);
		windowUpdate = windowUpdate or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.UpdateWindow);
		
		if not unrevertable then
			if securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.Revertable) then
				local originalValue = securecallfunction(setting.GetOriginalValue, setting);
				table.insert(self.revertableSettings, {setting = setting, originalValue = originalValue});
			end
		end
		
		securecallfunction(setting.Commit, setting);
	end
	
	self:FinalizeCommit(saveBindings, gxRestart, windowUpdate);

	if #self.revertableSettings > 0 then
		local duration = 8.0;
		ShowAppropriateDialog("GAME_SETTINGS_TIMED_CONFIRMATION", nil, nil, duration);
		local function Timer()
			self:RevertSettings();
			HideAppropriateDialog("GAME_SETTINGS_TIMED_CONFIRMATION");
		end
		self.Timer = C_Timer.NewTimer(duration, Timer);
	end
end

function SettingsPanelMixin:FinalizeCommit(saveBindings, gxRestart, windowUpdate)
	if saveBindings then
		SaveBindings(GetCurrentBindingSet());
	end

	if gxRestart then
		RestartGx();
	end
	
	if windowUpdate then
		UpdateWindow();
	end
end

function SettingsPanelMixin:DiscardRevertableSettings()
	self.revertableSettings = nil;
	self:WipeModifiedTable();
	self:CancelPendingRevertTimer();
end

function SettingsPanelMixin:RevertSettings()
	local saveBindings = false;
	local gxRestart = false;
	local windowUpdate = false;

	for index, data in ipairs(self.revertableSettings) do
		local setting = data.setting;
		saveBindings = saveBindings or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.SaveBindings);
		gxRestart = gxRestart or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.GxRestart);
		windowUpdate = windowUpdate or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.UpdateWindow);

		local originalValue = data.originalValue;
		securecallfunction(setting.SetValue, setting, originalValue);
		securecallfunction(setting.Commit, setting);
	end

	self:WipeModifiedTable();
	self:CancelPendingRevertTimer();
	self:FinalizeCommit(saveBindings, gxRestart, windowUpdate);
end

function SettingsPanelMixin:CancelPendingRevertTimer()
	if self.Timer then
		self.Timer:Cancel();
		self.Timer = nil;
	end
end

function SettingsPanelMixin:SetAllSettingsToDefaults()
	local saveBindings = false;
	local gxRestart = false;
	local windowUpdate = false;

	for setting, category in pairs(self.settings) do
		if securecallfunction(setting.SetValueToDefault, setting) then
			saveBindings = saveBindings or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.SaveBindings);
			gxRestart = gxRestart or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.GxRestart);
			windowUpdate = windowUpdate or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.UpdateWindow);
		end
	end

	self:CallDefaultOnCanvases();
	self:WipeModifiedTable();
	self:CheckApplyButton();
	self:FinalizeCommit(saveBindings, gxRestart, windowUpdate);
	
	Settings.SafeLoadBindings(Enum.BindingSet.Default);
end

function SettingsPanelMixin:SetCurrentCategorySettingsToDefaults()
	local saveBindings = false;
	local gxRestart = false;
	local windowUpdate = false;

	local currentCategory = self:GetCurrentCategory();
	for setting, category in pairs(self.settings) do
		if category == currentCategory then
			if securecallfunction(setting.SetValueToDefault, setting) then
				saveBindings = saveBindings or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.SaveBindings);
				gxRestart = gxRestart or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.GxRestart);
				windowUpdate = windowUpdate or securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.UpdateWindow);
			end
			self.modified[setting] = nil;
		end
	end

	for _, category in ipairs(self:GetAllCategories()) do
		if category == currentCategory then
			local layout = self:GetLayout(category);
			local layoutType = layout:GetLayoutType();
			if layoutType == SettingsLayoutMixin.LayoutType.Canvas then
				local frame = layout:GetFrame();
				securecallfunction(CallDefaultOnFrame, frame);
			end
		end
	end

	self:FinalizeCommit(saveBindings, gxRestart, windowUpdate);

	self:CheckApplyButton();

	if currentCategory == self.keybindingsCategory then
		Settings.SafeLoadBindings(Enum.BindingSet.Default);
	end
end

function SettingsPanelMixin:HasUnappliedSettings()
	for setting in pairs(self.modified) do
		if securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.Apply) and not securecallfunction(setting.HasCommitFlag, setting, Settings.CommitFlag.IgnoreApply) then
			return true;
		end
	end
	return false;
end

function SettingsPanelMixin:CheckApplyButton()
	self:SetApplyButtonEnabled(self:HasUnappliedSettings());
end

function SettingsPanelMixin:ForEachCanvas(func)
	local function CallOnCanvases(index, category, func)
		local layout = self:GetLayout(category);
		if layout:GetLayoutType() == SettingsLayoutMixin.LayoutType.Canvas then
			xpcall(func, CallErrorHandler, layout:GetFrame());
		end

		local subcategories = securecallfunction(category.GetSubcategories, category);
		secureexecuterange(subcategories, CallOnCanvases, func);
	end

	local allCategories = securecallfunction(self.GetAllCategories, self);
	secureexecuterange(allCategories, CallOnCanvases, func);
end

function SettingsPanelMixin:SetApplyButtonEnabled(enabled)
	self.ApplyButton:SetEnabled(enabled);
	self.ApplyButton:SetShown(enabled);
end

function SettingsPanelMixin:WipeModifiedTable()
	wipe(self.modified);
	self:CheckApplyButton();
end

function SettingsPanelMixin:CommitCanvases()
	self:ForEachCanvas(function(frame)
		if frame.OnCommit then
			frame:OnCommit();
		end
	end);
end

function SettingsPanelMixin:CallDefaultOnCanvases()
	self:ForEachCanvas(function(frame)
		CallDefaultOnFrame(frame);
	end);
end

function SettingsPanelMixin:CallRefreshOnCanvases()
	self:ForEachCanvas(function(frame)
		CallRefreshOnFrame(frame);
	end);
end

function SettingsPanelMixin:FindInitializersMatchingSearchText(searchText)
	searchText = searchText:upper();

	local words = { searchText };
	for word in string.gmatch(searchText, "([^, ]+)") do
		table.insert(words, word);
	end

	local matches = {};
	local function ParseCategory(category, parentCategory)
		local layout = self:GetLayout(category);
		local redirectCategory = category.redirectCategory or category;
		if layout:GetLayoutType() == SettingsLayoutMixin.LayoutType.Vertical then
			for _, initializer in layout:EnumerateInitializers() do
				local result = initializer:MatchesSearchTags(words);
				if result and initializer:ShouldShow() then
					if not matches[result] then
						matches[result] = {};
					end

					table.insert(matches[result], { initializer = initializer, category = redirectCategory });
				end
			end
		end
	end

	for index, category in ipairs(self:GetAllCategories()) do
		ParseCategory(category);

		for index, subcategory in EnumerateTaintedKeysTable(category:GetSubcategories()) do
			ParseCategory(subcategory, category);
		end
	end

	local matchScores = GetKeysArray(matches);
	table.sort(matchScores, function(a, b) return a > b end);

	local initializers = {};
	local found = {};
	for _, score in ipairs(matchScores) do
		for _, match in ipairs(matches[score]) do
			local category = match.category;
			if not found[category] then
				found[category] = true;

				table.insert(initializers, CreateSettingsListSearchCategoryInitializer(category));
			end

			table.insert(initializers, match.initializer);
		end
	end

	return initializers;
end


function SettingsPanelMixin:OnSearchTextChanged()
	local initializing = (self.searchText == nil);

	local text = self.SearchBox:GetText();
	if text == self.searchText then
		return;
	end

	self.searchText = text;

	if initializing then
		return;
	end

	if not self.SearchBox:HasText()then
		self:DisplayCategory(self:GetCurrentCategory());
		local settingsList = self:GetSettingsList();
		settingsList.Header.DefaultsButton:Show();
	elseif text and string.len(text) > 0 then
		local initializers = self:FindInitializersMatchingSearchText(text);
		local layout = CreateVerticalLayout();

		local added = {};
		local list = {};
		for _, initializer in ipairs(initializers) do
			local parentInitializer = initializer.parentInitializer;
			if parentInitializer then
				if not added[parentInitializer] then
					added[parentInitializer] = true;
					layout:AddInitializer(parentInitializer);
				end
			end
		
			added[initializer] = true;
			layout:AddInitializer(initializer);
		end
		
		local settingsList = self:GetSettingsList();
		local searchSuccess = not layout:IsEmpty();
		if not searchSuccess then
			layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(SETTINGS_SEARCH_NOTHING_FOUND));
		end

		settingsList.Header.Title:SetText(SETTINGS_SEARCH_RESULTS);

		self:DisplayLayout(layout);

		settingsList.Header.DefaultsButton:SetShown(not searchSuccess);
	end
end

function SettingsPanelMixin:ClearSearchBox()
	self.SearchBox:SetText("");
end

function SettingsPanelMixin:RegisterSetting(category, setting)
	self.settings[setting] = category;

	local variable = securecallfunction(setting.GetVariable, setting);
	SettingsInbound.RegisterOnSettingValueChanged(variable);

	local value = securecallfunction(setting.GetValue, setting);
	SettingsInitializedRegistry:TriggerEvent(variable, value);
end

function SettingsPanelMixin:RegisterInitializer(category, initializer)
	local layout = self.categoryLayouts[category];
	layout:AddInitializer(initializer);
end

function SettingsPanelMixin:AssignLayoutToCategory(category, layout)
	self.categoryLayouts[category] = layout;
end

function SettingsPanelMixin:GetLayout(category)
	return self.categoryLayouts[category];
end

function SettingsPanelMixin:GetSetting(variable)
	for setting, category in pairs(self.settings) do
		local settingVariable = securecallfunction(setting.GetVariable, setting);
		if settingVariable == variable then
			return setting;
		end
	end
	return nil;
end

function SettingsPanelMixin:OnSettingValueChanged(setting, value, oldValue, originalValue)
	assert(value ~= nil);
	if not self:IsShown() then
		return;
	end

	local isModified = securecallfunction(setting.IsModified, setting);
	self.modified[setting] = isModified and setting or nil;
	securecallfunction(setting.UpdateIgnoreApplyFlag, setting);
	self:CheckApplyButton();
end

function SettingsPanelMixin:GetAllCategories()
	return self:GetCategoryList():GetAllCategories();
end

function SettingsPanelMixin:RegisterCategory(category, group, addon)
	self:GetCategoryList():AddCategory(category, group, addon);
end

function SettingsPanelMixin:GetCategory(categoryName)
	return self:GetCategoryList():GetCategory(categoryName);
end

function SettingsPanelMixin:GetOrCreateGroup(group, order)
	return self:GetCategoryList():GetOrCreateGroup(group, order);
end

function SettingsPanelMixin:SelectFirstCategory()
	local categories = self:GetAllCategories();
	if #categories > 0 then
		self:SelectCategory(categories[1]);
	end
end

function SettingsPanelMixin:SelectCategory(category, force)
	if force or (self:GetCurrentCategory() ~= category) then
		self:ClearSearchBox();
		self:ClearOutputText();
		self:DisplayCategory(category);
		self:SetCurrentCategory(category);
	end
end

function SettingsPanelMixin:SetCurrentCategory(category)
	local newMode = self:GetCategoryList():SetCurrentCategory(category);
	self.tabsGroup:SelectAtIndex(newMode);

	self:CheckApplyButton();
end

function SettingsPanelMixin:GetCategoryList()
	return self.CategoryList;
end

function SettingsPanelMixin:GetSettingsList()
	return self.Container.SettingsList;
end

function SettingsPanelMixin:GetSettingsCanvas()
	return self.Container.SettingsCanvas;
end

function SettingsPanelMixin:DisplayCategory(category)
	if not category then
		return;
	end
	
	local settingsList = self:GetSettingsList();
	settingsList.Header.Title:SetText(category:GetName());

	local layout = self:GetLayout(category);
	self:DisplayLayout(layout);
end

function SettingsPanelMixin:DisplayLayout(layout)
	if not layout then
		return;
	end

	local currentCategory = self:GetCurrentCategory();
	if currentCategory then
		local layout = self:GetLayout(currentCategory);
		if layout:GetLayoutType() == SettingsLayoutMixin.LayoutType.Canvas then
			local frame = layout:GetFrame();
			frame:SetParent(nil);
			frame:ClearAllPoints();
			frame:Hide();
		end
	end

	local settingsList = self:GetSettingsList();
	local settingsCanvas = self:GetSettingsCanvas();
	local layoutType = layout:GetLayoutType();
	if layoutType == SettingsLayoutMixin.LayoutType.Vertical then
		local initializers = securecallfunction(layout.GetInitializers, layout);
		settingsList:Display(initializers);
		settingsList:Show();
		settingsCanvas:Hide();
	elseif layoutType == SettingsLayoutMixin.LayoutType.Canvas then
		local frame = layout:GetFrame();
		frame:SetParent(settingsCanvas);
		frame:ClearAllPoints();

		local anchors = layout:GetAnchorPoints();
		if #anchors > 0 then
			for index, tbl in ipairs(anchors) do
				frame:SetPoint(tbl.p, tbl.x, tbl.y);
			end
		else
			frame:SetAllPoints(settingsCanvas);
		end

		frame:Show();

		securecallfunction(CallRefreshOnFrame, frame);

		settingsCanvas:Show();
		settingsList:Hide();
	end
end

function SettingsPanelMixin:GetCurrentCategory()
	return self:GetCategoryList():GetCurrentCategory();
end

function SettingsPanelMixin:RenewKeybinds()
	EventRegistry:TriggerEvent("Settings.UpdateKeybinds");
end

function SettingsPanelMixin:SetOutputText(text)
	self.OutputText:SetText(text);
end

function SettingsPanelMixin:ClearOutputText()
	self.OutputText:SetText(nil);
end

function SettingsPanelMixin:OnKeybindStoppedListening(action, slotIndex)
	self:RenewKeybinds();

	self.SearchBox:Enable();

	self.InputBlocker:Hide();
	self:GetSettingsList():SetInputBlockerShown(false);

	self:SetOutputText(nil);

	EventRegistry:TriggerEvent("Settings.UnparentBindingsToInputBlocker");
end

function SettingsPanelMixin:OnKeybindStartedListening(action, slotIndex)
	self.SearchBox:Disable();

	self.InputBlocker:Show();
	self.InputBlocker:SetFrameStrata("DIALOG");

	local settingsList = self:GetSettingsList();
	settingsList:SetInputBlockerShown(true);
	
	self:SetOutputText(SETTINGS_BIND_KEY_TO_COMMAND_OR_CANCEL:format(GetBindingName(action), GetBindingText("ESCAPE")));
	
	EventRegistry:TriggerEvent("Settings.ReparentBindingsToInputBlocker", settingsList:GetInputBlocker());
end

function SettingsPanelMixin:OnKeybindUnbindFailed(action, unbindAction, unbindSlotIndex)
	local errorFormat = unbindSlotIndex == 1 and PRIMARY_KEY_UNBOUND_ERROR or KEY_UNBOUND_ERROR;
	self:SetOutputText(errorFormat:format(GetBindingName(unbindAction)));
end

function SettingsPanelMixin:OnKeybindRebindFailed(action)
	self:SetOutputText(KEYBINDINGFRAME_MOUSEWHEEL_ERROR);
end

function SettingsPanelMixin:OnKeybindRebindSuccess(action)
	self:SetOutputText(KEY_BOUND);
end