
local LEFT_ALIGNMENT = "left";
local RIGHT_ALIGNMENT = "right";

local IS_CAMERA_TARGET = true;
local IS_COMPACT = true;
local HAS_POWER = true;

local MAX_AURA_INDEX_TO_CHECK = 40;

CommentatorUnitFrameMixin = {};

function CommentatorUnitFrameMixin:Initialize(align)
	self:SetScale(.8);
	
	self.align = align or LEFT_ALIGNMENT;
	self.isCameraTarget = false;
	self.compact = false;
	self.canBeVisible = false;

	self.offensiveCooldownPool = CreateCommentatorCooldownPool(self, self:GetTeamAndPlayer());
	self.defensiveCooldownPool = CreateCommentatorCooldownPool(self, self:GetTeamAndPlayer());
	
	self:EvaluateRelayout();

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("ARENA_COOLDOWNS_UPDATE");
	self:RegisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE");
	
	self.DeadText:SetFontObjectsToTry(CommentatorDeadFontDefault, CommentatorDeadFontMedium, CommentatorDeadFontSmall);
end

function CommentatorUnitFrameMixin:OnEvent(event, ...)	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		self:OnCombatEvent(CombatLogGetCurrentEventInfo());
	elseif event == "COMMENTATOR_PLAYER_UPDATE" then
		self:FullCooldownRefresh();
	elseif ( event == "ARENA_COOLDOWNS_UPDATE" ) then
		local token = ...;
		if token == self.token then
			self:UpdateCrowdControlRemover();
			self:FullCooldownRefresh();
		end
	elseif ( event == "ARENA_CROWD_CONTROL_SPELL_UPDATE" ) then
		local token, spellID = ...;
		if token == self.token then
			self:SetCrowdControlRemoverIcon(spellID);
		end
	end
end

function CommentatorUnitFrameMixin:OnSizeChanged()
	self.DeadText:ApplyFontObjects();
end

local LAYOUT_TABLE = {
	[LEFT_ALIGNMENT] = {
		[IS_CAMERA_TARGET] = {
			[not IS_COMPACT] = {
				[HAS_POWER] = "team_left_power",
				[not HAS_POWER] = "team_left",
			},
			[IS_COMPACT] = {
				[HAS_POWER] = "team_left_compact_power",
				[not HAS_POWER] = "team_left_compact",
			},
		},
		[not IS_CAMERA_TARGET] = {
			[not IS_COMPACT] = {
				[HAS_POWER] = "team_left_power",
				[not HAS_POWER] = "team_left",
			},
			[IS_COMPACT] = {
				[HAS_POWER] = "team_left_compact_power",
				[not HAS_POWER] = "team_left_compact",
			},
		},
	},

	[RIGHT_ALIGNMENT] = {
		[IS_CAMERA_TARGET] = {
			[not IS_COMPACT] = {
				[HAS_POWER] = "team_right_power",
				[not HAS_POWER] = "team_right",
			},
			[IS_COMPACT] = {
				[HAS_POWER] = "team_right_compact_power",
				[not HAS_POWER] = "team_right_compact",
			},
		},
		[not IS_CAMERA_TARGET] = {
			[not IS_COMPACT] = {
				[HAS_POWER] = "team_right_power",
				[not HAS_POWER] = "team_right",
			},
			[IS_COMPACT] = {
				[HAS_POWER] = "team_right_compact_power",
				[not HAS_POWER] = "team_right_compact",
			},
		},
	},
};

function CommentatorUnitFrameMixin:CalculateLayout()
	local showPower = not self.compact or self.role == "HEALER";
	return LAYOUT_TABLE[self.align][self.isCameraTarget][self.compact][showPower];
end

function CommentatorUnitFrameMixin:EvaluateRelayout()
	local newLayout = self:CalculateLayout();

	if self.layout ~= newLayout then
		self.layout = newLayout;
		self.isLayoutDirty = true;
	end
end

