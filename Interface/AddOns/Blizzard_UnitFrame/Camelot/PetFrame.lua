function PetFrameMixin:OnLoad()
	self:OnLoadBase();

	PetName:SetJustifyH("CENTER");
	PetName:ClearAllPoints();
	PetName:SetPoint("TOPLEFT", PetPortrait, "TOPRIGHT", 2, -1);

	PetAttackModeTexture:ClearAllPoints();
	PetAttackModeTexture:SetPoint("TOPLEFT", PetFrame, "TOPLEFT", 0, 0);

	PetFrameFlash:ClearAllPoints();
	PetFrameFlash:SetPoint("TOPLEFT", PetFrame, "TOPLEFT", 0, 0);

	PetFrameHealthBar:ClearAllPoints();
	PetFrameHealthBar:SetPoint("BOTTOMLEFT", PetPortrait, "RIGHT", 3, -4);
	PetFrameHealthBarMask:ClearAllPoints();
	PetFrameHealthBarMask:SetPoint("TOPLEFT", PetFrameHealthBar, "TOPLEFT", -26, 3);

	PetFrameManaBar:ClearAllPoints();
	PetFrameManaBar:SetPoint("TOPLEFT", PetFrameHealthBar, "BOTTOMLEFT", -2, -2);
end
