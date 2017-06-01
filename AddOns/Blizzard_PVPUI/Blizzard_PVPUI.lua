
MAX_ARENA_TEAM_MEMBERS = 10;
MAX_BLACKLIST_BATTLEGROUNDS = 2;

WARGAME_HEADER_HEIGHT = 16;
BATTLEGROUND_BUTTON_HEIGHT = 40;

ASHRAN_MAP_ID = 978;
ASHRAN_QUEUE_ID = 1127;

local MAX_SHOWN_BATTLEGROUNDS = 8;
local NUM_BLACKLIST_INFO_LINES = 2;
local NO_ARENA_SEASON = 0;

local RANDOM_BG_REWARD = "randombg";
local SKIRMISH_REWARD = "skirmish";
local RATED_BG_REWARD = "ratedbg";
local ARENA_2V2_REWARD = "arena2v2";
local ARENA_3V3_REWARD = "arena3v3";
local BG_BRAWL_REWARD = "bgbrawl";
local ARENA_BRAWL_REWARD = "arenabrawl";

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
	}
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
		HonorFrame.BonusFrame.WorldBattlesTexture:SetAtlas("pvpqueue-bg-horde", true)
	else
		HonorFrame.BonusFrame.WorldBattlesTexture:SetAtlas("pvpqueue-bg-alliance", true)
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
	PlaySound("igCharacterInfoOpen");
	RequestPVPRewards();

	PVPUIFrame_UpdateSelectedRoles();
	PVPUIFrame_UpdateRolesChangeable();
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
	PVPUIFrame_SetRoles(self:GetParent():GetParent():GetParent());
end

function PVPUIFrame_SetRoles(frame)
	SetPVPRoles(frame.RoleInset.TankIcon.checkButton:GetChecked(),
		frame.RoleInset.HealerIcon.checkButton:GetChecked(),
		frame.RoleInset.DPSIcon.checkButton:GetChecked());
end

function PVPUIFrame_UpdateRolesChangeable()
	if ( PVPHelper_CanChangeRoles() ) then
		PVPUIFrame_UpdateAvailableRoles(HonorFrame.RoleInset.TankIcon, HonorFrame.RoleInset.HealerIcon, HonorFrame.RoleInset.DPSIcon);
		PVPUIFrame_UpdateAvailableRoles(ConquestFrame.RoleInset.TankIcon, ConquestFrame.RoleInset.HealerIcon, ConquestFrame.RoleInset.DPSIcon);
	else
		LFG_DisableRoleButton(HonorFrame.RoleInset.TankIcon);
		LFG_DisableRoleButton(HonorFrame.RoleInset.HealerIcon);
		LFG_DisableRoleButton(HonorFrame.RoleInset.DPSIcon);
		LFG_DisableRoleButton(ConquestFrame.RoleInset.TankIcon);
		LFG_DisableRoleButton(ConquestFrame.RoleInset.HealerIcon);
		LFG_DisableRoleButton(ConquestFrame.RoleInset.DPSIcon);
	end
end

function PVPUIFrame_UpdateAvailableRoles(tankButton, healButton, dpsButton)
	return LFG_UpdateAvailableRoles(tankButton, healButton, dpsButton);
end

function PVPUIFrame_UpdateSelectedRoles()
	local tank, healer, dps = GetPVPRoles();
	HonorFrame.RoleInset.TankIcon.checkButton:SetChecked(tank);
	HonorFrame.RoleInset.HealerIcon.checkButton:SetChecked(healer);
	HonorFrame.RoleInset.DPSIcon.checkButton:SetChecked(dps);
	ConquestFrame.RoleInset.TankIcon.checkButton:SetChecked(tank);
	ConquestFrame.RoleInset.HealerIcon.checkButton:SetChecked(healer);
	ConquestFrame.RoleInset.DPSIcon.checkButton:SetChecked(dps);
end


---------------------------------------------------------------
-- CATEGORY FRAME
---------------------------------------------------------------

local pvpFrames = { "HonorFrame", "ConquestFrame", "WarGamesFrame", "LFGListPVPStub" }

