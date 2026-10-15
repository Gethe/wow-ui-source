local MANA_PER_PIP = 10;
local RESOURCE_WIDTH_ANIMATION_DURATION = 0.2;
local DAMAGE_HEALTH_LINGER_DURATION = 0.4;

local RESOURCE_DISPLAY_UNIT_EVENTS = {
	"UNIT_HEALTH",
	"UNIT_MAXHEALTH",
	"UNIT_POWER_FREQUENT",
	"UNIT_MAXPOWER",
	"UNIT_CONNECTION",
	"UNIT_NAME_UPDATE",
	"UNIT_ABSORB_AMOUNT_CHANGED",
	"UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
	"UNIT_MAX_HEALTH_MODIFIERS_CHANGED",
};

local RESOURCE_DISPLAY_EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"PARTY_LEADER_CHANGED",
	"GROUP_ROSTER_UPDATE",
};

PersonalGrowingResourceDisplayMixin = {};

local function PersonalGrowingResourceDisplay_OpenContextMenu(frame, unit, button, isKeyPress)
	local which;
	local contextData = { unit = unit };

	-- This is to target the active player for the SELF context menu.
	if UnitIsUnit(unit, "player") then
		which = "SELF";
	else
		which = "PARTY";
	end

	UnitPopup_OpenMenu(which, contextData);
end

function PersonalGrowingResourceDisplayMixin:OnLoad()
	local healthBarContainer = self.HealthBarContainer;
	healthBarContainer.TempMaxHealthLoss:InitializeMaxHealthLossBar(healthBarContainer, healthBarContainer.Bar);
	CVarCallbackRegistry:RegisterCallback("showTempMaxHealthLoss", self.OnTempMaxHealthLossCVarChanged, self);

	self.manaPipTable = {};
	for i = 1, self.maxManaPips do
		local pip = CreateFrame("FRAME", nil, self.ManaPipContainer, "TravelerManaPipTemplate");
		pip.layoutIndex = i;
		self.manaPipTable[i] = pip;
		pip:Hide();
	end

	self:RegisterForClicks("RightButtonUp");
	self:SetScript("OnClick", function(frame, button)
		PersonalGrowingResourceDisplay_OpenContextMenu(frame, frame.unit, button, false);
	end);

	self:SetUnit(self.unit);
	self:UpdateDisplaySettings();
end

function PersonalGrowingResourceDisplayMixin:UpdateHealthHoverText()
	local healthHoverText = self.HealthHoverText;
	if not healthHoverText or not healthHoverText:IsShown() then
		return;
	end

	local currentHealth = BreakUpLargeNumbers(UnitHealth(self.unit));
	local totalHealth = BreakUpLargeNumbers(UnitHealthMax(self.unit));
	local totalAbsorb = BreakUpLargeNumbers(UnitGetTotalAbsorbs(self.unit) or 0);
	healthHoverText:SetText(currentHealth .. "/" .. totalHealth .. " (" .. totalAbsorb .. ")");
end

function PersonalGrowingResourceDisplayMixin:UpdateEnergyHoverText()
	local energyHoverText = self.EnergyHoverText;
	if not energyHoverText or not energyHoverText:IsShown() then
		return;
	end

	energyHoverText:SetText(BreakUpLargeNumbers(UnitPower(self.unit, Enum.PowerType.Energy)));
end

