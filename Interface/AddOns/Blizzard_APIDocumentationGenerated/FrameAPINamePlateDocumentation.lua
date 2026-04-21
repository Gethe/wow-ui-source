local FrameAPINamePlate =
{
	Name = "FrameAPINamePlate",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "CanChangeHitTestPoints",
			Type = "Function",
			Documentation = { "Returns true if this nameplate permits changes to its hit-test points. Updates are normally blocked for tainted code during combat, except on the tick a unit is first assigned or when untainted code updates hit-test points on the same tick." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "canChangeHitTestPoints", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearAllHitTestPoints",
			Type = "Function",
			RequiresCanChangeHitTestPoints = true,
			Documentation = { "Clears the anchor points that determine where the mouse interacts with the nameplate." },

			Arguments =
			{
			},
		},
		{
			Name = "GetHitTestPoints",
			Type = "Function",
			Documentation = { "Returns the anchor points that determine where the mouse interacts with the nameplate." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "anchors", Type = "table", InnerType = "AnchorBinding", Nilable = false },
			},
		},
		{
			Name = "SetAllHitTestPoints",
			Type = "Function",
			RequiresCanChangeHitTestPoints = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the anchor points that determine where the mouse interacts with the nameplate to fully encompass the target region." },

			Arguments =
			{
				{ Name = "relativeTo", Type = "ScriptRegion", Nilable = false },
			},
		},
		{
			Name = "SetHitTestPoints",
			Type = "Function",
			RequiresCanChangeHitTestPoints = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the anchor points that determine where the mouse interacts with the nameplate." },

			Arguments =
			{
				{ Name = "anchors", Type = "table", InnerType = "AnchorBinding", Nilable = false, Documentation = { "List of anchor points to use for hit testing. All existing points will be cleared." } },
			},
		},
		{
			Name = "SetStackingBoundsFrame",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "frame", Type = "SimpleFrame", Nilable = false },
			},
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
		{
			Name = "RequiresCanChangeHitTestPoints",
			Type = "Precondition",
			FailureMode = "Error",
			Documentation = { "Guarded APIs require that the nameplate frame must allow changes to its hit test points." },
		},
	},
};

APIDocumentation:AddDocumentationTable(FrameAPINamePlate);