function AlertFrameSystems_Register()
	GuildChallengeAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GuildChallengeAlertFrameTemplate", GuildChallengeAlertFrame_SetUp);
	DungeonCompletionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("DungeonCompletionAlertFrameTemplate", DungeonCompletionAlertFrame_SetUp);
	ScenarioAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("ScenarioAlertFrameTemplate", ScenarioAlertFrame_SetUp);
	InvasionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("ScenarioLegionInvasionAlertFrameTemplate", ScenarioLegionInvasionAlertFrame_SetUp, ScenarioLegionInvasionAlertFrame_Coalesce);
	DigsiteCompleteAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("DigsiteCompleteToastFrameTemplate", DigsiteCompleteToastFrame_SetUp);
	EntitlementDeliveredAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("EntitlementDeliveredAlertFrameTemplate", EntitlementDeliveredAlertFrame_SetUp);
	RafRewardDeliveredAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("RafRewardDeliveredAlertFrameTemplate", RafRewardDeliveredAlertFrame_SetUp);
	GarrisonBuildingAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonBuildingAlertFrameTemplate", GarrisonBuildingAlertFrame_SetUp);
	GarrisonMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonStandardMissionAlertFrameTemplate", GarrisonMissionAlertFrame_SetUp);
	GarrisonShipMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonShipMissionAlertFrameTemplate", GarrisonMissionAlertFrame_SetUp);
	GarrisonRandomMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonRandomMissionAlertFrameTemplate", GarrisonRandomMissionAlertFrame_SetUp);
	GarrisonFollowerAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonStandardFollowerAlertFrameTemplate", GarrisonFollowerAlertFrame_SetUp);
	GarrisonShipFollowerAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonShipFollowerAlertFrameTemplate", GarrisonShipFollowerAlertFrame_SetUp);
	GarrisonTalentAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonTalentAlertFrameTemplate", GarrisonTalentAlertFrame_SetUp);
	WorldQuestCompleteAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("WorldQuestCompleteAlertFrameTemplate", WorldQuestCompleteAlertFrame_SetUp, WorldQuestCompleteAlertFrame_Coalesce);
	LegendaryItemAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("LegendaryItemAlertFrameTemplate", LegendaryItemAlertFrame_SetUp);
	NewPetAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NewPetAlertFrameTemplate", NewPetAlertFrame_SetUp);
	NewMountAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NewMountAlertFrameTemplate", NewMountAlertFrame_SetUp);
	NewToyAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NewToyAlertFrameTemplate", NewToyAlertFrame_SetUp);
	NewRuneforgePowerAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NewRuneforgePowerAlertFrameTemplate", NewRuneforgePowerAlertSystem_SetUp);
end

-- [[ GuildChallengeAlertFrame ]] --
function GuildChallengeAlertFrame_SetUp(frame, challengeType, count, max)
	frame.Type:SetText(_G["GUILD_CHALLENGE_TYPE"..challengeType]);
	frame.Count:SetFormattedText(GUILD_CHALLENGE_PROGRESS_FORMAT, count, max);
	SetLargeGuildTabardTextures("player", frame.EmblemIcon, frame.EmblemBackground, frame.EmblemBorder);
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
function DungeonCompletionAlertFrame_OnLoad(self)
	self.glow = self.glowFrame.glow;
end

-- NOTE: Previously lived in the client, moved out because it's simpler to create this in lua
-- Potentially move this to a utility file.
function TooltipSetLFGCompletionReward(tooltip, itemLink, bonusQuantity)
	bonusQuantity = bonusQuantity or 0;

	tooltip:SetHyperlink(itemLink);

	if bonusQuantity > 0 then
		tooltip:AddLine(" ");

		local bonusValor = BONUS_VALOR_TOOLTIP:format(HIGHLIGHT_FONT_COLOR:GenerateHexColor(), bonusQuantity);
		local bonusValorLine = string.format("|c%s|r", bonusValor);
		tooltip:AddLine(bonusValorLine);
	end
end

-- Utility to acquire or create a reward frame and clear all fields.
-- Potentially move to frame pools.
local function GetRewardFrame(frame, templateName)
	frame.numUsedRewardFrames = (frame.numUsedRewardFrames or 0) + 1;
	local rewardFrame = frame.RewardFrames and frame.RewardFrames[frame.numUsedRewardFrames] or CreateFrame("BUTTON", nil, frame, templateName);

	rewardFrame.itemLink = nil;
	rewardFrame.money = nil;
	rewardFrame.xp = nil;
	rewardFrame.currencyIndex = nil;
	rewardFrame.rewardID = nil;
	rewardFrame:Show();

	return rewardFrame;
end

local function ResetRewardFrames(frame)
	if frame.RewardFrames then
		for _, rewardFrame in ipairs(frame.RewardFrames) do
			rewardFrame:Hide();
		end

		frame.numUsedRewardFrames = 0;
	end
end

function StandardRewardAlertFrame_AdjustRewardAnchors(frame)
	if frame.RewardFrames then
		local SPACING = 36;
		for i = 1, frame.numUsedRewardFrames do
			if frame.RewardFrames[i - 1] then
				frame.RewardFrames[i]:SetPoint("CENTER", frame.RewardFrames[i - 1], "CENTER", SPACING, 0);
			else
				frame.RewardFrames[i]:SetPoint("TOP", frame, "TOP", -SPACING / 2 * frame.numUsedRewardFrames + 41, 8);
			end
		end
	end
