TablesAPIMixin = CreateFromMixins(BaseAPIMixin);

function TablesAPIMixin:GetParentName()
	if self.System then
		return self.System:GetName(); 
	end

	return "";
end

function TablesAPIMixin:GetType()
	return "table";
end

function TablesAPIMixin:GetPrettyType()
	return self.Type:lower();
end

function TablesAPIMixin:GetLinkHexColor()
	return "55ffdd";
end

function TablesAPIMixin:GetFullName() -- override
	if self.Type == "Enumeration" then
		return ("Enum.%s"):format(self:GetName());
	end

	return BaseAPIMixin.GetFullName(self);
end

function TablesAPIMixin:MatchesSearchString(searchString)
	if self:GetLoweredName():match(searchString) then
		return true;
	end

	if self:MatchesAnyDocumentation(searchString) then
		return true;
	end

	if self:MatchesAnyAPI(self.Fields, searchString) then
		return true
	end
	return false;
end

function TablesAPIMixin:GetDetailedOutputLines()
	local lines = {};
	table.insert(lines, self:GetSingleOutputLine());

	self:AddSystemTag(lines);
	self:AddDocumentationTags(lines);

	if self.Fields then
		if self.Type == "Enumeration" then
			table.insert(lines, APIDocumentation:GetIndentString() .. "Num Values: " .. self.NumValues);
			table.insert(lines, APIDocumentation:GetIndentString() .. "Min Value: " .. self.MinValue);
			table.insert(lines, APIDocumentation:GetIndentString() .. "Max Value: " .. self.MaxValue);
			table.insert(lines, APIDocumentation:GetIndentString() .. "Values");
		else
			table.insert(lines, APIDocumentation:GetIndentString() .. "Fields");
		end

		for i, fieldInfo in ipairs(self.Fields) do
			table.insert(lines, APIDocumentation:GetIndentString(2) .. fieldInfo:GetSingleOutputLine());
		end
	end

	return lines;
end