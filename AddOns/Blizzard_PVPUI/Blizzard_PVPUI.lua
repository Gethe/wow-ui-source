
MAX_ARENA_TEAM_MEMBERS = 10;

BATTLEGROUND_BUTTON_HEIGHT = 40;

local MAX_SHOWN_BATTLEGROUNDS = 8;
local NO_ARENA_SEASON = 0;

local SEASON_STATE_OFFSEASON = 1;
local SEASON_STATE_PRESEASON = 2;
local SEASON_STATE_ACTIVE = 3;
local SEASON_STATE_DISABLED = 4;

local CONQUEST_CURRENCY_ID = 1602;

local BFA_START_SEASON = 26;

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

function PVPUIFrame_ConfigureRewardFrame(rewardFrame, honor, experience, itemRewards, currencyRewards)
	local itemID, currencyID;
	local rewardTexture, rewardQuantity;
	rewardFrame.conquestAmount = 0;

	-- artifact-level currency trumps item
	if currencyRewards then
		for i, reward in ipairs(currencyRewards) do
			local name, _, texture, _, _, _, _, quality = GetCurrencyInfo(reward.id);
			if quality == LE_ITEM_QUALITY_ARTIFACT then
				name, texture, _, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.id, reward.quantity, name, texture, quality);
				currencyID = reward.id;
				rewardTexture = texture;
				rewardQuantity = reward.quantity;
			elseif reward.id == CONQUEST_CURRENCY_ID then
				rewardFrame.conquestAmount = reward.quantity;
			end
		end
	end

	if not currencyID and itemRewards then
		local reward = itemRewards[1];
		if reward then
			itemID = reward.id;
			rewardTexture = reward.texture;
			rewardQuantity = reward.quantity;
		end
	end

	if currencyID or itemID then
		SetPortraitToTexture(rewardFrame.Icon, rewardTexture);
		rewardFrame.honor = honor;
		rewardFrame.experience = experience;
		rewardFrame.itemID = itemID;
		rewardFrame.currencyID = currencyID;
		rewardFrame.quantity = rewardQuantity;
		rewardFrame:Show();
	else
		rewardFrame:Hide();
	end
end

---------------------------------------------------------------
-- CATEGORY FRAME
---------------------------------------------------------------

local pvpFrames = { "HonorFrame", "ConquestFrame", "LFGListPVPStub" }

function PVPQueueFrame_OnLoad(self)
	--set up side buttons
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
		PortraitFrameTemplate_SetPortraitToAsset(PVEFrame, "Interface\\Icons\\INV_BannerPVP_01");
	else
		PortraitFrameTemplate_SetPortraitToAsset(PVEFrame, "Interface\\Icons\\INV_BannerPVP_02");
	end

	PVPQueueFrame_SetPrestige(self);
	PVPQueueFrame_UpdateTitle();

	PVEFrame.TopTileStreaks:Show()
end

function PVPQueueFrame_UpdateTitle()
	if ConquestFrame.seasonState == SEASON_STATE_PRESEASON then
		PVEFrame.TitleText:SetText(PLAYER_V_PLAYER);
	elseif ConquestFrame.seasonState == SEASON_STATE_OFFSEASON then
		PVEFrame.TitleText:SetText(PLAYER_V_PLAYER_OFF_SEASON);
	else
		PVEFrame.TitleText:SetText(PLAYER_V_PLAYER_SEASON:format(GetCurrentArenaSeason() - BFA_START_SEASON + 1));
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
local HONOR_REWARD_QUEST_ID = 54748;

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

function HonorFrame_OnShow(self)
	-- prime the data;
	HaveQuestRewardData(HONOR_REWARD_QUEST_ID);
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
	info.tooltipWhileDisabled = nil;
	info.tooltipTitle = nil;
	info.tooltipText = nil;
	info.tooltipOnButton = nil;
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
		elseif ( C_LFGList.HasActiveEntryInfo() ) then
			disabledReason = CANNOT_DO_THIS_WHILE_LFGLIST_LISTED;
		end
	end

	HonorFrame.QueueButton.tooltip = disabledReason;
