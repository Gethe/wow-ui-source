--[[ 
PowerBarColor attributes
======================================================
r, g, b: [numbers 0-1]  -- Red, green, and blue values that define the type's color, typically used by UI that still uses flat colors rather than resource-specific atlases (ex: nameplate resource bars)
atlas: [string]  -- Full name of the texture atlas to use for this power type's status bars
atlasElement: [string]  -- Partial name of this type's texture atlas; The full atlas name is determined at runtime based on what kind of UnitFrame the bar is in (see UnitFrameManaBar_UpdateType in UnitFrame.lua)
hasClassResourceVariant: [bool]  -- If true, the full logic for evaluating atlasElement will also check whether the power is being displayed as third "alternate" resource type and use a slightly different atlas
predictionColor: [global color]  -- Color to use for the cost prediction bar segments used for spells that cost this power type and have a cast time
fullPowerAnim: [bool]  -- If true, shows an animated pulse on the power bar when at or above max power
spark: [table]  -- Options that for a spark (or endcap) visual that displays at the end of the fill bar if defined
	atlas: [string] -- Name of the atlas to use for the spark
	xOffset: [number] -- Optional, x anchor offset from the RIGHT edge of the fill bar
	barHeight: [number] -- Fill bar height the spark was designed for; Used for adjusting the spark's scale to fit the bar's actual current height
	showAtMax: [bool] -- If true, spark stays visible when bar is at maximum fill, otherwise it's hidden
]]--

PowerBarColor = {};
PowerBarColor["MANA"] =				{ r = 0.00, g = 0.00, b = 1.00, atlasElementName="Mana", hasClassResourceVariant = true, predictionColor = POWERBAR_PREDICTION_COLOR_MANA };
PowerBarColor["RAGE"] =				{ r = 1.00, g = 0.00, b = 0.00, atlasElementName="Rage", predictionColor = POWERBAR_PREDICTION_COLOR_RAGE, fullPowerAnim=true };
PowerBarColor["FOCUS"] =			{ r = 1.00, g = 0.50, b = 0.25, atlasElementName="Focus", predictionColor = POWERBAR_PREDICTION_COLOR_FOCUS, fullPowerAnim=true };
PowerBarColor["ENERGY"] =			{ r = 1.00, g = 1.00, b = 0.00, atlasElementName="Energy", hasClassResourceVariant = true, predictionColor = POWERBAR_PREDICTION_COLOR_ENERGY, fullPowerAnim=true };
PowerBarColor["COMBO_POINTS"] =		{ r = 1.00, g = 0.96, b = 0.41 };
PowerBarColor["RUNES"] =			{ r = 0.50, g = 0.50, b = 0.50 };
PowerBarColor["RUNIC_POWER"] =		{ r = 0.00, g = 0.82, b = 1.00, atlasElementName="RunicPower", predictionColor = POWERBAR_PREDICTION_COLOR_RUNIC_POWER, fullPowerAnim=true };
PowerBarColor["SOUL_SHARDS"] =		{ r = 0.50, g = 0.32, b = 0.55 };
PowerBarColor["LUNAR_POWER"] =		{ r = 0.30, g = 0.52, b = 0.90, atlas="Unit_Druid_AstralPower_Fill", predictionColor = POWERBAR_PREDICTION_COLOR_LUNAR_POWER, spark = { atlas = "Unit_Druid_AstralPower_EndCap", xOffset = 1, barHeight = 10, showAtMax = true } };
PowerBarColor["HOLY_POWER"] =		{ r = 0.95, g = 0.90, b = 0.60 };
PowerBarColor["MAELSTROM"] =		{ r = 0.00, g = 0.50, b = 1.00, atlas = "Unit_Shaman_Maelstrom_Fill", predictionColor = POWERBAR_PREDICTION_COLOR_MAELSTROM, fullPowerAnim=true, spark = { atlas = "Unit_Shaman_Maelstrom_EndCap", barHeight = 10, showAtMax = true } };
PowerBarColor["INSANITY"] =			{ r = 0.40, g = 0.00, b = 0.80, atlas = "Unit_Priest_Insanity_Fill", predictionColor = POWERBAR_PREDICTION_COLOR_INSANITY, spark = { atlas = "Unit_Priest_Insanity_EndCap", xOffset = 1, barHeight = 10, showAtMax = false } };
PowerBarColor["CHI"] =				{ r = 0.71, g = 1.00, b = 0.92 };
PowerBarColor["ARCANE_CHARGES"] =	{ r = 0.10, g = 0.10, b = 0.98 };
PowerBarColor["FURY"] =				{ r = 0.788, g = 0.259, b = 0.992, atlas = "Unit_DemonHunter_Fury_Fill", predictionColor = POWERBAR_PREDICTION_COLOR_FURY, fullPowerAnim=true, spark = { atlas = "Unit_DemonHunter_Fury_EndCap", xOffset = 1, barHeight = 10, showAtMax = true } };
PowerBarColor["PAIN"] =				{ r = 255/255, g = 156/255, b = 0, atlas = "_DemonHunter-DemonicPainBar", predictionColor = POWERBAR_PREDICTION_COLOR_PAIN, fullPowerAnim=true };
-- vehicle colors
PowerBarColor["AMMOSLOT"] = 		{ r = 0.80, g = 0.60, b = 0.00 };
PowerBarColor["FUEL"] = 			{ r = 0.0, g = 0.55, b = 0.5 };
-- alternate power bar colors
PowerBarColor["EBON_MIGHT"] = { r = 0.9, g = 0.55, b = 0.3, atlas = "Unit_Evoker_EbonMight_Fill" };
PowerBarColor["STAGGER"] = {
	green = 	{ r = 0.52, g = 1.0, b = 0.52, atlas = "Unit_Monk_Stagger_Fill_Green" },
	yellow = 	{ r = 1.0, g = 0.98, b = 0.72, atlas = "Unit_Monk_Stagger_Fill_Yellow" },
	red = 		{ r = 1.0, g = 0.42, b = 0.42, atlas = "Unit_Monk_Stagger_Fill_Red" },
	spark = 	{ atlas = "Unit_Monk_Stagger_EndCap", barHeight = 10, xOffset = 1, showAtMax = true }
};

-- these are mostly needed for a fallback case (in case the code tries to index a power token that is missing from the table,
-- it will try to index by power type instead)
PowerBarColor[0] = PowerBarColor["MANA"];
PowerBarColor[1] = PowerBarColor["RAGE"];
PowerBarColor[2] = PowerBarColor["FOCUS"];
PowerBarColor[3] = PowerBarColor["ENERGY"];
PowerBarColor[4] = PowerBarColor["CHI"];
PowerBarColor[5] = PowerBarColor["RUNES"];
PowerBarColor[6] = PowerBarColor["RUNIC_POWER"];
PowerBarColor[7] = PowerBarColor["SOUL_SHARDS"];
PowerBarColor[8] = PowerBarColor["LUNAR_POWER"];
PowerBarColor[9] = PowerBarColor["HOLY_POWER"];
PowerBarColor[11] = PowerBarColor["MAELSTROM"];
PowerBarColor[13] = PowerBarColor["INSANITY"];
PowerBarColor[17] = PowerBarColor["FURY"];
PowerBarColor[18] = PowerBarColor["PAIN"];

function GetPowerBarColor(powerType)
	return PowerBarColor[powerType];
end