GamepadActionBarEditFrameMixin = {};

local EDIT_FRAME_MODES =
{
	BIND_ACTION = "BIND_ACTION",                                -- User is placing an action from an outside source in a slot, potentially overriding any action that is already bound.
	SELECT_ACTION_TO_PICKUP = "SELECT_ACTION_TO_PICKUP",		-- User doesn't have an action they have picked up previously to move.
	PLACE_OR_CLEAR_HELD_ACTION = "PLACE_OR_CLEAR_HELD_ACTION",  -- User is holding an action that was previously bound to a gamepad action bar slot. They can choose to move it to a new slot or clear the action.
	INACTIVE = "INACTIVE"                                       -- User is not in any bind or edit mode.
}

local EDIT_FRAME_DISPLAY_ACTION_TYPES =
{
	NONE = "NONE",
	SPELL = "SPELL",
	ITEM = "ITEM",
	MACRO = "MACRO",
	PETACTION = "PETACTION",
	FLYOUT = "FLYOUT",
	EQUIPMENTSET = "EQUIPMENTSET",
	OUTFIT = "OUTFIT",
	UNSPECIFIED = "UNSPECIFIED",
}

local FocusFX = require('.ActionBarFocusFX');

function GamepadActionBarEditFrameMixin:GetTooltip()
	return self.ActionTooltip;
end

function GamepadActionBarEditFrameMixin:OnLoad()
	self.clickHandlers = {};
	self.inputBindingGroups = {};

	self.displayedActionType = EDIT_FRAME_DISPLAY_ACTION_TYPES.NONE;
	self.activeMode = EDIT_FRAME_MODES.INACTIVE;

	self:InitializePageUnit();
	self:CreateInputBindingGroups();

	-- A button that when clicked causes the edit frame to enter edit mode.
	self.clickHandlers["EnterEditMode"] = GamepadSharedUtility.CreateDownClickButton("GamepadActionBarEditFrameEnterEditMode", self, GenerateClosure(self.EnterEditMode, self));

	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterUnitEvent("UNIT_PET", "player");

	self:UpdateButtonToListenFor();

	GamepadMode.FrameControlsManager:DisableFrameFocusPagingWhenFocused(self);

	-- Make tooltip invisible rather than making it Show/Hide so it does not need to be re-initialized every toggle
	self:GetTooltip():HookScript("OnShow", function(tooltip)
		tooltip:SetAlpha(GetCVarBool("GamepadDisableTooltips") and 0 or 1);
	end);

	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
end

function GamepadActionBarEditFrameMixin:OnEvent(event, ...)
	local arg1 = ...;
	if event == "UPDATE_BINDINGS" then
		self:UpdateButtonToListenFor();
	elseif (event == "UNIT_PET" and arg1 == "player") then
		if (self.displayedActionType == EDIT_FRAME_DISPLAY_ACTION_TYPES.PETACTION and not IsPetActive()) then
			if (self.activeMode == EDIT_FRAME_MODES.BIND_ACTION) then
				UIErrorsFrame:AddMessage(GAMEPAD_EDIT_FRAME_ABORT_BIND_PET_NOT_ACTIVE, RED_FONT_COLOR:GetRGB());
				self:ExitBindingMode();
			elseif (self.activeMode == EDIT_FRAME_MODES.PLACE_OR_CLEAR_HELD_ACTION) then
				UIErrorsFrame:AddMessage(GAMEPAD_EDIT_FRAME_ABORT_MOVE_PET_NOT_ACTIVE, RED_FONT_COLOR:GetRGB());
				self:TransitionToSelectActionToPickup();
			end
		end
	end
end

function GamepadActionBarEditFrameMixin:InitializeGamepad()
	EventUtil.ContinueOnVariablesLoaded(GenerateClosure(self.PostVariableSetUp, self));
end

function GamepadActionBarEditFrameMixin:PostVariableSetUp()
	self.PageUnit:RefreshCompactLayout();
end

--[[
	Building the list of buttons currently bound to the cross bars so they can be listened for when performing binding actions.
]]
function GamepadActionBarEditFrameMixin:UpdateButtonToListenFor()
	local bindings = { "GAMEPADACTIONBUTTON1", "GAMEPADACTIONBUTTON2", "GAMEPADACTIONBUTTON3", "GAMEPADACTIONBUTTON4", "GAMEPADACTIONBUTTON5", "GAMEPADACTIONBUTTON6", "GAMEPADACTIONBUTTON7", "GAMEPADACTIONBUTTON8" };

	self.buttonBindingInfos = {};

	for index, binding in ipairs(bindings) do
		local bindingInfo = {};
		bindingInfo.binding = binding;
		bindingInfo.gamepadKey = GetBindingKey(binding, 1);
		bindingInfo.buttonIndex = index;
		table.insert(self.buttonBindingInfos, bindingInfo);
	end
end

function GamepadActionBarEditFrameMixin:NextActionBarPage()
	self.PageUnit:ClickChangePageButton("LeftButton", true);
end

function GamepadActionBarEditFrameMixin:PreviousActionBarPage()
	self.PageUnit:ClickChangePageButton("RightButton", true);
end

function GamepadActionBarEditFrameMixin:CreateInputBindingGroups()
	local bindingGroups = self.inputBindingGroups;
	bindingGroups.bindingModeModified = GamepadMode.CreateBindingGroup("bindingModeModified");
	bindingGroups.bindingModeModified:BlockDpadAndFaceButtons();
	bindingGroups.bindingModeModified:BlockKeys({GAMEPAD_TRIGGER_RIGHT, GAMEPAD_TRIGGER_LEFT});
	bindingGroups.bindingModeModified:AddFunctionBinding(GAMEPAD_DPAD_LEFT, GenerateClosure(self.PreviousActionBarPage, self));
	bindingGroups.bindingModeModified:AddFunctionBinding(GAMEPAD_DPAD_RIGHT, GenerateClosure(self.NextActionBarPage, self));

	bindingGroups.editModeModified = GamepadMode.CreateBindingGroup("editModeModified");
	bindingGroups.editModeModified:BlockDpadAndFaceButtons();
	bindingGroups.editModeModified:BlockKeys({GAMEPAD_TRIGGER_RIGHT, GAMEPAD_TRIGGER_LEFT});
	bindingGroups.editModeModified:AddFunctionBinding(GAMEPAD_DPAD_LEFT, GenerateClosure(self.PreviousActionBarPage, self));
	bindingGroups.editModeModified:AddFunctionBinding(GAMEPAD_DPAD_RIGHT, GenerateClosure(self.NextActionBarPage, self));

	bindingGroups.inputBlockers = GamepadMode.CreateBindingGroup("inputBlockers");
	bindingGroups.inputBlockers:BlockKeys({GAMEPAD_STICK_LEFT_PRESS, GAMEPAD_MENU_LEFT});

	self:SetUpInfoFrameFooters();
