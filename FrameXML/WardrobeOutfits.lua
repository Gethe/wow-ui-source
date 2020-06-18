
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
end

function WardrobeOutfitDropDownMixin:SelectOutfit(outfitID, loadOutfit)
	local name;
	if ( outfitID ) then
		name = C_TransmogCollection.GetOutfitName(outfitID);
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
	if ( not self.selectedOutfitID ) then
		return true;
	end
	local appearanceSources, mainHandEnchant, offHandEnchant = C_TransmogCollection.GetOutfitSources(self.selectedOutfitID);
	if ( not appearanceSources ) then
		return true;
	end

	for key, transmogSlot in pairs(TRANSMOG_SLOTS) do
		if transmogSlot.location:IsAppearance() then
			local sourceID = self:GetSlotSourceID(transmogSlot.location);
			local slotID = transmogSlot.location:GetSlotID();
			if ( sourceID ~= NO_TRANSMOG_SOURCE_ID and sourceID ~= appearanceSources[slotID] ) then
				-- No artifacts in outfits, their sourceID is overriden to NO_TRANSMOG_SOURCE_ID
				if ( not IsSourceArtifact(sourceID) or appearanceSources[slotID] ~= NO_TRANSMOG_SOURCE_ID ) then
					return false;
				end
			end
		end
	end
	local mainHandIllusionTransmogLocation = TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.None);
	local mainHandSourceID = self:GetSlotSourceID(mainHandIllusionTransmogLocation);
	if ( mainHandSourceID ~= mainHandEnchant ) then
		return false;
	end
	local offHandIllusionTransmogLocation = TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.None);
	local offHandSourceID = self:GetSlotSourceID(offHandIllusionTransmogLocation);
	if ( offHandSourceID ~= offHandEnchant ) then
		return false;
	end
	return true;
end

function WardrobeOutfitDropDownMixin:CheckOutfitForSave(name)
	local sources = { };
	local mainHandEnchant, offHandEnchant;
	local pendingSources = { };
	local hadInvalidSources = false;

	for key, transmogSlot in pairs(TRANSMOG_SLOTS) do
		local sourceID = self:GetSlotSourceID(transmogSlot.location);
		if ( sourceID ~= NO_TRANSMOG_SOURCE_ID ) then
			if ( transmogSlot.location:IsAppearance() ) then
				local slotID = transmogSlot.location:GetSlotID();
				local isValidSource = C_TransmogCollection.PlayerKnowsSource(sourceID);
				if ( not isValidSource ) then
					local isInfoReady, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID);
					if ( isInfoReady ) then
						if ( canCollect ) then
							isValidSource = true;
						else
							-- hack: ignore artifacts
							if (not IsSourceArtifact(sourceID)) then
								hadInvalidSources = true;
							end
						end
					else
						-- saving the "slot" for the sourceID
						pendingSources[sourceID] = slotID;
					end
				end
				if ( isValidSource ) then
					-- No artifacts in outfits, their sourceID is overriden to NO_TRANSMOG_SOURCE_ID
					if ( IsSourceArtifact(sourceID) ) then
						sources[slotID] = NO_TRANSMOG_SOURCE_ID;
					else
						sources[slotID] = sourceID;
					end
				end
			elseif ( transmogSlot.location:IsIllusion() ) then
				if ( transmogSlot.location:IsMainHand() ) then
					mainHandEnchant = sourceID;
				else
					offHandEnchant = sourceID;
				end
			end
		end
	end

	-- store the state for this save
	WardrobeOutfitFrame.sources = sources;
	WardrobeOutfitFrame.mainHandEnchant = mainHandEnchant;
	WardrobeOutfitFrame.offHandEnchant = offHandEnchant;
	WardrobeOutfitFrame.pendingSources = pendingSources;
	WardrobeOutfitFrame.hadInvalidSources = hadInvalidSources;
	WardrobeOutfitFrame.name = name;
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
		if ( outfits[i] or newOutfitButton ) then
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
				if ( outfits[i].outfitID == self.dropDown.selectedOutfitID ) then
					button.Check:Show();
					button.Selection:Show();
				else
					button.Selection:Hide();
					button.Check:Hide();
				end
				button.Text:SetWidth(0);
				button:SetText(NORMAL_FONT_COLOR_CODE..outfits[i].name..FONT_COLOR_CODE_CLOSE);
				button.Icon:SetTexture(outfits[i].icon);
				button.outfitID = outfits[i].outfitID;
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

