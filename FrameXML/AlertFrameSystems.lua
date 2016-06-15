-- [[ GuildChallengeAlertFrame ]] --
function GuildChallengeAlertFrame_SetUp(frame, challengeType, count, max)
	GuildChallengeAlertFrameType:SetText(_G["GUILD_CHALLENGE_TYPE"..challengeType]);
	GuildChallengeAlertFrameCount:SetFormattedText(GUILD_CHALLENGE_PROGRESS_FORMAT, count, max);
	SetLargeGuildTabardTextures("player", GuildChallengeAlertFrameEmblemIcon, GuildChallengeAlertFrameEmblemBackground, GuildChallengeAlertFrameEmblemBorder);
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

GuildChallengeAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GuildChallengeAlertFrame, GuildChallengeAlertFrame_SetUp);

-- [[ DungeonCompletionAlertFrame ]] --
function DungeonCompletionAlertFrame_OnLoad(self)
	self.glow = self.glowFrame.glow;
end

DUNGEON_COMPLETION_MAX_REWARDS = 1;
function DungeonCompletionAlertFrame_SetUp(frame)
	PlaySound("LFG_Rewards");
	--For now we only have 1 dungeon alert frame. If you're completing more than one dungeon within ~5 seconds, tough luck.
	local name, typeID, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards = GetLFGCompletionReward();
	
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
		SetPortraitToTexture(DungeonCompletionAlertFrameReward1.texture, "Interface\\Icons\\inv_misc_coin_02");
		DungeonCompletionAlertFrameReward1.rewardID = 0;
		DungeonCompletionAlertFrameReward1:Show();

		rewardsOffset = 1;
	end
	
	for i = 1, numRewards do
		local frameID = (i + rewardsOffset);
		local reward = _G["DungeonCompletionAlertFrameReward"..frameID];
		if ( not reward ) then
			reward = CreateFrame("FRAME", "DungeonCompletionAlertFrameReward"..frameID, DungeonCompletionAlertFrame, "DungeonCompletionAlertFrameRewardTemplate");
			reward:SetID(frameID);
			DUNGEON_COMPLETION_MAX_REWARDS = frameID;
		end
		DungeonCompletionAlertFrameReward_SetReward(reward, i);
	end
	
	local usedButtons = numRewards + rewardsOffset;
	--Hide the unused ones
	for i = usedButtons + 1, DUNGEON_COMPLETION_MAX_REWARDS do
		_G["DungeonCompletionAlertFrameReward"..i]:Hide();
	end
	
	if ( usedButtons > 0 ) then
		--Set up positions
		local spacing = 36;
		DungeonCompletionAlertFrameReward1:SetPoint("TOP", DungeonCompletionAlertFrame, "TOP", -spacing/2 * usedButtons + 41, 0);
		for i = 2, usedButtons do
			_G["DungeonCompletionAlertFrameReward"..i]:SetPoint("CENTER", "DungeonCompletionAlertFrameReward"..(i - 1), "CENTER", spacing, 0);
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

DungeonCompletionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(DungeonCompletionAlertFrame, DungeonCompletionAlertFrame_SetUp);

-- [[ ScenarioAlertFrame ]] --
SCENARIO_MAX_REWARDS = 1;
function ScenarioAlertFrame_SetUp(frame)
	PlaySound("UI_Scenario_Ending");
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
		local reward = _G["ScenarioAlertFrameReward"..frameID];
		if ( not reward ) then
			reward = CreateFrame("FRAME", "ScenarioAlertFrameReward"..frameID, ScenarioAlertFrame, "DungeonCompletionAlertFrameRewardTemplate");
			SCENARIO_MAX_REWARDS = frameID;
		end
		DungeonCompletionAlertFrameReward_SetReward(reward, i);
	end

	local usedButtons = numRewards + rewardsOffset;
	--Hide the unused ones
	for i = usedButtons + 1, SCENARIO_MAX_REWARDS do
		_G["ScenarioAlertFrameReward"..i]:Hide();
	end

	if ( usedButtons > 0 ) then
		--Set up positions
		local spacing = 36;
		frame.reward1:SetPoint("TOP", frame, "TOP", -spacing/2 * usedButtons + 41, 8);
		for i = 2, usedButtons do
			_G["ScenarioAlertFrameReward"..i]:SetPoint("CENTER", "ScenarioAlertFrameReward"..(i - 1), "CENTER", spacing, 0);
		end
	end

	--Set up the text and icon
	frame.dungeonName:SetText(name);
	frame.dungeonTexture:SetTexture("Interface\\LFGFrame\\LFGIcon-"..textureFilename);
