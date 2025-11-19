MAX_COMBO_POINTS = 5;
MAX_TARGET_DEBUFFS = 16;
MAX_TARGET_BUFFS = 32;
MAX_BOSS_FRAMES = 5;

-- aura positioning constants
local AURA_START_X = 21;
local AURA_START_Y = 28;
local AURA_START_Y_MIRROR = -19;
local AURA_OFFSET_Y = 1;
local LARGE_AURA_SIZE = 21;
local SMALL_AURA_SIZE = 17;
local AURA_ROW_WIDTH = 122;
local TOT_AURA_ROW_WIDTH = 101;
local NUM_TOT_AURA_ROWS = 2;	-- TODO: replace with TOT_AURA_ROW_HEIGHT functionality if this becomes a problem

-- focus frame scales
local LARGE_FOCUS_SCALE = 1;
local SMALL_FOCUS_SCALE = 0.75;
local SMALL_FOCUS_UPSCALE = 1.333;

local PLAYER_UNITS = {
	player = true,
	vehicle = true,
	pet = true,
};

TARGET_FRAME_TEXTURES = {
	normal = "Interface\\TargetingFrame\\UI-TargetingFrame",
	minus = "Interface\\TargetingFrame\\UI-TargetingFrame-Minus",
	elite = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
	rareelite = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite",
	rare = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare",
};

CVarCallbackRegistry:SetCVarCachable("showTargetOfTarget");

TargetFrameMixin = {};

function TargetFrameMixin:OnLoad(unit, menuFunc)
	self.HealthBar.LeftText = self.textureFrame.HealthBarTextLeft;
	self.HealthBar.RightText = self.textureFrame.HealthBarTextRight;
	self.PowerBar.LeftText = self.textureFrame.ManaBarTextLeft;
	self.PowerBar.RightText = self.textureFrame.ManaBarTextRight;

	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;

	local thisName = self:GetName();
	self.borderTexture = _G[thisName.."TextureFrameTexture"];
	self.highLevelTexture = _G[thisName.."TextureFrameHighLevelTexture"];
	self.pvpIcon = _G[thisName.."TextureFramePVPIcon"];
	self.leaderIcon = _G[thisName.."TextureFrameLeaderIcon"];
	self.raidTargetIcon = _G[thisName.."TextureFrameRaidTargetIcon"];
	self.questIcon = _G[thisName.."TextureFrameQuestIcon"];
	self.levelText = _G[thisName.."TextureFrameLevelText"];
	self.deadText = _G[thisName.."TextureFrameDeadText"];
	self.unconsciousText = _G[thisName.."TextureFrameUnconsciousText"];
	self.petBattleIcon = _G[thisName.."TextureFramePetBattleIcon"];
	self.TOT_AURA_ROW_WIDTH = TOT_AURA_ROW_WIDTH;
	-- set simple frame
	if ( not self.showLevel ) then
		self.highLevelTexture:Hide();
		self.levelText:Hide();
	end
	-- set threat frame
	local threatFrame;
	if ( self.showThreat ) then
		threatFrame = _G[thisName.."Flash"];
	end
	-- set portrait frame
	local portraitFrame;
	if ( self.showPortrait ) then
		portraitFrame = _G[thisName.."Portrait"];
	end

	local healthBar = self.HealthBar;
	local manaBar = self.PowerBar;
	UnitFrame_Initialize(self, unit, self.textureFrame.Name, portraitFrame,
						healthBar,
						self.textureFrame.HealthBarText,
						manaBar,
						self.textureFrame.ManaBarText,
						threatFrame, "player", _G[thisName.."NumericalThreat"],
						healthBar.MyHealPredictionBar,
						healthBar.OtherHealPredictionBar,
						healthBar.TotalAbsorbBar, healthBar.TotalAbsorbBarOverlay,
						self.textureFrame.overAbsorbGlow, self.textureFrame.overHealAbsorbGlow,
						healthBar.HealAbsorbBar, healthBar.HealAbsorbBarLeftShadow,
						healthBar.HealAbsorbBarRightShadow, nil);

	self:Update();
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_HEALTH");
	if ( self.showLevel ) then
		self:RegisterEvent("UNIT_LEVEL");
	end
	self:RegisterEvent("UNIT_FACTION");
	if ( self.showClassification ) then
		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	end
	if ( self.showLeader ) then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	end
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterUnitEvent("UNIT_AURA", unit);
	self:RegisterUnitEvent("UNIT_TARGET", unit);

	SecureUnitButton_OnLoad(self, self.unit, menuFunc);
end

function TargetFrameMixin:Update()
	-- This check is here so the frame will hide when the target goes away
	-- even if some of the functions below are hooked by addons.
	if ( not ShouldShowTargetFrame(self) ) then
		self:Hide();
	else
		self:Show();

		-- Moved here to avoid taint from functions below
		if ( self.totFrame ) then
			self.totFrame:Update();
		end

		UnitFrame_Update(self);
		if ( self.showLevel ) then
			self:CheckLevel();
		end
		self:CheckFaction();
		if ( self.showClassification ) then
			self:CheckClassification();
		end
		self:CheckDead();
		self:CheckDishonorableKill();
		if ( self.showLeader ) then
			if ( UnitLeadsAnyGroup(self.unit) ) then
				self.leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
				self.leaderIcon:SetTexCoord(0, 1, 0, 1);
				self.leaderIcon:Show();
			else
				self.leaderIcon:Hide();
			end
		end
		self:UpdateAuras();
		if ( self.portrait ) then
			self.portrait:SetAlpha(1.0);
		end
		self:CheckBattlePet();
		if ( self.petBattleIcon ) then
			self.petBattleIcon:SetAlpha(1.0);
		end
	end
