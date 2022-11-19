local SimpleAnimatableObjectAPI =
{
	Name = "SimpleAnimatableObjectAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "CreateAnimationGroup",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "templateName", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "group", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetAnimationGroups",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scriptObject", Type = "ScriptObject", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "StopAnimating",
			Type = "Function",

			Arguments =
			{
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SimpleAnimatableObjectAPI);