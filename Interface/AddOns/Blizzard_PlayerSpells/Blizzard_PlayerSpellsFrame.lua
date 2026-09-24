PlayerSpellsFrameMixin = {};

local PlayerSpellsFrameEvents = {
	"PLAYER_LEAVING_WORLD",
};

local PlayerSpellsFrameUnitEvents = {
	"PLAYER_SPECIALIZATION_CHANGED",
};

function PlayerSpellsFrameMixin:OnLoad()
	TabSystemOwnerMixin.OnLoad(self);
	self:SetTabSystem(self.TabSystem);
	self.specTabID = self:AddNamedTab(TALENT_FRAME_TAB_LABEL_SPEC, self.SpecFrame);
	self.talentTabID = self:AddNamedTab(TALENT_FRAME_TAB_LABEL_TALENTS, self.TalentsFrame);
	self.spellBookTabID = self:AddNamedTab(TALENT_FRAME_TAB_LABEL_SPELLBOOK, self.SpellBookFrame);

	self.frameTabsToTabID = {
		[PlayerSpellsUtil.FrameTabs.ClassSpecializations] = self.specTabID,
		[PlayerSpellsUtil.FrameTabs.ClassTalents] = self.talentTabID,
		[PlayerSpellsUtil.FrameTabs.SpellBook] = self.spellBookTabID,
	};

	self.isMinimizingEnabled = true;
	self.manualMinimizeEnabled = GetCVarBool("spellBookMinimize");
	self.minimizedOnNextShow = false;

	self.MaximizeMinimizeButton:SetOnMaximizedCallback(GenerateClosure(self.OnManualMaximizeClicked, self));
	self.MaximizeMinimizeButton:SetOnMinimizedCallback(GenerateClosure(self.OnManualMinimizeClicked, self));
	-- Allowing button to handle updating the cvar will ensure it only gets set when it's manually toggled, and not when toggled automatically to fit other frames
	self.MaximizeMinimizeButton:SetMinimizedCVar("spellBookMinimize");
	-- Since we handle our own automatic minimizing/maximizing on showing, prevent the min/max button from trying to do its own reset to the cvar value every time it shows
	self.MaximizeMinimizeButton:SkipResetOnShow(true);

	self:SetFrameLevelsFromBaseLevel(5000);

	self:UpdatePortrait();

	self:RegisterForTransitions();
end

function PlayerSpellsFrameMixin:OnShow()
	local microButtons = self.GetAssociatedMicroButtons();
	for index, button in ipairs(microButtons) do
		button:EvaluateAlertVisibility();
	end

	FrameUtil.RegisterFrameForEvents(self, PlayerSpellsFrameEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, PlayerSpellsFrameUnitEvents, "player");

	self:UpdateTabs();

	MultiActionBar_ShowAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_SPELLCOLLECTION);
	UpdateMicroButtons();
	EventRegistry:TriggerEvent("PlayerSpellsFrame.OpenFrame");
	PlaySound(SOUNDKIT.UI_CLASS_TALENT_OPEN_WINDOW);

	-- This flag is intended for single-use only so reset it once the frame has been shown.
	self.minimizedOnNextShow = false;

	-- Make sure that the FrameControlsManager picks up the spells frame and selects the correct button after auto resizing.
	if (InputUtil.IsGamepadUIEnabled()) then
		GamepadMode.FrameControlsManager:FrameShown(self);
		if self:IsFrameTabActive(PlayerSpellsUtil.FrameTabs.SpellBook) then
			self.SpellBookFrame:ResetGamepadCursorLocation();
		elseif self:IsFrameTabActive(PlayerSpellsUtil.FrameTabs.ClassTalents) then
			self.TalentsFrame:ResetGamepadCursorLocation();
		end
	end
end

function PlayerSpellsFrameMixin:OnHide()
	local microButtons = self.GetAssociatedMicroButtons();
	for index, button in ipairs(microButtons) do
		button:EvaluateAlertVisibility();
	end

	FrameUtil.UnregisterFrameForEvents(self, PlayerSpellsFrameEvents);
	FrameUtil.UnregisterFrameForEvents(self, PlayerSpellsFrameUnitEvents);

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_CLOSE_WINDOW);

	self:ClearInspectUnit();

	MultiActionBar_HideAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_SPELLCOLLECTION);
	UpdateMicroButtons();
	self.lockInspect = false;

	EventRegistry:TriggerEvent("PlayerSpellsFrame.CloseFrame");

	if InputUtil.IsGamepadUIEnabled() then
		self.spellsFrameFooter:HideAndDeactivateBindings();
	end
end

function PlayerSpellsFrameMixin:OnEvent(event)
	if event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:UpdateTabs();
		self:UpdatePortrait();
	elseif event == "PLAYER_LEAVING_WORLD" then
		-- There's a lot of player spell info thrashing while exiting/re-entering world, avoid displaying during it
		HideUIPanel(self);
	end
end

function PlayerSpellsFrameMixin:GetTalentsTabButton()
	return self:GetTabButton(self.talentTabID);
end

-- Override in game types that don't use tabs.
function PlayerSpellsFrameMixin:IsTabSystemAvailable()
	return true;
end

function PlayerSpellsFrameMixin:UpdateTabs()
	local tabSystemAvailable = self:IsTabSystemAvailable();
	self.TabSystem:SetShown(tabSystemAvailable);

	local specTabAvailable = self:IsTabAvailable(self.specTabID);
	local spellBookTabAvailable = self:IsTabAvailable(self.spellBookTabID);
	self.TabSystem:SetTabShown(self.specTabID, specTabAvailable);
	self.TabSystem:SetTabShown(self.spellBookTabID, spellBookTabAvailable);

	if self:IsInspecting() then
		self.TabSystem:SetTabShown(self.talentTabID, false);
	else
		local talentTabAvailable = self:IsTabAvailable(self.talentTabID);
		self.TabSystem:SetTabShown(self.talentTabID, talentTabAvailable);
	end

	local currentTab = self:GetTab();
	if not currentTab or not self:IsTabAvailable(currentTab) then
		self:SetToDefaultAvailableTab();
	end
end

function PlayerSpellsFrameMixin:SetToDefaultAvailableTab()
	if(self:IsTabAvailable(self.talentTabID)) then
		self:SetTab(self.talentTabID);
	elseif (self:IsTabAvailable(self.specTabID)) then
		self:SetTab(self.specTabID);
	else
		self:SetTab(self.spellBookTabID);
	end
