local GossipInfo =
{
	Name = "GossipInfo",
	Type = "System",
	Namespace = "C_GossipInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "GossipClosed",
			Type = "Event",
			LiteralName = "GOSSIP_CLOSED",
		},
		{
			Name = "GossipConfirm",
			Type = "Event",
			LiteralName = "GOSSIP_CONFIRM",
			Payload =
			{
				{ Name = "gossipIndex", Type = "number", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
				{ Name = "cost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GossipConfirmCancel",
			Type = "Event",
			LiteralName = "GOSSIP_CONFIRM_CANCEL",
		},
		{
			Name = "GossipEnterCode",
			Type = "Event",
			LiteralName = "GOSSIP_ENTER_CODE",
			Payload =
			{
				{ Name = "gossipIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GossipShow",
			Type = "Event",
			LiteralName = "GOSSIP_SHOW",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(GossipInfo);