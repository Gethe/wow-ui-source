WardrobeOutfitDropdownMixin = { };

function WardrobeOutfitDropdownMixin:OnLoad()
	WowStyle1DropdownMixin.OnLoad(self);
	self:SetWidth(self.width or 200);
	self:SetDefaultText(GRAY_FONT_COLOR:WrapTextInColorCode(TRANSMOG_OUTFIT_NONE));

	self.SaveButton:SetScript("OnClick", function()
		WardrobeOutfitManager:StartOutfitSave(self, self:GetSelectedOutfitID());
	end);
end

function WardrobeOutfitDropdownMixin:SetSelectedOutfitID(outfitID)
	self.selectedOutfitID = outfitID;
end

function WardrobeOutfitDropdownMixin:GetSelectedOutfitID()
	return self.selectedOutfitID;
end

function WardrobeOutfitDropdownMixin:OnShow()
	self:RegisterEvent("TRANSMOG_OUTFITS_CHANGED");
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
		
	self:SelectOutfit(self:GetLastOutfitID());
	self:InitOutfitDropdown();
end

function WardrobeOutfitDropdownMixin:SelectOutfit(outfitID)
	self:SetSelectedOutfitID(outfitID);
	self:LoadOutfit(outfitID);
	self:UpdateSaveButton();
end

function WardrobeOutfitDropdownMixin:OnHide()
	self:UnregisterEvent("TRANSMOG_OUTFITS_CHANGED");
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	WardrobeOutfitManager:ClosePopups(self);
end

function WardrobeOutfitDropdownMixin:OnEvent(event)
	if event == "TRANSMOG_OUTFITS_CHANGED" then
		-- Outfits may have been deleted, or their names changed, so we need to
		-- rebuild the menu state.
		self:GenerateMenu();
		self:UpdateSaveButton();
	elseif event == "TRANSMOGRIFY_UPDATE" then
		self:UpdateSaveButton();
	end
end

function WardrobeOutfitDropdownMixin:UpdateSaveButton()
	if self:GetSelectedOutfitID() then
		self.SaveButton:SetEnabled(not self:IsOutfitDressed());
	else
		self.SaveButton:SetEnabled(false);
	end
end

function WardrobeOutfitDropdownMixin:OnOutfitSaved(outfitID)
	if self:ShouldReplaceInvalidSources() then
		self:LoadOutfit(outfitID);
	end
end

function WardrobeOutfitDropdownMixin:OnOutfitModified(outfitID)
	if self:ShouldReplaceInvalidSources() then
		self:LoadOutfit(outfitID);
	end
end

function WardrobeOutfitDropdownMixin:InitOutfitDropdown()
	local function IsOutfitSelected(outfitID)
		return self:GetSelectedOutfitID() == outfitID;
	end
	
	local function SetOutfitSelected(outfitID)
		self:SelectOutfit(outfitID);
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_WARDROBE_OUTFITS");

		local outfits = C_TransmogCollection.GetOutfits();
		for index, outfitID in ipairs(outfits) do
			local name, icon = C_TransmogCollection.GetOutfitInfo(outfitID);
			local text = NORMAL_FONT_COLOR:WrapTextInColorCode(name);

			local radio = rootDescription:CreateButton(text, SetOutfitSelected, outfitID);
			radio:SetIsSelected(IsOutfitSelected);
			radio:AddInitializer(function(button, description, menu)
				local texture = button:AttachTexture();
				texture:SetSize(19,19);
				texture:SetPoint("LEFT");
				texture:SetTexture(icon);

				local fontString = button.fontString;
				fontString:SetPoint("LEFT", texture, "RIGHT", 3, 0);

				if outfitID == self:GetSelectedOutfitID() then
					local fontString2 = button:AttachFontString();
					fontString2:SetPoint("LEFT", button.fontString, "RIGHT");
					fontString2:SetHeight(16);

					local size = 20;
					fontString2:SetTextToFit(CreateSimpleTextureMarkup([[Interface\Buttons\UI-CheckBox-Check]], size, size));
				end

				local gearButton = MenuTemplates.AttachAutoHideGearButton(button);
				gearButton:SetPoint("RIGHT");

				MenuUtil.HookTooltipScripts(gearButton, function(tooltip)
					GameTooltip_SetTitle(tooltip, TRANSMOG_OUTFIT_EDIT);
				end);

				gearButton:SetScript("OnClick", function()
					WardrobeOutfitEditFrame:ShowForOutfit(outfitID)
					menu:Close();
				end);
			end);
		end

		if #outfits < C_TransmogCollection.GetNumMaxOutfits() then
			local text = GREEN_FONT_COLOR:WrapTextInColorCode(TRANSMOG_OUTFIT_NEW);
			local button = rootDescription:CreateButton(text, function()
				if WardrobeTransmogFrame and HelpTip:IsShowing(WardrobeTransmogFrame, TRANSMOG_OUTFIT_DROPDOWN_TUTORIAL) then
					HelpTip:Hide(WardrobeTransmogFrame, TRANSMOG_OUTFIT_DROPDOWN_TUTORIAL);
					SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_OUTFIT_DROPDOWN, true);
				end
				WardrobeOutfitManager:StartOutfitSave(self);
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

