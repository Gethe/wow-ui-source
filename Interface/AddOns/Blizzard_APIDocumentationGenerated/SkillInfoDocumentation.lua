local SkillInfo =
{
	Name = "SkillInfo",
	Type = "System",
	Namespace = "C_SkillInfo",
	Environment = "All",

	Functions =
	{
		{
			Name = "AbandonSkill",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CollapseSkillHeader",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "ExpandSkillHeader",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetNumSkillLines",
			Type = "Function",

			Returns =
			{
				{ Name = "numSkillLines", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSelectedSkill",
			Type = "Function",

			Returns =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetSkillLineInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "skillLineAttributes", Type = "SkillLineAttributes", Nilable = true },
			},
		},
		{
			Name = "GetSkillLineInfoByID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "skillLineAttributes", Type = "SkillLineAttributes", Nilable = true },
			},
		},
		{
			Name = "SetSelectedSkill",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SkillLinesChanged",
			Type = "Event",
			LiteralName = "SKILL_LINES_CHANGED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "SkillLineAttributes",
			Type = "Structure",
			Fields =
			{
				{ Name = "skillID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "isHeader", Type = "bool", Nilable = false },
				{ Name = "isCollapsed", Type = "bool", Nilable = false },
				{ Name = "rank", Type = "number", Nilable = false },
				{ Name = "tempPoints", Type = "number", Nilable = false },
				{ Name = "modifier", Type = "number", Nilable = false },
				{ Name = "maxRank", Type = "number", Nilable = false },
				{ Name = "isAbandonable", Type = "bool", Nilable = false },
				{ Name = "stepCost", Type = "number", Nilable = false },
				{ Name = "rankCost", Type = "number", Nilable = false },
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "costType", Type = "number", Nilable = false },
				{ Name = "parentSkillLineID", Type = "number", Nilable = false },
				{ Name = "skillLineCategoryID", Type = "number", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SkillInfo);