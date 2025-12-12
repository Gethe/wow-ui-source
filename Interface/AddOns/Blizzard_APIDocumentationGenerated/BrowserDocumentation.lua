local Browser =
{
	Name = "Browser",
	Type = "System",
	Namespace = "C_Browser",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "SimpleBrowserWebError",
			Type = "Event",
			LiteralName = "SIMPLE_BROWSER_WEB_ERROR",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "errorCode", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SimpleBrowserWebProxyFailed",
			Type = "Event",
			LiteralName = "SIMPLE_BROWSER_WEB_PROXY_FAILED",
			SynchronousEvent = true,
		},
		{
			Name = "SimpleCheckoutClosed",
			Type = "Event",
			LiteralName = "SIMPLE_CHECKOUT_CLOSED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Browser);