do
	if not IsOnGlueScreen() then
		local attributes = 
		{ 
			area = "center",
			pushable = 0,
			whileDead = 1,
			checkFit = 1,
		};
		RegisterUIPanel(SettingsPanel, attributes);
	end
end