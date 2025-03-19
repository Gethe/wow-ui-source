local _, addonTable = ...;
local TutorialData = addonTable.TutorialData;

-- ------------------------------------------------------------------------------------------------------------
-- Add Spell To Action Bar Service
-- ------------------------------------------------------------------------------------------------------------
Class_AddSpellToActionBarService = class("AddSpellToActionBarService", Class_TutorialBase);
function Class_AddSpellToActionBarService:OnInitialize()
	self.playerClass = TutorialHelper:GetClass();
end

function Class_AddSpellToActionBarService:CanBegin(args)
	local spellID, warningString, spellMicroButtonString, optionalPreferredActionBar, requiredForm = unpack(args);
	if spellID and IsSpellKnown(spellID) then
		local button = TutorialHelper:GetActionButtonBySpellID(spellID);
		return button == nil;
	end
	return false;
end

function Class_AddSpellToActionBarService:OnBegin(args)
	local spellID, warningString, spellMicroButtonString, optionalPreferredActionBar, requiredForm = unpack(args);
	if not spellID then
		TutorialManager:Finished(self:Name());
		return;
	end

	self.inProgress = true;
	self.spellToAdd = spellID;
	self.spellIDString = "{$"..self.spellToAdd.."}";
	self.warningString = warningString;
	self.spellMicroButtonString = spellMicroButtonString or NPEV2_SPELLBOOK_ADD_SPELL;
	self.optionalPreferredActionBar = optionalPreferredActionBar;
	self.requiredForm = requiredForm;

	if self.requiredForm and (GetShapeshiftFormID() ~= self.requiredForm) then
		TutorialManager:Finished(self:Name());
		return;
	end

	if self.playerClass == "ROGUE" or self.playerClass == "DRUID" then
		Dispatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM", self);
	end

	local button = TutorialHelper:GetActionButtonBySpellID(self.spellToAdd);
	if button then
		TutorialManager:Finished(self:Name());
		return;
	end

	if self.warningString then
		local finalString = self.warningString:format(self.spellIDString);
		local content = {text = TutorialHelper:FormatString(finalString), icon=nil};
		self.PointerID = self:ShowScreenTutorial(content, nil, NPE_TutorialMainFrameMixin.FramePositions.Low);
	end

	if PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame:IsVisible() then
		self:SpellBookFrameShow();
	else
		-- Display the minimized version of the spells frame so it's less intimidating to a new player.
		PlayerSpellsUtil.SetPlayerSpellsFrameMinimizedOnNextShow(true);

		if self.spellIDString then
			self:ShowPointerTutorial(TutorialHelper:FormatString(self.spellMicroButtonString:format(self.spellIDString)), "DOWN", PlayerSpellsMicroButton, 0, 0, nil, "DOWN");
		end
		EventRegistry:RegisterCallback("PlayerSpellsFrame.SpellBookFrame.Show", self.SpellBookFrameShow, self);
	end
end

function Class_AddSpellToActionBarService:UPDATE_SHAPESHIFT_FORM()
	if self.requiredForm and (GetShapeshiftFormID() ~= self.requiredForm) then
		TutorialManager:Finished(self:Name());
		return;
	end
end

function Class_AddSpellToActionBarService:SpellBookFrameShow()
	EventRegistry:UnregisterCallback("PlayerSpellsFrame.SpellBookFrame.Show", self);
	EventRegistry:RegisterCallback("PlayerSpellsFrame.SpellBookFrame.Hide", self.SpellBookFrameHide, self);
	EventRegistry:RegisterCallback("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged", self.SpellBookFrameSpellsChanged, self);
	self:HidePointerTutorials();
	ActionButton_HideOverlayGlow(PlayerSpellsMicroButton);

	self:StartRemindTimer();
end

function Class_AddSpellToActionBarService:SpellBookFrameHide()
	TutorialManager:Finished(self:Name());
end

function Class_AddSpellToActionBarService:SpellBookFrameSpellsChanged()
	-- Don't force SpellBook back to the spell using "Go to spell", just try to find it if it's being displayed
	-- We'll fall back to a pointer visual if it isn't
	local knownSpellsOnly, toggleFlyout, flyoutReason = true, false, nil;
	self.spellButton, self.flyoutButton = PlayerSpellsFrame.SpellBookFrame:GetSpellFrame(self.spellToAdd, knownSpellsOnly, toggleFlyout, flyoutReason)
	self:UpdateVisuals();
end

function Class_AddSpellToActionBarService:ACTIONBAR_SHOW_BOTTOMLEFT()
	Dispatcher:UnregisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
	self:StartRemindTimer();
end

function Class_AddSpellToActionBarService:StartRemindTimer()
	if not self.remindTimer then
		self.remindTimer = C_Timer.NewTimer(0.1, function()
			self:RemindAbility();
			self.remindTimer = nil;
		end);
	end
end

