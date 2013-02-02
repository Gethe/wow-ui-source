MAX_ARENA_TEAMS = 3;
MAX_ARENA_TEAM_MEMBERS = 10;
MAX_BLACKLIST_BATTLEGROUNDS = 2;

HORDE_TEX_COORDS = {left=0.00195313, right=0.63867188, top=0.56445313, bottom=0.68945313}
ALLIANCE_TEX_COORDS = {left=0.00195313, right=0.63867188, top=0.31054688, bottom=0.43554688}

WARGAME_HEADER_HEIGHT = 16;
BATTLEGROUND_BUTTON_HEIGHT = 40;

BATTLEFIELD_TIMER_DELAY = 3;
BATTLEFIELD_TIMER_THRESHOLDS = {600, 300, 60, 15};
BATTLEFIELD_TIMER_THRESHOLD_INDEX = 1;

local MAX_SHOWN_BATTLEGROUNDS = 8;

StaticPopupDialogs["CONFIRM_JOIN_SOLO"] = {
	text = CONFIRM_JOIN_SOLO,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		HonorFrame_Queue(false, true);
	end,
	OnShow = function(self)
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
}

---------------------------------------------------------------
-- PVP FRAME
---------------------------------------------------------------
local panels = {
	[1] = { name = "PVPQueueFrame", addon = nil },
	[2] = { name = "PVPArenaTeamsFrame", addon = "Blizzard_ChallengesUI" },
}

local INSTANCE_TEXTURELIST = {
	  [0] = "Interface\\PVPFrame\\RandomPVPIcon",
	  [1] = "Interface\\LFGFrame\\LFGIcon-Battleground",
	  [2] = "Interface\\LFGFrame\\LFGIcon-WarsongGulch",
	  [3] = "Interface\\LFGFrame\\LFGIcon-ArathiBasin",
	  [4] = "Interface\\LFGFrame\\LFGIcon-NagrandArena",
	  [5] = "Interface\\LFGFrame\\LFGIcon-BladesEdgeArena",
	  [7] = "Interface\\LFGFrame\\LFGIcon-NetherBattlegrounds",
	  [8] = "Interface\\LFGFrame\\LFGIcon-RuinsofLordaeron",
	  [9] = "Interface\\LFGFrame\\LFGIcon-StrandoftheAncients",
	 [10] = "Interface\\LFGFrame\\LFGIcon-DalaranSewers",
	 [11] = "Interface\\LFGFrame\\LFGIcon-RingofValor",
	 [30] = "Interface\\LFGFrame\\LFGIcon-IsleOfConquest",
	[108] = "Interface\\LFGFrame\\LFGIcon-TwinPeaksBG",
	[120] = "Interface\\LFGFrame\\LFGIcon-TheBattleforGilneas",
	[699] = "Interface\\LFGFrame\\LFGIcon-TempleofKotmogu",
	[708] = "Interface\\LFGFrame\\LFGIcon-SilvershardMines",
	[719] = "Interface\\LFGFrame\\LFGIcon-TolvirArena",
}

function PVPUI_GetSelectedArenaTeam()
	if PVPUIFrame:IsVisible() then
		return ArenaTeamFrame.selectedTeam;
	end
	return nil;
end

function PVPUIFrame_OnLoad(self)
	RaiseFrameLevel(self.Shadows);
	PanelTemplates_SetNumTabs(self, 2);
	
	if (UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0]) then
		SetPortraitToTexture(self.portrait, "Interface\\Icons\\INV_BannerPVP_01");
		HonorFrame.BonusFrame.BattlegroundTexture:SetTexCoord(HORDE_TEX_COORDS.left, HORDE_TEX_COORDS.right,
															HORDE_TEX_COORDS.top, HORDE_TEX_COORDS.bottom)
	else
		SetPortraitToTexture(self.portrait, "Interface\\Icons\\INV_BannerPVP_02");
		HonorFrame.BonusFrame.BattlegroundTexture:SetTexCoord(ALLIANCE_TEX_COORDS.left, ALLIANCE_TEX_COORDS.right,
															ALLIANCE_TEX_COORDS.top, ALLIANCE_TEX_COORDS.bottom)
	end
	
	-- TEMP to get rewards for random/holiday
	RequestBattlegroundInstanceInfo(1);
	
	self:RegisterEvent("BATTLEFIELDS_CLOSED");
end

function PVPUIFrame_OnShow(self)
	if (UnitLevel("player") < SHOW_PVP_LEVEL or IsBlizzCon()) then
		self:Hide();
		return;
	end
	UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	PVPUIFrame_TabOnClick(PVPUIFrame.Tab1);
end

function PVPUIFrame_OnHide(self)
	UpdateMicroButtons();
	PlaySound("igCharacterInfoClose");
	ClearBattlemaster();
end

function PVPUIFrame_OnEvent(self, event, ...)
	if (event == "BATTLEFIELDS_CLOSED") then
		if (self:IsShown()) then
			self:Hide();
		end
	end
end

function PVPUIFrame_ToggleFrame(sidePanelName, selection)
	local self = PVPUIFrame;
	if ( self:IsShown() ) then
		if ( sidePanelName ) then
			local sidePanel = _G[sidePanelName];
			if ( sidePanel and sidePanel:IsShown() and sidePanel:getSelection() == selection ) then
				HideUIPanel(self);
			else
				PVPUIFrame_ShowFrame(sidePanelName, selection);
			end
		else
			HideUIPanel(self);
		end
	else
		PVPUIFrame_ShowFrame(sidePanelName, selection);
	end
end

function PVPUIFrame_ShowFrame(sidePanelName, selection)
	local self = PVPUIFrame;
	-- find side panel
	local tabIndex;
	if ( sidePanelName ) then
		for index, data in pairs(panels) do
			if ( data.name == sidePanelName ) then
				tabIndex = index;
				break;
			end
		end
	else
		-- no side panel specified, check current panel
		if ( self.activeTabIndex ) then
			tabIndex = self.activeTabIndex;
		else
			-- no current panel, go to the first panel
			tabIndex = 1;
		end
	end	
	if ( not tabIndex ) then
		return;
	end

	-- load addon if needed
	if ( panels[tabIndex].addon ) then
		UIParentLoadAddOn(panels[tabIndex].addon);
		panels[tabIndex].addon = nil;
	end
	-- show it
	ShowUIPanel(self);
	self.activeTabIndex = tabIndex;	
	PanelTemplates_SetTab(self, tabIndex);
	for index, data in pairs(panels) do
		local panel = _G[data.name];
		if ( index == tabIndex ) then
			panel:Show();
			if ( panel.update ) then
				panel:update(selection);
			end
		elseif ( panel ) then
			panel:Hide();
		end
	end
end

function PVPUIFrame_TabOnClick(self)
	PlaySound("igCharacterInfoTab");
	PVPUIFrame_ShowFrame(panels[self:GetID()].name);
end

---------------------------------------------------------------
-- CATEGORY FRAME
---------------------------------------------------------------

local pvpFrames = { "HonorFrame", "ConquestFrame", "WarGamesFrame" }

function PVPQueueFrame_OnLoad(self)
	--set up side buttons
	local englishFaction = UnitFactionGroup("player");	
	SetPortraitToTexture(self.CategoryButton1.Icon, "Interface\\Icons\\achievement_bg_winwsg");
	self.CategoryButton1.Name:SetText(PVP_TAB_HONOR);
	self.CategoryButton1.CurrencyIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor-"..englishFaction);
	local _, currencyAmount = GetCurrencyInfo(HONOR_CURRENCY);
	self.CategoryButton1.CurrencyAmount:SetText(currencyAmount);
	SetPortraitToTexture(self.CategoryButton2.Icon, "Interface\\Icons\\achievement_bg_killxenemies_generalsroom");
	self.CategoryButton2.Name:SetText(PVP_TAB_CONQUEST);
	self.CategoryButton2.CurrencyIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..englishFaction);
	_, currencyAmount = GetCurrencyInfo(CONQUEST_CURRENCY);
	self.CategoryButton2.CurrencyAmount:SetText(currencyAmount);
	SetPortraitToTexture(self.CategoryButton3.Icon, "Interface\\Icons\\ability_warrior_offensivestance");
	self.CategoryButton3.Name:SetText(WARGAMES);
	
	-- disable unusable side buttons
	if ( UnitLevel("player") < SCENARIOS_SHOW_LEVEL ) then
		PVPQueueFrame_SetCategoryButtonState(self.CategoryButton3, false);
		self.CategoryButton3.tooltip = format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SCENARIOS_SHOW_LEVEL);
		PVPQueueFrame:SetScript("OnEvent", PVPQueueFrame_OnEvent);
		PVPQueueFrame:RegisterEvent("PLAYER_LEVEL_UP");
	end
	if ( UnitLevel("player") < RAID_FINDER_SHOW_LEVEL ) then
		PVPQueueFrame_SetCategoryButtonState(self.CategoryButton2, false);
		self.CategoryButton2.tooltip = format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, RAID_FINDER_SHOW_LEVEL);
		PVPQueueFrame:SetScript("OnEvent", PVPQueueFrame_OnEvent);
		PVPQueueFrame:RegisterEvent("PLAYER_LEVEL_UP");
	end
	
	-- set up accessors
	self.getSelection = PVPQueueFrame_GetSelection;
	self.update = PVPQueueFrame_Update;
	
	--register for events
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_REQUEST_RESPONSE");
	self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_INVITE");
	self:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE");
	self:RegisterEvent("BATTLEFIELD_MGR_EJECT_PENDING");
	self:RegisterEvent("BATTLEFIELD_MGR_EJECTED");
	self:RegisterEvent("BATTLEFIELD_MGR_ENTERED");
	self:RegisterEvent("WARGAME_REQUESTED");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	self:RegisterEvent("PVP_REWARDS_UPDATE");
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("VARIABLES_LOADED");
end

function PVPQueueFrame_OnEvent(self, event, ...)
	if (event == "PLAYER_LEVEL_UP") then
		local level = ...;
		local allAvailable = true;

		if ( level >= SCENARIOS_SHOW_LEVEL ) then
			PVPQueueFrame_SetCategoryButtonState(self.CategoryButton3, true);
			self.CategoryButton3.tooltip = nil;
		else
			allAvailable = false;
		end

		if ( level >= RAID_FINDER_SHOW_LEVEL ) then
			PVPQueueFrame_SetCategoryButtonState(self.CategoryButton2, true);
			self.CategoryButton2.tooltip = nil;
		else
			allAvailable = false;
		end

		if ( allAvailable ) then
			PVPQueueFrame:UnregisterEvent("PLAYER_LEVEL_UP");		
		end
	elseif(event == "CURRENCY_DISPLAY_UPDATE") then
		PVPQueueFrame_UpdateCurrencies(self)
		if ( self:IsShown() ) then
			RequestPVPRewards();
		end
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED") then
		local arg1 = ...
		PVP_UpdateStatus(false, arg1);
	elseif ( event == "BATTLEFIELD_MGR_QUEUE_REQUEST_RESPONSE" ) then
		local battleID, accepted, warmup, inArea, loggingIn, areaName = ...;
		if(not loggingIn) then
			if(accepted) then
				if(warmup) then
					StaticPopup_Show("BFMGR_CONFIRM_WORLD_PVP_QUEUED_WARMUP", areaName, nil, arg1);
				elseif (inArea) then
					StaticPopup_Show("BFMGR_EJECT_PENDING", areaName, nil, arg1);
				else
					StaticPopup_Show("BFMGR_CONFIRM_WORLD_PVP_QUEUED", areaName, nil, arg1);
				end
			else
				StaticPopup_Show("BFMGR_DENY_WORLD_PVP_QUEUED", areaName, nil, arg1);
			end
		end
		PVP_UpdateStatus(false);
	elseif ( event == "BATTLEFIELD_MGR_QUEUE_INVITE" ) then
		local battleID, warmup, areaName = ...;
		if(warmup) then
			local dialog = StaticPopup_Show("BFMGR_INVITED_TO_QUEUE_WARMUP", areaName, nil, battleID);
		else
			local dialog = StaticPopup_Show("BFMGR_INVITED_TO_QUEUE", areaName, nil, battleID);
		end
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus(false);
	elseif ( event == "BATTLEFIELD_MGR_ENTRY_INVITE" ) then
		local battleID, areaName = ...;
		local dialog = StaticPopup_Show("BFMGR_INVITED_TO_ENTER", areaName, nil, battleID);
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus(false);
	elseif ( event == "BATTLEFIELD_MGR_EJECT_PENDING" ) then
		local battleID, remote, areaName = ...;
		if(remote) then
			StaticPopup_Show("BFMGR_EJECT_PENDING_REMOTE", areaName, nil, arg1);
		else
		StaticPopup_Show("BFMGR_EJECT_PENDING", areaName, nil, arg1);
		end
		PVP_UpdateStatus(false);
	elseif ( event == "BATTLEFIELD_MGR_EJECTED" ) then
		local battleID, playerExited, relocated, battleActive, lowLevel, areaName = ...;
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE");
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE_WARMUP");
		StaticPopup_Hide("BFMGR_INVITED_TO_ENTER");
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		if(lowLevel) then
			StaticPopup_Show("BFMGR_PLAYER_LOW_LEVEL", areaName, nil, arg1);
		elseif (playerExited and battleActive and not relocated) then
			StaticPopup_Show("BFMGR_PLAYER_EXITED_BATTLE", areaName, nil, arg1);
		end
		PVP_UpdateStatus(false);
	elseif ( event == "BATTLEFIELD_MGR_ENTERED" ) then
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE");
		StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE_WARMUP");
		StaticPopup_Hide("BFMGR_INVITED_TO_ENTER");
		StaticPopup_Hide("BFMGR_EJECT_PENDING");
		PVP_UpdateStatus(false);
	elseif ( event == "WARGAME_REQUESTED" ) then
		local challengerName, bgName, timeout = ...;
		PVPFramePopup_SetupPopUp(event, challengerName, bgName, timeout);
	elseif ( event == "PVP_RATED_STATS_UPDATE" ) then
		PVPQueueFrame_UpdateCurrencies(self);
	elseif ( event == "PVP_REWARDS_UPDATE" ) then
		PVPQueueFrame_UpdateCurrencies(self);
	elseif ( event == "BATTLEFIELDS_SHOW" ) then
		local isArena, bgID = ...;
		if (isArena) then
			PVPUIFrame_ShowFrame("PVPQueueFrame", ConquestFrame);
		else
			PVPUIFrame_ShowFrame("PVPQueueFrame", HonorFrame);
			HonorFrame_SetType("specific");
			HonorFrameSpecificList_FindAndSelectBattleground(bgID);
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		HonorFrameBonusFrame_UpdateExcludedBattlegrounds();
	end
end

function PVPQueueFrame_SetCategoryButtonState(button, enabled)
	if ( enabled ) then
		button.Background:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
		button.Name:SetFontObject("GameFontNormalLarge");
	else
		button.Background:SetTexCoord(0.00390625, 0.87890625, 0.67187500, 0.75000000);
		button.Name:SetFontObject("GameFontDisableLarge");
	end
	SetDesaturation(button.Icon, not enabled);
	SetDesaturation(button.Ring, not enabled);
	button:SetEnabled(enabled);