end

function GamepadActionBarEditFrameMixin:ClearBindings()
	self.bindingModeFooter:HideAndDeactivateBindings();
	self.editModeFooter:HideAndDeactivateBindings();

	for _, bindingGroup in pairs(self.inputBindingGroups) do
		GamepadMode.DeactivateBindingGroup(bindingGroup);
	end
end

function GamepadActionBarEditFrameMixin:SetUpInfoFrameFooters()
	local function IsBindingAction(self)
		return self.activeMode == EDIT_FRAME_MODES.BIND_ACTION;
	end

	local function IsHoldingAction(self)
		return self.activeMode == EDIT_FRAME_MODES.PLACE_OR_CLEAR_HELD_ACTION;
	end

	local function IsNotSelectingAction(self)
		return self.activeMode ~= EDIT_FRAME_MODES.SELECT_ACTION_TO_PICKUP;
	end

	local function ToggleTooltips(self)
		-- Make tooltip invisible rather than making it Show/Hide so it does not need to be re-initialized every toggle
		local shouldDisable = not GetCVarBool("GamepadDisableTooltips");
		SetCVar("GamepadDisableTooltips", shouldDisable);
		self:GetTooltip():SetAlpha(shouldDisable and 0 or 1);
	end

	-- EditActionBarsInfoFrame Footers --
	local cancel = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, GenerateClosure(self.ExitActiveMode, self), FRAME_ACTION_CANCEL);
	self.editModeFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self.EditActionBarsInfoFrame, "EditModeFooter");
	self.editModeFooter:AddPromptedBinding(cancel);
	self.editModeFooter:Finalize();

	-- BindingInfoFrame Footers --
	local tooltips = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_PRESS,  GenerateClosure(ToggleTooltips, self), PROMPT_TOGGLE_TOOLTIPS);
	tooltips:AddCondition(GenerateClosure(IsNotSelectingAction, self));
	tooltips:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local back = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, GenerateClosure(self.ExitActiveMode, self), FRAME_ACTION_BACK);
	back:AddCondition(GenerateClosure(IsBindingAction, self));
	back:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local undoEdit = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, GenerateClosure(self.UndoEdit, self), FRAME_ACTION_CANCEL);
	undoEdit:AddCondition(GenerateClosure(IsHoldingAction, self));
	undoEdit:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local enterEditMode = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, GenerateClosure(self.SwitchFromBindingModeToEditMode, self), FRAME_ACTION_EDIT_ACTION_BAR);
	enterEditMode:AddCondition(GenerateClosure(IsBindingAction, self));
	enterEditMode:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local clearAction = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, GenerateClosure(self.TryClearHeldAction, self), FRAME_ACTION_UNBIND);
	clearAction:AddCondition(GenerateClosure(IsHoldingAction, self));
	clearAction:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	self.bindingModeFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self.BindingInfoFrame, "BindingModeFooter");
	self.bindingModeFooter:AddPromptedBinding(enterEditMode);
	self.bindingModeFooter:AddPromptedBinding(clearAction);
	self.bindingModeFooter:AddPromptedBinding(tooltips);
	self.bindingModeFooter:AddPromptedBinding(back);
	self.bindingModeFooter:AddPromptedBinding(undoEdit);
	self.bindingModeFooter:Finalize();
end

-- Places the tooltip to the right of the paging UI.
function GamepadActionBarEditFrameMixin:RepositionActionDisplayTooltip()
	local tooltip = self:GetTooltip();
	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", self.BindingInfoFrame, "TOPRIGHT", 5, -15);
end

--[[
	Updates the texture and tooltip for the edit frame's action displays.

	iconTexture - The FileID or the file path to the action's texture to be displayed to the left
				  of the action name text.

	tooltipSetterFunc - Function used by the tooltip in order to populate the action info depending
						on the action type. This function will be passed in this GamepadActionBarEditFrameMixin
						instance's tooltip frame and any additional arguments passed into this function (...) that
						are needed by the setter function.

	... - Any action type specific arguments needed by the tooltipSetterFunc to update the tooltip info.
]]
function GamepadActionBarEditFrameMixin:UpdateActionDisplay(name, iconTexture, tooltipSetterFunc, ...)
	-- Update the display icons.
	self.BindingInfoFrame.ActionName:SetText(name);
	self.BindingInfoFrame.ActionIcon:SetTexture(iconTexture);

	local tooltip = self:GetTooltip();
	tooltip:Show();
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:ClearLines();
	if (tooltipSetterFunc) then
		tooltipSetterFunc(tooltip, ...);
		self:RepositionActionDisplayTooltip();
	else
		tooltip:Hide();
	end
end

function GamepadActionBarEditFrameMixin:DisplaySpellBookItem(slotIndex, spellBank)
	local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, spellBank);
	self:UpdateActionDisplay(spellBookItemInfo.name, spellBookItemInfo.iconID, GameTooltip.SetSpellBookItem, slotIndex, spellBank);

	local typeMapping = {
		[Enum.SpellBookItemType.PetAction] = EDIT_FRAME_DISPLAY_ACTION_TYPES.PETACTION,
		[Enum.SpellBookItemType.Flyout] = EDIT_FRAME_DISPLAY_ACTION_TYPES.FLYOUT,
		[Enum.SpellBookItemType.Spell] = EDIT_FRAME_DISPLAY_ACTION_TYPES.SPELL,
	};

	self.displayedActionType = typeMapping[spellBookItemInfo.itemType] or EDIT_FRAME_DISPLAY_ACTION_TYPES.UNSPECIFIED;
