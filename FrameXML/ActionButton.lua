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
	if ( BonusActionBarFrame:IsShown() ) then
		button = getglobal("BonusActionButton"..id);
	else
		button = getglobal("ActionButton"..id);
	end
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
end

function ActionButtonUp(id)
	local button;
	if ( BonusActionBarFrame:IsShown() ) then
		button = getglobal("BonusActionButton"..id);
	else
		button = getglobal("ActionButton"..id);
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

function ActionButton_OnLoad()
	this.flashing = 0;
	this.flashtime = 0;
	this:SetAttribute("showgrid", 0);
	this:SetAttribute("type", "action");
	this:SetAttribute("checkselfcast", true);
	this:SetAttribute("useparent-unit", true);
	this:SetAttribute("useparent-actionpage", true);
	this:RegisterForDrag("LeftButton", "RightButton");
	this:RegisterForClicks("AnyUp");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("ACTIONBAR_SHOWGRID");
	this:RegisterEvent("ACTIONBAR_HIDEGRID");
	this:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	this:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	this:RegisterEvent("UPDATE_BINDINGS");
	ActionButton_UpdateAction();
	ActionButton_UpdateHotkeys(this.buttonType);
end

function ActionButton_UpdateHotkeys(actionButtonType)
    if ( not actionButtonType ) then
        actionButtonType = "ACTIONBUTTON";
    end

    local hotkey = getglobal(this:GetName().."HotKey");
    local key = GetBindingKey(actionButtonType..this:GetID()) or
                GetBindingKey("CLICK "..this:GetName()..":LeftButton");

	local text = GetBindingText(key, "KEY_", 1);
    if ( text == "" ) then
        hotkey:SetText(RANGE_INDICATOR);
        hotkey:SetPoint("TOPLEFT", this, "TOPLEFT", 1, -2);
        hotkey:Hide();
    else
        hotkey:SetText(text);
        hotkey:SetPoint("TOPLEFT", this, "TOPLEFT", -2, -2);
        hotkey:Show();
    end
end

function ActionButton_CalculateAction(self, button)
	if ( not button ) then
		button = SecureButton_GetEffectiveButton(self);
	end
	if ( self:GetID() > 0 ) then
		local page = SecureButton_GetModifiedAttribute(self, "actionpage", button);
		if ( not page ) then
			page = GetActionBarPage();
			if ( self.isBonus and page == 1 ) then
				local offset = GetBonusBarOffset();
				if ( offset == 0 and BonusActionBarFrame and BonusActionBarFrame.lastBonusBar ) then
					offset = BonusActionBarFrame.lastBonusBar;
				end
				page = NUM_ACTIONBAR_PAGES + offset;
			end
		end
		return (self:GetID() + ((page - 1) * NUM_ACTIONBAR_BUTTONS));
	else
		return SecureButton_GetModifiedAttribute(self, "action", button) or 1;
	end
end

function ActionButton_UpdateAction()
	local action = ActionButton_CalculateAction(this);
	if ( action ~= this.action ) then
		this.action = action;
		ActionButton_Update();
	end
end

function ActionButton_Update()
	-- Special case code for bonus bar buttons
	-- Prevents the button from updating if the bonusbar is still in an animation transition
	if ( this.isBonus and this.inTransition ) then
		this.needsUpdate = true;
		ActionButton_UpdateUsable();
		return;
	end

	local action = this.action;
	local icon = getglobal(this:GetName().."Icon");
	local buttonCooldown = getglobal(this:GetName().."Cooldown");
	local texture = GetActionTexture(action);	
	
	if ( HasAction(action) ) then
		if ( not this.eventsRegistered ) then
			this:RegisterEvent("ACTIONBAR_UPDATE_STATE");
			this:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
			this:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
			this:RegisterEvent("PLAYER_AURAS_CHANGED");
			this:RegisterEvent("PLAYER_TARGET_CHANGED");
			this:RegisterEvent("CRAFT_SHOW");
			this:RegisterEvent("CRAFT_CLOSE");
			this:RegisterEvent("TRADE_SKILL_SHOW");
			this:RegisterEvent("TRADE_SKILL_CLOSE");
			this:RegisterEvent("PLAYER_ENTER_COMBAT");
			this:RegisterEvent("PLAYER_LEAVE_COMBAT");
			this:RegisterEvent("START_AUTOREPEAT_SPELL");
			this:RegisterEvent("STOP_AUTOREPEAT_SPELL");
			this.eventsRegistered = 1;
		end

		if ( not this:GetAttribute("statehidden") ) then
			this:Show();
		end
		ActionButton_UpdateState();
		ActionButton_UpdateUsable();
		ActionButton_UpdateCooldown();
		ActionButton_UpdateFlash();
	else
		if ( this.eventsRegistered ) then
			this:UnregisterEvent("ACTIONBAR_UPDATE_STATE");
			this:UnregisterEvent("ACTIONBAR_UPDATE_USABLE");
			this:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			this:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
			this:UnregisterEvent("PLAYER_AURAS_CHANGED");
			this:UnregisterEvent("PLAYER_TARGET_CHANGED");
			this:UnregisterEvent("CRAFT_SHOW");
			this:UnregisterEvent("CRAFT_CLOSE");
			this:UnregisterEvent("TRADE_SKILL_SHOW");
			this:UnregisterEvent("TRADE_SKILL_CLOSE");
			this:UnregisterEvent("PLAYER_ENTER_COMBAT");
			this:UnregisterEvent("PLAYER_LEAVE_COMBAT");
			this:UnregisterEvent("START_AUTOREPEAT_SPELL");
			this:UnregisterEvent("STOP_AUTOREPEAT_SPELL");
			this.eventsRegistered = nil;
		end

		if ( this:GetAttribute("showgrid") == 0 ) then
			this:Hide();
		else
			buttonCooldown:Hide();
		end
	end

	-- Add a green border if button is an equipped item
	local border = getglobal(this:GetName().."Border");
	if ( IsEquippedAction(action) ) then
		border:SetVertexColor(0, 1.0, 0, 0.35);
		border:Show();
	else
		border:Hide();
	end

	-- Update Macro Text
	local macroName = getglobal(this:GetName().."Name");
	if ( not IsConsumableAction(action) and not IsStackableAction(action) ) then
		macroName:SetText(GetActionText(action));
	else
		macroName:SetText("");
	end

	-- Update icon and hotkey text
	if ( texture ) then
		icon:SetTexture(texture);
		icon:Show();
		this.rangeTimer = -1;
		this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
	else
		icon:Hide();
		buttonCooldown:Hide();
		this.rangeTimer = nil;
		this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		local hotkey = getglobal(this:GetName().."HotKey");
        if ( hotkey:GetText() == RANGE_INDICATOR ) then
			hotkey:Hide();
		else
			hotkey:SetVertexColor(0.6, 0.6, 0.6);
		end
	end
	ActionButton_UpdateCount();	
	
	-- Update tooltip
	if ( GameTooltip:GetOwner() == this ) then
		ActionButton_SetTooltip(this);
	end

	this.feedback_action = action;
end

function ActionButton_ShowGrid(button)
	if ( not button ) then
		button = this;
	end
	
	if ( issecure() ) then
		button:SetAttribute("showgrid", button:GetAttribute("showgrid") + 1);
	end
	
	getglobal(button:GetName().."NormalTexture"):SetVertexColor(1.0, 1.0, 1.0, 0.5);

	if ( button:GetAttribute("showgrid") >= 1 and not button:GetAttribute("statehidden") ) then
		button:Show();
	end
end

function ActionButton_HideGrid(button)	
	if ( not button ) then
		button = this;
	end
	
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

function ActionButton_UpdateState(button)
	if ( not button ) then
		button = this;
	end
	local action = button.action;
	if ( IsCurrentAction(action) or IsAutoRepeatAction(action) ) then
		button:SetChecked(1);
	else
		button:SetChecked(0);
	end
end

function ActionButton_UpdateUsable()
	local icon = getglobal(this:GetName().."Icon");
	local normalTexture = getglobal(this:GetName().."NormalTexture");
	local isUsable, notEnoughMana = IsUsableAction(this.action);
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

