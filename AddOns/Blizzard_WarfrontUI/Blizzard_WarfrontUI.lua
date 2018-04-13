local RESOURCE_ATLAS = {
	[Enum.WarfrontResourceType.Iron] = "warfront_hud-icon1",
	[Enum.WarfrontResourceType.Lumber] = "warfront_hud-icon2",
	[Enum.WarfrontResourceType.Essence] = "warfront_hud-icon3",
};

WarfrontEventRegisterMixin = {};

function WarfrontEventRegisterMixin:OnLoad()
	self:RegisterEvent("SCENARIO_UPDATE");
	self:RegisterEvent("SCENARIO_COMPLETED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function WarfrontEventRegisterMixin:OnEvent(event)
	if ( event == "SCENARIO_UPDATE" or event == "PLAYER_ENTERING_WORLD" ) then
		-- temp
		local name = C_Scenario.GetInfo();
		self.inWarfrontScenario = (name == "The Battle for Stromgarde");
	elseif ( event == "SCENARIO_COMPLETED" and self.inWarfrontScenario ) then
		self:OnScenarioCompleted();
	end
end

function WarfrontEventRegisterMixin:OnScenarioCompleted()
	-- temp
	UIParentLoadAddOn("Blizzard_PVPUI");
	PlaySound(SOUNDKIT.PVP_THROUGH_QUEUE);
	TopBannerManager_Show(self, { name="The Battle for Stromgarde", description="Horde wins!" });
end

WarfrontResourceMixin = { };

function WarfrontResourceMixin:OnLoad()
	self.Icon:SetAtlas(RESOURCE_ATLAS[self.resourceType], true);
end

function WarfrontResourceMixin:OnEnter()
	local resourceInfo = C_Warfront.GetResourceInfo(self.resourceType);
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0);
	GameTooltip:SetText(resourceInfo.name);
	GameTooltip:AddLine(resourceInfo.description, 1, 1, 1, 1);
	GameTooltip:Show();
end

-- only units that appear in both buildable and capturable locations need enabledCondition

