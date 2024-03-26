GARRISON_FOLLOWER_MAX_LEVEL = 100;
GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY = {
	[Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower] = Enum.GarrFollowerQuality.Epic,
	[Enum.GarrisonFollowerType.FollowerType_6_0_Boat] = Enum.GarrFollowerQuality.Epic,
	[Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower] = Enum.GarrFollowerQuality.Title,
	[Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower] = Enum.GarrFollowerQuality.Legendary,
	[Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower] = Enum.GarrFollowerQuality.Common,
}

GARRISON_MISSION_NAME_FONT_COLOR	=	{r=0.78, g=0.75, b=0.73};
GARRISON_MISSION_TYPE_FONT_COLOR	=	{r=0.8, g=0.7, b=0.53};


---------------------------------------------------------------------------------
--- Main Frame                                                                ---
---------------------------------------------------------------------------------
GarrisonLandingPageMixin = { }
function GarrisonLandingPageMixin:OnLoad()
	self.selectedTab = 1;

	GarrisonLandingPage.Report:Show();
	GarrisonLandingPage.FollowerList:Hide();
	GarrisonLandingPage.FollowerList:SetSortFuncs(GarrisonFollowerList_DefaultSort, GarrisonFollowerList_InitializeDefaultSort);

	GarrisonLandingPage.FollowerTab:Hide();
	GarrisonLandingPage.ShipFollowerList:Hide();
	GarrisonLandingPage.ShipFollowerList:SetSortFuncs(GarrisonFollowerList_DefaultSort, GarrisonFollowerList_InitializeDefaultSort);
	GarrisonLandingPage.ShipFollowerTab:Hide();
end

function GarrisonLandingPageMixin:UpdateTabs()
	local numTabs = 2;
	if (self.garrTypeID == Enum.GarrisonType.Type_6_0_Garrison and C_Garrison.HasShipyard()) then
		numTabs = 3;
		self.FleetTab:Show();
	else
		self.FleetTab:Hide();
	end

	PanelTemplates_SetNumTabs(self, numTabs);
	PanelTemplates_UpdateTabs(self);

	if (self.garrTypeID == Enum.GarrisonType.Type_6_0_Garrison) then
		local fleetCount = C_Garrison.GetNumFollowers(Enum.GarrisonFollowerType.FollowerType_6_0_Boat);
		if (fleetCount == 0) then
			if (PanelTemplates_GetSelectedTab(self) == self.FleetTab:GetID()) then
				GarrisonLandingPageTab_SetTab(self.ReportTab);
			end
			PanelTemplates_DisableTab(self, 3);
		else
			PanelTemplates_EnableTab(self, 3);
		end
	else
		if (PanelTemplates_GetSelectedTab(self) == self.FleetTab:GetID()) then
			GarrisonLandingPageTab_SetTab(self.ReportTab);
		end
	end
end

function GarrisonLandingPageMixin:UpdateUIToGarrisonType()
	self:UpdateTabs();

	local shouldShowFollowerTab = not (self.garrTypeID == Enum.GarrisonType.Type_9_0_Garrison) or C_Garrison.HasAdventures();
	self.FollowerTabButton:SetShown(shouldShowFollowerTab);

	if (self.garrTypeID == Enum.GarrisonType.Type_6_0_Garrison) then
		if (C_Garrison.IsInvasionAvailable()) then
			self.InvasionBadge:Show();
			self.InvasionBadge.InvasionBadgeAnim:Play();
		else
			self.InvasionBadge:Hide();
		end
		self.Report.Background:SetAtlas("GarrLanding_Watermark-Tradeskill", true);
		self.Report.Background:ClearAllPoints();
		self.Report.Background:SetPoint("BOTTOMLEFT", 60, 40);
	elseif (self.garrTypeID == Enum.GarrisonType.Type_7_0_Garrison) then
		local _, className = UnitClass("player");
		self.Report.Background:SetAtlas("legionmission-landingpage-background-"..className, true);
		self.Report.Background:ClearAllPoints();
		self.Report.Background:SetPoint("BOTTOM", self.Report, "BOTTOMLEFT", 194, 54);
	elseif (self.garrTypeID == Enum.GarrisonType.Type_8_0_Garrison) then

		self.Report.Background:ClearAllPoints();
		self.Report.Background:SetPoint("BOTTOMLEFT", 100, 127);
		self.Report.Background:SetAtlas(("BfAMissionsLandingPage-Background-%s"):format(UnitFactionGroup("player")));
	elseif (self.garrTypeID == Enum.GarrisonType.Type_9_0_Garrison) then
		self:ResetSectionLayoutIndex();
		self:SetupCovenantTopPanel();
		self:SetupCovenantCallings();
		self:SetupGardenweald();
		self:LayoutSection();

		self.FollowerTabButton:SetText(COVENANT_MISSION_FOLLOWER_CATEGORY);
		self.FollowerList.LandingPageHeader:SetText(COVENANT_MISSION_FOLLOWER_CATEGORY);
		self.FollowerTab.FollowerText:Hide();
		self.FollowerTab.PortraitFrame:Hide();
		self.FollowerTab.CovenantFollowerPortraitFrame:Show();

		local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID());
		local textureKit = covenantData and covenantData.textureKit;
		self.Report.Background:SetShown(textureKit ~= nil);
		if textureKit then
			self.Report.Background:ClearAllPoints();
			self.Report.Background:SetPoint("BOTTOM", GarrisonLandingPageReport, "BOTTOMLEFT", 190, 110);
			self.Report.Background:SetAtlas(("ShadowlandsMissionsLandingPage-Background-%s"):format(textureKit), true);
		end
	end

	self.abilityCountersForMechanicTypes = C_Garrison.GetFollowerAbilityCountersForMechanicTypes(GetPrimaryGarrisonFollowerType(self.garrTypeID));
	GarrisonThreatCountersFrame:SetParent(self.FollowerTab);
	GarrisonThreatCountersFrame:SetPoint("TOPRIGHT", -152, 30);
