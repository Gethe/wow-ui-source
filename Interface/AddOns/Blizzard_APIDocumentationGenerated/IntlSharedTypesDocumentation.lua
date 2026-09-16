local IntlSharedTypes =
{
	Tables =
	{
		{
			Name = "BreakType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Character", Type = "BreakType", EnumValue = 0, Documentation = { "Locate extended grapheme cluster boundaries, which are treated as user-perceived character units." } },
				{ Name = "Word", Type = "BreakType", EnumValue = 1, Documentation = { "Locate word boundaries for selection, search, and whole-word operations, including locale dictionary support where available." } },
				{ Name = "Sentence", Type = "BreakType", EnumValue = 2, Documentation = { "Locate sentence boundaries while handling cases such as periods in numbers or abbreviations and trailing punctuation." } },
				{ Name = "Line", Type = "BreakType", EnumValue = 3, Documentation = { "Locate positions where text can wrap, using Unicode line-breaking rules that handle punctuation and hyphenated words." } },
			},
		},
		{
			Name = "CollationStrength",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Primary", Type = "CollationStrength", EnumValue = 0, Documentation = { "Compare base-character differences and ignore accents, case, and later collation levels." } },
				{ Name = "Secondary", Type = "CollationStrength", EnumValue = 1, Documentation = { "Compare accent or diacritic differences after base characters match, while ignoring tertiary differences such as case." } },
				{ Name = "Tertiary", Type = "CollationStrength", EnumValue = 2, Documentation = { "Compare case, letter variants, and similar tertiary differences after primary and secondary differences match." } },
				{ Name = "Quaternary", Type = "CollationStrength", EnumValue = 3, Documentation = { "Distinguish punctuation, whitespace, symbols, or Japanese Hiragana/Katakana differences after the first three levels match." } },
				{ Name = "Identical", Type = "CollationStrength", EnumValue = 4, Documentation = { "Use NFD Unicode code point order as a final tie-breaker after all other collation levels match." } },
			},
		},
		{
			Name = "CurrencyNameStyle",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Symbol", Type = "CurrencyNameStyle", EnumValue = 0, Documentation = { "A symbolic name for a currency, such as '$' for USD." } },
				{ Name = "NarrowSymbol", Type = "CurrencyNameStyle", EnumValue = 1, Documentation = { "The shortest narrow currency symbol, such as '$' instead of 'US$' for USD in en-CA." } },
				{ Name = "Long", Type = "CurrencyNameStyle", EnumValue = 2, Documentation = { "The long name for a currency, such as 'US Dollar' for USD." } },
				{ Name = "FormalSymbol", Type = "CurrencyNameStyle", EnumValue = 3, Documentation = { "The formal currency symbol is similar to the regular currency symbol, but it always takes the form used in formal settings such as banking; for example, 'NT$' instead of '$' for TWD in zh-TW." } },
				{ Name = "VariantSymbol", Type = "CurrencyNameStyle", EnumValue = 4, Documentation = { "The variant symbol for a currency is an alternative symbol that is not necessarily as widely used as the regular symbol." } },
			},
		},
		{
			Name = "DateTimeStyle",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "DateTimeStyle", EnumValue = 0, Documentation = { "Do not include this date or time portion in the formatter." } },
				{ Name = "Short", Type = "DateTimeStyle", EnumValue = 1, Documentation = { "Use the shortest locale format, generally numeric, such as 12/13/52 or 3:30pm." } },
				{ Name = "Medium", Type = "DateTimeStyle", EnumValue = 2, Documentation = { "Use a longer locale format than Short, such as abbreviated month names for dates." } },
				{ Name = "Long", Type = "DateTimeStyle", EnumValue = 3, Documentation = { "Use a longer locale format with fuller names or time fields than Medium." } },
				{ Name = "Full", Type = "DateTimeStyle", EnumValue = 4, Documentation = { "Use the most completely specified locale format, such as weekday, era, or time zone when applicable." } },
			},
		},
		{
			Name = "LocaleTransform",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Canonicalize", Type = "LocaleTransform", EnumValue = 0, Documentation = { "Canonicalizes the locale identifier into ICU's canonical locale ID form." } },
				{ Name = "AddLikelySubtags", Type = "LocaleTransform", EnumValue = 1, Documentation = { "Adds likely script and region subtags according to CLDR likely-subtags data." } },
				{ Name = "RemoveLikelySubtags", Type = "LocaleTransform", EnumValue = 2, Documentation = { "Minimizes script and region subtags according to CLDR likely-subtags data." } },
				{ Name = "Language", Type = "LocaleTransform", EnumValue = 3, Documentation = { "Gets the language code from the locale identifier." } },
				{ Name = "Script", Type = "LocaleTransform", EnumValue = 4, Documentation = { "Gets the script code from the locale identifier." } },
				{ Name = "Region", Type = "LocaleTransform", EnumValue = 5, Documentation = { "Gets the region code from the locale identifier." } },
				{ Name = "Variant", Type = "LocaleTransform", EnumValue = 6, Documentation = { "Gets the variant code from the locale identifier." } },
				{ Name = "ParentLocale", Type = "LocaleTransform", EnumValue = 7, Documentation = { "Gets the parent locale identifier." } },
			},
		},
		{
			Name = "NormalizationForm",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Nfc", Type = "NormalizationForm", EnumValue = 0, Documentation = { "Canonical decomposition followed by canonical composition." } },
				{ Name = "Nfd", Type = "NormalizationForm", EnumValue = 1, Documentation = { "Canonical decomposition." } },
				{ Name = "Nfkc", Type = "NormalizationForm", EnumValue = 2, Documentation = { "Compatibility decomposition followed by canonical composition." } },
				{ Name = "Nfkd", Type = "NormalizationForm", EnumValue = 3, Documentation = { "Compatibility decomposition." } },
			},
		},
		{
			Name = "NumberStyle",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Decimal", Type = "NumberStyle", EnumValue = 0, Documentation = { "Use normal decimal number format for the locale." } },
				{ Name = "Integer", Type = "NumberStyle", EnumValue = 1, Documentation = { "Use decimal formatting with zero minimum and maximum fraction digits in this wrapper." } },
				{ Name = "Percent", Type = "NumberStyle", EnumValue = 2, Documentation = { "Use percent number format for the locale." } },
				{ Name = "Currency", Type = "NumberStyle", EnumValue = 3, Documentation = { "Use generic currency format with a currency symbol and non-accounting minus-sign negatives." } },
			},
		},
		{
			Name = "PluralType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Cardinal", Type = "PluralType", EnumValue = 0, Documentation = { "Use plural rules for counted quantities, such as 1 file vs. 2 files." } },
				{ Name = "Ordinal", Type = "PluralType", EnumValue = 1, Documentation = { "Use plural rules for ordered values, such as 1st, 2nd, 3rd, and 4th." } },
			},
		},
		{
			Name = "CharacterProperties",
			Type = "Structure",
			Documentation = { "Unicode property values for the first code point in a string." },
			Fields =
			{
				{ Name = "codePoint", Type = "number", Nilable = false, Documentation = { "The Unicode code point tested for character properties." } },
				{ Name = "isAlphabetic", Type = "bool", Nilable = false, Documentation = { "True if the code point is a letter character with general category L." } },
				{ Name = "isDigit", Type = "bool", Nilable = false, Documentation = { "True if the code point is a digit character with general category Nd." } },
				{ Name = "isWhitespace", Type = "bool", Nilable = false, Documentation = { "True if the code point has the Unicode White_Space property." } },
				{ Name = "generalCategory", Type = "string", Nilable = false, Documentation = { "The short Unicode property value name for the code point's general category." } },
				{ Name = "scriptCode", Type = "string", Nilable = false, Documentation = { "The short ISO 15924 script code for the code point's script." } },
				{ Name = "blockCode", Type = "string", Nilable = false, Documentation = { "The short Unicode property value name for the code point's block." } },
			},
		},
		{
			Name = "CurrencyParseResult",
			Type = "Structure",
			Documentation = { "A parsed numeric amount and currency from a localized currency string." },
			Fields =
			{
				{ Name = "amount", Type = "number", Nilable = false, Documentation = { "The numeric amount parsed by the currency parser." } },
				{ Name = "currencyCode", Type = "string", Nilable = false, Documentation = { "The ISO 4217 currency code parsed alongside the amount." } },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(IntlSharedTypes);