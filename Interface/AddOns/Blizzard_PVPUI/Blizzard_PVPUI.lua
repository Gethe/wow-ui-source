
MAX_ARENA_TEAM_MEMBERS = 10;

BATTLEGROUND_BUTTON_HEIGHT = 40;

local MAX_SHOWN_BATTLEGROUNDS = 8;
local NO_ARENA_SEASON = 0;

local SEASON_STATE_OFFSEASON = 1;
local SEASON_STATE_PRESEASON = 2;
local SEASON_STATE_ACTIVE = 3;
local SEASON_STATE_DISABLED = 4;

local HORDE_PLAYER_FACTION_GROUP_NAME = PLAYER_FACTION_GROUP[PLAYER_FACTION_GROUP.Horde];
local ALLIANCE_PLAYER_FACTION_GROUP_NAME = PLAYER_FACTION_GROUP[PLAYER_FACTION_GROUP.Alliance];

---------------------------------------------------------------
-- PVP FRAME
---------------------------------------------------------------

local DEFAULT_BG_TEXTURE = "Interface\\PVPFrame\\RandomPVPIcon";

PVPCasualActivityButtonMixin = {};

function PVPCasualActivityButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	HonorFrameBonusFrame_SelectButton(self);
end

function PVPCasualActivityButtonMixin:OnEnter()
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

function PVPCasualActivityButtonMixin:OnMouseDown()
	if ( self:IsEnabled() ) then
		self.Anchor:SetPoint("TOPLEFT", -1, -1);
	end
end

function PVPCasualActivityButtonMixin:OnMouseUp()
	self.Anchor:SetPoint("TOPLEFT", 0, 0);
end

function PVPCasualActivityButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function PVPCasualActivityButtonMixin:OnShow()
	self.Title:SetPoint("RIGHT", self.Anchor, "RIGHT", -60, -1);
end

function PVPCasualActivityButtonMixin:OnHide()
	self.Title:SetPoint("RIGHT", self.Anchor, "RIGHT", -20, -1);
end

PVPSpecialEventButtonMixin = CreateFromMixins(PVPCasualActivityButtonMixin);

function PVPSpecialEventButtonMixin:OnEnter()
	PVPCasualActivityButtonMixin.OnEnter(self);
	self.NewAlert:ClearAlert();
end

function PVPSpecialEventButtonMixin:OnShow()
	PVPCasualActivityButtonMixin.OnShow(self);
	self.NewAlert:ValidateIsShown();
end

PVPSpecialEventLabelMixin = CreateFromMixins(NewFeatureLabelMixin);

function PVPSpecialEventLabelMixin:ClearAlert()
	NewFeatureLabelMixin.ClearAlert(self);
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PVP_SPECIAL_EVENT, true);
end

function PVPSpecialEventLabelMixin:ValidateIsShown()
	self:SetShown(not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PVP_SPECIAL_EVENT));
end

function PVPUIFrame_OnLoad(self)
	if (UnitFactionGroup("player") == HORDE_PLAYER_FACTION_GROUP_NAME) then
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
	if Kiosk.IsEnabled() then
		self:Hide();
		return;
	end
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	RequestPVPRewards();

	PVPUIFrame_UpdateSelectedRoles();
	PVPUIFrame_UpdateRolesChangeable();
	PVPUIFrame_EvaluateHelpTips(self);
end

function PVPUIFrame_OnHide(self)
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	ClearBattlemaster();
end

function PVPUIFrame_OnEvent(self, event, ...)
	if (event == "BATTLEFIELDS_CLOSED") then
		if (self:IsShown()) then
			self:GetParent():Hide();
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

function PVPUIFrame_EvaluateHelpTips(self)
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_LFG_LIST) and UnitLevel("player") >= 90 then
		local helpTipInfo = {
			text = LFG_LIST_TUTORIAL_ALERT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_LFG_LIST,
			targetPoint = HelpTip.Point.TopEdgeCenter,
		};
		HelpTip:Show(self, helpTipInfo, PVPQueueFrameCategoryButton3);
	end
end

function PVPUIFrame_RoleButtonClicked(self)
	PVPUIFrame_SetRoles(self:GetParent():GetParent());
end

function PVPUIFrame_SetRoles(frame)
	SetPVPRoles(frame.TankIcon.checkButton:GetChecked(),
		frame.HealerIcon.checkButton:GetChecked(),
		frame.DPSIcon.checkButton:GetChecked());
	LFG_UpdateAllRoleCheckboxes();
end

function PVPUIFrame_UpdateRolesChangeable()
	PVPUIFrame_UpdateAvailableRoles(HonorFrame.TankIcon, HonorFrame.HealerIcon, HonorFrame.DPSIcon);
	PVPUIFrame_UpdateRoleShortages(HonorFrame_GetSelectedModeRoleShortageBonus(), HonorFrame.RoleIcons);

	PVPUIFrame_UpdateAvailableRoles(ConquestFrame.TankIcon, ConquestFrame.HealerIcon, ConquestFrame.DPSIcon);
	PVPUIFrame_UpdateRoleShortages(ConquestFrame_GetSelectedModeRoleShortageBonus(), ConquestFrame.RoleIcons);

	EventRegistry:TriggerEvent("PVPUI.AvailablePVPRolesUpdated");
end

function PVPUIFrame_UpdateAvailableRoles(tankButton, healButton, dpsButton)
	return LFG_UpdateAvailableRoles(tankButton, healButton, dpsButton);
end

function PVPUIFrame_UpdateRoleShortages(roleShortageBonus, roleButtons)
	for index, roleButton in ipairs(roleButtons) do
		local roleHasShortage = (roleShortageBonus ~= nil) and tContains(roleShortageBonus.validRoles, roleButton.role);
		-- Always use the "rare" coin icon for PVP Call to Arms
		local incentiveIndex = roleHasShortage and LFG_ROLE_SHORTAGE_RARE or nil;
		LFG_SetRoleIconIncentive(roleButton, incentiveIndex);
		roleButton:EnableRoleShortagePulseAnim(roleButton:IsEnabled() and roleHasShortage);
	end
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

function PVPUIFrame_ConfigureRewardFrame(rewardFrame, honor, experience, itemRewards, currencyRewards, roleShortageBonus)
	local itemID, currencyID;
	local rewardTexture, rewardQuantity;
	rewardFrame.conquestAmount = 0;

	-- artifact-level currency trumps item
	if currencyRewards then
		for i, reward in ipairs(currencyRewards) do
			if(reward.id ~= Constants.CurrencyConsts.ECHOES_OF_NYALOTHA_CURRENCY_ID or #currencyRewards == 1) then
				local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reward.id);
				local name = currencyInfo.name;
				local texture = currencyInfo.iconFileID;
				local quality = currencyInfo.quality;
				if quality == Enum.ItemQuality.Artifact then
					local quantity;
					name, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.id, reward.quantity, name, texture, quality);
					currencyID = reward.id;
					rewardTexture = texture;
					rewardQuantity = reward.quantity;
				elseif reward.id == Constants.CurrencyConsts.CONQUEST_CURRENCY_ID then
					rewardFrame.conquestAmount = reward.quantity;
					rewardTexture = rewardTexture or texture;
				end
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

	if not rewardTexture then
		if honor and honor > 0 then
			local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(Constants.CurrencyConsts.HONOR_CURRENCY_ID, honor);
			if currencyInfo then
				rewardTexture = currencyInfo.icon;
			end
		elseif experience and experience > 0 then
			rewardTexture = "Interface\\Icons\\xp_icon"
		end
	end

	rewardFrame.RoleShortageBonus:Init(roleShortageBonus);
	rewardFrame:RefreshRoleShortageBonus();

	if rewardTexture then
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
	local disabledButtons = false;
	local canUse, failureReason = C_PvP.CanPlayerUseRatedPVPUI();
	if not canUse then
		disabledButtons = true;
		PVPQueueFrame_SetCategoryButtonState(self.CategoryButton2, false);
		self.CategoryButton2.tooltip = failureReason;
	end

	canUse, failureReason = C_LFGInfo.CanPlayerUsePremadeGroup();
	if not canUse then
		disabledButtons = true;
		PVPQueueFrame_SetCategoryButtonState(self.CategoryButton3, false);
		self.CategoryButton3.tooltip = failureReason;
	end

	if disabledButtons then
		PVPQueueFrame:SetScript("OnEvent", PVPQueueFrame_OnEvent);
		PVPQueueFrame:RegisterEvent("PLAYER_LEVEL_CHANGED");
	end

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
	if (event == "PLAYER_LEVEL_CHANGED") then
		local canUseRated = C_PvP.CanPlayerUseRatedPVPUI();
		local canUsePremade = C_LFGInfo.CanPlayerUsePremadeGroup();
		if canUseRated then
			PVPQueueFrame_SetCategoryButtonState(self.CategoryButton2, true);
			self.CategoryButton2.tooltip = nil;
		end
		if canUsePremade then
			self.CategoryButton3.tooltip = nil;
			PVPQueueFrame_SetCategoryButtonState(self.CategoryButton3, true);
		end
		if canUseRated and canUsePremade then
			self:UnregisterEvent("PLAYER_LEVEL_CHANGED");
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
	if (UnitFactionGroup("player") == HORDE_PLAYER_FACTION_GROUP_NAME) then
		PVEFrame:SetPortraitToAsset("Interface\\Icons\\INV_BannerPVP_01");
	else
		PVEFrame:SetPortraitToAsset("Interface\\Icons\\INV_BannerPVP_02");
	end

	PVPQueueFrame_SetPrestige(self);
	PVPQueueFrame_UpdateTitle();

	PVEFrame.TopTileStreaks:Show()
end

function PVPQueueFrame_UpdateTitle()
	if ConquestFrame.seasonState == SEASON_STATE_PRESEASON then
		PVEFrame:SetTitle(PLAYER_V_PLAYER_PRE_SEASON);
	elseif ConquestFrame.seasonState == SEASON_STATE_OFFSEASON then
		PVEFrame:SetTitle(PLAYER_V_PLAYER_OFF_SEASON);
	else
		PVEFrame:SetTitleFormatted(PLAYER_V_PLAYER_SEASON, PVPUtil.GetCurrentSeasonNumber());
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

function PVPQueueFrameButton_OnEnter(self)
	if ( self.tooltip ) then
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip_AddNormalLine(GameTooltip, self.tooltip);
		GameTooltip:Show();
	end
end

function PVPQueueFrameButton_OnLeave(self)
	if ( GameTooltip:GetOwner() == self ) then
		GameTooltip:Hide();
	end
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
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("PVPSpecificBattlegroundButtonTemplate", function(button, elementData)
		HonorFrame_InitSpecificButton(button, elementData);
	end);
	view:SetPadding(1,0,2,0,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.SpecificScrollBox, self.SpecificScrollBar, view);

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
		if ( self:IsShown() ) then
			RequestPVPRewards();
		end
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
		HonorFrame.SpecificScrollBox:Show();
		HonorFrame.SpecificScrollBar:Show();
		HonorFrame.BonusFrame:Hide();
	elseif ( value == "bonus" ) then
		HonorFrame.SpecificScrollBox:Hide();
		HonorFrame.SpecificScrollBar:Hide();
		HonorFrame.BonusFrame:Show();
	end

	PVPUIFrame_UpdateRoleShortages(HonorFrame_GetSelectedModeRoleShortageBonus(), HonorFrame.RoleIcons);
end

function HonorFrame_UpdateQueueButtons()
	local HonorFrame = HonorFrame;
	local canQueue;
	local arenaID;
	local isBrawl;
	if ( HonorFrame.type == "specific" ) then
		if ( HonorFrame.SpecificScrollBox.selectionID ) then
			canQueue = true;
		end
	elseif ( HonorFrame.type == "bonus" ) then
		if ( HonorFrame.BonusFrame.selectedButton ) then
			canQueue = HonorFrame.BonusFrame.selectedButton.canQueue;
			arenaID = HonorFrame.BonusFrame.selectedButton.arenaID;
			isBrawl = HonorFrame.BonusFrame.selectedButton.isBrawl;
			isSpecialBrawl = HonorFrame.BonusFrame.selectedButton.isSpecialBrawl;
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

	if (isBrawl or isSpecialBrawl) and not canQueue then
		if IsInGroup(LE_PARTY_CATEGORY_HOME) then
			local brawlInfo = isSpecialBrawl and C_PvP.GetSpecialEventBrawlInfo() or C_PvP.GetAvailableBrawlInfo();
			if brawlInfo then
				disabledReason = QUEUE_UNAVAILABLE_PARTY_MIN_LEVEL:format(isSpecialBrawl and brawlInfo.minLevel or GetMaxLevelForPlayerExpansion());
			end
		else
			disabledReason = INSTANCE_UNAVAILABLE_SELF_LEVEL_TOO_LOW;
		end
	end

	if isBrawl or isSpecialBrawl and canQueue then
		local brawlInfo = isSpecialBrawl and C_PvP.GetSpecialEventBrawlInfo() or C_PvP.GetAvailableBrawlInfo();
		local brawlHasMinItemLevelRequirement = brawlInfo and brawlInfo.brawlType == Enum.BrawlType.SoloRbg;
		if (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
			if(brawlInfo and not brawlInfo.groupsAllowed) then
				canQueue = false;
				disabledReason = SOLO_BRAWL_CANT_QUEUE;
			end
			if (brawlHasMinItemLevelRequirement and brawlInfo.groupsAllowed) then
				local brawlMinItemLevel = brawlInfo.minItemLevel;
				local partyMinItemLevel, playerWithLowestItemLevel = C_PartyInfo.GetMinItemLevel(Enum.AvgItemLevelCategories.PvP);
				if (UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) and partyMinItemLevel < brawlMinItemLevel) then
					canQueue = false;
					disabledReason = INSTANCE_UNAVAILABLE_OTHER_GEAR_TOO_LOW:format(playerWithLowestItemLevel, brawlMinItemLevel, partyMinItemLevel);
				end
			end
		end 
		local _, _, playerPvPItemLevel = GetAverageItemLevel();
		if (brawlHasMinItemLevelRequirement and playerPvPItemLevel < brawlInfo.minItemLevel) then
			canQueue = false;
			disabledReason = INSTANCE_UNAVAILABLE_SELF_PVP_GEAR_TOO_LOW:format("", brawlInfo.minItemLevel, playerPvPItemLevel);
		end
	end

	--Disable the button if the person is active in LFGList
	if not disabledReason then
		if ( select(2,C_LFGList.GetNumApplications()) > 0 ) then
			disabledReason = CANNOT_DO_THIS_WITH_LFGLIST_APP;
			canQueue = false;
		elseif ( C_LFGList.HasActiveEntryInfo() ) then
			disabledReason = CANNOT_DO_THIS_WHILE_LFGLIST_LISTED;
			canQueue = false;
		end
	end

	local isInCrossFactionGroup = C_PartyInfo.IsCrossFactionParty();
	if ( canQueue ) then
		HonorFrame.QueueButton:Enable();
		if ( IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
			HonorFrame.QueueButton:SetText(BATTLEFIELD_GROUP_JOIN);
			if (not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME)) then
				HonorFrame.QueueButton:Disable();
                disabledReason = ERR_NOT_LEADER; -- let this trump any other disabled reason
			elseif(isInCrossFactionGroup) then
				if isBrawl or isSpecialBrawl then 
					local brawlInfo = isSpecialBrawl and C_PvP.GetSpecialEventBrawlInfo() or C_PvP.GetAvailableBrawlInfo();
					local allowCrossFactionGroups = brawlInfo and brawlInfo.brawlType == Enum.BrawlType.SoloRbg;
					if (not allowCrossFactionGroups) then
						HonorFrame.QueueButton:Disable();
						disabledReason = CROSS_FACTION_PVP_ERROR;
					end
				end
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

	HonorFrame.QueueButton.tooltip = disabledReason;
end

function HonorFrame_GetSelectedModeRoleShortageBonus()
	local selectedButton = (HonorFrame.type == "bonus") and HonorFrame.BonusFrame.selectedButton;
	if selectedButton then
		return selectedButton.Reward.RoleShortageBonus.rewardInfo;
	end
