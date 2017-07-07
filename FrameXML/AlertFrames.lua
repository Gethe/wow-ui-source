ALERT_FRAME_COALESCE_CONTINUE = 1; -- Return to continue trying to find an alert to coalesce on to, coalescing failed
ALERT_FRAME_COALESCE_SUCCESS = 2; -- Return to signal coalescing was a success and that there's no longer a need to continue trying to coalesce onto other frames

-- [[ AlertFrameJustAnchorMixin ]] --
-- Used to insert a frame into the anchoring hierarchy
function CreateJustAnchorAlertSystem(anchorFrame)
	local justAnchorAlertSystem = CreateFromMixins(AlertFrameJustAnchorMixin);
	justAnchorAlertSystem:OnLoad(anchorFrame);
	return justAnchorAlertSystem;
end

AlertFrameJustAnchorMixin = {};

function AlertFrameJustAnchorMixin:OnLoad(anchorFrame)
	self.anchorFrame = anchorFrame;
end

function AlertFrameJustAnchorMixin:AdjustAnchors(relativeAlert)
	if self.anchorFrame:IsShown() then
		return self.anchorFrame;
	end
	return relativeAlert;
end

function AlertFrameJustAnchorMixin:CheckQueuedAlerts()
	-- Nothing can be queued on this.
end

-- [[ AlertFrameQueueMixin ]] --
-- A more complex alert frame system that can show multiple alerts and optionally queue additional alerts if the visible slots are full
function CreateAlertFrameQueueSystem(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue, coalesceFunction)
	local alertFrameQueue = CreateFromMixins(AlertFrameQueueMixin);
	alertFrameQueue:OnLoad(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue, coalesceFunction);
	return alertFrameQueue;
end

AlertFrameQueueMixin = {};

function OnPooledAlertFrameQueueReset(framePool, frame)
	FramePool_HideAndClearAnchors(framePool, frame);
	if frame.queue and not frame.queue:CheckQueuedAlerts() then
		AlertFrame:UpdateAnchors();
	end
end

function AlertFrameQueueMixin:OnLoad(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue, coalesceFunction)
	self.alertFramePool = CreateFramePool("BUTTON", UIParent, alertFrameTemplate, OnPooledAlertFrameQueueReset);
	self.setUpFunction = setUpFunction;
	self.coalesceFunction = coalesceFunction;
	self.maxAlerts = maxAlerts or 2;
	self.maxQueue = maxQueue or 6;
end

function AlertFrameQueueMixin:SetAlwaysReplace(alwaysReplace)
	self.alwaysReplace = alwaysReplace;
end

function AlertFrameQueueMixin:ShouldAlwaysReplace()
	return self.alwaysReplace;
end

function AlertFrameQueueMixin:OnFrameHide(frame)
	self.alertFramePool:Release(frame);
end

function AlertFrameQueueMixin:AddAlert(...)
	if self:CanShowMore() then
		self:ShowAlert(...);
		return true;
	elseif self:CanQueueMore() then
		self:QueueAlert(...);
		return true;
	end
	return false;
end

function AlertFrameQueueMixin:AddLocalizationHook(func)
	self.localizationHook = func;
end

function AlertFrameQueueMixin:ApplyCoalesceData(...)
	if self.coalesceFunction then
		for alertFrame in self.alertFramePool:EnumerateActive() do
			local coalescedResult = self.coalesceFunction(alertFrame, ...);
			if coalescedResult == ALERT_FRAME_COALESCE_SUCCESS then
				return true;
			end
		end
	end

	return false;
end

function AlertFrameQueueMixin:AddCoalesceData(...)
	if self.coalesceFunction then
		-- The only reason to queue coalesce data would be if we had something
		-- queued and it couldn't be added to a currently visible alert.
		if (not self:ApplyCoalesceData(...) and self:GetNumQueuedAlerts() > 0) then
			self:QueueCoalesceData(...);
		end
	end
end

function AlertFrameQueueMixin:CheckQueuedCoalesceData()
	if self.queuedCoalesceData then
		for coalesceData in pairs(self.queuedCoalesceData) do
			if self:ApplyCoalesceData(unpack(coalesceData, 1, coalesceData.numElements)) then
				self.queuedCoalesceData[coalesceData] = nil;
			end
		end
	end
