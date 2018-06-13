
MAX_ARENA_TEAM_MEMBERS = 10;

BATTLEGROUND_BUTTON_HEIGHT = 40;

local MAX_SHOWN_BATTLEGROUNDS = 8;
local NO_ARENA_SEASON = 0;

local RANDOM_BG_REWARD = "randombg";
local SKIRMISH_REWARD = "skirmish";
local RATED_BG_REWARD = "ratedbg";
local ARENA_2V2_REWARD = "arena2v2";
local ARENA_3V3_REWARD = "arena3v3";
local BG_BRAWL_REWARD = "bgbrawl";
local ARENA_BRAWL_REWARD = "arenabrawl";
local LFG_BRAWL_REWARD = "lfgbrawl";
local RANDOM_EPIC_BG_REWARD = "epicrandombg";

local REWARDS_AT_MAX_LEVEL = {
	[RANDOM_BG_REWARD] = {
		["FirstWin"] = 143680, 
		["NthWin"] = 138880,
	},
	[SKIRMISH_REWARD] = {
		["FirstWin"] = 143713,
		["NthWin"] = 138864,
	},
	[RATED_BG_REWARD] = {
		["FirstWin"] = 147203,
		["NthWin"] = 147200,
	},
	[ARENA_2V2_REWARD] = {
		["FirstWin"] = 147201,
		["NthWin"] = 147199,
	},
	[ARENA_3V3_REWARD] = {
		["FirstWin"] = 147202,
		["NthWin"] = 147198,
	},
	[BG_BRAWL_REWARD] = {
		["FirstWin"] = 143680,
		["NthWin"] = 138880,
	},
	[ARENA_BRAWL_REWARD] = {
		["FirstWin"] = 143713,
		["NthWin"] = 138864,
	},
	[LFG_BRAWL_REWARD] = {
		["FirstWin"] = 143713,
		["NthWin"] = 138864,
	},
	[RANDOM_EPIC_BG_REWARD] = {
	-- TODO
		--["FirstWin"] = ,
		--["NthWin"] = ,
	},	
}

function GetMaxLevelReward(bracketType, hasFirstWin)
	local factionGroup = UnitFactionGroup("player");
	if (UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEVEL_CURRENT]) then
		return nil;
	end

	
	local id;

	local key = hasFirstWin and "NthWin" or "FirstWin";

	local ARENA_2V2_ID = 1;
	local ARENA_3V3_ID = 2;
	local RATED_BG_ID = 4;
	if (REWARDS_AT_MAX_LEVEL[bracketType]) then
		id = REWARDS_AT_MAX_LEVEL[bracketType][key];
	elseif (bracketType == RANDOM_BATTLEGROUNDS) then
		id = REWARDS_AT_MAX_LEVEL[RANDOM_BG_REWARD][key];
	elseif (bracketType == SKIRMISH) then
		id = REWARDS_AT_MAX_LEVEL[SKIRMISH_REWARD][key];
	elseif (bracketType == ARENA_2V2_ID) then
		id = REWARDS_AT_MAX_LEVEL[ARENA_2V2_REWARD][key];
	elseif (bracketType == ARENA_3V3_ID) then
		id = REWARDS_AT_MAX_LEVEL[ARENA_3V3_REWARD][key];
	elseif (bracketType == RATED_BG_ID) then
		id = REWARDS_AT_MAX_LEVEL[RATED_BG_REWARD][key];
	elseif (bracketType == RANDOM_EPIC_BATTLEGROUNDS) then
		id = REWARDS_AT_MAX_LEVEL[RANDOM_EPIC_BG_REWARD][key];
	end

	if (not id) then
		return nil;
	end

	local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(id);

	if (not name) then
		PVPUIFrame_AddItemWait(id);
	end
	return { { id=id, name=name, texture=texture, quantity=1 } };
end
 
---------------------------------------------------------------
-- PVP FRAME
---------------------------------------------------------------

local DEFAULT_BG_TEXTURE = "Interface\\PVPFrame\\RandomPVPIcon";

function PVPUIFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 2);

	if (UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0]) then
		HonorFrame.BonusFrame.WorldBattlesTexture:SetAtlas("pvpqueue-background-casual-horde", true)
	else
		HonorFrame.BonusFrame.WorldBattlesTexture:SetAtlas("pvpqueue-background-casual-alliance", true)
	end

	RequestPVPRewards();

	RequestRandomBattlegroundInstanceInfo();

	self:RegisterEvent("BATTLEFIELDS_CLOSED");

	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PVP_ROLE_UPDATE");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
		
	self.update = function(self, panel) return PVPQueueFrame_Update(PVPQueueFrame, panel); end
	self.getSelection = function(self) return PVPQueueFrame_GetSelection(PVPQueueFrame); end

	self.waitingOnItems = {};
	
	PVPQueueFrame_ShowFrame(HonorFrame);
end

function PVPUIFrame_OnShow(self)
	if (UnitLevel("player") < SHOW_PVP_LEVEL or IsKioskModeEnabled()) then
		self:Hide();
		return;
	end
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	RequestPVPRewards();

	PVPUIFrame_UpdateSelectedRoles();
	PVPUIFrame_UpdateRolesChangeable();
end

function PVPUIFrame_OnHide(self)
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	ClearBattlemaster();
end

