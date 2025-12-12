local SimpleSliderAPI =
{
	Name = "SimpleSliderAPI",
	Type = "ScriptObject",
	Environment = "All",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetMinMaxValues",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "minValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetObeyStepOnDrag",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "obeyStepOnDrag", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetOrientation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "orientation", Type = "Orientation", Nilable = false },
			},
		},
		{
			Name = "SetStepsPerPage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "stepsPerPage", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetThumbTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetValue",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false },
				{ Name = "treatAsMouseEvent", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetValueStep",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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