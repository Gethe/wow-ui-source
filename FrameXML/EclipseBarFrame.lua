

ECLIPSE_BAR_POWER_INDEX = 8;
MOONKIN_FORM = 31



function EclipseBar_Update(self)
	local form  = GetShapeshiftFormID();	
	if form == MOONKIN_FORM then
		self:Show();
	else
		self:Hide();
		return;
	end

	local power = UnitPower( self:GetParent().unit, ECLIPSE_BAR_POWER_INDEX );
	local maxPower = UnitPowerMax( self:GetParent().unit, ECLIPSE_BAR_POWER_INDEX );	
	
	local barWidth = (self:GetWidth() - 10) / 2.0;
	local xpos =  barWidth*(power/maxPower)
	self.marker:SetPoint("CENTER", xpos, 0);
	--print("Eclipse bar: "..power..", "..maxPower..", "..xpos);
	
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
	self:RegisterEvent("UNIT_ECLIPSE");
	self:RegisterEvent("UNIT_MAXECLIPSE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");	
end



function EclipseBar_OnEvent (self, event, arg1)
	if ( event == "UNIT_DISPLAYPOWER" ) then		
		EclipseBar_Update (self)
	elseif ( event=="PLAYER_ENTERING_WORLD" ) then	
		EclipseBar_Update (self)
	elseif ( (event == "UNIT_ECLIPSE") and (arg1 == self:GetParent().unit) ) then
		EclipseBar_Update (self)
	elseif ( (event == "UNIT_MAXECLIPSE") and (arg1 == self:GetParent().unit) ) then
		EclipseBar_Update (self)
	elseif (event == "UPDATE_SHAPESHIFT_FORM")then
		EclipseBar_Update (self)
	else
		print("Unhandled Eclipse Event:",  event);
	end
end