function PVPUIFrame_OnEvent(self, event, ...)
	if (event == "BATTLEFIELDS_CLOSED") then
		if (self:IsShown()) then
			self:Hide();
		end
	elseif ( event == "VARIABLES_LOADED" or event == "PVP_ROLE_UPDATE" ) then
		PVPUIFrame_UpdateSelectedRoles();
		PVPUIFrame_UpdateRolesChangeable();
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
		PVPUIFrame_UpdateRolesChangeable();
	elseif ( event == "GET_ITEM_INFO_RECEIVED" ) then
		local id = ...;
		if (tContains(self.waitingOnItems, id)) then
			tDeleteItem(self.waitingOnItems, id);
			
			HonorFrameBonusFrame_Update();
			ConquestFrame_Update(ConquestFrame);
		end

		if (#self.waitingOnItems == 0) then
			self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
		end
	end
end

function PVPUIFrame_AddItemWait(itemid)
	local self = PVPUIFrame;

	if (not tContains(self.waitingOnItems, itemid)) then
		tinsert(self.waitingOnItems, itemid);
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	end
end

function PVPUIFrame_ToggleFrame(sidePanelName, selection)
	local self = PVPUIFrame;
	if ( self:IsShown() ) then
		HideUIPanel(self);
	else
		ShowUIPanel(self);
	end
end

function PVPUIFrame_RoleButtonClicked(self)
	PVPUIFrame_SetRoles(self:GetParent():GetParent());
end

function PVPUIFrame_SetRoles(frame)
	SetPVPRoles(frame.TankIcon.checkButton:GetChecked(),
		frame.HealerIcon.checkButton:GetChecked(),
		frame.DPSIcon.checkButton:GetChecked());
end

function PVPUIFrame_UpdateRolesChangeable()
	if ( PVPHelper_CanChangeRoles() ) then
		PVPUIFrame_UpdateAvailableRoles(HonorFrame.TankIcon, HonorFrame.HealerIcon, HonorFrame.DPSIcon);
		PVPUIFrame_UpdateAvailableRoles(ConquestFrame.TankIcon, ConquestFrame.HealerIcon, ConquestFrame.DPSIcon);
	else
		LFG_DisableRoleButton(HonorFrame.TankIcon);
		LFG_DisableRoleButton(HonorFrame.HealerIcon);
		LFG_DisableRoleButton(HonorFrame.DPSIcon);
		LFG_DisableRoleButton(ConquestFrame.TankIcon);
		LFG_DisableRoleButton(ConquestFrame.HealerIcon);
		LFG_DisableRoleButton(ConquestFrame.DPSIcon);
	end
end

function PVPUIFrame_UpdateAvailableRoles(tankButton, healButton, dpsButton)
	return LFG_UpdateAvailableRoles(tankButton, healButton, dpsButton);
end

function PVPUIFrame_UpdateSelectedRoles()
	local tank, healer, dps = GetPVPRoles();
	HonorFrame.TankIcon.checkButton:SetChecked(tank);
	HonorFrame.HealerIcon.checkButton:SetChecked(healer);
	HonorFrame.DPSIcon.checkButton:SetChecked(dps);
	ConquestFrame.TankIcon.checkButton:SetChecked(tank);
	ConquestFrame.HealerIcon.checkButton:SetChecked(healer);
	ConquestFrame.DPSIcon.checkButton:SetChecked(dps);
end


---------------------------------------------------------------
-- CATEGORY FRAME
---------------------------------------------------------------

local pvpFrames = { "HonorFrame", "ConquestFrame", "LFGListPVPStub" }

function PVPQueueFrame_OnLoad(self)
	--set up side buttons
	local englishFaction = UnitFactionGroup("player");
	SetPortraitToTexture(self.CategoryButton1.Icon, "Interface\\Icons\\achievement_bg_winwsg");
	self.CategoryButton1.Name:SetText(PVP_TAB_HONOR);

	SetPortraitToTexture(self.CategoryButton2.Icon, "Interface\\Icons\\achievement_bg_killxenemies_generalsroom");
	self.CategoryButton2.Name:SetText(PVP_TAB_CONQUEST);
	
	SetPortraitToTexture(self.CategoryButton3.Icon, "Interface\\Icons\\Achievement_General_StayClassy");
	self.CategoryButton3.Name:SetText(PVP_TAB_GROUPS);

	-- disable unusable side buttons
	if ( UnitLevel("player") < SHOW_CONQUEST_LEVEL ) then
		PVPQueueFrame_SetCategoryButtonState(self.CategoryButton2, false);
		self.CategoryButton2.tooltip = format(PVP_CONQUEST_LOWLEVEL, PVP_TAB_CONQUEST);
		PVPQueueFrame:SetScript("OnEvent", PVPQueueFrame_OnEvent);
		PVPQueueFrame:RegisterEvent("PLAYER_LEVEL_UP");
	end

	PVPQueueFrame_SetCategoryButtonState(self.CategoryButton3, true);

	-- set up accessors
	self.getSelection = PVPQueueFrame_GetSelection;
	self.update = PVPQueueFrame_Update;

	--register for events
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	self:RegisterEvent("PVP_REWARDS_UPDATE");
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("ARENA_SEASON_WORLD_STATE");
end

function PVPQueueFrame_OnEvent(self, event, ...)
	if (event == "PLAYER_LEVEL_UP") then
		local level = ...;
		if ( level >= SHOW_CONQUEST_LEVEL ) then
			PVPQueueFrame_SetCategoryButtonState(self.CategoryButton2, true);
			self.CategoryButton2.tooltip = nil;
			PVPQueueFrame:UnregisterEvent("PLAYER_LEVEL_UP");
		end
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED") then
		PVP_UpdateStatus();
	elseif ( event == "BATTLEFIELDS_SHOW" ) then
		local isArena, bgID = ...;
		if (isArena) then
			PVEFrame_ShowFrame("PVPUIFrame", ConquestFrame);
		else
			PVEFrame_ShowFrame("PVPUIFrame", HonorFrame);
			HonorFrame_SetType("specific");
			HonorFrameSpecificList_FindAndSelectBattleground(bgID);
		end
	elseif event == "ARENA_SEASON_WORLD_STATE" then
		if self:IsVisible() then
			PVPQueueFrame_UpdateTitle();
		end
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

function PVPQueueFrame_OnShow(self)
	if (UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0]) then
		SetPortraitToTexture(PVEFrame.portrait, "Interface\\Icons\\INV_BannerPVP_01");
	else
		SetPortraitToTexture(PVEFrame.portrait, "Interface\\Icons\\INV_BannerPVP_02");
	end

	PVPQueueFrame_SetPrestige(self);
	PVPQueueFrame_UpdateTitle();
	
	PVEFrame.TopTileStreaks:Show()
end

function PVPQueueFrame_UpdateTitle()
	local currentSeason = GetCurrentArenaSeason();

	if currentSeason == NO_ARENA_SEASON then
		PVEFrame.TitleText:SetText(PLAYER_V_PLAYER);
	else
		local LEGION_START_SEASON = 19; -- if you're changing this you probably want to update the global string PLAYER_V_PLAYER_SEASON also
		PVEFrame.TitleText:SetText(PLAYER_V_PLAYER_SEASON:format(currentSeason - LEGION_START_SEASON + 1));
	end
end

function PVPQueueFrame_SetPrestige(self)
	local parent = self:GetParent():GetParent();
	local factionGroup = UnitFactionGroup("player");
	local frame = self.PrestigePortrait;
	frame.PortraitBackground:Hide();
	frame.SmallWreath:SetShown(false);
	PVPQueueFrame_UpdateTitle();
end

--WARNING - You probably want to call PVEFrame_ShowFrame("PVPUIFrame", "frameName") instead
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

	PVPQueueFrame.selection = frame;
	frame:Show();
	local width = PVE_FRAME_BASE_WIDTH;
	width = width + PVPQueueFrame.HonorInset:Update();
	PVEFrame:SetWidth(width);
	PVPUIFrame:SetWidth(width);
	UpdateUIPanelPositions(PVEFrame);
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
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	PVPQueueFrame_ShowFrame(_G[frameName]);
end

