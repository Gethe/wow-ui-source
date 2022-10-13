GameTutorials = {};

function GameTutorials:Initialize()
	EventRegistry:RegisterCallback("TutorialManager.TutorialsEnabled", self.OnTutorialsEnabled, self);
	EventRegistry:RegisterCallback("TutorialManager.TutorialsDisabled", self.OnTutorialsDisabled, self);
end

function GameTutorials:OnTutorialsEnabled()
	if IsAddOnLoaded("Blizzard_NewPlayerExperience") then
		return;
	end

	TutorialManager:AddWatcher(Class_StarterTalentWatcher:new(), true);
	TutorialManager:AddTutorial(Class_ChangeSpec:new());
	TutorialManager:AddTutorial(Class_TalentPoints:new());

	local _, raceFilename = UnitRace("Player");
	if raceFilename == "Dracthyr" then
		TutorialManager:AddWatcher(Class_DracthyrEssenceWatcher:new(), true);
		TutorialManager:AddWatcher(Class_DracthyrEmpoweredSpellWatcher:new(), true);
	end

	if CanShowProfessionEquipmentTutorial() then
		TutorialManager:AddTutorial(Class_EquipProfessionGear:new());
		TutorialManager:AddTutorial(Class_ProfessionGearCheckingService:new());
		local autoStart = true;
		TutorialManager:AddWatcher(Class_ProfessionInventoryWatcher:new(), autoStart);
	end
end

function GameTutorials:OnTutorialsDisabled()
	self:Shutdown();
end

function GameTutorials:Shutdown()
	-- add special shutdown code here for your tutorials
end

GameTutorials:Initialize();
