GARRISON_MISSION_COMPLETE_BANNER_WIDTH = 300;
GARRISON_MODEL_PRELOAD_TIME = .25;
GARRISON_LONG_MISSION_TIME = 8 * 60 * 60;	-- 8 hours
GARRISON_LONG_MISSION_TIME_FORMAT = "|cffff7d1a%s|r";

---------------------------------------------------------------------------------
--- Garrison Follower Options				                                  ---
---------------------------------------------------------------------------------

-- These are follower options that depend on this AddOn being loaded, and so they can't be set in GarrisonBaseUtils.
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower].missionFollowerSortFunc = GarrisonFollowerList_DefaultMissionSort;
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower].missionFollowerInitSortFunc = GarrisonFollowerList_InitializeDefaultMissionSort;

---------------------------------------------------------------------------------
--- Garrison Follower Mission  Mixin Functions                                ---
---------------------------------------------------------------------------------

GarrisonFollowerMission = {};

function GarrisonFollowerMission:SetupMissionList()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("GarrisonMissionListButtonTemplate", function(button, elementData)
		GarrisonMissionList_InitButton(button, elementData, self);
	end);
	view:SetPadding(8,0,13,13,4);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.MissionTab.MissionList.ScrollBox, self.MissionTab.MissionList.ScrollBar, view);

	GarrisonMissionListTab_SetTab(self.MissionTab.MissionList.Tab1);
end

function GarrisonFollowerMission:OnLoadMainFrame()
	GarrisonMission.OnLoadMainFrame(self);

	self.TitleText:SetText(GARRISON_MISSIONS_TITLE);
	self.FollowerTab.ItemWeapon.Name:SetText(WEAPON);
	self.FollowerTab.ItemArmor.Name:SetText(ARMOR);

	self:UpdateCurrency();

	self:SetupMissionList();

	local factionGroup = UnitFactionGroup("player");
	if factionGroup == "Horde" then
		if self.MissionTab.MissionPage.RewardsFrame then
			self.MissionTab.MissionPage.RewardsFrame.Chest:SetAtlas("GarrMission-HordeChest");
		end

		if self.MissionTab.MissionPage.EmptyFollowerModel then
			self.MissionTab.MissionPage.EmptyFollowerModel.Texture:SetAtlas("GarrMission_Silhouettes-1Horde");
		end
	end
	self:SetupCompleteDialog();

	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GARRISON_MISSION_STARTED");
	self:RegisterEvent("GARRISON_MISSION_FINISHED");
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	self:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED");
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
end

function GarrisonFollowerMission:SetupCompleteDialog()
	local completeDialog = self:GetCompleteDialog();
	if (completeDialog) then
		local factionGroup = UnitFactionGroup("player");
		local chestDisplayID;
	    if ( factionGroup == "Horde" ) then
			chestDisplayID = 54913;
		    local dialogBorderFrame = completeDialog.BorderFrame;
		    dialogBorderFrame.Model:SetDisplayInfo(59175);
		    dialogBorderFrame.Model:SetPosition(0.2, 1.15, -0.7);
			GarrisonMissionStage_SetBack(dialogBorderFrame.Stage, "_GarrMissionLocation-FrostfireRidge-Back");
			GarrisonMissionStage_SetMid(dialogBorderFrame.Stage, "_GarrMissionLocation-FrostfireRidge-Mid");
			GarrisonMissionStage_SetFore(dialogBorderFrame.Stage, "_GarrMissionLocation-FrostfireRidge-Fore");
	    else
			chestDisplayID = 54912;
		    local dialogBorderFrame = completeDialog.BorderFrame;
		    dialogBorderFrame.Model:SetDisplayInfo(58063);
		    dialogBorderFrame.Model:SetPosition(0.2, .75, -0.7);
			GarrisonMissionStage_SetBack(dialogBorderFrame.Stage, "_GarrMissionLocation-ShadowmoonValley-Back");
			GarrisonMissionStage_SetMid(dialogBorderFrame.Stage, "_GarrMissionLocation-ShadowmoonValley-Mid");
			GarrisonMissionStage_SetFore(dialogBorderFrame.Stage, "_GarrMissionLocation-ShadowmoonValley-Fore");
	    end
		if (GarrisonFollowerOptions[self.followerTypeID].missionCompleteUseNeutralChest) then
			chestDisplayID = 71671;
		end
		if (self.MissionComplete.BonusRewards) then
			self.MissionComplete.BonusRewards.ChestModel:SetDisplayInfo(chestDisplayID);
		end
	end
end

function GarrisonFollowerMission:OnEventMainFrame(event, ...)
	if (event == "GARRISON_MISSION_LIST_UPDATE") then
		local followerTypeID = ...;
		if (followerTypeID == self.followerTypeID) then
			self:UpdateMissions();
		end
	elseif (event == "GARRISON_FOLLOWER_XP_CHANGED" and self.MissionTab.MissionPage:IsShown() and self.MissionTab.MissionPage.missionInfo ) then
		-- follower could have leveled at mission page, need to recheck counters
		local followerTypeID = ...;
		if (followerTypeID == self.followerTypeID) then
			self:GetFollowerBuffsForMission(self.MissionTab.MissionPage.missionInfo.missionID);
		end
	elseif (event == "CURRENCY_DISPLAY_UPDATE") then
		self:UpdateCurrency();
	elseif (event == "GARRISON_MISSION_STARTED") then
		local followerTypeID = ...;
		if (followerTypeID == self.followerTypeID) then
			if (self.MissionTab.MissionList and self.MissionTab.MissionList.Tab2) then
				local anim = self.MissionTab.MissionList.Tab2.MissionStartAnim;
				if (anim:IsPlaying()) then
					anim:Stop();
				end
				anim:Play();
			end
		end
	elseif (event == "GARRISON_MISSION_FINISHED") then
		local followerTypeID = ...;
		if (followerTypeID == self.followerTypeID) then
			self:CheckCompleteMissions();
		end
	elseif ( event == "GET_ITEM_INFO_RECEIVED" ) then
		self:UpdateRewards(...);
	elseif ( event == "GARRISON_RANDOM_MISSION_ADDED" ) then
		GarrisonMissionFrame_RandomMissionAdded(self, ...);
	elseif ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		if ( SpellCanTargetGarrisonFollower(0) ) then
			self.isTargettingGarrisonFollower = true;
			self:GetMissionPage():UpdatePortraitPulse();
		elseif ( self.isTargettingGarrisonFollower ) then
			self.isTargettingGarrisonFollower = false;
			self:GetMissionPage():UpdatePortraitPulse();
		end
	end
end

function GarrisonFollowerMission:OnShowMainFrame()
	GarrisonMission.OnShowMainFrame(self);
	self.abilityCountersForMechanicTypes = C_Garrison.GetFollowerAbilityCountersForMechanicTypes(self.followerTypeID);

	if (self.FollowerList.followerType ~= self.followerTypeID) then
		self.FollowerList:Initialize(self.followerTypeID);
	end
	self:CheckCompleteMissions(true);
	GarrisonThreatCountersFrame:SetParent(self.FollowerTab);
	GarrisonThreatCountersFrame:SetPoint("TOPRIGHT", -12, 30);
	PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_OPEN);
end

function GarrisonFollowerMission:OnHideMainFrame()
	if ( self:GetMissionPage().missionInfo ) then
		self:CloseMission();
	end
	GarrisonMissionFrame_ClearMouse();
	C_Garrison.CloseMissionNPC();
	HelpPlate_Hide();
	self:HideCompleteMissions(true);
	MissionCompletePreload_Cancel(self);
	PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_CLOSE);
	StaticPopup_Hide("DEACTIVATE_FOLLOWER");
	StaticPopup_Hide("ACTIVATE_FOLLOWER");
	StaticPopup_Hide("CONFIRM_FOLLOWER_TEMPORARY_ABILITY");
	StaticPopup_Hide("CONFIRM_FOLLOWER_UPGRADE");
	StaticPopup_Hide("CONFIRM_FOLLOWER_ABILITY_UPGRADE");
	StaticPopup_Hide("CONFIRM_FOLLOWER_EQUIPMENT");

	if (self.MissionTab.MissionList) then
		self.MissionTab.MissionList.newMissionIDs = { };
		self.MissionTab.MissionList:Update();
	end
end

function GarrisonFollowerMission:UpdateCurrency()
	local amount = C_CurrencyInfo.GetCurrencyInfo(self.FollowerList.MaterialFrame.currencyType).quantity;
	self.materialAmount = amount;
	amount = BreakUpLargeNumbers(amount)
	if (self.MissionTab.MissionList) then
		self.MissionTab.MissionList.MaterialFrame.Materials:SetText(amount);
	end
	self.FollowerList.MaterialFrame.Materials:SetText(amount);
end

function GarrisonFollowerMission:SelectTab(id)
	GarrisonMission.SelectTab(self, id);
	if (id == 1) then
		self.TitleText:SetText(GARRISON_MISSIONS_TITLE);
	else
		self.TitleText:SetText(GARRISON_FOLLOWERS_TITLE);
	end
	if ( UIDropDownMenu_GetCurrentDropDown() == self.OptionDropDown ) then
		CloseDropDownMenus();
	end
end

