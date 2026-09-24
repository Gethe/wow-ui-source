local CHARACTER_FRAME_WIDTH_PADDING = 82;

function ToggleCharacter (tab, onlyShow)
	if C_GameRules.IsGameRuleActive(Enum.GameRule.CharacterPanelDisabled) then
		return;
	end

	local subFrame = _G[tab];
	if ( subFrame ) then
		if (not subFrame.hidden) then
			if ( CharacterFrame:IsShown() ) then
				if ( subFrame:IsShown() ) then
					if ( not onlyShow ) then
						HideUIPanel(CharacterFrame);
					end
				else
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
					CharacterFrame:ShowSubFrame(tab);
					if InputUtil.IsGamepadUIEnabled() then
						CharacterFrame:UpdateSmartNavFocus();
					end
				end
			else
				CharacterFrame:ShowSubFrame(tab);
				ShowUIPanel(CharacterFrame);
			end
			CharacterFrame:RefreshDisplay();
		end
	end
end

function ShowCharacterFrameIfMatchesContext()
	if CharacterFrame:IsShown() then
		return;
	end

	local count = 0;
	for i = 1, NUM_INVSLOTS do
		if ItemButtonUtil.GetItemContextMatchResultForPaperDollFrame(i) == ItemButtonUtil.ItemContextMatchResult.Match then
			ToggleCharacter("PaperDollFrame");
			return;
		end
	end
end

local FRAME_FOCUS_LEFT = 1;
local FRAME_FOCUS_RIGHT = 2;

CHARACTER_FRAME_TAB = {
	Character = 1,
	Reputation = 2,
	Skills = 3,
	PVP = 4,
	Currency = 5,
	Statistics = 6,
};

local CHARACTER_MODE_TAB_ICONS = {
	[CHARACTER_FRAME_TAB.Character] = nil, -- Character tab uses player portrait.
	[CHARACTER_FRAME_TAB.Reputation] = "Interface/ICONS/INV_SideTab_Reputation2_c60",
	[CHARACTER_FRAME_TAB.Skills] = "Interface/ICONS/Ability_Racial_JackofAllTrades",
	[CHARACTER_FRAME_TAB.PVP] = nil, -- PvP tab is faction-specific.
	[CHARACTER_FRAME_TAB.Currency] = "Interface/ICONS/INV_SideTab_Currency_c60",
	[CHARACTER_FRAME_TAB.Statistics] = "Interface/ICONS/INV_SideTab_Stats_c60",
};

local CHARACTER_MODE_TAB_FRAMES = {
	[CHARACTER_FRAME_TAB.Character] = "PaperDollFrame",
	[CHARACTER_FRAME_TAB.Reputation] = "ReputationFrame",
	[CHARACTER_FRAME_TAB.Skills] = "SkillsFrame",
	[CHARACTER_FRAME_TAB.PVP] = "PVPRankFrame",
	[CHARACTER_FRAME_TAB.Currency] = "TokenFrame",
	[CHARACTER_FRAME_TAB.Statistics] = "StatisticsFrame",
};

local RESISTANCE_STAT_ENTRIES = {
	{ name = _G["DAMAGE_SCHOOL7"], damageClass = Enum.Damageclass.Arcane, atlas = "UI-Character-Info-Resistance-Arcane" },
	{ name = _G["DAMAGE_SCHOOL3"], damageClass = Enum.Damageclass.Fire, atlas = "UI-Character-Info-Resistance-Fire" },
	{ name = _G["DAMAGE_SCHOOL5"], damageClass = Enum.Damageclass.Frost, atlas = "UI-Character-Info-Resistance-Frost" },
	{ name = _G["DAMAGE_SCHOOL4"], damageClass = Enum.Damageclass.Nature, atlas = "UI-Character-Info-Resistance-Nature" },
	{ name = _G["DAMAGE_SCHOOL6"], damageClass = Enum.Damageclass.Shadow, atlas = "UI-Character-Info-Resistance-Shadow" },
};

CharacterFrameMixin = {};

function CharacterFrameMixin:GetTab(tabID)
	if self.ModeTabs and self.ModeTabs.Tabs then
		return self.ModeTabs.Tabs[tabID];
	end

	if self.Tabs then
		return self.Tabs[tabID];
	end

	return _G["CharacterFrameTab"..tabID];
end

--[[
	Boolean flag that identifies this frame as having updated jump hints, no longer
	using legacy FrameControlsManager jump hints only displayed on targets.
	See FrameControlsManager:RefreshJumpHints
]]
CharacterFrameMixin.useFooterJumpHints = true;

-- Text to display next to jump hints on other frames, if the jump takes them here
function CharacterFrameMixin:GetJumpHintLabel()
	return CHARACTER;
end

function CharacterFrameMixin:ToggleTokenFrame()
	if C_CurrencyInfo.GetCurrencyListSize() <= 0 then
		return;
	end

	ToggleCharacter("TokenFrame");
end

function CharacterFrameMixin:ShowSubFrame(frameName)
	-- Set this up front so anything the hide/show below triggers (Collapse/Expand -> RefreshDisplay)
	-- sees the incoming tab rather than the outgoing one.
	self.activeSubframe = frameName;

	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value ~= frameName ) then
			_G[value]:Hide();
		end
	end
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			_G[value]:Show()
		end
	end
end

local CharacterFrameEvents = {
	"UNIT_NAME_UPDATE",
	"PLAYER_PVP_RANK_CHANGED",
	"PLAYER_TALENT_UPDATE",
	"ACTIVE_TALENT_GROUP_CHANGED",
	"UNIT_PORTRAIT_UPDATE",
	"PORTRAITS_UPDATED",
}

function CharacterFrameMixin:OnLoad()
	ButtonFrameTemplate_HideButtonBar(self);
	self:SetTitleMaxLinesAndHeight(1, 13);
	self.Tab = CHARACTER_FRAME_TAB;
	self:SetupModeTabs();

	self:LoadRightPaneCollapsedSetting();

	local _, class = UnitClass("player");
	local atlas = string.format("UI-Character-Info-%s-BG", class);
	CharacterStatsPaneScrollBox.ClassBackground:SetAtlas(atlas, true);

	self:RegisterForTransitions();
	self:SetUIPanelAttribute();
end

function CharacterFrameMixin:UpdateCharacterModeTabPortrait()
	local icon = self.ModeTabs.CharacterTab.Icon;
	SetPortraitTexture(icon, "player");
	icon:SetTexCoord(0.03125, 0.96875, 0.03125, 0.96875);
end

function CharacterFrameMixin:SetupModeTabs()
	if not self.ModeTabs or not self.ModeTabs.Tabs then
		return;
	end

	for index, tab in ipairs(self.ModeTabs.Tabs) do
		tab.frameName = CHARACTER_MODE_TAB_FRAMES[index];
		if index == 4 then
			if UnitFactionGroup("player") == "Alliance" then
				tab.iconTexture = "Interface/ICONS/INV_SideTab_Honor_Alliance_c60";
			else
				tab.iconTexture = "Interface/ICONS/INV_SideTab_Honor_Horde_c60";
			end
		elseif index == 1 then
			tab.iconTexture = nil;
		else
			tab.iconTexture = CHARACTER_MODE_TAB_ICONS[index];
		end

		if index == 1 then
			self:UpdateCharacterModeTabPortrait();
		elseif tab.iconTexture then
			tab.Icon:SetTexture(tab.iconTexture);
		else
			tab.Icon:SetTexture(nil);
		end
	end

	self:SetSelectedModeTabByFrame("PaperDollFrame");
end

function CharacterFrameMixin:UpdateTabLayout()
	if not self.ModeTabs or not self.ModeTabs.Tabs then
		return;
	end

	local previousVisibleTab;
	for _, tab in ipairs(self.ModeTabs.Tabs) do
		tab:ClearAllPoints();
		if tab:IsShown() then
			if previousVisibleTab then
				tab:SetPoint("TOPLEFT", previousVisibleTab, "BOTTOMLEFT", 0, -2);
			else
				tab:SetPoint("TOPLEFT", self.ModeTabs, "TOPLEFT");
			end

			previousVisibleTab = tab;
		end
	end
end

function CharacterFrameMixin:SetSelectedModeTabByFrame(frameName)
	if not self.ModeTabs or not self.ModeTabs.Tabs then
		return;
	end

	for _, tab in ipairs(self.ModeTabs.Tabs) do
		local isSelected = tab.frameName == frameName;
		tab:SetChecked(isSelected);
		if isSelected then
			self.selectedTab = tab:GetID();
		end
	end
end

function CharacterFrameMixin:OnModeTabClicked(tab)
	if not tab.frameName then
		for _, modeTab in ipairs(self.ModeTabs.Tabs) do
			modeTab:SetChecked(modeTab == tab);
		end
		self.selectedTab = tab:GetID();
		return;
	end

	self.selectedTab = tab:GetID();
	ToggleCharacter(tab.frameName, true);
end

function CharacterFrameMixin:UpdatePortrait()
	local useSpecIcon = self.activeSubframe == "PaperDollFrame";
	if useSpecIcon then
		self:SetPortraitToSpecIcon();
		return;
	end

	SetPortraitTexture(self:GetPortrait(), "player");
end

function CharacterFrameMixin:UpdateTitle()
	local displayInfo = characterFrameDisplayInfo[self.activeSubframe] or characterFrameDisplayInfo["Default"];
	self:SetTitleColor(displayInfo.titleColor);
	self:SetTitle(displayInfo.title);
end

function CharacterFrameMixin:UpdateSize()
	local width = self:IsRightPaneCollapsed() and CHARACTER_FRAME_COLLAPSED_WIDTH or CHARACTER_FRAME_WIDTH;
	self:SetSize(width, CHARACTER_FRAME_HEIGHT);
end

function CharacterFrameMixin:RefreshDisplay()
	CharacterFrame:UpdateSize();
	CharacterFrame:UpdatePortrait();
	CharacterFrame:UpdateTitle();
	CharacterFrame:UpdateRightPaneHeader();
	CharacterFrame:SetSelectedModeTabByFrame(CharacterFrame.activeSubframe);
end

local CHARACTER_FRAME_COLLAPSED_CVAR = "characterFrameCollapsed";

function CharacterFrameMixin:IsRightPaneCollapsed()
	return self.rightPaneCollapsed == true;
end

function CharacterFrameMixin:LoadRightPaneCollapsedSetting()
	if self.rightPaneCollapsed ~= nil then
		return;
	end

	self.rightPaneCollapsed = C_CVar.GetCVarBool(CHARACTER_FRAME_COLLAPSED_CVAR) or false;
end

function CharacterFrameMixin:ToggleRightPane()
	self:SetRightPaneCollapsed(not self:IsRightPaneCollapsed());
end