end

function GamepadActionBarEditFrameMixin:DisplayItemAction(itemID)
	local itemActionName, _, _, _, _, _, _, _, _, itemActionTexture = C_Item.GetItemInfo(itemID);
	self:UpdateActionDisplay(itemActionName, itemActionTexture, GameTooltip.SetItemByID, itemID);
	self.displayedActionType = EDIT_FRAME_DISPLAY_ACTION_TYPES.ITEM;
end

function GamepadActionBarEditFrameMixin:DisplaySpellAction(spellID)
	local spellInfo = C_Spell.GetSpellInfo(spellID);
	self:UpdateActionDisplay(spellInfo.name, spellInfo.iconID, GameTooltip.SetSpellByID, spellID);
	self.displayedActionType = EDIT_FRAME_DISPLAY_ACTION_TYPES.SPELL;
end

function GamepadActionBarEditFrameMixin:DisplayMacroAction(macroIndex)
	local name, macroActionTexture = GetMacroInfo(macroIndex);
	self:UpdateActionDisplay(name, macroActionTexture, nil, nil);
	self.displayedActionType = EDIT_FRAME_DISPLAY_ACTION_TYPES.MACRO;
end

function GamepadActionBarEditFrameMixin:DisplayEquipmentSetAction(setID)
	local name, iconFileID = C_EquipmentSet.GetEquipmentSetInfo(setID);
	self:UpdateActionDisplay(name, iconFileID, GameTooltip.SetEquipmentSet, setID);
	self.displayedActionType = EDIT_FRAME_DISPLAY_ACTION_TYPES.EQUIPMENTSET;
end

function GamepadActionBarEditFrameMixin:DisplayOutfitAction(outfitID)
	if outfitID == 0 then
		local spellInfo = C_Spell.GetSpellInfo(Constants.TransmogOutfitDataConsts.CLEAR_TRANSMOG_OUTFIT_MANUAL_SPELL_ID);
		local iconID = spellInfo.iconID;
		self:UpdateActionDisplay(name, iconID, GameTooltip.SetSpellByID, Constants.TransmogOutfitDataConsts.CLEAR_TRANSMOG_OUTFIT_MANUAL_SPELL_ID);
	else
		local outfitInfo = C_TransmogOutfitInfo.GetOutfitInfo(outfitID);
		self:UpdateActionDisplay(outfitInfo.name, outfitInfo.icon, GameTooltip.SetOutfit, outfitID);
	end
	self.displayedActionType = EDIT_FRAME_DISPLAY_ACTION_TYPES.OUTFIT;
end

--[[
	When the LB modifier state changes the edit frame is responsible for adding or removing
	binding sets that enable/disable specific edit frame related actions depending on which
	mode it is in.
]]
function GamepadActionBarEditFrameMixin:OnInputModifierStateChanged(modifierPressed)
	if (self.activeMode == EDIT_FRAME_MODES.BIND_ACTION) then
		self:SetModifiedBindingModeActionsEnabled(modifierPressed);
	elseif (self.activeMode == EDIT_FRAME_MODES.SELECT_ACTION_TO_PICKUP or
			self.activeMode == EDIT_FRAME_MODES.PLACE_OR_CLEAR_HELD_ACTION) then
		self:SetModifiedEditingModeActionsEnabled(modifierPressed);
	end
end

function GamepadActionBarEditFrameMixin:OnShow()
	local mainPageUnit = GamepadMainActionBarFrame.PageUnit;

	GamepadMode.ActivateBindingGroup(self.inputBindingGroups.inputBlockers);

	-- Update the displayed page on the edit frame's page unit to that which was displayed on the main action bar's page unit
	local activePageOnMainActionBar = mainPageUnit:GetCurrentPage();
	self.PageUnit:SetCurrentPage(activePageOnMainActionBar);
	self.PageUnit.PageTracker:ClearAllPoints();
	self.PageUnit.PageTracker:SetPoint("BOTTOM", self.PageUnit.TopCenteredAnchor, "TOP", 60, 20);

	GamepadMainActionBarFrame:Hide();

	-- Update the active action bar based on what input the user is currently holding
	self.PageUnit:ActionBarModKeyDownStateCheck();
	self.PageUnit:StartListeningForModifierUpdates();

	GamepadPersistentInputLegend:RefreshVisibility();
end

function GamepadActionBarEditFrameMixin:OnHide()
	self:ExitActiveMode();
	self.PageUnit:StopListeningForModifierUpdates();

	local currentEditPage = self.PageUnit:GetCurrentPage();
	GamepadMainActionBarFrame.PageUnit:SetCurrentPage(currentEditPage);
	GamepadMainActionBarFrame:Show();
	GamepadMainActionBarFrame.PageUnit:ActionBarModKeyDownStateCheck();

	self:ClearBindings();
	GamepadPersistentInputLegend:RefreshVisibility();
end

--[[
	Starts listening for buttons that are tied to the cross bar so binding actions can be performed on them.
]]
function GamepadActionBarEditFrameMixin:StartListeningForButtons()
	self:SetScript("OnGamePadButtonDown", self.AttemptBindDown);
end

function GamepadActionBarEditFrameMixin:StopListeningForButtons()
	self:SetScript("OnGamePadButtonDown", nil);
end

------------------
-- BINDING MODE --
------------------

function GamepadActionBarEditFrameMixin:SetModifiedBindingModeActionsEnabled(enabled)
	if (enabled) then
		GamepadMode.ActivateBindingGroup(self.inputBindingGroups.bindingModeModified);
		self:StopListeningForButtons();
	else
		GamepadMode.DeactivateBindingGroup(self.inputBindingGroups.bindingModeModified);
		self:StartListeningForButtons();
	end
end