end

function HonorFrame_Queue()
	local HonorFrame = HonorFrame;
	if ( HonorFrame.type == "specific" and HonorFrame.SpecificFrame.selectionID ) then
		JoinBattlefield(HonorFrame.SpecificFrame.selectionID);
	elseif ( HonorFrame.type == "bonus" and HonorFrame.BonusFrame.selectedButton ) then
		if ( HonorFrame.BonusFrame.selectedButton.arenaID ) then
			JoinSkirmish(HonorFrame.BonusFrame.selectedButton.arenaID);
		elseif (HonorFrame.BonusFrame.selectedButton.queueID) then
			ClearAllLFGDungeons(LE_LFG_CATEGORY_WORLDPVP);
			JoinSingleLFG(LE_LFG_CATEGORY_WORLDPVP, HonorFrame.BonusFrame.selectedButton.queueID);
		elseif (HonorFrame.BonusFrame.selectedButton.isBrawl) then
			C_PvP.JoinBrawl();
		else
			JoinBattlefield(HonorFrame.BonusFrame.selectedButton.bgID);
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
		func = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(BONUS_BUTTON_RANDOM_LARGE_BG_TITLE, 1, 1, 1);
			GameTooltip:AddLine(BONUS_BUTTON_RANDOM_LARGE_BG_DESC, nil, nil, nil, true);
			GameTooltip:Show();
		end,
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

		PVPUIFrame_ConfigureRewardFrame(button.Reward, C_PvP.GetRandomBGRewards());
		button.Reward.EnlistmentBonus:SetShown(battlegroundEnlistmentActive);
		button.rewardQuestID = HONOR_REWARD_QUEST_ID;
    end

	-- arena pvp
	do
		local button = HonorFrame.BonusFrame.Arena1Button;
		button.Title:SetText(SKIRMISH);

		PVPUIFrame_ConfigureRewardFrame(button.Reward, C_PvP.GetArenaSkirmishRewards());
	end

	-- epic battleground
	do
		local button = HonorFrame.BonusFrame.RandomEpicBGButton;
		local randomBGInfo = C_PvP.GetRandomEpicBGInfo();
		HonorFrameBonusFrame_SetButtonState(button, randomBGInfo.canQueue, randomBGInfo.minLevel);
		button.canQueue = randomBGInfo.canQueue;
		button.bgID = randomBGInfo.bgID;
		button.Title:SetText(RANDOM_EPIC_BATTLEGROUND);

		PVPUIFrame_ConfigureRewardFrame(button.Reward, C_PvP.GetRandomEpicBGRewards());
		button.rewardQuestID = HONOR_REWARD_QUEST_ID;
	end

	do
		-- brawls
		local button = HonorFrame.BonusFrame.BrawlButton;
		local brawlInfo = C_PvP.GetAvailableBrawlInfo();
		local isMaxLevel = IsPlayerAtEffectiveMaxLevel();
		button.canQueue = brawlInfo and brawlInfo.canQueue and isMaxLevel;
		button.isBrawl = true;

		if (brawlInfo and brawlInfo.canQueue) then
			button:Enable();
			button.Title:SetText(brawlInfo.name);
			button.Title:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());

			PVPUIFrame_ConfigureRewardFrame(button.Reward, C_PvP.GetBrawlRewards(brawlInfo.brawlType));
			button.Reward.EnlistmentBonus:SetShown(brawlEnlistmentActive);
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
		HonorFrame.BonusFrame.BrawlHelpBox:SetShown(ShouldShowBrawlHelpBox(brawlInfo and brawlInfo.canQueue, (IsPlayerAtEffectiveMaxLevel())));
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

	ConquestFrame_EvaluateSeasonState(self);
end