end

function TargetFrameMixin:OnEvent(event, ...)
	UnitFrame_OnEvent(self, event, ...);

	local arg1 = ...;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self:Update();
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		-- Moved here to avoid taint from functions below
		self:Update();
		self:UpdateRaidTargetIcon();

		if ( UnitExists(self.unit) and not C_PlayerInteractionManager.IsReplacingUnit()) then
			if ( UnitIsEnemy(self.unit, "player") ) then
				PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT);
			elseif ( UnitIsFriend("player", self.unit) ) then
				PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT);
			else
				PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT);
			end
		end
	elseif ( event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" ) then
		for i = 1, MAX_BOSS_FRAMES do
			_G["Boss"..i.."TargetFrame"]:Update();
			_G["Boss"..i.."TargetFrame"]:UpdateRaidTargetIcon();
		end
		UIParent_ManageFramePositions();
	elseif ( event == "UNIT_TARGETABLE_CHANGED" and arg1 == self.unit) then
		self:Update();
		self:UpdateRaidTargetIcon();
		UIParent_ManageFramePositions();
	elseif ( event == "UNIT_HEALTH" ) then
		if ( arg1 == self.unit ) then
			self:CheckDead();
		end
	elseif ( event == "UNIT_LEVEL" ) then
		if ( arg1 == self.unit ) then
			self:CheckLevel();
		end
	elseif ( event == "UNIT_FACTION" ) then
		if ( arg1 == self.unit or arg1 == "player" ) then
			self:CheckFaction();
			self:UpdateAuras();
			if ( self.showLevel ) then
				self:CheckLevel();
			end
		end
	elseif ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
		if ( arg1 == self.unit ) then
			self:CheckClassification();
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == self.unit ) then
			self:UpdateAuras();
		end
	elseif (event == "UNIT_TARGET") then
		if (self.totFrame) then
			self.totFrame:Update();
		end
	elseif ( event == "PLAYER_FLAGS_CHANGED" ) then
		if ( arg1 == self.unit ) then
			if ( UnitLeadsAnyGroup(self.unit) ) then
				self.leaderIcon:Show();
			else
				self.leaderIcon:Hide();
			end
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		self:Update();
		if (self.unit == "focus") then
			-- If this is the focus frame, clear focus if the unit no longer exists
			if (not UnitExists(self.unit)) then
				ClearFocus();
			end
		else
			if ( self.totFrame ) then
				self.totFrame:Update();
			end
			self:CheckFaction();
		end
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		self:UpdateRaidTargetIcon();
	elseif ( event == "PLAYER_FOCUS_CHANGED" ) then
		if ( UnitExists(self.unit) ) then
			self:Show();
			self:Update();
			self:UpdateRaidTargetIcon();
		else
			self:Hide();
		end
	end
end

function TargetFrameMixin:OnHide()
	PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT);
end

function TargetFrameMixin:CheckLevel()
	local targetEffectiveLevel = UnitLevel(self.unit);

	if ( UnitIsCorpse(self.unit) ) then
		self.levelText:Hide();
		self.highLevelTexture:Show();
	elseif (UnitIsWildBattlePet(self.unit) or UnitIsBattlePetCompanion(self.unit)) then
		local petLevel = UnitBattlePetLevel(self.unit);
		self.levelText:SetVertexColor(1.0, 0.82, 0.0);
		self.levelText:SetText(petLevel);
		self.levelText:Show();
		self.highLevelTexture:Hide();
	elseif ( targetEffectiveLevel > 0 ) then
		-- Normal level target
		self.levelText:SetText(targetEffectiveLevel);
		-- Color level number
		if ( UnitCanAttack("player", self.unit) ) then
			local color = GetCreatureDifficultyColor(targetEffectiveLevel);
			self.levelText:SetVertexColor(color.r, color.g, color.b);
		else
			self.levelText:SetVertexColor(1.0, 0.82, 0.0);
		end

		self.levelText:Show();
		self.highLevelTexture:Hide();
	else
		-- Target is too high level to tell
		self.levelText:Hide();
		self.highLevelTexture:Show();
	end
end

function TargetFrameMixin:CheckFaction()
	if ( not UnitPlayerControlled(self.unit) and UnitIsTapDenied(self.unit) ) then
		self.nameBackground:SetVertexColor(0.5, 0.5, 0.5);
		if ( self.portrait ) then
			self.portrait:SetVertexColor(0.5, 0.5, 0.5);
		end
	else
		self.nameBackground:SetVertexColor(UnitSelectionColor(self.unit));
		if ( self.portrait ) then
			self.portrait:SetVertexColor(1.0, 1.0, 1.0);
		end
	end

	if ( self.showPVP ) then
		local factionGroup = UnitFactionGroup(self.unit);
		if ( UnitIsPVPFreeForAll(self.unit) ) then
			self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
			self.pvpIcon:Show();
		elseif ( factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(self.unit) ) then
			self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
			self.pvpIcon:Show();
		else
			self.pvpIcon:Hide();
		end
	end
end

