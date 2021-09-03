local MOUNT_BUTTON_HEIGHT = 46;
local PLAYER_MOUNT_LEVEL = 20;
local SUMMON_RANDOM_FAVORITE_MOUNT_SPELL = 150544;
local LOCKED_EQUIPMENT_LABEL_COLOR = CreateColor(0.450, 0.392, 0.341);
local DESATURATED_EQUIPMENT_LABEL_COLOR = CreateColor(0.502, 0.502, 0.502);

local MOUNT_FACTION_TEXTURES = {
	[0] = "MountJournalIcons-Horde",
	[1] = "MountJournalIcons-Alliance"
};

local mountTypeStrings = {
	[Enum.MountType.Ground] = MOUNT_JOURNAL_FILTER_GROUND,
	[Enum.MountType.Flying] = MOUNT_JOURNAL_FILTER_FLYING,
	[Enum.MountType.Aquatic] = MOUNT_JOURNAL_FILTER_AQUATIC,
};

StaticPopupDialogs["DIALOG_REPLACE_MOUNT_EQUIPMENT"] = {
	text = DIALOG_INSTRUCTION_REPLACE_MOUNT_EQUIPMENT,
	button1 = YES,
	button2 = NO,
	
	OnAccept = function()
		MountJournal_OnDialogApplyEquipmentChoice(MountJournal, true);
		PlaySound(SOUNDKIT.UI_MOUNT_SLOTEQUIPMENT_APPROVAL);
	end,
	OnCancel = function()
		MountJournal_OnDialogApplyEquipmentChoice(MountJournal, false);
	end,
	timeout = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1,
};

SuppressedMountEquipmentButtonMixin = {};
function SuppressedMountEquipmentButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", self:GetWidth());
	GameTooltip_AddErrorLine(GameTooltip, MOUNT_EQUIPMENT_EXEMPT, true);
	GameTooltip:Show();
end

function SuppressedMountEquipmentButtonMixin:OnLeave()
	GameTooltip:Hide();
end

AlertMountEquipmentFeatureMixin = CreateFromMixins(NewFeatureLabelMixin);

function AlertMountEquipmentFeatureMixin:ClearAlert()
	NewFeatureLabelMixin.ClearAlert(self);
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_MOUNT_EQUIPMENT_SLOT_FRAME, true);
	CollectionsMicroButton_SetAlertShown(false);
end

function AlertMountEquipmentFeatureMixin:ValidateIsShown()
	self:SetShown(not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_MOUNT_EQUIPMENT_SLOT_FRAME));
end

MountEquipmentButtonMixin = {};
function MountEquipmentButtonMixin:Initialize(item)
	self.ItemIcon:SetTexture(item and item:GetItemIcon() or nil);
	self.ItemBorder:SetShown(item ~= nil);
end

function MountEquipmentButtonMixin:OnReceiveDrag()
	self:ApplyEquipmentAtCursor();
end

function MountEquipmentButtonMixin:OnClick()
	if not IsModifiedClick() then
		self:ApplyEquipmentAtCursor();
	else
		if IsModifiedClick("CHATLINK") then
			local itemID = C_MountJournal.GetAppliedMountEquipmentID();
			local item = itemID and Item:CreateFromItemID(itemID);
			if item then
				item:ContinueOnItemLoad(function()
					ChatEdit_InsertLink(item:GetItemLink())
				end);
			end
		end
	end
end

function MountJournal_CanApplyMountEquipment(itemLocation)
	if itemLocation and itemLocation:IsValid() then
		if C_MountJournal.IsItemMountEquipment(itemLocation) then
			local item = Item:CreateFromItemLocation(itemLocation);
			local itemID = item and item:GetItemID();
			return itemID and itemID ~= C_MountJournal.GetAppliedMountEquipmentID();
		end
	end
	return false;
end

function MountEquipmentButtonMixin:ApplyEquipmentAtCursor()
	if self:IsEnabled() and MountJournal_ApplyEquipment(MountJournal, C_Cursor.GetCursorItem()) then
		ClearCursor();
	end
end

function MountJournal_ApplyEquipmentFromContainerClick(self, itemLocation)
	if MountJournal_ApplyEquipment(self, itemLocation) then
		self.SlotButton:ClearAlert();
	end
end

