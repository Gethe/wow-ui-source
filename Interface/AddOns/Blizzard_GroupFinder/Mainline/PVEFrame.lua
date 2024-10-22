---------------------------------------------------------------
-- PVE FRAME
---------------------------------------------------------------

PVE_FRAME_BASE_WIDTH = 563;

local panels = {
	{ name = "GroupFinderFrame", addon = nil },
	{ name = "PVPUIFrame", addon = "Blizzard_PVPUI" },
	{ name = "ChallengesFrame", addon = "Blizzard_ChallengesUI", check = function() return UnitLevel("player") >= GetMaxLevelForPlayerExpansion(); end, hideLeftInset = true },
	{ name = "DelvesDashboardFrame", addon = "Blizzard_DelvesDashboardUI", check = function() return GetExpansionLevel() >= LE_EXPANSION_WAR_WITHIN end, hideLeftInset = true },
}

function LFGListPVPStub_OnShow(self)
	LFGListPVEStub_OnShow(self);
	LFGListFrame_SetBaseFilters(LFGListFrame, Enum.LFGListFilter.PvP);
end

function LFGListPVEStub_OnShow(self)
	LFGListFrame:SetParent(self);
	LFGListFrame:ClearAllPoints();
	LFGListFrame:SetAllPoints(self);
	LFGListFrame:SetFrameLevel(self:GetFrameLevel());

	local filters = Enum.LFGListFilter.PvE;
	if PVEFrame:TimerunningEnabled() then
		filters = bit.band(filters, Enum.LFGListFilter.Timerunning);
	end
	LFGListFrame_SetBaseFilters(LFGListFrame, filters);
end

function PVEFrame_ToggleFrame(sidePanelName, selection)
	local canUse, failureReason = C_LFGInfo.CanPlayerUseGroupFinder();
	if ( not canUse or Kiosk.IsEnabled() ) then
		return;
	end
	local self = PVEFrame;
	if ( self:IsShown() ) then
		if ( sidePanelName ) then
			local sidePanel = _G[sidePanelName];
			if ( sidePanel ) then
				--We know the panel is loaded, so try to dereference the selection
				if ( type(selection) == "string" ) then
					selection = _G[selection];
				end
				if ( sidePanel:IsShown() and (not selection or not sidePanel.getSelection or sidePanel:getSelection() == selection) ) then
					HideUIPanel(self);
					return;
				end
			end
		else
			HideUIPanel(self);
			return;
		end
	end
	PVEFrame_ShowFrame(sidePanelName, selection);
end

function PVEFrame_ShowFrame(sidePanelName, selection)
	local self = PVEFrame;
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
	if ( panels[tabIndex].check and not panels[tabIndex].check() ) then
		tabIndex = self.activeTabIndex or 1;
	end

	-- load addon if needed
	if ( panels[tabIndex].addon ) then
		UIParentLoadAddOn(panels[tabIndex].addon);
		panels[tabIndex].addon = nil;
	end

	-- we've loaded the AddOn, so try to dereference the selection if needed
	if ( type(selection) == "string" ) then
		selection = _G[selection];
	end

	-- Hide the left panel if the panel doesn't need it
	if ( panels[tabIndex].hideLeftInset ) then
		PVEFrame_HideLeftInset();
	else
		PVEFrame_ShowLeftInset();
	end

	-- show it
	ShowUIPanel(self);
	self.activeTabIndex = tabIndex;
	PanelTemplates_SetTab(self, tabIndex);
	if ( panels[tabIndex].width ) then
		self:SetWidth(panels[tabIndex].width);
	else
		self:SetWidth(PVE_FRAME_BASE_WIDTH);
	end
	UpdateUIPanelPositions(PVEFrame);
	for index, data in pairs(panels) do
		local panel = _G[data.name];
		if ( index == tabIndex ) then
			panel:Show();
			if( panel.update ) then
				panel:update(selection);
			end
		elseif ( panel ) then
			panel:Hide();
		end
	end
end

