MAX_ACHIEVEMENT_ALERTS = 2;
LOOT_WON_ALERT_FRAMES = {};
LOOT_UPGRADE_ALERT_FRAMES = {};
MONEY_WON_ALERT_FRAMES = {};
DELAYED_ACHIEVEMENT_ALERTS = {};
ACHIEVEMENT_ID_INDEX = 1;
OLD_ACHIEVEMENT_INDEX = 2;
MAX_QUEUED_ACHIEVEMENT_TOASTS = 6;

function AlertFrame_OnLoad (self)
	self:RegisterEvent("ACHIEVEMENT_EARNED");
	self:RegisterEvent("CRITERIA_EARNED");
	self:RegisterEvent("LFG_COMPLETION_REWARD");
	self:RegisterEvent("GUILD_CHALLENGE_COMPLETED");
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
	self:RegisterEvent("LOOT_ITEM_ROLL_WON");
	self:RegisterEvent("SHOW_LOOT_TOAST");
	self:RegisterEvent("SHOW_LOOT_TOAST_UPGRADE");
	self:RegisterEvent("SHOW_PVP_FACTION_LOOT_TOAST");
	self:RegisterEvent("PET_BATTLE_CLOSE");
	self:RegisterEvent("STORE_PRODUCT_DELIVERED");
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE");
	self:RegisterEvent("GARRISON_MISSION_FINISHED");
	self:RegisterEvent("GARRISON_FOLLOWER_ADDED");
	self:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED");
end