function TargetFrameMixin:CheckBattlePet()
	if ( UnitIsWildBattlePet(self.unit) or UnitIsBattlePetCompanion(self.unit) ) then
		local petType = UnitBattlePetType(self.unit);
		self.petBattleIcon:SetTexture("Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType]);
		self.petBattleIcon:Show();
	else
		self.petBattleIcon:Hide();
	end
end


function TargetFrameMixin:CheckClassification(forceNormalTexture)
	local classification = UnitClassification(self.unit);
	self.nameBackground:Show();
	self.manabar.pauseUpdates = false;
	self.manabar:Show();
	self.manabar:UpdateTextString();
	self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash");

	if ( forceNormalTexture ) then
		self.borderTexture:SetTexture(TARGET_FRAME_TEXTURES["normal"]);
	elseif ( classification == "minus" ) then
		self.borderTexture:SetTexture(TARGET_FRAME_TEXTURES["minus"]);
		self.nameBackground:Hide();
		self.manabar.pauseUpdates = true;
		self.manabar:Hide();
		self.manabar.TextString:Hide();
		self.manabar.LeftText:Hide();
		self.manabar.RightText:Hide();
		forceNormalTexture = true;
	elseif ( classification == "worldboss" or classification == "elite" ) then
		self.borderTexture:SetTexture(TARGET_FRAME_TEXTURES["elite"]);
	elseif ( classification == "rareelite" ) then
		self.borderTexture:SetTexture(TARGET_FRAME_TEXTURES["rareelite"]);
	elseif ( classification == "rare" ) then
		self.borderTexture:SetTexture(TARGET_FRAME_TEXTURES["rare"]);
	else
		self.borderTexture:SetTexture(TARGET_FRAME_TEXTURES["normal"]);
		forceNormalTexture = true;
	end

	if ( forceNormalTexture ) then
		self.haveElite = nil;
		if ( classification == "minus" ) then
			self.Background:SetSize(119,12);
			self.Background:SetPoint("TOPRIGHT", self, "TOPRIGHT", -89.5, -44);
		else
			self.Background:SetSize(119,25);
			self.Background:SetPoint("TOPRIGHT", self, "TOPRIGHT", -89.5, -26);
		end
		if ( self.threatIndicator ) then
			if ( classification == "minus" ) then
				self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash");
				self.threatIndicator:SetTexCoord(0, 1, 0, 1);
				self.threatIndicator:SetWidth(256);
				self.threatIndicator:SetHeight(128);
				self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0);
			else
				self.threatIndicator:SetTexCoord(0, 0.9453125, 0, 0.181640625);
				self.threatIndicator:SetWidth(242);
				self.threatIndicator:SetHeight(93);
				self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0);
			end
		end
	else
		self.haveElite = true;
		self.Background:SetSize(119,25);
		self.Background:SetPoint("TOPRIGHT", self, "TOPRIGHT", -89.5, -26);
		if ( self.threatIndicator ) then
			self.threatIndicator:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625);
			self.threatIndicator:SetWidth(242);
			self.threatIndicator:SetHeight(112);
			self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -22, 9);
		end
	end

	--[[if (self.questIcon) then
		if (UnitIsQuestBoss(self.unit)) then
			self.questIcon:Show();
		else
			self.questIcon:Hide();
		end
	end]]
end

function TargetFrameMixin:CheckDead()
	if ( (UnitHealth(self.unit) <= 0) and UnitIsConnected(self.unit) ) then
		if ( UnitIsUnconscious(self.unit) ) then
			self.unconsciousText:Show();
			self.deadText:Hide();
		else
			self.unconsciousText:Hide();
			self.deadText:Show();
		end
	else
		self.deadText:Hide();
		self.unconsciousText:Hide();
	end
end

function TargetFrameMixin:CheckDishonorableKill()
	if ( UnitIsCivilian("target") ) then
		-- Is a dishonorable kill
		TargetFrameNameBackground:SetVertexColor(1.0, 1.0, 1.0);
	end
end

function TargetFrameMixin:OnUpdate(elapsed)
	if ( self.totFrame) then
		if ( self.totFrame:IsShown() ~= UnitExists(self.totFrame.unit) ) then
			self.totFrame:Update();
		end
	end

	self.elapsed = (self.elapsed or 0) + elapsed;
	if ( self.elapsed > 0.5 ) then
		self.elapsed = 0;
		UnitFrame_UpdateThreatIndicator(self.threatIndicator, self.threatNumericIndicator, self.feedbackUnit);
	end
end

local largeBuffList = {};
local largeDebuffList = {};
local function ShouldAuraBeLarge(caster)
	if (not GetCVarBool("showDynamicBuffSize")) then
		return true;
	end

	if not caster then
		return false;
	end

	for token, value in pairs(PLAYER_UNITS) do
		if UnitIsUnit(caster, token) or UnitIsOwnerOrControllerOfUnit(token, caster) then
			return value;
		end
	end
end

