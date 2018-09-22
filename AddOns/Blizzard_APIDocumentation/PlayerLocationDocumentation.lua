local PlayerLocation =
{
	Name = "PlayerLocationInfo",
	Type = "System",
	Namespace = "C_PlayerInfo",

	Functions =
	{
		{
			Name = "GetClass",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "className", Type = "string", Nilable = true },
				{ Name = "classFilename", Type = "string", Nilable = true },
				{ Name = "classID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetName",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetRace",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "raceID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSex",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "sex", Type = "number", Nilable = true },
			},
		},
		{
			Name = "IsConnected",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = true },
			},

			Returns =
			{
				{ Name = "isConnected", Type = "bool", Nilable = true },
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

APIDocumentation:AddDocumentationTable(PlayerLocation);