end

function PlayerSpellsFrameMixin:SetOpenToSpecTab(openToSpecTab)
	self.openToSpecTab = openToSpecTab;
end

function PlayerSpellsFrameMixin:ShouldOpenToSpecTab()
	return self.openToSpecTab;
end

function PlayerSpellsFrameMixin:UpdateFrameTitle()
	local tabID = self:GetTab();
	if self:IsInspecting() then
		local inspectUnit = self:GetInspectUnit();
		if inspectUnit then
			self:SetTitle(TALENTS_INSPECT_FORMAT:format(UnitName(self:GetInspectUnit())));
		else
			self:SetTitle(TALENTS_LINK_FORMAT:format(self:GetSpecName(), self:GetClassName()));
		end
	elseif tabID == self.specTabID then
		self:SetTitle(SPECIALIZATION);
	elseif tabID == self.talentTabID then
		self:SetTitle(TALENTS);
	else --if tabID == self.spellBookTabID
		self:SetTitle(SPELLBOOK);
	end
end

function PlayerSpellsFrameMixin:SetTab(tabID)
	TabSystemOwnerMixin.SetTab(self, tabID);

	local canNewTabBeMinimized = self:DoesTabSupportMinimizedMode(tabID);
	if self.isMinimized and not canNewTabBeMinimized then
		self:ForceMaximize();
	elseif not self.isMinimized and self:ShouldManuallyMinimize(tabID) then
		self:SetMinimized(true);
	else
		self:SetTabMinimized(tabID, self.isMinimized);
	end

	-- Do not enable the button for gamepad.
	if (not InputUtil.IsGamepadUIEnabled()) then
		self.MaximizeMinimizeButton:SetShown(canNewTabBeMinimized);
	end

	self:UpdateFrameTitle();
	self:UpdatePortrait();
	EventRegistry:TriggerEvent("PlayerSpellsFrame.TabSet", PlayerSpellsFrame, tabID);

	local microButtons = self.GetAssociatedMicroButtons();
	for index, button in ipairs(microButtons) do
		button:UpdateMicroButton();
	end

	return true; -- Don't show the tab as selected yet.
end

-- Expects a PlayerSpellsUtil.FrameTabs value
function PlayerSpellsFrameMixin:IsFrameTabActive(frameTab)
	local tabID = self.frameTabsToTabID[frameTab];
	if not tabID then
		return false;
	end
	return self:GetTab() == tabID;
end

-- Expects a PlayerSpellsUtil.FrameTabs value
function PlayerSpellsFrameMixin:TrySetTab(frameTab)
	local tabID = self.frameTabsToTabID[frameTab];
	if not tabID then
		return false;
	end

	local isTabAvailable = self:IsTabAvailable(tabID);
	if isTabAvailable then
		SetUIPanelAttribute(self, "area", self:AreaAttributeForTab(frameTab));

		self:SetTab(tabID);
	end

	return isTabAvailable;
end

function PlayerSpellsFrameMixin:AreaAttributeForTab(frameTab)
	if self.isMinimizingEnabled then
		return "centerOrLeft";
	end

	return "center";
end

function PlayerSpellsFrameMixin:IsTabAvailable(tabID)
	local canUseTalentSpecUI = C_SpecializationInfo.CanPlayerUseTalentSpecUI();
	local isInspecting = self:IsInspecting();

	if tabID == self.specTabID then
		return not isInspecting and canUseTalentSpecUI and C_SpecializationInfo.IsSpecSelectionEnabled(self:GetClassID());
	elseif tabID == self.talentTabID then
		return isInspecting or (PlayerUtil.CanUseClassTalents() and (canUseTalentSpecUI or not C_SpecializationInfo.IsSpecSelectionEnabled(self:GetClassID())));
	elseif tabID == self.spellBookTabID then
		return not isInspecting;
	end

	return false;
end

function PlayerSpellsFrameMixin:ClearInspectUnit()
	if not self:IsInspecting() then
		return;
	end

	ClearInspectPlayer();

	self:SetInspectString(nil);
end

function PlayerSpellsFrameMixin:SetInspectUnit(inspectUnit)
	local inspectString = nil;
	local inspectStringLevel = nil;
	self:SetInspecting(inspectUnit, inspectString, inspectStringLevel);
end

function PlayerSpellsFrameMixin:SetInspectString(inspectString, inspectStringLevel)
	local inspectUnit = nil;
	self:SetInspecting(inspectUnit, inspectString, inspectStringLevel);
end

function PlayerSpellsFrameMixin:SetInspecting(inspectUnit, inspectString, inspectStringLevel)
	if (inspectUnit or inspectString) and self:IsMinimized() then
		-- Force us out of minimize mode ahead of processing data so that we're in a clean state to inspect
		-- Otherwise the Hide involved will clear out the inspect unit.
		-- If Talent tab ever supports minimized mode in the future, we may be able to remove this.
		self:ForceMaximize();
	end

	self.inspectUnit = inspectUnit;
	self.inspectString = inspectString;

	if inspectString then
		local success, specID = self.TalentsFrame:ViewLoadout(inspectString, inspectStringLevel);
		if not success then
			self:SetInspecting(nil, nil, nil);
			return;
		end

		self.inspectStringSpecID = specID;
		self.inspectStringClassID = C_SpecializationInfo.GetClassIDFromSpecID(specID);
	else
		self.inspectStringSpecID = nil;
		self.inspectStringClassID = nil;
	end

	-- Disabling minimizing entirely to ensure the frame doesn't get thrashed by frame closes & opens that clear the inspect data
	self:SetMinimizingEnabled(not self:IsInspecting());

	self:UpdateTabs();
	self.TalentsFrame:UpdateInspecting();

	if inspectUnit or inspectString then
		self:SetTab(self.talentTabID);
	else
		self:UpdateFrameTitle();
	end

	self:UpdatePortrait();
end

function PlayerSpellsFrameMixin:IsInspecting()
	return (self.inspectUnit ~= nil) or (self.inspectString ~= nil);
end

function PlayerSpellsFrameMixin:GetInspectUnit()
	return self.inspectUnit;
end

function PlayerSpellsFrameMixin:GetInspectString()
	return self.inspectString, self.inspectStringClassID, self.inspectStringSpecID;
end