function ConquestFrame_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" or event == "LFG_LIST_SEARCH_RESULT_UPDATED" ) then
		ConquestFrame_UpdateJoinButton(self);
	elseif (event == "PVP_TYPES_ENABLED") then
		local _, ratedBgs, ratedArenas = ...;
		self.bgsEnabled = ratedBgs;
		self.arenasEnabled = ratedArenas;
		self.disabled = not ratedBgs and not ratedArenas;
		ConquestFrame_EvaluateSeasonState(self);
		ConquestFrame_UpdateSeasonFrames(self);
	elseif (self:IsVisible()) then
		ConquestFrame_Update(self);
	end
end

function ConquestFrame_EvaluateSeasonState(self)
	local season = GetCurrentArenaSeason();
	if season == NO_ARENA_SEASON then
		if self.disabled then
			self.seasonState = SEASON_STATE_PRESEASON;
		else
			self.seasonState = SEASON_STATE_OFFSEASON;
		end
	else
		if self.disabled then
			self.seasonState = SEASON_STATE_DISABLED;
		else
			self.seasonState = SEASON_STATE_ACTIVE;
		end
	end
end

function ConquestFrame_UpdateSeasonFrames(self)
	PVPQueueFrame_UpdateTitle();
	PVPQueueFrame.HonorInset:Update();
	HonorFrame.ConquestBar:Update();
	ConquestFrame.ConquestBar:Update();
	ConquestFrame_Update(self);
	ConquestFrame_UpdateJoinButton();
end

function ConquestFrame_IsQueueingEnabled()
	return ConquestFrame.bgsEnabled and ConquestFrame.arenasEnabled;
end

function ConquestFrame_OnShow(self)
	RequestRatedInfo();
	RequestPVPOptionsEnabled();
	ConquestFrame_Update(self);
	local lastSeasonNumber = tonumber(GetCVar("newPvpSeason"));
	if lastSeasonNumber < (GetCurrentArenaSeason() - BFA_START_SEASON + 1) then
		PVPQueueFrame.NewSeasonPopup:Show(); 
	end
end

local tierEnumToName =
{
	[0] = PVP_RANK_0_NAME,
	[1] = PVP_RANK_1_NAME,
	[2] = PVP_RANK_2_NAME,
	[3] = PVP_RANK_3_NAME,
	[4] = PVP_RANK_4_NAME,
	[5] = PVP_RANK_5_NAME,
};

local nextTierEnumToDescription =
{
	[0] = nil,
	[1] = PVP_RANK_1_NEXT_RANK_DESC,
	[2] = PVP_RANK_2_NEXT_RANK_DESC,
	[3] = PVP_RANK_3_NEXT_RANK_DESC,
	[4] = PVP_RANK_4_NEXT_RANK_DESC,
	[5] = PVP_RANK_5_NEXT_RANK_DESC,
};

function PVPRatedTier_OnEnter(self)
	if self.tierInfo and self.tierInfo.pvpTierEnum and tierEnumToName[self.tierInfo.pvpTierEnum] then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, tierEnumToName[self.tierInfo.pvpTierEnum]);
		GameTooltip:Show();
	end
end

function NextTier_OnEnter(self)
	if self.tierInfo and self.tierInfo.pvpTierEnum and tierEnumToName[self.tierInfo.pvpTierEnum] then
		local WORD_WRAP = true;
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, TOOLTIP_PVP_NEXT_RANK:format(tierEnumToName[self.tierInfo.pvpTierEnum]));
		if nextTierEnumToDescription[self.tierInfo.pvpTierEnum] then
			GameTooltip:SetMinimumWidth(260);
			GameTooltip_AddNormalLine(GameTooltip, nextTierEnumToDescription[self.tierInfo.pvpTierEnum], WORD_WRAP);
		end
		local activityItemLevel, weeklyItemLevel = C_PvP.GetRewardItemLevelsByTierEnum(self.tierInfo.pvpTierEnum);
		if activityItemLevel > 0 then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, PVP_GEAR_REWARD_CHANCE_LONG:format(activityItemLevel), NORMAL_FONT_COLOR, WORD_WRAP);
		end
		GameTooltip:Show();
	end
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

	tierFrame.tierInfo = tierInfo;
end