end

ScenarioAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(ScenarioAlertFrame, ScenarioAlertFrame_SetUp);

-- [[ScenarioLegionInvasionAlertFrame ]] --
function ScenarioLegionInvasionAlertFrame_SetUp(frame)
	PlaySound("UI_Scenario_Ending");

	local scenarioName, currentStage, numStages, flags, hasBonusStep, isBonusStepComplete, _, xp, money, scenarioType, areaName = C_Scenario.GetInfo();
	local rewardName, rewardTexture, rewardItemID = C_Scenario.GetScenarioLastStepRewardInfo();

	frame.ZoneName:SetText(areaName or scenarioName);
	frame.BonusStar:SetShown(hasBonusStep and isBonusStepComplete);

	local numUsedRewardFrames = 0;
	if money > 0 then
		local rewardFrame = frame.RewardFrames and frame.RewardFrames[i] or CreateFrame("FRAME", nil, frame, "InvasionAlertFrameRewardTemplate");

		SetPortraitToTexture(rewardFrame.texture, "Interface\\Icons\\inv_misc_coin_02");
		rewardFrame.itemID = nil;
		rewardFrame.money = money;
		rewardFrame.xp = nil;
		rewardFrame:Show();

		numUsedRewardFrames = numUsedRewardFrames + 1;
	end

	if xp > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL then
		local rewardFrame = frame.RewardFrames and frame.RewardFrames[i] or CreateFrame("FRAME", nil, frame, "InvasionAlertFrameRewardTemplate");

		SetPortraitToTexture(rewardFrame.texture, "Interface\\Icons\\xp_icon");
		rewardFrame.itemID = nil;
		rewardFrame.money = nil;
		rewardFrame.xp = xp;
		rewardFrame:Show();

		numUsedRewardFrames = numUsedRewardFrames + 1;
	end

	if rewardItemID then
		local rewardFrame = frame.RewardFrames and frame.RewardFrames[numUsedRewardFrames + 1] or CreateFrame("FRAME", nil, frame, "InvasionAlertFrameRewardTemplate");
		SetPortraitToTexture(rewardFrame.texture, rewardTexture);
		rewardFrame.itemID = rewardItemID;
		rewardFrame.money = nil;
		rewardFrame.xp = nil;
		rewardFrame:Show();

		numUsedRewardFrames = numUsedRewardFrames + 1;
	end

	if frame.RewardFrames then
		local SPACING = 36;
		for i = 1, numUsedRewardFrames do
			if frame.RewardFrames[i - 1] then
				frame.RewardFrames[i]:SetPoint("CENTER", frame.RewardFrames[i - 1], "CENTER", SPACING, 0);
			else
				frame.RewardFrames[i]:SetPoint("TOP", frame, "TOP", -SPACING / 2 * numUsedRewardFrames + 41, 8);
			end
		end

		for i = numUsedRewardFrames + 1, #frame.RewardFrames do
			frame.RewardFrames[i]:Hide();
		end
	end
end

function InvasionAlertFrameReward_OnEnter(self)
	AlertFrame_StopOutAnimation(self:GetParent());

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.itemID then
		GameTooltip:SetItemByID(self.itemID);
	elseif self.money then
		GameTooltip:AddLine(YOU_RECEIVED);
		SetTooltipMoney(GameTooltip, self.money, nil);
	elseif self.xp then
		GameTooltip:AddLine(YOU_RECEIVED);
		GameTooltip:AddLine(BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(self.xp), HIGHLIGHT_FONT_COLOR:GetRGB());
	end
	GameTooltip:Show();
end

InvasionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(ScenarioLegionInvasionAlertFrame, ScenarioLegionInvasionAlertFrame_SetUp);

