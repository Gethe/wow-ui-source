GARRISON_CURRENCY = 824;
GARRISON_NUM_BUILDING_SIZES = 3;
GARRISON_MAX_BUILDING_LEVEL = 3;
-- TODO get these values from code instead of hardcoding them once gameplay implements it
local CAN_UPGRADE_ATLAS = "Garr_LevelUpgradeArrow";
local LOCKED_UPGRADE_ATLAS= "Garr_LevelUpgradeLocked";
local BARRACKS_BUILDING_ID = 26;

local BUILDING_TABS = {};

local FactionData = {
	["Alliance"] = {
		townHallPlot = "GarrBuilding_TownHall_%d_A_Map",
		townHallInfo = "GarrBuilding_TownHall_%d_A_Info",
		emptyPlot = "GarrBuilding_EmptyPlot_A_%d",
		plotCircle = "Garr_Plot_Shadowmoon_A_%d",
		townHallUpgrade1Tooltip = GARRISON_TOWN_HALL_ALLIANCE_UPGRADE_TIER1_TOOLTIP,
		townHallUpgrade2Tooltip = GARRISON_TOWN_HALL_ALLIANCE_UPGRADE_TIER2_TOOLTIP,
		townHallName = GARRISON_TOWN_HALL_ALLIANCE,
	},
	["Horde"] = {
		townHallPlot = "GarrBuilding_TownHall_%d_H_Map",
		townHallInfo = "GarrBuilding_TownHall_%d_H_Info",
		emptyPlot = "GarrBuilding_EmptyPlot_H_%d",
		plotCircle = "Garr_Plot_Frostfire_H_%d",
		townHallUpgrade1Tooltip = GARRISON_TOWN_HALL_HORDE_UPGRADE_TIER1_TOOLTIP,
		townHallUpgrade2Tooltip = GARRISON_TOWN_HALL_HORDE_UPGRADE_TIER2_TOOLTIP,
		townHallName = GARRISON_TOWN_HALL_HORDE,
	}
}

PlotHitbox = {
	[1] = {
		width = 54,
		height = 42,
		bottomInset = 25,
	},
	[2] = {
		width = 58,
		height = 48,
		bottomInset = 25,
	},
	[3] = {
		width = 64,
		height = 62,
		bottomInset = 21,
	},
}

StaticPopupDialogs["GARRISON_CANCEL_UPGRADE_BUILDING"] = {
	text = GARRISON_CANCEL_UPGRADE_BUILDING,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		GarrisonBuildingFrameTimerCancel_OnConfirm(self.data);
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["GARRISON_CANCEL_BUILD_BUILDING"] = {
	text = GARRISON_CANCEL_BUILD_BUILDING,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		GarrisonBuildingFrameTimerCancel_OnConfirm(self.data);
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};

function GarrisonBuildingUI_ToggleFrame()
	if (not GarrisonBuildingFrame:IsShown()) then
		ShowUIPanel(GarrisonBuildingFrame);
	else
		HideUIPanel(GarrisonBuildingFrame);
	end
end

function BuildingSizeForTab(tabID)
	return GARRISON_NUM_BUILDING_SIZES - tabID + 1;
end

function GarrisonBuildingFrame_OnLoad(self)
	local list = GarrisonBuildingFrame.BuildingList;
	
	self.plots = {};
	self.level = 1;

	--set up tabs
	local tabInfo = C_Garrison.GetBuildingSizes();
	if (#tabInfo ~= GARRISON_NUM_BUILDING_SIZES) then
		return;
	end
	for i=1, GARRISON_NUM_BUILDING_SIZES do
		local tab = list["Tab"..i];
		local tabInfoIndex = BuildingSizeForTab(i); --put large tab first
		tab.categoryID = tabInfo[tabInfoIndex].id;
		BUILDING_TABS[tabInfo[tabInfoIndex].id] = tab;
		tab.Text:SetText(tabInfo[tabInfoIndex].name);
		
		tab.buildings = C_Garrison.GetBuildingsForSize(Enum.GarrisonType.Type_6_0_Garrison, tab.categoryID);
	end
	
	--get buildings owned
	local buildings = C_Garrison.GetBuildings(Enum.GarrisonType.Type_6_0_Garrison);
	--add instance IDs for owned buildings to the corresponding building buttons
	for i = 1, #buildings do
		local building = buildings[i];
		local tab = BUILDING_TABS[building.uiTab];
		if (tab) then
			for j = 1, #tab.buildings do
				if (tab.buildings[j].buildingID == building.buildingID) then
					tab.buildings[j].plotID = building.plotID;
				end
			end
		end
	end
	
	C_Garrison.RequestGarrisonUpgradeable(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower);
	GarrisonBuildingFrame_UpdateGarrisonInfo(self);
	GarrisonBuildingTab_Select(GarrisonBuildingFrame.BuildingList.Tab1);
	
	GarrisonBuildingFrame_UpdateCurrency();
	
	self.FollowerList:Initialize(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower, "GarrisonBuildingFollowerButtonTemplate");
	self.FollowerList:SetSortFuncs(GarrisonFollowerList_DefaultSort, GarrisonFollowerList_InitializeDefaultSort);

	GarrisonBuildingFrame.SPEC_CHANGE_CURRENCY, GarrisonBuildingFrame.SPEC_CHANGE_COST = C_Garrison.GetSpecChangeCost();
	
	self.TitleText:SetText(GARRISON_ARCHITECT);

	self:RegisterEvent("GARRISON_UPDATE");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GARRISON_BUILDING_UPDATE");
	self:RegisterEvent("GARRISON_BUILDING_PLACED");
	self:RegisterEvent("GARRISON_BUILDING_REMOVED");
	self:RegisterEvent("GARRISON_BUILDING_LIST_UPDATE");
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATED");
	self:RegisterEvent("GARRISON_UPGRADEABLE_RESULT");
	self:RegisterEvent("GARRISON_BUILDING_ERROR");
end

function GarrisonBuildingFrame_OnShow(self)
	if ( #GarrisonBuildingFrame.plots == 0 ) then
		GarrisonBuildingFrame_UpdateGarrisonInfo(self);
	end

	C_Garrison.RequestGarrisonUpgradeable(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower);
	GarrisonBuildingTab_Select(GarrisonBuildingFrame.BuildingList.Tab1);
	GarrisonBuildingList_Show();
	
	-- Update building state for owned buildings. This is only really needed to refresh the cooldown timers.
	local buildings = C_Garrison.GetBuildings(Enum.GarrisonType.Type_6_0_Garrison);
	for i = 1, #buildings do
		GarrisonPlot_UpdateBuilding(buildings[i].plotID);
	end
	
	-- check to show the help plate
	if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING) ) then
		local helpPlate = GarrisonBuilding_HelpPlate;
		if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
			HelpPlate_ShowTutorialPrompt( helpPlate, GarrisonBuildingFrame.MainHelpButton );
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true );
		end
		GarrisonBuildingList_SelectBuilding(BARRACKS_BUILDING_ID);
	else
		GarrisonTownHall_Select();
	end
	PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_OPEN);
end

function GarrisonBuildingFrame_OnHide(self)
	C_Garrison.CloseArchitect();
	HelpPlate_Hide();
	GarrisonBuildingPlacer_Clear();
	PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_CLOSE);
end

function GarrisonBuildingFrame_OnEvent(self, event, ...)
	if (event == "GARRISON_UPDATE") then
		GarrisonBuildingFrame_UpdateGarrisonInfo(self);
	elseif (event == "CURRENCY_DISPLAY_UPDATE") then
		GarrisonBuildingFrame_UpdateCurrency();
	elseif (event == "GARRISON_BUILDING_UPDATE") then
		local buildingID, plotID = ...;
		local buildingInfo = GarrisonBuildingFrame.selectedBuilding;
		if (buildingInfo and buildingID == buildingInfo.buildingID) then
			if (buildingInfo.plotID) then
				GarrisonBuildingInfoBox_ShowBuilding(buildingInfo.plotID, true);
				if (not plotID) then
					plotID = buildingInfo.plotID;
				end
			else
				GarrisonBuildingInfoBox_ShowBuilding(buildingInfo.buildingID, false);
			end
		end
		local Plot = self.plots[plotID];
		if (Plot) then
			GarrisonPlot_UpdateBuilding(plotID);
		end
	elseif (event == "GARRISON_BUILDING_PLACED") then
		GarrisonBuildingFrame_UpdateGarrisonInfo(self);
		local plotID, newPlacement = ...;
		local id, name, textureKit, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade, isPrebuilt = C_Garrison.GetOwnedBuildingInfoAbbrev(plotID);
		if (id) then
			local Plot = self.plots[plotID];
			if (not Plot) then
				return;
			end
			if (rank > 1) then
				Plot.BuildGlow:SetAtlas("Garr_UpgradeFX-Glow", true);
			else
				Plot.BuildGlow:SetAtlas("Garr_BuildFX-Glow", true);
			end
			if (newPlacement) then
				if (rank > 1) then
					PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_UPGRADE_START);
				else
					PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_PLACEMENT);
				end
				Plot.BuildingCreateFlareAnim:Play();
			end
			GarrisonPlot_SetBuilding(Plot, id, name, textureKit, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade, isPrebuilt);
			local buildingInfo = GarrisonBuildingFrame.selectedBuilding;
			if (buildingInfo and id == buildingInfo.buildingID) then
				GarrisonBuildingInfoBox_ShowBuilding(plotID, true);
			elseif (rank > 1) then
				GarrisonBuildingList_SelectBuilding(id);
			end
		end
	elseif (event == "GARRISON_BUILDING_REMOVED") then
		local plotID, buildingID = ...;
		local Plot = self.plots[plotID];
		if (not Plot) then
			return;
		end
		GarrisonPlot_ClearBuilding(Plot);
		local buildingInfo = GarrisonBuildingFrame.selectedBuilding;
		if (buildingInfo and buildingID == buildingInfo.buildingID) then
			GarrisonBuildingInfoBox_ShowBuilding(buildingID, false);
		end
	elseif (event == "GARRISON_BUILDING_LIST_UPDATE") then
		local categoryID = ...;
		local buildingID = nil;
		local list = GarrisonBuildingFrame.BuildingList
		for i=1, GARRISON_NUM_BUILDING_SIZES do
			local tab = list["Tab"..i];
			if (tab.categoryID == categoryID) then
				tab.buildings = C_Garrison.GetBuildingsForSize(Enum.GarrisonType.Type_6_0_Garrison, tab.categoryID);
				if (self.selectedTab == tab) then
					if (self.selectedBuilding) then
						buildingID = self.selectedBuilding.buildingID;
					end
					GarrisonBuildingList_SelectTab(tab);
					GarrisonBuildingList_SelectBuilding(buildingID);
				end
				return;
			end
		end 
	elseif (event == "GARRISON_BUILDING_ACTIVATED") then
		local plotID, buildingID = ...;
		local Plot = self.plots[plotID];
		GarrisonPlot_UpdateBuilding(plotID);
		if (Plot) then
			Plot.Timer:Hide();
			Plot.BuildingGlowPulseAnim:Stop();
		end
		local buildingInfo = GarrisonBuildingFrame.selectedBuilding;
		if (buildingInfo and buildingID == buildingInfo.buildingID) then
			GarrisonBuildingInfoBox_ShowBuilding(plotID, true);
		end
	elseif (event == "GARRISON_UPGRADEABLE_RESULT") then
		GarrisonBuildingFrame_UpdateUpgradeButton();
	elseif (event == "GARRISON_BUILDING_ERROR") then
		PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_PLACEMENT_ERROR);
	end
end

function GarrisonBuildingFrame_UpdatePlots()
	local plots = C_Garrison.GetPlots(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower);
	local mapWidth = GarrisonBuildingFrame.MapFrame:GetWidth();
	local mapHeight = GarrisonBuildingFrame.MapFrame:GetHeight();
	for i = 1, #plots do
		local plot = plots[i];
		if (not GarrisonBuildingFrame.MapFrame.Plots[i]) then
			GarrisonBuildingFrame.MapFrame.Plots[i] = CreateFrame("BUTTON", nil, GarrisonBuildingFrame.MapFrame, "GarrisonPlotTemplate");
		end
		local Plot = GarrisonBuildingFrame.MapFrame.Plots[i];
		local hitbox = PlotHitbox[plot.size];
		local leftRightInset = (Plot:GetWidth() - hitbox.width) / 2;
		local topInset = Plot:GetHeight() - hitbox.height - hitbox.bottomInset;
		Plot:SetHitRectInsets(leftRightInset, leftRightInset, topInset, hitbox.bottomInset);

		Plot.plotID = plot.id;
		Plot.size = plot.size;
		Plot:SetPoint("CENTER", GarrisonBuildingFrame.MapFrame, "BOTTOMLEFT", plot.x * mapWidth, plot.y * mapHeight)
		local factionGroup = UnitFactionGroup("player");
		local plotCircleAtlas = format(FactionData[factionGroup].plotCircle, plot.size);
		Plot.Plot:SetAtlas(plotCircleAtlas, true);
		Plot.PlotHover:SetAtlas(plotCircleAtlas, true);
		Plot.PlotHighlight:SetAtlas("Garr_Plot_Glow_"..plot.size, true);
		Plot.Lock:Hide();
		Plot.locked = false;
		local id, name, textureKit, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade, isPrebuilt = C_Garrison.GetOwnedBuildingInfoAbbrev(plot.id);
		Plot.isPrebuilt = isPrebuilt;
		if (id) then
			GarrisonPlot_SetBuilding(Plot, id, name, textureKit, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade, isPrebuilt);
		elseif (plot.buildingID) then
			id, name = C_Garrison.GetBuildingInfo(plot.buildingID);
			GarrisonPlot_SetBuilding(Plot, plot.buildingID, name, plot.building, plot.icon);
			Plot.locked = true;
			Plot.Lock:Show();
			-- Locked buildings are prebuilt
			Plot.isPrebuilt = true;
		else
			GarrisonPlot_ClearBuilding(Plot);
		end
		Plot:Show();
		GarrisonBuildingFrame.plots[plot.id] = Plot;
	end
end

function GarrisonBuildingFrame_UpdateBuildingList()
	for id, tab in pairs(BUILDING_TABS) do
		tab.buildings = C_Garrison.GetBuildingsForSize(Enum.GarrisonType.Type_6_0_Garrison, id);
	end
	if (GarrisonBuildingFrame.selectedTab) then
		GarrisonBuildingTab_Select(GarrisonBuildingFrame.selectedTab);
	end
end

function GarrisonBuildingFrame_UpdateUpgradeButton()
	if (C_Garrison.CanUpgradeGarrison()) then
		GarrisonBuildingFrame.MapFrame.TownHall.UpgradeArrow:Show();
		GarrisonBuildingFrame.MapFrame.TownHall.BuildingGlowPulseAnim:Play();
		
		GarrisonBuildingFrame.TownHallBox.UpgradeButton:Enable();
		GarrisonBuildingFrame.TownHallBox.UpgradeGlow:Show();
		GarrisonBuildingFrame.TownHallBox.UpgradeAnim:Play();
	else
		GarrisonBuildingFrame.MapFrame.TownHall.UpgradeArrow:Hide();
		GarrisonBuildingFrame.MapFrame.TownHall.BuildingGlowPulseAnim:Stop();
		
		GarrisonBuildingFrame.TownHallBox.UpgradeAnim:Stop();
		GarrisonBuildingFrame.TownHallBox.UpgradeGlow:Hide();
		if (GarrisonBuildingFrame.level == GARRISON_MAX_BUILDING_LEVEL) then
			GarrisonBuildingFrame.TownHallBox.UpgradeButton:Hide();
		else
			GarrisonBuildingFrame.TownHallBox.UpgradeButton:Disable();
		end
	end
end

function GarrisonBuildingFrame_UpdateGarrisonInfo(self)
	local level, mapTextureKit, townHallX, townHallY = C_Garrison.GetGarrisonInfo(Enum.GarrisonType.Type_6_0_Garrison);
	if ( not level or not townHallX or not townHallY ) then
		return;
	end
	self.level = level;
	self.MapFrame.Map:SetAtlas(mapTextureKit);
	self.MapFrame.TownHall.Level:SetText(level);
	self.MapFrame.TownHall.TownHallName:SetText(GarrisonTownHall_GetName());
	GarrisonTownHall_UpdateNameBanner(self.MapFrame.TownHall);

	local factionGroup = UnitFactionGroup("player");
	local townHallPlot = format(FactionData[factionGroup].townHallPlot, level);
	self.MapFrame.TownHall.Building:SetAtlas(townHallPlot, true);
	self.MapFrame.TownHall.BuildingHighlight:SetAtlas(townHallPlot, true);
	local mapWidth = self.MapFrame:GetWidth();
	local mapHeight = self.MapFrame:GetHeight();
	self.MapFrame.TownHall:ClearAllPoints();
	self.MapFrame.TownHall:SetPoint("CENTER", self.MapFrame, "BOTTOMLEFT", townHallX * mapWidth, townHallY * mapHeight);
	GarrisonBuildingFrame_UpdatePlots();
	GarrisonBuildingFrame_UpdateBuildingList();
end

function GarrisonBuildingFrame_UpdateCurrency()
	local materialsText = GarrisonBuildingFrame.BuildingList.MaterialFrame.Materials;
	
	local amount = C_CurrencyInfo.GetCurrencyInfo(GARRISON_CURRENCY).quantity;
	amount = BreakUpLargeNumbers(amount);
	materialsText:SetText(amount);
end

function GarrisonTownHall_GetName()
	local factionGroup = UnitFactionGroup("player");
	return FactionData[factionGroup].townHallName;
end

function GarrisonTownHall_UpdateNameBanner(self)
	if ( self.BannerMid:GetWidth() < (self.TownHallName:GetWidth() + 18) ) then
		self.BannerMid:SetWidth(self.TownHallName:GetWidth() + 18);
	end
end

function GarrisonTownHall_OnEnter(self)
	self.BuildingHighlight:Show();
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
	GameTooltip:SetText(GarrisonTownHall_GetName());
	GameTooltip:Show();
end

function GarrisonTownHall_OnLeave(self)
	self.BuildingHighlight:Hide();
	GameTooltip_Hide();
end

function GarrisonTownHall_OnClick(self)
	PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_SELECT);
	GarrisonTownHall_Select();
end

function GarrisonTownHall_Select()
	local self = GarrisonBuildingFrame.MapFrame.TownHall;
	GarrisonBuildingFrame.InfoBox:Hide();
	GarrisonBuildingFrame_ClearPlotHighlights();
	GarrisonBuildingList_Show();
	if (GarrisonBuildingFrame.selectedBuilding and GarrisonBuildingFrame.selectedBuilding.button) then
		GarrisonBuildingFrame.selectedBuilding.button.SelectedBG:Hide();
		GarrisonBuildingFrame.selectedBuilding = nil;
	end
		
	local infoBox = GarrisonBuildingFrame.TownHallBox;
	infoBox:Show();
	infoBox.Title:SetText(GarrisonTownHall_GetName());
	infoBox.RankBadge:SetAtlas("Garr_LevelBadge_"..GarrisonBuildingFrame.level, true);
	local factionGroup = UnitFactionGroup("player");
	infoBox.Building:SetAtlas(format(FactionData[factionGroup].townHallInfo, GarrisonBuildingFrame.level), true);
	local costMaterial, costGold = C_Garrison.GetGarrisonUpgradeCost(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower);
	if (costMaterial and costMaterial > 0) then
		infoBox.UpgradeCostBar.CostAmountMaterial:SetText(Garrison_GetMaterialCostString(costMaterial));
		infoBox.UpgradeCostBar:Show();
		if (costGold and costGold > 0) then
			infoBox.UpgradeCostBar.CostAmountGold:SetText(Garrison_GetGoldCostString(costGold));
			infoBox.UpgradeCostBar.CostAmountGold:Show();
		else
			infoBox.UpgradeCostBar.CostAmountGold:Hide();
		end
	else
		infoBox.UpgradeCostBar:Hide();
	end
	
	GarrisonBuildingFrame_UpdateUpgradeButton();
end

function GarrisonTownHall_StartUpgrade(self)
	local costMaterial, costGold = C_Garrison.GetGarrisonUpgradeCost(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower);
	
	-- Error if not enough money
	local currencyAmount = C_CurrencyInfo.GetCurrencyInfo(GARRISON_CURRENCY).quantity;
	if (currencyAmount < costMaterial) then
		UIErrorsFrame:AddMessage(ERR_GARRISON_NOT_ENOUGH_CURRENCY, 1.0, 0.1, 0.1, 1.0);
		PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_PLACEMENT_ERROR);
		return;
	elseif (GetMoney() < costGold * COPPER_PER_GOLD) then
		UIErrorsFrame:AddMessage(ERR_GARRISON_NOT_ENOUGH_GOLD, 1.0, 0.1, 0.1, 1.0);
		PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_PLACEMENT_ERROR);
		return;
	end
	
	local confirmation = GarrisonBuildingFrame.Confirmation;
	GarrisonBuildingFrameConfirmation_SetContext("upgradegarrison");
	
	confirmation.MaterialCost:SetText(Garrison_GetMaterialCostString(costMaterial));
	
	if ( costGold > 0 ) then
		confirmation.CostLabel:SetPoint("TOPLEFT", 81, -37);
		confirmation.GoldCost:SetText(Garrison_GetGoldCostString(costGold));
		confirmation.GoldCost:Show();
	else
		confirmation.CostLabel:SetPoint("TOPLEFT", 81, -44);
		confirmation.GoldCost:Hide();
	end
	
	confirmation:ClearAllPoints();
	confirmation:SetPoint("BOTTOM", GarrisonBuildingFrame.MapFrame.TownHall, "TOP", 0, -40);
	confirmation:Show();
	PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_UPGRADE);
end

function GarrisonTownHallUpgradeButton_OnEnter(self)
	if (self:IsEnabled()) then
		return;
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 15, 15);
	local factionGroup = UnitFactionGroup("player");
	if (GarrisonBuildingFrame.level == 1) then
		GameTooltip:SetText(format(FactionData[factionGroup].townHallUpgrade1Tooltip, RED_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE), nil, nil, nil, nil, true);
	elseif (GarrisonBuildingFrame.level == 2) then
		GameTooltip:SetText(format(FactionData[factionGroup].townHallUpgrade2Tooltip, RED_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE), nil, nil, nil, nil, true);
	else
		return;
	end
	GameTooltip:Show();
end

function GarrisonTownHallBoxMouseOver_GetColor(textLevel, garrisonLevel)
	if (textLevel > garrisonLevel) then
		return GRAY_FONT_COLOR;
	else
		return HIGHLIGHT_FONT_COLOR;
	end
end

