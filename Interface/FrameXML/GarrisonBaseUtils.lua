---------------------------------------------------------------------------------
-- Global Constants
---------------------------------------------------------------------------------
FOLLOWER_QUALITY_COLORS = {
	[Enum.GarrFollowerQuality.Common] = ITEM_QUALITY_COLORS[1]; -- Common
	[Enum.GarrFollowerQuality.Uncommon] = ITEM_QUALITY_COLORS[2]; -- Uncommon
	[Enum.GarrFollowerQuality.Rare] = ITEM_QUALITY_COLORS[3]; -- Rare
	[Enum.GarrFollowerQuality.Epic] = ITEM_QUALITY_COLORS[4]; -- Epic
	[Enum.GarrFollowerQuality.Legendary] = ITEM_QUALITY_COLORS[5]; -- Legendary
	[Enum.GarrFollowerQuality.Title] = ITEM_QUALITY_COLORS[4]; -- Followers with the title (== 6) quality still appear as epic to players.
};

---------------------------------------------------------------------------------
-- Display Options
---------------------------------------------------------------------------------
GarrisonFollowerOptions = { };
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_6_0] = {
	abilityTooltipFrame = "GarrisonFollowerAbilityTooltip",
	displayCounterAbilityInPlaceOfMechanic = false,
	followerListCounterNumPerRow = 2,
	followerListCounterInnerSpacing = 6,
	followerListCounterOuterSpacingX = 8,
	followerListCounterOuterSpacingY = 4,
	followerListCounterScale = 1.0,
	followerPageShowSourceText = true,
	followerPageShowGear = true,
	garrisonType = Enum.GarrisonType.Type_6_0,
	hideCountersInAbilityFrame = false,
	hideMissionTypeInLandingPage = false,
	isPrimaryFollowerType = true,
	minFollowersForThreatCountersFrame = 10,
	minQualityLevelToShowLevel = Enum.ItemQuality.Poor,
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
		FOLLOWER_NAME = GARRISON_FOLLOWERS,
		OUT_WITH_DURATION = GARRISON_FOLLOWER_ON_MISSION_WITH_DURATION,
		AVAILABILITY = GARRISON_MISSION_AVAILABILITY,
		NOT_ENOUGH_MATERIALS = GARRISON_NOT_ENOUGH_MATERIALS_TOOLTIP,
		TALENT_COMPLETE_TOAST_TITLE = GARRISON_TALENT_ORDER_ADVANCEMENT,
		ALERT_FRAME_TITLE = GARRISON_MISSION_COMPLETE,
		FOLLOWERLIST_LABEL_TROOPS = FOLLOWERLIST_LABEL_TROOPS,
		FOLLOWERLIST_LABEL_FOLLOWERS = FOLLOWERLIST_LABEL_CHAMPIONS,
		FOLLOWER_ON_COMPLETED_MISSION = GARRISON_FOLLOWER_ON_MISSION_COMPLETE,
	},
	traitAbilitiesAreEquipment = false,
	useAbilityTooltipStyleWithoutCounters = false,
	usesOvermaxMechanic = false,
	allowEquipmentCounterToShow = false,
	showCompleteDialog = true,
}

GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_6_2] = {
	abilityTooltipFrame = "GarrisonFollowerAbilityTooltip",
	displayCounterAbilityInPlaceOfMechanic = false,
	followerListCounterNumPerRow = 4,
	followerListCounterInnerSpacing = 6,
	followerListCounterOuterSpacingX = 8,
	followerListCounterOuterSpacingY = 4,
	followerListCounterScale = 1.0,
	followerPageShowSourceText = false,
	followerPageShowGear = false,
	garrisonType = Enum.GarrisonType.Type_6_0,
	hideCountersInAbilityFrame = false,
	hideMissionTypeInLandingPage = true,
	isPrimaryFollowerType = false,
	minFollowersForThreatCountersFrame = 1,
	minQualityLevelToShowLevel = Enum.ItemQuality.Poor,
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
		FOLLOWER_NAME = GARRISON_FOLLOWERS,
		OUT_WITH_DURATION = GARRISON_FOLLOWER_ON_MISSION_WITH_DURATION,
		AVAILABILITY = GARRISON_MISSION_AVAILABILITY,
		NOT_ENOUGH_MATERIALS = GARRISON_NOT_ENOUGH_MATERIALS_TOOLTIP,
		TALENT_COMPLETE_TOAST_TITLE = GARRISON_TALENT_ORDER_ADVANCEMENT,
		ALERT_FRAME_TITLE = GARRISON_MISSION_COMPLETE,
		FOLLOWERLIST_LABEL_TROOPS = nil,
		FOLLOWERLIST_LABEL_FOLLOWERS = nil,
		FOLLOWER_ON_COMPLETED_MISSION = GARRISON_FOLLOWER_ON_MISSION_COMPLETE,
	},
	traitAbilitiesAreEquipment = true,
	useAbilityTooltipStyleWithoutCounters = false,
	usesOvermaxMechanic = false,
	allowEquipmentCounterToShow = true,
	showCompleteDialog = true,
}

GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_7_0] = {
	abilityTooltipFrame = "GarrisonFollowerAbilityWithoutCountersTooltip",
	displayCounterAbilityInPlaceOfMechanic = true,
	followerListCounterNumPerRow = 2,
	followerListCounterInnerSpacing = 4,
	followerListCounterOuterSpacingX = 8,
	followerListCounterOuterSpacingY = 4,
	followerListCounterScale = 1.15,
	followerPageShowSourceText = false,
	followerPageShowGear = false,
	garrisonType = Enum.GarrisonType.Type_7_0,
	hideCountersInAbilityFrame = true,
	hideMissionTypeInLandingPage = true,
	isPrimaryFollowerType = true,
	minFollowersForThreatCountersFrame = math.huge,
	minQualityLevelToShowLevel = Enum.ItemQuality.Poor,
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
		FOLLOWER_NAME = GARRISON_FOLLOWERS,
		OUT_WITH_DURATION = GARRISON_FOLLOWER_ON_MISSION_WITH_DURATION,
		AVAILABILITY = GARRISON_MISSION_AVAILABILITY,
		NOT_ENOUGH_MATERIALS = GARRISON_NOT_ENOUGH_MATERIALS_TOOLTIP,
		TALENT_COMPLETE_TOAST_TITLE = GARRISON_TALENT_ORDER_ADVANCEMENT,
		ALERT_FRAME_TITLE = GARRISON_MISSION_COMPLETE,
		FOLLOWERLIST_LABEL_TROOPS = FOLLOWERLIST_LABEL_TROOPS,
		FOLLOWERLIST_LABEL_FOLLOWERS = FOLLOWERLIST_LABEL_CHAMPIONS,
		FOLLOWER_ON_COMPLETED_MISSION = GARRISON_FOLLOWER_ON_MISSION_COMPLETE,
	},
	traitAbilitiesAreEquipment = true,
	useAbilityTooltipStyleWithoutCounters = true,
	usesOvermaxMechanic = true,
	allowEquipmentCounterToShow = false,
	showCompleteDialog = true,
}

GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_8_0] = {
	abilityTooltipFrame = "GarrisonFollowerAbilityWithoutCountersTooltip",
	displayCounterAbilityInPlaceOfMechanic = true,
	followerListCounterNumPerRow = 2,
	followerListCounterInnerSpacing = 4,
	followerListCounterOuterSpacingX = 8,
	followerListCounterOuterSpacingY = 4,
	followerListCounterScale = 1.15,
	followerPageShowSourceText = false,
	followerPageShowGear = false,
	garrisonType = Enum.GarrisonType.Type_8_0,
	hideCountersInAbilityFrame = true,
	hideMissionTypeInLandingPage = true,
	isPrimaryFollowerType = true,
	minFollowersForThreatCountersFrame = math.huge,
	minQualityLevelToShowLevel = Enum.ItemQuality.Poor,
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
		FOLLOWER_NAME = GARRISON_FOLLOWERS,
		OUT_WITH_DURATION = GARRISON_FOLLOWER_ON_MISSION_WITH_DURATION,
		AVAILABILITY = GARRISON_MISSION_AVAILABILITY,
		NOT_ENOUGH_MATERIALS = GARRISON_NOT_ENOUGH_MATERIALS_TOOLTIP,
		TALENT_COMPLETE_TOAST_TITLE = GARRISON_TALENT_ORDER_ADVANCEMENT,
		ALERT_FRAME_TITLE = GARRISON_MISSION_COMPLETE,
		FOLLOWERLIST_LABEL_TROOPS = FOLLOWERLIST_LABEL_TROOPS,
		FOLLOWERLIST_LABEL_FOLLOWERS = FOLLOWERLIST_LABEL_CHAMPIONS,
		FOLLOWER_ON_COMPLETED_MISSION = GARRISON_FOLLOWER_ON_MISSION_COMPLETE,
	},
	traitAbilitiesAreEquipment = true,
	useAbilityTooltipStyleWithoutCounters = true,
	usesOvermaxMechanic = true,
	allowEquipmentCounterToShow = false,
	showCompleteDialog = true,
}

GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_9_0] = {
	abilityTooltipFrame = "GarrisonFollowerAbilityWithoutCountersTooltip",
	displayCounterAbilityInPlaceOfMechanic = true,
	followerListCounterNumPerRow = 2,
	followerListCounterInnerSpacing = 4,
	followerListCounterOuterSpacingX = 8,
	followerListCounterOuterSpacingY = 4,
	followerListCounterScale = 1.15,
	followerPageShowSourceText = false,
	followerPageShowGear = false,
	garrisonType = Enum.GarrisonType.Type_9_0,
	hideCountersInAbilityFrame = true,
	hideMissionTypeInLandingPage = true,
	isPrimaryFollowerType = true,
	minFollowersForThreatCountersFrame = math.huge,
	minQualityLevelToShowLevel = Enum.ItemQuality.Poor,
	missionAbilityTooltipFrame = "GarrisonFollowerMissionAbilityWithoutCountersTooltip",
	missionCompleteUseNeutralChest = false,
	missionFrame = "CovenantMissionFrame",
	missionPageAssignFollowerSound = SOUNDKIT.UI_GARRISON_COMMAND_TABLE_SLOT_CHAMPION,
	missionPageAssignTroopSound = SOUNDKIT.UI_GARRISON_COMMAND_TABLE_SLOT_TROOP,
	missionPageMechanicYOffset = -32,
	missionPageShowXPInMissionInfo = false,
	missionPageMaxCountersInFollowerFrame = 3,
	missionPageMaxCountersInFollowerFrameBeforeScaling = 2,
	missionTooltipShowPartialCountersAsFull = true,
	partyNotFullText = COVENANT_MISSIONS_NOT_ENOUGH_ADVENTURERS,
	showCategoriesInFollowerList = true,
	showCautionSignOnMissionFollowersSmallBias = false,
	showILevelInFollowerList = false,
	showILevelOnFollower = false,
	showILevelOnMission = false,
	showNumFollowers = false,
	showSingleMissionCompleteAnimation = false,
	showSingleMissionCompleteFollower = false,
	showSpikyBordersOnSpecializationAbilities = false,
	strings = {
		LANDING_COMPLETE = COVENANT_MISSIONS_TOOLTIP_RETURN_TO_COMPLETE,
		RETURN_TO_START = COVENANT_MISSIONS_TOOLTIP_RETURN_TO_START,
		CONFIRM_EQUIPMENT = GARRISON_FOLLOWER_CONFIRM_EQUIPMENT,
		CONFIRM_EQUIPMENT_REPLACEMENT = GARRISON_FOLLOWER_CONFIRM_EQUIPMENT_REPLACEMENT,
		TRAITS_LABEL = ORDER_HALL_EQUIPMENT_SLOTS,
		FOLLOWER_ADDED_TOAST = COVENANT_MISSIONS_ADVENTURER_GAINED,
		FOLLOWER_ADDED_UPGRADED_TOAST = COVENANT_MISSIONS_FOLLOWER_ADDED_UPGRADED_TOAST,
		TROOP_ADDED_TOAST = COVENANT_MISSIONS_ADVENTURER_GAINED,
		TROOP_ADDED_UPGRADED_TOAST = COVENANT_MISSIONS_FOLLOWER_ADDED_UPGRADED_TOAST,
		FOLLOWER_COUNT_LABEL = FOLLOWERLIST_LABEL_CHAMPIONS,
		FOLLOWER_COUNT_STRING = GARRISON_CHAMPION_COUNT,
		FOLLOWER_NAME = COVENANT_MISSIONS_FOLLOWERS,
		OUT_WITH_DURATION = COVENANT_MISSIONS_ON_ADVENTURE_DURATION,
		AVAILABILITY = COVENANT_MISSIONS_AVAILABILITY,
		NOT_ENOUGH_MATERIALS = COVENANT_MISSIONS_NOT_ENOUGH_MATERIALS,
		TALENT_COMPLETE_TOAST_TITLE = COVENANT_PROGRESS,
		ALERT_FRAME_TITLE = COVENANT_MISSIONS_ADVENTURE_COMPLETE,
		FOLLOWERLIST_LABEL_TROOPS = FOLLOWERLIST_LABEL_TROOPS,
		FOLLOWERLIST_LABEL_FOLLOWERS = COVENANT_MISSIONS_FOLLOWERS,
		FOLLOWER_ON_COMPLETED_MISSION = COVENANT_FOLLOWER_MISSION_COMPLETE,
	},
	traitAbilitiesAreEquipment = true,
	useAbilityTooltipStyleWithoutCounters = true,
	usesOvermaxMechanic = false,
	allowEquipmentCounterToShow = false,
	showCompleteDialog = false,
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

GarrisonLandingPage.Report.Title:SetTextColor(NORMAL_FONT_COLOR:GetRGBA());

	if (garrTypeID == Enum.GarrisonType.Type_6_0) then
		GarrisonLandingPage.Report.Title:SetText(GARRISON_LANDING_PAGE_TITLE);
		GarrisonLandingPage.FollowerList:Initialize(Enum.GarrisonFollowerType.FollowerType_6_0);
		GarrisonLandingPage.ShipFollowerList:Initialize(Enum.GarrisonFollowerType.FollowerType_6_2);
	elseif (garrTypeID == Enum.GarrisonType.Type_7_0) then
		GarrisonLandingPage.Report.Title:SetText(ORDER_HALL_LANDING_PAGE_TITLE);
		GarrisonLandingPage.FollowerList:Initialize(Enum.GarrisonFollowerType.FollowerType_7_0);
	elseif (garrTypeID == Enum.GarrisonType.Type_8_0) then
		GarrisonLandingPage.Report.Title:SetText(GARRISON_TYPE_8_0_LANDING_PAGE_TITLE);
		GarrisonLandingPage.FollowerList:Initialize(Enum.GarrisonFollowerType.FollowerType_8_0);
	elseif (garrTypeID == Enum.GarrisonType.Type_9_0) then
		local pageTitle = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE;
		local activeCovenantID = C_Covenants.GetActiveCovenantID();
		if activeCovenantID and activeCovenantID > 0 then
			local covenantData = C_Covenants.GetCovenantData(activeCovenantID);
			if covenantData then
				pageTitle = covenantData.name;
			end
		end

		GarrisonLandingPage.Report.Title:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGBA());
		GarrisonLandingPage.Report.Title:SetText(pageTitle);
		GarrisonLandingPage.FollowerList:Initialize(Enum.GarrisonFollowerType.FollowerType_9_0);
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
	local followerOptions = GarrisonFollowerOptions[followerType];
	if not followerOptions then
		GMError("Unknown follower type");
		return false;
	end

	return followerOptions.garrisonType == C_Garrison.GetLandingPageGarrisonType();
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

	if (quality == Enum.GarrFollowerQuality.Title) then
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
	if (self.quality == Enum.GarrFollowerQuality.Title) then
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