end

function StandardRewardAlertFrame_OnEnter(self)
	AlertFrame_PauseOutAnimation(self:GetParent());

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.itemLink then
		GameTooltip:SetHyperlink(self.itemLink);
	elseif self.money then
		GameTooltip:AddLine(YOU_RECEIVED);
		SetTooltipMoney(GameTooltip, self.money, nil);
	elseif self.xp then
		GameTooltip:AddLine(YOU_RECEIVED);
		GameTooltip:AddLine(BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(self.xp), HIGHLIGHT_FONT_COLOR:GetRGB());
	elseif self.currencyIndex then
		GameTooltip:SetQuestLogCurrency("reward", self.currencyIndex, self:GetParent().questID);
	end
	GameTooltip:Show();
end

local function SetRewardInternal(frame, texture, rewardID)
	SetPortraitToTexture(frame.texture, texture);
	frame.rewardID = rewardID;
end

function DungeonCompletionAlertFrameReward_SetRewardMoney(frame, optionalMoney)
	SetRewardInternal(frame, "Interface\\Icons\\inv_misc_coin_02", 0);
	if optionalMoney then
		frame.money = optionalMoney;
	end
end

function DungeonCompletionAlertFrameReward_SetRewardXP(frame, optionalXP)
	SetRewardInternal(frame, "Interface\\Icons\\xp_icon", 0);
	if optionalXP then
		frame.xp = optionalXP;
	end
end

function DungeonCompletionAlertFrameReward_SetRewardItem(frame, itemLink, texture)
	SetRewardInternal(frame, texture);
	frame.itemLink = itemLink;
end

function DungeonCompletionAlertFrameReward_SetReward(frame, reward)
	SetRewardInternal(frame, reward.texturePath, reward.rewardID);
	frame.reward = reward;
end

function DungeonCompletionAlertFrame_SetUp(frame, rewardData)
	PlaySound(SOUNDKIT.LFG_REWARDS);

	--For now we only have 1 dungeon alert frame. If you're completing more than one dungeon within ~5 seconds, tough luck.
	local isRaid = rewardData.subtypeID == LFG_SUBTYPEID_RAID;
	frame.raidArt:SetShown(isRaid);
	frame.dungeonArt:SetShown(not isRaid);

	if ( isRaid ) then
		frame.dungeonTexture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 26, 15);
		frame.completionText:SetPoint("TOP", 25, -28);
		frame.glowFrame.glow:SetPoint("CENTER", 0, -2);
		frame.shine:SetPoint("BOTTOMLEFT", 0, 1);
	else
		frame.dungeonTexture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 13, 18);
		frame.completionText:SetPoint("TOP", 25, -25);
		frame.glowFrame.glow:SetPoint("CENTER", 0, 1);
		frame.shine:SetPoint("BOTTOMLEFT", 0, 4);
	end

	--Set up the rewards
	ResetRewardFrames(frame);

	-- Use Money type icon for both money and xp here.
	if ( rewardData.moneyAmount > 0 or rewardData.experienceGained > 0 ) then
		local rewardFrame = GetRewardFrame(frame, "DungeonCompletionAlertFrameRewardTemplate");
		DungeonCompletionAlertFrameReward_SetRewardMoney(rewardFrame);
	end

	for i = 1, rewardData.numRewards do
		local rewardFrame = GetRewardFrame(frame, "DungeonCompletionAlertFrameRewardTemplate");
		DungeonCompletionAlertFrameReward_SetReward(rewardFrame, rewardData.rewards[i]);
	end

	StandardRewardAlertFrame_AdjustRewardAnchors(frame);

	--Set up the text and icons.

	frame.instanceName:SetText(rewardData.name);

	local instanceNameYOffset = isRaid and -43 or -39;
	if ( rewardData.subtypeID == LFG_SUBTYPEID_HEROIC ) then
		frame.heroicIcon:Show();
		frame.instanceName:SetPoint("TOP", 33, instanceNameYOffset);
	else
		frame.heroicIcon:Hide();
		frame.instanceName:SetPoint("TOP", 25, instanceNameYOffset);
	end

	frame.dungeonTexture:SetTexture(rewardData.iconTextureFile);
	frame.rewardData = rewardData;
end

function DungeonCompletionAlertFrameReward_OnEnter(self)
	local parent = self:GetParent();
	local rewardData = parent.rewardData;

	AlertFrame_PauseOutAnimation(parent);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if ( self.rewardID == 0 ) then
		GameTooltip:AddLine(YOU_RECEIVED);

		if ( rewardData.experienceGained > 0 ) then
			GameTooltip:AddLine(string.format(GAIN_EXPERIENCE, rewardData.experienceGained));
		end

		if ( rewardData.moneyAmount > 0 ) then
			SetTooltipMoney(GameTooltip, rewardData.moneyAmount, nil);
		end
	elseif ( self.reward.rewardItemLink ) then
		TooltipSetLFGCompletionReward(GameTooltip, self.reward.rewardItemLink, self.reward.bonusQuantity);
	end

	GameTooltip:Show();
end

function DungeonCompletionAlertFrameReward_OnLeave(frame)
	AlertFrame_ResumeOutAnimation(frame:GetParent());
	GameTooltip:Hide();
