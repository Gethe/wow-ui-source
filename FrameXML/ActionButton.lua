CURRENT_ACTIONBAR_PAGE = 1;
NUM_ACTIONBAR_PAGES = 6;
NUM_ACTIONBAR_BUTTONS = 12;
ATTACK_BUTTON_FLASH_TIME = 0.4;

IN_ATTACK_MODE = nil;
IN_AUTOREPEAT_MODE = nil;

function ActionButtonDown(id)
	if ( BonusActionBarFrame:IsVisible() ) then
		local button = getglobal("BonusActionButton"..id);
		if ( button:GetButtonState() == "NORMAL" ) then
			button:SetButtonState("PUSHED");
		end
		return;
	end
	
	local button = getglobal("ActionButton"..id);
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
end

function ActionButtonUp(id, onSelf)
	if ( BonusActionBarFrame:IsVisible() ) then
		local button = getglobal("BonusActionButton"..id);
		if ( button:GetButtonState() == "PUSHED" ) then
			button:SetButtonState("NORMAL");
			-- Used to save a macro
			MacroFrame_EditMacro();
			UseAction(ActionButton_GetPagedID(button), 0);
			if ( IsCurrentAction(ActionButton_GetPagedID(button)) ) then
				button:SetChecked(1);
			else
				button:SetChecked(0);
			end
		end
		return;
	end

	local button = getglobal("ActionButton"..id);
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		-- Used to save a macro
		MacroFrame_EditMacro();
		UseAction(ActionButton_GetPagedID(button), 0, onSelf);
		if ( IsCurrentAction(ActionButton_GetPagedID(button)) ) then
			button:SetChecked(1);
		else
			button:SetChecked(0);
		end
	end
end

function ActionBar_PageUp()
	CURRENT_ACTIONBAR_PAGE = CURRENT_ACTIONBAR_PAGE + 1;
	if ( CURRENT_ACTIONBAR_PAGE > NUM_ACTIONBAR_PAGES ) then
		CURRENT_ACTIONBAR_PAGE = 1;
	end
	ChangeActionBarPage();
end

function ActionBar_PageDown()
	CURRENT_ACTIONBAR_PAGE = CURRENT_ACTIONBAR_PAGE - 1;
	if ( CURRENT_ACTIONBAR_PAGE < 1 ) then
		CURRENT_ACTIONBAR_PAGE = NUM_ACTIONBAR_PAGES;
	end
	ChangeActionBarPage();
end

function ActionButton_OnLoad()
	this.showgrid = 0;
	this.flashing = 0;
	this.flashtime = 0;
	ActionButton_Update();
	this:RegisterForDrag("LeftButton", "RightButton");
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	this:RegisterEvent("ACTIONBAR_SHOWGRID");
	this:RegisterEvent("ACTIONBAR_HIDEGRID");
	this:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	this:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	this:RegisterEvent("ACTIONBAR_UPDATE_STATE");
	this:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
	this:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
	this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
	this:RegisterEvent("PLAYER_AURAS_CHANGED");
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("UNIT_AURASTATE");
	this:RegisterEvent("UNIT_INVENTORY_CHANGED");
	this:RegisterEvent("CRAFT_SHOW");
	this:RegisterEvent("CRAFT_CLOSE");
	this:RegisterEvent("TRADE_SKILL_SHOW");
	this:RegisterEvent("TRADE_SKILL_CLOSE");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_RAGE");
	this:RegisterEvent("UNIT_FOCUS");
	this:RegisterEvent("UNIT_ENERGY");
	this:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	this:RegisterEvent("PLAYER_ENTER_COMBAT");
	this:RegisterEvent("PLAYER_LEAVE_COMBAT");
	this:RegisterEvent("PLAYER_COMBO_POINTS");
	this:RegisterEvent("UPDATE_BINDINGS");
	this:RegisterEvent("START_AUTOREPEAT_SPELL");
	this:RegisterEvent("STOP_AUTOREPEAT_SPELL");
	ActionButton_UpdateHotkeys();
end

function ActionButton_UpdateHotkeys(actionButtonType)
	if ( not actionButtonType ) then
		actionButtonType = "ACTIONBUTTON";
	end
	local hotkey = getglobal(this:GetName().."HotKey");
	local action = actionButtonType..this:GetID();
	hotkey:SetText(KeyBindingFrame_GetLocalizedName(GetBindingKey(action), "KEY_"));
end

function ActionButton_Update()
	-- Determine whether or not the button should be flashing or not since the button may have missed the enter combat event
	local pagedID = ActionButton_GetPagedID(this);
	if ( IsAttackAction(pagedID) and IsCurrentAction(pagedID) ) then
		IN_ATTACK_MODE = 1;
	else
		IN_ATTACK_MODE = nil;
	end
	IN_AUTOREPEAT_MODE = IsAutoRepeatAction(pagedID);
	
	-- Special case code for bonus bar buttons
	-- Prevents the button from updating if the bonusbar is still in an animation transition

	-- Derek, I had to comment this out because it was causing them all to be grayed out after a cinematic...
	if ( this.isBonus and this.inTransition ) then
		ActionButton_UpdateUsable();
		ActionButton_UpdateCooldown();
		return;
	end
	
	local icon = getglobal(this:GetName().."Icon");
	local buttonCooldown = getglobal(this:GetName().."Cooldown");
	local texture = GetActionTexture(ActionButton_GetPagedID(this));
	if ( texture ) then
		icon:SetTexture(texture);
		icon:Show();
		this.rangeTimer = TOOLTIP_UPDATE_TIME;
		this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
		-- Save texture if the button is a bonus button, will be needed later
		if ( this.isBonus ) then
			this.texture = texture;
		end
		
	else
		icon:Hide();
		buttonCooldown:Hide();
		this.rangeTimer = nil;
		this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		getglobal(this:GetName().."HotKey"):SetVertexColor(0.6, 0.6, 0.6);
	end
	ActionButton_UpdateCount();
	if ( HasAction(ActionButton_GetPagedID(this)) ) then
		this:Show();
		ActionButton_UpdateUsable();
		ActionButton_UpdateCooldown();
	elseif ( this.showgrid == 0 ) then
		this:Hide();
	else
		getglobal(this:GetName().."Cooldown"):Hide();
	end
	if ( IN_ATTACK_MODE or IN_AUTOREPEAT_MODE ) then
		ActionButton_StartFlash();
	else
		ActionButton_StopFlash();
	end
	if ( GameTooltip:IsOwned(this) ) then
		ActionButton_SetTooltip();
	else
		this.updateTooltip = nil;
	end

	-- Update Macro Text
	local macroName = getglobal(this:GetName().."Name");
	macroName:SetText(GetActionText(ActionButton_GetPagedID(this)));
end

function ActionButton_ShowGrid()
	this.showgrid = this.showgrid+1;
	getglobal(this:GetName().."NormalTexture"):SetVertexColor(1.0, 1.0, 1.0);
	this:Show();
end

function ActionButton_HideGrid()	
	this.showgrid = this.showgrid-1;
	if ( this.showgrid == 0 and not HasAction(ActionButton_GetPagedID(this)) ) then
		this:Hide();
	end
end

function ActionButton_UpdateState()
	if ( IsCurrentAction(ActionButton_GetPagedID(this)) or IsAutoRepeatAction(ActionButton_GetPagedID(this)) ) then
		this:SetChecked(1);
	else
		this:SetChecked(0);
	end
end

function ActionButton_UpdateUsable()
	local icon = getglobal(this:GetName().."Icon");
	local normalTexture = getglobal(this:GetName().."NormalTexture");
	local isUsable, notEnoughMana = IsUsableAction(ActionButton_GetPagedID(this));
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
	local count = GetActionCount(ActionButton_GetPagedID(this));
	if ( count > 1 ) then
		text:SetText(count);
	else
		text:SetText("");
	end
end

function ActionButton_UpdateCooldown()
	local cooldown = getglobal(this:GetName().."Cooldown");
	local start, duration, enable = GetActionCooldown(ActionButton_GetPagedID(this));
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
end

