-- can't scale text with animations, use raid warning scaling
local abilityNameTimings = {
	["RAID_NOTICE_MIN_HEIGHT"] = 22.0,
	["RAID_NOTICE_MAX_HEIGHT"] = 32.0,
	["RAID_NOTICE_SCALE_UP_TIME"] = 0.1,
	["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.2,
}
local timeLeftTimings = {
	["RAID_NOTICE_MIN_HEIGHT"] = 20.0,
	["RAID_NOTICE_MAX_HEIGHT"] = 28.0,
	["RAID_NOTICE_SCALE_UP_TIME"] = 0.1,
	["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.2,
}

local TIME_LEFT_FRAME_WIDTH = 200;
LOSS_OF_CONTROL_TIME_OFFSET = 6;

function LossOfControlFrame_OnLoad(self)
	self:RegisterEvent("LOSS_OF_CONTROL_UPDATE");
	self:RegisterEvent("LOSS_OF_CONTROL_ADDED");
	-- figure out some string widths - our base width is for under 10 seconds which should be almost all loss of control durations
	self.TimeLeft.baseNumberWidth = self.TimeLeft.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
	self.TimeLeft.secondsWidth = self.TimeLeft.SecondsText:GetStringWidth();
end
;
function LossOfControlFrame_OnEvent(self, event, ...)
	if ( event == "LOSS_OF_CONTROL_UPDATE" ) then
		LossOfControlFrame_UpdateDisplay(self, false);
	elseif ( event == "LOSS_OF_CONTROL_ADDED" ) then
		local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, schoolMask, isActive = ...;
		LossOfControlFrame_UpdateDisplay(self, isActive);
	end
end

function LossOfControlFrame_OnUpdate(self, elapsed)
	RaidNotice_UpdateSlot(self.AbilityName, abilityNameTimings, elapsed);
	RaidNotice_UpdateSlot(self.TimeLeft.NumberText, timeLeftTimings, elapsed);
	RaidNotice_UpdateSlot(self.TimeLeft.SecondsText, timeLeftTimings, elapsed);

	-- Hack for Root and Interrupt display fading out
	if(self.FadeTime) then
		self.FadeTime = self.FadeTime - elapsed;
		self:SetAlpha(max(self.FadeTime*2, 0.0));
		if(self.FadeTime < 0) then
			self:Hide();
			self.FadeTime = nil;
		end
	else
		self:SetAlpha(1.0);
	end
	
	LossOfControlFrame_UpdateDisplay(self, false);
end

function LossOfControlFrame_UpdateDisplay(self, animate)

	local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool = GetActiveLossOfControlInfo();
	
	-- Only full LoC should stay up
	if ( locType == "POSSESS" or locType == "CONFUSE" or locType == "CHARM" or locType == "FEAR" or locType == "STUN" ) then
		self.FadeTime = nil;
	else
		if(animate) then
			self.FadeTime = 1.5;
			timeRemaining = duration;  -- hack so that the full duration appears in the toast
		else
			if(self.FadeTime == nil) then
				self:Hide();
			end
			return;
		end
	end
		
	if ( text ) then
		-- ability name
		if (locType == "SCHOOL_INTERRUPT") then
			-- Replace text with school-specific lockout text
			if(lockoutSchool and lockoutSchool ~= 0 and SchoolStringTable[lockoutSchool]) then
				text = string.format(LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL, SchoolStringTable[lockoutSchool]);
			end
		end
		self.AbilityName:SetText(text);
		-- time remaining
		local timeLeftFrame = self.TimeLeft;
		if(timeRemaining) then
			if ( timeRemaining >= 10 ) then
				timeLeftFrame.NumberText:SetFormattedText("%d", timeRemaining);
			else
				timeLeftFrame.NumberText:SetFormattedText("%.1f", timeRemaining);
			end
			timeLeftFrame:Show();
			LossOfControlTimeLeftFrame_SetNumberWidth(timeLeftFrame, timeRemaining);
		else
			timeLeftFrame:Hide();
			startTime = 0;
			duration = 0;
		end
		-- icon
		self.Icon:SetTexture(iconTexture);
		self.Cooldown:SetLossOfControlCooldown(startTime, duration);		
		-- position strings and icon if it's a new string
		if ( self.currentText ~= text or self.startTime ~= startTime ) then
			self.currentText = text;
			self.startTime = startTime;
			local abilityWidth = self.AbilityName:GetWidth();
			local longestTextWidth = max(abilityWidth, (timeLeftFrame.numberWidth + timeLeftFrame.secondsWidth));
			local xOffset = (abilityWidth - longestTextWidth) / 2 + 27;
			self.AbilityName:SetPoint("CENTER", xOffset, 11);
			self.Icon:SetPoint("CENTER", -((6 + longestTextWidth) / 2), 0);
			-- left-align the TimeLeft frame with the ability name using a center anchor (will need center for "animating" via frame scaling - NYI)
			xOffset = xOffset + (TIME_LEFT_FRAME_WIDTH - abilityWidth) / 2;
			timeLeftFrame:SetPoint("CENTER", xOffset, -12);
		end
		if(animate) then
			self.Anim:Stop();
			self.AbilityName.scrollTime = 0;
			self.TimeLeft.NumberText.scrollTime = 0;
			self.TimeLeft.SecondsText.scrollTime = 0;
			self.Anim:Play();
		end
		self:Show();
	else
		self.currentText = nil;
		self.startTime = nil;
		self:Hide();
	end
end

local floor = math.floor;
function LossOfControlTimeLeftFrame_SetNumberWidth(self, timeLeft)
	local tens = floor(timeLeft / 10);
	if ( tens ~= self.numberTens ) then
		-- resize
		if ( tens == 0 ) then
			self.numberWidth = self.baseNumberWidth;
			self.numberTens = 0;
		else
			self.NumberText:SetWidth(0);
			self.numberWidth = self.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
			self.numberTens = tens;
		end
		self.NumberText:SetWidth(self.numberWidth);
	end
end