function TargetFrameMixin:UpdateAuras()
	local frame, frameName;
	local frameIcon, frameCount, frameCooldown;
	local playerIsTarget = UnitIsUnit(PlayerFrame.unit, self.unit);
	local selfName = self:GetName();
	local canAssist = UnitCanAssist("player", self.unit);

	local numBuffs = 0;
	local buffIndex = 1;
	AuraUtil.ForEachAura(self.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), MAX_TARGET_BUFFS, function(...)
		local buffName, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _ , spellId, _, _, casterIsPlayer, nameplateShowAll = ...;
		if (buffName) then
			frameName = selfName.."Buff"..(buffIndex);
			frame = _G[frameName];
			if ( not frame ) then
				if ( not icon ) then
					return false;
				else
					frame = CreateFrame("Button", frameName, self, "TargetBuffFrameTemplate");
					frame.unit = self.unit;
				end
			end
			if ( icon and ( not self.maxBuffs or buffIndex <= self.maxBuffs ) ) then
				frame:SetID(buffIndex);

				-- set the icon
				frameIcon = _G[frameName.."Icon"];
				frameIcon:SetTexture(icon);

				-- set the count
				frameCount = _G[frameName.."Count"];
				if ( count > 1 and self.showAuraCount ) then
					frameCount:SetText(count);
					frameCount:Show();
				else
					frameCount:Hide();
				end

				-- Handle cooldowns
				frameCooldown = _G[frameName.."Cooldown"];
				CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);

				-- Show stealable frame if the target is not the current player and the buff is stealable.
				local frameStealable = _G[frameName.."Stealable"];
				if ( not playerIsTarget and canStealOrPurge ) then
					frameStealable:Show();
				else
					frameStealable:Hide();
				end

				-- set the buff to be big if the buff is cast by the player or his pet
				buffIndex = buffIndex + 1;
				numBuffs = numBuffs + 1;
				largeBuffList[numBuffs] = ShouldAuraBeLarge(caster);

				frame:ClearAllPoints();
				frame:Show();
			else
				frame:Hide();
			end
		else
			return false;
		end

		return numBuffs >= MAX_TARGET_BUFFS;
	end);

	for i = buffIndex, MAX_TARGET_BUFFS do
		local buffFrame = _G[selfName.."Buff"..i];
		if ( buffFrame ) then
			buffFrame:Hide();
		else
			break;
		end
	end

	local color;
	local frameBorder;

	local numDebuffs = 0;
	local debuffIndex = 1;
	local maxDebuffs = self.maxDebuffs or MAX_TARGET_DEBUFFS;

	AuraUtil.ForEachAura(self.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful, AuraUtil.AuraFilters.IncludeNameplateOnly), maxDebuffs, function(...)
		local debuffName, icon, count, debuffType, duration, expirationTime, caster, _, _, _, _, _, casterIsPlayer, nameplateShowAll = ...;
		if ( debuffName ) then
			if ( self:ShouldShowDebuffs(self.unit, caster, nameplateShowAll, casterIsPlayer) ) then
				frameName = selfName.."Debuff"..debuffIndex;
				frame = _G[frameName];
				if ( icon ) then
					if ( not frame ) then
						frame = CreateFrame("Button", frameName, self, "TargetDebuffFrameTemplate");
						frame.unit = self.unit;
					end
					frame:SetID(debuffIndex);

					-- set the icon
					frameIcon = _G[frameName.."Icon"];
					frameIcon:SetTexture(icon);

					-- set the count
					frameCount = _G[frameName.."Count"];
					if ( count > 1 and self.showAuraCount ) then
						frameCount:SetText(count);
						frameCount:Show();
					else
						frameCount:Hide();
					end

					-- Handle cooldowns
					frameCooldown = _G[frameName.."Cooldown"];
					CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);

					-- set debuff type color
					if ( debuffType ) then
						color = DebuffTypeColor[debuffType];
					else
						color = DebuffTypeColor["none"];
					end
					frameBorder = _G[frameName.."Border"];
					frameBorder:SetVertexColor(color.r, color.g, color.b);

					-- set the debuff to be big if the buff is cast by the player or his pet
					debuffIndex = debuffIndex + 1;
					numDebuffs = numDebuffs + 1;
					largeDebuffList[numDebuffs] = ShouldAuraBeLarge(caster);

					frame:ClearAllPoints();
					frame:Show();
				end
			end
		else
			return false;
		end

		return numDebuffs >= maxDebuffs;
	end);

	for i = debuffIndex, MAX_TARGET_DEBUFFS do
		local debuffFrame = _G[selfName.."Debuff"..i];
		if ( debuffFrame ) then
			debuffFrame:Hide();
		else
			break;
		end
	end

	self.auraRows = 0;

	local mirrorAurasVertically = false;
	if ( self.buffsOnTop ) then
		mirrorAurasVertically = true;
	end
	local haveTargetofTarget;
	if ( self.totFrame ) then
		haveTargetofTarget = self.totFrame:IsShown();
	end
	self.spellbarAnchor = nil;
	local maxRowWidth;
	-- update buff positions
	maxRowWidth = ( haveTargetofTarget and self.TOT_AURA_ROW_WIDTH ) or AURA_ROW_WIDTH;
	self:UpdateAuraPositions(selfName.."Buff", numBuffs, numDebuffs, largeBuffList, self.UpdateBuffAnchor, maxRowWidth, 3, mirrorAurasVertically);
	-- update debuff positions
	maxRowWidth = ( haveTargetofTarget and self.auraRows < NUM_TOT_AURA_ROWS and self.TOT_AURA_ROW_WIDTH ) or AURA_ROW_WIDTH;
	self:UpdateAuraPositions(selfName.."Debuff", numDebuffs, numBuffs, largeDebuffList, self.UpdateDebuffAnchor, maxRowWidth, 3, mirrorAurasVertically);
	-- update the spell bar position
	if self.spellbar ~= nil then
		self.spellbar:AdjustPosition();
	end
end

--
--		Hide debuffs on mobs cast by players other than me and aren't flagged to show to entire party on nameplates.
--
function TargetFrameMixin:ShouldShowDebuffs(unit, caster, nameplateShowAll, casterIsAPlayer)
	if (GetCVarBool("noBuffDebuffFilterOnTarget")) then
		return true;
	end

	if (nameplateShowAll) then
		return true;
	end

	if (caster and (UnitIsUnit("player", caster) or UnitIsOwnerOrControllerOfUnit("player", caster))) then
		return true;
	end

	if (UnitIsUnit("player", unit)) then
		return true;
	end

	local targetIsFriendly = not UnitCanAttack("player", unit);
	local targetIsAPlayer =  UnitIsPlayer(unit);
	local targetIsAPlayerPet = UnitIsOtherPlayersPet(unit);

	if (not targetIsAPlayer and not targetIsAPlayerPet and not targetIsFriendly and casterIsAPlayer) then
		return false;
	end

	return true;
end

function TargetFrameMixin:UpdateAuraPositions(auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
	-- a lot of this complexity is in place to allow the auras to wrap around the target of target frame if it's shown

	-- Position auras
	local size;
	local offsetY = AURA_OFFSET_Y;
	-- current width of a row, increases as auras are added and resets when a new aura's width exceeds the max row width
	local rowWidth = 0;
	local firstBuffOnRow = 1;
	for i=1, numAuras do
		-- update size and offset info based on large aura status
		if ( largeAuraList[i] ) then
			size = LARGE_AURA_SIZE;
			offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y;
		else
			size = SMALL_AURA_SIZE;
		end

		-- anchor the current aura
		if ( i == 1 ) then
			rowWidth = size;
			self.auraRows = self.auraRows + 1;
		else
			rowWidth = rowWidth + size + offsetX;
		end
		if ( rowWidth > maxRowWidth ) then
			-- this aura would cause the current row to exceed the max row width, so make this aura
			-- the start of a new row instead
			updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY, mirrorAurasVertically);

			rowWidth = size;
			self.auraRows = self.auraRows + 1;
			firstBuffOnRow = i;
			offsetY = AURA_OFFSET_Y;

			if ( self.auraRows > NUM_TOT_AURA_ROWS ) then
				-- if we exceed the number of tot rows, then reset the max row width
				-- note: don't have to check if we have tot because AURA_ROW_WIDTH is the default anyway
				maxRowWidth = AURA_ROW_WIDTH;
			end
		else
			updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY, mirrorAurasVertically);
		end
	end
end

function TargetFrameMixin:UpdateBuffAnchor(buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
	--For mirroring vertically
	local point, relativePoint;
	local startY, auraOffsetY;
	if ( mirrorVertically ) then
		point = "BOTTOM";
		relativePoint = "TOP";
		startY = AURA_START_Y_MIRROR;
		if ( self.threatNumericIndicator:IsShown() ) then
			startY = startY + self.threatNumericIndicator:GetHeight();
		end
		offsetY = - offsetY;
		auraOffsetY = -AURA_OFFSET_Y;
	else
		point = "TOP";
		relativePoint="BOTTOM";
		startY = AURA_START_Y;
		auraOffsetY = AURA_OFFSET_Y;
	end

	local buff = _G[buffName..index];
	if ( index == 1 ) then
		if ( UnitIsFriend("player", self.unit) or numDebuffs == 0 ) then
			-- unit is friendly or there are no debuffs...buffs start on top
			buff:SetPoint(point.."LEFT", self, relativePoint.."LEFT", AURA_START_X, startY);
		else
			-- unit is not friendly and we have debuffs...buffs start on bottom
			buff:SetPoint(point.."LEFT", self.debuffs, relativePoint.."LEFT", 0, -offsetY);
		end
		self.buffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0);
		self.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		self.spellbarAnchor = buff;
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint(point.."LEFT", _G[buffName..anchorIndex], relativePoint.."LEFT", 0, -offsetY);
		self.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		self.spellbarAnchor = buff;
	else
		-- anchor index is the previous index
		buff:SetPoint(point.."LEFT", _G[buffName..anchorIndex], point.."RIGHT", offsetX, 0);
	end

	-- Resize
	buff:SetWidth(size);
	buff:SetHeight(size);
end

function TargetFrameMixin:UpdateDebuffAnchor(debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
	local buff = _G[debuffName..index];
	local isFriend = UnitIsFriend("player", self.unit);

	--For mirroring vertically
	local point, relativePoint;
	local startY, auraOffsetY;
	if ( mirrorVertically ) then
		point = "BOTTOM";
		relativePoint = "TOP";
		startY = AURA_START_Y_MIRROR;
		if ( self.threatNumericIndicator:IsShown() ) then
			startY = startY + self.threatNumericIndicator:GetHeight();
		end
		offsetY = - offsetY;
		auraOffsetY = -AURA_OFFSET_Y;
	else
		point = "TOP";
		relativePoint="BOTTOM";
		startY = AURA_START_Y;
		auraOffsetY = AURA_OFFSET_Y;
	end

	if ( index == 1 ) then
		if ( isFriend and numBuffs > 0 ) then
			-- unit is friendly and there are buffs...debuffs start on bottom
			buff:SetPoint(point.."LEFT", self.buffs, relativePoint.."LEFT", 0, -offsetY);
		else
			-- unit is not friendly or there are no buffs...debuffs start on top
			buff:SetPoint(point.."LEFT", self, relativePoint.."LEFT", AURA_START_X, startY);
		end
		self.debuffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0);
		self.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
			self.spellbarAnchor = buff;
		end
	elseif ( anchorIndex ~= (index-1) ) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint(point.."LEFT", _G[debuffName..anchorIndex], relativePoint.."LEFT", 0, -offsetY);
		self.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
			self.spellbarAnchor = buff;
		end
	else
		-- anchor index is the previous index
		buff:SetPoint(point.."LEFT", _G[debuffName..(index-1)], point.."RIGHT", offsetX, 0);
	end

	-- Resize
	buff:SetWidth(size);
	buff:SetHeight(size);
	local debuffFrame =_G[debuffName..index.."Border"];
	debuffFrame:SetWidth(size+2);
	debuffFrame:SetHeight(size+2);
