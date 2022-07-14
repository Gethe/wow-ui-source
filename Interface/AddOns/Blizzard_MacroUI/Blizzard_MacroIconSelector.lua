
MacroPopupFrameMixin = {};

function MacroPopupFrameMixin:OnLoad()
	local function MacroPopupFrameIconButtonInitializer(button, selectionIndex, icon)
		button:SetIconTexture(icon);
	end

	self.IconSelector:SetSetupCallback(MacroPopupFrameIconButtonInitializer);

	self.IconSelector:AdjustScrollBarOffsets(0, 18, -1);
end

function MacroPopupFrameMixin:OnShow()
	MacroPopupEditBox:SetFocus();

	if ( self.mode == "new" ) then
		MacroFrameText:Hide();
	end

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	self.iconDataProvider = self:GetMacroFrame():RefreshIconDataProvider();
	self:Update();
	MacroPopupOkayButton_Update();

	-- Disable Buttons
	MacroEditButton:Disable();
	MacroDeleteButton:Disable();
	MacroNewButton:Disable();
	MacroFrameTab1:Disable();
	MacroFrameTab2:Disable();
end

function MacroPopupFrameMixin:OnHide()
	local macroFrame = self:GetMacroFrame();

	if ( self.mode == "new" ) then
		MacroFrameText:Show();
		MacroFrameText:SetFocus();
	end

	-- Enable Buttons
	MacroEditButton:Enable();
	MacroDeleteButton:Enable();

	local numAccountMacros, numCharacterMacros = GetNumMacros();
	local numMacros = macroFrame.macroBase and numAccountMacros or numCharacterMacros;
	MacroNewButton:SetEnabled(numMacros < macroFrame.macroMax);

	-- Enable tabs
	PanelTemplates_UpdateTabs(macroFrame);
end

function MacroPopupFrameMixin:Update()
	-- Determine whether we're creating a new macro or editing an existing one
	if self.mode == "new" then
		MacroPopupEditBox:SetText("");
		self.IconSelector:SetSelectedIndex(1);
	elseif self.mode == "edit" then
		local macroFrame = self:GetMacroFrame();
		local actualIndex = macroFrame:GetMacroDataIndex(macroFrame:GetSelectedIndex());
		local name = GetMacroInfo(actualIndex);
		MacroPopupEditBox:SetText(name);
		MacroPopupEditBox:HighlightText();

		local texture = MacroFrame.SelectedMacroButton:GetIconTexture();
		self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(texture));
	end

	local getSelection = GenerateClosure(self.GetIconByIndex, self);
	local getNumSelections = GenerateClosure(self.GetNumIcons, self);
	self.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections);
	self.IconSelector:ScrollToSelectedIndex();
end

function MacroPopupFrameMixin:GetIconByIndex(index)
	return self.iconDataProvider:GetIconByIndex(index);
end

function MacroPopupFrameMixin:GetIndexOfIcon(icon)
	return self.iconDataProvider:GetIndexOfIcon(icon);
end

function MacroPopupFrameMixin:GetNumIcons()
	return self.iconDataProvider:GetNumIcons();
end

function MacroPopupFrameMixin:GetSelectedIndex()
	return self.IconSelector:GetSelectedIndex();
end

function MacroPopupFrameMixin:GetMacroFrame()
	return MacroFrame;
end

function MacroPopupFrame_CancelEdit()
	MacroPopupFrame:Hide();

	MacroFrame:UpdateButtons();
end

function MacroPopupOkayButton_Update()
	local text = MacroPopupEditBox:GetText();
	text = string.gsub(text, "\"", "");
	if strlen(text) > 0 then
		MacroPopupFrame.BorderBox.OkayButton:Enable();
	else
		MacroPopupFrame.BorderBox.OkayButton:Disable();
	end
	if MacroPopupFrame.mode == "edit" and (strlen(text) > 0) then
		MacroPopupFrame.BorderBox.OkayButton:Enable();
	end
end

function MacroPopupOkayButton_OnClick(self, button)
	local index = 1
	local iconTexture = MacroPopupFrame:GetIconByIndex(MacroPopupFrame:GetSelectedIndex());

	-- When saving macro textures, we strip off the leading folder structure.
	if type(iconTexture) == "string" then
		iconTexture = string.gsub(iconTexture, [[INTERFACE\ICONS\]], "");
	end

	local text = MacroPopupEditBox:GetText();
	text = string.gsub(text, "\"", "");
	if ( MacroPopupFrame.mode == "new" ) then
		local isCharacterMacro = MacroFrame.macroBase > 0;
		index = CreateMacro(text, iconTexture, nil, isCharacterMacro) - MacroFrame.macroBase;
	elseif ( MacroPopupFrame.mode == "edit" ) then
		local actualIndex = MacroFrame:GetMacroDataIndex(MacroFrame:GetSelectedIndex());
		index = EditMacro(actualIndex, text, iconTexture) - MacroFrame.macroBase;
	end

	MacroPopupFrame:Hide();

	MacroFrame:SelectMacro(index);

	local retainScrollPosition = true;
	MacroFrame:Update(retainScrollPosition);
end
