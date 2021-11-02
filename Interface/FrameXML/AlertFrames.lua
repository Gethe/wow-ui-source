ALERT_FRAME_COALESCE_CONTINUE = 1; -- Return to continue trying to find an alert to coalesce on to, coalescing failed
ALERT_FRAME_COALESCE_SUCCESS = 2; -- Return to signal coalescing was a success and that there's no longer a need to continue trying to coalesce onto other frames

-- [[ ContainedAlertSystem ]] --

ContainedAlertSubSystemMixin = {};

function ContainedAlertSubSystemMixin:OnLoad(containedAlertFrame)
	self:ContainFrame(containedAlertFrame);
end

function ContainedAlertSubSystemMixin:ContainFrame(containedAlertFrame)
	containedAlertFrame:SetAlertContainer(self:GetAlertContainer());
end

function ContainedAlertSubSystemMixin:SetAlertContainer(alertContainer)
	self.alertContainer = alertContainer;
end

function ContainedAlertSubSystemMixin:GetAlertContainer()
	return self.alertContainer;
end

-- [[ AlertFrameExternallyAnchoredMixin ]] --
-- Used to insert a frame into the anchoring hierarchy, but that frame is positioned by something else.
-- This only serves to all the rest of the systems to pass through this frame
-- or use it in the anchoring chain.
AlertFrameExternallyAnchoredMixin = CreateFromMixins(ContainedAlertSubSystemMixin);

function AlertFrameExternallyAnchoredMixin:OnLoad(anchorFrame)
	ContainedAlertSubSystemMixin.OnLoad(self, anchorFrame);
	self.anchorFrame = anchorFrame;
end

function AlertFrameExternallyAnchoredMixin:AdjustAnchors(relativeAlert)
	if self.anchorFrame:IsShown() then
		return self.anchorFrame;
	end
	return relativeAlert;
end

function AlertFrameExternallyAnchoredMixin:CheckQueuedAlerts()
	-- Nothing can be queued on this.
end

-- [[ AlertFrameAutoAnchoredMixin ]] --
-- Used to insert a frame into the anchoring hierarchy, and this frame knows how to
-- automatically position itself relative to the other contained alerts based on
-- justification from the container it belongs to.
AlertFrameAutoAnchoredMixin = CreateFromMixins(ContainedAlertSubSystemMixin);

function AlertFrameAutoAnchoredMixin:OnLoad(anchorFrame)
	ContainedAlertSubSystemMixin.OnLoad(self, anchorFrame);
	self.anchorFrame = anchorFrame;
end

function AlertFrameAutoAnchoredMixin:AdjustAnchors(relativeAlert)
	local anchorFrame = self.anchorFrame;

	if anchorFrame:IsShown() then
		local point, relativePoint = anchorFrame:GetAlertContainer():GetPointsForJustification(relativeAlert);

		anchorFrame:ClearAllPoints();
		anchorFrame:SetPoint(point, relativeAlert, relativePoint, 0, 0);

		if anchorFrame.OnAlertAnchorUpdated then
			anchorFrame:OnAlertAnchorUpdated();
		end

		return anchorFrame;
	end

	return relativeAlert;
end

function AlertFrameAutoAnchoredMixin:CheckQueuedAlerts()
	-- Nothing can be queued on this.
end

-- [[ AlertFrameQueueMixin ]] --
-- A more complex alert frame system that can show multiple alerts and optionally queue additional alerts if the visible slots are full
AlertFrameQueueMixin = CreateFromMixins(ContainedAlertSubSystemMixin);

function OnPooledAlertFrameQueueReset(framePool, frame)
	FramePool_HideAndClearAnchors(framePool, frame);
	if frame.queue and not frame.queue:CheckQueuedAlerts() then
		frame.queue:GetAlertContainer():UpdateAnchors();
	end
end

function AlertFrameQueueMixin:OnLoad(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue, coalesceFunction)
	self.alertFramePool = CreateFramePool("ContainedAlertFrame", UIParent, alertFrameTemplate, OnPooledAlertFrameQueueReset);
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
	if frame.OnRelease then
		frame:OnRelease();
	end
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
		self:ContainFrame(alertFrame);
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

	self:GetAlertContainer():AddAlertFrame(alertFrame);
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
	if self:GetAlertContainer():AreAlertsEnabled() then
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

-- [[ AlertContainerMixin ]] --

AlertContainerMixin = {};

function AlertContainerMixin:OnLoad()
	self.alertFrameSubSystems = {};

	-- True must always mean that a system is enabled, a single false will cause the system to queue alerts.
	self.shouldQueueAlertsFlags = {
		playerEnteredWorld = false,
		variablesLoaded = false,
	};

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("VARIABLES_LOADED");
end

