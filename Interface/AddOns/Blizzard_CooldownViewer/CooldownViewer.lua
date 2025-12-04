local function IsSpellOnGCD(spellID, spellCooldownInfo)
	-- Get cooldown information for the dummy GCD spell (ID 61304)
	local gcdInfo = C_Spell.GetSpellCooldown(61304);

	-- Return false if the spell is not on cooldown at all
	if gcdInfo and spellCooldownInfo.duration ~= 0 then
		-- Compare the current cooldown state of the spell with the current GCD state
		-- If the spell's cooldown is the same as the GCD's, and both are active,
		-- then the spell is currently on the GCD.
		if spellCooldownInfo.startTime == gcdInfo.startTime and spellCooldownInfo.duration == gcdInfo.duration then
			return true;
		end
	end

	return false;
end

debugSpells = {};
local function IsDebugSpell(spellID)
	if debugSpells[spellID] then
		return true;
	end

	return false;
end

local function LogCooldown(spellID, functionName, fmt, ...)
	if IsDebugSpell(spellID) then
		local msg = fmt:format(...);
		print(("%.2f [%d]: %s : %s"):format(GetTime(), spellID, functionName, msg));
	end
end

local function CheckDisplayCooldownState(functionName, cooldownItem)
	LogCooldown(cooldownItem:GetSpellID(), functionName, "isOnGCD: %s, isEnabled: %s, allowAvailableAlert: %s allowOnCDAlert: %s",
		tostring(cooldownItem.isOnGCD), tostring(cooldownItem.cooldownEnabled),
		tostring(cooldownItem.allowAvailableAlert), tostring(cooldownItem.allowOnCooldownAlert));
end

local function CheckDisplayCooldownInfo(functionName, spellID, cachedInfo)
	if IsDebugSpell(spellID) then
		local isOnGCD = IsSpellOnGCD(spellID, cachedInfo);

		LogCooldown(spellID, functionName, "ST: %.4f, Dur: %.4f, Enabled: %s, Mod: %.4f, Cat: %s, Recovery: %.4f, structOnGCD: %s, hackOnGCD: %s",
			cachedInfo.startTime, cachedInfo.duration, tostring(cachedInfo.isEnabled), cachedInfo.modRate, tostring(cachedInfo.activeCategory),
			(cachedInfo.timeUntilEndOfStartRecovery or 0), tostring(cachedInfo.isOnGCD), tostring(isOnGCD));

		local cdInfo = C_Spell.GetSpellCooldown(spellID);
		assertsafe(cdInfo == cachedInfo or tCompare(cachedInfo, cdInfo), "cd info mismatch");
		assertsafe(cachedInfo.isOnGCD == isOnGCD, "GCD hack mismatch");
	end
end

CooldownViewerConstants = {
	ITEM_USABLE_COLOR = CreateColor(1.0, 1.0, 1.0, 1.0);
	ITEM_NOT_ENOUGH_MANA_COLOR = CreateColor(0.5, 0.5, 1.0, 1.0);
	ITEM_NOT_USABLE_COLOR = CreateColor(0.4, 0.4, 0.4, 1.0);
	ITEM_NOT_IN_RANGE_COLOR = CreateColor(0.64, 0.15, 0.15, 1.0);

	ITEM_AURA_COLOR = CreateColor(1, 0.95, 0.57, 0.7);
	ITEM_COOLDOWN_COLOR = CreateColor(0, 0, 0, 0.7);
};

---------------------------------------------------------------------------------------------------
-- Some ways to generate fake data for edit mode if the character doesn't have enough spells to populate it.
local EditModeIconDataProvider = nil;

local function GetEditModeIcon(index)
	if not EditModeIconDataProvider then
		local spellIconsOnly = true;
		EditModeIconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Spellbook, spellIconsOnly);
	end

	return EditModeIconDataProvider:GetIconByIndex(index);
end

local function GetEditModeDuration(index)
	return index * 5;
end

local function GetEditModeElapsedTime(index)
	-- Just to give the different items within a category different values.
	if index % 2 == 1 then
		return index * 4;
	end

	return index * 2;
end

---------------------------------------------------------------------------------------------------
-- Base Mixin for all Cooldown Viewer items.
CooldownViewerItemMixin = CreateFromMixins(CooldownViewerItemDataMixin);

function CooldownViewerItemMixin:OnUpdate(_elapsed, timeNow)
	if self:ShouldTriggerAvailableAlert(timeNow) then
		self:TriggerAvailableAlert();
	end

	if self:ShouldTriggerPandemicAlert(timeNow) then
		self:TriggerPandemicAlert(timeNow);
	end

	self:CheckPandemicTimeDisplay(timeNow);

	if self:ShouldTriggerChargeGainedAlert(timeNow) then
		self:TriggerChargeGainedAlert();
	end
end

function CooldownViewerItemMixin:GetCooldownFrame()
	return self.Cooldown;
end

function CooldownViewerItemMixin:GetIconTexture()
	return self.Icon;
end

function CooldownViewerItemMixin:OnLoad()
	self:RefreshActive();

	local cooldownFrame = self:GetCooldownFrame();
	if cooldownFrame and self.cooldownFont then
		cooldownFrame:SetCountdownFont(self.cooldownFont);
	end
end

function CooldownViewerItemMixin:SetViewerFrame(viewerFrame)
	self.viewerFrame = viewerFrame;
end

function CooldownViewerItemMixin:GetViewerFrame()
	return self.viewerFrame;
end

function CooldownViewerItemMixin:SetIsEditing(isEditing)
	self.isEditing = isEditing;
	self:UpdateShownState();
end

function CooldownViewerItemMixin:IsEditing()
	return self.isEditing;
end

function CooldownViewerItemMixin:SetEditModeData(index)
	self.editModeIndex = index;
	self:RefreshData();
end

function CooldownViewerItemMixin:HasEditModeData()
	return self.editModeIndex ~= nil;
end

function CooldownViewerItemMixin:ClearEditModeData()
	if not self:HasEditModeData() then
		return;
	end

	self.editModeIndex = nil;
	self:RefreshData();
end

function CooldownViewerItemMixin:OnCooldownViewerSpellOverrideUpdatedEvent(baseSpellID, overrideSpellID)
	-- Any time an override is added or removed the item needs to be synchronously updated so
	-- it correctly responds to unique events happening later in the frame. To reduce redunant work
	-- the whole RefreshData isn't done until a unique event is received.
	if baseSpellID ~= self:GetBaseSpellID() then
		return;
	end

	self:SetOverrideSpell(overrideSpellID);
	self:RefreshData();
end

function CooldownViewerItemMixin:OnSpellUpdateCooldownEvent(spellID, baseSpellID, startRecoveryCategory)
	if self:NeedsCooldownUpdate(spellID, baseSpellID, startRecoveryCategory) then
		self:RefreshData();
	end
end

function CooldownViewerItemMixin:OnUnitAuraRemovedEvent()
	if self:GetAuraSpellID() == self:GetLinkedSpell() then
		self:SetLinkedSpell(nil);
	end

	self:ClearAuraInstanceInfo();
	self:RefreshData();
end

function CooldownViewerItemMixin:OnUnitAuraUpdatedEvent()
	self:RefreshData();
end

function CooldownViewerItemMixin:OnUnitAuraAddedEvent(unitAuraUpdateInfo)
	-- If an aura was added and its spell matches the base, override, or a linked spell then the item needs to be refreshed.
	for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
		if self:NeedsAddedAuraUpdate(aura.spellId) then
			self:RefreshData();
			break;
		end
	end
end

function CooldownViewerItemMixin:OnPlayerTotemUpdateEvent(slot, name, startTime, duration, modRate, spellID)
	if not self:NeedsTotemUpdate(slot, spellID) then
		return;
	end

	if duration == 0 then
		self:ClearTotemData();
	else
		self:SetTotemData({
			slot = slot,
			expirationTime = startTime + duration,
			duration = duration,
			name = name,
			modRate = modRate;
		});
	end

	self:RefreshData();
end

function CooldownViewerItemMixin:GetFallbackSpellTexture()
	if self:HasEditModeData() then
		return GetEditModeIcon(self.editModeIndex);
	end

	return nil;
end

function CooldownViewerItemMixin:RefreshActive()
	self:SetIsActive(self:ShouldBeActive());
end

function CooldownViewerItemMixin:RefreshSpellTexture()
	local spellTexture = self:GetSpellTexture();
	self:GetIconTexture():SetTexture(spellTexture);
end

function CooldownViewerItemMixin:RefreshAuraInstance()
	local auraData = self:GetAuraData();
	if auraData then
		self:SetAuraInstanceInfo(auraData);
	else
		self:ClearAuraInstanceInfo();
	end
end

function CooldownViewerItemMixin:OnAuraInstanceInfoSet(_auraSpellID, auraInstanceID)
	if self.viewerFrame then
		self.viewerFrame:RegisterAuraInstanceIDItemFrame(auraInstanceID, self);
	end
end

function CooldownViewerItemMixin:OnAuraInstanceInfoCleared(_auraSpellID, auraInstanceID)
	if self.viewerFrame then
		self.viewerFrame:UnregisterAuraInstanceIDItemFrame(auraInstanceID, self);
	end
end

