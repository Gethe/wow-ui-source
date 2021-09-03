
--===================================================================================================================================
WardrobeOutfitDropDownMixin = { };

function WardrobeOutfitDropDownMixin:OnLoad()
	local button = _G[self:GetName().."Button"];
	button:SetScript("OnMouseDown", function(self)
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
						WardrobeOutfitFrame:Toggle(self:GetParent());
						end
					);
	UIDropDownMenu_JustifyText(self, "LEFT");
	if ( self.width ) then
		UIDropDownMenu_SetWidth(self, self.width);
	end
end

function WardrobeOutfitDropDownMixin:OnShow()
	self:RegisterEvent("TRANSMOG_OUTFITS_CHANGED");
	self:RegisterEvent("TRANSMOGRIFY_UPDATE");
	self:SelectOutfit(self:GetLastOutfitID(), true);
end

function WardrobeOutfitDropDownMixin:OnHide()
	self:UnregisterEvent("TRANSMOG_OUTFITS_CHANGED");
	self:UnregisterEvent("TRANSMOGRIFY_UPDATE");
	WardrobeOutfitFrame:ClosePopups(self);
	if ( WardrobeOutfitFrame.dropDown == self ) then
		WardrobeOutfitFrame:Hide();
	end
end

function WardrobeOutfitDropDownMixin:OnEvent(event)
	if ( event == "TRANSMOG_OUTFITS_CHANGED" ) then
		-- try to reselect the same outfit to update the name
		-- if it changed or clear the name if it got deleted
		self:SelectOutfit(self.selectedOutfitID);
		if ( WardrobeOutfitFrame:IsShown() ) then
			WardrobeOutfitFrame:Update();
		end
	end
	-- don't need to do anything for "TRANSMOGRIFY_UPDATE" beyond updating the save button
	self:UpdateSaveButton();
end

function WardrobeOutfitDropDownMixin:UpdateSaveButton()
	if ( self.selectedOutfitID ) then
		self.SaveButton:SetEnabled(not self:IsOutfitDressed());
	else
		self.SaveButton:SetEnabled(false);
	end
end

function WardrobeOutfitDropDownMixin:OnOutfitSaved(outfitID)
	-- Override in your mixin, called when a new outfit is saved
end

function WardrobeOutfitDropDownMixin:SelectOutfit(outfitID, loadOutfit)
	local name;
	if ( outfitID ) then
		name = C_TransmogCollection.GetOutfitInfo(outfitID);
	end
	if ( name ) then
		UIDropDownMenu_SetText(self, name);
	else
		outfitID = nil;
		UIDropDownMenu_SetText(self, GRAY_FONT_COLOR_CODE..TRANSMOG_OUTFIT_NONE..FONT_COLOR_CODE_CLOSE);
	end
	self.selectedOutfitID = outfitID;
	if ( loadOutfit ) then
		self:LoadOutfit(outfitID);
	end
	self:UpdateSaveButton();
	self:OnSelectOutfit(outfitID);
end

function WardrobeOutfitDropDownMixin:OnSelectOutfit(outfitID)
	-- nothing to see here
end

function WardrobeOutfitDropDownMixin:GetLastOutfitID()
	return nil;
end

local function IsSourceArtifact(sourceID)
	local link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID));
	if not link then
		return false;
	end
	local _, _, quality = GetItemInfo(link);
	return quality == Enum.ItemQuality.Artifact;
end

function WardrobeOutfitDropDownMixin:IsOutfitDressed()
	if not self.selectedOutfitID then
		return true;
	end

	local outfitItemTransmogInfoList = C_TransmogCollection.GetOutfitItemTransmogInfoList(self.selectedOutfitID);
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

