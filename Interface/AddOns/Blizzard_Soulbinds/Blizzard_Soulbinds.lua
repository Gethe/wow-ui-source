function Soulbinds.OnAddonLoaded(event, ...)
	if event == "SOULBIND_FORGE_INTERACTION_STARTED" then
		SoulbindViewer:Open();
	end
end

do
	local attributes = 
	{ 
		area = "doublewide",
		xoffset = 35,
		pushable = 0,
		allowOtherPanels = 1,
		checkFit = 1,
	};
	RegisterUIPanel(SoulbindViewer, attributes);
end