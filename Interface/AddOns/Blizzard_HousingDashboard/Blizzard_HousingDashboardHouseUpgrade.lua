HouseLevelTrackFrameMixin = CreateFromMixins(RewardTrackFrameMixin)
HouseLevelTrackFrameMixin.elementWidth = 72;

HousingUpgradeFrameMixin = {};

HousingUpgradeFrameMixinEvents = {
	"HOUSE_LEVEL_FAVOR_UPDATED",
	"RECEIVED_HOUSE_LEVEL_REWARDS"
};

function HousingUpgradeFrameMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, HousingUpgradeFrameMixinEvents);
	self.houseList = {};
	self.rewardPoolLarge = CreateFramePool("FRAME", self.RewardsFrame, "HouseUpgradeRewardFrameLargeTemplate");
	self.rewardPoolSmall = CreateFramePool("FRAME", self.RewardsFrame, "HouseUpgradeRewardFrameSmallTemplate");

	self.maxLevel = C_Housing.GetMaxHouseLevel() + 1; --+1 for the "coming soon" level
	self.houseLevelRewardInfos = {};

	for i = 1, self.maxLevel - 1 do
		table.insert(self.houseLevelRewardInfos, {
			level = i;
		});
		C_Housing.GetHouseLevelRewardsForLevel(i); --will respond with RECEIVED_HOUSE_LEVEL_REWARDS
	end
	table.insert(self.houseLevelRewardInfos, {level = self.maxLevel, rewards = "no rewards"});

	self.CurrentLevelFrame.HouseBarFrame.Bar.BarFill:SetFinishAnimCallback(GenerateClosure(self.RefreshSelectedElement, self));

	self.hasSelectedLevel = false;
end

--These two asynchronous events can happen in either order and both need to happen before SelectLevel is called.
function HousingUpgradeFrameMixin:OnEvent(event, ...)
	if event == "HOUSE_LEVEL_FAVOR_UPDATED" then
		local houseLevelFavor = ...;
		self:SelectHouseLevel(houseLevelFavor);
	elseif event == "RECEIVED_HOUSE_LEVEL_REWARDS" then
		local level, rewards = ...;
		self.houseLevelRewardInfos[level].rewards = rewards;

		if self:AllRewardsLoaded() then
			self.TrackFrame:Init(self.houseLevelRewardInfos);
			if not self.hasSelectedLevel then
				local fromOnShow, forceRefresh = false, true;
				self:SelectLevel(self.displayLevel, fromOnShow, forceRefresh);
			end
		end
	end
end

function HousingUpgradeFrameMixin:AllRewardsLoaded()
	local allRewardsLoaded = true;
	for _, info in ipairs(self.houseLevelRewardInfos) do
		if not info.rewards then
			allRewardsLoaded = false;
			break;
		end
	end
	return allRewardsLoaded;
end

function HousingUpgradeFrameMixin:OnShow()
	self.CurrentLevelFrame.HouseBarFrame.Bar.BarFill:OnUpdate();
	EventRegistry:TriggerEvent("HousingUpgradeFrame.Shown");
end

function HousingUpgradeFrameMixin:OnHide()
	EventRegistry:TriggerEvent("HousingUpgradeFrame.Hidden");
end

function HousingUpgradeFrameMixin:OnHouseSelected(houseInfoID)
	local houseInfo = self.houseList[houseInfoID];
	if houseInfo then
		self.houseInfo = houseInfo;
		self.TeleportToHouseButton:SetHouseInfo(houseInfo);
	
		local bgAtlasPrefix = "housing-dashboard-bg-";
		local bgAtlasSuffix = C_Housing.GetNeighborhoodTextureSuffix(houseInfo.neighborhoodGUID);
		if bgAtlasSuffix then
			self.Background:SetAtlas(bgAtlasPrefix .. bgAtlasSuffix);
		end

		self.OwnerText:SetText(string.format(HOUSING_DASHBOARD_OWNERS_HOUSE, houseInfo.ownerName));
		self.AddressText:SetText(string.format(HOUSING_DASHBOARD_ADDRESS, houseInfo.plotID, houseInfo.neighborhoodName))

		C_Housing.GetCurrentHouseLevelFavor(houseInfo.houseGUID); --should respond with HOUSE_LEVEL_FAVOR_UPDATED
		self.WatchFavorButton:SetHouse(houseInfo.houseGUID);
	end
end

function HousingUpgradeFrameMixin:SelectHouseLevel(houseLevelFavor)
	self.actualLevel = houseLevelFavor.houseLevel;
	self.displayLevel = houseLevelFavor.houseLevel + 1;
	self.houseFavor = houseLevelFavor.houseFavor;
	self.houseFavorNeeded = C_Housing.GetHouseLevelFavorForLevel(self.actualLevel + 1);

	self.CurrentLevelFrame.HouseLevelText:SetText(self.actualLevel);
	self.CurrentLevelFrame.HouseLevelText:ClearAllPoints()
	-- The FRIZQT font has a problemm with rendering 1 (or numbers starting with 1), which causes it to be off center
	-- So, we have to detect that and manually bump it back into the center
	local levelString = tostring(self.actualLevel);
	local indexOf1 = string.find(levelString, "1");
	if indexOf1 == 1 then
		self.CurrentLevelFrame.HouseLevelText:SetPoint("CENTER", -2, -10);
	else
		self.CurrentLevelFrame.HouseLevelText:SetPoint("CENTER", 0, -10);
	end

	if not self.hasSelectedLevel and self:AllRewardsLoaded() then
		local fromOnShow, forceRefresh = false, true;
		self:SelectLevel(self.displayLevel, fromOnShow, forceRefresh);
	end
	local BarFill = self.CurrentLevelFrame.HouseBarFrame.Bar.BarFill;
	BarFill:SetHouseLevelFavor(self.actualLevel, houseLevelFavor);
	if self:IsVisible() then
		BarFill:OnUpdate();
	end
end

function HousingUpgradeFrameMixin:OnHouseListUpdated(houseList)
	self.houseList = houseList;
end

function HousingUpgradeFrameMixin:SelectLevel(level, fromOnShow, forceRefresh)
	local selectionIndex;
	local elements = self.TrackFrame:GetElements();
	for i, frame in ipairs(elements) do
		if frame:GetLevel() == level then
			selectionIndex = i;
			break;
		end
	end
	if selectionIndex then
		local skipSound = fromOnShow;
		self.TrackFrame:SetSelection(selectionIndex, forceRefresh, skipSound);
		self.hasSelectedLevel = true;
	end
end

function HousingUpgradeFrameMixin:RefreshSelectedElement()
	local elements = self.TrackFrame:GetElements();
	local frame = elements[self.displayLevel];
	local selected = true;
	frame:Refresh(self.actualLevel, self.displayLevel, selected, self.houseFavor);

	local neededFavor = C_Housing.GetHouseLevelFavorForLevel(self.displayLevel);
	self.TrackFrame.ReminderText:SetShown(self.houseFavor >= neededFavor and self.actualLevel < self.displayLevel);
	if self.houseFavor >= neededFavor and self.actualLevel < self.displayLevel then
		PlaySound(SOUNDKIT.HOUSING_HOUSE_UPGRADES_EXPERIENCE_FILLED);
	end
end

function HousingUpgradeFrameMixin:OnTrackUpdate(leftIndex, centerIndex, rightIndex, isMoving)
	local track = self.TrackFrame;
	local elements = track:GetElements();
	local selectedElement = elements[centerIndex];
	self.displayLevel = selectedElement:GetLevel();
	for i = leftIndex, rightIndex do
		local selected = not self.moving and centerIndex == i;
		local frame = elements[i];
		frame:Refresh(self.actualLevel, self.displayLevel, selected, self.houseFavor);
		local alpha = track:GetDesiredAlphaForIndex(i);
		frame:SetAlpha(alpha);
	end
	if not isMoving then
		self:SetRewards(self.displayLevel);
	end
end