-- [[ AchievementAlertFrame ]] --
function AchievementAlertFrame_SetUp(frame, achievementID, alreadyEarned)
	local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID);
	
	local displayName = frame.Name;
	local shieldPoints = frame.Shield.Points;
	local shieldIcon = frame.Shield.Icon;
	local unlocked = frame.Unlocked;
	local oldCheevo = frame.OldAchievement;
	
	displayName:SetText(name);

	AchievementShield_SetPoints(points, shieldPoints, GameFontNormal, GameFontNormalSmall);
	
	if ( isGuildAch ) then
		local guildName = frame.GuildName;
		local guildBorder = frame.GuildBorder;
		local guildBanner = frame.GuildBanner;
		if ( not frame.guildDisplay or frame.oldCheevo) then
			frame.oldCheevo = nil
			shieldPoints:Show();
			shieldIcon:Show();
			oldCheevo:Hide();
			frame.guildDisplay = true;
			frame:SetHeight(104);
			local background = frame.Background;
			background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
			background:SetTexCoord(0.00195313, 0.62890625, 0.00195313, 0.19140625);
			background:SetPoint("TOPLEFT", -2, 2);
			background:SetPoint("BOTTOMRIGHT", 8, 8);
			local iconBorder = frame.Icon.Overlay;
			iconBorder:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
			iconBorder:SetTexCoord(0.25976563,0.40820313,0.50000000,0.64453125);
			iconBorder:SetPoint("CENTER", 0, 1);
			frame.Icon:SetPoint("TOPLEFT", -26, 2);
			displayName:SetPoint("BOTTOMLEFT", 79, 37);
			displayName:SetPoint("BOTTOMRIGHT", -79, 37);
			frame.Shield:SetPoint("TOPRIGHT", -15, -28);
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
			local background = frame.Background;
			background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background");
			background:SetTexCoord(0, 0.605, 0, 0.703);
			background:SetPoint("TOPLEFT", 0, 0);
			background:SetPoint("BOTTOMRIGHT", 0, 0);
			local iconBorder = frame.Icon.Overlay;
			iconBorder:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame");
			iconBorder:SetTexCoord(0, 0.5625, 0, 0.5625);
			iconBorder:SetPoint("CENTER", -1, 2);
			frame.Icon:SetPoint("TOPLEFT", -26, 16);
			displayName:SetPoint("BOTTOMLEFT", 72, 36);
			displayName:SetPoint("BOTTOMRIGHT", -60, 36);
			frame.Shield:SetPoint("TOPRIGHT", -10, -13);
			shieldPoints:SetPoint("CENTER", 7, 2);
			shieldPoints:SetVertexColor(1, 1, 1);
			shieldIcon:SetTexCoord(0, 0.5, 0, 0.45);
			unlocked:SetPoint("TOP", 7, -23);
			unlocked:SetText(ACHIEVEMENT_UNLOCKED);
			frame.GuildName:Hide();
			frame.GuildBorder:Hide();
			frame.GuildBanner:Hide();
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
	
	frame.Icon.Texture:SetTexture(icon);
	
	frame.id = achievementID;
	return true;
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

AchievementAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("AchievementAlertFrameTemplate", AchievementAlertFrame_SetUp, 2, 6);
AchievementAlertSystem:SetCanShowMoreConditionFunc(function() return not C_PetBattles.IsInBattle() end);

-- [[ CriteriaAlertFrame ]] --
function CriteriaAlertFrame_SetUp(frame, achievementID, criteriaString)
	local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch = GetAchievementInfo(achievementID);
	
	frame.Name:SetText(criteriaString);
	frame.Icon.Texture:SetTexture(icon);
	
	frame.id = achievementID;
end

CriteriaAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("CriteriaAlertFrameTemplate", CriteriaAlertFrame_SetUp, 2, 0);

-- [[ LootAlertFrame shared ]] --
function LootAlertFrame_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetHyperlink(self.hyperlink);
	GameTooltip:Show();
end

local LOOT_SOURCE_GARRISON_CACHE = 10;

-- [[ LootUpgradeFrameTemplate ]] --
LOOTUPGRADEFRAME_QUALITY_TEXTURES = {
	[LE_ITEM_QUALITY_UNCOMMON]	= {border = "loottoast-itemborder-green",	arrow = "loottoast-arrow-green"},
	[LE_ITEM_QUALITY_RARE]		= {border = "loottoast-itemborder-blue",	arrow = "loottoast-arrow-blue"},
	[LE_ITEM_QUALITY_EPIC]		= {border = "loottoast-itemborder-purple",	arrow = "loottoast-arrow-purple"},
	[LE_ITEM_QUALITY_LEGENDARY]	= {border = "loottoast-itemborder-orange",	arrow = "loottoast-arrow-orange"},
}

-- [[ LootWonAlertFrameTemplate ]] --
LOOTWONALERTFRAME_VALUES={
	Default = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=5, labelText=YOU_WON_LABEL, glowAtlas="loottoast-glow"},
	DefaultPersonal = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=5, labelText=YOU_RECEIVED_LABEL, glowAtlas="loottoast-glow"},
	Upgraded = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=5, labelText=ITEM_UPGRADED_LABEL, bgAtlas="LootToast-MoreAwesome", glowAtlas="loottoast-glow"},
	LessAwesome = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=5, labelText=YOU_RECEIVED_LABEL, bgAtlas="LootToast-LessAwesome"},
	GarrisonCache = { bgOffsetX=-4, bgOffsetY=0, labelOffsetX=7, labelOffsetY=1, labelText=GARRISON_CACHE, glowAtlas="CacheToast-Glow", bgAtlas="CacheToast", noIconBorder=true, iconUnderBG=true},
	Horde = { bgOffsetX=-1, bgOffsetY=-1, labelOffsetX=7, labelOffsetY=3, labelText=YOU_EARNED_LABEL, pvpAtlas="loottoast-bg-horde", glowAtlas="loottoast-glow"},
	Alliance = { bgOffsetX=-1, bgOffsetY=-1, labelOffsetX=7, labelOffsetY=3, labelText=YOU_EARNED_LABEL, pvpAtlas="loottoast-bg-alliance", glowAtlas="loottoast-glow"},
}

-- NOTE - This may also be called for an externally created frame. (E.g. bonus roll has its own frame)
function LootWonAlertFrame_SetUp(self, itemLink, quantity, rollType, roll, specID, isCurrency, showFactionBG, lootSource, lessAwesome, isUpgraded, isPersonal)
	local itemName, itemHyperLink, itemRarity, itemTexture;
	if (isCurrency) then
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

	local windowInfo = isPersonal and LOOTWONALERTFRAME_VALUES.DefaultPersonal or LOOTWONALERTFRAME_VALUES.Default;
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
		elseif ( lessAwesome ) then
			windowInfo = LOOTWONALERTFRAME_VALUES["LessAwesome"];
		elseif ( isUpgraded ) then
			windowInfo = LOOTWONALERTFRAME_VALUES["Upgraded"];
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
	if windowInfo.glowAtlas then
		self.glow:SetAtlas(windowInfo.glowAtlas);
		self.glow.suppressGlow = nil;
	else
		self.glow.suppressGlow = true;
	end
	
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
	self.IconBorder:SetAtlas(LOOT_BORDER_BY_QUALITY[itemRarity] or LOOT_BORDER_BY_QUALITY[LE_ITEM_QUALITY_UNCOMMON]);
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

	-- item upgraded?
	self.animArrows:Stop();
	if ( isUpgraded ) then
		local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[itemRarity] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[LE_ITEM_QUALITY_UNCOMMON];
		for i = 1, self.numArrows do
			self["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true);
		end
		self.animArrows:Play();
	else
		for i = 1, self.numArrows do
			self["Arrow"..i]:SetAlpha(0);
		end	
	end
	
	self.hyperlink = itemHyperLink;
	if ( lessAwesome ) then
		PlaySoundKitID(51402);	--UI_Raid_Loot_Toast_Lesser_Item_Won
	elseif ( isUpgraded ) then
		PlaySoundKitID(51561);	-- UI_Warforged_Item_Loot_Toast
	else
		PlaySoundKitID(31578);	--UI_EpicLoot_Toast
	end
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

LootAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("LootWonAlertFrameTemplate", LootWonAlertFrame_SetUp, 6, math.huge);

-- [[ LootUpgradeFrame ]] --
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

LootUpgradeAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("LootUpgradeFrameTemplate", LootUpgradeFrame_SetUp, 6, math.huge);

-- [[ MoneyWonAlertFrameTemplate ]] --
function MoneyWonAlertFrame_SetUp(self, amount)
	self.Amount:SetText(GetMoneyString(amount));
	PlaySoundKitID(31578);	--UI_EpicLoot_Toast
end

MoneyWonAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("MoneyWonAlertFrameTemplate", MoneyWonAlertFrame_SetUp, 6, math.huge);

-- [[ DigsiteCompleteToastFrame ]] --
function DigsiteCompleteToastFrame_SetUp(frame, researchBranchID)
	local raceName, raceTexture	= GetArchaeologyRaceInfoByID(researchBranchID);
	frame.DigsiteType:SetText(raceName);
	frame.DigsiteTypeTexture:SetTexture(raceTexture);
	PlaySound("UI_DigsiteCompletion_Toast");
end

DigsiteCompleteAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(DigsiteCompleteToastFrame, DigsiteCompleteToastFrame_SetUp);

-- [[ StorePurchaseAlertFrame ]] --
function StorePurchaseAlertFrame_SetUp(frame, icon, name, itemID)
	frame.Icon:SetTexture(icon);
	frame.Title:SetFontObject(GameFontNormalLarge);
	frame.Title:SetText(name);
	frame.itemID = itemID;
	if ( frame.Title:IsTruncated() ) then
		frame.Title:SetFontObject(GameFontNormal);
	end
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

StorePurchaseAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(StorePurchaseAlertFrame, StorePurchaseAlertFrame_SetUp);

-- [[ GarrisonBuildingAlertFrame ]] --
function GarrisonBuildingAlertFrame_SetUp(frame, name)
	frame.Name:SetFormattedText(GARRISON_BUILDING_COMPLETE_TOAST, name);
	PlaySound("UI_Garrison_Toast_BuildingComplete");
end

GarrisonBuildingAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonBuildingAlertFrame, GarrisonBuildingAlertFrame_SetUp);

