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
Import("pairs");
Import("Enum");

local function ClassTrialDoCharacterUpgrade(guid, confirmed)
	local hasBoost, requiredBoostType = C_CharacterServices.HasRequiredBoostForClassTrial();

	if hasBoost then
		if confirmed then
			C_CharacterServices.AssignUpgradeDistribution(guid, 0, 0, 0, requiredBoostType);
		else
			Outbound.ShowUpgradeConfirmation();
		end
	else
		Outbound.ShowStoreServices();
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
	local guid = value;

	if (name == "upgradecharacter") then
		ClassTrialDoCharacterUpgrade(guid, false);
	elseif name == "upgradecharacter-confirm" then
		ClassTrialDoCharacterUpgrade(guid, true);
	elseif name == "updateboostpurchasebutton" then
		self:OutboundUpdateBoost();
	end
end

function ClassTrialSecureFrameMixin:OutboundUpdateBoost()
	Outbound.SetClassTrialHasAvailableBoost(C_CharacterServices.HasRequiredBoostForClassTrial());
end