function WardrobeOutfitFrameMixin:SaveOutfit(name)
	local icon;
	for key, transmogSlot in pairs(TRANSMOG_SLOTS) do
		if ( transmogSlot.location:IsAppearance() ) then
			local slotID = transmogSlot.location:GetSlotID();
			local sourceID = self.sources[slotID];
			if ( sourceID ) then
				icon = select(4, C_TransmogCollection.GetAppearanceSourceInfo(sourceID));
				if ( icon ) then
					break;
				end
			end
		end
	end
		
	local outfitID = C_TransmogCollection.SaveOutfit(name, self.sources, self.mainHandEnchant, self.offHandEnchant, icon);
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
		if ( outfits[i].name == newName ) then
			if ( outfitID ) then
				UIErrorsFrame:AddMessage(TRANSMOG_OUTFIT_ALREADY_EXISTS, 1.0, 0.1, 0.1, 1.0);
			else
				WardrobeOutfitFrame:ShowPopup("CONFIRM_OVERWRITE_TRANSMOG_OUTFIT", newName, nil, newName);
			end
			return;
		end
	end
	if ( outfitID ) then
		-- this is a rename
		C_TransmogCollection.ModifyOutfit(outfitID, newName);
	else
		-- this is a new outfit
		self:SaveOutfit(newName);
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
	self.sources = nil;
	self.mainHandEnchant = nil;
	self.offHandEnchant = nil;
	self.pendingSources = nil;
	self.hadInvalidSources = nil;
	self.name = nil;
	self.popupDropDown = nil;
end

function WardrobeOutfitFrameMixin:EvaluateSaveState()
	if ( next(self.pendingSources) ) then
		-- wait
		if ( not StaticPopup_Visible("TRANSMOG_OUTFIT_CHECKING_APPEARANCES") ) then
			WardrobeOutfitFrame:ShowPopup("TRANSMOG_OUTFIT_CHECKING_APPEARANCES", nil, nil, nil, WardrobeOutfitCheckAppearancesFrame);
		end
	elseif ( self.hadInvalidSources ) then
		if ( next(self.sources) ) then
			-- warn
			WardrobeOutfitFrame:ShowPopup("TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES");
		else
			-- stop
			WardrobeOutfitFrame:ShowPopup("TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES");
		end
	else
		WardrobeOutfitFrame:ContinueWithSave();
	end
end

function WardrobeOutfitFrameMixin:ContinueWithSave()
	if ( self.name ) then
		WardrobeOutfitFrame:SaveOutfit(self.name);
		WardrobeOutfitFrame:ClosePopups();
	else
		WardrobeOutfitFrame:ShowPopup("NAME_TRANSMOG_OUTFIT");
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
	self.EditBox:SetText(C_TransmogCollection.GetOutfitName(outfitID));
end

function WardrobeOutfitEditFrameMixin:OnDelete()
	WardrobeOutfitFrame:Hide();
	local name = C_TransmogCollection.GetOutfitName(self.outfitID);
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

function WardrobeOutfitCheckAppearancesMixin:OnEvent(event, sourceID, canCollect)
	if ( WardrobeOutfitFrame.pendingSources[sourceID] ) then
		if ( canCollect ) then
			local slotID = WardrobeOutfitFrame.pendingSources[sourceID];
			WardrobeOutfitFrame.sources[slotID] = sourceID;
		else
			WardrobeOutfitFrame.hadInvalidSources = true;
		end
		WardrobeOutfitFrame.pendingSources[sourceID] = nil;
		WardrobeOutfitFrame:EvaluateSaveState();
	end
end