GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH = 205;
GARRISON_FOLLOWER_MAX_LEVEL = 100;

function GarrisonMissionFrame_ToggleFrame()
	if (not GarrisonMissionFrame:IsShown()) then
		ShowUIPanel(GarrisonMissionFrame);
	else
		HideUIPanel(GarrisonMissionFrame);
	end
end

function GarrisonMissionFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 2);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
	
	self.FollowerList.listScroll.update = GarrisonFollowerList_Update;
	HybridScrollFrame_CreateButtons(self.FollowerList.listScroll, "GarrisonFollowerListButtonTemplate", 7, -7, nil, nil, nil, -6);
	GarrisonFollowerList_Update();
	
	self.MissionTab.MissionList.listScroll.update = GarrisonMissionList_Update;
	HybridScrollFrame_CreateButtons(self.MissionTab.MissionList.listScroll, "GarrisonMissionListButtonTemplate", 10, -10, nil, nil, nil, -6);
	GarrisonMissionList_Update();
	
	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
end

function GarrisonMissionFrame_OnEvent(self, event, ...)
	if (event == "GARRISON_MISSION_LIST_UPDATE") then
		GarrisonMissionList_UpdateMissions();
	elseif (event == "GARRISON_FOLLOWER_LIST_UPDATE") then
		GarrisonFollowerList_UpdateFollowers();
	end
end

function GarrisonMissionFrame_OnShow(self)
	self.MissionComplete.completeMissions = C_Garrison.GetCompleteMissions();
	if (#self.MissionComplete.completeMissions > 0) then
		GarrisonMissionFrame_ShowCompleteMissions();
	end
end

function GarrisonMissionFrameTab_OnClick(self)
	PlaySound("igCharacterInfoTab");
	PanelTemplates_Tab_OnClick(self, GarrisonMissionFrame);
	
	if (self:GetID() == 1) then
		GarrisonMissionFrame.MissionTab:Show();
		GarrisonMissionFrame.FollowerTab:Hide();
	else
		GarrisonMissionFrame.MissionTab:Hide();
		GarrisonMissionFrame.FollowerTab:Show();
		if (not GarrisonMissionFrame.openFollower) then
			GarrisonMissionFrameFollowersListScrollFrameButton1:Click();
		end
	end
end

---------------------------------------------------------------------------------
--- Follower List                                                             ---
---------------------------------------------------------------------------------

function GarrisonFollowerList_OnShow(self)
	GarrisonFollowerList_UpdateFollowers()
end

function GarrisonFollowerList_OnHide(self)
	self.followers = nil;
end

function GarrisonFollowerList_UpdateFollowers()
	local self = GarrisonMissionFrame.FollowerList;
	self.followers = C_Garrison.GetFollowers();
	GarrisonFollowerList_Update();
end

function GarrisonFollowerList_Update()
	local followers = GarrisonMissionFrame.FollowerList.followers or {};
	local numFollowers = #followers;
	local scrollFrame = GarrisonMissionFrame.FollowerList.listScroll;
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
			button.Status:SetText(follower.status);
			local color = BAG_ITEM_QUALITY_COLORS[follower.quality];
			if (color) then
				button.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
			else
				button.PortraitFrame.LevelBorder:SetVertexColor(1, 1, 1);
			end
			SetPortraitTexture(button.PortraitFrame.Portrait, follower.displayID);
			button.PortraitFrame.Level:SetText(follower.level);
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
			if (button.id == GarrisonMissionFrame.openFollower) then
				GarrisonFollowerButton_Select(button);
				expandedHeight = button:GetHeight() - scrollFrame.buttonHeight + 6;
			else
				GarrisonFollowerButton_UnSelect(button);
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

function GarrisonFollowerButton_Select(self)
	self.UpArrow:Show();
	self.DownArrow:Hide();
	local abHeight = 0;
	if (not self.info.abilities) then
		self.info.abilities = C_Garrison.GetFollowerAbilities(self.info.followerID);
	end
	for i=1, #self.info.abilities do
		if (not self.Abilities[i]) then
			self.Abilities[i] = CreateFrame("Frame", nil, self, "GarrisonFollowerListButtonAbilityTemplate");
			self.Abilities[i]:SetPoint("TOPLEFT", self.Abilities[i-1], "BOTTOMLEFT", 0, -2);
		end
		local Ability = self.Abilities[i];
		local ability = self.info.abilities[i];
		Ability.Name:SetText(ability.name);
		Ability.Icon:SetTexture(ability.icon);
		Ability.tooltip = ability.description;
		Ability:Show();
		abHeight = abHeight + Ability:GetHeight() + 3;
	end
	for i=(#self.info.abilities + 1), #self.Abilities do
		self.Abilities[i]:Hide();
	end
	if (abHeight > 0) then
		abHeight = abHeight + 8;
		self.AbilitiesBG:Show();
		self.AbilitiesBG:SetHeight(abHeight);
	else
		self.AbilitiesBG:Hide();
	end
	self:SetHeight(51 + abHeight);
end

function GarrisonFollowerButton_UnSelect(self)
	self.UpArrow:Hide();
	self.DownArrow:Show();
	self.AbilitiesBG:Hide();
	for i=1, #self.Abilities do
		self.Abilities[i]:Hide();
	end
	self:SetHeight(56);
end

function GarrisonFollowerListButton_OnClick(self, button)
	GarrisonMissionFrame.openFollower = self.id;
	GarrisonFollowerList_Update();
	GarrisonFollowerPage_ShowFollower(self.info);
end

function GarrisonFollowerListButton_OnDragStart(self, button)
	GarrisonFollowerPlacer:SetDisplayInfo(self.info.displayID)
	GarrisonFollowerPlacer:SetAnimation(474);
	GarrisonFollowerPlacer.info = self.info;
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonFollowerPlacer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + 40);
	GarrisonFollowerPlacer:Show();
	GarrisonFollowerPlacer:SetScript("OnUpdate", GarrisonFollowerPlacer_OnUpdate);
end

function GarrisonFollowerListButton_OnDragStop(self)
	if (GarrisonFollowerPlacer:IsShown()) then
		GarrisonFollowerPlacerFrame:Show();
	end
end

function GarrisonFollowerPlacer_OnUpdate(self)
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonFollowerPlacer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + 40);
end

function GarrisonFollowerPlacerFrame_OnClick(self, button)
	local page = GarrisonMissionFrame.MissionTab.MissionPage;
	if (page.SmallParty:IsShown() and page.SmallParty:IsMouseOver()) then
		GarrisonSingleParty_ReceiveDrag(page.SmallParty);
	elseif (page.MediumParty:IsShown() and page.MediumParty:IsMouseOver()) then
		GarrisonManyParty_ReceiveDrag(page.MediumParty);
	elseif (page.LargeParty:IsShown() and page.LargeParty:IsMouseOver()) then
		GarrisonManyParty_ReceiveDrag(page.LargeParty);
	end
	GarrisonFollowerPlacer:Hide();
	self:Hide();
end

---------------------------------------------------------------------------------
--- Follower Page                                                             ---
---------------------------------------------------------------------------------

function GarrisonFollowerPage_ShowFollower(followerInfo)
	if (not followerInfo) then
		return;
	end
	local self = GarrisonMissionFrame.FollowerTab;
	
	self.Name:SetText(followerInfo.name);
	self.PortraitFrame.Level:SetText(followerInfo.level);
	local color = BAG_ITEM_QUALITY_COLORS[followerInfo.quality];
	if (color) then
		self.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
		self.Name:SetVertexColor(color.r, color.g, color.b);
	else
		self.PortraitFrame.LevelBorder:SetVertexColor(1, 1, 1);
		self.Name:SetVertexColor(1, 1, 1);
	end
	SetPortraitTexture(self.PortraitFrame.Portrait, followerInfo.displayID);
	self.Model:SetDisplayInfo(followerInfo.displayID);
	if (followerInfo.level == GARRISON_FOLLOWER_MAX_LEVEL) then
		self.XPText:Hide();
		self.XPLabel:Hide();
		self.XPBar:Hide();
		self.ItemLevel:SetText(ITEM_LEVEL_ABBR.." "..followerInfo.iLevel)
		self.ItemLevel:Show();
	else
		local xpLeft = followerInfo.levelXP - followerInfo.xp;
		self.XPText:SetText(xpLeft..XP);
		self.XPText:Show();
		self.XPLabel:Show();
		self.XPBar:Show();
		self.XPBar:SetMinMaxValues(0, followerInfo.levelXP);
		self.XPBar:SetValue(followerInfo.xp);
		self.ItemLevel:Hide();
	end
	
	for i=1, #self.Abilities do
		self.Abilities[i]:Hide();
	end
	for i=1, #self.Traits do
		self.Traits[i]:Hide();
	end
	
	local numAbilities = 0;
	local numTraits = 0;
	if (not followerInfo.abilities) then
		followerInfo.abilities = C_Garrison.GetFollowerAbilities(followerInfo.followerID);
	end
	for i=1, #followerInfo.abilities do
		local ability = followerInfo.abilities[i];
		local Frame;
		if (ability.isTrait) then
			numTraits = numTraits + 1;
			if (not self.Traits[numTraits]) then
				self.Traits[numTraits] = CreateFrame("Frame", nil, self, "GarrisonFollowerPageAbilityTemplate");
				self.Traits[numTraits]:SetPoint("TOPLEFT", self.Traits[numTraits-1], "BOTTOMLEFT", 0, -2);
			end
			Frame = self.Traits[numTraits];
		else
			numAbilities = numAbilities + 1;
			if (not self.Abilities[numAbilities]) then
				self.Abilities[numAbilities] = CreateFrame("Frame", nil, self, "GarrisonFollowerPageAbilityTemplate");
				self.Abilities[numAbilities]:SetPoint("TOPLEFT", self.Abilities[numAbilities-1], "BOTTOMLEFT", 0, -2);
			end
			Frame = self.Abilities[numAbilities];
		end
		
		Frame.Name:SetText(ability.name);
		Frame.Icon:SetTexture(ability.icon);
		Frame.Description:SetText(ability.description);
		
		local numCounters = 0;
		if (ability.counters) then
			for id, counter in pairs(ability.counters) do
				numCounters = numCounters + 1;
				if (not Frame.Counters[numCounters]) then
					Frame.Counters[numCounters] = CreateFrame("Frame", nil, Frame, "GarrisonMissionAbilityCounterTemplate");
					Frame.Counters[numCounters]:SetPoint("LEFT", Frame.Counters[numCounters-1], "RIGHT", 2, 0)
				end
				local Counter = Frame.Counters[numCounters];
				Counter.Icon:SetTexture(counter.icon);
				Counter.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
				Counter.tooltip = counter.name;
				Counter:Show();
			end
			Frame.CounterString:Show();
		else
			Frame.CounterString:Hide();
		end
		local startIndex = numCounters + 1;
		for j = startIndex, #Frame.Counters do
			Frame.Counters[j]:Hide();
		end
		
		Frame:Show();
	end
	
	if (numAbilities == 0) then
		self.AbilitiesText:Hide();
		self.TraitsText:ClearAllPoints();
		self.TraitsText:SetPoint("TOPLEFT", self.AbilitiesText, "TOPLEFT");
	else
		self.AbilitiesText:Show();
		self.TraitsText:ClearAllPoints();
		local offset = numAbilities * (self.Abilities[1]:GetHeight() + 2) + 10;
		self.TraitsText:SetPoint("TOPLEFT", self.AbilitiesText, "BOTTOMLEFT", 0, -offset);
	end
	
	if (numTraits == 0) then
		self.TraitsText:Hide();
	else
		self.TraitsText:Show();
	end
end

---------------------------------------------------------------------------------
--- Mission List                                                              ---
---------------------------------------------------------------------------------

function GarrisonMissionList_OnShow(self)
	GarrisonMissionList_UpdateMissions()
end

function GarrisonMissionList_OnHide(self)
	self.missions = nil;
end

function GarrisonMissionList_UpdateMissions()
	local self = GarrisonMissionFrame.MissionTab.MissionList;
	self.missions = C_Garrison.GetMissions();
	GarrisonMissionList_Update();
end

function GarrisonMissionList_Update()
	local missions = GarrisonMissionFrame.MissionTab.MissionList.missions or {};
	local numMissions = #missions;
	local scrollFrame = GarrisonMissionFrame.MissionTab.MissionList.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numMissions ) then
			local mission = missions[index];
			button.id = index;
			button.info = mission;
			button.Title:SetText(mission.name);
			button.Level:SetText(mission.level);
			button.Summary:SetText("Combat - "..mission.duration);
			button.Size:SetText(mission.numFollowers);
			button.XP:SetText(mission.baseXP and BreakUpLargeNumbers(mission.baseXP) or "0");
			local _, _, currencyTexture = GetCurrencyInfo(mission.baseCurrencyID);
			button.MaterialIcon:SetTexture(currencyTexture);
			button.Material:SetText(mission.baseCurrencyAmount);
			button.Description:SetText(mission.description);
			if (button.id == GarrisonMissionFrame.selectedMission) then
				GarrisonMissionButton_Select(button);
			else
				GarrisonMissionButton_UnSelect(button);
			end
			button:Show();
		else
			button:Hide();
		end
	end
	
	local totalHeight = numMissions * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GarrisonMissionButton_Select(self)
	self:SetHeight(112);
	self.Title:SetVertexColor(1, 1, 1);
	self.Selected:Show();
	self.SelectedHighlight:Show();
	self.SizeBG:Show();
	self.Size:Show();
	self.Description:Show();
	self.ViewButton:Show();
	GarrisonMissionButton_ToggleHighlight(self, false);
end

function GarrisonMissionButton_UnSelect(self)
	self:SetHeight(64);
	self.Title:SetVertexColor(0.792, 0.776, 0.757);
	self.Selected:Hide();
	self.SelectedHighlight:Hide();
	self.SizeBG:Hide();
	self.Size:Hide();
	self.Description:Hide();
	self.ViewButton:Hide();
	GarrisonMissionButton_ToggleHighlight(self, true);
end

function GarrisonMissionButton_ToggleHighlight(self, on)
	if (on) then
		self.HighlightT:Show();
		self.HighlightB:Show();
		self.HighlightTL:Show();
		self.HighlightTR:Show();
		self.HighlightBL:Show();
		self.HighlightBR:Show();
		self.Highlight:Show();
	else
		self.HighlightT:Hide();
		self.HighlightB:Hide();
		self.HighlightTL:Hide();
		self.HighlightTR:Hide();
		self.HighlightBL:Hide();
		self.HighlightBR:Hide();
		self.Highlight:Hide();
	end
