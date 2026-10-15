local characterCopyRegions = {
	[1] = NORTH_AMERICA,
	[2] = KOREA,
	[3] = EUROPE,
	[4] = TAIWAN,
	[5] = CHINA,
};

-- COPY CHARACTER
StaticPopupDialogs["COPY_CHARACTER"] = {
	text = "",
	button1 = OKAY,
	button2 = CANCEL,
	escapeHides = true,
	OnAccept = function(dialog, data)
		CopyCharacterFromLive();
	end,
}

StaticPopupDialogs["COPY_ACCOUNT_DATA"] = {
	text = COPY_ACCOUNT_CONFIRM,
	button1 = OKAY,
	button2 = CANCEL,
	escapeHides = true,
	OnAccept = function(dialog, data)
		CopyCharacter_AccountDataFromLive();
	end,
}

StaticPopupDialogs["COPY_KEY_BINDINGS"] = {
	text = COPY_KEY_BINDINGS_CONFIRM,
	button1 = OKAY,
	button2 = CANCEL,
	escapeHides = true,
	OnAccept = function(dialog, data)
		CopyCharacter_KeyBindingsFromLive();
	end,
}

function CopyCharacterFromLive()
	if ( not IsGMClient() ) then
		CopyAccountCharacterFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex);
	else
		CopyAccountCharacterFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex, CopyCharacterFrame.Surname:GetText(), CopyCharacterFrame.CharacterName:GetText());
	end
	StaticPopup_Show("COPY_IN_PROGRESS");
end

function CopyCharacter_AccountDataFromLive()
	if ( not IsGMClient() ) then
		CopyAccountDataFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex);
	else
		CopyAccountDataFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex, CopyCharacterFrame.Surname:GetText(), CopyCharacterFrame.CharacterName:GetText());
	end
	StaticPopup_Show("COPY_IN_PROGRESS");
end

function CopyCharacter_KeyBindingsFromLive()
	if ( not IsGMClient() ) then
		CopyKeyBindingsFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex);
	else
		CopyKeyBindingsFromLive(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.SelectedIndex, CopyCharacterFrame.Surname:GetText(), CopyCharacterFrame.CharacterName:GetText());
	end
	StaticPopup_Show("COPY_IN_PROGRESS");
end

CopyCharacterButtonMixin = {};

function CopyCharacterButtonMixin:OnClick()
	CopyCharacterFrame:SetShown(not CopyCharacterFrame:IsShown());
end

function CopyCharacterButtonMixin:UpdateButtonState()
	local isShown = C_CharacterServices.IsLiveRegionCharacterListEnabled() or C_CharacterServices.IsLiveRegionCharacterCopyEnabled() or C_CharacterServices.IsLiveRegionAccountCopyEnabled() or C_CharacterServices.IsLiveRegionKeyBindingsCopyEnabled();
	CharacterSelectUI.VisibilityFramesContainer.ToolTray:SetToolFrameShown(self, isShown);
end

CharacterSelectVisibilityToggleButtonMixin = {};

function CharacterSelectVisibilityToggleButtonMixin:NarrationGetName()
	return NARRATION_HIDE_INTERFACE_BUTTON;
end

function CopyCharacterSearch_OnClick(self)
	ClearAccountCharacters();
	CopyCharacterFrame_Update(CopyCharacterFrame.scrollFrame);
	RequestAccountCharacters(CopyCharacterFrame_GetSelectedRegionID(), CopyCharacterFrame.Surname:GetText(), CopyCharacterFrame.CharacterName:GetText());

	self:Disable();
end

function CopyCharacterCopy_OnClick(self)
	if ( not StaticPopup_IsAnyDialogShown() ) then
		local selectedIndex = CopyCharacterFrame.SelectedIndex;
		if ( selectedIndex and (selectedIndex <= GetNumAccountCharacters()) ) then
			local name, realm = GetAccountCharacterInfo(selectedIndex);
			StaticPopup_Show("COPY_CHARACTER", format(COPY_CHARACTER_CONFIRM, name, realm));
		elseif ( IsGMClient() ) then
			StaticPopup_Show("COPY_CHARACTER", format(COPY_CHARACTER_CONFIRM, CopyCharacterFrame.CharacterName:GetText(), CopyCharacterFrame.Surname:GetText()));
		end
	end
end

function CopyAccountData_OnClick(self)
	if ( not StaticPopup_IsAnyDialogShown() ) then
		StaticPopup_Show("COPY_ACCOUNT_DATA");
	end
end

function CopyKeyBindings_OnClick(self)
	if ( not StaticPopup_IsAnyDialogShown() ) then
		StaticPopup_Show("COPY_KEY_BINDINGS");
	end
end

function CopyCharacterEntry_Init(self, characterIndex)
	local name, realm, class, level = GetAccountCharacterInfo(characterIndex);
	self.Name:SetText(name);
	self.Server:SetText(realm);
	self.Class:SetText(class);
	self.Level:SetText(level);

	local selected = CopyCharacterFrame.SelectedIndex == characterIndex;
	CopyCharacterEntry_SetSelected(self, selected);
end

function CopyCharacterEntry_SetSelected(self, selected)
	self.SelectedTexture:SetShown(selected);
end

function CopyCharacterEntry_OnClick(self)
	CopyCharacterFrame_SetSelected(self:GetElementData());