function WardrobeOutfitDropdownMixin:NewOutfit(outfitID)
	self:SetSelectedOutfitID(outfitID);
	self:InitOutfitDropdown();
	self:UpdateSaveButton();

	self:OnOutfitSaved(outfitID);
end

function WardrobeOutfitDropdownMixin:GetLastOutfitID()
	-- Expected to return nil for the dropdown in DressUpModelFrame. See WardrobeOutfitMixin:GetLastOutfitID()
	-- for the regular implementation.
	return nil;
end

function WardrobeOutfitDropdownMixin:IsOutfitDressed()
	local outfitID = self:GetSelectedOutfitID();
	if not outfitID then
		return true;
	end

	local outfitItemTransmogInfoList = C_TransmogCollection.GetOutfitItemTransmogInfoList(outfitID);
	if not outfitItemTransmogInfoList then
		return true;
	end

	local currentItemTransmogInfoList = self:GetItemTransmogInfoList();
	if not currentItemTransmogInfoList then
		return true;
	end

	for slotID, itemTransmogInfo in ipairs(currentItemTransmogInfoList) do
		if not itemTransmogInfo:IsEqual(outfitItemTransmogInfoList[slotID]) then
			if itemTransmogInfo.appearanceID ~= Constants.Transmog.NoTransmogID then
				return false;
			end
		end
	end
	return true;
end

function WardrobeOutfitDropdownMixin:ShouldReplaceInvalidSources()
	return self.replaceInvalidSources;
end

--===================================================================================================================================
WardrobeOutfitManager = { };

WardrobeOutfitManager.popups = {
	"NAME_TRANSMOG_OUTFIT",
	"CONFIRM_DELETE_TRANSMOG_OUTFIT",
	"CONFIRM_SAVE_TRANSMOG_OUTFIT",
	"CONFIRM_OVERWRITE_TRANSMOG_OUTFIT",
	"TRANSMOG_OUTFIT_CHECKING_APPEARANCES",
	"TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES",
	"TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES",
};

function WardrobeOutfitManager:NewOutfit(name)
	local icon;

	for slotID, itemTransmogInfo in ipairs(self.itemTransmogInfoList) do
		local appearanceID = itemTransmogInfo.appearanceID;
		if appearanceID ~= Constants.Transmog.NoTransmogID then
			icon = select(4, C_TransmogCollection.GetAppearanceSourceInfo(appearanceID));
			if icon then
				break;
			end
		end
	end

	local outfitID = C_TransmogCollection.NewOutfit(name, icon, self.itemTransmogInfoList);
	if outfitID then
		self:SaveLastOutfit(outfitID);
	end
	if ( self.dropdown ) then
		self.dropdown:NewOutfit(outfitID);
	end
end

function WardrobeOutfitManager:NameOutfit(newName, outfitID)
	local outfits = C_TransmogCollection.GetOutfits();
	for i = 1, #outfits do
		local name, icon = C_TransmogCollection.GetOutfitInfo(outfits[i]);
		if name == newName then
			if ( outfitID ) then
				UIErrorsFrame:AddMessage(TRANSMOG_OUTFIT_ALREADY_EXISTS, 1.0, 0.1, 0.1, 1.0);
			else
				WardrobeOutfitManager:ShowPopup("CONFIRM_OVERWRITE_TRANSMOG_OUTFIT", newName, nil, { name = name, outfitID = outfits[i] });
			end
			return;
		end
	end
	if outfitID then
		C_TransmogCollection.RenameOutfit(outfitID, newName);
	else
		self:NewOutfit(newName);
	end
end

function WardrobeOutfitManager:ShowPopup(popup, ...)
	-- close all other popups
	for _, listPopup in pairs(self.popups) do
		if ( listPopup ~= popup ) then
			StaticPopup_Hide(listPopup);
		end
	end
	if ( popup ~= WardrobeOutfitEditFrame ) then
		StaticPopupSpecial_Hide(WardrobeOutfitEditFrame);
	end

	if ( popup == WardrobeOutfitEditFrame ) then
		StaticPopupSpecial_Show(WardrobeOutfitEditFrame);
	else
		StaticPopup_Show(popup, ...);
	end
end

function WardrobeOutfitManager:ClosePopups(requestingDropdown)
	if ( requestingDropdown and requestingDropdown ~= self.popupDropdown ) then
		return;
	end
	for _, popup in pairs(self.popups) do
		StaticPopup_Hide(popup);
	end
	StaticPopupSpecial_Hide(WardrobeOutfitEditFrame);

	-- clean up
	self.itemTransmogInfoList = nil;
	self.hasAnyPendingAppearances = nil;
	self.hasAnyValidAppearances = nil;
	self.hasAnyInvalidAppearances = nil;
	self.outfitID = nil;
	self.dropdown = nil;
end

