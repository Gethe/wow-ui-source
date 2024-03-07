RAID_CLASS_COLORS = {
	["HUNTER"] = CreateColor(0.67, 0.83, 0.45),
	["WARLOCK"] = CreateColor(0.53, 0.53, 0.93),
	["PRIEST"] = CreateColor(1.0, 1.0, 1.0),
	["PALADIN"] = CreateColor(0.96, 0.55, 0.73),
	["MAGE"] = CreateColor(0.25, 0.78, 0.92),
	["ROGUE"] = CreateColor(1.0, 0.96, 0.41),
	["DRUID"] = CreateColor(1.0, 0.49, 0.04),
	["SHAMAN"] = CreateColor(0.96, 0.55, 0.73),
	["WARRIOR"] = CreateColor(0.78, 0.61, 0.43),
	["DEATHKNIGHT"] = CreateColor(0.77, 0.12 , 0.23),
	["MONK"] = CreateColor(0.0, 1.00 , 0.59),
	["DEMONHUNTER"] = CreateColor(0.64, 0.19, 0.79),
};

for k, v in pairs(RAID_CLASS_COLORS) do
	v.colorStr = v:GenerateHexColor();
end