-- [[ GarrisonMissionAlertFrame ]] --
function GarrisonMissionAlertFrame_SetUp(frame, missionID)
	local missionInfo = C_Garrison.GetBasicMissionInfo(missionID);

	frame.Name:SetText(missionInfo.name);
	frame.MissionType:SetAtlas(missionInfo.typeAtlas);

	PlaySound("UI_Garrison_Toast_MissionComplete");
end

GarrisonMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonMissionAlertFrame, GarrisonMissionAlertFrame_SetUp);
GarrisonShipMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonShipMissionAlertFrame, GarrisonMissionAlertFrame_SetUp);

-- [[ GarrisonRandomMissionAlertFrame ]] --
function GarrisonRandomMissionAlertFrame_SetUp(frame, missionID)
	local missionInfo = C_Garrison.GetBasicMissionInfo(missionID);
	frame.Level:SetText(missionInfo.level);
	frame.ItemLevel:SetText("(" .. missionInfo.iLevel .. ")");
	if (missionInfo.iLevel ~= 0 and missionInfo.isRare) then
		frame.Level:SetPoint("TOP", "$parent", "TOP", -115, -14);
		frame.ItemLevel:SetPoint("TOP", "$parent", "TOP", -115, -37);
		frame.Rare:SetPoint("TOP", "$parent", "TOP", -115, -48);
	elseif (missionInfo.isRare) then
		frame.Level:SetPoint("TOP", "$parent", "TOP", -115, -19);
		frame.Rare:SetPoint("TOP", "$parent", "TOP", -115, -45);
	elseif (missionInfo.iLevel ~= 0) then
		frame.Level:SetPoint("TOP", "$parent", "TOP", -115, -19);
		frame.ItemLevel:SetPoint("TOP", "$parent", "TOP", -115, -45);
	else
		frame.Level:SetPoint("TOP", "$parent", "TOP", -115, -28);
	end

	frame.ItemLevel:SetShown(missionInfo.iLevel ~= 0);
	frame.Rare:SetShown(missionInfo.isRare);
	PlaySound("UI_Garrison_Toast_MissionComplete");
end

GarrisonRandomMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonRandomMissionAlertFrame, GarrisonRandomMissionAlertFrame_SetUp);

-- [[ GarrisonFollowerAlertFrame ]] --
GARRISON_FOLLOWER_QUALITY_TEXTURE_SUFFIXES = {
	[LE_ITEM_QUALITY_UNCOMMON] = "Uncommon",
	[LE_ITEM_QUALITY_EPIC] = "Epic",
	[LE_ITEM_QUALITY_RARE] = "Rare",
}

