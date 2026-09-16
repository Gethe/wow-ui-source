--
-- Challenge Mode - only 1 timer for now, needs some work for multiple timers
--

function WorldStateChallengeMode_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("WORLD_STATE_TIMER_START");
	self:RegisterEvent("WORLD_STATE_TIMER_STOP");
end

function WorldStateChallengeMode_OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		WorldStateChallengeMode_CheckTimers(GetWorldElapsedTimers());
	elseif event == "WORLD_STATE_TIMER_START" then
		local timerID = ...;
		WorldStateChallengeMode_CheckTimers(timerID);
	elseif event == "WORLD_STATE_TIMER_STOP" then
		local timerID = ...;
		WorldStateChallengeMode_HideTimer(timerID);
	end

end

-- WatchFrame handler function
function WorldStateChallengeMode_DisplayTimers(lineFrame, nextAnchor, maxHeight, frameWidth)
	local self = WorldStateChallengeModeFrame;
	if ( self.timerID ) then
		self:SetParent(lineFrame);
		if (nextAnchor) then
			self:SetPoint("TOPLEFT", nextAnchor, "BOTTOMLEFT", 0, -WATCHFRAME_TYPE_OFFSET);
		else
			self:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, -WATCHFRAME_INITIAL_OFFSET)
		end
		local _, elapsedTime = GetWorldElapsedTime(self.timerID);
		WorldStateChallengeModeTimer.baseTime = elapsedTime;
		WorldStateChallengeModeTimer.timeSinceBase = 0;
		WorldStateChallengeModeTimer.frame = self;
		self:Show();
		return self, 198, 0, 1;
	else
		-- handler should have been removed before this...
		self:Hide();
		return nextAnchor, 0, 0, 0;
	end
end

function WorldStateChallengeMode_CheckTimers(...)
	for i = 1, select("#", ...) do
		local timerID = select(i, ...);
		local _, elapsedTime, type = GetWorldElapsedTime(timerID);
		if ( type == Enum.WorldElapsedTimerTypes.ChallengeMode) then
			local _, _, _, _, _, _, _, mapID = GetInstanceInfo();
			if ( mapID ) then
				WorldStateChallengeMode_ShowTimer(timerID, elapsedTime, C_ChallengeMode.GetChallengeModeMapTimes(mapID));
				return;
			end
		end	
	end
	WorldStateChallengeMode_HideTimer();
end

function WorldStateChallengeMode_ShowTimer(timerID, elapsedTime, times)
	local self = WorldStateChallengeModeFrame;
	if not ( self.medalTimes ) then
		self.medalTimes = { };
	end
	for i = 1, #times do
		self.medalTimes[i] = times[i]
	end
	-- not currently being displayed, set up handler
	if ( not self.timerID ) then
		WatchFrame_AddObjectiveHandler(WorldStateChallengeMode_DisplayTimers, 1);
		if ( WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) ) then
			self.hidWatchedQuests = true;
		end
	end
	self.timerID = timerID;
	WorldStateChallengeModeFrame_UpdateMedal(self, elapsedTime);
	WorldStateChallengeModeFrame_UpdateValues(self, elapsedTime);
	WatchFrame_ClearDisplay();
	WatchFrame_Expand(WatchFrame);	-- will automatically do a watchframe update
	WorldStateChallengeModeTimer:Show();
end

function WorldStateChallengeMode_HideTimer(timerID)
	local self = WorldStateChallengeModeFrame;
	if ( not timerID or self.timerID == timerID ) then
		self.timerID = nil;
		if ( self.hidWatchedQuests ) then
			WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests);
		end
		self:Hide();
		WorldStateChallengeModeTimer:Hide();
		self.lastMedalShown = nil;
		WatchFrame_RemoveObjectiveHandler(WorldStateChallengeMode_DisplayTimers);
		WatchFrame_ClearDisplay();
		WatchFrame_Update(WatchFrame);
	end
end