local function InitializeHonorXPBarDropDown(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.isNotRadio = true;
	info.text = SHOW_FACTION_ON_MAINSCREEN;
	info.checked = IsWatchingHonorAsXP();
	info.func = function(_, _, _, value)
		if ( value ) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
			SetWatchingHonorAsXP(false);
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			SetWatchingHonorAsXP(true);
			SetWatchedFactionIndex(0);
		end

		StatusTrackingBarManager:UpdateBarsShown();
	end

	UIDropDownMenu_AddButton(info, level);

	info.notCheckable = true;
	info.checked = false;
	info.text = CANCEL;

	UIDropDownMenu_AddButton(info, level);
end

---------------------------------------------------------------
-- HONOR FRAME
---------------------------------------------------------------

local MIN_BONUS_HONOR_LEVEL;

function HonorFrame_OnLoad(self)
	self.SpecificFrame.scrollBar.doNotHide = true;
	self.SpecificFrame.update = HonorFrameSpecificList_Update;
	self.SpecificFrame.dynamic = HonorFrame_CalculateScroll;
	HybridScrollFrame_CreateButtons(self.SpecificFrame, "PVPSpecificBattlegroundButtonTemplate", -2, -1);

	-- min level for bonus frame
	MIN_BONUS_HONOR_LEVEL = (C_PvP.GetRandomBGInfo()).minLevel;

	UIDropDownMenu_SetWidth(HonorFrameTypeDropDown, 160);
	UIDropDownMenu_Initialize(HonorFrameTypeDropDown, HonorFrameTypeDropDown_Initialize);
	if ( UnitLevel("player") < MIN_BONUS_HONOR_LEVEL ) then
		HonorFrame_SetType("specific");
	else
		HonorFrame_SetType("bonus");
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW");
	self:RegisterEvent("PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PVP_REWARDS_UPDATE");
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
    self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PVP_WORLDSTATE_UPDATE");
end

function HonorFrame_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LEVEL_UP") then
		HonorFrameSpecificList_Update();
		HonorFrameBonusFrame_Update();
		PVP_UpdateStatus();
	elseif ( event == "PVPQUEUE_ANYWHERE_SHOW" or event ==  "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE"
			or event == "PVP_RATED_STATS_UPDATE") then
		HonorFrameSpecificList_Update();
		HonorFrameBonusFrame_Update();
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		HonorFrame_UpdateQueueButtons();
	elseif ( event == "PVP_REWARDS_UPDATE" or event == "PVP_WORLDSTATE_UPDATE" ) then
		if ( self:IsShown() ) then
			RequestRandomBattlegroundInstanceInfo();
		end
		HonorFrameBonusFrame_Update();
	elseif ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" or event == "LFG_LIST_SEARCH_RESULT_UPDATED" ) then
		HonorFrame_UpdateQueueButtons();
	end
end

function HonorFrameTypeDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = BONUS_BATTLEGROUNDS;
	info.value = "bonus";
	info.func = HonorFrameTypeDropDown_OnClick;
	info.checked = HonorFrame.type == info.value;
	if ( UnitLevel("player") < MIN_BONUS_HONOR_LEVEL ) then
		info.disabled = 1;
		info.tooltipWhileDisabled = 1;
		info.tooltipTitle = UNAVAILABLE;
		info.tooltipText = string.format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, MIN_BONUS_HONOR_LEVEL);
		info.tooltipOnButton = 1;
	end
	UIDropDownMenu_AddButton(info);

	info.text = SPECIFIC_BATTLEGROUNDS;
	info.value = "specific";
	info.func = HonorFrameTypeDropDown_OnClick;
	info.checked = HonorFrame.type == info.value;
	info.disabled = nil;
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
	local arenaID;
	local isBrawl;
	if ( HonorFrame.type == "specific" ) then
		if ( HonorFrame.SpecificFrame.selectionID ) then
			canQueue = true;
		end
	elseif ( HonorFrame.type == "bonus" ) then
		if ( HonorFrame.BonusFrame.selectedButton ) then
			canQueue = HonorFrame.BonusFrame.selectedButton.canQueue;
			arenaID = HonorFrame.BonusFrame.selectedButton.arenaID;
			isBrawl = HonorFrame.BonusFrame.selectedButton.isBrawl;
		end
	end

	local disabledReason;

	if arenaID then
		local battlemasterListInfo = C_PvP.GetSkirmishInfo(arenaID);
		if battlemasterListInfo then
			local groupSize = GetNumGroupMembers();
			local minPlayers = battlemasterListInfo.minPlayers;
			local maxPlayers = battlemasterListInfo.maxPlayers;
			if groupSize > maxPlayers then
				canQueue = false;
				disabledReason = PVP_ARENA_NEED_LESS:format(groupSize - maxPlayers);
			elseif groupSize < minPlayers then
				canQueue = false;
				disabledReason = PVP_ARENA_NEED_MORE:format(minPlayers - groupSize);
			end
		end
	end

	if isBrawl and not canQueue then
		disabledReason = INSTANCE_UNAVAILABLE_SELF_LEVEL_TOO_LOW;
	end

	if ( canQueue ) then
		HonorFrame.QueueButton:Enable();
		if ( IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
			HonorFrame.QueueButton:SetText(BATTLEFIELD_GROUP_JOIN);
			if (not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME)) then
				HonorFrame.QueueButton:Disable();
                disabledReason = ERR_NOT_LEADER; -- let this trump any other disabled reason
			end
		else
			HonorFrame.QueueButton:SetText(BATTLEFIELD_JOIN);
		end
	else
		HonorFrame.QueueButton:Disable();
		if (HonorFrame.type == "bonus" and HonorFrame.BonusFrame.selectedButton and HonorFrame.BonusFrame.selectedButton.queueID) then
			if not disabledReason then
				disabledReason = LFGConstructDeclinedMessage(HonorFrame.BonusFrame.selectedButton.queueID);
			end
		end
	end

	--Disable the button if the person is active in LFGList
	if not disabledReason then
		if ( select(2,C_LFGList.GetNumApplications()) > 0 ) then
			disabledReason = CANNOT_DO_THIS_WITH_LFGLIST_APP;
		elseif ( C_LFGList.GetActiveEntryInfo() ) then
			disabledReason = CANNOT_DO_THIS_WHILE_LFGLIST_LISTED;
		end
	end

	HonorFrame.QueueButton.tooltip = disabledReason;
end

function HonorFrame_Queue()
	local HonorFrame = HonorFrame;
    local isParty = IsInGroup(LE_PARTY_CATEGORY_HOME);
	if ( HonorFrame.type == "specific" and HonorFrame.SpecificFrame.selectionID ) then
		JoinBattlefield(HonorFrame.SpecificFrame.selectionID, isParty);
	elseif ( HonorFrame.type == "bonus" and HonorFrame.BonusFrame.selectedButton ) then
		if ( HonorFrame.BonusFrame.selectedButton.arenaID ) then
			JoinSkirmish(HonorFrame.BonusFrame.selectedButton.arenaID, isParty);
		elseif (HonorFrame.BonusFrame.selectedButton.queueID) then
			ClearAllLFGDungeons(LE_LFG_CATEGORY_WORLDPVP);
			JoinSingleLFG(LE_LFG_CATEGORY_WORLDPVP, HonorFrame.BonusFrame.selectedButton.queueID);
		elseif (HonorFrame.BonusFrame.selectedButton.isBrawl) then
			C_PvP.JoinBrawl();
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
		local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers, gameType, iconTexture, shortDescription, longDescription = GetBattlegroundInfo(i);
		if ( localizedName and canEnter and not isRandom ) then
			buttonCount = buttonCount + 1;
			if ( buttonCount > 0 and buttonCount <= numButtons ) then
				local button = buttons[buttonCount];
				button:Show();
				button.NameText:SetText(localizedName);
				button.name = localizedName;
				button.shortDescription = shortDescription;
				button.longDescription = longDescription;
				button.SizeText:SetFormattedText(PVP_TEAMTYPE, maxPlayers, maxPlayers);
				button.InfoText:SetText(gameType);
				button.Icon:SetTexture(iconTexture or DEFAULT_BG_TEXTURE);
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

