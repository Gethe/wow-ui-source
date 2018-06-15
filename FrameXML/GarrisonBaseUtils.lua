---------------------------------------------------------------------------------
-- Global Constants
---------------------------------------------------------------------------------
FOLLOWER_QUALITY_COLORS = {
	[LE_GARR_FOLLOWER_QUALITY_COMMON] = ITEM_QUALITY_COLORS[1]; -- Common
	[LE_GARR_FOLLOWER_QUALITY_UNCOMMON] = ITEM_QUALITY_COLORS[2]; -- Uncommon
	[LE_GARR_FOLLOWER_QUALITY_RARE] = ITEM_QUALITY_COLORS[3]; -- Rare
	[LE_GARR_FOLLOWER_QUALITY_EPIC] = ITEM_QUALITY_COLORS[4]; -- Epic
	[LE_GARR_FOLLOWER_QUALITY_LEGENDARY] = ITEM_QUALITY_COLORS[5]; -- Legendary
	[LE_GARR_FOLLOWER_QUALITY_TITLE] = ITEM_QUALITY_COLORS[4]; -- Followers with the title (== 6) quality still appear as epic to players.
};

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
	missionPageAssignFollowerSound = SOUNDKIT.UI_GARRISON_COMMAND_TABLE_ASSIGN_FOLLOWER,
	missionPageAssignTroopSound = nil,
	missionPageMechanicYOffset = -16,
	missionPageShowXPInMissionInfo = false,
	missionPageMaxCountersInFollowerFrame = 3,
	missionPageMaxCountersInFollowerFrameBeforeScaling = 2,
	missionTooltipShowPartialCountersAsFull = false,
	partyNotFullText = GARRISON_PARTY_NOT_FULL_TOOLTIP,
	showCategoriesInFollowerList = false,
	showCautionSignOnMissionFollowersSmallBias = true,
	showILevelInFollowerList = true,
	showILevelOnFollower = false,
	showILevelOnMission = true,
	showNumFollowers = true,
	showSingleMissionCompleteAnimation = false,
	showSingleMissionCompleteFollower = false,
	showSpikyBordersOnSpecializationAbilities = false,
	strings = {
		LANDING_COMPLETE = GARRISON_LANDING_BUILDING_COMPLEATE,
		RETURN_TO_START = GARRISON_MISSION_TOOLTIP_RETURN_TO_START,
		CONFIRM_EQUIPMENT = GARRISON_FOLLOWER_CONFIRM_EQUIPMENT,
		CONFIRM_EQUIPMENT_REPLACEMENT = nil,
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
	missionPageAssignFollowerSound = nil,
	missionPageAssignTroopSound = nil,
	missionPageMechanicYOffset = 0,
	missionPageShowXPInMissionInfo = false,
	missionPageMaxCountersInFollowerFrame = math.huge,
	missionPageMaxCountersInFollowerFrameBeforeScaling = math.huge,
	missionTooltipShowPartialCountersAsFull = false,
	partyNotFullText = GARRISON_SHIPYARD_PARTY_NOT_FULL_TOOLTIP,
	showCategoriesInFollowerList = false,
	showCautionSignOnMissionFollowersSmallBias = true,
	showILevelInFollowerList = true,
	showILevelOnFollower = false,
	showILevelOnMission = true,
	showNumFollowers = true,
	showSingleMissionCompleteAnimation = true,
	showSingleMissionCompleteFollower = true,
	showSpikyBordersOnSpecializationAbilities = false,
	strings = {
		LANDING_COMPLETE = GARRISON_LANDING_BUILDING_COMPLEATE,
		RETURN_TO_START = GARRISON_SHIPYARD_MISSION_TOOLTIP_RETURN_TO_START,
		CONFIRM_EQUIPMENT = GARRISON_SHIPYARD_CONFIRM_EQUIPMENT,
		CONFIRM_EQUIPMENT_REPLACEMENT = GARRISON_FOLLOWER_CONFIRM_EQUIPMENT_REPLACEMENT,
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
	missionPageAssignFollowerSound = SOUNDKIT.UI_GARRISON_COMMAND_TABLE_SLOT_CHAMPION,
	missionPageAssignTroopSound = SOUNDKIT.UI_GARRISON_COMMAND_TABLE_SLOT_TROOP,
	missionPageMechanicYOffset = -32,
	missionPageShowXPInMissionInfo = true,
	missionPageMaxCountersInFollowerFrame = 3,
	missionPageMaxCountersInFollowerFrameBeforeScaling = 2,
	missionTooltipShowPartialCountersAsFull = true,
	partyNotFullText = GARRISON_PARTY_NOT_ENOUGH_CHAMPIONS,
	showCategoriesInFollowerList = true,
	showCautionSignOnMissionFollowersSmallBias = false,
	showILevelInFollowerList = true,
	showILevelOnFollower = false,
	showILevelOnMission = true,
	showNumFollowers = true,
	showSingleMissionCompleteAnimation = true,
	showSingleMissionCompleteFollower = false,
	showSpikyBordersOnSpecializationAbilities = true,
	strings = {
		LANDING_COMPLETE = ORDER_HALL_LANDING_COMPLETE,
		RETURN_TO_START = ORDER_HALL_MISSION_TOOLTIP_RETURN_TO_START,
		CONFIRM_EQUIPMENT = GARRISON_FOLLOWER_CONFIRM_EQUIPMENT,
		CONFIRM_EQUIPMENT_REPLACEMENT = GARRISON_FOLLOWER_CONFIRM_EQUIPMENT_REPLACEMENT,
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

GarrisonFollowerOptions[LE_FOLLOWER_TYPE_GARRISON_8_0] = {
	abilityTooltipFrame = "GarrisonFollowerAbilityWithoutCountersTooltip",
	displayCounterAbilityInPlaceOfMechanic = true,
	followerListCounterNumPerRow = 2,
	followerListCounterInnerSpacing = 4,
	followerListCounterOuterSpacingX = 8,
	followerListCounterOuterSpacingY = 4,
	followerListCounterScale = 1.15,
	followerPageShowSourceText = false,
	followerPageShowGear = false,
	garrisonType = LE_GARRISON_TYPE_8_0,
	hideCountersInAbilityFrame = true,
	hideMissionTypeInLandingPage = true,
	isPrimaryFollowerType = true,
	minFollowersForThreatCountersFrame = math.huge,
	minQualityLevelToShowLevel = LE_ITEM_QUALITY_POOR,
	missionAbilityTooltipFrame = "GarrisonFollowerMissionAbilityWithoutCountersTooltip",
	missionCompleteUseNeutralChest = true,
	missionFrame = "BFAMissionFrame",
	missionPageAssignFollowerSound = SOUNDKIT.UI_GARRISON_COMMAND_TABLE_SLOT_CHAMPION,
	missionPageAssignTroopSound = SOUNDKIT.UI_GARRISON_COMMAND_TABLE_SLOT_TROOP,
	missionPageMechanicYOffset = -32,
	missionPageShowXPInMissionInfo = true,
	missionPageMaxCountersInFollowerFrame = 3,
	missionPageMaxCountersInFollowerFrameBeforeScaling = 2,
	missionTooltipShowPartialCountersAsFull = true,
	partyNotFullText = GARRISON_PARTY_NOT_ENOUGH_CHAMPIONS,
	showCategoriesInFollowerList = true,
	showCautionSignOnMissionFollowersSmallBias = false,
	showILevelInFollowerList = false,
	showILevelOnFollower = false,
	showILevelOnMission = false,
	showNumFollowers = false,
	showSingleMissionCompleteAnimation = true,
	showSingleMissionCompleteFollower = false,
	showSpikyBordersOnSpecializationAbilities = true,
	strings = {
		LANDING_COMPLETE = BFA_LANDING_COMPLETE,
		RETURN_TO_START = BFA_MISSION_TOOLTIP_RETURN_TO_START,
		CONFIRM_EQUIPMENT = GARRISON_FOLLOWER_CONFIRM_EQUIPMENT,
		CONFIRM_EQUIPMENT_REPLACEMENT = GARRISON_FOLLOWER_CONFIRM_EQUIPMENT_REPLACEMENT,
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
	if (not GarrisonMissionFrame) then
		Garrison_LoadUI();
	end
	if (garrTypeID == LE_GARRISON_TYPE_6_0) then
		GarrisonLandingPage.Report.Title:SetText(GARRISON_LANDING_PAGE_TITLE);
		GarrisonLandingPage.FollowerList:Initialize(LE_FOLLOWER_TYPE_GARRISON_6_0);
		GarrisonLandingPage.ShipFollowerList:Initialize(LE_FOLLOWER_TYPE_SHIPYARD_6_2);
	elseif (garrTypeID == LE_GARRISON_TYPE_7_0) then
		GarrisonLandingPage.Report.Title:SetText(ORDER_HALL_LANDING_PAGE_TITLE);
		GarrisonLandingPage.FollowerList:Initialize(LE_FOLLOWER_TYPE_GARRISON_7_0);
	elseif (garrTypeID == LE_GARRISON_TYPE_8_0) then
		GarrisonLandingPage.Report.Title:SetText(GARRISON_TYPE_8_0_LANDING_PAGE_TITLE);
		GarrisonLandingPage.FollowerList:Initialize(LE_FOLLOWER_TYPE_GARRISON_8_0);
	else
		return;
	end

	GarrisonLandingPage.garrTypeID = garrTypeID;
	if (GarrisonLandingPage:IsShown()) then
		GarrisonLandingPage:UpdateUIToGarrisonType();
	else
		ShowUIPanel(GarrisonLandingPage);
	end

end

function DoesFollowerMatchCurrentGarrisonType(followerType)
	if followerType == LE_FOLLOWER_TYPE_GARRISON_7_0 then
		return C_Garrison.GetLandingPageGarrisonType() == LE_GARRISON_TYPE_7_0;
	elseif followerType == LE_FOLLOWER_TYPE_GARRISON_6_0 or followerType == LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
		return C_Garrison.GetLandingPageGarrisonType() == LE_GARRISON_TYPE_6_0;
	end

	return false;
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
	self.quality = quality;

	if (quality == LE_GARR_FOLLOWER_QUALITY_TITLE) then
		self.LevelBorder:SetAtlas("legionmission-portraitring_levelborder_epicplus", true);
		self.PortraitRing:SetAtlas("legionmission-portraitring-epicplus", true);
		self.PortraitRingQuality:Hide();
		self:SetQualityColor(1, 1, 1);
	else
		self.LevelBorder:SetAtlas("GarrMission_PortraitRing_LevelBorder", true);
		self.PortraitRing:SetAtlas("GarrMission_PortraitRing_Quality", true);
		self.PortraitRingQuality:Show();
		local color = quality and FOLLOWER_QUALITY_COLORS[quality] or nil;
		if (color) then
			self:SetQualityColor(color.r, color.g, color.b);
		else
			self:SetQualityColor(1, 1, 1);
		end
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
	if (self.quality == LE_GARR_FOLLOWER_QUALITY_TITLE) then
		self.LevelBorder:SetAtlas("legionmission-portraitring_levelborder_epicplus", true);
	else
		self.LevelBorder:SetAtlas("GarrMission_PortraitRing_LevelBorder");
	end
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