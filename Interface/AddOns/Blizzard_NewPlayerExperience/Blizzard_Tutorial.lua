NewPlayerExperience = {};
-- ------------------------------------------------------------------------------------------------------------
function NewPlayerExperience:Initialize()
	self:Begin();
end

function NewPlayerExperience:Begin()
	local _, _, _, completed = GetAchievementInfo(TutorialManager.NPE_AchievementID);
	if ( completed == true ) then
		-- we have completed the NPE at least once, check to see if Tutorials are on
		local showTutorials = GetCVarBool("showTutorials");
		if ( not showTutorials ) then
			-- Tutorials are off, just exit
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
	
	-- if the achievement is NOT completed, we don't care if Tutorials are on or off
	Dispatcher:RegisterEvent("PLAYER_LEVEL_UP", self);
	Dispatcher:RegisterEvent("CVAR_UPDATE", self);

	HelpTip:SetHelpTipsEnabled("NPEv2", false);
	HelpTip:ForceHideAll();

	-- Tutorial only
	SetCVar("nameplateShowEnemies", 1); -- 0
	
	MainMenuMicroButton_SetAlertsEnabled(false, "NPEv2"); --Turns off microtips
	TutorialLogic:Begin();

	self.IsActive = true;
end

function NewPlayerExperience:PLAYER_LEVEL_UP(newLevel)
	local isRestricted = C_PlayerInfo.IsPlayerNPERestricted();
	if not isRestricted then
		self:Shutdown();
	end
end

function NewPlayerExperience:CVAR_UPDATE(cvar, value)
	if (cvar == "showTutorials" ) then
		if (value == "0") then
			-- player is trying to shut the NPE Tutorial off
			local _, _, _, completed = GetAchievementInfo(TutorialManager.NPE_AchievementID);
			-- they can  ONLY do that if the achievement is completed
			if (completed) then
				self:Shutdown();
			end
		end
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