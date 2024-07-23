CURRENT_ACTIONBAR_PAGE = 1;
NUM_ACTIONBAR_PAGES = 6;
NUM_ACTIONBAR_BUTTONS = 12;
NUM_OVERRIDE_BUTTONS = 6;
NUM_SPECIAL_BUTTONS = 10;

-- Table of action bar pages and whether they're viewable or not
VIEWABLE_ACTION_BAR_PAGES = {1, 1, 1, 1, 1, 1};

local ActionBarButtonNames = {
	"ActionButton",
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBarLeftButton",
	"MultiBarRightButton",
	"MultiBar5Button",
	"MultiBar6Button",
	"MultiBar7Button",
}

local MicroButtonNames = {
	"CharacterMicroButton",
	"ProfessionMicroButton",
	"PlayerSpellsMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"GuildMicroButton",
	"LFDMicroButton",
	"CollectionsMicroButton",
	"EJMicroButton",
	"MainMenuMicroButton",
	"QuickJoinToastButton",
}

ActionButtonUtil = {};

ActionButtonUtil.ActionBarActionStatus = {
	NotMissing = 1, 			-- Action is either Passive, unlearned, or is on an active bar
	MissingFromAllBars = 2,		-- Not on any action bar
	OnInactiveBonusBar = 3,		-- On a bar belonging to a different stance
	OnDisabledActionBar = 4,	-- On a bar that's been disabled via settings
};

ActionButtonUtil.ActionBarType = {
	MainMenuBar = 1,
	MultiActionBar = 2,
	StanceBar = 3,
	PetBar = 4,
	PossessActionBar = 5,
	BonusBar = 6,
	VehicleBar = 16,
	TempShapeshiftBar = 17,
	OverrideBar = 18,
};

function ActionButtonUtil.ShowAllActionButtonGrids()
	MainMenuBar:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	MultiActionBar_ShowAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
end

function ActionButtonUtil.HideAllActionButtonGrids()
	MainMenuBar:SetShowGrid(false, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	MultiActionBar_HideAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
end

function ActionButtonUtil.SetAllQuickKeybindButtonHighlights(show)
	for _, actionBar in ipairs(ActionBarButtonNames) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			_G[actionBar..i]:DoModeChange(show);
		end
	end
	for i = 1, NUM_SPECIAL_BUTTONS do
		PetActionBar.actionButtons[i]:DoModeChange(show);
		StanceBar.actionButtons[i]:DoModeChange(show);
	end
	ExtraActionButton1:DoModeChange(show);
	MainMenuBar.ActionBarPageNumber.UpButton:DoModeChange(show);
	MainMenuBar.ActionBarPageNumber.DownButton:DoModeChange(show);

	for _, bagButton in MainMenuBarBagManager:EnumerateBagButtons() do
		bagButton:DoModeChange(show);
	end

	for _, microButton in ipairs(MicroButtonNames) do
		_G[microButton]:DoModeChange(show);
	end
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
-- See GetActionBarsForSpell for what constitutes active vs inactive
-- excludeNonPlayerBars = [BOOLEAN] -- Skips bars whose spells are not owned by the player (ex Pet, Possess, Vehicle, etc) (Default: false)
-- excludeSpecialPlayerBars = [BOOLEAN] -- Skips bars whose spells are owned by the player but not set by them (ie Stance) (Default: false)
function ActionButtonUtil.IsSpellOnAnyActiveActionBar(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars)
	local barsWithSpell = ActionButtonUtil.GetActionBarsForSpell(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars);
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
--	Returns all action bars the spell is slotted into, their bar type, and their active status
--	excludeNonPlayerBars = [BOOLEAN] -- Skips bars whose spells are not owned by the player (ex Pet, Possess, Vehicle, etc) (Default: false)
--  excludeSpecialPlayerBars = [BOOLEAN] -- Skips bars whose spells are owned by the player but not set by them (ie Stance) (Default: false)
--	Bar types:
--		MainMenuBar: Active if not hidden by OverrideBar AND (page 1 is not overriden by a special bar OR spell is on a page other than page 1)
--		MultiActionBar: Active if not disabled via Action Bar settings
--		StanceBar: Active if loaded and currently shown
--		PetBar: Active if loaded and currently shown
--		PossessActionBar: Active if loaded and currently shown
--		BonusBar: Active if specific bonus bar is actively overriding first page of MainMenuBar, usually meaning player is in stance that bar belongs to
--		VehicleBar: Active if loaded and currently shown, either through OverrideBar or overriding first page of MainMenuBar
--		TempShapeshiftBar: Active if loaded and currently shown as overriding first page of MainMenuBar
--		OverrideBar = Active if loaded and currently shown, either through OverrideBar or overriding first page of MainMenuBar
--]]
function ActionButtonUtil.GetActionBarsForSpell(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars)
	local bars = {};

	-- First, get all action bar slots this spell is in, then we can determine which bars those slots are part of
	local playerActionBarSlots = C_ActionBar.FindSpellActionButtons(spellID);
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
--	Returns all action bars the PetAction is slotted into, their bar type, and their active status
--  See ActionButtonUtil.GetActionBarsForSpell for a breakdown of how active status is determined per bar type
-- ]]
function ActionButtonUtil.GetActionBarsForPetAction(actionID)
	local bars = {};

	local playerActionBarSlots = C_ActionBar.FindPetActionButtons(actionID);
	if playerActionBarSlots ~= nil then
		local excludeNonPlayerBars = false;
		ActionButtonUtil.AddPlayerActionBarsContainingSlots(playerActionBarSlots, bars, excludeNonPlayerBars);
	end

	local petActionBarSlots = C_ActionBar.GetPetActionPetBarIndices(actionID);
	if petActionBarSlots then
		bars["pet"] = {barFrame = PetActionBar:GetName(), barType = ActionButtonUtil.ActionBarType.PetBar, isActive = PetActionBar:IsShown()};
	end

	return not TableIsEmpty(bars) and bars or nil;
