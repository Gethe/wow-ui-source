local PRD_ENABLED_CVAR = "nameplateShowSelf";

local PERSONAL_RESOURCE_DISPLAY_ON_LOAD_EVENTS = {
	"PLAYER_IN_COMBAT_CHANGED",
};

local PERSONAL_RESOURCE_DISPLAY_ON_SHOW_EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_TALENT_UPDATE",
	"PLAYER_SPECIALIZATION_CHANGED",
};

local PERSONAL_RESOURCE_DISPLAY_ON_SHOW_UNIT_EVENTS = {
	"UNIT_AURA",
	"UNIT_POWER_FREQUENT",
	"UNIT_MAXPOWER",
	"UNIT_DISPLAYPOWER",
	"UNIT_SPELLCAST_START",
	"UNIT_SPELLCAST_STOP",
	"UNIT_SPELLCAST_FAILED",
	"PLAYER_GAINS_VEHICLE_DATA",
	"PLAYER_LOSES_VEHICLE_DATA",
	"UNIT_HEALTH",
	"UNIT_MAXHEALTH",
	"UNIT_MAX_HEALTH_MODIFIERS_CHANGED",
	"UNIT_HEAL_PREDICTION",
	"UNIT_ABSORB_AMOUNT_CHANGED",
	"UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
};

-- This mapping assumes one template for the class. If the bar should only show for certain specs,
-- the base template should handle that. If a class should ever have two different bars for different specs, either
-- the base template should handle that or this mapping should be changed to account for that and the class spec should be checked.
local CLASS_FRAME_INFO_MAP = {
	[Constants.UICharacterClasses.Paladin] = {
		template = "PaladinPowerBarFrameTemplate",
		yOffset = -14,
	},
	[Constants.UICharacterClasses.Rogue] = {
		template = "RogueComboPointBarTemplate",
		yOffset = -10,
	},
	[Constants.UICharacterClasses.DeathKnight] = {
		template = "RuneFrameTemplate",
		yOffset = -10,
	},
	[Constants.UICharacterClasses.Mage] = {
		template = "MageArcaneChargesFrameTemplate",
		yOffset = -8,
		updatePowerFunc = function(frame)
			local numCharges = UnitPower(frame:GetUnit(), frame.powerType, true);
			for i = 1, #frame.classResourceButtonTable do
				frame.classResourceButtonTable[i]:SetActive(i <= numCharges);
			end
		end,
	},
	[Constants.UICharacterClasses.Warlock] = {
		template = "WarlockPowerFrameTemplate",
		yOffset = -8,
	},
	[Constants.UICharacterClasses.Monk] = {
		template = "MonkHarmonyBarFrameTemplate",
		yOffset = -8,
	},
	[Constants.UICharacterClasses.Druid] = {
		template = "DruidComboPointBarTemplate",
		yOffset = -8,
	},
	[Constants.UICharacterClasses.Evoker] = {
		template = "EssencePlayerFrameTemplate",
		yOffset = -12,
	},
};

-- This mapping makes similar assumptions to CLASS_FRAME_INFO_MAP. Ideally the alternate power mixin
-- should handle any cases where there are different/multiple alt power bars for a given class/spec.
local CLASS_ALT_POWER_BAR_INFO_MAP = {
	[Constants.UICharacterClasses.DemonHunter] = {
		mixin = DemonHunterAlternatePowerBarMixin,
	},
	[Constants.UICharacterClasses.Evoker] = {
		mixin = EvokerAlternatePowerBarMixin,
	},
	[Constants.UICharacterClasses.Monk] = {
		mixin = MonkAlternatePowerBarMixin,
	},
	[Constants.UICharacterClasses.Priest] = {
		mixin = PriestAlternatePowerBarMixin,
	},
	[Constants.UICharacterClasses.Druid] = {
		mixin = DruidAlternatePowerBarMixin,
	},
};

local HEAL_PREDICTION_COLOR = { r = 0.0, g = 0.659, b = 0.608 };
local MANA_BAR_COLOR = {
	["MANA"] = { r = 0.1, g = 0.25, b = 1.00, predictionColor = POWERBAR_PREDICTION_COLOR_MANA }
};

local function ClassFrameInfoForClassID(classID)
	return CLASS_FRAME_INFO_MAP[classID];
end

local function ClassAltPowerBarInfoForClassID(classID)
	return CLASS_ALT_POWER_BAR_INFO_MAP[classID];
end

PersonalResourceDisplayMixin = {};

function PersonalResourceDisplayMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, PERSONAL_RESOURCE_DISPLAY_ON_LOAD_EVENTS);
	CVarCallbackRegistry:RegisterCallback(PRD_ENABLED_CVAR, self.UpdateShownState, self);

	self.defaultBarWidth = self:GetWidth();
	EditModeSystemMixin.OnSystemLoad(self);
end

function PersonalResourceDisplayMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, PERSONAL_RESOURCE_DISPLAY_ON_SHOW_EVENTS);
	FrameUtil.RegisterFrameForUnitEvents(self, PERSONAL_RESOURCE_DISPLAY_ON_SHOW_UNIT_EVENTS, "player");

	self:Setup();

	-- Refresh max health, current health, health prediction, and max power on show.
	-- We might be hiding this frame out of combat which means we're not registered for health or power updates.
	-- Ex. You take damage while out of combat, then enter combat, or your max health/power changes because you switched specs.
	self:UpdateMaxHealth();
	self:UpdateHealthPrediction();
	-- If the spec changed while hidden, fully refresh the power bar and alternate power bar.
	-- Otherwise a simple max power update is sufficient.
	local currentSpec = C_SpecializationInfo.GetSpecialization();
	if currentSpec ~= self.lastKnownSpec then
		self:UpdatePowerBar();
		self:UpdateAlternatePowerBar();
		self.lastKnownSpec = currentSpec;
	else
		self:UpdateMaxPower();
	end
end

function PersonalResourceDisplayMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, PERSONAL_RESOURCE_DISPLAY_ON_SHOW_EVENTS);
	FrameUtil.UnregisterFrameForEvents(self, PERSONAL_RESOURCE_DISPLAY_ON_SHOW_UNIT_EVENTS);
end

function PersonalResourceDisplayMixin:Setup()
	if not self.hasBeenSetup then
		self.hasBeenSetup = true;

		self:SetupClass();
		self:SetupHealthBar();
		self:SetupPowerBar();
		self:SetupAlternatePowerBar();
		self:SetupClassBar();
		self:UpdateFrameHeight();
		self.lastKnownSpec = C_SpecializationInfo.GetSpecialization();
	end
end

function PersonalResourceDisplayMixin:SetIsInEditMode(isInEditMode)
	self.isInEditMode = isInEditMode;
	self:UpdateShownState();
end

function PersonalResourceDisplayMixin:SetVisibleSetting(visibleSetting)
	self.visibleSetting = visibleSetting;
	self:UpdateShownState();
end

function PersonalResourceDisplayMixin:GetVisibleSetting()
	return self.visibleSetting or Enum.PersonalResourceDisplayVisibleSetting.Always;
end

function PersonalResourceDisplayMixin:UpdateShownState()
	local personalResourceDisplayEnabled = C_GameRules.IsPersonalResourceDisplayEnabled();
	local visibleSetting = self:GetVisibleSetting();

	if self.isInEditMode then
		self:Show();
	elseif personalResourceDisplayEnabled and visibleSetting == Enum.PersonalResourceDisplayVisibleSetting.Always then
		self:Show();
	elseif personalResourceDisplayEnabled and visibleSetting == Enum.PersonalResourceDisplayVisibleSetting.InCombat and UnitAffectingCombat("player") then
		self:Show();
	else
		self:Hide();
	end
end

function PersonalResourceDisplayMixin:OnEvent(event, ...)
	if event == "UNIT_HEALTH" then
		self:UpdateHealth();
		self:UpdateHealthPrediction();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UpdateMaxHealth();
		self:UpdateHealthPrediction();
		self:UpdatePowerBar();
		self:UpdateAlternatePowerBar();
	elseif event == "UNIT_MAXHEALTH" or event == "UNIT_MAX_HEALTH_MODIFIERS_CHANGED" then
		self:UpdateMaxHealth();
		self:UpdateHealthPrediction();
	elseif event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
		self:UpdateHealthPrediction();
	elseif event == "UNIT_POWER_FREQUENT" then
		local _unitTag, powerToken = ...;
		if self.powerToken == powerToken then
			self:UpdatePower();
		end
	elseif event == "UNIT_MAXPOWER" then
		local _unitTag, powerToken = ...;
		if self.powerToken == powerToken then
			self:UpdateMaxPower();
		end
	elseif event == "UNIT_DISPLAYPOWER" or event == "PLAYER_TALENT_UPDATE" then
		self:UpdatePowerBar();
		self:UpdateAlternatePowerBar();
	elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" then
		self:UpdatePredictedPowerCost(event == "UNIT_SPELLCAST_START");
		self:UpdatePower();
	elseif event == "PLAYER_GAINS_VEHICLE_DATA" or event == "PLAYER_LOSES_VEHICLE_DATA" then
		self:UpdatePowerBar();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:UpdatePowerBar();
		self:UpdateAlternatePowerBar();
		self:UpdateFrameHeight();
		self.lastKnownSpec = C_SpecializationInfo.GetSpecialization();
	elseif event == "UNIT_AURA" then
		if self.AlternatePowerBar and self.AlternatePowerBar.UpdateAuraState then
			self.AlternatePowerBar:UpdateAuraState();
		end
	elseif event == "PLAYER_IN_COMBAT_CHANGED" then
		self:UpdateShownState();
	end
