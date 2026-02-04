local PlayerLocation =
{
	Name = "PlayerLocationInfo",
	Type = "System",
	Namespace = "C_PlayerInfo",
	Environment = "All",

	Functions =
	{
		{
			Name = "GUIDIsPlayer",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "playerLocation", Type = "PlayerLocation", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "sex", Type = "UnitSex", Nilable = true },
			},
		},
		{
			Name = "IsConnected",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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