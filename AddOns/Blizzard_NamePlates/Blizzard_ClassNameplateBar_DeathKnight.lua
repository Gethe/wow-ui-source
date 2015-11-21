ClassNameplateBarDeathKnight = {};

function ClassNameplateBarDeathKnight:OnLoad()
	local _, myclass = UnitClass("player");
	if (myclass == "DEATHKNIGHT") then
		self:Show();
		NamePlateDriverFrame:SetClassNameplateBar(self);
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
		self:RegisterEvent("RUNE_POWER_UPDATE");
	end
end

function ClassNameplateBarDeathKnight:OnEvent(event, arg1, arg2)
	self:UpdateRunes(arg1, arg2);
end

function ClassNameplateBarDeathKnight:UpdateRunes(runeIndex, isEnergize)
	if runeIndex and runeIndex >= 1 and runeIndex <= #self.Runes then 
		local runeButton = self.Runes[runeIndex];
		
		local cooldown = runeButton.Cooldown;
		local start, duration, runeReady = GetRuneCooldown(runeIndex);

		if not runeReady then
			if start then
				CooldownFrame_SetTimer(cooldown, start, duration, 1);
			end
		end
	end
end