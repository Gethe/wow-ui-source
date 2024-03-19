MAX_COMBO_POINTS = 5;
MAX_TARGET_DEBUFFS = 16;
MAX_TARGET_BUFFS = 32;
MAX_BOSS_FRAMES = 5;

-- aura positioning constants
local AURA_START_X = 5;
local AURA_START_Y = 9;
local AURAR_MIRRORED_START_Y = -6
local AURA_OFFSET_Y = 3;
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

CVarCallbackRegistry:SetCVarCachable("showTargetOfTarget");

TargetFrameMixin = {};

function TargetFrameMixin:OnLoad(unit, menuFunc)
	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;
	self.TOT_AURA_ROW_WIDTH = TOT_AURA_ROW_WIDTH;

	-- set simple frame
	if (not self.showLevel) then
		self.TargetFrameContent.TargetFrameContentContextual.HighLevelTexture:Hide();
		self.TargetFrameContent.TargetFrameContentMain.LevelText:Hide();
	end

	-- set threat frame
	local threatFrame;
	if (self.showThreat) then
		threatFrame = self.TargetFrameContainer.Flash;
	end

	-- set portrait frame
	local portraitFrame;
	if (self.showPortrait) then
		portraitFrame = self.TargetFrameContainer.Portrait;
	end

	local targetFrameContentMain = self.TargetFrameContent.TargetFrameContentMain;
	local healthBar = targetFrameContentMain.HealthBar;
	local manaBar = targetFrameContentMain.ManaBar;
	UnitFrame_Initialize(self, unit, targetFrameContentMain.Name, self.frameType, portraitFrame,
						 healthBar,
						 healthBar.HealthBarText,
						 manaBar,
						 manaBar.ManaBarText,
						 threatFrame, "player", self.TargetFrameContent.TargetFrameContentContextual.NumericalThreat,
						 healthBar.MyHealPredictionBar,
						 healthBar.OtherHealPredictionBar,
						 healthBar.TotalAbsorbBar,
						 healthBar.OverAbsorbGlow,
						 healthBar.OverHealAbsorbGlow,
						 healthBar.HealAbsorbBar);

	self.auraPools = CreateFramePoolCollection();
	self.auraPools:CreatePool("FRAME", self, "TargetDebuffFrameTemplate");
	self.auraPools:CreatePool("FRAME", self, "TargetBuffFrameTemplate");

	local healthBarTexture = healthBar:GetStatusBarTexture();
	healthBarTexture:AddMaskTexture(healthBar.HealthBarMask);
	healthBarTexture:SetTexelSnappingBias(0);
	healthBarTexture:SetSnapToPixelGrid(false);

	local manaBarTexture = manaBar:GetStatusBarTexture();
	manaBarTexture:AddMaskTexture(manaBar.ManaBarMask);
	manaBarTexture:SetTexelSnappingBias(0);
	manaBarTexture:SetSnapToPixelGrid(false);

	self:Update();

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_HEALTH");
	if ( self.showLevel ) then
		self:RegisterEvent("UNIT_LEVEL");
	end
	self:RegisterEvent("UNIT_FACTION");
	if (self.showClassification) then
		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	end
	if (self.showLeader) then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	end
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterUnitEvent("UNIT_AURA", unit);
	self:RegisterUnitEvent("UNIT_TARGET", unit);

	local showmenu;
	if (menuFunc) then
		local dropdown = self.DropDown;
		UIDropDownMenu_SetInitializeFunction(dropdown, menuFunc);
		UIDropDownMenu_SetDisplayMode(dropdown, "MENU");

		local thisName = self:GetName();
		showmenu = function()
			ToggleDropDownMenu(1, nil, dropdown, thisName, 120, 10);
		end
	end
	SecureUnitButton_OnLoad(self, self.unit, showmenu);
end

local function ShouldShowTargetFrame(targetFrame)
	return UnitExists(targetFrame.unit) or ShowBossFrameWhenUninteractable(targetFrame.unit);
end

function TargetFrameMixin:Update()
	-- This check is here so the frame will hide when the target goes away
	-- even if some of the functions below are hooked by addons.
	if (not ShouldShowTargetFrame(self)) then
		self:Hide();
	else
		self:Show();

		-- Moved here to avoid taint from functions below
		if (self.totFrame) then
			self.totFrame:Update();
		end

		UnitFrame_Update(self);
		if (self.showLevel) then
			self:CheckLevel();
		end
		self:CheckFaction();
		if (self.showClassification) then
			self:CheckClassification();
		end
		self:CheckDead();
		if (self.showLeader) then
			self:CheckPartyLeader();
		end
		if (self.portrait) then
			self.portrait:SetAlpha(1.0);
		end
		self:CheckBattlePet();
		if (self.TargetFrameContent.TargetFrameContentContextual.PetBattleIcon) then
			self.TargetFrameContent.TargetFrameContentContextual.PetBattleIcon:SetAlpha(1.0);
		end
	end
end

function TargetFrameMixin:OnEvent(event, ...)
	UnitFrame_OnEvent(self, event, ...);

	local arg1 = ...;
	if (event == "PLAYER_ENTERING_WORLD") then
		self:Update();
	elseif (event == "PLAYER_TARGET_CHANGED" ) then
		-- Moved here to avoid taint from functions below
		self:Update();
		self:UpdateRaidTargetIcon(self);
		self:UpdateAuras();
		CloseDropDownMenus();

		if (UnitExists(self.unit) and not C_PlayerInteractionManager.IsReplacingUnit()) then
			if (UnitIsEnemy(self.unit, "player")) then
				PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT);
			elseif (UnitIsFriend("player", self.unit)) then
				PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT);
			else
				PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT);
			end
		end
	elseif (event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT") then
		for i = 1, MAX_BOSS_FRAMES do
			local bossTargetFrame = _G["Boss"..i.."TargetFrame"];
			bossTargetFrame:Update();
			bossTargetFrame:UpdateRaidTargetIcon(bossTargetFrame);
		end
		CloseDropDownMenus();
		UIParent_ManageFramePositions();
		BossTargetFrameContainer:Show();
	elseif (event == "UNIT_TARGETABLE_CHANGED" and arg1 == self.unit) then
		self:Update();
		self:UpdateRaidTargetIcon(self);
		CloseDropDownMenus();
		UIParent_ManageFramePositions();
	elseif (event == "UNIT_HEALTH") then
		if (arg1 == self.unit) then
			self:CheckDead();
		end
	elseif (event == "UNIT_LEVEL") then
		if (arg1 == self.unit) then
			self:CheckLevel();
		end
	elseif (event == "UNIT_FACTION") then
		if (arg1 == self.unit or arg1 == "player") then
			self:CheckFaction();
			if (self.showLevel) then
				self:CheckLevel();
			end
		end
	elseif (event == "UNIT_CLASSIFICATION_CHANGED") then
		if (arg1 == self.unit) then
			self:CheckClassification();
		end
	elseif (event == "UNIT_AURA") then
		if (arg1 == self.unit) then
			local unitAuraUpdateInfo = select(2, ...);
			self:UpdateAuras(unitAuraUpdateInfo);
		end
	elseif (event == "UNIT_TARGET") then
		if (self.totFrame) then
			self.totFrame:Update();
		end
	elseif (event == "PLAYER_FLAGS_CHANGED") then
		if (arg1 == self.unit) then
			self:CheckPartyLeader();
		end
	elseif (event == "GROUP_ROSTER_UPDATE") then
		if (self.unit == "focus") then
			self:Update();
			-- If this is the focus frame, clear focus if the unit no longer exists
			if (not UnitExists(self.unit)) then
				ClearFocus();
			end
		else
			if (self.totFrame) then
				self.totFrame:Update();
			end
			self:CheckFaction();
		end
	elseif (event == "RAID_TARGET_UPDATE") then
		self:UpdateRaidTargetIcon(self);
	elseif (event == "PLAYER_FOCUS_CHANGED") then
		if (UnitExists(self.unit)) then
			self:Show();
			self:Update();
			self:UpdateRaidTargetIcon(self);
			self:UpdateAuras();
		else
			self:Hide();
		end
		CloseDropDownMenus();
	end
end

function TargetFrameMixin:OnHide()
	-- "Soft" target changes should not cause this sound to play
	if (not IsTargetLoose()) then
		local forceNoDuplicates = true;
		PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT, nil, forceNoDuplicates);
	end
	CloseDropDownMenus();
