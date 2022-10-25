GameTutorials = {};

function GameTutorials:Initialize()
	EventRegistry:RegisterCallback("TutorialManager.TutorialsEnabled", self.OnTutorialsEnabled, self);
	EventRegistry:RegisterCallback("TutorialManager.TutorialsDisabled", self.OnTutorialsDisabled, self);
end

function GameTutorials:OnTutorialsEnabled()
	if IsAddOnLoaded("Blizzard_NewPlayerExperience") then
		return;
	end

	AddSpecAndTalentTutorials();
	AddDracthyrTutorials();
end

function GameTutorials:OnTutorialsDisabled()
	self:Shutdown();
end

function GameTutorials:Shutdown()
	-- add special shutdown code here for your tutorials
end

GameTutorials:Initialize();
