StaticPopupDialogs["CUSTOM_SET_INVALID_NAME"] = {
	text = CUSTOM_SET_INVALID_NAME,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(_dialog, data)
		-- Go back to previous dialog depending on what flow the player was in.
		if data and data.fromCustomSetEditFrame then
			WardrobeCustomSetEditFrame:ShowForCustomSet(data.customSetID);
		else
			WardrobeCustomSetManager:ShowPopup("TRANSMOG_CUSTOM_SET_NAME", nil, nil, data);
		end
	end,
	timeout = 0,
	hideOnEscape = 1
};

WardrobeCustomSetDropdownMixin = { };

function WardrobeCustomSetDropdownMixin:OnLoad()
	WowStyle1DropdownMixin.OnLoad(self);
	self:SetWidth(self.width or 200);
	self:SetDefaultText(GRAY_FONT_COLOR:WrapTextInColorCode(TRANSMOG_CUSTOM_SET_NONE));

	self.SaveButton:SetScript("OnClick", function()
		WardrobeCustomSetManager:StartCustomSetSave(self, self:GetSelectedCustomSetID());
	end);
end

function WardrobeCustomSetDropdownMixin:SetSelectedCustomSetID(customSetID)
	self.selectedCustomSetID = customSetID;
end

function WardrobeCustomSetDropdownMixin:GetSelectedCustomSetID()
	return self.selectedCustomSetID;
end

function WardrobeCustomSetDropdownMixin:OnShow()
	self:RegisterEvent("TRANSMOG_CUSTOM_SETS_CHANGED");
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");

	local persistSelectedCustomSet = false;
	self:SelectCustomSet(self:GetLastCustomSetID(), persistSelectedCustomSet);
	self:InitCustomSetDropdown();
end

function WardrobeCustomSetDropdownMixin:SelectCustomSet(customSetID, persistSelectedCustomSet)
	self.persistSelectedCustomSet = persistSelectedCustomSet;
	self:SetSelectedCustomSetID(customSetID);
	self:LoadCustomSet(customSetID);
	self:UpdateSaveButton();
end

function WardrobeCustomSetDropdownMixin:OnHide()
	self:UnregisterEvent("TRANSMOG_CUSTOM_SETS_CHANGED");
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	WardrobeCustomSetManager:ClosePopups(self);
	self.persistSelectedCustomSet = false;
end

function WardrobeCustomSetDropdownMixin:OnEvent(event)
	if event == "TRANSMOG_CUSTOM_SETS_CHANGED" then
		-- Custom sets may have been deleted, or their names changed, so we need to
		-- rebuild the menu state.
		self:GenerateMenu();
		self:UpdateSaveButton();
	elseif event == "TRANSMOGRIFY_UPDATE" then
		self:UpdateSaveButton();
	end
end

function WardrobeCustomSetDropdownMixin:UpdateSaveButton()
	if self:GetSelectedCustomSetID() then
		self.SaveButton:SetEnabled(not self:IsCustomSetDressed());
	else
		self.SaveButton:SetEnabled(false);
	end
end

function WardrobeCustomSetDropdownMixin:OnCustomSetSaved(customSetID)
	if self:ShouldReplaceInvalidSources() then
		self:LoadCustomSet(customSetID);
	end
end

function WardrobeCustomSetDropdownMixin:OnCustomSetModified(customSetID)
	if self:ShouldReplaceInvalidSources() then
		self:LoadCustomSet(customSetID);
	end
end