function GarrisonCommonFollowerAlertFrame_SetUp(frame, followerID, name, quality, isUpgraded)
	frame.followerID = followerID;
	frame.Name:SetText(name);
	local texSuffix = GARRISON_FOLLOWER_QUALITY_TEXTURE_SUFFIXES[quality]
	if (texSuffix) then
		frame.FollowerBG:SetAtlas("Garr_FollowerToast-"..texSuffix, true);
		frame.FollowerBG:Show();
	else
		frame.FollowerBG:Hide();
	end
	
	frame.Arrows.ArrowsAnim:Stop();
	if ( isUpgraded ) then
		local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[LE_ITEM_QUALITY_UNCOMMON];
		for i = 1, frame.Arrows.numArrows do
			frame.Arrows["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true);
		end

		frame.DieIcon:ClearAllPoints();
		frame.DieIcon:SetPoint("RIGHT", frame.Title, "LEFT", -4, 0);
		frame.DieIcon:Show();
		frame.Arrows.ArrowsAnim:Play();
	else
		frame.DieIcon:Hide();
	end

	PlaySound("UI_Garrison_Toast_FollowerGained");
end

function GarrisonFollowerAlertFrame_SetUp(frame, followerID, name, level, quality, isUpgraded)
	frame.followerInfo = C_Garrison.GetFollowerInfo(followerID);
	frame.PortraitFrame:SetupPortrait(frame.followerInfo);
	if ( frame.followerInfo.isTroop ) then
		if ( isUpgraded ) then
			frame.Title:SetText(GarrisonFollowerOptions[frame.followerInfo.followerTypeID].strings.TROOP_ADDED_UPGRADED_TOAST);
		else
			frame.Title:SetText(GarrisonFollowerOptions[frame.followerInfo.followerTypeID].strings.TROOP_ADDED_TOAST);
		end
	else
		if ( isUpgraded ) then
			frame.Title:SetText(GarrisonFollowerOptions[frame.followerInfo.followerTypeID].strings.FOLLOWER_ADDED_UPGRADED_TOAST);
		else
			frame.Title:SetText(GarrisonFollowerOptions[frame.followerInfo.followerTypeID].strings.FOLLOWER_ADDED_TOAST);
		end
	end
	GarrisonCommonFollowerAlertFrame_SetUp(frame, followerID, name, quality, isUpgraded);
end

function GarrisonShipFollowerAlertFrame_SetUp(frame, followerID, name, class, texPrefix, level, quality, isUpgraded)
	local mapAtlas = texPrefix .. "-List";
	frame.Portrait:SetAtlas(mapAtlas, false);
	local color = ITEM_QUALITY_COLORS[quality];
	frame.Name:SetTextColor(color.r, color.g, color.b);
	if ( isUpgraded ) then
		frame.Title:SetText(GARRISON_SHIPYARD_FOLLOWER_ADDED_UPGRADED_TOAST);
	else
		frame.Title:SetText(GARRISON_SHIPYARD_FOLLOWER_ADDED_TOAST);
	end
	frame.Class:SetText(class);
	GarrisonCommonFollowerAlertFrame_SetUp(GarrisonShipFollowerAlertFrame, followerID, name, 0, isUpgraded);
end

function GarrisonFollowerAlertFrame_OnEnter(self)
	AlertFrame_StopOutAnimation(self);
	
	local link = C_Garrison.GetFollowerLink(self.followerID);
	if ( link ) then
		GarrisonFollowerTooltip:ClearAllPoints();
		GarrisonFollowerTooltip:SetPoint("BOTTOM", self, "TOP");
		local _, garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, spec1 = strsplit(":", link);
		GarrisonFollowerTooltip_Show(tonumber(garrisonFollowerID), false, tonumber(quality), tonumber(level), 0, 0, tonumber(itemLevel), tonumber(spec1), tonumber(ability1), tonumber(ability2), tonumber(ability3), tonumber(ability4), tonumber(trait1), tonumber(trait2), tonumber(trait3), tonumber(trait4));
	end
end

function GarrisonFollowerAlertFrame_OnLeave(self)
	GarrisonFollowerTooltip:Hide();
	GarrisonShipyardFollowerTooltip:Hide();
	AlertFrame_ResumeOutAnimation(self);
end

function GarrisonFollowerAlertFrame_OnClick(self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end
	self:Hide();
	if (not GarrisonLandingPage) then
		Garrison_LoadUI();
	end
	ShowGarrisonLandingPage(GarrisonFollowerOptions[self.followerInfo.followerTypeID].garrisonType);
end

GarrisonFollowerAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonFollowerAlertFrame, GarrisonFollowerAlertFrame_SetUp);
GarrisonShipFollowerAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonShipFollowerAlertFrame, GarrisonShipFollowerAlertFrame_SetUp);

