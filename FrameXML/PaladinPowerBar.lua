MAX_HOLY_POWER = 3;
PALADINPOWERBAR_SHOW_LEVEL = 9



function PaladinPowerBar_ToggleHolyRune(self, visible)
	if visible then
		self.deactivate:Play();
	else
		self.activate:Play();
	end
end


function PaladinPowerBar_Update(self)
	local numHolyPower = UnitPower( PaladinPowerBar:GetParent().unit, SPELL_POWER_HOLY_POWER );

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
	elseif UnitLevel("player") < PALADINPOWERBAR_SHOW_LEVEL then
		self:RegisterEvent("PLAYER_LEVEL_UP");
		self:SetAlpha(0);
	end

	self:RegisterEvent("UNIT_POWER");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	
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
	elseif( event ==  "PLAYER_LEVEL_UP" ) then
		local level = arg1;
		if level >= PALADINPOWERBAR_SHOW_LEVEL then
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			self.showAnim:Play();
			PaladinPowerBar_Update(self);
		end
	else
		PaladinPowerBar_Update(self);
	end
end