end

function PVPQueueFrame_GetSelection(self)
	return self.selection;
end

function PVPQueueFrame_Update(self, frame)
	PVPQueueFrame_ShowFrame(frame);
end


function PVPQueueFrame_UpdateCurrencies(self)
	ConquestFrame_UpdateConquestBar(ConquestFrame)
	local _, ratedBGreward = GetPersonalRatedBGInfo();
	ConquestFrame.RatedBGReward:SetText(ratedBGreward);
	local _, currencyAmount = GetCurrencyInfo(HONOR_CURRENCY);
	self.CategoryButton1.CurrencyAmount:SetText(currencyAmount);
	_, currencyAmount = GetCurrencyInfo(CONQUEST_CURRENCY);
	self.CategoryButton2.CurrencyAmount:SetText(currencyAmount);
end

function PVPQueueFrame_OnShow(self)
	PVPUIFrame.TitleText:SetText(PLAYER_V_PLAYER);
	PVPUIFrame.TopTileStreaks:Show()
end

function PVPQueueFrame_ShowFrame(frame)
	frame = frame or PVPQueueFrame.selection or HonorFrame;
	-- hide the other frames and select the right button
	for index, frameName in pairs(pvpFrames) do
		local pvpFrame = _G[frameName];
		if ( pvpFrame == frame ) then
			PVPQueueFrame_SelectButton(index);
		else
			pvpFrame:Hide();
		end
	end
	frame:Show();
	PVPQueueFrame.selection = frame;	
end

function PVPQueueFrame_SelectButton(index)
	local self = PVPQueueFrame;
	for i = 1, #pvpFrames do
		local button = self["CategoryButton"..i];
		if ( i == index ) then
			button.Background:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188);
		else
			button.Background:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
		end
	end
end

function PVPQueueFrameButton_OnClick(self)
	local frameName = pvpFrames[self:GetID()];
	PVPQueueFrame_ShowFrame(_G[frameName]);
end

---------------------------------------------------------------
-- HONOR FRAME
---------------------------------------------------------------

local BlacklistIDs = { };

function HonorFrame_OnLoad(self)
	self.SpecificFrame.scrollBar.doNotHide = true;
	self.SpecificFrame.update = HonorFrameSpecificList_Update;
	HybridScrollFrame_CreateButtons(self.SpecificFrame, "PVPSpecificBattlegroundButtonTemplate", -2, -1);

	UIDropDownMenu_SetWidth(HonorFrameTypeDropDown, 160);
	UIDropDownMenu_Initialize(HonorFrameTypeDropDown, HonorFrameTypeDropDown_Initialize);
	HonorFrame_SetType("bonus");
	
	for i = 1, MAX_BLACKLIST_BATTLEGROUNDS do
		local mapID = GetBlacklistMap(i);
		if ( mapID > 0 ) then
			BlacklistIDs[mapID] = true;
		end
	end
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW");
	self:RegisterEvent("PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
end

function HonorFrame_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		HonorFrameSpecificList_Update();
		HonorFrameBonusFrame_Update();
		PVP_UpdateStatus(false, nil);
	elseif ( event == "PVPQUEUE_ANYWHERE_SHOW" or event ==  "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE"
			or event == "PVP_RATED_STATS_UPDATE") then
		HonorFrameSpecificList_Update();
		HonorFrameBonusFrame_Update();
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		HonorFrame_UpdateQueueButtons();
	end
end	

function HonorFrameTypeDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = BONUS_BATTLEGROUNDS;
	info.value = "bonus";
	info.func = HonorFrameTypeDropDown_OnClick;
	info.checked = HonorFrame.type == info.value;	
	UIDropDownMenu_AddButton(info);

	info.text = SPECIFIC_BATTLEGROUNDS;
	info.value = "specific";
	info.func = HonorFrameTypeDropDown_OnClick;
	info.checked = HonorFrame.type == info.value;	
	UIDropDownMenu_AddButton(info);
end

function HonorFrameTypeDropDown_OnClick(self)
	HonorFrame_SetType(self.value);
end

function HonorFrame_SetType(value)
	HonorFrame.type = value;
	UIDropDownMenu_SetSelectedValue(HonorFrameTypeDropDown, value);
	
	if ( value == "specific" ) then
		HonorFrame.SpecificFrame:Show();
		HonorFrame.BonusFrame:Hide();
	elseif ( value == "bonus" ) then
		HonorFrame.SpecificFrame:Hide();
		HonorFrame.BonusFrame:Show();	
	end
end

function HonorFrame_UpdateQueueButtons()
	local HonorFrame = HonorFrame;
	local canQueue;
	if ( HonorFrame.type == "specific" ) then
		if ( HonorFrame.SpecificFrame.selectionID ) then
			canQueue = true;
		end
	elseif ( HonorFrame.type == "bonus" ) then
		if ( HonorFrame.BonusFrame.selectedButton ) and ( HonorFrame.BonusFrame.selectedButton.canQueue ) then
			canQueue = true;
		end
	end

	if ( canQueue ) then
		HonorFrame.SoloQueueButton:Enable();
		if ( IsInGroup() and UnitIsGroupLeader("player") ) then
			HonorFrame.GroupQueueButton:Enable();
		else
			HonorFrame.GroupQueueButton:Disable();
		end	
	else
		HonorFrame.SoloQueueButton:Disable();
		HonorFrame.GroupQueueButton:Disable();	
	end
end

function HonorFrame_Queue(isParty, forceSolo)
	if (not isParty and not forceSolo and GetNumGroupMembers() > 1) then
		StaticPopup_Show("CONFIRM_JOIN_SOLO");
		return;
	end
	local HonorFrame = HonorFrame;
	if ( HonorFrame.type == "specific" and HonorFrame.SpecificFrame.selectionID ) then
		JoinBattlefield(HonorFrame.SpecificFrame.selectionID, isParty);
	elseif ( HonorFrame.type == "bonus" and HonorFrame.BonusFrame.selectedButton ) then
		if ( HonorFrame.BonusFrame.selectedButton.worldID ) then
			local pvpID = GetWorldPVPAreaInfo(HonorFrame.BonusFrame.selectedButton.worldID);
			BattlefieldMgrQueueRequest(pvpID);
		else
			JoinBattlefield(HonorFrame.BonusFrame.selectedButton.bgID, isParty);
		end
	end
end

-------- Specific BG Frame --------

function HonorFrameSpecificList_Update()
	local scrollFrame = HonorFrame.SpecificFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numBattlegrounds = GetNumBattlegroundTypes();
	local selectionID = scrollFrame.selectionID;
	local buttonCount = -offset;

	for i = 1, numBattlegrounds do
		local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers = GetBattlegroundInfo(i);
		if ( localizedName and canEnter and not isRandom ) then
			buttonCount = buttonCount + 1;
			if ( buttonCount > 0 and buttonCount <= numButtons ) then
				local button = buttons[buttonCount];
				button:Show();
				button.NameText:SetText(localizedName);
				button.InfoText:SetText("[PH]Type");
				button.SizeText:SetFormattedText(PVP_TEAMTYPE, maxPlayers, maxPlayers);
				if ( INSTANCE_TEXTURELIST[battleGroundID] ) then
					button.Icon:SetTexture(INSTANCE_TEXTURELIST[battleGroundID]);
				else
					button.Icon:SetTexture(INSTANCE_TEXTURELIST[0]);
				end
				if ( selectionID == battleGroundID ) then
					button.SelectedTexture:Show();
					button.NameText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
					button.SizeText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				else
					button.SelectedTexture:Hide();
					button.NameText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
					button.SizeText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end
				button:Show();
				button.bgID = battleGroundID;
			end
		end
	end
	buttonCount = max(buttonCount, 0);	-- safety check
	for i = buttonCount + 1, numButtons do
		buttons[i]:Hide();
	end

	local totalHeight = (buttonCount + offset) * BATTLEGROUND_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, numButtons * scrollFrame.buttonHeight);
	
	HonorFrame_UpdateQueueButtons();
end

function HonorFrameSpecificList_FindAndSelectBattleground(bgID)
	local numBattlegrounds = GetNumBattlegroundTypes();
	local buttonCount = 0;
	local bgButtonIndex = 0;

	for i = 1, numBattlegrounds do
		local localizedName, canEnter, isHoliday, isRandom, battleGroundID = GetBattlegroundInfo(i);
		if ( localizedName and canEnter and not isRandom ) then
			buttonCount = buttonCount + 1;
			if ( battleGroundID == bgID ) then
				bgButtonIndex = buttonCount;
			end
		end
	end

	if ( bgButtonIndex == 0 ) then
		-- didn't find the bg
		return;
	end

	HonorFrame.SpecificFrame.selectionID = bgID;
	-- scroll the list if necessary
	if ( numBattlegrounds > MAX_SHOWN_BATTLEGROUNDS ) then
		local offset;
		if ( bgButtonIndex <= MAX_SHOWN_BATTLEGROUNDS ) then
			-- if the bg is on the first page, scroll to the top
			offset = 0;
		elseif ( bgButtonIndex > ( numBattlegrounds - MAX_SHOWN_BATTLEGROUNDS ) ) then
			-- if the bg is on the last page, scroll to the bottom
			offset = ( numBattlegrounds - MAX_SHOWN_BATTLEGROUNDS ) * BATTLEGROUND_BUTTON_HEIGHT;
		else
			-- otherwise scroll to put that bg to the top
			offset = ( bgButtonIndex - 1 ) * BATTLEGROUND_BUTTON_HEIGHT;
		end
		HonorFrame.SpecificFrame.scrollBar:SetValue(offset);
	end

	HonorFrameSpecificList_Update();
end

function HonorFrameSpecificBattlegroundButton_OnClick(self)
	HonorFrame.SpecificFrame.selectionID = self.bgID;
	HonorFrameSpecificList_Update();
end

function IncludedBattlegroundsDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, IncludedBattlegroundsDropDown_Initialize, "MENU");
end

function IncludedBattlegroundsDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = "Included Battlegrounds"
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);
	
	info.text = RED_FONT_COLOR_CODE.."You can exclude up to"
	info.isTitle = nil;	
	info.disabled = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.text = RED_FONT_COLOR_CODE.."2 battlegrounds"
	info.isTitle = nil;	
	info.disabled = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);
	
	info.notCheckable = nil;
	
	local numBattlegrounds = GetNumBattlegroundTypes();
	local blacklistBGCount = 0;
	for _ in pairs(BlacklistIDs) do
		blacklistBGCount = blacklistBGCount + 1;
	end	

	for i = 1, numBattlegrounds do
		local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers = GetBattlegroundInfo(i);
		if ( localizedName and canEnter and not isRandom ) then
			info.text = localizedName;
			info.isNotRadio = 1;
			info.keepShownOnClick = 1;
			info.func = IncludedBattlegroundsDropDown_OnClick;
			info.value = BGMapID;
			if ( BlacklistIDs[BGMapID] ) then
				info.checked = nil;
				info.colorCode = RED_FONT_COLOR_CODE;
				info.disabled = nil;
			else
				info.checked = 1;
				info.colorCode = nil;
				if ( blacklistBGCount == MAX_BLACKLIST_BATTLEGROUNDS ) then
					info.disabled = 1;
				else
					info.disabled = nil;
				end
			end
			UIDropDownMenu_AddButton(info);
		end
	end
end

function IncludedBattlegroundsDropDown_OnClick(self)
	local mapID = self.value;
	if ( BlacklistIDs[mapID] ) then
		ClearBlacklistMap(mapID);
		BlacklistIDs[mapID] = nil;	
	else
		BlacklistIDs[mapID] = true;
		SetBlacklistMap(mapID);
	end
	HonorFrameBonusFrame_UpdateExcludedBattlegrounds();
	-- ugh, need to rerun IncludedBattlegroundsDropDown_Initialize
	IncludedBattlegroundsDropDown_Toggle();
	--IncludedBattlegroundsDropDown_Toggle();
end

function IncludedBattlegroundsDropDown_Toggle()
	ToggleDropDownMenu(1, nil, IncludedBattlegroundsDropDown);
end

-------- Bonus BG Frame --------

function HonorFrameBonusFrame_OnShow(self)
	self.updateTime = 0;
	HonorFrameBonusFrame_Update();
end

function HonorFrameBonusFrame_OnUpdate(self, elapsed)
	self.updateTime = self.updateTime + elapsed;
	if ( self.updateTime >= 1 ) then
		for i = 1, 2 do
			button = HonorFrame.BonusFrame["WorldPVP"..i.."Button"];
			local areaID, localizedName, isActive, canQueue, startTime, canEnter, minLevel, maxLevel = GetWorldPVPAreaInfo(i);
			if ( canEnter ) then
				HonorFrameBonusFrame_UpdateWorldPVPTime(button, isActive, startTime);
				button.canQueue = canQueue;
			end
		end
		self.updateTime = 0;
	end
end

function HonorFrameBonusFrame_Update()
	local playerLevel = UnitLevel("player");
	local englishFaction = UnitFactionGroup("player");	
	-- random bg
	local button = HonorFrame.BonusFrame.RandomBGButton;
	local canQueue, battleGroundID, hasWon, winHonorAmount, winConquestAmount, lossHonorAmount, lossConquestAmount, minLevel, maxLevel = GetRandomBGInfo();
	HonorFrameBonusFrame_SetButtonState(button, canQueue, minLevel);
	if ( canQueue ) then
		button.DiceButton:Show();
	else
		button.DiceButton:Hide();
	end
	HonorFrameBonusFrame_UpdateExcludedBattlegrounds();
	button.canQueue = canQueue;
	button.bgID = battleGroundID;
	-- call to arms
	button = HonorFrame.BonusFrame.CallToArmsButton;
	local canQueue, bgName, battleGroundID, hasWon, winHonorAmount, winConquestAmount, lossHonorAmount, lossConquestAmount, minLevel, maxLevel = GetHolidayBGInfo();
	HonorFrameBonusFrame_SetButtonState(button, canQueue, minLevel);
	button.BattlegroundName:SetText(bgName);
	if ( canQueue ) then
		button.BattlegroundName:SetTextColor(0.7, 0.7, 0.7);
	else
		button.BattlegroundName:SetTextColor(0.4, 0.4, 0.4);
	end
	button.canQueue = canQueue;
	button.bgID = battleGroundID;
	-- rewards for battlegrounds
	local rewardIndex = 0;
	if ( winConquestAmount and winConquestAmount > 0 ) then
		rewardIndex = rewardIndex + 1;
		local frame = HonorFrame.BonusFrame["BattlegroundReward"..rewardIndex];
		frame:Show();
		frame.Icon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..englishFaction);
		frame.Amount:SetText(winConquestAmount);
	end
	if ( winHonorAmount and winHonorAmount > 0 ) then
		rewardIndex = rewardIndex + 1;
		local frame = HonorFrame.BonusFrame["BattlegroundReward"..rewardIndex];
		frame:Show();
		frame.Icon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor-"..englishFaction);
		frame.Amount:SetText(winHonorAmount);
	end
	for i = rewardIndex + 1, 2 do
		HonorFrame.BonusFrame["BattlegroundReward"..i]:Hide();
	end
	-- world pvp
	for i = 1, 2 do
		button = HonorFrame.BonusFrame["WorldPVP"..i.."Button"];
		local areaID, localizedName, isActive, canQueue, startTime, canEnter, minLevel, maxLevel = GetWorldPVPAreaInfo(i);
		button.Title:SetText(localizedName);
		HonorFrameBonusFrame_SetButtonState(button, canEnter, minLevel);		
		if ( canEnter ) then
			HonorFrameBonusFrame_UpdateWorldPVPTime(button, isActive, startTime);
		else
			button.InProgressText:Hide();
			button.NextBattleText:Hide();
			button.TimeText:Hide();
		end
		button.canQueue = canQueue;
		button.worldID = i;
	end
	-- TODO: rewards for world pvp
	-- queue buttons
	HonorFrame_UpdateQueueButtons();
