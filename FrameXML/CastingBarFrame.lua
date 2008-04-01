CASTING_BAR_ALPHA_STEP = 0.05;
CASTING_BAR_FLASH_STEP = 0.2;
CASTING_BAR_HOLD_TIME = 1;

function CastingBarFrame_OnLoad()
	this:RegisterEvent("SPELLCAST_START");
	this:RegisterEvent("SPELLCAST_STOP");
	this:RegisterEvent("SPELLCAST_FAILED");
	this:RegisterEvent("SPELLCAST_INTERRUPTED");
	this:RegisterEvent("SPELLCAST_DELAYED");
	this:RegisterEvent("SPELLCAST_CHANNEL_START");
	this:RegisterEvent("SPELLCAST_CHANNEL_UPDATE");
	this.casting = nil;
	this.holdTime = 0;
end

function CastingBarFrame_OnEvent()
	if ( event == "SPELLCAST_START" ) then
		CastingBarFrameStatusBar:SetStatusBarColor(1.0, 0.7, 0.0);
		CastingBarSpark:Show();
		this.startTime = GetTime();
		this.maxValue = this.startTime + (arg2 / 1000);
		CastingBarFrameStatusBar:SetMinMaxValues(this.startTime, this.maxValue);
		CastingBarFrameStatusBar:SetValue(this.startTime);
		CastingBarText:SetText(arg1);
		this:SetAlpha(1.0);
		this.holdTime = 0;
		this.casting = 1;
		this.fadeOut = nil;
		this:Show();

		this.mode = "casting";
	elseif ( event == "SPELLCAST_STOP" ) then
		if ( not this:IsVisible() ) then
			this:Hide();
		end
		if ( this:IsShown() ) then
			CastingBarFrameStatusBar:SetValue(this.maxValue);
			CastingBarFrameStatusBar:SetStatusBarColor(0.0, 1.0, 0.0);
			CastingBarSpark:Hide();
			CastingBarFlash:SetAlpha(0.0);
			CastingBarFlash:Show();
			this.casting = nil;
			this.flash = 1;
			this.fadeOut = 1;

			this.mode = "flash";
		end
	elseif ( event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" ) then
		if ( this:IsShown() ) then
			CastingBarFrameStatusBar:SetValue(this.maxValue);
			CastingBarFrameStatusBar:SetStatusBarColor(1.0, 0.0, 0.0);
			CastingBarSpark:Hide();
			if ( event == "SPELLCAST_FAILED" ) then
				CastingBarText:SetText(FAILED);
			else
				CastingBarText:SetText(INTERRUPTED);
			end
			this.casting = nil;
			this.fadeOut = 1;
			this.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
		end
	elseif ( event == "SPELLCAST_DELAYED" ) then
		if( this:IsShown() ) then
			this.startTime = this.startTime + (arg1 / 1000);
			this.maxValue = this.maxValue + (arg1 / 1000);
			CastingBarFrameStatusBar:SetMinMaxValues(this.startTime, this.maxValue);
		end
	elseif ( event == "SPELLCAST_CHANNEL_START" ) then
		CastingBarFrameStatusBar:SetStatusBarColor(1.0, 0.7, 0.0);
		CastingBarSpark:Show();
		this.maxValue = 1;
		this.startTime = GetTime();
		this.endTime = this.startTime + (arg1 / 1000);
		this.duration = arg1 / 1000;
		CastingBarFrameStatusBar:SetMinMaxValues(this.startTime, this.endTime);
		CastingBarFrameStatusBar:SetValue(this.endTime);
		CastingBarText:SetText(arg2);
		this:SetAlpha(1.0);
		this.holdTime = 0;
		this.casting = nil;
		this.channeling = 1;
		this.fadeOut = nil;
		this:Show();
	elseif ( event == "SPELLCAST_CHANNEL_UPDATE" ) then
		if ( arg1 == 0 ) then
			this.channeling = nil;
		elseif ( this:IsShown() ) then
			local origDuration = this.endTime - this.startTime
			this.endTime = GetTime() + (arg1 / 1000)
			this.startTime = this.endTime - origDuration
			--this.endTime = this.startTime + (arg1 / 1000);
			CastingBarFrameStatusBar:SetMinMaxValues(this.startTime, this.endTime);
		end
	end
end

function CastingBarFrame_OnUpdate()
	if ( this.casting ) then
		local status = GetTime();
		if ( status > this.maxValue ) then
			status = this.maxValue
		end
		CastingBarFrameStatusBar:SetValue(status);
		CastingBarFlash:Hide();
		local sparkPosition = ((status - this.startTime) / (this.maxValue - this.startTime)) * 195;
		if ( sparkPosition < 0 ) then
			sparkPosition = 0;
		end
		CastingBarSpark:SetPoint("CENTER", "CastingBarFrameStatusBar", "LEFT", sparkPosition, 0);
	elseif ( this.channeling ) then
		local time = GetTime();
		if ( time > this.endTime ) then
			time = this.endTime
		end
		if ( time == this.endTime ) then
			this.channeling = nil;
			this.fadeOut = 1;
			return;
		end
		local barValue = this.startTime + (this.endTime - time);
		CastingBarFrameStatusBar:SetValue( barValue );
		CastingBarFlash:Hide();
		local sparkPosition = ((barValue - this.startTime) / (this.endTime - this.startTime)) * 195;
		CastingBarSpark:SetPoint("CENTER", "CastingBarFrameStatusBar", "LEFT", sparkPosition, 0);
	elseif ( GetTime() < this.holdTime ) then
		return;
	elseif ( this.flash ) then
		local alpha = CastingBarFlash:GetAlpha() + CASTING_BAR_FLASH_STEP;
		if ( alpha < 1 ) then
			CastingBarFlash:SetAlpha(alpha);
		else
			this.flash = nil;
		end
	elseif ( this.fadeOut ) then
		local alpha = this:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if ( alpha > 0 ) then
			this:SetAlpha(alpha);
		else
			this.fadeOut = nil;
			this:Hide();
		end
	end
end
