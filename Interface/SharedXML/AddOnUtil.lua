AddOnUtil = {};

-- HACK: Support for branches with different APIs in the C_AddOns table.
local getAddOnDependencies = GetAddOnDependencies or C_AddOns.GetAddOnDependencies;
local isAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded;
local enableAddOn = EnableAddOn or C_AddOns.EnableAddOn;
local disableAddOn = DisableAddOn or C_AddOns.DisableAddOn;
local loadAddOn = LoadAddOn or C_AddOns.LoadAddOn;
local getAddOnEnableState = GetAddOnEnableState or C_AddOns.GetAddOnEnableState;

local function GetAddOnDependenciesRecursive(addonName, dependencyTable)
	dependencyTable = dependencyTable or {};
	local dependencies = { getAddOnDependencies(addonName) };
	for _, depAddonName in pairs(dependencies) do
		if not dependencyTable[depAddonName] then
			dependencyTable[depAddonName] = true;
			GetAddOnDependenciesRecursive(depAddonName, dependencyTable);
		end
	end

	return dependencyTable;
end

local function SetAddOnEnabled(addonName, enabled)
	if enabled then
		enableAddOn(addonName);
	else
		disableAddOn(addonName);
	end
end

local function EnableAndLoadAddOnHelper(addonName, restoreEnabledState)
	local previousState = (getAddOnEnableState(nil, addonName) > 0);
	enableAddOn(addonName);
	local loaded, message = loadAddOn(addonName);

	if restoreEnabledState then
		SetAddOnEnabled(addonName, previousState);
	end

	return loaded, message;
end

function AddOnUtil.LoadAddOn(addonName, restoreEnabledState)
	if not isAddOnLoaded(addonName) then
		local dependencyTable = GetAddOnDependenciesRecursive(addonName);
		for depAddonName in pairs(dependencyTable) do
			EnableAndLoadAddOnHelper(depAddonName, restoreEnabledState);
		end
		return EnableAndLoadAddOnHelper(addonName, restoreEnabledState);
	end

	return true; -- It was already loaded, no status message for addons that are already loaded.
end