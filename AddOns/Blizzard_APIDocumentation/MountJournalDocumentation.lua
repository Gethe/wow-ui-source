local MountJournal =
{
	Name = "MountJournal",
	Type = "System",
	Namespace = "C_MountJournal",

	Functions =
	{
		{
			Name = "ClearFanfare",
			Type = "Function",

			Arguments =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClearRecentFanfares",
			Type = "Function",
		},
		{
			Name = "Dismiss",
			Type = "Function",
		},
		{
			Name = "GetCollectedFilterSetting",
			Type = "Function",

			Arguments =
			{
				{ Name = "filterIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDisplayedMountAllCreatureDisplayInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "mountIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "allDisplayInfo", Type = "table", InnerType = "MountCreatureDisplayInfo", Nilable = false },
			},
		},
		{
			Name = "GetDisplayedMountInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "displayIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "isActive", Type = "bool", Nilable = false },
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "sourceType", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "isFactionSpecific", Type = "bool", Nilable = false },
				{ Name = "faction", Type = "number", Nilable = true },
				{ Name = "shouldHideOnChar", Type = "bool", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "mountID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDisplayedMountInfoExtra",
			Type = "Function",

			Arguments =
			{
				{ Name = "mountIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureDisplayInfoID", Type = "number", Nilable = true },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "source", Type = "string", Nilable = false },
				{ Name = "isSelfMount", Type = "bool", Nilable = false },
				{ Name = "mountTypeID", Type = "number", Nilable = false },
				{ Name = "uiModelSceneID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetIsFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "mountIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "canSetFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetMountAllCreatureDisplayInfoByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "allDisplayInfo", Type = "table", InnerType = "MountCreatureDisplayInfo", Nilable = false },
			},
		},
		{
			Name = "GetMountFromSpell",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mountID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMountIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "mountIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetMountInfoByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "isActive", Type = "bool", Nilable = false },
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "sourceType", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "isFactionSpecific", Type = "bool", Nilable = false },
				{ Name = "faction", Type = "number", Nilable = true },
				{ Name = "shouldHideOnChar", Type = "bool", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "mountID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMountInfoExtraByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureDisplayInfoID", Type = "number", Nilable = true },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "source", Type = "string", Nilable = false },
				{ Name = "isSelfMount", Type = "bool", Nilable = false },
				{ Name = "mountTypeID", Type = "number", Nilable = false },
				{ Name = "uiModelSceneID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumDisplayedMounts",
			Type = "Function",

			Returns =
			{
				{ Name = "numMounts", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumMounts",
			Type = "Function",

			Returns =
			{
				{ Name = "numMounts", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumMountsNeedingFanfare",
			Type = "Function",

			Returns =
			{
				{ Name = "numMountsNeedingFanfare", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsSourceChecked",
			Type = "Function",

			Arguments =
			{
				{ Name = "filterIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValidSourceFilter",
			Type = "Function",

			Arguments =
			{
				{ Name = "filterIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "NeedsFanfare",
			Type = "Function",

			Arguments =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "needsFanfare", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Pickup",
			Type = "Function",

			Arguments =
			{
				{ Name = "displayIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetAllSourceFilters",
			Type = "Function",

			Arguments =
			{
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCollectedFilterSetting",
			Type = "Function",

			Arguments =
			{
				{ Name = "filterIndex", Type = "number", Nilable = false },
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetIsFavorite",
			Type = "Function",

			Arguments =
			{
				{ Name = "mountIndex", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSearch",
			Type = "Function",

			Arguments =
			{
				{ Name = "searchValue", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetSourceFilter",
			Type = "Function",

			Arguments =
			{
				{ Name = "filterIndex", Type = "number", Nilable = false },
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SummonByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "MountJournalSearchUpdated",
			Type = "Event",
			LiteralName = "MOUNT_JOURNAL_SEARCH_UPDATED",
		},
		{
			Name = "MountJournalUsabilityChanged",
			Type = "Event",
			LiteralName = "MOUNT_JOURNAL_USABILITY_CHANGED",
		},
		{
			Name = "NewMountAdded",
			Type = "Event",
			LiteralName = "NEW_MOUNT_ADDED",
			Payload =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "MountCreatureDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "creatureDisplayID", Type = "number", Nilable = false },
				{ Name = "isVisible", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MountJournal);