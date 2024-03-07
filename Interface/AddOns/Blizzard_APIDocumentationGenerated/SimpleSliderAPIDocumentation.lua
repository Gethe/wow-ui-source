local SimpleSliderAPI =
{
	Name = "SimpleSliderAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "Disable",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "Enable",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetMinMaxValues",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "minValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetObeyStepOnDrag",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isObeyStepOnDrag", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetOrientation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "orientation", Type = "Orientation", Nilable = false },
			},
		},
		{
			Name = "GetStepsPerPage",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "stepsPerPage", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetThumbTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "GetValue",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetValueStep",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "valueStep", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsDraggingThumb",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isDraggingThumb", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetMinMaxValues",
			Type = "Function",

			Arguments =
			{
				{ Name = "minValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetObeyStepOnDrag",
			Type = "Function",

			Arguments =
			{
				{ Name = "obeyStepOnDrag", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetOrientation",
			Type = "Function",

			Arguments =
			{
				{ Name = "orientation", Type = "Orientation", Nilable = false },
			},
		},
		{
			Name = "SetStepsPerPage",
			Type = "Function",

			Arguments =
			{
				{ Name = "stepsPerPage", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetThumbTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetValue",
			Type = "Function",

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false },
				{ Name = "treatAsMouseEvent", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetValueStep",
			Type = "Function",

			Arguments =
			{
				{ Name = "valueStep", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleSliderAPI);