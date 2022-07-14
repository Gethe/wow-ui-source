---------------------------------------------------------------------------------
--- Base Mission Mixin Functions                                              ---
---------------------------------------------------------------------------------
local MISSION_BONUS_FONT_COLOR = CreateColor(1.0, 0.82, 0.13);

GarrisonMission = {};

function GarrisonMission:OnLoadMainFrame()
	PanelTemplates_SetNumTabs(self, 2);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
end

function GarrisonMission:OnShowMainFrame()
	if (not self.followerXPTable) then
		self.followerXPTable = C_Garrison.GetFollowerXPTable(self.followerTypeID);
		local maxLevel = 0;
		for level in pairs(self.followerXPTable) do
			maxLevel = max(maxLevel, level);
		end
		self.followerMaxLevel = maxLevel;
	end

	if (not self.followerQualityTable) then
		self.followerQualityTable = C_Garrison.GetFollowerQualityTable(self.followerTypeID);
		local maxQuality = 0;
		for quality, xp in pairs(self.followerQualityTable) do
			maxQuality = max(maxQuality, quality);
		end
		self.followerMaxQuality = maxQuality;
	end
end

function GarrisonMission:GetMissionPage()
	return self.MissionTab.MissionPage;
end

function GarrisonMission:GetFollowerList()
	return self.FollowerList;
end

function GarrisonMission:GetCompleteDialog()
	return self.MissionTab.MissionList.CompleteDialog;
end


function GarrisonMission:SelectTab(id)
	PanelTemplates_SetTab(self, id);
	if (id == 1) then	-- missions
		if ( self.MissionComplete.currentIndex ) then
			self.MissionComplete:Show();
			self.MissionCompleteBackground:Show();
			self.FollowerList:Hide();
		end
		self.MissionTab:Show();
		self.FollowerTab:Hide();
		if ( self:GetMissionPage():IsShown() ) then
			self.FollowerList:UpdateFollowers();
		end
	elseif (id == 2) then	-- followers
		self.MissionComplete:Hide();
		self.MissionCompleteBackground:Hide();
		self.MissionTab:Hide();
		self.FollowerTab:Show();
		self.FollowerList:SetSortFuncs(GarrisonFollowerList_DefaultSort, GarrisonFollowerList_InitializeDefaultSort);
		if ( self.FollowerList:IsShown() ) then
			self.FollowerList:UpdateFollowers();
		else
			self.FollowerList:Show();
		end
	else	-- subclass specific tab
		self.MissionComplete:Hide();
		self.MissionCompleteBackground:Hide();
		self.MissionTab:Hide();
		self.FollowerTab:Hide();
		self.FollowerList:Hide();
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

	PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_SELECT_MISSION);
	return true;
end

function GarrisonMission:HasMission()
	return self:GetMissionPage():IsShown() and self:GetMissionPage().missionInfo ~= nil;
end

function GarrisonMission:GetFollowerBuffsForMission(missionID)
	self.followerCounters = C_Garrison.GetBuffedFollowersForMission(missionID, GarrisonFollowerOptions[self.followerTypeID].displayCounterAbilityInPlaceOfMechanic)
	self.followerTraits = C_Garrison.GetFollowersTraitsForMission(missionID);
	self.followerSpells = C_Garrison.GetFollowersSpellsForMission(missionID);
end

function GarrisonMission:SetTitle(title, ignoreTruncation)
	local missionPage = self:GetMissionPage();
	missionPage.Stage.Title:SetText(title);
	if(ignoreTruncation) then 
		GarrisonTruncationFrame_Check(missionPage.Stage.Title);
	end 
end

function GarrisonMission:GetNumTitleLines()
	local missionPage = self:GetMissionPage();
	return missionPage.Stage.Title:GetNumLines();
end

function GarrisonMission:SetEnvironmentTexture(environmentTexture)
	local missionPage = self:GetMissionPage();

	-- This is a fix for bug 496154. TODO: Add an icon for Elite difficulty that has a baked in glow.
	if (environmentTexture == 1488824 or environmentTexture == 1488825) then
		missionPage.Stage.MissionEnvIcon:SetSize(48,48);
		missionPage.Stage.MissionEnvIcon:SetPoint("LEFT", self.MissionTab.MissionPage.Stage.MissionInfo.MissionEnv, "RIGHT", -11, 0);
	else
		missionPage.Stage.MissionEnvIcon:SetSize(16,16);
		missionPage.Stage.MissionEnvIcon:SetPoint("LEFT", self.MissionTab.MissionPage.Stage.MissionInfo.MissionEnv, "RIGHT", 4, 0);
	end
end

function GarrisonMission:SetMissionIcon(typeAtlas, isRare)
	local missionPage = self:GetMissionPage();
	missionPage.MissionType:SetAtlas(typeAtlas);

	if ( isRare ) then
		missionPage.IconBG:SetVertexColor(0, 0.012, 0.291, 0.4);
	else
		missionPage.IconBG:SetVertexColor(0, 0, 0, 0.4);
	end
end

function GarrisonMission:ShowMission(missionInfo)
	local missionPage = self:GetMissionPage();
	missionPage.missionInfo = missionInfo;

	local missionDeploymentInfo =  C_Garrison.GetMissionDeploymentInfo(missionInfo.missionID);

	self:SetTitle(missionInfo.name);

	missionPage.environment = missionDeploymentInfo.environment;
	missionPage.xp = missionDeploymentInfo.xp;

	self:SetEnvironmentTexture(missionDeploymentInfo.environmentTexture)

	missionPage.Stage.MissionEnvIcon.Texture:SetTexture(missionDeploymentInfo.environmentTexture);

	local locTextureKit = missionDeploymentInfo.locTextureKit;
	if ( locTextureKit ) then
		GarrisonMissionStage_SetBack(missionPage.Stage, "_"..locTextureKit.."-Back");
		GarrisonMissionStage_SetMid(missionPage.Stage, "_"..locTextureKit.."-Mid");
		GarrisonMissionStage_SetFore(missionPage.Stage, "_"..locTextureKit.."-Fore");
	end

	self:SetMissionIcon(missionInfo.typeAtlas, missionInfo.isRare);

	-- max level
	if ( GarrisonFollowerOptions[self.followerTypeID].showILevelOnMission and missionPage.missionInfo.level == self.followerMaxLevel and missionPage.missionInfo.iLevel > 0 ) then
		missionPage.showItemLevel = true;
		missionPage.Stage.Level:SetPoint("CENTER", missionPage.Stage.Header, "TOPLEFT", 30, -28);
		missionPage.Stage.ItemLevel:Show();
		missionPage.Stage.ItemLevel:SetFormattedText(NUMBER_IN_PARENTHESES, missionPage.missionInfo.iLevel);
		missionPage.ItemLevelHitboxFrame:Show();
	else
		missionPage.showItemLevel = false;
		missionPage.Stage.Level:SetPoint("CENTER", missionPage.Stage.Header, "TOPLEFT", 30, -36);
		missionPage.Stage.ItemLevel:Hide();
		missionPage.ItemLevelHitboxFrame:Hide();
	end

	if (GarrisonFollowerOptions[self.followerTypeID].missionPageShowXPInMissionInfo) then
		-- show the XP in the upper left instead
		missionPage.Stage.MissionInfo.XP:SetFormattedText(GARRISON_MISSION_XP, missionPage.xp);
		missionPage.Stage.MissionInfo.XP:Show();
	else
		missionPage.Stage.MissionInfo.XP:Hide();
	end
	missionPage.Stage.MissionInfo.ExhaustingLabel:SetShown(missionDeploymentInfo.isExhausting);

	missionPage.Stage.MissionInfo:Layout();

	local enemies = missionDeploymentInfo.enemies;
	self:SetPartySize(missionPage, missionInfo.numFollowers, #enemies);
	self:SetEnemies(missionPage, enemies, missionInfo.numFollowers);

	if (missionPage.RewardsFrame) then
		local numRewards = #missionInfo.rewards;
		local numVisibleRewards = 0;
		for id, reward in pairs(missionInfo.rewards) do
			numVisibleRewards = numVisibleRewards + 1;
			local rewardFrame = missionPage.RewardsFrame.Rewards[numVisibleRewards];
			if ( rewardFrame ) then
				GarrisonMissionPage_SetReward(rewardFrame, reward);
			else
				-- too many rewards
				numVisibleRewards = numVisibleRewards - 1;
				break;
			end
		end
		for i = (numVisibleRewards + 1), #missionPage.RewardsFrame.Rewards do
			missionPage.RewardsFrame.Rewards[i]:Hide();
		end
		missionPage.RewardsFrame.Reward1:ClearAllPoints();
		if ( numRewards == 1 ) then
			missionPage.RewardsFrame.Reward1:SetPoint("LEFT", missionPage.RewardsFrame, 207, 0);
		else
			missionPage.RewardsFrame.Reward1:SetPoint("LEFT", missionPage.RewardsFrame, 128, 0);
		end

		-- set up all the values
		missionPage.RewardsFrame.currentChance = nil;	-- so we don't animate setting the initial chance %
		if ( missionPage.RewardsFrame.elapsedTime ) then
			GarrisonMissionPageRewardsFrame_StopUpdate(missionPage.RewardsFrame);
		end
	end

	self:UpdateMissionData(missionPage);

	self:GetFollowerBuffsForMission(missionInfo.missionID);

	missionPage:SetCounters(missionPage.Followers, missionPage.Enemies, missionPage.missionInfo.missionID);
end

function GarrisonMission:SetPartySize(missionPage, size, numEnemies)
	for i = 1, #missionPage.Followers do
		if ( i <= size ) then
			missionPage.Followers[i]:Show();
		else
			missionPage.Followers[i]:Hide();
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

function GarrisonMission:OnSetEnemy(enemyFrame, enemyInfo)

end

function GarrisonMission:OnSetEnemyMechanic(enemyFrame, mechanicFrame, mechanicID)

end

function GarrisonMission:SetEnemies(missionPage, enemies, numFollowers)
	local numVisibleEnemies = 0;
	for i=1, #enemies do
		local Frame = missionPage.Enemies[i];
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
			Mechanic.mainFrame = self;
			Mechanic.info = mechanic;
			Mechanic.Icon:SetTexture(mechanic.icon);
			Mechanic.mechanicID = mechanic.mechanicTypeID;
			Mechanic.followerTypeID = self.followerTypeID;
			self:OnSetEnemyMechanic(Frame, Mechanic, mechanic.mechanicTypeID);
			Mechanic:Show();
		end
		Frame.Mechanics[1]:SetPoint("BOTTOM", (numMechs - 1) * -22, GarrisonFollowerOptions[self.followerTypeID].missionPageMechanicYOffset);
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
		self:OnSetEnemy(Frame, enemy);
		Frame:Show();
	end

	for i = numVisibleEnemies + 1, #missionPage.Enemies do
		missionPage.Enemies[i]:Hide();
	end

	return numVisibleEnemies;
end

function GarrisonMission:UpdateMissionData(missionPage)
	local lastUpdate = missionPage.lastUpdate;
	local totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, missionEffects, xpBonus, currencyMultipliers, goldMultiplier = C_Garrison.GetPartyMissionInfo(missionPage.missionInfo.missionID);

	--Hacky fix for Bug 473557.  We don't want the color code to be directly in front of the number of days so that our
	--language rules parser can properly recognize plural/singular forms.  Previously "1 |4day:days;" becomes "|c...Time: |r|cffff19191 |4day:days;|r"
	--and the parser reads 19191 days (plural) instead of 1 day (singular).  Now "1 |4day:days;" becomes "|c...Time:|r|cffff1919 1 |4day:days;|r"
	totalTimeString = " "..totalTimeString;

	-- TIME
	if ( missionEffects.hasMissionTimeNegativeEffect ) then
		totalTimeString = RED_FONT_COLOR:WrapTextInColorCode(totalTimeString);
	elseif ( isMissionTimeImproved ) then
		totalTimeString = GREEN_FONT_COLOR_CODE..totalTimeString..FONT_COLOR_CODE_CLOSE;
	elseif ( totalTimeSeconds >= GARRISON_LONG_MISSION_TIME ) then
		totalTimeString = format(GARRISON_LONG_MISSION_TIME_FORMAT, totalTimeString);
	end
	missionPage.Stage.MissionInfo.MissionTime:SetFormattedText(GARRISON_MISSION_TIME_TOTAL, totalTimeString);

	local rewardsFrame = missionPage.RewardsFrame;
	-- SUCCESS CHANCE
	if ( rewardsFrame ) then
		-- if animating, stop it
		if ( rewardsFrame.elapsedTime ) then
			GarrisonMissionPageRewardsFrame_SetSuccessChance(rewardsFrame, rewardsFrame.endingChance);
			GarrisonMissionPageRewardsFrame_StopUpdate(rewardsFrame);
		end
		if ( rewardsFrame.currentChance and successChance > rewardsFrame.currentChance ) then
			rewardsFrame.elapsedTime = 0;
			rewardsFrame.startingChance = rewardsFrame.currentChance;
			rewardsFrame.endingChance = successChance;
			rewardsFrame:SetScript("OnUpdate", GarrisonMissionPageRewardsFrame_OnUpdate);
			rewardsFrame.ChanceGlowAnim:Play();
			if ( successChance < 100 ) then
				PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_INCREASED_SUCCESS_CHANCE);
			elseif (successChance < 200 ) then
				PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_100_SUCCESS);
			else
				PlaySound(SOUNDKIT.UI_MISSION_200_PERCENT);
			end
		else
			-- no need to animate if chance is not increasing
			if ( rewardsFrame.currentChance and successChance < rewardsFrame.currentChance and missionPage:IsShown()) then
				PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_REDUCED_SUCCESS_CHANCE);
			end
			GarrisonMissionPageRewardsFrame_SetSuccessChance(rewardsFrame, successChance);
		end
	end

	local followersWithAbilitiesGained = nil;

	-- PARTY BUFFS
	-- copy in any spillover abilities
	if (self.spilloverBuffs) then
		for _, val in ipairs(self.spilloverBuffs) do
			tinsert(partyBuffs, val);
		end
	end

	if (missionPage.BuffsFrame) then
		local buffsFrame = missionPage.BuffsFrame;
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
	end

	if ( followersWithAbilitiesGained ) then
		for followerID in pairs(followersWithAbilitiesGained) do
			local followerFrame = missionPage:GetFollowerFrameFromID(followerID);
			if ( followerFrame ) then
				followerFrame.PortraitFrame.PortraitFeedbackGlowAnim:Play();
			end
		end
	end

	-- ENVIRONMENT
	if ( missionPage.environment ) then
		local env = missionPage.environment;
		local envCheckFrame = missionPage.Stage.MissionEnvIcon;
		if ( missionEffects.environmentMechanicCountered ) then
			env = GREEN_FONT_COLOR_CODE..env..FONT_COLOR_CODE_CLOSE;
			if ( not envCheckFrame.Check:IsShown() ) then
				envCheckFrame.Check:Show();
				envCheckFrame.Anim:Stop();
				envCheckFrame.Anim:Play();
				PlaySound(SOUNDKIT.UI_GARRISON_MISSION_THREAT_COUNTERED);
			end
		else
			envCheckFrame.Check:Hide();
		end
		missionPage.Stage.MissionInfo.MissionEnv:SetFormattedText(GARRISON_MISSION_ENVIRONMENT, env);
		missionPage.Stage.MissionInfo.MissionEnv:Show();
	elseif ( missionPage.environmentMechanic ) then
		-- these mechanics are not counterable
		missionPage.Stage.MissionInfo.MissionEnv:SetFormattedText(GARRISON_MISSION_ENVIRONMENT, missionPage.environmentMechanic.name);
		missionPage.Stage.MissionInfo.MissionEnv:Show();
	else
		missionPage.Stage.MissionInfo.MissionEnv:Hide();
	end
	missionPage.Stage.MissionInfo:Layout();

	if ( rewardsFrame ) then
		rewardsFrame.MissionXP:Show();
		rewardsFrame.OvermaxItem:Hide();
		if (GarrisonFollowerOptions[self.followerTypeID].usesOvermaxMechanic) then
			local overmaxSuccess = Clamp(successChance - 100, 0, 100);
			local color;
			if missionEffects.hasBonusLootNegativeEffect then
				color = RED_FONT_COLOR;
			elseif overmaxSuccess > 0 then
				color = GREEN_FONT_COLOR;
			else
				color = HIGHLIGHT_FONT_COLOR;
			end
			rewardsFrame.MissionXP:SetFormattedText(ORDER_HALL_MISSION_BONUS_ROLL, MISSION_BONUS_FONT_COLOR:GenerateHexColor(), color:GenerateHexColor(), overmaxSuccess);

			if (#missionPage.missionInfo.overmaxRewards ~= 0) then
				local overmaxReward = missionPage.missionInfo.overmaxRewards[1];
				GarrisonMissionPage_SetReward(rewardsFrame.OvermaxItem, overmaxReward)
			else
				rewardsFrame.OvermaxItem:Hide();
				rewardsFrame.MissionXP:Hide();
			end

		else
			-- XP
			if ( xpBonus > 0 ) then
				rewardsFrame.MissionXP:SetFormattedText(GARRISON_MISSION_BASE_XP_PLUS, missionPage.xp + xpBonus, xpBonus);
				rewardsFrame.MissionXP.hasBonusBaseXP = true;
			else
				rewardsFrame.MissionXP:SetFormattedText(GARRISON_MISSION_BASE_XP, missionPage.xp);
				rewardsFrame.MissionXP.hasBonusBaseXP = false;
			end
		end
		GarrisonMissionPage_UpdateRewardQuantities(missionPage.RewardsFrame, currencyMultipliers, goldMultiplier);
	end

	self:UpdateStartButton(missionPage);
	missionPage.missionEffects = missionEffects;

	missionPage.lastUpdate = GetTime();
end

function GarrisonMission:GetStartMissionButtonFrame(missionPage)
	return missionPage.ButtonFrame;
end

function GarrisonMission:UpdateCostFrame(missionPage, baseCost, cost, owned, currencyType)
	missionPage.CostFrame:SetCurrency(currencyType);

	if ( owned < cost ) then
		missionPage.CostFrame.Cost:SetText(RED_FONT_COLOR_CODE..BreakUpLargeNumbers(cost)..FONT_COLOR_CODE_CLOSE);
	elseif (cost < baseCost) then
		missionPage.CostFrame.Cost:SetText(GREEN_FONT_COLOR_CODE..BreakUpLargeNumbers(cost)..FONT_COLOR_CODE_CLOSE);
	else
		missionPage.CostFrame.Cost:SetText(BreakUpLargeNumbers(cost));
	end

	local buttonFrame = self:GetStartMissionButtonFrame(missionPage);

	local leftAnchor = missionPage.CostFrame.leftAnchor or 50;
	missionPage.CostFrame:SetPoint("LEFT", buttonFrame, "LEFT", leftAnchor, 0);
	missionPage.CostFrame:SetPoint("RIGHT", buttonFrame, "CENTER");

	if (baseCost > 0) then
		missionPage.CostFrame:Show();
		missionPage.StartMissionButton:ClearAllPoints();
		missionPage.StartMissionButton:SetPoint("RIGHT", buttonFrame, "RIGHT", -50, 1);
	else
		missionPage.CostFrame:Hide();
		missionPage.StartMissionButton:ClearAllPoints();
		missionPage.StartMissionButton:SetPoint("CENTER", buttonFrame, "CENTER", 0, 1);
	end
end

function GarrisonMission:UpdateStartButton(missionPage)
	local missionInfo = missionPage.missionInfo;
	if ( not missionPage.missionInfo or not missionPage:IsVisible() ) then
		return;
	end

	local disableError;

	if ( not C_Garrison.AllowMissionStartAboveSoftCap(self.followerTypeID) and C_Garrison.IsAboveFollowerSoftCap(self.followerTypeID) ) then
		disableError = GARRISON_MAX_FOLLOWERS_MISSION_TOOLTIP;
	end

	local baseCost, cost = C_Garrison.GetMissionCost(missionPage.missionInfo.missionID);
	if( cost ~= nil) then
		missionInfo.cost = cost;
	end

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(missionInfo.costCurrencyTypesID);
	if ( currencyInfo ~= nil) then
		local amountOwned = currencyInfo.quantity;
		if ( not disableError and amountOwned < missionInfo.cost ) then
			disableError = GarrisonFollowerOptions[self.followerTypeID].strings.NOT_ENOUGH_MATERIALS;
		end

		self:UpdateCostFrame(missionPage, baseCost, cost, amountOwned, missionInfo.costCurrencyTypesID);
	end

	-- specific required champions
	if ( not disableError ) then
		local requiredChampions = missionPage.missionInfo.requiredChampions;
		if (requiredChampions) then
			local count = 0;
		    for i, followerFrame in ipairs(missionPage.Followers) do
			    if ( followerFrame.info ) then
					for i, required in ipairs(requiredChampions) do
				        if (followerFrame.info.garrFollowerID == required) then
					        count = count + 1;
				        end
					end
			    end
		    end
			if (count < #requiredChampions) then
				local errorStr;
				if (#requiredChampions == 1) then
					errorStr = ORDER_HALL_MISSION_REQUIRED_CHAMPION;
				else
					errorStr = ORDER_HALL_MISSION_REQUIRED_CHAMPIONS;
				end

				local str = "";
				for i, followerID in ipairs(requiredChampions) do
					if (i ~= 1) then
						str = str..", ";
					end
					local requiredInfo = C_Garrison.GetFollowerNameByID(followerID);
					str = str..requiredInfo;
				end

				disableError = string.format(errorStr, str);
			end
		end
	end

	-- required number of champions
	if ( not disableError ) then
		local requiredChampionCount = missionPage.missionInfo.requiredChampionCount;

		local numChampions = 0;
		if self.GetNumMissionFollowers then
			numChampions = self:GetNumMissionFollowers();
		else
			local followers = missionPage.Followers;
			for followerIndex = 1, #followers do
				local followerFrame = followers[followerIndex];
				if ( followerFrame.info ) then
					if (not followerFrame.info.isTroop and not followerFrame.info.isAutoTroop) then
						numChampions = numChampions + 1;
					end
				end
			end
		end

		if ( numChampions < requiredChampionCount ) then
			disableError = GarrisonFollowerOptions[self.followerTypeID].partyNotFullText;
		end
	end

	if ( not C_Garrison.AreMissionFollowerRequirementsMet(missionPage.missionInfo.missionID)) then
		local isOnlyOne, followerRequiredID = C_Garrison.ShowFollowerNameInErrorMessage(missionPage.missionInfo.missionID)
		if (isOnlyOne) then
			disableError = string.format(GARRISON_MISSION_REQUIRED_SINGLE_FOLLOWER_NOT_FOUND, C_Garrison.GetFollowerName(followerRequiredID));
		else
			disableError = GARRISON_MISSION_REQUIRED_FOLLOWERS_NOT_FOUND;
		end
	end


	if ( not disableError) then
		local successChance = C_Garrison.GetMissionSuccessChance(missionPage.missionInfo.missionID);
		local requiredSuccessChance = missionPage.missionInfo.requiredSuccessChance;
		if (successChance < requiredSuccessChance ) then
			disableError = GARRISON_MISSION_REQUIRED_CHANCE_NOT_MET;
		end
	end

	if (not disableError) then
		disableError = self:GetSystemSpecificStartMissionFailureMessage();
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

function GarrisonMission:GetSystemSpecificStartMissionFailureMessage()
end

function GarrisonMission:CloseMission()
	self:GetMissionPage():Hide();
	self:ClearParty();
	if (self.MissionTab.MissionList) then
		self.MissionTab.MissionList:Show();
	end
	self.followerCounters = nil;
	self:GetMissionPage().missionInfo = nil;
	self:ClearMouse();
end

function GarrisonMission:ClearParty()
	local missionPage = self:GetMissionPage();
	for i = 1, #missionPage.Followers do
		local followerFrame = missionPage.Followers[i];
		self:RemoveFollowerFromMission(followerFrame);
	end
end

function GarrisonMission:OnClickStartMissionButton()
	local missionID = self:GetMissionPage().missionInfo.missionID;

	if (not missionID) then
		return false;
	end
	C_Garrison.StartMission(missionID);
	self:UpdateMissions();
	self.FollowerList:UpdateFollowers();
	self:CloseMission();
	return true;
end

function GarrisonMission:AssignFollowerToMission(frame, info)
	if (frame.info) then
		self:RemoveFollowerFromMission(frame);
	end

	local missionPage = self:GetMissionPage();

	-- frame.info needs to be set for AddFollowerToMission()
	frame.info = info;
	if ( not C_Garrison.AddFollowerToMission(missionPage.missionInfo.missionID, info.followerID, frame.boardIndex) ) then
		frame.info = nil;
		return false;
	end

	if (missionPage.Followers and missionPage.Enemies) then
		missionPage:SetCounters(missionPage.Followers, missionPage.Enemies, missionPage.missionInfo.missionID);
	end
	return true;
end

function GarrisonMission:RemoveFollowerFromMission(frame, updateValues)
	local followerID = frame.info and frame.info.followerID or nil;

	frame.info = nil;
	if frame.Counters then
		for i = 1, #frame.Counters do
			frame.Counters[i]:Hide();
		end
	end

	self:GetMissionPage():UpdateFollowerDurability(frame);

	local missionPage = self:GetMissionPage();
	if (followerID) then
		C_Garrison.RemoveFollowerFromMission(missionPage.missionInfo.missionID, followerID);
		if (updateValues) then
			PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_UNASSIGN_FOLLOWER);
		end
	end

	if (missionPage.Followers and missionPage.Enemies) then
		missionPage:SetCounters(missionPage.Followers, missionPage.Enemies, missionPage.missionInfo.missionID);
	end
end

function GarrisonMission:UpdateMissionParty(followers, counterTemplate)
	self.spilloverBuffs = { };

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
				local maxCountersToDisplay = GarrisonFollowerOptions[followerInfo.followerTypeID].missionPageMaxCountersInFollowerFrame;

				for i = 1, min(#counters, maxCountersToDisplay) do
					numCounters = numCounters + 1;
					if (not followerFrame.Counters[i]) then
						followerFrame.Counters[i] = CreateFrame("Frame", nil, followerFrame, counterTemplate);
						followerFrame.Counters[i]:SetPoint("LEFT", followerFrame.Counters[i-1], "RIGHT", 16, 0);
					end
					local Counter = followerFrame.Counters[i];
					Counter.info = counters[i];
					Counter.info.showCounters = true;
					if (GarrisonFollowerOptions[followerInfo.followerTypeID].displayCounterAbilityInPlaceOfMechanic and counters[i].counterID) then
						local abilityInfo = C_Garrison.GetFollowerAbilityInfo(counters[i].counterID);
						Counter.Icon:SetTexture(abilityInfo.icon);
						Counter.Border:SetShown(ShouldShowFollowerAbilityBorder(followerInfo.followerTypeID, abilityInfo));
					else
						Counter.Icon:SetTexture(counters[i].icon);
					end
					Counter.tooltip = counters[i].name;
					Counter:Show();

					Counter.followerTypeID = followerInfo.followerTypeID;
				end
				for i = maxCountersToDisplay + 1, #counters do
					if (GarrisonFollowerOptions[followerInfo.followerTypeID].displayCounterAbilityInPlaceOfMechanic and counters[i].counterID) then
						tinsert(self.spilloverBuffs, followerFrame.info.followerID);
						tinsert(self.spilloverBuffs, counters[i].counterID);
					end
				end
			end
			for i = numCounters + 1, #followerFrame.Counters do
				followerFrame.Counters[i]:Hide();
			end

			self:GetMissionPage():UpdateFollowerDurability(followerFrame);
		end
	end
end

function GarrisonMission:GetPlacerFrame()
	return GarrisonFollowerPlacer;
end

function GarrisonMission:OnClickFollowerPlacerFrame(button, info)
	if ( button == "LeftButton" ) then
		for i = 1, #self:GetMissionPage().Followers do
			local followerFrame = self:GetMissionPage().Followers[i];
			if ( followerFrame:IsShown() and followerFrame:IsMouseOver() ) then
				self:AssignFollowerToMission(followerFrame, info);
			end
		end
	end
	self:ClearMouse();
end

function GarrisonMission:OnDragStartFollowerButton(placer, frame, yOffset)
	if ( not self:GetMissionPage():IsVisible() ) then
		return;
	end
	if ( frame.info.status or not frame.info.isCollected ) then
		return;
	end

	self:SetPlacerFrame(placer, frame.info, yOffset);
end

function GarrisonMission:OnDragStopFollowerButton(placer)
	if (placer:IsShown()) then
		GarrisonShowFollowerPlacerFrame(self, placer.info);
	end
end

function GarrisonMission:SetPlacerFrame(placer, info, yOffset)
	self:SetFollowerPortrait(placer, info, false, false);
	placer.info = info;
	self:LockPlacerToMouse(placer, yOffset);
end

function GarrisonMission:LockPlacerToMouse(placer, yOffset)
 	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	placer.yOffset = yOffset or 25;
	placer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + placer.yOffset);
	placer:Show();
	placer:SetScript("OnUpdate", self:GetPlacerUpdate());
end

function GarrisonMission:GetPlacerUpdate()
	return GarrisonFollowerPlacer_OnUpdate;
end

function GarrisonMission:OnDragStartMissionFollower(placer, frame, yOffset)
	if ( not frame.info ) then
		return;
	end
	self:SetPlacerFrame(placer, frame.info, yOffset);
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
		local info = frame.GetInfo and frame:GetInfo() or frame.info;
		if ( info ) then
			self:RemoveFollowerFromMission(frame, true);
		else
			GarrisonMissionPage_OnClick(self:GetMissionPage(), button);
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

	self.MissionComplete.completeMissions = C_Garrison.GetCompleteMissions(self.followerTypeID);
	self.MissionTab.MissionList:UpdateCombatAllyMission();
	if ( #self.MissionComplete.completeMissions > 0 ) then
		if ( self:IsShown() ) then
			if ( GarrisonFollowerOptions[self.followerTypeID].showCompleteDialog ) then
				self:GetCompleteDialog().BorderFrame.Model.Summary:SetFormattedText(GARRISON_NUM_COMPLETED_MISSIONS, #self.MissionComplete.completeMissions);
				self:GetCompleteDialog():Show();
				self:CheckTutorials();
				self:GetCompleteDialog().BorderFrame.ViewButton:SetEnabled(true);
				self:GetCompleteDialog().BorderFrame.LoadingFrame:Hide();
			end
			return true;
		end
	end

	return false;
end

function GarrisonMission:OnClickViewCompletedMissionsButton()
	if ( not MissionCompletePreload_IsReady() ) then
		self:GetCompleteDialog().BorderFrame.ViewButton:SetEnabled(false);
		self:GetCompleteDialog().BorderFrame.LoadingFrame:Show();
		MissionCompletePreload_StartTimeout(GARRISON_MODEL_PRELOAD_TIME, self.OnClickViewCompletedMissionsButton, self);
		return;
	end
	PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_VIEW_MISSION_REPORT);

	self:GetCompleteDialog():Hide();
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
	local missionCompleteFrame = self.MissionComplete;
	missionCompleteFrame.NextMissionButton:Enable();
	if (not missionList or #missionList == 0 or index == 0) then
		self:CloseMissionComplete();
		return false;
	end
	if (index > #missionList) then
		missionCompleteFrame.completeMissions = nil;
		self:CloseMissionComplete();
		return false;
	end
	local mission = missionList[index];
	missionCompleteFrame.currentMission = mission;

	local stage = missionCompleteFrame.Stage;
	stage.FollowersFrame:Hide();
	stage.EncountersFrame.FadeOut:Stop();
	stage.EncountersFrame:Show();

	for _, cluster in ipairs(stage.ModelCluster) do
		for _, model in next, cluster.Model do
			model.FadeIn:Stop();
			model:StopPan();
		end
		cluster.FadeOut:Stop();
		cluster:SetAlpha(1);
	end

	stage.MissionInfo.Title:SetText(mission.name);
	GarrisonTruncationFrame_Check(stage.MissionInfo.Title);

	missionCompleteFrame.LoadingFrame:Hide();

	missionCompleteFrame:StopAnims();
	missionCompleteFrame.rollCompleted = false;

	-- rare
	if ( mission.isRare ) then
		stage.MissionInfo.IconBG:SetVertexColor(0, 0.012, 0.291, 0.4);
	else
		stage.MissionInfo.IconBG:SetVertexColor(0, 0, 0, 0.4);
	end
	local missionDeploymentInfo = C_Garrison.GetMissionDeploymentInfo(mission.missionID);
	local enemies = missionDeploymentInfo.enemies;

	if (GarrisonFollowerOptions[self.followerTypeID].showSingleMissionCompleteAnimation) then
		enemies = { enemies[1] };
	end
	self:SortEnemies(enemies);

	stage.MissionInfo.MissionType:SetAtlas(mission.typeAtlas, true);
	stage.EncountersFrame.enemies = enemies;
	stage.EncountersFrame.uncounteredMechanics = C_Garrison.GetMissionUncounteredMechanics(mission.missionID);

	local encounters = C_Garrison.GetMissionCompleteEncounters(mission.missionID);
	if (GarrisonFollowerOptions[self.followerTypeID].showSingleMissionCompleteAnimation) then
		encounters = { encounters[1] };
	end
	self:SortEnemies(encounters);
	self:SetMissionCompleteNumEncounters(stage.EncountersFrame, #encounters);
	for i=1, #encounters do
		local encounter = stage.EncountersFrame.Encounters[i];
		self:SetEnemyName(encounter, encounters[i].name);
		encounter.displayID = encounters[i].displayID;
		self:SetEnemyPortrait(encounter, encounters[i], encounter.Elite, #enemies[i].mechanics);
	end

	missionCompleteFrame:KillFollowerXPAnims();
	missionCompleteFrame.pendingXPAwards = { };
	missionCompleteFrame.animInfo = {};
	stage.followers = {};
	local encounterIndex = 1;
	for missionFollowerIndex=1, #mission.followers do
		local followerFrame = stage.FollowersFrame.Followers[missionFollowerIndex];
		if (followerFrame) then
			local followerMissionCompleteInfo = C_Garrison.GetFollowerMissionCompleteInfo(mission.followers[missionFollowerIndex]);

			local displayIDs = followerMissionCompleteInfo.displayIDs;
			local height = followerMissionCompleteInfo.height;
			local scale = followerMissionCompleteInfo.scale;
			local isTroop = followerMissionCompleteInfo.isTroop;

			followerFrame.followerID = mission.followers[missionFollowerIndex];
			missionCompleteFrame:SetFollowerData(followerFrame, followerMissionCompleteInfo.name, followerMissionCompleteInfo.className, followerMissionCompleteInfo.classAtlas, followerMissionCompleteInfo.portraitIconID, followerMissionCompleteInfo.textureKit);
			local followerInfo = C_Garrison.GetFollowerInfo(followerFrame.followerID);
			missionCompleteFrame:SetFollowerLevel(followerFrame, followerInfo);

			stage.followers[missionFollowerIndex] = {
											displayIDs = displayIDs,
											height = height,
											scale = scale,
											followerID = mission.followers[missionFollowerIndex],
											isTroop = isTroop,
											durability = followerInfo.durability,
											maxDurability = followerInfo.maxDurability };

			if (not isTroop) then
				if (encounters[encounterIndex]) then --cannot have more animations than encounters
					missionCompleteFrame.animInfo[encounterIndex] = {
											displayID = displayIDs[1] and displayIDs[1].id,	-- for the fights we only show the first display ID
											showWeapon = displayIDs[1] and displayIDs[1].showWeapon,
											height = height,
											scale = scale * (displayIDs[1].followerPageScale or 1),
											movementType = followerMissionCompleteInfo.movementType,
											impactDelay = followerMissionCompleteInfo.impactDelay,
											castID = followerMissionCompleteInfo.castID,
											castSoundID = followerMissionCompleteInfo.castSoundID,
											impactID = followerMissionCompleteInfo.impactID,
											impactSoundID = followerMissionCompleteInfo.impactSoundID,
											targetImpactID = followerMissionCompleteInfo.targetImpactID,
											targetImpactSoundID = followerMissionCompleteInfo.targetImpactSoundID,
											enemyDisplayID = encounters[encounterIndex].displayID,
											enemyScale = encounters[encounterIndex].scale,
											enemyHeight = encounters[encounterIndex].height,
											followerID = mission.followers[missionFollowerIndex],
										}
					encounterIndex = encounterIndex + 1;
				end
			end
		end
	end
	-- if there are fewer followers than encounters, cycle through followers to match up against encounters
	for i = encounterIndex, #encounters do
		local index = mod(i, encounterIndex) + 1;
		local animInfo = missionCompleteFrame.animInfo[index];
		missionCompleteFrame.animInfo[i] = {
								displayID = animInfo.displayID,
								showWeapon = animInfo.showWeapon,
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

	local currencyMultipliers, goldMultiplier = select(8, C_Garrison.GetPartyMissionInfo(missionCompleteFrame.currentMission.missionID));
	missionCompleteFrame.currentMission.currencyMultipliers = currencyMultipliers;
	missionCompleteFrame.currentMission.goldMultiplier = goldMultiplier;

	if (missionCompleteFrame.BonusRewards) then
		missionCompleteFrame.BonusRewards.ChestModel.OpenAnim:Stop();
		missionCompleteFrame.BonusRewards.ChestModel.LockBurstAnim:Stop();
		missionCompleteFrame.BonusRewards.ChestModel:SetAlpha(1);
		for i = 1, #missionCompleteFrame.BonusRewards.Rewards do
			missionCompleteFrame.BonusRewards.Rewards[i]:Hide();
		end
		missionCompleteFrame.BonusRewards.ChestModel.LockBurstAnim:Stop();
		missionCompleteFrame.ChanceFrame.SuccessChanceInAnim:Stop();
		missionCompleteFrame.ChanceFrame.ResultAnim:Stop();
		missionCompleteFrame.BonusRewards.timerMissionID = nil;
		if (mission.completed) then
			-- if the mission is in this state, it's a success. We get here if the player gets to the rewards screen, and then doesn't click the
			-- chest and closes the window and then re-opens the mission complete screen.
			missionCompleteFrame.currentMission.succeeded = true;
			missionCompleteFrame:SetScript("OnUpdate", nil);

			stage.EncountersFrame:Hide();
			missionCompleteFrame.BonusRewards.Saturated:Show();
			missionCompleteFrame.BonusRewards.ChestModel.Lock:Hide();
			missionCompleteFrame.BonusRewards.ChestModel:SetAnimation(0, 0);
			missionCompleteFrame.BonusRewards.ChestModel.ClickFrame:Show();
			missionCompleteFrame.ChanceFrame.ChanceText:SetAlpha(0);
			missionCompleteFrame.ChanceFrame.ResultText:SetText(GARRISON_MISSION_SUCCESS);
			missionCompleteFrame.ChanceFrame.ResultText:SetTextColor(0.1, 1, 0.1);
			missionCompleteFrame.ChanceFrame.ResultText:SetAlpha(1);

			missionCompleteFrame.ChanceFrame.Banner:SetAlpha(1);
			missionCompleteFrame.ChanceFrame.Banner:SetWidth(GARRISON_MISSION_COMPLETE_BANNER_WIDTH);

			-- don't fade in any troops that are exhausted at this point, because we've already done their fade out animation the last time this rewards pane was shown.
			missionCompleteFrame:AnimFollowersIn(nil, true);
		else
			stage.ModelMiddle:Hide();
			stage.ModelRight:Hide();
			stage.ModelLeft:Hide();
			missionCompleteFrame.BonusRewards.Saturated:Hide();
			missionCompleteFrame.BonusRewards.ChestModel.Lock:SetAlpha(1);
			missionCompleteFrame.BonusRewards.ChestModel.Lock:Show();
			missionCompleteFrame.BonusRewards.ChestModel:SetAnimation(148);
			missionCompleteFrame.BonusRewards.ChestModel.ClickFrame:Hide();
			missionCompleteFrame.ChanceFrame.ChanceText:SetAlpha(1);
			missionCompleteFrame.ChanceFrame.ChanceText:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE, C_Garrison.GetMissionSuccessChance(mission.missionID));
			missionCompleteFrame.ChanceFrame.ResultText:SetAlpha(0);
			missionCompleteFrame.ChanceFrame.Banner:SetAlpha(0);
			missionCompleteFrame.ChanceFrame.Banner:SetWidth(200);
			missionCompleteFrame.ChanceFrame.SuccessChanceInAnim:Play();
			PlaySound(SOUNDKIT.UI_GARRISON_MISSION_COMPLETE_ENCOUNTER_CHANCE);
			C_Garrison.MarkMissionComplete(mission.missionID);
		end
	end
	missionCompleteFrame.NextMissionButton:Disable();
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

-- overridden
function GarrisonMission:CheckTutorials()
end

---------------------------------------------------------------------------------
--- Garrison Mission Reward Effects Functions                                 ---
---------------------------------------------------------------------------------

local function OnGarrisonMissionRewardReleased(framePool, frame)
	frame.id = nil;
	frame.Icon:Show();
	frame.BG:Show();
	frame.Name:Show();

	frame:Hide();
	frame:ClearAllPoints();
end

---------------------------------------------------------------------------------
--- Garrison Mission Complete Mixin Functions                                 ---
---------------------------------------------------------------------------------

GarrisonMissionComplete = {};

function GarrisonMissionComplete:OnLoad()
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
	self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE");
	self.pendingXPAwards = { };
	self:SetFrameLevel(self:GetParent().MissionCompleteBackground:GetFrameLevel() + 2);
	self:SetAnimationControl();

	self.missionRewardEffectsPool = CreateFramePool("FRAME", self.BonusRewards, "GarrisonMissionRewardEffectsTemplate", OnGarrisonMissionRewardReleased);
	if (self.BonusRewards) then
		self.BonusRewards.Rewards = {};
	end
end

function GarrisonMissionComplete:OnEvent(event, ...)
	local mainFrame = self:GetParent();
	if (event == "GARRISON_FOLLOWER_XP_CHANGED" and self:IsVisible()) then
		local followerTypeID = ...;
		if (followerTypeID == mainFrame.followerTypeID) then
			self:AnimFollowerXP(select(2, ...));
		end
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


function GarrisonMissionComplete:OnMissionCompleteResponse(missionID, canComplete, succeeded, overmaxSucceeded, followerDeaths)
	if ( self.currentMission and self.currentMission.missionID == missionID ) then
		self.NextMissionButton:Enable();
		if ( canComplete ) then
			self.currentMission.succeeded = succeeded;
			self.currentMission.overmaxSucceeded = overmaxSucceeded;
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
	self.missionRewardEffectsPool:ReleaseAll();
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
	[Enum.GarrisonFollowerType.FollowerType_6_0] = {
	    [1] = { ["ModelMiddle"] = { dist = 0, facing = 0.1, followerIndex = 1 },
			    ["ModelLeft"] = { hidden = true },
			    ["ModelRight"] = { hidden = true },
	    },
	    [2] = { ["ModelMiddle"] = { hidden = true },
			    ["ModelLeft"] = { dist = 0.2, facing = -0.2, followerIndex = 1 },
			    ["ModelRight"] = { dist = -0.2, facing = 0.2, followerIndex = 2 },
	    },
	    [3] = { ["ModelMiddle"] = { dist = 0, facing = 0.1, followerIndex = 2 },
			    ["ModelLeft"] = { dist = 0.25, facing = -0.3, followerIndex = 1 },
			    ["ModelRight"] = { dist = -0.275, facing = 0.3, followerIndex = 3 },
	    },
	},
	[Enum.GarrisonFollowerType.FollowerType_7_0] = {
	    [1] = { ["ModelMiddle"] = { dist = 0, facing = 0, followerIndex = 1 },
			    ["ModelLeft"] = { hidden = true },
			    ["ModelRight"] = { hidden = true },
	    },
	    [2] = { ["ModelMiddle"] = { hidden = true },
			    ["ModelLeft"] = { dist = 0.2, facing = 0, followerIndex = 1 },
			    ["ModelRight"] = { dist = -0.2, facing = 0, followerIndex = 2 },
	    },
	    [3] = { ["ModelMiddle"] = { dist = 0, facing = 0, followerIndex = 2 },
			    ["ModelLeft"] = { dist = 0.27, facing = 0, followerIndex = 1 },
			    ["ModelRight"] = { dist = -0.27, facing = 0, followerIndex = 3 },
	    },
	}
};
ENDINGS[Enum.GarrisonFollowerType.FollowerType_8_0] = ENDINGS[Enum.GarrisonFollowerType.FollowerType_7_0];

local POSITION_DATA = {
	[Enum.GarrisonFollowerType.FollowerType_6_0] = {
	    [1] = {
		    [1] = { scale=1.0,		facing=0,		x=0,	y=0		}
	    },
	},
	[Enum.GarrisonFollowerType.FollowerType_7_0] = {
	    [1] = {
		    [1] = { scale=1.0,		facing=0,		x=-0.02,	y=0		}
	    },
	    [2] = {
		    [1] = { scale=1.0,		facing=0,		x=0.025,	y=0		},
		    [2] = { scale=1.0/0.95,	facing=0.4,		x=-0.055,	y=0		},
	    },
	    [3] = {
		    [1] = { scale=1.0/0.8,	facing=0,		x=-0.02,	y=0,	},
		    [2] = { scale=1.0/0.7,	facing=-0.4,	x=.03,	y=-.07,	},
		    [3] = { scale=1.0/0.6,	facing=0.4,	    x=-.07,	y=-0.12,	},
	    },
	    [4] = {
		    [1] = { scale=1.0/0.8,	facing=0,		x=-0.02,	y=0,	},
		    [2] = { scale=1.0/0.7,	facing=-0.4,	x=.03,	y=-.07,	},
		    [3] = { scale=1.0/0.6,	facing=0.4,	    x=-.07,	y=-0.12,	},
		    [4] = { scale=1.0/0.5,	facing=-0.5,	x=0,	y=-0.2,	},
	    },
	    [5] = {
		    [1] = { scale=1.0/0.8,	facing=0,		x=-0.02,	y=0,	},
		    [2] = { scale=1.0/0.7,	facing=-0.4,	x=.03,	y=-.07,	},
		    [3] = { scale=1.0/0.6,	facing=0.4,	    x=-.07,	y=-0.12,	},
		    [4] = { scale=1.0/0.5,	facing=-0.5,	x=0,	y=-0.2,	},
		    [5] = { scale=1.0/0.35,	facing=0.5,		x=-0.04,	y=-0.26,	},
	    }
	}
};
POSITION_DATA[Enum.GarrisonFollowerType.FollowerType_8_0] = POSITION_DATA[Enum.GarrisonFollowerType.FollowerType_7_0];

function GarrisonMissionComplete:SetupEnding(numFollowers, hideExhaustedTroopModels)
	self.Stage.ModelRight:SetFacingLeft(false);
	local followerType = self:GetParent().followerTypeID;
	for model, data in pairs(ENDINGS[followerType][numFollowers]) do
		local modelClusterFrame = self.Stage[model];
		if ( data.hidden ) then
			modelClusterFrame:Hide();
		else
			local followerInfo = self.Stage.followers[data.followerIndex];
			if (hideExhaustedTroopModels and followerInfo.isTroop and followerInfo.durability and followerInfo.durability <= 0) then
				modelClusterFrame:SetAlpha(0);
			end
			local pos = POSITION_DATA[followerType][#followerInfo.displayIDs];
			for i = 1, #followerInfo.displayIDs do
				local modelFrame = modelClusterFrame.Model[i];
				modelFrame:SetAlpha(1);
				local displayInfo = followerInfo.displayIDs[i];
				GarrisonMission_SetFollowerModel(modelFrame, followerInfo.followerID, displayInfo and displayInfo.id, displayInfo and displayInfo.showWeapon);
				modelFrame:InitializeCamera((followerInfo.scale or 1) * (displayInfo and displayInfo.followerPageScale or 1) * pos[i].scale);
				modelFrame:SetHeightFactor(followerInfo.height + pos[i].y);
				modelFrame:SetTargetDistance(data.dist + pos[i].x);
				modelFrame:SetFacing(data.facing + pos[i].facing);
				modelFrame:Show();
			end
			for i = #followerInfo.displayIDs + 1, #modelClusterFrame.Model do
				modelClusterFrame.Model[i]:Hide();
			end
			modelClusterFrame:Show();
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

	self.missionRewardEffectsPool:ReleaseAll();

	local numRewards = #currentMission.rewards;
	local index = 1;
	local prevRewardFrame;
	for id, reward in pairs(currentMission.rewards) do
		local rewardFrame = self.missionRewardEffectsPool:Acquire();
		if (prevRewardFrame) then
			rewardFrame:SetPoint("RIGHT", prevRewardFrame, "LEFT", -9, 0);
		else
			if (numRewards == 1) then
				rewardFrame:SetPoint("CENTER", bonusRewards, "CENTER", 0, 0);
			elseif (numRewards == 2) then
				rewardFrame:SetPoint("LEFT", bonusRewards, "CENTER", 5, 0);
			else
				rewardFrame:SetPoint("RIGHT", bonusRewards, "RIGHT", -18, 0);
			end
		end
		GarrisonMissionPage_SetReward(rewardFrame, reward);
		if ( not self.skipAnimations ) then
			rewardFrame.Anim:Play();
		end
		prevRewardFrame = rewardFrame;
	end
	GarrisonMissionPage_UpdateRewardQuantities(bonusRewards, currentMission.currencyMultipliers, currentMission.goldMultiplier);
end


---------------------------------------------------------------------------------
--- Garrison Mission Complete Animation Mixin Functions                       ---
---------------------------------------------------------------------------------

function GarrisonMissionComplete:SetEncounterModels(index)
	local modelLeftCluster = self.Stage.ModelLeft;
	for i, model in ipairs(modelLeftCluster.Model) do
		model:Hide();
		model:ClearModel();
	end
	local modelLeft = modelLeftCluster.Model[1];
	modelLeft:SetAlpha(0);
	modelLeft:Show();
	modelLeftCluster:Show();

	local modelRightCluster = self.Stage.ModelRight;
	for i, model in ipairs(modelRightCluster.Model) do
		model:Hide();
		model:ClearModel();
	end
	local modelRight = modelRightCluster.Model[1];

	modelRight:SetAlpha(0);
	modelRight:Show();
	modelRightCluster:Show();

	if ( self.animInfo and index and self.animInfo[index] ) then
		local currentAnim = self.animInfo[index];
		modelLeft.state = "loading";
		GarrisonMission_SetFollowerModel(modelLeft, currentAnim.followerID, currentAnim.displayID, currentAnim.showWeapon);
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
		Mechanic.followerTypeID = Mechanic.mainFrame.followerTypeID;
		Mechanic.info = mechanic;
		Mechanic.Icon:SetTexture(mechanic.icon);
		Mechanic.mechanicID = mechanic.mechanicTypeID;
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
	-- Check whether animations are loaded for the fight scene. Only the first displayID (first model) is used in fight scenes.
	self.animNumModelHolds = 0;
	local modelLeft = self.Stage.ModelLeft;
	if ( modelLeft.Model[1].state == "loading" ) then
		self.animNumModelHolds = self.animNumModelHolds + 1;
	end
	local modelRight = self.Stage.ModelRight;
	if ( modelRight.Model[1].state == "loading" ) then
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
	local modelLeft = self.Stage.ModelLeft.Model[1];
	local modelRight = self.Stage.ModelRight.Model[1];

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
		PlaySound(SOUNDKIT.UI_GARRISON_MISSION_ENCOUNTER_ANIMATION_GENERIC);
		if ( currentAnim.castSoundID ) then
			PlaySound(currentAnim.castSoundID);
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
		PlaySound(currentAnim.impactSoundID);
		entry.duration = 0.9 - currentAnim.impactDelay;
	elseif ( currentAnim.playTargetImpactSound ) then
		PlaySound(currentAnim.targetImpactSoundID);
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
		PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_MISSION_SUCCESS_STINGER);
	else
		self.ChanceFrame.ResultText:SetText(GARRISON_MISSION_FAILED);
		self.ChanceFrame.ResultText:SetTextColor(1, 0.1, 0.1);
		self.ChanceFrame.ResultAnim:Play();
		self.NextMissionButton:Enable();
		PlaySound(SOUNDKIT.UI_GARRISON_MISSION_COMPLETE_MISSION_FAIL_STINGER);
	end
end

function GarrisonMissionComplete:AnimLockBurst(entry)
	if ( self.currentMission.succeeded ) then
		self.BonusRewards.ChestModel.LockBurstAnim:Play();
		PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_CHEST_UNLOCK);
		if ( C_Garrison.CanOpenMissionChest(self.currentMission.missionID) ) then
			self.BonusRewards.ChestModel.ClickFrame:Show();
		end
	else
		self.NextMissionButton:Enable();
	end
end

function GarrisonMissionComplete:AnimCleanUp(entry)
	local models = self.Stage.ModelCluster;
	for _, cluster in ipairs(self.Stage.ModelCluster) do
		for _, model in next, cluster.Model do
			model:StopPan();
			model:ClearModel();
		end
	end
end

function GarrisonMissionComplete:AnimXP(entry)
	for i = 1, #self.currentMission.followers do
		self:CheckAndShowFollowerXP(self.currentMission.followers[i]);
	end
end

function GarrisonMissionComplete:AnimCheerAndTroopDeath(entry)
	for i = 1, #self.currentMission.followers do
		self:AnimFollowerCheerAndTroopDeath(self.currentMission.followers[i]);
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
						PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_MISSION_SUCCESS_STINGER);
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
						PlaySound(SOUNDKIT.UI_GARRISON_MISSION_COMPLETE_MISSION_FAIL_STINGER);
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

	local animIndex = self:FindAnimIndexFor(self.AnimFollowersIn);
	for i = 1, #mission.followers do
		local followerFrame = self.Stage.FollowersFrame.Followers[i];
		if ( followerFrame.followerID == followerID ) then
			-- play anim now if we finished animating followers in
			if ( self.animIndex and self.animIndex > animIndex and (not followerFrame.activeAnims or followerFrame.activeAnims == 0) ) then
				if ( xpAward > 0 ) then
					local followerInfo = C_Garrison.GetFollowerInfo(followerID);
					followerInfo.level = oldLevel;
					followerInfo.quality = oldQuality;
					followerInfo.xp = oldXP;
					followerInfo.levelXP = self:GetFollowerNextLevelXP(oldLevel, oldQuality);
					self:SetFollowerLevel(followerFrame, followerInfo);
					self:AwardFollowerXP(followerFrame, xpAward);
				else
					-- lost xp, no anim
					local followerInfo = C_Garrison.GetFollowerInfo(followerID);
					self:SetFollowerLevel(followerFrame, followerInfo);
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

function GarrisonMissionComplete:AnimFollowerCheerAndTroopDeath(followerID)
	local missionList = self.completeMissions;
	local missionIndex = self.currentIndex;
	local mission = missionList[missionIndex];

	if (not mission) then
		return;
	end

	if (mission.succeeded) then
		PlaySound(SOUNDKIT.UI_MISSION_SUCCESS_CHEERS);
	end

	for i = 1, #mission.followers do
		local followerFrame = self.Stage.FollowersFrame.Followers[i];
		if ( followerFrame.followerID == followerID ) then

			local shouldFadeOut = false;
			local shouldCheer = mission.succeeded;

			local followerInfo = C_Garrison.GetFollowerInfo(followerID);
			if (followerInfo) then
				if (followerInfo.isTroop and followerInfo.durability) then
					if (followerInfo.durability <= 0) then
						shouldFadeOut = true;
						shouldCheer = false;
					else
						self:SetFollowerLevel(followerFrame, followerInfo);
					end
					followerFrame.DurabilityFrame:SetDurability(followerInfo.durability, followerInfo.maxDurability);
				end
			else
				-- follower has been deleted;
				shouldFadeOut = true;
				shouldCheer = false;
				if (followerFrame.DurabilityFrame:IsShown()) then
					local durability, maxDurability = followerFrame.DurabilityFrame:GetDurability();
					followerFrame.DurabilityFrame:SetDurability(0, maxDurability);
				end
			end

			for _, cluster in ipairs(self.Stage.ModelCluster) do
				if (cluster:IsShown()) then
					if (cluster:GetFollowerID() == followerFrame.followerID) then
						if (shouldFadeOut) then
							cluster.FadeOut:Play();
						end
						if (shouldCheer) then
							for _, model in ipairs(cluster.Model) do
								if ( model.followerID == followerFrame.followerID and model:IsShown() ) then
									if not (followerInfo.isTroop) then
										model:SetSpellVisualKit(75505);
									end
									model:PlayAnimKit(11935);
									break;
								end
							end
						else
							for _, model in ipairs(cluster.Model) do
								if ( model.followerID == followerFrame.followerID and model:IsShown() ) then
									model:PlayAnimKit(11937);
									break;
								end
							end
						end
					end
				end
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
		local followerInfo = C_Garrison.GetFollowerInfo(followerFrame.followerID);
		followerInfo.level = nextLevel;
		followerInfo.quality = nextQuality;
		followerInfo.xp = 0;
		followerInfo.levelXP = nextLevelXP;
		self:SetFollowerLevel(followerFrame, followerInfo);
		if ( nextLevelXP ) then
			maxXP = nextLevelXP;
		else
			-- ensure we're done
			xpBar.remainingXP = 0;
		end
		-- visual
		-- don't cheer for 7.0 followers because we are already cheering for mission success
		if (self:GetParent().followerTypeID ~= Enum.GarrisonFollowerType.FollowerType_7_0) then
			for _, cluster in ipairs(self.Stage.ModelCluster) do
				if (cluster:IsShown()) then
					for _, model in ipairs(cluster.Model) do
						if ( model.followerID == followerFrame.followerID and model:IsShown() ) then
							model:SetSpellVisualKit(6375);	-- level up visual
							PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_FOLLOWER_LEVEL_UP);
							break;
						end
					end
				end
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

function GarrisonMissionComplete_KillFollowerXPAnims(followerFrame)
	followerFrame.XPGain.FadeIn:Stop();
	followerFrame.XP:SetScript("OnUpdate", nil);
	followerFrame.LevelUpFrame.Anim:Stop();
	followerFrame.activeAnims = 0;
end

function GarrisonMissionComplete:KillFollowerXPAnims()
	for _, followerFrame in pairs(self.Stage.FollowersFrame.Followers) do
		GarrisonMissionComplete_KillFollowerXPAnims(followerFrame);
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
	local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(frame.itemLink or frame.itemID);
	frame.Icon:SetTexture(itemTexture);
	local color = ITEM_QUALITY_COLORS[itemRarity];
	if(color) then
		if (frame.Name and itemName) then
			frame.Name:SetText(color.hex..itemName..FONT_COLOR_CODE_CLOSE);
		end
		frame.IconBorder:SetVertexColor(color.r, color.g, color.b);
		frame.IconBorder:Show();
	end
end

function GarrisonMissionPage_SetReward(frame, reward, missionComplete)
	frame.Quantity:Hide();
	frame.Quantity:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	frame.IconBorder:Hide();
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
				frame.Name:SetText(frame.tooltip);
			else
				local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reward.currencyID);
				local currencyName = currencyInfo.name;
				local currencyQuantity = currencyInfo.quantity;
				local currencyTexture = currencyInfo.iconFileID;
				local currencyQuality = currencyInfo.quality;
				currencyName, currencyTexture, currencyQuantity, currencyQuality = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.currencyID, reward.quantity, currencyName, currencyTexture, currencyQuality);

				frame.currencyID = reward.currencyID;
				frame.currencyQuantity = reward.quantity;

				frame.Name:SetText(currencyName);
				local currencyColor = GetColorForCurrencyReward(frame.currencyID, currencyQuantity)
				frame.Name:SetTextColor(currencyColor:GetRGB());
				frame.Icon:SetTexture(currencyTexture);

				if (currencyQuality) then
					SetItemButtonQuality(frame, currencyQuality, frame.currencyID);
				end

				if ( not missionComplete and currencyQuantity > 1 ) then
					local currencyColor = GetColorForCurrencyReward(frame.currencyID, currencyQuantity)
					frame.Quantity:SetTextColor(currencyColor:GetRGB());
					frame.Quantity:SetText(currencyQuantity);
					frame.Quantity:Show();
				end
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
		if (tooltip) then
			GarrisonBonusArea_Set(tooltip.BonusArea, GARRISON_BONUS_EFFECT_TIME_ACTIVE, self.duration, self.icon, self.name, self.description);

			tooltip:ClearAllPoints();
			tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
			tooltip:SetHeight(tooltip.BonusArea:GetHeight());
			tooltip:Show();
		end
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		if (self.itemID) then
			GameTooltip:SetItemByID(self.itemID);
			return;
		end
		if (self.currencyID and self.currencyID ~= 0) then
			GameTooltip:SetCurrencyByID(self.currencyID, self.currencyQuantity);
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
	if (GarrisonBonusAreaTooltip) then
		GarrisonBonusAreaTooltip:Hide();
	end
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

function GarrisonMissionPageRewardsFrame_SetSuccessChance(self, chance)
	local successChanceColor = GREEN_FONT_COLOR;
	if (chance < 0) then
		successChanceColor = RED_FONT_COLOR;
	end

	self.Chance:SetFormattedText(successChanceColor:WrapTextInColorCode(PERCENTAGE_STRING), chance);
	self.ChanceLabel:SetText(successChanceColor:WrapTextInColorCode(GARRISON_MISSION_CHANCE));
	self.currentChance = chance;
end

function GarrisonMissionPageRewardsFrame_OnUpdate(self, elapsed)
	self.elapsedTime = self.elapsedTime + elapsed;
	-- 0 to 100 should take 1 second
	local newChance = math.floor(self.startingChance + self.elapsedTime * 100);
	newChance = min(newChance, self.endingChance);
	GarrisonMissionPageRewardsFrame_SetSuccessChance(self, newChance);
	if ( newChance == self.endingChance ) then
		if ( newChance == 100 ) then
			PlaySound(SOUNDKIT.UI_GARRISON_MISSION_100_PERCENT_CHANCE_REACHED_NOT_USED);	-- 100% chance reached
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

GarrisonMissionPageMixin = { }

--this function puts check marks on the encounter mechanics countered by the slotted followers abilities
function GarrisonMissionPageMixin:SetCounters(followers, enemies, missionID)
	-- clear counter state
	local numEnemies = enemies and #enemies or 0;
	for i = 1, numEnemies do
		local enemyFrame = enemies[i];
		for mechanicIndex = 1, #enemyFrame.Mechanics do
			enemyFrame.Mechanics[mechanicIndex].hasCounter = nil;
		end
	end

	for i = 1, #followers do
		local followerFrame = followers[i];
		if (followerFrame.info) then
			local followerBias = C_Garrison.GetFollowerBiasForMission(missionID, followerFrame.info.followerID);
			if ( followerBias > -1 ) then
				local abilities = C_Garrison.GetFollowerAbilities(followerFrame.info.followerID);
				for a = 1, #abilities do
					local ability = abilities[a];
					for counterID, counterInfo in pairs(ability.counters) do
						self:CheckCounter(enemies, counterID);
					end
				end
			end
		end
	end

	local bonusEffects = C_Garrison.GetMissionBonusAbilityEffects(missionID);
	for i = 1, #bonusEffects do
		local mechanicTypeID = bonusEffects[i].mechanicTypeID;
		if(mechanicTypeID ~= 0) then
			self:CheckCounter(enemies, mechanicTypeID);
		end
	end

	-- show/remove checks
	local playSound = false;
	for i = 1, numEnemies do
		local enemyFrame = enemies[i];
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
		PlaySound(SOUNDKIT.UI_GARRISON_MISSION_THREAT_COUNTERED);
	end
end

function GarrisonMissionPageMixin:GenerateSuccessTooltip(tooltipAnchor)
	GarrisonMissionPageRewardTemplate_TooltipHitBox_GenerateSuccessTooltip(tooltipAnchor);
end

function GarrisonMissionPageMixin:CheckCounter(enemies, counterID)
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

-- overridden
function GarrisonMissionPageMixin:UpdateFollowerDurability(followerFrame)
end


---------------------------------------------------------------------------------
--- Template Functions                                                        ---
---------------------------------------------------------------------------------

function GarrisonMissionFrame_OnLoad(self)
	self:OnLoadMainFrame();
end

function GarrisonMissionController_OnClickTab(tab)
	local mainFrame = tab:GetParent();
	PlaySound(SOUNDKIT.UI_GARRISON_NAV_TABS);
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
	local changeBack = (rateBack / 100) * elapsed;
	local changeMid = (rateMid / 100) * elapsed;
	local changeFore = (rateFore / 100) * elapsed;

	self.backProgress = (self.backProgress or 0) + changeBack;
	if self.backProgress >= 1 then
		self.backProgress = self.backProgress - 1;
	end

	self.midProgress = (self.midProgress or 0) + changeMid;
	if self.midProgress >= 1 then
		self.midProgress = self.midProgress - 1;
	end

	self.foreProgress = (self.foreProgress or 0) + changeFore;
	if self.foreProgress >= 1 then
		self.foreProgress = self.foreProgress - 1;
	end

	local backL = self.backProgress;
	local backR = backL + self.locBackTexCoordRange;
	local midL = self.midProgress;
	local midR = midL + self.locMidTexCoordRange;
	local foreL = self.foreProgress;
	local foreR = foreL + self.locForeTexCoordRange;

	self.LocBack:SetTexCoord(backL, backR, 0, 1);
	self.LocMid:SetTexCoord (midL, midR, 0, 1);
	self.LocFore:SetTexCoord(foreL, foreR, 0, 1);
end

function GarrisonMissionController_OnEnterMissionStartButton(self)
	if (not self:IsEnabled()) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, RED_FONT_COLOR.a, true);
		GameTooltip:Show();
	end
end

function GarrisonMissionController_OnClickMissionStartButton(buttonFrame)
	local mainFrame = buttonFrame:GetParent():GetParent():GetParent();
	mainFrame:OnClickStartMissionButton();
end

local function GarrisonMissionStage_SetupTexture(self, texture, textureCoordRangeKey, atlas)
	if atlas then
		-- Make sure the atlas exists. Many locations don't have an atlas for each layer.
		local info = C_Texture.GetAtlasInfo(atlas);
		if info and info.width and info.width ~= 0 then
			texture:SetAtlas(atlas, true);
			self[textureCoordRangeKey] = texture:GetWidth() / info.width;
			texture:Show();
		else
			texture:Hide();
		end
	else
		texture:Hide();
	end
end

function GarrisonMissionStage_SetBack(self, atlas)
	GarrisonMissionStage_SetupTexture(self, self.LocBack, "locBackTexCoordRange", atlas);
end

function GarrisonMissionStage_SetMid(self, atlas)
	GarrisonMissionStage_SetupTexture(self, self.LocMid, "locMidTexCoordRange", atlas);
end

function GarrisonMissionStage_SetFore(self, atlas)
	GarrisonMissionStage_SetupTexture(self, self.LocFore, "locForeTexCoordRange", atlas);
end

function GarrisonMissionStage_OnLoad(self)
	GarrisonMissionStage_SetBack(self, "_GarrMissionLocation-TannanJungle-Back");
	GarrisonMissionStage_SetMid(self, "_GarrMissionLocation-TannanJungle-Mid");
	GarrisonMissionStage_SetFore(self, "_GarrMissionLocation-TannanJungle-Fore");
