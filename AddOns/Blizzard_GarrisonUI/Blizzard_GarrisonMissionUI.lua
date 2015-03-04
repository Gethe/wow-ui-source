GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH = 205;
GARRISON_FOLLOWER_MAX_LEVEL = 100;
GARRISON_MISSION_COMPLETE_BANNER_WIDTH = 300;
GARRISON_MODEL_PRELOAD_TIME = 20;
GARRISON_LONG_MISSION_TIME = 8 * 60 * 60;	-- 8 hours
GARRISON_LONG_MISSION_TIME_FORMAT = "|cffff7d1a%s|r";

local MISSION_PAGE_FRAME;	-- set in GarrisonMissionFrame_OnLoad

StaticPopupDialogs["DEACTIVATE_FOLLOWER"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		C_Garrison.SetFollowerInactive(self.data, true);
	end,
	OnShow = function(self)
		local quality = C_Garrison.GetFollowerQuality(self.data);
		local name = ITEM_QUALITY_COLORS[quality].hex..C_Garrison.GetFollowerName(self.data)..FONT_COLOR_CODE_CLOSE;
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
		local name = ITEM_QUALITY_COLORS[quality].hex..C_Garrison.GetFollowerName(self.data)..FONT_COLOR_CODE_CLOSE;
		local uses = C_Garrison.GetNumFollowerActivationsRemaining();
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
	[1] = { text1 = GARRISON_MISSION_TUTORIAL1, xOffset = 240, yOffset = -150, parent = "MissionList" },
	[2] = { text1 = GARRISON_MISSION_TUTORIAL2, xOffset = 752, yOffset = -150, parent = "MissionList" },
	[3] = { text1 = GARRISON_MISSION_TUTORIAL3, specialAnchor = "threat", xOffset = 0, yOffset = -16, parent = "MissionPage" },
	[4] = { text1 = GARRISON_MISSION_TUTORIAL4, xOffset = 194, yOffset = -104, parent = "MissionPage" },
	[5] = { text1 = GARRISON_MISSION_TUTORIAL5, specialAnchor = "follower", xOffset = 0, yOffset = -20, parent = "MissionPage" },
	[6] = { text1 = GARRISON_MISSION_TUTORIAL6, specialAnchor = "threat", xOffset = 0, yOffset = -16, parent = "MissionPage" },
	[7] = { text1 = GARRISON_MISSION_TUTORIAL7, xOffset = 368, yOffset = -304, downArrow = true, parent = "MissionPage" },
	[8] = { text1 = GARRISON_MISSION_TUTORIAL9, xOffset = 536, yOffset = -474, downArrow = true, parent = "MissionPage" },	
}

function GarrisonMissionFrame_CheckTutorials(advance)
	local lastTutorial = tonumber(GetCVar("lastGarrisonMissionTutorial"));
	if ( lastTutorial ) then
		if ( advance ) then
			lastTutorial = lastTutorial + 1;
			SetCVar("lastGarrisonMissionTutorial", lastTutorial);
		end
		local tutorialFrame = GarrisonMissionTutorialFrame;
		if ( lastTutorial >= #tutorials ) then
			tutorialFrame:Hide();
		else
			local tutorial = tutorials[lastTutorial + 1];
			-- parent frame
			tutorialFrame:SetParent(GarrisonMissionFrame.MissionTab[tutorial.parent]);
			tutorialFrame:SetFrameStrata("DIALOG");
			tutorialFrame:SetPoint("TOPLEFT", GarrisonMissionFrame, 0, -21);
			tutorialFrame:SetPoint("BOTTOMRIGHT", GarrisonMissionFrame);

			local height = 58;	-- button height + top and bottom padding + spacing between text and button
			local glowBox = tutorialFrame.GlowBox;
			glowBox.BigText:SetText(tutorial.text1);
			height = height + glowBox.BigText:GetHeight();
			if ( tutorial.text2 ) then
				glowBox.SmallText:SetText(tutorial.text2);
				height = height + 12 + glowBox.SmallText:GetHeight();
				glowBox.SmallText:Show();
			else
				glowBox.SmallText:Hide();
			end
			glowBox:SetHeight(height);
			glowBox:ClearAllPoints();
			if ( tutorial.specialAnchor == "threat" ) then
				glowBox:SetPoint("TOP", MISSION_PAGE_FRAME.Enemy1.Mechanics[1], "BOTTOM", tutorial.xOffset, tutorial.yOffset);
			elseif ( tutorial.specialAnchor == "follower" ) then
				local followerFrame = MISSION_PAGE_FRAME.Follower1;
				glowBox:SetPoint("TOP", followerFrame.PortraitFrame, "BOTTOM", tutorial.xOffset, tutorial.yOffset);
			else
				glowBox:SetPoint("TOPLEFT", tutorial.xOffset, tutorial.yOffset);
			end
			if ( tutorial.downArrow ) then
				glowBox.ArrowUp:Hide();
				glowBox.ArrowGlowUp:Hide();
				glowBox.ArrowDown:Show();
				glowBox.ArrowGlowDown:Show();
			else
				glowBox.ArrowUp:Show();
				glowBox.ArrowGlowUp:Show();
				glowBox.ArrowDown:Hide();
				glowBox.ArrowGlowDown:Hide();
			end
			tutorialFrame:Show();
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

function GarrisonMissionFrame_OnLoad(self)
	MISSION_PAGE_FRAME = GarrisonMissionFrame.MissionTab.MissionPage;

	PanelTemplates_SetNumTabs(self, 2);
	self.selectedTab = 1;
	PanelTemplates_UpdateTabs(self);
	self.TitleText:SetText(GARRISON_MISSIONS_TITLE);
	self.FollowerTab.ItemWeapon.Name:SetText(WEAPON);
	self.FollowerTab.ItemArmor.Name:SetText(ARMOR);

	GarrisonFollowerList_OnLoad(self)

	GarrisonMissionFrame_UpdateCurrency();
	
	self.MissionTab.MissionList.listScroll.update = GarrisonMissionList_Update;
	HybridScrollFrame_CreateButtons(self.MissionTab.MissionList.listScroll, "GarrisonMissionListButtonTemplate", 13, -8, nil, nil, nil, -4);
	GarrisonMissionList_Update();
	
	GarrisonMissionList_SetTab(self.MissionTab.MissionList.Tab1);
	
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup == "Horde" ) then
		GarrisonMissionFrame.MissionTab.MissionPage.RewardsFrame.Chest:SetAtlas("GarrMission-HordeChest");
		MISSION_PAGE_FRAME.EmptyFollowerModel.Texture:SetAtlas("GarrMission_Silhouettes-1Horde");
		GarrisonMissionFrame.MissionComplete.BonusRewards.ChestModel:SetDisplayInfo(54913);
		local dialogBorderFrame = GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog.BorderFrame;
		dialogBorderFrame.Model:SetDisplayInfo(59175);
		dialogBorderFrame.Model:SetPosition(0.2, 1.15, -0.7);
		dialogBorderFrame.Stage.LocBack:SetAtlas("_GarrMissionLocation-FrostfireRidge-Back", true);
		dialogBorderFrame.Stage.LocMid:SetAtlas ("_GarrMissionLocation-FrostfireRidge-Mid", true);
		dialogBorderFrame.Stage.LocFore:SetAtlas("_GarrMissionLocation-FrostfireRidge-Fore", true);
		dialogBorderFrame.Stage.LocBack:SetTexCoord(0, 0.485, 0, 1);
		dialogBorderFrame.Stage.LocMid:SetTexCoord(0, 0.485, 0, 1);
		dialogBorderFrame.Stage.LocFore:SetTexCoord(0, 0.485, 0, 1);
	else
		local dialogBorderFrame = GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog.BorderFrame;
		dialogBorderFrame.Model:SetDisplayInfo(58063);
		dialogBorderFrame.Model:SetPosition(0.2, .75, -0.7);
		dialogBorderFrame.Stage.LocBack:SetAtlas("_GarrMissionLocation-ShadowmoonValley-Back", true);
		dialogBorderFrame.Stage.LocMid:SetAtlas ("_GarrMissionLocation-ShadowmoonValley-Mid", true);
		dialogBorderFrame.Stage.LocFore:SetAtlas("_GarrMissionLocation-ShadowmoonValley-Fore", true);
		dialogBorderFrame.Stage.LocBack:SetTexCoord(0.2, 0.685, 0, 1);
		dialogBorderFrame.Stage.LocMid:SetTexCoord(0.2, 0.685, 0, 1);
		dialogBorderFrame.Stage.LocFore:SetTexCoord(0.2, 0.685, 0, 1);
	end

	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GARRISON_MISSION_STARTED");
	self:RegisterEvent("GARRISON_MISSION_FINISHED");
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	self:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED");


	self.followerXPTable = C_Garrison.GetFollowerXPTable();
	local maxLevel = 0;
	for level in pairs(self.followerXPTable) do
		maxLevel = max(maxLevel, level);
	end
	self.followerMaxLevel = maxLevel;

	self.followerQualityTable = C_Garrison.GetFollowerQualityTable();
	local maxQuality = 0;
	for quality, xp in pairs(self.followerQualityTable) do
		maxQuality = max(maxQuality, quality);
	end
	self.followerMaxQuality = maxQuality;
end

function GarrisonMissionFrame_OnEvent(self, event, ...)
	if (event == "GARRISON_MISSION_LIST_UPDATE") then
		GarrisonMissionList_UpdateMissions();
	elseif (event == "GARRISON_FOLLOWER_LIST_UPDATE" or event == "GARRISON_FOLLOWER_XP_CHANGED" or event == "GARRISON_FOLLOWER_REMOVED") then
		-- follower could have leveled at mission page, need to recheck counters
		if ( event == "GARRISON_FOLLOWER_XP_CHANGED" and MISSION_PAGE_FRAME:IsShown() and MISSION_PAGE_FRAME.missionInfo ) then
			GarrisonMissionFrame.followerCounters = C_Garrison.GetBuffedFollowersForMission(MISSION_PAGE_FRAME.missionInfo.missionID);
			GarrisonMissionFrame.followerTraits = C_Garrison.GetFollowersTraitsForMission(MISSION_PAGE_FRAME.missionInfo.missionID);	
		end
		GarrisonFollowerList_OnEvent(self, event, ...);
	elseif (event == "CURRENCY_DISPLAY_UPDATE") then
		GarrisonMissionFrame_UpdateCurrency();
	elseif (event == "GARRISON_MISSION_STARTED") then
		local anim = GarrisonMissionFrame.MissionTab.MissionList.Tab2.MissionStartAnim;
		if (anim:IsPlaying()) then
			anim:Stop();
		end
		anim:Play();
	elseif (event == "GARRISON_MISSION_FINISHED") then
		GarrisonMissionFrame_CheckCompleteMissions();
	elseif ( event == "GET_ITEM_INFO_RECEIVED" ) then
		GarrisonMissionFrame_UpdateRewards(self, ...);
	elseif ( event == "GARRISON_FOLLOWER_UPGRADED" ) then
		GarrisonFollowerList_OnEvent(self, event, ...);
	elseif ( event == "GARRISON_RANDOM_MISSION_ADDED" ) then
		GarrisonMissionFrame_RandomMissionAdded(self, ...);
	end
end

function GarrisonMissionFrame_OnShow(self)
	GarrisonMissionFrame_CheckCompleteMissions(true);
	GarrisonThreatCountersFrame:SetParent(self.FollowerTab);
	GarrisonThreatCountersFrame:SetPoint("TOPRIGHT", -12, 30);
	PlaySound("UI_Garrison_CommandTable_Open");
end

function GarrisonMissionFrame_OnHide(self)
	if ( MISSION_PAGE_FRAME.missionInfo ) then
		GarrisonMissionPage_Close();
	end
	GarrisonMissionFrame_ClearMouse();
	C_Garrison.CloseMissionNPC();
	HelpPlate_Hide();
	GarrisonMissionFrame_HideCompleteMissions(true);
	MissionCompletePreload_Cancel();
	PlaySound("UI_Garrison_CommandTable_Close");
	StaticPopup_Hide("DEACTIVATE_FOLLOWER");
	StaticPopup_Hide("ACTIVATE_FOLLOWER");

	GarrisonMissionFrame.MissionTab.MissionList.newMissionIDs = { };
	GarrisonMissionList_Update();
end

function GarrisonMissionFrame_ClearMouse()
	if ( GarrisonFollowerPlacer.info ) then
		GarrisonFollowerPlacer:Hide();
		GarrisonFollowerPlacerFrame:Hide();
		GarrisonFollowerPlacer.info = nil;
		return true;
	end
	return false;
end

function GarrisonMissionFrame_CheckCompleteMissions(onShow)
	local self = GarrisonMissionFrame;
	if ( self.MissionComplete:IsShown() ) then
		return;
	end
	self.MissionComplete.completeMissions = C_Garrison.GetCompleteMissions();
	if ( #self.MissionComplete.completeMissions > 0 ) then
		if ( self:IsShown() ) then
			self.MissionTab.MissionList.CompleteDialog.BorderFrame.Model.Summary:SetFormattedText(GARRISON_NUM_COMPLETED_MISSIONS, #self.MissionComplete.completeMissions);
			self.MissionTab.MissionList.CompleteDialog:Show();
			-- preload models
			MissionCompletePreload_LoadMission(self.MissionComplete.completeMissions[1].missionID);
			self.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton:SetEnabled(true);
			self.MissionTab.MissionList.CompleteDialog.BorderFrame.LoadingFrame:Hide();
			-- go to the right tab if window is being open
			if ( onShow ) then
				GarrisonMissionFrame_SelectTab(1);
			end
			GarrisonMissionList_SetTab(self.MissionTab.MissionList.Tab1);
		end
	end
end

function GarrisonMissionFrame_GetFollowerNextLevelXP(level, quality)
	local self = GarrisonMissionFrame;
	if ( level < self.followerMaxLevel ) then
		return self.followerXPTable[level];
	elseif ( quality < self.followerMaxQuality ) then
		return self.followerQualityTable[quality];
	else
		return nil;
	end	
end

function GarrisonMissionFrameTab_OnClick(self)
	PlaySound("UI_Garrison_Nav_Tabs");
	GarrisonMissionFrame_SelectTab(self:GetID());
end

function GarrisonMissionFrame_SelectTab(id)
	PanelTemplates_SetTab(GarrisonMissionFrame, id);
	if (id == 1) then
		if ( GarrisonMissionFrame.MissionComplete.currentIndex ) then
			GarrisonMissionFrame.MissionComplete:Show();
			GarrisonMissionFrame.MissionCompleteBackground:Show();
			GarrisonMissionFrame.FollowerList:Hide();
		end
		GarrisonMissionFrame.MissionTab:Show();
		GarrisonMissionFrame.FollowerTab:Hide();
		if ( GarrisonMissionFrame.MissionTab.MissionPage:IsShown() ) then
			GarrisonFollowerList_UpdateFollowers(GarrisonMissionFrame.FollowerList);
		end
		GarrisonMissionFrame.TitleText:SetText(GARRISON_MISSIONS_TITLE);
	else
		GarrisonMissionFrame.MissionComplete:Hide();
		GarrisonMissionFrame.MissionCompleteBackground:Hide();
		GarrisonMissionFrame.MissionTab:Hide();
		GarrisonMissionFrame.FollowerTab:Show();
		if ( GarrisonMissionFrame.FollowerList:IsShown() ) then
			GarrisonFollowerList_UpdateFollowers(GarrisonMissionFrame.FollowerList);
		else
			GarrisonMissionFrame.FollowerList:Show();
		end
		GarrisonMissionFrame.TitleText:SetText(GARRISON_FOLLOWERS_TITLE);
	end
	if ( UIDropDownMenu_GetCurrentDropDown() == GarrisonFollowerOptionDropDown ) then
		CloseDropDownMenus();
	end
end

function GarrisonMissionFrame_UpdateCurrency()
	local currencyName, amount, currencyTexture = GetCurrencyInfo(GARRISON_CURRENCY);
	GarrisonMissionFrame.materialAmount = amount;
	amount = BreakUpLargeNumbers(amount)
	GarrisonMissionFrame.MissionTab.MissionList.MaterialFrame.Materials:SetText(amount);
	GarrisonMissionFrame.FollowerList.MaterialFrame.Materials:SetText(amount);
end

function GarrisonMissionFrame_SetFollowerPortrait(portraitFrame, followerInfo, forMissionPage)
	local color = ITEM_QUALITY_COLORS[followerInfo.quality];
	portraitFrame.PortraitRingQuality:SetVertexColor(color.r, color.g, color.b);
	portraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
	if ( forMissionPage ) then
		local boosted = false;
		local followerLevel = followerInfo.level;
		if ( MISSION_PAGE_FRAME.mentorLevel and MISSION_PAGE_FRAME.mentorLevel > followerLevel ) then
			followerLevel = MISSION_PAGE_FRAME.mentorLevel;
			boosted = true;
		end
		if ( MISSION_PAGE_FRAME.showItemLevel and followerLevel == GarrisonMissionFrame.followerMaxLevel ) then
			local followerItemLevel = followerInfo.iLevel;
			if ( MISSION_PAGE_FRAME.mentorItemLevel and MISSION_PAGE_FRAME.mentorItemLevel > followerItemLevel ) then
				followerItemLevel = MISSION_PAGE_FRAME.mentorItemLevel;
				boosted = true;
			end
			portraitFrame.Level:SetFormattedText(GARRISON_FOLLOWER_ITEM_LEVEL, followerItemLevel);
			portraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_iLvlBorder");
			portraitFrame.LevelBorder:SetWidth(70);
		else
			portraitFrame.Level:SetText(followerLevel);
			portraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_LevelBorder");
			portraitFrame.LevelBorder:SetWidth(58);
		end
		local followerBias = C_Garrison.GetFollowerBiasForMission(MISSION_PAGE_FRAME.missionInfo.missionID, followerInfo.followerID);
		if ( followerBias == -1 ) then
			portraitFrame.Level:SetTextColor(1, 0.1, 0.1);
		elseif ( followerBias < 0 ) then
			portraitFrame.Level:SetTextColor(1, 0.5, 0.25);
		elseif ( boosted ) then
			portraitFrame.Level:SetTextColor(0.1, 1, 0.1);
		else
			portraitFrame.Level:SetTextColor(1, 1, 1);
		end
		portraitFrame.Caution:SetShown(followerBias < 0);
	
	else
		portraitFrame.Level:SetText(followerInfo.level);
	end
	if ( followerInfo.displayID ) then
		GarrisonFollowerPortrait_Set(portraitFrame.Portrait, followerInfo.portraitIconID);
	end
end

function GarrisonMissionFrame_UpdateRewards(self, itemID)
	-- mission list
	local missionButtons = self.MissionTab.MissionList.listScroll.buttons;
	for i = 1, #missionButtons do
		GarrisonMissionFrame_CheckRewardButtons(missionButtons[i].Rewards, itemID);
	end
	-- mission page
	GarrisonMissionFrame_CheckRewardButtons(MISSION_PAGE_FRAME.RewardsFrame.Rewards, itemID);
	-- mission complete
	GarrisonMissionFrame_CheckRewardButtons(self.MissionComplete.BonusRewards.Rewards, itemID);
end

function GarrisonMissionFrame_RandomMissionAdded(self, missionID)
	self.MissionTab.MissionList.newMissionIDs[missionID] = true;
	GarrisonMissionList_Update();
end


function GarrisonMissionFrame_CheckRewardButtons(rewardButtons, itemID)
	for i = 1, #rewardButtons do
		local frame = rewardButtons[i];
		if ( frame.itemID == itemID ) then
			GarrisonMissionFrame_SetItemRewardDetails(frame);
		end
	end
end

function GarrisonMissionFrame_SetItemRewardDetails(frame)
	local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(frame.itemID);
	frame.Icon:SetTexture(itemTexture);
	if (frame.Name and itemName and itemRarity) then
		frame.Name:SetText(ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE);
	end
end

---------------------------------------------------------------------------------
--- Follower Dropdown                                                         ---
---------------------------------------------------------------------------------
function GarrisonFollowerOptionDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;

	local follower = self.followerID and C_Garrison.GetFollowerInfo(self.followerID);
	if ( follower ) then
		if ( MISSION_PAGE_FRAME:IsVisible() and MISSION_PAGE_FRAME.missionInfo ) then
			info.text = GARRISON_MISSION_ADD_FOLLOWER;
			info.func = function()
				GarrisonMissionPage_AddFollower(self.followerID);
			end
			if ( C_Garrison.GetNumFollowersOnMission(MISSION_PAGE_FRAME.missionInfo.missionID) >= MISSION_PAGE_FRAME.missionInfo.numFollowers or C_Garrison.GetFollowerStatus(self.followerID)) then		
				info.disabled = 1;
			end
			UIDropDownMenu_AddButton(info);
		end
		
		local followerStatus = C_Garrison.GetFollowerStatus(self.followerID);
		if ( followerStatus == GARRISON_FOLLOWER_INACTIVE ) then
			info.text = GARRISON_ACTIVATE_FOLLOWER;
			if ( C_Garrison.GetNumFollowerActivationsRemaining() == 0 ) then
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
			if ( followerStatus == GARRISON_FOLLOWER_ON_MISSION ) then
				info.disabled = 1;
				info.tooltipWhileDisabled = 1;
				info.tooltipTitle = GARRISON_DEACTIVATE_FOLLOWER;
				info.tooltipText = GARRISON_FOLLOWER_CANNOT_DEACTIVATE_ON_MISSION;
				info.tooltipOnButton = 1;
			elseif ( not C_Garrison.IsAboveFollowerSoftCap() ) then
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
function GarrisonMissionList_OnLoad(self)
	self.inProgressMissions = {};
	self.availableMissions = {};
	self.newMissionIDs = {};
	
	self.listScroll:SetScript("OnMouseWheel", function(self, ...) HybridScrollFrame_OnMouseWheel(self, ...); GarrisonMissionList_UpdateMouseOverTooltip(self); end);
end

function GarrisonMissionList_OnShow(self)
	GarrisonMissionList_UpdateMissions();
	GarrisonMissionFrame.FollowerList:Hide();
	GarrisonMissionFrame_CheckTutorials();
end

function GarrisonMissionList_OnHide(self)
	self.missions = nil;
	GarrisonFollowerPlacer:SetScript("OnUpdate", nil);
end

function GarrisonMissionListTab_OnClick(self, button)
	PlaySound("UI_Garrison_Nav_Tabs");
	GarrisonMissionList_SetTab(self);
end

function GarrisonMissionList_SetTab(self)
	local list = GarrisonMissionFrame.MissionTab.MissionList;
	if (self:GetID() == 1) then
		list.showInProgress = false;
		GarrisonMissonListTab_SetSelected(list.Tab2, false);
	else
		list.showInProgress = true;
		GarrisonMissonListTab_SetSelected(list.Tab1, false);
	end
	GarrisonMissonListTab_SetSelected(self, true);
	GarrisonMissionList_UpdateMissions();
end

function GarrisonMissonListTab_SetSelected(tab, isSelected)
	tab.SelectedLeft:SetShown(isSelected);
	tab.SelectedRight:SetShown(isSelected);
	tab.SelectedMid:SetShown(isSelected);
end

function GarrisonMissionList_UpdateMissions()
	local self = GarrisonMissionFrame.MissionTab.MissionList;
	C_Garrison.GetInProgressMissions(self.inProgressMissions);
	C_Garrison.GetAvailableMissions(self.availableMissions);
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
	GarrisonMissionList_Update();
end

function GarrisonMissionList_OnUpdate(self)
	if (self.showInProgress) then
		C_Garrison.GetInProgressMissions(self.inProgressMissions);
		self.Tab2:SetText(WINTERGRASP_IN_PROGRESS.." - "..#self.inProgressMissions)
		GarrisonMissionList_Update();
	else
		local timeNow = GetTime();
		for i = 1, #self.availableMissions do
			if ( self.availableMissions[i].offerEndTime and self.availableMissions[i].offerEndTime <= timeNow ) then
				GarrisonMissionList_UpdateMissions();
				break;
			end
		end
	end
end

function GarrisonMissionList_Update()
	local self = GarrisonMissionFrame.MissionTab.MissionList;
	local missions;
	if (self.showInProgress) then
		missions = self.inProgressMissions;
	else
		missions = self.availableMissions;
	end
	local numMissions = #missions;
	local scrollFrame = self.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	if (numMissions == 0) then
		self.EmptyListString:Show();
	else
		self.EmptyListString:Hide();
	end
	
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numMissions) then
			local mission = missions[index];
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
			if ( mission.locPrefix ) then
				button.LocBG:Show();
				button.LocBG:SetAtlas(mission.locPrefix.."-List");
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
			if ( mission.level == GARRISON_FOLLOWER_MAX_LEVEL and mission.iLevel > 0 ) then
				button.ItemLevel:SetFormattedText(NUMBER_IN_PARENTHESES, mission.iLevel);
				button.ItemLevel:Show();
				showingItemLevel = true;
			else
				button.ItemLevel:Hide();
			end
			if ( showingItemLevel and mission.isRare ) then
				button.Level:SetPoint("CENTER", button, "TOPLEFT", 40, -22);
			else
				button.Level:SetPoint("CENTER", button, "TOPLEFT", 40, -36);
			end

			button:Enable();
			if (mission.inProgress) then
				button.Overlay:Show();
				button.Summary:SetText(mission.timeLeft.." "..RED_FONT_COLOR_CODE..GARRISON_MISSION_IN_PROGRESS..FONT_COLOR_CODE_CLOSE);
			else
				button.Overlay:Hide();
			end
			if ( button.Title:GetWidth() + button.Summary:GetWidth() + 8 < 655 - mission.numRewards * 65 ) then
				button.Title:SetPoint("LEFT", 165, 0);
				button.Summary:ClearAllPoints();
				button.Summary:SetPoint("BOTTOMLEFT", button.Title, "BOTTOMRIGHT", 8, 0);
			else
				button.Title:SetPoint("LEFT", 165, 10);
				button.Title:SetWidth(655 - mission.numRewards * 65);
				button.Summary:ClearAllPoints();
				button.Summary:SetPoint("TOPLEFT", button.Title, "BOTTOMLEFT", 0, -4);	
			end			
			button.MissionType:SetAtlas(mission.typeAtlas);
			GarrisonMissionButton_SetRewards(button, mission.rewards, mission.numRewards);
			button:Show();

			local isNewMission = self.newMissionIDs[mission.missionID];
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
		else
			button:Hide();
			button.info = nil;
		end
	end
	
	local totalHeight = numMissions * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function GarrisonMissionList_UpdateMouseOverTooltip(self)
	local buttons = self.buttons;
	for i = 1, #buttons do
		if ( buttons[i]:IsMouseOver() ) then
			GarrisonMissionButton_OnEnter(buttons[i]);
			break;
		end
	end
end

function GarrisonMissionButton_SetRewards(self, rewards, numRewards)
	if (numRewards > 0) then
		local index = 1;
		for id, reward in pairs(rewards) do
			if (not self.Rewards[index]) then
				self.Rewards[index] = CreateFrame("Frame", nil, self, "GarrisonMissionListButtonRewardTemplate");
				self.Rewards[index]:SetPoint("RIGHT", self.Rewards[index-1], "LEFT", 0, 0);
			end
			local Reward = self.Rewards[index];
			Reward.Quantity:Hide();
			Reward.itemID = nil;
			Reward.currencyID = nil;
			Reward.tooltip = nil;
			if (reward.itemID) then
				Reward.itemID = reward.itemID;
				GarrisonMissionFrame_SetItemRewardDetails(Reward);
				if ( reward.quantity > 1 ) then
					Reward.Quantity:SetText(reward.quantity);
					Reward.Quantity:Show();
				end
			else
				Reward.Icon:SetTexture(reward.icon);
				Reward.title = reward.title
				if (reward.currencyID and reward.quantity) then
					if (reward.currencyID == 0) then
						Reward.tooltip = GetMoneyString(reward.quantity);
						Reward.Quantity:SetText(BreakUpLargeNumbers(floor(reward.quantity / COPPER_PER_GOLD)));
						Reward.Quantity:Show();
					else
						Reward.currencyID = reward.currencyID;
						Reward.Quantity:SetText(reward.quantity);
						Reward.Quantity:Show();
					end
				else
					Reward.tooltip = reward.tooltip;
					if ( reward.followerXP ) then
						Reward.Quantity:SetText(BreakUpLargeNumbers(reward.followerXP));
						Reward.Quantity:Show();
					end
				end
			end
			Reward:Show();
			index = index + 1;
		end
	end
	
	for i = (numRewards + 1), #self.Rewards do
		self.Rewards[i]:Hide();
	end
end

function GarrisonMissionButton_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local missionLink = C_Garrison.GetMissionLink(self.info.missionID);
		if (missionLink) then
			ChatEdit_InsertLink(missionLink);
		end
		return;
	end

	-- don't do anything other than create links and handle spell clicks for in progress missions
	if (self.info.inProgress) then
		C_Garrison.CastSpellOnMission(self.info.missionID);
		return;
	end

	GarrisonMissionList_Update();
	PlaySound("UI_Garrison_CommandTable_SelectMission");
	GarrisonMissionFrame.MissionTab.MissionList:Hide();
	GarrisonMissionFrame.MissionTab.MissionPage:Show();
	GarrisonMissionPage_ShowMission(self.info);
	GarrisonMissionFrame.followerCounters = C_Garrison.GetBuffedFollowersForMission(self.info.missionID)
	GarrisonMissionFrame.followerTraits = C_Garrison.GetFollowersTraitsForMission(self.info.missionID);
	GarrisonFollowerList_UpdateFollowers(GarrisonMissionFrame.FollowerList);
end

function GarrisonMissionButton_OnEnter(self, button)
	if (self.info == nil) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");

	if(self.info.inProgress) then
		GarrisonMissionButton_SetInProgressTooltip(self.info);
	else
		GameTooltip:SetText(self.info.name);
		GameTooltip:AddLine(string.format(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, self.info.numFollowers), 1, 1, 1);		
		GarrisonMissionButton_AddThreatsToTooltip(self.info.missionID);
		if (self.info.isRare) then
			GameTooltip:AddLine(GARRISON_MISSION_AVAILABILITY);
			GameTooltip:AddLine(self.info.offerTimeRemaining, 1, 1, 1);
		end
		if not C_Garrison.IsOnGarrisonMap() then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(GARRISON_MISSION_TOOLTIP_RETURN_TO_START, nil, nil, nil, 1);
		end
	end

	GameTooltip:Show();

	GarrisonMissionFrame.MissionTab.MissionList.newMissionIDs[self.info.missionID] = nil;
	GarrisonMissionList_Update();
end

function GarrisonMissionButton_SetInProgressTooltip(missionInfo, showRewards)
	GameTooltip:SetText(missionInfo.name);
	-- level
	if ( missionInfo.level == GARRISON_FOLLOWER_MAX_LEVEL and missionInfo.iLevel > 0 ) then
		GameTooltip:AddLine(format(GARRISON_MISSION_LEVEL_ITEMLEVEL_TOOLTIP, missionInfo.level, missionInfo.iLevel), 1, 1, 1);
	else
		GameTooltip:AddLine(format(GARRISON_MISSION_LEVEL_TOOLTIP, missionInfo.level), 1, 1, 1);
	end
	-- completed?
	if(missionInfo.isComplete) then
		GameTooltip:AddLine(COMPLETE, 1, 1, 1);
	end
	-- success chance
	local successChance = C_Garrison.GetMissionSuccessChance(missionInfo.missionID);
	if ( successChance ) then
		GameTooltip:AddLine(format(GARRISON_MISSION_PERCENT_CHANCE, successChance), 1, 1, 1);
	end

	if ( showRewards ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(REWARDS);
		for id, reward in pairs(missionInfo.rewards) do
			if (reward.quality) then
				GameTooltip:AddLine(ITEM_QUALITY_COLORS[reward.quality + 1].hex..reward.title..FONT_COLOR_CODE_CLOSE);
			elseif (reward.itemID) then 
				local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(reward.itemID);
				if itemName then
					GameTooltip:AddLine(ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE);
				end
			elseif (reward.followerXP) then
				GameTooltip:AddLine(reward.title, 1, 1, 1);
			else
				GameTooltip:AddLine(reward.title, 1, 1, 1);
			end
		end
	end

	if (missionInfo.followers ~= nil) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(GARRISON_FOLLOWERS);
		for i=1, #(missionInfo.followers) do
			GameTooltip:AddLine(C_Garrison.GetFollowerName(missionInfo.followers[i]), 1, 1, 1);
		end
	end
end

function GarrisonMission_DetermineCounterableThreats(missionID)
	local threats = {};
	threats.full = {};
	threats.partial = {};
	threats.away = {};
	threats.worker = {};

	local followerList = C_Garrison.GetFollowers();
	for i = 1, #followerList do
		local follower = followerList[i];
		if ( follower.isCollected and follower.status ~= GARRISON_FOLLOWER_INACTIVE ) then
			local bias = C_Garrison.GetFollowerBiasForMission(missionID, follower.followerID);
			if ( bias > -1.0 ) then
				local abilities = C_Garrison.GetFollowerAbilities(follower.followerID);
				for j = 1, #abilities do
					for counterMechanicID in pairs(abilities[j].counters) do
						if ( follower.status ) then
							if ( follower.status == GARRISON_FOLLOWER_ON_MISSION ) then
								local time = C_Garrison.GetFollowerMissionTimeLeftSeconds(follower.followerID);
								if ( not threats.away[counterMechanicID] ) then
									threats.away[counterMechanicID] = {};
								end
								table.insert(threats.away[counterMechanicID], time);
							elseif ( follower.status == GARRISON_FOLLOWER_WORKING ) then
								threats.worker[counterMechanicID] = (threats.worker[counterMechanicID] or 0) + 1;
							end
						else
							local isFullCounter = C_Garrison.IsMechanicFullyCountered(missionID, follower.followerID, counterMechanicID, abilities[j].id);
							if ( isFullCounter ) then
								threats.full[counterMechanicID] = (threats.full[counterMechanicID] or 0) + 1;
							else
								threats.partial[counterMechanicID] = (threats.partial[counterMechanicID] or 0) + 1;
							end
						end
					end
				end
			end
		end
	end

	for counter, times in pairs(threats.away) do
		table.sort(times);
	end
	return threats;
end

function GarrisonMissionButton_AddThreatsToTooltip(missionID)
	local location, xp, environment, environmentDesc, _, locPrefix, isExhausting, enemies = C_Garrison.GetMissionInfo(missionID);
	local numThreats = 0;

	-- Make a list of all the threats that we can counter.
	local counterableThreats = GarrisonMission_DetermineCounterableThreats(missionID);

	for i = 1, #enemies do
		local enemy = enemies[i];
		for mechanicID, mechanic in pairs(enemy.mechanics) do
			numThreats = numThreats + 1;
			local threatFrame = GarrisonMissionListTooltipThreatsFrame.Threats[numThreats];
			if ( not threatFrame ) then
				threatFrame = CreateFrame("Frame", nil, GarrisonMissionListTooltipThreatsFrame, "GarrisonAbilityCounterWithCheckTemplate");
				threatFrame:SetPoint("LEFT", GarrisonMissionListTooltipThreatsFrame.Threats[numThreats - 1], "RIGHT", 10, 0);
				tinsert(GarrisonMissionListTooltipThreatsFrame.Threats, threatFrame);
			end
			threatFrame.Icon:SetTexture(mechanic.icon);
			threatFrame:Show();
			GarrisonMissionButton_CheckTooltipThreat(threatFrame, missionID, mechanicID, counterableThreats);
		end
	end

	local hasAway = false;
	local threatSpacing = 30;
	local iconBorder = 10;
	local timeLeftBorder = 3;
	-- calculate the space needed between threats. The time left string may add some space.
	for i = 1, numThreats do
		local threatFrame = GarrisonMissionListTooltipThreatsFrame.Threats[i];
		if ( threatFrame.TimeLeft:IsShown() ) then
			hasAway = true;
			local strWidth = threatFrame.TimeLeft:GetWidth() + timeLeftBorder;
			if (strWidth > threatSpacing) then
				threatSpacing = strWidth;
			end
		end
	end
	-- set uniform spacing for all the threats.
	for i = 1, numThreats do
		local threatFrame = GarrisonMissionListTooltipThreatsFrame.Threats[i];
		threatFrame:SetWidth(threatSpacing - iconBorder);
	end
	local threatsFrameWidth = 24 + threatSpacing * numThreats;
	local threatsFrameHeight = 26; -- minimum height
	-- make space for font string if it's needed.
	if ( hasAway ) then
		threatsFrameHeight = threatsFrameHeight + 10;
	end

	for i = numThreats + 1, #GarrisonMissionListTooltipThreatsFrame.Threats do
		GarrisonMissionListTooltipThreatsFrame.Threats[i]:Hide();
	end
	GarrisonMissionListTooltipThreatsFrame:SetWidth(threatsFrameWidth);
	GarrisonMissionListTooltipThreatsFrame:SetHeight(threatsFrameHeight);
	if ( numThreats > 0 ) then
		local usedHeight = GameTooltip_InsertFrame(GameTooltip, GarrisonMissionListTooltipThreatsFrame);
		GarrisonMissionListTooltipThreatsFrame:SetHeight(usedHeight);
	else
		GarrisonMissionListTooltipThreatsFrame:Hide();
	end
end

function GarrisonMission_GetDurationStringCompact(time)

	local s_minute = 60;
	local s_hour = s_minute * 60;
	local s_day = s_hour * 24;

	local str;
	if (time >= s_day) then
		time = ((time - 1) / s_day) + 1;
		return string.format(COOLDOWN_DURATION_DAYS, time);
	elseif (time >= s_hour) then
		time = ((time - 1) / s_hour) + 1;
		return string.format(COOLDOWN_DURATION_HOURS, time);
	else
		time = ((time - 1) / s_minute) + 1;
		return string.format(COOLDOWN_DURATION_MIN, time);
	end
end

function GarrisonMissionButton_CheckTooltipThreat(threatFrame, missionID, mechanicID, counterableThreats)
	threatFrame.Check:Hide();
	threatFrame.Away:Hide();
	threatFrame.Working:Hide();
	threatFrame.TimeLeft:Hide();

	-- We remove threat counters from counterableThreats as they are used.

	if ( counterableThreats.full[mechanicID] and counterableThreats.full[mechanicID] > 0 ) then
		counterableThreats.full[mechanicID] = counterableThreats.full[mechanicID] - 1;
		threatFrame.Check:SetAtlas("GarrMission_CounterCheck", true);
		threatFrame.Check:Show();
		return;
	end

	if ( counterableThreats.partial[mechanicID] and counterableThreats.partial[mechanicID] > 0 ) then
		counterableThreats.partial[mechanicID] = counterableThreats.partial[mechanicID] - 1;
		threatFrame.Check:SetAtlas("GarrMission_CounterHalfCheck", true);
		threatFrame.Check:Show();
		return;
	end

	if ( counterableThreats.away[mechanicID] and #counterableThreats.away[mechanicID] > 0 ) then
		local soonestTime = table.remove(counterableThreats.away[mechanicID], 1);
		threatFrame.Away:Show();
		threatFrame.TimeLeft:Show();
		threatFrame.TimeLeft:SetText(GarrisonMission_GetDurationStringCompact(soonestTime));
		return;
	end

	if ( counterableThreats.worker[mechanicID] and counterableThreats.worker[mechanicID] > 0 ) then
		counterableThreats.worker[mechanicID] = counterableThreats.worker[mechanicID] - 1;
		threatFrame.Working:Show();
		return;
	end
end

function GarrisonMissionPageFollowerFrame_OnMouseUp(self, button)
	if ( button == "RightButton" ) then
		if ( self.info ) then
			GarrisonMissionPage_ClearFollower(self, true);
		else
			MISSION_PAGE_FRAME.CloseButton:Click();
		end
	end
end


---------------------------------------------------------------------------------
--- Mission Page                                                              ---
---------------------------------------------------------------------------------

function GarrisonMissionPage_OnLoad(self)
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
	self.BuffsFrame:SetFrameLevel(self.FollowerModel:GetFrameLevel() + 1);
	self:RegisterForClicks("RightButtonUp");
end

function GarrisonMissionPage_OnEvent(self, event)
	if ( event == "GARRISON_FOLLOWER_LIST_UPDATE" or event == "GARRISON_FOLLOWER_XP_CHANGED" ) then
		if ( MISSION_PAGE_FRAME.missionInfo ) then
			local mentorLevel, mentorItemLevel = C_Garrison.GetPartyMentorLevels(MISSION_PAGE_FRAME.missionInfo.missionID);
			MISSION_PAGE_FRAME.mentorLevel = mentorLevel;
			MISSION_PAGE_FRAME.mentorItemLevel = mentorItemLevel;
		else
			MISSION_PAGE_FRAME.mentorLevel = nil;
			MISSION_PAGE_FRAME.mentorItemLevel = nil;
		end
		GarrisonMissionPage_UpdateParty();
	end
	GarrisonMissionPage_UpdateStartButton(self);
end

function GarrisonMissionPage_OnShow(self)
	GarrisonMissionFrame.FollowerList.showUncollected = false;
	GarrisonMissionFrame.FollowerList.showCounters = true;
	GarrisonMissionFrame.FollowerList.canExpand = true;
	GarrisonMissionFrame.FollowerList:Show();
	GarrisonMissionPage_UpdateStartButton(self);
end

function GarrisonMissionPage_OnHide(self)
	GarrisonMissionFrame.FollowerList.showCounters = false;
	GarrisonMissionFrame.FollowerList.canExpand = false;
	GarrisonMissionFrame.FollowerList.showUncollected = true;
end

function GarrisonMissionPage_OnUpdate(self)
	if ( self.missionInfo.offerEndTime and self.missionInfo.offerEndTime <= GetTime() ) then
		-- mission expired
		GarrisonMissionFrame_ClearMouse();
		self.CloseButton:Click();
	end
end

function GarrisonMissionPage_ShowMission(missionInfo)
	local self = GarrisonMissionFrame.MissionTab.MissionPage;
	self.missionInfo = missionInfo;
	
	local location, xp, environment, environmentDesc, environmentTexture, locPrefix, isExhausting, enemies = C_Garrison.GetMissionInfo(missionInfo.missionID);
	self.Stage.Level:SetText(missionInfo.level);
	self.Stage.Title:SetText(missionInfo.name);
	GarrisonTruncationFrame_Check(self.Stage.Title);
	self.Stage.Location:SetText(missionInfo.location);
	self.Stage.MissionDescription:SetText(missionInfo.description);
	self.environment = environment;
	self.xp = xp;
	self.Stage.MissionEnvIcon.Texture:SetTexture(environmentTexture);
	if ( locPrefix ) then
		self.Stage.LocBack:SetAtlas("_"..locPrefix.."-Back", true);
		self.Stage.LocMid:SetAtlas ("_"..locPrefix.."-Mid", true);
		self.Stage.LocFore:SetAtlas("_"..locPrefix.."-Fore", true);
	end
	self.Stage.MissionType:SetAtlas(missionInfo.typeAtlas);

	-- max level
	if ( self.missionInfo.level == GarrisonMissionFrame.followerMaxLevel and self.missionInfo.iLevel > 0 ) then
		self.showItemLevel = true;
		self.Stage.Level:SetPoint("CENTER", self.Stage.Header, "TOPLEFT", 30, -28);
		self.Stage.ItemLevel:Show();
		self.Stage.ItemLevel:SetFormattedText(NUMBER_IN_PARENTHESES, self.missionInfo.iLevel);
		self.ItemLevelHitboxFrame:Show();
	else
		self.showItemLevel = false;
		self.Stage.Level:SetPoint("CENTER", self.Stage.Header, "TOPLEFT", 30, -36);
		self.Stage.ItemLevel:Hide();
		self.ItemLevelHitboxFrame:Hide();
	end

	if ( self.missionInfo.isRare ) then
		self.Stage.IconBG:SetVertexColor(0, 0.012, 0.291, 0.4);
	else
		self.Stage.IconBG:SetVertexColor(0, 0, 0, 0.4);
	end

	if ( isExhausting ) then
		self.Stage.ExhaustingLabel:Show();
		self.Stage.MissionTime:SetPoint("TOPLEFT", self.Stage.ExhaustingLabel, "BOTTOMLEFT", 0, -3);
	else
		self.Stage.ExhaustingLabel:Hide();
		self.Stage.MissionTime:SetPoint("TOPLEFT", self.Stage.Header, "BOTTOMLEFT", 7, -7);
	end
	
	if (missionInfo.cost > 0) then
		self.CostFrame:Show();
		self.StartMissionButton:ClearAllPoints();
		self.StartMissionButton:SetPoint("RIGHT", self.ButtonFrame, "RIGHT", -50, 1);
	else
		self.CostFrame:Hide();
		self.StartMissionButton:ClearAllPoints();
		self.StartMissionButton:SetPoint("CENTER", self.ButtonFrame, "CENTER", 0, 1);
	end
		
	GarrisonMissionPage_SetPartySize(missionInfo.numFollowers, #enemies);
	GarrisonMissionPage_SetEnemies(enemies, missionInfo.numFollowers);
	
	local numRewards = missionInfo.numRewards;
	local numVisibleRewards = 0;
	for id, reward in pairs(missionInfo.rewards) do
		numVisibleRewards = numVisibleRewards + 1;
		local rewardFrame = self.RewardsFrame.Rewards[numVisibleRewards];
		if ( rewardFrame ) then
			GarrisonMissionPage_SetReward(rewardFrame, reward);
		else
			-- too many rewards
			numVisibleRewards = numVisibleRewards - 1;
			break;
		end
	end
	for i = (numVisibleRewards + 1), #self.RewardsFrame.Rewards do
		self.RewardsFrame.Rewards[i]:Hide();
	end
	self.RewardsFrame.Reward1:ClearAllPoints();
	if ( numRewards == 1 ) then
		self.RewardsFrame.Reward1:SetPoint("LEFT", self.RewardsFrame, 207, 0);
	elseif ( numRewards == 2 ) then
		self.RewardsFrame.Reward1:SetPoint("LEFT", self.RewardsFrame, 128, 0);
	end
	-- set up all the values
	self.RewardsFrame.currentChance = nil;	-- so we don't animate setting the initial chance %
	if ( self.RewardsFrame.elapsedTime ) then
		GarrisonMissionPageRewardsFrame_StopUpdate(self.RewardsFrame);
	end
	GarrisonMissionPage_UpdateMissionForParty();
	GarrisonMissionFrame_CheckTutorials();
end

function GarrisonMissionPage_UpdateMissionForParty()
	local totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, isEnvMechanicCountered, xpBonus, materialMultiplier, goldMultiplier = C_Garrison.GetPartyMissionInfo(MISSION_PAGE_FRAME.missionInfo.missionID);

	-- TIME
	if ( isMissionTimeImproved ) then
		totalTimeString = GREEN_FONT_COLOR_CODE..totalTimeString..FONT_COLOR_CODE_CLOSE;
	elseif ( totalTimeSeconds >= GARRISON_LONG_MISSION_TIME ) then
		totalTimeString = format(GARRISON_LONG_MISSION_TIME_FORMAT, totalTimeString);
	end
	MISSION_PAGE_FRAME.Stage.MissionTime:SetFormattedText(GARRISON_MISSION_TIME_TOTAL, totalTimeString);

	-- SUCCESS CHANCE
	local rewardsFrame = MISSION_PAGE_FRAME.RewardsFrame;
	-- if animating, stop it
	if ( rewardsFrame.elapsedTime ) then
		rewardsFrame.Chance:SetFormattedText(PERCENTAGE_STRING, rewardsFrame.endingChance);
		rewardsFrame.currentChance = rewardsFrame.endingChance;
		GarrisonMissionPageRewardsFrame_StopUpdate(rewardsFrame);
	end	
	if ( rewardsFrame.currentChance and successChance > rewardsFrame.currentChance ) then
		rewardsFrame.elapsedTime = 0;
		rewardsFrame.startingChance = rewardsFrame.currentChance;
		rewardsFrame.endingChance = successChance;
		rewardsFrame:SetScript("OnUpdate", GarrisonMissionPageRewardsFrame_OnUpdate);
		rewardsFrame.ChanceGlowAnim:Play();
		if ( successChance < 100 ) then
			PlaySound("UI_Garrison_CommandTable_IncreaseSuccess");
		else
			PlaySound("UI_Garrison_CommandTable_100Success");
		end
	else
		-- no need to animate if chance is not increasing
		if ( rewardsFrame.currentChance and successChance < rewardsFrame.currentChance ) then
			PlaySound("UI_Garrison_CommandTable_ReducedSuccessChance");
		end
		rewardsFrame.Chance:SetFormattedText(PERCENTAGE_STRING, successChance);
		rewardsFrame.currentChance = successChance;
	end	

	-- PARTY BOOFS
	local buffsFrame = MISSION_PAGE_FRAME.BuffsFrame;
	local buffCount = #partyBuffs;
	if ( buffCount == 0 ) then
		buffsFrame:Hide();
	else
		for i = 1, buffCount do
			local buff = buffsFrame.Buffs[i];
			if ( not buff ) then
				buff = CreateFrame("Frame", nil, buffsFrame, "GarrisonMissionPartyBuffTemplate");
				buff:SetPoint("LEFT", buffsFrame.Buffs[i - 1], "RIGHT", 8, 0);
			end
			buff.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(partyBuffs[i]));
			buff.id = partyBuffs[i];
			buff:Show();
		end
		for i = buffCount + 1, #buffsFrame.Buffs do
			buffsFrame.Buffs[i]:Hide();
		end
		local width = buffCount * 28 + buffsFrame.BuffsTitle:GetWidth() + 40;
		buffsFrame:SetWidth(max(width, 160));
		buffsFrame:Show();
	end

	-- ENVIRONMENT
	if ( MISSION_PAGE_FRAME.environment ) then
		local env = MISSION_PAGE_FRAME.environment;
		local envCheckFrame = MISSION_PAGE_FRAME.Stage.MissionEnvIcon;
		if ( isEnvMechanicCountered ) then
			env = GREEN_FONT_COLOR_CODE..env..FONT_COLOR_CODE_CLOSE;
			if ( not envCheckFrame.Check:IsShown() ) then
				envCheckFrame.Check:Show();
				envCheckFrame.Anim:Stop();
				envCheckFrame.Anim:Play();
				PlaySound("UI_Garrison_Mission_Threat_Countered");
			end
		else
			envCheckFrame.Check:Hide();
		end
		MISSION_PAGE_FRAME.Stage.MissionEnv:SetFormattedText(GARRISON_MISSION_ENVIRONMENT, env);
	end	

	-- XP
	if ( xpBonus > 0 ) then
		rewardsFrame.MissionXP:SetFormattedText(GARRISON_MISSION_BASE_XP_PLUS, MISSION_PAGE_FRAME.xp + xpBonus, xpBonus);
		rewardsFrame.MissionXP.hasBonusBaseXP = true;
	else
		rewardsFrame.MissionXP:SetFormattedText(GARRISON_MISSION_BASE_XP, MISSION_PAGE_FRAME.xp);
		rewardsFrame.MissionXP.hasBonusBaseXP = false;
	end
	
	-- Material
	GarrisonMissionPage_UpdateRewardQuantities(rewardsFrame, materialMultiplier, goldMultiplier);

	-- START BUTTON AND STUFF
	GarrisonMissionPage_UpdateStartButton(MISSION_PAGE_FRAME);	
	GarrisonMissionPage_UpdatePortraitPulse(MISSION_PAGE_FRAME);
	GarrisonMissionPage_UpdateEmptyString();
end

function GarrisonMissionPageEnvironment_OnEnter(self)
	local _, _, environment, environmentDesc = C_Garrison.GetMissionInfo(MISSION_PAGE_FRAME.missionInfo.missionID);
	if ( environment ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(environment);
		GameTooltip:AddLine(environmentDesc, 1, 1, 1, 1);
		GameTooltip:Show();
	end
end

function GarrisonMissionPage_UpdateEmptyString()
	if ( C_Garrison.GetNumFollowersOnMission(MISSION_PAGE_FRAME.missionInfo.missionID) == 0 ) then
		MISSION_PAGE_FRAME.EmptyString:Show();
	else
		MISSION_PAGE_FRAME.EmptyString:Hide();
	end
end

function GarrisonMissionPage_UpdateStartButton(missionPage)
	local missionInfo = missionPage.missionInfo;
	if ( not missionPage.missionInfo or not missionPage:IsVisible() ) then
		return;
	end

	local disableError;
	
	if ( C_Garrison.IsAboveFollowerSoftCap() ) then
		disableError = GARRISON_MAX_FOLLOWERS_MISSION_TOOLTIP;
	end
	
	local currencyName, amount, currencyTexture = GetCurrencyInfo(GARRISON_CURRENCY);
	if ( not disableError and amount < missionInfo.cost ) then
		missionPage.CostFrame.Cost:SetText(RED_FONT_COLOR_CODE..BreakUpLargeNumbers(missionInfo.cost)..FONT_COLOR_CODE_CLOSE);
		disableError = GARRISON_NOT_ENOUGH_MATERIALS_TOOLTIP;
	else
		missionPage.CostFrame.Cost:SetText(BreakUpLargeNumbers(missionInfo.cost));
	end

	if ( not disableError and C_Garrison.GetNumFollowersOnMission(missionPage.missionInfo.missionID) < missionPage.missionInfo.numFollowers ) then
		disableError = GARRISON_PARTY_NOT_FULL_TOOLTIP;
	end

	local startButton = missionPage.StartMissionButton;
	if ( disableError ) then
		startButton:SetEnabled(false);
		startButton.Flash:Hide();
		startButton.FlashAnim:Stop();	
		startButton.tooltip = disableError;
	else
		startButton:SetEnabled(true);
		startButton.Flash:Show();
		startButton.FlashAnim:Play();
		startButton.tooltip = nil;
	end
end

function GarrisonMissionPage_UpdatePortraitPulse(missionPage)
	-- only pulse the first available slot
	local pulsed = false;
	for i = 1, #MISSION_PAGE_FRAME.Followers do
		local followerFrame = MISSION_PAGE_FRAME.Followers[i];
		if ( followerFrame.info ) then
			followerFrame.PortraitFrame.PulseAnim:Stop();
		else			
			if ( pulsed ) then
				followerFrame.PortraitFrame.PulseAnim:Stop();
			else
				followerFrame.PortraitFrame.PulseAnim:Play();
				pulsed = true;
			end			
		end
	end
end

function GarrisonMissionPage_SetReward(frame, reward)
	frame.Quantity:Hide();
	frame.itemID = nil;
	frame.currencyID = nil;
	frame.currencyQuantity = nil;
	frame.tooltip = nil;
	if (reward.itemID) then
		frame.itemID = reward.itemID;
		if ( reward.quantity > 1 ) then
			frame.Quantity:SetText(reward.quantity);
			frame.Quantity:Show();
		end
		GarrisonMissionFrame_SetItemRewardDetails(frame);
	else
		frame.Icon:SetTexture(reward.icon);
		frame.title = reward.title
		if (reward.currencyID and reward.quantity) then
			if (reward.currencyID == 0) then
				frame.tooltip = GetMoneyString(reward.quantity);
				frame.currencyID = 0;
				frame.currencyQuantity = reward.quantity;
				if (frame.Name) then
					frame.Name:SetText(frame.tooltip);
				end
			else
				local currencyName, _, currencyTexture = GetCurrencyInfo(reward.currencyID);
				frame.currencyID = reward.currencyID;
				frame.currencyQuantity = reward.quantity;
				if (frame.Name) then
					frame.Name:SetText(currencyName);
				end
				frame.Quantity:SetText(reward.quantity);
				frame.Quantity:Show();
			end
		else
			frame.tooltip = reward.tooltip;
			if (frame.Name) then
				if (reward.quality) then
					frame.Name:SetText(ITEM_QUALITY_COLORS[reward.quality + 1].hex..frame.title..FONT_COLOR_CODE_CLOSE);
				elseif (reward.followerXP) then
					frame.Name:SetFormattedText(GARRISON_REWARD_XP_FORMAT, BreakUpLargeNumbers(reward.followerXP));
				else
					frame.Name:SetText(frame.title);
				end
			end
		end
	end
	frame:Show();
end

function GarrisonMissionPage_UpdateRewardQuantities(rewardsFrame, materialMultiplier, goldMultiplier)
	for i = 1, #rewardsFrame.Rewards do
		local rewardFrame = rewardsFrame.Rewards[i];
		if ( rewardFrame.currencyID == GARRISON_CURRENCY and rewardFrame:IsShown() ) then
			local amount = floor(rewardFrame.currencyQuantity * materialMultiplier);
			rewardFrame.Quantity:SetText(amount);
		elseif ( rewardFrame.currencyID == 0 and rewardFrame:IsShown() ) then
			local amount = floor(rewardFrame.currencyQuantity * goldMultiplier);
			rewardFrame.tooltip = GetMoneyString(amount);
			if (rewardFrame.Name) then
				rewardFrame.Name:SetText(rewardFrame.tooltip);
			end
		end
	end
end

function GarrisonMissionPage_SetPartySize(size, numEnemies)
	for i = 1, #MISSION_PAGE_FRAME.Followers do
		if ( i <= size ) then
			MISSION_PAGE_FRAME.Followers[i]:Show();
		else
			MISSION_PAGE_FRAME.Followers[i]:Hide();
		end
	end
	MISSION_PAGE_FRAME.EmptyString:ClearAllPoints();
	MISSION_PAGE_FRAME.FollowerModel:Hide();
	if ( size == 1 ) then
		MISSION_PAGE_FRAME.EmptyString:SetText(GARRISON_PARTY_INSTRUCTIONS_SINGLE);
		MISSION_PAGE_FRAME.EmptyFollowerModel:Show();
		if ( numEnemies == 1 ) then
			MISSION_PAGE_FRAME.Followers[1]:SetPoint("TOPLEFT", 82, -274);
			MISSION_PAGE_FRAME.EmptyString:SetPoint("TOPLEFT", 98, -255);
		else
			MISSION_PAGE_FRAME.Followers[1]:SetPoint("TOPLEFT", 22, -274);
			MISSION_PAGE_FRAME.EmptyString:SetPoint("TOPLEFT", 28, -255);
		end
		MISSION_PAGE_FRAME.BuffsFrame:ClearAllPoints();
		MISSION_PAGE_FRAME.BuffsFrame:SetPoint("BOTTOMLEFT", 80, 198);
	else
		MISSION_PAGE_FRAME.EmptyString:SetText(GARRISON_PARTY_INSTRUCTIONS_MANY);
		MISSION_PAGE_FRAME.EmptyString:SetPoint("TOP", 0, -255);
		MISSION_PAGE_FRAME.EmptyFollowerModel:Hide();
		if ( size == 2 ) then
			MISSION_PAGE_FRAME.Followers[1]:SetPoint("TOPLEFT", 108, -274);
		else
			MISSION_PAGE_FRAME.Followers[1]:SetPoint("TOPLEFT", 22, -274);
		end
		MISSION_PAGE_FRAME.BuffsFrame:ClearAllPoints();
		MISSION_PAGE_FRAME.BuffsFrame:SetPoint("BOTTOM", 0, 198);		
	end
end

function GarrisonMissionPage_SetEnemies(enemies, numFollowers)
	local numVisibleEnemies = 0;
	for i=1, #enemies do
		local Frame = MISSION_PAGE_FRAME.Enemies[i];
		if ( not Frame ) then
			break;
		end
		numVisibleEnemies = numVisibleEnemies + 1;
		local enemy = enemies[i];
		Frame.Name:SetText(enemy.name);
		GarrisonEnemyPortait_Set(Frame.PortraitFrame.Portrait, enemy.portraitFileDataID);
		local numMechs = 0;
		for id, mechanic in pairs(enemy.mechanics) do
			numMechs = numMechs + 1;	
			if (not Frame.Mechanics[numMechs]) then
				Frame.Mechanics[numMechs] = CreateFrame("Button", nil, Frame, "GarrisonMissionEnemyLargeMechanicTemplate");
				Frame.Mechanics[numMechs]:SetPoint("LEFT", Frame.Mechanics[numMechs-1], "RIGHT", 16, 0);
			end
			local Mechanic = Frame.Mechanics[numMechs];
			Mechanic.info = mechanic;
			Mechanic.Icon:SetTexture(mechanic.icon);
			Mechanic.mechanicID = id;
			Mechanic:Show();
		end
		Frame.Mechanics[1]:SetPoint("BOTTOM", (numMechs - 1) * -22, -16);
		for j=(numMechs + 1), #Frame.Mechanics do
			Frame.Mechanics[j]:Hide();
			Frame.Mechanics[j].mechanicID = nil;
			Frame.Mechanics[j].info = nil;
		end
		if ( numMechs > 1 ) then
			Frame.PortraitFrame.Elite:Show();
		else
			Frame.PortraitFrame.Elite:Hide();
		end
		Frame:Show();
	end
	for i = numVisibleEnemies + 1, #MISSION_PAGE_FRAME.Enemies do
		MISSION_PAGE_FRAME.Enemies[i]:Hide();
	end
	if ( numVisibleEnemies == 1 ) then
		if ( numFollowers == 1 ) then
			MISSION_PAGE_FRAME.Enemy1:SetPoint("TOPLEFT", 143, -164);
		else
			MISSION_PAGE_FRAME.Enemy1:SetPoint("TOPLEFT", 251, -164);
		end
	elseif ( numVisibleEnemies == 2 ) then
		if ( numFollowers == 1 ) then
			MISSION_PAGE_FRAME.Enemy1:SetPoint("TOPLEFT", 78, -164);
		else
			MISSION_PAGE_FRAME.Enemy1:SetPoint("TOPLEFT", 165, -164);
		end	
	else
		MISSION_PAGE_FRAME.Enemy1:SetPoint("TOPLEFT", 78, -164);
	end
end

function GarrisonMissionPageRewardsFrame_OnUpdate(self, elapsed)
	self.elapsedTime = self.elapsedTime + elapsed;
	-- 0 to 100 should take 1 second
	local newChance = math.floor(self.startingChance + self.elapsedTime * 100);
	newChance = min(newChance, self.endingChance);
	self.Chance:SetFormattedText(PERCENTAGE_STRING, newChance);
	self.currentChance = newChance
	if ( newChance == self.endingChance ) then
		if ( newChance == 100 ) then
			PlaySoundKitID(43507);	-- 100% chance reached
		end
		GarrisonMissionPageRewardsFrame_StopUpdate(self);
	end
end

function GarrisonMissionPageRewardsFrame_StopUpdate(self)
	self.elapsedTime = nil;
	self.startingChance = nil;
	self.endingChance = nil;
	self:SetScript("OnUpdate", nil);
end

function GarrisonMissionPage_AddFollower(followerID)
	for i = 1, #MISSION_PAGE_FRAME.Followers do
		local followerFrame = MISSION_PAGE_FRAME.Followers[i];
		if ( not followerFrame.info ) then
			local followerInfo = C_Garrison.GetFollowerInfo(followerID);
			GarrisonMissionPage_SetFollower(followerFrame, followerInfo);
			break;
		end
	end
end

function GarrisonMissionPage_SetFollower(frame, info)
	if (frame.info) then
		GarrisonMissionPage_ClearFollower(frame);
	end

	-- frame.info needs to be set for AddFollowerToMission()
	frame.info = info;	
	if ( not C_Garrison.AddFollowerToMission(MISSION_PAGE_FRAME.missionInfo.missionID, info.followerID) ) then
		frame.info = nil;
		return;
	end

	frame.Name:Show();
	frame.Name:SetText(info.name);
	if (frame.Class) then
		frame.Class:Show();
		frame.Class:SetAtlas(info.classAtlas);
	end
	frame.PortraitFrame.Empty:Hide();




	PlaySound("UI_Garrison_CommandTable_AssignFollower");
	-- update follower list
	GarrisonMissionFrame.followerCounters = C_Garrison.GetBuffedFollowersForMission(MISSION_PAGE_FRAME.missionInfo.missionID);
	GarrisonMissionFrame.followerTraits = C_Garrison.GetFollowersTraitsForMission(MISSION_PAGE_FRAME.missionInfo.missionID);
	GarrisonFollowerList_UpdateFollowers(GarrisonMissionFrame.FollowerList);

	GarrisonMissionPage_UpdateMissionForParty();

	if ( MISSION_PAGE_FRAME.missionInfo.numFollowers == 1 ) then
		local model = MISSION_PAGE_FRAME.FollowerModel;
		model:Show();
		model:SetTargetDistance(0);
		GarrisonMission_SetFollowerModel(model, info.followerID, info.displayID);
		model:SetHeightFactor(info.height or 1);
		model:InitializeCamera(info.scale or 1);
		model:SetFacing(-.2);
		MISSION_PAGE_FRAME.EmptyFollowerModel:Hide();
	end

	GarrisonMissionPage_SetCounters();
end

function GarrisonMissionPage_UpdateParty()
	-- Update follower level and portrait color in case they have changed
	for followerIndex = 1, #MISSION_PAGE_FRAME.Followers do
		local followerFrame = MISSION_PAGE_FRAME.Followers[followerIndex];
		if ( followerFrame.info ) then
			local followerInfo = C_Garrison.GetFollowerInfo(followerFrame.info.followerID);
			if ( followerInfo and followerInfo.status == GARRISON_FOLLOWER_IN_PARTY ) then
				GarrisonMissionFrame_SetFollowerPortrait(followerFrame.PortraitFrame, followerInfo, true);
			else
				GarrisonMissionPage_ClearFollower(followerFrame, true);
			end
			
			local counters = GarrisonMissionFrame.followerCounters and followerFrame.info and GarrisonMissionFrame.followerCounters[followerFrame.info.followerID] or nil;
			if (counters) then
				for i = 1, #counters do
					if (not followerFrame.Counters[i]) then
						followerFrame.Counters[i] = CreateFrame("Frame", nil, followerFrame, "GarrisonMissionAbilityLargeCounterTemplate");
						followerFrame.Counters[i]:SetPoint("LEFT", followerFrame.Counters[i-1], "RIGHT", 16, 0);
					end
					local Counter = followerFrame.Counters[i];
					Counter.info = counters[i];
					Counter.info.showCounters = true;
					Counter.Icon:SetTexture(counters[i].icon);
					Counter.tooltip = counters[i].name;
					Counter:Show();
				end
				for i = (#counters + 1), #followerFrame.Counters do
					followerFrame.Counters[i]:Hide();
				end
			end
		end
	end
end

function GarrisonMissionPage_ClearFollower(frame, updateValues)
	local followerID = frame.info and frame.info.followerID or nil;
	frame.info = nil;
	frame.Name:Hide();
	if (frame.Class) then
		frame.Class:Hide();
	end
	frame.PortraitFrame.Empty:Show();
	frame.PortraitFrame.LevelBorder:SetAtlas("GarrMission_PortraitRing_LevelBorder");
	frame.PortraitFrame.LevelBorder:SetWidth(58);
	frame.PortraitFrame.Level:SetText("");
	frame.PortraitFrame.Caution:Hide();

	for i = 1, #frame.Counters do
		frame.Counters[i]:Hide();
	end

	if (followerID) then
		C_Garrison.RemoveFollowerFromMission(MISSION_PAGE_FRAME.missionInfo.missionID, followerID);
		if ( MISSION_PAGE_FRAME.missionInfo.numFollowers == 1 ) then
			MISSION_PAGE_FRAME.FollowerModel:ClearModel();
			MISSION_PAGE_FRAME.FollowerModel:Hide();
			MISSION_PAGE_FRAME.EmptyFollowerModel:Show();
		end
		if ( updateValues ) then
			PlaySound("UI_Garrison_CommandTable_UnassignFollower");
			GarrisonMissionPage_UpdateMissionForParty();
			-- update follower list
			GarrisonMissionFrame.followerCounters = C_Garrison.GetBuffedFollowersForMission(MISSION_PAGE_FRAME.missionInfo.missionID);
			GarrisonMissionFrame.followerTraits = C_Garrison.GetFollowersTraitsForMission(MISSION_PAGE_FRAME.missionInfo.missionID);
			GarrisonFollowerList_UpdateFollowers(GarrisonMissionFrame.FollowerList);
		end
	end
	
	GarrisonMissionPage_SetCounters();
end

function GarrisonMissionPage_ClearParty()
	for i = 1, #MISSION_PAGE_FRAME.Followers do
		local followerFrame = MISSION_PAGE_FRAME.Followers[i];
		GarrisonMissionPage_ClearFollower(followerFrame);
	end
	MISSION_PAGE_FRAME.FollowerModel:Hide();
	GarrisonMissionPage_UpdateEmptyString();
end

function GarrisonMissionPage_ClearCounters(enemiesFrame)
	for i=1, enemiesFrame.numEnemies do
		local frame = enemiesFrame["Enemy"..i];
		for j=1, #frame.Mechanics do
			frame.Mechanics[j].Check:Hide();
		end
	end
end

--this function puts check marks on the encounter mechanics countered by the slotted followers abilities
function GarrisonMissionPage_SetCounters()
	-- clear counter state
	for i = 1, #MISSION_PAGE_FRAME.Enemies do
		local enemyFrame = MISSION_PAGE_FRAME.Enemies[i];
		for mechanicIndex = 1, #enemyFrame.Mechanics do
			enemyFrame.Mechanics[mechanicIndex].hasCounter = nil;
		end
	end
	
	for i = 1, #MISSION_PAGE_FRAME.Followers do
		local followerFrame = MISSION_PAGE_FRAME.Followers[i];
		if (followerFrame.info) then
			local followerBias = C_Garrison.GetFollowerBiasForMission(MISSION_PAGE_FRAME.missionInfo.missionID, followerFrame.info.followerID);
			if ( followerBias > -1 ) then
				if (not followerFrame.info.abilities) then
					followerFrame.info.abilities = C_Garrison.GetFollowerAbilities(followerFrame.info.followerID)
				end
				for a = 1, #followerFrame.info.abilities do
					local ability = followerFrame.info.abilities[a];
					for counterID, counterInfo in pairs(ability.counters) do
						GarrisonMissionPage_CheckCounter(counterID);
					end
				end
			end
		end
	end
	
	-- show/remove checks
	local playSound = false;
	for i = 1, #MISSION_PAGE_FRAME.Enemies do
		local enemyFrame = MISSION_PAGE_FRAME.Enemies[i];
		for mechanicIndex = 1, #enemyFrame.Mechanics do
			local mechanicFrame = enemyFrame.Mechanics[mechanicIndex];
			if ( mechanicFrame.hasCounter ) then
				if ( not mechanicFrame.Check:IsShown() ) then
					mechanicFrame.Check:SetAlpha(1);
					mechanicFrame.Check:Show();
					mechanicFrame.Anim:Play();
					playSound = true;
				end
			else
				mechanicFrame.Check:Hide();
			end
		end
	end
	
	if ( playSound ) then
		PlaySound("UI_Garrison_Mission_Threat_Countered");
	end
end

function GarrisonMissionPage_CheckCounter(counterID)
	for i = 1, #MISSION_PAGE_FRAME.Enemies do
		local enemyFrame = MISSION_PAGE_FRAME.Enemies[i];
		for mechanicIndex = 1, #enemyFrame.Mechanics do
			if ( counterID == enemyFrame.Mechanics[mechanicIndex].mechanicID and not enemyFrame.Mechanics[mechanicIndex].hasCounter ) then			
				enemyFrame.Mechanics[mechanicIndex].hasCounter = true;
				return;
			end
		end
	end
end

function GarrisonMissionPage_Close(self)
	GarrisonMissionFrame.MissionTab.MissionPage:Hide();
	GarrisonMissionFrame.MissionTab.MissionList:Show();
	GarrisonMissionPage_ClearParty();
	GarrisonMissionFrame.followerCounters = nil;
	GarrisonMissionFrame.MissionTab.MissionPage.missionInfo = nil;	
end

---------------------------------------------------------------------------------
--- Mission Page: Placing Followers/Starting Mission                          ---
---------------------------------------------------------------------------------
function GarrisonFollowerListButton_OnDragStart(self, button)
	if ( not GarrisonMissionFrame.MissionTab.MissionPage:IsVisible() ) then
		return;
	end
	if ( self.info.status or not self.info.isCollected ) then
		return;
	end
	CloseDropDownMenus();
	GarrisonMissionFrame_SetFollowerPortrait(GarrisonFollowerPlacer, self.info);
	GarrisonFollowerPlacer.info = self.info;
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonFollowerPlacer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + 24);
	GarrisonFollowerPlacer:Show();
	GarrisonFollowerPlacer:SetScript("OnUpdate", GarrisonFollowerPlacer_OnUpdate);
end

function GarrisonFollowerListButton_OnDragStop(self)
	if (GarrisonFollowerPlacer:IsShown()) then
		GarrisonFollowerPlacerFrame:Show();
	end
end

function GarrisonFollowerPlacer_OnUpdate(self)
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonFollowerPlacer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + 24);
end

function GarrisonFollowerPlacerFrame_OnClick(self, button)
	if ( button == "LeftButton" ) then
		for i = 1, #MISSION_PAGE_FRAME.Followers do
			local followerFrame = MISSION_PAGE_FRAME.Followers[i];
			if ( followerFrame:IsShown() and followerFrame:IsMouseOver() ) then
				GarrisonMissionPage_SetFollower(followerFrame, GarrisonFollowerPlacer.info);
			end
		end
	end
	GarrisonMissionFrame_ClearMouse();
end

function GarrisonMissionPageFollowerFrame_OnDragStart(self)
	if ( not self.info ) then
		return;
	end
	GarrisonMissionFrame_SetFollowerPortrait(GarrisonFollowerPlacer, self.info);
	GarrisonFollowerPlacer.info = self.info;
	local cursorX, cursorY = GetCursorPosition();
	local uiScale = UIParent:GetScale();
	GarrisonFollowerPlacer:SetPoint("TOP", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale + 24);
	GarrisonFollowerPlacer:Show();
	GarrisonFollowerPlacer:SetScript("OnUpdate", GarrisonFollowerPlacer_OnUpdate);
	GarrisonMissionPage_ClearFollower(self, true);
end

function GarrisonMissionPageFollowerFrame_OnDragStop(self)
	if ( not GarrisonFollowerPlacer.info ) then
		return;
	end
	GarrisonFollowerPlacerFrame:Show();
end

function GarrisonMissionPageFollowerFrame_OnReceiveDrag(self)
	if ( GarrisonFollowerPlacer:IsVisible() and GarrisonFollowerPlacer.info ) then
		GarrisonMissionPage_SetFollower(self, GarrisonFollowerPlacer.info);
		GarrisonMissionFrame_ClearMouse();
	end
end

function GarrisonMissionPageFollowerFrame_OnEnter(self)
	if not self.info then 
		return;
	end

	GarrisonFollowerTooltip:ClearAllPoints();
	GarrisonFollowerTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT");	
	GarrisonFollowerTooltip_Show(self.info.garrFollowerID, 
		self.info.isCollected,
		C_Garrison.GetFollowerQuality(self.info.followerID),
		C_Garrison.GetFollowerLevel(self.info.followerID), 
		C_Garrison.GetFollowerXP(self.info.followerID),
		C_Garrison.GetFollowerLevelXP(self.info.followerID),
		C_Garrison.GetFollowerItemLevelAverage(self.info.followerID), 
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 4),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 4),
		true,
		C_Garrison.GetFollowerBiasForMission(MISSION_PAGE_FRAME.missionInfo.missionID, self.info.followerID) < 0.0
		);
end

function GarrisonMissionPageFollowerFrame_OnLeave(self)
	GarrisonFollowerTooltip:Hide();
end

function GarrisonMissionPageStartMissionButton_OnClick(self)
	if (not MISSION_PAGE_FRAME.missionInfo.missionID) then
		return;
	end
	C_Garrison.StartMission(MISSION_PAGE_FRAME.missionInfo.missionID);
	PlaySound("UI_Garrison_CommandTable_MissionStart");
	GarrisonMissionList_UpdateMissions();
	GarrisonFollowerList_UpdateFollowers(GarrisonMissionFrame.FollowerList);
	GarrisonMissionPage_Close();
	if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_LANDING)) then
		GarrisonLandingPageTutorialBox:Show();
	end
