ClassNameplateBarDeathKnight = {};

function ClassNameplateBarDeathKnight:OnLoad()
	self.class = "DEATHKNIGHT";
	self.powerToken = "RUNES";
	
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarDeathKnight:Setup()
	if ( self:MatchesClass() ) then
		self:RegisterEvent("RUNE_POWER_UPDATE");
	end

	return ClassNameplateBar.Setup(self);
end

function ClassNameplateBarDeathKnight:OnEvent(event, arg1, arg2)
	if ( event == "RUNE_POWER_UPDATE" ) then
		self:UpdateRunes(arg1, arg2);
		return true;
	end
	return ClassNameplateBar.OnEvent(self, event, arg1, arg2);
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