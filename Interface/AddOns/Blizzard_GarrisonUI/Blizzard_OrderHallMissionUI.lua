---------------------------------------------------------------------------------
--- Garrison Follower Options				                                  ---
---------------------------------------------------------------------------------

-- These are follower options that depend on this AddOn being loaded, and so they can't be set in GarrisonBaseUtils.
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower].missionFollowerSortFunc =  GarrisonFollowerList_PrioritizeSpecializationAbilityMissionSort;
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower].missionFollowerInitSortFunc = GarrisonFollowerList_InitializePrioritizeSpecializationAbilityMissionSort;

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
	self:UpdateTextures();

	PanelTemplates_SetNumTabs(self, 3);
	self:SelectTab(self:DefaultTab());
end

function OrderHallMission:UpdateTextures()
	local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(GarrisonFollowerOptions[self.followerTypeID].garrisonType);
	local currencyTexture = C_CurrencyInfo.GetCurrencyInfo(primaryCurrency).iconFileID;

	self.MissionTab.MissionPage.CostFrame:SetCurrency(primaryCurrency);
	self.MissionTab.MissionPage.CostFrame.CostIcon:SetTexture(currencyTexture);
	self.MissionTab.MissionPage.CostFrame.CostIcon:SetSize(18, 18);
	self.MissionTab.MissionPage.CostFrame.Cost:SetPoint("RIGHT", self.MissionTab.MissionPage.CostFrame.CostIcon, "LEFT", -8, -1);

	if (self.MissionTab.ZoneSupportMissionPage) then
		self.MissionTab.ZoneSupportMissionPage.CostFrame.CostIcon:SetTexture(currencyTexture);
		self.MissionTab.ZoneSupportMissionPage.CostFrame.CostIcon:SetSize(18, 18);
		self.MissionTab.ZoneSupportMissionPage.CostFrame.Cost:SetPoint("RIGHT", self.MissionTab.ZoneSupportMissionPage.CostFrame.CostIcon, "LEFT", -8, -1);
	end

	SetupMaterialFrame(self.FollowerList.MaterialFrame, primaryCurrency, currencyTexture);
	SetupMaterialFrame(self.MissionTab.MissionList.MaterialFrame, primaryCurrency, currencyTexture);

	-- All of the summary text in the Complete Dialog is anchored to the ViewButton, so we
	-- just need to center ViewButton to move all of the related UI.
	self:GetCompleteDialog().BorderFrame.ViewButton:SetPoint("BOTTOM", 0, 88);

	GarrisonFollowerMission.OnLoadMainFrame(self);

	self.MissionTab.MissionPage.RewardsFrame.Chest:SetAtlas("GarrMission-NeutralChest");
	self.MissionTab.MissionPage.RewardsFrame.Chance:SetPoint("CENTER", self.MissionTab.MissionPage.RewardsFrame.Chest, -9, 6);

	self.MissionTab.MissionPage.Stage.MissionEnvIcon:SetSize(48,48);
	self.MissionTab.MissionPage.Stage.MissionEnvIcon:SetPoint("LEFT", self.MissionTab.MissionPage.Stage.MissionInfo.MissionEnv, "RIGHT", -11, 0);

	self.Top:SetAtlas("_StoneFrameTile-Top", true);
	self.Bottom:SetAtlas("_StoneFrameTile-Bottom", true);
	self.Left:SetAtlas("!StoneFrameTile-Left", true);
	self.Right:SetAtlas("!StoneFrameTile-Left", true);
	self.GarrCorners.TopLeftGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);
	self.GarrCorners.TopRightGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);
	self.GarrCorners.BottomLeftGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);
	self.GarrCorners.BottomRightGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);

	local tabs = { self.MissionTab.MissionList.Tab1, self.MissionTab.MissionList.Tab2 };
	for _, tab in ipairs(tabs) do
		tab.Left:SetAtlas("ClassHall_ParchmentHeader-End-2", true);
		tab.Right:SetAtlas("ClassHall_ParchmentHeader-End-2", true);
		tab.Middle:SetAtlas("_ClassHall_ParchmentHeader-Mid", true);
		tab.Middle:SetPoint("LEFT", tab.Left, "RIGHT");
		tab.Middle:SetPoint("RIGHT", tab.Right, "LEFT");
		tab.Middle:SetHorizTile(false);
		tab.SelectedLeft:SetAtlas("ClassHall_ParchmentHeaderSelect-End-2", true);
		tab.SelectedRight:SetAtlas("ClassHall_ParchmentHeaderSelect-End-2", true);
		tab.SelectedMid:SetAtlas("_ClassHall_ParchmentHeaderSelect-Mid", true);
		tab.SelectedMid:SetPoint("LEFT", tab.SelectedLeft, "RIGHT");
		tab.SelectedMid:SetPoint("RIGHT", tab.SelectedRight, "LEFT");
		tab.SelectedMid:SetHorizTile(false);
	end

	local frames = { self.FollowerTab, self.MissionTab.MissionList };
	for _, frame in ipairs(frames) do
		frame.BaseFrameBackground:SetAtlas("ClassHall_StoneFrame-BackgroundTile");
		frame.BaseFrameLeft:SetAtlas("!ClassHall_InfoBoxMission-Left");
		frame.BaseFrameRight:SetAtlas("!ClassHall_InfoBoxMission-Left");
		frame.BaseFrameTop:SetAtlas("_ClassHall_InfoBoxMission-Top");
		frame.BaseFrameBottom:SetAtlas("_ClassHall_InfoBoxMission-Top");
		frame.BaseFrameTopLeft:SetAtlas("ClassHall_InfoBoxMission-Corner");
		frame.BaseFrameTopRight:SetAtlas("ClassHall_InfoBoxMission-Corner");
		frame.BaseFrameBottomLeft:SetAtlas("ClassHall_InfoBoxMission-Corner");
		frame.BaseFrameBottomRight:SetAtlas("ClassHall_InfoBoxMission-Corner");
	end

	self.FollowerList.HeaderLeft:SetAtlas("ClassHall_ParchmentHeaderSelect-End-2", true);
	self.FollowerList.HeaderLeft:SetPoint("BOTTOMLEFT", self.FollowerList, "TOPLEFT", 30, -8);

	self.FollowerList.HeaderRight:SetAtlas("ClassHall_ParchmentHeaderSelect-End-2", true);
	self.FollowerList.HeaderMid:SetAtlas("_ClassHall_ParchmentHeaderSelect-Mid", true);
	self.FollowerList.HeaderMid:SetPoint("LEFT", self.FollowerList.HeaderLeft, "RIGHT");
	self.FollowerList.HeaderMid:SetPoint("RIGHT", self.FollowerList.HeaderRight, "LEFT");
	self.FollowerList.HeaderMid:SetHorizTile(false);
	self.FollowerList.HeaderMid:SetWidth(110);

	self.BackgroundTile:SetAtlas("ClassHall_InfoBoxMission-BackgroundTile");

	if (self.ClassHallIcon) then
		local _, className = UnitClass("player");
		self.ClassHallIcon.Icon:SetAtlas("classhall-circle-"..className);
	end
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

function OrderHallMission:ShouldShowMissionsAndFollowersTabs()
	-- If we don't have any followers, hide followers and missions tabs
	return C_Garrison.GetNumFollowers(self.followerTypeID) > 0;
end

function OrderHallMission:SetupTabs()
	local tabList = { };
	local validTabs = { };
	local defaultTab;

	local lastShowMissionsAndFollowersTabs = self.lastShowMissionsAndFollowersTabs;

	if self:ShouldShowMissionsAndFollowersTabs() then
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
		tab:ClearAllPoints();
		tab:SetPoint("BOTTOMLEFT", self, tab.xOffset or 7, tab.yOffset or -31);
		tab:Show();

		for i = 2, #tabList do
			tab = self["Tab"..tabList[i]];
			tab:Show();
		end
	end

	 PanelTemplates_SetNumTabs(self, #tabList);

	-- If the selected tab is not a valid one, switch to the default. Additionally, if the missions tab is newly available, then select it.
	local selectedTab = PanelTemplates_GetSelectedTab(self);
	if (not validTabs[selectedTab] or lastShowMissionsAndFollowersTabs ~= self.lastShowMissionsAndFollowersTabs) then
		self:SelectTab(defaultTab);
	end
end

function OrderHallMission:SetupMissionList()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("GarrisonMissionListButtonTemplate", function(button, elementData)
		GarrisonMissionList_InitButton(button, elementData, self);
	end);
	view:SetPadding(8,0,13,13,4);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.MissionTab.MissionList.ScrollBox, self.MissionTab.MissionList.ScrollBar, view);

	GarrisonMissionListTab_SetTab(self.MissionTab.MissionList.Tab1);
