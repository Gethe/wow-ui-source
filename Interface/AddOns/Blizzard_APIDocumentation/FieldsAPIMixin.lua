FieldsAPIMixin = CreateFromMixins(BaseAPIMixin);

function FieldsAPIMixin:GetParentName()
	if self.Function then
		return self.Function:GetName(); 
	end

	if self.Table then
		return self.Table:GetName(); 
	end
	return "";
end

function FieldsAPIMixin:GetType()
	return "field";
end

function FieldsAPIMixin:GetLinkHexColor()
	return "ffdd55";
end

function FieldsAPIMixin:MatchesSearchString(searchString)
	if self:GetLoweredName():match(searchString) then
		return true;
	end
	
    if self:MatchesAnyDocumentation(searchString) then
	    return true;
    end

	return false;
end

function FieldsAPIMixin:GetLuaType()
	if self.InnerType then
		local complexType = APIDocumentation:FindAPIByName("table", self.InnerType);
		return ("%s of %s"):format(self.Type, complexType and complexType:GenerateAPILink() or self.InnerType)
	end

	if self.EnumValue then
		return self.EnumValue;
	end

	local complexType = APIDocumentation:FindAPIByName("table", self.Type);
	return complexType and complexType:GenerateAPILink() or self.Type;
end

function FieldsAPIMixin:GetStrideIndex()
	return self.StrideIndex;
end

function FieldsAPIMixin:IsOptional()
	return self.Default ~= nil or self.Nilable;
end

function FieldsAPIMixin:GetSingleOutputLine()
	local optionalString = "";
	if self:IsOptional() then
		if self.Default ~= nil then
			optionalString = ("(default:%s) "):format(tostring(self.Default));
		else
			optionalString = "(optional) ";
		end
	end
	if self.Documentation then
		return ("%s%s %s - %s"):format(optionalString, self:GetLuaType(), self:GenerateAPILink(), table.concat(self.Documentation, " "));
	end
	return ("%s%s %s"):format(optionalString, self:GetLuaType(), self:GenerateAPILink());
end

function FieldsAPIMixin:GetArgumentString(decorateOptionals, includeColorCodes)
	local prefix = decorateOptionals ~= false and self:IsOptional() and "optional " or "";
	if includeColorCodes ~= false then
		return ("|cff%s%s%s|r"):format(self:GetLinkHexColor(), prefix, self:GetName());
	end
	return ("%s%s"):format(prefix, self:GetName());
end

function FieldsAPIMixin:GetReturnString(decorateOptionals, includeColorCodes)
	return self:GetArgumentString(decorateOptionals, includeColorCodes); -- Nothing special currently
end

function FieldsAPIMixin:GetPayloadString(decorateOptionals, includeColorCodes)
	return self:GetReturnString(decorateOptionals, includeColorCodes); -- Nothing special currently
end