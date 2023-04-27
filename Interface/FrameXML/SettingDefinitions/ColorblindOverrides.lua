ColorblindOverrides = {}

function ColorblindOverrides.OnLoad(colorblindExamples)
	local qualityIDs = 
	{
		Enum.ItemQuality.Good,
		Enum.ItemQuality.Rare,
		Enum.ItemQuality.Epic,
		Enum.ItemQuality.Legendary,
		Enum.ItemQuality.Heirloom,
	};
	
	for index, qualityID in ipairs(qualityIDs) do
		local itemQuality = colorblindExamples.ItemQualities[index];
		itemQuality:SetText(_G["ITEM_QUALITY"..qualityID.."_DESC"]);
		itemQuality:SetTextColor(ITEM_QUALITY_COLORS[qualityID].color:GetRGB());
	end

	colorblindExamples.ExampleIcon4:SetTexture("Interface\\Icons\\INV_Misc_Gem_Variety_02");
	colorblindExamples.ExampleIcon6:SetTexture("Interface\\Icons\\Spell_Holy_SealOfRighteousness");
end