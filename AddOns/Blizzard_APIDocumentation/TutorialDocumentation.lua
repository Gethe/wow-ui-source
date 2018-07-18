local Tutorial =
{
	Name = "Tutorial",
	Type = "System",
	Namespace = "C_Tutorial",

	Functions =
	{
	},

	Events =
	{
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