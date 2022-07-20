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

	CVarCallbackRegistry:RegisterCallback(CVarCallbackRegistry.Event.OnCVarChanged, self.OnCVarChanged, self);

	self:RegisterEvent("UPDATE_BINDINGS");
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
		local value = setting:ConvertValueInternal(cvarValue);
		setting:SetValue(value, force);
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

	-- WOW10-16900
	if IsOnGlueScreen() then
		self:SetFrameStrata("DIALOG");
		GlueParent_AddModalFrame(self);
	end

	self:CheckApplyButton();

	self:CallRefreshOnCanvases();
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
		if (setting:HasCommitFlag(Settings.CommitFlag.Revertable) or setting:HasCommitFlag(Settings.CommitFlag.Apply)) and not setting:HasCommitFlag(Settings.CommitFlag.IgnoreApply) then
			setting:Revert();
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

function SettingsPanelMixin:OpenToCategory(category, scrollToElementName)
	self:Open();

	local categoryTbl = self:GetCategoryList():GetCategory(category);
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
		saveBindings = saveBindings or setting:HasCommitFlag(Settings.CommitFlag.SaveBindings);
		gxRestart = gxRestart or setting:HasCommitFlag(Settings.CommitFlag.GxRestart);
		windowUpdate = windowUpdate or setting:HasCommitFlag(Settings.CommitFlag.UpdateWindow);
		
		if not unrevertable then
			if setting:HasCommitFlag(Settings.CommitFlag.Revertable) then
				local originalValue = setting:GetOriginalValue();
				table.insert(self.revertableSettings, {setting = setting, originalValue = originalValue});
			end
		end
		
		setting:Commit();
	end
	
	--print("saveBindings, gxRestart, windowUpdate", saveBindings, gxRestart, windowUpdate)
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
		saveBindings = saveBindings or setting:HasCommitFlag(Settings.CommitFlag.SaveBindings);
		gxRestart = gxRestart or setting:HasCommitFlag(Settings.CommitFlag.GxRestart);
		windowUpdate = windowUpdate or setting:HasCommitFlag(Settings.CommitFlag.UpdateWindow);

		local originalValue = data.originalValue;
		setting:SetValue(originalValue);
		setting:Commit();
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
		if setting:SetValueToDefault() then
			saveBindings = saveBindings or setting:HasCommitFlag(Settings.CommitFlag.SaveBindings);
			gxRestart = gxRestart or setting:HasCommitFlag(Settings.CommitFlag.GxRestart);
			windowUpdate = windowUpdate or setting:HasCommitFlag(Settings.CommitFlag.UpdateWindow);
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
			--local oldValue = setting:GetValue();
			if setting:SetValueToDefault() then
				--print("Defaulting", setting:GetName(), oldValue, setting:GetValue())
				saveBindings = saveBindings or setting:HasCommitFlag(Settings.CommitFlag.SaveBindings);
				gxRestart = gxRestart or setting:HasCommitFlag(Settings.CommitFlag.GxRestart);
				windowUpdate = windowUpdate or setting:HasCommitFlag(Settings.CommitFlag.UpdateWindow);
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
				CallDefaultOnFrame(frame);
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
		if setting:HasCommitFlag(Settings.CommitFlag.Apply) and not setting:HasCommitFlag(Settings.CommitFlag.IgnoreApply) then
			return true;
		end
	end
	return false;
end

function SettingsPanelMixin:CheckApplyButton()
	self:SetApplyButtonEnabled(self:HasUnappliedSettings());
end

function SettingsPanelMixin:ForEachCanvas(func)
	local function CallOnCanvases(categories, func)
		for _, category in ipairs(categories) do
			local layout = self:GetLayout(category);
		   	if layout:GetLayoutType() == SettingsLayoutMixin.LayoutType.Canvas then
		   		func(layout:GetFrame());
		   	end

			CallOnCanvases(category:GetSubcategories(), func);
		end
	end

	CallOnCanvases(self:GetAllCategories(), func);
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
	local words = {};
	for word in string.gmatch(searchText:upper(), "([^, ]+)") do
		table.insert(words, word);
	end

	local initializers = {};
	local found = {};
	local function ParseCategory(category, parentCategory)
		local layout = self:GetLayout(category);
		local redirectCategory = category.redirectCategory or category;
		if layout:GetLayoutType() == SettingsLayoutMixin.LayoutType.Vertical then
			for _, initializer in layout:EnumerateInitializers() do
				if initializer:MatchesSearchTags(words) then
					if not found[redirectCategory] then
						found[redirectCategory] = true;

						table.insert(initializers, CreateSettingsListSearchCategoryInitializer(redirectCategory));
					end

					table.insert(initializers, initializer);
				end
			end
		end
	end

	for index, category in ipairs(self:GetAllCategories()) do
		ParseCategory(category);

		for index, subcategory in ipairs(category:GetSubcategories()) do
			ParseCategory(subcategory, category);
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
		if searchSuccess then
			settingsList.Header.Title:SetText(SETTINGS_SEARCH_RESULTS);

			self:DisplayLayout(layout);
		else
			self:DisplayCategory(self:GetCurrentCategory());
		end

		settingsList.Header.DefaultsButton:SetShown(not searchSuccess);
	end
end

function SettingsPanelMixin:ClearSearchBox()
	self.SearchBox:SetText("");
end

function SettingsPanelMixin:RegisterSetting(category, setting)
	self.settings[setting] = category;
	Settings.SetOnValueChangedCallback(setting:GetVariable(), self.OnSettingValueChanged, self);
	SettingsInitializedRegistry:TriggerEvent(setting:GetVariable(), setting:GetValue());
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
		if setting:GetVariable() == variable then
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

	self.modified[setting] = setting:IsModified() and setting or nil;
	setting:UpdateIgnoreApplyFlag();
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
		settingsList:Display(layout:GetInitializers());
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

		CallRefreshOnFrame(frame);

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