function MountEquipmentButtonMixin:SetPendingApply(isPending)
	if isPending then
		self:SetButtonState("NORMAL");
		self:SetDragTargetAnimationPlaying(false);
	end
	self:SetEnabled(not isPending);
	self.SlotBorder:SetShown(not isPending);
	self.SlotBorderOpen:SetShown(isPending);
end

function MountEquipmentButtonMixin:SetDragTargetAnimationPlaying(playing)
	self.NotifyDragTargetAnim:SetPlaying(playing and self:IsEnabled());
end

function MountEquipmentButtonMixin:OnEnter()
	self:ClearAlert();
	
	MountJournal_InitializeEquipmentTooltip(MountJournal);
end

function MountEquipmentButtonMixin:ClearAlert()
	self.NewAlert:ClearAlert();
end

function MountEquipmentButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function MountJournal_OnLoad(self)
	self:RegisterEvent("COMPANION_LEARNED");
	self:RegisterEvent("COMPANION_UNLEARNED");
	self:RegisterEvent("COMPANION_UPDATE");
	self:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED");
	self:RegisterEvent("MOUNT_JOURNAL_SEARCH_UPDATED");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
	self:RegisterEvent("MOUNT_EQUIPMENT_APPLY_RESULT");
	self:RegisterEvent("CURSOR_UPDATE");

	self.ListScrollFrame.update = MountJournal_UpdateMountList;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "MountListButtonTemplate", 44, 0);
	UIDropDownMenu_Initialize(self.mountOptionsMenu, MountOptionsMenu_Init, "MENU");

	local bottomLeftInset = self.BottomLeftInset;
	self.BackgroundOverlay = bottomLeftInset.BackgroundOverlay;
	self.SlotLabel = bottomLeftInset.SlotLabel;
	self.SlotButton = bottomLeftInset.SlotButton;
	
	local unlockLevel = C_MountJournal.GetMountEquipmentUnlockLevel();
	local levelRequiredText = MOUNT_EQUIPMENT_UNLOCK_REQUIREMENT:format(unlockLevel); 
	self.SlotRequirementLabel = bottomLeftInset.SlotRequirementLabel;
	self.SlotRequirementLabel:SetText(levelRequiredText);
	self.SlotRequirementLabel:SetTextColor(LOCKED_EQUIPMENT_LABEL_COLOR:GetRGB());
	
	self.SuppressedMountEquipmentButton = bottomLeftInset.SuppressedMountEquipmentButton;
	
	MountJournal_UpdateEquipment(self);
end