function AlertFrame_OnEvent (self, event, ...)
	if ( event == "ACHIEVEMENT_EARNED" ) then
		local id, alreadyEarned = ...;
		
		if ( not AchievementFrame ) then
			AchievementFrame_LoadUI();
		end
		
		AchievementAlertFrame_ShowAlert(id, alreadyEarned);
	elseif ( event == "CRITERIA_EARNED" ) then
		local id, criteria = ...;
		
		if ( not AchievementFrame ) then
			AchievementFrame_LoadUI();
		end
		
		CriteriaAlertFrame_ShowAlert(id, criteria);
	elseif ( event == "LFG_COMPLETION_REWARD" ) then
		if ( C_Scenario.IsInScenario() and not C_Scenario.TreatScenarioAsDungeon() ) then
			ScenarioAlertFrame_ShowAlert();
		else
			DungeonCompletionAlertFrame_ShowAlert();
		end
	elseif ( event == "GUILD_CHALLENGE_COMPLETED" ) then
		GuildChallengeAlertFrame_ShowAlert(...);
	elseif ( event == "CHALLENGE_MODE_COMPLETED" ) then
		ChallengeModeAlertFrame_ShowAlert();
	elseif ( event == "LOOT_ITEM_ROLL_WON" ) then
		local itemLink, quantity, rollType, roll = ...;
		LootWonAlertFrame_ShowAlert(itemLink, quantity, rollType, roll);
	elseif ( event == "SHOW_LOOT_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lootSource = ...;
		if ( typeIdentifier == "item" ) then
			LootWonAlertFrame_ShowAlert(itemLink, quantity, nil, nil, specID);
		elseif ( typeIdentifier == "money" ) then
			MoneyWonAlertFrame_ShowAlert(quantity);
		elseif ( (isPersonal == true) and (typeIdentifier == "currency") ) then
			-- only toast currency for personal loot
			LootWonAlertFrame_ShowAlert(itemLink, quantity, nil, nil, specID, true, false, lootSource);
		end
	elseif ( event == "SHOW_PVP_FACTION_LOOT_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal = ...;
		if ( typeIdentifier == "item" ) then
			LootWonAlertFrame_ShowAlert(itemLink, quantity, nil, nil, specID, false, true);
		elseif ( typeIdentifier == "money" ) then
			MoneyWonAlertFrame_ShowAlert(quantity);
		elseif ( typeIdentifier == "currency" ) then
			LootWonAlertFrame_ShowAlert(itemLink, quantity, nil, nil, specID, true, true);
		end
	elseif ( event == "SHOW_LOOT_TOAST_UPGRADE") then
		local itemLink, quantity, specID, sex, baseQuality, isPersonal = ...;
		LootUpgradeFrame_ShowAlert(itemLink, quantity, specID, baseQuality);
	elseif ( event == "PET_BATTLE_CLOSE" ) then
		AchievementAlertFrame_FireDelayedAlerts();
	elseif ( event == "STORE_PRODUCT_DELIVERED" ) then
		local icon, name, itemID = ...;
		StorePurchaseAlertFrame_ShowAlert(icon, name, itemID);
	elseif ( event == "GARRISON_BUILDING_ACTIVATABLE" ) then
		local name = ...;
		GarrisonBuildingAlertFrame_ShowAlert(name);
	elseif ( event == "GARRISON_MISSION_FINISHED" ) then
		if ( not GarrisonMissionFrame or not GarrisonMissionFrame:IsShown() ) then
			GarrisonMissionAlertFrame_ShowAlert(...);
		end
	elseif ( event == "GARRISON_FOLLOWER_ADDED" ) then
		local followerID, name, displayID, level, quality, isUpgraded = ...;
		GarrisonFollowerAlertFrame_ShowAlert(followerID, name, displayID, level, quality, isUpgraded);
	elseif ( event == "GARRISON_RANDOM_MISSION_ADDED" ) then
		GarrisonRandomMissionAlertFrame_ShowAlert(...);
	end
end

function AlertFrame_AnimateIn(frame)
	frame:Show();
	frame.animIn:Play();
	if ( frame.glow ) then
		frame.glow:Show();
		frame.glow.animIn:Play();
	end
	if ( frame.shine ) then
		frame.shine:Show();
		frame.shine.animIn:Play();
	end
	frame.waitAndAnimOut:Stop();	--Just in case it's already animating out, but we want to reinstate it.
	if ( frame:IsMouseOver() ) then
		frame.waitAndAnimOut.animOut:SetStartDelay(1);
	else
		frame.waitAndAnimOut.animOut:SetStartDelay(4.05);
		frame.waitAndAnimOut:Play();
	end
end

-- [[ AlertFrameTemplate functions ]] --
function AlertFrameTemplate_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function AlertFrame_StopOutAnimation(frame)
	frame.waitAndAnimOut:Stop();
	frame.waitAndAnimOut.animOut:SetStartDelay(1);
end

function AlertFrame_ResumeOutAnimation(frame)
	frame.waitAndAnimOut:Play();
end

function AlertFrame_OnClick(self, button, down)
	if ( button == "RightButton" ) then
		self.animIn:Stop();
		if ( self.glow ) then
			self.glow.animIn:Stop();
		end
		if ( self.shine ) then
			self.shine.animIn:Stop();
		end
		self.waitAndAnimOut:Stop();
		self:Hide();
		return true;
	end
	
	return false;
end

-- [[ Anchoring ]] --
function AlertFrame_FixAnchors()
	local alertAnchor = AlertFrame;
	alertAnchor = AlertFrame_SetLootAnchors(alertAnchor); --This needs to be first as it doesn't actually anchor anything.
	alertAnchor = AlertFrame_SetStorePurchaseAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetLootWonAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetLootUpgradeFrameAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetMoneyWonAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetAchievementAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetCriteriaAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetChallengeModeAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetDungeonCompletionAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetScenarioAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetGuildChallengeAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetDigsiteCompleteToastFrameAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetGarrisonBuildingAlertFrameAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetGarrisonMissionAlertFrameAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetGarrisonFollowerAlertFrameAnchors(alertAnchor);
end

function AlertFrame_SetLootAnchors(alertAnchor)
	-- this doesn't need to actually reanchor anything... yet
	-- normal loot
	local frame = GroupLootContainer;
	if ( frame:IsShown() ) then
		return frame;
	end
	-- LFR loot
	frame = MissingLootFrame;
	if ( frame:IsShown() ) then
		return frame;
	end

	return alertAnchor;
end

function AlertFrame_SetStorePurchaseAnchors(alertAnchor)
	local frame = StorePurchaseAlertFrame;
	if ( frame:IsShown() ) then
		frame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
		return frame;
	end
	return alertAnchor;
end

function AlertFrame_SetLootWonAnchors(alertAnchor)
	for i=1, #LOOT_WON_ALERT_FRAMES do
		local frame = LOOT_WON_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
			alertAnchor = frame;
		end
	end
	return alertAnchor;
end

function AlertFrame_SetLootUpgradeFrameAnchors(alertAnchor)
	for i=1, #LOOT_UPGRADE_ALERT_FRAMES do
		local frame = LOOT_UPGRADE_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
			alertAnchor = frame;
		end
	end
	return alertAnchor;
end

function AlertFrame_SetMoneyWonAnchors(alertAnchor)
	for i=1, #MONEY_WON_ALERT_FRAMES do
		local frame = MONEY_WON_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
			alertAnchor = frame;
		end
	end
	return alertAnchor;
end

function AlertFrame_SetAchievementAnchors(alertAnchor)
	-- skip work if there hasn't been an achievement toast yet
	if ( AchievementAlertFrame1 ) then
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["AchievementAlertFrame"..i];
			if ( frame and frame:IsShown() ) then
				frame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
				alertAnchor = frame;
			end
		end
	end
	return alertAnchor;
end

function AlertFrame_SetCriteriaAnchors(alertAnchor)
	-- skip work if there hasn't been an criteria toast yet
	if ( CriteriaAlertFrame1 ) then
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["CriteriaAlertFrame"..i];
			if ( frame and frame:IsShown() ) then
				frame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
				alertAnchor = frame;
			end
		end
	end
	return alertAnchor;
end

function AlertFrame_SetChallengeModeAnchors(alertAnchor)
	local frame = ChallengeModeAlertFrame1;
	if ( frame:IsShown() ) then
		frame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
		alertAnchor = frame;
	end
	return alertAnchor;
end

function AlertFrame_SetDungeonCompletionAnchors(alertAnchor)
	local frame = DungeonCompletionAlertFrame1;
	if ( frame:IsShown() ) then
		frame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
		alertAnchor = frame;
	end
	return alertAnchor;
end

function AlertFrame_SetScenarioAnchors(alertAnchor)
	local frame = ScenarioAlertFrame1;
	if ( frame:IsShown() ) then
		frame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
		alertAnchor = frame;
	end
	return alertAnchor;
end

function AlertFrame_SetGuildChallengeAnchors(alertAnchor)
	local frame = GuildChallengeAlertFrame;
	if ( frame:IsShown() ) then
		frame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
		alertAnchor = frame;
	end
	return alertAnchor;
end

function AlertFrame_SetDigsiteCompleteToastFrameAnchors(alertAnchor)
	if ( DigsiteCompleteToastFrame and DigsiteCompleteToastFrame:IsShown() ) then
		DigsiteCompleteToastFrame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
		alertAnchor = DigsiteCompleteToastFrame;
	end
	return alertAnchor;
end

function AlertFrame_SetGarrisonBuildingAlertFrameAnchors(alertAnchor)
	if ( GarrisonBuildingAlertFrame and GarrisonBuildingAlertFrame:IsShown() ) then
		GarrisonBuildingAlertFrame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
		alertAnchor = GarrisonBuildingAlertFrame;
	end
	return alertAnchor;
end

function AlertFrame_SetGarrisonMissionAlertFrameAnchors(alertAnchor)
	if ( GarrisonMissionAlertFrame and GarrisonMissionAlertFrame:IsShown() ) then
		GarrisonMissionAlertFrame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
		alertAnchor = GarrisonMissionAlertFrame;
	end
	return alertAnchor;
end

function AlertFrame_SetGarrisonFollowerAlertFrameAnchors(alertAnchor)
	if ( GarrisonFollowerAlertFrame and GarrisonFollowerAlertFrame:IsShown() ) then
		GarrisonFollowerAlertFrame:SetPoint("BOTTOM", alertAnchor, "TOP", 0, 10);
		alertAnchor = GarrisonFollowerAlertFrame;
	end
	return alertAnchor;
end

-- [[ GuildChallengeAlertFrame ]] --
function GuildChallengeAlertFrame_ShowAlert(...)
	local challengeType, count, max = ...;
	GuildChallengeAlertFrameType:SetText(_G["GUILD_CHALLENGE_TYPE"..challengeType]);
	GuildChallengeAlertFrameCount:SetFormattedText(GUILD_CHALLENGE_PROGRESS_FORMAT, count, max);
	SetLargeGuildTabardTextures("player", GuildChallengeAlertFrameEmblemIcon, GuildChallengeAlertFrameEmblemBackground, GuildChallengeAlertFrameEmblemBorder);
	AlertFrame_AnimateIn(GuildChallengeAlertFrame);
	AlertFrame_FixAnchors();
end

function GuildChallengeAlertFrame_OnClick(self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end
	if ( not GuildFrame or not GuildFrame:IsShown() ) then
		ToggleGuildFrame();
	end
	-- select the Info tab
	GuildFrame_TabClicked(GuildFrameTab5);
end

-- [[ DungeonCompletionAlertFrame ]] --
function DungeonCompletionAlertFrame_OnLoad (self)
	self.glow = self.glowFrame.glow;
end

DUNGEON_COMPLETION_MAX_REWARDS = 1;
function DungeonCompletionAlertFrame_ShowAlert()
	PlaySound("LFG_Rewards");
	local frame = DungeonCompletionAlertFrame1;
	--For now we only have 1 dungeon alert frame. If you're completing more than one dungeon within ~5 seconds, tough luck.
	local name, typeID, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards= GetLFGCompletionReward();
	
	if ( subtypeID == LFG_SUBTYPEID_RAID ) then
		frame.raidArt:Show();
		frame.dungeonArt1:Hide();
		frame.dungeonArt2:Hide();
		frame.dungeonArt3:Hide();
		frame.dungeonArt4:Hide();
		frame.dungeonTexture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 26, 18);
	else
		frame.raidArt:Hide();
		frame.dungeonArt1:Show();
		frame.dungeonArt2:Show();
		frame.dungeonArt3:Show();
		frame.dungeonArt4:Show();
		frame.dungeonTexture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 13, 13);
	end
	
	--Set up the rewards
	local moneyAmount = moneyBase + moneyVar * numStrangers;
	local experienceGained = experienceBase + experienceVar * numStrangers;
	
	local rewardsOffset = 0;

	if ( moneyAmount > 0 or experienceGained > 0 ) then --hasMiscReward ) then
		SetPortraitToTexture(DungeonCompletionAlertFrame1Reward1.texture, "Interface\\Icons\\inv_misc_coin_02");
		DungeonCompletionAlertFrame1Reward1.rewardID = 0;
		DungeonCompletionAlertFrame1Reward1:Show();

		rewardsOffset = 1;
	end
	
	for i = 1, numRewards do
		local frameID = (i + rewardsOffset);
		local reward = _G["DungeonCompletionAlertFrame1Reward"..frameID];
		if ( not reward ) then
			reward = CreateFrame("FRAME", "DungeonCompletionAlertFrame1Reward"..frameID, DungeonCompletionAlertFrame1, "DungeonCompletionAlertFrameRewardTemplate");
			reward:SetID(frameID);
			DUNGEON_COMPLETION_MAX_REWARDS = frameID;
		end
		DungeonCompletionAlertFrameReward_SetReward(reward, i);
	end
	
	local usedButtons = numRewards + rewardsOffset;
	--Hide the unused ones
	for i = usedButtons + 1, DUNGEON_COMPLETION_MAX_REWARDS do
		_G["DungeonCompletionAlertFrame1Reward"..i]:Hide();
	end
	
	if ( usedButtons > 0 ) then
		--Set up positions
		local spacing = 36;
		DungeonCompletionAlertFrame1Reward1:SetPoint("TOP", DungeonCompletionAlertFrame1, "TOP", -spacing/2 * usedButtons + 41, 0);
		for i = 2, usedButtons do
			_G["DungeonCompletionAlertFrame1Reward"..i]:SetPoint("CENTER", "DungeonCompletionAlertFrame1Reward"..(i - 1), "CENTER", spacing, 0);
		end
	end
	
	--Set up the text and icons.
	
	frame.instanceName:SetText(name);
	if ( subtypeID == LFG_SUBTYPEID_HEROIC ) then
		frame.heroicIcon:Show();
		frame.instanceName:SetPoint("TOP", 33, -44);
	else
		frame.heroicIcon:Hide();
		frame.instanceName:SetPoint("TOP", 25, -44);
	end
		
	frame.dungeonTexture:SetTexture("Interface\\LFGFrame\\LFGIcon-"..textureFilename);
	
	AlertFrame_AnimateIn(frame)
	
	
	AlertFrame_FixAnchors();
end

function DungeonCompletionAlertFrameReward_SetReward(frame, index)
	local texturePath, quantity = GetLFGCompletionRewardItem(index);
	SetPortraitToTexture(frame.texture, texturePath);
	frame.rewardID = index;
	frame:Show();
end

function DungeonCompletionAlertFrameReward_OnEnter(self)
	AlertFrame_StopOutAnimation(self:GetParent());
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( self.rewardID == 0 ) then
		GameTooltip:AddLine(YOU_RECEIVED);
		local name, typeID, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards = GetLFGCompletionReward();

		local moneyAmount = moneyBase + moneyVar * numStrangers;
		local experienceGained = experienceBase + experienceVar * numStrangers;
		
		if ( experienceGained > 0 ) then
			GameTooltip:AddLine(string.format(GAIN_EXPERIENCE, experienceGained));
		end
		if ( moneyAmount > 0 ) then
			SetTooltipMoney(GameTooltip, moneyAmount, nil);
		end
	else
		GameTooltip:SetLFGCompletionReward(self.rewardID);
	end
	GameTooltip:Show();
end

function DungeonCompletionAlertFrameReward_OnLeave(frame)
	AlertFrame_ResumeOutAnimation(frame:GetParent());
	GameTooltip:Hide();
end

-- [[ ChallengeModeAlertFrame ]] --
CHALLENGE_MODE_MAX_REWARDS = 1;
function ChallengeModeAlertFrame_ShowAlert()
	PlaySound("LFG_Rewards");
	local frame = ChallengeModeAlertFrame1;
	--For now we only have 1 challenge mode alert frame
	local mapID, medal, completionTime, moneyAmount, numRewards = GetChallengeModeCompletionInfo();
	frame.mapID = mapID;

	--Set up the rewards
	local rewardsOffset = 0;

	if ( moneyAmount > 0 ) then
		SetPortraitToTexture(frame.reward1.texture, "Interface\\Icons\\inv_misc_coin_02");
		frame.reward1.itemID = 0;
		frame.reward1:Show();
		rewardsOffset = 1;
	end

	for i = 1, numRewards do
		local frameID = (i + rewardsOffset);
		local reward = _G["ChallengeModeAlertFrame1Reward"..frameID];
		if ( not reward ) then
			reward = CreateFrame("FRAME", "ChallengeModeAlertFrame1Reward"..frameID, ChallengeModeAlertFrame1, "ChallengeModeAlertFrameRewardTemplate");
			CHALLENGE_MODE_MAX_REWARDS = frameID;
		end
		ChallengeModeAlertFrameReward_SetReward(reward, i);
	end

	local usedButtons = numRewards + rewardsOffset;
	--Hide the unused ones
	for i = usedButtons + 1, CHALLENGE_MODE_MAX_REWARDS do
		_G["ChallengeModeAlertFrame1Reward"..i]:Hide();
	end

	if ( usedButtons > 0 ) then
		--Set up positions
		local spacing = 36;
		frame.reward1:SetPoint("TOP", frame, "TOP", -spacing/2 * usedButtons + 41, 10);
		for i = 2, usedButtons do
			_G["ChallengeModeAlertFrame1Reward"..i]:SetPoint("CENTER", "ChallengeModeAlertFrame1Reward"..(i - 1), "CENTER", spacing, 0);
		end
	end
	--Set up the text and icon
	if ( CHALLENGE_MEDAL_TEXTURES[medal] ) then
		frame.medalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES[medal]);
		frame.medalIcon:Show();
	else
		frame.medalIcon:Hide();
	end
	frame.time:SetText(GetTimeStringFromSeconds(completionTime, true));
	frame.dungeonTexture:SetTexture("Interface\\Icons\\achievement_bg_wineos_underxminutes");

	AlertFrame_AnimateIn(frame)
	AlertFrame_FixAnchors();
