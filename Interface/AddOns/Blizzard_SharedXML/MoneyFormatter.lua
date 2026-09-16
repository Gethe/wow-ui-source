local DenominationOrderDescending = {
	Enum.CurrencyType.Gold,
	Enum.CurrencyType.Silver,
	Enum.CurrencyType.Copper,
};

MoneyFormatterDisplayMode = {
	Texture = 1, -- Prefer coin texture atlases for denominations. If the colorblindMode CVar is 1, Abbreviated style is used instead.
	Abbreviated = 2, -- Prefer abbreviated symbols for denominations ('1g').
	Full = 3, -- Prefer full names for denominations ('1 Gold').
};

MoneyFormatterZeroDisplayMode = {
	Collapse = 1, -- Avoid rendering zero values for any denominations (10001 -> '1g 1c', 0 -> '').
	ShowLower = 2, -- Show zero values for denominations below the first denomination with a non-zero value (100 -> '1s 0c').
	ShowAll = 3, -- Show zero values for all denominations (0 -> '0g 0s 0c').
};

MoneyFormatterConfigMixin = {};

MoneyFormatterConfigMixin.DenominationAtlases = {
	[Enum.CurrencyType.Copper] = "coin-copper",
	[Enum.CurrencyType.Silver] = "coin-silver",
	[Enum.CurrencyType.Gold] = "coin-gold",
};

MoneyFormatterConfigMixin.DenominationAbbreviations = {
	-- Note that these are not format strings - they need to be concatenated onto the end of the value.
	[Enum.CurrencyType.Copper] = COPPER_AMOUNT_SYMBOL,
	[Enum.CurrencyType.Silver] = SILVER_AMOUNT_SYMBOL,
	[Enum.CurrencyType.Gold] = GOLD_AMOUNT_SYMBOL,
};

MoneyFormatterConfigMixin.DenominationFullTexts = {
	[Enum.CurrencyType.Copper] = COPPER_AMOUNT,
	[Enum.CurrencyType.Silver] = SILVER_AMOUNT,
	[Enum.CurrencyType.Gold] = GOLD_AMOUNT,
};

function MoneyFormatterConfigMixin:Init()
	self.displayMode = MoneyFormatterDisplayMode.Texture;
	self.zeroDisplayMode = MoneyFormatterZeroDisplayMode.Collapse;
	self.valueFormatter = nil; -- Optional formatter invoked with (value, denomination).
	self.zeroDisplayText = nil; -- Optional static override specifically for rawCopper == 0.
	self.showMinDenominationAtZero = false; -- If true, rawCopper == 0 renders the minimum denomination with a zero value.
	self.minDenomination = Enum.CurrencyType.Copper; -- Minimum denomination unit to render.
	-- Parameters for texture/atlas markup formatting.
	self.textureWidth = 14;
	self.textureHeight = 14;
	self.textureOffsetX = 2;
	self.textureOffsetY = 0;
end

function MoneyFormatterConfigMixin:GetDisplayMode()
	return self.displayMode;
end

function MoneyFormatterConfigMixin:SetDisplayMode(mode)
	self.displayMode = mode;
end

function MoneyFormatterConfigMixin:GetMinDenomination()
	return self.minDenomination;
end

function MoneyFormatterConfigMixin:SetMinDenomination(denomination)
	self.minDenomination = denomination;
end

function MoneyFormatterConfigMixin:GetValueFormatter()
	return self.valueFormatter;
end

function MoneyFormatterConfigMixin:SetValueFormatter(func)
	self.valueFormatter = func;
end

function MoneyFormatterConfigMixin:GetZeroDisplayMode()
	return self.zeroDisplayMode;
end

function MoneyFormatterConfigMixin:SetZeroDisplayMode(mode)
	self.zeroDisplayMode = mode;
end

function MoneyFormatterConfigMixin:GetZeroDisplayText()
	return self.zeroDisplayText;
end

function MoneyFormatterConfigMixin:SetZeroDisplayText(text)
	self.zeroDisplayText = text;
end

function MoneyFormatterConfigMixin:GetShowMinDenominationAtZero()
	return self.showMinDenominationAtZero;
end

function MoneyFormatterConfigMixin:SetShowMinDenominationAtZero(showAtZero)
	self.showMinDenominationAtZero = showAtZero;
end

function MoneyFormatterConfigMixin:GetTextureMarkupOptions()
	return self.textureWidth, self.textureHeight, self.textureOffsetX, self.textureOffsetY;
