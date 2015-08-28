
---------------------------------------------------------------------------------
--- Base Mission Mixin Functions                                              ---
---------------------------------------------------------------------------------
GarrisonMission = {};

function GarrisonMission:OnLoadMainFrame()
	PanelTemplates_SetNumTabs(self, 2);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);

	self.followerXPTable = C_Garrison.GetFollowerXPTable(self:GetFollowerType());
	local maxLevel = 0;
	for level in pairs(self.followerXPTable) do
		maxLevel = max(maxLevel, level);
	end
	self.followerMaxLevel = maxLevel;

	self.followerQualityTable = C_Garrison.GetFollowerQualityTable(self:GetFollowerType());
	local maxQuality = 0;
	for quality, xp in pairs(self.followerQualityTable) do
		maxQuality = max(maxQuality, quality);
	end
	self.followerMaxQuality = maxQuality;
end

function GarrisonMission:SelectTab(id)
	PanelTemplates_SetTab(self, id);
	if (id == 1) then
		if ( self.MissionComplete.currentIndex ) then
			self.MissionComplete:Show();
			self.MissionCompleteBackground:Show();
			self.FollowerList:Hide();
		end
		self.MissionTab:Show();
		self.FollowerTab:Hide();
		if ( self.MissionTab.MissionPage:IsShown() ) then
			GarrisonFollowerList_UpdateFollowers(self.FollowerList);
		end
	else
		self.MissionComplete:Hide();
		self.MissionCompleteBackground:Hide();
		self.MissionTab:Hide();
		self.FollowerTab:Show();
		if ( self.FollowerList:IsShown() ) then
			GarrisonFollowerList_UpdateFollowers(self.FollowerList);
		else
			self.FollowerList:Show();
		end
	end
end

function GarrisonMission:OnClickMission(missionInfo)
	if ( IsModifiedClick("CHATLINK") ) then
		local missionLink = C_Garrison.GetMissionLink(missionInfo.missionID);
		if (missionLink) then
			ChatEdit_InsertLink(missionLink);
		end
		return false;
	end

	-- don't do anything other than create links and handle spell clicks for in progress missions
	if (missionInfo.inProgress) then
		C_Garrison.CastSpellOnMission(missionInfo.missionID);
		return false;
	end
	
	PlaySound("UI_Garrison_CommandTable_SelectMission");
	return true;
end

function GarrisonMission:HasMission()
	return self.MissionTab.MissionPage:IsShown() and self.MissionTab.MissionPage.missionInfo ~= nil;
end

function GarrisonMission:ShowMission(missionInfo)
	local frame = self.MissionTab.MissionPage;
	frame.missionInfo = missionInfo;
	
	local location, xp, environment, environmentDesc, environmentTexture, locPrefix, isExhausting, enemies = C_Garrison.GetMissionInfo(missionInfo.missionID);
	frame.Stage.Title:SetText(missionInfo.name);
	GarrisonTruncationFrame_Check(frame.Stage.Title);
	frame.environment = environment;
	frame.xp = xp;
	frame.Stage.MissionEnvIcon.Texture:SetTexture(environmentTexture);
	if ( locPrefix ) then
		frame.Stage.LocBack:SetAtlas("_"..locPrefix.."-Back", true);
		frame.Stage.LocMid:SetAtlas ("_"..locPrefix.."-Mid", true);
		frame.Stage.LocFore:SetAtlas("_"..locPrefix.."-Fore", true);
	end
	frame.MissionType:SetAtlas(missionInfo.typeAtlas);

	if ( frame.missionInfo.isRare ) then
		frame.IconBG:SetVertexColor(0, 0.012, 0.291, 0.4);
	else
		frame.IconBG:SetVertexColor(0, 0, 0, 0.4);
	end

	-- max level
	if ( frame.missionInfo.level == self.followerMaxLevel and frame.missionInfo.iLevel > 0 ) then
		frame.showItemLevel = true;
		frame.Stage.Level:SetPoint("CENTER", frame.Stage.Header, "TOPLEFT", 30, -28);
		frame.Stage.ItemLevel:Show();
		frame.Stage.ItemLevel:SetFormattedText(NUMBER_IN_PARENTHESES, frame.missionInfo.iLevel);
		frame.ItemLevelHitboxFrame:Show();
	else
		frame.showItemLevel = false;
		frame.Stage.Level:SetPoint("CENTER", frame.Stage.Header, "TOPLEFT", 30, -36);
		frame.Stage.ItemLevel:Hide();
		frame.ItemLevelHitboxFrame:Hide();
	end

	if ( isExhausting ) then
		frame.Stage.ExhaustingLabel:Show();
		frame.Stage.MissionTime:SetPoint("TOPLEFT", frame.Stage.ExhaustingLabel, "BOTTOMLEFT", 0, -3);
	else
		frame.Stage.ExhaustingLabel:Hide();
		frame.Stage.MissionTime:SetPoint("TOPLEFT", frame.Stage.Header, "BOTTOMLEFT", 7, -7);
	end
	
	frame.CostFrame:SetPoint("LEFT", frame.ButtonFrame, "LEFT", 50, 0);
	frame.CostFrame:SetPoint("RIGHT", frame.ButtonFrame, "CENTER");
	
	if (missionInfo.cost > 0) then
		frame.CostFrame:Show();
		frame.StartMissionButton:ClearAllPoints();
		frame.StartMissionButton:SetPoint("RIGHT", frame.ButtonFrame, "RIGHT", -50, 1);
	else
		frame.CostFrame:Hide();
		frame.StartMissionButton:ClearAllPoints();
		frame.StartMissionButton:SetPoint("CENTER", frame.ButtonFrame, "CENTER", 0, 1);
	end

	self:SetPartySize(frame, missionInfo.numFollowers, #enemies);
	self:SetEnemies(frame, enemies, missionInfo.numFollowers);
	
	local numRewards = missionInfo.numRewards;
	local numVisibleRewards = 0;
	for id, reward in pairs(missionInfo.rewards) do
		numVisibleRewards = numVisibleRewards + 1;
		local rewardFrame = frame.RewardsFrame.Rewards[numVisibleRewards];
		if ( rewardFrame ) then
			GarrisonMissionPage_SetReward(rewardFrame, reward);
		else
			-- too many rewards
			numVisibleRewards = numVisibleRewards - 1;
			break;
		end
	end
	for i = (numVisibleRewards + 1), #frame.RewardsFrame.Rewards do
		frame.RewardsFrame.Rewards[i]:Hide();
	end
	frame.RewardsFrame.Reward1:ClearAllPoints();
	if ( numRewards == 1 ) then
		frame.RewardsFrame.Reward1:SetPoint("LEFT", frame.RewardsFrame, 207, 0);
	elseif ( numRewards == 2 ) then
		frame.RewardsFrame.Reward1:SetPoint("LEFT", frame.RewardsFrame, 128, 0);
	end
	
	-- set up all the values
	frame.RewardsFrame.currentChance = nil;	-- so we don't animate setting the initial chance %
	if ( frame.RewardsFrame.elapsedTime ) then
		GarrisonMissionPageRewardsFrame_StopUpdate(frame.RewardsFrame);
	end
	
	self:UpdateMissionData(frame);
	
	self.followerCounters = C_Garrison.GetBuffedFollowersForMission(missionInfo.missionID)
	self.followerTraits = C_Garrison.GetFollowersTraitsForMission(missionInfo.missionID);
	
	GarrisonMissionPage_SetCounters(frame.Followers, frame.Enemies, frame.missionInfo.missionID);
end

function GarrisonMission:SetPartySize(frame, size, numEnemies)
	for i = 1, #frame.Followers do
		if ( i <= size ) then
			frame.Followers[i]:Show();
		else
			frame.Followers[i]:Hide();
		end
	end
end

function GarrisonMission:SortEnemies(enemies)
	-- Do not sort by default
end
	
function GarrisonMission:SortMechanics(mechanics)
	-- Do not sort by default
	local keys = {}
	for key in pairs(mechanics) do
		table.insert(keys, key)
	end

	return keys;
end

function GarrisonMission:SetEnemies(frame, enemies, numFollowers, mechanicYOffset, followerTypeID)
	local numVisibleEnemies = 0;
	for i=1, #enemies do
		local Frame = frame.Enemies[i];
		if ( not Frame ) then
			break;
		end
		numVisibleEnemies = numVisibleEnemies + 1;
		local enemy = enemies[i];
		Frame.Name:SetText(enemy.name);
		local numMechs = 0;
		local sortedKeys = self:SortMechanics(enemy.mechanics);
		for _, id in ipairs(sortedKeys) do
			local mechanic = enemy.mechanics[id];
			numMechs = numMechs + 1;	
			if (not Frame.Mechanics[numMechs]) then
				Frame.Mechanics[numMechs] = CreateFrame("Button", nil, Frame, "GarrisonMissionEnemyLargeMechanicTemplate");
				Frame.Mechanics[numMechs]:SetPoint("LEFT", Frame.Mechanics[numMechs-1], "RIGHT", 16, 0);
			end
			local Mechanic = Frame.Mechanics[numMechs];
			Mechanic.mainFrame = frame:GetParent():GetParent();
			Mechanic.info = mechanic;
			Mechanic.Icon:SetTexture(mechanic.icon);
			Mechanic.mechanicID = id;
			Mechanic.followerTypeID = followerTypeID;
			Mechanic:Show();
		end
		Frame.Mechanics[1]:SetPoint("BOTTOM", (numMechs - 1) * -22, mechanicYOffset);
		for j=(numMechs + 1), #Frame.Mechanics do
			Frame.Mechanics[j]:Hide();
			Frame.Mechanics[j].mechanicID = nil;
			Frame.Mechanics[j].info = nil;
		end
		local portrait = Frame;
		if (Frame.PortraitFrame) then
			portrait = Frame.PortraitFrame;
		end
		self:SetEnemyPortrait(portrait, enemy, portrait.Elite, numMechs);
		Frame:Show();
	end
	
	for i = numVisibleEnemies + 1, #frame.Enemies do
		frame.Enemies[i]:Hide();
	end
	
	return numVisibleEnemies;
end

function GarrisonMission:UpdateMissionData(frame)
	local lastUpdate = frame.lastUpdate;
	local totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, isEnvMechanicCountered, xpBonus, currencyMultipliers, goldMultiplier = C_Garrison.GetPartyMissionInfo(frame.missionInfo.missionID);

	-- TIME
	if ( isMissionTimeImproved ) then
		totalTimeString = GREEN_FONT_COLOR_CODE..totalTimeString..FONT_COLOR_CODE_CLOSE;
	elseif ( totalTimeSeconds >= GARRISON_LONG_MISSION_TIME ) then
		totalTimeString = format(GARRISON_LONG_MISSION_TIME_FORMAT, totalTimeString);
	end
	frame.Stage.MissionTime:SetFormattedText(GARRISON_MISSION_TIME_TOTAL, totalTimeString);

	-- SUCCESS CHANCE
	local rewardsFrame = frame.RewardsFrame;
	-- if animating, stop it
	if ( rewardsFrame.elapsedTime ) then
		rewardsFrame.Chance:SetFormattedText(PERCENTAGE_STRING, rewardsFrame.endingChance);
		rewardsFrame.currentChance = rewardsFrame.endingChance;
		GarrisonMissionPageRewardsFrame_StopUpdate(rewardsFrame);
	end	
	if ( rewardsFrame.currentChance and successChance > rewardsFrame.currentChance ) then
		rewardsFrame.elapsedTime = 0;
		rewardsFrame.startingChance = rewardsFrame.currentChance;
		rewardsFrame.endingChance = successChance;
		rewardsFrame:SetScript("OnUpdate", GarrisonMissionPageRewardsFrame_OnUpdate);
		rewardsFrame.ChanceGlowAnim:Play();
		if ( successChance < 100 ) then
			PlaySound("UI_Garrison_CommandTable_IncreasedSuccessChance");
		else
			PlaySound("UI_Garrison_CommandTable_100Success");
		end
	else
		-- no need to animate if chance is not increasing
		if ( rewardsFrame.currentChance and successChance < rewardsFrame.currentChance ) then
			PlaySound("UI_Garrison_CommandTable_ReducedSuccessChance");
		end
		rewardsFrame.Chance:SetFormattedText(PERCENTAGE_STRING, successChance);
		rewardsFrame.currentChance = successChance;
	end

	local followersWithAbilitiesGained = nil;

	-- PARTY BOOFS
	local buffsFrame = frame.BuffsFrame;
	local buffCount = #partyBuffs;
	if ( buffCount == 0 ) then
		buffsFrame:Hide();
	else
		local buffIndex = 0;
		for i = 1, buffCount, 2 do
			buffIndex = buffIndex + 1;
			local buff = buffsFrame.Buffs[buffIndex];
			if ( not buff ) then
				buff = CreateFrame("Frame", nil, buffsFrame, "GarrisonMissionPartyBuffTemplate");
				buff:SetPoint("LEFT", buffsFrame.Buffs[buffIndex - 1], "RIGHT", 8, 0);
			end
			local followerID = partyBuffs[i];
			local buffID = partyBuffs[i + 1];
			buff.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(buffID));
			buff.id = buffID;
			buff:Show();

			if ( lastUpdate and GarrisonFollowerAbilities_IsNew(lastUpdate, followerID, buffID, GARRISON_FOLLOWER_ABILITY_TYPE_TRAIT) ) then
				buff.AbilityFeedbackGlowAnim:Play();
				if ( not followersWithAbilitiesGained ) then
					followersWithAbilitiesGained = {};
				end
				followersWithAbilitiesGained[followerID] = true;
			else
				buff.AbilityFeedbackGlowAnim:Stop();
			end
		end
		for i = buffIndex + 1, #buffsFrame.Buffs do
			buffsFrame.Buffs[i]:Hide();
		end
		local width = buffIndex * 28 + buffsFrame.BuffsTitle:GetWidth() + 40;
		buffsFrame:SetWidth(max(width, 160));
		buffsFrame:Show();
	end

	if ( followersWithAbilitiesGained ) then
		for followerID in pairs(followersWithAbilitiesGained) do
			local followerFrame = GarrisonMissionPage_GetFollowerFrameFromID(followerID);
			if ( followerFrame ) then
				followerFrame.PortraitFrame.PortraitFeedbackGlowAnim:Play();
			end
		end
	end

	-- ENVIRONMENT
	if ( frame.environment ) then
		local env = frame.environment;
		local envCheckFrame = frame.Stage.MissionEnvIcon;
		if ( isEnvMechanicCountered ) then
			env = GREEN_FONT_COLOR_CODE..env..FONT_COLOR_CODE_CLOSE;
			if ( not envCheckFrame.Check:IsShown() ) then
				envCheckFrame.Check:Show();
				envCheckFrame.Anim:Stop();
				envCheckFrame.Anim:Play();
				PlaySound("UI_Garrison_Mission_Threat_Countered");
			end
		else
			envCheckFrame.Check:Hide();
		end
		frame.Stage.MissionEnv:SetFormattedText(GARRISON_MISSION_ENVIRONMENT, env);
	end	

	-- XP
	if ( xpBonus > 0 ) then
		rewardsFrame.MissionXP:SetFormattedText(GARRISON_MISSION_BASE_XP_PLUS, frame.xp + xpBonus, xpBonus);
		rewardsFrame.MissionXP.hasBonusBaseXP = true;
	else
		rewardsFrame.MissionXP:SetFormattedText(GARRISON_MISSION_BASE_XP, frame.xp);
		rewardsFrame.MissionXP.hasBonusBaseXP = false;
	end
	
	GarrisonMissionPage_UpdateRewardQuantities(frame.RewardsFrame, currencyMultipliers, goldMultiplier);
	self:UpdateStartButton(frame);

	frame.lastUpdate = GetTime();
