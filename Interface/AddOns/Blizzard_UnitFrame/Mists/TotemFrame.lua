TOTEM_BUTTON_DURATION_TEXT_VERTICAL_OFFSET = 5;

function TotemFrameMixin:UpdateClassSpecificLayout()
	local _, class = UnitClass("player");	
	local hasPet = PetFrame and PetFrame:IsShown();
	if (class == "PALADIN" or class == "WARLOCK" or class == "DEATHKNIGHT") then
		if ( hasPet ) then
			self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 28, -75);
		else
			self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 67, -63);
		end
	elseif (class == "DRUID") then
		local form  = GetShapeshiftFormID();
		if (form == MOONKIN_FORM or not form) then
			if (C_SpecializationInfo.GetSpecialization() == 1) then
				self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 115, -88);
			else
				self:SetPoint("TOPLEFT", PlayerFrame, "BOTTOMLEFT", 99, 38);
			end
		elseif (form == BEAR_FORM or form == CAT_FORM) then
			self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 99, -78);
		else
			self:SetPoint("TOPLEFT", PlayerFrame, "BOTTOMLEFT", 99, 38);
		end
	elseif ( class == "MONK" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 28, -75);
	elseif (hasPet and class ~= "SHAMAN") then
		self:Hide();
	end
end
