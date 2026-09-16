SuperDistrictMixin = {};

function SuperDistrictMixin:OnLoad()
	SetLoginScreenModel(self);

	self.selectedSuperDistrictID = nil;

	EventRegistry:RegisterCallback("SuperDistrict.SelectSuperDistrict", function(_, superDistrictID)
		self:UpdateSelection(superDistrictID);
	end, self);

	EventRegistry:RegisterCallback("SuperDistrict.ConfirmSuperDistrict", function(_, idx)
		self:ConfirmSuperDistrict();
	end, self);

	EventRegistry:RegisterCallback("SuperDistrict.CancelSelection", function(_, idx)
		self:OnCancel();
	end, self);

	self:RegisterEvent("SUPER_DISTRICT_LIST_UPDATED");

	self.districtButtonPool = CreateFramePoolCollection();
	self.districtButtonPool:CreatePool("CHECKBUTTON", self.ButtonLayout, "SuperDistrictButtonTemplate");

	self.SubRegionDropdown:SetWidth(228);
	local function IsSelected(subRegion)
		return C_Login.GetCurrentSubRegion() == subRegion;
	end
	local function SetSelected(subRegion)
		C_Login.SetCurrentSubRegion(subRegion);
	end
	self.SubRegionDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_LOGIN_SUB_REGION");

		for _, subRegion in ipairs(C_Login.GetSubRegions()) do
			local subRegionDisplayName = C_Login.GetSubRegionDisplayName(subRegion);
			if not subRegionDisplayName or subRegionDisplayName == "" then
				subRegionDisplayName = subRegion;
			end
			rootDescription:CreateRadio(subRegionDisplayName, IsSelected, SetSelected, subRegion);
		end
	end);

	self:RefreshSuperDistrictButtons();
	self:UpdateSelection(self.selectedSuperDistrictID);
end

function SuperDistrictMixin:OnShow()
	self.SubRegionDropdown:SetShown(#C_Login.GetSubRegions() > 1);
	self:RefreshSuperDistrictButtons();

	local narrationInfo = NarrationUtil.RegionToNarrationInfo(self, NarrationUtil.TriggerType.Notification);
	if narrationInfo then
		EventRegistry:TriggerEvent("Narration.Speak", narrationInfo);
	end
end

function SuperDistrictMixin:NarrationGetName()
	return self.Title:GetText();
end

function SuperDistrictMixin:NarrationGetDescription()
	return self.Description:GetText();
end

function SuperDistrictMixin:NarrationShouldIgnoreFocus()
	return true;
end

function SuperDistrictMixin:OnEvent(event)
	if event == "SUPER_DISTRICT_LIST_UPDATED" then
		self:RefreshSuperDistrictButtons();
	end
end

function SuperDistrictMixin:RefreshSuperDistrictButtons()
	self.districtButtonPool:ReleaseAll();
	self.districtButtons = {};

	local superDistrictInfos = C_DistrictUtils.GetAvailableSuperDistricts();

	for i, superDistrictInfo in ipairs(superDistrictInfos) do
		local button = self.districtButtonPool:Acquire("SuperDistrictButtonTemplate");
		button.superDistrictID = superDistrictInfo.superDistrictID;
		button.layoutIndex = i;
		button:SetupSuperDistrictButton(superDistrictInfo.superDistrictID);
		button:Show();
		table.insert(self.districtButtons, button);
	end

	self.ButtonLayout:Layout();
end

function SuperDistrictMixin:UpdateSelection(superDistrictID)
	self.selectedSuperDistrictID = superDistrictID;

	local hasSelection = false;
	for i, button in ipairs(self.districtButtons) do
		local isSelected = button.superDistrictID == superDistrictID;
		button:SetChecked(isSelected);
		hasSelection = hasSelection or isSelected;
	end

	self.SelectButton:SetEnabled(hasSelection);
	self.SelectButton:SetDisabledTooltip(hasSelection and nil or SUPER_DISTRICT_SELECT_DISABLED_REASON);
end

function SuperDistrictMixin:ConfirmSuperDistrict()
	CharacterSelectUtil.ChangeSuperDistrict(self.selectedSuperDistrictID);
end

function SuperDistrictMixin:OnCancel()
	local loginState = C_Login.GetState();
	if ( not loginState.connectedToWoW ) then
		C_Login.DisconnectFromServer();
	else
		ExitSuperDistrictSelection();
	end
end

SuperDistrictButtonMixin = CreateFromMixins(SelectableButtonMixin, DisabledTooltipButtonMixin);

function SuperDistrictButtonMixin:SetDisabledVisuals(disabled)
	self:SetAlpha(disabled and 0.55 or 1.0);
	self.Icon:SetDesaturated(disabled);
	self.Background:SetDesaturated(disabled);
	self.Circle:SetDesaturated(disabled);
end

function SuperDistrictButtonMixin:SetupSuperDistrictButton(superDistrictID)
	self.superDistrictID = superDistrictID;
	local info = C_DistrictUtils.GetSuperDistrictInfo(superDistrictID);

	local disallowLogin = info.disallowLogin;
	self:SetEnabled(not disallowLogin);
	self:SetDisabledVisuals(disallowLogin);
	self:SetMotionScriptsWhileDisabled(disallowLogin);
	self:SetDisabledTooltip(disallowLogin and SUPER_DISTRICT_DISALLOW_LOGIN or nil, "ANCHOR_BOTTOM");
	self:SetScript("OnEnter", self.OnEnter);
	self:SetScript("OnLeave", self.OnLeave);

	self.Title:SetText(info.displayName);
	self.Icon:SetTexture(info.iconFileDataID);
	self.Description:SetText(info.description);

	if info.overrideBgAtlas and info.overrideBgAtlas ~= "" then
		self.Background:SetAtlas(info.overrideBgAtlas);
	end

	if info.overrideBgGlowAtlas and info.overrideBgGlowAtlas ~= "" then
		self:SetCheckedTexture(info.overrideBgGlowAtlas);
	end
end

function SuperDistrictButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:SetChecked(true);

	EventRegistry:TriggerEvent("SuperDistrict.SelectSuperDistrict", self.superDistrictID);
end

function SuperDistrictButtonMixin:NarrationGetName()
	return self.Title:GetText();
end

function SuperDistrictButtonMixin:NarrationGetContext()
	if not self:IsEnabled() then
		return NARRATION_STATUS_DISABLED_FORMAT:format(NARRATION_OBJECT_BUTTON);
	end

	if self:GetChecked() then
		return NARRATION_STATUS_SELECTED_FORMAT:format(NARRATION_OBJECT_BUTTON);
	end

	return NARRATION_OBJECT_BUTTON;
end

function SuperDistrictButtonMixin:NarrationGetDescription()
	return self.Description:GetText();
end
