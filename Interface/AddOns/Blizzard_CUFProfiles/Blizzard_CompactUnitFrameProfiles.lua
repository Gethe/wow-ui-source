local function CUF_GetCVarBool(cvar)
	return CVarCallbackRegistry:GetCVarValueBool(cvar);
end

local function CUF_GetCVarNumeric(cvar)
	return CVarCallbackRegistry:GetCVarNumberOrDefault(cvar);
end

local function CUF_GetCVarString(cvar)
	return CVarCallbackRegistry:GetCVarValue(cvar);
end

local function CUF_GetCVarColor(cvar)
	return CreateColorFromHexString(CUF_GetCVarString(cvar));
end

local function CUF_SetOptionInternal(optionName, value, optionTarget, normalTable, miniTable)
	if optionTarget == "normal" or optionTarget == "all" then
		normalTable[optionName] = value;
	end

	if optionTarget == "mini" or optionTarget == "all" then
		miniTable[optionName] = value;
	end
end

local function CUF_SetOption(optionName, value, optionTarget)
	CUF_SetOptionInternal(optionName, value, optionTarget, DefaultCompactUnitFrameOptions, DefaultCompactMiniFrameOptions);
end

local function CUF_SetSetupOption(optionName, value, optionTarget)
	CUF_SetOptionInternal(optionName, value, optionTarget, DefaultCompactUnitFrameSetupOptions, DefaultCompactMiniFrameSetUpOptions);
end

local function CUF_SetRaidFrameManagerSetting(optionName, value, _optionTarget)
	CompactRaidFrameManager_SetSetting(optionName, value);
end

local CompactUnitFrameProfiles = { };

function CompactUnitFrameProfiles:OnCVarChanged(_value)
	if self.variablesLoaded then
		self:ApplyCurrentSettings();
	end
end

function CompactUnitFrameProfiles:OnVariablesLoaded(name)
	self.variablesLoaded = true;
	self:ApplyCurrentSettings();
end

function CompactUnitFrameProfiles:Init(options)
	self.CVarOptions = options;

	EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", self.OnVariablesLoaded, self);

	for cvar, _option in pairs(self.CVarOptions) do
		CVarCallbackRegistry:RegisterCallback(cvar, self.OnCVarChanged, self);
	end
end

function CompactUnitFrameProfiles:ApplyCurrentSettings()
	-- Query and transform all cvars, then call the appropriate UnitFrame settings API with the translated option name and value
	-- Skip the setup for cvars that don't exist
	for cvar, option in pairs(self.CVarOptions) do
		if C_CVar.GetCVar(cvar) ~= nil then
			local optionName = option.option;
			local optionValue = option.accessor and option.accessor(cvar) or CUF_GetCVarBool(cvar);
			(option.mutator or CUF_SetOption)(optionName, optionValue, option.target or "normal");
		end
	end

	--Refresh all frames to make sure the changes stick.
	CompactRaidFrameContainer:ApplyToFrames("normal", DefaultCompactUnitFrameSetup);
	CompactRaidFrameContainer:ApplyToFrames("normal", CompactUnitFrame_UpdateAll);
	CompactRaidFrameContainer:ApplyToFrames("mini", DefaultCompactMiniFrameSetup);
	CompactRaidFrameContainer:ApplyToFrames("mini", CompactUnitFrame_UpdateAll);

	--Update the borders on the group frames.
	CompactRaidFrameContainer:ApplyToFrames("group", CompactRaidGroup_UpdateBorder);

	--Update the container in case sizes and such changed.
	CompactRaidFrameContainer:TryUpdate();

	-- Update settings raid frame preview if it exists.
	if RaidFrameSettingsPreviewFrame then
		DefaultCompactUnitFrameSetup(RaidFrameSettingsPreviewFrame);
		CompactUnitFrame_UpdateAll(RaidFrameSettingsPreviewFrame);
	end
end

-- This table describes a mapping of cvar name to an internal CompactUnitFrame option and data about how to translate that option into a format that some UnitFrame settings API can use to actually
-- set the option.
--
-- Fields:
--		option - The name of the option in the API (or table key in the case of CUF options like DefaultCompactUnitFrameOptions/DefaultCompactMiniFrameOptions)

--		accessor - A function to query the cvar value and return it in the best format for the option (this function could transform the value into anything)
--					Default: CUF_GetCVarBool

--		mutator - A function to actually set the option in the CompactUnitFrame API
--					Default: CUF_SetOption

--		target - in the case of tables like DefaultCompactUnitFrameOptions/DefaultCompactMiniFrameOptions this is a string that decide which tables need to be written to. (normal/mini/all)
--					Default: "normal"
--
-- NOTE: CUF_GetCVarBool is the default accessor

CompactUnitFrameProfiles:Init({
	-- Default CompactUnitFrames
	raidFramesDisplayIncomingHeals				= { option = "displayHealPrediction", target = "all", },
	raidFramesDisplayPowerBars					= { option = "displayPowerBar", mutator = CUF_SetSetupOption, },
	raidFramesDisplayOnlyHealerPowerBars		= { option = "displayOnlyHealerPowerBars", mutator = CUF_SetSetupOption, },
	raidFramesDisplayAggroHighlight				= { option = "displayAggroHighlight", target = "all" },
	raidFramesDisplayClassColor					= { option = "useClassColors", },
	raidFramesHealthBarColor					= { option = "healthBarColor", accessor = CUF_GetCVarColor, },
	raidOptionDisplayPets						= { option = "DisplayPets", mutator = CUF_SetRaidFrameManagerSetting, },
	raidOptionDisplayMainTankAndAssist			= { option = "DisplayMainTankAndAssist", mutator = CUF_SetRaidFrameManagerSetting, },
	raidFramesDisplayDebuffs					= { option = "displayDebuffs", },
	raidFramesDisplayOnlyDispellableDebuffs		= { option = "displayOnlyDispellableDebuffs", },
	raidFramesDisplayLargerRoleSpecificDebuffs	= { option = "displayLargerRoleSpecificDebuffs", },
	raidFramesDispelIndicatorType				= { option = "raidFramesDispelIndicatorType", accessor = CUF_GetCVarNumeric },
	raidFramesHealthText						= { option = "healthText", accessor = CUF_GetCVarString },
	raidFramesDispelIndicatorOverlay			= { option = "showDispelIndicatorOverlay", },
	raidFramesCenterBigDefensive				= { option = "raidFramesCenterBigDefensive", },

	-- Pvp
	pvpFramesDisplayPowerBars					= { option = "pvpDisplayPowerBar", mutator = CUF_SetSetupOption, },
	pvpFramesDisplayOnlyHealerPowerBars			= { option = "pvpDisplayOnlyHealerPowerBars", mutator = CUF_SetSetupOption, },
	pvpFramesDisplayClassColor					= { option = "pvpUseClassColors", },
	pvpOptionDisplayPets						= { option = "pvpDisplayPets", mutator = CUF_SetRaidFrameManagerSetting, },
	pvpFramesHealthText							= { option = "pvpHealthText", accessor = CUF_GetCVarString },

	-- State
	raidOptionIsShown							= { option = "IsShown", mutator = CUF_SetRaidFrameManagerSetting, },
});
