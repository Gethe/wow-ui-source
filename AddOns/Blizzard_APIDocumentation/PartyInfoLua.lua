local PartyInfoLua =
{
	Name = "PartyInfo",
	Type = "System",
	Namespace = "C_PartyInfo",

	Functions =
	{
		{
			Name = "GetInviteConfirmationInvalidQueues",
			Type = "Function",

			Arguments =
			{
				{ Name = "inviteGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "invalidQueues", Type = "table", InnerType = "QueueSpecificInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PartyInfoLua);