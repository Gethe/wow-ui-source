
UIPanelWindows["MacroFrame"] = { area = "left", pushable = 1, whileDead = 1, width = PANEL_DEFAULT_WIDTH };

StaticPopupDialogs["CONFIRM_DELETE_SELECTED_MACRO"] = {
	text = CONFIRM_DELETE_MACRO,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		MacroFrame:DeleteMacro();
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1
};

function MacroFrame_Show()
	ShowUIPanel(MacroFrame);
end

function MacroFrame_SaveMacro()
	MacroFrame:SaveMacro();
end


MacroButtonMixin = {};

function MacroButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

function MacroButtonMixin:OnClick()
	SelectorButtonMixin.OnClick(self);

	if InClickBindingMode() and ClickBindingFrame:HasNewSlot() then
		local actualIndex = MacroFrame:GetMacroDataIndex(self:GetElementData());
		ClickBindingFrame:AddNewAction(Enum.ClickBindingType.Macro, actualIndex);
	end
end

function MacroButtonMixin:OnDragStart()
	local actualIndex = MacroFrame:GetMacroDataIndex(self:GetElementData());
	PickupMacro(actualIndex);
end


MacroFrameMixin = {};

function MacroFrameMixin:OnLoad()
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, 1);

	self.MacroSelector:AdjustScrollBarOffsets(MACRO_SCROLL_BAR_OFFSET_X, MACRO_SCROLL_BAR_OFFSET_TOP, MACRO_SCROLL_BAR_OFFSET_BOTTOM);

	local function MacroFrameInitMacroButton(macroButton, selectionIndex, name, texture, body)
		if name ~= nil then
			macroButton:SetIconTexture(texture);
			macroButton.Name:SetText(name);
			macroButton:Enable();
		else
			macroButton:SetIconTexture("");
			macroButton.Name:SetText("");
			macroButton:Disable();
		end
	end

	self.MacroSelector:SetSetupCallback(MacroFrameInitMacroButton);

	self.MacroSelector:SetCustomStride(6);
	self.MacroSelector:SetCustomPadding(5, 5, 5, 5, 13, 13);

	local function MacroFrameMacroButtonSelectedCallback(selectionIndex)
		MacroFrame:SaveMacro();
		MacroFrame:SelectMacro(selectionIndex);
		MacroPopupFrame:Hide();
		MacroFrameText:ClearFocus();
	end

	self.MacroSelector:SetSelectedCallback(MacroFrameMacroButtonSelectedCallback);

	self.SelectedMacroButton:SetScript("OnDragStart", function()
		local selectedMacroIndex = self:GetSelectedIndex();
		if selectedMacroIndex ~= nil then
			local actualIndex = self:GetMacroDataIndex(selectedMacroIndex);
			PickupMacro(actualIndex);
		end
	end)

	EventRegistry:RegisterCallback("ClickBindingFrame.UpdateFrames", self.UpdateButtons, self);
end

function MacroFrameMixin:OnShow()
	self:SetAccountMacros();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	UpdateMicroButtons();

	self:ChangeTab(1);
end

function MacroFrameMixin:OnHide()
	MacroPopupFrame:Hide();
	self:SaveMacro();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();

	if self.iconDataProvider ~= nil then
		self.iconDataProvider:Release();
		self.iconDataProvider = nil;
	end
end

function MacroFrameMixin:RefreshIconDataProvider()
	if self.iconDataProvider == nil then
		self.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Spellbook);
	end

	return self.iconDataProvider;
end

function MacroFrameMixin:SelectTab(tab)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local tabID = tab:GetID()
	self:ChangeTab(tabID);
end

function MacroFrameMixin:ChangeTab(tabID)
	PanelTemplates_SetTab(self, tabID);
	self:SaveMacro();
	if tabID == 1 then
		self:SetAccountMacros();
	elseif tabID == 2 then
		self:SetCharacterMacros();
	end
end

function MacroFrameMixin:SetAccountMacros()
	self.macroBase = 0;
	self.macroMax = MAX_ACCOUNT_MACROS;
	self:Update();
	self:SelectMacro(1);
end

function MacroFrameMixin:SetCharacterMacros()
	self.macroBase = MAX_ACCOUNT_MACROS;
	self.macroMax = MAX_CHARACTER_MACROS;
	self:Update();
	self:SelectMacro(1);
end

function MacroFrameMixin:Update()
	local useAccountMacros = PanelTemplates_GetSelectedTab(self) == 1;
	local numAccountMacros, numCharacterMacros = GetNumMacros();

	local function MacroFrameGetMacroInfo(selectionIndex)
		if selectionIndex > self.MacroSelector.numMacros then
			return nil;
		end

		local actualIndex = self:GetMacroDataIndex(selectionIndex);
		return GetMacroInfo(actualIndex);
	end

	local function MacroFrameGetNumMacros()
		return useAccountMacros and MAX_ACCOUNT_MACROS or MAX_CHARACTER_MACROS;
	end

	self.MacroSelector.numMacros = useAccountMacros and numAccountMacros or numCharacterMacros;
	self.MacroSelector:SetSelectionsDataProvider(MacroFrameGetMacroInfo, MacroFrameGetNumMacros);

	self:UpdateButtons();