end

function HonorFrame_Queue()
	local HonorFrame = HonorFrame;
	if ( HonorFrame.type == "specific" and HonorFrame.SpecificScrollBox.selectionID ) then
		JoinBattlefield(HonorFrame.SpecificScrollBox.selectionID);
	elseif ( HonorFrame.type == "bonus" and HonorFrame.BonusFrame.selectedButton ) then
		if ( HonorFrame.BonusFrame.selectedButton.arenaID ) then
			JoinSkirmish(HonorFrame.BonusFrame.selectedButton.arenaID);
		elseif (HonorFrame.BonusFrame.selectedButton.queueID) then
			ClearAllLFGDungeons(LE_LFG_CATEGORY_WORLDPVP);
			JoinSingleLFG(LE_LFG_CATEGORY_WORLDPVP, HonorFrame.BonusFrame.selectedButton.queueID);
		elseif (HonorFrame.BonusFrame.selectedButton.isBrawl) then
			C_PvP.JoinBrawl();
		elseif (HonorFrame.BonusFrame.selectedButton.isSpecialBrawl) then
			C_PvP.JoinBrawl(true);
		else
			JoinBattlefield(HonorFrame.BonusFrame.selectedButton.bgID);
		end
	end
end

-------- Specific BG Frame --------
function HonorFrame_InitSpecificButton(button, elementData)
	local localizedName = elementData.localizedName;
	local shortDescription = elementData.shortDescription;
	local longDescription = elementData.longDescription;
	local maxPlayers = elementData.maxPlayers;
	local gameType = elementData.gameType;
	local iconTexture = elementData.iconTexture;
	local battleGroundID = elementData.battleGroundID;

	button.NameText:SetText(localizedName);
	button.name = localizedName;
	button.shortDescription = shortDescription;
	button.longDescription = longDescription;
	button.SizeText:SetFormattedText(PVP_TEAMTYPE, maxPlayers, maxPlayers);
	button.InfoText:SetText(gameType);
	button.Icon:SetTexture(iconTexture or DEFAULT_BG_TEXTURE);
	if ( HonorFrame.SpecificScrollBox.selectionID == battleGroundID ) then
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

function HonorFrameSpecificList_Update()
	local dataProvider = CreateDataProvider();
	for index = 1, GetNumBattlegroundTypes() do
		local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers, gameType, iconTexture, shortDescription, longDescription = GetBattlegroundInfo(index);
		if localizedName and canEnter and not isRandom then
			dataProvider:Insert({
				localizedName=localizedName,
				battleGroundID=battleGroundID,
				maxPlayers=maxPlayers,
				gameType=gameType,
				iconTexture=iconTexture,
				shortDescription=shortDescription,
				longDescription=longDescription,
			});
		end
	end
	HonorFrame.SpecificScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	HonorFrame_UpdateQueueButtons();
end

function HonorFrameSpecificList_FindAndSelectBattleground(bgID)
	HonorFrame.SpecificScrollBox.selectionID = bgID;
	HonorFrame.SpecificScrollBox:ScrollToElementDataByPredicate(function(elementData)
		return elementData.battleGroundID == bgID;
	end);
	HonorFrameSpecificList_Update();
end

function HonorFrameSpecificBattlegroundButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	HonorFrame.SpecificScrollBox.selectionID = self.bgID;
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
	},
	SpecialEventBrawl = {
		func = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			local specialBrawl = true;
			GameTooltip:SetPvpBrawl(specialBrawl);
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

	QueueUpdater:RequestInfo();
	QueueUpdater:AddRef();
	self:RegisterEvent("PVP_BRAWL_INFO_UPDATED");
end

function HonorFrameBonusFrame_OnHide(self)
	QueueUpdater:RemoveRef();
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

	local buttons = {
		HonorFrame.BonusFrame.RandomBGButton,
		HonorFrame.BonusFrame.Arena1Button,
		HonorFrame.BonusFrame.RandomEpicBGButton,
		HonorFrame.BonusFrame.BrawlButton,
		HonorFrame.BonusFrame.BrawlButton2,
	};

	-- random bg
	do
		local button = buttons[1];
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
		local button = buttons[2];
		button.Title:SetText(SKIRMISH);

		PVPUIFrame_ConfigureRewardFrame(button.Reward, C_PvP.GetArenaSkirmishRewards());
	end

	-- epic battleground
	do
		local button = buttons[3];
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
		local button = buttons[4];
		local brawlInfo = C_PvP.GetAvailableBrawlInfo();
		local expansionMaxLevel = GetMaxLevelForPlayerExpansion();
		local meetsMaxLevel = PartyUtil.GetMinLevel() == expansionMaxLevel;
		button.canQueue = brawlInfo and brawlInfo.canQueue and meetsMaxLevel;
		HonorFrameBonusFrame_SetButtonState(button, button.canQueue, expansionMaxLevel);
		button.isBrawl = true;

		if (brawlInfo and brawlInfo.canQueue) then
			button.Title:SetText(brawlInfo.name);

			PVPUIFrame_ConfigureRewardFrame(button.Reward, C_PvP.GetBrawlRewards(brawlInfo.brawlType));
			button.Reward.EnlistmentBonus:SetShown(brawlEnlistmentActive);
		else
			local timeUntilNext = brawlInfo and brawlInfo.timeLeftUntilNextChange or 0;
			if (timeUntilNext == 0) then
				button.Title:SetText(BRAWL_CLOSED);
			else
				button.Title:SetText(BRAWL_CLOSED_NEW:format(SecondsToTime(timeUntilNext, false, false, 1)));
			end
			button.Reward:Hide();
		end
		HelpTip:Hide(button, BRAWL_TUTORIAL);
		if ShouldShowBrawlHelpBox(brawlInfo and brawlInfo.canQueue, (IsPlayerAtEffectiveMaxLevel())) then
			local helpTipInfo = {
				text = BRAWL_TUTORIAL,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_BRAWL,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				offsetX = -10,
			};
			HelpTip:Show(button, helpTipInfo);
		end
	end

	do
		local button = buttons[5];
		local brawlInfo = C_PvP.GetSpecialEventBrawlInfo();
		button.isSpecialBrawl = true;
		if (brawlInfo) then
			local meetsMinLevel = PartyUtil.GetMinLevel() >= brawlInfo.minLevel;
			button.canQueue = brawlInfo.canQueue and meetsMinLevel;
			HonorFrameBonusFrame_SetButtonState(button, button.canQueue, brawlInfo.minLevel);

			if (brawlInfo and brawlInfo.canQueue) then
				button.Title:SetText(brawlInfo.name);

				PVPUIFrame_ConfigureRewardFrame(button.Reward, C_PvP.GetBrawlRewards(brawlInfo.brawlType));
				button.Reward.EnlistmentBonus:SetShown(brawlEnlistmentActive);
			else
				button.Title:SetText(BRAWL_CLOSED);
				button.Reward:Hide();
			end
		end
		button:SetShown(brawlInfo);
	end

	local buttonContainerHeight = HonorFrame.BonusFrame:GetHeight();
	local buttonContainerMargin = 26;
	local buttonCount = #buttons;
	local buttonHeight = (buttonContainerHeight-buttonContainerMargin) / buttonCount;
	for i = 1, buttonCount do
		local button = buttons[i];
		button:SetHeight(buttonHeight);
		button.Anchor:SetHeight(buttonHeight);
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
	PVPUIFrame_UpdateRoleShortages(HonorFrame_GetSelectedModeRoleShortageBonus(), HonorFrame.RoleIcons);
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

		local tooLowLevel = minLevel and PartyUtil.GetMinLevel() < minLevel;
		if tooLowLevel then
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

CONQUEST_FRAME_EVENTS = {
	"GROUP_ROSTER_UPDATE",
	"LFG_LIST_ACTIVE_ENTRY_UPDATE",
	"LFG_LIST_SEARCH_RESULT_UPDATED",
	"PLAYER_SPECIALIZATION_CHANGED",
	"PVP_RATED_STATS_UPDATE",
	"PVP_REWARDS_UPDATE",
	"QUEST_LOG_UPDATE",
};

CONQUEST_BUTTONS = {};
local RATED_SOLO_SHUFFLE_BUTTON_ID = 1;
local RATED_BG_BUTTON_ID = 4;

function ConquestFrame_OnLoad(self)

	CONQUEST_BUTTONS = {ConquestFrame.RatedSoloShuffle, ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG};

	RequestRatedInfo();
	RequestPVPOptionsEnabled();

	self:RegisterEvent("PVP_TYPES_ENABLED");

	ConquestFrame_EvaluateSeasonState(self);
end

function ConquestFrame_OnEvent(self, event, ...)
	if ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" or event == "LFG_LIST_SEARCH_RESULT_UPDATED" ) then
		ConquestFrame_UpdateJoinButton(self);
	elseif (event == "PVP_TYPES_ENABLED") then
		local _, ratedBgs, ratedArenas, ratedSoloShuffle = ...;
		self.bgsEnabled = ratedBgs;
		self.arenasEnabled = ratedArenas;
		self.ratedSoloShuffleEnabled = ratedSoloShuffle;
		self.disabled = not ratedBgs and not ratedArenas and not ratedSoloShuffle;
		ConquestFrame_EvaluateSeasonState(self);
		ConquestFrame_UpdateSeasonFrames(self);
	elseif (event == "PLAYER_SPECIALIZATION_CHANGED") then
		RequestRatedInfo();
	else
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

function ConquestFrame_HasActiveSeason()
	return (ConquestFrame.seasonState == SEASON_STATE_ACTIVE) or (ConquestFrame.seasonState == SEASON_STATE_OFFSEASON);
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
	return ConquestFrame.bgsEnabled or ConquestFrame.arenasEnabled or ConquestFrame.ratedSoloShuffleEnabled;
end

function ConquestFrame_OnShow(self)
	FrameUtil.RegisterFrameForEvents(self, CONQUEST_FRAME_EVENTS);

	RequestRatedInfo();
	RequestPVPOptionsEnabled();
	ConquestFrame_Update(self);
	local lastSeasonNumber = tonumber(GetCVar("newPvpSeason"));
	local currentSeasonNumber = GetCurrentArenaSeason();
	if currentSeasonNumber >= SL_START_SEASON and lastSeasonNumber < currentSeasonNumber then
		PVPQueueFrame.NewSeasonPopup:Show();
	end
end

function ConquestFrame_OnHide(self)
	FrameUtil.UnregisterFrameForEvents(self, CONQUEST_FRAME_EVENTS);
end

function PVPRatedTier_OnEnter(self)
	local tierName = self.tierInfo and self.tierInfo.pvpTierEnum and PVPUtil.GetTierName(self.tierInfo.pvpTierEnum);
	if tierName then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, tierName);

		local activityItemLevel, weeklyItemLevel = C_PvP.GetRewardItemLevelsByTierEnum(self.tierInfo.pvpTierEnum);
		if weeklyItemLevel > 0 then
			GameTooltip_AddColoredLine(GameTooltip, PVP_GEAR_REWARD_BY_RANK:format(weeklyItemLevel), NORMAL_FONT_COLOR);
		end
		GameTooltip:Show();
	end
