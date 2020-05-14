local AnimaDiversionUI =
{
	Name = "AnimaDiversionInfo",
	Type = "System",
	Namespace = "C_AnimaDiversion",

	Functions =
	{
		{
			Name = "GetAnimaDiversionNodes",
			Type = "Function",

			Returns =
			{
				{ Name = "animaNodes", Type = "table", InnerType = "AnimaDiversionNodeInfo", Nilable = false },
			},
		},
		{
			Name = "GetReinforceProgress",
			Type = "Function",

			Returns =
			{
				{ Name = "progress", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTextureKit",
			Type = "Function",

			Returns =
			{
				{ Name = "textureKit", Type = "string", Nilable = false },
			},
		},
		{
			Name = "OpenAnimaDiversionUI",
			Type = "Function",
		},
		{
			Name = "SelectAnimaNode",
			Type = "Function",

			Arguments =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
				{ Name = "temporary", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AnimaDiversionClose",
			Type = "Event",
			LiteralName = "ANIMA_DIVERSION_CLOSE",
		},
		{
			Name = "AnimaDiversionOpen",
			Type = "Event",
			LiteralName = "ANIMA_DIVERSION_OPEN",
			Payload =
			{
				{ Name = "info", Type = "AnimaDiversionFrameInfo", Nilable = false },
			},
		},
		{
			Name = "AnimaDiversionTalentUpdated",
			Type = "Event",
			LiteralName = "ANIMA_DIVERSION_TALENT_UPDATED",
		},
	},

	Tables =
	{
		{
			Name = "AnimaDiversionNodeState",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Unavailable", Type = "AnimaDiversionNodeState", EnumValue = 0 },
				{ Name = "Available", Type = "AnimaDiversionNodeState", EnumValue = 1 },
				{ Name = "SelectedTemporary", Type = "AnimaDiversionNodeState", EnumValue = 2 },
				{ Name = "SelectedPermanent", Type = "AnimaDiversionNodeState", EnumValue = 3 },
			},
		},
		{
			Name = "AnimaDiversionCostInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AnimaDiversionFrameInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "mapID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AnimaDiversionNodeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "talentID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "costs", Type = "table", InnerType = "AnimaDiversionCostInfo", Nilable = false },
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "normalizedPosition", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "state", Type = "AnimaDiversionNodeState", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AnimaDiversionUI);