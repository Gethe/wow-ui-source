StaticPopupDialogs["CONFIRM_BUY_OUTFIT_SLOT"] = {
	text = CONFIRM_BUY_OUTFIT_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(_dialog, _data)
		-- Check if player can afford.
		local nextOutfitCost = C_TransmogOutfitInfo.GetNextOutfitCost();
		if GetMoney() < nextOutfitCost then
			UIErrorsFrame:AddMessage(ERR_TRANSMOG_OUTFIT_SLOT_CANNOT_AFFORD, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			return;
		end

		TransmogFrame.OutfitPopup.mode = IconSelectorPopupFrameModes.New;
		TransmogFrame.OutfitPopup:Show();
	end,
	OnShow = function(dialog, _data)
		local nextOutfitCost = C_TransmogOutfitInfo.GetNextOutfitCost();
		MoneyFrame_Update(dialog.MoneyFrame, nextOutfitCost);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["TRANSMOG_OUTFIT_INVALID_NAME"] = {
	text = TRANSMOG_OUTFIT_INVALID_NAME,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(_dialog, data)
		TransmogFrame.OutfitPopup.mode = data.mode;
		TransmogFrame.OutfitPopup.outfitData = data.outfitData;
		TransmogFrame.OutfitPopup:Show();
	end,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["TRANSMOG_PENDING_CHANGES"] = {
	text = TRANSMOG_PENDING_CHANGES,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(_dialog, data)
		if data.confirmCallback then
			data.confirmCallback();
		end
	end,
	timeout = 0,
	hideOnEscape = 1
};

TransmogFrameMixin = {
	DYNAMIC_EVENTS = {
		"TRANSMOG_OUTFITS_CHANGED",
		"TRANSMOG_DISPLAYED_OUTFIT_CHANGED",
		"VIEWED_TRANSMOG_OUTFIT_SLOT_REFRESH",
		"VIEWED_TRANSMOG_OUTFIT_SITUATIONS_CHANGED",
		"PLAYER_SPECIALIZATION_CHANGED",
		"DISPLAY_SIZE_CHANGED",
		"UI_SCALE_CHANGED"
	};
	HELP_PLATE_INFO = {
		FramePos = { x = 0,	y = -21 },
		-- Base positions and sizes to reference, as the transmog frame uses the 'checkFit' UIPanel setting to adjust its scale.
		-- Actual positions and sizes set in RefreshHelpPlate.
		FrameSizeBase = { width = 1618, height = 861 },
		[1] = { ButtonPosBase = { x = 133, y = -328 }, HighLightBoxBase = { x = 3, y = -99, width = 308, height = 758 }, ToolTipDir = "DOWN", ToolTipText = TRANSMOG_HELP_1 },
		[2] = { ButtonPosBase = { x = 618, y = -328 }, HighLightBoxBase = { x = 315, y = -3, width = 651, height = 854 }, ToolTipDir = "DOWN", ToolTipText = TRANSMOG_HELP_2 },
		[3] = { ButtonPosBase = { x = 1269, y = -328 }, HighLightBoxBase = { x = 970, y = -3, width = 644, height = 854 }, ToolTipDir = "DOWN", ToolTipText = TRANSMOG_HELP_3 },
	};
};

function TransmogFrameMixin:OnLoad()
	self:SetPortraitAtlasRaw("transmog-icon-ui");
	self:SetTitle(TRANSMOGRIFY);

	self.HelpPlateButton:SetScript("OnClick", function()
		if not HelpPlate.IsShowingHelpInfo(self.HELP_PLATE_INFO) then
			self:RefreshHelpPlate();
			HelpPlate.Show(self.HELP_PLATE_INFO, self, self.HelpPlateButton);
		else
			local userToggled = true;
			HelpPlate.Hide(userToggled);
		end
	end);

	self.WardrobeCollection.GetSelectedSlotCallback = GenerateClosure(self.CharacterPreview.GetSelectedSlotData, self.CharacterPreview);
	self.WardrobeCollection.GetCurrentTransmogInfoCallback = GenerateClosure(self.CharacterPreview.GetCurrentTransmogInfo, self.CharacterPreview);
	self.WardrobeCollection.GetItemTransmogInfoListCallback = GenerateClosure(self.CharacterPreview.GetItemTransmogInfoList, self.CharacterPreview);
	self.WardrobeCollection.GetSlotFrameCallback = GenerateClosure(self.CharacterPreview.GetSlotFrame, self.CharacterPreview);
end

function TransmogFrameMixin:OnShow()
	PlaySound(SOUNDKIT.UI_TRANSMOG_OPEN_WINDOW);

	FrameUtil.RegisterFrameForEvents(self, self.DYNAMIC_EVENTS);

	local selectActiveOutfit = true;
	self:RefreshOutfits(selectActiveOutfit);
	self:UpdateCostDisplay();
end

function TransmogFrameMixin:OnHide()
	PlaySound(SOUNDKIT.UI_TRANSMOG_CLOSE_WINDOW);

	FrameUtil.UnregisterFrameForEvents(self, self.DYNAMIC_EVENTS);

	-- Clean up any open dialogs.
	StaticPopup_Hide("CONFIRM_BUY_OUTFIT_SLOT");
	StaticPopup_Hide("TRANSMOG_OUTFIT_INVALID_NAME");
	StaticPopup_Hide("TRANSMOG_PENDING_CHANGES");
	StaticPopup_Hide("CONFIRM_DELETE_TRANSMOG_CUSTOM_SET");
	StaticPopup_Hide("TRANSMOG_CUSTOM_SET_NAME");
	StaticPopup_Hide("TRANSMOG_CUSTOM_SET_CONFIRM_OVERWRITE");
	self.OutfitPopup:Hide();

	local userToggled = false;
	HelpPlate.Hide(userToggled);

	-- Reset any pending changes.
	C_TransmogOutfitInfo.ClearAllPendingTransmogs();
	C_TransmogOutfitInfo.ClearAllPendingSituations();

	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Transmogrifier);
end

function TransmogFrameMixin:OnEvent(event, ...)
	if event == "TRANSMOG_OUTFITS_CHANGED" then
		local newOutfitID = ...;
		local selectActiveOutfit = false;
		self:RefreshOutfits(selectActiveOutfit);

		if newOutfitID then
			self.OutfitCollection:AnimateOutfitAdded(newOutfitID);
		end
	elseif event == "TRANSMOG_DISPLAYED_OUTFIT_CHANGED" then
		local selectActiveOutfit = false;
		self:RefreshOutfits(selectActiveOutfit);
	elseif event == "VIEWED_TRANSMOG_OUTFIT_SLOT_REFRESH" or event == "VIEWED_TRANSMOG_OUTFIT_SITUATIONS_CHANGED" then
		self:UpdateCostDisplay();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:RefreshSlots();
	elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		self:RefreshHelpPlate();
	end
end

function TransmogFrameMixin:RefreshOutfits(selectActiveOutfit)
	-- Build up the list of outfits.
	local dataProvider = CreateDataProvider();
	local outfitsInfo = C_TransmogOutfitInfo.GetOutfitsInfo();
	if outfitsInfo then
		for _index, outfitInfo in ipairs(outfitsInfo) do
			local onClickCallback = function()
				self.WardrobeCollection:SetToItemsTab();
			end;

			local onEditCallback = function()
				local popupData = {
					outfitID = outfitInfo.outfitID,
					name = outfitInfo.name,
					icon = outfitInfo.icon
				};

				self.OutfitPopup.mode = IconSelectorPopupFrameModes.Edit;
				self.OutfitPopup.outfitData = popupData;
				self.OutfitPopup:Show();

				HelpTip:HideAllSystem("TransmogOutfitCollection");
			end;

			local outfitData = {
				outfitID = outfitInfo.outfitID,
				name = outfitInfo.name,
				situationCategories = outfitInfo.situationCategories,
				icon = outfitInfo.icon,
				onClickCallback = onClickCallback,
				onEditCallback = onEditCallback
			};

			dataProvider:Insert(outfitData);
		end
	end

	self.OutfitCollection:Refresh(dataProvider, selectActiveOutfit);
end

function TransmogFrameMixin:RefreshSlots()
	-- Some action was done that could have changed slot info (weapon options, enabled state, etc.). Refresh things to reflect any new state.
	local clearCurrentWeaponOptionInfo = false;
	self.CharacterPreview:RefreshSlotWeaponOptions(clearCurrentWeaponOptionInfo);
	self.CharacterPreview:RefreshSlots();

	-- Update collection in case the selected slot changed.
	self.WardrobeCollection:UpdateSlot(self.CharacterPreview:GetSelectedSlotData());
end

function TransmogFrameMixin:RefreshHelpPlate()
	local relativeScale = self:GetEffectiveScale() / HelpPlate.GetEffectiveScale();

	self.HELP_PLATE_INFO.FrameSize = {
		width = self.HELP_PLATE_INFO.FrameSizeBase.width * relativeScale,
		height = self.HELP_PLATE_INFO.FrameSizeBase.height * relativeScale
	};

	local function UpdateHelpPlateSection(helpPlate)
		helpPlate.ButtonPos = {
			x = helpPlate.ButtonPosBase.x * relativeScale,
			y = helpPlate.ButtonPosBase.y * relativeScale
		};
		helpPlate.HighLightBox = {
			x = helpPlate.HighLightBoxBase.x * relativeScale,
			y = helpPlate.HighLightBoxBase.y * relativeScale,
			width = helpPlate.HighLightBoxBase.width * relativeScale,
			height = helpPlate.HighLightBoxBase.height * relativeScale
		};
	end

	UpdateHelpPlateSection(self.HELP_PLATE_INFO[1]);
	UpdateHelpPlateSection(self.HELP_PLATE_INFO[2]);
	UpdateHelpPlateSection(self.HELP_PLATE_INFO[3]);

	if HelpPlate.IsShowingHelpInfo(self.HELP_PLATE_INFO) then
		HelpPlate.Show(self.HELP_PLATE_INFO, self, self.HelpPlateButton);
	end
end

function TransmogFrameMixin:UpdateCostDisplay()
	local cost = C_TransmogOutfitInfo.GetPendingTransmogCost();
	local canApply = false;
	if cost and cost > GetMoney() then
		SetMoneyFrameColor(self.OutfitCollection.MoneyFrame.Money, "red");
	else
		SetMoneyFrameColor(self.OutfitCollection.MoneyFrame.Money);
		if cost then
			canApply = true;
		end
	end

	-- Always show 0 copper.
	MoneyFrame_Update(self.OutfitCollection.MoneyFrame.Money, cost or 0, true);
	self.OutfitCollection.SaveOutfitButton:SetEnabled(canApply);
	self.CharacterPreview.ClearAllPendingButton:SetShown(canApply);
end

function TransmogFrameMixin:SelectSlot(slotFrame, forceRefresh)
	-- Visually update selected slot
	self.CharacterPreview:UpdateSlot(slotFrame.slotData, forceRefresh);

	-- Navigate to correct items in collection.
	self.WardrobeCollection:UpdateSlot(slotFrame.slotData, forceRefresh);
end


TransmogOutfitCollectionMixin = {
	DYNAMIC_EVENTS = {
		"VIEWED_TRANSMOG_OUTFIT_CHANGED",
		"VIEWED_TRANSMOG_OUTFIT_SLOT_SAVE_SUCCESS"
	};
	HELPTIP_INFO = {
		text = TRANSMOG_OUTFITS_HELPTIP,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.RightEdgeTop,
		alignment = HelpTip.Alignment.Center,
		offsetX = -33,
		offsetY = -33,
		system = "TransmogOutfitCollection",
		acknowledgeOnHide = true,
		cvarBitfield = "closedInfoFramesAccountWide",
		bitfieldFlag = Enum.FrameTutorialAccount.TransmogOutfits
	};
};

function TransmogOutfitCollectionMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();

	view:SetElementInitializer("TransmogOutfitEntryTemplate", function(frame, elementData)
		frame:Init(elementData);
	end);

	local padTop = 8;
	local pad = 0;
	local spacing = 2;
	view:SetPadding(padTop, pad, pad, pad, spacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.OutfitList.ScrollBox, self.OutfitList.ScrollBar, view);
	ScrollUtil.AddResizableChildrenBehavior(self.OutfitList.ScrollBox);

	self.PurchaseOutfitButton:SetScript("OnMouseDown", function(button)
		button.Icon:SetPoint("LEFT", 16, -2);
	end);

	self.PurchaseOutfitButton:SetScript("OnMouseUp", function(button)
		button.Icon:SetPoint("LEFT", 14, 0);
	end);

	self.PurchaseOutfitButton:SetScript("OnEnter", function(button)
		if not button:IsEnabled() then
			GameTooltip_ShowDisabledTooltip(GameTooltip, button, TRANSMOG_PURCHASE_OUTFIT_SLOT_TOOLTIP_DISABLED:format(C_TransmogOutfitInfo.GetMaxNumberOfUsableOutfits()), "ANCHOR_RIGHT");
		end
	end);

	self.PurchaseOutfitButton:SetScript("OnLeave", GameTooltip_Hide);

	self.PurchaseOutfitButton:SetScript("OnClick", function()
		local function ClickCallback()
			-- Explicitly hide pending popup if showing so the confirm dialog is positioned correctly.
			StaticPopup_Hide("TRANSMOG_PENDING_CHANGES");
			StaticPopup_Show("CONFIRM_BUY_OUTFIT_SLOT");

			HelpTip:HideAllSystem("TransmogOutfitCollection");
		end;

		if C_TransmogOutfitInfo.HasPendingOutfitTransmogs() or C_TransmogOutfitInfo.HasPendingOutfitSituations() then
			local dialogData = {
				confirmCallback = ClickCallback
			};
			StaticPopup_Show("TRANSMOG_PENDING_CHANGES", nil, nil, dialogData);
		else
			ClickCallback();
		end
	end);

	self.SaveOutfitButton:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip:SetText(TRANSMOG_SAVE_OUTFIT_TOOLTIP);
	end);

	self.SaveOutfitButton:SetScript("OnLeave", GameTooltip_Hide);

	self.SaveOutfitButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.UI_TRANSMOG_APPLY_V2);
		C_TransmogOutfitInfo.CommitAndApplyAllPending();

		HelpTip:HideAllSystem("TransmogOutfitCollection");
	end);

	SmallMoneyFrame_OnLoad(self.MoneyFrame.Money);
	MoneyFrame_SetType(self.MoneyFrame.Money, "STATIC");