end

function PersonalResourceDisplayMixin:OnUpdate()
	if not self.predictedPowerCost then
		local queryCurrentCastingInfo = true;
		self:UpdatePredictedPowerCost(queryCurrentCastingInfo);
	end

	local currPowerValue = UnitPower("player", self.powerType) - self.predictedPowerCost;
	local oldValue = self.currPowerValue or 0;

	if currPowerValue ~= self.currPowerValue and self.PowerBar:IsShown() then
		-- Only show anim if change is more than 10%
		local feedbackMaxValue = self.PowerBar.FeedbackFrame:GetMaxValue();
		if feedbackMaxValue ~= 0 and (math.abs(currPowerValue - oldValue) / feedbackMaxValue) > 0.1 then
			self.PowerBar.FeedbackFrame:StartFeedbackAnim(oldValue, currPowerValue);
		end
		if self.PowerBar.FullPowerFrame.active then
			self.PowerBar.FullPowerFrame:StartAnimIfFull(currPowerValue);
		end
		self.currPowerValue = currPowerValue;
	end
end

function PersonalResourceDisplayMixin:SetupClass()
	self.classID = select(3, UnitClass("player"));
end

function PersonalResourceDisplayMixin:HasClassInfo()
	if not self.classFrame then
		return false;
	end

	local shouldShowBarFunc = self.classFrame.shouldShowBarFunc;
	if shouldShowBarFunc and not shouldShowBarFunc(self.classFrame) then
		return false;
	end

	return true;
end

function PersonalResourceDisplayMixin:HasAlternatePowerBar()
	local classAltPowerBarInfo = ClassAltPowerBarInfoForClassID(self.classID);
	if not classAltPowerBarInfo then
		return false;
	end

	return self.AlternatePowerBar.alternatePowerRequirementsMet;
end

-- NOTE: Textures, colors, etc. here are similar to old PRD and the PlayerFrame. They aren't shared, so they can be more easily changed later.
function PersonalResourceDisplayMixin:SetupHealthBar()
	-- Set shortcuts to access PRD healthbar and tempMaxHealthLossBar
	self.healthbar = self.HealthBarsContainer.healthBar;
	self.tempMaxHealthLossBar = self.HealthBarsContainer.TempMaxHealthLoss;

	-- Setup container border, healthbar statusbar color, and init the temp max health loss
	self.tempMaxHealthLossBar:InitializeMaxHealthLossBar(self.HealthBarsContainer, self.healthbar);

	-- Setup totalAbsorb + overlay
	local tileVertically = true;
	local tileHorizontally = true;
	self.healthbar.totalAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Fill");
	self.healthbar.totalAbsorb.overlay = self.healthbar.totalAbsorbOverlay;
	self.healthbar.totalAbsorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", tileVertically, tileHorizontally);
	self.healthbar.totalAbsorbOverlay.tileSize = 32;
	self.healthbar.totalAbsorb:ClearAllPoints();
	self.healthbar.totalAbsorbOverlay:SetAllPoints(self.healthbar.totalAbsorb);

	-- Setup overAbsorbGlow and overHealGlow
	self.healthbar.overAbsorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield");
	self.healthbar.overAbsorbGlow:SetBlendMode("ADD");
	self.healthbar.overAbsorbGlow:ClearAllPoints();
	PixelUtil.SetPoint(self.healthbar.overAbsorbGlow, "BOTTOMLEFT", self.healthbar, "BOTTOMRIGHT", -4, -1);
	PixelUtil.SetPoint(self.healthbar.overAbsorbGlow, "TOPLEFT", self.healthbar, "TOPRIGHT", -4, 1);
	PixelUtil.SetHeight(self.healthbar.overAbsorbGlow, 8);

	self.healthbar.overHealAbsorbGlow:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb");
	self.healthbar.overHealAbsorbGlow:SetBlendMode("ADD");
	self.healthbar.overHealAbsorbGlow:ClearAllPoints();
	PixelUtil.SetPoint(self.healthbar.overHealAbsorbGlow, "BOTTOMRIGHT", self.healthbar, "BOTTOMLEFT", 2, -1);
	PixelUtil.SetPoint(self.healthbar.overHealAbsorbGlow, "TOPRIGHT", self.healthbar, "TOPLEFT", 2, 1);
	PixelUtil.SetWidth(self.healthbar.overHealAbsorbGlow, 8);

	-- Setup heal predictions
	self.healthbar.myHealPrediction:ClearAllPoints();
	self.healthbar.myHealPrediction:SetVertexColor(HEAL_PREDICTION_COLOR.r, HEAL_PREDICTION_COLOR.g, HEAL_PREDICTION_COLOR.b);
	self.healthbar.otherHealPrediction:ClearAllPoints();
	self.healthbar.otherHealPrediction:SetVertexColor(HEAL_PREDICTION_COLOR.r, HEAL_PREDICTION_COLOR.g, HEAL_PREDICTION_COLOR.b);
end

function PersonalResourceDisplayMixin:UpdateMaxHealth()
	local maxHealth = UnitHealthMax("player");
	self.healthbar:SetMinMaxValues(0, maxHealth);
	self:UpdateHealth();
end

function PersonalResourceDisplayMixin:UpdateHealth()
	local currHealth = UnitHealth("player");
	self.healthbar:SetValue(currHealth);
	if self.tempMaxHealthLossBar and self.tempMaxHealthLossBar.initialized then
		self.tempMaxHealthLossBar:OnMaxHealthModifiersChanged(GetUnitTotalModifiedMaxHealthPercent("player"));
	end
end

function PersonalResourceDisplayMixin:GetDefaultHealthColor()
	return PERSONAL_RESOURCE_DISPLAY_DEFAULT_HEALTH_COLOR;
end

function PersonalResourceDisplayMixin:GetDesiredHealthColor()
	if self.showClassColor then
		local classFilename = PlayerUtil.GetClassFile();
		if classFilename then
			return RAID_CLASS_COLORS[classFilename] or self:GetDefaultHealthColor();
		end
	end

	return self:GetDefaultHealthColor();
end

function PersonalResourceDisplayMixin:UpdateHealthColor()
	local healthColor = self:GetDesiredHealthColor();
	if healthColor then
		self.healthbar:SetStatusBarColor(healthColor:GetRGB());
	end
end

function PersonalResourceDisplayMixin:UpdateBarWidth()
	local barWidthPercent = self:GetBarWidth();
	local newWidth = self.defaultBarWidth * barWidthPercent / 100;
	self:SetWidth(newWidth);
	self.HealthBarsContainer:SetWidth(newWidth);
	self.PowerBar:SetWidth(newWidth);
	self.AlternatePowerBar:SetWidth(newWidth);
	self.ClassFrameContainer:SetWidth(newWidth);
end

--WARNING: This function is very similar to the function CompactUnitFrame_UpdateHealPrediction in CompactUnitFrame.lua.
--If you are making changes here, it is possible you may want to make changes there as well.
function PersonalResourceDisplayMixin:UpdateHealthPrediction()
	local _, maxHealth = self.healthbar:GetMinMaxValues();
	local health = self.healthbar:GetValue();

	if maxHealth <= 0 then
		return;
	end

	local myIncomingHeal = UnitGetIncomingHeals("player", "player") or 0;
	local allIncomingHeal = UnitGetIncomingHeals("player") or 0;
	local totalAbsorb = UnitGetTotalAbsorbs("player") or 0;

	--We don't fill outside the health bar with healAbsorbs.  Instead, an overHealAbsorbGlow is shown.
	local myCurrentHealAbsorb = UnitGetTotalHealAbsorbs("player") or 0;

	if health < myCurrentHealAbsorb then
		self.healthbar.overHealAbsorbGlow:Show();
		myCurrentHealAbsorb = health;
	else
		self.healthbar.overHealAbsorbGlow:Hide();
	end

	--Make sure we don't go out of the frame.
	if health - myCurrentHealAbsorb + allIncomingHeal > maxHealth then
		allIncomingHeal = maxHealth - health + myCurrentHealAbsorb;
	end

	local otherIncomingHeal = 0;

	--Split up incoming heals.
	if allIncomingHeal >= myIncomingHeal then
		otherIncomingHeal = allIncomingHeal - myIncomingHeal;
	else
		myIncomingHeal = allIncomingHeal;
	end

	local overAbsorb = false;
	--We don't fill outside the the health bar with absorbs.  Instead, an overAbsorbGlow is shown.
	if health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth then
		if totalAbsorb > 0 then
			overAbsorb = true;
		end

		if allIncomingHeal > myCurrentHealAbsorb then
			totalAbsorb = max(0,maxHealth - (health - myCurrentHealAbsorb + allIncomingHeal));
		else
			totalAbsorb = max(0,maxHealth - health);
		end
	end
	if overAbsorb then
		self.healthbar.overAbsorbGlow:Show();
	else
		self.healthbar.overAbsorbGlow:Hide();
	end

	local healthTexture = self.healthbar:GetStatusBarTexture();

	local myCurrentHealAbsorbPercent = myCurrentHealAbsorb / maxHealth;

	local healAbsorbTexture = nil;

	--If allIncomingHeal is greater than myCurrentHealAbsorb, then the current
	--heal absorb will be completely overlayed by the incoming heals so we don't show it.
	if myCurrentHealAbsorb > allIncomingHeal then
		local shownHealAbsorb = myCurrentHealAbsorb - allIncomingHeal;
		local shownHealAbsorbPercent = shownHealAbsorb / maxHealth;
		healAbsorbTexture = CompactUnitFrameUtil_UpdateFillBar(self.HealthBarsContainer, healthTexture, self.healthbar.myHealAbsorb, shownHealAbsorb, -shownHealAbsorbPercent);

		--If there are incoming heals the left shadow would be overlayed by the incoming heals
		--so it isn't shown.
		if allIncomingHeal > 0 then
			self.healthbar.myHealAbsorbLeftShadow:Hide();
		else
			self.healthbar.myHealAbsorbLeftShadow:SetPoint("TOPLEFT", healAbsorbTexture, "TOPLEFT", 0, 0);
			self.healthbar.myHealAbsorbLeftShadow:SetPoint("BOTTOMLEFT", healAbsorbTexture, "BOTTOMLEFT", 0, 0);
			self.healthbar.myHealAbsorbLeftShadow:Show();
		end

		-- The right shadow is only shown if there are absorbs on the health bar.
		if totalAbsorb > 0 then
			self.healthbar.myHealAbsorbRightShadow:SetPoint("TOPLEFT", healAbsorbTexture, "TOPRIGHT", -8, 0);
			self.healthbar.myHealAbsorbRightShadow:SetPoint("BOTTOMLEFT", healAbsorbTexture, "BOTTOMRIGHT", -8, 0);
			self.healthbar.myHealAbsorbRightShadow:Show();
		else
			self.healthbar.myHealAbsorbRightShadow:Hide();
		end
	else
		self.healthbar.myHealAbsorb:Hide();
		self.healthbar.myHealAbsorbRightShadow:Hide();
		self.healthbar.myHealAbsorbLeftShadow:Hide();
	end

	--Show myIncomingHeal on the health bar.
	local incomingHealsTexture = CompactUnitFrameUtil_UpdateFillBar(self.HealthBarsContainer, healthTexture, self.healthbar.myHealPrediction, myIncomingHeal, -myCurrentHealAbsorbPercent);
	--Append otherIncomingHeal on the health bar.
	incomingHealsTexture = CompactUnitFrameUtil_UpdateFillBar(self.HealthBarsContainer, incomingHealsTexture, self.healthbar.otherHealPrediction, otherIncomingHeal);

	--Append absorbs to the correct section of the health bar.
	local appendTexture = nil;
	if healAbsorbTexture then
		--If there is a healAbsorb part shown, append the absorb to the end of that.
		appendTexture = healAbsorbTexture;
	else
		--Otherwise, append the absorb to the end of the the incomingHeals part;
		appendTexture = incomingHealsTexture;
	end
	CompactUnitFrameUtil_UpdateFillBar(self.HealthBarsContainer, appendTexture, self.healthbar.totalAbsorb, totalAbsorb)
end

function PersonalResourceDisplayMixin:SetupPowerBar()
	-- Prediction Bar
	local statusBarTexture = self.PowerBar:GetStatusBarTexture();
	self.PowerBar.ManaCostPredictionBar:ClearAllPoints();
	self.PowerBar.ManaCostPredictionBar:SetPoint("TOPLEFT", statusBarTexture, "TOPRIGHT", 0, 0);
	self.PowerBar.ManaCostPredictionBar:SetPoint("BOTTOMLEFT", statusBarTexture, "BOTTOMRIGHT", 0, 0);

	self:UpdatePowerBar();
end

function PersonalResourceDisplayMixin:UpdatePowerBar()
	-- Power Bar
	local powerType, powerToken, altR, altG, altB = UnitPowerType("player");
	local info;
	if powerToken then
		info = MANA_BAR_COLOR[powerToken] or PowerBarColor[powerToken];
		if not info then
			if altR then
				info = CreateColor(altR, altG, altB);
			else
				info = PowerBarColor[powerType];
			end
		end
		self.PowerBar:SetStatusBarColor(info.r, info.g, info.b);

		-- PRD mana bar uses only solid color (no atlases), ensure its feedback frame does the same
		local colorOnlyInfo = { r = info.r, g = info.g, b = info.b };
		self.PowerBar.FeedbackFrame:Initialize(colorOnlyInfo, "player", powerType);

		self.PowerBar.FullPowerFrame:SetSize(86, 6);
		self.PowerBar.FullPowerFrame.SpikeFrame:SetSize(86, 6);
		self.PowerBar.FullPowerFrame.PulseFrame:SetSize(86, 6);
		self.PowerBar.FullPowerFrame.SpikeFrame.AlertSpikeStay:SetSize(30, 12);
		self.PowerBar.FullPowerFrame.PulseFrame.YellowGlow:SetSize(20, 20);
		self.PowerBar.FullPowerFrame.PulseFrame.SoftGlow:SetSize(20, 20);
		self.PowerBar.FullPowerFrame:Initialize(info.fullPowerAnim);
	end

	if self.powerToken ~= powerToken or self.powerType ~= powerType then
		self.powerToken = powerToken;
		self.powerType = powerType;
		self.PowerBar.FullPowerFrame:RemoveAnims();

		local queryCurrentCastingInfo = true;
		self:UpdatePredictedPowerCost(queryCurrentCastingInfo);

		if self.PowerBar.ManaCostPredictionBar then
			local predictionColor;
			if info and info.predictionColor then
				predictionColor = info.predictionColor;
			else
				-- No prediction color set, default to mana prediction color
				predictionColor = POWERBAR_PREDICTION_COLOR_MANA;
			end

			self.PowerBar.ManaCostPredictionBar:SetVertexColor(predictionColor:GetRGBA());
		end
	end

	if not self.predictedPowerCost then
		local queryCurrentCastingInfo = true;
		self:UpdatePredictedPowerCost(queryCurrentCastingInfo);
	end

	self.currPowerValue = UnitPower("player", powerType) - self.predictedPowerCost;

	self:UpdateMaxPower();
end

function PersonalResourceDisplayMixin:SetHealthBarHeight(barHeight)
	self.HealthBarsContainer:SetHeight(barHeight);
	self:UpdateFrameHeight();
end

function PersonalResourceDisplayMixin:SetPowerBarHeight(barHeight)
	self.PowerBar:SetHeight(barHeight);
	self.AlternatePowerBar:SetHeight(barHeight);
	self:UpdateFrameHeight();
end

function PersonalResourceDisplayMixin:GetBarWidth()
	return self.barWidthPercent or 100;
end

function PersonalResourceDisplayMixin:SetBarWidth(barWidthPercent)
	self.barWidthPercent = barWidthPercent;
	self:UpdateBarWidth();
end

function PersonalResourceDisplayMixin:GetMinimumBarPadding()
	local MINIMUM_PADDING = 4;
	return MINIMUM_PADDING;
end

function PersonalResourceDisplayMixin:GetBarPadding()
	return (self.barPadding or 0) + self:GetMinimumBarPadding();
end

function PersonalResourceDisplayMixin:UpdatePowerBarAnchor()
	self.PowerBar:ClearAllPoints();
	if self.hideHealth then
		self.PowerBar:SetPoint("TOP", self, "TOP", 0, 0);
	else
		self.PowerBar:SetPoint("TOP", self.HealthBarsContainer, "BOTTOM", 0, -self:GetBarPadding());
	end
end

function PersonalResourceDisplayMixin:SetBarPadding(padding)
	self.barPadding = padding;
	self:UpdatePowerBarAnchor();
	self:UpdateAdditionalBarAnchors();
end

function PersonalResourceDisplayMixin:SetSize(size)
	self:SetScale(size / 100);
end

function PersonalResourceDisplayMixin:SetHideHealth(hideHealth)
	self.hideHealth = hideHealth;
	self.HealthBarsContainer:SetShown(not self.hideHealth);
	self:UpdatePowerBarAnchor();
	self:UpdateAdditionalBarAnchors();
end

function PersonalResourceDisplayMixin:SetHidePower(hidePower)
	self.hidePower = hidePower;
	self.PowerBar:SetShown(not self.hidePower);
	self:UpdateAdditionalBarAnchors();
end

function PersonalResourceDisplayMixin:SetHideAltPower(hideAltPower)
	self.hideAltPower = hideAltPower;
	self.AlternatePowerBar:SetShown(not self.hideAltPower and self:HasAlternatePowerBar());
	self:UpdateAdditionalBarAnchors();
end

