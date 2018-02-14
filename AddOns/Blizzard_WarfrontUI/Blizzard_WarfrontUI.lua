local RESOURCE_ATLAS = {
	[Enum.WarfrontResourceType.Iron] = "Warfront-HUD-Iron",
	[Enum.WarfrontResourceType.Lumber] = "Warfront-HUD-Lumber",
	[Enum.WarfrontResourceType.Essence] = "Warfront-HUD-ArmorScraps",
	[Enum.WarfrontResourceType.Food] = "Warfront-HUD-Food",
};

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

WarfrontCommandBarMixin = { };

function WarfrontCommandBarMixin:OnLoad()
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup == "Horde" ) then
		self.Background:SetAtlas("Warfront-Horde-HUD", true);
	end

	self:RegisterEvent("WARFRONT_UPDATE");
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:Update();
end

function WarfrontCommandBarMixin:OnEvent(event)
	if ( event == "WARFRONT_UPDATE" or event == "UNIT_AURA" )  then
		self:Update();
	end
end

function WarfrontCommandBarMixin:OnShow()
	UIParent_UpdateTopFramePositions();
end

function WarfrontCommandBarMixin:OnHide()
	UIParent_UpdateTopFramePositions();
end

function WarfrontCommandBarMixin:Update()
	if ( C_Warfront.InWarfront() ) then
		self:Show();
		for i, resourceFrame in ipairs(self.Resources) do
			local resourceInfo = C_Warfront.GetResourceInfo(resourceFrame.resourceType);
			resourceFrame.Quantity:SetText(resourceInfo.quantity.."/"..resourceInfo.maxQuantity);
		end
	else
		self:Hide();
	end
end

local ASSETS = {
	["GRUNT"] = {
		name = "Grunts",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14999, checkPersonal = true },
		},
		-- 15000, 15001
		recruitPCID = 56388,
		texture = "Interface\\Icons\\achievement_character_orc_female",
		availability = { WSID = 14498, value = 2},
	},
	["WITCH_DOCTOR"] = {
		name = "Witch Doctors",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15003, checkPersonal = true },
		},		
		recruitPCID = 56390,
		texture = "Interface\\Icons\\inv_hand_1h_trollshaman_c_01",
		availability = { WSID = 14151, value = 2},
	},
	["SHAMAN"] = {
		name = "Shaman",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15002, checkPersonal = true },
		},
		recruitPCID = 56389,
		texture = "Interface\\Icons\\trade_archaeology_ancientorcshamanheaddress",
		availability = { WSID = 14151, value = 2},
	},
	["WOLF_RAIDER"] = {
		name = "Wolf Raiders",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15004, checkPersonal = true },
		},		
		recruitPCID = 56393,
		texture = "Interface\\Icons\\achievement_boss_korkrondarkshaman",
		availability = { WSID = 14293, value = 2 },
		unlockLabels = { 
			[1] = {
				availability = { WSID = 14293, value = 1 },
				text = "Barracks troop.",
			},
			[2] = {
				availability = { WSID = 14293, value = 2 },
				text = "Troop added to the Barracks.",
			},
		},
	},
	["DEMOLISHER"] = {
		name = "Demolishers",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15005, checkPersonal = true },
		},		
		recruitPCID = 56394,
		texture = "Interface\\Icons\\achievement_character_orc_female",
		availability = { WSID = 14511, value = 2},
	},
	["WAR_TRIKE"] = {
		name = "War Trike",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 15006, checkPersonal = true },
		},		
		recruitPCID = 56395,
		texture = "Interface\\Icons\\achievement_character_orc_female",
		availability = { WSID = 14511, value = 2},
	},
	["SAPPER"] = {
		name = "Sappers",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 15007, checkPersonal = true },
		},		
		recruitPCID = 56396,
		texture = "Interface\\Icons\\achievement_character_orc_female",
		availability = { WSID = 14511, value = 2},
	},
};

local LOCATIONS = {
	["BARRACKS"] = {
		name = "Barracks",
		description = "Primary troop production building.",
		buildPCID = 56400,
		costsLabel = "Requires:",
		costs = {
			[1] = { costResourceType = Enum.WarfrontResourceType.Iron, costWSID = 14500, progressWSID = 14499 },
			[2] = { costResourceType = Enum.WarfrontResourceType.Lumber, costWSID = 14593, progressWSID = 14590 },
		},
		assets = { "GRUNT", "SHAMAN", "WITCH_DOCTOR", "WOLF_RAIDER"},
		assetsLabel = "Train:",
		showProgressBar = true,
		availability = { WSID = 14498, value = 2},
	},
	["NEWSTEAD"] = {
		name = "Newstead",
		description = "Grants an additional unit at the Barracks.",
		assetsLabel = "Unlocks:",
		assets = { "WOLF_RAIDER" },
		showProgressBar = false,
		useUnlockLabels = true,
	},
};

local AREA_POI_LOOKUP = {
	[5581] = "BARRACKS",
	[5586] = "BARRACKS",
	[5542] = "NEWSTEAD",
	[5541] = "NEWSTEAD",
}

-- trinary
local function CheckAvailability(availabilityInfo)
	if ( availabilityInfo ) then
		local value = C_Warfront.GetWorldStateValue(availabilityInfo.WSID);
		return  value == availabilityInfo.value;
	end
	return nil;
end

