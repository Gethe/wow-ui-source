ZONE_SPELL_ABILITY_TEXTURES_BASE = {
	[161676] = 1016652; -- "Interface\\ExtraButton\\GarrZoneAbility-BarracksAlliance",
	[161332] = 1016653; -- "Interface\\ExtraButton\\GarrZoneAbility-BarracksHorde",
	[162075] = 1016651; -- "Interface\\ExtraButton\\GarrZoneAbility-Armory",
	[161767] = 1016656; -- "Interface\\ExtraButton\\GarrZoneAbility-MageTower",
	[170097] = 1016658; -- "Interface\\ExtraButton\\GarrZoneAbility-TradingPost",
	[170108] = 1016658; -- "Interface\\ExtraButton\\GarrZoneAbility-TradingPost",
	[168487] = 1016654; -- "Interface\\ExtraButton\\GarrZoneAbility-Inn",
	[168499] = 1016654; -- "Interface\\ExtraButton\\GarrZoneAbility-Inn",
	[164012] = 1016659; -- "Interface\\ExtraButton\\GarrZoneAbility-TrainingPit",
	[164050] = 1016655; -- "Interface\\ExtraButton\\GarrZoneAbility-LumberMill",
	[165803] = 1016657; -- "Interface\\ExtraButton\\GarrZoneAbility-Stables",
	[164222] = 1016657; -- "Interface\\ExtraButton\\GarrZoneAbility-Stables",
	[160240] = 1016660; -- "Interface\\ExtraButton\\GarrZoneAbility-Workshop",
	[160241] = 1016660; -- "Interface\\ExtraButton\\GarrZoneAbility-Workshop",
};

ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK = 1016651; -- "Interface\\ExtraButton\\GarrZoneAbility-Armory";

function ZoneAbilityFrame_OnLoad(self)
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("SPELL_UPDATE_USABLE");
	self:RegisterEvent("SPELL_UPDATE_CHARGES");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	self:RegisterEvent("SPELL_NAME_UPDATE");

	ZoneAbilityFrame_Update(self);
end

function ZoneAbilityFrame_OnEvent(self, event, ...)
	-- Ask for the generic constant spell ID, based on our Aura. Then turn around
	-- and use that spell's name to look up the correct faction-specific spell ID
	-- that is relevant for our own player.
	-- EDITORIAL: this is a terrible, horrible way to find our spell. It needs to be fixed. -CM
	local spellID, type = GetZoneAbilitySpellInfo();
	if ((event == "SPELLS_CHANGED" or event=="UNIT_AURA")) then
		self.spellID = nil;
		self.baseSpellID = spellID;
		local baseName = spellID and GetSpellInfo(spellID) or nil;
		if baseName then
			self.spellID = select(7, GetSpellInfo(baseName));
		end
	elseif event == "SPELL_NAME_UPDATE" then
		local updateSpellID, spellName = ...;
		if spellID == updateSpellID then
			self.spellID = select(7, GetSpellInfo(spellName));
		end
	end

	if (not self.spellID) then
		self:Hide();
		return;
	end

	self.SpellButton.baseSpellID = self.baseSpellID;
	self.SpellButton.spellID = self.spellID;
	local lastState = self.buffSeen;
	self.buffSeen = (self.spellID ~= 0);

	if (self.buffSeen) then
		if (not HasZoneAbilitySpellOnBar(self)) then
			if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY) and type == Enum.ZoneAbilityType.Garrison ) then
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
			self.CurrentTexture = select(3, GetSpellInfo(self.spellID));
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
	if (not self.spellID) then
		return;
	end
	local name, _, tex = GetSpellInfo(self.spellID);

	self.CurrentTexture = tex;
	self.CurrentSpell = name;

	self.SpellButton.Style:SetTexture(ZONE_SPELL_ABILITY_TEXTURES_BASE[self.spellID] or ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK);
	self.SpellButton.Icon:SetTexture(tex);

	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(self.spellID);

	local usesCharges = false;
	if (maxCharges and maxCharges > 1) then
		self.SpellButton.Count:SetText(charges);
		usesCharges = true;
	else
		self.SpellButton.Count:SetText("");
	end

	local start, duration, enable = GetSpellCooldown(self.spellID);
	
	if (usesCharges and charges < maxCharges) then
		StartChargeCooldown(self.SpellButton, chargeStart, chargeDuration, enable);
	end
	if (start) then
		CooldownFrame_Set(self.SpellButton.Cooldown, start, duration, enable);
	end

	self.SpellButton.spellName = self.CurrentSpell;
	self.SpellButton.currentSpellID = self.spellID;
end

function HasZoneAbilitySpellOnBar(self)
	if (not self.spellID) then
		return false;
	end

	local name = GetSpellInfo(self.spellID);
	for i = 1, (LE_NUM_NORMAL_ACTION_PAGES * LE_NUM_ACTIONS_PER_PAGE) + 1, 1 do
		local type, id = GetActionInfo(i);

		if (type == "spell" or type == "companion") then
			if (id == self.spellID) then
				return true;
			end
		end
	end

	local bonusBarIndex = GetBonusBarIndex();
	if (HasBonusActionBar() and bonusBarIndex ~= 0) then
		for i = ((bonusBarIndex - 1) * LE_NUM_ACTIONS_PER_PAGE) + 1, bonusBarIndex * LE_NUM_ACTIONS_PER_PAGE, 1 do
			local type, id = GetActionInfo(i);

			if (type == "spell" or type == "companion") then
				if (id == self.spellID) then
					return true;
				end
			end
		end
	end

	return false;
end

function HasZoneAbility()
	local spellID, garrisonType = GetZoneAbilitySpellInfo();
	return (spellID ~= nil);
end

function GetLastZoneAbilitySpellTexture()
	return ZoneAbilityFrame.CurrentTexture;
end

function ZoneAbilityFrame_OnClick(self)
	CastSpellByID(self.baseSpellID);
end

function ZoneAbilityFrame_OnDragStart(self)
	PickupSpell(self.baseSpellID);
end