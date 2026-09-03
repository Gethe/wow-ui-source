local function CanShowHouseDecorQuestTutorial()
	return not HousingTutorialUtil.HousingDecorQuestTutorialComplete();
end

local function CanShowHouseDecorTutorials()
	return not CanShowHouseDecorQuestTutorial();
end

function CanShowHouseFinderTutorial()
	return not C_CVar.GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingHouseFinderMap) or not C_CVar.GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingHouseFinderVisitHouse);
end

local activeTutorials = {};

function UpdateHousingTutorials()
	-- If housing tutorials are enabled, we can start them up
	-- Otherwises, we need to stop any that were already started up
	local tutorialsEnabled = C_CVar.GetCVarBool("housingTutorialsEnabled");

	local activeTutorial = activeTutorials["HouseFinderTutorial"];
	if tutorialsEnabled and CanShowHouseFinderTutorial() then
		if not activeTutorial then
			activeTutorials["HouseFinderTutorial"] = CreateFromMixins(HouseFinderWatcherMixin);
			activeTutorial = activeTutorials["HouseFinderTutorial"];
		end

		activeTutorial:StartWatching();
	elseif activeTutorial then
		activeTutorial:StopWatching();
	end

	activeTutorial = activeTutorials["DecorQuestTutorial"];
	if tutorialsEnabled and CanShowHouseDecorQuestTutorial() then
		if not activeTutorial then
			activeTutorials["DecorQuestTutorial"] = CreateFromMixins(HouseDecorQuestWatcherMixin);
			activeTutorial = activeTutorials["DecorQuestTutorial"];
			activeTutorial:Initialize();
		end

		activeTutorial:StartWatching();
	elseif activeTutorial then
		activeTutorial:StopWatching();
	end

	activeTutorial = activeTutorials["DecorTutorial"];
	if tutorialsEnabled and CanShowHouseDecorTutorials() then
		if not activeTutorial then
			activeTutorials["DecorTutorial"] = CreateFromMixins(HouseDecorWatcherMixin);
			activeTutorial = activeTutorials["DecorTutorial"];
		end

		activeTutorial:StartWatching();
	elseif activeTutorial then
		activeTutorial:StopWatching();
	end
end

local HousingTutorialManager = {};

function HousingTutorialManager:Init()
	UpdateHousingTutorials();

	EventRegistry:RegisterFrameEventAndCallback("SETTINGS_LOADED", self.OnSettingsLoaded, self);
	CVarCallbackRegistry:RegisterCallback("housingTutorialsEnabled", function(cvar, value)
		UpdateHousingTutorials();
	end);
end

function HousingTutorialManager:OnSettingsLoaded()
	HousingTutorialsQuestManager:ReinitializeExistingQuests();
end

HousingTutorialManager:Init();

