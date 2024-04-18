-- These are functions that were deprecated in 10.2.6 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	FrameXML_Debug = C_Debug.FrameXMLDebug;
	GetMawPowerLinkBySpellID = C_Spell.GetMawPowerLinkBySpellID;

	-- Function name changed
	function C_TaskQuest.GetUIWidgetSetIDFromQuestID(questID)
		return C_TaskQuest.GetQuestTooltipUIWidgetSet(questID);
	end

	-- 2 key names changed in C_AreaPoiInfo.GetAreaPOIInfo
	local newGetAreaPOIInfoFunc = C_AreaPoiInfo.GetAreaPOIInfo;
	function C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
		local poiInfo = newGetAreaPOIInfoFunc(mapID, areaPoiID);
		if poiInfo then
			poiInfo.widgetSetID = poiInfo.tooltipWidgetSet;
			poiInfo.addPaddingAboveWidgets = poiInfo.addPaddingAboveTooltipWidgets;
		end
		return poiInfo;
	end

	-- 2 key names changed in C_VignetteInfo.GetVignetteInfo
	local newGetVignetteInfoFunc = C_VignetteInfo.GetVignetteInfo;
	function C_VignetteInfo.GetVignetteInfo(vignetteGUID)
		local vignetteInfo = newGetVignetteInfoFunc(vignetteGUID);
		if vignetteInfo then
			vignetteInfo.widgetSetID = vignetteInfo.tooltipWidgetSet;
			vignetteInfo.addPaddingAboveWidgets = vignetteInfo.addPaddingAboveTooltipWidgets;
		end
		return vignetteInfo;
	end
end