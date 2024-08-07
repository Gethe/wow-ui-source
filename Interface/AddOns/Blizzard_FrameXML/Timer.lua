TIMER_MINUTES_DISPLAY = "%d:%02d"

local TIMER_DATA = {
	[Enum.StartTimerType.PvPBeginTimer] = { mediumMarker = 11, largeMarker = 6, updateInterval = 10 },
	[Enum.StartTimerType.ChallengeModeCountdown] = { mediumMarker = 100, largeMarker = 100, updateInterval = 100 },
	[Enum.StartTimerType.PlayerCountdown] = { mediumMarker = 31, largeMarker = 11, updateInterval = 10, finishedSoundKitID = SOUNDKIT.UI_COUNTDOWN_FINISHED, bigNumberSoundKitID = SOUNDKIT.UI_COUNTDOWN_TIMER, mediumNumberFinishedSoundKitID = SOUNDKIT.UI_COUNTDOWN_MEDIUM_NUMBER_FINISHED, barShowSoundKitID = SOUNDKIT.UI_COUNTDOWN_BAR_STATE_STARTS, barHideSoundKitID = SOUNDKIT.UI_COUNTDOWN_BAR_STATE_FINISHED},
	[Enum.StartTimerType.PlunderstormCountdown] = {
		mediumMarker = 11,
		largeMarker = 11,
		updateInterval = 10,
		finishedSoundKitID = SOUNDKIT.UI_COUNTDOWN_FINISHED,
		bigNumberSoundKitID = SOUNDKIT.UI_COUNTDOWN_TIMER,
		mediumNumberFinishedSoundKitID = SOUNDKIT.UI_COUNTDOWN_MEDIUM_NUMBER_FINISHED,
		barShowSoundKitID = SOUNDKIT.UI_COUNTDOWN_BAR_STATE_STARTS,
		barHideSoundKitID = SOUNDKIT.UI_COUNTDOWN_BAR_STATE_FINISHED,
		customSoundKits = {
			[10] = { SOUNDKIT.PLUNDERSTORM_COUNTDOWN1, SOUNDKIT.PLUNDERSTORM_COUNTDOWN2, SOUNDKIT.PLUNDERSTORM_COUNTDOWN_MUSIC, },
			[5] = { SOUNDKIT.PLUNDERSTORM_COUNTDOWN3, },
			[3] = { SOUNDKIT.PLUNDERSTORM_COUNTDOWN4, },
		},
	},
};

local function GetTimerData(startTimerTypeEnum)
	return TIMER_DATA[startTimerTypeEnum];
end

TIMER_NUMBERS_SETS = {};
TIMER_NUMBERS_SETS["BigGold"]  = {	texture = "Interface\\Timer\\BigTimerNumbers", 
									w=256, h=170, texW=1024, texH=512,
									numberHalfWidths = {
										--0,   1,   2,   3,   4,   5,   6,   7,   8,   9,
										35/128, 14/128, 33/128, 32/128, 36/128, 32/128, 33/128, 29/128, 31/128, 31/128,
									}
								}