function PersonalGrowingResourceDisplayMixin:OnUpdate(elapsed)
	if self.resourceWidthAnimationElapsed then
		self.resourceWidthAnimationElapsed = self.resourceWidthAnimationElapsed + elapsed;
		local progress = math.min(1, self.resourceWidthAnimationElapsed / RESOURCE_WIDTH_ANIMATION_DURATION);
		local healthWidth = self.resourceWidthAnimationStartHealth + (self.resourceWidthTargetHealth - self.resourceWidthAnimationStartHealth) * progress;
		local energyWidth = self.resourceWidthAnimationStartEnergy + (self.resourceWidthTargetEnergy - self.resourceWidthAnimationStartEnergy) * progress;
		local absorbWidth = self.resourceWidthAnimationStartAbsorb + (self.resourceWidthTargetAbsorb - self.resourceWidthAnimationStartAbsorb) * progress;

		self.HealthBarContainer:SetWidth(healthWidth);
		self.EnergyBarContainer:SetWidth(energyWidth);
		local absorbContainerWidth = absorbWidth;
		if UnitAffectingCombat(self.unit) then
			absorbContainerWidth = math.max(self.AbsorbBarContainer:GetWidth(), absorbWidth);
		end
		self.AbsorbBarContainer:SetWidth(absorbContainerWidth);
		self.AbsorbBarContainer.Bar:SetWidth(absorbWidth);
		self:ApplyHealthBarWidth();
		self:UpdateDamageBorder();
		self:UpdateHealthOverlays();
		self:FlashReducedAbsorbBorder();
		self:UpdateGroupWidth();

		if progress == 1 then
			self.resourceWidthAnimationElapsed = nil;
		end
	end

	if self.damageHealthLingerElapsed then
		self.damageHealthLingerElapsed = self.damageHealthLingerElapsed + elapsed;
		if self.damageHealthLingerElapsed >= DAMAGE_HEALTH_LINGER_DURATION then
			self.damageHealthLingerElapsed = nil;
			local damageHealth = self.HealthBarContainer.DamageHealth;
			damageHealth.DamageHealthAnimation:Play();
		end
	end

	if self.HealthBarContainer.DamageHealth.DamageHealthAnimation:IsPlaying() and not self.damageHealthLingerElapsed then
		local damageHealth = self.HealthBarContainer.DamageHealth;
		if not self.HealthBarContainer.DamageHealth.DamageHealthAnimation:IsPlaying() then
			damageHealth:SetValue(self.previousHealth);
		end
	end

	if not self.resourceWidthAnimationElapsed and not self.damageHealthLingerElapsed and not self.HealthBarContainer.DamageHealth.DamageHealthAnimation:IsPlaying() then
		self:SetScript("OnUpdate", nil);
	end
end

function PersonalGrowingResourceDisplayMixin:OnShow()
	self:UpdateAll();
end

function PersonalGrowingResourceDisplayMixin:OnTempMaxHealthLossCVarChanged()
	if self.unit and UnitExists(self.unit) then
		self:UpdateHealth();
	end
end

function PersonalGrowingResourceDisplayMixin:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UpdateAll();
		return;
	end

	if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "UNIT_MAX_HEALTH_MODIFIERS_CHANGED" then
		self:UpdateHealth();
	elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
		self:UpdateAbsorb();
		if not UnitAffectingCombat(self.unit) then
			self.AbsorbBarContainer:SetWidth(self.resourceWidthTargetAbsorb or self.AbsorbBarContainer.Bar:GetWidth());
			self:UpdateGroupWidth();
		end
		self:UpdateHealthOverlays();
		self:FlashReducedAbsorbBorder();
	elseif event == "UNIT_POWER_FREQUENT" then
		local _unitTag, powerToken = ...;
		if powerToken == "ENERGY" then
			self:UpdateEnergy();
		elseif powerToken == "MANA" then
			self:UpdateManaPips();
		end
	elseif event == "UNIT_MAXPOWER" then
		local _unitTag, powerToken = ...;
		if powerToken == "ENERGY" then
			self:UpdateEnergy();
		elseif powerToken == "MANA" then
			self:UpdateMaxManaPips();
		end
	elseif event == "UNIT_NAME_UPDATE" then
		self:UpdateName();
	elseif event == "UNIT_CONNECTION" then
		self:UpdateName();
		local isConnected = UnitIsConnected(self.unit);
		self:SetOfflineBarOpacity(not isConnected);
		if isConnected then
			self:UpdateHealth();
			self:UpdateEnergy();
			self:UpdateMaxManaPips();
		else
			self.resourceWidthAnimationElapsed = nil;
			self.resourceWidthTargetHealth = nil;
			self.resourceWidthTargetEnergy = nil;
			self.resourceWidthTargetAbsorb = nil;
			self.totalAbsorb = nil;
			self.absorbWasReduced = nil;
			self.AbsorbBarContainer:SetWidth(1);
			self.AbsorbBarContainer.Bar:SetWidth(1);
			self.AbsorbBarContainer.Bar:SetValue(0);
			self.AbsorbBarContainer.Bar:Hide();
		end
	elseif event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE" then
		self:UpdateLeaderIcon();
	end
