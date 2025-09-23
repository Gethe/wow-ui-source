local LogicConstants =
{
	Tables =
	{
		{
			Name = "LogicLogicop",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "LogicLogicop", EnumValue = 0 },
				{ Name = "And", Type = "LogicLogicop", EnumValue = 1 },
				{ Name = "Or", Type = "LogicLogicop", EnumValue = 2 },
				{ Name = "Xor", Type = "LogicLogicop", EnumValue = 3 },
			},
		},
		{
			Name = "LogicMathop",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "None", Type = "LogicMathop", EnumValue = 0 },
				{ Name = "Plus", Type = "LogicMathop", EnumValue = 1 },
				{ Name = "Minus", Type = "LogicMathop", EnumValue = 2 },
				{ Name = "Times", Type = "LogicMathop", EnumValue = 3 },
				{ Name = "Div", Type = "LogicMathop", EnumValue = 4 },
				{ Name = "Mod", Type = "LogicMathop", EnumValue = 5 },
			},
		},
		{
			Name = "LogicRelop",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "None", Type = "LogicRelop", EnumValue = 0 },
				{ Name = "Equal", Type = "LogicRelop", EnumValue = 1 },
				{ Name = "Notequal", Type = "LogicRelop", EnumValue = 2 },
				{ Name = "Lt", Type = "LogicRelop", EnumValue = 3 },
				{ Name = "Lteq", Type = "LogicRelop", EnumValue = 4 },
				{ Name = "Gt", Type = "LogicRelop", EnumValue = 5 },
				{ Name = "Gteq", Type = "LogicRelop", EnumValue = 6 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LogicConstants);