function WardrobeCustomSetDropdownMixin:InitCustomSetDropdown()
	local function IsCustomSetSelected(customSetID)
		return self:GetSelectedCustomSetID() == customSetID;
	end

	local function SetCustomSetSelected(customSetID)
		local persistSelectedCustomSet = false;
		self:SelectCustomSet(customSetID, persistSelectedCustomSet);
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_WARDROBE_CUSTOM_SETS");

		local customSets = C_TransmogCollection.GetCustomSets();
		for index, customSetID in ipairs(customSets) do
			local name, icon = C_TransmogCollection.GetCustomSetInfo(customSetID);
			local text = NORMAL_FONT_COLOR:WrapTextInColorCode(name);

			local radio = rootDescription:CreateButton(text, SetCustomSetSelected, customSetID);
			radio:SetIsSelected(IsCustomSetSelected);
			radio:AddInitializer(function(button, description, menu)
				local texture = button:AttachTexture();
				texture:SetSize(19,19);
				texture:SetPoint("LEFT");
				texture:SetTexture(icon);

				local fontString = button.fontString;
				fontString:SetPoint("LEFT", texture, "RIGHT", 3, 0);

				if customSetID == self:GetSelectedCustomSetID() then
					local fontString2 = button:AttachFontString();
					fontString2:SetPoint("LEFT", button.fontString, "RIGHT");
					fontString2:SetHeight(16);

					local size = 20;
					fontString2:SetTextToFit(CreateSimpleTextureMarkup([[Interface\Buttons\UI-CheckBox-Check]], size, size));
				end

				local gearButton = MenuTemplates.AttachAutoHideGearButton(button);
				gearButton:SetPoint("RIGHT");

				MenuUtil.HookTooltipScripts(gearButton, function(tooltip)
					GameTooltip_SetTitle(tooltip, TRANSMOG_CUSTOM_SET_EDIT);
				end);

				gearButton:SetScript("OnClick", function()
					WardrobeCustomSetEditFrame:ShowForCustomSet(customSetID)
					menu:Close();
				end);
			end);
		end

		if #customSets < C_TransmogCollection.GetNumMaxCustomSets() then
			local text = GREEN_FONT_COLOR:WrapTextInColorCode(TRANSMOG_CUSTOM_SET_NEW);
			local button = rootDescription:CreateButton(text, function()
				WardrobeCustomSetManager:StartCustomSetSave(self);
			end);

			button:AddInitializer(function(button, description, menu)
				local texture = button:AttachTexture();
				texture:SetSize(19,19);
				texture:SetPoint("LEFT");
				texture:SetTexture([[Interface\PaperDollInfoFrame\Character-Plus]]);

				local fontString = button.fontString;
				fontString:SetPoint("LEFT", texture, "RIGHT", 3, 0);
			end);
		end
	end);
end

function WardrobeCustomSetDropdownMixin:NewCustomSet(customSetID)
	self:SetSelectedCustomSetID(customSetID);
	self:InitCustomSetDropdown();
	self:UpdateSaveButton();

	self:OnCustomSetSaved(customSetID);
end

function WardrobeCustomSetDropdownMixin:GetLastCustomSetID()
	-- The dropdown in DressUpModelFrame.
	-- Some flows explicitly want the selected custom set to persist, such as viewing a custom set you were just looking at in the transmog dialog.
	return self.persistSelectedCustomSet and self:GetSelectedCustomSetID() or nil;
end

function WardrobeCustomSetDropdownMixin:IsCustomSetDressed()
	local customSetID = self:GetSelectedCustomSetID();
	if not customSetID then
		return true;
	end

	local customSetItemTransmogInfoList = C_TransmogCollection.GetCustomSetItemTransmogInfoList(customSetID);
	if not customSetItemTransmogInfoList then
		return true;
	end

	local currentItemTransmogInfoList = self:GetItemTransmogInfoList();
	if not currentItemTransmogInfoList then
		return true;
	end

	for slotID, itemTransmogInfo in ipairs(currentItemTransmogInfoList) do
		if not itemTransmogInfo:IsEqual(customSetItemTransmogInfoList[slotID]) then
			if itemTransmogInfo.appearanceID ~= Constants.Transmog.NoTransmogID then
				return false;
			end
		end
	end
	return true;
end

function WardrobeCustomSetDropdownMixin:ShouldReplaceInvalidSources()
	return self.replaceInvalidSources;
end

--===================================================================================================================================
WardrobeCustomSetManager = { };

WardrobeCustomSetManager.popups = {
	"TRANSMOG_CUSTOM_SET_NAME",
	"CUSTOM_SET_INVALID_NAME",
	"TRANSMOG_CUSTOM_SET_CONFIRM_OVERWRITE",
	"CONFIRM_DELETE_TRANSMOG_CUSTOM_SET",
	"CONFIRM_SAVE_TRANSMOG_CUSTOM_SET",
	"TRANSMOG_CUSTOM_SET_CHECKING_APPEARANCES",
	"TRANSMOG_CUSTOM_SET_SOME_INVALID_APPEARANCES",
	"TRANSMOG_CUSTOM_SET_ALL_INVALID_APPEARANCES",
};

