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
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
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
				{ Name = "FailedSilent", Type = "PingResult", EnumValue = 8 },
			},
		},
		{
			Name = "PingSetTargetState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Ok", Type = "PingSetTargetState", EnumValue = 0 },
				{ Name = "Failed", Type = "PingSetTargetState", EnumValue = 1 },
				{ Name = "FailedSilent", Type = "PingSetTargetState", EnumValue = 2 },
			},
		},
		{
			Name = "PingSubjectType",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "Attack", Type = "PingSubjectType", EnumValue = 0 },
				{ Name = "Warning", Type = "PingSubjectType", EnumValue = 1 },
				{ Name = "Assist", Type = "PingSubjectType", EnumValue = 2 },
				{ Name = "OnMyWay", Type = "PingSubjectType", EnumValue = 3 },
				{ Name = "AlertThreat", Type = "PingSubjectType", EnumValue = 4 },
				{ Name = "AlertNotThreat", Type = "PingSubjectType", EnumValue = 5 },
				{ Name = "ActionReady", Type = "PingSubjectType", EnumValue = 6 },
				{ Name = "ActionOnCooldown", Type = "PingSubjectType", EnumValue = 7 },
				{ Name = "ActionUnavailable", Type = "PingSubjectType", EnumValue = 8 },
				{ Name = "ActionNotReady", Type = "PingSubjectType", EnumValue = 9 },
			},
		},
		{
			Name = "PingTargetOption",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "All", Type = "PingTargetOption", EnumValue = 0 },
				{ Name = "Environment", Type = "PingTargetOption", EnumValue = 1 },
				{ Name = "Units", Type = "PingTargetOption", EnumValue = 2 },
			},
		},
		{
			Name = "PingTargetType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Unit", Type = "PingTargetType", EnumValue = 0 },
				{ Name = "Point", Type = "PingTargetType", EnumValue = 1 },
				{ Name = "Action", Type = "PingTargetType", EnumValue = 2 },
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
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PingConstants);