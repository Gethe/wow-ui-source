
local LEFT_ALIGNMENT = "left";
local RIGHT_ALIGNMENT = "right";

local IS_CAMERA_TARGET = true;
local HAS_POWER = true;

local MAX_AURA_INDEX_TO_CHECK = 40;

COMMENTATOR_UNIT_FRAME_STANDARD = 0;
COMMENTATOR_UNIT_FRAME_COMPACT = 1;
COMMENTATOR_UNIT_FRAME_VERY_COMPACT = 2;
COMMENTATOR_UNIT_FRAME_EXTREMELY_COMPACT = 3;

CommentatorUnitFrameMixin = {};

function CommentatorUnitFrameMixin:Initialize(align)
	self:SetScale(.8);
	
	self.align = align or LEFT_ALIGNMENT;
	self.isCameraTarget = false;
	self.compactLevel = COMMENTATOR_UNIT_FRAME_STANDARD;
	self.canBeVisible = false;
	
	self:EvaluateRelayout();
	
	self.DeadText:SetFontObjectsToTry(CommentatorDeadFontDefault, CommentatorDeadFontMedium, CommentatorDeadFontSmall);
end

function CommentatorUnitFrameMixin:OnSizeChanged()
	self.DeadText:ApplyFontObjects();
end

local LAYOUT_TABLE = {
	[LEFT_ALIGNMENT] = {
		[IS_CAMERA_TARGET] = {
			[COMMENTATOR_UNIT_FRAME_STANDARD] = {
				[HAS_POWER] = "team_left_power",
				[not HAS_POWER] = "team_left",
			},
			[COMMENTATOR_UNIT_FRAME_COMPACT] = {
				[HAS_POWER] = "team_left_compact_power",
				[not HAS_POWER] = "team_left_compact",
			},
			[COMMENTATOR_UNIT_FRAME_VERY_COMPACT] = {
				[HAS_POWER] = "team_left_veryCompact_power",
				[not HAS_POWER] = "team_left_veryCompact",
			},
			[COMMENTATOR_UNIT_FRAME_EXTREMELY_COMPACT] = {
				[HAS_POWER] = "team_left_extremelyCompact_power",
				[not HAS_POWER] = "team_left_extremelyCompact",
			},
		},
		[not IS_CAMERA_TARGET] = {
			[COMMENTATOR_UNIT_FRAME_STANDARD] = {
				[HAS_POWER] = "team_left_power",
				[not HAS_POWER] = "team_left",
			},
			[COMMENTATOR_UNIT_FRAME_COMPACT] = {
				[HAS_POWER] = "team_left_compact_power",
				[not HAS_POWER] = "team_left_compact",
			},
			[COMMENTATOR_UNIT_FRAME_VERY_COMPACT] = {
				[HAS_POWER] = "team_left_veryCompact_power",
				[not HAS_POWER] = "team_left_veryCompact",
			},
			[COMMENTATOR_UNIT_FRAME_EXTREMELY_COMPACT] = {
				[HAS_POWER] = "team_left_extremelyCompact_power",
				[not HAS_POWER] = "team_left_extremelyCompact",
			},
		},
	},

	[RIGHT_ALIGNMENT] = {
		[IS_CAMERA_TARGET] = {
			[COMMENTATOR_UNIT_FRAME_STANDARD] = {
				[HAS_POWER] = "team_right_power",
				[not HAS_POWER] = "team_right",
			},
			[COMMENTATOR_UNIT_FRAME_COMPACT] = {
				[HAS_POWER] = "team_right_compact_power",
				[not HAS_POWER] = "team_right_compact",
			},
			[COMMENTATOR_UNIT_FRAME_VERY_COMPACT] = {
				[HAS_POWER] = "team_right_veryCompact_power",
				[not HAS_POWER] = "team_right_veryCompact",
			},
			[COMMENTATOR_UNIT_FRAME_EXTREMELY_COMPACT] = {
				[HAS_POWER] = "team_right_extremelyCompact_power",
				[not HAS_POWER] = "team_right_extremelyCompact",
			},
		},
		[not IS_CAMERA_TARGET] = {
			[COMMENTATOR_UNIT_FRAME_STANDARD] = {
				[HAS_POWER] = "team_right_power",
				[not HAS_POWER] = "team_right",
			},
			[COMMENTATOR_UNIT_FRAME_COMPACT] = {
				[HAS_POWER] = "team_right_compact_power",
				[not HAS_POWER] = "team_right_compact",
			},
			[COMMENTATOR_UNIT_FRAME_VERY_COMPACT] = {
				[HAS_POWER] = "team_right_veryCompact_power",
				[not HAS_POWER] = "team_right_veryCompact",
			},
			[COMMENTATOR_UNIT_FRAME_EXTREMELY_COMPACT] = {
				[HAS_POWER] = "team_right_extremelyCompact_power",
				[not HAS_POWER] = "team_right_extremelyCompact",
			},
		},
	},
};

