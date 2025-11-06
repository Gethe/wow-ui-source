CombatAudioAlertManagerMixin = {};

function CombatAudioAlertManagerMixin:OnLoad()
	self.lastUnitHealthPercent = {};

	local function RefreshEvents()
		self:RefreshEvents()
	end

	local function PlaySample()
		self:PlaySample()
	end

	local function RefreshThrottles()
		self:RefreshThrottles()
	end

	for _, cvarInfo in pairs(CombatAudioAlertConstants.CVars) do
		CVarCallbackRegistry:SetCVarCachable(cvarInfo.name);

		if cvarInfo.refreshEvents then
			CVarCallbackRegistry:RegisterCallback(cvarInfo.name, RefreshEvents);
		end

		if cvarInfo.playSample then
			CVarCallbackRegistry:RegisterCallback(cvarInfo.name, PlaySample);
		end

		if cvarInfo.refreshThrottles then
			CVarCallbackRegistry:RegisterCallback(cvarInfo.name, RefreshThrottles);
		end
	end

	self:RegisterEvent("VARIABLES_LOADED");
end

function CombatAudioAlertManagerMixin:OnEvent(event, ...)
	if event == "VARIABLES_LOADED" then
		self:InitThrottles();
		self:InitEvents();
	elseif event == "UNIT_HEALTH" then
		local unit = ...;

		if not self.unitHealthUnitsLookup[unit] then
			return;
		end

		self:ProcessUnitHealthChange(unit);
	elseif event == "PLAYER_TARGET_CHANGED" then
		self.lastUnitHealthPercent["target"] = nil;
		self:ProcessUnitHealthChange("target");
	end
end

function CombatAudioAlertManagerMixin:InitThrottles()
	local isInitYes = true;
	self:RefreshThrottles(isInitYes);
end

function CombatAudioAlertManagerMixin:RefreshThrottles(isInit)
	if isInit then
		self.throttles = {
			[CombatAudioAlertConstants.ThrottleTypes.Sample] = { duration = CombatAudioAlertConstants.SAMPLE_TEXT_THROTTLE_SECS, constant = true },
		}
	else
		for _, throttleInfo in ipairs(self.throttles) do
			if not throttleInfo.constant and throttleInfo.timer then
				throttleInfo.timer:Cancel();
				throttleInfo.timer = nil;
			end
		end
	end

	self.throttles[CombatAudioAlertConstants.ThrottleTypes.PlayerHealth] = { duration = CombatAudioAlertUtil.GetCAACvarValueNumber("PLAYER_HEALTH_THROTTLE_CVAR")};
	self.throttles[CombatAudioAlertConstants.ThrottleTypes.TargetHealth] = { duration = CombatAudioAlertUtil.GetCAACvarValueNumber("TARGET_HEALTH_THROTTLE_CVAR")};
end

function CombatAudioAlertManagerMixin:InitEvents()
	local isInitYes = true;
	self:RefreshEvents(isInitYes);
end

function CombatAudioAlertManagerMixin:RefreshEvents(isInit)
	if not isInit then
		self:UnregisterEvent("UNIT_HEALTH");
		self:UnregisterEvent("PLAYER_TARGET_CHANGED");
	end

	local enabled = CombatAudioAlertUtil.GetCAACVarValueBool("ENABLED_CVAR");
	if enabled then
		self.unitHealthUnits = {};

		local playerHealthNeeded = (CombatAudioAlertUtil.GetCAACvarValueNumber("PLAYER_HEALTH_PCT_CVAR") > 0);
		if playerHealthNeeded then
			table.insert(self.unitHealthUnits, "player");
		end

		local targetHealthNeeded = (CombatAudioAlertUtil.GetCAACvarValueNumber("TARGET_HEALTH_PCT_CVAR") > 0);
		if targetHealthNeeded then
			table.insert(self.unitHealthUnits, "target");
		end

		if #self.unitHealthUnits > 0 then
			self:RegisterUnitEvent("UNIT_HEALTH", self.unitHealthUnits);
		end

		self.unitHealthUnitsLookup = CopyValuesAsKeys(self.unitHealthUnits);

		if targetHealthNeeded then
			self:RegisterEvent("PLAYER_TARGET_CHANGED");
		end
	else
		self.unitHealthUnits = {};
		self.unitHealthUnitsLookup = {};
	end

	if isInit then
		for _, unit in ipairs(self.unitHealthUnits) do
			self:ProcessUnitHealthChange(unit);
		end
	end
end

function CombatAudioAlertManagerMixin:PlaySample()
	self:TrySpeakText(CombatAudioAlertConstants.ThrottleTypes.Sample, CAA_SAMPLE_TEXT);
end

function CombatAudioAlertManagerMixin:OnThrottleTimerComplete(throttleType)
	local throttleInfo = self.throttles[throttleType];
	if throttleInfo then
		--print("throttle "..throttleType.." complete");
		throttleInfo.timer:Cancel();
		throttleInfo.timer = nil;
		if throttleInfo.throttleDoneText then
			--print("speaking text "..throttleInfo.throttleDoneText);
			self:SpeakText(throttleInfo.throttleDoneText);
			throttleInfo.throttleDoneText = nil;
		end
	end
end

function CombatAudioAlertManagerMixin:CheckThrottle(throttleType, text)
	local throttleInfo = self.throttles[throttleType];
	if throttleInfo then
		if throttleInfo.timer then
			--print("throttle "..throttleType.." active throttleDoneText set to "..text);
			throttleInfo.throttleDoneText = text;
			return false;
		else
			if throttleInfo.duration > 0 then
				--print("throttle "..throttleType.." inactive, started timer duration = "..throttleInfo.duration);
				throttleInfo.timer = C_Timer.NewTimer(throttleInfo.duration, function() self:OnThrottleTimerComplete(throttleType) end);
			end

			return true;
		end
	else
		error("Invalid throttleType passed to CheckThrottle")
	end
end

function CombatAudioAlertManagerMixin:GetSelectedVoice()
	return CombatAudioAlertUtil.GetCAACvarValueNumber("VOICE_CVAR");
end

function CombatAudioAlertManagerMixin:GetSpeakerSpeed()
	return CombatAudioAlertUtil.GetCAACvarValueNumber("SPEED_CVAR");
end

function CombatAudioAlertManagerMixin:GetSpeakerVolume()
	return CombatAudioAlertUtil.GetCAACvarValueNumber("VOLUME_CVAR");
end

function CombatAudioAlertManagerMixin:GetUnitHealthThreshold(unit)
	if unit == "player" then
		return CombatAudioAlertUtil.GetCAACvarValueNumber("PLAYER_HEALTH_PCT_CVAR");
	elseif unit == "target" then
		return CombatAudioAlertUtil.GetCAACvarValueNumber("TARGET_HEALTH_PCT_CVAR");
	else
		error("Invalid unit passed to GetUnitHealthThreshold")
	end
end

function CombatAudioAlertManagerMixin:GetUnitResourceBand(unit, percent)
	if not percent then
		return nil;
	end

	local threshold = self:GetUnitHealthThreshold(unit);
	if threshold == 0 then
		return 0;
	end
	return math.floor(percent / threshold) * threshold;
end

function CombatAudioAlertManagerMixin:GetUnitFormattedHealthCVarVal(unit)
	if unit == "player" then
		return CombatAudioAlertUtil.GetCAACvarValueNumber("PLAYER_HEALTH_FMT_CVAR");
	elseif unit == "target" then
		return CombatAudioAlertUtil.GetCAACvarValueNumber("TARGET_HEALTH_FMT_CVAR");
	else
		error("Invalid unit passed to GetUnitFormattedHealthCVarVal")
	end
end

function CombatAudioAlertManagerMixin:GetUnitFormattedHealthString(unit, healthPercent)
	return CombatAudioAlertUtil.GetUnitFormattedHealthString(unit, self:GetUnitFormattedHealthCVarVal(unit), healthPercent);
end

function CombatAudioAlertManagerMixin:GetUnitHealthThrottleType(unit)
	if unit == "player" then
		return CombatAudioAlertConstants.ThrottleTypes.PlayerHealth;
	elseif unit == "target" then
		return CombatAudioAlertConstants.ThrottleTypes.TargetHealth;
	else
		error("Invalid unit passed to GetUnitHealthThrottleType")
	end
end

function CombatAudioAlertManagerMixin:GetUnitHealthPercent(unit)
	local health = UnitHealth(unit);
	local healthMax = UnitHealthMax(unit);
	if healthMax == 0 then
		return 0;
	end
	local percent = health / healthMax;
	return percent * 100;
end

function CombatAudioAlertManagerMixin:ProcessUnitHealthChange(unit)
	if not UnitExists(unit) then
		return;
	end

	local healthPercent = math.ceil(self:GetUnitHealthPercent(unit));

	local currentBand = self:GetUnitResourceBand(unit, healthPercent);
	local lastBand = self:GetUnitResourceBand(unit, self.lastUnitHealthPercent[unit]);

	if currentBand ~= lastBand then
		self:TrySpeakText(self:GetUnitHealthThrottleType(unit), self:GetUnitFormattedHealthString(unit, healthPercent));
	end

	self.lastUnitHealthPercent[unit] = healthPercent;
end

function CombatAudioAlertManagerMixin:SpeakText(text)
	--print("Reading "..text.." with voice "..self:GetSelectedVoice());
	C_VoiceChat.SpeakText(
		self:GetSelectedVoice(),
		text,
		self:GetSpeakerSpeed(),
		self:GetSpeakerVolume(),
		CombatAudioAlertConstants.ALLOW_OVERLAPPED_SPEECH
	);
end

function CombatAudioAlertManagerMixin:TrySpeakText(throttleType, text)
	if self:CheckThrottle(throttleType, text) then
		self:SpeakText(text);
	end
end
