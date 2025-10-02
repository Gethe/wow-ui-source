local SimpleBrowserAPI =
{
	Name = "SimpleBrowserAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "ClearFocus",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "CopyExternalLink",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "DeleteCookies",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "NavigateBack",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "NavigateForward",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "NavigateHome",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "urlType", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "NavigateReload",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "NavigateStop",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "OpenExternalLink",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "OpenTicket",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFocus",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetZoom",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "zoom", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleBrowserAPI);