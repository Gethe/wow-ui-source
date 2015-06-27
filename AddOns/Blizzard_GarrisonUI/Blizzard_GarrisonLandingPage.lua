GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH = 205;
GARRISON_FOLLOWER_MAX_LEVEL = 100;
GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY = 4;

GARRISON_MISSION_NAME_FONT_COLOR	=	{r=0.78, g=0.75, b=0.73};
GARRISON_MISSION_TYPE_FONT_COLOR	=	{r=0.8, g=0.7, b=0.53};


---------------------------------------------------------------------------------
--- Main Frame                                                                ---
---------------------------------------------------------------------------------
function GarrisonLandingPage_OnLoad(self)
	self.FollowerList:Load(LE_FOLLOWER_TYPE_GARRISON_6_0);
	self.ShipFollowerList:Load(LE_FOLLOWER_TYPE_SHIPYARD_6_2);

	self.selectedTab = 1;
	
	GarrisonLandingPage.Report:Show();
	GarrisonLandingPage.FollowerList:Hide();
	GarrisonLandingPage.FollowerTab:Hide();
	GarrisonLandingPage.ShipFollowerList:Hide();
	GarrisonLandingPage.ShipFollowerTab:Hide();
end

function GarrisonLandingPage_UpdateTabs(self)
	local numTabs = 2;
	if (C_Garrison.HasShipyard()) then
		numTabs = 3;
		self.FleetTab:Show();
	end
	PanelTemplates_SetNumTabs(self, numTabs);
	PanelTemplates_UpdateTabs(self);
	
	local fleetCount = C_Garrison.GetNumFollowers(LE_FOLLOWER_TYPE_SHIPYARD_6_2);
	if (fleetCount == 0) then
		if (PanelTemplates_GetSelectedTab(self) == self.FleetTab:GetID()) then
			GarrisonLandingPageTab_SetTab(self.ReportTab);
		end
		PanelTemplates_DisableTab(self, 3);
	else
		PanelTemplates_EnableTab(self, 3);
	end
end

function GarrisonLandingPageTab_OnEnter(self)
	self.LeftHighlight:Show();
	self.MiddleHighlight:Show();
	self.RightHighlight:Show();
end

function GarrisonLandingPageTab_OnLeave(self)
	self.LeftHighlight:Hide();
	self.MiddleHighlight:Hide();
	self.RightHighlight:Hide();
end

function GarrisonLandingPage_OnShow(self)
	GarrisonLandingPage_UpdateTabs(self);
	if (C_Garrison.IsInvasionAvailable()) then
		self.InvasionBadge:Show();
		self.InvasionBadge.InvasionBadgeAnim:Play();
	else
		self.InvasionBadge:Hide();
	end
	GarrisonThreatCountersFrame:SetParent(self.FollowerTab);
	GarrisonThreatCountersFrame:SetPoint("TOPRIGHT", -152, 30);
	PlaySound("UI_Garrison_GarrisonReport_Open");
end

function GarrisonLandingPage_OnHide(self)
	PlaySound("UI_Garrison_GarrisonReport_Close");
	StaticPopup_Hide("CONFIRM_FOLLOWER_TEMPORARY_ABILITY");
	StaticPopup_Hide("CONFIRM_FOLLOWER_UPGRADE");
	StaticPopup_Hide("CONFIRM_FOLLOWER_ABILITY_UPGRADE");
	GarrisonBonusAreaTooltip:Hide();
end

function GarrisonLandingPageTab_OnClick(self)
	PlaySound("UI_Garrison_Nav_Tabs");
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
function GarrisonLandingPageReport_OnLoad(self)
	HybridScrollFrame_CreateButtons(self.List.listScroll, "GarrisonLandingPageReportMissionTemplate", 0, 0);
	GarrisonLandingPageReportList_Update();
	self:RegisterEvent("GARRISON_LANDINGPAGE_SHIPMENTS");
	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:RegisterEvent("GARRISON_SHIPMENT_RECEIVED");
	
	self.List.listScroll:SetScript("OnMouseWheel", function(self, ...) HybridScrollFrame_OnMouseWheel(self, ...); GarrisonLandingPageReportList_UpdateMouseOverTooltip(self); end);
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
end

function GarrisonLandingPageReport_OnHide(self)
	GarrisonLandingPageReport:SetScript("OnUpdate", nil);
end