local ASSETS = {
	["GRUNT"] = {
		name = "Grunts",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14999, checkPersonal = true },
		},
		-- 15000, 15001
		--recruitPCID = 56388,
		texture = "Interface\\Icons\\achievement_character_orc_female",
		--enabledCondition = { WSID = 14498, value = 2},
	},
	["WITCH_DOCTOR"] = {
		name = "Witch Doctors",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15003, checkPersonal = true },
		},		
		recruitPCID = 56390,
		texture = "Interface\\Icons\\inv_hand_1h_trollshaman_c_01",
		enabledCondition = { WSID = 14151, value = 2},
	},
	["AXE_THROWER"] = {
		name = "Axe Throwers",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15466, checkPersonal = true },
		},		
		--recruitPCID = 57058,
		texture = "Interface\\Icons\\achievement_character_troll_male",
		--enabledCondition = { WSID = 14498, value = 2 },
	},
	["SHAMAN"] = {
		name = "Shaman",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15002, checkPersonal = true },
		},
		recruitPCID = 56389,
		texture = "Interface\\Icons\\trade_archaeology_ancientorcshamanheaddress",
		enabledCondition = { WSID = 14151, value = 2},
	},
	["WOLF_RAIDER"] = {
		name = "Wolf Raiders",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15004, checkPersonal = true },
		},		
		recruitPCID = 56393,
		texture = "Interface\\Icons\\achievement_boss_korkrondarkshaman",
		enabledCondition = { WSID = 14293, value = 2 },
	},
	["DEMOLISHER"] = {
		name = "Demolishers",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15005, checkPersonal = true },
		},		
		--recruitPCID = 56394,
		texture = "Interface\\Icons\\ability_vehicle_demolisherflamecatapult",
		--enabledCondition = { WSID = 14511, value = 2},
	},
	["WAR_TRIKE"] = {
		name = "War Trike",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15006, checkPersonal = true },
		},		
		--recruitPCID = 56395,
		texture = "Interface\\Icons\\inv_viciousgoblintrike",
		--enabledCondition = { WSID = 14511, value = 2},
	},
	["SAPPER"] = {
		name = "Crazed Bomber",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15007, checkPersonal = true },
		},		
		--recruitPCID = 56396,
		texture = "Interface\\Icons\\achievement_femalegoblinhead",
		--enabledCondition = { WSID = 14511, value = 2},
	},
	["ELEMENTAL_SPIRIT"] = {
		name = "Elemental Spirit",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15026, checkPersonal = true },
		},
		texture = "Interface\\Icons\\spell_fire_elemental_totem",
		enabledCondition = { WSID = 14151, value = 2},
	},
	["KODO_RIDER"] = {
		name = "Kodo Rider",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15044, checkPersonal = true },
		},
		texture = "Interface\\Icons\\ability_mount_viciouswarkodo",
		enabledCondition = { WSID = 14293, value = 2 },
	},
	["FLIGHT_MASTER"] = {
		name = "Flight Master",
		description = "Fly to captured locations.",
		texture = "Interface\\Icons\\ability_mount_gyrocoptor",
		enabledCondition = { WSID = 14272, value = 2},
	},
	["PEON_OVERSEER"] = {
		name = "Peon Overseer",
		description = "Train Peons to get resources",
		texture = "Interface\\Icons\\achievement_character_orc_male_brn",
		enabledCondition = { WSID = 14028, greaterThanValue = 0 },
		ignoreBuildingState = true,
	},	
	["BRISTLING_POWER"] = {
		name = "Bristling Power",
		texture = 458176,
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15042, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15042, checkPersonal = true, orCosts = true },
		},
	},
	["CALL_OF_THE_STORM"] = {
		name = "Call of the Storm",
		texture = 136099,
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Essence, costWSID = 15043, checkPersonal = true },
		},
	},
	["WEAPON_UPGRADE_1"] = {
		name = "Steel Weapons",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14442,
		},
		texture = "Interface\\Icons\\garrison_greenweapon",
		visibilityConditions = { 
			[1] = { WSID = 14442, lessThanWSID = 14453 },
		},
	},
	["WEAPON_UPGRADE_2"] = {
		name = "Thorium Weapons",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14645,
		},
		texture = "Interface\\Icons\\garrison_blueweapon",
		visibilityConditions = { 
			[1] = { WSID = 14645, lessThanWSID = 14453 },
			[2] = { WSID = 14442, equalWSID = 14453 },
		},
	},
	["WEAPON_UPGRADE_3"] = {
		name = "Arcanite Weapons",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14647,
		},
		texture = "Interface\\Icons\\garrison_purpleweapon",
		visibilityConditions = { 
			[1] = { WSID = 14647, lessThanWSID = 14453 },
			[2] = { WSID = 14645, equalWSID = 14453 },
		},
	},
	["WEAPON_UPGRADE_3_FINAL"] = {
		name = "Arcanite Weapons",
		texture = "Interface\\Icons\\garrison_purpleweapon",
		description = "Research fully completed",
		visibilityConditions = { 
			[1] = { WSID = 14647, equalWSID = 14453 },
		},
	},
	["ARMOR_UPGRADE_1"] = {
		name = "Steel Armor",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},		
		texture = "Interface\\Icons\\garrison_greenarmor",
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14458,
		},
		visibilityConditions = { 
			[1] = { WSID = 14458, lessThanWSID = 14453 },
		},
	},
	["ARMOR_UPGRADE_2"] = {
		name = "Thorium Armor",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},
		texture = "Interface\\Icons\\garrison_bluearmor",
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14646,
		},
		visibilityConditions = { 
			[1] = { WSID = 14646, lessThanWSID = 14453 },
			[2] = { WSID = 14458, equalWSID = 14453 },
		},
	},
	["ARMOR_UPGRADE_3"] = {
		name = "Arcanite Armor",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15008, checkPersonal = true, orCosts = true },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15009, checkPersonal = true },
		},
		texture = "Interface\\Icons\\garrison_purplearmor",
		progressBar = {
			maxValueWSID = 14453,
			currentValueWSID = 14648,
		},
		visibilityConditions = { 
			[1] = { WSID = 14648, lessThanWSID = 14453 },
			[2] = { WSID = 14646, equalWSID = 14453 },
		},
	},
	["ARMOR_UPGRADE_3_FINAL"] = {
		name = "Arcanite Armor",
		texture = "Interface\\Icons\\garrison_purplearmor",
		description = "Research fully completed",
		visibilityConditions = { 
			[1] = { WSID = 14648, equalWSID = 14453 },
		},
	},
	["GREAT_HALL"] = {
		name = "Great Hall                 Level 1",
		texture = "Interface\\Icons\\Achievement_garrison_tier01_horde",
		description = "Current level",
		visibilityConditions = { 
			[1] = { WSID = 14028, lessThanValue = 2 },
		},
		enabledCondition = { WSID = 14028, value = 1, failureText = RED_FONT_COLOR_CODE.."Capture And Rebuild!" },
		list = { "Required to construct other buildings" },
	},
	["STRONGHOLD"] = {
		name = "Stronghold               Level 2",
		texture = "Interface\\Icons\\Achievement_garrison_tier02_horde",
		recruitPCID = 56404,
		description = "Current level",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14525, progressWSID = 14524 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14601, progressWSID = 14600 },
		},
		makeProgressBarFromCosts = true,
		enabledCondition = { WSID = 14541, value = 2 },
		visibilityConditions = { 
			[1] = { WSID = 14028, lessThanValue = 3 },
		},
		builtCondition = { WSID = 14028, value = 2 },
		list = { "Increases number of peons collecting Iron", "Increases rate of unit production from Barracks", "Unlocks commander specific unit from Barracks" },
	},
	["FORTRESS"] = {
		name = "Fortress                     Level 3",
		texture = "Interface\\Icons\\Achievement_garrison_tier03_horde",
		recruitPCID = 56405,
		description = "Current level",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14538, progressWSID = 14536 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14603, progressWSID = 14602 },
		},	
		makeProgressBarFromCosts = true,
		enabledCondition = { WSID = 14506, value = 2 },	
		builtCondition = { WSID = 14028, value = 3 },
		list = { "Increases number of peons collecting Iron", "Increases rate of unit production from Barracks", "Increases damage dealt by Demolishers", "Commanders can now use special ability" },
	},
};