function CooldownViewerItemMixin:UpdateTooltip()
	if GameTooltip:IsOwned(self) then
		self:RefreshTooltip();
	end
end

function CooldownViewerItemMixin:SetHideWhenInactive(hideWhenInactive)
	self.hideWhenInactive = hideWhenInactive;
	self:UpdateShownState();
end

function CooldownViewerItemMixin:ShouldBeShown()
	if self:GetCooldownID() then
		if not self.allowHideWhenInactive then
			return true;
		end

		if not self.hideWhenInactive then
			return true;
		end

		if self:IsActive() then
			return true;
		end

		if CooldownViewerSettings:IsVisible() then
			return true;
		end
	end

	if self:IsEditing() then
		return true;
	end

	return false;
end

function CooldownViewerItemMixin:UpdateShownState()
	local shouldBeShown = self:ShouldBeShown();
	self:SetShown(shouldBeShown);
end

function CooldownViewerItemMixin:SetTimerShown(shownSetting)
	local cooldownFrame = self:GetCooldownFrame();
	if cooldownFrame then
		cooldownFrame:SetHideCountdownNumbers(not shownSetting);
	end
end

function CooldownViewerItemMixin:SetTooltipsShown(shownSetting)
	self:SetMouseClickEnabled(false);
	self:SetMouseMotionEnabled(shownSetting);
end

function CooldownViewerItemMixin:IsTimerShown()
	local cooldownFrame = self:GetCooldownFrame();
	if cooldownFrame then
		return not cooldownFrame:GetHideCountdownNumbers();
	end
	return false;
end

function CooldownViewerItemMixin:ShouldBeActive()
	return self.cooldownID ~= nil;
end

function CooldownViewerItemMixin:OnActiveStateChanged()
	self:UpdateShownState();
end

function CooldownViewerItemMixin:SetIsActive(active)
	if active == self.isActive then
		return;
	end

	self.isActive = active;

	self:OnActiveStateChanged();
end

function CooldownViewerItemMixin:IsActive()
	return self.isActive;
end

function CooldownViewerItemMixin:NeedsCooldownUpdate(spellID, baseSpellID, startRecoveryCategory)
	-- A nil spellID indicates all cooldowns should be updated.
	if spellID == nil then
		return true;
	end

	if self:UpdateLinkedSpell(spellID) then
		return true;
	end

	if startRecoveryCategory == Constants.SpellCooldownConsts.GLOBAL_RECOVERY_CATEGORY then
		return true;
	end

	local itemBaseSpellID = self:GetBaseSpellID();

	if spellID == itemBaseSpellID then
		return true;
	end

	-- Depending on the order of overrides being applied and removed, the item may already have a
	-- different override spell than the spell being updated. But if the base spell is the same, the
	-- item should still respond to the event.
	if baseSpellID == itemBaseSpellID then
		return true;
	end

	if spellID == self:GetSpellID() then
		return true;
	end

	-- In rare cases, some spells remove their override before the Update Cooldown Event is sent.
	-- When this happens the event doesn't correctly reference the base spell, so this logic
	-- compensates for that to ensure the event causes a refresh.
	local cooldownInfo = self:GetCooldownInfo();
	if cooldownInfo and spellID == cooldownInfo.previousOverrideSpellID then
		return true;
	end

	return false;
end

function CooldownViewerItemMixin:NeedsAddedAuraUpdate(spellID)
	if self:UpdateLinkedSpell(spellID) then
		return true;
	end

	if spellID == self:GetSpellID() then
		return true;
	end

	return false;
end

function CooldownViewerItemMixin:NeedsTotemUpdate(slot, spellID)
	if self:UpdateLinkedSpell(spellID) then
		return true;
	end

	if spellID == self:GetSpellID() then
		return true;
	end

	-- If a totem is destroyed the totem's spellID may already be set to 0, in which case
	-- it's necessary to use the slot to determine if the update is needed.
	local totemData = self:GetTotemData();
	if spellID == 0 and totemData and totemData.slot == slot then
		return true;
	end

	return false;
end

function CooldownViewerItemMixin:OnCooldownIDSet()
	CooldownViewerItemDataMixin.OnCooldownIDSet(self);
	self:RefreshAlerts();
end

function CooldownViewerItemMixin:RefreshAlerts()
	self.alertsByEvent = {};
	local layoutManager = CooldownViewerSettings:GetLayoutManager();
	if layoutManager then
		local alerts = layoutManager:GetAlerts(self:GetCooldownID());
		if alerts then
			for _, alert in ipairs(alerts) do
				local event = CooldownViewerAlert_GetEvent(alert);
				if not self.alertsByEvent[event] then
					self.alertsByEvent[event] = {};
				end
				table.insert(self.alertsByEvent[event], alert);
			end
		end
	end
end

function CooldownViewerItemMixin:TriggerAlertEvent(event)
	if self.alertsByEvent then
		local alerts = self.alertsByEvent[event];
		if alerts then
			local name = self:GetNameText();
			for _, alert in ipairs(alerts) do
				CooldownViewerAlert_PlayAlert(name, alert);
			end
		end
	end
end

function CooldownViewerItemMixin:ShouldTriggerAvailableAlert(timeNow)
	return self.allowAvailableAlert and self.availableAlertTriggerTime and timeNow >= self.availableAlertTriggerTime;
end

function CooldownViewerItemMixin:TriggerAvailableAlert()
	self:TriggerAlertEvent(Enum.CooldownViewerAlertEventType.Available);
	self.allowAvailableAlert = nil;
	self.availableAlertTriggerTime = nil;

	-- Need to refresh the entire button state after the cooldown finishes, this is what simulates the client sending
	-- a final SPELL_UPDATE_COOLDOWN event which is required to update the icon in case it was tracking buffs.
	self:RefreshData();
end

function CooldownViewerItemMixin:CheckSetPandemicAlertTiggerTime(auraData, timeNow)
	auraData = auraData or self:GetAuraData();
	timeNow = timeNow or GetTime();
	local isActive = auraData and (auraData.expirationTime > timeNow);
	if self:GetAuraDataUnit() == "target" and isActive then
		-- If the related spell could be cast again right now, what would the new duration be? This informs the pandemic-time alert.
		local extendedDuration = C_UnitAuras.GetRefreshExtendedDuration("target", auraData.auraInstanceID, self:GetSpellID());
		local baseDuration = C_UnitAuras.GetAuraBaseDuration("target", auraData.auraInstanceID, self:GetSpellID());
		local carriedOverToNewCast = (extendedDuration and baseDuration) and (extendedDuration - baseDuration) or 0;
		local allowPandemicAlert = carriedOverToNewCast > 0 and self:CanTriggerAlertType(Enum.CooldownViewerAlertEventType.PandemicTime);

		if allowPandemicAlert then
			self:SetPandemicAlertTriggerTime(timeNow, auraData.expirationTime - carriedOverToNewCast, auraData.expirationTime);
		end

		LogCooldown(self:GetSpellID(), "CheckSetPandemicAlertTiggerTime:Pandemic", "Start: %.2f, Duration: %.2f, active: %s, extended: %.2f", (auraData.expirationTime - auraData.duration) , auraData.duration, tostring(isActive), (extendedDuration or 0));

		return allowPandemicAlert;
	end

	return false;
end

function CooldownViewerItemMixin:SetPandemicAlertTriggerTime(timeNow, pandemicStartTime, pandemicEndTime)
	self.pandemicAlertTriggerTime = pandemicStartTime;
	self.pandemicStartTime = pandemicStartTime;
	self.pandemicEndTime = pandemicEndTime;

	LogCooldown(self:GetSpellID(), "SetPandemicAlertTriggerTime", "PStart: %.2f, PEnd: %.2f, nextAvailable: %.2f", (pandemicStartTime or 0), (pandemicEndTime or 0), (self.nextAvailableTimeToPlayPandemicAlert or 0));

	self:CheckPandemicTimeDisplay(timeNow);
end

function CooldownViewerItemMixin:GetPandemicAlertTriggerTime()
	return self.pandemicAlertTriggerTime;
end

function CooldownViewerItemMixin:ShouldTriggerPandemicAlert(timeNow)
	return self.pandemicAlertTriggerTime and timeNow >= self.pandemicAlertTriggerTime and (not self.nextAvailableTimeToPlayPandemicAlert or timeNow >= self.nextAvailableTimeToPlayPandemicAlert);
end

function CooldownViewerItemMixin:TriggerPandemicAlert()
	assertsafe(self.pandemicEndTime, "PandemicTime alert should not be triggered unless the CDItem [%d] has a valid pandemic end time.", (self:GetCooldownID() or 0));
	self.pandemicAlertTriggerTime = nil; -- Just clear the alert state once it plays
	self.nextAvailableTimeToPlayPandemicAlert = self.pandemicEndTime; -- Prevent the alert from playing again for this instance in case target changes
	self:TriggerAlertEvent(Enum.CooldownViewerAlertEventType.PandemicTime);

	-- NOTE: No need to refresh anything after the alert fires because the visual state of the button should remain in pandemic until the aura is removed.
	LogCooldown(self:GetSpellID(), "TriggerPandemicAlert", "Displaying pandemic state for %s", self:GetNameText());
end

function CooldownViewerItemMixin:CheckPandemicTimeDisplay(timeNow)
	if self:IsInPandemicTime(timeNow) then
		self:ShowPandemicStateFrame();
	else
		self:HidePandemicStateFrame();
	end
end

function CooldownViewerItemMixin:ShowPandemicStateFrame()
	if not self.PandemicIcon then
		self.PandemicIcon = self:GetViewerFrame():SetupPandemicStateFrameForItem(self);
	end

	self.PandemicIcon:Show();
end

function CooldownViewerItemMixin:HidePandemicStateFrame()
	if self.PandemicIcon then
		self:GetViewerFrame():HidePandemicStateFrame(self.PandemicIcon);
		self.PandemicIcon = nil;
	end
end

function CooldownViewerItemMixin:IsInPandemicTime(timeNow)
	return self.pandemicStartTime and timeNow >= self.pandemicStartTime and timeNow <= self.pandemicEndTime;
end

function CooldownViewerItemMixin:AddChargeGainedAlertTime(predictedChargeGainTime)
	local chargeTimes = GetOrCreateTableEntry(self, "chargeGainedAlertTimes", {});
	chargeTimes[predictedChargeGainTime] = true;
end

function CooldownViewerItemMixin:ShouldTriggerChargeGainedAlert(timeNow)
	if self.chargeGainedAlertTimes then
		for chargeTime in pairs(self.chargeGainedAlertTimes) do
			if timeNow >= chargeTime then
				self.chargeGainedAlertTimes[chargeTime] = nil;
				return true;
			end
		end
	end
end

function CooldownViewerItemMixin:TriggerChargeGainedAlert()
	self:TriggerAlertEvent(Enum.CooldownViewerAlertEventType.ChargeGained);
end

function CooldownViewerItemMixin:OnNewTarget()
	-- This is the first thing that should happen when handling a target switch
	-- Clear out all state data that was built while a previous target existed.
	self:SetIsActive(false); -- Force the frame back to an inactive state so that the pending update can re-run the refresh logic.
	self:SetPandemicAlertTriggerTime(GetTime(), nil, nil);
end

function CooldownViewerItemMixin:IsUsingVisualDataSource_Spell()
	return self.wasSetFromCharges or self.wasSetFromCooldown or self.wasSetFromAura;
end

function CooldownViewerItemMixin:IsUsingVisualDataSource_Any()
	return self:IsUsingVisualDataSource_Spell() or self.wasSetFromEditMode;
end

function CooldownViewerItemMixin:ClearVisualDataSource()
	self.wasSetFromCharges = false;
	self.wasSetFromCooldown = false;
	self.wasSetFromAura = false;
	self.wasSetFromEditMode = false;
end

function CooldownViewerItemMixin:AddVisualDataSource_Charges()
	self.wasSetFromCharges = true;
end

function CooldownViewerItemMixin:HasVisualDataSource_Charges()
	return self.wasSetFromCharges;
end

function CooldownViewerItemMixin:AddVisualDataSource_Cooldown()
	self.wasSetFromCooldown = true;
end

function CooldownViewerItemMixin:AddVisualDataSource_Aura()
	self.wasSetFromAura = true;
end

function CooldownViewerItemMixin:AddVisualDataSource_EditMode()
	assertsafe(not self:IsUsingVisualDataSource_Spell(), "Cooldown %s shouldn't use edit mode when it was already set from a spell", tostring(self:GetCooldownID()));
	self.wasSetFromEditMode = true;
end

---------------------------------------------------------------------------------------------------
-- Base Mixin for Essential and Utility cooldown items.
CooldownViewerCooldownItemMixin = CreateFromMixins(CooldownViewerItemMixin);

function CooldownViewerCooldownItemMixin:IsActivelyCast()
	-- This indicates that the spell related to the cooldown item can be cast by the player and isn't a proc.
	return true;
end

function CooldownViewerCooldownItemMixin:GetChargeCountFrame()
	return self.ChargeCount;
end

function CooldownViewerCooldownItemMixin:GetCooldownFlashFrame()
	return self.CooldownFlash;
end

function CooldownViewerCooldownItemMixin:GetOutOfRangeTexture()
	return self.OutOfRange;
end

function CooldownViewerCooldownItemMixin:OnLoad()
	CooldownViewerItemMixin.OnLoad(self);

	self:GetCooldownFrame():SetScript("OnCooldownDone", GenerateClosure(self.OnCooldownDone, self));
end

function CooldownViewerCooldownItemMixin:OnCooldownIDSet()
	CooldownViewerItemMixin.OnCooldownIDSet(self);

	self:RefreshOverlayGlow();

	local baseSpellID = self:GetBaseSpellID();
	self.needsRangeCheck = baseSpellID and C_Spell.SpellHasRange(baseSpellID);
	if self.needsRangeCheck == true then
		self.rangeCheckSpellID = baseSpellID;
		C_Spell.EnableSpellRangeCheck(self.rangeCheckSpellID, true);
		self.spellOutOfRange = C_Spell.IsSpellInRange(self.rangeCheckSpellID) == false;
		self:RegisterEvent("SPELL_RANGE_CHECK_UPDATE");
		self:RefreshIconColor();
	end
end

function CooldownViewerCooldownItemMixin:OnCooldownIDCleared()
	CooldownViewerItemMixin.OnCooldownIDCleared(self);

	ActionButtonSpellAlertManager:HideAlert(self);

	if self.needsRangeCheck == true then
		C_Spell.EnableSpellRangeCheck(self.rangeCheckSpellID, false);
		self:UnregisterEvent("SPELL_RANGE_CHECK_UPDATE");
		self.rangeCheckSpellID = nil;
		self.spellOutOfRange = nil;
	end
end

function CooldownViewerCooldownItemMixin:OnCooldownDone()
	-- No external event is dispatched when a totem finishes, but if the totem duration was shorter
	-- than the spell's cooldown, the item should immediately start displaying the cooldown.
	local totemData = self:GetTotemData();
	if totemData and totemData.expirationTime < GetTime() then
		self:ClearTotemData();
		self:RefreshData();
	else
		self:RefreshIconDesaturation();
	end

	CheckDisplayCooldownState("OnCooldownDone", self);
end

function CooldownViewerCooldownItemMixin:OnSpellActivationOverlayGlowShowEvent(spellID)
	if not self:NeedSpellActivationUpdate(spellID) then
		return;
	end

	ActionButtonSpellAlertManager:ShowAlert(self);
end

function CooldownViewerCooldownItemMixin:OnSpellActivationOverlayGlowHideEvent(spellID)
	if not self:NeedSpellActivationUpdate(spellID) then
		return;
	end

	ActionButtonSpellAlertManager:HideAlert(self);
end

function CooldownViewerCooldownItemMixin:OnSpellUpdateUsesEvent(spellID, baseSpellID)
	if not self:NeedSpellUseUpdate(spellID, baseSpellID) then
		return;
	end

	self:RefreshSpellChargeInfo();
end

function CooldownViewerCooldownItemMixin:OnSpellUpdateUsableEvent()
	self:RefreshIconColor();
end

function CooldownViewerCooldownItemMixin:OnSpellRangeCheckUpdateEvent(spellID, inRange, checksRange)
	if not self:NeedsSpellRangeUpdate(spellID) then
		return;
	end

	self.spellOutOfRange = checksRange == true and inRange == false;
	self:RefreshIconColor();
end

function CooldownViewerCooldownItemMixin:NeedSpellActivationUpdate(spellID)
	if spellID == self:GetSpellID() then
		return true;
	end

	return false;
end

function CooldownViewerCooldownItemMixin:NeedSpellUseUpdate(spellID, baseSpellID)
	if spellID == self:GetSpellID() then
		return true;
	end

	if baseSpellID and baseSpellID == self:GetBaseSpellID() then
		return true;
	end

	return false;
end

function CooldownViewerCooldownItemMixin:NeedsSpellRangeUpdate(spellID)
	if spellID == self.rangeCheckSpellID then
		return true;
	end

	return false;
end

function CooldownViewerCooldownItemMixin:CheckCacheCooldownValuesFromAura(timeNow)
	-- If the spell results in a self buff, give those values precedence over the spell's cooldown until the buff is gone.
	if self:CanUseAuraForCooldown() then
		local totemData = self:GetTotemData();
		if totemData then
			self:AddVisualDataSource_Aura();
			self.cooldownEnabled = true;
			self.cooldownStartTime = totemData.expirationTime - totemData.duration;
			self.cooldownDuration = totemData.duration;
			self.cooldownModRate = totemData.modRate;
			self.cooldownSwipeColor = CooldownViewerConstants.ITEM_AURA_COLOR;
			self.cooldownDesaturated = false;
			self.cooldownShowDrawEdge = false;
			self.cooldownShowSwipe = true;
			self.cooldownUseAuraDisplayTime = true;
			self.cooldownPlayFlash = false;
			self.cooldownPaused = false;
			return; -- Early return because totems take precedence and we can avoid aura lookup
		end

		local auraData = self:GetAuraData();
		if auraData then
			-- NOTE: Auras are in a priority class where we want to show their cooldown info, but keep the charge count display, but not the charge cooldown display.
			-- This is why auras don't check to see if HasVisualDataSource_Charges is true, but it means that the charge radial swipe will not display.
			self:AddVisualDataSource_Aura();
			self.cooldownEnabled = true;
			self.cooldownStartTime = auraData.expirationTime - auraData.duration;
			self.cooldownDuration = auraData.duration;
			self.cooldownModRate = auraData.timeMod;
			self.cooldownSwipeColor = CooldownViewerConstants.ITEM_AURA_COLOR;
			self.cooldownShowDrawEdge = false;
			self.cooldownShowSwipe = true;
			self.cooldownUseAuraDisplayTime = true;
			self.cooldownPlayFlash = false;
			self.cooldownPaused = false;

			-- This may have already been set by CheckCacheCooldownValuesFromSpellCooldown
			if not self:IsActivelyCast() or self:GetAuraDataUnit() == "player" then
				self.cooldownDesaturated = false;
			end

			if self:CheckSetPandemicAlertTiggerTime(auraData, timeNow) then
				self.cooldownUseAuraDisplayTime = false;
			end
		end
	end
end

function CooldownViewerCooldownItemMixin:CheckCacheCooldownValuesFromCharges(timeNow)
	local spellChargeInfo = self:GetSpellChargeInfo();
	local displayChargeCooldown = spellChargeInfo and (spellChargeInfo.cooldownStartTime or 0) > 0 and (spellChargeInfo.currentCharges or 0) > 0;

	-- If the spell has multiple charges, give those values precedence over the spell's cooldown until the charges are spent.
	if displayChargeCooldown then
		self:AddVisualDataSource_Charges();
		self.cooldownEnabled = true;
		self.cooldownStartTime = spellChargeInfo.cooldownStartTime;
		self.cooldownDuration = spellChargeInfo.cooldownDuration;
		self.cooldownModRate = spellChargeInfo.chargeModRate;
		self.cooldownSwipeColor = CooldownViewerConstants.ITEM_COOLDOWN_COLOR;
		self.cooldownDesaturated = false;
		self.cooldownShowDrawEdge = true;
		self.cooldownShowSwipe = false;
		self.cooldownUseAuraDisplayTime = false;
		self.cooldownPlayFlash = true;
		self.cooldownPaused = false;

		if spellChargeInfo.cooldownStartTime > 0 and spellChargeInfo.cooldownDuration > 0 and spellChargeInfo.currentCharges < spellChargeInfo.maxCharges then
			local predictedChargeGainTime = spellChargeInfo.cooldownStartTime + spellChargeInfo.cooldownDuration;
			if predictedChargeGainTime > timeNow then
				self:AddChargeGainedAlertTime(predictedChargeGainTime);
			end
		end
	end
end

local wasOnGCDLookup = {};
local function CheckAllowOnCooldown(cdItem, spellID, spellCooldownInfo)
	local wasOnGCD = wasOnGCDLookup[spellID];
	wasOnGCDLookup[spellID] = cdItem.isOnGCD;

	local allowOnCooldownAlert = wasOnGCD and not cdItem.isOnGCD and spellCooldownInfo.duration > (cdItem.cooldownDuration or 0) and spellCooldownInfo.duration > 0;
	return allowOnCooldownAlert;
end

function CooldownViewerCooldownItemMixin:CheckCacheCooldownValuesFromSpellCooldown(timeNow)
	local spellID = self:GetSpellID();
	local spellCooldownInfo = spellID and C_Spell.GetSpellCooldown(spellID);
	if spellCooldownInfo and not self:HasVisualDataSource_Charges() then
		self:AddVisualDataSource_Cooldown();
		CheckDisplayCooldownInfo("CheckCacheCooldownValuesFromSpellCooldown", spellID, spellCooldownInfo);

		local endTime = spellCooldownInfo.startTime + spellCooldownInfo.duration;
		self.cooldownIsActive = endTime > timeNow;

		self.isOnGCD = spellCooldownInfo.isOnGCD;
		self.isOnActualCooldown = not self.isOnGCD and self.cooldownIsActive;
		self.allowOnCooldownAlert = CheckAllowOnCooldown(self, spellID, spellCooldownInfo);
		self.allowAvailableAlert = self.allowAvailableAlert or (not self.isOnGCD and spellCooldownInfo.duration > 0 and self.cooldownEnabled);
		self.availableAlertTriggerTime = self.allowAvailableAlert and endTime or nil;
		self.cooldownEnabled = spellCooldownInfo.isEnabled;
		self.cooldownStartTime = spellCooldownInfo.startTime;
		self.cooldownDuration = spellCooldownInfo.duration;
		self.cooldownModRate = spellCooldownInfo.modRate;
		self.cooldownSwipeColor = CooldownViewerConstants.ITEM_COOLDOWN_COLOR;
		self.cooldownShowDrawEdge = false;
		self.cooldownShowSwipe = true;
		self.cooldownUseAuraDisplayTime = false;
		self.cooldownPaused = false;
		self.cooldownDesaturated = self.isOnActualCooldown;
		self.cooldownPlayFlash = self.isOnActualCooldown;

		LogCooldown(spellID, "CheckCacheCooldownValuesFromSpellCooldown:ItemData", "Start: %.2f, Duration: %.2f, active: %s", self.cooldownStartTime, self.cooldownDuration, tostring(self.cooldownIsActive));
	end
end

function CooldownViewerCooldownItemMixin:CheckCacheCooldownValuesFromEditMode()
	if self:HasEditModeData() and not self:IsUsingVisualDataSource_Spell() then
		self:AddVisualDataSource_EditMode();
		self.cooldownEnabled = true;
		self.cooldownStartTime = GetTime() - GetEditModeElapsedTime(self.editModeIndex);
		self.cooldownDuration = GetEditModeDuration(self.editModeIndex);
		self.cooldownModRate = 1;
		self.cooldownSwipeColor = CooldownViewerConstants.ITEM_COOLDOWN_COLOR;
		self.cooldownDesaturated = false;
		self.cooldownShowDrawEdge = false;
		self.cooldownShowSwipe = true;
		self.cooldownUseAuraDisplayTime = false;
		self.cooldownPlayFlash = false;
		self.cooldownPaused = true;
	end
end

function CooldownViewerCooldownItemMixin:CacheCooldownValues()
	local timeNow = GetTime();

	-- Cooldowns can be influenced by multiple sources, so check them all
	-- But if any source performed an update, those functions might return early.
	-- The state updates are in "rough" priority order and the call order here actually matters.
	self:CheckCacheCooldownValuesFromCharges(timeNow);
	self:CheckCacheCooldownValuesFromSpellCooldown(timeNow);
	self:CheckCacheCooldownValuesFromAura(timeNow);
	self:CheckCacheCooldownValuesFromEditMode();

	if not self:IsUsingVisualDataSource_Any() then
		self.cooldownEnabled = false;
		self.cooldownStartTime = 0;
		self.cooldownDuration = 0;
		self.cooldownModRate = 1;
		self.cooldownSwipeColor = CooldownViewerConstants.ITEM_COOLDOWN_COLOR;
		self.cooldownDesaturated = false;
		self.cooldownShowDrawEdge = false;
		self.cooldownShowSwipe = false;
		self.cooldownUseAuraDisplayTime = false;
		self.cooldownPlayFlash = false;
		self.cooldownPaused = false;
		self.isOnGCD = false;
		self.cooldownIsActive = false;
		self.allowOnCooldownAlert = false;
		self.isOnActualCooldown = false;
	end
end

function CooldownViewerCooldownItemMixin:CacheChargeValues()
	-- Give precedence to spells set up with explicit charge info that have more than one max charge.
	local spellChargeInfo = self:GetSpellChargeInfo();
	if spellChargeInfo and spellChargeInfo.maxCharges > 1 then
		self.cooldownChargesCount = spellChargeInfo.currentCharges;
		self.cooldownChargesShown = true;
		return;
	end

	-- Some spells are set up to show 'cast count' (also called 'use count') which can have different meanings base on the context of the spell.
	local spellID = self:GetSpellID();
	if spellID then
		self.cooldownChargesCount = C_Spell.GetSpellCastCount(spellID);
		self.cooldownChargesShown = self.cooldownChargesCount > 0;
		return;
	end

	self.cooldownChargesShown = false;
end

function CooldownViewerCooldownItemMixin:IsExpired()
	if self.cooldownStartTime == 0 then
		return true;
	end

	return self.cooldownStartTime + self.cooldownDuration <= GetTime();
end

function CooldownViewerCooldownItemMixin:RefreshSpellCooldownInfo()
	self:CacheCooldownValues();

	local cooldownFrame = self:GetCooldownFrame();
	local isExpired = self:IsExpired();

	if isExpired then
		CooldownFrame_Clear(cooldownFrame);
		cooldownFrame:SetDrawEdge(false);
	else
		cooldownFrame:SetSwipeColor(self.cooldownSwipeColor.r, self.cooldownSwipeColor.g, self.cooldownSwipeColor.b, self.cooldownSwipeColor.a);
		cooldownFrame:SetDrawSwipe(self.cooldownShowSwipe);
		cooldownFrame:SetUseAuraDisplayTime(self.cooldownUseAuraDisplayTime);
		CooldownFrame_Set(cooldownFrame, self.cooldownStartTime, self.cooldownDuration, self.cooldownEnabled, self.cooldownShowDrawEdge, self.cooldownModRate);
	end

	if self.cooldownPaused then
		cooldownFrame:Pause();
	else
		cooldownFrame:Resume();
	end

	local cooldownFlashFrame = self:GetCooldownFlashFrame();
	local playFlash = self.cooldownPlayFlash and not isExpired;

	if playFlash then
		local startDelay = self.cooldownStartTime + self.cooldownDuration - GetTime() - 0.75;

		cooldownFlashFrame:Show();
		cooldownFlashFrame.FlashAnim:Stop();
		cooldownFlashFrame.FlashAnim.ShowAnim:SetStartDelay(startDelay);
		cooldownFlashFrame.FlashAnim.PlayAnim:SetStartDelay(startDelay);
		cooldownFlashFrame.FlashAnim:Play();
	else
		cooldownFlashFrame:Hide();
		cooldownFlashFrame.FlashAnim:Stop();
	end

	CheckDisplayCooldownState("RefreshSpellCooldownInfo", self);

	if self.allowOnCooldownAlert then
		self:TriggerAlertEvent(Enum.CooldownViewerAlertEventType.OnCooldown);
		self.allowOnCooldownAlert = false;
	end
end

function CooldownViewerCooldownItemMixin:RefreshSpellChargeInfo()
	self:CacheChargeValues();

	local chargeCountFrame = self:GetChargeCountFrame();

	chargeCountFrame:SetShown(self.cooldownChargesShown);

	if self.cooldownChargesShown then
		chargeCountFrame.Current:SetText(self.cooldownChargesCount);
	end
end

function CooldownViewerCooldownItemMixin:RefreshIconDesaturation()
	LogCooldown(self:GetSpellID(), "RefreshIconDesaturation", "%s, expired: %s", tostring(self.cooldownDesaturated), tostring(self:IsExpired()));

	local iconTexture = self:GetIconTexture();
	local desaturated = self.cooldownDesaturated and not self:IsExpired();

	iconTexture:SetDesaturated(desaturated);
end

function CooldownViewerCooldownItemMixin:RefreshIconColor()
	local spellID = self:GetSpellID();
	if not spellID then
		return;
	end

	local iconTexture = self:GetIconTexture();
	local outOfRangeTexture = self:GetOutOfRangeTexture();

	local isUsable, notEnoughMana = C_Spell.IsSpellUsable(spellID);

	if self.spellOutOfRange == true then
		iconTexture:SetVertexColor(CooldownViewerConstants.ITEM_NOT_IN_RANGE_COLOR:GetRGBA());
	elseif isUsable then
		iconTexture:SetVertexColor(CooldownViewerConstants.ITEM_USABLE_COLOR:GetRGBA());
	elseif notEnoughMana then
		iconTexture:SetVertexColor(CooldownViewerConstants.ITEM_NOT_ENOUGH_MANA_COLOR:GetRGBA());
	else
		iconTexture:SetVertexColor(CooldownViewerConstants.ITEM_NOT_USABLE_COLOR:GetRGBA());
	end

	outOfRangeTexture:SetShown(self.spellOutOfRange == true);
end

function CooldownViewerCooldownItemMixin:RefreshOverlayGlow()
	local spellID = self:GetSpellID();
	local isSpellOverlayed = spellID and C_SpellActivationOverlay.IsSpellOverlayed(spellID) or false;
	if isSpellOverlayed then
		ActionButtonSpellAlertManager:ShowAlert(self);
	else
		ActionButtonSpellAlertManager:HideAlert(self);
	end
end

function CooldownViewerCooldownItemMixin:RefreshData()
	self:ClearVisualDataSource();
	self:RefreshAuraInstance();
	self:RefreshSpellCooldownInfo();
	self:RefreshSpellChargeInfo();
	self:RefreshSpellTexture();
	self:RefreshIconDesaturation();
	self:RefreshIconColor();
	self:RefreshOverlayGlow();
	self:RefreshActive();
end

---------------------------------------------------------------------------------------------------
CooldownViewerEssentialItemMixin = CreateFromMixins(CooldownViewerCooldownItemMixin);

---------------------------------------------------------------------------------------------------
CooldownViewerUtilityItemMixin = CreateFromMixins(CooldownViewerCooldownItemMixin);

---------------------------------------------------------------------------------------------------
-- Base Mixin for BuffIcon and BuffBar cooldown items.
CooldownViewerBuffItemMixin = CreateFromMixins(CooldownViewerItemMixin);

function CooldownViewerBuffItemMixin:OnCooldownIDSet()
	CooldownViewerItemMixin.OnCooldownIDSet(self);
end

function CooldownViewerBuffItemMixin:OnCooldownIDCleared()
	CooldownViewerItemMixin.OnCooldownIDCleared(self);
end

function CooldownViewerBuffItemMixin:ShouldBeActive()
	if not CooldownViewerItemMixin.ShouldBeActive(self) then
		return false;
	end

	local totemData = self:GetTotemData();
	if totemData then
		return totemData.expirationTime > GetTime();
	end

	local auraData = self:GetAuraData();
	if auraData then
		-- Auras with an expirationTime of 0 are infinite and considered active until they are removed.
		if auraData.expirationTime == 0 then
			return true;
		end

		return auraData.expirationTime > GetTime();
	end

	return false;
end

function CooldownViewerBuffItemMixin:OnActiveStateChanged()
	CooldownViewerItemMixin.OnActiveStateChanged(self);

	local active = self:IsActive();
	if active then
		self:CheckSetPandemicAlertTiggerTime(self:GetAuraData());
	end
end

function CooldownViewerBuffItemMixin:GetCooldownValues()
	local paused = false;

	local totemData = self:GetTotemData();
	if totemData then
		return totemData.expirationTime, totemData.duration, totemData.modRate, paused;
	end

	local auraData = self:GetAuraData();
	if auraData then
		return auraData.expirationTime, auraData.duration, auraData.timeMod, paused;
	end

	local modRate = 1;
	local expirationTime = 0;
	local duration = 0;

	if self:HasEditModeData() then
		duration = GetEditModeDuration(self.editModeIndex);
		expirationTime = GetTime() - GetEditModeElapsedTime(self.editModeIndex) + duration;
		paused = true;
		return expirationTime, duration, modRate, paused;
	end

	return expirationTime, duration, modRate, paused;
end

function CooldownViewerBuffItemMixin:GetApplicationsText()
	local auraData = self:GetAuraData();
	if auraData and auraData.applications and auraData.applications > 1 then
		return auraData.applications;
	end

	return "";
end

---------------------------------------------------------------------------------------------------
CooldownViewerBuffIconItemMixin = CreateFromMixins(CooldownViewerBuffItemMixin);

function CooldownViewerBuffIconItemMixin:GetApplicationsFrame()
	return self.Applications;
end

function CooldownViewerBuffIconItemMixin:GetApplicationsFontString()
	local applicationsFrame = self:GetApplicationsFrame();
	return applicationsFrame.Applications;
end

function CooldownViewerBuffIconItemMixin:OnLoad()
	CooldownViewerBuffItemMixin.OnLoad(self);

	local cooldownFrame = self:GetCooldownFrame();
	cooldownFrame:SetUseAuraDisplayTime(true);

	self:GetCooldownFrame():SetScript("OnCooldownDone", GenerateClosure(self.OnCooldownDone, self));
end

function CooldownViewerBuffIconItemMixin:OnCooldownDone()
	self:RefreshActive();
end

function CooldownViewerBuffIconItemMixin:GetCooldownSwipeColor()
	-- Adding API for this, but still using the standard cooldown colors even though this is an aura
	return CooldownViewerConstants.ITEM_COOLDOWN_COLOR;
end

function CooldownViewerBuffIconItemMixin:RefreshCooldownInfo()
	local cooldownFrame = self:GetCooldownFrame();

	local expirationTime, duration, timeMod, paused = self:GetCooldownValues();
	local currentTime = expirationTime - GetTime();

	if currentTime > 0 then
		local swipeColor = self:GetCooldownSwipeColor();
		cooldownFrame:SetSwipeColor(swipeColor.r, swipeColor.g, swipeColor.b, swipeColor.a);

		local startTime = expirationTime - duration;
		local isEnabled = 1;
		local forceShowDrawEdge = false;
		CooldownFrame_Set(cooldownFrame, startTime, duration, isEnabled, forceShowDrawEdge, timeMod);
	else
		CooldownFrame_Clear(cooldownFrame);
	end

	if paused then
		cooldownFrame:Pause();
	else
		cooldownFrame:Resume();
	end
end

function CooldownViewerBuffIconItemMixin:RefreshApplications()
	local applicationsText = self:GetApplicationsText();

	local applicationsFontString = self:GetApplicationsFontString();
	applicationsFontString:SetText(applicationsText);
end

function CooldownViewerBuffIconItemMixin:RefreshData()
	self:ClearVisualDataSource();
	self:RefreshAuraInstance();
	self:RefreshCooldownInfo();
	self:RefreshSpellTexture();
	self:RefreshApplications();
	self:RefreshActive();
end

---------------------------------------------------------------------------------------------------
CooldownViewerBuffBarItemMixin = CreateFromMixins(CooldownViewerBuffItemMixin);

function CooldownViewerBuffBarItemMixin:GetIconFrame()
	return self.Icon;
end

function CooldownViewerBuffBarItemMixin:GetIconTexture()
	local iconFrame = self:GetIconFrame();
	return iconFrame.Icon;
end

function CooldownViewerBuffBarItemMixin:GetBarFrame()
	return self.Bar;
end

function CooldownViewerBuffBarItemMixin:GetPipTexture()
	local barFrame = self:GetBarFrame();
	return barFrame.Pip;
end

function CooldownViewerBuffBarItemMixin:GetNameFontString()
	return self.Bar.Name;
end

function CooldownViewerBuffBarItemMixin:GetDurationFontString()
	return self.Bar.Duration;
end

function CooldownViewerBuffBarItemMixin:GetApplicationsFontString()
	local iconFrame = self:GetIconFrame();
	return iconFrame.Applications;
end

function CooldownViewerBuffBarItemMixin:OnLoad()
	CooldownViewerBuffItemMixin.OnLoad(self);

	local pipTexture = self:GetPipTexture();
	local barFrame = self:GetBarFrame();
	pipTexture:ClearAllPoints();
	pipTexture:SetPoint("CENTER", barFrame:GetStatusBarTexture(), "RIGHT", 0, 0);
end

function CooldownViewerBuffBarItemMixin:OnUpdate(elapsed, timeNow)
	if self:IsActive() then
		CooldownViewerItemMixin.OnUpdate(self, elapsed, timeNow);
		self:RefreshCooldownInfo();
		self:RefreshActive();
	end
end

function CooldownViewerBuffBarItemMixin:SetBarContent(barContent)
	local iconFrame = self:GetIconFrame();
	local nameFontString = self:GetNameFontString();
	local point, relativeTo, relativePoint, offsetX, offsetY = "LEFT", iconFrame, "RIGHT", 0, 0;

	if barContent == Enum.CooldownViewerBarContent.IconAndName then
		iconFrame:Show();
		nameFontString:Show();
	elseif barContent == Enum.CooldownViewerBarContent.IconOnly then
		iconFrame:Show();
		nameFontString:Hide();
	elseif barContent == Enum.CooldownViewerBarContent.NameOnly then
		iconFrame:Hide();
		nameFontString:Show();
		relativeTo = self;
		relativePoint = "LEFT";
	else
		assertsafe(false, "Unknown value for bar content: %d", barContent);
	end

	self:GetBarFrame():SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
end

function CooldownViewerBuffBarItemMixin:SetBarWidth(barWidth)
	self:SetWidth(barWidth);
end

function CooldownViewerBuffBarItemMixin:SetTimerShown(shownSetting)
	local durationFontString = self:GetDurationFontString();
	if durationFontString then
		durationFontString:SetShown(shownSetting);
	end
end

function CooldownViewerBuffBarItemMixin:IsTimerShown()
	local durationFontString = self:GetDurationFontString();
	if durationFontString then
		return durationFontString:IsShown();
	end

	return false;
end

function CooldownViewerBuffBarItemMixin:RefreshCooldownInfo()
	local barFrame = self:GetBarFrame();
	local durationFontString = self:GetDurationFontString();
	local pipTexture = self:GetPipTexture();

	local expirationTime, duration, paused = self:GetCooldownValues();
	local currentTime = expirationTime - GetTime();

	if currentTime > 0 then
		barFrame:SetMinMaxValues(0, duration);
		barFrame:SetValue(currentTime);

		if durationFontString:IsShown() then
			local time = string.format(COOLDOWN_DURATION_SEC, currentTime);
			durationFontString:SetText(time);
		end

		pipTexture:SetShown(true);
	else
		barFrame:SetMinMaxValues(0, 0);
		barFrame:SetValue(0);

		if durationFontString:IsShown() then
			durationFontString:SetText("");
		end

		pipTexture:SetShown(false);
	end
end

function CooldownViewerBuffBarItemMixin:RefreshName()
	local nameFontString = self:GetNameFontString();
	if not nameFontString:IsShown() then
		return;
	end

	local nameText = self:GetNameText();
	nameFontString:SetText(nameText);
end

function CooldownViewerBuffBarItemMixin:RefreshApplications()
	local applicationsText = self:GetApplicationsText();

	local applicationsFontString = self:GetApplicationsFontString();
	applicationsFontString:SetText(applicationsText);
end

function CooldownViewerBuffBarItemMixin:OnActiveStateChanged()
	CooldownViewerBuffItemMixin.OnActiveStateChanged(self);

	if self:IsActive() then
		self:RefreshName();
	end
end

function CooldownViewerBuffBarItemMixin:RefreshData()
	self:RefreshAuraInstance();
	self:RefreshSpellTexture();
	self:RefreshCooldownInfo();
	self:RefreshName();
	self:RefreshApplications();
	self:RefreshActive();
end

---------------------------------------------------------------------------------------------------
local cooldownViewerEnabledCVar = "cooldownViewerEnabled";
CVarCallbackRegistry:SetCVarCachable(cooldownViewerEnabledCVar);

CooldownViewerMixin = {};

function CooldownViewerMixin:GetItemContainerFrame()
	return self;
end

function CooldownViewerMixin:GetItemFrames()
	local itemContainerFrame = self:GetItemContainerFrame();
	return itemContainerFrame:GetLayoutChildren();
end

function CooldownViewerMixin:OnLoad()
	local itemResetCallback = function(pool, itemFrame)
		Pool_HideAndClearAnchors(pool, itemFrame);
		itemFrame:ClearCooldownID();
		itemFrame.layoutIndex = nil;
	end;
	self.itemFramePool = CreateFramePool("FRAME", self:GetItemContainerFrame(), self.itemTemplate, itemResetCallback);
	self.pandemicIconPool = CreateFramePool("FRAME", self, self:GetPandemicStateFrameTemplate());

	self.iconLimit = 1;
	self.iconDirection = Enum.CooldownViewerIconDirection.Right;
	self.iconPadding = 5;
	self.isHorizontal = true;
	self.iconScale = 1;
	self.timerShown = true;
	self.tooltipsShown = true;

	-- Used for quick lookup when handling UNIT_AURA events, requires the items to register/unregister their auraInstanceID when it changes.
	self.auraInstanceIDToItemFramesMap = {};

	self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED");
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");

	EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", self.OnVariablesLoaded, self);
	CVarCallbackRegistry:RegisterCallback(cooldownViewerEnabledCVar, self.OnCooldownViewerEnabledCVarChanged, self);

	EventRegistry:RegisterCallback("CooldownViewerSettings.OnShow", self.OnViewerSettingsShownStateChange, self);
	EventRegistry:RegisterCallback("CooldownViewerSettings.OnHide", self.OnViewerSettingsShownStateChange, self);

	self:UpdateShownState();

	-- The edit mode selection indicator uses the bounds of the item container to more closely match the player's expectation.
	self.Selection:SetAllPoints(self:GetItemContainerFrame());
end

function CooldownViewerMixin:RegisterAuraInstanceIDItemFrame(auraInstanceID, itemFrame)
	if not auraInstanceID then
		return;
	end

	if not self.auraInstanceIDToItemFramesMap[auraInstanceID] then
		self.auraInstanceIDToItemFramesMap[auraInstanceID] = {};
	end

	-- It's rare that two itemFrames use the same auraInstanceID but the data setup allows for it.
	tInsertUnique(self.auraInstanceIDToItemFramesMap[auraInstanceID], itemFrame);
end

function CooldownViewerMixin:UnregisterAuraInstanceIDItemFrame(auraInstanceID, itemFrame)
	tDeleteItem(self.auraInstanceIDToItemFramesMap[auraInstanceID], itemFrame);
end