end

-- [[ ScenarioAlertFrame ]] --
function ScenarioAlertFrame_SetUp(frame, rewardData)
	PlaySound(SOUNDKIT.UI_SCENARIO_ENDING);

	frame.BonusStar:SetShown(rewardData.hasBonusStep and rewardData.isBonusStepComplete);

	--Set up the rewards
	ResetRewardFrames(frame);

	-- Use Money type icon for both money and xp here.
	if ( rewardData.moneyAmount > 0 or rewardData.experienceGained > 0 ) then
		local rewardFrame = GetRewardFrame(frame, "DungeonCompletionAlertFrameRewardTemplate");
		DungeonCompletionAlertFrameReward_SetRewardMoney(rewardFrame);
	end

	for i = 1, rewardData.numRewards do
		local rewardFrame = GetRewardFrame(frame, "DungeonCompletionAlertFrameRewardTemplate");
		DungeonCompletionAlertFrameReward_SetReward(rewardFrame, rewardData.rewards[i]);
	end

	StandardRewardAlertFrame_AdjustRewardAnchors(frame);

	--Set up the text and icon
	frame.dungeonName:SetText(rewardData.name);
	frame.dungeonTexture:SetTexture(rewardData.iconTextureFile);
	frame.rewardData = rewardData;
end

-- [[ScenarioLegionInvasionAlertFrame ]] --
function ScenarioLegionInvasionAlertFrame_SetUp(frame, rewardQuestID, name, showBonusCompletion, xp, money)
	PlaySound(SOUNDKIT.UI_SCENARIO_ENDING);

	frame.questID = rewardQuestID;
	frame.ZoneName:SetText(name);
	frame.BonusStar:SetShown(showBonusCompletion);

	ResetRewardFrames(frame);

	if money > 0 then
		local rewardFrame = GetRewardFrame(frame, "InvasionAlertFrameRewardTemplate");
		DungeonCompletionAlertFrameReward_SetRewardMoney(rewardFrame, money);
	end

	if xp > 0 and not IsPlayerAtEffectiveMaxLevel() then
		local rewardFrame = GetRewardFrame(frame, "InvasionAlertFrameRewardTemplate");
		DungeonCompletionAlertFrameReward_SetRewardXP(rewardFrame, xp);
	end

	StandardRewardAlertFrame_AdjustRewardAnchors(frame);
end

function ScenarioLegionInvasionAlertFrame_Coalesce(frame, questID, rewardItemLink, texture)
	if frame.questID == questID then
		local rewardFrame = GetRewardFrame(frame, "WorldQuestFrameRewardTemplate");
		DungeonCompletionAlertFrameReward_SetRewardItem(rewardFrame, rewardItemLink, texture);
		StandardRewardAlertFrame_AdjustRewardAnchors(frame);

		return ALERT_FRAME_COALESCE_SUCCESS;
	end

	return ALERT_FRAME_COALESCE_CONTINUE;
end

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

-- [[ LootUpgradeFrameTemplate ]] --
LOOTUPGRADEFRAME_QUALITY_TEXTURES = {
	[Enum.ItemQuality.Uncommon]	= {border = "loottoast-itemborder-green",	arrow = "loottoast-arrow-green"},
	[Enum.ItemQuality.Rare]		= {border = "loottoast-itemborder-blue",	arrow = "loottoast-arrow-blue"},
	[Enum.ItemQuality.Epic]		= {border = "loottoast-itemborder-purple",	arrow = "loottoast-arrow-purple"},
	[Enum.ItemQuality.Legendary]	= {border = "loottoast-itemborder-orange",	arrow = "loottoast-arrow-orange"},
}

-- [[ LootWonAlertFrameTemplate ]] --
LOOTWONALERTFRAME_VALUES={
	WonRoll = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=5, labelText=YOU_WON_LABEL, glowAtlas="loottoast-glow"},
	Default = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=5, labelText=YOU_RECEIVED_LABEL, glowAtlas="loottoast-glow"},
	Upgraded = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=5, labelText=ITEM_UPGRADED_LABEL, bgAtlas="LootToast-MoreAwesome", glowAtlas="loottoast-glow", soundKit=SOUNDKIT.UI_WARFORGED_ITEM_LOOT_TOAST},
	LessAwesome = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=5, labelText=YOU_RECEIVED_LABEL, bgAtlas="LootToast-LessAwesome", soundKit=SOUNDKIT.UI_RAID_LOOT_TOAST_LESSER_ITEM_WON},
	GarrisonCache = { bgOffsetX=-4, bgOffsetY=0, labelOffsetX=7, labelOffsetY=1, labelText=GARRISON_CACHE, glowAtlas="CacheToast-Glow", bgAtlas="CacheToast", noIconBorder=true, iconUnderBG=true},
	Horde = { bgOffsetX=-1, bgOffsetY=-1, labelOffsetX=7, labelOffsetY=3, labelText=YOU_EARNED_LABEL, pvpAtlas="loottoast-bg-horde", glowAtlas="loottoast-glow"},
	Alliance = { bgOffsetX=-1, bgOffsetY=-1, labelOffsetX=7, labelOffsetY=3, labelText=YOU_EARNED_LABEL, pvpAtlas="loottoast-bg-alliance", glowAtlas="loottoast-glow"},
	RatedHorde = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=3, labelText=YOU_EARNED_LABEL, pvpAtlas="pvprated-loottoast-bg-horde", glowAtlas="loottoast-glow"},
	RatedAlliance = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=3, labelText=YOU_EARNED_LABEL, pvpAtlas="pvprated-loottoast-bg-alliance", glowAtlas="loottoast-glow"},
	Azerite = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=3, labelText=AZERITE_EMPOWERED_ITEM_LOOT_LABEL, bgAtlas="LootToast-Azerite", glowAtlas="loottoast-glow", soundKit=SOUNDKIT.UI_AZERITE_EMPOWERED_ITEM_LOOT_TOAST},
	Conduit = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=3, labelText=CONDUIT_ITEM_LOOT_LABEL, bgAtlas="loottoast-oribos", noIconBorder=true, glowAtlas="loottoast-glow"},
	Corrupted = { bgOffsetX=0, bgOffsetY=0, labelOffsetX=7, labelOffsetY=3, labelText=CORRUPTED_ITEM_LOOT_LABEL, bgAtlas="LootToast-Nzoth", glowAtlas="loottoast-glow", soundKit=SOUNDKIT.UI_CORRUPTED_ITEM_LOOT_TOAST},
}

