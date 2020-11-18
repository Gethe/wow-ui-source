TransmogUtil = {};

function TransmogUtil.GetInfoForEquippedSlot(transmogLocation)
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, appliedCategoryID, pendingSourceID, pendingVisualID, pendingCategoryID, hasPendingUndo, _, itemSubclass = C_Transmog.GetSlotVisualInfo(transmogLocation);
	if ( appliedSourceID == NO_TRANSMOG_SOURCE_ID ) then
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
		local appearanceSourceID = C_TransmogCollection.GetIllusionFallbackWeaponSource();
		local _, appearanceVisualID = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID);
		return appearanceSourceID, appearanceVisualID;
	end
end

-- Returns the weaponSlot and appearanceSourceID for the weapon that an illusion should be applied to (for dressup frames, etc)
-- If the player has a mainhand equipped that can have an illusion applied to it, uses that
-- If not, and the player has an offhand equipped that can have an illusion applied to it, uses that
-- Otherwise uses the fallback weapon in the mainhand
function TransmogUtil.GetBestWeaponInfoForIllusionDressup()
	local mainHandTransmogLocation = TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.None);
	local mainHandVisualID = C_Transmog.GetSlotVisualInfo(mainHandTransmogLocation);
	local offHandTransmogLocation = TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.None);
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
		return TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.None);
	elseif transmogLocation:IsOffHand() then
		return TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.None);
	end
end

function TransmogUtil.GetTransmogLocationLookupKey(slotID, transmogType, modification)
	return slotID * 100 + transmogType * 10 + modification;
end

function TransmogUtil.GetSetIcon(setID)
	local bestItemID;
	local bestSortOrder = 100;
	local sources = C_TransmogSets.GetSetSources(setID);
	if sources then
		for sourceID, collected in pairs(sources) do
			local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
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

TransmogLocationMixin = {};

function TransmogLocationMixin:Set(slotID, transmogType, modification)
	self.slotID = slotID;
	self.type = transmogType;
	self.modification = modification;
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

function TransmogLocationMixin:IsRightShoulderModification()
	return self.modification == Enum.TransmogModification.RightShoulder;
end

TRANSMOG_SLOTS = { };

-- this will indirectly populate slotIDToName
do
	function Add(slotName, transmogType, modification, armorCategoryID)
		local location = TransmogUtil.CreateTransmogLocation(slotName, transmogType, modification);
		local lookupKey = location:GetLookupKey();
		TRANSMOG_SLOTS[lookupKey] = { location = location, armorCategoryID = armorCategoryID };
	end

	Add("HEADSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.None, Enum.TransmogCollectionType.Head + 1);
	Add("SHOULDERSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.None, Enum.TransmogCollectionType.Shoulder + 1);
	Add("BACKSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.None, Enum.TransmogCollectionType.Back + 1);
	Add("CHESTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.None, Enum.TransmogCollectionType.Chest + 1);
	Add("TABARDSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.None, Enum.TransmogCollectionType.Tabard + 1);
	Add("SHIRTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.None, Enum.TransmogCollectionType.Shirt + 1);
	Add("WRISTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.None, Enum.TransmogCollectionType.Wrist + 1);
	Add("HANDSSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.None, Enum.TransmogCollectionType.Hands + 1);
	Add("WAISTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.None, Enum.TransmogCollectionType.Waist + 1);
	Add("LEGSSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.None, Enum.TransmogCollectionType.Legs + 1);
	Add("FEETSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.None, Enum.TransmogCollectionType.Feet + 1);
	Add("MAINHANDSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.None, nil);
	Add("SECONDARYHANDSLOT",	Enum.TransmogType.Appearance,	Enum.TransmogModification.None, nil);
	Add("MAINHANDSLOT",			Enum.TransmogType.Illusion,		Enum.TransmogModification.None, nil);
	Add("SECONDARYHANDSLOT",	Enum.TransmogType.Illusion,		Enum.TransmogModification.None, nil);
	-- independent right shoulder
	Add("SHOULDERSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.RightShoulder, Enum.TransmogCollectionType.Shoulder + 1);
end