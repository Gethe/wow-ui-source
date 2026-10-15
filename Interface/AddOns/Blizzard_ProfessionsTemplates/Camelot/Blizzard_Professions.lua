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

local originalGenerateCraftingDataProvider = Professions.GenerateCraftingDataProvider;
function Professions.GenerateCraftingDataProvider(professionID, searching, noStripCategories, collapses)
	local dataProvider = originalGenerateCraftingDataProvider(professionID, searching, noStripCategories, collapses);
	C_TradeSkillUI.SetShowUnlearned(Professions.GetDefaultShowUnlearned());
	return dataProvider;
end

function Professions.GetDefaultShowUnlearned()
	return false;
end

function Professions.GetNewestKnownProfessionInfo()
	return C_TradeSkillUI.GetBaseProfessionInfo();
end

function Professions.GetProfessionBackgroundFormat()
	return "Profession-background-card-%s";
end
