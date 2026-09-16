local Shared = require(".Shared");
local StaticOverrideActionBarMixin = require(".StaticOverrideActionBar");

local AUTO_SHOT_SPELL_ID = 75;
local SHOOT_RANGED_WEAPON_SPELL_ID_MAPPING = {
	[Enum.ItemWeaponSubclass.Bows] = 2480,
	[Enum.ItemWeaponSubclass.Guns] = 7918,
	[Enum.ItemWeaponSubclass.Thrown] = 2764,
	[Enum.ItemWeaponSubclass.Crossbow] = 7919,
	[Enum.ItemWeaponSubclass.Wand] = 5019,
};

GamepadHostileTargetingActionBarMixin = CreateFromMixins(StaticOverrideActionBarMixin);

function GamepadHostileTargetingActionBarMixin:OnLoad()
	self.swapLeftAndRightCvar = "GamepadSwapHostileTargetActions";
	GamepadMode.RegisterTargetModifierStateChanged(self.OnTargetModifierStateChanged, self);
	GamepadMode.RegisterTargetModifierStateCancelled(self.OnTargetModifierStateCancelled, self);
	StaticOverrideActionBarMixin.OnLoad(self);
end

function GamepadHostileTargetingActionBarMixin:OnTargetModifierStateChanged(newState)
	self:ActivateOrDeactivateOverrideBar(newState == GamepadTargetingState.HOSTILE);
end

function GamepadHostileTargetingActionBarMixin:OnTargetModifierStateCancelled(prevState)
	if prevState == GamepadTargetingState.HOSTILE then
		self:DeactivateOverrideBar();
	end
end

function GamepadHostileTargetingActionBarMixin:OnShow()
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("START_AUTOREPEAT_SPELL");
	self:RegisterEvent("STOP_AUTOREPEAT_SPELL");
	self:RegisterUnitEvent("UNIT_TARGET", "target");

	self:RefreshAssistButton();
	self:RefreshShootButton();

	GamepadMainActionBarFrame:SetShoulderIcons("gamepad-targeting-shortcuts", "gamepad-targeting-hostile");
end

function GamepadHostileTargetingActionBarMixin:OnHide()
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("PLAYER_TARGET_CHANGED");
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	self:UnregisterEvent("START_AUTOREPEAT_SPELL");
	self:UnregisterEvent("STOP_AUTOREPEAT_SPELL");
	self:UnregisterEvent("UNIT_TARGET");

	self:SetRangedButtonRangeCheckTimerEnabled(false);

	GamepadMainActionBarFrame:ResetShoulderIcons();
end

function GamepadHostileTargetingActionBarMixin:OnEvent(event, ...)
	local handler = self[event];
	if handler then
		handler(self, ...);
	end
end

function GamepadHostileTargetingActionBarMixin:PLAYER_EQUIPMENT_CHANGED()
	self:RefreshShootButton();
end

function GamepadHostileTargetingActionBarMixin:PLAYER_TARGET_CHANGED()
	self:RefreshAssistButton();
end

function GamepadHostileTargetingActionBarMixin:SPELL_UPDATE_COOLDOWN(spellID)
	if spellID == self.rangedSpellID then
		ActionButton_UpdateCooldown(self.faceLeftButton);
	end
end

function GamepadHostileTargetingActionBarMixin:START_AUTOREPEAT_SPELL()
	self.faceLeftButton:UpdateFlash();
	self.faceLeftButton:UpdateState();
end

function GamepadHostileTargetingActionBarMixin:STOP_AUTOREPEAT_SPELL()
	self.faceLeftButton:UpdateFlash();
	self.faceLeftButton:UpdateState();
end

function GamepadHostileTargetingActionBarMixin:UNIT_TARGET(unitTarget)
	if unitTarget == "target" then
		self:RefreshAssistButton();
	end
end

function GamepadHostileTargetingActionBarMixin:RefreshAssistButton()
	Shared.RefreshAssistButton(self, self.faceRightButton);
end

function GamepadHostileTargetingActionBarMixin:RefreshShootButton()
	local rangedWeaponID = GetInventoryItemID("player", INVSLOT_RANGED);

	self.rangedSpellID = nil;

	if rangedWeaponID then
		if UnitClassBase("player") == "HUNTER" then
			self.rangedSpellID = AUTO_SHOT_SPELL_ID;
		else
			local _, _, _, _, _, itemClassID, itemSubclassID = C_Item.GetItemInfoInstant(rangedWeaponID);
			local isWeapon = itemClassID == Enum.ItemClass.Weapon;
			self.rangedSpellID = isWeapon and SHOOT_RANGED_WEAPON_SPELL_ID_MAPPING[itemSubclassID];
		end
	end

	if self.rangedSpellID and not C_SpellBook.IsSpellKnown(self.rangedSpellID) then
		self.rangedSpellID = nil;
	end

	if self.rangedSpellID then
		local iconID = C_Spell.GetSpellTexture(self.rangedSpellID);
		self.faceLeftButton.SpecialActionIcon:SetTexture(iconID);
		self.faceLeftButton:SetAttribute("type", "spell");
		self.faceLeftButton:SetAttribute("spell", self.rangedSpellID);
	end

	self.faceLeftButton.spellID = self.rangedSpellID;
	self.faceLeftButton.SpecialActionIcon:SetShown(self.rangedSpellID);
	self:SetButtonEnabled(self.faceLeftButton, self.rangedSpellID);
	self:SetRangedButtonRangeCheckTimerEnabled(self.rangedSpellID);
	self:RefreshShootButtonRange();

	self.faceLeftButton:UpdateFlash();
	self.faceLeftButton:UpdateState();

	ActionButton_UpdateCooldown(self.faceLeftButton);
