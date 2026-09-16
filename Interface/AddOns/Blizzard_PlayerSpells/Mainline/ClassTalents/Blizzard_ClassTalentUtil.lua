-- panOffsets are required to account for minor differences in the positioning between different classes.
ClassVisuals = {
	[1]	 --[[Warrior--]]	 = { activationFX = "talents-animations-class-warrior", panOffset = { x = 60, y = 31 }, },
	[2]  --[[Paladin--]] 	 = { activationFX = "talents-animations-class-paladin", panOffset = { x = -60, y = -29 }, },
	[3]  --[[Hunter--]] 	 = { activationFX = "talents-animations-class-hunter", panOffset = { x = 0, y = -29 }, },
	[4]  --[[Rogue--]] 		 = { activationFX = "talents-animations-class-rogue", panOffset = { x = 30, y = -29 }, },
	[5]  --[[Priest--]] 	 = { activationFX = "talents-animations-class-priest", panOffset = { x = -30, y = -29 }, },
	[6]  --[[DeathKnight--]] = { activationFX = "talents-animations-class-deathknight", panOffset = { x = 0, y = 1 }, },
	[7]  --[[Shaman--]] 	 = { activationFX = "talents-animations-class-shaman", panOffset = { x = 0, y = 1 }, },
	[8]  --[[Mage--]] 		 = { activationFX = "talents-animations-class-mage", panOffset = { x = 30, y = -29 }, },
	[9]  --[[Warlock--]] 	 = { activationFX = "talents-animations-class-warlock", panOffset = { x = 0, y = 1 }, },
	[10] --[[Monk--]] 		 = { activationFX = "talents-animations-class-monk", panOffset = { x = 0, y = -29 }, },
	[11] --[[Druid--]] 		 = { activationFX = "talents-animations-class-druid", panOffset = { x = 30, y = -29 }, },
	[12] --[[DemonHunter--]] = { activationFX = "talents-animations-class-demonhunter", panOffset = { x = 30, y = -29 }, },
	[13] --[[Evoker--]]		 = { activationFX = "talents-animations-class-evoker", panOffset = { x = 30, y = -29 }, },
};

SpecializationVisuals = {
	-- DK
	[250] = { background = "talents-background-deathknight-blood", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[251] = { background = "talents-background-deathknight-frost", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[252] = { background = "talents-background-deathknight-unholy", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- DH
	[577] =  { background = "talents-background-demonhunter-havoc", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[581] =  { background = "talents-background-demonhunter-vengeance", heroContainerOffset = -45, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[1480] = { background = "talents-background-demonhunter-devourer", heroContainerOffset = 0, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- Druid
	[102] = { background = "talents-background-druid-balance", heroContainerOffset = 15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[103] = { background = "talents-background-druid-feral", heroContainerOffset = 15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[104] = { background = "talents-background-druid-guardian", heroContainerOffset = 15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[105] = { background = "talents-background-druid-restoration", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- Evoker
	[1467] = { background = "talents-background-evoker-devastation", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[1468] = { background = "talents-background-evoker-preservation", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[1473] = { background = "talents-background-evoker-augmentation", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- Hunter
	[253] = { background = "talents-background-hunter-beastmastery", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[254] = { background = "talents-background-hunter-marksmanship", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[255] = { background = "talents-background-hunter-survival", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- Mage
	[62] = { background = "talents-background-mage-arcane", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[63] = { background = "talents-background-mage-fire", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[64] = { background = "talents-background-mage-frost", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- Monk
	[268] = { background = "talents-background-monk-brewmaster", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[269] = { background = "talents-background-monk-windwalker", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[270] = { background = "talents-background-monk-mistweaver", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- Paladin
	[65] = { background = "talents-background-paladin-holy", heroContainerOffset = -45, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[66] = { background = "talents-background-paladin-protection", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[70] = { background = "talents-background-paladin-retribution", heroContainerOffset = -45, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- Priest
	[256] = { background = "talents-background-priest-discipline", heroContainerOffset = 15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[257] = { background = "talents-background-priest-holy", heroContainerOffset = 15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[258] = { background = "talents-background-priest-shadow", heroContainerOffset = 15, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- Rogue
	[259] = { background = "talents-background-rogue-assassination", heroContainerOffset = -45, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[260] = { background = "talents-background-rogue-outlaw", heroContainerOffset = -45, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[261] = { background = "talents-background-rogue-subtlety", heroContainerOffset = -45, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- Shaman
	[262] = { background = "talents-background-shaman-elemental", heroContainerOffset = 15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[263] = { background = "talents-background-shaman-enhancement", heroContainerOffset = 15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[264] = { background = "talents-background-shaman-restoration", heroContainerOffset = 15, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- Warlock
	[265] = { background = "talents-background-warlock-affliction", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[266] = { background = "talents-background-warlock-demonology", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[267] = { background = "talents-background-warlock-destruction", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },

	-- Warrior
	[71] = { background = "talents-background-warrior-arms", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[72] = { background = "talents-background-warrior-fury", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
	[73] = { background = "talents-background-warrior-protection", heroContainerOffset = -15, useAtlasSize = TextureKitConstants.UseAtlasSize },
};