function GarrisonFollowerMission:OnClickMission(missionInfo)
	if (not GarrisonMission.OnClickMission(self, missionInfo)) then
		return false;
	end

	if (self.MissionTab.MissionList) then
		self.MissionTab.MissionList:Update();
		self.MissionTab.MissionList:Hide();
	end
	self:GetMissionPage():Show();

	self:ShowMission(missionInfo);

	self.FollowerList:UpdateFollowers();
	self:CheckTutorials();
	return true;
end

function GarrisonFollowerMission:ShowMissionStage(missionInfo)
	local missionPage = self:GetMissionPage();

	missionPage.Stage.Level:SetText(missionInfo.level);
	missionPage.Stage.Location:SetText(missionInfo.location);
	missionPage.Stage.MissionDescription:SetText(missionInfo.description);
end

function GarrisonFollowerMission:ShowMission(missionInfo)
	GarrisonMission.ShowMission(self, missionInfo);

	self:ShowMissionStage(missionInfo);
end

function GarrisonFollowerMission:SetPartySize(frame, size, numEnemies)
	GarrisonMission.SetPartySize(self, frame, size, numEnemies);

	frame.EmptyString:ClearAllPoints();
	if ( frame.FollowerModel ~= nil ) then
		frame.FollowerModel:Hide();

		if ( size == 1 ) then
			frame.EmptyString:SetText(GARRISON_PARTY_INSTRUCTIONS_SINGLE);
			frame.EmptyFollowerModel:Show();
			if ( numEnemies == 1 ) then
				frame.Followers[1]:SetPoint("TOPLEFT", frame.FollowerAnchor, 82, 0);
				frame.EmptyString:SetPoint("BOTTOMLEFT", frame.FollowerAnchor, 98, 0);
			else
				frame.Followers[1]:SetPoint("TOPLEFT", frame.FollowerAnchor, 22, 0);
				frame.EmptyString:SetPoint("BOTTOMLEFT", frame.FollowerAnchor, 28, 0);
			end
			frame.BuffsFrame:ClearAllPoints();
			frame.BuffsFrame:SetPoint("BOTTOMLEFT", frame.BuffsFrameAnchor, 80, 0);
		else
			frame.EmptyString:SetText(GARRISON_PARTY_INSTRUCTIONS_MANY);
			frame.EmptyString:SetPoint("BOTTOM", frame.FollowerAnchor, 0, 10);
			frame.EmptyFollowerModel:Hide();
			if ( size == 2 ) then
				frame.Followers[1]:SetPoint("TOPLEFT", frame.FollowerAnchor, 108, 0);
			else
				frame.Followers[1]:SetPoint("TOPLEFT", frame.FollowerAnchor, 22, 0);
			end
			if ( frame.BuffsFrame ) then
				frame.BuffsFrame:ClearAllPoints();
				frame.BuffsFrame:SetPoint("BOTTOM", frame.BuffsFrameAnchor, 0, 0);
			end
		end
	end
end

function GarrisonFollowerMission:SetEnemies(frame, enemies, numFollowers)
	local numVisibleEnemies = GarrisonMission.SetEnemies(self, frame, enemies, numFollowers);

	if ( numVisibleEnemies == 1 ) then
		if ( numFollowers == 1 ) then
			frame.Enemy1:SetPoint("TOPLEFT", 143, -164);
		else
			frame.Enemy1:SetPoint("TOPLEFT", 251, -164);
		end
	elseif ( numVisibleEnemies == 2 ) then
		if ( numFollowers == 1 ) then
			frame.Enemy1:SetPoint("TOPLEFT", 78, -164);
		else
			frame.Enemy1:SetPoint("TOPLEFT", 165, -164);
		end
	else
		frame.Enemy1:SetPoint("TOPLEFT", 78, -164);
	end

	return numVisibleEnemies;
end

function GarrisonFollowerMission:UpdateMissionData(missionPage)
	GarrisonMission.UpdateMissionData(self, missionPage);

	-- Followers - TODO move GarrisonMissionPage_UpdatePortraitPulse() into common file when shipyard has followers?
	missionPage:UpdatePortraitPulse();
	missionPage:UpdateEmptyString();
end

function GarrisonFollowerMission:SetEnemyName(portraitFrame, name)
	portraitFrame.Name:SetText(name);
end

function GarrisonFollowerMission:SetEnemyPortrait(portraitFrame, enemy, eliteFrame, numMechs)
	GarrisonPortrait_Set(portraitFrame.Portrait, enemy.portraitFileDataID);

	if ( numMechs > 1 ) then
		eliteFrame:Show();
	else
		eliteFrame:Hide();
	end
end

function GarrisonFollowerMission:SetFollowerPortrait(followerFrame, followerInfo, forMissionPage)
	local frame = followerFrame;
	if (followerFrame.PortraitFrame) then
		frame = followerFrame.PortraitFrame;
	end
	GarrisonMissionPortrait_SetFollowerPortrait(frame, followerInfo, forMissionPage and self:GetMissionPage() or nil);
end

function GarrisonFollowerMission:ClearParty()
	GarrisonMission.ClearParty(self);
	if (self:GetMissionPage().FollowerModel) then
		self:GetMissionPage().FollowerModel:Hide();
	end
	self:GetMissionPage():UpdateEmptyString();
end

function GarrisonFollowerMission:OnClickStartMissionButton()
	if (not GarrisonMission.OnClickStartMissionButton(self)) then
		return;
	end
	PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_MISSION_START);

	local helpTipInfo = self:GenerateHelpTipInfo();

	HelpTip:Show(ExpansionLandingPageMinimapButton, helpTipInfo);
end

function GarrisonFollowerMission:GenerateHelpTipInfo()
	return {
		text = GARRISON_VIEW_MISSION_PROGRESS_HERE,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_GARRISON_LANDING,
		targetPoint = HelpTip.Point.LeftEdgeCenter,
		offsetX = -5,
		checkCVars = true,
	};
end

function GarrisonFollowerMission:AssignFollowerToMission(frame, info)
	if (not GarrisonMission.AssignFollowerToMission(self, frame, info)) then
		return;
	end

	if info.slotSoundKitID then
		PlaySound(info.slotSoundKitID);
	end

	local soundToPlay;
	if (info.isTroop) then
		soundToPlay = GarrisonFollowerOptions[info.followerTypeID].missionPageAssignTroopSound;
	else
		soundToPlay = GarrisonFollowerOptions[info.followerTypeID].missionPageAssignFollowerSound;
	end
	if (soundToPlay) then
		PlaySound(soundToPlay);
	end

	frame.Name:Show();
	frame.Name:SetText(info.name);
	if (frame.Class) then
		frame.Class:Show();
		frame.Class:SetAtlas(info.classAtlas);
	end
	frame.PortraitFrame.Empty:Hide();

	self:GetMissionPage():UpdateFollowerModel(info);

	self:CheckTutorials(true);
end

function GarrisonFollowerMission:RemoveFollowerFromMission(frame, updateValues)
	GarrisonMission.RemoveFollowerFromMission(self, frame, updateValues);

	local followerID = frame.info and frame.info.followerID or nil;
	frame.info = nil;
	frame.Name:Hide();
	if (frame.Class) then
		frame.Class:Hide();
	end
	frame.PortraitFrame.Empty:Show();
	frame.PortraitFrame:SetLevel("");
	frame.PortraitFrame.Caution:Hide();

	if (followerID and self:GetMissionPage().missionInfo.numFollowers == 1 ) then
		self:GetMissionPage().FollowerModel:ClearModel();
		self:GetMissionPage().FollowerModel:Hide();
		self:GetMissionPage().EmptyFollowerModel:Show();
	end
end

