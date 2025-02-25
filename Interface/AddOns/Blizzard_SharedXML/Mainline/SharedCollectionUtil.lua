SharedCollectionUtil = {};

function SharedCollectionUtil.ShowWarbandSceneEntryTooltip(tooltip, warbandSceneInfo, isOwned)
	-- Assumes that anchoring will be handled by calling location.
	GameTooltip_AddColoredLine(tooltip, warbandSceneInfo.name, warbandSceneInfo.qualityColor);

	-- Random entry doesn't show certain parts of normal tooltip info.
	local isRandomEntry = warbandSceneInfo.warbandSceneID == C_WarbandScene.GetRandomEntryID();

	if not isRandomEntry then
		GameTooltip_AddColoredLine(tooltip, ACCOUNT_LEVEL_SCENE, ACCOUNT_WIDE_FONT_COLOR);
	end

	if warbandSceneInfo.description and warbandSceneInfo.description ~= "" then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddNormalLine(tooltip, warbandSceneInfo.description);
	end

	if not isRandomEntry and not isOwned and warbandSceneInfo.source and warbandSceneInfo.source ~= "" then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddHighlightLine(tooltip, warbandSceneInfo.source);
	end

	tooltip:Show();
end