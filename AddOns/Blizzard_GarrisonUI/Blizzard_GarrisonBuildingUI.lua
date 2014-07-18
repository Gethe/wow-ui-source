GARRISON_CURRENCY = 824;
GARRISON_NUM_BUILDING_SIZES = 3;
GARRISON_MAX_BUILDING_LEVEL = 3;
local EMPTY_PLOT_ATLAS = "GarrBuilding_EmptyPlot_1_A_Info";
local CAN_UPGRADE_ATLAS = "Garr_LevelUpgradeArrow";
local LOCKED_UPGRADE_ATLAS= "Garr_LevelUpgradeLocked";
local BARRACKS_BUILDING_ID = 26;

local BUILDING_TABS = {};

function GarrisonBuildingUI_ToggleFrame()
	if (not GarrisonBuildingFrame:IsShown()) then
		ShowUIPanel(GarrisonBuildingFrame);
	else
		HideUIPanel(GarrisonBuildingFrame);
	end
end

function GarrisonBuildingFrame_OnLoad(self)
	local list = GarrisonBuildingFrame.BuildingList;
	
	--set up tabs
	local tabInfo = C_Garrison.GetBuildingSizes();
	if (#tabInfo ~= GARRISON_NUM_BUILDING_SIZES) then
		return;
	end
	for i=1, GARRISON_NUM_BUILDING_SIZES do
		local tab = list["Tab"..i];
		local tabInfoIndex = GARRISON_NUM_BUILDING_SIZES - i + 1; --put large tab first
		tab.categoryID = tabInfo[tabInfoIndex].id;
		BUILDING_TABS[tabInfo[tabInfoIndex].id] = tab;
		tab.Text:SetText(tabInfo[tabInfoIndex].name);
		
		tab.buildings = C_Garrison.GetBuildingsForSize(tab.categoryID);
	end
	
	--get buildings owned
	local buildings = C_Garrison.GetBuildings();
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
	
	--get plots
	GarrisonBuildingFrame_UpdatePlots();
	
	GarrisonBuildingFrame_UpdateCurrency();
	
	self.FollowerList.listScroll.update = GarrisonBuildingFollowerList_Update;
	HybridScrollFrame_CreateButtons(self.FollowerList.listScroll, "GarrisonBuildingFollowerButtonTemplate", 7, -7, nil, nil, nil, -6);
	GarrisonBuildingFollowerList_Update();
	
	GarrisonBuildingFrame.SPEC_CHANGE_CURRENCY, GarrisonBuildingFrame.SPEC_CHANGE_COST = C_Garrison.GetSpecChangeCost();
	
	self:RegisterEvent("GARRISON_UPDATE");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GARRISON_BUILDING_UPDATE");
	self:RegisterEvent("GARRISON_BUILDING_PLACED");
	self:RegisterEvent("GARRISON_BUILDING_REMOVED");
	self:RegisterEvent("GARRISON_BUILDING_LIST_UPDATE");
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATED");
end

function GarrisonBuildingFrame_OnShow(self)
	GarrisonBuildingFrame_UpdateGarrisonInfo(self);
	if (not GarrisonBuildingFrame.selectedBuilding) then
		GarrisonBuildingFrame.BuildingList.Tab1:Click();
		GarrisonBuildingList_Show();
		-- check to show the help plate
		if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING) ) then
			local helpPlate = GarrisonBuilding_HelpPlate;
			if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
				HelpPlate_Show( helpPlate, GarrisonBuildingFrame, GarrisonBuildingFrame.MainHelpButton );
				SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true );
			end
			GarrisonBuildingList_SelectBuilding(BARRACKS_BUILDING_ID);
		end
	end
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
			else
				GarrisonBuildingInfoBox_ShowBuilding(buildingInfo.buildingID, false);
			end
		end
		local Plot = self.plots[plotID];
		if (not Plot) then
			return;
		end
		GarrisonPlot_UpdateBuilding(plotID);
	elseif (event == "GARRISON_BUILDING_PLACED") then
		local plotID = ...;
		local id, name, texPrefix, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade = C_Garrison.GetOwnedBuildingInfoAbbrev(plotID);
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
			Plot.BuildingCreateFlareAnim:Play();
			PlaySoundKitID(40999);
			GarrisonPlot_SetBuilding(Plot, id, name, texPrefix, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade);
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
				tab.buildings = C_Garrison.GetBuildingsForSize(tab.categoryID);
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
	end
end

