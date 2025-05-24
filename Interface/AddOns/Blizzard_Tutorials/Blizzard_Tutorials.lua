GameTutorials = {};

function GameTutorials:Initialize()
	EventRegistry:RegisterCallback("TutorialManager.TutorialsEnabled", self.OnTutorialsEnabled, self);
	EventRegistry:RegisterCallback("TutorialManager.TutorialsDisabled", self.OnTutorialsDisabled, self);
	EventRegistry:RegisterCallback("TutorialManager.TutorialsInit", self.OnTutorialsInit, self);
end

function GameTutorials:OnTutorialsInit()
	AddEvokerTutorials();
end

function GameTutorials:OnTutorialsEnabled()
	if C_AddOns.IsAddOnLoaded("Blizzard_NewPlayerExperience") then
		return;
	end

	AddSpecAndTalentTutorials();
	AddFrameTutorials(); --Misc tutorials
	AddDragonridingTutorials();
	AddPerksProgramTutorials();

	if CanShowProfessionEquipmentTutorial() then
		TutorialManager:AddTutorial(Class_EquipProfessionGear:new());
		TutorialManager:AddTutorial(Class_ProfessionGearCheckingService:new());
		local autoStart = true;
		TutorialManager:AddWatcher(Class_ProfessionInventoryWatcher:new(), autoStart);
	end

	if PlayerHasPrimaryProfession() then
		-- If the player already has a profession, mark the tutorial as seen
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FIRST_PROFESSION, true);
	else
		TutorialManager:AddTutorial(Class_FirstProfessionTutorial:new());
		local autoStart = true;
		TutorialManager:AddWatcher(Class_FirstProfessionWatcher:new(), autoStart);
	end
end

function GameTutorials:OnTutorialsDisabled()
	self:Shutdown();
end

function GameTutorials:Shutdown()
	-- add special shutdown code here for your tutorials
end

GameTutorials:Initialize();