end

function GarrisonFollowerPlacerFrame_OnClick(self, button)
	self.mainFrame:OnClickFollowerPlacerFrame(button, self.info);
end

function GarrisonMissionController_OnClickViewCompletedMissionsButton(self)
	local mainFrame = self;
	while (mainFrame:GetParent() ~= UIParent and mainFrame:GetParent() ~= nil) do
		mainFrame = mainFrame:GetParent();
	end
	mainFrame:OnClickViewCompletedMissionsButton();
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
		PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_CHEST_UNLOCK_GOLD_SUCCESS);
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

function GarrisonMissionPageRewardTemplate_MissionXPTooltipHitBox_OnEnter(self)
	if (self:GetParent().MissionXP.hasBonusBaseXP) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddColoredLine(GameTooltip, GARRISON_MISSION_BONUS_BASE_XP_TOOLTIP, HIGHLIGHT_FONT_COLOR, nil, true);
		GameTooltip:Show();
	end
end

function GarrisonMissionPageRewardTemplate_TooltipHitBox_OnEnter(self)
	local missionPage = self:GetParent():GetParent();
	missionPage:GenerateSuccessTooltip(self);
end

function GarrisonMissionPageRewardTemplate_TooltipHitBox_GenerateSuccessTooltip(tooltipAnchor)
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("BOTTOMLEFT", tooltipAnchor, "BOTTOMRIGHT", 10, 0);
	GameTooltip:SetOwner(tooltipAnchor, "ANCHOR_PRESERVE");
	GameTooltip_AddNormalLine(GameTooltip, GARRISON_MISSION_CHANCE_TOOLTIP_HEADER);
	local missionID = tooltipAnchor:GetParent():GetParent().missionInfo.missionID;
	GameTooltip_AddColoredLine(GameTooltip, GARRISON_MISSION_PERCENT_CHANCE:format(C_Garrison.GetMissionSuccessChance(missionID)), HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, tooltipAnchor:GetParent().tooltipText, true, true);
	GameTooltip:Show();
