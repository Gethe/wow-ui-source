local TargetScript =
{
	Name = "TargetScript",
	Type = "System",

	Functions =
	{
		{
			Name = "AssistUnit",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestEnemy",
			Type = "Function",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestEnemyPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestFriend",
			Type = "Function",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestFriendPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestPartyMember",
			Type = "Function",

			Arguments =
			{
				{ Name = "reverse", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetNearestRaidMember",
			Type = "Function",

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

			Arguments =
			{
				{ Name = "useStartDelay", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "TargetToggle",
			Type = "Function",
		},
		{
			Name = "TargetUnit",
			Type = "Function",

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