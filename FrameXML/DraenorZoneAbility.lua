DraenorZoneAbilitySpellID = 161691;

DRAENOR_ZONE_SPELL_ABILITY_TEXTURES_BASE = {
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

-- Make sure we only cache the proper spells
DRAENOR_ZONE_FACTION_SPECIFIC_SPELLS = {
	[161676] = PLAYER_FACTION_GROUP[1],
	[161332] = PLAYER_FACTION_GROUP[0],
};

-- This list will be name -> Texture for later use, since we do our comparisons based on names
DRAENOR_ZONE_SPELL_ABILITY_TEXTURE_CACHE = {

};

DRAENOR_ZONE_NAME_TO_SPELL_ID_CACHE = {
	
};

function DraenorZoneAbilityFrame_OnLoad(self)
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("SPELL_UPDATE_USABLE");
	self:RegisterEvent("SPELL_UPDATE_CHARGES");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");

	self.SpellButton.spellID = DraenorZoneAbilitySpellID;
	DraenorZoneAbilityFrame_Update(self);
end

function DraenorZoneAbilityFrame_OnEvent(self, event)
	if (event == "SPELLS_CHANGED") then
		if (not self.baseName) then
			self.baseName = GetSpellInfo(DraenorZoneAbilitySpellID);
			if (self.baseName) then
				for spellID, path in pairs(DRAENOR_ZONE_SPELL_ABILITY_TEXTURES_BASE) do
					if (not DRAENOR_ZONE_FACTION_SPECIFIC_SPELLS[spellID] or DRAENOR_ZONE_FACTION_SPECIFIC_SPELLS[spellID] == UnitFactionGroup("player")) then
						local name = GetSpellInfo(spellID);
						DRAENOR_ZONE_SPELL_ABILITY_TEXTURE_CACHE[name] = path;
						DRAENOR_ZONE_NAME_TO_SPELL_ID_CACHE[name] = spellID;
					end
				end
			end
		end
	end

	if (not self.baseName) then
		return;
	end

	local lastState = self.BuffSeen;
	self.BuffSeen = HasDraenorZoneAbility();

	if (self.BuffSeen) then
		if (not HasDraenorZoneSpellOnBar(self)) then
			if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY) ) then
				DraenorZoneAbilityButtonAlert:SetHeight(DraenorZoneAbilityButtonAlert.Text:GetHeight()+42);
				DraenorZoneAbilityButtonAlert:Show();
				SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY, true );
			end
			self:Show();
		else
			DraenorZoneAbilityButtonAlert:Hide();
			self:Hide();
		end

		DraenorZoneAbilityFrame_Update(self);
	else
		if (not self.CurrentTexture) then
			self.CurrentTexture = select(3, GetSpellInfo(self.baseName));
		end
		self:Hide();
	end

	if (lastState ~= self.BuffSeen) then
		UIParent_ManageFramePositions();
		ActionBarController_UpdateAll(true);
	end
end

function DraenorZoneAbilityFrame_OnShow(self)
	DraenorZoneAbilityFrame_Update(self);
end

function DraenorZoneAbilityFrame_OnHide(self)
	DraenorZoneAbilityButtonAlert:Hide();
end

function DraenorZoneAbilityFrame_Update(self)
	if (not self.baseName) then
		return;
	end

	local name, _, tex = GetSpellInfo(self.baseName);

	self.CurrentTexture = tex;
	self.CurrentSpell = name;

	self.SpellButton.Style:SetTexture(DRAENOR_ZONE_SPELL_ABILITY_TEXTURE_CACHE[name]);
	self.SpellButton.Icon:SetTexture(tex);

	local spellID = DRAENOR_ZONE_NAME_TO_SPELL_ID_CACHE[name];
	local charges, maxCharges = GetSpellCharges(spellID);

	if (maxCharges and maxCharges > 1) then
		self.SpellButton.Count:SetText(charges);
	else
		self.SpellButton.Count:SetText("");
	end

	local start, duration, enable = GetSpellCooldown(name);

	if (start) then
		CooldownFrame_SetTimer(self.SpellButton.Cooldown, start, duration, enable);
	end
		
	self.SpellButton.spellName = self.CurrentSpell;
	self.SpellButton.currentSpellID = spellID;
end

function HasDraenorZoneSpellOnBar(self)
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

function GetLastDraenorSpellTexture()
	return DraenorZoneAbilityFrame.CurrentTexture;
end