function ConquestFrame_Update(self)
	local isOffseason = GetCurrentArenaSeason() == NO_ARENA_SEASON;
	if self.seasonState == SEASON_STATE_PRESEASON then
		ConquestFrame.NoSeason:Show();
		ConquestFrame.Disabled:Hide();
	elseif self.seasonState == SEASON_STATE_DISABLED then
		ConquestFrame.NoSeason:Hide();
		ConquestFrame.Disabled:Show();
	else
		local isOffseason = self.seasonState == SEASON_STATE_OFFSEASON;
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
				button.pvpTierEnum = tierInfo.pvpTierEnum;
			else
				button.CurrentRating:Hide();
			end
			ConquestFrame_SetTierInfo(button.Tier, tierInfo, ranking);
			if isOffseason then
				button.Tier:SetAlpha(0.25);
			else
				button.Tier:SetAlpha(1);
			end
			button.bracketIndex = bracketIndex;

			local enabled;

			if (i == RATED_BG_ID) then
				enabled = self.bgsEnabled;
				if enabled then
					PVPUIFrame_ConfigureRewardFrame(button.Reward, C_PvP.GetRatedBGRewards());
				end
			else
				enabled = self.arenasEnabled;
				if enabled then
					PVPUIFrame_ConfigureRewardFrame(button.Reward, C_PvP.GetArenaRewards(CONQUEST_SIZES[i]));
				end
			end
			button:SetEnabled(enabled);

			if (not enabled) then
				button.TeamSizeText:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
				button.CurrentRating:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
				button.Reward:Hide();
			elseif (isOffseason) then
				button.TeamSizeText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
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

	if ConquestFrame.seasonState == SEASON_STATE_DISABLED or ConquestFrame.seasonState == SEASON_STATE_PRESEASON then
		button:Disable();
		button.tooltip = nil;
		return;
	end

	--Disable the button if the person is active in LFGList
	local lfgListDisabled;
	if ( select(2,C_LFGList.GetNumApplications()) > 0 ) then
		lfgListDisabled = CANNOT_DO_THIS_WITH_LFGLIST_APP;
	elseif ( C_LFGList.HasActiveEntryInfo() ) then
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

	local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking = GetPersonalRatedInfo(self.bracketIndex);

	tooltip.Title:SetText(self.toolTipTitle);

	local tierInfo = C_PvP.GetPvpTierInfo(pvpTier);
	if tierInfo and tierInfo.pvpTierEnum and tierEnumToName[tierInfo.pvpTierEnum] then
		if ranking then
			tooltip.Tier:SetFormattedText(PVP_TIER_WITH_RANK_AND_RATING, tierEnumToName[tierInfo.pvpTierEnum], ranking, rating);
		else
			tooltip.Tier:SetFormattedText(PVP_TIER_WITH_RATING, tierEnumToName[tierInfo.pvpTierEnum], rating);
		end
	else
		tooltip.Tier:SetText("");
	end

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
	tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);
	tooltip:Show();
end

---------------------------------------------------------------
-- Rewards
---------------------------------------------------------------

