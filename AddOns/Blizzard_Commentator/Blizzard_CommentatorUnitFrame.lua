LOSS_OF_CONTROL_ACTIVE_INDEX = 1;

CommentatorUnitFrameMixin = {};

local CommentatorUnitFrameEvents =
{
	"COMBAT_LOG_EVENT_UNFILTERED",
	"ARENA_COOLDOWNS_UPDATE",
	"ARENA_CROWD_CONTROL_SPELL_UPDATE",
	"COMMENTATOR_PLAYER_UPDATE",
	"COMMENTATOR_PLAYER_NAME_OVERRIDE_UPDATE",
	"LOSS_OF_CONTROL_COMMENTATOR_ADDED",
	"LOSS_OF_CONTROL_COMMENTATOR_UPDATE",
};

local LifeState = 
{
	Alive = 1,
	FeigningDeath = 2,
	Dead = 3,
};

function CommentatorUnitFrameMixin:OnLoad()
	self.alignment = "LEFT";
	self.Name:SetFontObjectsToTry(CommentatorFontMedium, CommentatorFontSmall);

	local seconds = 60;
	self.CCRemover.Cooldown:SetCountdownAbbrevThreshold(seconds);
	self.CCRemover.Cooldown:SetSwipeColor(0, 0, 0, .7);
	self.Circle.CCCooldown:SetHideCountdownNumbers(true);
	self.Circle.CCCooldown:SetSwipeColor(0, 0, 0, .7);

	self.Bars:SetFrameLevel(self:GetFrameLevel() - 1);
end

function CommentatorUnitFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CommentatorUnitFrameEvents);

	self:UpdateCCRemover();
end

function CommentatorUnitFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CommentatorUnitFrameEvents);
end

function CommentatorUnitFrameMixin:SetAlignment(alignment)
	local oldAlignment = self.alignment;
	if alignment ~= oldAlignment then
		self.alignment = alignment;

		local mirrorDescriptions = {
			{region = self.Bars},
			{region = self.Bars.Overlay, mirrorUV = true},
			{region = self.Bars.HealthBar},
			{region = self.Bars.PowerBar},
			{region = self.Bars.AbsorbBar},
			{region = self.Role},
			{region = self.Circle},
			{region = self.CCRemover},
			{region = self.Name},
			{region = self.DefensiveSpellTray},
			{region = self.DebuffSpellTray},
			{region = self.OffensiveSpellTray},
			{region = self.FlagIcon, mirrorUV = true},
			{region = self.FlagIconStatic, mirrorUV = true},
			{region = self.FlagIconStatic2, mirrorUV = true},
		};
		AnchorUtil.MirrorRegionsAlongHorizontalAxis(mirrorDescriptions);
	end
end

function CommentatorUnitFrameMixin:Init(isAlignedLeft, playerData, teamIndex)
	self:Reset();

	self.playerData = playerData;
	if playerData then
		self.isInitializing = true;
		self.unitToken = playerData.unitToken;
		self.guid = UnitGUID(self.unitToken);
		self.teamIndex = teamIndex;

		C_PvP.RequestCrowdControlSpell(self.unitToken);
		
		self.ModelScene:Init(self.unitToken, self.guid, self.Circle);

		-- Spec omitted from BC commentator.
		self.Role:Hide();

		self:SetClass(select(2, UnitClass(self.unitToken)))

		self:InitSpells();
	else
		self.teamIndex = nil;
		self.unitToken = nil;
		self.guid = nil;
	end

	self.timeOfDeath = nil;

	self:SetAlignment(isAlignedLeft and "LEFT" or "RIGHT");
end

function CommentatorUnitFrameMixin:OnUnfilteredCombatLogEvent(...)
	--Dump({...)};
	local event = select(2, ...);
	local isActive = event == "SPELL_AURA_APPLIED";
	if isActive or event == "SPELL_AURA_REMOVED" then
		local sourceGUID = select(4, ...);
		if self:GetGUID() == sourceGUID then
			local trackedSpellID = C_Commentator.GetTrackedSpellID(select(12, ...));
			self:SetSpellActive(trackedSpellID, isActive);
		end
	elseif event == "ARENA_MATCH_START" then
		-- Tempoary equipment change check.
		C_PvP.RequestCrowdControlSpell(self.unitToken);
	end
end

function CommentatorUnitFrameMixin:OnEvent(event, ...)	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		self:OnUnfilteredCombatLogEvent(CombatLogGetCurrentEventInfo());
	elseif event == "COMMENTATOR_PLAYER_UPDATE" then
		self:InitSpells();
	elseif event == "ARENA_COOLDOWNS_UPDATE" then
		local unitToken = ...;
		if unitToken == self.unitToken then
			self:UpdateCCRemover();
			self:InitSpells();
		end
	elseif event == "ARENA_CROWD_CONTROL_SPELL_UPDATE" then
		local unitToken, spellID, itemID = ...;
		if unitToken == self.unitToken then
			if itemID ~= 0 then
				self:SetCCRemoverItemIcon(itemID);
			else
				self:SetCCRemoverSpellIcon(spellID);
			end
		end
	elseif event == "LOSS_OF_CONTROL_COMMENTATOR_ADDED" then
		local guid , index = ...;
		if self:GetGUID() == guid then
			self:ApplyLossOfControlAtIndex(index);
		end
	elseif event == "LOSS_OF_CONTROL_COMMENTATOR_UPDATE" then
		local guid = ...;
		if self:GetGUID() == guid then
			self:ApplyLossOfControlAtIndex(LOSS_OF_CONTROL_ACTIVE_INDEX);
		end
	end
end

function CommentatorUnitFrameMixin:SetMinified(minified)
	self.Name:ClearAllPoints();
	if minified then
		self.Name:SetPoint("TOPLEFT", self.Bars.HealthBar, "TOPLEFT");
		self.Name:SetPoint("BOTTOMRIGHT", self.Bars.HealthBar, "BOTTOMRIGHT");
	else
		self.Name:SetPoint("TOPLEFT", self.Bars.HealthBar, "TOPLEFT", 0, 20);
		self.Name:SetPoint("BOTTOMRIGHT", self.Bars.HealthBar, "BOTTOMRIGHT", 0, 45);
	end

	self.Bars.Overlay:SetAtlas(minified and "Metal-Bar-Battlegrounds" or "Metal-Bar");

	self.Name:SetScale(minified and .75 or 1);
	self.Name:SetAlpha(minified and .75 or 1);

	self.Circle:SetShown(not minified);
	self.DefensiveSpellTray:SetShown(not minified);
	self.OffensiveSpellTray:SetShown(not minified);
	self.DebuffSpellTray:SetShown(not minified);
end

function CommentatorUnitFrameMixin:OnSizeChanged()
	self.Name:ApplyFontObjects();
end

function CommentatorUnitFrameMixin:ApplyLossOfControlData(data)
	if data and data.locType ~= "SCHOOL_INTERRUPT" then
		self.ccDisplayText = data.displayText;
	else
		self.ccDisplayText = nil;
	end

	self:UpdatePlayerNameText();
end

function CommentatorUnitFrameMixin:ApplyLossOfControlAtIndex(index)
	local data = C_LossOfControl.GetActiveLossOfControlDataByUnit(self.unitToken, index);
	self:ApplyLossOfControlData(data);
end

function CommentatorUnitFrameMixin:OnUpdate(elapsed)
	if self.initSpellThrottle and self.initSpellThrottle:Update(elapsed) then
		self.initSpellThrottle = nil;
	end

	local hasFlag = C_Commentator.GetPlayerFlagInfoByUnit(self.unitToken);
	self.FlagIcon:SetShown(hasFlag);
	self.FlagIconStatic:SetShown(hasFlag);
	self.FlagIconStatic2:SetShown(hasFlag);
	if hasFlag then
		local enemyColor = C_Commentator.GetTeamColor(CommentatorUtil.GetOppositeTeamIndex(self.teamIndex));
		self.FlagIcon:SetVertexColor(enemyColor.r, enemyColor.g, enemyColor.b, enemyColor.a);
	end

	local color = C_Commentator.GetTeamColor(self.teamIndex);
	for index, overlay in ipairs(self.Circle.TeamOverlays) do
		overlay:SetVertexColor(color.r, color.g, color.b, color.a);
	end

	if UnitExists(self.unitToken) then
		local unitData = C_Commentator.GetUnitData(self.unitToken);
		self:SetMaxHP(unitData.healthMax);
		self:SetHP(unitData.health);
		self:SetAbsorb(unitData.health, unitData.absorbTotal, unitData.healthMax);
		self:SetPowerType(unitData.powerTypeToken);
		if unitData.isDeadOrGhost then
			self:SetLifeState(LifeState.Dead);
			self:SetMaxPower(0);
			self:SetPower(0);
		else
			if unitData.isFeignDeath then
			self:SetLifeState(LifeState.FeigningDeath);
		else
			self:SetLifeState(LifeState.Alive);
		end
			self:SetMaxPower(unitData.powerMax);
			self:SetPower(unitData.power);
		end

		self:UpdatePlayerNameText();

		self:UpdateCameraWeight(not unitData.isFeignDeath and unitData.isDeadOrGhost);
	else
		self.ModelScene:Reset();
		
		self:SetAbsorb(0, 0, 0);
		self:SetMaxPower(0)
		self:SetPower(0);
	end

	self:UpdateCrowdControlAuras();
	self:UpdateSpellTrays(elapsed);

	self.isInitializing = false;
end

function CommentatorUnitFrameMixin:UpdatePlayerNameText()
	self:SetPlayerNameText(self:GetPlayerNameText());
end

function CommentatorUnitFrameMixin:SetPlayerNameText(text)
	self.Name:SetText(text);
end

function CommentatorUnitFrameMixin:GetPlayerNameText()
	if self.lifeState == LifeState.Dead then
		return COMMENTATOR_UNITFRAME_DEAD_STR;
	elseif self.ccDisplayText and GetCVarBool("commentatorLossOfControlTextUnitFrame") then
		return self.ccDisplayText;
	else
		return self:GetPlayerName();
	end
end

function CommentatorUnitFrameMixin:GetPlayerName()
	return self.playerData.name or "";
end

function CommentatorUnitFrameMixin:GetGUID()
	return self.guid;
end

function CommentatorUnitFrameMixin:SetClass(class)
	if class then
		self.Circle.ClassIcon:SetAtlas(GetClassAtlas(class));
		local r, g, b, hex = GetClassColor(class);
		self.Bars.HealthBar:SetStatusBarColor(r, g, b, 1.0);
	end
end

function CommentatorUnitFrameMixin:Reset()
	self.initSpellThrottle = nil;
	for index, spellTray in ipairs(self.spellTrays) do
		spellTray:Reset();
	end
end

function CommentatorUnitFrameMixin:Invalidate()
	self:UnregisterEvent("COMMENTATOR_PLAYER_UPDATE");
end

function CommentatorUnitFrameMixin:IsInitializing()
	return self.isInitializing;
end

function CommentatorUnitFrameMixin:SetHP(health)
	if self:IsInitializing() then
		self.Bars.HealthBar:ResetSmoothedValue(health);
	else
		self.Bars.HealthBar:SetSmoothedValue(health);
	end
end

function CommentatorUnitFrameMixin:SetMaxHP(healthMax)
	self.Bars.HealthBar:SetMinMaxSmoothedValue(0, healthMax);
	if self:IsInitializing() then
		self.Bars.HealthBar:ResetSmoothedValue();
	end
end

function CommentatorUnitFrameMixin:SetAbsorb(health, totalAbsorb, healthMax)
	self.Bars.AbsorbBar:SetMinMaxSmoothedValue(0, healthMax);
	local effectiveHealth = health + totalAbsorb;
	self.Bars.AbsorbBar:SetSmoothedValue(effectiveHealth);
	if self:IsInitializing() then
		self.Bars.AbsorbBar:ResetSmoothedValue();
	end
	
	local canOverAbsorb = totalAbsorb > 0 and effectiveHealth >= healthMax;
	self.Bars.AbsorbBar.OverAbsorb:SetShown(canOverAbsorb);
end

function CommentatorUnitFrameMixin:UpdateCameraWeight(dead)
	if dead then
		local time = GetTime();
		if not self.timeOfDeath then
			self.timeOfDeath = time;
		end

		if time > self.timeOfDeath + 5.0 then
			C_Commentator.SetAdditionalCameraWeightByToken(self.unitToken, 0.0);
		end
	else
		self.timeOfDeath = nil;
		C_Commentator.SetAdditionalCameraWeightByToken(self.unitToken, 1.0);
	end
end

function CommentatorUnitFrameMixin:SetLifeState(lifeState)
	if self.lifeState ~= lifeState then
		self.lifeState = lifeState;

		local circle = self.Circle;
		if lifeState == LifeState.Dead then
			circle.DeathIcon:Show();
			circle.FeignDeathIcon:Hide();
		else
			if lifeState == LifeState.FeigningDeath then
				circle.DeathIcon:Hide();
				circle.FeignDeathIcon:Show();
			else
				circle.DeathIcon:Hide();
				circle.FeignDeathIcon:Hide();
			end
		end
	end
end

function CommentatorUnitFrameMixin:SetPower(power)
	self.Bars.PowerBar:SetSmoothedValue(power);
end

function CommentatorUnitFrameMixin:SetMaxPower(powerMax)
	self.Bars.PowerBar:SetMinMaxSmoothedValue(0, powerMax);
end

function CommentatorUnitFrameMixin:SetPowerType(powerType)
	local color = GetPowerBarColor(powerType);
	if color then
		self.Bars.PowerBar:SetStatusBarColor(color.r, color.g, color.b);
	end
end

function CommentatorUnitFrameMixin:GetRole()
	return self.role;
end

function CommentatorUnitFrameMixin:SetSpellActive(trackedSpellID, isActive)
	for index, spellTray in ipairs(self.spellTrays) do
		if C_Commentator.IsTrackedSpellByUnit(self.unitToken, trackedSpellID, spellTray.category) then
			spellTray:SetSpellActive(trackedSpellID, isActive);
		end
	end
end

function CommentatorUnitFrameMixin:SetCCRemoverSpellIcon(spellID)
	local spellValid = spellID > 0;
	self.CCRemover:SetShown(spellValid);

	if spellValid then
		local textureID = select(3, GetSpellInfo(spellID));
		self:SetCCRemoverIcon(textureID);
	end
end

function CommentatorUnitFrameMixin:SetCCRemoverItemIcon(itemID)
	local itemValid = itemID > 0;
	self.CCRemover:SetShown(itemValid);

	if itemValid then
		local textureID = GetItemIcon(itemID);
		self:SetCCRemoverIcon(textureID);
	end
end

function CommentatorUnitFrameMixin:SetCCRemoverIcon(textureID)
	local icon = self.CCRemover.Icon;
	if textureID ~= icon.textureID then
		icon.textureID = textureID;
		icon:SetTexture(textureID);
	end
end

function CommentatorUnitFrameMixin:UpdateCCRemover()
	if self.unitToken then
		local spellID, itemID, startTimeMs, durationMs = C_PvP.GetArenaCrowdControlInfo(self.unitToken);
		if spellID then
			if(itemID ~= 0) then
				self:SetCCRemoverItemIcon(itemID);
			else
				self:SetCCRemoverSpellIcon(spellID);
			end
			
			if (startTimeMs ~= 0 and durationMs ~= 0) then
				self.CCRemover.Cooldown:SetCooldown(startTimeMs / 1000.0, durationMs / 1000.0);
			else
				self.CCRemover.Cooldown:Clear();
			end
		else
			C_PvP.RequestCrowdControlSpell(self.unitToken);
		end
	end
end

function CommentatorUnitFrameMixin:UpdateCrowdControlAuras()
	if not GetCVarBool("commentatorLossOfControlIconUnitFrame") then
		return;
	end

	local spellID, expirationTime, duration = C_Commentator.GetPlayerCrowdControlInfoByUnit(self.unitToken);
	if expirationTime and self.ccSpellID ~= spellID then
		self.Circle.CCCooldown:SetCooldown(expirationTime - duration, duration);
	end

	self.ccExpirationTime = expirationTime;
	self.ccSpellID = spellID;

	local isCCed = spellID ~= nil;
	self.Circle.CCIcon:SetShown(isCCed);
	if isCCed then
		local textureID = select(3, GetSpellInfo(spellID));
		if textureID then
			self.Circle.CCIcon:SetTexture(textureID);
		end
	end

	local timeRemaining = self.ccExpirationTime and math.max(self.ccExpirationTime - GetTime(), 0) or 0;
	if timeRemaining > 0 then
		self.Circle.CCText:SetFormattedText("%.1f", timeRemaining);
		self.Circle.CCText:Show();
	else
		self.Circle.CCText:Hide();
		self.Circle.CCCooldown:Clear();
	end
end

function CommentatorUnitFrameMixin:UpdateSpellTrays(elapsed)
	for index, spellTray in ipairs(self.spellTrays) do
		spellTray:OnUpdate(elapsed);
	end
end

function CommentatorUnitFrameMixin:InitSpells()
	local defer = false;
	for index, spellTray in ipairs(self.spellTrays) do
		local success = spellTray:InitSpells(self.alignment, self.unitToken);
		if not success then
			defer = true;
		end
	end

	if defer then
		self.initSpellThrottle = CreateAndInitFromMixin(FunctionThrottleMixin, 1.0, self.InitSpells, self);
	end
end