function GarrisonLandingPageReport_OnEvent(self, event)
	if ( event == "GARRISON_LANDINGPAGE_SHIPMENTS" ) then
		GarrisonLandingPageReport_GetShipments(self);
	elseif ( event == "GARRISON_MISSION_LIST_UPDATE" ) then
		GarrisonLandingPageReportList_UpdateItems();
	elseif ( event == "GARRISON_SHIPMENT_RECEIVED" ) then
		C_Garrison.RequestLandingPageShipmentInfo();
	end
end

function GarrisonLandingPageReport_OnUpdate()
	if( GarrisonLandingPageReport.List.items and #GarrisonLandingPageReport.List.items > 0 )then
		GarrisonLandingPageReport.List.items = C_Garrison.GetLandingPageItems(true); -- don't sort entries again
	else
		GarrisonLandingPageReport.List.items = C_Garrison.GetLandingPageItems();
	end
	
	if( GarrisonLandingPageReportList_Update() ) then
		GarrisonLandingPageReport:SetScript("OnUpdate", nil);
	end
end

---------------------------------------------------------------------------------
--- Report - Shipments                                                        ---
---------------------------------------------------------------------------------
function GarrisonLandingPageReport_GetShipments(self)
	local shipmentIndex = 1;
	local buildings = C_Garrison.GetBuildings();
	for i = 1, #buildings do
		local buildingID = buildings[i].buildingID;
		if ( buildingID) then
			local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemIcon, itemQuality, itemID = C_Garrison.GetLandingPageShipmentInfo(buildingID);
			local shipment = self.Shipments[shipmentIndex];
			if ( not shipment ) then
				return;
			end
			if ( name and shipmentCapacity > 0 ) then
				SetPortraitToTexture(shipment.Icon, texture);
				shipment.Icon:SetDesaturated(true);
				shipment.Name:SetText(name);
				shipment.Done:Hide();
				shipment.Border:Show();
				shipment.BG:Hide();
				shipment.Count:SetText(nil);
				shipment.buildingID = buildingID;
				shipment.plotID = buildings[i].plotID;
				if (shipmentsTotal) then
					shipment.Count:SetFormattedText(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal);
					if ( shipmentsReady == shipmentsTotal ) then
						shipment.Swipe:SetCooldownUNIX(0, 0);
						shipment.Done:Show();
						shipment.Border:Hide();
					else
						shipment.BG:Show();
						shipment.Swipe:SetCooldownUNIX(creationTime, duration);
					end
				end
				shipment:Show();
				shipmentIndex = shipmentIndex + 1;
			else
				shipment:Hide();
			end
		end
	end
	for i = shipmentIndex, #self.Shipments do
		self.Shipments[i]:Hide();
	end
end

function GarrisonLandingPageReportShipment_OnEnter(self)
	local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemIcon, itemQuality, itemID = C_Garrison.GetLandingPageShipmentInfo(self.buildingID);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if (itemName) then
		GameTooltip:SetText(itemName);
	else
		GameTooltip:SetText(name);
	end
	
	local _,_,_,_,_, isBuilding, _,_, canActivate = C_Garrison.GetOwnedBuildingInfoAbbrev(self.plotID);
	if (isBuilding or canActivate) then
		GameTooltip:AddLine(GARRISON_BUILDING_UNDER_CONSTRUCTION, 1, 1, 1);
	else
		GameTooltip:AddLine(GARRISON_LANDING_SHIPMENT_LABEL, 1, 1, 1);
		GameTooltip:AddLine(" ");

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
end

---------------------------------------------------------------------------------
--- Report - Mission List                                                     ---
---------------------------------------------------------------------------------
function GarrisonLandingPageReportList_OnShow(self)
	GarrisonMinimap_ClearPulse();
	if ( GarrisonLandingPageReport.selectedTab ) then
		GarrisonLandingPageReportList_UpdateItems()
	end
end

function GarrisonLandingPageReportList_OnHide(self)
	self.missions = nil;
end

function GarrisonLandingPageReportTab_OnClick(self)
	if ( self == GarrisonLandingPageReport.unselectedTab ) then
		PlaySound("UI_Garrison_Nav_Tabs");
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
		GarrisonLandingPageReport.List.listScroll.update = GarrisonLandingPageReportList_Update;
	else
		GarrisonLandingPageReport.List.listScroll.update = GarrisonLandingPageReportList_UpdateAvailable;
	end
	
	GarrisonLandingPageReportList_UpdateItems();
end

function GarrisonLandingPageReportList_UpdateItems()
	GarrisonLandingPageReport.List.items = C_Garrison.GetLandingPageItems();
	GarrisonLandingPageReport.List.AvailableItems = C_Garrison.GetAvailableMissions();
	Garrison_SortMissions(GarrisonLandingPageReport.List.AvailableItems);
	GarrisonLandingPageReport.InProgress.Text:SetFormattedText(GARRISON_LANDING_IN_PROGRESS, #GarrisonLandingPageReport.List.items);
	GarrisonLandingPageReport.Available.Text:SetFormattedText(GARRISON_LANDING_AVAILABLE, #GarrisonLandingPageReport.List.AvailableItems);
	if ( GarrisonLandingPageReport.selectedTab == GarrisonLandingPageReport.InProgress ) then
		GarrisonLandingPageReportList_Update();
		GarrisonLandingPageReport:SetScript("OnUpdate", GarrisonLandingPageReport_OnUpdate);
	else
		GarrisonLandingPageReportList_UpdateAvailable();
		GarrisonLandingPageReport:SetScript("OnUpdate", nil);
	end
end

function GarrisonLandingPageReportList_UpdateAvailable()
	local items = GarrisonLandingPageReport.List.AvailableItems or {};
	local numItems = #items;
	local scrollFrame = GarrisonLandingPageReport.List.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	if (numItems == 0) then
		GarrisonLandingPageReport.List.EmptyMissionText:SetText(GARRISON_EMPTY_MISSION_LIST);
	else
		GarrisonLandingPageReport.List.EmptyMissionText:SetText(nil);
	end
	
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numItems ) then
			local item = items[index];
			button.id = index;

			if (item.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
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
			button.MissionTypeIcon:Show();
			button.MissionTypeIcon:SetAtlas(item.typeAtlas);
			
			local index = 1;
			for id, reward in pairs(item.rewards) do
				local Reward = button.Rewards[index];
				Reward.Quantity:Hide();
				Reward.bonusAbilityID = nil;
				Reward.bonusAbilityDuration = nil;
				Reward.bonusAbilityIcon = nil;
				Reward.bonusAbilityName = nil;
				Reward.bonusAbilityDescription = nil;
				if (reward.itemID) then
					Reward.itemID = reward.itemID;
					local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(reward.itemID);
					Reward.Icon:SetTexture(itemTexture);
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
							local _, _, currencyTexture = GetCurrencyInfo(reward.currencyID);
							Reward.tooltip = BreakUpLargeNumbers(reward.quantity).." |T"..currencyTexture..":0:0:0:-1|t ";
							Reward.Quantity:SetText(reward.quantity);
							Reward.Quantity:Show();
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
			button:Show();
		else
			button:Hide();
		end
	end
	
	local totalHeight = numItems * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
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

function GarrisonLandingPageReportList_Update()
	local items = GarrisonLandingPageReport.List.items or {};
	local numItems = #items;
	local scrollFrame = GarrisonLandingPageReport.List.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	local stopUpdate = true;
	
	if (numItems == 0) then
		GarrisonLandingPageReport.List.EmptyMissionText:SetText(GARRISON_EMPTY_IN_PROGRESS_LIST);
	else
		GarrisonLandingPageReport.List.EmptyMissionText:SetText(nil);
	end
	
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		local item = items[index];
		if ( item ) then
			button.id = index;
			local bgName;
			if (item.isBuilding) then
				bgName = "GarrLanding-Building-";
				button.Status:SetText(GARRISON_LANDING_STATUS_BUILDING);
			elseif (item.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
				bgName = "GarrLanding-ShipMission-";
			else
				bgName = "GarrLanding-Mission-";
			end
			button.Title:SetText(item.name);
			if (item.isComplete) then
				bgName = bgName.."Complete";
				button.MissionType:SetText(GARRISON_LANDING_BUILDING_COMPLEATE);
				button.MissionType:SetTextColor(YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
				button.Title:SetWidth(290);
			else
				bgName = bgName.."InProgress";
				button.MissionType:SetTextColor(GARRISON_MISSION_TYPE_FONT_COLOR.r, GARRISON_MISSION_TYPE_FONT_COLOR.g, GARRISON_MISSION_TYPE_FONT_COLOR.b);
				if (item.isBuilding) then
					button.MissionType:SetText(GARRISON_BUILDING_IN_PROGRESS);
				elseif ( item.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
					button.MissionType:SetText("");
				else
					button.MissionType:SetText(item.type);
				end
				button.TimeLeft:SetText(item.timeLeft);
				stopUpdate = false;
				button.Title:SetWidth(322 - button.TimeLeft:GetWidth());
			end
			button.MissionTypeIcon:SetAtlas(item.typeAtlas);
			button.MissionTypeIcon:SetShown(not item.isBuilding);
			button.Status:SetShown(not item.isComplete);
			button.TimeLeft:SetShown(not item.isComplete);

			button.BG:SetAtlas(bgName, true);
			for i = 1, #button.Rewards do
				button.Rewards[i]:Hide();
			end
			button:Show();
		else
			button:Hide();
		end
	end
	
	local totalHeight = numItems * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	
	return stopUpdate;
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

function GarrisonLandingPageReportMission_OnClick(self, button)
	
	local items = GarrisonLandingPageReport.List.items or {};
	if GarrisonLandingPageReport.selectedTab == GarrisonLandingPageReport.Available then
		items = GarrisonLandingPageReport.List.AvailableItems or {};
	end

	local item = items[self.id];

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
	
	local items = GarrisonLandingPageReport.List.items or {};
	if GarrisonLandingPageReport.selectedTab == GarrisonLandingPageReport.Available then
	    items = GarrisonLandingPageReport.List.AvailableItems or {};
	end
	
	local item = items[self.id];
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
		if (item.followerTypeID == LE_FOLLOWER_TYPE_GARRISON_6_0) then
			GarrisonMissionButton_SetInProgressTooltip(item, true);
		elseif (item.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
			GarrisonShipyardMapMissionTooltip:ClearAllPoints();
			GarrisonShipyardMapMissionTooltip:SetPoint("LEFT", self, "RIGHT", 0, 0);
			GarrisonShipyardMapMission_SetTooltip(item, true);
			return;
		end
	else
		GameTooltip:SetText(item.name);
		if (item.followerTypeID == LE_FOLLOWER_TYPE_GARRISON_6_0) then
			GameTooltip:AddLine(string.format(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, item.numFollowers), 1, 1, 1);
		elseif (item.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
			GameTooltip:AddLine(string.format(GARRISON_SHIPYARD_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, item.numFollowers), 1, 1, 1);
		end
		GarrisonMissionButton_AddThreatsToTooltip(item.missionID, item.followerTypeID);
		if (item.isRare) then
			GameTooltip:AddLine(GARRISON_MISSION_AVAILABILITY);
			GameTooltip:AddLine(item.offerTimeRemaining, 1, 1, 1);
		end
		if (item.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
			if (not C_Garrison.IsOnShipyardMap()) then
				GameTooltip:AddLine(" ");
				GameTooltip:AddLine(GARRISON_SHIPYARD_MISSION_TOOLTIP_RETURN_TO_START, nil, nil, nil, 1);
			end
		elseif not C_Garrison.IsOnGarrisonMap() then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(GARRISON_MISSION_TOOLTIP_RETURN_TO_START, nil, nil, nil, 1);
		end
	end

	GameTooltip:Show();
end

function GarrisonLandingPageReportMission_OnLeave(self)
	GarrisonShipyardMapMissionTooltip:Hide();
	GameTooltip_Hide(self);
end

function GarrisonLandingPageReportMissionReward_OnEnter(self)
	if (self.bonusAbilityID) then
		local tooltip = GarrisonBonusAreaTooltip;
		GarrisonBonusArea_Set(tooltip.BonusArea, GARRISON_BONUS_EFFECT_TIME_ACTIVE, self.bonusAbilityDuration, self.bonusAbilityIcon, self.bonusAbilityName, self.bonusAbilityDescription);
		
		tooltip:ClearAllPoints();
		tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
		tooltip:SetHeight(tooltip.BonusArea:GetHeight());
		tooltip:Show();
		return;
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		if (self.itemID) then
			GameTooltip:SetItemByID(self.itemID);
			return;
		end
		if (self.title) then
			GameTooltip:SetText(self.title);
		end
		if (self.tooltip) then
			GameTooltip:AddLine(self.tooltip, 1, 1, 1, true);
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

function GarrisonLandingShipFollowerList:Load(followerType)
	GarrisonShipyardFollowerList.Load(self, followerType, self:GetParent().ShipFollowerTab);
end

function GarrisonLandingShipFollowerList:UpdateValidSpellHighlight(followerID, followerInfo)
	GarrisonShipyardFollowerList.UpdateValidSpellHighlight(self, followerID, followerInfo, true);
end

function GarrisonLandingShipFollowerList:ShowFollower(followerID)
	GarrisonShipyardFollowerList.ShowFollower(self, followerID, true);
end
