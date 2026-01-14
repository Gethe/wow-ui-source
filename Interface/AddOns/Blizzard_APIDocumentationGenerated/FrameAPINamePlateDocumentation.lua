local FrameAPINamePlate =
{
	Name = "FrameAPINamePlate",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
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
};

APIDocumentation:AddDocumentationTable(FrameAPINamePlate);