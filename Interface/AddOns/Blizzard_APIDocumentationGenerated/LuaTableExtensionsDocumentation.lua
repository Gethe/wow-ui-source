local LuaTableExtensions =
{
	Name = "LuaTableExtensions",
	Type = "System",
	Namespace = "table",
	Environment = "All",

	Functions =
	{
		{
			Name = "contains",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if any value in the table compares equal to the specified value." },

			Arguments =
			{
				{ Name = "table", Type = "table", Nilable = false, Documentation = { "The table to search." } },
				{ Name = "value", Type = "any", Nilable = true, Documentation = { "The value for which to search." } },
			},

			Returns =
			{
				{ Name = "containsValue", Type = "bool", Nilable = false, Documentation = { "True if any entry in the table has the specified value." } },
			},
		},
		{
			Name = "count",
			Type = "Function",
			SecretWhenLuaTableHasSecretKeys = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the number of entries in the table." },

			Arguments =
			{
				{ Name = "table", Type = "table", Nilable = false, Documentation = { "The table whose entries will be counted." } },
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false, Documentation = { "The number of entries in the table." } },
			},
		},
		{
			Name = "create",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Creates an empty table with storage preallocated for the specified number of array and non-array entries." },

			Arguments =
			{
				{ Name = "arraySizeHint", Type = "number", Nilable = false, Documentation = { "The number of array entries for which to preallocate storage." } },
				{ Name = "nodeSizeHint", Type = "number", Nilable = false, Default = 0, Documentation = { "The number of non-array entries for which to preallocate storage." } },
			},

			Returns =
			{
				{ Name = "table", Type = "table", Nilable = false },
			},
		},
		{
			Name = "indexof",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the first integer index whose value compares equal to the specified value, searching consecutively from index 1 until the first nil value." },

			Arguments =
			{
				{ Name = "table", Type = "table", Nilable = false, Documentation = { "The table to search." } },
				{ Name = "value", Type = "any", Nilable = true, Documentation = { "The value for which to search." } },
			},

			Returns =
			{
				{ Name = "index", Type = "number", Nilable = true, Documentation = { "The first matching index, or nil if no match is found." } },
			},
		},
		{
			Name = "freeze",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Marks a supplied table as frozen, preventing any modifications to its contents, or replacement of its metatable. If the table has a pre-existing metatable with a '__newindex' table or function, assignments will pass through without raising errors. For tainted code, only tables created by the same addon making this function call are permitted to be frozen." },

			Arguments =
			{
				{ Name = "table", Type = "table", Nilable = false, Documentation = { "The table to freeze." } },
			},

			Returns =
			{
				{ Name = "frozen", Type = "table", Nilable = false, Documentation = { "The supplied table, passed through." } },
			},
		},
		{
			Name = "keys",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns an array containing the keys of the specified table." },

			Arguments =
			{
				{ Name = "table", Type = "table", Nilable = false, Documentation = { "The table whose keys will be returned." } },
			},

			Returns =
			{
				{ Name = "keys", Type = "any", Nilable = false, Documentation = { "An array containing the table's keys. The order of the returned keys is unspecified." } },
			},
		},
		{
			Name = "getcountinfo",
			Type = "Function",
			SecretWhenLuaTableHasSecretKeys = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns detailed information about the number and distribution of entries in the table." },

			Arguments =
			{
				{ Name = "table", Type = "table", Nilable = false, Documentation = { "The table to inspect." } },
			},

			Returns =
			{
				{ Name = "numEntries", Type = "number", Nilable = false, Documentation = { "The total number of entries in the table." } },
				{ Name = "numPositiveIntegerKeys", Type = "number", Nilable = false, Documentation = { "The number of entries with positive integral keys." } },
				{ Name = "maxPositiveIntegerKey", Type = "number", Nilable = false, Documentation = { "The largest positive integral key in the table, or zero if no such keys were found." } },
			},
		},
		{
			Name = "values",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns an array containing the values of the specified table." },

			Arguments =
			{
				{ Name = "table", Type = "table", Nilable = false, Documentation = { "The table whose values will be returned." } },
			},

			Returns =
			{
				{ Name = "values", Type = "any", Nilable = false, Documentation = { "An array containing the table's values. The order of the returned values is unspecified." } },
			},
		},
		{
			Name = "isempty",
			Type = "Function",
			SecretWhenLuaTableHasSecretKeys = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if the table contains no entries." },

			Arguments =
			{
				{ Name = "table", Type = "table", Nilable = false },
			},

			Returns =
			{
				{ Name = "empty", Type = "bool", Nilable = false, Documentation = { "True if the table contains no entries; otherwise false." } },
			},
		},
		{
			Name = "isfrozen",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns true if a table has been marked as frozen." },

			Arguments =
			{
				{ Name = "table", Type = "table", Nilable = false, Documentation = { "The table to inspect." } },
			},

			Returns =
			{
				{ Name = "frozen", Type = "bool", Nilable = false, Documentation = { "True if the table has been made read-only; otherwise false." } },
			},
		},
		{
			Name = "removeunordered",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Removes the value at the specified integer index by replacing it with the last value in the array and shortening the array by one element. The order of values in the array is not preserved." },

			Arguments =
			{
				{ Name = "table", Type = "table", Nilable = false, Documentation = { "The table from which to remove a value." } },
				{ Name = "index", Type = "number", Nilable = true, Documentation = { "The integer index of the value to remove. If omitted, the last value is removed." } },
			},

			Returns =
			{
				{ Name = "value", Type = "any", Nilable = true, Documentation = { "The removed value, or nil if the index is outside the array bounds." } },
			},
		},
		{
			Name = "removevalue",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Removes all values equal to the specified value from the array portion of a table." },

			Arguments =
			{
				{ Name = "table", Type = "table", Nilable = false, Documentation = { "The table from which to remove values." } },
				{ Name = "value", Type = "any", Nilable = true, Documentation = { "The value to remove." } },
			},

			Returns =
			{
				{ Name = "removedCount", Type = "number", Nilable = false, Documentation = { "The number of values removed." } },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(LuaTableExtensions);