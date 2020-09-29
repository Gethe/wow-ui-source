local Tutorial =
{
	Name = "Tutorial",
	Type = "System",
	Namespace = "C_Tutorial",

	Functions =
	{
		{
			Name = "AbandonTutorialArea",
			Type = "Function",
		},
		{
			Name = "ReturnToTutorialArea",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "LeavingTutorialArea",
			Type = "Event",
			LiteralName = "LEAVING_TUTORIAL_AREA",
		},
		{
			Name = "NpeTutorialUpdate",
			Type = "Event",
			LiteralName = "NPE_TUTORIAL_UPDATE",
		},
		{
			Name = "TutorialHighlightSpell",
			Type = "Event",
			LiteralName = "TUTORIAL_HIGHLIGHT_SPELL",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "tutorialGlobalStringTag", Type = "string", Nilable = false },
			},
		},
		{
			Name = "TutorialTrigger",
			Type = "Event",
			LiteralName = "TUTORIAL_TRIGGER",
			Payload =
			{
				{ Name = "tutorialIndex", Type = "number", Nilable = false },
				{ Name = "forceShow", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TutorialUnhighlightSpell",
			Type = "Event",
			LiteralName = "TUTORIAL_UNHIGHLIGHT_SPELL",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Tutorial);