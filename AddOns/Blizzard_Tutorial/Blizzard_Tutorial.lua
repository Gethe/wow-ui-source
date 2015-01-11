NewPlayerExperience = {};
NewPlayerExperience.CompletionLevel = NPE_TUTORIAL_COMPLETE_LEVEL;

-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:Initialize()

	self:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:Begin()
	if ( not GetCVarBool("showNPETutorials") ) then
		return;
	end
	-- Completion Criteria
	if (UnitLevel("player") >= self.CompletionLevel) then
		self:RegisterComplete();
		return;
	else
		Dispatcher:RegisterEvent("PLAYER_LEVEL_UP", self);
	end

	-- Tutorial only
	SetCVar("nameplateShowEnemies", 1); -- 0
	NPE_QuestManager:Initialize();
	Tutorials:Begin();

	self.IsActive = true;
end

-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:PLAYER_LEVEL_UP(newLevel)
	if (newLevel >= self.CompletionLevel) then
		self:RegisterComplete();
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:Shutdown()
	NPE_RangeManager:Shutdown();
	NPE_QuestManager:Shutdown();
	NPE_TutorialKeyboardMouseFrame:HideHelpFrame();

	Tutorials:Shutdown();
	self.IsActive = false;
end

-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:RegisterComplete()
	self:Shutdown();

	SetCVar("showNPETutorials", 0);
end

-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:GetIsActive()
	return self.IsActive;
end

-- ------------------------------------------------------------------------------------------------------------
NewPlayerExperience:Initialize();