function HonorFrame_CalculateScroll(offset)
	local heightLeft = offset;
	local buttonHeight;
	local numBattlegrounds = GetNumBattlegroundTypes();
	
	for i = 1, numBattlegrounds do
		buttonHeight = 40;	
		if ( heightLeft - buttonHeight <= 0 ) then
			return i-1, heightLeft;
		else
			heightLeft = heightLeft - buttonHeight;
		end
	end
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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	HonorFrame.SpecificFrame.selectionID = self.bgID;
	HonorFrameSpecificList_Update();
end

-------- Bonus BG Frame --------

BONUS_BUTTON_TOOLTIPS = {
	RandomBG = {
		func = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(BONUS_BUTTON_RANDOM_BG_TITLE, 1, 1, 1);
			GameTooltip:AddLine(BONUS_BUTTON_RANDOM_BG_DESC, nil, nil, nil, true);
			GameTooltip:Show();
		end,
	},
	Skirmish = {
		tooltipKey = "SKIRMISH",
	},
	EpicBattleground = {
		tooltipKey = "RANDOM_EPIC_BG",
	},
	Brawl = {
		func = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetPvpBrawl();
		end,
	}
}

function PVPCasualActivityButton_OnEnter(self)
	if (not self.tooltipTableKey) then
		return;
	end

	local tooltipTbl = BONUS_BUTTON_TOOLTIPS[self.tooltipTableKey];

	if (not tooltipTbl) then
		return;
	end

	if (tooltipTbl.func) then
		tooltipTbl.func(self);
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(_G["BONUS_BUTTON_"..tooltipTbl.tooltipKey.."_TITLE"], 1, 1, 1);
		GameTooltip:AddLine(_G["BONUS_BUTTON_"..tooltipTbl.tooltipKey.."_DESC"], nil, nil, nil, true);
		GameTooltip:Show();
	end	
end

function HonorFrameBonusFrame_OnShow(self)
	self.updateTime = 0;
	HonorFrameBonusFrame_Update();
	RequestRandomBattlegroundInstanceInfo();

	RequestLFDPlayerLockInfo();
	RequestLFDPartyLockInfo();
	self:RegisterEvent("PVP_BRAWL_INFO_UPDATED");
end

function HonorFrameBonusFrame_OnHide(self)
	self:UnregisterEvent("PVP_BRAWL_INFO_UPDATED");
end

function HonorFrameBonusFrame_OnEvent(self, event)
	if (event == "PVP_BRAWL_INFO_UPDATED") then
		HonorFrameBonusFrame_Update();
	end
end

local function GetRewardValues(reward)
	return reward.id, reward.name, reward.texture, reward.quantity;
end

local function ShouldShowBrawlHelpBox(brawlActive, isMaxLevel)
	if (not brawlActive) then
		return false;
	end

	if (not isMaxLevel) then
		return false;
	end

	if (GetCVarBitfield("closedInfoFrames",	LE_FRAME_TUTORIAL_BRAWL)) then
		return false;
	end

	return true;
end

