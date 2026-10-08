local ALLIANCE_TAB_TEXTURE = "Interface/ICONS/INV_SideTab_Honor_Alliance_c60";
local HORDE_TAB_TEXTURE = "Interface/ICONS/INV_SideTab_Honor_Horde_c60";
local GUILD_TAB_TEXTURE = "Interface/ICONS/INV_Shirt_GuildTabard_01";

local INSPECT_MODE_TAB_INDEX_CHARACTER = 1;
local INSPECT_MODE_TAB_INDEX_PVP = 2;
local INSPECT_MODE_TAB_INDEX_GUILD = 3;

UIPanelWindows["InspectFrame"] = { area = "left", pushable = 0, };

INSPECTFRAME_SUBFRAMES = { "InspectPaperDollFrame", "InspectPVPFrame", "InspectGuildFrame" };

INSPECTPAPERDOLLFRAME_SLOTS = {
	"InspectHeadSlot",
	"InspectNeckSlot",
	"InspectShoulderSlot",
	"InspectBackSlot",
	"InspectChestSlot",
	"InspectShirtSlot",
	"InspectTabardSlot",
	"InspectWristSlot",
	"InspectHandsSlot",
	"InspectWaistSlot",
	"InspectLegsSlot",
	"InspectFeetSlot",
	"InspectFinger0Slot",
	"InspectFinger1Slot",
	"InspectTrinket0Slot",
	"InspectTrinket1Slot",
	"InspectMainHandSlot",
	"InspectSecondaryHandSlot",
	"InspectRangedSlot",
};

InspectFrameMixin = {};

function InspectFrameMixin:GetInspectUnit()
	return self.unit;
end

function InspectFrame_Show(unit)
	HideUIPanel(InspectFrame);
	if CanInspect(unit, true) then
		NotifyInspect(unit);
		InspectFrame.unit = unit;
		InspectSwitchTabs(INSPECT_MODE_TAB_INDEX_CHARACTER);
	else
		InspectFrame.unit = nil;
	end
end

function InspectFrameMixin:OnLoad()
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("INSPECT_READY");
	self.unit = nil;

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, #INSPECTFRAME_SUBFRAMES);
	PanelTemplates_SetTab(self, INSPECT_MODE_TAB_INDEX_CHARACTER);
	self:GetTitleText():SetFontObject("GameFontHighlight");

	self:InitializeModeTabs();
	self:InitializeModeTabLayout();
	self:RegisterForTransitions();
end

function InspectFrameMixin:InitializeModeTabLayout()
	local previousTab;
	for _, tab in ipairs(self.ModeTabs.Tabs) do
		tab:ClearAllPoints();
		if tab:IsShown() then
			if previousTab then
				tab:SetPoint("TOPLEFT", previousTab, "BOTTOMLEFT");
			else
				tab:SetPoint("TOPLEFT", self.ModeTabs, "TOPLEFT");
			end

			previousTab = tab;
		end
	end
end

function InspectFrameMixin:OnEvent(event, ...)
	if event == "INSPECT_READY" then
		local unit = ...;
		local inspectUnit = self:GetInspectUnit();
		if inspectUnit and UnitGUID(inspectUnit) == unit then
			self:SetupModeTabsForUnit(inspectUnit);
			self:UpdateInspectHeaderForUnit(inspectUnit);
			ShowUIPanel(InspectFrame);
			self:UpdateTabs(self);
		end
	end

	if not self:IsShown() then
		return;
	end

	if event == "PLAYER_TARGET_CHANGED" or event == "GROUP_ROSTER_UPDATE" then
		if event == "PLAYER_TARGET_CHANGED" and self.unit == "target" or
			event == "GROUP_ROSTER_UPDATE" and self.unit ~= "target" then
			-- Just hide the InspectFrame when the unit changes.  This hides the bug that occurs when you click on targets too quickly and the server drops the inspect data when flooded with inspect requests.
			HideUIPanel(InspectFrame);
		end
	elseif event == "UNIT_NAME_UPDATE" then
		local unit = ...;
		if unit == self.unit then
			InspectFrame:SetTitle(GetUnitName(self.unit, true));
		end
	elseif event == "UNIT_PORTRAIT_UPDATE" then
		local unit = ...;
		if unit == self.unit then
			SetPortraitTexture(InspectFramePortrait, self.unit);
		end
	elseif event == "PORTRAITS_UPDATED" then
		SetPortraitTexture(InspectFramePortrait, self.unit);
	end
end

function InspectFrameMixin:UnitChanged()
	local unit = self.unit;
	NotifyInspect(unit);
	InspectPaperDollFrame_OnShow();
	self:UpdateInspectHeaderForUnit(unit);
	self:UpdateTabs();
	if InspectPVPFrame:IsShown() then
		InspectPVPFrame_OnShow();
	end
end

function InspectFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function InspectFrameMixin:UpdateInspectHeaderForUnit(unitToken)
	InspectFrame:SetPortraitToUnit(unitToken);
	InspectFrame:SetTitle(GetUnitName(unitToken, true));
end