function CommentatorUnitFrameMixin:GetAdditionalYSpacing()
	local FOCUS_ADDITIONAL_PADDING = 0;
	return self.isCameraTarget and FOCUS_ADDITIONAL_PADDING or 0;
end

function CommentatorUnitFrameMixin:AlignLeft()
	self.align = LEFT_ALIGNMENT;
	self:EvaluateRelayout();
end

function CommentatorUnitFrameMixin:AlignRight()
	self.align = RIGHT_ALIGNMENT;
	self:EvaluateRelayout();
end

function CommentatorUnitFrameMixin:SetCompact(compact)
	self.compact = not not compact;
	self:EvaluateRelayout();
end

function CommentatorUnitFrameMixin:AreUpdatesAllowed()
	-- For now, stop updating when the game ends
	return GetBattlefieldWinner() == nil;
end

local COOLDOWN_REFRESH_TIME = 1.0;
function CommentatorUnitFrameMixin:OnUpdate(elapsed)
	if self.isLayoutDirty then
		self.isLayoutDirty = false;
		self:ApplyLayout(self.layout);
	end
	
	if self.needsCooldownData then
		self.timeSinceLastFullCooldownRefresh = self.timeSinceLastFullCooldownRefresh + elapsed;
		if self.timeSinceLastFullCooldownRefresh > COOLDOWN_REFRESH_TIME then
			self:FullCooldownRefresh();
		end
	end

	if not self:AreUpdatesAllowed() then return end

	local maxHealth = UnitHealthMax(self.token);
	self:SetMaxHP(maxHealth);
	local health = UnitHealth(self.token);
	self:SetHP(health);
	self:SetAbsorb(health, UnitGetTotalAbsorbs(self.token) or 0, maxHealth);

	self:SetFlagInfo(C_Commentator.GetPlayerFlagInfo(self.teamIndex, self.playerIndex));

	self:SetMaxPower(UnitPowerMax(self.token))
	self:SetPower(UnitPower(self.token));

	self:SetPowerType(select(2, UnitPowerType(self.token)));

	self:SetLifeState(UnitIsFeignDeath(self.token), UnitIsDeadOrGhost(self.token));
	self:UpdateCameraWeight(not UnitIsFeignDeath(self.token) and UnitIsDeadOrGhost(self.token));

	self:UpdateOnFireEffectAuras();
	self:UpdateOnFireEffectVisuals(elapsed);

	self:UpdateCrowdControlAuras();
	self:UpdateCrowdControlAurasText();

	self.tokenChanging = false;
end

function CommentatorUnitFrameMixin:SetPlayerName(name)
	self.Name:SetText(name);
end

function CommentatorUnitFrameMixin:GetPlayerName()
	return self.Name:GetText() or "";
end

function CommentatorUnitFrameMixin:GetToken()
	return self.token;
end

function CommentatorUnitFrameMixin:IsValid()
	return self.token ~= nil;
end

function CommentatorUnitFrameMixin:GetGUID()
	return self.guid;
end

function CommentatorUnitFrameMixin:SetClass(class)
	if class and CLASS_ICON_TCOORDS[class] then
		self.ClassIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));

		local color = RAID_CLASS_COLORS[class];
		if color then
			self.HealthBar:SetStatusBarColor(color.r, color.g, color.b, 1.0);
		else
			self.HealthBar:SetStatusBarColor(0, 1.0, 0, 1.0);
		end
	end
end