end

function GarrisonLandingPageMixin:OnShow()
	self:UpdateUIToGarrisonType();

	if self.garrTypeID == Enum.GarrisonType.Type_9_0_Garrison then
	    PlaySound(SOUNDKIT.UI_GARRISON_9_0_OPEN_LANDING_PAGE);
	else
	    PlaySound(SOUNDKIT.UI_GARRISON_GARRISON_REPORT_OPEN);
	end

	self:RegisterEvent("GARRISON_HIDE_LANDING_PAGE");
	self:RegisterEvent("COVENANT_CHOSEN");
end

function GarrisonLandingPageMixin:OnHide()
    if self.garrTypeID == Enum.GarrisonType.Type_9_0_Garrison then
        PlaySound(SOUNDKIT.UI_GARRISON_9_0_CLOSE_LANDING_PAGE);
    else
        PlaySound(SOUNDKIT.UI_GARRISON_GARRISON_REPORT_CLOSE);
    end

	StaticPopup_Hide("CONFIRM_FOLLOWER_TEMPORARY_ABILITY");
	StaticPopup_Hide("CONFIRM_FOLLOWER_UPGRADE");
	StaticPopup_Hide("CONFIRM_FOLLOWER_ABILITY_UPGRADE");
	GarrisonBonusAreaTooltip:Hide();
	self.abilityCountersForMechanicTypes = nil;

	self:UnregisterEvent("GARRISON_HIDE_LANDING_PAGE");
	self:UnregisterEvent("COVENANT_CHOSEN");
end

function GarrisonLandingPageMixin:GetFollowerList()
	return self.FollowerList;
end

function GarrisonLandingPageMixin:GetShipFollowerList()
	return self.ShipFollowerList;
end

function GarrisonLandingPageMixin:ResetSectionLayoutIndex()
	self.sectionsLayoutIndex = 1;
end

function GarrisonLandingPageMixin:SetSectionLayoutIndex(frame)
	if frame then
		frame.layoutIndex = self.sectionsLayoutIndex or 1;
		self.sectionsLayoutIndex = frame.layoutIndex + 1;
	end
end

function GarrisonLandingPageMixin:LayoutSection()
	self.Report.Sections:Layout();
end

function GarrisonLandingPageMixin:SetupCovenantCallings()
	if not self.CovenantCallings then
		if UIParentLoadAddOn("Blizzard_CovenantCallings") then
			self.CovenantCallings = CovenantCallings.Create(self.Report.Sections);
			self.CovenantCallings.topPadding = -10;
		end
	end

	self:SetSectionLayoutIndex(self.CovenantCallings);
	self.CovenantCallings:Update();
end

function GarrisonLandingPageMixin:SetupCovenantTopPanel()
	if not self.SoulbindPanel then
		UIParentLoadAddOn("Blizzard_LandingSoulbinds");
		self.SoulbindPanel = LandingSoulbind.Create(self.Report.Sections);
	end

	self:SetSectionLayoutIndex(self.SoulbindPanel);
	self.SoulbindPanel:Update();
end

function GarrisonLandingPageMixin:SetupGardenweald()
	if C_ArdenwealdGardening.IsGardenAccessible() then
		if self.ArdenwealdGardeningPanel then
			self.ArdenwealdGardeningPanel:Show();
		elseif UIParentLoadAddOn("Blizzard_ArdenwealdGardening") then
			self.ArdenwealdGardeningPanel = ArdenwealdGardening.Create(self.Report.Sections);
		end
	elseif self.ArdenwealdGardeningPanel then
		self.ArdenwealdGardeningPanel:Hide();
	end

	self:SetSectionLayoutIndex(self.ArdenwealdGardeningPanel);
end

function GarrisonLandingPageMixin:OnEvent(event)
	if (event == "GARRISON_HIDE_LANDING_PAGE" or event == "COVENANT_CHOSEN") then
		HideUIPanel(self);
	end
end

---------------------------------------------------------------------------------
--- Shipyard Follower page
---------------------------------------------------------------------------------
GarrisonLandingPageShipyardFollowerMixin = { }

function GarrisonLandingPageShipyardFollowerMixin:GetFollowerList()
	-- in the landing page fleet tab, we'll get the ship follower list instead.
	return self:GetParent():GetShipFollowerList();
end



---------------------------------------------------------------------------------
--- Landing Page tabs
---------------------------------------------------------------------------------
function GarrisonLandingPageTab_OnClick(self)
	PlaySound(SOUNDKIT.UI_GARRISON_NAV_TABS);
	GarrisonLandingPageTab_SetTab(self);
end

