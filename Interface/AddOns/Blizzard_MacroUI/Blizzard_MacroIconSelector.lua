MacroPopupFrameMixin = {};

function MacroPopupFrameMixin:OnShow()
	IconSelectorPopupFrameTemplateMixin.OnShow(self);
	self.BorderBox.IconSelectorEditBox:SetFocus();

	if ( self.mode == IconSelectorPopupFrameModes.New ) then
		MacroFrameText:Hide();
	end

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	self.iconDataProvider = self:GetMacroFrame():RefreshIconDataProvider();

	self:SetIconFilter(IconSelectorPopupFrameIconFilterTypes.All);

	self:Update();
	self.BorderBox.IconSelectorEditBox:OnTextChanged();

	local function OnIconSelected(selectionIndex, icon)
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon);

		-- Index is not yet set, but we know if an icon in IconSelector was selected it was in the list, so set directly.
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_CLICK);
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetFontObject(GameFontHighlightSmall);
	end
    self.IconSelector:SetSelectedCallback(OnIconSelected);

	-- Disable Buttons
	MacroEditButton:Disable();
	MacroDeleteButton:Disable();
	MacroNewButton:Disable();
	MacroFrameTab1:Disable();
	MacroFrameTab2:Disable();

	local isShown = true;
	self:UpdateMacroFramePanelWidth(isShown);
end

function MacroPopupFrameMixin:OnHide()
	IconSelectorPopupFrameTemplateMixin.OnHide(self);
	local macroFrame = self:GetMacroFrame();

	if ( self.mode == IconSelectorPopupFrameModes.New ) then
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

	local isShown = false;
	self:UpdateMacroFramePanelWidth(isShown);
end

function MacroPopupFrameMixin:Update()
	-- Determine whether we're creating a new macro or editing an existing one
	if ( self.mode == IconSelectorPopupFrameModes.New ) then
		self.BorderBox.IconSelectorEditBox:SetText("");
		local initialIndex = 1;
		self.IconSelector:SetSelectedIndex(initialIndex);
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self:GetIconByIndex(initialIndex));
	elseif ( self.mode == IconSelectorPopupFrameModes.Edit ) then
		local macroFrame = self:GetMacroFrame();
		local actualIndex = macroFrame:GetMacroDataIndex(macroFrame:GetSelectedIndex());
		local name = GetMacroInfo(actualIndex);
		self.BorderBox.IconSelectorEditBox:SetText(name);
		self.BorderBox.IconSelectorEditBox:HighlightText();

		local texture = macroFrame.SelectedMacroButton:GetIconTexture();
		self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(texture));
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(texture);
	end

	local getSelection = GenerateClosure(self.GetIconByIndex, self);
	local getNumSelections = GenerateClosure(self.GetNumIcons, self);
	self.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections);
	self.IconSelector:ScrollToSelectedIndex();

	self:SetSelectedIconText();
end

function MacroPopupFrameMixin:CancelButton_OnClick()
	IconSelectorPopupFrameTemplateMixin.CancelButton_OnClick(self);
	self:GetMacroFrame():UpdateButtons();
end

function MacroPopupFrameMixin:OkayButton_OnClick()
	IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick(self);

	local macroFrame = self:GetMacroFrame();

	local index = 1
	local iconTexture = self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture();
	local text = self.BorderBox.IconSelectorEditBox:GetText();

	text = string.gsub(text, "\"", "");
	if ( self.mode == IconSelectorPopupFrameModes.New ) then
		local isCharacterMacro = macroFrame.macroBase > 0;
		index = CreateMacro(text, iconTexture, nil, isCharacterMacro) - macroFrame.macroBase;
	elseif ( self.mode == IconSelectorPopupFrameModes.Edit ) then
		local actualIndex = macroFrame:GetMacroDataIndex(macroFrame:GetSelectedIndex());
		index = EditMacro(actualIndex, text, iconTexture) - macroFrame.macroBase;
	end

	macroFrame:SelectMacro(index);

	local retainScrollPosition = true;
	macroFrame:Update(retainScrollPosition);
end

function MacroPopupFrameMixin:GetMacroFrame()
	return MacroFrame;
end

function MacroPopupFrameMixin:UpdateMacroFramePanelWidth(shown)
	local macroFrame = self:GetMacroFrame();
	local width = macroFrame:GetWidth();
	if shown then
		local p, r, rp, x, y = self:GetPointByName("TOPLEFT");
		width = width + x + self:GetWidth();
	end

	SetUIPanelAttribute(macroFrame, "width", width);
	UpdateUIPanelPositions(macroFrame);
end