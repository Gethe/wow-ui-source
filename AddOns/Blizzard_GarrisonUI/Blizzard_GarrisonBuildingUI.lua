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
		tab.categoryID = tabInfo[i].id;
		BUILDING_TABS[tabInfo[i].id] = tab;
		tab.Text:SetText(tabInfo[i].name);
		
		tab.buildings = C_Garrison.GetBuildingsForSize(tab.categoryID);
	end
	
	--get buildings owned
	local buildings = C_Garrison.GetBuildings();
	--add instance IDs for owned buildings to the corresponding building buttons
	for i = 1, #buildings do
		local building = buildings[i];
		local tab = BUILDING_TABS[building.uiTab];
		for j = 1, #tab.buildings do
			if (tab.buildings[j].buildingID == building.buildingID) then
				tab.buildings[j].plotID = building.plotID;
			end
		end
	end
	
	--get plots
	GarrisonBuildingFrame_UpdatePlots();
	
	for i = 1, GARRISON_MAX_BUILDING_LEVEL do
		self.InfoBox.Tooltip["Rank"..i]:SetFormattedText(GARRISON_CURRENT_LEVEL, i);
	end
	
	GarrisonBuildingFrame_UpdateCurrency();
	
	self:RegisterEvent("GARRISON_UPDATE");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GARRISON_BUILDING_UPDATE");
	self:RegisterEvent("GARRISON_BUILDING_PLACED");
	self:RegisterEvent("GARRISON_BUILDING_REMOVED");
	self:RegisterEvent("GARRISON_BUILDING_LIST_UPDATE");
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATED");
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE");
end

function GarrisonBuildingFrame_OnShow(self)
	GarrisonBuildingFrame_UpdateGarrisonInfo(self);
	if (not IsTutorialFlagged(66)) then
		GarrisonBuildingFrame.BuildingList.Tab3:Click();
		GarrisonBuildingList_SelectBuilding(BARRACKS_BUILDING_ID);
		GarrisonBarracksTutorialBox:Show();
	else
		GarrisonBuildingFrame.BuildingList.Tab1:Click();
	end
end