function PVPQueueFrame_OnLoad(self)
	--set up side buttons
	local englishFaction = UnitFactionGroup("player");
	SetPortraitToTexture(self.CategoryButton1.Icon, "Interface\\Icons\\achievement_bg_winwsg");
	self.CategoryButton1.Name:SetText(PVP_TAB_HONOR);

	SetPortraitToTexture(self.CategoryButton2.Icon, "Interface\\Icons\\achievement_bg_killxenemies_generalsroom");
	self.CategoryButton2.Name:SetText(PVP_TAB_CONQUEST);

	SetPortraitToTexture(self.CategoryButton3.Icon, "Interface\\Icons\\ability_warrior_offensivestance");
	self.CategoryButton3.Name:SetText(WARGAMES);
	
	SetPortraitToTexture(self.CategoryButton4.Icon, "Interface\\Icons\\Achievement_General_StayClassy");
	self.CategoryButton4.Name:SetText(PVP_TAB_GROUPS);

	-- disable unusable side buttons
	if ( UnitLevel("player") < SHOW_CONQUEST_LEVEL ) then
		PVPQueueFrame_SetCategoryButtonState(self.CategoryButton2, false);
		self.CategoryButton2.tooltip = format(PVP_CONQUEST_LOWLEVEL, PVP_TAB_CONQUEST);
		PVPQueueFrame:SetScript("OnEvent", PVPQueueFrame_OnEvent);
		PVPQueueFrame:RegisterEvent("PLAYER_LEVEL_UP");
	end

	PVPQueueFrame_SetCategoryButtonState(self.CategoryButton4, true);

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
	self:RegisterEvent("VARIABLES_LOADED");
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
		local arg1 = ...
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
	elseif ( event == "VARIABLES_LOADED" ) then
		HonorFrameBonusFrame_UpdateExcludedBattlegrounds();
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

	PVPQueueFrame_UpdateTitle();
	
	PVEFrame.TopTileStreaks:Show()
end

function PVPQueueFrame_UpdateTitle()
	local currentSeason = GetCurrentArenaSeason();
	if currentSeason == NO_ARENA_SEASON then
		PVEFrame.TitleText:SetText(PLAYER_V_PLAYER);
	else
		local LEGION_START_SEASON = 19; -- if you're changing this you probably want to update the global string PLAYER_V_PLAYER_SEASON also
		PVEFrame.TitleText:SetFormattedText(PLAYER_V_PLAYER_SEASON, currentSeason - LEGION_START_SEASON + 1);
	end
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
	PlaySound("igCharacterInfoOpen");
	PVPQueueFrame_ShowFrame(_G[frameName]);
end

function PVPQueueFrame_CheckXPBarLockState(frame)
    local xpBar = frame.XPBar;
    
    PVPHonorXPBar_CheckLockState(xpBar);
    
    if (xpBar.locked) then
        xpBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 13, -7);
    else
        xpBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -7);
    end
end

---------------------------------------------------------------
-- HONOR FRAME
---------------------------------------------------------------

local BlacklistIDs = { };
local MIN_BONUS_HONOR_LEVEL;

function HonorFrame_OnLoad(self)
	self.SpecificFrame.scrollBar.doNotHide = true;
	self.SpecificFrame.update = HonorFrameSpecificList_Update;
	self.SpecificFrame.dynamic = HonorFrame_CalculateScroll;
	HybridScrollFrame_CreateButtons(self.SpecificFrame, "PVPSpecificBattlegroundButtonTemplate", -2, -1);

	-- min level for bonus frame
	local _;
	_, _, _, _, _, _, _, MIN_BONUS_HONOR_LEVEL = GetRandomBGInfo();

	UIDropDownMenu_SetWidth(HonorFrameTypeDropDown, 160);
	UIDropDownMenu_Initialize(HonorFrameTypeDropDown, HonorFrameTypeDropDown_Initialize);
	if ( UnitLevel("player") < MIN_BONUS_HONOR_LEVEL ) then
		HonorFrame_SetType("specific");
	else
		HonorFrame_SetType("bonus");
	end

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
	self:RegisterEvent("PVP_REWARDS_UPDATE");
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
    self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PVP_WORLDSTATE_UPDATE");
	
	if( UIParent.variablesLoaded ) then
		HonorFrame_UpdateBlackList();
	else
		self:RegisterEvent("VARIABLES_LOADED");
	end
end

function HonorFrame_OnShow(self)
    PVPQueueFrame_CheckXPBarLockState(self);
end

function HonorFrame_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LEVEL_UP") then
        PVPQueueFrame_CheckXPBarLockState(self);
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
	elseif ( event == "VARIABLES_LOADED" ) then
		HonorFrame_UpdateBlackList();
	end
end

function HonorFrame_UpdateBlackList()
	for i = 1, GetNumBattlegroundTypes() do
		local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers = GetBattlegroundInfo(i);
		if ( BGMapID and BlacklistIDs[BGMapID] and (not canEnter or isRandom) ) then
			ClearBlacklistMap(BGMapID);
			BlacklistIDs[BGMapID] = nil;
		end
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
	PlaySound("igMainMenuOptionCheckBoxOn");
	HonorFrame.SpecificFrame.selectionID = self.bgID;
	HonorFrameSpecificList_Update();
end

function IncludedBattlegroundsDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, IncludedBattlegroundsDropDown_Initialize, "MENU");
end

function IncludedBattlegroundsDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = INCLUDED_BATTLEGROUNDS
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	for i = 1, NUM_BLACKLIST_INFO_LINES do
		local text = _G["EXCLUDE_BATTLEGROUNDS_LINE_"..i];
		if ( not text or text == "" ) then
			break;
		end
		-- only 1 line is going to have a "%d" but which line it is might differ by language
		info.text = RED_FONT_COLOR_CODE..string.format(text, MAX_BLACKLIST_BATTLEGROUNDS)..FONT_COLOR_CODE_CLOSE;
		info.isTitle = nil;
		info.disabled = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end
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
	-- ugh, need to rerun IncludedBattlegroundsDropDown_Initialize so close and reopen
	IncludedBattlegroundsDropDown_Toggle();
	IncludedBattlegroundsDropDown_Toggle();
end

function IncludedBattlegroundsDropDown_Toggle()
	ToggleDropDownMenu(1, nil, IncludedBattlegroundsDropDown);
end

-------- Bonus BG Frame --------

BONUS_BUTTON_TOOLTIPS = {
	RandomBG = {
		func = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(BONUS_BUTTON_RANDOM_BG_TITLE, 1, 1, 1);
			GameTooltip:AddLine(BONUS_BUTTON_RANDOM_BG_DESC, nil, nil, nil, true);
			
			local bgNames = HonorFrameBonusFrame_GetExcludedBattlegroundNames();
			if bgNames then
				local r, g, b = DULL_RED_FONT_COLOR:GetRGB();
				GameTooltip:AddLine(BONUS_BUTTON_RANDOM_BG_EXCLUDED:format(bgNames), r, g, b, true);
			end
			
			GameTooltip:Show();
		end,
	},
	Skirmish = {
		tooltipKey = "SKIRMISH",
	},
	Ashran = {
		tooltipKey = "ASHRAN",
	},
	Brawl = {
		func = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetPvpBrawl();
		end,
	}
}

function PVPBonusButtonTemplate_OnEnter(self)
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
		local canQueue, battleGroundID, hasWon, winHonorAmount, winConquestAmount, lossHonorAmount, lossConquestAmount, minLevel, maxLevel = GetRandomBGInfo();
		HonorFrameBonusFrame_SetButtonState(button, canQueue, minLevel);
		if ( canQueue ) then
			HonorFrame.BonusFrame.DiceButton:Show();
			if ( not selectButton ) then
				selectButton = button;
			end
		else
			HonorFrame.BonusFrame.DiceButton:Hide();
		end
		HonorFrameBonusFrame_UpdateExcludedBattlegrounds();
		button.canQueue = canQueue;
		button.bgID = battleGroundID;

		local honor, experience, rewards = C_PvP.GetRandomBGRewards();

		if (not rewards) then
			rewards = GetMaxLevelReward(RANDOM_BATTLEGROUNDS, hasWon);
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
		button.Contents.Title:SetText(SKIRMISH);

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

	-- ashran
	do
		local button = HonorFrame.BonusFrame.AshranButton;
		button.Contents.Title:SetText(GetMapNameByID(ASHRAN_MAP_ID));
		button.canQueue = IsLFGDungeonJoinable(ASHRAN_QUEUE_ID);
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
			button.Contents.Title:SetText(brawlInfo.name);
			button.Contents.Title:SetFontObject("GameFontHighlightMedium")
			local honor, experience, rewards, hasWon = C_PvP.GetBrawlRewards(brawlInfo.brawlType);

			if (not rewards) then
				if (brawlInfo.brawlType == Enum.BrawlType.Arena) then
					rewards = GetMaxLevelReward(ARENA_BRAWL_REWARD, hasWon);
				elseif (brawlInfo.brawlType == Enum.BrawlType.Battleground) then
					rewards = GetMaxLevelReward(BG_BRAWL_REWARD, hasWon);
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
				button.Contents.Title:SetText(BRAWL_CLOSED);
			else
				button.Contents.Title:SetText(BRAWL_CLOSED_NEW:format(SecondsToTime(timeUntilNext, false, false, 1)));
			end
			button.Contents.Title:SetFontObject("GameFontDisableMed3");
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