function PlayerSpellsFrameMixin:GetClassID()
	if self:IsInspecting() then
		local inspectUnit = self:GetInspectUnit();
		if inspectUnit then
			return select(3, UnitClass(inspectUnit));
		else
			return select(2, self:GetInspectString());
		end
	end

	return PlayerUtil.GetClassID();
end

function PlayerSpellsFrameMixin:GetSpecID()
	if self:IsInspecting() then
		local inspectUnit = self:GetInspectUnit();
		if inspectUnit then
			return C_SpecializationInfo.GetInspectSpecialization(inspectUnit);
		else
			return select(3, self:GetInspectString());
		end
	end

	return PlayerUtil.GetCurrentSpecID();
end

function PlayerSpellsFrameMixin:GetUnitSex()
	-- If we're inspecting via string, use the player's sex.
	local unit = (self:IsInspecting() and self:GetInspectUnit()) or "player";
	return UnitSex(unit);
end

function PlayerSpellsFrameMixin:GetClassName()
	if self:IsInspecting() then
		local inspectUnit = self:GetInspectUnit();
		if inspectUnit then
			local className = UnitClass(inspectUnit);
			return className;
		else
			local classID = select(2, self:GetInspectString());
			local classInfo = C_CreatureInfo.GetClassInfo(classID);
			return classInfo.className;
		end
	end

	return PlayerUtil.GetClassName();
end

function PlayerSpellsFrameMixin:GetSpecName()
	local unitSex = self:GetUnitSex();
	local specID = self:GetSpecID();
	if not specID then
		return "";
	end
	return select(2, GetSpecializationInfoByID(specID, unitSex));
end

function PlayerSpellsFrameMixin:UpdatePortrait()
	local specID = self:GetSpecID();
	local specIcon = specID and PlayerUtil.GetSpecIconBySpecID(specID, self:GetInspectUnit() or "player") or nil;
	if specIcon then
		self:SetPortraitTexCoord(0, 1, 0, 1);
		self:SetPortraitToAsset(specIcon);
	else
		local classID = self:GetClassID();
		self:SetPortraitToClassIcon(C_CreatureInfo.GetClassInfo(classID).classFile);
	end
end

function PlayerSpellsFrameMixin:CheckConfirmResetAction(callback, cancelCallback)
	if (self:GetTab() == self.talentTabID) and self.TalentsFrame:HasAnyConfigChanges() then
		local referenceKey = self;
		if not StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
			local customData = {
				text = TALENT_FRAME_CONFIRM_CLOSE,
				callback = callback,
				cancelCallback = cancelCallback,
				acceptText = CONTINUE,
				cancelText = CANCEL,
				referenceKey = referenceKey,
			};

			StaticPopup_ShowCustomGenericConfirmation(customData);
		end
	else
		callback();
	end
end

-- Override in game types that have different values for different tabs.
function PlayerSpellsFrameMixin:GetDesiredMinimizedWidth(tabID)
	return self.minimizedWidth;
end

-- Override in game types that have different values for different tabs.
function PlayerSpellsFrameMixin:GetDesiredMaximizedWidth(tabID)
	return self.maximizedWidth;
end

-- Override in game types that have different values for different tabs.
function PlayerSpellsFrameMixin:GetDesiredMinimizedHeight(tabID)
	return self.desiredHeight;
end

-- Override in game types that have different values for different tabs.
function PlayerSpellsFrameMixin:GetDesiredMaximizedHeight(tabID)
	return self.desiredHeight;
end

function PlayerSpellsFrameMixin:UpdateSize()
	local currentTab = self:GetTab();

	if self:IsMinimized() then
		self:SetWidth(self:GetDesiredMinimizedWidth(currentTab));
		self:SetHeight(self:GetDesiredMinimizedHeight(currentTab));
	else
		self:SetWidth(self:GetDesiredMaximizedWidth(currentTab));
		self:SetHeight(self:GetDesiredMaximizedHeight(currentTab));
	end
end

function PlayerSpellsFrameMixin:IsMinimized()
	return self.isMinimized;
end

function PlayerSpellsFrameMixin:IsMinimizingEnabled()
	return self.isMinimizingEnabled;
end

-- Setting this to true means the next time the player spells frame is shown it will be automatically
-- minimized and then minimizedOnNextShow will be set back to false.
function PlayerSpellsFrameMixin:SetMinimizedOnNextShow(minimizedOnNextShow)
	self.minimizedOnNextShow = minimizedOnNextShow;
end

function PlayerSpellsFrameMixin:ShouldAutoMinimize()
	-- Has the player previously minimized the frame.
	if self:ShouldManuallyMinimize() then
		return true;
	end

	-- Has external code requested the frame be minimized next time its opened.
	return self:IsMinimizingEnabled() and self.minimizedOnNextShow;
end

function PlayerSpellsFrameMixin:ShouldManuallyMinimize(tabID)
	return self:IsMinimizingEnabled() and self.manualMinimizeEnabled and self:DoesTabSupportMinimizedMode(tabID or self:GetTab());
end

function PlayerSpellsFrameMixin:OnManualMinimizeClicked()
	self.manualMinimizeEnabled = true;
	if not self.isMinimized and self:ShouldManuallyMinimize() then
		self:SetMinimized(true);
		EventRegistry:TriggerEvent("PlayerSpellsFrame.OnManualMinimize");
	end
end

function PlayerSpellsFrameMixin:OnManualMaximizeClicked()
	self.manualMinimizeEnabled = false;
	if self.isMinimized then
		self:ForceMaximize();
		EventRegistry:TriggerEvent("PlayerSpellsFrame.OnManualMaximize");
	end
end

function PlayerSpellsFrameMixin:DoesTabSupportMinimizedMode(tabID)
	-- Check should be updated if/when support for minimized mode is added to additional tabs
	return tabID == self.spellBookTabID;
end

function PlayerSpellsFrameMixin:GetDefaultMinimizableTab()
	-- Logic should be updated if/when support for minimized mode is added to additional tabs
	return self.spellBookTabID;
end

function PlayerSpellsFrameMixin:SetMinimized(shouldBeMinimized)
	if self.isMinimized == shouldBeMinimized then
		return;
	end

	-- Changing the UI panel "area" attribute requires running through all the area evaluation
	-- logic within ShowUIPanel and the panel needs to be hidden before changing the attribute.
	-- But this only needs to happen if the player spells frame is currently shown.
	local wasShown = self:IsShown();
	if wasShown then
		HideUIPanel(self, true);
	end

	local currentTab = self:GetTab();
	if not self.isMinimized and shouldBeMinimized then
		-- Prevent non-UIParent code manually calling SetMinimized when auto behavior intentionally disabled
		assert(self:IsMinimizingEnabled());

		self.isMinimized = true;
		if not self:DoesTabSupportMinimizedMode(currentTab) then
			local minimizableTabID = self:GetDefaultMinimizableTab();
			self:SetTab(minimizableTabID); -- SetTab will call SetTabMaximized
		else
			self:SetTabMinimized(currentTab, true);
		end

		self:UpdateSize();

		-- Update minimize button to reflect current state, but ensure it doesn't circle back to the click callback
		-- This ensures that auto-minimizes are reflected by the button state, and the click callback only occurs on manual minimizes
		local isAutomaticAction, skipCallback = true, true;
		self.MaximizeMinimizeButton:Minimize(isAutomaticAction, skipCallback);

		-- When using center alignment (e.g. when no other panels are visible on the screen) the minimized version
		-- of the frame should be offset such that it would be left aligned with the maximized version of the frame.
		SetUIPanelAttribute(self, "centerXOffset", -405);
	elseif self.isMinimized and not shouldBeMinimized then
		self.isMinimized = false;
		self:UpdateSize();
		self:SetTabMinimized(currentTab, false);

		local isAutomaticAction, skipCallback = true, true;
		self.MaximizeMinimizeButton:Maximize(isAutomaticAction, skipCallback);

		-- The maximized version of the frame should always be center aligned on the screen.
		SetUIPanelAttribute(self, "centerXOffset", 0);
	end

	-- If the panel was previously shown and then hidden to change the "area" attribute, show it again now.
	if wasShown then
		ShowUIPanel(self);
	end
end

function PlayerSpellsFrameMixin:SetTabMinimized(tabID, shouldBeMinimized)
	if not tabID or not self:DoesTabSupportMinimizedMode(tabID) then
		return;
	end

	local tabPage = self:GetElementsForTab(tabID)[1];
	tabPage:SetMinimized(shouldBeMinimized);
end

function PlayerSpellsFrameMixin:ForceMaximize()
	-- Close and re-show with minimize attributes temporarily disabled to ensure this frame stays maximized and other frames get closed
	self:SetMinimizingEnabled(false);
	self:SetMinimized(false);
	-- Now re-enable minimizing so that, if another frame gets opened later, we can be re-minimized and pop back to a supporting tab as usual
	self:SetMinimizingEnabled(true);
end

function PlayerSpellsFrameMixin:SetMinimizingEnabled(enabled)
	self.isMinimizingEnabled = enabled;

	if enabled then
		SetUIPanelAttribute(self, "autoMinimizeWithOtherPanels", true);
		SetUIPanelAttribute(self, "area", "centerOrLeft");
	else
		SetUIPanelAttribute(self, "autoMinimizeWithOtherPanels", false);
		SetUIPanelAttribute(self, "area", "center");
	end
end

function PlayerSpellsFrameMixin:GetAssociatedMicroButtons()
	return { PlayerSpellsMicroButton };
end

function PlayerSpellsFrameMixin:IsSpellButton(button)
	return button and button.buttonContext == "ButtonContext_SpellButton"
end

function PlayerSpellsFrameMixin:IsOutfitButton(button)
	return button and button.buttonContext == "ButtonContext_OutfitButton"
end

function PlayerSpellsFrameMixin:BindToGamepadActionBar()
	if (not GamepadMode.FrameControlsManager:IsFrameSuspended()) then
		GamepadMode.FrameControlsManager:SuspendFrame();
	end

	local suspendedButton = GamepadMode.FrameControlsManager:GetSuspendedButton();
	if (suspendedButton) then
		local spellBookItem = suspendedButton:GetParent();
		if (spellBookItem) then
			if self:IsSpellButton(suspendedButton) then
				GamepadActionBarEditFrame:BindSpellBookItem(spellBookItem.slotIndex, spellBookItem.spellBank);
			elseif self:IsOutfitButton(suspendedButton) then
				GamepadActionBarEditFrame:BindOutfit(spellBookItem:GetOutfitID());
			end
		end
	end
end

function PlayerSpellsFrameMixin:ToggleAutoCastOrCastSpell(toggleAutoCast)
	-- This action is triggered from a context menu, so the desired button is suspended.
	local suspendedButton = GamepadMode.FrameControlsManager:GetSuspendedButton();
	if (suspendedButton) then
		if (toggleAutoCast) then
			local spellBookItem = suspendedButton:GetParent();
			if (spellBookItem) then
				local itemInfo = spellBookItem.spellBookItemInfo;
				if (itemInfo) then
					C_Spell.ToggleSpellAutoCast(itemInfo.spellID);
				end
			end
		else
			suspendedButton:Click();
		end
	end
end

function PlayerSpellsFrameMixin:OpenSpellBookSettings()
	self.SpellBookFrame.SettingsDropdown:OpenMenu();
end

function PlayerSpellsFrameMixin:OpenTalentSettings()
	self.TalentsFrame.SearchOptionsDropdown:OpenMenu();
end

function PlayerSpellsFrameMixin:SelectNextSpellBookCategory(forward)
	if (SmartNavigation:GetActiveFrame() == self) then
		if self.SpellBookFrame:IsInSearchResultsMode() then
			self.SpellBookFrame:ClearActiveSearchState();
		end

		self.SpellBookFrame:SelectNextTab(forward);
	end
end

function PlayerSpellsFrameMixin:IsAutoCastDropdownContextActionValid()
	local spellButton = SmartNavigation:GetCurrentButton();
	if (spellButton) then
		local spellBookItem = spellButton:GetParent();
		if (spellBookItem) then
			local itemInfo = spellBookItem.spellBookItemInfo;
			if (itemInfo) then
				local isLearned = not itemInfo.isOffSpec and itemInfo.itemType ~= Enum.SpellBookItemType.FutureSpell;
				local isNotPassive = not itemInfo.isPassive;

				if ((isLearned and isNotPassive) and itemInfo.spellID and C_Spell.GetSpellAutoCast(itemInfo.spellID)) then
					return true;
				end
			end
		end
	end
	return false;
end

local function IsPassiveFlyout(spellBookItemInfo)
	if spellBookItemInfo.itemType ~= Enum.SpellBookItemType.Flyout then
		return false;
	end

	if spellBookItemInfo.isPassive then
		return true;
	end

	local _, _, numSlots = GetFlyoutInfo(spellBookItemInfo.actionID);
	local allPassive = true;

	for i = 1, numSlots do
		local _, overrideSpellID, isKnown = GetFlyoutSlotInfo(spellBookItemInfo.actionID, i);
		if isKnown and not C_Spell.IsSpellPassive(overrideSpellID) then
			allPassive = false;
			break;
		end
	end

	return allPassive;
end

--[[
	Even though the button has been marked as a spell button, we
	want to perform extra checks to make sure that the spell button
	contains a spell and that the spell is non-passive and known.
]]
function PlayerSpellsFrameMixin:GetSmartNavSpellBookItemInfo()
	local spellButton = SmartNavigation:GetCurrentButton();
	if not spellButton then
		return nil;
	end

	local spellBookItem = spellButton:GetParent();
	if not spellBookItem then
		return nil;
	end

	return spellBookItem.spellBookItemInfo;
end

function PlayerSpellsFrameMixin:IsSpellButtonButtonContextBindable()
	local itemInfo = self:GetSmartNavSpellBookItemInfo()
	if not itemInfo then
		return false;
	end

	local type = itemInfo.itemType;
	local isLearned = not itemInfo.isOffSpec and type ~= Enum.SpellBookItemType.FutureSpell;
	local isPassive = itemInfo.isPassive or IsPassiveFlyout(itemInfo);
	return isLearned and not isPassive;
end

function PlayerSpellsFrameMixin:IsSpellButtonButtonContextUsable()
	local itemInfo = self:GetSmartNavSpellBookItemInfo()
	return itemInfo
		and not itemInfo.isOffSpec
		and not itemInfo.isPassive
		and itemInfo.type ~= Enum.SpellBookItemType.FutureSpell;
end

function PlayerSpellsFrameMixin:IsTransmogButtonButtonContextValid()
	local spellButton = SmartNavigation:GetCurrentButton();
	if not spellButton then
		return nil;
	end

	local spellBookItem = spellButton:GetParent();
	if not spellBookItem then
		return nil;
	end

	return spellBookItem:HasValidData();
end

function PlayerSpellsFrameMixin:IsCurrentButtonUsable()
	local button = SmartNavigation:GetCurrentButton();
	
	if self:IsSpellButton(button) then
		return self:IsSpellButtonButtonContextUsable();
	elseif self:IsOutfitButton(button) then
		return self:IsTransmogButtonButtonContextValid();
	end

	return false;
end

function PlayerSpellsFrameMixin:IsCurrentButtonBindable()
	local button = SmartNavigation:GetCurrentButton();
	
	if self:IsSpellButton(button) then
		return self:IsSpellButtonButtonContextBindable();
	elseif self:IsOutfitButton(button) then
		return self:IsTransmogButtonButtonContextValid();
	end

	return false;
end

function PlayerSpellsFrameMixin:GetCastPromptLabel()
	local itemInfo = self:GetSmartNavSpellBookItemInfo()
	return (itemInfo and itemInfo.itemType == Enum.SpellBookItemType.Flyout)
		and CONTEXT_ACTION_LABEL_OPEN
		or CONTEXT_ACTION_LABEL_CAST;
end

local INPUT_THRESHOLD = 0.5;
local STICK_RESET_THRESHOLD = 0.25;

function PlayerSpellsFrameMixin:NavigateSection(x, y, directionHandlers)
	self.waitingForStickReset = self.waitingForStickReset or false;

	if self.waitingForStickReset then
		if math.abs(x) <= STICK_RESET_THRESHOLD and math.abs(y) <= STICK_RESET_THRESHOLD then
			self.waitingForStickReset = false;
		else
			return;
		end
	end

	local directionHandler;

	if math.abs(x) >= math.abs(y) then
		if x >= INPUT_THRESHOLD then
			directionHandler = directionHandlers.right;
		elseif x <= -INPUT_THRESHOLD then
			directionHandler = directionHandlers.left;
		end
	else
		if y >= INPUT_THRESHOLD then
			directionHandler = directionHandlers.up;
		elseif y <= -INPUT_THRESHOLD then
			directionHandler = directionHandlers.down;
		end
	end

	
	if directionHandler then
		directionHandler();
		self.waitingForStickReset = true;
	end
end