function GamepadActionBarEditFrameMixin:EnterBindingMode()
	-- If a frame is already suspended allow it to fall through. The Bind action has been called outside of the spellbook.
	if (not GamepadMode.FrameControlsManager:IsFrameSuspended()) then
		GamepadMode.FrameControlsManager:SuspendFrame();
	end

	self.activeMode = EDIT_FRAME_MODES.BIND_ACTION;
	self.BindingInfoFrame:Show();

	self.editModeFooter:HideAndDeactivateBindings();
	self.bindingModeFooter:ShowAndActivateBindings();

	ShowUIPanel(self);
	self:RepositionActionDisplayTooltip();

	-- Activate input capture controls.
	GamepadMode.SetOverrideAllowLeftRightModifiers(true);
	self:StartListeningForButtons();

	-- Start listening for LB modifier changes.
	GamepadMode.RegisterInputModifierStateChangeCallback(self.OnInputModifierStateChanged, self);
end

function GamepadActionBarEditFrameMixin:ExitBindingMode()
	self.activeMode = EDIT_FRAME_MODES.INACTIVE;
	self.displayedActionType = EDIT_FRAME_DISPLAY_ACTION_TYPES.NONE;
	self.BindingInfoFrame:Hide();
	self.bindingModeFooter:HideAndDeactivateBindings();

	-- Stop listening for LB modifier changes.
	GamepadMode.UnregisterInputModifierStateChangeCallback(self);

	-- Remove binding specific controls.
	self:SetModifiedBindingModeActionsEnabled(false);
	GamepadMode.SetOverrideAllowLeftRightModifiers(false);
	self:StopListeningForButtons();

	HideUIPanel(self);

	-- Resume frame focus on the suspended frame that started Edit Mode.
	GamepadMode.FrameControlsManager:UnsuspendFrame();
end

function GamepadActionBarEditFrameMixin:AttemptBindDown(gamepadKey)
	local propagateInput = true;

	--[[
		If the main menu radial is open, then we want its bindings on the binding stack to
		be used instead of the edit frame capturing the input
	]]
	if (GamepadRadial:IsShown()) then
		return propagateInput;
	end

	local actionBar = self.PageUnit:GetActiveBar();

	for _, bindingInfo in ipairs(self.buttonBindingInfos) do
		if (bindingInfo.gamepadKey == gamepadKey) then
			local actionButton = actionBar:GetActionButtonByIndex(bindingInfo.buttonIndex);
			propagateInput = not self:CaptureActionInput(actionButton);
		end
	end

	return propagateInput;
end

function GamepadActionBarEditFrameMixin:BindItem(itemID)
	self:DisplayItemAction(itemID);
	self:SetDisplayedActionPickupInfo(C_Item.PickupItem, itemID);
	self:EnterBindingMode();
end

function GamepadActionBarEditFrameMixin:BindSpell(spellID)
	self:DisplaySpellAction(spellID);
	self:SetDisplayedActionPickupInfo(C_Spell.PickupSpell, spellID);
	self:EnterBindingMode();
end

function GamepadActionBarEditFrameMixin:BindMacro(macroIndex)
	self:DisplayMacroAction(macroIndex);
	self:SetDisplayedActionPickupInfo(PickupMacro, macroIndex);
	self:EnterBindingMode();
end

function GamepadActionBarEditFrameMixin:BindSpellBookItem(slotIndex, spellBank)
	self:DisplaySpellBookItem(slotIndex, spellBank);
	self:SetDisplayedActionPickupInfo(C_SpellBook.PickupSpellBookItem, slotIndex, spellBank);
	self:EnterBindingMode();
end

function GamepadActionBarEditFrameMixin:BindEquipmentSet(setID)
	self:DisplayEquipmentSetAction(setID);
	self:SetDisplayedActionPickupInfo(C_EquipmentSet.PickupEquipmentSet, setID);
	self:EnterBindingMode();
end

function GamepadActionBarEditFrameMixin:BindOutfit(outfitID)
	self:DisplayOutfitAction(outfitID);
	self:SetDisplayedActionPickupInfo(C_TransmogOutfitInfo.PickupOutfit, outfitID);
	self:EnterBindingMode();
end

---------------
-- EDIT MODE --
---------------

function GamepadActionBarEditFrameMixin:SetModifiedEditingModeActionsEnabled(enabled)
	if (enabled) then
		GamepadMode.ActivateBindingGroup(self.inputBindingGroups.editModeModified);
		self:StopListeningForButtons();
	else
		GamepadMode.DeactivateBindingGroup(self.inputBindingGroups.editModeModified);
		self:StartListeningForButtons();
	end
end

function GamepadActionBarEditFrameMixin:EnterEditMode()
	-- If a frame is already suspended allow it to fall through. The Edit action has been called outside of the spellbook
	if (not GamepadMode.FrameControlsManager:IsFrameSuspended()) then
		GamepadMode.FrameControlsManager:SuspendFrame();
	end

	self:TransitionToSelectActionToPickup();
	ShowUIPanel(self);

	-- Activate input capture controls.
	GamepadMode.SetOverrideAllowLeftRightModifiers(true);
	self:StartListeningForButtons();

	-- Start listening for LB modifier changes.
	GamepadMode.RegisterInputModifierStateChangeCallback(self.OnInputModifierStateChanged, self);
end

function GamepadActionBarEditFrameMixin:ExitEditMode()
	self.activeMode = EDIT_FRAME_MODES.INACTIVE;
	self.EditActionBarsInfoFrame:Hide();
	self.editModeFooter:HideAndDeactivateBindings();

	-- Stop listening for LB modifier changes.
	GamepadMode.UnregisterInputModifierStateChangeCallback(self);

	-- Remove edit mode specific controls.
	self:SetModifiedEditingModeActionsEnabled(false);
	GamepadMode.SetOverrideAllowLeftRightModifiers(false);
	self:StopListeningForButtons();

	HideUIPanel(self);

	-- Resume frame focus on the suspended frame that started Edit Mode.
	GamepadMode.FrameControlsManager:UnsuspendFrame();
end

function GamepadActionBarEditFrameMixin:ShowEditModeFrameAndBindings()
	self.EditActionBarsInfoFrame:Show();
	self.BindingInfoFrame:Hide();
	self.editModeFooter:ShowAndActivateBindings();
	self.bindingModeFooter:HideAndDeactivateBindings();
end

