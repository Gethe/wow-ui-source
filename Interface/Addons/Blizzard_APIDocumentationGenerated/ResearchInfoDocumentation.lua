local ResearchInfo =
{
	Name = "ResearchInfo",
	Type = "System",
	Namespace = "C_ResearchInfo",

	Functions =
	{
		{
			Name = "GetDigSitesForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "digSites", Type = "table", InnerType = "DigSiteMapInfo", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ArchaeologyClosed",
			Type = "Event",
			LiteralName = "ARCHAEOLOGY_CLOSED",
		},
		{
			Name = "ArchaeologyFindComplete",
			Type = "Event",
			LiteralName = "ARCHAEOLOGY_FIND_COMPLETE",
			Payload =
			{
				{ Name = "numFindsCompleted", Type = "number", Nilable = false },
				{ Name = "totalFinds", Type = "number", Nilable = false },
				{ Name = "researchBranchID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ArchaeologySurveyCast",
			Type = "Event",
			LiteralName = "ARCHAEOLOGY_SURVEY_CAST",
			Payload =
			{
				{ Name = "numFindsCompleted", Type = "number", Nilable = false },
				{ Name = "totalFinds", Type = "number", Nilable = false },
				{ Name = "researchBranchID", Type = "number", Nilable = false },
				{ Name = "successfulFind", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ArchaeologyToggle",
			Type = "Event",
			LiteralName = "ARCHAEOLOGY_TOGGLE",
		},
		{
			Name = "ArtifactDigsiteComplete",
			Type = "Event",
			LiteralName = "ARTIFACT_DIGSITE_COMPLETE",
			Payload =
			{
				{ Name = "researchBranchID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ResearchArtifactComplete",
			Type = "Event",
			LiteralName = "RESEARCH_ARTIFACT_COMPLETE",
			Payload =
			{
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ResearchArtifactDigSiteUpdated",
			Type = "Event",
			LiteralName = "RESEARCH_ARTIFACT_DIG_SITE_UPDATED",
		},
		{
			Name = "ResearchArtifactHistoryReady",
			Type = "Event",
			LiteralName = "RESEARCH_ARTIFACT_HISTORY_READY",
		},
		{
			Name = "ResearchArtifactUpdate",
			Type = "Event",
			LiteralName = "RESEARCH_ARTIFACT_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "DigSiteMapInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "researchSiteID", Type = "number", Nilable = false },
				{ Name = "position", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "textureIndex", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ResearchInfo);