end

function GarrisonMissionButton_OnClick(self, button)
	GarrisonMissionFrame.selectedMission = self.id;
	GarrisonMissionList_Update();
end

function GarrisonMissionViewButton_OnClick(self)
	GarrisonMissionFrame.MissionTab.MissionList:Hide();
	GarrisonMissionFrame.MissionTab.MissionPage:Show();
	GarrisonMissionPage_ShowMission(self:GetParent().info);
end

---------------------------------------------------------------------------------
--- Mission Page                                                              ---
---------------------------------------------------------------------------------

function GarrisonMissionPage_ShowMission(missionInfo)
	local self = GarrisonMissionFrame.MissionTab.MissionPage;
	self.mission = missionInfo.missionID;
	local location, travelTime, missionTime, enemies, bronzeChance, silverChance, goldChance = C_Garrison.GetMissionInfo(missionInfo.missionID);
	
	self.Stage.Level:SetText(missionInfo.level);
	self.Stage.Title:SetText(missionInfo.name);
	self.Stage.MissionSummary:SetText("Combat - "..missionInfo.duration);
	self.Stage.MissionDescription:SetText(missionInfo.description);
	self.Stage.MissionArea:SetText(location);
	if (travelTime) then
		self.Stage.MissionTravel:SetText("Travel: "..travelTime);
	end
	if (missionTime) then
		self.Stage.MissionTime:SetText("Mission: "..missionTime);
	end
	
	self.Rewards.XP:SetText(BreakUpLargeNumbers(missionInfo.baseXP));
	local _, _, currencyTexture = GetCurrencyInfo(missionInfo.baseCurrencyID);
	self.Rewards.MaterialIcon:SetTexture(currencyTexture);
	self.Rewards.Material:SetText(missionInfo.baseCurrencyAmount);
	self.Rewards.BronzeChance:SetFormattedText(PERCENTAGE_STRING, bronzeChance);
	self.Rewards.SilverChance:SetFormattedText(PERCENTAGE_STRING, silverChance);
	self.Rewards.GoldChance:SetFormattedText(PERCENTAGE_STRING, goldChance);
	
	GarrisonMissionPage_SetPartySize(missionInfo.numFollowers);
	GarrisonMissionPage_SetEnemies(enemies);
	
end

function GarrisonMissionPage_SetPartySize(size)
	local self = GarrisonMissionFrame.MissionTab.MissionPage;
	
	self.Rewards:SetHeight(113);
	if (size == 1) then
		self.Rewards:SetHeight(142);
		self.SmallParty:Show();
		self.MediumParty:Hide();
		self.LargeParty:Hide();
	elseif (size == 2 or size == 3) then
		self.SmallParty:Hide();
		self.MediumParty:Show();
		self.LargeParty:Hide();
		if (size == 2) then
			self.MediumParty.Follower3:Hide();
			self.MediumParty.Follower1:SetPoint("TOPLEFT", self.MediumParty, "TOPLEFT", 80, -20);
			self.MediumParty.Follower2:SetPoint("LEFT", self.MediumParty.Follower1, "RIGHT", 60, 0);
		else
			self.MediumParty.Follower3:Show();
			self.MediumParty.Follower1:SetPoint("TOPLEFT", self.MediumParty, "TOPLEFT", 20, -20);
			self.MediumParty.Follower2:SetPoint("LEFT", self.MediumParty.Follower1, "RIGHT", 0, 0);
		end
		self.MediumParty:SetID(size);
	else
		self.SmallParty:Hide();
		self.MediumParty:Hide();
		self.LargeParty:Show();
		if (size == 4) then
			self.LargeParty.Follower5:Hide();
			self.LargeParty.Follower1:SetPoint("TOPLEFT", self.LargeParty, "TOPLEFT", 35, -24);
			self.LargeParty.Follower2:SetPoint("LEFT", self.LargeParty.Follower1, "RIGHT", 30, 0);
			self.LargeParty.Follower3:SetPoint("LEFT", self.LargeParty.Follower2, "RIGHT", 30, 0);
			self.LargeParty.Follower4:SetPoint("LEFT", self.LargeParty.Follower3, "RIGHT", 30, 0);
		else
			self.LargeParty.Follower5:Show();
			self.LargeParty.Follower1:SetPoint("TOPLEFT", self.LargeParty, "TOPLEFT", 10, -24);
			self.LargeParty.Follower2:SetPoint("LEFT", self.LargeParty.Follower1, "RIGHT", 7, 0);
			self.LargeParty.Follower3:SetPoint("LEFT", self.LargeParty.Follower2, "RIGHT", 7, 0);
			self.LargeParty.Follower4:SetPoint("LEFT", self.LargeParty.Follower3, "RIGHT", 7, 0);
		end
		self.LargeParty:SetID(size);
	end
end

function GarrisonMissionPage_SetNumEnemies(size)
	local self = GarrisonMissionFrame.MissionTab.MissionPage;
	
	if (size < 4) then
		self.FewEnemies:Show();
		self.ManyEnemies:Hide();
		if (size == 1) then
			self.FewEnemies.Enemy2:Hide();
			self.FewEnemies.Enemy3:Hide();
			self.FewEnemies.Enemy1:SetPoint("TOPLEFT", self.FewEnemies, "TOPLEFT", 30, -13);
		elseif (size == 2) then
			self.FewEnemies.Enemy2:Show();
			self.FewEnemies.Enemy3:Hide();
			self.FewEnemies.Enemy1:SetPoint("TOPLEFT", self.FewEnemies, "TOPLEFT", 75, -13);
			self.FewEnemies.Enemy2:SetPoint("LEFT", self.FewEnemies.Enemy1, "RIGHT", 46, 0);
		else
			self.FewEnemies.Enemy2:Show();
			self.FewEnemies.Enemy3:Show();
			self.FewEnemies.Enemy1:SetPoint("TOPLEFT", self.FewEnemies, "TOPLEFT", 20, -13);
			self.FewEnemies.Enemy2:SetPoint("LEFT", self.FewEnemies.Enemy1, "RIGHT", -14, 0);
		end
	else
		self.FewEnemies:Hide();
		self.ManyEnemies:Show();
		if (size == 4) then
			self.ManyEnemies.Enemy5:Hide();
			self.ManyEnemies.Enemy1:SetPoint("TOPLEFT", self.ManyEnemies, "TOPLEFT", 35, -10);
			self.ManyEnemies.Enemy2:SetPoint("LEFT", self.ManyEnemies.Enemy1, "RIGHT", 30, 0);
			self.ManyEnemies.Enemy3:SetPoint("LEFT", self.ManyEnemies.Enemy2, "RIGHT", 30, 0);
			self.ManyEnemies.Enemy4:SetPoint("LEFT", self.ManyEnemies.Enemy3, "RIGHT", 30, 0);
		else
			self.ManyEnemies.Enemy5:Show();
			self.ManyEnemies.Enemy1:SetPoint("TOPLEFT", self.ManyEnemies, "TOPLEFT", 9, -10);
			self.ManyEnemies.Enemy2:SetPoint("LEFT", self.ManyEnemies.Enemy1, "RIGHT", 7, 0);
			self.ManyEnemies.Enemy3:SetPoint("LEFT", self.ManyEnemies.Enemy2, "RIGHT", 7, 0);
			self.ManyEnemies.Enemy4:SetPoint("LEFT", self.ManyEnemies.Enemy3, "RIGHT", 7, 0);
		end
	end
	
