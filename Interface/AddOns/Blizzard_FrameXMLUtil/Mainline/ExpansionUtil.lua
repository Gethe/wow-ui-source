function GetExpansionName(expansion)
	local tag = "EXPANSION_NAME" .. tostring(expansion);
	return _G[tag] or "";
end