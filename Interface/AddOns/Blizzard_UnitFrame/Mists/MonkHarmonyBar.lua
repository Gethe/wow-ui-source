
MonkHarmonyBarMixin = {}
MonkLightEnergyMixin = {}

function MonkLightEnergyMixin:SetEnergy(active)

	if self.active == active then
		return;
	end

	self.active = active;

	if active then
		if (self.deactivate:IsPlaying()) then
			self.deactivate:Stop();
		end
		
		if (not self.activate:IsPlaying()) then
			self.activate:Play();
		end
	else
		if (self.activate:IsPlaying()) then
			self.activate:Stop();
		end
		
		if (not self.deactivate:IsPlaying()) then
			self.deactivate:Play();
		end
	end
end

function MonkHarmonyBarMixin:Update()
	local light = UnitPower("player", Enum.PowerType.Chi );

	-- if max light changed, show/hide the 5th and update anchors 
	local maxLight = UnitPowerMax("player", Enum.PowerType.Chi );
	if ( self.maxLight ~= maxLight ) then
		if ( maxLight == 4 ) then
			self.lightEnergy1:SetPoint("LEFT", -43, 1);
			self.lightEnergy2:SetPoint("LEFT", self.lightEnergy1, "RIGHT", 5, 0);
			self.lightEnergy3:SetPoint("LEFT", self.lightEnergy2, "RIGHT", 5, 0);
			self.lightEnergy4:SetPoint("LEFT", self.lightEnergy3, "RIGHT", 5, 0);
			self.lightEnergy5:Hide();
		else
			self.lightEnergy1:SetPoint("LEFT", -46, 1);
			self.lightEnergy2:SetPoint("LEFT", self.lightEnergy1, "RIGHT", 1, 0);
			self.lightEnergy3:SetPoint("LEFT", self.lightEnergy2, "RIGHT", 1, 0);
			self.lightEnergy4:SetPoint("LEFT", self.lightEnergy3, "RIGHT", 1, 0);
			self.lightEnergy5:Show();
		end
		self.maxLight = maxLight;
	end
	
	for i = 1, self.maxLight do
		self["lightEnergy"..i]:SetEnergy(i<=light);
	end
end

function MonkHarmonyBarMixin:OnLoad()
	-- Disable frame if not a monk
	local _, class = UnitClass("player");
	if ( class ~= "MONK" ) then
		self:Hide();
		return;
	end
	self.maxLight = 4;
	--self:SetFrameLevel(self:GetParent():GetFrameLevel() + 2);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
end

function MonkHarmonyBarMixin:OnEvent(event, arg1, arg2)
	if ( event == "UNIT_POWER_FREQUENT" ) then
		if ( arg2 == "CHI" or arg2 == "DARK_FORCE" ) then
			self:Update(self);
		end
	else
		self:Update(self);
	end
end