function WardrobeCustomSetManager:NewCustomSet(name)
	local icon;
	for _slotID, itemTransmogInfo in ipairs(self.itemTransmogInfoList) do
		local appearanceID = itemTransmogInfo.appearanceID;
		if appearanceID ~= Constants.Transmog.NoTransmogID then
			local appearanceSourceInfo = C_TransmogCollection.GetAppearanceSourceInfo(appearanceID);
			if appearanceSourceInfo and appearanceSourceInfo.icon then
				icon = appearanceSourceInfo.icon;
				break;
			end
		end
	end

	local customSetID = C_TransmogCollection.NewCustomSet(name, icon, self.itemTransmogInfoList);
	if customSetID then
		self:SaveLastCustomSet(customSetID);
	end

	if self.dropdown then
		self.dropdown:NewCustomSet(customSetID);
	end

	self:ClosePopups();
end

function WardrobeCustomSetManager:NameCustomSet(newName, customSetIDToRename, dialogData)
	-- Validate name.
	if not C_TransmogCollection.IsValidCustomSetName(newName) then
		self:ShowPopup("CUSTOM_SET_INVALID_NAME", nil, nil, dialogData);
		return;
	end

	local existingCustomSetID = nil;
	local customSets = C_TransmogCollection.GetCustomSets();
	for _index, customSetID in ipairs(customSets) do
		local name, _icon = C_TransmogCollection.GetCustomSetInfo(customSetID);
		if name == newName then
			existingCustomSetID = customSetID;
			break;
		end
	end

	if existingCustomSetID then
		if customSetIDToRename then
			-- Trying to rename existing custom set, with name of other existing custom set. Not allowed.
			UIErrorsFrame:AddMessage(TRANSMOG_CUSTOM_SET_ALREADY_EXISTS, 1.0, 0.1, 0.1, 1.0);
		else
			-- Trying to create a new custom set, with name of existing custom set, prompt to override it.
			-- 'name' field is needed in case the confirmation is cancelled, which would show TRANSMOG_CUSTOM_SET_NAME dialog again with that as the starting text.
			local confirmData = { name = newName, customSetID = existingCustomSetID, itemTransmogInfoList = self.itemTransmogInfoList };
			self:ShowPopup("TRANSMOG_CUSTOM_SET_CONFIRM_OVERWRITE", newName, nil, confirmData);
		end
	elseif customSetIDToRename then
		C_TransmogCollection.RenameCustomSet(customSetIDToRename, newName);
	else
		self:NewCustomSet(newName);
	end
end

function WardrobeCustomSetManager:ShowPopup(popup, ...)
	-- close all other popups
	for _, listPopup in pairs(self.popups) do
		if ( listPopup ~= popup ) then
			StaticPopup_Hide(listPopup);
		end
	end
	if ( popup ~= WardrobeCustomSetEditFrame ) then
		StaticPopupSpecial_Hide(WardrobeCustomSetEditFrame);
	end

	if ( popup == WardrobeCustomSetEditFrame ) then
		StaticPopupSpecial_Show(WardrobeCustomSetEditFrame);
	else
		StaticPopup_Show(popup, ...);
	end
end

function WardrobeCustomSetManager:ClosePopups(requestingDropdown)
	if ( requestingDropdown and requestingDropdown ~= self.popupDropdown ) then
		return;
	end
	for _, popup in pairs(self.popups) do
		StaticPopup_Hide(popup);
	end
	StaticPopupSpecial_Hide(WardrobeCustomSetEditFrame);

	-- clean up
	self.itemTransmogInfoList = nil;
	self.hasAnyPendingAppearances = nil;
	self.hasAnyValidAppearances = nil;
	self.hasAnyInvalidAppearances = nil;
	self.customSetID = nil;
	self.dropdown = nil;
end

function WardrobeCustomSetManager:StartCustomSetSave(dropdown, customSetID)
	self.dropdown = dropdown;
	self.customSetID = customSetID;
	self:EvaluateAppearances();
end

function WardrobeCustomSetManager:SetItemTransmogInfoList(itemTransmogInfoList)
	self.itemTransmogInfoList = itemTransmogInfoList;