function AlertContainerMixin:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:SetPlayerEnteredWorld();
	elseif event == "VARIABLES_LOADED" then
		self:SetVariablesLoaded();
	end
end

function AlertContainerMixin:SetEnabledFlag(flagName, enabled)
	local wereAlertsEnabled = self:AreAlertsEnabled();
	self.shouldQueueAlertsFlags[flagName] = enabled;
	local areAlertsEnabled = self:AreAlertsEnabled();

	if ( areAlertsEnabled and wereAlertsEnabled ~= areAlertsEnabled ) then
		for i, alertFrameSubSystem in ipairs(self.alertFrameSubSystems) do
			alertFrameSubSystem:CheckQueuedAlerts();
		end
	end
end

function AlertContainerMixin:SetPlayerEnteredWorld()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	self:SetEnabledFlag("playerEnteredWorld", true);
end

function AlertContainerMixin:SetVariablesLoaded()
	self:UnregisterEvent("VARIABLES_LOADED");
	self:SetEnabledFlag("variablesLoaded", true);
end

function AlertContainerMixin:SetAlertsEnabled(enabled, reason)
	self:SetEnabledFlag(reason, enabled);
end

function AlertContainerMixin:AreAlertsEnabled()
	for flagType, flagValue in pairs(self.shouldQueueAlertsFlags) do
		if not flagValue then return false; end
	end

	return true;
end

function AlertContainerMixin:CreateSubSystem(subSystemMixin, ...)
	local subSystem = CreateFromMixins(subSystemMixin);
	subSystem:SetAlertContainer(self);
	subSystem:OnLoad(...);
	return subSystem;
end

function AlertContainerMixin:AddExternallyAnchoredSubSystem(anchorFrame)
	local subSystem = self:CreateSubSystem(AlertFrameExternallyAnchoredMixin, anchorFrame);
	return self:AddAlertFrameSubSystem(subSystem);
end

function AlertContainerMixin:AddAutoAnchoredSubSystem(anchorFrame)
	local subSystem = self:CreateSubSystem(AlertFrameAutoAnchoredMixin, anchorFrame);
	return self:AddAlertFrameSubSystem(subSystem);
end

function AlertContainerMixin:CreateQueuedSubSystem(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue, coalesceFunction)
	return self:CreateSubSystem(AlertFrameQueueMixin, alertFrameTemplate, setUpFunction, maxAlerts, maxQueue, coalesceFunction);
end

function AlertContainerMixin:AddSimpleAlertFrameSubSystem(alertFrameTemplate, setUpFunction, coalesceFunction)
	local subSystem = self:AddAlertFrameSubSystem(self:CreateQueuedSubSystem(alertFrameTemplate, setUpFunction, 1, 1, coalesceFunction));
	subSystem:SetAlwaysReplace(true);
	return subSystem;
end

function AlertContainerMixin:AddQueuedAlertFrameSubSystem(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue, coalesceFunction)
	return self:AddAlertFrameSubSystem(self:CreateQueuedSubSystem(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue, coalesceFunction));
end