end

function GamepadHostileTargetingActionBarMixin:SetRangedButtonRangeCheckTimerEnabled(enabled)
	if enabled then
		if not self.rangedSpellRangeTicker then
			local handler = GenerateClosure(self.RefreshShootButtonRange, self);
			self.rangedSpellRangeTicker = C_Timer.NewTicker(1 / 20, handler);
		end
	elseif self.rangedSpellRangeTicker then
		self.rangedSpellRangeTicker:Cancel();
		self.rangedSpellRangeTicker = nil;
	end
end

function GamepadHostileTargetingActionBarMixin:RefreshShootButtonRange()
	if self.rangedSpellID then
		local inRange = C_Spell.IsSpellInRange(self.rangedSpellID);
		self.faceLeftButton:RefreshRange(inRange ~= nil, inRange);
	end
end

function GamepadHostileTargetingActionBarMixin:ResetFaceLeft()
	self.faceLeftButton:SetAttribute("type", "action");
	self.faceLeftButton:SetAttribute("spell", nil);
	self.faceLeftButton.spellID = nil;
	self.faceLeftButton.ClearFlash = self.prevClearFlash;
	self.faceLeftButton.SetChecked = self.prevSetChecked;
	self.faceLeftButton.SetTooltip = self.prevSetTooltip;
	self.faceLeftButton.UpdateFlash = self.prevUpdateFlash;
	self.faceLeftButton.UpdateState = self.prevUpdateState;
end

function GamepadHostileTargetingActionBarMixin:SetUpFaceLeft()
	self.prevClearFlash = self.faceLeftButton.ClearFlash;
	self.prevSetChecked = self.faceLeftButton.SetChecked;
	self.prevSetTooltip = self.faceLeftButton.SetTooltip;
	self.prevUpdateFlash = self.faceLeftButton.UpdateFlash;
	self.prevUpdateState = self.faceLeftButton.UpdateState;

	-- This is called by the action button in its Update, since the button doesn't contain an
	-- action. But we still want to keep flashing, so do nothing. When we want to stop we call
	-- StopFlash instead.
	self.faceLeftButton.ClearFlash = nop;

	-- This is also called by the action button's Update function. Ignore it too. We call the
	-- previous function instead to set the checked state.
	self.faceLeftButton.SetChecked = nop;

	function self.faceLeftButton.SetTooltip()
		if self.rangedSpellID then
			GameTooltip:Show();
			GameTooltip_SetDefaultAnchor(GameTooltip, self.faceLeftButton);
			GameTooltip:SetSpellByID(self.rangedSpellID, false, true);
		end
	end

	function self.faceLeftButton.UpdateFlash()
		local isFlashing = self.faceLeftButton:IsFlashing();
		if self.rangedSpellID and C_Spell.IsAutoRepeatSpell(self.rangedSpellID) then
			if not isFlashing then
				self.faceLeftButton:StartFlash();
			end
		elseif isFlashing then
			self.faceLeftButton:StopFlash();
		end
	end

	function self.faceLeftButton.UpdateState()
		local isChecked = self.rangedSpellID and C_Spell.IsAutoRepeatSpell(self.rangedSpellID);
		self.prevSetChecked(self.faceLeftButton, isChecked);
	end

	self.faceLeftButton:SetScript("OnClick", function(_, button, down)
		GamepadTargetLogic:ConsumeModifier();

		if self.rangedSpellID and C_Spell.IsAutoRepeatSpell(self.rangedSpellID) then
			if down then
				C_Spell.CancelAutoRepeatSpell();
			end
		else
			SecureActionButton_OnClick(self.faceLeftButton, button, down);
		end

		-- Native action button behavior causes the state to flip when it shouldn't, so we must
		-- update it immediately after performing the action.
		self.faceLeftButton:UpdateState();
	end);
end

function GamepadHostileTargetingActionBarMixin:ResetFaceTop()
	Shared.ResetTargetMarkerButton(self, self.faceTopButton);
end

function GamepadHostileTargetingActionBarMixin:SetUpFaceTop()
	Shared.SetUpTargetMarkerButton(self, self.faceTopButton, -1);
end

function GamepadHostileTargetingActionBarMixin:ResetFaceRight()
	Shared.ResetTargetingButton(self.faceRightButton);
end

function GamepadHostileTargetingActionBarMixin:SetUpFaceRight()
	self:RefreshAssistButton();

	self.faceRightButton.IconOverlay:SetAtlas("gamepad-targeting-overlay");
	self.faceRightButton.IconOverlay:Show();

	Shared.SetUpTargetingButton(self.faceRightButton, "targettarget");
end

function GamepadHostileTargetingActionBarMixin:SetUpFaceBottom()
	self.faceBottomButton.SpecialActionIcon:SetAtlas("gamepad-targeting-last-hostile");
	self.faceBottomButton.SpecialActionIcon:Show();

	Shared.SetButtonHandler(self.faceBottomButton, TargetLastEnemy);
end
