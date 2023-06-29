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
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "templateName", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "group", Type = "SimpleAnimGroup", Nilable = false },
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