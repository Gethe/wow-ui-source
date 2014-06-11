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
	
	for i = 1, GARRISON_MAX_BUILDING_LEVEL do
		self.InfoBox.Tooltip["Rank"..i]:SetFormattedText(GARRISON_CURRENT_LEVEL, i);
	end
	
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
		local id, name, texPrefix, icon, rank, isBuilding, timeLeft, canActivate = C_Garrison.GetOwnedBuildingInfoAbbrev(plotID);
		GarrisonPlot_SetBuilding(Plot, id, name, texPrefix, icon, rank, isBuilding, timeLeft, canActivate);
	elseif (event == "GARRISON_BUILDING_PLACED") then
		local plotID = ...;
		local id, name, texPrefix, icon, rank, isBuilding, timeLeft, canActivate = C_Garrison.GetOwnedBuildingInfoAbbrev(plotID);
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
			GarrisonPlot_SetBuilding(Plot, id, name, texPrefix, icon, rank, isBuilding, timeLeft, canActivate);
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
	local prevPlot;
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
		Plot.PlotHighlight:SetAtlas("Garr_Plot_Glow_"..plot.size, true);
		Plot.Lock:Hide();
		Plot.locked = false;
		local id, name, texPrefix, icon, rank, isBuilding, timeLeft, canActivate, canUpgrade = C_Garrison.GetOwnedBuildingInfoAbbrev(plot.id);
		if (id) then
			GarrisonPlot_SetBuilding(Plot, id, name, texPrefix, icon, rank, isBuilding, timeLeft, canActivate, canUpgrade);
		elseif (plot.buildingID) then
			GarrisonPlot_SetBuilding(Plot, plot.buildingID, "Complete a quest to unlock this building", plot.building, plot.icon);
			Plot.locked = true;
			Plot.Lock:Show();
		else
			GarrisonPlot_ClearBuilding(Plot);
		end
		Plot:Show();
		GarrisonBuildingFrame.plots[plot.id] = Plot;
		prevPlot = GarrisonBuildingFrame.MapFrame.Plots[i];
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
	infoBox.RemoveFollowerButton:Hide();

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
	local id, name, texPrefix, icon, description, rank, currencyID, currencyQty, buildTime, needsPlan, possSpecs, upgrades, canUpgrade, isMaxLevel, knownSpecs, currSpec, specCooldown, isBuilding, timeLeft, canActivate, hasFollower;
	if (owned) then
		id, name, texPrefix, icon, description, rank, currencyID, currencyQty, buildTime, needsPlan, possSpecs, upgrades, canUpgrade, isMaxLevel, knownSpecs, currSpec, specCooldown, isBuilding, timeLeft, canActivate, hasFollower = C_Garrison.GetOwnedBuildingInfo(ID);
	else
		id, name, texPrefix, icon, description, rank, currencyID, currencyQty, buildTime, needsPlan, possSpecs, upgrades, canUpgrade = C_Garrison.GetBuildingInfo(ID);
	end
	if (name == nil) then
		return;
	end
	infoBox.Title:SetText(name);
	infoBox.RankBadge:SetAtlas("Garr_LevelBadge_"..rank);
	infoBox.RankBadge:Show();
	infoBox.RankLabel:Show();
	
	--upgrade stuff
	infoBox.UpgradeButton:Hide();
	infoBox.UpgradeAnim:Stop();
	infoBox.UpgradeGlow:Hide();
	if (owned and not isBuilding and upgrades and #upgrades > 0 and rank ~= #upgrades) then
		if (canUpgrade) then
			infoBox.UpgradeBadge:SetAtlas(CAN_UPGRADE_ATLAS, true);
			infoBox.UpgradeButton.upgradePlotID = ID;
			infoBox.UpgradeButton:Show();
			if (not isMaxLevel) then
				infoBox.UpgradeButton:Enable();
				infoBox.UpgradeButton.tooltip = nil;
				infoBox.UpgradeGlow:Show();
				infoBox.UpgradeAnim:Play();
			else
				infoBox.UpgradeButton:Disable();
				infoBox.UpgradeButton.tooltip = GARRISON_UPGRADE_ERROR;
			end
		else
			infoBox.UpgradeBadge:SetAtlas(LOCKED_UPGRADE_ATLAS, true);
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
			infoBox.TimeLeft:Show();
			infoBox.TimeLeft:SetText(buildTime);
			infoBox.Timer.CompleteRing:Hide();
			infoBox.Timer.Glow:Hide();
			infoBox.Timer.Cooldown:SetCooldownDuration(timeLeft);
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
	
	--tooltip
	GarrisonBuildingInfoBox_SetTooltip(infoBox.Tooltip, name, rank, upgrades, canUpgrade, owned)
	
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
	
	--follower placement
	if (not hasFollower) then
		infoBox.AddFollowerButton:Hide();
		infoBox.RemoveFollowerButton:Hide();
		return;
	end
	
	infoBox.AddFollowerButton:Show();
	local followerName, level, quality, displayID = C_Garrison.GetFollowerInfoForBuilding(ID);
	if (followerName) then
		infoBox.AddFollowerButton.Plus:Hide();
		infoBox.AddFollowerButton.Level:Show();
		infoBox.AddFollowerButton.Level:SetText(level);
		local color = ITEM_QUALITY_COLORS[quality];
    	infoBox.AddFollowerButton.LevelBorder:SetVertexColor(color.r, color.g, color.b);
		SetPortraitTexture(infoBox.AddFollowerButton.Portrait, displayID);
		infoBox.RemoveFollowerButton:Show();
	else
		infoBox.AddFollowerButton.Plus:Show();
		infoBox.AddFollowerButton.Level:Hide();
		infoBox.AddFollowerButton.LevelBorder:SetVertexColor(1, 1, 1);
		SetPortraitTexture(infoBox.AddFollowerButton.Portrait, 0);
		infoBox.RemoveFollowerButton:Hide();
	end
end

function GarrisonBuildingInfoBox_SetTooltip(self, name, rank, upgrades, canUpgrade, owned)
	
	self.Name:SetText(name);
	
	if (not upgrades or #upgrades == 0) then
		return;
	end
	
	self.Rank1Tooltip:SetVertexColor(0.5, 0.5, 0.5, 1);
	self.Rank2Tooltip:SetVertexColor(0.5, 0.5, 0.5, 1);
	self.Rank3Tooltip:SetVertexColor(0.5, 0.5, 0.5, 1);
	if (owned) then
		for i=1, rank do
			self["Rank"..i.."Tooltip"]:SetVertexColor(1, 1, 1, 1);
		end
	end
	
	local height = self.Name:GetHeight() + 30; --15 pixels of padding on top and bottom
	for i=1, #upgrades do
		local tooltip = C_Garrison.GetBuildingTooltip(upgrades[i]);
		if (tooltip == "") then 
			tooltip = nil 
		end
		if (owned and i == (rank + 1) and not canUpgrade) then
			self["Rank"..i.."Tooltip"]:SetText((tooltip or "This is a TOOLTIP!").."\n"..RED_FONT_COLOR_CODE..GARRISON_PLAN_REQUIRED..FONT_COLOR_CODE_CLOSE);
		else
			self["Rank"..i.."Tooltip"]:SetText(tooltip or "This is a TOOLTIP!");
		end
		self["Rank"..i.."Tooltip"]:Show();
		self["Rank"..i]:Show();
		--10 pixels padding above rank title, 5 pixes above rank tooltip
		height = height + self["Rank"..i.."Tooltip"]:GetHeight() + self["Rank"..i]:GetHeight() + 15;
	end
	self:SetHeight(height);
	
	for i=#upgrades+1, 3 do
		self["Rank"..i.."Tooltip"]:Hide();
		self["Rank"..i]:Hide();
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
-----------------------------------------------------------------------
-- Placing followers stuff
-----------------------------------------------------------------------

function GarrisonBuildingAddFollowerButton_OnClick(self, button)
	if (GarrisonBuildingFrame.FollowerList:IsShown()) then
		GarrisonBuildingList_Show();
	else
		GarrisonBuildingFrame.FollowerList:Show();
		GarrisonBuildingFrame.BuildingList:Hide();
	end
end

function GarrisonBuildingFollowerList_OnShow(self)
	self.followers = C_Garrison.GetPossibleFollowersForBuilding(GarrisonBuildingFrame.selectedBuilding.plotID);
	GarrisonBuildingFollowerList_Update();
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
			SetPortraitTexture(button.PortraitFrame.Portrait, follower.displayID);
			button.PortraitFrame.Level:SetText(follower.level);
			--show iLevel for max level followers
			if (follower.level < 100) then
				button.Name:SetHeight(0);
				button.Name:SetPoint("LEFT", button, "TOPLEFT", 66, -28);
				button.ILevel:SetText(nil);
				button.Status:ClearAllPoints();
				button.Status:SetPoint("TOPLEFT", button.Name, "BOTTOMLEFT", 0, -2)
			else
				button.Name:SetHeight(10);
				button.Name:SetPoint("TOPLEFT", button, "TOPLEFT", 66, -13);
				button.ILevel:SetText(ITEM_LEVEL_ABBR.." "..follower.iLevel);
				button.Status:ClearAllPoints();
				button.Status:SetPoint("TOPLEFT", button.ILevel, "BOTTOMLEFT", 0, -3)
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
	
	--clear old building selection
	if (GarrisonBuildingFrame.selectedBuilding) then
		if (GarrisonBuildingFrame.selectedBuilding.button) then
			GarrisonBuildingFrame.selectedBuilding.button.SelectedBG:Hide()
		end
		GarrisonBuildingFrame.selectedBuilding = nil;
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
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.info.name);
	local tooltip, cost, currencyID, buildTime = C_Garrison.GetBuildingTooltip(self.info.buildingID);
	if (tooltip and tooltip ~= "") then
		GameTooltip:AddLine(tooltip, 1, 1, 1, true);
	end
	if (cost) then
		GameTooltip:AddLine(" ")
		if (self.info.plotID) then
			GameTooltip:AddLine(UPGRADE, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		end
		local _, _, currencyTexture = GetCurrencyInfo(currencyID);
		GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..COSTS_LABEL..FONT_COLOR_CODE_CLOSE.." "..cost.."  |T"..currencyTexture..":0:0:0:-1|t ", 1, 1, 1, true);
		GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..TIME_LABEL..FONT_COLOR_CODE_CLOSE.." "..buildTime, 1, 1, 1, true);
	end
	GameTooltip:Show();
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
	GarrisonBuildingPlacer.Building:SetTexture(nil);
	GarrisonBuildingPlacer.Icon:SetTexture(nil);
	GarrisonBuildingPlacer.info = nil;
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

