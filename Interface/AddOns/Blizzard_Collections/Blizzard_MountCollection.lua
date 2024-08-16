local MOUNT_BUTTON_HEIGHT = 46;
local PLAYER_MOUNT_LEVEL = 20;
local SUMMON_RANDOM_FAVORITE_MOUNT_SPELL = 150544;
local LOCKED_EQUIPMENT_LABEL_COLOR = CreateColor(0.450, 0.392, 0.341);
local DESATURATED_EQUIPMENT_LABEL_COLOR = CreateColor(0.502, 0.502, 0.502);

local MOUNT_FACTION_TEXTURES = {
	[0] = "MountJournalIcons-Horde",
	[1] = "MountJournalIcons-Alliance"
};

local mountFilterTypeStrings = {
	[Enum.MountType.Ground] = MOUNT_JOURNAL_FILTER_GROUND,
	[Enum.MountType.Flying] = MOUNT_JOURNAL_FILTER_FLYING,
	[Enum.MountType.Aquatic] = MOUNT_JOURNAL_FILTER_AQUATIC,
	[Enum.MountType.Dragonriding] = MOUNT_JOURNAL_FILTER_DRAGONRIDING,
	[Enum.MountType.RideAlong] = MOUNT_JOURNAL_FILTER_RIDEALONG,
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
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");
	self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("MOUNT_EQUIPMENT_APPLY_RESULT");
	self:RegisterEvent("CURSOR_CHANGED");
	self:RegisterUnitEvent("UNIT_FORM_CHANGED", "player");

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("MountListButtonTemplate", function(button, elementData)
		MountJournal_InitMountButton(button, elementData);
	end);
	view:SetPadding(0,0,44,0,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	MountJournal_InitFilterButton(self);

	MountJournal.MountDisplay.ModelScene:SetResetCallback(MountJournal_ModelScene_OnReset);
	MountJournal.MountDisplay.ModelScene.ControlFrame:SetModelScene(MountJournal.MountDisplay.ModelScene);

	local bottomLeftInset = self.BottomLeftInset;
	self.BackgroundOverlay = bottomLeftInset.BackgroundOverlay;
	self.SlotLabel = bottomLeftInset.SlotLabel;
	self.SlotButton = bottomLeftInset.SlotButton;
	
	local unlockLevel = C_MountJournal.GetMountEquipmentUnlockLevel();
	local levelRequiredText = MOUNT_EQUIPMENT_UNLOCK_REQUIREMENT:format(unlockLevel); 
	self.SlotRequirementLabel = bottomLeftInset.SlotRequirementLabel;
	self.SlotRequirementLabel:SetText(levelRequiredText);
	self.SlotRequirementLabel:SetTextColor(LOCKED_EQUIPMENT_LABEL_COLOR:GetRGB());
	
	MountJournal_SetPendingDragonMountChanges(false);

	self.SuppressedMountEquipmentButton = bottomLeftInset.SuppressedMountEquipmentButton;

	self.ToggleDynamicFlightFlyoutButton:SetFlyout(self.DynamicFlightFlyout);

	MountJournal_UpdateEquipment(self);
end

function MountJournal_InitFilterButton(self)
	self.FilterDropdown:SetWidth(90);

	self.FilterDropdown:SetIsDefaultCallback(function()
		return C_MountJournal.IsUsingDefaultFilters();
	end);
	
	self.FilterDropdown:SetDefaultCallback(function()
		C_MountJournal.SetDefaultFilters();
	end);

	local mountSourceOrderPriorities = {
		[Enum.BattlePetSources.Drop] = 5,
		[Enum.BattlePetSources.Quest] = 5,
		[Enum.BattlePetSources.Vendor] = 5,
		[Enum.BattlePetSources.Profession] = 5,
		[Enum.BattlePetSources.WildPet] = 5,
		[Enum.BattlePetSources.Achievement] = 5,
		[Enum.BattlePetSources.WorldEvent] = 5,
		[Enum.BattlePetSources.Discovery] = 5,
		[Enum.BattlePetSources.TradingPost] = 4,
		[Enum.BattlePetSources.Promotion] = 3,
		[Enum.BattlePetSources.PetStore] = 2,
		[Enum.BattlePetSources.Tcg] = 1,
	};
	
	local function IsSourceChecked(filterIndex) 
		return C_MountJournal.IsSourceChecked(filterIndex)
	end

	local function SetSourceChecked(filterIndex) 
		C_MountJournal.SetSourceFilter(filterIndex, not IsSourceChecked(filterIndex));
	end

	self.FilterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_MOUNT_COLLECTION_FILTER");

		rootDescription:CreateCheckbox(COLLECTED, MountJournal_GetCollectedFilter, function()
			MountJournal_SetCollectedFilter(not MountJournal_GetCollectedFilter());
		end);

		rootDescription:CreateCheckbox(NOT_COLLECTED, MountJournal_GetNotCollectedFilter, function()
			MountJournal_SetNotCollectedFilter(not MountJournal_GetNotCollectedFilter());
		end);
		
		rootDescription:CreateCheckbox(MOUNT_JOURNAL_FILTER_UNUSABLE, MountJournal_GetUnusableFilter, function()
			MountJournal_SetUnusableFilter(not MountJournal_GetUnusableFilter());
		end);
		
		rootDescription:CreateSpacer();
		rootDescription:CreateTitle(MOUNT_JOURNAL_FILTER_TYPE);
		
		local function IsTypeChecked(filterIndex)
			return C_MountJournal.IsTypeChecked(filterIndex);
		end

		local function SetTypeChecked(filterIndex)
			C_MountJournal.SetTypeFilter(filterIndex, not IsTypeChecked(filterIndex));
		end

		for filterIndex = 1, Enum.MountTypeMeta.NumValues do
			if C_MountJournal.IsValidTypeFilter(filterIndex) then
				rootDescription:CreateCheckbox(mountFilterTypeStrings[filterIndex - 1], IsTypeChecked, SetTypeChecked, filterIndex);
			end
		end

		local sourceSubmenu = rootDescription:CreateButton(SOURCES);
		sourceSubmenu:CreateButton(CHECK_ALL, MountJournal_SetAllSourceFilters, true);
		sourceSubmenu:CreateButton(UNCHECK_ALL, MountJournal_SetAllSourceFilters, false);

		local filterIndexList = CollectionsUtil.GetSortedFilterIndexList("TOYS", mountSourceOrderPriorities);
		for index = 1, C_PetJournal.GetNumPetSources() do
			local filterIndex = filterIndexList[i] and filterIndexList[i].index or index;
			if C_MountJournal.IsValidSourceFilter(filterIndex) then
				sourceSubmenu:CreateCheckbox(_G["BATTLE_PET_SOURCE_"..filterIndex], IsSourceChecked, SetSourceChecked, filterIndex);
			end
		end
	end);
end

local function CreateContextMenu(owner, rootDescription, index)
	rootDescription:SetTag("MENU_MOUNT_COLLECTION_MOUNT");

	local isUsable, _, _, _, _, _, _, menuMountID = select(5, C_MountJournal.GetDisplayedMountInfo(index));

	local text;
	local checkEnabled = false;
	local needsFanfare = C_MountJournal.NeedsFanfare(menuMountID);
	if needsFanfare then
		text = UNWRAP;
	else
		local active = select(4, C_MountJournal.GetMountInfoByID(menuMountID));
		if active then
			text = BINDING_NAME_DISMOUNT;
		else
			text = MOUNT;
			checkEnabled = true;
		end
	end

	local mountButton = rootDescription:CreateButton(text, function()
		if needsFanfare then
			MountJournal_Select(index);
		end
		MountJournalMountButton_UseMount(menuMountID);
	end);
	
	if checkEnabled then
		mountButton:SetEnabled(isUsable);
	end

	if not needsFanfare then
		local button;
		local isFavorite, canFavorite = C_MountJournal.GetIsFavorite(index);
		if isFavorite then
			button = rootDescription:CreateButton(BATTLE_PET_UNFAVORITE, function()
				C_MountJournal.SetIsFavorite(index, false);
			end);
		else
			button = rootDescription:CreateButton(BATTLE_PET_FAVORITE, function()
				C_MountJournal.SetIsFavorite(index, true);
			end);
		end
		button:SetEnabled(canFavorite);
	end
end

function MountJournal_ResetMountButton(button)
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

function MountJournal_InitMountButton(button, elementData)
	local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isSteadyFlight = C_MountJournal.GetDisplayedMountInfo(elementData.index);
	local needsFanfare = C_MountJournal.NeedsFanfare(mountID);

	button.name:SetText(creatureName);
	button.icon:SetTexture(needsFanfare and COLLECTIONS_FANFARE_ICON or icon);
	button.new:SetShown(needsFanfare);
	button.newGlow:SetShown(needsFanfare);

	local yOffset = 1;
	if isSteadyFlight then
		if button.name:GetNumLines() == 1 then
			yOffset = 6;
		else
			yOffset = 5;
		end
	end
	button.name:SetPoint("LEFT", button.icon, "RIGHT", 10, yOffset);

	button.SteadyFlightLabel:SetShown(isSteadyFlight);

	button.index = elementData.index;
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
end

function MountJournal_OnEvent(self, event, ...)
	if ( event == "MOUNT_JOURNAL_USABILITY_CHANGED" or event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" or event == "COMPANION_UPDATE" or event == "PLAYER_REGEN_ENABLED" ) then
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
	elseif ( event == "PLAYER_LEVEL_CHANGED" ) then
		MountJournal_UpdateEquipment(self);
		self.ToggleDynamicFlightFlyoutButton:UpdateVisibility();
	elseif ( event == "CURSOR_CHANGED" ) then
		MountJournal_ValidateCursorDragSourceCompatible(self);
	elseif ( event == "MOUNT_EQUIPMENT_APPLY_RESULT" ) then
		local success = ...;
		MountJournal_OnEquipmentApplyResult(self, success);
	elseif ( event == "PLAYER_MOUNT_DISPLAY_CHANGED" ) then
		MountJournal_UpdateEquipmentPalette(self);
	elseif ( event == "UNIT_FORM_CHANGED" ) then
		local showPlayer = GetCVarBool("mountJournalShowPlayer");
		if(self:IsVisible() and showPlayer) then
			MountJournal_UpdateMountDisplay(true);
		end
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

function MountJournal_ModelScene_OnEnter(button)
	MountJournal.MountDisplay.ModelScene:OnEnter(button);
end

function MountJournal_ModelScene_OnLeave(button)
	MountJournal.MountDisplay.ModelScene:OnLeave(button);
end

function MountJournal_ModelScene_OnReset()
	local forceSceneChange = true;
	MountJournal_UpdateMountDisplay(forceSceneChange);
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

	self.ToggleDynamicFlightFlyoutButton:UpdateVisibility();

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
	local newDataProvider = CreateDataProvider();
	for index = 1, C_MountJournal.GetNumDisplayedMounts() do
		local mountID = C_MountJournal.GetDisplayedMountID(index);
		newDataProvider:Insert({index = index, mountID = mountID});
	end
	MountJournal.ScrollBox:SetDataProvider(newDataProvider, ScrollBoxConstants.RetainScrollPosition);

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

function MountJournal_SetPendingDragonMountChanges(isPending)
	MountJournal.PendingDragonMountChanges = isPending;
end

function MountJournal_GetPendingDragonMountChanges()
	return MountJournal.PendingDragonMountChanges;
end

function MountJournal_OnModelLoaded(mountActor)
	mountActor:Show();
end

function MountJournal_UpdateMountDisplay(forceSceneChange)
	if ( MountJournal.selectedMountID ) then
		local creatureName, spellID, icon, active, isUsable, sourceType = C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID);
		local needsFanfare = C_MountJournal.NeedsFanfare(MountJournal.selectedMountID);
		if ( MountJournal.MountDisplay.lastDisplayed ~= spellID or forceSceneChange or MountJournal_GetPendingDragonMountChanges()) then
			MountJournal_SetPendingDragonMountChanges(false);
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

			MountJournal.MountDisplay.ModelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);

			MountJournal.MountDisplay.ModelScene:PrepareForFanfare(needsFanfare);

			local mountActor = MountJournal.MountDisplay.ModelScene:GetActorByTag("unwrapped");
			if mountActor then
				mountActor:Hide();
				mountActor:SetOnModelLoadedCallback(GenerateClosure(MountJournal_OnModelLoaded, mountActor));
				mountActor:SetModelByCreatureDisplayID(creatureDisplayID, true);

				-- mount self idle animation
				if (isSelfMount) then
					mountActor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
					mountActor:SetAnimation(618); -- MountSelfIdle
				else
					mountActor:SetAnimationBlendOperation(Enum.ModelBlendOperation.Anim);
					mountActor:SetAnimation(0);
				end
				local showPlayer = GetCVarBool("mountJournalShowPlayer");
				if not disablePlayerMountPreview and not showPlayer then
					disablePlayerMountPreview = true;
				end
				local useNativeForm = PlayerUtil.ShouldUseNativeFormInModelScene();
				MountJournal.MountDisplay.ModelScene:AttachPlayerToMount(mountActor, animID, isSelfMount, disablePlayerMountPreview, spellVisualKitID, useNativeForm);
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
	return MountJournal.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return elementData.mountID == mountID;
	end);
