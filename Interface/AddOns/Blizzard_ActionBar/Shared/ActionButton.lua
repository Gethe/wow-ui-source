ATTACK_BUTTON_FLASH_TIME = 0.4;
RANGE_INDICATOR = "●";

COOLDOWN_TYPE_LOSS_OF_CONTROL = 1;
COOLDOWN_TYPE_NORMAL = 2;

local countdownForCooldownsCVarName = "countdownForCooldowns";

ACTION_HIGHLIGHT_MARKS = { };
ON_BAR_HIGHLIGHT_MARKS = { };

ACTION_BUTTON_SHOW_GRID_REASON_CVAR = 1;
ACTION_BUTTON_SHOW_GRID_REASON_EVENT = 2;
ACTION_BUTTON_SHOW_GRID_REASON_SPELLCOLLECTION = 4;

ActionButtonBindingHighlightCallbackRegistry = CreateFromMixins(CallbackRegistryMixin);
ActionButtonBindingHighlightCallbackRegistry:SetUndefinedEventsAllowed(true);
ActionButtonBindingHighlightCallbackRegistry:OnLoad();

local ActionButtonCastType =
{
	Cast = 1,
	Channel = 2,
	Empowered = 3,
}

function MarkNewActionHighlight(action)
	ACTION_HIGHLIGHT_MARKS[action] = true;
end

function ClearNewActionHighlight(action, preventIdenticalActionsFromClearing)
	ACTION_HIGHLIGHT_MARKS[action] = nil;

	if preventIdenticalActionsFromClearing then
		return;
	end

	-- If we're unhighlighting this one because it was used/moused over/etc...
	-- then go find all other current actions that match this one that are also
	-- marked for highlight and unmark them.  The next time they update the highlight
	-- will update; may need to actually force update the action button in some cases
	-- and that means that ACTION_HIGHLIGHT_MARKS needs to store more information
	local unmarkedType, unmarkedID = GetActionInfo(action);

	for actionKey, markValue in pairs(ACTION_HIGHLIGHT_MARKS) do
		if markValue then
			local actionType, actionID = GetActionInfo(actionKey);
			if actionType == unmarkedType and actionID == unmarkedID then
				ACTION_HIGHLIGHT_MARKS[actionKey] = nil;
			end
		end
	end
end

-- Keys within ON_BAR_HIGHLIGHT_MARKS and ACTION_HIGHLIGHT_MARKS are vulnerable to taint from
-- talent and spellbook code. Will require some investigation.
local function SecureGetNewActionHighlightMark(action)
	return ACTION_HIGHLIGHT_MARKS[action];
end

function GetNewActionHighlightMark(action)
	return securecallfunction(SecureGetNewActionHighlightMark, action);
end

function ClearOnBarHighlightMarks()
	ON_BAR_HIGHLIGHT_MARKS = {};
end

local function SecureGetOnBarHighlightMark(action)
	return ON_BAR_HIGHLIGHT_MARKS[action];
end

function GetOnBarHighlightMark(action)
	return securecallfunction(SecureGetOnBarHighlightMark, action);
end

local function UpdateOnBarHighlightMarks(actionButtonSlots)
	if actionButtonSlots then
		ON_BAR_HIGHLIGHT_MARKS = tInvert(actionButtonSlots);
	else
		ClearOnBarHighlightMarks();
	end
end

function UpdateOnBarHighlightMarksBySpell(spellID)
	UpdateOnBarHighlightMarks(C_ActionBar.FindSpellActionButtons(spellID));
end

function UpdateOnBarHighlightMarksByFlyout(flyoutID)
	UpdateOnBarHighlightMarks(C_ActionBar.FindFlyoutActionButtons(flyoutID));
end

function UpdateOnBarHighlightMarksByPetAction(petAction)
	UpdateOnBarHighlightMarks(C_ActionBar.FindPetActionButtons(petAction));
end

function GetActionButtonForID(id)
	if OverrideActionBar and OverrideActionBar:IsShown() then
		if id > NUM_OVERRIDE_BUTTONS then
			return;
		end

		return _G["OverrideActionBarButton"..id];
	end

	return _G["ActionButton"..id];
end

function TryUseActionButton(self, checkingFromDown)
	local isKeyPress = true;
	local isSecureAction = true;
	local usedActionButton = SecureActionButton_OnClick(self, "LeftButton", checkingFromDown, isKeyPress, isSecureAction);
	if usedActionButton then
		if GetNewActionHighlightMark(self.action) then
			ClearNewActionHighlight(self.action);
			self:UpdateHighlightMark();
		end
	end
	self:UpdateState();
end

local isInPetBattle = C_PetBattles.IsInBattle;
local function CheckPetActionButtonEvent(id, isDown)
	if isInPetBattle() and PetBattleFrame then
		if isDown then
			PetBattleFrame_ButtonDown(id);
		else
			PetBattleFrame_ButtonUp(id);
		end
		return true;
	end

	return false;
end

function ActionButtonDown(id)
	if CheckPetActionButtonEvent(id, true) then
		return;
	end

	local button = GetActionButtonForID(id);
	if button then
		if button:GetButtonState() == "NORMAL" then
			button:SetButtonState("PUSHED");
		end

		TryUseActionButton(button, true);
	end
end

function ActionButtonUp(id)
	if CheckPetActionButtonEvent(id, false) then
		return;
	end

	local button = GetActionButtonForID(id);
	if button then
		if ( button:GetButtonState() == "PUSHED" ) then
			button:SetButtonState("NORMAL");
		end

		TryUseActionButton(button, false);
	end
end

function ActionBar_PageUp()
	local nextPage;
	for i=C_ActionBar.GetActionBarPage() + 1, NUM_ACTIONBAR_PAGES do
		if ( VIEWABLE_ACTION_BAR_PAGES[i] ) then
			nextPage = i;
			break;
		end
	end

	if ( not nextPage ) then
		nextPage = 1;
	end
	C_ActionBar.SetActionBarPage(nextPage);
end

function ActionBar_PageDown()
	local prevPage;
	for i=C_ActionBar.GetActionBarPage() - 1, 1, -1 do
		if ( VIEWABLE_ACTION_BAR_PAGES[i] ) then
			prevPage = i;
			break;
		end
	end

	if ( not prevPage ) then
		for i=NUM_ACTIONBAR_PAGES, 1, -1 do
			if ( VIEWABLE_ACTION_BAR_PAGES[i] ) then
				prevPage = i;
				break;
			end
		end
	end
	C_ActionBar.SetActionBarPage(prevPage);
end

ActionBarButtonEventsFrameMixin = {};

function ActionBarButtonEventsFrameMixin:OnLoad()
	self.frames = {};
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("GAME_PAD_ACTIVE_CHANGED");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterUnitEvent("UNIT_FLAGS", "pet");
	self:RegisterUnitEvent("UNIT_AURA", "pet");
	self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");

	CVarCallbackRegistry:SetCVarCachable(countdownForCooldownsCVarName);
	CVarCallbackRegistry:RegisterCallback(countdownForCooldownsCVarName, self.OnCountdownForCooldownsChanged, self);
end

function ActionBarButtonEventsFrameMixin:OnEvent(event, ...)
	-- pass event down to the buttons
	for k, frame in pairs(self.frames) do
		frame:OnEvent(event, ...);
	end
end

function ActionBarButtonEventsFrameMixin:OnCountdownForCooldownsChanged()
	for k, frame in pairs(self.frames) do
		ActionButton_UpdateCooldownNumberHidden(frame);
	end
end

function ActionBarButtonEventsFrameMixin:RegisterFrame(frame)
	tinsert(self.frames, frame);
end

function ActionBarButtonEventsFrameMixin:ForEachFrame(func)
	for k, frame in pairs(self.frames) do
		func(frame);
	end
end

ActionBarActionEventsFrameMixin = {};

function ActionBarActionEventsFrameMixin:OnLoad()
	self.frames = {};
	--self:RegisterEvent("ACTIONBAR_UPDATE_USABLE");		replaced with ACTION_USABLE_CHANGED
	self:RegisterEvent("SPELL_UPDATE_CHARGES");
	self:RegisterEvent("UPDATE_INVENTORY_ALERTS");
	self:RegisterEvent("TRADE_SKILL_SHOW");
	self:RegisterEvent("TRADE_SKILL_CLOSE");
	self:RegisterEvent("ARCHAEOLOGY_CLOSED");
	self:RegisterEvent("PLAYER_ENTER_COMBAT");
	self:RegisterEvent("PLAYER_LEAVE_COMBAT");
	self:RegisterEvent("START_AUTOREPEAT_SPELL");
	self:RegisterEvent("STOP_AUTOREPEAT_SPELL");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("COMPANION_UPDATE");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("UNIT_SPELLCAST_SENT");
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_RETICLE_TARGET", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_RETICLE_CLEAR", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "player");

	self:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE");
	self:RegisterEvent("PET_STABLE_UPDATE");
	self:RegisterEvent("PET_STABLE_SHOW");
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
	self:RegisterEvent("UPDATE_SUMMONPETS_ACTION");
	self:RegisterUnitEvent("LOSS_OF_CONTROL_ADDED", "player");
	self:RegisterUnitEvent("LOSS_OF_CONTROL_UPDATE", "player");
	self:RegisterEvent("SPELL_UPDATE_ICON");

	EventRegistry:RegisterCallback("AssistedCombatManager.OnSetActionSpell", function(o)
		-- May not be the best way, but it is a unique string which is what the event system cares about
		self:OnEvent("AssistedCombatManager.OnSetActionSpell");
	end);
