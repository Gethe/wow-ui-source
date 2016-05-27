---------------------------------------------------------------------------------
-- Display Options
---------------------------------------------------------------------------------
GarrisonFollowerOptions = { };
GarrisonFollowerOptions[LE_FOLLOWER_TYPE_GARRISON_6_0] = {
	abilityTooltipFrame = "GarrisonFollowerAbilityTooltip",
	displayCounterAbilityInPlaceOfMechanic = false,
	followerListCounterNumPerRow = 2,
	followerListCounterInnerSpacing = 6,
	followerListCounterOuterSpacingX = 8,
	followerListCounterOuterSpacingY = 4,
	followerListCounterScale = 1.0,
	followerPageShowSourceText = true,
	followerPageShowGear = true,
	garrisonType = LE_GARRISON_TYPE_6_0,
	hideCountersInAbilityFrame = false,
	hideMissionTypeInLandingPage = false,
	isPrimaryFollowerType = true,
	minFollowersForThreatCountersFrame = 10,
	minQualityLevelToShowLevel = LE_ITEM_QUALITY_POOR,
	missionAbilityTooltipFrame = "GarrisonFollowerAbilityTooltip",
	missionCompleteUseNeutralChest = false,
	missionFrame = "GarrisonMissionFrame",
	missionPageMechanicYOffset = -16,
	missionTooltipShowPartialCountersAsFull = false,
	partyNotFullText = GARRISON_PARTY_NOT_FULL_TOOLTIP,
	showCategoriesInFollowerList = false,
	showCautionSignOnMissionFollowersSmallBias = true,
	showILevelInFollowerList = true,
	showILevelOnFollower = false,
	showSingleMissionCompleteAnimation = false,
	showSingleMissionCompleteFollower = false,
	showSpikyBordersOnSpecializationAbilities = false,
	strings = {
		LANDING_COMPLETE = GARRISON_LANDING_BUILDING_COMPLEATE,
		RETURN_TO_START = GARRISON_MISSION_TOOLTIP_RETURN_TO_START,
		CONFIRM_EQUIPMENT = GARRISON_FOLLOWER_CONFIRM_EQUIPMENT,
		TRAITS_LABEL = GARRISON_TRAITS,
		FOLLOWER_ADDED_TOAST = GARRISON_FOLLOWER_ADDED_TOAST,
		FOLLOWER_ADDED_UPGRADED_TOAST = GARRISON_FOLLOWER_ADDED_UPGRADED_TOAST,
		FOLLOWER_COUNT_LABEL = GARRISON_FOLLOWERS,
		FOLLOWER_COUNT_STRING = GARRISON_FOLLOWER_COUNT,
	},
	traitAbilitiesAreEquipment = false,
	useAbilityTooltipStyleWithoutCounters = false,
	usesOvermaxMechanic = false,
}

GarrisonFollowerOptions[LE_FOLLOWER_TYPE_SHIPYARD_6_2] = {
	abilityTooltipFrame = "GarrisonFollowerAbilityTooltip",
	displayCounterAbilityInPlaceOfMechanic = false,
	followerListCounterNumPerRow = 4,
	followerListCounterInnerSpacing = 6,
	followerListCounterOuterSpacingX = 8,
	followerListCounterOuterSpacingY = 4,
	followerListCounterScale = 1.0,
	followerPageShowSourceText = false,
	followerPageShowGear = false,
	garrisonType = LE_GARRISON_TYPE_6_0,
	hideCountersInAbilityFrame = false,
	hideMissionTypeInLandingPage = true,
	isPrimaryFollowerType = false,
	minFollowersForThreatCountersFrame = 1,
	minQualityLevelToShowLevel = LE_ITEM_QUALITY_POOR,
	missionAbilityTooltipFrame = "GarrisonFollowerAbilityTooltip",
	missionCompleteUseNeutralChest = false,
	missionFrame = "GarrisonShipyardFrame",
	missionPageMechanicYOffset = 0,
	missionTooltipShowPartialCountersAsFull = false,
	partyNotFullText = GARRISON_SHIPYARD_PARTY_NOT_FULL_TOOLTIP,
	showCategoriesInFollowerList = false,
	showCautionSignOnMissionFollowersSmallBias = true,
	showILevelInFollowerList = true,
	showILevelOnFollower = false,
	showSingleMissionCompleteAnimation = true,
	showSingleMissionCompleteFollower = true,
	showSpikyBordersOnSpecializationAbilities = false,
	strings = {
		LANDING_COMPLETE = GARRISON_LANDING_BUILDING_COMPLEATE,
		RETURN_TO_START = GARRISON_SHIPYARD_MISSION_TOOLTIP_RETURN_TO_START,
		CONFIRM_EQUIPMENT = GARRISON_SHIPYARD_CONFIRM_EQUIPMENT,
		TRAITS_LABEL = nil;
		FOLLOWER_ADDED_TOAST = GARRISON_SHIPYARD_FOLLOWER_ADDED_TOAST,
		FOLLOWER_ADDED_UPGRADED_TOAST = GARRISON_SHIPYARD_FOLLOWER_ADDED_UPGRADED_TOAST,
		FOLLOWER_COUNT_LABEL = GARRISON_FLEET,
		FOLLOWER_COUNT_STRING = GARRISON_SHIPYARD_FOLLOWER_COUNT,
	},
	traitAbilitiesAreEquipment = true,
	useAbilityTooltipStyleWithoutCounters = false,
	usesOvermaxMechanic = false,
}

