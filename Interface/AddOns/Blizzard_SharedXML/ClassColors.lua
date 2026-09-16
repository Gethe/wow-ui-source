RAID_CLASS_COLORS = {};
do
	-- TODO: Provide universal valid class enumeration
	local classes =
	{
		"HUNTER",
		"WARLOCK",
		"PRIEST",
		"PALADIN",
		"MAGE",
		"ROGUE",
		"DRUID",
		"SHAMAN",
		"WARRIOR",
		"DEATHKNIGHT",
		"MONK",
		"DEMONHUNTER",
		"EVOKER",
		"ADVENTURER",
		"TRAVELER"
	};

	for i, className in ipairs(classes) do
		RAID_CLASS_COLORS[className] = C_ClassColor.GetClassColor(className);
	end
end

for _className, color in pairs(RAID_CLASS_COLORS) do
	color.colorStr = color:GenerateHexColor();
end