function CooldownViewerMixin:OnShow()
	-- Events passed directly to the items.
	self:RegisterEvent("COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterUnitEvent("UNIT_AURA", "player", "target");
	self:RegisterUnitEvent("UNIT_TARGET", "player");
	self:RegisterEvent("PLAYER_TOTEM_UPDATE");

	EventRegistry:RegisterCallback("CooldownViewerSettings.OnDataChanged", function()
		self:RefreshLayout();
	end, self);

	self:RefreshLayout();
end

function CooldownViewerMixin:OnHide()
	-- Events passed directly to the items.
	self:UnregisterEvent("COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED");
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	self:UnregisterEvent("UNIT_AURA");
	self:UnregisterEvent("UNIT_TARGET");
	self:UnregisterEvent("PLAYER_TOTEM_UPDATE");

	EventRegistry:UnregisterCallback("CooldownViewerSettings.OnDataChanged", self);
end

function CooldownViewerMixin:OnVariablesLoaded()
	self:UpdateShownState();
end

function CooldownViewerMixin:OnCooldownViewerEnabledCVarChanged()
	self:UpdateShownState();
end

function CooldownViewerMixin:OnEvent(event, ...)
	if event == "PLAYER_IN_COMBAT_CHANGED" or event == "PLAYER_LEVEL_CHANGED" then
		self:UpdateShownState();
	elseif event == "COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED" then
		local baseSpellID, overrideSpellID = ...;
		for itemFrame in self.itemFramePool:EnumerateActive() do
			itemFrame:OnCooldownViewerSpellOverrideUpdatedEvent(baseSpellID, overrideSpellID);
		end
	elseif event =="SPELL_UPDATE_COOLDOWN" then
		local spellID, baseSpellID, _category, startRecoveryCategory = ...;
		for itemFrame in self.itemFramePool:EnumerateActive() do
			itemFrame:OnSpellUpdateCooldownEvent(spellID, baseSpellID, startRecoveryCategory);
		end
	elseif event == "UNIT_AURA" then
		local unit, unitAuraUpdateInfo = ...;
		self:OnUnitAura(unit, unitAuraUpdateInfo);
	elseif event == "UNIT_TARGET" then
		local unit = ...;
		self:OnUnitTarget(unit);
	elseif event == "PLAYER_TOTEM_UPDATE" then
		local slot = ...;
		local _haveTotem, name, startTime, duration, _icon, modRate, spellID = GetTotemInfo(slot);
		for itemFrame in self.itemFramePool:EnumerateActive() do
			itemFrame:OnPlayerTotemUpdateEvent(slot, name, startTime, duration, modRate, spellID);
		end
	end
end

function CooldownViewerMixin:OnUpdate(elapsed)
	local now = GetTime();
	for itemFrame in self.itemFramePool:EnumerateActive() do
		itemFrame:OnUpdate(elapsed, now);
	end
end

function CooldownViewerMixin:OnUnitAura(unit, unitAuraUpdateInfo)
	if unit == "player" and unitAuraUpdateInfo then
		if unitAuraUpdateInfo.removedAuraInstanceIDs then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
				local itemFrames = self.auraInstanceIDToItemFramesMap[auraInstanceID];
				if itemFrames then
					for _, itemFrame in ipairs(itemFrames) do
						itemFrame:OnUnitAuraRemovedEvent();
					end
				end
			end
		end

		if unitAuraUpdateInfo.updatedAuraInstanceIDs then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
				local itemFrames = self.auraInstanceIDToItemFramesMap[auraInstanceID];
				if itemFrames then
					for _, itemFrame in ipairs(itemFrames) do
						itemFrame:OnUnitAuraUpdatedEvent();
					end
				end
			end
		end

		if unitAuraUpdateInfo.addedAuras then
			for itemFrame in self.itemFramePool:EnumerateActive() do
				itemFrame:OnUnitAuraAddedEvent(unitAuraUpdateInfo);
			end
		end
	elseif unit == "target" then
		self:RefreshActiveFramesForTargetChange();
	end
end

function CooldownViewerMixin:OnUnitTarget(_unit)
	self:RefreshActiveFramesForTargetChange();
end

function CooldownViewerMixin:RefreshActiveFramesForTargetChange()
	-- TODO: First pass, update everything; can afford to be more selective once a mapping is built that will only
	-- check the relevant frames that need updates (ones that care about target state)
	for itemFrame in self.itemFramePool:EnumerateActive() do
		itemFrame:OnNewTarget();
		itemFrame:RefreshData();
	end
end

function CooldownViewerMixin:ShouldBeShown()
	if self:IsEditing() then
		return true;
	end

	if not CVarCallbackRegistry:GetCVarValueBool(cooldownViewerEnabledCVar) then
		return false;
	end

	local isAvailable, _failureReason = C_CooldownViewer.IsCooldownViewerAvailable();
	if not isAvailable then
		return false;
	end

	if CooldownViewerSettings:IsVisible() then
		return true;
	end

	if self.visibleSetting then
		if self.visibleSetting == Enum.CooldownViewerVisibleSetting.Always then
			return true;
		elseif self.visibleSetting == Enum.CooldownViewerVisibleSetting.InCombat then
			local isInCombat = UnitAffectingCombat("player");
			return isInCombat;
		elseif self.visibleSetting == Enum.CooldownViewerVisibleSetting.Hidden then
			return false;
		else
			assertsafe(false, "Unknown value for visible setting: " .. self.visibleSetting);
		end
	end

	return true;
end

function CooldownViewerMixin:SetIsEditing(isEditing)
	if self.isEditing == isEditing then
		return;
	end

	self.isEditing = isEditing;

	self:RefreshLayout();
	self:UpdateShownState();
end

function CooldownViewerMixin:IsEditing()
	return self.isEditing;
end

function CooldownViewerMixin:SetHideWhenInactive(hideWhenInactive)
	if self.hideWhenInactive == hideWhenInactive then
		return;
	end

	self.hideWhenInactive = hideWhenInactive;

	for itemFrame in self.itemFramePool:EnumerateActive() do
		itemFrame:SetHideWhenInactive(hideWhenInactive);
	end
end

function CooldownViewerMixin:GetHideWhenInactive()
	return self.hideWhenInactive;
end

function CooldownViewerMixin:UpdateShownState()
	local shouldBeShown = self:ShouldBeShown();
	local isShown = self:IsShown();

	if shouldBeShown == isShown then
		return;
	end

	self:SetShown(shouldBeShown);

	if shouldBeShown then
		self:RefreshData();
	end
end

function CooldownViewerMixin:OnViewerSettingsShownStateChange()
	self:UpdateShownState();

	for itemFrame in self.itemFramePool:EnumerateActive() do
		itemFrame:UpdateShownState();
	end
end

function CooldownViewerMixin:IsHorizontal()
	return self.orientationSetting == Enum.CooldownViewerOrientation.Horizontal;
end

function CooldownViewerMixin:GetItemCount()
	local cooldownIDs = self:GetCooldownIDs();
	local itemCount = cooldownIDs and #cooldownIDs or 0;

	local minimumItemCount = 2;
	itemCount = math.max(itemCount, minimumItemCount);

	return itemCount;
end

function CooldownViewerMixin:GetStride()
	return self.iconLimit;
end

function CooldownViewerMixin:OnAcquireItemFrame(itemFrame)
	itemFrame:SetViewerFrame(self);
	itemFrame:SetScale(self.iconScale);
	itemFrame:SetTimerShown(self.timerShown);
	itemFrame:SetTooltipsShown(self.tooltipsShown);
	itemFrame:SetHideWhenInactive(self.hideWhenInactive);
	itemFrame:SetIsEditing(self.isEditing);
end

function CooldownViewerMixin:RefreshLayout()
	self.itemFramePool:ReleaseAll();

	local itemCount = self:GetItemCount();
	for i = 1, itemCount do
		local itemFrame = self.itemFramePool:Acquire();
		itemFrame.layoutIndex = i;
		self:OnAcquireItemFrame(itemFrame);
	end

	local itemContainerFrame = self:GetItemContainerFrame();

	-- Needed for changes to icon scale, which don't trigger a layout update.
	itemContainerFrame.alwaysUpdateLayout = true;

	itemContainerFrame.isHorizontal = self:IsHorizontal();

	-- Vertical layout is always left to right. Horizontal layout uses the Icon Direction.
	itemContainerFrame.layoutFramesGoingRight = not self.isHorizontal or (self.isHorizontal and self.iconDirection == Enum.CooldownViewerIconDirection.Right);

	-- Horizontal layout is always top to bottom. Vertical layout uses the Icon Direction.
	itemContainerFrame.layoutFramesGoingUp = not self.isHorizontal and self.iconDirection == Enum.CooldownViewerIconDirection.Right;

	itemContainerFrame.childXPadding = self.iconPadding;
	itemContainerFrame.childYPadding = self.iconPadding;

	itemContainerFrame.stride = self:GetStride();

	if self:IsShown() then
		self:RefreshData();
	end

	self:GetItemContainerFrame():Layout();
end

function CooldownViewerMixin:GetCategory()
	return self.cooldownViewerCategory;
end

function CooldownViewerMixin:GetCooldownIDs()
	assertsafe(self:GetCategory(), "Cooldown Viewer Category not set");
	return CooldownViewerSettings:GetDataProvider():GetOrderedCooldownIDsForCategory(self:GetCategory());
end

function CooldownViewerMixin:RefreshData()
	local cooldownIDs = self:GetCooldownIDs();

	for itemFrame in self.itemFramePool:EnumerateActive() do
		local cooldownID = cooldownIDs and cooldownIDs[itemFrame.layoutIndex];
		if cooldownID then
			itemFrame:SetCooldownID(cooldownID);
		else
			itemFrame:ClearCooldownID();

			if self:IsEditing() then
				-- Generate a unique number for each item in edit mode that can be used to look up a placeholder texture or generate a fake duration.
				local editModeData = itemFrame.layoutIndex * 5 + self:GetCategory();
				itemFrame:SetEditModeData(editModeData);
			else
				itemFrame:ClearEditModeData();
			end
		end
	end
end

function CooldownViewerMixin:SetTimerShown(shownSetting)
	self.timerShown = shownSetting;

	for itemFrame in self.itemFramePool:EnumerateActive() do
		itemFrame:SetTimerShown(shownSetting);
	end
end

function CooldownViewerMixin:SetTooltipsShown(shownSetting)
	self.tooltipsShown = shownSetting;

	for itemFrame in self.itemFramePool:EnumerateActive() do
		itemFrame:SetTooltipsShown(shownSetting);
	end
end

function CooldownViewerMixin:SetBarContent(_barContent)
	-- override as needed
end

function CooldownViewerMixin:SetBarWidthScale(_barWidthScale)
	-- override as needed
end

function CooldownViewerMixin:GetPandemicStateFrameTemplate()
	-- override as needed
	return "CooldownPandemicFXTemplate";
end

function CooldownViewerMixin:SetupPandemicStateFrameForItem(cooldownItem)
	local frame = self.pandemicIconPool:Acquire();
	frame:SetParent(cooldownItem);

	self:AnchorPandemicStateFrame(frame, cooldownItem);
	return frame;
end

function CooldownViewerMixin:AnchorPandemicStateFrame(frame, cooldownItem)
	-- Override as needed
	frame:SetPoint("TOPLEFT", cooldownItem, "TOPLEFT", -6, 6);
	frame:SetPoint("BOTTOMRIGHT", cooldownItem, "BOTTOMRIGHT", 6, -6);
end

function CooldownViewerMixin:HidePandemicStateFrame(stateFrame)
	self.pandemicIconPool:Release(stateFrame);
end

---------------------------------------------------------------------------------------------------
-- Base Mixin for Essential and Utility Cooldown Viewers.
CooldownViewerCooldownMixin = CreateFromMixins(CooldownViewerMixin);

function CooldownViewerCooldownMixin:OnShow()
	CooldownViewerMixin.OnShow(self);

	-- Events passed directly to the items.
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
	self:RegisterEvent("SPELL_UPDATE_USES");
	self:RegisterEvent("SPELL_UPDATE_USABLE");
	self:RegisterEvent("SPELL_RANGE_CHECK_UPDATE");
end

function CooldownViewerCooldownMixin:OnHide()
	CooldownViewerMixin.OnHide(self);

	-- Events passed directly to the items.
	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
	self:UnregisterEvent("SPELL_UPDATE_USES");
	self:UnregisterEvent("SPELL_UPDATE_USABLE");
	self:UnregisterEvent("SPELL_RANGE_CHECK_UPDATE");
end

function CooldownViewerCooldownMixin:OnEvent(event, ...)
	CooldownViewerMixin.OnEvent(self, event, ...);

	if event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
		local spellID = ...;
		for itemFrame in self.itemFramePool:EnumerateActive() do
			itemFrame:OnSpellActivationOverlayGlowShowEvent(spellID);
		end
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
		local spellID = ...;
		for itemFrame in self.itemFramePool:EnumerateActive() do
			itemFrame:OnSpellActivationOverlayGlowHideEvent(spellID);
		end
	elseif event == "SPELL_UPDATE_USES" then
		local spellID, baseSpellID = ...;
		for itemFrame in self.itemFramePool:EnumerateActive() do
			itemFrame:OnSpellUpdateUsesEvent(spellID, baseSpellID);
		end
	elseif event == "SPELL_UPDATE_USABLE" then
		for itemFrame in self.itemFramePool:EnumerateActive() do
			itemFrame:OnSpellUpdateUsableEvent();
		end
	elseif event == "SPELL_RANGE_CHECK_UPDATE" then
		local spellID, inRange, checksRange = ...;
		for itemFrame in self.itemFramePool:EnumerateActive() do
			itemFrame:OnSpellRangeCheckUpdateEvent(spellID, inRange, checksRange);
		end
	end
end

---------------------------------------------------------------------------------------------------
EssentialCooldownViewerMixin = CreateFromMixins(CooldownViewerCooldownMixin, EditModeCooldownViewerSystemMixin, UIParentManagedFrameMixin, GridLayoutFrameMixin);

function EssentialCooldownViewerMixin:OnLoad()
	EditModeCooldownViewerSystemMixin.OnSystemLoad(self);
	CooldownViewerCooldownMixin.OnLoad(self);
end

function EssentialCooldownViewerMixin:OnShow()
	LayoutMixin.OnShow(self);
	UIParentManagedFrameMixin.OnShow(self);
	CooldownViewerCooldownMixin.OnShow(self);
end

function EssentialCooldownViewerMixin:OnHide()
	UIParentManagedFrameMixin.OnHide(self);
	CooldownViewerCooldownMixin.OnHide(self);
end

function EssentialCooldownViewerMixin:OnEvent(event, ...)
	CooldownViewerCooldownMixin.OnEvent(self, event, ...);
end

---------------------------------------------------------------------------------------------------
UtilityCooldownViewerMixin = CreateFromMixins(CooldownViewerCooldownMixin, EditModeCooldownViewerSystemMixin, UIParentManagedFrameMixin, GridLayoutFrameMixin);

function UtilityCooldownViewerMixin:OnLoad()
	EditModeCooldownViewerSystemMixin.OnSystemLoad(self);
	CooldownViewerCooldownMixin.OnLoad(self);
end

function UtilityCooldownViewerMixin:OnShow()
	LayoutMixin.OnShow(self);
	UIParentManagedFrameMixin.OnShow(self);
	CooldownViewerCooldownMixin.OnShow(self);
end

function UtilityCooldownViewerMixin:OnHide()
	UIParentManagedFrameMixin.OnHide(self);
	CooldownViewerCooldownMixin.OnHide(self);
end

function UtilityCooldownViewerMixin:OnEvent(event, ...)
	CooldownViewerCooldownMixin.OnEvent(self, event, ...);
end

---------------------------------------------------------------------------------------------------
-- Base Mixin for BuffIcon and BuffBar Cooldown Viewers.
CooldownViewerBuffMixin = CreateFromMixins(CooldownViewerMixin);

function CooldownViewerBuffMixin:OnShow()
	CooldownViewerMixin.OnShow(self);
end

function CooldownViewerBuffMixin:OnHide()
	CooldownViewerMixin.OnHide(self);
end

function CooldownViewerBuffMixin:OnEvent(event, ...)
	CooldownViewerMixin.OnEvent(self, event, ...);
end

---------------------------------------------------------------------------------------------------
BuffIconCooldownViewerMixin = CreateFromMixins(CooldownViewerBuffMixin, EditModeCooldownViewerSystemMixin, UIParentManagedFrameMixin, GridLayoutFrameMixin);

function BuffIconCooldownViewerMixin:OnLoad()
	EditModeCooldownViewerSystemMixin.OnSystemLoad(self);
	CooldownViewerBuffMixin.OnLoad(self);
end

function BuffIconCooldownViewerMixin:OnShow()
	LayoutMixin.OnShow(self);
	UIParentManagedFrameMixin.OnShow(self);
	CooldownViewerBuffMixin.OnShow(self);
end

function BuffIconCooldownViewerMixin:OnHide()
	UIParentManagedFrameMixin.OnHide(self);
	CooldownViewerBuffMixin.OnHide(self);
end

function BuffIconCooldownViewerMixin:OnEvent(event, ...)
	CooldownViewerBuffMixin.OnEvent(self, event, ...);
end

function BuffIconCooldownViewerMixin:GetStride()
	-- Ensure there is only ever one row/column (based on orientation)
	return self:GetItemCount();
end

---------------------------------------------------------------------------------------------------
BuffBarCooldownViewerMixin = CreateFromMixins(CooldownViewerBuffMixin, EditModeCooldownViewerSystemMixin, GridLayoutFrameMixin);

function BuffBarCooldownViewerMixin:OnLoad()
	EditModeCooldownViewerSystemMixin.OnSystemLoad(self);
	CooldownViewerBuffMixin.OnLoad(self);

	self.barContent = Enum.CooldownViewerBarContent.IconAndName;
	self.baseBarWidth = 220;
	self.barWidthScale = 1;
end

function BuffBarCooldownViewerMixin:OnShow()
	LayoutMixin.OnShow(self);
	CooldownViewerBuffMixin.OnShow(self);
end

function BuffBarCooldownViewerMixin:OnHide()
	CooldownViewerBuffMixin.OnHide(self);
end

function BuffBarCooldownViewerMixin:OnEvent(event, ...)
	CooldownViewerBuffMixin.OnEvent(self, event, ...);
end

function BuffBarCooldownViewerMixin:GetStride()
	-- Ensure there is only ever one row/column (based on orientation)
	return self:GetItemCount();
end

function BuffBarCooldownViewerMixin:OnAcquireItemFrame(itemFrame)
	CooldownViewerBuffMixin.OnAcquireItemFrame(self, itemFrame);

	itemFrame:SetBarContent(self.barContent);
	itemFrame:SetBarWidth(self:GetBarWidth());
end

function BuffBarCooldownViewerMixin:SetBarContent(barContent)
	self.barContent = barContent;

	for itemFrame in self.itemFramePool:EnumerateActive() do
		itemFrame:SetBarContent(barContent);
	end
end

function BuffBarCooldownViewerMixin:SetBarWidthScale(barWidthScale)
	-- using a "reasonably small value that could be a scale" as the max, because you can go over 100% scale.
	assertsafe(barWidthScale and barWidthScale > 0 and barWidthScale <= 3, "barWidthScale should be a percentage");

	self.barWidthScale = barWidthScale;
end

function BuffBarCooldownViewerMixin:GetBarWidth()
	return self.baseBarWidth * self.barWidthScale;
end

function BuffBarCooldownViewerMixin:GetPandemicStateFrameTemplate()
	-- override as needed
	return "CooldownPandemicBarFXTemplate";
end

function BuffBarCooldownViewerMixin:AnchorPandemicStateFrame(frame, cooldownItem)
	-- Override as needed
	frame:SetPoint("TOPLEFT", cooldownItem.Bar, "TOPLEFT", -9, 10);
	frame:SetPoint("BOTTOMRIGHT", cooldownItem.Bar, "BOTTOMRIGHT", 9, -10);
	frame:SetFrameLevel(cooldownItem.Bar:GetFrameLevel() + 1);
end
