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
	UnitFrame_Initialize(self, unit, targetFrameContentMain.Name, portraitFrame,
						 targetFrameContentMain.HealthBar,
						 targetFrameContentMain.HealthBar.HealthBarText,
						 targetFrameContentMain.ManaBar,
						 targetFrameContentMain.ManaBar.ManaBarText,
						 threatFrame, "player", self.TargetFrameContent.TargetFrameContentContextual.NumericalThreat,
						 targetFrameContentMain.MyHealPredictionBar,
						 targetFrameContentMain.OtherHealPredictionBar,
						 targetFrameContentMain.TotalAbsorbBar,
						 targetFrameContentMain.TotalAbsorbBarOverlay,
						 targetFrameContentMain.OverAbsorbGlow,
						 targetFrameContentMain.OverHealAbsorbGlow,
						 targetFrameContentMain.HealAbsorbBar,
						 targetFrameContentMain.HealAbsorbBarLeftShadow,
						 targetFrameContentMain.HealAbsorbBarRightShadow);

	self.auraPools = CreateFramePoolCollection();
	self.auraPools:CreatePool("FRAME", self, "TargetDebuffFrameTemplate");
	self.auraPools:CreatePool("FRAME", self, "TargetBuffFrameTemplate");

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
			TargetofTarget_Update(self.totFrame);
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
				TargetofTarget_Update(self.totFrame);
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
	PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT);
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

	if (self.showPVP) then
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


function TargetFrameMixin:CheckClassification(forceNormalTexture)
	local classification = UnitClassification(self.unit);
	local targetFrameContentMain = self.TargetFrameContent.TargetFrameContentMain;

	-- Base frame/health/mana pieces
	targetFrameContentMain.ManaBar.pauseUpdates = false;
	targetFrameContentMain.ManaBar:Show();
	TextStatusBar_UpdateTextString(targetFrameContentMain.ManaBar);

	if (forceNormalTexture) then
		self.TargetFrameContainer.FrameTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn", TextureKitConstants.UseAtlasSize);
	elseif (classification == "minus") then
		self.TargetFrameContainer.FrameTexture:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn", TextureKitConstants.UseAtlasSize);
		targetFrameContentMain.HealthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Target-MinusMob-PortraitOn-Bar-Health", TextureKitConstants.UseAtlasSize);
		targetFrameContentMain.HealthBar:SetHeight(12);
		targetFrameContentMain.HealthBar:SetWidth(125);
		targetFrameContentMain.HealthBar:SetPoint("BOTTOMRIGHT", self.TargetFrameContainer.Portrait, "LEFT", 0, -3);

		targetFrameContentMain.ManaBar.pauseUpdates = true;
		targetFrameContentMain.ManaBar:Hide();
		targetFrameContentMain.ManaBar.TextString:Hide();
		targetFrameContentMain.ManaBar.LeftText:Hide();
		targetFrameContentMain.ManaBar.RightText:Hide();
		forceNormalTexture = true;
	else
		self.TargetFrameContainer.FrameTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn", TextureKitConstants.UseAtlasSize);
		targetFrameContentMain.HealthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health", TextureKitConstants.UseAtlasSize);
		targetFrameContentMain.HealthBar:SetHeight(20);
		targetFrameContentMain.HealthBar:SetWidth(126);
		targetFrameContentMain.HealthBar:SetPoint("BOTTOMRIGHT", self.TargetFrameContainer.Portrait, "LEFT", 1, -11);
		forceNormalTexture = true;
	end

	-- Flash pieces
	-- self.threatIndicator should just be set to self.TargetFrameContainer.Flash.  See 'threatFrame' in TargetFrameMixin:OnLoad.
	self.threatIndicator:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize);
	if (forceNormalTexture) then
		self.haveElite = nil;
		if (self.threatIndicator) then
			if (classification == "minus") then
				self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash");
				self.threatIndicator:SetTexCoord(0, 1, 0, 1);
				self.threatIndicator:SetWidth(210);
				self.threatIndicator:SetHeight(105);
				self.threatIndicator:ClearAllPoints();
				self.threatIndicator:SetPoint("CENTER", self, 17, -14);
			else
				self.threatIndicator:ClearAllPoints();
				self.threatIndicator:SetPoint("CENTER", self, 0, 2);
			end
		end
	else
		self.haveElite = true;
		if (self.threatIndicator) then
			self.threatIndicator:SetPoint("CENTER", self, 0, 2);
		end
	end

	-- Boss frame pieces (dragon frame, icons)
	local bossPortraitFrameTexture = self.TargetFrameContainer.BossPortraitFrameTexture;
	if (UnitIsBossMob(self.unit)) then
		bossPortraitFrameTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged", TextureKitConstants.UseAtlasSize);
		bossPortraitFrameTexture:SetPoint("TOPRIGHT", 8, -8);
		bossPortraitFrameTexture:Show();
	elseif (classification == "elite" or classification == "rareelite") then
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
	elseif (classification == "rare") then
		targetFrameContenContextual.BossIcon:SetAtlas("UnitFrame-Target-PortraitOn-Boss-Rare-Star", TextureKitConstants.UseAtlasSize);
		targetFrameContenContextual.BossIcon:Show();
	elseif ( classification == "rareelite") then
		targetFrameContenContextual.BossIcon:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare", TextureKitConstants.UseAtlasSize);
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
		TargetofTarget_Update(self.totFrame);
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

	if aura.isHelpful and not aura.isNameplateOnly then
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
				if self.activeDebuffs[auraInstanceID] ~= nil then
					local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID);
					self.activeDebuffs[auraInstanceID] = newAura;
					debuffsChanged = true;
				elseif self.activeBuffs[auraInstanceID] ~= nil then
					local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID);
					self.activeBuffs[auraInstanceID] = newAura;
					buffsChanged = true;
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
	self:UpdateAuraFrames(self.activeBuffs, numBuffs, numDebuffs, UpdateAuraFrame, TargetFrame_UpdateBuffAnchor, maxRowWidth, 3, mirrorAurasVertically);
	-- update debuff positions
	maxRowWidth = (haveTargetofTarget and self.auraRows < NUM_TOT_AURA_ROWS and self.TOT_AURA_ROW_WIDTH) or AURA_ROW_WIDTH;
	self:UpdateAuraFrames(self.activeDebuffs, numDebuffs, numBuffs, UpdateAuraFrame, TargetFrame_UpdateDebuffAnchor, maxRowWidth, 4, mirrorAurasVertically);
	-- update the spell bar position
	if self.spellbar ~= nil then
		Target_Spellbar_AdjustPosition(self.spellbar);
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
	local debuffFrame = buff.Border;
	debuffFrame:SetWidth(size+2);
	debuffFrame:SetHeight(size+2);
end

function TargetFrameMixin:UpdateAuraFrames(auraList, numAuras, numOppositeAuras, setupFunc, anchorFunc, maxRowWidth, offsetX, mirrorAurasVertically)
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
		local template = aura.isHarmful and "TargetDebuffFrameTemplate" or "TargetBuffFrameTemplate";
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
	UnitFrame_Initialize(frame, unit, frame.Name, frame.Portrait,
						 frame.HealthBar, frame.HealthBar.HealthBarText,
						 frame.ManaBar, frame.ManaBar.ManaBarText);
	SetTextStatusBarTextZeroText(frame.HealthBar, DEAD);

	SecureUnitButton_OnLoad(frame, unit);
end

function TargetHealthCheck(self)
	if (UnitIsPlayer(self.unit)) then
		local unitHPMin, unitHPMax, unitCurrHP;
		unitHPMin, unitHPMax = self:GetMinMaxValues();
		unitCurrHP = self:GetValue();
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

function Target_Spellbar_OnEvent(self, event, ...)
	local arg1 = ...

	--	Check for target specific events
	if ((event == "VARIABLES_LOADED") or ((event == "CVAR_UPDATE") and (arg1 == "SHOW_TARGET_CASTBAR"))) then
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
		Target_Spellbar_AdjustPosition(self);
	end
	self:OnEvent(event, arg1, select(2, ...));
end

function Target_Spellbar_AdjustPosition(self)
	local parentFrame = self:GetParent();
	if (self.boss) then
		self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, 10);
	elseif (parentFrame.haveToT) then
		if (parentFrame.buffsOnTop or parentFrame.auraRows <= 1) then
			self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, -21);
		else
			self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
		end
	elseif (parentFrame.haveElite) then
		if (parentFrame.buffsOnTop or parentFrame.auraRows <= 1) then
			self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, -5);
		else
			self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
		end
	else
		if ((not parentFrame.buffsOnTop) and parentFrame.auraRows > 0) then
			self:SetPoint("TOPLEFT", parentFrame.spellbarAnchor, "BOTTOMLEFT", 20, -15);
		else
			self:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 25, 7);
		end
	end
end

--
-- Target of Target Frame
--

function TargetofTarget_OnHide(self)
	local targetParent = self:GetParent();
	targetParent:UpdateAuras();
end

function TargetofTarget_Update(self, elapsed)
	local parent = self:GetParent();
	if (CVarCallbackRegistry:GetCVarValueBool("showTargetOfTarget") and UnitExists(parent.unit) and UnitExists(self.unit) and ( not UnitIsUnit(PlayerFrame.unit, parent.unit) ) and ( UnitHealth(parent.unit) > 0 )) then
		if (not self:IsShown()) then
			self:Show();
			if (parent.spellbar) then
				parent.haveToT = true;
				Target_Spellbar_AdjustPosition(parent.spellbar);
			end
		end
		UnitFrame_Update(self);
		TargetofTarget_CheckDead(self);
		TargetofTargetHealthCheck(self);
		RefreshDebuffs(self, self.unit, nil, nil, true);
	else
		if (self:IsShown()) then
			self:Hide();
			if (parent.spellbar) then
				parent.haveToT = nil;
				Target_Spellbar_AdjustPosition(parent.spellbar);
			end
		end
	end
end

function TargetofTarget_CheckDead(self)
	if ((UnitHealth(self.unit) <= 0) and UnitIsConnected(self.unit)) then
		self.background:SetAlpha(0.9);
		if (UnitIsUnconscious(self.unit)) then
			self.HealthBar.UnconsciousText:Show();
			self.HealthBar.DeadText:Hide();
		else
			self.HealthBar.UnconsciousText:Hide();
			self.HealthBar.DeadText:Show();
		end
	else
		self.background:SetAlpha(1);
		self.HealthBar.DeadText:Hide();
		self.HealthBar.UnconsciousText:Hide();
	end
end

function TargetofTargetHealthCheck(self)
	if (UnitIsPlayer(self.unit)) then
		local unitHPMin, unitHPMax, unitCurrHP;
		unitHPMin, unitHPMax = self.HealthBar:GetMinMaxValues();
		unitCurrHP = self.HealthBar:GetValue();
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

	TargetFrameMixin.OnLoad(self, "boss"..id, BossTargetFrameDropDown_Initialize);
	TargetFrameMixin.CheckDead(self);

	self:UnregisterEvent("UNIT_AURA"); -- Boss frames do not display auras
	self:RegisterEvent("UNIT_TARGETABLE_CHANGED");

	self.TargetFrameContainer.Portrait:Hide();
	self.TargetFrameContainer.FrameTexture:SetAtlas("UI-HUD-UnitFrame-PortraitOff-Boss-Small", TextureKitConstants.UseAtlasSize);

	self.TargetFrameContent.TargetFrameContentContextual.RaidTargetIcon:SetPoint("RIGHT", -90, 0);
	self.threatNumericIndicator:SetPoint("BOTTOM", self, "TOP", -85, -22);
	self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-UnitFrame-Boss-Flash");
	self.threatIndicator:SetTexCoord(0.0, 0.945, 0.0, 0.73125);

	self:SetHitRectInsets(0, 95, 15, 30);
	self:SetScale(0.75);

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

	self.spellbar:ClearAllPoints();
	if (self.castBarOnSide) then
		self.spellbar:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, -25);
	else
		self.spellbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -105, 15);
	end
end

function BossTargetFrameDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "BOSS", self:GetParent().unit);
end

BossTargetFrameContainerMixin = { };

function BossTargetFrameContainerMixin:UpdateSize()
	local lastShowingBossFrame;
	local numShowingBossFrames = 0;
	for index, bossFrame in ipairs(self.BossTargetFrames) do
		bossFrame.rightPadding = 20;
		if (self.castBarOnSide) then
			bossFrame.bottomPadding = -30;
			if (self.smallSize) then
				bossFrame.leftPadding = 70;
			else
				bossFrame.leftPadding = 150;
			end
		else
			bossFrame.bottomPadding = 0;
			if (self.smallSize) then
				bossFrame.leftPadding = -25;
			else
				bossFrame.leftPadding = 20;
			end
		end

		if (bossFrame:IsShown()) then
			numShowingBossFrames = numShowingBossFrames + 1;
			lastShowingBossFrame = bossFrame;
		end
	end

	if (lastShowingBossFrame) then
		if (self.smallSize) then
			if (self.castBarOnSide) then
				lastShowingBossFrame.bottomPadding = -40 - (numShowingBossFrames - 1) * 20;
			else
				lastShowingBossFrame.bottomPadding = -17 - (numShowingBossFrames - 1) * 27;
			end
		else
			if (self.castBarOnSide) then
				lastShowingBossFrame.bottomPadding = -20;
			else
				lastShowingBossFrame.bottomPadding = 10;
			end
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

function FocusFrameDropDown_Initialize(self)
	UnitPopup_ShowMenu(self, "FOCUS", "focus", SET_FOCUS);
end

FOCUS_FRAME_LOCKED = true;
function FocusFrame_IsLocked()
	return FOCUS_FRAME_LOCKED;
end

function FocusFrame_SetLock(locked)
	FOCUS_FRAME_LOCKED = locked;
end

function FocusFrame_OnDragStart(self, button)
	FOCUS_FRAME_MOVING = false;
	if (not FOCUS_FRAME_LOCKED) then
		local cursorX, cursorY = GetCursorPosition();
		self:SetFrameStrata("DIALOG");
		self:StartMoving();
		FOCUS_FRAME_MOVING = true;
	end
end

function FocusFrame_OnDragStop(self)
	if (not FOCUS_FRAME_LOCKED and FOCUS_FRAME_MOVING) then
		self:StopMovingOrSizing();
		self:SetFrameStrata("BACKGROUND");
		if (self:GetBottom() < 15 + MainMenuBar:GetHeight()) then
			local anchorX = self:GetLeft();
			local anchorY = 60;
			if (self.smallSize) then
				anchorY = 90;	-- empirically determined
			end
			self:SetPoint("BOTTOMLEFT", anchorX, anchorY);
		end
		FOCUS_FRAME_MOVING = false;
	end
end

function FocusFrame_SetSmallSize(smallSize)
	local focusFrameContentMain = FocusFrame.TargetFrameContent.TargetFrameContentMain;
	local focusFrameContentContextual = FocusFrame.TargetFrameContent.TargetFrameContentContextual;

	if (smallSize) then
		FocusFrame.smallSize = true;
		FocusFrame.maxBuffs = 0;
		FocusFrame.maxDebuffs = 8;
		FocusFrame:SetScale(SMALL_FOCUS_SCALE);
		FocusFrameToT:SetScale(SMALL_FOCUS_UPSCALE);
		FocusFrameToT:SetPoint("BOTTOMRIGHT", -13, -17);
		FocusFrame.TOT_AURA_ROW_WIDTH = 80;	-- not as much room for auras with scaled-up ToT frame
		FocusFrame.spellbar:SetScale(SMALL_FOCUS_UPSCALE);
		focusFrameContentMain.Name:SetFontObject(FocusFontSmall);
		focusFrameContentMain.Name:SetWidth(90);
		focusFrameContentMain.HealthBar.TextString:SetFontObject(TextStatusBarTextLarge);
		focusFrameContentMain.HealthBar.TextString:SetPoint("CENTER", -50, 4)
		FocusFrame:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED");
		FocusFrame.showClassification = true;
		FocusFrame:UnregisterEvent("PLAYER_FLAGS_CHANGED");
		FocusFrame.showLeader = nil;
		FocusFrame.showPVP = nil;
		FocusFrame.showAuraCount = nil;
		focusFrameContentContextual.PvpIcon:Hide();
		focusFrameContentContextual.PrestigePortrait:Hide();
		focusFrameContentContextual.PrestigeBadge:Hide();
		focusFrameContentContextual.LeaderIcon:Hide();
		focusFrameContentContextual.GuideIcon:Hide();
		FocusFrame.showAuraCount = nil;
--		FocusFrame:CheckClassification(true);
		FocusFrame:Update();
	elseif (not smallSize and FocusFrame.smallSize) then
		FocusFrame.smallSize = false;
		FocusFrame.maxBuffs = nil;
		FocusFrame.maxDebuffs = nil;
		FocusFrame:SetScale(LARGE_FOCUS_SCALE);
		FocusFrameToT:SetScale(LARGE_FOCUS_SCALE);
		FocusFrameToT:SetPoint("BOTTOMRIGHT", -35, -10);
		FocusFrame.TOT_AURA_ROW_WIDTH = TOT_AURA_ROW_WIDTH;
		FocusFrame.spellbar:SetScale(LARGE_FOCUS_SCALE);
		focusFrameContentMain.Name:SetFontObject(GameFontNormalSmall);
		focusFrameContentMain.Name:SetWidth(90);
		focusFrameContentMain.HealthBar.TextString:SetFontObject(TextStatusBarText);
		focusFrameContentMain.HealthBar.TextString:SetPoint("CENTER", -50, 3)
		FocusFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
		FocusFrame.showClassification = true;
		FocusFrame:RegisterEvent("PLAYER_FLAGS_CHANGED");
		FocusFrame.showLeader = true;
		FocusFrame.showPVP = true;
		FocusFrame.showAuraCount = true;
		FocusFrame:Update();
	end

	FocusFrame:Update();
	FocusFrame:UpdateAuras();
end