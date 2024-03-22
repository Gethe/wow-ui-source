local VoidStorageInfo =
{
	Name = "VoidStorageInfo",
	Type = "System",
	Namespace = "C_VoidStorageInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "VoidDepositWarning",
			Type = "Event",
			LiteralName = "VOID_DEPOSIT_WARNING",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
				{ Name = "link", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "VoidStorageContentsUpdate",
			Type = "Event",
			LiteralName = "VOID_STORAGE_CONTENTS_UPDATE",
		},
		{
			Name = "VoidStorageDepositUpdate",
			Type = "Event",
			LiteralName = "VOID_STORAGE_DEPOSIT_UPDATE",
			Payload =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "VoidStorageUpdate",
			Type = "Event",
			LiteralName = "VOID_STORAGE_UPDATE",
		},
		{
			Name = "VoidTransferDone",
			Type = "Event",
			LiteralName = "VOID_TRANSFER_DONE",
		},
		{
			Name = "VoidTransferSuccess",
			Type = "Event",
			LiteralName = "VOID_TRANSFER_SUCCESS",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(VoidStorageInfo);