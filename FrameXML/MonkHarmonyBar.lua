

MONKHARMONYBAR_SHOW_LEVEL = 0;
MONKHARMONYBAR_MAX_COUNT = 4;

function MonkHarmonyBar_SetEnergy(self, active)
	if ( active ) then
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


function MonkHarmonyBar_Update(self)
	local light = UnitPower( MonkHarmonyBar:GetParent().unit, SPELL_POWER_LIGHT_FORCE );

	for i=1,MONKHARMONYBAR_MAX_COUNT do
		MonkHarmonyBar_SetEnergy(self["lightEnergy"..i], i<=light);
	end
end



function MonkHarmonyBar_OnLoad (self)
	-- Disable frame if not a monk
	local _, class = UnitClass("player");
	if ( class ~= "MONK" ) then
		self:Hide();
		return;
	elseif UnitLevel("player") < MONKHARMONYBAR_SHOW_LEVEL then
		self:RegisterEvent("PLAYER_LEVEL_UP");
		self:SetAlpha(0);
	end
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 2);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterUnitEvent("UNIT_POWER", "player", "vehicle");
end



function MonkHarmonyBar_OnEvent (self, event, arg1, arg2)
	if ( event == "UNIT_POWER" ) then
		if ( arg1 == self:GetParent().unit and (arg2 == "LIGHT_FORCE" or arg2 == "DARK_FORCE") ) then
			MonkHarmonyBar_Update(self);
		end
	elseif( event ==  "PLAYER_LEVEL_UP" ) then
		local level = arg1;
		if level >= MONKHARMONYBAR_SHOW_LEVEL then
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			self.showAnim:Play();
			MonkHarmonyBar_Update(self);
		end
	else
		MonkHarmonyBar_Update(self);
	end
end