function MountJournal_OnEvent(self, event, ...)
	if ( event == "MOUNT_JOURNAL_USABILITY_CHANGED" or event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" or event == "COMPANION_UPDATE" ) then
		local companionType = ...;
		if ( not companionType or companionType == "MOUNT" ) then
			MountJournal_FullUpdate(self);
		end
	elseif ( event == "MOUNT_JOURNAL_SEARCH_UPDATED" ) then
		MountJournal_FullUpdate(self);
	elseif ( event == "UI_MODEL_SCENE_INFO_UPDATED" ) then
		if (self:IsVisible()) then
			MountJournal_UpdateMountDisplay(true);
		end
	elseif ( event == "PLAYER_LEVEL_UP" ) then
		MountJournal_UpdateEquipment(self);
	elseif ( event == "CURSOR_UPDATE" ) then
		MountJournal_ValidateCursorDragSourceCompatible(self);
	elseif ( event == "MOUNT_EQUIPMENT_APPLY_RESULT" ) then
		local success = ...;
		MountJournal_OnEquipmentApplyResult(self, success);
	elseif (event == "PLAYER_MOUNT_DISPLAY_CHANGED" ) then
		MountJournal_UpdateEquipmentPalette(self);
	end
end

function MountJournal_ApplyEquipment(self, itemLocation)
	if not MountJournal_CanApplyMountEquipment(itemLocation) then
		return false;
	end

	local pendingItem = Item:CreateFromItemLocation(itemLocation);
	local canContinue = true;
	if C_MountJournal.IsMountEquipmentApplied() then
		local dialog = StaticPopup_Show("DIALOG_REPLACE_MOUNT_EQUIPMENT");
		if not dialog then
			return false;
		end
		MountJournal_SetPendingApply(self, pendingItem);
	else
		MountJournal_SetPendingApply(self, pendingItem);

		canContinue = C_MountJournal.ApplyMountEquipment(itemLocation);
	end

	if canContinue then
		pendingItem:ContinueWithCancelOnItemLoad(function()
			MountJournal_InitializeEquipmentSlot(self, pendingItem);
		end);

		PlaySound(SOUNDKIT.UI_MOUNT_SLOTEQUIPMENT);
	else
		MountJournal_ClearPendingAndUpdate(self);
	end

	return canContinue;
end

function MountJournal_UpdateEquipmentPalette(self)
	local effectsSuppressed = C_MountJournal.AreMountEquipmentEffectsSuppressed();
	local locked = not C_PlayerInfo.CanPlayerUseMountEquipment();
	if locked or effectsSuppressed then
		local desaturation = 1.0;
		self.BottomLeftInset:DesaturateHierarchy(desaturation);
		self.SlotLabel:SetTextColor(DESATURATED_EQUIPMENT_LABEL_COLOR:GetRGB());
	else
		local desaturation = 0.0;
		self.BottomLeftInset:DesaturateHierarchy(desaturation);

		local displayedItem = MountJournal_GetDisplayedMountEquipmentItem(self);
		if displayedItem then
			displayedItem:ContinueWithCancelOnItemLoad(function()
				local colorObject = displayedItem:GetItemQualityColor();
				local color = colorObject and colorObject.color;
				if color then
					self.SlotLabel:SetTextColor(color:GetRGB());
				end
			end);
		else
			self.SlotLabel:SetTextColor(GameFontNormal:GetTextColor());
		end
	end

	self.SuppressedMountEquipmentButton:SetShown(effectsSuppressed);
end

function MountJournal_GetDisplayedMountEquipmentItem(self)
	return self.pendingItem or self.currentItem;
end

function MountJournal_HasPendingMountEquipment(self)
	return self.pendingItem ~= nil;
end

function MountJournal_SetPendingApply(self, item)
	if item then
		item:LockItem();
		
		self.pendingItem = item;
		self.SlotButton:SetPendingApply(true);
	end
end

function MountJournal_ClearPendingApply(self)
	local pendingItem = self.pendingItem;
	self.pendingItem = nil;

	if pendingItem then
		pendingItem:UnlockItem();
		
		self.SlotButton:SetPendingApply(false);
	end
end

function MountJournal_ClearPendingAndUpdate(self)
	MountJournal_ClearPendingApply(self);
	MountJournal_UpdateEquipment(self);
end

function MountJournal_OnDialogApplyEquipmentChoice(self, isAccepted)
	local canContinue = false;
	if isAccepted then
		local pendingItem = self.pendingItem;
		canContinue = C_MountJournal.ApplyMountEquipment(pendingItem:GetItemLocation());
	end

	if not canContinue then
		MountJournal_ClearPendingAndUpdate(self);
	end
end

function MountJournal_OnEquipmentApplyResult(self, success)
	MountJournal_ClearPendingAndUpdate(self);
end

function MountJournal_InitializeEquipmentTooltip(self)
	GameTooltip:Hide();
	GameTooltip:SetOwner(self.SlotButton, "ANCHOR_RIGHT");

	local item = MountJournal_GetDisplayedMountEquipmentItem(self);
	local itemID = item and item:GetItemID();
	if itemID then
		GameTooltip:SetItemByID(itemID);
		GameTooltip:Show();
	end
end

function MountJournal_ValidateCursorDragSourceCompatible(self)
	local itemLocation = C_Cursor.GetCursorItem();
	local canApply = MountJournal_CanApplyMountEquipment(itemLocation);
	self.SlotButton:SetDragTargetAnimationPlaying(canApply);
end

function MountJournal_InitializeEquipmentSlot(self, item)	
	self.SlotButton:Initialize(item);

	if item then
		local itemName = item:GetItemName();
		self.SlotLabel:SetText(itemName);

		-- Replace the existing tooltip if necessary.
		if GameTooltip:IsShown() and GameTooltip:GetOwner() == self.SlotButton then
			MountJournal_InitializeEquipmentTooltip(self);
		end	
	else
		self.SlotLabel:SetText(MOUNT_EQUIPMENT_NOTICE);
	end

	MountJournal_UpdateEquipmentPalette(self);
end

function MountJournal_UpdateEquipment(self)
	local isUnlocked = C_PlayerInfo.CanPlayerUseMountEquipment();
	self.SlotButton:SetShown(isUnlocked);
	self.SlotLabel:SetShown(isUnlocked);
	self.SlotRequirementLabel:SetShown(not isUnlocked);
	self.BackgroundOverlay:SetShown(not isUnlocked);

	local itemID = C_MountJournal.GetAppliedMountEquipmentID();
	self.currentItem = itemID and Item:CreateFromItemID(itemID);

	if isUnlocked then
		-- A pending item has precedence over the current item.
		local displayedItem = MountJournal_GetDisplayedMountEquipmentItem(self);
		if displayedItem then
			displayedItem:ContinueWithCancelOnItemLoad(function()
				MountJournal_InitializeEquipmentSlot(self, displayedItem);
			end);
		else
			local noItem = nil;
			MountJournal_InitializeEquipmentSlot(self, noItem);
		end
	end

	MountJournal_UpdateEquipmentPalette(self);
end

function MountJournal_FullUpdate(self)
	if (self:IsVisible()) then
		MountJournal_UpdateMountList();

		if (not MountJournal.selectedSpellID) then
			MountJournal_Select(1);
		end

		MountJournal_UpdateMountDisplay();
	end
end

function MountJournal_OnShow(self)
	MountJournal_FullUpdate(self);
	MountJournal_UpdateEquipment(self);
	CollectionsJournal:SetPortraitToAsset("Interface\\Icons\\MountJournalPortrait");

	local hasPendingItem = MountJournal_HasPendingMountEquipment(self);
	self.SlotButton:SetPendingApply(hasPendingItem);
	self.SlotButton.NewAlert:ValidateIsShown();
	EventRegistry:TriggerEvent("MountJournal.OnShow");
end

function MountJournal_OnHide(self)
	C_MountJournal.ClearRecentFanfares();
	EventRegistry:TriggerEvent("MountJournal.OnHide");
end

function MountJournal_UpdateMountList()
	local scrollFrame = MountJournal.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local numMounts = C_MountJournal.GetNumMounts();
	MountJournal.numOwned = 0;
	local showMounts = true;
	local playerLevel = UnitLevel("player");
	if  ( numMounts < 1 ) then
		-- display the no mounts message on the right hand side
		MountJournal.MountDisplay.NoMounts:Show();
		showMounts = false;
	else
		local mountIDs = C_MountJournal.GetMountIDs();
		for i, mountID in ipairs(mountIDs) do
			local _, _, _, _, _, _, _, _, _, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID);
			if (isCollected and hideOnChar ~= true) then
				MountJournal.numOwned = MountJournal.numOwned + 1;
			end
		end
		MountJournal.MountDisplay.NoMounts:Hide();
	end

	local numDisplayedMounts = C_MountJournal.GetNumDisplayedMounts();
	for i=1, #buttons do
		local button = buttons[i];
		local displayIndex = i + offset;
		if ( displayIndex <= numDisplayedMounts and showMounts ) then
			local index = displayIndex;
			local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID = C_MountJournal.GetDisplayedMountInfo(index);
			local needsFanfare = C_MountJournal.NeedsFanfare(mountID);

			button.name:SetText(creatureName);
			button.icon:SetTexture(needsFanfare and COLLECTIONS_FANFARE_ICON or icon);
			button.new:SetShown(needsFanfare);
			button.newGlow:SetShown(needsFanfare);

			button.index = index;
			button.spellID = spellID;
			button.mountID = mountID;

			button.active = active;
			if (active) then
				button.DragButton.ActiveTexture:Show();
			else
				button.DragButton.ActiveTexture:Hide();
			end
			button:Show();

			if ( MountJournal.selectedSpellID == spellID ) then
				button.selected = true;
				button.selectedTexture:Show();
			else
				button.selected = false;
				button.selectedTexture:Hide();
			end
			button:SetEnabled(true);
			CollectionItemListButton_SetRedOverlayShown(button, false);
			button.iconBorder:Hide();
			button.background:SetVertexColor(1, 1, 1, 1);
			if (isUsable or needsFanfare) then
				button.DragButton:SetEnabled(true);
				button.additionalText = nil;
				button.icon:SetDesaturated(false);
				button.icon:SetAlpha(1.0);
				button.name:SetFontObject("GameFontNormal");
			else
				if (isCollected) then
					CollectionItemListButton_SetRedOverlayShown(button, true);
					button.DragButton:SetEnabled(true);
					button.name:SetFontObject("GameFontNormal");
					button.icon:SetAlpha(0.75);
					button.additionalText = nil;
					button.background:SetVertexColor(1, 0, 0, 1);
				else
					button.icon:SetDesaturated(true);
					button.DragButton:SetEnabled(false);
					button.icon:SetAlpha(0.25);
					button.additionalText = nil;
					button.name:SetFontObject("GameFontDisable");
				end
			end

			if ( isFavorite ) then
				button.favorite:Show();
			else
				button.favorite:Hide();
			end

			if ( isFactionSpecific ) then
				button.factionIcon:SetAtlas(MOUNT_FACTION_TEXTURES[faction], true);
				button.factionIcon:Show();
			else
				button.factionIcon:Hide();
			end

			if ( button.showingTooltip ) then
				MountJournalMountButton_UpdateTooltip(button);
			end
		else
			button.name:SetText("");
			button.icon:SetTexture("Interface\\PetBattles\\MountJournalEmptyIcon");
			button.index = nil;
			button.spellID = 0;
			button.selected = false;
			CollectionItemListButton_SetRedOverlayShown(button, false);
			button.DragButton.ActiveTexture:Hide();
			button.selectedTexture:Hide();
			button:SetEnabled(false);
			button.DragButton:SetEnabled(false);
			button.icon:SetDesaturated(true);
			button.icon:SetAlpha(0.5);
			button.favorite:Hide();
			button.factionIcon:Hide();
			button.background:SetVertexColor(1, 1, 1, 1);
			button.iconBorder:Hide();
		end
	end

	local totalHeight = numDisplayedMounts * MOUNT_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
	MountJournal.MountCount.Count:SetText(MountJournal.numOwned);
	if ( not showMounts ) then
		MountJournal.selectedSpellID = nil;
		MountJournal.selectedMountID = nil;
		MountJournal_UpdateMountDisplay();
		MountJournal.MountCount.Count:SetText(0);
	end