end

function WardrobeCustomSetManager:EvaluateAppearance(appearanceID, category, transmogLocation)
	local preferredAppearanceID, hasAllData, canCollect;
	if self.dropdown:ShouldReplaceInvalidSources() then
		preferredAppearanceID, hasAllData, canCollect = CollectionWardrobeUtil.GetPreferredSourceID(appearanceID, nil, category, transmogLocation);
	else
		preferredAppearanceID = appearanceID;
		hasAllData, canCollect = C_TransmogCollection.PlayerCanCollectSource(appearanceID);
	end

	if canCollect then
		self.hasAnyValidAppearances = true;
	else
		if hasAllData then
			self.hasAnyInvalidAppearances = true;
		else
			self.hasAnyPendingAppearances = true;
		end
	end
	local isInvalidAppearance = hasAllData and not canCollect;
	return preferredAppearanceID, isInvalidAppearance;
end

function WardrobeCustomSetManager:EvaluateAppearances()
	self.hasAnyInvalidAppearances = false;
	self.hasAnyValidAppearances = false;
	self.hasAnyPendingAppearances = false;
	self:SetItemTransmogInfoList(self.dropdown:GetItemTransmogInfoList());
	-- all illusions are collectible
	for slotID, itemTransmogInfo in ipairs(self.itemTransmogInfoList) do
		local isValidAppearance = false;
		if TransmogUtil.IsValidTransmogSlotID(slotID) then
			local appearanceID = itemTransmogInfo.appearanceID;
			isValidAppearance = appearanceID ~= Constants.Transmog.NoTransmogID;
			-- skip offhand if mainhand is an appeance from Legion Artifacts category and the offhand matches the paired appearance
			if isValidAppearance and slotID == INVSLOT_OFFHAND then
				local mhInfo = self.itemTransmogInfoList[INVSLOT_MAINHAND];
				if mhInfo:IsMainHandPairedWeapon() then
					isValidAppearance = appearanceID ~= C_TransmogCollection.GetPairedArtifactAppearance(mhInfo.appearanceID);
				end
			end
			if isValidAppearance then
				local isSecondary = false;
				local transmogLocation = TransmogUtil.CreateTransmogLocation(slotID, Enum.TransmogType.Appearance, isSecondary);
				local category = C_TransmogCollection.GetCategoryForItem(appearanceID);
				local preferredAppearanceID, isInvalidAppearance = self:EvaluateAppearance(appearanceID, category, transmogLocation);
				if isInvalidAppearance then
					isValidAppearance = false;
				else
					itemTransmogInfo.appearanceID = preferredAppearanceID;
				end
				-- secondary check
				if itemTransmogInfo.secondaryAppearanceID ~= Constants.Transmog.NoTransmogID and C_Transmog.CanHaveSecondaryAppearanceForSlotID(slotID) then
					isSecondary = true;
					local secondaryTransmogLocation = TransmogUtil.CreateTransmogLocation(slotID, Enum.TransmogType.Appearance, isSecondary);
					local secondaryCategory = C_TransmogCollection.GetCategoryForItem(itemTransmogInfo.secondaryAppearanceID);
					local secondaryPreferredAppearanceID, secondaryIsInvalidAppearance = self:EvaluateAppearance(itemTransmogInfo.secondaryAppearanceID, secondaryCategory, secondaryTransmogLocation);
					if secondaryIsInvalidAppearance then
						-- secondary is invalid, clear it
						itemTransmogInfo.secondaryAppearanceID = Constants.Transmog.NoTransmogID;
					else
						if isInvalidAppearance then
							-- secondary is valid but primary is invalid, make the secondary the primary
							isValidAppearance = true;
							itemTransmogInfo.appearanceID = secondaryPreferredAppearanceID;
							itemTransmogInfo.secondaryAppearanceID = Constants.Transmog.NoTransmogID;
						else
							-- both primary and secondary are valid
							itemTransmogInfo.secondaryAppearanceID = secondaryPreferredAppearanceID;
						end
					end
				end
			end
		end
		if not isValidAppearance then
			itemTransmogInfo:Clear();
		end
	end

	self:EvaluateSaveState();
end