function GarrisonLandingPageTab_SetTab(self)
	local id = self:GetID();
	PanelTemplates_SetTab(GarrisonLandingPage, id);
	if ( id == 1 ) then
		GarrisonLandingPage.Report:Show();
		GarrisonLandingPage.FollowerList:Hide();
		GarrisonLandingPage.FollowerTab:Hide();
		GarrisonLandingPage.ShipFollowerList:Hide();
		GarrisonLandingPage.ShipFollowerTab:Hide();
	elseif ( id == 2 ) then
		GarrisonLandingPage.Report:Hide();
		GarrisonLandingPage.FollowerList:Show();
		GarrisonLandingPage.FollowerTab:Show();
		GarrisonLandingPage.ShipFollowerList:Hide();
		GarrisonLandingPage.ShipFollowerTab:Hide();
	else
		GarrisonLandingPage.Report:Hide();
		GarrisonLandingPage.FollowerList:Hide();
		GarrisonLandingPage.FollowerTab:Hide();
		GarrisonLandingPage.ShipFollowerList:Show();
		GarrisonLandingPage.ShipFollowerTab:Show();
	end
end

---------------------------------------------------------------------------------
--- Report Page                                                          ---
---------------------------------------------------------------------------------

local function OnShipmentReleased(pool, shipmentFrame)
	FramePool_HideAndClearAnchors(pool, shipmentFrame);
	shipmentFrame.talent = nil;
	shipmentFrame.Done:Hide();
	shipmentFrame.Border:Show();
	shipmentFrame.BG:Hide();
	shipmentFrame.Count:SetText(nil);
	shipmentFrame.Swipe:Hide();
end

function GarrisonLandingPageReport_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("GarrisonLandingPageReportMissionTemplate", function(button, elementData)
		if GarrisonLandingPageReport.selectedTab == GarrisonLandingPageReport.InProgress then
			GarrisonLandingPageReportList_InitButton(button, elementData);
		else
			GarrisonLandingPageReportList_InitButtonAvailable(button, elementData);
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.List.ScrollBox, self.List.ScrollBar, view);

	self.shipmentsPool = CreateFramePool("FRAME", self, "GarrisonLandingPageReportShipmentStatusTemplate", OnShipmentReleased);
end

function GarrisonLandingPageReport_OnShow(self)
	-- Shipments
	C_Garrison.RequestLandingPageShipmentInfo();

	if ( not GarrisonLandingPageReport.selectedTab ) then
		-- SetTab flips the tabs, so set them up reversed & call SetTab
		GarrisonLandingPageReport.unselectedTab = GarrisonLandingPageReport.InProgress;
		GarrisonLandingPageReport.selectedTab = GarrisonLandingPageReport.Available;
		GarrisonLandingPageReport_SetTab(GarrisonLandingPageReport.unselectedTab);
	else
		GarrisonLandingPageReportList_UpdateItems()
	end

	self:RegisterEvent("GARRISON_LANDINGPAGE_SHIPMENTS");
	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:RegisterEvent("GARRISON_SHIPMENT_RECEIVED");
	self:RegisterEvent("GARRISON_TALENT_UPDATE");
	self:RegisterEvent("GARRISON_TALENT_COMPLETE");
end

function GarrisonLandingPageReport_OnHide(self)
	self:UnregisterEvent("GARRISON_LANDINGPAGE_SHIPMENTS");
	self:UnregisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:UnregisterEvent("GARRISON_SHIPMENT_RECEIVED");
	self:UnregisterEvent("GARRISON_TALENT_UPDATE");
	self:UnregisterEvent("GARRISON_TALENT_COMPLETE");
end

function GarrisonLandingPageReport_OnEvent(self, event)
	if ( event == "GARRISON_LANDINGPAGE_SHIPMENTS" or event == "GARRISON_TALENT_UPDATE" or event == "GARRISON_TALENT_COMPLETE") then
		GarrisonLandingPageReport_GetShipments(self);
	elseif ( event == "GARRISON_MISSION_LIST_UPDATE" or event == "GET_ITEM_INFO_RECEIVED" ) then
		GarrisonLandingPageReportList_UpdateItems();
	elseif ( event == "GARRISON_SHIPMENT_RECEIVED" ) then
		C_Garrison.RequestLandingPageShipmentInfo();
	end
end

function GarrisonLandingPageReport_OnUpdate(self)
	if ( GarrisonLandingPageReport.selectedTab == GarrisonLandingPageReport.InProgress ) then
		GarrisonLandingPageReportList_Update();
	end
end

---------------------------------------------------------------------------------
--- Report - Shipments                                                        ---
---------------------------------------------------------------------------------

local SHIPMENT_TYPE_BUILDING = 1;
local SHIPMENT_TYPE_FOLLOWER = 2;
local SHIPMENT_TYPE_TALENT = 3;
local SHIPMENT_TYPE_LOOSE = 4;

local function SetupShipment(shipmentFrame, texture, applyMask, name, buildingID, plotID, containerID, shipmentsReady, shipmentsTotal, creationTime, duration, shipmentType, index)
	if (applyMask) then
		SetPortraitToTexture(shipmentFrame.Icon, texture);
	else
		shipmentFrame.Icon:SetTexture(texture);
	end
	shipmentFrame.Name:SetText(name);
	shipmentFrame.buildingID = buildingID;
	shipmentFrame.containerID = containerID;
	shipmentFrame.plotID = plotID;
	shipmentFrame.shipmentType = shipmentType;
	if (shipmentsTotal) then
		if (shipmentType ~= SHIPMENT_TYPE_TALENT) then
			shipmentFrame.Count:SetFormattedText(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal);
		end
		if ( shipmentsReady == shipmentsTotal ) then
			shipmentFrame.Swipe:SetCooldownUNIX(0, 0);
			shipmentFrame.Done:Show();
			shipmentFrame.Border:Hide();
		else
			shipmentFrame.BG:Show();
			shipmentFrame.Swipe:SetCooldownUNIX(creationTime, duration);
		end
	end
	shipmentFrame:SetPoint("TOPLEFT", 60 + mod(index, 3) * 105, -105 - floor(index / 3) * 100);
	shipmentFrame:Show();