function Class_AddSpellToActionBarService:RemindAbility()
	self:HideScreenTutorial();

	-- find an empty action button
	self.actionButton = TutorialHelper:FindEmptyButton(self.optionalPreferredActionBar);
	if not self.requested and not self.actionButton and not MultiBarBottomLeft:IsVisible() then
		-- no button was found, request the bottom left action bar be shown
		Dispatcher:RegisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
		self.requested = RequestBottomLeftActionBar();
		return;
	end

	-- have the spellbook navigate to the spell and give us the button for it
	local knownSpellsOnly, toggleFlyout, flyoutReason = true, false, nil;
	self.spellButton, self.flyoutButton = PlayerSpellsFrame.SpellBookFrame:GoToSpell(self.spellToAdd, knownSpellsOnly, toggleFlyout, flyoutReason)

	if self.actionButton and (self.flyoutButton or self.spellButton) then
		Dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	end

	self:UpdateVisuals();
end

function Class_AddSpellToActionBarService:UpdateVisuals()
	if self.actionButton and (self.flyoutButton or self.spellButton) then
		-- play the drag animation
		TutorialDragButton:Hide();
		TutorialDragButton:Show(self.flyoutButton or self.spellButton, self.actionButton);

		local tutorialString = NPEV2_SPELLBOOKREMINDER:format(self.spellIDString);
		tutorialString = TutorialHelper:FormatString(tutorialString)
		self:ShowPointerTutorial(tutorialString, "LEFT", self.flyoutButton or self.spellButton, -100, 0, nil, "LEFT");
	else
		-- no drag, only pointer 
		TutorialDragButton:Hide();
		local tutorialString = NPEV2_SPELLBOOKREMINDER_PART2:format(self.spellIDString);
		tutorialString = TutorialHelper:FormatString(tutorialString)

		if self.flyoutButton or self.spellButton then
			self:ShowPointerTutorial(tutorialString, "LEFT", self.flyoutButton or self.spellButton, -100, 0, nil, "LEFT");
		else
			self:ShowPointerTutorial(tutorialString, "DOWN", PlayerSpellsFrame.SpellBookFrame, 15, -20, nil, "RIGHT");
		end
	end
end

function Class_AddSpellToActionBarService:ACTIONBAR_SLOT_CHANGED(slot)
	local button = TutorialHelper:GetActionButtonBySpellID(self.spellToAdd);
	if button then
		TutorialManager:Finished(self:Name());
	else
		local _, spellID = GetActionInfo(slot);

		-- HACK: there is a special Tutorial only condition here we need to check here for Freezing Trap
		local normalFreezingTrapSpellID = 187650;
		local specialFreezingTrapSpellID = 321164;
		if self.spellToAdd == normalFreezingTrapSpellID then
			if (spellID == normalFreezingTrapSpellID) or (spellID == specialFreezingTrapSpellID) then
				TutorialManager:Finished(self:Name());
				return;
			end
		end

		local nextEmptyButton = TutorialHelper:FindEmptyButton();
		if not nextEmptyButton then
			TutorialManager:Finished(self:Name());-- no more empty buttons
		elseif self.actionButton ~= nextEmptyButton then
			self.actionButton = nextEmptyButton;
			self:UpdateVisuals();
		end
	end
end

function Class_AddSpellToActionBarService:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_AddSpellToActionBarService:OnComplete()
	Dispatcher:UnregisterEvent("ACTIONBAR_SLOT_CHANGED", self);
	Dispatcher:UnregisterEvent("UPDATE_SHAPESHIFT_FORM", self);
	Dispatcher:UnregisterEvent("ACTIONBAR_SHOW_BOTTOMLEFT", self);
	EventRegistry:UnregisterCallback("PlayerSpellsFrame.SpellBookFrame.Show", self);
	EventRegistry:UnregisterCallback("PlayerSpellsFrame.SpellBookFrame.Hide", self);
	EventRegistry:UnregisterCallback("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged", self);
	self:HidePointerTutorials();
	self:HideScreenTutorial();
	TutorialDragButton:Hide();

	if self.remindTimer then
		self.remindTimer:Cancel();
		self.remindTimer = nil;
	end

	self.spellToAdd = nil;
	self.actionButton = nil;
	self.spellButton = nil;
	self.inProgress = false;
end

-- ------------------------------------------------------------------------------------------------------------
-- Item Upgrade Checking Service - Watches you inventory for item upgrades to kick off this sequence
-- ------------------------------------------------------------------------------------------------------------
Class_ItemUpgradeCheckingService = class("ItemUpgradeCheckingService", Class_TutorialBase);
function Class_ItemUpgradeCheckingService:OnInitialize()
	self.WeaponType = {
		TwoHand	= "TwoHand",
		Ranged	= "Ranged",
		Other	= "Other",
	}
end

function Class_ItemUpgradeCheckingService:CanBegin()
	return UnitLevel("player") < TutorialData.MAX_ITEM_HELP_LEVEL;
end

function Class_ItemUpgradeCheckingService:OnBegin()
	local upgrades = self:GetBestItemUpgrades();
	local slot, item = next(upgrades);

	if item and slot ~= INVSLOT_TABARD then
		TutorialManager:Queue(Class_ChangeEquipment.name, item);
	end
	TutorialManager:Finished(self:Name());
end