end

function MountJournal_SetSelected(selectedMountID, selectedSpellID)
	local oldSelectedID = MountJournal.selectedMountID;
	MountJournal.selectedSpellID = selectedSpellID;
	MountJournal.selectedMountID = selectedMountID;
	MountJournal_UpdateMountDisplay();
	
	if oldSelectedID ~= selectedMountID then
		local foundFrame = MountJournal.ScrollBox:FindFrameByPredicate(function(frame, elementData)
			return elementData.mountID == oldSelectedID;
		end);
		if foundFrame then
			MountJournal_InitMountButton(foundFrame, foundFrame:GetElementData());
		end
	end

	-- Scroll to the selected mount only if it is not in view.
	local foundFrame = MountJournal.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return elementData.mountID == selectedMountID;
	end);
	if not foundFrame then
		MountJournal.ScrollBox:ScrollToElementDataByPredicate(function(elementData)
			return elementData.mountID == selectedMountID;
		end);
	else
		MountJournal_InitMountButton(foundFrame, foundFrame:GetElementData());
	end
end

function MountJournalMountButton_UseMount(mountID)
	local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(mountID);
	if ( active ) then
		C_MountJournal.Dismiss();
	elseif ( C_MountJournal.NeedsFanfare(mountID) ) then
		local function OnFinishedCallback()
			C_MountJournal.ClearFanfare(mountID);
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
		local isCollected = select(11, C_MountJournal.GetDisplayedMountInfo(parent.index));
		if isCollected then
			MenuUtil.CreateContextMenu(self, CreateContextMenu, parent.index);
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local id = parent.spellID;
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = C_Spell.GetSpellName(id);
			ChatEdit_InsertLink(spellName);
		else
			local mountLink = C_MountJournal.GetMountLink(id);
			ChatEdit_InsertLink(mountLink);
		end
	else
		C_MountJournal.Pickup(parent.index);
	end