function ActionButton_UpdateCount()
	local text = getglobal(this:GetName().."Count");
	local action = this.action;
	if ( IsConsumableAction(action) or IsStackableAction(action) ) then
		text:SetText(GetActionCount(action));
	else
		text:SetText("");
	end
end

function ActionButton_UpdateCooldown()
	local cooldown = getglobal(this:GetName().."Cooldown");
	local start, duration, enable = GetActionCooldown(this.action);
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
end

function ActionButton_OnEvent(event)
	if ( event == "ACTIONBAR_SLOT_CHANGED" ) then
		if ( arg1 == 0 or arg1 == this.action ) then
			ActionButton_Update();
		end
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		ActionButton_Update();
		return;
	end
	if ( event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_BONUS_ACTIONBAR" ) then
		ActionButton_UpdateAction();
		return;
	end
	if ( event == "ACTIONBAR_SHOWGRID" ) then
		ActionButton_ShowGrid();
		return;
	end
	if ( event == "ACTIONBAR_HIDEGRID" ) then
		ActionButton_HideGrid();
		return;
	end
	if ( event == "UPDATE_BINDINGS" ) then
		ActionButton_UpdateHotkeys(this.buttonType);
		return;
	end

	-- All event handlers below this line are only set when the button has an action

	if ( event == "PLAYER_TARGET_CHANGED" ) then
		this.rangeTimer = -1;
	elseif ( event == "ACTIONBAR_UPDATE_STATE" ) then
		ActionButton_UpdateState();
	elseif ( event == "ACTIONBAR_UPDATE_USABLE" ) then
		ActionButton_UpdateUsable();
	elseif ( event == "ACTIONBAR_UPDATE_COOLDOWN" ) then
		ActionButton_UpdateCooldown();
	elseif ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		ActionButton_UpdateState();
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		if ( IsAttackAction(this.action) ) then
			ActionButton_StartFlash();
		end
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		if ( IsAttackAction(this.action) ) then
			ActionButton_StopFlash();
		end
	elseif ( event == "START_AUTOREPEAT_SPELL" ) then
		if ( IsAutoRepeatAction(this.action) ) then
			ActionButton_StartFlash();
		end
	elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
		if ( ActionButton_IsFlashing() and not IsAttackAction(this.action) ) then
			ActionButton_StopFlash();
		end
	end
end

function ActionButton_SetTooltip(self)
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		if ( self:GetParent() == MultiBarBottomRight or self:GetParent() == MultiBarRight or self:GetParent() == MultiBarLeft ) then
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

function ActionButton_OnUpdate(elapsed)
	if ( ActionButton_IsFlashing() ) then
		this.flashtime = this.flashtime - elapsed;
		if ( this.flashtime <= 0 ) then
			local overtime = -this.flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			this.flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

			local flashTexture = getglobal(this:GetName().."Flash");
			if ( flashTexture:IsShown() ) then
				flashTexture:Hide();
			else
				flashTexture:Show();
			end
		end
	end
	
	-- Handle range indicator
	if ( this.rangeTimer ) then
		this.rangeTimer = this.rangeTimer - elapsed;

		if ( this.rangeTimer <= 0 ) then
			local count = getglobal(this:GetName().."HotKey");
			local valid = IsActionInRange(this.action);
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
			this.rangeTimer = TOOLTIP_UPDATE_TIME;
		end
	end
end

function ActionButton_GetPagedID(self)
    return self.action;
end

function ActionButton_UpdateFlash()
	local action = this.action;
	if ( (IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action) ) then
		ActionButton_StartFlash();
	else
		ActionButton_StopFlash();
	end
end

function ActionButton_StartFlash()
	this.flashing = 1;
	this.flashtime = 0;
	ActionButton_UpdateState();
end

function ActionButton_StopFlash()
	this.flashing = 0;
	getglobal(this:GetName().."Flash"):Hide();
	ActionButton_UpdateState();
end

function ActionButton_IsFlashing()
	if ( this.flashing == 1 ) then
		return 1;
	else
		return nil;
	end
end