end

--[[
--	Returns all action bars the Flyout is slotted into, their bar type, and their active status
--  See ActionButtonUtil.GetActionBarsForSpell for a breakdown of how active status is determined per bar type
-- ]]
function ActionButtonUtil.GetActionBarsForFlyout(actionID)
	local bars = {};

	local playerActionBarSlots = C_ActionBar.FindFlyoutActionButtons(actionID);
	if playerActionBarSlots ~= nil then
		local excludeNonPlayerBars = false;
		ActionButtonUtil.AddPlayerActionBarsContainingSlots(playerActionBarSlots, bars, excludeNonPlayerBars);
	end

	return not TableIsEmpty(bars) and bars or nil;
end

function ActionButtonUtil.AddPlayerActionBarsContainingSlots(slots, bars, excludeNonPlayerBars)
	-- Pre-retrieve page numbers for various override bars
	local vehicleBarPage = GetVehicleBarIndex();
	local overrideBarPage = GetOverrideBarIndex();
	local tempShapeshiftBarPage = GetTempShapeshiftBarIndex();
	local currentBonusBarIndex = GetBonusBarIndex();

	local isMainMenuBarActive = ActionBarController_GetCurrentActionBarState() == LE_ACTIONBAR_STATE_MAIN;
	local isMainMenuBarDefaultFirstPageActive = isMainMenuBarActive and not (HasBonusActionBar() or HasOverrideActionBar() or HasVehicleActionBar() or HasTempShapeshiftActionBar());

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
					barEntry = {barFrame = MainMenuBar:GetName(), isActive = isMainMenuBarActive};
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
						barFrame = MainMenuBar:GetName(),
						barType = ActionButtonUtil.ActionBarType.BonusBar,
						isActive = slotBonusBarIndex == currentBonusBarIndex -- Mismatched bonus bar indices likely means we're in a different stance
					};
				-- Default Primary Action Bar
				elseif VIEWABLE_ACTION_BAR_PAGES[page] == 1 then
					barEntry = {
						barFrame = MainMenuBar:GetName(),
						barType = ActionButtonUtil.ActionBarType.MainMenuBar,
						isActive = page ~= 1 or isMainMenuBarDefaultFirstPageActive
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

	for _, actionBar in ipairs(ActionBarButtonNames) do
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

	local barsWithSpell = ActionButtonUtil.GetActionBarsForSpell(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars);

	return ActionButtonUtil.GetActionBarStatusFromBars(barsWithSpell);
end

-- Determine a standard action bar "status" based on the status of bars a spell is on, if any
function ActionButtonUtil.GetActionBarStatusForPetAction(petActionID)
	if not petActionID or C_PetInfo.IsPetActionPassive(petActionID) then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	local barsWithPetAction = ActionButtonUtil.GetActionBarsForPetAction(petActionID);

	return ActionButtonUtil.GetActionBarStatusFromBars(barsWithPetAction);
end

-- Determine a standard action bar "status" based on the status of bars a spell is on, if any
function ActionButtonUtil.GetActionBarStatusForFlyout(flyoutActionID)
	if not flyoutActionID then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	local barsWithFlyout = ActionButtonUtil.GetActionBarsForFlyout(flyoutActionID);

	return ActionButtonUtil.GetActionBarStatusFromBars(barsWithFlyout);
end

function ActionButtonUtil.GetActionBarStatusFromBars(barsWithAction)
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