
NamePlateCommentatorDisplayInfoMixin = {};

function NamePlateCommentatorDisplayInfoMixin:OnUpdate()
	local parent = self:GetParent();
	local unitFrame = parent:GetParent();
	local CCIndicator = self.CCIndicator;
	local spellID, expirationTime, duration = C_Commentator.GetPlayerCrowdControlInfoByUnit(parent.unit);
	local iconTexture = select(3, GetSpellInfo(spellID));
	if iconTexture then
		CCIndicator.icon:SetTexture(iconTexture);
		CCIndicator.icon:Show();
	else
		CCIndicator.icon:Hide();
	end
	
	if expirationTime then
		CooldownFrame_Set(CCIndicator.Cooldown, expirationTime - duration, duration, true, true);
	else
		CooldownFrame_Clear(CCIndicator.Cooldown);
	end
	
	-- This BASE_MODEL_FRAME_SCALE adjustment is needed because the model frame needs to be sized
	-- with the appropriate ratio between width and height and also needs to have sufficient height
	-- to avoid the model being cut off even at the larger selected size.
	-- 1.35 was experimentally discovered to make the models and model frame size we have look good.
	local BASE_MODEL_FRAME_SCALE = 1.0 / 1.35;
	
	-- Normalize the scale changes for the model frame.
	local normalizedScale = (0.9 + unitFrame:GetScale()) / 2.0;
	local modelScale = normalizedScale * BASE_MODEL_FRAME_SCALE;
	
	self.OffensiveCooldownModel:SetScale(modelScale);
	self.DefensiveCooldownModel:SetScale(modelScale);
	
	local offensiveActive, defensiveActive = C_Commentator.HasTrackedAuras(parent.unit);
	self.OffensiveCooldownModel:SetShown(offensiveActive);
	self.DefensiveCooldownModel:SetShown(defensiveActive);
end