-- [[ GarrisonTalentAlertFrame ]] --
function GarrisonTalentAlertFrame_SetUp(frame, garrisonType)
    local talentID = C_Garrison.GetCompleteTalent(garrisonType);
    local talent = C_Garrison.GetTalent(talentID);
    frame.Icon:SetTexture(talent.icon);
	PlaySound("UI_OrderHall_Talent_Ready_Toast");
end

GarrisonTalentAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GarrisonTalentAlertFrame, GarrisonTalentAlertFrame_SetUp);

-- [[ NewRecipeLearnedAlertFrame ]] --
function NewRecipeLearnedAlertFrame_GetStarTextureFromRank(rank)
	if rank == 1 then
		return "|TInterface\\LootFrame\\toast-star:12:12:0:0:32:32:0:21:0:21|t";
	elseif rank == 2 then
		return "|TInterface\\LootFrame\\toast-star-2:12:24:0:0:64:32:0:42:0:21|t";
	elseif rank == 3 then
		return "|TInterface\\LootFrame\\toast-star-3:12:36:0:0:64:32:0:64:0:21|t";
	end
	return nil;
end

function NewRecipeLearnedAlertFrame_SetUp(self, recipeID)
	local tradeSkillID, skillLineName = C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID);
	if tradeSkillID then
		local recipeName = GetSpellInfo(recipeID);
		if recipeName then
			PlaySound("UI_Professions_NewRecipeLearned_Toast");

			self.Icon:SetTexture(C_TradeSkillUI.GetTradeSkillTexture(tradeSkillID));
			self.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
		
			local rank = GetSpellRank(recipeID);
			self.Title:SetText(rank and rank > 1 and UPGRADED_RECIPE_LEARNED_TITLE or NEW_RECIPE_LEARNED_TITLE);

			local rankTexture = NewRecipeLearnedAlertFrame_GetStarTextureFromRank(rank);
			if rankTexture then
				self.Name:SetFormattedText("%s %s", recipeName, rankTexture);
			else
				self.Name:SetText(recipeName);
			end
			self.tradeSkillID = tradeSkillID;
			self.recipeID = recipeID;
			return true;
		end
	end
	return false;
end

function NewRecipeLearnedAlertFrame_OnClick(self, button, down)
	if AlertFrame_OnClick(self, button, down) then
		return;
	end

	TradeSkillFrame_LoadUI();
	if C_TradeSkillUI.OpenTradeSkill(self.tradeSkillID) then
		TradeSkillFrame:SelectRecipe(self.recipeID);
	end
end

NewRecipeLearnedAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NewRecipeLearnedAlertFrameTemplate", NewRecipeLearnedAlertFrame_SetUp, 2, 6);

-- [[WorldQuestCompleteAlertFrame ]] --
function WorldQuestCompleteAlertFrame_GetIconForQuestID(questID)
	local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(questID);

	if ( worldQuestType == LE_QUEST_TAG_TYPE_PVP ) then
		return "Interface\\Icons\\achievement_arena_2v2_1";
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE ) then
		return "Interface\\Icons\\INV_Pet_BattlePetTraining";
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION ) then
		local tradeskillLineID = select(7, GetProfessionInfo(tradeskillLineIndex));
		return C_TradeSkillUI.GetTradeSkillTexture(tradeskillLineID);
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_DUNGEON ) then
		return "Interface\\Icons\\INV_Misc_Bone_Skull_02";
	end

	return "Interface\\Icons\\Achievement_Quests_Completed_TwilightHighlands";
end

