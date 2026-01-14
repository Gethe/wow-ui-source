FunctionsAPIMixin = CreateFromMixins(BaseAPIMixin);

function FunctionsAPIMixin:GetParentName()
	if self.System then
		return self.System:GetName(); 
	end

	return "";
end

function FunctionsAPIMixin:GetType()
	return "function";
end

function FunctionsAPIMixin:GetLinkHexColor()
	return "55ddff";
end

function FunctionsAPIMixin:GetFullName(decorateOptionals, includeColorCodes)
	if self.System and self.System:GetNamespaceName() ~= "" then
		return ("%s.%s(%s)"):format(self.System:GetNamespaceName(), self:GetName(), self:GetArgumentString(decorateOptionals, includeColorCodes));
	end
	return ("%s(%s)"):format(self:GetName(), self:GetArgumentString(decorateOptionals, includeColorCodes));
end

function FunctionsAPIMixin:MatchesSearchString(searchString)
	if self:GetLoweredName():match(searchString) then
		return true;
	end

	if self:MatchesAnyDocumentation(searchString) then
		return true;
	end

	if self:MatchesAnyAPI(self.Arguments, searchString) then
		return true
	end

	if self:MatchesAnyAPI(self.Returns, searchString) then
		return true
	end

	return false;
end

function FunctionsAPIMixin:GetArgumentString(decorateOptionals, includeColorCodes)
	if self.Arguments then
		local values = {};
		for i, argumentInfo in ipairs(self.Arguments) do
			if includeColorCodes ~= false then
				table.insert(values, ("%s|cff%s"):format(argumentInfo:GetArgumentString(decorateOptionals, includeColorCodes), self:GetLinkHexColor()));
			else
				table.insert(values, argumentInfo:GetArgumentString(decorateOptionals, includeColorCodes));
			end
		end
		return table.concat(values, ", ");
	end
	return "";
end

function FunctionsAPIMixin:GetReturnString(decorateOptionals, includeColorCodes)
	if self.Returns then
		local values = {};
		for i, returnInfo in ipairs(self.Returns) do
			if includeColorCodes ~= false then
				table.insert(values, ("%s|cff%s"):format(returnInfo:GetReturnString(decorateOptionals, includeColorCodes), self:GetLinkHexColor()));
			else
				table.insert(values, returnInfo:GetReturnString(decorateOptionals, includeColorCodes));
			end
		end
		return table.concat(values, ", ");
	end
	return "";
end

function FunctionsAPIMixin:GetClipboardString()
	if self.Returns then
		return ("local %s = %s"):format(self:GetReturnString(false, false), self:GetFullName(false, false));
	end
	return self:GetFullName(false, false);
end

function FunctionsAPIMixin:GetDetailedOutputLines()
	local lines = {};
	table.insert(lines, self:GetSingleOutputLine());

	self:AddSystemTag(lines);
	self:AddDocumentationTags(lines);

	if self.Arguments then
		table.insert(lines, APIDocumentation:GetIndentString() .. "Arguments");
		for i, argumentInfo in ipairs(self.Arguments) do
			if argumentInfo:GetStrideIndex() == 1 then
				table.insert(lines, APIDocumentation:GetIndentString(2) .. "(Variable arguments)");
			end

			table.insert(lines, APIDocumentation:GetIndentString(2) .. ("%d. %s"):format(i, argumentInfo:GetSingleOutputLine()));
		end
	end

	if self.Returns then
		table.insert(lines, APIDocumentation:GetIndentString() .. "Returns");
		for i, returnInfo in ipairs(self.Returns) do
			if returnInfo:GetStrideIndex() == 1 then
				table.insert(lines, APIDocumentation:GetIndentString(2) .. "(Variable returns)");
			end
			table.insert(lines, APIDocumentation:GetIndentString(2) .. ("%d. %s"):format(i, returnInfo:GetSingleOutputLine()));
		end
	end

	return lines;
end