CURRENT_ACTIONBAR_PAGE = 1;
NUM_ACTIONBAR_PAGES = 6;
NUM_ACTIONBAR_BUTTONS = 12;
ATTACK_BUTTON_FLASH_TIME = 0.4;

BOTTOMLEFT_ACTIONBAR_PAGE = 6;
BOTTOMRIGHT_ACTIONBAR_PAGE = 5;
LEFT_ACTIONBAR_PAGE = 4;
RIGHT_ACTIONBAR_PAGE = 3;
RANGE_INDICATOR = "●";

-- Table of actionbar pages and whether they're viewable or not
VIEWABLE_ACTION_BAR_PAGES = {1, 1, 1, 1, 1, 1};

function ActionButtonDown(id)
	local button;
	if ( VehicleMenuBar:IsShown() and id <= VEHICLE_MAX_ACTIONBUTTONS ) then
		button = _G["VehicleMenuBarActionButton"..id];
	elseif ( BonusActionBarFrame:IsShown() ) then
		button = _G["BonusActionButton"..id];
	else
		button = _G["ActionButton"..id];
	end
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
end

function ActionButtonUp(id)
	local button;
	if ( VehicleMenuBar:IsShown() and id <= VEHICLE_MAX_ACTIONBUTTONS ) then
		button = _G["VehicleMenuBarActionButton"..id];
	elseif ( BonusActionBarFrame:IsShown() ) then
		button = _G["BonusActionButton"..id];
	else
		button = _G["ActionButton"..id];
	end
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		SecureActionButton_OnClick(button, "LeftButton");
		ActionButton_UpdateState(button);
	end
end

function ActionBar_PageUp()
	local nextPage;
	for i=GetActionBarPage() + 1, NUM_ACTIONBAR_PAGES do
		if ( VIEWABLE_ACTION_BAR_PAGES[i] ) then
			nextPage = i;
			break;
		end
	end

	if ( not nextPage ) then
		nextPage = 1;
	end
	ChangeActionBarPage(nextPage);
end

function ActionBar_PageDown()
	local prevPage;
	for i=GetActionBarPage() - 1, 1, -1 do
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
	ChangeActionBarPage(prevPage);
end

function ActionButton_OnLoad (self)
	self.flashing = 0;
	self.flashtime = 0;
	self:SetAttribute("showgrid", 0);
	self:SetAttribute("type", "action");
	self:SetAttribute("checkselfcast", true);
	self:SetAttribute("checkfocuscast", true);
	self:SetAttribute("useparent-unit", true);
	self:SetAttribute("useparent-actionpage", true);
	self:RegisterForDrag("LeftButton", "RightButton");
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ACTIONBAR_SHOWGRID");
	self:RegisterEvent("ACTIONBAR_HIDEGRID");
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	ActionButton_UpdateAction(self);
	ActionButton_UpdateHotkeys(self, self.buttonType);
end

function ActionButton_UpdateHotkeys (self, actionButtonType)
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

    local hotkey = _G[self:GetName().."HotKey"];
    local key = GetBindingKey(actionButtonType..id) or
                GetBindingKey("CLICK "..self:GetName()..":LeftButton");

	local text = GetBindingText(key, "KEY_", 1);
    if ( text == "" ) then
        hotkey:SetText(RANGE_INDICATOR);
        hotkey:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -2);
        hotkey:Hide();
    else
        hotkey:SetText(text);
        hotkey:SetPoint("TOPLEFT", self, "TOPLEFT", -2, -2);
        hotkey:Show();
    end
end