end



---------------------------------------------------------------------------------
--- Tooltips                                                                  ---
---------------------------------------------------------------------------------

function GarrisonMissionMechanic_OnEnter(self)
	if (not self.info) then
		return;
	end

	if (GarrisonFollowerOptions[self.followerTypeID].displayCounterAbilityInPlaceOfMechanic and self.counterAbility) then
		ShowGarrisonFollowerMissionAbilityTooltip(self, self.counterAbility.id, self.followerTypeID);
		return;
	end

	local tooltip = GarrisonMissionMechanicTooltip;

	-- Tooltip needs to be parented to the main frame. Since this tooltip frame is shared between
	-- multiple main frames, we need to set the parent here. Also set the frame strata because
	-- setting the parent loses the frame strata. This is a bug we should fix in 7.0.
	tooltip:SetParent(self.mainFrame);
	tooltip:SetFrameStrata("TOOLTIP");
	if (not self.followerTypeID) then
		self.followerTypeID = Enum.GarrisonFollowerType.FollowerType_6_0;
	end
	if ( self.info.factor <= GARRISON_HIGH_THREAT_VALUE and self.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_2 ) then
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

function GarrisonMissionMechanic_OnLeave(self)
	GarrisonMissionMechanicTooltip:Hide();
	HideGarrisonFollowerMissionAbilityTooltip(self.followerTypeID);
