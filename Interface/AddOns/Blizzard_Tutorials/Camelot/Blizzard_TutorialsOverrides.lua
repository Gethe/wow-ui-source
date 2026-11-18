-- Camelot relies on the talent micro button helptip instead of the talent tutorial.
function IsTalentTutorialEnabled()
	return false;
end

function GetTalentMicroButton()
	return TalentMicroButton;
end

-- Camelot's talent UI has no starter build loadout dropdown.
function IsStarterTalentTutorialEnabled()
	return false;
end
