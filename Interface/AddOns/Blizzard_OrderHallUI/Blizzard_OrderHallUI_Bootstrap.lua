local AddonName = ...;

function OrderHall_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ToggleOrderHallTalentUI()
	if OrderHall_LoadUI() then
		OrderHallTalentFrame_ToggleFrame();
	end
end

function OpenOrderHallTalentUI(garrisonType)
	if OrderHall_LoadUI() then
		OrderHallTalentFrame:SetGarrisonType(garrisonType);
		OrderHallTalentFrame_ToggleFrame();
	end
end
