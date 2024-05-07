NUM_PET_ACTION_SLOTS = 10;

PET_DEFENSIVE_TEXTURE = "Interface\\Icons\\Ability_Defend";
PET_AGGRESSIVE_TEXTURE = "Interface\\Icons\\Ability_Racial_BloodRage";
PET_DEFENSIVEASSIST_TEXTURE = "Interface\\Icons\\Ability_Defend";
PET_PASSIVE_TEXTURE = "Interface\\Icons\\Ability_Seal";
PET_ASSIST_TEXTURE = "Interface\\Icons\\Ability_Hunter_Pet_Assist";
PET_ATTACK_TEXTURE = "Interface\\Icons\\Ability_GhoulFrenzy";
PET_FOLLOW_TEXTURE = "Interface\\Icons\\Ability_Tracking";
PET_WAIT_TEXTURE = "Interface\\Icons\\Spell_Nature_TimeStop";
PET_DISMISS_TEXTURE = "Interface\\Icons\\Spell_Shadow_Teleport";
PET_MOVE_TO_TEXTURE = "Interface\\Icons\\Ability_Hunter_Pet_Goto";

PET_ACTION_HIGHLIGHT_MARKS = {};

PetActionBarMixin = {};

local function HasPetActionHighlightMark(index)
	return PET_ACTION_HIGHLIGHT_MARKS[index];
end

local function CancelSpellLoadCallback(button)
	if button.spellDataLoadedCancelFunc then
		button.spellDataLoadedCancelFunc();
		button.spellDataLoadedCancelFunc = nil;
	end
end

function PetActionBarMixin:ClearPetActionHighlightMarks()
	PET_ACTION_HIGHLIGHT_MARKS = {};
end

function PetActionBarMixin:UpdatePetActionHighlightMarks(petAction)
	local petBarIndices = C_ActionBar.GetPetActionPetBarIndices(petAction);
	if petBarIndices then
		PET_ACTION_HIGHLIGHT_MARKS = tInvert(petBarIndices);
	else
		self:ClearPetActionHighlightMarks();
	end
end

function PetActionBarMixin:OnHide()
	self.mode = "none";
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		CancelSpellLoadCallback(self.actionButtons[i]);
	end
end

function PetActionBarMixin:OnLoad()
	self:RegisterEvent("PLAYER_CONTROL_LOST");
	self:RegisterEvent("PLAYER_CONTROL_GAINED");
	self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_FLAGS");
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN");
	self:RegisterEvent("PET_BAR_UPDATE_USABLE");
	self:RegisterEvent("PET_UI_UPDATE");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
	self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
	self:RegisterUnitEvent("UNIT_AURA", "pet");
	self:Update();
	if ( PetHasActionBar() ) then
		self:Show();
		self:LockPetActionBar();
	end
end

function PetActionBarMixin:OnEvent(event, ...)
	local arg1 = ...;
	if ( event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and arg1 == "player") or event == "PET_UI_UPDATE" or event == "UPDATE_VEHICLE_ACTIONBAR") then
		if ( PetHasActionBar() and UnitIsVisible("pet") ) then
			self:Update();
			self:Show();
			self:LockPetActionBar();
			self:UpdateShownButtons();
		else
			self:UnlockPetActionBar();
			self:Hide();
		end
	elseif ( event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" or event == "PET_BAR_UPDATE_USABLE" or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_MOUNT_DISPLAY_CHANGED" ) then
		self:Update(self);
	elseif ( (event == "UNIT_FLAGS") or (event == "UNIT_AURA") ) then
		if ( arg1 == "pet" ) then
			self:Update();
		end
	elseif ( event =="PET_BAR_UPDATE_COOLDOWN" ) then
		self:UpdateCooldowns();
	end
end

