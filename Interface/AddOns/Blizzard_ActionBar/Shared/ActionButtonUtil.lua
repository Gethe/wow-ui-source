CURRENT_ACTIONBAR_PAGE = 1;
NUM_ACTIONBAR_PAGES = 6;
NUM_ACTIONBAR_BUTTONS = 12;
NUM_OVERRIDE_BUTTONS = 6;
NUM_SPECIAL_BUTTONS = 10;

-- Table of action bar pages and whether they're viewable or not
VIEWABLE_ACTION_BAR_PAGES = {1, 1, 1, 1, 1, 1};

ActionButtonUtil = {};

ActionButtonUtil.ActionBarActionStatus = {
	NotMissing = 1, 			-- Action is either Passive, unlearned, or is on an active bar
	MissingFromAllBars = 2,		-- Not on any action bar
	OnInactiveBonusBar = 3,		-- On a bar belonging to a different stance
	OnDisabledActionBar = 4,	-- On a bar that's been disabled via settings
};

ActionButtonUtil.ActionBarType = {
	MainActionBar = 1,
	MultiActionBar = 2,
	StanceBar = 3,
	PetBar = 4,
	PossessActionBar = 5,
	BonusBar = 6,
	VehicleBar = 16,
	TempShapeshiftBar = 17,
	OverrideBar = 18,
};

ActionButtonUtil.ActionBarButtonNames = {
	"ActionButton",
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBarLeftButton",
	"MultiBarRightButton",
	"MultiBar5Button",
	"MultiBar6Button",
	"MultiBar7Button",
};

function ActionButtonUtil.ShowAllActionButtonGrids()
	MainActionBar:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	MultiActionBar_ShowAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
end

