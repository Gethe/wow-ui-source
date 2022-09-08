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
		return subcategory, category;
	else
		local category, layout = Settings.RegisterCanvasLayoutCategory(frame, frame.name, frame.name);
		Settings.RegisterAddOnCategory(category);
		return category;
	end
end

-- Deprecated. Use Settings.OpenToCategory().
function InterfaceOptionsFrame_OpenToCategory(categoryNameOrFrame)
	if type(categoryNameOrFrame == "string") then
		return Settings.OpenToCategory(categoryNameOrFrame);
	elseif type(categoryNameOrFrame == "table") then
		local category = frame.name;
		if category and type(category) == "string" then
			return Settings.OpenToCategory(category);
		end
	end
end