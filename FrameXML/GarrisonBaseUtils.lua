---------------------------------------------------------------------------------
-- Display Options
---------------------------------------------------------------------------------
GarrisonFollowerOptions = { };
GarrisonFollowerOptions[LE_FOLLOWER_TYPE_GARRISON_6_0] = {
	displayCounterAbilityInPlaceOfMechanic = false,
	useAbilityTooltipStyleWithoutCounters = false,
	hideCountersInAbilityFrame = false,
	showILevelOnFollower = false,
	showCategoriesInFollowerList = false,
	minFollowersForThreatCountersFrame = 10,
	showSingleMissionCompleteAnimation = false,
	showCautionSignOnMissionFollowersSmallBias = true,
	minQualityLevelToShowLevel = LE_ITEM_QUALITY_POOR,
	usesOvermaxMechanic = false,
	partyNotFullText = GARRISON_PARTY_NOT_FULL_TOOLTIP,
}

GarrisonFollowerOptions[LE_FOLLOWER_TYPE_SHIPYARD_6_2] = {
	displayCounterAbilityInPlaceOfMechanic = false,
	useAbilityTooltipStyleWithoutCounters = false,
	hideCountersInAbilityFrame = false,
	showILevelOnFollower = false,
	showCategoriesInFollowerList = false,
	minFollowersForThreatCountersFrame = 1,
	showSingleMissionCompleteAnimation = true,
	showCautionSignOnMissionFollowersSmallBias = true,
	minQualityLevelToShowLevel = LE_ITEM_QUALITY_POOR,
	usesOvermaxMechanic = false,
	partyNotFullText = GARRISON_SHIPYARD_PARTY_NOT_FULL_TOOLTIP,
}

GarrisonFollowerOptions[LE_FOLLOWER_TYPE_GARRISON_7_0] = {
	displayCounterAbilityInPlaceOfMechanic = true,
	useAbilityTooltipStyleWithoutCounters = true,
	hideCountersInAbilityFrame = true,
	showILevelOnFollower = true,
	showCategoriesInFollowerList = true,
	minFollowersForThreatCountersFrame = math.huge,
	showSingleMissionCompleteAnimation = true,
	showCautionSignOnMissionFollowersSmallBias = false,
	minQualityLevelToShowLevel = LE_ITEM_QUALITY_EPIC,
	usesOvermaxMechanic = true,
	partyNotFullText = GARRISON_PARTY_NOT_ENOUGH_CHAMPIONS,
}

---------------------------------------------------------------------------------
--- Follower Portrait                                                         ---
---------------------------------------------------------------------------------
GarrisonFollowerPortraitMixin = { }

function GarrisonFollowerPortraitMixin:SetPortraitIcon(iconFileID)
	if (iconFileID == nil or iconFileID == 0) then
		-- unknown icon file ID; use the default silhouette portrait
		self.Portrait:SetTexture("Interface\\Garrison\\Portraits\\FollowerPortrait_NoPortrait");
	else
		self.Portrait:SetTexture(iconFileID);
	end
end

function GarrisonFollowerPortraitMixin:SetQuality(quality)
	local color = quality and ITEM_QUALITY_COLORS[quality] or nil;
	if (color) then
		self:SetQualityColor(color.r, color.g, color.b);
	else
		self:SetQualityColor(1, 1, 1);
	end
end

function GarrisonFollowerPortraitMixin:SetQualityColor(r, g, b)
	self.LevelBorder:SetVertexColor(r, g, b);
	self.PortraitRingQuality:SetVertexColor(r, g, b);
end

function GarrisonFollowerPortraitMixin:SetNoLevel()
	self.LevelBorder:Hide();
	self.Level:Hide();
end

function GarrisonFollowerPortraitMixin:SetLevel(level)
	self.LevelBorder:SetAtlas("GarrMission_PortraitRing_LevelBorder");
	self.LevelBorder:SetWidth(58);
	self.LevelBorder:Show();
	self.Level:Show();
	self.Level:SetText(level);
end

function GarrisonFollowerPortraitMixin:SetILevel(iLevel)
	self.LevelBorder:SetAtlas("GarrMission_PortraitRing_iLvlBorder");
	self.LevelBorder:SetWidth(70);
	self.LevelBorder:Show();
	self.Level:Show();
	self.Level:SetFormattedText(GARRISON_FOLLOWER_ITEM_LEVEL, iLevel);
end

function GarrisonFollowerPortraitMixin:SetupPortrait(followerInfo, showILevel)
	self:SetPortraitIcon(followerInfo.portraitIconID);
	self:SetQuality(followerInfo.quality);
	local showILevelOnFollower = followerInfo.followerTypeID and GarrisonFollowerOptions[followerInfo.followerTypeID].showILevelOnFollower or false;
	local hideLevelOnFollower = followerInfo.isTroop or (followerInfo.quality < GarrisonFollowerOptions[followerInfo.followerTypeID].minQualityLevelToShowLevel);

	if (hideLevelOnFollower) then
		self:SetNoLevel();
	elseif (showILevel or showILevelOnFollower) then
		self:SetILevel(followerInfo.iLevel);
	else
		self:SetLevel(followerInfo.level);
	end
end