end

function OrderHallMission:OnShowMainFrame()
	GarrisonFollowerMission.OnShowMainFrame(self);
	AdventureMapMixin.OnShow(self.MapTab);

	self:RegisterEvent("ADVENTURE_MAP_CLOSE");
	self:SetupTabs();
end

function OrderHallMission:OnHideMainFrame()
	GarrisonFollowerMission.OnHideMainFrame(self);
	AdventureMapMixin.OnHide(self.MapTab);

	OrderHallMissionTutorialFrame:Hide();
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
		self.BackgroundTile:Show()
	elseif (id == 2) then
		self.TitleText:SetText(ORDER_HALL_FOLLOWERS);
		self.MapTab:Hide();
		self.BackgroundTile:Show()
	else
		self.TitleText:SetText(ADVENTURE_MAP_TITLE);
		self.FollowerList:Hide();
		self.MapTab:Show();
		self.BackgroundTile:Hide()
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
		self:CheckTutorials();
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
		enemyFrame.mechanicEffectID = mechanic.ability.id;
		enemyFrame.mechanicName = mechanic.name;
		enemyFrame.mechanicAbilityName = mechanic.ability.name;
		enemyFrame.mechanicEffectDescription = mechanic.ability.description;
	else
		enemyFrame.mechanicEffectID = nil;
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

		GarrisonMissionStage_SetBack(completeDialog.BorderFrame.Stage, "legionmission-complete-background-"..className);
		GarrisonMissionStage_SetMid(completeDialog.BorderFrame.Stage, nil);
		GarrisonMissionStage_SetFore(completeDialog.BorderFrame.Stage, nil);

		local neutralChestDisplayID = 71671;
		self.MissionComplete.BonusRewards.ChestModel:SetDisplayInfo(neutralChestDisplayID);
	end
end


function OrderHallMission:MissionCompleteInitialize(missionList, index)
	if (not GarrisonFollowerMission.MissionCompleteInitialize(self, missionList, index)) then
		return false;
	end

	self.MissionComplete.Stage.MissionInfo.MissionType:SetSize(50, 50);
	self.MissionComplete.Stage.MissionInfo.MissionType:SetPoint("TOPLEFT", 58, -10);

	self.MissionComplete.BonusText.BonusTextGlowAnim:Stop();
	local mission = missionList[index];

	local bonusChance = Clamp(C_Garrison.GetMissionSuccessChance(mission.missionID) - 100, 0, 100);
	if (bonusChance > 0 and #self.MissionComplete.currentMission.overmaxRewards ~= 0) then
		self.MissionComplete.BonusRewards.BonusChanceLabel:SetFormattedText(GARRISON_MISSION_COMPLETE_BONUS_CHANCE, bonusChance);
		self.MissionComplete.BonusRewards.BonusChanceLabel:Show();
	else
		self.MissionComplete.BonusRewards.BonusChanceLabel:Hide();
	end

	self.MissionComplete.BonusChanceFail.CrossLeft:Hide();
	self.MissionComplete.BonusChanceFail.CrossRight:Hide();

	self.MissionComplete.BonusText.BonusText:SetAlpha(0);
	self.MissionComplete.BonusText.BonusGlow:SetAlpha(0);
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
	local missionComplete = true;
	local bonusRewards = self.BonusRewards;
	self.NextMissionButton:Enable();
	if ( not bonusRewards.success and not self.skipAnimations ) then
		return;
	end

	self.missionRewardEffectsPool:ReleaseAll();

	local currentMission = self.currentMission;
	local overmaxSucceeded = currentMission.overmaxSucceeded and #currentMission.overmaxRewards ~= 0;

	if (overmaxSucceeded and not self.skipAnimations) then
		self.BonusText.BonusTextGlowAnim:Play();
	end

	-- The reward and overmax reward are staggered if there is an overmax reward. Otherwise,
	-- display the one item immediately as normal.
	local firstItemDelay = overmaxSucceeded and 0.75 or 0;
	local secondItemDelay = 1;

	-- There should be exactly 1 base reward, but display them all even if there is more.
	local numRewards = #currentMission.rewards + (overmaxSucceeded and 1 or 0);
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
					GarrisonMissionPage_SetReward(rewardFrame, reward, missionComplete);
					rewardFrame.Anim:Play();
				end
			);
		else
			GarrisonMissionPage_SetReward(rewardFrame, reward, missionComplete);
			if (not self.skipAnimations) then
				rewardFrame.Anim:Play();
			end
		end
		prevRewardFrame = rewardFrame;
	end

	if (overmaxSucceeded and #currentMission.overmaxRewards ~= 0) then
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
			local rewardMissionID = self.currentMission.missionID;
			C_Timer.After(secondItemDelay,
				function()
					if ( rewardMissionID == self.currentMission.missionID ) then
						GarrisonMissionPage_SetReward(rewardFrame, currentMission.overmaxRewards[1], missionComplete);
						rewardFrame.Anim:Play();
					end
				end
			);
		else
			GarrisonMissionPage_SetReward(rewardFrame, currentMission.overmaxRewards[1], missionComplete);
		end
		prevRewardFrame = rewardFrame;
	end
	if (self.BonusRewards.BonusChanceLabel:IsShown() and not overmaxSucceeded) then
		self.BonusChanceFail.CrossLeft:SetAlpha(1);
		self.BonusChanceFail.CrossRight:SetAlpha(1);
		self.BonusChanceFail.CrossLeft:Show();
		self.BonusChanceFail.CrossRight:Show();
		self.BonusChanceFail.BonusFailed:Play();
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

	if (self.CombatAllyUI) then
		if (self.combatAllyMission) then
			self:SetHeight(440);
		else
			self:SetHeight(565);
		end
		self.CombatAllyUI:SetMission(self.combatAllyMission);
	end
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

---------------------------------------------------------------------------------
-- Utility functions
---------------------------------------------------------------------------------

function GarrisonFollowerFilter_MustHaveZoneSupport(followerInfo)
	return followerInfo.isCollected and followerInfo.zoneSupportSpellID ~= nil;
end

---------------------------------------------------------------------------------
-- Tutorials
---------------------------------------------------------------------------------


local function CheckHasMissions(missionFrame)
	if (not missionFrame.MissionTab.MissionList:IsShown()) then
		return false;
	end

	if (missionFrame.MissionTab.MissionList.CompleteDialog:IsShown()) then
		return false;
	end

	return missionFrame.MissionTab.MissionList.availableMissions and #missionFrame.MissionTab.MissionList.availableMissions > 0;
end

local function CheckHasNoMissions(missionFrame)
	if (not missionFrame.MissionTab.MissionList:IsShown()) then
		return false;
	end

	return missionFrame.MissionTab.MissionList.availableMissions and #missionFrame.MissionTab.MissionList.availableMissions == 0;
end

local function CheckOpenMissionPage(missionFrame)
	return missionFrame.MissionTab.MissionPage:IsShown();
end

local function CheckNotOpenMissionPage(missionFrame)
	return not CheckOpenMissionPage(missionFrame);
end

local function CheckOpenMissionPageAndHasBossMechanic(missionFrame)
	if (CheckNotOpenMissionPage(missionFrame)) then
		return false;
	end

	if (not missionFrame.MissionTab.MissionPage.Enemy1.counterAbility.isSpecialization) then
		return false;
	end

	-- see if you have a follower that has that spec
	for _, follower in ipairs(missionFrame.FollowerList.followers) do
		if not follower.status then
			local abilities = C_Garrison.GetFollowerAbilities(follower.followerID);
			for _, ability in ipairs(abilities) do
				if (ability.id == missionFrame.MissionTab.MissionPage.Enemy1.counterAbility.id) then
					return true;
				end
			end
		end
	end

	return false;
end

local function CheckOpenMissionPageAndBossCountered(missionFrame)
	if (CheckNotOpenMissionPage(missionFrame)) then
		return false;
	end

	return missionFrame.MissionTab.MissionPage.Enemy1.MechanicEffect.CrossLeft:IsShown();
end

local function CheckOpenMissionComplete(missionFrame)
	return missionFrame.MissionComplete:IsShown() or missionFrame:GetCompleteDialog():IsShown();
end

local function CheckHasCombatAllyMission(missionFrame)
	if (not missionFrame.MissionTab.MissionList.CombatAllyUI:IsShown()) then
		return false;
	end

	if (not missionFrame.MissionTab.MissionList.CombatAllyUI.Available:IsShown()) then
		return false;
	end

	return not CheckOpenMissionComplete(missionFrame);
end

local function CheckNotHasCombatAllyMission(missionFrame)
	return not CheckHasCombatAllyMission(missionFrame);
end

local function CheckOpenZoneSupportMissionPage(missionFrame)
	return missionFrame.MissionTab.ZoneSupportMissionPage:IsShown();
end

local function CheckOpenMissionCompleteOrHasNoMissions(missionFrame)
	return CheckOpenMissionComplete(missionFrame) or CheckHasNoMissions(missionFrame);
end

local function CheckOpenMissionPageAndHasTroopInList(missionFrame)
	if (CheckNotOpenMissionPage(missionFrame)) then
		return false;
	end

	-- find a follower that is a troop
	for _, follower in ipairs(missionFrame.FollowerList.followers) do
		if (not follower.status) then
			if (follower.isTroop) then
				return true;
			end
		end
	end
	
	return false;
end

local function CheckOpenMissionPageAndTroopInMission(missionFrame)
	if (CheckNotOpenMissionPage(missionFrame)) then
		return false;
	end

	for _, followerFrame in ipairs(missionFrame.MissionTab.MissionPage.Followers) do
		if (followerFrame.info and followerFrame.info.isTroop) then
			return true;
		end
	end
	return false;
end


local function CheckOpenMissionPageAndHasUncounteredMechanicEffect(missionFrame, mechanicEffectID)
	if (CheckNotOpenMissionPage(missionFrame)) then
		return false;
	end

	for _, enemy in ipairs(missionFrame.MissionTab.MissionPage.Enemies) do
		if (enemy.mechanicEffectID == mechanicEffectID and not enemy.MechanicEffect.CrossLeft:IsShown()) then
			return true;
		end
	end

	return false;
end

local function CheckClosedMissionPageOrMechanicEffectCountered(missionFrame, mechanicEffectID)
	if (CheckNotOpenMissionPage(missionFrame)) then
		return true;
	end

	local foundMechanic;
	local foundIndex;
	for index, enemy in ipairs(missionFrame.MissionTab.MissionPage.Enemies) do
		if (enemy.mechanicEffectID == mechanicEffectID) then
			foundMechanic = enemy.mechanic;
			foundIndex = index;
			break;
		end
	end

	return foundIndex and missionFrame.MissionTab.MissionPage.Enemies[foundIndex].MechanicEffect.CrossLeft:IsShown();
end

local function PositionAtMechanicEffect(missionFrame, mechanicEffectID)
	local foundMechanic;
	local foundIndex;
	for index, enemy in ipairs(missionFrame.MissionTab.MissionPage.Enemies) do
		if (enemy.mechanicEffectID == mechanicEffectID) then
			foundMechanic = enemy.mechanic;
			foundIndex = index;
			break;
		end
	end

	if (foundIndex) then
		if (foundIndex < 3) then
			return HelpTip.Point.RightEdgeCenter, 6, -20, missionFrame.MissionTab.MissionPage.Enemies[foundIndex];
		else
			return HelpTip.Point.LeftEdgeCenter, -6, -20, missionFrame.MissionTab.MissionPage.Enemies[foundIndex];
		end
	end
end

local function PositionAtFirstEnemy(missionFrame)
	return HelpTip.Point.RightEdgeCenter, 6, 0, missionFrame.MissionTab.MissionPage.Enemy1;
end

local function PositionAtFirstTroop(missionFrame)
	-- find a follower that is a troop
	local firstTroopFrame = missionFrame.FollowerList.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		local follower = elementData.follower or nil;
		return follower and not follower.status and follower.isTroop;
	end);

	if (firstTroopFrame and firstTroopFrame.Follower and firstTroopFrame.Follower.DurabilityFrame) then
		return HelpTip.Point.TopEdgeCenter, 8, 25, firstTroopFrame.Follower.DurabilityFrame;
	else
		return HelpTip.Point.TopEdgeCenter, -10, -520, OrderHallMissionFrame.FollowerList.ScrollBox;
	end