end

function TransmogOutfitCollectionMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, self.DYNAMIC_EVENTS);

	self.canScrollToOutfit = true;
	self.OutfitList.ScrollBox:ScrollToBegin();
end

function TransmogOutfitCollectionMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, self.DYNAMIC_EVENTS);
end

function TransmogOutfitCollectionMixin:OnEvent(event, ...)
	if event == "VIEWED_TRANSMOG_OUTFIT_CHANGED" then
		self:UpdateSelectedOutfit();
	elseif event == "VIEWED_TRANSMOG_OUTFIT_SLOT_SAVE_SUCCESS" then
		local _slot, _type, _weaponOption = ...;

		-- Already set to true, do not restart animations if multiple slots are changing.
		if self:GetOutfitSavedState() then
			return;
		end

		self:AnimateViewedOutfitSaved();
	end
end

function TransmogOutfitCollectionMixin:Refresh(dataProvider, selectActiveOutfit)
	self.OutfitList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	self:UpdateShowEquippedGearButton();

	self:CheckShowHelptips();

	-- Active outfit is the outfit the player is wearing out in the world, viewed is what is being viewed in the transmog frame.
	local viewedOutfitID = C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID();
	local outfitID = selectActiveOutfit and C_TransmogOutfitInfo.GetActiveOutfitID() or viewedOutfitID;
	if outfitID == 0 then
		local firstElementData = dataProvider:Find(1);
		outfitID = firstElementData.outfitID;
	end

	-- Make sure to set the viewed outfit when first opening the frame, otherwise only call if it changed.
	if selectActiveOutfit or outfitID ~= viewedOutfitID then
		C_TransmogOutfitInfo.ChangeViewedOutfit(outfitID);
	end

	-- Check to see if we can purchase more outfits (the outfit list might now be at the max number of slots allowed).
	local source = Enum.TransmogOutfitEntrySource.PlayerPurchased;
	local unlockedOutfitCount = C_TransmogOutfitInfo.GetNumberOfOutfitsUnlockedForSource(source);
	local maxOutfitCount = C_TransmogOutfitInfo.GetMaxNumberOfTotalOutfitsForSource(source);
	local enabled = unlockedOutfitCount < maxOutfitCount;
	self.PurchaseOutfitButton:SetEnabled(enabled);
	self.PurchaseOutfitButton.Icon:SetDesaturated(not enabled);
end

function TransmogOutfitCollectionMixin:CheckShowHelptips()
	if not GetCVarBitfield("closedInfoFramesAccountWide", Enum.FrameTutorialAccount.TransmogOutfits) then
		-- Use OutfitList as the parent instead of any scroll box element to prevent the help tip being masked.
		HelpTip:Show(self.OutfitList, self.HELPTIP_INFO);
	end
end

function TransmogOutfitCollectionMixin:UpdateShowEquippedGearButton()
	local overlayFX = self.ShowEquippedGearSpellFrame.OverlayFX;

	local activeOutfit = C_TransmogOutfitInfo.IsEquippedGearOutfitDisplayed();
	overlayFX.OverlayActive:SetShown(activeOutfit);
	self.ShowEquippedGearSpellFrame.Label:SetFontObject(activeOutfit and "GameFontHighlight" or "GameFontNormal");
	self.ShowEquippedGearSpellFrame.Checkmark:SetShown(activeOutfit);

	local isLockedOutfit = C_TransmogOutfitInfo.IsEquippedGearOutfitLocked();
	overlayFX.OverlayLocked:SetShown(isLockedOutfit);
	overlayFX.OverlayLocked:ShowAutoCastEnabled(isLockedOutfit);
end

function TransmogOutfitCollectionMixin:UpdateSelectedOutfit()
	local viewedOutfitID = C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID();

	if self.canScrollToOutfit then
		local alignment = ScrollBoxConstants.AlignNearest;
		self:ScrollToOutfit(viewedOutfitID, alignment);
		self.canScrollToOutfit = false;
	end

	self.OutfitList.ScrollBox:ForEachFrame(function(frame)
		local elementData = frame:GetElementData();
		if elementData then
			frame:SetSelected(elementData.outfitID == viewedOutfitID);
		end
	end);
end

function TransmogOutfitCollectionMixin:ScrollToOutfit(outfitID, alignment)
	local scrollBox = self.OutfitList.ScrollBox;
	local elementData = scrollBox:FindElementDataByPredicate(function(elementData)
		return elementData.outfitID == outfitID;
	end);

	if elementData then
		scrollBox:ScrollToElementData(elementData, alignment);
	end
end

function TransmogOutfitCollectionMixin:AnimateViewedOutfitSaved()
	local outfitSaved = true;
	self:SetOutfitSavedState(outfitSaved);

	local viewedOutfitID = C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID();
	local alignment = ScrollBoxConstants.AlignBegin;
	self:ScrollToOutfit(viewedOutfitID, alignment);

	self.OutfitList.ScrollBox:ForEachFrame(function(frame)
		local elementData = frame:GetElementData();
		if elementData and elementData.outfitID == viewedOutfitID then
			local animSaved = frame.OutfitButton.AnimSaved;
			animSaved:SetScript("OnFinished", function()
				animSaved:SetScript("OnFinished", nil);
				outfitSaved = false;
				self:SetOutfitSavedState(outfitSaved);
			end);
			animSaved:Restart();
		end
	end);
end

function TransmogOutfitCollectionMixin:AnimateOutfitAdded(outfitID)
	local alignment = ScrollBoxConstants.AlignBegin;
	self:ScrollToOutfit(outfitID, alignment);

	self.OutfitList.ScrollBox:ForEachFrame(function(frame)
		local elementData = frame:GetElementData();
		if elementData and elementData.outfitID == outfitID then
			frame.OutfitButton.AnimNew:Restart();
		end
	end);
end

function TransmogOutfitCollectionMixin:GetOutfitSavedState()
	return self.outfitSaved;
end

function TransmogOutfitCollectionMixin:SetOutfitSavedState(outfitSaved)
	self.outfitSaved = outfitSaved;
end


ShowEquippedGearSpellFrameMixin = {};

function ShowEquippedGearSpellFrameMixin:OnLoad()
	UIPanelSpellButtonFrameMixin.OnLoad(self);

	local drawBling = false;
	self.Button.Cooldown:SetDrawBling(drawBling);

	self.Button.Icon:ClearAllPoints();
	self.Button.Icon:SetSize(36, 36);
	self.Button.Icon:SetPoint("CENTER");

	self.Button:ClearPushedTexture();
	self.Button:SetHighlightAtlas("transmog-outfit-spellframe", "ADD");
end

function ShowEquippedGearSpellFrameMixin:OnIconClick(_button, buttonName)
	local function ClickCallback()
		local toggleLock = false;

		if buttonName == "RightButton" then
			toggleLock = true;
		end

		C_TransmogOutfitInfo.ClearDisplayedOutfit(Enum.TransmogSituationTrigger.Manual, toggleLock);
	end;

	-- If already active and normally clicking, nothing will happen so don't possibly show pending dialog.
	local activeOutfit = C_TransmogOutfitInfo.IsEquippedGearOutfitDisplayed();
	if activeOutfit and buttonName == "LeftButton" then
		return;
	end

	if C_TransmogOutfitInfo.HasPendingOutfitTransmogs() or C_TransmogOutfitInfo.HasPendingOutfitSituations() then
		local dialogData = {
			confirmCallback = ClickCallback
		};
		StaticPopup_Show("TRANSMOG_PENDING_CHANGES", nil, nil, dialogData);
	else
		ClickCallback();
	end
end

function ShowEquippedGearSpellFrameMixin:OnIconDragStart()
	-- PickupOutfit with outfitID of 0 is a special case for this spell.
	C_TransmogOutfitInfo.PickupOutfit(0);
end


TransmogOutfitPopupMixin = {};

-- Overridden.
function TransmogOutfitPopupMixin:OnShow()
	IconSelectorPopupFrameTemplateMixin.OnShow(self);

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	self.BorderBox.IconSelectorEditBox:SetFocus();
	self.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Equipment);
	self:SetIconFilter(IconSelectorPopupFrameIconFilterTypes.All);
	self:Update();
	self.BorderBox.IconSelectorEditBox:OnTextChanged();

	local function OnIconSelected(_selectionIndex, icon)
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon);

		-- Index is not yet set, but we know if an icon in IconSelector was selected it was in the list, so set directly.
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_CLICK);
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetFontObject(GameFontHighlightSmall);
	end
	self.IconSelector:SetSelectedCallback(OnIconSelected);
end

-- Overridden.
function TransmogOutfitPopupMixin:OnHide()
	IconSelectorPopupFrameTemplateMixin.OnHide(self);

	self.outfitData = nil;
end

-- Overridden.
function TransmogOutfitPopupMixin:Update()
	if self.mode == IconSelectorPopupFrameModes.New then
		self.BorderBox.IconSelectorEditBox:SetText("");

		local initialIndex = 1;
		self.IconSelector:SetSelectedIndex(initialIndex);
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self:GetIconByIndex(initialIndex));
	elseif self.mode == IconSelectorPopupFrameModes.Edit and self.outfitData then
		self.BorderBox.IconSelectorEditBox:SetText(self.outfitData.name);
		self.BorderBox.IconSelectorEditBox:HighlightText();

		self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(self.outfitData.icon));
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self.outfitData.icon);
	end

	local getSelection = GenerateClosure(self.GetIconByIndex, self);
	local getNumSelections = GenerateClosure(self.GetNumIcons, self);
	self.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections);
	self.IconSelector:ScrollToSelectedIndex();

	self:SetSelectedIconText();
end

-- Overridden.
function TransmogOutfitPopupMixin:OkayButton_OnClick()
	local iconTexture = self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture();
	local text = self.BorderBox.IconSelectorEditBox:GetText();

	-- Validate name.
	if not C_TransmogOutfitInfo.IsValidTransmogOutfitName(text) then
		local dialogData = {
			mode = self.mode,
			outfitData = self.outfitData
		};
		StaticPopup_Show("TRANSMOG_OUTFIT_INVALID_NAME", nil, nil, dialogData);
	else
		if self.mode == IconSelectorPopupFrameModes.New then
			C_TransmogOutfitInfo.AddNewOutfit(text, iconTexture);
		elseif self.mode == IconSelectorPopupFrameModes.Edit and self.outfitData then
			C_TransmogOutfitInfo.CommitOutfitInfo(self.outfitData.outfitID, text, iconTexture);
		end
	end

	-- Run at the end, as this will hide the frame and thus clear outfitData.
	IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick(self);
end


TransmogCharacterMixin = {
	DYNAMIC_EVENTS = {
		"VIEWED_TRANSMOG_OUTFIT_SLOT_SAVE_SUCCESS",
		"VIEWED_TRANSMOG_OUTFIT_CHANGED",
		"VIEWED_TRANSMOG_OUTFIT_SLOT_REFRESH",
		"VIEWED_TRANSMOG_OUTFIT_SLOT_WEAPON_OPTION_CHANGED",
		"VIEWED_TRANSMOG_OUTFIT_SECONDARY_SLOTS_CHANGED",
		"TRANSMOG_DISPLAYED_OUTFIT_CHANGED",
		"PLAYER_EQUIPMENT_CHANGED"
	};
	HELPTIP_INFO = {
		text = TRANSMOG_WEAPON_OPTIONS_HELPTIP,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		alignment = HelpTip.Alignment.Center,
		system = "TransmogCharacter",
		acknowledgeOnHide = true,
		cvarBitfield = "closedInfoFramesAccountWide",
		bitfieldFlag = Enum.FrameTutorialAccount.TransmogWeaponOptions
	};
};

