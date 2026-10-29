local GeneratedAddonName = "Blizzard_APIDocumentationGenerated";

function APIDocumentation_LoadUI()
	-- The generated addon is not loadable at glues.
	if C_Glue.IsOnGlueScreen() then
		return false;
	end

	return LoadAddOnWithErrorHandling(GeneratedAddonName);
end
