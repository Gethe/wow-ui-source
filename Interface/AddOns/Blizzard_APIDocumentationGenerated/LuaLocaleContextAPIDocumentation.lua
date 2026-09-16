local LuaLocaleContextAPI =
{
	Name = "LuaLocaleContextAPI",
	Type = "ScriptObject",
	ObjectType = "Userdata",
	Namespace = "C_LocaleContext",
	Environment = "All",

	Functions =
	{
		{
			Name = "CompareStrings",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Compares two UTF-8 strings using the options specified on a collator." },

			Arguments =
			{
				{ Name = "left", Type = "cstring", Nilable = false, Documentation = { "The first UTF-8 string passed to collation comparison." } },
				{ Name = "right", Type = "cstring", Nilable = false, Documentation = { "The second UTF-8 string passed to collation comparison." } },
				{ Name = "strength", Type = "CollationStrength", Nilable = false, Documentation = { "The comparison level used by the collator for ordering and equality." } },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false, Documentation = { "The comparison result: less than, equal to, or greater than zero." } },
			},
		},
		{
			Name = "FindBreaks",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Opens a break iterator for locating text boundaries in the context locale." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 text whose boundary offsets are requested." } },
				{ Name = "breakType", Type = "BreakType", Nilable = false, Documentation = { "The break iterator kind to use for boundary analysis." } },
			},

			Returns =
			{
				{ Name = "byteOffsets", Type = "table", InnerType = "number", Nilable = false, Documentation = { "The native UTF-8 string indices for the text boundaries." } },
			},
		},
		{
			Name = "FindStringMatches",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Creates a string search iterator using a collator and returns every match position." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 text scanned by the string search iterator." } },
				{ Name = "pattern", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 pattern whose collation-aware matches are returned." } },
				{ Name = "strength", Type = "CollationStrength", Nilable = false, Documentation = { "The comparison level used by the collator while searching for matches." } },
			},

			Returns =
			{
				{ Name = "byteOffsets", Type = "table", InnerType = "number", Nilable = false, Documentation = { "The UTF-8 byte offsets of matches in the text." } },
			},
		},
		{
			Name = "FoldCase",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Case-folds the characters in a string; case-folding is locale-independent and not context-sensitive." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 text converted with locale-independent case folding." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The case-folded string, which may be longer or shorter than the original." } },
			},
		},
		{
			Name = "FormatCurrency",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Formats a double as a localized currency value using the provided ISO 4217 currency code." },

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false, Documentation = { "The double value formatted by the locale currency formatter." } },
				{ Name = "currencyCode", Type = "cstring", Nilable = false, Documentation = { "The 3-letter null-terminated ISO 4217 currency code for currency formatting." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The localized currency text produced by the formatter." } },
			},
		},
		{
			Name = "FormatDate",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Formats Unix time as localized date text using locale date patterns, symbols, style, and optional time zone." },

			Arguments =
			{
				{ Name = "unixTimeSeconds", Type = "number", Nilable = false, Documentation = { "The date as seconds since the Unix epoch; this API converts it to milliseconds." } },
				{ Name = "style", Type = "DateTimeStyle", Nilable = false, Documentation = { "The date format length; None omits the date portion." } },
				{ Name = "timeZone", Type = "cstring", Nilable = false, Documentation = { "The time zone ID applied to the formatter; empty strings keep the formatter default." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The formatted date string." } },
			},
		},
		{
			Name = "FormatDateTime",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Formats Unix time as localized date and time text using locale patterns, symbols, styles, and optional time zone." },

			Arguments =
			{
				{ Name = "unixTimeSeconds", Type = "number", Nilable = false, Documentation = { "The date and time as seconds since the Unix epoch; this API converts it to milliseconds." } },
				{ Name = "dateStyle", Type = "DateTimeStyle", Nilable = false, Documentation = { "The date format length; None omits the date portion." } },
				{ Name = "timeStyle", Type = "DateTimeStyle", Nilable = false, Documentation = { "The time format length; None omits the time portion." } },
				{ Name = "timeZone", Type = "cstring", Nilable = false, Documentation = { "The time zone ID applied to the formatter; empty strings keep the formatter default." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The formatted date and time string." } },
			},
		},
		{
			Name = "FormatNumber",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Formats a double with locale number formatting using locale symbols, grouping, and the selected non-currency style." },

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false, Documentation = { "The double value formatted according to the selected number formatter." } },
				{ Name = "style", Type = "NumberStyle", Nilable = false, Documentation = { "The number style to format with; Currency is not accepted here, use FormatCurrency instead." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The localized number text produced by the formatter." } },
			},
		},
		{
			Name = "FormatTime",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Formats Unix time as localized time text using locale time patterns, symbols, style, and optional time zone." },

			Arguments =
			{
				{ Name = "unixTimeSeconds", Type = "number", Nilable = false, Documentation = { "The time as seconds since the Unix epoch; this API converts it to milliseconds." } },
				{ Name = "style", Type = "DateTimeStyle", Nilable = false, Documentation = { "The time format length; None omits the time portion." } },
				{ Name = "timeZone", Type = "cstring", Nilable = false, Documentation = { "The time zone ID applied to the formatter; empty strings keep the formatter default." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The formatted time string." } },
			},
		},
		{
			Name = "GetCurrencyName",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the display name for a currency in the context locale." },

			Arguments =
			{
				{ Name = "currencyCode", Type = "cstring", Nilable = false, Documentation = { "The null-terminated 3-letter ISO 4217 currency code." } },
				{ Name = "style", Type = "CurrencyNameStyle", Nilable = false, Documentation = { "The selector for which kind of currency name to return." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The display string for the currency, or the currency code itself if no localized name is available." } },
			},
		},
		{
			Name = "GetDisplayName",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Gets a display name suitable for the specified locale." },

			Arguments =
			{
				{ Name = "displayLocale", Type = "cstring", Nilable = false, Documentation = { "The locale whose language conventions are used for the display name" } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The displayable name for the locale." } },
			},
		},
		{
			Name = "GetLocale",
			Type = "Function",
			Documentation = { "Gets the locale used by this locale context." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The locale ID of this locale context." } },
			},
		},
		{
			Name = "GetSortKey",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Transforms a string into a collation sort key." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 text converted into collation sort-key bytes." } },
				{ Name = "strength", Type = "CollationStrength", Nilable = false, Documentation = { "The comparison level used by the collator; lower strengths ignore later-level differences." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The sort key bytes excluding the terminating zero byte." } },
			},
		},
		{
			Name = "Length",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Counts character break boundaries in UTF-8 text." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 text counted by character break iteration." } },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false, Documentation = { "The number of character boundaries minus the initial boundary." } },
			},
		},
		{
			Name = "ParseCurrency",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Parses an entire localized currency string into a double amount and ISO 4217 currency code." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The localized currency text to parse for both amount and ISO 4217 code." } },
			},

			Returns =
			{
				{ Name = "result", Type = "CurrencyParseResult", Nilable = false, Documentation = { "The numeric amount and ISO 4217 currency code parsed from the localized currency text." } },
			},
		},
		{
			Name = "ParseNumber",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Parses an entire localized number string into a double using the selected non-currency number formatter." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The localized numeric text to parse with the selected style." } },
				{ Name = "style", Type = "NumberStyle", Nilable = false, Documentation = { "The number style to parse with; Currency is not accepted here, use ParseCurrency instead." } },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false, Documentation = { "The numeric value parsed from the localized number text." } },
			},
		},
		{
			Name = "SelectPlural",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the keyword of the first plural rule that applies to a number." },

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false, Documentation = { "The number for which the plural rule has to be determined." } },
				{ Name = "pluralType", Type = "PluralType", Nilable = false, Documentation = { "The plural rule type, cardinal or ordinal." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The plural keyword for the rule that applies to the number." } },
			},
		},
		{
			Name = "SetLocale",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets the locale used by this locale context." },

			Arguments =
			{
				{ Name = "locale", Type = "cstring", Nilable = false, Documentation = { "The locale ID used by subsequent locale context calls." } },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false, Documentation = { "True if the locale was updated." } },
			},
		},
		{
			Name = "ToLower",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Lowercases the characters in a string; casing is locale-dependent and context-sensitive." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 text whose characters are lowercased." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The lowercased string, which may be longer or shorter than the original." } },
			},
		},
		{
			Name = "ToTitle",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Titlecases a string using titlecase positions determined by the default Unicode algorithm." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 text whose titlecase positions are mapped." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The titlecased string, which may be longer or shorter than the original." } },
			},
		},
		{
			Name = "ToUpper",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Uppercases the characters in a string; casing is locale-dependent and context-sensitive." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 text whose characters are uppercased." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The uppercased string, which may be longer or shorter than the original." } },
			},
		},
		{
			Name = "TransformLocale",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Applies a locale transform to the context locale and returns the transformed locale string." },

			Arguments =
			{
				{ Name = "transform", Type = "LocaleTransform", Nilable = false, Documentation = { "The locale transform to apply." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The transformed locale string." } },
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

APIDocumentation:AddDocumentationTable(LuaLocaleContextAPI);