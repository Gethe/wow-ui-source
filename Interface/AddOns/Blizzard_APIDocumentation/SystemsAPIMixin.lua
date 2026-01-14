SystemsAPIMixin = CreateFromMixins(BaseAPIMixin);

function SystemsAPIMixin:GetType()
	return "system";
end

function SystemsAPIMixin:GetLinkHexColor()
	return "ff55dd";
end

function SystemsAPIMixin:GetNamespaceName()
	return self.Namespace or "";
end

function SystemsAPIMixin:GetLoweredNamespaceName()
	if not self.loweredNamespaceName then
		self.loweredNamespaceName = self:GetNamespaceName():lower();
	end
	return self.loweredNamespaceName;
end

function SystemsAPIMixin:MatchesSearchString(searchString)
	if self:GetLoweredName():match(searchString) then
		return true;
	end

	if self:MatchesAnyDocumentation(searchString) then
		return true;
	end

	return false;
end

function SystemsAPIMixin:GetSingleOutputLine()
	if self.Namespace then
		return ("%s %s (%s)"):format(self:GetPrettyType(), self:GenerateAPILink(), self.Namespace);
	end
	return BaseAPIMixin.GetSingleOutputLine(self);
end

function SystemsAPIMixin:GetDetailedOutputLines()
	local lines = {};
	table.insert(lines, self:GetSingleOutputLine());

	self:AddDocumentationTags(lines);

	if self.Functions and #self.Functions > 0 then
		table.insert(lines, APIDocumentation:GetIndentString() .. "Functions");
		for i, functionInfo in ipairs(self.Functions) do
			table.insert(lines, APIDocumentation:GetIndentString(2) .. functionInfo:GetSingleOutputLine());
		end
	end

	if self.Events and #self.Events > 0 then
		table.insert(lines, APIDocumentation:GetIndentString() .. "Events");
		for i, eventInfo in ipairs(self.Events) do
			table.insert(lines, APIDocumentation:GetIndentString(2) .. eventInfo:GetSingleOutputLine());
		end
	end

	if self.Tables and #self.Tables > 0 then
		table.insert(lines, APIDocumentation:GetIndentString() .. "Tables");
		for i, tableInfo in ipairs(self.Tables) do
			table.insert(lines, APIDocumentation:GetIndentString(2) .. tableInfo:GetSingleOutputLine());
		end
	end

	return lines;
end

function SystemsAPIMixin:MatchesName(name, parentName)
	if BaseAPIMixin.MatchesName(self, name, parentName) then
		return true;
	end

	return name == self:GetNamespaceName();
end

function SystemsAPIMixin:MatchesNameCaseInsenstive(name, parentName)
	if BaseAPIMixin.MatchesNameCaseInsenstive(self, name, parentName) then
		return true;
	end

	return name == self:GetLoweredNamespaceName();
end

function SystemsAPIMixin:FindAllAPIMatches(apiToSearchFor)
	apiToSearchFor = apiToSearchFor:lower();

	local matches = {
		tables = {},
		functions = {},
		events = {},
	};

	APIDocumentationMixin:AddAllMatches(self.Tables, matches.tables, apiToSearchFor);
	APIDocumentationMixin:AddAllMatches(self.Functions, matches.functions, apiToSearchFor);
	APIDocumentationMixin:AddAllMatches(self.Events, matches.events, apiToSearchFor);

	-- Only return something if we matched anything
	for name, subTable in pairs(matches) do
		if #subTable > 0 then
			return matches;
		end
	end

	return nil;
end

local function AddAll(apiContainer, matchesContainer)
	if apiContainer then
	    for i, apiInfo in ipairs(apiContainer) do
		    table.insert(matchesContainer, apiInfo); 
	    end
	end
end

function SystemsAPIMixin:ListAllAPI()
	local allAPI = {
		tables = {},
		functions = {},
		events = {},
	};

	AddAll(self.Tables, allAPI.tables);
	AddAll(self.Functions, allAPI.functions);
	AddAll(self.Events, allAPI.events);

	return allAPI;
end

function SystemsAPIMixin:GetNumTables()
	return self.Tables and #self.Tables or 0;
end

function SystemsAPIMixin:GetNumFunctions()
	return self.Functions and #self.Functions or 0;
end

function SystemsAPIMixin:GetNumEvents()
	return self.Events and #self.Events or 0;
end