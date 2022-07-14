TransmogSlotOrder = {
	INVSLOT_HEAD,
	INVSLOT_SHOULDER,
	INVSLOT_BACK,
	INVSLOT_CHEST,
	INVSLOT_BODY,
	INVSLOT_TABARD,
	INVSLOT_WRIST,
	INVSLOT_HAND,
	INVSLOT_WAIST,
	INVSLOT_LEGS,
	INVSLOT_FEET,
	INVSLOT_MAINHAND,
	INVSLOT_OFFHAND,
};

TransmogUtil = {};

function TransmogUtil.GetInfoForEquippedSlot(transmogLocation)
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo, _, itemSubclass = C_Transmog.GetSlotVisualInfo(transmogLocation);
	if ( appliedSourceID == Constants.Transmog.NoTransmogID ) then
		appliedSourceID = baseSourceID;
		appliedVisualID = baseVisualID;
	end
	local selectedSourceID, selectedVisualID;
	if pendingSourceID ~= REMOVE_TRANSMOG_ID then
		selectedSourceID = pendingSourceID;
		selectedVisualID = pendingVisualID;
	elseif hasPendingUndo then
		selectedSourceID = baseSourceID;
		selectedVisualID = baseVisualID;
	else
		selectedSourceID = appliedSourceID;
		selectedVisualID = appliedVisualID;
	end
	return appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID, itemSubclass;
end

function TransmogUtil.CanEnchantSource(sourceID)
	local _, _, canEnchant = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
	return canEnchant;
end

function TransmogUtil.GetWeaponInfoForEnchant(transmogLocation)
	local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = TransmogUtil.GetInfoForEquippedSlot(transmogLocation);
	if TransmogUtil.CanEnchantSource(selectedSourceID) then
		return selectedSourceID, selectedVisualID;
	else
		local appearanceSourceID = C_TransmogCollection.GetFallbackWeaponAppearance();
		local _, appearanceVisualID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		return appearanceSourceID, appearanceVisualID;
	end
end

-- Returns the weaponSlot and appearanceSourceID for the weapon that an illusion should be applied to (for dressup frames, etc)
-- If the player has a mainhand equipped that can have an illusion applied to it, uses that
-- If not, and the player has an offhand equipped that can have an illusion applied to it, uses that
-- Otherwise uses the fallback weapon in the mainhand
function TransmogUtil.GetBestWeaponInfoForIllusionDressup()
	local mainHandTransmogLocation = TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
	local mainHandVisualID = C_Transmog.GetSlotVisualInfo(mainHandTransmogLocation);
	local offHandTransmogLocation = TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
	local offHandVisualID = C_Transmog.GetSlotVisualInfo(offHandTransmogLocation);

	local transmogLocation = ((mainHandVisualID == NO_TRANSMOG_VISUAL_ID) and (offHandVisualID ~= NO_TRANSMOG_VISUAL_ID)) and offHandTransmogLocation or mainHandTransmogLocation;
	local weaponSourceID = TransmogUtil.GetWeaponInfoForEnchant(transmogLocation);

	return transmogLocation:GetSlotName(), weaponSourceID;
end

-- populated when TRANSMOG_SLOTS transmoglocations are created
local slotIDToName = { };

function TransmogUtil.GetSlotID(slotName)
	local slotID = GetInventorySlotInfo(slotName);
	slotIDToName[slotID] = slotName;
	return slotID;
end

function TransmogUtil.GetSlotName(slotID)
	return slotIDToName[slotID];
end

local function GetSlotID(slotDescriptor)
	if type(slotDescriptor) == "string" then
		return TransmogUtil.GetSlotID(slotDescriptor);
	else
		return slotDescriptor;
	end
end

function TransmogUtil.CreateTransmogLocation(slotDescriptor, transmogType, modification)
	local slotID = GetSlotID(slotDescriptor);
	local transmogLocation = CreateFromMixins(TransmogLocationMixin);
	transmogLocation:Set(slotID, transmogType, modification);
	return transmogLocation;
end

