ColorManager = {};

function ColorManager.UpdateColorData()
	-- Repopulate any tables as needed
	ColorManager.UpdateColorsForItemQuality();

	if C_Glue.IsOnGlueScreen() then
		-- Some enum values are not exposed at glues because they are not needed, just clear associated tables for those cases.
		WORLD_QUEST_QUALITY_COLORS = {};
		FOLLOWER_QUALITY_COLORS = {};
	else
		ColorManager.UpdateColorsForWorldQuestQuality();
		ColorManager.UpdateColorsForFollowerQuality();
	end

	EventRegistry:TriggerEvent("ColorManager.OnColorDataUpdated");
end

function ColorManager.UpdateColorsForItemQuality()
	ITEM_QUALITY_COLORS = {};

	for i = 0, Enum.ItemQualityMeta.NumValues - 1 do
		local color = C_ColorOverrides.GetColorForQuality(i);
		ITEM_QUALITY_COLORS[i] = { r = color.r, g = color.g, b = color.b, hex = color:GenerateHexColorMarkup(), color = color };
	end
end

function ColorManager.UpdateColorsForWorldQuestQuality()
	WORLD_QUEST_QUALITY_COLORS = {
		[Enum.WorldQuestQuality.Common] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Common];
		[Enum.WorldQuestQuality.Rare] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Rare];
		[Enum.WorldQuestQuality.Epic] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Epic];
	};
end

function ColorManager.UpdateColorsForFollowerQuality()
	FOLLOWER_QUALITY_COLORS = {
		[Enum.GarrFollowerQuality.Common] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Common];
		[Enum.GarrFollowerQuality.Uncommon] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Uncommon];
		[Enum.GarrFollowerQuality.Rare] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Rare];
		[Enum.GarrFollowerQuality.Epic] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Epic];
		[Enum.GarrFollowerQuality.Legendary] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Legendary];
		[Enum.GarrFollowerQuality.Title] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Epic]; -- Followers with the title (== 6) quality still appear as epic to players.
	};
end

--[[
Color Accessing
Ensure if editing method names/adding new methods, that corresponding edits are reflected in classic.
]]--

function ColorManager.GetColorDataForItemQuality(quality)
	local colorData = ITEM_QUALITY_COLORS[quality];
	if not colorData then
		return nil;
	end

	-- ITEM_QUALITY_COLORS is populated in a way that already takes override colors into account.
	return colorData;
end

-- Version that does not take color overrides into account.
function ColorManager.GetDefaultColorDataForItemQuality(quality)
	local colorData = nil;

	local color = C_ColorOverrides.GetDefaultColorForQuality(quality);
	colorData = { r = color.r, g = color.g, b = color.b, hex = color:GenerateHexColorMarkup(), color = color };

	return colorData;
end

function ColorManager.GetColorDataForWorldQuestQuality(quality)
	local colorData = WORLD_QUEST_QUALITY_COLORS[quality];
	if not colorData then
		return nil;
	end

	-- WORLD_QUEST_QUALITY_COLORS derives from ITEM_QUALITY_COLORS, and is populated in a way that already takes override colors into account.
	return colorData;
end

function ColorManager.GetColorDataForFollowerQuality(quality)
	local colorData = FOLLOWER_QUALITY_COLORS[quality];
	if not colorData then
		return nil;
	end

	-- FOLLOWER_QUALITY_COLORS derives from ITEM_QUALITY_COLORS, and is populated in a way that already takes override colors into account.
	return colorData;
end

function ColorManager.GetColorDataForBagItemQuality(quality)
	local overrideQuality = ITEM_QUALITY_OVERRIDES[quality];
	if overrideQuality then
		local overrideInfo = C_ColorOverrides.GetColorOverrideInfo(overrideQuality);
		if overrideInfo then
			return overrideInfo.overrideColor;
		end
	end

	return ColorManager.GetDefaultColorDataForBagItemQuality(quality);
end

-- Version that does not take color overrides into account.
function ColorManager.GetDefaultColorDataForBagItemQuality(quality)
	local color = BAG_ITEM_QUALITY_COLORS[quality];
	if not color then
		return nil;
	end

	return color;
end

function ColorManager.GetAtlasDataForAuctionHouseItemQuality(quality)
	local atlasData = {
		atlas = nil,
		overrideColor = nil
	};

	local overrideQuality = ITEM_QUALITY_OVERRIDES[quality];
	if overrideQuality then
		local overrideInfo = C_ColorOverrides.GetColorOverrideInfo(overrideQuality);
		if overrideInfo then
			atlasData.atlas = "auctionhouse-itemicon-border-color";
			atlasData.overrideColor = overrideInfo.overrideColor;
			return atlasData;
		end
	end

	atlasData.atlas = AUCTION_HOUSE_ITEM_QUALITY_ICON_BORDER_ATLASES[quality];
	return atlasData;
end