end

function MacroFrameMixin:UpdateButtons()
	-- Macro Details
	local hasSelectedMacro = self:GetSelectedIndex() ~= nil;
	if hasSelectedMacro then
		self:ShowDetails();
		MacroDeleteButton:Enable();
	else
		self:HideDetails();
		MacroDeleteButton:Disable();
	end

	local inClickBinding = InClickBindingMode();

	--Update New Button
	local numMacros = self.MacroSelector.numMacros;
	MacroNewButton:SetEnabled(numMacros and (numMacros < self.macroMax) and not inClickBinding);

	-- Disable Buttons
	if ( MacroPopupFrame:IsShown() or inClickBinding ) then
		MacroEditButton:Disable();
		MacroDeleteButton:Disable();
	else
		MacroEditButton:Enable();
		MacroDeleteButton:Enable();
	end

	if not hasSelectedMacro then
		MacroDeleteButton:Disable();
	end

	-- Add disabled tooltip if in click binding mode
	local disabledInClickBinding = {
		MacroEditButton,
		MacroDeleteButton,
		MacroNewButton,
	};
	local onEnterFunction, onLeaveFunction;
	if ( inClickBinding ) then
		onEnterFunction = function(button)
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
			GameTooltip:AddLine(CLICK_BINDING_BUTTON_DISABLED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			GameTooltip:Show();
		end;
		onLeaveFunction = function()
			GameTooltip:Hide();
		end;
	end
	for _, button in ipairs(disabledInClickBinding) do
		button:SetScript("OnEnter", onEnterFunction);
		button:SetScript("OnLeave", onLeaveFunction);
	end

	self.MacroSelector:UpdateAllSelectedTextures();
end

function MacroFrameMixin:GetMacroDataIndex(index)
	return self.macroBase + index;
end

function MacroFrameSaveButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	MacroFrame:SaveMacro();

	local retainScrollPosition = true;
	MacroFrame:Update(retainScrollPosition);

	MacroPopupFrame:Hide();
	MacroFrameText:ClearFocus();
end

function MacroFrameCancelButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local retainScrollPosition = true;
	MacroFrame:Update(retainScrollPosition);

	MacroPopupFrame:Hide();
	MacroFrameText:ClearFocus();
end

function MacroFrameMixin:SelectMacro(index)
	if index then
		local macroCount = select(PanelTemplates_GetSelectedTab(self), GetNumMacros());
		if macroCount < index then
			index = nil;
		end
	end

	self.MacroSelector:SetSelectedIndex(index);

	if index then
		local actualIndex = self:GetMacroDataIndex(index);
		local name, texture, body = GetMacroInfo(actualIndex);
		if(name) then 
			MacroFrameSelectedMacroName:SetText(name);
			MacroFrameText:SetText(body);
			self.SelectedMacroButton.Icon:SetTexture(texture);
		end
	end

	self:UpdateButtons();
end

function MacroFrameMixin:GetSelectedIndex()
	return self.MacroSelector:GetSelectedIndex();
end

function MacroFrameMixin:DeleteMacro()
	local selectedMacroIndex = self:GetSelectedIndex();
	local actualIndex = self:GetMacroDataIndex(selectedMacroIndex);
	DeleteMacro(actualIndex);

	local macroCount = select(PanelTemplates_GetSelectedTab(self), GetNumMacros());
	local newMacroIndex = math.min(macroCount, selectedMacroIndex);
	self:SelectMacro(newMacroIndex > 0 and newMacroIndex or nil);

	local retainScrollPosition = true;
	self:Update(retainScrollPosition);

	MacroFrameText:ClearFocus();
end

function MacroNewButton_OnClick(self, button)
	MacroFrame:SaveMacro();
	MacroPopupFrame.mode = IconSelectorPopupFrameModes.New;
	MacroPopupFrame:Show();
end

function MacroEditButton_OnClick(self, button)
	MacroFrame:SaveMacro();
	MacroPopupFrame.mode = IconSelectorPopupFrameModes.Edit;
	MacroPopupFrame:Show();
end

function MacroFrameMixin:HideDetails()
	MacroEditButton:Hide();
	MacroFrameCharLimitText:Hide();
	MacroFrameText:Hide();
	MacroFrameSelectedMacroBackground:Hide();
	MacroFrameSelectedMacroName:Hide();
	self.SelectedMacroButton:Hide();
end

function MacroFrameMixin:ShowDetails()
	MacroEditButton:Show();
	MacroFrameCharLimitText:Show();
	MacroFrameEnterMacroText:Show();
	MacroFrameText:Show();
	MacroFrameSelectedMacroBackground:Show();
	MacroFrameSelectedMacroName:Show();
	self.SelectedMacroButton:Show();
end

function MacroFrameMixin:SaveMacro()
	local selectedMacroIndex = self:GetSelectedIndex();
	if self.textChanged and (selectedMacroIndex ~= nil) then
		local actualIndex = self:GetMacroDataIndex(selectedMacroIndex);
		EditMacro(actualIndex, nil, nil, MacroFrameText:GetText());
		self:SelectMacro(selectedMacroIndex); -- Make sure we update the selected icon art if needed (default overridden icon case).
		self.textChanged = nil;
	end
end