function CommentatorUnitFrameMixin:CalculateLayout()
	local showPower = true; --not self:IsCompact() or self.role == "HEALER";
	return LAYOUT_TABLE[self.align][self.isCameraTarget][self.compactLevel][showPower];
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

function CommentatorUnitFrameMixin:SetCompact(compactLevel)
	self.compactLevel = compactLevel;
	self:EvaluateRelayout();
end

function CommentatorUnitFrameMixin:IsCompact()
	return self.compactLevel >= COMMENTATOR_UNIT_FRAME_COMPACT;
end

function CommentatorUnitFrameMixin:IsVeryCompact()
	return self.compactLevel >= COMMENTATOR_UNIT_FRAME_VERY_COMPACT;
end

function CommentatorUnitFrameMixin:IsExtremelyCompact()
	return self.compactLevel >= COMMENTATOR_UNIT_FRAME_EXTREMELY_COMPACT;
end

function CommentatorUnitFrameMixin:AreUpdatesAllowed()
	-- For now, stop updating when the game ends
	return GetBattlefieldWinner() == nil;
end

function CommentatorUnitFrameMixin:OnUpdate(elapsed)
	if self.isLayoutDirty then
		self.isLayoutDirty = false;
		self:ApplyLayout(self.layout);
	end

	if not self:AreUpdatesAllowed() then return end

	local maxHealth = UnitHealthMax(self.token);
	self:SetMaxHP(maxHealth);
	local health = UnitHealth(self.token);
	self:SetHP(health);

	self:SetFlagInfo(C_Commentator.GetPlayerFlagInfo(self.teamIndex, self.playerIndex));

	self:SetMaxPower(UnitPowerMax(self.token))
	self:SetPower(UnitPower(self.token));

	self:SetPowerType(select(2, UnitPowerType(self.token)));

	self:SetLifeState(UnitIsFeignDeath(self.token), UnitIsDeadOrGhost(self.token));
	self:UpdateCameraWeight(not UnitIsFeignDeath(self.token) and UnitIsDeadOrGhost(self.token));

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
	
	if token then
		self.token = token;
		self.tokenChanging = true;

		self.Name:SetText(playerName);
		self.Name:SetTextColor(C_Commentator.GetTeamHighlightColor(teamIndex));

		self:SetClass(select(2, UnitClass(self.token)))

		self.guid = UnitGUID(self.token);
		self.playerIndex = playerIndex;
		self.teamIndex = teamIndex;
		self.specID = specID;
	else
		self.token = nil;
		self.guid = nil;
		self.playerIndex = nil;
		self.teamIndex = nil;
	end
	
	self.timeOfDeath = nil;
	
	self:UpdateVisibility();
	self:EvaluateRelayout();
end

function CommentatorUnitFrameMixin:GetTeamAndPlayer()
	return self.teamIndex, self.playerIndex;
end

function CommentatorUnitFrameMixin:OnLayoutApplied()
	self.PowerBar:SetShown(self.PowerBar.enabled);
end

function CommentatorUnitFrameMixin:Invalidate()
	if self:IsValid() then
		self.token = nil;
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

function CommentatorUnitFrameMixin:SetFlagInfo(hasFlag)
	self.FlagIcon:SetShown(hasFlag);
	self.FlagIconHighlight:SetShown(hasFlag);
	if hasFlag then
		UIFrameFlash(self.FlagIconHighlight, 0.5, 0.5, -1);

		if self.teamIndex == 2 then
			-- TeamIndex 2 = Horde = Cap the Alliance Flag
			self.FlagIcon:SetAtlas("tournamentarena-flag-large-blue");
			self.FlagIconHighlight:SetAtlas("tournamentarena-flag-large-blue-flash");
		else
			-- TeamIndex 2 = Alliance = Cap the Horde Flag
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
		if self:IsCompact() then
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