end

function MountListItem_OnClick(self, button)
	if ( button ~= "LeftButton" ) then
		local isCollected = select(11, C_MountJournal.GetDisplayedMountInfo(self.index));
		if isCollected then
			MenuUtil.CreateContextMenu(self, CreateContextMenu, self.index);
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local id = self.spellID;
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = C_Spell.GetSpellName(id);
			ChatEdit_InsertLink(spellName);
		else
			local mountLink = C_MountJournal.GetMountLink(id);
			ChatEdit_InsertLink(mountLink);
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

function MountJournal_SetCollectedFilter(value)
	return C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, value);
end

function MountJournal_GetCollectedFilter()
	return C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED);
end

function MountJournal_SetNotCollectedFilter(value)
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, value);
end

function MountJournal_GetNotCollectedFilter()
	return C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED);
end

function MountJournal_SetUnusableFilter(value)
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE, value);
end

function MountJournal_GetUnusableFilter()
	return C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE);
end

function MountJournal_SetAllSourceFilters(value)
	C_MountJournal.SetAllSourceFilters(value); 
	return MenuResponse.Refresh;
end

--------------------------------------------------
-- Random Favorite Mount Button Mixin
MountJournalSummonRandomFavoriteButtonMixin = {};

function MountJournalSummonRandomFavoriteButtonMixin:OnLoad()
	self.spellID = SUMMON_RANDOM_FAVORITE_MOUNT_SPELL;
	local spellIcon = C_Spell.GetSpellTexture(self.spellID);
	self.texture:SetTexture(spellIcon);
	-- Use the global string instead of the spellName from the db here so that we can have custom newlines in the string
	self.spellname:SetText(MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT);
	self:RegisterForDrag("LeftButton");