end


function ActionBarActionEventsFrameMixin:IsSpellcastEvent(event)
	if ( event == "UNIT_SPELLCAST_INTERRUPTED" or
	event == "UNIT_SPELLCAST_SUCCEEDED" or
	event == "UNIT_SPELLCAST_START" or
	event == "UNIT_SPELLCAST_STOP" or
	event == "UNIT_SPELLCAST_CHANNEL_START" or
	event == "UNIT_SPELLCAST_CHANNEL_STOP" or
	event == "UNIT_SPELLCAST_RETICLE_TARGET" or
	event == "UNIT_SPELLCAST_RETICLE_CLEAR" or
	event == "UNIT_SPELLCAST_EMPOWER_START" or
	event == "UNIT_SPELLCAST_EMPOWER_STOP" or
	event == "UNIT_SPELLCAST_SENT" or
	event == "UNIT_SPELLCAST_FAILED") then
		return true;
	else
		return false;
	end
end

function ActionBarActionEventsFrameMixin:OnEvent(event, ...)
	if ( event == "UNIT_INVENTORY_CHANGED" ) then
		local unit = ...;
		if ( unit == "player" and self.tooltipOwner and GameTooltip:GetOwner() == self.tooltipOwner ) then
			self.tooltipOwner:SetTooltip();
		end
	elseif ( self:IsSpellcastEvent(event) ) then
		for k, frame in pairs(self.frames) do
			local spellID;
			local unit = ...;

			if(event == "UNIT_SPELLCAST_SENT") then
				spellID = select(4, ...);
			else
				spellID = select(3, ...);
			end

			if (unit == "player" and frame:MatchesActiveButtonSpellID(spellID)) then
				frame:OnEvent(event, ...);
			end
		end
	else
		for k, frame in pairs(self.frames) do
			frame:OnEvent(event, ...);
		end
	end
end

function ActionBarActionEventsFrameMixin:RegisterFrame(frame)
	self.frames[frame] = frame;
end

function ActionBarActionEventsFrameMixin:UnregisterFrame(frame)
	self.frames[frame] = nil;
end

ActionBarButtonUpdateFrameMixin = {};

function ActionBarButtonUpdateFrameMixin:OnLoad()
	self.frames = {};
end

function ActionBarButtonUpdateFrameMixin:OnUpdate(elapsed)
	for k, frame in pairs(self.frames) do
		frame:OnUpdate(elapsed);
	end
end

function ActionBarButtonUpdateFrameMixin:RegisterFrame(frame)
	self.frames[frame] = frame;
end

function ActionBarButtonUpdateFrameMixin:UnregisterFrame(frame)
	self.frames[frame] = nil;
end

ActionBarButtonRangeCheckFrameMixin = {};

function ActionBarButtonRangeCheckFrameMixin:OnLoad()
	self.actions = {};
	self:RegisterEvent("ACTION_RANGE_CHECK_UPDATE");
end

function ActionBarButtonRangeCheckFrameMixin:OnEvent(event, ...)
	local action, inRange, checksRange = ...;

	-- pass event down to the buttons
	local frames = self.actions[action];
	if frames then
		for k, frame in pairs(frames) do
			frame:OnEvent(event, ...);
		end
	end
end

function ActionBarButtonRangeCheckFrameMixin:RegisterFrame(action, frame)
	if not self.actions[action] then
		self.actions[action] = {};
	end
	if self.actions[action][frame] then
		return;
	end
	self.actions[action][frame] = frame;
	C_ActionBar.EnableActionRangeCheck(action, true);
end

function ActionBarButtonRangeCheckFrameMixin:UnregisterFrame(action, frame)
	if not self.actions[action] or not self.actions[action][frame] then
		return;
	end
	self.actions[action][frame] = nil;
	C_ActionBar.EnableActionRangeCheck(action, false);
end

ActionBarButtonUsableWatcherFrameMixin = {};

function ActionBarButtonUsableWatcherFrameMixin:OnLoad()
	self.actions = {};
	self:RegisterEvent("ACTION_USABLE_CHANGED");
end

function ActionBarButtonUsableWatcherFrameMixin:OnEvent(event, ...)
	local changes = ...;

	-- pass event down to the buttons
	for _, change in ipairs(changes) do
		local frames = self.actions[change.slot];
		if frames then
			for k, frame in pairs(frames) do
				frame:UpdateUsable(change.slot, change.usable, change.noMana);
			end
		end
	end
end

function ActionBarButtonUsableWatcherFrameMixin:RegisterFrame(action, frame)
	if not self.actions[action] then
		self.actions[action] = {};
	end
	if self.actions[action][frame] then
		return;
	end
	self.actions[action][frame] = frame;
end

function ActionBarButtonUsableWatcherFrameMixin:UnregisterFrame(action, frame)
	if not self.actions[action] or not self.actions[action][frame] then
		return;
	end
	self.actions[action][frame] = nil;
end

ActionBarActionButtonMixin = {};

function ActionBarActionButtonMixin:OnLoad()
	self.SetButtonStateBase = self.SetButtonState;
	self.SetButtonState = self.SetButtonStateOverride;

	self.flashing = 0;
	self.flashtime = 0;
	self:SetAttribute("type", "action");
	self:SetAttribute("typerelease", "actionrelease");
	self:SetAttribute("checkselfcast", true);
	self:SetAttribute("checkfocuscast", true);
	self:SetAttribute("checkmouseovercast", true);
	self:SetAttribute("useparent-unit", true);
	self:SetAttribute("useparent-actionpage", true);
	self:RegisterForDrag("LeftButton", "RightButton");
	self:RegisterForClicks("AnyUp", "LeftButtonDown", "RightButtonDown");
	ActionBarButtonEventsFrame:RegisterFrame(self);
	self:UpdateAction();
	self:UpdateHotkeys(self.buttonType);

	self.QuickKeybindHighlightTexture:ClearAllPoints();
	self.QuickKeybindHighlightTexture:SetPoint("CENTER");
	self.QuickKeybindHighlightTexture:SetSize(46, 45);

	ActionButton_UpdateCooldownNumberHidden(self);
end

function ActionBarActionButtonMixin:UpdateHotkeys(actionButtonType)
	local id;
    if ( not actionButtonType ) then
        actionButtonType = "ACTIONBUTTON";
		id = self:GetID();
	else
		if ( actionButtonType == "MULTICASTACTIONBUTTON" ) then
			id = self.buttonIndex;
		else
			id = self:GetID();
		end
    end

	self.bindingAction = actionButtonType..id;
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		self.bindingAction = "WOWLABS_"..self.bindingAction;
	end
    local hotkey = self.HotKey;
    local key = GetBindingKey(self.bindingAction) or
                GetBindingKey("CLICK "..self:GetName()..":LeftButton");

	local text = GetBindingText(key, 1);
    if ( text == "" ) then
        hotkey:SetText(RANGE_INDICATOR);
        hotkey:Hide();
    else
		local frameWidth, frameHeight = self:GetSize();
		if ( IsBindingForGamePad(key) ) then
			-- Allow gamepad binding to go all the way across and overlap the border for more space
			hotkey:SetSize(frameWidth, 16);
			hotkey:SetPoint("TOPRIGHT", self, "TOPRIGHT", self.hotkeyTextGamepadX or 0, self.hotkeyTextGamepadY or 0);
		else
			-- Tuck in KBM binding a bit to be inside the border
			hotkey:SetSize(frameWidth-8, 10);
			hotkey:SetPoint("TOPRIGHT", self, "TOPRIGHT", self.hotkeyTextKeyboardX or 0, self.hotkeyTextKeyboardY or 0);
		end
        hotkey:SetText(text);
        hotkey:Show();
    end
end

function ActionBarActionButtonMixin:UpdatePressAndHoldAction()
	local pressAndHoldAction = false;

	if self.action then
		local actionType, id = GetActionInfo(self.action);
		if actionType == "spell" then
			pressAndHoldAction = C_Spell.IsPressHoldReleaseSpell(id);
		end
	end

	self:SetAttribute("pressAndHoldAction", pressAndHoldAction);
end

function ActionBarActionButtonMixin:OnAttributeChanged(name, value)
	BaseActionButtonMixin.BaseActionButtonMixin_OnAttributeChanged(self, name, value);
	self:UpdateAction();
end

function ActionBarActionButtonMixin:UpdateAction(force)
	local action = self:CalculateAction();
	if ( action ~= self.action or force ) then
		if self.action then
			self:UnregisterActionBarButtonCheckFrames(self.action);
		end
		self.action = action;
		if self.action and self:IsVisible() then
			self:RegisterActionBarButtonCheckFrames(self.action);
		end

		C_ActionBar.RegisterActionUIButton(self, action, self.cooldown);

		self:UpdateAssistedCombatRotationFrame();

		self:Update();

		-- If on an action bar and layout fields are set, ask it to update visibility of its buttons
		if (self.index and self.bar) then
			self.bar:UpdateShownButtons();
		end

		EventRegistry:TriggerEvent("ActionButton.OnActionChanged", self);
	end
