CombatAudioAlertManagerMixin = {};

function CombatAudioAlertManagerMixin:OnLoad()
	self.lastUnitHealthPercent = {};

	local function CheckRefreshEvents()
		if not SettingsPanel:CheckIsSettingDefaults() then
			self:RefreshEvents();
		end
	end

	local function CheckPlaySample()
		if not SettingsPanel:CheckIsSettingDefaults() then
			self:PlaySample();
		end
	end

	local function CheckRefreshThrottles()
		if not SettingsPanel:CheckIsSettingDefaults() then
			self:RefreshThrottles();
		end
	end

	local function OnSettingsDefaulted(_owner, category)
		if not category or (category.name == ACCESSIBILITY_AUDIO_LABEL) then
			self:RefreshEvents();
			self:RefreshThrottles();
		end
	end

	for _, cvarInfo in pairs(CombatAudioAlertConstants.CVars) do
		CVarCallbackRegistry:SetCVarCachable(cvarInfo.name);

		if cvarInfo.refreshEvents then
			CVarCallbackRegistry:RegisterCallback(cvarInfo.name, CheckRefreshEvents);
		end

		if cvarInfo.playSample then
			CVarCallbackRegistry:RegisterCallback(cvarInfo.name, CheckPlaySample);
		end

		if cvarInfo.refreshThrottles then
			CVarCallbackRegistry:RegisterCallback(cvarInfo.name, CheckRefreshThrottles);
		end
	end

	EventRegistry:RegisterCallback("Settings.Defaulted", OnSettingsDefaulted);
	EventRegistry:RegisterCallback("Settings.CategoryDefaulted", OnSettingsDefaulted);
	self:RegisterEvent("VARIABLES_LOADED");
end

function CombatAudioAlertManagerMixin:OnEvent(event, ...)
	if event == "VARIABLES_LOADED" then
		self:InitThrottles();
		self:InitEvents();
	elseif event == "UNIT_HEALTH" then
		local unit = ...;
		self:ProcessUnitHealthChange(unit);
	elseif event == "PLAYER_TARGET_CHANGED" then
		self:ProcessTargetChange();
	elseif event == "PLAYER_IN_COMBAT_CHANGED" then
		local inCombat = ...;
		self:ProcessCombatStateChanged(inCombat);
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
		self:UnregisterEvent("PLAYER_IN_COMBAT_CHANGED");
	end

	local unitHealthUnits = {};

	if self:IsEnabled() then
		if self:ShouldSayPlayerHealth() then
			table.insert(unitHealthUnits, "player");
		end

		local targetHealthNeeded = self:ShouldSayTargetHealth();
		if targetHealthNeeded then
			table.insert(unitHealthUnits, "target");
		end

		if #unitHealthUnits > 0 then
			self:RegisterUnitEvent("UNIT_HEALTH", unitHealthUnits);
		end

		self.unitHealthUnitsLookup = CopyValuesAsKeys(unitHealthUnits);

		if targetHealthNeeded or self:ShouldSayTargetName() then
			self:RegisterEvent("PLAYER_TARGET_CHANGED");
		end

		if self:ShouldSayCombatStart() or self:ShouldSayCombatEnd() then
			self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED");
		end
	else
		self.unitHealthUnitsLookup = {};
	end

	if isInit then
		for _, unit in ipairs(unitHealthUnits) do
			self:ProcessUnitHealthChange(unit);
		end
	end
end

function CombatAudioAlertManagerMixin:IsEnabled()
	return CombatAudioAlertUtil.GetCAACVarValueBool("ENABLED_CVAR");
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

function CombatAudioAlertManagerMixin:ShouldSayCombatStart()
	return CombatAudioAlertUtil.GetCAACVarValueBool("SAY_COMBAT_START_CVAR");
end

function CombatAudioAlertManagerMixin:ShouldSayCombatEnd()
	return CombatAudioAlertUtil.GetCAACVarValueBool("SAY_COMBAT_END_CVAR");
end

function CombatAudioAlertManagerMixin:ShouldSayPlayerHealth()
	return (CombatAudioAlertUtil.GetCAACvarValueNumber("PLAYER_HEALTH_PCT_CVAR") > 0);
end

function CombatAudioAlertManagerMixin:ShouldSayTargetName()
	return CombatAudioAlertUtil.GetCAACVarValueBool("SAY_TARGET_NAME_CVAR");
end

function CombatAudioAlertManagerMixin:ShouldSayTargetHealth()
	return (CombatAudioAlertUtil.GetCAACvarValueNumber("TARGET_HEALTH_PCT_CVAR") > 0);
end

function CombatAudioAlertManagerMixin:GetTargetDeathBehavior()
	return CombatAudioAlertUtil.GetCAACvarValueNumber("TARGET_DEATH_BEHAVIOR_CVAR");
end

function CombatAudioAlertManagerMixin:ShouldReplaceTargetDeathWithVoiceLine()
	return (self:GetTargetDeathBehavior() ~= Enum.CombatAudioAlertTargetDeathBehavior.Default);
end

function CombatAudioAlertManagerMixin:IsWatchingUnitHealth(unit)
	return self.unitHealthUnitsLookup[unit] ~= nil;
end

local sampleTextInfo = {throttleType = CombatAudioAlertConstants.ThrottleTypes.Sample, text = CAA_SAMPLE_TEXT};

function CombatAudioAlertManagerMixin:PlaySample()
	self:TrySpeakText(sampleTextInfo);
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

function CombatAudioAlertManagerMixin:CheckThrottle(textInfo)
	local throttleInfo = self.throttles[textInfo.throttleType];
	if throttleInfo then
		if throttleInfo.timer then
			--print("throttle "..textInfo.throttleType.." active throttleDoneText set to "..textInfo.text);
			throttleInfo.throttleDoneText = textInfo.text;
			return false;
		else
			if throttleInfo.duration > 0 then
				--print("throttle "..textInfo.throttleType.." inactive, started timer duration = "..throttleInfo.duration);
				throttleInfo.timer = C_Timer.NewTimer(throttleInfo.duration, function() self:OnThrottleTimerComplete(textInfo.throttleType) end);
			end

			return true;
		end
	else
		error("Invalid throttleType passed to CheckThrottle")
	end
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
	local text;
	if unit == "target" and UnitIsDead("target") and self:ShouldReplaceTargetDeathWithVoiceLine() then
		return CAA_TARGET_DEAD;
	else
		return CombatAudioAlertUtil.GetUnitFormattedHealthString(unit, self:GetUnitFormattedHealthCVarVal(unit), healthPercent);
	end
end

function CombatAudioAlertManagerMixin:GetCurrentHealthText(unit)
	local healthPercent = self:GetUnitHealthPercent(unit);
	return self:GetUnitFormattedHealthString(unit, healthPercent);
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
	return math.ceil((health / healthMax) * 100);
end

function CombatAudioAlertManagerMixin:GetUnitHealthTextInfo(unit, healthPercent)
	return {throttleType = self:GetUnitHealthThrottleType(unit), text = self:GetUnitFormattedHealthString(unit, healthPercent)};
end

function CombatAudioAlertManagerMixin:ProcessUnitHealthChange(unit)
	if not self:IsWatchingUnitHealth(unit) or not UnitExists(unit) then
		return;
	end

	local healthPercent = self:GetUnitHealthPercent(unit);

	local currentBand = self:GetUnitResourceBand(unit, healthPercent);
	local lastBand = self:GetUnitResourceBand(unit, self.lastUnitHealthPercent[unit]);

	if currentBand ~= lastBand then
		self:TrySpeakText(self:GetUnitHealthTextInfo(unit, healthPercent));
	end

	self.lastUnitHealthPercent[unit] = healthPercent;
end

function CombatAudioAlertManagerMixin:ProcessTargetChange()
	if not UnitExists("target") then
		return;
	end

	local finalText;

	if self:ShouldSayTargetName() then
		finalText = UnitName("target");
	end

	if self:ShouldSayTargetHealth() then
		local healthText = self:GetCurrentHealthText("target");
		finalText = (finalText or "")..healthText;
	end

	if finalText then
		self:SpeakText(finalText);
	end
end

function CombatAudioAlertManagerMixin:ProcessCombatStateChanged(isInCombat)
	if isInCombat then
		if self:ShouldSayCombatStart() then
			self:SpeakText(CAA_COMBAT_START_TEXT);
		end
	else
		if self:ShouldSayCombatEnd() then
			self:SpeakText(CAA_COMBAT_END_TEXT);
		end
	end
end

function CombatAudioAlertManagerMixin:SpeakText(text)
	if not self:IsEnabled() then
		return;
	end

	--print("Reading "..text.." with voice "..self:GetSelectedVoice());
	C_VoiceChat.SpeakText(
		self:GetSelectedVoice(),
		text,
		self:GetSpeakerSpeed(),
		self:GetSpeakerVolume(),
		CombatAudioAlertConstants.ALLOW_OVERLAPPED_SPEECH
	);
end

function CombatAudioAlertManagerMixin:TrySpeakText(textInfo)
	if not self:IsEnabled() then
		return;
	end

	if self:CheckThrottle(textInfo) then
		self:SpeakText(textInfo.text);
	end
end
