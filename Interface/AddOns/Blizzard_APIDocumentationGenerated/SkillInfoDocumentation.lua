local SkillInfo =
{
	Name = "SkillInfo",
	Type = "System",
	Namespace = "C_SkillInfo",
	Environment = "All",

	Functions =
	{
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
	},
};

APIDocumentation:AddDocumentationTable(SkillInfo);