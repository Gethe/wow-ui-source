local Soulbinds =
{
	Name = "Soulbinds",
	Type = "System",
	Namespace = "C_Soulbinds",

	Functions =
	{
		{
			Name = "GetTree",
			Type = "Function",

			Arguments =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "tree", Type = "SoulbindTree", Nilable = false },
			},
		},
		{
			Name = "GetTrees",
			Type = "Function",

			Returns =
			{
				{ Name = "trees", Type = "table", InnerType = "SoulbindTree", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "SoulbindNode",
			Type = "Structure",
			Fields =
			{
				{ Name = "talent", Type = "GarrisonTalentInfo", Nilable = false },
				{ Name = "state", Type = "SoulbindNodeState", Nilable = false },
				{ Name = "conduitType", Type = "SoulbindConduitType", Nilable = true },
				{ Name = "parentNodeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "SoulbindTree",
			Type = "Structure",
			Fields =
			{
				{ Name = "treeID", Type = "number", Nilable = false },
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "nodes", Type = "table", InnerType = "SoulbindNode", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Soulbinds);