end

local function PositionAtFirstMission(missionFrame)
	local frame = missionFrame.MissionTab.MissionList.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return frame.id == 1;
	end);

	return HelpTip.Point.BottomEdgeCenter, -120, 6, frame;
end

local function PositionAtCombatAlly(missionFrame)
	return HelpTip.Point.RightEdgeCenter, -1, 4, missionFrame.MissionTab.MissionList.CombatAllyUI.Available.AddFollowerButton;
end

local function TextBossSpec(missionFrame, tutorial)
	local className = UnitClass("player");

	local followerName = "";

	-- find a follower that has the correct spec
	for _, follower in ipairs(missionFrame.FollowerList.followers) do
		local abilities = C_Garrison.GetFollowerAbilities(follower.followerID);
		for _, ability in ipairs(abilities) do
			if (ability.id == missionFrame.MissionTab.MissionPage.Enemy1.counterAbility.id) then
				followerName = follower.name;
				break;
			end
		end
	end

	return string.format(ORDER_HALL_MISSION_TUTORIAL_BOSS_COUNTER,
		missionFrame.MissionTab.MissionPage.Enemy1.counterAbility.name,
		className,
		followerName);
end

local lethalMechanicEffectID = 437;
local cursedMechanicEffectID = 471;
local slowingMechanicEffectID = 428;
local disorientingMechanicEffectID = 472;