function WardrobeCustomSetManager:EvaluateSaveState()
	if self.hasAnyPendingAppearances then
		-- wait
		if ( not StaticPopup_Visible("TRANSMOG_CUSTOM_SET_CHECKING_APPEARANCES") ) then
			self:ShowPopup("TRANSMOG_CUSTOM_SET_CHECKING_APPEARANCES", nil, nil, nil, WardrobeCustomSetCheckAppearancesFrame);
		end
	else
		StaticPopup_Hide("TRANSMOG_CUSTOM_SET_CHECKING_APPEARANCES");
		if not self.hasAnyValidAppearances then
			-- stop
			self:ShowPopup("TRANSMOG_CUSTOM_SET_ALL_INVALID_APPEARANCES");
		elseif self.hasAnyInvalidAppearances then
			-- warn
			self:ShowPopup("TRANSMOG_CUSTOM_SET_SOME_INVALID_APPEARANCES");
		else
			self:ContinueWithSave();
		end
	end
end

function WardrobeCustomSetManager:ContinueWithSave()
	if self.customSetID then
		C_TransmogCollection.ModifyCustomSet(self.customSetID, self.itemTransmogInfoList);
		self:SaveLastCustomSet(self.customSetID);
		if ( self.dropdown ) then
			self.dropdown:OnCustomSetModified(self.customSetID);
		end
		self:ClosePopups();
	else
		self:ShowPopup("TRANSMOG_CUSTOM_SET_NAME");
	end
end

function WardrobeCustomSetManager:SaveLastCustomSet(customSetID)
	local value = customSetID or "";

	-- Classic only cvar
	local classicSpecValue = GetCVar("lastTransmogCustomSetIDNoSpec");
	if(classicSpecValue ~= nil) then
		SetCVar("lastTransmogCustomSetIDNoSpec", value);
		return;
	end

	local currentSpecIndex = GetCVarBool("transmogCurrentSpecOnly") and C_SpecializationInfo.GetSpecialization() or nil;
	for specIndex = 1, GetNumSpecializations() do
		if not currentSpecIndex or specIndex == currentSpecIndex then
			SetCVar("lastTransmogCustomSetIDSpec"..specIndex, value);
		end
	end
end

function WardrobeCustomSetManager:OverwriteCustomSet(customSetID)
	self.customSetID = customSetID;
	self:ContinueWithSave();
end

--===================================================================================================================================
WardrobeCustomSetEditFrameMixin = { };

function WardrobeCustomSetEditFrameMixin:ShowForCustomSet(customSetID)
	WardrobeCustomSetManager:ShowPopup(self);
	self.customSetID = customSetID;
	local name, _icon = C_TransmogCollection.GetCustomSetInfo(customSetID);
	self.EditBox:SetText(name);
end

function WardrobeCustomSetEditFrameMixin:OnDelete()
	local name, _icon = C_TransmogCollection.GetCustomSetInfo(self.customSetID);
	WardrobeCustomSetManager:ShowPopup("CONFIRM_DELETE_TRANSMOG_CUSTOM_SET", name, nil,  self.customSetID);
end

function WardrobeCustomSetEditFrameMixin:OnAccept()
	if ( not self.AcceptButton:IsEnabled() ) then
		return;
	end
	StaticPopupSpecial_Hide(self);
	local data = {
		fromCustomSetEditFrame = true,
		customSetID = self.customSetID
	}
	WardrobeCustomSetManager:NameCustomSet(self.EditBox:GetText(), self.customSetID, data);
end

--===================================================================================================================================
WardrobeCustomSetCheckAppearancesMixin = { };

function WardrobeCustomSetCheckAppearancesMixin:OnShow()
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOG_SOURCE_COLLECTABILITY_UPDATE");
end

function WardrobeCustomSetCheckAppearancesMixin:OnHide()
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:UnregisterEvent("TRANSMOG_SOURCE_COLLECTABILITY_UPDATE");
	self.reevaluate = nil;
end

function WardrobeCustomSetCheckAppearancesMixin:OnEvent(event)
	self.reevaluate = true;
end

function WardrobeCustomSetCheckAppearancesMixin:OnUpdate()
	if self.reevaluate then
		self.reevaluate = nil;
		WardrobeCustomSetManager:EvaluateAppearances();
	end
end