end

function GarrisonMissionMechanicFollowerCounter_OnEnter(self)
	if (not self.info) then
		return;
	end
	if ( self.info.traitID ) then
		ShowGarrisonFollowerAbilityTooltip(self, self.info.traitID, self.followerTypeID);
		return;
	elseif ( self.info.spellID ) then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 0);
		GameTooltip:SetSpellByID(self.info.spellID);
		GameTooltip:Show();
		return;
	elseif (self.info.autoCombatSpellID) then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 0);
		AddAutoCombatSpellToTooltip(GameTooltip, self.info);
		GameTooltip:Show();
		return;
	elseif (GarrisonFollowerOptions[self.followerTypeID].displayCounterAbilityInPlaceOfMechanic and self.info.counterID) then
		ShowGarrisonFollowerAbilityTooltip(self, self.info.counterID, self.followerTypeID);
		return;
	end
	local tooltip = GarrisonMissionMechanicFollowerCounterTooltip;
	tooltip.Icon:SetTexture(self.info.icon);
	tooltip.Name:SetText(self.info.name);
	if (self.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_2) then
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

		if ( self.info.factor <= GARRISON_HIGH_THREAT_VALUE and self.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_2 ) then
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
	GameTooltip:Hide();
	GarrisonMissionMechanicFollowerCounterTooltip:Hide();
	HideGarrisonFollowerAbilityTooltip(self.followerTypeID);
