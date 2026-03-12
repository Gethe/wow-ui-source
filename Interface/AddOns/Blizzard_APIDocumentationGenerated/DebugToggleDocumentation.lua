local DebugToggle =
{
	Name = "DebugToggle",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "IsCollisionEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ToggleAnimKitDisplay",
			Type = "Function",
		},
		{
			Name = "ToggleCollision",
			Type = "Function",
		},
		{
			Name = "ToggleCollisionDisplay",
			Type = "Function",
		},
		{
			Name = "ToggleDebugAIDisplay",
			Type = "Function",
		},
		{
			Name = "ToggleGravity",
			Type = "Function",
		},
		{
			Name = "TogglePlayerBounds",
			Type = "Function",
		},
		{
			Name = "TogglePortals",
			Type = "Function",
		},
		{
			Name = "ToggleTris",
			Type = "Function",
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(DebugToggle);