function SplitTextIntoLines(text, delimiter)
	local lines = {};
	local startIndex = 1;
	local foundIndex = string.find(text, delimiter);
	while foundIndex do
		table.insert(lines, text:sub(startIndex, foundIndex - 1));
		startIndex = foundIndex + 2;
		foundIndex = string.find(text, delimiter, startIndex);
	end
	if startIndex <= #text then
		table.insert(lines, text:sub(startIndex));
	end
	return lines;
end

function SplitTextIntoHeaderAndNonHeader(text)
	local foundIndex = string.find(text, "|n");
	if not foundIndex then
		-- There was no newline...the whole thing is a header
		return text;
	elseif #text == 2 then
		-- There was a newline, but that was all that was in the string.
		return nil;
	elseif foundIndex == 1 then
		-- There was a newline at the very beginning...the whole rest of the string is a header
		return text:sub(3);
	elseif foundIndex == #text - 1 then
		-- There was a newline at the very end...the whole rest of the string is a header
		return text:sub(1, foundIndex - 1);
	else
		-- There was a newline somewhere in the middle...everything before it is the header and everything after it is the non-header
		return text:sub(1, foundIndex - 1), text:sub(foundIndex + 2);
	end
end

function FormatValueWithSign(value)
	local formatString = value < 0 and SYMBOLIC_NEGATIVE_NUMBER or SYMBOLIC_POSITIVE_NUMBER;
	return formatString:format(math.abs(value));
end

function FormatLargeNumber(amount)
	amount = tostring(amount);
	local newDisplay = "";
	local strlen = amount:len();
	--Add each thing behind a comma
	for i=4, strlen, 3 do
		newDisplay = LARGE_NUMBER_SEPERATOR..amount:sub(-(i - 1), -(i - 3))..newDisplay;
	end
	--Add everything before the first comma
	newDisplay = amount:sub(1, (strlen % 3 == 0) and 3 or (strlen % 3))..newDisplay;
	return newDisplay;
end

COPPER_PER_SILVER = 100;
SILVER_PER_GOLD = 100;
COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD;

function GetMoneyString(money, separateThousands)
	local goldString, silverString, copperString;
	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);

	if ( CVarCallbackRegistry:GetCVarValueBool("colorblindMode") or ENABLE_COLORBLIND_MODE == "1" ) then
		if (separateThousands) then
			goldString = FormatLargeNumber(gold)..GOLD_AMOUNT_SYMBOL;
		else
			goldString = gold..GOLD_AMOUNT_SYMBOL;
		end
		silverString = silver..SILVER_AMOUNT_SYMBOL;
		copperString = copper..COPPER_AMOUNT_SYMBOL;
	else
		if (separateThousands) then
			goldString = GOLD_AMOUNT_TEXTURE_STRING:format(FormatLargeNumber(gold), 0, 0);
		else
			goldString = GOLD_AMOUNT_TEXTURE:format(gold, 0, 0);
		end
		silverString = SILVER_AMOUNT_TEXTURE:format(silver, 0, 0);
		copperString = COPPER_AMOUNT_TEXTURE:format(copper, 0, 0);
	end

	local moneyString = "";
	local separator = "";
	if ( gold > 0 ) then
		moneyString = goldString;
		separator = " ";
	end
	if ( silver > 0 ) then
		moneyString = moneyString..separator..silverString;
		separator = " ";
	end
	if ( copper > 0 or moneyString == "" ) then
		moneyString = moneyString..separator..copperString;
	end

	return moneyString;
end

function FormatPercentage(percentage, roundToNearestInteger)
	if roundToNearestInteger then
		percentage = Round(percentage * 100);
	else
		percentage = percentage * 100;
	end

	return PERCENTAGE_STRING:format(percentage);
end

function FormatFraction(numerator, denominator)
	return GENERIC_FRACTION_STRING:format(numerator, denominator);
end

