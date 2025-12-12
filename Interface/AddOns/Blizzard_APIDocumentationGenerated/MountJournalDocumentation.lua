local MountJournal =
{
	Name = "MountJournal",
	Type = "System",
	Namespace = "C_MountJournal",
	Environment = "All",

	Functions =
	{
		{
			Name = "ApplyMountEquipment",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "canContinue", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AreMountEquipmentEffectsSuppressed",
			Type = "Function",

			Returns =
			{
				{ Name = "areEffectsSuppressed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearFanfare",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetAllCreatureDisplayIDsForMountID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureDisplayIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetAppliedMountEquipmentID",
			Type = "Function",

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCollectedDragonridingMounts",
			Type = "Function",

			Returns =
			{
				{ Name = "mountIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetCollectedFilterSetting",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filterIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDisplayedMountAllCreatureDisplayInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mountIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "allDisplayInfo", Type = "table", InnerType = "MountCreatureDisplayInfo", Nilable = false },
			},
		},
		{
			Name = "GetDisplayedMountID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "displayIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDisplayedMountInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "displayIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "isActive", Type = "bool", Nilable = false },
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "sourceType", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "isFactionSpecific", Type = "bool", Nilable = false },
				{ Name = "faction", Type = "PvPFaction", Nilable = true },
				{ Name = "shouldHideOnChar", Type = "bool", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "mountID", Type = "number", Nilable = false },
				{ Name = "isSteadyFlight", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDisplayedMountInfoExtra",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mountIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureDisplayInfoID", Type = "number", Nilable = true },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "source", Type = "cstring", Nilable = false },
				{ Name = "isSelfMount", Type = "bool", Nilable = false },
				{ Name = "mountTypeID", Type = "number", Nilable = false },
				{ Name = "uiModelSceneID", Type = "number", Nilable = false },
				{ Name = "animID", Type = "number", Nilable = false },
				{ Name = "spellVisualKitID", Type = "number", Nilable = false },
				{ Name = "disablePlayerMountPreview", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDynamicFlightModeSpellID",
			Type = "Function",

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetIsFavorite",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mountIndex", Type = "luaIndex", Nilable = false },
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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetMountEquipmentUnlockLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMountFromItem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mountID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMountFromSpell",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

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
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "isActive", Type = "bool", Nilable = false },
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "sourceType", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "isFactionSpecific", Type = "bool", Nilable = false },
				{ Name = "faction", Type = "PvPFaction", Nilable = true },
				{ Name = "shouldHideOnChar", Type = "bool", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "mountID", Type = "number", Nilable = false },
				{ Name = "isSteadyFlight", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetMountInfoExtraByID",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureDisplayInfoID", Type = "number", Nilable = true },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "source", Type = "cstring", Nilable = false },
				{ Name = "isSelfMount", Type = "bool", Nilable = false },
				{ Name = "mountTypeID", Type = "number", Nilable = false },
				{ Name = "uiModelSceneID", Type = "number", Nilable = false },
				{ Name = "animID", Type = "number", Nilable = false },
				{ Name = "spellVisualKitID", Type = "number", Nilable = false },
				{ Name = "disablePlayerMountPreview", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetMountLink",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mountCreatureDisplayInfoLink", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetMountUsabilityByID",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
				{ Name = "checkIndoors", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "useError", Type = "cstring", Nilable = true },
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
			Name = "IsDragonridingUnlocked",
			Type = "Function",
			Documentation = { "Returns whether the player has unlocked the ability to switch between Skyriding and steady flight styles for flying mounts ." },

			Returns =
			{
				{ Name = "isUnlocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsItemMountEquipment",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Determines if the item is mount equipment based on its class and subclass." },

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isMountEquipment", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMountEquipmentApplied",
			Type = "Function",

			Returns =
			{
				{ Name = "isApplied", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSourceChecked",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filterIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTypeChecked",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filterIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUsingDefaultFilters",
			Type = "Function",

			Returns =
			{
				{ Name = "isUsingDefaultFilters", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValidSourceFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filterIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValidTypeFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filterIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "NeedsFanfare",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "displayIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "PickupDynamicFlightMode",
			Type = "Function",
		},
		{
			Name = "SetAllSourceFilters",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAllTypeFilters",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCollectedFilterSetting",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filterIndex", Type = "luaIndex", Nilable = false },
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetDefaultFilters",
			Type = "Function",
		},
		{
			Name = "SetIsFavorite",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mountIndex", Type = "luaIndex", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetSearch",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "searchValue", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetSourceFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filterIndex", Type = "luaIndex", Nilable = false },
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetTypeFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filterIndex", Type = "luaIndex", Nilable = false },
				{ Name = "isChecked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SummonByID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mountID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SwapDynamicFlightMode",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "MountEquipmentApplyResult",
			Type = "Event",
			LiteralName = "MOUNT_EQUIPMENT_APPLY_RESULT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MountJournalSearchUpdated",
			Type = "Event",
			LiteralName = "MOUNT_JOURNAL_SEARCH_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "MountJournalUsabilityChanged",
			Type = "Event",
			LiteralName = "MOUNT_JOURNAL_USABILITY_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "NewMountAdded",
			Type = "Event",
			LiteralName = "NEW_MOUNT_ADDED",
			SynchronousEvent = true,
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
		{
			Name = "MountInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "isActive", Type = "bool", Nilable = false },
				{ Name = "isUsable", Type = "bool", Nilable = false },
				{ Name = "sourceType", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
				{ Name = "isFactionSpecific", Type = "bool", Nilable = false },
				{ Name = "faction", Type = "PvPFaction", Nilable = true },
				{ Name = "shouldHideOnChar", Type = "bool", Nilable = false },
				{ Name = "isCollected", Type = "bool", Nilable = false },
				{ Name = "mountID", Type = "number", Nilable = false },
				{ Name = "isSteadyFlight", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "MountInfoExtra",
			Type = "Structure",
			Fields =
			{
				{ Name = "creatureDisplayInfoID", Type = "number", Nilable = true },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "source", Type = "cstring", Nilable = false },
				{ Name = "isSelfMount", Type = "bool", Nilable = false },
				{ Name = "mountTypeID", Type = "number", Nilable = false },
				{ Name = "uiModelSceneID", Type = "number", Nilable = false },
				{ Name = "animID", Type = "number", Nilable = false },
				{ Name = "spellVisualKitID", Type = "number", Nilable = false },
				{ Name = "disablePlayerMountPreview", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MountJournal);