end

function TargetFrameMixin:CheckPartyLeader()
	local targetFrameContentContextual = self.TargetFrameContent.TargetFrameContentContextual;
	if (UnitLeadsAnyGroup(self.unit)) then
		targetFrameContentContextual.LeaderIcon:SetShown(not HasLFGRestrictions());
		targetFrameContentContextual.GuideIcon:SetShown(HasLFGRestrictions());
	else
		targetFrameContentContextual.LeaderIcon:Hide();
		targetFrameContentContextual.GuideIcon:Hide();
	end
end

function TargetFrameMixin:CheckLevel()
	local targetEffectiveLevel = UnitEffectiveLevel(self.unit);
	local levelText = self.TargetFrameContent.TargetFrameContentMain.LevelText;
	local highLevelTexture = self.TargetFrameContent.TargetFrameContentContextual.HighLevelTexture;

	if (UnitIsCorpse(self.unit)) then
		levelText:Hide();
		highLevelTexture:Show();
	elseif (UnitIsWildBattlePet(self.unit) or UnitIsBattlePetCompanion(self.unit)) then
		local petLevel = UnitBattlePetLevel(self.unit);
		levelText:SetVertexColor(1.0, 0.82, 0.0);
		levelText:SetText(petLevel);
		levelText:Show();
		highLevelTexture:Hide();
	elseif (targetEffectiveLevel > 0) then
		-- Normal level target
		levelText:SetText(targetEffectiveLevel);
		-- Color level number
		if (UnitCanAttack("player", self.unit)) then
			local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(self.unit)
			local color = GetDifficultyColor(difficulty);
			levelText:SetVertexColor(color.r, color.g, color.b);
		else
			levelText:SetVertexColor(1.0, 0.82, 0.0);
		end

		levelText:Show();
		highLevelTexture:Hide();
	else
		-- Target is too high level to tell
		levelText:Hide();
		highLevelTexture:Show();
	end
end

function TargetFrameMixin:CheckFaction()
	if (not UnitPlayerControlled(self.unit) and UnitIsTapDenied(self.unit)) then
		self.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetVertexColor(0.5, 0.5, 0.5);
		if (self.TargetFrameContainer.Portrait) then
			self.TargetFrameContainer.Portrait:SetVertexColor(0.5, 0.5, 0.5);
		end
	else
		self.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetVertexColor(UnitSelectionColor(self.unit));
		if (self.TargetFrameContainer.Portrait) then
			self.TargetFrameContainer.Portrait:SetVertexColor(1.0, 1.0, 1.0);
		end
	end

	if (self.showPVP and C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.UnitFramePvPContextual)) then
		local factionGroup = UnitFactionGroup(self.unit);
		local targetFrameContentContextual = self.TargetFrameContent.TargetFrameContentContextual;
		if (UnitIsPVPFreeForAll(self.unit)) then
			local honorLevel = UnitHonorLevel(self.unit);
			local honorRewardInfo = C_PvP.GetHonorRewardInfo(honorLevel);
			if (honorRewardInfo) then
				targetFrameContentContextual.PrestigePortrait:SetAtlas("honorsystem-portrait-neutral", TextureKitConstants.IgnoreAtlasSize);
				targetFrameContentContextual.PrestigeBadge:SetTexture(honorRewardInfo.badgeFileDataID);
				targetFrameContentContextual.PrestigePortrait:Show();
				targetFrameContentContextual.PrestigeBadge:Show();
				targetFrameContentContextual.PvpIcon:Hide();
			else
				targetFrameContentContextual.PrestigePortrait:Hide();
				targetFrameContentContextual.PrestigeBadge:Hide();
				targetFrameContentContextual.PvpIcon:SetAtlas("UI-HUD-UnitFrame-Player-PVP-FFAIcon", TextureKitConstants.UseAtlasSize);
				targetFrameContentContextual.PvpIcon:Show();
			end
		elseif (factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(self.unit)) then
			local honorLevel = UnitHonorLevel(self.unit);
			local honorRewardInfo = C_PvP.GetHonorRewardInfo(honorLevel);
			if (honorRewardInfo) then
				targetFrameContentContextual.PrestigePortrait:SetAtlas("honorsystem-portrait-"..factionGroup, TextureKitConstants.IgnoreAtlasSize);
				targetFrameContentContextual.PrestigeBadge:SetTexture(honorRewardInfo.badgeFileDataID);
				targetFrameContentContextual.PrestigePortrait:Show();
				targetFrameContentContextual.PrestigeBadge:Show();
				targetFrameContentContextual.PvpIcon:Hide();
			else
				targetFrameContentContextual.PrestigePortrait:Hide();
				targetFrameContentContextual.PrestigeBadge:Hide();
				if (factionGroup == "Horde") then
					targetFrameContentContextual.PvpIcon:SetAtlas("UI-HUD-UnitFrame-Player-PVP-HordeIcon", TextureKitConstants.UseAtlasSize);
				elseif (factionGroup == "Alliance") then
					targetFrameContentContextual.PvpIcon:SetAtlas("UI-HUD-UnitFrame-Player-PVP-AllianceIcon", TextureKitConstants.UseAtlasSize);
				end
				targetFrameContentContextual.PvpIcon:Show();
			end
		else
			targetFrameContentContextual.PrestigePortrait:Hide();
			targetFrameContentContextual.PrestigeBadge:Hide();
			targetFrameContentContextual.PvpIcon:Hide();
		end
	end