function PlayerSpellsFrameMixin:SetUpSpellBookGamepad()
	local bindSpell = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, GenerateClosure(self.BindToGamepadActionBar, self), CONTEXT_ACTION_LABEL_BIND_TO_GAMEPAD_ACTION_BAR);
	bindSpell:AddButtonContext("ButtonContext_SpellButton");
	bindSpell:AddButtonContext("ButtonContext_OutfitButton");
	bindSpell:AddCondition(GenerateFlatClosure(self.IsCurrentButtonBindable, self));


	-- Use the button's click handler directly rather than routing though SmartNavigation synthesized MouseUp/Down events.
	-- Certain game states (ex: pending ground casts) suppress emulated mouse input before they reach OnClick handlers, preventing them from firing.
	local function ClickSelectedSpellBookButton()
		local button = SmartNavigation:GetCurrentButton();
		return button and button:Click();
	end

	local castSpell = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, ClickSelectedSpellBookButton);
	castSpell:AddButtonContext("ButtonContext_SpellButton");
	castSpell:AddButtonContext("ButtonContext_OutfitButton");
	castSpell:AddCondition(GenerateFlatClosure(self.IsCurrentButtonUsable, self));
	castSpell:SetLabelFunction(GenerateFlatClosure(self.GetCastPromptLabel, self));

	local function Back()
		self.CloseButton:Click();
		GameTooltip_Hide();
	end

	local backAction = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, Back, FRAME_ACTION_BACK);

	local autoCastOptions = GamepadSharedUtility.CreateMoreActionsPromptedBinding(GAMEPAD_FACE_BOTTOM);
	autoCastOptions:AddButtonContext("ButtonContext_SpellButton");
	autoCastOptions:AddCondition(GenerateFlatClosure(self.IsAutoCastDropdownContextActionValid, self));
	autoCastOptions:AddMoreActionsEntry(CONTEXT_ACTION_LABEL_CAST, GenerateFlatClosure(self.ToggleAutoCastOrCastSpell, self, false));
	autoCastOptions:AddMoreActionsEntry(CONTEXT_ACTION_LABEL_AUTO_CAST, GenerateFlatClosure(self.ToggleAutoCastOrCastSpell, self, true));

	-- "Auto-cast" should have higher priority than "Cast" if usable, but "Cast" should be shown if both are unusable.
	autoCastOptions:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local openSettings = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_RIGHT, GenerateFlatClosure(self.OpenSpellBookSettings, self), nil);
	openSettings:SetCustomPromptFrame(self.SpellBookFrame.SettingsTopFaceIcon);

	local enterSearchBox = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, function() self.SpellBookFrame.SearchBox:SetFocus(); end, nil);
	enterSearchBox:SetCustomPromptFrame(self.SpellBookFrame.SearchBoxIcon);

	local editActionBar = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, GenerateClosure(GamepadActionBarEditFrame.EnterEditMode, GamepadActionBarEditFrame), FRAME_ACTION_EDIT_ACTION_BAR);

	local previousCategory = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_SHOULDER_LEFT, GenerateFlatClosure(self.SelectNextSpellBookCategory, self, false), nil);
	previousCategory:SetCustomPromptFrame(self.SpellBookFrame.PreviousCategoryIcon);

	local nextCategory = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_SHOULDER_RIGHT, GenerateFlatClosure(self.SelectNextSpellBookCategory, self, true), nil);
	nextCategory:SetCustomPromptFrame(self.SpellBookFrame.NextCategoryIcon);

	local tooltips = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_PRESS, nil, PROMPT_TOGGLE_TOOLTIPS);

	-- Navigate Section --
	local SpellBookFrameSectionHandlers = {
		left = function()
			self.SpellBookFrame:GamepadNavigateViewLeft();
		end,

		right = function()
			self.SpellBookFrame:GamepadNavigateViewRight();
		end,
	};

	self.navigateSpellBookSection = GamepadMode.CreateBindingGroup("SpellbookNavigateSection");
	self.navigateSpellBookSection:AddAxisBinding(GAMEPAD_STICK_LEFT, 
		function(x, y)
			self:NavigateSection(x, y, SpellBookFrameSectionHandlers);
		end
	);

	-- Navigate Elements --
	local navigateElements = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD, nil, FRAME_ACTION_NAVIGATE);

	self.spellsFrameFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "SpellsFrameFooter");
	self.spellsFrameFooter:SetAnchorOffsets(0, -5);
	self.spellsFrameFooter:AddPromptedBinding(backAction);
	self.spellsFrameFooter:AddPromptedBinding(autoCastOptions);
	self.spellsFrameFooter:AddPromptedBinding(castSpell);
	self.spellsFrameFooter:AddPromptedBinding(bindSpell);
	self.spellsFrameFooter:AddPromptedBinding(editActionBar);
	self.spellsFrameFooter:AddPromptedBinding(navigateElements);
	self.spellsFrameFooter:AddPromptedBinding(openSettings);
	self.spellsFrameFooter:AddPromptedBinding(enterSearchBox);
	self.spellsFrameFooter:AddPromptedBinding(previousCategory);
	self.spellsFrameFooter:AddPromptedBinding(nextCategory);
	self.spellsFrameFooter:AddPromptedBinding(tooltips);
	self.spellsFrameFooter:AddStandardFrameControlManagerBindings(self);
	self.spellsFrameFooter:Finalize();
end

function PlayerSpellsFrameMixin:SetUpClassTalentsGamepad()
	local talentFrame = self.TalentsFrame;

	-- Tabbing --
	local function SecondarySpecUnlocked()
		return GetNumSpecGroups() > 1;
	end

	-- Undo Changes --
	local function UndoChanges()
		self.TalentsFrame.UndoButton:Click();
	end
	local function ShouldShowUndo()
		return talentFrame:HasAnyConfigChanges() and not talentFrame.isConfigReadyToApply;
	end

	-- Add point --
	local function CanAddPoint()
		local classTalentButton = SmartNavigation:GetCurrentButton();
		return classTalentButton and classTalentButton:CanPurchaseRank();
	end
	local function AddPoint()
		local classTalentButton = SmartNavigation:GetCurrentButton();
		if classTalentButton:CanPurchaseRank() then
			classTalentButton:PurchaseRank();
		end
	end

	-- Select --
	local function Select()
		local element = SmartNavigation:GetCurrentButton();
		if element and element.Click then
			element:Click();
			if element == talentFrame.UndoButton then
				SmartNavigation:SelectButton(talentFrame:GamepadGetStartingButtonForTree());
			end
		end
	end

	local function ElementNotTalentButton()
		local element = SmartNavigation:GetCurrentButton();
		return not (element and element.buttonContext and element.buttonContext == "ButtonContext_ClassTalent");
	end

	-- Remove point --
	local function CanRemovePoint()
		local classTalentButton = SmartNavigation:GetCurrentButton();
		return classTalentButton and classTalentButton:CanRefundRank();
	end
	local function RemovePoint()
		local classTalentButton = SmartNavigation:GetCurrentButton();
		classTalentButton:RefundRank();
	end

	-- Apply changes --
	local function CanApplyChanges()
		return talentFrame.ApplyButton:IsEnabled();
	end
	local function ApplyChanges()
		return talentFrame.ApplyButton:Click();
	end

	-- Section Navigation --
	local TalentFrameSectionHandlers = {
		left = function()
			talentFrame:GamepadNavigateHorizontalSection(-1);
		end,

		right = function()
			talentFrame:GamepadNavigateHorizontalSection(1);
		end,

		up = function()
			talentFrame:GamepadNavigateVerticalSection(1);
		end,

		down = function()
			talentFrame:GamepadNavigateVerticalSection(-1);
		end,
	};

	-- Tabbing --
	local primarySpecTab = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_SHOULDER_LEFT, function()
		talentFrame:SetTab(talentFrame.primarySpecTabID)
		if not talentFrame:IsActiveTabSelected() and talentFrame.ActiveSpec.ActivateButton:IsShown() then
			SmartNavigation:SelectButton(talentFrame.ActiveSpec.ActivateButton);
		else
			SmartNavigation:SelectButton(talentFrame:GamepadGetStartingButtonForTree());
		end
	end, nil);
	primarySpecTab:SetCustomPromptFrame(self.TalentsFrame.GamepadPrimaryTabIcon);

	local secondarySpecTab = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_SHOULDER_RIGHT, function()
		talentFrame:SetTab(talentFrame.secondarySpecTabID)
		if not talentFrame:IsActiveTabSelected() and talentFrame.ActiveSpec.ActivateButton:IsShown() then
			SmartNavigation:SelectButton(talentFrame.ActiveSpec.ActivateButton);
		else
			SmartNavigation:SelectButton(talentFrame:GamepadGetStartingButtonForTree());
		end
	end, nil);
	secondarySpecTab:SetCustomPromptFrame(talentFrame.GamepadSecondaryTabIcon, talentFrame.GamepadSecondaryTabIcon.SetPressable, talentFrame.GamepadSecondaryTabIcon.SetDisabled);
	secondarySpecTab:AddCondition(SecondarySpecUnlocked);

	-- Add point --
	local addPoint = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, AddPoint, GAMEPAD_TALENT_ADD_POINT);
	addPoint:AddButtonContext("ButtonContext_ClassTalent");
	addPoint:AddCondition(CanAddPoint);

	-- Select --
	local select = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, Select, ACTION_LABEL_SELECT);
	select:AddCondition(ElementNotTalentButton);
	select:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	-- Remove point --
	local removePoint = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, "ClassTalents_RemovePoint_PromptedBinding");
	removePoint:AddFooterBinding({
		label = GAMEPAD_TALENT_REMOVE_POINT,
		buttonContexts = "ButtonContext_ClassTalent",
		conditions = { CanRemovePoint, function() return not ShouldShowUndo(); end, },
	})
	removePoint:AddFooterFunction({
		buttonUpDown = GAMEPAD_BUTTON_ANY_UP,
		bindingFunctions = RemovePoint,
	})

	-- Undo changes --
	local undoChanges = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, "ClassTalents_UndoChanges_PromptedBinding");
	undoChanges:AddFooterBinding({
		label = GAMEPAD_TALENT_REMOVE_POINT,
		buttonContexts = "ButtonContext_ClassTalent",
		conditions = { CanRemovePoint, ShouldShowUndo },
	})
	local undoChangesHoldBinding = undoChanges:AddCustomPromptBinding({
		frame = talentFrame.GamepadUndoButton,
		visibilityType = PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE,
		conditions = ShouldShowUndo,
	})
	undoChanges:AddCustomPromptHoldFunction(undoChangesHoldBinding, {
		holdTime = 0.5,
		onTap = RemovePoint,
		onHeld = UndoChanges,
	});

	-- Apply changes --
	local applyChanges = GamepadSharedUtility.CreateTapOrHoldPromptedBinding(GAMEPAD_FACE_LEFT, 0.5, nil, ApplyChanges, GAMEPAD_TALENT_APPLY);
	applyChanges:AddCondition(CanApplyChanges);
	applyChanges:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	local applyChangesIcon = GamepadMode.AddGamepadIconToButton(talentFrame.ApplyButton, GAMEPAD_FACE_LEFT, { buttonHeightScale = (1.3), });
	GamepadMode.SetGamepadIconShown(applyChangesIcon, true);

	-- Navigate Section --
	self.navigateTalentSection = GamepadMode.CreateBindingGroup("ClassTalentsNavigateSection");
	self.navigateTalentSection:AddAxisBinding(GAMEPAD_STICK_LEFT, 
		function(x, y)
			self:NavigateSection(x, y, TalentFrameSectionHandlers);
		end
	);

	-- Toggle Tooltips --
	local tooltips = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_PRESS, nil, PROMPT_TOGGLE_TOOLTIPS);

	-- Navigate Elements --
	local navigateElements = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD, nil, FRAME_ACTION_NAVIGATE);

	-- Open Settings --
	local openSettings = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_RIGHT, GenerateFlatClosure(self.OpenTalentSettings, self), nil);
	openSettings:SetCustomPromptFrame(talentFrame.SettingsTopFaceIcon);

	-- Enter Searchbox --
	local enterSearchBox = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, function() talentFrame.SearchBox:SetFocus(); end, nil);
	enterSearchBox:SetCustomPromptFrame(talentFrame.SearchBoxIcon);

	self.classTalentsFrameFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "ClassTalentsFrameFooter");
	self.classTalentsFrameFooter:SetAnchorOffsets(0, -5);
	self.classTalentsFrameFooter:AddStandardBackPrompt(FRAME_ACTION_CLOSE);
	self.classTalentsFrameFooter:AddPromptedBinding(primarySpecTab);
	self.classTalentsFrameFooter:AddPromptedBinding(secondarySpecTab);
	self.classTalentsFrameFooter:AddPromptedBinding(addPoint);
	self.classTalentsFrameFooter:AddPromptedBinding(select);
	self.classTalentsFrameFooter:AddPromptedBinding(removePoint);
	self.classTalentsFrameFooter:AddPromptedBinding(undoChanges);
	self.classTalentsFrameFooter:AddPromptedBinding(applyChanges);
	self.classTalentsFrameFooter:AddPromptedBinding(tooltips);
	self.classTalentsFrameFooter:AddPromptedBinding(navigateElements);
	self.classTalentsFrameFooter:AddPromptedBinding(openSettings);
	self.classTalentsFrameFooter:AddPromptedBinding(enterSearchBox);
	self.classTalentsFrameFooter:AddStandardFrameControlManagerBindings(self);
	self.classTalentsFrameFooter:Finalize();
end

