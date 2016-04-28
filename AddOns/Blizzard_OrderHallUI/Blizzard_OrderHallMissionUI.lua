---------------------------------------------------------------------------------
--- Garrison Follower Options				                                  ---
---------------------------------------------------------------------------------

-- These are follower options that depend on this AddOn being loaded, and so they can't be set in GarrisonBaseUtils.
GarrisonFollowerOptions[LE_FOLLOWER_TYPE_GARRISON_7_0].missionFollowerSortFunc =  GarrisonFollowerList_PrioritizeSpecializationAbilityMissionSort;
GarrisonFollowerOptions[LE_FOLLOWER_TYPE_GARRISON_7_0].missionFollowerInitSortFunc = GarrisonFollowerList_InitializePrioritizeSpecializationAbilityMissionSort;

---------------------------------------------------------------------------------
-- Order Hall Mission Frame
---------------------------------------------------------------------------------

OrderHallMission = { }

local function SetupMaterialFrame(materialFrame, currency, currencyTexture)
	materialFrame.currencyType = currency;
	materialFrame.Icon:SetTexture(currencyTexture);
	materialFrame.Icon:SetSize(18, 18);
	materialFrame.Icon:SetPoint("RIGHT", materialFrame, "RIGHT", -14, 0);
end

function OrderHallMission:OnLoadMainFrame()
	self.followerTypeID = LE_FOLLOWER_TYPE_GARRISON_7_0;

	local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0);
	local _, _, currencyTexture = GetCurrencyInfo(primaryCurrency);

	self.MissionTab.MissionPage.CostFrame.CostIcon:SetTexture(currencyTexture);
	self.MissionTab.MissionPage.CostFrame.CostIcon:SetSize(18, 18);
	self.MissionTab.MissionPage.CostFrame.Cost:SetPoint("RIGHT", self.MissionTab.MissionPage.CostFrame.CostIcon, "LEFT", -8, -1);

	self.MissionTab.ZoneSupportMissionPage.CostFrame.CostIcon:SetTexture(currencyTexture);
	self.MissionTab.ZoneSupportMissionPage.CostFrame.CostIcon:SetSize(18, 18);
	self.MissionTab.ZoneSupportMissionPage.CostFrame.Cost:SetPoint("RIGHT", self.MissionTab.ZoneSupportMissionPage.CostFrame.CostIcon, "LEFT", -8, -1);

	SetupMaterialFrame(self.FollowerList.MaterialFrame, primaryCurrency, currencyTexture);
	SetupMaterialFrame(self.MissionTab.MissionList.MaterialFrame, primaryCurrency, currencyTexture);

	-- All of the summary text in the Complete Dialog is anchored to the ViewButton, so we
	-- just need to center ViewButton to move all of the related UI.
	self:GetCompleteDialog().BorderFrame.ViewButton:SetPoint("BOTTOM", 0, 88);

	GarrisonFollowerMission.OnLoadMainFrame(self);
	
	self.MissionTab.MissionPage.RewardsFrame.Chest:SetAtlas("GarrMission-NeutralChest");

	PanelTemplates_SetNumTabs(self, 3);

	self:SelectTab(self:DefaultTab());
end

function OrderHallMission:OnEventMainFrame(event, ...)
	if (event == "ADVENTURE_MAP_CLOSE") then
		self.CloseButton:Click();
	else
		GarrisonFollowerMission.OnEventMainFrame(self, event, ...);
	end
end

function OrderHallMission:DefaultTab()
	return 1;	-- Missions
end

