GamepadIconIntroTrackerMixin = {};

local PAGE_UNIT_SLOT_ID_PUSH_ORDER = {
	24, 21, 23, 22,		-- RT+face buttons
	12, 9, 11, 10,		-- LT+dpad buttons
	16, 13, 15, 14,		-- LT+face buttons
	20, 17, 19, 18,		-- RT+dpad buttons
	4, 1, 3, 2,			-- dpad buttons
	32, 29, 31, 30,		-- RT+LT+face buttons
	28, 25, 27, 26,		-- RT+LT+dpad buttons
};

local function GetOverrideBarForPageUnitSlot(pageUnit, pageUnitSlotID)
	local actionBars = pageUnit:GetPageableActionBarsInIndexOrder();
	local actionBarIndex = math.ceil(pageUnitSlotID / Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR);
	local actionBar = actionBars[actionBarIndex];

	if not actionBar then
		return;
	end

	local overrideSlotIndex = pageUnitSlotID - (actionBarIndex - 1) * Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR;

	for _, overrideBar in ipairs(pageUnit.overrideBars) do
		if overrideBar:IsBarActivelyOverridingActionBar(actionBar) then
			return overrideBar, overrideSlotIndex;
		end
	end
end

local function GetActionButtonName(gamepadPageNum, gamepadPageUnitSlotID)
	local gamepadBarIndex = math.floor((gamepadPageUnitSlotID - 1) / Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR) + 1;
	local gamepadBarButtonIndex = ((gamepadPageUnitSlotID - 1) % Constants.GamepadActionBarConstants.NUM_SLOTS_PER_GAMEPAD_ACTION_BAR) + 1;
	local directions = { "Top", "Left", "Right", "Bottom" };
	local direction = directions[gamepadBarIndex];
	return "GamepadMainActionBarFramePageUnit" .. direction .. "CenteredAnchor" .. direction .. "BarActionButton" .. tostring(gamepadBarButtonIndex);
end

function GamepadIconIntroTrackerMixin:OnLoad()
	self.iconList = {};

	local actionBarIconIntroDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.ActionbarIconIntroDisabled);
	if not actionBarIconIntroDisabled then
		self:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR");
		self:RegisterEvent("SPELL_PUSHED_TO_FLYOUT_ON_ACTIONBAR");
	end
end

function GamepadIconIntroTrackerMixin:OnEvent(event, ...)
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	if event == "SPELL_PUSHED_TO_ACTIONBAR" or event == "SPELL_PUSHED_TO_FLYOUT_ON_ACTIONBAR" then
		local spellID = ...;
		if not self:PushSpellToActionBar(spellID) then
			C_SpellBook.AbortSpellIntro(spellID);
		end
	end
end

function GamepadIconIntroTrackerMixin:PushSpellToActionBar(spellID)
	local slotIndex, gamepadPageNum, gamepadPageUnitSlotID = self:FindFreeVisibleSlot();
	if slotIndex == nil then
		return false;
	end

	local buttonName = GetActionButtonName(gamepadPageNum, gamepadPageUnitSlotID);
	local button = _G[buttonName];
	if not button then
		return false;
	end

	local icon = C_Spell.GetSpellTexture(spellID);
	local flyout = self:GetFreeIcon();

	flyout.icon.icon:SetTexture(icon);
	flyout.icon.spellID = spellID;
	flyout.icon.slot = slotIndex;
	flyout.icon.page = gamepadPageNum;
	flyout.icon.pageUnitSlotID = gamepadPageUnitSlotID;
	flyout.icon.button = button;
	flyout.icon.noHighlight = true;

	flyout:ClearAllPoints();
	flyout:SetPoint("CENTER", flyout.icon.button, 0, 0);
	flyout:SetFrameLevel(flyout.icon.button:GetFrameLevel() + 1);

	flyout.icon.flyin:Play(1);
	flyout.isFree = false;
	return true;
end

function GamepadIconIntroTrackerMixin:FindFreeVisibleSlot()
	local pageUnit = GamepadMainActionBarFrame.PageUnit;
	local visiblePageNum = pageUnit:GetCurrentPage();

	for _, pageUnitSlotID in ipairs(PAGE_UNIT_SLOT_ID_PUSH_ORDER) do
		-- Don't put two abilities in the same slot if queued too quickly
		if not self:IsSlotPending(visiblePageNum, pageUnitSlotID) then
			local overrideBar, overrideSlotIndex = GetOverrideBarForPageUnitSlot(pageUnit, pageUnitSlotID);
			local slotIndex;

			-- Only push spells onto the stance bar, no other override bar
			if overrideBar == GamepadMainActionBarFrame.PageUnit.actionBars.stanceBar then
				slotIndex = C_GamepadUI.GetFirstGamepadActionBarStorageSlotIndexForActiveStance() + overrideSlotIndex - 1;
			elseif not overrideBar then
				slotIndex = GamepadActionBarBindingUtil.GetGamepadStorageSlotIndexFromPageAndPageUnitSlotID(visiblePageNum, pageUnitSlotID);
			end

			if slotIndex and not C_ActionBar.HasAction(slotIndex) then
				-- It's fine to return the original slot ID even if we're pushing to an override
				-- bar as the bars will be overlapping, and the page number and slot ID is only
				-- used for finding out where on screen to push it to, as well as making sure we
				-- only push one thing there.
				return slotIndex, visiblePageNum, pageUnitSlotID;
			end
		end
	end
end

function GamepadIconIntroTrackerMixin:IsSlotPending(page, pageUnitSlotID)
	for _, v in ipairs(self.iconList) do
		if v.icon.page == page and v.icon.pageUnitSlotID == pageUnitSlotID then
			return true;
		end
	end

	return false;
end

function GamepadIconIntroTrackerMixin:GetFreeIcon()
	for _, v in ipairs(self.iconList) do
		if v.isFree then
			v.isFree = false;
			return v;
		end
	end

	local index = #self.iconList + 1;
	local icon = CreateFrame("FRAME", self:GetName() .. "Icon" .. tostring(index), UIParent, "IconIntroTemplate");

	self.iconList[index] = icon;

	icon.isFree = false;
	return icon;
end