function PetActionBarMixin:OnUpdate(elapsed)
	if ( self.slideTimer and (self.slideTimer < self.timeToSlide) ) then
		self.completed = nil;
		self.slideTimer = self.slideTimer + elapsed;
	else
		self.completed = 1;
		if ( self.mode == "hide" ) then
			self:Hide();
		end
		self.mode = "none";
	end

	local rangeTimer = self.rangeTimer;
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed;
		if ( rangeTimer <= 0 ) then
			for i=1, NUM_PET_ACTION_SLOTS, 1 do
				local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID, checksRange, inRange = GetPetActionInfo(i);
				ActionButton_UpdateRangeIndicator(self.actionButtons[i], checksRange, inRange);
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end
		self.rangeTimer = rangeTimer;
	end
end

function PetActionBarMixin:Update()
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine;
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		petActionButton = self.actionButtons[i];
		petActionIcon = petActionButton.icon;
		petAutoCastableTexture = petActionButton.AutoCastable;
		petAutoCastShine = petActionButton.AutoCastShine;
		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i);
		if ( not isToken ) then
			petActionIcon:SetTexture(texture);
			petActionButton.tooltipName = name;
		else
			petActionIcon:SetTexture(_G[texture]);
			petActionButton.tooltipName = _G[name];
		end
		petActionButton.isToken = isToken;
		if spellID then
			local spell = Spell:CreateFromSpellID(spellID);
			petActionButton.spellDataLoadedCancelFunc = spell:ContinueWithCancelOnSpellLoad(function()
				petActionButton.tooltipSubtext = spell:GetSpellSubtext();
			end);
		end
		if ( isActive ) then
			if ( IsPetAttackAction(i) ) then
				petActionButton:StartFlash();
				-- the checked texture looks a little confusing at full alpha (looks like you have an extra ability selected)
				petActionButton:GetCheckedTexture():SetAlpha(0.5);
			else
				petActionButton:StopFlash();
				petActionButton:GetCheckedTexture():SetAlpha(1.0);
			end
			petActionButton:SetChecked(true);
		else
			petActionButton:StopFlash();
			petActionButton:SetChecked(false);
		end
		if ( autoCastAllowed ) then
			petAutoCastableTexture:Show();
		else
			petAutoCastableTexture:Hide();
		end
		if ( autoCastEnabled ) then
			AutoCastShine_AutoCastStart(petAutoCastShine);
		else
			AutoCastShine_AutoCastStop(petAutoCastShine);
		end
		if ( texture ) then
			if ( GetPetActionSlotUsable(i) ) then
				petActionIcon:SetVertexColor(1, 1, 1);
			else
				petActionIcon:SetVertexColor(0.4, 0.4, 0.4);
			end
			petActionIcon:Show();
		else
			petActionIcon:Hide();
		end

		SharedActionButton_RefreshSpellHighlight(petActionButton, HasPetActionHighlightMark(i));
	end
	self:UpdateCooldowns();
	if ( not PetHasActionBar() ) then
		--ControlReleased();
		self:Hide();
	end
	self.rangeTimer = -1;
end

function PetActionBarMixin:UpdateCooldowns()
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local cooldown = self.actionButtons[i].cooldown;
		local start, duration, enable = GetPetActionCooldown(i);
		CooldownFrame_Set(cooldown, start, duration, enable);

		-- Update tooltip
		local actionButton = self.actionButtons[i];
		if ( GameTooltip:GetOwner() == actionButton ) then
			actionButton:OnEnter(actionButton);
		end
	end
end

function PetActionBarMixin:PetActionButtonDown(id)
	local button = self.actionButtons[id];
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
	if (GetCVarBool("ActionButtonUseKeyDown")) then
		CastPetAction(id);
	end
end

function PetActionBarMixin:PetActionButtonUp(id)
	local button = self.actionButtons[id];
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		if(not GetCVarBool("ActionButtonUseKeyDown")) then
			CastPetAction(id);
		end
	end
end

function PetActionBarMixin:LockPetActionBar()
	self.locked = 1;
end