function ColorManager.GetAtlasDataForProfessionsItemQuality(quality)
	local atlasData = {
		atlas = nil,
		overrideColor = nil
	};

	local overrideQuality = ITEM_QUALITY_OVERRIDES[quality];
	if overrideQuality then
		local overrideInfo = C_ColorOverrides.GetColorOverrideInfo(overrideQuality);
		if overrideInfo then
			atlasData.atlas = "professions-slot-frame-white";
			atlasData.overrideColor = overrideInfo.overrideColor;
			return atlasData;
		end
	end

	atlasData.atlas = PROFESSIONS_ITEM_QUALITY_ICON_BORDER_ATLASES[quality];
	return atlasData;
end

function ColorManager.GetAtlasDataForNewItemQuality(quality)
	-- Does not currently check color overrides, just return original lookup.
	return NEW_ITEM_ATLAS_BY_QUALITY[quality];
end

function ColorManager.GetAtlasDataForLootBorderItemQuality(quality)
	-- Does not currently check color overrides, just return original lookup.
	return LOOT_BORDER_BY_QUALITY[quality];
end

function ColorManager.GetAtlasDataForLootUpgradeQuality(quality)
	-- Does not currently check color overrides, just return original lookup.
	return LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality];
end

function ColorManager.GetAtlasDataForGarrisonFollowerQuality(quality)
	-- Does not currently check color overrides, just return original lookup.
	return GARRISON_FOLLOWER_QUALITY_TEXTURE_SUFFIXES[quality];
end

function ColorManager.GetAtlasDataForWardrobeSetItemQuality(quality)
	local atlasData = {
		atlas = nil,
		overrideColor = nil
	};

	local overrideQuality = ITEM_QUALITY_OVERRIDES[quality];
	if overrideQuality then
		local overrideInfo = C_ColorOverrides.GetColorOverrideInfo(overrideQuality);
		if overrideInfo then
			atlasData.atlas = "loottab-set-itemborder-color";
			atlasData.overrideColor = overrideInfo.overrideColor;
			return atlasData;
		end
	end

	atlasData.atlas = WARDROBE_SETS_ITEM_QUALITY_ICON_BORDER_ATLASES[quality];
	return atlasData;
end

function ColorManager.GetAtlasDataForLootJournalSetItemQuality(quality)
	local atlasData = {
		atlas = nil,
		overrideColor = nil
	};

	local overrideQuality = ITEM_QUALITY_OVERRIDES[quality];
	if overrideQuality then
		local overrideInfo = C_ColorOverrides.GetColorOverrideInfo(overrideQuality);
		if overrideInfo then
			atlasData.atlas = "loottab-set-itemborder-color";
			atlasData.overrideColor = overrideInfo.overrideColor;
			return atlasData;
		end
	end

	atlasData.atlas = LOOT_JOURNAL_ITEM_SETS_QUALITY_ICON_BORDER_ATLASES[quality];
	return atlasData;
end

function ColorManager.GetColorDataForDressUpFrameQuality(quality)
	-- Does not currently check color overrides, just return original lookup.
	return DRESS_UP_FRAME_QUALITY_COLORS[quality];
end

function ColorManager.GetAtlasDataForGarrisonShipyardFollowerQuality(quality)
	-- Does not currently check color overrides, just return original lookup.
	return GARRISON_SHIPYARD_FOLLOWER_QUALITY_ATLASES[quality];
end

function ColorManager.GetAtlasDataForSpellDisplayColor(quality)
	local atlasData = {
		atlas = nil,
		overrideColor = nil
	};

	local overrideQuality = ITEM_QUALITY_OVERRIDES[quality];
	if overrideQuality then
		local overrideInfo = C_ColorOverrides.GetColorOverrideInfo(overrideQuality);
		if overrideInfo then
			atlasData.atlas = "wowlabs-in-world-item-common";
			atlasData.overrideColor = overrideInfo.overrideColor;
			return atlasData;
		end
	end

	atlasData.atlas = SPELL_DISPLAY_BORDER_COLOR_ATLASES[quality];
	return atlasData;
end

function ColorManager.GetAtlasDataForPlayerChoice(quality)
	local atlasData = {
		postfixData = nil,
		overrideColor = nil
	};

	local overrideQuality = ITEM_QUALITY_OVERRIDES[quality];
	if overrideQuality then
		local overrideInfo = C_ColorOverrides.GetColorOverrideInfo(overrideQuality);
		if overrideInfo then
			atlasData.postfixData = {
				circleBorder = "-border-white",
				portraitBackgroundGlow1 = "-portrait-qualitywhite-01",
				portraitBackgroundGlow2 = "-portrait-qualitywhite-02",
				portraitBackgroundTorghast = "",
				portraitBackgroundCypher = "-white"
			};
			atlasData.overrideColor = overrideInfo.overrideColor;
			return atlasData;
		end
	end

	atlasData.postfixData = PLAYER_CHOICE_ATLAS_POSTFIXES[quality];
	return atlasData;
end

-- |cnIQ<ItemQuality>:<your text here>|r - Named color token specifically for Item Qualities (IQ) which takes override colors into account.
function ColorManager.GetFormattedStringForItemQuality(text, quality)
	local colorString = string.format("|cnIQ%d:", quality);
	return colorString..text.."|r";
end

EventRegistry:RegisterFrameEventAndCallback("ACCOUNT_CVARS_LOADED", ColorManager.UpdateColorData, ColorManager);
EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", ColorManager.UpdateColorData, ColorManager);

ColorManager.UpdateColorData();