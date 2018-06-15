local KnowledgeBase =
{
	Name = "KnowledgeBase",
	Type = "System",
	Namespace = "C_KnowledgeBase",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "KnowledgeBaseArticleLoadFailure",
			Type = "Event",
			LiteralName = "KNOWLEDGE_BASE_ARTICLE_LOAD_FAILURE",
		},
		{
			Name = "KnowledgeBaseArticleLoadSuccess",
			Type = "Event",
			LiteralName = "KNOWLEDGE_BASE_ARTICLE_LOAD_SUCCESS",
		},
		{
			Name = "KnowledgeBaseQueryLoadFailure",
			Type = "Event",
			LiteralName = "KNOWLEDGE_BASE_QUERY_LOAD_FAILURE",
		},
		{
			Name = "KnowledgeBaseQueryLoadSuccess",
			Type = "Event",
			LiteralName = "KNOWLEDGE_BASE_QUERY_LOAD_SUCCESS",
		},
		{
			Name = "KnowledgeBaseServerMessage",
			Type = "Event",
			LiteralName = "KNOWLEDGE_BASE_SERVER_MESSAGE",
		},
		{
			Name = "KnowledgeBaseSetupLoadFailure",
			Type = "Event",
			LiteralName = "KNOWLEDGE_BASE_SETUP_LOAD_FAILURE",
		},
		{
			Name = "KnowledgeBaseSetupLoadSuccess",
			Type = "Event",
			LiteralName = "KNOWLEDGE_BASE_SETUP_LOAD_SUCCESS",
		},
		{
			Name = "KnowledgeBaseSystemMotdUpdated",
			Type = "Event",
			LiteralName = "KNOWLEDGE_BASE_SYSTEM_MOTD_UPDATED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(KnowledgeBase);