function GamepadActionBarEditFrameMixin:ShowBindingModeFrameAndBindings()
	self.EditActionBarsInfoFrame:Hide();
	self.BindingInfoFrame:Show();
	self.editModeFooter:HideAndDeactivateBindings();
	self.bindingModeFooter:ShowAndActivateBindings();
end

function GamepadActionBarEditFrameMixin:UndoEdit()
	if self:PlaceOrClearHeldActionCapturedInputHandler(self.pickupSlot, self.pickupIsPossessBarButton) then
		self:TransitionToSelectActionToPickup()
	end
end

function GamepadActionBarEditFrameMixin:InitializePageUnit()
	local function IsActionBarUsable()
		return self:IsVisible();
	end

	local actionBars = self.PageUnit.actionBars;
	for _, actionBar in pairs(actionBars) do
		actionBar:SetIsActionBarUsableFunc(IsActionBarUsable);
		actionBar:SetShowCheckedStateOnExpand(true);
		actionBar:SetExpandSequence(CreateAndInitFromMixin(FocusFX.GamepadActionBarSequenceEditModeExpandMixin, actionBar));
		actionBar:SetCollapseSequence(CreateAndInitFromMixin(FocusFX.GamepadActionBarSequenceEditModeCollapseMixin, actionBar));
	end

	-- Keep the paging UI visible all the time.
	self.PageUnit.ShowActionBarPageTracker = function()
		GamepadActionBarPageUnitMixin.ShowActionBarPageTracker(self.PageUnit, true);
	end;
	self.PageUnit:ShowActionBarPageTracker();

	-- Always show all the bars in edit mode
	self.PageUnit:SetUseCompactLayout(false);

	-- This page unit doesn't need to display any button art other than the standard slot display.
	self.PageUnit:DisableActionButtonGameplayFeedback();

	self:SetupNonBindableActionArt(actionBars);
end

function GamepadActionBarEditFrameMixin:SetupNonBindableActionArt(actionBars)
	-- Desaturate special action icons and display 'permabound' texture
	local interactButton = actionBars.topBar.Right.ActionButton1;
	local interactButtonSpecialIcon = interactButton.SpecialActionIcon;
	local inspectButton = actionBars.topBar.Right.ActionButton2;
	local inspectButtonSpecialIcon = inspectButton.SpecialActionIcon;
	local backButton = actionBars.topBar.Right.ActionButton3;
	local backButtonSpecialIcon = backButton.SpecialActionIcon;
	local jumpButton = actionBars.topBar.Right.ActionButton4;
	local jumpButtonSpecialIcon = jumpButton.SpecialActionIcon;

	-- Interact
	local buttonIcon = interactButton.icon;
	buttonIcon:SetAlpha(0.0);
	interactButtonSpecialIcon:Show();
	interactButtonSpecialIcon:SetDesaturation(1.0);

	-- Inspect
	inspectButtonSpecialIcon:SetAtlas("crosshair_inspect_32");
	inspectButtonSpecialIcon:ClearAllPoints();
	inspectButtonSpecialIcon:SetPoint("TOPLEFT", inspectButton, "TOPLEFT", -3, 3);
	inspectButtonSpecialIcon:SetPoint("BOTTOMRIGHT", inspectButton, "BOTTOMRIGHT", 3, -3);
	inspectButtonSpecialIcon:Show();
	inspectButtonSpecialIcon:SetDesaturation(1.0);

	-- Back
	backButtonSpecialIcon:SetAtlas("128-redbutton-exit");
	backButtonSpecialIcon:ClearAllPoints();
	backButtonSpecialIcon:SetPoint("TOPLEFT", backButton, "TOPLEFT", -6, 6);
	backButtonSpecialIcon:SetPoint("BOTTOMRIGHT", backButton, "BOTTOMRIGHT", 6, -6);
	backButtonSpecialIcon:Show();
	backButtonSpecialIcon:SetDesaturation(1.0);

	-- Jump
	jumpButtonSpecialIcon:SetAtlas("gamepad-ability-icon-jump");
	jumpButtonSpecialIcon:Show();
	jumpButtonSpecialIcon:SetDesaturation(1.0);

	-- Show 'permabound' context overlay
	interactButton.PermaboundOverlay:Show();
	inspectButton.PermaboundOverlay:Show();
	backButton.PermaboundOverlay:Show();
	jumpButton.PermaboundOverlay:Show();
end

--[[
	This function is called when one of the buttons being listened for is pressed and performs the
	corresponding action based on which mode we are in.
]]
function GamepadActionBarEditFrameMixin:CaptureActionInput(button)
	local gamepadActionButtonStorageSlot = button:GetID();	-- Both standard and pet buttons will have their storage slots as their IDs.
	if gamepadActionButtonStorageSlot == 0 then	-- Non-bindable buttons have a storage slot of zero
		return false;
	end

	local capturedButtonIsGamepadPossessBarButton = self.PageUnit:IsPossessBarActiveBarForPageUnit();

	-- Charmed pets can't have their actions modified.
	if (capturedButtonIsGamepadPossessBarButton and UnitIsCharmed("pet")) then
		UIErrorsFrame:AddMessage(GAMEPAD_POSSESS_BAR_MODIFICATION_NOT_POSSIBLE, RED_FONT_COLOR:GetRGB());
		return false;
	end

	if (self.activeMode == EDIT_FRAME_MODES.BIND_ACTION) then
		self:PlaceOrClearHeldActionCapturedInputHandler(gamepadActionButtonStorageSlot, capturedButtonIsGamepadPossessBarButton, true);
	elseif (self.activeMode == EDIT_FRAME_MODES.SELECT_ACTION_TO_PICKUP) then
		if self:SelectActionToPickupCapturedInputHandler(gamepadActionButtonStorageSlot, capturedButtonIsGamepadPossessBarButton) then
			self:ShowBindingModeFrameAndBindings();
		end
	elseif (self.activeMode == EDIT_FRAME_MODES.PLACE_OR_CLEAR_HELD_ACTION) then
		self:PlaceOrClearHeldActionCapturedInputHandler(gamepadActionButtonStorageSlot, capturedButtonIsGamepadPossessBarButton, false);
	end

	return true;
end