function WorldStateChallengeModeFrame_UpdateMedal(self, elapsedTime)
	-- find best medal for current time
	local prevMedalTime = 0;
	for i = #self.medalTimes, 1, -1 do
		local currentMedalTime = self.medalTimes[i];
		if ( elapsedTime < currentMedalTime ) then
			self.statusBar:SetMinMaxValues(0, currentMedalTime - prevMedalTime);
			self.statusBar.medalTime = currentMedalTime;
			if ( CHALLENGE_MEDAL_TEXTURES[i] ) then
				self.medalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES[i]);
				self.medalIcon:Show();
				self.GlowFrame.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES[i]);
				self.GlowFrame.MedalGlowAnim:Play();
			end
			self.noMedal:Hide();
			-- play sound if medal changed
			if ( self.lastMedalShown and self.lastMedalShown ~= i ) then
				if ( self.lastMedalShown == CHALLENGE_MEDAL_GOLD ) then
					PlaySound(SOUNDKIT.UI_CHALLENGES_MEDALEXPIRE_GOLDTOSILVER);
				elseif ( self.lastMedalShown == CHALLENGE_MEDAL_SILVER ) then
					PlaySound(SOUNDKIT.UI_CHALLENGES_MEDALEXPIRE_SILVERTOBRONZE);
				else
					PlaySound(SOUNDKIT.UI_CHALLENGES_MEDALEXPIRE);
				end
			end
			self.lastMedalShown = i;
			return;
		else
			prevMedalTime = currentMedalTime;
		end
	end
	-- no medal
	self.statusBar.timeLeft:SetText(CHALLENGES_TIMER_NO_MEDAL);
	self.statusBar:SetValue(0);
	self.statusBar.medalTime = nil;
	self.noMedal:Show();
	self.medalIcon:Hide();
	-- play sound if medal changed
	if ( self.lastMedalShown and self.lastMedalShown ~= 0 ) then
		PlaySound(SOUNDKIT.UI_CHALLENGES_MEDALEXPIRE);
	end
	self.lastMedalShown = 0;
end

function WorldStateChallengeModeFrame_UpdateValues(self, elapsedTime)
	local statusBar = self.statusBar;
	if ( statusBar.medalTime ) then
		local timeLeft = statusBar.medalTime - elapsedTime;
		local anim = self.GlowFrame.MedalPulseAnim;
		if (timeLeft <= 5) then
			if (anim:IsPlaying()) then 
				anim.timeLeft = timeLeft;
			else
				self.GlowFrame.MedalPulseAnim:Play();
			end
		end
		if (timeLeft == 10) then
			if (not self.playedSound) then
				PlaySound(SOUNDKIT.UI_CHALLENGES_WARNING);
				self.playedSound = true;
			end
		else
			self.playedSound = false;
		end
		if ( timeLeft < 0 ) then
			WorldStateChallengeModeFrame_UpdateMedal(self, elapsedTime);
		else
			statusBar:SetValue(statusBar.medalTime - elapsedTime);
			statusBar.timeLeft:SetText(GetTimeStringFromSeconds(statusBar.medalTime - elapsedTime));
		end
	end
end

function WorldStateChallengeModeAnim_OnFinished(self)
	if (self.timeLeft and self.timeLeft > 0 and self.timeLeft < 5) then
		self:Play();
	else
		self.timeLeft = nil;
	end
end

local floor = floor; --optimization so we don't do a global lookup on update
function WorldStateChallengeModeTimer_OnUpdate(self, elapsed)
	self.timeSinceBase = self.timeSinceBase + elapsed;
	WorldStateChallengeModeFrame_UpdateValues(self.frame, floor(self.baseTime + self.timeSinceBase));
end

--
-- Proving Grounds
--

-- WatchFrame handler function
function WorldStateProvingGrounds_DisplayTimers(lineFrame, nextAnchor, maxHeight, frameWidth)
	local self = WorldStateProvingGroundsFrame;
	if ( self.timerID ) then
		self:SetParent(lineFrame);
		if (nextAnchor) then
			self:SetPoint("TOPLEFT", nextAnchor, "BOTTOMLEFT", 0, -WATCHFRAME_TYPE_OFFSET);
		else
			self:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", 0, -WATCHFRAME_INITIAL_OFFSET)
		end
		local _, elapsedTime = GetWorldElapsedTime(self.timerID);
		WorldStateProvingGroundsTimer.baseTime = elapsedTime;
		WorldStateProvingGroundsTimer.timeSinceBase = 0;
		WorldStateProvingGroundsTimer.frame = self;
		self:Show();
		WatchFrameScenario_UpdateScenario();
		return self, 198, 0, 1;
	else
		-- handler should have been removed before this...
		self:Hide();
		return nextAnchor, 0, 0, 0;
	end
end

function WorldStateProvingGrounds_CheckTimers(...)
	for i = 1, select("#", ...) do
		local timerID = select(i, ...);
		local _, elapsedTime, type = GetWorldElapsedTime(timerID);
		if ( type == Enum.WorldElapsedTimerTypes.ProvingGround) then
			local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
			if (duration > 0) then
				WorldStateProvingGrounds_ShowTimer(timerID, elapsedTime, duration, diffID, currWave, maxWave);
				return;
			end
		end	
	end
	WorldStateProvingGrounds_HideTimer();
end

local PROVING_GROUNDS_ENDLESS_INDEX = 4;
function WorldStateProvingGrounds_ShowTimer(timerID, elapsedTime, duration, medalIndex, currWave, maxWave)
	local self = WorldStateProvingGroundsFrame;
	local statusBar = self.statusBar;
	
	-- not currently being displayed, set up handler
	if ( not self.timerID ) then
		WatchFrame_AddObjectiveHandler(WorldStateProvingGrounds_DisplayTimers, 1);
		if ( WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) ) then
			self.hidWatchedQuests = true;
		end
	end
	
	self.timerID = timerID;
	statusBar.duration = duration;
	statusBar:SetMinMaxValues(0, duration);
	if ( CHALLENGE_MEDAL_TEXTURES[medalIndex] ) then
		self.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES[medalIndex]);
		self.MedalIcon:Show();
	end
	
	if (medalIndex < PROVING_GROUNDS_ENDLESS_INDEX) then
		self.ScoreLabel:Hide();
		self.Score:Hide();
		self.WaveLabel:SetPoint("TOPLEFT", self.MedalIcon, "TOPRIGHT", 1, -4);
		self.Wave:SetFormattedText(GENERIC_FRACTION_STRING, currWave, maxWave);
		statusBar:SetPoint("CENTER", self, "CENTER", 22, -8);
	else
		self.ScoreLabel:Show();
		self.Score:Show();
		self.WaveLabel:SetPoint("TOPLEFT", self.MedalIcon, "TOPRIGHT", 1, 4);
		self.Wave:SetText(currWave);
		statusBar:SetPoint("CENTER", self, "CENTER", 22, -17);
	end
	
	self:RegisterEvent("PROVING_GROUNDS_SCORE_UPDATE");
	WorldStateProvingGroundsFrame_UpdateValues(self, elapsedTime);
	self.CountdownAnim.timeLeft = nil;
	WatchFrame_ClearDisplay();
	WatchFrame_Expand(WatchFrame);	-- will automatically do a watchframe update
	WorldStateProvingGroundsTimer:Show();
end

function WorldStateProvingGrounds_HideTimer(timerID)
	local self = WorldStateProvingGroundsFrame;
	if ( not timerID or self.timerID == timerID ) then
		self.timerID = nil;
		if ( self.hidWatchedQuests ) then
			WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests);
		end
		self:UnregisterEvent("PROVING_GROUNDS_SCORE_UPDATE");
		self:Hide();
		WorldStateProvingGroundsTimer:Hide();
		WatchFrame_RemoveObjectiveHandler(WorldStateProvingGrounds_DisplayTimers);
		WatchFrame_ClearDisplay();
		WatchFrame_Update(WatchFrame);
	end
end

function WorldStateProvingGroundsFrame_UpdateValues(self, elapsedTime)
	WatchFrameHeader:Show()
	local statusBar = self.statusBar;
	if ( elapsedTime < statusBar.duration ) then
		statusBar:SetValue(statusBar.duration - elapsedTime);
		statusBar.timeLeft:SetText(GetTimeStringFromSeconds(statusBar.duration - elapsedTime));
		
		local timeLeft = statusBar.duration - elapsedTime;
		local anim = self.CountdownAnim;
		if (timeLeft <= 5) then
			if (anim:IsPlaying()) then 
				anim.timeLeft = timeLeft;
			else
				anim:Play();
			end
		elseif (anim.timeLeft ~= nil) then
			-- the time left never reaches 0 if there's another wave, but the animation always needs to get to 0
			anim.timeLeft = 0; 
		end
	end
end

function WorldStateProvingGrounds_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("WORLD_STATE_TIMER_START");
	self:RegisterEvent("WORLD_STATE_TIMER_STOP");
end

function WorldStateProvingGrounds_OnEvent(self, event, ...)
	if (event == "PROVING_GROUNDS_SCORE_UPDATE") then
		local score = ...
		self.Score:SetText(score);
	elseif event == "PLAYER_ENTERING_WORLD" then
		WorldStateProvingGrounds_CheckTimers(GetWorldElapsedTimers());
	elseif event == "WORLD_STATE_TIMER_START" then
		local timerID = ...;
		WorldStateProvingGrounds_CheckTimers(timerID);
	elseif event == "WORLD_STATE_TIMER_STOP" then
		local timerID = ...;
		WorldStateProvingGrounds_HideTimer(timerID);
	end
end

function WorldStateProvingGroundsTimer_OnUpdate(self, elapsed)
	self.timeSinceBase = self.timeSinceBase + elapsed;
	WorldStateProvingGroundsFrame_UpdateValues(self.frame, floor(self.baseTime + self.timeSinceBase));
end

function WorldStateProvingGroundsAnim_OnFinished(self)
	if (self.timeLeft and self.timeLeft > 0 and self.timeLeft < 5) then
		self:Play();
	else
		self.timeLeft = nil;
	end
end