end

function ActionBarActionButtonMixin:Update()
	local action = self.action;
	local icon = self.icon;
	local texture = C_ActionBar.GetActionTexture(action);

	icon:SetDesaturated(false);
	local type, id = GetActionInfo(action);
	if ( C_ActionBar.HasAction(action) ) then
		if ( not self.eventsRegistered ) then
			ActionBarActionEventsFrame:RegisterFrame(self);
			self.eventsRegistered = true;
		end
		self:UpdateState();
		self:UpdateUsable();
		self:UpdateProfessionQuality();
		self:UpdateTypeOverlay();
		ActionButton_UpdateCooldown(self);
		self:UpdateFlash();
		self:UpdateHighlightMark();
		self:UpdateSpellHighlightMark();
	else
		if ( self.eventsRegistered ) then
			ActionBarActionEventsFrame:UnregisterFrame(self);
			self.eventsRegistered = nil;
		end

		ClearActionButtonCooldowns(self.cooldown, self.chargeCooldown, self.lossOfControlCooldown);

		self:ClearFlash();
		self:SetChecked(false);
		self:ClearProfessionQuality();
		self:ClearTypeOverlay();

		if self.LevelLinkLockIcon then
			self.LevelLinkLockIcon:SetShown(false);
		end
	end

	self:UpdatePressAndHoldAction();

	-- Add a green border if button is an equipped item
	local border = self.Border;
	if border then
		if ( C_ActionBar.IsEquippedAction(action) ) then
			border:SetVertexColor(0, 1.0, 0, 0.5);
			border:Show();
		else
			border:Hide();
		end
	end

	-- Update Action Text
	local actionName = self.Name;
	if actionName then
		if ( not C_ActionBar.IsConsumableAction(action) and not C_ActionBar.IsStackableAction(action) and (C_ActionBar.IsItemAction(action) or C_ActionBar.GetActionUseCount(action) == 0) ) then
			actionName:SetText(C_ActionBar.GetActionText(action));
		else
			actionName:SetText("");
		end
	end

	-- Update icon and hotkey text
	if ( texture ) then
		icon:SetTexture(texture);
		icon:Show();
		self:UpdateCount();
	else
		self.Count:SetText("");
		icon:Hide();
		ClearActionButtonCooldowns(self.cooldown, self.chargeCooldown, self.lossOfControlCooldown);
		local hotkey = self.HotKey;
        if ( hotkey:GetText() == RANGE_INDICATOR ) then
			hotkey:Hide();
		else
			hotkey:SetVertexColor(ACTIONBAR_HOTKEY_FONT_COLOR:GetRGB());
		end
	end

	-- Update flyout appearance
	self:UpdateFlyout();

	self:UpdateSpellAlert();

	-- Update tooltip
	if ( GameTooltip:GetOwner() == self ) then
		self:SetTooltip();
	end

	self.feedback_action = action;
end

function ActionBarActionButtonMixin:UpdateHighlightMark()
	if ( self.NewActionTexture ) then
		self.NewActionTexture:SetShown(GetNewActionHighlightMark(self.action)); -- TODO: Should bindings support this, or should we force SetShown to take a bool?
	end
end

-- Shared between the action bar and the pet bar.
function SharedActionButton_RefreshSpellHighlight(button, shown)
	if ( shown ) then
		button.SpellHighlightTexture:Show();
		button.SpellHighlightAnim:Play();
	else
		button.SpellHighlightTexture:Hide();
		button.SpellHighlightAnim:Stop();
	end
end

function ActionBarActionButtonMixin:UpdateSpellHighlightMark()
	if ( self.SpellHighlightTexture and self.SpellHighlightAnim ) then
		SharedActionButton_RefreshSpellHighlight(self, GetOnBarHighlightMark(self.action));
	end
end

function ActionBarActionButtonMixin:HasAction()
	return C_ActionBar.HasAction(self.action);
end

function ActionBarActionButtonMixin:UpdateState()
	local action = self.action;
	local isChecked = (C_ActionBar.IsCurrentAction(action) or C_ActionBar.IsAutoRepeatAction(action)) and not C_ActionBar.IsAutoCastPetAction(action);
	self:SetChecked(isChecked);
end

function ActionBarActionButtonMixin:UpdateUsable(action, isUsable, notEnoughMana)
	local icon = self.icon;

	assertsafe(action == nil or action == self.action);
	if isUsable == nil or notEnoughMana == nil then
		isUsable, notEnoughMana = C_ActionBar.IsUsableAction(self.action);
	end
	if ( isUsable ) then
		icon:SetVertexColor(1.0, 1.0, 1.0);
	elseif ( notEnoughMana ) then
		icon:SetVertexColor(0.5, 0.5, 1.0);
	else
		icon:SetVertexColor(0.4, 0.4, 0.4);
	end

	local isLevelLinkLocked = C_LevelLink and C_LevelLink.IsActionLocked(self.action);
	if not icon:IsDesaturated() then
		icon:SetDesaturated(isLevelLinkLocked);
	end

	if self.LevelLinkLockIcon then
		self.LevelLinkLockIcon:SetShown(isLevelLinkLocked);
	end
	self:EvaluateState();
end

function ActionBarActionButtonMixin:EvaluateState()
return;
end

function ActionBarActionButtonMixin:CreateTextureOverlayFrame()
	return CreateFrame("Frame", nil, self, "ActionButtonTextureOverlayTemplate");
end

function ActionBarActionButtonMixin:UpdateProfessionQuality()
	if C_ActionBar.IsItemAction(self.action) then
		local qualityInfo = C_ActionBar.GetProfessionQualityInfo(self.action);
		if qualityInfo then
			if not self.ProfessionQualityOverlayFrame then
				self.ProfessionQualityOverlayFrame = self:CreateTextureOverlayFrame();
				self.ProfessionQualityOverlayFrame:SetPoint("TOPLEFT", 14, -14);
			end

			self.ProfessionQualityOverlayFrame:Show();
			self.ProfessionQualityOverlayFrame.Texture:SetAtlas(qualityInfo.iconInventory, TextureKitConstants.UseAtlasSize);
			return;
		end
	end
	self:ClearProfessionQuality();
end

function ActionBarActionButtonMixin:ClearProfessionQuality()
	if self.ProfessionQualityOverlayFrame then
		self.ProfessionQualityOverlayFrame:Hide();
	end
end

function ActionBarActionButtonMixin:GetOrCreateTypeOverlay(atlas)
	if not self.TypeIconOverlayFrame then
		self.TypeIconOverlayFrame = self:CreateTextureOverlayFrame();
		self.TypeIconOverlayFrame:SetPoint("CENTER", self, "BOTTOM", 0, 3);
		self.TypeIconOverlayFrame:SetFrameLevel(self:GetFrameLevel() + 100);
		self.TypeIconOverlayFrame.Texture:SetSize(21, 24);
	end

	self.TypeIconOverlayFrame.Texture:SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
	return self.TypeIconOverlayFrame;
end

function ActionBarActionButtonMixin:UpdateTypeOverlay()
	if self.TypeIconOverlayFrame then
		self.TypeIconOverlayFrame:Hide();
	end

	local strategy = GameRulesUtil.GetActionButtonTypeOverlayStrategy();
	if strategy == GameRulesUtil.ActionButtonTypeOverlayStrategy.None then
		return;
	end

	if strategy == GameRulesUtil.ActionButtonTypeOverlayStrategy.HighlightMana then
		local typeOverlayFrameAtlas = "plunderstorm-icon-utility";

		local actionType, actionID = GetActionInfo(self.action);
		if (actionType == "spell") and actionID then
			local costTable = C_Spell.GetSpellPowerCost(actionID);
			if costTable then
				for _i, costInfo in pairs(costTable) do
					if costInfo.type == Enum.PowerType.Mana then
						typeOverlayFrameAtlas = "plunderstorm-icon-offensive";
						break;
					end
				end
			end
		end

		local typeIconOverlayFrame = self:GetOrCreateTypeOverlay(typeOverlayFrameAtlas);
		typeIconOverlayFrame:Show();
	elseif strategy == GameRulesUtil.ActionButtonTypeOverlayStrategy.ManaAndEnergy then
		local typeOverlayFrameAtlas = nil;

		local actionType, actionID = GetActionInfo(self.action);
		if (actionType == "spell") and actionID then
			local costTable = C_Spell.GetSpellPowerCost(actionID);
			if costTable then
				for _i, costInfo in pairs(costTable) do
					-- Mana is high priority if a spell costs both.
					if costInfo.type == Enum.PowerType.Mana then
						typeOverlayFrameAtlas = "plunderstorm-icon-offensive";
						break;
					elseif costInfo.type == Enum.PowerType.Energy then
						typeOverlayFrameAtlas = "plunderstorm-icon-utility";
					end
				end
			end
		end

		if typeOverlayFrameAtlas then
			local typeIconOverlayFrame = self:GetOrCreateTypeOverlay(typeOverlayFrameAtlas);
			typeIconOverlayFrame:Show();
		end
	end
end

function ActionBarActionButtonMixin:ClearTypeOverlay()
	if self.TypeIconOverlayFrame then
		self.TypeIconOverlayFrame:Hide();
	end
end

function ActionBarActionButtonMixin:UpdateCount()
	self.Count:SetText(C_ActionBar.GetActionDisplayCount(self.action, self.maxDisplayCount));
end

-- Determine whether cooldowns display countdown numbers for action bar buttons and spell flyout buttons.
function ActionButton_UpdateCooldownNumberHidden(actionButton)
	local shouldBeHidden = CVarCallbackRegistry:GetCVarValueBool(countdownForCooldownsCVarName) ~= true;
	actionButton.cooldown:SetHideCountdownNumbers(shouldBeHidden);
end

local defaultCooldownInfo = { startTime = 0; duration = 0; isEnabled = false; modRate = 0 };
local defaultChargeInfo = { currentCharges = 0; maxCharges = 0; cooldownStartTime = 0; cooldownDuration = 0; chargeModRate = 0 };
local defaultLossOfControlInfo = { startTime = 0; duration = 0; modRate = 0 };

-- Shared between action bar buttons and spell flyout buttons.
function ActionButton_UpdateCooldown(self)
	local chargeInfo;
	local cooldownInfo;
	local lossOfControlInfo = {};
	local actionType, actionID = nil, nil;
	if (self.action) then
		actionType, actionID = GetActionInfo(self.action);
	end
	local auraData = nil;
	local passiveCooldownSpellID = nil;
	local onEquipPassiveSpellID = nil;

	if(actionID) then
		onEquipPassiveSpellID = C_ActionBar.GetItemActionOnEquipSpellID(self.action);
	end

	if (onEquipPassiveSpellID) then
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(onEquipPassiveSpellID);
	elseif ((actionType and actionType == "spell") and actionID ) then
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(actionID);
	elseif(self.spellID) then
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(self.spellID);
	end

	if(passiveCooldownSpellID and passiveCooldownSpellID ~= 0) then
		auraData = C_UnitAuras.GetPlayerAuraBySpellID(passiveCooldownSpellID);
	end

	if(auraData) then
		local currentTime = GetTime();
		local timeUntilExpire = auraData.expirationTime - currentTime;
		local howMuchTimeHasPassed = auraData.duration - timeUntilExpire;

		lossOfControlInfo.startTime =  currentTime - howMuchTimeHasPassed;
		lossOfControlInfo.duration = auraData.expirationTime - currentTime;
		lossOfControlInfo.modRate = auraData.timeMod;
		cooldownInfo = {};
		cooldownInfo.startTime = currentTime - howMuchTimeHasPassed;
		cooldownInfo.duration =  auraData.duration
		cooldownInfo.modRate = auraData.timeMod;
		cooldownInfo.isEnabled = 1;
		chargeInfo = {};
		chargeInfo.charges = auraData.charges;
		chargeInfo.maxCharges = auraData.maxCharges;
		chargeInfo.chargeStart = currentTime * 0.001;
		chargeInfo.chargeDuration = auraData.duration * 0.001;
		chargeInfo.chargeModRate = auraData.timeMod;
	elseif (self.spellID) then
		cooldownInfo = C_Spell.GetSpellCooldown(self.spellID) or defaultCooldownInfo;
		chargeInfo = C_Spell.GetSpellCharges(self.spellID) or defaultChargeInfo;

		local locStart, locDuration = C_Spell.GetSpellLossOfControlCooldown(self.spellID);
		lossOfControlInfo.startTime = locStart;
		lossOfControlInfo.duration = locDuration;
		lossOfControlInfo.modRate = cooldownInfo.modRate;
	else
		cooldownInfo = C_ActionBar.GetActionCooldown(self.action);
		chargeInfo = C_ActionBar.GetActionCharges(self.action);

		local locStart, locDuration = C_ActionBar.GetActionLossOfControlCooldown(self.action);
		lossOfControlInfo.startTime = locStart;
		lossOfControlInfo.duration = locDuration;
		lossOfControlInfo.modRate = cooldownInfo.modRate;
	end

	if not self.enableLOCCooldown then
		lossOfControlInfo = defaultLossOfControlInfo;
	end

	ActionButton_ApplyCooldown(self.cooldown, cooldownInfo, self.chargeCooldown, chargeInfo, self.lossOfControlCooldown, lossOfControlInfo);
end

-- Create a pristine instance of Cooldown frame to mitigate potential secret leaks through overwriting methods.
local CooldownPrototype = CreateFrame("Cooldown");

-- Secure version of CooldownFrame_Set - manually call methods passing in cooldown as self
local function SecureCooldown_SetOrClear(cooldown, start, duration, enable, modRate)
	if enable and enable ~= 0 and start > 0 and duration > 0 then
		CooldownPrototype.SetCooldown(cooldown, start, duration, modRate);
	else
		CooldownPrototype.Clear(cooldown);
	end
end

-- This excessive argument list is required because SecureDelegates will not (and should not) clear taint off values inside of tables.
local function SecureCooldown_ApplyCooldown(
	lossOfControlCooldown,
	lossOfControlStartTime,
	lossOfControlDuration,
	lossOfControlModRate,
	normalCooldown,
	cooldownStartTime,
	cooldownDuration,
	cooldownIsEnabled,
	cooldownModRate,
	chargeCooldown,
	chargeMaxCharges,
	chargeCurrentCharges,
	chargeCooldownStartTime,
	chargeCooldownDuration,
	chargeModRate
)
	local showLossOfControlCooldown = (lossOfControlStartTime + lossOfControlDuration) > (cooldownStartTime + cooldownDuration);
	local showChargeCooldown = not showLossOfControlCooldown and chargeMaxCharges > 1 and chargeCurrentCharges < chargeMaxCharges;
	local showNormalCooldown = not showLossOfControlCooldown and cooldownDuration > 0 and cooldownIsEnabled;

	if lossOfControlCooldown then
		SecureCooldown_SetOrClear(lossOfControlCooldown, lossOfControlStartTime, lossOfControlDuration, showLossOfControlCooldown, lossOfControlModRate);
	end
	SecureCooldown_SetOrClear(chargeCooldown, chargeCooldownStartTime, chargeCooldownDuration, showChargeCooldown, chargeModRate);
	SecureCooldown_SetOrClear(normalCooldown, cooldownStartTime, cooldownDuration, showNormalCooldown, cooldownModRate);
end
local SecureCooldown_ApplyCooldownDelegate = CreateSecureDelegate(SecureCooldown_ApplyCooldown);

function ActionButton_ApplyCooldown(normalCooldown, cooldownInfo, chargeCooldown, chargeInfo, lossOfControlCooldown, lossOfControlInfo)
	SecureCooldown_ApplyCooldownDelegate(
		lossOfControlCooldown,
		lossOfControlInfo.startTime,
		lossOfControlInfo.duration,
		lossOfControlInfo.modRate,
		normalCooldown,
		cooldownInfo.startTime,
		cooldownInfo.duration,
		cooldownInfo.isEnabled,
		cooldownInfo.modRate,
		chargeCooldown,
		chargeInfo.maxCharges,
		chargeInfo.currentCharges,
		chargeInfo.cooldownStartTime,
		chargeInfo.cooldownDuration,
		chargeInfo.chargeModRate
	);
end

function ClearActionButtonCooldowns(normalCooldown, chargeCooldown, lossOfControlCooldown)
	CooldownPrototype.Clear(normalCooldown);
	CooldownPrototype.Clear(chargeCooldown);
	if lossOfControlCooldown then
		CooldownPrototype.Clear(lossOfControlCooldown);
	end
end

function ActionBarActionButtonMixin:UpdateSpellAlert()
	local spellType, id, subType  = GetActionInfo(self.action);

	local show = (spellType == "spell" or spellType == "macro") and C_SpellActivationOverlay.IsSpellOverlayed(id);
	if show then
		ActionButtonSpellAlertManager:ShowAlert(self);
	else
		ActionButtonSpellAlertManager:HideAlert(self);
	end

	self:EvaluateTutorials(spellType, id);
end

function ActionBarActionButtonMixin:UpdateAssistedCombatRotationFrame()
	local show = C_ActionBar.IsAssistedCombatAction(self.action);
	local assistedCombatRotationFrame = self.AssistedCombatRotationFrame;
	-- create frame if needed
	if show and not assistedCombatRotationFrame then
		assistedCombatRotationFrame = CreateFrame("Frame", nil, self, "ActionBarButtonAssistedCombatRotationTemplate");
		self.AssistedCombatRotationFrame = assistedCombatRotationFrame;
	end

	if assistedCombatRotationFrame then
		assistedCombatRotationFrame:UpdateState();
	end
end

-- Override as needed
function ActionBarActionButtonMixin:EvaluateTutorials(spellType, id)
end

ActionBarOverlayGlowAnimInMixin = {};

function ActionBarOverlayGlowAnimInMixin:OnPlay()
	local frame = self:GetParent();
	local frameWidth, frameHeight = frame:GetSize();
	frame.spark:SetSize(frameWidth, frameHeight);
	frame.spark:SetAlpha(0.3);
	frame.innerGlow:SetSize(frameWidth / 2, frameHeight / 2);
	frame.innerGlow:SetAlpha(1.0);
	frame.innerGlowOver:SetAlpha(1.0);
	frame.outerGlow:SetSize(frameWidth * 2, frameHeight * 2);
	frame.outerGlow:SetAlpha(1.0);
	frame.outerGlowOver:SetAlpha(1.0);
	frame.ants:SetSize(frameWidth * 0.85, frameHeight * 0.85)
	frame.ants:SetAlpha(0);
	frame:Show();
