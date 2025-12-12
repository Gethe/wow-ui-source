CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.SIMPLIFIED_TYPES_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.CAST_BAR_DISPLAY_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.SIZE_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.SHOW_FRIENDLY_NPCS_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.THREAT_DISPLAY_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.DEBUFF_PADDING_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.SHOW_ONLY_NAME_FOR_FRIENDLY_PLAYER_UNITS_CVAR);

local CAST_BAR_SPARK_EXTRA_HEIGHT = 8;

-- Displays the info about the unit to which the nameplate is attached.
-- This mixin is a child of a frame that has been created in code and is using NamePlateBaseMixin.
NamePlateUnitFrameMixin = {};

function NamePlateUnitFrameMixin:OnLoad()
	CompactUnitFrame_OnLoad(self);

	self:RegisterForClicks("LeftButtonDown", "RightButtonUp");

	-- Leverage the logic in CompactUnitFrame adjusting the shown state of the selection highlight
	-- to determine if the nameplate's unit is the player's current target.
	do
		self.selectionHighlight:SetScript("OnShow", function()
			self:UpdateIsTarget();
		end);

		self.selectionHighlight:SetScript("OnHide", function()
			self:UpdateIsTarget();
		end);
	end

	-- Hide all aggro highlight pieces once it's finished facing out.
	self.AggroHighlightFadeOutAnim:SetScript("OnFinished", function()
		self.aggroHighlightBase:SetShown(false);
		self.aggroHighlightAdditive:SetShown(false);
		self.aggroHighlightMask:SetShown(false);
		self.AggroHighlightScrollAnim:Stop();
	end);

	-- Nothing in the nameplate is clickable. Hit testing is done at the C++ level using the location of HitTestFrame.
	self:EnableMouse(false);

	-- Prevent arbitrary modifcations of the frame used for hit testing.
	self.HitTestFrame:SetForbidden(true);

	self.HealthBarsContainer.healthBar:SetUnitNameFontString(self.name);

	-- Prevent the animation from playing unless it's needed.
	self.LoseAggroAnim:Stop();

	-- Necessary for CompactUnitFrame compatibility.
	do
		self.healthBar = self.HealthBarsContainer.healthBar;
		self.myHealPrediction = self.healthBar.myHealPrediction;
		self.otherHealPrediction = self.healthBar.otherHealPrediction;
		self.totalAbsorb = self.healthBar.totalAbsorb;
		self.totalAbsorbOverlay = self.healthBar.totalAbsorbOverlay;
		self.overAbsorbGlow = self.healthBar.overAbsorbGlow;
		self.myHealAbsorb = self.healthBar.myHealAbsorb;
		self.myHealAbsorbLeftShadow = self.healthBar.myHealAbsorbLeftShadow;
		self.myHealAbsorbRightShadow = self.healthBar.myHealAbsorbRightShadow;
		self.overHealAbsorbGlow = self.healthBar.overHealAbsorbGlow;
		self.classificationIndicator = self.ClassificationFrame.classificationIndicator;

		self.selectionHighlight:SetParent(self.HealthBarsContainer.healthBar);
		self.aggroFlash:SetParent(self.HealthBarsContainer.healthBar);
	end

	self.myHealPrediction:SetVertexColor(0.0, 0.659, 0.608);

	self.myHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);

	self.otherHealPrediction:SetVertexColor(0.0, 0.659, 0.608);

	self.totalAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Fill");
	self.totalAbsorb.overlay = self.totalAbsorbOverlay;

	self.totalAbsorbOverlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true);	--Tile both vertically and horizontally
	self.totalAbsorbOverlay.tileSize = 20;

	self.overAbsorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield");
	self.overAbsorbGlow:SetBlendMode("ADD");

	self.overHealAbsorbGlow:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb");
	self.overHealAbsorbGlow:SetBlendMode("ADD");

	self.myHealPrediction:ClearAllPoints();

	self.myHealAbsorb:ClearAllPoints();

	self.myHealAbsorbLeftShadow:ClearAllPoints();
	self.myHealAbsorbRightShadow:ClearAllPoints();

	self.otherHealPrediction:ClearAllPoints();

	self.totalAbsorb:ClearAllPoints();

	self.totalAbsorbOverlay:SetAllPoints(self.totalAbsorb);

	self.totalAbsorbOverlay:SetAllPoints(self.totalAbsorb);
end

function NamePlateUnitFrameMixin:OnEvent(event, ...)
	CompactUnitFrame_OnEvent(self, event, ...);

	if event == "UNIT_AURA" then
		local _unit, unitAuraUpdateInfo = ...;
		self.AurasFrame:RefreshAuras(unitAuraUpdateInfo);

		-- PvP Indicator uses aura data.
		self.ClassificationFrame:UpdateClassificationIndicator();
	elseif event == "UNIT_FACTION" then
		self:OnUnitFactionChanged();
	elseif event == "NAME_PLATE_UNIT_BEHIND_CAMERA_CHANGED" then
		local _unit, isBehindCamera = ...;
		self.isBehindCamera = isBehindCamera;
		self:UpdateBehindCamera();
	elseif event == "PLAYER_FOCUS_CHANGED" then
		self:UpdateIsFocus();
	elseif event == "RAID_TARGET_UPDATE" then
		self:UpdateRaidTarget();
	end
end

function NamePlateUnitFrameMixin:OnUnitSet()
	CVarCallbackRegistry:RegisterCallback(NamePlateConstants.SIMPLIFIED_TYPES_CVAR, self.UpdateIsSimplified, self);
	CVarCallbackRegistry:RegisterCallback(NamePlateConstants.CAST_BAR_DISPLAY_CVAR, self.UpdateCastBarDisplay, self);
	CVarCallbackRegistry:RegisterCallback(NamePlateConstants.SIZE_CVAR, self.UpdateScale, self);
	CVarCallbackRegistry:RegisterCallback(NamePlateConstants.SHOW_FRIENDLY_NPCS_CVAR, self.UpdateWidgetsOnlyMode, self);
	CVarCallbackRegistry:RegisterCallback(NamePlateConstants.THREAT_DISPLAY_CVAR, self.UpdateThreatDisplay, self);
	CVarCallbackRegistry:RegisterCallback(NamePlateConstants.DEBUFF_PADDING_CVAR, self.UpdateAnchors, self);
	CVarCallbackRegistry:RegisterCallback(NamePlateConstants.SHOW_ONLY_NAME_FOR_FRIENDLY_PLAYER_UNITS_CVAR, self.UpdateShowOnlyName, self);

	self:RegisterUnitEvent("UNIT_AURA", self.unit);
	self:RegisterUnitEvent("UNIT_FACTION", self.unit);
	self:RegisterUnitEvent("NAME_PLATE_UNIT_BEHIND_CAMERA_CHANGED", self.unit);
	self:RegisterEvent("PLAYER_FOCUS_CHANGED");
	self:RegisterEvent("RAID_TARGET_UPDATE");

	-- Needs to happen before any update logic is run.
	C_NamePlateManager.SetNamePlateHitTestFrame(self.unit, self.HitTestFrame);

	self:UpdateIsPlayer();
	self:UpdateIsFriend();
	self:UpdateIsDead();
	self:UpdateIsSimplified();
	self:UpdateIsTarget();
	self:UpdateIsFocus();
	self:UpdateRaidTarget();
	self:UpdateCastBarDisplay();
	self:UpdateScale();
	self:UpdateAggroHighlight();
	self:UpdateBehindCamera();
	self:UpdateWidgetsOnlyMode();
	self:UpdateShowOnlyName();

	self.AurasFrame:SetActive(not C_Commentator.IsSpectating());
	self.AurasFrame:SetUnit(self.unit);

	self.ClassificationFrame:SetOptions(self.optionTable);
	self.ClassificationFrame:SetUnit(self.unit);

	self.HealthBarsContainer.healthBar:SetUnit(self.unit);
end

function NamePlateUnitFrameMixin:OnUnitCleared()
	CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.SIMPLIFIED_TYPES_CVAR, self);
	CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.CAST_BAR_DISPLAY_CVAR, self);
	CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.SIZE_CVAR, self);
	CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.SHOW_FRIENDLY_NPCS_CVAR, self);
	CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.THREAT_DISPLAY_CVAR, self);
	CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.DEBUFF_PADDING_CVAR, self);
	CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.SHOW_ONLY_NAME_FOR_FRIENDLY_PLAYER_UNITS_CVAR, self);

	self:UnregisterEvent("UNIT_AURA");
	self:UnregisterEvent("UNIT_FACTION");
	self:UnregisterEvent("NAME_PLATE_UNIT_BEHIND_CAMERA_CHANGED");
	self:UnregisterEvent("PLAYER_FOCUS_CHANGED");
	self:UnregisterEvent("RAID_TARGET_UPDATE");

	-- Intentionally not calling Update functions but clearing the variables so the next time
	-- the Update functions are called they're not using a stale cached value.
	self.isPlayer = nil;
	self.isFriend = nil;
	self.isDead = nil;
	self.isSimplified = nil;
	self.isFocus = nil;
	self.isTarget = nil;
	self.widgetsOnlyMode = nil;
	self.showOnlyName = nil;

	self.aggroHighlightShown = nil;
	self.isBehindCamera = nil;

	self.AurasFrame:SetUnit(nil);
	self.ClassificationFrame:SetUnit(nil);
	self.HealthBarsContainer.healthBar:SetUnit(nil);
end

function NamePlateUnitFrameMixin:ApplyFrameOptions(setupOptions, frameOptions)
	local customOptions = self.customOptions;

	self.castBar:SetHeight(setupOptions.castBarHeight);
	self.castBar.Spark:SetHeight(setupOptions.castBarHeight + CAST_BAR_SPARK_EXTRA_HEIGHT);

	self.castBar.Text:SetTextHeight(setupOptions.castBarFontHeight);
	self.castBar.CastTargetNameText:SetTextHeight(setupOptions.castBarFontHeight);

	if setupOptions.unitNameInsideHealthBar then
		self.name:SetFontObject("SystemFont_NamePlate_Outlined");
		self.HealthBarsContainer.healthBar.Text:SetFontObject("SystemFont_NamePlate_Outlined");
		self.HealthBarsContainer.healthBar.LeftText:SetFontObject("SystemFont_NamePlate_Outlined");
		self.HealthBarsContainer.healthBar.RightText:SetFontObject("SystemFont_NamePlate_Outlined");

		-- Clickable region defined by both name and health bar.
		self.HitTestFrame:SetPoint("TOPLEFT", self.HealthBarsContainer.healthBar);
		self.HitTestFrame:SetPoint("BOTTOMRIGHT", self.HealthBarsContainer.healthBar);
	else
		-- Outlined font is harder to read when text is outside the health bar.
		self.name:SetFontObject("SystemFont_NamePlate");
		self.HealthBarsContainer.healthBar.Text:SetFontObject("SystemFont_NamePlate");
		self.HealthBarsContainer.healthBar.LeftText:SetFontObject("SystemFont_NamePlate");
		self.HealthBarsContainer.healthBar.RightText:SetFontObject("SystemFont_NamePlate");

		-- Clickable region is just the health bar.
		self.HitTestFrame:SetPoint("TOPLEFT", self.name);
		self.HitTestFrame:SetPoint("BOTTOMRIGHT", self.HealthBarsContainer.healthBar);
	end

	self.name:SetTextHeight(setupOptions.healthBarFontHeight);
	self.HealthBarsContainer.healthBar.Text:SetTextHeight(setupOptions.healthBarFontHeight);
	self.HealthBarsContainer.healthBar.LeftText:SetTextHeight(setupOptions.healthBarFontHeight);
	self.HealthBarsContainer.healthBar.RightText:SetTextHeight(setupOptions.healthBarFontHeight);

	self.ClassificationFrame:SetScale(setupOptions.classificationScale or 1.0);
	self.PlayerLevelDiffFrame:SetScale(setupOptions.classificationScale or 1.0);

	CompactUnitFrame_SetOptionTable(self, frameOptions);

	self:UpdateAnchors();
end

function NamePlateUnitFrameMixin:OnUnitFactionChanged()
	CompactUnitFrame_UpdateName(self);
	CompactUnitFrame_UpdateHealthColor(self);
	self:UpdateIsFriend();
end

function NamePlateUnitFrameMixin:UpdateIsPlayer()
	local isPlayer = false;

	-- Allow special cases (e.g. the Options Preview Nameplate) to control whether the nameplate is displaying for a player unit.
	if self.explicitIsPlayer ~= nil then
		isPlayer = self.explicitIsPlayer;
	elseif self.unit ~= nil then
		isPlayer = UnitIsPlayer(self.unit);
	end

	if self.isPlayer == isPlayer then
		return;
	end

	self.isPlayer = isPlayer;

	self:UpdateShowOnlyName();

	self.AurasFrame:SetIsPlayer(self.isPlayer);
	self.HealthBarsContainer.healthBar:SetIsPlayer(self.isPlayer);
end

function NamePlateUnitFrameMixin:IsPlayer()
	return self.isPlayer == true;
end

function NamePlateUnitFrameMixin:IsFriend()
	return self.isFriend == true;
end

function NamePlateUnitFrameMixin:UpdateIsFriend()
	local isFriend = false;

	-- Allow special cases (e.g. the Options Preview Nameplate) to control whether the nameplate is displaying for a friendly unit.
	if self.explicitIsFriend ~= nil then
		isFriend = self.explicitIsFriend;
	elseif self.unit ~= nil then
		isFriend = UnitIsFriend("player", self.unit);
	end

	if self.isFriend == isFriend then
		return;
	end

	self.isFriend = isFriend;

	self:UpdateThreatDisplay();
	self:UpdateShowOnlyName();

	self.AurasFrame:SetIsFriend(self.isFriend);
end

function NamePlateUnitFrameMixin:IsDead()
	return self.isDead == true;
end

function NamePlateUnitFrameMixin:UpdateIsDead()
	local isDead = false;

	if self.unit ~= nil then
		isDead = UnitIsDead(self.unit);
	end

	if self.isDead == isDead then
		return;
	end

	self.isDead = isDead;

	self.HealthBarsContainer.healthBar:SetIsDead(self.isDead);
end

function NamePlateUnitFrameMixin:IsMinion()
	-- Allow special cases (e.g. the Options Preview Nameplate) to control whether the nameplate is displaying for a minion.
	if self.explicitIsMinion ~= nil then
		return self.explicitIsMinion;
	end

	return UnitIsMinion(self.unit);
end

function NamePlateUnitFrameMixin:IsMinusMob()
	-- Allow special cases (e.g. the Options Preview Nameplate) to control whether the nameplate is displaying for a minion.
	if self.explicitIsMinusMob ~= nil then
		return self.explicitIsMinusMob;
	end

	return UnitClassification(self.unit) == "minus";
end

function NamePlateUnitFrameMixin:ShouldBeSimplified()
	if not self.unit then
		return false;
	end

	local simplifiedMinions = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.SIMPLIFIED_TYPES_CVAR, Enum.NamePlateSimplifiedType.Minion);
	if simplifiedMinions and self:IsMinion() then
		return true;
	end

	local simplifiedMinusMobs = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.SIMPLIFIED_TYPES_CVAR, Enum.NamePlateSimplifiedType.MinusMob);
	if simplifiedMinusMobs and self:IsMinusMob() then
		return true;
	end

	local simplifiedFriendlyPlayer = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.SIMPLIFIED_TYPES_CVAR, Enum.NamePlateSimplifiedType.FriendlyPlayer);
	if simplifiedFriendlyPlayer and self:IsPlayer() and self:IsFriend() then
		return true;
	end

	local simplifiedFriendlyNpc = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.SIMPLIFIED_TYPES_CVAR, Enum.NamePlateSimplifiedType.FriendlyNpc);
	if simplifiedFriendlyNpc and not self:IsPlayer() and self:IsFriend() then
		return true;
	end

	return false;
end

function NamePlateUnitFrameMixin:IsSimplified()
	return self.isSimplified == true;
end

function NamePlateUnitFrameMixin:UpdateIsSimplified()
	local isSimplified = self:ShouldBeSimplified();

	if isSimplified == self.isSimplified then
		return;
	end

	self.isSimplified = isSimplified;

	-- The NamePlateManager needs to know if this nameplate is simplified so it can scale it down.
	C_NamePlateManager.SetNamePlateSimplified(self.unit, isSimplified);

	-- Unit name is hidden for simplified units unless they're the player's current target.
	CompactUnitFrame_UpdateName(self);

	self.AurasFrame:SetIsSimplified(isSimplified);
	self.HealthBarsContainer.healthBar:SetIsSimplified(isSimplified);
end

function NamePlateUnitFrameMixin:ShouldBeTarget()
	if not self.unit then
		return false;
	end

	if self.selectionHighlight:IsShown() then
		return true;
	end

	return false;
end

function NamePlateUnitFrameMixin:IsTarget()
	return self.isTarget == true;
end

function NamePlateUnitFrameMixin:UpdateIsTarget()
	local isTarget = self:ShouldBeTarget();

	if isTarget == self.isTarget then
		return;
	end

	self.isTarget = isTarget;

	self.HealthBarsContainer.healthBar:SetIsTarget(isTarget);
end

function NamePlateUnitFrameMixin:ShouldBeFocus()
	if not self.unit then
		return false;
	end

	return UnitIsUnit(self.unit, "focus");
end

function NamePlateUnitFrameMixin:IsFocus()
	return self.isFocus == true;
end

function NamePlateUnitFrameMixin:UpdateIsFocus()
	local isFocus = self:ShouldBeFocus();

	if isFocus == self.isFocus then
		return;
	end

	self.isFocus = isFocus;

	self.HealthBarsContainer.healthBar:SetIsFocus(isFocus);
end

function NamePlateUnitFrameMixin:GetRaidTargetIndex()
	-- Don't display raid icons on other players.
	if self:IsPlayer() then
		return nil;
	end

	return GetRaidTargetIndex(self.unit);
end

function NamePlateUnitFrameMixin:UpdateRaidTarget()
	local index = self:GetRaidTargetIndex();

	self.RaidTargetFrame:SetRaidTargetIndex(index);
	self.ClassificationFrame:SetRaidTargetIndex(index);
end

function NamePlateUnitFrameMixin:ShouldAggroHighlightBeShown()
	-- Driven by logic in CompactUnitFrame_UpdateAggroHighlight
	return self.aggroHighlight:IsShown();
end

function NamePlateUnitFrameMixin:UpdateAggroHighlight()
	local shouldBeShown = self:ShouldAggroHighlightBeShown();

	if self.aggroHighlightShown == nil then
		-- The first time running the logic bypass the fading animations and immediately enter the correct state of shown or not.
		self.aggroHighlightBase:SetShown(shouldBeShown);
		self.aggroHighlightAdditive:SetShown(shouldBeShown);
		self.aggroHighlightMask:SetShown(shouldBeShown);
		self.AggroHighlightScrollAnim:SetPlaying(shouldBeShown);
	elseif shouldBeShown == true and self.aggroHighlightShown == false then
		-- Fade the pieces in from their current alpha value.
		self.aggroHighlightBase:SetShown(shouldBeShown);
		self.aggroHighlightAdditive:SetShown(shouldBeShown);
		self.aggroHighlightMask:SetShown(shouldBeShown);
		self.AggroHighlightFadeInAnim.aggroHighlightBaseAlpha:SetFromAlpha(self.aggroHighlightBase:GetAlpha());
		self.AggroHighlightFadeInAnim.aggroHighlightAdditiveAlpha:SetFromAlpha(self.aggroHighlightAdditive:GetAlpha());
		self.AggroHighlightFadeOutAnim:Stop();
		self.AggroHighlightFadeInAnim:Play();
		self.AggroHighlightScrollAnim:Play();
	elseif shouldBeShown == false and self.aggroHighlightShown == true then
		-- Fade the pieces out from their current alpha value.
		self.AggroHighlightFadeOutAnim.aggroHighlightBaseAlpha:SetFromAlpha(self.aggroHighlightBase:GetAlpha());
		self.AggroHighlightFadeOutAnim.aggroHighlightAdditiveAlpha:SetFromAlpha(self.aggroHighlightAdditive:GetAlpha());
		self.AggroHighlightFadeInAnim:Stop();
		self.AggroHighlightFadeOutAnim:Play();
	end

	self.aggroHighlightShown = shouldBeShown;

	-- Keep the colors of all the pieces in sync when threat state changes.
	if shouldBeShown then
		local r, g, b, _a = self.aggroHighlight:GetVertexColor();
		self.aggroHighlightBase:SetVertexColor(r, g, b);
		self.aggroHighlightAdditive:SetVertexColor(r, g, b);
	end
end

function NamePlateUnitFrameMixin:UpdateCastBarDisplay()
	local spellNameShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.CAST_BAR_DISPLAY_CVAR, Enum.NamePlateCastBarDisplay.SpellName);
	self.castBar:SetNameTextShown(spellNameShown);

	local iconShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.CAST_BAR_DISPLAY_CVAR, Enum.NamePlateCastBarDisplay.SpellIcon);
	self.castBar:SetIconShown(iconShown);

	local spellTargetShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.CAST_BAR_DISPLAY_CVAR, Enum.NamePlateCastBarDisplay.SpellTarget);
	self.castBar:SetTargetNameTextShown(spellTargetShown);

	local highlightImportantCasts = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.CAST_BAR_DISPLAY_CVAR, Enum.NamePlateCastBarDisplay.HighlightImportantCasts);
	self.castBar:SetHighlightImportantCasts(highlightImportantCasts);

	local highlightWhenCastTarget = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.CAST_BAR_DISPLAY_CVAR, Enum.NamePlateCastBarDisplay.HighlightWhenCastTarget);
	self.castBar:SetHighlightWhenCastTarget(highlightWhenCastTarget);
end

function NamePlateUnitFrameMixin:GetScaleData()
	local namePlateSize = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.SIZE_CVAR);
	return NamePlateConstants.NAME_PLATE_SCALES[namePlateSize] or NamePlateConstants.NAME_PLATE_SCALES[Enum.NamePlateSize.Medium];
end

function NamePlateUnitFrameMixin:UpdateScale()
	local scaleData = self:GetScaleData();

	local aggroHighlightScale = scaleData.aggroHighlight;
	self.aggroHighlightBase:SetScale(aggroHighlightScale);
	self.aggroHighlightAdditive:SetScale(aggroHighlightScale);
	self.aggroHighlightMask:SetScale(aggroHighlightScale);

	self.AurasFrame:UpdateScale(scaleData);
end

function NamePlateUnitFrameMixin:UpdateBehindCamera()
	-- Once the value has been initialized, all changes to the value will be provided by the event.
	if self.isBehindCamera == nil and self.unit ~= nil then
		self.isBehindCamera = C_NamePlateManager.IsNamePlateUnitBehindCamera(self.unit);
	end

	self.behindCameraIcon:SetShown(self.isBehindCamera ~= nil and self.isBehindCamera);
end

function NamePlateUnitFrameMixin:UpdateWidgetsOnlyMode()
	self.widgetsOnlyMode = self.unit ~= nil and UnitNameplateShowsWidgetsOnly(self.unit);

	CompactUnitFrame_UpdateName(self);

	self.HealthBarsContainer.healthBar:SetWidgetsOnlyMode(self.widgetsOnlyMode);
	self.castBar:SetWidgetsOnlyMode(self.widgetsOnlyMode);
	self.AurasFrame:SetWidgetsOnlyMode(self.widgetsOnlyMode);
	self.ClassificationFrame:SetWidgetsOnlyMode(self.widgetsOnlyMode);
	self.RaidTargetFrame:SetWidgetsOnlyMode(self.widgetsOnlyMode);

	self.WidgetContainer:ClearAllPoints();
	if inWidgetsOnlyMode then
		PixelUtil.SetPoint(self.WidgetContainer, "BOTTOM", self, "BOTTOM", 0, 0);
	else
		PixelUtil.SetPoint(self.WidgetContainer, "TOP", self.castBar, "BOTTOM", 0, 0);
	end
end

function NamePlateUnitFrameMixin:IsShowOnlyName()
	return self.showOnlyName == true;
end

function NamePlateUnitFrameMixin:UpdateShowOnlyName()
	local showOnlyName = false;

	if self:IsFriend() and self:IsPlayer() and CVarCallbackRegistry:GetCVarValueBool(NamePlateConstants.SHOW_ONLY_NAME_FOR_FRIENDLY_PLAYER_UNITS_CVAR) then
		showOnlyName = true;
	end

	if self.showOnlyName == showOnlyName then
		return;
	end

	self.showOnlyName = showOnlyName;

	self.HealthBarsContainer.healthBar:SetShowOnlyName(showOnlyName);
	self.castBar:SetShowOnlyName(showOnlyName);
	self.AurasFrame:SetShowOnlyName(showOnlyName);
	self.ClassificationFrame:SetShowOnlyName(showOnlyName);
	self.RaidTargetFrame:SetShowOnlyName(showOnlyName);

	self:UpdateAnchors();
end

function NamePlateUnitFrameMixin:UpdateThreatDisplay()
	if self:IsFriend() == false then
		self.displayAggroFlash = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.THREAT_DISPLAY_CVAR, Enum.NamePlateThreatDisplay.Flash);
		self.displayAggroHighlight = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.THREAT_DISPLAY_CVAR, Enum.NamePlateThreatDisplay.Progressive);
		self.displayThreatHealthBarColor = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.THREAT_DISPLAY_CVAR, Enum.NamePlateThreatDisplay.HealthBarColor);
	else
		self.displayAggroFlash = false;
		self.displayAggroHighlight = false;
		self.displayThreatHealthBarColor = false;
	end

	CompactUnitFrame_UpdateAggroFlash(self);
	CompactUnitFrame_UpdateAggroHighlight(self);
	CompactUnitFrame_UpdateHealthColor(self);
end

function NamePlateUnitFrameMixin:ShouldShowName()
	if self.widgetsOnlyMode == true then
		return false;
	end

	-- Leverage logic in CompactUnitFrame.
	return ShouldShowName(self);
end

function NamePlateUnitFrameMixin:UpdateAnchors()
	local customOptions = self.customOptions;
	local setupOptions = NamePlateSetupOptions;

	-- Anchoring logic starts from bottom of the frame and works its way upwards.

	-- Cast Bar
	do
		self.castBar:ClearAllPoints();
		self.castBar.Icon:ClearAllPoints();
		self.castBar.BorderShield:ClearAllPoints();

		-- If spell name is inside the cast bar, the cast bar is the bottom most region.
		-- Otherwise the icon and name are the bottom most region.
		if setupOptions.spellNameInsideCastBar == true then
			PixelUtil.SetPoint(self.castBar, "BOTTOMLEFT", self, "BOTTOMLEFT", 12, 0);
			PixelUtil.SetPoint(self.castBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", -12, 0);

			PixelUtil.SetPoint(self.castBar.Icon, "LEFT", self.castBar, "LEFT", 0, 0);
		else
			PixelUtil.SetPoint(self.castBar.Icon, "BOTTOMLEFT", self, "BOTTOMLEFT", 12, 0);

			PixelUtil.SetPoint(self.castBar, "BOTTOM", self.castBar.Icon, "TOP", 0, 0);
			PixelUtil.SetPoint(self.castBar, "LEFT", self, "BOTTOMLEFT", 12, 0);
			PixelUtil.SetPoint(self.castBar, "RIGHT", self, "BOTTOMRIGHT", -12, 0);
		end

		PixelUtil.SetSize(self.castBar.Icon, setupOptions.castIconWidth, setupOptions.castIconHeight);

		-- The uninterruptable spell icon occupies the same place on the screen as the spell icon. They
		-- don't display at the same time. Only interruptable spells display the spell icon.
		PixelUtil.SetSize(self.castBar.BorderShield, setupOptions.castBarShieldWidth, setupOptions.castBarShieldHeight);
		PixelUtil.SetPoint(self.castBar.BorderShield, "RIGHT", self.castBar.Icon, "RIGHT", 0, 0);
	end

	-- Health Bar
	do
		self.HealthBarsContainer:ClearAllPoints();

		PixelUtil.SetPoint(self.HealthBarsContainer, "BOTTOMLEFT", self.castBar, "TOPLEFT", 0, 2);
		PixelUtil.SetPoint(self.HealthBarsContainer, "BOTTOMRIGHT", self.castBar, "TOPRIGHT", 0, 2);
		PixelUtil.SetHeight(self.HealthBarsContainer, setupOptions.healthBarHeight);

		local healthBar = self.HealthBarsContainer.healthBar;
		local healthBarText = healthBar.Text;
		local healthBarLeftText = healthBar.LeftText;
		local healthBarRightText = healthBar.RightText;

		self.name:ClearAllPoints();
		healthBarText:ClearAllPoints();
		healthBarLeftText:ClearAllPoints();
		healthBarRightText:ClearAllPoints();

		if self:IsShowOnlyName() then
			self.name:SetJustifyH("CENTER");

			if setupOptions.unitNameInsideHealthBar == true then
				PixelUtil.SetPoint(self.name, "LEFT", self.HealthBarsContainer, "LEFT", 4, 0);
				PixelUtil.SetPoint(self.name, "RIGHT", self.HealthBarsContainer, "RIGHT", -4, 0);
			else
				PixelUtil.SetPoint(self.name, "BOTTOMLEFT", self.HealthBarsContainer, "TOPLEFT", 4, 2);
				PixelUtil.SetPoint(self.name, "BOTTOMRIGHT", self.HealthBarsContainer, "TOPRIGHT", -4, 2);
			end
		else
			self.name:SetJustifyH("LEFT");

			-- Unit name needs to truncate if the health bar text is populated.
			-- Left Text (percentage) is intentionally to the right of Right Text (numeric value)
			if setupOptions.unitNameInsideHealthBar == true then
				PixelUtil.SetPoint(healthBarLeftText, "RIGHT", self.HealthBarsContainer.healthBar, "RIGHT", -4, 0);
				PixelUtil.SetPoint(healthBarRightText, "RIGHT", healthBarLeftText, "LEFT", -2, 0);
				PixelUtil.SetPoint(healthBarText, "RIGHT", healthBarRightText, "LEFT", 2, 0);
				PixelUtil.SetPoint(self.name, "LEFT", self.HealthBarsContainer, "LEFT", 4, 0);
				PixelUtil.SetPoint(self.name, "RIGHT", healthBarText, "LEFT", -2, 0);
			else
				PixelUtil.SetPoint(healthBarLeftText, "BOTTOMRIGHT", self.HealthBarsContainer.healthBar, "TOPRIGHT", -4, 2);
				PixelUtil.SetPoint(healthBarRightText, "BOTTOMRIGHT", healthBarLeftText, "BOTTOMLEFT", -2, 0);
				PixelUtil.SetPoint(healthBarText, "BOTTOMRIGHT", healthBarRightText, "BOTTOMLEFT", 2, 0);
				PixelUtil.SetPoint(self.name, "BOTTOMLEFT", self.HealthBarsContainer, "TOPLEFT", 4, 2);
				PixelUtil.SetPoint(self.name, "BOTTOMRIGHT", healthBarText, "BOTTOMLEFT", -2, 0);
			end
		end

		PixelUtil.SetHeight(self.name, self.name:GetLineHeight());

		if not customOptions or not customOptions.ignoreOverAbsorbGlow then
			self.overAbsorbGlow:ClearAllPoints();
			PixelUtil.SetPoint(self.overAbsorbGlow, "BOTTOMLEFT", self.HealthBarsContainer.healthBar, "BOTTOMRIGHT", -4, -1);
			PixelUtil.SetPoint(self.overAbsorbGlow, "TOPLEFT", self.HealthBarsContainer.healthBar, "TOPRIGHT", -4, 1);
			PixelUtil.SetHeight(self.overAbsorbGlow, 8);
		end

		if not customOptions or not customOptions.ignoreOverHealAbsorbGlow then
			self.overHealAbsorbGlow:ClearAllPoints();
			PixelUtil.SetPoint(self.overHealAbsorbGlow, "BOTTOMRIGHT", self.HealthBarsContainer.healthBar, "BOTTOMLEFT", 2, -1);
			PixelUtil.SetPoint(self.overHealAbsorbGlow, "TOPRIGHT", self.HealthBarsContainer.healthBar, "TOPLEFT", 2, 1);
			PixelUtil.SetWidth(self.overHealAbsorbGlow, 8);
		end

		local bgTexture = healthBar.bgTexture;
		PixelUtil.SetPoint(bgTexture, "TOPLEFT", healthBar, "TOPLEFT", -2, 3);
		PixelUtil.SetPoint(bgTexture, "BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 5, -6);
	end

	-- Auras Frame
	do
		local debuffPadding = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.DEBUFF_PADDING_CVAR);

		if setupOptions.unitNameInsideHealthBar == true then
			PixelUtil.SetPoint(self.AurasFrame.DebuffListFrame, "BOTTOM", self.HealthBarsContainer.healthBar, "TOP", 0, debuffPadding);
		else
			PixelUtil.SetPoint(self.AurasFrame.DebuffListFrame, "BOTTOM", self.name, "TOP", 0, debuffPadding);
		end
	end
end

function NamePlateUnitFrameMixin:SetExplicitValues(explicitValues)
	self.explicitIsPlayer = explicitValues.isPlayer;
	self.explicitIsFriend = explicitValues.isFriend;
	self.explicitIsMinion = explicitValues.isMinion;
	self.explicitIsMinusMob = explicitValues.isMinusMob;
	self.explicitThreatSituation = explicitValues.threatSituation;
	self.explicitAggroFlash = explicitValues.aggroFlash;

	self:UpdateIsPlayer();
	self:UpdateIsFriend();
	self:UpdateIsSimplified();
	self:UpdateNameOverride();

	self.AurasFrame:SetExplicitValues(explicitValues);
	self.ClassificationFrame:SetExplicitValues(explicitValues);
end