function GarrisonTownHallBoxMouseOver_OnEnter(self, button)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 15, 15);
	GameTooltip:SetText(GarrisonTownHall_GetName(), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	local garrisonLevel = C_Garrison.GetGarrisonInfo(Enum.GarrisonType.Type_6_0_Garrison);
	local color;
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(format(GARRISON_CURRENT_LEVEL, 1), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	color = GarrisonTownHallBoxMouseOver_GetColor(1, garrisonLevel);
	GameTooltip:AddLine(GARRISON_TOWN_HALL_LEVEL1_DESCRIPTION, color.r, color.g, color.b, true);
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(format(GARRISON_CURRENT_LEVEL, 2), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	color = GarrisonTownHallBoxMouseOver_GetColor(2, garrisonLevel);
	GameTooltip:AddLine(GARRISON_TOWN_HALL_LEVEL2_DESCRIPTION, color.r, color.g, color.b, true);
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(format(GARRISON_CURRENT_LEVEL, 3), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	color = GarrisonTownHallBoxMouseOver_GetColor(3, garrisonLevel);
	GameTooltip:AddLine(GARRISON_TOWN_HALL_LEVEL3_DESCRIPTION, color.r, color.g, color.b, true);
	
	GameTooltip:Show();
end

-----------------------------------------------------------------------
-- Info Box stuff
-----------------------------------------------------------------------

function GarrisonBuildingInfoBox_ShowEmptyPlot(plotSize)
	GarrisonBuildingFrame.TownHallBox:Hide();
	local infoBox = GarrisonBuildingFrame.InfoBox;
	infoBox:Show()
	
	infoBox.RankBadge:Hide();
	infoBox.RankLabel:Hide();
	infoBox.UpgradeBadge:Hide();
	infoBox.UpgradeAnim:Stop();
	infoBox.UpgradeGlow:Hide();
	infoBox.PlansNeeded:Hide();
	infoBox.Timer:Hide();
	infoBox.TimeLeft:Hide();
	infoBox.SpecFrame:Hide();
	infoBox.AddFollowerButton:Hide();
	infoBox.FollowerPortrait:Hide();
	infoBox.UpgradeCostBar:Hide();

	local factionGroup = UnitFactionGroup("player");
	infoBox.Building:SetAtlas(format(FactionData[factionGroup].emptyPlot, plotSize), true);
	infoBox.InfoBar:Hide();
	infoBox.InfoText:Hide();
	infoBox.Lock:Hide();
	infoBox.Building:SetDesaturated(false);
	if (plotSize == 1) then
		infoBox.Title:SetText(GARRISON_EMPTY_PLOT_SMALL);
	elseif (plotSize == 2) then
		infoBox.Title:SetText(GARRISON_EMPTY_PLOT_MEDIUM);
	else
		infoBox.Title:SetText(GARRISON_EMPTY_PLOT_LARGE);
	end
	infoBox.Description:SetText(GARRISON_EMPTY_PLOT_EXPLANATION);
end

function GarrisonBuildingInfoBox_ShowBuilding(ID, owned, showLock)
	GarrisonBuildingFrame.TownHallBox:Hide();
	if (not ID or ID == 0) then
		return;
	end
	local infoBox = GarrisonBuildingFrame.InfoBox;
	if ( infoBox.ID ~= ID ) then
		if ( GarrisonBuildingFrame.FollowerList:IsShown() ) then
			GarrisonBuildingList_Show();
		end
	end
	infoBox.ID = ID;
	infoBox:Show()
	local id, name, textureKit, icon, description, rank, currencyID, currencyQty, goldQty, buildTime, needsPlan, isPrebuilt, possSpecs, upgrades, canUpgrade, isMaxLevel, knownSpecs, currSpec, specCooldown, isBuilding, startTime, buildDuration, timeLeftStr, canActivate, hasFollowerSlot;
	if (owned) then
		id, name, textureKit, icon, description, rank, currencyID, currencyQty, goldQty, buildTime, needsPlan, isPrebuilt, possSpecs, upgrades, canUpgrade, isMaxLevel, hasFollowerSlot, knownSpecs, currSpec, specCooldown, isBuilding, startTime, buildDuration, timeLeftStr, canActivate = C_Garrison.GetOwnedBuildingInfo(ID);
	else
		id, name, textureKit, icon, description, rank, currencyID, currencyQty, goldQty, buildTime, needsPlan, isPrebuilt, possSpecs, upgrades, canUpgrade, isMaxLevel, hasFollowerSlot = C_Garrison.GetBuildingInfo(ID);
	end
	-- currencyID, currencyQty, and goldQty from above are the cost of the building's current level, which we do not display. What we do display is the cost of the next level.
	if ( id and owned ) then
		local _;
		_, _, _, _, _, currencyID, currencyQty, goldQty = C_Garrison.GetBuildingUpgradeInfo(id);
	end
	infoBox.canActivate = canActivate;
	if (name == nil) then
		return;
	end
	infoBox.Title:SetText(name);
	infoBox.RankBadge:SetAtlas("Garr_LevelBadge_"..rank);
	infoBox.RankBadge:Show();
	infoBox.RankLabel:Show();
	
	-- We need to set the follower portrait data before the upgrade animation plays
	-- so that the animation does not change the portrait alpha values
	GarrisonBuildingInfoBox_ShowFollowerPortrait(owned, hasFollowerSlot, infoBox, isBuilding, canActivate, ID);
	
	--upgrade stuff
	infoBox.UpgradeButton:Hide();
	infoBox.UpgradeAnim:Stop();
	infoBox.UpgradeGlow:Hide();
	infoBox.UpgradeBadge:Hide();
	
	-- Show the upgrade button if we own it, construction is complete, and we are not at max level
	if (owned and not isBuilding and not canActivate and rank < GARRISON_MAX_BUILDING_LEVEL) then
		infoBox.UpgradeButton:Show();
		infoBox.UpgradeBadge:Show();
		if (canUpgrade and rank < GarrisonBuildingFrame.level) then
			infoBox.UpgradeButton.upgradePlotID = ID;
			infoBox.UpgradeButton:Enable();
			infoBox.UpgradeBadge:SetAtlas(CAN_UPGRADE_ATLAS, true);
			infoBox.UpgradeButton.tooltip = nil;
			infoBox.UpgradeGlow:Show();
			infoBox.UpgradeAnim:Play();
		else
			infoBox.UpgradeButton:Disable();
			infoBox.UpgradeBadge:SetAtlas(LOCKED_UPGRADE_ATLAS, true);
			local _, _, _, _, _, upgradeNeedsPlan = C_Garrison.GetBuildingTooltip(upgrades[rank+1]);
			if (upgradeNeedsPlan) then
				infoBox.UpgradeButton.tooltip = GARRISON_UPGRADE_NEED_PLAN;
			else
				infoBox.UpgradeButton.tooltip = GARRISON_UPGRADE_ERROR;
			end
		end
	end
	
	--general building info
	if (description and description ~= "") then
		infoBox.Description:SetText(description);
	end
	if (textureKit) then
		infoBox.Building:SetAtlas(textureKit.."_Info", true);
	end
	infoBox.InfoBar:Hide();
	infoBox.InfoText:Hide();
	infoBox.TimeLeft:Hide();
	
	--building and activation
	if (isBuilding or canActivate) then
		infoBox.InfoBar:Show();
		infoBox.InfoText:Show();
		infoBox.Timer:Show();
		if (rank > 1) then
			if (canActivate) then 
				infoBox.InfoText:SetText(GARRISON_UPGRADE_COMPLETE);
			else
				infoBox.InfoText:SetText(GARRISON_UPGRADE_IN_PROGRESS);
			end
			infoBox.Timer.Icon:SetAtlas("Garr_UpgradeIcon", true);
			infoBox.Timer.CompleteRing:SetAtlas("Garr_UpgradeTimerFill", true);
			infoBox.Timer.Glow:SetAtlas("Garr_UpgradeTimerGlow", true);
			infoBox.Timer.BG:SetAtlas("Garr_UpgradeTimerBG", true);
			infoBox.Timer.Cooldown:SetSwipeTexture("Interface\\Garrison\\Garr_TimerFill-Upgrade");
		else
			if (canActivate) then 
				infoBox.InfoText:SetText(GARRISON_BUILDING_COMPLETE);
			else
				infoBox.InfoText:SetText(GARRISON_BUILDING_IN_PROGRESS);
			end
			infoBox.Timer.Icon:SetAtlas("Garr_BuildIcon", true);
			infoBox.Timer.CompleteRing:SetAtlas("Garr_BuildingTimerFill", true);
			infoBox.Timer.Glow:SetAtlas("Garr_BuildingTimerGlow", true);
			infoBox.Timer.BG:SetAtlas("Garr_BuildingTimerBG", true);
			infoBox.Timer.Cooldown:SetSwipeTexture("Interface\\Garrison\\Garr_TimerFill");
		end
		if (canActivate) then
			infoBox.Timer.CompleteRing:Show();
			infoBox.Timer.Glow:Show();
			infoBox.Timer.Cooldown:SetCooldownDuration(0);
			infoBox.Timer.Cancel:Hide();
			infoBox.Timer.CompleteMouseOver:Show();
		else
			infoBox:SetScript("OnUpdate", GarrisonBuildingInfoBox_OnUpdate);
			infoBox.TimeLeft:Show();
			infoBox.TimeLeft:SetText(timeLeftStr);
			infoBox.Timer.CompleteRing:Hide();
			infoBox.Timer.Glow:Hide();
			infoBox.Timer.Cooldown:SetCooldownUNIX(startTime, buildDuration);
			infoBox.Timer.Cancel:Show();
			infoBox.Timer.CompleteMouseOver:Hide();
		end
	else
		infoBox.Timer:Hide();
	end
	
	--build restrictions
	infoBox.Lock:Hide();
	infoBox.PlansNeeded:Hide();
	if (showLock) then
		infoBox.Lock:Show();
		infoBox.InfoBar:Show();
		infoBox.InfoText:Show();
		infoBox.InfoText:SetText(GARRISON_BUILDING_LOCKED);
	elseif (needsPlan) then
		infoBox.PlansNeeded:Show();
		infoBox.Building:SetDesaturated(true);
	else
		infoBox.Building:SetDesaturated(false);
	end
	
	if (not isBuilding and not canActivate and currencyID and not showLock) then
		infoBox.UpgradeCostBar.CostAmountMaterial:SetText(Garrison_GetMaterialCostString(currencyQty));
		infoBox.UpgradeCostBar.CostAmountGold:SetText(Garrison_GetGoldCostString(goldQty));
		infoBox.UpgradeCostBar.TimeAmount:SetText(buildTime);
		infoBox.UpgradeCostBar:Show();
	else
		infoBox.UpgradeCostBar:Hide();
	end
	
	-- hide old specs
	for i=1, #infoBox.SpecFrame.Specs do
		infoBox.SpecFrame.Specs[i]:Hide();
	end
	
	-- show specs
	if (possSpecs and #possSpecs > 0) then
		infoBox.SpecFrame:Show();
		local spec, prevSpec;
		local width = 14; --7 pix of padding on each side
		for i=1, #possSpecs do
			if (not infoBox.SpecFrame.Specs[i]) then
				infoBox.SpecFrame.Specs[i] = CreateFrame("BUTTON", nil, infoBox.SpecFrame, "GarrisonBuildingSpecTemplate");
				infoBox.SpecFrame.Specs[i]:SetPoint("LEFT", prevSpec, "RIGHT", 0, 0);
			end
			spec = infoBox.SpecFrame.Specs[i]
			local name, tooltip, iconID = C_Garrison.GetBuildingSpecInfo(possSpecs[i]);
			spec.id = possSpecs[i];
			spec.name = name;
			spec.tooltip = tooltip
			spec.Icon:SetTexture(iconID);
			spec:Show();
			spec:Disable();
			spec.Icon:SetDesaturated(true);
			if (knownSpecs) then
				for j=1, #knownSpecs do
					if (knownSpecs[i] == possSpecs[i]) then
						spec.Icon:SetDesaturated(false);
						if (not specCooldown) then
							spec:Enable();
						end
						break;
					end
				end
			end
			if (spec.Icon:IsDesaturated()) then
				spec.tooltip = spec.tooltip.."\n\n"..RED_FONT_COLOR_CODE..GARRISON_SPECIALIZATION_UNKNOWN..FONT_COLOR_CODE_CLOSE
			elseif (specCooldown) then
				spec.tooltip = spec.tooltip.."\n\n"..RED_FONT_COLOR_CODE..string.format(GARRISON_SPECIALIZATION_COOLDOWN, specCooldown)..FONT_COLOR_CODE_CLOSE
			end
			if (currSpec == possSpecs[i]) then
				spec.Selected:Show();
			else
				spec.Selected:Hide();
			end
			width = width + spec:GetWidth();
			prevSpec = infoBox.SpecFrame.Specs[i];
		end
		infoBox.SpecFrame:SetWidth(width);
	else 
		infoBox.SpecFrame:Hide();
	end
end

function GarrisonBuildingFrameComplete_OnEnter(self)
	if (GarrisonBuildingFrame.InfoBox.canActivate) then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -5, 54);
		GameTooltip:SetText(GARRISON_FINALIZE_BUILDING_TOOLTIP, nil, nil, nil, nil, true);
	end
end

function GarrisonBuildingInfoBox_ShowFollowerPortrait(owned, hasFollowerSlot, infoBox, isBuilding, canActivate, ID)
	if (not hasFollowerSlot) then
		infoBox.AddFollowerButton:Hide();
		infoBox.FollowerPortrait:Hide();
		return;
	end
	
	infoBox.AddFollowerButton.greyedOut = (isBuilding or canActivate or not owned);
	
	local followerName, level, quality, followerID, garrFollowerID, status, portraitIconID = C_Garrison.GetFollowerInfoForBuilding(ID);
	if (followerName) then
		infoBox.AddFollowerButton:Hide();
		local button = infoBox.FollowerPortrait;
		button:SetLevel(level);
		button:SetQuality(quality);
		button:SetPortraitIcon(portraitIconID);
		button.FollowerName:SetText(followerName);
		button.FollowerStatus:SetText(status);
		button.garrFollowerID = garrFollowerID;
		button.followerID = followerID;
		button:Show();
	else
		infoBox.FollowerPortrait:Hide();
		infoBox.AddFollowerButton:Show();
		if (infoBox.AddFollowerButton.greyedOut) then
			infoBox.AddFollowerButton.Plus:Hide();
			infoBox.AddFollowerButton.EmptyPortrait:SetAlpha(0.5);
			if (owned) then
				infoBox.AddFollowerButton.AddFollowerText:SetText(GARRISON_BUILDING_SELECT_FOLLOWER_DEACTIVATED_TEXT);
			else
				infoBox.AddFollowerButton.AddFollowerText:SetText(GARRISON_BUILDING_SELECT_FOLLOWER_NOT_OWNED_TEXT);
			end
		else
			infoBox.AddFollowerButton.Plus:Show();
			infoBox.AddFollowerButton.EmptyPortrait:SetAlpha(1.0);
			infoBox.AddFollowerButton.AddFollowerText:SetText(GARRISON_BUILDING_SELECT_FOLLOWER_ACTIVATED_TEXT);
		end
	end
end

function GarrisonFollowerPortrait_OnEnter(self, button)
	GarrisonFollowerTooltipShow(self, self.followerID, self.garrFollowerID);
end

function GarrisonFollowerPortrait_OnLeave(self, button)
	GarrisonFollowerTooltip:Hide();
end

function GarrisonFollowerTooltipShow(self, followerID, garrFollowerID)
	if ( not followerID ) then
		return;
	end
	GarrisonFollowerTooltip:ClearAllPoints();
	GarrisonFollowerTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT");
	GarrisonFollowerTooltip_Show(garrFollowerID, 
		true,
		C_Garrison.GetFollowerQuality(followerID),
		C_Garrison.GetFollowerLevel(followerID), 
		C_Garrison.GetFollowerXP(followerID),
		C_Garrison.GetFollowerLevelXP(followerID),
		C_Garrison.GetFollowerItemLevelAverage(followerID), 
		C_Garrison.GetFollowerSpecializationAtIndex(followerID, 1),
		C_Garrison.GetFollowerAbilityAtIndex(followerID, 1),
		C_Garrison.GetFollowerAbilityAtIndex(followerID, 2),
		C_Garrison.GetFollowerAbilityAtIndex(followerID, 3),
		C_Garrison.GetFollowerAbilityAtIndex(followerID, 4),
		C_Garrison.GetFollowerTraitAtIndex(followerID, 1),
		C_Garrison.GetFollowerTraitAtIndex(followerID, 2),
		C_Garrison.GetFollowerTraitAtIndex(followerID, 3),
		C_Garrison.GetFollowerTraitAtIndex(followerID, 4)
		);
end

function GarrisonBuildingInfoBox_OnUpdate(self)
	local timeLeft, timeLefttext = C_Garrison.GetBuildingTimeRemaining( self.ID );
	self.TimeLeft:SetText( timeLefttext );
	if( timeLeft == 0 ) then
		self.Timer.Cooldown:SetCooldownDuration(0);
		self.Timer.CompleteRing:Show();
		self:SetScript("OnUpdate", nil);
	end
end

function GarrisonBuildingInfoBox_OnDragStart(self, button)
	local building = GarrisonBuildingFrame.selectedBuilding;
	if (not building or building.plotID) then 
		--there is no building displayed, or that building is already placed/locked
		return;
	end
	
	local id, name, textureKit, icon, _, _, currencyID, currencyQty, goldQty, buildTime, needsPlan = C_Garrison.GetBuildingInfo(building.buildingID);
	
	if (needsPlan) then
		return;
	end
		
	if (icon) then
		SetPortraitToTexture(GarrisonBuildingPlacer.Icon, icon);
	end
	if (textureKit) then
		GarrisonPlot_SetBuildingArt(GarrisonBuildingPlacer, textureKit.."_Map");
	end
	GarrisonBuildingPlacer.info = building;
	GarrisonBuildingPlacer.info.cost = currencyQty;
	GarrisonBuildingPlacer.info.goldQty = goldQty;
	GarrisonBuildingPlacer.info.buildTime = buildTime;
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonBuildingPlacer:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale);
	GarrisonBuildingPlacer:Show();
	GarrisonBuildingPlacer:SetScript("OnUpdate", GarrisonBuildingPlacer_OnUpdate);
	GarrisonBuildingFrame_HighlightPlots(C_Garrison.GetPlotsForBuilding(building.buildingID), true);
end

function GarrisonBuildingInfoBox_OnDragStop(self)
	if (GarrisonBuildingPlacer:IsShown()) then
		GarrisonBuildingPlacerFrame:Show();
	end
end

function GarrisonBuildingFrameTimerCancel_OnClick(self, button)
	local _,_,_,_,rank = C_Garrison.GetOwnedBuildingInfoAbbrev(GarrisonBuildingFrame.selectedBuilding.plotID);
	local popupText = "GARRISON_CANCEL_BUILD_BUILDING";
	if (rank > 1) then
		popupText = "GARRISON_CANCEL_UPGRADE_BUILDING";
	end
	local dialog = StaticPopup_Show(popupText);
	dialog.data = GarrisonBuildingFrame.selectedBuilding;
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function GarrisonBuildingFrameTimerCancel_OnConfirm(selectedBuilding)
	if (not selectedBuilding or not selectedBuilding.plotID) then
		return;
	end
	
	C_Garrison.CancelConstruction(selectedBuilding.plotID);
end

function GarrisonBuildingFrameLevelIcon_OnEnter(self, button)
	if (not GarrisonBuildingFrame.InfoBox.RankBadge:IsShown()) then
		return;
	end
	
	local building = GarrisonBuildingFrame.selectedBuilding;
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 15, 15);
	local _, id, name, textureKit, icon, rank, currencyID, cost, goldQty, buildTime, tooltip, needsPlan;
	local locked = building.plotID and GarrisonBuildingFrame.plots[building.plotID] and GarrisonBuildingFrame.plots[building.plotID].locked;
	
	-- If we own the building, show upgrade info
	if (building.plotID and not locked) then
		id, name, textureKit, icon, rank, currencyID, cost, goldQty, buildTime, tooltip = C_Garrison.GetBuildingUpgradeInfo(building.buildingID);
		if (rank) then
			_, _, _, _, _, needsPlan = C_Garrison.GetBuildingTooltip(id);
			GameTooltip:SetText(format(GARRISON_BUILDING_LEVEL_UPGRADE, rank)); 
		else
			-- We are at max rank
			GameTooltip:SetText(GARRISON_BUILDING_LEVEL_MAX);
			GameTooltip:Show();
			return;
		end
		tooltip = HIGHLIGHT_FONT_COLOR_CODE .. tooltip .. "|r";
	else
		tooltip, cost, goldQty, currencyID, buildTime, needsPlan = C_Garrison.GetBuildingTooltip(building.buildingID);
		tooltip = GRAY_FONT_COLOR_CODE .. tooltip .. "|r";
		GameTooltip:SetText(GARRISON_BUILDING_LEVEL_ONE); 
	end

	if (tooltip and tooltip ~= "") then
		GameTooltip:AddLine(tooltip, 1, 1, 1, true);
	end
	
	if (not locked) then
		if (needsPlan) then
			GameTooltip:AddLine(GARRISON_PLAN_REQUIRED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		end
		if (cost) then
			GameTooltip:AddLine(" ")
			if (building.plotID) then
				GameTooltip:AddLine(UPGRADE, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
			end
			local costAmount = Garrison_GetTotalCostString(cost, goldQty);
			GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..COSTS_LABEL..FONT_COLOR_CODE_CLOSE.." "..costAmount, 1, 1, 1, true);
			GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..TIME_LABEL..FONT_COLOR_CODE_CLOSE.." "..buildTime, 1, 1, 1, true);
		end
	end
	GameTooltip:Show();
end

function GarrisonBuildingFrameLevelIcon_OnLeave(self, button)
	GameTooltip_Hide();
end

-----------------------------------------------------------------------
-- Placing followers stuff
-----------------------------------------------------------------------

function GarrisonBuildingAddFollowerButton_OnClick(self, button)
	if (GarrisonBuildingFrame.FollowerList:IsShown()) then
		GarrisonBuildingList_Show();
		PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_ASSIGN_FOLLOWER);
	elseif (not self.greyedOut) then
		GarrisonBuildingFrame.FollowerList:Show();
		GarrisonBuildingFrame.BuildingList:Hide();
		PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_ASSIGN_FOLLOWER)
	end
