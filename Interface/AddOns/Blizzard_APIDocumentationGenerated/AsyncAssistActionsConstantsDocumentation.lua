local AsyncAssistActionsConstants =
{
	Tables =
	{
		{
			Name = "AssistActionType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "None", Type = "AssistActionType", EnumValue = 0 },
				{ Name = "LoungingPlayer", Type = "AssistActionType", EnumValue = 1 },
				{ Name = "GraveMarker", Type = "AssistActionType", EnumValue = 2 },
				{ Name = "PlacedVo", Type = "AssistActionType", EnumValue = 3 },
				{ Name = "PlayerGuardian", Type = "AssistActionType", EnumValue = 4 },
				{ Name = "PlayerSlayer", Type = "AssistActionType", EnumValue = 5 },
				{ Name = "CapturedBuff", Type = "AssistActionType", EnumValue = 6 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AsyncAssistActionsConstants);