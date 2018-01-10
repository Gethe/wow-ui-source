--If any of these functions call out of this file, they should be using securecall. Be very wary of using return values.
local _, tbl = ...;
local Outbound = {};
tbl.Outbound = Outbound;
tbl = nil;	--This file shouldn't be calling back into secure code.

function Outbound.ShowUpgradeConfirmation(guid, boostType)
	local data = { guid = guid, boostType = boostType };
	securecall("StaticPopup_Show", "CONFIRM_UNLOCK_TRIAL_CHARACTER", nil, nil, data);
end

function Outbound.ShowUpgradeLogoutConfirmation(boostType)
	securecall("StaticPopup_Show", "CLASS_TRIAL_CHOOSE_BOOST_LOGOUT_PROMPT", nil, nil, boostType);
end

function Outbound.ShowStoreServices(guid, boostType)
	securecall("ClassTrial_ShowStoreServices", guid, boostType);
end

function Outbound.SetClassTrialHasAvailableBoost(hasBoost)
	securecall("ClassTrial_SetHasAvailableBoost", hasBoost);
end