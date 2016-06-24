-- [[ AlertFrameSimpleMixin ]] --
-- Used for simple alert frames that only hold one frame at a time
function CreateSimpleAlertFrameSystem(alertFrame, setUpFunction, coalesceFunction)
	local simpleAlertFrameSystem = CreateFromMixins(AlertFrameSimpleMixin);
	simpleAlertFrameSystem:OnLoad(alertFrame, setUpFunction, coalesceFunction);
	return simpleAlertFrameSystem;
end

ALERT_FRAME_COALESCE_CONTINUE = 1; -- Return to run setup function, coalescing failed
ALERT_FRAME_COALESCE_STOP = 2; -- Return to signal coalescing was a success or not relevant, do not run setup function

AlertFrameSimpleMixin = {};

function AlertFrameSimpleMixin:OnLoad(alertFrame, setUpFunction, coalesceFunction)
	assert(alertFrame);
	self.alertFrame = alertFrame;
	self.setUpFunction = setUpFunction;
	self.coalesceFunction = coalesceFunction;
end

function AlertFrameSimpleMixin:AddAlert(...)
	if self.coalesceFunction and self.alertFrame:IsShown() then
		local coalescedResult = self.coalesceFunction(self.alertFrame, ...);
		if coalesced ~= ALERT_FRAME_COALESCE_CONTINUE then
			return true;
		end
	end

	if self.setUpFunction then
		local result = self.setUpFunction(self.alertFrame, ...);
		if result == false then -- nil is success
			self.alertFrame:Hide();
			return false;
		end
	end

	AlertFrame:AddAlertFrame(self.alertFrame);

	return true;
end

function AlertFrameSimpleMixin:AdjustAnchors(relativeAlert)
	if self.alertFrame:IsShown() then
		self.alertFrame:SetPoint("BOTTOM", relativeAlert, "TOP", 0, 10);
		return self.alertFrame;
	end
	return relativeAlert;
end

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

-- [[ AlertFrameQueueMixin ]] --
-- A more complex alert frame system that can show multiple alerts and optionally queue additional alerts if the visible slots are full
function CreateAlertFrameQueueSystem(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue)
	local alertFrameQueue = CreateFromMixins(AlertFrameQueueMixin);
	alertFrameQueue:OnLoad(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue);
	return alertFrameQueue;
end

AlertFrameQueueMixin = {};

function OnPooledAlertFrameQueueReset(framePool, frame)
	FramePool_HideAndClearAnchors(framePool, frame);
	if frame.queue and not frame.queue:CheckQueuedAlerts() then
		AlertFrame:UpdateAnchors();
	end
end

function AlertFrameQueueMixin:OnLoad(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue)
	self.alertFramePool = CreateFramePool("BUTTON", UIParent, alertFrameTemplate, OnPooledAlertFrameQueueReset);
	self.setUpFunction = setUpFunction;
	self.maxAlerts = maxAlerts or 2;
	self.maxQueue = maxQueue or 6;
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

function OnPooledAlertFrameQueueHide(frame)
	frame.queue:OnFrameHide(frame);
end

function AlertFrameQueueMixin:ShowAlert(...)
	local alertFrame, isNew = self.alertFramePool:Acquire();
	if isNew then
		alertFrame.queue = self;
		alertFrame:SetScript("OnHide", OnPooledAlertFrameQueueHide);
	end
	if self.setUpFunction then
		local result = self.setUpFunction(alertFrame, ...);
		if result == false then -- nil is success
			self.alertFramePool:Release(alertFrame);
			return false;
		end
	end

	AlertFrame:AddAlertFrame(alertFrame);
	return true;
end

