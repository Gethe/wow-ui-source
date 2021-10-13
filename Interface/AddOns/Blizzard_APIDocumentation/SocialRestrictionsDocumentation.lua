local SocialRestrictions =
{
	Name = "SocialRestrictions",
	Type = "System",
	Namespace = "C_SocialRestrictions",

	Functions =
	{
		{
			Name = "IsMuted",
			Type = "Function",

			Returns =
			{
				{ Name = "isMuted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSilenced",
			Type = "Function",

			Returns =
			{
				{ Name = "isSilenced", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSquelched",
			Type = "Function",

			Returns =
			{
				{ Name = "isSquelched", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SocialRestrictions);