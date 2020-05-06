Soulbinds = {};

function Soulbinds.OnAddonLoaded(event, ...)
	if event == "SOULBIND_FORGE_INTERACTION_STARTED" then
		SoulbindViewer:Open();
	end
end

function Soulbinds.GetConduitInfoAtCursor()
	local itemLocation = C_Cursor.GetCursorItem();
	if itemLocation then
		local conduitType = C_Soulbinds.GetItemConduitType(itemLocation);
		if conduitType then
			return itemLocation, conduitType;
		end
	end
	return nil, nil;
end

function Soulbinds.HasConduitAtCursor()
	local itemLocation, conduitType = Soulbinds.GetConduitInfoAtCursor();
	return itemLocation ~= nil and conduitType ~= nil;
end

do
	local attributes = 
	{ 
		area = "center",
		pushable = 0,
		allowOtherPanels = 1,
	};
	RegisterUIPanel(SoulbindViewer, attributes);

	TRADESKILL_LOG_FIRSTPERSON = "+ %s : %s (Craft)";
	TRADESKILL_LOG_THIRDPERSON = "+ %s : %s (Craft)"

end