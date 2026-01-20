--local CAA_IsEnabled = C_CombatAudioAlert.IsEnabled;
--local CAA_SpeakText = C_CombatAudioAlert.SpeakText;

CombatAudioAlertManagerMixin = {};

function CombatAudioAlertManagerMixin:OnLoad()
	self.lastUnitHealthPercent = {};
	self.lastPlayerPowerPercent = {};
	self.partyHealthInfo = { unitCount = 0, unitInfo = {} };
	self.knownTargetingList = {};

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
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
end

function CombatAudioAlertManagerMixin:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:Init();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:UpdateSpecSpecificSettings();
	elseif event == "PLAYER_IN_COMBAT_CHANGED" then
		local inCombat = ...;
		self:ProcessCombatStateChanged(inCombat);
	elseif event == "UNIT_HEALTH" then
		local unit = ...;
		self:ProcessUnitHealthChange(unit);
	elseif event == "PLAYER_TARGET_CHANGED" then
		self:ProcessTargetChange();
	elseif event == "PLAYER_TARGET_DIED" then
		self:ProcessTargetDied();
	elseif event == "GROUP_ROSTER_UPDATE" then
		self:RefreshAllPartyHealthUnits();
		self:RefreshEvents();
	elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" then
		local _, powerToken = ...;
		self:ProcessPlayerPowerUpdate(powerToken);
	elseif event == "UNIT_DISPLAYPOWER" then
		self:UpdateWatchedPowerTokens();
	elseif event == "UNIT_SPELLCAST_START" then
		local unit, _, spellID = ...;
		self:ProcessCastState(unit, spellID, Enum.CombatAudioAlertCastState.OnCastStart);
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, _, spellID = ...;
		self:ProcessCastState(unit, spellID, Enum.CombatAudioAlertCastState.OnCastEnd);
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
		local _, castGUID = ...;
		self:ProcessTargetCastInterrupted(castGUID);
	elseif event == "UNIT_TARGET" then
		local unit = ...;
		self:ProcessUnitTargetChanged(unit);
	end
end

function CombatAudioAlertManagerMixin:Init(force)
	if force or not self.initDone then
		local isInitYes = true;
		self:RefreshThrottles(isInitYes);
		self:RefreshEvents(isInitYes);
		self.initDone = true;
	end
end

function CombatAudioAlertManagerMixin:RefreshThrottles(isInit)
	if not isInit and not self.initDone then
		return;
	end

	if isInit then
		self.throttles = {
			[Enum.CombatAudioAlertThrottle.Sample] = { duration = C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.Sample), constant = true },
		}
	else
		for _, throttleInfo in pairs(self.throttles) do
			if not throttleInfo.constant and throttleInfo.timer then
				throttleInfo.timer:Cancel();
				throttleInfo.timer = nil;
			end
		end
	end

	self.throttles[Enum.CombatAudioAlertThrottle.PlayerHealth] = { duration = C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.PlayerHealth), queueLastThrottledMessage = true};
	self.throttles[Enum.CombatAudioAlertThrottle.TargetHealth] = { duration = C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.TargetHealth), queueLastThrottledMessage = true};
	self.throttles[Enum.CombatAudioAlertThrottle.PlayerCast] = { duration = C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.PlayerCast)};
	self.throttles[Enum.CombatAudioAlertThrottle.TargetCast] = { duration = C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.TargetCast)};
	self.throttles[Enum.CombatAudioAlertThrottle.PlayerResource1] = { duration = C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.PlayerResource1), queueLastThrottledMessage = true};
	self.throttles[Enum.CombatAudioAlertThrottle.PlayerResource2] = { duration = C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.PlayerResource2), queueLastThrottledMessage = true};
end

