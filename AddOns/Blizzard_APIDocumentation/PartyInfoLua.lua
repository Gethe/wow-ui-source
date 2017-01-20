local PartyInfoLua =
{
	Name = "PartyInfo",
	Namespace = "C_PartyInfo",

	Functions =
	{
		{
			Name = "GetInviteConfirmationInvalidQueues",

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

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(PartyInfoLua);