local ValueTypeStrings = {
	[Enum.HouseLevelRewardValueType.InteriorDecor] = HOUSING_DASHBOARD_REWARD_INTERIOR_BUDGET,
	[Enum.HouseLevelRewardValueType.ExteriorDecor] = HOUSING_DASHBOARD_REWARD_EXTERIOR_BUDGET,
	[Enum.HouseLevelRewardValueType.Rooms] =         HOUSING_DASHBOARD_REWARD_ROOM_BUDGET,
	[Enum.HouseLevelRewardValueType.Fixtures] =      HOUSING_DASHBOARD_REWARD_FIXTURE_BUDGET,
};

local ValueTypePortraits = {
	[Enum.HouseLevelRewardValueType.InteriorDecor] = "house-decor-budget-icon",
	[Enum.HouseLevelRewardValueType.ExteriorDecor] = "house-outdoor-budget-icon",
	[Enum.HouseLevelRewardValueType.Rooms] =         "house-room-limit-icon",
	[Enum.HouseLevelRewardValueType.Fixtures] =      "house-fixture-budget-icon",
}

local ValueTypeTooltipTexts = {
	[Enum.HouseLevelRewardValueType.InteriorDecor] = HOUSING_DASHBOARD_REWARD_INTERIOR_TOOLTIP,
	[Enum.HouseLevelRewardValueType.ExteriorDecor] = HOUSING_DASHBOARD_REWARD_EXTERIOR_TOOLTIP,
	[Enum.HouseLevelRewardValueType.Rooms] =         HOUSING_DASHBOARD_REWARD_ROOM_TOOLTIP,
	[Enum.HouseLevelRewardValueType.Fixtures] =      HOUSING_DASHBOARD_REWARD_FIXTURE_TOOLTIP,
}

local QuestionMarkIconFileDataID = 134400;

function HousingUpgradeFrameMixin:SetRewards(selectedLevel)

	local neededFavor = C_Housing.GetHouseLevelFavorForLevel(selectedLevel);
	self.TrackFrame.ReminderText:SetShown(self.houseFavor >= neededFavor and self.actualLevel < selectedLevel)

	local rewards = self.houseLevelRewardInfos[selectedLevel].rewards;

	self.rewardPoolLarge:ReleaseAll();
	self.rewardPoolSmall:ReleaseAll();

	if rewards == "no rewards" then
		self.RewardsFrame.ComingSoonText:Show();
		return;
	else
		self.RewardsFrame.ComingSoonText:Hide();
	end

	local pool;
	if #rewards <= 4 then
		self.RewardsFrame.stride = 2;
		self.RewardsFrame.childXPadding = 10;
		pool = self.rewardPoolLarge;
	else
		self.RewardsFrame.stride = 3;
		self.RewardsFrame.childXPadding = 6;
		pool = self.rewardPoolSmall;
	end

	for i, rewardInfo in ipairs(rewards) do
		local rewardFrame = pool:Acquire();
		if pool == self.rewardPoolSmall then
			rewardFrame.PortraitFrame:SetPoint("LEFT", 10, 0);
		end
		rewardFrame.layoutIndex = i;

		if rewardInfo.type == Enum.HouseLevelRewardType.Value then
			rewardFrame.ValueIncreaseReward:Show();
			rewardFrame.ObjectReward:Hide();
			rewardFrame.PortraitFrame.UpArrow:Show();
			rewardFrame.ValueIncreaseReward.ValueName:SetText(ValueTypeStrings[rewardInfo.valueType]);
			rewardFrame.ValueIncreaseReward.OldValue:SetText(rewardInfo.oldValue);
			rewardFrame.ValueIncreaseReward.NewValue:SetText(rewardInfo.newValue);
			rewardFrame.PortraitFrame.Portrait:SetAtlas(ValueTypePortraits[rewardInfo.valueType]);
			rewardFrame.tooltipText = ValueTypeTooltipTexts[rewardInfo.valueType];
		elseif rewardInfo.type == Enum.HouseLevelRewardType.Object then
			rewardFrame.ObjectReward:Show();
			rewardFrame.ValueIncreaseReward:Hide();
			local portrait = rewardFrame.PortraitFrame.Portrait;
			local modelScene = rewardFrame.PortraitFrame.ModelScene;
			rewardFrame.PortraitFrame.UpArrow:Hide();
			rewardFrame.ObjectReward.ObjectName:SetText(rewardInfo.objectName);
			if rewardInfo.iconTexture or rewardInfo.iconAtlas then
				if rewardInfo.iconTexture then
					portrait:SetTexture(rewardInfo.iconTexture);
				else
					portrait:SetAtlas(rewardInfo.iconAtlas);
				end
			elseif rewardInfo.asset then
				local actor = modelScene:GetActorByTag(ActorTag);
				if actor then
					local modelID = rewardInfo.asset;
					actor:SetModelByFileID(modelID);
				end

				modelScene:Show();
				portrait:SetTexture(nil);
				portrait:Hide();
			else
				-- HOUSING_TODO: Remove or update placeholder replacement
				portrait:SetTexture(QuestionMarkIconFileDataID);
				portrait:Show();
			end
			rewardFrame.tooltipText = rewardInfo.tooltipText or HOUSING_DASHBOARD_REWARD_OBJECT_TOOLTIP;
		end

		rewardFrame:Show();
	end
	self.RewardsFrame:MarkDirty();