end

function TargetFrameMixin:CheckBattlePet()
	if (UnitIsWildBattlePet(self.unit) or UnitIsBattlePetCompanion(self.unit)) then
		local petType = UnitBattlePetType(self.unit);
		self.TargetFrameContent.TargetFrameContentContextual.PetBattleIcon:SetTexture("Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType]);
		self.TargetFrameContent.TargetFrameContentContextual.PetBattleIcon:Show();
	else
		self.TargetFrameContent.TargetFrameContentContextual.PetBattleIcon:Hide();
	end
end

function TargetFrameMixin:CheckClassification()
	local classification = UnitClassification(self.unit);
	local healthBar = self.TargetFrameContent.TargetFrameContentMain.HealthBar;
	local manaBar = self.TargetFrameContent.TargetFrameContentMain.ManaBar;

	-- Base frame/health/mana pieces
	manaBar.pauseUpdates = false;
	manaBar:Show();
	TextStatusBar_UpdateTextString(manaBar);

	if (classification == "minus") then
		self.TargetFrameContainer.FrameTexture:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn", TextureKitConstants.UseAtlasSize);

		-- self.threatIndicator should just be set to self.TargetFrameContainer.Flash.  See 'threatFrame' in TargetFrameMixin:OnLoad.
		if (self.threatIndicator) then
			self.threatIndicator:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize);
		end

		healthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn-Bar-Health", TextureKitConstants.UseAtlasSize);
		healthBar:SetHeight(12);
		healthBar:SetWidth(125);
		healthBar:SetPoint("BOTTOMRIGHT", self.TargetFrameContainer, "LEFT", 148, -1);

		healthBar.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn-Bar-Health-Mask", TextureKitConstants.UseAtlasSize);
		healthBar.HealthBarMask:SetPoint("TOPLEFT", -1, 2);

		manaBar.pauseUpdates = true;
		manaBar:Hide();
		manaBar.TextString:Hide();
		manaBar.LeftText:Hide();
		manaBar.RightText:Hide();
	else
		if (classification == "rare" or classification == "rareelite") then
			self.TargetFrameContainer.FrameTexture:SetAtlas("UI-HUD-UnitFrame-Target-Rare-PortraitOn", TextureKitConstants.UseAtlasSize);
		else
			self.TargetFrameContainer.FrameTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn", TextureKitConstants.UseAtlasSize);
		end

		-- self.threatIndicator should just be set to self.TargetFrameContainer.Flash.  See 'threatFrame' in TargetFrameMixin:OnLoad.
		if (self.threatIndicator) then
			self.threatIndicator:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize);
		end

		healthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health", TextureKitConstants.UseAtlasSize);
		healthBar:SetHeight(20);
		healthBar:SetWidth(126);
		healthBar:SetPoint("BOTTOMRIGHT", self.TargetFrameContainer, "LEFT", 149, -10);

		healthBar.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Mask", TextureKitConstants.UseAtlasSize);
		healthBar.HealthBarMask:SetPoint("TOPLEFT", -1, 6);
	end

	-- Boss frame pieces (dragon frame, icons)
	local bossPortraitFrameTexture = self.TargetFrameContainer.BossPortraitFrameTexture;
	if (UnitIsBossMob(self.unit)) then
		bossPortraitFrameTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged", TextureKitConstants.UseAtlasSize);
		bossPortraitFrameTexture:SetPoint("TOPRIGHT", 8, -8);
		bossPortraitFrameTexture:Show();
	elseif (classification == "rareelite") then
		bossPortraitFrameTexture:SetAtlas("ui-hud-unitframe-target-portraiton-boss-rare-silver", TextureKitConstants.UseAtlasSize);
		bossPortraitFrameTexture:SetPoint("TOPRIGHT", -11, -8);
		bossPortraitFrameTexture:Show();
	elseif (classification == "elite") then
		bossPortraitFrameTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold", TextureKitConstants.UseAtlasSize);
		bossPortraitFrameTexture:SetPoint("TOPRIGHT", -11, -8);
		bossPortraitFrameTexture:Show();
	else
		bossPortraitFrameTexture:Hide();
	end

	local targetFrameContenContextual = self.TargetFrameContent.TargetFrameContentContextual;
	local isQuestBoss = UnitIsQuestBoss(self.unit);

	if (targetFrameContenContextual.QuestIcon) then
		targetFrameContenContextual.QuestIcon:SetShown(isQuestBoss);
	end

	-- Quest icon showing trumps rarity icon.
	if (targetFrameContenContextual.QuestIcon and isQuestBoss) then
		targetFrameContenContextual.BossIcon:Hide();
	elseif (classification == "rare" or classification == "rareelite") then
		targetFrameContenContextual.BossIcon:SetAtlas("UnitFrame-Target-PortraitOn-Boss-Rare-Star", TextureKitConstants.UseAtlasSize);
		targetFrameContenContextual.BossIcon:Show();
	else
		targetFrameContenContextual.BossIcon:Hide();
	end
end

function TargetFrameMixin:CheckDead()
	local healthBar = self.TargetFrameContent.TargetFrameContentMain.HealthBar;

	if ((UnitHealth(self.unit) <= 0) and UnitIsConnected(self.unit)) then
		if (UnitIsUnconscious(self.unit)) then
			healthBar.UnconsciousText:Show();
			healthBar.DeadText:Hide();
		else
			healthBar.UnconsciousText:Hide();
			healthBar.DeadText:Show();
		end
	else
		healthBar.DeadText:Hide();
		healthBar.UnconsciousText:Hide();
	end
end

function TargetFrameMixin:OnUpdate(elapsed)
	if (self.totFrame and self.totFrame:IsShown() ~= UnitExists(self.totFrame.unit)) then
		self.totFrame:Update();
	end

	self.elapsed = (self.elapsed or 0) + elapsed;
	if (self.elapsed > 0.5) then
		self.elapsed = 0;
		UnitFrame_UpdateThreatIndicator(self.threatIndicator, self.threatNumericIndicator, self.feedbackUnit);
	end
end

local function ShouldAuraBeLarge(caster)
	if not caster then
		return false;
	end

	for token, value in pairs(PLAYER_UNITS) do
		if UnitIsUnit(caster, token) or UnitIsOwnerOrControllerOfUnit(token, caster) then
			return value;
		end
	end
end

local AuraUpdateChangedType = EnumUtil.MakeEnum(
	"None",
	"Debuff",
	"Buff"
);

function TargetFrameMixin:ProcessAura(aura)
	if aura == nil or aura.icon == nil then
		return AuraUpdateChangedType.None;
	end

	if aura.isHelpful and not aura.isNameplateOnly and self:ShouldShowBuffs() then
		self.activeBuffs[aura.auraInstanceID] = aura;
		return AuraUpdateChangedType.Buff;
	elseif aura.isHarmful and self:ShouldShowDebuffs(self.unit, aura.sourceUnit, aura.nameplateShowAll, aura.isFromPlayerOrPlayerPet) then
		self.activeDebuffs[aura.auraInstanceID] = aura;
		return AuraUpdateChangedType.Debuff;
	end

	return AuraUpdateChangedType.None;
end

function TargetFrameMixin:ParseAllAuras()
	if self.activeDebuffs == nil then
		self.activeDebuffs = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
		self.activeBuffs = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
	else
		self.activeDebuffs:Clear();
		self.activeBuffs:Clear();
	end

	local function HandleAura(aura)
		self:ProcessAura(aura);
		return false;
	end

	local batchCount = nil;
	local usePackedAura = true;
	AuraUtil.ForEachAura(self.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), batchCount, HandleAura, usePackedAura);
	AuraUtil.ForEachAura(self.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful, AuraUtil.AuraFilters.IncludeNameplateOnly), batchCount, HandleAura, usePackedAura);
end

function TargetFrameMixin:UpdateAuras(unitAuraUpdateInfo)
	local debuffsChanged = false;
	local buffsChanged = false;

	if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or self.activeDebuffs == nil then
		self:ParseAllAuras();
		debuffsChanged = true;
		buffsChanged = true;
	else
		if unitAuraUpdateInfo.addedAuras ~= nil then
			for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
				local type = self:ProcessAura(aura);
				if type == AuraUpdateChangedType.Buff then
					buffsChanged = true;
				elseif type == AuraUpdateChangedType.Debuff then
					debuffsChanged = true;
				end
			end
		end

		if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
				local wasInDebuff = self.activeDebuffs[auraInstanceID] ~= nil;
				local wasInBuff = self.activeBuffs[auraInstanceID] ~= nil;
				if wasInDebuff or wasInBuff then
					local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID);
					self.activeDebuffs[auraInstanceID] = nil;
					self.activeBuffs[auraInstanceID] = nil;
					local type = self:ProcessAura(newAura);
					if type == AuraUpdateChangedType.Buff or wasInBuff then
						buffsChanged = true;
					end
					if type == AuraUpdateChangedType.Debuff or wasInDebuff then
						debuffsChanged = true;
					end
				end
			end
		end

		if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
				if self.activeDebuffs[auraInstanceID] ~= nil then
					self.activeDebuffs[auraInstanceID] = nil;
					debuffsChanged = true;
				elseif self.activeBuffs[auraInstanceID] ~= nil then
					self.activeBuffs[auraInstanceID] = nil;
					buffsChanged = true;
				end
			end
		end
	end

	if not (buffsChanged or debuffsChanged) then
		return;
	end

	local playerIsTarget = UnitIsUnit(PlayerFrame.unit, self.unit);
	local numBuffs = 0;
	local numDebuffs = 0;
	self.auraPools:ReleaseAll();

	local function UpdateAuraFrame(frame, aura)
		frame.unit = self.unit;
		frame.auraInstanceID = aura.auraInstanceID;

		-- set the icon
		frame.Icon:SetTexture(aura.icon);

		-- set the count
		local frameCount = frame.Count;
		if aura.applications > 1 and self.showAuraCount then
			frameCount:SetText(aura.applications);
			frameCount:Show();
		else
			frameCount:Hide();
		end

		-- Handle cooldowns
		CooldownFrame_Set(frame.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, true);

		if aura.isHarmful then
			-- set debuff type color
			local color;
			if aura.dispelName ~= nil then
				color = DebuffTypeColor[aura.dispelName];
			else
				color = DebuffTypeColor["none"];
			end
			frame.Border:SetVertexColor(color.r, color.g, color.b);
		else
			-- Show stealable frame if the target is not the current player and the buff is stealable.
			frame.Stealable:SetShown(not playerIsTarget and aura.isStealable);
		end

		frame:ClearAllPoints();
		frame:Show();
	end

	local maxBuffs = math.min(self.maxBuffs or MAX_TARGET_BUFFS, MAX_TARGET_BUFFS);
	numBuffs = math.min(maxBuffs, self.activeBuffs:Size());

	local maxDebuffs = math.min(self.maxDebuffs or MAX_TARGET_DEBUFFS, MAX_TARGET_DEBUFFS);
	numDebuffs = math.min(maxDebuffs, self.activeDebuffs:Size());

	self.auraRows = 0;
	local mirrorAurasVertically = false;
	if self.buffsOnTop then
		mirrorAurasVertically = true;
	end
	local haveTargetofTarget;
	if self.totFrame ~= nil then
		haveTargetofTarget = self.totFrame:IsShown();
	end
	self.spellbarAnchor = nil;
	local maxRowWidth;
	-- update buff positions
	maxRowWidth = (haveTargetofTarget and self.TOT_AURA_ROW_WIDTH) or AURA_ROW_WIDTH;
	self:UpdateAuraFrames(self.activeBuffs, numBuffs, numDebuffs, UpdateAuraFrame, TargetFrame_UpdateBuffAnchor, maxRowWidth, 3, mirrorAurasVertically, "TargetBuffFrameTemplate");
	-- update debuff positions
	maxRowWidth = (haveTargetofTarget and self.auraRows < NUM_TOT_AURA_ROWS and self.TOT_AURA_ROW_WIDTH) or AURA_ROW_WIDTH;
	self:UpdateAuraFrames(self.activeDebuffs, numDebuffs, numBuffs, UpdateAuraFrame, TargetFrame_UpdateDebuffAnchor, maxRowWidth, 4, mirrorAurasVertically, "TargetDebuffFrameTemplate");
	-- update the spell bar position
	if self.spellbar ~= nil then
		self.spellbar:AdjustPosition();
	end
end

function TargetFrameMixin:ShouldShowBuffs()
	return C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.TargetFrameBuffs);
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


function TargetFrame_UpdateBuffAnchor(self, buff, index, numDebuffs, anchorBuff, anchorIndex, size, offsetX, offsetY, mirrorVertically)
	--For mirroring vertically
	local point, relativePoint;
	local startY, auraOffsetY;
	if (mirrorVertically) then
		point = "BOTTOM";
		relativePoint = "TOP";
		startY = AURAR_MIRRORED_START_Y;
		if (self.threatNumericIndicator:IsShown()) then
			startY = startY + self.threatNumericIndicator:GetHeight();
		end
		offsetY = -offsetY;
		auraOffsetY = -AURA_OFFSET_Y;
	else
		point = "TOP";
		relativePoint="BOTTOM";
		startY = AURA_START_Y;
		auraOffsetY = AURA_OFFSET_Y;
	end

	buff:ClearAllPoints();
	local targetFrameContentContextual = self.TargetFrameContent.TargetFrameContentContextual;
	if (index == 1) then
		if (UnitIsFriend("player", self.unit) or numDebuffs == 0) then
			-- unit is friendly or there are no debuffs...buffs start on top
			buff:SetPoint(point.."LEFT", self.TargetFrameContainer.FrameTexture, relativePoint.."LEFT", AURA_START_X, startY);
		else
			-- unit is not friendly and we have debuffs...buffs start on bottom
			buff:SetPoint(point.."LEFT", targetFrameContentContextual.debuffs, relativePoint.."LEFT", 0, -offsetY);
		end
		targetFrameContentContextual.buffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0);
		targetFrameContentContextual.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		self.spellbarAnchor = buff;
	elseif (anchorIndex ~= (index-1)) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint(point.."LEFT", anchorBuff, relativePoint.."LEFT", 0, -offsetY);
		targetFrameContentContextual.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		self.spellbarAnchor = buff;
	else
		-- anchor index is the previous index
		buff:SetPoint(point.."LEFT", anchorBuff, point.."RIGHT", offsetX, 0);
	end

	-- Resize
	buff:SetWidth(size);
	buff:SetHeight(size);
end

function TargetFrame_UpdateDebuffAnchor(self, buff, index, numBuffs, anchorBuff, anchorIndex, size, offsetX, offsetY, mirrorVertically)
	local isFriend = UnitIsFriend("player", self.unit);

	--For mirroring vertically
	local point, relativePoint;
	local startY, auraOffsetY;
	if (mirrorVertically) then
		point = "BOTTOM";
		relativePoint = "TOP";
		startY = AURAR_MIRRORED_START_Y;
		if (self.threatNumericIndicator:IsShown()) then
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

	buff:ClearAllPoints();
	local targetFrameContentContextual = self.TargetFrameContent.TargetFrameContentContextual;
	if (index == 1) then
		if (isFriend and numBuffs > 0) then
			-- unit is friendly and there are buffs...debuffs start on bottom
			buff:SetPoint(point.."LEFT", targetFrameContentContextual.buffs, relativePoint.."LEFT", 0, -offsetY);
		else
			-- unit is not friendly or there are no buffs...debuffs start on top
			buff:SetPoint(point.."LEFT", self.TargetFrameContainer.FrameTexture, relativePoint.."LEFT", AURA_START_X, startY);
		end
		targetFrameContentContextual.debuffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0);
		targetFrameContentContextual.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
			self.spellbarAnchor = buff;
		end
	elseif (anchorIndex ~= (index-1)) then
		-- anchor index is not the previous index...must be a new row
		buff:SetPoint(point.."LEFT", anchorBuff, relativePoint.."LEFT", 0, -offsetY);
		targetFrameContentContextual.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
		if (( isFriend ) or ( not isFriend and numBuffs == 0)) then
			self.spellbarAnchor = buff;
		end
	else
		-- anchor index is the previous index
		buff:SetPoint(point.."LEFT", anchorBuff, point.."RIGHT", offsetX, 0);
	end

	-- Resize
	buff:SetWidth(size);
	buff:SetHeight(size);
	local buffBorder = buff.Border;
	buffBorder:SetWidth(size+2);
	buffBorder:SetHeight(size+2);
end

function TargetFrameMixin:UpdateAuraFrames(auraList, numAuras, numOppositeAuras, setupFunc, anchorFunc, maxRowWidth, offsetX, mirrorAurasVertically, template)
	-- a lot of this complexity is in place to allow the auras to wrap around the target of target frame if it's shown

	-- Position auras
	local size;
	local offsetY = AURA_OFFSET_Y;
	-- current width of a row, increases as auras are added and resets when a new aura's width exceeds the max row width
	local rowWidth = 0;
	local i = 0;
	local firstIndexOnRow = 1;
	local firstBuffOnRow;
	local lastBuff;
	auraList:Iterate(function(auraInstanceID, aura)
		i = i + 1;
		if i > numAuras then
			return true;
		end
		local pool = self.auraPools:GetPool(template);
		local frame = pool:Acquire();
		setupFunc(frame, aura);

		-- update size and offset info based on large aura status
		if ShouldAuraBeLarge(aura.sourceUnit) then
			size = LARGE_AURA_SIZE;
			offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y;
		else
			size = SMALL_AURA_SIZE;
		end

		-- anchor the current aura
		if i == 1 then
			rowWidth = size;
			self.auraRows = self.auraRows + 1;
			firstBuffOnRow = frame;
		else
			rowWidth = rowWidth + size + offsetX;
		end
		if rowWidth > maxRowWidth then
			-- this aura would cause the current row to exceed the max row width, so make this aura
			-- the start of a new row instead
			anchorFunc(self, frame, i, numOppositeAuras, firstBuffOnRow, firstIndexOnRow, size, offsetX, offsetY, mirrorAurasVertically);

			rowWidth = size;
			self.auraRows = self.auraRows + 1;
			firstIndexOnRow = i;
			firstBuffOnRow = frame;
			offsetY = AURA_OFFSET_Y;

			if ( self.auraRows > NUM_TOT_AURA_ROWS ) then
				-- if we exceed the number of tot rows, then reset the max row width
				-- note: don't have to check if we have tot because AURA_ROW_WIDTH is the default anyway
				maxRowWidth = AURA_ROW_WIDTH;
			end
		else
			anchorFunc(self, frame, i, numOppositeAuras, lastBuff, i - 1, size, offsetX, offsetY, mirrorAurasVertically);
		end

		lastBuff = frame;
		return false;
	end);
end

function TargetFrameMixin:HealthUpdate(elapsed, unit)
	if (UnitIsPlayer(unit)) then
		if ((self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2)) then
			local alpha = 255;
			local counter = self.statusCounter + elapsed;
			local sign    = self.statusSign;

			if (counter > 0.5) then
				sign = -sign;
				self.statusSign = sign;
			end
			counter = mod(counter, 0.5);
			self.statusCounter = counter;

			if (sign == 1) then
				alpha = (127  + (counter * 256)) / 255;
			else
				alpha = (255 - (counter * 256)) / 255;
			end
			if (self.TargetFrameContainer.Portrait) then
				self.TargetFrameContainer.Portrait:SetAlpha(alpha);
			end
		end
	end
end

function TargetFrameDropDown_Initialize(self)
	local menu;
	local name;
	local id = nil;
	if (UnitIsUnit("target", "player")) then
		menu = "SELF";
	elseif (UnitIsUnit("target", "vehicle")) then
		-- NOTE: vehicle check must come before pet check for accuracy's sake because
		-- a vehicle may also be considered your pet
		menu = "VEHICLE";
	elseif (UnitIsUnit("target", "pet")) then
		menu = "PET";
	elseif (UnitIsOtherPlayersBattlePet("target")) then
		menu = "OTHERBATTLEPET";
	elseif (UnitIsBattlePet("target")) then
		menu = "BATTLEPET";
	elseif (UnitIsOtherPlayersPet("target")) then
		menu = "OTHERPET";
	elseif (UnitIsPlayer("target")) then
		id = UnitInRaid("target");
		if (id) then
			menu = "RAID_PLAYER";
		elseif (UnitInParty("target")) then
			menu = "PARTY";
		else
			if (not UnitIsMercenary("player")) then
				if (UnitCanCooperate("player", "target")) then
					menu = "PLAYER";
				else
					menu = "ENEMY_PLAYER"
				end
			else
				if (UnitCanAttack("player", "target")) then
					menu = "ENEMY_PLAYER"
				else
					menu = "PLAYER";
				end
			end
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if (menu) then
		UnitPopup_ShowMenu(self, menu, "target", name, id);
	end
end

-- Raid target icon function
RAID_TARGET_ICON_DIMENSION = 64;
RAID_TARGET_TEXTURE_DIMENSION = 256;
RAID_TARGET_TEXTURE_COLUMNS = 4;
RAID_TARGET_TEXTURE_ROWS = 4;
function TargetFrameMixin:UpdateRaidTargetIcon()
	local index = GetRaidTargetIndex(self.unit);
	if (index) then
		SetRaidTargetIconTexture(self.TargetFrameContent.TargetFrameContentContextual.RaidTargetIcon, index);
		self.TargetFrameContent.TargetFrameContentContextual.RaidTargetIcon:Show();
	else
		self.TargetFrameContent.TargetFrameContentContextual.RaidTargetIcon:Hide();
	end
end

function SetRaidTargetIconTexture(texture, raidTargetIconIndex)
	raidTargetIconIndex = raidTargetIconIndex - 1;
	local left, right, top, bottom;
	local coordIncrement = RAID_TARGET_ICON_DIMENSION / RAID_TARGET_TEXTURE_DIMENSION;
	left = mod(raidTargetIconIndex , RAID_TARGET_TEXTURE_COLUMNS) * coordIncrement;
	right = left + coordIncrement;
	top = floor(raidTargetIconIndex / RAID_TARGET_TEXTURE_ROWS) * coordIncrement;
	bottom = top + coordIncrement;
	texture:SetTexCoord(left, right, top, bottom);
end

function SetRaidTargetIcon(unit, index)
	if (GetRaidTargetIndex(unit) and GetRaidTargetIndex(unit) == index) then
		SetRaidTarget(unit, 0);
	else
		SetRaidTarget(unit, index);
	end
end

function TargetFrameMixin:CreateSpellbar(event, boss)
	local name = self:GetName().."SpellBar";
	local spellbar;
	if (boss) then
		spellbar = CreateFrame("STATUSBAR", name, self, "BossSpellBarTemplate");
	else
		spellbar = CreateFrame("STATUSBAR", name, self, "TargetSpellBarTemplate");
	end
	spellbar.boss = boss;
	spellbar:SetFrameLevel(self:GetFrameLevel() - 1);
	self.spellbar = spellbar;
	self.auraRows = 0;
	spellbar:RegisterEvent("CVAR_UPDATE");
	spellbar:RegisterEvent("VARIABLES_LOADED");

	spellbar:SetUnit(self.unit, false, true);
	if (event) then
		spellbar.updateEvent = event;
		spellbar:RegisterEvent(event);
	end

	-- check to see if the castbar should be shown
	if (GetCVar("showTargetCastbar") == "0") then
		spellbar.showCastbar = false;
	end
end

function TargetFrameMixin:CreateTargetofTarget(unit)
	local thisName = self:GetName().."ToT";
	local frame = CreateFrame("BUTTON", thisName, self, "TargetofTargetFrameTemplate");
	frame:SetFrameLevel(self:GetFrameLevel() + 5);
	self.totFrame = frame;
	UnitFrame_Initialize(frame, unit, frame.Name, frame.frameType, frame.Portrait,
						 frame.HealthBar, nil, frame.ManaBar, nil);
	SetTextStatusBarTextZeroText(frame.HealthBar, DEAD);

	frame.HealthBar:GetStatusBarTexture():AddMaskTexture(frame.HealthBar.HealthBarMask);

	frame.ManaBar:GetStatusBarTexture():AddMaskTexture(frame.ManaBar.ManaBarMask);

	SecureUnitButton_OnLoad(frame, unit);
end

function TargetHealthCheck(self)
	if (UnitIsPlayer(self.unit)) then
		local _, unitHPMax = self:GetMinMaxValues();
		local unitCurrHP = self:GetValue();
		self.unitHPPercent = unitCurrHP / unitHPMax;
		if (self.Portrait) then
			if (UnitIsDead(self.unit)) then
				self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
			elseif (UnitIsGhost(self.unit)) then
				self.Portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
			elseif ((self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2)) then
				self.Portrait:SetVertexColor(1.0, 0.0, 0.0);
			else
				self.Portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
			end
		end
	end
end

TargetFrameStatusBarMixin = {};

function TargetFrameStatusBarMixin:OnLoad()
	TextStatusBar_Initialize(self);
	self.textLockable = 1;
	self.lockColor = true;
	self.cvar = "statusText";
	self.cvarLabel = "STATUS_TEXT_TARGET";
	self.zeroText = "";
end

TargetFrameHealthBarMixin = CreateFromMixins(TargetFrameStatusBarMixin);

function TargetFrameHealthBarMixin:OnValueChanged(value)
	UnitFrameHealthBar_OnValueChanged(self, value);
	TargetHealthCheck(self);
end

function TargetFrameHealthBarMixin:OnSizeChanged()
	UnitFrameHealPredictionBars_UpdateSize(self:GetParent());
end

TargetSpellBarMixin = CreateFromMixins(CastingBarMixin);

function TargetSpellBarMixin:OnEvent(event, ...)
	local arg1 = ...

	--	Check for target specific events
	if ((event == "VARIABLES_LOADED") or ((event == "CVAR_UPDATE") and (arg1 == "showTargetCastbar"))) then
		if (GetCVar("showTargetCastbar") == "0") then
			self.showCastbar = false;
		else
			self.showCastbar = true;
		end

		if (not self.showCastbar) then
			self:Hide();
		elseif (self.casting or self.channeling) then
			self:Show();
		end
		return;
	elseif (event == self.updateEvent) then
		-- check if the new target is casting a spell
		local nameChannel  = UnitChannelInfo(self.unit);
		local nameSpell  = UnitCastingInfo(self.unit);
		if (nameChannel) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = self.unit;
		elseif (nameSpell) then
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

	-- If the buffs are on the bottom of the frame, and either:
	--  We have a ToT frame and more than 2 rows of buffs/debuffs.
	--  We have no ToT frame and any rows of buffs/debuffs.
	local useSpellbarAnchor = (not parentFrame.buffsOnTop) and ((parentFrame.haveToT and parentFrame.auraRows > 2) or ((not parentFrame.haveToT) and parentFrame.auraRows > 0));

	local relativeKey = useSpellbarAnchor and parentFrame.spellbarAnchor or parentFrame;
	local pointX = useSpellbarAnchor and 18 or  (parentFrame.smallSize and 38 or 43);
	local pointY = useSpellbarAnchor and -10 or (parentFrame.smallSize and 3 or 5);

	if ((not useSpellbarAnchor) and parentFrame.haveToT) then
		pointY = parentFrame.smallSize and -48 or -46;
	end

	self:SetPoint("TOPLEFT", relativeKey, "BOTTOMLEFT", pointX, pointY);
end

BossSpellBarMixin = CreateFromMixins(TargetSpellBarMixin);

function BossSpellBarMixin:AdjustPosition()
	self:ClearAllPoints();
	if self.castBarOnSide then
		if self:GetParent().powerBarAlt:IsShown() then
			self:SetPoint("TOPRIGHT", self:GetParent(), "TOPLEFT", 45, -57);
		else
			self:SetPoint("TOPRIGHT", self:GetParent(), "TOPLEFT", 45, -34);
		end
	else
		self:SetPoint("TOPRIGHT", self:GetParent(), "BOTTOMRIGHT", -100, 17);
	end
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

function TargetOfTargetMixin:Update()
	local parent = self:GetParent();
	if (CVarCallbackRegistry:GetCVarValueBool("showTargetOfTarget") and UnitExists(parent.unit) and UnitExists(self.unit)
		and (not UnitIsUnit(PlayerFrame.unit, parent.unit)) and (UnitHealth(parent.unit) > 0)) then
		if (not self:IsShown()) then
			self:Show();
			if (parent.spellbar) then
				parent.haveToT = true;
				parent.spellbar:AdjustPosition();
			end
		end
		UnitFrame_Update(self);
		self:CheckDead();
		self:HealthCheck();
		RefreshDebuffs(self, self.unit, nil, nil, true);
	else
		if (self:IsShown()) then
			self:Hide();
			if (parent.spellbar) then
				parent.haveToT = nil;
				parent.spellbar:AdjustPosition();
			end
		end
	end
end

function TargetOfTargetMixin:CheckDead()
	if ((UnitHealth(self.unit) <= 0) and UnitIsConnected(self.unit)) then
		local unitIsUnconscious = UnitIsUnconscious(self.unit);
		self.HealthBar.UnconsciousText:SetShown(unitIsUnconscious);
		self.HealthBar.DeadText:SetShown(not unitIsUnconscious);
	else
		self.HealthBar.DeadText:Hide();
		self.HealthBar.UnconsciousText:Hide();
	end
end

function TargetOfTargetMixin:HealthCheck()
	if (UnitIsPlayer(self.unit)) then
		local _, unitHPMax = self.HealthBar:GetMinMaxValues();
		local unitCurrHP = self.HealthBar:GetValue();
		self.unitHPPercent = unitCurrHP / unitHPMax;
		if (UnitIsDead(self.unit)) then
			self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
		elseif (UnitIsGhost(self.unit)) then
			self.Portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
		elseif ((self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2)) then
			self.Portrait:SetVertexColor(1.0, 0.0, 0.0);
		else
			self.Portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	end
end

--
-- Boss Frames
--

BossTargetFrameMixin = {};

function BossTargetFrameMixin:OnLoad()
	local id = self:GetID();

	self.isBossFrame = true;
	self.showLevel = true;
	self.showThreat = true;
	self.maxBuffs = 0;
	self.maxDebuffs = 0;
	self.showPortrait = false;

	TargetFrameMixin.OnLoad(self, "boss"..id, BossTargetFrameDropDown_Initialize);
	TargetFrameMixin.CheckDead(self);

	self:UnregisterEvent("UNIT_AURA"); -- Boss frames do not display auras
	self:RegisterEvent("UNIT_TARGETABLE_CHANGED");

	-- There are several edits to the target frame that need to happen to fit the portraitless version of the boss frame.
	self.TargetFrameContainer.Portrait:Hide();
	self.TargetFrameContainer.FrameTexture:SetAtlas("UI-HUD-UnitFrame-Target-Boss-Small-PortraitOff", TextureKitConstants.UseAtlasSize);
	self.threatIndicator:SetAtlas("UI-HUD-UnitFrame-Target-Boss-Small-PortraitOff-InCombat", TextureKitConstants.UseAtlasSize);
	self.threatIndicator:SetPoint("CENTER", self.TargetFrameContainer, "CENTER", -12, 2);

	local targetFrameContentMain = self.TargetFrameContent.TargetFrameContentMain;

	local reputationBar = targetFrameContentMain.ReputationColor;
	reputationBar:SetAtlas("UI-HUD-UnitFrame-Target-Boss-Small-PortraitOff-Type", TextureKitConstants.UseAtlasSize);
	reputationBar:SetPoint("TOPRIGHT", targetFrameContentMain, "TOPRIGHT", -86, -32);

	targetFrameContentMain.LevelText:SetPoint("TOPLEFT", reputationBar, "TOPRIGHT", -83, -2);
	targetFrameContentMain.Name:SetWidth(55);
	targetFrameContentMain.Name:SetPoint("TOPLEFT", reputationBar, "TOPRIGHT", -56, -1);

	local healthBar = targetFrameContentMain.HealthBar;
	healthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Target-Boss-Small-PortraitOff-Bar-Health", TextureKitConstants.UseAtlasSize);
	healthBar:SetWidth(84);
	healthBar:SetHeight(10);
	healthBar:SetPoint("BOTTOMRIGHT", self.TargetFrameContainer, "LEFT", 145, -6);

	-- The boss frame mask is the same shape as the party frame, so we just use that.
	healthBar.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOff-Bar-Health-Mask", TextureKitConstants.UseAtlasSize);
	healthBar.HealthBarMask:SetPoint("TOPLEFT", targetFrameContentMain, "TOPLEFT", 40, -43);

	local manaBar = targetFrameContentMain.ManaBar;
	manaBar:SetWidth(84);
	manaBar:SetHeight(7);
	manaBar:SetPoint("TOPRIGHT", healthBar, "BOTTOMRIGHT", 0, -1);
	manaBar.ManaBarText:SetPoint("CENTER", 0, 0);
	manaBar.RightText:SetPoint("RIGHT", -5, 0);

	-- The boss frame mask is the same shape as the party frame, so we just use that.
	manaBar.ManaBarMask:SetAtlas("UI-HUD-UnitFrame-Party-PortraitOff-Bar-Mana-Mask", TextureKitConstants.UseAtlasSize);
	manaBar.ManaBarMask:SetPoint("TOPLEFT", targetFrameContentMain, "TOPLEFT", 40, -52);

	self.TargetFrameContent.TargetFrameContentContextual.RaidTargetIcon:SetPoint("RIGHT", -90, 0);
	self.threatNumericIndicator:SetPoint("BOTTOM", self, "TOP", -28, -33);

	self:SetHitRectInsets(0, 95, 15, 30);

	if (id == 1) then
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT");
	end

	self:CreateSpellbar("INSTANCE_ENCOUNTER_ENGAGE_UNIT", true);
	self.spellbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -105, 15);