end

function GarrisonMissionPage_SetEnemies(enemies)
	GarrisonMissionPage_SetNumEnemies(#enemies)
	local enemyFrames;
	if (#enemies < 4) then
		enemyFrames = GarrisonMissionFrame.MissionTab.MissionPage.FewEnemies;
	else
		enemyFrames = GarrisonMissionFrame.MissionTab.MissionPage.ManyEnemies;
	end
	
	for i=1, #enemies do
		local Frame = enemyFrames["Enemy"..i]
		local enemy = enemies[i];
		Frame.Name:SetText(enemy.name);
		if (enemy.displayID) then
			SetPortraitTexture(Frame.PortraitFrame.Portrait, enemy.displayID);
		end
		if (enemy.creatureType) then
			Frame.PortraitFrame.Type:SetTexture(enemy.creatureType);
			Frame.PortraitFrame.Type:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			Frame.PortraitFrame.Type:Show();
			Frame.PortraitFrame.TypeRing:Show();
		else
			Frame.PortraitFrame.Type:Hide();
			Frame.PortraitFrame.TypeRing:Hide();
		end
		local numMechs = 1;
		for id, mechanic in pairs(enemy.mechanics) do
			if (not Frame.Mechanics[numMechs]) then
				Frame.Mechanics[numMechs] = CreateFrame("Frame", nil, Frame, "GarrisonMissionEnemyMechanicTemplate");
				Frame.Mechanics[numMechs]:SetPoint("LEFT", Frame.Mechanics[numMechs-1], "RIGHT", 0, 0);
			end
			local Mechanic = Frame.Mechanics[numMechs];
			Mechanic.Icon:SetTexture(mechanic.icon);
			Mechanic.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			Mechanic.tooltip = mechanic.name;
			Mechanic.mechanicID = id;
			Mechanic:Show();
			numMechs = numMechs + 1;
		end
		for j=(numMechs + 1), #Frame.Mechanics do
			Frame.Mechanics[j]:Hide();
			Frame.Mechanics[j].mechanicID = nil;
		end
	end
end

function GarrisonMissionPageFollowerFrame_SetFollower(frame, info)
	if (frame.info) then
		GarrisonMissionFollowerFrame_ClearFollower(frame);
	end
	frame.info = info;
	frame.Name:Show();
	frame.Name:SetText(info.name);
	if (frame.Class) then
		frame.Class:Show();
	end
	frame.PortraitFrame.Empty:Hide();
	SetPortraitTexture(frame.PortraitFrame.Portrait, info.displayID);
	frame.PortraitFrame.Level:SetText(info.level);
	local missionPage = GarrisonMissionFrame.MissionTab.MissionPage;
	C_Garrison.AddFollowerToMission(missionPage.mission, info.followerID);
	--update bonus loot chances
	local bronzeChance, silverChance, goldChance = C_Garrison.GetBonusRewardChances(missionPage.mission);
	missionPage.Rewards.BronzeChance:SetFormattedText(PERCENTAGE_STRING, bronzeChance);
	missionPage.Rewards.SilverChance:SetFormattedText(PERCENTAGE_STRING, silverChance);
	missionPage.Rewards.GoldChance:SetFormattedText(PERCENTAGE_STRING, goldChance);
	
	GarrisonMissionPage_SetCounters();
end

function GarrisonMissionFollowerFrame_ClearFollower(frame)
	local followerID = frame.info and frame.info.followerID or nil;
	frame.info = nil;
	frame.Name:Hide();
	if (frame.Class) then
		frame.Class:Hide();
	end
	frame.PortraitFrame.Empty:Show();
	local missionPage = GarrisonMissionFrame.MissionTab.MissionPage;
	if (followerID) then
		C_Garrison.RemoveFollowerFromMission(missionPage.mission, followerID);
		--update bonus loot chances
		local bronzeChance, silverChance, goldChance = C_Garrison.GetBonusRewardChances(missionPage.mission);
		missionPage.Rewards.BronzeChance:SetFormattedText(PERCENTAGE_STRING, bronzeChance);
		missionPage.Rewards.SilverChance:SetFormattedText(PERCENTAGE_STRING, silverChance);
		missionPage.Rewards.GoldChance:SetFormattedText(PERCENTAGE_STRING, goldChance);
	end
	
	GarrisonMissionPage_SetCounters();
end

function GarrisonMissionPageParty_IsEmpty(partyFrame)
	for i=1, partyFrame.partySize do
		local Follower = partyFrame["Follower"..i];
		if (Follower.info) then
			return false;
		end
	end
	return true;
end

function GarrisonMissionPageParty_Reset(partyFrame)
	for i=1, partyFrame.partySize do
		local Follower = partyFrame["Follower"..i];
		GarrisonMissionFollowerFrame_ClearFollower(Follower);
	end
	
	partyFrame.Buffs:Hide();
	
	if (partyFrame.partySize == 1) then
		partyFrame.Follower1.EmptyString:Show();
		partyFrame.Model:Hide();
		partyFrame.EmptyShadow:Show();
	else
		partyFrame.EmptyString:Show();
	end
end

function GarrisonMissionPage_ClearCounters(enemiesFrame)
	for i=1, enemiesFrame.numEnemies do
		local frame = enemiesFrame["Enemy"..i];
		for j=1, #frame.Mechanics do
			frame.Mechanics[j].Check:Hide();
		end
	end
end

--this function puts check marks on the encounter mechanics countered by the slotted followers abilities
function GarrisonMissionPage_SetCounters()
	local missionPage = GarrisonMissionFrame.MissionTab.MissionPage;
	local enemiesFrame, partyFrame;
	if (missionPage.FewEnemies:IsShown()) then
		enemiesFrame = missionPage.FewEnemies;
	else
		enemiesFrame = missionPage.ManyEnemies;
	end
	if (missionPage.SmallParty:IsShown()) then
		partyFrame = missionPage.SmallParty;
	elseif (missionPage.MediumParty:IsShown()) then
		partyFrame = missionPage.MediumParty;
	else
		partyFrame = missionPage.LargeParty;
	end
	
	GarrisonMissionPage_ClearCounters(enemiesFrame);
	for f=1, partyFrame.partySize do
		local follower = partyFrame["Follower"..f];
		if (follower.info) then
			if (not follower.info.abilities) then
				follower.info.abilities = C_Garrison.GetFollowerAbilities(follower.info.followerID)
			end
			for a=1, #follower.info.abilities do
				local ability = follower.info.abilities[a];
				for counterID, counterInfo in pairs(ability.counters) do
					for e=1, enemiesFrame.numEnemies do
						local enemy = enemiesFrame["Enemy"..e];
						for m=1, #enemy.Mechanics do
							if (counterID == enemy.Mechanics[m].mechanicID) then
								enemy.Mechanics[m].Check:Show();
								
							end
						end
					end
				end
			end
		end
	end
end

function GarrisonMissionPageCloseButton_OnClick(self)
	GarrisonMissionFrame.MissionTab.MissionPage:Hide();
	GarrisonMissionFrame.MissionTab.MissionList:Show();
	GarrisonMissionPageParty_Reset(GarrisonMissionFrame.MissionTab.MissionPage.SmallParty);
	GarrisonMissionPageParty_Reset(GarrisonMissionFrame.MissionTab.MissionPage.MediumParty);
	GarrisonMissionPageParty_Reset(GarrisonMissionFrame.MissionTab.MissionPage.LargeParty);
end

function GarrisonSingleParty_ReceiveDrag(self)
	if (not GarrisonFollowerPlacer:IsShown()) then
		return;
	end
	
	local follower = GarrisonFollowerPlacer.info;
	
	self.EmptyShadow:Hide();
	self.Follower1.EmptyString:Hide();
	
	GarrisonMissionPageFollowerFrame_SetFollower(self.Follower1, follower)
	self.Model:Show();
	self.Model:SetDisplayInfo(follower.displayID);
	self.Buffs:Show();
	
	GarrisonFollowerPlacer:Hide();
	GarrisonFollowerPlacerFrame:Hide();
end

function GarrisonManyParty_ReceiveDrag(self)
	if (not GarrisonFollowerPlacer:IsShown()) then
		return;
	end
	
	local follower = GarrisonFollowerPlacer.info;
	
	self.EmptyString:Hide();
	GarrisonFollowerPlacer:Hide();
	GarrisonFollowerPlacerFrame:Hide();
	
	local followerFrame;
	for i=1, self.partySize do
		if (not self["Follower"..i].info) then
			followerFrame = self["Follower"..i];
			break;
		elseif (self["Follower"..i].info.followerID == follower.followerID) then
			return;
		end
	end
	if (not followerFrame) then
		return;
	end
	
	GarrisonMissionPageFollowerFrame_SetFollower(followerFrame, follower)
	self.Buffs:Show();
end

function GarrisonMissionPageFollowerFrame_OnDragStart(self)
	GarrisonFollowerPlacer:SetDisplayInfo(self.info.displayID)
	GarrisonFollowerPlacer:SetAnimation(474);
	GarrisonFollowerPlacer.info = self.info;
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonFollowerPlacer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + 40);
	GarrisonFollowerPlacer:Show();
	GarrisonFollowerPlacer:SetScript("OnUpdate", GarrisonFollowerPlacer_OnUpdate);
end

function GarrisonMissionPageFollowerFrame_OnDragStop(self)
	GarrisonFollowerPlacer:Hide();
	GarrisonFollowerPlacerFrame:Hide();
	
	if (self:IsMouseOver()) then
		return;
	end
	
	GarrisonMissionFollowerFrame_ClearFollower(self);
	
	local partyFrame = self:GetParent()
	if (GarrisonMissionPageParty_IsEmpty(partyFrame)) then
		GarrisonMissionPageParty_Reset(partyFrame);
	end
end

function GarrisonMissionPageStartMissionButton_OnClick(self)
	local missionPage = GarrisonMissionFrame.MissionTab.MissionPage;
	if (not missionPage.mission) then
		return;
	end
	C_Garrison.StartMission(missionPage.mission);
	GarrisonMissionList_UpdateMissions();
	GarrisonFollowerList_UpdateFollowers();
	missionPage.CloseButton:Click();
end

---------------------------------------------------------------------------------
--- Mission Complete                                                          ---
---------------------------------------------------------------------------------

function GarrisonMissionComplete_OnLoad(self)
	self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE");
end

function GarrisonMissionComplete_OnEvent(self, event, ...)
	if (event == "GARRISON_MISSION_BONUS_ROLL_COMPLETE") then
		missionID, chestIndex, result = ...;
		GarrisonMissionCompleteReward_OnResult(missionID, chestIndex, result);
	end
end

function GarrisonMissionFrame_ShowCompleteMissions()
	local self = GarrisonMissionFrame.MissionComplete;
	
	GarrisonMissionFrame.MissionTab:Hide();
	GarrisonMissionFrame.FollowerTab:Hide();
	GarrisonMissionFrame.FollowerList:Hide();
	
	GarrisonMissionFrame.Rewards:Show();
	GarrisonMissionFrame.MissionComplete:Show();
	GarrisonMissionFrame.Overlay:Show();
	
	self.currentIndex = 1;
	GarrisonMissionComplete_Initialize(self.completeMissions, self.currentIndex);
end

function HideCompleteMissions()
	local self = GarrisonMissionFrame;
	
	self.MissionTab:Show();
	self.FollowerList:Show();
	
	self.Rewards:Hide();
	self.MissionComplete:Hide();
	self.Overlay:Hide();
end

function GarrisonMissionComplete_Initialize(missionList, index)
	local self = GarrisonMissionFrame.MissionComplete;
	if (not missionList or #missionList == 0 or index == 0) then
		HideCompleteMissions();
		return;
	end
	if (index > #missionList) then
		self.currentIndex = nil;
		self.completeMissions = nil;
		HideCompleteMissions();
		return;
	end
	local mission = missionList[index];
	
	self.Stage.FewFollowers:Hide();
	self.Stage.ManyFollowers:Hide();
	self.Stage.BaseRewards:Hide();
	self.Stage.Encounters:Show();
	
	self.Stage.MissionInfo.Title:SetText(mission.name);
	self.Stage.MissionInfo.Level:SetText(mission.level);
	self.Stage.MissionInfo.Location:SetText(mission.location);
	self.Stage.MissionInfo.NumViewed:SetText(self.currentIndex.." / "..#self.completeMissions);
	
	local _, _, currencyTexture = GetCurrencyInfo(mission.baseCurrencyID);
	self.Stage.BaseRewards.MaterialIcon:SetTexture(currencyTexture);
	self.Stage.BaseRewards.Material:SetText(mission.baseCurrencyAmount);
	self.Stage.BaseRewards.XP:SetText(mission.baseXP);
	
	self.BonusRewards.Saturated:Hide();
	for i=1, 3 do
		self.BonusRewards["Chest"..i].Lock:SetAlpha(1);
		self.BonusRewards["Chest"..i].Chest:SetAnimation(148);
		self.BonusRewards["Chest"..i].Chance:SetFormattedText(PERCENTAGE_STRING, mission.lootChances[i]);
		self.BonusRewards["Chest"..i]:Show();
	end
	self.BonusRewards.Chest2:ClearAllPoints();
	self.BonusRewards.Chest2:SetPoint("LEFT", self.BonusRewards.Chest1, "RIGHT", -23, 0);
	self.BonusRewards.Chest3:ClearAllPoints();
	self.BonusRewards.Chest3:SetPoint("LEFT", self.BonusRewards.Chest2, "RIGHT", -23, 0);
	
	local encounters = C_Garrison.GetMissionCompleteEncounters(mission.missionID);
	GarrisonMissionComplete_SetNumEncounters(#encounters);
	for i=1, #encounters do
		local encounter = self.Stage.Encounters["Encounter"..i]
		if (encounters[i].displayID) then
			SetPortraitTexture(encounter.Portrait, encounters[i].displayID);
		end
	end
	
	local followerFrame;
	if (#mission.followers > 3) then
		followerFrame = self.Stage.ManyFollowers;
	else
		followerFrame = self.Stage.FewFollowers;
	end
	self.animInfo = {};
	self.animIndex = 1;
	for i=1, #mission.followers do
		local follower = followerFrame["Follower"..i];
		local name, displayID, level, quality, currXP, maxXP, height, scale, movementType, impactDelay, castID, impactID = 
					C_Garrison.GetFollowerMissionCompleteInfo(mission.followers[i]);
		SetPortraitTexture(follower.PortraitFrame.Portrait, displayID);
		follower.Name:SetText(name);
		follower.PortraitFrame.Level:SetText(level);
		local color = BAG_ITEM_QUALITY_COLORS[quality];
		if (color) then
	        follower.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
        else
	        follower.PortraitFrame.LevelBorder:SetVertexColor(1, 1, 1);
        end
		follower.XP:SetMinMaxValues(0, maxXP);
		follower.XP:SetValue(currXP);
		follower.XPGain.Text:SetText("+"..mission.baseXP);
		if (encounters[i]) then --cannot have more animations than encounters
			self.animInfo[i] = { 	displayID = displayID,
									height = height, 
									scale = scale, 
									movementType = movementType,
									impactDelay = impactDelay,
									castID = castID,
									impactID = impactID,
									enemyDisplayID = encounters[i].displayID,
									enemyScale = encounters[i].scale,
									enemyHeight = encounters[i].height,
								}
		end
	end
	
	if (mission.state >= 0) then
		self.Stage.Encounters:Hide();
		GarrisonMissionCompleteEncountersAnim_OnFinished();
		if (mission.state == 1) then
			self.BonusRewards.Chest1:Hide();
			self.BonusRewards.Chest2:ClearAllPoints();
			self.BonusRewards.Chest2:SetPoint("LEFT", self.BonusRewards.Chest1, "LEFT");
			self.BonusRewards.Chest3:ClearAllPoints();
			self.BonusRewards.Chest3:SetPoint("LEFT", self.BonusRewards.Chest2, "RIGHT", 126, 0);
			self.BonusRewards.Chest2.FadeOutLock:Play();
		elseif (mission.state == 2) then
			self.BonusRewards.Chest1:Hide();
			self.BonusRewards.Chest2:Hide();
			self.BonusRewards.Chest3:ClearAllPoints();
			self.BonusRewards.Chest3:SetPoint("LEFT", self.BonusRewards.Chest2, "LEFT");
			self.BonusRewards.Chest3.FadeOutLock:Play();
		end
	else
		self.Stage.ModelFarLeft:Hide();
		self.Stage.ModelFarRight:Hide();
		self.Stage.ModelMiddle:Hide();
		GarrisonMissionComplete_ShowNextAnimation();
	end
end

function GarrisonMissionComplete_SetNumEncounters(size)
	local self = GarrisonMissionFrame.MissionComplete.Stage.Encounters;
	
	local _, _, _, width = self.Encounter5:GetPoint(1);
	
	self.Encounter2:Hide();
	self.Encounter3:Hide();
	self.Encounter4:Hide();
	self.Encounter5:Hide();
	
	if (size > 1) then
		self.Encounter2:Show();
	end
	if (size > 2) then
		self.Encounter3:Show();
	end
	if (size > 3) then
		self.Encounter4:Show();
	end
	if (size > 4) then
		self.Encounter5:Show();
	end
	
	local step = width / size;
	local currentAnchor = step;
	for i=1, size do
		local encounter = self["Encounter"..i];
		encounter:SetPoint("CENTER", self.BarNub, "CENTER", currentAnchor, 3);
		currentAnchor = currentAnchor + step;
	end
	
end

function GarrisonMissionCompleteReward_OnClick(self)
	local missionList = GarrisonMissionFrame.MissionComplete.completeMissions;
	local missionIndex = GarrisonMissionFrame.MissionComplete.currentIndex;
	C_Garrison.MissionBonusRoll(missionList[missionIndex].missionID, self.index);
end

function GarrisonMissionCompleteReward_OnResult(missionID, chestIndex, result)
	local missionList = GarrisonMissionFrame.MissionComplete.completeMissions;
	local missionIndex = GarrisonMissionFrame.MissionComplete.currentIndex;
	if (missionList[missionIndex].missionID ~= missionID) then
		return
	end
	
	local chest = GarrisonMissionFrame.MissionComplete.BonusRewards["Chest"..chestIndex];
	if (not chest) then
		return;
	end
	if (result) then
		chest.Chest:SetAnimation(154);
	else
		chest.Chest:SetAnimation(153);
	end
	
	local nextIndex = chestIndex + 1;
	local nextChest = GarrisonMissionFrame.MissionComplete.BonusRewards["Chest"..nextIndex];
	if (not nextChest) then
		return;
	end
	nextChest.FadeOutLock:Play();
end

function GarrisonMissionCompleteNextButton_OnClick(self)
	local frame = GarrisonMissionFrame.MissionComplete;
	
	frame.currentIndex = frame.currentIndex + 1;
	GarrisonMissionComplete_Initialize(frame.completeMissions, frame.currentIndex);
end

---------------------------------------------------------------------------------
--- Mission Complete: Animation stuff                                         ---
---------------------------------------------------------------------------------

GARRISON_ANIMATION_LENGTH = 1;

-- this function assumes that a table of animation info has been attached to the MissionComplete frame
function GarrisonMissionComplete_ShowNextAnimation()
	local self = GarrisonMissionFrame.MissionComplete;
	if (not self.animInfo or not self.animIndex) then
		return;
	end
	
	local currentAnim = self.animInfo[self.animIndex];
	if (not currentAnim) then 
		self.animInfo = nil;
		self.animIndex = nil;
		GarrisonMissionComplete_ShowEnding();
		return; 
	end
	
	self.Stage.ModelLeft:Show();
	self.Stage.ModelRight:Show();
	self.Stage.ModelLeft:SetAlpha(0);
	self.Stage.ModelRight:SetAlpha(0);
	self.Stage.ModelLeft:SetDisplayInfo(currentAnim.displayID or 0);
	self.Stage.ModelRight:SetDisplayInfo(currentAnim.enemyDisplayID or 0);
	self.Stage.ModelLeft:InitializePanCamera(currentAnim.scale or 1)
	self.Stage.ModelRight:InitializePanCamera(currentAnim.enemyScale or 1);
	self.Stage.ModelLeft:SetHeightFactor(currentAnim.height or 0.5);
	self.Stage.ModelRight:SetHeightFactor(currentAnim.enemyHeight or 0.5);
	self.Stage.ModelRight:SetAnimOffset(currentAnim.impactDelay  or 0);
	self.Stage.ModelLeft:StartPan(currentAnim.movementType or LE_PAN_NONE, GARRISON_ANIMATION_LENGTH, true, currentAnim.castID);
	self.Stage.ModelRight:StartPan(LE_PAN_NONE, GARRISON_ANIMATION_LENGTH, true, currentAnim.impactID);
	
	self.animIndex = self.animIndex + 1;
end

---------------------------------------------------------------------------------
--- Mission Complete: Follower pose stuff                                     ---
---------------------------------------------------------------------------------

function GarrisonMissionComplete_ShowEnding()
	local self = GarrisonMissionFrame.MissionComplete.Stage;
	
	self.Encounters.FadeOut:Play();
	
end	

function GarrisonMissionCompleteEncountersAnim_OnFinished()
	local self = GarrisonMissionFrame.MissionComplete.Stage;
	local missionList = GarrisonMissionFrame.MissionComplete.completeMissions;
	local missionIndex = GarrisonMissionFrame.MissionComplete.currentIndex;
	C_Garrison.MarkMissionComplete(missionList[missionIndex].missionID);
	
	local numFollowers = #missionList[missionIndex].followers;
	GarrisonMissionComplete_SetNumFollowers(numFollowers);
	_G["Ending"..numFollowers]();
	if (self.ModelLeft:IsShown()) then
		self.ModelLeft.FadeIn:Play();
	end
	if (self.ModelRight:IsShown()) then
		self.ModelRight.FadeIn:Play();
	end
	if (self.ModelFarLeft:IsShown()) then
		self.ModelFarLeft.FadeIn:Play();
	end
	if (self.ModelFarRight:IsShown()) then
		self.ModelFarRight.FadeIn:Play();
	end
	if (self.ModelMiddle:IsShown()) then
		self.ModelMiddle.FadeIn:Play();
	end
	if (#missionList[missionIndex].followers <= 3) then
		self.FewFollowers.FadeIn:Play();
	else
		self.ManyFollowers.FadeIn:Play();
	end
	self.BaseRewards:Show();
	self.BaseRewards.FadeIn:Play();
end

function GarrisonMissionComplete_SetNumFollowers(size)
	local self = GarrisonMissionFrame.MissionComplete.Stage;
	
	if (size < 4) then
		self.FewFollowers:Show();
		self.ManyFollowers:Hide();
		if (size == 1) then
			Ending1();
			self.FewFollowers.Follower2:Hide();
			self.FewFollowers.Follower3:Hide();
			self.FewFollowers.Follower1:SetPoint("LEFT", self.FewFollowers, "BOTTOMLEFT", 200, -4);
		elseif (size == 2) then
			Ending2();
			self.FewFollowers.Follower2:Show();
			self.FewFollowers.Follower3:Hide();
			self.FewFollowers.Follower1:SetPoint("LEFT", self.FewFollowers, "BOTTOMLEFT", 75, -4);
			self.FewFollowers.Follower2:SetPoint("LEFT", self.FewFollowers.Follower1, "RIGHT", 75, 0);
		else
			Ending3();
			self.FewFollowers.Follower2:Show();
			self.FewFollowers.Follower3:Show();
			self.FewFollowers.Follower1:SetPoint("LEFT", self.FewFollowers, "BOTTOMLEFT", 25, -4);
			self.FewFollowers.Follower2:SetPoint("LEFT", self.FewFollowers.Follower1, "RIGHT", 0, 0);
		end
	else
		self.FewFollowers:Hide();
		self.ManyFollowers:Show();
		if (size == 4) then
			Ending4();
			self.ManyFollowers.Follower5:Hide();
			self.ManyFollowers.Follower1:SetPoint("LEFT", self.ManyFollowers, "BOTTOMLEFT", 50, -7);
			self.ManyFollowers.Follower2:SetPoint("LEFT", self.ManyFollowers.Follower1, "RIGHT", 40, 0);
			self.ManyFollowers.Follower3:SetPoint("LEFT", self.ManyFollowers.Follower2, "RIGHT", 40, 0);
			self.ManyFollowers.Follower4:SetPoint("LEFT", self.ManyFollowers.Follower3, "RIGHT", 40, 0);
		else
			Ending5();
			self.ManyFollowers.Follower5:Show();
			self.ManyFollowers.Follower1:SetPoint("LEFT", self.ManyFollowers, "BOTTOMLEFT", 27, -7);
			self.ManyFollowers.Follower2:SetPoint("LEFT", self.ManyFollowers.Follower1, "RIGHT", 20, 0);
			self.ManyFollowers.Follower3:SetPoint("LEFT", self.ManyFollowers.Follower2, "RIGHT", 20, 0);
			self.ManyFollowers.Follower4:SetPoint("LEFT", self.ManyFollowers.Follower3, "RIGHT", 20, 0);
		end
	end
	
end

function MissionComplete_OnEncounterAnimFinished()
	local self = GarrisonMissionFrame.MissionComplete.Stage;
	
end

---------------------------------------------------------------------------------
--- Mission Complete: Stage Stuff                                             ---
---------------------------------------------------------------------------------

function GarrisonMissionCompleteStage_OnLoad(self)
	self.LocBack:SetAtlas("_GarrMissionLocation-TannanJungle-Back", true);
	self.LocMid:SetAtlas ("_GarrMissionLocation-TannanJungle-Mid", true);
	self.LocFore:SetAtlas("_GarrMissionLocation-TannanJungle-Fore", true);
	local _, backWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Back");
	local _, midWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Mid");
	local _, foreWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Fore");
	local texWidth = self.LocBack:GetWidth();
	self.LocBack:SetTexCoord(0, texWidth/backWidth, 0, 1);
	self.LocMid:SetTexCoord (0, texWidth/midWidth, 0, 1);
	self.LocFore:SetTexCoord(0, texWidth/foreWidth, 0, 1);
end

--parallax rates in % texCoords per second
local rateBack = 0.1; 
local rateMid = 0.3;
local rateFore = 0.8;

function GarrisonMissionCompleteStage_OnUpdate(self, elapsed)
	local changeBack = rateBack/100 * elapsed;
	local changeMid = rateMid/100 * elapsed;
	local changeFore = rateFore/100 * elapsed;
	
	local backL, _, _, _, backR = self.LocBack:GetTexCoord();
	local midL, _, _, _, midR = self.LocMid:GetTexCoord();
	local foreL, _, _, _, foreR = self.LocFore:GetTexCoord();
	
	backL = backL + changeBack;
	backR = backR + changeBack;
	midL = midL + changeMid;
	midR = midR + changeMid;
	foreL = foreL + changeFore;
	foreR = foreR + changeFore;
	
	if (backL >= 1) then
		backL = backL - 1;
		backR = backR - 1;
	end
	if (midL >= 1) then
		midL = midL - 1;
		midR = midR - 1;
	end
	if (foreL >= 1) then
		foreL = foreL - 1;
		foreR = foreR - 1;
	end
	
	self.LocBack:SetTexCoord(backL, backR, 0, 1);
	self.LocMid:SetTexCoord (midL, midR, 0, 1);
	self.LocFore:SetTexCoord(foreL, foreR, 0, 1);
end

---------------------------------------------------------------------------------
--- Debugging/Prototyping stuff                                               ---
---------------------------------------------------------------------------------

function Test(id)
	self:SetDisplayInfo(id);
	self:SetTargetDistance(0);
	self:InitializeCamera(.29);
	self:SetHeightFactor(1.3);
	self:SetFacing(-.2);
end

function ShowMissionComplete()
	ShowUIPanel(GarrisonMissionFrame);
	GarrisonMissionFrame_ShowCompleteMissions();
end

function SetupEnding(M, L, R, FL, FR)
	local frame = GarrisonMissionFrame.MissionComplete.Stage.FewFollowers;
	GarrModel1:SetDisplayInfo(L or 41901);
	SetPortraitTexture(frame.Follower1.PortraitFrame.Portrait, L or 41901)
	GarrModel2:SetDisplayInfo(R or 51767);
	SetPortraitTexture(frame.Follower3.PortraitFrame.Portrait, R or 51767)
	GarrModel3:SetDisplayInfo(FL or 54022);
	GarrModel4:SetDisplayInfo(FR or 52882);
	GarrModel5:SetDisplayInfo(M or 54077);
	SetPortraitTexture(frame.Follower2.PortraitFrame.Portrait, M or 54077)
end

function Ending1(facing)
	SetupEnding();
	GarrModel1:Hide();
	GarrModel2:Hide();
	GarrModel3:Hide();
	GarrModel4:Hide();
	GarrModel5:Show();
	GarrModel5:SetAlpha(1);
	GarrModel5:SetTargetDistance(0);
	GarrModel5:SetFacing(facing or .1);
end

function Ending2(facingL, facingR)
	SetupEnding();
	GarrModel1:Show();
	GarrModel1:SetAlpha(1);
	GarrModel1:SetTargetDistance(.2);
	GarrModel1:SetFacing(facingL or -.2);
	GarrModel2:Show();
	GarrModel2:SetAlpha(1);
	GarrModel2:SetTargetDistance(.2);
	GarrModel2:SetFacing(facingR or .2);
	GarrModel3:Hide();
	GarrModel4:Hide();
	GarrModel5:Hide();
end

function Ending3(facingM, facingL, facingR)
	SetupEnding();
	GarrModel1:Show();
	GarrModel1:SetAlpha(1);
	GarrModel1:SetTargetDistance(.2);
	GarrModel1:SetFacing(facingL or -.3);
	GarrModel2:Show();
	GarrModel2:SetAlpha(1);
	GarrModel2:SetTargetDistance(.2);
	GarrModel2:SetFacing(facingR or .3);
	GarrModel3:Hide();
	GarrModel4:Hide();
	GarrModel5:Show();
	GarrModel5:SetAlpha(1);
	GarrModel5:SetTargetDistance(0);
	GarrModel5:SetFacing(facingM or .1);
end

function Ending4(facingL, facingR, facingFL, facingFR)
	SetupEnding();
	GarrModel1:Show();
	GarrModel1:SetAlpha(1);
	GarrModel1:SetTargetDistance(.1);
	GarrModel1:SetFacing(facingL or -.2);
	GarrModel2:Show();
	GarrModel2:SetAlpha(1);
	GarrModel2:SetTargetDistance(.1);
	GarrModel2:SetFacing(facingR or .2);
	GarrModel3:Show();
	GarrModel3:SetAlpha(1);
	GarrModel3:SetTargetDistance(.28);
	GarrModel3:SetFacing(facingFL or -.3);
	GarrModel4:Show();
	GarrModel4:SetAlpha(1);
	GarrModel4:SetTargetDistance(.28);
	GarrModel4:SetFacing(facingFR or .3);
	GarrModel5:Hide();
end

function Ending5(facingM, facingL, facingR, facingFL, facingFR)
	SetupEnding();
	GarrModel1:Show();
	GarrModel1:SetAlpha(1);
	GarrModel1:SetTargetDistance(.15);
	GarrModel1:SetFacing(facingL or -.4);
	GarrModel2:Show();
	GarrModel2:SetAlpha(1);
	GarrModel2:SetTargetDistance(.15);
	GarrModel2:SetFacing(facingR or .4);
	GarrModel3:Show();
	GarrModel3:SetAlpha(1);
	GarrModel3:SetTargetDistance(.3);
	GarrModel3:SetFacing(facingFL or -.45);
	GarrModel4:Show();
	GarrModel4:SetAlpha(1);
	GarrModel4:SetTargetDistance(.3);
	GarrModel4:SetFacing(facingFR or .45);
	GarrModel5:Show();
	GarrModel5:SetAlpha(1);
	GarrModel5:SetTargetDistance(0);
	GarrModel5:SetFacing(facingM or .1);
end

function SetRates(back, mid, fore)
	rateBack = back;
	rateMid = mid;
    rateFore = fore;
end

function Setup1(scale1, scale2)
	GarrModel1:SetDisplayInfo(52882);
	GarrModel2:SetDisplayInfo(51767);
	GarrModel1:InitializePanCamera(scale1 or 1);
	GarrModel2:InitializePanCamera(scale2 or 0.8);
	GarrModel3:Hide();
	GarrModel4:Hide();
	GarrModel5:Hide();
end

function Setup2(scale1, scale2)
	GarrModel1:SetDisplayInfo(53051);
	GarrModel2:SetDisplayInfo(53970);
	GarrModel1:InitializePanCamera(scale1 or .8)
	GarrModel2:InitializePanCamera(scale2 or 1.1);
	GarrModel3:Hide();
	GarrModel4:Hide();
	GarrModel5:Hide();
end

function Setup(displayID1, displayID2, weaponID1, weaponID2, scale1, scale2)
	GarrModel1:SetDisplayInfo(displayID1);
	GarrModel2:SetDisplayInfo(displayID2);
	if (weaponID1) then
		GarrModel1:SetCreatureData(weaponID1);
	end
	if (weaponID2) then
		GarrModel2:SetCreatureData(weaponID2);
	end
	GarrModel1:InitializePanCamera(scale1 or 1)
	GarrModel2:InitializePanCamera(scale2 or 1);
end

function Demo1(length, panType1, panType2, fadeIn, fadeOut, impactOffset, hitOffset)
	GarrModel1:SetCreatureData(81577);
	GarrModel1:SetAnimOffset(hitOffset or 0);
	GarrModel2:SetAnimOffset(impactOffset or 0.35);
	GarrModel1:SetFadeTimes(fadeIn or .1, fadeOut or .2);
	GarrModel2:SetFadeTimes(fadeIn or .1, fadeOut or .2);
	GarrModel1:StartPan(panType1 or LE_PAN_AND_JUMP, length or 1, true, 41100); 
	GarrModel2:StartPan(panType2 or LE_PAN_NONE, length or 1, true, 41101);
end

function Demo2(length, panType1, panType2, fadeIn, fadeOut, impactOffset, hitOffset)
	GarrModel1:SetAnimOffset(hitOffset or 0);
	GarrModel2:SetAnimOffset(impactOffset or 0.35);
	GarrModel1:SetFadeTimes(fadeIn or .1, fadeOut or .2);
	GarrModel2:SetFadeTimes(fadeIn or .1, fadeOut or .2);
	GarrModel1:StartPan(panType1 or LE_PAN_NONE, length or 1, true, 41097);
	GarrModel2:StartPan(panType2 or LE_PAN_NONE, length or 1, true, 41098);
end

function Demo(castKitID, impactKitID, length, panType1, panType2, fadeIn, fadeOut, impactOffset, hitOffset)
	GarrModel1:SetAnimOffset(hitOffset or 0);
	GarrModel2:SetAnimOffset(impactOffset or 0.35);
	GarrModel1:SetFadeTimes(fadeIn or .1, fadeOut or .2);
	GarrModel2:SetFadeTimes(fadeIn or .1, fadeOut or .2);
	GarrModel1:StartPan(panType1 or LE_PAN_STEADY, length or 1, true, castKitID);
	GarrModel2:StartPan(panType2 or LE_PAN_STEADY, length or 1, true, impactKitID);
end