-- NOTE - This may also be called for an externally created frame. (E.g. bonus roll has its own frame)
function LootWonAlertFrame_SetUp(self, itemLink, originalQuantity, rollType, roll, specID, isCurrency, showFactionBG, lootSource, lessAwesome, isUpgraded, isCorrupted, wonRoll, showRatedBG, isSecondaryResult)
	local itemName, itemTexture, quantity, itemRarity, itemLink = ItemUtil.GetItemDetails(itemLink, originalQuantity, isCurrency, lootSource);

	self.isCurrency = isCurrency;

	local windowInfo = wonRoll and LOOTWONALERTFRAME_VALUES.WonRoll or LOOTWONALERTFRAME_VALUES.Default;
	if( showFactionBG ) then
		local factionGroup = UnitFactionGroup("player");
		windowInfo = LOOTWONALERTFRAME_VALUES[factionGroup]
		self.PvPBackground:SetAtlas(windowInfo.pvpAtlas, true);
		self.PvPBackground:SetPoint("CENTER", windowInfo.bgOffsetX, windowInfo.bgOffsetY);
		self.Background:Hide();
		self.BGAtlas:Hide();
		self.RatedPvPBackground:Hide();
		self.PvPBackground:Show();
	elseif ( showRatedBG ) then
		local factionGroup = UnitFactionGroup("player");
		windowInfo = LOOTWONALERTFRAME_VALUES["Rated"..factionGroup]
		self.RatedPvPBackground:SetAtlas(windowInfo.pvpAtlas, true);
		self.RatedPvPBackground:SetPoint("CENTER", windowInfo.bgOffsetX, windowInfo.bgOffsetY);
		self.Background:Hide();
		self.BGAtlas:Hide();
		self.PvPBackground:Hide();
		self.RatedPvPBackground:Show();
	else
		if ( lootSource == LOOT_SOURCE_GARRISON_CACHE ) then
			windowInfo = LOOTWONALERTFRAME_VALUES["GarrisonCache"];
		elseif ( isCorrupted ) then
			windowInfo = LOOTWONALERTFRAME_VALUES["Corrupted"];
		elseif ( lessAwesome ) then
			windowInfo = LOOTWONALERTFRAME_VALUES["LessAwesome"];
		elseif ( isUpgraded ) then
			windowInfo = LOOTWONALERTFRAME_VALUES["Upgraded"];
		elseif ( C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemLink) ) then
			windowInfo = LOOTWONALERTFRAME_VALUES["Azerite"];
		elseif ( C_Soulbinds.IsItemConduitByItemInfo(itemLink) ) then
			windowInfo = LOOTWONALERTFRAME_VALUES["Conduit"];
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
		self.RatedPvPBackground:Hide();
	end
	if windowInfo.glowAtlas then
		self.glow:SetAtlas(windowInfo.glowAtlas);
		self.glow.suppressGlow = nil;
	else
		self.glow.suppressGlow = true;
	end

	self.Label:SetText(isSecondaryResult and YOU_RECEIVED_LABEL or windowInfo.labelText);
	self.Label:SetPoint("TOPLEFT", self.lootItem.Icon, "TOPRIGHT", windowInfo.labelOffsetX, windowInfo.labelOffsetY);

	self.ItemName:SetText(itemName);
	local color = ITEM_QUALITY_COLORS[itemRarity];
	self.ItemName:SetVertexColor(color.r, color.g, color.b);

	local isIconBorderShown = not windowInfo.noIconBorder;
	local isIconBorderDropShadowShown = false;
	local iconDrawLayer = windowInfo.iconUnderBG and "BACKGROUND" or "BORDER";
	self.lootItem:Init(itemLink, originalQuantity, specID, isCurrency, isUpgraded, isIconBorderShown, isIconBorderDropShadowShown, iconDrawLayer);

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
	local soundKit = windowInfo.soundKit or SOUNDKIT.UI_EPICLOOT_TOAST;
	PlaySound(soundKit);
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

	local baseTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[baseQuality] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[Enum.ItemQuality.Uncommon];
	local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[itemRarity] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[Enum.ItemQuality.Uncommon];
	self.BaseQualityBorder:SetAtlas(baseTexture.border, true);
	self.UpgradeQualityBorder:SetAtlas(upgradeTexture.border, true);

	for i = 1, self.numArrows do
		self["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true);
	end

	self.hyperlink = itemHyperLink;
	PlaySound(SOUNDKIT.UI_EPICLOOT_TOAST);
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
	PlaySound(SOUNDKIT.UI_EPICLOOT_TOAST);
end

MoneyWonAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("MoneyWonAlertFrameTemplate", MoneyWonAlertFrame_SetUp, 6, math.huge);

-- [[ HonorAwardedAlertFrameTemplate ]] --
function HonorAwardedAlertFrame_SetUp(self, amount)
	self.Amount:SetText(string.format(MERCHANT_HONOR_POINTS, amount));
	PlaySound(SOUNDKIT.UI_EPICLOOT_TOAST);
end

HonorAwardedAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("HonorAwardedAlertFrameTemplate", HonorAwardedAlertFrame_SetUp, 6, math.huge);

-- [[ DigsiteCompleteToastFrame ]] --
function DigsiteCompleteToastFrame_SetUp(frame, raceName, raceTexture)
	frame.DigsiteType:SetText(raceName);
	frame.DigsiteTypeTexture:SetTexture(raceTexture);
	PlaySound(SOUNDKIT.UI_DIG_SITE_COMPLETION_TOAST);
end

-- [[ EntitlementDeliveredAlertFrame ]] --
function EntitlementDeliveredAlertFrame_SetUp(frame, type, icon, name, payloadID, showFancyToast)
	frame.Icon:SetTexture(icon);
	frame.Title:SetFontObject(GameFontNormalLarge);
	frame.Title:SetText(name);

	frame.type = type;
	frame.payloadID = payloadID;

	if ( frame.Title:IsTruncated() ) then
		frame.Title:SetFontObject(GameFontNormal);
	end
	PlaySound(SOUNDKIT.UI_IG_STORE_PURCHASE_DELIVERED_TOAST_01);
end

-- [[ RafRewardDeliveredAlertFrame ]] --
function RafRewardDeliveredAlertFrame_SetUp(frame, type, icon, name, payloadID, showFancyToast)
	EntitlementDeliveredAlertFrame_SetUp(frame, type, icon, name, payloadID, showFancyToast);

	if showFancyToast then
		frame.StandardBackground:SetShown(false);
		frame.FancyBackground:SetShown(true);
		frame.Icon:SetPoint("LEFT", frame, "LEFT", 34, -5);
	else
		frame.StandardBackground:SetShown(true);
		frame.FancyBackground:SetShown(false);
		frame.Icon:SetPoint("LEFT", frame, "LEFT", 35, -3);
	end

	if type == Enum.WoWEntitlementType.GameTime then
		frame.Title:SetTextColor(HEIRLOOM_BLUE_COLOR:GetRGBA());
	else
		frame.Title:SetTextColor(EPIC_PURPLE_COLOR:GetRGBA());
	end
end

function EntitlementDelivered_OnClick(self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end

	if (self.type == Enum.WoWEntitlementType.Item) then
		local slot = SearchBagsForItem(self.payloadID);
		if (slot >= 0) then
			OpenBag(slot);
		end
	elseif (self.type == Enum.WoWEntitlementType.Mount) then
		ToggleCollectionsJournal(1);
	elseif (self.type == Enum.WoWEntitlementType.Battlepet) then
		ToggleCollectionsJournal(2);
	elseif (self.type == Enum.WoWEntitlementType.Toy) then
		ToggleToyCollection(self.payloadID);
	elseif (self.type == Enum.WoWEntitlementType.Appearance or self.type == Enum.WoWEntitlementType.AppearanceSet or self.type == Enum.WoWEntitlementType.Illusion) then
		ToggleCollectionsJournal(5);
	end
end

-- [[ GarrisonBuildingAlertFrame ]] --
function GarrisonBuildingAlertFrame_SetUp(frame, name, garrisonType)
	frame.Name:SetFormattedText(GARRISON_BUILDING_COMPLETE_TOAST, name);
	frame.garrisonType = garrisonType;
	PlaySound(SOUNDKIT.UI_GARRISON_TOAST_BUILDING_COMPLETE);
end

-- [[ GarrisonMissionAlertFrame ]] --
function GarrisonMissionAlertFrame_SetUp(frame, missionInfo)
	frame.Name:SetText(missionInfo.name);
	frame.MissionType:SetAtlas(missionInfo.typeAtlas);
	frame.garrisonType = GarrisonFollowerOptions[missionInfo.followerTypeID].garrisonType;
	frame.Title:SetText(GarrisonFollowerOptions[missionInfo.followerTypeID].strings.ALERT_FRAME_TITLE);
	frame.MissionType:SetShown(true);

	if(frame.EncounterIcon) then
		frame.EncounterIcon:SetShown(false);
	end

	if (missionInfo.followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0) then
		frame.EncounterIcon:SetShown(true);
		frame.MissionType:SetShown(false);

		local encounterIconInfo = C_Garrison.GetMissionEncounterIconInfo(missionInfo.missionID);
		frame.EncounterIcon.RareOverlay:SetShown(encounterIconInfo.isRare);
		frame.EncounterIcon.EliteOverlay:SetShown(encounterIconInfo.isElite);

		if encounterIconInfo.portraitFileDataID == nil or encounterIconInfo.portraitFileDataID == 0 then
			frame.EncounterIcon.Portrait:SetTexture("Interface\\Garrison\\Portraits\\FollowerPortrait_NoPortrait");
		else
			frame.EncounterIcon.Portrait:SetTexture(encounterIconInfo.portraitFileDataID);
		end

		frame.EncounterIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -19);
	elseif (missionInfo.followerTypeID == Enum.GarrisonFollowerType.FollowerType_7_0) then
		frame.MissionType:SetSize(50, 50);
		frame.MissionType:SetPoint("TOPLEFT", frame, "TOPLEFT", 21, -14);
	elseif (missionInfo.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0) then
		frame.MissionType:SetSize(64, 64);
		frame.MissionType:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -8);
	end

	PlaySound(SOUNDKIT.UI_GARRISON_TOAST_MISSION_COMPLETE);