function PersonalResourceDisplayMixin:SetHideClassInfo(hideClassInfo)
	self.hideClassInfo = hideClassInfo;

	local classFrameInfo = ClassFrameInfoForClassID(self.classID);
	self.ClassFrameContainer:SetShown(not self.hideClassInfo and classFrameInfo);
end

function PersonalResourceDisplayMixin:SetShowClassColor(showClassColor)
	self.showClassColor = showClassColor;
	self:UpdateHealthColor();
end

function PersonalResourceDisplayMixin:SetShowBarText(showBarText)
	self.showBarText = showBarText;

	self.healthbar:SetForceShow(showBarText);
	self.PowerBar:SetForceShow(showBarText);
	self.AlternatePowerBar:SetForceShow(showBarText);
end

function PersonalResourceDisplayMixin:SetHideClassInfoOnPlayerFrame(hideClassInfoOnPlayerFrame)
	EventRegistry:TriggerEvent("PersonalResourceDisplay.HideClassInfoOnPlayerFrameChanged", hideClassInfoOnPlayerFrame);
end

function PersonalResourceDisplayMixin:UpdatePredictedPowerCost(queryCurrentCastingInfo)
	local cost = 0;

	if queryCurrentCastingInfo then
		local spellID = select(9, UnitCastingInfo("player"));

		if spellID then
			local costTable = C_Spell.GetSpellPowerCost(spellID) or {};
			for _, costInfo in pairs(costTable) do
				if costInfo.type == self.powerType then
					cost = costInfo.cost;
					break;
				end
			end
		end
	end

	self.predictedPowerCost = cost;
end

function PersonalResourceDisplayMixin:UpdateMaxPower()
	local maxValue = UnitPowerMax("player", self.powerType);
	self.PowerBar:SetMinMaxValues(0, maxValue);
	self.PowerBar.FullPowerFrame:SetMaxValue(maxValue);
	self.PowerBar.FeedbackFrame:SetMaxValue(maxValue);

	self:UpdatePower();
end

function PersonalResourceDisplayMixin:UpdatePower()
	if not self.predictedPowerCost then
		local queryCurrentCastingInfo = true;
		self:UpdatePredictedPowerCost(queryCurrentCastingInfo);
	end

	local currPowerValue = UnitPower("player", self.powerType) - self.predictedPowerCost;
	self.PowerBar:SetValue(currPowerValue);

	if self.predictedPowerCost == 0 then
		self.PowerBar.ManaCostPredictionBar:Hide();
	else
		local bar = self.PowerBar.ManaCostPredictionBar;

		local totalWidth = self.PowerBar:GetWidth();
		local _, totalMax = self.PowerBar:GetMinMaxValues();

		if totalMax <= 0 then
			self.PowerBar.ManaCostPredictionBar:Hide();
		else
			local barSize = (self.predictedPowerCost / totalMax) * totalWidth;
			bar:SetWidth(barSize);
			bar:Show();
		end
	end
end

function PersonalResourceDisplayMixin:SetupAlternatePowerBar()
	self.AlternatePowerBar:SetScript("OnShow", function() self:UpdateAdditionalBarAnchors() end);
	self.AlternatePowerBar:SetScript("OnHide", function() self:UpdateAdditionalBarAnchors() end);

	local classAltPowerBarInfo = ClassAltPowerBarInfoForClassID(self.classID);

	if classAltPowerBarInfo then
		Mixin(self.AlternatePowerBar, classAltPowerBarInfo.mixin);

		--Ensure the UpdateArt function doesn't overwrite the desired atlas.
		self.AlternatePowerBar.barTextureAtlas = self.AlternatePowerBar:GetStatusBarTexture():GetAtlas();

		self.AlternatePowerBar:SetScript("OnUpdate", function()
			self.AlternatePowerBar:UpdatePower();
		end);

		self:UpdateAlternatePowerBar();
	else
		self.AlternatePowerBar.alternatePowerRequirementsMet = false;
		self.AlternatePowerBar:Hide();
	end
end

function PersonalResourceDisplayMixin:UpdateAlternatePowerBar()
	local classAltPowerBarInfo = ClassAltPowerBarInfoForClassID(self.classID);

	if classAltPowerBarInfo then
		self.AlternatePowerBar:Initialize();

		if self.hideAltPower or not self:HasAlternatePowerBar() then
			self.AlternatePowerBar:Hide();
		else
			self.AlternatePowerBar:Show();
		end
	end
end

function PersonalResourceDisplayMixin:SetupClassBar()
	self.ClassFrameContainer:SetScript("OnShow", function() self:UpdateAdditionalBarAnchors() end);
	self.ClassFrameContainer:SetScript("OnHide", function() self:UpdateAdditionalBarAnchors() end);

	local classFrameInfo = ClassFrameInfoForClassID(self.classID);

	if classFrameInfo then
		if not self.classFrame then
			self.classFrame = FrameUtil.CreateFrame(nil, self.ClassFrameContainer, classFrameInfo.template);

			if classFrameInfo.updatePowerFunc then
				self.classFrame.UpdatePower = function() classFrameInfo.updatePowerFunc(self.classFrame) end;
			end

			-- Some class templates inherit PlayerBottomManagedFrameTemplate which at load time calls
			-- ClearAllPoints and re-parents the frame to the player frame managed container.
			-- before CreateFrame even returns.
			self.classFrame:SetParent(self.ClassFrameContainer);
			self.classFrame:SetPoint("CENTER", self.ClassFrameContainer, "CENTER");

			-- Prevent the managed container from stomping the parent/points on any future Show.
			self.classFrame.ignoreFramePositionManager = true;

			-- Ensure the class frame doesn't self-hide when HideClassInfoOnPlayerFrame is toggled.
			self.classFrame.canBeHiddenByPersonalResourceDisplay = false;
		end

		self.ClassFrameContainer.yOffset = classFrameInfo.yOffset or 0;
		self.ClassFrameContainer:SetShown(not self.hideClassInfo);
	else
		self.ClassFrameContainer:Hide();
	end
end

-- If either additional bar is shown, ensure the anchors are correctly set for either/both
function PersonalResourceDisplayMixin:UpdateAdditionalBarAnchors()
	local alternatePowerBarShown = self.AlternatePowerBar:IsShown();
	local classFrameContainerShown = self.ClassFrameContainer:IsShown();
	local padding = self:GetBarPadding();

	if alternatePowerBarShown then
		self.AlternatePowerBar:ClearAllPoints();
		if not self.hidePower then
			self.AlternatePowerBar:SetPoint("TOP", self.PowerBar, "BOTTOM", 0, -padding);
		elseif not self.hideHealth then
			self.AlternatePowerBar:SetPoint("TOP", self.HealthBarsContainer, "BOTTOM", 0, -padding);
		else
			self.AlternatePowerBar:SetPoint("TOP", self, "TOP", 0, 0);
		end
	end

	if classFrameContainerShown then
		self.ClassFrameContainer:ClearAllPoints();
		if alternatePowerBarShown then
			self.ClassFrameContainer:SetPoint("TOP", self.AlternatePowerBar, "BOTTOM", 0, self.ClassFrameContainer.yOffset - padding);
		elseif not self.hidePower then
			self.ClassFrameContainer:SetPoint("TOP", self.PowerBar, "BOTTOM", 0, self.ClassFrameContainer.yOffset - padding);
		elseif not self.hideHealth then
			self.ClassFrameContainer:SetPoint("TOP", self.HealthBarsContainer, "BOTTOM", 0, self.ClassFrameContainer.yOffset - padding);
		else
			self.ClassFrameContainer:SetPoint("TOP", self, "TOP", 0, self.ClassFrameContainer.yOffset);
		end
	end

	self:UpdateFrameHeight();
end

function PersonalResourceDisplayMixin:GetMinimumFrameHeight()
	local MINIMUM_FRAME_HEIGHT = 15;
	return MINIMUM_FRAME_HEIGHT;
end

function PersonalResourceDisplayMixin:UpdateFrameHeight()
	local totalHeight = 0;

	if not self.hideHealth then
		totalHeight = totalHeight + self.HealthBarsContainer:GetHeight();
	end

	if not self.hidePower then
		if not self.hideHealth then
			totalHeight = totalHeight + self:GetBarPadding();
		end
		totalHeight = totalHeight + self.PowerBar:GetHeight();
	end

	if self.AlternatePowerBar:IsShown() then
		if not self.hidePower or not self.hideHealth then
			totalHeight = totalHeight + self:GetBarPadding();
		end
		totalHeight = totalHeight + self.AlternatePowerBar:GetHeight();
	end

	if self.ClassFrameContainer:IsShown() and self:HasClassInfo() then
		local hasBarAboveClassFrame = not self.hidePower or not self.hideHealth or self.AlternatePowerBar:IsShown();
		if hasBarAboveClassFrame then
			totalHeight = totalHeight + self:GetBarPadding();
		end
		totalHeight = totalHeight - (self.ClassFrameContainer.yOffset or 0) + self.ClassFrameContainer:GetHeight();
	end

	self:SetHeight(math.max(totalHeight, self:GetMinimumFrameHeight()));

	if self.Selection and self.Selection:IsShown() then
		self.Selection:UpdateLabelVisibility();
	end
end
