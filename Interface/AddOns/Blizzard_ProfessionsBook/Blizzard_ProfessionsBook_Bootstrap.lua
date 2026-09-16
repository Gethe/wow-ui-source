local AddonName = ...;

function ProfessionsBook_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ToggleProfessionsBook()
	if ProfessionsBook_LoadUI() then
		ToggleFrame(ProfessionsBookFrame);
	end
end