function CommentatorUnitFrameMixin:SetTeamAndPlayer(teamIndex, playerIndex)
	local token, playerName, faction, specID = C_Commentator.GetPlayerInfo(teamIndex, playerIndex);
	
	self.offensiveCooldownPool:SetTeamAndPlayer(teamIndex, playerIndex);
	self.defensiveCooldownPool:SetTeamAndPlayer(teamIndex, playerIndex);
	
	if token then
		self.token = token;
		self.tokenChanging = true;

		self.Name:SetText(playerName);
		self.Name:SetTextColor(C_Commentator.GetTeamHighlightColor(teamIndex));

		self:SetClass(select(2, UnitClass(self.token)))

		C_PvP.RequestCrowdControlSpell(self.token);

		self.role = GetSpecializationRoleByID(specID);
		if self.role == nil or self.role == "DAMAGER" then
			self.RoleIcon:Hide();
		else
			self.RoleIcon:Show();
			if self.role == "HEALER" then
				self.RoleIcon:SetAtlas("HealerBadge");
			elseif self.role == "TANK" then
				self.RoleIcon:SetAtlas("TankBadge");
			end
		end

		self.guid = UnitGUID(self.token);
		self.playerIndex = playerIndex;
		self.teamIndex = teamIndex;
		self.specID = specID;
		self:FullCooldownRefresh();
		self:RegisterEvent("COMMENTATOR_PLAYER_UPDATE");
	else
		self.token = nil;
		self.guid = nil;
		self.playerIndex = nil;
		self.teamIndex = nil;
		self:UnregisterEvent("COMMENTATOR_PLAYER_UPDATE");
	end

	self.onFireEffectCurrentScale = 0;
	self.onFireEffectTargetScale = 0;
	self.OffensiveCooldownModel:SetModelScale(0);
	
	self.DefensiveCooldownModel:Hide();
	
	self.timeOfDeath = nil;
	
	self:UpdateVisibility();
	self:EvaluateRelayout();
end

function CommentatorUnitFrameMixin:GetTeamAndPlayer()
	return self.teamIndex, self.playerIndex;
end

function CommentatorUnitFrameMixin:OnLayoutApplied()
	self.TrinketIcon:SetShown(self.TrinketIcon.enabled);
	self.PowerBar:SetShown(self.PowerBar.enabled);
	self.OffensiveCooldownContainer:SetShown(self.OffensiveCooldownContainer.enabled);
	self.DefensiveCooldownContainer:SetShown(self.DefensiveCooldownContainer.enabled);
end

function CommentatorUnitFrameMixin:Invalidate()
	if self:IsValid() then
		self.token = nil;
		self:UnregisterEvent("COMMENTATOR_PLAYER_UPDATE");
		self:UpdateVisibility();
	end
end

function CommentatorUnitFrameMixin:SetVisibility(canBeVisible)
	self.canBeVisible = canBeVisible;
	self:UpdateVisibility();
end

function CommentatorUnitFrameMixin:UpdateVisibility()
	self:SetShown(self.canBeVisible and self:IsValid());
end

function CommentatorUnitFrameMixin:ShouldResetAnimatedBars()
	return self.tokenChanging;
end

function CommentatorUnitFrameMixin:SetHP(health)
	if self:ShouldResetAnimatedBars() then
		self.HealthBar:ResetSmoothedValue(health);
	else
		self.HealthBar:SetSmoothedValue(health);
	end
end

function CommentatorUnitFrameMixin:SetMaxHP(healthMax)
	self.HealthBar:SetMinMaxSmoothedValue(0, healthMax);
	if self:ShouldResetAnimatedBars() then
		self.HealthBar:ResetSmoothedValue();
	end
end

function CommentatorUnitFrameMixin:SetAbsorb(health, totalAbsorb, healthMax)
	self.AbsorbBar:SetMinMaxSmoothedValue(0, healthMax);
	self.AbsorbBar:SetSmoothedValue(health + totalAbsorb);
	if self:ShouldResetAnimatedBars() then
		self.AbsorbBar:ResetSmoothedValue();
	end
	
	self.HealthBar.OverAbsorb:SetShown(totalAbsorb > 0 and health + totalAbsorb >= healthMax);
end

function CommentatorUnitFrameMixin:SetFlagInfo(hasFlag)
	self.FlagIcon:SetShown(hasFlag);
	self.FlagIconHighlight:SetShown(hasFlag);
	if hasFlag then
		UIFrameFlash(self.FlagIconHighlight, 0.5, 0.5, -1);
		
		if self.teamIndex == 1 then
			self.FlagIcon:SetAtlas("tournamentarena-flag-large-blue");
			self.FlagIconHighlight:SetAtlas("tournamentarena-flag-large-blue-flash");
		else
			self.FlagIcon:SetAtlas("tournamentarena-flag-large-red");
			self.FlagIconHighlight:SetAtlas("tournamentarena-flag-large-red-flash");
		end
	else
		UIFrameFlashStop(self.FlagIconHighlight);
	end
	self:UpdateFlagAnchors();
end

function CommentatorUnitFrameMixin:UpdateFlagAnchors()
	if self.FlagIcon:IsShown() then
		self.FlagIcon:ClearAllPoints();
		local point, relPoint = "LEFT", "RIGHT";
		local reverseAlign = self.align == RIGHT_ALIGNMENT;
		local offsetXDirection = 1;
		if reverseAlign then
			point, relPoint = relPoint, point;
			offsetXDirection = -1;
		end
		local offsetY = -2;
		if self.compact then
			offsetY = -5;
		end
		if self.CCIcon:IsShown() then
			self.FlagIcon:SetPoint(point, self.CCIcon, relPoint, 5 * offsetXDirection, offsetY);
		else
			self.FlagIcon:SetPoint(point, self.CCIcon, point, 12 * offsetXDirection, offsetY);
		end
	end
end

function CommentatorUnitFrameMixin:UpdateCameraWeight(dead)
	if dead then
		if not self.timeOfDeath then
			self.timeOfDeath = GetTime();
		end

		if GetTime() > self.timeOfDeath + 5.0 then
			C_Commentator.SetAdditionalCameraWeight(self.teamIndex, self.playerIndex, 0.0);
		end
	else
		self.timeOfDeath = nil;
		C_Commentator.SetAdditionalCameraWeight(self.teamIndex, self.playerIndex, 1.0);
	end
end

function CommentatorUnitFrameMixin:SetLifeState(feigned, dead)
	self.DeadText:SetShown(not feigned and dead);
	self.DeathIcon:SetShown(not feigned and dead);
	self.DeathOverlay:SetShown(not feigned and dead);

	self.FeignIcon:SetShown(feigned);
end

function CommentatorUnitFrameMixin:SetPower(power)
	self.PowerBar:SetSmoothedValue(power, self:ShouldResetAnimatedBars());
end

function CommentatorUnitFrameMixin:SetMaxPower(powerMax)
	self.PowerBar:SetMinMaxSmoothedValue(0, powerMax, self:ShouldResetAnimatedBars());
end

function CommentatorUnitFrameMixin:SetPowerType(powerType)
	local color = PowerBarColor[powerType];
	if color then
		self.PowerBar:SetStatusBarColor(color.r, color.g, color.b);
	end
end

function CommentatorUnitFrameMixin:GetRole()
	return self.role;
end