end

-- [[ GarrisonRandomMissionAlertFrame ]] --
function GarrisonRandomMissionAlertFrame_SetUp(frame, missionInfo)
	frame.Level:SetText(missionInfo.level);

	local followerOptions = GarrisonFollowerOptions[missionInfo.followerTypeID];
	local showItemLevel = followerOptions.showILevelOnMission and missionInfo.iLevel ~= 0;
	if showItemLevel then
	frame.ItemLevel:SetText("(" .. missionInfo.iLevel .. ")");
	end

	if (showItemLevel and missionInfo.isRare) then
		frame.Level:SetPoint("TOP", -115, -14);
		frame.ItemLevel:SetPoint("TOP", -115, -37);
		frame.Rare:SetPoint("TOP", -115, -48);
	elseif (missionInfo.isRare) then
		frame.Level:SetPoint("TOP", -115, -19);
		frame.Rare:SetPoint("TOP", -115, -45);
	elseif (showItemLevel) then
		frame.Level:SetPoint("TOP", -115, -19);
		frame.ItemLevel:SetPoint("TOP", -115, -45);
	else
		frame.Level:SetPoint("TOP", -115, -28);
	end

	frame.ItemLevel:SetShown(showItemLevel);
	frame.Rare:SetShown(missionInfo.isRare);
	frame.garrisonType = followerOptions.garrisonType;
	PlaySound(SOUNDKIT.UI_GARRISON_TOAST_MISSION_COMPLETE);
