local HousingCustomizeModeUI =
{
	Name = "HousingCustomizeModeUI",
	Type = "System",
	Namespace = "C_HousingCustomizeMode",

	Functions =
	{
		{
			Name = "ApplyDyeToSelectedDecor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "If a dyeable decor is selected, applies a specific dye color in a specific slot as a preview; See CommitDyesForSelectedDecor to actually save applied dye changes" },

			Arguments =
			{
				{ Name = "dyeSlotID", Type = "number", Nilable = false },
				{ Name = "dyeColorID", Type = "number", Nilable = true, Documentation = { "If not provided, clears the dye from the specified dye slot, returning that part of the decor asset to its default color" } },
			},
		},
		{
			Name = "ApplyThemeToRoom",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Attempt to apply a specific theme set (aka style) to all applicable room components in the current room" },

			Arguments =
			{
				{ Name = "themeSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ApplyThemeToSelectedRoomComponent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Attempt to apply a specific theme set (aka style) to the currently selected room component only" },

			Arguments =
			{
				{ Name = "themeSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ApplyWallpaperToAllWalls",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Attempt to apply a specific wallpaper (aka material/texture) to all applicable room components in the current room" },

			Arguments =
			{
				{ Name = "roomComponentTextureRecID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ApplyWallpaperToSelectedRoomComponent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Attempt to apply a specific wallpaper (aka material/texture) to the currently selected room component only" },

			Arguments =
			{
				{ Name = "roomComponentTextureRecID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CancelActiveEditing",
			Type = "Function",
			Documentation = { "Cancels all in-progress editing of the selected target, which will reset any unapplied customization changes and deselect the active target" },
		},
		{
			Name = "ClearDyesForSelectedDecor",
			Type = "Function",
			Documentation = { "Clears all previewed dye changes on the selected decor; Does not clear any already saved dyes that were previously applied" },
		},
		{
			Name = "ClearTargetRoomComponent",
			Type = "Function",
			Documentation = { "Deselect the currently selected room component, if there is one" },
		},
		{
			Name = "CommitDyesForSelectedDecor",
			Type = "Function",
			Documentation = { "Attempt to save all previewed dye changes made to the selected decor" },

			Returns =
			{
				{ Name = "hasChanges", Type = "bool", Nilable = false, Documentation = { "True if there were any changes to save" } },
			},
		},
		{
			Name = "GetHoveredDecorInfo",
			Type = "Function",
			Documentation = { "Returns info for the placed decor instance currently being hovered, if there is one" },

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetHoveredRoomComponentInfo",
			Type = "Function",
			Documentation = { "Returns info for the room component currently being hovered, if there is one" },

			Returns =
			{
				{ Name = "info", Type = "HousingRoomComponentInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetNumDyesToRemoveOnSelectedDecor",
			Type = "Function",
			Documentation = { "If a dyeable decor instance is selected, returns how many dye slots would be cleared on applying all currently previewed dye changes" },

			Returns =
			{
				{ Name = "numDyesToRemove", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumDyesToSpendOnSelectedDecor",
			Type = "Function",
			Documentation = { "If a dyeable decor instance is selected, returns how many dye items would be spent on applying all currently previewed dye changes" },

			Returns =
			{
				{ Name = "numDyesToSpend", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPreviewDyesOnSelectedDecor",
			Type = "Function",
			Documentation = { "If a dyeable decor instance is selected, returns info structs for each new/changed dye currently being previewed" },

			Returns =
			{
				{ Name = "previewDyes", Type = "table", InnerType = "PreviewDyeSlotInfo", Nilable = false },
			},
		},
		{
			Name = "GetRecentlyUsedDyes",
			Type = "Function",
			Documentation = { "Returns a list of ids for the dyes most recently applied by the player, if any" },

			Returns =
			{
				{ Name = "recentDyes", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRecentlyUsedThemeSets",
			Type = "Function",
			Documentation = { "Returns a list of ids for the theme sets (aka styles) most recently applied by the player, if any" },

			Returns =
			{
				{ Name = "recentThemeSets", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRecentlyUsedWallpapers",
			Type = "Function",
			Documentation = { "Returns a list of ids for the wallpapers most recently applied by the player, if any" },

			Returns =
			{
				{ Name = "recentWallpapers", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetSelectedDecorInfo",
			Type = "Function",
			Documentation = { "Returns info for the decor instance that's currently selected, if there is one" },

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetSelectedRoomComponentInfo",
			Type = "Function",
			Documentation = { "Returns info for the currently selected room component, if there is one" },

			Returns =
			{
				{ Name = "info", Type = "HousingRoomComponentInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetThemeSetInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the name of the specified theme set (aka style) if it exists" },

			Arguments =
			{
				{ Name = "themeSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetWallpapersForRoomComponentType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Get all wallpapers (aka materials/textures) available for the selected room component type, if any" },

			Arguments =
			{
				{ Name = "type", Type = "HousingRoomComponentType", Nilable = false },
			},

			Returns =
			{
				{ Name = "availableWallpapers", Type = "table", InnerType = "RoomComponentWallpaper", Nilable = false },
			},
		},
		{
			Name = "IsDecorSelected",
			Type = "Function",
			Documentation = { "Returns true if a decor instance is currently selected for customization" },

			Returns =
			{
				{ Name = "hasSelectedDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHouseExteriorDoorHovered",
			Type = "Function",
			Documentation = { "Returns true if the entry door of the house's exterior is currently being hovered" },

			Returns =
			{
				{ Name = "isHouseExteriorDoorHovered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHoveringDecor",
			Type = "Function",
			Documentation = { "Returns true if a placed decor instance is currently being hovered" },

			Returns =
			{
				{ Name = "isHoveringDecor", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsHoveringRoomComponent",
			Type = "Function",
			Documentation = { "Returns true if a room component is currently being hovered" },

			Returns =
			{
				{ Name = "isHovering", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRoomComponentSelected",
			Type = "Function",
			Documentation = { "Returns true if a room component is currently selected for customization" },

			Returns =
			{
				{ Name = "hasSelectedComponent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RoomComponentSupportsVariant",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Check whether a specific room component supports a particular variant; What kind of id or enum 'variant' equates to is complicated, as it depends on the component type" },

			Arguments =
			{
				{ Name = "componentID", Type = "number", Nilable = false },
				{ Name = "variant", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "variantSupported", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetRoomComponentCeilingType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Attempt to set a specific ceiling component, within a specific room, to a specific new ceiling type" },

			Arguments =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
				{ Name = "ceilingType", Type = "HousingRoomComponentCeilingType", Nilable = false },
			},
		},
		{
			Name = "SetRoomComponentDoorType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Attempt to set a specific door component, within a specific room, to a specific new door type" },

			Arguments =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
				{ Name = "newDoortype", Type = "HousingRoomComponentDoorType", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingCustomizeModeHoveredTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_CUSTOMIZE_MODE_HOVERED_TARGET_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "hasHoveredTarget", Type = "bool", Nilable = false },
				{ Name = "targetType", Type = "HousingCustomizeModeTargetType", Nilable = false },
			},
		},
		{
			Name = "HousingCustomizeModeSelectedTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_CUSTOMIZE_MODE_SELECTED_TARGET_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "hasSelectedTarget", Type = "bool", Nilable = false },
				{ Name = "targetType", Type = "HousingCustomizeModeTargetType", Nilable = false },
			},
		},
		{
			Name = "HousingDecorCustomizationChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_CUSTOMIZATION_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "HousingDecorDyeFailure",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_DYE_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "housingResult", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingRoomComponentCustomizationChangeFailed",
			Type = "Event",
			LiteralName = "HOUSING_ROOM_COMPONENT_CUSTOMIZATION_CHANGE_FAILED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
				{ Name = "housingResult", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingRoomComponentCustomizationChanged",
			Type = "Event",
			LiteralName = "HOUSING_ROOM_COMPONENT_CUSTOMIZATION_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "HousingCustomizeModeTargetType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "HousingCustomizeModeTargetType", EnumValue = 0 },
				{ Name = "Decor", Type = "HousingCustomizeModeTargetType", EnumValue = 1 },
				{ Name = "RoomComponent", Type = "HousingCustomizeModeTargetType", EnumValue = 2 },
				{ Name = "ExteriorHouse", Type = "HousingCustomizeModeTargetType", EnumValue = 3 },
			},
		},
		{
			Name = "HousingRoomComponentInstanceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "type", Type = "HousingRoomComponentType", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
				{ Name = "canBeCustomized", Type = "bool", Nilable = false },
				{ Name = "currentThemeSet", Type = "number", Nilable = true },
				{ Name = "availableThemeSets", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "currentWallpaper", Type = "number", Nilable = true },
				{ Name = "currentRoomComponentTextureRecID", Type = "number", Nilable = true },
				{ Name = "ceilingType", Type = "HousingRoomComponentCeilingType", Nilable = false },
				{ Name = "doorType", Type = "HousingRoomComponentDoorType", Nilable = false },
			},
		},
		{
			Name = "PreviewDyeSlotInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "dyeColorID", Type = "number", Nilable = false },
				{ Name = "dyeSlotID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RoomComponentWallpaper",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "roomComponentTextureRecID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingCustomizeModeUI);