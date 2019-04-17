-- These are functions that were deprecated in 8.2.0, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

do
	-- Use PVPMatchUtil.IsRatedBattleground() instead
	IsRatedBattleground = PVPMatchUtil.IsRatedBattleground;
	-- Use PVPMatchUtil.IsRatedArena() instead
	IsRatedArena = PVPMatchUtil.IsRatedArena;
	-- Use C_PvP.IsRatedMap() instead
	IsRatedMap =  C_PvP.IsRatedMap;
end