end

-- [[ GarrisonFollowerAlertFrame ]] --
GARRISON_FOLLOWER_QUALITY_TEXTURE_SUFFIXES = {
	[Enum.ItemQuality.Uncommon] = "Uncommon",
	[Enum.ItemQuality.Epic] = "Epic",
	[Enum.ItemQuality.Rare] = "Rare",
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
		local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[Enum.ItemQuality.Uncommon];
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

	PlaySound(SOUNDKIT.UI_GARRISON_TOAST_FOLLOWER_GAINED);
end

function GarrisonFollowerAlertFrame_SetUp(frame, followerID, name, level, quality, isUpgraded, followerInfo)
	frame.followerInfo = followerInfo;
	frame.PortraitFrame:SetupPortrait(frame.followerInfo);
	if ( frame.followerInfo.isTroop ) then
		if ( isUpgraded ) then
			frame.Title:SetText(GarrisonFollowerOptions[frame.followerInfo.followerTypeID].strings.TROOP_ADDED_UPGRADED_TOAST);
		else
			frame.Title:SetText(GarrisonFollowerOptions[frame.followerInfo.followerTypeID].strings.TROOP_ADDED_TOAST);
		end
		frame.PortraitFrame:SetPoint("LEFT", 23, -1);
	else
		if ( isUpgraded ) then
			frame.Title:SetText(GarrisonFollowerOptions[frame.followerInfo.followerTypeID].strings.FOLLOWER_ADDED_UPGRADED_TOAST);
		else
			frame.Title:SetText(GarrisonFollowerOptions[frame.followerInfo.followerTypeID].strings.FOLLOWER_ADDED_TOAST);
		end
		frame.PortraitFrame:SetPoint("LEFT", 23, 3);
	end
	GarrisonCommonFollowerAlertFrame_SetUp(frame, followerID, name, quality, isUpgraded);
end

function GarrisonShipFollowerAlertFrame_SetUp(frame, followerID, name, class, textureKit, level, quality, isUpgraded, followerInfo)
	frame.followerInfo = followerInfo;
	if textureKit then
		frame.Portrait:SetAtlas(textureKit.."-List", false);
	else
		frame.Portrait:SetAtlas(nil);
	end

	local color = ITEM_QUALITY_COLORS[quality];
	frame.Name:SetTextColor(color.r, color.g, color.b);
	if ( isUpgraded ) then
		frame.Title:SetText(GARRISON_SHIPYARD_FOLLOWER_ADDED_UPGRADED_TOAST);
	else
		frame.Title:SetText(GARRISON_SHIPYARD_FOLLOWER_ADDED_TOAST);
	end
	frame.Class:SetText(class);
	GarrisonCommonFollowerAlertFrame_SetUp(frame, followerID, name, 0, isUpgraded);
end

function GarrisonFollowerAlertFrame_OnEnter(self)
	AlertFrame_PauseOutAnimation(self);

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

function GarrisonAlertFrame_OnClick(self, button, down)
	if( AlertFrame_OnClick(self, button, down) ) then
		return;
	end
	self:Hide();
	if (not GarrisonLandingPage) then
		Garrison_LoadUI();
	end
	if (self.garrisonType) then
		ShowGarrisonLandingPage(self.garrisonType);
	end
end

-- [[ GarrisonTalentAlertFrame ]] --
function GarrisonTalentAlertFrame_SetUp(frame, garrisonType, talent)
	local garrisonFollowerType = GetPrimaryGarrisonFollowerType(garrisonType);
    frame.Icon:SetTexture(talent.icon);
	local toastTitle = GarrisonFollowerOptions[garrisonFollowerType].strings.TALENT_COMPLETE_TOAST_TITLE;
	frame.Title:SetText(toastTitle);
	frame.garrisonType = garrisonType;
	PlaySound(SOUNDKIT.UI_ORDERHALL_TALENT_READY_TOAST);
end

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

function NewRecipeLearnedAlertFrame_SetUp(self, recipeID, recipeLevel)
	local tradeSkillID, skillLineName, parentTradeSkillID = C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID);
	if tradeSkillID then
		local recipeName = GetSpellInfo(recipeID);
		if recipeName then
			if recipeLevel ~= nil then
				recipeName = TRADESKILL_RECIPE_LEVEL_RECIPE_FORMAT:format(recipeName, recipeLevel);
			end

			PlaySound(SOUNDKIT.UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST);

			self.Icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			self.Icon:SetTexture(C_TradeSkillUI.GetTradeSkillTexture(tradeSkillID));

			local rank = GetSpellRank(recipeID);
			self.Title:SetText(rank and rank > 1 and UPGRADED_RECIPE_LEARNED_TITLE or NEW_RECIPE_LEARNED_TITLE);

			local rankTexture = NewRecipeLearnedAlertFrame_GetStarTextureFromRank(rank);
			if rankTexture then
				self.Name:SetFormattedText("%s %s", recipeName, rankTexture);
			else
				self.Name:SetText(recipeName);
			end
			self.tradeSkillID = parentTradeSkillID or tradeSkillID;
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
	local info = C_QuestLog.GetQuestTagInfo(questID);

	if info then
		if info.worldQuestType == Enum.QuestTagType.PvP then
			return "Interface\\Icons\\achievement_arena_2v2_1";
		elseif info.worldQuestType == Enum.QuestTagType.PetBattle then
			return "Interface\\Icons\\INV_Pet_BattlePetTraining";
		elseif info.worldQuestType == Enum.QuestTagType.Profession then
			return C_TradeSkillUI.GetTradeSkillTexture(info.tradeskillLineID);
		elseif info.worldQuestType == Enum.QuestTagType.Dungeon or info.worldQuestType == Enum.QuestTagType.Raid then
			return "Interface\\Icons\\INV_Misc_Bone_Skull_02";
		end
	end

	return "Interface\\Icons\\Achievement_Quests_Completed_TwilightHighlands";
