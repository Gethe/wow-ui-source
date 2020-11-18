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

local TEXT_OVERRIDE = {
	[33786] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
	[113506] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
	[209753] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
}

local TIME_LEFT_FRAME_WIDTH = 200;
LOSS_OF_CONTROL_TIME_OFFSET = 6;

local DISPLAY_TYPE_FULL = 2;
local DISPLAY_TYPE_ALERT = 1;
local DISPLAY_TYPE_NONE = 0;

LOSS_OF_CONTROL_ACTIVE_INDEX = 1;

function LossOfControlFrame_OnLoad(self)
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	-- figure out some string widths - our base width is for under 10 seconds which should be almost all loss of control durations
	self.TimeLeft.baseNumberWidth = self.TimeLeft.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
	self.TimeLeft.secondsWidth = self.TimeLeft.SecondsText:GetStringWidth();
end

function LossOfControlFrame_OnEvent(self, event, ...)
	if ( event == "LOSS_OF_CONTROL_UPDATE" ) then
		LossOfControlFrame_UpdateDisplay(self, false);
	elseif ( event == "LOSS_OF_CONTROL_ADDED" ) then
		local eventIndex = ...;
		local data = C_LossOfControl.GetActiveLossOfControlData(eventIndex);
		local timeRemaining = data.timeRemaining;
		local priority = data.priority;
		if ( data.displayType == DISPLAY_TYPE_ALERT ) then
			-- only display an alert type if there's nothing up or it has higher priority. If same priority, it needs to have longer time remaining
			if ( not self:IsShown() or priority > self.priority or ( priority == self.priority and timeRemaining and ( not self.TimeLeft.timeRemaining or timeRemaining > self.TimeLeft.timeRemaining ) ) ) then
				LossOfControlFrame_SetUpDisplay(self, true, data);
			end
			return;
		end
		if ( eventIndex == LOSS_OF_CONTROL_ACTIVE_INDEX ) then
			self.fadeTime = nil;
			LossOfControlFrame_SetUpDisplay(self, true);
		end
	elseif ( event == "CVAR_UPDATE" ) then
		local cvar, value = ...;
		if ( cvar == "LOSS_OF_CONTROL" ) then
			if ( value == "1" ) then
				self:RegisterEvent("LOSS_OF_CONTROL_UPDATE");
				self:RegisterEvent("LOSS_OF_CONTROL_ADDED");
			else
				self:UnregisterEvent("LOSS_OF_CONTROL_UPDATE");
				self:UnregisterEvent("LOSS_OF_CONTROL_ADDED");
				self:Hide();
			end
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		if ( GetCVarBool("lossOfControl" ) ) then
			self:RegisterEvent("LOSS_OF_CONTROL_UPDATE");
			self:RegisterEvent("LOSS_OF_CONTROL_ADDED");
		end
	end
end

function LossOfControlFrame_OnUpdate(self, elapsed)
	RaidNotice_UpdateSlot(self.AbilityName, abilityNameTimings, elapsed);
	RaidNotice_UpdateSlot(self.TimeLeft.NumberText, timeLeftTimings, elapsed);
	RaidNotice_UpdateSlot(self.TimeLeft.SecondsText, timeLeftTimings, elapsed);

	-- handle alert type
	if(self.fadeTime) then
		self.fadeTime = self.fadeTime - elapsed;
		self:SetAlpha(max(self.fadeTime*2, 0.0));
		if(self.fadeTime < 0) then
			self:Hide();
		else
			-- no need to do any other work
			return;
		end
	else
		self:SetAlpha(1.0);
	end
	LossOfControlFrame_UpdateDisplay(self);	
end

function LossOfControlFrame_OnHide(self)
	self.fadeTime = nil;
	self.priority = nil;
end

function LossOfControlFrame_SetUpDisplay(self, animate, data)
	if ( not data ) then
		data = C_LossOfControl.GetActiveLossOfControlData(LOSS_OF_CONTROL_ACTIVE_INDEX);
	end
	
	local locType = data.locType;
	local spellID = data.spellID;
	local text = data.displayText;
	local iconTexture = data.iconTexture;
	local startTime = data.startTime;
	local timeRemaining = data.timeRemaining;
	local duration = data.duration;
	local lockoutSchool = data.lockoutSchool;
	local priority = data.priority;
	local displayType = data.displayType;

	if ( text and displayType ~= DISPLAY_TYPE_NONE ) then
		-- ability name
		text = TEXT_OVERRIDE[spellID] or text;
		if ( locType == "SCHOOL_INTERRUPT" ) then
			-- Replace text with school-specific lockout text
			if(lockoutSchool and lockoutSchool ~= 0) then
				text = string.format(LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL, GetSchoolString(lockoutSchool));
			end
		end
		self.AbilityName:SetText(text);
		-- icon
		self.Icon:SetTexture(iconTexture);
		-- time
		local timeLeftFrame = self.TimeLeft;
		if ( displayType == DISPLAY_TYPE_ALERT ) then
			timeRemaining = duration;
			CooldownFrame_Clear(self.Cooldown);
		elseif ( not startTime ) then
			CooldownFrame_Clear(self.Cooldown);
		else
			CooldownFrame_Set(self.Cooldown, startTime, duration, true);
		end
		LossOfControlTimeLeftFrame_SetTime(timeLeftFrame, timeRemaining);
		-- align stuff
		local abilityWidth = self.AbilityName:GetWidth();
		local longestTextWidth = max(abilityWidth, (timeLeftFrame.numberWidth + timeLeftFrame.secondsWidth));
		local xOffset = (abilityWidth - longestTextWidth) / 2 + 27;
		self.AbilityName:SetPoint("CENTER", xOffset, 11);
		self.Icon:SetPoint("CENTER", -((6 + longestTextWidth) / 2), 0);
		-- left-align the TimeLeft frame with the ability name using a center anchor (will need center for "animating" via frame scaling - NYI)
		xOffset = xOffset + (TIME_LEFT_FRAME_WIDTH - abilityWidth) / 2;
		timeLeftFrame:SetPoint("CENTER", xOffset, -12);
		-- show
		if ( animate ) then
			if ( displayType == DISPLAY_TYPE_ALERT ) then
				self.fadeTime = 1.5;
			end
			self.Anim:Stop();
			self.AbilityName.scrollTime = 0;
			self.TimeLeft.NumberText.scrollTime = 0;
			self.TimeLeft.SecondsText.scrollTime = 0;
			self.Cooldown:Hide();
			self.Anim:Play();
			PlaySound(SOUNDKIT.UI_LOSS_OF_CONTROL_START);
		end
		self.priority = priority;
		self.spellID = spellID;
		self.startTime = startTime;
		self:Show();
	end
end

function LossOfControlFrame_UpdateDisplay(self)
	-- if displaying an alert, wait for it to go away on its own
	if ( self.fadeTime ) then
		return;
	end

	local data = C_LossOfControl.GetActiveLossOfControlData(LOSS_OF_CONTROL_ACTIVE_INDEX);
	if ( data and data.displayText and data.displayType == DISPLAY_TYPE_FULL ) then
		if ( data.spellID ~= self.spellID or data.startTime ~= self.startTime ) then
			LossOfControlFrame_SetUpDisplay(self, false, data);
		end
		if ( not self.Anim:IsPlaying() and data.startTime ) then
			CooldownFrame_Set(self.Cooldown, data.startTime, data.duration, true, true);
		end
		LossOfControlTimeLeftFrame_SetTime(self.TimeLeft, data.timeRemaining);
	else
		self:Hide();
	end
end

function LossOfControlTimeLeftFrame_SetTime(self, timeRemaining)
	if( timeRemaining ) then
		if ( timeRemaining >= 10 ) then
			self.NumberText:SetFormattedText("%d", timeRemaining);
		elseif (timeRemaining < 9.95) then -- From 9.95 to 9.99 it will print 10.0 instead of 9.9
			self.NumberText:SetFormattedText("%.1F", timeRemaining);
		end
		self:Show();
		self.timeRemaining = timeRemaining;
		self.numberWidth = self.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
	else
		self:Hide();
		self.numberWidth = 0;
	end
end