function WardrobeOutfitManager:StartOutfitSave(dropdown, outfitID)
	self.dropdown = dropdown;
	self.outfitID = outfitID;
	self:EvaluateAppearances();
end

function WardrobeOutfitManager:EvaluateAppearance(appearanceID, category, transmogLocation)
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

function WardrobeOutfitManager:EvaluateAppearances()
	self.hasAnyInvalidAppearances = false;
	self.hasAnyValidAppearances = false;
	self.hasAnyPendingAppearances = false;
	self.itemTransmogInfoList = self.dropdown:GetItemTransmogInfoList();
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
				local transmogLocation = TransmogUtil.CreateTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
				local category = C_TransmogCollection.GetCategoryForItem(appearanceID);
				local preferredAppearanceID, isInvalidAppearance = self:EvaluateAppearance(appearanceID, category, transmogLocation);
				if isInvalidAppearance then
					isValidAppearance = false;
				else
					itemTransmogInfo.appearanceID = preferredAppearanceID;
				end
				-- secondary check
				if itemTransmogInfo.secondaryAppearanceID ~= Constants.Transmog.NoTransmogID and C_Transmog.CanHaveSecondaryAppearanceForSlotID(slotID) then
					local secondaryTransmogLocation = TransmogUtil.CreateTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary);
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

function WardrobeOutfitManager:EvaluateSaveState()
	if self.hasAnyPendingAppearances then
		-- wait
		if ( not StaticPopup_Visible("TRANSMOG_OUTFIT_CHECKING_APPEARANCES") ) then
			WardrobeOutfitManager:ShowPopup("TRANSMOG_OUTFIT_CHECKING_APPEARANCES", nil, nil, nil, WardrobeOutfitCheckAppearancesFrame);
		end
	else
		StaticPopup_Hide("TRANSMOG_OUTFIT_CHECKING_APPEARANCES");
		if not self.hasAnyValidAppearances then
			-- stop
			WardrobeOutfitManager:ShowPopup("TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES");
		elseif self.hasAnyInvalidAppearances then
			-- warn
			WardrobeOutfitManager:ShowPopup("TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES");
		else
			WardrobeOutfitManager:ContinueWithSave();
		end
	end
end

function WardrobeOutfitManager:ContinueWithSave()
	if self.outfitID then
		C_TransmogCollection.ModifyOutfit(self.outfitID, self.itemTransmogInfoList);
		self:SaveLastOutfit(self.outfitID);
		if ( self.dropdown ) then
			self.dropdown:OnOutfitModified(self.outfitID);
		end
		WardrobeOutfitManager:ClosePopups();
	else
		WardrobeOutfitManager:ShowPopup("NAME_TRANSMOG_OUTFIT");
	end
end

function WardrobeOutfitManager:SaveLastOutfit(outfitID)
	local value = outfitID or "";
	local currentSpecIndex = GetCVarBool("transmogCurrentSpecOnly") and GetSpecialization() or nil;
	for specIndex = 1, GetNumSpecializations() do
		if not currentSpecIndex or specIndex == currentSpecIndex then
			SetCVar("lastTransmogOutfitIDSpec"..specIndex, value);
		end
	end
end

function WardrobeOutfitManager:OverwriteOutfit(outfitID)
	self.outfitID = outfitID;
	self:ContinueWithSave();
end

--===================================================================================================================================
WardrobeOutfitEditFrameMixin = { };

function WardrobeOutfitEditFrameMixin:ShowForOutfit(outfitID)
	WardrobeOutfitManager:ShowPopup(self);
	self.outfitID = outfitID;
	local name, icon = C_TransmogCollection.GetOutfitInfo(outfitID);
	self.EditBox:SetText(name);
end

function WardrobeOutfitEditFrameMixin:OnDelete()
	local name = C_TransmogCollection.GetOutfitInfo(self.outfitID);
	WardrobeOutfitManager:ShowPopup("CONFIRM_DELETE_TRANSMOG_OUTFIT", name, nil,  self.outfitID);
end

function WardrobeOutfitEditFrameMixin:OnAccept()
	if ( not self.AcceptButton:IsEnabled() ) then
		return;
	end
	StaticPopupSpecial_Hide(self);
	WardrobeOutfitManager:NameOutfit(self.EditBox:GetText(), self.outfitID);
end

--===================================================================================================================================
WardrobeOutfitCheckAppearancesMixin = { };

function WardrobeOutfitCheckAppearancesMixin:OnShow()
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterEvent("TRANSMOG_SOURCE_COLLECTABILITY_UPDATE");
end

function WardrobeOutfitCheckAppearancesMixin:OnHide()
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:UnregisterEvent("TRANSMOG_SOURCE_COLLECTABILITY_UPDATE");
	self.reevaluate = nil;
end

function WardrobeOutfitCheckAppearancesMixin:OnEvent(event)
	self.reevaluate = true;
end

function WardrobeOutfitCheckAppearancesMixin:OnUpdate()
	if self.reevaluate then
		self.reevaluate = nil;
		WardrobeOutfitManager:EvaluateAppearances();
	end
end