end

function TargetFrameMixin:HealthUpdate(elapsed, unit)
	if ( UnitIsPlayer(unit) ) then
		if ( (self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2) ) then
			local alpha = 255;
			local counter = self.statusCounter + elapsed;
			local sign    = self.statusSign;

			if ( counter > 0.5 ) then
				sign = -sign;
				self.statusSign = sign;
			end
			counter = mod(counter, 0.5);
			self.statusCounter = counter;

			if ( sign == 1 ) then
				alpha = (127  + (counter * 256)) / 255;
			else
				alpha = (255 - (counter * 256)) / 255;
			end
			if ( self.portrait ) then
				self.portrait:SetAlpha(alpha);
			end
		end
	end
end

function TargetHealthCheck (self)
	if ( UnitIsPlayer(self.unit) ) then
		local unitHPMin, unitHPMax, unitCurrHP;
		local parent = self:GetParent();
		unitHPMin, unitHPMax = self:GetMinMaxValues();
		unitCurrHP = self:GetValue();
		parent.unitHPPercent = unitCurrHP / unitHPMax;
		if ( parent.portrait ) then
			if ( UnitIsDead(self.unit) ) then
				parent.portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
			elseif ( UnitIsGhost(self.unit) ) then
				parent.portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
			elseif ( (parent.unitHPPercent > 0) and (parent.unitHPPercent <= 0.2) ) then
				parent.portrait:SetVertexColor(1.0, 0.0, 0.0);
			else
				parent.portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
			end
		end
	end
end

function TargetFrame_OpenMenu()
	local which;
	local name;
	if ( UnitIsUnit("target", "player") ) then
		which = "SELF";
	elseif ( UnitIsUnit("target", "vehicle") ) then
		-- NOTE: vehicle check must come before pet check for accuracy's sake because
		-- a vehicle may also be considered your pet
		which = "VEHICLE";
	elseif ( UnitIsUnit("target", "pet") ) then
		which = "PET";
	elseif ( UnitIsOtherPlayersPet("target") ) then
		which = "OTHERPET";
	elseif ( UnitIsPlayer("target") ) then
		if ( UnitInRaid("target") ) then
			which = "RAID_PLAYER";
		elseif ( UnitInParty("target") ) then
			which = "PARTY";
		elseif ( UnitCanCooperate("player", "target") ) then
			which = "PLAYER";
		else
			which = "ENEMY_PLAYER"
		end
	else
		which = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if ( which ) then
		local contextData = {
			fromTargetFrame = true;
			unit = "target",
			name = name,
		};
		UnitPopup_OpenMenu(which, contextData);
	end
end

-- Raid target icon function
RAID_TARGET_ICON_DIMENSION = 64;
RAID_TARGET_TEXTURE_DIMENSION = 256;
RAID_TARGET_TEXTURE_COLUMNS = 4;
RAID_TARGET_TEXTURE_ROWS = 4;
function TargetFrameMixin:UpdateRaidTargetIcon()
	local index = GetRaidTargetIndex(self.unit);
	if ( index ) then
		SetRaidTargetIconTexture(self.raidTargetIcon, index);
		self.raidTargetIcon:Show();
	else
		self.raidTargetIcon:Hide();
	end
end

function SetRaidTargetIconTexture (texture, raidTargetIconIndex)
	raidTargetIconIndex = raidTargetIconIndex - 1;
	local left, right, top, bottom;
	local coordIncrement = RAID_TARGET_ICON_DIMENSION / RAID_TARGET_TEXTURE_DIMENSION;
	left = mod(raidTargetIconIndex , RAID_TARGET_TEXTURE_COLUMNS) * coordIncrement;
	right = left + coordIncrement;
	top = floor(raidTargetIconIndex / RAID_TARGET_TEXTURE_ROWS) * coordIncrement;
	bottom = top + coordIncrement;
	texture:SetTexCoord(left, right, top, bottom);
end

function SetRaidTargetIcon (unit, index)
	if ( GetRaidTargetIndex(unit) and GetRaidTargetIndex(unit) == index ) then
		SetRaidTarget(unit, 0);
	else
		SetRaidTarget(unit, index);
	end
end

function TargetFrameMixin:CreateTargetofTarget(unit)
	local thisName = self:GetName().."ToT";
	local frame = CreateFrame("BUTTON", thisName, self, "TargetofTargetFrameTemplate");
	self.totFrame = frame;
	UnitFrame_Initialize(frame, unit, _G[thisName.."TextureFrameName"], _G[thisName.."Portrait"],
						 _G[thisName.."HealthBar"], _G[thisName.."TextureFrameHealthBarText"],
						 _G[thisName.."ManaBar"], _G[thisName.."TextureFrameManaBarText"]);
	frame.healthbar:SetBarTextZeroText(DEAD);
	frame.deadText = _G[thisName.."TextureFrameDeadText"];
	frame.unconsciousText = _G[thisName.."TextureFrameUnconsciousText"];
	SecureUnitButton_OnLoad(frame, unit);
end

--
-- Target of Target Frame
--

TargetOfTargetMixin = {};

function TargetOfTargetMixin:OnShow()
	local parent = self:GetParent();
	parent:UpdateAuras();
end

function TargetOfTargetMixin:OnHide()
	local parent = self:GetParent();
	parent:UpdateAuras();
end

function TargetOfTargetMixin:Update(elapsed)
	local show;
	local parent = self:GetParent();
	if ( CVarCallbackRegistry:GetCVarValueBool("showTargetOfTarget") and UnitExists(parent.unit) and UnitExists(self.unit) and ( not UnitIsUnit(PlayerFrame.unit, parent.unit) ) and ( UnitHealth(parent.unit) > 0 ) ) then
		if ( not self:IsShown() ) then
			self:Show();
			if ( parent.spellbar ) then
				parent.haveToT = true;
				parent.spellbar:AdjustPosition();
			end
		end
		UnitFrame_Update(self);
		self:CheckDead();
		TargetofTargetHealthCheck(self);
		AuraUtil.RefreshAuras(self, self.unit, nil, nil, true, false);
	else
		if ( self:IsShown() ) then
			self:Hide();
			if ( parent.spellbar ) then
				parent.haveToT = nil;
				parent.spellbar:AdjustPosition();
			end
		end
	end
end

function TargetOfTargetMixin:CheckDead()
	if ( (UnitHealth(self.unit) <= 0) and UnitIsConnected(self.unit) ) then
		self.background:SetAlpha(0.9);
		if ( UnitIsUnconscious(self.unit) ) then
			self.unconsciousText:Show();
			self.deadText:Hide();
		else
			self.unconsciousText:Hide();
			self.deadText:Show();
		end
	else
		self.background:SetAlpha(1);
		self.deadText:Hide();
		self.unconsciousText:Hide();
	end
end

function TargetofTargetHealthCheck(self)
	if ( UnitIsPlayer(self.unit) ) then
		local unitHPMin, unitHPMax, unitCurrHP;
		unitHPMin, unitHPMax = self.healthbar:GetMinMaxValues();
		unitCurrHP = self.healthbar:GetValue();
		self.unitHPPercent = unitCurrHP / unitHPMax;
		if ( UnitIsDead(self.unit) ) then
			self.portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
		elseif ( UnitIsGhost(self.unit) ) then
			self.portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
		elseif ( (self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2) ) then
			self.portrait:SetVertexColor(1.0, 0.0, 0.0);
		else
			self.portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	else
		self.portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
	end
end

function TargetFrameMixin:CreateSpellbar(event, boss)
	local name = self:GetName().."SpellBar";
	local spellbar;
	if ( boss ) then
		spellbar = CreateFrame("STATUSBAR", name, self, "BossSpellBarTemplate");
	else
		spellbar = CreateFrame("STATUSBAR", name, self, "TargetSpellBarTemplate");
	end
	spellbar.boss = boss;
	spellbar:SetFrameLevel(_G[self:GetName().."TextureFrame"]:GetFrameLevel() - 1);
	self.spellbar = spellbar;
	self.auraRows = 0;
	spellbar:RegisterEvent("CVAR_UPDATE");
	spellbar:RegisterEvent("VARIABLES_LOADED");

	spellbar:SetUnit(self.unit, false, true);
	if ( event ) then
		spellbar.updateEvent = event;
		spellbar:RegisterEvent(event);
	end

	-- check to see if the castbar should be shown
	if ( GetCVar("showTargetCastbar") == "0") then
		spellbar.showCastbar = false;
	end
end

TargetSpellBarMixin = CreateFromMixins(CastingBarMixin);

function TargetSpellBarMixin:OnEvent(event, ...)
	local arg1 = ...

	--	Check for target specific events
	if ( (event == "VARIABLES_LOADED") or ((event == "CVAR_UPDATE") and (arg1 == "showTargetCastbar")) ) then
		if ( GetCVar("showTargetCastbar") == "0") then
			self.showCastbar = false;
		else
			self.showCastbar = true;
		end

		if ( not self.showCastbar ) then
			self:Hide();
		elseif ( self.casting or self.channeling ) then
			self:Show();
		end
		return;
	elseif ( event == self.updateEvent ) then
		-- check if the new target is casting a spell
		local nameChannel  = UnitChannelInfo(self.unit);
		local nameSpell  = UnitCastingInfo(self.unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = self.unit;
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = self.unit;
		else
			self.casting = nil;
			self.channeling = nil;
			self:SetMinMaxValues(0, 0);
			self:SetValue(0);
			self:Hide();
			return;
		end
		-- The position depends on the classification of the target
		self:AdjustPosition();
	end
	CastingBarMixin.OnEvent(self, event, arg1, select(2, ...));
end

function TargetSpellBarMixin:AdjustPosition()
	local parentFrame = self:GetParent();
	local xOffset = self.xOffset or 0;
	if ( self.boss ) then
		self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 43 + xOffset, 6 );
	elseif ( parentFrame.haveToT ) then
		if ( parentFrame.buffsOnTop or parentFrame.auraRows <= 1 ) then
			self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 43+ xOffset, -25 );
		else
			self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 22+ xOffset, -15);
		end
	elseif ( parentFrame.haveElite ) then
		if ( parentFrame.buffsOnTop or parentFrame.auraRows <= 1 ) then
			self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 43+ xOffset, -9 );
		else
			self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 22+ xOffset, -15);
		end
	else
		if ( (not parentFrame.buffsOnTop) and parentFrame.auraRows > 0 ) then
			self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 22+ xOffset, -15);
		else
			self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 43+ xOffset, 3 );
		end
	end