end

function GarrisonLandingPageReport_GetShipments(self)
	self.shipmentsPool:ReleaseAll();

	local shipmentIndex = 0;
	local maxShipments = 12;
	local garrisonType = self:GetParent().garrTypeID;
	local buildings = C_Garrison.GetBuildings(garrisonType);
	for i = 1, #buildings do
		local buildingID = buildings[i].buildingID;
		if ( buildingID) then
			local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemIcon, itemQuality, itemID = C_Garrison.GetLandingPageShipmentInfo(buildingID);
			if ( name and shipmentCapacity > 0 and shipmentIndex < maxShipments ) then
				local shipment = self.shipmentsPool:Acquire();
				SetupShipment(shipment, texture, true, name, buildingID, buildings[i].plotID, nil, shipmentsReady, shipmentsTotal, creationTime, duration, SHIPMENT_TYPE_BUILDING, shipmentIndex);
				shipmentIndex = shipmentIndex + 1;
			end
		end
	end

	local followerShipments = C_Garrison.GetFollowerShipments(garrisonType);
	for i = 1, #followerShipments do
		local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, _, _, _, _, followerID = C_Garrison.GetLandingPageShipmentInfoByContainerID(followerShipments[i]);
		if ( name and shipmentCapacity > 0 and shipmentIndex < maxShipments ) then
			local shipment = self.shipmentsPool:Acquire();
			SetupShipment(shipment, texture, false, name, nil, nil, followerShipments[i], shipmentsReady, shipmentsTotal, creationTime, duration, SHIPMENT_TYPE_FOLLOWER, shipmentIndex);
			shipmentIndex = shipmentIndex + 1;
		end
	end

	local looseShipments = C_Garrison.GetLooseShipments(garrisonType);
	for i = 1, #looseShipments do
		local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString = C_Garrison.GetLandingPageShipmentInfoByContainerID(looseShipments[i]);
		if ( name and shipmentCapacity > 0 and shipmentIndex < maxShipments ) then
			local shipment = self.shipmentsPool:Acquire();
			SetupShipment(shipment, texture, true, name, nil, nil, looseShipments[i], shipmentsReady, shipmentsTotal, creationTime, duration, SHIPMENT_TYPE_LOOSE, shipmentIndex);
			shipmentIndex = shipmentIndex + 1;
		end
	end

	local talentTreeIDs = C_Garrison.GetTalentTreeIDsByClassID(garrisonType, select(3, UnitClass("player")));
	-- this is a talent that has completed, but has not been seen in the talent UI yet.
	local completeTalentID = C_Garrison.GetCompleteTalent(garrisonType);
	if (talentTreeIDs) then
		for treeIndex, treeID in ipairs(talentTreeIDs) do
			local treeInfo = C_Garrison.GetTalentTreeInfo(treeID);
			for talentIndex, talent in ipairs(treeInfo.talents) do
				if talent.isBeingResearched or talent.id == completeTalentID then
					local shipment = self.shipmentsPool:Acquire();
					SetupShipment(shipment, talent.icon, true, talent.name, nil, nil, nil, talent.isBeingResearched and 0 or 1, 1, talent.startTime, talent.researchDuration, SHIPMENT_TYPE_TALENT, shipmentIndex);
					shipment.talent = talent;
					shipmentIndex = shipmentIndex + 1;
				end
			end
		end
	end
end