end

function MountJournalMountButton_UpdateTooltip(self)
	GameTooltip:SetMountBySpellID(self.spellID);
end

function MountJournalMountButton_ChooseFallbackMountToDisplay(mountID, random)
	local allCreatureDisplays = C_MountJournal.GetMountAllCreatureDisplayInfoByID(mountID);
	if allCreatureDisplays and #allCreatureDisplays > 0 then
		if random then
			return allCreatureDisplays[math.random(1, #allCreatureDisplays)].creatureDisplayID;
		else
			return allCreatureDisplays[1].creatureDisplayID;
		end
	end
	return 0;
end

function MountJournal_UpdateMountDisplay(forceSceneChange)
	if ( MountJournal.selectedMountID ) then
		local creatureName, spellID, icon, active, isUsable, sourceType = C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID);
		local needsFanfare = C_MountJournal.NeedsFanfare(MountJournal.selectedMountID);
		if ( MountJournal.MountDisplay.lastDisplayed ~= spellID or forceSceneChange ) then
			local creatureDisplayID, descriptionText, sourceText, isSelfMount, _, modelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(MountJournal.selectedMountID);
			if not creatureDisplayID then
				local randomSelection = false;
				creatureDisplayID = MountJournalMountButton_ChooseFallbackMountToDisplay(MountJournal.selectedMountID, randomSelection);
			end

			MountJournal.MountDisplay.InfoButton.Name:SetText(creatureName);

			if needsFanfare then
				MountJournal.MountDisplay.InfoButton.New:Show();
				MountJournal.MountDisplay.InfoButton.NewGlow:Show();

				local offsetX = math.min(MountJournal.MountDisplay.InfoButton.Name:GetStringWidth(), MountJournal.MountDisplay.InfoButton.Name:GetWidth());
				MountJournal.MountDisplay.InfoButton.New:SetPoint("LEFT", MountJournal.MountDisplay.InfoButton.Name, "LEFT", offsetX + 8, 0);

				MountJournal.MountDisplay.InfoButton.Icon:SetTexture(COLLECTIONS_FANFARE_ICON);
			else
				MountJournal.MountDisplay.InfoButton.New:Hide();
				MountJournal.MountDisplay.InfoButton.NewGlow:Hide();

				MountJournal.MountDisplay.InfoButton.Icon:SetTexture(icon);
			end

			MountJournal.MountDisplay.InfoButton.Source:SetText(sourceText);
			MountJournal.MountDisplay.InfoButton.Lore:SetText(descriptionText)

			MountJournal.MountDisplay.lastDisplayed = spellID;

			MountJournal.MountDisplay.ModelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);

			MountJournal.MountDisplay.ModelScene:PrepareForFanfare(needsFanfare);

			local mountActor = MountJournal.MountDisplay.ModelScene:GetActorByTag("unwrapped");
			if mountActor then
				mountActor:SetModelByCreatureDisplayID(creatureDisplayID);

				-- mount self idle animation
				if (isSelfMount) then
					mountActor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_NONE);
					mountActor:SetAnimation(618); -- MountSelfIdle
				else
					mountActor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_ANIM);
					mountActor:SetAnimation(0);
				end
				local showPlayer = GetCVarBool("mountJournalShowPlayer");
				if not disablePlayerMountPreview and not showPlayer then
					disablePlayerMountPreview = true;
				end
				MountJournal.MountDisplay.ModelScene:AttachPlayerToMount(mountActor, animID, isSelfMount, disablePlayerMountPreview, spellVisualKitID);
			end
		end

		MountJournal.MountDisplay.ModelScene:Show();
		MountJournal.MountDisplay.YesMountsTex:Show();
		MountJournal.MountDisplay.InfoButton:Show();
		MountJournal.MountDisplay.NoMountsTex:Hide();
		MountJournal.MountDisplay.NoMounts:Hide();

		if ( needsFanfare ) then
			MountJournal.MountButton:SetText(UNWRAP)
			MountJournal.MountButton:Enable();
		elseif ( active ) then
			MountJournal.MountButton:SetText(BINDING_NAME_DISMOUNT);
			MountJournal.MountButton:SetEnabled(isUsable);
		else
			MountJournal.MountButton:SetText(MOUNT);
			MountJournal.MountButton:SetEnabled(isUsable);
		end
	else
		MountJournal.MountDisplay.InfoButton:Hide();
		MountJournal.MountDisplay.ModelScene:Hide();
		MountJournal.MountDisplay.YesMountsTex:Hide();
		MountJournal.MountDisplay.NoMountsTex:Show();
		MountJournal.MountDisplay.NoMounts:Show();
		MountJournal.MountButton:SetEnabled(false);
	end
