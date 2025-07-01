MAX_ARENA_TEAM_MEMBERS = 10;

HORDE_TEX_COORDS = {left=0.00195313, right=0.63867188, top=0.31738281, bottom=0.44238281}
ALLIANCE_TEX_COORDS = {left=0.00195313, right=0.63867188, top=0.19042969, bottom=0.31542969}

WARGAME_HEADER_HEIGHT = 16;
BATTLEGROUND_BUTTON_HEIGHT = 40;

local MAX_SHOWN_BATTLEGROUNDS = 8;
local NO_ARENA_SEASON = 0;

local DEFAULT_BG_TEXTURE = "Interface\\PVPFrame\\RandomPVPIcon";

StaticPopupDialogs["CONFIRM_JOIN_SOLO"] = {
	text = CONFIRM_JOIN_SOLO,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		HonorQueueFrame_Queue(false, true);
	end,
	OnShow = function(self)
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
}

---------------------------------------------------------------
-- PVP FRAME  (Unlike reference, this is now a tab of the GroupFinderFrame)
---------------------------------------------------------------

local pvpFrames = { "HonorQueueFrame", "ConquestQueueFrame", "WarGamesQueueFrame" }

function PVPQueueFrame_OnLoad(self)
	local englishFaction = UnitFactionGroup("player");
	local currencyInfo;

	SetPortraitToTexture(self.CategoryButton1.Icon, "Interface\\Icons\\achievement_bg_winwsg");
	self.CategoryButton1.Name:SetText(PVP_TAB_HONOR);
	currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID);
	self.CategoryButton1.CurrencyAmount:SetText(currencyInfo.quantity);
	self.CategoryButton1.CurrencyIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor-"..englishFaction);

	SetPortraitToTexture(self.CategoryButton2.Icon, "Interface\\Icons\\achievement_bg_killxenemies_generalsroom");
	self.CategoryButton2.Name:SetText(PVP_TAB_CONQUEST);
	self.CategoryButton2.CurrencyIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..englishFaction);
	currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID);
	self.CategoryButton2.CurrencyAmount:SetText(currencyInfo.quantity);

	SetPortraitToTexture(self.CategoryButton3.Icon, "Interface\\Icons\\ability_warrior_offensivestance");
	self.CategoryButton3.Name:SetText(WARGAMES);

	if (UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0]) then
		HonorQueueFrame.BonusFrame.BattlegroundTexture:SetTexCoord(HORDE_TEX_COORDS.left, HORDE_TEX_COORDS.right,
															HORDE_TEX_COORDS.top, HORDE_TEX_COORDS.bottom)
	else
		HonorQueueFrame.BonusFrame.BattlegroundTexture:SetTexCoord(ALLIANCE_TEX_COORDS.left, ALLIANCE_TEX_COORDS.right,
															ALLIANCE_TEX_COORDS.top, ALLIANCE_TEX_COORDS.bottom)
	end

	RequestRandomBattlegroundInstanceInfo();

	PVPQueueFrame_UpdateSelectedRoles();

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
	self:RegisterEvent("BATTLEFIELDS_SHOW");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PVP_ROLE_UPDATE");
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
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED") then
		PVP_UpdateStatus();
	elseif ( event == "PVP_RATED_STATS_UPDATE" ) then
		PVPQueueFrame_UpdateCurrencies(self);
	elseif ( event == "BATTLEFIELDS_SHOW" ) then
		local isArena, bgID = ...;
		if (isArena) then
			PVPQueueFrame_ShowFrame(ConquestQueueFrame);
			ShowUIPanel(PVPUIFrame);
		else
			PVPQueueFrame_ShowFrame(HonorQueueFrame);
			ShowUIPanel(PVPUIFrame);
			HonorQueueFrame_SetType("specific");
			HonorQueueFrameSpecificList_FindAndSelectBattleground(bgID);
		end
	elseif ( event == "VARIABLES_LOADED" or event == "PVP_ROLE_UPDATE" ) then
		HonorQueueFrameBonusFrame_UpdateExcludedBattlegrounds();
		PVPQueueFrame_UpdateSelectedRoles();
	end

	PVPQueueFrame_UpdateRolesChangeable();
