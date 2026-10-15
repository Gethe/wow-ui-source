local LuaValuePredicates =
{
	Tables =
	{
	},

	Predicates =
	{
		{
			Name = "SecretWhenLuaTableHasSecretKeys",
			Type = "Secret",
			Documentation = { "Guarded APIs produce secret values if the subject Lua table contains any secret keys." },
		},
	},
};

APIDocumentation:AddDocumentationTable(LuaValuePredicates);