function GarrisonPlot_OnReceiveDrag(self)
	if (not GarrisonBuildingPlacer:IsShown() or not GarrisonBuildingPlacer.info.buildingID 
		or not self.plotID) then
		return;
	end
	PlaySoundKitID(40998);
	local confirmation = GarrisonBuildingFrame.Confirmation;
	if (self.buildingID) then
		GarrisonBuildingFrameConfirmation_SetContext("replace")
		local id, name, texPrefix, icon = C_Garrison.GetOwnedBuildingInfoAbbrev(self.plotID);
		confirmation.oldBuilding = {buildingID = self.buildingID, name = name, icon = icon, texPrefix = texPrefix};
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
	
	GarrisonBuildingFrame_ClearPlotHighlights();
	self.PlotHighlight:Show();
	
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

function GarrisonPlot_SetBuilding(self, id, tooltip, texPrefix, icon, rank, isBuilding, timeLeft, canActivate, canUpgrade)
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
		self.IconRing:Show();
	end
	if (texPrefix) then
		self.Building:SetAtlas(texPrefix.."_Map", true);
		self.BuildingHighlight:SetAtlas(texPrefix.."_Map", true);
		self.Building:Show();
	end
	
	if (canUpgrade) then
		self.UpgradeArrow:Show();
	end
	
	if (not isBuilding and not canActivate) then
		self.Timer:Hide();
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
		self.Timer.Cooldown:SetCooldownDuration(timeLeft);
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
	GarrisonBuildingFrameConfirmation_SetContext("upgrade")
	confirmation.plotID = building.plotID;
	confirmation.buildingID = id;
	confirmation.oldBuilding = building;
	local _, _, oldTexPrefix = C_Garrison.GetOwnedBuildingInfoAbbrev(building.plotID);
	confirmation.oldBuilding.texPrefix = oldTexPrefix;
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
	confirmation.oldBuilding = nil;
	GarrisonBuildingFrame_ClearConfirmation();
end

function GarrisonBuildingFrame_ConfirmReplace()
	
end

function GarrisonBuildingFrame_ClearConfirmation()
	local confirmation = GarrisonBuildingFrame.Confirmation;
	if (confirmation.plot) then
		if (confirmation.oldBuilding) then
			local info = confirmation.oldBuilding
			GarrisonPlot_SetBuilding(confirmation.plot, info.buildingID, info.name, info.texPrefix, info.icon);
			confirmation.oldBuilding = nil;
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