function TransmogUtil.GetTransmogLocation(slotDescriptor, transmogType, modification)
	local slotID = GetSlotID(slotDescriptor);
	local lookupKey = TransmogUtil.GetTransmogLocationLookupKey(slotID, transmogType, modification);
	local transmogSlot = TRANSMOG_SLOTS[lookupKey];
	return transmogSlot and transmogSlot.location;
end

function TransmogUtil.GetCorrespondingHandTransmogLocation(transmogLocation)
	if transmogLocation:IsMainHand() then
		return TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
	elseif transmogLocation:IsOffHand() then
		return TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
	end
end

function TransmogUtil.GetTransmogLocationLookupKey(slotID, transmogType, modification)
	return slotID * 100 + transmogType * 10 + modification;
end

function TransmogUtil.GetSetIcon(setID)
	local bestItemID;
	local bestSortOrder = 100;
	local setAppearances = C_TransmogSets.GetSetPrimaryAppearances(setID);
	if setAppearances then
		for i, appearanceInfo in pairs(setAppearances) do
			local sourceInfo = C_TransmogCollection.GetSourceInfo(appearanceInfo.appearanceID);
			if sourceInfo then
				local sortOrder = EJ_GetInvTypeSortOrder(sourceInfo.invType);
				if sortOrder < bestSortOrder then
					bestSortOrder = sortOrder;
					bestItemID = sourceInfo.itemID;
				end
			end
		end
	end
	if bestItemID then
		return select(5, GetItemInfoInstant(bestItemID));
	else
		return QUESTION_MARK_ICON;
	end
end

function TransmogUtil.CreateTransmogPendingInfo(pendingType, transmogID, category, secondaryTransmogID)
	return CreateAndInitFromMixin(TransmogPendingInfoMixin, pendingType, transmogID, category, secondaryTransmogID);
end

function TransmogUtil.IsSecondaryTransmoggedForItemLocation(itemLocation)
	if itemLocation and C_Item.DoesItemExist(itemLocation) then
		local itemTransmogInfo = C_Item.GetAppliedItemTransmogInfo(itemLocation);
		return itemTransmogInfo and itemTransmogInfo.secondaryAppearanceID ~= Constants.Transmog.NoTransmogID;
	end
	return false;
end

function TransmogUtil.GetItemLocationFromTransmogLocation(transmogLocation)
	if not transmogLocation then
		return nil;
	end
	return ItemLocation:CreateFromEquipmentSlot(transmogLocation:GetSlotID());
end

function TransmogUtil.GetRelevantTransmogID(itemTransmogInfo, transmogLocation)
	if not itemTransmogInfo then
		return Constants.Transmog.NoTransmogID;
	end
	if transmogLocation.type == Enum.TransmogType.Illusion then
		return itemTransmogInfo.illusionID;
	end
	if transmogLocation.modification == Enum.TransmogModification.Secondary then
		return itemTransmogInfo.secondaryAppearanceID;
	end
	return itemTransmogInfo.appearanceID;
end

function TransmogUtil.IsCategoryLegionArtifact(categoryID)
	return categoryID == Enum.TransmogCollectionType.Paired;
end

function TransmogUtil.IsCategoryRangedWeapon(categoryID)
	return (categoryID == Enum.TransmogCollectionType.Bow) or (categoryID == Enum.TransmogCollectionType.Gun) or (categoryID == Enum.TransmogCollectionType.Crossbow);
end