function TimerTracker_OnLoad(self)
	self.timerList = {};
	self:RegisterEvent("START_TIMER");
	self:RegisterEvent("START_PLAYER_COUNTDOWN");
	self:RegisterEvent("CANCEL_PLAYER_COUNTDOWN");
	self:RegisterEvent("STOP_TIMER_OF_TYPE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end


function StartTimer_OnShow(self)
	self.time = self.endTime - GetTime();
	if self.time <= 0 then
		FreeTimerTrackerTimer(self);
		self:Hide();
	elseif self.startNumbers:IsPlaying() then
		self.startNumbers:Stop();
		self.startNumbers:Play();
	end
end

function GetPlayerFactionGroup()
	local factionGroup = UnitFactionGroup("player");
	if (C_PvP.IsPVPMap()) then
		-- this might be a rated BG or wargame and if so the player's faction might be altered
		if ( not IsActiveBattlefieldArena()) then
			factionGroup = PLAYER_FACTION_GROUP[GetBattlefieldArenaFaction()];
		end
	end

	return factionGroup
end

function FreeTimerTrackerTimer(timer)
	timer.time = nil;
	timer.type = nil;
	timer.isFree = true;
	timer.barShowing = false;
	timer:SetScript("OnUpdate", nil);
	timer.fadeBarOut:Stop();
	timer.fadeBarIn:Stop();
	timer.startNumbers:Stop();
	timer.GoTextureAnim:Stop();
	timer.bar:SetAlpha(0);
end

function TimerTracker_StartTimerOfType(self, timerType, timeSeconds, totalTime, informChat, initiatedByGuid, initiatedByName)
	local timer;
	local numTimers = 0;
	local isTimerRunning = false;
		
	for a,b in pairs(self.timerList) do
		if b.type == timerType and not b.isFree then
			timer = b;
			isTimerRunning = true;
			break;
		end
	end

	if isTimerRunning and timer.type ~= Enum.StartTimerType.PlayerCountdown then
		-- don't interupt the final count down
		if not timer.startNumbers:IsPlaying() then
			timer.time = timeSeconds;
			timer.endTime = GetTime() + timeSeconds;
		end
	else
		for a,b in pairs(self.timerList) do
			if not timer and b.isFree then
				timer = b;
			else
				numTimers = numTimers + 1;
			end
		end
			
		if(timer and timer.type == Enum.StartTimerType.PlayerCountdown) then 
			FreeTimerTrackerTimer(timer);
		end 

		if not timer then
			timer = CreateFrame("FRAME", self:GetName().."Timer"..(#self.timerList+1), self, "StartTimerBar");
			self.timerList[#self.timerList+1] = timer;
		end
			
		timer:ClearAllPoints();
		timer:SetPoint("TOP", 0, -155 - (24*numTimers));
			
		timer.isFree = false;
		timer.type = timerType;
		timer.time = timeSeconds;
		timer.endTime = GetTime() + timeSeconds;
		timer.bar:SetMinMaxValues(0, totalTime);
		timer.style = TIMER_NUMBERS_SETS["BigGold"];
			
		timer.digit1:SetTexture(timer.style.texture);
		timer.digit2:SetTexture(timer.style.texture);
		timer.digit1:SetSize(timer.style.w/2, timer.style.h/2);
		timer.digit2:SetSize(timer.style.w/2, timer.style.h/2);
		--This is to compensate texture size not affecting GetWidth() right away.
		timer.digit1.width, timer.digit2.width = timer.style.w/2, timer.style.w/2;
			
		timer.digit1.glow = timer.glow1;
		timer.digit2.glow = timer.glow2;
		timer.glow1:SetTexture(timer.style.texture.."Glow");
		timer.glow2:SetTexture(timer.style.texture.."Glow");
			
		local timerData = GetTimerData(timer.type);
		timer.updateTime = timerData.updateInterval;
		timer:SetScript("OnUpdate", StartTimer_BigNumberOnUpdate);
		timer:Show();
	end
	StartTimer_SetGoTexture(timer);

	if informChat then
		local systemMessage;

		if not initiatedByGuid then
			systemMessage = COUNTDOWN_CANCEL_ENCOUNTER_START;
		elseif initiatedByName then
			if totalTime > 0 then
				systemMessage = COUNTDOWN_SET:format(initiatedByName, initiatedByName);
			else
				systemMessage = COUNTDOWN_CLEAR:format(initiatedByName, initiatedByName);
			end
		end
			
		if systemMessage then
			ChatFrame_DisplaySystemMessageInPrimary(systemMessage);
		end
	end
end

function TimerTracker_OnEvent(self, event, ...)
	if C_Commentator.IsSpectating() then
		self:SetParent(WorldFrame);
	else
		self:SetParent(UIParent);
	end
	
	if event == "START_TIMER" then
		local timerType, timeSeconds, totalTime  = ...;
		TimerTracker_StartTimerOfType(self, timerType, timeSeconds, totalTime);
	elseif event == "START_PLAYER_COUNTDOWN" then
		local initiatedByGuid, timeSeconds, totalTime, informChat, initiatedByName  = ...;
		TimerTracker_StartTimerOfType(self, Enum.StartTimerType.PlayerCountdown, timeSeconds, totalTime, informChat, initiatedByGuid, initiatedByName);
	elseif event == "CANCEL_PLAYER_COUNTDOWN" then
		local initiatedByGuid, informChat, initiatedByName  = ...;
		TimerTracker_StartTimerOfType(self, Enum.StartTimerType.PlayerCountdown, 0, 0, informChat, initiatedByGuid, initiatedByName);
	elseif event == "STOP_TIMER_OF_TYPE" then
		local timerType = ...;
		for a,timer in pairs(self.timerList) do
			if(timer.type == timerType) then 
				FreeTimerTrackerTimer(timer);
				timer:Hide();
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		for a,timer in pairs(self.timerList) do
			if(timer.type == Enum.StartTimerType.PvPBeginTimer) then 
				FreeTimerTrackerTimer(timer);
			end
		end
	end
end


function StartTimer_BigNumberOnUpdate(self, elapsed)
	self.time = self.endTime - GetTime();
	local timerData = GetTimerData(self.type);
	if C_Commentator.IsSpectating() then
		if self.time < timerData.mediumMarker then
			self:SetAlpha(1);
		else
			self.bar:Hide();
			return;
		end
	end

	self.updateTime = self.updateTime - elapsed;
	local minutes, seconds = floor(self.time/60), floor(mod(self.time, 60)); 

	if ( self.time < timerData.mediumMarker ) then
		self.anchorCenter = false;
		if self.time < timerData.largeMarker then
			StartTimer_SwitchToLargeDisplay(self);
		end
		self:SetScript("OnUpdate", nil);
		if ( self.barShowing ) then
			self.barShowing = false;
			self.fadeBarOut:Play();
			if (timerData.barHideSoundKitID) then 
				PlaySound(timerData.barHideSoundKitID); 
			end 
		else
			self.startNumbers:Play();
		end
	elseif not self.barShowing then
		self.fadeBarIn:Play();
		self.barShowing = true;
		if (timerData.barShowSoundKitID) then 
			PlaySound(timerData.barShowSoundKitID); 
		end 
	elseif self.updateTime <= 0 then
		self.updateTime = timerData.updateInterval;
	end

	self.bar:SetValue(self.time);
	self.bar.timeText:SetText(string.format(TIMER_MINUTES_DISPLAY, minutes, seconds));
end


function StartTimer_BarOnlyOnUpdate(self, elapsed)
	self.time = self.endTime - GetTime();
	local minutes, seconds = floor(self.time/60), mod(self.time, 60); 

	self.bar:SetValue(self.time);
	self.bar.timeText:SetText(string.format(TIMER_MINUTES_DISPLAY, minutes, seconds));
	
	if self.time < 0 then
		FreeTimerTrackerTimer(self);
		self:Hide();
	end
	
	if not self.barShowing then
		self.fadeBarIn:Play();
		self.barShowing = true;
	end
end


function StartTimer_SetTexNumbers(self, ...)
	local digits = {...}
	local timeDigits = floor(self.time);
	local digit;
	local style = self.style;
	local i = 1;

	local timerData = GetTimerData(self.type);
	local customSoundKits = timerData.customSoundKits and timerData.customSoundKits[timeDigits] or nil;
	if customSoundKits then
		for _, soundKitID in ipairs(customSoundKits) do
			PlaySound(soundKitID);
		end
	end

	local texCoW = style.w/style.texW;
	local texCoH = style.h/style.texH;
	local l,r,t,b;
	local columns = floor(style.texW/style.w);
	local numberOffset = 0;
	local numShown = 0;

	while digits[i] do -- THIS WILL DISPLAY SECOND AS A NUMBER 2:34 would be 154
		if timeDigits > 0 then
			digit = mod(timeDigits, 10);
			
			digits[i].hw = style.numberHalfWidths[digit+1]*digits[i].width;
			numberOffset  = numberOffset + digits[i].hw;
			
			l = mod(digit, columns) * texCoW;
			r = l + texCoW;
			t = floor(digit/columns) * texCoH;
			b = t + texCoH;
			digits[i]:SetTexCoord(l,r,t,b);
			digits[i].glow:SetTexCoord(l,r,t,b);
			
			timeDigits = floor(timeDigits/10);	
			numShown = numShown + 1;			
		else
			digits[i]:SetTexCoord(0,0,0,0);
			digits[i].glow:SetTexCoord(0,0,0,0);
		end
		i = i + 1;
	end
	
	if numberOffset > 0 then
		if(timerData.bigNumberSoundKitID and numShown < timerData.largeMarker ) then 
			PlaySound(timerData.bigNumberSoundKitID); 
		else 
			PlaySound(SOUNDKIT.UI_BATTLEGROUND_COUNTDOWN_TIMER, "SFX");
		end 
		digits[1]:ClearAllPoints();
		if self.anchorCenter or C_Commentator.IsSpectating() then
			digits[1]:SetPoint("CENTER", TimerTracker, "CENTER", numberOffset - digits[1].hw, 0);
		else
			digits[1]:SetPoint("CENTER", self, "CENTER", numberOffset - digits[1].hw, 0);
		end
		
		for j=2,numShown do
			digits[j]:ClearAllPoints();
			digits[j]:SetPoint("CENTER", digits[j-1], "CENTER", -(digits[j].hw + digits[j-1].hw), 0)
			j = j + 1;
		end
	end
end

function StartTimer_SetGoTexture(timer)
	if ( timer.type == Enum.StartTimerType.PvPBeginTimer ) then
		if C_Commentator.IsSpectating() or IsInLFDBattlefield() then
			timer.GoTexture:SetAtlas("countdown-swords");
			timer.GoTextureGlow:SetAtlas("countdown-swords-glow");

			StartTimer_SwitchToLargeDisplay(timer);
		else
			local factionGroup = GetPlayerFactionGroup();
			if ( factionGroup and factionGroup ~= "Neutral" ) then
				timer.GoTexture:SetTexture("Interface\\Timer\\"..factionGroup.."-Logo");
				timer.GoTextureGlow:SetTexture("Interface\\Timer\\"..factionGroup.."Glow-Logo");
			end
		end
	elseif ( timer.type == Enum.StartTimerType.ChallengeModeCountdown ) then
		timer.GoTexture:SetTexture("Interface\\Timer\\Challenges-Logo");
		timer.GoTextureGlow:SetTexture("Interface\\Timer\\ChallengesGlow-Logo");
	elseif (timer.type == Enum.StartTimerType.PlayerCountdown) then 
		timer.GoTexture:SetTexture("")
		timer.GoTextureGlow:SetTexture("")
	end 
end

function StartTimer_NumberAnimOnFinished(self)
	self.time = self.time - 1;
	local timerData = GetTimerData(self.type);
	if self.time > 0 then
		if self.time < timerData.largeMarker then
			StartTimer_SwitchToLargeDisplay(self);
		end	
		self.startNumbers:Play();
	else
		if(timerData.finishedSoundKitID) then
			PlaySound(timerData.finishedSoundKitID); 
		else
			PlaySound(SOUNDKIT.UI_BATTLEGROUND_COUNTDOWN_FINISHED);
		end
		FreeTimerTrackerTimer(self);
		self.GoTextureAnim:Play();
	end
end

function StartTimer_SwitchToLargeDisplay(self)
	if not self.anchorCenter then
		self.anchorCenter = true;
		--This is to compensate texture size not affecting GetWidth() right away.
		self.digit1.width, self.digit2.width = self.style.w, self.style.w;
		self.digit1:SetSize(self.style.w, self.style.h);
		self.digit2:SetSize(self.style.w, self.style.h);

		local timerData = GetTimerData(self.type);
		if(timerData.mediumNumberFinishedSoundKitID) then 
			PlaySound(timerData.mediumNumberFinishedSoundKitID);
		end 
	end
end