end

function GarrisonBuildingAddFollowerButton_OnEnter(self, button)
	if (not self.greyedOut) then
		self.PortraitHighlight:Show();
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:SetText(GARRISON_BUILDING_SELECT_FOLLOWER_TOOLTIP, nil, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function GarrisonBuildingAddFollowerButton_OnLeave(self, button)
	self.PortraitHighlight:Hide();
	GameTooltip_Hide();
end

function GarrisonBuildingFollowerList_OnShow(self)
	local followerList = GarrisonBuildingFrame.FollowerList;
	self.followers = C_Garrison.GetPossibleFollowersForBuilding(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower, GarrisonBuildingFrame.selectedBuilding.plotID);
	GarrisonFollowerList_SortFollowers(self);

	local dataProvider = CreateDataProvider();
	for index, follower in ipairs(self.followers) do
		dataProvider:Insert({index=index, follower=follower, followerList=self});
	end
	followerList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	followerList.NoFollowerText:SetShown(#self.followers == 0);
end

function GarrisonBuildingFollowerList_OnHide(self)
	self.followers = nil;
end

function GarrisonBuildingFollowerButton_OnClick(self, button)
	if ( C_Garrison.GetFollowerStatus(self.id) ) then
		return;
	end
	C_Garrison.AssignFollowerToBuilding(GarrisonBuildingFrame.selectedBuilding.plotID, self.info.followerID);
	GarrisonBuildingList_Show();
	PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_SELECT_FOLLOWER);
end

function GarrisonBuildingFollowerButton_GetFollowerList(self)
	return self:GetParent():GetParent():GetParent():GetParent().followers;
end

function GarrisonBuildingFollowerButton_OnEnter(self, button)
	local followers = GarrisonBuildingFollowerButton_GetFollowerList(self);
	for i = 1, #followers do
		if ( followers[i].followerID == self.id ) then
			GarrisonFollowerTooltipShow(self, self.id, followers[i].garrFollowerID);
			return;
		end
	end
end

function GarrisonBuildingFollowerButton_OnLeave(self, button)
	GarrisonFollowerTooltip:Hide();
end

-----------------------------------------------------------------------
-- Building List stuff
-----------------------------------------------------------------------

function GarrisonBuildingList_Show()
	GarrisonBuildingFrame.FollowerList:Hide();
	GarrisonBuildingFrame.BuildingList:Show();
end

function GarrisonBuildingList_SelectTab(tab)
	local list = GarrisonBuildingFrame.BuildingList;
	for i=1, GARRISON_NUM_BUILDING_SIZES do
		local otherTab = list["Tab"..i];
		if (i ~= tab:GetID()) then
			otherTab:GetNormalTexture():SetAtlas("Garr_ListTab", true)
		end
	end
	tab:GetNormalTexture():SetAtlas("Garr_ListTab-Select", true)
	GarrisonBuildingFrame.selectedTab = tab;
	
	--update buttons in list
	local currButton, prevButton;
	for i=1, #tab.buildings do
		local building = tab.buildings[i];
		if (not list.Buttons[i]) then
			list.Buttons[i] = CreateFrame("BUTTON", nil, list, "GarrisonBuildingListButtonTemplate");
			list.Buttons[i]:SetPoint("TOP", prevButton, "BOTTOM", 0, 2);
		end
		currButton = list.Buttons[i];
		currButton.info = building;
		currButton.Name:SetText(building.name);
		currButton.Icon:SetTexture(building.icon);
		if (building.needsPlan) then
			currButton.Plans:Show();
			currButton.Icon:SetDesaturated(true);
			currButton.Name:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		else
			currButton.Plans:Hide();
			currButton.Icon:SetDesaturated(false);
			currButton.Name:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
		currButton:Show();
		prevButton = list.Buttons[i];
	end
	for i=(#tab.buildings+1), #list.Buttons do
		list.Buttons[i]:Hide();
	end
end

function GarrisonBuildingTab_OnMouseDown(self)
	if (GarrisonBuildingFrame.selectedTab ~= self) then
		PlaySound(SOUNDKIT.UI_GARRISON_NAV_TABS);
		GarrisonBuildingTab_Select(self);
	end
end

function GarrisonBuildingTab_Select(self)
	GarrisonBuildingList_SelectTab(self)
	GarrisonBuildingListButton_Select(GarrisonBuildingFrame.BuildingList.Buttons[1]);
end

function GarrisonBuildingListButton_OnMouseDown(self, button)
	PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_SELECT);
	GarrisonBuildingListButton_Select(self);
end

function GarrisonBuildingListButton_Select(self)
	if (GarrisonBuildingFrame.selectedBuilding and GarrisonBuildingFrame.selectedBuilding.button) then
		GarrisonBuildingFrame.selectedBuilding.button.SelectedBG:Hide();
	end
	if (self.info) then
		GarrisonBuildingFrame.selectedBuilding = self.info;
		GarrisonBuildingFrame.selectedBuilding.button = self;
		self.SelectedBG:Show();
		
		GarrisonBuildingFrame_ClearPlotHighlights();
		if (self.info.plotID) then
			GarrisonBuildingInfoBox_ShowBuilding(self.info.plotID, true);
			GarrisonBuildingFrame_HighlightPlots({self.info.plotID}, true);
		else
			GarrisonBuildingInfoBox_ShowBuilding(self.info.buildingID, false);
			GarrisonBuildingFrame_HighlightPlots(C_Garrison.GetPlotsForBuilding(self.info.buildingID), false);
		end
	end
end

function GarrisonBuildingList_SelectBuilding(buildingID) 
	if (not buildingID or buildingID == 0) then
		return;
	end
	local buttons = GarrisonBuildingFrame.BuildingList.Buttons;
	for i=1, #buttons do
		if (buttons[i].info.buildingID == buildingID) then
			GarrisonBuildingListButton_Select(buttons[i]);
			return;
		end
	end
	GarrisonBuildingListButton_Select(buttons[1]);
end

function GarrisonBuilding_ShowLevelTooltip(name, plotID, buildingID, anchor)
	if ( plotID and not GarrisonBuildingFrame.plots[plotID] ) then
		return;
	end
	local Tooltip = GarrisonBuildingFrame.BuildingLevelTooltip;
	Tooltip.Name:SetText(name);
	local height = Tooltip.Name:GetHeight() + 30; --15 pixels of padding on top and bottom
	local followerText = plotID and GarrisonBuildingFrame.plots[plotID].followerTooltip;
	if (followerText) then
		Tooltip.FollowerText:SetText(followerText);
		height = height + Tooltip.FollowerText:GetHeight() + 5;
		Tooltip.Rank1:SetPoint("TOPLEFT", Tooltip.FollowerText, "BOTTOMLEFT", 0, -10);
	else
		Tooltip.FollowerText:SetText(nil);
		Tooltip.Rank1:SetPoint("TOPLEFT", Tooltip.Name, "BOTTOMLEFT", 0, -10);
	end
	local _, rank, currencyID, currencyQty, goldQty, buildTime, needsPlan, upgrades, canUpgrade, underConstruction, canActivate;
	local locked = plotID and GarrisonBuildingFrame.plots[plotID].locked;
	local owned = plotID and not locked;
	if (owned) then
		_, _, _, _, _, rank, currencyID, currencyQty, goldQty, buildTime, needsPlan, _, _, upgrades, canUpgrade, _, _, _, _, _, underConstruction, _, _, _, canActivate = C_Garrison.GetOwnedBuildingInfo(plotID);
	else
		_, _, _, _, _, rank, currencyID, currencyQty, goldQty, buildTime, needsPlan, _, _, upgrades, canUpgrade = C_Garrison.GetBuildingInfo(buildingID);
	end
		
	for i = 1, GARRISON_MAX_BUILDING_LEVEL do
		Tooltip["Rank"..i]:SetFormattedText(GARRISON_BUILDING_LEVEL_TOOLTIP_TEXT, i);
	end

	if (not upgrades or #upgrades == 0) then
		return;
	end
	
	Tooltip.Rank1Tooltip:SetVertexColor(0.5, 0.5, 0.5, 1);
	Tooltip.Rank2Tooltip:SetVertexColor(0.5, 0.5, 0.5, 1);
	Tooltip.Rank3Tooltip:SetVertexColor(0.5, 0.5, 0.5, 1);
	if (owned) then
		for i=1, rank do
			-- Note: If the building is under construction or not yet activated, the player only receives the benefit of the building ranks below the current rank
			if(i < rank or not(underConstruction or canActivate)) then
				Tooltip["Rank"..i.."Tooltip"]:SetVertexColor(1, 1, 1, 1);
			end
		end
	end
	
	local nextAnchor = nil;
	for i=1, #upgrades do
		local tooltip = C_Garrison.GetBuildingTooltip(upgrades[i]);
		if (tooltip == "") then 
			tooltip = nil 
		end
		
		if (nextAnchor) then
			Tooltip["Rank"..i]:SetPoint("TOPLEFT", nextAnchor, "BOTTOMLEFT", -10, -10);
		end
		local tooltipText = tooltip;
		
		Tooltip["Rank"..i.."Tooltip"]:SetText(tooltipText);
		Tooltip["Rank"..i]:Show();
		Tooltip["Rank"..i.."Tooltip"]:Show();
		--10 pixels padding above rank title, 5 pixels above rank tooltip
		height = height + Tooltip["Rank"..i.."Tooltip"]:GetHeight() + Tooltip["Rank"..i]:GetHeight() + 15;
	end
	
	for i=#upgrades+1, 3 do
		Tooltip["Rank"..i.."Tooltip"]:Hide();
		Tooltip["Rank"..i]:Hide();
	end
	
	if (locked) then
		Tooltip.UnlockText:SetText(GARRISON_LOCKED_PLOT_TOOLTIP);
		--10 pixels padding above unlock text
		height = height + Tooltip.UnlockText:GetHeight() + 10;
	else
		Tooltip.UnlockText:SetText(nil);
	end
	
	Tooltip:SetHeight(height);
	Tooltip:SetPoint("LEFT", anchor, "RIGHT", -3, -5);
	Tooltip:Show();
end

function GarrisonBuilding_HideLevelTooltip()
	GarrisonBuildingFrame.BuildingLevelTooltip:Hide();
end
	
function GarrisonBuildingListButton_OnEnter(self)
	GarrisonBuilding_ShowLevelTooltip(self.info.name, self.info.plotID, self.info.buildingID, self);
	
	-- Highlight the building on the map if we own it or relevant plots if we don't
	if (self.info.plotID) then
		if ( GarrisonBuildingFrame.plots[self.info.plotID] ) then
			GarrisonBuildingFrame.plots[self.info.plotID].BuildingHighlight:Show();
		end
	else
		local plotList = C_Garrison.GetPlotsForBuilding(self.info.buildingID);
		for i=1, #plotList do
			local Plot = GarrisonBuildingFrame.plots[plotList[i]];
			if (Plot and not Plot.buildingID) then
				Plot.PlotHover:Show();
			end
		end
	end
end

function GarrisonBuildingListButton_OnLeave(self)
	GarrisonBuilding_HideLevelTooltip();
		
	-- Un-Highlight building or empty plots on the map
	if (self.info.plotID) then
		if ( GarrisonBuildingFrame.plots[self.info.plotID] ) then
			GarrisonBuildingFrame.plots[self.info.plotID].BuildingHighlight:Hide();
		end
	else
		local plotList = C_Garrison.GetPlotsForBuilding(self.info.buildingID);
		for i=1, #plotList do
			local Plot = GarrisonBuildingFrame.plots[plotList[i]];
			if (Plot and not Plot.buildingID) then
				Plot.PlotHover:Hide();
			end
		end
	end
end

function GarrisonBuildingListButton_OnDragStart(self, button)
	if (self.info.needsPlan) then --You can't place a building you don't have the plans for
		return;
	end
	
	local id, name, textureKit, icon = C_Garrison.GetBuildingInfo(self.info.buildingID);
	if (icon) then
		SetPortraitToTexture(GarrisonBuildingPlacer.Icon, icon);
	end
	if (textureKit) then
		GarrisonPlot_SetBuildingArt(GarrisonBuildingPlacer, textureKit.."_Map");
	end
	GarrisonBuildingPlacer.info = self.info;
	GarrisonBuildingPlacer.fromExistingBuilding = (self.info.plotID ~= nil);
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonBuildingPlacer:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale);
	GarrisonBuildingPlacer:Show();
	GarrisonBuildingPlacer:SetScript("OnUpdate", GarrisonBuildingPlacer_OnUpdate);
	GarrisonBuildingFrame_HighlightPlots(C_Garrison.GetPlotsForBuilding(self.info.buildingID), true);
end

function GarrisonBuildingListButton_OnDragStop(self)
	if (GarrisonBuildingPlacer:IsShown()) then
		GarrisonBuildingPlacerFrame:Show();
	end
end

function GarrisonBuildingPlacer_OnUpdate(self)
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonBuildingPlacer:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale);
end

