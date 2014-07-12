GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH = 205;
GARRISON_FOLLOWER_MAX_LEVEL = 100;
GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY = 4;

GARRISON_MISSION_NAME_FONT_COLOR	=	{r=0.78, g=0.75, b=0.73};
GARRISON_MISSION_TYPE_FONT_COLOR	=	{r=0.8, g=0.7, b=0.53};


function GarrisonLandingPage_OnLoad(self)
	self.List.listScroll.update = GarrisonLandingPageList_Update;
	HybridScrollFrame_CreateButtons(self.List.listScroll, "GarrisonLandingPageMissionTemplate", 0, 0);
	GarrisonLandingPageList_Update();
	self:RegisterEvent("GARRISON_LANDINGPAGE_SHIPMENTS");
end

function GarrisonLandingPage_OnShow(self)
	-- Shipments
	C_Garrison.RequestLandingPageShipmentInfo();
end

function GarrisonLandingPage_OnHide(self)
	GarrisonLandingPage:SetScript("OnUpdate", nil);
end

function GarrisonLandingPage_OnEvent(self, event)
	if ( event == "GARRISON_LANDINGPAGE_SHIPMENTS" ) then
		for i = 1, #self.Shipments do
			local shipment = self.Shipments[i];
			local name, texture, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemIcon, itemQuality, itemID = C_Garrison.GetLandingPageShipmentInfo(i);
			if ( name ) then
				SetPortraitToTexture(shipment.Icon, texture);
				shipment.Icon:SetDesaturated(true);
				shipment.Name:SetText(name);
				shipment.Count:SetFormattedText(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal);
				if ( shipmentsReady == shipmentsTotal ) then
					shipment.Swipe:SetCooldownUNIX(0, 0);
					shipment.Done:Show();
					shipment.BG:Hide();
				else
					shipment.Swipe:SetCooldownUNIX(creationTime, duration);
					shipment.Done:Hide();
					shipment.BG:Show();
				end
				shipment:Show();
				shipment.index = i;
			else
				shipment:Hide();
			end
		end
	end
end

