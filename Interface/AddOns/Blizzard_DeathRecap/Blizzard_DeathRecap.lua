NUM_DEATH_RECAP_EVENTS = 5;
function DeathRecapFrame_OpenRecap( recapID )
	local self = DeathRecapFrame;
	
	if( self:IsShown() and recapID == self.recapID ) then
		self.recapID = nil;
		HideUIPanel(DeathRecapFrame);
		return;
	end
	
	self.recapID = recapID;	
	ShowUIPanel(DeathRecapFrame);
		
	local events = DeathRecap_GetEvents( recapID );
	
	if( not events or #events <= 0 ) then
		for i = 1, NUM_DEATH_RECAP_EVENTS do
			self.DeathRecapEntry[i]:Hide();
		end
		DeathRecapFrame.Unavailable:Show();
		return;
	end
	DeathRecapFrame.Unavailable:Hide();
	
	local maxHp = UnitHealthMax("player");
	local highestDmgIdx, highestDmgAmount = 1, 0;
	self.DeathTimeStamp = nil;
	
	for i = 1, #events do
		local entry = self.DeathRecapEntry[i];
		entry:Show();
		local evtData = events[i]; 
		local spellId, spellName, texture = DeathRecapFrame_GetEventInfo( evtData );		
		self.DeathTimeStamp = self.DeathTimeStamp or evtData.timestamp;
		
		local dmgInfo = entry.DamageInfo;
		if ( evtData.amount ) then
			local amountStr = BreakUpLargeNumbers(-(evtData.amount));
			dmgInfo.Amount:SetText(amountStr);
			dmgInfo.AmountLarge:SetText(amountStr);
			dmgInfo.amount = BreakUpLargeNumbers(evtData.amount);
		
			dmgInfo.dmgExtraStr = "";
			if ( evtData.overkill and evtData.overkill > 0 ) then
				dmgInfo.dmgExtraStr = format(TEXT_MODE_A_STRING_RESULT_OVERKILLING, evtData.overkill);
				dmgInfo.amount = BreakUpLargeNumbers(evtData.amount - evtData.overkill)
			end
			if ( evtData.absorbed and evtData.absorbed > 0 ) then
				dmgInfo.dmgExtraStr = dmgInfo.dmgExtraStr.." "..format(TEXT_MODE_A_STRING_RESULT_ABSORB, evtData.absorbed);
				dmgInfo.amount = BreakUpLargeNumbers(evtData.amount - evtData.absorbed)
			end
			if ( evtData.resisted and evtData.resisted > 0 ) then
				dmgInfo.dmgExtraStr = dmgInfo.dmgExtraStr.." "..format(TEXT_MODE_A_STRING_RESULT_RESIST, evtData.resisted);
				dmgInfo.amount = BreakUpLargeNumbers(evtData.amount - evtData.resisted)
			end
			if ( evtData.blocked and evtData.blocked > 0 ) then
				dmgInfo.dmgExtraStr = dmgInfo.dmgExtraStr.." "..format(TEXT_MODE_A_STRING_RESULT_BLOCK, evtData.blocked);
				dmgInfo.amount = BreakUpLargeNumbers(evtData.amount - evtData.blocked)
			end
			
			if( evtData.amount > highestDmgAmount ) then
				highestDmgIdx = i;
				highestDmgAmount = evtData.amount;
			end
			dmgInfo.Amount:Show();
			dmgInfo.AmountLarge:Hide();
		else
			dmgInfo.Amount:SetText("");
			dmgInfo.AmountLarge:SetText("");
			dmgInfo.amount = nil;
			dmgInfo.dmgExtraStr = nil;
		end
		
		dmgInfo.timestamp = evtData.timestamp;
		dmgInfo.hpPercent = floor(evtData.currentHP/maxHp*100);
		
		dmgInfo.spellName = spellName;
		if( not evtData.hideCaster ) then
			dmgInfo.caster = evtData.sourceName or COMBATLOG_UNKNOWN_UNIT
			dmgInfo.casterPrestige = evtData.casterPrestige;
		else
			dmgInfo.caster = nil;
			dmgInfo.casterPrestige = nil;
		end
		dmgInfo.school = evtData.school;
		
		entry.SpellInfo.Caster:SetText(dmgInfo.caster); --may want to add honor level back to this someday, used to have prestige
		entry.SpellInfo.Name:SetText(spellName);
		entry.SpellInfo.Icon:SetTexture(texture);

		entry.SpellInfo.spellId = spellId;
	end
	
	for i = #events+1, #(self.DeathRecapEntry) do
		self.DeathRecapEntry[i]:Hide();
	end

	local entry = self.DeathRecapEntry[highestDmgIdx];
	if ( entry.DamageInfo.amount ) then
		entry.DamageInfo.Amount:Hide();
		entry.DamageInfo.AmountLarge:Show();
	end
	local deathEntry = self.DeathRecapEntry[1];
	local tombstoneIcon = deathEntry.tombstone;
	if ( entry == deathEntry ) then
		tombstoneIcon:SetPoint("RIGHT", deathEntry.DamageInfo.AmountLarge, "LEFT", -10, 0);
	else
		tombstoneIcon:SetPoint("RIGHT", deathEntry.DamageInfo.Amount, "LEFT", -10, 0);
	end	
end

function DeathRecapFrame_OnHide(self)
	self.recapID = nil;
end

function DeathRecapFrame_Spell_OnEnter(self)
	if ( self.spellId ) then 
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetSpellByID(self.spellId, false, false, false, -1, true);
		GameTooltip:Show();
	end
end

function DeathRecapFrame_Amount_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:ClearLines();
	if( self.amount ) then
		local valueStr = self.school and format(TEXT_MODE_A_STRING_VALUE_SCHOOL, self.amount, CombatLog_String_SchoolString(self.school)) or
						 self.amount;	
		GameTooltip:AddLine(format(DEATH_RECAP_DAMAGE_TT, valueStr, self.dmgExtraStr), 1, 0, 0, false);
	end
	
	if( self.spellName ) then
		if( self.caster and #self.caster > 0 ) then
			GameTooltip:AddLine(format(DEATH_RECAP_CAST_BY_TT, self.spellName, self.caster), 1, 1, 1, true );
		else
			GameTooltip:AddLine(self.spellName, 1, 1, 1, true );
		end
	end
	
	local seconds = DeathRecapFrame.DeathTimeStamp - self.timestamp;
	if ( seconds > 0 ) then
		GameTooltip:AddLine( format(DEATH_RECAP_CURR_HP_TT, format("%.1F", seconds), self.hpPercent), 1, 0.824, 0, true );
	else
		GameTooltip:AddLine( format(DEATH_RECAP_DEATH_TT, self.hpPercent), 1, 0.824, 0, true );
	end
	
	GameTooltip:Show();
end

----------------
function DeathRecapFrame_GetEventInfo(evtData)
	local spellName = evtData.spellName;
	local nameIsNotSpell = false;
	
	local event = evtData.event;
	local spellId = evtData.spellId;
	local texture;
	if ( event == "SWING_DAMAGE" ) then
		spellId = 88163; 
		spellName = ACTION_SWING;
		
		nameIsNotSpell = true;
	elseif ( event == "RANGE_DAMAGE" ) then 
		nameIsNotSpell = true;
	elseif ( strsub(event, 1, 5) == "SPELL" ) then	-- Spell standard arguments
	-- elseif ( event == "DAMAGE_SHIELD" ) then
	elseif ( event == "ENVIRONMENTAL_DAMAGE" ) then
		local environmentalType = evtData.environmentalType;
		environmentalType = string.upper(environmentalType);
		spellName = _G["ACTION_ENVIRONMENTAL_DAMAGE_"..environmentalType];
		nameIsNotSpell = true;
		if ( environmentalType == "DROWNING" ) then
			texture = "spell_shadow_demonbreath";
		elseif ( environmentalType == "FALLING" ) then
			texture = "ability_rogue_quickrecovery";
		elseif ( environmentalType == "FIRE" or environmentalType == "LAVA" ) then
			texture = "spell_fire_fire";
		elseif ( environmentalType == "SLIME" ) then
			texture = "inv_misc_slime_01";
		elseif ( environmentalType == "FATIGUE" ) then
			texture = "ability_creature_cursed_05";
		else
			texture = "ability_creature_cursed_05"; -- default
		end
		texture = "Interface\\Icons\\"..texture;
	-- elseif ( event == "DAMAGE_SPLIT" ) then
	end
	
	local spellNameStr = spellName;
	local spellString;
	if ( spellName ) then
		if ( nameIsNotSpell ) then
			spellString = format(TEXT_MODE_A_STRING_ACTION, event, spellNameStr);
		else
			spellString = spellName;
		end
	end
	
	if ( spellId and not texture ) then
		texture = select(3, GetSpellInfo(spellId));
	end
	return spellId, spellString, texture;
end