end

function TargetFrameMixin:ResetUserPlacedPosition()
	self:ClearAllPoints();
	self:SetUserPlaced(false);
	self:SetClampedToScreen(false);
	self:SetLocked(true);
	UIParent_UpdateTopFramePositions();
end

-- *********************************************************************************
-- Boss Frames
-- *********************************************************************************

BossTargetFrameMixin = {};

function BossTargetFrameMixin:OnLoad(unit, event)
	self.isBossFrame = true;
	self.noTextPrefix = true;
	self.showLevel = true;
	self.showThreat = true;
	self.maxBuffs = 0;
	self.maxDebuffs = 0;
	self:OnLoad(unit, BossTargetFrame_OpenMenu);
	self:RegisterEvent("UNIT_TARGETABLE_CHANGED");
	self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-UnitFrame-Boss");
	self.levelText:SetPoint("CENTER", 12, select(5, self.levelText:GetPoint(1)));
	self.raidTargetIcon:SetPoint("RIGHT", -90, 0);
	self.threatNumericIndicator:SetPoint("BOTTOM", self, "TOP", -85, -22);
	self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-UnitFrame-Boss-Flash");
	self.threatIndicator:SetTexCoord(0.0, 0.945, 0.0, 0.73125);
	self:SetHitRectInsets(0, 95, 15, 30);
	self:SetScale(0.75);
	if ( event ) then
		self:RegisterEvent(event);
	end
end

function BossTargetFrame_OpenMenu()
	local contextData = 
	{
		fromTargetFrame = true;
		unit = self.unit,
		name = name,
	};
	UnitPopup_OpenMenu("BOSS", contextData);
end

-- *********************************************************************************
-- Focus Frame
-- *********************************************************************************

FocusFrameMixin = {};

function FocusFrame_OpenMenu()
	local contextData = {
		fromFocusFrame = true;
		unit = "focus",
		name = SET_FOCUS,
	};
	UnitPopup_OpenMenu("FOCUS", contextData);
end

function FocusFrameMixin:SetSmallSize(smallSize)
	if ( smallSize and not FocusFrame.smallSize ) then
		FocusFrame.smallSize = true;
		FocusFrame.maxBuffs = 0;
		FocusFrame.maxDebuffs = 8;
		FocusFrame:SetScale(SMALL_FOCUS_SCALE);
		FocusFrameToT:SetScale(SMALL_FOCUS_UPSCALE);
		FocusFrameToT:SetPoint("BOTTOMRIGHT", -13, -17);
		FocusFrame.TOT_AURA_ROW_WIDTH = 80;	-- not as much room for auras with scaled-up ToT frame
		FocusFrame.spellbar:SetScale(SMALL_FOCUS_UPSCALE);
		FocusFrame.spellbar.xOffset = -5;
		FocusFrameTextureFrameName:SetFontObject(FocusFontSmall);
		FocusFrameHealthBar.TextString:SetFontObject(TextStatusBarTextLarge);
		FocusFrameHealthBar.TextString:SetPoint("CENTER", -50, 4);
		FocusFrameTextureFrameName:SetWidth(120);
		FocusFrame:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED");
		FocusFrame.showClassification = true;
		FocusFrame:UnregisterEvent("PLAYER_FLAGS_CHANGED");
		FocusFrame.showLeader = nil;
		FocusFrame.showPVP = nil;
		FocusFrame.pvpIcon:Hide();
		FocusFrame.leaderIcon:Hide();
		FocusFrame.showAuraCount = nil;

		FocusFrame:Update();
	elseif ( not smallSize and FocusFrame.smallSize ) then
		FocusFrame.smallSize = false;
		FocusFrame.maxBuffs = nil;
		FocusFrame.maxDebuffs = nil;
		FocusFrame:SetScale(LARGE_FOCUS_SCALE);
		FocusFrameToT:SetScale(LARGE_FOCUS_SCALE);
		FocusFrameToT:SetPoint("BOTTOMRIGHT", -35, -10);
		FocusFrame.TOT_AURA_ROW_WIDTH = TOT_AURA_ROW_WIDTH;
		FocusFrame.spellbar:SetScale(LARGE_FOCUS_SCALE);
		FocusFrame.spellbar.xOffset = nil;
		FocusFrameTextureFrameName:SetFontObject(GameFontNormalSmall);
		FocusFrameHealthBar.TextString:SetFontObject(TextStatusBarText);
		FocusFrameHealthBar.TextString:SetPoint("CENTER", -50, 3);
		FocusFrameTextureFrameName:SetWidth(100);
		FocusFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
		FocusFrame.showClassification = true;
		FocusFrame:RegisterEvent("PLAYER_FLAGS_CHANGED");
		FocusFrame.showPVP = true;
		FocusFrame.showLeader = true;
		FocusFrame.showAuraCount = true;
		FocusFrame:Update();
	end
end
