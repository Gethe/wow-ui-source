
AventuresPuckAbilityMixin = {};

function AventuresPuckAbilityMixin:OnEnter()
	GameTooltip:SetOwner(self);

	local wrap = true;
	local overrideColor = nil;
	GameTooltip_SetTitle(GameTooltip, self.abilityInfo.name, overrideColor, wrap);
	GameTooltip_AddNormalLine(GameTooltip, self.abilityInfo.description, wrap);

	GameTooltip:Show();
end

function AventuresPuckAbilityMixin:OnLeave()
	GameTooltip_Hide();
end

function AventuresPuckAbilityMixin:SetAbilityInfo(abilityInfo)
	self.abilityInfo = abilityInfo;

	self.Icon:SetTexture(abilityInfo.icon);

	self.currentCooldown = nil;
	self:RefreshCooldown();
end

function AventuresPuckAbilityMixin:GetAutoCombatSpellID()
	return self.abilityInfo and self.abilityInfo.autoCombatSpellID or nil;
end

function AventuresPuckAbilityMixin:StartCooldown()
	local cooldown = self.abilityInfo.cooldown;
	self.currentCooldown = (cooldown > 0) and cooldown or nil;
	self:RefreshCooldown();
	self.cooldownStartedThisRound = true;
end

function AventuresPuckAbilityMixin:AdvanceCooldown()
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

function AventuresPuckAbilityMixin:RefreshCooldown()
	local cooldown = self.currentCooldown or 0;
	local onCooldown = cooldown > 0;
	self.DisabledTexture:SetShown(onCooldown);
	self.CooldownText:SetShown(onCooldown);
	self.CooldownText:SetText(cooldown);
end

function AventuresPuckAbilityMixin:SetPuckDesaturation(desaturation)
	self.Icon:SetDesaturation(desaturation);
	self.Border:SetDesaturation(desaturation);
end


AventuresPuckHealthBarMixin = {};

local HealthBarBorderSize = 2;
local TotalHealthBarBorderSize = HealthBarBorderSize * 2;
function AventuresPuckHealthBarMixin:SetHealth(health)
	self.health = health;

	local healthPercent = health / self.maxHealth;
	local healthBarWidth = self.Background:GetWidth();
	self.Health:SetPoint("RIGHT", self.Background, "LEFT", healthBarWidth * healthPercent, 0);
end

function AventuresPuckHealthBarMixin:GetHealth()
	return self.health;
end

function AventuresPuckHealthBarMixin:SetMaxHealth(maxHealth)
	self.maxHealth = maxHealth;
end

function AventuresPuckHealthBarMixin:SetPuckDesaturation(desaturation)
	self.Background:SetDesaturation(desaturation);
	self.Health:SetDesaturation(desaturation);
	self.RoleIcon:SetDesaturation(desaturation);
end

function AventuresPuckHealthBarMixin:SetRole(role)
	local useAtlasSize = true;
	if role == Enum.AutoCombatantRole.Healer then
		self.RoleIcon:SetAtlas("Adventures-Healer", useAtlasSize);
	elseif role == Enum.AutoCombatantRole.Tank then
		self.RoleIcon:SetAtlas("Adventures-Tank", useAtlasSize);
	else
		self.RoleIcon:SetAtlas("Adventures-DPS", useAtlasSize);
	end
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
		self.AbilityOne:StartCooldown();
	elseif self.AbilityTwo:GetAutoCombatSpellID() == autoCombatSpellID then
		self.AbilityTwo:StartCooldown();
	end
end

function AdventuresPuckMixin:SetMaxHealth(maxHealth)
	self.HealthBar:SetMaxHealth(maxHealth);
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
end

-- Overwrite in your derived Mixin
function AdventuresPuckMixin:GetName()
	return "";
end


AdventuresFollowerPuckMixin = {};

function AdventuresFollowerPuckMixin:OnLoad()
	AdventuresPuckMixin.OnLoad(self);

	self.PuckBorder:SetAtlas("Adventurers-Followers-Frame");
end

function AdventuresFollowerPuckMixin:SetFollowerGUID(followerGUID, missionCompleteInfo)
	self.followerGUID = followerGUID;
	self.missionCompleteInfo = missionCompleteInfo;
	self:Refresh();
end

function AdventuresFollowerPuckMixin:GetFollowerGUID()
	return self.followerGUID;
end

function AdventuresFollowerPuckMixin:Refresh()
	local followerGUID = self:GetFollowerGUID();

	local info = self.missionCompleteInfo or C_Garrison.GetFollowerMissionCompleteInfo(followerGUID);
	self.name = info.name;
	self.Portrait:SetTexture(info.portraitIconID);
	self.HealthBar:SetMaxHealth(info.maxHealth);
	self.HealthBar:SetHealth(info.health);
	self.HealthBar:SetRole(info.role);

	local abilities = C_Garrison.GetFollowerAutoCombatSpells(followerGUID);
	local abilityOne = abilities[1];
	local abilityTwo = abilities[2];

	self.AbilityOne:SetShown(abilityOne ~= nil);
	if abilityOne then
		self.AbilityOne:SetAbilityInfo(abilityOne);
	end

	self.AbilityTwo:SetShown(abilityTwo ~= nil);
	if abilityTwo then
		self.AbilityTwo:SetAbilityInfo(abilityTwo);
	end
end

function AdventuresFollowerPuckMixin:GetName()
	return self.name;
end


AdventuresEnemyPuckMixin = {};

function AdventuresEnemyPuckMixin:OnLoad()
	AdventuresPuckMixin.OnLoad(self);

	self.AbilityOne:SetScale(0.7);
	self.AbilityOne:SetPoint("LEFT", -5, -5);
	self.AbilityTwo:SetScale(0.7);
	self.AbilityTwo:SetPoint("LEFT", 0, 25);
	self.HealthBar:SetScale(0.7);

	self.PuckBorder:SetAtlas("Adventures-Enemy-Frame");
end

function AdventuresEnemyPuckMixin:SetEncounter(encounter)
	self.name = encounter.name;
	self.Portrait:SetTexture(encounter.portraitFileDataID);

	self.HealthBar:SetMaxHealth(encounter.maxHealth);
	self.HealthBar:SetHealth(encounter.health);
	self.HealthBar:SetRole(encounter.role);

	local abilities = encounter.autoCombatSpells;
	local abilityOne = abilities[1];
	local abilityTwo = abilities[2];

	self.AbilityOne:SetShown(abilityOne ~= nil);
	if abilityOne then
		self.AbilityOne:SetAbilityInfo(abilityOne);
	end

	self.AbilityTwo:SetShown(abilityTwo ~= nil);
	if abilityTwo then
		self.AbilityTwo:SetAbilityInfo(abilityTwo);
	end
end

function AdventuresEnemyPuckMixin:GetName()
	return self.name;
end