end

function GarrisonMission_DetermineCounterableThreats(missionID, followerType)
	local threats = {};
	threats.full = {};
	threats.partial = {};
	threats.away = {};
	threats.worker = {};

	local followerList = C_Garrison.GetFollowers(followerType) or {};
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
							if ( isFullCounter or GarrisonFollowerOptions[followerType].missionTooltipShowPartialCountersAsFull ) then
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

function GarrisonMissionButton_AddThreatsToTooltip(missionID, followerTypeID, noGameTooltip, abilityCountersForMechanicTypes)
	local missionDeploymentInfo = C_Garrison.GetMissionDeploymentInfo(missionID);
	local enemies = missionDeploymentInfo.enemies;
	local numThreats = 0;

	-- Make a list of all the threats that we can counter.
	local counterableThreats = GarrisonMission_DetermineCounterableThreats(missionID, followerTypeID);

	for i = 1, #enemies do
		local enemy = enemies[i];
		for _, mechanic in pairs(enemy.mechanics) do
			numThreats = numThreats + 1;
			local threatFrame = GarrisonMissionListTooltipThreatsFrame.Threats[numThreats];
			if ( not threatFrame ) then
				threatFrame = CreateFrame("Frame", nil, GarrisonMissionListTooltipThreatsFrame, "GarrisonAbilityCounterWithCheckTemplate");
				threatFrame:SetPoint("LEFT", GarrisonMissionListTooltipThreatsFrame.Threats[numThreats - 1], "RIGHT", 10, 0);
				tinsert(GarrisonMissionListTooltipThreatsFrame.Threats, threatFrame);
			end

			if (GarrisonFollowerOptions[followerTypeID].displayCounterAbilityInPlaceOfMechanic) then
				local ability = abilityCountersForMechanicTypes[mechanic.mechanicTypeID];
				threatFrame.Border:SetShown(ability and ShouldShowFollowerAbilityBorder(followerTypeID, ability));
				threatFrame.Icon:SetTexture(ability and ability.icon);
			else
				if ( mechanic.factor <= GARRISON_HIGH_THREAT_VALUE and followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_2 ) then
					threatFrame.Border:SetAtlas("GarrMission_WeakEncounterAbilityBorder");
				else
					threatFrame.Border:SetAtlas("GarrMission_EncounterAbilityBorder");
				end
				threatFrame.Icon:SetTexture(mechanic.icon);
			end
			threatFrame:Show();
			GarrisonMissionButton_CheckTooltipThreat(threatFrame, missionID, mechanic.mechanicTypeID, counterableThreats);
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