end

function MoneyFormatterConfigMixin:SetTextureMarkupOptions(textureWidth, textureHeight, textureOffsetX, textureOffsetY)
	self.textureWidth = textureWidth;
	self.textureHeight = textureHeight;
	self.textureOffsetX = textureOffsetX or 0;
	self.textureOffsetY = textureOffsetY or 0;
end

function MoneyFormatterConfigMixin:GetDenominationAbbreviation(denomination)
	return self.DenominationAbbreviations[denomination];
end

function MoneyFormatterConfigMixin:GetDenominationAtlas(denomination)
	return self.DenominationAtlases[denomination];
end

function MoneyFormatterConfigMixin:GetDenominationFullText(denomination)
	return self.DenominationFullTexts[denomination];
end

MoneyFormatterUtil = {};

function MoneyFormatterUtil.CreateFormatterConfig()
	return CreateAndInitFromMixin(MoneyFormatterConfigMixin);
end

function MoneyFormatterUtil.GetAppropriateDisplayMode(config)
	local displayMode = config:GetDisplayMode();

	if displayMode == MoneyFormatterDisplayMode.Texture then
		if CVarCallbackRegistry:GetCVarValueBool("colorblindMode") then
			return MoneyFormatterDisplayMode.Abbreviated;
		end
	end

	return displayMode;
end