function WorldQuestCompleteAlertFrame_SetUp(frame, questID)
	PlaySound("UI_WorldQuest_Complete");

	local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(questID);
	frame.QuestName:SetText(taskName);

	local icon = WorldQuestCompleteAlertFrame_GetIconForQuestID(questID);
	frame.QuestTexture:SetTexture(icon);

	local numUsedRewardFrames = 0;
	local money = GetQuestLogRewardMoney(questID);
	if money > 0 then
		local rewardFrame = frame.RewardFrames and frame.RewardFrames[i] or CreateFrame("FRAME", nil, frame, "WorldQuestFrameRewardTemplate");

		SetPortraitToTexture(rewardFrame.texture, "Interface\\Icons\\inv_misc_coin_02");
		rewardFrame.itemID = nil;
		rewardFrame.money = money;
		rewardFrame.xp = nil;
		rewardFrame:Show();

		numUsedRewardFrames = numUsedRewardFrames + 1;
	end

	local xp = GetQuestLogRewardXP(questID);
	if xp > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL then
		local rewardFrame = frame.RewardFrames and frame.RewardFrames[i] or CreateFrame("FRAME", nil, frame, "WorldQuestFrameRewardTemplate");

		SetPortraitToTexture(rewardFrame.texture, "Interface\\Icons\\xp_icon");
		rewardFrame.itemID = nil;
		rewardFrame.money = nil;
		rewardFrame.xp = xp;
		rewardFrame:Show();

		numUsedRewardFrames = numUsedRewardFrames + 1;
	end

	local numItems = GetNumQuestLogRewards(questID);
	for i = 1, numItems do
		local name, texture, count, quality, isUsable, itemID = GetQuestLogRewardInfo(i, questID);
		local rewardFrame = frame.RewardFrames and frame.RewardFrames[numUsedRewardFrames + 1] or CreateFrame("FRAME", nil, frame, "WorldQuestFrameRewardTemplate");
		SetPortraitToTexture(rewardFrame.texture, texture);
		rewardFrame.itemID = itemID;
		rewardFrame.money = nil;
		rewardFrame.xp = nil;
		rewardFrame:Show();

		numUsedRewardFrames = numUsedRewardFrames + 1;
	end

	if frame.RewardFrames then
		local SPACING = 36;
		for i = 1, numUsedRewardFrames do
			if frame.RewardFrames[i - 1] then
				frame.RewardFrames[i]:SetPoint("CENTER", frame.RewardFrames[i - 1], "CENTER", SPACING, 0);
			else
				frame.RewardFrames[i]:SetPoint("TOP", frame, "TOP", -SPACING / 2 * numUsedRewardFrames + 41, 8);
			end
		end

		for i = numUsedRewardFrames + 1, #frame.RewardFrames do
			frame.RewardFrames[i]:Hide();
		end
	end
end

function WorldQuestCompleteFrameReward_OnEnter(self)
	AlertFrame_StopOutAnimation(self:GetParent());

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.itemID then
		GameTooltip:SetItemByID(self.itemID);
	elseif self.money then
		GameTooltip:AddLine(YOU_RECEIVED);
		SetTooltipMoney(GameTooltip, self.money, nil);
	elseif self.xp then
		GameTooltip:AddLine(YOU_RECEIVED);
		GameTooltip:AddLine(BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(self.xp), HIGHLIGHT_FONT_COLOR:GetRGB());
	end
	GameTooltip:Show();
end

WorldQuestCompleteAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(WorldQuestCompleteAlertFrame, WorldQuestCompleteAlertFrame_SetUp);

-- [[LegendaryItemAlertFrame ]] --
function LegendaryItemAlertFrame_SetUp(frame, itemLink)
	itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
	frame.Icon:SetTexture(itemTexture);
	frame.ItemName:SetText(itemName);
	local color = ITEM_QUALITY_COLORS[itemRarity];
	frame.ItemName:SetVertexColor(color.r, color.g, color.b);
	frame.hyperlink = itemHyperLink;
	frame.Background2.animIn:Play();
	frame.Background3.animIn:Play();
	PlaySound("UI_LegendaryLoot_Toast");
end

function LegendaryItemAlertFrame_OnClick(self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end
	local bag = SearchBagsForItemLink(self.hyperlink);
	if (bag >= 0) then
		OpenBag(bag);
	end
end

LegendaryItemAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(LegendaryItemAlertFrame, LegendaryItemAlertFrame_SetUp);