end

function GarrisonMissionPageStartMissionButton_OnEnter(self)
	if (not self:IsEnabled()) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true);
		GameTooltip:Show();
	end
end


---------------------------------------------------------------------------------
--- Tooltips                                                                  ---
---------------------------------------------------------------------------------

function GarrisonMissionMechanic_OnEnter(self)
	if (not self.info) then
		return;
	end
	local tooltip = GarrisonMissionMechanicTooltip;
	tooltip.Icon:SetTexture(self.info.icon);
	tooltip.Name:SetText(self.info.name);
	local height = tooltip.Icon:GetHeight() + 28; --height of icon plus padding around it and at the bottom
	tooltip.Description:SetText(self.info.description);
	height = height + tooltip.Description:GetHeight();
	tooltip:SetHeight(height);
	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 5, 0);
	tooltip:Show();
end

function GarrisonMissionMechanicFollowerCounter_OnEnter(self)
	if (not self.info) then
		return;
	end
	if ( self.info.traitID ) then
		GarrisonFollowerAbilityTooltip:ClearAllPoints();
		GarrisonFollowerAbilityTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT");
		GarrisonFollowerAbilityTooltip_Show(self.info.traitID);
		return;
	end
	local tooltip = GarrisonMissionMechanicFollowerCounterTooltip;
	tooltip.Icon:SetTexture(self.info.icon);
	tooltip.Name:SetText(self.info.name);
	local height = tooltip.Title:GetHeight() + tooltip.Subtitle:GetHeight() + tooltip.Icon:GetHeight() + 28; --height of icon plus padding around it and at the bottom

	if (self.info.showCounters) then
		tooltip.CounterFrom:Show();
		tooltip.CounterIcon:Show();
		tooltip.CounterName:Show();
		tooltip.CounterIcon:SetTexture(self.info.counterIcon);
		tooltip.CounterName:SetText(self.info.counterName);
		height = height + 21 + tooltip.CounterFrom:GetHeight() + tooltip.CounterIcon:GetHeight();
	else
		tooltip.CounterFrom:Hide();
		tooltip.CounterIcon:Hide();
		tooltip.CounterName:Hide();
	end
	
	tooltip:SetHeight(height);
	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 5, 0);
	tooltip:Show();
