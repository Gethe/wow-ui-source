AddOnUtil = {};

local function GetAddOnDependenciesRecursive(addonName, dependencyTable)
	dependencyTable = dependencyTable or {};
	local dependencies = { C_AddOns.GetAddOnDependencies(addonName) };
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
		C_AddOns.EnableAddOn(addonName);
	else
		C_AddOns.DisableAddOn(addonName);
	end
end

local function EnableAndLoadAddOnHelper(addonName, restoreEnabledState)
	local previousState = (C_AddOns.GetAddOnEnableState(addonName) > 0);
	C_AddOns.EnableAddOn(addonName);
	local loaded, message = C_AddOns.LoadAddOn(addonName);

	if restoreEnabledState then
		SetAddOnEnabled(addonName, previousState);
	end

	return loaded, message;
end

function AddOnUtil.LoadAddOn(addonName, restoreEnabledState)
	if not C_AddOns.IsAddOnLoaded(addonName) then
		local dependencyTable = GetAddOnDependenciesRecursive(addonName);
		for depAddonName in pairs(dependencyTable) do
			if not C_AddOns.IsAddOnLoaded(depAddonName) then
				EnableAndLoadAddOnHelper(depAddonName, restoreEnabledState);
			end
		end
		return EnableAndLoadAddOnHelper(addonName, restoreEnabledState);
	end

	return true; -- It was already loaded, no status message for addons that are already loaded.
end

function AddOnUtil.SetEnableStateForAddOnAndDependencies(addonName, character, enabled)
	local setter = enabled and C_AddOns.EnableAddOn or C_AddOns.DisableAddOn;

	local dependencyTable = GetAddOnDependenciesRecursive(addonName);
	for depAddonName in pairs(dependencyTable) do
		setter(depAddonName, character);
	end
	setter(addonName, character);
end
