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