end

function GarrisonMissionMechanicFollowerCounter_OnLeave(self)
	GarrisonFollowerAbilityTooltip:Hide();
	GarrisonMissionMechanicFollowerCounterTooltip:Hide();
end

---------------------------------------------------------------------------------
--- Mission Complete                                                          ---
---------------------------------------------------------------------------------

function GarrisonMissionComplete_OnLoad(self)
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
	self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE");
	self.pendingXPAwards = { };
	self:SetFrameLevel(GarrisonMissionFrame.MissionCompleteBackground:GetFrameLevel() + 2);
end

function GarrisonMissionComplete_OnEvent(self, event, ...)
	if (event == "GARRISON_FOLLOWER_XP_CHANGED" and self:IsVisible()) then
		GarrisonMissionComplete_AnimFollowerXP(...);
	elseif ( event == "GARRISON_MISSION_COMPLETE_RESPONSE" ) then
		GarrisonMissionComplete_OnMissionCompleteResponse(self, ...);
	end
end

function GarrisonMissionFrame_ShowCompleteMissions()
	PlaySound("UI_Garrison_CommandTable_ViewMissionReport");
	if ( not MissionCompletePreload_IsReady() ) then
		GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton:SetEnabled(false);
		GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog.BorderFrame.LoadingFrame:Show();
		MissionCompletePreload_StartTimeout(GARRISON_MODEL_PRELOAD_TIME, GarrisonMissionFrame_ShowCompleteMissions);
		return;
	end

	GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog:Hide();
	local self = GarrisonMissionFrame.MissionComplete;

	GarrisonMissionFrame.FollowerTab:Hide();
	GarrisonMissionFrame.FollowerList:Hide();
	HelpPlate_Hide();

	GarrisonMissionFrame.MissionComplete:Show();
	GarrisonMissionFrame.MissionCompleteBackground:Show();

	self.currentIndex = 1;
	GarrisonMissionComplete_Initialize(self.completeMissions, self.currentIndex);
