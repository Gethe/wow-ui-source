
MAX_ARENA_TEAM_MEMBERS = 10;
MAX_BLACKLIST_BATTLEGROUNDS = 2;

HORDE_TEX_COORDS = {left=0.00195313, right=0.63867188, top=0.31738281, bottom=0.44238281}
ALLIANCE_TEX_COORDS = {left=0.00195313, right=0.63867188, top=0.19042969, bottom=0.31542969}

WARGAME_HEADER_HEIGHT = 16;
BATTLEGROUND_BUTTON_HEIGHT = 40;

local MAX_SHOWN_BATTLEGROUNDS = 8;
local NUM_BLACKLIST_INFO_LINES = 2;
local NO_ARENA_SEASON = 0;

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

local DEFAULT_BG_TEXTURE = "Interface\\PVPFrame\\RandomPVPIcon";

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

	RequestRandomBattlegroundInstanceInfo();

	self:RegisterEvent("BATTLEFIELDS_CLOSED");

	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PVP_ROLE_UPDATE");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
end

function PVPUIFrame_OnShow(self)
	if (UnitLevel("player") < SHOW_PVP_LEVEL or IsBlizzCon()) then
		self:Hide();
		return;
	end
	UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");

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
	PVPUIFrame_SetRoles();
end

function PVPUIFrame_SetRoles()
	SetPVPRoles(HonorFrame.RoleInset.TankIcon.checkButton:GetChecked(),
		HonorFrame.RoleInset.HealerIcon.checkButton:GetChecked(),
		HonorFrame.RoleInset.DPSIcon.checkButton:GetChecked());
end

function PVPUIFrame_UpdateRolesChangeable()
	if ( PVPHelper_CanChangeRoles() ) then
		PVPUIFrame_UpdateAvailableRoles(HonorFrame.RoleInset.TankIcon, HonorFrame.RoleInset.HealerIcon, HonorFrame.RoleInset.DPSIcon);
	else
		LFG_DisableRoleButton(HonorFrame.RoleInset.TankIcon);
		LFG_DisableRoleButton(HonorFrame.RoleInset.HealerIcon);
		LFG_DisableRoleButton(HonorFrame.RoleInset.DPSIcon);
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
	if ( UnitLevel("player") < SHOW_CONQUEST_LEVEL ) then
		PVPQueueFrame_SetCategoryButtonState(self.CategoryButton2, false);
		self.CategoryButton2.tooltip = format(PVP_CONQUEST_LOWLEVEL, PVP_TAB_CONQUEST);
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
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	self:RegisterEvent("PVP_REWARDS_UPDATE");
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("VARIABLES_LOADED");
end

function PVPQueueFrame_OnEvent(self, event, ...)
	if (event == "PLAYER_LEVEL_UP") then
		local level = ...;
		if ( level >= SHOW_CONQUEST_LEVEL ) then
			PVPQueueFrame_SetCategoryButtonState(self.CategoryButton2, true);
			self.CategoryButton2.tooltip = nil;
			PVPQueueFrame:UnregisterEvent("PLAYER_LEVEL_UP");
		end
	elseif(event == "CURRENCY_DISPLAY_UPDATE") then
		PVPQueueFrame_UpdateCurrencies(self)
		if ( self:IsShown() ) then
			RequestPVPRewards();
		end
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED") then
		local arg1 = ...
		PVP_UpdateStatus();
	elseif ( event == "PVP_RATED_STATS_UPDATE" ) then
		PVPQueueFrame_UpdateCurrencies(self);
	elseif ( event == "PVP_REWARDS_UPDATE" ) then
		PVPQueueFrame_UpdateCurrencies(self);
	elseif ( event == "BATTLEFIELDS_SHOW" ) then
		local isArena, bgID = ...;
		if (isArena) then
			PVPQueueFrame_ShowFrame(ConquestFrame);
			ShowUIPanel(PVPUIFrame);
		else
			PVPQueueFrame_ShowFrame(HonorFrame);
			ShowUIPanel(PVPUIFrame);
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
	PlaySound("igCharacterInfoOpen");
	PVPQueueFrame_ShowFrame(_G[frameName]);