end

function HousingUpgradeFrameMixin:CancelLevelEffect()
	--intentionally blank
end

HouseUpgradeLevelFrameMixin = {};

function HouseUpgradeLevelFrameMixin:SetInfo(info)
	self.info = info;
end

function HouseUpgradeLevelFrameMixin:GetLevel()
	return self.info and self.info.level or 0;
end

function HouseUpgradeLevelFrameMixin:Refresh(actualLevel, displayLevel, selected, currentFavor)
	local level = self:GetLevel();
	local earned = level <= actualLevel;
	local enoughFavor = C_Housing.GetHouseLevelFavorForLevel(level) <= currentFavor;

	self.Pip:SetShown(enoughFavor and (actualLevel < level));
	self.Checkmark:SetShown(level <= actualLevel);

	self.Level:SetText(level);

	if selected then
		self.Plaque:SetAtlas("house-upgrade-reward-level-plaque-active");
		self.Level:SetTextColor(YELLOW_FONT_COLOR:GetRGB());
	elseif earned then
		self.Plaque:SetAtlas("house-upgrade-reward-level-plaque-complete");
		self.Level:SetTextColor(YELLOW_FONT_COLOR:GetRGB());
	else
		self.Plaque:SetAtlas("house-upgrade-reward-level-plaque-incomplete");
		self.Level:SetTextColor(WHITE_FONT_COLOR:GetRGB());
	end
end

HousingTeleportToHouseMixin = {};

local TeleportToHouseEvents = {
	"HOUSE_PLOT_ENTERED",
	"HOUSE_PLOT_EXITED",
	"SPELL_UPDATE_COOLDOWN",
};

local cooldownFormatter = CreateFromMixins(SecondsFormatterMixin);
cooldownFormatter:Init(
	60, --format with approximate under 1 minute ( < 1 minute )
	SecondsFormatter.Abbreviation.None,
	SecondsFormatterConstants.DontRoundUpLastUnit, 
	SecondsFormatterConstants.DontConvertToLower);
cooldownFormatter:SetMinInterval(SecondsFormatter.Interval.Minutes);

function HousingTeleportToHouseMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, TeleportToHouseEvents);
	self:UpdateState();
end

function HousingTeleportToHouseMixin:OnEvent(event, ...)
	if event == "HOUSE_PLOT_ENTERED" or event == "HOUSE_PLOT_EXITED" or event == "SPELL_UPDATE_COOLDOWN" then
		self:UpdateState();
	end
end

function HousingTeleportToHouseMixin:OnClick()
	if self.houseInfo then
		if self.teleportToPlot then
			C_Housing.TeleportHome(self.houseInfo.neighborhoodGUID, self.houseInfo.houseGUID, self.houseInfo.plotID);
		else
			C_Housing.ReturnAfterVisitingHouse();
		end
	end
	PlaySound(SOUNDKIT.HOUSING_HOUSE_UPGRADES_TELEPORT_HOME);
end

function HousingTeleportToHouseMixin:OnMouseDown()
	self.Icon:SetPoint("CENTER", 1, -1);
end

function HousingTeleportToHouseMixin:OnMouseUp()
	self.Icon:SetPoint("CENTER",0, 0);
