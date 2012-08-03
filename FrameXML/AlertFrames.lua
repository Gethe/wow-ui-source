MAX_ACHIEVEMENT_ALERTS = 2;
LOOT_WON_ALERT_FRAMES = {};
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
	self:RegisterEvent("PET_BATTLE_CLOSE");
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
		if ( C_Scenario.IsInScenario() ) then
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
		local typeIdentifier, itemLink, quantity = ...;
		if ( typeIdentifier == "item" ) then
			LootWonAlertFrame_ShowAlert(itemLink, quantity);
		elseif ( typeIdentifier == "money" ) then
			MoneyWonAlertFrame_ShowAlert(quantity);
		end
	elseif ( event == "PET_BATTLE_CLOSE" ) then
		AchievementAlertFrame_FireDelayedAlerts();
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

function AlertFrame_StopOutAnimation(frame)
	frame.waitAndAnimOut:Stop();
	frame.waitAndAnimOut.animOut:SetStartDelay(1);
end

function AlertFrame_ResumeOutAnimation(frame)
	frame.waitAndAnimOut:Play();
end

-- [[ Anchoring ]] --
function AlertFrame_FixAnchors()
	local alertAnchor = AlertFrame;
	alertAnchor = AlertFrame_SetLootAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetLootWonAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetMoneyWonAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetAchievementAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetCriteriaAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetChallengeModeAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetDungeonCompletionAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetScenarioAnchors(alertAnchor);
	alertAnchor = AlertFrame_SetGuildChallengeAnchors(alertAnchor);
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

-- [[ GuildChallengeAlertFrame ]] --
function GuildChallengeAlertFrame_ShowAlert(...)
	local challengeType, count, max = ...;
	GuildChallengeAlertFrameType:SetText(_G["GUILD_CHALLENGE_TYPE"..challengeType]);
	GuildChallengeAlertFrameCount:SetFormattedText(GUILD_CHALLENGE_PROGRESS_FORMAT, count, max);
	SetLargeGuildTabardTextures("player", GuildChallengeAlertFrameEmblemIcon, GuildChallengeAlertFrameEmblemBackground, GuildChallengeAlertFrameEmblemBorder);
	AlertFrame_AnimateIn(GuildChallengeAlertFrame);
	AlertFrame_FixAnchors();
end

function GuildChallengeAlertFrame_OnClick(self)
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

	AlertFrame_AnimateIn(frame)
	AlertFrame_FixAnchors();
end

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
function AchievementAlertFrame_OnLoad (self)
	self:RegisterForClicks("LeftButtonUp");
end

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
	
	AlertFrame_AnimateIn(frame);
	
	AlertFrame_FixAnchors();

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

function AchievementAlertFrame_OnClick (self)
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

-- [[ LootWonAlertFrameTemplate ]] --

function LootWonAlertFrame_ShowAlert(itemLink, quantity, rollType, roll)
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

	LootWonAlertFrame_SetUp(frame, itemLink, quantity, rollType, roll);
	AlertFrame_AnimateIn(frame);
	AlertFrame_FixAnchors();
end

-- NOTE - This may also be called for an externally created frame. (E.g. bonus roll has its own frame)
function LootWonAlertFrame_SetUp(self, itemLink, quantity, rollType, roll)
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink);
	self.Icon:SetTexture(itemTexture);
	self.ItemName:SetText(itemName);
	local color = ITEM_QUALITY_COLORS[itemRarity];
	self.ItemName:SetVertexColor(color.r, color.g, color.b);
	self.IconBorder:SetTexCoord(unpack(LOOT_BORDER_QUALITY_COORDS[itemRarity] or LOOT_BORDER_QUALITY_COORDS[ITEM_QUALITY_UNCOMMON]));

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

	self.hyperlink = itemLink;
	PlaySoundKitID(31578);	--UI_EpicLoot_Toast
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

