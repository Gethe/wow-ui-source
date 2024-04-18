local CompactUnitFrameProfiles = { };

CompactUnitFrameProfiles.CVarOptions = {
	-- Default
	raidFramesDisplayIncomingHeals				= "displayHealPrediction",
	raidFramesDisplayPowerBars					= "displayPowerBar",
	raidFramesDisplayOnlyHealerPowerBars		= "displayOnlyHealerPowerBars",
	raidFramesDisplayAggroHighlight				= "displayAggroHighlight",
	raidFramesDisplayClassColor					= "useClassColors",
	raidOptionDisplayPets						= "displayPets",
	raidOptionDisplayMainTankAndAssist			= "displayMainTankAndAssist",
	raidFramesDisplayDebuffs					= "displayDebuffs",
	raidFramesDisplayOnlyDispellableDebuffs		= "displayOnlyDispellableDebuffs",
	raidFramesHealthText						= "healthText",
	raidOptionIsShown							= "shown",

	-- Pvp
	pvpFramesDisplayPowerBars					= "pvpDisplayPowerBar",
	pvpFramesDisplayOnlyHealerPowerBars			= "pvpDisplayOnlyHealerPowerBars",
	pvpFramesDisplayClassColor					= "pvpUseClassColors",
	pvpOptionDisplayPets						= "pvpDisplayPets",
	pvpFramesHealthText							= "pvpHealthText",
};

function CompactUnitFrameProfiles:OnCVarChanged(name)
	if self.variablesLoaded and self.CVarOptions[name] then
		self:ApplyCurrentSettings();
	end
end

function CompactUnitFrameProfiles:OnVariablesLoaded(name)
	self.variablesLoaded = true;
	self:ApplyCurrentSettings();
end

function CompactUnitFrameProfiles:Init()
	EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", self.OnVariablesLoaded, self);
	CVarCallbackRegistry:RegisterCVarChangedCallback(self.OnCVarChanged, self);
end


-------------------------------------------------------------
-----------------Applying of Options----------------------
-------------------------------------------------------------


function CompactUnitFrameProfiles:GetCVarOptions()
	local options = {};

	for cvar, option in pairs(self.CVarOptions) do
		local value = GetCVar(cvar);
		if value == "0" then
			value = false;
		elseif value == "1" then
			value = true;
		end
		options[option] = value;
	end

	return options;
end

function CompactUnitFrameProfiles:ApplyCurrentSettings()
	local options = self:GetCVarOptions();
	self:ApplyOptions(options);
end

function CompactUnitFrameProfiles:ApplyOptions(options)
	for optionName, value in pairs(options) do
		local func = self.CUFProfileActionTable[optionName];
		if ( func ) then
			func(value);
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

function CompactUnitFrameProfiles:GenerateRaidManagerSetting(optionName)
	return function(value)
		CompactRaidFrameManager_SetSetting(optionName, value);
	end
end

function CompactUnitFrameProfiles:GenerateOptionSetter(optionName, optionTarget)
	return function(value)
		if ( optionTarget == "normal" or optionTarget == "all" ) then
			DefaultCompactUnitFrameOptions[optionName] = value;
		end
		if ( optionTarget == "mini" or optionTarget == "all" ) then
			DefaultCompactMiniFrameOptions[optionName] = value;
		end
	end
end

function CompactUnitFrameProfiles:GenerateSetUpOptionSetter(optionName, optionTarget)
	return function(value)
		if ( optionTarget == "normal" or optionTarget == "all" ) then
			DefaultCompactUnitFrameSetupOptions[optionName] = value;
		end
		if ( optionTarget == "mini" or optionTarget == "all" ) then
			DefaultCompactMiniFrameSetUpOptions[optionName] = value;
		end
	end
end

CompactUnitFrameProfiles.CUFProfileActionTable = {
	--Settings
	displayPets = CompactUnitFrameProfiles:GenerateRaidManagerSetting("DisplayPets"),
	displayMainTankAndAssist = CompactUnitFrameProfiles:GenerateRaidManagerSetting("DisplayMainTankAndAssist"),
	displayHealPrediction = CompactUnitFrameProfiles:GenerateOptionSetter("displayHealPrediction", "all"),
	displayPowerBar = CompactUnitFrameProfiles:GenerateSetUpOptionSetter("displayPowerBar", "normal"),
	displayOnlyHealerPowerBars = CompactUnitFrameProfiles:GenerateSetUpOptionSetter("displayOnlyHealerPowerBars", "normal"),
	displayAggroHighlight = CompactUnitFrameProfiles:GenerateOptionSetter("displayAggroHighlight", "all"),
	displayDebuffs = CompactUnitFrameProfiles:GenerateOptionSetter("displayDebuffs", "normal"),
	displayOnlyDispellableDebuffs = CompactUnitFrameProfiles:GenerateOptionSetter("displayOnlyDispellableDebuffs", "normal"),
	useClassColors = CompactUnitFrameProfiles:GenerateOptionSetter("useClassColors", "normal"),
	healthText = CompactUnitFrameProfiles:GenerateOptionSetter("healthText", "normal"),

	-- Pvp Settings
	pvpDisplayPowerBar = CompactUnitFrameProfiles:GenerateSetUpOptionSetter("pvpDisplayPowerBar", "normal"),
	pvpDisplayOnlyHealerPowerBars = CompactUnitFrameProfiles:GenerateSetUpOptionSetter("pvpDisplayOnlyHealerPowerBars", "normal"),
	pvpUseClassColors = CompactUnitFrameProfiles:GenerateOptionSetter("pvpUseClassColors", "normal"),
	pvpDisplayPets = CompactUnitFrameProfiles:GenerateRaidManagerSetting("pvpDisplayPets"),
	pvpHealthText = CompactUnitFrameProfiles:GenerateOptionSetter("pvpHealthText", "normal"),

	--State
	shown = CompactUnitFrameProfiles:GenerateRaidManagerSetting("IsShown"),
}

CompactUnitFrameProfiles:Init();
