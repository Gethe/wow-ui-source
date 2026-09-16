COMBATLOG_DEFAULT_COLORS = {
	-- Unit names
	unitColoring = {
		[COMBATLOG_FILTER_MINE] 		= {a=1.0,r=0.70,g=0.70,b=0.70}; --{a=1.0,r=0.14,g=1.00,b=0.15};
		[COMBATLOG_FILTER_MY_PET] 		= {a=1.0,r=0.70,g=0.70,b=0.70}; --{a=1.0,r=0.14,g=0.80,b=0.15};
		[COMBATLOG_FILTER_FRIENDLY_UNITS] 	= {a=1.0,r=0.34,g=0.64,b=1.00};
		[COMBATLOG_FILTER_HOSTILE_UNITS] 	= {a=1.0,r=0.75,g=0.05,b=0.05};
		[COMBATLOG_FILTER_HOSTILE_PLAYERS] 	= {a=1.0,r=0.75,g=0.05,b=0.05};
		[COMBATLOG_FILTER_NEUTRAL_UNITS] 	= {a=1.0,r=0.75,g=0.05,b=0.05}; -- {a=1.0,r=0.80,g=0.80,b=0.14};
		[COMBATLOG_FILTER_UNKNOWN_UNITS] 	= {a=1.0,r=0.75,g=0.75,b=0.75};
	};
	-- School coloring
	schoolColoring = {
		[Enum.Damageclass.MaskNone]	= {a=1.0,r=1.00,g=1.00,b=1.00};
		[Enum.Damageclass.MaskPhysical]	= {a=1.0,r=1.00,g=1.00,b=0.00};
		[Enum.Damageclass.MaskHoly] 	= {a=1.0,r=1.00,g=0.90,b=0.50};
		[Enum.Damageclass.MaskFire] 	= {a=1.0,r=1.00,g=0.50,b=0.00};
		[Enum.Damageclass.MaskNature] 	= {a=1.0,r=0.30,g=1.00,b=0.30};
		[Enum.Damageclass.MaskFrost] 	= {a=1.0,r=0.50,g=1.00,b=1.00};
		[Enum.Damageclass.MaskShadow] 	= {a=1.0,r=0.50,g=0.50,b=1.00};
		[Enum.Damageclass.MaskArcane] 	= {a=1.0,r=1.00,g=0.50,b=1.00};
	};
	-- Defaults
	defaults = {
		spell = {a=1.0,r=1.00,g=1.00,b=1.00};
		damage = {a=1.0,r=1.00,g=1.00,b=0.00};
	};
	-- Line coloring
	eventColoring = {
	};

	-- Highlighted events
	highlightedEvents = {
		["PARTY_KILL"] = true;
	};
};