function TransmogCharacterMixin:OnLoad()
	self.SavedFrame.Anim:SetScript("OnFinished", function()
		self.SavedFrame:Hide();
	end);

	self.HideIgnoredToggle.Checkbox:SetScript("OnClick", function()
		local toggledOn = not GetCVarBool("transmogHideIgnoredSlots");
		if toggledOn then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		end

		SetCVar("transmogHideIgnoredSlots", toggledOn);
		self:RefreshHideIgnoredToggle();
		self:RefreshSlots();
	end);

	self.ClearAllPendingButton:SetScript("OnMouseDown", function(button)
		button.Icon:SetPoint("CENTER", 2, -2);
	end);

	self.ClearAllPendingButton:SetScript("OnMouseUp", function(button)
		button.Icon:SetPoint("CENTER");
	end);

	self.ClearAllPendingButton:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip:SetText(TRANSMOGRIFY_CLEAR_ALL_PENDING);
	end);

	self.ClearAllPendingButton:SetScript("OnLeave", GameTooltip_Hide);

	self.ClearAllPendingButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.UI_TRANSMOG_REVERTING_GEAR_SLOT);
		C_TransmogOutfitInfo.ClearAllPendingTransmogs();
	end);

	local function OnSlotReleased(pool, slot)
		slot:Release();
		Pool_HideAndClearAnchors(pool, slot);
	end
	self.CharacterAppearanceSlotFramePool = CreateFramePool("BUTTON", self, "TransmogAppearanceSlotTemplate", OnSlotReleased);
	self.CharacterIllusionSlotFramePool = CreateFramePool("BUTTON", self, "TransmogIllusionSlotTemplate", OnSlotReleased);

	self.ModelScene.ControlFrame:SetModelScene(self.ModelScene);
end

