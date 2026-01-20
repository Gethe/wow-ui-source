local ClassTrial =
{
	Name = "ClassTrial",
	Type = "System",
	Namespace = "C_ClassTrial",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ClassTrialTimerStart",
			Type = "Event",
			LiteralName = "CLASS_TRIAL_TIMER_START",
			SynchronousEvent = true,
		},
		{
			Name = "ClassTrialUpgradeComplete",
			Type = "Event",
			LiteralName = "CLASS_TRIAL_UPGRADE_COMPLETE",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ClassTrial);