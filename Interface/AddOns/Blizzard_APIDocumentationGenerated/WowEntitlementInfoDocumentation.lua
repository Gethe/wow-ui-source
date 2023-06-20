local WowEntitlementInfo =
{
	Name = "WowEntitlementInfo",
	Type = "System",
	Namespace = "C_WowEntitlementInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "EntitlementDelivered",
			Type = "Event",
			LiteralName = "ENTITLEMENT_DELIVERED",
			Payload =
			{
				{ Name = "entitlementType", Type = "WoWEntitlementType", Nilable = false },
				{ Name = "textureID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "payloadID", Type = "number", Nilable = true },
				{ Name = "showFancyToast", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RafEntitlementDelivered",
			Type = "Event",
			LiteralName = "RAF_ENTITLEMENT_DELIVERED",
			Payload =
			{
				{ Name = "entitlementType", Type = "WoWEntitlementType", Nilable = false },
				{ Name = "textureID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "payloadID", Type = "number", Nilable = true },
				{ Name = "showFancyToast", Type = "bool", Nilable = false },
				{ Name = "rafVersion", Type = "RecruitAFriendRewardsVersion", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "WoWEntitlementType",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "Item", Type = "WoWEntitlementType", EnumValue = 0 },
				{ Name = "Mount", Type = "WoWEntitlementType", EnumValue = 1 },
				{ Name = "Battlepet", Type = "WoWEntitlementType", EnumValue = 2 },
				{ Name = "Toy", Type = "WoWEntitlementType", EnumValue = 3 },
				{ Name = "Appearance", Type = "WoWEntitlementType", EnumValue = 4 },
				{ Name = "AppearanceSet", Type = "WoWEntitlementType", EnumValue = 5 },
				{ Name = "GameTime", Type = "WoWEntitlementType", EnumValue = 6 },
				{ Name = "Title", Type = "WoWEntitlementType", EnumValue = 7 },
				{ Name = "Illusion", Type = "WoWEntitlementType", EnumValue = 8 },
				{ Name = "Invalid", Type = "WoWEntitlementType", EnumValue = 9 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WowEntitlementInfo);