function PlayerSpellsFrameMixin:SetUpSearchGamepad(frame)
	local searchBox = frame.SearchBox;
	local searchPreview = frame.SearchPreviewContainer;

	local function ClearText()
		if searchBox then
			frame:ClearActiveSearchState();
			searchBox:SetFocus();
		end
	end

	local function HasText()
		if searchBox then
			return searchBox:GetText() ~= "";
		end
	end

	local function Back()
		if searchBox then
			searchBox:ClearFocus();
		end
	end

	local clear = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, ClearText, NARRATION_OBJECT_CLEAR_BUTTON);
	clear:AddCondition(HasText);
	local back = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, Back, BACK);
	local unfocusSearch = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, Back, nil);
	unfocusSearch:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.NEVER);

	local footerName = frame:GetParentKey().."SearchBoxFooter";
	local searchBoxFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, footerName);
	searchBoxFooter:AddStandardSelectPrompt(SEARCH);
	searchBoxFooter:AddPromptedBinding(clear);
	searchBoxFooter:AddPromptedBinding(back);
	searchBoxFooter:AddPromptedBinding(unfocusSearch);
	searchBoxFooter:Finalize();

	local function OnSearchBoxFocusGained(_, focusTarget)
		if focusTarget ~= searchBox then
			return;
		end

		searchBoxFooter:ShowAndActivateBindings();
	end

	local function OnSearchBoxFocusLost(_, focusTarget)
		if focusTarget ~= searchBox then
			return;
		end

		searchBoxFooter:HideAndDeactivateBindings();
	end

	local function OnSearchPreviewFocusGained(_, focusTarget)
		if focusTarget ~= searchPreview then
			return;
		end

		searchBoxFooter:SetParentFrame(searchPreview);
		searchBoxFooter:ShowAndActivateBindings();
	end

	local function OnSearchPreviewFocusLost(_, focusTarget)
		if focusTarget ~= searchPreview then
			return;
		end

		searchBoxFooter:SetParentFrame(searchBox);
		searchBoxFooter:HideAndDeactivateBindings();
	end

	searchBox.clearButton.smartNavigationIgnored = true;
	EventRegistry:RegisterCallback("SpellSearchBox.FocusedGained", OnSearchBoxFocusGained, frame);
	EventRegistry:RegisterCallback("SpellSearchBox.FocusedLost", OnSearchBoxFocusLost, frame); 
	EventRegistry:RegisterCallback("SpellSearchPreview.FocusedGained", OnSearchPreviewFocusGained, frame);
	EventRegistry:RegisterCallback("SpellSearchPreview.FocusedLost", OnSearchPreviewFocusLost, frame);
end

function PlayerSpellsFrameMixin:SetUpGamepad()
	-- Set up gamepad bindings for both frames, then conditionally activate based on which is shown
	self:SetUpSpellBookGamepad();
	self:SetUpClassTalentsGamepad();

	self:SetUpSearchGamepad(self.SpellBookFrame);
	self:SetUpSearchGamepad(self.TalentsFrame);
	
	local function OnSpellBookHitRightEdge(self)
		self.SpellBookFrame:GamepadSpellBookNextPage();
	end

	local function OnSpellBookHitLeftEdge(self)
		self.SpellBookFrame:GamepadSpellBookPreviousPage(true);
	end

	function PlayerSpellsFrame.UnfocusGamepad()
		SmartNavigation:UnregisterCallback("HitRightEdge", self);
		SmartNavigation:UnregisterCallback("HitLeftEdge", self);
		self.spellsFrameFooter:HideAndDeactivateBindings();
		self.classTalentsFrameFooter:HideAndDeactivateBindings();
		GamepadMode.DeactivateBindingGroup(self.navigateTalentSection);
		GamepadMode.DeactivateBindingGroup(self.navigateSpellBookSection);
	end

	function PlayerSpellsFrame.FocusGamepad()
		if self:IsFrameTabActive(PlayerSpellsUtil.FrameTabs.SpellBook) then
			SmartNavigation:RegisterCallback("HitRightEdge", OnSpellBookHitRightEdge, self);
			SmartNavigation:RegisterCallback("HitLeftEdge", OnSpellBookHitLeftEdge, self);
			self.spellsFrameFooter:ShowAndActivateBindings();
			GamepadMode.ActivateBindingGroup(self.navigateSpellBookSection);
		elseif self:IsFrameTabActive(PlayerSpellsUtil.FrameTabs.ClassTalents) then
			self.classTalentsFrameFooter:ShowAndActivateBindings();
			GamepadMode.ActivateBindingGroup(self.navigateTalentSection);
		end
	end
end

function PlayerSpellsFrameMixin:InitializeGamepad()
	-- Hide unnecessary Spellbook elements for gamepad.
	self.TabSystem:Hide();
	self.MaximizeMinimizeButton:Hide();
	self.CloseButton:Hide();
	self.SpellBookFrame.HelpPlateButton:Hide();
	self.SpellBookFrame.PagedSpellsFrame.PagingControls.PrevPageButton:Hide();
	self.SpellBookFrame.PagedSpellsFrame.PagingControls.NextPageButton:Hide();
	self.SpellBookFrame.SearchBox:ClearAllPoints();
	self.SpellBookFrame.SearchBox:SetPoint("RIGHT", self.SpellBookFrame.SettingsTopFaceIcon, "LEFT", -15, 0);

	self.TalentsFrame.UndoButton:ClearAllPoints();
	self.TalentsFrame.UndoButton:SetPoint("LEFT", self.TalentsFrame.GamepadUndoButton, "RIGHT");
	self.TalentsFrame.SearchOptionsDropdown:ClearAllPoints();
	self.TalentsFrame.SearchOptionsDropdown:SetPoint("BOTTOMRIGHT", self.TalentsFrame.BackgroundBorder, "TOPRIGHT", -5, 4);
	self.TalentsFrame.SearchBox:ClearAllPoints();
	self.TalentsFrame.SearchBox:SetPoint("RIGHT", self.TalentsFrame.SettingsTopFaceIcon, "LEFT", -10, 0);
end

function PlayerSpellsFrameMixin:UninitializeGamepad()
	-- Show Spellbook elements hidden for gamepad.
	self.TabSystem:Show();
	self.MaximizeMinimizeButton:Show();
	self.CloseButton:Show();
	self.SpellBookFrame.HelpPlateButton:Show();
	self.SpellBookFrame.PagedSpellsFrame.PagingControls.PrevPageButton:Show();
	self.SpellBookFrame.PagedSpellsFrame.PagingControls.NextPageButton:Show();
	self.SpellBookFrame.SearchBox:ClearAllPoints();
	self.SpellBookFrame.SearchBox:SetPoint("RIGHT", self.SpellBookFrame.SettingsDropdown, "LEFT", -5, 4);

	self.TalentsFrame.UndoButton:ClearAllPoints();
	self.TalentsFrame.UndoButton:SetPoint("CENTER", self.TalentsFrame.ResetButton, "CENTER");
	self.TalentsFrame.SearchBox:ClearAllPoints();
	self.TalentsFrame.SearchOptionsDropdown:ClearAllPoints();
	self.TalentsFrame.SearchBox:SetSearchBoxDefaultPosition();
end

function PlayerSpellsFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetUpGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end