function GarrisonBuildingFrame_UpdatePlots()
	GarrisonBuildingFrame.plots = {}
	local plots = C_Garrison.GetPlots();
	local mapWidth = GarrisonBuildingFrame.MapFrame:GetWidth();
	local mapHeight = GarrisonBuildingFrame.MapFrame:GetHeight();
	for i = 1, #plots do
		local plot = plots[i];
		if (not GarrisonBuildingFrame.MapFrame.Plots[i]) then
			GarrisonBuildingFrame.MapFrame.Plots[i] = CreateFrame("BUTTON", nil, GarrisonBuildingFrame.MapFrame, "GarrisonPlotTemplate");
		end
		local Plot = GarrisonBuildingFrame.MapFrame.Plots[i];
		Plot.plotID = plot.id;
		Plot:SetPoint("CENTER", GarrisonBuildingFrame.MapFrame, "BOTTOMLEFT", plot.x * mapWidth, plot.y * mapHeight)
		Plot.Plot:SetAtlas("Garr_Plot_Shadowmoon_A_"..plot.size, true);
		Plot.PlotHover:SetAtlas("Garr_Plot_Shadowmoon_A_"..plot.size, true);
		Plot.PlotHighlight:SetAtlas("Garr_Plot_Glow_"..plot.size, true);
		Plot.Lock:Hide();
		Plot.locked = false;
		local id, name, texPrefix, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade = C_Garrison.GetOwnedBuildingInfoAbbrev(plot.id);
		if (id) then
			GarrisonPlot_SetBuilding(Plot, id, name, texPrefix, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade);
		elseif (plot.buildingID) then
			GarrisonPlot_SetBuilding(Plot, plot.buildingID, "Complete a quest to unlock this building", plot.building, plot.icon);
			Plot.locked = true;
			Plot.Lock:Show();
		else
			GarrisonPlot_ClearBuilding(Plot);
		end
		Plot:Show();
		GarrisonBuildingFrame.plots[plot.id] = Plot;
	end
end

function GarrisonBuildingFrame_UpdateBuildingList()
	for id, tab in pairs(BUILDING_TABS) do
		tab.buildings = C_Garrison.GetBuildingsForSize(id);
	end
	if (GarrisonBuildingFrame.selectedTab) then
		GarrisonBuildingFrame.selectedTab:Click();
	end
end

function GarrisonBuildingFrame_UpdateGarrisonInfo(self)
	local level, mapTexture, townHallX, townHallY = C_Garrison.GetGarrisonInfo();
	self.level = level;
	self.MapFrame.Map:SetAtlas(mapTexture);
	self.MapFrame.TownHall.Level:SetText(level);
	self.MapFrame.TownHall.Building:SetAtlas("GarrBuilding_TownHall_"..level.."_A_Map", true);
	self.MapFrame.TownHall.BuildingHighlight:SetAtlas("GarrBuilding_TownHall_"..level.."_A_Map", true);
	local mapWidth = self.MapFrame:GetWidth();
	local mapHeight = self.MapFrame:GetHeight();
	self.MapFrame.TownHall:ClearAllPoints();
	self.MapFrame.TownHall:SetPoint("CENTER", self.MapFrame, "BOTTOMLEFT", townHallX * mapWidth, townHallY * mapHeight);
	GarrisonBuildingFrame_UpdatePlots();
	GarrisonBuildingFrame_UpdateBuildingList();
end

function GarrisonBuildingFrame_UpdateCurrency()
	local materialsText = GarrisonBuildingFrame.BuildingList.MoneyFrame.Materials;
	
	local currencyName, amount, currencyTexture = GetCurrencyInfo(GARRISON_CURRENCY);
	materialsText:SetText(amount.."  |T"..currencyTexture..":0:0:0:-1|t ");
end

