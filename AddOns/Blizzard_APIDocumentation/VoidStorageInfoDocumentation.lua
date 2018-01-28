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
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "VoidStorageClose",
			Type = "Event",
			LiteralName = "VOID_STORAGE_CLOSE",
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
			Name = "VoidStorageOpen",
			Type = "Event",
			LiteralName = "VOID_STORAGE_OPEN",
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