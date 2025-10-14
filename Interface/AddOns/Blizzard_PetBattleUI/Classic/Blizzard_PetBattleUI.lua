function PetBattleFrame_OnShow(self)
end

function PetBattleFrame_OnHide(self)
end

function PetBattleXPBar_OnLoad(self)
	SetTextStatusBarTextPrefix(XP);
end

function PetBattleXPBar_OnEnter(self)
	ShowTextStatusBarText(self);
	if ( self.tooltip ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
	end
end

function PetBattleXPBar_OnLeave(self)
	HideTextStatusBarText(self);
	GameTooltip:Hide();
end

MicroButtonFrameMixin = {};

function MicroButtonFrameMixin:OnShow()
	OverrideMicroMenuPosition(self, "TOPLEFT", self, "TOPLEFT", -10, 27, true);
end