function HonorFrameBonusFrame_GetExcludedBattlegroundNames()
	local bgNames;
	for i = 1, MAX_BLACKLIST_BATTLEGROUNDS do
		local mapName = GetBlacklistMapName(i);
		if ( mapName ) then
			if ( bgNames ) then
				bgNames = bgNames..EXCLUDED_BATTLEGROUNDS_SEPARATOR..mapName;
			else
				bgNames = mapName;
			end
		end
	end
	
	return bgNames;
end

function HonorFrameBonusFrame_UpdateExcludedBattlegrounds()
	local bgNames = HonorFrameBonusFrame_GetExcludedBattlegroundNames();
	if ( bgNames ) then
		HonorFrame.BonusFrame.RandomBGButton.Contents.Title:SetPoint("LEFT", HonorFrame.BonusFrame.RandomBGButton.Contents, "LEFT", 14, 8);
		HonorFrame.BonusFrame.RandomBGButton.Contents.ThumbTexture:Show();
		HonorFrame.BonusFrame.RandomBGButton.Contents.ExcludedBattlegrounds:SetText(bgNames);
	else
		HonorFrame.BonusFrame.RandomBGButton.Contents.Title:SetPoint("LEFT", HonorFrame.BonusFrame.RandomBGButton.Contents, "LEFT", 14, 0);
		HonorFrame.BonusFrame.RandomBGButton.Contents.ThumbTexture:Hide();
		HonorFrame.BonusFrame.RandomBGButton.Contents.ExcludedBattlegrounds:SetText("");
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
		button.Contents.Title:SetTextColor(1, 1, 1);
		button.NormalTexture:SetAlpha(1);
		button:Enable();
		button.Contents.UnlockText:Hide();
		button.Contents.MinLevelText:Hide();
	else
		if ( button == HonorFrame.BonusFrame.selectedButton ) then
			button.SelectedTexture:Hide();
		end
		button.Contents.Title:SetTextColor(0.4, 0.4, 0.4);
		button.NormalTexture:SetAlpha(0.5);
		button:Disable();
		if ( minLevel ) then
			button.Contents.MinLevelText:Show();
			button.Contents.MinLevelText:SetFormattedText(UNIT_LEVEL_TEMPLATE, minLevel);
			button.Contents.UnlockText:Show();
		else
			button.Contents.MinLevelText:Hide();
			button.Contents.UnlockText:Hide();
		end
	end
end

---------------------------------------------------------------
-- CONQUEST FRAME
---------------------------------------------------------------

CONQUEST_SIZE_STRINGS = { ARENA_2V2, ARENA_3V3, BATTLEGROUND_10V10 };
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

function ConquestFrame_Update(self)
    PVPQueueFrame_CheckXPBarLockState(self);
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
			local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon = GetPersonalRatedInfo(bracketIndex);
			button.Wins:SetText(seasonWon);
			button.CurrentRating:SetText(rating);
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
				button.TeamSizeText:SetFontObject(GameFontDisableLarge);
				button.Wins:SetFontObject(GameFontDisable);
				button.CurrentRating:SetFontObject(GameFontDisable);
			else
				button.TeamSizeText:SetFontObject(GameFontHighlightLarge);
				button.Wins:SetFontObject(GameFontNormal);
				button.CurrentRating:SetFontObject(GameFontNormal);
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
		PlaySound("igMainMenuOptionCheckBoxOn");
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
	
	local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest = GetPersonalRatedInfo(self.bracketIndex);
	
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
		local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest = GetPersonalRatedInfo(self.bracketIndex);

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
	WarGamesFrame.otherHeaderIndex = nil;
	UpdateWarGamesList();
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
			local name, pvpType, collapsed, id, minPlayers, maxPlayers, isRandom, iconTexture, shortDescription, longDescription = GetWarGameTypeInfo(index);
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
				warGame.Icon:SetTexture(iconTexture or DEFAULT_BG_TEXTURE);
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
			button.Entry.name = name;
			button.Entry.shortDescription = shortDescription;
			button.Entry.longDescription = longDescription;

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
	self.NameText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	self.SizeText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
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
				return string.format(WARGAME_REQ_ARENA, name, RED_FONT_COLOR_CODE)..FONT_COLOR_CODE_CLOSE;
			end
		else
			if ( groupSize < minPlayers or groupSize > maxPlayers ) then
				return string.format(WARGAME_REQ, name, RED_FONT_COLOR_CODE, minPlayers, maxPlayers)..FONT_COLOR_CODE_CLOSE;
			end
		end
	end
	return nil;
end

function WarGameStartButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local name = GetWarGameTypeInfo(GetSelectedWarGameType());
	if ( name ) then
		StartWarGame("target", name, WarGameTournamentModeCheckButton:GetChecked());
	end
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