function GarrisonLandingPageReportShipment_OnEnter(self)

	if (self.shipmentType == SHIPMENT_TYPE_BUILDING or self.shipmentType == SHIPMENT_TYPE_FOLLOWER or self.shipmentType == SHIPMENT_TYPE_LOOSE) then
		local _, name, shipmentCapacity, shipmentsReady, shipmentsTotal, timeleftString, itemName;
		if (self.shipmentType == SHIPMENT_TYPE_BUILDING) then
			name, _, shipmentCapacity, shipmentsReady, shipmentsTotal, _, _, timeleftString, itemName = C_Garrison.GetLandingPageShipmentInfo(self.buildingID);
		elseif (self.shipmentType == SHIPMENT_TYPE_FOLLOWER or self.shipmentType == SHIPMENT_TYPE_LOOSE) then
			name, _, shipmentCapacity, shipmentsReady, shipmentsTotal, _, _, timeleftString, itemName = C_Garrison.GetLandingPageShipmentInfoByContainerID(self.containerID);
		else
			return;
		end

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(itemName or name);

		local isBuilding, canActivate;
		if (self.plotID) then
			_,_,_,_,_, isBuilding, _,_, canActivate = C_Garrison.GetOwnedBuildingInfoAbbrev(self.plotID);
		end

		if (isBuilding or canActivate) then
			GameTooltip:AddLine(GARRISON_BUILDING_UNDER_CONSTRUCTION, 1, 1, 1);
		else
			if (self.shipmentType == SHIPMENT_TYPE_BUILDING) then
				GameTooltip:AddLine(GARRISON_LANDING_SHIPMENT_LABEL, 1, 1, 1);
				GameTooltip:AddLine(" ");
			end

			local shipmentsAvailable = shipmentCapacity;

			if(shipmentsTotal) then
				shipmentsAvailable = shipmentCapacity - shipmentsTotal;
			end

			if shipmentsAvailable > 0 then
				GameTooltip:AddLine(format(GARRISON_LANDING_SHIPMENT_READY_TO_START, shipmentsAvailable) , GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
			end

			if (shipmentsReady and shipmentsTotal) then
				if (shipmentsReady == shipmentsTotal) then
					GameTooltip:AddLine(format(GARRISON_LANDING_RETURN, shipmentsTotal), GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				else
					if (timeleftString) then
						GameTooltip:AddLine(format(GARRISON_LANDING_COMPLETED, shipmentsReady, shipmentsTotal) .. " " .. format(GARRISON_LANDING_NEXT,timeleftString), 1, 1, 1);
					else
						GameTooltip:AddLine(format(GARRISON_LANDING_COMPLETED, shipmentsReady, shipmentsTotal), 1, 1, 1);
					end
				end
			end
		end
		GameTooltip:Show();
	elseif (self.shipmentType == SHIPMENT_TYPE_TALENT) then

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local talent = self.talent;
		GameTooltip:AddLine(talent.name, 1, 1, 1);
		GameTooltip:AddLine(talent.description, nil, nil, nil, true);

		if talent.isBeingResearched then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..TIME_REMAINING..FONT_COLOR_CODE_CLOSE.." "..SecondsToTime(talent.timeRemaining), 1, 1, 1);
		end
		GameTooltip:Show();
	end
end

---------------------------------------------------------------------------------
--- Report - Mission List                                                     ---
---------------------------------------------------------------------------------
function GarrisonLandingPageReportList_OnShow(self)
	GarrisonLandingPageReport:RegisterEvent("GET_ITEM_INFO_RECEIVED");

	ExpansionLandingPageMinimapButton:ClearPulses();
	if ( GarrisonLandingPageReport.selectedTab ) then
		GarrisonLandingPageReportList_UpdateItems()
	end
end

function GarrisonLandingPageReportList_OnHide(self)
	GarrisonLandingPageReport:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
	self.missions = nil;
end

function GarrisonLandingPageReportTab_OnClick(self)
	if ( self == GarrisonLandingPageReport.unselectedTab ) then
		PlaySound(SOUNDKIT.UI_GARRISON_NAV_TABS);
		GarrisonLandingPageReport_SetTab(self);
	end
end

function GarrisonLandingPageReport_SetTab(self)
	local tab = GarrisonLandingPageReport.selectedTab;
	tab:GetNormalTexture():SetAtlas("GarrLanding-TopTabUnselected", true);
	tab:SetNormalFontObject(GameFontNormalMed2);
	tab:SetHighlightFontObject(GameFontNormalMed2);
	tab:GetHighlightTexture():SetAlpha(1);
	tab:SetSize(205,30);

	GarrisonLandingPageReport.unselectedTab = tab;
	GarrisonLandingPageReport.selectedTab = self;

	self:GetNormalTexture():SetAtlas("GarrLanding-TopTabSelected", true);
	self:SetNormalFontObject(GameFontHighlightMed2);
	self:SetHighlightFontObject(GameFontHighlightMed2);
	self:GetHighlightTexture():SetAlpha(0);
	self:SetSize(205,36);

	if (self == GarrisonLandingPageReport.InProgress) then
		GarrisonLandingPageReportList_Update();
	else
		GarrisonLandingPageReportList_UpdateAvailable();
	end

	GarrisonLandingPageReportList_UpdateItems();
end

function GarrisonLandingPageReportList_UpdateItems()
	local garrTypeID = GarrisonLandingPage.garrTypeID;
	local availableMissions = C_Garrison.GetAvailableMissions(GetPrimaryGarrisonFollowerType(garrTypeID));
	GarrisonLandingPageReport.List.AvailableItems = GarrisonLandingPageReportMission_FilterOutCombatAllyMissions(availableMissions);
	Garrison_SortMissions(GarrisonLandingPageReport.List.AvailableItems);

	local items = GarrisonLandingPageReportMission_FilterOutCombatAllyMissions(C_Garrison.GetLandingPageItems(garrTypeID));
	GarrisonLandingPageReport.List.items = items;
	GarrisonLandingPageReport.InProgress.Text:SetFormattedText(GARRISON_LANDING_IN_PROGRESS, #items);

	local availableString = garrTypeID == Enum.GarrisonType.Type_9_0_Garrison and COVENANT_MISSIONS_AVAILABLE or GARRISON_LANDING_AVAILABLE;
	GarrisonLandingPageReport.Available.Text:SetFormattedText(availableString, #GarrisonLandingPageReport.List.AvailableItems);

	if ( GarrisonLandingPageReport.selectedTab == GarrisonLandingPageReport.InProgress ) then
		GarrisonLandingPageReportList_Update();
	else
		GarrisonLandingPageReportList_UpdateAvailable();
	end
end

function GarrisonLandingPageReportList_UpdateAvailable()
	local dataProvider = CreateDataProvider(GarrisonLandingPageReport.List.AvailableItems or {});
	if dataProvider:GetSize() == 0 then
		local emptyMissionText = GarrisonLandingPageReport:GetParent().garrTypeID == Enum.GarrisonType.Type_9_0_Garrison and COVENANT_MISSIONS_EMPTY_LIST or GARRISON_EMPTY_MISSION_LIST;
		GarrisonLandingPageReport.List.EmptyMissionText:SetText(emptyMissionText);
	else
		GarrisonLandingPageReport.List.EmptyMissionText:SetText(nil);
	end
	GarrisonLandingPageReport.List.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function GarrisonLandingPageReportList_InitButtonAvailable(button, elementData)
	local item = elementData;

	if (item.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat) then
		button.BG:SetAtlas("GarrLanding-ShipMission-InProgress", true);
	else
		button.BG:SetAtlas("GarrLanding-Mission-InProgress", true);
	end
	button.Title:SetText(item.name);
	button.MissionType:SetTextColor(GARRISON_MISSION_TYPE_FONT_COLOR.r, GARRISON_MISSION_TYPE_FONT_COLOR.g, GARRISON_MISSION_TYPE_FONT_COLOR.b);
	if ( item.durationSeconds >= GARRISON_LONG_MISSION_TIME ) then
		button.MissionType:SetFormattedText(GARRISON_LONG_MISSION_TIME_FORMAT, item.duration);
	else
		button.MissionType:SetText(item.duration);
	end
	button.MissionTypeIcon:SetShown(item.followerTypeID ~= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower);
	button.EncounterIcon:SetShown(item.followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower);

	button.MissionTypeIcon:SetAtlas(item.typeAtlas);
	if (item.followerTypeID == Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower) then
		button.MissionTypeIcon:SetSize(40, 40);
		button.MissionTypeIcon:SetPoint("TOPLEFT", 5, -3);
	elseif item.followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower then
		button.EncounterIcon:SetEncounterInfo(C_Garrison.GetMissionEncounterIconInfo(item.missionID));
	else
		button.MissionTypeIcon:SetSize(50, 50);
		button.MissionTypeIcon:SetPoint("TOPLEFT", 0, 2);
	end
	local index = 1;
	for id, reward in pairs(item.rewards) do
		local Reward = button.Rewards[index];
		Reward.Quantity:Hide();
		Reward.Quantity:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		Reward.bonusAbilityID = nil;
		Reward.bonusAbilityDuration = nil;
		Reward.bonusAbilityIcon = nil;
		Reward.bonusAbilityName = nil;
		Reward.bonusAbilityDescription = nil;
		Reward.currencyID = nil;
		Reward.currencyQuantity = nil;
		Reward.itemLink = nil;
		SetItemButtonQuality(Reward, nil);
		if (reward.itemID) then
			Reward.itemID = reward.itemID;
			Reward.itemLink = reward.itemLink;
			local _, _, quality, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(reward.itemLink or reward.itemID);
			Reward.Icon:SetTexture(itemTexture);
			SetItemButtonQuality(Reward, quality, reward.itemID);

			if ( reward.quantity > 1 ) then
				Reward.Quantity:SetText(reward.quantity);
				Reward.Quantity:Show();
			end
		else
			Reward.itemID = nil;
			Reward.Icon:SetTexture(reward.icon);
			Reward.title = reward.title
			if (reward.currencyID and reward.quantity) then
				if (reward.currencyID == 0) then
					Reward.tooltip = GetMoneyString(reward.quantity);
					Reward.Quantity:SetText(BreakUpLargeNumbers(floor(reward.quantity / COPPER_PER_GOLD)));
					Reward.Quantity:Show();
				else
					local currencyTexture = C_CurrencyInfo.GetCurrencyInfo(reward.currencyID).iconFileID;
					Reward.tooltip = BreakUpLargeNumbers(reward.quantity).." |T"..currencyTexture..":0:0:0:-1|t ";
					Reward.currencyID = reward.currencyID;
					Reward.currencyQuantity = reward.quantity;
					if C_CurrencyInfo.IsCurrencyContainer(reward.currencyID, reward.quantity) then
						local name, texture, quantity = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.currencyID, reward.quantity);
						Reward.Icon:SetTexture(texture);
						if quantity > 1 then
							Reward.Quantity:SetText(quantity);
							Reward.Quantity:Show();
						end
					else
						Reward.Quantity:SetText(reward.quantity);
						Reward.Quantity:Show();
					end
					local currencyColor = GetColorForCurrencyReward(reward.currencyID, reward.quantity);
					Reward.Quantity:SetTextColor(currencyColor:GetRGB());
				end
			elseif (reward.bonusAbilityID) then
				Reward.bonusAbilityID = reward.bonusAbilityID;
				Reward.bonusAbilityDuration = reward.duration;
				Reward.bonusAbilityIcon = reward.icon;
				Reward.bonusAbilityName = reward.name;
				Reward.bonusAbilityDescription = reward.description;
			else
				Reward.tooltip = reward.tooltip;
				if ( reward.followerXP ) then
					Reward.Quantity:SetText(GarrisonLandingPageReportList_FormatXPNumbers(reward.followerXP));
					Reward.Quantity:Show();
				end
			end
		end
		Reward:Show();
		index = index + 1;
	end
	for i = index, #button.Rewards do
		button.Rewards[i]:Hide();
	end

	-- Set title width based on number of rewards
	local titleWidth = 334 - ((index - 1)* 44);
	button.Title:SetWidth(titleWidth);

	button.Status:Hide();
	button.TimeLeft:Hide();
end

function GarrisonLandingPageReportList_FormatXPNumbers(value)
	local strLen = strlen(value);
	if ( strLen > 4 ) then
		value = value / FIRST_NUMBER_CAP_VALUE;
		if ( value%1 == 0 ) then
			-- integer
			return value..FIRST_NUMBER_CAP;
		else
			-- float
			return string.format("%.1F", value)..FIRST_NUMBER_CAP;
		end
	else
		return BreakUpLargeNumbers(value);
	end
end

function GarrisonLandingPageReportList_InitButton(button, elementData)
	local item = elementData;

	local bgName;
	if (item.isBuilding) then
		bgName = "GarrLanding-Building-";
		button.Status:SetText(GARRISON_LANDING_STATUS_BUILDING);
	elseif (item.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat) then
		bgName = "GarrLanding-ShipMission-";
	else
		bgName = "GarrLanding-Mission-";
	end
	button.Title:SetText(item.name);
	if (item.isComplete) then
		bgName = bgName.."Complete";
		if (item.isBuilding) then
			button.MissionType:SetText(GARRISON_LANDING_BUILDING_COMPLEATE);
		else
			button.MissionType:SetText(GarrisonFollowerOptions[item.followerTypeID].strings.LANDING_COMPLETE);
		end
		button.MissionType:SetTextColor(YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		button.Title:SetWidth(290);
	else
		bgName = bgName.."InProgress";
		button.MissionType:SetTextColor(GARRISON_MISSION_TYPE_FONT_COLOR.r, GARRISON_MISSION_TYPE_FONT_COLOR.g, GARRISON_MISSION_TYPE_FONT_COLOR.b);
		if (item.isBuilding) then
			button.MissionType:SetText(GARRISON_BUILDING_IN_PROGRESS);
		elseif ( GarrisonFollowerOptions[item.followerTypeID].hideMissionTypeInLandingPage ) then
			button.MissionType:SetText("");
		else
			button.MissionType:SetText(item.type);
		end
		button.TimeLeft:SetText(item.timeLeft);
		button.Title:SetWidth(322 - button.TimeLeft:GetWidth());
	end
	button.MissionTypeIcon:SetAtlas(item.typeAtlas);
	button.EncounterIcon:SetShown(item.followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower);

	if (item.followerTypeID == Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower) then
		button.MissionTypeIcon:SetSize(40, 40);
		button.MissionTypeIcon:SetPoint("TOPLEFT", 5, -3);
	elseif item.followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower then
		button.EncounterIcon:SetEncounterInfo(C_Garrison.GetMissionEncounterIconInfo(item.missionID));
	else
		button.MissionTypeIcon:SetSize(50, 50);
		button.MissionTypeIcon:SetPoint("TOPLEFT", 0, 2);
	end
	button.MissionTypeIcon:SetShown(not item.isBuilding and item.followerTypeID ~= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower);
	button.Status:SetShown(not item.isComplete);
	button.TimeLeft:SetShown(not item.isComplete);

	button.BG:SetAtlas(bgName, true);
	for i = 1, #button.Rewards do
		button.Rewards[i]:Hide();
	end
end

function GarrisonLandingPageReportList_Update()
	local garrTypeID = GarrisonLandingPage.garrTypeID;
	local items = GarrisonLandingPageReportMission_FilterOutCombatAllyMissions(C_Garrison.GetLandingPageItems(garrTypeID));
	Garrison_SortMissions(items);
	GarrisonLandingPageReport.List.items = items;

	if #items == 0 then
		local emptyMissionText = GarrisonLandingPageReport:GetParent().garrTypeID == Enum.GarrisonType.Type_9_0_Garrison and COVENANT_MISSIONS_EMPTY_IN_PROGRESS or GARRISON_EMPTY_IN_PROGRESS_LIST;
		GarrisonLandingPageReport.List.EmptyMissionText:SetText(emptyMissionText);
	else
		GarrisonLandingPageReport.List.EmptyMissionText:SetText(nil);
	end

	local missionDataMatches = false;
	local dataProvider = GarrisonLandingPageReport.List.ScrollBox:GetDataProvider();

	-- If data provider exists with same number of missions, check if all existing mission ids match the current mission id list
	if dataProvider and #items == dataProvider:GetSize() then
		missionDataMatches = TableUtil.CompareValuesAsKeys(items, dataProvider:GetCollection(), function(mission)
			return mission.missionID;
		end);
	end

	if missionDataMatches then
		-- New and existing mission ids match, update all the entries with current data to avoid rebuilding the data provider every frame
		for _, mission in ipairs(items) do
			local elementData = dataProvider:FindElementDataByPredicate(function(elementData)
				return elementData.missionID == mission.missionID;
			end);

			if elementData then
				MergeTable(elementData, mission);
			end
		end

		GarrisonLandingPageReport.List.ScrollBox:ForEachFrame(function(frame)
			GarrisonLandingPageReportList_InitButton(frame, frame:GetElementData());
		end);
	else
		-- Mission data doesn't match, recreate the provider with new data
		dataProvider = CreateDataProvider(items);
		GarrisonLandingPageReport.List.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	end
end

function GarrisonLandingPageReportList_UpdateMouseOverTooltip(self)
	local buttons = self.buttons;
	for i = 1, #buttons do
		if ( buttons[i]:IsMouseOver() ) then
			GarrisonLandingPageReportMission_OnEnter(buttons[i]);
			break;
		end
	end
end

function GarrisonLandingPageReportMission_FilterOutCombatAllyMissions(items)
	for i = #items, 1, -1 do
		if (not items[i].isBuilding and items[i].isZoneSupport) then
			table.remove(items, i);
		end
	end
	return items;
end

function GarrisonLandingPageReportMission_OnClick(self, button)
	local item = self:GetElementData();
	-- non mission entries have no click capability
	if not item.missionID then
		return;
	end

	if ( IsModifiedClick("CHATLINK") ) then
		local missionLink = C_Garrison.GetMissionLink(item.missionID);
		if (missionLink) then
			ChatEdit_InsertLink(missionLink);
			return;
		end
	elseif ( C_Garrison.CastSpellOnMission(item.missionID) ) then
		return;
	end
end

function GarrisonLandingPageReportMission_OnEnter(self, button)
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("LEFT", self, "RIGHT", 0, 0);

	local item = self:GetElementData();
	if (not item) then
		return;
	end

	if ( item.isBuilding ) then
		GameTooltip:SetText(item.name);
		GameTooltip:AddLine(string.format(GARRISON_BUILDING_LEVEL_LABEL_TOOLTIP, item.buildingLevel), 1, 1, 1);
		if(item.isComplete) then
			GameTooltip:AddLine(COMPLETE, 1, 1, 1);
		else
			GameTooltip:AddLine(tostring(item.timeLeft), 1, 1, 1);
		end
		GameTooltip:Show();
		return;
	end

	if ( GarrisonLandingPageReport.selectedTab == GarrisonLandingPageReport.InProgress ) then
		if (item.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat) then
			GarrisonShipyardMapMissionTooltip:ClearAllPoints();
			GarrisonShipyardMapMissionTooltip:SetPoint("LEFT", self, "RIGHT", 0, 0);
			GarrisonShipyardMapMission_SetTooltip(item, true);
			return;
		else
			GarrisonMissionButton_SetInProgressTooltip(item, true);
		end
	else
		GameTooltip:SetText(item.name);
		if (item.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat) then
			GameTooltip:AddLine(string.format(GARRISON_SHIPYARD_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, item.numFollowers), 1, 1, 1);
		elseif (item.followerTypeID ~= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower) then
			GameTooltip:AddLine(string.format(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, item.numFollowers), 1, 1, 1);
		end
		GarrisonMissionButton_AddThreatsToTooltip(item.missionID, item.followerTypeID, false, GarrisonLandingPage.abilityCountersForMechanicTypes);
		if (item.isRare) then
			GameTooltip:AddLine(GarrisonFollowerOptions[item.followerTypeID].strings.AVAILABILITY);
			GameTooltip:AddLine(item.offerTimeRemaining, 1, 1, 1);
		end
		if (item.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat) then
			if (not C_Garrison.IsOnShipyardMap()) then
				GameTooltip:AddLine(" ");
				GameTooltip:AddLine(GarrisonFollowerOptions[item.followerTypeID].strings.RETURN_TO_START, nil, nil, nil, 1);
			end
		elseif not C_Garrison.IsPlayerInGarrison(GarrisonLandingPage.garrTypeID) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(GarrisonFollowerOptions[item.followerTypeID].strings.RETURN_TO_START, nil, nil, nil, 1);
		end
	end

	GameTooltip:Show();
end

function GarrisonLandingPageReportMission_OnLeave(self)
	GarrisonShipyardMapMissionTooltip:Hide();
	GameTooltip:Hide();
end

function GarrisonLandingPageReportMissionReward_OnEnter(self)
	if (self.bonusAbilityID) then
		self.UpdateTooltip = nil;
		local tooltip = GarrisonBonusAreaTooltip;
		GarrisonBonusArea_Set(tooltip.BonusArea, GARRISON_BONUS_EFFECT_TIME_ACTIVE, self.bonusAbilityDuration, self.bonusAbilityIcon, self.bonusAbilityName, self.bonusAbilityDescription);

		tooltip:ClearAllPoints();
		tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
		tooltip:SetHeight(tooltip.BonusArea:GetHeight());
		tooltip:Show();
		return;
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		self.UpdateTooltip = GarrisonLandingPageReportMissionReward_OnEnter;
		if (self.itemLink) then
			GameTooltip:SetHyperlink(self.itemLink);
			return;
		end
		if (self.itemID) then
			GameTooltip:SetItemByID(self.itemID);
			return;
		end
		if (self.currencyID and C_CurrencyInfo.IsCurrencyContainer(self.currencyID, self.currencyQuantity)) then
			GameTooltip:SetCurrencyByID(self.currencyID, self.currencyQuantity);
			return;
		end
		if (self.title) then
			GameTooltip:SetText(self.title);
		end
		if (self.tooltip) then
			local color = HIGHLIGHT_FONT_COLOR;
			if (self.currencyID) then
				color = GetColorForCurrencyReward(self.currencyID, self.currencyQuantity);
			end
			GameTooltip:AddLine(self.tooltip, color.r, color.g, color.b, true);
		end
		GameTooltip:Show();
	end
end

function GarrisonLandingPageReportMissionReward_OnLeave(self)
	GarrisonBonusAreaTooltip:Hide();
	GameTooltip_Hide(self);
end

---------------------------------------------------------------------------------
--- Garrison Landing Page Ship Follower List Mixin Functions                  ---
---------------------------------------------------------------------------------

GarrisonLandingShipFollowerList = {};

function GarrisonLandingShipFollowerList:Initialize(followerType)
	GarrisonShipyardFollowerList.Initialize(self, followerType, self:GetParent().ShipFollowerTab);
end

function GarrisonLandingShipFollowerList:UpdateValidSpellHighlight(followerID, followerInfo)
	GarrisonShipyardFollowerList.UpdateValidSpellHighlight(self, followerID, followerInfo, true);
end

function GarrisonLandingShipFollowerList:ShowFollower(followerID)
	GarrisonShipyardFollowerList.ShowFollower(self, followerID, true);
end
