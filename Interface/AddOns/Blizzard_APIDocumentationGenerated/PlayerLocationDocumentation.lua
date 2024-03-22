local PlayerLocation =
{
	Name = "PlayerLocationInfo",
	Type = "System",
	Namespace = "C_PlayerInfo",

	Functions =
	{
		{
			Name = "GUIDIsPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPlayer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetClass",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "PlayerLocation", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "className", Type = "cstring", Nilable = true },
				{ Name = "classFilename", Type = "cstring", Nilable = true },
				{ Name = "classID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetName",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "PlayerLocation", Mixin = "PlayerLocationMixin", Nilable = false },
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
				{ Name = "playerLocation", Type = "PlayerLocation", Mixin = "PlayerLocationMixin", Nilable = false },
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
				{ Name = "playerLocation", Type = "PlayerLocation", Mixin = "PlayerLocationMixin", Nilable = false },
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
				{ Name = "playerLocation", Type = "PlayerLocation", Mixin = "PlayerLocationMixin", Nilable = true },
			},

			Returns =
			{
				{ Name = "isConnected", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "UnitIsSameServer",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "PlayerLocation", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "unitIsSameServer", Type = "bool", Nilable = false },
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