end

function NextTier_OnEnter(self)
	local tierName = self.tierInfo and self.tierInfo.pvpTierEnum and PVPUtil.GetTierName(self.tierInfo.pvpTierEnum);
	if tierName then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, TOOLTIP_PVP_NEXT_RANK:format(tierName));
		local tierDescription = PVPUtil.GetTierDescription(self.tierInfo.pvpTierEnum);
		if tierDescription then
			GameTooltip:SetMinimumWidth(260);
			GameTooltip_AddNormalLine(GameTooltip, tierDescription);
		end
		local activityItemLevel, weeklyItemLevel = C_PvP.GetRewardItemLevelsByTierEnum(self.tierInfo.pvpTierEnum);
		if activityItemLevel > 0 then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, PVP_GEAR_REWARD_BY_NEXT_RANK:format(weeklyItemLevel), NORMAL_FONT_COLOR);
		end
		GameTooltip:Show();
	end
end

function ConquestFrame_SetPanelTierInfo(tierFrame, tierInfo, ranking)
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

		local firstAvailableButton = self.ratedSoloShuffleEnabled and ConquestFrame.RatedSoloShuffle or self.arenasEnabled and ConquestFrame.Arena2v2 or ConquestFrame.RatedBG;

		for i = 1, RATED_BG_BUTTON_ID do
			local button = CONQUEST_BUTTONS[i];
			local bracketIndex = CONQUEST_BRACKET_INDEXES[i];
			local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking, roundsSeasonPlayed, roundsSeasonWon, roundsWeeklyPlayed, roundsWeeklyWon = GetPersonalRatedInfo(bracketIndex);
			local tierInfo = pvpTier and C_PvP.GetPvpTierInfo(pvpTier);
			if tierInfo then
				button.CurrentRating:SetText(rating);
				button.CurrentRating:Show();
				button.pvpTierEnum = tierInfo.pvpTierEnum;
			else
				button.CurrentRating:Hide();
			end
			button.Tier:Setup(tierInfo, ranking);
			if isOffseason then
				button.Tier:SetAlpha(0.25);
			else
				button.Tier:SetAlpha(1);
			end
			button.bracketIndex = bracketIndex;

			local enabled;

			if (i == RATED_BG_BUTTON_ID) then
				enabled = self.bgsEnabled;
				if enabled then
					PVPUIFrame_ConfigureRewardFrame(button.Reward, C_PvP.GetRatedBGRewards());
				end
			elseif (i == RATED_SOLO_SHUFFLE_BUTTON_ID) then
				enabled = self.ratedSoloShuffleEnabled;
				if enabled then
					PVPUIFrame_ConfigureRewardFrame(button.Reward, C_PvP.GetRatedSoloShuffleRewards());
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

	if not ConquestFrame_HasActiveSeason() then
		button:Disable();
		button.tooltip = nil;
		return;
	end

	--Disable the button if the person is active in LFGList
	local lfgListDisabled;
	if ( not ConquestFrame.selectedButton ) or ( ConquestFrame.selectedButton.id ~= RATED_SOLO_SHUFFLE_BUTTON_ID ) then
		if ( select(2,C_LFGList.GetNumApplications()) > 0 ) then
			lfgListDisabled = CANNOT_DO_THIS_WITH_LFGLIST_APP;
		elseif ( C_LFGList.HasActiveEntryInfo() ) then
			lfgListDisabled = CANNOT_DO_THIS_WHILE_LFGLIST_LISTED;
		end
	end

	if ( lfgListDisabled ) then
		button:Disable();
		button.tooltip = lfgListDisabled;
		return;
	end

	--Check whether they have a valid button selected
	if ( ConquestFrame.selectedButton ) then
		if ( ConquestFrame.selectedButton.id == RATED_SOLO_SHUFFLE_BUTTON_ID) then
			local minItemLevel = C_PvP.GetRatedSoloShuffleMinItemLevel();
			local _, _, playerPvPItemLevel = GetAverageItemLevel();
			if (playerPvPItemLevel < minItemLevel) then
				button.tooltip = format(_G["INSTANCE_UNAVAILABLE_SELF_PVP_GEAR_TOO_LOW"], "", minItemLevel, playerPvPItemLevel);
			else
				button.tooltip = nil;
				button:Enable();
				return;
			end
		elseif ( groupSize == 0 ) then
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
				-- Rated activities require a max level party/raid
				local maxLevel = GetMaxLevelForLatestExpansion();
				for i = 1, loopMax do
					if ( not UnitIsConnected(token..i) ) then
						validGroup = false;
						button.tooltip = PVP_NO_QUEUE_DISCONNECTED_GROUP;
						break;
					elseif ( UnitLevel(token..i) < maxLevel ) then
						validGroup = false;
						button.tooltip = PVP_NO_QUEUE_GROUP;
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
				if ( ConquestFrame.selectedButton.id == RATED_BG_BUTTON_ID ) then
					button.tooltip = string.format(PVP_RATEDBG_NEED_MORE, neededSize - groupSize);
				else
					button.tooltip = string.format(PVP_ARENA_NEED_MORE, neededSize - groupSize);
				end
			else
				if ( ConquestFrame.selectedButton.id == RATED_BG_BUTTON_ID ) then
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
	PVPUIFrame_UpdateRoleShortages(ConquestFrame_GetSelectedModeRoleShortageBonus(), ConquestFrame.RoleIcons);
	ConquestFrame_UpdateJoinButton();
end

function ConquestFrame_GetSelectedModeRoleShortageBonus()
	local selectedButton = ConquestFrame.selectedButton;
	if selectedButton then
		return selectedButton.Reward.RoleShortageBonus.rewardInfo;
	end
end

function ConquestFrameButton_OnClick(self, button)
	CloseDropDownMenus();
	if(IsModifiedClick("CHATLINK")) then
		local link = GetPvpRatingLink(UnitName("player"));
		if not ChatEdit_InsertLink(link) then
			ChatFrame_OpenChat(link);
		end
		return;
	end
	if ( button == "LeftButton" or self.teamIndex ) then
		ConquestFrame_SelectButton(self);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function ConquestFrameJoinButton_OnClick(self)
	if (ConquestFrame.selectedButton.id == RATED_SOLO_SHUFFLE_BUTTON_ID) then
		JoinRatedSoloShuffle();
	elseif (ConquestFrame.selectedButton.id == RATED_BG_BUTTON_ID) then
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

function ConquestFrameButton_OnEnter(self)
	local tooltip = ConquestTooltip;

	local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking, roundsSeasonPlayed, roundsSeasonWon, roundsWeeklyPlayed, roundsWeeklyWon = GetPersonalRatedInfo(self.bracketIndex);

	tooltip.Title:SetText(self.toolTipTitle);

	local isSoloShuffle = self.id == RATED_SOLO_SHUFFLE_BUTTON_ID;
	local tierInfo = pvpTier and C_PvP.GetPvpTierInfo(pvpTier);
	local tierName = tierInfo and tierInfo.pvpTierEnum and PVPUtil.GetTierName(tierInfo.pvpTierEnum);
	local hasSpecRank = tierName and ranking and isSoloShuffle;
	if tierName then
		if ranking and not hasSpecRank then
			tooltip.Tier:SetFormattedText(PVP_TIER_WITH_RANK_AND_RATING, tierName, ranking, rating);
		else
			tooltip.Tier:SetFormattedText(PVP_TIER_WITH_RATING, tierName, rating);
		end
	else
		tooltip.Tier:SetText("");
	end
	tooltip.SpecRank:SetText(hasSpecRank and PVP_SPECIALIZATION_RANK:format(PlayerUtil.GetSpecName(), ranking) or "");
	tooltip.SpecRank:SetShown(hasSpecRank);
	tooltip.WeeklyLabel:ClearAllPoints();
	tooltip.WeeklyLabel:SetPoint("TOPLEFT", hasSpecRank and tooltip.SpecRank or tooltip.Tier, "BOTTOMLEFT", 0, -13);

	tooltip.WeeklyBest:SetText(PVP_BEST_RATING..weeklyBest);
	tooltip.WeeklyWon:SetText(isSoloShuffle and (PVP_ROUNDS_WON .. roundsWeeklyWon) or (PVP_GAMES_WON .. weeklyWon));
	tooltip.WeeklyPlayed:SetText(isSoloShuffle and (PVP_ROUNDS_PLAYED .. roundsWeeklyPlayed) or (PVP_GAMES_PLAYED .. weeklyPlayed));

	tooltip.SeasonBest:SetText(PVP_BEST_RATING..seasonBest);
	tooltip.SeasonWon:SetText(isSoloShuffle and (PVP_ROUNDS_WON .. roundsSeasonWon) or (PVP_GAMES_WON .. seasonWon));
	tooltip.SeasonPlayed:SetText(isSoloShuffle and (PVP_ROUNDS_PLAYED .. roundsSeasonPlayed) or (PVP_GAMES_PLAYED .. seasonPlayed));

	local specStats = isSoloShuffle and C_PvP.GetPersonalRatedSoloShuffleSpecStats();
	if specStats then
		tooltip.WeeklyMostPlayedSpec:SetText(PVP_MOST_PLAYED_SPEC:format(PlayerUtil.GetSpecNameBySpecID(specStats.weeklyMostPlayedSpecID), specStats.weeklyMostPlayedSpecRounds));
		tooltip.SeasonMostPlayedSpec:SetText(PVP_MOST_PLAYED_SPEC:format(PlayerUtil.GetSpecNameBySpecID(specStats.seasonMostPlayedSpecID), specStats.seasonMostPlayedSpecRounds));
	end
	tooltip.WeeklyMostPlayedSpec:SetShown(specStats);
	tooltip.SeasonMostPlayedSpec:SetShown(specStats);
	tooltip.SeasonLabel:ClearAllPoints();
	tooltip.SeasonLabel:SetPoint("TOPLEFT", specStats and tooltip.WeeklyMostPlayedSpec or tooltip.WeeklyPlayed, "BOTTOMLEFT", 0, -13);

	-- We want the mode description to word wrap, set it to the width of the next longest string
	tooltip.ModeDescription:SetText("");
	local descriptionWidth = tooltip.minimumWidth;
	for i, fontString in ipairs(tooltip.Content) do
		descriptionWidth = math.max(descriptionWidth , fontString:GetStringWidth());
	end
	tooltip.ModeDescription:SetWidth(descriptionWidth);
	tooltip.ModeDescription:SetText(self.modeDescription or "");
	tooltip.ModeDescription:ClearAllPoints();
	tooltip.ModeDescription:SetPoint("TOPLEFT", specStats and tooltip.SeasonMostPlayedSpec or tooltip.SeasonPlayed, "BOTTOMLEFT", 0, -13);
	tooltip.ModeDescription:SetShown(self.modeDescription);

	tooltip:ClearAllPoints();
	local xOffset = 0;
	local yOffset = isSoloShuffle and -100 or 0;
	tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", xOffset, yOffset);
	tooltip:Layout();
	tooltip:Show();
end

---------------------------------------------------------------
-- Rewards
---------------------------------------------------------------

local function AddPVPRewardCurrency(tooltip, currencyID, amount)
	local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(currencyID, amount);
	if currencyInfo then
		local text = BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format(currencyInfo.icon, currencyInfo.displayAmount, currencyInfo.name);
		local currencyColor = GetColorForCurrencyReward(currencyID, currencyInfo.displayAmount);
		tooltip:AddLine(text, currencyColor:GetRGB());
	end
end

PVPStandardRewardMixin = CreateFromMixins(CallbackRegistryMixin);

function PVPStandardRewardMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:AddDynamicEventMethod(EventRegistry, "PVPUI.AvailablePVPRolesUpdated", self.OnAvailablePVPRolesUpdated);
end

function PVPStandardRewardMixin:OnEnter()
	if (not self.Icon:IsShown()) then
		return;
	end
	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
	EmbeddedItemTooltip:SetText(PVP_REWARD_TOOLTIP);
	self.UpdateTooltip = nil;

	if self.experience and self.experience > 0 then
		GameTooltip_AddColoredLine(EmbeddedItemTooltip, PVP_REWARD_XP_FORMAT:format(BreakUpLargeNumbers(self.experience)), HIGHLIGHT_FONT_COLOR);
	else
		AddPVPRewardCurrency(EmbeddedItemTooltip, Constants.CurrencyConsts.HONOR_CURRENCY_ID, self.honor);
	end
	if self.conquestAmount and self.conquestAmount > 0 then
		AddPVPRewardCurrency(EmbeddedItemTooltip, Constants.CurrencyConsts.CONQUEST_CURRENCY_ID, self.conquestAmount);
	end

	if self.itemID then
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
		EmbeddedItemTooltip_SetItemByID(EmbeddedItemTooltip.ItemTooltip, self.itemID, self.quantity);
	elseif self.currencyID and self.currencyID ~= CONQUEST_CURRENCY_ID then
		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
		EmbeddedItemTooltip_SetCurrencyByID(EmbeddedItemTooltip.ItemTooltip, self.currencyID, self.quantity);
	end
	EmbeddedItemTooltip:Show();
end

function PVPStandardRewardMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
	self.UpdateTooltip = nil;
end

function PVPStandardRewardMixin:OnAvailablePVPRolesUpdated()
	self:RefreshRoleShortageBonus();
end

function PVPStandardRewardMixin:RefreshRoleShortageBonus()
	if not self.RoleShortageBonus:HasRewardInfo() then
		self.RoleShortageBonus:Hide();
		return;
	end

	-- The Enlistment Bonus appears in the same location as the Role Shortage Bonus.
	-- They should never be active at the same time, but let's prioritize displaying the Enlistment Bonus just in case.
	local showingEnlistmentBonus = self.EnlistmentBonus:IsShown();
	if showingEnlistmentBonus then
		self.RoleShortageBonus:Hide();
		return;
	end

	local playerCanQueueForBonus = false;	
	local playerClassID = PlayerUtil.GetClassID();
	for specIndex = 1, GetNumSpecializationsForClassID(playerClassID) do
		local specID, specName, specDescription, specIcon, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(playerClassID, specIndex);
		if tContains(self.RoleShortageBonus.rewardInfo.validRoles, role) then
			playerCanQueueForBonus = true;
			break;
		end
	end

	self.RoleShortageBonus:SetShown(playerCanQueueForBonus);
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
	local xOffset = QueueStatusButton:GetLeft() - self:GetLeft();
	local yOffset = QueueStatusButton:GetTop() - self:GetTop() + 64;

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
	self.CasualPanel:Show();
	self.RatedPanel:Hide();
end

local function GetPVPSeasonAchievementID()
	local achievementID = C_PvP.GetPVPSeasonRewardAchievementID();
	if achievementID then
		while true do
			local completed = select(4, GetAchievementInfo(achievementID));
			if not completed then
				break;
			end

			local supercedingAchievements = C_AchievementInfo.GetSupercedingAchievements(achievementID);
			if not supercedingAchievements[1] then
				break;
			end

			achievementID = supercedingAchievements[1];
		end
	end

	return achievementID;
end

function PVPUIHonorInsetMixin:DisplayRatedPanel()
	self.RatedPanel:Show();
	self.CasualPanel:Hide();
end

PVPUIHonorLevelDisplayMixin = { };

function PVPUIHonorLevelDisplayMixin:OnLoad()
	self:Pause();
	if UnitFactionGroup("player") == HORDE_PLAYER_FACTION_GROUP_NAME then
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

function PVPUIHonorLevelDisplayMixin:OnMouseUp(button)
	if button == "RightButton" then
		UIDropDownMenu_Initialize(self.DropDown, InitializeHonorXPBarDropDown, "MENU");
		ToggleDropDownMenu(1, nil, self.DropDown, "cursor", 10, -10);
	end
end

function PVPUIHonorLevelDisplayMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, -20);
	GameTooltip_SetTitle(GameTooltip, LIFETIME_HONOR);
	GameTooltip_AddColoredLine(GameTooltip, LIFETIME_HONOR_DESC, NORMAL_FONT_COLOR);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	local currentHonor = UnitHonor("player");
	local maxHonor = UnitHonorMax("player");
	GameTooltip_AddColoredLine(GameTooltip, string.format(GENERIC_FRACTION_STRING_WITH_SPACING, currentHonor, maxHonor), HIGHLIGHT_FONT_COLOR);
	GameTooltip:Show();
end

PVPAchievementRewardMixin = {};

function PVPAchievementRewardMixin:Init(achievementID, headerString)
	self.achievementID = achievementID;
	self.headerString = headerString;
	self:Update();
end

function PVPAchievementRewardMixin:GetAchievementID()
	return self.achievementID;
end

function PVPAchievementRewardMixin:GetHeaderString()
	return self.headerString;
end

function PVPAchievementRewardMixin:OnShow()
	self:Update();
end

function PVPAchievementRewardMixin:OnMouseDown(mouseButton)
	if self.rewardItemID and IsModifiedClick("DRESSUP") then
		local itemID, _, _, _, texture = C_Item.GetItemInfoInstant(self.rewardItemID);
		local _, itemLink = C_Item.GetItemInfo(itemID);
		HandleModifiedItemClick(itemLink);
	end
end

function PVPAchievementRewardMixin:Update()
	local achievementID = self:GetAchievementID();
	local hasAchievementID = achievementID ~= nil;
	if hasAchievementID then
		self.rewardItemID = C_AchievementInfo.GetRewardItemID(achievementID);
		local texture = self.rewardItemID and select(5, C_Item.GetItemInfoInstant(self.rewardItemID)) or nil;
		self.Icon:SetTexture(texture);
		self.Icon:Show();
		local completed = false;
		if  GetAchievementNumCriteria(achievementID) > 0 then
			completed = select(3, GetAchievementCriteriaInfo(achievementID, 1));
		end
		if completed then
			self.Icon:SetDesaturated(false);
			if self.CheckMark then
				self.CheckMark:Show();
			end
		else
			self.Icon:SetDesaturated(true);
			if self.CheckMark then
				self.CheckMark:Hide();
			end
		end
	else
		self.Icon:Hide();
	end

	self:SetShown(hasAchievementID);
end

function PVPAchievementRewardMixin:UpdateTooltip()
	local achievementID = self:GetAchievementID();
	if not achievementID or GetAchievementNumCriteria(achievementID) == 0 then
		return;
	end

	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(EmbeddedItemTooltip, self:GetHeaderString());

	local criteriaString, criteriaType, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(achievementID, 1);
	if criteriaString then
		if completed then
			GameTooltip_AddColoredLine(EmbeddedItemTooltip, GOAL_COMPLETED, GREEN_FONT_COLOR);
		else
			local wordWrap = true;
			if self.useAchievementDescription then
				local description = select(8, GetAchievementInfo(achievementID));
				GameTooltip_AddNormalLine(EmbeddedItemTooltip, description, wordWrap);
			else
				GameTooltip_AddNormalLine(EmbeddedItemTooltip, criteriaString, wordWrap);
			end

			GameTooltip_ShowProgressBar(EmbeddedItemTooltip, 0, reqQuantity, quantity, FormatPercentage(quantity / reqQuantity));
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

function PVPAchievementRewardMixin:UpdateCursor()
	if self.rewardItemID and IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function PVPAchievementRewardMixin:OnEnter()
	self:SetScript("OnUpdate", self.UpdateCursor);

	self:UpdateTooltip();
	self:UpdateCursor();
end

function PVPAchievementRewardMixin:OnLeave()
	self:SetScript("OnUpdate", nil);

	EmbeddedItemTooltip:Hide();
	ResetCursor();
end

PVPConquestBarMixin = { };

function PVPConquestBarMixin:OnLoad()
	self.Reward:SetTooltipAnchor("ANCHOR_BOTTOMRIGHT");
end

function PVPConquestBarMixin:OnShow()
	self:RegisterEvent("WEEKLY_REWARDS_ITEM_CHANGED");
	self:RegisterEvent("WEEKLY_REWARDS_UPDATE");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:Update();
end

function PVPConquestBarMixin:OnHide()
	self:UnregisterEvent("WEEKLY_REWARDS_ITEM_CHANGED");
	self:UnregisterEvent("WEEKLY_REWARDS_UPDATE");
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
end

function PVPConquestBarMixin:OnEvent(event, ...)
	if event == "WEEKLY_REWARDS_ITEM_CHANGED" or event == "WEEKLY_REWARDS_UPDATE" or event == "CURRENCY_DISPLAY_UPDATE" then
		self:Update();
	end
end

function PVPConquestBarMixin:OnEnter()
	self.Reward:TryShowTooltip();
end

function PVPConquestBarMixin:OnLeave()
	self.Reward:HideTooltip();
end

function PVPConquestLockTooltipShow(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
	GameTooltip:SetText(string.format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, GetMaxLevelForLatestExpansion()));
	GameTooltip:Show();
end

