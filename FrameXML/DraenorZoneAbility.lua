DraenorZoneAbilitySpellID = 161691;

function DraenorZoneAbilityFrame_OnLoad(self)
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("SPELL_UPDATE_USABLE");
	self:RegisterEvent("SPELLS_CHANGED");

	self.SpellButton.spellID = DraenorZoneAbilitySpellID;
	DraenorZoneAbilityFrame_Update(self);
end

function DraenorZoneAbilityFrame_OnEvent(self, event)
	if (event == "SPELLS_CHANGED") then
		if (not self.baseName) then
			self.baseName = GetSpellInfo(DraenorZoneAbilitySpellID);
		end
	end

	if (not self.baseName) then
		return;
	end

	self.BuffSeen = HasDraenorZoneAbility();

	if (self.BuffSeen) then
		self:Show();

		WorldStateAlwaysUpFrame:ClearAllPoints();
		WorldStateAlwaysUpFrame:SetPoint("TOP", self, "BOTTOM", -5, -15);

		DraenorZoneAbilityFrame_Update(self);
	else
		self:Hide();

		WorldStateAlwaysUpFrame:ClearAllPoints();
		WorldStateAlwaysUpFrame:SetPoint("TOP", -5, -15);
	end
end

function DraenorZoneAbilityFrame_OnShow(self)
	DraenorZoneAbilityFrame_Update(self);
end

function DraenorZoneAbilityFrame_Update(self)
	if (not self.baseName) then
		return;
	end

	local name, _, tex = GetSpellInfo(self.baseName);

	self.CurrentSpell = name;

	self.SpellButton.Icon:SetTexture(tex);

	local start, duration, enable = GetSpellCooldown(name);

	if (start) then
		CooldownFrame_SetTimer(self.SpellButton.Cooldown, start, duration, enable);
	end
		
	self.SpellButton.spellName = self.CurrentSpell;
end