end

function MountJournalSummonRandomFavoriteButtonMixin:OnClick()
	C_MountJournal.SummonByID(0);
end

function MountJournalSummonRandomFavoriteButtonMixin:OnDragStart()
	C_MountJournal.Pickup(0);
end

function MountJournalSummonRandomFavoriteButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetMountBySpellID(self.spellID);
end

--------------------------------------------------
-- Flight Mode Button Mixin
MountJournalDynamicFlightModeButtonMixin = {};

function MountJournalDynamicFlightModeButtonMixin:OnLoad()
	self.spellID = C_MountJournal.GetDynamicFlightModeSpellID();
	self:RegisterForDrag("LeftButton");
	self.NormalTexture:SetDrawLayer("OVERLAY");
	self.PushedTexture:SetDrawLayer("OVERLAY");
end

function MountJournalDynamicFlightModeButtonMixin:OnShow()
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");

	self:UpdateIcon();
end

function MountJournalDynamicFlightModeButtonMixin:OnHide()
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
end

function MountJournalDynamicFlightModeButtonMixin:OnEvent(event, ...)
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		self:UpdateIcon();
		if GameTooltip:GetOwner() == self then
			self:DisplayTooltip();
		end
	end
end

function MountJournalDynamicFlightModeButtonMixin:OnClick()
	self.flyoutButton:CloseFlyout();

	C_MountJournal.SwapDynamicFlightMode();