function TransmogCharacterMixin:OnShow()
	local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
	if hasAlternateForm then
		self:RegisterUnitEvent("UNIT_FORM_CHANGED", "player");
		self.inAlternateForm = inAlternateForm;
	end
	FrameUtil.RegisterFrameForEvents(self, self.DYNAMIC_EVENTS);

	self.ModelScene:TransitionToModelSceneID(290, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
	self:RefreshPlayerModel();
	self:RefreshHideIgnoredToggle();
end

function TransmogCharacterMixin:OnHide()
	self:UnregisterEvent("UNIT_FORM_CHANGED");
	FrameUtil.UnregisterFrameForEvents(self, self.DYNAMIC_EVENTS);

	self.selectedSlotData = nil;
end

function TransmogCharacterMixin:OnEvent(event, ...)
	if event == "UNIT_FORM_CHANGED" then
		self:HandleFormChanged();
	elseif event == "VIEWED_TRANSMOG_OUTFIT_SLOT_SAVE_SUCCESS" then
		local slot, type, _weaponOption = ...;
		local slotFrame = self:GetSlotFrame(slot, type);
		if slotFrame then
			slotFrame:OnTransmogrifySuccess();

			if not self.SavedFrame:IsShown() then
				self.SavedFrame:Show();
				self.SavedFrame.Anim:Restart();
			end
		end
	elseif event == "VIEWED_TRANSMOG_OUTFIT_SLOT_REFRESH" or event == "TRANSMOG_DISPLAYED_OUTFIT_CHANGED" then
		self:RefreshSlots();
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		local clearCurrentWeaponOptionInfo = true;
		self:RefreshSlotWeaponOptions(clearCurrentWeaponOptionInfo);
		self:RefreshSelectedSlot();
	elseif event == "VIEWED_TRANSMOG_OUTFIT_CHANGED" or event == "VIEWED_TRANSMOG_OUTFIT_SECONDARY_SLOTS_CHANGED" then
		self:SetupSlots();
		self:RefreshSelectedSlot();
	elseif event == "VIEWED_TRANSMOG_OUTFIT_SLOT_WEAPON_OPTION_CHANGED" then
		local slot, weaponOption = ...;
		local appearanceType = Enum.TransmogType.Appearance;
		local slotFrame = self:GetSlotFrame(slot, appearanceType);
		if slotFrame then
			slotFrame:SetCurrentWeaponOption(weaponOption);

			local illusionSlotFrame = slotFrame:GetIllusionSlotFrame();
			if illusionSlotFrame then
				illusionSlotFrame:SetCurrentWeaponOptionInfo(slotFrame:GetCurrentWeaponOptionInfo());
			end
		end
	end
end

function TransmogCharacterMixin:Refresh()
	self:RefreshPlayerModel();
	self:RefreshSlots();
end

function TransmogCharacterMixin:HandleFormChanged()
	if IsUnitModelReadyForUI("player") then
		local _hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
		if self.inAlternateForm ~= inAlternateForm then
			self.inAlternateForm = inAlternateForm;
			self:Refresh();
		end
	end
end

function TransmogCharacterMixin:SetupSlots()
	self.CharacterAppearanceSlotFramePool:ReleaseAll();
	self.CharacterIllusionSlotFramePool:ReleaseAll();

	local slotGroupData = C_TransmogOutfitInfo.GetSlotGroupInfo();
	for _index, groupData in ipairs(slotGroupData) do
		self:SetupSlotSection(groupData);
	end

	if self.selectedSlotData then
		-- Make sure we are selecting the same slot after refreshing our frames, if the slot still exists.
		local slotFrameFound = false;
		if self.selectedSlotData.transmogLocation then
			local slotFrame = self:GetSlotFrame(self.selectedSlotData.transmogLocation:GetSlot(), self.selectedSlotData.transmogLocation:GetType());
			if slotFrame then
				slotFrameFound = true;
				slotFrame:SetSelected(true);
			end
		end

		if not slotFrameFound then
			-- Whatever slot we were selecting is no longer present (split slot that is now hidden).
			self.selectedSlotData = nil;
		end
	end
end

function TransmogCharacterMixin:SetupSlotSection(groupData)
	local parentFrame;
	if groupData.position == Enum.TransmogOutfitSlotPosition.Left then
		parentFrame = self.LeftSlots;
	elseif groupData.position == Enum.TransmogOutfitSlotPosition.Right then
		parentFrame = self.RightSlots;
	elseif groupData.position == Enum.TransmogOutfitSlotPosition.Bottom then
		parentFrame = self.BottomSlots;
	end

	-- Appearance slots.
	for index, appearanceInfo in ipairs(groupData.appearanceSlotInfo) do
		local slotFrame = self.CharacterAppearanceSlotFramePool:Acquire();

		local transmogLocation = TransmogUtil.GetTransmogLocation(appearanceInfo.slotName, appearanceInfo.type, appearanceInfo.isSecondary);
		local slotData = {
			transmogLocation = transmogLocation,
			transmogFrame = TransmogFrame,
			currentWeaponOptionInfo = nil,
			-- Appearance specific fields.
			weaponOptionsInfo = nil,
			artifactOptionsInfo = nil
		};
		slotFrame.layoutIndex = index;

		slotFrame:Init(slotData);
		slotFrame:SetParent(parentFrame);
		slotFrame:Show();
	end

	-- Illusion slots, should only be created once their corresponding appearance slot is in place as they need to anchor off of it.
	local illusionAnchorOffset = 19;
	local appearanceType = Enum.TransmogType.Appearance;
	for _index, illusionInfo in ipairs(groupData.illusionSlotInfo) do
		local slotFrame = self:GetSlotFrame(illusionInfo.slot, appearanceType);
		assertsafe(slotFrame ~= nil);
		if slotFrame then
			local illusionSlotFrame = self.CharacterIllusionSlotFramePool:Acquire();
			slotFrame:SetIllusionSlotFrame(illusionSlotFrame);

			local transmogLocation = TransmogUtil.GetTransmogLocation(illusionInfo.slotName, illusionInfo.type, illusionInfo.isSecondary);
			local illusionSlotData = {
				transmogLocation = transmogLocation,
				transmogFrame = TransmogFrame,
				currentWeaponOptionInfo = slotFrame:GetCurrentWeaponOptionInfo()
			};

			illusionSlotFrame:Init(illusionSlotData);
			illusionSlotFrame:SetParent(slotFrame);
			illusionSlotFrame:SetFrameLevel(300);
			if groupData.position == Enum.TransmogOutfitSlotPosition.Left then
				illusionSlotFrame:SetPoint("RIGHT", slotFrame, "LEFT", -illusionAnchorOffset, 0);
			elseif groupData.position == Enum.TransmogOutfitSlotPosition.Right then
				illusionSlotFrame:SetPoint("LEFT", slotFrame, "RIGHT", illusionAnchorOffset, 0);
			elseif groupData.position == Enum.TransmogOutfitSlotPosition.Bottom then
				illusionSlotFrame:SetPoint("TOP", slotFrame, "BOTTOM", 0, illusionAnchorOffset);
			end
			illusionSlotFrame:Show();
		end
	end

	parentFrame:Layout();
end

function TransmogCharacterMixin:RefreshHideIgnoredToggle()
	local hideIgnored = GetCVarBool("transmogHideIgnoredSlots");
	self.HideIgnoredToggle.Checkbox:SetChecked(hideIgnored);
	self.HideIgnoredToggle.Text:SetFontObject(hideIgnored and "GameFontHighlight" or "GameFontNormal");
end

function TransmogCharacterMixin:RefreshPlayerModel()
	local modelScene = self.ModelScene;
	if modelScene.previousActor then
		modelScene.previousActor:ClearModel();
		modelScene.previousActor = nil;
	end

	local actor = modelScene:GetPlayerActor();
	if actor then
		local sheatheWeapons = false;
		local autoDress = true;
		local hideWeapons = false;
		actor:SetModelByUnit("player", sheatheWeapons, autoDress, hideWeapons, PlayerUtil.ShouldUseNativeFormInModelScene());
		modelScene.previousActor = actor;
	end
end

function TransmogCharacterMixin:RefreshSlotWeaponOptions(clearCurrentWeaponOptionInfo)
	for slotFrame in self.CharacterAppearanceSlotFramePool:EnumerateActive() do
		if clearCurrentWeaponOptionInfo then
			slotFrame:SetCurrentWeaponOptionInfo(slotFrame.DEFAULT_WEAPON_OPTION_INFO);
		end

		slotFrame:RefreshWeaponOptions();
	end
end

function TransmogCharacterMixin:RefreshSlots()
	local actor = self.ModelScene:GetPlayerActor();
	if not actor then
		return;
	end

	for slotFrame in self.CharacterAppearanceSlotFramePool:EnumerateActive() do
		slotFrame:Update();

		-- Slot that was selected is now disabled, will need to select a new slot.
		local selectedSlotTransmogLocation = self.selectedSlotData and self.selectedSlotData.transmogLocation or nil;
		local appearanceSlotTransmogLocation = slotFrame:GetTransmogLocation();
		if appearanceSlotTransmogLocation and selectedSlotTransmogLocation and appearanceSlotTransmogLocation:IsEqual(selectedSlotTransmogLocation) and not slotFrame:IsEnabled() then
			self.selectedSlotData = nil;
		end

		local illusionSlotFrame = slotFrame:GetIllusionSlotFrame();
		if illusionSlotFrame then
			illusionSlotFrame:Update();

			local illusionSlotTransmogLocation = illusionSlotFrame:GetTransmogLocation();
			if illusionSlotTransmogLocation and selectedSlotTransmogLocation and illusionSlotTransmogLocation:IsEqual(selectedSlotTransmogLocation) and not illusionSlotFrame:IsEnabled() then
				self.selectedSlotData = nil;
			end
		end

		-- Only attempt to set a slot's appearance on the actor if this is not a secondary slot (the primary slot will handle things for it).
		local linkedSlotInfo = C_TransmogOutfitInfo.GetLinkedSlotInfo(slotFrame.slotData.transmogLocation:GetSlot());
		if not linkedSlotInfo or linkedSlotInfo.primarySlotInfo.slot == slotFrame.slotData.transmogLocation:GetSlot() then
			-- Secondary slots.
			local secondaryAppearanceID = Constants.Transmog.NoTransmogID;
			if linkedSlotInfo then
				-- Use primary slot option.
				local outfitSlotInfo = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(linkedSlotInfo.secondarySlotInfo.slot, linkedSlotInfo.secondarySlotInfo.type, slotFrame:GetCurrentWeaponOptionInfo().weaponOption);
				if outfitSlotInfo then
					secondaryAppearanceID = outfitSlotInfo.transmogID;
				end
			end

			-- Illusions.
			local illusionID = Constants.Transmog.NoTransmogID;
			if illusionSlotFrame then
				local illusionSlotInfo = illusionSlotFrame:GetSlotInfo();
				if illusionSlotInfo and illusionSlotInfo.warning ~= Enum.TransmogOutfitSlotWarning.WeaponDoesNotSupportIllusions then
					illusionID = illusionSlotInfo.transmogID;
				end
			end

			local transmogLocation = slotFrame:GetTransmogLocation();
			if transmogLocation then

				local slotID = transmogLocation:GetSlotID();
				if slotID ~= nil then
					local appearanceID = slotFrame:GetEffectiveTransmogID();
					local itemTransmogInfo = ItemUtil.CreateItemTransmogInfo(appearanceID, secondaryAppearanceID, illusionID);
					local currentItemTransmogInfo = actor:GetItemTransmogInfo(slotID);

					-- Need the main category for mainhand.
					local mainHandCategoryID;
					local isLegionArtifact = false;
					if transmogLocation:IsMainHand() then
						mainHandCategoryID = C_TransmogOutfitInfo.GetItemModifiedAppearanceEffectiveCategory(appearanceID);
						isLegionArtifact = TransmogUtil.IsCategoryLegionArtifact(mainHandCategoryID);
						itemTransmogInfo:ConfigureSecondaryForMainHand(isLegionArtifact);
					end

					-- Update only if there is a change or it can recurse (offhand is processed first and mainhand might override offhand).
					if not itemTransmogInfo:IsEqual(currentItemTransmogInfo) or isLegionArtifact then
						if appearanceID == Constants.Transmog.NoTransmogID then
							actor:UndressSlot(slotID);
						else
							-- Don't specify a slot for ranged weapons.
							if mainHandCategoryID and TransmogUtil.IsCategoryRangedWeapon(mainHandCategoryID) then
								slotID = nil;
							end
							actor:SetItemTransmogInfo(itemTransmogInfo, slotID);
						end
					end
				end
			end
		end
	end

	-- Select valid slot now that everything has updated if needed.
	if not self.selectedSlotData then
		self:SetInitialSelectedSlot();
	end
end

function TransmogCharacterMixin:RefreshSelectedSlot()
	if not self.selectedSlotData then
		return;
	end

	local slotFrame = self:GetSlotFrame(self.selectedSlotData.transmogLocation:GetSlot(), self.selectedSlotData.transmogLocation:GetType());
	if slotFrame then
		local forceRefresh = true;
		TransmogFrame:SelectSlot(slotFrame, forceRefresh);
	end
end

function TransmogCharacterMixin:SetInitialSelectedSlot()
	local function FindValidSlotToSelect(slotsParent)
		for _index, slotFrame in ipairs(slotsParent:GetLayoutChildren()) do
			if slotFrame:IsEnabled() and slotFrame:GetTransmogLocation():IsAppearance() then
				local fromOnClick = false;
				slotFrame:OnSelect(fromOnClick);
				return true;
			end
		end
		return false;
	end

	local selectionFound = FindValidSlotToSelect(self.LeftSlots);

	if not selectionFound then
		selectionFound = FindValidSlotToSelect(self.BottomSlots);
	end

	if not selectionFound then
		selectionFound = FindValidSlotToSelect(self.RightSlots);
	end

	return selectionFound;
end

function TransmogCharacterMixin:UpdateSlot(slotData, forceRefresh)
	if not slotData then
		self.selectedSlotData = nil;
		return;
	end

	if not self.selectedSlotData or (slotData.transmogLocation and self.selectedSlotData.transmogLocation and not slotData.transmogLocation:IsEqual(self.selectedSlotData.transmogLocation)) then
		if self.selectedSlotData and self.selectedSlotData.transmogLocation:IsEitherHand() and not GetCVarBitfield("closedInfoFramesAccountWide", Enum.FrameTutorialAccount.TransmogWeaponOptions) then
			-- If the previous selected slot was either hand slot, and the associated help tip hasn't been acknowledged, mark it as seen as it should have been viewed by now.
			HelpTip:HideAllSystem("TransmogCharacter");
		end

		self.selectedSlotData = slotData;
		local showHelptip = self.selectedSlotData.transmogLocation:IsEitherHand() and not GetCVarBitfield("closedInfoFramesAccountWide", Enum.FrameTutorialAccount.TransmogWeaponOptions);
		for slotFrame in self.CharacterAppearanceSlotFramePool:EnumerateActive() do
			local selected = slotFrame.slotData.transmogLocation and self.selectedSlotData.transmogLocation and slotFrame.slotData.transmogLocation:IsEqual(self.selectedSlotData.transmogLocation);
			slotFrame:SetSelected(selected);

			if showHelptip and selected then
				-- Help tip parent is dependent on if the flyout dropdown is shown or not.
				local helpTipParent = slotFrame.FlyoutDropdown:IsShown() and slotFrame.FlyoutDropdown or slotFrame;
				HelpTip:Show(helpTipParent, self.HELPTIP_INFO);
			end
		end

		for slotFrame in self.CharacterIllusionSlotFramePool:EnumerateActive() do
			slotFrame:SetSelected(slotFrame.slotData.transmogLocation and self.selectedSlotData.transmogLocation and slotFrame.slotData.transmogLocation:IsEqual(self.selectedSlotData.transmogLocation));
		end
	elseif forceRefresh then
		self.selectedSlotData = slotData;
		-- Refresh the visuals on the actor.
		self:RefreshSlots();
	end
end

function TransmogCharacterMixin:GetSelectedSlotData()
	return self.selectedSlotData;
end

function TransmogCharacterMixin:GetSlotFrame(slot, type)
	for slotFrame in self.CharacterAppearanceSlotFramePool:EnumerateActive() do
		if slotFrame.slotData.transmogLocation and slotFrame.slotData.transmogLocation:GetSlot() == slot and slotFrame.slotData.transmogLocation:GetType() == type then
			return slotFrame;
		end
	end

	for slotFrame in self.CharacterIllusionSlotFramePool:EnumerateActive() do
		if slotFrame.slotData.transmogLocation and slotFrame.slotData.transmogLocation:GetSlot() == slot and slotFrame.slotData.transmogLocation:GetType() == type then
			return slotFrame;
		end
	end

	return nil;
end

function TransmogCharacterMixin:GetCurrentTransmogInfo()
	local transmogInfo = {};
	for slotFrame in self.CharacterAppearanceSlotFramePool:EnumerateActive() do
		local transmogLocation = slotFrame:GetTransmogLocation();
		local slotInfo = slotFrame:GetSlotInfo();
		if transmogLocation and not transmogLocation:IsSecondary() and slotInfo and slotInfo.transmogID ~= Constants.Transmog.NoTransmogID then
			transmogInfo[transmogLocation] = {
				transmogID = slotInfo.transmogID,
				hasPending = slotInfo.hasPending
			};
		end

		local illusionSlotFrame = slotFrame:GetIllusionSlotFrame();
		if illusionSlotFrame then
			local illusionTransmogLocation = illusionSlotFrame:GetTransmogLocation();
			local illusionSlotInfo = illusionSlotFrame:GetSlotInfo();

			if illusionTransmogLocation and not illusionTransmogLocation:IsSecondary() and illusionSlotInfo and illusionSlotInfo.transmogID ~= Constants.Transmog.NoTransmogID then
				transmogInfo[illusionTransmogLocation] = {
					transmogID = illusionSlotInfo.transmogID,
					hasPending = illusionSlotInfo.hasPending
				};
			end
		end
	end

	return transmogInfo;
end

-- Used for custom set data formats.
function TransmogCharacterMixin:GetItemTransmogInfoList()
	local actor = self.ModelScene:GetPlayerActor();
	if not actor then
		return nil;
	end

	return actor:GetItemTransmogInfoList();
end


TransmogWardrobeMixin = {
	HELPTIP_INFO = {
		[Enum.FrameTutorialAccount.TransmogSets] =
		{
			text = TRANSMOG_SETS_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			alignment = HelpTip.Alignment.Center,
			offsetY = 5,
			system = "TransmogWardrobe",
			acknowledgeOnHide = true,
			cvarBitfield = "closedInfoFramesAccountWide",
			bitfieldFlag = Enum.FrameTutorialAccount.TransmogSets
		},
		[Enum.FrameTutorialAccount.TransmogCustomSets] =
		{
			text = TRANSMOG_CUSTOM_SETS_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			alignment = HelpTip.Alignment.Center,
			offsetY = 5,
			system = "TransmogWardrobe",
			acknowledgeOnHide = true,
			cvarBitfield = "closedInfoFramesAccountWide",
			bitfieldFlag = Enum.FrameTutorialAccount.TransmogCustomSets
		},
		[Enum.FrameTutorialAccount.TransmogSituations] =
		{
			text = TRANSMOG_SITUATIONS_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			alignment = HelpTip.Alignment.Center,
			offsetY = 5,
			system = "TransmogWardrobe",
			acknowledgeOnHide = true,
			cvarBitfield = "closedInfoFramesAccountWide",
			bitfieldFlag = Enum.FrameTutorialAccount.TransmogSituations
		}
	};
};

function TransmogWardrobeMixin:OnLoad()
	TabSystemOwnerMixin.OnLoad(self);
	self:SetTabSystem(self.TabHeaders);

	self.itemsTabID = self:AddNamedTab(TRANSMOG_TAB_ITEMS, self.TabContent.ItemsFrame);
	self.setsTabID = self:AddNamedTab(TRANSMOG_TAB_SETS, self.TabContent.SetsFrame);
	self.custmSetsTabID = self:AddNamedTab(TRANSMOG_TAB_CUSTOM_SETS, self.TabContent.CustomSetsFrame);
	self.situationsTabID = self:AddNamedTab(TRANSMOG_TAB_SITUATIONS, self.TabContent.SituationsFrame);

	self:UpdateTabs();
	self.TabContent.ItemsFrame:Init(self);
	self.TabContent.SetsFrame:Init(self);
	self.TabContent.CustomSetsFrame:Init(self);
end

function TransmogWardrobeMixin:OnShow()
	self:SetToDefaultAvailableTab();

	-- Situation info may have changed in between showing transmog frame.
	self.TabContent.SituationsFrame:Init();
end

function TransmogWardrobeMixin:OnHide()
	self.TabContent.ItemsFrame:Reset();
end

function TransmogWardrobeMixin:UpdateTabs()
	self.TabHeaders:SetTabShown(self.itemsTabID, true);
	self.TabHeaders:SetTabShown(self.setsTabID, true);
	self.TabHeaders:SetTabShown(self.custmSetsTabID, true);
	self.TabHeaders:SetTabShown(self.situationsTabID, true);
end

function TransmogWardrobeMixin:SetToDefaultAvailableTab()
	self:SetToItemsTab();
end

function TransmogWardrobeMixin:SetToItemsTab()
	self:SetTab(self.itemsTabID);
end

function TransmogWardrobeMixin:SetTab(tabID)
	TabSystemOwnerMixin.SetTab(self, tabID);

	self:CheckShowHelptips(tabID);
end

function TransmogWardrobeMixin:CheckShowHelptips(tabID)
	-- Hide any showing wardrobe helptips.
	HelpTip:HideAllSystem("TransmogWardrobe");

	local helpTipParent = self:GetTabButton(tabID);
	local bitfieldFlag;
	if tabID == self.setsTabID then
		bitfieldFlag = Enum.FrameTutorialAccount.TransmogSets;
	elseif tabID == self.custmSetsTabID then
		bitfieldFlag = Enum.FrameTutorialAccount.TransmogCustomSets;
	elseif tabID == self.situationsTabID then
		bitfieldFlag = Enum.FrameTutorialAccount.TransmogSituations;
	end

	if bitfieldFlag and not GetCVarBitfield("closedInfoFramesAccountWide", bitfieldFlag) then
		local helptipInfo = self.HELPTIP_INFO[bitfieldFlag];
		if not helptipInfo then
			return;
		end

		HelpTip:Show(helpTipParent, helptipInfo);
	end
end

function TransmogWardrobeMixin:UpdateSlot(slotData, forceRefresh)
	self:SetToItemsTab();
	self.TabContent.ItemsFrame:UpdateSlot(slotData, forceRefresh);
end


TransmogWardrobeItemsMixin = {
	DYNAMIC_EVENTS = {
		"TRANSMOG_SEARCH_UPDATED",
		"TRANSMOG_COLLECTION_UPDATED",
		"UI_SCALE_CHANGED",
		"DISPLAY_SIZE_CHANGED",
		"TRANSMOG_COLLECTION_CAMERA_UPDATE",
		"VIEWED_TRANSMOG_OUTFIT_CHANGED",
		"VIEWED_TRANSMOG_OUTFIT_SLOT_REFRESH",
		"VIEWED_TRANSMOG_OUTFIT_SECONDARY_SLOTS_CHANGED",
		"VIEWED_TRANSMOG_OUTFIT_SLOT_SAVE_SUCCESS",
		"PLAYER_EQUIPMENT_CHANGED"
	};
	COLLECTION_TEMPLATES = {
		["COLLECTION_ITEM"] = { template = "TransmogItemModelTemplate", initFunc = TransmogItemModelMixin.Init, resetFunc = TransmogItemModelMixin.Reset }
	};
	WEAPON_DROPDOWN_WIDTH = 168;
};

function TransmogWardrobeItemsMixin:OnLoad()
	self:InitFilterButton();
	self.PagedContent:SetElementTemplateData(self.COLLECTION_TEMPLATES);
	self.SearchBox:SetSearchType(self.searchType);
	self.WeaponDropdown:SetWidth(self.WEAPON_DROPDOWN_WIDTH);

	local function SetPendingDisplayTypeForSlot(displayType)
		local selectedSlotData = self:GetSelectedSlotCallback();
		if not selectedSlotData or not selectedSlotData.transmogLocation then
			return;
		end

		local transmogID = Constants.Transmog.NoTransmogID;
		C_TransmogOutfitInfo.SetPendingTransmog(selectedSlotData.transmogLocation:GetSlot(), selectedSlotData.transmogLocation:GetType(), selectedSlotData.currentWeaponOptionInfo.weaponOption, transmogID, displayType);
	end

	self.DisplayTypeUnassignedButton.SavedFrame.Anim:SetScript("OnFinished", function()
		self.DisplayTypeUnassignedButton.SavedFrame:Hide();
	end);

	self.DisplayTypeUnassignedButton:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip_AddHighlightLine(GameTooltip, TRANSMOG_SLOT_DISPLAY_TYPE_UNASSIGNED);
		GameTooltip_AddNormalLine(GameTooltip, TRANSMOG_SLOT_DISPLAY_TYPE_UNASSIGNED_TOOLTIP);
		GameTooltip:Show();
	end);

	self.DisplayTypeUnassignedButton:SetScript("OnLeave", GameTooltip_Hide);

	self.DisplayTypeUnassignedButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.UI_TRANSMOG_ITEM_CLICK);
		SetPendingDisplayTypeForSlot(Enum.TransmogOutfitDisplayType.Unassigned);
	end);

	self.DisplayTypeEquippedButton.SavedFrame.Anim:SetScript("OnFinished", function()
		self.DisplayTypeEquippedButton.SavedFrame:Hide();
	end);

	self.DisplayTypeEquippedButton:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip_AddHighlightLine(GameTooltip, TRANSMOG_SLOT_DISPLAY_TYPE_EQUIPPED);
		GameTooltip_AddNormalLine(GameTooltip, TRANSMOG_SLOT_DISPLAY_TYPE_EQUIPPED_TOOLTIP);
		GameTooltip:Show();
	end);

	self.DisplayTypeEquippedButton:SetScript("OnLeave", GameTooltip_Hide);

	self.DisplayTypeEquippedButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.UI_TRANSMOG_ITEM_CLICK);
		SetPendingDisplayTypeForSlot(Enum.TransmogOutfitDisplayType.Equipped);
	end);

	self.SecondaryAppearanceToggle.Checkbox:SetScript("OnClick", function(button)
		local selectedSlotData = self:GetSelectedSlotCallback();
		if not selectedSlotData or not selectedSlotData.transmogLocation then
			return;
		end

		local toggledOn = button:GetChecked();
		if toggledOn then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		end
		C_TransmogOutfitInfo.SetSecondarySlotState(selectedSlotData.transmogLocation:GetSlot(), toggledOn);
		self.SecondaryAppearanceToggle.Text:SetFontObject(toggledOn and "GameFontHighlight" or "GameFontNormal");
	end);

	self:Reset();