function GarrisonTownHall_OnClick(self)
	GarrisonBuildingFrame.InfoBox:Hide();
	GarrisonBuildingList_Show();
	local infoBox = GarrisonBuildingFrame.TownHallBox;
	infoBox:Show();
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup == "Alliance" ) then
		infoBox.Title:SetText(GARRISON_TOWN_HALL_ALLIANCE);
	else
		infoBox.Title:SetText(GARRISON_TOWN_HALL_HORDE);
	end
	infoBox.RankBadge:SetAtlas("Garr_LevelBadge_"..GarrisonBuildingFrame.level, true);
	infoBox.Building:SetAtlas("GarrBuilding_TownHall_"..GarrisonBuildingFrame.level.."_A_Info", true);
	local emptyPlots = false;
	for k, plot in pairs(GarrisonBuildingFrame.plots) do
		if (not plot.buildingID) then
			emptyPlots = true;
			break;
		end
	end
	if (emptyPlots) then
		infoBox.UpgradeButton:Hide();
		infoBox.UpgradeAnim:Stop();
		infoBox.UpgradeGlow:Hide();
	else
		infoBox.UpgradeButton:Show();
		infoBox.UpgradeGlow:Show();
		infoBox.UpgradeAnim:Play();
	end
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
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup == "Alliance" ) then
		GameTooltip:SetText(GARRISON_TOWN_HALL_ALLIANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		GameTooltip:SetText(GARRISON_TOWN_HALL_HORDE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	local garrisonLevel = C_Garrison.GetGarrisonInfo();
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

function GarrisonBuildingInfoBox_ShowDefault()
	GarrisonBuildingFrame.TownHallBox:Hide();
	local infoBox = GarrisonBuildingFrame.InfoBox;
	infoBox:Show()
	
	infoBox.RankBadge:Hide();
	infoBox.RankLabel:Hide();
	infoBox.UpgradeBadge:Hide();
	infoBox.UpgradeAnim:Stop();
	infoBox.UpgradeGlow:Hide();
	infoBox.CostBar:Hide();
	infoBox.PlansNeeded:Hide();
	infoBox.Timer:Hide();
	infoBox.SpecFrame:Hide();
	infoBox.AddFollowerButton:Hide();

	infoBox.Building:SetAtlas(EMPTY_PLOT_ATLAS, true)
	infoBox.Building:SetDesaturated(false);
	infoBox.Title:SetText(GARRISON_EMPTY_PLOT);
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
	local id, name, texPrefix, icon, description, rank, currencyID, currencyQty, buildTime, needsPlan, possSpecs, upgrades, canUpgrade, isMaxLevel, knownSpecs, currSpec, specCooldown, isBuilding, startTime, buildDuration, timeLeftStr, canActivate, hasFollowerSlot;
	if (owned) then
		id, name, texPrefix, icon, description, rank, currencyID, currencyQty, buildTime, needsPlan, possSpecs, upgrades, canUpgrade, isMaxLevel, hasFollowerSlot, knownSpecs, currSpec, specCooldown, isBuilding, startTime, buildDuration, timeLeftStr, canActivate = C_Garrison.GetOwnedBuildingInfo(ID);
	else
		id, name, texPrefix, icon, description, rank, currencyID, currencyQty, buildTime, needsPlan, possSpecs, upgrades, canUpgrade, isMaxLevel, hasFollowerSlot = C_Garrison.GetBuildingInfo(ID);
	end
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
	if (owned and not isBuilding and upgrades and #upgrades > 0 and rank ~= #upgrades) then
		infoBox.UpgradeButton:Show();
		if (canUpgrade) then
			infoBox.UpgradeButton.upgradePlotID = ID;
			if (not isMaxLevel) then
				infoBox.UpgradeButton:Enable();
				infoBox.UpgradeBadge:SetAtlas(CAN_UPGRADE_ATLAS, true);
				infoBox.UpgradeButton.tooltip = nil;
				infoBox.UpgradeGlow:Show();
				infoBox.UpgradeAnim:Play();
			else
				infoBox.UpgradeButton:Disable();
				infoBox.UpgradeBadge:SetAtlas(LOCKED_UPGRADE_ATLAS, true);
				infoBox.UpgradeButton.tooltip = GARRISON_UPGRADE_ERROR;
			end
		else
			infoBox.UpgradeButton:Disable();
			infoBox.UpgradeBadge:SetAtlas(LOCKED_UPGRADE_ATLAS, true);
			local _, _, _, _, upgradeNeedsPlan = C_Garrison.GetBuildingTooltip(upgrades[rank+1]);
			if (upgradeNeedsPlan) then
				infoBox.UpgradeButton.tooltip = GARRISON_UPGRADE_NEED_PLAN;
			else
				infoBox.UpgradeButton.tooltip = GARRISON_UPGRADE_ERROR;
			end
		end
		infoBox.UpgradeBadge:Show();
	else
		infoBox.UpgradeBadge:Hide();
	end
	
	--general building info
	if (description and description ~= "") then
		infoBox.Description:SetText(description);
	end
	if (texPrefix) then
		infoBox.Building:SetAtlas(texPrefix.."_Info", true);
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
			infoBox.InfoText:SetText(GARRISON_UPGRADE_IN_PROGRESS);
			infoBox.Timer.Icon:SetAtlas("Garr_UpgradeIcon", true);
			infoBox.Timer.CompleteRing:SetAtlas("Garr_UpgradeTimerFill", true);
			infoBox.Timer.Glow:SetAtlas("Garr_UpgradeTimerGlow", true);
			infoBox.Timer.BG:SetAtlas("Garr_UpgradeTimerBG", true);
			infoBox.Timer.Cooldown:SetSwipeTexture("Interface\\Garrison\\Garr_TimerFill-Upgrade");
		else
			infoBox.InfoText:SetText(GARRISON_BUILDING_IN_PROGRESS);
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
		else
			infoBox:SetScript("OnUpdate", GarrisonBuildingInfoBox_OnUpdate);
			infoBox.TimeLeft:Show();
			infoBox.TimeLeft:SetText(timeLeftStr);
			infoBox.Timer.CompleteRing:Hide();
			infoBox.Timer.Glow:Hide();
			infoBox.Timer.Cooldown:SetCooldownUNIX(startTime, buildDuration);
			infoBox.Timer.Cancel:Show();
		end
	else
		infoBox.Timer:Hide();
	end
	
	--build restrictions
	infoBox.Lock:Hide();
	infoBox.PlansNeeded:Hide();
	infoBox.CostBar:Hide();
	if (showLock) then
		infoBox.Lock:Show();
		infoBox.InfoBar:Show();
		infoBox.InfoText:Show();
		infoBox.InfoText:SetText(GARRISON_BUILDING_LOCKED);
	elseif (needsPlan) then
		infoBox.PlansNeeded:Show();
		infoBox.Building:SetDesaturated(true);
	else
		infoBox.CostBar:Show();
		local _, _, currencyTexture = GetCurrencyInfo(currencyID);
		infoBox.CostBar.Cost:SetText(currencyQty.."  |T"..currencyTexture..":0:0:0:-1|t ");
		infoBox.CostBar.Time:SetText(buildTime);
		infoBox.Building:SetDesaturated(false);
	end
	
	if (owned) then
		infoBox.CostBar:Hide();
	end
	
	-- Show the cost to upgrade the building if it can be upgraded.
	local _;
	if (owned and canUpgrade) then
		_, _, _, _, _, currencyID, currencyQty = C_Garrison.GetBuildingUpgradeInfo(id);
	end
	if (owned and not isBuilding and currencyID) then
		local _, _, currencyTexture = GetCurrencyInfo(currencyID);
		infoBox.UpgradeCostBar.CostAmount:SetText(currencyQty.."  |T"..currencyTexture..":0:0:0:-1|t ");
		infoBox.UpgradeCostBar.TimeAmount:SetText(buildTime);
		infoBox.UpgradeCostBar.CostLabel:Show();
		infoBox.UpgradeCostBar.TimeLabel:Show();
		infoBox.UpgradeCostBar.CostAmount:Show();
		infoBox.UpgradeCostBar.TimeAmount:Show();
	else
		infoBox.UpgradeCostBar.CostLabel:Hide();
		infoBox.UpgradeCostBar.TimeLabel:Hide();
		infoBox.UpgradeCostBar.CostAmount:Hide();
		infoBox.UpgradeCostBar.TimeAmount:Hide();
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

function GarrisonBuildingInfoBox_ShowFollowerPortrait(owned, hasFollowerSlot, infoBox, isBuilding, canActivate, ID)
	if (not hasFollowerSlot) then
		infoBox.AddFollowerButton:Hide();
		infoBox.FollowerPortrait:Hide();
		return;
	end
	
	infoBox.AddFollowerButton.greyedOut = (isBuilding or canActivate or not owned);
	
	local followerName, level, quality, displayID, followerID, garrFollowerID, status = C_Garrison.GetFollowerInfoForBuilding(ID);
	if (followerName) then
		infoBox.AddFollowerButton:Hide();
		local button = infoBox.FollowerPortrait;
		button.Level:SetText(level);
		local color = ITEM_QUALITY_COLORS[quality];
    	button.LevelBorder:SetVertexColor(color.r, color.g, color.b);
		button.PortraitRing:SetVertexColor(color.r, color.g, color.b);
		SetPortraitTexture(button.Portrait, displayID);
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
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");	
	GarrisonFollowerTooltip_Show(garrFollowerID, 
		true,
		C_Garrison.GetFollowerQuality(followerID),
		C_Garrison.GetFollowerLevel(followerID), 
		C_Garrison.GetFollowerXP(followerID),
		C_Garrison.GetFollowerLevelXP(followerID),
		C_Garrison.GetFollowerItemLevelAverage(followerID), 
		C_Garrison.GetFollowerAbilityAtIndex(followerID, 1),
		C_Garrison.GetFollowerAbilityAtIndex(followerID, 2),
		C_Garrison.GetFollowerAbilityAtIndex(followerID, 3),
		C_Garrison.GetFollowerAbilityAtIndex(followerID, 4),
		C_Garrison.GetFollowerTraitAtIndex(followerID, 1),
		C_Garrison.GetFollowerTraitAtIndex(followerID, 2),
		C_Garrison.GetFollowerTraitAtIndex(followerID, 3),
		C_Garrison.GetFollowerTraitAtIndex(followerID, 4)
		);
	GarrisonFollowerTooltip:Show();
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
	
	local id, name, texPrefix, icon, _, _, currencyID, currencyQty, buildTime = C_Garrison.GetBuildingInfo(building.buildingID);
	if (icon) then
		SetPortraitToTexture(GarrisonBuildingPlacer.Icon, icon);
	end
	if (texPrefix) then
		GarrisonBuildingPlacer.Building:SetAtlas(texPrefix.."_Map", true);
	end
	GarrisonBuildingPlacer.info = building;
	GarrisonBuildingPlacer.info.cost = currencyQty;
	GarrisonBuildingPlacer.info.buildTime = buildTime;
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonBuildingPlacer:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale);
	GarrisonBuildingPlacer:Show();
	GarrisonBuildingPlacer:SetScript("OnUpdate", GarrisonBuildingPlacer_OnUpdate);
end

function GarrisonBuildingInfoBox_OnDragStop(self)
	if (GarrisonBuildingPlacer:IsShown()) then
		GarrisonBuildingPlacerFrame:Show();
	end
end

function GarrisonBuildingFrameTimerCancel_OnClick(self, button)
	local buildingInfo = GarrisonBuildingFrame.selectedBuilding;
	if (not buildingInfo or not buildingInfo.plotID) then
		return;
	end
	
	C_Garrison.CancelConstruction(buildingInfo.plotID);
end

function GarrisonBuildingFrameLevelIcon_OnEnter(self, button)
	local building = GarrisonBuildingFrame.selectedBuilding;
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 15, 15);
	local _, id, name, texPrefix, icon, rank, currencyID, cost, buildTime, tooltip, needsPlan;
	
	-- If we own the building, show upgrade info
	if (building.plotID) then
		id, name, texPrefix, icon, rank, currencyID, cost, buildTime, tooltip = C_Garrison.GetBuildingUpgradeInfo(building.buildingID);
		if (rank) then
			_, _, _, _, needsPlan = C_Garrison.GetBuildingTooltip(id);
			GameTooltip:SetText(format(GARRISON_BUILDING_LEVEL_UPGRADE, rank)); 
		else
			-- We are at max rank
			GameTooltip:SetText(GARRISON_BUILDING_LEVEL_MAX);
			GameTooltip:Show();
			return;
		end
		tooltip = HIGHLIGHT_FONT_COLOR_CODE .. tooltip .. "|r";
	else
		tooltip, cost, currencyID, buildTime, needsPlan = C_Garrison.GetBuildingTooltip(building.buildingID);
		tooltip = GRAY_FONT_COLOR_CODE .. tooltip .. "|r";
		GameTooltip:SetText(GARRISON_BUILDING_LEVEL_ONE); 
	end

	if (tooltip and tooltip ~= "") then
		GameTooltip:AddLine(tooltip, 1, 1, 1, true);
	end
	if (needsPlan) then
		GameTooltip:AddLine(GARRISON_PLAN_REQUIRED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	end
	if (cost) then
		GameTooltip:AddLine(" ")
		if (building.plotID) then
			GameTooltip:AddLine(UPGRADE, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		end
		local _, _, currencyTexture = GetCurrencyInfo(currencyID);
		GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..COSTS_LABEL..FONT_COLOR_CODE_CLOSE.." "..cost.."  |T"..currencyTexture..":0:0:0:-1|t ", 1, 1, 1, true);
		GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..TIME_LABEL..FONT_COLOR_CODE_CLOSE.." "..buildTime, 1, 1, 1, true);
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
	elseif (not self.greyedOut) then
		GarrisonBuildingFrame.FollowerList:Show();
		GarrisonBuildingFrame.BuildingList:Hide();
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
	self.followers = C_Garrison.GetPossibleFollowersForBuilding(GarrisonBuildingFrame.selectedBuilding.plotID);
	GarrisonBuildingFollowerList_Update();
	
	if (#self.followers == 0) then
		GarrisonBuildingFrame.FollowerList.NoFollowerText:Show();
	else
		GarrisonBuildingFrame.FollowerList.NoFollowerText:Hide();
	end
end

function GarrisonBuildingFollowerList_OnHide(self)
	self.followers = nil;
end

function GarrisonBuildingFollowerList_Update()
	local followers = GarrisonBuildingFrame.FollowerList.followers or {};
	local numFollowers = #followers;
	local scrollFrame = GarrisonBuildingFrame.FollowerList.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local expandedHeight = 0;
	
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numFollowers ) then
			local follower = followers[index];
			button.id = index;
			button.info = follower;
			button.Name:SetText(follower.name);
			button.Class:SetAtlas(follower.classAtlas);
			button.Status:SetText(follower.status);
			local color = ITEM_QUALITY_COLORS[follower.quality];
			button.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
			button.PortraitFrame.PortraitRing:SetVertexColor(color.r, color.g, color.b);
			button.PortraitFrame.Level:SetText(follower.level);
			SetPortraitTexture(button.PortraitFrame.Portrait, follower.displayID);
			button.PortraitFrame.Level:SetText(follower.level);
			button.followerID = follower.followerID;
			button.garrFollowerID = follower.garrFollowerID;
			-- adjust text position if we have additional text to show below name
			if (follower.level == GARRISON_FOLLOWER_MAX_LEVEL or follower.status) then
				button.Name:SetPoint("LEFT", button.PortraitFrame, "LEFT", 66, 8);
			else
				button.Name:SetPoint("LEFT", button.PortraitFrame, "LEFT", 66, 0);
			end
			-- show iLevel for max level followers	
			if (follower.level == GARRISON_FOLLOWER_MAX_LEVEL) then
				button.ILevel:SetText(ITEM_LEVEL_ABBR.." "..follower.iLevel);
				button.Status:SetPoint("TOPLEFT", button.ILevel, "TOPRIGHT", 4, 0);
			else
				button.ILevel:SetText(nil);
				button.Status:SetPoint("TOPLEFT", button.ILevel, "TOPRIGHT", 0, 0);
			end
			if (follower.xp == 0 or follower.levelXP == 0) then 
				button.XPBar:Hide();
			else
				button.XPBar:Show();
				button.XPBar:SetWidth((follower.xp/follower.levelXP) * GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH);
			end
			button:Show();
		else
			button:Hide();
		end
	end
	
	local totalHeight = numFollowers * scrollFrame.buttonHeight + expandedHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GarrisonBuildingFollowerButton_OnClick(self, button)
	C_Garrison.AssignFollowerToBuilding(GarrisonBuildingFrame.selectedBuilding.plotID, self.info.followerID);
	GarrisonBuildingList_Show();
end

function GarrisonBuildingFollowerButton_OnEnter(self, button)
	GarrisonFollowerTooltipShow(self, self.followerID, self.garrFollowerID);
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
	
	GarrisonBuildingFrame_ClearPlotHighlights();
end

function GarrisonBuildingTab_OnClick(self)
	local oldTab = GarrisonBuildingFrame.selectedTab;
	GarrisonBuildingList_SelectTab(self)
	if (oldTab ~= self) then
		GarrisonBuildingFrame.BuildingList.Buttons[1]:Click();
	end
end

function GarrisonBuildingListButton_OnClick(self, button)
	if (GarrisonBuildingFrame.selectedBuilding and GarrisonBuildingFrame.selectedBuilding.button) then
		GarrisonBuildingFrame.selectedBuilding.button.SelectedBG:Hide();
	end
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

function GarrisonBuildingList_SelectBuilding(buildingID) 
	if (not buildingID or buildingID == 0) then
		return;
	end
	local buttons = GarrisonBuildingFrame.BuildingList.Buttons;
	for i=1, #buttons do
		if (buttons[i].info.buildingID == buildingID) then
			buttons[i]:Click();
			return;
		end
	end
	buttons[1]:Click();
end

function GarrisonBuildingListButton_OnEnter(self)
	local Tooltip = GarrisonBuildingFrame.BuildingList.Tooltip;
	Tooltip.Name:SetText(self.info.name);
	local _, rank, currencyID, currencyQty, buildTime, needsPlan, upgrades, canUpgrade;
	local owned = self.info.plotID;
	if (owned) then
		_, _, _, _, _, rank, currencyID, currencyQty, buildTime, needsPlan, _, upgrades, canUpgrade = C_Garrison.GetOwnedBuildingInfo(self.info.plotID);
	else
		_, _, _, _, _, rank, currencyID, currencyQty, buildTime, needsPlan, _, upgrades, canUpgrade = C_Garrison.GetBuildingInfo(self.info.buildingID);
	end
		
	for i = 1, GARRISON_MAX_BUILDING_LEVEL do
		Tooltip["Rank"..i]:SetFormattedText(GARRISON_CURRENT_LEVEL, i);
	end

	if (not upgrades or #upgrades == 0) then
		return;
	end
	
	Tooltip.Rank1Tooltip:SetVertexColor(0.5, 0.5, 0.5, 1);
	Tooltip.Rank2Tooltip:SetVertexColor(0.5, 0.5, 0.5, 1);
	Tooltip.Rank3Tooltip:SetVertexColor(0.5, 0.5, 0.5, 1);
	if (owned) then
		for i=1, rank do
			Tooltip["Rank"..i.."Tooltip"]:SetVertexColor(1, 1, 1, 1);
		end
	end
	
	local nextAnchor = nil;
	local height = Tooltip.Name:GetHeight() + 30; --15 pixels of padding on top and bottom
	for i=1, #upgrades do
		local tooltip, _, _, _, needsPlan = C_Garrison.GetBuildingTooltip(upgrades[i]);
		if (tooltip == "") then 
			tooltip = nil 
		end
		
		if (nextAnchor) then
			Tooltip["Rank"..i]:SetPoint("TOPLEFT", nextAnchor, "BOTTOMLEFT", -10, -10);
		end
		local tooltipText = tooltip;
		
		if (needsPlan) then
			tooltipText = tooltipText .. "\n" .. RED_FONT_COLOR_CODE .. GARRISON_PLAN_REQUIRED .. FONT_COLOR_CODE_CLOSE;
		end
		Tooltip["Rank"..i.."Tooltip"]:SetText(tooltipText);
		if ((not owned and i == 1) or (owned and i == (rank + 1))) then
			local _, _, currencyTexture = GetCurrencyInfo(currencyID);
			Tooltip["Rank"..i.."Cost"]:SetText(currencyQty.."  |T"..currencyTexture..":0:0:0:-1|t ");
			Tooltip["Rank"..i.."Time"]:SetText(buildTime);
			Tooltip["Rank"..i.."Cost"]:Show();
			Tooltip["Rank"..i.."Time"]:Show();
			Tooltip["Rank"..i.."CostLabel"]:Show();
			Tooltip["Rank"..i.."TimeLabel"]:Show();
			nextAnchor = Tooltip["Rank"..i.."TimeLabel"];
			-- 10 pixels above cost, 2 pixels above time
			height = height + Tooltip["Rank"..i.."Cost"]:GetHeight() +Tooltip["Rank"..i.."Time"]:GetHeight() + 12;
		else
			Tooltip["Rank"..i.."Cost"]:Hide();
			Tooltip["Rank"..i.."Time"]:Hide();
			Tooltip["Rank"..i.."CostLabel"]:Hide();
			Tooltip["Rank"..i.."TimeLabel"]:Hide();
			nextAnchor = Tooltip["Rank"..i.."Tooltip"];
		end
		Tooltip["Rank"..i]:Show();
		Tooltip["Rank"..i.."Tooltip"]:Show();
		--10 pixels padding above rank title, 5 pixes above rank tooltip
		height = height + Tooltip["Rank"..i.."Tooltip"]:GetHeight() + Tooltip["Rank"..i]:GetHeight() + 15;
	end
	
	for i=#upgrades+1, 3 do
		Tooltip["Rank"..i.."Tooltip"]:Hide();
		Tooltip["Rank"..i]:Hide();
	end
	
	Tooltip:SetHeight(height);
	Tooltip:SetPoint("LEFT", self, "RIGHT", -3, -5);
	Tooltip:Show();
end

function GarrisonBuildingListButton_OnLeave(self)
	GarrisonBuildingFrame.BuildingList.Tooltip:Hide();
end

function GarrisonBuildingListButton_OnDragStart(self, button)
	if (self.plotID or self.info.needsPlan) then --You can't place a building you already have
		return;
	end
	
	local id, name, texPrefix, icon = C_Garrison.GetBuildingInfo(self.info.buildingID);
	if (icon) then
		SetPortraitToTexture(GarrisonBuildingPlacer.Icon, icon);
	end
	if (texPrefix) then
		GarrisonBuildingPlacer.Building:SetAtlas(texPrefix.."_Map", true);
	end
	GarrisonBuildingPlacer.info = self.info;
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonBuildingPlacer:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale);
	GarrisonBuildingPlacer:Show();
	GarrisonBuildingPlacer:SetScript("OnUpdate", GarrisonBuildingPlacer_OnUpdate);
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
	
	local id, name, texPrefix, icon = C_Garrison.GetBuildingInfo(self.buildingID);
	GarrisonPlot_SetGreyedOut(self, true);
	
	if (icon) then
		SetPortraitToTexture(GarrisonBuildingPlacer.Icon, icon);
	end
	
	if (texPrefix) then
		GarrisonBuildingPlacer.Building:SetAtlas(texPrefix.."_Map", true);
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
	PlaySoundKitID(40998);
	-- If this was dragged from another plot, swap the buildings
	if (GarrisonBuildingPlacer.fromExistingBuilding) then
		C_Garrison.SwapBuildings(GarrisonBuildingPlacer.info.plotID, self.plotID);
		GarrisonBuildingPlacer_Clear();
		return;
	end
	
	local confirmation = GarrisonBuildingFrame.Confirmation;
	if (self.buildingID) then
		GarrisonBuildingFrameConfirmation_SetContext("replace")
		confirmation.oldPlotID = self.plotID;
	else
		C_Garrison.PlaceBuilding(self.plotID, GarrisonBuildingPlacer.info.buildingID);
		GarrisonBuildingPlacer_Clear();
		return;
	end
	local _, _, currencyTexture = GetCurrencyInfo(GARRISON_CURRENCY);
	confirmation.Cost:SetText(GarrisonBuildingPlacer.info.cost.."  |T"..currencyTexture..":0:0:0:-1|t ");
	confirmation.Time:SetText(GarrisonBuildingPlacer.info.buildTime);
	confirmation.plot = self;
	confirmation.buildingID = GarrisonBuildingPlacer.info.buildingID;
	confirmation:ClearAllPoints();
	confirmation:SetPoint("BOTTOM", self, "TOP", 0, 0);
	confirmation:Show();
	
	local id, name, texPrefix, icon = C_Garrison.GetBuildingInfo(GarrisonBuildingPlacer.info.buildingID)
	GarrisonPlot_SetBuilding(self, id, name, texPrefix, icon);
	
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
		return;
	end
	GarrisonBuildingList_Show();	
	GarrisonBuildingList_SelectTab(BUILDING_TABS[categoryID]);
	
	GarrisonBuildingFrame.InfoBox.UpgradeButton:Hide();
	GarrisonBuildingFrame_ClearPlotHighlights();
	self.PlotHighlight:Show();
	GarrisonPlot_ShowTooltip(self);
	
	if (self.buildingID) then
		GarrisonBuildingList_SelectBuilding(self.buildingID);
		return;
	end
	
	local buildings = C_Garrison.GetBuildingsForPlot(self.plotID);
	if (#buildings == 1) then
		for i=1, #list.Buttons do
			local Button = list.Buttons[i];
			if (Button.info.buildingID == buildings[1]) then
				Button:Click();
				return;
			end
		end
	end
	GarrisonBuildingInfoBox_ShowDefault();
end

function GarrisonPlot_ShowTooltip(self)
	if (self.buildingID) then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
		GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true);
	else
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
		GameTooltip:SetText(GARRISON_EMPTY_PLOT);
		if (self.PlotHighlight:IsShown()) then
			GameTooltip:AddLine(GARRISON_EMPTY_PLOT_SELECTED_TOOLTIP, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		else
			GameTooltip:AddLine(GARRISON_EMPTY_PLOT_HOVER_TOOLTIP, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		end
		GameTooltip:Show();
	end
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
		local id, name, texPrefix, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade = C_Garrison.GetOwnedBuildingInfoAbbrev(plotID);
		GarrisonPlot_SetBuilding(plot, id, tooltip, texPrefix, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade)
	end
end

function GarrisonPlot_SetBuilding(self, id, tooltip, texPrefix, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade)
	GarrisonPlot_ClearBuilding(self);
	self.buildingID = id;
	if (canActivate) then
		self.tooltip = GARRISON_FINALIZE_BUILDING_TOOLTIP
	else
		self.tooltip = tooltip;
	end
	if (icon) then
		SetPortraitToTexture(self.Icon, icon);
		self.Icon:Show();
		self.Icon:SetDesaturated(self.greyedOut);
		self.IconRing:Show();
		self.IconRing:SetDesaturated(self.greyedOut);
	end
	if (texPrefix) then
		self.Building:SetAtlas(texPrefix.."_Map", true);
		self.BuildingHighlight:SetAtlas(texPrefix.."_Map", true);
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
	self.ReplaceButton:Hide();
	self.SwitchButton:Hide();
	self.CostLabel:SetText(COSTS_LABEL);
	self.TimeLabel:SetText(TIME_LABEL);
	if (context == "build") then
		self.BuildButton:Show();
		self.Icon:SetAtlas("Garr_BuildIcon", true);
	elseif (context == "upgrade") then
		self.UpgradeButton:Show();
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
	
	local id, name, texPrefix, icon, rank, currencyID, currencyQty, buildTime = C_Garrison.GetBuildingUpgradeInfo(building.buildingID)
	
	local Plot = GarrisonBuildingFrame.plots[building.plotID];
	
	local confirmation = GarrisonBuildingFrame.Confirmation;
	GarrisonBuildingFrameConfirmation_SetContext("upgrade");
	confirmation.plotID = building.plotID;
	confirmation.buildingID = id;
	confirmation.oldPlotID = building.plotID;
	confirmation.plot = Plot
	local _, _, currencyTexture = GetCurrencyInfo(currencyID);
	confirmation.Cost:SetText(currencyQty.."  |T"..currencyTexture..":0:0:0:-1|t ");
	confirmation.Time:SetText(buildTime);
	confirmation:ClearAllPoints();
	confirmation:SetPoint("BOTTOM", Plot, "TOP", 0, 0);
	confirmation:Show();
	
	GarrisonPlot_SetBuilding(Plot, id, name, texPrefix, icon);
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

function GarrisonBuildingFrame_ConfirmReplace()
	
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
	local _, _, currencyTexture = GetCurrencyInfo(GarrisonBuildingFrame.SPEC_CHANGE_CURRENCY);
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
	[1] = { ButtonPos = { x = 135,	y = -102 },  HighLightBox = { x = 10, y = -15, width = 285, height = 590 },	 ToolTipDir = "DOWN",  ToolTipText = "Drag unlocked buildings from this list to the yellow circles on the map. \n \nBuildings can only go in the correct plot size on the map." },
	[2] = { ButtonPos = { x = 650, y = -420 }, HighLightBox = { x =310, y = -185, width = 630, height = 420 }, ToolTipDir = "UP",   ToolTipText = "Drag buildings to the yellow circles on the map to start construction." },
	[3] = { ButtonPos = { x = 450, y = -70 },  HighLightBox = { x = 310, y = -15, width = 630, height = 160 },  ToolTipDir = "RIGHT",  ToolTipText = "Build costs and information is displayed here for the selected building. \n \nYou can select buildings from the list or the map." },
}


function GarrisonBuilding_ToggleTutorial()
	local helpPlate = GarrisonBuilding_HelpPlate;
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, GarrisonBuildingFrame, GarrisonBuildingFrame.MainHelpButton, true );
		SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true );
	else
		HelpPlate_Hide(true);
	end
end
