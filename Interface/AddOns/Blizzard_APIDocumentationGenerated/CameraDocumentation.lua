local Camera =
{
	Name = "Camera",
	Type = "System",

	Functions =
	{
		{
			Name = "GetCameraFOVDefaults",
			Type = "Function",

			Returns =
			{
				{ Name = "fieldOfViewDegreesDefault", Type = "number", Nilable = false },
				{ Name = "fieldOfViewDegreesPlayerMin", Type = "number", Nilable = false },
				{ Name = "fieldOfViewDegreesPlayerMax", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetUICameraInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiCameraID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "posX", Type = "number", Nilable = false },
				{ Name = "posY", Type = "number", Nilable = false },
				{ Name = "posZ", Type = "number", Nilable = false },
				{ Name = "lookAtX", Type = "number", Nilable = false },
				{ Name = "lookAtY", Type = "number", Nilable = false },
				{ Name = "lookAtZ", Type = "number", Nilable = false },
				{ Name = "animID", Type = "number", Nilable = false },
				{ Name = "animVariation", Type = "number", Nilable = false },
				{ Name = "animFrame", Type = "number", Nilable = false },
				{ Name = "useModelCenter", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Camera);