end

function MountJournal_Select(index)
	local creatureName, spellID, icon, active, _, _, _, _, _, _, _, mountID = C_MountJournal.GetDisplayedMountInfo(index);
	MountJournal_SetSelected(mountID, spellID);
end

function MountJournal_SelectByMountID(mountID)
	local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(mountID);
	MountJournal_SetSelected(mountID, spellID);
end

function MountJournal_GetMountButtonHeight()
	return MOUNT_BUTTON_HEIGHT;
end

function MountJournal_GetMountButtonByMountID(mountID)
	local scrollFrame = MountJournal.ListScrollFrame;
	local buttons = scrollFrame.buttons;

	for i=1, #buttons do
		local button = buttons[i];
		if ( button.mountID == mountID ) then
			return button;
		end
	end
end

local function GetMountDisplayIndexByMountID(mountID)
	for i = 1, C_MountJournal.GetNumDisplayedMounts() do
		local creatureName, spellID, icon, active, _, _, _, _, _, _, _, currentMountID = C_MountJournal.GetDisplayedMountInfo(i);
		if currentMountID == mountID then
			return i;
		end
	end
	return nil;
end

function MountJournal_SetSelected(selectedMountID, selectedSpellID)
	MountJournal.selectedSpellID = selectedSpellID;
	MountJournal.selectedMountID = selectedMountID;
	MountJournal_HideMountDropdown();
	MountJournal_UpdateMountList();
	MountJournal_UpdateMountDisplay();
	
	local inView = MountJournal_GetMountButtonByMountID(selectedMountID) ~= nil;
	if not inView then
		local mountIndex = GetMountDisplayIndexByMountID(selectedMountID);
		if mountIndex then
			HybridScrollFrame_ScrollToIndex(MountJournal.ListScrollFrame, mountIndex, MountJournal_GetMountButtonHeight);
		end
	end