function PetActionBarMixin:UnlockPetActionBar()
	self.locked = nil;
end

PetActionButtonMixin = {}

function PetActionButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton", "RightButton");
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("GAME_PAD_ACTIVE_CHANGED");
	self:SetHotkeys();
	self.cooldown:SetSwipeColor(0, 0, 0);
end

function PetActionButtonMixin:OnEvent(event, ...)
	if ( event == "UPDATE_BINDINGS" or event == "GAME_PAD_ACTIVE_CHANGED" ) then
		self:SetHotkeys();
		return;
	end
end

function PetActionButtonMixin:PreClick()
	self:SetChecked(false);
end

function PetActionButtonMixin:OnClick(button)
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		if ( IsModifiedClick() and IsModifiedClick("PICKUPACTION") ) then
			PickupPetAction(self:GetID());
			return;
		else
			if ( button == "LeftButton" ) then
				CastPetAction(self:GetID());
			else
				TogglePetAutocast(self:GetID());
			end
		end
	end
end

function PetActionButtonMixin:OnDragStart()
	if ( not Settings.GetValue("lockActionBars") or IsModifiedClick("PICKUPACTION")) then
		self:SetChecked(false);
		PickupPetAction(self:GetID());
		PetActionBar:Update();
	end
end

function PetActionButtonMixin:OnReceiveDrag()
	local cursorType = GetCursorInfo();
	if (cursorType == "petaction") then
		self:SetChecked(false);
		PickupPetAction(self:GetID());
		PetActionBar:Update();
	end
end

function PetActionButtonMixin:OnEnter()
	if ( not self.tooltipName ) then
		return;
	end

	local uber = GetCVar("UberTooltips");
	if ( uber == "0" and not KeybindFrames_InQuickKeybindMode() ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local bindingText = GetBindingText(GetBindingKey("BONUSACTIONBUTTON"..self:GetID()));
		if (bindingText and bindingText ~= "") then
			GameTooltip:SetText(self.tooltipName..NORMAL_FONT_COLOR_CODE.." ("..bindingText..")"..FONT_COLOR_CODE_CLOSE, 1.0, 1.0, 1.0);
		else
			GameTooltip:SetText(self.tooltipName, 1.0, 1.0, 1.0);
		end
		if ( self.tooltipSubtext ) then
			GameTooltip:AddLine(self.tooltipSubtext, 0.5, 0.5, 0.5, true);
		end
		GameTooltip:Show();
		self.UpdateTooltip = nil;
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		if (GameTooltip:SetPetAction(self:GetID())) then
			self.UpdateTooltip = self.OnEnter;
		else
			self.UpdateTooltip = nil;
		end
	end
end

function PetActionButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function PetActionButtonMixin:OnUpdate(elapsed)
	if ( self:IsFlashing() ) then
		local flashtime = self.flashtime;
		flashtime = flashtime - elapsed;

		if ( flashtime <= 0 ) then
			local overtime = -flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

			local flashTexture = self.Flash;
			if ( flashTexture:IsShown() ) then
				flashTexture:Hide();
			else
				flashTexture:Show();
			end
		end

		self.flashtime = flashtime;
	end
end

function PetActionButtonMixin:SetHotkeys()
	local binding = GetBindingText(GetBindingKey("BONUSACTIONBUTTON"..self:GetID()), true);
	local hotkey = self.HotKey;
	if ( binding == "" ) then
		hotkey:SetText(RANGE_INDICATOR);
		hotkey:Hide();
	else
		hotkey:SetText(binding);
		hotkey:Show();
	end
end

function PetActionButtonMixin:StartFlash()
	self.flashing = true;
	self.flashtime = 0;
end

function PetActionButtonMixin:StopFlash()
	self.flashing = false;
	self.Flash:Hide();
end

function PetActionButtonMixin:IsFlashing()
	return self.flashing;
end

function PetActionButtonMixin:HasAction()
    return GetPetActionInfo(self.index);
end