-- These are functions that were deprecated in 11.2.0 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

-- NOTE FOR ADDON DEVELOPERS:
-- Starting this patch, region:ClearAllPoints() will immediately invalidate the rect.
-- This means you cannot rely on calling GetWidth, GetHeight, GetTop/Left/Bottom/Right, or GetRect after ClearAllPoints.
-- Any measurement calculations relying on the previous rect should occur before calling ClearAllPoints.

function IsSpellOverlayed(spellID)
	return C_SpellActivationOverlay.IsSpellOverlayed(spellID);
end

-- The following functions will be updated in 12.0.0 to reflect the removal of the Reagent Bank:
-- C_Item.GetItemCount(itemID, includeBank, includeUses, includeReagentBank, includeAccountBank);
-- C_Container.UseContainerItem(bag, slot, unitToken, Enum.BankType.Account, isReagentBankOpen);

function EquipmentManager_UnpackLocation(packedLocation)
	local locationData = EquipmentManager_GetLocationData(packedLocation);
	-- Void Storage is being deprecated in 11.2.0
	local voidStorage, tab, voidSlot = false, nil, nil;
	return locationData.isPlayer or false, locationData.isBank or false, locationData.isBags or false, voidStorage, locationData.slot, locationData.bag, tab, voidSlot;
end