--==============================================================================================================================================
WarfrontTooltipControllerMixin = { };

function WarfrontTooltipControllerMixin:InitializeTooltip(tooltip, anchor, areaPoiID, name, description)
	local locationTag = AREA_POI_LOOKUP[areaPoiID];
	if ( not locationTag ) then
		return false;
	end

	self.location = LOCATIONS[locationTag];
	self.tooltip = tooltip;
	if not ( self.assetPool ) then
		self.costFrame = CreateFrame("FRAME", nil, nil, "WarfrontTooltipCostTemplate");
		self.assetPool = CreateFramePool("FRAME", self.assetPool, "WarfrontTooltipAssetTemplate");
		self.progressBar = CreateFrame("FRAME", nil, nil, "TooltipProgressBarTemplate");
	else
		self.assetPool:ReleaseAll();
		self.costFrame:ClearCosts();
	end

	self.tooltip:SetOwner(anchor, "ANCHOR_BOTTOMRIGHT");
	self.tooltip:SetText(name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	self.tooltip:AddLine(description);
	
	return true;
end

function WarfrontTooltipControllerMixin:AddBuildRequirements()
	if ( CheckAvailability(self.location.availability) ) then
		return false;
	end

	local addedToTooltip = false;
	if ( self.location.buildPCID ) then
		local cannotBuild, buildErrorText = C_Warfront.GetPlayerConditionInfo(self.location.buildPCID);
		if ( cannotBuild ) then
			self.tooltip:AddLine(buildErrorText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			addedToTooltip = true;
		end
	end
	
	self.costFrame:AddCosts(self.location.costs);
	if ( self.costFrame.totalProgress < self.costFrame.totalCost ) then
		if ( self.location.showProgressBar and not cannotBuild ) then
			self.progressBar.Bar:SetMinMaxValues(0, self.costFrame.totalCost);
			self.progressBar.Bar:SetValue(self.costFrame.totalProgress);
			GameTooltip_InsertFrame(self.tooltip, self.progressBar);
			self.progressBar.Bar.Label:SetText(FormatPercentage(self.costFrame.totalProgress / self.costFrame.totalCost, true));
		else
			self.tooltip:AddLine(" ");
		end
		self.tooltip:AddLine(self.location.costsLabel);
		GameTooltip_InsertFrame(self.tooltip, self.costFrame);
		addedToTooltip = true;
	end
	return addedToTooltip;
end

function WarfrontTooltipControllerMixin:AddAssets()
	local added = 0;
	for i, assetTag in ipairs(self.location.assets) do
		local assetFrame = self.assetPool:Acquire();
		if ( assetFrame:SetUp(ASSETS[assetTag], self.location.useUnlockLabels) ) then
			if ( added == 0 ) then
				if ( self.location.assetsLabel ) then
					self.tooltip:AddLine(self.location.assetsLabel);
				end
			else
				self.tooltip:AddLine(" ");
			end
			GameTooltip_InsertFrame(self.tooltip, assetFrame);
			added = added + 1;
		end
	end
end

function WarfrontTooltipControllerMixin:HandleTooltip(tooltip, anchor, areaPoiID, name, description)
	if ( not self:InitializeTooltip(tooltip, anchor, areaPoiID, name, description) ) then
		return false;
	end

	local addedToTooltip = self:AddBuildRequirements();
	if ( not addedToTooltip ) then
		tooltip:AddLine(" ");
	end
	self:AddAssets();

	tooltip:Show();
	return true;
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
end

function WarfrontTooltipCostMixin:AddCosts(costs, disabled)
	self:ClearCosts();
	self.Label:Hide();
	if ( not costs ) then
		return;
	end
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
	end
end

function WarfrontTooltipCostMixin:UseUnlockLabel(unlockLabels)
	self:ClearCosts();
	local labelText;
	for i, unlockLabelInfo in ipairs(unlockLabels) do
		if ( not unlockLabelInfo.availability or CheckAvailability(unlockLabelInfo.availability) == true ) then
			labelText = unlockLabelInfo.text;
			break;
		end
	end	
	self.Label:SetText(labelText);
	self.Label:Show();
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

function WarfrontTooltipAssetMixin:SetUp(assetInfo, useUnlockLabels)
	if ( not assetInfo ) then
		return false;
	end

	local disabled = false;

	local requirement; 
	if ( assetInfo.recruitPCID ) then
		local isValid, failureText = C_Warfront.GetPlayerConditionInfo(assetInfo.recruitPCID);
		if ( not isValid ) then
			requirement = failureText;
		end
	end
	if ( requirement and not useUnlockLabels ) then
		self.Requirement:SetText(requirement);
		self.Requirement:Show();
		self:SetSize(237, 48);
		disabled = true;
	else
		self.Requirement:Hide();
		self:SetSize(220, 36);
	end
	
	if ( not disabled and CheckAvailability(assetInfo.availability) == false ) then
		disabled = true;
	end

	self.Name:SetText(assetInfo.name);
	if ( assetInfo.texture ) then
		self.Icon:SetTexture(assetInfo.texture);
	end
	
	if ( useUnlockLabels ) then
		self.CostFrame:UseUnlockLabel(assetInfo.unlockLabels);
	else
		self.CostFrame:AddCosts(assetInfo.costs, disabled);
	end

	self.Icon:SetDesaturated(disabled);
	if ( disabled ) then
		self.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	else
		self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end

	return true;
end