local PRELOADING_NUM_MODELS_TOTAL = 0;
local PRELOADING_NUM_MODELS_LOADED = 0;
local PRELOADING_MISSION_ID = 0;

function MissionCompletePreload_LoadMission(mainFrame, missionID, singleFollower, singleEncounter)
	if ( missionID == PRELOADING_MISSION_ID ) then
		return;
	end

	PRELOADING_MISSION_ID = missionID;
	-- followersDisplayIDs is an array of arrays of displayIDs.
	-- enemies can only have one displayID each.
	local followersDisplayIDs, enemyDisplayIDs = C_Garrison.GetMissionDisplayIDs(missionID);

	if (singleFollower) then
		-- Only load the first follower model
		local missionInfo = C_Garrison.GetBasicMissionInfo(missionID);
		for index = 1, #followersDisplayIDs do
			if (not C_Garrison.GetFollowerIsTroop(missionInfo.followers[index])) then
				followersDisplayIDs = { followersDisplayIDs[index] };
			end
		end
	end

	if (singleEncounter) then
		enemyDisplayIDs = { enemyDisplayIDs[1] };
	end

	local models = mainFrame.MissionTab.MissionCompletePreloadModels;
	-- clean up if needed
	if ( not MissionCompletePreload_IsReady() ) then
		MissionCompletePreload_Cancel(mainFrame);
	end
	-- load models
	local index = 0;
	if ( models ) then
		for i = 1, #followersDisplayIDs do
			for j = 1, #followersDisplayIDs[i] do
				index = index + 1;
				local model = models[index];
				model.loading = true;
				model:SetDisplayInfo(followersDisplayIDs[i][j].id);
			end
		end
		for i = 1, #enemyDisplayIDs do
			index = index + 1;
			local model = models[index];
			model.loading = true;
			model:SetDisplayInfo(enemyDisplayIDs[i]);
		end
	end
	PRELOADING_NUM_MODELS_TOTAL = index;
end

function MissionCompletePreload_Cancel(mainFrame)
	local models = mainFrame.MissionTab.MissionCompletePreloadModels;
	if ( models ) then
		for i = 1, #models do
			models[i].loading = nil;
			models[i]:ClearModel();
		end
		PRELOADING_NUM_MODELS_LOADED = 0;
		PRELOADING_NUM_MODELS_TOTAL = 0;
		PRELOADING_MISSION_ID = 0;
		models[1]:SetScript("OnUpdate", nil);
	end
end

function MissionCompletePreload_IsReady()
	return PRELOADING_NUM_MODELS_LOADED == PRELOADING_NUM_MODELS_TOTAL;
end

function MissionCompletePreload_OnModelLoaded(self)
	if ( self.loading ) then
		self.loading = nil;
		PRELOADING_NUM_MODELS_LOADED = PRELOADING_NUM_MODELS_LOADED + 1;
	end
end

function MissionCompletePreload_OnUpdate(self, elapsed)
	local callback = self.callbackFunc;
	if ( MissionCompletePreload_IsReady() ) then
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

---------------------------------------------------------------------------------
--- GarrisonMissionCompleteModelClusterMixin                                  ---
---------------------------------------------------------------------------------

GarrisonMissionCompleteModelClusterMixin = {}

function GarrisonMissionCompleteModelClusterMixin:SetFacingLeft(facingLeft)
	for i, model in ipairs(self.Model) do
		model:SetFacingLeft(facingLeft);
	end
end

function GarrisonMissionCompleteModelClusterMixin:GetFollowerID()
	return self.Model[1].followerID;
end

---------------------------------------------------------------------------------
--- GarrisonMissionPageCostWithTooltipMixin                                  ---
---------------------------------------------------------------------------------

GarrisonMissionPageCostWithTooltipMixin = {}

function GarrisonMissionPageCostWithTooltipMixin:SetCurrency(currency)
	self.currency = currency;
end

function GarrisonMissionPageCostWithTooltipMixin:OnEnter()
	if self.currency then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetCurrencyTokenByID(self.currency);
		GameTooltip:Show();
	end
end

function GarrisonMissionPageCostWithTooltipMixin:OnLeave()
	GameTooltip:Hide();
end