end

function ActionBarOverlayGlowAnimInMixin:OnFinished()
	local frame = self:GetParent();
	local frameWidth, frameHeight = frame:GetSize();
	frame.spark:SetAlpha(0);
	frame.innerGlow:SetAlpha(0);
	frame.innerGlow:SetSize(frameWidth, frameHeight);
	frame.innerGlowOver:SetAlpha(0.0);
	frame.outerGlow:SetSize(frameWidth, frameHeight);
	frame.outerGlowOver:SetAlpha(0.0);
	frame.outerGlowOver:SetSize(frameWidth, frameHeight);
	frame.ants:SetAlpha(1.0);
end

ActionButtonInterruptAnimInMixin = {};
function ActionButtonInterruptAnimInMixin:OnFinished()
	self:GetParent():GetParent():Hide();
end

function ActionBarActionButtonMixin:MatchesActiveButtonSpellID(spellID)
	if(not spellID) then
		return false;
	end

	local actionType, id, subType = GetActionInfo(self.action);
	if actionType == "item" then
		id = C_ActionBar.GetSpell(self.action);
	end
	return id == spellID;
end

function ActionBarActionButtonMixin:RegisterActionBarButtonCheckFrames(action)
	ActionBarButtonRangeCheckFrame:RegisterFrame(action, self);
	ActionBarButtonUsableWatcherFrame:RegisterFrame(action, self);
end

function ActionBarActionButtonMixin:UnregisterActionBarButtonCheckFrames(action)
	ActionBarButtonRangeCheckFrame:UnregisterFrame(action, self);
	ActionBarButtonUsableWatcherFrame:UnregisterFrame(action, self);
end