end

function TransmogWardrobeItemsMixin:OnShow()
	local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
	if hasAlternateForm then
		self:RegisterUnitEvent("UNIT_FORM_CHANGED", "player");
		self.inAlternateForm = inAlternateForm;
	end
	FrameUtil.RegisterFrameForEvents(self, self.DYNAMIC_EVENTS);

	self:Refresh();
end

function TransmogWardrobeItemsMixin:OnHide()
	self:UnregisterEvent("UNIT_FORM_CHANGED");
	FrameUtil.UnregisterFrameForEvents(self, self.DYNAMIC_EVENTS);
end

function TransmogWardrobeItemsMixin:OnEvent(event, ...)
	if event == "UNIT_FORM_CHANGED" then
		self:HandleFormChanged();
	elseif event == "TRANSMOG_SEARCH_UPDATED" then
		local searchType, collectionType = ...;
		if searchType == self.searchType and collectionType == self.activeCategoryID then
			self:RefreshCollectionEntries();

			if self.jumpToTransmogID then
				self:PageToTransmogID(self.jumpToTransmogID);
				self.jumpToTransmogID = nil;
			end
		end
	elseif event == "TRANSMOG_COLLECTION_UPDATED" then
		self:RefreshCollectionEntries();
	elseif event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" or event == "TRANSMOG_COLLECTION_CAMERA_UPDATE" then
		self:RefreshCameras();
	elseif event == "VIEWED_TRANSMOG_OUTFIT_CHANGED" then
		self:RefreshActiveSlotTitle();
		self:RefreshDisplayTypeButtons();
		self:RefreshSecondaryAppearanceToggle();
		self:RefreshCameras();
		self:RefreshPagedEntry();
	elseif event == "VIEWED_TRANSMOG_OUTFIT_SLOT_REFRESH" then
		self:RefreshDisplayTypeButtons();
		self:RefreshCollectionEntries();
	elseif event == "VIEWED_TRANSMOG_OUTFIT_SECONDARY_SLOTS_CHANGED" then
		self:RefreshActiveSlotTitle();
		self:RefreshCameras();
	elseif event == "VIEWED_TRANSMOG_OUTFIT_SLOT_SAVE_SUCCESS" then
		local slot, type, weaponOption = ...;
		local selectedSlotData = self:GetSelectedSlotCallback();
		if not selectedSlotData or not selectedSlotData.transmogLocation then
			return;
		end

		-- Already set to true, do not stomp if multiple slots are changing.
		if self:GetOutfitSlotSavedState() then
			return;
		end

		local outfitSlotSaved = selectedSlotData.transmogLocation:GetSlot() == slot and selectedSlotData.transmogLocation:GetType() == type and selectedSlotData.currentWeaponOptionInfo.weaponOption == weaponOption;
		self:SetOutfitSlotSavedState(outfitSlotSaved);
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		self:RefreshDisplayTypeButtons();
	end
end

function TransmogWardrobeItemsMixin:Init(wardrobeCollection)
	self.wardrobeCollection = wardrobeCollection;
end

function TransmogWardrobeItemsMixin:InitFilterButton()
	self.FilterButton:SetText(SOURCES);

	self.FilterButton:SetupMenu(function(_dropdown, rootDescription)
		rootDescription:SetTag("MENU_TRANSMOG_ITEMS_FILTER");

		rootDescription:CreateButton(CHECK_ALL, function()
			C_TransmogCollection.SetAllSourceTypeFilters(true);
			return MenuResponse.Refresh;
		end);

		rootDescription:CreateButton(UNCHECK_ALL, function()
			C_TransmogCollection.SetAllSourceTypeFilters(false);
			return MenuResponse.Refresh;
		end);

		local function IsChecked(filter)
			return C_TransmogCollection.IsSourceTypeFilterChecked(filter);
		end

		local function SetChecked(filter)
			C_TransmogCollection.SetSourceTypeFilter(filter, not IsChecked(filter));
		end

		for filterIndex = 1, C_TransmogCollection.GetNumTransmogSources() do
			if (C_TransmogCollection.IsValidTransmogSource(filterIndex)) then
				rootDescription:CreateCheckbox(_G["TRANSMOG_SOURCE_"..filterIndex], IsChecked, SetChecked, filterIndex);
			end
		end
	end);

	self.FilterButton:SetIsDefaultCallback(function()
		return C_TransmogCollection.IsUsingDefaultFilters();
	end);

	self.FilterButton:SetDefaultCallback(function()
		return C_TransmogCollection.SetDefaultFilters();
	end);
end

function TransmogWardrobeItemsMixin:Reset()
	self.activeCategoryID = nil;
	self.lastWeaponCategoryID = nil;
	self.transmogLocation = nil;
	self.itemCollectionEntries = nil;
	self.chosenVisualSources = {};
	self.PagedContent:SetDataProvider(CreateDataProvider());
end

function TransmogWardrobeItemsMixin:HandleFormChanged()
	if IsUnitModelReadyForUI("player") then
		local _hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
		if self.inAlternateForm ~= inAlternateForm then
			self.inAlternateForm = inAlternateForm;
			self:RefreshCollectionEntries();
		end
	end
end

function TransmogWardrobeItemsMixin:Refresh()
	self:RefreshActiveSlotTitle();
	self:RefreshFilterButtons();
	self:RefreshWeaponDropdown();
	self:RefreshDisplayTypeButtons();
	self:RefreshSecondaryAppearanceToggle();
	self:RefreshCollectionEntries();
end

function TransmogWardrobeItemsMixin:RefreshActiveSlotTitle()
	local selectedSlotData = self:GetSelectedSlotCallback();
	if not selectedSlotData or not selectedSlotData.transmogLocation then
		self.ActiveSlotTitle:SetText("");
		return;
	end

	local slotName = _G[selectedSlotData.transmogLocation:GetSlotName()];
	if selectedSlotData.transmogLocation:IsIllusion() then
		slotName = WEAPON_ENCHANTMENT;
	else
		-- Use weapon option name if set.
		-- Use different names if slots are split.
		if selectedSlotData.currentWeaponOptionInfo.weaponOption ~= Enum.TransmogOutfitSlotOption.None then
			slotName = selectedSlotData.currentWeaponOptionInfo.name;
		elseif C_TransmogOutfitInfo.GetSecondarySlotState(selectedSlotData.transmogLocation:GetSlot()) then
			if selectedSlotData.transmogLocation:GetSlot() == Enum.TransmogOutfitSlot.ShoulderRight then
				slotName = RIGHTSHOULDERSLOT;
			elseif selectedSlotData.transmogLocation:GetSlot() == Enum.TransmogOutfitSlot.ShoulderLeft then
				slotName = LEFTSHOULDERSLOT;
			end
		end
	end
	self.ActiveSlotTitle:SetText(slotName);
end

function TransmogWardrobeItemsMixin:RefreshFilterButtons()
	local selectedSlotData = self:GetSelectedSlotCallback();
	if not selectedSlotData or not selectedSlotData.transmogLocation or selectedSlotData.transmogLocation:IsIllusion() then
		self.SearchBox:Hide();
		self.FilterButton:Hide();
		return;
	end

	self.SearchBox:Show();
	self.FilterButton:Show();

	-- Reapply current search, in case the collection has changed.
	self.SearchBox:UpdateSearch();
end

function TransmogWardrobeItemsMixin:RefreshWeaponDropdown()
	if not self.activeCategoryID then
		self.WeaponDropdown:Hide();
		return;
	end

	local selectedSlotData = self:GetSelectedSlotCallback();
	if not selectedSlotData or not selectedSlotData.transmogLocation or selectedSlotData.transmogLocation:IsIllusion() then
		self.WeaponDropdown:Hide();
		return;
	end

	local activeCollectionInfo = C_TransmogOutfitInfo.GetCollectionInfoForSlotAndOption(selectedSlotData.transmogLocation:GetSlot(), selectedSlotData.currentWeaponOptionInfo.weaponOption, self.activeCategoryID);

	if not activeCollectionInfo or not activeCollectionInfo.isWeapon then
		self.WeaponDropdown:Hide();
		return;
	end

	local validCategories = {};
	for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
		local collectionInfo = C_TransmogOutfitInfo.GetCollectionInfoForSlotAndOption(selectedSlotData.transmogLocation:GetSlot(), selectedSlotData.currentWeaponOptionInfo.weaponOption, categoryID);
		if collectionInfo and collectionInfo.isWeapon then
			validCategories[categoryID] = collectionInfo.name;
		end
	end

	-- Only show weapon dropdown if there are more than 1 options to choose from.
	if table.count(validCategories) <= 1 then
		self.WeaponDropdown:Hide();
		return;
	end

	self.WeaponDropdown:Show();

	local function IsSelected(categoryID)
		return categoryID == self.activeCategoryID;
	end

	local function SetSelected(categoryID)
		if categoryID ~= self.activeCategoryID then
			self:SetActiveCategory(categoryID);
		end
	end

	self.WeaponDropdown:SetupMenu(function(_dropdown, rootDescription)
		rootDescription:SetTag("MENU_TRANSMOG_WEAPONS_FILTER");

		for categoryID, name in pairs(validCategories) do
			rootDescription:CreateRadio(name, IsSelected, SetSelected, categoryID);
		end
	end);
end