end

function HonorFrameBonusFrame_UpdateExcludedBattlegrounds()
	local bgNames;
	for i = 1, MAX_BLACKLIST_BATTLEGROUNDS do
		local mapName = GetBlacklistMapName(i);
		if ( mapName ) then
			if ( bgNames ) then
				bgNames = bgNames.." & "..mapName;
			else
				bgNames = mapName;
			end
		end
	end
	if ( bgNames ) then
		HonorFrame.BonusFrame.RandomBGButton.ThumbTexture:Show();
		HonorFrame.BonusFrame.RandomBGButton.ExcludedBattlegrounds:SetText(bgNames);
	else
		HonorFrame.BonusFrame.RandomBGButton.ThumbTexture:Hide();
		HonorFrame.BonusFrame.RandomBGButton.ExcludedBattlegrounds:SetText("");
	end
end

function HonorFrameBonusFrame_SelectButton(button)
	if ( HonorFrame.BonusFrame.selectedButton ) then
		HonorFrame.BonusFrame.selectedButton.SelectedTexture:Hide();
	end
	button.SelectedTexture:Show();
	HonorFrame.BonusFrame.selectedButton = button;
	HonorFrame_UpdateQueueButtons();
end

function HonorFrameBonusFrame_SetButtonState(button, enable, minLevel)
	if ( enable ) then
		button.Title:SetTextColor(1, 1, 1);
		button.DisabledTexture:Hide();
		button:Enable();
		button.UnlockText:Hide();
		button.MinLevelText:Hide();
	else		
		if ( button == HonorFrame.BonusFrame.selectedButton ) then
			button.SelectedTexture:Hide();
		end
		button.Title:SetTextColor(0.4, 0.4, 0.4);
		button.DisabledTexture:Show();
		button:Disable();
		button.UnlockText:Show();
		button.MinLevelText:Show();
		button.MinLevelText:SetFormattedText(UNIT_LEVEL_TEMPLATE, minLevel);
	end
end

function HonorFrameBonusFrame_UpdateWorldPVPTime(button, isActive, startTime)
	if ( isActive ) then
		button.InProgressText:Show();
		button.NextBattleText:Hide();
		button.TimeText:Hide();
	else
		button.InProgressText:Hide();
		button.NextBattleText:Show();
		button.TimeText:Show();
		button.TimeText:SetText(SecondsToTime(startTime));
	end
end

---------------------------------------------------------------
-- CONQUEST FRAME
---------------------------------------------------------------

CONQUEST_SIZE_STRINGS = { ARENA_2V2, ARENA_3V3, ARENA_5V5, BATTLEGROUND_10V10 };
CONQUEST_SIZES = {2, 3, 5, 10};
ARENA_BUTTONS = {};

function ConquestFrame_OnLoad(self)

	ARENA_BUTTONS = {ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.Arena5v5};
	
	local factionGroup = UnitFactionGroup("player");
	self.ArenaRewardSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);
	self.RatedBGRewardSymbol:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);
	
	local _, ratedBGreward = GetPersonalRatedBGInfo();
	self.RatedBGReward:SetText(ratedBGreward);
	
	local name = UnitName("player");
	local _, class = UnitClass("player");
	local color = RAID_CLASS_COLORS[class].colorStr;
	self.RatedBG.TeamNameText:SetText("|c"..color..name..FONT_COLOR_CODE_CLOSE);
	
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("ARENA_TEAM_UPDATE");
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
end

function ConquestFrame_OnEvent(self, event, ...)
	ConquestFrame_OnUpdate(self);
end

function ConquestFrame_OnShow(self)
	
	RequestRatedBattlegroundInfo();
	RequestPVPRewards();
	RequestPVPOptionsEnabled();
	
	ConquestFrame_OnUpdate(self);
	
end

function ConquestFrame_OnUpdate(self)
	
	ConquestFrame_UpdateConquestBar(self);
	ConquestFrame_UpdateArenas(self);
	ConquestFrame_UpdateRatedBG(self);
	ConquestFrame_UpdateJoinButton();
end

function ConquestFrame_UpdateConquestBar(self)
	currencyName, currencyAmount = GetCurrencyInfo(CONQUEST_CURRENCY);
	local pointsThisWeek, maxPointsThisWeek, tier2Quantity, tier2Limit, tier1Quantity, tier1Limit, randomPointsThisWeek, maxRandomPointsThisWeek = GetPVPRewards();
	-- just want a plain bar
	CapProgressBar_Update(self.ConquestBar, 0, 0, nil, nil, pointsThisWeek, maxPointsThisWeek);
	self.ConquestBar.label:SetFormattedText(CURRENCY_THIS_WEEK, currencyName);
end

function ConquestFrame_UpdateArenas(self)
	
	local _, arenaReward = GetPersonalRatedArenaInfo(1);
	self.ArenaReward:SetText(arenaReward);
	if (arenaReward == 0) then
		RequestRatedArenaInfo(1);
	end
	
	for i=1, 3 do
		ArenaTeamRoster(i);
		local arenaButton = ARENA_BUTTONS[i];
		local teamName, teamSize, teamRating, teamPlayed, teamWins,  seasonTeamPlayed, 
		seasonTeamWins, playerPlayed, seasonPlayerPlayed, teamRank, playerRating = GetArenaTeam(i);
		if (teamName) then
			arenaButton.hasTeam = true;
			arenaButton.TeamNameText:SetText(teamName);
			arenaButton.RatingText:SetText(teamRating);
			arenaButton.RatingLabel:Show();
		else
			arenaButton.hasTeam = nil;
			arenaButton.TeamNameText:SetFormattedText(NO_ARENA_TEAM, CONQUEST_SIZE_STRINGS[i]);
			arenaButton.RatingText:SetText("");
			arenaButton.RatingLabel:Hide();
			arenaButton.TeamNameText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			arenaButton.TeamSizeText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end
	end
	
end

function ConquestFrame_UpdateRatedBG(self)
	
	local personalBGRating, ratedBGreward, _, _, _, _, weeklyWins, weeklyPlayed = GetPersonalRatedBGInfo();
	self.RatedBG.RatingText:SetText(personalBGRating);
	
end

function ConquestFrame_UpdateJoinButton()
	local button = ConquestFrame.JoinButton;
	local groupSize = GetNumGroupMembers();
	if (ConquestFrame.selectedButton) then
		if (CONQUEST_SIZES[ConquestFrame.selectedButton.id] == groupSize) then
			button:Enable();
			return;
		end
	end
	button:Disable();
end