function GarrisonBuildingPlacer_Clear()
	GarrisonBuildingFrame_ClearPlotHighlights();
	if (GarrisonBuildingFrame.selectedBuilding) then
		GarrisonBuildingList_SelectBuilding(GarrisonBuildingFrame.selectedBuilding.buildingID);
	end
	if (GarrisonBuildingPlacer.fromExistingBuilding) then
		GarrisonPlot_SetGreyedOut(GarrisonBuildingPlacer.info, false);
	end

	GarrisonBuildingPlacer.Building:SetTexture(nil);
	GarrisonBuildingPlacer.Icon:SetTexture(nil);
	GarrisonBuildingPlacer.info = nil;
	GarrisonBuildingPlacer.fromExistingBuilding = nil;
	GarrisonBuildingPlacer:SetScript("OnUpdate", nil);
	GarrisonBuildingPlacer:Hide();
	GarrisonBuildingPlacerFrame:Hide();
end

function GarrisonBuildingPlacerFrame_OnClick(self, button)
	local plotList = GarrisonBuildingFrame.MapFrame.Plots;
	for i=1, #plotList do
		if (plotList[i]:IsMouseOver()) then
			GarrisonPlot_OnReceiveDrag(plotList[i]);
			break;
		end	
	end
	GarrisonBuildingPlacer_Clear();
end

-----------------------------------------------------------------------
-- Plot stuff
-----------------------------------------------------------------------

function GarrisonPlot_SetGreyedOut(self, greyedOut)
	self.greyedOut = greyedOut;
	GarrisonPlot_UpdateBuilding(self.plotID);
end
	
function GarrisonPlot_OnDragStart(self)
	-- Cannot drag empty or locked plots
	if (self.locked or not self.buildingID) then
		return;
	end
	
	local id, name, textureKit, icon = C_Garrison.GetBuildingInfo(self.buildingID);
	GarrisonPlot_SetGreyedOut(self, true);
	
	if (icon) then
		SetPortraitToTexture(GarrisonBuildingPlacer.Icon, icon);
	end
	
	if (textureKit) then
		GarrisonPlot_SetBuildingArt(GarrisonBuildingPlacer, textureKit.."_Map");
	end
	GarrisonBuildingPlacer.info = self;
	GarrisonBuildingPlacer.fromExistingBuilding = true;
	
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonBuildingPlacer:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale);
	GarrisonBuildingPlacer:Show();
	GarrisonBuildingPlacer:SetScript("OnUpdate", GarrisonPlot_OnUpdate);
	
	-- Highlight available plots to swap with
	GarrisonBuildingFrame_ClearPlotHighlights();
	GarrisonBuildingFrame_HighlightPlots(C_Garrison.GetPlotsForBuilding(self.buildingID), true);
end

function GarrisonPlot_OnDragStop(self)
	-- This placer frame is so that after you stop dragging, you can click again to clear the mouse
	if (GarrisonBuildingPlacer:IsShown()) then
		GarrisonBuildingPlacerFrame:Show();
	end
end

function GarrisonPlot_OnUpdate(self)
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonBuildingPlacer:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale);
end

