ColorblindOverrides = {}

function ColorblindOverrides.OnLoad(colorblindExamples)
	local qualityIDs = 
	{
		Enum.ItemQuality.Uncommon,
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
end