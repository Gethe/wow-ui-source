
ATTACK_BUTTON_FLASH_TIME = 0.4;

function AttackButton_OnLoad()
	this.flashing = 0;
	this:RegisterEvent("PLAYER_ENTER_COMBAT");
	this:RegisterEvent("PLAYER_LEAVE_COMBAT");
end

function AttackButton_StartFlash()
	this.flashing = 1;
	this.flashtime = 0;
	ActionButton_UpdateState();
end

function AttackButton_StopFlash()
	this.flashing = 0;
	AttackButtonFlash:Hide();
	ActionButton_UpdateState();
end

function AttackButton_OnEvent(event)
	if ( event == "PLAYER_ENTER_COMBAT" ) then
		AttackButton_StartFlash();
		return;
	end
	if ( event == "PLAYER_LEAVE_COMBAT" ) then
		AttackButton_StopFlash();
		return;
	end
end

function AttackButton_OnUpdate(elapsed)
	if ( this.flashing == 0 ) then
		return;
	end

	this.flashtime = this.flashtime - elapsed;
	if ( this.flashtime > 0 ) then
		return;
	end
	local overtime = -this.flashtime;
	if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
		overtime = 0;
	end
	this.flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

	if ( AttackButtonFlash:IsVisible() ) then
		AttackButtonFlash:Hide();
	else
		AttackButtonFlash:Show();
	end
end
