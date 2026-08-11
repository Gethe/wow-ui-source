function ConfirmationStringMatches(userInput, expectedText)
	return strupper(userInput) == strupper(expectedText);
end

function ConfirmationEditBoxMatches(editBox, expectedText)
	return ConfirmationStringMatches(editBox:GetText(), expectedText);
end

function UserInputNonEmpty(userInput)
	return userInput and strtrim(userInput) ~= "";
end

function UserEditBoxNonEmpty(editBox)
	return UserInputNonEmpty(editBox:GetText());
end

function StringSplitIntoTable(sep, string)
	return { strsplit(sep, string) };
end

function StringContains(string, substring)
	local index = 1;
	local plain = true;
	return string.find(string, substring, index, plain) ~= nil;
end

StringUtil = {};

function StringUtil.RemoveTrailingSpaces(str)
	return str:match("^(.-)%s*$");
end

function StringUtil.JoinAlternatingConditionalColor(delimiter, unmetColor, ...)
	if ( select("#", ...) == 0 ) then
		return nil;
	end

	local text, meetsCondition = ...;
	local joinedString = meetsCondition and text or unmetColor:WrapTextInColorCode(text);
	for i = 3, select("#", ...), 2 do
		text, meetsCondition = select(i, ...);
		local formattedText = meetsCondition and text or unmetColor:WrapTextInColorCode(text);
		joinedString = joinedString .. delimiter .. formattedText;
	end

	return joinedString;
end
