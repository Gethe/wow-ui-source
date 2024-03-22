local ScriptWarnings =
{
	Name = "ScriptWarnings",
	Type = "System",
	Namespace = "C_ScriptWarnings",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "LuaWarning",
			Type = "Event",
			LiteralName = "LUA_WARNING",
			Payload =
			{
				{ Name = "warnType", Type = "number", Nilable = false },
				{ Name = "warningText", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ScriptWarnings);