function HonorFrameBonusFrame_Update()
	local englishFaction = UnitFactionGroup("player");
	local selectButton = nil;
	local battlegroundEnlistmentActive, brawlEnlistmentActive = C_PvP.IsBattlegroundEnlistmentBonusActive();

	-- random bg
	do
		local button = HonorFrame.BonusFrame.RandomBGButton;
		button.Title:SetText(RANDOM_BATTLEGROUNDS);
		local randomBGInfo = C_PvP.GetRandomBGInfo();
		HonorFrameBonusFrame_SetButtonState(button, randomBGInfo.canQueue, randomBGInfo.minLevel);
		if ( randomBGInfo.canQueue ) then
			if ( not selectButton ) then
				selectButton = button;
			end
		end
		button.canQueue = randomBGInfo.canQueue;
		button.bgID = randomBGInfo.bgID;

		local honor, experience, rewards = C_PvP.GetRandomBGRewards();

		if (not rewards) then
			rewards = GetMaxLevelReward(RANDOM_BATTLEGROUNDS, randomBGInfo.hasRandomWinToday);
		end

		if (rewards and #rewards > 0) then
			local id, name, texture, quantity = GetRewardValues(rewards[1]);
			SetPortraitToTexture(button.Reward.Icon, texture);
			button.Reward.honor = honor;
			button.Reward.experience = experience;
			button.Reward.itemID = id;
			button.Reward:Show();
			button.Reward.EnlistmentBonus:SetShown(battlegroundEnlistmentActive);
		else
			button.Reward:Hide();
		end
    end

	-- arena pvp
	do
		local button = HonorFrame.BonusFrame.Arena1Button;
		button.Title:SetText(SKIRMISH);

		local honor, experience, rewards = C_PvP.GetArenaSkirmishRewards();
		local hasWon = C_PvP.HasArenaSkirmishWinToday();

		if (not rewards) then
			rewards = GetMaxLevelReward(SKIRMISH, hasWon);
		end

		if (rewards and #rewards > 0) then
			local id, name, texture, quantity = GetRewardValues(rewards[1]);
			SetPortraitToTexture(button.Reward.Icon, texture);
			button.Reward.honor = honor;
			button.Reward.experience = experience;
			button.Reward.itemID = id;
			button.Reward:Show();
		else
			button.Reward:Hide();
		end
	end

	-- epic battleground
	do
		local button = HonorFrame.BonusFrame.RandomEpicBGButton;
		local randomBGInfo = C_PvP.GetRandomEpicBGInfo();
		HonorFrameBonusFrame_SetButtonState(button, randomBGInfo.canQueue, randomBGInfo.minLevel);
		button.canQueue = randomBGInfo.canQueue;
		button.bgID = randomBGInfo.bgID;
		button.Title:SetText(RANDOM_EPIC_BATTLEGROUND);

		local honor, experience, rewards = C_PvP.GetRandomEpicBGRewards();

		if (not rewards) then
			rewards = GetMaxLevelReward(RANDOM_EPIC_BATTLEGROUNDS, randomBGInfo.hasRandomWinToday);
		end

		if (rewards and #rewards > 0) then
			local id, name, texture, quantity = GetRewardValues(rewards[1]);
			SetPortraitToTexture(button.Reward.Icon, texture);
			button.Reward.honor = honor;
			button.Reward.experience = experience;
			button.Reward.itemID = id;
			button.Reward:Show();
		else
			button.Reward:Hide();
		end
	end

	do
		-- brawls
		local button = HonorFrame.BonusFrame.BrawlButton;
		local brawlInfo = C_PvP.GetBrawlInfo();
		local isMaxLevel = UnitLevel("player") >= MAX_PLAYER_LEVEL;
		button.canQueue = brawlInfo and brawlInfo.active and isMaxLevel;
		button.isBrawl = true;

		if (brawlInfo and brawlInfo.active) then
			button:Enable();
			button.Title:SetText(brawlInfo.name);
			button.Title:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
			local honor, experience, rewards, hasWon = C_PvP.GetBrawlRewards(brawlInfo.brawlType);

			if (not rewards) then
				if (brawlInfo.brawlType == Enum.BrawlType.Arena) then
					rewards = GetMaxLevelReward(ARENA_BRAWL_REWARD, hasWon);
				elseif (brawlInfo.brawlType == Enum.BrawlType.Battleground) then
					rewards = GetMaxLevelReward(BG_BRAWL_REWARD, hasWon);
				elseif (brawlInfo.brawlType == Enum.BrawlType.Lfg) then
					rewards = GetMaxLevelReward(LFG_BRAWL_REWARD, hasWon);
				end
			end

			if (rewards and #rewards > 0) then
				local id, name, texture, quantity = GetRewardValues(rewards[1]);
				SetPortraitToTexture(button.Reward.Icon, texture);
				button.Reward.honor = honor;
				button.Reward.experience = experience;
				button.Reward.itemID = id;
				button.Reward:Show();
				button.Reward.EnlistmentBonus:SetShown(brawlEnlistmentActive);
			else
				button.Reward:Hide();
			end
		else
			local timeUntilNext = brawlInfo and brawlInfo.timeLeftUntilNextChange or 0;
			if (timeUntilNext == 0) then
				button.Title:SetText(BRAWL_CLOSED);
			else
				button.Title:SetText(BRAWL_CLOSED_NEW:format(SecondsToTime(timeUntilNext, false, false, 1)));
			end
			button.Title:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
			button.Reward:Hide();
			button:Disable();
		end
		HonorFrame.BonusFrame.BrawlHelpBox:SetShown(ShouldShowBrawlHelpBox(brawlInfo and brawlInfo.active, (UnitLevel("player") >= MAX_PLAYER_LEVEL)));
	end

	-- select a button if one isn't selected
	if ( not HonorFrame.BonusFrame.selectedButton and selectButton ) then
		HonorFrameBonusFrame_SelectButton(selectButton);
	else
		HonorFrame_UpdateQueueButtons();
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
		button.Title:SetPoint("LEFT", button.Anchor, "LEFT", 20, -1);
		button.Title:SetTextColor(1, 1, 1);
		button.NormalTexture:SetAlpha(1);
		button:Enable();
		button.LevelRequirement:Hide();
	else
		if ( button == HonorFrame.BonusFrame.selectedButton ) then
			button.SelectedTexture:Hide();
		end
		button.Title:SetTextColor(0.4, 0.4, 0.4);
		button.NormalTexture:SetAlpha(0.5);
		button:Disable();
		if ( minLevel ) then
			button.LevelRequirement:Show();
			button.LevelRequirement:SetFormattedText(UNLOCKS_AT_LEVEL, minLevel);
			local height = button.LevelRequirement:GetHeight() + 4;
			button.Title:SetPoint("LEFT", button.Anchor, "LEFT", 20, (height / 2) - 1);
		else
			button.Title:SetPoint("LEFT", button.Anchor, "LEFT", 20, -1);
			button.LevelRequirement:Hide();
		end
	end
end

---------------------------------------------------------------
-- CONQUEST FRAME
---------------------------------------------------------------

CONQUEST_SIZE_STRINGS = { ARENA_2V2, ARENA_3V3, BATTLEGROUND_10V10 };
CONQUEST_TYPE_STRINGS = { ARENA, ARENA, BATTLEGROUNDS };
CONQUEST_SIZES = {2, 3, 10};
CONQUEST_BRACKET_INDEXES = { 1, 2, 4 }; -- 5v5 was removed
CONQUEST_BUTTONS = {};
local RATED_BG_ID = 3;

function ConquestFrame_OnLoad(self)

	CONQUEST_BUTTONS = {ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG};

	RequestRatedInfo();
	RequestPVPOptionsEnabled();
	
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	self:RegisterEvent("PVP_REWARDS_UPDATE");
	self:RegisterEvent("PVP_TYPES_ENABLED");
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
end

function ConquestFrame_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" or event == "LFG_LIST_SEARCH_RESULT_UPDATED" ) then
		ConquestFrame_UpdateJoinButton(self);
	elseif (event == "PVP_TYPES_ENABLED") then
		local _, ratedBgs, ratedArenas = ...;
		self.bgsEnabled = ratedBgs;
		self.arenasEnabled = ratedArenas;
		self.disabled = not ratedBgs and not ratedArenas;
		ConquestFrame_Update(self);
	elseif (self:IsVisible()) then
		ConquestFrame_Update(self);
		if (event == "QUEST_LOG_UPDATE" and self.activeWeeklyBonus) then
			PVPRewardWeeklyBonus_OnEnter(self.activeWeeklyBonus);
		end
	end
end

function ConquestFrame_OnShow(self)
	RequestRatedInfo();
	RequestPVPOptionsEnabled();
	ConquestFrame_Update(self);
end

function ConquestFrame_SetTierInfo(tierFrame, tierInfo, ranking)
	if tierInfo then
		tierFrame.Icon:SetTexture(tierInfo.tierIconID);
		tierFrame:Show();
		if ranking then
			tierFrame.RankingShadow:Show();
			tierFrame.Ranking:SetText(ranking);
		else
			tierFrame.RankingShadow:Hide();
			tierFrame.Ranking:SetText();
		end
	else
		tierFrame:Hide();
	end
end

function ConquestFrame_Update(self)
	if ( GetCurrentArenaSeason() == NO_ARENA_SEASON ) then
		ConquestFrame.Disabled:Hide();
		ConquestFrame.NoSeason:Show();
	elseif ( self.disabled ) then
		ConquestFrame.NoSeason:Hide();
		ConquestFrame.Disabled:Show();
	else
		ConquestFrame.NoSeason:Hide();
		ConquestFrame.Disabled:Hide();
		
		local firstAvailableButton = self.arenasEnabled and ConquestFrame.Arena2v2 or ConquestFrame.RatedBG;

		for i = 1, RATED_BG_ID do
			local button = CONQUEST_BUTTONS[i];
			local bracketIndex = CONQUEST_BRACKET_INDEXES[i];
			local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking = GetPersonalRatedInfo(bracketIndex);
			local tierInfo = C_PvP.GetPvpTierInfo(pvpTier);
			if tierInfo then
				button.CurrentRating:SetText(rating);
				button.CurrentRating:Show();
			else
				button.CurrentRating:Hide();
			end
			ConquestFrame_SetTierInfo(button.Tier, tierInfo, ranking);
			button.bracketIndex = bracketIndex;

			local honor, experience, rewards;

			local enabled;

			if (i == RATED_BG_ID) then
				enabled = self.bgsEnabled;
				honor, experience, rewards = C_PvP.GetRatedBGRewards();
			else
				enabled = self.arenasEnabled;
				honor, experience, rewards = C_PvP.GetArenaRewards(CONQUEST_SIZES[i]);
			end

			if (not rewards) then
				rewards = GetMaxLevelReward(CONQUEST_BRACKET_INDEXES[i], hasWon);
			end

			if (rewards and #rewards > 0 and enabled) then
				local id, name, texture, quantity = GetRewardValues(rewards[1]);
				SetPortraitToTexture(button.Reward.Icon, texture);
				button.Reward.honor = honor;
				button.Reward.experience = experience;
				button.Reward.itemID = id;
				button.Reward:Show();

				local completed, itemLevel = GetWeeklyPVPRewardInfo(bracketIndex);
				if (not completed) then
					button.Reward.WeeklyBonus.bracketIndex = bracketIndex;
					button.Reward.WeeklyBonus.index = i;
					button.Reward.WeeklyBonus:Show();
				else
					button.Reward.WeeklyBonus:Hide();
				end
			else
				button.Reward:Hide();
			end
			button:SetEnabled(enabled);
			
			if (not enabled) then
				button.TeamSizeText:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
				button.CurrentRating:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
			else
				button.TeamSizeText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
				button.CurrentRating:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
			end

			if (not enabled and ConquestFrame.selectedButton == button) then
				ConquestFrame_SelectButton(firstAvailableButton);
			end
		end
		
		if ( not ConquestFrame.selectedButton ) then
			ConquestFrame_SelectButton(firstAvailableButton);
		else
			ConquestFrame_UpdateJoinButton();
		end
	end
end

function ConquestFrame_UpdateJoinButton()
	local button = ConquestFrame.JoinButton;
	local groupSize = GetNumGroupMembers();

	--Disable the button if the person is active in LFGList
	local lfgListDisabled;
	if ( select(2,C_LFGList.GetNumApplications()) > 0 ) then
		lfgListDisabled = CANNOT_DO_THIS_WITH_LFGLIST_APP;
	elseif ( C_LFGList.GetActiveEntryInfo() ) then
		lfgListDisabled = CANNOT_DO_THIS_WHILE_LFGLIST_LISTED;
	end

	if ( lfgListDisabled ) then
		button:Disable();
		button.tooltip = lfgListDisabled;
		return;
	end

	--Check whether they have a valid button selected
	if ( ConquestFrame.selectedButton ) then
		if ( groupSize == 0 ) then
			button.tooltip = PVP_NO_QUEUE_GROUP;
		elseif ( not UnitIsGroupLeader("player") ) then
			button.tooltip = PVP_NOT_LEADER;
		else
			local neededSize = CONQUEST_SIZES[ConquestFrame.selectedButton.id];
			local token, loopMax;
			if (groupSize > (MAX_PARTY_MEMBERS + 1)) then
				token = "raid";
				loopMax = groupSize;
			else
				token = "party";
				loopMax = groupSize - 1; -- player not included in party tokens, just raid tokens
			end
			if ( neededSize == groupSize ) then
				local validGroup = true;
				local teamIndex = ConquestFrame.selectedButton.teamIndex;
				for i = 1, loopMax do
					if ( not UnitIsConnected(token..i) ) then
						validGroup = false;
						button.tooltip = PVP_NO_QUEUE_DISCONNECTED_GROUP
						break;
					end
				end
				if ( validGroup ) then
					if ( not GetSpecialization() ) then
						button.tooltip = SPELL_FAILED_CUSTOM_ERROR_122;
					else
						button.tooltip = nil;
						button:Enable();
						return;
					end
				end
			elseif ( neededSize > groupSize ) then
				if ( ConquestFrame.selectedButton.id == RATED_BG_ID ) then
					button.tooltip = string.format(PVP_RATEDBG_NEED_MORE, neededSize - groupSize);
				else
					button.tooltip = string.format(PVP_ARENA_NEED_MORE, neededSize - groupSize);
				end
			else
				if ( ConquestFrame.selectedButton.id == RATED_BG_ID ) then
					button.tooltip = string.format(PVP_RATEDBG_NEED_LESS, groupSize -  neededSize);
				else
					button.tooltip = string.format(PVP_ARENA_NEED_LESS, groupSize -  neededSize);
				end
			end
		end
	else
		button.tooltip = nil;
	end
	button:Disable();
end

function ConquestFrame_SelectButton(button)
	if ( ConquestFrame.selectedButton ) then
		ConquestFrame.selectedButton.SelectedTexture:Hide();
	end
	button.SelectedTexture:Show();
	ConquestFrame.selectedButton = button;
	ConquestFrame_UpdateJoinButton();
end

function ConquestFrameButton_OnClick(self, button)
	CloseDropDownMenus();
	if ( button == "LeftButton" or self.teamIndex ) then
		ConquestFrame_SelectButton(self);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function ConquestFrameJoinButton_OnClick(self)
	if (ConquestFrame.selectedButton.id == RATED_BG_ID) then
		JoinRatedBattlefield();
	else
		JoinArena();
	end
end

--------- Conquest Tooltips ----------

function DefaultBattlegroundReward_ShowTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(BATTLEGROUND_BONUS_REWARD_TOOLTIP, nil, nil, nil, nil,
	true);
	GameTooltip:Show();
end

function DefaultBattlegroundReward_HideTooltip(self)
	GameTooltip_Hide();
end

local CONQUEST_TOOLTIP_PADDING = 30 --counts both sides

function ConquestFrameButton_OnEnter(self)
	local tooltip = ConquestTooltip;
	
	local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, pvpTier, ranking = GetPersonalRatedInfo(self.bracketIndex);
	
	tooltip.Title:SetText(self.toolTipTitle);
	
	tooltip.WeeklyBest:SetText(PVP_BEST_RATING..weeklyBest);
	tooltip.WeeklyGamesWon:SetText(PVP_GAMES_WON..weeklyWon);
	tooltip.WeeklyGamesPlayed:SetText(PVP_GAMES_PLAYED..weeklyPlayed);
	
	tooltip.SeasonBest:SetText(PVP_BEST_RATING..seasonBest);
	tooltip.SeasonWon:SetText(PVP_GAMES_WON..seasonWon);
	tooltip.SeasonGamesPlayed:SetText(PVP_GAMES_PLAYED..seasonPlayed);

	local maxWidth = 0;
	for i, fontString in ipairs(tooltip.Content) do
		maxWidth = math.max(maxWidth, fontString:GetStringWidth());
	end
	
	tooltip:SetWidth(maxWidth + CONQUEST_TOOLTIP_PADDING);
	tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0);
	tooltip:Show();
end

---------------------------------------------------------------
-- Rewards
---------------------------------------------------------------

function PVPRewardTemplate_OnEnter(self)
	if (not self.Icon:IsShown()) then
		return;
	end
	PVPRewardTooltip:ClearAllPoints();
	PVPRewardTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
	if (self.experience > 0) then
		PVPRewardTooltip.XP:SetText(PVP_REWARD_XP_FORMAT:format(BreakUpLargeNumbers(self.experience)));
		PVPRewardTooltip.XP:Show();
		PVPRewardTooltip.Honor:Hide();
	else
		PVPRewardTooltip.XP:Hide();
		PVPRewardTooltip.Honor:SetText(REWARD_FOR_PVP_WIN_HONOR:format(BreakUpLargeNumbers(self.honor)));
		PVPRewardTooltip.Honor:Show();
	end
	EmbeddedItemTooltip_SetItemByID(PVPRewardTooltip.ItemTooltip, self.itemID);
	PVPRewardTooltip:Show();
end

function PVPRewardWeeklyBonus_OnEnter(self)
	ConquestFrame.activeWeeklyBonus = self;
	local completed, itemLevel, numWins, numWinsReq = GetWeeklyPVPRewardInfo(self.bracketIndex);
	if (not completed and itemLevel) then
		local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, pvpTier, ranking = GetPersonalRatedInfo(self.bracketIndex);

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(PVP_WEEKLY_BONUS:format(CONQUEST_SIZE_STRINGS[self.index]));
		GameTooltip:AddLine(string.format(PVP_WEEKLY_BONUS_DESCRIPTION, itemLevel, lastWeeksBest), 1, 1, 1, true);
		if (numWinsReq > 0) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(string.format(PVP_WEEKLY_BONUS_GAMES_WON, numWins, numWinsReq));
		end
		GameTooltip:Show();
	end
end

function PVPRewardWeeklyBonus_OnLeave(self)
	GameTooltip:Hide();
	ConquestFrame.activeWeeklyBonus = nil;
end

function PVPRewardEnlistmentBonus_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local spellName = GetSpellInfo(BATTLEGROUND_ENLISTMENT_BONUS);
	local spellDesc = GetSpellDescription(BATTLEGROUND_ENLISTMENT_BONUS);
	GameTooltip:SetText(spellName);
	GameTooltip:AddLine(spellDesc, 1, 1, 1, true);
	GameTooltip:Show();
end

function PvPObjectiveBannerFrame_PlayBanner(self, data)
	name = data.name or "";
	description = data.description or "";

	self.Title:SetText(name);
	self.TitleFlash:SetText(name);
	self.BonusLabel:SetText(description);

	-- offsets for anims
	local xOffset = QueueStatusMinimapButton:GetLeft() - self:GetLeft();
	local yOffset = QueueStatusMinimapButton:GetTop() - self:GetTop() + 64;

	self.Anim.BG1Translation:SetOffset(xOffset, yOffset);
	self.Anim.TitleTranslation:SetOffset(xOffset, yOffset);
	self.Anim.BonusLabelTranslation:SetOffset(xOffset, yOffset);
	self.Anim.IconTranslation:SetOffset(xOffset, yOffset);
	-- hide zone text as it's very likely to be up
	ZoneText_Clear();
	-- show and play
	self:Show();
	self.Anim:Stop();
	self.Anim:Play();
end

function PvPObjectiveBannerFrame_StopBanner(self)
	self.Anim:Stop();
	self:Hide();
end

function PvPObjectiveBannerFrame_OnAnimFinished()
	TopBannerManager_BannerFinished();
	PvPObjectiveBannerFrame:Hide();
end

local HONOR_INSET_WIDTH = 225;

PVPUIHonorInsetMixin = { }

function PVPUIHonorInsetMixin:Update()
	local activePanel = PVPQueueFrame.selection;
	if activePanel == HonorFrame then
		self:Show();
		self:DisplayCasualPanel();
		return HONOR_INSET_WIDTH;
	elseif activePanel == ConquestFrame then
		self:Show();
		self:DisplayRatedPanel();
		return HONOR_INSET_WIDTH;
	end

	self:Hide();
	return 0;
end

function PVPUIHonorInsetMixin:DisplayCasualPanel()
	local panel = self.CasualPanel;
	panel:Show();
	self.RatedPanel:Hide();

	local lifetimeHonorKills = GetPVPLifetimeStats();
	panel.HKValue:SetText(BreakUpLargeNumbers(lifetimeHonorKills));
end

function PVPUIHonorInsetMixin:DisplayRatedPanel()
	local panel = self.RatedPanel;
	panel:Show();
	self.CasualPanel:Hide();

	local tierID, nextTierID = C_PvP.GetSeasonBestInfo();
	local tierInfo = C_PvP.GetPvpTierInfo(tierID);
	ConquestFrame_SetTierInfo(panel.Tier, tierInfo);

	local nextTierInfo = nextTierID and C_PvP.GetPvpTierInfo(nextTierID);	
	if nextTierInfo then
		panel.Tier.NextTier.Icon:SetTexture(nextTierInfo.tierIconID);
		panel.Tier.NextTier:Show();
	else
		panel.Tier.NextTier:Hide();
	end
end

PVPUIHonorLevelDisplayMixin = { };

function PVPUIHonorLevelDisplayMixin:OnLoad()
	self:Pause();
	if UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] then
		self.Background:SetAtlas("pvpqueue-sidebar-honorbar-background-horde", false);
	else
		self.Background:SetAtlas("pvpqueue-sidebar-honorbar-background-alliance", false);
	end
end

function PVPUIHonorLevelDisplayMixin:OnShow()
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("HONOR_LEVEL_UPDATE");
	self:Update();
end

function PVPUIHonorLevelDisplayMixin:OnHide()
	self:UnregisterEvent("HONOR_XP_UPDATE");
	self:UnregisterEvent("HONOR_LEVEL_UPDATE");
end

function PVPUIHonorLevelDisplayMixin:OnEvent(event, ...)
	self:Update();
end

function PVPUIHonorLevelDisplayMixin:Update()
	-- progress bar
	local currentHonor = UnitHonor("player");
	local maxHonor = UnitHonorMax("player");
	CooldownFrame_SetDisplayAsPercentage(self, currentHonor / maxHonor);
	-- honor level
	local honorLevel = UnitHonorLevel("player");
	self.LevelLabel:SetFormattedText(HONOR_LEVEL_LABEL, honorLevel);
	-- badge icon
	local honorRewardInfo = C_PvP.GetHonorRewardInfo(honorLevel);
	if honorRewardInfo then
		self.LevelBadge:SetTexture(honorRewardInfo.badgeFileDataID);
		self.LevelBadge:Show();
	else
		self.LevelBadge:Hide();
	end
	-- next reward level
	self.nextHonorLevelForReward = C_PvP.GetNextHonorLevelForReward(honorLevel);
	if not self.nextHonorLevelForReward then
		self.NextRewardLevel.LevelLabel:SetText("");
		self.NextRewardLevel.RingBorder:SetAtlas("pvpqueue-rewardring-black");
	else
		local nextRewardInfo = C_PvP.GetHonorRewardInfo(self.nextHonorLevelForReward);
		local iconTexture = select(10, GetAchievementInfo(nextRewardInfo.achievementRewardedID));
		if iconTexture then
			self.NextRewardLevel.RewardIcon:SetTexture(iconTexture);
		else
			self.NextRewardLevel.RewardIcon:SetColorTexture(0, 0, 0);
		end
		-- light up the reward if it's at the end of this level
		if honorLevel + 1 == self.nextHonorLevelForReward then
			self.NextRewardLevel.RingBorder:SetAtlas("pvpqueue-rewardring");
			self.NextRewardLevel.LevelLabel:SetText("");
			self.NextRewardLevel.RewardIcon:SetDesaturated(false);
			self.NextRewardLevel.IconCover:Hide();
		else
			self.NextRewardLevel.RingBorder:SetAtlas("pvpqueue-rewardring-black");
			self.NextRewardLevel.LevelLabel:SetText(self.nextHonorLevelForReward);
			self.NextRewardLevel.RewardIcon:SetDesaturated(true);
			self.NextRewardLevel.IconCover:Show();
		end
	end
end

function PVPUIHonorLevelDisplayMixin:ShowNextRewardTooltip()
	local rewardInfo = C_PvP.GetHonorRewardInfo(self.nextHonorLevelForReward);
	if rewardInfo then
		local rewardText = select(11, GetAchievementInfo(rewardInfo.achievementRewardedID));
		if rewardText and rewardText ~= "" then
			GameTooltip:SetOwner(self.NextRewardLevel, "ANCHOR_RIGHT", -4, -4);
			GameTooltip:SetText(PVP_PRESTIGE_RANK_UP_NEXT_MAX_LEVEL_REWARD:format(self.nextHonorLevelForReward));
			local WRAP = true;
			GameTooltip_AddColoredLine(rewardText, HIGHLIGHT_FONT_COLOR, WRAP);
			GameTooltip:Show();
		end
	end
end

function PVPUIHonorLevelDisplayMixin:OnMouseUp(button)
	if button == "RightButton" then
		UIDropDownMenu_Initialize(self.DropDown, InitializeHonorXPBarDropDown, "MENU");
		ToggleDropDownMenu(1, nil, self.DropDown, "cursor", 10, -10);
	end
end

PVPUISeasonRewardFrameMixin = { };

local REWARD_QUEST_ID = 53096;
local SEASON_REWARD_ACHIEVEMENTS = {
	[PLAYER_FACTION_GROUP[0]] = 13136,
	[PLAYER_FACTION_GROUP[1]] = 13137,
};

function PVPUISeasonRewardFrameMixin:OnShow()
	if self:IsRewardAvailable() then
		self:Update();
	else
		self:RegisterEvent("QUEST_LOG_UPDATE");
	end
end

function PVPUISeasonRewardFrameMixin:OnHide()
	self:UnregisterEvent("QUEST_LOG_UPDATE");
end

function PVPUISeasonRewardFrameMixin:IsRewardAvailable()
	return HaveQuestData(REWARD_QUEST_ID) and HaveQuestRewardData(REWARD_QUEST_ID);
end

function PVPUISeasonRewardFrameMixin:OnEvent(event, ...)
	if event == "QUEST_LOG_UPDATE" then
		if self:IsRewardAvailable() then
			self:UnregisterEvent("QUEST_LOG_UPDATE");
			self:Update();
		end
	end
end

function PVPUISeasonRewardFrameMixin:Update()
	local itemIndex = 1;
	local name, texture, count, quality, isUsable = GetQuestLogRewardInfo(itemIndex, REWARD_QUEST_ID);
	if texture then
		self.Icon:SetTexture(texture);
		self.Icon:Show();
		local completed = false;
		local achievementID = SEASON_REWARD_ACHIEVEMENTS[UnitFactionGroup("player")];
		if achievementID and GetAchievementNumCriteria(achievementID) > 0 then
			completed = select(3, GetAchievementCriteriaInfo(achievementID, 1));
		end
		if completed then
			self.Icon:SetDesaturated(false);
			self.CheckMark:Show();
		else
			self.Icon:SetDesaturated(true);
			self.CheckMark:Hide();
		end
	else
		self.Icon:Hide();
	end
end

function PVPUISeasonRewardFrameMixin:UpdateTooltip()
	local achievementID = SEASON_REWARD_ACHIEVEMENTS[UnitFactionGroup("player")];
	if not achievementID then
		return;
	end
	if GetAchievementNumCriteria(achievementID) == 0 then
		return;
	end

	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(EmbeddedItemTooltip, PVP_SEASON_REWARD);

	local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(achievementID, 1);
	if criteriaString then
		if completed then
			GameTooltip_AddColoredLine(EmbeddedItemTooltip, GOAL_COMPLETED, GREEN_FONT_COLOR);
		else
			local wordWrap = true;
			GameTooltip_AddNormalLine(EmbeddedItemTooltip, criteriaString, wordWrap);
			local roundToNearestInteger = true;
			GameTooltip_ShowProgressBar(EmbeddedItemTooltip, 0, reqQuantity, quantity, FormatPercentage(quantity / reqQuantity, roundToNearestInteger));
			EmbeddedItemTooltip:AddLine(" ");
			GameTooltip_AddNormalLine(EmbeddedItemTooltip, REWARD, wordWrap);
			EmbeddedItemTooltip_SetItemByQuestReward(EmbeddedItemTooltip.ItemTooltip, 1, REWARD_QUEST_ID);
		end
	end
	EmbeddedItemTooltip:Show();
end

function PVPUISeasonRewardFrameMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
end

PVPConquestBarMixin = { };

function PVPConquestBarMixin:OnShow()
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:Update();
end

function PVPConquestBarMixin:OnHide()
	self:UnregisterEvent("QUEST_LOG_UPDATE");
end

function PVPConquestBarMixin:OnEvent(event, ...)
	if event == "QUEST_LOG_UPDATE" then
		self:Update();
	end
end

function PVPConquestBarMixin:Update()
	local current, max, rewardItemID = self:GetConquestLevelInfo();
	if max == 0 then
		self:SetValue(0);
	else
		self:SetValue(current / max * 100);
	end
	self.Label:SetFormattedText(CONQUEST_BAR, current, max);
	if rewardItemID then
		self.Reward.Icon:SetTexture(GetItemIcon(rewardItemID));
		self.Reward.itemID = rewardItemID;
	else
		self.Reward.Icon:SetColorTexture(0, 0, 0);
		self.Reward.itemID = nil;
	end
end

function PVPConquestBarMixin:GetConquestLevelInfo()
	local CONQUEST_QUESTLINE_ID = 782;
	local quests = C_QuestLine.GetQuestLineQuests(CONQUEST_QUESTLINE_ID)
	local currentQuestID = quests[1];
	for i, questID in ipairs(quests) do
		if not IsQuestFlaggedCompleted(questID) and not C_QuestLog.IsOnQuest(questID) then
			break;
		end
		currentQuestID = questID;
	end

	if not HaveQuestData(currentQuestID) then
		return 0, 0, nil;
	end

	local objectives = C_QuestLog.GetQuestObjectives(currentQuestID);
	if not objectives or not objectives[1] then
		return 0, 0, nil;
	end

	local rewardItemID;
	if HaveQuestRewardData(currentQuestID) then
		local itemIndex = 1;
		rewardItemID = select(6, GetQuestLogRewardInfo(itemIndex, currentQuestID));
	end

	return objectives[1].numFulfilled, objectives[1].numRequired, rewardItemID;
end