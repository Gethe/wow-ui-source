function TutorialManager:CanShutdownTutorial()
	return true;
end

function TutorialManager:CanShowSupertrackTutorial()
	return false;
end

function TutorialManager:CanBootstrapNPE()
	return GetCVarBool("showNPETutorials");
end

TutorialManager.NPE_AchievementID = 64208;