end

function CopyCharacterFrame_SetSelected(characterIndex)
	if characterIndex then
		CopyCharacterFrame.CopyButton:SetEnabled(C_CharacterServices.IsLiveRegionCharacterCopyEnabled());
	end

	local function SetSelected(index, selected)
		if index then
			local frame = CopyCharacterFrame.ScrollBox:FindFrame(index);
			if frame then
				CopyCharacterEntry_SetSelected(frame, selected);
			end
		end
	end

	SetSelected(CopyCharacterFrame.SelectedIndex, false);
	CopyCharacterFrame.SelectedIndex = characterIndex;
	SetSelected(CopyCharacterFrame.SelectedIndex, true);
end

function CopyCharacterEntry_OnEnter(self)
	self.HighlightTexture:Show();
end

function CopyCharacterEntry_OnLeave(self)
	self.HighlightTexture:Hide();
end

function CopyCharacterFrame_OnLoad(self)
	ButtonFrameTemplate_HidePortrait(self);
	self:RegisterEvent("ACCOUNT_CHARACTER_LIST_RECIEVED");
	self:RegisterEvent("CHAR_RESTORE_COMPLETE");
	self:RegisterEvent("ACCOUNT_DATA_RESTORED");
	self:RegisterEvent("KEY_BINDINGS_COPY_COMPLETE");

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CopyCharacterEntryTemplate", function(button, elementData)
		CopyCharacterEntry_Init(button, elementData);
	end);
	view:SetPadding(0,0,0,0,4);

	ScrollUtil.InitScrollBoxListWithScrollBar(CopyCharacterFrame.ScrollBox, CopyCharacterFrame.ScrollBar, view);

	self.RegionID:SetWidth(100);
end

function CopyCharacterFrame_OnShow(self)
	GlueParent_AddModalFrame(self);

	self.CopyButton:SetEnabled(false);

	local regions = C_CharacterServices.GetLiveRegionCharacterCopySourceRegions();
	self.selectedRegion = regions[1];

	local function IsSelected(regionID)
		return self.selectedRegion == regionID;
	end

	local function SetSelected(regionID)
		self.selectedRegion = regionID;

		if not IsGMClient() then
			CopyCharacterFrame_SetSelected(nil);
			CopyCharacterFrame.ScrollBox:SetDataProvider(CreateIndexRangeDataProvider(0), ScrollBoxConstants.RetainScrollPosition);
			CopyCharacterFrame.CopyButton:Disable();
			RequestAccountCharacters(regionID);
		end
	end

	self.RegionID:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CHARACTER_SELECT_REGION");

		for index, regionID in ipairs(regions) do
			local regionName = characterCopyRegions[regionID];
			if regionName then
				rootDescription:CreateRadio(regionName, IsSelected, SetSelected, regionID);
			end
		end
	end);

	ClearAccountCharacters();
	CopyCharacterFrame_Update(self.scrollFrame);

	if ( not IsGMClient() ) then
		self.Surname:Hide();
		self.CharacterName:Hide();
		self.SearchButton:Hide();
		RequestAccountCharacters(CopyCharacterFrame_GetSelectedRegionID());
	else
		self.Surname:Show();
		self.Surname:SetFocus();
		self.CharacterName:Show();
		self.SearchButton:Show();
		self.SearchButton:SetEnabled(C_CharacterServices.IsLiveRegionCharacterListEnabled());
		self.CopyButton:SetEnabled(C_CharacterServices.IsLiveRegionCharacterCopyEnabled());
	end

	self.CopyAccountData:SetEnabled(C_CharacterServices.IsLiveRegionAccountCopyEnabled());
	self.CopyKeyBindings:SetEnabled(C_CharacterServices.IsLiveRegionKeyBindingsCopyEnabled());
end

function CopyCharacterFrame_OnHide(self)
	GlueParent_RemoveModalFrame(self);
end

function CopyCharacterFrame_OnEvent(self, event, ...)
	if ( event == "ACCOUNT_CHARACTER_LIST_RECIEVED" ) then
		CopyCharacterFrame_Update(self.scrollFrame);
		self.SearchButton:Enable();
	elseif ( event == "CHAR_RESTORE_COMPLETE" or event == "ACCOUNT_DATA_RESTORED" or event == "KEY_BINDINGS_COPY_COMPLETE") then
		local success, token = ...;
		StaticPopup_HideAll();
		self:Hide();
		if (not success) then
			StaticPopup_Show("OKAY", COPY_FAILED);
		end
	end
end

function CopyCharacterFrame_GetSelectedRegionID()
	return CopyCharacterFrame.selectedRegion;
end

function CopyCharacterFrame_Update(self)
	local dataProvider = CreateIndexRangeDataProvider(GetNumAccountCharacters());
	CopyCharacterFrame.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function CopyCharacterEditBox_OnLoad(self)
	self.parent = self:GetParent();
end

function CopyCharacterEditBox_OnShow(self)
	self:SetText("");
end

function CopyCharacterEditBox_OnEnterPressed(self)
	self:GetParent().SearchButton:Click();
end

function CopyCharacterSurnameEditBox_OnTabPressed(self)
	self:GetParent().CharacterName:SetFocus();
end

function CopyCharacterCharacterNameEditBox_OnTabPressed(self)
	self:GetParent().Surname:SetFocus();
end