function GetHighlightedNumberDifferenceString(baseString, newString)
	local outputString = "";
	-- output string is being built from the new string
	local newStringIndex = 1;
	-- find a stretch of digits (including . and , because of different locales) - but has to end in a digit
	local PATTERN = "([,%.%d]*%d+)";
	local start1, end1, baseNumberString = string.find(baseString, PATTERN);
	local start2, end2, newNumberString = string.find(newString, PATTERN);
	while start1 and start2 do
		-- add from the new string until the matched spot
		outputString = outputString .. string.sub(newString, newStringIndex, start2 - 1);
		newStringIndex = end2 + 1;

		if baseNumberString ~= newNumberString then
			-- need to remove , and . before comparing numbers because of locales
			local scrubbedBaseNumberString = gsub(baseNumberString, "[,%.]", "");
			local scrubbedNewNumberString = gsub(newNumberString, "[,%.]", "");
			local baseNumber = tonumber(scrubbedBaseNumberString);
			local newNumber = tonumber(scrubbedNewNumberString);
			if baseNumber and newNumber then
				local delta = newNumber - baseNumber;
				if delta > 0 then
					newNumberString = GREEN_FONT_COLOR_CODE..string.format(newNumberString)..FONT_COLOR_CODE_CLOSE;
				elseif delta < 0 then
					newNumberString = RED_FONT_COLOR_CODE..string.format(newNumberString)..FONT_COLOR_CODE_CLOSE;
				end
			end
		end

		outputString = outputString..newNumberString;

		start1, end1, baseNumberString = string.find(baseString, PATTERN, end1 + 1);
		start2, end2, newNumberString = string.find(newString, PATTERN, end2 + 1);
	end

	outputString = outputString .. string.sub(newString, newStringIndex, string.len(newString));
	return outputString;
end

function FormatUnreadMailTooltip(tooltip, headerText, senders)
	for i, sender in ipairs(senders) do
		headerText = headerText.."\n"..sender;
	end

	tooltip:SetText(headerText);
end

FormattingUtil = {};

function FormattingUtil.GetCostString(icon, quantity, colorCode, abbreviate)
	colorCode = colorCode or HIGHLIGHT_FONT_COLOR_CODE;

	local markup = CreateTextureMarkup(icon, 64, 64, 16, 16, 0, 1, 0, 1);
	local amountString;
	if abbreviate then
		amountString = AbbreviateNumbers(quantity);
	else
		amountString = BreakUpLargeNumbers(quantity);
	end
	return ("%s%s %s|r"):format(colorCode, amountString, markup);
end

function FormattingUtil.GetItemCostString(itemID, quantity, colorCode, abbreviate)
	local icon = C_Item.GetItemIconByID(itemID);
	if icon then
		return FormattingUtil.GetCostString(icon, quantity, colorCode, abbreviate);
	end

	return "";
end

function GetCurrencyString(currencyID, overrideAmount, colorCode, abbreviate)
	colorCode = colorCode or HIGHLIGHT_FONT_COLOR_CODE;

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
	if currencyInfo then
		local quantity = overrideAmount or currencyInfo.quantity;
		return FormattingUtil.GetCostString(currencyInfo.iconFileID, quantity, colorCode, abbreviate);
	end

	return "";
end

function GetCurrenciesString(currencies)
	local text = nil;
	for i, currency in ipairs(currencies) do
		if text then
			text = text.." ";
		else
			text = "";
		end

		if type(currency) == "table" then
			if currency.currencyID and currency.amount then
				text = text..GetCurrencyString(currency.currencyID, currency.amount, currency.colorCode);
			else
				text = text..GetCurrencyString(unpack(currency));
			end
		else
			text = text..GetCurrencyString(currency);
		end
	end

	return text;
end

function ReplaceGenderTokens(string, gender)
	if not strfind(string, "%$") then
		return string;
	end

	-- This is a very simple parser that will only handle $G/$g tokens
	return gsub(string, "$[Gg]([^:]+):([^;]+);", "%"..gender);
end