end

-- [[ ScenarioAlertFrame ]] --
SCENARIO_MAX_REWARDS = 1;
function ScenarioAlertFrame_ShowAlert()
	PlaySound("UI_Scenario_Ending");
	local frame = ScenarioAlertFrame1;
	--For now we only have 1 scenario alert frame
	local name, typeID, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards = GetLFGCompletionReward();
	
	-- bonus?
	local _, _, _, _, hasBonusStep, isBonusStepComplete = C_Scenario.GetInfo();
	if ( hasBonusStep and isBonusStepComplete ) then
		frame.BonusStar:Show();
	else
		frame.BonusStar:Hide();
	end

	--Set up the rewards
	local moneyAmount = moneyBase + moneyVar * numStrangers;
	local experienceGained = experienceBase + experienceVar * numStrangers;

	local rewardsOffset = 0;

	if ( moneyAmount > 0 or experienceGained > 0 ) then --hasMiscReward ) then
		SetPortraitToTexture(frame.reward1.texture, "Interface\\Icons\\inv_misc_coin_02");
		frame.reward1.rewardID = 0;
		frame.reward1:Show();

		rewardsOffset = 1;
	end

	for i = 1, numRewards do
		local frameID = (i + rewardsOffset);
		local reward = _G["ScenarioAlertFrame1Reward"..frameID];
		if ( not reward ) then
			reward = CreateFrame("FRAME", "ScenarioAlertFrame1Reward"..frameID, ChallengeModeAlertFrame1, "DungeonCompletionAlertFrameRewardTemplate");
			SCENARIO_MAX_REWARDS = frameID;
		end
		DungeonCompletionAlertFrameReward_SetReward(reward, i);
	end

	local usedButtons = numRewards + rewardsOffset;
	--Hide the unused ones
	for i = usedButtons + 1, SCENARIO_MAX_REWARDS do
		_G["ScenarioAlertFrame1Reward"..i]:Hide();
	end

	if ( usedButtons > 0 ) then
		--Set up positions
		local spacing = 36;
		frame.reward1:SetPoint("TOP", frame, "TOP", -spacing/2 * usedButtons + 41, 8);
		for i = 2, usedButtons do
			_G["ScenarioAlertFrame1Reward"..i]:SetPoint("CENTER", "ScenarioAlertFrame1Reward"..(i - 1), "CENTER", spacing, 0);
		end
	end

	--Set up the text and icon
	frame.dungeonName:SetText(name);
	frame.dungeonTexture:SetTexture("Interface\\LFGFrame\\LFGIcon-"..textureFilename);

	-- bonus objectives?
	local _, _, _, _, hasBonusStep, isBonusStepComplete = C_Scenario.GetInfo();
	if ( hasBonusStep and isBonusStepComplete ) then
	end

	AlertFrame_AnimateIn(frame)
	AlertFrame_FixAnchors();
end

-- [[ ChallengeModeAlertFrameReward ]] --
function ChallengeModeAlertFrameReward_SetReward(frame, index)
	local itemID, name, texturePath, quantity, isCurrency = GetChallengeModeCompletionReward(index);
	SetPortraitToTexture(frame.texture, texturePath);
	frame.itemID = itemID;
	frame.isCurrency = isCurrency;
	frame:Show();
end

function ChallengeModeAlertFrameReward_OnEnter(self)
	AlertFrame_StopOutAnimation(self:GetParent());

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( self.itemID == 0 ) then
		local _, _, _, moneyAmount = GetChallengeModeCompletionInfo();
		if ( moneyAmount > 0 ) then
			GameTooltip:AddLine(YOU_RECEIVED);
			SetTooltipMoney(GameTooltip, moneyAmount, nil);
		end
	elseif ( self.isCurrency ) then
		GameTooltip:SetCurrencyByID(self.itemID);
	else
		GameTooltip:SetItemByID(self.itemID);
	end
	GameTooltip:Show();
end

function ChallengeModeAlertFrameReward_OnLeave(frame)
	AlertFrame_ResumeOutAnimation(frame:GetParent());
	GameTooltip:Hide();
end

-- [[ AchievementAlertFrame ]] --
function AchievementAlertFrame_IsPaused()
	return C_PetBattles.IsInBattle();
end

