NewPlayerExperience = {};
-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:Initialize()
	self:Begin();
end

function NewPlayerExperience:Begin()
	EventRegistry:RegisterCallback("TutorialManager.TutorialsEnabled", self.OnTutorialsEnabled, self);
	EventRegistry:RegisterCallback("TutorialManager.TutorialsDisabled", self.OnTutorialsDisabled, self);
end

function NewPlayerExperience:OnTutorialsEnabled()
	local _, _, _, completed = GetAchievementInfo(TutorialManager.NPE_AchievementID);
	if ( completed == true ) then
		-- we have completed the NPE at least once, check to see if Tutorials are on
		local showTutorials = GetCVarBool("showTutorials");
		if ( not showTutorials ) then
			-- Tutorials are off, just Shutdown
			self:Shutdown();
			return;
		end
	else
		-- this player does not have the achievement, but they also aren't elligible
		if not C_PlayerInfo.IsPlayerEligibleForNPEv2() then
			self:Shutdown();
			return;
		end
	end
	
	Dispatcher:RegisterEvent("PLAYER_LEVEL_UP", self);
	HelpTip:SetHelpTipsEnabled("NPEv2", false);
	HelpTip:ForceHideAll();

	-- Tutorial only
	SetCVar("nameplateShowEnemies", 1); -- 0
	MainMenuMicroButton_SetAlertsEnabled(false, "NPEv2"); --Turns off microtips
	TutorialLogic:Begin();
	self.IsActive = true;
end

function NewPlayerExperience:OnTutorialsDisabled()
	-- the TutorialManager will only send this even out if its possible to shut the NPE down
	self:Shutdown();
end

function NewPlayerExperience:PLAYER_LEVEL_UP(newLevel)
	local isRestricted = C_PlayerInfo.IsPlayerNPERestricted();
	if not isRestricted then
		-- the player has leveled up beyond the NPE
		self:Shutdown();
	end
end

function NewPlayerExperience:Shutdown()
	HelpTip:SetHelpTipsEnabled("NPEv2", true);
	MainMenuMicroButton_SetAlertsEnabled(true, "NPEv2"); --Turns microtips back on

	TutorialLogic:Shutdown();
	self.IsActive = false;
end

function NewPlayerExperience:GetIsActive()
	return self.IsActive;
end

NewPlayerExperience:Initialize();