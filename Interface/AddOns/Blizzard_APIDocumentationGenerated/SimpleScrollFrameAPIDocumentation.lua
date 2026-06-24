local SimpleScrollFrameAPI =
{
	Name = "SimpleScrollFrameAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetHorizontalScroll",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.ScrollOffset },

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
			SecretReturnsForAspect = { Enum.SecretAspect.ScrollOffset },

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
			SecretArgumentsAddAspect = { Enum.SecretAspect.ScrollOffset },
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "offset", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetScrollChild",
			Type = "Function",
			IsProtectedFunction = true,
			CheckAllowInheritForbiddenParentAspects = true,
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
			SecretArgumentsAddAspect = { Enum.SecretAspect.ScrollOffset },
			SecretArguments = "AllowedWhenUntainted",

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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SimpleScrollFrameAPI);