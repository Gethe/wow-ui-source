
PlayerCastingBarMixin = {};

function PlayerCastingBarMixin:OnLoad()
	local showTradeSkills = true;
	local showShieldNo = false;
	CastingBarMixin.OnLoad(self, "player", showTradeSkills, showShieldNo);
	self.Icon:Hide();
end

function PlayerCastingBarMixin:OnShow()
	CastingBarMixin.OnShow(self);
	UIParentManagedFrameMixin.OnShow(self); 
end

function PlayerCastingBarMixin:IsAttachedToPlayerFrame()
	return self.attachedToPlayerFrame;
end