end

function GarrisonMission:UpdateStartButton(missionPage, partyNotFullText)
	local missionInfo = missionPage.missionInfo;
	if ( not missionPage.missionInfo or not missionPage:IsVisible() ) then
		return;
	end

	local disableError;
	
	if ( not C_Garrison.AllowMissionStartAboveSoftCap(self:GetFollowerType()) and C_Garrison.IsAboveFollowerSoftCap(self:GetFollowerType()) ) then
		disableError = GARRISON_MAX_FOLLOWERS_MISSION_TOOLTIP;
	end
	
	local currencyName, amount, currencyTexture = GetCurrencyInfo(missionInfo.costCurrencyTypesID);
	if ( not disableError and amount < missionInfo.cost ) then
		missionPage.CostFrame.Cost:SetText(RED_FONT_COLOR_CODE..BreakUpLargeNumbers(missionInfo.cost)..FONT_COLOR_CODE_CLOSE);
		disableError = GARRISON_NOT_ENOUGH_MATERIALS_TOOLTIP;
	else
		missionPage.CostFrame.Cost:SetText(BreakUpLargeNumbers(missionInfo.cost));
	end

	if ( not disableError and C_Garrison.GetNumFollowersOnMission(missionPage.missionInfo.missionID) < missionPage.missionInfo.numFollowers ) then
		disableError = partyNotFullText or GARRISON_PARTY_NOT_FULL_TOOLTIP;
	end

	local startButton = missionPage.StartMissionButton;
	if ( disableError ) then
		startButton:SetEnabled(false);
		startButton.Flash:Hide();
		startButton.FlashAnim:Stop();	
		startButton.tooltip = disableError;
	else
		startButton:SetEnabled(true);
		startButton.Flash:Show();
		startButton.FlashAnim:Play();
		startButton.tooltip = nil;
	end
end

function GarrisonMission:CloseMission()
	self.MissionTab.MissionPage:Hide();
	self.MissionTab.MissionList:Show();
	self:ClearParty();
	self.followerCounters = nil;
	self.MissionTab.MissionPage.missionInfo = nil;	
end

function GarrisonMission:ClearParty()
	local frame = self.MissionTab.MissionPage;
	for i = 1, #frame.Followers do
		local followerFrame = frame.Followers[i];
		self:RemoveFollowerFromMission(followerFrame);
	end
end

function GarrisonMission:OnClickStartMissionButton()
	local missionID = self.MissionTab.MissionPage.missionInfo.missionID;
	if (not missionID) then
		return false;
	end
	C_Garrison.StartMission(missionID);
	self:UpdateMissions();
	GarrisonFollowerList_UpdateFollowers(self.FollowerList);
	self:CloseMission();
	return true;
end

function GarrisonMission:AssignFollowerToMission(frame, info)
	if (frame.info) then
		self:RemoveFollowerFromMission(frame);
	end

	local missionFrame = self.MissionTab.MissionPage;
	
	-- frame.info needs to be set for AddFollowerToMission()
	frame.info = info;	
	if ( not C_Garrison.AddFollowerToMission(missionFrame.missionInfo.missionID, info.followerID) ) then
		frame.info = nil;
		return false;
	end
	
	GarrisonMissionPage_SetCounters(missionFrame.Followers, missionFrame.Enemies, missionFrame.missionInfo.missionID);
	return true;
end

function GarrisonMission:RemoveFollowerFromMission(frame, updateValues)
	local followerID = frame.info and frame.info.followerID or nil;
	
	frame.info = nil;
	for i = 1, #frame.Counters do
		frame.Counters[i]:Hide();
	end
	
	local missionFrame = self.MissionTab.MissionPage;
	if (followerID) then
		C_Garrison.RemoveFollowerFromMission(missionFrame.missionInfo.missionID, followerID);
		if (updateValues) then
			PlaySound("UI_Garrison_CommandTable_UnassignFollower");
		end
	end
	
	GarrisonMissionPage_SetCounters(missionFrame.Followers, missionFrame.Enemies, missionFrame.missionInfo.missionID);
end

function GarrisonMission:UpdateMissionParty(followers, counterTemplate)
	-- Update follower level and portrait color in case they have changed
	for followerIndex = 1, #followers do
		local followerFrame = followers[followerIndex];
		if ( followerFrame.info ) then
			local followerInfo = C_Garrison.GetFollowerInfo(followerFrame.info.followerID);
			if ( followerInfo and followerInfo.status == GARRISON_FOLLOWER_IN_PARTY ) then
				self:SetFollowerPortrait(followerFrame, followerInfo, true);
			else
				self:RemoveFollowerFromMission(followerFrame, true);
			end
			
			local numCounters = 0;
			local counters = self.followerCounters and followerFrame.info and self.followerCounters[followerFrame.info.followerID] or nil;
			if (counters) then
				for i = 1, #counters do
					numCounters = numCounters + 1;
					if (not followerFrame.Counters[i]) then
						followerFrame.Counters[i] = CreateFrame("Frame", nil, followerFrame, counterTemplate);
						followerFrame.Counters[i]:SetPoint("LEFT", followerFrame.Counters[i-1], "RIGHT", 16, 0);
					end
					local Counter = followerFrame.Counters[i];
					Counter.info = counters[i];
					Counter.info.showCounters = true;
					Counter.Icon:SetTexture(counters[i].icon);
					Counter.tooltip = counters[i].name;
					Counter:Show();
					
					Counter.followerTypeID = followerInfo.followerTypeID;
				end
			end
			for i = numCounters + 1, #followerFrame.Counters do
				followerFrame.Counters[i]:Hide();
			end
		end
	end
end

function GarrisonMission:OnClickFollowerPlacerFrame(button, info)
	if ( button == "LeftButton" ) then
		for i = 1, #self.MissionTab.MissionPage.Followers do
			local followerFrame = self.MissionTab.MissionPage.Followers[i];
			if ( followerFrame:IsShown() and followerFrame:IsMouseOver() ) then
				self:AssignFollowerToMission(followerFrame, info);
			end
		end
	end
	self:ClearMouse();
end

function GarrisonMission:OnDragStartFollowerButton(placer, frame, yOffset)
	if ( not self.MissionTab.MissionPage:IsVisible() ) then
		return;
	end
	if ( frame.info.status or not frame.info.isCollected ) then
		return;
	end
	self:SetFollowerPortrait(placer, frame.info, false, false);
	placer.info = frame.info;
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	placer.yOffset = yOffset;
	placer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + placer.yOffset);
	placer:Show();
	placer:SetScript("OnUpdate", GarrisonFollowerPlacer_OnUpdate);
end

function GarrisonMission:OnDragStopFollowerButton(placer)
	if (placer:IsShown()) then
		GarrisonShowFollowerPlacerFrame(self, placer.info);
	end
end

function GarrisonMission:OnDragStartMissionFollower(placer, frame, yOffset)
	if ( not frame.info ) then
		return;
	end
	self:SetFollowerPortrait(placer, frame.info, false, false);
	placer.info = frame.info;
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	placer.yOffset = yOffset;
	placer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + placer.yOffset);
	placer:Show();
	placer:SetScript("OnUpdate", GarrisonFollowerPlacer_OnUpdate);
	self:RemoveFollowerFromMission(frame);
