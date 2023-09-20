-- These are functions that were deprecated in 10.2.0 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

do
	GetCVarInfo = C_CVar.GetCVarInfo;

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

	local original_SetPortraitToTexture = SetPortraitToTexture;
	SetPortraitToTexture = function(texture, asset)
		if asset ~= nil then
			if type(texture) == "string" then
				texture = _G[texture];
			end
			original_SetPortraitToTexture(texture, asset);
		end
	end
end