--DraenorZoneAbilitySpellID = 15473;
--DraenorZoneAbilitySpellID = 113858;

--[[DraenorZoneAbilitySpellArtPackages = {
	[15473] = {
		animationKey = "SomeKeyForSomeAnimGroup",
		atlasFormat = "Generic",
	}
}]]

function DraenorZoneAbilityFrame_OnLoad(self)
--	self:RegisterUnitEvent("UNIT_AURA", "player");
--	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
--	self:RegisterEvent("SPELL_UPDATE_USABLE");
--	self:RegisterEvent("SPELLS_CHANGED");

	self.Expanded.SpellButton.spellID = DraenorZoneAbilitySpellID;
--	DraenorZoneAbilityFrame_Update(self);
end

function DraenorZoneAbilityFrame_OnEvent(self, event)
	if (event == "SPELLS_CHANGED") then
		if (not self.buffName) then
			self.buffName = GetSpellInfo(DraenorZoneAbilitySpellID);
		end
		DraenorZoneAbilityFrame_Update(self);
	else
		DraenorZoneAbilityFrame_Update(self);
	end
end

function DraenorZoneAbilityFrame_OnUpdate(self, elapsed)
	if (GetTime() > self.start + self.duration) then 
		DraenorZoneAbilityFrame_Update(self); 
		self:SetScript("OnUpdate", nil);
		return;
	else
		self.Timer.Fill:SetValue(self.Timer.Fill:GetValue() + elapsed);
	end
end

function DraenorZoneAbilityFrame_Update(self)
	if (not self.buffName) then
		return;
	end

	self.BuffSeen = UnitBuff("player", self.buffName);

	if (self.BuffSeen) then
		self.WasSeen = true;
		--[[
		if (self.CurrentSpell) then
			-- animation the current spell out
		end]]

		-- Change the atlas's!!

		local name, _, tex = GetSpellInfo(DraenorZoneAbilitySpellID);
		local start, duration = GetSpellCooldown(DraenorZoneAbilitySpellID);

		if ((start ~= 0 and duration > 1.5) and not self.start or not self.duration) then
			self.start = start;
			self.duration = duration;
		end

		self.Timer:Show();

		if (start == 0 --[[or duration <= 1.5]] or (GetTime() > (self.start + self.duration))) then
			if (self.CurrentSpell ~= name or not self.expanded) then
				-- Animate it in expanded now, but for now, just show expanded version

				self.Collapsed:Hide();
				self.Expanded:Show();

				self.CurrentSpell = name;
				self.expanded = true;

				self.Expanded.SpellButton.Icon:SetTexture(tex);
				self.Expanded.AbilityName:SetText(name);
				self.Timer:SetPoint("TOP", 2, -38);
		
				self:SetScript("OnUpdate", nil);
				
				self.Timer.Fill:SetMinMaxValues(0, 1);
				self.Timer.Fill:SetValue(1);
				self.Timer.Fill.Glow:Show();
			end
		elseif (self.CurrentSpell ~= name or self.expanded) then
			-- Animation it in to collapsed, but for now, just show collapsed version
			self.Expanded:Hide();
			self.Collapsed:Show();

			self.CurrentSpell = name;
			self.expanded = false;

			self.Collapsed.AbilityName:SetText(name);
			self.Timer:SetPoint("TOP", 0, -14);
			self.Timer.Fill:SetMinMaxValues(0, duration - (GetTime() - start));

			self.Timer.Fill:SetValue(0);
			self.Timer.Fill.Glow:Hide();

			self:SetScript("OnUpdate", DraenorZoneAbilityFrame_OnUpdate);
		end

		self:Show();

		WorldStateAlwaysUpFrame:ClearAllPoints();
		WorldStateAlwaysUpFrame:SetPoint("TOP", self.Timer, "BOTTOM", -5, -15);
	else
		if (self.WasSeen) then
			-- Animate out!  For now though just hide
			self.Collapsed:Hide();
			self.Expanded:Hide();
			self.Timer:Hide();

			self.WasSeen = false;
			self.CurrentSpell = nil;
		end

		self.start = nil;
		self.duration = nil;
		self:Hide();
		self:SetScript("OnUpdate", nil);

		WorldStateAlwaysUpFrame:ClearAllPoints();
		WorldStateAlwaysUpFrame:SetPoint("TOP", -5, -15);
	end
end