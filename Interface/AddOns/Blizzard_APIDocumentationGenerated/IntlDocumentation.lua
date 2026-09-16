local Intl =
{
	Name = "Intl",
	Type = "System",
	Namespace = "C_Intl",
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
			Name = "CreateLocaleContext",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Creates a locale context object for locale-scoped internationalization operations." },

			Arguments =
			{
				{ Name = "locale", Type = "cstring", Nilable = false, Documentation = { "The locale ID used to initialize the locale context object." } },
			},

			Returns =
			{
				{ Name = "context", Type = "LuaLocaleContext", Nilable = false, Documentation = { "A locale context userdata object for calling locale-scoped APIs." } },
			},
		},
		{
			Name = "FindBreaks",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Opens a break iterator for locating text boundaries in a specified locale." },

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
			Name = "GetCharacterProperties",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns Unicode property values for the first code point in a string." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The string whose first code point is tested." } },
			},

			Returns =
			{
				{ Name = "result", Type = "CharacterProperties", Nilable = false, Documentation = { "Unicode property values for the first code point." } },
			},
		},
		{
			Name = "GetCurrencyFractionDigits",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the number of fraction digits that should be displayed for the given currency." },

			Arguments =
			{
				{ Name = "currencyCode", Type = "cstring", Nilable = false, Documentation = { "The null-terminated 3-letter ISO 4217 currency code." } },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false, Documentation = { "The non-negative number of fraction digits to be displayed, or 0 if the lookup fails." } },
			},
		},
		{
			Name = "GetCurrencyName",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the display name for a currency in the given locale." },

			Arguments =
			{
				{ Name = "currencyCode", Type = "cstring", Nilable = false, Documentation = { "The null-terminated 3-letter ISO 4217 currency code." } },
				{ Name = "nameStyle", Type = "CurrencyNameStyle", Nilable = false, Documentation = { "The selector for which kind of currency name to return." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The display string for the currency, or the currency code itself if no localized name is available." } },
			},
		},
		{
			Name = "GetCurrentLocale",
			Type = "Function",
			Documentation = { "Gets the current locale used by C_Intl." },

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false, Documentation = { "The current locale ID." } },
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
				{ Name = "sortKey", Type = "string", Nilable = false, Documentation = { "The sort key bytes excluding the terminating zero byte." } },
			},
		},
		{
			Name = "IsNormalized",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Tests if the string is normalized according to the specified normalization form." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 text checked against the requested normalization form." } },
				{ Name = "form", Type = "NormalizationForm", Nilable = false, Documentation = { "The normalization form to test against." } },
			},

			Returns =
			{
				{ Name = "isNormalized", Type = "bool", Nilable = false, Documentation = { "True if the string is normalized according to the specified form." } },
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
			Name = "Normalize",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Writes the normalized form of the source string to the destination string." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 text that is normalized." } },
				{ Name = "form", Type = "NormalizationForm", Nilable = false, Documentation = { "The normalization form to write." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The normalized form of the source string." } },
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
			Documentation = { "Applies a locale transform to the current locale and returns the transformed locale string." },

			Arguments =
			{
				{ Name = "transform", Type = "LocaleTransform", Nilable = false, Documentation = { "The locale transform to apply." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The transformed locale string." } },
			},
		},
		{
			Name = "Transliterate",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Opens a system transliterator by ID and transliterates the text in place." },

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false, Documentation = { "The UTF-8 text converted by the opened transliterator." } },
				{ Name = "transliteratorID", Type = "cstring", Nilable = false, Documentation = { "A registered transliterator ID, such as a source-target system transliterator." } },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false, Documentation = { "The UTF-8 text after transliterator rules are applied." } },
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

APIDocumentation:AddDocumentationTable(Intl);