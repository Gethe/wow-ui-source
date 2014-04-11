function MonkHarmonyBar_SetEnergy(self, active)
	if ( active ) then
		if (self.deactivate:IsPlaying()) then
			self.deactivate:Stop();
		end
		
		if (not self.active and not self.activate:IsPlaying()) then
			self.activate:Play();
			self.active = true;
		end
	else
		if (self.activate:IsPlaying()) then
			self.activate:Stop();
		end
		
		if (self.active and not self.deactivate:IsPlaying()) then
			self.deactivate:Play();
			self.active = false;
		end
	end
end

function MonkHarmonyBar_UpdateMaxPower(self)
	-- if max light changed, show/hide the 5th and update anchors 
	local maxLight = UnitPowerMax("player", SPELL_POWER_CHI );
	if ( self.maxLight ~= maxLight ) then
		local startX, xOffset, orbOff, lightOrb;

		if ( maxLight == 4 ) then
			startX = -43;
			xOffset = 5;
			orbOff = "MonkUI-OrbOff";
			lightOrb = "MonkUI-LightOrb";
		elseif (maxLight == 5 ) then
			startX = -46;
			xOffset = 1;
			orbOff = "MonkUI-OrbOff";
			lightOrb = "MonkUI-LightOrb";
		else
			startX = -54;
			xOffset = 0;
			orbOff = "MonkUI-OrbOff-small";
			lightOrb = "MonkUI-LightOrb-small";
		end

		for i = 1,maxLight do
			local orb = self.LightEnergy[i];
			if (not orb) then
				orb = CreateFrame("Frame", nil, MonkHarmonyBar, "MonkLightEnergyTemplate");
			end
			orb:ClearAllPoints();
			orb.Glow:SetAtlas(lightOrb, true);
			orb.OrbOff:SetAtlas(orbOff, true);
			if (i == 1) then
				orb:SetPoint("LEFT", startX, 1);
			else
				local prev = self.LightEnergy[i - 1];
				orb:SetPoint("LEFT", prev, "RIGHT", xOffset, 0);
			end
			orb:Show();
		end
		
		for i = maxLight+1, #self.LightEnergy do
			local orb = self.LightEnergy[i];
			if (orb) then
				orb:Hide();
			end
		end

		self.maxLight = maxLight;
	end
end

function MonkHarmonyBar_Update(self)
	local light = UnitPower("player", SPELL_POWER_CHI );
	
	for i = 1, self.maxLight do
		MonkHarmonyBar_SetEnergy(self.LightEnergy[i], i<=light);
	end
end



function MonkHarmonyBar_OnLoad (self)
	-- Disable frame if not a monk
	local _, class = UnitClass("player");
	if ( class ~= "MONK" ) then
		self:Hide();
		return;
	end
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 2);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
end



function MonkHarmonyBar_OnEvent (self, event, arg1, arg2)
	if ( event == "UNIT_POWER_FREQUENT" ) then
		if ( arg2 == "CHI" or arg2 == "DARK_FORCE" ) then
			MonkHarmonyBar_Update(self);
		end
	else
		MonkHarmonyBar_UpdateMaxPower(self);
		MonkHarmonyBar_Update(self);
	end
end


