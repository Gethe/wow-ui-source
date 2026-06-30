local HousingBlueprintUI =
{
	Name = "HousingBlueprintUI",
	Type = "System",
	Namespace = "C_HousingBlueprint",
	Environment = "All",

	Functions =
	{
		{
			Name = "CanImportTypeFromCurrentLocation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if the player's current location is a valid place to attempt to import a specific kind of blueprint" },

			Arguments =
			{
				{ Name = "type", Type = "HousingBlueprintType", Nilable = false },
			},

			Returns =
			{
				{ Name = "locationValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DeleteBlueprint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Delete the specified owned blueprint; Listen for HousingBlueprintDeleteSuccess and HousingBlueprintDeleteFailure for results" },

			Arguments =
			{
				{ Name = "blueprintID", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "ExportBlueprint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Saves out a new Blueprint of the specified type, using the specified name, if available, based on where the player is currently standing (see GetExportAvailability); Listen for HousingBlueprintExportSuccess and HousingBlueprintExportFailure for results" },

			Arguments =
			{
				{ Name = "type", Type = "HousingBlueprintType", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ExportRoomBlueprint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Saves out a new Blueprint of the specified room, using the specified name, if available (see GetExportAvailability); Listen for HousingBlueprintExportSuccess and HousingBlueprintExportFailure for results" },

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetBlueprintHyperlink",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "blueprintShareCode", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "hyperLink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetBlueprintTypeForCode",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns what type of Blueprint the specified code is for; Will return HousingBlueprintType.None if code is invalid; Does NOT check whether the shareCode actually matches up to a real valid Blueprint" },

			Arguments =
			{
				{ Name = "shareCode", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "type", Type = "HousingBlueprintType", Nilable = false },
			},
		},
		{
			Name = "GetExportAvailability",
			Type = "Function",
			Documentation = { "Returns success if the player can currently export Blueprints, or a specific error type (ex: invalid location or permissions)" },

			Returns =
			{
				{ Name = "availability", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "GetFeatureAvailability",
			Type = "Function",
			Documentation = { "Returns success if Blueprints as a feature is currently enabled and available" },

			Returns =
			{
				{ Name = "blueprintsAvailability", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "GetImportAvailability",
			Type = "Function",
			Documentation = { "Returns success if the player can currently import Blueprints, or a specific error type (ex: invalid location or permissions)" },

			Returns =
			{
				{ Name = "availability", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "ImportBlueprint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Imports the specified blueprint, if available (see GetImportAvailability and CanImportTypeFromCurrentLocation); Listen for HousingBlueprintImportSuccess and HousingBlueprintImportFailure for results" },

			Arguments =
			{
				{ Name = "shareCode", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsShareCodeValid",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if the string matches the valid expected format for a Blueprint Share Code; Does NOT check whether the shareCode actually matches up to a real valid Blueprint" },

			Arguments =
			{
				{ Name = "shareCode", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RenameBlueprint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Rename the specified owned blueprint to the specified name; Listen for HousingBlueprintRenameSuccess and HousingBlueprintRenameFailure for results" },

			Arguments =
			{
				{ Name = "blueprintID", Type = "BigUInteger", Nilable = false },
				{ Name = "newName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "RequestBlueprintCollection",
			Type = "Function",
			Documentation = { "Request the full list of all of the player's Blueprints; This is async, either the HOUSING_BLUEPRINT_COLLECTION_RECEIVED or HOUSING_BLUEPRINT_COLLECTION_FAILURE event will eventually be fired as a result" },
		},
		{
			Name = "RequestBlueprintContents",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Request the full contents of a specific Blueprint, in context of the current owned plot or house (if any); This is async as content info includes dynamic data from the server, either the HOUSING_BLUEPRINT_CONTENTS_RECEIVED or HOUSING_BLUEPRINT_CONTENTS_FAILURE event will eventually be fired as a result; Calling this again before a prior request has finished will cancel the prior request" },

			Arguments =
			{
				{ Name = "shareCode", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "RequestBlueprintContentsForContext",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Request the full contents of a specific Blueprint, either in context of a specific owned House or plot, or explicitly outside of any specific context; Typically used to update missing requirement info from previously-retrieved contents; See RequestBlueprintContents for other notes" },

			Arguments =
			{
				{ Name = "shareCode", Type = "cstring", Nilable = false },
				{ Name = "optionalHouseGUID", Type = "WOWGUID", Nilable = true },
			},
		},
		{
			Name = "StartImportRoomBlueprint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Start the process of importing a Room Blueprint. This will lead to Layout Mode being opened, so the player can then select an available door to attach the room to" },

			Arguments =
			{
				{ Name = "shareCode", Type = "cstring", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingBlueprintCollectionFailure",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_COLLECTION_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintCollectionReceived",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_COLLECTION_RECEIVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "collection", Type = "HousingBlueprintCollection", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintContentsFailure",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_CONTENTS_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "blueprintShareCode", Type = "string", Nilable = false },
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintContentsReceived",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_CONTENTS_RECEIVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "contentInfo", Type = "HousingBlueprintContentInfo", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintDeleteFailure",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_DELETE_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "blueprintID", Type = "BigUInteger", Nilable = false },
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintDeleteSuccess",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_DELETE_SUCCESS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "blueprintID", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintExportFailure",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_EXPORT_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintExportSuccess",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_EXPORT_SUCCESS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "blueprintShareCode", Type = "string", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintImportFailure",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_IMPORT_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintImportStarted",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_IMPORT_STARTED",
			SynchronousEvent = true,
		},
		{
			Name = "HousingBlueprintImportSuccess",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_IMPORT_SUCCESS",
			SynchronousEvent = true,
		},
		{
			Name = "HousingBlueprintRenameFailure",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_RENAME_FAILURE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "blueprintID", Type = "BigUInteger", Nilable = false },
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintRenameSuccess",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_RENAME_SUCCESS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "blueprintID", Type = "BigUInteger", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintsAvailabilityChanged",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINTS_AVAILABILITY_CHANGED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(HousingBlueprintUI);