end

function PersonalGrowingResourceDisplayMixin:Init(unit)
	if unit then
		self.unit = unit;
	end

	self:SetUnit(self.unit);
	self:UpdateDisplaySettings();
end

function PersonalGrowingResourceDisplayMixin:UpdateDisplaySettings()
	self.HealthBarContainer:SetHeight(self.healthBarHeight);
	self.AbsorbBarContainer:SetHeight(self.healthBarHeight);
	self.EnergyBarContainer:SetHeight(self.energyBarHeight);
	self.ManaPipContainer:SetScale(self.manaPipScaling or 1);
	self:ApplyHealthBarWidth();

	local padding = self.elementPadding or 2;
	self.AbsorbBarContainer:SetPoint("TOPLEFT", self.HealthBarContainer, "TOPRIGHT", 2, 0);
	self.EnergyBarContainer:SetPoint("TOPLEFT", self.HealthBarContainer, "BOTTOMLEFT", 0, -padding);
	self.ManaPipContainer:SetPoint("TOPLEFT", self.EnergyBarContainer, "BOTTOMLEFT", 0, -(self.manaPipTopPadding or padding));
	self:UpdateDamageBorder();

	if self.scale then
		self:SetScale(self.scale);
	end
end

function PersonalGrowingResourceDisplayMixin:SetUnit(unit)
	self.unit = unit;
	self.previousHealth = nil;
	self:ResetHealthVisuals();

	-- Unregister previous events
	self:UnregisterAllEvents();

	if not unit then
		return;
	end

	-- Register unit events
	FrameUtil.RegisterFrameForUnitEvents(self, RESOURCE_DISPLAY_UNIT_EVENTS, unit);
	FrameUtil.RegisterFrameForEvents(self, RESOURCE_DISPLAY_EVENTS);

	if self:IsShown() then
		self:UpdateAll();
	end
end

function PersonalGrowingResourceDisplayMixin:UpdateAll()
	if not self.unit or not UnitExists(self.unit) then
		return;
	end

	self:SetOfflineBarOpacity(not UnitIsConnected(self.unit));
	self:UpdateName();
	self:UpdateLeaderIcon();
	self:UpdateHealth();
	self:UpdateEnergy();
	self:UpdateMaxManaPips();
end

function PersonalGrowingResourceDisplayMixin:UpdateName()
	local name = UnitName(self.unit);
	if name and not UnitIsConnected(self.unit) then
		name = PLAYER_NAME_OFFLINE:format(name);
	end

	self.NameText:SetText(name or UNKNOWN);
end

function PersonalGrowingResourceDisplayMixin:SetOfflineBarOpacity(isOffline)
	local alpha = isOffline and 0.3 or 1;
	self.HealthBarContainer:SetAlpha(alpha);
	self.AbsorbBarContainer:SetAlpha(alpha);
	self.EnergyBarContainer:SetAlpha(alpha);
	self.ManaPipContainer:SetAlpha(alpha);

	-- Also set the health/absorb/energy bar colors to 808080
	if isOffline then
		self.HealthBarContainer.Bar:SetStatusBarColor(0.5, 0.5, 0.5);
		self.EnergyBarContainer.Bar:SetStatusBarColor(0.5, 0.5, 0.5);
	else
		self.HealthBarContainer.Bar:SetStatusBarColor(0, 0.8, 0);
		self.EnergyBarContainer.Bar:SetStatusBarColor(0.9, 0.9, 0);
	end
end

function PersonalGrowingResourceDisplayMixin:UpdateLeaderIcon()
	local isLeader = UnitIsGroupLeader(self.unit);
	self.LeaderIcon:SetShown(isLeader);
	if not isLeader then
		self.NameText:SetPoint("TOPLEFT", self, "TOPLEFT", 10, 0);
	else
		self.NameText:SetPoint("TOPLEFT", self.LeaderIcon, "TOPRIGHT", 2, -1);
	end
end

function PersonalGrowingResourceDisplayMixin:UpdateGroupWidth()
	local healthWidth = self.HealthBarContainer:GetWidth();
	local absorbWidth = self.AbsorbBarContainer:GetWidth();
	local energyWidth = self.EnergyBarContainer:GetWidth();
	local manaWidth = self.ManaPipContainer:GetWidth() * self.ManaPipContainer:GetScale();
	local longestWidth = math.max(healthWidth + (absorbWidth > 1 and ((self.elementPadding or 2) + absorbWidth) or 0), energyWidth, manaWidth);

	self:SetWidth(longestWidth + 20);
	self:UpdateDamageBorder();
end

function PersonalGrowingResourceDisplayMixin:UpdateDamageBorder()
	local healthBar = self.HealthBarContainer;
	local absorbWidth = self.AbsorbBarContainer:GetWidth();
	local padding = self.elementPadding or 2;
	local width = healthBar:GetWidth() + (absorbWidth > 1 and padding + absorbWidth or 0) + 5;

	self.DamageBorder:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -3, 3);
	self.DamageBorder:SetWidth(width);
	self.DamageBorder:SetHeight(healthBar:GetHeight() + 6);
end

function PersonalGrowingResourceDisplayMixin:HideHealthOverlays()
	local healthBar = self.HealthBarContainer.Bar;
	healthBar.HealAbsorbBar:Hide();
	healthBar.HealAbsorbBar.LeftShadow:Hide();
	healthBar.HealAbsorbBar.RightShadow:Hide();
	healthBar.OverAbsorbGlow:Hide();
	healthBar.OverHealAbsorbGlow:Hide();
end

function PersonalGrowingResourceDisplayMixin:CancelDamageHealth()
	local healthBarContainer = self.HealthBarContainer;
	local damageHealth = healthBarContainer.DamageHealth;
	self.damageHealthLingerElapsed = nil;
	damageHealth.DamageHealthAnimation:Stop();
	damageHealth:Hide();
end

function PersonalGrowingResourceDisplayMixin:FlashReducedAbsorbBorder()
	if self.absorbWasReduced then
		self.DamageBorderAnimation:Restart();
		self.absorbWasReduced = nil;
	end
end

function PersonalGrowingResourceDisplayMixin:ResetHealthVisuals()
	self.resourceWidthAnimationElapsed = nil;
	self.resourceWidthTargetHealth = nil;
	self.resourceWidthTargetEnergy = nil;
	self.resourceWidthTargetAbsorb = nil;
	self.totalAbsorb = nil;
	self.absorbWasReduced = nil;
	self.maxHealthLossPercent = 0;
	self.hasActiveAbsorb = false;
	self:SetScript("OnUpdate", nil);

	self:CancelDamageHealth();
	self.DamageBorderAnimation:Stop();
	self.DamageBorder:SetAlpha(0);
	self:HideHealthOverlays();
	local absorbBar = self.AbsorbBarContainer.Bar;
	self.AbsorbBarContainer:SetWidth(1);
	absorbBar:SetWidth(1);
	absorbBar:SetMinMaxValues(0, 1);
	absorbBar:SetValue(0);
	absorbBar:Hide();

	local healthBarContainer = self.HealthBarContainer;
	healthBarContainer.Bar:SetWidth(healthBarContainer:GetWidth());
	healthBarContainer.DamageHealth:SetWidth(healthBarContainer:GetWidth());
	healthBarContainer.TempMaxHealthLoss:SetValue(0);
	healthBarContainer.TempMaxHealthLoss:Hide();
end

function PersonalGrowingResourceDisplayMixin:GetMaxHealthLossPercent()
	if not CVarCallbackRegistry:GetCVarValueBool("showTempMaxHealthLoss") then
		return 0;
	end

	if not self.unit then
		return 0;
	end

	return Clamp(GetUnitTotalModifiedMaxHealthPercent(self.unit) or 0, 0, 1);
end

function PersonalGrowingResourceDisplayMixin:ApplyHealthBarWidth()
	local healthBarContainer = self.HealthBarContainer;
	local healthBar = healthBarContainer.Bar;
	local maxHealthLossPercent = self.maxHealthLossPercent or 0;

	if maxHealthLossPercent > 0 then
		healthBarContainer.TempMaxHealthLoss:OnMaxHealthModifiersChanged(maxHealthLossPercent);
	else
		healthBar:SetWidth(healthBarContainer:GetWidth());
		healthBarContainer.TempMaxHealthLoss:SetValue(0);
		healthBarContainer.TempMaxHealthLoss:Hide();
	end

	healthBarContainer.DamageHealth:SetWidth(healthBar:GetWidth());
end

function PersonalGrowingResourceDisplayMixin:UpdateHealthOverlays()
	if not UnitIsConnected(self.unit) then
		return;
	end

	local healthBar = self.HealthBarContainer.Bar;
	local _minHealth, maxHealth = healthBar:GetMinMaxValues();
	if not self.unit or maxHealth <= 0 then
		self.hasActiveAbsorb = false;
		self:HideHealthOverlays();
		return;
	end

	local health = healthBar:GetValue();
	local totalAbsorb = UnitGetTotalAbsorbs(self.unit) or 0;
	local healAbsorb = UnitGetTotalHealAbsorbs(self.unit) or 0;
	self.hasActiveAbsorb = totalAbsorb > 0;

	if self.hasActiveAbsorb then
		self:CancelDamageHealth();
	end

	if healAbsorb > health then
		healthBar.OverHealAbsorbGlow:Show();
		healAbsorb = health;
	else
		healthBar.OverHealAbsorbGlow:Hide();
	end

	local healthTexture = healthBar:GetStatusBarTexture();
	if healAbsorb > 0 then
		local healAbsorbPercent = healAbsorb / maxHealth;
		healthBar.HealAbsorbBar:UpdateFillPosition(healthTexture, healAbsorb, -healAbsorbPercent);
		healthBar.HealAbsorbBar.LeftShadow:Show();
		healthBar.HealAbsorbBar.RightShadow:SetShown(totalAbsorb > 0);
	else
		healthBar.HealAbsorbBar:Hide();
		healthBar.HealAbsorbBar.LeftShadow:Hide();
		healthBar.HealAbsorbBar.RightShadow:Hide();
	end

end

function PersonalGrowingResourceDisplayMixin:AnimateResourceWidths(healthWidth, energyWidth, absorbWidth)
	if self.resourceWidthTargetHealth == healthWidth and self.resourceWidthTargetEnergy == energyWidth and self.resourceWidthTargetAbsorb == absorbWidth then
		return;
	end

	self.resourceWidthTargetHealth = healthWidth;
	self.resourceWidthTargetEnergy = energyWidth;
	self.resourceWidthTargetAbsorb = absorbWidth;
	self.resourceWidthAnimationStartHealth = self.HealthBarContainer:GetWidth();
	self.resourceWidthAnimationStartEnergy = self.EnergyBarContainer:GetWidth();
	self.resourceWidthAnimationStartAbsorb = self.AbsorbBarContainer.Bar:GetWidth();
	self.resourceWidthAnimationElapsed = 0;
	self:SetScript("OnUpdate", self.OnUpdate);
end

