-- Avoid directly referencing these tables outside of Blizzard_Colors,
-- instead preferring the various accessor methods in ColorManager.

ITEM_QUALITY_OVERRIDES = {
	[Enum.ItemQuality.Poor] = Enum.ColorOverride.ItemQualityPoor,
	[Enum.ItemQuality.Common] = Enum.ColorOverride.ItemQualityCommon,
	[Enum.ItemQuality.Uncommon] = Enum.ColorOverride.ItemQualityUncommon,
	[Enum.ItemQuality.Rare] = Enum.ColorOverride.ItemQualityRare,
	[Enum.ItemQuality.Epic] = Enum.ColorOverride.ItemQualityEpic,
	[Enum.ItemQuality.Legendary] = Enum.ColorOverride.ItemQualityLegendary,
	[Enum.ItemQuality.Artifact] = Enum.ColorOverride.ItemQualityArtifact,
	[Enum.ItemQuality.Heirloom] = Enum.ColorOverride.ItemQualityAccount
};

ITEM_QUALITY_COLORS = { };

WORLD_QUEST_QUALITY_COLORS = { };

FOLLOWER_QUALITY_COLORS = { };

BAG_ITEM_QUALITY_COLORS = {
	[Enum.ItemQuality.Common] = COMMON_GRAY_COLOR,
	[Enum.ItemQuality.Uncommon] = UNCOMMON_GREEN_COLOR,
	[Enum.ItemQuality.Rare] = RARE_BLUE_COLOR,
	[Enum.ItemQuality.Epic] = EPIC_PURPLE_COLOR,
	[Enum.ItemQuality.Legendary] = LEGENDARY_ORANGE_COLOR,
	[Enum.ItemQuality.Artifact] = ARTIFACT_GOLD_COLOR,
	[Enum.ItemQuality.Heirloom] = HEIRLOOM_BLUE_COLOR,
	[Enum.ItemQuality.WoWToken] = HEIRLOOM_BLUE_COLOR
};

AUCTION_HOUSE_ITEM_QUALITY_ICON_BORDER_ATLASES = {
	[Enum.ItemQuality.Poor] = "auctionhouse-itemicon-border-gray",
	[Enum.ItemQuality.Common] = "auctionhouse-itemicon-border-white",
	[Enum.ItemQuality.Uncommon] = "auctionhouse-itemicon-border-green",
	[Enum.ItemQuality.Rare] = "auctionhouse-itemicon-border-blue",
	[Enum.ItemQuality.Epic] = "auctionhouse-itemicon-border-purple",
	[Enum.ItemQuality.Legendary] = "auctionhouse-itemicon-border-orange",
	[Enum.ItemQuality.Artifact] = "auctionhouse-itemicon-border-artifact",
	[Enum.ItemQuality.Heirloom] = "auctionhouse-itemicon-border-account",
	[Enum.ItemQuality.WoWToken] = "auctionhouse-itemicon-border-account"
};

PROFESSIONS_ITEM_QUALITY_ICON_BORDER_ATLASES = {
	[Enum.ItemQuality.Common] = "Professions-Slot-Frame",
	[Enum.ItemQuality.Uncommon] = "Professions-Slot-Frame-Green",
	[Enum.ItemQuality.Rare] = "Professions-Slot-Frame-Blue",
	[Enum.ItemQuality.Epic] = "Professions-Slot-Frame-Epic",
	[Enum.ItemQuality.Legendary] = "Professions-Slot-Frame-Legendary"
};

NEW_ITEM_ATLAS_BY_QUALITY = {
	[Enum.ItemQuality.Poor] = "bags-glow-white",
	[Enum.ItemQuality.Common] = "bags-glow-white",
	[Enum.ItemQuality.Uncommon] = "bags-glow-green",
	[Enum.ItemQuality.Rare] = "bags-glow-blue",
	[Enum.ItemQuality.Epic] = "bags-glow-purple",
	[Enum.ItemQuality.Legendary] = "bags-glow-orange",
	[Enum.ItemQuality.Artifact] = "bags-glow-artifact",
	[Enum.ItemQuality.Heirloom] = "bags-glow-heirloom"
};

LOOT_BORDER_BY_QUALITY = {
	[Enum.ItemQuality.Common] = "loottoast-itemborder-white",
	[Enum.ItemQuality.Uncommon] = "loottoast-itemborder-green",
	[Enum.ItemQuality.Rare] = "loottoast-itemborder-blue",
	[Enum.ItemQuality.Epic] = "loottoast-itemborder-purple",
	[Enum.ItemQuality.Legendary] = "loottoast-itemborder-orange",
	[Enum.ItemQuality.Heirloom] = "loottoast-itemborder-heirloom",
	[Enum.ItemQuality.Artifact] = "loottoast-itemborder-artifact"
};