---------------------------------------------------------------------------------
--- Talent Tree                                                               ---
---------------------------------------------------------------------------------

function GetGarrisonTalentCostString(talentInfo, abbreviate, colorCode)
	local costString;

	local function AddCost(cost)
		if costString then
			costString = costString.."  "..cost;
		else
			costString = cost;
		end
	end

	for i, researchCostInfo in ipairs(talentInfo.researchCurrencyCosts) do
		local cost = researchCostInfo.currencyQuantity;
		local currencyColorCode = colorCode;
		if currencyColorCode == nil then
			local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(researchCostInfo.currencyType);
			if currencyInfo and (currencyInfo.quantity < cost) then
				currencyColorCode = RED_FONT_COLOR_CODE;
			end
		end
		AddCost(GetCurrencyString(researchCostInfo.currencyType, cost, currencyColorCode, abbreviate));
	end
	if talentInfo.researchGoldCost > 0 then
		AddCost(talentInfo.researchGoldCost.."|TINTERFACE\\MONEYFRAME\\UI-MoneyIcons.blp:16:16:2:0:64:16:0:16:0:16|t");
	end

	return costString;
end

---------------------------------------------------------------------------------
--- Auto Combat Util                                                          ---
---------------------------------------------------------------------------------

GarrAutoCombatUtil = {};

