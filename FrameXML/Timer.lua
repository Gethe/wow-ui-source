TIMER_MINUTES_DISPLAY = "%d:%02d"

TIMER_MEDIUM_MARKER = 11;
TIMER_LARGE_MARKER = 6;
TIMER_UPDATE_INTERVAL = 10;

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
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end


function StartTimer_OnShow(self)
	self.time = self.endTime - GetTime();
	if self.time <= 0 then
		self:Hide();
		self.isFree = true;
	elseif self.startNumbers:IsPlaying() then
		self.startNumbers:Stop();
		self.startNumbers:Play();
	end
end

function GetPlayerFactionGroup()
	local factionGroup = UnitFactionGroup("player");
	-- this might be a rated BG or wargame and if so the player's faction might be altered
	if ( not IsActiveBattlefieldArena() ) then
		factionGroup = PLAYER_FACTION_GROUP[GetBattlefieldArenaFaction()];
	end
	
	return factionGroup
end

function TimerTracker_OnEvent(self, event, ...)
	
	if event == "START_TIMER" then
		local timerType, timeSeconds, totalTime  = ...;
		local timer;
		local numTimers = 0;
		local isTimerRuning = false;
		
		for a,b in pairs(self.timerList) do
			if b.type == timerType and not b.isFree then
				timer = b;
				isTimerRuning = true;
				break;
			end
		end

		if isTimerRuning then
			-- don't interupt the final count down
			if not timer.startNumbers:IsPlaying() then
				timer.time = timeSeconds;
			end
			
			local factionGroup = GetPlayerFactionGroup();

			if ( not timer.factionGroup or (timer.factionGroup ~= factionGroup) ) then
				timer.faction:SetTexture("Interface\\Timer\\"..factionGroup.."-Logo");
				timer.factionGlow:SetTexture("Interface\\Timer\\"..factionGroup.."Glow-Logo");
				timer.factionGroup = factionGroup;
			end
		else
			for a,b in pairs(self.timerList) do
				if not timer and b.isFree then
					timer = b;
				else
					numTimers = numTimers + 1;
				end
			end
			
			
			if not timer then
				timer = CreateFrame("FRAME", self:GetName().."Timer"..(#self.timerList+1), UIParent, "StartTimerBar");
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
			
			local factionGroup = GetPlayerFactionGroup();
			if ( factionGroup ) then
				timer.faction:SetTexture("Interface\\Timer\\"..factionGroup.."-Logo");
				timer.factionGlow:SetTexture("Interface\\Timer\\"..factionGroup.."Glow-Logo");
			end
			timer.factionGroup = factionGroup;
			timer.updateTime = TIMER_UPDATE_INTERVAL;
			timer:SetScript("OnUpdate", StartTimer_BigNumberOnUpdate);
			timer:Show();
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		for a,timer in pairs(self.timerList) do
			timer.time = nil;
			timer.type = nil;
			timer.isFree = nil;
			timer:SetScript("OnUpdate", nil);
			timer.fadeBarOut:Stop();
			timer.fadeBarIn:Stop();
			timer.startNumbers:Stop();
			timer.factionAnim:Stop();
			timer.bar:SetAlpha(0);
		end
	end
end


function StartTimer_BigNumberOnUpdate(self, elasped)
	self.time = self.endTime - GetTime();
	self.updateTime = self.updateTime - elasped;
	local minutes, seconds = floor(self.time/60), floor(mod(self.time, 60)); 

	
	if self.time < TIMER_MEDIUM_MARKER then
		self.fadeBarOut:Play();
		self.barShowing = false;
		self.anchorCenter = false;
		self:SetScript("OnUpdate", nil);
	elseif not self.barShowing then
		self.fadeBarIn:Play();
		self.barShowing = true;
	elseif self.updateTime <= 0 then
		ValidateTimer(self.type);
		self.updateTime = TIMER_UPDATE_INTERVAL;
	end

	self.bar:SetValue(self.time);
	self.bar.timeText:SetText(string.format(TIMER_MINUTES_DISPLAY, minutes, seconds));
end


function StartTimer_BarOnlyOnUpdate(self, elasped)
	self.time = self.endTime - GetTime();
	local minutes, seconds = floor(self.time/60), mod(self.time, 60); 

	self.bar:SetValue(self.time);
	self.bar.timeText:SetText(string.format(TIMER_MINUTES_DISPLAY, minutes, seconds));
	
	if self.time < 0 then
		self:SetScript("OnUpdate", nil);
		self.barShowing = false;
		self.isFree = true;
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
		PlaySoundKitID(25477, "SFX", false);
		digits[1]:ClearAllPoints();
		if self.anchorCenter then
			digits[1]:SetPoint("CENTER", UIParent, "CENTER", numberOffset - digits[1].hw, 0);
		else
			digits[1]:SetPoint("CENTER", self, "CENTER", numberOffset - digits[1].hw, 0);
		end
		
		for i=2,numShown do
			digits[i]:ClearAllPoints();
			digits[i]:SetPoint("CENTER", digits[i-1], "CENTER", -(digits[i].hw + digits[i-1].hw), 0)
			i = i + 1;
		end
	end
end



function StartTimer_NumberAnimOnFinished(self)
	self.time = self.time - 1;
	if self.time > 0 then
		if self.time < TIMER_LARGE_MARKER then
			if not self.anchorCenter then
				self.anchorCenter = true;
				--This is to compensate texture size not affecting GetWidth() right away.
				self.digit1.width, self.digit2.width = self.style.w, self.style.w;
				self.digit1:SetSize(self.style.w, self.style.h);
				self.digit2:SetSize(self.style.w, self.style.h);
			end
		end
	
		self.startNumbers:Play();
	else
		self.isFree = true;
		PlaySoundKitID(25478);
		self.factionAnim:Play();
	end
end