function AchievementAlertFrame_FireDelayedAlerts()
	while ( #DELAYED_ACHIEVEMENT_ALERTS > 0 ) do
		if ( AchievementAlertFrame_ShowAlert(DELAYED_ACHIEVEMENT_ALERTS[1][ACHIEVEMENT_ID_INDEX], DELAYED_ACHIEVEMENT_ALERTS[1][OLD_ACHIEVEMENT_INDEX]) ) then
			table.remove(DELAYED_ACHIEVEMENT_ALERTS, 1);
		else
			break;
		end
	end
end

function AchievementAlertFrame_ShowAlert (achievementID, alreadyEarned)
	local frame = AchievementAlertFrame_GetAlertFrame();
	if ( AchievementAlertFrame_IsPaused() or not frame ) then
		-- Either we ran out of frames or we've paused alerts, so we have to queue this one.
		
		-- Make sure we haven't hit the cap for the number of queued achievemnts
		if ( #DELAYED_ACHIEVEMENT_ALERTS >= MAX_QUEUED_ACHIEVEMENT_TOASTS ) then
			return false;
		end
		
		-- Make sure this one isn't already queued.
		for i=1, #DELAYED_ACHIEVEMENT_ALERTS do
			if ( DELAYED_ACHIEVEMENT_ALERTS[i][ACHIEVEMENT_ID_INDEX] == achievementID ) then
				return false;
			end
		end

		-- Queue this one up.
		DELAYED_ACHIEVEMENT_ALERTS[#DELAYED_ACHIEVEMENT_ALERTS + 1] = {achievementID, alreadyEarned};
		return false;
	end

	AchievementAlertFrame_SetUp(frame, achievementID, alreadyEarned);

	AlertFrame_AnimateIn(frame);
	
	AlertFrame_FixAnchors();

	return true;
end
	
function AchievementAlertFrame_SetUp(frame, achievementID, alreadyEarned)
	local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID);
	
	
	local frameName = frame:GetName();
	local displayName = _G[frameName.."Name"];
	local shieldPoints = _G[frameName.."ShieldPoints"];
	local shieldIcon = _G[frameName.."ShieldIcon"];
	local unlocked = _G[frameName.."Unlocked"];
	local oldCheevo = _G[frameName.."OldAchievement"];
	
	displayName:SetText(name);

	AchievementShield_SetPoints(points, shieldPoints, GameFontNormal, GameFontNormalSmall);
	
	if ( isGuildAch ) then
		local guildName = _G[frameName.."GuildName"];
		local guildBorder = _G[frameName.."GuildBorder"];
		local guildBanner = _G[frameName.."GuildBanner"];
		if ( not frame.guildDisplay or frame.oldCheevo) then
			frame.oldCheevo = nil
			shieldPoints:Show();
			shieldIcon:Show();
			oldCheevo:Hide();
			frame.guildDisplay = true;
			frame:SetHeight(104);
			local background = _G[frameName.."Background"];
			background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
			background:SetTexCoord(0.00195313, 0.62890625, 0.00195313, 0.19140625);
			background:SetPoint("TOPLEFT", -2, 2);
			background:SetPoint("BOTTOMRIGHT", 8, 8);
			local iconBorder = _G[frameName.."IconOverlay"];
			iconBorder:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
			iconBorder:SetTexCoord(0.25976563,0.40820313,0.50000000,0.64453125);
			iconBorder:SetPoint("CENTER", 0, 1);
			_G[frameName.."Icon"]:SetPoint("TOPLEFT", -26, 2);
			displayName:SetPoint("BOTTOMLEFT", 79, 37);
			displayName:SetPoint("BOTTOMRIGHT", -79, 37);
			_G[frameName.."Shield"]:SetPoint("TOPRIGHT", -15, -28);
			shieldPoints:SetPoint("CENTER", 7, 5);
			shieldPoints:SetVertexColor(0, 1, 0);
			shieldIcon:SetTexCoord(0, 0.5, 0.5, 1);
			unlocked:SetPoint("TOP", -1, -36);
			unlocked:SetText(GUILD_ACHIEVEMENT_UNLOCKED);
			guildName:Show();
			guildBanner:Show();
			guildBorder:Show();
			frame.glow:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
			frame.glow:SetTexCoord(0.00195313, 0.74804688, 0.19531250, 0.49609375);
			frame.shine:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
			frame.shine:SetTexCoord(0.75195313, 0.91601563, 0.19531250, 0.35937500);
			frame.shine:SetPoint("BOTTOMLEFT", 0, 16);
		end
		guildName:SetText(GetGuildInfo("player"));
		SetSmallGuildTabardTextures("player", nil, guildBanner, guildBorder);
	else
		if ( frame.guildDisplay  or frame.oldCheevo) then
			frame.oldCheevo = nil
			shieldPoints:Show();
			shieldIcon:Show();
			oldCheevo:Hide();
			frame.guildDisplay = nil;
			frame:SetHeight(88);
			local background = _G[frameName.."Background"];
			background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background");
			background:SetTexCoord(0, 0.605, 0, 0.703);
			background:SetPoint("TOPLEFT", 0, 0);
			background:SetPoint("BOTTOMRIGHT", 0, 0);
			local iconBorder = _G[frameName.."IconOverlay"];
			iconBorder:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame");
			iconBorder:SetTexCoord(0, 0.5625, 0, 0.5625);
			iconBorder:SetPoint("CENTER", -1, 2);
			_G[frameName.."Icon"]:SetPoint("TOPLEFT", -26, 16);
			displayName:SetPoint("BOTTOMLEFT", 72, 36);
			displayName:SetPoint("BOTTOMRIGHT", -60, 36);
			_G[frameName.."Shield"]:SetPoint("TOPRIGHT", -10, -13);
			shieldPoints:SetPoint("CENTER", 7, 2);
			shieldPoints:SetVertexColor(1, 1, 1);
			shieldIcon:SetTexCoord(0, 0.5, 0, 0.45);
			unlocked:SetPoint("TOP", 7, -23);
			unlocked:SetText(ACHIEVEMENT_UNLOCKED);
			_G[frameName.."GuildName"]:Hide();
			_G[frameName.."GuildBorder"]:Hide();
			_G[frameName.."GuildBanner"]:Hide();
			frame.glow:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow");
			frame.glow:SetTexCoord(0, 0.78125, 0, 0.66796875);
			frame.shine:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow");
			frame.shine:SetTexCoord(0.78125, 0.912109375, 0, 0.28125);
			frame.shine:SetPoint("BOTTOMLEFT", 0, 8);
		end
		
		if (alreadyEarned) then
			frame.oldCheevo = true;
			shieldPoints:Hide();
			shieldIcon:Hide();
			oldCheevo:Show();
			displayName:SetPoint("BOTTOMLEFT", 72, 37);
			displayName:SetPoint("BOTTOMRIGHT", -25, 37);
			unlocked:SetPoint("TOP", 21, -23);
		end	
	end
	
	if ( points == 0 ) then
		shieldIcon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
	else
		shieldIcon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
	end
	
	_G[frameName.."IconTexture"]:SetTexture(icon);
	
	frame.id = achievementID;
	return true;
end

function AchievementAlertFrame_GetAlertFrame()
	local name, frame, previousFrame;
	for i=1, MAX_ACHIEVEMENT_ALERTS do
		name = "AchievementAlertFrame"..i;
		frame = _G[name];
		if ( frame ) then
			if ( not frame:IsShown() ) then
				return frame;
			end
		else
			frame = CreateFrame("Button", name, UIParent, "AchievementAlertFrameTemplate");
			if ( not previousFrame ) then
				frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 128);
			else
				frame:SetPoint("BOTTOM", previousFrame, "TOP", 0, -10);
			end
			return frame;
		end
		previousFrame = frame;
	end
	return nil;
end

function CriteriaAlertFrame_ShowAlert (achievementID, criteriaID)
	local frame = CriteriaAlertFrame_GetAlertFrame();
	if ( not frame ) then
		-- We ran out of frames! Bail!
		return;
	end
	
	local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch = GetAchievementInfo(achievementID);
	local criteriaString = GetAchievementCriteriaInfoByID(achievementID, criteriaID);
	
	local frameName = frame:GetName();
	local displayName = _G[frameName.."Name"];
	
	displayName:SetText(criteriaString);
	
	_G[frameName.."IconTexture"]:SetTexture(icon);
	
	frame.id = achievementID;
	
	AlertFrame_AnimateIn(frame);
	
	AlertFrame_FixAnchors();
end

function CriteriaAlertFrame_GetAlertFrame()
	local name, frame, previousFrame;
	for i=1, MAX_ACHIEVEMENT_ALERTS do
		name = "CriteriaAlertFrame"..i;
		frame = _G[name];
		if ( frame ) then
			if ( not frame:IsShown() ) then
				return frame;
			end
		else
			frame = CreateFrame("Button", name, UIParent, "CriteriaAlertFrameTemplate");
			if ( not previousFrame ) then
				frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 128);
			else
				frame:SetPoint("BOTTOM", previousFrame, "TOP", 0, -10);
			end
			return frame;
		end
		previousFrame = frame;
	end
	return nil;
