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

			Returns =
			{
				{ Name = "canChange", Type = "bool", Nilable = false },
				{ Name = "canAdd", Type = "bool", Nilable = false },
				{ Name = "changeError", Type = "string", Nilable = false },
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
			Name = "HasUnspentTalentPoints",
			Type = "Function",

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
				{ Name = "importError", Type = "string", Nilable = false },
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
				{ Name = "ranksPurchased", Type = "number", Nilable = false },
				{ Name = "selectionEntryID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ClassTalents);