function GarrisonFollowerMission:UpdateMissionParty(followers)
	GarrisonMission.UpdateMissionParty(self, followers, "GarrisonMissionAbilityLargeCounterTemplate");

	local maxCountersToDisplay = GarrisonFollowerOptions[self.followerTypeID].missionPageMaxCountersInFollowerFrame;
	local maxCountersToDisplayBeforeScaling = GarrisonFollowerOptions[self.followerTypeID].missionPageMaxCountersInFollowerFrameBeforeScaling;

	for followerIndex = 1, #followers do
		local followerFrame = followers[followerIndex];
		if ( followerFrame.info ) then
			local counters = self.followerCounters and followerFrame.info and self.followerCounters[followerFrame.info.followerID] or nil;
			if ( counters ) then
				if (#counters > maxCountersToDisplayBeforeScaling) then
					followerFrame.Counters[1]:SetPoint("LEFT", 74, -1);
				else
					followerFrame.Counters[1]:SetPoint("LEFT", 64, -1);
				end
				for i = 1, min(#counters, maxCountersToDisplay) do
					local Counter = followerFrame.Counters[i];
					if (#counters > maxCountersToDisplayBeforeScaling) then
						Counter:SetScale(0.8);
					else
						Counter:SetScale(1);
					end
				end
			end
		end
	end
end

function GarrisonFollowerMission:ClearMouse()
	GarrisonMissionFrame_ClearMouse();
end

function GarrisonFollowerMission:OnDragStartFollowerButton(placer, frame, yOffset)
	GarrisonMission.OnDragStartFollowerButton(self, placer, frame, yOffset);
	CloseDropDownMenus();
end

function GarrisonFollowerMission:OnMouseUpMissionFollower(frame, button)
	if ( button == "LeftButton" ) then
		if ( frame.info and SpellCanTargetGarrisonFollower(frame.info.followerID) and C_Garrison.TargetSpellHasFollowerTemporaryAbility() ) then
			GarrisonFollower_AttemptUpgrade(frame.info.followerID);
		end
	else
		GarrisonMission.OnMouseUpMissionFollower(self, frame, button);
	end
end

function GarrisonFollowerMission:UpdateMissions()
	if (self.MissionTab.MissionList) then
		self.MissionTab.MissionList:UpdateMissions();
		self:CheckTutorials();
	end
end

function GarrisonFollowerMission:CheckCompleteMissions(onShow)
	if (not GarrisonMission.CheckCompleteMissions(self, onShow)) then
		return;
	end

	-- preload all follower and enemy models
	MissionCompletePreload_LoadMission(self, self.MissionComplete.completeMissions[1].missionID,
		GarrisonFollowerOptions[self.followerTypeID].showSingleMissionCompleteFollower,
		GarrisonFollowerOptions[self.followerTypeID].showSingleMissionCompleteAnimation);

	-- go to the right tab if window is being open
	if ( onShow ) then
		self:SelectTab(1);
	end

	if (self.MissionTab.MissionList and self.MissionTab.MissionList.Tab1) then
		GarrisonMissionListTab_SetTab(self.MissionTab.MissionList.Tab1);
	end
end

function GarrisonFollowerMission:MissionCompleteInitialize(missionList, index)
	if (not GarrisonMission.MissionCompleteInitialize(self, missionList, index)) then
		return false;
	end

	local mission = missionList[index];
	local frame = self.MissionComplete;
	local stage = frame.Stage;
	stage.MissionInfo.Level:SetText(mission.level);
	stage.MissionInfo.Location:SetText(mission.location);

	-- max level
	if ( GarrisonFollowerOptions[mission.followerTypeID].showILevelOnMission and mission.level == self.followerMaxLevel and mission.iLevel > 0 ) then
		stage.MissionInfo.Level:SetPoint("CENTER", stage.MissionInfo, "TOPLEFT", 30, -28);
		stage.MissionInfo.ItemLevel:Show();
		stage.MissionInfo.ItemLevel:SetFormattedText(NUMBER_IN_PARENTHESES, mission.iLevel);
		stage.ItemLevelHitboxFrame:Show();
	else
		stage.MissionInfo.Level:SetPoint("CENTER", stage.MissionInfo, "TOPLEFT", 30, -36);
		stage.MissionInfo.ItemLevel:Hide();
		stage.ItemLevelHitboxFrame:Hide();
	end

	return true;
end

function GarrisonFollowerMission_ResetMissionCompleteEncounter(encounter)
	encounter:Show();
	encounter.CheckFrame.SuccessAnim:Stop();
	encounter.CheckFrame.FailureAnim:Stop();
	encounter.CheckFrame.CrossLeft:SetAlpha(0);
	encounter.CheckFrame.CrossRight:SetAlpha(0);
	encounter.CheckFrame.CheckMark:SetAlpha(0);
	encounter.CheckFrame.CheckMarkGlow:SetAlpha(0);
	encounter.CheckFrame.CheckMarkLeft:SetAlpha(0);
	encounter.CheckFrame.CheckMarkRight:SetAlpha(0);
	encounter.CheckFrame.CheckSmoke:SetAlpha(0);
	encounter.Name:Hide();
	encounter.GlowFrame.OnAnim:Stop();
	encounter.GlowFrame.OffAnim:Stop();
	encounter.GlowFrame.SpikeyGlow:SetAlpha(0);
	encounter.GlowFrame.EncounterGlow:SetAlpha(0);
end

function GarrisonFollowerMission:ResetMissionCompleteEncounter(encounter)
	GarrisonFollowerMission_ResetMissionCompleteEncounter(encounter);
end


---------------------------------------------------------------------------------
--- Garrison Mission Frame                                                    ---
---------------------------------------------------------------------------------

StaticPopupDialogs["DEACTIVATE_FOLLOWER"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		C_Garrison.SetFollowerInactive(self.data, true);
	end,
	OnShow = function(self)
		local quality = C_Garrison.GetFollowerQuality(self.data);
		local name = FOLLOWER_QUALITY_COLORS[quality].hex..C_Garrison.GetFollowerName(self.data)..FONT_COLOR_CODE_CLOSE;
		local cost = GetMoneyString(C_Garrison.GetFollowerActivationCost());
		local uses = C_Garrison.GetNumFollowerDailyActivations();
		self.text:SetFormattedText(GARRISON_DEACTIVATE_FOLLOWER_CONFIRMATION, name, cost, uses);
	end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ACTIVATE_FOLLOWER"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		C_Garrison.SetFollowerInactive(self.data, false);
	end,
	OnShow = function(self)
		local quality = C_Garrison.GetFollowerQuality(self.data);
		local name = FOLLOWER_QUALITY_COLORS[quality].hex..C_Garrison.GetFollowerName(self.data)..FONT_COLOR_CODE_CLOSE;
		local followerInfo = C_Garrison.GetFollowerInfo(self.data);
		local uses = C_Garrison.GetNumFollowerActivationsRemaining(GarrisonFollowerOptions[followerInfo.followerTypeID].garrisonType);
		self.text:SetFormattedText(GARRISON_ACTIVATE_FOLLOWER_CONFIRMATION, name, uses);
		MoneyFrame_Update(self.moneyFrame, C_Garrison.GetFollowerActivationCost());
	end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hasMoneyFrame = 1,
	hideOnEscape = 1
};

local tutorials = {
	[1] = { text = GARRISON_MISSION_TUTORIAL1, anchor = "mission", offsetX = -135, offsetY = 13, parent = "MissionList", targetPoint = HelpTip.Point.BottomEdgeCenter },
	[2] = { text = GARRISON_MISSION_TUTORIAL2, anchor = "mission", offsetX = -37, offsetY = 13, parent = "MissionList", targetPoint = HelpTip.Point.BottomEdgeRight },
	[3] = { text = GARRISON_MISSION_TUTORIAL3, anchor = "threat", offsetX = 0, offsetY = 8, parent = "MissionPage", targetPoint = HelpTip.Point.BottomEdgeCenter },
	[4] = { text = GARRISON_MISSION_TUTORIAL4, anchor = "follower", offsetX = -16, offsetY = 33, parent = "MissionPage", targetPoint = HelpTip.Point.BottomEdgeRight },
	[5] = { text = GARRISON_MISSION_TUTORIAL5, anchor = "slot", offsetX = 26, offsetY = 3, parent = "MissionPage", targetPoint = HelpTip.Point.BottomEdgeLeft },
	[6] = { text = GARRISON_MISSION_TUTORIAL6, anchor = "threat", offsetX = 0, offsetY = 8, parent = "MissionPage", targetPoint = HelpTip.Point.BottomEdgeCenter },
	[7] = { text = GARRISON_MISSION_TUTORIAL7, anchor = "rewards",  offsetX = 32, offsetY = -23, parent = "MissionPage", targetPoint = HelpTip.Point.TopEdgeLeft },
	[8] = { text = GARRISON_MISSION_TUTORIAL9, anchor = "button", offsetX = 0, offsetY = -17, parent = "MissionPage", targetPoint = HelpTip.Point.TopEdgeCenter },
}

-- TODO: Move these GarrisonMissionFrame_ functions to the GarrisonFollowerMission mixin
function GarrisonFollowerMission:OnCloseMissionTutorial()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:CheckTutorials(true);
end

function GarrisonFollowerMission:CheckTutorials(advance)
	local lastTutorial = tonumber(GetCVar("lastGarrisonMissionTutorial"));
	if ( lastTutorial ) then
		if ( advance ) then
			lastTutorial = lastTutorial + 1;
			SetCVar("lastGarrisonMissionTutorial", lastTutorial);
		end
		local tutorialFrame = GarrisonMissionTutorialFrame;
		if ( lastTutorial >= #tutorials ) then
			tutorialFrame:Hide();
		elseif ( GarrisonMissionFrame:IsShown() ) then
			local tutorial = tutorials[lastTutorial + 1];
			-- parent frame
			tutorialFrame:SetParent(GarrisonMissionFrame.MissionTab[tutorial.parent]);
			tutorialFrame:SetFrameStrata("DIALOG");
			tutorialFrame:SetPoint("TOPLEFT", GarrisonMissionFrame, 0, -21);
			tutorialFrame:SetPoint("BOTTOMRIGHT", GarrisonMissionFrame);

			local relativeFrame;
			local anchor = tutorial.anchor;
			if anchor == "mission" then
				relativeFrame = self.MissionTab.MissionList.ScrollBox:GetFrames()[1];
			elseif anchor == "threat" then
				local enemy = self:GetMissionPage().Enemy1;
				if enemy then
					relativeFrame = enemy.Mechanics[1];
				end
			elseif anchor == "follower" then
				relativeFrame = self.FollowerList.ScrollBox:GetFrames()[1];
			elseif anchor == "slot" then
				relativeFrame = self:GetMissionPage().Follower1;
			elseif anchor == "rewards" then
				relativeFrame = self:GetMissionPage().RewardsFrame;
			elseif anchor == "button" then
				relativeFrame = self:GetMissionPage().ButtonFrame;
			end
			if relativeFrame then
				local helpTipInfo = {
					text = tutorial.text,
					buttonStyle = HelpTip.ButtonStyle.Next,
					targetPoint = tutorial.targetPoint,
					onAcknowledgeCallback = GenerateClosure(self.OnCloseMissionTutorial, self),
					offsetX = tutorial.offsetX,
					offsetY = tutorial.offsetY,
				};

				local wasShown = HelpTip:Show(tutorialFrame, helpTipInfo, relativeFrame);
				tutorialFrame:SetShown(wasShown);
			end
		end
	end
end

function GarrisonMissionFrame_ToggleFrame()
	if (not GarrisonMissionFrame:IsShown()) then
		ShowUIPanel(GarrisonMissionFrame);
	else
		HideUIPanel(GarrisonMissionFrame);
	end
end

function GarrisonMissionFrame_ClearMouse()
	GarrisonFollowerPlacerFrame:Hide();
	if ( GarrisonFollowerPlacer.info ) then
		GarrisonFollowerPlacer:Hide();
		GarrisonFollowerPlacer.info = nil;

		return true;
	elseif (CovenantFollowerPlacer.info ) then
		CovenantFollowerPlacer:Hide();
		CovenantFollowerPlacer.info = nil;

		EventRegistry:TriggerEvent("CovenantMission.CancelLoopingTargetingAnimation");
		return true;
	end
	return false;
end

function GarrisonMissionPortrait_SetFollowerPortrait(portraitFrame, followerInfo, missionPage)
	portraitFrame:SetQuality(followerInfo.quality);
	if ( missionPage ) then
		local boosted = false;
		local followerLevel = followerInfo.level;
		if ( missionPage.mentorLevel and missionPage.mentorLevel > followerLevel ) then
			followerLevel = missionPage.mentorLevel;
			boosted = true;
		end
		portraitFrame:SetupPortrait(followerInfo);
		if ( followerInfo.isTroop ) then
			portraitFrame:SetNoLevel();
		elseif ( (missionPage.showItemLevel and followerInfo.isMaxLevel ) or GarrisonFollowerOptions[followerInfo.followerTypeID].showILevelOnFollower) then
			local followerItemLevel = followerInfo.iLevel;
			if ( missionPage.mentorItemLevel and missionPage.mentorItemLevel > followerItemLevel ) then
				followerItemLevel = missionPage.mentorItemLevel;
				boosted = true;
			end
			portraitFrame:SetILevel(followerItemLevel);
		else
			portraitFrame:SetLevel(followerLevel);
		end
		local followerBias = C_Garrison.GetFollowerBiasForMission(missionPage.missionInfo.missionID, followerInfo.followerID);
		if ( followerBias == -1 ) then
			portraitFrame.Level:SetTextColor(1, 0.1, 0.1);
		elseif ( followerBias < 0 ) then
			portraitFrame.Level:SetTextColor(1, 0.5, 0.25);
		elseif ( boosted ) then
			portraitFrame.Level:SetTextColor(0.1, 1, 0.1);
		else
			portraitFrame.Level:SetTextColor(1, 1, 1);
		end

		if GarrisonFollowerOptions[followerInfo.followerTypeID].showCautionSignOnMissionFollowersSmallBias then
			portraitFrame.Caution:SetShown(followerBias < 0);
		else
			portraitFrame.Caution:SetShown(followerBias == -1);
		end
	else
		portraitFrame:SetupPortrait(followerInfo);
	end
end

function GarrisonFollowerMission:UpdateRewards(itemID)
	-- mission list
	if (self.MissionTab.MissionList) then
		self.MissionTab.MissionList.ScrollBox:ForEachFrame(function(frame)
			self:CheckRewardButtons(frame.Rewards, itemID);
		end);
	end
	-- mission page
	if (self:GetMissionPage().RewardsFrame) then
		if (self:GetMissionPage().RewardsFrame.Rewards) then
			self:CheckRewardButtons(self:GetMissionPage().RewardsFrame.Rewards, itemID);
		end
		if (self:GetMissionPage().RewardsFrame.OvermaxItem) then
			if ( self:GetMissionPage().RewardsFrame.OvermaxItem.itemID == itemID ) then
				GarrisonMissionFrame_SetItemRewardDetails(self:GetMissionPage().RewardsFrame.OvermaxItem);
			end
		end
	end
	-- mission complete
	if (self.MissionComplete.BonusRewards) then
		self:CheckRewardButtons(self.MissionComplete.BonusRewards.Rewards, itemID);
	end
end

function GarrisonMissionFrame_RandomMissionAdded(self, followerTypeID, missionID)
	if (followerTypeID == self.followerTypeID) then
		self.MissionTab.MissionList.newMissionIDs[missionID] = true;
		self.MissionTab.MissionList:Update();
	end
end

function GarrisonFollowerMission:CheckRewardButtons(rewardButtons, itemID)
	for i = 1, #rewardButtons do
		local frame = rewardButtons[i];
		if ( frame.itemID == itemID ) then
			GarrisonMissionFrame_SetItemRewardDetails(frame);
		end
	end
end

---------------------------------------------------------------------------------
--- Follower Dropdown                                                         ---
---------------------------------------------------------------------------------
function GarrisonFollowerOptionDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	local missionFrame = self:GetParent():GetParent();
	local missionPage;
	if (missionFrame.MissionTab) then
		missionPage = missionFrame:GetMissionPage();
	end

	local follower = self.followerID and C_Garrison.GetFollowerInfo(self.followerID);
	if ( follower ) then
		if ( missionPage and missionPage:IsVisible() and missionPage.missionInfo ) then
			info.text = GARRISON_MISSION_ADD_FOLLOWER;
			info.func = function()
				missionPage:AddFollower(self.followerID);
			end
			if ( C_Garrison.GetNumFollowersOnMission(missionPage.missionInfo.missionID) >= missionPage.missionInfo.numFollowers or C_Garrison.GetFollowerStatus(self.followerID)) then
				info.disabled = 1;
			end
			UIDropDownMenu_AddButton(info);
		end

		local followerStatus = C_Garrison.GetFollowerStatus(self.followerID);
		if ( followerStatus == GARRISON_FOLLOWER_INACTIVE ) then
			info.text = GARRISON_ACTIVATE_FOLLOWER;
			local followerInfo = C_Garrison.GetFollowerInfo(self.followerID);
			if ( C_Garrison.GetNumFollowerActivationsRemaining(GarrisonFollowerOptions[followerInfo.followerTypeID].garrisonType) == 0 ) then
				info.disabled = 1;
				info.tooltipWhileDisabled = 1;
				info.tooltipTitle = GARRISON_ACTIVATE_FOLLOWER;
				info.tooltipText = GARRISON_NO_MORE_FOLLOWER_ACTIVATIONS;
				info.tooltipOnButton = 1;
			elseif ( C_Garrison.GetFollowerActivationCost() > GetMoney() ) then
				info.tooltipWhileDisabled = 1;
				info.tooltipTitle = GARRISON_ACTIVATE_FOLLOWER;
				info.tooltipText = format(GARRISON_CANNOT_AFFORD_FOLLOWER_ACTIVATION, GetMoneyString(C_Garrison.GetFollowerActivationCost()));
				info.tooltipOnButton = 1;
				info.disabled = 1;
			else
				info.disabled = nil;
				info.func = function()
					StaticPopup_Show("ACTIVATE_FOLLOWER", follower.name, nil, self.followerID);
				end
			end
		else
			info.text = GARRISON_DEACTIVATE_FOLLOWER;
			info.func = function()
				StaticPopup_Show("DEACTIVATE_FOLLOWER", follower.name, nil, self.followerID);
			end
			if ( follower.isTroop ) then
				info.disabled = 1;
			elseif ( followerStatus == GARRISON_FOLLOWER_ON_MISSION ) then
				info.disabled = 1;
				info.tooltipWhileDisabled = 1;
				info.tooltipTitle = GARRISON_DEACTIVATE_FOLLOWER;
				info.tooltipText = GARRISON_FOLLOWER_CANNOT_DEACTIVATE_ON_MISSION;
				info.tooltipOnButton = 1;
			elseif ( not C_Garrison.IsAboveFollowerSoftCap(missionFrame.followerTypeID) ) then
				info.disabled = 1;
			else
				info.disabled = nil;
			end
		end
		UIDropDownMenu_AddButton(info);
	end

	info.text = CANCEL;
	info.tooltipTitle = nil;
	info.func = nil;
	info.disabled = nil;
	UIDropDownMenu_AddButton(info);
end

---------------------------------------------------------------------------------
--- Mission List                                                              ---
---------------------------------------------------------------------------------

GarrisonMissionListMixin = { }

function GarrisonMissionListMixin:OnLoad()
	self.inProgressMissions = {};
	self.availableMissions = {};
	self.newMissionIDs = {};
end

function GarrisonMissionListMixin:GetMissionFrame()
	return self:GetParent():GetParent();
end

function GarrisonMissionListMixin:OnShow()
	self:UpdateMissions();
	self:GetMissionFrame().FollowerList:Hide();
	self:GetMissionFrame():CheckTutorials();
end

function GarrisonMissionListMixin:OnHide()
	self.missions = nil;
	GarrisonFollowerPlacer:SetScript("OnUpdate", nil);
end

function GarrisonMissionListMixin:OnUpdate()
	if (self.showInProgress) then
		C_Garrison.GetInProgressMissions(self.inProgressMissions, self:GetMissionFrame().followerTypeID);
		self.Tab2:SetText(WINTERGRASP_IN_PROGRESS.." - "..#self.inProgressMissions)

		local dataProvider = self.ScrollBox:GetDataProvider();
		if dataProvider then
			for index, mission in ipairs(self.inProgressMissions) do
				local elementData = dataProvider:FindElementDataByPredicate(function(elementData)
					return elementData.mission.missionID == mission.missionID;
				end);

				-- Move the mission data into the elementData we want to keep.
				if elementData then
					MergeTable(elementData.mission, mission);
				end
			end

			self.ScrollBox:ForEachFrame(function(frame)
				GarrisonMissionList_InitButton(frame, frame:GetElementData(), self:GetParent():GetParent());
			end);
		else
			self:Update();
		end
	else
		local timeNow = GetTime();
		for i = 1, #self.availableMissions do
			if ( self.availableMissions[i].offerEndTime and self.availableMissions[i].offerEndTime <= timeNow ) then
				self:UpdateMissions();
				break;
			end
		end
	end
	self:UpdateCombatAllyMission();
end

function GarrisonMissionListTab_OnClick(self, button)
	PlaySound(SOUNDKIT.UI_GARRISON_NAV_TABS);
	GarrisonMissionListTab_SetTab(self);
end

function GarrisonMissionListTab_SetTab(self)
	local list = self:GetParent();
	local mainFrame = self:GetParent():GetParent():GetParent();
	if (self:GetID() == 1) then
		list.showInProgress = false;
		GarrisonMissonListTab_SetSelected(list.Tab2, false);
	else
		list.showInProgress = true;
		GarrisonMissonListTab_SetSelected(list.Tab1, false);
	end
	GarrisonMissonListTab_SetSelected(self, true);
	mainFrame:UpdateMissions();
end

function GarrisonMissonListTab_SetSelected(tab, isSelected)
	tab.SelectedLeft:SetShown(isSelected);
	tab.SelectedRight:SetShown(isSelected);
	tab.SelectedMid:SetShown(isSelected);
end

-- overridden by subclasses
function GarrisonMissionListMixin:UpdateCombatAllyMission()
	self.combatAllyMission = C_Garrison.GetCombatAllyMission(self:GetMissionFrame().followerTypeID);
end

function GarrisonMissionListMixin:UpdateMissions()
	C_Garrison.GetInProgressMissions(self.inProgressMissions, self:GetMissionFrame().followerTypeID);
	C_Garrison.GetAvailableMissions(self.availableMissions, self:GetMissionFrame().followerTypeID);
	self:UpdateCombatAllyMission();
	Garrison_SortMissions(self.availableMissions);
	self.Tab1:SetText(AVAILABLE.." - "..#self.availableMissions)
	self.Tab2:SetText(WINTERGRASP_IN_PROGRESS.." - "..#self.inProgressMissions)
	if ( #self.inProgressMissions > 0 ) then
		self.Tab2.Left:SetDesaturated(false);
		self.Tab2.Right:SetDesaturated(false);
		self.Tab2.Middle:SetDesaturated(false);
		self.Tab2.Text:SetTextColor(1, 1, 1);
		self.Tab2:SetEnabled(true);
	else
		self.Tab2.Left:SetDesaturated(true);
		self.Tab2.Right:SetDesaturated(true);
		self.Tab2.Middle:SetDesaturated(true);
		self.Tab2.Text:SetTextColor(0.5, 0.5, 0.5);
		self.Tab2:SetEnabled(false);
	end
	self:Update();
end

function GarrisonMissionList_InitButton(button, elementData, missionFrame)
	local mission = elementData.mission;
	local index = elementData.index;

	button.id = index;
	button.info = mission;
	button.Title:SetWidth(0);
	button.Title:SetText(mission.name);
	button.Level:SetText(mission.level);
	if ( mission.durationSeconds >= GARRISON_LONG_MISSION_TIME ) then
		local duration = format(GARRISON_LONG_MISSION_TIME_FORMAT, mission.duration);
		button.Summary:SetFormattedText(PARENS_TEMPLATE, duration);
	else
		button.Summary:SetFormattedText(PARENS_TEMPLATE, mission.duration);
	end
	if ( mission.locTextureKit ) then
		button.LocBG:Show();
		button.LocBG:SetAtlas(mission.locTextureKit.."-List");
	else
		button.LocBG:Hide();
	end
	if (mission.isRare) then
		button.RareOverlay:Show();
		button.RareText:Show();
		button.IconBG:SetVertexColor(0, 0.012, 0.291, 0.4)
	else
		button.RareOverlay:Hide();
		button.RareText:Hide();
		button.IconBG:SetVertexColor(0, 0, 0, 0.4)
	end
	local showingItemLevel = false;

	local followerTypeID = missionFrame.followerTypeID;

	if ( GarrisonFollowerOptions[followerTypeID].showILevelOnMission and mission.isMaxLevel and mission.iLevel > 0 ) then
		button.ItemLevel:SetFormattedText(NUMBER_IN_PARENTHESES, mission.iLevel);
		button.ItemLevel:Show();
		showingItemLevel = true;
	else
		button.ItemLevel:Hide();
	end
	if ( showingItemLevel and mission.isRare ) then
		button.Level:SetPoint("CENTER", button, "TOPLEFT", 35, -22);
	else
		button.Level:SetPoint("CENTER", button, "TOPLEFT", 35, -36);
	end

	button:Enable();
	if (mission.inProgress) then
		button.Overlay:Show();
		button.Summary:SetText(mission.timeLeft.." "..RED_FONT_COLOR_CODE..GARRISON_MISSION_IN_PROGRESS..FONT_COLOR_CODE_CLOSE);
	else
		button.Overlay:Hide();
	end
	if ( button.Title:GetWidth() + button.Summary:GetWidth() + 8 < 655 - #mission.rewards * 65 ) then
		button.Title:SetPoint("LEFT", 165, 0);
		button.Summary:ClearAllPoints();
		button.Summary:SetPoint("BOTTOMLEFT", button.Title, "BOTTOMRIGHT", 8, 0);
	else
		button.Title:SetPoint("LEFT", 165, 10);
		button.Title:SetWidth(655 - #mission.rewards * 65);
		button.Summary:ClearAllPoints();
		button.Summary:SetPoint("TOPLEFT", button.Title, "BOTTOMLEFT", 0, -4);
	end
	button.MissionType:SetAtlas(mission.typeAtlas);
	if (followerTypeID == Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower0) then
		button.MissionType:SetSize(62, 62);
		button.MissionType:SetPoint("TOPLEFT", 74, -6);
	else
		button.MissionType:SetSize(75, 75);
		button.MissionType:SetPoint("TOPLEFT", 68, -2);
	end
	GarrisonMissionButton_SetRewards(button, mission.rewards, #mission.rewards);

	local isNewMission = missionFrame.MissionTab.MissionList.newMissionIDs[mission.missionID];
	if (isNewMission) then
		if (not button.NewHighlight) then
			button.NewHighlight = CreateFrame("Frame", nil, button, "GarrisonMissionListButtonNewHighlightTemplate");
			button.NewHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
			button.NewHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0);
		end
		button.NewHighlight:Show();
	else
		if (button.NewHighlight) then
			button.NewHighlight:Hide();
		end
	end
end

function GarrisonMissionListMixin:Update()
	local missions = self.showInProgress and self.inProgressMissions or self.availableMissions;

	local dataProvider = CreateDataProvider();
	for index, mission in ipairs(missions) do
		dataProvider:Insert({index=index, mission=mission});
	end

	local function SortWrapper(lhs, rhs)
		return GarrisonMissionSorter(lhs.mission, rhs.mission);
	end
	dataProvider:SetSortComparator(SortWrapper);

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	local haveMissions = dataProvider:GetSize() > 0;
	self.EmptyListString:SetShown(not haveMissions);
end

function GarrisonMissionButtonRewards_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if (self.itemID) then
		self.UpdateTooltip = GarrisonMissionButtonRewards_OnEnter;
		if(self.itemLink) then
			GameTooltip:SetHyperlink(self.itemLink);
		else
			GameTooltip:SetItemByID(self.itemID);
		end
		return;
	end
	self.UpdateTooltip = nil;
	if (self.currencyID and self.currencyID ~= 0 and self.currencyQuantity) then
		GameTooltip:SetCurrencyByID(self.currencyID, self.currencyQuantity);
		return;
	end
	if (self.title) then
		GameTooltip:SetText(self.title);
	end
	if (self.tooltip) then
		GameTooltip:AddLine(self.tooltip, 1, 1, 1, true);
	end
	GameTooltip:Show();
end

function GarrisonMissionButton_OnClick(self, button)
	local missionFrame = self:GetParent():GetParent():GetParent():GetParent():GetParent();
	missionFrame:OnClickMission(self.info);
end

function GarrisonMissionButton_GetMissionFrame(self)
	local missionList = self:GetParent():GetParent():GetParent();
	return missionList:GetMissionFrame();
end

function GarrisonMissionButton_OnEnter(self, button)
	if (self.info == nil) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");

	local missionFrame = GarrisonMissionButton_GetMissionFrame(self);
	if(self.info.inProgress) then
		GarrisonMissionButton_SetInProgressTooltip(self.info);
	else
		GameTooltip:SetText(self.info.name);
		GameTooltip:AddLine(string.format(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, self.info.numFollowers), 1, 1, 1);
		GarrisonMissionButton_AddThreatsToTooltip(self.info.missionID, missionFrame.followerTypeID, false, missionFrame.abilityCountersForMechanicTypes );
		if (self.info.isRare) then
			GameTooltip:AddLine(GARRISON_MISSION_AVAILABILITY);
			GameTooltip:AddLine(self.info.offerTimeRemaining, 1, 1, 1);
		end
		if not C_Garrison.IsPlayerInGarrison(GarrisonFollowerOptions[missionFrame.followerTypeID].garrisonType) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(GarrisonFollowerOptions[missionFrame.followerTypeID].strings.RETURN_TO_START, nil, nil, nil, 1);
		end
	end

	GameTooltip:Show();

	missionFrame.MissionTab.MissionList.newMissionIDs[self.info.missionID] = nil;
	missionFrame.MissionTab.MissionList.ScrollBox:ForEachFrame(function(frame)
		GarrisonMissionList_InitButton(frame, frame:GetElementData(), missionFrame);
	end);
end

function GarrisonMissionButton_SetInProgressTooltip(missionInfo, showRewards)
	GameTooltip:SetText(missionInfo.name);
	-- level
	if ( GarrisonFollowerOptions[missionInfo.followerTypeID].showILevelOnMission and  missionInfo.isMaxLevel and missionInfo.iLevel > 0 ) then
		GameTooltip:AddLine(format(GARRISON_MISSION_LEVEL_ITEMLEVEL_TOOLTIP, missionInfo.level, missionInfo.iLevel), 1, 1, 1);
	else
		GameTooltip:AddLine(format(GARRISON_MISSION_LEVEL_TOOLTIP, missionInfo.level), 1, 1, 1);
	end
	-- completed?
	if(missionInfo.isComplete) then
		GameTooltip:AddLine(COMPLETE, 1, 1, 1);
	end
	-- success chance, automissions don't have success chance
	local successChance = C_Garrison.GetMissionSuccessChance(missionInfo.missionID);
	if ( successChance and missionInfo.followerTypeID ~= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower) then
		GameTooltip:AddLine(format(GARRISON_MISSION_PERCENT_CHANCE, successChance), 1, 1, 1);
	end

	if ( showRewards ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(REWARDS);
		for id, reward in pairs(missionInfo.rewards) do
			if (reward.quality) then
				GameTooltip:AddLine(ITEM_QUALITY_COLORS[reward.quality + 1].hex..reward.title..FONT_COLOR_CODE_CLOSE);
			elseif (reward.itemID) then
				local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(reward.itemID);
				if itemName then
					GameTooltip:AddLine(ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE);
				end
			elseif (reward.followerXP) then
				GameTooltip:AddLine(reward.title, 1, 1, 1);
            elseif (reward.currencyID and C_CurrencyInfo.IsCurrencyContainer(reward.currencyID, reward.quantity)) then
                local name, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.currencyID, reward.quantity);
                if name then
					GameTooltip:AddLine(ITEM_QUALITY_COLORS[quality].hex..name..FONT_COLOR_CODE_CLOSE);
				end
			else
				GameTooltip:AddLine(reward.title, 1, 1, 1);
			end
		end
	end

	if (missionInfo.followers ~= nil) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(GarrisonFollowerOptions[missionInfo.followerTypeID].strings.FOLLOWER_NAME);
		for i=1, #(missionInfo.followers) do
			GameTooltip:AddLine(C_Garrison.GetFollowerName(missionInfo.followers[i]), 1, 1, 1);
		end
	end
end

function GarrisonMissionPageFollowerFrame_OnMouseUp(self, button)
	local mainFrame = self:GetParent():GetParent():GetParent();
	mainFrame:OnMouseUpMissionFollower(self, button);
end


---------------------------------------------------------------------------------
--- Mission Page                                                              ---
---------------------------------------------------------------------------------

function GarrisonMissionPage_OnLoad(self)
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
	if (self.BuffsFrame and self.FollowerModel) then
		self.BuffsFrame:SetFrameLevel(self.FollowerModel:GetFrameLevel() + 1);
	end
	self:RegisterForClicks("RightButtonUp");
end

function GarrisonMissionPage_OnEvent(self, event, ...)
	local mainFrame = self:GetParent():GetParent();
	if ( event == "GARRISON_FOLLOWER_LIST_UPDATE" or event == "GARRISON_FOLLOWER_XP_CHANGED" ) then
		local followerTypeID = ...;
		if (followerTypeID == mainFrame.followerTypeID) then
			if ( self.missionInfo ) then
				local mentorLevel, mentorItemLevel = C_Garrison.GetPartyMentorLevels(self.missionInfo.missionID);
				self.mentorLevel = mentorLevel;
				self.mentorItemLevel = mentorItemLevel;
				mainFrame:GetFollowerBuffsForMission(self.missionInfo.missionID);
				self.missionEffects = select(6, C_Garrison.GetPartyMissionInfo(self.missionInfo.missionID));
			else
				self.mentorLevel = nil;
				self.mentorItemLevel = nil;
				self.missionEffects = nil;
			end
			mainFrame:UpdateMissionParty(self.Followers);

			if ( self.missionInfo ) then
				local missionID = self.missionInfo.missionID;
				mainFrame.FollowerList:UpdateFollowers();
				mainFrame:UpdateMissionData(self);
				if (self.followers and self.Enemies) then
					self:SetCounters(self.Followers, self.Enemies, self.missionInfo.missionID);
				end
				return;
			end
		end
	end
	mainFrame:UpdateStartButton(self);
end

function GarrisonMissionPage_OnShow(self)
	local mainFrame = self:GetParent():GetParent();
	self:SetFollowerListSortFuncsForMission();
	mainFrame.FollowerList.showUncollected = false;
	mainFrame.FollowerList.showCounters = true;
	mainFrame.FollowerList.canExpand = true;
	mainFrame.FollowerList:Show();
	mainFrame:UpdateStartButton(self);
end

function GarrisonMissionPage_OnHide(self)
	local mainFrame = self:GetParent():GetParent();
	mainFrame.FollowerList.showCounters = false;
	mainFrame.FollowerList.canExpand = false;
	mainFrame.FollowerList.showUncollected = true;
	mainFrame.FollowerList:SetSortFuncs(GarrisonGarrisonFollowerList_DefaultSort, GarrisonFollowerList_InitializeDefaultSort);

	self.lastUpdate = nil;
end

function GarrisonMissionPage_OnUpdate(self)
	if ( self.missionInfo.offerEndTime and self.missionInfo.offerEndTime <= GetTime() ) then
		-- mission expired
		GarrisonMissionFrame_ClearMouse();
		self.CloseButton:Click();
	end
end

function GarrisonMissionPage_OnClick(self, button)
	if button == "RightButton" then
		GarrisonMissionFrame_ClearMouse();
		self.CloseButton:Click();
	end
end

function GarrisonMissionPageEnvironment_OnEnter(self)
	local missionPage = self:GetParent():GetParent();
	local missionDeploymentInfo = C_Garrison.GetMissionDeploymentInfo(missionPage.missionInfo.missionID);
	if ( missionDeploymentInfo.environment ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(missionDeploymentInfo.environment);
		GameTooltip:AddLine(missionDeploymentInfo.environmentDesc, 1, 1, 1, 1);

		if ( C_Garrison.IsEnvironmentCountered(missionPage.missionInfo.missionID) ) then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddInstructionLine(GameTooltip, GARRISON_MISSION_ENVIRONMENT_COUNTERED, 1);
		end

		GameTooltip:Show();
	end
end

GarrisonFollowerMissionPageMixin = { }

function GarrisonFollowerMissionPageMixin:SetCounters(followers, enemies, missionID)
	GarrisonMissionPageMixin.SetCounters(self, followers, enemies, missionID);
end

function GarrisonFollowerMissionPageMixin:SetFollowerListSortFuncsForMission()
	local mainFrame = self:GetParent():GetParent();
	mainFrame.FollowerList:SetSortFuncs(GarrisonFollowerOptions[mainFrame.followerTypeID].missionFollowerSortFunc, GarrisonFollowerOptions[mainFrame.followerTypeID].missionFollowerInitSortFunc);
end

function GarrisonFollowerMissionPageMixin:UpdateFollowerModel(info)
	if ( self.missionInfo.numFollowers == 1 ) then
		local model = self.FollowerModel;
		model:Show();
		model:SetTargetDistance(0);
		-- TODO: Support a ModelCluster here; this follower could have multiple models (like Rexxar)
		local displayInfo = info.displayIDs and info.displayIDs[1];
		GarrisonMission_SetFollowerModel(model, info.followerID, displayInfo and displayInfo.id, displayInfo and displayInfo.showWeapon);
		model:SetHeightFactor(info.height or 1);
		model:InitializeCamera((info.scale or 1) * (displayInfo and displayInfo.followerPageScale or 1));
		model:SetFacing(-.2);
		self.EmptyFollowerModel:Hide();
	end
end

function GarrisonFollowerMissionPageMixin:UpdateEmptyString()
	if ( C_Garrison.GetNumFollowersOnMission(self.missionInfo.missionID) == 0 ) then
		self.EmptyString:Show();
	else
		self.EmptyString:Hide();
	end
end

function GarrisonFollowerMissionPageMixin:GetFollowerFrameFromID(followerID)
	for i = 1, #self.Followers do
		local followerFrame = self.Followers[i];
		if (followerFrame.info and followerFrame.info.followerID == followerID) then
			return followerFrame;
		end
	end
	return nil;
end

function GarrisonFollowerMissionPageMixin:UpdatePortraitPulse()
	-- only pulse the first available slot
	local pulsed = false;
	for i = 1, #self.Followers do
		local followerFrame = self.Followers[i];
		if ( followerFrame.info ) then
			followerFrame.PortraitFrame.PulseAnim:Stop();

			if ( C_Garrison.CanSpellTargetFollowerIDWithAddAbility(followerFrame.info.followerID) ) then
				followerFrame.PortraitFrame.SpellTargetHighlight:Show();
			else
				followerFrame.PortraitFrame.SpellTargetHighlight:Hide();
			end
		else
			followerFrame.PortraitFrame.SpellTargetHighlight:Hide();

			if ( pulsed ) then
				followerFrame.PortraitFrame.PulseAnim:Stop();
			else
				followerFrame.PortraitFrame.PulseAnim:Play();
				pulsed = true;
			end
		end
	end
end

function GarrisonFollowerMissionPageMixin:AddFollower(followerID)
	local missionFrame = self:GetParent():GetParent();
	for i = 1, #self.Followers do
		local followerFrame = self.Followers[i];
		if ( not followerFrame.info ) then
			local followerInfo = C_Garrison.GetFollowerInfo(followerID);
			missionFrame:AssignFollowerToMission(followerFrame, followerInfo);
			break;
		end
	end
end

function GarrisonFollowerMissionPageMixin:CalculateDurabilityLoss(missionEffects, followerInfo)
	local finalDurability = max(0, followerInfo.durability - 1);
	if (missionEffects.hasKillTroopsEffect) then
		finalDurability = 0;
	end

	return followerInfo.durability - finalDurability;
end


function GarrisonFollowerMissionPageMixin:UpdateFollowerDurability(followerFrame)
	if followerFrame.Durability then
		if (followerFrame.info and followerFrame.info.isTroop) then
			followerFrame.DurabilityBackground:Show();
			followerFrame.Durability:Show();
			followerFrame.Durability:SetDurability(followerFrame.info.durability, followerFrame.info.maxDurability, self:CalculateDurabilityLoss(self.missionEffects, followerFrame.info));
		else
			followerFrame.DurabilityBackground:Hide();
			followerFrame.Durability:Hide();
		end
	end
end

---------------------------------------------------------------------------------
--- Mission Page: Placing Followers/Starting Mission                          ---
---------------------------------------------------------------------------------
function GarrisonMissionPageFollowerFrame_OnDragStart(self)
	local mainFrame = self:GetParent():GetParent():GetParent();
	mainFrame:OnDragStartMissionFollower(mainFrame:GetPlacerFrame(), self, 24);
end

function GarrisonMissionPageFollowerFrame_OnDragStop(self)
	local mainFrame = self:GetParent():GetParent():GetParent();
	mainFrame:OnDragStopMissionFollower(mainFrame:GetPlacerFrame());
end

function GarrisonMissionPageFollowerFrame_OnReceiveDrag(self)
	local mainFrame = self:GetParent():GetParent():GetParent();
	mainFrame:OnReceiveDragMissionFollower(mainFrame:GetPlacerFrame(), self);
end

function GarrisonMissionPageFollowerFrame_OnEnter(self)
	local missionPage = self:GetParent();
	if not self.info then
		return;
	end

	local followerBias = missionPage.missionInfo and (C_Garrison.GetFollowerBiasForMission(missionPage.missionInfo.missionID, self.info.followerID) < 0.0) or nil;
	local underBiasReason = missionPage.missionInfo and C_Garrison.GetFollowerUnderBiasReason(missionPage.missionInfo.missionID, self.info.followerID) or nil;

	GarrisonFollowerTooltip:ClearAllPoints();
	GarrisonFollowerTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT");
	GarrisonFollowerTooltip_Show(self.info.garrFollowerID,
		self.info.isCollected,
		C_Garrison.GetFollowerQuality(self.info.followerID),
		C_Garrison.GetFollowerLevel(self.info.followerID),
		C_Garrison.GetFollowerXP(self.info.followerID),
		C_Garrison.GetFollowerLevelXP(self.info.followerID),
		C_Garrison.GetFollowerItemLevelAverage(self.info.followerID),
		C_Garrison.GetFollowerSpecializationAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 4),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 4),
		true,
		followerBias,
		underBiasReason
		);
end

function GarrisonMissionPageFollowerFrame_OnLeave(self)
	GarrisonFollowerTooltip:Hide();
end


---------------------------------------------------------------------------------
--- Garrison Follower Mission Complete Mixin Functions                        ---
---------------------------------------------------------------------------------

GarrisonFollowerMissionComplete = {};

function GarrisonFollowerMissionComplete:AnimLine(entry)
	self:SetEncounterModels(self.encounterIndex);
	entry.duration = 0.5;

	local encountersFrame = self.Stage.EncountersFrame;
	local mechanicsFrame = self.Stage.EncountersFrame.MechanicsFrame;
	local numMechs, playCounteredSound = self:ShowEncounterMechanics(encountersFrame, mechanicsFrame, self.encounterIndex);
	if ( playCounteredSound ) then
		PlaySound(SOUNDKIT.UI_GARRISON_MISSION_THREAT_COUNTERED);
	end
	mechanicsFrame:SetParent(encountersFrame.Encounters[self.encounterIndex]);
	mechanicsFrame:SetPoint("BOTTOM", encountersFrame.Encounters[self.encounterIndex], (numMechs - 1) * -16, -5);
	encountersFrame.Encounters[self.encounterIndex].CheckFrame:SetFrameLevel(mechanicsFrame:GetFrameLevel() + 1);
	encountersFrame.Encounters[self.encounterIndex].Name:Show();
	encountersFrame.Encounters[self.encounterIndex].GlowFrame.OnAnim:Play();
	if ( self.encounterIndex > 1 ) then
		encountersFrame.Encounters[self.encounterIndex - 1].Name:Hide();
		encountersFrame.Encounters[self.encounterIndex - 1].GlowFrame.OffAnim:Play();
	end
end

function GarrisonFollowerMissionComplete:AnimModels(entry)
	self.Stage.ModelRight:SetFacingLeft(true);
	local currentAnim = self.animInfo[self.encounterIndex];
	GarrisonMissionComplete.AnimModels(self, entry, LE_PAN_NONE_RANGED, currentAnim.movementType or LE_PAN_NONE);
end

function GarrisonFollowerMissionComplete:AnimPortrait(entry)
	local encounter = self.Stage.EncountersFrame.Encounters[self.encounterIndex];
	if ( self.currentMission.succeeded ) then
		encounter.CheckFrame.SuccessAnim:Play();
	else
		if ( self.currentMission.failedEncounter == self.encounterIndex ) then
			encounter.CheckFrame.FailureAnim:Play();
			PlaySound(SOUNDKIT.UI_GARRISON_MISSION_COMPLETE_ENCOUNTER_FAIL);
		else
			encounter.CheckFrame.SuccessAnim:Play();
			PlaySound(SOUNDKIT.UI_GARRISON_MISSION_COMPLETE_MISSION_SUCCESS);
		end
	end
	entry.duration = 0.5;
end

function GarrisonFollowerMissionComplete:AnimCheckEncounters(entry)
	self.encounterIndex = self.encounterIndex + 1;
	if ( self.animInfo[self.encounterIndex] and (not self.currentMission.failedEncounter or self.encounterIndex <= self.currentMission.failedEncounter) ) then
		-- restart for new encounter
		self.animIndex = 0;
		entry.duration = 0.25;
	else
		self.Stage.EncountersFrame.FadeOut:Play();	-- has OnFinished to hide
		entry.duration = 0;
	end
end

function GarrisonFollowerMissionComplete:SetNumFollowers(size)
	local followersFrame = self.Stage.FollowersFrame;
	followersFrame:Show();
	if (size == 1) then
		followersFrame.Follower2:Hide();
		followersFrame.Follower3:Hide();
		followersFrame.Follower1:SetPoint("LEFT", followersFrame, "BOTTOMLEFT", 200, -4);
	elseif (size == 2) then
		followersFrame.Follower2:Show();
		followersFrame.Follower3:Hide();
		followersFrame.Follower1:SetPoint("LEFT", followersFrame, "BOTTOMLEFT", 75, -4);
		followersFrame.Follower2:SetPoint("LEFT", followersFrame.Follower1, "RIGHT", 75, 0);
	else
		followersFrame.Follower2:Show();
		followersFrame.Follower3:Show();
		followersFrame.Follower1:SetPoint("LEFT", followersFrame, "BOTTOMLEFT", 25, -4);
		followersFrame.Follower2:SetPoint("LEFT", followersFrame.Follower1, "RIGHT", 0, 0);
	end
end

function GarrisonFollowerMissionComplete:AnimFollowersIn(entry, hideExhuastedTroopModels)
	local mission = self.completeMissions[self.currentIndex];

	local numFollowers = #self.Stage.followers;
	self:SetNumFollowers(numFollowers);
	self:SetupEnding(numFollowers, hideExhuastedTroopModels);
	local stage = self.Stage;

	for _, cluster in ipairs(stage.ModelCluster) do
		if (cluster:IsShown()) then
			for _, model in ipairs(cluster.Model) do
				if ( self.skipAnimations ) then
					model:SetAlpha(1);
				else
					model.FadeIn:Play();		-- no OnFinished
				end
			end
		end
	end
	for i = 1, numFollowers do
		local followerFrame = stage.FollowersFrame.Followers[i];
		followerFrame.XPGain:SetAlpha(0);
		followerFrame.LevelUpFrame:Hide();
	end
	stage.FollowersFrame.FadeIn:Stop();
	if ( self.skipAnimations ) then
		stage.FollowersFrame:SetAlpha(1);
	else
		stage.FollowersFrame.FadeIn:Play();
	end
	-- preload next set
	local nextIndex = self.currentIndex + 1;
	if ( self.completeMissions[nextIndex] ) then
		MissionCompletePreload_LoadMission(self:GetParent(), self.completeMissions[nextIndex].missionID,
		GarrisonFollowerOptions[self:GetParent().followerTypeID].showSingleMissionCompleteFollower,
		GarrisonFollowerOptions[self:GetParent().followerTypeID].showSingleMissionCompleteAnimation);
	end

	if ( entry ) then
		if ( self.skipAnimations ) then
			entry.duration = 0;
		else
			entry.duration = 0.5;
		end
	end
end

-- if duration is nil it will be set in the onStart function
-- duration is irrelevant for the last entry
-- WARNING: If you're going to alter this, make sure OnSkipKeyPressed still works
local ANIMATION_CONTROL = {
	[Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower] = {
		[1] = { duration = nil,		onStartFunc = GarrisonFollowerMissionComplete.AnimLine },			-- line between encounters
		[2] = { duration = nil,		onStartFunc = GarrisonMissionComplete.AnimCheckModels },			-- check that models are loaded
		[3] = { duration = nil,		onStartFunc = GarrisonFollowerMissionComplete.AnimModels },					-- model fight
		[4] = { duration = nil,		onStartFunc = GarrisonMissionComplete.AnimPlayImpactSound },		-- impact sound when follower hits
		[5] = { duration = 0.45,	onStartFunc = GarrisonFollowerMissionComplete.AnimPortrait },		-- X over portrait
		[6] = { duration = nil,		onStartFunc = GarrisonFollowerMissionComplete.AnimCheckEncounters },		-- evaluate whether to do next encounter or move on
		[7] = { duration = 0.75,	onStartFunc = GarrisonMissionComplete.AnimRewards },				-- reward panel
		[8] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimLockBurst },				-- explode the lock if mission successful
		[9] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimCleanUp },				-- clean up any model anims
		[10] = { duration = nil,	onStartFunc = GarrisonFollowerMissionComplete.AnimFollowersIn },	-- show all the mission followers
		[11] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimXP },						-- follower xp
		[12] = { duration = nil,	onStartFunc = GarrisonMissionComplete.AnimSkipWait },				-- wait if we're in skip mode
		[13] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimSkipNext },				-- click Next button if we're in skip mode
	},
	[Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower] = {
		[1] = { duration = nil,		onStartFunc = GarrisonFollowerMissionComplete.AnimLine },			-- line between encounters
		[2] = { duration = nil,		onStartFunc = GarrisonMissionComplete.AnimCheckModels },			-- check that models are loaded
		[3] = { duration = nil,		onStartFunc = GarrisonFollowerMissionComplete.AnimModels },					-- model fight
		[4] = { duration = nil,		onStartFunc = GarrisonMissionComplete.AnimPlayImpactSound },		-- impact sound when follower hits
		[5] = { duration = 0.45,	onStartFunc = GarrisonFollowerMissionComplete.AnimPortrait },		-- X over portrait
		[6] = { duration = nil,		onStartFunc = GarrisonFollowerMissionComplete.AnimCheckEncounters },		-- evaluate whether to do next encounter or move on
		[7] = { duration = 0.75,	onStartFunc = GarrisonMissionComplete.AnimRewards },				-- reward panel
		[8] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimLockBurst },				-- explode the lock if mission successful
		[9] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimCleanUp },				-- clean up any model anims
		[10] = { duration = nil,	onStartFunc = GarrisonFollowerMissionComplete.AnimFollowersIn },	-- show all the mission followers
		[11] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimXP },						-- follower xp
		[12] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimCheerAndTroopDeath },		-- champions cheer and exhausted troops fade out
		[13] = { duration = nil,	onStartFunc = GarrisonMissionComplete.AnimSkipWait },				-- wait if we're in skip mode
		[14] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimSkipNext },				-- click Next button if we're in skip mode
	}
};
ANIMATION_CONTROL[Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower] = ANIMATION_CONTROL[Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower];

function GarrisonFollowerMissionComplete:SetAnimationControl()
	self.animationControl = ANIMATION_CONTROL[self:GetParent().followerTypeID];
end

function GarrisonFollowerMissionComplete:BeginAnims(animIndex)
	GarrisonMissionComplete.BeginAnims(self, animIndex);
	self.encounterIndex = 1;
end

function GarrisonFollowerMissionComplete:SetFollowerData(follower, name, className, classAtlas, portraitIconID)
	follower.PortraitFrame:SetPortraitIcon(portraitIconID);
	follower.Name:SetText(name);
	follower.Class:SetAtlas(classAtlas);
end

function GarrisonFollowerMissionComplete:SetFollowerLevel(followerFrame, followerInfo)
	local maxLevel = self:GetParent().followerMaxLevel;
	local level = min(followerInfo.level, maxLevel);
	if ( followerInfo.isTroop ) then
		followerFrame.XP:Hide();
		followerFrame.DurabilityFrame:Show();
		followerFrame.DurabilityBackground:Show();
		followerFrame.DurabilityFrame:SetDurability(followerInfo.durability, followerInfo.maxDurability);
		followerFrame.Name:ClearAllPoints();
		followerFrame.Name:SetPoint("LEFT", 58, 6);
	elseif ( followerInfo.levelXP and followerInfo.levelXP > 0 ) then
		followerFrame.XP:SetMinMaxValues(0, followerInfo.levelXP);
		followerFrame.XP:SetValue(followerInfo.xp);
		followerFrame.XP:Show();
		followerFrame.DurabilityFrame:Hide();
		followerFrame.DurabilityBackground:Hide();
		followerFrame.Name:ClearAllPoints();
		followerFrame.Name:SetPoint("LEFT", 58, 6);
	else
		followerFrame.XP:Hide();
		followerFrame.DurabilityFrame:Hide();
		followerFrame.DurabilityBackground:Hide();
		followerFrame.Name:ClearAllPoints();
		followerFrame.Name:SetPoint("LEFT", 58, 0);
	end
	followerFrame.XP.level = level;
	followerFrame.XP.quality = followerInfo.quality;
	followerFrame.PortraitFrame:SetupPortrait(followerInfo);
end

function GarrisonFollowerMissionComplete:DetermineFailedEncounter(missionID, succeeded)
	if ( succeeded ) then
		self.currentMission.failedEncounter = nil;
	else
		-- pick an encounter to fail
		local uncounteredMechanics = self.Stage.EncountersFrame.uncounteredMechanics;
		local failedEncounters = { };
		for i = 1, #uncounteredMechanics do
			if ( #uncounteredMechanics[i] > 0 ) then
				tinsert(failedEncounters, i);
			end
		end
		-- It's possible that there are no encounters with uncountered mechanics on a failed mission because of lower-level followers
		if ( #failedEncounters > 0 ) then
			local rnd = random(1, #failedEncounters);
			self.currentMission.failedEncounter = failedEncounters[rnd];
		elseif ( #self.animInfo > 0 ) then
			self.currentMission.failedEncounter = random(1, #self.animInfo);
		else
			self.currentMission.failedEncounter = 1;
		end
	end
end

function GarrisonFollowerMissionComplete:ClearFollowerData()

end

---------------------------------------------------------------------------------
--- Global Portrait Setting                                                       ---
---------------------------------------------------------------------------------

function GarrisonPortrait_Set(portrait, portraitFileDataID)
	if (portraitFileDataID == nil or portraitFileDataID == 0) then
		-- unknown icon file ID; use the default silhouette portrait
		portrait:SetTexture("Interface\\Garrison\\Portraits\\FollowerPortrait_NoPortrait");
	else
		portrait:SetTexture(portraitFileDataID);
	end
end
