ZONE_SPELL_ABILITY_TEXTURES_BASE = {
	[161676] = "Interface\\ExtraButton\\GarrZoneAbility-BarracksAlliance",
	[161332] = "Interface\\ExtraButton\\GarrZoneAbility-BarracksHorde",
	[162075] = "Interface\\ExtraButton\\GarrZoneAbility-Armory",
	[161767] = "Interface\\ExtraButton\\GarrZoneAbility-MageTower",
	[170097] = "Interface\\ExtraButton\\GarrZoneAbility-TradingPost",
	[170108] = "Interface\\ExtraButton\\GarrZoneAbility-TradingPost",
	[168487] = "Interface\\ExtraButton\\GarrZoneAbility-Inn",
	[168499] = "Interface\\ExtraButton\\GarrZoneAbility-Inn",
	[164012] = "Interface\\ExtraButton\\GarrZoneAbility-TrainingPit",
	[164050] = "Interface\\ExtraButton\\GarrZoneAbility-LumberMill",
	[165803] = "Interface\\ExtraButton\\GarrZoneAbility-Stables",
	[164222] = "Interface\\ExtraButton\\GarrZoneAbility-Stables",
	[160240] = "Interface\\ExtraButton\\GarrZoneAbility-Workshop",
	[160241] = "Interface\\ExtraButton\\GarrZoneAbility-Workshop",
};

ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK = "Interface\\ExtraButton\\GarrZoneAbility-Armory";

function ZoneAbilityFrame_OnLoad(self)
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("SPELL_UPDATE_USABLE");
	self:RegisterEvent("SPELL_UPDATE_CHARGES");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");

	ZoneAbilityFrame_Update(self);
end

function ZoneAbilityFrame_OnEvent(self, event)
	local spellID, garrisonType = GetZoneAbilitySpellInfo();
	if ((event == "SPELLS_CHANGED" or event=="UNIT_AURA")) then
		self.baseName = GetSpellInfo(spellID);
	end

	if (not self.baseName) then
		self:Hide();
		return;
	end

	self.SpellButton.spellID = spellID;
	local lastState = self.buffSeen;
	self.buffSeen = (spellID ~= 0);

	if (self.buffSeen) then
		if (not HasZoneAbilitySpellOnBar(self)) then
			if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY) and garrisonType == LE_GARRISON_TYPE_6_0 ) then
				ZoneAbilityButtonAlert:SetHeight(ZoneAbilityButtonAlert.Text:GetHeight()+42);
				ZoneAbilityButtonAlert:Show();
				SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY, true );
			end
			self:Show();
		else
			ZoneAbilityButtonAlert:Hide();
			self:Hide();
		end

		ZoneAbilityFrame_Update(self);
	else
		if (not self.CurrentTexture) then
			self.CurrentTexture = select(3, GetSpellInfo(self.baseName));
		end
		self:Hide();
	end

	if (lastState ~= self.buffSeen) then
		UIParent_ManageFramePositions();
		ActionBarController_UpdateAll(true);
	end
end

function ZoneAbilityFrame_OnShow(self)
	ZoneAbilityFrame_Update(self);
end

function ZoneAbilityFrame_OnHide(self)
	ZoneAbilityButtonAlert:Hide();
end

function ZoneAbilityFrame_Update(self)
	if (not self.baseName) then
		return;
	end
	local name, _, tex, _, _, _, spellID = GetSpellInfo(self.baseName);

	self.CurrentTexture = tex;
	self.CurrentSpell = name;

	self.SpellButton.Style:SetTexture(ZONE_SPELL_ABILITY_TEXTURES_BASE[spellID] or ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK);
	self.SpellButton.Icon:SetTexture(tex);

	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID);

	local usesCharges = false;
	if (maxCharges and maxCharges > 1) then
		self.SpellButton.Count:SetText(charges);
		usesCharges = true;
	else
		self.SpellButton.Count:SetText("");
	end

	local start, duration, enable = GetSpellCooldown(name);
	
	if (usesCharges and charges < maxCharges) then
		StartChargeCooldown(self.SpellButton, chargeStart, chargeDuration, enable);
	end
	if (start) then
		CooldownFrame_SetTimer(self.SpellButton.Cooldown, start, duration, enable);
	end

	self.SpellButton.spellName = self.CurrentSpell;
	self.SpellButton.currentSpellID = spellID;
end

function HasZoneAbilitySpellOnBar(self)
	if (not self.baseName) then
		return false;
	end

	local name = GetSpellInfo(self.baseName);
	for i = 1, ((LE_NUM_NORMAL_ACTION_PAGES + LE_NUM_BONUS_ACTION_PAGES) * LE_NUM_ACTIONS_PER_PAGE) + 1, 1 do
		local type, id = GetActionInfo(i);

		if (type == "spell" or type == "companion") then
			local actionName = GetSpellInfo(id);

			if (name == actionName) then
				return true;
			end
		end
	end

	return false;
end

function HasZoneAbility()
	local spellID, garrisonType = GetZoneAbilitySpellInfo();
	return (spellID ~= 0);
end

function GetLastZoneAbilitySpellTexture()
	return ZoneAbilityFrame.CurrentTexture;
end