function PVPRewardTemplate_OnEnter(self)
	if (not self.Icon:IsShown()) then
		return;
	end
	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
	EmbeddedItemTooltip:SetText(PVP_REWARD_TOOLTIP);
	self.UpdateTooltip = nil;

	if (self.experience > 0) then
		GameTooltip_AddColoredLine(EmbeddedItemTooltip, PVP_REWARD_XP_FORMAT:format(BreakUpLargeNumbers(self.experience)), HIGHLIGHT_FONT_COLOR);
	else
		GameTooltip_AddColoredLine(EmbeddedItemTooltip, REWARD_FOR_PVP_WIN_HONOR:format(BreakUpLargeNumbers(self.honor)), HIGHLIGHT_FONT_COLOR);
	end
	if self.conquestAmount > 0 then
		local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(CONQUEST_CURRENCY_ID, self.conquestAmount);
		if currencyInfo then
			local text = BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format(currencyInfo.icon, currencyInfo.displayAmount, currencyInfo.name);
			local currencyColor = GetColorForCurrencyReward(CONQUEST_CURRENCY_ID, self.conquestAmount);
			EmbeddedItemTooltip:AddLine(text, currencyColor:GetRGB());
		end
	end
	local activityItemLevel;
	local pvpTierEnum = self:GetParent().pvpTierEnum;
	if pvpTierEnum then
		activityItemLevel = C_PvP.GetRewardItemLevelsByTierEnum(pvpTierEnum);
	end
	local rewardQuestID = self:GetParent().rewardQuestID;
	if rewardQuestID then
		if HaveQuestRewardData(rewardQuestID) then
			activityItemLevel = select(7, GetQuestLogRewardInfo(1, rewardQuestID));
		else
			self.UpdateTooltip = PVPRewardTemplate_OnEnter;
		end
	end
	if activityItemLevel and activityItemLevel > 0 then
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
		GameTooltip_AddColoredLine(EmbeddedItemTooltip, PVP_GEAR_REWARD_CHANCE:format(activityItemLevel), HIGHLIGHT_FONT_COLOR);
	end
	if self.itemID then
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
		EmbeddedItemTooltip_SetItemByID(EmbeddedItemTooltip.ItemTooltip, self.itemID);
	elseif self.currencyID then
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
		EmbeddedItemTooltip_SetCurrencyByID(EmbeddedItemTooltip.ItemTooltip, self.currencyID, self.quantity);
	end
	EmbeddedItemTooltip:Show();
end

function PVPRewardTemplate_OnLeave(self)
	EmbeddedItemTooltip:Hide();
	self.UpdateTooltip = nil;
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

	local seasonState = ConquestFrame.seasonState;

	panel.SeasonRewardFrame:SetShown(seasonState ~= SEASON_STATE_PRESEASON);

	if seasonState == SEASON_STATE_PRESEASON then
		panel.Tier:Hide();
	else
		panel.Tier:Show();

		if seasonState == SEASON_STATE_OFFSEASON then
			panel.Tier.Title:SetText(PVP_LAST_SEASON_HIGH);
			panel.Tier.Title:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		else
			panel.Tier.Title:SetText(PVP_SEASON_HIGH);
			panel.Tier.Title:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end

		local tierID, nextTierID = C_PvP.GetSeasonBestInfo();
		local tierInfo = C_PvP.GetPvpTierInfo(tierID);
		ConquestFrame_SetTierInfo(panel.Tier, tierInfo);

		local nextTierInfo = nextTierID and C_PvP.GetPvpTierInfo(nextTierID);
		if nextTierInfo and seasonState ~= SEASON_STATE_OFFSEASON then
			panel.Tier.NextTier.tierInfo = nextTierInfo;
			panel.Tier.NextTier.Icon:SetTexture(nextTierInfo.tierIconID);
			panel.Tier.NextTier:Show();
		else
			panel.Tier.NextTier.tierInfo = nil;
			panel.Tier.NextTier:Hide();
		end
	end
end

PVPUIHonorLevelDisplayMixin = { };

function PVPUIHonorLevelDisplayMixin:OnLoad()
	self:Pause();
	if UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] then
		self.Background:SetAtlas("pvpqueue-sidebar-honorbar-background-horde", false);
		self.FactionBadge:SetAtlas("pvpqueue-sidebar-honorbar-badge-horde", false);
	else
		self.Background:SetAtlas("pvpqueue-sidebar-honorbar-background-alliance", false);
		self.FactionBadge:SetAtlas("pvpqueue-sidebar-honorbar-badge-alliance", false);
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
		self.FactionBadge:Hide();
	else
		self.LevelBadge:Hide();
		self.FactionBadge:Show();
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
			GameTooltip_AddColoredLine(GameTooltip, rewardText, HIGHLIGHT_FONT_COLOR, WRAP);
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

function PVPUIHonorLevelDisplayMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, -20);
	GameTooltip:SetText(HONOR);
	local currentHonor = UnitHonor("player");
	local maxHonor = UnitHonorMax("player");
	GameTooltip_AddColoredLine(GameTooltip, string.format(GENERIC_FRACTION_STRING_WITH_SPACING, currentHonor, maxHonor), HIGHLIGHT_FONT_COLOR);
	GameTooltip:Show();
end

PVPUISeasonRewardFrameMixin = { };

local SEASON_REWARD_ACHIEVEMENTS = {
	[BFA_START_SEASON] = {
		[PLAYER_FACTION_GROUP[0]] = 13136,
		[PLAYER_FACTION_GROUP[1]] = 13137,
	},
	[BFA_START_SEASON + 1] = {
		[PLAYER_FACTION_GROUP[0]] = 13227,
		[PLAYER_FACTION_GROUP[1]] = 13228,
	},
};

function PVPUISeasonRewardFrameMixin:GetAchievementID()
	local seasonAchievements = SEASON_REWARD_ACHIEVEMENTS[GetCurrentArenaSeason()];
	local achievementID = seasonAchievements and seasonAchievements[UnitFactionGroup("player")];
	if achievementID then
		local id, name, points, completed = GetAchievementInfo(achievementID);
		local supercedingAchievements = C_AchievementInfo.GetSupercedingAchievements(achievementID);
		while completed and supercedingAchievements[1] do
			achievementID = supercedingAchievements[1];
			id, name, points, completed = GetAchievementInfo(achievementID);
			supercedingAchievements = C_AchievementInfo.GetSupercedingAchievements(achievementID);
		end
	end
	return achievementID;
end

function PVPUISeasonRewardFrameMixin:OnShow()
	self:Update();
end

function PVPUISeasonRewardFrameMixin:Update()
	local achievementID = self:GetAchievementID();
	if achievementID then
		local rewardItemID = C_AchievementInfo.GetRewardItemID(achievementID);
		local texture = rewardItemID and select(5, GetItemInfoInstant(rewardItemID)) or nil;
		self.Icon:SetTexture(texture);
		self.Icon:Show();
		local completed = false;
		if  GetAchievementNumCriteria(achievementID) > 0 then
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
	local achievementID = self:GetAchievementID();
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
			local rewardItemID = C_AchievementInfo.GetRewardItemID(achievementID);
			if rewardItemID then
				GameTooltip_AddBlankLinesToTooltip(EmbeddedItemTooltip, 1);
				GameTooltip_AddNormalLine(EmbeddedItemTooltip, REWARD, wordWrap);
				EmbeddedItemTooltip_SetItemByID(EmbeddedItemTooltip.ItemTooltip, rewardItemID);
			end
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
	local locked = not IsPlayerAtEffectiveMaxLevel();
	self.Lock:SetShown(locked);

	local inactiveSeason = ConquestFrame.seasonState == SEASON_STATE_PRESEASON or ConquestFrame.seasonState == SEASON_STATE_DISABLED;
	local currentValue, maxValue, questID = self:GetConquestLevelInfo();
	local questDone = questID and questID == 0;
	if locked or inactiveSeason or questDone or maxValue == 0 then
		self:SetValue(0);
	else
		self:SetValue(currentValue / maxValue * 100);
	end
	self:SetDisabled(inactiveSeason or locked or questDone);
	self.Label:SetFormattedText(CONQUEST_BAR, currentValue, maxValue);

	if locked or inactiveSeason or not questID then
		self.Reward:Clear();
	else
		self.Reward:SetUp(questID);
	end
end

function PVPConquestBarMixin:GetConquestLevelInfo()
	local CONQUEST_QUESTLINE_ID = 782;
	local currentQuestID = QuestUtils_GetCurrentQuestLineQuest(CONQUEST_QUESTLINE_ID);

	-- if not on a current quest that means all caught up for this week
	if currentQuestID == 0 then
		return 0, 0, 0;
	end

	if not HaveQuestData(currentQuestID) then
		return 0, 0, nil;
	end

	local objectives = C_QuestLog.GetQuestObjectives(currentQuestID);
	if not objectives or not objectives[1] then
		return 0, 0, nil;
	end

	return objectives[1].numFulfilled, objectives[1].numRequired, currentQuestID;
end

