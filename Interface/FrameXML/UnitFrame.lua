local ManaBarFrequentUpdateUnitTypes = {
	"player",
	"pet",
	"vehicle",
	"target",
	"focus",
	"targettarget",
	"focustarget"
};

local replacePortraitCvarNames = {
	"ReplaceMyPlayerPortrait",
	"ReplaceOtherPlayerPortraits",
};

--[[
	This system uses "update" functions as OnUpdate, and OnEvent handlers.
	This "Initialize" function registers the events to handle.
	The "update" function is set as the OnEvent handler (although they do not parse the event),
	as well as run from the parent's update handler.

	TT: I had to make the spellbar system differ from the norm.
	I needed a seperate OnUpdate and OnEvent handlers. And needed to parse the event.
]]--

function UnitFrame_Initialize (self, unit, name, frameType, portrait, healthbar, healthtext, manabar, manatext, threatIndicator, threatFeedbackUnit, threatNumericIndicator,
	myHealPredictionBar, otherHealPredictionBar, totalAbsorbBar, overAbsorbGlow, overHealAbsorbGlow, healAbsorbBar, myManaCostPredictionBar)
	self.unit = unit;
	self.name = name;
	self.frameType = frameType;
	self.portrait = portrait;
	self.healthbar = healthbar;
	self.manabar = manabar;
	self.threatIndicator = threatIndicator;
	self.threatNumericIndicator = threatNumericIndicator;
	self.myHealPredictionBar = myHealPredictionBar;
	self.otherHealPredictionBar = otherHealPredictionBar
	self.totalAbsorbBar = totalAbsorbBar;
	self.overAbsorbGlow = overAbsorbGlow;
	self.overHealAbsorbGlow = overHealAbsorbGlow;
	self.healAbsorbBar = healAbsorbBar;
	self.myManaCostPredictionBar = myManaCostPredictionBar;

	if (self.overAbsorbGlow) then
		self.overAbsorbGlow:ClearAllPoints();
		self.overAbsorbGlow:SetPoint("TOPLEFT", self.healthbar, "TOPRIGHT", -7, 0);
		self.overAbsorbGlow:SetPoint("BOTTOMLEFT", self.healthbar, "BOTTOMRIGHT", -7, 0);
	end
	if (self.overHealAbsorbGlow) then
		self.overHealAbsorbGlow:ClearAllPoints();
		self.overHealAbsorbGlow:SetPoint("BOTTOMRIGHT", self.healthbar, "BOTTOMLEFT", 7, 0);
		self.overHealAbsorbGlow:SetPoint("TOPRIGHT", self.healthbar, "TOPLEFT", 7, 0);
	end

	if (self.healthbar) then
		self.healthbar.capNumericDisplay = true;
		self.healthbar.unitFrame = self;
	end
	if (self.manabar) then
		self.manabar.capNumericDisplay = true;
		self.manabar.unitFrame = self;
	end

	UnitFrameHealthBar_Initialize(unit, healthbar, healthtext, true);

	local manaBarFrequentUpdates = false;
	for _, unitType in ipairs(ManaBarFrequentUpdateUnitTypes) do
		if (unit == unitType) then
			manaBarFrequentUpdates = true;
			break;
		end
	end

	UnitFrameManaBar_Initialize(unit, manabar, manatext, manaBarFrequentUpdates);
	UnitFrameThreatIndicator_Initialize(unit, self, threatFeedbackUnit);
	UnitFrame_Update(self);

	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	self:RegisterEvent("PORTRAITS_UPDATED");
	if ( self.healAbsorbBar ) then
		self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit);
	end
	if ( self.myHealPredictionBar ) then
		self:RegisterUnitEvent("UNIT_MAXHEALTH", unit);
		self:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit);
	end
	if ( self.totalAbsorbBar ) then
		self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit);
	end
	if ( self.myManaCostPredictionBar ) then
		self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit);
		self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit);
		self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit);
		self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit);
	end

	UnitFrame_UpdateReplacePortraitSettingRegistration(self);
end

function UnitFrame_SetUnit (self, unit, healthbar, manabar)
	-- update unit events if unit changes
	if ( self.unit ~= unit ) then
		if ( self.myHealPredictionBar ) then
			self:RegisterUnitEvent("UNIT_MAXHEALTH", unit);
			self:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit);
		end
		if ( self.totalAbsorbBar ) then
			self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit);
		end
		if ( not healthbar.frequentUpdates ) then
			healthbar:RegisterUnitEvent("UNIT_HEALTH", unit);
		end
		if ( manabar and not manabar.frequentUpdates ) then
			UnitFrameManaBar_RegisterDefaultEvents(manabar);
		end
		healthbar:RegisterUnitEvent("UNIT_MAXHEALTH", unit);
		
		if ( self.PlayerFrameHealthBarAnimatedLoss ) then
			self.PlayerFrameHealthBarAnimatedLoss:SetUnitHealthBar(unit, healthbar);
		end
	end

	self.unit = unit;

	UnitFrame_UpdateReplacePortraitSettingRegistration(self);

	UnitFrameHealthBar_SetUnit(healthbar, unit)
	if ( manabar ) then	--Party Pet frames don't have a mana bar.
		manabar.unit = unit;
	end
	self:SetAttribute("unit", unit);
	securecall("UnitFrame_Update", self);
end

function UnitFrame_Update (self, isParty)
	if ( self.name ) then
		local name;
		if ( self.overrideName ) then
			name = self.overrideName;
		else
			name = self.unit;
		end

		local nameText = GetUnitName(name, isParty);
		if ( nameText ) then
			if ( UnitInPartyIsAI(self.unit) and C_LFGInfo.IsInLFGFollowerDungeon() ) then
				nameText = LFG_FOLLOWER_NAME_PREFIX:format(nameText);
			end

			self.name:SetText(nameText);
		end
	end

	UnitFramePortrait_Update(self);
	UnitFrameHealthBar_Update(self.healthbar, self.unit);
	UnitFrameManaBar_Update(self.manabar, self.unit);
	UnitFrame_UpdateThreatIndicator(self.threatIndicator, self.threatNumericIndicator);
	UnitFrameHealPredictionBars_UpdateMax(self);
	UnitFrameHealPredictionBars_Update(self);
	UnitFrameManaCostPredictionBars_Update(self);
end

function UnitFramePortrait_Update (self)
	if ( self.portrait ) then
		if ( UnitFrame_ShouldReplacePortrait(self) ) then
			local _, class = UnitClass(self.unit);
			if ( class ) then
				local classIconAtlas = GetClassAtlas(class);
				if ( classIconAtlas ) then
					self.portrait:SetAtlas(classIconAtlas);
					return;
				end
			end
		end

		SetPortraitTexture(self.portrait, self.unit, self.disablePortraitMask);
	end
end

function UnitFrame_OnEvent(self, event, ...)
	local eventUnit = ...

	local unit = self.unit;
	if ( eventUnit == unit ) then
		if ( event == "UNIT_NAME_UPDATE" ) then
			self.name:SetText(GetUnitName(unit));
		elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
			UnitFramePortrait_Update(self);
		elseif ( event == "UNIT_DISPLAYPOWER" ) then
			if ( self.manabar ) then
				UnitFrameManaBar_UpdateType(self.manabar);
			end
		elseif ( event == "UNIT_MAXHEALTH" ) then
			UnitFrameHealPredictionBars_UpdateMax(self);
		elseif ( event == "UNIT_HEAL_PREDICTION" ) then
			UnitFrameHealPredictionBars_Update(self);
		elseif ( event == "UNIT_ABSORB_AMOUNT_CHANGED" ) then
			UnitFrameHealPredictionBars_Update(self);
		elseif ( event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" ) then
			UnitFrameHealPredictionBars_Update(self);
		elseif ( event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_SUCCEEDED" ) then
			local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit);
			UnitFrameManaCostPredictionBars_Update(self, event == "UNIT_SPELLCAST_START", startTime, endTime, spellID);
		end
	elseif ( event == "PORTRAITS_UPDATED" ) then
		UnitFramePortrait_Update(self);
	end
end

function UnitFrameHealPredictionBars_UpdateMax(self)
	UnitFrameHealPredictionBars_Update(self);
end

function UnitFrameHealPredictionBars_UpdateSize(self)
	UnitFrameHealPredictionBars_Update(self);
end

--WARNING: This function is very similar to the function CompactUnitFrame_UpdateHealPrediction in CompactUnitFrame.lua.
--If you are making changes here, it is possible you may want to make changes there as well.
local MAX_INCOMING_HEAL_OVERFLOW = 1.0;
function UnitFrameHealPredictionBars_Update(frame)
	if ( not frame.myHealPredictionBar and not frame.otherHealPredictionBar and not frame.healAbsorbBar and not frame.totalAbsorbBar ) then
		return;
	end

	local _, maxHealth = frame.healthbar:GetMinMaxValues();
	local health = frame.healthbar:GetValue();
	if ( maxHealth <= 0 ) then
		return;
	end

	local myIncomingHeal = UnitGetIncomingHeals(frame.unit, "player") or 0;
	local allIncomingHeal = UnitGetIncomingHeals(frame.unit) or 0;
	local totalAbsorb = UnitGetTotalAbsorbs(frame.unit) or 0;

	local myCurrentHealAbsorb = 0;
	if ( frame.healAbsorbBar ) then
		myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(frame.unit) or 0;

		--We don't fill outside the health bar with healAbsorbs.  Instead, an overHealAbsorbGlow is shown.
		if ( health < myCurrentHealAbsorb ) then
			frame.overHealAbsorbGlow:Show();
			myCurrentHealAbsorb = health;
		else
			frame.overHealAbsorbGlow:Hide();
		end
	end

	--See how far we're going over the health bar and make sure we don't go too far out of the frame.
	if ( health - myCurrentHealAbsorb + allIncomingHeal > maxHealth * MAX_INCOMING_HEAL_OVERFLOW ) then
		allIncomingHeal = maxHealth * MAX_INCOMING_HEAL_OVERFLOW - health + myCurrentHealAbsorb;
	end

	local otherIncomingHeal = 0;

	--Split up incoming heals.
	if ( allIncomingHeal >= myIncomingHeal ) then
		otherIncomingHeal = allIncomingHeal - myIncomingHeal;
	else
		myIncomingHeal = allIncomingHeal;
	end

	--We don't fill outside the the health bar with absorbs.  Instead, an overAbsorbGlow is shown.
	local overAbsorb = false;
	if ( health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth ) then
		if ( totalAbsorb > 0 ) then
			overAbsorb = true;
		end

		if ( allIncomingHeal > myCurrentHealAbsorb ) then
			totalAbsorb = max(0,maxHealth - (health - myCurrentHealAbsorb + allIncomingHeal));
		else
			totalAbsorb = max(0,maxHealth - health);
		end
	end

	if ( overAbsorb ) then
		frame.overAbsorbGlow:Show();
	else
		frame.overAbsorbGlow:Hide();
	end

	local healthTexture = frame.healthbar:GetStatusBarTexture();
	local myCurrentHealAbsorbPercent = 0;
	local healAbsorbTexture = nil;

	if ( frame.healAbsorbBar ) then
		myCurrentHealAbsorbPercent = myCurrentHealAbsorb / maxHealth;

		--If allIncomingHeal is greater than myCurrentHealAbsorb, then the current
		--heal absorb will be completely overlayed by the incoming heals so we don't show it.
		if ( myCurrentHealAbsorb > allIncomingHeal ) then
			local shownHealAbsorb = myCurrentHealAbsorb - allIncomingHeal;
			local shownHealAbsorbPercent = shownHealAbsorb / maxHealth;

			healAbsorbTexture = frame.healAbsorbBar:UpdateFillPosition(healthTexture, shownHealAbsorb, -shownHealAbsorbPercent);

			--If there are incoming heals the left shadow would be overlayed by the incoming heals
			--so it isn't shown.
			frame.healAbsorbBar.LeftShadow:SetShown(allIncomingHeal <= 0);

			-- The right shadow is only shown if there are absorbs on the health bar.
			frame.healAbsorbBar.RightShadow:SetShown(totalAbsorb > 0)
		else
			frame.healAbsorbBar:Hide();
		end
	end

	--Show myIncomingHeal on the health bar.
	local incomingHealTexture;
	if ( frame.myHealPredictionBar ) then
		incomingHealTexture = frame.myHealPredictionBar:UpdateFillPosition(healthTexture, myIncomingHeal, -myCurrentHealAbsorbPercent);
	end

	local otherHealLeftTexture = (myIncomingHeal > 0) and incomingHealTexture or healthTexture;
	local xOffset = (myIncomingHeal > 0) and 0 or -myCurrentHealAbsorbPercent;

	--Append otherIncomingHeal on the health bar
	if ( frame.otherHealPredictionBar ) then
		incomingHealTexture = frame.otherHealPredictionBar:UpdateFillPosition(otherHealLeftTexture, otherIncomingHeal, xOffset);
	end

	--Append absorbs to the correct section of the health bar.
	local appendTexture = nil;
	if ( healAbsorbTexture ) then
		--If there is a healAbsorb part shown, append the absorb to the end of that.
		appendTexture = healAbsorbTexture;
	else
		--Otherwise, append the absorb to the end of the the incomingHeals or health part;
		appendTexture = incomingHealTexture or healthTexture;
	end

	if ( frame.totalAbsorbBar ) then
		frame.totalAbsorbBar:UpdateFillPosition(appendTexture, totalAbsorb);
	end
end

function UnitFrameManaCostPredictionBars_Update(frame, isStarting, startTime, endTime, spellID)
	if (not frame.manabar or not frame.myManaCostPredictionBar) then
		return;
	end
	local cost = 0;
	if (not isStarting or startTime == endTime) then
        local currentSpellID = select(9, UnitCastingInfo(frame.unit));
        if(currentSpellID and frame.predictedPowerCost) then --if we're currently casting something with a power cost, then whatever cast
		    cost = frame.predictedPowerCost;                 --just finished was allowed while casting, don't reset the original cast
        else
            frame.predictedPowerCost = nil;
        end
	else
		local costTable = GetSpellPowerCost(spellID);
		for _, costInfo in pairs(costTable) do
			if (costInfo.type == frame.manabar.powerType) then
				cost = costInfo.cost;
				break;
			end
		end
		frame.predictedPowerCost = cost;
	end
	local manaBarTexture = frame.manabar:GetStatusBarTexture();
	UnitFrameManaBar_Update(frame.manabar, frame.unit);
	frame.myManaCostPredictionBar:UpdateFillPosition(manaBarTexture, cost);
end

function UnitFrame_OnEnter (self)
	UnitFrame_UpdateTooltip(self);
end

function UnitFrame_OnLeave (self)
	self.UpdateTooltip = nil;
	GameTooltip:FadeOut();
end

function UnitFrame_UpdateTooltip (self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	if ( GameTooltip:SetUnit(self.unit, self.hideStatusOnTooltip) ) then
		self.UpdateTooltip = UnitFrame_UpdateTooltip;
	else
		self.UpdateTooltip = nil;
	end
end

--[[
	Previous way to set the mana bar type was by coloring the mana bar (or using an atlas texture for
	certain cases).  Current way uses atlas textures exclusively, with a mask (done in each frame)
	making the older existing atlas textures fit to the frame shape.  Once all unit frames have been
	converted to the new flow, this method and any associated data pieces can be removed safely.
]]--
function UnitFrameManaBar_UpdateTypeOld(manaBar)
	if ( not manaBar ) then
		return;
	end

	local powerType, powerToken, altR, altG, altB = UnitPowerType(manaBar.unit);
	local prefix = _G[powerToken];
	local info = PowerBarColor[powerToken];

	manaBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");

	if ( info ) then
		if ( not manaBar.lockColor ) then
			local playerDeadOrGhost = (manaBar.unit == "player" and (UnitIsDead("player") or UnitIsGhost("player")));
			if ( info.atlas ) then
				manaBar:SetStatusBarTexture(info.atlas);
				manaBar:SetStatusBarColor(1, 1, 1);
				manaBar:GetStatusBarTexture():SetDesaturated(playerDeadOrGhost);
				manaBar:GetStatusBarTexture():SetAlpha(playerDeadOrGhost and 0.5 or 1);
			else
				if ( playerDeadOrGhost ) then
					manaBar:SetStatusBarColor(0.6, 0.6, 0.6, 0.5);
				else
					manaBar:SetStatusBarColor(info.r, info.g, info.b);
				end
			end

			if ( manaBar.FeedbackFrame ) then
				manaBar.FeedbackFrame:Initialize(info, manaBar.unit, powerType);
			end

			if ( manaBar.FullPowerFrame ) then
				manaBar.FullPowerFrame:Initialize(info.fullPowerAnim);
			end

			if ( manaBar.Spark ) then
				manaBar.Spark:SetVisuals(info);
			end
		end
	else
		if ( not altR ) then
			-- couldn't find a power token entry...default to indexing by power type or just mana if we don't have that either
			info = PowerBarColor[powerType] or PowerBarColor["MANA"];
		else
			if ( not manaBar.lockColor ) then
				manaBar:SetStatusBarColor(altR, altG, altB);
			end
		end
	end

	if ( manaBar.powerType ~= powerType ) then
		manaBar.powerType = powerType;
		manaBar.powerToken = powerToken;
		if ( manaBar.FullPowerFrame ) then
			manaBar.FullPowerFrame:RemoveAnims();
		end
		if manaBar.FeedbackFrame then
			manaBar.FeedbackFrame:StopFeedbackAnim();
		end
		manaBar.currValue = UnitPower("player", powerType);
		if manaBar.unitFrame.myManaCostPredictionBar then
			manaBar.unitFrame.myManaCostPredictionBar:Hide();
		end
		manaBar.unitFrame.predictedPowerCost = 0;
	end

	-- Update the manabar text
	TextStatusBar_UpdateTextString(manaBar);

	-- Setup newbie tooltip
	if ( manaBar.unit ~= "pet") then
	    if ( manaBar.unitFrame:GetName() == "PlayerFrame" ) then
		    manaBar.tooltipTitle = prefix;
		    manaBar.tooltipText = _G["NEWBIE_TOOLTIP_MANABAR_"..powerType];
	    else
		    manaBar.tooltipTitle = nil;
		    manaBar.tooltipText = nil;
	    end
	end
end

function UnitFrameManaBar_UpdateType(manaBar)
	if (not manaBar) then
		return;
	end

	if(not manaBar.unitFrame.frameType) then
		UnitFrameManaBar_UpdateTypeOld(manaBar);
		return;
	end

	local powerType, powerToken, altR, altG, altB = UnitPowerType(manaBar.unit);
	local info = PowerBarColor[powerToken];

	local portraitType = manaBar.unitFrame.portrait and "PortraitOn" or "PortraitOff";

	-- Some mana bar art is different for a frame depending on if they are in a vehicle or not.
	-- Special case for the party frame.
	local vehicleText = "";
	if(manaBar.unitFrame.frameType == "Party" and manaBar.unitFrame.state == "vehicle") then
		vehicleText = "-Vehicle";
	end

	if (info) then
		local manaBarAtlas;
		if (manaBar.unitFrame.frameType and info.atlasElementName) then
			
			-- Some player spec/classes use a third "alternate" bar, requiring their primary bar to use slightly different bar art
			-- Very few bars have this ClassResource variant so far, hence the hasClassResourceVariant check which for now is much cheaper than constant GetAtlasInfo nil checks
			local classResourceText = "";
			if(manaBar.unitFrame.frameType == "Player" and manaBar.unitFrame.state == "player" and manaBar.unitFrame.activeAlternatePowerBar and info.hasClassResourceVariant) then
				classResourceText = "-ClassResource";
			end

			local manaBarTexture = "UI-HUD-UnitFrame-"..manaBar.unitFrame.frameType.."-"..portraitType..vehicleText..classResourceText.."-Bar-"..info.atlasElementName;
			manaBar:SetStatusBarTexture(manaBarTexture);
			manaBarAtlas = manaBarTexture;
		elseif (info.atlas) then
			manaBar:SetStatusBarTexture(info.atlas);
			manaBarAtlas = info.atlas;
		end

		manaBar:SetStatusBarColor(1, 1, 1);

		local playerDeadOrGhost = (manaBar.unit == "player" and (UnitIsDead("player") or UnitIsGhost("player")));
		local statusBarTexture = manaBar:GetStatusBarTexture();
		statusBarTexture:SetDesaturated(playerDeadOrGhost);
		statusBarTexture:SetAlpha(playerDeadOrGhost and 0.5 or 1);

		if (manaBar.FeedbackFrame) then
			-- Ensure feedback frame gets the atlas we actually used rather than having it duplicate the same handling
			manaBar.FeedbackFrame:Initialize({atlas = manaBarAtlas}, manaBar.unit, powerType);
		end

		if (manaBar.FullPowerFrame) then
			manaBar.FullPowerFrame:Initialize(info.fullPowerAnim);
		end

		if (manaBar.Spark) then
			manaBar.Spark:SetVisuals(info.spark);
		end
	else
		-- If we cannot find the info for what the mana bar should be, default either to Mana or Mana-Status (colorable).
		local manaBarTexture = "UI-HUD-UnitFrame-"..manaBar.unitFrame.frameType.."-"..portraitType..vehicleText.."-Bar-Mana";
		manaBar:SetStatusBarColor(1, 1, 1);

		if (altR) then
			-- This steps around manaBar.lockColor as it is initially setting things.
			manaBarTexture = "UI-HUD-UnitFrame-"..manaBar.unitFrame.frameType.."-"..portraitType..vehicleText.."-Bar-Mana-Status";
			manaBar:SetStatusBarColor(altR, altG, altB);
		end

		manaBar:SetStatusBarTexture(manaBarTexture);
	end

	if (manaBar.powerType ~= powerType) then
		manaBar.powerType = powerType;
		manaBar.powerToken = powerToken;

		if (manaBar.FeedbackFrame) then
			manaBar.FeedbackFrame:StopFeedbackAnim();
		end

		if (manaBar.FullPowerFrame) then
			manaBar.FullPowerFrame:RemoveAnims();
		end

		manaBar.currValue = UnitPower("player", powerType);
		if (manaBar.unitFrame.myManaCostPredictionBar) then
			manaBar.unitFrame.myManaCostPredictionBar:Hide();

			local predictionColor;
			if (info and info.predictionColor) then
				predictionColor = info.predictionColor;
			else
				-- No prediction color set, default to mana prediction color
				predictionColor = POWERBAR_PREDICTION_COLOR_MANA;
			end
	
			manaBar.unitFrame.myManaCostPredictionBar:SetFillColor(predictionColor);
		end

		manaBar.unitFrame.predictedPowerCost = 0;
	end

	-- Update the manabar text
	TextStatusBar_UpdateTextString(manaBar);
end

function UnitFrameHealthBar_Initialize (unit, statusbar, statustext, frequentUpdates)
	if ( not statusbar ) then
		return;
	end

	statusbar.unit = unit;
	SetTextStatusBarText(statusbar, statustext);

	statusbar.frequentUpdates = frequentUpdates;
	if ( frequentUpdates ) then
		statusbar:RegisterEvent("VARIABLES_LOADED");
	end

	UnitFrameHealthBar_RefreshUpdateEvent(statusbar);

	statusbar:RegisterUnitEvent("UNIT_MAXHEALTH", unit);
	statusbar:SetScript("OnEvent", UnitFrameHealthBar_OnEvent);

	-- Setup newbie tooltip
	if ( statusbar and (statusbar.unitFrame == PlayerFrame) ) then
		statusbar.tooltipTitle = HEALTH;
		statusbar.tooltipText = NEWBIE_TOOLTIP_HEALTHBAR;
	else
		statusbar.tooltipTitle = nil;
		statusbar.tooltipText = nil;
	end
end

function UnitFrameHealthBar_RefreshUpdateEvent(self)
	if ( GetCVarBool("predictedHealth") and self.frequentUpdates ) then
		self:SetScript("OnUpdate", UnitFrameHealthBar_OnUpdate);
		self:UnregisterEvent("UNIT_HEALTH");
	else
		self:SetScript("OnUpdate", nil);
		self:RegisterUnitEvent("UNIT_HEALTH", self.unit);
	end
end

function UnitFrameHealthBar_SetUnit(self, unit)
	self.unit = unit;
	UnitFrameHealthBar_RefreshUpdateEvent(self);
end

function UnitFrameHealthBar_OnEvent(self, event, ...)
	if ( event == "CVAR_UPDATE" ) then
		TextStatusBar_OnEvent(self, event, ...);
	elseif ( event == "VARIABLES_LOADED" ) then
		self:UnregisterEvent("VARIABLES_LOADED");
		UnitFrameHealthBar_RefreshUpdateEvent(self);
	elseif self:IsShown() then
		if ( not self.ignoreNoUnit or UnitGUID(self.unit) ) then
			UnitFrameHealthBar_Update(self, ...);
		end
	end
end

AnimatedHealthLossMixin = {};

function AnimatedHealthLossMixin:OnLoad()
	self:SetStatusBarColor(1, 0, 0, 1);
	self:SetDuration(.25);
	self:SetStartDelay(.1);
	self:SetPauseDelay(.05);
	self:SetPostponeDelay(.05);
end

function AnimatedHealthLossMixin:SetDuration(duration)
	self.animationDuration = duration or 0;
end

function AnimatedHealthLossMixin:SetStartDelay(delay)
	self.animationStartDelay = delay or 0;
end

function AnimatedHealthLossMixin:SetPauseDelay(delay)
	self.animationPauseDelay = delay or 0;
end

function AnimatedHealthLossMixin:SetPostponeDelay(delay)
	self.animationPostponeDelay = delay or 0;
end

function AnimatedHealthLossMixin:SetUnitHealthBar(unit, healthBar)
	if self.unit ~= unit then
		healthBar.AnimatedLossBar = self;

		self.unit = unit;
		self:SetAllPoints(healthBar);
		self:UpdateHealthMinMax();
	end
end

function AnimatedHealthLossMixin:UpdateHealthMinMax()
	local maxValue = UnitHealthMax(self.unit);
	self:SetMinMaxValues(0, maxValue);
end

function AnimatedHealthLossMixin:GetHealthLossAnimationData(currentHealth, previousHealth)
	if self.animationStartTime then
		local totalElapsedTime = GetTime() - self.animationStartTime;
		if totalElapsedTime > 0 then
			local animCompletePercent = totalElapsedTime / self.animationDuration;
			if animCompletePercent < 1 and previousHealth > currentHealth then
				local healthDelta = previousHealth - currentHealth;
				local animatedLossAmount = previousHealth - (animCompletePercent * healthDelta);
				return animatedLossAmount, animCompletePercent;
			end
		else
			return previousHealth, 0;
		end
	end
	return 0, 1; -- Animated loss amount is 0, and the animation is fully complete.
end

function AnimatedHealthLossMixin:CancelAnimation()
	self:Hide();
	self.animationStartTime = nil;
	self.animationCompletePercent = nil;
end

function AnimatedHealthLossMixin:BeginAnimation(value)
	self.animationStartValue = value;
	self.animationStartTime = GetTime() + self.animationStartDelay;
	self.animationCompletePercent = 0;
	self:Show();
	self:SetValue(self.animationStartValue);
end

function AnimatedHealthLossMixin:PostponeStartTime()
	self.animationStartTime = self.animationStartTime + self.animationPostponeDelay;
end

function AnimatedHealthLossMixin:UpdateHealth(currentHealth, previousHealth)
	local delta = currentHealth - previousHealth;
	local hasLoss = delta < 0;
	local hasBegun = self.animationStartTime ~= nil;
	local isAnimating = hasBegun and self.animationCompletePercent > 0;

	if hasLoss and not hasBegun then
		self:BeginAnimation(previousHealth);
	elseif hasLoss and hasBegun and not isAnimating then
		self:PostponeStartTime();
	elseif hasLoss and isAnimating then
		-- Reset the starting value of the health to what the animated loss bar was when the new incoming damage happened
		-- and pause briefly when new damage occurs.
		self.animationStartValue = self:GetHealthLossAnimationData(previousHealth, self.animationStartValue);
		self.animationStartTime = GetTime() + self.animationPauseDelay;
	elseif not hasLoss and hasBegun and currentHealth >= self.animationStartValue then
		self:CancelAnimation();
	end
end

function AnimatedHealthLossMixin:UpdateLossAnimation(currentHealth)
	local totalAbsorb = UnitGetTotalAbsorbs(self.unit) or 0;
	if totalAbsorb > 0 then
		self:CancelAnimation();
	end

	if self.animationStartTime then
		local animationValue, animationCompletePercent = self:GetHealthLossAnimationData(currentHealth, self.animationStartValue);
		self.animationCompletePercent = animationCompletePercent;
		if animationCompletePercent >= 1 then
			self:CancelAnimation();
		else
			self:SetValue(animationValue);
		end
	end
end

function UnitFrameHealthBar_OnUpdate(self)
	if ( not self.disconnected and not self.lockValues) then
		local currValue = UnitHealth(self.unit);
		local animatedLossBar = self.AnimatedLossBar;

		if ( currValue ~= self.currValue ) then
			if ( not self.ignoreNoUnit or UnitGUID(self.unit) ) then

				if animatedLossBar then
					animatedLossBar:UpdateHealth(currValue, self.currValue);
				end

				self:SetValue(currValue);
				self.currValue = currValue;
				TextStatusBar_UpdateTextString(self);
				UnitFrameHealPredictionBars_Update(self.unitFrame);
			end
		end

		if animatedLossBar then
			animatedLossBar:UpdateLossAnimation(currValue);
		end
	end
end

function UnitFrameHealthBar_Update(statusbar, unit)
	if ( not statusbar or statusbar.lockValues ) then
		return;
	end

	if ( unit == statusbar.unit ) then
		local maxValue = UnitHealthMax(unit);

		-- Safety check to make sure we never get an empty bar.
		statusbar.forceHideText = false;
		if ( maxValue == 0 ) then
			maxValue = 1;
			statusbar.forceHideText = true;
		end

		statusbar:SetMinMaxValues(0, maxValue);

		if statusbar.AnimatedLossBar then
			statusbar.AnimatedLossBar:UpdateHealthMinMax();
		end

		statusbar.disconnected = not UnitIsConnected(unit);
		if ( statusbar.disconnected ) then
			if ( not statusbar.lockColor ) then
				statusbar:SetStatusBarColor(0.5, 0.5, 0.5);
			end
			statusbar:SetValue(maxValue);
			statusbar.currValue = maxValue;
		else
			local currValue = UnitHealth(unit);
			if ( not statusbar.lockColor ) then
				statusbar:SetStatusBarColor(0.0, 1.0, 0.0);
			end
			statusbar:SetValue(currValue);
			statusbar.currValue = currValue;
		end
	end
	TextStatusBar_UpdateTextString(statusbar);
	UnitFrameHealPredictionBars_Update(statusbar.unitFrame);
end

function UnitFrameHealthBar_OnValueChanged(self, value)
	TextStatusBar_OnValueChanged(self, value);
	HealthBar_OnValueChanged(self, value);
end

function UnitFrameManaBar_UnregisterDefaultEvents(self)
	self:UnregisterEvent("UNIT_POWER_UPDATE");
end

function UnitFrameManaBar_RegisterDefaultEvents(self)
	self:RegisterUnitEvent("UNIT_POWER_UPDATE", self.unit);
end

function UnitFrameManaBar_Initialize (unit, statusbar, statustext, frequentUpdates)
	if ( not statusbar ) then
		return;
	end
	statusbar.unit = unit;
	statusbar.texture = statusbar:GetStatusBarTexture();
	SetTextStatusBarText(statusbar, statustext);

	statusbar.frequentUpdates = frequentUpdates;
	if ( frequentUpdates ) then
		statusbar:RegisterEvent("VARIABLES_LOADED");
	end
	if ( frequentUpdates ) then
		statusbar:SetScript("OnUpdate", UnitFrameManaBar_OnUpdate);
	else
		UnitFrameManaBar_RegisterDefaultEvents(statusbar);
	end
	statusbar:RegisterEvent("UNIT_DISPLAYPOWER");
	statusbar:RegisterUnitEvent("UNIT_MAXPOWER", unit);
	statusbar:RegisterUnitEvent("PLAYER_GAINS_VEHICLE_DATA", unit);
	statusbar:RegisterUnitEvent("PLAYER_LOSES_VEHICLE_DATA", unit);
	if ( statusbar.unit == "player" ) then
		statusbar:RegisterEvent("PLAYER_DEAD");
		statusbar:RegisterEvent("PLAYER_ALIVE");
		statusbar:RegisterEvent("PLAYER_UNGHOST");
	end
	statusbar:SetScript("OnEvent", UnitFrameManaBar_OnEvent);
end

function UnitFrameManaBar_OnEvent(self, event, ...)
	if ( event == "CVAR_UPDATE" ) then
		TextStatusBar_OnEvent(self, event, ...);
	elseif ( event == "VARIABLES_LOADED" ) then
		self:UnregisterEvent("VARIABLES_LOADED");
		if ( self.frequentUpdates ) then
			self:SetScript("OnUpdate", UnitFrameManaBar_OnUpdate);
			UnitFrameManaBar_UnregisterDefaultEvents(self);
		else
			UnitFrameManaBar_RegisterDefaultEvents(self);
			self:SetScript("OnUpdate", nil);
		end
	elseif ( event == "PLAYER_ALIVE"  or event == "PLAYER_DEAD" or event == "PLAYER_UNGHOST" ) then
		UnitFrameManaBar_UpdateType(self);
	elseif ( event == "PLAYER_GAINS_VEHICLE_DATA"  or event == "PLAYER_LOSES_VEHICLE_DATA" ) then
		UnitFrameManaBar_UpdateType(self);
	else
		if ( not self.ignoreNoUnit or UnitGUID(self.unit) ) then
			UnitFrameManaBar_Update(self, ...);
		end
	end
end

function UnitFrameManaBar_OnUpdate(self)
	if ( not self.disconnected and not self.lockValues ) then
		local predictedCost = self.unitFrame.predictedPowerCost;
		local currValue = UnitPower(self.unit, self.powerType);
		if (predictedCost) then
			currValue = currValue - predictedCost;
		end
		if ( currValue ~= self.currValue or self.forceUpdate ) then
			self.forceUpdate = nil;
			if ( not self.ignoreNoUnit or UnitGUID(self.unit) ) then
				if ( self.FeedbackFrame and self.FeedbackFrame.maxValue ) then
					-- Only show anim if change is more than 10%
					local oldValue = self.currValue or 0;
					if ( self.FeedbackFrame.maxValue ~= 0 and math.abs(currValue - oldValue) / self.FeedbackFrame.maxValue > 0.1 ) then
						self.FeedbackFrame:StartFeedbackAnim(oldValue, currValue);
					end
				end
				if ( self.FullPowerFrame and self.FullPowerFrame.active ) then
					self.FullPowerFrame:StartAnimIfFull(currValue);
				end
				self:SetValue(currValue);
				self.currValue = currValue;
				TextStatusBar_UpdateTextString(self);
			end
		end
	end
end

function UnitFrameManaBar_Update(statusbar, unit)
	if ( not statusbar or statusbar.lockValues ) then
		return;
	end

	if ( unit == statusbar.unit ) then
		-- be sure to update the power type before grabbing the max power!
		UnitFrameManaBar_UpdateType(statusbar);

		local maxValue = UnitPowerMax(unit, statusbar.powerType);

		statusbar:SetMinMaxValues(0, maxValue);

		statusbar.disconnected = not UnitIsConnected(unit);
		if ( statusbar.disconnected ) then
			statusbar:SetValue(maxValue);
			statusbar.currValue = maxValue;
			if ( not statusbar.lockColor ) then
				statusbar:SetStatusBarColor(0.5, 0.5, 0.5);
			end
		else
			local predictedCost = statusbar.unitFrame.predictedPowerCost;
			local currValue = UnitPower(unit, statusbar.powerType);
			if (predictedCost) then
				currValue = currValue - predictedCost;
			end
			if ( statusbar.FullPowerFrame ) then
				statusbar.FullPowerFrame:SetMaxValue(maxValue);
			end

			statusbar:SetValue(currValue);
			statusbar.forceUpdate = true;
		end
	end
	TextStatusBar_UpdateTextString(statusbar);
end

function UnitFrameThreatIndicator_Initialize(unit, unitFrame, feedbackUnit)
	local indicator = unitFrame.threatIndicator;
	if ( not indicator ) then
		return;
	end

	indicator.unit = unit;
	indicator.feedbackUnit = feedbackUnit or unit;

	unitFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	if ( unitFrame.OnEvent == nil ) then
		unitFrame.OnEvent = unitFrame:GetScript("OnEvent") or false;
	end
	unitFrame:SetScript("OnEvent", UnitFrameThreatIndicator_OnEvent);
end

function UnitFrameThreatIndicator_OnEvent(self, event, ...)
	if ( self.OnEvent ) then
		self.OnEvent(self, event, ...);
	end
	if ( event == "UNIT_THREAT_SITUATION_UPDATE" ) then
		UnitFrame_UpdateThreatIndicator(self.threatIndicator, self.threatNumericIndicator,...);
	end
end

function UnitFrame_UpdateThreatIndicator(indicator, numericIndicator, unit)
	if ( not indicator ) then
		return;
	end

	if ( not unit or unit == indicator.feedbackUnit ) then
		local status;
		if ( indicator.feedbackUnit ~= indicator.unit ) then
			status = UnitThreatSituation(indicator.feedbackUnit, indicator.unit);
		else
			status = UnitThreatSituation(indicator.feedbackUnit);
		end

		if ( IsThreatWarningEnabled() ) then
			if (status and status > 0) then
				indicator:SetVertexColor(GetThreatStatusColor(status));
				indicator:Show();
			else
				indicator:Hide();
			end

			if ( numericIndicator ) then
				if ( ShowNumericThreat() and not (UnitClassification(indicator.unit) == "minus") ) then
					local isTanking, status, percentage, rawPercentage = UnitDetailedThreatSituation(indicator.feedbackUnit, indicator.unit);
					local display = rawPercentage;
					if ( isTanking ) then
						display = UnitThreatPercentageOfLead(indicator.feedbackUnit, indicator.unit);
					end
					if ( display and display ~= 0 ) then
						numericIndicator.text:SetText(format("%1.0f", display).."%");
						numericIndicator.bg:SetVertexColor(GetThreatStatusColor(status));
						numericIndicator:Show();
					else
						numericIndicator:Hide();
					end
				else
					numericIndicator:Hide();
				end
			end
		else
			indicator:Hide();
			if ( numericIndicator ) then
				numericIndicator:Hide();
			end
		end
	end
end

function UnitFrame_ShouldReplacePortrait(self)
	if UnitIsPlayer(self.unit) then
		local cvarName = UnitIsUnit(self.unit, "player") and "ReplaceMyPlayerPortrait" or "ReplaceOtherPlayerPortraits";
		return GetCVarBool(cvarName);
	end

	return false;
end

function UnitFrame_UpdateReplacePortraitSettingRegistration(self)
	if self.unit then
		if self.replacePortraitSettingChangedHandlers then
			return;
		end
		self.replacePortraitSettingChangedHandlers = {};

		for _, cvarName in ipairs(replacePortraitCvarNames) do
			local settingChangedHandler = Settings.SetOnValueChangedCallback(cvarName, UnitFramePortrait_Update, self);
			table.insert(self.replacePortraitSettingChangedHandlers, settingChangedHandler);
		end
	else
		if self.replacePortraitSettingChangedHandlers then
			for _, settingChangedHandler in ipairs(self.replacePortraitSettingChangedHandlers) do
				settingChangedHandler:Unregister();
			end
			self.replacePortraitSettingChangedHandlers = nil;
		end
	end
end

function GetUnitName(unit, showServerName)
	local name, server = UnitName(unit);
	local relationship = UnitRealmRelationship(unit);
	if ( server and server ~= "" ) then
		if ( showServerName ) then
			return name.."-"..server;
		else
			if (relationship == LE_REALM_RELATION_VIRTUAL) then
				return name;
			else
				return name..FOREIGN_SERVER_LABEL;
			end
		end
	else
		return name;
	end
end

function ShowNumericThreat()
	if ( GetCVar("threatShowNumeric") == "1" ) then
		return true;
	else
		return false;
	end
end