local LOCATIONS = {
	["DESTROYED_TOWN_HALL"] = { 
		assets = { "GREAT_HALL", "STRONGHOLD", "FORTRESS" },
		checkRecruitCondition = true,
		addBreakAfterTopSection = true,
	},	
	["TOWN_HALL"] = { 
		assets = { "GREAT_HALL", "STRONGHOLD", "FORTRESS" },
		checkRecruitCondition = true,
		ignoreNameAndDescription = true,
	},
	["BARRACKS"] = {
		buildPCID = 56400,
		costsLabel = "Requires:",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14500, progressWSID = 14499 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14593, progressWSID = 14590 },
		},
		assets = { "GRUNT", "AXE_THROWER", "SHAMAN", "WOLF_RAIDER"},
		assetsLabel = { 
			[1] = { text = "Train:" },
		},
		showProgressBar = true,
		checkRecruitCondition = true,
		addBreakAfterTopSection = true,
		builtCondition = { WSID = 14498, value = 2},
	},
	["ARMORY"] = {
		buildPCID = 56403,
		costsLabel = "Requires:",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14509, progressWSID = 14507 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14594, progressWSID = 14591 },
		},
		assets = { "WEAPON_UPGRADE_1", "WEAPON_UPGRADE_2", "WEAPON_UPGRADE_3", "WEAPON_UPGRADE_3_FINAL", "ARMOR_UPGRADE_1", "ARMOR_UPGRADE_2", "ARMOR_UPGRADE_3", "ARMOR_UPGRADE_3_FINAL" },
		assetsLabel = { 
			[1] = { text = "Research:" },
		},
		showProgressBar = true,
		checkRecruitCondition = true,
		addBreakAfterTopSection = true,
		builtCondition = { WSID = 14506, value = 2},
	},
	["NEWSTEAD"] = {
		assetsLabel = { 
			[1] = {
				condition = { WSID = 14293, value = 1 },
				text = "Unlock:",
			},
			[2] = {
				condition = { WSID = 14293, value = 2 },
				text = "Train:",
			},
		},
		assets = { "WOLF_RAIDER", "KODO_RIDER" },
		showProgressBar = false,
		checkRecruitCondition = false,
		addBreakAfterTopSection = true,
		stateLabel = {
			[1] = {
				condition = { WSID = 14293, value = 1 },
				text = "|nCapture %s",
			},
		},
	},
	["CIRCLE_OF_ELEMENTS"] = {
		assetsLabel = { 
			[1] = {
				condition = { WSID = 14151, value = 0 },
				text = "Unlock:",
			},
			[2] = {
				condition = { WSID = 14151, value = 1 },
				text = "Unlock:",
			},
			[3] = {
				condition = { WSID = 14151, value = 2 },
				text = "Train:",
			},
		},
		assets = { "SHAMAN", "ELEMENTAL_SPIRIT" },
		showProgressBar = false,
		checkRecruitCondition = false,
		addBreakAfterTopSection = true,
		stateLabel = {
			[1] = {
				condition = { WSID = 14151, value = 0 },
				text = "|nCapture %s",
			},
			[2] = {
				condition = { WSID = 14151, value = 1 },
				text = "|nCapture %s",
			},
		},
	},	
	["LUMBER_MILL"] = {
		stateLabel = {
			[1] = {
				condition = { WSID = 14286, value = 0 },
				text = "Capture %s",
			},
			[2] = {
				condition = { WSID = 14286, value = 1 },
				text = "Capture %s",
			},
		},
		addBreakAfterTopSection = true,
	},	
	["MINE"] = {
		stateLabel = {
			[1] = {
				condition = { WSID = 14413, value = 0 },
				text = "Capture %s",
			},
			[2] = {
				condition = { WSID = 14413, value = 1 },
				text = "Capture %s",
			},
		},
		addBreakAfterTopSection = true,
	},
	["WORKSHOP"] = {
		buildPCID = 56402,
		costsLabel = "Requires:",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14514, progressWSID = 14512 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14595, progressWSID = 14592 },
		},
		assets = {"DEMOLISHER"},
		assetsLabel = { 
			[1] = { text = "Train:" },
		},
		showProgressBar = true;
		addBreakAfterTopSection = true,
		builtCondition = { WSID = 14511, value = 2},
	},
	["HIGH_PERCH"] = {
		stateLabel = {
			[1] = {
				condition = { WSID = 14272, value = 0 },
				text = "|nCapture %s",
			},
			[2] = {
				condition = { WSID = 14272, value = 1 },
				text = "|nCapture %s",
			},
		},
		assets = {"FLIGHT_MASTER"},	
		assetsLabel = { 
			[1] = {
				condition = { WSID = 14272, value = 0 },
				text = "Unlock:",
			},
			[2] = {
				condition = { WSID = 14272, value = 1 },
				text = "Unlock:",
			},
			[3] = {
				condition = { WSID = 14151, value = 2 },
				text = "Available:",
			},
		},
		addBreakAfterTopSection = true,
	},
	["ALTAR"] = {
		buildPCID = 56401,
		costsLabel = "Requires:",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14543, progressWSID = 14542 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14599, progressWSID = 14598 },
		},
		assets = { "BRISTLING_POWER", "CALL_OF_THE_STORM" },
		assetsLabel = { 
			[1] = { text = "Provides:" },
		},
		showProgressBar = true;
		addBreakAfterTopSection = true,
		builtCondition = { WSID = 14541, value = 2 },
	},
	["NORTHFOLD_CROSSING"] = {
	},
	["VALORCALL_PASS"] = {
	},
	["STROMGARDE_KEEP"] = {
	},
};