function ConquestFrameButton_OnClick(self, button)
	CloseDropDownMenus();
	if ( ConquestFrame.selectedButton ) then
		ConquestFrame.selectedButton.SelectedTexture:Hide();
	end
	self.SelectedTexture:Show();
	ConquestFrame.selectedButton = self;
	ConquestFrame_UpdateJoinButton();
	
	if (button == "RightButton") then
		local team = {};
		local numMembers = GetNumArenaTeamMembers(self.id, 1);
		if (numMembers == 0) then
			return;
		end
		local index = 1;
		for i=1, numMembers do
			local name, _, _, class, online = GetArenaTeamRosterInfo(self.id, i);
			if (name ~= UnitName("player")) then
				team[index] = {["class"] = class, ["name"] = name, ["online"] = online};
				index = index + 1;
			end
		end
		UIDropDownMenu_Initialize(ConquestFrame.ArenaInviteMenu, ArenaInviteMenu_Init, "MENU", nil, team);
		ToggleDropDownMenu(1, nil, ConquestFrame.ArenaInviteMenu, self, 150, 30, team);
	end
end

function ConquestFrameJoinButton_OnClick(self)
	if (ConquestFrame.selectedButton.id < 4) then
		JoinArena();
	elseif (ConquestFrame.selectedButton.id == 4) then
		JoinRatedBattlefield();
	end
end

local INVITE_DROPDOWN = 1;
function ArenaInviteMenu_Init(self, level, team)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.value = nil;
	
	if (level == 1 and (not team or not team[1])) then
		info.text = INVITE_TEAM_MEMBERS;
		info.disabled = true;
		info.func =  nil;
		info.hasArrow = true;
		info.value = INVITE_DROPDOWN;
		UIDropDownMenu_AddButton(info, level)
		
		info.text = CANCEL
		info.disabled = nil;
		info.hasArrow = nil;
		info.value = nil;
		info.func = nil
		UIDropDownMenu_AddButton(info, level)
		return;
	end
	
	if (UIDROPDOWNMENU_MENU_VALUE == INVITE_DROPDOWN) then
		for i=1, #team do
			if (team[i].online) then
				local color = RAID_CLASS_COLORS[team[i].class].colorStr
				info.text = "|c"..color..team[i].name..FONT_COLOR_CODE_CLOSE;
				info.func = function (menu, name) InviteToGroup(name); end
				info.arg1 = team[i].name;
				info.disabled = nil;
			else
				info.disabled = true;
				info.text = team[i].name;
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end
	
	if (level == 1) then
		info.text = INVITE_TEAM_MEMBERS;
		info.func =  nil;
		info.hasArrow = true;
		info.value = INVITE_DROPDOWN;
		info.menuList = team;
		UIDropDownMenu_AddButton(info, level)
		info.text = CANCEL
		info.value = nil;
		info.hasArrow = nil;
		info.menuList = nil;
		UIDropDownMenu_AddButton(info, level)
	end
end
--------- Conquest Tooltips ----------

function PVPFrameConquestBar_OnEnter(self)
	local currencyName = GetCurrencyInfo(CONQUEST_CURRENCY);
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(MAXIMUM_REWARD);
	GameTooltip:AddLine(format(CURRENCY_RECEIVED_THIS_WEEK, currencyName), 1, 1, 1, true);
	GameTooltip:AddLine(" ");

	local pointsThisWeek, maxPointsThisWeek, tier2Quantity, tier2Limit, tier1Quantity, tier1Limit, randomPointsThisWeek, maxRandomPointsThisWeek = GetPVPRewards();
	
	local r, g, b = 1, 1, 1;
	local capped;
	if ( pointsThisWeek >= maxPointsThisWeek ) then
		r, g, b = 0.5, 0.5, 0.5;
		capped = true;
	end
	GameTooltip:AddDoubleLine(FROM_ALL_SOURCES, format(CURRENCY_WEEKLY_CAP_FRACTION, pointsThisWeek, maxPointsThisWeek), r, g, b, r, g, b);
	
	if ( capped or tier2Quantity >= tier2Limit ) then
		r, g, b = 0.5, 0.5, 0.5;
	else
		r, g, b = 1, 1, 1;
	end
	GameTooltip:AddDoubleLine(" -"..FROM_RATEDBG, format(CURRENCY_WEEKLY_CAP_FRACTION, tier2Quantity, tier2Limit), r, g, b, r, g, b);	
	
	if ( capped or tier1Quantity >= tier1Limit ) then
		r, g, b = 0.5, 0.5, 0.5;
	else
		r, g, b = 1, 1, 1;
	end
	GameTooltip:AddDoubleLine(" -"..FROM_ARENA, format(CURRENCY_WEEKLY_CAP_FRACTION, tier1Quantity, tier1Limit), r, g, b, r, g, b);

	if ( capped or randomPointsThisWeek >= maxRandomPointsThisWeek ) then
		r, g, b = 0.5, 0.5, 0.5;
	else
		r, g, b = 1, 1, 1;
	end
	GameTooltip:AddDoubleLine(" -"..FROM_RANDOMBG, format(CURRENCY_WEEKLY_CAP_FRACTION, randomPointsThisWeek, maxRandomPointsThisWeek), r, g, b, r, g, b);

	GameTooltip:Show();
end

function ConquestFrameButton_OnEnter(self)
	if (self.hasTeam or self.id == 4) then --if this is an arena button and the team exists, or if it's the rated BGs
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		if (self.id < #CONQUEST_SIZES) then --if this an arena, not the rated BG
			local teamName, _, teamRating, teamPlayed, teamWins = GetArenaTeam(self.id);
			local _, _, _, _, _, _, bestRating = GetPersonalRatedArenaInfo(self.id);
			GameTooltip:SetText(CONQUEST_SIZE_STRINGS[self.id].." "..teamName);
			GameTooltip:AddLine(ARENA_WEEKLY_STATS, 1, 1, 1);
			GameTooltip:AddLine(" ");
			
			GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..PVP_CURRENT_RATING..FONT_COLOR_CODE_CLOSE.." "..teamRating, 1, 1, 1);
			local losses = teamPlayed - teamWins;
			GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..PVP_RECORD..FONT_COLOR_CODE_CLOSE.." "..teamWins.."-"..losses, 1, 1, 1);
			GameTooltip:AddLine(" ");
			
			GameTooltip:AddLine(PVP_INVITE_TEAM_TOOLTIP, 1, 1, 1);
		else
			GameTooltip:SetText(self.TeamNameText:GetText());
			GameTooltip:AddLine(ARENA_WEEKLY_STATS, 1, 1, 1);
			GameTooltip:AddLine(" ");
			
			local rating, _, _, _, _, _, bestRating = GetPersonalRatedBGInfo()
			GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..PVP_CURRENT_RATING..FONT_COLOR_CODE_CLOSE.." "..rating, 1, 1, 1);
			GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..PVP_BEST_RATING..FONT_COLOR_CODE_CLOSE.." "..bestRating, 1, 1, 1);
		end
		GameTooltip:Show();
	end
end

---------------------------------------------------------------
-- WAR GAMES FRAME
---------------------------------------------------------------

function WarGamesFrame_OnLoad(self)
	self.scrollFrame.scrollBar.doNotHide = true;
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");		-- for leadership changes
	self.scrollFrame.update = WarGamesFrame_Update;
	self.scrollFrame.dynamic =  WarGamesFrame_GetTopButton;
	HybridScrollFrame_CreateButtons(self.scrollFrame, "PVPWarGameButtonTemplate", 0, -1);
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

