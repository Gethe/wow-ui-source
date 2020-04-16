NewPlayerExperience = {};

-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:Initialize()
	--Flags all old tutorials to be complete 
	for i = 1, 65 do 
		FlagTutorial(i)
	end 
	self:Begin();
end

-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:Begin()
	if ( not GetCVarBool("showNPETutorials") ) then
		return;
	end
	-- Completion Criteria
	if not C_PlayerInfo.IsPlayerEligibleForNPEv2() then
		self:RegisterComplete();
		return;
	else
		Dispatcher:RegisterEvent("PLAYER_LEVEL_UP", self);
	end

	HelpTip:SetHelpTipsEnabled("NPEv2", false);
	HelpTip:ForceHideAll();

	-- Tutorial only
	SetCVar("nameplateShowEnemies", 1); -- 0
	
	MainMenuMicroButton_SetAlertsEnabled(false, "NPEv2"); --Turns off microtips
	NPE_QuestManager:Initialize();
	Tutorials:Begin();

	self.IsActive = true;
end

-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:PLAYER_LEVEL_UP(newLevel)
	if not C_PlayerInfo.IsPlayerEligibleForNPEv2() then
		self:RegisterComplete();
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:Shutdown()
	NPE_RangeManager:Shutdown();
	NPE_QuestManager:Shutdown();

	HelpTip:SetHelpTipsEnabled("NPEv2", true);
	MainMenuMicroButton_SetAlertsEnabled(true, "NPEv2"); --Turns microtips back on

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