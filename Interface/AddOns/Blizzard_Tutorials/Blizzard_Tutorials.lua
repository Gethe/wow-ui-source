GameTutorials = {};

function GameTutorials:Initialize()
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", self.OnPlayerEnterWorld, self);
end

function GameTutorials:OnPlayerEnterWorld(isLogin, isReloadUI)
	if (isLogin or isReloadUI) and not IsAddOnLoaded("Blizzard_NewPlayerExperience") then
		TutorialManager:AddWatcher(Class_StarterTalentWatcher:new(), true);
		TutorialManager:AddTutorial(Class_ChangeSpec:new());
		TutorialManager:AddTutorial(Class_TalentPoints:new());
	end
end

GameTutorials:Initialize();
