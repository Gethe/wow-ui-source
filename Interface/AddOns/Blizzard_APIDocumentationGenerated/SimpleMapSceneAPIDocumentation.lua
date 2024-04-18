local SimpleMapSceneAPI =
{
	Name = "SimpleMapSceneAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetMaxCharacterSlotCount",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maxCharacterSlotCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetModelDrawLayer",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
				{ Name = "sublayer", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetViewInsets",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "right", Type = "uiUnit", Nilable = false },
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetModelDrawLayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
			},
		},
		{
			Name = "SetViewInsets",
			Type = "Function",

			Arguments =
			{
				{ Name = "left", Type = "uiUnit", Nilable = false },
				{ Name = "right", Type = "uiUnit", Nilable = false },
				{ Name = "top", Type = "uiUnit", Nilable = false },
				{ Name = "bottom", Type = "uiUnit", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleMapSceneAPI);