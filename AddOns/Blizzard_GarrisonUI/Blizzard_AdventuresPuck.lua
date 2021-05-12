
AdventuresPuckAbilityMixin = {};

function AdventuresPuckAbilityMixin:OnEnter()
	GameTooltip:SetOwner(self);
	AddAutoCombatSpellToTooltip(GameTooltip, self.abilityInfo);
	GameTooltip:Show();

	local autoCombatSpellID = self:GetAutoCombatSpellID();
	if autoCombatSpellID ~= nil then
		local board = self:GetBoard();
		if (board ~= nil) and not board:IsShowingActiveCombat() then
			local missionID = board:GetMainFrame():GetActiveMissionID();
			if missionID ~= nil then
				local abilityTargetInfos = C_Garrison.GetAutoMissionTargetingInfoForSpell(missionID, autoCombatSpellID, self:GetPuck():GetBoardIndex());
				local useLoop = true;
				board:TriggerTargetingReticles(abilityTargetInfos, useLoop);
			end
		end
	end
end

function AdventuresPuckAbilityMixin:OnLeave()
	GameTooltip_Hide();
	EventRegistry:TriggerEvent("CovenantMission.CancelLoopingTargetingAnimation");
end

function AdventuresPuckAbilityMixin:SetAbilityInfo(abilityInfo)
	self.abilityInfo = abilityInfo;

	self.Icon:SetTexture(abilityInfo.icon);

	self.currentCooldown = nil;
	self:RefreshCooldown();
end

function AdventuresPuckAbilityMixin:GetAutoCombatSpellID()
	return self.abilityInfo and self.abilityInfo.autoCombatSpellID or nil;
end

function AdventuresPuckAbilityMixin:StartCooldown()
	local cooldown = self.abilityInfo.cooldown;
	self.currentCooldown = (cooldown > 0) and cooldown or nil;
	self:RefreshCooldown();
	self.cooldownStartedThisRound = true;
end

function AdventuresPuckAbilityMixin:AdvanceCooldown()
	if self.cooldownStartedThisRound then
		self.cooldownStartedThisRound = false;
		return;
	end

	if self.currentCooldown then
		if self.currentCooldown <= 1 then
			self.currentCooldown = nil;
		else
			self.currentCooldown = self.currentCooldown - 1;
		end
	end

	self:RefreshCooldown();
end

function AdventuresPuckAbilityMixin:GetCurrentCooldown()
	return self.currentCooldown;
end

function AdventuresPuckAbilityMixin:RefreshCooldown()
	local cooldown = self.currentCooldown or 0;
	local onCooldown = cooldown > 0;
	self.DisabledTexture:SetShown(onCooldown);
	self.CooldownText:SetShown(onCooldown);
	self.CooldownText:SetText(cooldown);
end

function AdventuresPuckAbilityMixin:SetPuckDesaturation(desaturation)
	self.Icon:SetDesaturation(desaturation);
	self.Border:SetDesaturation(desaturation);
end

function AdventuresPuckAbilityMixin:GetPuck()
	return self:GetParent();
end

function AdventuresPuckAbilityMixin:GetBoard()
	return self:GetPuck():GetBoard();
end

AdventuresPuckMixin = {};

function AdventuresPuckMixin:OnLoad()
	local function OnDeathAnimationFinished()
		self:SetScript("OnUpdate", AdventuresPuckMixin.UpdateFade);
	end

	self.DeathAnimationFrame.DeathAnimation:SetScript("OnFinished", OnDeathAnimationFinished);
end

function AdventuresPuckMixin:Reset()
	self:SetPuckDesaturation(0);
	self.DeathAnimationFrame.DeathAnimation:Stop();
	self.DeathAnimationFrame.CrossRight:SetAlpha(0);
	self.DeathAnimationFrame.CrossLeft:SetAlpha(0);
end

local MaxFadedDesaturation = 0.7;
function AdventuresPuckMixin:UpdateFade(elapsed)
	self.fadeTime = (self.fadeTime or 0) + elapsed;

	if self.fadeTime > MaxFadedDesaturation then
		self:SetPuckDesaturation(MaxFadedDesaturation);
		self:SetScript("OnUpdate", nil);
	else
		self:SetPuckDesaturation(self.fadeTime);
	end
end

function AdventuresPuckMixin:SetHealth(health)
	local previousHealth = self.HealthBar:GetHealth();
	self.HealthBar:SetHealth(health);

	if health <= 0 and previousHealth > 0 then
		self:PlayDeathAnimation();
	end
end

function AdventuresPuckMixin:SetMaxHealth(maxHealth)
	self.HealthBar:SetMaxHealth(maxHealth);
end

function AdventuresPuckMixin:AdvanceCooldowns()
	self.AbilityOne:AdvanceCooldown();
	self.AbilityTwo:AdvanceCooldown();
end

function AdventuresPuckMixin:StartCooldown(autoCombatSpellID)
	if self.AbilityOne:GetAutoCombatSpellID() == autoCombatSpellID then
		if self.AbilityOne:GetCurrentCooldown() == nil then
			self.AbilityOne:StartCooldown();
		end
	elseif self.AbilityTwo:GetAutoCombatSpellID() == autoCombatSpellID then
		if self.AbilityTwo:GetCurrentCooldown() == nil then
			self.AbilityTwo:StartCooldown();
		end
	end
end

function AdventuresPuckMixin:GetHealth()
	return self.HealthBar:GetHealth();
end

function AdventuresPuckMixin:ShowHealthValues()
	self.HealthBar.HealthValue:Show();
end

function AdventuresPuckMixin:HideHealthValues()
	self.HealthBar.HealthValue:Hide();
end


function AdventuresPuckMixin:SetPuckDesaturation(desaturation)
	local function DesaturateRegions(...)
		for i = 1, select("#", ...) do
			local region = select(i, ...);
			region:SetDesaturation(desaturation);
		end
	end

	DesaturateRegions(self:GetRegions());

	self.DeathAnimationFrame.CrossRight:SetDesaturation(desaturation);
	self.DeathAnimationFrame.CrossLeft:SetDesaturation(desaturation);

	self.AbilityOne:SetPuckDesaturation(desaturation);
	self.AbilityTwo:SetPuckDesaturation(desaturation);
	self.HealthBar:SetPuckDesaturation(desaturation);
end

function AdventuresPuckMixin:PlayDeathAnimation()
	self.DeathAnimationFrame.DeathAnimation:Play();
	
	if self.deathSound then	
		PlaySound(self.deathSound);
	end
end

function AdventuresPuckMixin:OnEnter()
	local name = self:GetName();
	if name then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, name);

		local autoCombatSpells = self:GetAutoCombatSpells();
		if autoCombatSpells then 
			for i = 1, #autoCombatSpells do
				GameTooltip_AddBlankLineToTooltip(GameTooltip);
				AddAutoCombatSpellToTooltip(GameTooltip, autoCombatSpells[i]);
			end
		end

		local autoCombatAutoAttack = self:GetAutoCombatAutoAttack();
		if autoCombatAutoAttack ~= nil then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			AddAutoCombatSpellToTooltip(GameTooltip, autoCombatAutoAttack);
		end

		GameTooltip:Show();

		self:ShowAutoAttackTargetingReticles();
	end
	self:GetBoard():ShowHealthValues();
end

function AdventuresPuckMixin:ShowAutoAttackTargetingReticles()
	local autoCombatAutoAttack = self:GetAutoCombatAutoAttack();
	if autoCombatAutoAttack ~= nil then
		local board = self:GetBoard();
		if (board ~= nil) and not board:IsShowingActiveCombat() then
			local missionID = board:GetMainFrame():GetActiveMissionID();
			if missionID ~= nil then
				local abilityTargetInfos = C_Garrison.GetAutoMissionTargetingInfoForSpell(missionID, autoCombatAutoAttack.autoCombatSpellID, self:GetBoardIndex());
				local useLoop = true;
				board:TriggerTargetingReticles(abilityTargetInfos, useLoop);
			end
		end
	end
end

function AdventuresPuckMixin:OnLeave()
	GameTooltip_Hide();
	EventRegistry:TriggerEvent("CovenantMission.CancelLoopingTargetingAnimation");
	self:GetBoard():HideHealthValues();
end

function AdventuresPuckMixin:GetBoardIndex()
	return self.boardIndex;
end

function AdventuresPuckMixin:GetBoard()
	return self:GetParent():GetParent();
end

-- Overwrite in your derived Mixin
function AdventuresPuckMixin:GetAutoCombatSpells()
	return nil;
end

-- Overwrite in your derived Mixin
function AdventuresPuckMixin:GetAutoCombatAutoAttack()
	return nil;
end

-- Overwrite in your derived Mixin
function AdventuresPuckMixin:GetName()
	return "";
end

-- Overwrite in your derived Mixin
function AdventuresPuckMixin:ShowSupportColorationRings()
end

--Overwrite in your derived Mixin
function AdventuresPuckMixin:HideSupportColorationRings()
end


AdventuresFollowerPuckMixin = {};

function AdventuresFollowerPuckMixin:OnLoad()
	AdventuresPuckMixin.OnLoad(self);

	self.PuckBorder:SetAtlas("Adventurers-Followers-Frame");
	self.deathSound = SOUNDKIT.UI_ADVENTURES_DEATH_FRIENDLY;
end

function AdventuresFollowerPuckMixin:SetFollowerGUID(followerGUID, info)
	local function GetFollowerAutoCombatSpellsFromInfo()
		if (info.autoCombatSpells ~= nil) and (info.autoCombatAutoAttack ~= nil) then
			return info.autoCombatSpells, info.autoCombatAutoAttack;
		end

		return C_Garrison.GetFollowerAutoCombatSpells(followerGUID, info.level);
	end

	self.followerGUID = followerGUID;
	self.info = info;
	self.name = info.name;

	local puckBorderAtlas = info.isAutoTroop and "Adventurers-Followers-Frame-Troops" or "Adventurers-Followers-Frame";
	self.PuckBorder:SetAtlas(puckBorderAtlas);

	local autoCombatSpells, autoCombatAutoAttack = GetFollowerAutoCombatSpellsFromInfo();
	self.autoCombatSpells = autoCombatSpells;
	self.autoCombatAutoAttack = autoCombatAutoAttack;
	
	local abilityOne = autoCombatSpells[1];
	local abilityTwo = autoCombatSpells[2];

	self.AbilityOne:SetShown(abilityOne ~= nil);
	if abilityOne then
		self.AbilityOne:SetAbilityInfo(abilityOne);
	end

	self.AbilityTwo:SetShown(abilityTwo ~= nil);
	if abilityTwo then
		self.AbilityTwo:SetAbilityInfo(abilityTwo);
	end

	local autoCombatStats = info.autoCombatantStats and info.autoCombatantStats or C_Garrison.GetFollowerAutoCombatStats(followerGUID);
	info.autoCombatantStats = autoCombatStats;

	self.Portrait:SetTexture(info.portraitIconID);
	self.HealthBar:SetMaxHealth(info.autoCombatantStats.maxHealth);
	self.HealthBar:SetHealth(info.autoCombatantStats.currentHealth);
	self.HealthBar:SetRole(info.role);
end

function AdventuresFollowerPuckMixin:GetFollowerGUID()
	return self.followerGUID;
end

function AdventuresFollowerPuckMixin:GetAutoCombatSpells()
	return self.autoCombatSpells;
end

function AdventuresFollowerPuckMixin:GetAutoCombatAutoAttack()
	return self.autoCombatAutoAttack;
end

function AdventuresFollowerPuckMixin:GetName()
	return self.name;
end

function AdventuresFollowerPuckMixin:ShowSupportColorationRings()
	self.SupportColorationAnimator:SetPreviewTargets(self:GetSupportPreviewTypeForPuck(), {self.SupportColorationBurst, self.SupportColorationRing});
end

function AdventuresFollowerPuckMixin:HideSupportColorationRings()
	self.SupportColorationAnimator:CancelPreviewTargets();
end

function AdventuresFollowerPuckMixin:GetSupportPreviewTypeForPuck()
	local previewType = 0;
	for _, spell in ipairs(self.autoCombatSpells) do
		if bit.band(spell.previewMask, Enum.GarrAutoPreviewTargetType.Buff) == Enum.GarrAutoPreviewTargetType.Buff then
			previewType = bit.bor(previewType ,Enum.GarrAutoPreviewTargetType.Buff);
		end

		if bit.band(spell.previewMask, Enum.GarrAutoPreviewTargetType.Heal) == Enum.GarrAutoPreviewTargetType.Heal then
			previewType = bit.bor(previewType, Enum.GarrAutoPreviewTargetType.Heal);
		end
	end

	return previewType;
end

function AdventuresFollowerPuckMixin:UpdateStats()
	local followerID = self:GetFollowerGUID();

	if followerID and self.info then
		self.info.autoCombatantStats = C_Garrison.GetFollowerAutoCombatStats(followerID);

		self.HealthBar:SetMaxHealth(self.info.autoCombatantStats.maxHealth);
		self.HealthBar:SetHealth(self.info.autoCombatantStats.currentHealth);
	end
end

AdventuresEnemyPuckMixin = {};

function AdventuresEnemyPuckMixin:OnLoad()
	AdventuresPuckMixin.OnLoad(self);

	self.AbilityOne:SetScale(0.7);
	self.AbilityOne:SetPoint("LEFT", -5, -5);
	self.AbilityTwo:SetScale(0.7);
	self.AbilityTwo:SetPoint("LEFT", 0, 25);
	self.PuckShadow:SetPoint("TOPLEFT", 0, 0);
	self.PuckShadow:SetPoint("BOTTOMRIGHT", 0, 0);
	self.HealthBar:SetScale(0.7);
	self.HealthBar.HealthValue:SetScale(1/.7);
	self.HealthBar.HealthValue:SetPoint("CENTER", 10, 1);

	self.PuckBorder:SetAtlas("Adventures-Enemy-Frame");
	self.deathSound = SOUNDKIT.UI_ADVENTURES_DEATH_ENEMY;
end

function AdventuresEnemyPuckMixin:SetEncounter(encounter)
	self.name = encounter.name;

	local autoCombatSpells = encounter.autoCombatSpells;
	self.autoCombatSpells = autoCombatSpells;
	self.autoCombatAutoAttack = encounter.autoCombatAutoAttack;

	local abilityOne = autoCombatSpells[1];
	local abilityTwo = autoCombatSpells[2];

	self.AbilityOne:SetShown(abilityOne ~= nil);
	if abilityOne then
		self.AbilityOne:SetAbilityInfo(abilityOne);
	end

	self.AbilityTwo:SetShown(abilityTwo ~= nil);
	if abilityTwo then
		self.AbilityTwo:SetAbilityInfo(abilityTwo);
	end

	self.Portrait:SetTexture(encounter.portraitFileDataID);
	self.EliteOverlay:SetShown(encounter.isElite);

	self.HealthBar:SetMaxHealth(encounter.maxHealth);
	self.HealthBar:SetHealth(encounter.health);
	self.HealthBar:SetRole(encounter.role);
end

function AdventuresEnemyPuckMixin:GetAutoCombatSpells()
	return self.autoCombatSpells;
end

function AdventuresEnemyPuckMixin:GetAutoCombatAutoAttack()
	return self.autoCombatAutoAttack;
end

function AdventuresEnemyPuckMixin:GetName()
	return self.name;
end


AdventuresMissionPageFollowerPuckMixin = {}

function AdventuresMissionPageFollowerPuckMixin:OnLoad()
	AdventuresFollowerPuckMixin.OnLoad(self);

	self:RegisterForDrag("LeftButton");
end

function AdventuresMissionPageFollowerPuckMixin:OnEnter()
	local followerID = self:GetFollowerGUID();
	if followerID then
		GarrisonMissionPageFollowerFrame_OnEnter(self);
		self:ShowAutoAttackTargetingReticles();
		self:GetBoard():ShowHealthValues();
	end
end

function AdventuresMissionPageFollowerPuckMixin:OnLeave()
	GarrisonFollowerTooltip:Hide();
	EventRegistry:TriggerEvent("CovenantMission.CancelLoopingTargetingAnimation");
	self:GetBoard():HideHealthValues();
end

function AdventuresMissionPageFollowerPuckMixin:SetEmpty()
	self.name = nil;
	self.info = nil;
	self.followerGUID = nil;
	self.Portrait:Hide();
	self.PuckBorder:Hide();
	self.PuckShadow:Hide();
	self.EmptyPortrait:Hide();
	self.HealthBar:Hide();
	self.AbilityOne:Hide();
	self.AbilityTwo:Hide();
end

function AdventuresMissionPageFollowerPuckMixin:IsEmpty()
	return self.followerGUID == nil;
end

function AdventuresMissionPageFollowerPuckMixin:SetFollowerGUID(...)
	AdventuresFollowerPuckMixin.SetFollowerGUID(self, ...);

	self.Portrait:Show();
	self.PuckBorder:Show();
	self.PuckShadow:Show();
	self.EmptyPortrait:Hide();
	self.HealthBar:Show();
end

function AdventuresMissionPageFollowerPuckMixin:GetInfo()
	return self.info;
end

function AdventuresMissionPageFollowerPuckMixin:SetMainFrame(mainFrame)
	self.mainFrame = mainFrame;
end

function AdventuresMissionPageFollowerPuckMixin:GetMainFrame()
	return self.mainFrame;
end

function AdventuresMissionPageFollowerPuckMixin:OnMouseUp(button)
	local mainFrame = self:GetMainFrame();
	if mainFrame then
		mainFrame:TriggerEvent(CovenantMission.Event.OnFollowerFrameMouseUp, self, button);
	end
end

function AdventuresMissionPageFollowerPuckMixin:OnDragStart()
	local mainFrame = self:GetMainFrame();
	if mainFrame then
		mainFrame:TriggerEvent(CovenantMission.Event.OnFollowerFrameDragStart, self);
	end
end

function AdventuresMissionPageFollowerPuckMixin:OnDragStop()
	local mainFrame = self:GetMainFrame();
	if mainFrame then
		mainFrame:TriggerEvent(CovenantMission.Event.OnFollowerFrameDragStop, self);
	end
end

function AdventuresMissionPageFollowerPuckMixin:OnReceiveDrag()
	local mainFrame = self:GetMainFrame();
	if mainFrame then
		mainFrame:TriggerEvent(CovenantMission.Event.OnFollowerFrameReceiveDrag, self);
	end
end

function AdventuresMissionPageFollowerPuckMixin:SetHighlight(highlight)
	if highlight then
		self.PulseAnim:Play();
	else
		self.PulseAnim:Stop();
		self.Highlight:SetAlpha(0);
	end
end