end

function PVPQueueFrame_OnShow(self)
	if(SetPortraitAtlasRaw) then
		PVEFrame:SetPortraitAtlasRaw("groupfinder-eye-frame");
	else
		PVEFramePortrait:SetAtlas("groupfinder-eye-frame");
	end
	PVPQueueFrame_UpdateTitle();
end

function PVPQueueFrame_UpdateTitle()
	local currentArenaSeason = GetCurrentArenaSeason();
	if currentArenaSeason ~= NO_ARENA_SEASON then
		PVEFrame:SetTitleFormatted(PLAYER_V_PLAYER_SEASON, currentArenaSeason);
	else
		PVEFrame:SetTitle(PLAYER_V_PLAYER_OFF_SEASON);
	end
end

function PVPQueueFrame_RoleButtonClicked(self)
	PVPQueueFrame_SetRoles();
end

function PVPQueueFrame_SetRoles()
	SetPVPRoles(HonorQueueFrame.RoleInset.TankIcon.checkButton:GetChecked(),
		HonorQueueFrame.RoleInset.HealerIcon.checkButton:GetChecked(),
		HonorQueueFrame.RoleInset.DPSIcon.checkButton:GetChecked());
end

function PVPQueueFrame_UpdateRolesChangeable()
	if ( PVPQueueFrame_CanChangeRoles() ) then
		PVPQueueFrame_UpdateAvailableRoles(HonorQueueFrame.RoleInset.TankIcon, HonorQueueFrame.RoleInset.HealerIcon, HonorQueueFrame.RoleInset.DPSIcon);
	else
		LFG_DisableRoleButton(HonorQueueFrame.RoleInset.TankIcon);
		LFG_DisableRoleButton(HonorQueueFrame.RoleInset.HealerIcon);
		LFG_DisableRoleButton(HonorQueueFrame.RoleInset.DPSIcon);
	end
end

function PVPQueueFrame_CanChangeRoles()
	-- For now we don't have any restrictions
	return true;
end

function PVPQueueFrame_UpdateAvailableRoles(tankButton, healButton, dpsButton)
	return LFG_UpdateAvailableRoles(tankButton, healButton, dpsButton);
end

function PVPQueueFrame_UpdateSelectedRoles()
	local tank, healer, dps = GetPVPRoles();
	HonorQueueFrame.RoleInset.TankIcon.checkButton:SetChecked(tank);
	HonorQueueFrame.RoleInset.HealerIcon.checkButton:SetChecked(healer);
	HonorQueueFrame.RoleInset.DPSIcon.checkButton:SetChecked(dps);
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
	ConquestQueueFrame_UpdateConquestBar(ConquestQueueFrame)

	local honorCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID);
	local arenaCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID);

	self.CategoryButton1.CurrencyAmount:SetText(honorCurrencyInfo.quantity);
	self.CategoryButton2.CurrencyAmount:SetText(arenaCurrencyInfo.quantity);
end

function PVPQueueFrame_ShowFrame(frame)
	frame = frame or PVPQueueFrame.selection or HonorQueueFrame;
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
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	PVPQueueFrame_ShowFrame(_G[frameName]);
end

---------------------------------------------------------------
-- HONOR FRAME
---------------------------------------------------------------

local LocklistIDs = { };
local MIN_BONUS_HONOR_LEVEL;

