
MAX_ARENA_TEAM_MEMBERS = 10;

BATTLEGROUND_BUTTON_HEIGHT = 40;

local MAX_SHOWN_BATTLEGROUNDS = 8;
local NO_ARENA_SEASON = 0;

local SEASON_STATE_OFFSEASON = 1;
local SEASON_STATE_PRESEASON = 2;
local SEASON_STATE_ACTIVE = 3;
local SEASON_STATE_DISABLED = 4;

local BFA_START_SEASON = 26;
local BFA_FINAL_SEASON = 29;
local SL_START_SEASON = 30;

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
	PanelTemplates_SetNumTabs(self, 2);

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
	PVPUIFrame_UpdateAvailableRoles(ConquestFrame.TankIcon, ConquestFrame.HealerIcon, ConquestFrame.DPSIcon);
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
		if honor > 0 then
			local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(Constants.CurrencyConsts.HONOR_CURRENCY_ID, honor);
			if currencyInfo then
				rewardTexture = currencyInfo.icon;
			end
		elseif experience > 0 then
			rewardTexture = "Interface\\Icons\\xp_icon"
		end
	end

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
		PVEFrame.TitleText:SetText(PLAYER_V_PLAYER_PRE_SEASON);
	elseif ConquestFrame.seasonState == SEASON_STATE_OFFSEASON then
		PVEFrame.TitleText:SetText(PLAYER_V_PLAYER_OFF_SEASON);
	else
		PVEFrame.TitleText:SetText(PLAYER_V_PLAYER_SEASON:format(GetCurrentArenaSeason() - SL_START_SEASON + 1));
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
		if IsInGroup(LE_PARTY_CATEGORY_HOME) then
			local brawlInfo = C_PvP.GetAvailableBrawlInfo();
			if brawlInfo then
				disabledReason = QUEUE_UNAVAILABLE_PARTY_MIN_LEVEL:format(GetMaxLevelForPlayerExpansion());
			end
		else
			disabledReason = INSTANCE_UNAVAILABLE_SELF_LEVEL_TOO_LOW;
		end
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
	},
	SpecialEvent = {
		func = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(PVP_SPECIAL_EVENT_BUTTON_TT_TITLE, 1, 1, 1);
			GameTooltip:AddLine(PVP_SPECIAL_EVENT_BUTTON_TT_DESC, nil, nil, nil, true);
			GameTooltip:Show();
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
		-- special event
		local info = C_PvP.GetSpecialEventInfo();
		local details = C_PvP.GetSpecialEventDetails();
		local button = HonorFrame.BonusFrame.SpecialEventButton;
		local isEventAvailable = info and details and details.isActive;
		if isEventAvailable then
			button.canQueue = info.canQueue;
			button.bgID = info.bgID;
			button.Title:SetText(details.name);
			button.Reward.questID = details.questID; 
			button.Reward:Init(details.questID);
			local textColor = button.canQueue and HIGHLIGHT_FONT_COLOR or DISABLED_FONT_COLOR;
			button.Title:SetTextColor(textColor:GetRGB());
			button:SetEnabled(button.canQueue);
			tinsert(buttons, button);
		end
		button:SetShown(isEventAvailable);
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
	return ConquestFrame.bgsEnabled and ConquestFrame.arenasEnabled;
end

function ConquestFrame_OnShow(self)
	RequestRatedInfo();
	RequestPVPOptionsEnabled();
	ConquestFrame_Update(self);
	local lastSeasonNumber = tonumber(GetCVar("newPvpSeason"));
	local currentSeasonNumber = GetCurrentArenaSeason();
	if currentSeasonNumber >= SL_START_SEASON and lastSeasonNumber < currentSeasonNumber then
		PVPQueueFrame.NewSeasonPopup:Show();
	end
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
			button.Tier:Setup(tierInfo, ranking);
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

	if not ConquestFrame_HasActiveSeason() then
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
	local tierName = tierInfo and tierInfo.pvpTierEnum and PVPUtil.GetTierName(tierInfo.pvpTierEnum);
	if tierName then
		if ranking then
			tooltip.Tier:SetFormattedText(PVP_TIER_WITH_RANK_AND_RATING, tierName, ranking, rating);
		else
			tooltip.Tier:SetFormattedText(PVP_TIER_WITH_RATING, tierName, rating);
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

local function AddPVPRewardCurrency(tooltip, currencyID, amount)
	local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(currencyID, amount);
	if currencyInfo then
		local text = BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format(currencyInfo.icon, currencyInfo.displayAmount, currencyInfo.name);
		local currencyColor = GetColorForCurrencyReward(currencyID, currencyInfo.displayAmount);
		tooltip:AddLine(text, currencyColor:GetRGB());
	end
end

function PVPStandardRewardTemplate_OnEnter(self)
	if (not self.Icon:IsShown()) then
		return;
	end
	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
	EmbeddedItemTooltip:SetText(PVP_REWARD_TOOLTIP);
	self.UpdateTooltip = nil;

	if (self.experience > 0) then
		GameTooltip_AddColoredLine(EmbeddedItemTooltip, PVP_REWARD_XP_FORMAT:format(BreakUpLargeNumbers(self.experience)), HIGHLIGHT_FONT_COLOR);
	else
		AddPVPRewardCurrency(EmbeddedItemTooltip, Constants.CurrencyConsts.HONOR_CURRENCY_ID, self.honor);
	end
	if self.conquestAmount > 0 then
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
	self.CasualPanel:Show();
	self.RatedPanel:Hide();
end

local SEASON_REWARD_ACHIEVEMENTS = {
	[BFA_FINAL_SEASON] = {
		[HORDE_PLAYER_FACTION_GROUP_NAME] = 13944,
		[ALLIANCE_PLAYER_FACTION_GROUP_NAME] = 13943,
	},
	[SL_START_SEASON] = {
		[HORDE_PLAYER_FACTION_GROUP_NAME] = 14611,
		[ALLIANCE_PLAYER_FACTION_GROUP_NAME] = 14612,
	},
	[SL_START_SEASON + 1] = {
		[HORDE_PLAYER_FACTION_GROUP_NAME] = 14966,
		[ALLIANCE_PLAYER_FACTION_GROUP_NAME] = 14967,
	},
	[SL_START_SEASON + 2] = {
		[HORDE_PLAYER_FACTION_GROUP_NAME] = 14564,
		[ALLIANCE_PLAYER_FACTION_GROUP_NAME] = 14558,
	},
	[SL_START_SEASON + 3] = {
		[HORDE_PLAYER_FACTION_GROUP_NAME] = 14565,
		[ALLIANCE_PLAYER_FACTION_GROUP_NAME] = 14559,
	},
	[SL_START_SEASON + 4] = {
		[HORDE_PLAYER_FACTION_GROUP_NAME] = 14566,
		[ALLIANCE_PLAYER_FACTION_GROUP_NAME] = 14560,
	},
};

local function GetPVPSeasonAchievementID(seasonID)
	local achievements = SEASON_REWARD_ACHIEVEMENTS[seasonID];
	local achievementID = achievements and achievements[UnitFactionGroup("player")];
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
		local itemID, _, _, _, texture = GetItemInfoInstant(self.rewardItemID);
		local _, itemLink = GetItemInfo(itemID);
		HandleModifiedItemClick(itemLink);
	end
end

function PVPAchievementRewardMixin:Update()
	local achievementID = self:GetAchievementID();
	local hasAchievementID = achievementID ~= nil;
	if hasAchievementID then
		self.rewardItemID = C_AchievementInfo.GetRewardItemID(achievementID);
		local texture = self.rewardItemID and select(5, GetItemInfoInstant(self.rewardItemID)) or nil;
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
	self:Update();
end

function PVPConquestBarMixin:OnHide()
	self:UnregisterEvent("WEEKLY_REWARDS_ITEM_CHANGED");
	self:UnregisterEvent("WEEKLY_REWARDS_UPDATE");
end

function PVPConquestBarMixin:OnEvent(event, ...)
	if event == "WEEKLY_REWARDS_ITEM_CHANGED" or event == "WEEKLY_REWARDS_UPDATE" then
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
	self.locked = not IsPlayerAtEffectiveMaxLevel();
	self.Lock:SetShown(self.locked);

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID);
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
		self.SeasonDescriptionHeader:SetText(SL_SEASON_NUMBER:format(currentSeason - SL_START_SEASON + 1));

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

	local achievementID = GetPVPSeasonAchievementID(currentSeason);
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
	local atlas = "pvpqueue-chest-greatvault-"..state;
	self.ChestTexture:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	self.Highlight:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);

	local desaturated = not ConquestFrame_HasActiveSeason();
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
		GameTooltip_AddInstructionLine(GameTooltip, WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS);
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
	local showSeasonReward = false;
	local seasonState = ConquestFrame.seasonState;
	if seasonState ~= SEASON_STATE_PRESEASON then
		local seasonID = GetCurrentArenaSeason();
		if seasonID == NO_ARENA_SEASON then
			seasonID = GetPreviousArenaSeason();
		end
		if seasonID and seasonID >= BFA_FINAL_SEASON then
			local achievementID = GetPVPSeasonAchievementID(seasonID);
			if achievementID ~= nil then
				showSeasonReward = true;
				self.SeasonRewardFrame:Init(achievementID, PVP_SEASON_REWARD);
			end
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
	GameTooltip_AddQuest(self); 	
end

function PVPQuestRewardMixin:OnLeave()
	GameTooltip:Hide(); 
end 