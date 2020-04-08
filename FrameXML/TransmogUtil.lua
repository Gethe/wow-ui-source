TransmogUtil = {};

function TransmogUtil.GetInfoForEquippedSlot(slot, transmogType)
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo, _, itemSubclass = C_Transmog.GetSlotVisualInfo(GetInventorySlotInfo(slot), transmogType);
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

function TransmogUtil.GetWeaponInfoForEnchant(slot)
	local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = TransmogUtil.GetInfoForEquippedSlot(slot, LE_TRANSMOG_TYPE_APPEARANCE);
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
	local mainHandVisualID = C_Transmog.GetSlotVisualInfo(GetInventorySlotInfo("MAINHANDSLOT"), LE_TRANSMOG_TYPE_APPEARANCE);
	local offHandVisualID = C_Transmog.GetSlotVisualInfo(GetInventorySlotInfo("SECONDARYHANDSLOT"), LE_TRANSMOG_TYPE_APPEARANCE);

	local weaponSlot = ((mainHandVisualID == NO_TRANSMOG_VISUAL_ID) and (offHandVisualID ~= NO_TRANSMOG_VISUAL_ID)) and "SECONDARYHANDSLOT" or "MAINHANDSLOT";
	local weaponSourceID = TransmogUtil.GetWeaponInfoForEnchant(weaponSlot, LE_TRANSMOG_TYPE_APPEARANCE);

	return weaponSlot, weaponSourceID;
end