function HonorQueueFrame_OnLoad(self)
	self.SpecificFrame.scrollBar.doNotHide = true;
	self.SpecificFrame.update = HonorQueueFrameSpecificList_Update;
	HybridScrollFrame_CreateButtons(self.SpecificFrame, "PVPSpecificBattlegroundButtonTemplate", -2, -1);

	-- min level for bonus frame
	MIN_BONUS_HONOR_LEVEL = (C_PvP.GetRandomBGInfo()).minLevel;

	UIDropDownMenu_SetWidth(HonorQueueFrameTypeDropDown, 160);
	UIDropDownMenu_Initialize(HonorQueueFrameTypeDropDown, HonorQueueFrameTypeDropDown_Initialize);

	if ( UnitLevel("player") < MIN_BONUS_HONOR_LEVEL ) then
		HonorQueueFrame_SetType("specific");
	else
		HonorQueueFrame_SetType("bonus");
	end

	for i = 1, Constants.PvpInfoConsts.MAX_PVP_LOCK_LIST_MAP do
		local mapID = C_PvP.GetLocklistMap(i);
		if ( mapID > 0 ) then
			LocklistIDs[mapID] = true;
		end
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW");
	self:RegisterEvent("PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
end

function HonorQueueFrame_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		HonorQueueFrameSpecificList_Update();
		HonorQueueFrameBonusFrame_Update();
		PVP_UpdateStatus();
	elseif ( event == "PVPQUEUE_ANYWHERE_SHOW" or event ==  "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE"
			or event == "PVP_RATED_STATS_UPDATE") then
		HonorQueueFrameSpecificList_Update();
		HonorQueueFrameBonusFrame_Update();
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		HonorQueueFrame_UpdateQueueButtons();
	end
end

function HonorQueueFrameTypeDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = BONUS_BATTLEGROUNDS;
	info.value = "bonus";
	info.func = HonorQueueFrameTypeDropDown_OnClick;
	info.checked = HonorQueueFrame.type == info.value;
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
	info.func = HonorQueueFrameTypeDropDown_OnClick;
	info.checked = HonorQueueFrame.type == info.value;
	info.disabled = nil;
	UIDropDownMenu_AddButton(info);
end

function HonorQueueFrameTypeDropDown_OnClick(self)
	HonorQueueFrame_SetType(self.value);
end

function HonorQueueFrame_SetType(value)
	HonorQueueFrame.type = value;
	UIDropDownMenu_SetSelectedValue(HonorQueueFrameTypeDropDown, value);

	if ( value == "specific" ) then
		HonorQueueFrame.SpecificFrame:Show();
		HonorQueueFrame.BonusFrame:Hide();
	elseif ( value == "bonus" ) then
		HonorQueueFrame.SpecificFrame:Hide();
		HonorQueueFrame.BonusFrame:Show();
	end
end

function HonorQueueFrame_UpdateQueueButtons()
	local HonorQueueFrame = HonorQueueFrame;
	local canQueue;
	local isWorldPVP;
	if ( HonorQueueFrame.type == "specific" ) then
		if ( HonorQueueFrame.SpecificFrame.selectionID ) then
			canQueue = true;
		end
	elseif ( HonorQueueFrame.type == "bonus" ) then
		if ( HonorQueueFrame.BonusFrame.selectedButton ) then
			if ( HonorQueueFrame.BonusFrame.selectedButton.canQueue ) then
				canQueue = true;
			end
			isWorldPVP = HonorQueueFrame.BonusFrame.selectedButton.worldID;
		end
	end

	if ( canQueue ) then
		HonorQueueFrame.SoloQueueButton:Enable();
		if ( not isWorldPVP and IsInGroup() and UnitIsGroupLeader("player") ) then
			HonorQueueFrame.GroupQueueButton:Enable();
		else
			HonorQueueFrame.GroupQueueButton:Disable();
		end
	else
		HonorQueueFrame.SoloQueueButton:Disable();
		HonorQueueFrame.GroupQueueButton:Disable();
	end
end

function HonorQueueFrame_Queue(isParty, forceSolo)
	if (not isParty and not forceSolo and GetNumGroupMembers() > 1) then
		StaticPopup_Show("CONFIRM_JOIN_SOLO");
		return;
	end
	local HonorQueueFrame = HonorQueueFrame;
	if ( HonorQueueFrame.type == "specific" and HonorQueueFrame.SpecificFrame.selectionID ) then
		JoinBattlefield(HonorQueueFrame.SpecificFrame.selectionID, isParty);
	elseif ( HonorQueueFrame.type == "bonus" and HonorQueueFrame.BonusFrame.selectedButton ) then
		if ( HonorQueueFrame.BonusFrame.selectedButton.worldID ) then
			JoinWorldPVPQueue(false, isParty, HonorQueueFrame.BonusFrame.selectedButton.bgID);
		else
			JoinBattlefield(HonorQueueFrame.BonusFrame.selectedButton.bgID, isParty);
		end
	end
end

-------- Specific BG Frame --------

function HonorQueueFrameSpecificList_Update()
	local scrollFrame = HonorQueueFrame.SpecificFrame;
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
				button.selectionID = i;
			end
		end
	end
	buttonCount = max(buttonCount, 0);	-- safety check
	for i = buttonCount + 1, numButtons do
		buttons[i]:Hide();
	end

	local totalHeight = (buttonCount + offset) * BATTLEGROUND_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, numButtons * scrollFrame.buttonHeight);

	HonorQueueFrame_UpdateQueueButtons();
end

function HonorQueueFrameSpecificList_FindAndSelectBattleground(bgID)
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

	HonorQueueFrame.SpecificFrame.selectionID = bgButtonIndex;
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
		HonorQueueFrame.SpecificFrame.scrollBar:SetValue(offset);
	end

	HonorQueueFrameSpecificList_Update();
end

function HonorQueueFrameSpecificBattlegroundButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	HonorQueueFrame.SpecificFrame.selectionID = self.selectionID;
	HonorQueueFrameSpecificList_ResetInfo();
	HonorQueueFrameSpecificList_Update();
end

function HonorQueueFrameSpecificList_ResetInfo()
	if HonorQueueFrame.SpecificFrame.selectionID then
		RequestBattlegroundInstanceInfo(HonorQueueFrame.SpecificFrame.selectionID);
	end
	PVPHonor_UpdateInfo();
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

	for i = 1, Constants.PvpInfoConsts.MAX_PVP_LOCK_LIST_MAP do
		local text = _G["EXCLUDE_BATTLEGROUNDS_LINE_"..i];
		if ( not text or text == "" ) then
			break;
		end
		-- only 1 line is going to have a "%d" but which line it is might differ by language
		info.text = RED_FONT_COLOR_CODE..string.format(text, Constants.PvpInfoConsts.MAX_PVP_LOCK_LIST_MAP);
		info.isTitle = nil;
		info.disabled = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end
	info.notCheckable = nil;

	local numBattlegrounds = GetNumBattlegroundTypes();
	local locklistBGCount = 0;
	for _ in pairs(LocklistIDs) do
		locklistBGCount = locklistBGCount + 1;
	end

	for i = 1, numBattlegrounds do
		local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers = GetBattlegroundInfo(i);
		if ( localizedName and canEnter and not isRandom ) then
			info.text = localizedName;
			info.isNotRadio = 1;
			info.keepShownOnClick = 1;
			info.func = IncludedBattlegroundsDropDown_OnClick;
			info.value = BGMapID;
			if ( LocklistIDs[BGMapID] ) then
				info.checked = nil;
				info.colorCode = RED_FONT_COLOR_CODE;
				info.disabled = nil;
			else
				info.checked = 1;
				info.colorCode = nil;
				if ( locklistBGCount == Constants.PvpInfoConsts.MAX_PVP_LOCK_LIST_MAP ) then
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
	if ( LocklistIDs[mapID] ) then
		C_PvP.ClearLocklistMap(mapID);
		LocklistIDs[mapID] = nil;
	else
		LocklistIDs[mapID] = true;
		C_PvP.SetLocklistMap(mapID);
	end
	HonorQueueFrameBonusFrame_UpdateExcludedBattlegrounds();
	-- ugh, need to rerun IncludedBattlegroundsDropDown_Initialize so close and reopen
	IncludedBattlegroundsDropDown_Toggle();
	IncludedBattlegroundsDropDown_Toggle();