function PVEFrame_TabOnClick(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	PVEFrame_ShowFrame(panels[self:GetID()].name);
end

function PVEFrame_HideLeftInset()
    PVEFrameLeftInset:Hide();
    PVEFrameBlueBg:Hide();
    PVEFrameTLCorner:Hide();
    PVEFrameTRCorner:Hide();
    PVEFrameBRCorner:Hide();
    PVEFrameBLCorner:Hide();
    PVEFrameLLVert:Hide();
    PVEFrameRLVert:Hide();
    PVEFrameBottomLine:Hide();
    PVEFrameTopLine:Hide();
    PVEFrameTopFiligree:Hide();
    PVEFrameBottomFiligree:Hide();
    PVEFrame.shadows:Hide();
end

function PVEFrame_ShowLeftInset()
    PVEFrameLeftInset:Show();
    PVEFrameBlueBg:Show();
    PVEFrameTLCorner:Show();
    PVEFrameTRCorner:Show();
    PVEFrameBRCorner:Show();
    PVEFrameBLCorner:Show();
    PVEFrameLLVert:Show();
    PVEFrameRLVert:Show();
    PVEFrameBottomLine:Show();
    PVEFrameTopLine:Show();
    PVEFrameTopFiligree:Show();
    PVEFrameBottomFiligree:Show();
    PVEFrame.shadows:Show();
end

---------------------------------------------------------------
-- GROUP FINDER
---------------------------------------------------------------

local groupFrames = { "LFDParentFrame", "RaidFinderFrame", "LFGListPVEStub" }

local function GroupFinderFrame_InitLFG(self, button)
	SetPortraitToTexture(button.icon, "Interface\\Icons\\INV_Helmet_08");
	button.name:SetText(LOOKING_FOR_DUNGEON_PVEFRAME);
end

local function GroupFinderFrame_InitScenarios(self, button)
	SetPortraitToTexture(button.icon, "Interface\\Icons\\Icon_Scenarios");
	button.name:SetText(SCENARIOS_PVEFRAME);
end

local function GroupFinderFrame_InitLFR(self, button)
	SetPortraitToTexture(button.icon, "Interface\\LFGFrame\\UI-LFR-PORTRAIT");
	button.name:SetText(RAID_FINDER_PVEFRAME);
end

local function GroupFinderFrame_InitPremadeGroup(self, button)
	SetPortraitToTexture(button.icon, "Interface\\Icons\\Achievement_General_StayClassy");
	button.name:SetText(LFGLIST_NAME);
end

function GroupFinderFrame_OnLoad(self)
	GroupFinderFrame_EvaluateButtonVisibility(self);

	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO");
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");

	-- set up accessors
	self.getSelection = GroupFinderFrame_GetSelection;
	self.update = GroupFinderFrame_Update;
end

local function GroupFinderFrame_SetupLFG(self, button)
	local canUse, failureReason = C_LFGInfo.CanPlayerUseLFD();
	GroupFinderFrameButton_SetEnabled(button, canUse);
	if not canUse then
		button.tooltip = button.tooltip or failureReason;
	else
		button.tooltip = nil;
	end
end

local function GroupFinderFrame_SetupLFR(self, button)
	local canUse, failureReason = C_LFGInfo.CanPlayerUseLFR();
	GroupFinderFrameButton_SetEnabled(button, canUse);
	if not canUse then
		button.tooltip = failureReason;
	else
		button.tooltip = nil;
	end
end

local function GroupFinderFrame_SetupPremadeGroup(self, button)
	local canUse, failureReason = C_LFGInfo.CanPlayerUsePremadeGroup();
	GroupFinderFrameButton_SetEnabled(button, canUse);
	if not canUse then
		button.tooltip = failureReason;
	else
		button.tooltip = nil;
	end
end

local function GroupFinderFrame_SetupScenario(self, button)
	local canUse, failureReason = C_LFGInfo.CanPlayerUseScenarioFinder();
	GroupFinderFrameButton_SetEnabled(button, canUse);
	if not canUse then
		if ( GroupFinderFrame_GetSelectedIndex(self) == button:GetID() ) then
			-- Deselect this now hidden tab if it happened to be selected
			self.selection = nil
			GroupFinderFrame_ShowGroupFrame(nil)
		end
		button.tooltip = button.tooltip or failureReason;
	else
		button.tooltip = nil;
	end
end

function GroupFinderFrame_EvaluateButtonVisibility(self)
	GroupFinderFrame_SetupLFG(self, self.groupButton1);
	
	if PVEFrame:ScenariosEnabled() then
		GroupFinderFrame_SetupScenario(self, self.groupButton2);
		GroupFinderFrame_SetupLFR(self, self.groupButton3);
		GroupFinderFrame_SetupPremadeGroup(self, self.groupButton4);

		local function GroupFinderFrame_UpdateButtonAnchors(self)
			local moveDown = not self.groupButton2:IsShown();
			local spacing =  moveDown and -30 or -23
			local button3RelativeTo = moveDown and self.groupButton1 or self.groupButton2
			self.groupButton3:SetPoint("TOP", button3RelativeTo, "BOTTOM", 0, spacing);
			self.groupButton4:SetPoint("TOP", self.groupButton3, "BOTTOM", 0, spacing);
			self.groupButton1:SetPoint("TOPLEFT", self, "TOPLEFT", 10, moveDown and -101 or -70);
		end
		GroupFinderFrame_UpdateButtonAnchors(self);
	else
		GroupFinderFrame_SetupLFR(self, self.groupButton2);
		GroupFinderFrame_SetupPremadeGroup(self, self.groupButton3);		
	end
end

function GroupFinderFrameButton_SetEnabled(button, enabled)
	if ( button:IsEnabled() == enabled ) then
		return
	end

	if ( enabled ) then
		button.bg:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
		button.name:SetFontObject("GameFontNormalLarge");
	else
		button.bg:SetTexCoord(0.00390625, 0.87890625, 0.67187500, 0.75000000);
		button.name:SetFontObject("GameFontDisableLarge");
	end
	SetDesaturation(button.icon, not enabled);
	SetDesaturation(button.ring, not enabled);
	button:SetEnabled(enabled);
end

function GroupFinderFrame_OnEvent(self, event, ...)
	GroupFinderFrame_EvaluateButtonVisibility(self);
end

function GroupFinderFrame_GetSelection(self)
	return self.selection;
end

function GroupFinderFrame_GetSelectedIndex(self)
	return self.selectionIndex;
end

function GroupFinderFrame_Update(self, frame)
	GroupFinderFrame_ShowGroupFrame(frame);
end

function GroupFinderFrame_EvaluateHelpTips(self)
	if not GetCVarBitfield("closedInfoFramesAccountWide", LE_FRAME_TUTORIAL_ACCOUNT_LFG_LIST) and C_LFGInfo.CanPlayerUsePremadeGroup() then
		local helpTipInfo = {
			text = LFG_LIST_TUTORIAL_ALERT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFramesAccountWide",
			bitfieldFlag = LE_FRAME_TUTORIAL_ACCOUNT_LFG_LIST,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			checkCVars = true,
		};
		if PVEFrame:TimerunningEnabled() then
			HelpTip:Show(self, helpTipInfo, GroupFinderFrameGroupButton4);
		else
			HelpTip:Show(self, helpTipInfo, GroupFinderFrameGroupButton3);
		end
	end
end

function GroupFinderFrame_OnShow(self)
	GroupFinderFrame_InitLFG(self, self.groupButton1);
	
	if (PVEFrame:ScenariosEnabled()) then		
		groupFrames = { "LFDParentFrame", "ScenarioFinderFrame", "RaidFinderFrame", "LFGListPVEStub" };

		GroupFinderFrame_InitScenarios(self, self.groupButton2);
		GroupFinderFrame_InitLFR(self, self.groupButton3);
		GroupFinderFrame_InitPremadeGroup(self, self.groupButton4);
		self.groupButton4:Show();
		GroupFinderFrameButton_SetEnabled(self.groupButton4, true);
	else
		groupFrames = { "LFDParentFrame", "RaidFinderFrame", "LFGListPVEStub" };

		GroupFinderFrame_InitLFR(self, self.groupButton2);
		GroupFinderFrame_InitPremadeGroup(self, self.groupButton3);
		self.groupButton4:Hide();
	end

	PVEFrame:SetPortraitAtlasRaw("groupfinder-eye-frame");
	PVEFrame:SetTitle(GROUP_FINDER);
	GroupFinderFrame_EvaluateButtonVisibility(self);
	GroupFinderFrame_EvaluateHelpTips(self);
end

function GroupFinderFrame_ShowGroupFrame(frame)
	frame = frame or GroupFinderFrame.selection or (C_LFGInfo.CanPlayerUseLFD() and LFDParentFrame or LFGListPVEStub);
	-- hide the other frames and select the right button
	for index, frameName in pairs(groupFrames) do
		local groupFrame = _G[frameName];
		if ( groupFrame == frame ) then
			GroupFinderFrame_SelectGroupButton(index);
		else
			groupFrame:Hide();
		end
	end
	frame:Show();
	GroupFinderFrame.selection = frame;
end

function GroupFinderFrame_SelectGroupButton(index)
	local self = GroupFinderFrame;
	for i = 1, #groupFrames do
		local button = self["groupButton"..i];
		if ( i == index ) then
			button.bg:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188);
		else
			button.bg:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
		end
	end

	GroupFinderFrame.selectionIndex = index
