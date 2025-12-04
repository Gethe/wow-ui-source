local SimpleColorSelectAPI =
{
	Name = "SimpleColorSelectAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "ClearColorWheelTexture",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetColorAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetColorAlphaTexture",
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
			Name = "GetColorAlphaThumbTexture",
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
			Name = "GetColorHSV",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hsvX", Type = "number", Nilable = false },
				{ Name = "hsvY", Type = "number", Nilable = false },
				{ Name = "hsvZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetColorRGB",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "rgbR", Type = "number", Nilable = false },
				{ Name = "rgbG", Type = "number", Nilable = false },
				{ Name = "rgbB", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetColorValueTexture",
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
			Name = "GetColorValueThumbTexture",
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
			Name = "GetColorWheelTexture",
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
			Name = "GetColorWheelThumbTexture",
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
			Name = "SetColorAlpha",
			Type = "Function",
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "alpha", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetColorAlphaTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "SetColorAlphaThumbTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "texture", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetColorHSV",
			Type = "Function",
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "hsvX", Type = "number", Nilable = false },
				{ Name = "hsvY", Type = "number", Nilable = false },
				{ Name = "hsvZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetColorRGB",
			Type = "Function",
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "rgbR", Type = "number", Nilable = false },
				{ Name = "rgbG", Type = "number", Nilable = false },
				{ Name = "rgbB", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetColorValueTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "SetColorValueThumbTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "texture", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetColorWheelTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "SetColorWheelThumbTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "texture", Type = "TextureAsset", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleColorSelectAPI);