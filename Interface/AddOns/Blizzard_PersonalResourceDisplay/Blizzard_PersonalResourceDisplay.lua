local PRD_ENABLED_CVAR = "nameplateShowSelf";

local PERSONAL_RESOURCE_DISPLAY_ON_LOAD_EVENTS = {
	"PLAYER_ENTER_COMBAT",
	"PLAYER_LEAVE_COMBAT",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_REGEN_DISABLED",
};

local PERSONAL_RESOURCE_DISPLAY_ON_SHOW_EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_TALENT_UPDATE",
	"PLAYER_SPECIALIZATION_CHANGED",
};

local PERSONAL_RESOURCE_DISPLAY_ON_SHOW_UNIT_EVENTS = {
	"UNIT_AURA",
	"UNIT_COMBAT",
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
};

local MAX_INCOMING_HEAL_OVERFLOW = 1.05;
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
	self.classID = select(3, UnitClass("player"));

	CVarCallbackRegistry:RegisterCallback(PRD_ENABLED_CVAR, self.UpdateShownState, self);

	self:SetupClassBar();
	EditModeSystemMixin.OnSystemLoad(self);
	self:UpdateShownState();
end

function PersonalResourceDisplayMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, PERSONAL_RESOURCE_DISPLAY_ON_SHOW_EVENTS);
	FrameUtil.RegisterFrameForUnitEvents(self, PERSONAL_RESOURCE_DISPLAY_ON_SHOW_UNIT_EVENTS, "player");

	self:SetupHealthBar();
	self:SetupPowerBar();
	self:SetupAlternatePowerBar();
end

function PersonalResourceDisplayMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, PERSONAL_RESOURCE_DISPLAY_ON_SHOW_EVENTS);
	FrameUtil.UnregisterFrameForEvents(self, PERSONAL_RESOURCE_DISPLAY_ON_SHOW_UNIT_EVENTS);
end

function PersonalResourceDisplayMixin:SetIsInEditMode(isInEditMode)
	self.isInEditMode = isInEditMode;
	self:UpdateShownState();
end

function PersonalResourceDisplayMixin:UpdateShownState()
	local personalResourceDisplayEnabled = C_GameRules.IsPersonalResourceDisplayEnabled();
	
	if self.isInEditMode then
		self:Show();
	elseif not self.onlyShowInCombat and personalResourceDisplayEnabled then
		self:Show();
	elseif self.onlyShowInCombat and personalResourceDisplayEnabled and UnitAffectingCombat("player") then
		self:Show();
	else
		self:Hide();
	end
end

function PersonalResourceDisplayMixin:OnEvent(event, ...)
	if not C_GameRules.IsPersonalResourceDisplayEnabled() then
		return;
	end

    if event == "UNIT_HEALTH" or event == "UNIT_MAX_HEALTH_MODIFIERS_CHANGED" then
        self:UpdateHealth();
		self:UpdateHealthPrediction();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:SetupMaxHealth();
        self:UpdateHealthPrediction();
		self:SetupPowerBar();
		self:UpdatePower();
		self:SetupAlternatePowerBar();
    elseif event == "UNIT_MAXHEALTH" then
        self:SetupMaxHealth();
        self:UpdateHealthPrediction();
    elseif event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
        self:UpdateHealthPrediction();
	elseif event == "UNIT_POWER_FREQUENT" then
		local unitTag, powerToken = ...;
		if unitTag == "player" and self.powerToken == powerToken then
			self:UpdatePower();
		end
	elseif event == "UNIT_MAXPOWER" then
		local unitTag = ...;
		if unitTag == "player" then
			self:UpdateMaxPower();
		end
	elseif event == "UNIT_DISPLAYPOWER" or event == "PLAYER_TALENT_UPDATE" then
		self:SetupPowerBar();
		self:UpdatePower();
		self:SetupAlternatePowerBar();
	elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" then
		self:UpdatePredictedPowerCost(event == "UNIT_SPELLCAST_START");
		self:SetupPowerBar();
	elseif event == "PLAYER_GAINS_VEHICLE_DATA" or event == "PLAYER_LOSES_VEHICLE_DATA" then
		self:SetupPowerBar();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:SetupAlternatePowerBar();
		self:SetupPowerBar();
	elseif event == "UNIT_AURA" then
		if self.AlternatePowerBar and self.AlternatePowerBar.UpdateAuraState then
			self.AlternatePowerBar:UpdateAuraState();
		end
	elseif event == "PLAYER_ENTER_COMBAT" or event == "UNIT_COMBAT" or event == "PLAYER_REGEN_DISABLED" then
		self:UpdateShownState();
	elseif event == "PLAYER_LEAVE_COMBAT" or event == "PLAYER_REGEN_ENABLED" then
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
		if self.PowerBar.FeedbackFrame.maxValue ~= 0 and (math.abs(currPowerValue - oldValue) / self.PowerBar.FeedbackFrame.maxValue) > 0.1 then
			self.PowerBar.FeedbackFrame:StartFeedbackAnim(oldValue, currPowerValue);
		end
		if self.PowerBar.FullPowerFrame.active then
			self.PowerBar.FullPowerFrame:StartAnimIfFull(currPowerValue);
		end
		self.currPowerValue = currPowerValue;
	end
end

-- NOTE: Textures, colors, etc. here are similar to old PRD and the PlayerFrame. They aren't shared, so they can be more easily changed later.
function PersonalResourceDisplayMixin:SetupHealthBar()
	-- Set shortcuts to access PRD healthbar and tempMaxHealthLossBar
	self.healthbar = self.HealthBarsContainer.healthBar;
    self.tempMaxHealthLossBar = self.HealthBarsContainer.TempMaxHealthLoss;

	-- Setup container border, healthbar statusbar color, and init the temp max health loss
    self.HealthBarsContainer.border:SetVertexColor(0, 0, 0);
    self.HealthBarsContainer.border:SetAlpha(0.5);
    self.healthbar:SetStatusBarColor(0.0, 0.8, 0.0);
    self.tempMaxHealthLossBar:InitalizeMaxHealthLossBar(self.HealthBarsContainer, self.healthbar);

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

	if self.hideHealthAndPower then
		self.HealthBarsContainer:Hide();
	else
		self.HealthBarsContainer:Show();
	end
end

function PersonalResourceDisplayMixin:SetupMaxHealth()
	if not self.HealthBarsContainer:IsShown() then
		return;
	end

    local maxHealth = UnitHealthMax("player");
    self.healthbar:SetMinMaxValues(0, maxHealth);
    self:UpdateHealth();
end

function PersonalResourceDisplayMixin:UpdateHealth()
	if not self.HealthBarsContainer:IsShown() then
		return;
	end

    local currHealth = UnitHealth("player");
    self.healthbar:SetValue(currHealth);
    if self.tempMaxHealthLossBar and self.tempMaxHealthLossBar.initialized then
		self.tempMaxHealthLossBar:OnMaxHealthModifiersChanged(GetUnitTotalModifiedMaxHealthPercent("player"));
	end
end

--WARNING: This function is very similar to the function CompactUnitFrame_UpdateHealPrediction in CompactUnitFrame.lua.
--If you are making changes here, it is possible you may want to make changes there as well.
function PersonalResourceDisplayMixin:UpdateHealthPrediction()
	if not self.HealthBarsContainer:IsShown() then
		return;
	end

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

	--See how far we're going over the health bar and make sure we don't go too far out of the frame.
	if health - myCurrentHealAbsorb + allIncomingHeal > maxHealth * MAX_INCOMING_HEAL_OVERFLOW then
		allIncomingHeal = maxHealth * MAX_INCOMING_HEAL_OVERFLOW - health + myCurrentHealAbsorb;
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
	-- Border
	self.PowerBar.Border:SetVertexColor(0, 0, 0);
	self.PowerBar.Border:SetAlpha(0.5);

	-- Prediction Bar
	local statusBarTexture = self.PowerBar:GetStatusBarTexture();
	self.PowerBar.ManaCostPredictionBar:ClearAllPoints();
	self.PowerBar.ManaCostPredictionBar:SetPoint("TOPLEFT", statusBarTexture, "TOPRIGHT", 0, 0);
	self.PowerBar.ManaCostPredictionBar:SetPoint("BOTTOMLEFT", statusBarTexture, "BOTTOMRIGHT", 0, 0);

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

	if self.hideHealthAndPower then
		self.PowerBar:Hide();
	else
		self.PowerBar:Show();
		self:UpdateMaxPower();
		self:UpdatePower();
	end
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

		local barSize = (self.predictedPowerCost / totalMax) * totalWidth;
		bar:SetWidth(barSize);
		bar:Show();
	end
end

function PersonalResourceDisplayMixin:SetupAlternatePowerBar()
	local classAltPowerBarInfo = ClassAltPowerBarInfoForClassID(self.classID);

	if classAltPowerBarInfo then
		self.AlternatePowerBar.Border:SetVertexColor(0, 0, 0);
		self.AlternatePowerBar.Border:SetAlpha(0.5);

		Mixin(self.AlternatePowerBar, classAltPowerBarInfo.mixin);
		self.AlternatePowerBar:Initialize();

		self.AlternatePowerBar:SetScript("OnUpdate", function()
			self.AlternatePowerBar:UpdatePower();
		end);

		if self.hideHealthAndPower or not self.AlternatePowerBar.alternatePowerRequirementsMet then
			self.AlternatePowerBar:Hide();
		else
			self.AlternatePowerBar:Show();
		end

		self:UpdateAdditionalBarAnchors();
	end
end

function PersonalResourceDisplayMixin:SetupClassBar()
	local classFrameInfo = ClassFrameInfoForClassID(self.classID);

	if classFrameInfo then
		local classFrame = FrameUtil.CreateFrame("prdClassFrame", self.ClassFrameContainer, classFrameInfo.template);

		if classFrameInfo.updatePowerFunc then 
			classFrame.UpdatePower = function() classFrameInfo.updatePowerFunc(classFrame) end;
		end

		self.ClassFrameContainer.yOffset = classFrameInfo.yOffset or 0;

		classFrame:SetParent(self.ClassFrameContainer);
		classFrame:SetPoint("CENTER", self.ClassFrameContainer, "CENTER");
		classFrame:SetScript("OnShow", function() 
			classFrame:SetPoint("CENTER", self.ClassFrameContainer, "CENTER");
		end);

		self.ClassFrameContainer:Show();
		self:UpdateAdditionalBarAnchors();
	else
		self.ClassFrameContainer:Hide();
	end
end

-- If either additional bar is shown, ensure the anchors are correctly set for either/both
function PersonalResourceDisplayMixin:UpdateAdditionalBarAnchors()
	local alternatePowerBarShown = self.AlternatePowerBar:IsShown();
	local classFrameContainerShown = prdClassFrame and prdClassFrame:IsShown();
	
	if alternatePowerBarShown and classFrameContainerShown then
		self.AlternatePowerBar:SetPoint("TOP", self.PowerBar, "BOTTOM");
		self.ClassFrameContainer:SetPoint("TOP", self.AlternatePowerBar, "BOTTOM", 0, self.ClassFrameContainer.yOffset);
	elseif alternatePowerBarShown and not classFrameContainerShown then
		self.AlternatePowerBar:SetPoint("TOP", self.PowerBar, "BOTTOM");
	elseif classFrameContainerShown and not alternatePowerBarShown then
		self.ClassFrameContainer:SetPoint("TOP", self.PowerBar, "BOTTOM", 0, self.ClassFrameContainer.yOffset);
	end
end
