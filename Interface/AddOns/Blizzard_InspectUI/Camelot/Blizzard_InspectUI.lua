
INSPECTED_UNIT = nil;

UIPanelWindows["InspectFrame"] = { area = "left", pushable = 0, };


INSPECTFRAME_SUBFRAMES = { "InspectPaperDollFrame", "InspectPVPFrame", "InspectGuildFrame" };

INSPECT_MODE_TAB_FRAMES = { };

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
};

function InspectFrame_GetPaperDollTabIndex()
	return 1;
end

function InspectFrame_GetGuildTabIndex()
	return 3;
end

function InspectGuildFrame_ShowRealm()
	return true;
end

function InspectGuildFrame_ShowPoints()
	return true;
end


local INSPECT_MODE_TAB_ICONS = {
	["PaperDollFrame"] = nil, -- Character tab uses player portrait.
	["GuildFrame"] = "Interface/ICONS/INV_Shirt_GuildTabard_01",
};

InspectFrameMixin = {};

function InspectFrame_Show(unit)
	HideUIPanel(InspectFrame);
	if ( CanInspect(unit, true) ) then
		INSPECTED_UNIT = unit;
		NotifyInspect(unit);
		InspectFrame.unit = unit;
		InspectSwitchTabs(1);
	else
		INSPECTED_UNIT = nil;
	end
	InspectFrame:UpdateTabLayout(InspectFrame);
	InspectFrame:SetupModeTabs(InspectFrame);
end

function InspectFrameMixin:OnLoad()
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("INSPECT_READY");
	self.unit = nil;
	INSPECTED_UNIT = nil;

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, #INSPECTFRAME_SUBFRAMES);
	PanelTemplates_SetTab(self, 1);
	self:GetTitleText():SetFontObject("GameFontHighlight");

	self:SetupModeTabs();
	self:RegisterForTransitions();
end

function InspectFrameMixin:UpdateTabLayout()
	if not self.ModeTabs or not self.ModeTabs.Tabs then
		return;
	end

	local previousVisibleTab;
	for _, tab in ipairs(self.ModeTabs.Tabs) do
		tab:ClearAllPoints();
		if tab:IsShown() then
			if previousVisibleTab then
				tab:SetPoint("TOPLEFT", previousVisibleTab, "BOTTOMLEFT");
			else
				tab:SetPoint("TOPLEFT", self.ModeTabs, "TOPLEFT");
			end

			previousVisibleTab = tab;
		end
	end
end

function InspectFrameMixin:OnEvent(event, ...)

	if(event == "INSPECT_READY") then
		local unit = ...;
		if (InspectFrame.unit and (UnitGUID(InspectFrame.unit) == unit)) then
			ShowUIPanel(InspectFrame);
			self:UpdateTabs(self);
		end
	end


	if ( not self:IsShown() ) then
		return;
	end

	if ( event == "PLAYER_TARGET_CHANGED" or event == "GROUP_ROSTER_UPDATE" ) then
		if ( (event == "PLAYER_TARGET_CHANGED" and self.unit == "target") or
			(event == "GROUP_ROSTER_UPDATE" and self.unit ~= "target") ) then
			-- Just hide the InspectFrame when the unit changes.  This hides the bug that occurs when you click on targets too quickly and the server drops the inspect data when flooded with inspect requests.
			--if ( CanInspect(self.unit) ) then
			--	InspectFrame_UnitChanged(self);
			--else
			--	HideUIPanel(InspectFrame);
			--end
			HideUIPanel(InspectFrame);
		end
	elseif ( event == "UNIT_NAME_UPDATE" ) then
		local unit = ...;
		if ( unit == self.unit ) then
			InspectFrame:SetTitle(GetUnitName(self.unit, true));
		end
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if unit == self.unit then
			SetPortraitTexture(InspectFramePortrait, self.unit);
		end
	elseif ( event == "PORTRAITS_UPDATED" ) then
		SetPortraitTexture(InspectFramePortrait, self.unit);
	end
end

function InspectFrameMixin:UnitChanged()
	local unit = self.unit;
	NotifyInspect(unit);
	InspectPaperDollFrame_OnShow();
	InspectFrame:SetPortraitToUnit(unit);
	InspectFrame:SetTitle(GetUnitName(unit, true));
	self:UpdateTabs();
	if ( InspectPVPFrame:IsShown() ) then
		InspectPVPFrame_OnShow();
	end
end

function InspectFrameMixin:OnShow()
	if ( not self.unit ) then
		return;
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	InspectFrame:SetPortraitToUnit(self.unit);
	InspectFrame:SetTitle(GetUnitName(self.unit, true));
end

function InspectFrameMixin:OnHide()
	self.unit = nil;
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

	-- Clear the player being inspected
	if not PlayerSpellsFrame or not PlayerSpellsFrame:IsInspecting() then
		ClearInspectPlayer();
	end
end

function InspectFrameMixin:OnUpdate()
end

