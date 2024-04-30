--[[ Deprecated. 
See Blizzard_ImplementationReadme.lua for recommended setup.
]]--
function InterfaceOptions_AddCategory(frame, addOn, position)
	-- cancel is no longer a default option. May add menu extension for this.
	frame.OnCommit = frame.okay;
	frame.OnDefault = frame.default;
	frame.OnRefresh = frame.refresh;

	if frame.parent then
		local category = Settings.GetCategory(frame.parent);
		local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, frame, frame.name, frame.name);
		subcategory.ID = frame.name;
		return subcategory, category;
	else
		local category, layout = Settings.RegisterCanvasLayoutCategory(frame, frame.name, frame.name);
		category.ID = frame.name;
		Settings.RegisterAddOnCategory(category);
		return category;
	end
end

-- Deprecated. Use Settings.OpenToCategory().
function InterfaceOptionsFrame_OpenToCategory(categoryIDOrFrame)
	if type(categoryIDOrFrame) == "table" then
		local categoryID = categoryIDOrFrame.name;
		return Settings.OpenToCategory(categoryID);
	else
		return Settings.OpenToCategory(categoryIDOrFrame);
	end
end