end

function AchievementAlertFrame_OnClick (self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end
	
	local id = self.id;
	if ( not id ) then
		return;
	end
	
	CloseAllWindows();
	ShowUIPanel(AchievementFrame);
	
	local _, _, _, achCompleted = GetAchievementInfo(id);
	if ( achCompleted and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_INCOMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
	elseif ( (not achCompleted) and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_COMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
	end
	
	AchievementFrame_SelectAchievement(id)
end

-- [[ LootAlertFrame shared ]] --
function LootAlertFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetHyperlink(self.hyperlink);
	GameTooltip:Show();
end

-- [[ LootWonAlertFrameTemplate ]] --
LOOTWONALERTFRAME_VALUES={
	Default = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=5, labelText=YOU_WON_LABEL, glowAtlas="loottoast-glow"},
	GarrisonCache = { bgOffsetX=-4, bgOffsetY=0, labelOffsetX=7, labelOffsetY=1, labelText=GARRISON_CACHE, glowAtlas="CacheToast-Glow", bgAtlas="CacheToast", noIconBorder=true, iconUnderBG=true},
	Horde = { bgOffsetX=-1, bgOffsetY=-1, labelOffsetX=7, labelOffsetY=3, labelText=YOU_EARNED_LABEL, pvpAtlas="loottoast-bg-horde", glowAtlas="loottoast-glow"},
	Alliance = { bgOffsetX=-1, bgOffsetY=-1, labelOffsetX=7, labelOffsetY=3, labelText=YOU_EARNED_LABEL, pvpAtlas="loottoast-bg-alliance", glowAtlas="loottoast-glow"},
}
function LootWonAlertFrame_ShowAlert(itemLink, quantity, rollType, roll, specID, isCurrency, showFactionBG, lootSource)
	local frame;
	for i=1, #LOOT_WON_ALERT_FRAMES do
		local lootWon = LOOT_WON_ALERT_FRAMES[i];
		if ( not lootWon:IsShown() ) then
			frame = lootWon;
			break;
		end
	end

	if ( not frame ) then
		frame = CreateFrame("Button", nil, UIParent, "LootWonAlertFrameTemplate");
		table.insert(LOOT_WON_ALERT_FRAMES, frame);
	end

	LootWonAlertFrame_SetUp(frame, itemLink, quantity, rollType, roll, specID, isCurrency, showFactionBG, lootSource);
	AlertFrame_AnimateIn(frame);
	AlertFrame_FixAnchors();
end

local LOOT_SOURCE_GARRISON_CACHE = 10;

-- NOTE - This may also be called for an externally created frame. (E.g. bonus roll has its own frame)
function LootWonAlertFrame_SetUp(self, itemLink, quantity, rollType, roll, specID, isCurrency, showFactionBG, lootSource)
	local itemName, itemHyperLink, itemRarity, itemTexture;
	if (isCurrency == true) then
		itemName, _, itemTexture, _, _, _, _, itemRarity = GetCurrencyInfo(itemLink);
		if ( lootSource == LOOT_SOURCE_GARRISON_CACHE ) then
			itemName = format(GARRISON_RESOURCES_LOOT, quantity);
		else
			itemName = format(CURRENCY_QUANTITY_TEMPLATE, quantity, itemName);
		end
		itemHyperLink = itemLink;		
	else
		itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
	end

	local windowInfo = LOOTWONALERTFRAME_VALUES.Default;
	if( showFactionBG ) then
		local factionGroup = UnitFactionGroup("player");
		windowInfo = LOOTWONALERTFRAME_VALUES[factionGroup]
		self.PvPBackground:SetAtlas(windowInfo.pvpAtlas, true);
		self.PvPBackground:SetPoint("CENTER", windowInfo.bgOffsetX, windowInfo.bgOffsetY);
		self.Background:Hide();
		self.BGAtlas:Hide();
		self.PvPBackground:Show();	
	else
		if ( lootSource == LOOT_SOURCE_GARRISON_CACHE ) then
			windowInfo = LOOTWONALERTFRAME_VALUES["GarrisonCache"];
		end
		if ( windowInfo.bgAtlas ) then
			self.Background:Hide();
			self.BGAtlas:Show();
			self.BGAtlas:SetAtlas(windowInfo.bgAtlas);
			self.BGAtlas:SetPoint("CENTER", windowInfo.bgOffsetX, windowInfo.bgOffsetY);
		else
			self.Background:SetPoint("CENTER", windowInfo.bgOffsetX, windowInfo.bgOffsetY);
			self.Background:Show();
			self.BGAtlas:Hide();
		end
		self.PvPBackground:Hide();
	end
	self.glow:SetAtlas(windowInfo.glowAtlas);
	self.IconBorder:SetShown(not windowInfo.noIconBorder);
	if ( windowInfo.iconUnderBG ) then
		self.Icon:SetDrawLayer("BACKGROUND");
	else
		self.Icon:SetDrawLayer("BORDER");
	end

	self.Label:SetText(windowInfo.labelText);	
	self.Label:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", windowInfo.labelOffsetX, windowInfo.labelOffsetY);
	
	self.isCurrency = isCurrency;

	self.Icon:SetTexture(itemTexture);
	self.ItemName:SetText(itemName);
	local color = ITEM_QUALITY_COLORS[itemRarity];
	self.ItemName:SetVertexColor(color.r, color.g, color.b);
	self.IconBorder:SetTexCoord(unpack(LOOT_BORDER_QUALITY_COORDS[itemRarity] or LOOT_BORDER_QUALITY_COORDS[LE_ITEM_QUALITY_UNCOMMON]));
	if ( specID and specID > 0 and not isCurrency ) then
		local id, name, description, texture, background, role, class = GetSpecializationInfoByID(specID);
		self.SpecIcon:SetTexture(texture);
		self.SpecIcon:Show();
		self.SpecRing:Show();
	else
		self.SpecIcon:Hide();
		self.SpecRing:Hide();
	end

	if ( rollType == LOOT_ROLL_TYPE_NEED ) then
		self.RollTypeIcon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up");
		self.RollValue:SetText(roll);
		self.RollTypeIcon:Show();
		self.RollValue:Show();
	elseif ( rollType == LOOT_ROLL_TYPE_GREED ) then
		self.RollTypeIcon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up");
		self.RollValue:SetText(roll);
		self.RollTypeIcon:Show();
		self.RollValue:Show();
	else
		self.RollTypeIcon:Hide();
		self.RollValue:Hide();
	end

	self.hyperlink = itemHyperLink;
	PlaySoundKitID(31578);	--UI_EpicLoot_Toast
end

function LootWonAlertFrame_OnClick(self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end
	if (self.isCurrency) then 
		return;
	end
	local itemID = GetItemInfoFromHyperlink(self.hyperlink);
	local slot = SearchBagsForItem(itemID);
	if (slot >= 0) then
		OpenBag(slot);
	end
end

-- [[ LootUpgradeFrameTemplate ]] --
LOOTUPGRADEFRAME_QUALITY_TEXTURES = {
	[LE_ITEM_QUALITY_UNCOMMON]	= {border = "loottoast-itemborder-green",	arrow = "loottoast-arrow-green"},
	[LE_ITEM_QUALITY_RARE]		= {border = "loottoast-itemborder-blue",	arrow = "loottoast-arrow-blue"},
	[LE_ITEM_QUALITY_EPIC]		= {border = "loottoast-itemborder-purple",	arrow = "loottoast-arrow-purple"},
	[LE_ITEM_QUALITY_LEGENDARY]	= {border = "loottoast-itemborder-orange",	arrow = "loottoast-arrow-orange"},
}
function LootUpgradeFrame_ShowAlert(itemLink, quantity, specID, baseQuality)
	local frame;
	for i=1, #LOOT_UPGRADE_ALERT_FRAMES do
		local lootFrame = LOOT_UPGRADE_ALERT_FRAMES[i];
		if ( not lootFrame:IsShown() ) then
			frame = lootFrame;
			break;
		end
	end

	if ( not frame ) then
		frame = CreateFrame("Button", nil, UIParent, "LootUpgradeFrameTemplate");
		table.insert(LOOT_UPGRADE_ALERT_FRAMES, frame);
	end

	LootUpgradeFrame_SetUp(frame, itemLink, quantity, specID, baseQuality);
	AlertFrame_AnimateIn(frame);
	AlertFrame_FixAnchors();
end

function LootUpgradeFrame_SetUp(self, itemLink, quantity, specID, baseQuality)
	local itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
	local baseQualityColor = ITEM_QUALITY_COLORS[baseQuality];
	local upgradeQualityColor = ITEM_QUALITY_COLORS[itemRarity];
	
	self.Icon:SetTexture(itemTexture);
	self.BaseQualityItemName:SetText(itemName);
	self.BaseQualityItemName:SetTextColor(baseQualityColor.r, baseQualityColor.g, baseQualityColor.b);
	self.UpgradeQualityItemName:SetText(itemName);
	self.UpgradeQualityItemName:SetTextColor(upgradeQualityColor.r, upgradeQualityColor.g, upgradeQualityColor.b);
	self.WhiteText:SetText(itemName);
	self.WhiteText2:SetText(itemName);
	self.TitleText:SetText(format(LOOTUPGRADEFRAME_TITLE, _G["ITEM_QUALITY"..itemRarity.."_DESC"]));
	self.TitleText:SetTextColor(upgradeQualityColor.r, upgradeQualityColor.g, upgradeQualityColor.b);
	
	local baseTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[baseQuality] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[LE_ITEM_QUALITY_UNCOMMON];
	local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[itemRarity] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[LE_ITEM_QUALITY_UNCOMMON];
	self.BaseQualityBorder:SetAtlas(baseTexture.border, true);
	self.UpgradeQualityBorder:SetAtlas(upgradeTexture.border, true);
	
	for i = 1, self.numArrows do
		self["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true);
	end

	self.hyperlink = itemHyperLink;
	PlaySoundKitID(31578);	--UI_EpicLoot_Toast
end

function LootUpgradeFrame_OnClick(self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end
	local bag = SearchBagsForItemLink(self.hyperlink);
	if (bag >= 0) then
		OpenBag(bag);
	end
end

function LootUpgradeFrame_AnimDone(self)
	self:GetParent().animIn:Stop();
	self:GetParent():Hide();
end

-- [[ MoneyWonAlertFrameTemplate ]] --

function MoneyWonAlertFrame_ShowAlert(amount)
	local frame;
	for i=1, #MONEY_WON_ALERT_FRAMES do
		local moneyWon = MONEY_WON_ALERT_FRAMES[i];
		if ( not moneyWon:IsShown() ) then
			frame = moneyWon;
			break;
		end
	end
	
	if ( not frame ) then
		frame = CreateFrame("Button", nil, UIParent, "MoneyWonAlertFrameTemplate");
		table.insert(MONEY_WON_ALERT_FRAMES, frame);
	end

	MoneyWonAlertFrame_SetUp(frame, amount);
	AlertFrame_AnimateIn(frame);
	AlertFrame_FixAnchors();
end

function MoneyWonAlertFrame_SetUp(self, amount)
	self.Amount:SetText(GetMoneyString(amount));
	PlaySoundKitID(31578);	--UI_EpicLoot_Toast
end

-- [[ DigsiteCompleteToastFrame ]] --
function DigsiteCompleteToastFrame_ShowAlert(researchBranchID)
	local RaceName, RaceTexture	= GetArchaeologyRaceInfoByID(researchBranchID);
	DigsiteCompleteToastFrame.DigsiteType:SetText(RaceName);
	DigsiteCompleteToastFrame.DigsiteTypeTexture:SetTexture(RaceTexture);
	PlaySound("UI_DigsiteCompletion_Toast");
	AlertFrame_AnimateIn(DigsiteCompleteToastFrame);
	AlertFrame_FixAnchors();
end

-- [[ StorePurchaseAlertFrame ]] --
function StorePurchaseAlertFrame_ShowAlert(icon, name, itemID)
	StorePurchaseAlertFrame.Icon:SetTexture(icon);
	StorePurchaseAlertFrame.Title:SetFontObject(GameFontNormalLarge);
	StorePurchaseAlertFrame.Title:SetText(name);
	StorePurchaseAlertFrame.itemID = itemID;
	if ( StorePurchaseAlertFrame.Title:IsTruncated() ) then
		StorePurchaseAlertFrame.Title:SetFontObject(GameFontNormal);
	end
	AlertFrame_AnimateIn(StorePurchaseAlertFrame);
	AlertFrame_FixAnchors();
	PlaySound("UI_igStore_PurchaseDelivered_Toast_01");
end

function StorePurchaseAlertFrame_OnClick(self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end
	local slot = SearchBagsForItem(self.itemID);
	if (slot >= 0) then
		OpenBag(slot);
	end
end

-- [[ GarrisonBuildingAlertFrame ]] --
function GarrisonBuildingAlertFrame_ShowAlert(name)
	GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Play();
	GarrisonBuildingAlertFrame.Name:SetFormattedText(GARRISON_BUILDING_COMPLETE_TOAST, name);
	AlertFrame_AnimateIn(GarrisonBuildingAlertFrame);
	AlertFrame_FixAnchors();
	PlaySound("UI_Garrison_Toast_BuildingComplete");
end

-- [[ GarrisonMissionAlertFrame ]] --
function GarrisonMissionAlertFrame_ShowAlert(missionID)
	GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Play();
	local missionInfo = C_Garrison.GetBasicMissionInfo(missionID);
	GarrisonMissionAlertFrame.Name:SetText(missionInfo.name);
	GarrisonMissionAlertFrame.MissionType:SetAtlas(missionInfo.typeAtlas);
	AlertFrame_AnimateIn(GarrisonMissionAlertFrame);
	AlertFrame_FixAnchors();
	PlaySound("UI_Garrison_Toast_MissionComplete");
end

-- [[ GarrisonRandomMissionAlertFrame ]] --
function GarrisonRandomMissionAlertFrame_ShowAlert(missionID)
	local missionInfo = C_Garrison.GetBasicMissionInfo(missionID);
	GarrisonRandomMissionAlertFrame.Level:SetText(missionInfo.level);
	GarrisonRandomMissionAlertFrame.ItemLevel:SetText("(" .. missionInfo.iLevel .. ")");
	if (missionInfo.iLevel ~= 0 and missionInfo.isRare) then
		GarrisonRandomMissionAlertFrame.Level:SetPoint("TOP", "$parent", "TOP", -115, -14);
		GarrisonRandomMissionAlertFrame.ItemLevel:SetPoint("TOP", "$parent", "TOP", -115, -37);
		GarrisonRandomMissionAlertFrame.Rare:SetPoint("TOP", "$parent", "TOP", -115, -48);
	elseif (missionInfo.isRare) then
		GarrisonRandomMissionAlertFrame.Level:SetPoint("TOP", "$parent", "TOP", -115, -19);
		GarrisonRandomMissionAlertFrame.Rare:SetPoint("TOP", "$parent", "TOP", -115, -45);
	elseif (missionInfo.iLevel ~= 0) then
		GarrisonRandomMissionAlertFrame.Level:SetPoint("TOP", "$parent", "TOP", -115, -19);
		GarrisonRandomMissionAlertFrame.ItemLevel:SetPoint("TOP", "$parent", "TOP", -115, -45);
	else
		GarrisonRandomMissionAlertFrame.Level:SetPoint("TOP", "$parent", "TOP", -115, -28);
	end

	GarrisonRandomMissionAlertFrame.ItemLevel:SetShown(missionInfo.iLevel ~= 0);
	GarrisonRandomMissionAlertFrame.Rare:SetShown(missionInfo.isRare);

	AlertFrame_AnimateIn(GarrisonRandomMissionAlertFrame);
	AlertFrame_FixAnchors();
	PlaySound("UI_Garrison_Toast_MissionComplete");
end

-- [[ GarrisonFollowerAlertFrame ]] --
GARRISON_FOLLOWER_QUALITY_TEXTURE_SUFFIXES = {
	[LE_ITEM_QUALITY_UNCOMMON] = "Uncommon",
	[LE_ITEM_QUALITY_EPIC] = "Epic",
	[LE_ITEM_QUALITY_RARE] = "Rare",
}
function GarrisonFollowerAlertFrame_ShowAlert(followerID, name, displayID, level, quality, isUpgraded)
	GarrisonFollowerAlertFrame.followerID = followerID;
	GarrisonFollowerAlertFrame.Name:SetText(name);
	local texSuffix = GARRISON_FOLLOWER_QUALITY_TEXTURE_SUFFIXES[quality]
	if (texSuffix) then
		GarrisonFollowerAlertFrame.FollowerBG:SetAtlas("Garr_FollowerToast-"..texSuffix, true);
		GarrisonFollowerAlertFrame.FollowerBG:Show();
	else
		GarrisonFollowerAlertFrame.FollowerBG:Hide();
	end
	SetPortraitTexture(GarrisonFollowerAlertFrame.PortraitFrame.Portrait, displayID);
	GarrisonFollowerAlertFrame.PortraitFrame.Level:SetText(level);
	local color = BAG_ITEM_QUALITY_COLORS[quality];
	if (color) then
		GarrisonFollowerAlertFrame.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
		GarrisonFollowerAlertFrame.PortraitFrame.PortraitRingQuality:SetVertexColor(color.r, color.g, color.b);
	else
		GarrisonFollowerAlertFrame.PortraitFrame.LevelBorder:SetVertexColor(1, 1, 1);
		GarrisonFollowerAlertFrame.PortraitFrame.PortraitRingQuality:SetVertexColor(1, 1, 1);
	end
	
	GarrisonFollowerAlertFrame.ArrowsAnim:Stop();	
	if ( isUpgraded ) then
		local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[LE_ITEM_QUALITY_UNCOMMON];
		for i = 1, GarrisonFollowerAlertFrame.Arrows.numArrows do
			GarrisonFollowerAlertFrame.Arrows["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true);
		end
		GarrisonFollowerAlertFrame.Title:SetText(GARRISON_FOLLOWER_ADDED_UPGRADED_TOAST);
		GarrisonFollowerAlertFrame.DieIcon:Show();
		GarrisonFollowerAlertFrame.ArrowsAnim:Play();
	else
		GarrisonFollowerAlertFrame.Title:SetText(GARRISON_FOLLOWER_ADDED_TOAST);
		GarrisonFollowerAlertFrame.DieIcon:Hide();
	end

	AlertFrame_AnimateIn(GarrisonFollowerAlertFrame);
	
	AlertFrame_FixAnchors();
	PlaySound("UI_Garrison_Toast_FollowerGained");
end

function GarrisonFollowerAlertFrame_OnEnter(self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end
	AlertFrame_StopOutAnimation(self);
	
	local link = C_Garrison.GetFollowerLink(self.followerID);
	if ( link ) then
		GarrisonFollowerTooltip:ClearAllPoints();
		GarrisonFollowerTooltip:SetPoint("BOTTOM", self, "TOP");
		local _, garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4 = strsplit(":", link);
		GarrisonFollowerTooltip_Show(tonumber(garrisonFollowerID), false, tonumber(quality), tonumber(level), 0, 0, tonumber(itemLevel), tonumber(ability1), tonumber(ability2), tonumber(ability3), tonumber(ability4), tonumber(trait1), tonumber(trait2), tonumber(trait3), tonumber(trait4));
	end
end

function GarrisonFollowerAlertFrame_OnLeave(self)
	GarrisonFollowerTooltip:Hide();
	AlertFrame_ResumeOutAnimation(self);
end

function GarrisonAlertFrame_OnClick(self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end
	self:Hide();
	if (not GarrisonLandingPage) then
		Garrison_LoadUI();
	end
	ShowUIPanel(GarrisonLandingPage);
end
