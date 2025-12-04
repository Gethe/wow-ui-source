local SimpleScrollFrameAPI =
{
	Name = "SimpleScrollFrameAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetHorizontalScroll",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "offset", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetHorizontalScrollRange",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ScrollRange },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "range", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetScrollChild",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scrollChild", Type = "SimpleFrame", Nilable = false },
			},
		},
		{
			Name = "GetVerticalScroll",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "offset", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetVerticalScrollRange",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ScrollRange },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "range", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetHorizontalScroll",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "offset", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetScrollChild",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "scrollChild", Type = "SimpleFrame", Nilable = false },
			},
		},
		{
			Name = "SetVerticalScroll",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "offset", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "UpdateScrollChildRect",
			Type = "Function",

			Arguments =
			{
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

APIDocumentation:AddDocumentationTable(SimpleScrollFrameAPI);