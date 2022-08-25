local Camera =
{
	Name = "Camera",
	Type = "System",
	Namespace = "C_CameraDefaults",

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
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Camera);