function PersonalGrowingResourceDisplayMixin:UpdateHealth()
	if not UnitIsConnected(self.unit) then
		return;
	end

	local currentHealth = UnitHealth(self.unit);
	local maxHealth = UnitHealthMax(self.unit);
	local previousHealth = self.previousHealth;
	local maxHealthLossPercent = self:GetMaxHealthLossPercent();
	local remainingMaxHealthPercent = math.max(1 - maxHealthLossPercent, 0.01);
	local unmodifiedMaxHealth = maxHealth / remainingMaxHealthPercent;

	-- Scale the full health envelope so temporary loss can occupy its right side.
	-- The -13 value is how large a player's initial barrier will be when they log in
	-- for the very first time.
	local widthRatio = math.min(1, unmodifiedMaxHealth / self.maxHealthCap);
	local containerWidth = math.max(1, widthRatio * self.barMaxWidth - 13);

	self.previousHealth = currentHealth;
	self.maxHealthLossPercent = maxHealthLossPercent;

	self.HealthBarContainer.Bar:SetMinMaxValues(0, maxHealth);
	self.HealthBarContainer.Bar:SetValue(currentHealth);
	self.HealthBarContainer.DamageHealth:SetMinMaxValues(0, maxHealth);
	self:AnimateResourceWidths(containerWidth, self.resourceWidthTargetEnergy or self.EnergyBarContainer:GetWidth(), self.resourceWidthTargetAbsorb or self.AbsorbBarContainer.Bar:GetWidth());
	self:ApplyHealthBarWidth();
	self:UpdateAbsorb();
	self:UpdateHealthOverlays();

	if self.unit == "player" and not self.hasActiveAbsorb and previousHealth and currentHealth < previousHealth then
		local damageHealth = self.HealthBarContainer.DamageHealth;
		local damageHealthActive = self.damageHealthLingerElapsed or self.damageHealthAnimationStarted;
		if not damageHealthActive then
			damageHealth:SetValue(previousHealth);
		end
		if damageHealth.DamageHealthAnimation:IsPlaying() then
			damageHealth.DamageHealthAnimation:Stop();
		end
		damageHealth:SetAlpha(1);
		damageHealth:Show();
		self.damageHealthLingerElapsed = 0;
		self:SetScript("OnUpdate", self.OnUpdate);

		self.DamageBorderAnimation:Restart();
	end
end

function PersonalGrowingResourceDisplayMixin:UpdateEnergy()
	if not UnitIsConnected(self.unit) then
		return;
	end

	local currentEnergy = UnitPower(self.unit, Enum.PowerType.Energy);
	local maxEnergy = UnitPowerMax(self.unit, Enum.PowerType.Energy);

	-- Scale the container width based on max energy relative to the cap
	local widthRatio = math.min(1, maxEnergy / self.maxEnergyCap);
	local containerWidth = math.max(1, widthRatio * self.barMaxWidth);

	self:AnimateResourceWidths(self.resourceWidthTargetHealth or self.HealthBarContainer:GetWidth(), containerWidth, self.resourceWidthTargetAbsorb or self.AbsorbBarContainer.Bar:GetWidth());
	self.EnergyBarContainer.Bar:SetMinMaxValues(0, maxEnergy);
	self.EnergyBarContainer.Bar:SetValue(currentEnergy);
	self:UpdateEnergyHoverText();
end

function PersonalGrowingResourceDisplayMixin:UpdateAbsorb()
	if not UnitIsConnected(self.unit) then
		return;
	end

	local totalAbsorb = UnitGetTotalAbsorbs(self.unit) or 0;
	self.absorbWasReduced = self.totalAbsorb and totalAbsorb < self.totalAbsorb;
	self.totalAbsorb = totalAbsorb;
	local absorbWidthRatio = math.min(1, totalAbsorb / (1 * self.maxHealthCap));
	local containerWidth = math.max(1, absorbWidthRatio * self.barMaxWidth);
	local absorbBar = self.AbsorbBarContainer.Bar;

	absorbBar:SetMinMaxValues(0, math.max(1, totalAbsorb));
	absorbBar:SetValue(totalAbsorb);
	absorbBar:SetShown(totalAbsorb > 0);
	self:AnimateResourceWidths(self.resourceWidthTargetHealth or self.HealthBarContainer:GetWidth(), self.resourceWidthTargetEnergy or self.EnergyBarContainer:GetWidth(), containerWidth);
	self:UpdateHealthHoverText();
