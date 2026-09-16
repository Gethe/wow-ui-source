local AddonName = ...;

function ProfessionsFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowProfessionsFrame()
	if ProfessionsFrame_LoadUI() then
		ShowUIPanel(ProfessionsFrame);
	end
end

function OpenProfessionUIToSkillLine(skillLineID)
	if ProfessionsFrame_LoadUI() then
		local currBaseProfessionInfo = C_TradeSkillUI.GetBaseProfessionInfo();
		if currBaseProfessionInfo == nil or currBaseProfessionInfo.professionID ~= skillLineID then
			C_TradeSkillUI.OpenTradeSkill(skillLineID);
		end
		ProfessionsFrame:SetTab(ProfessionsFrame.recipesTabID);
		ShowUIPanel(ProfessionsFrame);
	end
end

function ShowProfessionEquipmentHelpTip(skillLineID)
	OpenProfessionUIToSkillLine(skillLineID);

	local helpTipInfo =
	{
		text = PROFESSION_EQUIPMENT_LOCATION_HELPTIP,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.LeftEdgeTop,
		alignment = HelpTip.Alignment.Left,
		offsetX = 940,
		offsetY = -48,
	};
	HelpTip:Show(ProfessionsFrame.CraftingPage, helpTipInfo, ProfessionsFrame.CraftingPage);
end