local seenAllTutorials = 0x000F0004;

-- tutorial numbers from 1-0xFFFF are sequential, those from 0x10000-0xFFFF0000 are bit flags and can happen in any order.
local tutorials = {
	-- Click to view mission details
	[1] = {
		id = 1,
		text = ORDER_HALL_MISSION_TUTORIAL_VIEW_DETAILS,
		parent = "MissionList",
		openConditionFunc = CheckHasMissions,
		closeConditionFunc = CheckOpenMissionPage,
		cancelConditionFunc = CheckOpenMissionCompleteOrHasNoMissions,
		positionFunc = PositionAtFirstMission,
		advanceOnClick = true,
	},
	-- This boss can be countered by specialization
	[2] = {
		id = 2,
		parent = "MissionPage",
		openConditionFunc = CheckOpenMissionPageAndHasBossMechanic,
		closeConditionFunc = CheckOpenMissionPageAndBossCountered,
		cancelConditionFunc = CheckNotOpenMissionPage,
		positionFunc = PositionAtFirstEnemy,
		textFunc = TextBossSpec,
		advanceOnClick = true,
	},
	-- Lethal will always kill a troop if not countered.
	[0x10000] = {
		id = 0x10000,
		text = ORDER_HALL_MISSION_TUTORIAL_LETHAL,
		parent = "MissionPage",
		openConditionFunc = function(missionFrame) return CheckOpenMissionPageAndHasUncounteredMechanicEffect(missionFrame, lethalMechanicEffectID); end,
		closeConditionFunc = function(missionFrame) return CheckClosedMissionPageOrMechanicEffectCountered(missionFrame, lethalMechanicEffectID); end,
		positionFunc = function(missionFrame) return PositionAtMechanicEffect(missionFrame, lethalMechanicEffectID); end,
	},
	-- Cursed will not provide a bonus loot if not countered.
	[0x20000] = {
		id = 0x20000,
		text = ORDER_HALL_MISSION_TUTORIAL_CURSED,
		parent = "MissionPage",
		openConditionFunc = function(missionFrame) return CheckOpenMissionPageAndHasUncounteredMechanicEffect(missionFrame, cursedMechanicEffectID); end,
		closeConditionFunc = function(missionFrame) return CheckClosedMissionPageOrMechanicEffectCountered(missionFrame, cursedMechanicEffectID); end,
		positionFunc = function(missionFrame) return PositionAtMechanicEffect(missionFrame, cursedMechanicEffectID); end,
	},
	-- Slowing increases the mission duration if not countered.
	[0x40000] = {
		id = 0x40000,
		text = ORDER_HALL_MISSION_TUTORIAL_SLOWING,
		parent = "MissionPage",
		openConditionFunc = function(missionFrame) return CheckOpenMissionPageAndHasUncounteredMechanicEffect(missionFrame, slowingMechanicEffectID); end,
		closeConditionFunc = function(missionFrame) return CheckClosedMissionPageOrMechanicEffectCountered(missionFrame, slowingMechanicEffectID); end,
		positionFunc = function(missionFrame) return PositionAtMechanicEffect(missionFrame, slowingMechanicEffectID); end,
	},
	-- Disorienting increases the mission cost if not countered.
	[0x80000] = {
		id = 0x80000,
		text = ORDER_HALL_MISSION_TUTORIAL_DISORIENTING,
		parent = "MissionPage",
		openConditionFunc = function(missionFrame) return CheckOpenMissionPageAndHasUncounteredMechanicEffect(missionFrame, disorientingMechanicEffectID); end,
		closeConditionFunc = function(missionFrame) return CheckClosedMissionPageOrMechanicEffectCountered(missionFrame, disorientingMechanicEffectID); end,
		positionFunc = function(missionFrame) return PositionAtMechanicEffect(missionFrame, disorientingMechanicEffectID); end,
	},
	-- Click on Combat Ally
	[0x100000] = {
		id = 0x100000,
		text = ORDER_HALL_MISSION_TUTORIAL_COMBAT_ALLY,
		parent = "MissionList",
		openConditionFunc = CheckHasCombatAllyMission,
		closeConditionFunc = CheckOpenZoneSupportMissionPage,
		cancelConditionFunc = CheckNotHasCombatAllyMission,
		positionFunc = PositionAtCombatAlly,
	 },
	-- Troops have abilities that can increase your success chance
	[0x200000] = {
		id = 0x200000,
		text = ORDER_HALL_MISSION_TUTORIAL_TROOPS,
		parent = "MissionPage",
		openConditionFunc = CheckOpenMissionPageAndHasTroopInList,
		closeConditionFunc = CheckOpenMissionPageAndTroopInMission,
		positionFunc = PositionAtFirstTroop,
	},
};

