HOLY_POWER_INDEX = 9;
MAX_HOLY_POWER = 3;



function PaladinPowerBar_ToggleHolyRune(self, visible)
	if visible then
		self.deactivate:Play();
	else
		self.activate:Play();
	end
end


function PaladinPowerBar_Update(self)
	
	
	-- Temp hack checking buffs
	local unit = PlayerFrame.unit;
	local j = 1;
	local numHolyPowerTemp = 0;
	local name, rank, texture, count = UnitAura(unit, j, "HELPFUL");
	while name do 
		if name == "Holy Power" then 
			numHolyPowerTemp = count;
			break;
		end
		j=j+1;
		name, rank, texture, count = UnitAura(unit, j, "HELPFUL");
	end



	
	local numHolyPower = max(numHolyPowerTemp, UnitPower( PaladinPowerBar:GetParent().unit, HOLY_POWER_INDEX ));

	for i=1,MAX_HOLY_POWER do
		local holyRune = self["rune"..i];
		local isShown = holyRune:GetAlpha()> 0 or holyRune.activate:IsPlaying();
		local shouldShow = i <= numHolyPower;
		if isShown ~= shouldShow then 
			PaladinPowerBar_ToggleHolyRune(holyRune, isShown);
		end
	end
	
	if numHolyPower == MAX_HOLY_POWER then
		self.glow.pulse.stopPulse = false;
		self.glow.pulse:Play();
	else
		self.glow.pulse.stopPulse = true;
	end
end



function PaladinPowerBar_OnLoad (self)
	-- Disable rune frame if not a Warlock.
	local _, class = UnitClass("player");	
	if ( class ~= "PALADIN" ) then
		self:Hide();
		return;
	end
	self:RegisterEvent("UNIT_POWER");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	
	self:RegisterEvent("UNIT_AURA");
	
	self.glow:SetAlpha(0);
	self.rune1:SetAlpha(0);
	self.rune2:SetAlpha(0);
	self.rune3:SetAlpha(0);
end



function PaladinPowerBar_OnEvent (self, event, arg1, arg2)
	if ( (event == "UNIT_POWER") and (arg1 == self:GetParent().unit) ) then
		if ( arg2 == "HOLY_POWER" ) then
			PaladinPowerBar_Update(self);
		end
	else
		PaladinPowerBar_Update(self);
	end
end