function GarrisonPlot_OnReceiveDrag(self)
	if (not GarrisonBuildingPlacer:IsShown() or not GarrisonBuildingPlacer.info
		or not GarrisonBuildingPlacer.info.buildingID or not self.plotID) then
		return;
	end
	-- Do nothing if you drag the plot onto itself
	if (GarrisonBuildingPlacer.info.plotID == self.plotID) then
		return;
	end
	-- If this was dragged from another plot, swap the buildings
	if (GarrisonBuildingPlacer.fromExistingBuilding) then
		C_Garrison.SwapBuildings(GarrisonBuildingPlacer.info.plotID, self.plotID);
		GarrisonBuildingPlacer_Clear();
		return;
	end
	
	local confirmation = GarrisonBuildingFrame.Confirmation;
	
	-- Error if we drag the wrong building size onto the plot, or we drag onto a pre-built plot
	local dragPlotSize = BuildingSizeForTab(GarrisonBuildingFrame.selectedTab:GetID())
	local myPlotSize = GarrisonBuildingFrame.plots[self.plotID].size;
	local isPrebuilt = GarrisonBuildingFrame.plots[self.plotID].isPrebuilt;
	if (dragPlotSize ~= myPlotSize or (self.buildingID and isPrebuilt)) then
		UIErrorsFrame:AddMessage(ERR_GARRISON_INVALID_PLOT_BUILDING, 1.0, 0.1, 0.1, 1.0);
		GarrisonBuildingPlacer_Clear();
		PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_PLACEMENT_ERROR);
		return;
	end
		
	if (self.buildingID) then
		GarrisonBuildingFrameConfirmation_SetContext("replace")
		confirmation.oldPlotID = self.plotID;
	else
		C_Garrison.PlaceBuilding(self.plotID, GarrisonBuildingPlacer.info.buildingID);
		GarrisonBuildingPlacer_Clear();
		return;
	end
	confirmation.MaterialCost:SetText(Garrison_GetTotalCostString(GarrisonBuildingPlacer.info.cost, GarrisonBuildingPlacer.info.goldCost));
	confirmation.Time:SetText(GarrisonBuildingPlacer.info.buildTime);
	confirmation.plot = self;
	confirmation.buildingID = GarrisonBuildingPlacer.info.buildingID;
	confirmation:ClearAllPoints();
	confirmation:SetPoint("BOTTOM", self, "TOP", 0, 0);
	confirmation:Show();
	PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_UPGRADE);
	
	local id, name, textureKit, icon = C_Garrison.GetBuildingInfo(GarrisonBuildingPlacer.info.buildingID)
	GarrisonPlot_SetBuilding(self, id, name, textureKit, icon);
	
	GarrisonBuildingPlacer_Clear();
end

function GarrisonPlot_OnClick(self)
	if (not self.plotID) then
		return;
	end
	
	local list = GarrisonBuildingFrame.BuildingList;
	
	local categoryID = C_Garrison.GetTabForPlot(self.plotID);
	if (not BUILDING_TABS[categoryID]) then
		if (self.buildingID) then
			if (GarrisonBuildingFrame.selectedBuilding and GarrisonBuildingFrame.selectedBuilding.button) then
				GarrisonBuildingFrame.selectedBuilding.button.SelectedBG:Hide();
			end
			GarrisonBuildingFrame.selectedBuilding = {plotID = self.plotID, buildingID = self.buildingID};
			if (self.locked) then
				GarrisonBuildingInfoBox_ShowBuilding(self.buildingID, false, true);
			else
				GarrisonBuildingInfoBox_ShowBuilding(self.plotID, true);
			end
			GarrisonBuildingFrame_ClearPlotHighlights();
			self.PlotHighlight:Show();
		end
		PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_SELECT);
		return;
	end
	GarrisonBuildingList_Show();	
	GarrisonBuildingList_SelectTab(BUILDING_TABS[categoryID]);
	
	GarrisonBuildingFrame.InfoBox.UpgradeButton:Hide();
	GarrisonBuildingFrame_ClearPlotHighlights();
	self.PlotHighlight:Show();
	GarrisonPlot_ShowTooltip(self);
	
	if (self.buildingID) then
		PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_SELECT);
		GarrisonBuildingList_SelectBuilding(self.buildingID);
		return;
	end
	
	local buildings = C_Garrison.GetBuildingsForPlot(self.plotID);
	if (#buildings == 1) then
		for i=1, #list.Buttons do
			local Button = list.Buttons[i];
			if (Button.info.buildingID == buildings[1]) then
				PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_SELECT);
				GarrisonBuildingListButton_Select(Button);
				return;
			end
		end
	end

	PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_PLOT_SELECT);
	local plotSize = GarrisonBuildingFrame.plots[self.plotID].size;
	GarrisonBuildingInfoBox_ShowEmptyPlot(plotSize);
end

function GarrisonPlot_GetFollowerTooltipText(buildingID, plotID)
	local _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_, hasFollowerSlot = C_Garrison.GetBuildingInfo(buildingID);
	if (hasFollowerSlot) then
		local followerName = C_Garrison.GetFollowerInfoForBuilding(plotID);
		local followerString;
		if (followerName) then
			followerString = format(GARRISON_BUILDING_FOLLOWER_WORKING, followerName);
		else
			followerString = GARRISON_BUILDING_FOLLOWER_EMPTY;
		end
		return format("|cffb2f0ff%s|r", followerString);
	end
	return nil;
end

function GarrisonPlot_ShowTooltip(self)
	if (self.buildingID and self.tooltip) then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
		if (self.isPrebuilt) then
			GarrisonBuilding_ShowLevelTooltip(self.tooltip, self.plotID, self.buildingID, self);
		else
			GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true);
			if (self.followerTooltip) then
				GameTooltip:AddLine(self.followerTooltip);
			end
		end
	else
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
		
		local plotSize = GarrisonBuildingFrame.plots[self.plotID].size;
		if (plotSize == 1) then
			GameTooltip:SetText(GARRISON_EMPTY_PLOT_SMALL);
		elseif (plotSize == 2) then
			GameTooltip:SetText(GARRISON_EMPTY_PLOT_MEDIUM);
		else
			GameTooltip:SetText(GARRISON_EMPTY_PLOT_LARGE);
		end
		if (self.PlotHighlight:IsShown()) then
			GameTooltip:AddLine(GARRISON_EMPTY_PLOT_SELECTED_TOOLTIP, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		else
			GameTooltip:AddLine(GARRISON_EMPTY_PLOT_HOVER_TOOLTIP, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		end
	end
	GameTooltip:Show();
end

function GarrisonPlot_OnEnter(self)
	self.BuildingHighlight:Show();
	self.PlotHover:Show();
	GarrisonPlot_ShowTooltip(self);
end

function GarrisonPlot_OnLeave(self)
	self.BuildingHighlight:Hide();
	self.PlotHover:Hide();
	GameTooltip_Hide();
	GarrisonBuilding_HideLevelTooltip();
end	

function GarrisonPlot_ClearBuilding(self)
	self.buildingID = nil;
	self.name = nil;
	self.Icon:Hide();
	self.IconRing:Hide();
	self.Building:Hide();
	self.BuildingHighlight:SetAtlas(nil);
	self.UpgradeArrow:Hide();
	self.Lock:Hide();
	self.Timer:Hide();
	self.BuildingGlowPulseAnim:Stop();
end

function GarrisonPlot_UpdateBuilding(plotID)
	local plot = GarrisonBuildingFrame.plots[plotID];
	if (plot) then
		local id, name, textureKit, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade, isPrebuilt = C_Garrison.GetOwnedBuildingInfoAbbrev(plotID);
		GarrisonPlot_SetBuilding(plot, id, name, textureKit, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade, isPrebuilt)
	end
end

function GarrisonPlot_SetBuildingArt(frame, texture)
	frame.Building:SetAtlas(texture, true);
	local width, height = frame.Building:GetSize();
	frame.Building:SetSize(width * 0.75, height * 0.75);
	frame.Building:SetPoint("BOTTOM", 0, 10);
	if (frame.BuildingHighlight) then
		frame.BuildingHighlight:SetAtlas(texture, true);
		frame.BuildingHighlight:SetSize(width * 0.75, height * 0.75);
	end
end
		
function GarrisonPlot_SetBuilding(self, id, tooltip, textureKit, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade, isPrebuilt)
	GarrisonPlot_ClearBuilding(self);
	self.buildingID = id;
	if (canActivate) then
		self.tooltip = GARRISON_FINALIZE_BUILDING_TOOLTIP;
		self.followerTooltip = nil;
	else
		self.tooltip = tooltip;
		self.followerTooltip = GarrisonPlot_GetFollowerTooltipText(self.buildingID, self.plotID);
	end
	if (icon) then
		SetPortraitToTexture(self.Icon, icon);
		self.Icon:Show();
		self.Icon:SetDesaturated(self.greyedOut);
		self.IconRing:Show();
		self.IconRing:SetDesaturated(self.greyedOut);
	end
	if (textureKit) then
		GarrisonPlot_SetBuildingArt(self, textureKit.."_Map");
		self.Building:Show();
		self.Building:SetDesaturated(self.greyedOut);
	end
	
	if (not isBuilding and not canActivate) then
		self.Timer:Hide();
		if (canUpgrade) then
			self.UpgradeArrow:Show();
			self.UpgradeArrow:SetDesaturated(self.greyedOut);
		end
		return;
	end
	
	if (rank > 1) then
		self.BuildingPulse:SetAtlas("Garr_BuildingUpgradeExplosion", true);
		self.AlphaPulse:SetAtlas("Garr_BuildingUpgradeExplosion", true);
		self.Timer.BG:SetAtlas("Garr_UpgradeIconTimerBG", true);
		self.Timer.CompleteRing:SetAtlas("Garr_UpgradeIconTimerFill", true);
		self.Timer.Cooldown:SetSwipeTexture("Interface\\Garrison\\Garr_TimerFill-Upgrade");
	else
		self.BuildingPulse:SetAtlas("Garr_BuildingPlacementExplosion", true);
		self.AlphaPulse:SetAtlas("Garr_BuildingPlacementExplosion", true);
		self.Timer.BG:SetAtlas("Garr_BuildingIconTimerBG", true);
		self.Timer.CompleteRing:SetAtlas("Garr_BuildingIconTimerFill", true);
		self.Timer.Cooldown:SetSwipeTexture("Interface\\Garrison\\Garr_TimerFill");
	end
	
	self.Timer:Show();
	if (isBuilding) then
		self.Timer.CompleteRing:Hide();
		self.Timer.Cooldown:SetCooldownUNIX(timeStart, buildTime);
		return;
	end
	
	if (canActivate) then
		self.BuildingGlowPulseAnim:Play();
		self.Timer.CompleteRing:Show();
	end
end

-- plotList is a list of plot IDs to highlight
function GarrisonBuildingFrame_HighlightPlots(plotList, highlightOwned)
	for i=1, #plotList do
		local Plot = GarrisonBuildingFrame.plots[plotList[i]];
		if (Plot and (not Plot.buildingID or highlightOwned)) then
			Plot.PlotHighlight:Show();
		end
	end
end

function GarrisonBuildingFrame_ClearPlotHighlights()
	for i, Plot in pairs(GarrisonBuildingFrame.plots) do
		Plot.PlotHighlight:Hide();
	end
end

-----------------------------------------------------------------------
-- Confirmation stuff
-----------------------------------------------------------------------

function GarrisonBuildingFrameConfirmation_SetContext(context)
	local self = GarrisonBuildingFrame.Confirmation;
	GarrisonBuildingFrame_ClearConfirmation();
	self.BuildButton:Hide();
	self.UpgradeButton:Hide();
	self.UpgradeGarrisonButton:Hide();
	self.ReplaceButton:Hide();
	self.SwitchButton:Hide();
	self.TimeLabel:Show();
	self.CostLabel:SetPoint("TOPLEFT", 81, -34);
	self.Time:Show();
	self.CostLabel:SetText(COSTS_LABEL);
	self.GoldCost:Hide();
	self.TimeLabel:SetText(TIME_LABEL);
	if (context == "build") then
		self.BuildButton:Show();
		self.Icon:SetAtlas("Garr_BuildIcon", true);
	elseif (context == "upgrade") then
		self.UpgradeButton:Show();
		self.Icon:SetAtlas("Garr_UpgradeIcon", true);
	elseif (context == "upgradegarrison") then
		self.UpgradeGarrisonButton:Show();
		self.TimeLabel:Hide();
		self.CostLabel:ClearAllPoints();
		self.CostLabel:SetPoint("TOPLEFT", 81, -44);
		self.Time:Hide();
		self.Icon:SetAtlas("Garr_UpgradeIcon", true);
	elseif (context == "replace") then
		self.ReplaceButton:Show();
		self.Icon:SetAtlas("Garr_SwapIcon", true);
	elseif(context == "switch") then
		self.SwitchButton:Show();
		self.Icon:SetAtlas("Garr_SwapIcon", true);
		self.CostLabel:SetText(GARRISON_SWITCH_SPECIALIZATIONS);
		self.Cost:SetText("");
		self.TimeLabel:SetText(COSTS_LABEL);
	end
end

function GarrisonBuildingFrame_ConfirmBuild()
	local confirmation = GarrisonBuildingFrame.Confirmation;
	if (not confirmation.plot or not confirmation.buildingID) then
		GarrisonBuildingFrame_ClearConfirmation();
		return;
	end
	
	C_Garrison.PlaceBuilding(confirmation.plot.plotID, confirmation.buildingID);
	GarrisonBuildingFrame_ClearConfirmation();
end

function GarrisonBuildingFrame_StartUpgrade(self)
	local building = GarrisonBuildingFrame.selectedBuilding;
	if (not building.plotID or not building.buildingID) then
		return;
	end
	
	local id, name, textureKit, icon, rank, currencyID, currencyQty, goldQty, buildTime = C_Garrison.GetBuildingUpgradeInfo(building.buildingID)

	-- Error if not enough money
	local currencyAmount = C_CurrencyInfo.GetCurrencyInfo(GARRISON_CURRENCY).quantity;
	if (currencyAmount < currencyQty) then
		UIErrorsFrame:AddMessage(ERR_GARRISON_NOT_ENOUGH_CURRENCY, 1.0, 0.1, 0.1, 1.0);
		PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_PLACEMENT_ERROR);
		return;
	elseif (GetMoney() < goldQty * COPPER_PER_GOLD) then
		UIErrorsFrame:AddMessage(ERR_GARRISON_NOT_ENOUGH_GOLD, 1.0, 0.1, 0.1, 1.0);
		PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_BUILDING_PLACEMENT_ERROR);
		return;
	end

	local Plot = GarrisonBuildingFrame.plots[building.plotID];
	
	local confirmation = GarrisonBuildingFrame.Confirmation;
	GarrisonBuildingFrameConfirmation_SetContext("upgrade");
	confirmation.plotID = building.plotID;
	confirmation.buildingID = id;
	confirmation.oldPlotID = building.plotID;
	confirmation.plot = Plot
	confirmation.MaterialCost:SetText(Garrison_GetTotalCostString(currencyQty, goldQty));
	confirmation.Time:SetText(buildTime);
	confirmation:ClearAllPoints();
	confirmation:SetPoint("BOTTOM", Plot, "TOP", 0, 0);
	confirmation:Show();
	PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_UPGRADE);
	
	GarrisonPlot_SetBuilding(Plot, id, name, textureKit, icon);
