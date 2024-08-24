RAID_CLASS_COLORS = {};
do
	local classes = {"HUNTER", "WARLOCK", "PRIEST", "PALADIN", "MAGE", "ROGUE", "DRUID", "SHAMAN", "WARRIOR", "DEATHKNIGHT", "MONK", "DEMONHUNTER", "EVOKER"};

	for i, className in ipairs(classes) do
		RAID_CLASS_COLORS[className] = C_ClassColor.GetClassColor(className);
	end
end

for k, v in pairs(RAID_CLASS_COLORS) do
	v.colorStr = v:GenerateHexColor();
end