end

function WorldQuestCompleteAlertFrame_SetUp(frame, questData)
	PlaySound(SOUNDKIT.UI_WORLDQUEST_COMPLETE);

	frame.questID = questData.questID;
	frame.QuestName:SetText(questData.taskName);

	frame.QuestTexture:SetTexture(questData.icon);

	frame.ToastText:SetText(questData.displayAsObjective and TOAST_OBJECTIVE_COMPLETE or WORLD_QUEST_COMPLETE);

	ResetRewardFrames(frame);

	if questData.money > 0 then
		local rewardFrame = GetRewardFrame(frame, "WorldQuestFrameRewardTemplate");
		DungeonCompletionAlertFrameReward_SetRewardMoney(rewardFrame, questData.money);
	end

	if questData.xp > 0 and not IsPlayerAtEffectiveMaxLevel() then
		local rewardFrame = GetRewardFrame(frame, "WorldQuestFrameRewardTemplate");
		DungeonCompletionAlertFrameReward_SetRewardXP(rewardFrame, questData.xp);
	end

	if questData.currencyRewards then
		for currencyIndex, currencyTexture in ipairs(questData.currencyRewards) do
			local rewardFrame = GetRewardFrame(frame, "WorldQuestFrameRewardTemplate");
			SetPortraitToTexture(rewardFrame.texture, currencyTexture);
			rewardFrame.currencyIndex = currencyIndex;
		end
	end

	StandardRewardAlertFrame_AdjustRewardAnchors(frame);
end

function WorldQuestCompleteAlertFrame_Coalesce(frame, questID, rewardItemLink, texture)
	if frame.questID == questID and rewardItemLink then
		local rewardFrame = GetRewardFrame(frame, "WorldQuestFrameRewardTemplate");
		DungeonCompletionAlertFrameReward_SetRewardItem(rewardFrame, rewardItemLink, texture);
		StandardRewardAlertFrame_AdjustRewardAnchors(frame);
		return ALERT_FRAME_COALESCE_SUCCESS;
	end

	return ALERT_FRAME_COALESCE_CONTINUE;
end

