

ECLIPSE_BAR_POWER_INDEX = 8;
MOONKIN_FORM = 31


function EclipseBar_UpdateShown(self)
	if VehicleMenuBar:IsShown() then
		return;
	end

	-- Disable rune frame if not a DRUID.
	local _, class = UnitClass("player");
	local form  = GetShapeshiftFormID();
	
	if  class == "DRUID" and (form == MOONKIN_FORM or not form) then
		if GetMasteryIndex(GetActiveTalentGroup(false, false)) == 1 then
			self.showPercent = GetCVarBool("statusTextPercentage");	
			if GetCVarBool("playerStatusText") then
				self.powerText:Show();
				self.lockShow = true;
			else
				self.powerText:Hide();
				self.lockShow = false;
			end
			self:Show();
		else
			self:Hide();
		end
	else
		self:Hide();
		return;
	end
end



function EclipseBar_Update(self)
	local power = UnitPower( self:GetParent().unit, ECLIPSE_BAR_POWER_INDEX );
	local maxPower = UnitPowerMax( self:GetParent().unit, ECLIPSE_BAR_POWER_INDEX );
	if self.showPercent then 
		self.powerText:SetText(abs(power/maxPower*100).."%");
	else
		self.powerText:SetText(abs(power));
	end
	
	local barWidth = (self:GetWidth() - 10) / 2.0;
	local xpos =  barWidth*(power/maxPower)
	self.marker:SetPoint("CENTER", xpos, 0);
	
	if( abs(power) == maxPower ) then
		self.glow:Show();
		self.glow:ClearAllPoints();
		if power < 0 then
			self.glow:SetPoint("CENTER", self, "LEFT", -10, 2);
		else
			self.glow:SetPoint("CENTER", self, "RIGHT", 10, 2);
		end			
	else
		self.glow:Hide();
	end	
end





function EclipseBar_OnLoad (self)
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");	
	self:RegisterEvent("PLAYER_TALENT_UPDATE");	
	self:RegisterEvent("MASTERY_UPDATE");
	self:RegisterEvent("CVAR_UPDATE");
	self.lockShow = false;
end



function EclipseBar_OnEvent (self, event, ...)
	EclipseBar_UpdateShown(self);
end