LOOTUPGRADEFRAME_QUALITY_TEXTURES = {
	[Enum.ItemQuality.Uncommon]	= {
		border = "loottoast-itemborder-green",
		arrow = "loottoast-arrow-green"
	},
	[Enum.ItemQuality.Rare]	= {
		border = "loottoast-itemborder-blue",
		arrow = "loottoast-arrow-blue"
	},
	[Enum.ItemQuality.Epic]	= {
		border = "loottoast-itemborder-purple",
		arrow = "loottoast-arrow-purple"
	},
	[Enum.ItemQuality.Legendary] = {
		border = "loottoast-itemborder-orange",
		arrow = "loottoast-arrow-orange"
	}
};

GARRISON_FOLLOWER_QUALITY_TEXTURE_SUFFIXES = {
	[Enum.ItemQuality.Uncommon] = "Uncommon",
	[Enum.ItemQuality.Epic] = "Epic",
	[Enum.ItemQuality.Rare] = "Rare"
};

WARDROBE_SETS_ITEM_QUALITY_ICON_BORDER_ATLASES = {
	[Enum.ItemQuality.Uncommon] = "loottab-set-itemborder-green",
	[Enum.ItemQuality.Rare] = "loottab-set-itemborder-blue",
	[Enum.ItemQuality.Epic] = "loottab-set-itemborder-purple"
};

LOOT_JOURNAL_ITEM_SETS_QUALITY_ICON_BORDER_ATLASES = {
	[Enum.ItemQuality.Uncommon] = "loottab-set-itemborder-green",
	[Enum.ItemQuality.Rare] = "loottab-set-itemborder-blue",
	[Enum.ItemQuality.Epic] = "loottab-set-itemborder-purple"
};

DRESS_UP_FRAME_QUALITY_COLORS = {
	[Enum.ItemQuality.Poor] = "gray",
	[Enum.ItemQuality.Common] = "white",
	[Enum.ItemQuality.Uncommon] = "green",
	[Enum.ItemQuality.Rare] = "blue",
	[Enum.ItemQuality.Epic] = "purple",
	[Enum.ItemQuality.Legendary] = "orange",
	[Enum.ItemQuality.Artifact] = "artifact",
	[Enum.ItemQuality.Heirloom] = "account"
};

GARRISON_SHIPYARD_FOLLOWER_QUALITY_ATLASES = {
	[Enum.ItemQuality.Uncommon] = "ShipMission_BoatRarity-Uncommon",
	[Enum.ItemQuality.Rare] = "ShipMission_BoatRarity-Rare",
	[Enum.ItemQuality.Epic] = "ShipMission_BoatRarity-Epic"
};

SPELL_DISPLAY_BORDER_COLOR_ATLASES = {
	[Enum.ItemQuality.Common] = "wowlabs-in-world-item-common",
	[Enum.ItemQuality.Uncommon] = "wowlabs-in-world-item-uncommon",
	[Enum.ItemQuality.Rare] = "wowlabs-in-world-item-rare",
	[Enum.ItemQuality.Epic] = "wowlabs-in-world-item-epic",
	[Enum.ItemQuality.Legendary] = "wowlabs-in-world-item-legendary"
};

PLAYER_CHOICE_ATLAS_POSTFIXES = {
	[Enum.ItemQuality.Common] = {
		circleBorder = "-border",
		portraitBackgroundGlow1 = "-portrait-qualitygeneric-01",
		portraitBackgroundGlow2 = "-portrait-qualitygeneric-02",
		portraitBackgroundTorghast = "",
		portraitBackgroundCypher = "-Common"
	},
	[Enum.ItemQuality.Uncommon] = {
		circleBorder = "-QualityUncommon-border",
		portraitBackgroundGlow1 = "-portrait-qualityuncommon-01",
		portraitBackgroundGlow2 = "-portrait-qualityuncommon-02",
		portraitBackgroundTorghast = "-QualityUncommon",
		portraitBackgroundCypher = "-Uncommon"
	},
	[Enum.ItemQuality.Rare] = {
		circleBorder = "-QualityRare-border",
		portraitBackgroundGlow1 = "-portrait-qualityrare-01",
		portraitBackgroundGlow2 = "-portrait-qualityrare-02",
		portraitBackgroundTorghast = "-QualityRare",
		portraitBackgroundCypher = "-Rare"
	},
	[Enum.ItemQuality.Epic] = {
		circleBorder = "-QualityEpic-border",
		portraitBackgroundGlow1 = "-portrait-qualityepic-01",
		portraitBackgroundGlow2 = "-portrait-qualityepic-02",
		portraitBackgroundTorghast = "-QualityEpic",
		portraitBackgroundCypher = "-Epic"
	}
};

MATERIAL_TEXT_COLOR_TABLE["Progenitor"] = PROGENITOR_MATERIAL_TEXT_COLOR;
MATERIAL_TITLETEXT_COLOR_TABLE["Progenitor"] = PROGENITOR_MATERIAL_TITLETEXT_COLOR;