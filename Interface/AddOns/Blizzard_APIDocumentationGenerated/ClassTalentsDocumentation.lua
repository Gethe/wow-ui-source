local ClassTalents =
{
	Name = "ClassTalents",
	Type = "System",
	Namespace = "C_ClassTalents",

	Functions =
	{
		{
			Name = "CanChangeTalents",
			Type = "Function",
			Documentation = { "Returns true only if the player has staged changes and can commit their talents in their current state." },

			Returns =
			{
				{ Name = "canChange", Type = "bool", Nilable = false },
				{ Name = "canAdd", Type = "bool", Nilable = false },
				{ Name = "changeError", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CanCreateNewConfig",
			Type = "Function",

			Returns =
			{
				{ Name = "canCreate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanEditTalents",
			Type = "Function",
			Documentation = { "Returns true if the player could switch talents if they staged a proper loadout." },

			Returns =
			{
				{ Name = "canEdit", Type = "bool", Nilable = false },
				{ Name = "changeError", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "CommitConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "savedConfigID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DeleteConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetActiveConfigID",
			Type = "Function",

			Returns =
			{
				{ Name = "activeConfigID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetActiveHeroTalentSpec",
			Type = "Function",
			Documentation = { "Returns the SubTreeID of the player's active Hero Talent Specialization SubTree." },

			Returns =
			{
				{ Name = "heroSpecID", Type = "number", Nilable = true, Documentation = { "SubTreeID of the player's active Hero Talent Specialization or nil if no Specialization is active." } },
			},
		},
		{
			Name = "GetConfigIDsBySpecID",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "configIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetHasStarterBuild",
			Type = "Function",

			Returns =
			{
				{ Name = "hasStarterBuild", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetHeroTalentSpecsForClassSpec",
			Type = "Function",
			Documentation = { "Returns the SubTreeIDs of the Hero Talent Specializations available to a Class Specialization and config; Returns nothing if none available" },

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = true, Documentation = { "If not supplied, defaults to the player's active config" } },
				{ Name = "classSpecID", Type = "number", Nilable = true, Documentation = { "If not supplied, defaults to the player's active spec" } },
			},

			Returns =
			{
				{ Name = "subTreeIDs", Type = "table", InnerType = "number", Nilable = true, Documentation = { "SubTreeIDs of each Hero Talent Specialization" } },
				{ Name = "requiredPlayerLevel", Type = "number", Nilable = true, Documentation = { "The player level at which one of the Hero Talent Specializations can be activated" } },
			},
		},
		{
			Name = "GetLastSelectedSavedConfigID",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "configID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetNextStarterBuildPurchase",
			Type = "Function",

			Returns =
			{
				{ Name = "nodeID", Type = "number", Nilable = true },
				{ Name = "entryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetStarterBuildActive",
			Type = "Function",

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetTraitTreeForSpec",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "treeID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "HasUnspentHeroTalentPoints",
			Type = "Function",
			Documentation = { "Returns whether the player has any unspent talent points in their active hero talent tree. If hasUnspentPoints is true, numHeroPoints will be greater than zero." },

			Returns =
			{
				{ Name = "hasUnspentPoints", Type = "bool", Nilable = false },
				{ Name = "numHeroPoints", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasUnspentTalentPoints",
			Type = "Function",
			Documentation = { "Returns whether the player has any unspent talent points in their class or spec talent trees. If hasUnspentPoints is true, the number of unspent points for at least one of the trees will be greater than zero. Hero talent points are not included by this function." },

			Returns =
			{
				{ Name = "hasUnspentPoints", Type = "bool", Nilable = false },
				{ Name = "numClassPoints", Type = "number", Nilable = false },
				{ Name = "numSpecPoints", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ImportLoadout",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "entries", Type = "table", InnerType = "ImportLoadoutEntryInfo", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
				{ Name = "importError", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "InitializeViewLoadout",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsConfigPopulated",
			Type = "Function",
			Documentation = { "New configs may or may not be populated and ready to load immediately after creation. Avoid calling for configs intentionally created empty." },

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPopulated", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LoadConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "autoApply", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "LoadConfigResult", Nilable = false },
				{ Name = "changeError", Type = "string", Nilable = true },
				{ Name = "newLearnedNodeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "RenameConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RequestNewConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SaveConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetStarterBuildActive",
			Type = "Function",

			Arguments =
			{
				{ Name = "active", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "LoadConfigResult", Nilable = false },
			},
		},
		{
			Name = "SetUsesSharedActionBars",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "usesShared", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UpdateLastSelectedSavedConfigID",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "configID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ViewLoadout",
			Type = "Function",

			Arguments =
			{
				{ Name = "entries", Type = "table", InnerType = "ImportLoadoutEntryInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ActiveCombatConfigChanged",
			Type = "Event",
			LiteralName = "ACTIVE_COMBAT_CONFIG_CHANGED",
			Payload =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SelectedLoadoutChanged",
			Type = "Event",
			LiteralName = "SELECTED_LOADOUT_CHANGED",
		},
		{
			Name = "SpecializationChangeCastFailed",
			Type = "Event",
			LiteralName = "SPECIALIZATION_CHANGE_CAST_FAILED",
		},
		{
			Name = "StarterBuildActivationFailed",
			Type = "Event",
			LiteralName = "STARTER_BUILD_ACTIVATION_FAILED",
		},
	},

	Tables =
	{
		{
			Name = "LoadConfigResult",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Error", Type = "LoadConfigResult", EnumValue = 0 },
				{ Name = "NoChangesNecessary", Type = "LoadConfigResult", EnumValue = 1 },
				{ Name = "LoadInProgress", Type = "LoadConfigResult", EnumValue = 2 },
				{ Name = "Ready", Type = "LoadConfigResult", EnumValue = 3 },
			},
		},
		{
			Name = "ImportLoadoutEntryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "nodeID", Type = "number", Nilable = false },
				{ Name = "ranksGranted", Type = "number", Nilable = false },
				{ Name = "ranksPurchased", Type = "number", Nilable = false },
				{ Name = "selectionEntryID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ClassTalents);