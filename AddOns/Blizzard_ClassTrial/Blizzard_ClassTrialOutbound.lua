--If any of these functions call out of this file, they should be using securecall. Be very wary of using return values.
local _, tbl = ...;
local Outbound = {};
tbl.Outbound = Outbound;
tbl = nil;	--This file shouldn't be calling back into secure code.

function Outbound.ShowUpgradeConfirmation()
	securecall("StaticPopup_Show", "CONFIRM_UNLOCK_TRIAL_CHARACTER");
end

function Outbound.ShowStoreServices()
	securecall("ClassTrial_ShowStoreServices");
end

function Outbound.SetClassTrialHasAvailableBoost(hasBoost)
	securecall("ClassTrial_SetHasAvailableBoost", hasBoost);
end