function Class_ItemUpgradeCheckingService:STRUCT_ItemContainer(itemLink, characterSlot, container, containerSlot)
	return
	{
		ItemLink = itemLink,
		Container = container,
		ContainerSlot = containerSlot,
		CharacterSlot = characterSlot,
	};
end

-- Find the best item a player can equip from their bags per equipment slot
-- @return A table keyed off equipment slot that contains a STRUCT_ItemContainer
function Class_ItemUpgradeCheckingService:GetBestItemUpgrades()
	local potentialUpgrades = self:GetPotentialItemUpgrades();
	local upgrades = {};

	for equipmentSlot, items in pairs(potentialUpgrades) do
		local highest = nil;
		local highestIlvl = 0;

		for i = 1, #items do
			local itemLink = items[i].ItemLink;
			local itemQuality = select(3, C_Item.GetItemInfo(itemLink));
			local ilvl = C_Item.GetDetailedItemLevelInfo(itemLink) or 0;
			if (itemQuality == Enum.ItemQuality.Heirloom) then
				-- always recommend heirlooms, regardless of iLevel
				highest = items[i];
				highestIlvl = ilvl;
				break;
			elseif (ilvl > highestIlvl) then
				highest = items[i];
				highestIlvl = ilvl;
			end
		end

		if (highest) then
			upgrades[equipmentSlot] = highest;
		end
	end
	return upgrades;
end

function Class_ItemUpgradeCheckingService:GetWeaponType(itemID)
	local loc = select(9, C_Item.GetItemInfo(itemID));

	if ((loc == "INVTYPE_RANGED") or (loc == "INVTYPE_RANGEDRIGHT")) then
		return self.WeaponType.Ranged;
	elseif (loc == "INVTYPE_2HWEAPON") then
		return self.WeaponType.TwoHand;
	else
		return self.WeaponType.Other;
	end
end

local function IsDagger(itemInfo)
	local subClassType = ITEMSUBCLASSTYPES["DAGGER"];
	return ((itemInfo[12] == subClassType.classID) and (itemInfo[13] == subClassType.subClassID));
end

-- Walk all the character item slots and create a list of items in the player's inventory
-- that can be equipped into those slots and is a higher ilvl
-- @return a table of all slots that have higher ilvl items in the player's pags. Each table is a list of STRUCT_ItemContainer
function Class_ItemUpgradeCheckingService:GetPotentialItemUpgrades()
	local potentialUpgrades = {};

	local playerClass = TutorialHelper:GetClass();

	for i = 0, INVSLOT_LAST_EQUIPPED do
		local existingItemIlvl = 0;
		local existingItemWeaponType;

		local existingItemLink = GetInventoryItemLink("player", i);
		local existingItemQuality;
		if (existingItemLink ~= nil) then
			existingItemIlvl = C_Item.GetDetailedItemLevelInfo(existingItemLink) or 0;
			existingItemQuality = select(3, C_Item.GetItemInfo(existingItemLink));

			if (i == INVSLOT_MAINHAND) then
				local existingItemID = GetInventoryItemID("player", i);
				existingItemWeaponType = self:GetWeaponType(existingItemID);
			end
		end

		local availableItems = {};
		GetInventoryItemsForSlot(i, availableItems);

		for packedLocation, itemLink in pairs(availableItems) do
			local itemInfo = {C_Item.GetItemInfo(itemLink)};
			local ilvl = C_Item.GetDetailedItemLevelInfo(itemLink) or 0;

			if (ilvl ~= nil) and (existingItemQuality ~= Enum.ItemQuality.Heirloom) then
				if (ilvl > existingItemIlvl) then
					local match = true;

					-- if it's a main-hand, make sure it matches the current type, if there is one
					if (i == INVSLOT_MAINHAND) then
						local item = Item:CreateFromItemLink(itemLink);
						local itemID = item:GetItemID();
						local weaponType = self:GetWeaponType(itemID);
						match = (not existingItemWeaponType) or (existingItemWeaponType == weaponType);

						-- rogue's should only be recommended daggers
						if ( playerClass == "ROGUE" and not IsDagger(itemInfo)) then
							match = false;
						end
					end

					-- if it's an off-hand, make sure the player doesn't have a 2h or ranged weapon
					if (i == INVSLOT_OFFHAND) then
						local mainHandID = GetInventoryItemID("player", INVSLOT_MAINHAND);
						if (mainHandID) then
							local mainHandType = self:GetWeaponType(mainHandID);
							if ((mainHandType == self.WeaponType.TwoHand) or (mainHandType == self.WeaponType.Ranged)) then
								match = false;
							end
						end

						-- rogue's should only be recommended daggers
						if ( playerClass == "ROGUE" and not IsDagger(itemInfo)) then
							match = false;
						end
					end

					if (match) then
						local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(packedLocation);

						if ((player == true) and (bags == true)) then
							if (potentialUpgrades[i] == nil) then
								potentialUpgrades[i] = {};
							end

							table.insert(potentialUpgrades[i], self:STRUCT_ItemContainer(itemLink, i, bag, slot));
						end
					end
				end
			end
		end
	end
	return potentialUpgrades;
end

function Class_ItemUpgradeCheckingService:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_ItemUpgradeCheckingService:OnComplete()
end