function CommentatorUnitFrameMixin:OnCombatEvent(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	if not self:IsValid() then return end

	local guid = self:GetGUID();
	local isSource = guid == sourceGUID;
	local isDest = guid == destGUID;

	if isSource then
		if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" then
			local spellID = ...;
			if C_Commentator.IsTrackedOffensiveCooldown(self.teamIndex, self.playerIndex, spellID) then
				self.offensiveCooldownPool:SetCooldownIsActive(spellID, event == "SPELL_AURA_APPLIED");
			end
			
			if C_Commentator.IsTrackedDefensiveCooldown(self.teamIndex, self.playerIndex, spellID) then
				self.defensiveCooldownPool:SetCooldownIsActive(spellID, event == "SPELL_AURA_APPLIED");
			end
		end
	end

	if isDest then
		if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" then
			local spellID = ...;
			if C_Commentator.IsTrackedOffensiveAura(spellID) or C_Commentator.IsTrackedDefensiveAura(spellID) then
				self.onFireEffectAurasDirty = true;
			end
		end
	end
end

function CommentatorUnitFrameMixin:SetCrowdControlRemoverIcon(spellID)
	if (spellID ~= self.TrinketIcon.spellID) then
		local _, _, spellTexture = GetSpellInfo(spellID);
		self.TrinketIcon.spellID = spellID;
		self.TrinketIcon:SetTexture(spellTexture);
	end
end

function CommentatorUnitFrameMixin:UpdateCrowdControlRemover()
	if not self.token then
		return
	end
	
	local spellID, startTime, duration = C_PvP.GetArenaCrowdControlInfo(self.token);
	if (spellID) then
		self:SetCrowdControlRemoverIcon(spellID);
		
		if (startTime ~= 0 and duration ~= 0) then
			self.CooldownFrame:SetCooldown(startTime/1000.0, duration/1000.0);
		else
			self.CooldownFrame:Clear();
		end
	else
		C_PvP.RequestCrowdControlSpell(self.token);
	end
end

function CommentatorUnitFrameMixin:UpdateCrowdControlAuras()
	local spellID, expirationTime, duration = C_Commentator.GetPlayerCrowdControlInfo(self.teamIndex, self.playerIndex);
	local icon = select(3, GetSpellInfo(spellID));
	self.ccExpirationTime = expirationTime;

	local isCCed = self.ccExpirationTime ~= nil;

	self.CCIcon:SetShown(isCCed);
	self.CCIconGlow:SetShown(isCCed);
	self.CCOverlay:SetShown(isCCed);

	if icon then
		self.CCIcon:SetTexture(icon);
	end

	self:UpdateFlagAnchors();
end

function CommentatorUnitFrameMixin:UpdateOnFireEffectAuras()
	if not self.onFireEffectAurasDirty then return end
	self.onFireEffectAurasDirty = false;

	self:SetOnFireEffectShown(C_Commentator.HasTrackedAuras(self.token));
end

local SCALE_AMOUNT_PER_SEC = .05;
function CommentatorUnitFrameMixin:UpdateOnFireEffectVisuals(elapsed)
	self.onFireEffectCurrentScale = DeltaLerp(self.onFireEffectCurrentScale, self.onFireEffectTargetScale * self.OffensiveCooldownModel.modelScale, SCALE_AMOUNT_PER_SEC, elapsed);
	if self.onFireEffectCurrentScale < .01 then
		self.OffensiveCooldownModel:Hide();
	else
		self.OffensiveCooldownModel:SetModelScale(self.onFireEffectCurrentScale);
		self.OffensiveCooldownModel:Show();
	end
end

function CommentatorUnitFrameMixin:SetOnFireEffectShown(isOnFireEffectShown, defensiveFireEffectShown)
	self.onFireEffectTargetScale = isOnFireEffectShown and 1.0 or 0.0;
	if defensiveFireEffectShown then
		self.DefensiveCooldownModel:Show();
	else
		self.DefensiveCooldownModel:Hide();
	end
end

function CommentatorUnitFrameMixin:UpdateCrowdControlAurasText()
	if self.ccExpirationTime then
		local now = GetTime();
		local timeLeft = self.ccExpirationTime - now;
		if timeLeft > 0 then
			self.CCText:SetFormattedText("%.1f", timeLeft);
			self.CCText:Show();
		else
			self.CCText:Hide();
		end
	else
		self.CCText:Hide();
	end
end

function CommentatorUnitFrameMixin:FullCooldownRefresh()
	local PADDING = 11;
	self.needsCooldownData = false;
	self.timeSinceLastFullCooldownRefresh = 0;
	
	local offensiveCooldowns = C_Commentator.GetTrackedOffensiveCooldowns(self.teamIndex, self.playerIndex);
	if offensiveCooldowns then
		self.offensiveCooldownPool:SetCooldowns(offensiveCooldowns, self.OffensiveCooldownContainer, "LEFT", PADDING);	
	else
		self.needsCooldownData = true;
	end
	
	local defensiveCooldowns = C_Commentator.GetTrackedDefensiveCooldowns(self.teamIndex, self.playerIndex);
	if defensiveCooldowns then
		self.defensiveCooldownPool:SetCooldowns(defensiveCooldowns, self.DefensiveCooldownContainer, "LEFT", PADDING);
	else
		self.needsCooldownData = true;
	end
end