end

function MountJournalMountButton_UseMount(mountID)
	local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(mountID);
	if ( active ) then
		C_MountJournal.Dismiss();
	elseif ( C_MountJournal.NeedsFanfare(mountID) ) then
		local function OnFinishedCallback()
			C_MountJournal.ClearFanfare(mountID);
			MountJournal_HideMountDropdown();
			MountJournal_UpdateMountList();
			MountJournal_UpdateMountDisplay();
		end

		MountJournal.MountDisplay.ModelScene:StartUnwrapAnimation(OnFinishedCallback);
	else
		C_MountJournal.SummonByID(mountID);
	end
end

function MountJournalMountButton_OnClick(self)
	if MountJournal.selectedMountID then
		MountJournalMountButton_UseMount(MountJournal.selectedMountID);
	end
end

function MountJournalMountButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self:GetText(), HIGHLIGHT_FONT_COLOR:GetRGB());

	local needsFanFare = MountJournal.selectedMountID and C_MountJournal.NeedsFanfare(MountJournal.selectedMountID);
	if needsFanFare then
		GameTooltip_AddNormalLine(GameTooltip, MOUNT_UNWRAP_TOOLTIP, true);
	else
		GameTooltip_AddNormalLine(GameTooltip, MOUNT_SUMMON_TOOLTIP, true);
	end

	if MountJournal.selectedMountID ~= nil then
		local checkIndoors = true;
		local isUsable, errorText = C_MountJournal.GetMountUsabilityByID(MountJournal.selectedMountID, checkIndoors);
		if errorText ~= nil then
			GameTooltip_AddErrorLine(GameTooltip, errorText, true);
		end
	end

	GameTooltip:Show();
