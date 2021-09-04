---------------
--NOTE - Please do not change this section without talking to Jacob
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

setfenv(1, tbl);
----------------

Import("C_CharacterServices");
Import("C_SharedCharacterServices");
Import("pairs");
Import("Enum");

local function ClassTrialDoCharacterUpgrade(guid, boostType, confirmed)
	local upgradeDistributions = C_SharedCharacterServices.GetUpgradeDistributions();
	if upgradeDistributions[boostType] and upgradeDistributions[boostType].amount >= 1 then
		if confirmed then
			if boostType == C_CharacterServices.GetActiveClassTrialBoostType() then
				C_CharacterServices.AssignUpgradeDistribution(guid, 0, 0, 0, boostType, 0);
			else
				Outbound.ShowUpgradeLogoutConfirmation(boostType);
			end
		else
			if boostType == C_CharacterServices.GetActiveClassTrialBoostType() then
				Outbound.ShowUpgradeConfirmation(guid, boostType);
			else
				Outbound.ShowUpgradeLogoutConfirmation(boostType);
			end
		end
	else
		Outbound.ShowStoreServices(guid, boostType);
	end
end

ClassTrialSecureFrameMixin = {};

function ClassTrialSecureFrameMixin:OnLoad()
	self:RegisterEvent("PRODUCT_DISTRIBUTIONS_UPDATED");
end

function ClassTrialSecureFrameMixin:OnEvent(event, ...)
	if event == "PRODUCT_DISTRIBUTIONS_UPDATED" then
		self:OutboundUpdateBoost();
	end
end

function ClassTrialSecureFrameMixin:OnAttributeChanged(name, value)
	local data = value;

	if (name == "upgradecharacter") then
		ClassTrialDoCharacterUpgrade(data.guid, data.boostType, false);
	elseif name == "upgradecharacter-confirm" then
		ClassTrialDoCharacterUpgrade(data.guid, data.boostType, true);
	elseif name == "updateboostpurchasebutton" then
		self:OutboundUpdateBoost();
	end
end

function ClassTrialSecureFrameMixin:OutboundUpdateBoost()
	Outbound.SetClassTrialHasAvailableBoost(C_CharacterServices.HasRequiredBoostForClassTrial());
end