function ActionButtonUtil.HideAllActionButtonGrids()
	MainActionBar:SetShowGrid(false, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	MultiActionBar_HideAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
end

function ActionButtonUtil.SetAllQuickKeybindButtonHighlights(show)
	-- Override me!
end

function ActionButtonUtil.ShowAllQuickKeybindButtonHighlights()
	ActionButtonUtil.SetAllQuickKeybindButtonHighlights(true);
end

function ActionButtonUtil.HideAllQuickKeybindButtonHighlights()
	ActionButtonUtil.SetAllQuickKeybindButtonHighlights(false);
end

-- Calculates page number for provided action bar slot index
function ActionButtonUtil.GetPageForSlot(slot)
	return math.floor((slot - 1) / NUM_ACTIONBAR_BUTTONS) + 1;
end

-- Returns true if spell is currently slotted into any active Action Bar
-- See GetMkbActionBarsForSpell for what constitutes active vs inactive
-- excludeNonPlayerBars = [BOOLEAN] -- Skips bars whose spells are not owned by the player (ex Pet, Possess, Vehicle, etc) (Default: false)
-- excludeSpecialPlayerBars = [BOOLEAN] -- Skips bars whose spells are owned by the player but not set by them (ie Stance) (Default: false)
function ActionButtonUtil.IsSpellOnAnyActiveMkbActionBar(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars)
	local barsWithSpell = ActionButtonUtil.GetMkbActionBarsForSpell(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars);
	if not barsWithSpell then
		return false;
	end

	for _, barEntry in pairs(barsWithSpell) do
		if barEntry.isActive then
			return true;
		end
	end

	return false;
end

--[[
--	Returns all Mkb action bars the spell is slotted into, their bar type, and their active status
--	excludeNonPlayerBars = [BOOLEAN] -- Skips bars whose spells are not owned by the player (ex Pet, Possess, Vehicle, etc) (Default: false)
--  excludeSpecialPlayerBars = [BOOLEAN] -- Skips bars whose spells are owned by the player but not set by them (ie Stance) (Default: false)
--	Bar types:
--		MainActionBar: Active if not hidden by OverrideBar AND (page 1 is not overriden by a special bar OR spell is on a page other than page 1)
--		MultiActionBar: Active if not disabled via Action Bar settings
--		StanceBar: Active if loaded and currently shown
--		PetBar: Active if loaded and currently shown
--		PossessActionBar: Active if loaded and currently shown
--		BonusBar: Active if specific bonus bar is actively overriding first page of MainActionBar, usually meaning player is in stance that bar belongs to
--		VehicleBar: Active if loaded and currently shown, either through OverrideBar or overriding first page of MainActionBar
--		TempShapeshiftBar: Active if loaded and currently shown as overriding first page of MainActionBar
--		OverrideBar = Active if loaded and currently shown, either through OverrideBar or overriding first page of MainActionBar
--]]
function ActionButtonUtil.GetMkbActionBarsForSpell(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars)
	local bars = {};

	-- First, get all action bar slots this spell is in, then we can determine which bars those slots are part of
	local playerActionBarSlots = C_ActionBar.FindSpellActionButtons(spellID, Enum.ActionBarSet.Mkb);
	if playerActionBarSlots ~= nil then
		ActionButtonUtil.AddPlayerActionBarsContainingSlots(playerActionBarSlots, bars, excludeNonPlayerBars);
	end

	-- FindSpellActionButtons does not cover special bars like Stance and Pet bars, so now check those
	if not excludeSpecialPlayerBars then
		if StanceBar then
			for i = 1, NUM_SPECIAL_BUTTONS do
				local stanceBtn = StanceBar.actionButtons[i];
				local stanceSpellID = select(4, GetShapeshiftFormInfo(stanceBtn:GetID()));
				if stanceSpellID == spellID then
					bars["stance"] = {barFrame = StanceBar:GetName(), barType = ActionButtonUtil.ActionBarType.StanceBar, isActive = StanceBar:IsShown()};
					break;
				end
			end
		end
	end
	if not excludeNonPlayerBars then
		if PetActionBar then
			-- C_ActionBar.GetPetActionPetBarIndices works with PetAction actionIDs, not their spellIDs, so can't use that here
			for i = 1, NUM_SPECIAL_BUTTONS do
				local petSpellID = select(7, GetPetActionInfo(i));
				if petSpellID == spellID then
					bars["pet"] = {barFrame = PetActionBar:GetName(), barType = ActionButtonUtil.ActionBarType.PetBar, isActive = PetActionBar:IsShown()};
					break;
				end
			end
		end
		if PossessActionBar then
			for i = 1, NUM_POSSESS_SLOTS do
				local possessSpellID = select(2, GetPossessInfo(i));
				if possessSpellID == spellID then
					bars["possess"] = {barFrame = PossessActionBar:GetName(), barType = ActionButtonUtil.ActionBarType.PossessActionBar, isActive = PossessActionBar:IsShown()};
					break;
				end
			end
		end
	end

	return not TableIsEmpty(bars) and bars or nil;
end

--[[
--	Returns all Mkb action bars the PetAction is slotted into, their bar type, and their active status
--  See ActionButtonUtil.GetMkbActionBarsForSpell for a breakdown of how active status is determined per bar type
-- ]]
function ActionButtonUtil.GetMkbActionBarsForPetAction(actionID)
	local bars = {};

	local playerActionBarSlots = C_ActionBar.FindPetActionButtons(actionID, Enum.ActionBarSet.Mkb);
	if playerActionBarSlots ~= nil then
		local excludeNonPlayerBars = false;
		ActionButtonUtil.AddPlayerActionBarsContainingSlots(playerActionBarSlots, bars, excludeNonPlayerBars);
	end

	local petActionBarSlots = C_ActionBar.GetPetActionPetBarIndices(actionID, Enum.ActionBarSet.Mkb);
	if petActionBarSlots then
		bars["pet"] = {barFrame = PetActionBar:GetName(), barType = ActionButtonUtil.ActionBarType.PetBar, isActive = PetActionBar:IsShown()};
	end

	return not TableIsEmpty(bars) and bars or nil;
end

--[[
--	Returns all Mkb action bars the Flyout is slotted into, their bar type, and their active status
--  See ActionButtonUtil.GetMkbActionBarsForSpell for a breakdown of how active status is determined per bar type
-- ]]
function ActionButtonUtil.GetMkbActionBarsForFlyout(actionID)
	local bars = {};

	local playerActionBarSlots = C_ActionBar.FindFlyoutActionButtons(actionID, Enum.ActionBarSet.Mkb);
	if playerActionBarSlots ~= nil then
		local excludeNonPlayerBars = false;
		ActionButtonUtil.AddPlayerActionBarsContainingSlots(playerActionBarSlots, bars, excludeNonPlayerBars);
	end

	return not TableIsEmpty(bars) and bars or nil;
end

function ActionButtonUtil.AddPlayerActionBarsContainingSlots(slots, bars, excludeNonPlayerBars)
	-- Pre-retrieve page numbers for various override bars
	local vehicleBarPage = C_ActionBar.GetVehicleBarIndex();
	local overrideBarPage = C_ActionBar.GetOverrideBarIndex();
	local tempShapeshiftBarPage = C_ActionBar.GetTempShapeshiftBarIndex();
	local currentBonusBarIndex = C_ActionBar.GetBonusBarIndex();

	local isMainActionBarActive = ActionBarController_GetCurrentActionBarState() == LE_ACTIONBAR_STATE_MAIN;
	local isMainActionBarDefaultFirstPageActive = isMainActionBarActive and not (C_ActionBar.HasBonusActionBar() or C_ActionBar.HasOverrideActionBar() or C_ActionBar.HasVehicleActionBar() or C_ActionBar.HasTempShapeshiftActionBar());

	for _, slot in ipairs(slots) do
		-- First, calculate the page for slot index, then we can find the bar using that page
		local page = ActionButtonUtil.GetPageForSlot(slot);
		if not bars[page] then
			local barEntry = nil;
			local multiActionBar = MultiActionBar_GetBarForPage(page);

			-- MultiActionBars
			if multiActionBar then
				barEntry = {
					barFrame = multiActionBar:GetName(),
					barType = ActionButtonUtil.ActionBarType.MultiActionBar,
					isActive = multiActionBar:IsShown() -- ActionBar IsShown is overriden to reflect whether it is disabled via settings
				};
			-- Various Override bars
			elseif not excludeNonPlayerBars and (page == vehicleBarPage or page == overrideBarPage or page == tempShapeshiftBarPage) then
				if OverrideActionBar and OverrideActionBar:IsShown() then
					barEntry = {barFrame = OverrideActionBar:GetName(), isActive = true};
				else
					barEntry = {barFrame = MainActionBar:GetName(), isActive = isMainActionBarActive};
				end

				if page == vehicleBarPage then
					barEntry.barType = ActionButtonUtil.ActionBarType.VehicleBar;
				elseif page == overrideBarPage then
					barEntry.barType = ActionButtonUtil.ActionBarType.OverrideBar;
				elseif page == tempShapeshiftBarPage then
					barEntry.barType = ActionButtonUtil.ActionBarType.TempShapeshiftBar;
				end
			else
				-- Bonus Bar
				local slotBonusBarIndex = C_ActionBar.GetBonusBarIndexForSlot(slot);
				if slotBonusBarIndex then
					barEntry = {
						barFrame = MainActionBar:GetName(),
						barType = ActionButtonUtil.ActionBarType.BonusBar,
						isActive = slotBonusBarIndex == currentBonusBarIndex -- Mismatched bonus bar indices likely means we're in a different stance
					};
				-- Default Primary Action Bar
				elseif VIEWABLE_ACTION_BAR_PAGES[page] == 1 then
					barEntry = {
						barFrame = MainActionBar:GetName(),
						barType = ActionButtonUtil.ActionBarType.MainActionBar,
						isActive = page ~= 1 or isMainActionBarDefaultFirstPageActive
					};
				end
			end

			if barEntry then
				bars[page] = barEntry;
			end
		end
	end
end

-- Returns first ActionButton frame found containing the provided spell
-- excludeNonPlayerBars = [BOOLEAN] -- Skips bars whose spells are not owned by the player (ex Pet, Possess, Vehicle, etc) (Default: false)
-- excludeSpecialPlayerBars = [BOOLEAN] -- Skips bars whose spells are owned by the player but not set by them (ie Stance) (Default: false)
function ActionButtonUtil.GetActionButtonBySpellID(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars)
	if type(spellID) ~= "number" then
		return nil;
	end

	for _, actionBar in ipairs(ActionButtonUtil.ActionBarButtonNames) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local btn = _G[actionBar..i];
			local _, actionSpellID = GetActionInfo(btn.action);

			if actionSpellID == spellID then
				return btn;
			end
		end
	end

	if not excludeSpecialPlayerBars then
		for i = 1, NUM_SPECIAL_BUTTONS do
			-- Stance Bar buttons
			local stanceBtn = StanceBar.actionButtons[i];
			local stanceSpellID = select(4, GetShapeshiftFormInfo(stanceBtn:GetID()));
			if stanceSpellID == spellID then
				return stanceBtn;
			end
		end
	end

	if not excludeNonPlayerBars then
		for i = 1, NUM_SPECIAL_BUTTONS do
			-- Pet Bar buttons
			local petBtn = PetActionBar.actionButtons[i];
			local petSpellID = select(7, GetPetActionInfo(i));
			if petSpellID == spellID then
				return petBtn;
			end
		end

		if PossessActionBar then
			for i = 1, NUM_POSSESS_SLOTS do
				local possessButton = PossessActionBar.actionButtons[i];
				local possessSpellID = select(2, GetPossessInfo(i));
				if possessSpellID == spellID then
					return possessButton;
				end
			end
		end
	end

	return nil;
end

-- Determine a standard action bar "status" based on the status of bars a spell is on, if any
function ActionButtonUtil.GetActionBarStatusForSpell(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars)
	if not spellID or C_Spell.IsSpellPassive(spellID) then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	if (InputUtil.IsMKBUIEnabled()) then
		local barsWithSpell = ActionButtonUtil.GetMkbActionBarsForSpell(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars);
		return ActionButtonUtil.GetActionBarStatusFromMkbBars(barsWithSpell);
	elseif (InputUtil.IsGamepadUIEnabled()) then
		return ActionButtonUtil.GetActionBarStatusForSpellFromGamepadBars(spellID, excludeSpecialPlayerBars);
	end

	return ActionButtonUtil.ActionBarActionStatus.NotMissing;
end

-- Determine a standard action bar "status" based on the status of bars a spell is on, if any
function ActionButtonUtil.GetActionBarStatusForPetAction(petActionID)
	if not petActionID or C_PetInfo.IsPetActionPassive(petActionID) then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	if (InputUtil.IsMKBUIEnabled()) then
		local barsWithPetAction = ActionButtonUtil.GetMkbActionBarsForPetAction(petActionID);
		return ActionButtonUtil.GetActionBarStatusFromMkbBars(barsWithPetAction);
	elseif (InputUtil.IsGamepadUIEnabled()) then
		return ActionButtonUtil.GetActionBarStatusForPetActionFromGamepadBars(petActionID);
	end

	return ActionButtonUtil.ActionBarActionStatus.NotMissing;
end

-- Determine a standard action bar "status" based on the status of bars a spell is on, if any
function ActionButtonUtil.GetActionBarStatusForFlyout(flyoutActionID)
	if not flyoutActionID then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	if (InputUtil.IsMKBUIEnabled()) then
		local barsWithFlyout = ActionButtonUtil.GetMkbActionBarsForFlyout(flyoutActionID);
		return ActionButtonUtil.GetActionBarStatusFromMkbBars(barsWithFlyout);
	elseif (InputUtil.IsGamepadUIEnabled()) then
		return ActionButtonUtil.GetActionBarStatusForFlyoutFromGamepadBars(flyoutActionID);
	end

	return ActionButtonUtil.ActionBarActionStatus.NotMissing;
end

function ActionButtonUtil.GetActionBarStatusFromMkbBars(barsWithAction)
	if not barsWithAction then
		return ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars;
	end

	-- Evaluate whether bars are active, and if not, what type of inactive bar
	local isOnInactiveBonusBar, isOnDisabledBar = false, false;
	for _, barEntry in pairs(barsWithAction) do
		if barEntry.isActive then
			return ActionButtonUtil.ActionBarActionStatus.NotMissing;
		end

		-- Inactive MultiActionBar means bar is disabled in settings
		if barEntry.barType == ActionButtonUtil.ActionBarType.MultiActionBar then
			isOnDisabledBar = true;
		-- Inactive Bonus Bar means bar belongs to a different stance
		elseif barEntry.barType == ActionButtonUtil.ActionBarType.BonusBar then
			isOnInactiveBonusBar = true;
		end
	end

	-- Action being on a disabled bar for all stances takes priority over being on another stance's bar
	if isOnDisabledBar then
		return ActionButtonUtil.ActionBarActionStatus.OnDisabledActionBar;
	elseif isOnInactiveBonusBar then
		return ActionButtonUtil.ActionBarActionStatus.OnInactiveBonusBar;
	else
		return ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars;
	end
end
local function IsSlotOnGamepadNormalBar(slot)
	local firstGamepadNormalBarsSlotIndex = C_GamepadUI.GetFirstGamepadActionStorageSlotIndex();
	local reservedSlotCount = Constants.GamepadActionBarConstants.NUM_RESERVED_SLOTS_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT
		* Constants.GamepadActionBarConstants.NUM_STANDARD_PAGES_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT;
	local endGamepadNormalBarsSlotIndex = firstGamepadNormalBarsSlotIndex
		+ Constants.GamepadActionBarConstants.NUM_PAGEABLE_SLOTS_PER_GAMEPAD_ACTION_BAR_PAGE_UNIT
		- reservedSlotCount;
	return slot >= firstGamepadNormalBarsSlotIndex and slot < endGamepadNormalBarsSlotIndex;
end

local function HasAnySlotOnGamepadActiveStanceBar(slots)
	if (not C_ActionBar.HasBonusActionBar()) then
		return false;
	end

	local firstGamepadActiveStanceSlotIndex = C_GamepadUI.GetFirstGamepadActionBarStorageSlotIndexForActiveStance();
	assert(firstGamepadActiveStanceSlotIndex, "A MKB bonus action bar is active which doesn't have a gamepad equivalent. Extend the gamepad action bar storage (ActionBarConstants.tag) to add additional slots for this bar.");
	local lastGamepadActiveStanceSlotIndex = firstGamepadActiveStanceSlotIndex + Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR - 1;

	for _, slot in ipairs(slots) do
		if (slot >= firstGamepadActiveStanceSlotIndex and slot <= lastGamepadActiveStanceSlotIndex) then
			return true;
		end
	end

	return false;
end

function ActionButtonUtil.GetActionBarStatusForSpellFromGamepadBars(spellID, excludeSpecialPlayerBars)
	-- Get the slots this spell is in across both normal and stance gamepad bars.
	local gamepadButtonsWithSpell = C_ActionBar.FindSpellActionButtons(spellID, Enum.ActionBarSet.Gamepad);
	if (not gamepadButtonsWithSpell) then
		return ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars;
	end

	if (IsSlotOnGamepadNormalBar(gamepadButtonsWithSpell[1])) then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	--[[
		If the first occurence of the slot was not on a normal gamepad bar then it must be on a stance bar, but
		those are being excluded from evaluation.
	]]
	if (excludeSpecialPlayerBars) then
		return ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars;
	end

	if (HasAnySlotOnGamepadActiveStanceBar(gamepadButtonsWithSpell)) then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	return ActionButtonUtil.ActionBarActionStatus.OnInactiveBonusBar;
end

function ActionButtonUtil.GetActionBarStatusForPetActionFromGamepadBars(petActionID)
	-- Is the pet action on the gamepad posseess bar?
	local gamepadPossessBarPetActionSlots = C_ActionBar.GetPetActionPetBarIndices(petActionID, Enum.ActionBarSet.Gamepad);
	if (gamepadPossessBarPetActionSlots) then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	local normalGamepadActionBarPetActionSlots = C_ActionBar.FindPetActionButtons(petActionID, Enum.ActionBarSet.Gamepad);
	if (not normalGamepadActionBarPetActionSlots) then
		return ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars;
	end

	-- Is the pet action on a normal or active stance gamepad bar?
	if (IsSlotOnGamepadNormalBar(normalGamepadActionBarPetActionSlots[1]) or HasAnySlotOnGamepadActiveStanceBar(normalGamepadActionBarPetActionSlots)) then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	return ActionButtonUtil.ActionBarActionStatus.OnInactiveBonusBar;
end

function ActionButtonUtil.GetActionBarStatusForFlyoutFromGamepadBars(flyoutActionID)
	local gamepadActionBarSlots = C_ActionBar.FindFlyoutActionButtons(flyoutActionID, Enum.ActionBarSet.Gamepad);
	if (not gamepadActionBarSlots) then
		return ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars;
	end

	if (IsSlotOnGamepadNormalBar(gamepadActionBarSlots[1]) or HasAnySlotOnGamepadActiveStanceBar(gamepadActionBarSlots)) then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	return ActionButtonUtil.ActionBarActionStatus.OnInactiveBonusBar;
end
