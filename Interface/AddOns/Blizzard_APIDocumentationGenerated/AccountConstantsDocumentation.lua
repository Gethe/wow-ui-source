local AccountConstants =
{
	Tables =
	{
		{
			Name = "AccountData",
			Type = "Enumeration",
			NumValues = 15,
			MinValue = 0,
			MaxValue = 14,
			Fields =
			{
				{ Name = "Config", Type = "AccountData", EnumValue = 0 },
				{ Name = "Config2", Type = "AccountData", EnumValue = 1 },
				{ Name = "Bindings", Type = "AccountData", EnumValue = 2 },
				{ Name = "Bindings2", Type = "AccountData", EnumValue = 3 },
				{ Name = "Macros", Type = "AccountData", EnumValue = 4 },
				{ Name = "Macros2", Type = "AccountData", EnumValue = 5 },
				{ Name = "UILayout", Type = "AccountData", EnumValue = 6 },
				{ Name = "ChatSettings", Type = "AccountData", EnumValue = 7 },
				{ Name = "TtsSettings", Type = "AccountData", EnumValue = 8 },
				{ Name = "TtsSettings2", Type = "AccountData", EnumValue = 9 },
				{ Name = "FlaggedIDs", Type = "AccountData", EnumValue = 10 },
				{ Name = "FlaggedIDs2", Type = "AccountData", EnumValue = 11 },
				{ Name = "ClickBindings", Type = "AccountData", EnumValue = 12 },
				{ Name = "UIEditModeAccount", Type = "AccountData", EnumValue = 13 },
				{ Name = "UIEditModeChar", Type = "AccountData", EnumValue = 14 },
			},
		},
		{
			Name = "AccountDataUpdateStatus",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "AccountDataUpdateSuccess", Type = "AccountDataUpdateStatus", EnumValue = 0 },
				{ Name = "AccountDataUpdateFailed", Type = "AccountDataUpdateStatus", EnumValue = 1 },
				{ Name = "AccountDataUpdateCorrupt", Type = "AccountDataUpdateStatus", EnumValue = 2 },
				{ Name = "AccountDataUpdateToobig", Type = "AccountDataUpdateStatus", EnumValue = 3 },
			},
		},
		{
			Name = "AccountExportResult",
			Type = "Enumeration",
			NumValues = 14,
			MinValue = 0,
			MaxValue = 13,
			Fields =
			{
				{ Name = "Success", Type = "AccountExportResult", EnumValue = 0 },
				{ Name = "UnknownError", Type = "AccountExportResult", EnumValue = 1 },
				{ Name = "Cancelled", Type = "AccountExportResult", EnumValue = 2 },
				{ Name = "ShuttingDown", Type = "AccountExportResult", EnumValue = 3 },
				{ Name = "TimedOut", Type = "AccountExportResult", EnumValue = 4 },
				{ Name = "NoAccountFound", Type = "AccountExportResult", EnumValue = 5 },
				{ Name = "RequestedInvalidCharacter", Type = "AccountExportResult", EnumValue = 6 },
				{ Name = "RpcError", Type = "AccountExportResult", EnumValue = 7 },
				{ Name = "FileInvalid", Type = "AccountExportResult", EnumValue = 8 },
				{ Name = "FileWriteFailed", Type = "AccountExportResult", EnumValue = 9 },
				{ Name = "Unavailable", Type = "AccountExportResult", EnumValue = 10 },
				{ Name = "AlreadyInProgress", Type = "AccountExportResult", EnumValue = 11 },
				{ Name = "FailedToLockAccount", Type = "AccountExportResult", EnumValue = 12 },
				{ Name = "FailedToGenerateFile", Type = "AccountExportResult", EnumValue = 13 },
			},
		},
		{
			Name = "DisableAccountProfilesFlags",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 16,
			Fields =
			{
				{ Name = "None", Type = "DisableAccountProfilesFlags", EnumValue = 0 },
				{ Name = "Document", Type = "DisableAccountProfilesFlags", EnumValue = 1 },
				{ Name = "SharedCollections", Type = "DisableAccountProfilesFlags", EnumValue = 2 },
				{ Name = "MountsCollections", Type = "DisableAccountProfilesFlags", EnumValue = 4 },
				{ Name = "PetsCollections", Type = "DisableAccountProfilesFlags", EnumValue = 8 },
				{ Name = "ItemsCollections", Type = "DisableAccountProfilesFlags", EnumValue = 16 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AccountConstants);