end

---------------------------------------------------------------
-- HONOR FRAME
---------------------------------------------------------------

local BlacklistIDs = { };
local MIN_BONUS_HONOR_LEVEL;

function HonorFrame_OnLoad(self)
	self.SpecificFrame.scrollBar.doNotHide = true;
	self.SpecificFrame.update = HonorFrameSpecificList_Update;
	HybridScrollFrame_CreateButtons(self.SpecificFrame, "PVPSpecificBattlegroundButtonTemplate", -2, -1);

	-- min level for bonus frame
	local _, minLevel;
	_, _, _, _, _, _, _, MIN_BONUS_HONOR_LEVEL = GetRandomBGInfo();
	_, _, _, _, _, _, _, _, _, minLevel = GetHolidayBGInfo();
	minLevel = minLevel and minLevel or MIN_BONUS_HONOR_LEVEL;
	MIN_BONUS_HONOR_LEVEL = min(MIN_BONUS_HONOR_LEVEL, minLevel);

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
end

function HonorFrame_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		HonorFrameSpecificList_Update();
		HonorFrameBonusFrame_Update();
		PVP_UpdateStatus();
	elseif ( event == "PVPQUEUE_ANYWHERE_SHOW" or event ==  "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE"
			or event == "PVP_RATED_STATS_UPDATE") then
		HonorFrameSpecificList_Update();
		HonorFrameBonusFrame_Update();
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		HonorFrame_UpdateQueueButtons();
	elseif ( event == "PVP_REWARDS_UPDATE" and self:IsShown() ) then
		RequestRandomBattlegroundInstanceInfo();
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
	local isWorldPVP;
	if ( HonorFrame.type == "specific" ) then
		if ( HonorFrame.SpecificFrame.selectionID ) then
			canQueue = true;
		end
	elseif ( HonorFrame.type == "bonus" ) then
		if ( HonorFrame.BonusFrame.selectedButton ) then
			if ( HonorFrame.BonusFrame.selectedButton.canQueue ) then
				canQueue = true;
			end
			isWorldPVP = HonorFrame.BonusFrame.selectedButton.worldID;
		end
	end

	if ( canQueue ) then
		HonorFrame.SoloQueueButton:Enable();
		if ( not isWorldPVP and IsInGroup() and UnitIsGroupLeader("player") ) then
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
		local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers, gameType, iconTexture = GetBattlegroundInfo(i);
		if ( localizedName and canEnter and not isRandom ) then
			buttonCount = buttonCount + 1;
			if ( buttonCount > 0 and buttonCount <= numButtons ) then
				local button = buttons[buttonCount];
				button:Show();
				button.NameText:SetText(localizedName);
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
		info.text = RED_FONT_COLOR_CODE..string.format(text, MAX_BLACKLIST_BATTLEGROUNDS);
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

function HonorFrameBonusFrame_OnShow(self)
	self.updateTime = 0;
	HonorFrameBonusFrame_Update();
	RequestRandomBattlegroundInstanceInfo();
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
	local selectButton = nil;
	local _, _, _, _, _, _, _, _, arenaReward, ratedBGReward = GetPVPRewards();
	-- random bg
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
	-- call to arms
	button = HonorFrame.BonusFrame.CallToArmsButton;
	local hasData, canQueue, bgName, battleGroundID, hasWon, winHonorAmount, winConquestAmount, lossHonorAmount, lossConquestAmount, minLevel, maxLevel = GetHolidayBGInfo();
	if ( hasData ) then
		-- cap conquest to total earnable
		if ( arenaReward < winConquestAmount ) then
			winConquestAmount = arenaReward
		elseif ( ratedBGReward < winConquestAmount ) then
			winConquestAmount = ratedBGReward
		end
		HonorFrameBonusFrame_SetButtonState(button, canQueue, minLevel);
		button.Contents.BattlegroundName:SetText(bgName);
		if ( canQueue ) then
			button.Contents.BattlegroundName:SetTextColor(0.7, 0.7, 0.7);
			if ( not selectButton ) then
				selectButton = button;
			end
		else
			button.Contents.BattlegroundName:SetTextColor(0.4, 0.4, 0.4);
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
		if ( rewardIndex == 0 ) then
			-- we don't have any rewards
			HonorFrame.BonusFrame.NoBattlegroundReward:Show();
		else
			HonorFrame.BonusFrame.NoBattlegroundReward:Hide();
		end
	else
		HonorFrameBonusFrame_SetButtonState(button, false, nil);
		button.Contents.BattlegroundName:SetText("");
		button.canQueue = false;
		button.bgID = nil;
		HonorFrame.BonusFrame.BattlegroundReward1:Hide();
		HonorFrame.BonusFrame.BattlegroundReward2:Hide();
		HonorFrame.BonusFrame.NoBattlegroundReward:Show();
	end
	-- world pvp
	for i = 1, 2 do
		button = HonorFrame.BonusFrame["WorldPVP"..i.."Button"];
		local areaID, localizedName, isActive, canQueue, startTime, canEnter, minLevel, maxLevel = GetWorldPVPAreaInfo(i);
		button.Contents.Title:SetText(localizedName);
		HonorFrameBonusFrame_SetButtonState(button, canEnter, minLevel);
		if ( canEnter ) then
			HonorFrameBonusFrame_UpdateWorldPVPTime(button, isActive, startTime);
			if ( not selectButton ) then
				selectButton = button;
			end
		else
			button.Contents.InProgressText:Hide();
			button.Contents.NextBattleText:Hide();
			button.Contents.TimeText:Hide();
		end
		button.canQueue = canQueue;
		button.worldID = i;
	end
	-- TODO: rewards for world pvp

	-- select a button if one isn't selected
	if ( not HonorFrame.BonusFrame.selectedButton and selectButton ) then
		HonorFrameBonusFrame_SelectButton(selectButton);
	else
		HonorFrame_UpdateQueueButtons();
	end
end

function HonorFrameBonusFrame_UpdateExcludedBattlegrounds()
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
	if ( bgNames ) then
		HonorFrame.BonusFrame.RandomBGButton.Contents.ThumbTexture:Show();
		HonorFrame.BonusFrame.RandomBGButton.Contents.ExcludedBattlegrounds:SetText(bgNames);
	else
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

function HonorFrameBonusFrame_UpdateWorldPVPTime(button, isActive, startTime)
	if ( isActive ) then
		button.Contents.InProgressText:Show();
		button.Contents.NextBattleText:Hide();
		button.Contents.TimeText:Hide();
	else
		button.Contents.InProgressText:Hide();
		button.Contents.NextBattleText:Show();
		button.Contents.TimeText:Show();
		button.Contents.TimeText:SetText(SecondsToTime(startTime));
	end
end

---------------------------------------------------------------
-- CONQUEST FRAME
---------------------------------------------------------------

CONQUEST_SIZE_STRINGS = { ARENA_2V2, ARENA_3V3, ARENA_5V5, BATTLEGROUND_10V10 };
CONQUEST_SIZES = {2, 3, 5, 10};
CONQUEST_BUTTONS = {};
local RATED_BG_ID = 4;

function ConquestFrame_OnLoad(self)

	CONQUEST_BUTTONS = {ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.Arena5v5, ConquestFrame.RatedBG};

	local factionGroup = UnitFactionGroup("player");
	self.ArenaReward.Icon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);
	self.RatedBGReward.Icon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..factionGroup);

	RequestRatedInfo();
	RequestPVPRewards();
	RequestPVPOptionsEnabled();
	
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	self:RegisterEvent("PVP_REWARDS_UPDATE");
end

function ConquestFrame_OnEvent(self, event, ...)
	ConquestFrame_Update(self);
end

function ConquestFrame_OnShow(self)
	RequestRatedInfo();
	RequestPVPRewards();
	RequestPVPOptionsEnabled();
	ConquestFrame_Update(self);
end

function ConquestFrame_Update(self)
	if ( GetCurrentArenaSeason() == NO_ARENA_SEASON ) then
		ConquestFrame.NoSeason:Show();
	else
		ConquestFrame.NoSeason:Hide();
		local _, _, _, _, _, _, _, _, arenaReward, ratedBGReward = GetPVPRewards();
		if (arenaReward == 0) then
			RequestPVPRewards();
		end
		self.RatedBGReward.Amount:SetText(ratedBGReward);
		self.ArenaReward.Amount:SetText(arenaReward);
		ConquestFrame_UpdateConquestBar(self);
		
		for i = 1, RATED_BG_ID do
			local button = CONQUEST_BUTTONS[i];
			local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon = GetPersonalRatedInfo(i);
			button.Wins:SetText(seasonWon);
			button.BestRating:SetText(weeklyBest);
			button.CurrentRating:SetText(rating);
		end
		
		if ( not ConquestFrame.selectedButton ) then
			-- if nothing's selected select rated BG cuz why the heck not
			ConquestFrame_SelectButton(ConquestFrame.RatedBG);
		else
			ConquestFrame_UpdateJoinButton();
		end
	end
end

function ConquestFrame_UpdateConquestBar(self)
	currencyName, currencyAmount = GetCurrencyInfo(CONQUEST_CURRENCY);
	local pointsThisWeek, maxPointsThisWeek, tier2Quantity, tier2Limit, tier1Quantity, tier1Limit, randomPointsThisWeek, maxRandomPointsThisWeek, arenaReward, ratedBGReward = GetPVPRewards();
	-- just want a plain bar
	CapProgressBar_Update(self.ConquestBar, 0, 0, nil, nil, pointsThisWeek, maxPointsThisWeek);
	self.ConquestBar.label:SetFormattedText(CURRENCY_THIS_WEEK, currencyName);
end

function ConquestFrame_UpdateJoinButton()
	local button = ConquestFrame.JoinButton;
	local groupSize = GetNumGroupMembers();
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
					button.tooltip = nil;
					button:Enable();
					return;
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

function ConquestFrame_ShowMaximumRewardsTooltip(self)
	local currencyName = GetCurrencyInfo(CONQUEST_CURRENCY);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(MAXIMUM_REWARD);
	GameTooltip:AddLine(format(CURRENCY_RECEIVED_THIS_WEEK, currencyName), 1, 1, 1, true);
	GameTooltip:AddLine(" ");

	local pointsThisWeek, maxPointsThisWeek, tier2Quantity, tier2Limit, tier1Quantity, tier1Limit, randomPointsThisWeek, maxRandomPointsThisWeek, arenaReward, ratedBGReward = GetPVPRewards();

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

local CONQUEST_TOOLTIP_PADDING = 30 --counts both sides

function ConquestFrameButton_OnEnter(self)
	local tooltip = ConquestTooltip;
	
	local rating, seasonBest, weeklyBest, seasonPlayed, _, weeklyPlayed, _, cap = GetPersonalRatedInfo(self.id);
	
	tooltip.WeeklyBest:SetText(PVP_BEST_RATING..weeklyBest);
	tooltip.WeeklyGamesPlayed:SetText(PVP_GAMES_PLAYED..weeklyPlayed);
	
	tooltip.SeasonBest:SetText(PVP_BEST_RATING..seasonBest);
	tooltip.SeasonGamesPlayed:SetText(PVP_GAMES_PLAYED..seasonPlayed);

	tooltip.ProjectedCap:SetText(cap);
	
	local maxWidth = max(tooltip.WeeklyBest:GetStringWidth(), tooltip.WeeklyGamesPlayed:GetStringWidth(),
						tooltip.SeasonBest:GetStringWidth(), tooltip.SeasonGamesPlayed:GetStringWidth(),
						tooltip.ProjectedCapLabel:GetStringWidth());
	
	tooltip:SetWidth(maxWidth + CONQUEST_TOOLTIP_PADDING);
	tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0);
	tooltip:Show();
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
			local name, pvpType, collapsed, id, minPlayers, maxPlayers, isRandom, iconTexture = GetWarGameTypeInfo(index);
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
	PlaySound("igMainMenuOptionCheckBoxOn");
	local name = GetWarGameTypeInfo(GetSelectedWarGameType());
	if ( name ) then
		StartWarGame("target", name);
	end
end

