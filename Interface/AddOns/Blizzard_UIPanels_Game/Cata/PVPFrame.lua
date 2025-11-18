-- PVP Global Lua Constants

WORLD_PVP_TIME_UPDATE_IINTERVAL = 1;

BATTLEFIELD_TIMER_DELAY = 3;
BATTLEFIELD_TIMER_THRESHOLDS = {600, 300, 60, 15};
BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;


CURRENT_BATTLEFIELD_QUEUES = {};
PREVIOUS_BATTLEFIELD_QUEUES = {};

MAX_ARENA_TEAM_MEMBERS_SHOWN = 6;
MAX_ARENA_TEAM_NAME_WIDTH = 310;

MAX_ARENA_TEAM_MEMBER_WIDTH = 320;
MAX_ARENA_TEAM_MEMBER_SCROLL_WIDTH = 300;

NUM_DISPLAYED_BATTLEGROUNDS = 5;

NO_ARENA_SEASON = 0;


BG_BUTTON_WIDTH = 320;
BG_BUTTON_SCROLL_WIDTH = 298;

WARGAME_HEADER_HEIGHT = 16;
WARGAME_BUTTON_HEIGHT = 40;


local PVPHONOR_TEXTURELIST = {};
PVPHONOR_TEXTURELIST[1] = "Interface\\PVPFrame\\PvpBg-AlteracValley";
PVPHONOR_TEXTURELIST[2] = "Interface\\PVPFrame\\PvpBg-WarsongGulch";
PVPHONOR_TEXTURELIST[3] = "Interface\\PVPFrame\\PvpBg-ArathiBasin";
PVPHONOR_TEXTURELIST[7] = "Interface\\PVPFrame\\PvpBg-EyeOfTheStorm";
PVPHONOR_TEXTURELIST[9] = "Interface\\PVPFrame\\PvpBg-StrandOfTheAncients";
PVPHONOR_TEXTURELIST[30] = "Interface\\PVPFrame\\PvpBg-IsleOfConquest";
PVPHONOR_TEXTURELIST[32] = "Interface\\PVPFrame\\PvpRandomBg";
PVPHONOR_TEXTURELIST[108] = "Interface\\PVPFrame\\PvpBg-TwinPeaks";
PVPHONOR_TEXTURELIST[120] = "Interface\\PVPFrame\\PvpBg-Gilneas";
PVPHONOR_TEXTURELIST[1089] = "Interface\\PVPFrame\\PvpBg-Wintergrasp";
PVPHONOR_TEXTURELIST[1116] = "Interface\\PVPFrame\\PvpBg-TolBarad";

ARENABANNER_SMALLFONT = "GameFontNormalSmall"


function PVPFrame_ExpansionSpecificOnLoad(self)
	PanelTemplates_SetNumTabs(self, 4)
	PVPFrame_TabClicked(PVPFrameTab1);
	SetPortraitToTexture(PVPFramePortrait,"Interface\\BattlefieldFrame\\UI-Battlefield-Icon");
	
	self:RegisterEvent("UNIT_LEVEL");
	
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");

	self:RegisterEvent("WARGAME_REQUESTED");
	self:RegisterEvent("PVP_REWARDS_UPDATE");
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("BATTLEFIELDS_CLOSED");
	self:RegisterEvent("PVP_TYPES_ENABLED");
	
	PVPFrame.timerDelay = 0;
end

function PVPFrame_OnShow()
	if ( not GetCurrentArenaSeasonUsesTeams() ) then
		RequestRatedInfo();
	end

	PVPFrame_Update();
	UpdateMicroButtons();
	SetPortraitTexture(PVPFramePortrait, "player");
	PVPFrame_TabClicked(PVPFrameTab1);

	RequestPVPRewards();
	RequestPVPOptionsEnabled();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	PVPFrame_UpdateSelectedRoles();

	PVPFrameLeftButton_RightSeparator:Hide();
end

function PVPFrame_OnHide()
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	ClearBattlemaster();
end

function PVPFrame_ExpansionSpecificOnEvent(self, event, ...)
	if  event == "PLAYER_ENTERING_WORLD" then
		HonorFrameSpecificList_Update();
		BattlefieldFrame_UpdateStatus(false, nil);
		PVPFrame_UpdateSelectedRoles();
	elseif event == "CURRENCY_DISPLAY_UPDATE" then
		PVPFrame_UpdateCurrency(self);
		if ( self:IsShown() ) then
			RequestPVPRewards();
		end
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED") then
		local arg1 = ...
		BattlefieldFrame_UpdateStatus(false, arg1);
	elseif ( event == "PVP_REWARDS_UPDATE" ) then
		PVPFrame_UpdateCurrency(self);
	elseif ( event == "WARGAME_REQUESTED" ) then
		local challengerName, bgName, timeout = ...;
		PVPFramePopup_SetupPopUp(event, challengerName, bgName, timeout);
	elseif ( event == "PARTY_LEADER_CHANGED" ) then

	elseif ( event == "PVP_RATED_STATS_UPDATE" ) then
		HonorFrameSpecificList_Update();
		PVPFrame_UpdateCurrency(self);
	elseif ( event == "BATTLEFIELDS_SHOW" and not IsBattlefieldArena() ) then
		ShowUIPanel(PVPFrame);
		local isArena, bgID = ...;
		if (isArena) then
			PVPFrameTab2:Click();
		else
			PVPFrameTab1:Click();
			HonorFrameSpecificList_Update();
			HonorFrameSpecificList_FindAndSelectBattleground(bgID);
		end
	elseif ( event == "BATTLEFIELDS_CLOSED" )  then
		if self:IsShown() then
			TogglePVPFrame();
		end
	elseif ( event == "PVP_TYPES_ENABLED" )  then
		self.wargamesEnable, self.ratedBGsEnabled, self.ratedArenasEnabled = ...;
	elseif ( event == "UNIT_LEVEL" ) then
		local unit = ...;
		if ( unit == "player" and UnitLevel(unit) == SHOW_CONQUEST_LEVEL ) then
			if ( PVPFrameTab2:IsShown() ) then
				PVPFrame_TabClicked(PVPFrameTab2);
			end
		end
	elseif( event == "PVP_ROLE_UPDATE") then
		PVPFrame_UpdateSelectedRoles();
	end

	PVP_UpdateAvailableRoles(self.TankIcon, self.HealerIcon, self.DPSIcon);
end

function PVPFrame_UpdateTabs()
	local selectedTab = PanelTemplates_GetSelectedTab(PVPFrame)
	if (selectedTab == nil or selectedTab == 1) then
		PVPFrameTab1:Click();
	elseif (selectedTab == 2) then
		PVPFrameTab2:Click();
	elseif (selectedTab == 3) then
		PVPFrameTab3:Click();
	elseif (selectedTab == 4) then
		PVPFrameTab4:Click();
	end
end

---- PVP Role Functions

