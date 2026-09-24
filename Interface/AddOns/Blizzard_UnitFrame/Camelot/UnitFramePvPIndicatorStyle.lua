local _addonName, addonTable = ...;

-- Consumed by UnitFrameUtil.lua as load-time upvalues; never exposed on UnitFrameUtil so tainted code cannot mutate it.
addonTable.PvPIndicatorStyle = {
	hordeIconAtlas = "UI-HUD-UnitFrame-SmallCircle-Horde",
	allianceIconAtlas = "UI-HUD-UnitFrame-SmallCircle-Alliance",
	ffaIconAtlas = "UI-HUD-UnitFrame-Player-PVP-FFAIcon",
	-- Camelot has no prestige art, so honor rewards fall through to the plain faction icon.
	neutralPrestigePortraitAtlas = "",
	factionPrestigePortraitAtlasPrefix = "",
	supportsPrestige = false,
	usesBackground = true,
};
