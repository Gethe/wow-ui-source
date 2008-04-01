
BUFF_FLASH_TIME_ON = 0.75;
BUFF_FLASH_TIME_OFF = 0.75;
BUFF_MIN_ALPHA = 0.3;
BUFF_WARNING_TIME = 31;

function BuffFrame_OnLoad()
	BuffFrameUpdateTime = 0;
	BuffFrameFlashTime = 0;
	BuffFrameFlashState = 1;
end

function BuffFrame_OnUpdate(elapsed)
	if ( BuffFrameUpdateTime > 0 ) then
		BuffFrameUpdateTime = BuffFrameUpdateTime - elapsed;
	else
		BuffFrameUpdateTime = BuffFrameUpdateTime + TOOLTIP_UPDATE_TIME;
	end

	BuffFrameFlashTime = BuffFrameFlashTime - elapsed;
	if ( BuffFrameFlashTime < 0 ) then
		local overtime = -BuffFrameFlashTime;
		if ( BuffFrameFlashState == 0 ) then
			BuffFrameFlashState = 1;
			BuffFrameFlashTime = BUFF_FLASH_TIME_ON;
		else
			BuffFrameFlashState = 0;
			BuffFrameFlashTime = BUFF_FLASH_TIME_OFF;
		end
		if ( overtime < BuffFrameFlashTime ) then
			BuffFrameFlashTime = BuffFrameFlashTime - overtime;
		end
	end
end

function BuffButton_Update()
	local buffIndex, untilCancelled = GetPlayerBuff(this:GetID(), this.buffFilter);
	this.buffIndex = buffIndex;
	this.untilCancelled = untilCancelled;

	if ( buffIndex < 0 ) then
		this:Hide();
		return;
	else
		this:SetAlpha(1.0);
		this:Show();
	end

	local icon = getglobal(this:GetName().."Icon");
	icon:SetTexture(GetPlayerBuffTexture(buffIndex));

	if ( GameTooltip:IsOwned(this) ) then
		GameTooltip:SetPlayerBuff(buffIndex);
	end
end

function BuffButton_OnLoad()
	-- Valid tokens for "buffFilter" include: HELPFUL, HARMFUL, PASSIVE, CANCELABLE, NOT_CANCELABLE
	BuffButton_Update();
	this:RegisterForClicks("RightButtonUp");
	this:RegisterEvent("PLAYER_AURAS_CHANGED");
end

function BuffButton_OnEvent(event)
	BuffButton_Update();
end

function BuffButton_OnUpdate()
	if ( this.untilCancelled == 1 ) then
		return;
	end

	local buffIndex = this.buffIndex;
	local timeLeft = GetPlayerBuffTimeLeft(buffIndex);
	local buffAlphaValue;
	if ( timeLeft < BUFF_WARNING_TIME ) then
		if ( BuffFrameFlashState == 1 ) then
			buffAlphaValue = (BUFF_FLASH_TIME_ON - BuffFrameFlashTime) / BUFF_FLASH_TIME_ON;
			buffAlphaValue = buffAlphaValue * (1 - BUFF_MIN_ALPHA) + BUFF_MIN_ALPHA;
		else
			buffAlphaValue = BuffFrameFlashTime / BUFF_FLASH_TIME_ON;
			buffAlphaValue = (buffAlphaValue * (1 - BUFF_MIN_ALPHA)) + BUFF_MIN_ALPHA;
			this:SetAlpha(BuffFrameFlashTime / BUFF_FLASH_TIME_ON);
		end
		this:SetAlpha(buffAlphaValue);
	end

	if ( BuffFrameUpdateTime > 0 ) then
		return;
	end
	if ( GameTooltip:IsOwned(this) ) then
		GameTooltip:SetPlayerBuff(buffIndex);
	end
end

function BuffButton_OnClick()
	CancelPlayerBuff(this.buffIndex);
end