function PVPConquestBarMixin:Update()
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID);
	local shouldShowConquestBar = currencyInfo and currencyInfo.maxQuantity > 0;
	self:SetShown(shouldShowConquestBar);

	self.locked = not IsPlayerAtEffectiveMaxLevel();
	self.Lock:SetShown(self.locked);

	local maxProgress = currencyInfo.maxQuantity;
	local progress = math.min(currencyInfo.totalEarned, maxProgress);

	local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress();
	local displayType = weeklyProgress.displayType;

	local isAtMax = progress >= maxProgress;
	if not isAtMax then
		if displayType == Enum.ConquestProgressBarDisplayType.Seasonal then
			self.FillTexture:SetAtlas("_pvpqueue-conquestbar-fill-yellow");
		else
			self.FillTexture:SetAtlas("_pvpqueue-conquestbar-fill-blue");
		end
	else
		self.FillTexture:SetAtlas("_pvpqueue-conquestbar-fill-disabled");
	end

	local inactiveSeason = not ConquestFrame_HasActiveSeason();
	if self.locked or inactiveSeason or maxProgress == 0 then
		self:SetValue(0);
	else
		local maxCurrentProgress = math.min(progress, maxProgress);
		self:SetValue((maxCurrentProgress / maxProgress) * 100);
	end

	self:SetDisabled(inactiveSeason or self.locked);
	self.Border:SetDesaturated(isAtMax or self.disabled);

	self.Label:SetFormattedText(CONQUEST_BAR, progress, maxProgress);

	if self.locked or inactiveSeason then
		self.Reward:Clear();
	else
		self.Reward:Setup();
	end
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

NewPvpSeasonMixin = { };

local MAX_NUMBER_OF_PVP_SEASON_DESCRIPTIONS = 2;
local PVP_SEASON_DESCRIPTION_FORMAT = "SL_PVP_SEASON_DESCRIPTION%s";
local PVP_SEASON_DESCRIPTION_VERTICAL_SPACING = 14;

function NewPvpSeasonMixin:OnShow()
	if self.SeasonDescriptions == nil then
		self.SeasonDescriptions = {};
	end

	local currentSeason = GetCurrentArenaSeason();
	if currentSeason == SL_START_SEASON then
		self.SeasonDescriptionHeader:SetText(SL_PVP_FIRST_SEASON_DESCRIPTION);
		self.SeasonRewardText:SetPoint("TOP", self.SeasonDescriptionHeader, "BOTTOM", 0, -14);

		for i, seasonDescription in ipairs(self.SeasonDescriptions) do
			seasonDescription:Hide();
		end
	else
		self.SeasonDescriptionHeader:SetText(PLAYER_V_PLAYER_SEASON:format(PVPUtil.GetCurrentSeasonNumber()));

		local rewardTextAnchor = self.SeasonDescriptionHeader;
		for i = 1, MAX_NUMBER_OF_PVP_SEASON_DESCRIPTIONS do
			local seasonDescriptionText = _G[PVP_SEASON_DESCRIPTION_FORMAT:format(i)];
			local hasText = (seasonDescriptionText ~= nil);

			local seasonDescription = self.SeasonDescriptions[i];
			if seasonDescription == nil then
				if not hasText then
					break;
				end

				local fontStringName = nil;
				seasonDescription = self:CreateFontString(fontStringName, "ARTWORK", "PVPSeasonChangesDescriptionTemplate");

				local relativeFontString = (i > 1) and self.SeasonDescriptions[i - 1] or self.SeasonDescriptionHeader;
				seasonDescription:SetPoint("TOP", relativeFontString, "BOTTOM", 0, -PVP_SEASON_DESCRIPTION_VERTICAL_SPACING);
			end

			seasonDescription:SetShown(hasText);
			if hasText then
				seasonDescription:SetText(seasonDescriptionText);
				rewardTextAnchor = seasonDescription;
			end
		end

		self.SeasonRewardText:SetPoint("TOP", rewardTextAnchor, "BOTTOM", 0, -PVP_SEASON_DESCRIPTION_VERTICAL_SPACING);
	end

	local achievementID = GetPVPSeasonAchievementID();
	local showSeasonReward = achievementID ~= nil;
	if showSeasonReward then
		self.SeasonRewardFrame:Init(achievementID, PVP_SEASON_REWARD);
	end
	self.SeasonRewardText:SetShown(showSeasonReward);
	self.SeasonRewardFrame:SetShown(showSeasonReward);
end

PVPWeeklyChestMixin = CreateFromMixins(WeeklyRewardMixin);
function PVPWeeklyChestMixin:GetState()
	local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress();

	if C_WeeklyRewards.HasAvailableRewards() then
		return "collect";
	elseif self:HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.RankedPvP) or weeklyProgress.unlocksCompleted > 0 then
		return "complete";
	end

	return "incomplete";
end

function PVPWeeklyChestMixin:OnShow()
	local state = self:GetState();
	local atlas = "pvpqueue-chest-dragonflight-greatvault-"..state;
	self.ChestTexture:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	self.Highlight:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);

	local hasActiveSeason = ConquestFrame_HasActiveSeason();
	local desaturated = not hasActiveSeason;
	self.ChestTexture:SetDesaturated(desaturated);
	self.Highlight:SetDesaturated(desaturated);

	self.SpinTextureBottom:Hide();
	self.SpinTextureTop:Hide();
	self.SpinAnim:Stop();
end

function PVPWeeklyChestMixin:OnEnter()
	if not ConquestFrame_HasActiveSeason() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);
		GameTooltip_AddDisabledLine(GameTooltip, UNAVAILABLE);
		GameTooltip_AddNormalLine(GameTooltip, CONQUEST_REQUIRES_PVP_SEASON);
		GameTooltip:Show();
		return;
	end

	local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress();
	local unlocksCompleted = weeklyProgress.unlocksCompleted or 0;

	local state = self:GetState();
	local maxUnlocks = weeklyProgress.maxUnlocks or 3;
	local description;
	if unlocksCompleted > 0 then
		description = RATED_PVP_WEEKLY_VAULT_TOOLTIP:format(unlocksCompleted, maxUnlocks);
	else
		description = RATED_PVP_WEEKLY_VAULT_TOOLTIP_NO_REWARDS:format(unlocksCompleted, maxUnlocks);
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);

	local hasRewards = C_WeeklyRewards.HasAvailableRewards();
	if hasRewards then
		GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
	end
	GameTooltip_AddNormalLine(GameTooltip, description);
	GameTooltip_AddInstructionLine(GameTooltip, WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS);
	GameTooltip:Show();
end

function PVPWeeklyChestMixin:OnMouseUp(...)
	if not ConquestFrame_HasActiveSeason() then
		return;
	end

	WeeklyRewardMixin.OnMouseUp(self, ...);
end

function PVPNewSeasonPopupOnClick(self)
	self:GetParent():Hide();
	SetCVar("newPvpSeason", GetCurrentArenaSeason());
end

PVPWeeklyCasualPanelMixin = { };
function PVPWeeklyCasualPanelMixin:OnShow()
	local serverExpansionLevel = GetServerExpansionLevel();

	local maxLevel = GetMaxLevelForExpansionLevel(serverExpansionLevel);
	local playerLevel = UnitLevel("player");
	local Label = self.HKLabel;
	if playerLevel < maxLevel then
		Label:Hide();
		self.WeeklyChest:Hide();
		self.HonorLevelDisplay:SetPoint("TOP", 0, -25);
	else
		Label:SetText(RATED_PVP_WEEKLY_VAULT);
		Label:SetPoint("TOP", 0, -12);
		Label:Show();
		self.WeeklyChest:Show();
		self.HonorLevelDisplay:SetPoint("TOP", self.WeeklyChest, "BOTTOM", 0, -90);
	end
end


PVPWeeklyRatedPanelMixin = { };

function PVPWeeklyRatedPanelMixin:OnShow()
	self:RegisterEvent("PVP_RATED_STATS_UPDATE");
	self:Update()
end

function PVPWeeklyRatedPanelMixin:OnHide()
	self:UnregisterEvent("PVP_RATED_STATS_UPDATE");
end

function PVPWeeklyRatedPanelMixin:OnEvent(event, ...)
	if event == "PVP_RATED_STATS_UPDATE" then
		self:Update();
	end
end