function AlertContainerMixin:AddAlertFrameSubSystem(alertFrameSubSystem)
	self.alertFrameSubSystems[#self.alertFrameSubSystems + 1] = alertFrameSubSystem;

	local STARTING_PRIORITY = 1000;
	self:SetSubSystemAnchorPriority(alertFrameSubSystem, STARTING_PRIORITY + #self.alertFrameSubSystems * 10);
	return alertFrameSubSystem;
end

function AlertContainerMixin:SetSubSystemAnchorPriority(alertFrameSubSystem, priority)
	alertFrameSubSystem.anchorPriority = priority;
	self.anchorPrioritiesDirty = true;
end

do
	local function AnchorPriorityComparator(left, right)
		return left.anchorPriority < right.anchorPriority;
	end

	function AlertContainerMixin:CleanAnchorPriorities()
		if self.anchorPrioritiesDirty then
			self.anchorPrioritiesDirty = nil;
			table.sort(self.alertFrameSubSystems, AnchorPriorityComparator);
		end
	end
end

function AlertContainerMixin:UpdateAnchors()
	self:CleanAnchorPriorities();

	local relativeFrame = self;
	for i, alertFrameSubSystem in ipairs(self.alertFrameSubSystems) do
		relativeFrame = alertFrameSubSystem:AdjustAnchors(relativeFrame);
	end
end

function AlertContainerMixin:SetJustification(justification)
	if self.justification ~= justification then
		self.justification = justification;
		self:UpdateAnchors();
	end
end

function AlertContainerMixin:GetJustification()
	return self.justification or "CENTER";
end

local justificationLookupsForInitialFrame =
{
	["LEFT"] = { point = "BOTTOMLEFT", relativePoint = "BOTTOMLEFT" },
	["CENTER"] = { point = "BOTTOM", relativePoint = "BOTTOM" },
	["RIGHT"] = { point = "BOTTOMRIGHT", relativePoint = "BOTTOMRIGHT" },
};

local justificationLookupsForSubsequentFrames =
{
	["LEFT"] = { point = "BOTTOMLEFT", relativePoint = "TOPLEFT" },
	["CENTER"] = { point = "BOTTOM", relativePoint = "TOP" },
	["RIGHT"] = { point = "BOTTOMRIGHT", relativePoint = "TOPRIGHT" },
};

function AlertContainerMixin:GetPointsForJustification(relativeFrame)
	local justification = self:GetJustification();
	local lookupTable = (relativeFrame == self) and justificationLookupsForInitialFrame or justificationLookupsForSubsequentFrames;
	local pointsTable = lookupTable[justification];
	return pointsTable.point, pointsTable.relativePoint;
end

function AlertContainerMixin:AddAlertFrame(frame)
	self:UpdateAnchors();
	AlertFrame_ShowNewAlert(frame);
end

-- [[ AlertFrameMixin ]] --
AlertFrameMixin = {};

function AlertFrameMixin:OnLoad()
	AlertContainerMixin.OnLoad(self);

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
	self:RegisterEvent("ENTITLEMENT_DELIVERED");
	self:RegisterEvent("RAF_ENTITLEMENT_DELIVERED");
	self:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE");
    self:RegisterEvent("GARRISON_TALENT_COMPLETE");
	self:RegisterEvent("GARRISON_MISSION_FINISHED");
	self:RegisterEvent("GARRISON_FOLLOWER_ADDED");
	self:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED");
	self:RegisterEvent("NEW_RECIPE_LEARNED");
	self:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED");
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_LOOTED");
	self:RegisterEvent("QUEST_TURNED_IN");
	self:RegisterEvent("QUEST_LOOT_RECEIVED");
	self:RegisterEvent("NEW_PET_ADDED");
	self:RegisterEvent("NEW_MOUNT_ADDED");
	self:RegisterEvent("NEW_TOY_ADDED");
	self:RegisterEvent("NEW_RUNEFORGE_POWER_ADDED");
	self:RegisterEvent("TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED");
end

function CreateContinuableContainerForLFGRewards()
	local continuableContainer = ContinuableContainer:Create();
	local rewardCount = select(10, GetLFGCompletionReward());
	for i = 1, rewardCount or 0 do
		local _, _, _, _, _, _, id, objectType = GetLFGCompletionRewardItem(i);
		if objectType == "item" then
			local item = Item:CreateFromItemID(id);
			continuableContainer:AddContinuable(item);
		end
	end
	return continuableContainer;
end

function AlertFrameMixin:OnEvent(event, ...)
	AlertContainerMixin.OnEvent(self, event, ...);

	if ( event == "ACHIEVEMENT_EARNED" ) then
		if (Kiosk.IsEnabled()) then
			return;
		end

		if ( not AchievementFrame ) then
			AchievementFrame_LoadUI();
		end

		AchievementAlertSystem:AddAlert(...);
	elseif ( event == "CRITERIA_EARNED" ) then
		if (Kiosk.IsEnabled()) then
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
				if (not self:ShouldSupressDungeonOrScenarioAlert()) then 
					local continuableContainer = CreateContinuableContainerForLFGRewards();
					if continuableContainer then
						continuableContainer:ContinueOnLoad(function()
							ScenarioAlertSystem:AddAlert(self:BuildScenarioRewardData());
						end);
					end
				end
			end
		else
			if (not self:ShouldSupressDungeonOrScenarioAlert()) then 
				local continuableContainer = CreateContinuableContainerForLFGRewards();
				if continuableContainer then
					continuableContainer:ContinueOnLoad(function()
						DungeonCompletionAlertSystem:AddAlert(self:BuildLFGRewardData());
					end);
				end
			end
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
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lootSource, lessAwesome, isUpgraded, isCorrupted = ...;
		if ( typeIdentifier == "item" ) then
			LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, nil, nil, nil, lessAwesome, isUpgraded, isCorrupted);
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
	elseif ( event == "ENTITLEMENT_DELIVERED" ) then
		EntitlementDeliveredAlertSystem:AddAlert(...);
	elseif ( event == "RAF_ENTITLEMENT_DELIVERED" ) then
		RafRewardDeliveredAlertSystem:AddAlert(...);
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
			local talent = C_Garrison.GetTalentInfo(talentID);
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

					if ( followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_2 ) then
						GarrisonShipMissionAlertSystem:AddAlert(missionInfo);
					else
						GarrisonMissionAlertSystem:AddAlert(missionInfo);
					end
				end
			end
		end
	elseif ( event == "GARRISON_FOLLOWER_ADDED" ) then
		local followerID, name, class, level, quality, isUpgraded, textureKit, followerType = ...;
		local followerInfo = C_Garrison.GetFollowerInfo(followerID);
		if (followerType == Enum.GarrisonFollowerType.FollowerType_6_2) then
			GarrisonShipFollowerAlertSystem:AddAlert(followerID, name, class, textureKit, level, quality, isUpgraded, followerInfo);
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
	elseif ( event == "AZERITE_EMPOWERED_ITEM_LOOTED" ) then
		local itemLink = ...;
		LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, false);
	elseif ( event == "NEW_PET_ADDED") then
		local petID = ...;
		NewPetAlertSystem:AddAlert(petID);
	elseif ( event == "NEW_MOUNT_ADDED") then
		local mountID = ...;
		NewMountAlertSystem:AddAlert(mountID);
	elseif ( event == "QUEST_TURNED_IN" ) then
		local questID = ...;
		if QuestUtils_IsQuestWorldQuest(questID) then
			WorldQuestCompleteAlertSystem:AddAlert(self:BuildQuestData(questID));
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
	elseif ( event == "NEW_TOY_ADDED") then
		local toyID = ...;
		NewToyAlertSystem:AddAlert(toyID);
	elseif ( event == "NEW_RUNEFORGE_POWER_ADDED") then
		local powerID = ...;
		NewRuneforgePowerAlertSystem:AddAlert(powerID);
	elseif ( event == "TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED") then
		local itemModifiedAppearanceID = ...;
		NewCosmeticAlertFrameSystem:AddAlert(itemModifiedAppearanceID);
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
	local taskName, factionID, capped, displayAsObjective = C_TaskQuest.GetQuestInfoByQuestID(questID);

	local questData =
	{
		questID = questID,
		icon = WorldQuestCompleteAlertFrame_GetIconForQuestID(questID),
		taskName = taskName,
		money = GetQuestLogRewardMoney(questID),
		xp = GetQuestLogRewardXP(questID),
		displayAsObjective = displayAsObjective,
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

function AlertFrameMixin:ShouldSupressDungeonOrScenarioAlert()
	if	(IslandsPartyPoseFrame) then 
		if (IslandsPartyPoseFrame:IsVisible()) then 
			return true; 
		end
	elseif (WarfrontsPartyPoseFrame) then 
		if(WarfrontsPartyPoseFrame:IsVisible()) then 
			return true;
		end
	end
	return false;
end

-- [[ AlertFrameTemplate functions ]] --
function AlertFrame_PauseOutAnimation(frame)
	frame.waitAndAnimOut:Stop();
end

function AlertFrame_PlayOutAnimation(frame, optionalDelay)
	frame.waitAndAnimOut.animOut:SetStartDelay(optionalDelay or 1);
	frame.waitAndAnimOut:Play();
end

function AlertFrame_ResumeOutAnimation(frame)
	if frame:ManagesOwnOutroAnimation() then
		-- TODO: If the mouse was over the alert when it was initially shown, and then leaves (by accident or on purpose)
		-- that the initial delay of 4 seconds will be reduced to 1 here...this was previous behavior, but it might be
		-- desirable to track how long the mouse was over the frame and to adjust the initial delay accordingly.
		AlertFrame_PlayOutAnimation(frame, 1);
	end
end

function AlertFrame_PlayIntroAnimation(frame)
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
end

function AlertFrame_PlayOutroAnimation(frame)
	AlertFrame_PauseOutAnimation(frame);

	if not frame:IsMouseOver() then
		AlertFrame_PlayOutAnimation(frame, frame.duration or 4);
	end
end

function AlertFrame_PlayAnimations(frame)
	AlertFrame_PlayIntroAnimation(frame);

	if frame:ManagesOwnOutroAnimation() then
		AlertFrame_PlayOutroAnimation(frame);
	end
end

function AlertFrame_ShowNewAlert(frame)
	frame:Show();
	AlertFrame_PlayAnimations(frame);
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