local function ReadTutorialCVAR()
	local cvarVal = tonumber(GetCVar("orderHallMissionTutorial")) or 0;

	local lastTutorial = bit.band(cvarVal, 0xFFFF);
	local tutorialFlags = bit.band(cvarVal, 0xFFFF0000);

	return lastTutorial, tutorialFlags, cvarVal;
end

local function WriteTutorialCVAR(lastTutorial, tutorialFlags)
	lastTutorial = bit.band(lastTutorial, 0xFFFF);
	tutorialFlags = bit.band(tutorialFlags, 0xFFFF0000);

	local cvarVal = bit.bor(tutorialFlags, lastTutorial);
	SetCVar("orderHallMissionTutorial", cvarVal);
end

function OrderHallMission:TryShowTutorial(tutorial)
	if tutorial and tutorial.openConditionFunc and tutorial.openConditionFunc(self) then
		local targetPoint, offsetX, offsetY, relativeFrame = tutorial.positionFunc(self);
		if targetPoint then
			local helpTipInfo = {
				text = tutorial.textFunc and tutorial.textFunc(self, tutorial) or tutorial.text,
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = targetPoint,
				offsetX = offsetX,
				offsetY = offsetY,
				onHideCallback = GenerateClosure(self.CheckTutorials, self),
			};
			HelpTip:Show(OrderHallMissionTutorialFrame, helpTipInfo, relativeFrame);

			-- parent frame
			OrderHallMissionTutorialFrame:SetParent(self.MissionTab[tutorial.parent]);
			OrderHallMissionTutorialFrame:SetFrameStrata("DIALOG");
			OrderHallMissionTutorialFrame:SetPoint("TOPLEFT", self, 0, -21);
			OrderHallMissionTutorialFrame:SetPoint("BOTTOMRIGHT", self);
			OrderHallMissionTutorialFrame.id = tutorial.id;
			OrderHallMissionTutorialFrame:Show();

			return true;
		end
	end

	return false;