function PVPWeeklyRatedPanelMixin:Update()
	local showSeasonReward = false;
	local seasonState = ConquestFrame.seasonState;
	if seasonState ~= SEASON_STATE_PRESEASON then
		local achievementID = GetPVPSeasonAchievementID();
		if achievementID ~= nil then
			showSeasonReward = true;
			self.SeasonRewardFrame:Init(achievementID, PVP_SEASON_REWARD);
		end
	end
	self.SeasonRewardFrame:SetShown(showSeasonReward);

	local Tier = self.Tier;
	if seasonState == SEASON_STATE_PRESEASON then
		Tier:Hide();
	else
		Tier:Show();

		local Title = Tier.Title;
		if seasonState == SEASON_STATE_OFFSEASON then
			Title:SetText(PVP_LAST_SEASON_HIGH);
			Title:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		else
			Title:SetText(PVP_SEASON_HIGH);
			Title:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end

		local tierID, nextTierID = C_PvP.GetSeasonBestInfo();
		local tierInfo = C_PvP.GetPvpTierInfo(tierID);
		ConquestFrame_SetPanelTierInfo(Tier, tierInfo);

		local NextTier = Tier.NextTier;
		local nextTierInfo = nextTierID and C_PvP.GetPvpTierInfo(nextTierID);
		if nextTierInfo and seasonState ~= SEASON_STATE_OFFSEASON then
			NextTier.tierInfo = nextTierInfo;
			NextTier.Icon:SetTexture(nextTierInfo.tierIconID);
			NextTier:Show();
		else
			NextTier.tierInfo = nil;
			NextTier:Hide();
		end
	end

	local serverExpansionLevel = GetServerExpansionLevel();

	local maxLevel = GetMaxLevelForExpansionLevel(serverExpansionLevel);
	local playerLevel = UnitLevel("player");
	local Label = self.Label;
	if playerLevel < maxLevel then
		Label:Hide();
		self.WeeklyChest:Hide();
		Tier:SetPoint("TOP", 0, -32);
	else
		Label:SetText(RATED_PVP_WEEKLY_VAULT);
		Label:Show();
		self.WeeklyChest:Show();
		Tier:SetPoint("TOP", self.WeeklyChest, "BOTTOM", 0, -90);
	end
	Label:SetText(RATED_PVP_WEEKLY_VAULT);
end

local function PVPQuestRewardSortFunction(firstValue, secondValue)
	return firstValue > secondValue;
end

PVPQuestRewardMixin = { };

function PVPQuestRewardMixin:OnShow()
	self:RegisterEvent("QUEST_LOG_UPDATE");
end

function PVPQuestRewardMixin:OnHide()
	self:RegisterEvent("QUEST_LOG_UPDATE");
end

function PVPQuestRewardMixin:OnEvent(event, ...)
	if(event == "QUEST_LOG_UPDATE") then
		self:Init(self.questID);
	end
end

function PVPQuestRewardMixin:Init(questID)
	self.questID = questID;
	self.Icon:Hide();

	if (not self.questID) then
		return;
	end

	if (not HaveQuestData(self.questID)) then
		self.questInCache = false;
		return;
	end

	--We already have set up the frame if the quest is set to in your cache.
	if (self.questInCache and self.Icon:IsShown()) then
		return;
	end

	local isCompleted;
	if (C_QuestLog.IsOnQuest(self.questID)) then
		isCompleted =  C_QuestLog.IsComplete(self.questID)
	else
		isCompleted = C_QuestLog.IsQuestFlaggedCompleted(self.questID);
	end

	self.Icon:SetDesaturated(isCompleted);
	if self.CheckMark then
		self.CheckMark:SetShown(isCompleted);
	end

	self.questInCache = true;
	local rewards = { };
	rewards.currencyRewards = { };
	local continuableContainer = ContinuableContainer:Create();
	local numCurrencies = GetNumQuestLogRewardCurrencies(self.questID);
	for i = 1, numCurrencies do
		local name, texture, count, currencyID, quality = GetQuestLogRewardCurrencyInfo(i, questID);
		local reward = { };
		reward.texture = texture;
		reward.quality = quality;
		tinsert(rewards.currencyRewards, reward);
	end

	local numItems = GetNumQuestLogRewards(questID);
	for i = 1, numItems do
		local name, texture, count, quality, isUsable, itemID = GetQuestLogRewardInfo(i, questID);
		local item = Item:CreateFromItemID(itemID);
		continuableContainer:AddContinuable(item);
	end

	continuableContainer:ContinueOnLoad(function()
		rewards.itemRewards = { };
		local numItems = GetNumQuestLogRewards(questID);
		for i = 1, numItems do
			local name, texture, count, quality, isUsable, itemID = GetQuestLogRewardInfo(i, questID);
			local reward = { };
			reward.texture = texture;
			reward.quality = quality;
		end

		if (rewards.itemRewards and #rewards.itemRewards > 1) then
			table.sort(self.itemRewards, function(a, b)
				return PVPQuestRewardSortFunction(a.quality, b.quality);
			end);
		end

		if(rewards.currencyRewards and #rewards.currencyRewards > 1) then
			table.sort(rewards.currencyRewards, function(a, b)
				return PVPQuestRewardSortFunction(a.quality, b.quality);
			end);
		end
		if(rewards and rewards.itemRewards and rewards.itemRewards[1]) then
			self.Icon:SetTexture(rewards.itemRewards[1].texture);
			self.Icon:Show();
		elseif(rewards and rewards.currencyRewards and rewards.currencyRewards[1]) then
			self.Icon:SetTexture(rewards.currencyRewards[1].texture)
			self.Icon:Show();
		end
	end);

	self:Show();
end

function PVPQuestRewardMixin:OnEnter()
	self.shouldShowObjectivesAsStatusBar = true;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( not C_QuestLog.IsOnQuest(self.questID) and C_QuestLog.IsQuestFlaggedCompleted(self.questID)) then
		GameTooltip_AddColoredLine(GameTooltip, GOAL_COMPLETED, GREEN_FONT_COLOR);
		GameTooltip:Show();
	else
		GameTooltip_AddQuest(self);
	end
end

function PVPQuestRewardMixin:OnLeave()
	GameTooltip:Hide();
end

local function UserActionClosePVPTalentPrestigeLevelDialog(frame)
	PlaySound(SOUNDKIT.UI_PVP_HONOR_PRESTIGE_WINDOW_CLOSE);
	frame:Hide();
end

PVPTalentPrestigeLevelDialogCloseButtonMixin = {};

function PVPTalentPrestigeLevelDialogCloseButtonMixin:OnClick()
	UserActionClosePVPTalentPrestigeLevelDialog(self:GetParent());
end

PVPRewardRoleShortageBonusMixin = {};

function PVPRewardRoleShortageBonusMixin:Init(rewardInfo)
	self.rewardInfo = rewardInfo;

	if rewardInfo then
		local iconTexture = C_Item.GetItemIconByID(rewardInfo.rewardItemID);
		self.Icon:SetTexture(iconTexture or QUESTION_MARK_ICON);

		self.rewardInfo.rewardSpell = Spell:CreateFromSpellID(rewardInfo.rewardSpellID);
	end
end

function PVPRewardRoleShortageBonusMixin:HasRewardInfo()
	return self.rewardInfo ~= nil;
end

function PVPRewardRoleShortageBonusMixin:OnEnter()
	if self.rewardInfo then
		self.rewardInfo.rewardSpell:ContinueOnSpellLoad(GenerateClosure(self.RefreshTooltip, self));
	end
end

function PVPRewardRoleShortageBonusMixin:RefreshTooltip()
	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(EmbeddedItemTooltip, BATTLEGROUND_HOLIDAY, NORMAL_FONT_COLOR);
	GameTooltip_AddHighlightLine(EmbeddedItemTooltip, self.rewardInfo.rewardSpell:GetSpellDescription(), false);

	GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
	EmbeddedItemTooltip_SetItemByID(EmbeddedItemTooltip.ItemTooltip, self.rewardInfo.rewardItemID);		
	EmbeddedItemTooltip:Show();
end

function PVPRewardRoleShortageBonusMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
end