end

function HousingTeleportToHouseMixin:SetHouseInfo(houseInfo)
	self.houseInfo = houseInfo;
	self:UpdateState();
end

function HousingTeleportToHouseMixin:UpdateCooldown()
	local cooldownInfo = C_Housing.GetVisitCooldownInfo();
	self.cooldownInfo = cooldownInfo;
	if cooldownInfo and cooldownInfo.isEnabled and self.teleportToPlot then
		self.Cooldown:SetCooldown(cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.modRate);
	else
		self.Cooldown:Clear();
	end
end

function HousingTeleportToHouseMixin:UpdateState()
	self.teleportToPlot = true;
	if C_HousingNeighborhood.CanReturnAfterVisitingHouse() then
		local currentNeighborhoodGUID = C_Housing.GetCurrentNeighborhoodGUID();
		if currentNeighborhoodGUID and currentNeighborhoodGUID == self.houseInfo.neighborhoodGUID then
			self.teleportToPlot = false;
		end
	end
	if self.teleportToPlot then
		self.Icon:SetAtlas("dashboard-panel-homestone-teleport-button");
		self.Icon:SetDesaturated(not self.houseInfo);
	else
		self.Icon:SetAtlas("dashboard-panel-homestone-teleport-out-button");
		self.Icon:SetDesaturated(false);
	end
	self:UpdateCooldown();
end

function HousingTeleportToHouseMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.teleportToPlot then
		if self.houseInfo then
			GameTooltip_AddHighlightLine(GameTooltip, HOUSING_DASHBOARD_TELEPORT_TO_PLOT);
			if self.cooldownInfo and self.cooldownInfo.isEnabled then
				local timeLeft = self.cooldownInfo.duration - (GetTime() - self.cooldownInfo.startTime);
				if timeLeft > 0 then
					GameTooltip_AddNormalLine(GameTooltip, COOLDOWN_REMAINING.." "..cooldownFormatter:Format(timeLeft));
				end
			end
		else
			GameTooltip_AddErrorLine(GameTooltip, HOUSING_DASHBOARD_NO_HOUSE_SELECTED);
		end
	else
		GameTooltip_AddHighlightLine(GameTooltip, HOUSING_DASHBOARD_RETURN);
	end
	
	GameTooltip:Show();
end

function HousingTeleportToHouseMixin:OnLeave()
	GameTooltip:Hide();
end

HouseUpgradeRewardFrameMixin = {};

function HouseUpgradeRewardFrameMixin:OnEnter()
	self.Background:SetAtlas("house-upgrade-reward-large-tile-bg-highlight")
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, self.tooltipText);
	GameTooltip:Show();
end

function HouseUpgradeRewardFrameMixin:OnLeave()
	self.Background:SetAtlas("house-upgrade-reward-large-tile-bg")
	GameTooltip:Hide();
end

HouseUpgradeCurrentLevelFrameMixin = {}

function HouseUpgradeCurrentLevelFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
	local parent = self:GetParent();
	GameTooltip_AddNormalLine(GameTooltip, string.format(HOUSING_DASHBOARD_HOUSE_LEVEL, parent.actualLevel));
	GameTooltip_AddHighlightLine(GameTooltip, string.format(HOUSING_DASHBOARD_NEIGHBORHOOD_FAVOR, parent.houseFavor, parent.houseFavorNeeded));
	GameTooltip:Show();
end

function HouseUpgradeCurrentLevelFrameMixin:OnLeave()
	GameTooltip:Hide();
end

HouseWatchFavorButtonMixin = {}

function HouseWatchFavorButtonMixin:OnShow()
	self:UpdateState();
end

function HouseWatchFavorButtonMixin:OnClick()
	self:UpdateState(); --I want UpdateState to control if it's checked not the default check behavior.
	if self:GetChecked() then
		C_Housing.SetTrackedHouseGuid(nil);
	else
		C_Housing.SetTrackedHouseGuid(self.houseGUID);
	end
	self:UpdateState();
	PlaySound(SOUNDKIT.HOUSING_HOUSE_UPGRADES_TOGGLE_EXPERIENCE);
end

