function ProfessionsButtonMixin:OnLoad()
	self.IconBorder:ClearAllPoints();
	self.IconBorder:SetPoint("TOPLEFT", self.Icon, "TOPLEFT", -5, 4);
	self.IconBorder:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT", 4, -5);
end