function ActionBarActionButtonMixin:OnEvent(event, ...)
	local arg1 = ...;
	if ((event == "UNIT_INVENTORY_CHANGED" and arg1 == "player") or event == "LEARNED_SPELL_IN_SKILL_LINE") then
		if ( GameTooltip:GetOwner() == self ) then
			self:SetTooltip();
		end
	elseif ( event == "ACTIONBAR_SLOT_CHANGED" ) then
		if ( arg1 == 0 or arg1 == tonumber(self.action) ) then
			ClearNewActionHighlight(self.action, true);
			self:UpdateAction(true);
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self:Update();
	elseif ( event == "UPDATE_SHAPESHIFT_FORM" ) then
		-- need to listen for UPDATE_SHAPESHIFT_FORM because attack icons change when the shapeshift form changes
		-- This is NOT intended to update everything about shapeshifting; most stuff should be handled by ActionBar-specific events such as UPDATE_BONUS_ACTIONBAR, UPDATE_USABLE, etc.
		local texture = C_ActionBar.GetActionTexture(self.action);
		if (texture) then
			self.icon:SetTexture(texture);
		end
	elseif ( event == "UPDATE_BINDINGS" or event == "GAME_PAD_ACTIVE_CHANGED" ) then
		self:UpdateHotkeys(self.buttonType);
	-- All event handlers below this line are only set when the button has an action
	elseif ( event == "UNIT_FLAGS" or event == "UNIT_AURA" or event == "PET_BAR_UPDATE" ) then
		-- Pet actions can also change the state of action buttons.
		self.flashDirty = true;
		self.stateDirty = true;
		self:CheckNeedsUpdate();
	elseif ( (event == "ACTIONBAR_UPDATE_STATE") or
		((event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") and (arg1 == "player")) or
		((event == "COMPANION_UPDATE") and (arg1 == "MOUNT")) ) then
		self:UpdateState();
	elseif ( event == "PLAYER_MOUNT_DISPLAY_CHANGED" ) then
		self:UpdateUsable();
	elseif ( event == "LOSS_OF_CONTROL_UPDATE" ) then
		ActionButton_UpdateCooldown(self);
	elseif ( event == "ACTIONBAR_UPDATE_COOLDOWN" or event == "LOSS_OF_CONTROL_ADDED" ) then
		ActionButton_UpdateCooldown(self);
		-- Update tooltip
		if ( GameTooltip:GetOwner() == self ) then
			self:SetTooltip();
		end
	elseif ( event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE"  or event == "ARCHAEOLOGY_CLOSED" ) then
		self:UpdateState();
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		if ( C_ActionBar.IsAttackAction(self.action) ) then
			self:StartFlash();
		end
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		if ( C_ActionBar.IsAttackAction(self.action) ) then
			self:StopFlash();
		end
	elseif ( event == "START_AUTOREPEAT_SPELL" ) then
		if ( C_ActionBar.IsAutoRepeatAction(self.action) ) then
			self:StartFlash();
		end
	elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
		if ( self:IsFlashing() and not C_ActionBar.IsAttackAction(self.action) ) then
			self:StopFlash();
		end
	elseif ( event == "PET_STABLE_UPDATE" or event == "PET_STABLE_SHOW") then
		-- Has to update everything for now, but this event should happen infrequently
		self:Update();
	elseif ( event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" ) then
		local actionType, id, subType = GetActionInfo(self.action);
		if ( actionType == "spell" and id == arg1 ) then
			ActionButtonSpellAlertManager:ShowAlert(self);
		elseif ( actionType == "macro" and subType == "spell" ) then
			if ( id == arg1 ) then
				ActionButtonSpellAlertManager:ShowAlert(self);
			end
		elseif (actionType == "flyout" and FlyoutHasSpell(id, arg1)) then
			ActionButtonSpellAlertManager:ShowAlert(self);
		end
	elseif ( event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" ) then
		local actionType, id, subType = GetActionInfo(self.action);
		if ( actionType == "spell" and id == arg1 ) then
			ActionButtonSpellAlertManager:HideAlert(self);
		elseif ( actionType == "macro" and subType == "spell" ) then
			if (id == arg1 ) then
				ActionButtonSpellAlertManager:HideAlert(self);
			end
		elseif (actionType == "flyout" and FlyoutHasSpell(id, arg1)) then
			ActionButtonSpellAlertManager:HideAlert(self);
		end
	elseif ( event == "SPELL_UPDATE_CHARGES" ) then
		self:UpdateCount();
	elseif ( event == "UPDATE_SUMMONPETS_ACTION" ) then
		local actionType, id = GetActionInfo(self.action);
		if (actionType == "summonpet") then
			local texture = C_ActionBar.GetActionTexture(self.action);
			if (texture) then
				self.icon:SetTexture(texture);
			end
		end
	elseif ( event == "SPELL_UPDATE_ICON" ) then
		self:Update();
	elseif ( event == "ACTION_RANGE_CHECK_UPDATE" ) then
		local inRange, checksRange = select(2, ...);
		ActionButton_UpdateRangeIndicator(self, checksRange, inRange);
	elseif (event == "UNIT_SPELLCAST_INTERRUPTED") then
		self:PlaySpellInterruptedAnim();
	elseif (event == "UNIT_SPELLCAST_START") then
		self:PlaySpellCastAnim(ActionButtonCastType.Cast);
	elseif (event == "UNIT_SPELLCAST_STOP") then
		self:StopSpellCastAnim(true, ActionButtonCastType.Cast);
		self:StopTargettingReticleAnim();
	elseif(event == "UNIT_SPELLCAST_SUCCEEDED") then
		self:StopSpellCastAnim(false, ActionButtonCastType.Cast);
		self:StopTargettingReticleAnim();
	elseif(event == "UNIT_SPELLCAST_SENT" or event == "UNIT_SPELLCAST_FAILED") then
		self:StopTargettingReticleAnim();
	elseif (event == "UNIT_SPELLCAST_EMPOWER_START") then
		self:PlaySpellCastAnim(ActionButtonCastType.Empowered);
	elseif(event == "UNIT_SPELLCAST_EMPOWER_STOP") then
		local _, _, _, castComplete = ...;
		local interrupted = not castComplete;
		if(interrupted) then
			self:PlaySpellInterruptedAnim();
		else
			self:StopSpellCastAnim(interrupted, ActionButtonCastType.Empowered);
		end
	elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then
			self:PlaySpellCastAnim(ActionButtonCastType.Channel);
	elseif (event == "UNIT_SPELLCAST_CHANNEL_STOP") then
			self:StopSpellCastAnim(false, ActionButtonCastType.Channel);
	elseif (event == "UNIT_SPELLCAST_RETICLE_TARGET") then
			self:PlayTargettingReticleAnim();
	elseif (event == "UNIT_SPELLCAST_RETICLE_CLEAR") then
			self:StopTargettingReticleAnim();
	elseif event == "AssistedCombatManager.OnSetActionSpell" then
		self:UpdateAssistedCombatRotationFrame();
	end
end

function ActionBarActionButtonMixin:SetTooltip()
	local inQuickKeybind = KeybindFrames_InQuickKeybindMode();
	if ( GetCVar("UberTooltips") == "1" or inQuickKeybind ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		if ( self.bar and (self.bar == MultiBarBottomRight or self.bar == MultiBarRight or self.bar == MultiBarLeft) ) then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		end
	end
	if ( GameTooltip:SetAction(self.action) ) then
		self.UpdateTooltip = self.SetTooltip;
	else
		self.UpdateTooltip = nil;
	end
end

function ActionBarActionButtonMixin:CheckNeedsUpdate()
	local needsUpdate = (self.stateDirty or self.flashDirty or self:IsFlashing()) and self:IsVisible();
	if (needsUpdate ~= self.needsUpdate) then
		if needsUpdate then
			ActionBarButtonUpdateFrame:RegisterFrame(self);
		else
			ActionBarButtonUpdateFrame:UnregisterFrame(self);
		end
		self.needsUpdate = needsUpdate;
	end
end

function ActionBarActionButtonMixin:OnUpdate(elapsed)
	if ( self.stateDirty ) then
		self:UpdateState();
		self.stateDirty = nil;
	end

	if ( self.flashDirty ) then
		self:UpdateFlash();
		self.flashDirty = nil;
	end

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

	self:CheckNeedsUpdate();
end

function ActionBarActionButtonMixin:OnShow()
	self:CheckNeedsUpdate();
	if self.action then
		self:Update();
		self:RegisterActionBarButtonCheckFrames(self.action);
	end
end

function ActionBarActionButtonMixin:OnHide()
	self:CheckNeedsUpdate();
	if self.action then
		self:UnregisterActionBarButtonCheckFrames(self.action);
	end
end

function ActionBarActionButtonMixin:SpellFXEnabled()
	return self.enableSpellFX;
end

function ActionBarActionButtonMixin:ClearReticle()
	if (not self:SpellFXEnabled()) then
		return;
	end

	if(self.TargetReticleAnimFrame:IsShown()) then
		self.TargetReticleAnimFrame:Hide();
	end
end

function ActionBarActionButtonMixin:ClearInterruptDisplay()
	if (not self:SpellFXEnabled()) then
		return;
	end

	if(self.InterruptDisplay:IsShown()) then
		self.InterruptDisplay:Hide();
	end
end

function ActionBarActionButtonMixin:PlaySpellCastAnim(actionButtonCastType)
	if (not self:SpellFXEnabled()) then
		return;
	end

	self.cooldown:SetSwipeColor(0, 0, 0, 0);
	self.hideCooldownFrame = true;
	self:ClearInterruptDisplay();
	self:ClearReticle();
	self.SpellCastAnimFrame:Setup(actionButtonCastType);
	self.actionButtonCastType = actionButtonCastType;
end

function ActionBarActionButtonMixin:PlayTargettingReticleAnim()
	if (not self:SpellFXEnabled()) then
		return;
	end

	if(self.InterruptDisplay:IsShown()) then
		self.InterruptDisplay:Hide();
	end
	if not C_ActionBar.IsAssistedCombatAction(self.action) then
		self.TargetReticleAnimFrame:Setup();
	end
end

function ActionBarActionButtonMixin:StopTargettingReticleAnim()
	if (not self:SpellFXEnabled()) then
		return;
	end

	if (self.TargetReticleAnimFrame:IsShown()) then
		self.TargetReticleAnimFrame:Hide();
	end
end

function ActionBarActionButtonMixin:StopSpellCastAnim(forceStop, actionButtonCastType)
	if (not self:SpellFXEnabled()) then
		return;
	end

	self:StopTargettingReticleAnim();

	if (self.actionButtonCastType == actionButtonCastType) then
		if(forceStop) then
			self.SpellCastAnimFrame:Hide();
		elseif(self.SpellCastAnimFrame.Fill.CastingAnim:IsPlaying()) then
			self.SpellCastAnimFrame:FinishAnimAndPlayBurst();
		end
		self.actionButtonCastType = nil;
	end
end

function ActionBarActionButtonMixin:PlaySpellInterruptedAnim()
	if (not self:SpellFXEnabled()) then
		return;
	end

	self:StopSpellCastAnim(true, self.actionButtonCastType);
	--Hide if it's already showing to clear the anim.
	if(self.InterruptDisplay:IsShown()) then
		self.InterruptDisplay:Hide();
	end
	self.InterruptDisplay:Show();
end

-- Shared between the action bar and the pet bar.
function ActionButton_UpdateRangeIndicator(self, checksRange, inRange)
	if ( self.HotKey:GetText() == RANGE_INDICATOR ) then
		if ( checksRange ) then
			self.HotKey:Show();
			if ( inRange ) then
				self.HotKey:SetVertexColor(ACTIONBAR_HOTKEY_FONT_COLOR:GetRGB());
			else
				self.HotKey:SetVertexColor(RED_FONT_COLOR:GetRGB());
			end
		else
			self.HotKey:Hide();
		end
	else
		if ( checksRange and not inRange ) then
			self.HotKey:SetVertexColor(RED_FONT_COLOR:GetRGB());
		else
			self.HotKey:SetVertexColor(ACTIONBAR_HOTKEY_FONT_COLOR:GetRGB());
		end
	end
end

function ActionBarActionButtonMixin:GetPagedID()
    return self.action;
end

function ActionBarActionButtonMixin:UpdateFlash()
	local action = self.action;
	local actionType, actionID, actionSubtype = GetActionInfo(action);

	if ( (C_ActionBar.IsAttackAction(action) and C_ActionBar.IsCurrentAction(action)) or C_ActionBar.IsAutoRepeatAction(action) ) then
		self:StartFlash();

		if ( actionSubtype == "pet" ) then
			self:GetCheckedTexture():SetAlpha(0.5);
		else
			self:GetCheckedTexture():SetAlpha(1.0);
		end
	else
		self:StopFlash();
	end

	if ( self.AutoCastOverlay ) then
		-- Outfit actions.
		local isLockedOutfit = actionType == "outfit" and C_TransmogOutfitInfo.IsLockedOutfit(actionID);
		local isLockedEquippedGear = C_ActionBar.IsEquippedGearOutfitAction(action) and C_TransmogOutfitInfo.IsEquippedGearOutfitLocked();

		-- Pet actions.
		local isAutoCastPetAction = C_ActionBar.IsAutoCastPetAction(action);
		local isEnabledAutoCastPetAction = C_ActionBar.IsEnabledAutoCastPetAction(action);

		self.AutoCastOverlay:SetShown(isLockedOutfit or isLockedEquippedGear or isAutoCastPetAction);
		self.AutoCastOverlay:ShowAutoCastEnabled(isLockedOutfit or isLockedEquippedGear or isEnabledAutoCastPetAction);
	end
end

function ActionBarActionButtonMixin:ClearFlash()
	if ( self.AutoCastOverlay ) then
		self.AutoCastOverlay:ShowAutoCastEnabled(false);
		self.AutoCastOverlay:Hide();
	end
end

function ActionBarActionButtonMixin:StartFlash()
	self.flashing = 1;
	self.flashtime = 0;
	self:UpdateState();
	self:CheckNeedsUpdate();
end

function ActionBarActionButtonMixin:StopFlash()
	self.flashing = 0;
	self.Flash:Hide();
	self:UpdateState();
	self:CheckNeedsUpdate();
end

function ActionBarActionButtonMixin:IsFlashing()
	if ( self.flashing == 1 ) then
		return 1;
	end

	return nil;
end

-- Shared between action bar buttons and spell flyout buttons
function ActionBarActionButtonMixin:UpdateFlyout(isButtonDownOverride)
	BaseActionButtonMixin.UpdateFlyout(self, isButtonDownOverride);
end

function ActionBarActionButtonMixin:SetButtonStateOverride(state)
	self:SetButtonStateBase(state);
end

function ActionBarActionButtonMixin:OnClick(button, down)
	if ( KeybindFrames_InQuickKeybindMode() ) then
		local cursorType = GetCursorInfo();
		if ( cursorType ) then
			local slotID = self:CalculateAction(button);
			C_ActionBar.PutActionInSlot(slotID);
		end
	else
		if button == "RightButton" and C_ActionBar.IsAutoCastPetAction(self.action) then
			if not down then
				C_ActionBar.ToggleAutoCastPetAction(self.action);
			end
		else
			local actionBarLocked = Settings.GetValue("lockActionBars");

			local isModifiedClickLockedBarDoNothing = IsModifiedClick("PICKUPACTION");
			if GetCursorInfo() then
				-- If we have something on the cursor then we don't care whether it was a modified click
				-- as far as lockedBarDoNothing goes
				isModifiedClickLockedBarDoNothing = false;
			end

			local lockedBarDoNothing = actionBarLocked and down and isModifiedClickLockedBarDoNothing;
			local unlockedBarDoNothing = not actionBarLocked and (self:GetAttribute("pressAndHoldAction") and down);
			if lockedBarDoNothing or unlockedBarDoNothing then
				return;
			end

			local isKeyPress = false;
			local isSecureAction = true;
			SecureActionButton_OnClick(self, button, down, isKeyPress, isSecureAction);
		end
	end
end

function ActionBarActionButtonMixin:OnDragStart()
	if ( not Settings.GetValue("lockActionBars") or IsModifiedClick("PICKUPACTION") ) then
		-- If an IconSelectorPopupFrame is active, we do not want to remove the action from the bar, just copy it to the mouse.
		local ignoreActionRemoval = IsAnyIconSelectorPopupFrameShown();
		PickupAction(self.action, ignoreActionRemoval);

		SpellFlyout:Hide();
		self:UpdateState();
		self:UpdateFlash();
	end
end

function ActionBarActionButtonMixin:OnReceiveDrag()
	PlaceAction(self.action);
	self:UpdateState();
	self:UpdateFlash();
end

function ActionBarActionButtonMixin:OnEnter()
	if (self.NewActionTexture) then
		ClearNewActionHighlight(self.action);
		self:UpdateAction(true);
	end
	self:SetTooltip();
	ActionBarButtonEventsFrame.tooltipOwner = self;
	ActionBarActionEventsFrame.tooltipOwner = self;
	if self.bindingAction then
		ActionButtonBindingHighlightCallbackRegistry:TriggerEvent(self.bindingAction, true);
	end
end

function ActionBarActionButtonMixin:OnLeave()
	GameTooltip:Hide();
	ActionBarButtonEventsFrame.tooltipOwner = nil;
	ActionBarActionEventsFrame.tooltipOwner = nil;
	if self.bindingAction then
		ActionButtonBindingHighlightCallbackRegistry:TriggerEvent(self.bindingAction, false);
	end
end


-- Can be overridden by ActionButtonOverrides.
ActionBarButtonEventsDerivedFrameMixin = CreateFromMixins(ActionBarButtonEventsFrameMixin);
ActionBarActionButtonDerivedMixin = CreateFromMixins(ActionBarActionButtonMixin);

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnLoad()
	ActionBarActionButtonMixin.OnLoad(self);
end

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnAttributeChanged()
	ActionBarActionButtonMixin.OnAttributeChanged(self);
end

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnEvent(event, ...)
	ActionBarActionButtonMixin.OnEvent(self, event, ...);
end

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnClick(button, down)
	ActionBarActionButtonMixin.OnClick(self, button, down);
	QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnClick(self, button, down);
end

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnPostClick()
	ActionBarActionButtonMixin.UpdateState(self);
end

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnDragStart()
	ActionBarActionButtonMixin.OnDragStart(self);
end

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnReceiveDrag()
	ActionBarActionButtonMixin.OnReceiveDrag(self);
end

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnDragStop()

end

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnEnter()
	ActionBarActionButtonMixin.OnEnter(self);
	QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnEnter(self);
end

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnLeave()
	ActionBarActionButtonMixin.OnLeave(self);
	QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnLeave(self);
end

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnShow()
	ActionBarActionButtonMixin.OnShow(self);
	QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnShow(self);
end

function ActionBarActionButtonDerivedMixin:ActionBarActionButtonDerivedMixin_OnHide()
	ActionBarActionButtonMixin.OnHide(self);
	QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnHide(self);
end


BaseActionButtonMixin = {}

function BaseActionButtonMixin:BaseActionButtonMixin_OnLoad()
	FlyoutButtonMixin.OnLoad(self);

	self:UpdateButtonArt();
	self:UpdateFlyout();

	self.NormalTexture:SetDrawLayer("OVERLAY");
	self.PushedTexture:SetDrawLayer("OVERLAY");
end

function BaseActionButtonMixin:BaseActionButtonMixin_OnEnter()
	FlyoutButtonMixin.OnEnter(self);
end

function BaseActionButtonMixin:BaseActionButtonMixin_OnLeave()
	FlyoutButtonMixin.OnLeave(self);
end

function BaseActionButtonMixin:BaseActionButtonMixin_OnDragStart()
	FlyoutButtonMixin.OnDragStart(self);
end

function BaseActionButtonMixin:BaseActionButtonMixin_OnAttributeChanged(name, value)
	self:UpdateFlyout();
end

function BaseActionButtonMixin:GetShowGrid()
	local showGridAttribute = self:GetAttribute("showgrid");
	return showGridAttribute and showGridAttribute > 0 or false;
end

function BaseActionButtonMixin:SetShowGrid(showGrid, reason)
	assert(reason);

	if ( issecure() and self:GetShowGrid() ~= showGrid ) then
		local showGridAttribute = self:GetAttribute("showgrid");
		if ( showGrid ) then
			self:SetAttribute("showgrid", bit.bor(showGridAttribute or 0, reason));
		else
			self:SetAttribute("showgrid", bit.band(showGridAttribute or 0, bit.bnot(reason)));
		end
	end
end

function BaseActionButtonMixin:UpdateButtonArt()
	-- Overridden for various game flavors.
end

-- Shared between action bar buttons and spell flyout buttons
function BaseActionButtonMixin:UpdateFlyout(isButtonDownOverride)
	if not self.HasPopup then
		return;
	end

	-- Attempt to resolve the action on this button to a flyout, either by
	-- having the secure "type" attribute explicitly set to "flyout" or by
	-- configuring it as a regular "action" with a slot ID that itself holds
	-- a flyout.
	--
	-- This is intended to support case where a button inherits from a
	-- fully-featured button template such as ActionBarButtonTemplate, or
	-- a barebones combo of ActionButtonTemplate + SecureActionButtonTemplate.

	local effectiveButton = SecureButton_GetEffectiveButton(self);
	local popupDirection = SecureButton_GetModifiedAttribute(self, "flyoutDirection", effectiveButton);
	local actionType = SecureButton_GetModifiedAttribute(self, "type", effectiveButton);

	if actionType == nil or actionType == "action" then
		local slotID;

		if self.CalculateAction then
			slotID = self:CalculateAction();
		else
			slotID = self.action;
		end

		if slotID then
			actionType = GetActionInfo(slotID);
		end
	end

	-- If an explicit popup direction hasn't been supplied and the button is on an action bar then use the direction from the action bar.
	if not popupDirection and self.bar then
		popupDirection = self.bar:GetSpellFlyoutDirection();
	end

	-- FlyoutButtonMixin stores the direction of the popout on a field
	-- on the button itself, which needs securely updating from the value
	-- stored in the attribute if defined.

	if popupDirection then
		self:SetPopupDirection(popupDirection);
	end

	if actionType == "flyout" and SpellFlyout then
		self:SetPopup(SpellFlyout);
	else
		self:ClearPopup();
	end
end

ActionBarButtonMixin = {};

function ActionBarButtonMixin:ActionBarButtonMixin_OnLoad()
	BaseActionButtonMixin.BaseActionButtonMixin_OnLoad(self);
	ActionBarActionButtonDerivedMixin.ActionBarActionButtonDerivedMixin_OnLoad(self);
end

function ActionBarButtonMixin:ActionBarButtonMixin_OnEnter()
	BaseActionButtonMixin.BaseActionButtonMixin_OnEnter(self);
	ActionBarActionButtonDerivedMixin.ActionBarActionButtonDerivedMixin_OnEnter(self);
end

function ActionBarButtonMixin:ActionBarButtonMixin_OnLeave()
	BaseActionButtonMixin.BaseActionButtonMixin_OnLeave(self);
	ActionBarActionButtonDerivedMixin.ActionBarActionButtonDerivedMixin_OnLeave(self);
end

function ActionBarButtonMixin:ActionBarButtonMixin_OnDragStart()
	BaseActionButtonMixin.BaseActionButtonMixin_OnDragStart(self);
	ActionBarActionButtonDerivedMixin.ActionBarActionButtonDerivedMixin_OnDragStart(self);
end

SmallActionButtonMixin = {}

function SmallActionButtonMixin:SmallActionButtonMixin_OnLoad()
	BaseActionButtonMixin.BaseActionButtonMixin_OnLoad(self);

	self.HotKey:ClearAllPoints();
	self.HotKey:SetPoint("TOPRIGHT", self.hotkeyX or 0, self.hotkeyY or 0);

	self.Count:ClearAllPoints();
	self.Count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 1);

	self.IconMask:SetSize(45, 45);
	self.IconMask:ClearAllPoints();
	self.IconMask:SetPoint("CENTER", 0.5, -0.5);

	self.AutoCastOverlay:SetSize(31, 31);
	self.AutoCastOverlay:ClearAllPoints();
	self.AutoCastOverlay:SetPoint("CENTER", 0.5, -0.5);

	self.HighlightTexture:SetSize(31.6, 30.9);
	self.CheckedTexture:SetSize(31.6, 30.9);

	if self.QuickKeybindHighlightTexture then
		self.QuickKeybindHighlightTexture:ClearAllPoints();
		self.QuickKeybindHighlightTexture:SetPoint("CENTER");
		self.QuickKeybindHighlightTexture:SetSize(31.6, 30.9);
	end

	self.NewActionTexture:SetSize(31.6, 30.9);
	self.SpellHighlightTexture:SetSize(31.6, 30.9);
	self.Border:SetSize(31.6, 30.9);
	self.Flash:SetSize(31.6, 30.9);

	self.cooldown:ClearAllPoints();
	self.cooldown:SetPoint("TOPLEFT", self.icon, "TOPLEFT", 1.7, -1.7);
	self.cooldown:SetPoint("BOTTOMRIGHT", self.icon, "BOTTOMRIGHT", -1, 1);
end

function SmallActionButtonMixin:UpdateButtonArt()
	BaseActionButtonMixin.UpdateButtonArt(self);

	-- Gotta set these texture sizes here since BaseActionButtonMixin.UpdateButtonArt changes their size
	self.NormalTexture:SetSize(35, 35);
	self.PushedTexture:SetSize(35, 35);
end

ActionButtonInterruptFrameMixin = { };

function ActionButtonInterruptFrameMixin:OnShow()
	self.Base.AnimIn:Play();
	self.Highlight.AnimIn:Play();
end

function ActionButtonInterruptFrameMixin:OnHide()
	self.Base.AnimIn:Stop();
	self.Highlight.AnimIn:Stop();
end

ActionButtonCastingAnimFrameMixin = { };

function ActionButtonCastingAnimFrameMixin:Setup(actionButtonCastType)
	local startTime, endTime, totalTimeInSeconds;

	local isChannelCast = actionButtonCastType == ActionButtonCastType.Channel;
	local isEmpoweredCast = actionButtonCastType == ActionButtonCastType.Empowered;
	local _;
	if (isChannelCast or isEmpoweredCast) then
		_, _, _, startTime, endTime = UnitChannelInfo("player");
	else
		_, _, _, startTime, endTime = UnitCastingInfo("player");
	end

	self.EndBurst:Hide();

	local fillFrame = self.Fill;
	fillFrame.CastFill:ClearAllPoints();
	local castingAnim = self.Fill.CastingAnim;
	local finishCastAnim = self.EndBurst.FinishCastAnim;

	castingAnim:Stop();
	finishCastAnim:Stop();
	if (isChannelCast) then
		fillFrame.CastFill:SetAtlas("UI-HUD-ActionBar-Channel-Fill", true);
		fillFrame.InnerGlowTexture:SetAtlas("UI-HUD-ActionBar-Channel-InnerGlow", true);
		fillFrame.CastFill:SetPoint("CENTER", 45, 0);
		fillFrame.CastingAnim.CastFillTranslation:SetOffset(-43, 0);
	else
		fillFrame.CastFill:SetAtlas("UI-HUD-ActionBar-Cast-Fill", true);
		fillFrame.InnerGlowTexture:SetAtlas("UI-HUD-ActionBar-Casting-InnerGlow", true);
		fillFrame.CastFill:SetPoint("CENTER", -45, 0);
		fillFrame.CastingAnim.CastFillTranslation:SetOffset(43, 0);
	end

	if not isEmpoweredCast and (not startTime or not endTime)  then

		totalTimeInSeconds = 0;
	else
		totalTimeInSeconds = (endTime - startTime) / 1000;
	end

	castingAnim.CastFillTranslation:SetDuration(totalTimeInSeconds);
	castingAnim:Play();
	self:Show();
end

function ActionButtonCastingAnimFrameMixin:OnHide()
	local parent = self:GetParent();
	parent:ClearReticle();
	parent.cooldown:SetSwipeColor(0, 0, 0, 1);
	ActionButton_UpdateCooldown(parent);
end

function ActionButtonCastingAnimFrameMixin:FinishAnimAndPlayBurst()
	self.Fill.CastingAnim:Stop();
	self.Fill.CastingAnim:OnFinished();
end

ActionButtonCastingAnimationFillMixin = { };

function ActionButtonCastingAnimationFillMixin:OnFinished()
	local endBurst = self:GetParent():GetParent().EndBurst;
	endBurst:Show();
	endBurst.FinishCastAnim:Play();
end

ActionButtonCastingFinishAnimMixin = { };
function ActionButtonCastingFinishAnimMixin:OnFinished()
	self:GetParent():GetParent():Hide();
	local parentButton = self:GetParent():GetParent():GetParent();
	self:GetParent():GetParent():GetParent():StopSpellCastAnim(false, parentButton.actionButtonCastType);
end

ActionButtonTargetReticleFrameMixin = { };
function ActionButtonTargetReticleFrameMixin:Setup()
	self.HighlightAnim:Play();
	self:Show();
end

ActionButtonCooldownFlashMixin = { };
function ActionButtonCooldownFlashMixin:Setup()
	self.FlashAnim:Play();
	self:Show();
end

ActionButtonCooldownFlashAnimMixin = { };
function ActionButtonCooldownFlashAnimMixin:OnFinished()
	self:GetParent():Hide();
end

-- This is done to preserve old hierarchy, while allowing for proper layering of the HotKey text
ActionButtonTextOverlayContainerMixin = {};
function ActionButtonTextOverlayContainerMixin:OnLoad()
	local parentActionButton = self:GetParent();
	parentActionButton.HotKey = self.HotKey;
	parentActionButton.Count = self.Count;
end

ActionBarButtonAssistedCombatRotationFrameMixin = { };

function ActionBarButtonAssistedCombatRotationFrameMixin:OnLoad()
	local actionButton = self:GetParent();
	local frameWidth, frameHeight = actionButton:GetSize();
	self:SetSize(frameWidth * 1.4, frameHeight * 1.4);
	self:SetPoint("CENTER", actionButton, "CENTER", -2, 1);

	if MainActionBar then
		self:SetFrameLevel(MainActionBar:GetEndCapsFrameLevel() + 1);
	end

	self.updateTimeLeft = 0;

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function ActionBarButtonAssistedCombatRotationFrameMixin:OnShow()
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");

	self:UpdateGlow();
	self:EvaluateTutorials();
end

function ActionBarButtonAssistedCombatRotationFrameMixin:OnHide()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED");
	self:UnregisterEvent("PLAYER_REGEN_DISABLED");
end

function ActionBarButtonAssistedCombatRotationFrameMixin:OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" then
		self:SetFrameLevel(MainActionBar:GetEndCapsFrameLevel() + 1);
		-- action bars go through setup on PEW too so this needs to wait
		RunNextFrame(function()
			-- gotta check since we're doing things out of order now
			if self:IsShown() then
				self:EvaluateTutorials();
			end
		end);
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	elseif event == "ASSISTED_COMBAT_ACTION_SPELL_CAST" then
		HelpTip:Acknowledge(UIParent, ASSISTED_COMBAT_ROTATION_ACTION_BUTTON_HELPTIP);
		self:UnregisterEvent("ASSISTED_COMBAT_ACTION_SPELL_CAST");
	else
		self:UpdateGlow();
	end
end

function ActionBarButtonAssistedCombatRotationFrameMixin:OnUpdate(elapsed)
	self.updateTimeLeft = self.updateTimeLeft - elapsed;
	if self.updateTimeLeft <= 0 then
		local actionButton = self:GetParent();
		C_ActionBar.ForceUpdateAction(actionButton.action);
		self.updateTimeLeft = AssistedCombatManager:GetUpdateRate();
	end
end

function ActionBarButtonAssistedCombatRotationFrameMixin:UpdateState()
	local actionButton = self:GetParent();
	local show = C_ActionBar.IsAssistedCombatAction(actionButton.action);
	local isShown = self:IsShown();
	if show ~= isShown then
		self:SetShown(show);
		EventRegistry:TriggerEvent("ActionButton.OnAssistedCombatRotationFrameChanged", actionButton, show);
	end
end

function ActionBarButtonAssistedCombatRotationFrameMixin:UpdateGlow()
	local affectingCombat = UnitAffectingCombat("player");
	if affectingCombat then
		self.InactiveTexture:Hide();
		self.ActiveFrame:Show();
		self.ActiveFrame.GlowAnim:Play();
	else
		self.InactiveTexture:Show();
		self.ActiveFrame:Hide();
	end
end

function ActionBarButtonAssistedCombatRotationFrameMixin:EvaluateTutorials()
	local actionButton = self:GetParent();
	if not actionButton.bar then
		return;
	end

	if GetCVarBitfield("closedInfoFramesAccountWide", Enum.FrameTutorialAccount.AssistedCombatRotationActionButton) then
		return;
	end

	-- the action spell can be dragged to multiple action buttons
	HelpTip:Hide(UIParent, ASSISTED_COMBAT_ROTATION_ACTION_BUTTON_HELPTIP);

	local targetPoint = HelpTip.Point.TopEdgeCenter;
	local offsetX = 0;
	local offsetY = -8;

	local direction = actionButton.bar:GetSpellFlyoutDirection();
	if direction == "DOWN" then
		targetPoint = HelpTip.Point.BottomEdgeCenter;
		offsetX = 0;
		offsetY = 8;
	elseif direction == "LEFT" then
		targetPoint = HelpTip.Point.LeftEdgeCenter;
		offsetX = 8;
		offsetY = 0;
	elseif direction == "RIGHT" then
		targetPoint = HelpTip.Point.RightEdgeCenter;
		offsetX = -8;
		offsetY = 0;
	end

	local helpTipInfo = {
		text = ASSISTED_COMBAT_ROTATION_ACTION_BUTTON_HELPTIP,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFramesAccountWide",
		bitfieldFlag = Enum.FrameTutorialAccount.AssistedCombatRotationActionButton,
		targetPoint = targetPoint,
		offsetX = offsetX,
		offsetY = offsetY,
		system = helptipSystem,
		autoHideWhenTargetHides = true,
	};
	HelpTip:Show(UIParent, helpTipInfo, self);

	self:RegisterEvent("ASSISTED_COMBAT_ACTION_SPELL_CAST");
end
