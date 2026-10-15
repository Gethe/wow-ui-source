ClassVisuals = {
	[1]	 --[[Warrior--]]	 = { activationFX = "talents-animations-class-warrior", panOffset = { x = 60, y = 31 }, },
	[2]  --[[Paladin--]] 	 = { activationFX = "talents-animations-class-paladin", panOffset = { x = 60, y = 31 }, },
	[3]  --[[Hunter--]] 	 = { activationFX = "talents-animations-class-hunter", panOffset = { x = 60, y = 31 }, },
	[4]  --[[Rogue--]] 		 = { activationFX = "talents-animations-class-rogue", panOffset = { x = 60, y = 31 }, },
	[5]  --[[Priest--]] 	 = { activationFX = "talents-animations-class-priest", panOffset = { x = 60, y = 31 }, },
	[7]  --[[Shaman--]] 	 = { activationFX = "talents-animations-class-shaman", panOffset = { x = 60, y = 31 }, },
	[8]  --[[Mage--]] 		 = { activationFX = "talents-animations-class-mage", panOffset = { x = 60, y = 31 }, },
	[9]  --[[Warlock--]] 	 = { activationFX = "talents-animations-class-warlock", panOffset = { x = 60, y = 31 }, },
	[11] --[[Druid--]] 		 = { activationFX = "talents-animations-class-druid", panOffset = { x = 60, y = 31 }, },
};

SpecializationVisuals = {
	-- Mage
	[1482] = { background = "talent-background-mage", heroContainerOffset = 0, useAtlasSize = TextureKitConstants.IgnoreAtlasSize },

	-- Druid
	[1484] = { background = "talent-background-druid", heroContainerOffset = 0, useAtlasSize = TextureKitConstants.IgnoreAtlasSize },

	-- Hunter
	[1485] = { background = "talent-background-hunter", heroContainerOffset = 0, useAtlasSize = TextureKitConstants.IgnoreAtlasSize },

	-- Paladin
	[1486] = { background = "talent-background-paladin", heroContainerOffset = 0, useAtlasSize = TextureKitConstants.IgnoreAtlasSize },

	-- Priest
	[1487] = { background = "talent-background-priest", heroContainerOffset = 0, useAtlasSize = TextureKitConstants.IgnoreAtlasSize },

	-- Rogue
	[1488] = { background = "talent-background-rogue", heroContainerOffset = 0, useAtlasSize = TextureKitConstants.IgnoreAtlasSize },

	-- Shaman
	[1489] = { background = "talent-background-shaman", heroContainerOffset = 0, useAtlasSize = TextureKitConstants.IgnoreAtlasSize },

	-- Warlock
	[1490] = { background = "talent-background-warlock", heroContainerOffset = 0, useAtlasSize = TextureKitConstants.IgnoreAtlasSize },

	-- Warrior
	[1491] = { background = "talent-background-warrior", heroContainerOffset = 0, useAtlasSize = TextureKitConstants.IgnoreAtlasSize },
};

ClassTalentUtilSpendSoundKitByEntryTypeOverrides = {
	-- Camelot uses the SpendSquare for the visual, but doesn't want the "major" sound to play when allocating points.
	[Enum.TraitNodeEntryType.SpendSquare] = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND,
};