end

function OrderHallMission:CheckTutorials(advance)
	if (not OrderHallMissionTutorialFrame) then
		return;
	end
	local lastTutorial, tutorialFlags, cvarVal = ReadTutorialCVAR();
	if (cvarVal == seenAllTutorials) then
		return;
	end

	local nextTutorial = lastTutorial + 1;
	local tutorial = tutorials[nextTutorial] or {};

	if (OrderHallMissionTutorialFrame.id) then
		if (not advance) then
			if (tutorial.closeConditionFunc and tutorial.closeConditionFunc(self)) then
				advance = true;
			end
		end
		if ( advance ) then
			if (tutorial.advanceOnClick) then
				lastTutorial = OrderHallMissionTutorialFrame.id;
				nextTutorial = lastTutorial + 1;
			else
				tutorialFlags = bit.bor(tutorialFlags, OrderHallMissionTutorialFrame.id);
			end
			WriteTutorialCVAR(lastTutorial, tutorialFlags);
			OrderHallMissionTutorialFrame:Hide();
			OrderHallMissionTutorialFrame.id = nil;
		elseif (tutorial.cancelConditionFunc and tutorial.cancelConditionFunc(self, tutorial)) then
			OrderHallMissionTutorialFrame:Hide();
			OrderHallMissionTutorialFrame.id = nil;
		else
			-- We have a tutorial showing already, and it's not ready to close or advance, so just call TryShowTutorial on that (it may have been hidden by other means)
			self:TryShowTutorial(tutorial);
			return;
		end
	end

	local eligibleTutorialIDs = { }
	if (tutorials[nextTutorial]) then
		tinsert(eligibleTutorialIDs, nextTutorial);
	end

	local tutorialFlag = 0x10000;
	while (tutorials[tutorialFlag]) do
		if (bit.band(bit.bnot(tutorialFlags), tutorialFlag) ~= 0) then
			tinsert(eligibleTutorialIDs, tutorialFlag);
		end
		tutorialFlag = bit.lshift(tutorialFlag, 1);
	end

	for _, id in ipairs(eligibleTutorialIDs) do
		tutorial = tutorials[id];
		if self:TryShowTutorial(tutorial) then
			break;
		end
	end
end