end

function GarrisonMissionFrame_HideCompleteMissions(onWindowClosing)
	local self = GarrisonMissionFrame;	
	self.MissionComplete:Hide();
	self.MissionCompleteBackground:Hide();
	GarrisonMissionFrame.MissionComplete.currentIndex = nil;
	if ( not onWindowClosing ) then
		self.MissionTab:Show();	
		GarrisonMissionList_UpdateMissions();
	end
end

GARRISON_MISSION_CHEST_MODELS = {
	{[PLAYER_FACTION_GROUP[0]] = 54910, [PLAYER_FACTION_GROUP[1]] = 54910},
	{[PLAYER_FACTION_GROUP[0]] = 54911, [PLAYER_FACTION_GROUP[1]] = 54911},
	{[PLAYER_FACTION_GROUP[0]] = 54913, [PLAYER_FACTION_GROUP[1]] = 54912},
}

function GarrisonMissionComplete_OnMissionCompleteResponse(self, missionID, canComplete, succeeded)
	if ( self.currentMission and self.currentMission.missionID == missionID ) then
		GarrisonMissionFrame.MissionComplete.NextMissionButton:Enable();
		if ( canComplete ) then
			self.currentMission.succeeded = succeeded;
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
				elseif ( #self.animInfo ) then
					self.currentMission.failedEncounter = random(1, #self.animInfo);
				else
					self.currentMission.failedEncounter = 1;
				end
			end		
			local animIndex = 0;		
			if ( GarrisonMissionFrame.MissionComplete.Stage.EncountersFrame.numEncounters == 0 ) then
				animIndex = GarrisonMissionComplete_FindAnimIndexFor(GarrisonMissionComplete_AnimRewards) - 1;
			end
			GarrisonMissionComplete_BeginAnims(self, animIndex);
			GarrisonMissionFrame.MissionComplete.NextMissionButton:Disable();
		end
	end
end

function GarrisonMissionComplete_Initialize(missionList, index)
	local self = GarrisonMissionFrame.MissionComplete;
	self.NextMissionButton:Enable();
	if (not missionList or #missionList == 0 or index == 0) then
		GarrisonMissionFrame_HideCompleteMissions();
		return;
	end
	if (index > #missionList) then
		self.completeMissions = nil;
		GarrisonMissionFrame_HideCompleteMissions();
		return;
	end
	local mission = missionList[index];
	self.currentMission = mission;

	local stage = self.Stage;
	stage.FollowersFrame:Hide();
	stage.EncountersFrame.FadeOut:Stop();
	stage.EncountersFrame:Show();

	for i = 1, #stage.Models do
		stage.Models[i].FadeIn:Stop();
	end

		
	stage.MissionInfo.Title:SetText(mission.name);
	GarrisonTruncationFrame_Check(stage.MissionInfo.Title);
	stage.MissionInfo.Level:SetText(mission.level);
	stage.MissionInfo.Location:SetText(mission.location);

	self.LoadingFrame:Hide();

	-- max level
	if ( mission.level == GarrisonMissionFrame.followerMaxLevel and mission.iLevel > 0 ) then
		stage.MissionInfo.Level:SetPoint("CENTER", stage.MissionInfo, "TOPLEFT", 30, -28);
		stage.MissionInfo.ItemLevel:Show();
		stage.MissionInfo.ItemLevel:SetFormattedText(NUMBER_IN_PARENTHESES, mission.iLevel);
		stage.ItemLevelHitboxFrame:Show();
	else
		stage.MissionInfo.Level:SetPoint("CENTER", stage.MissionInfo, "TOPLEFT", 30, -36);
		stage.MissionInfo.ItemLevel:Hide();
		stage.ItemLevelHitboxFrame:Hide();
	end
	-- rare
	if ( mission.isRare ) then
		stage.MissionInfo.IconBG:SetVertexColor(0, 0.012, 0.291, 0.4);
	else
		stage.MissionInfo.IconBG:SetVertexColor(0, 0, 0, 0.4);
	end
	local location, xp, environment, environmentDesc, environmentTexture, locPrefix, isExhausting, enemies = C_Garrison.GetMissionInfo(mission.missionID);
	if ( locPrefix ) then
		stage.LocBack:SetAtlas("_"..locPrefix.."-Back", true);
		stage.LocMid:SetAtlas ("_"..locPrefix.."-Mid", true);
		stage.LocFore:SetAtlas("_"..locPrefix.."-Fore", true);
	end
	stage.MissionInfo.MissionType:SetAtlas(mission.typeAtlas);
	stage.EncountersFrame.enemies = enemies;
	stage.EncountersFrame.uncounteredMechanics = C_Garrison.GetMissionUncounteredMechanics(mission.missionID);

	local encounters = C_Garrison.GetMissionCompleteEncounters(mission.missionID);
	GarrisonMissionComplete_SetNumEncounters(#encounters);
	for i=1, #encounters do
		local encounter = stage.EncountersFrame.Encounters[i];
		encounter.Name:SetText(encounters[i].name);
		GarrisonEnemyPortait_Set(encounter.Portrait, encounters[i].portraitFileDataID);
		if ( #enemies[1].mechanics > 1 ) then
			encounter.Elite:Show();
		else
			encounter.Elite:Hide();
		end
	end

	self.animInfo = {};
	stage.followers = {};
	for i=1, #mission.followers do
		local follower = stage.FollowersFrame.Followers[i];
		local name, displayID, level, quality, currXP, maxXP, height, scale, movementType, impactDelay, castID, castSoundID, impactID, impactSoundID, classAtlas, portraitIconID = 
					C_Garrison.GetFollowerMissionCompleteInfo(mission.followers[i]);
		follower.followerID = mission.followers[i];
		GarrisonFollowerPortrait_Set(follower.PortraitFrame.Portrait, portraitIconID);
		follower.Name:SetText(name);
		if ( follower.Class ) then
			follower.Class:SetAtlas(classAtlas);
		end
		GarrisonMissionComplete_SetFollowerLevel(follower, level, quality, currXP, maxXP);
		stage.followers[i] = { displayID = displayID, height = height, scale = scale, followerID = mission.followers[i] };
		if (encounters[i]) then --cannot have more animations than encounters
			self.animInfo[i] = { 	displayID = displayID,
									height = height, 
									scale = scale, 
									movementType = movementType,
									impactDelay = impactDelay,
									castID = castID,
									castSoundID = castSoundID,
									impactID = impactID,
									impactSoundID = impactSoundID,
									enemyDisplayID = encounters[i].displayID,
									enemyScale = encounters[i].scale,
									enemyHeight = encounters[i].height,
									followerID = mission.followers[i],
								}
		end
	end
	-- if there are fewer followers than encounters, cycle through followers to match up against encounters
	for i = #mission.followers + 1, #encounters do
		local index = mod(i, #mission.followers) + 1;
		local animInfo = self.animInfo[index];
		self.animInfo[i] = { 	displayID = animInfo.displayID,
								height = animInfo.height, 
								scale = animInfo.scale, 
								movementType = animInfo.movementType,
								impactDelay = animInfo.impactDelay,
								castID = animInfo.castID,
								castSoundID = animInfo.castSoundID,
								impactID = animInfo.impactID,
								impactSoundID = animInfo.impactSoundID,
								enemyDisplayID = encounters[i].displayID,
								enemyScale = encounters[i].scale,
								enemyHeight = encounters[i].height,
								followerID = animInfo.followerID,
							};
	end

	local materialMultiplier, goldMultiplier = select(8, C_Garrison.GetPartyMissionInfo(self.currentMission.missionID));
	self.currentMission.materialMultiplier = materialMultiplier;
	self.currentMission.goldMultiplier = goldMultiplier;

	self.BonusRewards.ChestModel.OpenAnim:Stop();
	self.BonusRewards.ChestModel.LockBurstAnim:Stop();
	self.BonusRewards.ChestModel:SetAlpha(1);
	for i = 1, #self.BonusRewards.Rewards do
		self.BonusRewards.Rewards[i]:Hide();
	end
	self.BonusRewards.ChestModel.LockBurstAnim:Stop();
	self.ChanceFrame.SuccessChanceInAnim:Stop();
	self.ChanceFrame.ResultAnim:Stop();
	if (mission.state >= 0) then
		-- if the mission is in this state, it's a success
		self.currentMission.succeeded = true;
		self:SetScript("OnUpdate", nil);

		stage.EncountersFrame:Hide();
		self.BonusRewards.Saturated:Show();
		self.BonusRewards.ChestModel.Lock:Hide();
		self.BonusRewards.ChestModel:SetAnimation(0, 0);
		self.BonusRewards.ChestModel.ClickFrame:Show();
		self.ChanceFrame.ChanceText:SetAlpha(0);
		self.ChanceFrame.ResultText:SetText(GARRISON_MISSION_SUCCESS);
		self.ChanceFrame.ResultText:SetTextColor(0.1, 1, 0.1);
		self.ChanceFrame.ResultText:SetAlpha(1);

		self.ChanceFrame.Banner:SetAlpha(1);
		self.ChanceFrame.Banner:SetWidth(GARRISON_MISSION_COMPLETE_BANNER_WIDTH);

		GarrisonMissionComplete_AnimFollowersIn(self);
	else
		stage.ModelMiddle:Hide();
		stage.ModelRight:Hide();
		stage.ModelLeft:Hide();
		self.BonusRewards.Saturated:Hide();
		self.BonusRewards.ChestModel.Lock:SetAlpha(1);
		self.BonusRewards.ChestModel.Lock:Show();
		self.BonusRewards.ChestModel:SetAnimation(148);
		self.BonusRewards.ChestModel.ClickFrame:Hide();		
		self.ChanceFrame.ChanceText:SetAlpha(1);
		self.ChanceFrame.ChanceText:SetFormattedText(GARRISON_MISSION_PERCENT_CHANCE, C_Garrison.GetRewardChance(mission.missionID));
		self.ChanceFrame.ResultText:SetAlpha(0);
		self.ChanceFrame.Banner:SetAlpha(0);
		self.ChanceFrame.Banner:SetWidth(200);
		self.ChanceFrame.SuccessChanceInAnim:Play();		
		PlaySound("UI_Garrison_Mission_Complete_Encounter_Chance");
		C_Garrison.MarkMissionComplete(mission.missionID);
	end
	self.NextMissionButton:Disable();
end

function GarrisonMissionComplete_SetFollowerLevel(followerFrame, level, quality, currXP, maxXP)
	local maxLevel = GarrisonMissionFrame.followerMaxLevel;
	level = min(level, maxLevel);
	if ( maxXP and maxXP > 0 ) then
		followerFrame.XP:SetMinMaxValues(0, maxXP);
		followerFrame.XP:SetValue(currXP);
		followerFrame.XP:Show();
		followerFrame.Name:ClearAllPoints();
		followerFrame.Name:SetPoint("LEFT", 58, 6);
	else
		followerFrame.XP:Hide();
		followerFrame.Name:ClearAllPoints();		
		followerFrame.Name:SetPoint("LEFT", 58, 0);
	end
	followerFrame.XP.level = level;
	followerFrame.XP.quality = quality;
	followerFrame.PortraitFrame.Level:SetText(level);
	local color = ITEM_QUALITY_COLORS[quality];
    followerFrame.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
	followerFrame.PortraitFrame.PortraitRingQuality:SetVertexColor(color.r, color.g, color.b);
end

function GarrisonMissionComplete_SetNumEncounters(numEncounters)
	local self = GarrisonMissionFrame.MissionComplete.Stage.EncountersFrame;
	self.numEncounters = numEncounters;

	for i = 1, 3 do
		local encounter = self["Encounter"..i];
		if ( i <= numEncounters ) then
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
		else
			encounter:Hide();
		end
	end
	self.Encounter1:SetPoint("BOTTOM", -77 * (numEncounters - 1), -40);
end

function GarrisonMissionCompleteReward_OnClick(self)
	self:SetScript("OnEvent", GarrisonMissionCompleteReward_OnEvent);
	self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT");
	local missionList = GarrisonMissionFrame.MissionComplete.completeMissions;
	local missionIndex = GarrisonMissionFrame.MissionComplete.currentIndex;
	C_Garrison.MissionBonusRoll(missionList[missionIndex].missionID);
end

function GarrisonMissionCompleteReward_OnEvent(self, event, ...)
	if (event == "GARRISON_MISSION_BONUS_ROLL_LOOT") then
		local itemID = ...;
		local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID);
		local reward = self:GetParent();
		reward.Chest:Hide();
		reward.itemID = itemID;
		reward.Icon:SetTexture(itemTexture);
		reward.Name:SetText(ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE);
		reward.Icon:Show();
		reward.Name:Show();
		reward.BG:Show();
		self:SetScript("OnEvent", nil);
		self:UnregisterEvent("GARRISON_MISSION_BONUS_ROLL_LOOT");
	end
end

function GarrisonMissionCompleteNextButton_OnClick(self)
	PlaySound("UI_Garrison_CommandTable_Nav_Next");
	local frame = GarrisonMissionFrame.MissionComplete;
	
	if ( not MissionCompletePreload_IsReady() ) then
		frame.NextMissionButton:SetEnabled(false);
		frame.LoadingFrame:Show();
		MissionCompletePreload_StartTimeout(GARRISON_MODEL_PRELOAD_TIME, GarrisonMissionCompleteNextButton_OnClick);
		return;
	end
	
	frame.currentIndex = frame.currentIndex + 1;
	GarrisonMissionComplete_Initialize(frame.completeMissions, frame.currentIndex);
end

function GarrisonMissionCompleteChest_OnMouseDown(self)
	GarrisonMissionFrame.MissionComplete.NextMissionButton:Enable();
	if ( C_Garrison.CanOpenMissionChest(GarrisonMissionFrame.MissionComplete.currentMission.missionID) ) then
		-- hide the click frame
		self:Hide();

		local bonusRewards = GarrisonMissionFrame.MissionComplete.BonusRewards;
		bonusRewards.waitForEvent = true;
		bonusRewards.waitForTimer = true;
		bonusRewards.success = false;
		bonusRewards:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE");
		bonusRewards.ChestModel:SetAnimation(154);
		bonusRewards.ChestModel.OpenAnim:Play();
		C_Timer.After(1.1, GarrisonMissionComplete_OnRewardTimer);
		C_Garrison.MissionBonusRoll(GarrisonMissionFrame.MissionComplete.currentMission.missionID);
		PlaySound("UI_Garrison_CommandTable_ChestUnlock_Gold_Success");
		GarrisonMissionFrame.MissionComplete.NextMissionButton:Disable();
	end
end

function GarrisonMissionCompleteChest_OnEnter(self)
	if ( C_Garrison.CanOpenMissionChest(GarrisonMissionFrame.MissionComplete.currentMission.missionID) ) then
		SetCursor("INTERACT_CURSOR");
	end
end

function GarrisonMissionCompleteChest_OnLeave(self)
	ResetCursor();
end

function GarrisonMissionComplete_OnRewardTimer()
	local self = GarrisonMissionFrame.MissionComplete.BonusRewards;
	self.waitForTimer = nil;
	if ( not self.waitForEvent ) then
		GarrisonMissionComplete_ShowRewards(self);
	end
end

function GarrisonMissionComplete_OnRewardEvent(self, event, ...)
	local missionID, success = ...;
	if ( GarrisonMissionFrame.MissionComplete.currentMission and GarrisonMissionFrame.MissionComplete.currentMission.missionID == missionID ) then
		self:UnregisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE");
		self.waitForEvent = nil;
		self.success = success;
		if ( not self.waitForTimer ) then
			GarrisonMissionComplete_ShowRewards(self);
		end
	end
end

function GarrisonMissionComplete_ShowRewards(self)
	GarrisonMissionFrame.MissionComplete.NextMissionButton:Enable();
	if ( not self.success ) then
		return;
	end

	local currentMission = GarrisonMissionFrame.MissionComplete.currentMission;

	local numRewards = currentMission.numRewards;
	local index = 1;
	for id, reward in pairs(currentMission.rewards) do
		if (not self.Rewards[index]) then
			self.Rewards[index] = CreateFrame("Frame", nil, self, "GarrisonMissionPageRewardTemplate");
			self.Rewards[index]:SetPoint("RIGHT", self.Rewards[index-1], "LEFT", -9, 0);
		end
		local Reward = self.Rewards[index];
		Reward.id = id;
		Reward.Icon:Show();
		Reward.BG:Show();
		Reward.Name:Show();
		GarrisonMissionPage_SetReward(self.Rewards[index], reward);
		Reward.Anim:Play();
		index = index + 1;
	end
	for i = (numRewards + 1), #self.Rewards do
		self.Rewards[i]:Hide();
	end
	GarrisonMissionPage_UpdateRewardQuantities(self, currentMission.materialMultiplier, currentMission.goldMultiplier);

	self.Rewards[1]:ClearAllPoints();
	if (numRewards == 1) then
		self.Rewards[1]:SetPoint("CENTER", self, "CENTER", 0, 0);
	elseif (numRewards == 2) then
		self.Rewards[1]:SetPoint("LEFT", self, "CENTER", 5, 0);
	else
		self.Rewards[1]:SetPoint("RIGHT", self, "RIGHT", -18, 0);
	end
end

---------------------------------------------------------------------------------
--- Mission Complete: Animation stuff                                         ---
---------------------------------------------------------------------------------

GARRISON_ANIMATION_LENGTH = 1;

function GarrisonMissionComplete_AnimLine(self, entry)
	GarrisonMissionComplete_SetEncounterModels(self);
	entry.duration = 0.5;

	local encountersFrame = self.Stage.EncountersFrame;
	local mechanicsFrame = self.Stage.EncountersFrame.MechanicsFrame;
	local numMechs = 0;
	local playCounteredSound = false;
	for id, mechanic in pairs(encountersFrame.enemies[self.encounterIndex].mechanics) do
		numMechs = numMechs + 1;	
		if (not mechanicsFrame.Mechanics[numMechs]) then
			mechanicsFrame.Mechanics[numMechs] = CreateFrame("Frame", nil, mechanicsFrame, "GarrisonMissionEnemyMechanicTemplate");
			mechanicsFrame.Mechanics[numMechs]:SetPoint("LEFT", mechanicsFrame.Mechanics[numMechs-1], "RIGHT", 12, 0);
		end
		local Mechanic = mechanicsFrame.Mechanics[numMechs];
		Mechanic.info = mechanic;
		Mechanic.Icon:SetTexture(mechanic.icon);
		Mechanic.mechanicID = id;
		Mechanic:Show();
		-- counter
		local countered = true;
		for index, mechanicID in pairs(encountersFrame.uncounteredMechanics[self.encounterIndex]) do
			if ( mechanicID == id ) then
				countered = false;
				break;
			end
		end
		if ( countered ) then
			Mechanic.Check:Show();
			playCounteredSound = true;
		else
			Mechanic.Check:Hide();
		end
	end
	for j=(numMechs + 1), #mechanicsFrame.Mechanics do
		mechanicsFrame.Mechanics[j]:Hide();
		mechanicsFrame.Mechanics[j].mechanicID = nil;
		mechanicsFrame.Mechanics[j].info = nil;
	end
	if ( playCounteredSound ) then
		PlaySound("UI_Garrison_Mission_Threat_Countered");
	end
	mechanicsFrame:SetParent(encountersFrame.Encounters[self.encounterIndex]);
	mechanicsFrame:SetPoint("BOTTOM", encountersFrame.Encounters[self.encounterIndex], (numMechs - 1) * -16, -5);
	encountersFrame.Encounters[self.encounterIndex].CheckFrame:SetFrameLevel(mechanicsFrame:GetFrameLevel() + 1);
	encountersFrame.Encounters[self.encounterIndex].GlowFrame.OnAnim:Play();
	encountersFrame.Encounters[self.encounterIndex].Name:Show();
	if ( self.encounterIndex > 1 ) then
		encountersFrame.Encounters[self.encounterIndex - 1].GlowFrame.OffAnim:Play();
		encountersFrame.Encounters[self.encounterIndex - 1].Name:Hide();
	end
end

function GarrisonMissionComplete_AnimCheckModels(self, entry)
	self.animNumModelHolds = 0;
	local modelLeft = self.Stage.ModelLeft;
	if ( modelLeft.state == "loading" ) then
		self.animNumModelHolds = self.animNumModelHolds + 1;
	end
	local modelRight = self.Stage.ModelRight;
	if ( modelRight.state == "loading" ) then
		self.animNumModelHolds = self.animNumModelHolds + 1;
	end

	if ( self.animNumModelHolds == 0 ) then
		entry.duration = 0;
	else
		-- wait a little more for models to finish loading	
		entry.duration = 1;
	end
end

function GarrisonMissionComplete_AnimModels(self, entry)
	self.animNumModelHolds = nil;
	local modelLeft = self.Stage.ModelLeft;
	local modelRight = self.Stage.ModelRight;
	local currentAnim = self.animInfo[self.encounterIndex];
	currentAnim.playImpactSound = false;
	-- if enemy model is still loading, ignore it
	if ( modelRight.state == "loading" ) then
		modelRight.state = "empty";
	end
	-- but we must have follower model
	if ( modelLeft.state == "loaded" ) then
		-- play models
		modelLeft:InitializePanCamera(currentAnim.scale or 1)
		modelLeft:SetHeightFactor(currentAnim.height or 0.5);
		if ( self.currentMission.failedEncounter == self.encounterIndex ) then
			-- always same pose on fail
			modelLeft:StartPan(LE_PAN_NONE_RANGED, GARRISON_ANIMATION_LENGTH, true, currentAnim.castID);
		else
			modelLeft:StartPan(currentAnim.movementType or LE_PAN_NONE, GARRISON_ANIMATION_LENGTH, true, currentAnim.castID);
			if ( currentAnim.impactSoundID ) then
				currentAnim.playImpactSound = true;
			end
		end
		PlaySound("UI_Garrison_MissionEncounter_Animation_Generic");		
		if ( currentAnim.castSoundID ) then
			PlaySoundKitID(currentAnim.castSoundID);
		end
		-- enemy model is optional
		if ( modelRight.state == "loaded" ) then
			modelRight:InitializePanCamera(currentAnim.enemyScale or 1);
			modelRight:SetHeightFactor(currentAnim.enemyHeight or 0.5);
			modelRight:SetAnimOffset(currentAnim.impactDelay  or 0);
			if ( self.currentMission.failedEncounter == self.encounterIndex ) then
				-- skip the impact on fail
				modelRight:StartPan(LE_PAN_NONE, GARRISON_ANIMATION_LENGTH, true);
				-- play the miss
				self.Stage.Miss.Anim.WaitAlpha:SetDuration(currentAnim.impactDelay);
				self.Stage.Miss.Anim:Play();
			else
				modelRight:StartPan(LE_PAN_NONE, GARRISON_ANIMATION_LENGTH, true, currentAnim.impactID);
			end
		end
		if ( currentAnim.playImpactSound ) then
			entry.duration = currentAnim.impactDelay;
		else
			entry.duration = 0.9;
		end
	else
		-- no models, skip
		entry.duration = 0;
	end
end

function GarrisonMissionComplete_AnimPlayImpactSound(self, entry)
	local currentAnim = self.animInfo[self.encounterIndex];
	if ( currentAnim.playImpactSound ) then
		PlaySoundKitID(currentAnim.impactSoundID);
		entry.duration = 0.9 - currentAnim.impactDelay;
	else
		entry.duration = 0;
	end
end

function GarrisonMissionComplete_AnimPortrait(self, entry)
	local encounter = self.Stage.EncountersFrame.Encounters[self.encounterIndex];
	if ( self.currentMission.succeeded ) then
		encounter.CheckFrame.SuccessAnim:Play();
	else
		if ( self.currentMission.failedEncounter == self.encounterIndex ) then
			encounter.CheckFrame.FailureAnim:Play();
			PlaySound("UI_Garrison_Mission_Complete_Encounter_Fail");
		else
			encounter.CheckFrame.SuccessAnim:Play();
			PlaySound("UI_Garrison_Mission_Complete_Mission_Success");
		end
	end
	entry.duration = 0.5;
end

function GarrisonMissionComplete_AnimCheckEncounters(self, entry)
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

function GarrisonMissionComplete_AnimFollowersIn(self, entry)
	local missionList = self.completeMissions;
	local missionIndex = self.currentIndex;
	local mission = missionList[missionIndex];

	local numFollowers = #mission.followers;
	GarrisonMissionComplete_SetNumFollowers(numFollowers);
	GarrisonMissionComplete_SetupEnding(numFollowers);
	local stage = self.Stage;
	if (stage.ModelLeft:IsShown()) then
		stage.ModelLeft.FadeIn:Play();		-- no OnFinished
	end
	if (stage.ModelRight:IsShown()) then
		stage.ModelRight.FadeIn:Play();		-- no OnFinished
	end
	if (stage.ModelMiddle:IsShown()) then
		stage.ModelMiddle.FadeIn:Play();	-- no OnFinished
	end
	for i = 1, numFollowers do
		local followerFrame = stage.FollowersFrame.Followers[i];
		followerFrame.XPGain:SetAlpha(0);
		followerFrame.LevelUpFrame:Hide();
	end
	stage.FollowersFrame.FadeIn:Stop();
	stage.FollowersFrame.FadeIn:Play();
	-- preload next set
	local nextIndex = self.currentIndex + 1;
	if ( missionList[nextIndex] ) then
		MissionCompletePreload_LoadMission(missionList[nextIndex].missionID);
	end
end

function GarrisonMissionComplete_AnimRewards(self, entry)
	self.BonusRewards.Saturated:Show();
	self.BonusRewards.Saturated.FadeIn:Play();

	if ( self.currentMission.succeeded ) then
		self.ChanceFrame.ResultText:SetText(GARRISON_MISSION_SUCCESS);
		self.ChanceFrame.ResultText:SetTextColor(0.1, 1, 0.1);
		self.ChanceFrame.ResultAnim:Play();
		self.BonusRewards.ChestModel:SetAnimation(0, 0);
		PlaySound("UI_Garrison_CommandTable_MissionSuccess_Stinger");
	else
		self.ChanceFrame.ResultText:SetText(GARRISON_MISSION_FAILED);
		self.ChanceFrame.ResultText:SetTextColor(1, 0.1, 0.1);
		self.ChanceFrame.ResultAnim:Play();
		self.NextMissionButton:Enable();
		PlaySound("UI_Garrison_Mission_Complete_MissionFail_Stinger");
	end
end

function GarrisonMissionComplete_AnimXP(self, entry)
	for i = 1, #self.currentMission.followers do
		GarrisonMissionComplete_CheckAndShowFollowerXP(self.currentMission.followers[i]);
	end
end

function GarrisonMissionComplete_AnimLockBurst(self, entry)
	if ( self.currentMission.succeeded ) then
		self.BonusRewards.ChestModel.LockBurstAnim:Play();
		PlaySound("UI_Garrison_CommandTable_ChestUnlock");
		if ( C_Garrison.CanOpenMissionChest(self.currentMission.missionID) ) then
			self.BonusRewards.ChestModel.ClickFrame:Show();
		end
	else
		self.NextMissionButton:Enable();
	end
end

-- if duration is nil it will be set in the onStart function
-- duration is irrelevant for the last entry
local ANIMATION_CONTROL = {
	[1] = { duration = nil,		onStartFunc = GarrisonMissionComplete_AnimLine },					-- line between encounters
	[2] = { duration = nil,		onStartFunc = GarrisonMissionComplete_AnimCheckModels },			-- check that models are loaded
	[3] = { duration = nil,		onStartFunc = GarrisonMissionComplete_AnimModels },					-- model fight
	[4] = { duration = nil,		onStartFunc = GarrisonMissionComplete_AnimPlayImpactSound },		-- impact sound when follower hits
	[5] = { duration = 0.45,	onStartFunc = GarrisonMissionComplete_AnimPortrait },				-- X over portrait
	[6] = { duration = nil,		onStartFunc = GarrisonMissionComplete_AnimCheckEncounters },		-- evaluate whether to do next encounter or move on
	[7] = { duration = 0.75,	onStartFunc = GarrisonMissionComplete_AnimRewards },				-- reward panel
	[8] = { duration = 0,		onStartFunc = GarrisonMissionComplete_AnimLockBurst },				-- explode the lock if mission successful	
	[9] = { duration = 0.5,		onStartFunc = GarrisonMissionComplete_AnimFollowersIn },			-- show all the mission followers
	[10] = { duration = 0,		onStartFunc = GarrisonMissionComplete_AnimXP },						-- follower xp
};

function GarrisonMissionComplete_FindAnimIndexFor(func)
	for i = 1, #ANIMATION_CONTROL do
		if ( ANIMATION_CONTROL[i].onStartFunc == func ) then
			return i;
		end
	end
	return 0;
end

function GarrisonMissionComplete_BeginAnims(self, animIndex)
	self.encounterIndex = 1;
	self.animIndex = animIndex or 0;
	self.animTimeLeft = 0;
	self:SetScript("OnUpdate", GarrisonMissionComplete_OnUpdate);
end

function GarrisonMissionComplete_OnUpdate(self, elapsed)
	self.animTimeLeft = self.animTimeLeft - elapsed;
	if ( self.animTimeLeft <= 0 ) then
		self.animIndex = self.animIndex + 1;
		local entry = ANIMATION_CONTROL[self.animIndex];
		if ( entry ) then
			entry.onStartFunc(self, entry);
			self.animTimeLeft = entry.duration;
		else
			-- done
			self:SetScript("OnUpdate", nil);
		end
	end
end

function GarrisonMissionComplete_OnModelLoaded(self)
	-- making sure we didn't give up on loading this model
	if ( self.state == "loading" ) then
		self.state = "loaded";
		-- is the anim paused for models?
		local frame = GarrisonMissionFrame.MissionComplete;
		if ( frame.animNumModelHolds ) then
			frame.animNumModelHolds = frame.animNumModelHolds - 1;
			-- no models left to load, full speed ahead
			if ( frame.animNumModelHolds == 0 ) then
				frame.animTimeLeft = 0;
			end
		end
	end
end

function GarrisonMissionComplete_SetEncounterModels(self)
	local modelLeft = self.Stage.ModelLeft;
	modelLeft:SetAlpha(0);	
	modelLeft:Show();
	modelLeft:ClearModel();

	local modelRight = self.Stage.ModelRight;	
	modelRight:SetAlpha(0);	
	modelRight:Show();
	modelRight:ClearModel();

	if ( self.animInfo and self.encounterIndex and self.animInfo[self.encounterIndex] ) then
		local currentAnim = self.animInfo[self.encounterIndex];
		modelLeft.state = "loading";
		GarrisonMission_SetFollowerModel(modelLeft, currentAnim.followerID, currentAnim.displayID);		
		if ( currentAnim.enemyDisplayID ) then
			modelRight.state = "loading";
			modelRight:SetDisplayInfo(currentAnim.enemyDisplayID);
		else
			modelRight.state = "empty";
		end
	else
		modelLeft.state = "empty";
		modelRight.state = "empty";
	end
end

---------------------------------------------------------------------------------
--- Mission Complete: XP stuff				                                  ---
---------------------------------------------------------------------------------

function GarrisonMissionComplete_AwardFollowerXP(followerFrame, xpAward)
	local xpBar = followerFrame.XP;
	local xpFrame = followerFrame.XPGain;
	-- xp text
	xpFrame:Show();
	xpFrame.FadeIn:Play();
	xpFrame.Text:SetFormattedText(XP_GAIN, BreakUpLargeNumbers(xpAward));
	-- bar
	local _, maxXP = xpBar:GetMinMaxValues();
	if ( xpBar:GetValue() + xpAward >  maxXP ) then
		xpBar.toGoXP = maxXP - xpBar:GetValue();
		xpBar.remainingXP = xpAward - xpBar.toGoXP;
	else
		xpBar.toGoXP = xpAward;
		xpBar.remainingXP = 0;
	end
	followerFrame.activeAnims = 2;	-- text & bar
	GarrisonMissionComplete_AnimXPBar(xpBar);
end

function GarrisonMissionComplete_AnimFollowerXP(followerID, xpAward, oldXP, oldLevel, oldQuality)
	local self = GarrisonMissionFrame.MissionComplete;
	local missionList = self.completeMissions;
	local missionIndex = self.currentIndex;
	local mission = missionList[missionIndex];
	
	if (not mission) then
		return;
	end

	for i = 1, #mission.followers do
		local followerFrame = self.Stage.FollowersFrame.Followers[i];
		if ( followerFrame.followerID == followerID ) then
			-- play anim now if we finished animating followers in
			local animIndex = GarrisonMissionComplete_FindAnimIndexFor(GarrisonMissionComplete_AnimFollowersIn);
			if ( self.animIndex and self.animIndex > animIndex and (not followerFrame.activeAnims or followerFrame.activeAnims == 0) ) then
				if ( xpAward > 0 ) then
					GarrisonMissionComplete_SetFollowerLevel(followerFrame, oldLevel, oldQuality, oldXP, GarrisonMissionFrame_GetFollowerNextLevelXP(oldLevel, oldQuality));
					GarrisonMissionComplete_AwardFollowerXP(followerFrame, xpAward);
				else
					-- lost xp, no anim
					local _, _, level, quality, currXP, maxXP = C_Garrison.GetFollowerMissionCompleteInfo(followerID);
					GarrisonMissionComplete_SetFollowerLevel(followerFrame, level, quality, currXP, maxXP);
				end
			else
				-- save for later
				local t = {};
				t.followerID = followerID;
				t.xpAward = xpAward;
				t.oldXP = oldXP;
				t.oldLevel = oldLevel;
				t.oldQuality = oldQuality;
				tinsert(self.pendingXPAwards, t);
			end
			break;
		end
	end
end

function GarrisonMissionComplete_AnimXPBar(xpBar)
	xpBar.timeIn = 0;
	xpBar.startXP = xpBar:GetValue();
	local _, maxXP = xpBar:GetMinMaxValues();
	xpBar.duration = xpBar.toGoXP / maxXP * xpBar.length / 25;
	xpBar:SetScript("OnUpdate", GarrisonMissionComplete_AnimXPBar_OnUpdate);
end

function GarrisonMissionComplete_AnimXPBar_OnUpdate(self, elapsed)
	self.timeIn = self.timeIn + elapsed;
	if ( self.timeIn >= self.duration ) then
		self.timeIn = nil;
		self:SetScript("OnUpdate", nil);
		self:SetValue(self.startXP + self.toGoXP);
		GarrisonMissionComplete_AnimXPBarOnFinish(self);
	else
		self:SetValue(self.startXP + (self.timeIn / self.duration) * self.toGoXP);
	end
	
end

function GarrisonMissionComplete_AnimXPBarOnFinish(xpBar)
	local _, maxXP = xpBar:GetMinMaxValues();
	if ( xpBar:GetValue() == maxXP ) then
		-- leveled up!
		local followerFrame = xpBar:GetParent();
		local levelUpFrame = followerFrame.LevelUpFrame;
		if ( not levelUpFrame:IsShown() ) then
			levelUpFrame:Show();
			levelUpFrame:SetAlpha(1);
			levelUpFrame.Anim:Play();
		end
		
		local maxLevel = GarrisonMissionFrame.followerMaxLevel;
		local nextLevel, nextQuality;
		if ( xpBar.level == maxLevel ) then
			-- at max level progress the quality
			nextLevel = xpBar.level;
			nextQuality = xpBar.quality + 1;
			-- and cap it to the max attainable via xp	
			nextQuality = min(nextQuality, GarrisonMissionFrame.followerMaxQuality);
		else
			nextLevel = xpBar.level + 1;
			nextQuality = xpBar.quality;
		end
	
		local nextLevelXP = GarrisonMissionFrame_GetFollowerNextLevelXP(nextLevel, nextQuality);
		GarrisonMissionComplete_SetFollowerLevel(followerFrame, nextLevel, nextQuality, 0, nextLevelXP);
		if ( nextLevelXP ) then
			maxXP = nextLevelXP;
		else
			-- ensure we're done
			xpBar.remainingXP = 0;
		end
		-- visual
		local models = GarrisonMissionFrame.MissionComplete.Stage.Models;
		for i = 1, #models do
			if ( models[i].followerID == followerFrame.followerID and models[i]:IsShown() ) then
				models[i]:SetSpellVisualKit(6375);	-- level up visual
				PlaySound("UI_Garrison_CommandTable_Follower_LevelUp");
				break;
			end
		end
	end
	if ( xpBar.remainingXP > 0 ) then
		-- we still have XP to go
		local availableXP = maxXP - xpBar:GetValue();
		if ( xpBar.remainingXP > availableXP ) then
			xpBar.toGoXP = availableXP;
			xpBar.remainingXP = xpBar.remainingXP - availableXP;
		else
			xpBar.toGoXP = xpBar.remainingXP;
			xpBar.remainingXP = 0;
		end
		GarrisonMissionComplete_AnimXPBar(xpBar);
	else
		GarrisonMissionComplete_OnFollowerXPFinished(xpBar:GetParent());
	end
end

function GarrisonMissionComplete_AnimXPGainOnFinish(self)
	GarrisonMissionComplete_OnFollowerXPFinished(self:GetParent():GetParent());
end

function GarrisonMissionComplete_OnFollowerXPFinished(followerFrame)
	followerFrame.activeAnims = followerFrame.activeAnims - 1;
	if ( followerFrame.activeAnims == 0 ) then
		GarrisonMissionComplete_CheckAndShowFollowerXP(followerFrame.followerID);
	end
end

function GarrisonMissionComplete_CheckAndShowFollowerXP(followerID)
	local pendingXPAwards = GarrisonMissionFrame.MissionComplete.pendingXPAwards;
	for k, v in pairs(pendingXPAwards) do
		if ( v.followerID == followerID ) then
			GarrisonMissionComplete_AnimFollowerXP(v.followerID, v.xpAward, v.oldXP, v.oldLevel, v.oldQuality);
			tremove(pendingXPAwards, k);
			return;
		end
	end
end

---------------------------------------------------------------------------------
--- Mission Complete: Follower pose stuff                                     ---
---------------------------------------------------------------------------------

function GarrisonMissionComplete_ShowEnding()
	local self = GarrisonMissionFrame.MissionComplete;
	
	self.Stage.EncountersFrame.FadeOut:Play();
end

local ENDINGS = {
	[1] = { ["ModelMiddle"] = { dist = 0, facing = 0.1, followerIndex = 1 },
			["ModelLeft"] = { hidden = true },	
			["ModelRight"] = { hidden = true },
	},
	[2] = { ["ModelMiddle"] = { hidden = true },
			["ModelLeft"] = { dist = 0.2, facing = -0.2, followerIndex = 1 },	
			["ModelRight"] = { dist = 0.2, facing = 0.2, followerIndex = 2 },
	},
	[3] = { ["ModelMiddle"] = { dist = 0, facing = 0.1, followerIndex = 2 },
			["ModelLeft"] = { dist = 0.25, facing = -0.3, followerIndex = 1 },	
			["ModelRight"] = { dist = 0.275, facing = 0.3, followerIndex = 3 },
	},
	[4] = { ["ModelMiddle"] = { hidden = true },
			["ModelLeft"] = { dist = 0.1, facing = -0.2, followerIndex = 2 },
			["ModelRight"] = { dist = 0.1, facing = 0.2, followerIndex = 3 },
	},
	[5] = { ["ModelMiddle"] = { dist = 0, facing = 0.1, followerIndex = 3 },
			["ModelLeft"] = { dist = 0.15, facing = -0.4, followerIndex = 2 },
			["ModelRight"] = { dist = 0.15, facing = 0.4, followerIndex = 4 },
	},
};

function GarrisonMissionComplete_SetupEnding(numFollowers)
	local ending = ENDINGS[numFollowers];
	local stage = GarrisonMissionFrame.MissionComplete.Stage;
	for model, data in pairs(ending) do
		local modelFrame = stage[model];
		if ( data.hidden ) then
			modelFrame:Hide();
		else
			modelFrame:Show();
			modelFrame:SetAlpha(1);
			modelFrame:SetTargetDistance(data.dist);
			modelFrame:SetFacing(data.facing);
			local followerInfo = stage.followers[data.followerIndex];
			GarrisonMission_SetFollowerModel(modelFrame, followerInfo.followerID, followerInfo.displayID);
			modelFrame:SetHeightFactor(followerInfo.height);
			modelFrame:InitializeCamera(followerInfo.scale);	
		end
	end
end

function GarrisonMissionComplete_SetNumFollowers(size)
	local followersFrame = GarrisonMissionFrame.MissionComplete.Stage.FollowersFrame;
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


---------------------------------------------------------------------------------
--- Mission Complete: Stage Stuff                                             ---
---------------------------------------------------------------------------------

function GarrisonMissionCompleteStage_OnLoad(self)
	self.LocBack:SetAtlas("_GarrMissionLocation-TannanJungle-Back", true);
	self.LocMid:SetAtlas ("_GarrMissionLocation-TannanJungle-Mid", true);
	self.LocFore:SetAtlas("_GarrMissionLocation-TannanJungle-Fore", true);
	local _, backWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Back");
	local _, midWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Mid");
	local _, foreWidth = GetAtlasInfo("_GarrMissionLocation-TannanJungle-Fore");
	local texWidth = self.LocBack:GetWidth();
	self.LocBack:SetTexCoord(0, texWidth/backWidth,  0, 1);
	self.LocMid:SetTexCoord (0, texWidth/midWidth, 0, 1);
	self.LocFore:SetTexCoord(0, texWidth/foreWidth, 0, 1);
end

--parallax rates in % texCoords per second
local rateBack = 0.1; 
local rateMid = 0.3;
local rateFore = 0.8;

function GarrisonMissionStage_OnUpdate(self, elapsed)
	local changeBack = rateBack/100 * elapsed;
	local changeMid = rateMid/100 * elapsed;
	local changeFore = rateFore/100 * elapsed;
	
	local backL, _, _, _, backR = self.LocBack:GetTexCoord();
	local midL, _, _, _, midR = self.LocMid:GetTexCoord();
	local foreL, _, _, _, foreR = self.LocFore:GetTexCoord();
	
	backL = backL + changeBack;
	backR = backR + changeBack;
	midL = midL + changeMid;
	midR = midR + changeMid;
	foreL = foreL + changeFore;
	foreR = foreR + changeFore;
	
	if (backL >= 1) then
		backL = backL - 1;
		backR = backR - 1;
	end
	if (midL >= 1) then
		midL = midL - 1;
		midR = midR - 1;
	end
	if (foreL >= 1) then
		foreL = foreL - 1;
		foreR = foreR - 1;
	end
	
	self.LocBack:SetTexCoord(backL, backR, 0, 1);
	self.LocMid:SetTexCoord (midL, midR, 0, 1);
	self.LocFore:SetTexCoord(foreL, foreR, 0, 1);
end

---------------------------------------------------------------------------------
--- Mission Complete: Preloading Models	                                      ---
---------------------------------------------------------------------------------

local PRELOADING_NUM_MODELS = 0;
local PRELOADING_MISSION_ID = 0;

function MissionCompletePreload_LoadMission(missionID)
	if ( missionID == PRELOADING_MISSION_ID ) then
		return;		
	end

	PRELOADING_MISSION_ID = missionID;
	local displayIDs = C_Garrison.GetMissionDisplayIDs(missionID);
	local models = GarrisonMissionFrame.MissionTab.MissionCompletePreloadModels;
	-- clean up if needed
	if ( PRELOADING_NUM_MODELS > 0 ) then
		MissionCompletePreload_Cancel();
	end
	-- load models
	PRELOADING_NUM_MODELS = #displayIDs;
	for i = 1, PRELOADING_NUM_MODELS do
		local model = models[i];
		model.loading = true;
		model:SetDisplayInfo(displayIDs[i]);
	end
end

function MissionCompletePreload_Cancel()
	local models = GarrisonMissionFrame.MissionTab.MissionCompletePreloadModels;
	for i = 1, #models do
		models[i].loading = nil;
		models[i]:ClearModel();
	end
	PRELOADING_NUM_MODELS = 0;
	PRELOADING_MISSION_ID = 0;
	models[1]:SetScript("OnUpdate", nil);
end

function MissionCompletePreload_IsReady()
	return PRELOADING_NUM_MODELS == 0;
end

function MissionCompletePreload_OnModelLoaded(self)
	if ( self.loading ) then
		self.loading = nil;
		PRELOADING_NUM_MODELS = PRELOADING_NUM_MODELS - 1;
	end
end

function MissionCompletePreload_OnUpdate(self, elapsed)
	if ( PRELOADING_NUM_MODELS == 0 ) then
		self:SetScript("OnUpdate", nil);
		self.callbackFunc();
	else
		self.waitTime = self.waitTime - elapsed;
		if ( self.waitTime <= 0 ) then
			MissionCompletePreload_Cancel();
			self.callbackFunc();
		end
	end
end

function MissionCompletePreload_StartTimeout(waitTime, callbackFunc)
	local model = GarrisonMissionFrame.MissionTab.MissionCompletePreloadModels[1];
	model:SetScript("OnUpdate", MissionCompletePreload_OnUpdate);
	model.waitTime = waitTime;
	model.callbackFunc = callbackFunc;
end

---------------------------------------------------------------------------------
--- Enemy Portrait                                                            ---
---------------------------------------------------------------------------------
function GarrisonEnemyPortait_Set(portrait, portraitFileDataID)
	if (portraitFileDataID == nil or portraitFileDataID == 0) then
		-- unknown icon file ID; use the default silhouette portrait
		portrait:SetTexture("Interface\\Garrison\\Portraits\\FollowerPortrait_NoPortrait");
	else
		portrait:SetToFileData(portraitFileDataID);
	end
end