function OrderHallMission:SetupTabs()
	local tabList = { };
	local validTabs = { };
	local defaultTab;

	local lastShowMissionsAndFollowersTabs = self.lastShowMissionsAndFollowersTabs;

	-- If we don't have any followers, hide followers and missions tabs
	if (C_Garrison.GetNumFollowers(self.followerTypeID) > 0) then
		table.insert(tabList, 1);
		table.insert(tabList, 2);
		validTabs[1] = true;
		validTabs[2] = true;
		self.lastShowMissionsAndFollowersTabs = true;
		defaultTab = 1;
	else
		self.lastShowMissionsAndFollowersTabs = false;
	end

	-- If we have completed all sandbox choice quests, hide the adventure map
	if ((#tabList == 0) or C_Garrison.ShouldShowMapTab(GarrisonFollowerOptions[self.followerTypeID].garrisonType)) then
		table.insert(tabList, 3);
		validTabs[3] = true;
		if (not defaultTab) then
			defaultTab = 3;
		end
	end

	self.Tab1:Hide();
	self.Tab2:Hide();
	self.Tab3:Hide();

	-- don't show any tabs if there's only 1
	if (#tabList > 1) then
		local tab = self["Tab"..tabList[1]];
		local prevTab = tab;
		tab:ClearAllPoints();
		tab:SetPoint("BOTTOMLEFT", self, 11, -42);
		tab:Show();

		for i = 2, #tabList do
			tab = self["Tab"..tabList[i]];
			tab:ClearAllPoints();
			tab:SetPoint("LEFT", prevTab, "RIGHT", -5, 0);
			tab:Show();
			prevTab = tab;
		end
	end

	-- If the selected tab is not a valid one, switch to the default. Additionally, if the missions tab is newly available, then select it.
	local selectedTab = PanelTemplates_GetSelectedTab(self);
	if (not validTabs[selectedTab] or lastShowMissionsAndFollowersTabs ~= self.lastShowMissionsAndFollowersTabs) then
		self:SelectTab(defaultTab);
	end
end

function OrderHallMission:SetupMissionList()
	self.MissionTab.MissionList.listScroll.update = function() self.MissionTab.MissionList:Update(); end;
	HybridScrollFrame_CreateButtons(self.MissionTab.MissionList.listScroll, "OrderHallMissionListButtonTemplate", 13, -8, nil, nil, nil, -4);
	self.MissionTab.MissionList:Update();
	
	GarrisonMissionListTab_SetTab(self.MissionTab.MissionList.Tab1);
end

function OrderHallMission:OnShowMainFrame()
	GarrisonFollowerMission.OnShowMainFrame(self);
	AdventureMapMixin.OnShow(self.MapTab);

	self.abilityCountersForMechanicTypes = C_Garrison.GetFollowerAbilityCountersForMechanicTypes(self.followerTypeID);

	self:RegisterEvent("ADVENTURE_MAP_CLOSE");
	self:SetupTabs();
end

function OrderHallMission:OnHideMainFrame()
	GarrisonFollowerMission.OnHideMainFrame(self);
	AdventureMapMixin.OnHide(self.MapTab);

	self.abilityCountersForMechanicTypes = nil;

	self:UnregisterEvent("ADVENTURE_MAP_CLOSE");
end

function OrderHallMission:EscapePressed()
	if self:GetMissionPage() and self:GetMissionPage():IsVisible() then
		self:GetMissionPage().CloseButton:Click();
		return true;
	end

	return false;
end

function OrderHallMission:SelectTab(id)
	if (self:GetMissionPage():IsShown()) then
		self:GetMissionPage().CloseButton:Click();
	end
	GarrisonFollowerMission.SelectTab(self, id);
	if (id == 1) then
		self.TitleText:SetText(ORDER_HALL_MISSIONS);
		self.FollowerList:Hide();
		self.MapTab:Hide();
	elseif (id == 2) then
		self.TitleText:SetText(ORDER_HALL_FOLLOWERS);
		self.MapTab:Hide();
	else
		self.TitleText:SetText(ADVENTURE_MAP_TITLE);
		self.FollowerList:Hide();
		self.MapTab:Show();
	end
end


function OrderHallMission:GetMissionPage()
	if (self.MissionTab.isZoneSupport) then
		return self.MissionTab.ZoneSupportMissionPage;
	else
		return self.MissionTab.MissionPage;
	end
end


function OrderHallMission:OnClickMission(missionInfo)
	self.MissionTab.isZoneSupport = missionInfo.isZoneSupport;
	return GarrisonFollowerMission.OnClickMission(self, missionInfo);
end

function OrderHallMission:ShowMissionStage(missionInfo)
	if (not self.MissionTab.isZoneSupport) then
		GarrisonFollowerMission.ShowMissionStage(self, missionInfo);
	end
end

function OrderHallMission:ShowMission(missionInfo)
	if (missionInfo.isZoneSupport) then
		self:GetMissionPage().missionInfo = missionInfo;
		self:UpdateMissionData(self:GetMissionPage());
		self:GetFollowerBuffsForMission(self:GetMissionPage().missionInfo.missionID);
		self:GetMissionPage():SetCounters(self:GetMissionPage().Followers, self:GetMissionPage().Enemies, self:GetMissionPage().missionInfo.missionID);
	else
		GarrisonFollowerMission.ShowMission(self, missionInfo);
	end
end

function OrderHallMission:UpdateZoneSupportMissionData(missionPage)
	local texture;
	local spellID;
	local timeText
	if (missionPage.Followers[1] and missionPage.Followers[1].info) then
		spellID = missionPage.Followers[1].info.zoneSupportSpellID;
		local _, _, spellTexture = GetSpellInfo(spellID);
		texture = spellTexture;
	end

	missionPage.CombatAllySpell.iconTexture:SetTexture(texture);
	missionPage.CombatAllySpell:SetShown(texture ~= nil);
	missionPage.CombatAllySpell.spellID = spellID;

	missionPage:UpdatePortraitPulse();
	missionPage:UpdateEmptyString();

	self:UpdateStartButton(missionPage);
end

function OrderHallMission:UpdateMissionData(missionPage)
	if (missionPage.missionInfo.isZoneSupport) then
		self:UpdateZoneSupportMissionData(missionPage);
	else
		GarrisonFollowerMission.UpdateMissionData(self, missionPage);
	end
end

function OrderHallMission:OnSetEnemy(enemyFrame, enemyInfo)

	-- Display the enemy's mechanic ability icon

	local _, mechanic = next(enemyInfo.mechanics);


	if (mechanic and mechanic.ability and mechanic.ability.icon) then
		enemyFrame.mechanicEffectIcon = mechanic.ability.icon;
	else
		enemyFrame.mechanicEffectIcon = nil;
	end

	enemyFrame.MechanicEffect.Icon:SetTexture(enemyFrame.mechanicEffectIcon);
	enemyFrame.name = enemyInfo.name;
		
	
	if (mechanic and mechanic.ability) then
		enemyFrame.mechanicName = mechanic.name;
		enemyFrame.mechanicAbilityName = mechanic.ability.name;
		enemyFrame.mechanicEffectDescription = mechanic.ability.description;
	else
		enemyFrame.mechanicName = nil;
		enemyFrame.mechanicAbilityName = nil;
		enemyFrame.mechanicEffectDescription = nil;
	end
end

function OrderHallMission:OnSetEnemyMechanic(enemyFrame, mechanicFrame, mechanicID)
	local counterAbility = self.abilityCountersForMechanicTypes[mechanicID];
	mechanicFrame.counterAbility = counterAbility;
	enemyFrame.counterAbility = counterAbility;
	if (counterAbility and counterAbility.icon) then
		mechanicFrame.Icon:SetTexture(counterAbility.icon);
		mechanicFrame.Border:SetShown(ShouldShowFollowerAbilityBorder(self.followerTypeID, counterAbility));
	end
end



function OrderHallMission:SetEnemies(frame, enemies, numFollowers)
	local numVisibleEnemies = GarrisonFollowerMission.SetEnemies(self, frame, enemies, numFollowers);

	for i=1, numVisibleEnemies do
		local Frame = frame.Enemies[i];
		Frame.Mechanics[1]:SetScale(1.3);
	end

end


function OrderHallMission:SetupCompleteDialog()
	local completeDialog = self:GetCompleteDialog();
	if (completeDialog) then

		completeDialog.BorderFrame.Model.Title:SetText(ORDERHALL_MISSION_REPORT);

		local _, className = UnitClass("player");

		completeDialog.BorderFrame.Stage.LocBack:SetAtlas("legionmission-complete-background-"..className);
		completeDialog.BorderFrame.Stage.LocBack:SetTexCoord(0, 1, 0, 1);
		completeDialog.BorderFrame.Stage.LocMid:Hide();
		completeDialog.BorderFrame.Stage.LocFore:Hide();
	end
end


function OrderHallMission:MissionCompleteInitialize(missionList, index)
	if (not GarrisonFollowerMission.MissionCompleteInitialize(self, missionList, index)) then
		return false;
	end

	self.MissionComplete.BonusText.BonusTextGlowAnim:Stop();
	local mission = missionList[index];

	local bonusChance = Clamp(C_Garrison.GetMissionSuccessChance(mission.missionID) - 100, 0, 100);
	if (bonusChance > 0) then
		self.MissionComplete.BonusRewards.BonusChanceLabel:SetFormattedText(GARRISON_MISSION_COMPLETE_BONUS_CHANCE, bonusChance);
		self.MissionComplete.BonusRewards.BonusChanceLabel:Show();
	else
		self.MissionComplete.BonusRewards.BonusChanceLabel:Hide();
	end

	return true;
end

---------------------------------------------------------------------------------
-- Order Hall Mission Page
---------------------------------------------------------------------------------
OrderHallFollowerMissionPageMixin = { }

function OrderHallFollowerMissionPageMixin:SetCounters(followers, enemies, missionID)
	GarrisonFollowerMissionPageMixin.SetCounters(self, followers, enemies, missionID);

	-- Draw an X over mechanic effect, if the mechanic has been countered.
	for i = 1, #enemies do
		local enemyFrame = enemies[i];
		local mechanicFrame = enemyFrame.Mechanics[1];
		if ( mechanicFrame ) then
			if ( mechanicFrame.hasCounter ) then
				if ( not enemyFrame.MechanicEffect.CrossLeft:IsShown() ) then
					enemyFrame.MechanicEffect.CrossLeft:SetAlpha(1);
					enemyFrame.MechanicEffect.CrossRight:SetAlpha(1);
					enemyFrame.MechanicEffect.CrossLeft:Show();
					enemyFrame.MechanicEffect.CrossRight:Show();
					enemyFrame.MechanicEffect.Countered:Play();
				end
			else
				enemyFrame.MechanicEffect.CrossLeft:Hide();
				enemyFrame.MechanicEffect.CrossRight:Hide();
			end
		end
	end
end


---------------------------------------------------------------------------------
-- Order Hall Mission Page Enemy Frame
---------------------------------------------------------------------------------
OrderHallMissionPageEnemyMixin = { }

function OrderHallMissionPageEnemyMixin:OnEnter()
	if (self.mechanicName and self.mechanicAbilityName) then
		GameTooltip:SetOwner(self, "ANCHOR_NONE");
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0);
		GameTooltip:AddLine(self.name, 1, 1, 1);
		GameTooltip:AddLine(self.mechanicName, 0.698, 0.941, 1);
		GameTooltip:AddLine(" ");
		local str;
		if (self.mechanicEffectIcon) then
			str = "|T"..self.mechanicEffectIcon..":16:16:0:0|t "
		else
			str = "";
		end
		str = str..self.mechanicAbilityName;
		GameTooltip:AddLine(str, 1, 1, 1);
		GameTooltip:AddLine(self.mechanicEffectDescription, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function OrderHallMissionPageEnemyMixin:OnLeave()
	GameTooltip_Hide();
end

---------------------------------------------------------------------------------
-- Order Hall Mission Complete
---------------------------------------------------------------------------------
OrderHallMissionComplete = { }

function OrderHallMissionComplete:ShowRewards()
	local bonusRewards = self.BonusRewards;
	self.NextMissionButton:Enable();
	if ( not bonusRewards.success and not self.skipAnimations ) then
		return;
	end

	self.missionRewardEffectsPool:ReleaseAll();

	local currentMission = self.currentMission;
	local overmaxSucceeded = currentMission.overmaxSucceeded;

	if (overmaxSucceeded and not self.skipAnimations) then
		self.BonusText.BonusTextGlowAnim:Play();
	end

	-- The reward and overmax reward are staggered if there is an overmax reward. Otherwise,
	-- display the one item immediately as normal.
	local firstItemDelay = overmaxSucceeded and 0.75 or 0;
	local secondItemDelay = 1;

	-- There should be exactly 1 base reward, but display them all even if there is more.
	local hasOvermaxRewardItem = (overmaxSucceeded and currentMission.overmaxRewardItem ~= 0);
	local numRewards = currentMission.numRewards + (hasOvermaxRewardItem and 1 or 0);
	local prevRewardFrame;
	for id, reward in pairs(currentMission.rewards) do
		local rewardFrame = self.missionRewardEffectsPool:Acquire();
		if (prevRewardFrame) then
			rewardFrame:SetPoint("LEFT", prevRewardFrame, "RIGHT", 9, 0);
		else
			if (numRewards == 1) then
				rewardFrame:SetPoint("CENTER", bonusRewards, "CENTER", 0, 0);
			elseif (numRewards == 2) then
				rewardFrame:SetPoint("RIGHT", bonusRewards, "CENTER", -5, 0);
			else
				rewardFrame:SetPoint("LEFT", bonusRewards, "LEFT", 18, 0);
			end
		end

		rewardFrame.id = id;
		if ( not self.skipAnimations ) then
			rewardFrame:Hide();
			C_Timer.After(firstItemDelay,
				function()
					GarrisonMissionPage_SetReward(rewardFrame, reward);
					rewardFrame.Anim:Play();
				end
			);
		else
			GarrisonMissionPage_SetReward(rewardFrame, reward);
			if (not self.skipAnimations) then
				rewardFrame.Anim:Play();
			end
		end
		prevRewardFrame = rewardFrame;
	end

	if (overmaxSucceeded and currentMission.overmaxRewardItem ~= 0) then
		local rewardFrame = self.missionRewardEffectsPool:Acquire();
		if (prevRewardFrame) then
			rewardFrame:SetPoint("LEFT", prevRewardFrame, "RIGHT", 9, 0);
		else
			if (numRewards == 1) then
				rewardFrame:SetPoint("CENTER", bonusRewards, "CENTER", 0, 0);
			elseif (numRewards == 2) then
				rewardFrame:SetPoint("RIGHT", bonusRewards, "CENTER", -5, 0);
			else
				rewardFrame:SetPoint("LEFT", bonusRewards, "LEFT", 18, 0);
			end
		end
		self.BonusRewards.BonusChanceLabel:Hide();
		if ( not self.skipAnimations ) then
			rewardFrame:Hide();
			C_Timer.After(secondItemDelay,
				function()
					GarrisonMissionPage_SetOvermaxReward(rewardFrame, currentMission.overmaxRewardItem, currentMission.overmaxRewardMoney)
					rewardFrame.Anim:Play();
				end
			);
		else
			GarrisonMissionPage_SetOvermaxReward(rewardFrame, currentMission.overmaxRewardItem, currentMission.overmaxRewardMoney)
			if (not self.skipAnimations) then
				Reward.Anim:Play();
			end
		end
		prevRewardFrame = rewardFrame;
	end
	GarrisonMissionPage_UpdateRewardQuantities(bonusRewards, currentMission.currencyMultipliers, currentMission.goldMultiplier);
end

---------------------------------------------------------------------------------
-- Order Hall Adventure Map
---------------------------------------------------------------------------------
OrderHallMissionAdventureMapMixin = { }

function AdventureMapMixin:SetupTitle()
end

function OrderHallMissionAdventureMapMixin:EvaluateLockReasons()
	if next(self.lockReasons) then
		self:GetParent().GarrCorners:EnableMouse(true);
	else
		self:GetParent().GarrCorners:EnableMouse(false);
	end
end

-- Don't call C_AdventureMap.Close here because we may be simply switching tabs. We call that method in OrderHallMission:OnHide() instead.
function OrderHallMissionAdventureMapMixin:OnShow()
end

function OrderHallMissionAdventureMapMixin:OnHide()
end

function OrderHallMissionAdventureMapMixin:OnLoad()
	AdventureMapMixin.OnLoad(self);
	self.ScrollContainer:SetScalingMode("SCALING_MODE_LINEAR");
end

function OrderHallMissionAdventureMapMixin:UpdateMissions()

end

function OrderHallMissionAdventureMapMixin:Update()

end

---------------------------------------------------------------------------------
-- Zone Support Page
---------------------------------------------------------------------------------

ZoneSupportMissionPageMixin = { }
function ZoneSupportMissionPageMixin:UpdateEmptyString()
	if ( C_Garrison.GetNumFollowersOnMission(self.missionInfo.missionID) == 0 ) then
		self.CombatAllyDescriptionLabel:SetText(self.missionInfo.description);
	else
		self.CombatAllyDescriptionLabel:SetText(ORDER_HALL_ZONE_SUPPORT_DESCRIPTION_IN_ZONE);
	end
end

function ZoneSupportMissionPageMixin:UpdateFollowerModel(info)
end

function ZoneSupportMissionPageMixin:SetFollowerListSortFuncsForMission()
	local mainFrame = self:GetParent():GetParent();
	mainFrame.FollowerList:SetSortFuncs(GarrisonFollowerList_DefaultSort, GarrisonFollowerList_InitializeDefaultSort);
end

---------------------------------------------------------------------------------
-- Order Hall Mission list
---------------------------------------------------------------------------------

OrderHallMissionListMixin = { }

function OrderHallMissionListMixin:UpdateCombatAllyMission()
	GarrisonMissionListMixin.UpdateCombatAllyMission(self);

	if (self.combatAllyMission) then
		self:SetHeight(440);
	else
		self:SetHeight(565);
	end
	self.CombatAllyUI:SetMission(self.combatAllyMission);
end

OrderHallCombatAllyMixin = { }

function OrderHallCombatAllyMixin:SetMission(missionInfo)
	self.missionInfo = missionInfo;
	if (missionInfo) then
		local followerIsAssigned = missionInfo.inProgress or missionInfo.completed;
		local completed = (missionInfo.inProgress and missionInfo.timeLeftSeconds == 0) or missionInfo.completed;
		self.Available:SetShown(not followerIsAssigned);
		self.InProgress:SetShown(followerIsAssigned);
		if (followerIsAssigned) then
			local followerInfo = C_Garrison.GetFollowerInfo(missionInfo.followers[1]);
			self.InProgress.PortraitFrame:SetupPortrait(followerInfo);
			self.InProgress.Name:SetText(followerInfo.name);

			local name, _, texture = GetSpellInfo(followerInfo.zoneSupportSpellID);

			self.InProgress.CombatAllySpell.iconTexture:SetTexture(texture);
			self.InProgress.CombatAllySpell.spellID = followerInfo.zoneSupportSpellID;
			self.InProgress.ZoneSupportName:SetText(name or "");

			self.InProgress.Unassign:SetEnabled(completed);
		end
		self:Show();
	else
		self:Hide();
	end
end

function OrderHallCombatAllyMixin:UnassignAlly()
	C_Garrison.MarkMissionComplete(self.missionInfo.missionID);
end

function OrderHallCombatAllyMixin:GetMissionFrame()
	return self:GetParent():GetParent():GetParent();
end

function OrderHallCombatAllyMixin:GetMissionList()
	return self:GetParent();
end

--- Utility functions

function GarrisonFollowerFilter_MustHaveZoneSupport(followerInfo) 
	return followerInfo.isCollected and followerInfo.zoneSupportSpellID ~= nil; 
end