function TransmogWardrobeItemsMixin:RefreshDisplayTypeButtons()
	local unassignedButton = self.DisplayTypeUnassignedButton;
	local equippedButton = self.DisplayTypeEquippedButton;

	local selectedSlotData = self:GetSelectedSlotCallback();
	if not selectedSlotData or not selectedSlotData.transmogLocation then
		unassignedButton:Hide();
		equippedButton:Hide();
		return;
	end

	local outfitSlotInfo = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(selectedSlotData.transmogLocation:GetSlot(), selectedSlotData.transmogLocation:GetType(), selectedSlotData.currentWeaponOptionInfo.weaponOption);
	if not outfitSlotInfo then
		unassignedButton:Hide();
		equippedButton:Hide();
		return;
	end

	unassignedButton:Show();
	equippedButton:Show();

	local function SetDisplayTypeButtonState(displayTypeButton, selected)
		local stateAtlas;
		if selected then
			displayTypeButton.IconFrame.Border:SetAtlas("transmog-appearance-circFrame-active", TextureKitConstants.UseAtlasSize);
			displayTypeButton:SetNormalAtlas("common-button-tertiary-depressed-normal", TextureKitConstants.IgnoreAtlasSize);
			displayTypeButton:SetNormalFontObject("GameFontHighlight");

			if outfitSlotInfo.hasPending then
				stateAtlas = "common-button-tertiary-depressed-normal-glow-purple";
			else
				stateAtlas = "common-button-tertiary-depressed-normal-purple";
			end
		else
			displayTypeButton.IconFrame.Border:SetAtlas("transmog-appearance-circframe", TextureKitConstants.UseAtlasSize);
			displayTypeButton:SetNormalAtlas("common-button-tertiary-normal", TextureKitConstants.IgnoreAtlasSize);
			displayTypeButton:SetNormalFontObject("GameFontNormal");
		end

		if stateAtlas then
			displayTypeButton.StateTexture:SetAtlas(stateAtlas, TextureKitConstants.IgnoreAtlasSize);
			displayTypeButton.StateTexture:Show();

			if outfitSlotInfo.hasPending then
				displayTypeButton.PendingFrame:Show();
				displayTypeButton.PendingFrame.Anim:Restart();
			else
				displayTypeButton.PendingFrame.Anim:Stop();
				displayTypeButton.PendingFrame:Hide();
			end

			if self:GetOutfitSlotSavedState() then
				displayTypeButton.SavedFrame:Show();
				displayTypeButton.SavedFrame.Anim:Restart();

				local outfitSlotSaved = false;
				self:SetOutfitSlotSavedState(outfitSlotSaved);
			end
		else
			displayTypeButton.StateTexture:Hide();

			displayTypeButton.PendingFrame.Anim:Stop();
			displayTypeButton.PendingFrame:Hide();
		end

		-- Do not show hover or click states when selected.
		displayTypeButton:SetEnabled(not selected);
	end

	-- Unassigned Button.
	local unassignedAtlas;
	if selectedSlotData.transmogLocation:IsIllusion() then
		unassignedAtlas = "transmog-appearance-unassigned-enchant";
	else
		unassignedAtlas = C_TransmogOutfitInfo.GetUnassignedDisplayAtlasForSlot(selectedSlotData.transmogLocation:GetSlot());
	end
	unassignedButton.IconFrame.Icon:SetAtlas(unassignedAtlas, TextureKitConstants.UseAtlasSize);

	local isUnassigned = outfitSlotInfo.displayType == Enum.TransmogOutfitDisplayType.Unassigned;
	SetDisplayTypeButtonState(unassignedButton, isUnassigned);

	-- Equipped Button.
	local equippedIcon = equippedButton.IconFrame.Icon;
	if outfitSlotInfo.warning ~= Enum.TransmogOutfitSlotWarning.Ok then
		equippedIcon:SetAtlas(unassignedAtlas, TextureKitConstants.UseAtlasSize);
	else
		local textureName = GetInventoryItemTexture("player", selectedSlotData.transmogLocation:GetSlotID());
		if textureName then
			equippedIcon:SetTexture(textureName);
		else
			equippedIcon:SetAtlas(unassignedAtlas, TextureKitConstants.UseAtlasSize);
		end
	end

	local isEquipped = outfitSlotInfo.displayType == Enum.TransmogOutfitDisplayType.Equipped;
	SetDisplayTypeButtonState(equippedButton, isEquipped);
end

function TransmogWardrobeItemsMixin:RefreshSecondaryAppearanceToggle()
	local selectedSlotData = self:GetSelectedSlotCallback();
	if not selectedSlotData or not selectedSlotData.transmogLocation then
		return;
	end

	local slot = selectedSlotData.transmogLocation:GetSlot();
	local hasSecondary = C_TransmogOutfitInfo.SlotHasSecondary(slot);
	if hasSecondary then
		self.SecondaryAppearanceToggle:Show();
		local toggledOn = C_TransmogOutfitInfo.GetSecondarySlotState(slot);
		self.SecondaryAppearanceToggle.Checkbox:SetChecked(toggledOn);
		self.SecondaryAppearanceToggle.Text:SetFontObject(toggledOn and "GameFontHighlight" or "GameFontNormal");
	else
		self.SecondaryAppearanceToggle:Hide();
	end
end

function TransmogWardrobeItemsMixin:RefreshCollectionEntries()
	if not self.transmogLocation or not self.activeCategoryID then
		return;
	end

	if self.transmogLocation:IsIllusion() then
		self.itemCollectionEntries = C_TransmogCollection.GetIllusions();
	else
		self.itemCollectionEntries = C_TransmogCollection.GetCategoryAppearances(self.activeCategoryID, self.transmogLocation:GetData());
	end

	local retainCurrentPage = true;
	self:SetCollectionEntries(self.itemCollectionEntries, retainCurrentPage);
end

function TransmogWardrobeItemsMixin:RefreshCameras()
	self.PagedContent:ForEachFrame(function(frame)
		frame:RefreshItemCamera();
	end);
end

function TransmogWardrobeItemsMixin:RefreshPagedEntry()
	local selectedSlotData = self:GetSelectedSlotCallback();
	if not selectedSlotData or not selectedSlotData.transmogLocation then
		return;
	end

	local outfitSlotInfo = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(selectedSlotData.transmogLocation:GetSlot(), selectedSlotData.transmogLocation:GetType(), selectedSlotData.currentWeaponOptionInfo.weaponOption);
	if not outfitSlotInfo or outfitSlotInfo.displayType == Enum.TransmogOutfitDisplayType.Unassigned or outfitSlotInfo.displayType == Enum.TransmogOutfitDisplayType.Equipped then
		self.PagedContent.PagingControls:SetCurrentPage(1);
	else
		self:PageToTransmogID(outfitSlotInfo.transmogID);
	end
end

function TransmogWardrobeItemsMixin:SelectVisual(visualID)
	if not self.transmogLocation then
		return;
	end

	local sourceID;
	if self.transmogLocation:IsAppearance() then
		local mustBeUsable = true;
		sourceID = self:GetAnAppearanceSourceFromVisual(visualID, mustBeUsable);
	else
		for _index, itemEntry in ipairs(self.itemCollectionEntries) do
			if itemEntry.visualID == visualID then
				sourceID = itemEntry.sourceID;
				break;
			end
		end
	end

	-- Artifacts from other specs will not have something valid
	if sourceID ~= Constants.Transmog.NoTransmogID then
		local selectedSlotData = self:GetSelectedSlotCallback();
		if not selectedSlotData or not selectedSlotData.transmogLocation then
			return;
		end

		local displayType = Enum.TransmogOutfitDisplayType.Assigned;
		if C_TransmogCollection.IsAppearanceHiddenVisual(sourceID) then
			displayType = Enum.TransmogOutfitDisplayType.Hidden;
		end
		C_TransmogOutfitInfo.SetPendingTransmog(selectedSlotData.transmogLocation:GetSlot(), selectedSlotData.transmogLocation:GetType(), selectedSlotData.currentWeaponOptionInfo.weaponOption, sourceID, displayType);

		PlaySound(SOUNDKIT.UI_TRANSMOG_ITEM_CLICK);
	end
end

function TransmogWardrobeItemsMixin:GetAnAppearanceSourceFromVisual(visualID, mustBeUsable)
	if not self.transmogLocation or not self.activeCategoryID then
		return nil;
	end

	local sourceID = self:GetChosenVisualSource(visualID);
	if sourceID == Constants.Transmog.NoTransmogID then
		local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(visualID, self.activeCategoryID, self.transmogLocation);
		for _index, source in ipairs(sources) do
			-- First 1 if it doesn't have to be usable
			if not mustBeUsable or self:IsAppearanceUsableForActiveCategory(source) then
				sourceID = source.sourceID;
				break;
			end
		end
	end
	return sourceID;
end

function TransmogWardrobeItemsMixin:GetChosenVisualSource(visualID)
	return self.chosenVisualSources[visualID] or Constants.Transmog.NoTransmogID;
end

function TransmogWardrobeItemsMixin:SetChosenVisualSource(visualID, sourceID)
	self.chosenVisualSources[visualID] = sourceID;
end

function TransmogWardrobeItemsMixin:ValidateChosenVisualSources()
	for visualID, sourceID in pairs(self.chosenVisualSources) do
		if sourceID ~= Constants.Transmog.NoTransmogID then
			local keep = false;
			local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
			if sourceInfo and sourceInfo.isCollected and not sourceInfo.useError then
				keep = true;
			end

			if not keep then
				self.chosenVisualSources[visualID] = Constants.Transmog.NoTransmogID;
			end
		end
	end
end

function TransmogWardrobeItemsMixin:IsAppearanceUsableForActiveCategory(appearanceInfo)
	if not self.activeCategoryID then
		return false;
	end

	local inLegionArtifactCategory = TransmogUtil.IsCategoryLegionArtifact(self.activeCategoryID);
	return CollectionWardrobeUtil.IsAppearanceUsable(appearanceInfo, inLegionArtifactCategory);
end

function TransmogWardrobeItemsMixin:GetAppearanceNameTextAndColor(appearanceInfo)
	if not self.activeCategoryID then
		return nil, nil;
	end

	local inLegionArtifactCategory = TransmogUtil.IsCategoryLegionArtifact(self.activeCategoryID);
	return CollectionWardrobeUtil.GetAppearanceNameTextAndColor(appearanceInfo, inLegionArtifactCategory);
end

function TransmogWardrobeItemsMixin:SetAppearanceTooltip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	self.tooltipModel = frame;
	self.tooltipVisualID = frame:GetAppearanceInfo().visualID;
	self:RefreshAppearanceTooltip();
end

function TransmogWardrobeItemsMixin:RefreshAppearanceTooltip()
	if not self.tooltipVisualID or not self.transmogLocation or not self.activeCategoryID then
		return;
	end

	local sources = CollectionWardrobeUtil.GetSortedAppearanceSourcesForClass(self.tooltipVisualID, C_TransmogCollection.GetClassFilter(), self.activeCategoryID, self.transmogLocation);
	local appearanceData = {
		sources = sources,
		primarySourceID = self:GetChosenVisualSource(self.tooltipVisualID),
		selectedIndex = nil,
		showUseError = true,
		inLegionArtifactCategory = TransmogUtil.IsCategoryLegionArtifact(self.activeCategoryID),
		subheaderString = nil,
		warningString = CollectionWardrobeUtil.GetBestVisibilityWarning(self.tooltipModel, self.transmogLocation, sources),
		showTrackingInfo = false,
		slotType = nil
	}

	local _tooltipSourceIndex, _tooltipCycle = CollectionWardrobeUtil.SetAppearanceTooltip(GameTooltip, appearanceData);
end

function TransmogWardrobeItemsMixin:ClearAppearanceTooltip()
	self.tooltipModel = nil;
	self.tooltipVisualID = nil;
	GameTooltip:Hide();
end

function TransmogWardrobeItemsMixin:SetCollectionEntries(entries, retainCurrentPage)
	local compareEntries = function(element1, element2)
		local source1 = element1.appearanceInfo;
		local source2 = element2.appearanceInfo;

		if source1.isCollected ~= source2.isCollected then
			return source1.isCollected;
		end

		if source1.isUsable ~= source2.isUsable then
			return source1.isUsable;
		end

		if source1.isFavorite ~= source2.isFavorite then
			return source1.isFavorite;
		end

		if source1.canDisplayOnPlayer ~= source2.canDisplayOnPlayer then
			return source1.canDisplayOnPlayer;
		end

		if source1.isHideVisual ~= source2.isHideVisual then
			return source1.isHideVisual;
		end

		if source1.hasActiveRequiredHoliday ~= source2.hasActiveRequiredHoliday then
			return source1.hasActiveRequiredHoliday;
		end

		if source1.uiOrder and source2.uiOrder then
			return source1.uiOrder > source2.uiOrder;
		end

		return source1.sourceID > source2.sourceID;
	end

	local collectionElements = {};
	for _index, itemEntry in ipairs(entries) do
		if (itemEntry.isUsable and itemEntry.isCollected) or itemEntry.alwaysShowItem then
			local element = {
				templateKey = "COLLECTION_ITEM",
				appearanceInfo = itemEntry,
				collectionFrame = self
			};
			table.insert(collectionElements, element);
		end
	end

	table.sort(collectionElements, compareEntries);

	local collectionData = {{elements = collectionElements}};
	local dataProvider = CreateDataProvider(collectionData);
	self.PagedContent:SetDataProvider(dataProvider, retainCurrentPage);