function ActionButton_OnEvent(event)
	if ( event == "ACTIONBAR_SLOT_CHANGED" ) then
		if ( arg1 == -1 or arg1 == ActionButton_GetPagedID(this) ) then
			ActionButton_Update();
		end
		return;
	end
	if ( event == "ACTIONBAR_PAGE_CHANGED" or event == "PLAYER_AURAS_CHANGED" or event == "UPDATE_BONUS_ACTIONBAR" ) then
		ActionButton_Update();
		ActionButton_UpdateState();
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
		ActionButton_UpdateHotkeys();
	end

	-- All event handlers below this line MUST only be valid when the button is visible
	if ( not this:IsVisible() ) then
		return;
	end

	if ( event == "PLAYER_TARGET_CHANGED" ) then
		ActionButton_UpdateUsable();
		return;
	end
	if ( event == "UNIT_AURASTATE" ) then
		if ( arg1 == "player" or arg1 == "target" ) then
			ActionButton_UpdateUsable();
		end
		return;
	end
	if ( event == "UNIT_INVENTORY_CHANGED" ) then
		if ( arg1 == "player" ) then
			ActionButton_Update();
		end
		return;
	end
	if ( event == "ACTIONBAR_UPDATE_STATE" ) then
		ActionButton_UpdateState();
		return;
	end
	if ( event == "ACTIONBAR_UPDATE_USABLE" or event == "UPDATE_INVENTORY_ALERTS" or event == "ACTIONBAR_UPDATE_COOLDOWN" ) then
		ActionButton_UpdateUsable();
		ActionButton_UpdateCooldown();
		return;
	end
	if ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		ActionButton_UpdateState();
		return;
	end
	if ( arg1 == "player" and (event == "UNIT_HEALTH" or event == "UNIT_MANA" or event == "UNIT_RAGE" or event == "UNIT_FOCUS" or event == "UNIT_ENERGY") ) then
		ActionButton_UpdateUsable();
		return;
	end
	if ( event == "PLAYER_ENTER_COMBAT" ) then
		IN_ATTACK_MODE = 1;
		if ( IsAttackAction(ActionButton_GetPagedID(this)) ) then
			ActionButton_StartFlash();
		end
		return;
	end
	if ( event == "PLAYER_LEAVE_COMBAT" ) then
		IN_ATTACK_MODE = nil;
		if ( IsAttackAction(ActionButton_GetPagedID(this)) ) then
			ActionButton_StopFlash();
		end
		return;
	end
	if ( event == "PLAYER_COMBO_POINTS" ) then
		ActionButton_UpdateUsable();
		return;
	end
	if ( event == "START_AUTOREPEAT_SPELL" ) then
		IN_AUTOREPEAT_MODE = 1;
		if ( IsAutoRepeatAction(ActionButton_GetPagedID(this)) ) then
			ActionButton_StartFlash();
		end
		return;
	end
	if ( event == "STOP_AUTOREPEAT_SPELL" ) then
		IN_AUTOREPEAT_MODE = nil;
		if ( ActionButton_IsFlashing() and not IsAttackAction(ActionButton_GetPagedID(this)) ) then
			ActionButton_StopFlash();
		end
		return;
	end
end

function ActionButton_SetTooltip()
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, this);
	else
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	end
	
	if ( GameTooltip:SetAction(ActionButton_GetPagedID(this)) ) then
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		this.updateTooltip = nil;
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
			if ( flashTexture:IsVisible() ) then
				flashTexture:Hide();
			else
				flashTexture:Show();
			end
		end
	end
	
	-- Handle range indicator
	if ( this.rangeTimer ) then
		if ( this.rangeTimer < 0 ) then
			local count = getglobal(this:GetName().."HotKey");
			if ( IsActionInRange( ActionButton_GetPagedID(this)) == 0 ) then
				count:SetVertexColor(1.0, 0.1, 0.1);
			else
				count:SetVertexColor(0.6, 0.6, 0.6);
			end
			this.rangeTimer = TOOLTIP_UPDATE_TIME;
		else
			this.rangeTimer = this.rangeTimer - elapsed;
		end
	end

	if ( not this.updateTooltip ) then
		return;
	end

	this.updateTooltip = this.updateTooltip - elapsed;
	if ( this.updateTooltip > 0 ) then
		return;
	end

	if ( GameTooltip:IsOwned(this) ) then
		ActionButton_SetTooltip();
	else
		this.updateTooltip = nil;
	end
end

function ActionButton_GetPagedID(button)
	if( button == nil ) then
		message("nil button passed into ActionButton_GetPagedID(), contact Jeff");
		return 0;
	end
	if ( button.isBonus and CURRENT_ACTIONBAR_PAGE == 1 ) then
		local offset = GetBonusBarOffset();
		if ( offset == 0 and BonusActionBarFrame and BonusActionBarFrame.lastBonusBar ) then
			offset = BonusActionBarFrame.lastBonusBar;
		end
		return (button:GetID() + ((NUM_ACTIONBAR_PAGES + offset - 1) * NUM_ACTIONBAR_BUTTONS));
	else
		return (button:GetID() + ((CURRENT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
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
