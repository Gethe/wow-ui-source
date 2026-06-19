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

			Arguments =
			{
				{ Name = "blueprintID", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "ExportBlueprint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "ImportBlueprint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "shareCode", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsExportAvailable",
			Type = "Function",
			Documentation = { "Returns true if the player is currently in a valid location and has permission to export Blueprints" },

			Returns =
			{
				{ Name = "exportAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsImportAvailable",
			Type = "Function",
			Documentation = { "Returns true if the player is currently in a valid location and has permission to import Blueprints" },

			Returns =
			{
				{ Name = "importAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsShareCodeValid",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintDeleteSuccess",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_DELETE_SUCCESS",
			SynchronousEvent = true,
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
				{ Name = "result", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingBlueprintRenameSuccess",
			Type = "Event",
			LiteralName = "HOUSING_BLUEPRINT_RENAME_SUCCESS",
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