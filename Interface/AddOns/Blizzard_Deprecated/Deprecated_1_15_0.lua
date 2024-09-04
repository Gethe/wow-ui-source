-- These are functions that were deprecated in 1.15.0 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	EnableAddOn = C_AddOns.EnableAddOn;
	DisableAddOn = C_AddOns.DisableAddOn;
	GetAddOnEnableState = function(character, name) return C_AddOns.GetAddOnEnableState(name, character); end
	LoadAddOn = C_AddOns.LoadAddOn;
	IsAddOnLoaded = C_AddOns.IsAddOnLoaded;
	EnableAllAddOns = C_AddOns.EnableAllAddOns;
	DisableAllAddOns = C_AddOns.DisableAllAddOns;
	GetAddOnInfo = C_AddOns.GetAddOnInfo;
	GetAddOnDependencies = C_AddOns.GetAddOnDependencies;
	GetAddOnOptionalDependencies = C_AddOns.GetAddOnOptionalDependencies;
	GetNumAddOns = C_AddOns.GetNumAddOns;
	SaveAddOns = C_AddOns.SaveAddOns;
	ResetAddOns = C_AddOns.ResetAddOns;
	ResetDisabledAddOns = C_AddOns.ResetDisabledAddOns;
	IsAddonVersionCheckEnabled = C_AddOns.IsAddonVersionCheckEnabled;
	SetAddonVersionCheck = C_AddOns.SetAddonVersionCheck;
	IsAddOnLoadOnDemand = C_AddOns.IsAddOnLoadOnDemand;
end