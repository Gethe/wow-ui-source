TOTEM_BUTTON_DURATION_TEXT_VERTICAL_OFFSET = 0;

function TotemFrameMixin:UpdateClassSpecificLayout()
	local _, class = UnitClass("player");	
	local hasPet = PetFrame and PetFrame:IsShown();
	if ( hasPet ) then
		if ( class == "DEATHKNIGHT" ) then
			self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 28, -75);
		elseif ( class == "SHAMAN" ) then
			--Nothing!
		else
			self:Hide();
			return;
		end
	elseif ( class == "DEATHKNIGHT" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 65, -55);
	end
end