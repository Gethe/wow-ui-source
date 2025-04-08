AreaPoiUtil = {};

function AreaPoiUtil.TryShowTooltip(region, anchor, poiInfo, customFn)
	local hasDescription = poiInfo.description and poiInfo.description ~= "";
	local isTimed, hideTimer = C_AreaPoiInfo.IsAreaPOITimed(poiInfo.areaPoiID);
	local showTimer = poiInfo.secondsLeft or (isTimed and not hideTimer);
	local hasWidgetSet = poiInfo.tooltipWidgetSet ~= nil;

	local hasTooltip = hasDescription or showTimer or hasWidgetSet;
	local addedTooltipLine = false;

	if hasTooltip then
		local tooltip = GetAppropriateTooltip();
		local verticalPadding = nil;

		tooltip:SetOwner(region, anchor);
		if region:HasDisplayName() then
			GameTooltip_SetTitle(tooltip, region:GetDisplayName(), HIGHLIGHT_FONT_COLOR);
			addedTooltipLine = true;
		end

		if hasDescription then
			GameTooltip_AddNormalLine(tooltip, poiInfo.description);
			addedTooltipLine = true;
		end

		if showTimer then
			local secondsLeft = poiInfo.secondsLeft or C_AreaPoiInfo.GetAreaPOISecondsLeft(poiInfo.areaPoiID);
			if secondsLeft and secondsLeft > 0 then
				local timeString = SecondsToTime(secondsLeft);
				timeString = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(timeString);
				GameTooltip_AddNormalLine(tooltip, MAP_TOOLTIP_TIME_LEFT:format(timeString));
				addedTooltipLine = true;
			end
		end

		if poiInfo.textureKit == "OribosGreatVault" then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddInstructionLine(tooltip, ORIBOS_GREAT_VAULT_POI_TOOLTIP_INSTRUCTIONS, false);
			addedTooltipLine = true;
		end

		if hasWidgetSet then
			local overflow = GameTooltip_AddWidgetSet(tooltip, poiInfo.tooltipWidgetSet, addedTooltipLine and poiInfo.addPaddingAboveTooltipWidgets and 10);
			if overflow then
				verticalPadding = -overflow;
			end
		end

		if poiInfo.textureKit then
			local backdropStyle = GAME_TOOLTIP_TEXTUREKIT_BACKDROP_STYLES[poiInfo.textureKit];
			if (backdropStyle) then
				SharedTooltip_SetBackdropStyle(tooltip, backdropStyle);
			end
		end

		if customFn then
			customFn(tooltip);
		end

		tooltip:Show();

		-- need to set padding after Show or else there will be a flicker
		if verticalPadding then
			tooltip:SetPadding(0, verticalPadding);
		end

		return true;
	end

	return false;
end