function PVPConquestBarMixin:SetDisabled(disabled)
	if self.disabled ~= disabled then
		self.Border:SetDesaturated(disabled);
		self.Background:SetDesaturated(disabled);
		self.Reward.Ring:SetDesaturated(disabled);
		self.Reward.Icon:SetDesaturated(disabled);
		self.Label:SetAlpha(disabled and 0 or 1);
		local alpha = disabled and 0.6 or 1;
		self.Border:SetAlpha(alpha);
		self.Background:SetAlpha(alpha);
		self.disabled = disabled;
	end
end

function PVPConquestBarMixin:OnEnter()
	self.Reward:TryShowTooltip();
end

function PVPConquestBarMixin:OnLeave()
	self.Reward:HideTooltip();
end

PVPConquestBarRewardMixin = { };

function PVPConquestBarRewardMixin:SetUp(questID)
	self.questID = questID;
	if questID == 0 then
		self:SetTexture("Interface\\Icons\\inv_misc_bag_10", 0.2);
		self.CheckMark:Show();
		self.CheckMark:SetDesaturated(true);
	else
		if IsQuestComplete(questID) then
			self.CheckMark:Show();
			self.CheckMark:SetDesaturated(false);
		else
			self.CheckMark:Hide();
		end
		local itemTexture;
		if HaveQuestRewardData(questID) then
			local itemIndex = QuestUtils_GetBestQualityItemRewardIndex(questID);
			itemTexture = select(2, GetQuestLogRewardInfo(itemIndex, questID));
		end
		self:SetTexture(itemTexture, 1);
	end
end

function PVPConquestBarRewardMixin:Clear()
	self:SetTexture(nil, 1);
	self.questID = nil;
	self.CheckMark:Hide();
end

function PVPConquestBarRewardMixin:SetTexture(texture, alpha)
	if texture then
		self.Icon:SetTexture(texture);
	else
		self.Icon:SetColorTexture(0, 0, 0);
	end
	self.Icon:SetAlpha(alpha);
end

function PVPConquestBarRewardMixin:TryShowTooltip()
	local WORD_WRAP = true;
	if ConquestFrame.seasonState == SEASON_STATE_PRESEASON then
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(EmbeddedItemTooltip, PVP_CONQUEST, HIGHLIGHT_FONT_COLOR);
		GameTooltip_AddColoredLine(EmbeddedItemTooltip, CONQUEST_REQUIRES_PVP_SEASON, NORMAL_FONT_COLOR, WORD_WRAP);
		EmbeddedItemTooltip:Show();
	elseif self.questID == 0 then
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(EmbeddedItemTooltip, PVP_CONQUEST, HIGHLIGHT_FONT_COLOR);
		GameTooltip_AddColoredLine(EmbeddedItemTooltip, CONQUEST_BAR_REWARD_DONE, NORMAL_FONT_COLOR, WORD_WRAP);
		EmbeddedItemTooltip:Show();
	elseif self.questID and self:IsMouseOver() then
		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		GameTooltip_SetTitle(EmbeddedItemTooltip, PVP_CONQUEST);
		if IsQuestComplete(self.questID) then
			GameTooltip_AddNormalLine(EmbeddedItemTooltip, CONQUEST_BAR_REWARD_COLLECT, WORD_WRAP);
			GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
		end
		GameTooltip_AddNormalLine(EmbeddedItemTooltip, SAMPLE_REWARD_WITH_COLON);
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
		GameTooltip_AddQuestRewardsToTooltip(EmbeddedItemTooltip, self.questID, TOOLTIP_QUEST_REWARDS_STYLE_CONQUEST_BAR);
		self.UpdateTooltip = self.OnEnter;

		if IsModifiedClick("DRESSUP") then
			ShowInspectCursor();
		else
			ResetCursor();
		end
		EmbeddedItemTooltip:Show();
	end
end

function PVPConquestBarRewardMixin:HideTooltip()
	EmbeddedItemTooltip:Hide();
	self.UpdateTooltip = nil;
end

function PVPConquestBarRewardMixin:OnEnter()
	self:TryShowTooltip();
