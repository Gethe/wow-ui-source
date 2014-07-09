DraenorZoneAbilitySpellID = 161691;

function DraenorZoneAbilityFrame_OnLoad(self)
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("SPELL_UPDATE_USABLE");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");

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
		end

		DraenorZoneAbilityFrame_Update(self);
	else
		if (not self.CurrentTexture) then
			self.CurrentTexture = select(3, GetSpellInfo(self.baseName));
		end
		DraenorZoneAbilityButtonAlert:Hide();
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

function DraenorZoneAbilityFrame_Update(self)
	if (not self.baseName) then
		return;
	end

	local name, _, tex = GetSpellInfo(self.baseName);

	self.CurrentTexture = tex;
	self.CurrentSpell = name;

	self.SpellButton.Icon:SetTexture(tex);

	local start, duration, enable = GetSpellCooldown(name);

	if (start) then
		CooldownFrame_SetTimer(self.SpellButton.Cooldown, start, duration, enable);
	end
		
	self.SpellButton.spellName = self.CurrentSpell;
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