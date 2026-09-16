
local function ClassTrialDoCharacterUpgrade(guid, boostType, confirmed)
	local upgradeDistributions = C_SharedCharacterServices.GetUpgradeDistributions();
	if upgradeDistributions[boostType] and upgradeDistributions[boostType].amount >= 1 then
		if confirmed then
			if boostType == C_CharacterServices.GetActiveClassTrialBoostType() then
				C_CharacterServices.AssignUpgradeDistribution(guid, 0, 0, 0, boostType, 0);
			else
				ClassTrialOutbound.ShowUpgradeLogoutConfirmation(boostType);
			end
		else
			if boostType == C_CharacterServices.GetActiveClassTrialBoostType() then
				ClassTrialOutbound.ShowUpgradeConfirmation(guid, boostType);
			else
				ClassTrialOutbound.ShowUpgradeLogoutConfirmation(boostType);
			end
		end
	else
		ClassTrialOutbound.ShowStoreServices(guid, boostType);
	end
end

ClassTrialSecureFrameMixin = {};

function ClassTrialSecureFrameMixin:OnLoad()
	self:RegisterEvent("PRODUCT_DISTRIBUTIONS_UPDATED");
end

function ClassTrialSecureFrameMixin:OnEvent(event, ...)
	if event == "PRODUCT_DISTRIBUTIONS_UPDATED" then
		self:ClassTrialOutboundUpdateBoost();
	end
end

function ClassTrialSecureFrameMixin:OnAttributeChanged(name, value)
	local data = value;

	if (name == "upgradecharacter") then
		ClassTrialDoCharacterUpgrade(data.guid, data.boostType, false);
	elseif name == "upgradecharacter-confirm" then
		ClassTrialDoCharacterUpgrade(data.guid, data.boostType, true);
	elseif name == "updateboostpurchasebutton" then
		self:ClassTrialOutboundUpdateBoost();
	end
end

function ClassTrialSecureFrameMixin:ClassTrialOutboundUpdateBoost()
	ClassTrialOutbound.SetClassTrialHasAvailableBoost(C_CharacterServices.HasRequiredBoostForClassTrial());
end
