local Browser =
{
	Name = "Browser",
	Type = "System",
	Namespace = "C_Browser",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "SimpleBrowserWebError",
			Type = "Event",
			LiteralName = "SIMPLE_BROWSER_WEB_ERROR",
			Payload =
			{
				{ Name = "errorCode", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SimpleBrowserWebProxyFailed",
			Type = "Event",
			LiteralName = "SIMPLE_BROWSER_WEB_PROXY_FAILED",
		},
		{
			Name = "SimpleCheckoutClosed",
			Type = "Event",
			LiteralName = "SIMPLE_CHECKOUT_CLOSED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Browser);