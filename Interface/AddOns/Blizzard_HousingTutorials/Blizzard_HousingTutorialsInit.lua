local function CanShowHouseDecorQuestTutorial()
	local housingCleanupTutorialComplete = GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingDecorCleanup) or C_QuestLog.IsQuestFlaggedCompleted(HousingTutorialQuestIDs.CleanupQuest);
	local housingDecorateTutorialComplete = GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingDecorPlace) or C_QuestLog.IsQuestFlaggedCompleted(HousingTutorialQuestIDs.DecorateQuest);

	return not housingCleanupTutorialComplete or not housingDecorateTutorialComplete;
end

local function CanShowHouseDecorTutorials()
	return not CanShowHouseDecorQuestTutorial();
end

function CanShowHouseFinderTutorial()
	return not C_CVar.GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingHouseFinderMap) or not C_CVar.GetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingHouseFinderVisitHouse);
end

local activeTutorials = {};

function UpdateHousingTutorials()
	if not C_CVar.GetCVarBool("housingTutorialsEnabled") then
		-- Don't add the watchers if we don't have tutorials enabled
		return;
	end

	local activeTutorial = activeTutorials["HouseFinderTutorial"];
	if CanShowHouseFinderTutorial() then
		if not activeTutorial then
			activeTutorials["HouseFinderTutorial"] = CreateFromMixins(HouseFinderWatcherMixin);
			activeTutorial = activeTutorials["HouseFinderTutorial"];
		end

		activeTutorial:StartWatching();
	elseif activeTutorial then
		activeTutorial:StopWatching();
	end

	activeTutorial = activeTutorials["DecorQuestTutorial"];
	if CanShowHouseDecorQuestTutorial() then
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
	if CanShowHouseDecorTutorials() then
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
end

function HousingTutorialManager:OnSettingsLoaded()
	HousingTutorialsQuestManager:ReinitializeExistingQuests();
end

HousingTutorialManager:Init();

