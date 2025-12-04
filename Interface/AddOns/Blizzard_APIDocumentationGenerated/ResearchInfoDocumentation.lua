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
			SecretArguments = "AllowedWhenUntainted",

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
			SynchronousEvent = true,
		},
		{
			Name = "ArchaeologyFindComplete",
			Type = "Event",
			LiteralName = "ARCHAEOLOGY_FIND_COMPLETE",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "ArtifactDigsiteComplete",
			Type = "Event",
			LiteralName = "ARTIFACT_DIGSITE_COMPLETE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "researchBranchID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ResearchArtifactComplete",
			Type = "Event",
			LiteralName = "RESEARCH_ARTIFACT_COMPLETE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ResearchArtifactDigSiteUpdated",
			Type = "Event",
			LiteralName = "RESEARCH_ARTIFACT_DIG_SITE_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "ResearchArtifactUpdate",
			Type = "Event",
			LiteralName = "RESEARCH_ARTIFACT_UPDATE",
			SynchronousEvent = true,
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
				{ Name = "position", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "poiBlobID", Type = "number", Nilable = false },
				{ Name = "textureIndex", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ResearchInfo);