end

function MountListDragButton_OnClick(self, button)
	local parent = self:GetParent();
	if ( button ~= "LeftButton" ) then
		local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetDisplayedMountInfo(parent.index);
		if isCollected then
			MountJournal_ShowMountDropdown(parent.index, self, 0, 0);
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local id = parent.spellID;
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(id);
			ChatEdit_InsertLink(spellName);
		else
			local spellLink = GetSpellLink(id);
			ChatEdit_InsertLink(spellLink);
		end
	else
		C_MountJournal.Pickup(parent.index);
	end
end

function MountListItem_OnClick(self, button)
	if ( button ~= "LeftButton" ) then
		local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetDisplayedMountInfo(self.index);
		if isCollected then
			MountJournal_ShowMountDropdown(self.index, self, 0, 0);
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local id = self.spellID;
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(id);
			ChatEdit_InsertLink(spellName);
		else
			local spellLink = GetSpellLink(id);
			ChatEdit_InsertLink(spellLink);
		end
	elseif ( self.spellID ~= MountJournal.selectedSpellID ) then
		MountJournal_Select(self.index);
	end
end

function MountJournal_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	C_MountJournal.SetSearch(self:GetText());
end

function MountJournal_ClearSearch()
	MountJournal.searchBox:SetText("");
end

function MountJournalFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, MountJournalFilterDropDown_Initialize, "MENU");
end

function MountJournalFilterDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;

	if level == 1 then
		info.text = COLLECTED
		info.func = function(_, _, _, value)
						C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED,value);
					end
		info.checked = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)

		info.text = NOT_COLLECTED
		info.func = function(_, _, _, value)
						C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED,value);
					end
		info.checked = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)

		info.text = MOUNT_JOURNAL_FILTER_UNUSABLE
		info.func = function(_, _, _, value)
						C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE, value);
					end
		info.checked = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)

		UIDropDownMenu_AddSpace(level);

		info.hasArrow = false;
		info.isNotRadio = true;
		info.notCheckable = true;
		info.isTitle = true;
		info.text = MOUNT_JOURNAL_FILTER_TYPE;
		UIDropDownMenu_AddButton(info, level);

		for i=1, Enum.MountTypeMeta.NumValues do
			info = UIDropDownMenu_CreateInfo();
			info.keepShownOnClick = true;
			info.isNotRadio = true;
			if not C_MountJournal.IsValidTypeFilter(i) then
				break;
			end

			info.text = mountTypeStrings[i-1];

			info.func = function(_, _, _, value)
							C_MountJournal.SetTypeFilter(i, value);
						end
			info.checked = function() return C_MountJournal.IsTypeChecked(i) end;
			UIDropDownMenu_AddButton(info, level);
		end;

		UIDropDownMenu_AddSpace(level);

		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;

		info.text = SOURCES;
		info.value = 1;
		UIDropDownMenu_AddButton(info, level)

	else --if level == 2 then
		info.hasArrow = false;
		info.isNotRadio = true;
		info.notCheckable = true;

		info.text = CHECK_ALL
		info.func = function()
						C_MountJournal.SetAllSourceFilters(true);
						UIDropDownMenu_Refresh(MountJournalFilterDropDown, 1, 2);
					end
		UIDropDownMenu_AddButton(info, level)

		info.text = UNCHECK_ALL
		info.func = function()
						C_MountJournal.SetAllSourceFilters(false);
						UIDropDownMenu_Refresh(MountJournalFilterDropDown, 1, 2);
					end
		UIDropDownMenu_AddButton(info, level)

		info.notCheckable = false;
		local numSources = C_PetJournal.GetNumPetSources();
		for i=1,numSources do
			if C_MountJournal.IsValidSourceFilter(i) then
				info.text = _G["BATTLE_PET_SOURCE_"..i];
				info.func = function(_, _, _, value)
								C_MountJournal.SetSourceFilter(i,value);
							end
				info.checked = function() return C_MountJournal.IsSourceChecked(i) end;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end