end

function MountJournalDynamicFlightModeButtonMixin:OnDragStart()
	C_MountJournal.PickupDynamicFlightMode();
end

function MountJournalDynamicFlightModeButtonMixin:OnEnter()
	self:DisplayTooltip();
end

function MountJournalDynamicFlightModeButtonMixin:SetFlyoutButton(flyoutButton)
	self.flyoutButton = flyoutButton;
end

function MountJournalDynamicFlightModeButtonMixin:UpdateIcon()
	local spellIcon = C_Spell.GetSpellTexture(self.spellID);
	self.texture:SetTexture(spellIcon);
end

function MountJournalDynamicFlightModeButtonMixin:DisplayTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(self.spellID);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddColoredLine(GameTooltip, FLIGHT_MODE_TOGGLE_TOOLTIP_SUBTEXT, GREEN_FONT_COLOR);
	GameTooltip:Show();
end

--------------------------------------------------
MountJournalOpenDynamicFlightSkillTreeButtonMixin = {};

function MountJournalOpenDynamicFlightSkillTreeButtonMixin:OnLoad()
	self.NormalTexture:SetDrawLayer("OVERLAY");
	self.PushedTexture:SetDrawLayer("OVERLAY");
end

function MountJournalOpenDynamicFlightSkillTreeButtonMixin:SetFlyoutButton(flyoutButton)
	self.flyoutButton = flyoutButton;
end

function MountJournalOpenDynamicFlightSkillTreeButtonMixin:OnClick()
	self.flyoutButton:CloseFlyout();

	GenericTraitUI_LoadUI();

	GenericTraitFrame:SetSystemID(Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID);
	GenericTraitFrame:SetTreeID(Constants.MountDynamicFlightConsts.TREE_ID);
	ToggleFrame(GenericTraitFrame);
end

function MountJournalOpenDynamicFlightSkillTreeButtonMixin:OnEnter()
	local tooltipOwner = self;
	GameTooltip_ShowSimpleTooltip(GetAppropriateTooltip(), OPEN_DYNAMIC_FLIGHT_TREE_TOOLTIP, SimpleTooltipConstants.NoOverrideColor, SimpleTooltipConstants.DoNotWrapText, tooltipOwner, "ANCHOR_RIGHT");