end

function IncludedBattlegroundsDropDown_Toggle()
	ToggleDropDownMenu(1, nil, IncludedBattlegroundsDropDown);
end

-------- Bonus BG Frame --------

function HonorQueueFrameBonusFrame_OnShow(self)
	self.updateTime = 0;
	HonorQueueFrameBonusFrame_Update();
	RequestRandomBattlegroundInstanceInfo();
end

function HonorQueueFrameBonusFrame_OnUpdate(self, elapsed)
	local button = nil;
	self.updateTime = self.updateTime + elapsed;
	if ( self.updateTime >= 1 ) then
		local i = 1;
		for index = 1, GetNumBattlegroundTypes() do
			local _, _, _, _, battleGroundID, _, _, _, _, _, _, _, hasControllingHoliday = GetBattlegroundInfo(index);
			if battleGroundID ~= nil and hasControllingHoliday > 0 then
				button = HonorQueueFrame.BonusFrame["WorldPVP"..i.."Button"];
				local worldPvpInfo = C_PvP.GetWorldPVPAreaInfo(index);
				if ( worldPvpInfo.canEnter ) then
					HonorQueueFrameBonusFrame_UpdateWorldPVPTime(button, worldPvpInfo.isActive, worldPvpInfo.startTime);
					button.canQueue = worldPvpInfo.canQueue;
				end
				i = i + 1;
			end
		end
		self.updateTime = 0;
	end
end

function HonorQueueFrameBonusFrame_Update()
	local playerLevel = UnitLevel("player");
	local englishFaction = UnitFactionGroup("player");
	local selectButton = nil;

	-- random bg
	local button = HonorQueueFrame.BonusFrame.RandomBGButton;
	local randomBGInfo = C_PvP.GetRandomBGInfo();
	HonorQueueFrameBonusFrame_SetButtonState(button, randomBGInfo.canQueue, randomBGInfo.minLevel);
	if ( randomBGInfo.canQueue ) then
		HonorQueueFrame.BonusFrame.DiceButton:Show();
		if ( not selectButton ) then
			selectButton = button;
		end
	else
		HonorQueueFrame.BonusFrame.DiceButton:Hide();
	end
	HonorQueueFrameBonusFrame_UpdateExcludedBattlegrounds();
	button.canQueue = randomBGInfo.canQueue;
	button.bgID = randomBGInfo.bgID;
	button.selectionID = randomBGInfo.bgIndex;

	-- call to arms
	button = HonorQueueFrame.BonusFrame.CallToArmsButton;
	local holidayBGInfo = C_PvP.GetHolidayBGInfo();
	if ( holidayBGInfo.bgID ) then
		HonorQueueFrameBonusFrame_SetButtonState(button, holidayBGInfo.canQueue, holidayBGInfo.minLevel);
		button.Contents.BattlegroundName:SetText(holidayBGInfo.name);
		if ( holidayBGInfo.canQueue ) then
			button.Contents.BattlegroundName:SetTextColor(0.7, 0.7, 0.7);
			if ( not selectButton ) then
				selectButton = button;
			end
		else
			button.Contents.BattlegroundName:SetTextColor(0.4, 0.4, 0.4);
		end
		button.canQueue = holidayBGInfo.canQueue;
		button.bgID = holidayBGInfo.bgID;
		button.selectionID = holidayBGInfo.bgIndex;
	else
		HonorQueueFrameBonusFrame_SetButtonState(button, false, nil);
		button.Contents.BattlegroundName:SetText("");
		button.canQueue = false;
		button.bgID = nil;
		button.selectionID = nil;
	end

	-- world pvp
	local i = 1;
	for index = 1, GetNumBattlegroundTypes() do
		local _, _, _, _, battleGroundID, _, _, _, _, _, _, _, hasControllingHoliday = GetBattlegroundInfo(index);
		if battleGroundID ~= nil and hasControllingHoliday > 0 then
			button = HonorQueueFrame.BonusFrame["WorldPVP"..i.."Button"];
			local worldPvpInfo = C_PvP.GetWorldPVPAreaInfo(index);
			button.Contents.Title:SetText(worldPvpInfo.name);
			HonorQueueFrameBonusFrame_SetButtonState(button, worldPvpInfo.canEnter, worldPvpInfo.minLevel);
			if ( worldPvpInfo.canEnter ) then
				HonorQueueFrameBonusFrame_UpdateWorldPVPTime(button, worldPvpInfo.isActive, worldPvpInfo.startTime);
				if ( not selectButton ) then
					selectButton = button;
				end
			else
				button.Contents.InProgressText:Hide();
				button.Contents.NextBattleText:Hide();
				button.Contents.TimeText:Hide();
			end
			button.canQueue = worldPvpInfo.canQueue and worldPvpInfo.isActive;
			button.bgID = battleGroundID;
			button.worldID = i;

			i = i + 1;
		end
	end

	-- select a button if one isn't selected
	if ( not HonorQueueFrame.BonusFrame.selectedButton and selectButton ) then
		HonorQueueFrameBonusFrame_SelectButton(selectButton);
	else
		HonorQueueFrame_UpdateQueueButtons();
	end
end

function HonorQueueFrameBonusFrame_UpdateExcludedBattlegrounds()
	local bgNames = nil;
	for i = 1, Constants.PvpInfoConsts.MAX_PVP_LOCK_LIST_MAP do
		local mapName = C_PvP.GetLocklistMapName(i);
		if ( mapName ) then
			if ( bgNames ) then
				bgNames = bgNames..EXCLUDED_BATTLEGROUNDS_SEPARATOR..mapName;
			else
				bgNames = mapName;
			end
		end
	end
	if ( bgNames ) then
		HonorQueueFrame.BonusFrame.RandomBGButton.Contents.ThumbTexture:Show();
		HonorQueueFrame.BonusFrame.RandomBGButton.Contents.ExcludedBattlegrounds:SetText(bgNames);
	else
		HonorQueueFrame.BonusFrame.RandomBGButton.Contents.ThumbTexture:Hide();
		HonorQueueFrame.BonusFrame.RandomBGButton.Contents.ExcludedBattlegrounds:SetText("");
	end
end

function HonorQueueFrameBonusFrame_SelectButton(button)
	if ( HonorQueueFrame.BonusFrame.selectedButton ) then
		HonorQueueFrame.BonusFrame.selectedButton.SelectedTexture:Hide();
	end
	button.SelectedTexture:Show();
	HonorQueueFrame.BonusFrame.selectedButton = button;
	if button.selectionID then
		RequestBattlegroundInstanceInfo(button.selectionID);
	end
	HonorQueueFrame_UpdateQueueButtons();
end

function HonorQueueFrameBonusFrame_SetButtonState(button, enable, minLevel)
	if ( enable ) then
		button.Contents.Title:SetTextColor(1, 1, 1);
		button.NormalTexture:SetAlpha(1);
		button:Enable();
		button.Contents.UnlockText:Hide();
		button.Contents.MinLevelText:Hide();
	else
		if ( button == HonorQueueFrame.BonusFrame.selectedButton ) then
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

function HonorQueueFrameBonusFrame_UpdateWorldPVPTime(button, isActive, startTime)
	if ( isActive ) then
		button.Contents.InProgressText:Show();
		button.Contents.NextBattleText:Hide();
		button.Contents.TimeText:Hide();
	else
		button.Contents.InProgressText:Hide();
		button.Contents.NextBattleText:Show();
		button.Contents.TimeText:Show();
		button.Contents.TimeText:SetText(MinutesToTime(startTime));
	end
end

---------------------------------------------------------------
-- CONQUEST FRAME
---------------------------------------------------------------

CONQUEST_SIZE_STRINGS = { ARENA_2V2, ARENA_3V3, ARENA_5V5, BATTLEGROUND_10V10 };
CONQUEST_SIZES = {2, 3, 5, 10};
CONQUEST_BUTTONS = {};
local RATED_BG_ID = 4;

function ConquestQueueFrame_OnLoad(self)

	CONQUEST_BUTTONS = {ConquestQueueFrame.Arena2v2, ConquestQueueFrame.Arena3v3, ConquestQueueFrame.Arena5v5, ConquestQueueFrame.RatedBG};

	local factionGroup = UnitFactionGroup("player");

	RequestRatedInfo();
	RequestPVPOptionsEnabled();
	
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
end

function ConquestQueueFrame_OnEvent(self, event, ...)
	ConquestQueueFrame_Update(self);
end

function ConquestQueueFrame_OnShow(self)
	RequestRatedInfo();
	RequestPVPOptionsEnabled();
	ConquestQueueFrame_Update(self);
end

function ConquestQueueFrame_Update(self)
	if ( GetCurrentArenaSeason() == NO_ARENA_SEASON ) then
		ConquestQueueFrame.NoSeason:Show();
	else
		ConquestQueueFrame.NoSeason:Hide();
		ConquestQueueFrame_UpdateConquestBar(self);
		
		for i = 1, RATED_BG_ID do
			local button = CONQUEST_BUTTONS[i];
			local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon = GetPersonalRatedInfo(i);
			button.Wins:SetText(seasonWon);
			button.BestRating:SetText(weeklyBest);
			button.CurrentRating:SetText(rating);
		end
		
		if ( not ConquestQueueFrame.selectedButton ) then
			-- if nothing's selected select rated BG cuz why the heck not
			ConquestQueueFrame_SelectButton(ConquestQueueFrame.RatedBG);
		else
			ConquestQueueFrame_UpdateJoinButton();
		end
	end
end

function ConquestQueueFrame_UpdateConquestBar(self)
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

	CapProgressBar_Update(self.ConquestBar, tier1Quantity, tier1Limit, tier2Quantity, tier2Limit, pointsThisWeek, maxPointsThisWeek, false);
	PVPFrameConquestBar.label:SetText(conquestCurrencyInfo.name);
end

function ConquestQueueFrame_UpdateJoinButton()
	local button = ConquestQueueFrame.JoinButton;
	local groupSize = GetNumGroupMembers();
	if ( ConquestQueueFrame.selectedButton ) then
		if ( groupSize == 0 ) then
			button.tooltip = PVP_NO_QUEUE_GROUP;
		elseif ( not UnitIsGroupLeader("player") ) then
			button.tooltip = PVP_NOT_LEADER;
		else
			local neededSize = CONQUEST_SIZES[ConquestQueueFrame.selectedButton.id];
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
				local teamIndex = ConquestQueueFrame.selectedButton.teamIndex;
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
				if ( ConquestQueueFrame.selectedButton.id == RATED_BG_ID ) then
					button.tooltip = string.format(PVP_RATEDBG_NEED_MORE, neededSize - groupSize);
				else
					button.tooltip = string.format(PVP_ARENA_NEED_MORE, neededSize - groupSize);
				end
			else
				if ( ConquestQueueFrame.selectedButton.id == RATED_BG_ID ) then
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

function ConquestQueueFrame_SelectButton(button)
	if ( ConquestQueueFrame.selectedButton ) then
		ConquestQueueFrame.selectedButton.SelectedTexture:Hide();
	end
	button.SelectedTexture:Show();
	ConquestQueueFrame.selectedButton = button;
	ConquestQueueFrame_UpdateJoinButton();
end