end

function GroupFinderFrameGroupButton_OnClick(self)
	local frameName = groupFrames[self:GetID()];
	GroupFinderFrame_ShowGroupFrame(_G[frameName]);
end

function GroupFinderFrameGroupButton_OnEnter(self)
	if self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip_AddNormalLine(GameTooltip, self.tooltip);
		GameTooltip:Show();
	end
end

PVEFrameMixin = { };
function PVEFrameMixin:OnLoad()
	RaiseFrameLevel(self.shadows);
	PanelTemplates_SetNumTabs(self, #panels);

	self:RegisterEvent("AJ_PVP_ACTION");
	self:RegisterEvent("AJ_PVP_SPECIAL_BG_ACTION");
	self:RegisterEvent("AJ_PVP_SKIRMISH_ACTION");
	self:RegisterEvent("AJ_PVP_LFG_ACTION");
	self:RegisterEvent("AJ_PVP_RBG_ACTION");
	self:RegisterEvent("AJ_PVE_LFG_ACTION");
	self:RegisterEvent("SHOW_DELVES_DISPLAY_UI");

	self.maxTabWidth = (self:GetWidth() - 19) / #panels;
end

function PVEFrameMixin:TimerunningEnabled()
	return PlayerGetTimerunningSeasonID();
end

function PVEFrameMixin:ScenariosEnabled()
	-- scenarios are currently only enabled in Timerunning
	-- Keeping this seperate from the Timerunning check to leave 
	-- room for Design to add other conditions
	return self:TimerunningEnabled();
end

function PVEFrameMixin:OnShow()
	for index, panel in pairs(panels) do
		if (panel.check and not panel.check()) then
			PanelTemplates_HideTab(self, index);
		else
			PanelTemplates_ShowTab(self, index);
			if (panel.name == "ChallengesFrame" and not C_MythicPlus.IsMythicPlusActive()) then
				PanelTemplates_DisableTab(self, index);
			else
				PanelTemplates_EnableTab(self, index);
			end
		end
	end	

	-- hide the PVP and Mythic+ tabs if timerunning is enabled
	self.tab2:SetShown(not self:TimerunningEnabled());
	self.tab3:SetShown(not self:TimerunningEnabled());

	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function PVEFrameMixin:OnHide()
	UpdateMicroButtons();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function PVEFrameMixin:OnEvent(event, ...)
	if ( event == "AJ_PVP_ACTION" ) then
		local id = ...;
		PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame");
		HonorFrameSpecificList_FindAndSelectBattleground(id);
		HonorFrame_SetType("specific");
	elseif ( event == "AJ_PVP_SPECIAL_BG_ACTION" ) then
		PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame");
		HonorFrame_SetType("bonus");
		
		if (HonorFrame.BonusFrame.BrawlButton2) then
			HonorFrameBonusFrame_SelectButton(HonorFrame.BonusFrame.BrawlButton2);
		end

	elseif ( event == "AJ_PVP_SKIRMISH_ACTION" ) then
		PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame");
		HonorFrame_SetType("bonus");

		HonorFrameBonusFrame_SelectButton(HonorFrame.BonusFrame.Arena1Button);
	elseif ( event == "AJ_PVE_LFG_ACTION" ) then
		PVEFrame_ShowFrame("GroupFinderFrame", "LFGListPVEStub");
	elseif ( event == "AJ_PVP_LFG_ACTION" ) then
		PVEFrame_ShowFrame("PVPUIFrame", "LFGListPVPStub");
	elseif ( event == "AJ_PVP_RBG_ACTION" ) then
		PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame");
		HonorFrame_SetType("bonus");

		HonorFrameBonusFrame_SelectButton(HonorFrame.BonusFrame.RandomBGButton);
	elseif ( event == "SHOW_DELVES_DISPLAY_UI" ) then
		PVEFrame_ShowFrame("DelvesDashboardFrame");
	end
end