end

function BossTargetFrameMixin:OnShow()
	BossTargetFrameContainer:UpdateSize();
end

function BossTargetFrameMixin:OnHide()
	BossTargetFrameContainer:UpdateSize();
end

function BossTargetFrameMixin:UpdateShownState()
	self:SetShown(BossTargetFrameContainer.isInEditMode or ShouldShowTargetFrame(self));
	self.spellbar:SetShown(BossTargetFrameContainer.isInEditMode or self.spellbar.casting);
end

function BossTargetFrameMixin:SetCastBarPosition(castBarOnSide)
	if (self.castBarOnSide == castBarOnSide) then
		return;
	end
	self.castBarOnSide = castBarOnSide;
	self.spellbar.castBarOnSide = castBarOnSide;
	self.spellbar:AdjustPosition();
end

function BossTargetFrameDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "BOSS", self:GetParent().unit);
end

BossTargetFrameContainerMixin = { };

function BossTargetFrameContainerMixin:UpdateSize()
	local lastShowingBossFrame;
	for index, bossFrame in ipairs(self.BossTargetFrames) do
		if (self.smallSize) then
			bossFrame.rightPadding = 30;
			bossFrame.leftPadding = self.castBarOnSide and 80 or 15;
			bossFrame.bottomPadding = self.castBarOnSide and -20 or 0;
		else
			bossFrame.rightPadding = 15;
			bossFrame.leftPadding = self.castBarOnSide and 105 or 20;
			bossFrame.bottomPadding = self.castBarOnSide and -50 or -20;
		end

		if (bossFrame:IsShown()) then
			lastShowingBossFrame = bossFrame;
		end
	end

	if (lastShowingBossFrame) then
		if (self.smallSize) then
			lastShowingBossFrame.bottomPadding = self.castBarOnSide and -15 or 10;
		else
			lastShowingBossFrame.bottomPadding = self.castBarOnSide and -20 or 10;
		end
	end

	self:Layout();
	UIParent_ManageFramePositions();
end

function BossTargetFrameContainerMixin:OnShow()
	LayoutMixin.OnShow(self);
	UIParentManagedFrameMixin.OnShow(self);
end

function BossTargetFrameContainerMixin:SetSmallSize(smallSize)
	if (smallSize == self.smallSize) then
		return;
	end
	self.smallSize = smallSize;

	local scale = self.smallSize and SMALL_FOCUS_SCALE or LARGE_FOCUS_SCALE;
	for index, bossFrame in ipairs(self.BossTargetFrames) do
		bossFrame:SetScale(scale);
	end

	self:UpdateSize();
end

function BossTargetFrameContainerMixin:SetCastBarPosition(castBarOnSide)
	if (castBarOnSide == self.castBarOnSide) then
		return;
	end
	self.castBarOnSide = castBarOnSide;

	for index, bossFrame in ipairs(self.BossTargetFrames) do
		bossFrame:SetCastBarPosition(castBarOnSide);
	end

	self:UpdateSize();
end

--
-- Focus Frame
--

local FOCUS_FRAME_LOCKED = true;

FocusFrameMixin = {};

function FocusFrameDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "FOCUS", "focus", SET_FOCUS);
end

function FocusFrameMixin:IsLocked()
	return FOCUS_FRAME_LOCKED;
end

function FocusFrameMixin:SetLock(locked)
	FOCUS_FRAME_LOCKED = locked;
end

function FocusFrameMixin:SetSmallSize(smallSize)
	local focusFrameContentMain = self.TargetFrameContent.TargetFrameContentMain;
	local focusFrameContentContextual = self.TargetFrameContent.TargetFrameContentContextual;

	self.smallSize = smallSize;

	if (self.smallSize) then
		self.maxBuffs = 0;
		self.maxDebuffs = 8;
		self.showLeader = nil;
		self.showPVP = nil;
		self.showAuraCount = nil;
		self.TOT_AURA_ROW_WIDTH = 80; -- not as much room for auras with scaled-up ToT frame

		self:SetScale(SMALL_FOCUS_SCALE);
		self.totFrame:SetScale(SMALL_FOCUS_UPSCALE);
		self.spellbar:SetScale(SMALL_FOCUS_UPSCALE);

		self.totFrame:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 20, 8);
		focusFrameContentMain.HealthBar.TextString:SetFontObject(TextStatusBarTextLarge);
		focusFrameContentContextual.NumericalThreat:SetPoint("BOTTOM", focusFrameContentMain.ReputationColor, "TOP", 0, -1);
		focusFrameContentContextual.PvpIcon:Hide();
		focusFrameContentContextual.PrestigePortrait:Hide();
		focusFrameContentContextual.PrestigeBadge:Hide();
		focusFrameContentContextual.LeaderIcon:Hide();
		focusFrameContentContextual.GuideIcon:Hide();

		self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED");
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED");
	else
		self.maxBuffs = nil;
		self.maxDebuffs = nil;
		self.showLeader = true;
		self.showPVP = true;
		self.showAuraCount = true;
		self.TOT_AURA_ROW_WIDTH = TOT_AURA_ROW_WIDTH;

		self:SetScale(LARGE_FOCUS_SCALE);
		self.totFrame:SetScale(LARGE_FOCUS_SCALE);
		self.spellbar:SetScale(LARGE_FOCUS_SCALE);

		self.totFrame:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 12, 10);
		focusFrameContentMain.HealthBar.TextString:SetFontObject(TextStatusBarText);
		focusFrameContentContextual.NumericalThreat:SetPoint("BOTTOM", focusFrameContentMain.ReputationColor, "TOP", 0, 0);

		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
		self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	end

	self:Update();
	self:UpdateAuras();
end
