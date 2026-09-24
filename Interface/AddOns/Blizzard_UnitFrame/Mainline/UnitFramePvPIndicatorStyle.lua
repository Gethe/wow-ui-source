local _addonName, addonTable = ...;

-- Consumed by UnitFrameUtil.lua as load-time upvalues; never exposed on UnitFrameUtil so tainted code cannot mutate it.
addonTable.PvPIndicatorStyle = {
	hordeIconAtlas = "UI-HUD-UnitFrame-Player-PVP-HordeIcon",
	allianceIconAtlas = "UI-HUD-UnitFrame-Player-PVP-AllianceIcon",
	ffaIconAtlas = "UI-HUD-UnitFrame-Player-PVP-FFAIcon",
	neutralPrestigePortraitAtlas = "honorsystem-portrait-neutral",
	factionPrestigePortraitAtlasPrefix = "honorsystem-portrait-",
	supportsPrestige = true,
	usesBackground = false,
};
