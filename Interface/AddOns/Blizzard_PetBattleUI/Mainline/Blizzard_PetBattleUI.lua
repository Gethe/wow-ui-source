function PetBattleFrame_OnShow(self)
	EditModeManagerFrame:BlockEnteringEditMode(self);
end

function PetBattleFrame_OnHide(self)
	EditModeManagerFrame:UnblockEnteringEditMode(self);
end

function PetBattleXPBar_OnLoad(self)
	self:SetBarTextPrefix(XP);
end

function PetBattleXPBar_OnEnter(self)
	self:ShowStatusBarText();
	if ( self.tooltip ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
	end
end

function PetBattleXPBar_OnLeave(self)
	self:HideStatusBarText();
	GameTooltip:Hide();
end

MicroButtonFrameMixin = {};

function MicroButtonFrameMixin:OnShow()
	MicroMenu:OverrideMicroMenuPosition(self, "TOPLEFT", self, "TOPLEFT", -3, 4, true);
end
