local PingConstants =
{
	Tables =
	{
		{
			Name = "PingMode",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "KeyDown", Type = "PingMode", EnumValue = 0 },
				{ Name = "ClickDrag", Type = "PingMode", EnumValue = 1 },
			},
		},
		{
			Name = "PingResult",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Success", Type = "PingResult", EnumValue = 0 },
				{ Name = "FailedGeneric", Type = "PingResult", EnumValue = 1 },
				{ Name = "FailedSpamming", Type = "PingResult", EnumValue = 2 },
				{ Name = "FailedDisabledByLeader", Type = "PingResult", EnumValue = 3 },
				{ Name = "FailedDisabledBySettings", Type = "PingResult", EnumValue = 4 },
				{ Name = "FailedOutOfPingArea", Type = "PingResult", EnumValue = 5 },
				{ Name = "FailedSquelched", Type = "PingResult", EnumValue = 6 },
				{ Name = "FailedUnspecified", Type = "PingResult", EnumValue = 7 },
			},
		},
		{
			Name = "PingSubjectType",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Attack", Type = "PingSubjectType", EnumValue = 0 },
				{ Name = "Warning", Type = "PingSubjectType", EnumValue = 1 },
				{ Name = "Assist", Type = "PingSubjectType", EnumValue = 2 },
				{ Name = "OnMyWay", Type = "PingSubjectType", EnumValue = 3 },
				{ Name = "AlertThreat", Type = "PingSubjectType", EnumValue = 4 },
				{ Name = "AlertNotThreat", Type = "PingSubjectType", EnumValue = 5 },
			},
		},
		{
			Name = "PingTypeFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "DefaultPing", Type = "PingTypeFlags", EnumValue = 1 },
			},
		},
		{
			Name = "ContextualWorldPingResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "contextualPingType", Type = "PingSubjectType", Nilable = true },
				{ Name = "result", Type = "PingResult", Nilable = false },
			},
		},
		{
			Name = "PingCooldownInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "startTimeMs", Type = "number", Nilable = false },
				{ Name = "endTimeMs", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PingTypeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "orderIndex", Type = "number", Nilable = false },
				{ Name = "type", Type = "PingSubjectType", Nilable = false },
				{ Name = "uiTextureKitID", Type = "textureKit", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PingConstants);