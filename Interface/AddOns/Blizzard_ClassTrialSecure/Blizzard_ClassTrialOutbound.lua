-- Outbound loads under the global environment but needs to put the outbound table into the secure environment
local secureEnv = GetCurrentEnvironment();
SwapToGlobalEnvironment();
local ClassTrialOutbound = {};
secureEnv.ClassTrialOutbound = ClassTrialOutbound;
secureEnv = nil;	--This file shouldn't be calling back into secure code.

function ClassTrialOutbound.ShowUpgradeConfirmation(guid, boostType)
	local data = { guid = guid, boostType = boostType };
	securecall("StaticPopup_Show", "CONFIRM_UNLOCK_TRIAL_CHARACTER", nil, nil, data);
end

function ClassTrialOutbound.ShowUpgradeLogoutConfirmation(boostType)
	securecall("StaticPopup_Show", "CLASS_TRIAL_CHOOSE_BOOST_LOGOUT_PROMPT", nil, nil, boostType);
end

function ClassTrialOutbound.ShowStoreServices(guid, boostType)
	securecall("ClassTrial_ShowStoreServices", guid, boostType);
end

function ClassTrialOutbound.SetClassTrialHasAvailableBoost(hasBoost)
	securecall("ClassTrial_SetHasAvailableBoost", hasBoost);
end