function CharacterFrameMixin:SetRightPaneCollapsed(collapsed)
	if self:IsRightPaneCollapsed() == collapsed then
		return;
	end

	self.rightPaneCollapsed = collapsed;

	PlaySound(collapsed and SOUNDKIT.IG_CHARACTER_INFO_CLOSE or SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	self:RefreshRightPane();
	self:RefreshDisplay();

	UpdateUIPanelPositions(self);
end

function CharacterFrameMixin:RefreshRightPane()
	local collapsed = self:IsRightPaneCollapsed();

	self.RightPaneHost:SetShown(not collapsed);

	for _, pane in ipairs(self.SidePanes or {}) do
		pane:SetShown(not collapsed);
	end

	if PaperDollFrame:IsShown() then
		self:Expand();
	end

	self:UpdateRightPaneToggleButton();
	self:SetUIPanelAttribute();
end

function CharacterFrameMixin:SetUIPanelAttribute()
	local width = self:GetWidth() + CHARACTER_FRAME_WIDTH_PADDING;
	SetUIPanelAttribute(CharacterFrame, "width", width);
end

function CharacterFrameMixin:HidePaperDollRightPane()
	for i = 1, #PAPERDOLL_SIDEBARS do
		GetPaperDollSideBarFrame(i):Hide();
	end

	PaperDollSidebarTabs:Hide();
	PaperDollLevelInfo:Hide();
end

function CharacterFrameMixin:UpdateRightPaneToggleButton()
	local button = self.RightPaneToggleButton;
	if not button then
		return;
	end

	local collapsed = self:IsRightPaneCollapsed();
	button:GetNormalTexture():SetTexture(collapsed and "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up" or "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
	button:GetPushedTexture():SetTexture(collapsed and "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down" or "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
	button.tooltipText = collapsed and CHARACTER_FRAME_SHOW_DETAILS_TOOLTIP or CHARACTER_FRAME_HIDE_DETAILS_TOOLTIP;
end

CharacterFrameRightPaneToggleButtonMixin = {};

function CharacterFrameRightPaneToggleButtonMixin:OnClick()
	CharacterFrame:ToggleRightPane();

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
	end
end

function CharacterFrameRightPaneToggleButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.tooltipText);
	GameTooltip:Show();
end

function CharacterFrameRightPaneToggleButtonMixin:OnLeave()
	GameTooltip_Hide();
end

-- The stone header backs the PaperDoll sidebar tabs, so it should not render on tabs that have none.
function CharacterFrameMixin:UpdateRightPaneHeader()
	self.RightPaneHost.StoneBg:SetShown(self.activeSubframe == "PaperDollFrame");
end

function CharacterFrameMixin:ShouldShowCurrencyTab()
	return true;
end

function CharacterFrameMixin:OnEvent (event, ...)
	if ( not self:IsShown() ) then
		return;
	end

	local arg1 = ...;
	if ( event == "UNIT_NAME_UPDATE" ) then
		if ( arg1 == "player" ) then
			characterFrameDisplayInfo["Default"].title = UnitPVPName("player");
			self:UpdateTitle();
		end
		return;
	elseif ( event == "PLAYER_PVP_RANK_CHANGED" ) then
		characterFrameDisplayInfo["Default"].title = UnitPVPName("player");
		self:UpdateTitle();
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if ( unit == "player" ) then
			self:UpdatePortrait();
			self:UpdateCharacterModeTabPortrait();
		end
	elseif ( event == "PORTRAITS_UPDATED" or event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" ) then
		self:UpdatePortrait();
		self:UpdateCharacterModeTabPortrait();
	end
end

function CharacterFrameMixin:UpdateSmartNavFocus()
	-- Clear the scroll Frame focus in case we are switching between tabs.
	SmartNavigation:SetScrollFrameForFrame(self, nil);

	-- Drop any selection carried over from the previously displayed tab so stale highlights and tooltips don't persist.
	SmartNavigation:ClearLastTarget(self);
	SmartNavigation:SelectButton(nil);

	if self.activeSubframe then
		local subframe = _G[self.activeSubframe];
		if subframe:IsVisible() then
			if subframe.OnSubframeFocus then
				subframe:OnSubframeFocus(self);
			end
		end
	end

	-- Subframes without an OnSubframeFocus handler still need a valid starting selection.
	if not SmartNavigation:GetCurrentButton() then
		SmartNavigation:SelectFirstButton();
	end
end

function CharacterFrameMixin:OnSmartNavFocus()
	self:UpdateSmartNavFocus();

	local isInRepairMode = InRepairMode();
	CharacterFrame.TabIndicators:LockTabs(isInRepairMode);
end

function CharacterFrameMixin:UnfocusGamepad()
	self:UnfocusCharacterView();
	self.TabIndicators:Hide();
	self.leftFooter:HideAndDeactivateBindings();
	self.rightFooter:HideAndDeactivateBindings();
	PaperDollFrame.TabIndicators:Hide();
end

function CharacterFrameMixin:FocusGamepad()
	if (GamepadMode.FrameControlsManager:IsSuspendedFrame(self)) then
		local suspendedButton = GamepadMode.FrameControlsManager:GetSuspendedButton();
		if suspendedButton and suspendedButton.buttonContext == "ButtonContext_GearSetButton" then
			self:SwapToRightSide();
			return;
		end
	end

	if CharacterStatsPanePetScrollBox:IsShown() then
		-- If the pet pane is open, there is no left side.
		self:SwapToRightSide();
	else
		self:SwapToLeftSide();
	end
end

function CharacterFrameMixin:SwapToRightSide()
	-- Hide non-right elements.
	self.leftFooter:HideAndDeactivateBindings();
	self.TabIndicators:Hide();

	-- Show right elements.
	self.rightFooter:ShowAndActivateBindings();
	PaperDollFrame.TabIndicators:Show();
	self.currentFrameFocus = FRAME_FOCUS_RIGHT;
end

function CharacterFrameMixin:SwapToLeftSide()
	-- Hide non-left elements.
	self.rightFooter:HideAndDeactivateBindings();
	PaperDollFrame.TabIndicators:Hide();

	-- Show left elements.
	self.leftFooter:ShowAndActivateBindings();
	self.TabIndicators:Show();
	self.currentFrameFocus = FRAME_FOCUS_LEFT;
end

function CharacterFrameMixin:RefreshFooters()
	if (self.currentFrameFocus == FRAME_FOCUS_LEFT) and self.leftFooter then
		self.leftFooter:Refresh();
	elseif (self.currentFrameFocus == FRAME_FOCUS_RIGHT) and self.rightFooter then
		self.rightFooter:Refresh();
	end
end

function CharacterFrameMixin:FocusCharacterView()
	self.TabIndicators:Hide();
	self.leftFooter:HideAndDeactivateBindings();
	self.rightFooter:HideAndDeactivateBindings();
	PaperDollFrame.TabIndicators:Hide();
	self.oldButton = SmartNavigation:GetCurrentButton();
	SmartNavigation:SuspendCursor(true);
	PaperDollFrame:ShowCharacterViewLegend();
end

function CharacterFrameMixin:UnfocusCharacterView()
	if PaperDollFrame.CharacterViewerFooter.inputLegend:IsShown() then
		PaperDollFrame:HideCharacterViewLegend();
		SmartNavigation:SuspendCursor(false);
		SmartNavigation:ShowCursor(false);
		if self.oldButton then
			SmartNavigation:SelectButton(self.oldButton);
			self.oldButton = nil;
		end
		if self.currentFrameFocus == FRAME_FOCUS_RIGHT then
			self:SwapToRightSide();
		else
			self:SwapToLeftSide();
		end
	end
end

function CharacterFrameMixin:HandleGamepadClose()
	if InRepairMode() then
		MerchantRepairItemButton_OnClick();
		CharacterFrame.TabIndicators:LockTabs(false);
		return true;
	else
		return false;
	end
end

function CharacterFrameMixin:RightSideSwapSmartNavigationJumpOverride()
	--[[
		If no return value is specified, then Smart Nav will use the
		default navigation method to determine the next button to land on.
	]]

	-- When swapping to the equipment manager pane...
	if (PaperDollFrame.EquipmentManagerPane:IsShown()) then
		return PaperDollFrame.EquipmentManagerPane:GetButtonToLandOnWhenCharacterFrameRightSideSwapOccurs();
	end
end

function CharacterFrameMixin:SetupGamepad()
	local function SmartNavJumps()
		-- Handle vertical wrapping for columns.
		SmartNavigation_AddJumpNavigationOverride(CharacterHeadSlot, SMART_NAV_INPUT_DIRECTION.UP, CharacterWristSlot);
		SmartNavigation_AddJumpNavigationOverride(CharacterWristSlot, SMART_NAV_INPUT_DIRECTION.DOWN, CharacterHeadSlot);
		SmartNavigation_AddJumpNavigationOverride(CharacterHandsSlot, SMART_NAV_INPUT_DIRECTION.UP, CharacterTrinket1Slot);
		SmartNavigation_AddJumpNavigationOverride(CharacterTrinket1Slot, SMART_NAV_INPUT_DIRECTION.DOWN, CharacterHandsSlot);

		local halfVerticalEquipmentSlots = (#PaperDollItemsFrame.EquipmentSlots / 2);
		-- Handle the left/right jumps for all but the bottom equipment slots.
		for i = 1, halfVerticalEquipmentSlots - 1, 1 do
			SmartNavigation_AddJumpNavigationOverride(
				PaperDollItemsFrame.EquipmentSlots[i],
				SMART_NAV_INPUT_DIRECTION.RIGHT,
				PaperDollItemsFrame.EquipmentSlots[i + 8]
			);
			SmartNavigation_AddJumpNavigationOverride(
				PaperDollItemsFrame.EquipmentSlots[i + 8],
				SMART_NAV_INPUT_DIRECTION.LEFT,
				PaperDollItemsFrame.EquipmentSlots[i]
			);
		end

		local numWeaponSlots = #PaperDollItemsFrame.WeaponSlots;
		for i = 1, numWeaponSlots, 1 do
			local navigateUpFrame = CharacterWristSlot;
			local navigateDownFrame = CharacterHeadSlot;
			if (i > math.ceil(numWeaponSlots / 2)) then
				navigateUpFrame = CharacterTrinket1Slot;
				navigateDownFrame = CharacterHandsSlot;
			end

			SmartNavigation_AddJumpNavigationOverride(
				PaperDollItemsFrame.WeaponSlots[i],
				SMART_NAV_INPUT_DIRECTION.UP,
				navigateUpFrame
			);
			SmartNavigation_AddJumpNavigationOverride(
				PaperDollItemsFrame.WeaponSlots[i],
				SMART_NAV_INPUT_DIRECTION.DOWN,
				navigateDownFrame
			);
		end
		SmartNavigation_AddJumpNavigationOverride(
			PaperDollItemsFrame.WeaponSlots[1],
			SMART_NAV_INPUT_DIRECTION.LEFT,
			CharacterWristSlot
		);

		local rightmostBottomButton;
		if UnitHasRelicSlot("player") then
			rightmostBottomButton = PaperDollItemsFrame.WeaponSlots[numWeaponSlots];
		else
			rightmostBottomButton = CharacterAmmoSlot;
		end

		SmartNavigation_AddJumpNavigationOverride(
			rightmostBottomButton,
			SMART_NAV_INPUT_DIRECTION.RIGHT,
			CharacterTrinket1Slot
		);

		for i = halfVerticalEquipmentSlots + 1, #PaperDollItemsFrame.EquipmentSlots, 1 do
			SmartNavigation_AddJumpNavigationOverride(
				PaperDollItemsFrame.EquipmentSlots[i],
				SMART_NAV_INPUT_DIRECTION.RIGHT,
				GenerateClosure(CharacterFrameMixin.RightSideSwapSmartNavigationJumpOverride, self)
			);

			-- Handle right side legend swap.
			SmartNavigation_RegisterOutgoingDirNavCallback(
				PaperDollItemsFrame.EquipmentSlots[i],
				SMART_NAV_INPUT_DIRECTION.RIGHT,
				GenerateClosure(CharacterFrameMixin.SwapToRightSide, self)
			);
		end

		-- Ignore the Character Model Scene for smart navigation.
		SmartNavigation_MarkFrameIgnoredContainerFrame(CharacterModelScene);
		SmartNavigation_MarkFrameIgnored(CharacterModelScene.ControlFrame);

		-- Ignore the tab buttons that will be navigated by bumpers.
		SmartNavigation_MarkFrameIgnored(PaperDollSidebarTabs);

		-- Ignore the scollbars as landing spots for smart navigation.
		SmartNavigation_MarkFrameIgnored(PaperDollFrame.EquipmentManagerPane.ScrollBar);
		SmartNavigation_MarkFrameIgnored(CharacterStatsPanePetScrollBox.ScrollBar);
		SmartNavigation_MarkFrameIgnored(CharacterStatsPaneScrollBox.ScrollBar);
		SmartNavigation_MarkFrameIgnored(ReputationFrame.ScrollBar);
		SmartNavigation:SetScrollFrameForFrame(self, CharacterStatsPaneScrollBox.ScrollBox);
		GamepadScrollBarHint:SetOwner(CharacterStatsPaneScrollBox.ScrollBar.Track.Thumb, "CENTER");
		GamepadScrollBarHint:Show();

		SmartNavigation_MarkFrameFocusable(PetPaperDollPetHappinessInfo);
	end

	local function SetUpLegend()
		local LEGEND_VERTICAL_OFFSET = -12;

		self.leftFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "CharacterLeftFooter");
		self.leftFooter:SetAnchorOffsets(0, LEGEND_VERTICAL_OFFSET);
		self.leftFooter:AddPromptedBindings(PaperDollFrame:CreateGamepadPromptedBindings());
		self.leftFooter:AddNonFallbackSelectPrompt();
		self.leftFooter:AddStandardFrameControlManagerBindings(self);
		self.leftFooter:AddStandardBackPrompt(FRAME_ACTION_CLOSE);
		self.leftFooter:Finalize();

		self.rightFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "CharacterRightFooter");
		self.rightFooter:SetAnchorOffsets(0, LEGEND_VERTICAL_OFFSET);
		self.rightFooter:AddPromptedBindings(PaperDollFrame.EquipmentManagerPane:CreateGamepadPromptedBindings());
		self.rightFooter:AddNonFallbackSelectPrompt();
		self.rightFooter:AddStandardFrameControlManagerBindings(self);
		self.rightFooter:AddStandardBackPrompt(FRAME_ACTION_CLOSE);
		self.rightFooter:Finalize();
	end

	local function SetUpTabs()
		CharacterFrame.TabIndicators:SetUpTabs(CharacterFrame.ModeTabs.Tabs);
		local reverse = true;
		PaperDollFrame.TabIndicators:SetUpTabs(PaperDollSidebarTabs.Tabs, reverse);
	end

	local function PostLoadSetup()
		SmartNavJumps();
		SetUpLegend();
		SetUpTabs();
	end

	-- Set the smart nav close handler to deactivate the single item repair state before closing the frame.
	self.SmartNavigationCloseHandler = self.HandleGamepadClose;

	EventUtil.ContinueOnAddOnLoaded("Blizzard_UIPanels_Game", PostLoadSetup);

	SmartNavigation:SetSmartNavPanelInfoAddedCallback(self, function()
		local function GetFirstEnchantableSlot(container)
			for _, slot in ipairs(container) do
				local location = slot:GetItemLocation();
				if location and location:IsValid() and C_Item.DoesItemMatchTargetEnchantingSpell(location) then
					return slot;
				end
			end
		end

		local isPaperDollTab = self.selectedTab == self.Tab.Character;
		local isEnchanting = ItemButtonUtil.GetItemContext() == ItemButtonUtil.ItemContextEnum.Enchanting;
		if isPaperDollTab and isEnchanting then
			local firstSlot = GetFirstEnchantableSlot(PaperDollFrame.ItemsFrame.EquipmentSlots)
				or GetFirstEnchantableSlot(PaperDollFrame.ItemsFrame.WeaponSlots);
			if firstSlot then
				SmartNavigation:SetTargetButtonForFrame(self, firstSlot);
			end
		end
	end);
end

function CharacterFrameMixin:InitializeGamepad()
	CharacterFrameCloseButton:Hide();

	self:UpdateSmartNavFocus();
end

function CharacterFrameMixin:UninitializeGamepad()
	CharacterFrameCloseButton:Show();
end

function CharacterFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

local function ShouldShowExaltedPlusHelpTip()
	if (GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_REPUTATION_EXALTED_PLUS)) then
		return false;
	end

	local numFactions = C_Reputation.GetNumFactions();
	for i=1, numFactions do
		local factionData = C_Reputation.GetFactionDataByIndex(i);
		if (factionData and C_Reputation.IsFactionParagonForCurrentPlayer(factionData.factionID) ) then
			return true;
		end
	end
	return false;
end

function CharacterFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CharacterFrameEvents);
	characterFrameDisplayInfo["Default"].title = UnitPVPName("player");
	self:UpdateCharacterModeTabPortrait();
	self:RefreshRightPane();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	UpdateMicroButtons();

	local playerFrameHealthBar = PlayerFrame_GetHealthBar();
	local playerFrameManaBar = PlayerFrame_GetManaBar();
	local playerFrameAlternatePowerBar = PlayerFrame_GetAlternatePowerBar();
	playerFrameHealthBar.showNumeric = true;
	playerFrameManaBar.showNumeric = true;
	if playerFrameAlternatePowerBar then
		playerFrameAlternatePowerBar.showNumeric = true;
	end
	PetFrameHealthBar.showNumeric = true;
	PetFrameManaBar.showNumeric = true;
	playerFrameHealthBar:ShowStatusBarText();
	playerFrameManaBar:ShowStatusBarText();
	if playerFrameAlternatePowerBar then
		playerFrameAlternatePowerBar:ShowStatusBarText();
	end
	PetFrameHealthBar:ShowStatusBarText();
	PetFrameManaBar:ShowStatusBarText();
	StatusTrackingBarManager:SetTextLocked(true);

	if ShouldShowExaltedPlusHelpTip() then
		local helpTipInfo = {
			text = REPUTATION_EXALTED_PLUS_HELP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_REPUTATION_EXALTED_PLUS,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			offsetY = 8,
		};
		HelpTip:Show(self, helpTipInfo, CharacterFrameModeTab2);
	end

	MicroButtonPulseStop(CharacterMicroButton);	--Stop the button pulse
	EventRegistry:TriggerEvent("CharacterFrame.Show");

	if (InputUtil.IsGamepadUIEnabled()) then
		self:SwapToLeftSide();
	end
end

function CharacterFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CharacterFrameEvents);

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();

	local playerFrameHealthBar = PlayerFrame_GetHealthBar();
	local playerFrameManaBar = PlayerFrame_GetManaBar();
	local playerFrameAlternatePowerBar = PlayerFrame_GetAlternatePowerBar();
	playerFrameHealthBar.showNumeric = nil;
	playerFrameManaBar.showNumeric = nil;
	if playerFrameAlternatePowerBar then
		playerFrameAlternatePowerBar.showNumeric = nil;
	end
	PetFrameHealthBar.showNumeric = nil;
	PetFrameManaBar.showNumeric = nil;
	playerFrameHealthBar:HideStatusBarText();
	playerFrameManaBar:HideStatusBarText();
	if playerFrameAlternatePowerBar then
		playerFrameAlternatePowerBar:HideStatusBarText();
	end
	PetFrameHealthBar:HideStatusBarText();
	PetFrameManaBar:HideStatusBarText();
	StatusTrackingBarManager:SetTextLocked(false);
	PaperDollFrame.currentSideBar = nil;
	EventRegistry:TriggerEvent("CharacterFrame.Hide");

	if InputUtil.IsGamepadUIEnabled() and ContainerFrameCombinedBags:IsShown() then
		ContainerFrameCombinedBags:Hide();
	end
end

function CharacterFrameMixin:Collapse()
	self.Expanded = false;
	for i = 1, #PAPERDOLL_SIDEBARS do
		GetPaperDollSideBarFrame(i):Hide();
	end
	PaperDollFrame_SetLevel();
	self:RefreshDisplay();
end

function CharacterFrameMixin:Expand()
	self.Expanded = true;

	if self:IsRightPaneCollapsed() then
		self:HidePaperDollRightPane();
	else
		PaperDollSidebarTabs:Show();
		PaperDollLevelInfo:Show();

		if (PaperDollFrame:IsShown() and PaperDollFrame.currentSideBar) then
			PaperDollFrame.currentSideBar:Show();
		else
			self:GetStatsPane():Show();
		end
		PaperDollFrame_UpdateSidebarTabs();
	end

	PaperDollFrame_SetLevel();
	self:RefreshDisplay();
end

function CharacterFrameMixin:GetStatsPane()
	return CharacterStatsPaneScrollBox;
end

CharacterFrameSidePaneMixin = {};

function CharacterFrameSidePaneMixin:OnLoad()
	ScrollUtil.RegisterScrollBoxWithScrollBar(self.Description:GetScrollBox(), self.DescriptionScrollBar);

	CharacterFrame.SidePanes = CharacterFrame.SidePanes or {};
	table.insert(CharacterFrame.SidePanes, self);
	self:SetShown(not CharacterFrame:IsRightPaneCollapsed());

	self.rowPools = CreateFramePoolCollection();
	self.rowPools:CreatePool("FRAME", self.Content, "CharacterFrameSidePaneRowTemplate");
	self.rowPools:CreatePool("FRAME", self.Content, "CharacterFrameSidePaneWrappedRowTemplate");
	self.rowPools:CreatePool("FRAME", self.Content, "CharacterFrameSidePaneIconRowTemplate");
	self.rowPools:CreatePool("FRAME", self.Content, "CharacterFrameSidePaneCategoryTemplate");

	self.layoutIndex = 0;
end

function CharacterFrameSidePaneMixin:SetPaneTitle(title, subtitle)
	self.Title:SetText(title or "");
	self.Subtitle:SetText(subtitle or "");
	self.Subtitle:SetShown(subtitle ~= nil and subtitle ~= "");
end

function CharacterFrameSidePaneMixin:SetPaneTitleColor(titleColor, subtitleColor)
	if titleColor then
		self.Title:SetVertexColor(titleColor:GetRGB());
	end
	if subtitleColor then
		self.Subtitle:SetVertexColor(subtitleColor:GetRGB());
	end
end

function CharacterFrameSidePaneMixin:SetDescription(description, height, color)
	local hasDescription = description ~= nil and description ~= "";
	self.Description:SetShown(hasDescription);
	self.Description:SetTextColor(color or WHITE_FONT_COLOR);
	self.DescriptionScrollBar:SetShown(hasDescription);

	if hasDescription then
		self.Description:SetHeight(height or 90);
		self.Description:SetText(description);
	else
		self.Description:SetHeight(1);
	end
end

function CharacterFrameSidePaneMixin:ResetRows()
	self.rowPools:ReleaseAll();
	self.layoutIndex = 0;
end

function CharacterFrameSidePaneMixin:AcquireRow(template)
	local row = self.rowPools:Acquire(template);
	self.layoutIndex = self.layoutIndex + 1;
	row.layoutIndex = self.layoutIndex;
	row:Show();
	return row;
end

function CharacterFrameSidePaneMixin:AddRow(label, value, labelColor, valueColor)
	local row = self:AcquireRow("CharacterFrameSidePaneRowTemplate");
	row.Label:SetText(label or "");
	row.Label:SetTextColor((labelColor or NORMAL_FONT_COLOR):GetRGB());
	row.Value:SetText(value or "");
	row.Value:SetTextColor((valueColor or HIGHLIGHT_FONT_COLOR):GetRGB());
	return row;
end

function CharacterFrameSidePaneMixin:AddWrappedRow(text, color)
	local row = self:AcquireRow("CharacterFrameSidePaneWrappedRowTemplate");
	row.Label:SetText(text or "");
	row.Label:SetTextColor((color or NORMAL_FONT_COLOR):GetRGB());

	row:SetHeight(math.max(1, row.Label:GetStringHeight()));
	return row;
end

function CharacterFrameSidePaneMixin:AddIconRow(icon, text, color)
	local hasIcon = icon ~= nil and icon ~= 0;
	if not hasIcon then
		return self:AddWrappedRow(text, color);
	end

	local row = self:AcquireRow("CharacterFrameSidePaneIconRowTemplate");
	row.Icon:SetTexture(icon);
	row.Label:SetText(text or "");
	row.Label:SetTextColor((color or NORMAL_FONT_COLOR):GetRGB());

	row:SetHeight(math.max(row.IconSlot:GetHeight(), row.Label:GetStringHeight()));
	return row;
end

function CharacterFrameSidePaneMixin:AddCategory(text)
	local row = self:AcquireRow("CharacterFrameSidePaneCategoryTemplate");
	row.Label:SetText(text or "");
	return row;
end

function CharacterFrameSidePaneMixin:AddSpacer(height)
	local row = self:AcquireRow("CharacterFrameSidePaneWrappedRowTemplate");
	row.Label:SetText("");
	row:SetHeight(height or 8);
	return row;
end

function CharacterFrameSidePaneMixin:LayoutRows()
	self.Content:Layout();
end

function CharacterFrameSidePaneMixin:SetEmpty(emptyText)
	self:ResetRows();
	self:LayoutRows();
	self:SetPaneTitle(nil, nil);
	self:SetDescription(nil);
	self.Divider:Hide();
	self.Footer:Hide();
	self.EmptyText:SetText(emptyText or "");
	self.EmptyText:Show();
end

function CharacterFrameSidePaneMixin:ClearEmpty()
	self.EmptyText:Hide();
	self.Divider:Show();
	self.Footer:Show();
end

CharacterModeTabButtonMixin = CreateFromMixins(SidePanelTabButtonMixin);

function CharacterModeTabButtonMixin:OnLoad()
	SidePanelTabButtonMixin.OnLoad(self);

	self:SetCustomOnMouseUpHandler(function(tab, button, upInside)
		if button == "LeftButton" and upInside then
			CharacterFrame:OnModeTabClicked(self);
		end
	end);
end

GearEnchantAnimationMixin = {}

local GearEnchantAnimationEvents = {
	"ENCHANT_SPELL_COMPLETED",
};

function GearEnchantAnimationMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, GearEnchantAnimationEvents);

	local function GearEnchantFXAnimOnFinished()
		self.FrameFX:Hide();
	end
	self.FrameFX.FrameFXAnimGroup:SetScript("OnFinished", GearEnchantFXAnimOnFinished);

	local function GearEnchantTopFrameAnimOnFinished()
		self.TopFrame:Hide();
	end
	self.TopFrame.TopFrameAnimGroup:SetScript("OnFinished", GearEnchantTopFrameAnimOnFinished)
end

function GearEnchantAnimationMixin:OnEvent(event, ...)
	if event == "ENCHANT_SPELL_COMPLETED" then
		local successful, enchantedItem = ...;

		if successful and enchantedItem and enchantedItem:IsValid() and enchantedItem:IsEquipmentSlot() then
			self:PlayAndShow();
		end
	end
end

function GearEnchantAnimationMixin:PlayAndShow()
	self:Show();

	self.FrameFX:Show();
	self.FrameFX.FrameFXAnimGroup:Play();

	self.TopFrame:Show();
	self.TopFrame.TopFrameAnimGroup:Play();
end

function GearEnchantAnimationMixin:StopAndHide()
	self.FrameFX.FrameFXAnimGroup:Stop();
	self.TopFrame.TopFrameAnimGroup:Stop();

	self:Hide();
end

CharacterStatFrameCategoryMixin = {};

function CharacterStatFrameCategoryMixin:OnLoad()
	self.Title:SetText(self.titleText);
end

CharacterStatFrameMixin = {};

function CharacterStatFrameMixin:OnLoad()
	if (STATFRAME_STATTEXT_FONT_OVERRIDE) then
		self.Value:SetFontObject(STATFRAME_STATTEXT_FONT_OVERRIDE);
	end
end


function CharacterStatFrameMixin:OnEnter()
	if ( self.onEnterFunc ) then
		self:onEnterFunc();
	else
		PaperDollStatTooltip(self);
	end
end

CharacterStatsPaneScrollBoxBaseMixin = {};

function CharacterStatsPaneScrollBoxBaseMixin:OnLoad()
	self.ScrollBox:SetEdgeFadeLength(45);
end

CharacterStatsPaneScrollBoxMixin = {};

function CharacterStatsPaneScrollBoxMixin:OnLoad()
	CharacterStatsPaneScrollBoxBaseMixin.OnLoad(self);

	local function Initializer(button, elementData)
		button:Init(elementData);
		if (InputUtil.IsGamepadUIEnabled() and not elementData.isHeader) then
			SmartNavigation_MarkFrameFocusable(button);
			self:SetUpGamepadNavigation(button);
		end
	end

	local spacing = 0;
	local bottomPadding = 8;
	local view = CreateScrollBoxListLinearView(0, bottomPadding, 0, 0, spacing);
	view:SetElementFactory(function(factory, elementData)
		if elementData.isHeader then
			factory("CharacterStatFrameCategoryScrollBoxElementTemplate", Initializer);
		elseif elementData.texture or elementData.atlas then
			factory("CharacterStatFrameScrollBoxIconElementTemplate", Initializer);
		else
			factory("CharacterStatFrameScrollBoxLabelElementTemplate", Initializer);
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.elementData = {};
	self.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnUpdate, GenerateClosure(self.ScrollBoxOnUpdate, self));
end

function CharacterStatsPaneScrollBoxMixin:ScrollBoxOnUpdate()
	self:HideElements();
end

function CharacterStatsPaneScrollBoxMixin:HideElements()
	local changed = false;
	for i = #self.elementData, 1, -1 do
		local elementData = self.elementData[i];

		if (elementData.shouldRemove) then
			changed = true;
			table.remove(self.elementData, i);
		end
	end

	if changed then
		self.ScrollBox:SetDataProvider(CreateDataProvider(self.elementData), ScrollBoxConstants.RetainScrollPosition);
	end
end

function CharacterStatsPaneScrollBoxMixin:SetUpGamepadNavigation(button)
	SmartNavigation_RegisterOutgoingDirNavCallback(
		button,
		SMART_NAV_INPUT_DIRECTION.LEFT,
		GenerateClosure(CharacterFrameMixin.SwapToLeftSide, CharacterFrame)
	);
end

function CharacterStatsPaneScrollBoxMixin:UpdateStats()
	local spec, role;
	spec = C_SpecializationInfo.GetSpecialization();
	if spec then
		role = GetSpecializationRoleEnum(spec);
	end

	self.elementData = {};

	for catIndex = 1, #PAPERDOLL_STATCATEGORIES do
		local skipCategory = false;

		if PAPERDOLL_STATCATEGORIES[catIndex].unit and PAPERDOLL_STATCATEGORIES[catIndex].unit ~= self:GetUnit() then
			skipCategory = true;
		end

		if not skipCategory then
			local catFrame = CharacterStatsPane[PAPERDOLL_STATCATEGORIES[catIndex].categoryFrame];
			local numStatInCat = 0;
			local statsForCategory = {};
			for statIndex = 1, #PAPERDOLL_STATCATEGORIES[catIndex].stats do
				local stat = PAPERDOLL_STATCATEGORIES[catIndex].stats[statIndex];
				local showStat = true;
				if ( showStat and stat.primary and spec ) then
					local primaryStat = select(6, C_SpecializationInfo.GetSpecializationInfo(spec, false, false, nil, UnitSex("player")));
					if ( stat.primary ~= primaryStat ) then
						showStat = false;
					end
				end
				if ( showStat and stat.roles ) then
					local foundRole = false;
					for _, statRole in pairs(stat.roles) do
						if ( role == statRole ) then
							foundRole = true;
							break;
						end
					end
					showStat = foundRole;
				end
				if (showStat and stat.unit) then
					showStat = stat.unit == self:GetUnit();
				end

				if ( showStat and stat.showFunc ) then
					showStat = stat.showFunc();
				end
				if ( showStat ) then
						tinsert(statsForCategory, stat);
						numStatInCat = numStatInCat + 1;
				end
			end


			-- We need this to calculate stats
			local statFrame = CharacterStatsPane.statsFramePool:Acquire();

			if numStatInCat > 0 then
				local headerData = {};
				headerData.isHeader = true;
				headerData.name = PAPERDOLL_STATCATEGORIES[catIndex].categoryName;
				tinsert(self.elementData, headerData);
				local actualIndex = 1;
				for i, stat in ipairs(statsForCategory) do
					local statData = {
						isHeader = false;
						unit = self:GetUnit();
						name = stat.stat;
						id = stat.id;
						statIndex = actualIndex;
						texture = stat.texture;
						textureCoordL = stat.textureCoordL;
						textureCoordR = stat.textureCoordR;
						textureCoordT = stat.textureCoordT;
						textureCoordB = stat.textureCoordB;
						hideAt = stat.hideAt;
					};
					local numericValue = PAPERDOLL_STATINFO[statData.name].updateFunc(statFrame, statData.unit, statData.id);

					if numericValue ~= statData.hideAt then
						tinsert(self.elementData, statData);
						actualIndex = actualIndex + 1;
					end
				end
			end

			CharacterStatsPane.statsFramePool:Release(statFrame);
		end
	end

	local unit = self:GetUnit();
	if unit == "player" or unit == "pet" then
		local headerData = {
			isHeader = true,
			name = _G["STAT_CATEGORY_RESISTANCE"],
		};
		tinsert(self.elementData, headerData);

		for statIndex, resistanceData in ipairs(RESISTANCE_STAT_ENTRIES) do
			local _baseResistance, effectiveResistance = UnitResistance(unit, resistanceData.damageClass);
			local tooltipData = {};
			PaperDollFrame_SetResistanceTooltips(tooltipData, resistanceData.name, effectiveResistance, unit, resistanceData.damageClass);

			local statData = {
				isHeader = false,
				statIndex = statIndex,
				atlas = resistanceData.atlas,
				labelText = resistanceData.name,
				valueText = BreakUpLargeNumbers(effectiveResistance),
				numericValue = effectiveResistance,
				tooltip = tooltipData.tooltip,
				tooltip2 = tooltipData.tooltip2,
				tooltip3 = tooltipData.tooltip3,
			};

			tinsert(self.elementData, statData);
		end
	end

	self.ScrollBox:SetDataProvider(CreateDataProvider(self.elementData), ScrollBoxConstants.RetainScrollPosition);
end

function CharacterStatsPaneScrollBoxMixin:GetUnit()
	return "player";
end


CharacterStatFrameCategoryScrollBoxElementMixin = {};

function CharacterStatFrameCategoryScrollBoxElementMixin:Init(elementData)
	self.Title:SetText(elementData.name);
end

CharacterStatFrameScrollBoxBaseElementMixin = CreateFromMixins(CharacterStatFrameMixin);

function CharacterStatFrameScrollBoxBaseElementMixin:Init(elementData)
	self.onEnterFunc = nil;
	self.UpdateTooltip = nil;
	self.tooltip = elementData.tooltip;
	self.tooltip2 = elementData.tooltip2;
	self.tooltip3 = elementData.tooltip3;
	self.numericValue = nil;

	self.Background:SetShown((elementData.statIndex % 2) == 1);
	if self.Icon then
		self.Icon:Hide();
	end

	if elementData.labelText then
		self.Label:SetText(format(STAT_FORMAT, elementData.labelText));
	end

	if elementData.valueText then
		self.Value:SetText(elementData.valueText);
	end

	if elementData.numericValue ~= nil then
		self.numericValue = elementData.numericValue;
	end

	if not elementData.name or not PAPERDOLL_STATINFO[elementData.name] then
		return;
	end

	local numericValue = PAPERDOLL_STATINFO[elementData.name].updateFunc(self, elementData.unit, elementData.id);

	if elementData.hideAt and numericValue == elementData.hideAt then
		elementData.shouldRemove = true;
	end

	self.numericValue = numericValue;
end

CharacterStatFrameScrollBoxIconElementMixin = CreateFromMixins(CharacterStatFrameScrollBoxBaseElementMixin);

function CharacterStatFrameScrollBoxIconElementMixin:Init(elementData)
	CharacterStatFrameScrollBoxBaseElementMixin.Init(self, elementData);

	if elementData.texture then
		self.Icon:SetTexture(elementData.texture);
		if elementData.textureCoordL and elementData.textureCoordR and elementData.textureCoordT and elementData.textureCoordB then
			self.Icon:SetTexCoord(elementData.textureCoordL, elementData.textureCoordR, elementData.textureCoordT, elementData.textureCoordB);
		else
			self.Icon:SetTexCoord(0, 1, 0, 1);
		end

		self.Icon:Show();
	elseif elementData.atlas then
		self.Icon:SetAtlas(elementData.atlas, TextureKitConstants.UseAtlasSize);
		self.Icon:SetTexCoord(0, 1, 0, 1);
		self.Icon:Show();
	end
end

CharacterStatsPanePetScrollBoxMixin = CreateFromMixins(CharacterStatsPaneScrollBoxMixin);

function CharacterStatsPanePetScrollBoxMixin:GetUnit()
	return "pet";
end

function CharacterStatsPanePetScrollBoxMixin:SetUpGamepadNavigation(button)
	SmartNavigation_AddJumpNavigationOverride(
		button,
		SMART_NAV_INPUT_DIRECTION.LEFT,
		PetPaperDollPetHappinessInfo
	);
end