function WarGamesFrame_GetTopButton(offset)
	local heightLeft = offset;
	local buttonHeight;
	local numWarGames = GetNumWarGameTypes();

	-- find the other header's position if needed (assuming collapsing and expanding headers are a rare occurence for a list this small)
	if ( not WarGamesFrame.otherHeaderIndex ) then
		WarGamesFrame.otherHeaderIndex = 0;
		for i = 2, numWarGames do
			local name = GetWarGameTypeInfo(i);
			if ( name == "header" ) then
				WarGamesFrame.otherHeaderIndex = i;
				break;
			end
		end
	end
	-- determine top button
	local otherHeaderIndex = WarGamesFrame.otherHeaderIndex;
	for i = 1, numWarGames do
		if ( i == 1 or i == otherHeaderIndex ) then
			buttonHeight =	WARGAME_HEADER_HEIGHT;
		else
			buttonHeight = BATTLEGROUND_BUTTON_HEIGHT;
		end
		if ( heightLeft - buttonHeight <= 0 ) then
			return i - 1, heightLeft;
		else
			heightLeft = heightLeft - buttonHeight;
		end
	end
end

function WarGamesFrame_Update()
	local scrollFrame = WarGamesFrame.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local numWarGames = GetNumWarGameTypes();
	local selectedIndex = GetSelectedWarGameType();
	
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i;
		if index <= numWarGames  then
			local name, pvpType, collapsed, id, minPlayers, maxPlayers, isRandom = GetWarGameTypeInfo(index);
			if ( name == "header" ) then
				button:SetHeight(WARGAME_HEADER_HEIGHT);
				button.Header:Show();
				button.Entry:Hide();
				if ( pvpType == INSTANCE_TYPE_BG ) then
					button.Header.NameText:SetText(BATTLEGROUND);
				elseif ( pvpType == INSTANCE_TYPE_ARENA ) then
					button.Header.NameText:SetText(ARENA);
				else
					button.Header.NameText:SetText(UNKNOWN);
				end
				if ( collapsed ) then
					button.Header:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				else
					button.Header:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up"); 
				end
			else
				button:SetHeight(BATTLEGROUND_BUTTON_HEIGHT);
				button.Header:Hide();
				local warGame = button.Entry;
				warGame:Show();
				warGame.NameText:SetText(name);
				-- arena?
				if ( pvpType == INSTANCE_TYPE_ARENA ) then
					minPlayers = 2;
					warGame.SizeText:SetText(WARGAME_ARENA_SIZES);
				else
					warGame.SizeText:SetFormattedText(PVP_TEAMTYPE, maxPlayers, maxPlayers);
				end
				warGame.InfoText:SetFormattedText(WARGAME_MINIMUM, minPlayers, minPlayers);
				if ( INSTANCE_TEXTURELIST[id] ) then
					warGame.Icon:SetTexture(INSTANCE_TEXTURELIST[id]);
				else
					warGame.Icon:SetTexture(INSTANCE_TEXTURELIST[0]);
				end
				if ( selectedIndex == index ) then
					warGame.SelectedTexture:Show();
					warGame.NameText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
					warGame.SizeText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				else
					warGame.SelectedTexture:Hide();
					warGame.NameText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
					warGame.SizeText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end
			end
			button:Show();
			button.index = index;
		else
			button:Hide();
		end
	end

	-- keeping it somewhat easy to expand past 2 headers if needed
	local numHeaders = 1;
	if ( WarGamesFrame.otherHeaderIndex and WarGamesFrame.otherHeaderIndex > 0 ) then
		numHeaders = numHeaders + 1;
	end
	
	local totalHeight = numHeaders * WARGAME_HEADER_HEIGHT + (numWarGames - numHeaders) * BATTLEGROUND_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, 208);
	
	WarGameStartButton_Update();
end

function WarGameButtonHeader_OnClick(self)
	local index = self:GetParent().index;
	local name, pvpType, collapsed = GetWarGameTypeInfo(index);
	if ( collapsed ) then
		ExpandWarGameHeader(index);
	else
		CollapseWarGameHeader(index);
	end
	WarGamesFrame.otherHeaderIndex = nil;	-- header location probably changed;
	WarGamesFrame_Update();
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function WarGameButton_OnEnter(self)
	self.NameText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	self.SizeText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end

function WarGameButton_OnLeave(self)
	if ( self:GetParent().index ~= GetSelectedWarGameType() ) then
		self.NameText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		self.SizeText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end

function WarGameButton_OnClick(self)
	local index = self:GetParent().index;
	SetSelectedWarGameType(index);
	WarGamesFrame_Update();
	PlaySound("igMainMenuOptionCheckBoxOn");
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
		if ( pvpType == INSTANCE_TYPE_ARENA ) then
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
		StartWarGame(UnitName("target"), name);
	end
end

---------------------------------------------------------------
-- ARENA TEAM MANAGEMENT
---------------------------------------------------------------

function PVPArenaTeamsFrame_OnLoad(self)
	self:RegisterEvent("ARENA_TEAM_UPDATE");
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");
end

function PVPArenaTeamsFrame_OnEvent(self, event, ...)
	if (event == "ARENA_TEAM_UPDATE") then
		PVPArenaTeamsFrame_UpdateTeams(self);
		PVPArenaTeamsFrame_ShowTeam(self);
	elseif (event == "ARENA_TEAM_ROSTER_UPDATE") then
		PVPArenaTeamsFrame_ShowTeam(self);
	end
end

function PVPArenaTeamsFrame_OnShow(self)
	ArenaTeamFrame:Show();
	PVPArenaTeamsFrame_UpdateTeams(self);
	PVPArenaTeamsFrame_ShowTeam(self);
	PVPUIFrame.TopTileStreaks:Hide();
	PVPUIFrame.TitleText:SetText(ARENA_TEAMS);
end