function ActionButton_CalculateAction (self, button)
	if ( not button ) then
		button = SecureButton_GetEffectiveButton(self);
	end
	if ( self:GetID() > 0 ) then
		local page = SecureButton_GetModifiedAttribute(self, "actionpage", button);
		if ( not page ) then
			page = GetActionBarPage();
			if ( self.isBonus and (page == 1 or self.alwaysBonus) ) then
				local offset = GetBonusBarOffset();
				if ( offset == 0 and BonusActionBarFrame and BonusActionBarFrame.lastBonusBar ) then
					offset = BonusActionBarFrame.lastBonusBar;
				end
				page = NUM_ACTIONBAR_PAGES + offset;
			elseif ( self.buttonType == "MULTICASTACTIONBUTTON" ) then
				page = NUM_ACTIONBAR_PAGES + GetMultiCastBarOffset();
			end
		end
		return (self:GetID() + ((page - 1) * NUM_ACTIONBAR_BUTTONS));
	else
		return SecureButton_GetModifiedAttribute(self, "action", button) or 1;
	end
end

function ActionButton_UpdateAction (self)
	local action = ActionButton_CalculateAction(self);
	if ( action ~= self.action ) then
		self.action = action;
		ActionButton_Update(self);
	end
end

function ActionButton_Update (self)
	local name = self:GetName();

	local action = self.action;
	local icon = _G[name.."Icon"];
	local buttonCooldown = _G[name.."Cooldown"];
	local texture = GetActionTexture(action);	

	if ( HasAction(action) ) then
		if ( not self.eventsRegistered ) then
			self:RegisterEvent("ACTIONBAR_UPDATE_STATE");
			self:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
			self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			self:RegisterEvent("UPDATE_INVENTORY_ALERTS");
			self:RegisterEvent("PLAYER_TARGET_CHANGED");
			self:RegisterEvent("TRADE_SKILL_SHOW");
			self:RegisterEvent("TRADE_SKILL_CLOSE");
			self:RegisterEvent("PLAYER_ENTER_COMBAT");
			self:RegisterEvent("PLAYER_LEAVE_COMBAT");
			self:RegisterEvent("START_AUTOREPEAT_SPELL");
			self:RegisterEvent("STOP_AUTOREPEAT_SPELL");
			self:RegisterEvent("UNIT_ENTERED_VEHICLE");
			self:RegisterEvent("UNIT_EXITED_VEHICLE");
			self:RegisterEvent("COMPANION_UPDATE");
			self:RegisterEvent("UNIT_INVENTORY_CHANGED");
			self:RegisterEvent("LEARNED_SPELL_IN_TAB");
			self.eventsRegistered = true;
		end

		if ( not self:GetAttribute("statehidden") ) then
			self:Show();
		end
		ActionButton_UpdateState(self);
		ActionButton_UpdateUsable(self);
		ActionButton_UpdateCooldown(self);
		ActionButton_UpdateFlash(self);
	else
		if ( self.eventsRegistered ) then
			self:UnregisterEvent("ACTIONBAR_UPDATE_STATE");
			self:UnregisterEvent("ACTIONBAR_UPDATE_USABLE");
			self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			self:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
			self:UnregisterEvent("PLAYER_TARGET_CHANGED");
			self:UnregisterEvent("TRADE_SKILL_SHOW");
			self:UnregisterEvent("TRADE_SKILL_CLOSE");
			self:UnregisterEvent("PLAYER_ENTER_COMBAT");
			self:UnregisterEvent("PLAYER_LEAVE_COMBAT");
			self:UnregisterEvent("START_AUTOREPEAT_SPELL");
			self:UnregisterEvent("STOP_AUTOREPEAT_SPELL");
			self:UnregisterEvent("UNIT_ENTERED_VEHICLE");
			self:UnregisterEvent("UNIT_EXITED_VEHICLE");
			self:UnregisterEvent("COMPANION_UPDATE");
			self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
			self:UnregisterEvent("LEARNED_SPELL_IN_TAB");
			self.eventsRegistered = nil;
		end

		if ( self:GetAttribute("showgrid") == 0 ) then
			self:Hide();
		else
			buttonCooldown:Hide();
		end
	end

	-- Add a green border if button is an equipped item
	local border = _G[name.."Border"];
	if ( IsEquippedAction(action) ) then
		border:SetVertexColor(0, 1.0, 0, 0.35);
		border:Show();
	else
		border:Hide();
	end

	-- Update Action Text
	local actionName = _G[name.."Name"];
	if ( not IsConsumableAction(action) and not IsStackableAction(action) ) then
		actionName:SetText(GetActionText(action));
	else
		actionName:SetText("");
	end

	-- Update icon and hotkey text
	if ( texture ) then
		icon:SetTexture(texture);
		icon:Show();
		self.rangeTimer = -1;
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
	else
		icon:Hide();
		buttonCooldown:Hide();
		self.rangeTimer = nil;
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		local hotkey = _G[name.."HotKey"];
        if ( hotkey:GetText() == RANGE_INDICATOR ) then
			hotkey:Hide();
		else
			hotkey:SetVertexColor(0.6, 0.6, 0.6);
		end
	end
	ActionButton_UpdateCount(self);	

	-- Update tooltip
	if ( GameTooltip:GetOwner() == self ) then
		ActionButton_SetTooltip(self);
	end

	self.feedback_action = action;
end

function ActionButton_ShowGrid (button)
	assert(button);

	if ( issecure() ) then
		button:SetAttribute("showgrid", button:GetAttribute("showgrid") + 1);
	end

	_G[button:GetName().."NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0, 0.5);

	if ( button:GetAttribute("showgrid") >= 1 and not button:GetAttribute("statehidden") ) then
		button:Show();
	end
end

function ActionButton_HideGrid (button)	
	assert(button);
	
	local showgrid = button:GetAttribute("showgrid");
	
	if ( issecure() ) then
		if ( showgrid > 0 ) then
			button:SetAttribute("showgrid", showgrid - 1);
		end
	end
	
	if ( button:GetAttribute("showgrid") == 0 and not HasAction(button.action) ) then
		button:Hide();
	end
end

function ActionButton_UpdateState (button)
	assert(button);
	
	local action = button.action;
	if ( IsCurrentAction(action) or IsAutoRepeatAction(action) ) then
		button:SetChecked(1);
	else
		button:SetChecked(0);
	end
end

function ActionButton_UpdateUsable (self)
	local name = self:GetName();
	local icon = _G[name.."Icon"];
	local normalTexture = _G[name.."NormalTexture"];
	local isUsable, notEnoughMana = IsUsableAction(self.action);
	if ( isUsable ) then
		icon:SetVertexColor(1.0, 1.0, 1.0);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	elseif ( notEnoughMana ) then
		icon:SetVertexColor(0.5, 0.5, 1.0);
		normalTexture:SetVertexColor(0.5, 0.5, 1.0);
	else
		icon:SetVertexColor(0.4, 0.4, 0.4);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
end

function ActionButton_UpdateCount (self)
	local text = _G[self:GetName().."Count"];
	local action = self.action;
	if ( IsConsumableAction(action) or IsStackableAction(action) ) then
		local count = GetActionCount(action);
		if ( count > (self.maxDisplayCount or 9999 ) ) then
			text:SetText("*");
		else
			text:SetText(count);
		end
	else
		text:SetText("");
	end
end

function ActionButton_UpdateCooldown (self)
	local cooldown = _G[self:GetName().."Cooldown"];
	local start, duration, enable = GetActionCooldown(self.action);
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
end

function ActionButton_OnEvent (self, event, ...)
	local arg1 = ...;
	if ((event == "UNIT_INVENTORY_CHANGED" and arg1 == "player") or event == "LEARNED_SPELL_IN_TAB") then
		if ( GameTooltip:GetOwner() == self ) then
			ActionButton_SetTooltip(self);
		end
	end
	if ( event == "ACTIONBAR_SLOT_CHANGED" ) then
		if ( arg1 == 0 or arg1 == tonumber(self.action) ) then
			ActionButton_Update(self);
		end
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_SHAPESHIFT_FORM" ) then
		-- need to listen for UPDATE_SHAPESHIFT_FORM because attack icons change when the shapeshift form changes
		ActionButton_Update(self);
		return;
	end
	if ( event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_BONUS_ACTIONBAR" ) then
		ActionButton_UpdateAction(self);
		return;
	end
	if ( event == "ACTIONBAR_SHOWGRID" ) then
		ActionButton_ShowGrid(self);
		return;
	end
	if ( event == "ACTIONBAR_HIDEGRID" ) then
		ActionButton_HideGrid(self);
		return;
	end
	if ( event == "UPDATE_BINDINGS" ) then
		ActionButton_UpdateHotkeys(self, self.buttonType);
		return;
	end

	-- All event handlers below this line are only set when the button has an action

	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self.rangeTimer = -1;
	elseif ( (event == "ACTIONBAR_UPDATE_STATE") or
		((event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") and (arg1 == "player")) or
		((event == "COMPANION_UPDATE") and (arg1 == "MOUNT")) ) then
		ActionButton_UpdateState(self);
	elseif ( event == "ACTIONBAR_UPDATE_USABLE" ) then
		ActionButton_UpdateUsable(self);
	elseif ( event == "ACTIONBAR_UPDATE_COOLDOWN" ) then
		ActionButton_UpdateCooldown(self);
	elseif ( event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		ActionButton_UpdateState(self);
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		if ( IsAttackAction(self.action) ) then
			ActionButton_StartFlash(self);
		end
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		if ( IsAttackAction(self.action) ) then
			ActionButton_StopFlash(self);
		end
	elseif ( event == "START_AUTOREPEAT_SPELL" ) then
		if ( IsAutoRepeatAction(self.action) ) then
			ActionButton_StartFlash(self);
		end
	elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
		if ( ActionButton_IsFlashing(self) and not IsAttackAction(self.action) ) then
			ActionButton_StopFlash(self);
		end
	end
end

function ActionButton_SetTooltip (self)
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		local parent = self:GetParent();
		if ( parent == MultiBarBottomRight or parent == MultiBarRight or parent == MultiBarLeft ) then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		end
	end
	if ( GameTooltip:SetAction(self.action) ) then
		self.UpdateTooltip = ActionButton_SetTooltip;
	else
		self.UpdateTooltip = nil;
	end
end

function ActionButton_OnUpdate (self, elapsed)
	if ( ActionButton_IsFlashing(self) ) then
		local flashtime = self.flashtime;
		flashtime = flashtime - elapsed;
		
		if ( flashtime <= 0 ) then
			local overtime = -flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

			local flashTexture = _G[self:GetName().."Flash"];
			if ( flashTexture:IsShown() ) then
				flashTexture:Hide();
			else
				flashTexture:Show();
			end
		end
		
		self.flashtime = flashtime;
	end
	
	-- Handle range indicator
	local rangeTimer = self.rangeTimer;
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed;

		if ( rangeTimer <= 0 ) then
			local count = _G[self:GetName().."HotKey"];
			local valid = IsActionInRange(self.action);
			if ( count:GetText() == RANGE_INDICATOR ) then
				if ( valid == 0 ) then
					count:Show();
					count:SetVertexColor(1.0, 0.1, 0.1);
				elseif ( valid == 1 ) then
					count:Show();
					count:SetVertexColor(0.6, 0.6, 0.6);
				else
					count:Hide();
				end
			else
				if ( valid == 0 ) then
					count:SetVertexColor(1.0, 0.1, 0.1);
				else
					count:SetVertexColor(0.6, 0.6, 0.6);
				end
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end
		
		self.rangeTimer = rangeTimer;
	end
end

function ActionButton_GetPagedID (self)
    return self.action;
end

function ActionButton_UpdateFlash (self)
	local action = self.action;
	if ( (IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action) ) then
		ActionButton_StartFlash(self);
	else
		ActionButton_StopFlash(self);
	end
end

function ActionButton_StartFlash (self)
	self.flashing = 1;
	self.flashtime = 0;
	ActionButton_UpdateState(self);
end

function ActionButton_StopFlash (self)
	self.flashing = 0;
	_G[self:GetName().."Flash"]:Hide();
	ActionButton_UpdateState (self);
end

function ActionButton_IsFlashing (self)
	if ( self.flashing == 1 ) then
		return 1;
	end
	
	return nil;
end