function WardrobeOutfitDropDownMixin:CheckOutfitForSave(outfitID)
	local pendingAppearances = { };
	local hasInvalidAppearances = false;
	local hasValidAppearances = false;
	local itemTransmogInfoList = self:GetItemTransmogInfoList();

	-- only need to check main appearanceIDs
	-- secondaryAppearanceIDs will only be set at the transmogrifier or from ctrl-clicking in the collection, and as such are automatically valid
	-- all illusions are collectible
	for slotID, itemTransmogInfo in ipairs(itemTransmogInfoList) do
		local isValidAppearance = false;
		if TransmogUtil.IsValidTransmogSlotID(slotID) then
			local appearanceID = itemTransmogInfo.appearanceID;
			local isValidSlot = appearanceID ~= Constants.Transmog.NoTransmogID;
			-- skip offhand if mainhand is an appeance from Legion Artifacts category and the offhand matches the paired appearance
			if isValidSlot and slotID == INVSLOT_OFFHAND then
				local mhInfo = itemTransmogInfoList[INVSLOT_MAINHAND];
				if mhInfo.secondaryAppearanceID == Constants.Transmog.MainHandTransmogFromPairedCategory then
					isValidSlot = appearanceID ~= C_TransmogCollection.GetPairedArtifactAppearance(mhInfo.appearanceID);
				end
			end
			if isValidSlot then
				isValidAppearance = C_TransmogCollection.PlayerKnowsSource(appearanceID);
				if not isValidAppearance then
					local isInfoReady, canCollect = C_TransmogCollection.PlayerCanCollectSource(itemTransmogInfo.appearanceID);
					if isInfoReady then
						isValidAppearance = canCollect;
					else
						pendingAppearances[appearanceID] = slotID;
					end
				end

				if isValidAppearance then
					hasValidAppearances = true;
				else
					hasInvalidAppearances = true;
				end
			end
		end
		if not isValidAppearance then
			itemTransmogInfo:Clear();
		end
	end

	-- store the state for this save
	WardrobeOutfitFrame.pendingAppearances = pendingAppearances;
	WardrobeOutfitFrame.itemTransmogInfoList = itemTransmogInfoList;
	WardrobeOutfitFrame.hasValidAppearances = hasValidAppearances;
	WardrobeOutfitFrame.hasInvalidAppearances = hasInvalidAppearances;
	WardrobeOutfitFrame.outfitID = outfitID;
	-- save the dropdown
	WardrobeOutfitFrame.popupDropDown = self;

	WardrobeOutfitFrame:EvaluateSaveState();
end

--===================================================================================================================================
WardrobeOutfitFrameMixin = { };

WardrobeOutfitFrameMixin.popups = {
	"NAME_TRANSMOG_OUTFIT",
	"CONFIRM_DELETE_TRANSMOG_OUTFIT",
	"CONFIRM_SAVE_TRANSMOG_OUTFIT",
	"CONFIRM_OVERWRITE_TRANSMOG_OUTFIT",
	"TRANSMOG_OUTFIT_CHECKING_APPEARANCES",
	"TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES",
	"TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES",
};

local OUTFIT_FRAME_MIN_STRING_WIDTH = 152;
local OUTFIT_FRAME_MAX_STRING_WIDTH = 216;
local OUTFIT_FRAME_ADDED_PIXELS = 90;	-- pixels added to string width

function WardrobeOutfitFrameMixin:OnHide()
	self.timer = nil;
end

function WardrobeOutfitFrameMixin:Toggle(dropDown)
	if ( self.dropDown == dropDown and self:IsShown() ) then
		WardrobeOutfitFrame:Hide();
	else
		CloseDropDownMenus();
		self.dropDown = dropDown;
		self:Show();
		self:SetPoint("TOPLEFT", self.dropDown, "BOTTOMLEFT", 8, -3);
		self:Update();
	end
end

function WardrobeOutfitFrameMixin:OnUpdate(elapsed)
	local mouseFocus = GetMouseFocus();
	for i = 1, #self.Buttons do
		local button = self.Buttons[i];
		if ( button == mouseFocus or button:IsMouseOver() ) then
			if ( button.outfitID ) then
				button.EditButton:Show();
			else
				button.EditButton:Hide();
			end
			button.Highlight:Show();
		else
			button.EditButton:Hide();
			button.Highlight:Hide();
		end
	end
	if ( UIDROPDOWNMENU_OPEN_MENU ) then
		self:Hide();
	end
	if ( self.timer ) then
		self.timer = self.timer - elapsed;
		if ( self.timer < 0 ) then
			self:Hide();
		end
	end
end

function WardrobeOutfitFrameMixin:StartHideCountDown()
	self.timer = UIDROPDOWNMENU_SHOW_TIME;
end

function WardrobeOutfitFrameMixin:StopHideCountDown()
	self.timer = nil;
end