function PVPArenaTeamsFrame_ShowTeam(self, teamIndex)
	local frame = ArenaTeamFrame;
	if (not teamIndex or teamIndex > 3) then
		teamIndex = ArenaTeamFrame.selectedTeam or self.defaultTeam;
	end
	if (not teamIndex) then
		frame.NoTeams:Show()
		return;
	else
		frame.NoTeams:Hide()
	end
	
	PVPArenaTeamsFrame_SelectButton(teamIndex);
	
	local teamName, teamSize, teamRating, gamesPlayed, gamesWon, seasonPlayed, seasonWon, playerPlayed, seasonPlayerPlayed, emblem, border, _, teamButton;
	local background = {}; 
	local emblemColor = {} ;
	local borderColor = {}; 	
	teamName, teamSize, teamRating, gamesPlayed,  gamesWon,  seasonPlayed, seasonWon, weeklyPlayerPlayed, seasonPlayerPlayed, _, _, 
	background.r, background.g, background.b, 
	emblem, emblemColor.r, emblemColor.g, emblemColor.b, 
	border, borderColor.r, borderColor.g, borderColor.b 		= GetArenaTeam(teamIndex);
	
	frame.Flag.Banner:SetVertexColor(background.r, background.g, background.b);
	frame.Flag.Emblem:SetVertexColor( emblemColor.r, emblemColor.g, emblemColor.b);
	frame.Flag.Emblem:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..emblem);
	frame.Flag.Border:SetVertexColor( borderColor.r, borderColor.g, borderColor.b );				
	frame.Flag.Border:SetTexture("Interface\\PVPFrame\\PVP-Banner-2-Border-"..border);
	
	local played, wins;
	if ( frame.seasonStats ) then
		played = seasonPlayed;
		wins = seasonWon;
		playerPlayed = seasonPlayerPlayed;
		frame.WeeklyDisplay.WeeklyText:SetText(ARENA_SEASON_STATS);
	else
		played = gamesPlayed;
		wins = gamesWon;
		playerPlayed = weeklyPlayerPlayed;
		frame.WeeklyDisplay.WeeklyText:SetText(ARENA_WEEKLY_STATS);
	end
	
	frame.TeamSize:SetText(_G["ARENA_"..teamSize.."V"..teamSize]);
	frame.Rating:SetText(teamRating);
	frame.TeamName:SetText(teamName);
	frame.Games:SetText(played);
	local gamesLost = played - wins;
	frame.Wins:SetText(wins.." - "..gamesLost);
	frame.Played:SetText(playerPlayed);
	
	local numMembers = GetNumArenaTeamMembers(teamIndex, 1);
	local button, name, rank, level, class, online, played, win, seasonPlayed, seasonWin, rating, loss;
	for i=1, MAX_ARENA_TEAM_MEMBERS do
		button = frame["TeamMember"..i];
		if (i > numMembers) then
			button:Disable();
			button.NameText:SetText("");
			button.PlayedText:SetText("");
			button.WinLossText:SetText("");
			button.RatingText:SetText("");
			button.CaptainIcon:Hide();
		else
			button:Enable();
			name, rank, level, class, online, played, win, seasonPlayed, seasonWin, rating = GetArenaTeamRosterInfo(teamIndex, i);
			local color = RAID_CLASS_COLORS[class].colorStr;
			if (online) then
				button.NameText:SetText("|c"..color..name..FONT_COLOR_CODE_CLOSE);
			else
				button.NameText:SetText(GRAY_FONT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE);
			end
			if (frame.seasonStats) then
				button.PlayedText:SetText(seasonPlayed);
				loss = seasonPlayed - seasonWin;
				button.WinLossText:SetText(seasonWin.."-"..loss);
			else
				button.PlayedText:SetText(played);
				loss = played - win;
				button.WinLossText:SetText(win.."-"..loss);
			end
			button.RatingText:SetText(rating);
			if (rank > 0) then
				button.CaptainIcon:Hide();
			else
				button.CaptainIcon:Show();
			end
		end
	end
end

function ArenaTeamsFrameWeeklyToggle_OnClick(self)
	ArenaTeamFrame.seasonStats = not ArenaTeamFrame.seasonStats;	
	PVPArenaTeamsFrame_ShowTeam(PVPArenaTeamsFrame, ArenaTeamFrame.selectedTeam);
end

function PVPArenaTeamsTeamButton_OnClick(self)
	if (self.hasTeam) then
		PVPArenaTeamsFrame_ShowTeam(PVPArenaTeamsFrame, self:GetID());
	else
		local teamSize = CONQUEST_SIZES[self:GetID()];
		PVPBannerFrame.teamSize = teamSize;
		ShowUIPanel(PVPBannerFrame);
		PVPBannerFrameTitleText:SetText(_G["ARENA_"..teamSize.."V"..teamSize]);
	end
end

function PVPArenaTeamsFrame_SelectButton(index)
	ArenaTeamFrame.selectedTeam = index;
	local self = PVPArenaTeamsFrame;
	for i = 1, 3 do
		local button = self["Team"..i];
		if ( i == index ) then
			button.Background:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188);
		else
			button.Background:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
		end
	end
end

function PVPArenaTeamsFrame_UpdateTeams(self)
	
	self.defaultTeam = nil;
	ArenaTeamFrame.selectedTeam = nil;
	local bannerName = "";
	
	local teamName, teamSize, teamRating, emblem, border, _, teamButton;
	local background = {}; 
	local emblemColor = {} ;
	local borderColor = {}; 		

	for i=1, MAX_ARENA_TEAMS do
		--the ammount of parameter this returns is absurd
		teamName, teamSize, teamRating, _,  _,  _, _, _, _, _, _, 
		background.r, background.g, background.b, 
		emblem, emblemColor.r, emblemColor.g, emblemColor.b, 
		border, borderColor.r, borderColor.g, borderColor.b 		= GetArenaTeam(i);			

		teamButton = self["Team"..i];
		
		if teamName then		
			teamButton.hasTeam = true;
			teamButton.Flag.Banner:SetVertexColor(background.r, background.g, background.b);
			teamButton.Flag.Emblem:Show();
			teamButton.Flag.Emblem:SetVertexColor( emblemColor.r, emblemColor.g, emblemColor.b);
			teamButton.Flag.Emblem:SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..emblem);
			teamButton.Flag.Border:Show();
			teamButton.Flag.Border:SetVertexColor( borderColor.r, borderColor.g, borderColor.b );				
			teamButton.Flag.Border:SetTexture("Interface\\PVPFrame\\PVP-Banner-2-Border-"..border);
			
			teamButton.TeamSize:Show();
			teamButton.TeamSize:SetText(CONQUEST_SIZE_STRINGS[i])
			teamButton.RatingLabel:Show();
			teamButton.Rating:Show();
			teamButton.Rating:SetText(teamRating);
			teamButton.TeamName:SetText(teamName);
			
			if not self.defaultTeam then
				self.defaultTeam = i;	
			end
		else
			teamButton.hasTeam = nil
			teamButton.Flag.Banner:SetVertexColor(1, 1, 1);
			teamButton.Flag.Emblem:Hide();
			teamButton.Flag.Border:Hide();
			teamButton.TeamSize:Hide(); 
			teamButton.RatingLabel:Hide();
			teamButton.Rating:Hide();
			teamButton.TeamName:SetFormattedText(CREATE_NEW_ARENA_TEAM, CONQUEST_SIZE_STRINGS[i])
			teamButton.TeamName:SetPoint("LEFT", teamButton, "LEFT", 55, 0);
			if  self.selectedTeam == self["Team"..i] then
				self.selectedTeam = nil;
			end
		end
		if (teamButton.hasTeam) then
			local _, height = teamButton.TeamName:GetFont();
			if (floor(teamButton.TeamName:GetHeight()) > height) then
				teamButton.TeamSize:SetPoint("BOTTOMLEFT", teamButton, "BOTTOMLEFT", 55, 5);
				teamButton.TeamName:SetPoint("BOTTOMLEFT", teamButton.TeamSize, "TOPLEFT", 0, 5);
				teamButton.RatingLabel:SetPoint("BOTTOMRIGHT", teamButton, "BOTTOMRIGHT", -40, 5);
			else
				teamButton.TeamSize:SetPoint("BOTTOMLEFT", teamButton, "BOTTOMLEFT", 55, 10);
				teamButton.TeamName:SetPoint("BOTTOMLEFT", teamButton.TeamSize, "TOPLEFT", 0, 10);
				teamButton.RatingLabel:SetPoint("BOTTOMRIGHT", teamButton, "BOTTOMRIGHT", -40, 10);
			end
		end
	end
	
end

function ArenaTeamMember_DropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "TEAM", nil, ArenaTeamMemberDropDown.name);
end

function ArenaTeamMember_ShowDropdown(name, online)
	HideDropDownMenu(1);
	local dropdown = ArenaTeamMemberDropDown;
	if ( not IsArenaTeamCaptain(ArenaTeamFrame.selectedTeam) ) then
		if ( online ) then
			dropdown.initialize = ArenaTeamMember_DropDown_Initialize;
			dropdown.displayMode = "MENU";
			dropdown.name = name;
			dropdown.online = online;
			ToggleDropDownMenu(1, nil, dropdown, "cursor");
		end
	else
		dropdown.initialize = ArenaTeamMember_DropDown_Initialize;
		dropdown.displayMode = "MENU";
		dropdown.name = name;
		dropdown.online = online;
		ToggleDropDownMenu(1, nil, dropdown, "cursor");
	end
end