function ConquestQueueFrameButton_OnClick(self, button)
	CloseDropDownMenus();
	if ( button == "LeftButton" or self.teamIndex ) then
		ConquestQueueFrame_SelectButton(self);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function ConquestQueueFrameJoinButton_OnClick(self)
	if (ConquestQueueFrame.selectedButton.id == RATED_BG_ID) then
		JoinRatedBattlefield();
	else
		JoinArena();
	end
end

--------- Conquest Tooltips ----------

local CONQUEST_TOOLTIP_PADDING = 30 --counts both sides

function ConquestQueueFrameButton_OnEnter(self)
	local tooltip = ConquestTooltip;
	
	local rating, seasonBest, weeklyBest, seasonPlayed, _, weeklyPlayed, _, cap = GetPersonalRatedInfo(self.id);
	
	tooltip.WeeklyBest:SetText(PVP_BEST_RATING..weeklyBest);
	tooltip.WeeklyGamesPlayed:SetText(PVP_GAMES_PLAYED..weeklyPlayed);
	
	tooltip.SeasonBest:SetText(PVP_BEST_RATING..seasonBest);
	tooltip.SeasonGamesPlayed:SetText(PVP_GAMES_PLAYED..seasonPlayed);
	
	local maxWidth = max(tooltip.WeeklyBest:GetStringWidth(), tooltip.WeeklyGamesPlayed:GetStringWidth(),
						tooltip.SeasonBest:GetStringWidth(), tooltip.SeasonGamesPlayed:GetStringWidth());
	
	tooltip:SetWidth(maxWidth + CONQUEST_TOOLTIP_PADDING);
	tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0);
	tooltip:Show();
end

---------------------------------------------------------------
-- WAR GAMES FRAME
---------------------------------------------------------------

function WarGamesQueueFrame_OnLoad(self)
	self.scrollFrame.scrollBar.doNotHide = true;
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");		-- for leadership changes
	self.scrollFrame.update = WarGamesQueueFrame_Update;
	self.scrollFrame.dynamic =  WarGamesQueueFrame_GetTopButton;
	HybridScrollFrame_CreateButtons(self.scrollFrame, "PVPWarGameButtonTemplate", 0, -1);
end

function WarGamesQueueFrame_OnEvent(self, event, ...)
	if ( self:IsShown() ) then
		WarGameStartButton_Update();
	end
end

function WarGamesQueueFrame_OnShow(self)
	if ( not self.dataLevel or UnitLevel("player") > self.dataLevel ) then
		WarGamesQueueFrame.otherHeaderIndex = nil;
		self.dataLevel = UnitLevel("player");
		UpdateWarGamesList();
	end
	WarGamesQueueFrame_Update();
end

function WarGamesQueueFrame_GetTopButton(offset)
	local heightLeft = offset;
	local buttonHeight;
	local numWarGames = GetNumWarGameTypes();

	-- find the other header's position if needed (assuming collapsing and expanding headers are a rare occurence for a list this small)
	if ( not WarGamesQueueFrame.otherHeaderIndex ) then
		WarGamesQueueFrame.otherHeaderIndex = 0;
		for i = 2, numWarGames do
			local name = GetWarGameTypeInfo(i);
			if ( name == "header" ) then
				WarGamesQueueFrame.otherHeaderIndex = i;
				break;
			end
		end
	end
	-- determine top button
	local otherHeaderIndex = WarGamesQueueFrame.otherHeaderIndex;
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

function WarGamesQueueFrame_Update()
	local scrollFrame = WarGamesQueueFrame.scrollFrame;
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
	if ( WarGamesQueueFrame.otherHeaderIndex and WarGamesQueueFrame.otherHeaderIndex > 0 ) then
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
	WarGamesQueueFrame.otherHeaderIndex = nil;	-- header location probably changed;
	WarGamesQueueFrame_Update();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
	WarGamesQueueFrame_Update();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local name = GetWarGameTypeInfo(GetSelectedWarGameType());
	if ( name ) then
		StartWarGame("target", name);
	end
end