function HouseWatchFavorButtonMixin:SetHouse(houseGUID)
	self.houseGUID = houseGUID;
	self:UpdateState();
end

function HouseWatchFavorButtonMixin:UpdateState()
	self:SetChecked(self.houseGUID and (C_Housing.GetTrackedHouseGuid() == self.houseGUID));
end

HouseUpgradeProgressBarMixin = {}

local BAR_PERCENTAGE_COVERED = 0.22;
local BAR_ANIM_TIME = 1.0;

function HouseUpgradeProgressBarMixin:OnLoad()
	self.targetPercentage = BAR_PERCENTAGE_COVERED / 2;
	self.currentPercentage = BAR_PERCENTAGE_COVERED / 2;
end

function HouseUpgradeProgressBarMixin:SetFinishAnimCallback(cb)
	self.finishAnimCallback = cb;
end

function HouseUpgradeProgressBarMixin:DoToEdges(name, ...)
	local leadEdge = self.LeadEdge;
	local threshold = self.Threshold;
	local flipBook = self.Flipbook;
	leadEdge[name](leadEdge, ...);
	threshold[name](threshold, ...);
	flipBook[name](flipBook, ...);
end

function HouseUpgradeProgressBarMixin:OnUpdate()
	local startingPercentage = self.currentPercentage;
	local endingPercentage = self.targetPercentage;
	local diff = startingPercentage - endingPercentage;
	if diff == 0 then
		return;
	end

	local function UpdateGivenPercentage(newPercentage)
		local rotateAmount = (0.5 - newPercentage) * 2 * math.pi;
		self:DoToEdges("SetRotation", rotateAmount);

		CooldownFrame_SetDisplayAsPercentage(self, newPercentage);
		self.currentPercentage = newPercentage;
	end

	local function UpdateBar(elapsedTime, duration)
		local timePercent = elapsedTime / duration;
		local newPercentage = math.min(startingPercentage + EasingUtil.InOutQuartic(timePercent) * (endingPercentage - startingPercentage), 1.0);
		
		UpdateGivenPercentage(newPercentage);
	end

	ScriptAnimationUtil.StartScriptAnimation(self, UpdateBar, BAR_ANIM_TIME, GenerateClosure(self.OnAnimationFinished, self));
	self.BarAnimation:Restart();
end

function HouseUpgradeProgressBarMixin:OnAnimationFinished()

	PlaySound(SOUNDKIT.HOUSING_HOUSE_UPGRADES_EXPERIENCE_GAIN_STOP);
	if self.loopSoundHandle then
		StopSound(self.loopSoundHandle);
		self.loopSoundHandle = nil;
	end
	self.finishAnimCallback();
end

function HouseUpgradeProgressBarMixin:SetHouseLevelFavor(level, houseLevelFavor)
	local neededForPreviousLevel = C_Housing.GetHouseLevelFavorForLevel(level);
	local neededForNextLevel = C_Housing.GetHouseLevelFavorForLevel(level + 1);
	local neededForThisLevel = neededForNextLevel - neededForPreviousLevel;

	local basePercentage = neededForThisLevel == 0 and 1 or ((houseLevelFavor.houseFavor - neededForPreviousLevel) / neededForThisLevel);
	basePercentage = basePercentage > 1 and 1 or basePercentage;
	-- The bottom portion of the circular progress bar is covered
	-- Because of this, the progress bar fill art is a semi circle and we need some special logic to determine the correct display percentage
	
	local barDegreesCovered = 360 * BAR_PERCENTAGE_COVERED;
	local barDegreesVisible = 360 - barDegreesCovered;
	local finalDisplayPercentage = ((basePercentage * barDegreesVisible) + (barDegreesCovered / 2)) / 360;

	self.targetPercentage = finalDisplayPercentage;

	if self.targetPercentage ~= self.currentPercentage then
		PlaySound(SOUNDKIT.HOUSING_HOUSE_UPGRADES_EXPERIENCE_GAIN_START);
		local _, soundHandle = PlaySound(SOUNDKIT.HOUSING_HOUSE_UPGRADES_EXPERIENCE_GAIN_LOOP);
		self.loopSoundHandle = soundHandle;
	end
end


