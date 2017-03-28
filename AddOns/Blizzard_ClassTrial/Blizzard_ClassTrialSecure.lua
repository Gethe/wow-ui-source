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

Import("C_SharedCharacterServices");
Import("pairs");
Import("Enum");

local function HasRequiredUpgradeProduct()
	local upgrades = C_SharedCharacterServices.GetUpgradeDistributions();
	local hasBoost = false;
	local useFreeBoost = false;
	local requiredProduct = Enum.BattlepayBoostProduct.Level100Boost;

	for id, data in pairs(upgrades) do
		if id == requiredProduct then
			hasBoost = hasBoost or (data.numPaid) > 0 or (data.numFree > 0);
			useFreeBoost = useFreeBoost or (data.numFree > 0);
		end
	end

	return requiredProduct, hasBoost, useFreeBoost;
end

local function ClassTrialDoCharacterUpgrade(guid, confirmed)
	local productID, hasBoost, useFreeBoost = HasRequiredUpgradeProduct();

	if hasBoost then
		if confirmed then
			C_SharedCharacterServices.AssignUpgradeDistribution(guid, 0, 0, 0, useFreeBoost, productID);
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
	local _, hasBoost = HasRequiredUpgradeProduct();
	Outbound.SetClassTrialHasAvailableBoost(hasBoost);
end
