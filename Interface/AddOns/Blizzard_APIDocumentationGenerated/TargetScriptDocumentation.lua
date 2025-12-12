local TargetScript =
{
	Name = "TargetScript",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "AssistUnit",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false, Default = "" },
				{ Name = "exactMatch", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "AttackTarget",
			Type = "Function",
		},
		{
			Name = "ClearFocus",
			Type = "Function",
		},
		{
			Name = "ClearTarget",
			Type = "Function",

			Returns =
			{
				{ Name = "willMakeChange", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "FocusUnit",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false, Default = "" },
			},
		},
		{
			Name = "IsTargetLoose",
			Type = "Function",

			Returns =
			{
				{ Name = "isTargetLoose", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TargetDirectionEnemy",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "facing", Type = "number", Nilable = false },
				{ Name = "coneAngle", Type = "number", Nilable = true },
			},
		},
		{
			Name = "TargetDirectionFinished",
			Type = "Function",
		},
		{
			Name = "TargetDirectionFriend",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "facing", Type = "number", Nilable = false },
				{ Name = "coneAngle", Type = "number", Nilable = true },
			},
		},
		{
			Name = "TargetLastEnemy",
			Type = "Function",
		},
		{
			Name = "TargetLastFriend",
			Type = "Function",
		},
		{
			Name = "TargetLastTarget",
			Type = "Function",
		},
		{
			Name = "TargetNearest",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestEnemy",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestEnemyPlayer",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestFriend",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestFriendPlayer",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestPartyMember",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestRaidMember",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetPriorityHighlightEnd",
			Type = "Function",
		},
		{
			Name = "TargetPriorityHighlightStart",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "useStartDelay", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetToggle",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "TargetUnit",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false, Default = "" },
				{ Name = "exactMatch", Type = "bool", Nilable = false, Default = false },
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

APIDocumentation:AddDocumentationTable(TargetScript);