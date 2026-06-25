do
	AuraButtonMixin.SetupDebuffBorderTexture = function(self)
		self.DebuffBorder:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays");
		self.DebuffBorder:SetSize(33, 32);
		self.DebuffBorder:SetTexCoord(0.296875, 0.5703125, 0, 0.515625);
	end;
end