--[[
	This input handler attempts to pick up an action in the interacted slot and transition the frame
	into the EDIT_FRAME_MODES.PLACE_OR_CLEAR_HELD_ACTION edit mode.

	gamepadActionButtonStorageSlot - The storage index of the gamepad action button whose action should be picked up.
									 For gamepad possess bar buttons this is the pet button id.

	capturedButtonIsGamepadPossessBarButton - Indicates that the captured input button was a button on the gamepad possess bar.
]]
function GamepadActionBarEditFrameMixin:SelectActionToPickupCapturedInputHandler(gamepadActionButtonStorageSlot, capturedButtonIsGamepadPossessBarButton)
	-- Start with an empty cursor.
	ClearCursor();

	if (capturedButtonIsGamepadPossessBarButton) then
		if (not C_GamepadUI.IsValidGamepadPossessBarStorageSlotIndex(gamepadActionButtonStorageSlot)) then
			return false;
		end

		-- Is the specified slot empty?
		local preMoveSlotInfo = { GetPetActionInfo(gamepadActionButtonStorageSlot) };
		if (#preMoveSlotInfo == 0) then
			-- Inform the user that the move action failed because the slot they specified had no action to move.
			UIErrorsFrame:AddMessage(GAMEPAD_EDIT_FRAME_ATTEMPTED_MOVE_EMPTY_SLOT, RED_FONT_COLOR:GetRGB());
			return false;
		end

		PickupPetAction(gamepadActionButtonStorageSlot);
	else
		if (not C_GamepadUI.IsValidGamepadActionStorageSlotIndex(gamepadActionButtonStorageSlot)) then
			return false;
		end

		-- Is the specified slot empty?
		local preMoveSlotInfo = { GetActionInfo(gamepadActionButtonStorageSlot) };
		if (#preMoveSlotInfo == 0) then
			-- Inform the user that the move action failed because the slot they specified had no action to move.
			UIErrorsFrame:AddMessage(GAMEPAD_EDIT_FRAME_ATTEMPTED_MOVE_EMPTY_SLOT, RED_FONT_COLOR:GetRGB());
			return false;
		end

		PickupAction(gamepadActionButtonStorageSlot);
	end

	-- Get information from the picked up action.
	local selectedActionInfo = { GetCursorInfo() };
	if (#selectedActionInfo == 0) then
		UIErrorsFrame:AddMessage(GAMEPAD_MOVE_ACTION_FAILURE_NO_PICK_UP, RED_FONT_COLOR:GetRGB());
		return false;
	end

	-- Prevent the player from picking up a pet action bound to a *NORMAL SLOT* which the active pet hasn't learned.
	if (selectedActionInfo[1] == "petaction" and selectedActionInfo[3] == 0) then
		self:RestoreSlot(gamepadActionButtonStorageSlot, capturedButtonIsGamepadPossessBarButton);
		UIErrorsFrame:AddMessage(GAMEPAD_MOVE_ACTION_FAILURE_UNKNOWN_PET_ACTION, RED_FONT_COLOR:GetRGB());
		return false;
	end

	--[[
		Verify that we can move actions of this type: Should never enter as long as all supported action types exist.
		If a action type is not supported, add support for it.
	]]
	local actionType = selectedActionInfo[1];
	local selectedActionDisplayFunc = self.EDIT_FRAME_MOVE_DISPLAY_UPDATE_FUNC[actionType];
	if (not selectedActionDisplayFunc) then
		error("Moving " .. actionType .. " actions is not currently supported.");
		-- Restore original slot
		self:RestoreSlot(gamepadActionButtonStorageSlot, capturedButtonIsGamepadPossessBarButton);
		return false;
	end

	-- Store pickup information for undo/clear
	self.pickupSlot = gamepadActionButtonStorageSlot;
	self.pickupIsPossessBarButton = capturedButtonIsGamepadPossessBarButton;
	self.unbindErrorMessage = GamepadActionBarBindingUtil.GetUnbindErrorMessage(selectedActionInfo);

	ClearCursor();	-- We have stored the necessary info we needed, and the action is being moved so the slot should remain clear.

	-- Transition into the PLACE_OR_CLEAR_HELD_ACTION state
	self.activeMode = EDIT_FRAME_MODES.PLACE_OR_CLEAR_HELD_ACTION;
	selectedActionDisplayFunc(self, selectedActionInfo);
	self.bindingModeFooter:Refresh();

	return true;
end

--[[
	This input handler is called when the player has an action selected for movement and interacts with a gamepad
	button to place the action in a new slot. If the slot is empty the state will transition to SELECT_ACTION_TO_PICKUP
	or if the slot has an existing action that action will be picked up and the state will remain as PLACE_OR_CLEAR_HELD_ACTION.

	gamepadActionButtonStorageSlot - The storage index of the gamepad action button whose action should be picked up.
									 For gamepad possess bar buttons this is the pet button id.

	capturedButtonIsGamepadPossessBarButton - Indicates that the captured input button was a button on the gamepad possess bar.
]]
function GamepadActionBarEditFrameMixin:PlaceOrClearHeldActionCapturedInputHandler(gamepadActionButtonStorageSlot,
																				   capturedButtonIsGamepadPossessBarButton,
																				   exitOnBind)
	local prePlacementSlotInfo;

	if (capturedButtonIsGamepadPossessBarButton) then
		if (not C_GamepadUI.IsValidGamepadPossessBarStorageSlotIndex(gamepadActionButtonStorageSlot)) then
			return false;
		end

		-- Get any info on the action currently stored in the slot we are placing the action in.
		prePlacementSlotInfo = { GetPetActionInfo(gamepadActionButtonStorageSlot) };
	else
		if (not C_GamepadUI.IsValidGamepadActionStorageSlotIndex(gamepadActionButtonStorageSlot)) then
			return false;
		end

		-- Get any info on the action currently stored in the slot we are placing the action in.
		prePlacementSlotInfo = { GetActionInfo(gamepadActionButtonStorageSlot) };
	end

	-- If the slot we are placing the action into is empty, proceed to bind.
	if (#prePlacementSlotInfo == 0) then
		local wasBound = false;
		if (capturedButtonIsGamepadPossessBarButton) then
			wasBound = GamepadActionBarBindingUtil.AssignActionToGamepadPossessBarSlot(gamepadActionButtonStorageSlot, self.pickupFunc, unpack(self.pickupParams));
		else
			wasBound = GamepadActionBarBindingUtil.AssignActionToGamepadStandardSlot(gamepadActionButtonStorageSlot, self.pickupFunc, unpack(self.pickupParams));
			if (not wasBound) then
				return false;
			end
		end

		if wasBound then
			if exitOnBind then
				self:ExitBindingMode();
			else
				self:TransitionToSelectActionToPickup();
			end
			return true;
		end
		return false;
	end

	--[[
		Verify that we can move actions of this type: Should never enter as long as all supported action types exist.
		If a action type is not supported, add support for it.
	]]
	local prePlacementSlotActionType;
	if (capturedButtonIsGamepadPossessBarButton) then
		prePlacementSlotActionType = "petaction";
	else
		prePlacementSlotActionType = prePlacementSlotInfo[1];
		if (prePlacementSlotActionType == "spell" and prePlacementSlotInfo[3] == "pet") then
			prePlacementSlotActionType = "petaction";
		end

		-- If the macro id still exists on the bar but the macro definition itself no longer exists then clear the action from the slot
		-- so we can bind to an empty slot.
		if (prePlacementSlotActionType == "macro") and (prePlacementSlotInfo[2] == 0) then
			PickupAction(gamepadActionButtonStorageSlot);
			ClearCursor();
			self:PlaceOrClearHeldActionCapturedInputHandler(gamepadActionButtonStorageSlot, capturedButtonIsGamepadPossessBarButton, exitOnBind);
			return;
		end
	end

	local selectedActionDisplayFunc = self.EDIT_FRAME_MOVE_DISPLAY_UPDATE_FUNC[prePlacementSlotActionType];
	if (not selectedActionDisplayFunc) then
		error("Cannot place this action because moving " .. prePlacementSlotActionType .. " actions is not currently supported.");
		return false;
	end

	-- Pickup the action that is in the stored slot now that we are sure that we can place it in a new slot if needed.
	if (capturedButtonIsGamepadPossessBarButton) then
		PickupPetAction(gamepadActionButtonStorageSlot);
	else
		PickupAction(gamepadActionButtonStorageSlot);
	end
	local previouslyBoundActionCursorInfo = { GetCursorInfo() };

	-- Error handling
	if (#previouslyBoundActionCursorInfo == 0) then
		return false; -- Couldn't pick up the existing bound action for some reason.
	elseif (previouslyBoundActionCursorInfo[1] == "petaction" and previouslyBoundActionCursorInfo[3] == 0) then
		-- We won't be able to rebind the specific action in this slot because the active pet can't retrieve it from the spellbook as it is unknown.
		self:RestoreSlot(gamepadActionButtonStorageSlot, capturedButtonIsGamepadPossessBarButton);
		UIErrorsFrame:AddMessage(GAMEPAD_MOVE_ACTION_FAILURE_UNKNOWN_PET_ACTION, RED_FONT_COLOR:GetRGB());
		return false;
	end

	ClearCursor();	-- All the information we should need to rebind the action is stored in the previouslyBoundActionCursorInfo table.

	-- Attempt to bind the action being moved into the specified slot.
	local wasActionToMoveBound = false;
	if (capturedButtonIsGamepadPossessBarButton) then
		wasActionToMoveBound = GamepadActionBarBindingUtil.AssignActionToGamepadPossessBarSlot(gamepadActionButtonStorageSlot, self.pickupFunc, unpack(self.pickupParams));
	else
		wasActionToMoveBound = GamepadActionBarBindingUtil.AssignActionToGamepadStandardSlot(gamepadActionButtonStorageSlot, self.pickupFunc, unpack(self.pickupParams));
	end

	-- If the binding failed, attempt to place the previously bound action back into its slot.
	if (not wasActionToMoveBound) then
		ClearCursor(); -- Clear the cursor for the pickup function for the failed action.
		self.pickupFunc(unpack(self.pickupParams)); -- Place failed action on cursor
		local failedActionCursorInfo = { GetCursorInfo() };
		ClearCursor(); -- Clear the cursor for the pickup function for the old action.

		-- Rebind old action.
		selectedActionDisplayFunc(self, previouslyBoundActionCursorInfo);
		local rebindingSucceeded = false;
		if (capturedButtonIsGamepadPossessBarButton) then
			rebindingSucceeded = GamepadActionBarBindingUtil.AssignActionToGamepadPossessBarSlot(gamepadActionButtonStorageSlot, self.pickupFunc, unpack(self.pickupParams));
		else
			rebindingSucceeded = GamepadActionBarBindingUtil.AssignActionToGamepadStandardSlot(gamepadActionButtonStorageSlot, self.pickupFunc, unpack(self.pickupParams));
		end

		if (not rebindingSucceeded) then
			UIErrorsFrame:AddMessage(GAMEPAD_BIND_FAILURE_FAILED_REBIND_OLD_ACTION, RED_FONT_COLOR:GetRGB());
			ClearCursor();
		end

		if (#failedActionCursorInfo == 0) then
			UIErrorsFrame:AddMessage(GAMEPAD_MOVE_ACTION_FAILURE_PLACEMENT_NO_LONGER_AVAILABLE, RED_FONT_COLOR:GetRGB());
			self:TransitionToSelectActionToPickup();
			return false;
		end

		-- Update the display back to the failed action for another move attempt.
		local failedActionType = failedActionCursorInfo[1];
		local failedActionDisplayFunc = self.EDIT_FRAME_MOVE_DISPLAY_UPDATE_FUNC[failedActionType];
		failedActionDisplayFunc(self, failedActionCursorInfo);
		return false;
	end

	--[[
		Remain in the PLACE_OR_CLEAR_HELD_ACTION mode, but update the
		displayed action to the action that was picked up from the slot
		the player placed their selected action in.
	]]
	selectedActionDisplayFunc(self, previouslyBoundActionCursorInfo);
	return true;
end

--[[
	Restores a slot after a failed PickupAction / PickupPetAction.
	Standard slots require PlaceAction, pet slots require PickupPetAction
]]
function GamepadActionBarEditFrameMixin:RestoreSlot(slot, isPossess)
	if isPossess then
		PickupPetAction(slot);
	else
		PlaceAction(slot);
	end
end

function GamepadActionBarEditFrameMixin:TransitionToSelectActionToPickup()
	self.activeMode = EDIT_FRAME_MODES.SELECT_ACTION_TO_PICKUP;
	self.displayedActionType = EDIT_FRAME_DISPLAY_ACTION_TYPES.NONE;
	self.ActionTooltip:Hide();
	self:ShowEditModeFrameAndBindings();
end

function GamepadActionBarEditFrameMixin:UpdateSelectedMoveDisplay_Spell(selectedActionInfo)
	local spellID = selectedActionInfo[4];
	self:DisplaySpellAction(spellID);
	self:SetDisplayedActionPickupInfo(C_Spell.PickupSpell, spellID);
end

function GamepadActionBarEditFrameMixin:UpdateSelectedMoveDisplay_Item(selectedActionInfo)
	local itemID = selectedActionInfo[2];
	self:DisplayItemAction(itemID);
	self:SetDisplayedActionPickupInfo(C_Item.PickupItem, itemID);
end

function GamepadActionBarEditFrameMixin:UpdateSelectedMoveDisplay_PetAction(selectedActionInfo)
	local spellBookSlotIndex = selectedActionInfo[3];
	self:DisplaySpellBookItem(spellBookSlotIndex, Enum.SpellBookSpellBank.Pet);
	self:SetDisplayedActionPickupInfo(C_SpellBook.PickupSpellBookItem, spellBookSlotIndex, Enum.SpellBookSpellBank.Pet);
end

function GamepadActionBarEditFrameMixin:UpdateSelectedMoveDisplay_Flyout(selectedActionInfo)
	local spellBookSlotIndex = selectedActionInfo[4];
	self:DisplaySpellBookItem(spellBookSlotIndex, Enum.SpellBookSpellBank.Player);
	self:SetDisplayedActionPickupInfo(C_SpellBook.PickupSpellBookItem, spellBookSlotIndex, Enum.SpellBookSpellBank.Player);
end

function GamepadActionBarEditFrameMixin:UpdateSelectedMoveDisplay_EquipmentSet(selectedActionInfo)
	local equipmentSetName = selectedActionInfo[2];
	local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(equipmentSetName);
	self:DisplayEquipmentSetAction(equipmentSetID);
	self:SetDisplayedActionPickupInfo(C_EquipmentSet.PickupEquipmentSet, equipmentSetID);
end

function GamepadActionBarEditFrameMixin:UpdateSelectedMoveDisplay_Outfit(selectedActionInfo)
	local outfitID = selectedActionInfo[2];
	self:DisplayOutfitAction(outfitID);
	self:SetDisplayedActionPickupInfo(C_TransmogOutfitInfo.PickupOutfit, outfitID);
end

GamepadActionBarEditFrameMixin.EDIT_FRAME_MOVE_DISPLAY_UPDATE_FUNC =
{
	spell = GamepadActionBarEditFrameMixin.UpdateSelectedMoveDisplay_Spell,
	item = GamepadActionBarEditFrameMixin.UpdateSelectedMoveDisplay_Item,
	petaction = GamepadActionBarEditFrameMixin.UpdateSelectedMoveDisplay_PetAction,
	flyout = GamepadActionBarEditFrameMixin.UpdateSelectedMoveDisplay_Flyout,
	equipmentset = GamepadActionBarEditFrameMixin.UpdateSelectedMoveDisplay_EquipmentSet,
	outfit = GamepadActionBarEditFrameMixin.UpdateSelectedMoveDisplay_Outfit
}

--[[
	Stores the necessary pickup related info for the type of action we are displaying.
	This information is used in the binding process to pass along to the binding utility.

	actionPickupFunc - The function that can be used to pickup an action and place it on the cursor.

	... - Any parameters that need to be passed into the pickup function for the displayed action's type.
]]
function GamepadActionBarEditFrameMixin:SetDisplayedActionPickupInfo(actionPickupFunc, ...)
	self.pickupFunc = actionPickupFunc;
	self.pickupParams = {...};
end

function GamepadActionBarEditFrameMixin:UnFocusGamepad()
	self:ExitActiveMode();
end

function GamepadActionBarEditFrameMixin:TryClearHeldAction()
	-- We can only "clear" an action if one is held.
	if (self.activeMode == EDIT_FRAME_MODES.PLACE_OR_CLEAR_HELD_ACTION) then
		if self.unbindErrorMessage then
			UIErrorsFrame:AddMessage(self.unbindErrorMessage, RED_FONT_COLOR:GetRGB());
			return;
		end

		self:TransitionToSelectActionToPickup();
	end
end

function GamepadActionBarEditFrameMixin:SwitchFromBindingModeToEditMode()
	self:ExitBindingMode();
	self:EnterEditMode();
end

function GamepadActionBarEditFrameMixin:ExitActiveMode()
	if self.activeMode ~= EDIT_FRAME_MODES.INACTIVE then
		local inBindMode = self.activeMode == EDIT_FRAME_MODES.BIND_ACTION;
		local inEditMode = self.activeMode == EDIT_FRAME_MODES.SELECT_ACTION_TO_PICKUP or self.activeMode == EDIT_FRAME_MODES.PLACE_OR_CLEAR_HELD_ACTION;

		if inBindMode then
			self:ExitBindingMode();
		elseif inEditMode then
			self:ExitEditMode();
		end
	end
end

-----------------------------------------------------
-- GamepadActionBarEditFrameInfoFrameTitleBoxMixin --
-----------------------------------------------------
GamepadActionBarEditFrameInfoFrameTitleBoxMixin = {};

function GamepadActionBarEditFrameInfoFrameTitleBoxMixin:OnLoad()
	self.TitleText:SetText(self.Title);
	local width = self.TitleText:GetWidth() + 60;
	local height = self.TitleText:GetHeight() + 34;
	self:SetSize(width, height);
end
