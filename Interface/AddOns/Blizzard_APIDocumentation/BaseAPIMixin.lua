BaseAPIMixin = {};

function BaseAPIMixin:GetType()
	return assert(false);
end

function BaseAPIMixin:GetPrettyType()
	return self:GetType();
end

function BaseAPIMixin:GetLinkHexColor()
	return "ffffff";
end

function BaseAPIMixin:GetName()
	return self.Name;
end

function BaseAPIMixin:GetFullName()
	return self:GetName();
end

function BaseAPIMixin:GetParentName()
	return "";
end

function BaseAPIMixin:GetLoweredParentName()
	if not self.loweredParentName then
		self.loweredParentName = self:GetParentName():lower();
	end
	return self.loweredParentName;
end

function BaseAPIMixin:GetLoweredName()
	if not self.loweredName then
		self.loweredName = self:GetName():lower();
	end
	return self.loweredName;
end

function BaseAPIMixin:GetClipboardString()
	return self:GetFullName();
end

function BaseAPIMixin:GenerateAPILink()
	return ("|cff%s|Hapi:%s:%s:%s|h%s|h|r"):format(self:GetLinkHexColor(), self:GetType(), self:GetName(), self:GetParentName(), self:GetFullName());
end

function BaseAPIMixin:GetSingleOutputLine()
	return ("%s %s"):format(self:GetPrettyType(), self:GenerateAPILink());
end

function BaseAPIMixin:GetDetailedOutputLines()
	return { self:GetSingleOutputLine() };
end

function BaseAPIMixin:MatchesSearchString(searchString)
	return false;
end

function BaseAPIMixin:MatchesName(name, parentName)
	if name == self:GetName() then
		return not parentName or parentName == self:GetParentName();
	end
	return false;
end

function BaseAPIMixin:MatchesNameCaseInsenstive(name, parentName)
	if name == self:GetLoweredName() then
		return not parentName or parentName == self:GetLoweredParentName();
	end
	return false;
end

function BaseAPIMixin:MatchesAnyAPI(apiTable, searchString)
	if apiTable then
		for i, apiInfo in ipairs(apiTable) do
			if apiInfo:MatchesSearchString(searchString) then
				return true;
			end
		end
	end
	return false;
end

function BaseAPIMixin:MatchesAnyDocumentation(searchString)
	if self.Documentation then
		for i, documentation in ipairs(self.Documentation) do
			if documentation:lower():match(searchString) then
				return true;
			end
		end
	end
end

function BaseAPIMixin:AddDocumentationTags(lines)
	if self.Documentation then
		for i, documentation in ipairs(self.Documentation) do
			table.insert(lines, APIDocumentation:GetIndentString() .. documentation);
		end
	end
end

function BaseAPIMixin:AddSystemTag(lines)
	if self.System then
		table.insert(lines, APIDocumentation:GetIndentString() .. ("Part of the %s system"):format(self.System:GenerateAPILink()));
	end
end