function InspectSwitchTabs(newID)
	local newFrame = _G[INSPECTFRAME_SUBFRAMES[newID]];
	local oldFrame = _G[INSPECTFRAME_SUBFRAMES[PanelTemplates_GetSelectedTab(InspectFrame)]];
	if ( newFrame ) then
		if ( oldFrame ) then
			oldFrame:Hide();
		end
		PanelTemplates_SetTab(InspectFrame, newID);
		newFrame:Show();
	end

	if INSPECT_MODE_TAB_FRAMES[newID] then
		InspectFrame:SetSelectedModeTabByFrame(INSPECT_MODE_TAB_FRAMES[newID]);
	end
end

function InspectFrameTab_OnClick(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	InspectSwitchTabs(self:GetID());
end

function InspectFrameMixin:UpdateTabs()
	if ( not InspectFrame.unit ) then
		return;
	end

	-- Guild tab

	local guildTabIndex = InspectFrame_GetGuildTabIndex();
	
	local _, _, guildName = C_PaperDollInfo.GetInspectGuildInfo(InspectFrame.unit);
	local hasGuild = guildName and guildName ~= "";

	if guildTabIndex >= 1 then
		if ( hasGuild ) then
			PanelTemplates_EnableTab(InspectFrame, guildTabIndex);
		else
			PanelTemplates_DisableTab(InspectFrame, guildTabIndex);
			if ( PanelTemplates_GetSelectedTab(InspectFrame) == guildTabIndex ) then
				InspectSwitchTabs(1);
			end
		end
	end

	if self.ModeTabs and self.ModeTabs.Tabs then
		self.ModeTabs.GuildTab:SetShown(hasGuild);
	end

end

function InspectFrameMixin:UpdateCharacterModeTabPortrait()
	local icon = self.ModeTabs.CharacterTab.Icon;
	SetPortraitTexture(icon, self.unit or "target");
	icon:SetTexCoord(0.03125, 0.96875, 0.03125, 0.96875);
end

function InspectFrameMixin:SetSelectedModeTabByFrame(frameName)
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

	if InputUtil.IsGamepadUIEnabled() then
		if self.selectedTab == InspectFrame_GetPaperDollTabIndex() then
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

function InspectFrameMixin:SetupModeTabs()
	if not self.ModeTabs or not self.ModeTabs.Tabs then
		return;
	end

	for index, tab in ipairs(self.ModeTabs.Tabs) do
		tab.frameName = INSPECT_MODE_TAB_FRAMES[index];
		if index == 1 then
			tab.iconTexture = nil;
		else
			tab.iconTexture = INSPECT_MODE_TAB_ICONS[tab.frameName];
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

InspectTabButtonMixin = CreateFromMixins(SidePanelTabButtonMixin);

function InspectTabButtonMixin:OnLoad()
	SidePanelTabButtonMixin.OnLoad(self);

	self:SetCustomOnMouseUpHandler(function(tab, button, upInside)
		if button == "LeftButton" and upInside then
			InspectSwitchTabs(self:GetID());
		end
	end);
end

function InspectFrameMixin:OnGamepadInspectTalents()
	InspectPaperDollFrame.InspectTalents:OnClick();
end

function InspectFrameMixin:CanShowDressingRoom()
	local paperDollButton = SmartNavigation:GetCurrentButton();
	if (paperDollButton) and (InspectFrame.unit) then
		local itemLink = GetInventoryItemLink(InspectFrame.unit, paperDollButton:GetID());
		return itemLink ~= nil;
	end
	return false;
end

function InspectFrameMixin:OnGamepadOpenDressingRoom()
	local paperDollButton = SmartNavigation:GetCurrentButton();
	local itemLink = GetInventoryItemLink(InspectFrame.unit, paperDollButton:GetID());
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
			if (i > math.ceil(numWeaponSlots / 2)) then
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
		if UnitHasRelicSlot("player") then
			rightmostBottomButton = InspectPaperDollItemsFrame.WeaponSlots[numWeaponSlots];
		else
			rightmostBottomButton = InspectAmmoSlot;
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
		local inspectTalent = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, GenerateClosure(self.OnGamepadInspectTalents, self), TALENTS);
		inspectTalent:AddCondition(C_Traits.HasValidInspectData);

		local dressingRoom = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, GenerateClosure(self.OnGamepadOpenDressingRoom, self), DRESSUP_FRAME);
		dressingRoom:AddCondition(GenerateClosure(self.CanShowDressingRoom, self));

		local tooltips = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_LEFT_PRESS,
			GenerateClosure(GamepadMode.FrameControlsManager.ToggleTooltips, GamepadMode.FrameControlsManager), PROMPT_TOGGLE_TOOLTIPS);

		self.frameFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "InspectFrameFooter");
		self.frameFooter:AddPromptedBinding(tooltips);
		self.frameFooter:AddPromptedBinding(inspectTalent);
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
