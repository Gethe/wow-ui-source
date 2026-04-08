
function ReputationStatusBarMixin:UpdateBarTextures(reactionLevel, overrideUseBlueBar)
	local color = FACTION_BAR_COLORS[reactionLevel];	
	self.StatusBar:SetStatusBarColor(color.r, color.g, color.b);
end