local AREA_POI_LOOKUP = {
	[5581] = "BARRACKS",
	[5586] = "BARRACKS",
	[5542] = "NEWSTEAD",
	[5541] = "NEWSTEAD",
	[5532] = "LUMBER_MILL",
	[5531] = "LUMBER_MILL",
	[5550] = "CIRCLE_OF_ELEMENTS",
	[5538] = "CIRCLE_OF_ELEMENTS",
	[5537] = "CIRCLE_OF_ELEMENTS",
	[5549] = "MINE",
	[5540] = "MINE",
	[5539] = "MINE",
	[5583] = "WORKSHOP",
	[5588] = "WORKSHOP",
	[5536] = "HIGH_PERCH",
	[5535] = "HIGH_PERCH",
	[5584] = "ARMORY",
	[5589] = "ARMORY",
	[5560] = "DESTROYED_TOWN_HALL",	-- destroyed great hall
	[5585] = "TOWN_HALL",			-- great hall	
	[5590] = "TOWN_HALL",			-- stronghold
	[5593] = "TOWN_HALL",			-- fortress
	[5582] = "ALTAR",
	[5587] = "ALTAR",
	-- these are just for tooltip positioning purposes
	[5533] = "NORTHFOLD_CROSSING",
	[5534] = "NORTHFOLD_CROSSING",
	[5544] = "VALORCALL_PASS",
	[5543] = "VALORCALL_PASS",
	[5592] = "STROMGARDE_KEEP",
}

-- trinary
local function CheckCondition(conditionInfo)
	if ( conditionInfo ) then
		local value = C_Warfront.GetWorldStateValue(conditionInfo.WSID);
		if ( conditionInfo.value ) then
			return value == conditionInfo.value;
		elseif ( conditionInfo.greaterThanValue ) then
			return value > conditionInfo.greaterThanValue;
		elseif ( conditionInfo.lessThanValue ) then
			return value < conditionInfo.lessThanValue;
		elseif ( conditionInfo.lessThanWSID ) then
			return value < C_Warfront.GetWorldStateValue(conditionInfo.lessThanWSID);
		elseif ( conditionInfo.equalWSID ) then	
			return value == C_Warfront.GetWorldStateValue(conditionInfo.equalWSID);
		end
	end
	return nil;
end

local function CheckConditions(conditions)
	if ( not conditions ) then
		return nil;
	end
	for i, conditionInfo in ipairs(conditions) do
		local value = CheckCondition(conditionInfo);
		if ( value ~= true ) then
			return value;
		end
	end
	return true;
end

--==============================================================================================================================================
WarfrontTooltipControllerMixin = { };