function CombatAudioAlertManagerMixin:RefreshEvents(isInit)
	if not isInit and not self.initDone then
		return;
	end

	if not isInit then
		self:UnregisterEvent("PLAYER_IN_COMBAT_CHANGED");
		self:UnregisterEvent("UNIT_HEALTH");
		self:UnregisterEvent("PLAYER_TARGET_DIED");
		self:UnregisterEvent("PLAYER_TARGET_CHANGED");
		self:UnregisterEvent("GROUP_ROSTER_UPDATE");
		self:UnregisterEvent("UNIT_SPELLCAST_START");
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
		self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	end

	if C_CombatAudioAlert.IsEnabled() then
		if self:IsSayCombatStartEnabled() or self:IsSayCombatEndEnabled() then
			self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED");
		end

		self:RegisterForUnitHealth();

		local targetHealthNeeded = self:IsSayTargetHealthEnabled();
		if targetHealthNeeded then
			self:RegisterEvent("PLAYER_TARGET_DIED");
		end

		if targetHealthNeeded or self:IsSayTargetNameEnabled() then
			self:RegisterEvent("PLAYER_TARGET_CHANGED");
		end

		if self:IsSayPartyHealthEnabled() then
			self:RegisterEvent("GROUP_ROSTER_UPDATE");
		else
			self:ClearAllPartyHealthUnits();
		end

		local unitCastStartUnits = {};
		local unitCastEndUnits = {};

		if self:IsCastModeSet("player", Enum.CombatAudioAlertCastState.OnCastStart) then
			table.insert(unitCastStartUnits, "player");
		end

		if self:IsCastModeSet("player", Enum.CombatAudioAlertCastState.OnCastEnd) then
			table.insert(unitCastEndUnits, "player");
		end

		if self:IsCastModeSet("target", Enum.CombatAudioAlertCastState.OnCastStart) or self:IsInterruptCastEnabled() then
			table.insert(unitCastStartUnits, "target");
		end

		if self:IsCastModeSet("target", Enum.CombatAudioAlertCastState.OnCastEnd) then
			table.insert(unitCastEndUnits, "target");
		end

		if #unitCastStartUnits > 0 then
			self:RegisterUnitEvent("UNIT_SPELLCAST_START", unitCastStartUnits);
		end

		if #unitCastEndUnits > 0 then
			self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unitCastEndUnits);
		end

		self.unitCastStartUnitsLookup = CopyValuesAsKeys(unitCastStartUnits);
		self.unitCastEndUnitsLookup = CopyValuesAsKeys(unitCastEndUnits);

		if self:IsInterruptCastSuccessEnabled() then
			self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "target");
		end
	else
		self.unitHealthUnitsLookup = {};
		self.watchedPowerTokens = {};
		self.unitCastStartUnitsLookup = {};
		self.unitCastEndUnitsLookup = {};
		self:ClearAllPartyHealthUnits();
	end

	self:UpdateSpecSpecificSettings(isInit);

	if isInit and C_CombatAudioAlert.IsEnabled() then
		if self:IsInPartyHealthMode() then
			self:RefreshAllPartyHealthUnits();
		else
			self:ProcessUnitHealthChange("player");
		end
	end
end

function CombatAudioAlertManagerMixin:SetSpeakerVoice(newVoiceID)
	newVoiceID = tonumber(newVoiceID);
	local currentVoiceID = tonumber(GetCVar("CAAVoice"));
	if newVoiceID ~= currentVoiceID then
		SetCVar("CAAVoice", newVoiceID);
	else
		self:PlaySample();
	end
end

function CombatAudioAlertManagerMixin:SetSpeakerSpeed(newSpeed)
	newSpeed = tonumber(newSpeed);
	local currentSpeed = C_CombatAudioAlert.GetSpeakerSpeed();
	if newSpeed ~= currentSpeed then
		C_CombatAudioAlert.SetSpeakerSpeed(newSpeed);
	else
		self:PlaySample();
	end
end

function CombatAudioAlertManagerMixin:SetSpeakerVolume(newVolume)
	newVolume = tonumber(newVolume);
	local currentVolume = C_CombatAudioAlert.GetSpeakerVolume();
	if newVolume ~= currentVolume then
		C_CombatAudioAlert.SetSpeakerVolume(newVolume);
	else
		self:PlaySample();
	end
end

function CombatAudioAlertManagerMixin:IsSayCombatStartEnabled()
	return CombatAudioAlertUtil.GetCAACVarValueBool("SAY_COMBAT_START_CVAR");
end

function CombatAudioAlertManagerMixin:IsSayCombatEndEnabled()
	return CombatAudioAlertUtil.GetCAACVarValueBool("SAY_COMBAT_END_CVAR");
end

function CombatAudioAlertManagerMixin:IsSayPlayerHealthEnabled()
	return (CombatAudioAlertUtil.GetCAACvarValueNumber("PLAYER_HEALTH_PCT_CVAR") > 0);
end

function CombatAudioAlertManagerMixin:IsSayTargetNameEnabled()
	return CombatAudioAlertUtil.GetCAACVarValueBool("SAY_TARGET_NAME_CVAR");
end

function CombatAudioAlertManagerMixin:IsSayTargetHealthEnabled()
	return (CombatAudioAlertUtil.GetCAACvarValueNumber("TARGET_HEALTH_PCT_CVAR") > 0);
end

function CombatAudioAlertManagerMixin:ShouldSayTargetHealth()
	if self:IsSayTargetHealthEnabled() then
		if UnitIsFriend("player", "target") and not UnitInParty("target") then
			return (self:GetUnitHealthPercent("target") < 100);
		else
			return true;
		end
	else
		return false;
	end
end

function CombatAudioAlertManagerMixin:GetTargetDeathBehavior()
	return CombatAudioAlertUtil.GetCAACvarValueNumber("TARGET_DEATH_BEHAVIOR_CVAR");
end

function CombatAudioAlertManagerMixin:ShouldReplaceTargetDeathWithVoiceLine()
	return (self:GetTargetDeathBehavior() ~= Enum.CombatAudioAlertTargetDeathBehavior.Default);
end

function CombatAudioAlertManagerMixin:IsSayPartyHealthEnabled()
	return (CombatAudioAlertUtil.GetCAACvarValueNumber("PARTY_HEALTH_PCT_CVAR") > 0);
end

function CombatAudioAlertManagerMixin:GetSayPartyHealthPercent()
	return CombatAudioAlertUtil.GetCurrentPartyHealthPercentInfo().percentVal;
end

function CombatAudioAlertManagerMixin:GetPartyHealthRelativeFrequencySetting()
	return CombatAudioAlertUtil.GetCAACvarValueNumber("PARTY_HEALTH_FREQ_CVAR");
end

-- Calculate relative frequency scale value (from 0.5 to 1.5)
function CombatAudioAlertManagerMixin:GetPartyHealthRelativeFrequencyScalingValue()
	-- Get the party health frequency setting (-10 to 10)
	local relativeFrequency = self:GetPartyHealthRelativeFrequencySetting();
	
	-- Normalize it (0.0 to 1.0)
	local normalizedRelativeFrequency = PercentageBetween(relativeFrequency, Constants.CAAConstants.CAAFrequencyMin, Constants.CAAConstants.CAAFrequencyMax);

	-- Reverse it and scale up (1.5 to 0.5)
	return 1.5 - normalizedRelativeFrequency;
end

function CombatAudioAlertManagerMixin:IsSayPlayerResource1Enabled()
	return (C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource1Percent) > 0);
end

function CombatAudioAlertManagerMixin:IsSayPlayerResource2Enabled()
	return (C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource2Percent) > 0);
end

function CombatAudioAlertManagerMixin:GetSayUnitCastMode(unit)
	if unit == "player" then
		return CombatAudioAlertUtil.GetCAACvarValueNumber("SAY_PLAYER_CAST_CVAR");
	elseif unit == "target" then
		return CombatAudioAlertUtil.GetCAACvarValueNumber("SAY_TARGET_CAST_CVAR");
	else
		error("Invalid unit passed to GetSayUnitCastMode")
	end
end

function CombatAudioAlertManagerMixin:IsCastModeSet(unit, mode)
	return (self:GetSayUnitCastMode(unit) == mode);
end

function CombatAudioAlertManagerMixin:IsInterruptCastEnabled()
	return (CombatAudioAlertUtil.GetCAACvarValueNumber("SAY_INTERRUPT_CAST_CVAR") > 0);
end

function CombatAudioAlertManagerMixin:IsInterruptCastSuccessEnabled()
	return (CombatAudioAlertUtil.GetCAACvarValueNumber("SAY_INTERRUPT_CAST_SUCCESS_CVAR") > 0);
end

function CombatAudioAlertManagerMixin:GetSayIfTargetedMode()
	return C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.SayIfTargeted);
end

function CombatAudioAlertManagerMixin:IsSayIfTargetedEnabled()
	return (self:GetSayIfTargetedMode() > 0);
end

function CombatAudioAlertManagerMixin:IsWatchingUnitHealth(unit)
	return self.unitHealthUnitsLookup[unit] ~= nil;
end

local partyUnits = { "player", "party1", "party2", "party3", "party4" };
local partyUnitLookup = tInvert(partyUnits);

function CombatAudioAlertManagerMixin:GetPartyUnitIndex(unit)
	return partyUnitLookup[unit];
end

function CombatAudioAlertManagerMixin:IsPartyUnit(unit)
	return self:GetPartyUnitIndex(unit) ~= nil;
end

function CombatAudioAlertManagerMixin:IsInPartyHealthMode()
	return self:IsSayPartyHealthEnabled() and UnitInParty("player");
end

function CombatAudioAlertManagerMixin:RegisterForUnitHealth()
	local unitHealthUnits = {};

	if self:IsInPartyHealthMode() then
		for _, unit in ipairs(partyUnits) do
			if UnitExists(unit) then
				table.insert(unitHealthUnits, unit);
			end
		end
	elseif self:IsSayPlayerHealthEnabled() then
		table.insert(unitHealthUnits, "player");
	end

	if self:IsSayTargetHealthEnabled() then
		table.insert(unitHealthUnits, "target");
	end

	local numWatchedUnits = #unitHealthUnits;
	if numWatchedUnits > 0 then
		if numWatchedUnits <= Constants.UnitEventConstants.MAX_UNIT_TOKENS_IN_EVENT then
			self:RegisterUnitEvent("UNIT_HEALTH", unitHealthUnits);
		else
			self:RegisterEvent("UNIT_HEALTH");
		end

		self.unitHealthUnitsLookup = CopyValuesAsKeys(unitHealthUnits);
	else
		self.unitHealthUnitsLookup = {};
	end
end

function CombatAudioAlertManagerMixin:UpdateSpecSpecificSettings(isInit)
	if not isInit and not self.initDone then
		return;
	end

	if not isInit then
		self:UnregisterEvent("UNIT_TARGET");
		self:UnregisterEvent("UNIT_POWER_UPDATE");
		self:UnregisterEvent("UNIT_MAXPOWER");
		self:UnregisterEvent("UNIT_DISPLAYPOWER");
	end

	if C_CombatAudioAlert.IsEnabled() then
		if self:IsSayIfTargetedEnabled() then
			self:RegisterEvent("UNIT_TARGET");
		end

		local playerPowerNeeded = self:IsSayPlayerResource1Enabled() or self:IsSayPlayerResource2Enabled();
		if playerPowerNeeded then
			self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player");
			self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
			self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player");
		end
		self:UpdateWatchedPowerTokens();
	end
end

function CombatAudioAlertManagerMixin:UpdateWatchedPowerTokens()
	self.watchedPowerTokens = {};

	if self:IsSayPlayerResource1Enabled() then
		local powerType, powerToken = UnitPowerType("player");
		if powerToken then
			self.watchedPowerTokens[powerToken] = powerType;
		end
	end

	if self:IsSayPlayerResource2Enabled() then
		local powerType, powerToken = GetUnitSecondaryPowerInfo("player");
		if powerToken then
			self.watchedPowerTokens[powerToken] = powerType;
		end
	end
end

function CombatAudioAlertManagerMixin:IsWatchingPowerToken(powerToken)
	return self.watchedPowerTokens[powerToken] ~= nil;
end

function CombatAudioAlertManagerMixin:IsWatchingUnitCastState(unit, castState)
	if castState == Enum.CombatAudioAlertCastState.OnCastStart then
		return self.unitCastStartUnitsLookup[unit] ~= nil;
	else
		return self.unitCastEndUnitsLookup[unit] ~= nil;
	end
end

local sampleTextInfo = {throttleType = Enum.CombatAudioAlertThrottle.Sample, text = CAA_SAMPLE_TEXT};

function CombatAudioAlertManagerMixin:PlaySample()
	self:TrySpeakText(sampleTextInfo, CombatAudioAlertConstants.ALLOW_OVERLAP_NO);
end

function CombatAudioAlertManagerMixin:OnThrottleTimerComplete(throttleType)
	local throttleInfo = self.throttles[throttleType];
	if throttleInfo then
		--print("throttle "..throttleType.." complete");
		throttleInfo.timer:Cancel();
		throttleInfo.timer = nil;
		if throttleInfo.throttleDoneText then
			--print("speaking text "..throttleInfo.throttleDoneText);
			C_CombatAudioAlert.SpeakText(throttleInfo.throttleDoneText);

			-- We just called SpeakText so start a new throttle timer right away (with no throttleDoneText)
			throttleInfo.throttleDoneText = nil;
			throttleInfo.timer = C_Timer.NewTimer(throttleInfo.duration, function() self:OnThrottleTimerComplete(throttleType) end);
		end
		--print("----------");
	end
end

function CombatAudioAlertManagerMixin:CheckThrottle(textInfo)
	--print("check throttle "..textInfo.throttleType.." text = "..textInfo.text);
	local throttleInfo = self.throttles[textInfo.throttleType];
	if throttleInfo then
		if throttleInfo.timer then
			--print("throttled "..(throttleInfo.queueLastThrottledMessage and " throttleDoneText set" or ""));
			if throttleInfo.queueLastThrottledMessage then
				throttleInfo.throttleDoneText = textInfo.text;
			end
			--print("----------");
			return false;
		else
			--print("no throttle");
			if throttleInfo.duration > 0 then
				--print("throttle created duration = "..throttleInfo.duration);
				throttleInfo.timer = C_Timer.NewTimer(throttleInfo.duration, function() self:OnThrottleTimerComplete(textInfo.throttleType) end);
			end
			--print("----------");
			return true;
		end
	else
		error("Invalid throttleType passed to CheckThrottle")
	end
end

function CombatAudioAlertManagerMixin:GetPercentageBand(percent, threshold)
	if not percent or not threshold then
		return nil;
	end

	if threshold == 0 then
		return 0;
	end

	return math.floor(percent / threshold) * threshold;
end

function CombatAudioAlertManagerMixin:GetUnitHealthThreshold(unit)
	if unit == "player" then
		return CombatAudioAlertUtil.GetCAACvarValueNumber("PLAYER_HEALTH_PCT_CVAR") * 10;
	elseif unit == "target" then
		return CombatAudioAlertUtil.GetCAACvarValueNumber("TARGET_HEALTH_PCT_CVAR") * 10;
	else
		error("Invalid unit passed to GetUnitHealthThreshold")
	end
end

function CombatAudioAlertManagerMixin:GetUnitHealthBand(unit, healthPercent)
	local threshold = self:GetUnitHealthThreshold(unit);
	return self:GetPercentageBand(healthPercent, threshold);
end

function CombatAudioAlertManagerMixin:GetUnitFormattedHealthString(unit, healthPercent)
	local text;
	if unit == "target" and self:ShouldConsiderUnitDead("target") and self:ShouldReplaceTargetDeathWithVoiceLine() then
		return CAA_TARGET_DEAD;
	else
		return CombatAudioAlertUtil.GetUnitFormattedString(unit, Enum.CombatAudioAlertType.Health, nil, healthPercent);
	end
end

function CombatAudioAlertManagerMixin:GetCurrentHealthText(unit)
	local healthPercent = self:GetUnitHealthPercent(unit);
	return self:GetUnitFormattedHealthString(unit, healthPercent);
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
	return {throttleType = CombatAudioAlertUtil.GetUnitThrottleType(unit, Enum.CombatAudioAlertType.Health), text = self:GetUnitFormattedHealthString(unit, healthPercent)};
end

function CombatAudioAlertManagerMixin:ShouldConsiderUnitHealth(unit)
	return UnitExists(unit) and UnitIsConnected(unit);
end

function CombatAudioAlertManagerMixin:ShouldConsiderUnitDead(unit)
	return UnitIsDead(unit) or UnitIsGhost(unit);
end

function CombatAudioAlertManagerMixin:ProcessUnitHealthChange(unit)
	if not self:IsWatchingUnitHealth(unit) or not self:ShouldConsiderUnitHealth(unit) then
		return;
	end

	if self:IsInPartyHealthMode() and self:IsPartyUnit(unit) then
		self:ProcessPartyUnitHealthChange(unit);
		return;
	end

	local healthPercent = self:GetUnitHealthPercent(unit);

	local currentBand = self:GetUnitHealthBand(unit, healthPercent);
	local lastBand = self:GetUnitHealthBand(unit, self.lastUnitHealthPercent[unit]);

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

	if self:IsSayTargetNameEnabled() then
		finalText = UnitName("target");
	end

	if self:ShouldSayTargetHealth() then
		local healthText = self:GetCurrentHealthText("target");
		finalText = (finalText or "")..healthText;
	end

	if finalText then
		C_CombatAudioAlert.SpeakText(finalText);
	end
end

function CombatAudioAlertManagerMixin:ProcessTargetDied()
	if self:ShouldSayTargetHealth() then
		C_CombatAudioAlert.SpeakText(self:GetCurrentHealthText("target"));
	end
end

function CombatAudioAlertManagerMixin:ProcessCombatStateChanged(isInCombat)
	if isInCombat then
		if self:IsSayCombatStartEnabled() then
			C_CombatAudioAlert.SpeakText(CAA_COMBAT_START_TEXT);
		end
	else
		if self:IsSayCombatEndEnabled() then
			C_CombatAudioAlert.SpeakText(CAA_COMBAT_END_TEXT);
		end
	end
end

function CombatAudioAlertManagerMixin:GetPartyHealthFrequencyMinAndMax()
	-- Get scaling value, based off the player's current relateive frequency setting (0.5 to 1.5)
	local scaleValue = self:GetPartyHealthRelativeFrequencyScalingValue();
	
	-- Apply scaling to both min and max values
	local scaledMinSeconds = CombatAudioAlertConstants.PARTY_HEALTH_UPDATE_MIN_SECONDS * scaleValue;
	local scaledMaxSeconds = CombatAudioAlertConstants.PARTY_HEALTH_UPDATE_MAX_SECONDS * scaleValue;
	
	return scaledMinSeconds, scaledMaxSeconds;
end

function CombatAudioAlertManagerMixin:GetPartyHealthUpdateFrequency(healthPercent)
	local unscaledHealthPercent = healthPercent / 100;

	-- Get the min and max frequency
	local minFrequency, maxFrequency = self:GetPartyHealthFrequencyMinAndMax();

	-- Return a value between those 2 values, scaled by unscaledHealthPercent  
	return Lerp(minFrequency, maxFrequency, unscaledHealthPercent);
end

function CombatAudioAlertManagerMixin:ProcessPartyUnitHealthChange(unit)
	local healthPercent = self:GetUnitHealthPercent(unit);

	--print("Processing "..unit.." health: "..healthPercent.." dead: "..(UnitIsDead(unit) and "true" or "false").." ghost: "..(UnitIsGhost(unit) and "true" or "false"));

	if not self:ShouldConsiderUnitDead(unit) and healthPercent < self:GetSayPartyHealthPercent() then
		self:UpdatePartyHealthUnit(unit, healthPercent);
	else
		self:RemovePartyHealthUnitIfNeeded(unit);
	end

	if self.partyHealthInfo.unitCount > 0 then
		self:SetScript("OnUpdate", self.OnUpdate);
	else
		self:SetScript("OnUpdate", nil);
	end

	self.lastUnitHealthPercent[unit] = healthPercent;
end

function CombatAudioAlertManagerMixin:OnUpdate(elapsed)
	for unit, unitInfo in pairs(self.partyHealthInfo.unitInfo) do
		unitInfo.updateAfter = unitInfo.updateAfter - elapsed;
		if unitInfo.updateAfter <= 0 then
			C_CombatAudioAlert.SpeakText(unitInfo.partyIndex);
			unitInfo.updateAfter = unitInfo.updateAfter + unitInfo.frequency;
			--print("Announcing "..unit.." with unit index "..unitInfo.partyIndex);
		end
	end
end

function CombatAudioAlertManagerMixin:UpdatePartyHealthUnit(unit, healthPercent)
	local frequency = self:GetPartyHealthUpdateFrequency(healthPercent);

	if not self.partyHealthInfo.unitInfo[unit] then
		-- First update for this unit, increment unitCount and initialize unitInfo table
		self.partyHealthInfo.unitCount = self.partyHealthInfo.unitCount + 1;
		self.partyHealthInfo.unitInfo[unit] = { partyIndex = self:GetPartyUnitIndex(unit), updateAfter = frequency, frequency = frequency };
		--print("Setting update for "..unit.." to announce every "..frequency.." secs");
	else
		-- This unit was already getting updates, adjust updateAfter and frequency
		local frequencyDelta = frequency - self.partyHealthInfo.unitInfo[unit].frequency;
		self.partyHealthInfo.unitInfo[unit].updateAfter = self.partyHealthInfo.unitInfo[unit].updateAfter + frequencyDelta;
		self.partyHealthInfo.unitInfo[unit].frequency = frequency;
		--print("Adjusted update for "..unit.." to announce every "..frequency.." secs");
	end
end

function CombatAudioAlertManagerMixin:RemovePartyHealthUnitIfNeeded(unit)
	if self.partyHealthInfo.unitInfo[unit] then
		self.partyHealthInfo.unitCount = self.partyHealthInfo.unitCount - 1;
		self.partyHealthInfo.unitInfo[unit] = nil;
	end
end

function CombatAudioAlertManagerMixin:ClearAllPartyHealthUnits()
	self:SetScript("OnUpdate", nil);
	self.partyHealthInfo.unitCount = 0;
	self.partyHealthInfo.unitInfo = {};
end

function CombatAudioAlertManagerMixin:RefreshAllPartyHealthUnits()
	--print("RefreshAllPartyHealthUnits");
	self:ClearAllPartyHealthUnits();
	if UnitInParty("player") then
		for _, unit in ipairs(partyUnits) do
			if self:ShouldConsiderUnitHealth(unit) then
				--print("Considering "..unit);
				self:ProcessPartyUnitHealthChange(unit);
			end
		end
	end
end

function CombatAudioAlertManagerMixin:GetPlayerPowerThreshold(powerType)
	return CombatAudioAlertUtil.GetResourcePercentCVarVal(powerType) * 10;
end

function CombatAudioAlertManagerMixin:GetPlayerPowerBand(powerType, powerPercent)
	local threshold = self:GetPlayerPowerThreshold(powerType);
	return self:GetPercentageBand(powerPercent, threshold);
end

function CombatAudioAlertManagerMixin:GetFormattedResourceString(powerToken, powerPercent)
	return CombatAudioAlertUtil.GetPlayerResourceFormattedString(powerToken, _G[powerToken], powerPercent);
end

function CombatAudioAlertManagerMixin:GetPlayerPowerPercent(powerType)
	local power = UnitPower("player", powerType);
	local powerMax = UnitPowerMax("player", powerType);
	if powerMax == 0 then
		return 0;
	end
	return math.ceil((power / powerMax) * 100);
end

function CombatAudioAlertManagerMixin:GetPlayerResourceTextInfo(powerToken, powerPercent)
	return {throttleType = CombatAudioAlertUtil.GetResourceThrottleType(powerToken), text = self:GetFormattedResourceString(powerToken, powerPercent)};
end

function CombatAudioAlertManagerMixin:ProcessPlayerPowerUpdate(powerToken)
	if not self:IsWatchingPowerToken(powerToken) then
		return;
	end

	local powerType = self.watchedPowerTokens[powerToken];
	local powerPercent = self:GetPlayerPowerPercent(powerType);

	local currentBand = self:GetPlayerPowerBand(powerType, powerPercent);
	local lastBand = self:GetPlayerPowerBand(powerType, self.lastPlayerPowerPercent[powerType]);

	if currentBand ~= lastBand then
		self:TrySpeakText(self:GetPlayerResourceTextInfo(powerToken, powerPercent));
	end

	self.lastPlayerPowerPercent[powerType] = powerPercent;
end

function CombatAudioAlertManagerMixin:GetUnitFormattedCastString(unit, spellName)
	return CombatAudioAlertUtil.GetUnitFormattedString(unit, Enum.CombatAudioAlertType.Cast, spellName);
end

function CombatAudioAlertManagerMixin:GetUnitCastTextInfo(unit, spellName)
	return {throttleType = CombatAudioAlertUtil.GetUnitThrottleType(unit, Enum.CombatAudioAlertType.Cast), text = self:GetUnitFormattedCastString(unit, spellName)};
end

function CombatAudioAlertManagerMixin:GetUnitMinCastTime(unit)
	if unit == "player" then
		return CombatAudioAlertUtil.GetCAACvarValueNumber("SAY_PLAYER_CAST_MIN_TIME_CVAR");
	elseif unit == "target" then
		return CombatAudioAlertUtil.GetCAACvarValueNumber("SAY_TARGET_CAST_MIN_TIME_CVAR");
	else
		error("Invalid unit passed to GetUnitMinCastTime")
	end
end

function CombatAudioAlertManagerMixin:CheckUnitCastTime(unit, spellInfo)
	local castTimeSeconds = spellInfo.castTime / 1000;
	return castTimeSeconds > self:GetUnitMinCastTime(unit);
end

function CombatAudioAlertManagerMixin:ProcessCastState(unit, spellID, castState)
	if not self:IsWatchingUnitCastState(unit, castState) then
		return;
	end

	local spellInfo = C_Spell.GetSpellInfo(spellID);
	if not spellInfo then
		return;
	end

	local shouldCheckInterrupt = (unit == "target") and (castState == Enum.CombatAudioAlertCastState.OnCastStart) and self:IsInterruptCastEnabled();
	if shouldCheckInterrupt then
		local interruptible = not (select(8, UnitCastingInfo(unit)));
		if interruptible then
			C_CombatAudioAlert.SpeakText(CAA_INTERRUPTIBLE_CAST_TEXT);
			return;
		end
	end

	if not self:IsCastModeSet(unit, castState) then
		return;
	end

	if self:CheckUnitCastTime(unit, spellInfo) then
		self:TrySpeakText(self:GetUnitCastTextInfo(unit, spellInfo.name));
	end
end

function CombatAudioAlertManagerMixin:ProcessTargetCastInterrupted(castGUID)
	-- sometimes 2 interrupt events come down for the same cast
	if castGUID ~= self.lastInterruptedCast then
		C_CombatAudioAlert.SpeakText(CAA_INTERRUPTED_CAST_TEXT);
		self.lastInterruptedCast = castGUID;
	end
end

function CombatAudioAlertManagerMixin:GetUnitFormattedTargetingString(unit)
	local sayIfTargetedMode = self:GetSayIfTargetedMode();

	local text;
	if sayIfTargetedMode == Enum.CombatAudioAlertSayIfTargetedType.Aggro then
		text = CAA_AGGRO_TEXT;
	elseif sayIfTargetedMode == Enum.CombatAudioAlertSayIfTargetedType.Targeted then
		text = CAA_YOURE_TARGETED_TEXT;
	elseif sayIfTargetedMode == Enum.CombatAudioAlertSayIfTargetedType.TargetedBy then
		local unitName = UnitName(unit);
		if unitName then
			text = CAA_TARGETED_BY_TEXT:format(unitName);
		else
			-- Fallback if we can't get the name
			text = CAA_YOURE_TARGETED_TEXT;
		end
	else
		error("Invalid SayIfTargetedMode set")
	end

	return text;
end

function CombatAudioAlertManagerMixin:AddToKnownTargetingList(unit)
	--print("AddToKnownTargetingList : "..unit);
	for knownTargetingUnit in pairs(self.knownTargetingList) do
		if UnitIsUnit(knownTargetingUnit, unit) then
			--print("dupe : "..knownTargetingUnit);
			return false;
		end
	end

	--print("added to knownTargetingList");
	self.knownTargetingList[unit] = true;
	return true;
end

function CombatAudioAlertManagerMixin:RemoveFromKnownTargetingList(unit)
	--print("RemoveFromKnownTargetingList : "..unit);
	for knownTargetingUnit in pairs(self.knownTargetingList) do
		if UnitIsUnit(knownTargetingUnit, unit) then
			--print("found matching unit : "..knownTargetingUnit);
			self.knownTargetingList[knownTargetingUnit] = nil;
			return true;
		end
	end

	--print("didn't find matching unit : "..unit);
	return false;
end

function CombatAudioAlertManagerMixin:ProcessUnitTargetChanged(unit)
	if not self:IsSayIfTargetedEnabled() then
		return;
	end

	if not UnitCanAttack("player", unit) then
		-- If they aren't an attackable ignore them
		return;
	end

	local unitTarget = unit.."target";
	if UnitIsUnit(unitTarget, "player") then
		-- This unit is targeting the player. Check if they are already on the known targeting list
		if self:AddToKnownTargetingList(unit) then
			-- Nope they just started targeting the player, announce it
			C_CombatAudioAlert.SpeakText(self:GetUnitFormattedTargetingString(unit));
		end
	else
		-- This unit is not targeting the player. Check if they are on the known targeting list
		self:RemoveFromKnownTargetingList(unit);
	end
end

function CombatAudioAlertManagerMixin:TrySpeakText(textInfo, allowOverlap)
	if not C_CombatAudioAlert.IsEnabled() then
		return;
	end

	if self:CheckThrottle(textInfo) then
		C_CombatAudioAlert.SpeakText(textInfo.text, allowOverlap);
	end
end
