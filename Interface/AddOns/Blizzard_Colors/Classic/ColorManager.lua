-- This file exists only to support locations of shared code where a ColorManager API path must exist for both mainline and classic.
-- This file should only return direct references to various color tables, similar to other classic code.
ColorManager = {};

function ColorManager.GetColorDataForBagItemQuality(quality)
	return BAG_ITEM_QUALITY_COLORS[quality];
end

function ColorManager.GetColorDataForItemQuality(quality)
	return ITEM_QUALITY_COLORS[quality];
end

function ColorManager.GetColorDataForWorldQuestQuality(quality)
	return WORLD_QUEST_QUALITY_COLORS[quality];
end

function ColorManager.GetFormattedStringForItemQuality(text, quality)
	local colorData = ColorManager.GetColorDataForItemQuality(quality);
	return colorData.color:WrapTextInColorCode(text);
end

function ColorManager.GetAtlasDataForWardrobeSetItemQuality(quality)
	local atlasData = {
		atlas = nil,
		overrideColor = nil
	};
	
	if ( quality == Enum.ItemQuality.Uncommon ) then
		atlasData.atlas = "loottab-set-itemborder-green";
	elseif ( quality == Enum.ItemQuality.Rare ) then
		atlasData.atlas = "loottab-set-itemborder-blue";
	elseif ( quality == Enum.ItemQuality.Epic ) then
		atlasData.atlas = "loottab-set-itemborder-purple";
	end

	return atlasData;
end