end

function OnPooledAlertFrameQueueHide(frame)
	frame.queue:OnFrameHide(frame);
end

function AlertFrameQueueMixin:ShowAlert(...)
	local alertFrame, isNew = self.alertFramePool:Acquire();

	if isNew then
		alertFrame.queue = self;
		alertFrame:SetScript("OnHide", OnPooledAlertFrameQueueHide);

		if self.localizationHook then
			self.localizationHook(alertFrame);
		end
	end

	if self.setUpFunction then
		local result = self.setUpFunction(alertFrame, ...);
		if result == false then -- nil is success
			self.alertFramePool:Release(alertFrame);
			return false;
		end
	end
	
	AlertFrame:AddAlertFrame(alertFrame);
	self:CheckQueuedCoalesceData();

	return true;
end

function AlertFrameQueueMixin:CreateQueuedData(...)
	local data = { ... };
	data.numElements = select("#", ...);
	return data;
end

function AlertFrameQueueMixin:QueueAlert(...)
	self.queuedAlerts = self.queuedAlerts or {};
	local index = self:ShouldAlwaysReplace() and 1 or #self.queuedAlerts + 1;
	self.queuedAlerts[index] = self:CreateQueuedData(...);
end

function AlertFrameQueueMixin:QueueCoalesceData(...)
	self.queuedCoalesceData = self.queuedCoalesceData or {};
	local data = self:CreateQueuedData(...);
	self.queuedCoalesceData[data] = true;
end

function AlertFrameQueueMixin:GetNumVisibleAlerts()
	return self.alertFramePool:GetNumActive();
end

function AlertFrameQueueMixin:GetNumQueuedAlerts()
	return self.queuedAlerts and #self.queuedAlerts or 0;
end

function AlertFrameQueueMixin:CanShowMore()
	if AlertFrame:AreAlertsEnabled() then
		if self:ShouldAlwaysReplace() or self:GetNumVisibleAlerts() < self.maxAlerts then
			if (not self.canShowMoreConditionFunc or self.canShowMoreConditionFunc()) then
				return true;
			end
		end
	end

	return false;
end

function AlertFrameQueueMixin:CanQueueMore()
	return self:ShouldAlwaysReplace() or self:GetNumQueuedAlerts() < self.maxQueue;
end

function AlertFrameQueueMixin:CheckQueuedAlerts()
	while self:CanShowMore() and self:GetNumQueuedAlerts() > 0 do
		local queuedAlertData = table.remove(self.queuedAlerts, 1);
		return self:ShowAlert(unpack(queuedAlertData, 1, queuedAlertData.numElements));
	end
	return false;
end

function AlertFrameQueueMixin:AdjustAnchors(relativeAlert)
	for alertFrame in self.alertFramePool:EnumerateActive() do
		alertFrame:SetPoint("BOTTOM", relativeAlert, "TOP", 0, 10);
		relativeAlert = alertFrame;
	end
	return relativeAlert;
end

function AlertFrameQueueMixin:SetCanShowMoreConditionFunc(canShowMoreConditionFunc)
	self.canShowMoreConditionFunc = canShowMoreConditionFunc;
end

-- [[ AlertFrameMixin ]] --
AlertFrameMixin = {};

