PartyUtil = {};

local unitTags = { "player", "party1", "party2", "party3", "party4" };

function PartyUtil.GetMinLevel()
	local minLevel = math.huge;
	for index, unit in ipairs(unitTags) do
		if UnitExists(unit) then
			minLevel = math.min(minLevel, UnitLevel(unit));
		end
	end
	return minLevel;
end