function TransmogUtil.IsValidTransmogSlotID(slotID)
	local lookupKey = TransmogUtil.GetTransmogLocationLookupKey(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
	return not not TRANSMOG_SLOTS[lookupKey];
end

function TransmogUtil.OpenCollectionToItem(sourceID)
	if TransmogUtil.OpenCollectionUI() then
		WardrobeCollectionFrame:GoToItem(sourceID);
	end
end

function TransmogUtil.OpenCollectionToSet(setID)
	if TransmogUtil.OpenCollectionUI() then
		WardrobeCollectionFrame:GoToSet(setID);
	end
end

function TransmogUtil.OpenCollectionUI()
	if not CollectionsJournal then
		CollectionsJournal_LoadUI();
	end
	if CollectionsJournal then
		if not CollectionsJournal:IsVisible() or not WardrobeCollectionFrame:IsVisible() then
			ToggleCollectionsJournal(COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES);
		end
		return true;
	end
	return false;
end

function TransmogUtil.GetEmptyItemTransmogInfoList()
	local list = { };
	for i = 1, INVSLOT_LAST_EQUIPPED do
		table.insert(list, ItemUtil.CreateItemTransmogInfo(0, 0, 0));
	end
	return list;
end

local NUM_OUTFIT_SLASH_COMMAND_VALUES = 17;

-- Outfit slash command sample:
-- /outfit v1 7019,7017,0,0,7022,0,0,7015,7020,7016,7018,7021,70216,0,0,0,0
-- "v1" is the version so future formats won't break older slash commands
-- The comma-separated values are as follows:
-- 		Head		- appearanceID
--		Shoulder	- appearanceID
--		Shoulder	- secondaryAppearanceID (0 if shoulders aren't split)
-- 		Back		- appearanceID
--		Chest		- appearanceID
--		Body		- appearanceID
--		Tabard		- appearanceID
--		Wrist		- appearanceID
--		Hand		- appearanceID
--		Waist		- appearanceID
--		Legs		- appearanceID
--		Feet		- appearanceID
--		MainHand	- appearanceID
--		MainHand	- secondaryAppearanceID (0 if the weapon is from Legion Artifacts category, -1 otherwise)
--		MainHand	- illusionID
--		OffHand		- appearanceID
--		OffHand		- illusionID

function TransmogUtil.CreateOutfitSlashCommand(itemTransmogInfoList)
	local slashCommand = "/outfit v1 ";
	local isPairedWeapons = false;
	for index, slotID in ipairs(TransmogSlotOrder) do
		local transmogInfo = itemTransmogInfoList[slotID];
		if transmogInfo then
			local appearanceID = transmogInfo.appearanceID;
			if slotID == INVSLOT_OFFHAND and isPairedWeapons then
				appearanceID = -1;
			end
			if index == 1 then
				slashCommand = slashCommand..appearanceID;
			else
				slashCommand = slashCommand..","..appearanceID;
			end
			-- secondaries
			if slotID == INVSLOT_SHOULDER or slotID == INVSLOT_MAINHAND then
				slashCommand = slashCommand..","..transmogInfo.secondaryAppearanceID;
			end
			-- illusions
			if slotID == INVSLOT_MAINHAND or slotID == INVSLOT_OFFHAND then
				slashCommand = slashCommand..","..transmogInfo.illusionID;
			end
		end
	end
	return slashCommand;
end

function TransmogUtil.ParseOutfitSlashCommand(msg)
	-- check version #
	if string.sub(msg, 1, 3) == "v1 " then
		local readlist = C_Transmog.ExtractTransmogIDList(string.sub(msg, 4));
		if #readlist ~= NUM_OUTFIT_SLASH_COMMAND_VALUES then
			DEFAULT_CHAT_FRAME:AddMessage(TRANSMOG_OUTFIT_LINK_INVALID, RED_FONT_COLOR:GetRGB());
			return;
		end

		-- accessor for next value
		local readIndex = 0;
		local function GetNextReadValue()
			readIndex = readIndex + 1; 
			return readlist[readIndex];
		end

		-- set the values
		local itemTransmogInfoList = TransmogUtil.GetEmptyItemTransmogInfoList();
		for _, slotID in ipairs(TransmogSlotOrder) do
			local info = itemTransmogInfoList[slotID];
			info.appearanceID = GetNextReadValue();
			-- secondaries
			if slotID == INVSLOT_SHOULDER or slotID == INVSLOT_MAINHAND then
				info.secondaryAppearanceID = GetNextReadValue();
				-- category check on shoulder secondary
				if slotID == INVSLOT_SHOULDER and info.secondaryAppearanceID ~= Constants.Transmog.NoTransmogID then
					local categoryID = C_TransmogCollection.GetAppearanceSourceInfo(info.secondaryAppearanceID);
					if categoryID ~= Enum.TransmogCollectionType.Shoulder then
						info.secondaryAppearanceID = Constants.Transmog.NoTransmogID;
					end
				end
			end
			-- illusions
			if slotID == INVSLOT_MAINHAND or slotID == INVSLOT_OFFHAND then
				info.illusionID = math.max(GetNextReadValue(), Constants.Transmog.NoTransmogID);
			end
		end
		return itemTransmogInfoList;
	end
	DEFAULT_CHAT_FRAME:AddMessage(TRANSMOG_OUTFIT_LINK_INVALID, RED_FONT_COLOR:GetRGB());
	return nil;
end

TransmogPendingInfoMixin = {};

function TransmogPendingInfoMixin:Init(pendingType, transmogID, category)
	self.type = pendingType;
	if pendingType ~= Enum.TransmogPendingType.Apply then
		transmogID = Constants.Transmog.NoTransmogID;
	end
	self.transmogID = transmogID;
	self.category = category;
end

TransmogLocationMixin = {};

function TransmogLocationMixin:Set(slotID, transmogType, modification)
	self.slotID = slotID;
	self.type = transmogType;
	self.modification = modification or Enum.TransmogModification.Main;
end

function TransmogLocationMixin:IsAppearance()
	return self.type == Enum.TransmogType.Appearance;
end

function TransmogLocationMixin:IsIllusion()
	return self.type == Enum.TransmogType.Illusion;
end

function TransmogLocationMixin:GetSlotID()
	return self.slotID;
end

function TransmogLocationMixin:GetSlotName()
	return TransmogUtil.GetSlotName(self.slotID);
end

function TransmogLocationMixin:IsEitherHand()
	return self:IsMainHand() or self:IsOffHand();
end

function TransmogLocationMixin:IsMainHand()
	local slotName = self:GetSlotName();
	return slotName == "MAINHANDSLOT";
end

function TransmogLocationMixin:IsOffHand()
	local slotName = self:GetSlotName();
	return slotName == "SECONDARYHANDSLOT";
end

function TransmogLocationMixin:IsEqual(transmogLocation)
	if not transmogLocation then
		return false;
	end
	return self.slotID == transmogLocation.slotID and self.type == transmogLocation.type and self.modification == transmogLocation.modification;
end

function TransmogLocationMixin:GetArmorCategoryID()
	local transmogSlot = TRANSMOG_SLOTS[self:GetLookupKey()];
	return transmogSlot and transmogSlot.armorCategoryID;
end

function TransmogLocationMixin:GetLookupKey()
	return TransmogUtil.GetTransmogLocationLookupKey(self.slotID, self.type, self.modification);
end

function TransmogLocationMixin:IsSecondary()
	return self.modification == Enum.TransmogModification.Secondary;
end

TRANSMOG_SLOTS = { };

-- this will indirectly populate slotIDToName
do
	function Add(slotName, transmogType, modification, armorCategoryID)
		local location = TransmogUtil.CreateTransmogLocation(slotName, transmogType, modification);
		local lookupKey = location:GetLookupKey();
		TRANSMOG_SLOTS[lookupKey] = { location = location, armorCategoryID = armorCategoryID };
	end

	Add("HEADSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Head);
	Add("SHOULDERSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Shoulder);
	Add("BACKSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Back);
	Add("CHESTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Chest);
	Add("TABARDSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Tabard);
	Add("SHIRTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Shirt);
	Add("WRISTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Wrist);
	Add("HANDSSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Hands);
	Add("WAISTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Waist);
	Add("LEGSSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Legs);
	Add("FEETSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Feet);
	Add("MAINHANDSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, nil);
	Add("SECONDARYHANDSLOT",	Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, nil);
	Add("MAINHANDSLOT",			Enum.TransmogType.Illusion,		Enum.TransmogModification.Main, nil);
	Add("SECONDARYHANDSLOT",	Enum.TransmogType.Illusion,		Enum.TransmogModification.Main, nil);
	-- secondary shoulder
	Add("SHOULDERSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Secondary, Enum.TransmogCollectionType.Shoulder);
end