function GarrisonBuildingFrame_OnEvent(self, event, ...)
	if (event == "GARRISON_UPDATE") then
		GarrisonBuildingFrame_UpdateGarrisonInfo(self);
	elseif (event == "CURRENCY_DISPLAY_UPDATE") then
		GarrisonBuildingFrame_UpdateCurrency();
	elseif (event == "GARRISON_BUILDING_UPDATE") then
		local buildingID = ...;
		local building = GarrisonBuildingFrame.selectedBuilding;
		if (buildingID == building.info.buildingID) then
			if (building.plotID) then
				GarrisonBuildingInfoBox_ShowBuilding(building.plotID, true);
			else
				GarrisonBuildingInfoBox_ShowBuilding(building.info.buildingID, false);
			end
		end
	elseif (event == "GARRISON_BUILDING_PLACED") then
		local plotID = ...;
		local id, name, texPrefix, icon = C_Garrison.GetOwnedBuildingInfo(plotID);
		if (id) then
			local Plot = self.plots[plotID];
			if (not Plot) then
				return;
			end
			local isBuilding, canActivate = C_Garrison.GetBuildingActivationInfo(plotID);
			GarrisonPlot_SetBuilding(Plot, id, name, texPrefix, icon, isBuilding);
			local building = GarrisonBuildingFrame.selectedBuilding;
			if (building and id == building.info.buildingID) then
				GarrisonBuildingInfoBox_ShowBuilding(plotID, true);
			end
			if (canActivate) then
				self.Activation.plotID = plotID;
				GarrisonBuildingFrame_UpdateActivation();
			end
		end
	elseif (event == "GARRISON_BUILDING_REMOVED") then
		local plotID, buildingID = ...;
		local Plot = self.plots[plotID];
		if (not Plot) then
			return;
		end
		GarrisonPlot_ClearBuilding(Plot);
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
						buildingID = self.selectedBuilding.info.buildingID;
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
			Plot.BuildIcon:Hide();
		end
		local building = GarrisonBuildingFrame.selectedBuilding;
		if (building and buildingID == building.info.buildingID) then
			GarrisonBuildingInfoBox_ShowBuilding(plotID, true);
		end
	elseif (event == "GARRISON_BUILDING_ACTIVATABLE") then
		local buildings = C_Garrison.GetActivatableBuildings();
		if (#buildings > 0) then
			self.Activation.plotID = buildings[1];
			buildings[1] = buildings[#buildings];
			buildings[#buildings] = nil;
			self.activatableBuildings = buildings
			GarrisonBuildingFrame_UpdateActivation();
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
		local id, name, texPrefix, icon = C_Garrison.GetOwnedBuildingInfo(plot.id)
		if (id) then
			GarrisonPlot_SetBuilding(Plot, id, name, texPrefix, icon);
		end
		Plot:Show();
		GarrisonBuildingFrame.plots[plot.id] = Plot;
		prevPlot = GarrisonBuildingFrame.MapFrame.Plots[i];
	end
end

function GarrisonBuildingFrame_UpdateGarrisonInfo(self)
	local level, mapTexture = C_Garrison.GetGarrisonInfo();
	self.level = level;
	self.MapFrame.Map:SetAtlas(mapTexture);
	self.MapFrame.TownHall.Level:SetText(level);
	self.MapFrame.TownHall.Building:SetAtlas("GarrBuilding_TownHall_"..level.."_A_Map", true);
	GarrisonBuildingFrame_UpdatePlots();
end

function GarrisonBuildingFrame_UpdateCurrency()
	local materialsText = GarrisonBuildingFrame.BuildingList.MoneyFrame.Materials;
	
	local currencyName, amount, currencyTexture = GetCurrencyInfo(GARRISON_CURRENCY);
	materialsText:SetText(amount.."  |T"..currencyTexture..":0:0:0:-1|t ");
end

function GarrisonTownHall_OnClick(self)
	GarrisonBuildingFrame.InfoBox:Hide();
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
	
	infoBox.Building:SetAtlas(EMPTY_PLOT_ATLAS, true)
	infoBox.Building:SetDesaturated(false);
	infoBox.Title:SetText(GARRISON_EMPTY_PLOT);
	infoBox.Description:SetText(GARRISON_EMPTY_PLOT_EXPLANATION);
end

function GarrisonBuildingInfoBox_ShowBuilding(ID, owned)
	GarrisonBuildingFrame.TownHallBox:Hide();
	if (not ID or ID == 0) then
		return;
	end
	local infoBox = GarrisonBuildingFrame.InfoBox;
	infoBox:Show()
	local id, name, texPrefix, icon, description, rank, currencyID, currencyQty, buildTime, needsPlan, possSpecs, upgrades, canUpgrade, knownSpecs, currSpec, isBuilding;
	if (owned) then
		id, name, texPrefix, icon, description, rank, currencyID, currencyQty, buildTime, needsPlan, possSpecs, upgrades, canUpgrade, knownSpecs, currSpec, isBuilding = C_Garrison.GetOwnedBuildingInfo(ID);
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
			infoBox.UpgradeGlow:Show();
			infoBox.UpgradeAnim:Play();
		else
			infoBox.UpgradeBadge:SetAtlas(LOCKED_UPGRADE_ATLAS, true);
		end
		infoBox.UpgradeBadge:Show();
	else
		infoBox.UpgradeBadge:Hide();
	end
	
	if (description and description ~= "") then
		infoBox.Description:SetText(description);
	end
	if (texPrefix) then
		infoBox.Building:SetAtlas(texPrefix.."_Info", true);
	end
	
	if (isBuilding) then
		infoBox.BuildIcon:Show();
	else
		infoBox.BuildIcon:Hide();
	end
	
	if (needsPlan) then
		infoBox.CostBar:Hide();
		infoBox.PlansNeeded:Show();
		infoBox.Building:SetDesaturated(true);
	else
		infoBox.PlansNeeded:Hide();
		infoBox.CostBar:Show();
		local _, _, currencyTexture = GetCurrencyInfo(currencyID);
		infoBox.CostBar.Cost:SetText(currencyQty.."  |T"..currencyTexture..":0:0:0:-1|t ");
		infoBox.CostBar.Time:SetText(buildTime);
		infoBox.Building:SetDesaturated(false);
	end
	
	if (owned) then
		infoBox.CostBar:Hide();
	end
	
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
			if (knownSpecs) then
				for j=1, #knownSpecs do
					if (knownSpecs[i] == possSpecs[i]) then
						spec:Enable();
						break;
					end
				end
			end
			if (not spec:IsEnabled()) then
				spec.Icon:SetDesaturated(true);
				spec.tooltip = spec.tooltip.."\n\n"..RED_FONT_COLOR_CODE.."You must learn this specialization before you can activate it"..FONT_COLOR_CODE_CLOSE
			else
				spec.Icon:SetDesaturated(false);
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

-----------------------------------------------------------------------
-- Building List stuff
-----------------------------------------------------------------------

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
		GarrisonBuildingFrame.selectedBuilding.SelectedBG:Hide()
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
	if (GarrisonBuildingFrame.selectedBuilding) then
		GarrisonBuildingFrame.selectedBuilding.SelectedBG:Hide();
	end
	GarrisonBuildingFrame.selectedBuilding = self;
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
end

function GarrisonBuildingListButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.info.name);
	local tooltip = C_Garrison.GetBuildingTooltip(self.info.buildingID);
	if (tooltip and tooltip ~= "") then
		GameTooltip:AddLine("")
		GameTooltip:AddLine(tooltip, 1, 1, 1, true);
	end
	GameTooltip:Show();
end

function GarrisonBuildingListButton_OnDragStart(self, button)
	if (button ~= "LeftButton") then
		return;
	end
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
		or not self.plotID or self.buildingID) then
		return;
	end
	PlaySoundKitID(40998);
	local confirmation = GarrisonBuildingFrame.BuildConfirmation;
	if (confirmation.plot) then
		GarrisonPlot_ClearBuilding(confirmation.plot);
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
	self.Bang:Show()
	
	GarrisonBuildingPlacer_Clear();
end

function GarrisonPlot_OnClick(self)
	if (not self.plotID) then
		return;
	end
	
	local list = GarrisonBuildingFrame.BuildingList;
	
	local categoryID = C_Garrison.GetTabForPlot(self.plotID);
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
	self.Bang:Hide();
	self.UpgradeBang:Hide();
	self.BuildIcon:Hide();
end

function GarrisonPlot_SetBuilding(self, id, name, texPrefix, icon, isBuilding)
	GarrisonPlot_ClearBuilding(self);
	self.buildingID = id;
	self.name = name;
	if (icon) then
		SetPortraitToTexture(self.Icon, icon);
		self.Icon:Show();
		self.IconRing:Show();
	end
	if (texPrefix) then
		self.Building:SetAtlas(texPrefix.."_Map", true);
		self.Building:Show();
	end
	
	if (isBuilding) then
		self.BuildIcon:Show();
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
-- Building/Upgrading of Buildings stuff
-----------------------------------------------------------------------

function GarrisonBuildingFrame_ConfirmBuild()
	local confirmation = GarrisonBuildingFrame.BuildConfirmation;
	if (not confirmation.plot or not confirmation.buildingID) then
		GarrisonBuildingFrame_ClearConfirmation();
		return;
	end
	PlaySoundKitID(40999);
	C_Garrison.PlaceBuilding(confirmation.plot.plotID, confirmation.buildingID);
	if (confirmation.buildingID == BARRACKS_BUILDING_ID) then
		TriggerTutorial(66);
	end
	GarrisonBuildingFrame_ClearConfirmation();
end

function GarrisonBuildingFrame_StartUpgrade(self)
	local building = GarrisonBuildingFrame.selectedBuilding;
	if (not building.info.plotID or not building.info.buildingID) then
		return;
	end
	
	local id, name, texPrefix, icon, rank, currencyID, currencyQty, buildTime = C_Garrison.GetBuildingUpgradeInfo(building.info.buildingID)
	
	local Plot = GarrisonBuildingFrame.plots[building.info.plotID];
	
	local confirmation = GarrisonBuildingFrame.UpgradeConfirmation;
	confirmation.plotID = building.info.plotID;
	confirmation.buildingID = id;
	confirmation.oldBuilding = building.info;
	confirmation.oldBuilding.texPrefix = Plot.Building:GetAtlas();
	confirmation.plot = Plot
	local _, _, currencyTexture = GetCurrencyInfo(GARRISON_CURRENCY);
	confirmation.Cost:SetText(currencyQty.."  |T"..currencyTexture..":0:0:0:-1|t ");
	confirmation.Time:SetText(buildTime);
	confirmation:ClearAllPoints();
	confirmation:SetPoint("BOTTOM", Plot, "TOP", 0, 0);
	confirmation:Show();
	
	GarrisonPlot_SetBuilding(Plot, id, name, texPrefix, icon);
	Plot.UpgradeBang:Show();
end

function GarrisonBuildingFrame_ConfirmUpgrade()
	local confirmation = GarrisonBuildingFrame.UpgradeConfirmation;
	if (not confirmation.plotID) then
		GarrisonBuildingFrame_ClearConfirmation(confirmation);
		return;
	end
	
	PlaySoundKitID(40999);
	C_Garrison.UpgradeBuilding(confirmation.plotID);
	confirmation.oldBuilding = nil;
	GarrisonBuildingFrame_ClearConfirmation();
end

function GarrisonBuildingFrame_ClearConfirmation()
	local confirmation = GarrisonBuildingFrame.BuildConfirmation;
	if (confirmation.plot) then
		GarrisonPlot_ClearBuilding(confirmation.plot);
		confirmation.plot = nil;
		confirmation.buildingID = nil;
		confirmation:Hide();
	end
	
	local confirmation = GarrisonBuildingFrame.UpgradeConfirmation;
	if (confirmation.plot) then
		if (confirmation.oldBuilding) then
			local info = confirmation.oldBuilding
			GarrisonPlot_SetBuilding(confirmation.plot, info.name, info.buildingID, info.texPrefix, info.icon);
		end
		confirmation.plot = nil;
		confirmation.buildingID = nil;
		confirmation:Hide();
	end
end

function GarrisonBuildingFrame_UpdateActivation()
	local self = GarrisonBuildingFrame.Activation;
	if (not self.plotID) then
		self:Hide();
		return;
	end
	
	local id, name, texPrefix, icon, _, rank = C_Garrison.GetOwnedBuildingInfo(self.plotID);
	if (not id) then
		self.plotID = nil;
		self:Hide();
		return;
	end
	
	if (rank > 1) then
		self.Title:SetText(GARRISON_UPGRADE_COMPLETE);
		self.UpgradeBadge:SetAtlas("Garr_LevelBadge_"..rank, true);
		self.UpgradeBadge:Show();
		self.LevelUpText:Show();
		self.UpgradeBanner:Show();
	else
		self.Title:SetText(GARRISON_BUILDING_COMPLETE);
		self.UpgradeBadge:Hide();
		self.LevelUpText:Hide();
		self.UpgradeBanner:Hide();
	end
	self.Building:SetAtlas(texPrefix.."_Info", false);
	self.Name:SetText(name);
	self:Show();
end

function GarrisonBuildingFrame_ActivateBuilding()
	local self = GarrisonBuildingFrame.Activation;
	if (not self.plotID) then
		self:Hide();
		return;
	end
	
	C_Garrison.SetBuildingActive(self.plotID);
	
	local buildings = GarrisonBuildingFrame.activatableBuildings;
	if (buildings and #buildings > 0) then
		self.plotID = buildings[1];
		buildings[1] = buildings[#buildings];
		buildings[#buildings] = nil;
		GarrisonBuildingFrame.activatableBuildings = buildings;
		GarrisonBuildingFrame_UpdateActivation();
	else
		GarrisonBuildingFrame.activatableBuildings = nil;
		self.plotID = nil;
		self:Hide();
	end
	
end

-----------------------------------------------------------------------
-- Building Specialization stuff
-----------------------------------------------------------------------

function GarrisonBuildingSpec_OnClick(self, button)
	if (not GarrisonBuildingFrame.selectedBuilding or not GarrisonBuildingFrame.selectedBuilding.info.plotID) then
		return;
	end
	C_Garrison.SetBuildingSpecialization(GarrisonBuildingFrame.selectedBuilding.info.plotID, self.id);
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