function WardrobeOutfitFrameMixin:Update()
	local outfits = C_TransmogCollection.GetOutfits();
	local buttons = self.Buttons;
	local numButtons = 0;
	local stringWidth = 0;
	local minStringWidth = self.dropDown.minMenuStringWidth or OUTFIT_FRAME_MIN_STRING_WIDTH;
	local maxStringWidth = self.dropDown.maxMenuStringWidth or OUTFIT_FRAME_MAX_STRING_WIDTH;
	self:SetWidth(maxStringWidth + OUTFIT_FRAME_ADDED_PIXELS);
	for i = 1, C_TransmogCollection.GetNumMaxOutfits() do
		local newOutfitButton = (i == (#outfits + 1));
		local outfitID = outfits[i];
		if ( outfitID or newOutfitButton ) then
			local button = buttons[i];
			if ( not button ) then
				button = CreateFrame("BUTTON", nil, self, "WardrobeOutfitButtonTemplate");
				button:SetPoint("TOPLEFT", buttons[i-1], "BOTTOMLEFT", 0, 0);
				button:SetPoint("TOPRIGHT", buttons[i-1], "BOTTOMRIGHT", 0, 0);
			end
			button:Show();
			if ( newOutfitButton ) then
				button:SetText(GREEN_FONT_COLOR_CODE..TRANSMOG_OUTFIT_NEW..FONT_COLOR_CODE_CLOSE);
				button.Icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus");
				button.outfitID = nil;
				button.Check:Hide();
				button.Selection:Hide();
			else
				if ( outfitID == self.dropDown.selectedOutfitID ) then
					button.Check:Show();
					button.Selection:Show();
				else
					button.Selection:Hide();
					button.Check:Hide();
				end
				local name, icon = C_TransmogCollection.GetOutfitInfo(outfitID);
				button.Text:SetWidth(0);
				button:SetText(NORMAL_FONT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE);
				button.Icon:SetTexture(icon);
				button.outfitID = outfitID;
			end
			stringWidth = max(stringWidth, button.Text:GetStringWidth());
			if ( button.Text:GetStringWidth() > maxStringWidth) then
				button.Text:SetWidth(maxStringWidth);
			end
			numButtons = numButtons + 1;
		else
			if ( buttons[i] ) then
				buttons[i]:Hide();
			end
		end
	end
	stringWidth = max(stringWidth, minStringWidth);
	stringWidth = min(stringWidth, maxStringWidth);
	self:SetWidth(stringWidth + OUTFIT_FRAME_ADDED_PIXELS);
	self:SetHeight(30 + numButtons * 20);
end

function WardrobeOutfitFrameMixin:NewOutfit(name)
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
	if ( self.popupDropDown ) then
		self.popupDropDown:SelectOutfit(outfitID);
		self.popupDropDown:OnOutfitSaved(outfitID);
	end
end

function WardrobeOutfitFrameMixin:DeleteOutfit(outfitID)
	C_TransmogCollection.DeleteOutfit(outfitID);
end

function WardrobeOutfitFrameMixin:NameOutfit(newName, outfitID)
	local outfits = C_TransmogCollection.GetOutfits();
	for i = 1, #outfits do
		local name, icon = C_TransmogCollection.GetOutfitInfo(outfits[i]);
		if name == newName then
			if ( outfitID ) then
				UIErrorsFrame:AddMessage(TRANSMOG_OUTFIT_ALREADY_EXISTS, 1.0, 0.1, 0.1, 1.0);
			else
				WardrobeOutfitFrame:ShowPopup("CONFIRM_OVERWRITE_TRANSMOG_OUTFIT", newName, nil, newName);
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

function WardrobeOutfitFrameMixin:ShowPopup(popup, ...)
	-- close all other popups
	for _, listPopup in pairs(self.popups) do
		if ( listPopup ~= popup ) then
			StaticPopup_Hide(listPopup);
		end
	end
	if ( popup ~= WardrobeOutfitEditFrame ) then
		StaticPopupSpecial_Hide(WardrobeOutfitEditFrame);
	end

	self.popupDropDown = self.dropDown;
	if ( popup == WardrobeOutfitEditFrame ) then
		StaticPopupSpecial_Show(WardrobeOutfitEditFrame);
	else
		StaticPopup_Show(popup, ...);
	end
end

function WardrobeOutfitFrameMixin:ClosePopups(requestingDropDown)
	if ( requestingDropDown and requestingDropDown ~= self.popupDropDown ) then
		return;
	end
	for _, popup in pairs(self.popups) do
		StaticPopup_Hide(popup);
	end
	StaticPopupSpecial_Hide(WardrobeOutfitEditFrame);

	-- clean up
	self.itemTransmogInfoList = nil;
	self.pendingAppearances = nil;
	self.hasValidAppearances = nil;
	self.hasInvalidAppearances = nil;
	self.outfitID = nil;
	self.popupDropDown = nil;
end

function WardrobeOutfitFrameMixin:EvaluateSaveState()
	if next(self.pendingAppearances) then
		-- wait
		if ( not StaticPopup_Visible("TRANSMOG_OUTFIT_CHECKING_APPEARANCES") ) then
			WardrobeOutfitFrame:ShowPopup("TRANSMOG_OUTFIT_CHECKING_APPEARANCES", nil, nil, nil, WardrobeOutfitCheckAppearancesFrame);
		end
	elseif not self.hasValidAppearances then
		-- stop
		WardrobeOutfitFrame:ShowPopup("TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES");
	elseif self.hasInvalidAppearances then
		-- warn
		WardrobeOutfitFrame:ShowPopup("TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES");
	else
		WardrobeOutfitFrame:ContinueWithSave();
	end
end

function WardrobeOutfitFrameMixin:ContinueWithSave()
	if self.outfitID then
		C_TransmogCollection.ModifyOutfit(self.outfitID, self.itemTransmogInfoList);
		self:SaveLastOutfit(self.outfitID);
		WardrobeOutfitFrame:ClosePopups();
	else
		WardrobeOutfitFrame:ShowPopup("NAME_TRANSMOG_OUTFIT");
	end
end

function WardrobeOutfitFrameMixin:SaveLastOutfit(outfitID)
	local value = outfitID or "";
	local currentSpecIndex = GetCVarBool("transmogCurrentSpecOnly") and GetSpecialization() or nil;
	for specIndex = 1, GetNumSpecializations() do
		if not currentSpecIndex or specIndex == currentSpecIndex then
			SetCVar("lastTransmogOutfitIDSpec"..specIndex, value);
		end
	end
end

--===================================================================================================================================
WardrobeOutfitButtonMixin = { };

function WardrobeOutfitButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	WardrobeOutfitFrame:Hide();
	if ( self.outfitID ) then
		WardrobeOutfitFrame.dropDown:SelectOutfit(self.outfitID, true);
	else
		if ( WardrobeTransmogFrame and HelpTip:IsShowing(WardrobeTransmogFrame, TRANSMOG_OUTFIT_DROPDOWN_TUTORIAL) ) then
			HelpTip:Hide(WardrobeTransmogFrame, TRANSMOG_OUTFIT_DROPDOWN_TUTORIAL);
			SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_OUTFIT_DROPDOWN, true);
		end
		WardrobeOutfitFrame.dropDown:CheckOutfitForSave();
	end
end

--===================================================================================================================================
WardrobeOutfitEditFrameMixin = { };

function WardrobeOutfitEditFrameMixin:ShowForOutfit(outfitID)
	WardrobeOutfitFrame:Hide();
	WardrobeOutfitFrame:ShowPopup(self);
	self.outfitID = outfitID;
	local name, icon = C_TransmogCollection.GetOutfitInfo(outfitID);
	self.EditBox:SetText(name);
end

function WardrobeOutfitEditFrameMixin:OnDelete()
	WardrobeOutfitFrame:Hide();
	local name = C_TransmogCollection.GetOutfitInfo(self.outfitID);
	WardrobeOutfitFrame:ShowPopup("CONFIRM_DELETE_TRANSMOG_OUTFIT", name, nil,  self.outfitID);
end

function WardrobeOutfitEditFrameMixin:OnAccept()
	if ( not self.AcceptButton:IsEnabled() ) then
		return;
	end
	StaticPopupSpecial_Hide(self);
	WardrobeOutfitFrame:NameOutfit(self.EditBox:GetText(), self.outfitID);
end

--===================================================================================================================================
WardrobeOutfitCheckAppearancesMixin = { };

function WardrobeOutfitCheckAppearancesMixin:OnLoad()
	self.Anim:Play();
end

function WardrobeOutfitCheckAppearancesMixin:OnShow()
	self:RegisterEvent("TRANSMOG_SOURCE_COLLECTABILITY_UPDATE");
end

function WardrobeOutfitCheckAppearancesMixin:OnHide()
	self:UnregisterEvent("TRANSMOG_SOURCE_COLLECTABILITY_UPDATE");
end

function WardrobeOutfitCheckAppearancesMixin:OnEvent(event, appearanceID, canCollect)
	local slotID = WardrobeOutfitFrame.pendingAppearances[appearanceID];
	if slotID then
		if not canCollect then
			WardrobeOutfitFrame.hasInvalidAppearances = true;
			for i, itemTransmogInfo in ipairs(WardrobeOutfitFrame.itemTransmogInfoList) do
				if itemTransmogInfo.appearanceID == appearanceID then
					itemTransmogInfo:Clear();
				end
			end
		end
		WardrobeOutfitFrame.pendingAppearances[appearanceID] = nil;
		WardrobeOutfitFrame:EvaluateSaveState();
	end
end