GarrisonFollowerOptions[LE_FOLLOWER_TYPE_GARRISON_7_0] = {
	abilityTooltipFrame = "GarrisonFollowerAbilityWithoutCountersTooltip",
	displayCounterAbilityInPlaceOfMechanic = true,
	followerListCounterNumPerRow = 2,
	followerListCounterInnerSpacing = 4,
	followerListCounterOuterSpacingX = 8,
	followerListCounterOuterSpacingY = 4,
	followerListCounterScale = 1.15,
	followerPageShowSourceText = false,
	followerPageShowGear = false,
	garrisonType = LE_GARRISON_TYPE_7_0,
	hideCountersInAbilityFrame = true,
	hideMissionTypeInLandingPage = true,
	isPrimaryFollowerType = true,
	minFollowersForThreatCountersFrame = math.huge,
	minQualityLevelToShowLevel = LE_ITEM_QUALITY_POOR,
	missionAbilityTooltipFrame = "GarrisonFollowerMissionAbilityWithoutCountersTooltip",
	missionCompleteUseNeutralChest = true,
	missionFrame = "OrderHallMissionFrame",
	missionPageMechanicYOffset = -32,
	missionTooltipShowPartialCountersAsFull = true,
	partyNotFullText = GARRISON_PARTY_NOT_ENOUGH_CHAMPIONS,
	showCategoriesInFollowerList = true,
	showCautionSignOnMissionFollowersSmallBias = false,
	showILevelInFollowerList = true,
	showILevelOnFollower = false,
	showSingleMissionCompleteAnimation = true,
	showSingleMissionCompleteFollower = false,
	showSpikyBordersOnSpecializationAbilities = true,
	strings = {
		LANDING_COMPLETE = ORDER_HALL_LANDING_COMPLETE,
		RETURN_TO_START = ORDER_HALL_MISSION_TOOLTIP_RETURN_TO_START,
		CONFIRM_EQUIPMENT = GARRISON_FOLLOWER_CONFIRM_EQUIPMENT,
		TRAITS_LABEL = ORDER_HALL_EQUIPMENT_SLOTS,
		FOLLOWER_ADDED_TOAST = ORDER_HALL_FOLLOWER_ADDED_TOAST,
		FOLLOWER_ADDED_UPGRADED_TOAST = ORDER_HALL_FOLLOWER_ADDED_UPGRADED_TOAST,
		TROOP_ADDED_TOAST = ORDER_HALL_TROOP_ADDED_TOAST,
		TROOP_ADDED_UPGRADED_TOAST = ORDER_HALL_TROOP_ADDED_UPGRADED_TOAST,
		FOLLOWER_COUNT_LABEL = FOLLOWERLIST_LABEL_CHAMPIONS,
		FOLLOWER_COUNT_STRING = GARRISON_CHAMPION_COUNT,
	},
	traitAbilitiesAreEquipment = true,
	useAbilityTooltipStyleWithoutCounters = true,
	usesOvermaxMechanic = true,
}

function GetPrimaryGarrisonFollowerType(garrTypeID)
	for type, options in pairs(GarrisonFollowerOptions) do
		if (options.garrisonType == garrTypeID and options.isPrimaryFollowerType) then
			return type;
		end
	end
	return nil;
end

function ShouldShowFollowerAbilityBorder(followerTypeID, abilityInfo) 
	return GarrisonFollowerOptions[followerTypeID].showSpikyBordersOnSpecializationAbilities and abilityInfo.isSpecialization;
end


function ShouldShowILevelInFollowerList(followerInfo) 
	return GarrisonFollowerOptions[followerInfo.followerTypeID].showILevelInFollowerList and followerInfo.isMaxLevel and not followerInfo.isTroop;
end


---------------------------------------------------------------------------------
--- Landing Page                                                         ---
---------------------------------------------------------------------------------
function ShowGarrisonLandingPage(garrTypeID)
	if (not garrTypeID) then
		garrTypeID = C_Garrison.GetLandingPageGarrisonType();
	end
	if (garrTypeID == 0) then
		return;
	end
	if (GarrisonLandingPage and GarrisonLandingPage:IsShown() and GarrisonLandingPage.garrTypeID == garrTypeID) then
		return;
	end
	if (garrTypeID == LE_GARRISON_TYPE_6_0) then
		if (not GarrisonMissionFrame) then
			Garrison_LoadUI();
		end
		GarrisonLandingPage.Report.Title:SetText(GARRISON_LANDING_PAGE_TITLE);
		GarrisonLandingPage.FollowerList:Initialize(LE_FOLLOWER_TYPE_GARRISON_6_0);
		GarrisonLandingPage.ShipFollowerList:Initialize(LE_FOLLOWER_TYPE_SHIPYARD_6_2);
	elseif (garrTypeID == LE_GARRISON_TYPE_7_0) then
		if (not OrderHallMissionFrame) then
			OrderHall_LoadUI();
		end
		GarrisonLandingPage.Report.Title:SetText(ORDER_HALL_LANDING_PAGE_TITLE);
		GarrisonLandingPage.FollowerList:Initialize(LE_FOLLOWER_TYPE_GARRISON_7_0);
	else
		return;
	end

	GarrisonLandingPage.garrTypeID = garrTypeID;
	ShowUIPanel(GarrisonLandingPage);

end

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