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

-------------------------------------------------------------------------------------------------------------------------
-- TextStatusBar has been updated to a mixin and these global functions should be updated to call the new mixin functions
function TextStatusBar_Initialize(self)
   self:InitializeTextStatusBar();
end

function SetTextStatusBarText(bar, text)
   bar:SetBarText(text);
end

function TextStatusBar_OnEvent(self, event, ...)
   self:TextStatusBarOnEvent(event, ...);
end

function TextStatusBar_UpdateTextString(textStatusBar)
   textStatusBar:UpdateTextString();
end

function TextStatusBar_UpdateTextStringWithValues(statusFrame, textString, value, valueMin, valueMax)
   statusFrame:UpdateTextStringWithValues(textString, value, valueMin, valueMax);
end

function TextStatusBar_OnValueChanged(self)
   self:OnStatusBarValueChanged();
end

function TextStatusBar_OnMinMaxChanged(self, min, max)
   self:OnStatusBarMinMaxChanged(min, max);
end

function SetTextStatusBarTextPrefix(bar, prefix)
   bar:SetBarTextPrefix(prefix);
end

function SetTextStatusBarTextZeroText(bar, zeroText)
   bar:SetBarTextZeroText(zeroText);
end

function ShowTextStatusBarText(bar)
   bar:ShowStatusBarText();
end

function HideTextStatusBarText(bar)
   bar:HideStatusBarText();
end
-------------------------------------------------------------------------------------------------------------------------

do
	-- Return value is now a result enum instead of a bool
	local newRegisterAddonMessagePrefixFunc = C_ChatInfo.RegisterAddonMessagePrefix;
	function C_ChatInfo.RegisterAddonMessagePrefix(...)
		local result = newRegisterAddonMessagePrefixFunc(...);
		return (result == Enum.SendAddonMessageResult.Success), result;
	end

	-- Return value is now a result enum instead of a bool
	local newSendAddonMessageFunc = C_ChatInfo.SendAddonMessage;
	function C_ChatInfo.SendAddonMessage(...)
		local result = newSendAddonMessageFunc(...);
		return (result == Enum.SendAddonMessageResult.Success), result;
	end

	-- Return value is now a result enum instead of a bool
	local newSendAddonMessageLoggedFunc = C_ChatInfo.SendAddonMessageLogged;
	function C_ChatInfo.SendAddonMessageLogged(...)
		local result = newSendAddonMessageLoggedFunc(...);
		return (result == Enum.RegisterAddonMessagePrefixResult.Success), result;
	end
end