end

function TransmogWardrobeItemsMixin:UpdateSlot(slotData, forceRefresh)
	if not slotData then
		return;
	end

	local transmogLocation = slotData.transmogLocation;
	if transmogLocation then
		local outfitSlotInfo = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(transmogLocation:GetSlot(), transmogLocation:GetType(), slotData.currentWeaponOptionInfo.weaponOption);
		if outfitSlotInfo then
			local isUnassignedOrEquipped = outfitSlotInfo.displayType == Enum.TransmogOutfitDisplayType.Unassigned or outfitSlotInfo.displayType == Enum.TransmogOutfitDisplayType.Equipped;
			if not transmogLocation:IsEqual(self.transmogLocation) or forceRefresh then
				self:SetActiveSlot(transmogLocation, forceRefresh);

				-- If initially setting to a new category and not one of the display type buttons, make sure we can correctly page to the entry we want once search filters update.
				if not isUnassignedOrEquipped then
					self.jumpToTransmogID = outfitSlotInfo.transmogID;
				end
			end

			if isUnassignedOrEquipped then
				self.PagedContent.PagingControls:SetCurrentPage(1);
			else
				self:PageToTransmogID(outfitSlotInfo.transmogID);
			end
		end
	end

	-- Force update filters to show collected or not.
	C_TransmogCollection.SetCollectedShown(transmogLocation ~= nil);
end

function TransmogWardrobeItemsMixin:GetActiveSlotInfo()
	return TransmogUtil.GetInfoForEquippedSlot(self.transmogLocation);
end

function TransmogWardrobeItemsMixin:SetActiveSlot(transmogLocation, forceRefresh)
	self:SetTransmogLocation(transmogLocation);
	local activeSlotInfo = self:GetActiveSlotInfo();

	-- Figure out a category.
	local categoryID;
	local useLastWeaponCategory = not forceRefresh and self.transmogLocation:IsEitherHand() and self.lastWeaponCategoryID and self:IsValidWeaponCategoryForSlot(self.lastWeaponCategoryID);
	if useLastWeaponCategory then
		categoryID = self.lastWeaponCategoryID;
	elseif activeSlotInfo.selectedSourceID ~= Constants.Transmog.NoTransmogID then
		local appearanceSourceInfo = C_TransmogCollection.GetAppearanceSourceInfo(activeSlotInfo.selectedSourceID);
		categoryID = appearanceSourceInfo and appearanceSourceInfo.category;
		if categoryID and not self:IsValidWeaponCategoryForSlot(categoryID) then
			categoryID = nil;
		end
	end

	if not categoryID then
		if self.transmogLocation:IsEitherHand() then
			-- Find the first valid weapon category.
			for weaponCategoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
				if self:IsValidWeaponCategoryForSlot(weaponCategoryID) then
					categoryID = weaponCategoryID;
					break;
				end
			end
		else
			categoryID = self.transmogLocation:GetArmorCategoryID();
		end
	end

	if categoryID and categoryID ~= self.activeCategoryID then
		self:SetActiveCategory(categoryID);
	end

	self:Refresh();
end

function TransmogWardrobeItemsMixin:IsValidWeaponCategoryForSlot(categoryID)
	local selectedSlotData = self:GetSelectedSlotCallback();
	if not selectedSlotData or not selectedSlotData.transmogLocation then
		return false;
	end

	local collectionInfo = C_TransmogOutfitInfo.GetCollectionInfoForSlotAndOption(selectedSlotData.transmogLocation:GetSlot(), selectedSlotData.currentWeaponOptionInfo.weaponOption, categoryID);
	return collectionInfo and collectionInfo.isWeapon;
end

function TransmogWardrobeItemsMixin:PageToTransmogID(transmogID)
	if transmogID == Constants.Transmog.NoTransmogID then
		self.PagedContent.PagingControls:SetCurrentPage(1);
		return;
	end

	self.PagedContent:GoToElementByPredicate(function(elementData)
		if self.transmogLocation:IsAppearance() then
			local mustBeUsable = true;
			local sourceID = self:GetAnAppearanceSourceFromVisual(elementData.appearanceInfo.visualID, mustBeUsable);

			return sourceID == transmogID;
		else
			return elementData.appearanceInfo.sourceID == transmogID;
		end
	end);
end

function TransmogWardrobeItemsMixin:GetActiveCategory()
	return self.activeCategoryID;
end

function TransmogWardrobeItemsMixin:SetActiveCategory(categoryID)
	if self.activeCategoryID == categoryID then
		return;
	end

	self.activeCategoryID = categoryID;

	local selectedSlotData = self:GetSelectedSlotCallback();
	if not selectedSlotData or not selectedSlotData.transmogLocation or not self.transmogLocation then
		return;
	end

	if self.transmogLocation:IsAppearance() then
		C_TransmogCollection.SetSearchAndFilterCategory(self.activeCategoryID);
		local collectionInfo = C_TransmogOutfitInfo.GetCollectionInfoForSlotAndOption(selectedSlotData.transmogLocation:GetSlot(), selectedSlotData.currentWeaponOptionInfo.weaponOption, self.activeCategoryID);
		if collectionInfo and collectionInfo.isWeapon then
			self.lastWeaponCategoryID = self.activeCategoryID;
		end
	end
end

function TransmogWardrobeItemsMixin:GetTransmogLocation()
	return self.transmogLocation;
end

function TransmogWardrobeItemsMixin:SetTransmogLocation(transmogLocation)
	self.transmogLocation = transmogLocation;
end

function TransmogWardrobeItemsMixin:GetActiveSlot()
	return self.transmogLocation and self.transmogLocation:GetSlotName();
end

function TransmogWardrobeItemsMixin:HasActiveSecondaryAppearance()
	local secondaryAppearanceToggle = self.SecondaryAppearanceToggle;
	return secondaryAppearanceToggle:IsShown() and secondaryAppearanceToggle.Checkbox:GetChecked();
end

function TransmogWardrobeItemsMixin:GetOutfitSlotSavedState()
	return self.outfitSlotSaved;
end

function TransmogWardrobeItemsMixin:SetOutfitSlotSavedState(outfitSlotSaved)
	self.outfitSlotSaved = outfitSlotSaved;
end

function TransmogWardrobeItemsMixin:GetSelectedSlotCallback()
	return self.wardrobeCollection.GetSelectedSlotCallback();
end

function TransmogWardrobeItemsMixin:GetSlotFrameCallback(slot, type)
	return self.wardrobeCollection.GetSlotFrameCallback(slot, type);
end


TransmogWardrobeSetsMixin = {
	DYNAMIC_EVENTS = {
		"TRANSMOG_SEARCH_UPDATED",
		"TRANSMOG_COLLECTION_UPDATED",
		"TRANSMOG_SETS_UPDATE_FAVORITE",
		"UI_SCALE_CHANGED",
		"DISPLAY_SIZE_CHANGED",
		"VIEWED_TRANSMOG_OUTFIT_SLOT_SAVE_SUCCESS"
	};
	COLLECTION_TEMPLATES = {
		["COLLECTION_SET"] = { template = "TransmogSetModelTemplate", initFunc = TransmogSetModelMixin.Init, resetFunc = TransmogSetModelMixin.Reset }
	};
};

function TransmogWardrobeSetsMixin:OnLoad()
	self:InitFilterButton();
	self.PagedContent:SetElementTemplateData(self.COLLECTION_TEMPLATES);
	self.SearchBox:SetSearchType(self.searchType);
	self.setsDataProvider = CreateFromMixins(WardrobeSetsDataProviderMixin);
end

function TransmogWardrobeSetsMixin:OnShow()
	local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
	if hasAlternateForm then
		self:RegisterUnitEvent("UNIT_FORM_CHANGED", "player");
		self.inAlternateForm = inAlternateForm;
	end
	FrameUtil.RegisterFrameForEvents(self, self.DYNAMIC_EVENTS);

	self:RefreshCollectionEntries();
end

function TransmogWardrobeSetsMixin:OnHide()
	self:UnregisterEvent("UNIT_FORM_CHANGED");
	FrameUtil.UnregisterFrameForEvents(self, self.DYNAMIC_EVENTS);
end

function TransmogWardrobeSetsMixin:OnEvent(event, ...)
	if event == "UNIT_FORM_CHANGED" then
		self:HandleFormChanged();
	elseif event == "TRANSMOG_SEARCH_UPDATED" then
		local searchType, _collectionType = ...;
		if searchType == self.searchType then
			self:RefreshCollectionEntries();
		end
	elseif event == "TRANSMOG_COLLECTION_UPDATED" or event == "TRANSMOG_SETS_UPDATE_FAVORITE" then
		self:RefreshCollectionEntries();
	elseif event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
		self:RefreshCameras();
	elseif event == "VIEWED_TRANSMOG_OUTFIT_SLOT_SAVE_SUCCESS" then
		local _slot, _type, _weaponOption = ...;

		-- Already set to true, do not stomp if multiple slots are changing.
		if self:GetOutfitSlotSavedState() then
			return;
		end

		local appliedSetID, _hasPending = self:GetFirstMatchingSetID();
		local outfitSlotSaved = appliedSetID ~= nil;
		self:SetOutfitSlotSavedState(outfitSlotSaved);
	end
end

function TransmogWardrobeSetsMixin:Init(wardrobeCollection)
	self.wardrobeCollection = wardrobeCollection;
end

function TransmogWardrobeSetsMixin:InitFilterButton()
	self.FilterButton:SetupMenu(function(_dropdown, rootDescription)
		rootDescription:SetTag("MENU_TRANSMOG_SETS_FILTER");

		local function SetSetsFilter(filter)
			C_TransmogSets.SetSetsFilter(filter, not C_TransmogSets.GetSetsFilter(filter));
		end

		rootDescription:CreateCheckbox(COLLECTED, C_TransmogSets.GetSetsFilter, SetSetsFilter, LE_TRANSMOG_SET_FILTER_COLLECTED);
		rootDescription:CreateCheckbox(NOT_COLLECTED, C_TransmogSets.GetSetsFilter, SetSetsFilter, LE_TRANSMOG_SET_FILTER_UNCOLLECTED);
		rootDescription:CreateDivider();
		rootDescription:CreateCheckbox(TRANSMOG_SET_PVE, C_TransmogSets.GetSetsFilter, SetSetsFilter, LE_TRANSMOG_SET_FILTER_PVE);
		rootDescription:CreateCheckbox(TRANSMOG_SET_PVP, C_TransmogSets.GetSetsFilter, SetSetsFilter, LE_TRANSMOG_SET_FILTER_PVP);
	end);

	self.FilterButton:SetIsDefaultCallback(function()
		return C_TransmogSets.IsUsingDefaultSetsFilters();
	end);

	self.FilterButton:SetDefaultCallback(function()
		return C_TransmogSets.SetDefaultSetsFilters();
	end);
end

function TransmogWardrobeSetsMixin:HandleFormChanged()
	if IsUnitModelReadyForUI("player") then
		local _hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
		if self.inAlternateForm ~= inAlternateForm then
			self.inAlternateForm = inAlternateForm;
			self:RefreshCollectionEntries();
		end
	end
end

function TransmogWardrobeSetsMixin:RefreshCollectionEntries()
	self.setsDataProvider:ClearSets();

	local collectionElements = {};
	local availableSets = self.setsDataProvider:GetAvailableSets();
	for _index, availableSet in ipairs(availableSets) do
		local element = {
			templateKey = "COLLECTION_SET",
			set = availableSet,
			sourceData = self.setsDataProvider:GetSetSourceData(availableSet.setID),
			collectionFrame = self
		};
		table.insert(collectionElements, element);
	end

	local collectionData = {{elements = collectionElements}};
	local dataProvider = CreateDataProvider(collectionData);
	local retainCurrentPage = true;
	self.PagedContent:SetDataProvider(dataProvider, retainCurrentPage);
end

function TransmogWardrobeSetsMixin:RefreshCameras()
	self.PagedContent:ForEachFrame(function(frame)
		frame:RefreshSetCamera();
	end);
end

function TransmogWardrobeSetsMixin:GetFirstMatchingSetID()
	local appliedSetID, hasPending;

	local transmogInfo = self:GetCurrentTransmogInfoCallback();
	local usableSets = self.setsDataProvider:GetUsableSets();
	for _index, usableSet in ipairs(usableSets) do
		local setMatched = false;
		hasPending = false;
		for transmogLocation, info in pairs(transmogInfo) do
			if transmogLocation:IsAppearance() then
				local sourceIDs = C_TransmogOutfitInfo.GetSourceIDsForSlot(usableSet.setID, transmogLocation:GetSlot());
				-- If there are no sources for a slot, that slot is considered matched.
				local slotMatched = #sourceIDs == 0;
				for _indexSourceIDs, sourceID in ipairs(sourceIDs) do
					if info.transmogID == sourceID then
						slotMatched = true;
						if not hasPending and info.hasPending then
							hasPending = true;
						end
						break;
					end
				end

				setMatched = slotMatched;
				if not setMatched then
					break;
				end
			end
		end

		if setMatched then
			appliedSetID = usableSet.setID;
			break;
		end
	end

	return appliedSetID, hasPending;
