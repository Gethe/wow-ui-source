EventsAPIMixin = CreateFromMixins(BaseAPIMixin);

function EventsAPIMixin:GetParentName() -- override
	if self.System then
		return self.System:GetName(); 
	end

	return "";
end

function EventsAPIMixin:GetType() -- override
	return "event";
end

function EventsAPIMixin:GetLinkHexColor()
	return "77ff22";
end

function EventsAPIMixin:GetClipboardString()
	local lines = {};
	table.insert(lines, ([[if event == "%s" then]]):format(self.LiteralName));
	table.insert(lines, ("\tlocal %s = ...;"):format(self:GetPayloadString(false, false)));
	table.insert(lines, "end");
	return table.concat(lines, "\r\n");
end

function EventsAPIMixin:GetFullName(decorateOptionals, includeColorCodes) -- override
	if self.System then
		return ("Event.%s.%s -> %s"):format(self.System:GetName(), self:GetName(), self:GetPayloadString(decorateOptionals, includeColorCodes));
	end
	return ("Event.%s -> %s"):format(self:GetName(), self:GetPayloadString(decorateOptionals, includeColorCodes));
end

function EventsAPIMixin:MatchesSearchString(searchString) -- override
	if self:GetLoweredName():match(searchString) then
		return true;
	end

	if self.System and self.System:GetLoweredName():match(searchString) then
		return true;
	end

	if self.LiteralName:lower():match(searchString) then
		return true;
	end

	if self:MatchesAnyDocumentation(searchString) then
		return true;
	end

	if self:MatchesAnyAPI(self.Payload, searchString) then
		return true
	end

	return false;
end

function EventsAPIMixin:GetPayloadString(decorateOptionals, includeColorCodes) -- override
	if self.Payload then
		local values = {};
		for i, payloadInfo in ipairs(self.Payload) do
			if includeColorCodes ~= false then
				table.insert(values, ("%s|cff%s"):format(payloadInfo:GetPayloadString(decorateOptionals, includeColorCodes), self:GetLinkHexColor()));
			else
				table.insert(values, payloadInfo:GetPayloadString(decorateOptionals, includeColorCodes));
			end
		end
		return table.concat(values, ", ");
	end
	return "";
end

function EventsAPIMixin:GetDetailedOutputLines() -- override
	local lines = {};
	table.insert(lines, self:GetSingleOutputLine());

	self:AddSystemTag(lines);
	self:AddDocumentationTags(lines);

	table.insert(lines, APIDocumentation:GetIndentString() .. "Literal Name: \"" .. self.LiteralName .. "\"");

	if self.Payload then
		table.insert(lines, APIDocumentation:GetIndentString() .. "Payload");
		for i, payloadInfo in ipairs(self.Payload) do
			table.insert(lines, APIDocumentation:GetIndentString(2) .. ("%d. %s"):format(i, payloadInfo:GetSingleOutputLine()));
		end
	end

	return lines;
end