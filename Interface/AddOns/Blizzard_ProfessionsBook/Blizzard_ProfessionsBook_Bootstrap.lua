local AddonName = ...;

function ProfessionsBook_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ToggleProfessionsBook()
	if ProfessionsBook_LoadUI() then
		if ProfessionsBookFrame then
			ToggleFrame(ProfessionsBookFrame);
		elseif ProfessionsFrame then
			ToggleFrame(ProfessionsFrame);
		elseif ShowProfessionsFrame then
			ShowProfessionsFrame();

			if ProfessionsFrame and ProfessionsFrame.SelectBookPage then
				ProfessionsFrame:SelectBookPage();
			end
		end
	end
end
