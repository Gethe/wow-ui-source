LanguagesOverrides = {}

function LanguagesOverrides.CreateSocialSettings(category, layout)
	if C_Glue.IsOnGlueScreen() then
		return;
	end

	RequestPreferredPlaySettings.Setup(category, layout);
end
