local AddonName = ...;

function GuildControlUI_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function GuildControlUI_Show()
	if GuildControlUI_LoadUI() then
		ShowUIPanel(GuildControlUI);
	end
end