end

function PersonalGrowingResourceDisplayMixin:UpdateMaxManaPips()
	if not UnitIsConnected(self.unit) then
		return;
	end

	local maxMana = UnitPowerMax(self.unit, Enum.PowerType.Mana);
	local numPips = math.min(self.maxManaPips, math.floor(maxMana / MANA_PER_PIP));

	-- Only rebuild if pip count changed
	if self.currentPipCount == numPips then
		return;
	end

	self.currentPipCount = numPips;

	for i, pip in ipairs(self.manaPipTable) do
		if i <= numPips then
			pip:Setup();
		else
			pip:Hide();
		end
	end

	self.ManaPipContainer.spacing = self.manaPipSpacing or 2;
	self.ManaPipContainer:Layout();
	self:UpdateGroupWidth();

	self:UpdateManaPips();
end

function PersonalGrowingResourceDisplayMixin:UpdateManaPips()
	if not UnitIsConnected(self.unit) then
		return;
	end

	local currentMana = UnitPower(self.unit, Enum.PowerType.Mana);
	local filledPips = math.floor(currentMana / MANA_PER_PIP);

	for i = 1, #self.manaPipTable do
		self.manaPipTable[i]:SetActive(i <= filledPips);
	end
end

local function InitializePersonalGrowingResourceDisplay()
	-- Hide the party frame
	if PartyFrame then
		PartyFrame:SetShown(false);
		PartyFrame:UnregisterAllEvents();
	end

	-- Hide the standard Personal Resource Display if it exists
	if PersonalResourceDisplayFrame then
		PersonalResourceDisplayFrame:SetShown(false);
		PersonalResourceDisplayFrame:UnregisterAllEvents();
	end

	-- Show the personal player resource display

	local healthBarContainer = PersonalGrowingResourceDisplay.HealthBarContainer;
	local healthBar = healthBarContainer.Bar;
	local healthHoverText = healthBar.HealthHoverText;
	healthHoverText:SetScale(1.1);
	healthHoverText:Hide();
	PersonalGrowingResourceDisplay.HealthHoverText = healthHoverText;

	local energyBarContainer = PersonalGrowingResourceDisplay.EnergyBarContainer;
	local energyBar = energyBarContainer.Bar;
	local energyHoverText = energyBar.EnergyHoverText;
	energyHoverText:Hide();
	PersonalGrowingResourceDisplay.EnergyHoverText = energyHoverText;

	PersonalGrowingResourceDisplay:SetScript("OnEnter", function(frame)
		frame.HealthHoverText:Show();
		frame.EnergyHoverText:Show();
		frame:UpdateHealthHoverText();
		frame:UpdateEnergyHoverText();
		UnitFrame_OnEnter(frame);
	end);
	PersonalGrowingResourceDisplay:SetScript("OnLeave", function(frame)
		frame.HealthHoverText:Hide();
		frame.EnergyHoverText:Hide();
		UnitFrame_OnLeave(frame);
	end);

	PersonalGrowingResourceDisplay:Show();

	-- Initialize the party container
	EventRegistry:RegisterCallback("ChatFrame.ButtonSideUpdated", PartyGrowingResourceContainer.UpdateAnchor, PartyGrowingResourceContainer);
	EventRegistry:RegisterCallback("ChatFrame.DockSizeChanged", PartyGrowingResourceContainer.UpdateAnchor, PartyGrowingResourceContainer);

	-- Restore saved anchor state
	local savedAnchored = not (WoWHackPartyFrameSettings and WoWHackPartyFrameSettings.isAnchoredToDock == false);

	PartyGrowingResourceContainer:Show();
	PartyGrowingResourceContainer:SetAnchoredToDock(savedAnchored);
end

-- Run initialization after the addon loads
EventUtil.ContinueOnAddOnLoaded("Blizzard_PersonalGrowingResourceDisplay", InitializePersonalGrowingResourceDisplay);
