function CollectionWardrobeUtil.CompareAppearance(source1, source2)
	if source1.isCollected ~= source2.isCollected then
		return source1.isCollected;
	end
	if source1.isUsable ~= source2.isUsable then
		return source1.isUsable;
	end
	if source1.isFavorite ~= source2.isFavorite then
		return source1.isFavorite;
	end
	if source1.canDisplayOnPlayer ~= source2.canDisplayOnPlayer then
		return source1.canDisplayOnPlayer;
	end
	if source1.isHideVisual ~= source2.isHideVisual then
		return source1.isHideVisual;
	end
	if source1.hasActiveRequiredHoliday ~= source2.hasActiveRequiredHoliday then
		return source1.hasActiveRequiredHoliday;
	end
	if source1.minIlvl and source2.minIlvl then
		return source1.minIlvl < source2.minIlvl;
	end
	if source1.uiOrder and source2.uiOrder then
		return source1.uiOrder > source2.uiOrder;
	end
	return source1.sourceID > source2.sourceID;
end