function InspectFrameMixin:OnHide()
	self.unit = nil;
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

	-- Clear the player being inspected
	if not PlayerSpellsFrame or not PlayerSpellsFrame:IsInspecting() then
		ClearInspectPlayer();
	end
end

function InspectSwitchTabs(newID)
	local newFrame = _G[INSPECTFRAME_SUBFRAMES[newID]];
	local oldFrame = _G[INSPECTFRAME_SUBFRAMES[PanelTemplates_GetSelectedTab(InspectFrame)]];
	oldFrame:Hide();
	PanelTemplates_SetTab(InspectFrame, newID);
	newFrame:Show();

	InspectFrame:SetSelectedModeTabByID(newID);
end

function InspectFrameTab_OnClick(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	InspectSwitchTabs(self:GetID());
end

function InspectFrameMixin:UpdateTabs()
	local inspectUnit = self:GetInspectUnit();
	if not inspectUnit then
		return;
	end

	local _, _, guildName = C_PaperDollInfo.GetInspectGuildInfo(inspectUnit);
	local hasGuild = guildName and guildName ~= "";
	local guildTabIndex = INSPECT_MODE_TAB_INDEX_GUILD;

	if hasGuild then
		PanelTemplates_EnableTab(InspectFrame, guildTabIndex);
	else
		PanelTemplates_DisableTab(InspectFrame, guildTabIndex);
		if PanelTemplates_GetSelectedTab(InspectFrame) == guildTabIndex then
			InspectSwitchTabs(INSPECT_MODE_TAB_INDEX_CHARACTER);
		end
	end

	self.ModeTabs.GuildTab:SetShown(hasGuild);

end

function InspectFrameMixin:UpdateCharacterModeTabPortrait(unitToken)
	local icon = self.ModeTabs.CharacterTab.Icon;
	SetPortraitTexture(icon, unitToken);
	icon:SetTexCoord(0.03125, 0.96875, 0.03125, 0.96875);
end

function InspectFrameMixin:GetPVPModeTabTexture(factionGroup)
	if factionGroup == "Alliance" then
		return ALLIANCE_TAB_TEXTURE;
	end

	return HORDE_TAB_TEXTURE;
end

function InspectFrameMixin:SetSelectedModeTabByID(tabID)
	for _, tab in ipairs(self.ModeTabs.Tabs) do
		local isSelected = tab:GetID() == tabID;
		tab:SetChecked(isSelected);
		if isSelected then
			self.selectedTab = tab:GetID();
		end
	end

	if InputUtil.IsGamepadUIEnabled() then
		local paperDollTabIndex = 1;
		if self.selectedTab == paperDollTabIndex then
			SmartNavigation:SuspendCursor(false);
			if not SmartNavigation:GetCurrentButton() then
				SmartNavigation:SelectFirstButton();
			end
		else
			SmartNavigation:SuspendCursor(true);
			SmartNavigation:ClearLastTarget(self);
			SmartNavigation:SelectButton(nil);
		end
	end
end

function InspectFrameMixin:InitializeModeTabs()
	self:SetSelectedModeTabByID(INSPECT_MODE_TAB_INDEX_CHARACTER);
end

function InspectFrameMixin:SetupModeTabs(unitToken, pvpModeTabIconTexture)
	for index, tab in ipairs(self.ModeTabs.Tabs) do
		if index == INSPECT_MODE_TAB_INDEX_CHARACTER then
			self:UpdateCharacterModeTabPortrait(unitToken);
		elseif index == INSPECT_MODE_TAB_INDEX_PVP then
			tab.Icon:SetTexture(pvpModeTabIconTexture);
		else
			tab.Icon:SetTexture(GUILD_TAB_TEXTURE);
		end
	end

	local selectedTabID = PanelTemplates_GetSelectedTab(self) or INSPECT_MODE_TAB_INDEX_CHARACTER;
	self:SetSelectedModeTabByID(selectedTabID);
end

function InspectFrameMixin:SetupModeTabsForUnit(unitToken)
	local factionGroup = UnitFactionGroup(unitToken);
	local pvpModeTabIconTexture = self:GetPVPModeTabTexture(factionGroup);
	self:SetupModeTabs(unitToken, pvpModeTabIconTexture);
end

InspectTabButtonMixin = CreateFromMixins(SidePanelTabButtonMixin);

function InspectTabButtonMixin:OnLoad()
	SidePanelTabButtonMixin.OnLoad(self);

	self:SetCustomOnMouseUpHandler(function(tab, button, upInside)
		if button == "LeftButton" and upInside then
			InspectSwitchTabs(self:GetID());
		end
	end);
end

function InspectFrameMixin:CanShowDressingRoom()
	local inspectUnit = self:GetInspectUnit();
	if not inspectUnit then
		return false;
	end

	local paperDollButton = SmartNavigation:GetCurrentButton();
	if not paperDollButton then
		return false;
	end

	local itemLink = GetInventoryItemLink(inspectUnit, paperDollButton:GetID());
	return itemLink ~= nil;
end

function InspectFrameMixin:OnGamepadOpenDressingRoom()
	local paperDollButton = SmartNavigation:GetCurrentButton();
	local inspectUnit = self:GetInspectUnit();
	local itemLink = GetInventoryItemLink(inspectUnit, paperDollButton:GetID());
	DressUpLink(itemLink);
end

function InspectFrameMixin:FocusGamepad()
	self.TabIndicators:Show();
	self.frameFooter:ShowAndActivateBindings();

	InspectPaperDollFrame:FocusGamepad();
end

function InspectFrameMixin:UnfocusGamepad()
	self.TabIndicators:Hide();
	self.frameFooter:HideAndDeactivateBindings();

	InspectPaperDollFrame:UnfocusGamepad();
end

function InspectFrameMixin:SetupGamepad()
	local function SmartNavJumps()
		-- Handle vertical wrapping for columns.
		SmartNavigation_AddBidirectionalJumpNavigationOverride(InspectHeadSlot, SMART_NAV_INPUT_DIRECTION.UP, InspectWristSlot);
		SmartNavigation_AddBidirectionalJumpNavigationOverride(InspectHandsSlot, SMART_NAV_INPUT_DIRECTION.UP, InspectTrinket1Slot);

		local numSlotsToMap = math.min(#InspectPaperDollItemsFrame.LeftEquipmentSlots, #InspectPaperDollItemsFrame.RightEquipmentSlots);
		-- Handle the left/right jumps for all but the bottom equipment slots so they navigate to the weapon slots.
		for i = 1, numSlotsToMap - 1 do
			SmartNavigation_AddBidirectionalJumpNavigationOverride(
				InspectPaperDollItemsFrame.LeftEquipmentSlots[i],
				SMART_NAV_INPUT_DIRECTION.RIGHT,
				InspectPaperDollItemsFrame.RightEquipmentSlots[i]
			);
		end

		local numWeaponSlots = #InspectPaperDollItemsFrame.WeaponSlots;
		for i = 1, numWeaponSlots, 1 do
			local navigateUpFrame = InspectWristSlot;
			local navigateDownFrame = InspectHeadSlot;
			if i > math.ceil(numWeaponSlots / 2) then
				navigateUpFrame = InspectTrinket1Slot;
				navigateDownFrame = InspectHandsSlot;
			end

			SmartNavigation_AddJumpNavigationOverride(
				InspectPaperDollItemsFrame.WeaponSlots[i],
				SMART_NAV_INPUT_DIRECTION.UP,
				navigateUpFrame
			);
			SmartNavigation_AddJumpNavigationOverride(
				InspectPaperDollItemsFrame.WeaponSlots[i],
				SMART_NAV_INPUT_DIRECTION.DOWN,
				navigateDownFrame
			);
		end
		SmartNavigation_AddJumpNavigationOverride(
			InspectPaperDollItemsFrame.WeaponSlots[1],
			SMART_NAV_INPUT_DIRECTION.LEFT,
			InspectWristSlot
		);

		local rightmostBottomButton;
		if UnitUsesAmmo("player") then
			rightmostBottomButton = InspectAmmoSlot;
		else
			rightmostBottomButton = InspectPaperDollItemsFrame.WeaponSlots[numWeaponSlots];
		end

		SmartNavigation_AddJumpNavigationOverride(
			rightmostBottomButton,
			SMART_NAV_INPUT_DIRECTION.RIGHT,
			InspectTrinket1Slot
		);

		-- Ignore the Character Model Scene for smart navigation.
		SmartNavigation_MarkFrameIgnoredContainerFrame(InspectPaperDollFrame);
		SmartNavigation_MarkFrameIgnored(InspectModelFrame);
		SmartNavigation_MarkFrameIgnored(InspectModelFrame.controlFrame);
	end

	local function SetUpLegend()
		local dressingRoom = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, GenerateClosure(self.OnGamepadOpenDressingRoom, self), DRESSUP_FRAME);
		dressingRoom:AddCondition(GenerateClosure(self.CanShowDressingRoom, self));

		local tooltips = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_LEFT_PRESS,
			GenerateClosure(GamepadMode.FrameControlsManager.ToggleTooltips, GamepadMode.FrameControlsManager), PROMPT_TOGGLE_TOOLTIPS);

		self.frameFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "InspectFrameFooter");
		self.frameFooter:AddPromptedBinding(tooltips);
		self.frameFooter:AddPromptedBinding(dressingRoom);
		self.frameFooter:AddStandardBackPrompt();
		self.frameFooter:Finalize();
		self.frameFooter.inputLegend:ClearAllPoints();
		self.frameFooter.inputLegend:SetPoint("TOPLEFT", InspectFrame, "BOTTOMLEFT", 0, -10);
	end

	local function SetUpTabs()
		InspectFrame.TabIndicators:SetUpTabs(InspectFrame.ModeTabs.Tabs);
	end

	local function PostLoadSetup()
		SmartNavJumps();
		SetUpLegend();
		SetUpTabs();
	end
	EventUtil.ContinueOnAddOnLoaded("Blizzard_InspectUI", PostLoadSetup);
end

function InspectFrameMixin:InitializeGamepad()
	self.CloseButton:Hide();
end

function InspectFrameMixin:UninitializeGamepad()
	self.CloseButton:Show();
end

function InspectFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end
