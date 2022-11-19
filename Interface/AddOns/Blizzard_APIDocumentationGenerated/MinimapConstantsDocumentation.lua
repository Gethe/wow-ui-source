local MinimapConstants =
{
	Tables =
	{
		{
			Name = "MinimapTrackingFilter",
			Type = "Enumeration",
			NumValues = 22,
			MinValue = 0,
			MaxValue = 1048576,
			Fields =
			{
				{ Name = "Unfiltered", Type = "MinimapTrackingFilter", EnumValue = 0 },
				{ Name = "Auctioneer", Type = "MinimapTrackingFilter", EnumValue = 1 },
				{ Name = "Banker", Type = "MinimapTrackingFilter", EnumValue = 2 },
				{ Name = "Battlemaster", Type = "MinimapTrackingFilter", EnumValue = 4 },
				{ Name = "TaxiNode", Type = "MinimapTrackingFilter", EnumValue = 8 },
				{ Name = "VenderFood", Type = "MinimapTrackingFilter", EnumValue = 16 },
				{ Name = "Innkeeper", Type = "MinimapTrackingFilter", EnumValue = 32 },
				{ Name = "Mailbox", Type = "MinimapTrackingFilter", EnumValue = 64 },
				{ Name = "TrainerProfession", Type = "MinimapTrackingFilter", EnumValue = 128 },
				{ Name = "VendorReagent", Type = "MinimapTrackingFilter", EnumValue = 256 },
				{ Name = "Repair", Type = "MinimapTrackingFilter", EnumValue = 512 },
				{ Name = "TrivialQuests", Type = "MinimapTrackingFilter", EnumValue = 1024 },
				{ Name = "Stablemaster", Type = "MinimapTrackingFilter", EnumValue = 2048 },
				{ Name = "Transmogrifier", Type = "MinimapTrackingFilter", EnumValue = 4096 },
				{ Name = "POI", Type = "MinimapTrackingFilter", EnumValue = 8192 },
				{ Name = "Target", Type = "MinimapTrackingFilter", EnumValue = 16384 },
				{ Name = "Focus", Type = "MinimapTrackingFilter", EnumValue = 32768 },
				{ Name = "QuestPoIs", Type = "MinimapTrackingFilter", EnumValue = 65536 },
				{ Name = "Digsites", Type = "MinimapTrackingFilter", EnumValue = 131072 },
				{ Name = "TrainerClass", Type = "MinimapTrackingFilter", EnumValue = 262144 },
				{ Name = "VendorAmmo", Type = "MinimapTrackingFilter", EnumValue = 524288 },
				{ Name = "VendorPoison", Type = "MinimapTrackingFilter", EnumValue = 1048576 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(MinimapConstants);