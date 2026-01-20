local ColorUtil =
{
	Name = "ColorUtil",
	Type = "System",
	Namespace = "C_ColorUtil",
	Environment = "All",

	Functions =
	{
		{
			Name = "ConvertHSLToHSV",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Converts an unpacked HSL color to HSV." },

			Arguments =
			{
				{ Name = "hslH", Type = "number", Nilable = false },
				{ Name = "hslS", Type = "number", Nilable = false },
				{ Name = "hslL", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hsvH", Type = "number", Nilable = false },
				{ Name = "hsvS", Type = "number", Nilable = false },
				{ Name = "hsvV", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ConvertHSVToHSL",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Converts an unpacked HSV color to HSL." },

			Arguments =
			{
				{ Name = "hsvH", Type = "number", Nilable = false },
				{ Name = "hsvS", Type = "number", Nilable = false },
				{ Name = "hsvV", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hslH", Type = "number", Nilable = false },
				{ Name = "hslS", Type = "number", Nilable = false },
				{ Name = "hslL", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ConvertHSVToRGB",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Converts an unpacked HSV color to RGB." },

			Arguments =
			{
				{ Name = "hsvH", Type = "number", Nilable = false },
				{ Name = "hsvS", Type = "number", Nilable = false },
				{ Name = "hsvV", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rgbR", Type = "number", Nilable = false },
				{ Name = "rgbG", Type = "number", Nilable = false },
				{ Name = "rgbB", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ConvertRGBToHSV",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Converts an unpacked RGB color to HSV. For achromatic inputs, the returned hue will be -1." },

			Arguments =
			{
				{ Name = "rgbR", Type = "number", Nilable = false },
				{ Name = "rgbG", Type = "number", Nilable = false },
				{ Name = "rgbB", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hsvH", Type = "number", Nilable = false },
				{ Name = "hsvS", Type = "number", Nilable = false },
				{ Name = "hsvV", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GenerateTextColorCode",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Generates a hex color code suitable for use in text color code markup." },

			Arguments =
			{
				{ Name = "color", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false, Documentation = { "Color to generate a hex color code from." } },
			},

			Returns =
			{
				{ Name = "textColorCode", Type = "string", Nilable = false, Documentation = { "Hex representation of the color formatted as an 8-byte ARGB string, with alpha forced to 255." } },
			},
		},
		{
			Name = "WrapTextInColor",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Wraps a given string with color code markup." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "Text to be wrapped in color markup." } },
				{ Name = "color", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false, Documentation = { "Color to apply to the text." } },
			},

			Returns =
			{
				{ Name = "coloredText", Type = "string", Nilable = false, Documentation = { "The input text wrapped in '|c' and '|r' quoted code sequences for the supplied color." } },
			},
		},
		{
			Name = "WrapTextInColorCode",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Wraps a given string with color code markup." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "Text to be wrapped in color markup." } },
				{ Name = "textColorCode", Type = "cstring", Nilable = false, Documentation = { "Color to apply to the text, formatted as an 8-byte ARGB string as returned by GenerateTextColorCode." } },
			},

			Returns =
			{
				{ Name = "coloredText", Type = "string", Nilable = false, Documentation = { "The input text wrapped in '|c' and '|r' quoted code sequences for the supplied color." } },
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

APIDocumentation:AddDocumentationTable(ColorUtil);