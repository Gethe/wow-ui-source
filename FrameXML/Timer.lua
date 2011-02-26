
TIMER_MINUTES_DISPLAY = "%d:%02d"


function TimerTracker_OnLoad(self)
	self.timerList = {};
	--self:RegisterEvent("START_TIMER");
end


function TimerTracker_OnEvent(self, event, ...)
	local timer;
	local numTimers = 0;
	
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
	timer:SetPoint("BOTTOM", 0, 125 + (24*numTimers));
	
	if event == "START_TIMER" then
		local timerType, timeSeconds, totalTime  = ...;
		timer.isFree = false;
		timer:SetScript("OnUpdate", StartTimer_OnUpdate);
		timer.time = timeSeconds;
		timer.bar:SetMinMaxValues(0, totalTime);
		print("The time is:", timeSeconds, timerType);
	end
end


function StartTimer_OnUpdate(self, elasped)
	self.time = self.time - elasped;
	local minutes, seconds = floor(self.time/60), mod(self.time, 60); 

	self.bar:SetValue(self.time);
	self.bar.timeText:SetText(string.format(TIMER_MINUTES_DISPLAY, minutes, seconds));
	if self.time < 0 then
		self:SetScript("OnUpdate", nil);
		self.isFree = true;
		self:Hide();
	end
end


function tcp()
	TimerTracker_OnEvent(TimerTracker, "START_TIMER", "pvp", random(20, 40));
end