function MountJournalSummonRandomFavoriteButton_OnLoad(self)
	self.spellID = SUMMON_RANDOM_FAVORITE_MOUNT_SPELL;
	local spellName, _, spellIcon = GetSpellInfo(self.spellID);
	self.texture:SetTexture(spellIcon);
	-- Use the global string instead of the spellName from the db here so that we can have custom newlines in the string
	self.spellname:SetText(MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT);
	self:RegisterForDrag("LeftButton");
end

function MountJournalSummonRandomFavoriteButton_OnClick(self)
	C_MountJournal.SummonByID(0);
end

function MountJournalSummonRandomFavoriteButton_OnDragStart(self)
	C_MountJournal.Pickup(0);
end

function MountJournalSummonRandomFavoriteButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetMountBySpellID(self.spellID);
end

function MountOptionsMenu_Init(self, level)
	if not MountJournal.menuMountIndex then
		return;
	end

	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;

	local active = select(4, C_MountJournal.GetMountInfoByID(MountJournal.menuMountID));
	local needsFanfare = C_MountJournal.NeedsFanfare(MountJournal.menuMountID);

	if (needsFanfare) then
		info.text = UNWRAP;
	elseif ( active ) then
		info.text = BINDING_NAME_DISMOUNT;
	else
		info.text = MOUNT;
		info.disabled = not MountJournal.menuIsUsable;
	end

	info.func = function()
		if needsFanfare then
			MountJournal_Select(MountJournal.menuMountIndex);
		end
		MountJournalMountButton_UseMount(MountJournal.menuMountID);
	end;

	UIDropDownMenu_AddButton(info, level);

	if not needsFanfare then
		info.disabled = nil;

		local canFavorite = false;
		local isFavorite = false;
		if (MountJournal.menuMountIndex) then
			 isFavorite, canFavorite = C_MountJournal.GetIsFavorite(MountJournal.menuMountIndex);
		end

		if (isFavorite) then
			info.text = BATTLE_PET_UNFAVORITE;
			info.func = function()
				C_MountJournal.SetIsFavorite(MountJournal.menuMountIndex, false);
			end
		else
			info.text = BATTLE_PET_FAVORITE;
			info.func = function()
				C_MountJournal.SetIsFavorite(MountJournal.menuMountIndex, true);
			end
		end

		if (canFavorite) then
			info.disabled = false;
		else
			info.disabled = true;
		end

		UIDropDownMenu_AddButton(info, level);
	end

	info.disabled = nil;
	info.text = CANCEL
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
end

function MountJournal_ShowMountDropdown(index, anchorTo, offsetX, offsetY)
	if (index) then
		MountJournal.menuMountIndex = index;
		MountJournal.menuMountID = select(12, C_MountJournal.GetDisplayedMountInfo(MountJournal.menuMountIndex));
		local active, isUsable = select(4, C_MountJournal.GetDisplayedMountInfo(index));
		MountJournal.active = active;
		MountJournal.menuIsUsable = isUsable;
	else
		return;
	end
	ToggleDropDownMenu(1, nil, MountJournal.mountOptionsMenu, anchorTo, offsetX, offsetY);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function MountJournal_HideMountDropdown()
	if (UIDropDownMenu_GetCurrentDropDown() == MountJournal.mountOptionsMenu) then
		HideDropDownMenu(1);
	end
end


PlayerPreviewToggle = {}
function PlayerPreviewToggle:OnShow()
	local showPlayer = GetCVarBool("mountJournalShowPlayer");	
	self:SetChecked(showPlayer);
end

function PlayerPreviewToggle:OnClick()
	if self:GetChecked() then
		SetCVar("mountJournalShowPlayer", 1);
	else
		SetCVar("mountJournalShowPlayer", 0);
	end
	MountJournal_UpdateMountDisplay(true);
end