function WarfrontTooltipControllerMixin:InitializeTooltip(tooltip, anchor, areaPoiID, name, description)
	local locationTag = AREA_POI_LOOKUP[areaPoiID];
	if ( not locationTag or not LOCATIONS[locationTag] ) then
		return false;
	end

	self.location = LOCATIONS[locationTag];
	self.canAccessAssets = true;
	self.name = name;
	self.tooltip = tooltip;
	if not ( self.assetPool ) then
		self.costFrame = CreateFrame("FRAME", nil, nil, "WarfrontTooltipCostTemplate");
		self.assetPool = CreateFramePool("FRAME", nil, "WarfrontTooltipAssetTemplate");
		self.progressBarPool = CreateFramePool("FRAME", nil, "TooltipProgressBarTemplate");
	else
		self.assetPool:ReleaseAll();
		self.progressBarPool:ReleaseAll();
		self.costFrame:ClearCosts();
	end

	self.tooltip:SetOwner(anchor, "ANCHOR_BOTTOMRIGHT");
	if ( not self.location.ignoreNameAndDescription ) then
		self.tooltip:SetText(name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		self.tooltip:AddLine(description);
	end
	
	return true;
end

function WarfrontTooltipControllerMixin:GetCanAccessAssets()
	return self.canAccessAssets;
end

function WarfrontTooltipControllerMixin:GetLocation()
	return self.location;
end

function WarfrontTooltipControllerMixin:GetTooltip()
	return self.tooltip;
end

function WarfrontTooltipControllerMixin:AddBuildRequirements()
	if ( CheckCondition(self.location.builtCondition) ) then
		return false;
	end

	local addedToTooltip = false;
	local canBuild = false;
	if ( self.location.buildPCID ) then
		local buildErrorText;
		canBuild, buildErrorText = C_Warfront.GetPlayerConditionInfo(self.location.buildPCID);
		if ( not canBuild ) then
			self.tooltip:AddLine(buildErrorText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			addedToTooltip = true;
		end
	end
	
	self.costFrame:AddCosts(self.location.costs);
	if ( self.costFrame.totalProgress < self.costFrame.totalCost ) then
		if ( self.location.showProgressBar and canBuild ) then
			local progressBar = self.progressBarPool:Acquire();
			progressBar.Bar:SetMinMaxValues(0, self.costFrame.totalCost);
			progressBar.Bar:SetValue(self.costFrame.totalProgress);
			GameTooltip_InsertFrame(self.tooltip, progressBar);
			progressBar.Bar.Label:SetText(FormatPercentage(self.costFrame.totalProgress / self.costFrame.totalCost, true));
		else
			self.tooltip:AddLine(" ");
		end
		self.tooltip:AddLine(self.location.costsLabel);
		GameTooltip_InsertFrame(self.tooltip, self.costFrame);
		addedToTooltip = true;
	end
	self.canAccessAssets = not addedToTooltip;
	return addedToTooltip;
end

function WarfrontTooltipControllerMixin:AddAssets(assets)
	if ( not assets ) then
		return;
	end

	local numAssetsAdded = 0;
	for i, assetTag in ipairs(assets) do
		local added = false;
		if ( ASSETS[assetTag].simpleAsset ) then
			self:AddAssetsLabel(numAssetsAdded);
			self:AddSimpleAsset(ASSETS[assetTag]);
			added = true;
		else
			local assetFrame = self.assetPool:Acquire();
			if ( assetFrame:SetUp(ASSETS[assetTag]) ) then
				self:AddAssetsLabel(numAssetsAdded);
				GameTooltip_InsertFrame(self.tooltip, assetFrame);
				assetFrame:CheckAndAddProgressBar();
				assetFrame:CheckAndAddList();
				added = true;
			end
		end
		if ( added ) then
			numAssetsAdded = numAssetsAdded + 1;
		end
	end
end

function WarfrontTooltipControllerMixin:AddSimpleAsset(assetInfo)
	if ( assetInfo.nameRight ) then
		self.tooltip:AddDoubleLine(assetInfo.name, assetInfo.nameRight, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		self.tooltip:AddLine(assetInfo.name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	self.tooltip:AddLine(" ");
	local descriptionColor = NORMAL_FONT_COLOR;
	if ( assetInfo.enabledCondition and not CheckCondition(assetInfo.enabledCondition) ) then
		descriptionColor = DISABLED_FONT_COLOR;
	end
	self.tooltip:AddLine(assetInfo.description, descriptionColor.r, descriptionColor.g, descriptionColor.b, true);
end

function WarfrontTooltipControllerMixin:AcquireProgressBar()
	return self.progressBarPool:Acquire();
end

function WarfrontTooltipControllerMixin:GetConditionText(conditions)
	if ( conditions ) then
		for i, conditionInfo in ipairs(conditions) do
			if ( not conditionInfo.condition or CheckCondition(conditionInfo.condition) == true ) then
				return conditionInfo.text;
			end
		end	
	end
	return nil;
end

function WarfrontTooltipControllerMixin:AddAssetsLabel(numAssetsAdded)
	if ( numAssetsAdded and numAssetsAdded > 0 ) then
		self.tooltip:AddLine(" ");
		return;
	end
	local text = self:GetConditionText(self.location.assetsLabel);
	if ( text ) then
		self.tooltip:AddLine(text);
	end
end

function WarfrontTooltipControllerMixin:AddStateLabel()
	local text = self:GetConditionText(self.location.stateLabel);
	if ( text ) then
		text = string.format(text, self.name);
		self.tooltip:AddLine(text, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	end
end

function WarfrontTooltipControllerMixin:HandleTooltip(tooltip, anchor, areaPoiID, name, description)
	if ( not self:InitializeTooltip(tooltip, anchor, areaPoiID, name, description) ) then
		return false;
	end

	local addedToTooltip = self:AddBuildRequirements();
	if ( not addedToTooltip and self.location.addBreakAfterTopSection ) then
		tooltip:AddLine(" ");
	end

	self:AddAssets(self.location.assets);
	self:AddStateLabel();

	tooltip:Show();
	return true;
end

function WarfrontTooltipControllerMixin:IsRelatedPOI(areaPoiID)
	return AREA_POI_LOOKUP[areaPoiID] and true;
end

WarfrontTooltipController = CreateFromMixins(WarfrontTooltipControllerMixin);

--==============================================================================================================================================
WarfrontTooltipCostMixin = { };

function WarfrontTooltipCostMixin:ClearCosts()
	self.costIndex = 0;
	for i, costFrame in ipairs(self.Costs) do
		costFrame:Hide();
	end
	self.totalCost = 0;
	self.totalProgress = 0;
	self.IndividualCostSeparator:SetText("");
end

function WarfrontTooltipCostMixin:AddCosts(costs, disabled)
	self:ClearCosts();
	if ( not costs ) then
		return false;
	end
	local orCosts = false;
	for i, costInfo in ipairs(costs) do
		local cost = C_Warfront.GetWorldStateValue(costInfo.costWSID);
		local progress = 0;
		if ( costInfo.progressWSID ) then
			progress = C_Warfront.GetWorldStateValue(costInfo.progressWSID);
		end
		local amount = max(cost - progress, 0);
		if ( amount > 0 ) then
			self:AddCost(amount, costInfo.costResourceType, disabled, costInfo.checkPersonal);
		end
		self.totalCost = self.totalCost + cost;
		self.totalProgress = self.totalProgress + progress;
		if ( costInfo.orCosts ) then
			orCosts = true;
		end
	end
	
	if ( orCosts ) then
		self.IndividualCostSeparator:SetText("or  ");
		if ( disabled ) then
			self.IndividualCostSeparator:SetTextColor(DISABLED_FONT_COLOR:GetRGB());		
		else
			self.IndividualCostSeparator:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		end
	end
	return true;
end

function WarfrontTooltipCostMixin:AddCost(amount, resourceType, disabled, checkPersonal)
	self.costIndex = self.costIndex + 1;
	local costFrame = self.Costs[self.costIndex];
	costFrame.Text:SetText(amount);
	
	if ( not disabled and checkPersonal ) then
		local resourceInfo = C_Warfront.GetResourceInfo(resourceType);
		if ( resourceInfo.quantity < amount ) then
			disabled = true;
		end
	end
	
	if ( disabled ) then
		costFrame.Text:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	else
		costFrame.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end
	costFrame.Icon:SetAtlas(RESOURCE_ATLAS[resourceType], true);
	costFrame:Show();
end

--==============================================================================================================================================
WarfrontTooltipAssetMixin = { };

function WarfrontTooltipAssetMixin:SetUp(assetInfo)
	if ( not assetInfo ) then
		return false;
	end
	self.assetInfo = assetInfo;

	if ( assetInfo.visibilityConditions and not CheckConditions(assetInfo.visibilityConditions) ) then
		return false;
	end

	self.disabled = not assetInfo.ignoreBuildingState and not WarfrontTooltipController:GetCanAccessAssets();

	local enabledFailureText;
	if ( assetInfo.enabledCondition and not CheckCondition(assetInfo.enabledCondition) ) then
		enabledFailureText = assetInfo.enabledCondition.failureText;
		self.disabled = true;
	end
	
	local requirement; 
	local location = WarfrontTooltipController:GetLocation();
	if ( location.checkRecruitCondition and assetInfo.recruitPCID ) then
		local canRecruit, failureText = C_Warfront.GetPlayerConditionInfo(assetInfo.recruitPCID);
		if ( not canRecruit ) then
			requirement = failureText;
		end
	end
	if ( requirement ) then
		self.Requirement:SetText(requirement);
		self.Requirement:Show();
		self:SetSize(237, 48);
		self.disabled = true;
		if ( WarfrontTooltipController:GetCanAccessAssets() ) then
			self.Requirement:SetTextColor(RED_FONT_COLOR:GetRGB());
		else
			self.Requirement:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		end
	else
		self.Requirement:Hide();
		self:SetSize(220, 36);
	end
	
	if ( not self.disabled and CheckCondition(assetInfo.enabledCondition) == false ) then
		self.disabled = true;
	end

	self.Name:SetText(assetInfo.name);
	if ( assetInfo.texture ) then
		self.Icon:SetTexture(assetInfo.texture);
	end

	if ( CheckCondition(assetInfo.builtCondition) == true ) then
		self.costsAdded = false;
		self.CostFrame:ClearCosts();
	else
		self.costsAdded = self.CostFrame:AddCosts(assetInfo.costs, self.disabled);
	end

	if ( assetInfo.description and not self.costsAdded ) then
		self.Description:SetText(enabledFailureText or assetInfo.description);
		self.Description:Show();
	else
		self.Description:Hide();
	end

	self.Icon:SetDesaturated(self.disabled);
	if ( self.disabled ) then
		self.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.Description:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	else
		self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.Description:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end

	return true;
end

function WarfrontTooltipAssetMixin:CheckAndAddProgressBar()
	local info = self.assetInfo.progressBar;
	if ( info and not self.disabled and self.costsAdded ) then
		local currentValue = C_Warfront.GetWorldStateValue(info.currentValueWSID);
		local maxValue = C_Warfront.GetWorldStateValue(info.maxValueWSID);
		local progressBar = WarfrontTooltipController:AcquireProgressBar();
		progressBar.Bar:SetMinMaxValues(0, maxValue);
		progressBar.Bar:SetValue(currentValue);
		GameTooltip_InsertFrame(WarfrontTooltipController:GetTooltip(), progressBar);
		progressBar.Bar.Label:SetText(FormatPercentage(currentValue / maxValue, true));
	end
	if ( self.assetInfo.makeProgressBarFromCosts and not self.disabled and self.costsAdded ) then
		local progressBar = WarfrontTooltipController:AcquireProgressBar();
		progressBar.Bar:SetMinMaxValues(0, self.CostFrame.totalCost);
		progressBar.Bar:SetValue(self.CostFrame.totalProgress);
		GameTooltip_InsertFrame(WarfrontTooltipController:GetTooltip(), progressBar);
		progressBar.Bar.Label:SetText(FormatPercentage(self.CostFrame.totalProgress / self.CostFrame.totalCost, true));		
	end
end

function WarfrontTooltipAssetMixin:CheckAndAddList()
	local list = self.assetInfo.list;
	if ( list ) then
		local tooltip = WarfrontTooltipController:GetTooltip();
		local color = NORMAL_FONT_COLOR;
		if ( self.disabled or self.costsAdded ) then
			color = DISABLED_FONT_COLOR;
		end
		for i, text in ipairs(list) do
			tooltip:AddLine("• "..text, color.r, color.g, color.b, true);
		end
	end
end

--===============================================================================================

local CHOICES = {
	[313] = {
		options = {
			[764] = { location = "BARRACKS", index = 1 },
			[1024] = { location = "BARRACKS", index = 2 },
		},
		percentageOnHeader = true,
	},
	[358] = {
		options = {
			[1021] = { location = "ALTAR", index = 1 },
			[1027] = { location = "ALTAR", index = 2 },	
		},
		percentageOnHeader = true,
	},
	[320] = {
		options = {
			[779] = { asset = "STRONGHOLD", index = 1 },
			[1028] = { asset = "STRONGHOLD", index = 2 },
		},
		percentageOnHeader = true,
	},
	[328] = {
		options = {
			[818] = { location = "WORKSHOP", index = 1 },
			[1026] = { location = "WORKSHOP", index = 2 },
		},
		percentageOnHeader = true,
	},	
	[329] = {
		options = {
			[820] = { location = "ARMORY", index = 1 },
			[1025] = { location = "ARMORY", index = 2 },
		},
		percentageOnHeader = true,
	},	
	[357] = {
		options = {
			[1017] = { asset = "FORTRESS", index = 1 },
			[1029] = { asset = "FORTRESS", index = 2 },
		},
		percentageOnHeader = true,
	},
	[332] = {
		options = {
			[828] = { asset = "WEAPON_UPGRADE_1", xOffset = 127 },
			[833] = { asset = "ARMOR_UPGRADE_1", xOffset = 127 },
			[1151] = { asset = "WEAPON_UPGRADE_2", xOffset = 127 },
			[1159] = { asset = "ARMOR_UPGRADE_2", xOffset = 127 },
			[1155] = { asset = "WEAPON_UPGRADE_3", xOffset = 127 },
			[1163] = { asset = "ARMOR_UPGRADE_3", xOffset = 127 },
		},
	},
};

WarfrontPlayerChoiceHookMixin = { };

local function WarfrontPlayerChoiceHook_Update(self, ...)
	WarfrontPlayerChoiceHook:Reset();
	WarfrontPlayerChoiceHook.oldUpdateFunc(self, ...);
	
	WarfrontPlayerChoiceHook.choice = CHOICES[self.choiceID];
	if not WarfrontPlayerChoiceHook.choice then
		WarfrontPlayerChoiceHook.Percentage:Hide();
		return;
	end

	for i, option in ipairs(self.Options) do
		if option:IsShown() then
			local currentValue, maxValue = WarfrontPlayerChoiceHook:GetValuesForOption(option.optID);
			if maxValue > 0 then
				WarfrontPlayerChoiceHook:AddProgressBar(option);
			end
		end
	end
end

function WarfrontPlayerChoiceHookMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED");
	self.progressBarPool = CreateFramePool("FRAME", self, "TooltipProgressBarTemplate");
end

function WarfrontPlayerChoiceHookMixin:OnEvent(event, ...)
	if event == "ADDON_LOADED" then
		local addon = ...;
		if addon == "Blizzard_WarboardUI" then
			self:SetParent(WarboardQuestChoiceFrame);
			self:SetPoint("LEFT", WarboardQuestChoiceFrame.QuestionText, "RIGHT", 20, 0);
			self:Show();
			self:UnregisterEvent("ADDON_LOADED");
			self.oldUpdateFunc = WarboardQuestChoiceFrame.Update;
			WarboardQuestChoiceFrame.Update = WarfrontPlayerChoiceHook_Update;
		end
	end
end

function WarfrontPlayerChoiceHookMixin:Reset()
	self.progressBarPool:ReleaseAll();
end

function WarfrontPlayerChoiceHookMixin:OnUpdate()
	self:UpdateProgressBars();
end

function WarfrontPlayerChoiceHookMixin:GetTargetFromOptionInfo(optionInfo)
	if optionInfo then
		if optionInfo.location then
			return LOCATIONS[optionInfo.location];
		elseif optionInfo.asset then
			return ASSETS[optionInfo.asset];
		end
	end
	return nil;
end

function WarfrontPlayerChoiceHookMixin:GetValuesForOption(optionID)
	local progressWSID, costWSID = self:GetWorldStates(self.choice.options[optionID]);
	return C_Warfront.GetWorldStateValue(progressWSID), C_Warfront.GetWorldStateValue(costWSID);
end

function WarfrontPlayerChoiceHookMixin:GetWorldStates(optionInfo)
	local target = self:GetTargetFromOptionInfo(optionInfo);
	if target then
		if optionInfo.index then
			local costInfo = target.costs[optionInfo.index];
			return costInfo.progressWSID, costInfo.costWSID;
		elseif target.progressBar then
			return target.progressBar.currentValueWSID, target.progressBar.maxValueWSID;
		end
	end
	return 0, 0;
end

function WarfrontPlayerChoiceHookMixin:GetTotalValues()
	local totalCurrentValue = 0;
	local totalMaxValue = 0;
	for optID, optionInfo in pairs(self.choice.options) do
		local progressWSID, costWSID = self:GetWorldStates(optionInfo);
		local currentValue = C_Warfront.GetWorldStateValue(progressWSID);
		local maxValue = C_Warfront.GetWorldStateValue(costWSID);
		totalCurrentValue = totalCurrentValue + currentValue;
		totalMaxValue = totalMaxValue + maxValue;
	end
	return totalCurrentValue, totalMaxValue;
end

local function ProgressBarOnMouseDown(self, button)
	if button == "RightButton" and IsShiftKeyDown() and IsControlKeyDown() then
		local optionInfo = WarfrontPlayerChoiceHook.choice.options[self:GetParent().optID];
		local progressWSID, costWSID = WarfrontPlayerChoiceHook:GetWorldStates(optionInfo);
		local targetValue = C_Warfront.GetWorldStateValue(costWSID) - 10;
		ConsoleExec("setworldstate "..progressWSID.." "..targetValue);
	end
end

function WarfrontPlayerChoiceHookMixin:AddProgressBar(option)
	local progressBar = self.progressBarPool:Acquire();
	progressBar:SetParent(option);
	local optionInfo = self.choice.options[option.optID];
	local xOffset = optionInfo.xOffset or 0;
	progressBar:SetPoint("TOP", option, xOffset, -20);
	progressBar:Show();
	progressBar:SetScript("OnMouseDown", ProgressBarOnMouseDown);
end

function WarfrontPlayerChoiceHookMixin:UpdateProgressBars()
	if not self.choice then
		return;
	end

	for progressBar in self.progressBarPool:EnumerateActive() do
		local currentValue, maxValue = self:GetValuesForOption(progressBar:GetParent().optID);
		progressBar.Bar:SetMinMaxValues(0, maxValue);
		progressBar.Bar:SetValue(currentValue);
		progressBar.Bar.Label:SetText(FormatPercentage(currentValue / maxValue, true));
		if currentValue == maxValue then
			progressBar:GetParent().OptionButton:SetEnabled(false);
		end
	end

	if self.choice.percentageOnHeader then
		local totalCurrent, totalMax = self:GetTotalValues();
		self.Percentage:SetText(FormatPercentage(totalCurrent / totalMax, true));
		self.Percentage:Show();
	else
		self.Percentage:Hide();
	end
end