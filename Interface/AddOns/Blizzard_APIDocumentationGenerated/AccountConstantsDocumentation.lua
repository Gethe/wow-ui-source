local AccountConstants =
{
	Tables =
	{
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
	},
};

APIDocumentation:AddDocumentationTable(AccountConstants);