function MoneyFormatterUtil.GetDenominationAmount(rawCopper, denomination)
	if denomination == Enum.CurrencyType.Gold then
		return math.floor(rawCopper / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	elseif denomination == Enum.CurrencyType.Silver then
		return math.floor(rawCopper / COPPER_PER_SILVER) % SILVER_PER_GOLD;
	elseif denomination == Enum.CurrencyType.Copper then
		return math.fmod(rawCopper, COPPER_PER_SILVER);
	end

	assertsafe(false, "attempted to get value for an unsupported denomination");
	return 0;
end

function MoneyFormatterUtil.FormatDenominationValue(config, denomination, amount)
	local valueFormatter = config:GetValueFormatter();
	local formattedValue;

	if valueFormatter ~= nil then
		formattedValue = valueFormatter(amount, denomination);
	end

	if formattedValue == nil then
		formattedValue = tostring(amount);
	end

	return formattedValue;
end

function MoneyFormatterUtil.FormatTextureDenomination(config, denomination, formattedValue)
	return formattedValue .. CreateAtlasMarkup(config:GetDenominationAtlas(denomination), config:GetTextureMarkupOptions());
end

function MoneyFormatterUtil.FormatAbbreviatedDenomination(config, denomination, formattedValue)
	return formattedValue .. config:GetDenominationAbbreviation(denomination);
end

function MoneyFormatterUtil.FormatFullDenomination(config, denomination, formattedValue)
	return string.format(config:GetDenominationFullText(denomination), formattedValue);
end

function MoneyFormatterUtil.FormatDenomination(config, denomination, amount)
	local formattedValue = MoneyFormatterUtil.FormatDenominationValue(config, denomination, amount);
	local displayMode = MoneyFormatterUtil.GetAppropriateDisplayMode(config);

	if displayMode == MoneyFormatterDisplayMode.Texture then
		return MoneyFormatterUtil.FormatTextureDenomination(config, denomination, formattedValue);
	elseif displayMode == MoneyFormatterDisplayMode.Abbreviated then
		return MoneyFormatterUtil.FormatAbbreviatedDenomination(config, denomination, formattedValue);
	elseif displayMode == MoneyFormatterDisplayMode.Full then
		return MoneyFormatterUtil.FormatFullDenomination(config, denomination, formattedValue);
	end

	assertsafe(false, "attempted to format denomination with an unsupported display mode");
	return formattedValue;
end

function MoneyFormatterUtil.ShouldIncludeDenomination(config, denomination, amount, hasStartedOutput, rawCopper)
	local shouldInclude = false;
	local zeroDisplayMode = config:GetZeroDisplayMode();

	if zeroDisplayMode == MoneyFormatterZeroDisplayMode.ShowAll then
		shouldInclude = true;
	elseif zeroDisplayMode == MoneyFormatterZeroDisplayMode.Collapse then
		shouldInclude = amount > 0;
	elseif zeroDisplayMode == MoneyFormatterZeroDisplayMode.ShowLower then
		shouldInclude = amount > 0 or hasStartedOutput;
	else
		assertsafe(false, "attempted to evaluate inclusion for an unsupported zero display mode");
		shouldInclude = amount > 0;
	end

	-- Technically, this logic could be done first. But, keeping it this way
	-- ensures that we consistently triggerName assertsafe validation of the
	-- zeroDisplayMode rather than have it be skipped for some inputs.
	if rawCopper == 0 and config:GetShowMinDenominationAtZero() and denomination == config:GetMinDenomination() then
		shouldInclude = true;
	end

	return shouldInclude;
end

function MoneyFormatterUtil.FormatMoney(rawCopper, config)
	if not assertsafe(rawCopper >= 0, "attempted to format a negative copper value") then
		-- Negative amount formatting is not presently supported. Format such values as zero instead.
		rawCopper = 0;
	end

	if rawCopper == 0 then
		local zeroDisplayText = config:GetZeroDisplayText();

		if zeroDisplayText then
			return zeroDisplayText;
		end
	end

	local parts = {};
	local hasStartedOutput = false;

	for _, denomination in ipairs(DenominationOrderDescending) do
		if denomination >= config:GetMinDenomination() then
			local amount = MoneyFormatterUtil.GetDenominationAmount(rawCopper, denomination);

			if MoneyFormatterUtil.ShouldIncludeDenomination(config, denomination, amount, hasStartedOutput, rawCopper) then
				table.insert(parts, MoneyFormatterUtil.FormatDenomination(config, denomination, amount));
				hasStartedOutput = true;
			end
		end
	end

	return table.concat(parts, " ");
end

function MoneyFormatterUtil.BreakUpLargeNumbers(amount, denomination)
	if denomination == Enum.CurrencyType.Gold then
		return BreakUpLargeNumbers(amount);
	else
		return tostring(amount);
	end
end

MoneyFormatterPresets = {};

-- Formats a compact representation of money with zero denominations omitted (10001 -> "1g 1c", 0 -> "").
MoneyFormatterPresets.Compact = MoneyFormatterUtil.CreateFormatterConfig();
MoneyFormatterPresets.Compact:SetDisplayMode(MoneyFormatterDisplayMode.Texture);
MoneyFormatterPresets.Compact:SetZeroDisplayMode(MoneyFormatterZeroDisplayMode.Collapse);
MoneyFormatterPresets.Compact:SetValueFormatter(MoneyFormatterUtil.BreakUpLargeNumbers);

-- Formats a compact representation of money with zero denominations omitted, except at zero itself (10001 -> "1g 1c", 0 -> "0c").
MoneyFormatterPresets.CompactWithZero = MoneyFormatterUtil.CreateFormatterConfig();
MoneyFormatterPresets.CompactWithZero:SetDisplayMode(MoneyFormatterDisplayMode.Texture);
MoneyFormatterPresets.CompactWithZero:SetZeroDisplayMode(MoneyFormatterZeroDisplayMode.Collapse);
MoneyFormatterPresets.CompactWithZero:SetShowMinDenominationAtZero(true);
MoneyFormatterPresets.CompactWithZero:SetValueFormatter(MoneyFormatterUtil.BreakUpLargeNumbers);

-- Formats money while showing lower denominations after the first shown denomination (10001 -> "1g 0s 1c", 100 -> "1s 0c", 0 -> "0c").
MoneyFormatterPresets.ShowLowerWithZero = MoneyFormatterUtil.CreateFormatterConfig();
MoneyFormatterPresets.ShowLowerWithZero:SetDisplayMode(MoneyFormatterDisplayMode.Texture);
MoneyFormatterPresets.ShowLowerWithZero:SetZeroDisplayMode(MoneyFormatterZeroDisplayMode.ShowLower);
MoneyFormatterPresets.ShowLowerWithZero:SetShowMinDenominationAtZero(true);
MoneyFormatterPresets.ShowLowerWithZero:SetValueFormatter(MoneyFormatterUtil.BreakUpLargeNumbers);

-- Formats an expanded representation of money with all zero denominations included (10001 -> "1g 0s 1c", 0 -> "0g 0s 0c").
MoneyFormatterPresets.ShowAll = MoneyFormatterUtil.CreateFormatterConfig();
MoneyFormatterPresets.ShowAll:SetDisplayMode(MoneyFormatterDisplayMode.Texture);
MoneyFormatterPresets.ShowAll:SetZeroDisplayMode(MoneyFormatterZeroDisplayMode.ShowAll);
MoneyFormatterPresets.ShowAll:SetValueFormatter(MoneyFormatterUtil.BreakUpLargeNumbers);