end

function GarrisonMission:OnDragStopMissionFollower(placer)
	if ( not placer.info ) then
		return;
	end
	GarrisonShowFollowerPlacerFrame(self, placer.info);
end

function GarrisonMission:OnReceiveDragMissionFollower(placer, frame)	
	if ( placer:IsVisible() and placer.info ) then
		self:AssignFollowerToMission(frame, placer.info);
		self:ClearMouse();
	end
end

function GarrisonMission:OnMouseUpMissionFollower(frame, button)
	if ( button == "RightButton" ) then
		if ( frame.info ) then
			self:RemoveFollowerFromMission(frame, true);
		else
			self.MissionTab.MissionPage.CloseButton:Click();
		end
	end
end

function GarrisonFollowerPlacer_OnUpdate(self)
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	self:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + self.yOffset);
end

function GarrisonMission:CheckCompleteMissions(onShow)
	if ( self.MissionComplete:IsShown() ) then
		return false;
	end
	
	self.MissionComplete.completeMissions = C_Garrison.GetCompleteMissions(self:GetFollowerType());
	if ( #self.MissionComplete.completeMissions > 0 ) then
		if ( self:IsShown() ) then
			self.MissionTab.MissionList.CompleteDialog.BorderFrame.Model.Summary:SetFormattedText(GARRISON_NUM_COMPLETED_MISSIONS, #self.MissionComplete.completeMissions);
			self.MissionTab.MissionList.CompleteDialog:Show();
			self.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton:SetEnabled(true);
			self.MissionTab.MissionList.CompleteDialog.BorderFrame.LoadingFrame:Hide();
			return true;
		end
	end
	
	return false;
end

function GarrisonMission:OnClickViewCompletedMissionsButton()
	PlaySound("UI_Garrison_CommandTable_ViewMissionReport");
	if ( not MissionCompletePreload_IsReady() ) then
		self.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton:SetEnabled(false);
		self.MissionTab.MissionList.CompleteDialog.BorderFrame.LoadingFrame:Show();
		MissionCompletePreload_StartTimeout(GARRISON_MODEL_PRELOAD_TIME, self.OnClickViewCompletedMissionsButton, self);
		return;
	end

	self.MissionTab.MissionList.CompleteDialog:Hide();
	self.FollowerTab:Hide();
	self.FollowerList:Hide();
	HelpPlate_Hide();
	self.MissionComplete:Show();
	self.MissionCompleteBackground:Show();

	self.MissionComplete.currentIndex = 1;
	
	self:MissionCompleteInitialize(self.MissionComplete.completeMissions, self.MissionComplete.currentIndex);
end

function GarrisonMission:NextMission()
	if ( not MissionCompletePreload_IsReady() ) then
		self.MissionComplete.NextMissionButton:SetEnabled(false);
		self.MissionComplete.LoadingFrame:Show();
		MissionCompletePreload_StartTimeout(GARRISON_MODEL_PRELOAD_TIME, self.NextMission, self);
		return;
	end
	self.MissionComplete.currentIndex = self.MissionComplete.currentIndex + 1;
	self:MissionCompleteInitialize(self.MissionComplete.completeMissions, self.MissionComplete.currentIndex);
end

function GarrisonMission:MissionCompleteInitialize(missionList, index)
	local frame = self.MissionComplete;
	frame.NextMissionButton:Enable();
	if (not missionList or #missionList == 0 or index == 0) then
		self:CloseMissionComplete();
		return false;
	end
	if (index > #missionList) then
		frame.completeMissions = nil;
		self:CloseMissionComplete();
		return false;
	end
	local mission = missionList[index];
	frame.currentMission = mission;

	local stage = frame.Stage;
	stage.FollowersFrame:Hide();
	stage.EncountersFrame.FadeOut:Stop();
	stage.EncountersFrame:Show();

	for i = 1, #stage.Models do
		stage.Models[i].FadeIn:Stop();
		stage.Models[i]:StopPan();
	end

	stage.MissionInfo.Title:SetText(mission.name);
	GarrisonTruncationFrame_Check(stage.MissionInfo.Title);

	frame.LoadingFrame:Hide();
	
	frame:StopAnims();
	frame.rollCompleted = false;

	-- rare
	if ( mission.isRare ) then
		stage.MissionInfo.IconBG:SetVertexColor(0, 0.012, 0.291, 0.4);
	else
		stage.MissionInfo.IconBG:SetVertexColor(0, 0, 0, 0.4);
	end
	local location, xp, environment, environmentDesc, environmentTexture, locPrefix, isExhausting, enemies = C_Garrison.GetMissionInfo(mission.missionID);
	self:SortEnemies(enemies);
	if ( locPrefix ) then
		stage.LocBack:SetAtlas("_"..locPrefix.."-Back", true);
		stage.LocMid:SetAtlas ("_"..locPrefix.."-Mid", true);
		stage.LocFore:SetAtlas("_"..locPrefix.."-Fore", true);
	end
	
	stage.MissionInfo.MissionType:SetAtlas(mission.typeAtlas, true);
	stage.EncountersFrame.enemies = enemies;
	stage.EncountersFrame.uncounteredMechanics = C_Garrison.GetMissionUncounteredMechanics(mission.missionID);

	local encounters = C_Garrison.GetMissionCompleteEncounters(mission.missionID);
	self:SortEnemies(encounters);
	self:SetMissionCompleteNumEncounters(stage.EncountersFrame, #encounters);
	for i=1, #encounters do
		local encounter = stage.EncountersFrame.Encounters[i];
		self:SetEnemyName(encounter, encounters[i].name);
		encounter.displayID = encounters[i].displayID;
		self:SetEnemyPortrait(encounter, encounters[i], encounter.Elite, #enemies[i].mechanics);
	end

	frame.animInfo = {};
	stage.followers = {};
	for i=1, #mission.followers do
		local follower = stage.FollowersFrame.Followers[i];
		local name, displayID, level, quality, currXP, maxXP, height, scale, movementType, impactDelay, castID, 
			  castSoundID, impactID, impactSoundID, targetImpactID, targetImpactSoundID, className, classAtlas, portraitIconID, texPrefix = 
					C_Garrison.GetFollowerMissionCompleteInfo(mission.followers[i]);
		follower.followerID = mission.followers[i];
		frame:SetFollowerData(follower, name, className, classAtlas, portraitIconID, texPrefix);
		frame:SetFollowerLevel(follower, level, quality, currXP, maxXP);

		stage.followers[i] = { displayID = displayID, height = height, scale = scale, followerID = mission.followers[i] };
		if (encounters[i]) then --cannot have more animations than encounters
			frame.animInfo[i] = { 	displayID = displayID,
									height = height, 
									scale = scale, 
									movementType = movementType,
									impactDelay = impactDelay,
									castID = castID,
									castSoundID = castSoundID,
									impactID = impactID,
									impactSoundID = impactSoundID,
									targetImpactID = targetImpactID,
									targetImpactSoundID = targetImpactSoundID,
									enemyDisplayID = encounters[i].displayID,
									enemyScale = encounters[i].scale,
									enemyHeight = encounters[i].height,
									followerID = mission.followers[i],
								}
		end
	end
	-- if there are fewer followers than encounters, cycle through followers to match up against encounters
	for i = #mission.followers + 1, #encounters do
		local index = mod(i, #mission.followers) + 1;
		local animInfo = frame.animInfo[index];
		frame.animInfo[i] = { 	displayID = animInfo.displayID,
								height = animInfo.height, 
								scale = animInfo.scale, 
								movementType = animInfo.movementType,
								impactDelay = animInfo.impactDelay,
								castID = animInfo.castID,
								castSoundID = animInfo.castSoundID,
								impactID = animInfo.impactID,
								impactSoundID = animInfo.impactSoundID,
								targetImpactID = animInfo.targetImpactID,
								targetImpactSoundID = animInfo.targetImpactSoundID,
								enemyDisplayID = encounters[i].displayID,
								enemyScale = encounters[i].scale,
								enemyHeight = encounters[i].height,
								followerID = animInfo.followerID,
							};
	end

	local currencyMultipliers, goldMultiplier = select(8, C_Garrison.GetPartyMissionInfo(frame.currentMission.missionID));
	frame.currentMission.currencyMultipliers = currencyMultipliers;
	frame.currentMission.goldMultiplier = goldMultiplier;

	frame.BonusRewards.ChestModel.OpenAnim:Stop();
	frame.BonusRewards.ChestModel.LockBurstAnim:Stop();
	frame.BonusRewards.ChestModel:SetAlpha(1);
	for i = 1, #frame.BonusRewards.Rewards do
		frame.BonusRewards.Rewards[i]:Hide();
	end
	frame.BonusRewards.ChestModel.LockBurstAnim:Stop();
	frame.ChanceFrame.SuccessChanceInAnim:Stop();
	frame.ChanceFrame.ResultAnim:Stop();
	frame.BonusRewards.timerMissionID = nil;
	if (mission.state >= 0) then
		-- if the mission is in this state, it's a success
		frame.currentMission.succeeded = true;
		frame:SetScript("OnUpdate", nil);

		stage.EncountersFrame:Hide();
		frame.BonusRewards.Saturated:Show();
		frame.BonusRewards.ChestModel.Lock:Hide();
		frame.BonusRewards.ChestModel:SetAnimation(0, 0);
		frame.BonusRewards.ChestModel.ClickFrame:Show();
		frame.ChanceFrame.ChanceText:SetAlpha(0);
		frame.ChanceFrame.ResultText:SetText(GARRISON_MISSION_SUCCESS);
		frame.ChanceFrame.ResultText:SetTextColor(0.1, 1, 0.1);
		frame.ChanceFrame.ResultText:SetAlpha(1);

		frame.ChanceFrame.Banner:SetAlpha(1);
		frame.ChanceFrame.Banner:SetWidth(GARRISON_MISSION_COMPLETE_BANNER_WIDTH);

		frame:AnimFollowersIn();
	else
		stage.ModelMiddle:Hide();
		stage.ModelRight:Hide();
		stage.ModelLeft:Hide();
		frame.BonusRewards.Saturated:Hide();
		frame.BonusRewards.ChestModel.Lock:SetAlpha(1);
		frame.BonusRewards.ChestModel.Lock:Show();
		frame.BonusRewards.ChestModel:SetAnimation(148);
		frame.BonusRewards.ChestModel.ClickFrame:Hide();		
		frame.ChanceFrame.ChanceText:SetAlpha(1);
		frame.ChanceFrame.ChanceText:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE, C_Garrison.GetRewardChance(mission.missionID));
		frame.ChanceFrame.ResultText:SetAlpha(0);
		frame.ChanceFrame.Banner:SetAlpha(0);
		frame.ChanceFrame.Banner:SetWidth(200);
		frame.ChanceFrame.SuccessChanceInAnim:Play();		
		PlaySound("UI_Garrison_Mission_Complete_Encounter_Chance");
		C_Garrison.MarkMissionComplete(mission.missionID);
		-- TODO this is for testing the success case only. Remove
		--C_Timer.After(0.1, function() GarrisonMissionComplete_OnEvent(self.MissionComplete, "GARRISON_MISSION_COMPLETE_RESPONSE", mission.missionID, true, true); end);
		--GarrisonMissionComplete_OnEvent(self.MissionComplete, "GARRISON_FOLLOWER_XP_CHANGED", 0x439D, 150, 4800, 100, 3);
	end
	frame.NextMissionButton:Disable();
	return true;
end

function GarrisonMission:CloseMissionComplete()
	self:HideCompleteMissions();
end

function GarrisonMission:HideCompleteMissions(onWindowClosing)
	self.MissionComplete:Hide();
	self.MissionCompleteBackground:Hide();
	self.MissionComplete.currentIndex = nil;
	if ( not onWindowClosing ) then
		self.MissionTab:Show();	
		self:UpdateMissions();
	end
end

function GarrisonMission:SetMissionCompleteNumEncounters(frame, numEncounters)
	frame.numEncounters = numEncounters;

	for i = 1, 3 do
		local encounter = frame["Encounter"..i];
		if ( i <= numEncounters ) then
			self:ResetMissionCompleteEncounter(encounter);
		else
			encounter:Hide();
		end
	end
	frame.Encounter1:SetPoint("BOTTOM", -77 * (numEncounters - 1), -40);
end


---------------------------------------------------------------------------------
--- Garrison Mission Complete Mixin Functions                                 ---
---------------------------------------------------------------------------------

GarrisonMissionComplete = {};

function GarrisonMissionComplete:OnMissionCompleteResponse(missionID, canComplete, succeeded, followerDeaths)
	if ( self.currentMission and self.currentMission.missionID == missionID ) then
		self.NextMissionButton:Enable();
		if ( canComplete ) then
			self.currentMission.succeeded = succeeded;
			local animIndex = 0;
			if ( self.Stage.EncountersFrame.numEncounters == 0 ) then
				animIndex = self:FindAnimIndexFor(self.AnimRewards) - 1;
			end
			self:DetermineFailedEncounter(missionID, succeeded, followerDeaths);
			self:BeginAnims(animIndex, missionID);
			self.NextMissionButton:Disable();
		end
	end
end

function GarrisonMissionComplete:BeginAnims(animIndex)
	self.animIndex = animIndex or 0;
	self.animTimeLeft = 0;
	self:SetScript("OnUpdate", self.OnUpdate);
end

function GarrisonMissionComplete:StopAnims()
	self:SetScript("OnUpdate", nil);
	self.animIndex = nil;
	self.skipAnimations = nil;
end

function GarrisonMissionComplete:OnUpdate(elapsed)
	self.animTimeLeft = self.animTimeLeft - elapsed;
	if ( self.animTimeLeft <= 0 ) then
		self.animIndex = self.animIndex + 1;
		local entry = self.animationControl[self.animIndex];
		if ( entry ) then
			entry.onStartFunc(self, entry);
			self.animTimeLeft = entry.duration;
		else
			-- done
			self:SetScript("OnUpdate", nil);
		end
	end
end

function GarrisonMissionComplete:FindAnimIndexFor(func)
	for i = 1, #self.animationControl do
		if ( self.animationControl[i].onStartFunc == func ) then
			return i;
		end
	end
	return 0;
end

local ENDINGS = {
	[1] = { ["ModelMiddle"] = { dist = 0, facing = 0.1, followerIndex = 1 },
			["ModelLeft"] = { hidden = true },	
			["ModelRight"] = { hidden = true },
	},
	[2] = { ["ModelMiddle"] = { hidden = true },
			["ModelLeft"] = { dist = 0.2, facing = -0.2, followerIndex = 1 },	
			["ModelRight"] = { dist = 0.2, facing = 0.2, followerIndex = 2 },
	},
	[3] = { ["ModelMiddle"] = { dist = 0, facing = 0.1, followerIndex = 2 },
			["ModelLeft"] = { dist = 0.25, facing = -0.3, followerIndex = 1 },	
			["ModelRight"] = { dist = 0.275, facing = 0.3, followerIndex = 3 },
	},
	[4] = { ["ModelMiddle"] = { hidden = true },
			["ModelLeft"] = { dist = 0.1, facing = -0.2, followerIndex = 2 },
			["ModelRight"] = { dist = 0.1, facing = 0.2, followerIndex = 3 },
	},
	[5] = { ["ModelMiddle"] = { dist = 0, facing = 0.1, followerIndex = 3 },
			["ModelLeft"] = { dist = 0.15, facing = -0.4, followerIndex = 2 },
			["ModelRight"] = { dist = 0.15, facing = 0.4, followerIndex = 4 },
	},
};

function GarrisonMissionComplete:SetupEnding(numFollowers)
	local ending = ENDINGS[numFollowers];
	local stage = self.Stage;
	for model, data in pairs(ending) do
		local modelFrame = stage[model];
		if ( data.hidden ) then
			modelFrame:Hide();
		else
			modelFrame:Show();
			modelFrame:SetAlpha(1);
			modelFrame:SetTargetDistance(data.dist);
			modelFrame:SetFacing(data.facing);
			local followerInfo = stage.followers[data.followerIndex];
			GarrisonMission_SetFollowerModel(modelFrame, followerInfo.followerID, followerInfo.displayID);
			modelFrame:SetHeightFactor(followerInfo.height);
			modelFrame:InitializeCamera(followerInfo.scale);
		end
	end
end

function GarrisonMissionComplete:ShowRewards()
	local bonusRewards = self.BonusRewards;
	self.NextMissionButton:Enable();
	if ( not bonusRewards.success and not self.skipAnimations ) then
		return;
	end

	local currentMission = self.currentMission;

	local numRewards = currentMission.numRewards;
	local index = 1;
	for id, reward in pairs(currentMission.rewards) do
		if (not bonusRewards.Rewards[index]) then
			bonusRewards.Rewards[index] = CreateFrame("Frame", nil, bonusRewards, "GarrisonMissionRewardEffectsTemplate");
			bonusRewards.Rewards[index]:SetPoint("RIGHT", bonusRewards.Rewards[index-1], "LEFT", -9, 0);
		end
		local Reward = bonusRewards.Rewards[index];
		Reward.id = id;
		Reward.Icon:Show();
		Reward.BG:Show();
		Reward.Name:Show();
		local isAlreadyShown = Reward:IsShown();
		GarrisonMissionPage_SetReward(bonusRewards.Rewards[index], reward);
		if ( not isAlreadyShown ) then
			Reward.Anim:Play();
		end
		index = index + 1;
	end
	for i = (numRewards + 1), #bonusRewards.Rewards do
		bonusRewards.Rewards[i]:Hide();
	end
	GarrisonMissionPage_UpdateRewardQuantities(bonusRewards, currentMission.currencyMultipliers, currentMission.goldMultiplier);

	bonusRewards.Rewards[1]:ClearAllPoints();
	if (numRewards == 1) then
		bonusRewards.Rewards[1]:SetPoint("CENTER", bonusRewards, "CENTER", 0, 0);
	elseif (numRewards == 2) then
		bonusRewards.Rewards[1]:SetPoint("LEFT", bonusRewards, "CENTER", 5, 0);
	else
		bonusRewards.Rewards[1]:SetPoint("RIGHT", bonusRewards, "RIGHT", -18, 0);
	end
end


---------------------------------------------------------------------------------
--- Garrison Mission Complete Animation Mixin Functions                       ---
---------------------------------------------------------------------------------

function GarrisonMissionComplete:SetEncounterModels(index)
	local modelLeft = self.Stage.ModelLeft;
	modelLeft:SetAlpha(0);	
	modelLeft:Show();
	modelLeft:ClearModel();

	local modelRight = self.Stage.ModelRight;	
	modelRight:SetAlpha(0);	
	modelRight:Show();
	modelRight:ClearModel();

	if ( self.animInfo and index and self.animInfo[index] ) then
		local currentAnim = self.animInfo[index];
		modelLeft.state = "loading";
		GarrisonMission_SetFollowerModel(modelLeft, currentAnim.followerID, currentAnim.displayID);		
		if ( currentAnim.enemyDisplayID ) then
			modelRight.state = "loading";
			modelRight:SetDisplayInfo(currentAnim.enemyDisplayID);
		else
			modelRight.state = "empty";
		end
	else
		modelLeft.state = "empty";
		modelRight.state = "empty";
	end
end

function GarrisonMissionComplete:ShowEncounterMechanics(encountersFrame, mechanicsFrame, encounterIndex)
	local numMechs = 0;
	local playCounteredSound = false;
	local sortedKeys = self:GetParent():SortMechanics(encountersFrame.enemies[encounterIndex].mechanics);
	for _, id in ipairs(sortedKeys) do
		local mechanic = encountersFrame.enemies[encounterIndex].mechanics[id];
		numMechs = numMechs + 1;
		if (not mechanicsFrame.Mechanics[numMechs]) then
			mechanicsFrame.Mechanics[numMechs] = CreateFrame("Frame", nil, mechanicsFrame, "GarrisonMissionEnemyMechanicTemplate");
			mechanicsFrame.Mechanics[numMechs]:SetPoint("LEFT", mechanicsFrame.Mechanics[numMechs-1], "RIGHT", 12, 0);
		end
		local Mechanic = mechanicsFrame.Mechanics[numMechs];
		Mechanic.mainFrame = self:GetParent();
		Mechanic.info = mechanic;
		Mechanic.Icon:SetTexture(mechanic.icon);
		Mechanic.mechanicID = id;
		Mechanic:Show();
		-- counter
		local countered = true;
		for index, mechanicID in pairs(encountersFrame.uncounteredMechanics[encounterIndex]) do
			if ( mechanicID == id ) then
				countered = false;
				break;
			end
		end
		if ( countered ) then
			Mechanic.Check:Show();
			playCounteredSound = true;
		else
			Mechanic.Check:Hide();
		end
	end
	for j=(numMechs + 1), #mechanicsFrame.Mechanics do
		mechanicsFrame.Mechanics[j]:Hide();
		mechanicsFrame.Mechanics[j].mechanicID = nil;
		mechanicsFrame.Mechanics[j].info = nil;
	end
	return numMechs, playCounteredSound;
end

function GarrisonMissionComplete:AnimCheckModels(entry)
	self.animNumModelHolds = 0;
	local modelLeft = self.Stage.ModelLeft;
	if ( modelLeft.state == "loading" ) then
		self.animNumModelHolds = self.animNumModelHolds + 1;
	end
	local modelRight = self.Stage.ModelRight;
	if ( modelRight.state == "loading" ) then
		self.animNumModelHolds = self.animNumModelHolds + 1;
	end

	if ( self.animNumModelHolds == 0 ) then
		entry.duration = 0;
	else
		-- wait a little more for models to finish loading	
		entry.duration = 1;
	end
end

GARRISON_ANIMATION_LENGTH = 1;

function GarrisonMissionComplete:AnimModels(entry, failPanType, successPanType, startPositionScale, speedMultiplier)
	self.animNumModelHolds = nil;
	local modelLeft = self.Stage.ModelLeft;
	local modelRight = self.Stage.ModelRight;
	local currentAnim = self.animInfo[self.encounterIndex];
	currentAnim.playImpactSound = false;
	currentAnim.playTargetImpactSound = false;
	-- if enemy model is still loading, ignore it
	if ( modelRight.state == "loading" ) then
		modelRight.state = "empty";
	end
	-- but we must have follower model
	if ( modelLeft.state == "loaded" ) then
		-- play models
		modelLeft:InitializePanCamera(currentAnim.scale or 1)
		modelLeft:SetHeightFactor(currentAnim.height or 0.5);
		if ( self.currentMission.failedEncounter == self.encounterIndex ) then
			-- always same pose on fail
			modelLeft:StartPan(failPanType, GARRISON_ANIMATION_LENGTH, true, currentAnim.castID, startPositionScale, speedMultiplier);
		else
			modelLeft:StartPan(successPanType, GARRISON_ANIMATION_LENGTH, true, currentAnim.castID, startPositionScale, speedMultiplier);
			if ( currentAnim.impactSoundID ) then
				currentAnim.playImpactSound = true;
			end
		end
		PlaySound("UI_Garrison_MissionEncounter_Animation_Generic");		
		if ( currentAnim.castSoundID ) then
			PlaySoundKitID(currentAnim.castSoundID);
		end
		-- enemy model is optional
		if ( modelRight.state == "loaded" ) then
			modelRight:InitializePanCamera(currentAnim.enemyScale or 1);
			modelRight:SetHeightFactor(currentAnim.enemyHeight or 0.5);
			modelRight:SetAnimOffset(currentAnim.impactDelay  or 0);
			if ( self.currentMission.failedEncounter == self.encounterIndex ) then
				-- play the targetImpactID animation on fail if it exists; otherwise skip the impact animation
				if (currentAnim.targetImpactID and currentAnim.targetImpactID ~= 0) then
					modelRight:StartPan(LE_PAN_NONE, GARRISON_ANIMATION_LENGTH, true, currentAnim.targetImpactID);
					if (currentAnim.targetImpactSoundID) then
						currentAnim.playTargetImpactSound = true;
					end
				else
					modelRight:StartPan(LE_PAN_NONE, GARRISON_ANIMATION_LENGTH, true);
				end
				-- play the miss
				self.Stage.Miss.Anim.WaitAlpha:SetDuration(currentAnim.impactDelay);
				self.Stage.Miss.Anim:Play();
			else
				modelRight:StartPan(LE_PAN_NONE, GARRISON_ANIMATION_LENGTH, true, currentAnim.impactID);
			end
		end
		if ( currentAnim.playImpactSound or currentAnim.playTargetImpactSound ) then
			entry.duration = currentAnim.impactDelay;
		else
			entry.duration = 0.9;
		end
	else
		-- no models, skip
		entry.duration = 0;
	end
end

function GarrisonMissionComplete:AnimPlayImpactSound(entry)
	local currentAnim = self.animInfo[self.encounterIndex];
	if ( currentAnim.playImpactSound ) then
		PlaySoundKitID(currentAnim.impactSoundID);
		entry.duration = 0.9 - currentAnim.impactDelay;
	elseif ( currentAnim.playTargetImpactSound ) then
		PlaySoundKitID(currentAnim.targetImpactSoundID);
		entry.duration = 0.9 - currentAnim.impactDelay;
	else
		entry.duration = 0;
	end
end

function GarrisonMissionComplete:AnimRewards(entry)
	self.BonusRewards.Saturated:Show();
	self.BonusRewards.Saturated.FadeIn:Play();

	if ( self.currentMission.succeeded ) then
		self.ChanceFrame.ResultText:SetText(GARRISON_MISSION_SUCCESS);
		self.ChanceFrame.ResultText:SetTextColor(0.1, 1, 0.1);
		self.ChanceFrame.ResultAnim:Play();
		self.BonusRewards.ChestModel:SetAnimation(0, 0);
		PlaySound("UI_Garrison_CommandTable_MissionSuccess_Stinger");
	else
		self.ChanceFrame.ResultText:SetText(GARRISON_MISSION_FAILED);
		self.ChanceFrame.ResultText:SetTextColor(1, 0.1, 0.1);
		self.ChanceFrame.ResultAnim:Play();
		self.NextMissionButton:Enable();
		PlaySound("UI_Garrison_Mission_Complete_MissionFail_Stinger");
	end
end

function GarrisonMissionComplete:AnimLockBurst(entry)
	if ( self.currentMission.succeeded ) then
		self.BonusRewards.ChestModel.LockBurstAnim:Play();
		PlaySound("UI_Garrison_CommandTable_ChestUnlock");
		if ( C_Garrison.CanOpenMissionChest(self.currentMission.missionID) ) then
			self.BonusRewards.ChestModel.ClickFrame:Show();
		end
	else
		self.NextMissionButton:Enable();
	end
end

function GarrisonMissionComplete:AnimCleanUp(entry)
	local models = self.Stage.Models;
	for i = 1, #models do
		models[i]:StopPan();
		models[i]:ClearModel();
	end
end

function GarrisonMissionComplete:AnimXP(entry)
	for i = 1, #self.currentMission.followers do
		self:CheckAndShowFollowerXP(self.currentMission.followers[i]);
	end
end

function GarrisonMissionComplete:AnimSkipWait(entry)
	if ( self.skipAnimations ) then
		entry.duration = 1.25;
	else
		entry.duration = 0;
	end	
end

function GarrisonMissionComplete:AnimSkipNext(entry)
	if ( self.skipAnimations ) then
		self.NextMissionButton:Click();
	end
end

function GarrisonMissionComplete:OnSkipKeyPressed(key)
	if ( key == "SPACE" ) then
		self:SetPropagateKeyboardInput(false);
		local animIndex = self.animIndex;
		-- checking for animIndex to see if animations have started
		if ( animIndex and not self.skipAnimations ) then
			self.skipAnimations = true;
			local followersInAnimIndex = self:FindAnimIndexFor(self.AnimFollowersIn);
			if ( animIndex < followersInAnimIndex ) then
				-- STATE: animating through fights or rewards
				-- play sounds if we haven't yet
				local playSound = (animIndex < self:FindAnimIndexFor(GarrisonMissionComplete.AnimRewards));
				-- hide encounters
				self.Stage.EncountersFrame.FadeOut:Stop();
				self.Stage.EncountersFrame:Hide();
				-- rewards bg
				self.BonusRewards.Saturated:Show();
				self.BonusRewards.Saturated:SetAlpha(1);
				-- success or failure text
				self.ChanceFrame.SuccessChanceInAnim:Stop();	
				self.ChanceFrame.ResultAnim:Stop();
				self.ChanceFrame.ChanceText:SetAlpha(0);
				self.ChanceFrame.ChanceGlow:SetAlpha(0);
				self.ChanceFrame.SuccessGlow:SetAlpha(0);
				self.ChanceFrame.Banner:SetAlpha(1);
				self.ChanceFrame.Banner:SetWidth(GARRISON_MISSION_COMPLETE_BANNER_WIDTH);
				self.ChanceFrame.ResultText:SetAlpha(1);			
				if ( self.currentMission.succeeded ) then
					self.ChanceFrame.ResultText:SetText(GARRISON_MISSION_SUCCESS);
					self.ChanceFrame.ResultText:SetTextColor(0.1, 1, 0.1);
					if ( playSound ) then
						PlaySound("UI_Garrison_CommandTable_MissionSuccess_Stinger");
					end
					-- remove chest
					self.BonusRewards.ChestModel.OpenAnim:Stop();
					self.BonusRewards.ChestModel.LockBurstAnim:Stop();
					self.BonusRewards.ChestModel:SetAlpha(0);
					self.BonusRewards.ChestModel.ClickFrame:Hide();
					-- rewards and enable Next button
					self:ShowRewards();
				else
					self.ChanceFrame.ResultText:SetText(GARRISON_MISSION_FAILED);
					self.ChanceFrame.ResultText:SetTextColor(1, 0.1, 0.1);
					if ( playSound ) then
						PlaySound("UI_Garrison_Mission_Complete_MissionFail_Stinger");
					end
					-- enable Next button
					self.NextMissionButton:Enable();
				end
				-- complete mission
				C_Garrison.MissionBonusRoll(self.currentMission.missionID);
				-- set animation to AnimCleanUp
				self:BeginAnims(self:FindAnimIndexFor(self.AnimCleanUp) - 1);
			else
				if ( self.currentMission.succeeded ) then
					-- remove chest
					self.BonusRewards.ChestModel.OpenAnim:Stop();
					self.BonusRewards.ChestModel.LockBurstAnim:Stop();
					self.BonusRewards.ChestModel:SetAlpha(0);
					self.BonusRewards.ChestModel.ClickFrame:Hide();
					-- rewards and enable Next button
					self:ShowRewards();
					-- if we restart animations we don't want to be further than AnimSkipWait
					local newAnimIndex = min(animIndex, self:FindAnimIndexFor(self.AnimSkipWait));
					-- check rewards state
					if ( self.BonusRewards:IsEventRegistered("GARRISON_MISSION_BONUS_ROLL_COMPLETE") ) then
						-- STATE: player already clicked chest and is waiting for rewards
						-- stop the event and timer
						self.BonusRewards:UnregisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")
						self.BonusRewards.timerMissionID = nil;
						-- restart anim with the current index
						self:BeginAnims(newAnimIndex - 1);
					elseif ( not self.rollCompleted ) then
						-- STATE: chest is waiting to be clicked
						-- complete mission
						C_Garrison.MissionBonusRoll(self.currentMission.missionID);
						-- restart anim with the current index
						self:BeginAnims(newAnimIndex - 1);
					else
						-- STATE: player pressed SPACEBAR after roll was completed
						self.NextMissionButton:Click();
					end
				else
					-- STATE: failed mission
					-- for boats we should display death
					local checkBoatDeathAnimIndex = self:FindAnimIndexFor(self.AnimCheckBoatDeath);
					if ( checkBoatDeathAnimIndex ~= 0 and animIndex <= checkBoatDeathAnimIndex ) then
						-- STATE: still processing boat death
						if ( animIndex == checkBoatDeathAnimIndex ) then
							-- don't do anything here, it's gonna loop anyway if there are boats left
						elseif ( animIndex == followersInAnimIndex ) then
							self:BeginAnims(self:FindAnimIndexFor(self.AnimBoatDeath) - 1);
						else
							-- force next evaluation now
							self:BeginAnims(checkBoatDeathAnimIndex - 1);
						end
					else
						-- STATE: player pressed SPACEBAR after all boat deaths have been done
						self.NextMissionButton:Click();
					end
				end
			end
		else
			-- we're already skipping animations and player pressed SPACEBAR again, just go to next mission
			-- it's not going to do anything if animations haven't started yet
			self.NextMissionButton:Click();
		end
	else
		self:SetPropagateKeyboardInput(true);
	end
end

---------------------------------------------------------------------------------
--- Garrison Mission Complete XPBar Mixin Functions                           ---
---------------------------------------------------------------------------------

function GarrisonMissionComplete:CheckAndShowFollowerXP(followerID)
	local pendingXPAwards = self.pendingXPAwards;
	for k, v in pairs(pendingXPAwards) do
		if ( v.followerID == followerID ) then
			self:AnimFollowerXP(v.followerID, v.xpAward, v.oldXP, v.oldLevel, v.oldQuality);
			tremove(pendingXPAwards, k);
			return;
		end
	end
end

function GarrisonMissionComplete:GetFollowerNextLevelXP(level, quality)
	if ( level < self:GetParent().followerMaxLevel ) then
		return self:GetParent().followerXPTable[level];
	elseif ( quality < self:GetParent().followerMaxQuality ) then
		return self:GetParent().followerQualityTable[quality];
	else
		return nil;
	end	
end

function GarrisonMissionComplete:AnimFollowerXP(followerID, xpAward, oldXP, oldLevel, oldQuality)
	local missionList = self.completeMissions;
	local missionIndex = self.currentIndex;
	local mission = missionList[missionIndex];
	
	if (not mission) then
		return;
	end

	for i = 1, #mission.followers do
		local followerFrame = self.Stage.FollowersFrame.Followers[i];
		if ( followerFrame.followerID == followerID ) then
			-- play anim now if we finished animating followers in
			local animIndex = self:FindAnimIndexFor(self.AnimFollowersIn);
			if ( self.animIndex and self.animIndex > animIndex and (not followerFrame.activeAnims or followerFrame.activeAnims == 0) ) then
				if ( xpAward > 0 ) then
					self:SetFollowerLevel(followerFrame, oldLevel, oldQuality, oldXP, self:GetFollowerNextLevelXP(oldLevel, oldQuality));
					self:AwardFollowerXP(followerFrame, xpAward);
				else
					-- lost xp, no anim
					local _, _, level, quality, currXP, maxXP = C_Garrison.GetFollowerMissionCompleteInfo(followerID);
					self:SetFollowerLevel(followerFrame, level, quality, currXP, maxXP);
				end
			else
				-- save for later
				local t = {};
				t.followerID = followerID;
				t.xpAward = xpAward;
				t.oldXP = oldXP;
				t.oldLevel = oldLevel;
				t.oldQuality = oldQuality;
				tinsert(self.pendingXPAwards, t);
			end
			break;
		end
	end
end

function GarrisonMissionComplete:AwardFollowerXP(followerFrame, xpAward)
	local xpBar = followerFrame.XP;
	local xpFrame = followerFrame.XPGain;
	-- xp text
	xpFrame:Show();
	xpFrame.FadeIn:Play();
	xpFrame.Text:SetFormattedText(XP_GAIN, BreakUpLargeNumbers(xpAward));
	-- bar
	local _, maxXP = xpBar:GetMinMaxValues();
	if ( xpBar:GetValue() + xpAward >  maxXP ) then
		xpBar.toGoXP = maxXP - xpBar:GetValue();
		xpBar.remainingXP = xpAward - xpBar.toGoXP;
	else
		xpBar.toGoXP = xpAward;
		xpBar.remainingXP = 0;
	end
	followerFrame.activeAnims = 2;	-- text & bar
	self:AnimXPBar(xpBar);
end

function GarrisonMissionComplete:AnimXPBar(xpBar)
	xpBar.timeIn = 0;
	xpBar.startXP = xpBar:GetValue();
	local _, maxXP = xpBar:GetMinMaxValues();
	xpBar.duration = xpBar.toGoXP / maxXP * xpBar.length / 25;
	xpBar.missionCompleteFrame = self;
	xpBar:SetScript("OnUpdate", GarrisonMissionComplete_AnimXPBar_OnUpdate);
end

function GarrisonMissionComplete_AnimXPBar_OnUpdate(self, elapsed)
	self.timeIn = self.timeIn + elapsed;
	if ( self.timeIn >= self.duration ) then
		self.timeIn = nil;
		self:SetScript("OnUpdate", nil);
		self:SetValue(self.startXP + self.toGoXP);
		self.missionCompleteFrame:AnimXPBarOnFinish(self);
	else
		self:SetValue(self.startXP + (self.timeIn / self.duration) * self.toGoXP);
	end
end

function GarrisonMissionComplete:AnimXPBarOnFinish(xpBar)
	local _, maxXP = xpBar:GetMinMaxValues();
	if ( xpBar:GetValue() == maxXP ) then
		-- leveled up!
		local followerFrame = xpBar:GetParent();
		local levelUpFrame = followerFrame.LevelUpFrame;
		if ( not levelUpFrame:IsShown() ) then
			levelUpFrame:Show();
			levelUpFrame:SetAlpha(1);
			levelUpFrame.Anim:Play();
		end
		
		local maxLevel = self:GetParent().followerMaxLevel;
		local nextLevel, nextQuality;
		if ( xpBar.level == maxLevel ) then
			-- at max level progress the quality
			nextLevel = xpBar.level;
			nextQuality = xpBar.quality + 1;
			-- and cap it to the max attainable via xp	
			nextQuality = min(nextQuality, self:GetParent().followerMaxQuality);
		else
			nextLevel = xpBar.level + 1;
			nextQuality = xpBar.quality;
		end
	
		local nextLevelXP = self:GetFollowerNextLevelXP(nextLevel, nextQuality);
		self:SetFollowerLevel(followerFrame, nextLevel, nextQuality, 0, nextLevelXP);
		if ( nextLevelXP ) then
			maxXP = nextLevelXP;
		else
			-- ensure we're done
			xpBar.remainingXP = 0;
		end
		-- visual
		local models = self.Stage.Models;
		for i = 1, #models do
			if ( models[i].followerID == followerFrame.followerID and models[i]:IsShown() ) then
				models[i]:SetSpellVisualKit(6375);	-- level up visual
				PlaySound("UI_Garrison_CommandTable_Follower_LevelUp");
				break;
			end
		end
	end
	if ( xpBar.remainingXP > 0 ) then
		-- we still have XP to go
		local availableXP = maxXP - xpBar:GetValue();
		if ( xpBar.remainingXP > availableXP ) then
			xpBar.toGoXP = availableXP;
			xpBar.remainingXP = xpBar.remainingXP - availableXP;
		else
			xpBar.toGoXP = xpBar.remainingXP;
			xpBar.remainingXP = 0;
		end
		self:AnimXPBar(xpBar);
	else
		self:OnFollowerXPFinished(xpBar:GetParent());
	end
end

function GarrisonMissionComplete:OnFollowerXPFinished(followerFrame)
	followerFrame.activeAnims = followerFrame.activeAnims - 1;
	if ( followerFrame.activeAnims == 0 ) then
		self:CheckAndShowFollowerXP(followerFrame.followerID);
	end
end

function GarrisonMissionComplete_AnimXPGainOnStop(self)
	local followerFrame = self:GetParent():GetParent();
	followerFrame.activeAnims = followerFrame.activeAnims - 1;
end

function GarrisonMissionComplete_AnimXPGainOnFinish(self)
	local followerFrame = self:GetParent():GetParent();
	local missionCompleteFrame = followerFrame:GetParent():GetParent():GetParent();
	missionCompleteFrame:OnFollowerXPFinished(followerFrame);
end


---------------------------------------------------------------------------------
--- Common Functions                                                          ---
---------------------------------------------------------------------------------

function GarrisonMissionFrameTab_OnEnter(self)
	self.LeftHighlight:Show();
	self.MiddleHighlight:Show();
	self.RightHighlight:Show();
end

function GarrisonMissionFrameTab_OnLeave(self)
	self.LeftHighlight:Hide();
	self.MiddleHighlight:Hide();
	self.RightHighlight:Hide();
end

function GarrisonMissionFrame_SetItemRewardDetails(frame)
	local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(frame.itemID);
	frame.Icon:SetTexture(itemTexture);
	if (frame.Name and itemName and itemRarity) then
		frame.Name:SetText(ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE);
	end
end

function GarrisonMissionPage_SetReward(frame, reward)
	frame.Quantity:Hide();
	frame.itemID = nil;
	frame.currencyID = nil;
	frame.currencyQuantity = nil;
	frame.tooltip = nil;
	frame.bonusAbilityID = nil;
	if (reward.itemID) then
		frame.itemID = reward.itemID;
		if ( reward.quantity > 1 ) then
			frame.Quantity:SetText(reward.quantity);
			frame.Quantity:Show();
		end
		GarrisonMissionFrame_SetItemRewardDetails(frame);
	else
		frame.Icon:SetTexture(reward.icon);
		frame.title = reward.title
		if (reward.currencyID and reward.quantity) then
			if (reward.currencyID == 0) then
				frame.tooltip = GetMoneyString(reward.quantity);
				frame.currencyID = 0;
				frame.currencyQuantity = reward.quantity;
				if (frame.Name) then
					frame.Name:SetText(frame.tooltip);
				end
			else
				local currencyName, _, currencyTexture = GetCurrencyInfo(reward.currencyID);
				frame.currencyID = reward.currencyID;
				frame.currencyQuantity = reward.quantity;
				if (frame.Name) then
					frame.Name:SetText(currencyName);
				end
				frame.Quantity:SetText(reward.quantity);
				frame.Quantity:Show();
			end
		elseif (reward.bonusAbilityID) then
			frame.bonusAbilityID = reward.bonusAbilityID;
			frame.icon = reward.icon;
			frame.name = reward.name;
			frame.description = reward.description;
			frame.duration = reward.duration;
			if (frame.Name) then
				frame.Name:SetText(reward.name);
			end
		else
			frame.tooltip = reward.tooltip;
			if (frame.Name) then
				if (reward.quality) then
					frame.Name:SetText(ITEM_QUALITY_COLORS[reward.quality + 1].hex..frame.title..FONT_COLOR_CODE_CLOSE);
				elseif (reward.followerXP) then
					frame.Name:SetFormattedText(GARRISON_REWARD_XP_FORMAT, BreakUpLargeNumbers(reward.followerXP));
				else
					frame.Name:SetText(frame.title);
				end
			end
		end
	end
	frame:Show();
end

function GarrisonMissionPage_RewardOnEnter(self)
	if (self.bonusAbilityID) then
		local tooltip = GarrisonBonusAreaTooltip;
		GarrisonBonusArea_Set(tooltip.BonusArea, GARRISON_BONUS_EFFECT_TIME_ACTIVE, self.duration, self.icon, self.name, self.description);
		
		tooltip:ClearAllPoints();
		tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
		tooltip:SetHeight(tooltip.BonusArea:GetHeight());
		tooltip:Show();
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		if (self.itemID) then
			GameTooltip:SetItemByID(self.itemID);
			return;
		end
		if (self.currencyID and self.currencyID ~= 0) then
			GameTooltip:SetCurrencyByID(self.currencyID);
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

function GarrisonMissionPage_RewardOnLeave(self)
	GarrisonBonusAreaTooltip:Hide();
	GameTooltip_Hide(self);
end

function GarrisonMissionPage_UpdateRewardQuantities(rewardsFrame, currencyMultipliers, goldMultiplier)
	for i = 1, #rewardsFrame.Rewards do
		local rewardFrame = rewardsFrame.Rewards[i];
		if ( rewardFrame.currencyID and rewardFrame.currencyID ~= 0 and rewardFrame:IsShown() ) then
			local multiplier = currencyMultipliers[rewardFrame.currencyID] or 1;
			local amount = floor(rewardFrame.currencyQuantity * multiplier);
			rewardFrame.Quantity:SetText(amount);
		elseif ( rewardFrame.currencyID == 0 and rewardFrame:IsShown() ) then
			local amount = floor(rewardFrame.currencyQuantity * goldMultiplier);
			rewardFrame.tooltip = GetMoneyString(amount);
			if (rewardFrame.Name) then
				rewardFrame.Name:SetText(rewardFrame.tooltip);
			end
		end
	end
end

function GarrisonMissionPageRewardsFrame_OnUpdate(self, elapsed)
	self.elapsedTime = self.elapsedTime + elapsed;
	-- 0 to 100 should take 1 second
	local newChance = math.floor(self.startingChance + self.elapsedTime * 100);
	newChance = min(newChance, self.endingChance);
	self.Chance:SetFormattedText(PERCENTAGE_STRING, newChance);
	self.currentChance = newChance
	if ( newChance == self.endingChance ) then
		if ( newChance == 100 ) then
			PlaySoundKitID(43507);	-- 100% chance reached
		end
		GarrisonMissionPageRewardsFrame_StopUpdate(self);
	end
end

function GarrisonMissionPageRewardsFrame_StopUpdate(self)
	self.elapsedTime = nil;
	self.startingChance = nil;
	self.endingChance = nil;
	self:SetScript("OnUpdate", nil);
end

function GarrisonShowFollowerPlacerFrame(mainFrame, info)
	GarrisonFollowerPlacerFrame.mainFrame = mainFrame;
	GarrisonFollowerPlacerFrame.info = info;
	GarrisonFollowerPlacerFrame:Show();
end

--this function puts check marks on the encounter mechanics countered by the slotted followers abilities
function GarrisonMissionPage_SetCounters(Followers, Enemies, missionID)
	-- clear counter state
	for i = 1, #Enemies do
		local enemyFrame = Enemies[i];
		for mechanicIndex = 1, #enemyFrame.Mechanics do
			enemyFrame.Mechanics[mechanicIndex].hasCounter = nil;
		end
	end
	
	for i = 1, #Followers do
		local followerFrame = Followers[i];
		if (followerFrame.info) then
			local followerBias = C_Garrison.GetFollowerBiasForMission(missionID, followerFrame.info.followerID);
			if ( followerBias > -1 ) then
				local abilities = C_Garrison.GetFollowerAbilities(followerFrame.info.followerID);
				for a = 1, #abilities do
					local ability = abilities[a];
					for counterID, counterInfo in pairs(ability.counters) do
						GarrisonMissionPage_CheckCounter(Enemies, counterID);
					end
				end
			end
		end
	end
	
	local bonusEffects = C_Garrison.GetMissionBonusAbilityEffects(missionID);
	for i = 1, #bonusEffects do
		local mechanicTypeID = bonusEffects[i].mechanicTypeID;
		if(mechanic ~= 0) then
			GarrisonMissionPage_CheckCounter(Enemies, mechanicTypeID);
		end
	end
	
	-- show/remove checks
	local playSound = false;
	for i = 1, #Enemies do
		local enemyFrame = Enemies[i];
		for mechanicIndex = 1, #enemyFrame.Mechanics do
			local mechanicFrame = enemyFrame.Mechanics[mechanicIndex];
			if ( mechanicFrame.hasCounter ) then
				if ( not mechanicFrame.Check:IsShown() ) then
					mechanicFrame.Check:SetAlpha(1);
					mechanicFrame.Check:Show();
					mechanicFrame.Anim:Play();
					-- play sound if frame is visible
					playSound = enemyFrame:IsVisible();
				end
			else
				mechanicFrame.Check:Hide();
			end
		end
	end
	
	if ( playSound ) then
		PlaySound("UI_Garrison_Mission_Threat_Countered");
	end
end

function GarrisonMissionPage_CheckCounter(enemies, counterID)
	for i = 1, #enemies do
		local enemyFrame = enemies[i];
		for mechanicIndex = 1, #enemyFrame.Mechanics do
			if ( counterID == enemyFrame.Mechanics[mechanicIndex].mechanicID and not enemyFrame.Mechanics[mechanicIndex].hasCounter ) then			
				enemyFrame.Mechanics[mechanicIndex].hasCounter = true;
				return;
			end
		end
	end
end

---------------------------------------------------------------------------------
--- Template Functions                                                        ---
---------------------------------------------------------------------------------

function GarrisonMissionFrame_OnLoad(self)
	self:OnLoadMainFrame();
end

function GarrisonMissionController_OnClickTab(tab)
	local mainFrame = tab:GetParent();
	PlaySound("UI_Garrison_Nav_Tabs");
	PanelTemplates_SetTab(mainFrame, tab:GetID());
	mainFrame:SelectTab(tab:GetID());
end

function GarrisonMissionController_CloseMission(buttonFrame)
	local mainFrame = buttonFrame:GetParent():GetParent():GetParent();
	mainFrame:CloseMission();
end

--parallax rates in % texCoords per second
local rateBack = 0.1; 
local rateMid = 0.3;
local rateFore = 0.8;

function GarrisonMissionController_OnStageUpdate(self, elapsed)
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

function GarrisonMissionController_OnEnterMissionStartButton(self)
	if (not self:IsEnabled()) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function GarrisonMissionController_OnClickMissionStartButton(buttonFrame)
	local mainFrame = buttonFrame:GetParent():GetParent():GetParent();
	mainFrame:OnClickStartMissionButton();
end

function GarrisonMissionStage_OnLoad(self)
	self.LocBack:SetAtlas("_GarrMissionLocation-TannanJungle-Back", true);
	self.LocMid:SetAtlas ("_GarrMissionLocation-TannanJungle-Mid", true);
	self.LocFore:SetAtlas("_GarrMissionLocation-TannanJungle-Fore", true);
	local _, backWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Back");
	local _, midWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Mid");
	local _, foreWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Fore");
	local texWidth = self.LocBack:GetWidth();
	self.LocBack:SetTexCoord(0, texWidth/backWidth,  0, 1);
	self.LocMid:SetTexCoord (0, texWidth/midWidth, 0, 1);
	self.LocFore:SetTexCoord(0, texWidth/foreWidth, 0, 1);
end

function GarrisonFollowerPlacerFrame_OnClick(self, button)
	self.mainFrame:OnClickFollowerPlacerFrame(button, self.info);
end

function GarrisonMissionController_OnClickViewCompletedMissionsButton(self)
	local mainFrame = self:GetParent():GetParent():GetParent():GetParent():GetParent();
	mainFrame:OnClickViewCompletedMissionsButton();
end

function GarrisonMissionComplete_OnLoad(self)
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
	self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE");
	self.pendingXPAwards = { };
	self:SetFrameLevel(self:GetParent().MissionCompleteBackground:GetFrameLevel() + 2);
	self:SetAnimationControl();
end

function GarrisonMissionComplete_OnEvent(self, event, ...)
	local mainFrame = self:GetParent();
	if (event == "GARRISON_FOLLOWER_XP_CHANGED" and self:IsVisible()) then
		self:AnimFollowerXP(...);
	elseif ( event == "GARRISON_MISSION_COMPLETE_RESPONSE" ) then
		self:OnMissionCompleteResponse(...);
	end
end

function GarrisonMissionComplete_OnModelLoaded(self)
	-- making sure we didn't give up on loading this model
	if ( self.state == "loading" ) then
		self.state = "loaded";
		-- is the anim paused for models?
		local frame = self:GetParent():GetParent();
		if ( frame.animNumModelHolds ) then
			frame.animNumModelHolds = frame.animNumModelHolds - 1;
			-- no models left to load, full speed ahead
			if ( frame.animNumModelHolds == 0 ) then
				frame.animTimeLeft = 0;
			end
		end
	end
end

function GarrisonMissionCompleteChest_OnMouseDown(self)
	local missionCompleteFrame = self:GetParent():GetParent():GetParent();
	missionCompleteFrame.NextMissionButton:Enable();
	if ( C_Garrison.CanOpenMissionChest(missionCompleteFrame.currentMission.missionID) ) then
		-- hide the click frame
		self:Hide();

		local bonusRewards = missionCompleteFrame.BonusRewards;
		bonusRewards.waitForEvent = true;
		bonusRewards.waitForTimer = true;
		bonusRewards.success = false;
		bonusRewards:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE");
		bonusRewards.ChestModel:SetAnimation(154);
		bonusRewards.ChestModel.OpenAnim:Play();
		bonusRewards.timerMissionID = missionCompleteFrame.currentMission.missionID
		C_Timer.After(1.1,
			function()
				if ( bonusRewards.timerMissionID == missionCompleteFrame.currentMission.missionID ) then
					bonusRewards.waitForTimer = nil;
					if ( not bonusRewards.waitForEvent ) then
						missionCompleteFrame:ShowRewards();
					end
				end
			end
		);
		C_Garrison.MissionBonusRoll(missionCompleteFrame.currentMission.missionID);
		PlaySound("UI_Garrison_CommandTable_ChestUnlock_Gold_Success");
		missionCompleteFrame.NextMissionButton:Disable();
	end
end

function GarrisonMissionCompleteChest_OnEnter(self)
	local missionCompleteFrame = self:GetParent():GetParent():GetParent();
	if ( C_Garrison.CanOpenMissionChest(missionCompleteFrame.currentMission.missionID) ) then
		SetCursor("INTERACT_CURSOR");
	end
end

function GarrisonMissionCompleteChest_OnLeave(self)
	ResetCursor();
end

function GarrisonMissionComplete_OnRewardEvent(self, event, ...)
	local missionID, success = ...;
	local missionCompleteFrame = self:GetParent();
	if ( missionCompleteFrame.currentMission and missionCompleteFrame.currentMission.missionID == missionID ) then
		self:UnregisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE");
		self.waitForEvent = nil;
		self.success = success;
		missionCompleteFrame.rollCompleted = true;
		if ( not self.waitForTimer ) then
			missionCompleteFrame:ShowRewards();
		end
	end
end


---------------------------------------------------------------------------------
--- Tooltips                                                                  ---
---------------------------------------------------------------------------------

function GarrisonMissionMechanic_OnEnter(self)
	if (not self.info) then
		return;
	end
	local tooltip = GarrisonMissionMechanicTooltip;
	
	-- Tooltip needs to be parented to the main frame. Since this tooltip frame is shared between
	-- multiple main frames, we need to set the parent here. Also set the frame strata because 
	-- setting the parent loses the frame strata. This is a bug we should fix in 7.0.
	tooltip:SetParent(self.mainFrame);
	tooltip:SetFrameStrata("TOOLTIP");
	if (not self.followerTypeID) then
		self.followerTypeID = LE_FOLLOWER_TYPE_GARRISON_6_0;
	end
	if ( self.info.factor <= GARRISON_HIGH_THREAT_VALUE and self.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
		tooltip.Border:SetAtlas("GarrMission_WeakEncounterAbilityBorder-Lg");
	else
		tooltip.Border:SetAtlas("GarrMission_EncounterAbilityBorder-Lg");
	end
	
	tooltip.Icon:SetTexture(self.info.icon);
	tooltip.Name:SetText(self.info.name);
	local height = tooltip.Icon:GetHeight() + 28; --height of icon plus padding around it and at the bottom
	tooltip.Description:SetText(self.info.description);
	height = height + tooltip.Description:GetHeight();
	tooltip:SetHeight(height);
	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 5, 0);
	tooltip:Show();
end

function GarrisonMissionMechanicFollowerCounter_OnEnter(self)
	if (not self.info) then
		return;
	end
	if ( self.info.traitID ) then
		GarrisonFollowerAbilityTooltip:ClearAllPoints();
		GarrisonFollowerAbilityTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT");
		GarrisonFollowerAbilityTooltip_Show(self.info.traitID, self.followerTypeID);
		return;
	end
	local tooltip = GarrisonMissionMechanicFollowerCounterTooltip;
	tooltip.Icon:SetTexture(self.info.icon);
	tooltip.Name:SetText(self.info.name);
	if (self.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
		tooltip.Subtitle:SetText(GARRISON_SHIP_CAN_COUNTER);
	else
		tooltip.Subtitle:SetText(GARRISON_FOLLOWER_CAN_COUNTER);
	end
	local height = tooltip.Title:GetHeight() + tooltip.Subtitle:GetHeight() + tooltip.Icon:GetHeight() + 28; --height of icon plus padding around it and at the bottom

	if (self.info.showCounters) then
		tooltip.CounterFrom:Show();
		tooltip.CounterIcon:Show();
		tooltip.CounterName:Show();
		tooltip.CounterIcon:SetTexture(self.info.counterIcon);
		tooltip.CounterName:SetText(self.info.counterName);
		
		if ( self.info.factor <= GARRISON_HIGH_THREAT_VALUE and self.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
			tooltip.Border:SetAtlas("GarrMission_WeakEncounterAbilityBorder-Lg");
		else
			tooltip.Border:SetAtlas("GarrMission_EncounterAbilityBorder-Lg");
		end
		
		height = height + 21 + tooltip.CounterFrom:GetHeight() + tooltip.CounterIcon:GetHeight();
	else
		tooltip.CounterFrom:Hide();
		tooltip.CounterIcon:Hide();
		tooltip.CounterName:Hide();
	end
	
	tooltip:SetHeight(height);
	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 5, 0);
	tooltip:Show();
end

function GarrisonMissionMechanicFollowerCounter_OnLeave(self)
	GarrisonFollowerAbilityTooltip:Hide();
	GarrisonMissionMechanicFollowerCounterTooltip:Hide();
end

function GarrisonMission_DetermineCounterableThreats(missionID, followerType)
	local threats = {};
	threats.full = {};
	threats.partial = {};
	threats.away = {};
	threats.worker = {};

	local followerList = C_Garrison.GetFollowers(followerType);
	for i = 1, #followerList do
		local follower = followerList[i];
		if ( follower.isCollected and follower.status ~= GARRISON_FOLLOWER_INACTIVE ) then
			local bias = C_Garrison.GetFollowerBiasForMission(missionID, follower.followerID);
			if ( bias > -1.0 ) then
				local abilities = C_Garrison.GetFollowerAbilities(follower.followerID);
				for j = 1, #abilities do
					for counterMechanicID in pairs(abilities[j].counters) do
						if ( follower.status ) then
							if ( follower.status == GARRISON_FOLLOWER_ON_MISSION ) then
								local time = C_Garrison.GetFollowerMissionTimeLeftSeconds(follower.followerID);
								if ( not threats.away[counterMechanicID] ) then
									threats.away[counterMechanicID] = {};
								end
								table.insert(threats.away[counterMechanicID], time);
							elseif ( follower.status == GARRISON_FOLLOWER_WORKING ) then
								threats.worker[counterMechanicID] = (threats.worker[counterMechanicID] or 0) + 1;
							end
						else
							local isFullCounter = C_Garrison.IsMechanicFullyCountered(missionID, follower.followerID, counterMechanicID, abilities[j].id);
							if ( isFullCounter ) then
								threats.full[counterMechanicID] = (threats.full[counterMechanicID] or 0) + 1;
							else
								threats.partial[counterMechanicID] = (threats.partial[counterMechanicID] or 0) + 1;
							end
						end
					end
				end
			end
		end
	end
	
	local bonusEffects = C_Garrison.GetMissionBonusAbilityEffects(missionID);
	for i = 1, #bonusEffects do
		local mechanicTypeID = bonusEffects[i].mechanicTypeID;
		if(mechanicTypeID ~= 0) then
			threats.full[mechanicTypeID] = (threats.full[mechanicTypeID] or 0) + 1;
		end
	end

	for counter, times in pairs(threats.away) do
		table.sort(times);
	end
	return threats;
end

function GarrisonMissionButton_AddThreatsToTooltip(missionID, followerType, noGameTooltip)
	local location, xp, environment, environmentDesc, _, locPrefix, isExhausting, enemies = C_Garrison.GetMissionInfo(missionID);
	local numThreats = 0;

	-- Make a list of all the threats that we can counter.
	local counterableThreats = GarrisonMission_DetermineCounterableThreats(missionID, followerType);

	for i = 1, #enemies do
		local enemy = enemies[i];
		for mechanicID, mechanic in pairs(enemy.mechanics) do
			numThreats = numThreats + 1;
			local threatFrame = GarrisonMissionListTooltipThreatsFrame.Threats[numThreats];
			if ( not threatFrame ) then
				threatFrame = CreateFrame("Frame", nil, GarrisonMissionListTooltipThreatsFrame, "GarrisonAbilityCounterWithCheckTemplate");
				threatFrame:SetPoint("LEFT", GarrisonMissionListTooltipThreatsFrame.Threats[numThreats - 1], "RIGHT", 10, 0);
				tinsert(GarrisonMissionListTooltipThreatsFrame.Threats, threatFrame);
			end
			
			if ( mechanic.factor <= GARRISON_HIGH_THREAT_VALUE and followerType == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
				threatFrame.Border:SetAtlas("GarrMission_WeakEncounterAbilityBorder");
			else
				threatFrame.Border:SetAtlas("GarrMission_EncounterAbilityBorder");
			end
			
			threatFrame.Icon:SetTexture(mechanic.icon);
			threatFrame:Show();
			GarrisonMissionButton_CheckTooltipThreat(threatFrame, missionID, mechanicID, counterableThreats);
		end
	end

	local hasAway = false;
	local threatSpacing = 30;
	local iconBorder = 10;
	local timeLeftBorder = 3;
	-- calculate the space needed between threats. The time left string may add some space.
	for i = 1, numThreats do
		local threatFrame = GarrisonMissionListTooltipThreatsFrame.Threats[i];
		if ( threatFrame.TimeLeft:IsShown() ) then
			hasAway = true;
			local strWidth = threatFrame.TimeLeft:GetWidth() + timeLeftBorder;
			if (strWidth > threatSpacing) then
				threatSpacing = strWidth;
			end
		end
	end
	-- set uniform spacing for all the threats.
	for i = 1, numThreats do
		local threatFrame = GarrisonMissionListTooltipThreatsFrame.Threats[i];
		threatFrame:SetWidth(threatSpacing - iconBorder);
	end
	local threatsFrameWidth = 24 + threatSpacing * numThreats;
	local threatsFrameHeight = 26; -- minimum height
	-- make space for font string if it's needed.
	if ( hasAway ) then
		threatsFrameHeight = threatsFrameHeight + 10;
	end

	for i = numThreats + 1, #GarrisonMissionListTooltipThreatsFrame.Threats do
		GarrisonMissionListTooltipThreatsFrame.Threats[i]:Hide();
	end
	GarrisonMissionListTooltipThreatsFrame:SetWidth(threatsFrameWidth);
	GarrisonMissionListTooltipThreatsFrame:SetHeight(threatsFrameHeight);
	if ( numThreats > 0 and not noGameTooltip) then
		local usedHeight = GameTooltip_InsertFrame(GameTooltip, GarrisonMissionListTooltipThreatsFrame);
		GarrisonMissionListTooltipThreatsFrame:SetHeight(usedHeight);
	else
		GarrisonMissionListTooltipThreatsFrame:Hide();
	end
	return numThreats;
end

function GarrisonMission_GetDurationStringCompact(time)

	local s_minute = 60;
	local s_hour = s_minute * 60;
	local s_day = s_hour * 24;

	local str;
	if (time >= s_day) then
		time = ((time - 1) / s_day) + 1;
		return string.format(COOLDOWN_DURATION_DAYS, time);
	elseif (time >= s_hour) then
		time = ((time - 1) / s_hour) + 1;
		return string.format(COOLDOWN_DURATION_HOURS, time);
	else
		time = ((time - 1) / s_minute) + 1;
		return string.format(COOLDOWN_DURATION_MIN, time);
	end
end

function GarrisonMissionButton_CheckTooltipThreat(threatFrame, missionID, mechanicID, counterableThreats)
	threatFrame.Check:Hide();
	threatFrame.Away:Hide();
	threatFrame.Working:Hide();
	threatFrame.TimeLeft:Hide();

	-- We remove threat counters from counterableThreats as they are used.

	if ( counterableThreats.full[mechanicID] and counterableThreats.full[mechanicID] > 0 ) then
		counterableThreats.full[mechanicID] = counterableThreats.full[mechanicID] - 1;
		threatFrame.Check:SetAtlas("GarrMission_CounterCheck", true);
		threatFrame.Check:Show();
		return;
	end

	if ( counterableThreats.partial[mechanicID] and counterableThreats.partial[mechanicID] > 0 ) then
		counterableThreats.partial[mechanicID] = counterableThreats.partial[mechanicID] - 1;
		threatFrame.Check:SetAtlas("GarrMission_CounterHalfCheck", true);
		threatFrame.Check:Show();
		return;
	end

	if ( counterableThreats.away[mechanicID] and #counterableThreats.away[mechanicID] > 0 ) then
		local soonestTime = table.remove(counterableThreats.away[mechanicID], 1);
		threatFrame.Away:Show();
		threatFrame.TimeLeft:Show();
		threatFrame.TimeLeft:SetText(GarrisonMission_GetDurationStringCompact(soonestTime));
		return;
	end

	if ( counterableThreats.worker[mechanicID] and counterableThreats.worker[mechanicID] > 0 ) then
		counterableThreats.worker[mechanicID] = counterableThreats.worker[mechanicID] - 1;
		threatFrame.Working:Show();
		return;
	end
end


---------------------------------------------------------------------------------
--- Mission Complete: Preloading Models	                                      ---
---------------------------------------------------------------------------------

local PRELOADING_NUM_MODELS = 0;
local PRELOADING_MISSION_ID = 0;

function MissionCompletePreload_LoadMission(mainFrame, missionID, singleModel)
	if ( missionID == PRELOADING_MISSION_ID ) then
		return;		
	end

	PRELOADING_MISSION_ID = missionID;
	local allDisplayIDs = C_Garrison.GetMissionDisplayIDs(missionID);
	local displayIDs = {};
	
	if (singleModel) then
		-- Only load the first follower model and first encounter model
		local missionInfo = C_Garrison.GetBasicMissionInfo(missionID);
		table.insert(displayIDs, allDisplayIDs[1]);
		table.insert(displayIDs, allDisplayIDs[missionInfo.numFollowers + 1]);
	else
		displayIDs = allDisplayIDs;
	end
	
	local models = mainFrame.MissionTab.MissionCompletePreloadModels;
	-- clean up if needed
	if ( PRELOADING_NUM_MODELS > 0 ) then
		MissionCompletePreload_Cancel(mainFrame);
	end
	-- load models
	PRELOADING_NUM_MODELS = #displayIDs;
	for i = 1, PRELOADING_NUM_MODELS do
		local model = models[i];
		model.loading = true;
		model:SetDisplayInfo(displayIDs[i]);
	end
end

function MissionCompletePreload_Cancel(mainFrame)
	local models = mainFrame.MissionTab.MissionCompletePreloadModels;
	for i = 1, #models do
		models[i].loading = nil;
		models[i]:ClearModel();
	end
	PRELOADING_NUM_MODELS = 0;
	PRELOADING_MISSION_ID = 0;
	models[1]:SetScript("OnUpdate", nil);
end

function MissionCompletePreload_IsReady()
	return PRELOADING_NUM_MODELS == 0;
end

function MissionCompletePreload_OnModelLoaded(self)
	if ( self.loading ) then
		self.loading = nil;
		PRELOADING_NUM_MODELS = PRELOADING_NUM_MODELS - 1;
	end
end

function MissionCompletePreload_OnUpdate(self, elapsed)
	local callback = self.callbackFunc;
	if ( PRELOADING_NUM_MODELS == 0 ) then
		self:SetScript("OnUpdate", nil);
		self.callbackFunc(self.mainFrame);
	else
		self.waitTime = self.waitTime - elapsed;
		if ( self.waitTime <= 0 ) then
			MissionCompletePreload_Cancel(self.mainFrame);
			self.callbackFunc(self.mainFrame);
		end
	end
end

function MissionCompletePreload_StartTimeout(waitTime, callbackFunc, mainFrame)
	local model = mainFrame.MissionTab.MissionCompletePreloadModels[1];
	model:SetScript("OnUpdate", MissionCompletePreload_OnUpdate);
	model.waitTime = waitTime;
	model.callbackFunc = callbackFunc;
	model.mainFrame = mainFrame;
end
