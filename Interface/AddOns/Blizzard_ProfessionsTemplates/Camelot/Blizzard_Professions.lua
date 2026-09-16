function Professions.SetupFilterMenu(dropdown, rootDescription)
	rootDescription:SetTag("MENU_PROFESSIONS_FILTER");

	local isGatheringProfession = Professions.GetProfessionType(Professions.GetProfessionInfo()) == Professions.ProfessionType.Gathering;
	local isNPCCrafting = C_TradeSkillUI.IsNPCCrafting();

	Professions.InitSkillUpFilter(rootDescription);

	Professions.InitMakeableFilter(rootDescription);

	if not isGatheringProfession then
		Professions.InitSlotsFilter(rootDescription);
	end
end

function Professions.GetNewestKnownProfessionInfo()
	return C_TradeSkillUI.GetBaseProfessionInfo();
end

function Professions.GetProfessionBackgroundFormat()
	return "Profession-background-card-%s";
end
