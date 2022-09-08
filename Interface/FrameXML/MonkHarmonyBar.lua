MonkPowerBar = {};
function MonkPowerBar:UpdatePower()
	local light = UnitPower("player", Enum.PowerType.Chi);
	for i = 1, #self.classResourceButtonTable do
		self.classResourceButtonTable[i]:SetEnergy(i<=light);
	end
end

MonkLightEnergyMixin = { }; 
function MonkLightEnergyMixin:Setup()
	local maxLight = UnitPowerMax("player", Enum.PowerType.Chi);
	if ( maxLight == 4 ) then
		orbOff = "MonkUI-OrbOff";
		lightOrb = "MonkUI-LightOrb";
	elseif (maxLight == 5 ) then
		orbOff = "MonkUI-OrbOff";
		lightOrb = "MonkUI-LightOrb";
	else
		orbOff = "MonkUI-OrbOff-small";
		lightOrb = "MonkUI-LightOrb-small";
	end
	self.Glow:SetAtlas(lightOrb, true);
	self.OrbOff:SetAtlas(orbOff, true);
	self:Show();
end


function MonkLightEnergyMixin:SetEnergy(active)
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