end

function TransmogWardrobeSetsMixin:GetOutfitSlotSavedState()
	return self.outfitSlotSaved;
end

function TransmogWardrobeSetsMixin:SetOutfitSlotSavedState(outfitSlotSaved)
	self.outfitSlotSaved = outfitSlotSaved;
end

function TransmogWardrobeSetsMixin:GetCurrentTransmogInfoCallback()
	return self.wardrobeCollection.GetCurrentTransmogInfoCallback();
end


TransmogWardrobeCustomSetsMixin = {
	DYNAMIC_EVENTS = {
		"TRANSMOG_CUSTOM_SETS_CHANGED",
		"UI_SCALE_CHANGED",
		"DISPLAY_SIZE_CHANGED",
		"VIEWED_TRANSMOG_OUTFIT_SLOT_SAVE_SUCCESS",
		"VIEWED_TRANSMOG_OUTFIT_SLOT_REFRESH"
	};
	COLLECTION_TEMPLATES = {
		["COLLECTION_CUSTOM_SET"] = { template = "TransmogCustomSetModelTemplate", initFunc = TransmogCustomSetModelMixin.Init, resetFunc = TransmogCustomSetModelMixin.Reset }
	};
};

function TransmogWardrobeCustomSetsMixin:OnLoad()
	self.PagedContent:SetElementTemplateData(self.COLLECTION_TEMPLATES);

	self.NewCustomSetButton:SetScript("OnClick", function()
		local data = { name = "", customSetID = nil, itemTransmogInfoList = self:GetItemTransmogInfoListCallback() };
		StaticPopup_Show("TRANSMOG_CUSTOM_SET_NAME", nil, nil, data);
	end);

	self.NewCustomSetButton:SetScript("OnEnter", function(button)
		local showTooltip = self.NewCustomSetButton.Text:IsTruncated() or not button:IsEnabled();
		if showTooltip then
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT");

			if self.NewCustomSetButton.Text:IsTruncated() then
				local text = self.NewCustomSetButton.Text:GetText();
				if text then
					GameTooltip_AddNormalLine(GameTooltip, text);
				end
			end

			if not button:IsEnabled() then
				GameTooltip_AddErrorLine(GameTooltip, TRANSMOG_CUSTOM_SET_NEW_TOOLTIP_DISABLED);
			end

			GameTooltip:Show();
		end
	end);

	self.NewCustomSetButton:SetScript("OnLeave", GameTooltip_Hide);
end

function TransmogWardrobeCustomSetsMixin:OnShow()
	local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
	if hasAlternateForm then
		self:RegisterUnitEvent("UNIT_FORM_CHANGED", "player");
		self.inAlternateForm = inAlternateForm;
	end
	FrameUtil.RegisterFrameForEvents(self, self.DYNAMIC_EVENTS);

	self:RefreshNewCustomSetButton();
	self:RefreshCollectionEntries();
end

function TransmogWardrobeCustomSetsMixin:OnHide()
	self:UnregisterEvent("UNIT_FORM_CHANGED");
	FrameUtil.UnregisterFrameForEvents(self, self.DYNAMIC_EVENTS);
end

function TransmogWardrobeCustomSetsMixin:OnEvent(event, ...)
	if event == "UNIT_FORM_CHANGED" then
		self:HandleFormChanged();
	elseif event == "TRANSMOG_CUSTOM_SETS_CHANGED" then
		self:RefreshCollectionEntries();
	elseif event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
		self:RefreshCameras();
	elseif event == "VIEWED_TRANSMOG_OUTFIT_SLOT_SAVE_SUCCESS" then
		local _slot, _type, _weaponOption = ...;

		-- Already set to true, do not stomp if multiple slots are changing.
		if self:GetOutfitSlotSavedState() then
			return;
		end

		local appliedCustomSetID, _hasPending = self:GetFirstMatchingCustomSetID();
		local outfitSlotSaved = appliedCustomSetID ~= nil;
		self:SetOutfitSlotSavedState(outfitSlotSaved);
	elseif event == "VIEWED_TRANSMOG_OUTFIT_SLOT_REFRESH" then
		self:RefreshNewCustomSetButton();
	end
end

function TransmogWardrobeCustomSetsMixin:Init(wardrobeCollection)
	self.wardrobeCollection = wardrobeCollection;
end

function TransmogWardrobeCustomSetsMixin:HandleFormChanged()
	if IsUnitModelReadyForUI("player") then
		local _hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
		if self.inAlternateForm ~= inAlternateForm then
			self.inAlternateForm = inAlternateForm;
			self:RefreshCollectionEntries();
		end
	end
end

function TransmogWardrobeCustomSetsMixin:RefreshNewCustomSetButton()
	-- Enable the new custom set button if there is at least 1 valid slot apperance to make a custom set from.
	local itemTransmogInfoList = self:GetItemTransmogInfoListCallback();
	local hasValidAppearance = TransmogUtil.IsValidItemTransmogInfoList(itemTransmogInfoList);
	self.NewCustomSetButton:SetEnabled(hasValidAppearance);
end

function TransmogWardrobeCustomSetsMixin:RefreshCollectionEntries()
	local compareEntries = function(element1, element2)
		if element1.isCollected ~= element2.isCollected then
			return element1.isCollected;
		end

		local customSetName1, _customSetIcon1 = C_TransmogCollection.GetCustomSetInfo(element1.customSetID);
		local customSetName2, _customSetIcon2 = C_TransmogCollection.GetCustomSetInfo(element2.customSetID);
		return customSetName1 < customSetName2;
	end

	local collectionElements = {};
	local customSets = C_TransmogCollection.GetCustomSets();
	for _indexCustomSet, customSetID in ipairs(customSets) do
		local isCollected = TransmogUtil.IsCustomSetCollected(customSetID);

		local element = {
			templateKey = "COLLECTION_CUSTOM_SET",
			customSetID = customSetID,
			isCollected = isCollected,
			collectionFrame = self
		};
		table.insert(collectionElements, element);
	end
	table.sort(collectionElements, compareEntries);

	local collectionData = {{elements = collectionElements}};
	local dataProvider = CreateDataProvider(collectionData);
	local retainCurrentPage = true;
	self.PagedContent:SetDataProvider(dataProvider, retainCurrentPage);
end

function TransmogWardrobeCustomSetsMixin:RefreshCameras()
	self.PagedContent:ForEachFrame(function(frame)
		frame:RefreshSetCamera();
	end);
end

function TransmogWardrobeCustomSetsMixin:GetFirstMatchingCustomSetID()
	local appliedCustomSetID, hasPending;

	local customSets = C_TransmogCollection.GetCustomSets();
	for _indexCustomSet, customSetID in ipairs(customSets) do
		if TransmogUtil.IsCustomSetCollected(customSetID) then
			local customSetTransmogInfo = C_TransmogCollection.GetCustomSetItemTransmogInfoList(customSetID);

			local customSetMatched = false;
			hasPending = false;

			local slotMatched = false;
			for indexCustomSetInfo, customSetInfo in ipairs(customSetTransmogInfo) do
				-- Should we check this slot? (filters out non appearances like neck slot, as well as slots not set in the custom set).
				local slot = C_TransmogOutfitInfo.GetTransmogOutfitSlotFromInventorySlot(indexCustomSetInfo - 1);

				-- Weapon slots are special here, as there is ambiguity with weapon options.
				local isValidSlot = slot ~= nil and not C_TransmogOutfitInfo.IsSlotWeaponSlot(slot);
				if isValidSlot and customSetInfo.appearanceID ~= Constants.Transmog.NoTransmogID then
					slotMatched = false;

					local appearanceType = Enum.TransmogType.Appearance;
					local weaponOption = Enum.TransmogOutfitSlotOption.None;
					local outfitInfo = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, appearanceType, weaponOption);
					if outfitInfo.transmogID ~= customSetInfo.appearanceID then
						break;
					end

					slotMatched = true;
					if not hasPending and outfitInfo.hasPending then
						hasPending = true;
					end
				end
			end

			customSetMatched = slotMatched;
			if customSetMatched then
				appliedCustomSetID = customSetID;
				break;
			end
		end
	end

	return appliedCustomSetID, hasPending;
end

function TransmogWardrobeCustomSetsMixin:GetOutfitSlotSavedState()
	return self.outfitSlotSaved;
end

function TransmogWardrobeCustomSetsMixin:SetOutfitSlotSavedState(outfitSlotSaved)
	self.outfitSlotSaved = outfitSlotSaved;
end

function TransmogWardrobeCustomSetsMixin:GetCurrentTransmogInfoCallback()
	return self.wardrobeCollection.GetCurrentTransmogInfoCallback();
end

function TransmogWardrobeCustomSetsMixin:GetItemTransmogInfoListCallback()
	return self.wardrobeCollection.GetItemTransmogInfoListCallback();
end


TransmogWardrobeSituationsMixin = {
	DYNAMIC_EVENTS = {
		"VIEWED_TRANSMOG_OUTFIT_SITUATIONS_CHANGED"
	};
};

function TransmogWardrobeSituationsMixin:OnLoad()
	self.SituationFramePool = CreateFramePool("FRAME", self.Situations, "TransmogSituationTemplate", nil);

	self.DefaultsButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
		C_TransmogOutfitInfo.ResetOutfitSituations();
	end);

	self.EnabledToggle.Checkbox:SetScript("OnClick", function()
		local toggledOn = not C_TransmogOutfitInfo.GetOutfitSituationsEnabled();
		if toggledOn then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		end
		C_TransmogOutfitInfo.SetOutfitSituationsEnabled(toggledOn);
		self:Refresh();
	end);

	self.ApplyButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
		C_TransmogOutfitInfo.CommitPendingSituations();
	end);

	self.UndoButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
		C_TransmogOutfitInfo.ClearAllPendingSituations();
	end);
end

function TransmogWardrobeSituationsMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, self.DYNAMIC_EVENTS);

	self:Refresh();
end

function TransmogWardrobeSituationsMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, self.DYNAMIC_EVENTS);
end

function TransmogWardrobeSituationsMixin:OnEvent(event, ...)
	if event == "VIEWED_TRANSMOG_OUTFIT_SITUATIONS_CHANGED" then
		self:Refresh();
	end
end

function TransmogWardrobeSituationsMixin:Init()
	-- Set up situation dropdowns separately from any outfit's data.
	self.SituationFramePool:ReleaseAll();

	local situationsData = C_TransmogOutfitInfo.GetUISituationCategoriesAndOptions();
	if situationsData then
		for index, data in ipairs(situationsData) do
			local situationFrame = self.SituationFramePool:Acquire();
			local situationData = {
				triggerID = data.triggerID,
				name = data.name,
				description = data.description,
				isRadioButton = data.isRadioButton,
				groupData = data.groupData
			};
			situationFrame.layoutIndex = index;

			situationFrame:Init(situationData);
			situationFrame:Show();
		end
		self.Situations:Layout();
	end
end

function TransmogWardrobeSituationsMixin:Refresh()
	local situationsEnabled = C_TransmogOutfitInfo.GetOutfitSituationsEnabled();
	self.EnabledToggle.Checkbox:SetChecked(situationsEnabled);
	self.EnabledToggle.Text:SetFontObject(situationsEnabled and "GameFontHighlight" or "GameFontNormal");
	local titleFontColor = situationsEnabled and NORMAL_FONT_COLOR or GRAY_FONT_COLOR;
	local dropdownFontColor = situationsEnabled and RED_FONT_COLOR or GRAY_FONT_COLOR;
	local formattedDefaultText = dropdownFontColor:WrapTextInColorCode(TRANSMOG_SITUATIONS_NO_VALID_OPTIONS);

	local situationsAreValid = true;
	for situationFrame in self.SituationFramePool:EnumerateActive() do
		situationFrame.Title:SetTextColor(titleFontColor:GetRGB());
		situationFrame.Dropdown:SetEnabled(situationsEnabled);
		situationFrame.Dropdown:SetDefaultText(formattedDefaultText);
		situationFrame.Dropdown:GenerateMenu();
		if situationsAreValid and not situationFrame:IsValid() then
			situationsAreValid = false;
		end
	end

	local disabledTooltip = nil;
	local disabledTooltipAnchor = nil;
	if not situationsAreValid then
		disabledTooltip = TRANSMOG_SITUATIONS_APPLY_DISABLED_TOOLTIP;
		disabledTooltipAnchor = "ANCHOR_RIGHT";
	end
	self.ApplyButton:SetDisabledTooltip(disabledTooltip, disabledTooltipAnchor);

	local hasPending = C_TransmogOutfitInfo.HasPendingOutfitSituations();
	self.ApplyButton:SetEnabled(hasPending and (situationsAreValid or not situationsEnabled));
	self.UndoButton:SetShown(hasPending);
end