function GarrisonLandingPage_OnUpdate()
	if( GarrisonLandingPage.List.items and #GarrisonLandingPage.List.items > 0 )then
		GarrisonLandingPage.List.items = C_Garrison.GetLandingPageItems(true); -- don't sort entries again
	else
		GarrisonLandingPage.List.items = C_Garrison.GetLandingPageItems();
	end
	
	if( GarrisonLandingPageList_Update() ) then
		GarrisonLandingPage:SetScript("OnUpdate", nil);
	end
end

function GarrisonLandingPageShipment_OnEnter(self)
	local name, texture, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemIcon, itemQuality, itemID = C_Garrison.GetLandingPageShipmentInfo(self.index);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if (itemName) then
		GameTooltip:SetText(itemName);
	end
	if (shipmentsReady and shipmentsTotal) then
		GameTooltip:AddLine(format(GARRISON_LANDING_COMPLETED, shipmentsReady, shipmentsTotal), 1, 1, 1);
	    
		if (shipmentsReady == shipmentsTotal) then
		    GameTooltip:AddLine(GARRISON_LANDING_RETURN, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
	    elseif (timeleftString) then
		    GameTooltip:AddLine(format(GARRISON_LANDING_NEXT,timeleftString), 1, 1, 1);
	    end
	end
	GameTooltip:Show();
end

---------------------------------------------------------------------------------
--- Mission List                                                              ---
---------------------------------------------------------------------------------

function GarrisonLandingPageList_OnShow(self)
	GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Stop();
	if ( not GarrisonLandingPage.selectedTab ) then
		-- SetTab flips the tabs, so set them up reversed & call SetTab
		GarrisonLandingPage.unselectedTab = GarrisonLandingPage.InProgress;
		GarrisonLandingPage.selectedTab = GarrisonLandingPage.Available;
		GarrisonLandingPage_SetTab(GarrisonLandingPage.unselectedTab);
	else
		GarrisonLandingPageList_UpdateItems()
	end
end

function GarrisonLandingPageList_OnHide(self)
	self.missions = nil;
end

function GarrisonLandingPage_SetTab(self)
	if ( self == GarrisonLandingPage.unselectedTab ) then
		local tab = GarrisonLandingPage.selectedTab;
		tab:GetNormalTexture():SetAtlas("GarrLanding-TopTabUnselected", true);
		tab:SetNormalFontObject(GameFontNormalMed2);
		tab:SetHighlightFontObject(GameFontNormalMed2);
		tab:GetHighlightTexture():SetAlpha(1);
		tab:SetSize(205,30);
		
		GarrisonLandingPage.unselectedTab = tab;
		GarrisonLandingPage.selectedTab = self;
		
		self:GetNormalTexture():SetAtlas("GarrLanding-TopTabSelected", true);
		self:SetNormalFontObject(GameFontHighlightMed2);
		self:SetHighlightFontObject(GameFontHighlightMed2);
		self:GetHighlightTexture():SetAlpha(0);
		self:SetSize(205,36);
		
		GarrisonLandingPageList_UpdateItems();
	end
end

function GarrisonLandingPageList_UpdateItems()
	GarrisonLandingPage.List.items = C_Garrison.GetLandingPageItems();
	GarrisonLandingPage.List.AvailableItems = C_Garrison.GetAvailableMissions();
	GarrisonLandingPage.InProgress.Text:SetFormattedText(GARRISON_LANDING_IN_PROGRESS, #GarrisonLandingPage.List.items);
	GarrisonLandingPage.Available.Text:SetFormattedText(GARRISON_LANDING_AVAILABLE, #GarrisonLandingPage.List.AvailableItems);
	if ( GarrisonLandingPage.selectedTab == GarrisonLandingPage.InProgress ) then
		GarrisonLandingPageList_Update();
		GarrisonLandingPage:SetScript("OnUpdate", GarrisonLandingPage_OnUpdate);
	else
		GarrisonLandingPageList_UpdateAvailable();
		GarrisonLandingPage:SetScript("OnUpdate", nil);
	end
end

function GarrisonLandingPageList_UpdateAvailable()
	local items = GarrisonLandingPage.List.AvailableItems or {};
	local numItems = #items;
	local scrollFrame = GarrisonLandingPage.List.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numItems ) then
			local item = items[index];
			button.id = index;

			button.BG:SetAtlas("GarrLanding-Mission-InProgress", true);
			button.Title:SetText(item.name);
			button.MissionType:SetTextColor(GARRISON_MISSION_TYPE_FONT_COLOR.r, GARRISON_MISSION_TYPE_FONT_COLOR.g, GARRISON_MISSION_TYPE_FONT_COLOR.b);
			button.MissionType:SetText(item.duration);
			button.MissionTypeIcon:Show();
			button.RewardBG:Show();
			
			if ( item.cost > 0 ) then
				button.CostBG:Show();
				button.Cost:SetText(BreakUpLargeNumbers(item.cost));
				button.Cost:Show();
				button.CostLabel:Show();
				button.MaterialIcon:Show();
			else
				button.CostBG:Hide();
				button.Cost:Hide();
				button.CostLabel:Hide();
				button.MaterialIcon:Hide();
			end
			
			local index = 1;
			for id, reward in pairs(item.rewards) do
				local Reward = button.Rewards[index];
				Reward.Quantity:Hide();
				if (reward.itemID) then
					Reward.itemID = reward.itemID;
					local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(reward.itemID);
					Reward.Icon:SetTexture(itemTexture);
				else
					Reward.Icon:SetTexture(reward.icon);
					Reward.title = reward.title
					if (reward.currencyID and reward.quantity) then
						if (reward.currencyID == 0) then
							Reward.tooltip = GetMoneyString(reward.quantity);
						else
							local _, _, currencyTexture = GetCurrencyInfo(reward.currencyID);
							Reward.tooltip = BreakUpLargeNumbers(reward.quantity).." |T"..currencyTexture..":0:0:0:-1|t ";
							Reward.Quantity:SetText(reward.quantity);
							Reward.Quantity:Show();
						end
					else
						Reward.tooltip = reward.tooltip;
					end
				end
				Reward:Show();
				index = index + 1;
			end
			for i = index, #button.Rewards do
				button.Rewards[i]:Hide();
			end
			
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

function GarrisonLandingPageList_Update()
	local items = GarrisonLandingPage.List.items or {};
	local numItems = #items;
	local scrollFrame = GarrisonLandingPage.List.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	local stopUpdate = true;
	
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numItems ) then
			local item = items[index];
			button.id = index;
			local bgName;
			if (item.isBuilding) then
				bgName = "GarrLanding-Building-";
				button.Status:SetText(GARRISON_LANDING_STATUS_BUILDING);
			else
				bgName = "GarrLanding-Mission-";
			end
			if (item.isComplete) then
				bgName = bgName.."Complete";
				button.MissionType:SetText(GARRISON_LANDING_BUILDING_COMPLEATE);
				button.MissionType:SetTextColor(YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
			else
				bgName = bgName.."InProgress";
				button.MissionType:SetTextColor(GARRISON_MISSION_TYPE_FONT_COLOR.r, GARRISON_MISSION_TYPE_FONT_COLOR.g, GARRISON_MISSION_TYPE_FONT_COLOR.b);
				if (item.isBuilding) then
					button.MissionType:SetText(GARRISON_BUILDING_IN_PROGRESS);
				else
					button.MissionType:SetText(item.type);
				end
				button.TimeLeft:SetText(item.timeLeft);
				stopUpdate = false;
			end

			button.MissionTypeIcon:SetShown(not item.isBuilding);
			button.Status:SetShown(not item.isComplete);
			button.TimeLeft:SetShown(not item.isComplete);

			button.BG:SetAtlas(bgName, true);
			button.Title:SetText(item.name);
			button.Cost:Hide();
			button.CostLabel:Hide();
			button.MaterialIcon:Hide();
			button.RewardBG:Hide();
			button.CostBG:Hide();
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

function GarrisonLandingPageMission_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local items = GarrisonLandingPage.List.items or {};
		if GarrisonLandingPage.selectedTab == GarrisonLandingPage.Available then
			items = GarrisonLandingPage.List.AvailableItems or {};
		end
	
		local item = items[self.id];

		-- non mission entries have no link capability
		if not item.missionID then
			return;
		end

		local missionLink = C_Garrison.GetMissionLink(item.missionID);
		if (missionLink) then
			ChatEdit_InsertLink(missionLink);
			return;
		end
	end
end

function GarrisonLandingPageMission_OnEnter(self, button)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
	local items = GarrisonLandingPage.List.items or {};
	if GarrisonLandingPage.selectedTab == GarrisonLandingPage.Available then
	    items = GarrisonLandingPage.List.AvailableItems or {};
	end
	
	local item = items[self.id];

	-- building entries have no tooltip
	if item.isBuilding then
		return;
	end
	
	--mission tooltips
	GameTooltip:SetText(item.name);

	if(GarrisonLandingPage.selectedTab == GarrisonLandingPage.InProgress) then
		if(item.isComplete) then
			GameTooltip:AddLine(COMPLETE, 1, 1, 1);
		else
			GameTooltip:AddLine(tostring(item.timeLeft), 1, 1, 1);
		end

		GameTooltip:AddLine(" ");

		if item.followers ~= nil then
			GameTooltip:AddLine(GARRISON_FOLLOWERS);
			for i=1, #(item.followers) do
				GameTooltip:AddLine(C_Garrison.GetFollowerName(item.followers[i]), 1, 1, 1);
			end
			GameTooltip:AddLine(" ");
		end

		GameTooltip:AddLine(REWARDS);
		for id, reward in pairs(item.rewards) do
			if (reward.quality) then
				GameTooltip:AddLine(ITEM_QUALITY_COLORS[reward.quality + 1].hex..reward.title..FONT_COLOR_CODE_CLOSE);
			elseif (reward.itemID) then 
				local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(reward.itemID);
				if itemName then
					GameTooltip:AddLine(ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE);
				end
			elseif (reward.followerXP) then
				GameTooltip:AddLine(reward.title, 1, 1, 1);
			else
				GameTooltip:AddLine(reward.title, 1, 1, 1);
			end
		end
	else
		GameTooltip:AddLine(string.format(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, item.numFollowers), 1, 1, 1);
		
		if not C_Garrison.IsOnGarrisonMap() then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(GARRISON_MISSION_TOOLTIP_RETURN_TO_START);
		end
	end

	GameTooltip:Show();
end