end

function MountJournalOpenDynamicFlightSkillTreeButtonMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

--------------------------------------------------
MountJournalToggleDynamicFlightFlyoutButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function MountJournalToggleDynamicFlightFlyoutButtonMixin:SetFlyout(flyout)
	self.flyout = flyout;
	self.flyout.OpenDynamicFlightSkillTreeButton:SetFlyoutButton(self);
	self.flyout.DynamicFlightModeButton:SetFlyoutButton(self);

	self:UpdateArrow();
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:ToggleFlyout()
	self.flyout:SetShown(not self.flyout:IsShown());

	self:UpdateArrow();
	self:UpdateUnspentGlyphsAnimation();
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:CloseFlyout()
	self.flyout:Hide();

	self:UpdateArrow();
	self:UpdateUnspentGlyphsAnimation();
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:OnEvent(event, ...)
	if event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		local treeID = ...;
		if treeID == Constants.MountDynamicFlightConsts.TREE_ID then
			self:UpdateCanSpendGlyphs();
		end
	end
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:OnHide()
	self:UnregisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED");

	self:CloseFlyout();
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:OnShow()
	self:RegisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED");

	self:UpdateCanSpendGlyphs();
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:OnClick()
	self:ToggleFlyout();
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:OnButtonStateChanged()
	self:UpdateArrow();
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:SetArrowPosition(arrow, rotation, offset)
	SetClampedTextureRotation(arrow, rotation);
	arrow:ClearAllPoints();
	arrow:SetPoint("BOTTOM", self, "BOTTOM", 0, offset);
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:UpdateCanSpendGlyphs()
	local canSpendDragonridingGlyphs = DragonridingUtil.CanSpendDragonridingGlyphs();
	if canSpendDragonridingGlyphs == self.canSpendDragonridingGlyphs then
		return;
	end

	self.canSpendDragonridingGlyphs = canSpendDragonridingGlyphs;

	self:UpdateUnspentGlyphsAnimation();
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:UpdateVisibility()
	local isDragonRidingUnlocked = DragonridingUtil.IsDragonridingUnlocked();
	self:SetShown(isDragonRidingUnlocked);
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:UpdateUnspentGlyphsAnimation()
	-- If the flyout is shown MountJournalOpenDynamicFlightSkillTreeButtonMixin takes over the pulsing animation.
	local isFlyoutShown = self.flyout:IsShown();

	self.UnspentGlyphsAnim:SetPlaying(self.canSpendDragonridingGlyphs and not isFlyoutShown);

	self.flyout.OpenDynamicFlightSkillTreeButton.UnspentGlyphsAnim:SetPlaying(self.canSpendDragonridingGlyphs and isFlyoutShown);
end

function MountJournalToggleDynamicFlightFlyoutButtonMixin:UpdateArrow()
	if self:IsDown() then
		self.FlyoutArrowNormal:Hide();
		self.FlyoutArrowHighlight:Hide();
		self.FlyoutArrowPushed:Show();
	else
		self.FlyoutArrowNormal:Show();
		self.FlyoutArrowHighlight:Show();
		self.FlyoutArrowPushed:Hide();
	end

	if self.flyout:IsShown() then
		local rotation = 180;
		self:SetArrowPosition(self.FlyoutArrowNormal, rotation, self.openArrowOffset);
		self:SetArrowPosition(self.FlyoutArrowHighlight, rotation, self.openArrowOffset);
		self:SetArrowPosition(self.FlyoutArrowPushed, rotation, self.openArrowOffset);
	else
		local rotation = 0;
		self:SetArrowPosition(self.FlyoutArrowNormal, rotation, self.closedArrowOffset);
		self:SetArrowPosition(self.FlyoutArrowHighlight, rotation, self.closedArrowOffset);
		self:SetArrowPosition(self.FlyoutArrowPushed, rotation, self.closedArrowOffset);
	end
end

--------------------------------------------------------

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