function PVPFrame_UpdateSelectedRoles()
	local tank, healer, dps = GetPVPRoles();
	PVPFrame.TankIcon.checkButton:SetChecked(tank);
	PVPFrame.HealerIcon.checkButton:SetChecked(healer);
	PVPFrame.DPSIcon.checkButton:SetChecked(dps);
end

function PVPRoleButtonTemplate_OnLoad(self)
	if self.role then
		local showDisabled = false;
		self:SetNormalAtlas(GetIconForRole(self.role, showDisabled), TextureKitConstants.IgnoreAtlasSize);
		showDisabled = true;
		self:SetDisabledAtlas(GetIconForRole(self.role, showDisabled), TextureKitConstants.IgnoreAtlasSize);
	end
	
	local classTank, classHealer, classDPS = UnitGetAvailableRoles("player");
	local id = self.role;
	if(self.role == "TANK") then
		if( not classTank ) then
			self.permDisabledTip = YOUR_CLASS_MAY_NOT_PERFORM_ROLE;
		else
			self.permDisabledTip = YOU_ARE_NOT_SPECIALIZED_IN_ROLE;
		end
	elseif(self.role == "HEALER")then
		if( not classHealer ) then
			self.permDisabledTip = YOUR_CLASS_MAY_NOT_PERFORM_ROLE;
		else
			self.permDisabledTip = YOU_ARE_NOT_SPECIALIZED_IN_ROLE;
		end
	elseif(self.role == "DAMAGER")then
		if( not classDPS ) then
			self.permDisabledTip = YOUR_CLASS_MAY_NOT_PERFORM_ROLE;
		else
			self.permDisabledTip = YOU_ARE_NOT_SPECIALIZED_IN_ROLE;
		end
	end
end

function PVPRoleButtonTemplate_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(_G["ROLE_DESCRIPTION_"..self.role], nil, nil, nil, nil, true);
	if ( self.permDisabled ) then
		if(self.permDisabledTip)then
			GameTooltip:AddLine(self.permDisabledTip, 1, 0, 0, true);
		end
	elseif ( self.disabledTooltip and not self:IsEnabled() ) then
		GameTooltip:AddLine(self.disabledTooltip, 1, 0, 0, true);
	end
	GameTooltip:Show();
end

function PVPFrame_RoleButtonClicked(self)
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	PVPFrame_SetRoles(self:GetParent():GetParent());
end

function PVPFrame_SetRoles(frame)
	SetPVPRoles(frame.TankIcon.checkButton:GetChecked(),
		frame.HealerIcon.checkButton:GetChecked(),
		frame.DPSIcon.checkButton:GetChecked());
	PVPFrame_UpdateSelectedRoles();
end

function PVP_UpdateAvailableRoleButton(button, canBeRole)
	if (canBeRole) then
		PVP_EnableRoleButton(button);
	else
		PVP_PermanentlyDisableRoleButton(button);
	end
end

function PVP_UpdateAvailableRoles(tankButton, healButton, dpsButton)
	local canBeTank, canBeHealer, canBeDPS = C_LFGList.GetAvailableRoles();
	PVP_UpdateAvailableRoleButton(tankButton, canBeTank);
	PVP_UpdateAvailableRoleButton(healButton, canBeHealer);
	PVP_UpdateAvailableRoleButton(dpsButton, canBeDPS);
end

function PVP_PermanentlyDisableRoleButton(button)
	button.permDisabled = true;
	button:Disable();
	button.checkButton:Hide();
	button.checkButton:Disable();
	button.checkButton:SetChecked(false);
	button.alert:Hide();
end

function PVP_DisableRoleButton(button)
	button:Disable();
	button.checkButton:Disable();
end

function PVP_EnableRoleButton(button)
	button.permDisabled = false;
	button:Enable();
	if( button.lockedIndicator:IsShown() ) then
		button.checkButton:Hide();
		button.checkButton:Disable();
	else
		button.checkButton:Show();
		button.checkButton:Enable();
	end
end

---- NEW PVP FRAME FUNCTIONS

function PVPFrame_UpdateCurrency(self)
	local currencyID = PVPFrameCurrency.currencyID;
	local currencyInfo;
	if ( currencyID ) then
		currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
	end

	if ( currencyInfo and currencyInfo.name and currencyInfo.quantity) then
		-- show conquest bar?
		if ( currencyID == Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID ) then
			PVPFrameCurrency:Hide();
			PVPFrameConquestBar:Show();

			local conquestCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID);
			local bgCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_BG_META_CURRENCY_ID);
			local arenaCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_ARENA_META_CURRENCY_ID);

			local tier1Limit = arenaCurrencyInfo.maxQuantity;
			local tier2Limit = bgCurrencyInfo.maxQuantity;
			local tier1Quantity = arenaCurrencyInfo.totalEarned;
			local tier2Quantity = bgCurrencyInfo.totalEarned;
			local pointsThisWeek = conquestCurrencyInfo.totalEarned;
			local maxPointsThisWeek = conquestCurrencyInfo.maxQuantity;

			-- if BG limit is below arena, swap them
			if ( tier2Limit < tier1Limit ) then
				tier1Quantity, tier2Quantity = tier2Quantity, tier1Quantity;
				tier1Limit, tier2Limit = tier2Limit, tier1Limit;
			end

			CapProgressBar_Update(PVPFrameConquestBar, tier1Quantity, tier1Limit, tier2Quantity, tier2Limit, pointsThisWeek, maxPointsThisWeek, false);
			PVPFrameConquestBar.label:SetText(currencyInfo.name);
		else
			PVPFrameCurrency:Show();
			PVPFrameConquestBar:Hide();
			PVPFrameCurrencyValue:SetText(currencyInfo.quantity);
		end
	else
		PVPFrameCurrency:Hide();
		PVPFrameConquestBar:Hide();
	end
end

function PVPFrameConquestBar_OnEnter(self)
	local conquestCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID);
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(MAXIMUM_REWARD);
	GameTooltip:AddLine(format(CURRENCY_RECEIVED_THIS_SEASON, conquestCurrencyInfo.name), 1, 1, 1, true);
	GameTooltip:AddLine(" ");

	
	local bgCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_BG_META_CURRENCY_ID);
	local arenaCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_ARENA_META_CURRENCY_ID);

	local pointsThisWeek = conquestCurrencyInfo.totalEarned;
	local maxPointsThisWeek = conquestCurrencyInfo.maxQuantity;
	
	local r, g, b = 1, 1, 1;
	local capped;
	if ( pointsThisWeek >= maxPointsThisWeek ) then
		r, g, b = 0.5, 0.5, 0.5;
		capped = true;
	end

	GameTooltip:AddDoubleLine(FROM_ALL_SOURCES, format(GENERIC_FRACTION_STRING, pointsThisWeek, maxPointsThisWeek), r, g, b, r, g, b);
	
	if ( capped ) then
		r, g, b = 0.5, 0.5, 0.5;
	else
		r, g, b = 1, 1, 1;
	end
	GameTooltip:AddDoubleLine(" -"..FROM_RATEDBG, bgCurrencyInfo.totalEarned, r, g, b, r, g, b);	
	
	if ( capped ) then
		r, g, b = 0.5, 0.5, 0.5;
	else
		r, g, b = 1, 1, 1;
	end
	GameTooltip:AddDoubleLine(" -"..FROM_ARENA, arenaCurrencyInfo.totalEarned, r, g, b, r, g, b);

	GameTooltip:Show();
end

function PVPFrame_JoinClicked(self, isParty, wargame)
	local tabID =  PVPFrame.lastSelectedTab:GetID();
	if tabID == 1 then --Honor BGs
		if wargame then
			StartWarGame();
		else
			if PVPHonorFrame.selectedIsWorldPvp then
				JoinWorldPVPQueue(false, isParty, PVPHonorFrame.bgTypeScrollBox.selectionID);
			else 
				JoinBattlefield(0, isParty);
			end
		end
	elseif tabID == 2 then
		if PVPConquestFrame.mode == "Arena" then
			JoinArena();
		else -- rated bg
			JoinRatedBattlefield();
		end
	elseif tabID == 3 then	
		--StaticPopup_Show("ADD_TEAMMEMBER", nil, nil, PVPTeamManagementFrame.selectedTeam:GetID());
	end
end

function PVPFrame_TabClicked(self)
	local index = self:GetID()	
	PanelTemplates_SetTab(self:GetParent(), index);
	self:GetParent().lastSelectedTab = self;
	PVPFrameRightButton:Hide();
	PVPFrame.panel1:Hide();	
	PVPFrame.panel2:Hide();	
	PVPFrame.panel3:Hide();
	PVPFrame.panel4:Hide();
	
	PVPFrame.lowLevelFrame:Hide();
	PVPFrameLeftButton:Show();
	PVPFrame.TankIcon:Show();
	PVPFrame.HealerIcon:Show();
	PVPFrame.DPSIcon:Show();
	
	PVPFrameTitleText:SetText(self:GetText());	
	PVPFrame.Inset:SetPoint("TOPLEFT", PANEL_INSET_LEFT_OFFSET, PANEL_INSET_ATTIC_OFFSET);
	PVPFrame.topInset:Hide();
	local factionGroup = UnitFactionGroup("player");
	
	if index == 1 then -- Honor Page
		PVPFrame.panel1:Show();
		PVPFrameRightButton:Show();
		PVPFrameLeftButton:SetText(BATTLEFIELD_JOIN);
		PVPFrameLeftButton:Enable();
		PVPFrameCurrencyLabel:SetText(HONOR);
		PVPFrameCurrencyIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor-"..factionGroup);
		PVPFrameCurrency.currencyID = Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID;
	elseif index == 4 then -- War games
		PVPFrame.panel4:Show();
		PVPFrame.TankIcon:Hide();
		PVPFrame.HealerIcon:Hide();
		PVPFrame.DPSIcon:Hide();
		PVPFrameCurrency.currencyID = nil;
	elseif UnitLevel("player") < SHOW_CONQUEST_LEVEL then
		self:GetParent().lastSelectedTab = nil;
		PVPFrameLeftButton:Hide();
		PVPFrame.lowLevelFrame.title:SetText(self:GetText());
		PVPFrame.lowLevelFrame.error:SetFormattedText(PVP_CONQUEST_LOWLEVEL, self:GetText());
		PVPFrame.lowLevelFrame.description:SetText(self.info);
		PVPFrame.lowLevelFrame:Show();
		PVPFrameCurrency.currencyID = nil;
	elseif GetCurrentArenaSeason() == NO_ARENA_SEASON then
		self:GetParent().lastSelectedTab = nil;
		PVPFrameLeftButton:Hide();
		PVPFrame.lowLevelFrame.title:SetText(self:GetText());
		PVPFrame.lowLevelFrame.error:SetText("");
		PVPFrame.lowLevelFrame.description:SetText(ARENA_MASTER_NO_SEASON_TEXT);
		PVPFrame.lowLevelFrame:Show();
		PVPFrameCurrencyIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);
		PVPFrameCurrency.currencyID = Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID;
	elseif index == 2 then -- Conquest 
		PVPFrame.panel2:Show();	
		PVPFrameLeftButton:SetText(BATTLEFIELD_JOIN);
		PVPFrameCurrencyLabel:SetText(PVP_CONQUEST);
		PVPFrameCurrencyIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);
		PVPFrameCurrency.currencyID = Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID;
	elseif index == 3 then -- Arena Management
		PVPFrameLeftButton:Hide();
		PVPFrameLeftButton:Disable();
		PVPFrame.TankIcon:Hide();
		PVPFrame.HealerIcon:Hide();
		PVPFrame.DPSIcon:Hide();
		PVPFrame.panel3:Show();	
		PVPFrameArenaIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);
		PVPFrameCurrency.currencyID = none;
	end
	
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	PVPFrame_UpdateCurrency(self);
end



-- Honor Frame functions (the new BG page)

function PVPHonor_ButtonClicked(self)	
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	PVPHonorFrame.selectedIsWorldPvp = self.isWorldPVP;
	PVPHonorFrame.selectedPvpID = self.pvpID;
	HonorFrameSpecificList_FindAndSelectBattleground(self.battleGroundID);
	PVPHonorFrame_ResetInfo();
	PVPHonorFrame_UpdateGroupAvailable();
end

function PVPHonorFrame_ResetInfo()
	if not PVPHonorFrame.selectedIsWorldPvp and PVPHonorFrame.selectedPvpID then
		RequestBattlegroundInstanceInfo(PVPHonorFrame.selectedPvpID);
	end
	PVPHonor_UpdateInfo();
end

function PVPHonor_UpdateInfo()
	if PVPHonorFrame.selectedPvpID then
		local _, canEnter, isHoliday, isRandom, BattleGroundID, mapDescription = GetBattlegroundInfo(PVPHonorFrame.selectedPvpID);
		
		if(PVPHONOR_TEXTURELIST[BattleGroundID]) then
			PVPHonorFrameBGTex:SetTexture(PVPHONOR_TEXTURELIST[BattleGroundID]);
		end
		
		if ( isRandom or isHoliday ) then
			PVPHonor_UpdateRandomInfo();
			PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo:Show();
			PVPHonorFrameInfoScrollFrameChildFrameDescription:Hide();
		else
			if ( mapDescription ~= PVPHonorFrameInfoScrollFrameChildFrameDescription:GetText() ) then
				PVPHonorFrameInfoScrollFrameChildFrameDescription:SetText(mapDescription);
				PVPHonorFrameInfoScrollFrame:SetVerticalScroll(0);
			end
			
			PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo:Hide();
			PVPHonorFrameInfoScrollFrameChildFrameDescription:Show();
		end
	end
end

function PVPHonor_GetRandomBattlegroundInfo()
	if PVPHonorFrame.selectedPvpID == nil then
		-- CLASS-30641: It looks like we are getting "PVP_RATED_STATS_UPDATE" events before GetBattlegroundInfo is available..for now just nil check
		return nil;
	end
	return GetBattlegroundInfo(PVPHonorFrame.selectedPvpID);
end

function PVPHonor_UpdateRandomInfo()
	PVPQueue_UpdateRandomInfo(PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo, PVPHonor_GetRandomBattlegroundInfo);
end

function PVPHonor_UpdateQueueStatus()
	local queueStatus, queueMapName, queueInstanceID, button;

	for i=1, GetNumBattlegroundTypes() do
		local localizedName = GetBattlegroundInfo(i);
		local found = PVPHonorFrame.bgTypeScrollBox:FindElementDataByPredicate(function(elementData)
			return elementData and elementData.localizedName == localizedName;
		end);
		if found then 
			button = PVPHonorFrame.bgTypeScrollBox:FindFrame(found);
			if button then
				button.status:Hide();
			end
		end
	end

	local factionTexture = "Interface\\PVPFrame\\PVP-Currency-"..UnitFactionGroup("player");
	for i=1, GetMaxBattlefieldID() do
		queueStatus, queueMapName, queueInstanceID = GetBattlefieldStatus(i);
		local found = PVPHonorFrame.bgTypeScrollBox:FindElementDataByPredicate(function(elementData)
			return elementData and elementData.localizedName == queueMapName;
		end);
		if found then 
			button = PVPHonorFrame.bgTypeScrollBox:FindFrame(found);
			if button then
				if ( queueStatus ~= "none" ) then
					if ( queueStatus == "queued" ) then
						button.status.texture:SetTexture(factionTexture);
						button.status.texture:SetTexCoord(0.0, 1.0, 0.0, 1.0);
						button.status.tooltip = BATTLEFIELD_QUEUE_STATUS;
						button.status:Show();
					elseif ( queueStatus == "confirm" ) then
						button.status.texture:SetTexture("Interface\\CharacterFrame\\UI-StateIcon");
						button.status.texture:SetTexCoord(0.45, 0.95, 0.0, 0.5);
						button.status.tooltip = BATTLEFIELD_CONFIRM_STATUS;
						button.status:Show();
					end
				end
			end
		end
	end
end

function PVPHonorFrame_OnLoad(self)
	self:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("PVPHonorFrameButtonTemplate", function(button, elementData)
		HonorFrame_InitSpecificButton(button, elementData);
	end);
	view:SetPadding(1,0,2,0,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.bgTypeScrollBox, self.bgTypeScrollBar, view);
end

function PVPHonorFrame_OnEvent(self, event, ...)
	if ( event == "PVPQUEUE_ANYWHERE_SHOW" ) then
		self.currentData = true;
		HonorFrameSpecificList_Update();
		if ( self.selectedPvpID ) then
			PVPHonor_UpdateInfo();
		end
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
		HonorFrameSpecificList_Update();
	elseif ( event == "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE") then
		HonorFrameSpecificList_Update();
		if ( self.selectedPvpID ) then
			PVPHonorFrame_ResetInfo();
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" ) then
		PVPHonorFrame_UpdateGroupAvailable();
	elseif ( event == "PVP_RATED_STATS_UPDATE" ) then
		HonorFrameSpecificList_Update();
		PVPHonor_UpdateRandomInfo();
	end
end

function PVPHonorFrame_OnShow(self)	
	SortBGList();
	HonorFrameSpecificList_Update();
	PVPHonorFrame_ResetInfo();
end

function PVPHonorFrame_UpdateGroupAvailable()
	if ( (GetNumGroupMembers() > 0) and UnitIsGroupLeader("player") ) then
		-- If this is true then can join as a group
		PVPFrameRightButton:Enable();
	else
		PVPFrameRightButton:Disable();
	end
end

-------- Honor Frame Battleground Buttons --------
function HonorFrame_InitSpecificButton(button, elementData)
	local localizedName = elementData.localizedName;
	local isRandom = elementData.isRandom;
	local battleGroundID = elementData.battleGroundID;
	local mapDescription = elementData.mapDescription;
	local BGMapID = elementData.BGMapID;
	local maxPlayers = elementData.maxPlayers;
	local iconTexture = elementData.iconTexture;
	local shortDescription = elementData.shortDescription;
	local longDescription = elementData.longDescription;
	local canQueue = elementData.canQueue;
	local startTime = elementData.startTime;
	local pvpID = elementData.pvpID;
	local isWorldPVP = elementData.isWorldPVP;

	local name = localizedName;
	button:Enable();
	if(not canQueue) then
		button:Disable();
		if ( startTime and startTime > 0 ) then
			name = GRAY_FONT_COLOR_CODE..name;
			name = name.." ("..MinutesToTime(startTime)..")";
		else
			button:Enable();
			name = name.." ("..WINTERGRASP_IN_PROGRESS..")";
		end	
	end

	button.name = localizedName;
	button.title:SetText(name);

	if(not PVPHonorFrame.selectedPvpID) then
		PVPHonorFrame.selectedPvpID = pvpID;
		PVPHonorFrame.bgTypeScrollBox.selectionID = battleGroundID;
	end

	if ( PVPHonorFrame.bgTypeScrollBox.selectionID == battleGroundID ) then
		button.highlight:Show();
		button:LockHighlight();
		button.title:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		PVPHonorFrame.selectedPvpID = pvpID;
	else
		button.highlight:Hide();
		button:UnlockHighlight();
		button.title:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	button.battleGroundID = battleGroundID;
	button.isWorldPVP = isWorldPVP;
	button.pvpID = pvpID;
end

function HonorFrameSpecificList_Update()
	local dataProvider = CreateDataProvider();
	for index = 1, GetNumBattlegroundTypes() do
		local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers, gameType, iconTexture, shortDescription, longDescription, hasControllingHoliday = GetBattlegroundInfo(index);
		if battleGroundID ~= nil then -- CLASS-30641: It looks like we are getting "PVP_RATED_STATS_UPDATE" events before GetBattlegroundInfo is available..for now just nil check
			local startTime = C_PvP.GetWorldPvPWaitTime(battleGroundID);
			if localizedName and canEnter then
				dataProvider:Insert({
					localizedName=localizedName,
					isRandom=isRandom,
					battleGroundID=battleGroundID,
					mapDescription=mapDescription,
					BGMapID=BGMapID,
					maxPlayers=maxPlayers,
					iconTexture=iconTexture,
					shortDescription=shortDescription,
					longDescription=longDescription,
					canQueue=canEnter,
					startTime=startTime,
					pvpID=index,
					isWorldPVP = false;
				});
			elseif localizedName and (hasControllingHoliday > 0) then
				dataProvider:Insert({
					localizedName=localizedName,
					isRandom=isRandom,
					battleGroundID=battleGroundID,
					mapDescription=mapDescription,
					BGMapID=BGMapID,
					maxPlayers=maxPlayers,
					iconTexture=iconTexture,
					shortDescription=shortDescription,
					longDescription=longDescription,
					canQueue=canEnter,
					startTime=startTime,
					pvpID=index,
					isWorldPVP = true,
				});
			end
		end
	end
	PVPHonorFrame.bgTypeScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	PVPHonor_UpdateQueueStatus();
end

function HonorFrameSpecificList_FindAndSelectBattleground(bgID)
	PVPHonorFrame.bgTypeScrollBox.selectionID = bgID;
	PVPHonorFrame.bgTypeScrollBox:ScrollToElementDataByPredicate(function(elementData)
		return elementData.battleGroundID == bgID;
	end);
	HonorFrameSpecificList_Update();
end

-----------------------------------
---- PVPConquestFrame fUNCTIONS ---
-----------------------------------

function PVPConquestFrame_OnLoad(self)
	
	self.arenaButton.title:SetText(ARENA);
	self.ratedbgButton.title:SetText(PVP_RATED_BATTLEGROUND);		
	self.arenaButton:SetWidth(321);
	self.ratedbgButton:SetWidth(321);
	
	
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("ARENA_TEAM_UPDATE");
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	
	
	
	local factionGroup = UnitFactionGroup("player");
	self.infoButton.factionIcon = _G["PVPConquestFrameInfoButtonInfoIcon"..factionGroup];
	self.infoButton.factionIcon:Show();
	self.winReward.arenaSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);
end


function PVPConquestFrame_OnEvent(self, event, ...)
	if not self:IsShown() then
		return;
	end
	
	PVPConquestFrame_Update(PVPConquestFrame);
end


function PVPConquestFrame_Update(self)
	local groupSize = max(GetNumGroupMembers(), 1);
	local validGroup = false;
	local reward = 0;
	local name, size;

	if self.mode == "Arena" then
		self.winReward.winAmount:SetText(0);
		self.noWeeklyFrame:Hide();
		local prefixColorCode = "|cff808080";
	
		if(UnitIsGroupLeader("player") and (IsInGroup() or IsInRaid())) then
			if(groupSize == 2 or groupSize == 3 or groupSize == 5) then
				validGroup = true;
			end
		end

		if not validGroup then
			self.infoButton.title:SetText(prefixColorCode..ARENA_BATTLES);
			self.infoButton.arenaError:Show();
			self.infoButton.wins:Hide();
			self.infoButton.winsValue:Hide();
			self.infoButton.losses:Hide();
			self.infoButton.lossesValue:Hide();
			self.infoButton.topLeftText:Hide();
			self.infoButton.bottomLeftText:Hide();
			self.teamIndex = nil;
		else
			prefixColorCode = "";
			self.infoButton.title:SetText(prefixColorCode..ARENA_BATTLES);
			reward = PVPConquestFrame_ConfigureConquestRewards(C_PvP.GetArenaRewards(groupSize));
			local ArenaSizesToIndex = {};
            ArenaSizesToIndex[2] = 1;
            ArenaSizesToIndex[3] = 2;
            ArenaSizesToIndex[5] = 3;
			local personalBGRating, _, _, seasonPlayed, seasonWon, weeklyPlayed, weeklyWins = GetPersonalRatedInfo(ArenaSizesToIndex[groupSize]);
			self.winReward.winAmount:SetText(reward);

			--self.infoButton.title:SetText(teamName);
			self.infoButton.winsValue:SetText(seasonWon);
			self.infoButton.lossesValue:SetText(seasonPlayed-seasonWon);
			self.infoButton.topLeftText:SetText(PVP_RATING.." "..personalBGRating);
			self.infoButton.bottomLeftText:SetText(_G["ARENA_"..groupSize.."V"..groupSize]);
			
			self.infoButton.arenaError:Hide();
			self.infoButton.wins:Show();
			self.infoButton.winsValue:Show();
			self.infoButton.losses:Show();
			self.infoButton.lossesValue:Show();
			self.infoButton.topLeftText:Show();
			self.infoButton.bottomLeftText:Show();
		end
	else -- Rated BG
		reward = PVPConquestFrame_ConfigureConquestRewards(C_PvP.GetRatedBGRewards());
		local personalBGRating, _, _, seasonPlayed, seasonWon, weeklyPlayed, weeklyWins = GetPersonalRatedInfo(4);
		self.topRatingText:SetText(RATING..": "..personalBGRating);
		self.winReward.winAmount:SetText(reward);

		name, size = GetRatedBattleGroundInfo();
		
		validGroup = groupSize==size;
		local prefixColorCode = "|cff808080";
		if validGroup then
			prefixColorCode = "";
		end
		
		
		if name then
			self.infoButton.title:SetText(prefixColorCode..name);
			self.infoButton.bottomLeftText:SetFormattedText(PVP_TEAMTYPE, size, size);
			self.noWeeklyFrame:Hide();
		else
			self.noWeeklyFrame:Show();
			self.noWeeklyFrame:SetFrameLevel(self:GetFrameLevel()+2);
		end
		
		
		self.infoButton.winsValue:SetText(prefixColorCode..seasonWon);
		self.infoButton.lossesValue:SetText(prefixColorCode..(seasonPlayed-seasonWon));
		self.infoButton.topLeftText:SetText();
		
		self.infoButton.arenaError:Hide();
		self.infoButton.bgOff:Hide();
		
		
		self.infoButton.wins:Show();
		self.infoButton.winsValue:Show();
		self.infoButton.losses:Show();
		self.infoButton.lossesValue:Show();
		self.infoButton.topLeftText:Show();
		self.infoButton.bottomLeftText:Show();
		self.infoButton.bgNorm:Show();
	end
	
	self.partyInfoRollOver.tooltip = nil;
	if validGroup then
		self.partyStatusBG:SetVertexColor(0,1,0);
		self.partyInfoRollOver:Hide();
		self.partyNum:SetFormattedText(GREEN_FONT_COLOR_CODE..PVP_PARTY_SIZE, groupSize);
		self.infoButton.bgNorm:Show();
		self.infoButton.bgOff:Hide();
		SetDesaturation(self.infoButton.factionIcon, false);
		
		self.infoButton.wins:SetText(WINS);
		self.infoButton.losses:SetText(LOSSES);
		if UnitIsGroupLeader("player") then
			PVPFrameLeftButton:Enable();
		else
			PVPFrameLeftButton:Disable();
		end
	else
		self.partyStatusBG:SetVertexColor(1,0,0);
		self.partyInfoRollOver:Show();
		self.partyNum:SetFormattedText(RED_FONT_COLOR_CODE..PVP_PARTY_SIZE, groupSize);
		self.infoButton.bgNorm:Hide();
		self.infoButton.bgOff:Show();
		SetDesaturation(self.infoButton.factionIcon, true);
		
		self.infoButton.wins:SetText("|cff808080"..WINS);
		self.infoButton.losses:SetText("|cff808080"..LOSSES);
		PVPFrameLeftButton:Disable();
		
		if PVPConquestFrame.mode == "RatedBg" and  size and groupSize then
			if  size > groupSize then
				self.partyInfoRollOver.tooltip = string.format(PVP_RATEDBG_NEED_MORE, size - groupSize);
			else
				self.partyInfoRollOver.tooltip = string.format(PVP_RATEDBG_NEED_LESS, groupSize -  size);
			end
		end
	end

	if reward > 0 then
		self.rewardDescription:SetText(PVP_REWARD_EXPLANATION);
		self.winReward:Show();
	else
		self.rewardDescription:SetText(PVP_REWARD_FAILURE);
		self.winReward:Hide();
	end
	
	self.validGroup = validGroup;
end

function PVPConquestFrame_ConfigureConquestRewards(honor, experience, itemRewards, currencyRewards, roleShortageBonus)
	local conquestReward = 0;

	if(currencyRewards) then
		for i, reward in ipairs(currencyRewards) do
			if reward.id == Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID then
				conquestReward = reward.quantity;
			end
		end
	end

	return conquestReward/100;
end


function PVPConquestFrame_OnShow(self)
	if not self.clickedButton then
		self.clickedButton = self.arenaButton;
	end
	self.clickedButton:Click();
	PVPConquestFrame_Update(self);
end


function PVPConquestFrame_ButtonClicked(button)
	if button:GetID() == 1 then --Arena
		PVPConquestFrame.mode = "Arena";
		PVPConquestFrame.BG:SetTexCoord(0.00097656, 0.31445313, 0.33789063, 0.88476563);
		PVPConquestFrame.description:SetText(PVP_ARENA_EXPLANATION);
		PVPConquestFrame.title:SetText(ARENA_BATTLES);
		button:LockHighlight();
		PVPConquestFrame.ratedbgButton:UnlockHighlight();
		PVPConquestFrame.topRatingText:Hide();
	else -- Rated BG	
		PVPConquestFrame.mode = "RatedBg";
		PVPConquestFrame.BG:SetTexCoord(0.32324219, 0.63671875, 0.00195313, 0.54882813);
		PVPConquestFrame.description:SetText(PVP_RATED_BATTLEGROUND_EXPLANATION);
		PVPConquestFrame.title:SetText(PVP_RATED_BATTLEGROUNDS);
		button:LockHighlight();
		PVPConquestFrame.arenaButton:UnlockHighlight();
		PVPConquestFrameInfoButton.title:SetText(PVP_RATED_BATTLEGROUND);
		PVPConquestFrame.topRatingText:Show();
	end
	PVPConquestFrame_Update(PVPConquestFrame);
end

--  PVPTeamManagementFrame
function PVPTeamManagementFrame_ToggleSeasonal(self)	
	if ( PVPFrame.seasonStats ) then
		PVPFrame.seasonStats = nil;
		PvP_WeeklyText:SetText(ARENA_WEEKLY_STATS);
	else
		PVPFrame.seasonStats = 1;
		PvP_WeeklyText:SetText(ARENA_SEASON_STATS);
	end
	PVPTeam_Update();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

-- PVP Honor Data
function PVPHonor_Update()
	local hk, cp, dk, contribution, rank, highestRank, rankName, rankNumber;

	-- Yesterday's values
	hk = GetPVPYesterdayStats();
	PVPHonorYesterdayKills:SetText(hk);

	-- Lifetime values
	hk =  GetPVPLifetimeStats();
	PVPHonorLifetimeKills:SetText(hk);

	local honorCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID);
	PVPFrameHonorPoints:SetText(honorCurrencyInfo.quantity);

	local arenaCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID);
	PVPFrameArenaPoints:SetText(arenaCurrencyInfo.quantity)	
	
	-- Today's values
	hk = GetPVPSessionStats();
	PVPHonorTodayKills:SetText(hk);
end

---- PVP PopUp Functions
function PVPFramePopup_OnLoad(self)
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("BATTLEFIELD_QUEUE_TIMEOUT");
end


function PVPFramePopup_OnEvent(self, event, ...)
	if event == "BATTLEFIELD_QUEUE_TIMEOUT" then
		if self.type == "WARGAME_REQUESTED" then
			self:Hide();
		end
	end
end


function PVPFramePopup_OnUpdate(self, elasped)
	if self.timeout then
		self.timeout = self.timeout - elasped;
		if self.timeout > 0 then
			self.timer:SetText(SecondsToTime(self.timeout))
		end
	end
end


function PVPFramePopup_SetupPopUp(event, challengerName, bgName, timeout)
	PVPFramePopup.title:SetFormattedText(WARGAME_CHALLENGED, challengerName, bgName);
	PVPFramePopup:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } } );
	PVPFramePopup.type = event;
	PVPFramePopup.timeout = timeout  - 3;  -- add a 3 second buffer
	PVPFramePopup.minimizeButton:Disable();
	SetPortraitToTexture(PVPFramePopup.ringIcon,"Interface\\BattlefieldFrame\\UI-Battlefield-Icon");
	StaticPopupSpecial_Show(PVPFramePopup);
	PlaySound("ReadyCheck");
end



function PVPFramePopup_OnResponse(accepted)
	if PVPFramePopup.type == "WARGAME_REQUESTED" then
		WarGameRespond(accepted)
	end
	
	StaticPopupSpecial_Hide(PVPFramePopup);
end



---- PVPTimer
function PVPTimerFrame_OnUpdate(self, elapsed)
	local keepUpdating = false;
	if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 ) then
		keepUpdating = true;
		if(BattlefieldIconText) then
			BattlefieldIconText:Hide();
		end
	else
		local lowestExpiration = 0;
		for i = 1, GetMaxBattlefieldID() do
			local expiration = GetBattlefieldPortExpiration(i);
			if ( expiration > 0 ) then
				if( expiration < lowestExpiration or lowestExpiration == 0 ) then
					lowestExpiration = expiration;
				end
	
				keepUpdating = true;
			end
		end
		if(BattlefieldIconText) then
			if( lowestExpiration > 0 and lowestExpiration <= 10 ) then
				BattlefieldIconText:SetText(lowestExpiration);
				BattlefieldIconText:Show();
			else
				BattlefieldIconText:Hide();
			end
		end
	end
	
	if ( not keepUpdating ) then
		PVPTimerFrame:SetScript("OnUpdate", nil);
		PVPTimerFrame.updating = false;
		return;
	end
	
	local frame = PVPFrame
	
	BATTLEFIELD_SHUTDOWN_TIMER = BATTLEFIELD_SHUTDOWN_TIMER - elapsed;
	-- Set the time for the score frame
	WorldStateScoreFrameTimer:SetFormattedText(SecondsToTimeAbbrev(BATTLEFIELD_SHUTDOWN_TIMER));
	-- Check if I should send a message only once every 3 seconds (BATTLEFIELD_TIMER_DELAY)
	frame.timerDelay = frame.timerDelay + elapsed;
	if ( frame.timerDelay < BATTLEFIELD_TIMER_DELAY ) then
		return;
	else
		frame.timerDelay = 0
	end

	local threshold = BATTLEFIELD_TIMER_THRESHOLDS[BATTLEFIELD_TIMER_THRESHOLD_INDEX];
	if ( BATTLEFIELD_SHUTDOWN_TIMER > 0 ) then
		if ( BATTLEFIELD_SHUTDOWN_TIMER < threshold and BATTLEFIELD_TIMER_THRESHOLD_INDEX ~= #BATTLEFIELD_TIMER_THRESHOLDS ) then
			-- If timer past current threshold advance to the next one
			BATTLEFIELD_TIMER_THRESHOLD_INDEX = BATTLEFIELD_TIMER_THRESHOLD_INDEX + 1;
		else
			-- See if time should be posted
			local currentMod = floor(BATTLEFIELD_SHUTDOWN_TIMER/threshold);
			if ( PREVIOUS_BATTLEFIELD_MOD ~= currentMod ) then
				-- Print message
				local info = ChatTypeInfo["SYSTEM"];
				local string;
				if ( GetBattlefieldWinner() ) then
					local isArena = IsActiveBattlefieldArena();
					if ( isArena ) then
						string = format(ARENA_COMPLETE_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
					else
						string = format(BATTLEGROUND_COMPLETE_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
					end
				else
					string = format(INSTANCE_SHUTDOWN_MESSAGE, SecondsToTime(ceil(BATTLEFIELD_SHUTDOWN_TIMER/threshold) * threshold));
				end
				DEFAULT_CHAT_FRAME:AddMessage(string, info.r, info.g, info.b, info.id);
				PREVIOUS_BATTLEFIELD_MOD = currentMod;
			end
		end
	else
		BATTLEFIELD_SHUTDOWN_TIMER = 0;
	end
end

------		Misc PVP Functions
function GetRandomBGHonorCurrencyBonuses()
	local honorWin,_,_, currencyRewardsWin = C_PvP.GetRandomBGRewards();
	local honorLoss,_,_, currencyRewardsLoss = C_PvP.GetRandomBGLossRewards();
	local conquestWin, conquestLoss = 0, 0;

	if GetCurrentArenaSeason() ~= NO_ARENA_SEASON then 
		if(currencyRewardsWin) then
			for i, reward in ipairs(currencyRewardsWin) do
				if reward.id == Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID then
					conquestWin = reward.quantity;
				end
			end
		end

		if(currencyRewardsLoss) then
			for i, reward in ipairs(currencyRewardsLoss) do
				if reward.id == Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID then
					conquestLoss = reward.quantity;
				end
			end
		end
	end

	return true, honorWin/100, conquestWin/100, honorLoss/100, conquestLoss/100;
end

function GetHolidayBGHonorCurrencyBonuses()
	local honorWin,_,_, currencyRewardsWin = C_PvP.GetHolidayBGRewards();
	local honorLoss,_,_, currencyRewardsLoss = C_PvP.GetHolidayBGLossRewards();
	local conquestWin, conquestLoss = 0, 0;

	if GetCurrentArenaSeason() ~= NO_ARENA_SEASON then
		if(currencyRewardsWin) then
			for i, reward in ipairs(currencyRewardsWin) do
				if reward.id == Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID then
					conquestWin = reward.quantity;
				end
			end
		end

		if(currencyRewardsLoss) then
			for i, reward in ipairs(currencyRewardsLoss) do
				if reward.id == Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID then
					conquestLoss = reward.quantity;
				end
			end
		end
	end

	return true, honorWin/100, conquestWin/100, honorLoss/100, conquestLoss/100;
end

function PVPQueue_UpdateRandomInfo(base, infoFunc)
	if infoFunc == nil then
		-- CLASS-30641: It looks like we are getting "PVP_RATED_STATS_UPDATE" events before GetBattlegroundInfo is available..for now just nil check
		return;
	end

	local BGname, canEnter, isHoliday, isRandom = infoFunc();
	
	local hasWin, lossHonor, winHonor, winArena, lossArena;
	
	if ( isRandom ) then
		hasWin, winHonor, winArena, lossHonor, lossArena = GetRandomBGHonorCurrencyBonuses();
		base.title:SetText(RANDOM_BATTLEGROUND);
		base.description:SetText(RANDOM_BATTLEGROUND_EXPLANATION);
	else
		base.title:SetText(BATTLEGROUND_HOLIDAY);
		base.description:SetText(BATTLEGROUND_HOLIDAY_EXPLANATION);
		hasWin, winHonor, winArena, lossHonor, lossArena = GetHolidayBGHonorCurrencyBonuses();
	end
	
	if (winHonor ~= 0) then
		base.winReward.honorSymbol:Show();
		base.winReward.honorAmount:Show();
		base.winReward.honorAmount:SetText(winHonor);
	else
		base.winReward.honorSymbol:Hide();
		base.winReward.honorAmount:Hide();
	end
	
	if (winArena ~= 0) then
		base.winReward.arenaSymbol:Show();
		base.winReward.arenaAmount:Show();
		base.winReward.arenaAmount:SetText(winArena);
	else
		base.winReward.arenaSymbol:Hide();
		base.winReward.arenaAmount:Hide();
	end
	
	if (lossHonor ~= 0) then
		base.lossReward.honorSymbol:Show();
		base.lossReward.honorAmount:Show();
		base.lossReward.honorAmount:SetText(lossHonor);
	else
		base.lossReward.honorSymbol:Hide();
		base.lossReward.honorAmount:Hide();
	end
	
	if (lossArena ~= 0) then
		base.lossReward.arenaSymbol:Show();
		base.lossReward.arenaAmount:Show();
		base.lossReward.arenaAmount:SetText(lossArena);
	else
		base.lossReward.arenaSymbol:Hide();
		base.lossReward.arenaAmount:Hide();
	end
		
	local englishFaction = UnitFactionGroup("player");
	base.winReward.honorSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor-"..englishFaction);
	base.lossReward.honorSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor-"..englishFaction);
	base.winReward.arenaSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..englishFaction);
	base.lossReward.arenaSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..englishFaction);
end

function IsAlreadyInQueue(mapName)
	local inQueue = nil;
	for index,value in pairs(PREVIOUS_BATTLEFIELD_QUEUES) do
		if ( value == mapName ) then
			inQueue = 1;
		end
	end
	return inQueue;
end

function BattlegroundShineFadeIn()
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = 0.5;
	fadeInfo.finishedFunc = BattlegroundShineFadeOut;
	UIFrameFade(BattlegroundShine, fadeInfo);
end

--hack since a frame can't have a reference to itself in it
function BattlegroundShineFadeOut()
	UIFrameFadeOut(BattlegroundShine, 0.5);
end

--
-- WARGAMES
--
function WarGamesFrame_OnLoad(self)
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");		-- for leadership changes
	self:RegisterAllEvents();

	local view = CreateScrollBoxListLinearView();

	view:SetElementExtentCalculator(function(dataIndex, elementData)
		if (elementData.localizedName == "header") then
			return WARGAME_HEADER_HEIGHT;
		else
			return WARGAME_BUTTON_HEIGHT;
		end
	end);
	view:SetElementFactory(function(factory, elementData)
		if (elementData.localizedName == "header") then
			factory("WarGameHeaderTemplate", function(button, elementData)
				WarGamesFrame_InitButton(button, elementData);
			end);
		else
			factory("WarGameButtonTemplate", function(button, elementData)
				WarGamesFrame_InitButton(button, elementData);
			end);
		end
	end);

	view:SetPadding(1,0,2,0,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.scrollBox, self.scrollBar, view);
end

-------- Specific BG Frame --------
function WarGamesFrame_InitButton(button, elementData)
	local index = elementData.index;
	local localizedName = elementData.localizedName;
	local collapsed = elementData.collapsed;
	local shortDescription = elementData.shortDescription;
	local longDescription = elementData.longDescription;
	local minPlayers = elementData.minPlayers;
	local maxPlayers = elementData.maxPlayers;
	local gameType = elementData.gameType;
	local iconTexture = elementData.iconTexture;
	local battleGroundID = elementData.battleGroundID;

	if(localizedName == "header") then
		if ( gameType == Enum.PvpMatchmakingType.Battleground ) then
			button.NameText:SetText(BATTLEGROUND);
		elseif ( gameType == Enum.PvpMatchmakingType.Arena ) then
			button.NameText:SetText(ARENA);
		else
			button.NameText:SetText(UNKNOWN);
		end

		if ( collapsed ) then
			button:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
		else
			button:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up"); 
		end

		button.collapsed = collapsed;
		button.bgID = battleGroundID;
	else
		button.NameText:SetText(localizedName);
		button.name = localizedName;
		button.shortDescription = shortDescription;
		button.longDescription = longDescription;
		if ( gameType == Enum.PvpMatchmakingType.Arena ) then
			minPlayers = 2;
			button.SizeText:SetText(WARGAME_ARENA_SIZES);
			button.InfoText:SetFormattedText(WARGAME_MINIMUM, minPlayers, minPlayers);
		else
			button.SizeText:SetFormattedText(PVP_TEAMTYPE, maxPlayers, maxPlayers);
			button.InfoText:SetFormattedText(WARGAME_MINIMUM, minPlayers, minPlayers);
		end
		button.Icon:SetTexture(iconTexture or DEFAULT_BG_TEXTURE);
		if ( WarGamesFrame.scrollBox.selectionID == battleGroundID ) then
			button.SelectedTexture:Show();
			button.NameText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			button.SizeText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		else
			button.SelectedTexture:Hide();
			button.NameText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			button.SizeText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
		button.bgID = battleGroundID;
	end
	button.index = index;
end

function WarGamesFrame_Update()
	local dataProvider = CreateDataProvider();
	for index = 1, GetNumWarGameTypes() do
		local localizedName, gameType, collapsed, battleGroundID, minPlayers, maxPlayers, isRandom, iconTexture, shortDescription, longDescription = GetWarGameTypeInfo(index);
		if localizedName then
			dataProvider:Insert({
				index = index;
				localizedName=localizedName,
				collapsed = collapsed,
				battleGroundID=battleGroundID,
				minPlayers = minPlayers;
				maxPlayers=maxPlayers,
				gameType=gameType,
				iconTexture=iconTexture,
				shortDescription=shortDescription,
				longDescription=longDescription,
			});
		end
	end
	WarGamesFrame.scrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function WarGamesFrame_FindAndSelectBattleground(bgID)
	WarGamesFrame.scrollBox.selectionID = bgID;
	WarGamesFrame.scrollBox:ScrollToElementDataByPredicate(function(elementData)
		return elementData.battleGroundID == bgID;
	end);
	WarGamesFrame_Update();
end

function WarGamesFrame_OnEvent(self, event, ...)
	if ( self:IsShown() ) then
		WarGameStartButton_Update();
	end
end

function WarGamesFrame_OnShow(self)
	if ( not self.dataLevel or UnitLevel("player") > self.dataLevel ) then
		WarGamesFrame.otherHeaderIndex = nil;
		self.dataLevel = UnitLevel("player");
		UpdateWarGamesList();
	end
	WarGamesFrame_Update();
end

function WarGameButtonHeader_OnClick(self)
	local index = self.index;
	if ( self.collapsed ) then
		ExpandWarGameHeader(index);
	else
		CollapseWarGameHeader(index);
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	WarGamesFrame_Update();
end

function WarGameButton_OnEnter(self)
	self.NameText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	self.SizeText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end

function WarGameButton_OnLeave(self)
	if ( self.index ~= GetSelectedWarGameType() ) then
		self.NameText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		self.SizeText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end

function WarGameButton_OnClick(self)
	local index = self.index;
	SetSelectedWarGameType(index);
	WarGamesFrame_FindAndSelectBattleground(self.bgID);
end

function WarGameStartButton_Update()
	local selectedIndex = GetSelectedWarGameType();
	if ( selectedIndex > 0 and not WarGameStartButton_GetErrorTooltip() ) then
		WarGameStartButton:Enable();
	else
		WarGameStartButton:Disable();
	end
end

function WarGameStartButton_OnEnter(self)
	local tooltip = WarGameStartButton_GetErrorTooltip();
	if ( tooltip ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(tooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1, 1);
	end
end

function WarGameStartButton_GetErrorTooltip()
	local name, pvpType, collapsed, id, minPlayers, maxPlayers = GetWarGameTypeInfo(GetSelectedWarGameType());
	if ( name ) then
		if ( not UnitIsGroupLeader("player") ) then
			return WARGAME_REQ_LEADER;
		end	
		if ( not UnitLeadsAnyGroup("target") or UnitIsUnit("player", "target") ) then
			return WARGAME_REQ_TARGET;
		end
		local groupSize = GetNumGroupMembers();
		-- how about a nice game of arena?
		if ( pvpType == Enum.PvpMatchmakingType.Arena ) then
			if ( groupSize ~= 2 and groupSize ~= 3 and groupSize ~= 5 ) then
				return string.format(WARGAME_REQ_ARENA, name, RED_FONT_COLOR_CODE);
			end
		else
			if ( groupSize < minPlayers or groupSize > maxPlayers ) then
				return string.format(WARGAME_REQ, name, RED_FONT_COLOR_CODE, minPlayers, maxPlayers);
			end
		end
	end
	return nil;
end

function WarGameStartButton_OnClick(self)
	local name = GetWarGameTypeInfo(GetSelectedWarGameType());
	if ( name ) then
		StartWarGame("target", name);
	end
end