function AlertFrameMixin:OnLoad()
	self:RegisterEvent("ACHIEVEMENT_EARNED");
	self:RegisterEvent("CRITERIA_EARNED");
	self:RegisterEvent("LFG_COMPLETION_REWARD");
	self:RegisterEvent("SCENARIO_COMPLETED");
	self:RegisterEvent("LOOT_ITEM_ROLL_WON");
	self:RegisterEvent("SHOW_LOOT_TOAST");
	self:RegisterEvent("SHOW_LOOT_TOAST_UPGRADE");
	self:RegisterEvent("SHOW_PVP_FACTION_LOOT_TOAST");
	self:RegisterEvent("SHOW_RATED_PVP_REWARD_TOAST");
	self:RegisterEvent("PET_BATTLE_CLOSE");
	self:RegisterEvent("STORE_PRODUCT_DELIVERED");
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE");
    self:RegisterEvent("GARRISON_TALENT_COMPLETE");
	self:RegisterEvent("GARRISON_MISSION_FINISHED");
	self:RegisterEvent("GARRISON_FOLLOWER_ADDED");
	self:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED");
	self:RegisterEvent("NEW_RECIPE_LEARNED");
	self:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED");
	self:RegisterEvent("QUEST_TURNED_IN");
	self:RegisterEvent("QUEST_LOOT_RECEIVED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("NEW_PET_ADDED");
	self:RegisterEvent("NEW_MOUNT_ADDED");

	self.alertFrameSubSystems = {};

	-- True must always mean that a system is enabled, a single false will cause the system to queue alerts.
	self.shouldQueueAlertsFlags = {
		playerEnteredWorld = false,
		variablesLoaded = false,
	};
end

function AlertFrameMixin:SetEnabledFlag(flagName, enabled)
	local wereAlertsEnabled = self:AreAlertsEnabled();
	self.shouldQueueAlertsFlags[flagName] = enabled;
	local areAlertsEnabled = self:AreAlertsEnabled();

	if ( areAlertsEnabled and wereAlertsEnabled ~= areAlertsEnabled ) then
		for i, alertFrameSubSystem in ipairs(self.alertFrameSubSystems) do
			alertFrameSubSystem:CheckQueuedAlerts();
		end
	end
end

function AlertFrameMixin:SetPlayerEnteredWorld()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	self:SetEnabledFlag("playerEnteredWorld", true);
end

function AlertFrameMixin:SetVariablesLoaded()
	self:UnregisterEvent("VARIABLES_LOADED");
	self:SetEnabledFlag("variablesLoaded", true);
end

function AlertFrameMixin:SetAlertsEnabled(enabled, reason)
	self:SetEnabledFlag(reason, enabled);
end

function AlertFrameMixin:AreAlertsEnabled()
	for flagType, flagValue in pairs(self.shouldQueueAlertsFlags) do
		if not flagValue then return false; end
	end

	return true;
end

function AlertFrameMixin:OnEvent(event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self:SetPlayerEnteredWorld();
		return;
	elseif ( event == "VARIABLES_LOADED" ) then
		self:SetVariablesLoaded();
		return;
	end

	if ( event == "ACHIEVEMENT_EARNED" ) then
		if (IsKioskModeEnabled()) then
			return;
		end

		if ( not AchievementFrame ) then
			AchievementFrame_LoadUI();
		end

		AchievementAlertSystem:AddAlert(...);
	elseif ( event == "CRITERIA_EARNED" ) then
		if (IsKioskModeEnabled()) then
			return;
		end

		if ( not AchievementFrame ) then
			AchievementFrame_LoadUI();
		end

		CriteriaAlertSystem:AddAlert(...);
	elseif ( event == "LFG_COMPLETION_REWARD" ) then
		if ( C_Scenario.IsInScenario() and not C_Scenario.TreatScenarioAsDungeon() ) then
			local scenarioType = select(10, C_Scenario.GetInfo());
			if scenarioType ~= LE_SCENARIO_TYPE_LEGION_INVASION then
				ScenarioAlertSystem:AddAlert(AlertFrame:BuildScenarioRewardData());
			end
		else
			DungeonCompletionAlertSystem:AddAlert(AlertFrame:BuildLFGRewardData());
		end
	elseif ( event == "SCENARIO_COMPLETED" ) then
		local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, scenarioType, areaName = C_Scenario.GetInfo();
		if scenarioType == LE_SCENARIO_TYPE_LEGION_INVASION then
			local rewardQuestID = ...;
			if rewardQuestID then
				local alertName = areaName or scenarioName;
				local showBonusCompletion = hasBonusStep and isBonusStepComplete;
				InvasionAlertSystem:AddAlert(rewardQuestID, alertName, showBonusCompletion, xp, money);
			end
		end
	elseif ( event == "LOOT_ITEM_ROLL_WON" ) then
		local itemLink, quantity, rollType, roll, isUpgraded = ...;
		LootAlertSystem:AddAlert(itemLink, quantity, rollType, roll, nil, nil, nil, nil, nil, isUpgraded);
	elseif ( event == "SHOW_LOOT_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lootSource, lessAwesome, isUpgraded = ...;
		if ( typeIdentifier == "item" ) then
			LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, nil, nil, nil, lessAwesome, isUpgraded);
		elseif ( typeIdentifier == "money" ) then
			MoneyWonAlertSystem:AddAlert(quantity);
		elseif ( isPersonal and (typeIdentifier == "currency") ) then
			-- only toast currency for personal loot
			LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, true, false, lootSource);
		elseif ( typeIdentifier == "honor" ) then
			HonorAwardedAlertSystem:AddAlert(quantity);
		end
	elseif ( event == "SHOW_PVP_FACTION_LOOT_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lessAwesome = ...;
		if ( typeIdentifier == "item" ) then
			LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, false, true, nil, lessAwesome);
		elseif ( typeIdentifier == "money" ) then
			MoneyWonAlertSystem:AddAlert(quantity);
		elseif ( typeIdentifier == "currency" ) then
			LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, true, true);
		end
	elseif ( event == "SHOW_RATED_PVP_REWARD_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lessAwesome = ...;
		if ( typeIdentifier == "item" ) then
			LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, false, false, nil, lessAwesome, nil, nil, true);
		elseif ( typeIdentifier == "money" ) then
			MoneyWonAlertSystem:AddAlert(quantity);
		elseif ( typeIdentifier == "currency" ) then
			LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, true, false, nil, nil, nil, nil, true);
		end
	elseif ( event == "SHOW_LOOT_TOAST_UPGRADE") then
		local itemLink, quantity, specID, sex, baseQuality, isPersonal, lessAwesome = ...;
		LootUpgradeAlertSystem:AddAlert(itemLink, quantity, specID, baseQuality, nil, nil, lessAwesome);
	elseif ( event == "PET_BATTLE_CLOSE" ) then
		AchievementAlertSystem:CheckQueuedAlerts();
	elseif ( event == "STORE_PRODUCT_DELIVERED" ) then
		StorePurchaseAlertSystem:AddAlert(...);
	elseif ( event == "GARRISON_BUILDING_ACTIVATABLE" ) then
		local buildingName, garrisonType = ...;
		if ( garrisonType == C_Garrison.GetLandingPageGarrisonType() ) then
			GarrisonBuildingAlertSystem:AddAlert(buildingName, garrisonType);
			GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Play();
		end
    elseif ( event == "GARRISON_TALENT_COMPLETE") then
    	local garrisonType, doAlert = ...;
    	if ( doAlert ) then
			local talentID = C_Garrison.GetCompleteTalent(garrisonType);
			local talent = C_Garrison.GetTalent(talentID);
	        GarrisonTalentAlertSystem:AddAlert(garrisonType, talent);
		end
	elseif ( event == "GARRISON_MISSION_FINISHED" ) then
		local followerTypeID, missionID = ...;
		if ( DoesFollowerMatchCurrentGarrisonType(followerTypeID) ) then
			local validInstance = false;
			local _, instanceType = GetInstanceInfo();
			if ( instanceType == "none" or C_Garrison.IsOnGarrisonMap() ) then
				validInstance = true;
			end
			-- toast only if not in an instance (except for garrison), and mission frame is not shown, and not in combat
			if ( validInstance and not UnitAffectingCombat("player") ) then
				local missionFrame = _G[GarrisonFollowerOptions[followerTypeID].missionFrame];
				if (not missionFrame or not missionFrame:IsShown()) then
					GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Play();

					local missionInfo = C_Garrison.GetBasicMissionInfo(missionID);

					if ( followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
						GarrisonShipMissionAlertSystem:AddAlert(missionInfo);
					else
						GarrisonMissionAlertSystem:AddAlert(missionInfo);
					end
				end
			end
		end
	elseif ( event == "GARRISON_FOLLOWER_ADDED" ) then
		local followerID, name, class, level, quality, isUpgraded, texPrefix, followerType = ...;
		local followerInfo = C_Garrison.GetFollowerInfo(followerID);
		if (followerType == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
			GarrisonShipFollowerAlertSystem:AddAlert(followerID, name, class, texPrefix, level, quality, isUpgraded, followerInfo);
		else
			GarrisonFollowerAlertSystem:AddAlert(followerID, name, level, quality, isUpgraded, followerInfo);
		end
	elseif ( event == "GARRISON_RANDOM_MISSION_ADDED" ) then
		local _, missionID = ...;
		local missionInfo = C_Garrison.GetBasicMissionInfo(missionID);
		GarrisonRandomMissionAlertSystem:AddAlert(missionInfo);
	elseif ( event == "NEW_RECIPE_LEARNED" ) then
		NewRecipeLearnedAlertSystem:AddAlert(...);
	elseif ( event == "SHOW_LOOT_TOAST_LEGENDARY_LOOTED") then
		local itemLink = ...;
		LegendaryItemAlertSystem:AddAlert(itemLink);
	elseif ( event == "NEW_PET_ADDED") then
		local petID = ...;
		NewPetAlertSystem:AddAlert(petID);
	elseif ( event == "NEW_MOUNT_ADDED") then
		local mountID = ...;
		NewMountAlertSystem:AddAlert(mountID);
	elseif ( event == "QUEST_TURNED_IN" ) then
		local questID = ...;
		if QuestUtils_IsQuestWorldQuest(questID) then
			WorldQuestCompleteAlertSystem:AddAlert(AlertFrame:BuildQuestData(questID));
		end
	elseif ( event == "QUEST_LOOT_RECEIVED" ) then
		local questID, rewardItemLink = ...;
		local _, _, _, _, texture = GetItemInfoInstant(rewardItemLink);
		if QuestUtils_IsQuestWorldQuest(questID) then
			WorldQuestCompleteAlertSystem:AddCoalesceData(questID, rewardItemLink, texture);
		else
			-- May be invasion reward
			InvasionAlertSystem:AddCoalesceData(questID, rewardItemLink, texture);
		end
	end
end

function AlertFrameMixin:AddJustAnchorFrameSubSystem(anchorFrame)
	return self:AddAlertFrameSubSystem(CreateJustAnchorAlertSystem(anchorFrame));
end

function AlertFrameMixin:AddSimpleAlertFrameSubSystem(alertFrameTemplate, setUpFunction, coalesceFunction)
	local subSystem = self:AddAlertFrameSubSystem(CreateAlertFrameQueueSystem(alertFrameTemplate, setUpFunction, 1, 1, coalesceFunction));
	subSystem:SetAlwaysReplace(true);
	return subSystem;
end

function AlertFrameMixin:AddQueuedAlertFrameSubSystem(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue, coalesceFunction)
	return self:AddAlertFrameSubSystem(CreateAlertFrameQueueSystem(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue, coalesceFunction));
end

function AlertFrameMixin:AddAlertFrameSubSystem(alertFrameSubSystem)
	self.alertFrameSubSystems[#self.alertFrameSubSystems + 1] = alertFrameSubSystem;

	local STARTING_PRIORITY = 1000;
	self:SetSubSustemAnchorPriority(alertFrameSubSystem, STARTING_PRIORITY + #self.alertFrameSubSystems * 10);
	return alertFrameSubSystem;
end

function AlertFrameMixin:SetSubSustemAnchorPriority(alertFrameSubSystem, priority)
	alertFrameSubSystem.anchorPriority = priority;
	self.anchorPrioritiesDirty = true;
end

do
	local function AnchorPriorityComparator(left, right)
		return left.anchorPriority < right.anchorPriority;
	end
	function AlertFrameMixin:CleanAnchorPriorities()
		if self.anchorPrioritiesDirty then
			self.anchorPrioritiesDirty = nil;
			table.sort(self.alertFrameSubSystems, AnchorPriorityComparator);
		end
	end
end

function AlertFrameMixin:UpdateAnchors()
	self:CleanAnchorPriorities();

	local relativeFrame = self;
	for i, alertFrameSubSystem in ipairs(self.alertFrameSubSystems) do
		relativeFrame = alertFrameSubSystem:AdjustAnchors(relativeFrame);
	end
end

function AlertFrameMixin:AddAlertFrame(frame)
	self:UpdateAnchors();
	frame:Show();
	frame.animIn:Play();
	if frame.glow then
		if frame.glow.suppressGlow then
			frame.glow:Hide();
		else
			frame.glow:Show();
			frame.glow.animIn:Play();
		end
	end

	if frame.shine then
		frame.shine:Show();
		frame.shine.animIn:Play();
	end
	frame.waitAndAnimOut:Stop();	--Just in case it's already animating out, but we want to reinstate it.
	if frame:IsMouseOver() then
		frame.waitAndAnimOut.animOut:SetStartDelay(1);
	else
		frame.waitAndAnimOut.animOut:SetStartDelay(4.05);
		frame.waitAndAnimOut:Play();
	end
end

-- [[ AlertFrame Utility functions ]] --
function AlertFrameMixin:BuildLFGRewardData()
	local rewardData = {};

	local name, typeID, subtypeID, iconTextureFile, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards = GetLFGCompletionReward();

	rewardData.name = name;
	rewardData.subtypeID = subtypeID;
	rewardData.iconTextureFile = iconTextureFile;
	rewardData.moneyBase = moneyBase;
	rewardData.moneyVar = moneyVar;
	rewardData.experienceBase = experienceBase;
	rewardData.experienceVar = experienceVar;
	rewardData.numStrangers = numStrangers;
	rewardData.numRewards = numRewards;

	rewardData.moneyAmount = moneyBase + moneyVar * numStrangers;
	rewardData.experienceGained = experienceBase + experienceVar * numStrangers;

	if numRewards > 0 then
		rewardData.rewards = {};
		local rewards = rewardData.rewards;

		for i = 1, numRewards do
			local texturePath, quantity, isBonus, bonusQuantity = GetLFGCompletionRewardItem(i);
			local rewardItemLink = GetLFGCompletionRewardItemLink(i);
			rewards[#rewards + 1] = { texturePath = texturePath, quantity = quantity, isBonus = isBonus, bonusQuantity = bonusQuantity, rewardItemLink = rewardItemLink, rewardID = i };
		end
	end

	return rewardData;
end

function AlertFrameMixin:BuildScenarioRewardData()
	local rewardData = self:BuildLFGRewardData();

	local _, _, _, _, hasBonusStep, isBonusStepComplete = C_Scenario.GetInfo();
	rewardData.hasBonusStep = hasBonusStep;
	rewardData.isBonusStepComplete = isBonusStepComplete;

	return rewardData;
end

function AlertFrameMixin:BuildQuestData(questID)
	local taskName = C_TaskQuest.GetQuestInfoByQuestID(questID);

	local questData =
	{
		questID = questID,
		icon = WorldQuestCompleteAlertFrame_GetIconForQuestID(questID),
		taskName = taskName,
		money = GetQuestLogRewardMoney(questID),
		xp = GetQuestLogRewardXP(questID),
	};

	local currencyRewardCount = GetNumQuestLogRewardCurrencies(questID);
	if currencyRewardCount > 0 then
		questData.currencyRewards = {};
		local currencyRewards = questData.currencyRewards;

		for currencyIndex = 1, currencyRewardCount do
			local name, texture, count = GetQuestLogRewardCurrencyInfo(currencyIndex, questID);
			currencyRewards[currencyIndex] = texture;
		end
	end

	return questData;
end

-- [[ AlertFrameTemplate functions ]] --
function AlertFrameTemplate_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function AlertFrameTemplate_OnHide(self)
	AlertFrame:UpdateAnchors();
end

function AlertFrame_StopOutAnimation(frame)
	frame.waitAndAnimOut:Stop();
	frame.waitAndAnimOut.animOut:SetStartDelay(1);
end

function AlertFrame_ResumeOutAnimation(frame)
	frame.waitAndAnimOut:Play();
end

function AlertFrame_OnClick(self, button, down)
	if button == "RightButton" then
		self.animIn:Stop();
		if self.glow then
			self.glow.animIn:Stop();
		end
		if self.shine then
			self.shine.animIn:Stop();
		end
		self.waitAndAnimOut:Stop();
		self:Hide();
		return true;
	end

	return false;
end