end

function GarrisonBuildingFrame_ConfirmUpgrade()
	local confirmation = GarrisonBuildingFrame.Confirmation;
	if (not confirmation.plotID) then
		GarrisonBuildingFrame_ClearConfirmation();
		return;
	end
	C_Garrison.UpgradeBuilding(confirmation.plotID);
	confirmation.oldPlotID = nil;
	GarrisonBuildingFrame_ClearConfirmation();
end

function GarrisonBuildingFrame_ConfirmUpgradeGarrison()
	C_Garrison.UpgradeGarrison(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower);
	GarrisonBuildingFrame_ClearConfirmation();
end

function GarrisonBuildingFrame_CancelConfirmation()
	GarrisonBuildingFrame_ClearConfirmation();
	PlaySound(SOUNDKIT.UI_GARRISON_ARCHITECT_TABLE_UPGRADE_CANCEL);
end

function GarrisonBuildingFrame_ClearConfirmation()
	local confirmation = GarrisonBuildingFrame.Confirmation;
	if (confirmation.plot) then
		if (confirmation.oldPlotID) then
			GarrisonPlot_UpdateBuilding(confirmation.oldPlotID);
			confirmation.oldPlotID = nil;
		else
			GarrisonPlot_ClearBuilding(confirmation.plot);
		end
		confirmation.plot = nil;
		confirmation.buildingID = nil;
	else
		confirmation.plotID = nil;
		confirmation.specID = nil;
	end
	confirmation:Hide();
end

-----------------------------------------------------------------------
-- Building Specialization stuff
-----------------------------------------------------------------------

function GarrisonBuildingSpec_OnClick(self, button)
	if (not GarrisonBuildingFrame.selectedBuilding or not GarrisonBuildingFrame.selectedBuilding.plotID) then
		return;
	end
	local confirmation = GarrisonBuildingFrame.Confirmation;
	GarrisonBuildingFrameConfirmation_SetContext("switch")
	confirmation.plotID = GarrisonBuildingFrame.selectedBuilding.plotID;
	confirmation.specID = self.id;
	if (not GarrisonBuildingFrame.SPEC_CHANGE_COST) then
		GarrisonBuildingFrame.SPEC_CHANGE_CURRENCY, GarrisonBuildingFrame.SPEC_CHANGE_COST = C_Garrison.GetSpecChangeCost();
	end
	local currencyTexture = C_CurrencyInfo.GetCurrencyInfo(GarrisonBuildingFrame.SPEC_CHANGE_CURRENCY).iconFileID;
	confirmation.Time:SetText(GarrisonBuildingFrame.SPEC_CHANGE_COST.."  |T"..currencyTexture..":0:0:0:-1|t ");
	confirmation:ClearAllPoints();
	confirmation:SetPoint("BOTTOM", self, "TOP", 0, 0);
	confirmation:Show();
end

function GarrisonBuildingSpec_ConfirmSwitch()
	local confirmation = GarrisonBuildingFrame.Confirmation;
	if (not confirmation.plotID or not confirmation.specID) then
		GarrisonBuildingFrame_ClearConfirmation();
		return;
	end
	C_Garrison.SetBuildingSpecialization(confirmation.plotID, confirmation.specID);
	GarrisonBuildingFrame_ClearConfirmation();
end

function GarrisonBuildingSpec_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	if (self.name) then
		GameTooltip:SetText(self.name);
	end
	if (self.tooltip) then
		GameTooltip:AddLine(self.tooltip, 1, 1, 1, true)
	end
	GameTooltip:Show();
end


---------------------------------------
-------Help plate stuff-----------
---------------------------------------

GarrisonBuilding_HelpPlate = {
	FramePos = { x = 20,          y = -22 },
	FrameSize = { width = 960, height = 700 },
	[1] = { ButtonPos = { x = 135,	y = -102 },  HighLightBox = { x = 10, y = -15, width = 285, height = 590 },	 ToolTipDir = "DOWN",  ToolTipText = GARRISON_BUILDING_TUTORIAL1 },
	[2] = { ButtonPos = { x = 650, y = -420 }, HighLightBox = { x =310, y = -185, width = 630, height = 420 }, ToolTipDir = "UP",   ToolTipText = GARRISON_BUILDING_TUTORIAL2 },
	[3] = { ButtonPos = { x = 450, y = -70 },  HighLightBox = { x = 310, y = -15, width = 630, height = 160 },  ToolTipDir = "RIGHT",  ToolTipText = GARRISON_BUILDING_TUTORIAL3 },
}


function GarrisonBuilding_ToggleTutorial()
	local helpPlate = GarrisonBuilding_HelpPlate;
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, GarrisonBuildingFrame, GarrisonBuildingFrame.MainHelpButton );
		SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true );
	else
		HelpPlate_Hide(true);
	end
end

---------------------------------------
------- Helper functions --------------
---------------------------------------

function Garrison_GetMaterialCostString(materialCost)
	if (materialCost) then
		local currencyTexture = C_CurrencyInfo.GetCurrencyInfo(GARRISON_CURRENCY).iconFileID;
		return materialCost .. " |T" .. currencyTexture..":0:0:0:0|t";
	else
		return "";
	end
end

function Garrison_GetGoldCostString(goldCost)
	if (goldCost) then
		return GetMoneyString(goldCost * 10000);
	else
		return "";
	end
end

function Garrison_GetTotalCostString(materialCost, goldCost)
	return Garrison_GetMaterialCostString(materialCost) .. "   " .. Garrison_GetGoldCostString(goldCost);
end