end

function PVPConquestBarRewardMixin:OnLeave()
	ResetCursor();
	self:HideTooltip();
end

function PVPConquestBarRewardMixin:OnClick()
	if self.questID and self.questID > 0 and IsModifiedClick() then
		local itemIndex = QuestUtils_GetBestQualityItemRewardIndex(self.questID);
		HandleModifiedItemClick(GetQuestLogItemLink("reward", itemIndex, self.questID));
	end
end

NewPvpSeasonMixin = { };

function NewPvpSeasonMixin:OnShow()
	local currentSeasonNumber = GetCurrentArenaSeason() - BFA_START_SEASON + 1;
	self.SeasonDescription:SetText(BFA_SEASON_NUMBER:format(currentSeasonNumber));
	self.SeasonDescription2:SetText(BFA_PVP_SEASON_DESCRIPTION_TWO);
end

PVPWeeklyChestMixin = { };

function PVPWeeklyChestMixin:GetState()
	local rewardAchieved, lastWeekRewardAchieved, lastWeekRewardClaimed, pvpTierMaxFromWins = C_PvP.GetWeeklyChestInfo();
	if lastWeekRewardAchieved and not lastWeekRewardClaimed then
		return "collect";
	elseif rewardAchieved then
		return "complete";
	end
	return "incomplete";
end

function PVPWeeklyChestMixin:OnShow()
	local state = self:GetState();
	local atlas;
	if (UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0]) then
		atlas = "pvpqueue-chest-horde-"..state;
	else
		atlas = "pvpqueue-chest-alliance-"..state;
	end
	self.ChestTexture:SetAtlas(atlas);

	if state == "collect" then
		self.SpinTextureBottom:Show();
		self.SpinTextureTop:Show();
		self.SpinAnim:Play();
	else
		self.SpinTextureBottom:Hide();
		self.SpinTextureTop:Hide();
		self.SpinAnim:Stop();
	end
end

function PVPWeeklyChestMixin:OnEnter()
	local state = self:GetState();
	local title, description, showItemLevel;
	if state == "incomplete" then
		title = RATED_PVP_WEEKLY_CHEST;
		description = RATED_PVP_WEEKLY_CHEST_TOOLTIP_INCOMPLETE;
		showItemLevel = true;
	elseif state == "complete" then
		title = RATED_PVP_WEEKLY_CHEST_EARNED;
		description = RATED_PVP_WEEKLY_CHEST_TOOLTIP_COMPLETE;
		showItemLevel = true;
	elseif state == "collect" then
		title = RATED_PVP_WEEKLY_CHEST;
		description = RATED_PVP_WEEKLY_CHEST_TOOLTIP_COLLECT;
		showItemLevel = false;
	end

	if showItemLevel then
		local rewardAchieved, lastWeekRewardAchieved, lastWeekRewardClaimed, pvpTierMaxFromWins = C_PvP.GetWeeklyChestInfo();
		-- it's -1 if you haven't won any matches in the current season
		pvpTierMaxFromWins = max(pvpTierMaxFromWins, 0);
		local activityItemLevel, weeklyItemLevel = C_PvP.GetRewardItemLevelsByTierEnum(pvpTierMaxFromWins);
		description = description:format(weeklyItemLevel);
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local WORD_WRAP = true;
	GameTooltip_SetTitle(GameTooltip, title);
	GameTooltip_AddColoredLine(GameTooltip, description, NORMAL_FONT_COLOR, WORD_WRAP);
	if state == "incomplete" then
		local current, max = ConquestFrame.ConquestBar:GetConquestLevelInfo();
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddColoredLine(GameTooltip, RATED_PVP_WEEKLY_CHEST_REQUIREMENTS:format(current, max), HIGHLIGHT_FONT_COLOR, WORD_WRAP);	
	end
	GameTooltip:Show();
end

function PVPNewSeasonPopupOnClick(self)
	self:GetParent():Hide();
	SetCVar("newPvpSeason", GetCurrentArenaSeason() - BFA_START_SEASON + 1);
end