function AlertFrameQueueMixin:QueueAlert(...)
	self.queuedAlerts = self.queuedAlerts or {};

	local data = { ... };
	data.numElements = select("#", ...);
	self.queuedAlerts[#self.queuedAlerts + 1] = data;
end

function AlertFrameQueueMixin:GetNumVisibleAlerts()
	return self.alertFramePool:GetNumActive();
end

function AlertFrameQueueMixin:GetNumQueuedAlerts()
	return self.queuedAlerts and #self.queuedAlerts or 0;
end

function AlertFrameQueueMixin:CanShowMore()
	return self:GetNumVisibleAlerts() < self.maxAlerts and (not self.canShowMoreConditionFunc or self.canShowMoreConditionFunc());
end

function AlertFrameQueueMixin:CanQueueMore()
	return self:GetNumQueuedAlerts() < self.maxQueue;
end

function AlertFrameQueueMixin:CheckQueuedAlerts()
	if self:CanShowMore() and self:GetNumQueuedAlerts() > 0 then
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

	self.alertFrameSubSystems = {};
end

function AlertFrameMixin:OnEvent(event, ...)
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
				ScenarioAlertSystem:AddAlert();
			end
		else
			DungeonCompletionAlertSystem:AddAlert();
		end
	elseif ( event == "SCENARIO_COMPLETED" ) then
		local scenarioType = select(10, C_Scenario.GetInfo());
		if scenarioType == LE_SCENARIO_TYPE_LEGION_INVASION then
			local rewardQuestID = ...;
			if rewardQuestID then
				InvasionAlertSystem:AddAlert(rewardQuestID);
			end
		end
	elseif ( event == "LOOT_ITEM_ROLL_WON" ) then
		local itemLink, quantity, rollType, roll, isUpgraded = ...;
		LootAlertSystem:AddAlert(itemLink, quantity, rollType, roll, nil, nil, nil, nil, nil, isUpgraded);
	elseif ( event == "SHOW_LOOT_TOAST" ) then
		local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lootSource, lessAwesome, isUpgraded = ...;
		if ( typeIdentifier == "item" ) then
			LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, nil, nil, nil, lessAwesome, isUpgraded, isPersonal);
		elseif ( typeIdentifier == "money" ) then
			MoneyWonAlertSystem:AddAlert(quantity);
		elseif ( isPersonal and (typeIdentifier == "currency") ) then
			-- only toast currency for personal loot
			LootAlertSystem:AddAlert(itemLink, quantity, nil, nil, specID, true, false, lootSource);
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
	elseif ( event == "SHOW_LOOT_TOAST_UPGRADE") then
		local itemLink, quantity, specID, sex, baseQuality, isPersonal, lessAwesome = ...;
		LootUpgradeAlertSystem:AddAlert(itemLink, quantity, specID, baseQuality, nil, nil, lessAwesome);
	elseif ( event == "PET_BATTLE_CLOSE" ) then
		AchievementAlertSystem:CheckQueuedAlerts();
	elseif ( event == "STORE_PRODUCT_DELIVERED" ) then
		StorePurchaseAlertSystem:AddAlert(...);
	elseif ( event == "GARRISON_BUILDING_ACTIVATABLE" ) then
		GarrisonBuildingAlertSystem:AddAlert(...);
		GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Play();
    elseif ( event == "GARRISON_TALENT_COMPLETE") then
        GarrisonTalentAlertSystem:AddAlert(...);
	elseif ( event == "GARRISON_MISSION_FINISHED" ) then
		local validInstance = false;
		local _, instanceType = GetInstanceInfo();
		if ( instanceType == "none" or C_Garrison.IsOnGarrisonMap() ) then
			validInstance = true;
		end
		-- toast only if not in an instance (except for garrison), and mission frame is not shown, and not in combat
		if ( validInstance and not UnitAffectingCombat("player") ) then
			local followerTypeID, missionID = ...;
			local missionFrame = _G[GarrisonFollowerOptions[followerTypeID].missionFrame];
			if (not missionFrame or not missionFrame:IsShown()) then
				GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Play();

				if ( followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
					GarrisonShipMissionAlertSystem:AddAlert(missionID);
				else
					GarrisonMissionAlertSystem:AddAlert(missionID);
				end
			end
		end
	elseif ( event == "GARRISON_FOLLOWER_ADDED" ) then
		local followerID, name, class, level, quality, isUpgraded, texPrefix, followerType = ...;
		if (followerType == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
			GarrisonShipFollowerAlertSystem:AddAlert(followerID, name, class, texPrefix, level, quality, isUpgraded);
		else
			GarrisonFollowerAlertSystem:AddAlert(followerID, name, level, quality, isUpgraded);
		end
	elseif ( event == "GARRISON_RANDOM_MISSION_ADDED" ) then
		GarrisonRandomMissionAlertSystem:AddAlert(select(2, ...));
	elseif ( event == "NEW_RECIPE_LEARNED" ) then
		NewRecipeLearnedAlertSystem:AddAlert(...);
	elseif ( event == "SHOW_LOOT_TOAST_LEGENDARY_LOOTED") then
		local itemLink = ...;
		LegendaryItemAlertSystem:AddAlert(itemLink);
	elseif ( event == "QUEST_TURNED_IN" ) then
		local questID = ...;
		if QuestMapFrame_IsQuestWorldQuest(questID) then
			WorldQuestCompleteAlertSystem:AddAlert(questID);
		end
	elseif ( event == "QUEST_LOOT_RECEIVED" ) then
		local questID, rewardItemLink = ...;
		if QuestMapFrame_IsQuestWorldQuest(questID) then
			WorldQuestCompleteAlertSystem:AddAlert(questID, rewardItemLink);
		else
			-- May be invasion reward
			InvasionAlertSystem:AddAlert(questID, rewardItemLink);
		end
	end
end

function AlertFrameMixin:AddJustAnchorFrameSubSystem(anchorFrame)
	return self:AddAlertFrameSubSystem(CreateJustAnchorAlertSystem(anchorFrame));
end

function AlertFrameMixin:AddSimpleAlertFrameSubSystem(alertFrame, setUpFunction, coalesceFunction)
	return self:AddAlertFrameSubSystem(CreateSimpleAlertFrameSystem(alertFrame, setUpFunction, coalesceFunction));
end

function AlertFrameMixin:AddQueuedAlertFrameSubSystem(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue)
	return self:AddAlertFrameSubSystem(CreateAlertFrameQueueSystem(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue));
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

	self:UpdateAnchors();
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