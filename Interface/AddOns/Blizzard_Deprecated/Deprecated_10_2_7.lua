-- These are functions that were deprecated in 10.2.7 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
   -- The following functions have been moved into the C_StableInfo namespace:
   ClosePetStables = C_StableInfo.ClosePetStables;
   GetStablePetInfo = function(...)
      local t = C_StableInfo.GetStablePetInfo(...);
      if t then
         return unpack({t.icon, t.name, t.level, t.familyName, t.specialization});
      end
   end
   PickupStablePet = C_StableInfo.PickupStablePet;
   GetStablePetFoodTypes = function(...)
      local t = C_StableInfo.GetStablePetFoodTypes(...);
      if t then
         return unpack(t);
      end
   end
   IsAtStableMaster = C_StableInfo.IsAtStableMaster;
   SetPetSlot = C_StableInfo.SetPetSlot;
   
   -- The following functions have been moved into the C_PetInfo namespace:
   PetAbandon = C_PetInfo.PetAbandon;
   PetRename = function(...)
      local name, declensions = ...;
      C_PetInfo.PetRename(name, nil, declensions);
   end 
   PetCanBeRenamed = function()  -- There are no more restrictions on when/how many times a pet can be renamed
      return true;
   end;
end