function GarrAutoCombatUtil.GetFollowerAutoCombatSpells(followerGUID, level, includeAutoAttack)
	local spellInfo, autoAttack = C_Garrison.GetFollowerAutoCombatSpells(followerGUID, level);
	if includeAutoAttack and (autoAttack ~= nil) then
		table.insert(spellInfo, autoAttack);
	end

	return spellInfo;
end

function GarrAutoCombatUtil.CreateTextureMarkupForTooltipSpellIcon(icon)
	return CreateTextureMarkup(icon, 64, 64, 16, 16, 0, 1, 0, 1, 0, 0);
end

function GarrAutoCombatUtil.GetAuraTypeAtlasesFromPreviewMask(previewMask)
	local atlases = {};
	if FlagsUtil.IsSet(previewMask, Enum.GarrAutoPreviewTargetType.Buff) then
		table.insert(atlases, "Adventure-buff-indicator-small");
	end

	if FlagsUtil.IsSet(previewMask, Enum.GarrAutoPreviewTargetType.Heal) then
		table.insert(atlases, "Adventure-heal-indicator-small");
	end

	if FlagsUtil.IsSet(previewMask, Enum.GarrAutoPreviewTargetType.Debuff) then
		table.insert(atlases, "Adventure-debuff-indicator-small");
	end

	return atlases;
end

function GarrAutoCombatUtil.GetAtlasMarkupFromPreviewMask(previewMask)
	local previewTypeAtlases = GarrAutoCombatUtil.GetAuraTypeAtlasesFromPreviewMask(previewMask);
	local output = "";
	for i, atlas in ipairs(previewTypeAtlases) do
		if i > 1 then
			output = output.." ";
		end

		output = output..CreateAtlasMarkupWithAtlasSize(atlas);
	end

	return output;
end

function GarrAutoCombatUtil.AddAuraToTooltip(tooltip, auraSpellID, dynamicPreviewMask)
	local autoCombatSpellInfo = C_Garrison.GetCombatLogSpellInfo(auraSpellID);
	if autoCombatSpellInfo then
		local iconMarkup = GarrAutoCombatUtil.CreateTextureMarkupForTooltipSpellIcon(autoCombatSpellInfo.icon);
		local leftText = COVENANT_MISSIONS_AURA_TOOLTIP_ENTRY_FORMAT:format(iconMarkup, autoCombatSpellInfo.name);

		local previewTypeMarkup = GarrAutoCombatUtil.GetAtlasMarkupFromPreviewMask(dynamicPreviewMask or autoCombatSpellInfo.previewMask);
		
		GameTooltip_AddColoredDoubleLine(tooltip, leftText, previewTypeMarkup, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR);
	end
end

local AbilityEventTypes = {
	Enum.GarrAutoMissionEventType.MeleeDamage,
	Enum.GarrAutoMissionEventType.RangeDamage,
	Enum.GarrAutoMissionEventType.SpellMeleeDamage,
	Enum.GarrAutoMissionEventType.SpellRangeDamage,
	Enum.GarrAutoMissionEventType.Heal,
	Enum.GarrAutoMissionEventType.ApplyAura,
};

function GarrAutoCombatUtil.IsAbilityEvent(event)
	local eventType = event.type;
	if not tContains(AbilityEventTypes, eventType) then
		return false;
	end

	-- Thorns damage effects apply outside the normal "turn" for the combatant so
	-- we don't want to include them outside of the initial application of the thorns buff.
	local spellInfo = C_Garrison.GetCombatLogSpellInfo(event.spellID);
	if (spellInfo == nil) or (spellInfo.hasThornsEffect and (eventType ~= Enum.GarrAutoMissionEventType.ApplyAura)) then
		return false;
	end

	return true;
end