-- [[LegendaryItemAlertFrame ]] --
function LegendaryItemAlertFrame_SetUp(frame, itemLink)
	local itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
	frame.Icon:SetTexture(itemTexture);
	frame.ItemName:SetText(itemName);
	local color = ITEM_QUALITY_COLORS[itemRarity];
	frame.ItemName:SetVertexColor(color.r, color.g, color.b);
	frame.hyperlink = itemHyperLink;
	frame.Background2.animIn:Play();
	frame.Background3.animIn:Play();
	PlaySound(SOUNDKIT.UI_LEGENDARY_LOOT_TOAST);
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

function LegendaryItemAlertFrame_OnEnter(self)
	AlertFrame_PauseOutAnimation(self);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetHyperlink(self.hyperlink);
	GameTooltip:Show();
end

function LegendaryItemAlertFrame_OnLeave(self)
	AlertFrame_ResumeOutAnimation(self);

	GameTooltip:Hide();
end

-- [[ ItemAlertFrame (template) ]] ---

ItemAlertFrameMixin = {};

function ItemAlertFrameMixin:SetUpDisplay(icon, itemQuality, name, label)
	self.Icon:SetTexture(icon);
	self.IconBorder:SetAtlas(LOOT_BORDER_BY_QUALITY[itemQuality] or LOOT_BORDER_BY_QUALITY[Enum.ItemQuality.Uncommon]);
	self.Name:SetText(ITEM_QUALITY_COLORS[itemQuality].hex..name.."|r");
	self.Label:SetText(label);
end

-- [[ NewPetAlertFrame ]] --

function NewPetAlertFrame_SetUp(frame, petID)
	frame:SetUp(petID);
end

NewPetAlertFrameMixin = CreateFromMixins(ItemAlertFrameMixin);

function NewPetAlertFrameMixin:SetUp(petID)
	self.petID = petID;

	local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon = C_PetJournal.GetPetInfoByPetID(petID);
	local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID);
	if speciesID ~= nil and health ~= nil then
		local itemQuality = rarity - 1;
		self:SetUpDisplay(icon, itemQuality, customName or name, YOU_EARNED_LABEL);
	end
end

function NewPetAlertFrameMixin:OnClick(button, down)
	if AlertFrame_OnClick(self, button, down) then
		return;
	end

	SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS);
	PetJournal_SelectPet(PetJournal, self.petID);
end

-- [[ NewMountAlertFrame ]] --

function NewMountAlertFrame_SetUp(frame, mountID)
	frame:SetUp(mountID);
end

NewMountAlertFrameMixin = CreateFromMixins(ItemAlertFrameMixin);

function NewMountAlertFrameMixin:SetUp(mountID)
	self.mountID = mountID;

	local creatureName, spellID, icon, active, isUsable, sourceType = C_MountJournal.GetMountInfoByID(mountID);
	local itemQuality = Enum.ItemQuality.Epic; -- Mounts don't have an inherent concept of quality so we always use epic (for now).
	self:SetUpDisplay(icon, itemQuality, creatureName, YOU_EARNED_LABEL);
end

function NewMountAlertFrameMixin:OnClick(button, down)
	if AlertFrame_OnClick(self, button, down) then
		return;
	end

	SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS);
	MountJournal_SelectByMountID(self.mountID);
end

-- [[ NewToyAlertFrame ]] --

function NewToyAlertFrame_SetUp(frame, toyID)
	frame:SetUp(toyID);
end

NewToyAlertFrameMixin = CreateFromMixins(ItemAlertFrameMixin);

function NewToyAlertFrameMixin:SetUp(toyID)
	self.toyID = toyID;

	local itemID, toyName, icon, isFavorite, hasFanfare, itemQuality = C_ToyBox.GetToyInfo(self.toyID);
	self:SetUpDisplay(icon, itemQuality, toyName, YOU_EARNED_LABEL);
end

function NewToyAlertFrameMixin:OnClick(button, down)
	if AlertFrame_OnClick(self, button, down) then
		return;
	end

	ToggleToyCollection(self.toyID);
end

-- [[ NewRuneforgePowerAlertSystem ]] --

function NewRuneforgePowerAlertSystem_SetUp(frame, powerID)
	frame:SetUp(powerID);
end

NewRuneforgePowerAlertFrameMixin = CreateFromMixins(ItemAlertFrameMixin, RuneforgePowerBaseMixin);

function NewRuneforgePowerAlertFrameMixin:SetUp(powerID)
	self:SetPowerID(powerID);
end

function NewRuneforgePowerAlertFrameMixin:OnPowerSet(oldPowerID, newPowerID)
	local powerInfo = self:GetPowerInfo();
	self.powerInfo = powerInfo;
	self:SetUpDisplay(powerInfo.iconFileID, Enum.ItemQuality.Legendary, powerInfo.name, YOU_EARNED_LABEL);
end

function NewRuneforgePowerAlertFrameMixin:OnEnter()
	RuneforgePowerBaseMixin.OnEnter(self);

	AlertFrame_PauseOutAnimation(self);
end

function NewRuneforgePowerAlertFrameMixin:OnLeave()
	RuneforgePowerBaseMixin.OnLeave(self);

	AlertFrame_ResumeOutAnimation(self);
end

function NewRuneforgePowerAlertFrameMixin:OnClick(button, down)
	if AlertFrame_OnClick(self, button, down) then
		return;
	end

	if self:OnSelected() then
		return;
	end

	EncounterJournal_LoadUI();
	EncounterJournal_OpenToPowerID(self:GetPowerID());
end
