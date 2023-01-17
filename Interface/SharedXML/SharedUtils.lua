-- For these races, the names are shortened for the atlas
local fixedRaceAtlasNames = {
    ["highmountaintauren"] = "highmountain",
    ["lightforgeddraenei"] = "lightforged",
    ["scourge"] = "undead",
    ["zandalaritroll"] = "zandalari",
};

function GetRaceAtlas(raceName, gender, useHiRez)
	if (fixedRaceAtlasNames[raceName]) then
		raceName = fixedRaceAtlasNames[raceName];
	end
	local formatingString = useHiRez and "raceicon128-%s-%s" or "raceicon-%s-%s";
	return formatingString:format(raceName, gender);
end